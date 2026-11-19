extends DaoTestSuite
## The drawn Đạo Đồ on the v5 map (design/gdd/dao-do.md rules 1, 3, 4, 5, 16, 19; Formulas F, H; ADR-0004):
## AC-KMD-13, -14, -15, -16, -18, -42, -51, -59, -96, -97, -98, -99, -100, -102.

const FIRE_START := 36
const FIRE_ROAD := 42          # a Fire-land road next to the Fire start
const FIRE_MARK := 690         # a Fire-land small Dao mark next to the Fire start
const BORDER_WF := 1455        # a Dao mark in the Wood-Fire border cluster
const WIND_MARK := 796         # a Dao mark in the Wind start's figure
const FE_ROAD := 234           # a Fire-Earth border road
const HUB_ROAD := 1            # a Taiji hub Source road (gated)
const EMBER_HEART := 2843      # a Fire-ribbon notable, gated Chaos land


func _t() -> DaoDoTree:
	return TestFixtures.tree()


func _c(elements: Dictionary, variants: Dictionary = {}, realm: int = 0) -> Character:
	var c := TestFixtures.character(elements, 50, realm)
	c.linh_can.variants = variants.duplicate()
	c.linh_can.recompute_derived(game_data())
	var start: int = _t().npc_start(c.linh_can, game_data())
	c.tree_nodes = [start] if start >= 0 else []
	return c


# --- Map (rule 1, Formulas H; AC-KMD-99) ----------------------------------------------------------------------------

func test_the_v5_map_loads_with_the_gdd_counts_ac_kmd_99() -> void:
	var t := _t()
	var kinds := {}
	for n in t.nodes.values():
		kinds[n.kind] = int(kinds.get(n.kind, 0)) + 1
	assert_eq(t.nodes.size(), 8057, "8,057 nodes")
	assert_eq(t.size(), 7295, "7,295 visible Dao marks")
	assert_eq(kinds, {"start": 11, "road": 751, "small": 5493, "notable": 1759, "keystone": 43}, "kinds")
	assert_eq(t.nodes.values().filter(func(n): return bool(n.gated)).size(), 817, "817 gated nodes")
	assert_eq(t.starts.size(), 11, "11 starts")
	assert_eq(t.baseline, DaoDoTree.BASELINE, "the v5 baseline")


func test_the_map_loads_once_per_game_data() -> void:
	assert_true(DaoDoTree.load_map(game_data()) == DaoDoTree.load_map(game_data()), "shared, read-only")


func test_every_node_is_reachable_from_every_start_with_the_gate_open() -> void:
	var t := _t()
	var c := _c({"moc": 50, "hoa": 50, "tho": 50, "kim": 50, "thuy": 50}, {"hon_don": 50}, 4)
	for key in t.starts:
		c.tree_nodes = [int(t.starts[key])]
		assert_eq(t.distances(c, game_data()).size(), 8057, "all reachable from the %s start" % key)


func test_no_capability_or_keystone_lies_on_a_road() -> void:
	for n in _t().nodes.values():
		if str(n.kind) == "road":
			assert_true(n.has("grants") and not n.has("mods") and not n.has("cap"), "road #%d grants purity only" % int(n.id))


# --- Starts (rule 3; AC-KMD-96) -------------------------------------------------------------------------------------

func test_offered_starts_follow_the_root_ac_kmd_96() -> void:
	var t := _t()
	var gd := game_data()
	var names := func(c: Character) -> Array: return t.starts_for(c.linh_can, gd).map(func(id): return str(t.start_of[id]))
	assert_eq(names.call(_c({"hoa": 70, "thuy": 40})), ["hoa", "thuy"], "Fire and Water")
	assert_eq(names.call(_c({"thuy": 60}, {"bang": 50})), ["thuy", "bang"], "Water and Ice; not Light")
	assert_true(names.call(_c({"moc": 50, "hoa": 50, "tho": 50, "kim": 50, "thuy": 50}, {"hon_don": 50})).has("hon_don"), "Chaos start offered")


func test_an_npc_takes_its_strongest_start_ac_kmd_96() -> void:
	var t := _t()
	var gd := game_data()
	assert_eq(t.npc_start(_c({"moc": 55, "hoa": 55}).linh_can, gd), int(t.starts.moc), "Wood: generating-cycle tie-break")
	var thunder := _c({"kim": 60, "hoa": 40})
	thunder.linh_can.variants = {"loi": 80.0}
	assert_eq(t.npc_start(thunder.linh_can, gd), int(t.starts.loi), "Thunder 80 over Metal 60")


