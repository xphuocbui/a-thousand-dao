extends DaoTestSuite
## KarmicRules unit tests covering Formulas A-C, Rules 4-6, and AC-CK-07, 08, 09,
## 10, 11 (refund rule helper), 17, and 20.


func test_ac_ck_07_successor_perks_edge_and_starting_talismans() -> void:
	var gd := game_data()
	var held: Array = ["dao_cot", "tho_nguyen"]
	var offered: Array = KarmicRules.roll_successor_perks(gd, rng(777), held, 0, "thien_dinh")
	assert_eq(offered.size(), 3, "AC-CK-07: Fated heir with 0 karma rolls 3 unheld destiny perks")
	for pid in offered:
		assert_false(held.has(pid), "AC-CK-07: already-held perk %s is never offered again" % str(pid))
	assert_true(KarmicRules.successor_gets_edge(), "AC-CK-07: successor gains protagonist edge")

	var heir_items: Array = KarmicRules.successor_starting_talismans(gd, true)
	assert_eq(heir_items.size(), 0, "AC-CK-07: heir receives no Phá Cảnh Phù")
	assert_eq(KarmicRules.successor_birth_mode("tu_dinh", true, "thien_dinh"), "tu_dinh", "Rule 5: heir keeps dead life birth mode")

	var reborn_items: Array = KarmicRules.successor_starting_talismans(gd, false)
	assert_eq(reborn_items.size(), 1, "AC-CK-07: reborn receives starting item entry")
	assert_eq(str(reborn_items[0].talisman), "pha_canh", "AC-CK-07: reborn receives Phá Cảnh Phù")
	assert_eq(int(reborn_items[0].qty), 2, "AC-CK-07: reborn receives 2 Phá Cảnh Phù")
	assert_eq(KarmicRules.successor_birth_mode("tu_dinh", false, "thien_dinh"), "thien_dinh", "Rule 5: reborn picks birth mode fresh")


func test_ac_ck_08_karma_earned_formula_a() -> void:
	var gd := game_data()
	# Trúc Cơ (1) + 25 newly known entries -> 1 + floor(25/10) = 3.
	assert_eq(KarmicRules.karma_earned(gd, "continue", "thien_dinh", false, 1, false, 0, 25), 3, "AC-CK-08: Trúc Cơ + 25 new = 3")
	# Same life with 0 newly known entries (already known in earlier life) -> 1.
	assert_eq(KarmicRules.karma_earned(gd, "continue", "thien_dinh", false, 1, false, 0, 0), 1, "AC-CK-08: Trúc Cơ + 0 new = 1")
	# Nguyên Anh (3) + 30 newly known -> 4 + 3 = 7.
	assert_eq(KarmicRules.karma_earned(gd, "continue", "thien_dinh", false, 3, false, 0, 30), 7, "Formulas A example: NA + 30 = 7")
	# Hóa Thần (4) + 60 newly known -> 6 + 6 = 12.
	assert_eq(KarmicRules.karma_earned(gd, "continue", "thien_dinh", false, 4, false, 0, 60), 12, "Formulas A max example: HT + 60 = 12")
	# Heir who gains no realm earns 0 from realm_karma (strict loss on paid heir).
	assert_eq(KarmicRules.karma_earned(gd, "continue", "thien_dinh", false, 2, true, 2, 0), 0, "Formulas A: heir with no realm gain earns 0 realm karma")
	assert_eq(KarmicRules.karma_earned(gd, "continue", "thien_dinh", false, 2, true, 2, 15), 1, "heir with no realm gain still earns discovery karma")
	# Heir who climbs past start_realm earns realm_karma for r_max.
	assert_eq(KarmicRules.karma_earned(gd, "continue", "thien_dinh", false, 3, true, 2, 0), 4, "heir climbing KD -> NA earns NA realm karma (4)")
	# Self-made or cheated Continue life earns 0 (Rule 6 + Rule 9 gate).
	assert_eq(KarmicRules.karma_earned(gd, "continue", "tu_dinh", false, 4, false, 0, 50), 0, "Rule 6: Self-made earns 0 karma")
	assert_eq(KarmicRules.karma_earned(gd, "continue", "thien_dinh", true, 4, false, 0, 50), 0, "Rule 6: cheated earns 0 karma")


