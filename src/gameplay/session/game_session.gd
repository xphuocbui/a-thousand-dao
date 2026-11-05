class_name GameSession
extends RefCounted
## One life: owns the clock, the player, the world database and every gameplay service,
## and exposes each player action as a method that returns {ok, lines, ...}.
## Frontends (the debug terminal now, a Godot UI later) only call this API and render
## the returned lines; no gameplay rule lives in a frontend.
## Design: design/gdd/game-concept.md (core loop: seasons, actions, events, breakthroughs).
##
## Time model: one turn = one season (0.25 year). Every action that costs time passes
## seasons through [method _pass_season], which ages herbs, the player and the world.
##
## Usage:
## [codeblock]
## var s := GameSession.new(GameData.load_from(), LlmService.new(gd))
## s.new_game(42, {"mode": "roll", "name": "Lâm Vô Danh", "gender": "male", "origin": "tan_tu"})
## var r: Dictionary = s.cultivate(4)
## for line in r.lines: print(line)
## if s.has_pending_event(): s.choose(0)
## [/codeblock]

signal life_ended(summary: Dictionary)
## A great breakthrough succeeded (player only, Realms rule 9). [param realm_index] is the new realm.
signal breakthrough_succeeded(realm_index: int)

const SAVE_VERSION := 2
## Save versions load_dict can migrate from.
const SAVE_VERSIONS_READ := [1, 2]

var gd: GameData
var tree: MeridianTree
var llm: LlmService
var db: WorldDB
var rng := RandomNumberGenerator.new()

var items: ItemFactory
var builds: BuildGenerator
var field: HerbField
var alchemy: Alchemy
var refinery: Refinery
var talismans: Talismans
var beasts: BeastKeeper
var formations: Formations
var market: Market
var ticker: WorldTicker
var templates: EventTemplateSource
var validator: EventValidator
var resolver: EventResolver
var narrator: Narrator

var seed_value: int = 0
var year: int = 0
var season: int = 0
var player: Character
## Normalized event waiting for a choice ({} when none).
var pending_event: Dictionary = {}
## {source, warnings, llm_error} of the pending event.
var pending_meta: Dictionary = {}
var life_over: bool = false
## Set when debug commands touched this life: it can no longer earn achievements.
var cheated: bool = false
## The main character's edge (thiên mệnh, starting items, cơ duyên); false = baseline life.
var edge: bool = true
## Realm index -> cơ duyên events offered in that realm.
var co_duyen_used: Dictionary = {}
var epitaph_text: String = ""
## Lines from the yearly tick (upkeep, stipend) shown with the next action's result.
var _notices: Array = []


func _init(game_data: GameData, llm_service: LlmService, meridian_tree: MeridianTree = null) -> void:
	gd = game_data
	llm = llm_service
	tree = meridian_tree if meridian_tree != null else MeridianTree.generate(gd)


# --- Life cycle -------------------------------------------------------------------

## Generates a new world and player. [param spec]: mode ("roll" | "custom"), name, gender,
## origin, and for custom: thien_phu {id: value}, purities {element: purity}, variants [ids].
func new_game(seed_v: int, spec: Dictionary) -> Dictionary:
	seed_value = seed_v
	rng.seed = seed_v
	var gen := WorldGenerator.new(gd, tree)
	db = gen.generate(rng)
	year = gen.current_year
	season = 0
	_wire()
	life_over = false
	cheated = false
	edge = bool(spec.get("edge", true))
	co_duyen_used = {}
	pending_event = {}
	epitaph_text = ""
	var name: String = str(spec.get("name", "Vô Danh"))
	var gender: String = str(spec.get("gender", "male"))
	var origin: String = str(spec.get("origin", "tan_tu"))
	if spec.has("character"):
		# A character already created and approved in a frontend (e.g. the rerollable
		# preview in the terminal's character creation).
		player = Character.from_dict(spec.character)
		player.id = ""
	elif str(spec.get("mode", "roll")) == "custom":
		player = CharacterFactory.custom_player(gd, rng, name, gender, origin, spec.get("thien_phu", {}), spec.get("purities", {}), spec.get("variants", []))
	else:
		player = CharacterFactory.roll_player(gd, rng, name, gender, origin)
	if edge:
		_grant_edge(str(spec.get("perk", "")))
	player.id = db.add("people", player.to_dict())
	_place_player()
	if edge:
		for si in ProgressionEdges.config(gd).player.starting_items:
			if si.has("talisman"):
				var tal: Dictionary = items.talisman(str(si.talisman), int(si.qty))
				tal["owner_id"] = player.id
				db.add("items", tal)
	sync_player()
	var lines: Array = ["A new world: %d regions, %d places, %d sects, %d people, %d recorded events (%s năm %d)." % [
		db.count("regions"), db.count("places"), db.count("sects"), db.count("people"), db.count("events"), gd.world_gen().calendar_name, year]]
	lines.append("%s is born: %s" % [player.name, player.linh_can.describe(gd)])
	return {"ok": true, "lines": lines}


## Gives the thiên mệnh perk: the one chosen in the frontend, else a random one of the offer.
func _grant_edge(perk_id: String) -> void:
	var pid: String = perk_id
	if ProgressionEdges.perk(gd, pid).is_empty():
		pid = str(ProgressionEdges.roll_perk_choices(gd, rng)[0])
	ProgressionEdges.apply_birth(player, gd, pid)


## Event context with the session facts the rules need (edge, cơ duyên left this realm).
func event_context() -> Dictionary:
	var per: int = int(ProgressionEdges.config(gd).player.co_duyen_per_realm)
	var left: int = per - int(co_duyen_used.get(player.realm_index, 0)) if edge else 0
	return EventContext.build(player, gd, db, sheet(), year, season, llm.language, {"edge": edge, "co_duyen_left": left})


## Rebuilds services around the current database (after new_game or load).
func _wire() -> void:
	items = ItemFactory.new(gd)
	builds = BuildGenerator.new(gd, tree, db)
	field = HerbField.new(gd, db, items)
	alchemy = Alchemy.new(gd, db, items)
	refinery = Refinery.new(gd, db, items)
	talismans = Talismans.new(gd, db, items)
	beasts = BeastKeeper.new(gd, db)
	formations = Formations.new(gd, db)
	market = Market.new(gd, db, items)
	ticker = WorldTicker.new(gd, db, builds)
	templates = EventTemplateSource.new(gd, db, builds)
	validator = EventValidator.new(gd, db, builds)
	resolver = EventResolver.new(gd, db, builds, items)
	resolver.unseal_fn = _unseal_from_event
	narrator = Narrator.new(gd, db, llm, templates, validator)