func test_the_start_is_owned_free_ac_kmd_96() -> void:
	var c := _c({"hoa": 70})
	assert_eq(c.tree_nodes, [FIRE_START], "the Fire start, nothing spent")


# --- Opening (rule 3; AC-KMD-13, -14) -------------------------------------------------------------------------------

func test_opening_costs_one_point_and_checks_every_rule_ac_kmd_13() -> void:
	var t := _t()
	var gd := game_data()
	var c := _c({"hoa": 70})
	c.tree_points = 0
	assert_false(t.can_allocate(c, FIRE_MARK, gd).ok, "no points")
	c.tree_points = 2
	assert_false(t.can_allocate(c, FIRE_START, gd).ok, "already open")
	assert_false(t.can_allocate(c, 2131, gd).ok, "not adjacent")
	assert_true(t.can_allocate(c, FIRE_MARK, gd).ok, "adjacent")
	t.open_node(c, FIRE_MARK, gd)
	assert_eq(c.tree_points, 1, "exactly 1 point")
	assert_true(c.tree_nodes.has(FIRE_MARK), "open")


func test_paths_are_all_or_nothing_ac_kmd_14() -> void:
	var gd := game_data()
	var llm := LlmService.new(gd)
	llm.enabled = false
	var s := GameSession.new(gd, llm, _t())
	s.new_game(4242, {"mode": "custom", "name": "Thử", "gender": "male", "origin": "tan_tu", "thien_phu": {},
		"purities": {"hoa": 70}, "variants": [], "edge": false})
	s.pending_event = {}
	var target: int = -1
	for id in s.tree.distances(s.player, gd):
		if int(s.tree.distances(s.player, gd)[id]) == 5:
			target = int(id)
			break
	var route: Array = s.tree.path_to(s.player, gd, target)
	assert_eq(route.size(), 5, "a 5-node route")
	s.player.tree_points = 4
	var before: Array = s.player.tree_nodes.duplicate()
	assert_false(s.tree_allocate(target, true).ok, "4 points fail")
	assert_eq(s.player.tree_nodes, before, "nothing changed")
	assert_eq(s.player.tree_points, 4, "nothing spent")
	s.player.tree_points = 5
	assert_true(s.tree_allocate(target, true).ok, "5 points open it")
	for id in route:
		assert_true(s.player.tree_nodes.has(id), "#%d open" % int(id))
	assert_eq(s.player.tree_points, 0, "all spent")


func test_the_route_preview_equals_the_route_opened_ac_kmd_14() -> void:
	var t := _t()
	var gd := game_data()
	var c := _c({"hoa": 70})
	var preview: Array = t.path_to(c, gd, 2131)
	c.tree_points = preview.size()
	for id in preview:
		assert_true(t.can_allocate(c, int(id), gd).ok, "each step legal")
		t.open_node(c, int(id), gd)
	assert_true(c.tree_nodes.has(2131), "reached")


# --- Scaling (rule 4; AC-KMD-15, -16) -------------------------------------------------------------------------------

func test_land_marks_scale_by_purity_ac_kmd_15() -> void:
	var t := _t()
	var gd := game_data()
	assert_near(t.node_scale(FIRE_MARK, _c({"hoa": 60}).linh_can, gd), 1.10, 1e-9, "Fire 60")
	assert_near(t.node_scale(FIRE_MARK, _c({"hoa": 100}).linh_can, gd), 1.50, 1e-9, "Fire 100")
	assert_near(t.node_scale(FIRE_MARK, _c({"hoa": 140}).linh_can, gd), 1.90, 1e-9, "Fire 140")
	assert_near(t.node_scale(FIRE_MARK, _c({"kim": 60}).linh_can, gd), 0.25, 1e-9, "absent")


func test_an_unowned_element_raised_by_roads_scales_at_the_unowned_rate_ac_kmd_15() -> void:
	var t := _t()
	var gd := game_data()
	var lc := _c({"kim": 60}).linh_can
	lc.add_road_purity(gd, "hoa", 1.0)
	assert_near(t.node_scale(FIRE_MARK, lc, gd), 0.26, 1e-9, "purity 1.0: x0.26, not x0.51")
	lc.add_road_purity(gd, "hoa", 24.0)
	assert_near(t.node_scale(FIRE_MARK, lc, gd), 0.50, 1e-9, "purity 25")
	lc.add_road_purity(gd, "hoa", 5.0)
	assert_near(t.node_scale(FIRE_MARK, lc, gd), 0.55, 1e-9, "purity 30")


