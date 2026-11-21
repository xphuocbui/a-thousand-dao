extends SceneTree
## Balance probe: plays whole lives through the [GameSession] API with a competent policy
## driven by [Advisor] (the same goals the player sees) and prints when each realm was
## reached. It reports observations for tuning; it is not a test and judges nothing.
##
##   Godot_console.exe --headless --path . -s res://tools/balance/autoplay.gd -- \
##       [--seeds 101,202,303] [--origins tan_tu,gia_toc,tong_mon] [--elements 0|1..5]
##       [--edge on|off] [--ratings on|off] [--verbose]
##
## --ratings off (default) turns Power Rankings off: its season fights feed no breakthrough odds.
##
## --edge off plays baseline lives (no thiên mệnh, no starting items, no cơ duyên) to tune
## the 3-in-10 baseline; --edge on (default) plays the main character with a random perk.
##
## --elements N plays Tự Định characters with N elements at purity 60 and all thiên phú 50,
## isolating the linh căn curve; 0 (default) rolls characters like Thiên Định.
##
## Policy, in order each turn: answer events by best odds · break through when a pill is in
## hand (or thọ nguyên is nearly gone) · spend Đạo Đồ points · follow the Advisor's
## ingredient plan (plant, harvest, transplant) · buy missing rare herbs or the pill at the
## nearest markets · craft the breakthrough pill, else train Đan Đạo · spend spare linh
## thạch on trận pháp and luyện khí (keeping the plan's reserve and five years of upkeep)
## · take missions when poor · explore now and then · otherwise cultivate one season.

const TREE_WEIGHTS := {
	"cultivation_speed_pct": 3.0, "cultivation_speed_per_element_pct": 3.0, "breakthrough_chance": 3.0,
	"alchemy_success": 2.0, "herb_growth_pct": 2.0, "lifespan_years": 0.5, "lifespan_pct": 2.0,
	"field_plots": 0.0, "pill_effect_pct": 1.0, "dan_doc_resist_pct": 0.5, "tam_ma_resist_pct": 0.5,
}
const MAX_TURNS := 14000
## Brews the plant plan keeps planted ahead.
const cfg_recipes := 4

var gd: GameData
var tree: DaoDoTree
var verbose: bool = false
var edge_on: bool = true
## Birth perk for --edge on lives; "" takes a random one.
var perk_id: String = ""


func _init() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	var seeds: Array = _list_arg(args, "--seeds", "101,202,303,404,505,606").map(func(x): return int(x))
	var origins: Array = _list_arg(args, "--origins", "tan_tu,gia_toc,tong_mon")
	var elements: int = int(_list_arg(args, "--elements", "0")[0])
	edge_on = str(_list_arg(args, "--edge", "on")[0]) != "off"
	verbose = args.has("--verbose")
	perk_id = str(_list_arg(args, "--perk", "any")[0]).replace("any", "")
	gd = GameData.load_from("res://assets/data")
	# Power Rankings' season fights feed no breakthrough odds and cost minutes a life: off unless asked for
	if str(_list_arg(args, "--ratings", "off")[0]) != "on":
		gd.file("combat_rankings")["enabled"] = false
	# A life's odds do not depend on how many strangers exist, so lives run in a small world.
	var world: int = int(_list_arg(args, "--world", "300")[0])
	gd.world_gen().people.world_cultivators = world
	gd.world_gen().people.world_cultivators_min = world
	tree = DaoDoTree.load_map(gd)
	var rows: Array = []
	var started: int = Time.get_ticks_msec()
	for seed_v in seeds:
		for origin in origins:
			rows.append(_life(int(seed_v), str(origin), elements))
			print(_row_text(rows[-1]))
	print("")
	_summary(rows, origins)
	print("(%d lives in %.0f s)" % [rows.size(), (Time.get_ticks_msec() - started) / 1000.0])
	quit()


# --- One life ---------------------------------------------------------------------------