func _place_player() -> void:
	var o: Dictionary = gd.origin(player.origin)
	var home: Dictionary = {}
	if bool(o.get("sect", false)):
		var sects: Array = db.find("sects", func(s): return s.status == "active")
		if not sects.is_empty():
			var s: Dictionary = RngUtils.pick(rng, sects)
			player.sect_id = s.id
			player.sect_rank = str(gd.session().sect.join_rank)
			s.members.append(player.id)
			home = db.get_record("places", s.hq_place_id)
	if home.is_empty():
		var types: Array = gd.session().home_place_types
		var towns: Array = db.find("places", func(p): return types.has(p.type))
		home = RngUtils.pick(rng, towns) if not towns.is_empty() else RngUtils.pick(rng, db.all("places"))
	player.home_id = home.id
	player.location_id = home.id
	var cp: Dictionary = items.cong_phap(rng, gd.cong_phap_tier_rank(str(o.get("cong_phap_tier", "hoang"))), [_starting_element()])
	cp["owner_id"] = player.id
	db.add("items", cp)
	CongPhap.learn(player, cp)
	player.main_tech = str(cp.tech_id)
	var province: Array = db.find("places", func(p): return bool(p.get("market", false)) and p.get("region_id", "") == home.get("region_id", ""))
	if province.is_empty():
		province = db.find("places", func(p): return bool(p.get("market", false)))
	if not province.is_empty():
		market.stock_guaranteed(province[0].id)
	var plot: int = 0
	for h in o.get("starting_herbs", []):
		for k in int(h.qty):
			var herb: Dictionary = items.herb(str(h.herb), float(h.age))
			herb["owner_id"] = player.id
			herb["plot"] = plot
			plot += 1
			db.add("items", herb)
	_log("player_born", {"a": player.id, "place": home.id})
	if player.sect_id != "":
		_log("player_joined_sect", {"a": player.id, "s1": player.sect_id})


## The strongest base element, ties in cycle order (cong-phap.md Edge Cases).
func _starting_element() -> String:
	var best: String = ""
	for e in gd.element_cycle():
		if player.linh_can.elements.has(e) and (best == "" or int(player.linh_can.elements[e]) > int(player.linh_can.elements[best])):
			best = e
	return best


## Writes the live player object back to its people record.
func sync_player() -> void:
	if player == null or db == null:
		return
	var rec: Dictionary = player.to_dict()
	var old: Dictionary = db.get_record("people", player.id)
	rec["created_by"] = "player"
	if builds != null:
		rec["power"] = builds.power_of(player)
	if old.has("death_year"):
		rec["death_year"] = old.death_year
	db.put("people", rec)


## Fresh stat sheet for the player.
func sheet() -> StatSheet:
	return StatSheet.build(player, gd, db, tree)


## "Năm 312, Thu" style clock label.
func clock_label() -> String:
	var names: Array = gd.world_gen().season_names
	return "%s năm %d, %s" % [gd.world_gen().calendar_name, year, names[season]]


## Absolute season counter (used for once-per-season limits).
func season_index() -> int:
	return year * int(gd.cultivation_rules().seasons_per_year) + season


## True while an event waits for a choice.
func has_pending_event() -> bool:
	return not pending_event.is_empty()


# --- Time ---------------------------------------------------------------------------

func _guard(needs_time: bool) -> Dictionary:
	if db == null or player == null:
		return {"ok": false, "lines": ["No game in progress. Use 'new'."]}
	if life_over:
		return {"ok": false, "lines": ["This life has ended. Use 'new' to begin another."]}
	if needs_time and has_pending_event():
		return {"ok": false, "lines": ["An event is waiting: '%s'. Use 'event' to read it and 'choose <n>'." % pending_event.title]}
	return {"ok": true, "lines": []}


## Passes one season. [param mode]: "cultivate", "closed_door" or "" (time passes only).
## Returns {tu_vi, stages, points, news: [event ids], died}.
func _pass_season(mode: String) -> Dictionary:
	var sh: StatSheet = sheet()
	var out := {"tu_vi": 0.0, "stages": 0, "points": 0, "news": [], "died": false}
	var cultivating: bool = mode == "cultivate" or mode == "closed_door"
	out["techniques"] = CongPhap.season_tick(player, gd, sh.effective("ngo_tinh", player), cultivating)
	if cultivating:
		for l in _check_technique_seals():
			_notices.append("  " + l)
	if cultivating:
		var density: float = float(db.get_record("places", player.location_id).get("density", 1.0))
		var gain: float = CultivationRules.rate_per_season(player, gd, db, sh, density).total
		if mode == "closed_door":
			gain *= float(gd.cultivation_rules().closed_door_efficiency)
		var res: Dictionary = CultivationRules.add_tu_vi(player, gd, gain)
		out.tu_vi = gain
		out.stages = res.stages
		out.points = res.tree_points
		if res.stages > 0:
			sh = sheet()
	elif mode == "travel" and player.has_capability(8):
		var density_t: float = float(db.get_record("places", player.location_id).get("density", 1.0))
		var r8: Dictionary = CultivationRules.add_tu_vi(player, gd, float(gd.capability(8).params.rate_mult) * CultivationRules.rate_per_season(player, gd, db, sh, density_t).total)
		out.tu_vi = r8.gained
		out.stages = r8.stages
		out.points = r8.tree_points
	field.grow(player, sh, 1)
	var d: Dictionary = gd.attributes().derived
	player.dan_doc = maxf(player.dan_doc - CharacterRules.dan_doc_decay(player, gd, sh).total, 0.0)
	player.tam_ma = maxf(player.tam_ma - float(d.tam_ma_natural_decay), 0.0)
	player.vitality = minf(player.vitality + float(d.injury_recovery_frac_per_season), 1.0)
	var aging: float = float(gd.capability(7).params.age_mult) if mode == "closed_door" and player.has_capability(7) else 1.0
	player.age += aging / float(gd.cultivation_rules().seasons_per_year)
	season += 1
	if season >= int(gd.cultivation_rules().seasons_per_year):
		season = 0
		year += 1
		_yearly()
	out.news = ticker.tick(rng, year, season)
	if player.age >= CultivationRules.lifespan(player, gd, sh).total:
		_end_life("Thọ nguyên cạn kiệt ở tuổi %d" % int(player.age))
		out.died = true
	sync_player()
	return out


func _yearly() -> void:
	if player.has_capability(3) and not player.equipped.is_empty():
		player.nurture_years += 1
	if player.sect_id != "":
		var stipend: int = int(gd.session().sect.stipend_per_year_by_realm.get(gd.realm(player.realm_index).id, 0))
		player.linh_thach += stipend
	for l in beasts.feed(player):
		_notices.append("  " + l)
	for l in formations.pay_upkeep(player):
		_notices.append("  " + l)
		_log("player_formation_decay", {"a": player.id})


func _news_lines(news: Array, limit: int = 3) -> Array:
	var lines: Array = _notices.duplicate()
	_notices.clear()
	for eid in news.slice(-limit):
		lines.append("  [tin đồn] " + str(db.get_record("events", eid).get("text", "")))
	return lines


## True when an event carries a cơ duyên gift (counted against the realm's allowance).
func _is_co_duyen(ev: Dictionary) -> bool:
	var gifts: Array = gd.budgets().get("co_duyen_effects", [])
	for ch in ev.get("choices", []):
		for part in [ch.get("always", []), ch.get("success", {}).get("effects", []), ch.get("failure", {}).get("effects", [])]:
			for fx in part:
				var key: String = str(fx.type) if str(fx.type) != "talisman" else "talisman:" + str(fx.get("talisman", ""))
				if gifts.has(key):
					return true
	return false