func test_border_wind_and_exact_scales_ac_kmd_15() -> void:
	var t := _t()
	var gd := game_data()
	assert_near(t.node_scale(BORDER_WF, _c({"moc": 60}).linh_can, gd), 0.675, 1e-9, "Wood 60, Fire absent")
	assert_near(t.node_scale(WIND_MARK, _c({"hoa": 60}, {"phong": 50}).linh_can, gd), 1.00, 1e-9, "Wind 50")
	assert_near(t.node_scale(WIND_MARK, _c({"hoa": 60}).linh_can, gd), 0.25, 1e-9, "no Wind")
	for n in t.nodes.values():
		if str(n.kind) == "keystone":
			assert_eq(t.node_scale(int(n.id), _c({"hoa": 10}).linh_can, gd), 1.0, "keystone #%d exact" % int(n.id))
	var c := _c({"hoa": 70})
	c.tree_nodes.append(FIRE_MARK)
	var m: Dictionary = t.collect_mods(c, gd)[0]
	assert_eq(m.source, "Đạo Đồ: %s #%d" % [t.node(FIRE_MARK).name, FIRE_MARK], "the source")


func test_a_root_change_rescales_open_marks_on_the_same_call_ac_kmd_16() -> void:
	var t := _t()
	var gd := game_data()
	var c := _c({"hoa": 60})
	c.tree_nodes.append(FIRE_MARK)
	var v60: float = float(t.collect_mods(c, gd)[0].value)
	c.linh_can.raise_purity(gd, "hoa", 20)
	var v80: float = float(t.collect_mods(c, gd)[0].value)
	var base: float = float(t.node(FIRE_MARK).mods[0].value)
	assert_near(v60, base * 1.10, 1e-6, "x1.10")
	assert_near(v80, base * 1.30, 1e-6, "x1.30")


func test_parents_lands_scale_by_the_variant_ac_lc_58() -> void:
	var t := _t()
	var gd := game_data()
	var water: int = t.nodes.values().filter(func(n): return str(n.get("area", "")) == "el:thuy")[0].id
	assert_near(t.node_scale(water, _c({"hoa": 86}, {"phong": 50}).linh_can, gd), 1.00, 1e-9, "Wind 50 owns Water's land")
	assert_near(t.node_scale(water, _c({"thuy": 70}, {"bang": 1}).linh_can, gd), 1.20, 1e-9, "Ice = Water 70")
	var chaos := _c({"moc": 50, "hoa": 60, "tho": 50, "kim": 40, "thuy": 30}, {"hon_don": 1})
	assert_near(t.node_scale(water, chaos.linh_can, gd), 0.95, 1e-9, "Chaos 45")


# --- Roads (rule 4; AC-KMD-97) --------------------------------------------------------------------------------------

func test_roads_grant_purity_ac_kmd_97() -> void:
	var t := _t()
	var gd := game_data()
	var c := _c({"hoa": 70, "tho": 40})
	c.tree_points = 10
	t.open_node(c, FIRE_ROAD, gd)
	assert_eq(c.linh_can.purity("hoa"), 70.5, "a Fire road +0.5 Fire")
	t.open_node(c, FE_ROAD, gd)
	assert_eq(c.linh_can.purity("hoa"), 70.75, "a Fire-Earth border road +0.25 Fire")
	assert_eq(c.linh_can.purity("tho"), 40.25, "and +0.25 Earth")
	var five := _c({"moc": 50, "hoa": 50, "tho": 50, "kim": 50, "thuy": 50}, {"hon_don": 50})
	five.tree_points = 1
	t.open_node(five, HUB_ROAD, gd)
	for e in gd.element_cycle():
		assert_eq(five.linh_can.purity(e), 50.5, "a hub road +0.5 %s" % e)


# --- Chaos land gate (rule 3; AC-KMD-102) ---------------------------------------------------------------------------

func test_the_chaos_land_is_shut_to_an_ordinary_root_ac_kmd_102() -> void:
	var t := _t()
	var gd := game_data()
	var c := _c({"hoa": 86, "kim": 40}, {}, 2)   # Core Formation, so capability notables count as reachable
	c.tree_points = 9999
	for n in t.nodes.values():
		if bool(n.gated):
			assert_false(t.accessible(c, int(n.id), gd), "#%d gated" % int(n.id))
	assert_eq(t.distances(c, gd).size(), 7240, "all 7,240 other nodes reachable from the Fire start")
	assert_eq(t.path_to(c, gd, EMBER_HEART), [], "no route to a gated node")
	assert_false(t.frontier(c, gd).any(func(id): return bool(t.node(id).gated)), "no gated node on the frontier")


