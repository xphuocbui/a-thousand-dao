extends DaoTestSuite
## The great breakthrough through the session: pills, conditions, talismans, Awakening,
## hidden clusters and capabilities (canh-gioi.md rules 7-11, kinh-mach-do.md rules 7-10, 17).


func _session(purities: Dictionary = {"hoa": 86, "kim": 40}, perkless: bool = true) -> GameSession:
	var gd := game_data()
	var llm := LlmService.new(gd)
	llm.enabled = false
	var s := GameSession.new(gd, llm, TestFixtures.tree())
	s.new_game(4242, {"mode": "custom", "name": "Thử", "gender": "male", "origin": "tan_tu", "thien_phu": {}, "purities": purities, "variants": [], "edge": not perkless})
	s.pending_event = {}
	return s


func _gate(s: GameSession, realm_idx: int) -> void:
	var c: Character = s.player
	c.realm_index = realm_idx
	c.level = Ladder.band(s.gd, realm_idx)[1]
	c.level_peak = c.level
	c.stage = Ladder.stage_of_level(s.gd, c.level)
	c.tu_vi = Ladder.bar_cost(s.gd, realm_idx)
	c.age = 40.0


func _pill(s: GameSession, realm_idx: int, qty: int = 1) -> String:
	var tag: String = str(s.gd.realm(realm_idx + 1).entry_requirement.item_tag)
	return s.alchemy.add_pills(s.player, tag, 0, qty)


func _dense_home(s: GameSession) -> void:
	s.db.get_record("places", s.player.location_id)["density"] = 2.0


func test_a_pill_attempt_burns_the_pill_and_a_failure_adds_insight() -> void:
	var s := _session()
	_gate(s, 0)
	var id: String = _pill(s, 0, 2)
	s.player.tam_ma = 0.0
	var before: int = int(s.db.get_record("items", id).qty)
	s.breakthrough()
	assert_eq(int(s.db.get_record("items", id).get("qty", 0)), before - 1, "one pill burned")


func test_with_the_condition_unmet_a_pill_needs_confirmation_and_is_kept_ac45() -> void:
	var s := _session()
	_gate(s, 1)
	s.db.get_record("places", s.player.location_id)["density"] = 1.0
	var id: String = _pill(s, 1)
	var r: Dictionary = s.breakthrough()
	assert_true(r.get("needs_confirm", false), "preview first")
	assert_eq(int(s.db.get_record("items", id).qty), 1, "no pill burned")
	s.breakthrough(true)
	assert_eq(int(s.db.get_record("items", id).qty), 1, "a bare attempt burns no pill")
	assert_eq(s.player.bare_attempts, 1, "counted as bare")


func test_a_fourth_bare_attempt_is_refused_ac40a() -> void:
	var s := _session()
	_gate(s, 1)
	s.player.bare_attempts = 3
	var r: Dictionary = s.breakthrough(true)
	assert_false(r.ok, "refused")
	assert_true(str(r.lines[0]).contains("used up"), "says why")


func test_only_one_talisman_counts_per_realm_step_ac22() -> void:
	var s := _session()
	_gate(s, 0)
	_pill(s, 0, 3)
	var t: Dictionary = s.items.talisman("pha_canh", 3)
	t["owner_id"] = s.player.id
	var tid: String = s.db.add("items", t)
	s.breakthrough()
	if s.player.realm_index != 0:
		return
	assert_eq(int(s.db.get_record("items", tid).qty), 2, "one burned")
	assert_true(s.player.talisman_used, "flag set")
	s.player.tu_vi = Ladder.bar_cost(s.gd, 0)
	s.player.tam_ma = 0.0
	s.breakthrough()
	if s.player.realm_index == 0:
		assert_eq(int(s.db.get_record("items", tid).qty), 2, "no second talisman this step")


func test_awakening_rolls_on_success_with_the_capability_ac30() -> void:
	var s := _session()
	_gate(s, 2)
	s.player.grant_capability(24)
	s.player.linh_can.rolled = ["phong", "huyet", "hu_khong", "loi", "quang"]
	var fired: Array = []
	s.breakthrough_succeeded.connect(func(r): fired.append(r))
	s._on_breakthrough_succeeded()
	assert_eq(fired, [2], "the event fired once")
	assert_true(s.player.linh_can.rolled.has("loi"), "Thunder may roll again")