## Rolls for a random event at the current place. Returns lines describing it, or [].
## At a bình cảnh a life with the edge is likelier to meet one (cơ duyên).
func _maybe_event(bonus: float) -> Array:
	var cfg: Dictionary = gd.event_templates().random_event_chance
	var place: Dictionary = db.get_record("places", player.location_id)
	var chance: float = float(cfg.base) + float(cfg.per_danger) * float(place.get("danger", 1)) + bonus
	if edge and CultivationRules.at_bottleneck(player, gd) and int(co_duyen_used.get(player.realm_index, 0)) < int(ProgressionEdges.config(gd).player.co_duyen_per_realm):
		chance += float(ProgressionEdges.config(gd).player.co_duyen_bottleneck_event_bonus) * (1.0 + sheet().total("co_duyen_pct") / 100.0)
	if rng.randf() >= chance:
		return []
	var lines: Array = start_event("")
	# Capability #20: a hostile event may pass the character by.
	if player.has_capability(20) and has_pending_event() and rng.randf() >= float(gd.capability(20).params.hostile_mult):
		if pending_event.choices.any(func(ch): return str(ch.check.type) == "combat"):
			pending_event = {}
			pending_meta = {}
			return []
	return lines


## Generates an event now (LLM first, templates as fallback). [param template_id] forces a template.
func start_event(template_id: String) -> Array:
	var ctx: Dictionary = event_context()
	var res: Dictionary = narrator.generate_event(ctx, rng, template_id)
	if not res.ok:
		return ["(No event fits here.%s)" % ((" " + res.llm_error) if res.llm_error != "" else "")]
	pending_event = res.event
	pending_meta = {"source": res.source, "warnings": res.warnings, "llm_error": res.llm_error}
	if _is_co_duyen(pending_event):
		co_duyen_used[player.realm_index] = int(co_duyen_used.get(player.realm_index, 0)) + 1
		_log("player_co_duyen", {"a": player.id, "place": player.location_id})
	return ["", "*** EVENT: %s ***  (type 'event' to read, 'choose <n>' to act)" % pending_event.title]


# --- Actions ------------------------------------------------------------------------

## Tu luyện for [param seasons] seasons (stops early if an event interrupts).
func cultivate(seasons: int) -> Dictionary:
	var g: Dictionary = _guard(true)
	if not g.ok:
		return g
	var n: int = clampi(seasons, 1, int(gd.session().cultivate.max_seasons_per_command))
	var total: float = 0.0
	var stages: int = 0
	var points: int = 0
	var news: Array = []
	var lines: Array = []
	var done: int = 0
	for i in n:
		var r: Dictionary = _pass_season("cultivate")
		done += 1
		total += r.tu_vi
		stages += r.stages
		points += r.points
		news.append_array(r.news)
		if r.died:
			break
		var ev: Array = _maybe_event(0.0)
		if not ev.is_empty():
			lines.append_array(ev)
			break
	lines.push_front("Tu luyện %d season(s): +%.0f tu vi%s. Now %s (%.0f / %.0f)." % [done, total,
		(", +%d stage(s), +%d Kinh Mạch points" % [stages, points]) if stages > 0 else "",
		gd.realm_label(player.realm_index, player.stage), player.tu_vi, CultivationRules.level_requirement(player, gd)])
	if CultivationRules.at_bottleneck(player, gd):
		lines.insert(1, "  Bình cảnh! Further tu vi is wasted. Use 'breakthrough' (a %s helps greatly)." % str(gd.realm(player.realm_index + 1).entry_requirement.item_tag))
	lines.append_array(_news_lines(news))
	if life_over:
		lines.append_array(death_lines())
	return {"ok": true, "lines": lines}


## Bế quan for whole years: more efficient, no events, the world moves on.
func closed_door(years: int) -> Dictionary:
	var g: Dictionary = _guard(true)
	if not g.ok:
		return g
	var y: int = clampi(years, 1, int(gd.session().closed_door.max_years))
	var total: float = 0.0
	var stages: int = 0
	var news: Array = []
	var seasons: int = y * int(gd.cultivation_rules().seasons_per_year)
	var done: int = 0
	for i in seasons:
		var r: Dictionary = _pass_season("closed_door")
		done += 1
		total += r.tu_vi
		stages += r.stages
		news.append_array(r.news)
		if r.died:
			break
	var lines: Array = ["Bế quan %.1f năm: +%.0f tu vi (x%s efficiency)%s. Now %s, age %d." % [
		float(done) / float(gd.cultivation_rules().seasons_per_year), total, str(gd.cultivation_rules().closed_door_efficiency),
		(", +%d stage(s)" % stages) if stages > 0 else "", gd.realm_label(player.realm_index, player.stage), int(player.age)]]
	if CultivationRules.at_bottleneck(player, gd):
		lines.append("  You reached a bình cảnh during seclusion; excess tu vi was lost.")
	lines.append("  %d things happened in the world while you were secluded; 'news' shows them." % news.size())
	lines.append_array(_news_lines(news))
	if life_over:
		lines.append_array(death_lines())
	return {"ok": true, "lines": lines}


## Sect mission (at your sect's headquarters) or bounty work (in a town). One season.
func mission() -> Dictionary:
	var g: Dictionary = _guard(true)
	if not g.ok:
		return g
	var cfg: Dictionary = gd.session().mission
	var place: Dictionary = db.get_record("places", player.location_id)
	var sect: Dictionary = db.get_record("sects", player.sect_id)
	var base: float
	var kind: String
	if not sect.is_empty() and sect.hq_place_id == player.location_id:
		base = float(cfg.sect_base_income)
		kind = "Sect mission for %s" % sect.name
	elif bool(place.get("bounties", false)):
		base = float(cfg.bounty_base_income)
		kind = "Bounty work in %s" % place.name
	else:
		return {"ok": false, "lines": ["No work here: go to your sect's headquarters or a town/city with bounties."]}
	var sh: StatSheet = sheet()
	var income := Breakdown.new("Income")
	income.base(kind, base)
	income.mul("Realm scale", float(cfg.income_realm_scale.get(gd.realm(player.realm_index).id, 1.0)))
	income.mul("Kim/mission multiplier", CharacterRules.mission_income(player, gd, sh).total)
	var earned: int = int(roundf(income.total))
	player.linh_thach += earned
	var lines: Array = ["%s: +%d linh thạch (now %d)." % [kind, earned, player.linh_thach]]
	if rng.randf() < float(cfg.injury_chance):
		player.vitality = maxf(player.vitality - float(cfg.injury_khi_huyet_loss_pct) / 100.0, 0.05)
		lines.append("  You were wounded: khí huyết -%d%%." % int(cfg.injury_khi_huyet_loss_pct))
	var r: Dictionary = _pass_season("")
	lines.append_array(_news_lines(r.news))
	if not r.died:
		lines.append_array(_maybe_event(0.0))
	else:
		lines.append_array(death_lines())
	return {"ok": true, "lines": lines}