func _life(seed_v: int, origin: String, elements: int) -> Dictionary:
	var llm := LlmService.new(gd)
	llm.enabled = false
	var s := GameSession.new(gd, llm, tree)
	var spec := {"mode": "roll", "name": "Auto", "gender": "male", "origin": origin, "edge": edge_on, "perk": perk_id}
	if elements > 0:
		var rng := RandomNumberGenerator.new()
		rng.seed = seed_v
		var tp: Dictionary = {}
		for def in gd.thien_phu_defs():
			tp[def.id] = 50
		var purities: Dictionary = {}
		for e in gd.element_cycle().slice(0, elements):
			purities[e] = 60
		spec["character"] = CharacterFactory.custom_player(gd, rng, "Auto", "male", origin, tp, purities, []).to_dict()
	s.new_game(seed_v, spec)
	var st := {"seed": seed_v, "origin": origin, "root": s.player.linh_can.describe(gd), "elements": s.player.linh_can.n_eff(gd),
		"reached": {}, "arrived": {}, "tech_price": 0, "events": 0, "bt_attempts": 0, "crafts": 0, "trips": 0, "max_lt": 0, "target": "", "next_trip_year": 0,
		"pill_sources": [], "builds": 0, "refines": 0, "turn": 0, "use": {}, "odds": {}, "first_lines": {}}
	for turn in MAX_TURNS:
		# Nothing after the last gate changes the gate odds, so the life stops there.
		if s.life_over or s.player.realm_index >= gd.realms().size() - 1:
			break
		_step(s, st)
		if verbose and turn % 80 == 0:
			var pl: Dictionary = _plan(s)
			print("    năm %d tuổi %.0f %s LT %d Đan Đạo %d at %s | %s" % [s.year, s.player.age, gd.realm_label(s.player.realm_index, s.player.stage), s.player.linh_thach,
				s.player.skill_level(Alchemy.SKILL), s.player.location_id, "; ".join(pl.get("statuses", []).map(func(x): return x.text))])
		st.max_lt = maxi(st.max_lt, s.player.linh_thach)
	var c: Character = s.player
	st["death_age"] = c.age
	st["level"] = c.level
	st["final"] = gd.realm_label(c.realm_index, c.stage)
	st["final_realm"] = c.realm_index
	st["lt"] = c.linh_thach
	st["dan_dao"] = c.skill_level(Alchemy.SKILL)
	st["cause"] = c.death_cause
	return st


func _step(s: GameSession, st: Dictionary) -> void:
	var c: Character = s.player
	if s.has_pending_event():
		st.events += 1
		s.choose(_best_choice(s))
		return
	if _breakthrough_if_ready(s, st):
		return
	_spend_points(s)
	if _maybe_technique(s, st):
		return
	st.turn += 1
	if st.turn % 8 == 0:
		_equip_idle(s)
	if st.target != "":
		_travel_step(s, st)
		return
	var plan: Dictionary = _plan(s)
	if _gather(s, st, plan):
		return
	if c.location_id == c.home_id:
		if _tend_field(s, plan):
			return
	elif not _at_market_shop(s, st, plan) and not (st.get("working", false) and Advisor.can_work_here(s)):
		st.target = c.home_id
		return
	if _maybe_shop(s, st, plan):
		return
	if _craft(s, st, plan):
		return
	_use_pills(s)
	if _invest(s, st, plan):
		return
	if c.linh_thach < maxi(_money_needed(s, plan), int(st.get("tech_price", 0))):
		if Advisor.can_work_here(s):
			st.use["mission"] = int(st.use.get("mission", 0)) + 1
			s.mission()
			return
		var work: String = Advisor.nearest_work_place(s)
		if work != "" and c.location_id == c.home_id:
			st.target = work
			st["working"] = true
			return
	elif st.get("working", false) and c.location_id != c.home_id:
		st.working = false
		st.target = c.home_id
		return
	if st.turn % 12 == 0 and int(s.db.get_record("places", c.location_id).get("danger", 9)) <= 2:
		st.use["explore"] = int(st.use.get("explore", 0)) + 1
		s.explore()
		return
	st.use["cultivate"] = int(st.use.get("cultivate", 0)) + 1
	s.cultivate(1)


