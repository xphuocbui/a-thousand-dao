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

const SAVE_VERSION := 3
## Save versions load_dict can read. 1 is the old stage ladder, which migrates. 2 is the
## 300-level ladder, which is refused (canh-gioi.md Edge Cases, Saves).
const SAVE_VERSIONS_READ := [1, 3]

var gd: GameData
var tree: DaoDoTree
## Set by [method load_dict] when the loaded player's tree was migrated from the generated map (rule 19).
var _player_migrated: bool = false
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
## Sects & Missions, the member's side (standing, contribution, joining, promotion, leaving).
var sect_members: SectMembers
## Power Rankings (design/gdd/power-rankings.md; ADR-0003), behind combat_rankings.json "enabled".
var ratings: RatingService
## Runs each season's rating batch on a background thread while the season is played (ADR-0003 decision 6); false
## runs it, blocking, when the season ends (tools and tests). Either way the batch completes, so results do not
## depend on how fast the season was played.
var ratings_background: bool = true
## {season, panels, panel_fights, pair_fights} of the last applied season batch (the terminal's 'rankings').
var last_rating_batch: Dictionary = {}
var _rating_batch: SeasonBatch
## A multi-season command in progress (user decision 2026-11-14): the seasons that begin and end inside it share one
## season_fight_budget, split evenly in order, so a command waits for about one season's batch however many seasons
## it passes. _bulk_left counts the command's seasons still to pass; -1 outside such a command.
var _bulk_left: int = -1
var _bulk_share: int = 0
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
## What the player knows of the map: known tiles and places, clues, finds (Travel & Map rule 14; null in an old world).
var knowledge: MapKnowledge = null
## The new game's chosen start place (a continent place id or name; "" = picked), read by _place_player.
var _start_home: String = ""
## Lines from the yearly tick (upkeep, stipend) shown with the next action's result.
var _notices: Array = []


func _init(game_data: GameData, llm_service: LlmService, dao_do_tree: DaoDoTree = null) -> void:
	gd = game_data
	llm = llm_service
	tree = dao_do_tree if dao_do_tree != null else DaoDoTree.load_map(gd)


# --- Life cycle -------------------------------------------------------------------

## Generates a new world and player. [param spec]: mode ("roll" | "custom"), name, gender,
## origin, start (an element or variant id the root holds; else the strongest, Đạo Đồ rule 3), and for custom:
## thien_phu {id: value}, purities {element: purity}, variants [ids].
func new_game(seed_v: int, spec: Dictionary) -> Dictionary:
	_finish_ratings(false)
	seed_value = seed_v
	rng.seed = seed_v
	# World Generation & History: the authored continent and its history (WorldBuilder); the old random generator
	# only when the authored data is missing
	if gd.registry.has_file(WorldBuilder.HISTORY_FILE) and gd.registry.has_file(ContinentData.DATA_FILE):
		var builder := WorldBuilder.new(gd, tree)
		db = builder.generate(rng, str(seed_v))
		year = builder.current_year
		if not builder.errors.is_empty():
			push_error("World build: %s" % "; ".join(builder.errors))
	else:
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
	_start_home = str(spec.get("home", ""))
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
	_choose_start(str(spec.get("start", "")))
	player.id = db.add("people", player.to_dict())
	_place_player()
	knowledge = MapKnowledge.start(gd, db, player) if db.has_record("world", "w_meta") else null
	if edge:
		for si in ProgressionEdges.config(gd).player.starting_items:
			if si.has("talisman"):
				var tal: Dictionary = items.talisman(str(si.talisman), int(si.qty))
				tal["owner_id"] = player.id
				db.add("items", tal)
	sync_player()
	var rated: Dictionary = {}
	if ratings_on():   # Power Rankings rule 16, while the game loads
		rated = ratings.worldgen(seed_value, player, sheet(), player.location_id)
		_start_ratings()
	var lines: Array = ["A new world: %d regions, %d places, %d sects, %d people, %d recorded events (%s năm %d)." % [
		db.count("regions"), db.count("places"), db.count("sects"), db.count("people"), db.count("events"), gd.world_gen().calendar_name, year]]
	lines.append("%s is born: %s" % [player.name, player.linh_can.describe(gd)])
	lines.append(_start_line())
	if not rated.is_empty():
		lines.append("Power Rankings: the player's panel (%d fights) and %d coarse panels (%d fights) rated at load." % [
			int(rated.player_fights), int(rated.coarse_panels), int(rated.fights)])
	return {"ok": true, "lines": lines}


## Gives the thiên mệnh perk: the one chosen in the frontend, else a random one of the offer.
func _grant_edge(perk_id: String) -> void:
	var pid: String = perk_id
	if ProgressionEdges.perk(gd, pid).is_empty():
		pid = str(ProgressionEdges.roll_perk_choices(gd, rng)[0])
	ProgressionEdges.apply_birth(player, gd, pid)


## Event context with the session facts the rules need (edge, cơ duyên left this realm).
func event_context() -> Dictionary:
	var per: int = ProgressionEdges.co_duyen_limit(gd, player.realm_index)
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
	sect_members = SectMembers.new(gd, db)
	ratings = RatingService.new(gd, db)
	ratings.sheet_fn = builds.sheet_of
	ticker.ratings = ratings
	templates = EventTemplateSource.new(gd, db, builds)
	validator = EventValidator.new(gd, db, builds)
	resolver = EventResolver.new(gd, db, builds, items)
	resolver.ratings = ratings
	resolver.rating_clock = _rating_clock   # a method, not a lambda: a lambda capturing self would cycle and leak
	narrator = Narrator.new(gd, db, llm, templates, validator)


func _place_player() -> void:
	var o: Dictionary = gd.origin(player.origin)
	var home: Dictionary = _origin_home(player.origin)
	if not home.is_empty() and bool(o.get("sect", false)):
		var seat_sect: Dictionary = db.get_record("sects", str(home.get("sect_id", "")))
		if not seat_sect.is_empty():
			player.sect_id = seat_sect.id
			player.sect_rank = str(gd.session().sect.join_rank)
			seat_sect.members.append(player.id)
			sect_members.record(str(seat_sect.id), player.id)
	elif bool(o.get("sect", false)):
		var sects: Array = db.find("sects", func(s): return s.status == "active")
		if not sects.is_empty():
			var s: Dictionary = RngUtils.pick(rng, sects)
			player.sect_id = s.id
			player.sect_rank = str(gd.session().sect.join_rank)
			s.members.append(player.id)
			sect_members.record(str(s.id), player.id)
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
## World Generation rule 12 and Travel & Map rule 14: on the continent, the origin's start place comes from the
## approved home lists (world_continent.json origin_homes: a sect seat, a cultivator market or a clan town), the
## spec's "home" (a continent place id or name) when it is one of them, else a pick by the game's stream. {} in a
## world without continent places (an old generated world).
func _origin_home(origin_id: String) -> Dictionary:
	var homes: Array = gd.file(ContinentData.DATA_FILE).get("origin_homes", {}).get(origin_id, [])
	var places: Array = []
	for cid in homes:
		var found: Array = db.find("places", func(p): return int(p.get("continent_id", -1)) == int(cid))
		if not found.is_empty():
			places.append(found[0])
	if places.is_empty():
		return {}
	var want: String = str(_start_home)
	for p in places:
		if want != "" and (str(p.continent_id) == want or str(p.name) == want):
			return p
	return RngUtils.pick(rng, places)