## Explore the current place for a season: small finds, lost treasures, likely events.
func explore() -> Dictionary:
	var g: Dictionary = _guard(true)
	if not g.ok:
		return g
	var cfg: Dictionary = gd.session().explore
	var place: Dictionary = db.get_record("places", player.location_id)
	var b: Dictionary = EventContext.budget(player, gd, sheet())
	var found: int = int(roundf(RngUtils.range_f(rng, cfg.loot_linh_thach_frac) * float(b.linh_thach_max)))
	player.linh_thach += found
	var lines: Array = ["You explore %s for a season and find %d linh thạch." % [place.name, found]]
	if rng.randf() < float(cfg.get("material_find_chance", 0.0)):
		var m: Dictionary = items.random_material(rng, int(b.get("material_rarity_max", 1)))
		m["qty"] = rng.randi_range(1, int(cfg.get("material_qty_max", 1)))
		m["owner_id"] = player.id
		var mid: String = market.add_or_merge(player, m)
		lines.append("  You also gather %s." % items.describe(db.get_record("items", mid)))
	for lost in db.items_of(place.id):
		var sh: StatSheet = sheet()
		var chance: float = resolver.stat_check_chance(player, sh, str(cfg.lost_item_check.stat), float(cfg.lost_item_check.difficulty)).total
		if rng.randf() < chance:
			lost["owner_id"] = player.id
			lost.erase("lost")
			_log("player_found_lost", {"a": player.id, "item": lost.id, "place": place.id})
			lines.append("  !!! You sense a hidden aura and unearth %s, lost here long ago. [%s]" % [items.describe(lost), lost.id])
		else:
			lines.append("  You sense something hidden here, but cannot find it (%.0f%% chance)." % (chance * 100.0))
		break
	var r: Dictionary = _pass_season("")
	lines.append_array(_news_lines(r.news))
	if not r.died:
		lines.append_array(_maybe_event(float(gd.event_templates().random_event_chance.explore_bonus)))
	else:
		lines.append_array(death_lines())
	return {"ok": true, "lines": lines}


## Travel to a linked place. Takes the link's seasons (faster with travel_speed_pct).
func travel(dest_id: String) -> Dictionary:
	var g: Dictionary = _guard(true)
	if not g.ok:
		return g
	var here: Dictionary = db.get_record("places", player.location_id)
	var link: Dictionary = {}
	for l in here.links:
		if l.to == dest_id:
			link = l
	if link.is_empty():
		return {"ok": false, "lines": ["%s is not reachable directly from %s. Use 'map' to see roads." % [dest_id, here.name]]}
	var speed: float = sheet().total("travel_speed_pct")
	var seasons: int = maxi(1, int(ceil(float(link.seasons) / maxf(1.0 + speed / 100.0, 0.1))))
	var news: Array = []
	var died: bool = false
	for i in seasons:
		var r: Dictionary = _pass_season("travel")
		news.append_array(r.news)
		if r.died:
			died = true
			break
	if died:
		return {"ok": true, "lines": ["You die on the road."] + death_lines()}
	player.location_id = dest_id
	if not player.visited.has(dest_id):
		player.visited.append(dest_id)
	for b in beasts.owned(player):
		b["location_id"] = dest_id
	sync_player()
	var dest: Dictionary = db.get_record("places", dest_id)
	market.ensure_stock(rng, dest_id, year, player.realm_index, player.linh_can)
	var lines: Array = ["You travel %d season(s) and arrive at %s." % [seasons, dest.name]]
	lines.append_array(_news_lines(news))
	lines.append_array(_maybe_event(0.0))
	return {"ok": true, "lines": lines}


## Capability #21: once a year, travel instantly to any visited place.
func blink(dest_id: String) -> Dictionary:
	var g: Dictionary = _guard(true)
	if not g.ok:
		return g
	if not player.has_capability(21):
		return {"ok": false, "lines": ["You hold no Blink Mark."]}
	if player.blink_year == year:
		return {"ok": false, "lines": ["The mark has not recovered this year."]}
	if not player.visited.has(dest_id):
		return {"ok": false, "lines": ["You have not been to %s." % dest_id]}
	player.blink_year = year
	player.location_id = dest_id
	sync_player()
	return {"ok": true, "lines": ["You step through the mark to %s." % db.get_record("places", dest_id).get("name", dest_id)]}


## Luyện đan one recipe (one season; with capability #10 two recipes share a season).
func craft(recipe_id: String) -> Dictionary:
	var g: Dictionary = _guard(true)
	if not g.ok:
		return g
	var r: Dictionary = alchemy.craft(player, sheet(), rng, recipe_id)
	if not r.ok:
		return {"ok": false, "lines": [r.message]}
	var lines: Array = [r.message]
	if player.has_capability(10) and not player.cap_used.has("10_brew"):
		player.cap_used["10_brew"] = true
		return {"ok": true, "lines": lines + ["The second furnace is still lit: one more brew fits this season."]}
	player.cap_used.erase("10_brew")
	var t: Dictionary = _pass_season("")
	lines.append_array(_news_lines(t.news))
	if t.died:
		lines.append_array(death_lines())
	return {"ok": true, "lines": lines}


## Luyện khí: refines a pháp bảo of [param base_id] at [param tier] (-1 = own realm). One season.
func refine(base_id: String, tier: int = -1) -> Dictionary:
	var g: Dictionary = _guard(true)
	if not g.ok:
		return g
	var t: int = player.realm_index if tier < 0 else tier
	var r: Dictionary = refinery.refine(player, sheet(), rng, base_id, t)
	if not r.ok:
		return {"ok": false, "lines": [r.message]}
	if r.success:
		_log("player_refined", {"a": player.id, "item": r.item_id})
	var lines: Array = [r.message]
	var p: Dictionary = _pass_season("")
	lines.append_array(_news_lines(p.news))
	if p.died:
		lines.append_array(death_lines())
	return {"ok": true, "lines": lines}


## Phù lục: draws one batch of talismans. One season.
func draw_talisman(talisman_id: String) -> Dictionary:
	var g: Dictionary = _guard(true)
	if not g.ok:
		return g
	var r: Dictionary = talismans.draw(player, sheet(), rng, talisman_id)
	if not r.ok:
		return {"ok": false, "lines": [r.message]}
	var lines: Array = [r.message]
	var p: Dictionary = _pass_season("")
	lines.append_array(_news_lines(p.news))
	if p.died:
		lines.append_array(death_lines())
	return {"ok": true, "lines": lines}


## Trận pháp: raises a formation at the động phủ one level. One season.
func formation_build(formation_id: String) -> Dictionary:
	var g: Dictionary = _guard(true)
	if not g.ok:
		return g
	var r: Dictionary = formations.build(player, formation_id)
	if not r.ok:
		return {"ok": false, "lines": [r.message]}
	_log("player_formation", {"a": player.id, "place": player.home_id})
	var lines: Array = [r.message]
	var p: Dictionary = _pass_season("")
	lines.append_array(_news_lines(p.news))
	if p.died:
		lines.append_array(death_lines())
	return {"ok": true, "lines": lines}