## Travel & Map rule 18 in play: an ingredient the plan says to gather at a wild herb ground: travel there and explore
## until it is in hand (a few seasons at most per visit). Returns true when it spent the turn.
func _gather(s: GameSession, st: Dictionary, plan: Dictionary) -> bool:
	for stt in plan.get("statuses", []):
		if not stt.has("gather_at") or bool(stt.get("ready", false)):
			continue
		if s.player.location_id != str(stt.gather_at):
			st.target = str(stt.gather_at)
			return false
		st.use["gather"] = int(st.use.get("gather", 0)) + 1
		var r: Dictionary = s.explore()
		if not bool(r.get("ok", false)):
			# refused (a sealed realm, a waiting event): spend the season cultivating instead, so time always passes
			st.use["cultivate"] = int(st.use.get("cultivate", 0)) + 1
			s.cultivate(1)
		return true
	return false


## The next breakthrough: {recipe, tag, pill, statuses: [ingredient status], realm}.
func _plan(s: GameSession) -> Dictionary:
	var c: Character = s.player
	if c.realm_index >= gd.realms().size() - 1:
		return {}
	var tag: String = str(gd.realm(c.realm_index + 1).entry_requirement.item_tag)
	var recipe: Dictionary = Advisor.recipe_for_tag(gd, tag)
	var statuses: Array = []
	if not recipe.is_empty():
		for ing in recipe.ingredients:
			var stt: Dictionary = Advisor.ingredient_status(s, c, s.sheet(), ing)
			stt["herb"] = str(ing.herb)
			stt["min_age"] = float(ing.min_age)
			statuses.append(stt)
	return {"recipe": recipe, "tag": tag, "pill": Advisor.best_pill(s, tag), "statuses": statuses}


func _breakthrough_if_ready(s: GameSession, st: Dictionary) -> bool:
	var c: Character = s.player
	if not CultivationRules.at_bottleneck(c, gd):
		return false
	if not st.arrived.has(c.realm_index):
		st.arrived[c.realm_index] = c.age
	var tag: String = str(gd.realm(c.realm_index + 1).entry_requirement.item_tag)
	var has_pill: bool = not Advisor.best_pill(s, tag).is_empty()
	var sh: StatSheet = s.sheet()
	var left: float = CultivationRules.lifespan(c, gd, sh).total - c.age
	var met: bool = CultivationRules.breakthrough_condition(c, gd, s.local_density(sh)).met
	if has_pill and not met and left > 3.0:
		return _chase_condition(s, st)
	if (not has_pill or not met) and left > 3.0:
		return false
	if (not has_pill or not met) and not CultivationRules.bare_attempt_left(c, gd):
		return false
	st.bt_attempts += 1
	var before: int = c.realm_index
	var out: Dictionary = s.breakthrough(true)
	# every attempt's odds, and the first attempt's breakdown at each gate (2026-11-20 tuning round)
	for ln in out.get("lines", []):
		var t: String = str(ln)
		if t.begins_with("Roll "):
			if not st.odds.has(before):
				st.odds[before] = []
			st.odds[before].append(t.get_slice(" vs ", 1).trim_suffix("%.").to_float() / 100.0)
	if not st.first_lines.has(before):
		st.first_lines[before] = out.get("lines", [])
	if c.realm_index > before:
		st.reached[c.realm_index] = c.age
		st.pill_sources.append("pill" if has_pill else "no pill")
	return true


## Goes after the realm condition: a place with enough qi for Core Formation, or a place where
## enlightenment can come for the Deity Transformation insight. Heart demon is waited for.
## Returns true when it spent the turn.
func _chase_condition(s: GameSession, st: Dictionary) -> bool:
	var c: Character = s.player
	var cond: Variant = gd.realm(c.realm_index + 1).entry_requirement.get("condition")
	if cond == null or st.target != "":
		return false
	match str(cond.type):
		"density_min":
			# the stacked density the player gets there (Formula B), at a place the player knows (Travel & Map rule 14)
			st.target = _nearest_place(s, func(p): return s.place_density(str(p.id)) >= float(cond.value))
		"insight":
			var types: Array = gd.event_templates().templates.filter(func(t): return t.id == "don_ngo")[0].place_types
			if types.has(str(s.db.get_record("places", c.location_id).get("type", ""))):
				st.use["seek_insight"] = int(st.use.get("seek_insight", 0)) + 1
				s.explore()
				return true
			st.target = _nearest_place(s, func(p): return types.has(str(p.get("type", ""))))
	return false


