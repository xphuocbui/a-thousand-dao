extends DaoTestSuite
## Formations Part I, combat diagrams, against design/gdd/formations.md: F1 strength, F2 fuel, rule 7's effective
## level, F6 reservation, the node budget and the reservation cap (rules 3, 9a), drawbacks and polarity (F1), F4's
## NPC choice, and the diagram compiled into a fight (rules 1-6): the default line, node order, Modifier and gate
## nodes, and feeds. Fixture diagrams only: the catalogue is the user's to author (Open Question 4).


func _ring(n: int = 3) -> Dictionary:
	var nodes: Array = []
	for i in n:
		nodes.append({"polarity": "+", "rule": {"type": "mod", "key": "art_speed_pct", "value": 10.0}, "node_score": 1.0})
	return {"id": "fx_ring", "grade": 2, "nodes": nodes, "links": [], "reserve_share": 0.12}


func test_strength_follows_f1_ac_fo_17() -> void:
	var gd := game_data()
	assert_near(Diagrams.strength(gd, 2, 3, 20.0), 2.4375, 1e-9, "1.3 x 1.5625 x 1.2")
	assert_near(Diagrams.scaled(10.0, "+", Diagrams.strength(gd, 2, 3, 20.0), 1.0), 24.375, 1e-6, "+10 laid")
	assert_near(Diagrams.scaled(10.0, "+", Diagrams.strength(gd, 2, 3, 20.0), 0.7), 17.0625, 1e-6, "+10 in an ambush")
	assert_near(Diagrams.strength(gd, 0, 1, 0.0), 1.0, 1e-9, "grade 0, L1")
	assert_near(Diagrams.strength(gd, 0, 1, -50.0), 0.5, 1e-9, "power -50 %")
	assert_near(Diagrams.clamp_s(gd, 0.1), 0.25, 1e-9, "S_min")
	assert_near(Diagrams.strength(gd, 4, 7, 100.0), 8.0, 1e-9, "clamped to S_max")


func test_drawbacks_scale_by_the_share_only_and_polarity_not_sign_decides_ac_fo_18() -> void:
	var gd := game_data()
	var s: float = Diagrams.strength(gd, 2, 3, 20.0)
	assert_near(Diagrams.scaled(-15.0, "-", s, 1.0), -15.0, 1e-9, "a drawback stays -15 laid")
	assert_near(Diagrams.scaled(-15.0, "-", s, 0.7), -10.5, 1e-9, "-10.5 in an ambush")
	assert_near(Diagrams.scaled(-20.0, "+", s, 1.0), -48.75, 1e-6, "a cheaper-cost node is a benefit: scaled")


func test_fuel_follows_f2_with_the_rounding_tolerance_ac_fo_08_19() -> void:
	var gd := game_data()
	assert_eq(Diagrams.fuel(gd, 5, 2, 3, 2), 288, "Core Formation, N 5, grade 2, L3: 288, not 289")
	assert_eq(Diagrams.fuel(gd, 1, 0, 1, 0), 1, "the ceil at Qi Refining")
	assert_eq(Diagrams.fuel(gd, 7, 4, 5, 2), 2294, "N 7, grade 4, L5")
	assert_eq(Diagrams.fuel(gd, 7, 4, 7, 2), 5873, "with the keystone's L7")


func test_the_effective_level_follows_the_skill_cap_and_the_keystone_ac_fo_20() -> void:
	var gd := game_data()
	assert_eq(Diagrams.level_eff(gd, 4, 1), 2, "skill 1 caps at 2")
	assert_eq(Diagrams.level_eff(gd, 7, 6, true), 7, "skill 6, the keystone: 7")
	assert_eq(Diagrams.level_eff(gd, 7, 6), 5, "without it: max_level 5")
	assert_eq(Diagrams.level_eff(gd, 4, 1, true), 4, "min(4, 2 + 2)")


func test_the_situation_sets_the_share_ac_fo_08() -> void:
	var gd := game_data()
	assert_eq([Diagrams.share_of(gd, FightRequest.Situation.FORESEEN, true), Diagrams.share_of(gd, FightRequest.Situation.FORESEEN, false),
		Diagrams.share_of(gd, FightRequest.Situation.AMBUSH, true), Diagrams.share_of(gd, FightRequest.Situation.BLIND, true)],
		[1.0, 0.7, 0.7, 0.5], "laid, carried, ambush, blind")