## Lets an owned linh thú go.
func release_beast(beast_id: String) -> Dictionary:
	var g: Dictionary = _guard(false)
	if not g.ok:
		return g
	var r: Dictionary = beasts.release(player, beast_id)
	sync_player()
	return {"ok": r.ok, "lines": [r.message]}


## Plants a seed (herb template id or name) or transplants an owned herb item id.
func plant(what: String) -> Dictionary:
	var g: Dictionary = _guard(false)
	if not g.ok:
		return g
	var r: Dictionary
	if db.has_record("items", what):
		r = field.transplant(player, sheet(), what)
	else:
		var herb_id: String = _herb_id(what)
		r = field.plant_seed(player, sheet(), herb_id)
	sync_player()
	return {"ok": r.ok, "lines": [r.message]}


## Harvests a plot, or every plot with [param plot] = -1.
func harvest(plot: int) -> Dictionary:
	var g: Dictionary = _guard(false)
	if not g.ok:
		return g
	var lines: Array = []
	var planted: Dictionary = field.planted(player)
	var plots: Array = [plot] if plot >= 0 else planted.keys()
	if plots.is_empty():
		return {"ok": false, "lines": ["Nothing is planted."]}
	if plot < 0:
		# "harvest all" never pulls a herb younger than its mature age; name the plot to force it.
		var young: Array = plots.filter(func(p): return float(planted[p].age) < float(gd.herb(planted[p].template).get("mature_years", 0.0)))
		for p in young:
			lines.append("Plot %d: %s is not mature yet (%.1f / %.0f năm); left in the ground. Use 'harvest %d' to force." % [int(p), planted[p].name, float(planted[p].age), float(gd.herb(planted[p].template).mature_years), int(p)])
		plots = plots.filter(func(p): return not young.has(p))
	var any_ok: bool = false
	for p in plots:
		var r: Dictionary = field.harvest(player, int(p))
		lines.append(r.message)
		any_ok = any_ok or r.ok
	return {"ok": any_ok, "lines": lines}


## Eats a pill.
func use_item(item_id: String) -> Dictionary:
	var g: Dictionary = _guard(false)
	if not g.ok:
		return g
	if db.get_record("items", item_id).get("kind", "") == "treasure":
		var t: Dictionary = TreasureEffects.use(player, gd, db, rng, item_id)
		if t.has("unseal_item"):
			return _use_seal_key(item_id)
		if t.ok:
			_log_root_changes("player_linh_can_changed", t.changes)
		sync_player()
		return {"ok": t.ok, "lines": [t.message]}
	var r: Dictionary = PillEffects.consume(player, gd, db, sheet(), item_id)
	var lines: Array = [r.message]
	if r.ok:
		_log_root_changes("player_root_purified", r.get("changes", []))
	if r.ok and float(r.get("tu_vi", 0.0)) > 0.0:
		var res: Dictionary = CultivationRules.add_tu_vi(player, gd, float(r.tu_vi))
		if res.stages > 0:
			lines.append("  Stage up! Now %s (+%d Kinh Mạch points)." % [gd.realm_label(player.realm_index, player.stage), res.tree_points])
		if res.bottleneck:
			lines.append("  Bình cảnh reached.")
	sync_player()
	return {"ok": r.ok, "lines": lines}


## Equips a pháp bảo.
func equip(item_id: String) -> Dictionary:
	var g: Dictionary = _guard(false)
	if not g.ok:
		return g
	var item: Dictionary = db.get_record("items", item_id)
	if item.is_empty() or item.owner_id != player.id or item.kind != "artifact":
		return {"ok": false, "lines": ["You own no pháp bảo %s." % item_id]}
	if player.equipped.has(item_id):
		return {"ok": false, "lines": ["Already equipped."]}
	var slots: int = int(gd.artifacts_file().equip.max_slots) + (int(gd.capability(2).params.slots) if player.has_capability(2) else 0)
	if player.equipped.size() >= slots:
		return {"ok": false, "lines": ["All %d slots are full." % slots]}
	player.equipped.append(item_id)
	sync_player()
	var p: Dictionary = CombatPower.compute(player, gd, db, sheet())
	var lines: Array = ["Equipped %s. Chiến lực now %.0f." % [item.name, p.total]]
	if p.overflow.has(item_id):
		lines.append("  Warning: your thần thức (%.0f) cannot control it as well; it adds nothing until you grow stronger or unequip something." % p.than_thuc_capacity)
	return {"ok": true, "lines": lines}


## Unequips a pháp bảo.
func unequip(item_id: String) -> Dictionary:
	var g: Dictionary = _guard(false)
	if not g.ok:
		return g
	if not player.equipped.has(item_id):
		return {"ok": false, "lines": ["%s is not equipped." % item_id]}
	player.equipped.erase(item_id)
	sync_player()
	return {"ok": true, "lines": ["Unequipped %s." % db.get_record("items", item_id).get("name", item_id)]}


## Reads an owned manual: its technique joins the known list at layer 1 (cong-phap.md rule 4).
func learn(item_id: String) -> Dictionary:
	var g: Dictionary = _guard(false)
	if not g.ok:
		return g
	var item: Dictionary = db.get_record("items", item_id)
	if item.is_empty() or item.owner_id != player.id or item.kind != "cong_phap":
		return {"ok": false, "lines": ["You own no manual %s." % item_id]}
	if not CongPhap.learn(player, item):
		return {"ok": false, "lines": ["You already know %s." % item.name]}
	sync_player()
	var lines: Array = ["You learn %s at layer 1. Put it in a slot with 'slot'." % item.name]
	if not CongPhap.usable(player, player.techniques[str(item.tech_id)].def):
		lines.append("  Your root lacks what it names, so it cannot be slotted yet.")
	return {"ok": true, "lines": lines}


## Changes a technique slot at the season start. [param slot] is main, second or aux with
## [param index]; key "" empties it. A change that would end the life needs [param confirm]
## (Realms rule 14). Returns {ok, lines, needs_confirm}.
func set_slot(slot: String, index: int, key: String, confirm: bool = false) -> Dictionary:
	var g: Dictionary = _guard(false)
	if not g.ok:
		return g
	var before: Dictionary = {"main": player.main_tech, "second": player.second_tech, "aux": player.aux_tech.duplicate()}
	var r: Dictionary = CongPhap.set_slot(player, gd, slot, index, key)
	if not r.ok:
		return {"ok": false, "lines": [r.reason]}
	var cap: float = CultivationRules.lifespan(player, gd, sheet()).total
	if cap <= player.age and not confirm:
		player.main_tech = before.main
		player.second_tech = before.second
		player.aux_tech = before.aux
		return {"ok": false, "needs_confirm": true, "lines": ["Your lifespan falls to %d; you are %d: you will die of old age." % [int(cap), int(player.age)]]}
	sync_player()
	if cap <= player.age:
		_end_life("Thọ nguyên cạn kiệt ở tuổi %d" % int(player.age))
		return {"ok": true, "lines": death_lines()}
	var f: Dictionary = CongPhap.speed_factor(player, gd)
	return {"ok": true, "lines": ["Slots set. Speed factor: %s = x%.2f." % [f.label, f.mult]]}


