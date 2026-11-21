extends DaoTestSuite
## Cave Abode's formulas against design/gdd/cave-abode.md: F1 grade cost, F2 upkeep (with the Thổ cut and the floor),
## F3 slots and the level ceiling, F4 the claim fee and the grade after, F5 the NPC raise gate.


func test_grade_cost_follows_f1_ac_ca_06_20() -> void:
	var gd := game_data()
	assert_eq(CaveAbode.grade_cost(gd, 3, 2), 3750, "Core Formation, grade 3: 5,000 x 0.75")
	var ladder: int = 0
	for g in range(2, 6):
		ladder += CaveAbode.grade_cost(gd, g, 3)
	assert_eq(ladder, 320000, "Nascent Soul, the ladder 2 to 5: 40,000 x 8")
	assert_eq(CaveAbode.grade_cost(gd, 2, 0), 20, "grade 2 at Qi Refining")
	assert_eq(CaveAbode.grade_cost(gd, 1, 2), 0, "grade 1 has no raise cost")


func test_grade_upkeep_follows_f2_ac_ca_09_20() -> void:
	var gd := game_data()
	assert_eq(CaveAbode.grade_upkeep(gd, 5, 3, 0.0), 400, "Nascent Soul, grade 5")
	assert_eq(CaveAbode.grade_upkeep(gd, 5, 3, 75.0), 280, "Tho 75: cut 0.3")
	assert_eq(CaveAbode.grade_upkeep(gd, 5, 3, 100.0), 240, "Tho 100: cut 0.4, 60 %")
	assert_eq(CaveAbode.grade_upkeep(gd, 1, 0, 0.0), 1, "Qi Refining grade 1: the floor")
	assert_eq(CaveAbode.grade_upkeep(gd, 1, 0, 100.0), 1, "the floor with Tho 100")
	assert_eq(CaveAbode.grade_upkeep(gd, 3, 2, 0.0), 13, "Core Formation grade 3: 12.5 rounds up")
	assert_eq(CaveAbode.grade_upkeep(gd, 2, 2, 0.0), 5, "grade 2: 5")


func test_slots_and_the_level_ceiling_follow_f3_ac_ca_03_20() -> void:
	var gd := game_data()
	assert_eq([CaveAbode.slots(gd, 1), CaveAbode.slots(gd, 3), CaveAbode.slots(gd, 5)], [2, 4, 6], "2 / 4 / 6")
	assert_eq([CaveAbode.ceiling(gd, 1, 5), CaveAbode.ceiling(gd, 3, 5), CaveAbode.ceiling(gd, 5, 7)], [3, 5, 7], "grade + 2, after the work's max")
	assert_eq(CaveAbode.ceiling(gd, 5, 3), 3, "a work's own max wins")


func test_the_claim_fee_and_grade_after_follow_f4_ac_ca_13() -> void:
	var gd := game_data()
	assert_eq(CaveAbode.claim_fee(gd, 2), 125, "Core Formation: 5,000 x 0.05 x 0.5")
	assert_eq(CaveAbode.grade_after(gd, 3, 2), 2, "old grade minus one")
	assert_eq(CaveAbode.grade_after(gd, 1, 2), 1, "never below 1")
	assert_eq(CaveAbode.grade_after(gd, 5, 0), 3, "a Qi Refining claimant holds at most grade 3")


func test_an_npc_raises_only_with_the_reserve_and_the_roll_ac_ca_14() -> void:
	var gd := game_data()
	assert_true(CaveAbode.npc_raises(gd, 2, 2, 7500.0, 0.049), "purse 7,500 = 2 x 3,750, roll 0.049")
	assert_false(CaveAbode.npc_raises(gd, 2, 2, 7500.0, 0.050), "roll 0.050: not below 0.05")
	assert_false(CaveAbode.npc_raises(gd, 2, 2, 7499.0, 0.0), "purse 7,499 never")
	assert_false(CaveAbode.npc_raises(gd, 3, 1, 1e9, 0.0), "Truc Co at grade 3: grade 4 needs Core Formation")