func test_the_reservation_is_never_scaled_and_the_cap_and_node_budget_hold_ac_fo_02_24_26() -> void:
	var d := _ring()
	assert_near(Diagrams.reserved(d, 25.0), 0.09, 1e-9, "0.12 at 25 % efficiency: 90 of 1,000")
	assert_near(Diagrams.reserved(d, 80.0), 0.06, 1e-9, "efficiency above 50 % counts as 50")
	assert_true(bool(Diagrams.can_set(d, 5, 0.0, 0.0, 0.9).ok), "3 nodes in 5 slots")
	assert_false(bool(Diagrams.can_set(_ring(6), 5, 0.0, 0.0, 0.9).ok), "6 nodes in 5 slots cannot be set")
	assert_false(bool(Diagrams.can_set(d, 5, 0.80, 0.0, 0.9).ok), "wards at 0.80 plus 0.12 pass the 0.90 cap")


func test_an_npc_takes_the_best_fit_ties_to_fewer_nodes_ac_fo_12() -> void:
	var gd := game_data()
	var arts := [{"id": "a", "tags": []}, {"id": "b", "tags": []}, {"id": "c", "tags": []}, {"id": "d", "tags": []},
		{"id": "e", "tags": []}, {"id": "f", "tags": []}, {"id": "g", "tags": []}]
	var mk := func(id: String, scores: Array) -> Dictionary:
		return {"id": id, "grade": 0, "links": [], "nodes": scores.map(func(x): return {"polarity": "+", "rule": {}, "node_score": float(x)})}
	var four: Dictionary = mk.call("d4", [4.0])
	var seven5: Dictionary = mk.call("d7a", [3.0, 1.0, 1.0, 1.0, 1.0])
	var seven6: Dictionary = mk.call("d7b", [2.0, 1.0, 1.0, 1.0, 1.0, 1.0])
	assert_eq(str(Diagrams.choose(gd, [four, seven6, seven5], arts).diagram.id), "d7a", "fits 4, 7, 7: the 5-node one")
	assert_true(Dictionary(Diagrams.choose(gd, [mk.call("z", [0.0])], arts).diagram).is_empty(), "a fit of exactly 0: the default line")


func _fight(gd: GameData, pa: FighterProfile) -> Fight:
	return Fight.new(pa, FighterCompiler.from_data("typical", 1, gd), CombatConstants.from_game_data(gd), 7)


func test_the_default_line_changes_nothing_ac_fo_01() -> void:
	var gd := game_data()
	var p1: FighterProfile = FighterCompiler.from_data("typical", 1, gd)
	var p2: FighterProfile = FighterCompiler.from_data("typical", 1, gd)
	assert_eq(Diagrams.apply(gd, p2, {}, [], 1.0, 1.0), [], "no lines")
	var r1: FightResult = _fight(gd, p1).run()
	var r2: FightResult = _fight(gd, p2).run()
	assert_eq([r1.win_code(), r1.t_ms, r1.a_end.health, r1.b_end.health], [r2.win_code(), r2.t_ms, r2.a_end.health, r2.b_end.health], "the same fight")


func test_node_order_comes_first_and_a_modifier_node_acts_on_its_art_only_ac_fo_03_04() -> void:
	var gd := game_data()
	var p: FighterProfile = FighterCompiler.from_data("typical", 1, gd)
	var ids: Array = p.arts.map(func(a): return str(a.id))
	assert_true(ids.size() >= 3, "the typical kit has at least 3 arts")
	var d := {"id": "fx", "grade": 0, "links": [], "reserve_share": 0.0,
		"nodes": [{"polarity": "+", "rule": {"type": "mod", "key": "art_speed_pct", "value": 25.0}}]}
	Diagrams.apply(gd, p, d, [ids[2]], 1.0, 1.0)
	assert_eq(str(p.arts[0].id), str(ids[2]), "the node's art goes first")
	assert_eq(p.arts.slice(1).map(func(a): return str(a.id)), [ids[0], ids[1]] + ids.slice(3), "plain slots keep their order")
	var f := _fight(gd, p)
	var own: float = f.art_speed(f.a, p.arts[0])
	var other: float = f.art_speed(f.a, p.arts[1])
	assert_near(own - other, 0.25, 1e-9, "+25 % art speed on that art only (10 s -> 8 s alone)")