func _starting_element() -> String:
	return player.linh_can.strongest_in_cycle(gd)


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
	var sh := StatSheet.build(player, gd, db, tree)
	if edge:
		ProgressionEdges.add_protagonist_mods(player, gd, sh)
	return sh


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
		var density: float = float(db.get_record("places", player.location_id).get("density", 1.0))
		var gain: float = CultivationRules.rate_per_season(player, gd, db, sh, density, mode == "closed_door", db.get_record("places", player.location_id).get("qi", {})).total
		var res: Dictionary = CultivationRules.add_tu_vi(player, gd, gain)
		out.tu_vi = gain
		out.stages = res.stages
		out.points = res.tree_points
		if res.stages > 0:
			sh = sheet()
	elif mode == "travel" and player.has_capability(8):
		var density_t: float = float(db.get_record("places", player.location_id).get("density", 1.0))
		var r8: Dictionary = CultivationRules.add_tu_vi(player, gd, float(gd.capability(8).params.rate_mult) * CultivationRules.rate_per_season(player, gd, db, sh, density_t, false, db.get_record("places", player.location_id).get("qi", {})).total)
		out.tu_vi = r8.gained
		out.stages = r8.stages
		out.points = r8.tree_points
	field.grow(player, sh, 1)
	if knowledge != null:   # Formula J upkeep and Formula M rent, once a season
		out.news.append_array(MapWorks.upkeep(gd, db, player))
		out.news.append_array(_bill_residence())
		_sect_residence()
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
	_finish_ratings()   # the season that just ended: its batch completes and applies (rule 13)
	out.news = ticker.tick(rng, year, season)
	if _bulk_left > 0:
		_bulk_left -= 1
	_start_ratings()
	if player.age >= CultivationRules.lifespan(player, gd, sh).total:
		_end_life("Thọ nguyên cạn kiệt ở tuổi %d" % int(player.age))
		out.died = true
	sync_player()
	return out