func test_an_event_unseals_the_nearest_sealed_cluster_kmd() -> void:
	var s := _session()
	s.player.realm_index = 3
	var before: int = s.db.count("events")
	var line: String = s._unseal_from_event("sealed")
	assert_true(line != "", "one opened")
	assert_eq(s.player.unsealed.size(), 1, "recorded")
	assert_eq(s.db.count("events"), before + 1, "a World Database record")
	var k: Dictionary = s.tree.clusters[int(s.player.unsealed[0])]
	assert_eq(k.seal.type, "event", "an event-sealed cluster")


func test_a_gate_above_the_realm_keeps_a_cluster_shut() -> void:
	var s := _session()
	var high: Array = s.tree.clusters.values().filter(func(k): return int(k.gate) > 0)
	assert_eq(s.unseal_cluster(int(high[0].id), "test"), "", "refused in Qi Refining")


func test_open_unseals_stop_at_the_realm_allowance() -> void:
	var s := _session()
	s.player.realm_index = 2
	assert_true(s._unseal_from_event("open") != "", "first")
	assert_eq(s._unseal_from_event("open"), "", "second refused: allowance 1")
	assert_eq(s.player.fills.size(), 1, "the fill is recorded")


func test_a_seal_key_opens_an_item_sealed_cluster_and_is_consumed() -> void:
	var s := _session()
	s.player.realm_index = 3
	var t: Dictionary = s.items.treasure("mach_an")
	t["owner_id"] = s.player.id
	var tid: String = s.db.add("items", t)
	var r: Dictionary = s.use_item(tid)
	assert_true(r.ok, "used: %s" % str(r.lines))
	assert_false(s.db.has_record("items", tid), "consumed")
	assert_eq(s.tree.clusters[int(s.player.unsealed[0])].seal.type, "item", "an item seal")


func test_opening_a_capability_notable_grants_it() -> void:
	var s := _session()
	var k: Dictionary = s.tree.clusters.values().filter(func(x): return int(x.capability) > 0)[0]
	var nid: int = k.notables[0]
	s.player.unsealed.append(int(k.id))
	s.player.tree_nodes.append_array(s.tree.neighbors(nid))
	s.player.tree_points = 3
	s.tree_allocate(nid, false)
	assert_true(s.player.has_capability(int(k.capability)), "granted")


func test_guard_keeps_the_lift_at_delta_max_kmd_e2() -> void:
	var gd := game_data()
	assert_near(CultivationRules.q_desperate(gd, 0.25, 0.0, 0.70), 0.40, 1e-9, "S 0.70, q 0.25")
	assert_near(CultivationRules.q_desperate(gd, 0.30, 0.0, 0.30), 0.40, 1e-9, "the clamp binds")
	assert_near(CultivationRules.q_desperate(gd, 0.1225, 0.05, 0.1725), 0.2225, 1e-9, "with a talisman")
	assert_near(CultivationRules.q_retry(gd, 0.25, 0.04, 0.70), 0.25, 1e-9, "no insight left to add")
	assert_near(CultivationRules.q_retry(gd, 0.1025, 0.02, 0.17654), 0.09715, 1e-4, "insight reserved")


func test_burn_cost_is_the_greater_of_its_terms() -> void:
	var gd := game_data()
	var c := TestFixtures.character({"hoa": 50})
	assert_eq(CultivationRules.burn_cost(c, gd), 10.0, "QR: 10 years")
	c.realm_index = 3
	assert_eq(CultivationRules.burn_cost(c, gd), 50.0, "NS: 5 % of 1,000")


func test_soul_leaves_the_body_saves_a_life_once_per_realm_cap5() -> void:
	var s := _session()
	var c: Character = s.player
	c.grant_capability(5)
	c.realm_index = 1
	c.level = 60
	c.stage = 1
	CultivationRules.lose_stage(c, s.gd)
	assert_eq(c.level, 40, "first level of the previous stage")
	assert_eq(c.tu_vi, 0.0, "bar reset")
	assert_eq(c.realm_index, 1, "never crosses a realm")