func test_a_gate_node_adds_a_guard_to_its_art_ac_fo_04() -> void:
	var gd := game_data()
	var p: FighterProfile = FighterCompiler.from_data("typical", 1, gd)
	var first: String = str(p.arts[0].id)
	var before: int = p.arts[0].guards.size()
	var d := {"id": "fx", "grade": 0, "links": [], "nodes": [{"polarity": "?", "rule": {"type": "gate", "cond": {"read": "own.hp_share", "op": ">=", "value": 0.5}}}]}
	Diagrams.apply(gd, p, d, [first], 1.0, 1.0)
	assert_eq(p.arts[0].guards.size(), before + 1, "one more guard")
	assert_eq(FighterCompiler.from_data("typical", 1, gd).arts[0].guards.size(), before, "the shared art is not changed")


func test_a_feed_takes_seconds_off_a_cooling_timer_with_the_floor_ac_fo_05() -> void:
	var gd := game_data()
	var p: FighterProfile = FighterCompiler.from_data("typical", 1, gd)
	var ids: Array = p.arts.map(func(a): return str(a.id))
	var d := {"id": "fx", "grade": 0, "nodes": [{"polarity": "+", "rule": {}}, {"polarity": "+", "rule": {}}],
		"links": [{"kind": "feed", "from": 1, "to": 2, "seconds": 2.0}, {"kind": "feed", "from": 2, "to": 1, "seconds": 2.0}]}
	Diagrams.apply(gd, p, d, [ids[0], ids[1]], 1.0, 1.0)
	var f := _fight(gd, p)
	var k: CombatConstants = CombatConstants.from_game_data(gd)
	f.t = 1000
	f.a.ready[1] = 7000
	f._feed(f.a, 0)
	assert_eq(f.a.ready[1] - f.t, 4000, "6 s left, fed 2 s: 4 s")
	f.a.ready[1] = f.t + 1000
	f._feed(f.a, 0)
	assert_eq(f.a.ready[1] - f.t, k.cooldown_min_ms, "1 s left stops at cooldown_min")
	f.a.ready[1] = f.t + 300
	f._feed(f.a, 0)
	assert_eq(f.a.ready[1] - f.t, 300, "below cooldown_min: never raised")
	f.a.ready[1] = f.t
	f._feed(f.a, 0)
	assert_eq(f.a.ready[1], f.t, "ready already: nothing changes")
	var p2: FighterProfile = FighterCompiler.from_data("typical", 1, gd)
	Diagrams.apply(gd, p2, d, [ids[0], ids[1]], 2.4375, 1.0)
	assert_eq(int(p2.feeds[0][2]), 4875, "a feed scales like any positive number: 4.875 s at S 2.44")


func test_a_cost_node_stays_within_its_bound_ac_fo_18() -> void:
	var gd := game_data()
	var p: FighterProfile = FighterCompiler.from_data("typical", 1, gd)
	var first: String = str(p.arts[0].id)
	var d := {"id": "fx", "grade": 4, "links": [], "nodes": [{"polarity": "+", "rule": {"type": "mod", "key": "art_cost_pct", "value": -20.0}}]}
	Diagrams.apply(gd, p, d, [first], 8.0, 1.0)
	assert_eq(p.arts[0].node_cost_pct, float(Diagrams.cfg(gd).node_cost_min_pct), "-160 % is held at the bound")


func test_an_adjacency_node_reads_its_linked_art_and_moves_no_timer_ac_fo_06() -> void:
	var gd := game_data()
	var p: FighterProfile = FighterCompiler.from_data("typical", 1, gd)
	var ids: Array = p.arts.map(func(a): return str(a.id))
	var tag: String = "fire"   # a fixture tag on the neighbour (the typical kit's arts carry none)
	p.arts[1].tags_s = ["fire"]
	var d := {"id": "fx", "grade": 0, "nodes": [
		{"polarity": "+", "rule": {"type": "adj_mod", "key": "art_speed_pct", "value": 20.0, "tag": tag}},
		{"polarity": "+", "rule": {}}], "links": [{"kind": "adj", "a": 1, "b": 2}]}
	Diagrams.apply(gd, p, d, [ids[0], ids[1]], 1.0, 1.0)
	assert_eq(p.arts[0].node_speed_pct, 20.0, "+20 while the linked art carries %s" % tag)
	assert_eq(p.feeds, [], "adjacency moves no timer")
	var p2: FighterProfile = FighterCompiler.from_data("typical", 1, gd)
	Diagrams.apply(gd, p2, d, [ids[0], ""], 1.0, 1.0)
	assert_eq(p2.arts[0].node_speed_pct, 0.0, "an empty neighbour gives nothing")
	var d2: Dictionary = d.duplicate(true)
	d2.nodes[0].rule.tag = "no_such_tag"
	var p3: FighterProfile = FighterCompiler.from_data("typical", 1, gd)
	Diagrams.apply(gd, p3, d2, [ids[0], ids[1]], 1.0, 1.0)
	assert_eq(p3.arts[0].node_speed_pct, 0.0, "a neighbour without the tag gives nothing")