func _yearly() -> void:
	if player.has_capability(3) and player.equipped.has(player.nurtured_id):
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
	if edge and CultivationRules.at_bottleneck(player, gd) and int(co_duyen_used.get(player.realm_index, 0)) < ProgressionEdges.co_duyen_limit(gd, player.realm_index):
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
	_bulk_begin(n)
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
	_bulk_end()
	lines.push_front("Tu luyện %d season(s): +%.0f tu vi%s. Now %s (%.0f / %.0f)." % [done, total,
		(", +%d stage(s), +%d Đạo Đồ points" % [stages, points]) if stages > 0 else "",
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
	_bulk_begin(seasons)
	for i in seasons:
		var r: Dictionary = _pass_season("closed_door")
		done += 1
		total += r.tu_vi
		stages += r.stages
		news.append_array(r.news)
		if r.died:
			break
	_bulk_end()
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
	if not sect.is_empty() and sect.hq_place_id == player.location_id:
		# Sects rule 25, F10, F12: contribution and standing with the sect
		var rw: Dictionary = sect_members.mission_reward(player, earned)
		lines.append("  +%d contribution (now %d), standing %+.1f (now %.0f)." % [int(rw.contribution),
			sect_members.contribution(sect.id, player.id), float(rw.standing), sect_members.standing(sect.id, player.id)])
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
	if place.has("cycle"):   # Travel & Map rule 26: a secret realm on a cycle is entered only while open
		var st: Dictionary = MapChange.realm_state(place, MapChange.abs_season(year, season), str(db.get_record("world", "w_meta").get("seed", "")))
		if not bool(st.open):
			return {"ok": false, "lines": ["The gate of %s is sealed. It opens in %d season(s)." % [place.name, int(st.next_open_in)]]}
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
			lost.erase("lost_since")
			_log("player_found_lost", {"a": player.id, "item": lost.id, "place": place.id})
			lines.append("  !!! You sense a hidden aura and unearth %s, lost here long ago. [%s]" % [items.describe(lost), lost.id])
		else:
			lines.append("  You sense something hidden here, but cannot find it (%.0f%% chance)." % (chance * 100.0))
		break
	lines.append_array(_gather_herbs(place))
	if knowledge != null and str(place.get("kind", "")) in gd.world_gen().get("continent", {}).get("settled_kinds", []):
		var heard: String = Discovery.rumour(gd, db, knowledge, rng, str(place.get("region_id", "")))
		if heard != "":
			lines.append(heard)
	var r: Dictionary = _pass_season("")
	lines.append_array(_news_lines(r.news))
	if not r.died:
		lines.append_array(_maybe_event(float(gd.event_templates().random_event_chance.explore_bonus)))
	else:
		lines.append_array(death_lines())
	return {"ok": true, "lines": lines}


## Travel to a linked place. Takes the link's seasons (faster with travel_speed_pct).
## Travels to [param dest_id] (a place id or name), any reachable place, by the quickest way (Travel & Map rules
## 9-13, Formulas D-E; user decision 2026-11-20). On the continent the trip is a tile path: roads, rivers by boat,
## sea lanes and the wilderness, or flight when [param how] is "flight" (Foundation Establishment and up); in an old
## generated world it follows the links. A trip of T seasons spends ceil(T) seasons and the rest of the last season
## cultivates at the destination; each season of the trip may draw one encounter (Formula E).
func travel(dest_id: String, how: String = "ground") -> Dictionary:
	var g: Dictionary = _guard(true)
	if not g.ok:
		return g
	var here: Dictionary = db.get_record("places", player.location_id)
	if not db.has_record("places", dest_id):
		var named: Array = db.find("places", func(p): return str(p.name) == dest_id)
		if named.is_empty():
			return {"ok": false, "lines": ["No place '%s'. Use 'map' to see roads." % dest_id]}
		dest_id = str(named[0].id)
	if dest_id == player.location_id:
		return {"ok": false, "lines": ["You are already at %s." % here.name]}
	if knowledge != null and not knowledge.knows_place(dest_id) and not _map_clue_for(dest_id):
		return {"ok": false, "lines": ["You have not heard of such a place."]}
	var f: float = Travel.speed_factor(gd, sheet().total("travel_speed_pct"))
	var dest: Dictionary = db.get_record("places", dest_id)
	var t: float = -1.0
	var hops: String = ""
	var stretches: Array = []
	var path_tiles: Array = []
	var flown: float = 0.0
	if here.has("tile") and dest.has("tile") and TravelGrid.of(gd).errors.is_empty():
		var tg: TravelGrid = TravelGrid.of(gd)
		var fly_speed: float = 0.0
		if how == "flight":
			fly_speed = tg.flight_speed(str(gd.realm(player.realm_index).id))
			if fly_speed <= 0.0:
				return {"ok": false, "lines": ["You cannot fly yet: flight opens at %s." % gd.realm(1).name]}
		var trip: Dictionary = tg.trip(Vector2i(int(here.tile[0]), int(here.tile[1])), Vector2i(int(dest.tile[0]), int(dest.tile[1])), how, f, fly_speed)
		if not trip.is_empty():
			t = float(trip.seasons)
			stretches = tg.stretches(trip)
			path_tiles = trip.tiles
			var legs: PackedStringArray = []
			for m in trip.by_mode:
				legs.append("%s %.2f" % [m, float(trip.by_mode[m])])
			hops = "%d tiles: %s" % [trip.steps.size(), ", ".join(legs)]
			if how == "flight":
				flown = float(trip.steps.size())
	if t < 0.0:
		if how == "flight":
			return {"ok": false, "lines": ["There is no flight path to %s." % dest.name]}
		var route: Dictionary = Travel.quickest(db, player.location_id, dest_id, f)
		if route.is_empty():
			return {"ok": false, "lines": ["%s cannot be reached from %s." % [dest.name, here.name]]}
		t = float(route.seasons)
		hops = "%d leg(s)" % int(route.hops)
		for pid in route.path:
			if not player.visited.has(pid):
				player.visited.append(pid)
	var split: Dictionary = Travel.split(t)
	var seasons: int = int(split.seasons)
	var news: Array = []
	var died: bool = false
	var encounter: Dictionary = {}
	_bulk_begin(seasons)
	for i in seasons:
		var r: Dictionary = _pass_season("travel")
		news.append_array(r.news)
		if r.died:
			died = true
			break
		if encounter.is_empty() and i < stretches.size() and rng.randf() < float(stretches[i].chance):
			encounter = stretches[i]
	_bulk_end()
	if died:
		return {"ok": true, "lines": ["You die on the road."] + death_lines()}
	player.location_id = dest_id
	if not player.visited.has(dest_id):
		player.visited.append(dest_id)
	for b in beasts.owned(player):
		b["location_id"] = dest_id
	var lines: Array = ["You travel %.2f season(s) (%s) and arrive at %s; %d season(s) pass." % [t, hops, dest.name, seasons]]
	if knowledge != null:
		knowledge.signposts(db, dest_id)
	if knowledge != null and not path_tiles.is_empty():
		var ds: float = CharacterRules.than_thuc(player, gd, sheet()).total
		var seen: Array = knowledge.reveal_path(db, path_tiles, MapKnowledge.sight_radius(gd, ds))
		if not seen.is_empty():
			lines.append("You see %d place(s) you did not know along the way." % seen.size())
		lines.append_array(Discovery.check_path(gd, db, knowledge, rng, player, ds, path_tiles, how == "flight", year, season))
	if flown > 0.0:
		var v_eff: float = TravelGrid.of(gd).flight_speed(str(gd.realm(player.realm_index).id)) * f
		var last_tiles: float = minf(flown, v_eff * float(split.last_share))
		var pool: float = clampf(1.0 - float(gd.file(Travel.RULES_FILE).get("flight_drain_per_season", 0.6)) * last_tiles / v_eff, 0.0, 1.0)
		lines.append("You land with %d%% of your linh lực (Formula D flight drain)." % int(round(pool * 100.0)))
	var left: float = 1.0 - float(split.last_share)
	if left > 0.0 and not CultivationRules.at_bottleneck(player, gd):
		var eta: float = float(gd.file(Travel.RULES_FILE).get("partial_season_efficiency", 1.0))
		var rate: float = CultivationRules.rate_per_season(player, gd, db, sheet(), float(dest.get("density", 1.0)), false, dest.get("qi", {})).total
		var res: Dictionary = CultivationRules.add_tu_vi(player, gd, rate * left * eta)
		lines.append("The rest of the season (%d%%) you cultivate there: +%.1f tu vi." % [int(round(left * 100.0)), float(res.gained)])
	sync_player()
	market.ensure_stock(rng, dest_id, year, player.realm_index, player.linh_can)
	lines.append_array(_news_lines(news))
	if not encounter.is_empty():
		lines.append_array(_road_encounter(encounter))
	else:
		lines.append_array(_maybe_event(0.0))
	return {"ok": true, "lines": lines}


## Formula E: an encounter on the way, set where the stretch spent most of its time; its biome sets the kind of
## place the Event Engine draws for (travel_rules.json encounter_place_type).
func _road_encounter(st: Dictionary) -> Array:
	var tg: TravelGrid = TravelGrid.of(gd)
	var legend: Dictionary = gd.file(ContinentData.DATA_FILE).get("legend", {}).get("biome_ids", {})
	var biome: String = str(legend.get(str(tg.biome_at(st.tile)), "")).to_lower().replace(" ", "_")
	var types: Dictionary = gd.file(Travel.RULES_FILE).get("encounter_place_type", {})
	var ptype: String = str(types.get(biome, types.get("default", "son")))
	var ctx: Dictionary = event_context()
	ctx.place = {"id": player.location_id, "name": "giữa đường (%s)" % biome.replace("_", " "), "type": ptype, "danger": int(st.danger),
		"region": ctx.place.get("region", ""), "biome": biome, "mode": str(st.mode)}
	var res: Dictionary = narrator.generate_event(ctx, rng, "")
	if not res.ok:
		return []
	pending_event = res.event
	pending_meta = {"source": res.source, "warnings": res.warnings, "llm_error": res.llm_error, "on_the_road": st}
	return ["", "*** ON THE ROAD (%s, danger %d): %s ***  (type 'event' to read, 'choose <n>' to act)" % [str(st.mode), int(st.danger), pending_event.title]]


## Travel & Map rule 18 and Trade Goods Formula K: gathering at a wild herb ground while exploring it. Returns lines.
func _gather_herbs(place: Dictionary) -> Array:
	var grounds: Array = place.get("herb_grounds", [])
	var hg: Dictionary = gd.file(MapProduction.DATA_FILE).get("herb_ground", {})
	if grounds.is_empty() or rng.randf() >= float(hg.get("gather_chance", 0.6)):
		return []
	var total: float = 0.0
	for g in grounds:
		total += float(g.fit)
	var x: float = rng.randf() * total
	var pick: Dictionary = grounds[-1]
	for g in grounds:
		x -= float(g.fit)
		if x <= 0.0:
			pick = g
			break
	var herb: Dictionary = gd.herb(str(pick.herb))
	var q: float = minf(float(hg.get("q_max", 0.5)), float(hg.get("q_base", 0.15)) * float(place.get("density", 1.0)) * (1.0 - float(hg.get("access_default", 0.5))))
	var units: int = rng.randi_range(int(hg.get("units_min", 1)), int(hg.get("units_max", 2)))
	var out: Array = []
	for u in units:
		var j: int = 0
		var key: String = "%s:herb:%s:%d:%s:%d" % [str(seed_value), str(place.id), year * 4 + season, str(pick.herb), u]
		while j < 8 and float(RngUtils.stable_hash("%s:%d" % [key, j]) % 100000) / 100000.0 < q:
			j += 1
		var age: float = float(herb.get("mature_years", 1)) * pow(2.0, float(j))
		var item: Dictionary = items.herb(str(pick.herb), age)
		item["owner_id"] = player.id
		db.add("items", item)
		out.append("  You gather %s (%.0f năm) from the wild herb ground here." % [herb.get("name", pick.herb), age])
	return out


## Searches the current region for a season with the clues held for it (Travel & Map rule 17, Formula F). The
## season is spent off-road, so it may draw an encounter at the region's danger (Formula E, mode "search").
func search() -> Dictionary:
	var g: Dictionary = _guard(true)
	if not g.ok:
		return g
	if knowledge == null:
		return {"ok": false, "lines": ["There is nothing hidden to search for in this world."]}
	var place: Dictionary = db.get_record("places", player.location_id)
	var region_id: String = str(place.get("region_id", ""))
	var ds: float = CharacterRules.than_thuc(player, gd, sheet()).total
	var f: float = Travel.speed_factor(gd, sheet().total("travel_speed_pct"))
	var res: Dictionary = Discovery.search(gd, db, knowledge, rng, player, ds, f, region_id, year, season)
	var lines: Array = ["You spend a season searching the wilds of %s." % db.get_record("regions", region_id).get("name", "")]
	lines.append_array(res.lines)
	var r: Dictionary = _pass_season("")
	lines.append_array(_news_lines(r.news))
	if r.died:
		return {"ok": true, "lines": lines + death_lines()}
	var hz: Array = gd.file(Travel.RULES_FILE).get("hazard_per_season", [0.15, 0.35, 0.7, 1.2])
	var danger: int = clampi(int(place.get("danger", 1)) + 1, 1, hz.size())
	var chance: float = 1.0 - exp(-float(hz[danger - 1]) * float(gd.file(Travel.RULES_FILE).get("mode_factor", {}).get("search", 1.0)))
	if rng.randf() < chance:
		lines.append_array(_road_encounter({"tile": place.get("tile", [0, 0]), "mode": "search", "danger": danger}))
	return {"ok": true, "lines": lines}


## The clues the player holds, as lines (never the truth: a false clue looks like a true one).
func clue_lines() -> Array:
	if knowledge == null or knowledge.clues.is_empty():
		return ["You hold no clues to hidden places. Explore settlements to hear rumours."]
	var out: Array = []
	for c in knowledge.clues:
		var roll: Dictionary = Discovery.ledger(db).get(str(c.slot), {})
		var done: String = " (found)" if knowledge.found.has(str(c.slot)) else ""
		out.append("  %-9s %s in %s, quality %.2f%s" % [str(c.kind), Discovery._kind_words(str(roll.get("kind", ""))), db.get_record("regions", str(c.region)).get("name", "?"), float(c.quality), done])
	return out


## Whether the player holds an exact map to the hidden place [param place_id] (it may then be travelled to).
func _map_clue_for(place_id: String) -> bool:
	if knowledge == null:
		return false
	var slot: String = str(db.get_record("places", place_id).get("slot", ""))
	return slot != "" and knowledge.clues.any(func(c): return str(c.slot) == slot and str(c.kind) == "map")


## Travel & Map rule 11 and Formula K: a jump between two teleport-array cities. The fee grows with the straight-line
## distance d in tiles: round(linh_thach_max[realm] * min(fee_base_frac + fee_per_tile_frac * d, fee_frac_max) *
## owner_mult); the jump takes jump_seasons, and the rest of the season cultivates at the destination. {} fee when
## either end has no array.
func teleport_fee(dest_id: String) -> Dictionary:
	var here: Dictionary = db.get_record("places", player.location_id)
	var dest: Dictionary = db.get_record("places", dest_id)
	if not bool(here.get("array", false)) or not bool(dest.get("array", false)) or dest_id == player.location_id:
		return {}
	var tp: Dictionary = gd.file(Travel.RULES_FILE).get("teleport", {})
	var d: int = maxi(absi(int(here.tile[0]) - int(dest.tile[0])), absi(int(here.tile[1]) - int(dest.tile[1])))
	var frac: float = minf(float(tp.get("fee_base_frac", 0.05)) + float(tp.get("fee_per_tile_frac", 0.0005)) * float(d), float(tp.get("fee_frac_max", 0.3)))
	var lt_max: float = float(gd.realm_budget(player.realm_index).get("linh_thach_max", 0))
	return {"fee": int(round(lt_max * frac * float(tp.get("owner_mult", 1.0)))), "tiles": d, "seasons": float(tp.get("jump_seasons", 0.05))}


## Jumps through the teleport array here to the one at [param dest_id] (a place id or name).
func teleport(dest_id: String) -> Dictionary:
	var g: Dictionary = _guard(true)
	if not g.ok:
		return g
	if not db.has_record("places", dest_id):
		var named: Array = db.find("places", func(p): return str(p.name) == dest_id)
		dest_id = str(named[0].id) if not named.is_empty() else dest_id
	var fee: Dictionary = teleport_fee(dest_id)
	if fee.is_empty():
		return {"ok": false, "lines": ["A jump needs a teleport array here and at the destination (the great cities that hold one: 'arrays')."]}
	if player.linh_thach < int(fee.fee):
		return {"ok": false, "lines": ["The array keepers ask %d linh thạch; you have %d." % [int(fee.fee), player.linh_thach]]}
	player.linh_thach -= int(fee.fee)
	var dest: Dictionary = db.get_record("places", dest_id)
	var r: Dictionary = _pass_season("travel")
	if r.died:
		return {"ok": true, "lines": ["You die before the array takes you."] + death_lines()}
	player.location_id = dest_id
	if not player.visited.has(dest_id):
		player.visited.append(dest_id)
	if knowledge != null:
		knowledge.places[dest_id] = true
	var lines: Array = ["The array flares: %d tiles in %.2f of a season, for %d linh thạch. You arrive at %s." % [int(fee.tiles), float(fee.seasons), int(fee.fee), dest.name]]
	var left: float = 1.0 - float(fee.seasons)
	if not CultivationRules.at_bottleneck(player, gd):
		var rate: float = CultivationRules.rate_per_season(player, gd, db, sheet(), float(dest.get("density", 1.0)), false, dest.get("qi", {})).total
		var res: Dictionary = CultivationRules.add_tu_vi(player, gd, rate * left * float(gd.file(Travel.RULES_FILE).get("partial_season_efficiency", 1.0)))
		lines.append("The rest of the season you cultivate there: +%.1f tu vi." % float(res.gained))
	sync_player()
	lines.append_array(_news_lines(r.news))
	return {"ok": true, "lines": lines}


## The teleport-array cities and the fee from here to each, as lines.
func array_lines() -> Array:
	var out: Array = []
	for p in db.find("places", func(x): return bool(x.get("array", false))):
		var fee: Dictionary = teleport_fee(str(p.id))
		var here_array: bool = bool(db.get_record("places", player.location_id).get("array", false))
		var note: String = "(you are here)" if str(p.id) == player.location_id else ("%d LT, %d tiles" % [int(fee.fee), int(fee.tiles)] if not fee.is_empty() else ("" if here_array else "(go to an array city to jump)"))
		out.append("  %-5s %-22s %s" % [p.id, p.name, note])
	return out if not out.is_empty() else ["No teleport arrays in this world."]


## Builds or raises a work on the land here (Travel & Map rules 31-32, Formula J): a shared work at a place the
## player holds, a home work at home. Permanent works take their level's seasons; upkept ones one season.
func build_work(work_id: String, element: String = "") -> Dictionary:
	var g: Dictionary = _guard(true)
	if not g.ok:
		return g
	var place: Dictionary = db.get_record("places", player.location_id)
	var r: Dictionary = MapWorks.build(gd, db, player, place, work_id, element)
	if not r.ok:
		return r
	var lines: Array = r.lines
	for i in int(r.seasons):
		var t: Dictionary = _pass_season("")
		lines.append_array(_news_lines(t.news))
		if t.died:
			return {"ok": true, "lines": lines + death_lines()}
	return {"ok": true, "lines": lines}


## The works here and what each would cost next, as lines.
func work_lines() -> Array:
	var place: Dictionary = db.get_record("places", player.location_id)
	var qi: Dictionary = place.get("qi", {})
	if qi.is_empty():
		return ["This ground has no land qi to work."]
	var out: Array = ["Works at %s (layer 2 shared%s; layer 1 at your home):" % [place.name, ", you hold it" if MapWorks.holds(db, player, place) else ", held by others"]]
	if float(qi.get("prebuilt", 0.0)) > 0.0:
		out.append("  the ground's own works: density +%.2f (kept up by its holder)" % float(qi.prebuilt))
	var mine: Dictionary = qi.get("layer1", {}).get(player.id, {})
	for id in MapWorks.cfg(gd).works:
		var w: Dictionary = MapWorks.work(gd, str(id))
		var store: Dictionary = qi.get("layer2", {}) if int(w.layer) == 2 else mine
		var lv: int = int(store.get(id, {}).get("level", 0))
		var next: String = "max" if lv >= int(w.max) else "next %d LT, %d materials, %d season(s)" % [int(MapWorks.cost(gd, str(id), lv + 1).lt), int(MapWorks.cost(gd, str(id), lv + 1).materials), int(MapWorks.cost(gd, str(id), lv + 1).seasons)]
		out.append("  %-15s layer %d %-9s %-10s level %d/%d  (%s)" % [id, int(w.layer), str(w.kind), str(w.stat), lv, int(w.max), next])
	return out


## Opens a cave abode on the wilderness tile ([param x], [param y]) (Travel & Map rule 8, Formulas M): travels there,
## pays round(linh_thach_max x abode_cost_frac) and a season, and the abode becomes the player's home, a new place
## with the tile part's terrain and qi ([param part] 0-2; -1 picks the part with the best density x land match).
func open_abode(x: int, y: int, part: int = -1) -> Dictionary:
	var g: Dictionary = _guard(true)
	if not g.ok:
		return g
	var tg: TravelGrid = TravelGrid.of(gd)
	var here: Dictionary = db.get_record("places", player.location_id)
	if knowledge == null or not here.has("tile") or not tg.errors.is_empty():
		return {"ok": false, "lines": ["Cave abodes can be opened on the continent's wilderness only."]}
	var t := Vector2i(x, y)
	if not tg.passable(t) or db.find("places", func(p): return p.has("tile") and int(p.tile[0]) == x and int(p.tile[1]) == y).size() > 0:
		return {"ok": false, "lines": ["Tile %d,%d is not open wilderness (water, or a place stands there)." % [x, y]]}
	var grid := ContinentGrid.from_continent(gd)
	var best: int = -1
	var best_v: float = -1.0
	for k in 3:
		var q: Dictionary = grid.part_qi(x, y, k)
		if q.is_empty() or int(grid.value("BIO%d" % (k + 1), x, y)) in [ContinentGrid.SEA_ID, ContinentGrid.LAKE_ID]:
			continue
		var v: float = float(q.density) * LandQi.land_match(player, gd, q).total
		if (part < 0 and v > best_v) or k == part:
			best = k
			best_v = v
	if best < 0:
		return {"ok": false, "lines": ["Tile %d,%d has no land to dig into (sea or lake)." % [x, y]]}
	var q: Dictionary = grid.part_qi(x, y, best)
	if q.is_empty():
		return {"ok": false, "lines": ["That tile has no land to dig into."]}
	var cost: int = int(round(float(gd.realm_budget(player.realm_index).get("linh_thach_max", 0)) * float(MapWorks.cfg(gd).get("abode_cost_frac", 0.05))))
	var trip: Dictionary = tg.trip(Vector2i(int(here.tile[0]), int(here.tile[1])), t, "ground", Travel.speed_factor(gd, sheet().total("travel_speed_pct")))
	if trip.is_empty():
		return {"ok": false, "lines": ["You cannot reach tile %d,%d on foot." % [x, y]]}
	if player.linh_thach < cost:
		return {"ok": false, "lines": ["Opening a cave abode costs %d linh thạch; you have %d." % [cost, player.linh_thach]]}
	var seasons: int = int(Travel.split(float(trip.seasons)).seasons) + 1
	var lines: Array = ["You walk %.2f season(s) to tile %d,%d and open a cave abode there (%d linh thạch, a season's work)." % [float(trip.seasons), x, y, cost]]
	_bulk_begin(seasons)
	for i in seasons:
		var r: Dictionary = _pass_season("travel" if i < seasons - 1 else "")
		lines.append_array(_news_lines(r.news))
		if r.died:
			_bulk_end()
			return {"ok": true, "lines": lines + death_lines()}
	_bulk_end()
	player.linh_thach -= cost
	var region_cid: int = grid.region(x, y)
	var region: Array = db.find("regions", func(r): return int(r.get("continent_id", -1)) == region_cid)
	var rec := {"name": "Động phủ của %s" % player.name, "type": "dong_phu", "kind": "abode", "region_id": str(region[0].id) if not region.is_empty() else "",
		"density": float(q.density), "danger": int(q.danger), "market": false, "bounties": false, "links": [], "sect_id": "",
		"tile": [x, y], "qi": {"shares": q.shares, "variants": q.variants, "land_density": float(q.density), "part": best},
		"owner_id": player.id, "opened_year": year}
	WorldBuilder._climate(rec, grid)
	var pid: String = db.add("places", rec)
	if not region.is_empty():
		region[0].places.append(pid)
	knowledge.places[pid] = true
	knowledge.reveal_path(db, trip.tiles, MapKnowledge.sight_radius(gd, CharacterRules.than_thuc(player, gd, sheet()).total))
	player.location_id = pid
	player.home_id = pid
	db.log_event(year, season, "abode_opened", "%s mở động phủ tại %s." % [player.name, rec.region_id], [player.id], [pid], [], {"tile": [x, y]})
	sync_player()
	lines.append("Your new home: density %.2f, danger %d, land match x%.3f." % [float(q.density), int(q.danger), LandQi.land_match(player, gd, rec.qi).total])
	return {"ok": true, "lines": lines}


## Rents or buys a residence of [param grade] here (Travel & Map rule 34, Formula M): settled ground only, the grade
## within the place's max_grade and the realm minimum. A sect member lives at their seat by realm for free.
func take_residence(grade: int, buy: bool = false) -> Dictionary:
	var g: Dictionary = _guard(false)
	if not g.ok:
		return g
	var place: Dictionary = db.get_record("places", player.location_id)
	var cfg: Dictionary = MapWorks.cfg(gd)
	if place.get("qi", {}).is_empty() or not MapWorks.settled(gd, place):
		return {"ok": false, "lines": ["Residences are let in settlements and sect grounds."]}
	if player.sect_id != "" and str(place.get("sect_id", "")) == player.sect_id:
		return {"ok": false, "lines": ["Your sect houses you here by your realm; there is nothing to rent."]}
	var max_g: int = int(cfg.max_grade.get(str(place.kind), 1))
	if grade < 1 or grade > max_g:
		return {"ok": false, "lines": ["%s has residences of grade 1 to %d." % [place.name, max_g]]}
	if player.realm_index < int(cfg.grade_realm_min.get(str(grade), 0)):
		return {"ok": false, "lines": ["Grade %d needs %s." % [grade, gd.realm(int(cfg.grade_realm_min[str(grade)])).name]]}
	var d_res: float = float(LandQi.stacked_density(gd, player, place.qi, float(place.density), 0.0).total) + float(cfg.furnish_per_grade) * grade
	var rent: int = MapWorks.rent(gd, player.realm_index, d_res)
	var price: int = rent * int(cfg.buy_seasons)
	if buy and player.linh_thach < price:
		return {"ok": false, "lines": ["A grade %d residence here sells for %d linh thạch; you have %d." % [grade, price, player.linh_thach]]}
	if buy:
		player.linh_thach -= price
	if not place.qi.has("residences"):
		place.qi["residences"] = {}
	place.qi.residences[player.id] = {"grade": grade, "own": buy, "rent": rent}
	player.home_id = str(place.id)
	sync_player()
	return {"ok": true, "lines": ["You %s a grade %d residence at %s%s; it is your home now." % ["buy" if buy else "rent", grade, place.name, (" for %d linh thạch" % price) if buy else (" for %d linh thạch a season" % rent)]]}


## Rule 33: a sect member lives at their seat in a residence of grade min(realm + 1, the seat's max grade), allocated
## by the sect, free (Sects #26 owns the allocation by rank).
func _sect_residence() -> void:
	if player.sect_id == "":
		return
	var sect: Dictionary = db.get_record("sects", player.sect_id)
	var seat: Dictionary = db.get_record("places", str(sect.get("hq_place_id", "")))
	if seat.get("qi", {}).is_empty():
		return
	var grade: int = mini(player.realm_index + 1, int(MapWorks.cfg(gd).max_grade.get(str(seat.get("kind", "")), 5)))
	if not seat.qi.has("residences"):
		seat.qi["residences"] = {}
	var cur: Dictionary = seat.qi.residences.get(player.id, {})
	if cur.is_empty() or (bool(cur.get("sect", false)) and int(cur.grade) != grade):
		seat.qi.residences[player.id] = {"grade": grade, "own": true, "rent": 0, "sect": true}


## Formula M: bills the season's rent of a rented residence; one unpaid season ends the lease.
func _bill_residence() -> Array:
	for p in db.all("places"):
		var res: Dictionary = p.get("qi", {}).get("residences", {}).get(player.id, {})
		if res.is_empty() or bool(res.get("own", false)):
			continue
		if player.linh_thach >= int(res.rent):
			player.linh_thach -= int(res.rent)
			return []
		p.qi.residences.erase(player.id)
		return ["  You could not pay the rent at %s; the residence is let to someone else." % p.name]
	return []


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


## Eats a pill or uses a treasure. [param element] is the player's pick for a Linh Căn Quả;
## without a valid one the fruit is kept and the answer lists the choices.
func use_item(item_id: String, element: String = "") -> Dictionary:
	var g: Dictionary = _guard(false)
	if not g.ok:
		return g
	if db.get_record("items", item_id).get("kind", "") == "treasure":
		var t: Dictionary = TreasureEffects.use(player, gd, db, rng, item_id, element)
		if t.has("unseal_item"):
			return {"ok": false, "lines": ["The seal finds nothing to open: the Đạo Đồ has no hidden clusters (rule 6, retired)."]}
		if t.get("needs_element", false):
			return {"ok": false, "needs_element": true, "options": t.options, "lines": TreasureEffects.preview_lines(player, gd, t.options, item_id)}
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
			lines.append("  Stage up! Now %s (+%d Đạo Đồ points)." % [gd.realm_label(player.realm_index, player.stage), res.tree_points])
		if res.bottleneck:
			lines.append("  Bình cảnh reached.")
	sync_player()
	return {"ok": r.ok, "lines": lines}


## Equips a pháp bảo in [param slot] ("weapon", "armour", "ring", "necklace" or "extra"); with none, the first
## fitting free base slot, then an extra slot (item-database.md rule 11).
func equip(item_id: String, slot: String = "") -> Dictionary:
	var g: Dictionary = _guard(false)
	if not g.ok:
		return g
	var item: Dictionary = db.get_record("items", item_id)
	if item.is_empty() or item.owner_id != player.id or item.kind != "artifact":
		return {"ok": false, "lines": ["You own no pháp bảo %s." % item_id]}
	if player.equipped.has(item_id):
		return {"ok": false, "lines": ["Already equipped."]}
	var to: String = EquipSlots.slot_for(player, gd, db, sheet(), item, slot)
	if to == "":
		if slot != "":
			return {"ok": false, "lines": ["%s cannot go in the %s slot, or it is full." % [item.name, slot]]}
		return {"ok": false, "lines": ["No free slot fits %s." % item.name]}
	player.equipped.append(item_id)
	player.equip_slots[item_id] = to
	sync_player()
	var p: Dictionary = CombatPower.compute(player, gd, db, sheet())
	var where: String = "an extra slot" if to == EquipSlots.EXTRA else "the %s slot" % to
	var lines: Array = ["Equipped %s in %s. Chiến lực now %.0f." % [item.name, where, p.total]]
	if p.overflow.has(item_id):
		lines.append("  Warning: it is past your extra slots (%d); it adds nothing until a slot frees up (thần thức %.0f opens the next)." % [p.extra_limit, EquipSlots.next_slot_than_thuc(player, gd, sheet())])
	return {"ok": true, "lines": lines}


## Chooses the equipped pháp bảo to nurture (capability #3). Choosing another restarts the growth.
func nurture(item_id: String) -> Dictionary:
	var g: Dictionary = _guard(false)
	if not g.ok:
		return g
	if not player.has_capability(3):
		return {"ok": false, "lines": ["You have not opened Dưỡng Bảo Nội Thể."]}
	if not player.equipped.has(item_id):
		return {"ok": false, "lines": ["%s is not equipped." % item_id]}
	if player.nurtured_id == item_id:
		return {"ok": false, "lines": ["Already nurtured (%d years)." % player.nurture_years]}
	var restarted: bool = player.nurtured_id != ""
	player.nurtured_id = item_id
	player.nurture_years = 0
	sync_player()
	var label: String = str(db.get_record("items", item_id).get("name", item_id))
	return {"ok": true, "lines": ["You begin nurturing %s within your body%s." % [label, "; the old growth is lost" if restarted else ""]]}


## Unequips a pháp bảo.
func unequip(item_id: String) -> Dictionary:
	var g: Dictionary = _guard(false)
	if not g.ok:
		return g
	if not player.equipped.has(item_id):
		return {"ok": false, "lines": ["%s is not equipped." % item_id]}
	player.equipped.erase(item_id)
	player.equip_slots.erase(item_id)
	if player.nurtured_id == item_id:   # capability #3: the growth restarts with the next chosen treasure
		player.nurtured_id = ""
		player.nurture_years = 0
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
## The density the player would cultivate at in [param place_id] (Formula B's stack for them there, density_bonus
## included; the place's density in an old generated world).
func place_density(place_id: String) -> float:
	var p: Dictionary = db.get_record("places", place_id)
	var bonus: float = sheet().total("density_bonus")
	if p.get("qi", {}).is_empty():
		return float(p.get("density", 1.0)) + bonus
	return float(LandQi.stacked_density(gd, player, p.qi, float(p.get("density", 1.0)), bonus).total)


func local_density(sh: StatSheet) -> float:
	var here: Dictionary = db.get_record("places", player.location_id)
	if here.get("qi", {}).is_empty():
		return float(here.get("density", 1.0)) + sh.total("density_bonus")
	return float(LandQi.stacked_density(gd, player, here.qi, float(here.get("density", 1.0)), sh.total("density_bonus")).total)


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
	if not is_pill and not CultivationRules.bare_attempt_left(player, gd):
		return {"ok": false, "lines": ["Bare attempts used up for this breakthrough."]}
	if not pill.is_empty() and not bool(cond.met) and not confirm_bare:
		var cap: int = int(gd.ladder().bare_attempt_cap)
		var bare: float = CultivationRules.breakthrough_chance(player, gd, sh, -1).total
		return {"ok": false, "needs_confirm": true, "lines": ["Condition not met: %s. This would be a bare attempt at %.3f%%, burning no pill and using 1 of the %d of %d bare attempts left." % [cond.text, 100.0 * bare, cap - player.bare_attempts, cap]]}
	var rank: int = int(pill.quality) if is_pill else -1
	var talisman: bool = is_pill and use_talisman and talisman_available()
	var chance: Breakdown = CultivationRules.breakthrough_chance(player, gd, sh, rank, talisman)
	var odds: float = chance.total
	var lines: Array = Array(chance.lines())
	var step_used: bool = player.cap_used.has("22") or player.cap_used.has("23")
	var left: float = CultivationRules.lifespan(player, gd, sh).total - player.age
	var tau: float = CultivationRules.talisman_value(gd) * CultivationRules.gate_factor(player, gd) if talisman else 0.0
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
			var retry: float = CultivationRules.q_retry(gd, q, insight, s_g, CultivationRules.gate_factor(player, gd))
			lines.append("Thiêu Thọ Phá Cảnh: %.0f years burn; an extra roll at %.1f%%." % [burn, retry * 100.0])
			res = CultivationRules.resolve_attempt(player, gd, sheet(), rng, retry, true)
			lines.append("Roll %.0f vs %.0f%%." % [res.roll * 100.0, res.chance * 100.0])
	if res.success:
		_log("player_breakthrough", {"a": player.id, "realm": next.name})
		lines.append("*** BREAKTHROUGH! You are now %s. +%d Đạo Đồ points. Lifespan rises to %.0f. ***" % [gd.realm_label(player.realm_index, player.stage), res.points, CultivationRules.lifespan(player, gd, sheet()).total])
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
		changes.append({"what": "variant", "id": id, "from": 0, "to": player.linh_can.purity(id)})
	_log_root_changes("player_variant_awakened", changes)
	return [TreasureEffects.variants_text(gd, player.linh_can, formed).strip_edges()] if not formed.is_empty() else []


## Opens a Đạo Đồ node; with [param walk_path] opens the whole shortest path.
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
		var opened: Dictionary = tree.open_node(player, int(nid), gd)
		lines.append("Opened #%d %s: %s" % [int(nid), tree.node(int(nid)).name, tree.describe_mods(int(nid), player.linh_can, gd)])
		for id in opened.road:
			lines.append("  %s purity +%s (now %s)." % [gd.element_label(str(id)), LinhCan.fmt(float(opened.road[id])), LinhCan.fmt(player.linh_can.purity(str(id)))])
		if int(opened.cap) > 0:
			lines.append("  Capability gained: %s. %s" % [gd.capability(int(opened.cap)).name, gd.capability(int(opened.cap)).desc])
	sync_player()
	return {"ok": true, "lines": lines}


## The starts the player's root may pick (Đạo Đồ rule 3), as {id, key, name, current}.
func tree_starts() -> Array:
	var out: Array = []
	var cur: int = tree.start_of_character(player)
	for sid in tree.starts_for(player.linh_can, gd):
		out.append({"id": sid, "key": str(tree.start_of[sid]), "name": str(tree.node(sid).name), "current": sid == cur})
	return out


## Changes the player's start to the start of [param key] (an element or variant id the root holds), allowed while no
## Dao mark has been opened yet: at birth, and after a migrated save (rule 19). Returns {ok, lines}.
func tree_choose_start(key: String) -> Dictionary:
	if player.tree_nodes.size() > 1:
		return {"ok": false, "lines": ["The start is fixed once a Dao mark is open."]}
	var sid: int = int(tree.starts.get(key, -1))
	if sid < 0 or not tree.starts_for(player.linh_can, gd).has(sid):
		return {"ok": false, "lines": ["Your root may start at: %s." % ", ".join(tree_starts().map(func(x): return x.key))]}
	player.tree_nodes = [sid]
	sync_player()
	return {"ok": true, "lines": ["You start at the %s (#%d)." % [str(tree.node(sid).name), sid]]}


## Sets the player's start: [param key]'s if the root holds it, else the strongest element's (rule 3).
func _choose_start(key: String) -> void:
	var sid: int = int(tree.starts.get(key, -1))
	if sid < 0 or not tree.starts_for(player.linh_can, gd).has(sid):
		sid = tree.npc_start(player.linh_can, gd)
	player.tree_nodes = [sid] if sid >= 0 else []
	player.tree_baseline = DaoDoTree.BASELINE


func _start_line() -> String:
	var sid: int = tree.start_of_character(player)
	var others: Array = tree_starts().filter(func(x): return not x.current)
	var s: String = "Đạo Đồ start: %s (#%d)." % [str(tree.node(sid).get("name", "?")), sid]
	if not others.is_empty():
		s += " Before opening a Dao mark you may move it: 'tree start <%s>'." % "|".join(others.map(func(x): return x.key))
	return s


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
	_finish_ratings(false)
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


# --- Sects: the member's side ----------------------------------------------------

## The player's sect, rank, standing and contribution, the next promotion's needs, and any other sect's standing
## with the player (Sects rules 19-22). Returns {ok, lines}.
func sect_status() -> Dictionary:
	var g: Dictionary = _guard(false)
	if not g.ok:
		return g
	var lines: Array = []
	if player.sect_id == "":
		lines.append("You are a loose cultivator (tán tu).")
		var here: Dictionary = db.get_record("sects", str(db.get_record("places", player.location_id).get("sect_id", "")))
		if not here.is_empty():
			var cj: Dictionary = sect_members.can_join(player, here)
			lines.append("  %s [%s] has its seat here: %s" % [here.name, here.id, "you may join ('join')" if cj.ok else "cannot join: " + "; ".join(cj.reasons)])
	else:
		var s: Dictionary = db.get_record("sects", player.sect_id)
		lines.append("%s [%s], %s. Standing %.0f, contribution %d." % [s.get("name", player.sect_id), player.sect_id,
			sect_members.rank_name(player.sect_rank), sect_members.standing(player.sect_id, player.id), sect_members.contribution(player.sect_id, player.id)])
		var need: Dictionary = sect_members.promotion_needs(player)
		if (need.missing as Array).is_empty():
			lines.append("  You may be promoted to %s ('promote'): %d contribution." % [sect_members.rank_name(str(need.rank)), int(need.gate.contribution)])
		else:
			lines.append("  Next rank %s: %s." % [sect_members.rank_name(str(need.rank)) if need.rank != "" else "-", "; ".join(need.missing)])
	for rec in db.all(SectMembers.TABLE):
		if str(rec.person) == player.id and str(rec.sect) != player.sect_id and float(rec.standing) != 0.0:
			lines.append("  %s: standing %.0f%s" % [db.get_record("sects", str(rec.sect)).get("name", rec.sect), float(rec.standing),
				" (hostile)" if sect_members.hostile(str(rec.sect), player.id) else ""])
	return {"ok": true, "lines": lines}


## Joins the sect whose seat is here, or [param sect_id] (Sects rule 20). No time passes. Returns {ok, lines}.
func join_sect(sect_id: String = "") -> Dictionary:
	var g: Dictionary = _guard(true)
	if not g.ok:
		return g
	var sid: String = sect_id if sect_id != "" else str(db.get_record("places", player.location_id).get("sect_id", ""))
	if sid == "":
		return {"ok": false, "lines": ["No sect has its seat here: a sect recruits at its seat ('map' marks them S)."]}
	var s: Dictionary = db.get_record("sects", sid)
	var cj: Dictionary = sect_members.can_join(player, s)
	if not cj.ok:
		return {"ok": false, "lines": ["You cannot join: %s." % "; ".join(cj.reasons)]}
	sect_members.join(player, s)
	_log("player_joined_sect", {"a": player.id, "s1": s.id})
	sync_player()
	return {"ok": true, "lines": ["You join %s as an %s." % [s.name, sect_members.rank_name(player.sect_rank)]]}


## Promotion to the next rank when its gate is met (Sects F13). No time passes. Returns {ok, lines}.
func promote() -> Dictionary:
	var g: Dictionary = _guard(true)
	if not g.ok:
		return g
	var r: Dictionary = sect_members.promote(player)
	if r.ok:
		sync_player()
	return r


## Leaves the player's sect on good terms, or deserts it ([param desert]; Sects rule 22). Returns {ok, lines}.
func leave_sect(desert: bool) -> Dictionary:
	var g: Dictionary = _guard(true)
	if not g.ok:
		return g
	var r: Dictionary = sect_members.leave(player, desert)
	if r.ok:
		sync_player()
	return r


# --- Power Rankings ---------------------------------------------------------------

## Call before the program exits or the session is dropped: waits for a season batch still running on its
## background thread (a process quitting under a running batch hangs) and drops it unapplied.
func shutdown() -> void:
	_finish_ratings(false)


## True when Power Rankings runs (combat_rankings.json "enabled").
func ratings_on() -> bool:
	return ratings != null and ratings.enabled()


## Plans this season's rating batch and, with [member ratings_background], starts it.
func _start_ratings() -> void:
	if not ratings_on() or life_over:
		return
	sync_player()
	var budget: int = _bulk_share if _bulk_left > 0 else -1   # a season that will end inside the command
	_rating_batch = ratings.plan_season(seed_value, season_index(), year, season, player, sheet(), budget)
	if ratings_background:
		_rating_batch.start()


## Starts a command that passes [param seasons] seasons back to back: the seasons that begin inside it (all but its
## first, whose batch was planned before) share one season_fight_budget. [method _bulk_end] when it returns.
func _bulk_begin(seasons: int) -> void:
	if seasons < 2 or not ratings_on():
		return
	_bulk_left = seasons
	_bulk_share = floori(float(ratings.knob("season_fight_budget")) / float(seasons - 1))


func _bulk_end() -> void:
	_bulk_left = -1
	_bulk_share = 0


## [game seed, season key] for Power Rankings' keyed event-fight seeds (EventResolver.rating_clock).
func _rating_clock() -> Array:
	return [seed_value, season_index()]


## Completes the pending batch and applies it ([param apply] false stops and drops it instead: quitting, or a life or
## world being replaced).
func _finish_ratings(apply: bool = true) -> void:
	if _rating_batch == null:
		return
	var b: SeasonBatch = _rating_batch
	_rating_batch = null
	if not apply:
		b.cancel()   # its results are dropped: a running batch stops at its next fight
		b.finish()
		return
	if ratings_background:
		b.finish()
	else:
		b.run(true)
	if apply and ratings != null:
		ratings.apply_batch(b)
		last_rating_batch = {"season": b.season, "budget": b.budget, "panels": b.panels.filter(func(p): return not p.result.is_empty()).size(),
			"queued": b.waiting, "panel_fights": b.panel_fights, "pair_fights": b.pair_fights, "pairs": b.pairs.size()}


## The player's shown power (Power Rankings rule 10): the power number when ratings run (opening it while Stale runs
## the player's panel now, once per build: Edge Cases), else chiến lực. Returns {value, text, provisional}.
func player_power() -> Dictionary:
	if not ratings_on():
		var cl: float = CombatPower.compute(player, gd, db, sheet()).total
		return {"value": cl, "text": "Chiến lực %.0f" % cl, "provisional": false}
	sync_player()
	var rec: Dictionary = ratings.refresh_person(db.get_record("people", player.id))
	if str(rec.state) == RatingService.STALE:
		ratings.run_panel(player, sheet(), seed_value, season_index())
	return power_of_person(player.id)


## A person's shown power: {value, text, provisional} (the power number when ratings run, else chiến lực).
func power_of_person(id: String) -> Dictionary:
	var p: Dictionary = db.get_record("people", id)
	if not ratings_on():
		return {"value": float(p.get("power", 0.0)), "text": "chiến lực %.0f" % float(p.get("power", 0.0)), "provisional": false}
	var rec: Dictionary = ratings.refresh_person(p)
	var n: int = ratings.ladder.power_number(float(rec.base) + float(rec.offset))
	var prov: bool = str(rec.state) == RatingService.PROVISIONAL
	return {"value": float(n), "text": "power %s%s" % [_thousands(n), "?" if prov else ""], "provisional": prov}


static func _thousands(n: int) -> String:
	var s: String = str(absi(n))
	var out: String = ""
	while s.length() > 3:
		out = "," + s.right(3) + out
		s = s.left(s.length() - 3)
	return ("-" if n < 0 else "") + s + out


# --- Save / load ------------------------------------------------------------------

## Whole session as a JSON-safe Dictionary.
func to_dict() -> Dictionary:
	sync_player()
	return {
		"version": SAVE_VERSION, "seed": seed_value, "rng_state": str(rng.state), "rng_seed": str(rng.seed),
		"year": year, "season": season, "player_id": player.id, "db": db.to_dict(),
		"pending_event": pending_event, "pending_meta": pending_meta, "life_over": life_over, "epitaph": epitaph_text, "cheated": cheated,
		"edge": edge, "co_duyen_used": co_duyen_used,
		"knowledge": knowledge.to_dict() if knowledge != null else {},
	}


## Restores a session saved by [method to_dict]. Returns {ok, lines}.
func load_dict(d: Dictionary) -> Dictionary:
	if int(d.get("version", 0)) == 2:
		return {"ok": false, "lines": ["This save uses the old 300-level ladder and cannot be loaded."]}
	if not SAVE_VERSIONS_READ.has(int(d.get("version", 0))):
		return {"ok": false, "lines": ["Save version %s is not supported." % str(d.get("version"))]}
	_finish_ratings(false)
	_player_migrated = false
	seed_value = int(d.seed)
	rng.seed = str(d.rng_seed).to_int()
	rng.state = str(d.rng_state).to_int()
	year = int(d.year)
	season = int(d.season)
	var loaded_db: WorldDB = WorldDB.from_dict(d.db)
	var meta: Dictionary = loaded_db.get_record("world", "w_meta")
	var map_now: String = str(gd.file(ContinentData.DATA_FILE).get("map_version", ""))
	if not meta.is_empty() and str(meta.get("map_version", "")) != map_now:
		# World Generation Core Rule 13: the terrain is read from the data files, so a save made on another map is refused
		return {"ok": false, "lines": ["This save was made on map version %s; this game has map version %s. It cannot be loaded." % [str(meta.get("map_version", "?")), map_now]]}
	db = loaded_db
	for rec in db.all("people"):
		if rec.has("linh_can"):
			rec["linh_can"] = LinhCan.migrate_record(rec.linh_can, gd)
		var old_ladder: bool = not rec.has("level")
		Ladder.migrate_record(rec, gd)
		CongPhap.migrate_record(rec, db, gd)
		if old_ladder:
			# The old map's ids mean nothing on the new map: the points come back unspent.
			rec["tree_nodes"] = []
			rec["tree_points"] = Ladder.points_total(gd, int(rec.level))
			rec["tree_baseline"] = ""
		migrate_tree_record(rec)
	_wire()
	_reallocate_migrated()
	player = Character.from_dict(db.get_record("people", str(d.player_id)))
	var migrated: bool = _player_migrated
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
	var kd: Dictionary = d.get("knowledge", {})
	knowledge = MapKnowledge.from_dict(kd) if not kd.is_empty() else null
	ratings.normalise_loaded()
	if not life_over:
		_start_ratings()   # the season's batch is planned again from the saved state (rule 14's pending work)
	var out: Array = ["Loaded %s — %s, %s." % [player.name, gd.realm_label(player.realm_index, player.stage), clock_label()]]
	if migrated:
		out.append("The Đạo Đồ was redrawn: your open Dao marks came back as %d unspent points. %s" % [player.tree_points, _start_line()])
	return {"ok": true, "lines": out}


## Rule 19: a people record from the generated map (no `tree_baseline`) is migrated once: every open node but the old
## root comes back as an unspent point, its hidden-cluster state is dropped, and it takes the start of its strongest
## element (the player may move it with [method tree_choose_start] before opening a Dao mark). A record on the
## current baseline is left alone. Returns true if it migrated.
func migrate_tree_record(rec: Dictionary) -> bool:
	if str(rec.get("tree_baseline", "")) == DaoDoTree.BASELINE:
		return false
	if rec.get("is_beast", false):
		rec["tree_baseline"] = DaoDoTree.BASELINE
		return false
	var opened: int = maxi(0, Array(rec.get("tree_nodes", [])).size() - 1)
	rec["tree_points"] = int(rec.get("tree_points", 0)) + opened
	for k in ["unsealed", "discovered", "fills", "tree_visibility", "open_unseals"]:
		rec.erase(k)
	# capabilities came from opened Dao marks of the old map: they go with them (the new map's notables grant them again)
	rec["capabilities"] = []
	var lc := LinhCan.from_dict(rec.get("linh_can", {}))
	var sid: int = tree.npc_start(lc, gd)
	rec["tree_nodes"] = [sid] if sid >= 0 else []
	rec["tree_baseline"] = DaoDoTree.BASELINE
	if bool(rec.get("is_player", false)):
		_player_migrated = true
	elif opened > 0 or int(rec.get("tree_points", 0)) > 0:
		rec["_tree_realloc"] = true
	return true


## After a migration (rule 19), every migrated NPC spends its refunded points on the new map by rule 5, from a stream
## keyed on the game seed and its id (ADR-0002), so a reload gives the same trees. The player chooses for itself.
func _reallocate_migrated() -> void:
	for rec in db.all("people"):
		if not rec.get("_tree_realloc", false):
			continue
		rec.erase("_tree_realloc")
		var c := Character.from_dict(rec)
		var r := RandomNumberGenerator.new()
		r.seed = RngUtils.stable_hash("tree_migrate:%d:%s" % [seed_value, str(rec.get("id", ""))])
		var focus: Array = gd.archetype(c.archetype).get("tree_focus", []).duplicate()
		if focus.is_empty():
			focus = [c.linh_can.strongest_element()]
		builds.allocate(c, r, focus)
		for k in ["tree_nodes", "tree_points", "capabilities", "linh_can"]:
			rec[k] = c.to_dict()[k]
		db.put("people", rec)


# --- Helpers ------------------------------------------------------------------------

func _herb_id(what: String) -> String:
	if not gd.herb(what).is_empty():
		return what
	var needle: String = WorldDB.fold(what)
	for h in gd.herbs():
		if WorldDB.fold(h.name).contains(needle) or WorldDB.fold(h.id).contains(needle):
			return h.id
	return what


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