func _nearest_place(s: GameSession, keep: Callable) -> String:
	var here: String = s.player.location_id
	if s.knowledge != null:
		# on the continent: the nearest known place that keeps, by straight-line tiles (travel finds the way)
		var at: Dictionary = s.db.get_record("places", here)
		if keep.call(at):
			return ""
		var best: String = ""
		var best_d: int = 1 << 30
		for pid in s.knowledge.places:
			var p: Dictionary = s.db.get_record("places", str(pid))
			if p.is_empty() or not p.has("tile") or str(pid) == here or not keep.call(p):
				continue
			var d: int = maxi(absi(int(p.tile[0]) - int(at.tile[0])), absi(int(p.tile[1]) - int(at.tile[1])))
			if d < best_d:
				best_d = d
				best = str(pid)
		return best
	var seen: Dictionary = {here: true}
	var queue: Array = [here]
	while not queue.is_empty():
		var cur: String = queue.pop_front()
		if keep.call(s.db.get_record("places", cur)):
			return "" if cur == here else cur
		for l in s.db.get_record("places", cur).links:
			if not seen.has(l.to):
				seen[l.to] = true
				queue.append(l.to)
	return ""


## Rule 18 in play: moves to a main method that reaches the next realm, buying the reserved
## par-tier manual when none is known. Returns true when it set a trip.
func _maybe_technique(s: GameSession, st: Dictionary) -> bool:
	var c: Character = s.player
	if st.target != "":
		return false
	var at_top: bool = CultivationRules.at_great_perfection(c, gd)
	var want: int = CongPhap.par_tier(gd, mini(c.realm_index + (1 if at_top else 0), gd.realms().size() - 1))
	var main: Dictionary = CongPhap.main_entry(c)
	if not main.is_empty() and int(main.def.tier) >= want:
		return false
	for key in c.techniques.keys():
		var e: Dictionary = c.techniques[key]
		if str(e.def.tech_kind) == "main" and int(e.def.tier) >= want and CongPhap.usable(c, e.def):
			s.set_slot("main", 0, str(key))
			return false
	var best: Dictionary = {}
	var best_p: float = -1.0
	var best_place: String = ""
	for place in s.db.all("places"):
		if not bool(place.get("market", false)):
			continue
		for it in s.market.stock(place.id):
			if it.kind != "cong_phap" or int(it.tier) < want or str(it.tech_kind) != "main":
				continue
			var p: float = c.linh_can.average_purity(it.names)
			if p > best_p:
				best_p = p
				best = it
				best_place = place.id
	if best.is_empty() or best_p <= 0.0:
		return false
	var price: int = s.market.buy_price(c, s.sheet(), best)
	st["tech_price"] = price
	if c.linh_thach < price:
		return false
	if c.location_id != best_place:
		st.target = best_place
		return true
	if s.buy(best.id).ok:
		var mine: Array = s.db.items_of(c.id).filter(func(i): return i.kind == "cong_phap" and i.get("tech_id", "") == best.tech_id)
		if not mine.is_empty():
			s.learn(mine[0].id)
			s.set_slot("main", 0, str(best.tech_id))
		st.tech_price = 0
	return false


func _spend_points(s: GameSession) -> void:
	var c: Character = s.player
	while c.tree_points > 0:
		var best: int = -1
		var best_score: float = -INF
		for nid in tree.frontier(c, gd):
			if not tree.can_allocate(c, nid, gd).ok:
				continue
			var sc: float = _node_value(nid, c) + 0.5 * tree.neighbors(nid).map(func(n): return _node_value(n, c)).max()
			if sc > best_score:
				best_score = sc
				best = nid
		if best == -1 or not s.tree_allocate(best, false).ok:
			return


func _node_value(nid: int, c: Character) -> float:
	var nd: Dictionary = tree.node(nid)
	var scale: float = tree.node_scale(nid, c.linh_can, gd)
	var v: float = 0.0
	for m in nd.get("mods", []):
		v += float(TREE_WEIGHTS.get(str(m.stat), 0.2)) * float(m.value) * scale
	return v