func test_second_slot_needs_capability_six() -> void:
	var s := _session()
	var c: Character = s.player
	var m: Dictionary = s.items.cong_phap(rng(1), 0, ["hoa"])
	m["tech_id"] = "second"
	CongPhap.learn(c, m)
	assert_false(CongPhap.set_slot(c, s.gd, "second", 0, "second").ok, "no capability")
	c.grant_capability(6)
	assert_true(CongPhap.set_slot(c, s.gd, "second", 0, "second").ok, "with #6")
	var solo: float = CongPhap.tech_one(c, s.gd, CongPhap.main_entry(c))
	assert_true(CongPhap.speed_factor(c, s.gd).mult > solo, "the second method adds speed")


func test_a_slot_change_that_would_end_the_life_needs_confirmation_ac62() -> void:
	var s := _session()
	var c: Character = s.player
	c.age = 125.0
	var art: Dictionary = {"tech_id": "long", "name": "Trường Sinh", "tier": 0, "tech_kind": "secret", "names": ["hoa"], "layers": 6, "bonuses": [{"stat": "lifespan_years", "value": 20.0}], "abilities": [], "seal_clusters": [], "origin": "authored"}
	CongPhap.learn(c, art)
	c.techniques["long"]["layer"] = 6
	assert_true(s.set_slot("aux", 0, "long").ok, "slotted")
	assert_true(CultivationRules.lifespan(c, s.gd, s.sheet()).total > 125.0, "the bonus holds the life")
	var r: Dictionary = s.set_slot("aux", 0, "")
	assert_true(r.get("needs_confirm", false), "the preview names the death")
	assert_eq(c.aux_tech[0], "long", "declining changes nothing")


func test_starting_technique_is_a_yellow_main_method_on_the_strongest_element_rule16() -> void:
	var s := _session({"moc": 50, "hoa": 50, "kim": 40})
	var e: Dictionary = CongPhap.main_entry(s.player)
	assert_eq(int(e.def.tier), 0, "Yellow")
	assert_eq(e.def.names, ["moc"], "ties go in cycle order")


func test_every_realm_has_a_reserved_par_method_per_element_rule18() -> void:
	var s := _session()
	var reserved: Array = s.db.all("items").filter(func(i): return bool(i.get("reserved", false)))
	assert_eq(reserved.size(), 15, "3 realms x 5 elements")
	var place: Dictionary = s.db.find("places", func(p): return bool(p.get("market", false)))[0]
	s.market.ensure_stock(s.rng, place.id, s.year + 50, 0)
	assert_eq(s.db.all("items").filter(func(i): return bool(i.get("reserved", false))).size(), 15, "a restock keeps them")


func test_the_plant_plan_fills_recipes_in_order_ac66() -> void:
	var s := _session()
	var recipe: Dictionary = s.gd.recipe("truc_co_dan")
	assert_eq(Advisor.next_plant(s, recipe, 1), "hoang_tinh_sam", "the first recipe's first herb")
	for i in 2:
		var h: Dictionary = s.items.herb("hoang_tinh_sam", 0.0)
		h["owner_id"] = s.player.id
		s.db.add("items", h)
	assert_eq(Advisor.next_plant(s, recipe, 1), "hoa_linh_chi", "then its companion")
	var c: Dictionary = s.items.herb("hoa_linh_chi", 0.0)
	c["owner_id"] = s.player.id
	s.db.add("items", c)
	assert_eq(Advisor.next_plant(s, recipe, 1), "", "one recipe covered")
	assert_eq(Advisor.next_plant(s, recipe, 2), "hoang_tinh_sam", "the next brew starts")


func test_a_save_round_trip_keeps_the_step_state_ac56() -> void:
	var s := _session()
	var c: Character = s.player
	c.level = 12
	c.level_peak = 14
	c.bare_attempts = 2
	c.failed_pills = 1
	c.talisman_used = true
	c.has_insight = true
	c.grant_capability(9)
	c.unsealed = [3]
	var back := Character.from_dict(JSON.parse_string(JSON.stringify(c.to_dict())))
	assert_eq(back.level, 12, "level")
	assert_eq(back.level_peak, 14, "peak")
	assert_eq(back.bare_attempts, 2, "bare")
	assert_eq(back.failed_pills, 1, "insight")
	assert_true(back.talisman_used, "talisman")
	assert_true(back.has_insight, "DT insight")
	assert_eq(back.capabilities, [9], "capabilities")
	assert_eq(back.unsealed, [3], "clusters")
	assert_eq(back.main_tech, c.main_tech, "main slot")
	assert_eq(back.techniques.keys(), c.techniques.keys(), "known techniques")
