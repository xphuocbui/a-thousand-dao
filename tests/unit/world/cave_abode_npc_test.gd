extends DaoTestSuite
## Cave Abode's NPC abodes against design/gdd/cave-abode.md rule 12 and F5 (AC-CA-14): the keyed raise at the gate,
## the old grade's upkeep from the NPC's own purse, the fade clock of one that cannot pay, and one aggregate burn.


func _npc(id: String, realm: int, purse: float, grade: int = 2) -> Dictionary:
	return {"id": id, "realm_index": realm, "linh_thach": purse, "abode_grade": grade, "alive": true, "sect_id": ""}


func test_the_raise_gate_and_roll_follow_f5_ac_ca_14() -> void:
	var gd := game_data()
	var a := _npc("a", 2, 7500.0)
	assert_eq(CaveAbode.npc_pay(gd, a, 0.049, 4), 3755.0, "raise 3,750 plus the grade-2 upkeep 5")
	assert_eq(int(a.abode_grade), 3, "grade 3 from now on")
	var b := _npc("b", 2, 7500.0)
	assert_eq(CaveAbode.npc_pay(gd, b, 0.050, 4), 5.0, "roll 0.050: no raise, the upkeep is paid")
	assert_eq(int(b.abode_grade), 2, "still grade 2")
	var c := _npc("c", 2, 7499.0)
	assert_eq(CaveAbode.npc_pay(gd, c, 0.0, 4), 5.0, "a purse below the gate never raises")
	var top := _npc("t", 1, 1.0e9, 3)
	assert_eq(CaveAbode.npc_pay(gd, top, 0.0, 4), float(CaveAbode.grade_upkeep(gd, 3, 1, 0.0)), "Truc Co holds at most grade 3")


func test_an_npc_that_cannot_pay_advances_only_its_own_clock_and_the_aggregate_is_the_sum_ac_ca_14() -> void:
	var gd := game_data()
	var db := WorldDB.new()
	db.put("people", _npc("a", 2, 7500.0))
	db.put("people", _npc("b", 2, 0.0))
	db.put("people", {"id": "s", "realm_index": 2, "linh_thach": 9000.0, "alive": true, "sect_id": "x1"})
	var u_a: float = CaveAbode.npc_roll("seed", "a", 7)
	var expect: float = 5.0 + (3750.0 if u_a < 0.05 else 0.0)
	var total: float = CaveAbode.npc_season(gd, db, null, "seed", 7)
	assert_eq(total, expect, "the aggregate is what A paid; B pays nothing")
	assert_eq(float(db.get_record("people", "a").linh_thach), 7500.0 - expect, "A's own purse paid")
	assert_eq([float(db.get_record("people", "b").linh_thach), int(db.get_record("people", "b").abode_unpaid)], [0.0, 1], "B: purse untouched, its clock 1")
	assert_eq(float(db.get_record("people", "s").linh_thach), 9000.0, "a sect member has no abode here")
	for i in 3:
		CaveAbode.npc_season(gd, db, null, "seed", 8 + i)
	assert_eq(int(db.get_record("people", "b").abode_grade), 1, "four unpaid seasons: B falls a grade")