## Plants, harvests and transplants for the breakthrough plan; fills spare plots with
## cheap herbs for Đan Đạo training. Returns true when it did something (free actions).
func _tend_field(s: GameSession, plan: Dictionary) -> bool:
	var c: Character = s.player
	var acted: bool = false
	# Harvest mature training herbs first so plan herbs find a free plot.
	var plan_herbs: Array = plan.get("statuses", []).map(func(x): return x.herb)
	for p in s.field.planted(c).keys():
		var h: Dictionary = s.field.planted(c)[p]
		if not plan_herbs.has(h.template) and float(h.age) >= float(gd.herb(h.template).mature_years):
			acted = s.harvest(int(p)).ok or acted
	# Follow the Advisor: harvest ripe plan herbs, plant seeds or the herb held in the bag.
	for stt in _plan(s).get("statuses", []):
		var cmd: String = str(stt.command)
		if cmd.begins_with("harvest "):
			acted = s.harvest(int(cmd.get_slice(" ", 1))).ok or acted
		elif cmd.begins_with("plant ") and c.linh_thach >= int(gd.herb(stt.herb).seed_price):
			acted = s.plant(cmd.get_slice(" ", 1)).ok or acted
	# Harvest every ripe recipe herb, so its plot can take the next one in the plan.
	var ages: Dictionary = {}
	for ing in plan.get("recipe", {}).get("ingredients", []):
		ages[ing.herb] = float(ing.min_age)
	for p in s.field.planted(c).keys():
		var h2: Dictionary = s.field.planted(c)[p]
		if ages.has(h2.template) and float(h2.age) >= float(ages[h2.template]):
			acted = s.harvest(int(p)).ok or acted
	# The plant plan: free plots rotate into the next brews' herbs (Formulas D).
	var recipe: Dictionary = plan.get("recipe", {})
	while not recipe.is_empty() and s.field.free_plot(c, s.sheet()) != -1:
		var herb: String = Advisor.next_plant(s, recipe, int(cfg_recipes))
		# Training comes after the first brew is in the ground: a competent life reaches the
		# recipe's level plus one, which is what the brew odds assume.
		if Advisor.next_plant(s, recipe, 1) == "" and c.skill_level(Alchemy.SKILL) < int(recipe.min_level) + 1:
			herb = "ngung_khi_thao" if s.field.planted(c).values().filter(func(h): return h.template == "ngung_khi_thao").is_empty() else herb
		if herb == "" or c.linh_thach < int(gd.herb(herb).seed_price) or not s.plant(herb).ok:
			break
		acted = true
	return acted


func _craft(s: GameSession, st: Dictionary, plan: Dictionary) -> bool:
	var c: Character = s.player
	var recipe: Dictionary = plan.get("recipe", {})
	if not recipe.is_empty():
		if s.alchemy.find_ingredients(c, recipe).ok and c.skill_level(Alchemy.SKILL) + 1 >= int(recipe.min_level):
			st.crafts += 1
			s.craft(recipe.id)
			return true
	# Train Đan Đạo only up to one level above what the next pill needs.
	var want: int = int(recipe.get("min_level", 1)) + 1
	st.use["crafttry"] = int(st.use.get("crafttry", 0)) + 1
	if c.skill_level(Alchemy.SKILL) >= want:
		return false
	for rid in ["hoang_long_dan", "tu_khi_dan"]:
		var r: Dictionary = gd.recipe(rid)
		if c.skill_level(Alchemy.SKILL) + 1 >= int(r.min_level) and s.alchemy.find_ingredients(c, r).ok and not _reserved(plan, r):
			st.crafts += 1
			s.craft(rid)
			return true
	return false


## True when a training recipe would eat herbs the breakthrough plan needs.
func _reserved(plan: Dictionary, r: Dictionary) -> bool:
	var plan_herbs: Array = plan.get("statuses", []).map(func(x): return x.herb)
	for ing in r.ingredients:
		if plan_herbs.has(ing.herb):
			return true
	return false