func test_the_gate_opens_above_thirty_and_scales_by_the_weakest_ac_kmd_102() -> void:
	var t := _t()
	var gd := game_data()
	var at30 := _c({"hoa": 30, "tho": 40, "kim": 50, "thuy": 60, "moc": 70})
	assert_false(t.gate_open(at30.linh_can, gd), "Fire 30 is not above 30")
	at30.tree_points = 1
	t.open_node(at30, FIRE_ROAD, gd)
	assert_true(t.gate_open(at30.linh_can, gd), "one Fire road: Fire 30.5")
	var at31 := _c({"hoa": 31, "tho": 40, "kim": 50, "thuy": 60, "moc": 70})
	assert_true(t.gate_open(at31.linh_can, gd), "Fire 31")
	assert_near(t.node_scale(EMBER_HEART, at31.linh_can, gd), 0.81, 1e-9, "the weakest element at the owned rate")
	var chaos := _c({"hoa": 86})
	chaos.linh_can.variants = {"hon_don": 55.0}   # set as is: a recompute would read the absent parents
	assert_near(t.node_scale(EMBER_HEART, chaos.linh_can, gd), 1.05, 1e-9, "Chaos 55, not Fire")
	assert_true(t.gate_open(chaos.linh_can, gd), "a Chaos root opens it at any purity")


# --- Capabilities (rule 16; AC-KMD-42, -100) ------------------------------------------------------------------------

func test_capability_notables_need_core_formation_ac_kmd_100() -> void:
	var t := _t()
	var gd := game_data()
	var caps: Array = t.nodes.values().filter(func(n): return int(n.get("cap", 0)) > 0)
	assert_eq(caps.size(), 25, "25 capability notables")
	var ids := {}
	for n in caps:
		ids[int(n.cap)] = true
	assert_eq(ids.size(), 25, "each capability once")
	var nid: int = int(caps.filter(func(n): return not bool(n.gated))[0].id)
	var c := _c({"hoa": 70, "kim": 70, "moc": 70, "tho": 70, "thuy": 70}, {}, 1)
	c.tree_nodes.append_array(t.neighbors(nid))
	c.tree_points = 5
	var r: Dictionary = t.can_allocate(c, nid, gd)
	assert_false(r.ok, "Foundation Establishment refused")
	assert_true(str(r.reason).contains(str(gd.realm(2).name)), "names Core Formation")
	c.realm_index = 2
	assert_true(t.can_allocate(c, nid, gd).ok, "Core Formation")
	t.open_node(c, nid, gd)
	assert_true(c.has_capability(int(t.node(nid).cap)), "held")
	c.grant_capability(int(t.node(nid).cap))
	assert_eq(c.capabilities.size(), 1, "a second grant changes nothing")


# --- Breakthrough curve (Formulas F; AC-KMD-59) ---------------------------------------------------------------------

func test_the_breakthrough_curve_ac_kmd_59() -> void:
	var gd := game_data()
	for pair in [[8.0, 5.55], [16.0, 8.79], [32.0, 12.88], [0.0, 0.0]]:
		var sh := StatSheet.new()
		sh._gd = gd
		if float(pair[0]) > 0.0:
			sh.add_mod("Đạo Đồ: test", "breakthrough_chance", float(pair[0]), StatSheet.KIND_TREE)
		assert_near(sh.tree_breakthrough(), float(pair[1]), 0.01, "%s pp" % str(pair[0]))


# --- Scoped lines (ADR-0004 decision 4) -----------------------------------------------------------------------------

func test_scoped_lines_stay_out_of_the_totals() -> void:
	var gd := game_data()
	var sh := StatSheet.new()
	sh._gd = gd
	sh.add_mod("Đạo Đồ: a", "attack_pct", 6.0, StatSheet.KIND_TREE, ["hoa"])
	sh.add_mod("Đạo Đồ: b", "attack_pct", 4.0, StatSheet.KIND_TREE)
	assert_eq(sh.total("attack_pct"), 4.0, "the plain line only")
	assert_eq(sh.scoped("attack_pct").size(), 1, "the scoped line kept apart")
	assert_eq(sh.scoped_lines()[0].scope, ["hoa"], "with its scope")


# --- NPC allocator (rule 5; AC-KMD-18, -55) -------------------------------------------------------------------------