## Local spiritual qi: the place's density plus density_bonus, the same sum the rate uses.
func local_density(sh: StatSheet) -> float:
	return float(db.get_record("places", player.location_id).get("density", 1.0)) + sh.total("density_bonus")


## True if a talisman would go on this attempt: one held, and none used this realm step.
func talisman_available() -> bool:
	return not _breakthrough_talisman().is_empty() and not player.talisman_used


func _breakthrough_talisman() -> Dictionary:
	for it in db.items_of(player.id):
		if it.kind == "talisman" and str(Talismans.def_of(gd, str(it.template)).get("use", "")) == "breakthrough":
			return it
	return {}


## Attempts the great breakthrough (Realms rules 7-11). The best matching pill and the
## talisman burn on a pill attempt. With a pill held but the condition unmet the attempt
## would be bare: that needs [param confirm_bare]. [param use_talisman] is the preview toggle.
## [param burn_life] commits capability #23's extra roll if this pill attempt fails.
func breakthrough(confirm_bare: bool = false, use_talisman: bool = true, burn_life: bool = false) -> Dictionary:
	var g: Dictionary = _guard(true)
	if not g.ok:
		return g
	if not CultivationRules.at_bottleneck(player, gd):
		return {"ok": false, "lines": ["You are not at a bottleneck (%s, %.0f / %.0f tu vi)." % [gd.realm_label(player.realm_index, player.stage), player.tu_vi, CultivationRules.level_requirement(player, gd)]]}
	var next: Dictionary = gd.realm(player.realm_index + 1)
	var pill: Dictionary = Advisor.best_pill(self, str(next.entry_requirement.item_tag))
	var sh: StatSheet = sheet()
	var cond: Dictionary = CultivationRules.breakthrough_condition(player, gd, local_density(sh))
	var is_pill: bool = not pill.is_empty() and bool(cond.met)
	if not pill.is_empty() and not bool(cond.met) and not confirm_bare:
		return {"ok": false, "needs_confirm": true, "lines": ["Condition not met: %s. This would be a bare attempt at %.2f%%, burning no pill." % [cond.text, 100.0 * float(next.entry_requirement.base_chance)]]}
	if not is_pill and not CultivationRules.bare_attempt_left(player, gd):
		return {"ok": false, "lines": ["Bare attempts used up for this breakthrough."]}
	var rank: int = int(pill.quality) if is_pill else -1
	var talisman: bool = is_pill and use_talisman and talisman_available()
	var chance: Breakdown = CultivationRules.breakthrough_chance(player, gd, sh, rank, talisman)
	var odds: float = chance.total
	var lines: Array = Array(chance.lines())
	var step_used: bool = player.cap_used.has("22") or player.cap_used.has("23")
	var left: float = CultivationRules.lifespan(player, gd, sh).total - player.age
	var tau: float = CultivationRules.talisman_value(gd) if talisman else 0.0
	var held: int = int(pill.get("qty", 0)) if is_pill else 0
	if is_pill and player.has_capability(22) and not step_used and left < float(gd.capability(22).params.years_left):
		var s_guard: float = CultivationRules.guard_success(player, gd, held, odds - tau)
		odds = CultivationRules.q_desperate(gd, odds - tau, tau, s_guard) + tau
		player.cap_used["22"] = true
		step_used = true
		lines.append("  Hồi Quang Phản Chiếu lifts this attempt to %.1f%%." % (odds * 100.0))
	if talisman:
		var tal: Dictionary = _breakthrough_talisman()
		if not Talismans.keeps_talisman(player, gd, rng):
			tal["qty"] = int(tal.qty) - 1
			if int(tal.qty) <= 0:
				db.remove("items", tal.id)
		player.talisman_used = true
		lines.push_front("You burn %s." % tal.name)
	if is_pill:
		pill["qty"] = int(pill.qty) - 1
		if int(pill.qty) <= 0:
			db.remove("items", pill.id)
		lines.append("  Consumed 1 %s." % pill.name)
	var res: Dictionary = CultivationRules.resolve_attempt(player, gd, sh, rng, odds, is_pill)
	lines.append("Roll %.0f vs %.0f%%." % [res.roll * 100.0, res.chance * 100.0])
	if not res.success and not res.died and is_pill and burn_life and player.has_capability(23) and not step_used:
		var burn: float = CultivationRules.burn_cost(player, gd)
		var life_left: float = CultivationRules.lifespan(player, gd, sheet()).total - player.age
		if life_left > burn:
			player.age += burn
			player.cap_used["23"] = true
			var q: float = CultivationRules.breakthrough_chance(player, gd, sheet(), rank, false).total
			var insight: float = CultivationRules.failure_insight(gd, player.failed_pills)
			var s_g: float = CultivationRules.guard_success(player, gd, maxi(held - 1, 0), q)
			var retry: float = CultivationRules.q_retry(gd, q, insight, s_g)
			lines.append("Thiêu Thọ Phá Cảnh: %.0f years burn; an extra roll at %.1f%%." % [burn, retry * 100.0])
			res = CultivationRules.resolve_attempt(player, gd, sheet(), rng, retry, true)
			lines.append("Roll %.0f vs %.0f%%." % [res.roll * 100.0, res.chance * 100.0])
	if res.success:
		_log("player_breakthrough", {"a": player.id, "realm": next.name})
		lines.append("*** BREAKTHROUGH! You are now %s. +%d Kinh Mạch points. Lifespan rises to %.0f. ***" % [gd.realm_label(player.realm_index, player.stage), res.points, CultivationRules.lifespan(player, gd, sheet()).total])
		lines.append_array(_on_breakthrough_succeeded())
	else:
		_log("player_breakthrough_fail", {"a": player.id, "realm": next.name})
		lines.append("Breakthrough failed: -%.0f tu vi, tâm ma +%.1f, khí huyết now %d%%." % [res.tu_vi_lost, res.tam_ma_gained, int(player.vitality * 100.0)])
		if res.backlash:
			lines.append("  Tẩu hỏa nhập ma! Your meridians convulse.")
		if res.died:
			_end_life(player.death_cause)
			lines.append_array(death_lines())
	sync_player()
	var t: Dictionary = {"died": false, "news": []}
	if not life_over:
		t = _pass_season("")
	lines.append_array(_news_lines(t.news))
	return {"ok": true, "lines": lines}


## The player-only breakthrough_succeeded event: Mutation Awakening when capability #24 is held
## (linh-can.md rule 10). Only a formed variant is recorded.
func _on_breakthrough_succeeded() -> Array:
	breakthrough_succeeded.emit(player.realm_index)
	if not player.has_capability(int(gd.attributes().linh_can.awakening_capability)):
		return []
	var formed: Array = player.linh_can.awakening_pass(gd, rng)
	var changes: Array = []
	for id in formed:
		changes.append({"what": "variant", "id": id, "from": 0, "to": int(player.linh_can.variants[id])})
	_log_root_changes("player_variant_awakened", changes)
	return [TreasureEffects.variants_text(gd, player.linh_can, formed).strip_edges()] if not formed.is_empty() else []