## Spends spare linh thạch: formations at home (herb growth first), then refining.
func _invest(s: GameSession, st: Dictionary, plan: Dictionary) -> bool:
	var c: Character = s.player
	var reserve: int = _money_needed(s, plan) + s.formations.upkeep(c) * 5 + int(st.get("tech_price", 0))
	if c.location_id == c.home_id and _home_up(s, reserve):
		st.builds += 1
		return true
	if c.location_id == c.home_id:
		for fid in ["thanh_moc", "tu_linh", "ho_son"]:
			var ck: Dictionary = s.formations.can_build(c, fid)
			if ck.ok and c.linh_thach - int(ck.cost.lt) >= reserve + int(ck.cost.lt) / 2:
				st.builds += 1
				s.formation_build(fid)
				return true
	var base: String = "phi_kiem"
	var rk: Dictionary = s.refinery.check(c, base, c.realm_index)
	if rk.ok and c.linh_thach - int(rk.fuel) >= reserve * 2:
		st.refines += 1
		s.refine(base, c.realm_index)
		return true
	return false


## Cave Abode (rules 2, 6; Travel & Map rule 34): when the home's slots are full or its level ceiling holds an array
## back, a cave abode is raised a grade and a settled home moves up to the next residence grade the place and the
## realm allow, bought, when the stones are to spare.
func _home_up(s: GameSession, reserve: int) -> bool:
	var c: Character = s.player
	var home: Dictionary = s.db.get_record("places", c.home_id)
	var qi: Dictionary = home.get("qi", {})
	var rec: Dictionary = CaveAbode.home_rec(qi, c.id)
	if rec.is_empty() or bool(rec.get("sect", false)):
		return false
	var g: int = CaveAbode.grade_of(rec)
	var blocked: bool = CaveAbode.used(qi, c) >= CaveAbode.slots(s.gd, g)
	for fid in c.formations:
		if int(c.formations[fid]) >= CaveAbode.ceiling(s.gd, g, 99):
			blocked = true
	if not blocked or g >= 5:
		return false
	if CaveAbode.is_abode(rec):
		var cost: int = CaveAbode.grade_cost(s.gd, g + 1, c.realm_index)
		if g + 1 <= CaveAbode.top_grade(s.gd, c.realm_index) and c.linh_thach - cost >= reserve * 2:
			return bool(s.raise_abode().ok)
		return false
	if c.linh_thach < reserve * 2:
		return false
	return bool(s.take_residence(g + 1, true).ok)


## Equips owned pháp bảo while a slot is free (item-database.md rule 11).
func _equip_idle(s: GameSession) -> void:
	var c: Character = s.player
	var idle: Array = s.db.items_of(c.id).filter(func(i): return i.kind == "artifact" and not c.equipped.has(i.id))
	if idle.is_empty():
		return
	for it in idle:
		s.equip(it.id)


func _use_pills(s: GameSession) -> void:
	var c: Character = s.player
	for it in s.db.items_of(c.id):
		if it.kind != "pill":
			continue
		var fx: Dictionary = gd.recipe(it.template).effect
		var use: bool = false
		match str(fx.type):
			"tu_vi":
				use = c.dan_doc < 40.0 and not CultivationRules.at_bottleneck(c, gd)
			"dan_doc":
				use = c.dan_doc >= 50.0
			"heal_pct":
				use = c.vitality < 0.5
			"tam_ma":
				use = c.tam_ma >= 18.0
			"lifespan", "stat":
				use = true
		if use:
			s.use_item(it.id)
			return


## Starts a market trip when the plan needs a herb seeds cannot provide, or the pill.
func _maybe_shop(s: GameSession, st: Dictionary, plan: Dictionary) -> bool:
	if plan.is_empty() or s.year < int(st.next_trip_year) or not plan.pill.is_empty():
		return false
	var need: bool = false
	for stt in plan.statuses:
		if not stt.ready and stt.command == "" and not str(stt.text).contains("growing"):
			need = true
	if not need:
		return false
	var market: String = _nearest_market(s)
	if market == "":
		return false
	st.target = market
	st.trips += 1
	st.next_trip_year = s.year + 3
	return true