func test_a_feed_that_fires_is_logged_with_source_target_and_seconds_ac_fo_11() -> void:
	var gd := game_data()
	var p: FighterProfile = FighterCompiler.from_data("typical", 1, gd)
	var ids: Array = p.arts.map(func(a): return str(a.id))
	var d := {"id": "fx", "grade": 0, "nodes": [{"polarity": "+", "rule": {}}, {"polarity": "+", "rule": {}}],
		"links": [{"kind": "feed", "from": 1, "to": 2, "seconds": 2.0}]}
	var lines: Array = Diagrams.apply(gd, p, d, [ids[0], ids[1]], 1.0, 1.0)
	assert_true(lines.any(func(l): return str(l).begins_with("feed 1 -> 2")), "the opening Breakdown has the feed line")
	var f := Fight.new(p, FighterCompiler.from_data("typical", 1, gd), CombatConstants.from_game_data(gd), 7, Fight.Order.COIN, true)
	var r: FightResult = f.run()
	var feeds: Array = r.log_rows.filter(func(row): return row.kind == FightLogRow.Kind.FEED)
	assert_true(feeds.size() > 0, "the fight record has FEED rows (%d)" % feeds.size())
	assert_eq(str(feeds[0].art_id), ids[1], "the target art")


func test_a_deferred_fuel_is_burnt_only_when_paid_ac_fo_09() -> void:
	var gd := game_data()
	var db := WorldDB.new()
	db.add(WorldEconomy.TABLE, {"id": "k_test", "sect_id": "s1", "regions": []})
	var c := Character.from_dict({"id": "p1", "realm_index": 2, "linh_thach": 1000})
	var rec: Dictionary = c.to_dict()
	rec["is_player"] = true
	db.put("people", rec)
	var nodes: Array = []
	for i in 3:
		nodes.append({"polarity": "+", "rule": {}})
	c.diagram = {"record": {"id": "fx", "grade": 2, "nodes": nodes, "links": []}, "level": 1, "placement": []}
	var p: FighterProfile = FighterCompiler.from_data("typical", 2, gd)
	var due: Array = []
	Diagrams.compile_for(gd, db, c, p, null, FightRequest.Situation.FORESEEN, 5, due)
	assert_eq([c.linh_thach, due.size()], [1000, 1], "decided, not paid: a fight refused now burns nothing")
	Diagrams.pay_fuel(db, due[0][0], int(due[0][1]))
	assert_eq(c.linh_thach, 1000 - int(due[0][1]), "paid once the fight has run")
	c.diagram["lay"] = false
	var due2: Array = []
	Diagrams.compile_for(gd, db, c, FighterCompiler.from_data("typical", 2, gd), null, FightRequest.Situation.FORESEEN, 5, due2)
	assert_eq(due2.size(), 0, "the player chose not to lay")


func test_a_gate_on_a_count_or_the_fight_time_reads_as_plain_numbers() -> void:
	# regression (2026-11-26): the gate text formatted its value with "%g", which GDScript's % does not support, so the
	# sect window printed "String formatting error" and the condition lost its number
	var timed: String = Diagrams.rule_words({"type": "gate", "cond": {"read": "time", "op": ">=", "value": 12.0}}, "?")
	assert_eq(timed, "holds until the fight's time >= 12s")
	var counted: String = Diagrams.rule_words({"type": "gate", "cond": {"read": "foe.curses", "op": ">=", "value": 2.5}}, "?")
	assert_eq(counted, "holds until the foe's curses >= 2.5")