## Opens a Kinh Mạch Đồ node; with [param walk_path] opens the whole shortest path.
func tree_allocate(node_id: int, walk_path: bool) -> Dictionary:
	var g: Dictionary = _guard(false)
	if not g.ok:
		return g
	var targets: Array = tree.path_to(player, gd, node_id) if walk_path else [node_id]
	if walk_path and targets.size() > player.tree_points:
		return {"ok": false, "lines": ["The route costs %d points; you have %d." % [targets.size(), player.tree_points]]}
	if targets.is_empty():
		return {"ok": false, "lines": ["Nothing to open (already open or unreachable)."]}
	if targets.size() > player.tree_points:
		return {"ok": false, "lines": ["Path needs %d points; you have %d." % [targets.size(), player.tree_points]]}
	var lines: Array = []
	for nid in targets:
		var check: Dictionary = tree.can_allocate(player, int(nid), gd)
		if not check.ok:
			lines.append("Cannot open #%d %s: %s" % [int(nid), tree.node(int(nid)).get("name", ""), check.reason])
			break
		player.tree_nodes.append(int(nid))
		player.tree_points -= 1
		lines.append("Opened #%d %s: %s" % [int(nid), tree.node(int(nid)).name, tree.describe_mods(int(nid), player.linh_can, gd)])
		for nb in tree.neighbors(int(nid)):
			var hint: int = int(tree.node(nb).get("cluster", -1))
			if hint >= 0 and not player.discovered.has(hint):
				player.discovered.append(hint)
				lines.append("  You sense a hidden cluster nearby: %s." % tree.clusters[hint].name)
		var cap: int = int(tree.node(int(nid)).get("capability", 0))
		if cap > 0 and not player.has_capability(cap):
			player.grant_capability(cap)
			lines.append("  Capability gained: %s. %s" % [gd.capability(cap).name, gd.capability(cap).desc])
	sync_player()
	return {"ok": true, "lines": lines}


## Buys an item from the market here.
func buy(item_id: String) -> Dictionary:
	var g: Dictionary = _guard(false)
	if not g.ok:
		return g
	var r: Dictionary = market.buy(player, sheet(), player.location_id, item_id)
	sync_player()
	return {"ok": r.ok, "lines": [r.message]}


## Sells one unit of an owned item at the market here.
func sell(item_id: String) -> Dictionary:
	var g: Dictionary = _guard(false)
	if not g.ok:
		return g
	var r: Dictionary = market.sell(player, sheet(), player.location_id, item_id)
	sync_player()
	return {"ok": r.ok, "lines": [r.message]}


## Talks to a person at the same place (once per season each).
func talk(npc_id: String, player_line: String) -> Dictionary:
	var g: Dictionary = _guard(false)
	if not g.ok:
		return g
	var npc: Dictionary = db.get_record("people", npc_id)
	if npc.is_empty() or not npc.alive or npc.get("is_player", false):
		return {"ok": false, "lines": ["No living person %s." % npc_id]}
	if str(npc.location_id) != player.location_id:
		return {"ok": false, "lines": ["%s is not here." % npc.name]}
	if npc.get("is_beast", false):
		return {"ok": false, "lines": ["%s only growls." % npc.name]}
	if int(npc.get("last_talk_season", -1)) == season_index():
		return {"ok": false, "lines": ["You already spoke with %s this season." % npc.name]}
	npc["last_talk_season"] = season_index()
	var ctx: Dictionary = event_context()
	var r: Dictionary = narrator.talk(npc, ctx, player_line, rng)
	var cfg: Dictionary = gd.session().talk
	var change: int = clampi(int(r.attitude_change), -int(cfg.attitude_change_max), int(cfg.attitude_change_max))
	npc["attitude"] = clampi(int(npc.get("attitude", 0)) + change, int(cfg.relationship_min), int(cfg.relationship_max))
	var lines: Array = [r.reply]
	if r.rumor_id != "":
		var ent: Dictionary = db.lookup(r.rumor_id)
		lines.append("  (hint: %s %s — 'db show %s')" % [r.rumor_id, str(ent.get("name", ent.get("text", ""))).substr(0, 60), r.rumor_id])
	lines.append("  [%s | attitude %+d -> %d]%s" % [r.source, change, int(npc.attitude), (" " + r.error) if r.error != "" else ""])
	return {"ok": true, "lines": lines}


## Resolves the pending event with choice [param index] (0-based).
func choose(index: int) -> Dictionary:
	var g: Dictionary = _guard(false)
	if not g.ok:
		return g
	if not has_pending_event():
		return {"ok": false, "lines": ["No event is waiting."]}
	var check: Dictionary = resolver.can_choose(player, pending_event, index)
	if not check.ok:
		return {"ok": false, "lines": ["Cannot choose that: %s." % check.reason]}
	var event: Dictionary = pending_event
	var sh: StatSheet = sheet()
	var result: Dictionary = resolver.resolve(player, sh, rng, event, index)
	var story: Dictionary = narrator.narrate(event, index, result)
	var people: Array = [player.id]
	if str(event.npc_id) != "":
		people.append(event.npc_id)
	db.log_event(year, season, "story", "%s — %s: %s" % [event.title, event.choices[index].label, "thành công" if result.success else "thất bại"],
		people, [event.place_id], result.items, {"narration": story.text, "effects": result.lines, "source": pending_meta.get("source", "")})
	pending_event = {}
	pending_meta = {}
	var lines: Array = ["> " + str(event.choices[index].label), ""]
	lines.append(story.text)
	lines.append("")
	for l in result.lines:
		lines.append("  " + l)
	if story.error != "":
		lines.append("  (%s)" % story.error)
	if result.died:
		_end_life(player.death_cause)
		lines.append_array(death_lines())
	sync_player()
	return {"ok": true, "lines": lines}


# --- Death ----------------------------------------------------------------------------

func _end_life(cause: String) -> void:
	if life_over:
		return
	life_over = true
	player.alive = false
	player.death_cause = cause
	_log("player_death", {"a": player.id, "cause": cause})
	var facts: String = "%s, %s, died at age %d in %s. Linh căn: %s. Cause: %s. Notable events: %s" % [
		player.name, gd.realm_label(player.realm_index, player.stage), int(player.age), clock_label(),
		player.linh_can.describe(gd), cause, "; ".join(db.events_of(player.id).slice(-8).map(func(e): return str(e.text)))]
	epitaph_text = narrator.epitaph(facts).text
	sync_player()
	life_ended.emit({"name": player.name, "realm": gd.realm_label(player.realm_index, player.stage), "age": player.age, "cause": cause})


## Lines shown when the life ends.
func death_lines() -> Array:
	return ["", "======== %s ========" % "ĐẠO TIÊU THÂN VẪN", epitaph_text, "", "Your life is over. 'chronicle' shows your story; 'new' begins another life."]


# --- Save / load ------------------------------------------------------------------