## At a market: buy the plan's pill or its missing rare herb. Returns true if it stays.
func _at_market_shop(s: GameSession, st: Dictionary, plan: Dictionary) -> bool:
	var place: Dictionary = s.db.get_record("places", s.player.location_id)
	if not bool(place.get("market", false)) or plan.is_empty():
		return false
	var sh: StatSheet = s.sheet()
	# Materials for formations and refining, when money is to spare.
	var bought: int = 0
	for it in s.market.stock(place.id):
		if it.kind == "material" and bought < 3 and s.market.buy_price(s.player, sh, it) * 4 <= s.player.linh_thach - _money_needed(s, plan):
			if s.buy(it.id).ok:
				bought += 1
	for it in s.market.stock(place.id):
		var price: int = s.market.buy_price(s.player, sh, it)
		if price > s.player.linh_thach:
			continue
		if it.kind == "pill" and str(gd.recipe(str(it.template)).effect.get("tag", "")) == plan.tag:
			s.buy(it.id)
			return false
		for stt in plan.statuses:
			if it.kind == "herb" and it.template == stt.herb and not stt.ready:
				s.buy(it.id)
				return false
	return false


func _travel_step(s: GameSession, st: Dictionary) -> void:
	st.use["travel"] = int(st.use.get("travel", 0)) + 1
	if s.knowledge != null:
		# on the continent a trip goes the whole way by the quickest route (Travel & Map rules 10-12)
		var r: Dictionary = s.travel(st.target)
		if not r.ok or s.player.location_id == st.target:
			st.target = ""
		return
	var hop: String = Advisor.next_hop(s, s.player.location_id, st.target)
	if hop == "":
		st.target = ""
		return
	s.travel(hop)
	if s.player.location_id == st.target:
		st.target = ""


func _nearest_market(s: GameSession) -> String:
	var seen: Dictionary = {s.player.location_id: true}
	var queue: Array = [s.player.location_id]
	while not queue.is_empty():
		var cur: String = queue.pop_front()
		if cur != s.player.location_id and bool(s.db.get_record("places", cur).get("market", false)):
			return cur
		for l in s.db.get_record("places", cur).links:
			if not seen.has(l.to):
				seen[l.to] = true
				queue.append(l.to)
	return ""


func _money_needed(s: GameSession, plan: Dictionary) -> int:
	var need: int = 20
	for stt in plan.get("statuses", []):
		if str(stt.command).begins_with("plant "):
			need = maxi(need, int(gd.herb(stt.herb).seed_price) + 5)
		elif stt.has("price") and not stt.ready:
			need = maxi(need, int(stt.price))
	return need


## Picks the choice with the best expected value: chance × success gains + (1 − chance)
## × failure outcome, minus certain costs. Walking away is worth 0, not "100% safe".
func _best_choice(s: GameSession) -> int:
	var best: int = s.pending_event.choices.size() - 1
	var best_v: float = -INF
	for i in s.pending_event.choices.size():
		var o: Dictionary = Advisor.choice_odds(s, i)
		if not o.ok:
			continue
		var ch: Dictionary = s.pending_event.choices[i]
		var p: float = 1.0 if float(o.chance) < 0.0 else float(o.chance)
		var v: float = _fx_value(s, ch.get("always", [])) + p * _fx_value(s, ch.success.effects) + (1.0 - p) * _fx_value(s, ch.get("failure", {}).get("effects", []))
		if v > best_v:
			best_v = v
			best = i
	return best


## Rough worth of effects in linh thạch (only for the bot policy).
func _fx_value(s: GameSession, effects: Array) -> float:
	var c: Character = s.player
	var v: float = 0.0
	for fx in effects:
		match str(fx.type):
			"linh_thach":
				v += float(fx.get("amount", 0))
			"tu_vi":
				v += float(fx.get("amount", 0)) * 0.5
			"herb", "material", "cong_phap":
				v += 30.0
			"artifact", "talisman":
				v += 60.0
			"pill":
				v += 50.0
			"tree_point":
				v += 80.0 * float(fx.get("amount", 1))
			"insight":
				v += 500.0 if c.realm_index == gd.realm_index("nguyen_anh") else 0.0
			"breakthrough_pill", "plan_herb", "treasure":
				v += 1000.0
			"khi_huyet_loss_pct":
				v -= float(fx.get("amount", 0)) * (4.0 if c.vitality < 0.5 else 1.0)
			"tam_ma", "dan_doc":
				v -= float(fx.get("amount", 0)) * 2.0
			"relationship":
				v += float(fx.get("amount", 0)) * 0.2
	return v