func test_npc_allocation_is_repeatable_and_legal_ac_kmd_18() -> void:
	var gd := game_data()
	var db := WorldDB.new()
	var gen := BuildGenerator.new(gd, _t(), db)
	var runs: Array = []
	for i in 2:
		var c := _c({"hoa": 70, "kim": 40}, {}, 2)
		c.tree_points = 150
		var r := RandomNumberGenerator.new()
		r.seed = 77
		var stats := {}
		gen.allocate(c, r, ["hoa"], stats)
		runs.append(c.tree_nodes.duplicate())
		assert_eq(c.tree_points, 0, "every point spent")
		assert_eq(c.tree_nodes.size(), 151, "start + 150")
		assert_eq(int(stats.pops), 150, "one pop per point (no rescan)")
		var fire := 0
		var other := {}
		for id in c.tree_nodes:
			var a: String = str(_t().node(int(id)).get("area", ""))
			if a == "el:hoa":
				fire += 1
			elif a.begins_with("el:"):
				other[a] = int(other.get(a, 0)) + 1
			assert_false(bool(_t().node(int(id)).gated), "no gated node")
		for a in other:
			assert_true(fire > int(other[a]), "more Fire than %s" % a)
	assert_eq(runs[0], runs[1], "identical on repeat")


func test_an_npc_opens_the_gate_with_roads_and_then_enters_ac_kmd_102() -> void:
	var gd := game_data()
	var gen := BuildGenerator.new(gd, _t(), WorldDB.new())
	var c := _c({"hoa": 30, "tho": 40, "kim": 50, "thuy": 60, "moc": 70}, {}, 2)
	assert_false(_t().gate_open(c.linh_can, gd), "shut at Fire 30")
	c.tree_nodes = [FIRE_START]   # its strongest start is Wood's; from Fire's the first Fire road is close
	c.tree_points = 400
	var r := RandomNumberGenerator.new()
	r.seed = 5
	gen.allocate(c, r, ["hoa"])
	assert_true(_t().gate_open(c.linh_can, gd), "Fire roads lifted it past 30")


func test_an_npc_below_core_formation_takes_no_capability() -> void:
	var gd := game_data()
	var gen := BuildGenerator.new(gd, _t(), WorldDB.new())
	var c := _c({"hoa": 70, "kim": 70}, {}, 1)
	c.tree_points = 300
	var r := RandomNumberGenerator.new()
	r.seed = 9
	gen.allocate(c, r, ["hoa"])
	assert_eq(c.capabilities, [], "none below Core Formation")


# --- Saves (rule 19; AC-KMD-51, -98) --------------------------------------------------------------------------------

func test_a_round_trip_keeps_the_tree_state_ac_kmd_51() -> void:
	var gd := game_data()
	var c := _c({"hoa": 70})
	c.tree_points = 1
	_t().open_node(c, FIRE_ROAD, gd)
	c.grant_capability(5)
	var once: String = JSON.stringify(c.to_dict())
	var back := Character.from_dict(JSON.parse_string(once))
	assert_eq(back.tree_nodes, c.tree_nodes, "start and open nodes")
	assert_eq(back.capabilities, [5], "capabilities")
	assert_eq(back.tree_baseline, DaoDoTree.BASELINE, "baseline")
	assert_eq(back.linh_can.purity("hoa"), 70.5, "road purity")
	assert_eq(JSON.stringify(back.to_dict()), once, "serialising twice gives identical output")


func test_an_old_generated_map_record_is_migrated_once_ac_kmd_98() -> void:
	var gd := game_data()
	var llm := LlmService.new(gd)
	llm.enabled = false
	var s := GameSession.new(gd, llm, _t())
	var rec := {"tree_nodes": range(86), "tree_points": 35, "unsealed": [3], "fills": {}, "is_player": false,
		"linh_can": {"elements": {"hoa": 70, "thuy": 40}, "variants": {}, "rolled": [], "declined": []}}
	assert_true(s.migrate_tree_record(rec), "migrated")
	assert_eq(rec.tree_points, 120, "85 opened + 35 unspent = 120")
	assert_eq(rec.tree_nodes, [FIRE_START], "the strongest element's start")
	assert_eq(rec.tree_baseline, DaoDoTree.BASELINE, "flag set")
	assert_false(rec.has("unsealed"), "hidden-cluster state dropped")
	assert_false(s.migrate_tree_record(rec), "loading it again changes nothing")
	assert_eq(rec.tree_points, 120, "unchanged")