func test_ac_ck_09_karma_spending_and_overspend_rejection() -> void:
	var gd := game_data()
	# 4 karma: lineage (3) + 1 extra perk option -> options 4, karma_left 0.
	var ok_res: Dictionary = KarmicRules.validate_spend(gd, 4, false, 0, true, 1, 8, "thien_dinh")
	assert_true(bool(ok_res.ok), "AC-CK-09: lineage (3) + 1 extra fits 4 karma")
	assert_eq(int(ok_res.total_cost), 4, "total cost 4")
	assert_eq(int(ok_res.karma_left), 0, "AC-CK-09: leaves 0 karma")
	assert_eq(int(ok_res.options), 4, "AC-CK-09: 4 perk options offered")

	# Overspending rejected (lineage 3 + 2 extra = 5 > 4).
	var over_res: Dictionary = KarmicRules.validate_spend(gd, 4, false, 0, true, 2, 8, "thien_dinh")
	assert_false(bool(over_res.ok), "AC-CK-09: overspend rejected")
	assert_eq(str(over_res.reason), "insufficient_karma", "reason is insufficient_karma")

	# perk_extra never exceeds perk_extra_max (3), even with abundant karma.
	var cap_res: Dictionary = KarmicRules.validate_spend(gd, 20, false, 0, false, 4, 8, "thien_dinh")
	assert_false(bool(cap_res.ok), "AC-CK-09: perk_extra > 3 rejected")
	assert_eq(str(cap_res.reason), "perk_extra_above_max", "reason is perk_extra_above_max")
	assert_eq(KarmicRules.max_perk_extra(gd, 20, 0, 8, "thien_dinh"), 3, "max_perk_extra capped at 3")

	# heir * lineage = 0 (lineage is rebirth-only).
	var both_res: Dictionary = KarmicRules.validate_spend(gd, 20, true, 0, true, 0, 8, "thien_dinh")
	assert_false(bool(both_res.ok), "Formulas B: cannot combine heir and lineage")
	assert_eq(str(both_res.reason), "lineage_with_heir", "reason is lineage_with_heir")


func test_ac_ck_10_one_life_earns_zero_and_new_continue_starts_at_zero() -> void:
	var gd := game_data()
	assert_eq(KarmicRules.karma_earned(gd, "one_life", "thien_dinh", false, 4, false, 0, 100), 0, "AC-CK-10: One Life earns 0 karma")
	assert_eq(KarmicRules.starting_karma(), 0, "AC-CK-10: new Continue playthrough starts with 0 karma")


func test_ac_ck_11_destroyed_lineage_refund_helper() -> void:
	var gd := game_data()
	var alive_res: Dictionary = KarmicRules.resolve_lineage_survival(gd, 1, "sect", true, "r6")
	assert_false(bool(alive_res.refunded), "surviving sect triggers no refund")
	assert_eq(int(alive_res.karma), 1, "karma unchanged when lineage survives")

	var dead_res: Dictionary = KarmicRules.resolve_lineage_survival(gd, 1, "sect", false, "r6")
	assert_true(bool(dead_res.refunded), "AC-CK-11: destroyed sect triggers refund")
	assert_eq(int(dead_res.refund_amount), 3, "AC-CK-11: refunds lineage_cost (3)")
	assert_eq(int(dead_res.karma), 4, "AC-CK-11: refunded karma added back")
	assert_eq(str(dead_res.fallback_origin), "tan_tu", "AC-CK-11: falls back to loose cultivator")
	assert_eq(str(dead_res.fallback_region_id), "r6", "AC-CK-11: starts in that region")


func test_ac_ck_17_unheld_perk_pool_clamping_and_self_made_gate() -> void:
	var gd := game_data()
	var all_ids: Array = ProgressionEdges.perks(gd).map(func(p): return str(p.id))
	assert_eq(all_ids.size(), 8, "8 total destiny perks in character_edges.json")

	# 6 held (unheld = 2) with 2 karma -> perk_extra capped at 0, 2 unheld perks show, karma stays 2.
	assert_eq(KarmicRules.max_perk_extra(gd, 2, 0, 2, "thien_dinh"), 0, "AC-CK-17: 6/8 held caps perk_extra at 0")
	var v6_bad: Dictionary = KarmicRules.validate_spend(gd, 2, true, 0, false, 1, 2, "thien_dinh")
	assert_false(bool(v6_bad.ok), "AC-CK-17: buying extra perk rejected when unheld = 2")
	var v6_ok: Dictionary = KarmicRules.validate_spend(gd, 2, true, 0, false, 0, 2, "thien_dinh")
	assert_true(bool(v6_ok.ok), "AC-CK-17: 0 extra succeeds")
	assert_eq(int(v6_ok.options), 2, "AC-CK-17: shows the 2 unheld perks")
	assert_eq(int(v6_ok.karma_left), 2, "AC-CK-17: karma stays 2")
	var rolled_2: Array = KarmicRules.roll_successor_perks(gd, rng(11), all_ids.slice(0, 6), 0, "thien_dinh")
	assert_eq(rolled_2.size(), 2, "AC-CK-17: rolls exactly the 2 unheld perks")

	# 5 held (unheld = 3) with 3 karma -> perk_extra capped at 0, 3 options show.
	assert_eq(KarmicRules.max_perk_extra(gd, 3, 0, 3, "thien_dinh"), 0, "AC-CK-17: 5/8 held caps perk_extra at 0")
	var v5_ok: Dictionary = KarmicRules.validate_spend(gd, 3, true, 0, false, 0, 3, "thien_dinh")
	assert_eq(int(v5_ok.options), 3, "AC-CK-17: 3 unheld options show")

	# 8 held (unheld = 0) -> pick skipped (empty list).
	assert_eq(KarmicRules.roll_successor_perks(gd, rng(12), all_ids, 0, "thien_dinh").size(), 0, "Edge Case: 0 unheld skips perk pick")

	# Self-made successor -> perk_extra not offered (capped at 0, >0 rejected).
	assert_eq(KarmicRules.max_perk_extra(gd, 10, 0, 8, "tu_dinh"), 0, "AC-CK-17: Self-made max_perk_extra is 0")
	var v_self_bad: Dictionary = KarmicRules.validate_spend(gd, 10, false, 0, false, 1, 8, "tu_dinh")
	assert_false(bool(v_self_bad.ok), "AC-CK-17: Self-made rejects perk_extra > 0")
	assert_eq(str(v_self_bad.reason), "perk_extra_self_made", "reason is perk_extra_self_made")