# --- Report -------------------------------------------------------------------------------

func _row_text(r: Dictionary) -> String:
	var ages: PackedStringArray = []
	for ri in [1, 2, 3]:
		ages.append("%-5s %5s" % [gd.realm(ri).name.substr(0, 5), ("%.0f" % r.reached[ri]) if r.reached.has(ri) else "—"])
	return "use %s cause %s\nseed %4d %-8s %-36s %s | died %3.0f %-22s | LT now %6d max %7d | Đan Đạo %d | ev %3d bt %d crafts %3d trips %d trận %d khí %d %s" % [
		str(r.use), str(r.cause), r.seed, r.origin, r.root.substr(0, 36), " · ".join(ages), r.death_age, r.final, r.lt, r.max_lt, r.dan_dao, r.events, r.bt_attempts, r.crafts, r.trips, r.builds, r.refines, ",".join(r.pill_sources)]


func _summary(rows: Array, origins: Array) -> void:
	print("Summary (median ages; n = lives; edge %s):" % ("on" if edge_on else "off"))
	var gates: PackedStringArray = []
	for ri in range(0, gd.realms().size() - 1):
		var arrived: int = rows.filter(func(r): return r.arrived.has(ri)).size()
		var crossed: int = rows.filter(func(r): return r.reached.has(ri + 1)).size()
		gates.append("%s→%s %d/%d = %.0f%%" % [gd.realm(ri).name, gd.realm(ri + 1).name, crossed, arrived, 100.0 * float(crossed) / maxf(float(arrived), 1.0)])
	print("  per gate (crossed / arrived at a full bar): " + " · ".join(gates))
	for ri in range(0, gd.realms().size() - 1):
		var all_odds: Array = []
		var lives: int = 0
		for r in rows:
			if r.odds.has(ri):
				all_odds.append_array(r.odds[ri])
				lives += 1
		if not all_odds.is_empty():
			var mean: float = 0.0
			for x in all_odds:
				mean += float(x)
			print("  attempts at %s: %d in %d lives, mean odds %.1f%%, max %.1f%%" % [gd.realm(ri).name, all_odds.size(), lives, 100.0 * mean / all_odds.size(), 100.0 * float(all_odds.max())])
			var ex: Array = rows.filter(func(r): return r.first_lines.has(ri))
			if not ex.is_empty():
				print("    first attempt breakdown (seed %d %s): %s" % [ex[0].seed, ex[0].origin, " | ".join(Array(ex[0].first_lines[ri]).slice(0, 14))])
	var reached: Array = [rows.size(), 0, 0, 0]
	for r in rows:
		for ri in [1, 2, 3]:
			if r.reached.has(ri):
				reached[ri] += 1
	var steps: PackedStringArray = []
	for ri in [1, 2]:
		steps.append("%s %d/%d = %.0f%%" % [gd.realm(ri).name, reached[ri], reached[ri - 1], 100.0 * float(reached[ri]) / maxf(float(reached[ri - 1]), 1.0)])
	print("  per step: " + " · ".join(steps))
	for o in origins + ["all"]:
		var sel: Array = rows.filter(func(r): return o == "all" or r.origin == o)
		var line: String = "  %-8s n %2d" % [o, sel.size()]
		for ri in [1, 2]:
			var got: Array = sel.filter(func(r): return r.reached.has(ri)).map(func(r): return float(r.reached[ri]))
			line += " | %s %2d/%d at %s" % [gd.realm(ri).name, got.size(), sel.size(), _median_text(got)]
		line += " | death %s | max LT %s" % [_median_text(sel.map(func(r): return float(r.death_age))), _median_text(sel.map(func(r): return float(r.max_lt)))]
		print(line)


func _median_text(v: Array) -> String:
	if v.is_empty():
		return "—"
	var a: Array = v.duplicate()
	a.sort()
	return "%.0f" % a[a.size() / 2]


func _list_arg(args: PackedStringArray, flag: String, default: String) -> Array:
	var i: int = args.find(flag)
	var raw: String = args[i + 1] if i != -1 and i + 1 < args.size() else default
	return Array(raw.split(",", false))