## Whole session as a JSON-safe Dictionary.
func to_dict() -> Dictionary:
	sync_player()
	return {
		"version": SAVE_VERSION, "seed": seed_value, "rng_state": str(rng.state), "rng_seed": str(rng.seed),
		"year": year, "season": season, "player_id": player.id, "db": db.to_dict(),
		"pending_event": pending_event, "pending_meta": pending_meta, "life_over": life_over, "epitaph": epitaph_text, "cheated": cheated,
		"edge": edge, "co_duyen_used": co_duyen_used,
	}


## Restores a session saved by [method to_dict]. Returns {ok, lines}.
func load_dict(d: Dictionary) -> Dictionary:
	if not SAVE_VERSIONS_READ.has(int(d.get("version", 0))):
		return {"ok": false, "lines": ["Save version %s is not supported." % str(d.get("version"))]}
	seed_value = int(d.seed)
	rng.seed = str(d.rng_seed).to_int()
	rng.state = str(d.rng_state).to_int()
	year = int(d.year)
	season = int(d.season)
	db = WorldDB.from_dict(d.db)
	for rec in db.all("people"):
		if rec.has("linh_can"):
			rec["linh_can"] = LinhCan.migrate_record(rec.linh_can, gd)
		var old_ladder: bool = not rec.has("level")
		Ladder.migrate_record(rec, gd)
		CongPhap.migrate_record(rec, db, gd)
		if old_ladder:
			# The old map's ids mean nothing on the new map: the points come back unspent.
			rec["tree_nodes"] = [MeridianTree.ROOT_ID]
			rec["tree_points"] = Ladder.points_total(gd, int(rec.level))
	_wire()
	player = Character.from_dict(db.get_record("people", str(d.player_id)))
	pending_event = d.get("pending_event", {})
	pending_meta = d.get("pending_meta", {})
	life_over = bool(d.get("life_over", false))
	cheated = bool(d.get("cheated", false))
	edge = bool(d.get("edge", true))
	co_duyen_used = {}
	var cdu: Dictionary = d.get("co_duyen_used", {})
	for k in cdu.keys():
		co_duyen_used[int(k)] = int(cdu[k])
	epitaph_text = str(d.get("epitaph", ""))
	return {"ok": true, "lines": ["Loaded %s — %s, %s." % [player.name, gd.realm_label(player.realm_index, player.stage), clock_label()]]}


# --- Helpers ------------------------------------------------------------------------

func _herb_id(what: String) -> String:
	if not gd.herb(what).is_empty():
		return what
	var needle: String = WorldDB.fold(what)
	for h in gd.herbs():
		if WorldDB.fold(h.name).contains(needle) or WorldDB.fold(h.id).contains(needle):
			return h.id
	return what


## Uses a Meridian Seal key on the nearest item-sealed cluster the realm allows.
func _use_seal_key(item_id: String) -> Dictionary:
	var cid: int = pick_cluster("sealed", "item")
	if cid < 0:
		return {"ok": false, "lines": ["The seal finds nothing it can open yet."]}
	var line: String = unseal_cluster(cid, "item")
	db.remove("items", item_id)
	return {"ok": true, "lines": [line]}


## An event's unseal effect: "sealed" or "open". An open unseal is limited per realm (rule 10).
func _unseal_from_event(kind: String) -> String:
	if kind == "open":
		var key: String = str(player.realm_index)
		if int(player.open_unseals.get(key, 0)) >= int(gd.tree_config().open_unseals_per_realm[player.realm_index]):
			return ""
		var open_id: int = pick_cluster("open")
		if open_id < 0:
			return ""
		player.open_unseals[key] = int(player.open_unseals.get(key, 0)) + 1
		return unseal_cluster(open_id, "story")
	var sealed_id: int = pick_cluster("sealed", "event")
	return unseal_cluster(sealed_id, "event") if sealed_id >= 0 else ""


## Unseals a hidden cluster for the player if its gate allows (Meridian Map rule 9). An open
## cluster gets its template fill here, recorded as canonical. Returns the text line.
func unseal_cluster(cluster_id: int, source: String) -> String:
	var k: Dictionary = tree.clusters.get(cluster_id, {})
	if k.is_empty() or player.unsealed.has(cluster_id) or int(k.gate) > player.realm_index:
		return ""
	player.unsealed.append(cluster_id)
	if not player.discovered.has(cluster_id):
		player.discovered.append(cluster_id)
	if str(k.kind) == "open":
		player.fills[str(cluster_id)] = {"source": "template"}
	db.log_event(year, season, "cluster_unsealed", "%s khai mở %s." % [player.name, k.name], [player.id], [], [], {"cluster": cluster_id, "source": source})
	sync_player()
	return "A hidden cluster opens: %s (%d huyệt, %s)." % [k.name, int(k.size), k.location]


## The cluster to unseal: rule 10's choice (lowest reach, then lowest id) among clusters of
## [param kind] whose gate allows it, with [param seal] on sealed ones. -1 if none.
func pick_cluster(kind: String, seal: String = "") -> int:
	var dist: Dictionary = tree.distances(player)
	var best: int = -1
	var best_reach: int = 1 << 30
	for k in tree.clusters_of(kind):
		if player.unsealed.has(int(k.id)) or int(k.gate) > player.realm_index:
			continue
		if seal != "" and str(k.seal.type) != seal:
			continue
		var reach: int = 1 << 29
		for l in k.links:
			reach = mini(reach, int(dist.get(int(l), 1 << 29)))
		if reach < best_reach:
			best_reach = reach
			best = int(k.id)
	return best


## Technique seals (Meridian Map rule 7): after enough cultivating seasons in the main slot, a
## main method opens a technique-sealed cluster of its element. Until sealed clusters are
## authored with their own techniques, naming the cluster's element is what "lists" it.
func _check_technique_seals() -> Array:
	var lines: Array = []
	var main: Dictionary = CongPhap.main_entry(player)
	if main.is_empty() or int(main.get("seal_seasons", 0)) < int(CongPhap.tier_of(gd, main.def).seal_seasons):
		return lines
	for k in tree.clusters_of("sealed"):
		if str(k.seal.type) == "technique" and Array(main.def.names).has(k.sector) and not player.unsealed.has(int(k.id)):
			var t: String = unseal_cluster(int(k.id), "technique")
			if t != "":
				lines.append(t)
				break
	return lines


## One World Database record per root change, with old and new values (linh-can.md AC-LC-45).
func _log_root_changes(type: String, changes: Array) -> void:
	for ch in changes:
		var text: String = str(gd.world_gen().history.texts.get(type, type)).replace("{a}", player.name)
		db.log_event(year, season, type, text, [player.id], [], [], ch)


func _log(type: String, refs: Dictionary) -> String:
	var text: String = str(gd.world_gen().history.texts.get(type, type))
	var people: Array = []
	var places: Array = []
	var its: Array = []
	for key in refs.keys():
		var v: String = str(refs[key])
		var rec: Dictionary = db.lookup(v)
		text = text.replace("{%s}" % key, str(rec.get("name", v)) if not rec.is_empty() else v)
		match db.table_of(v):
			"people", "sects":
				people.append(v)
			"places":
				places.append(v)
			"items":
				its.append(v)
	return db.log_event(year, season, type, text, people, places, its, {"refs": refs})