func test_ac_ck_20_heir_costs_and_candidate_filtering() -> void:
	var gd := game_data()
	assert_eq(KarmicRules.heir_cost(gd, 0), 0, "AC-CK-20: Luyện Khí heir costs 0")
	assert_eq(KarmicRules.heir_cost(gd, 1), 1, "Trúc Cơ heir costs 1")
	assert_eq(KarmicRules.heir_cost(gd, 2), 3, "AC-CK-20: Kết Đan heir costs 3")
	assert_eq(KarmicRules.heir_cost(gd, 3), 6, "AC-CK-20: Nguyên Anh heir costs 6")
	assert_eq(KarmicRules.heir_cost(gd, 4), 10, "Hóa Thần heir costs 10")
	assert_eq(KarmicRules.heir_cost(gd, -1), 0, "mortal/realm-less heir counts as 0")

	var db := WorldDB.new()
	var dead_id: String = db.add("people", {"name": "Tổ Sư", "alive": false, "realm_index": 3})
	var lk_child: String = db.add("people", {"name": "Con Luyện Khí", "alive": true, "realm_index": 0, "stage": 1, "parent_id": dead_id, "age": 20.0})
	var kd_disc: String = db.add("people", {"name": "Đệ Tử Kết Đan", "alive": true, "realm_index": 2, "stage": 0, "master_id": dead_id, "age": 80.0})
	var na_disc: String = db.add("people", {"name": "Đệ Tử Nguyên Anh", "alive": true, "realm_index": 3, "stage": 0, "master_id": dead_id, "age": 220.0})
	var killer_disc: String = db.add("people", {"name": "Phản Đồ", "alive": true, "realm_index": 2, "stage": 0, "master_id": dead_id, "age": 90.0})
	var dead_child: String = db.add("people", {"name": "Con Đã Mất", "alive": false, "realm_index": 1, "stage": 0, "parent_id": dead_id, "age": 40.0})

	var cands: Array = KarmicRules.heir_candidates(gd, db, dead_id, killer_disc, 5, [kd_disc, na_disc, killer_disc])
	assert_eq(cands.size(), 3, "AC-CK-20: offers the 3 living non-killer heirs (excludes killer and dead)")
	var by_id: Dictionary = {}
	for c in cands:
		by_id[str(c.id)] = c

	assert_false(by_id.has(killer_disc), "known killer excluded from heir candidates")
	assert_false(by_id.has(dead_child), "dead child excluded from heir candidates")

	assert_eq(int(by_id[lk_child].cost), 0, "AC-CK-20: LK heir costs 0")
	assert_true(bool(by_id[lk_child].affordable), "LK heir affordable at 5 karma")
	assert_false(bool(by_id[lk_child].greyed), "LK heir not greyed")

	assert_eq(int(by_id[kd_disc].cost), 3, "AC-CK-20: KD heir costs 3")
	assert_true(bool(by_id[kd_disc].affordable), "KD heir affordable at 5 karma")
	assert_false(bool(by_id[kd_disc].greyed), "KD heir not greyed")

	assert_eq(int(by_id[na_disc].cost), 6, "AC-CK-20: NA heir costs 6")
	assert_false(bool(by_id[na_disc].affordable), "AC-CK-20: NA heir unaffordable at 5 karma")
	assert_true(bool(by_id[na_disc].greyed), "AC-CK-20: NA heir shows greyed with its cost")


func test_formula_c_rebirth_gap_and_recognition_cap() -> void:
	var gd := game_data()
	assert_eq(KarmicRules.rebirth_years(gd, "tan_tu"), 16, "Formula C: rebirth_years is 16")
	assert_eq(KarmicRules.rebirth_seasons(gd, "tan_tu"), 64, "Formula C: rebirth_seasons is 64")
	assert_eq(KarmicRules.recognition_max(gd), 2, "Formula C: recognition_max is 2")
