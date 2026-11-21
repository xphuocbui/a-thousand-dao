extends DaoTestSuite
## Cave Abode's moving rules against design/gdd/cave-abode.md: leaving a home (rules 1, 10; AC-CA-01, 12), claiming a
## left or ruined abode (rule 11, F4; AC-CA-13), and a dead owner's abode a Ruin (rule 10; AC-CA-17).


func _place(id: String, grade: int, owner: String = "p1") -> Dictionary:
	return {"id": id, "name": id, "owner_id": owner, "qi": {"layer1": {owner: {}},
		"abode": {"owner": owner, "grade": grade, "unpaid": 0, "pending": 0, "state": "open", "order": [], "dormant": []}}}


func test_leaving_an_abode_leaves_it_at_its_grade_and_the_works_stop_counting_ac_ca_01_12() -> void:
	var gd := game_data()
	var db := WorldDB.new()
	var old := _place("l1", 3)
	old.qi.layer1.p1["tended_abode"] = {"level": 3}
	db.put("places", old)
	var c := Character.from_dict({"id": "p1", "realm_index": 2, "home_id": "l1"})
	c.formations = {"tu_linh": 2}
	CaveAbode.reconcile(gd, old.qi, c)
	CaveAbode.leave(gd, c, old)
	assert_eq([str(old.qi.abode.state), CaveAbode.grade_of(old.qi.abode)], ["left", 3], "Left at grade 3")
	assert_eq(c.formations, {}, "the arrays stay behind")
	assert_eq(int(old.qi.arrays_left.p1.tu_linh.level), 2, "Tu Linh is left at the place")
	assert_near(float(MapWorks.density(gd, old.qi, c).l1), 0.0, 1e-9, "the permanent work stays with the place and counts 0 for the owner")
	var fresh: Dictionary = _place("l2", 1)
	assert_eq(CaveAbode.used(fresh.qi, c), 0, "the new home has no works")
	for i in 4:
		CaveAbode.fade_left(gd, db, "p1")
	assert_eq(int(old.qi.arrays_left.p1.tu_linh.level), 1, "Tu Linh fades a level on the abode's clock")
	var res := {"id": "l3", "name": "town", "qi": {"residences": {"p1": {"grade": 2, "own": false, "rent": 10}}}}
	CaveAbode.leave(gd, c, res)
	assert_false(res.qi.residences.has("p1"), "a residence returns to its holder")
	assert_false(CaveAbode.claimable(res, Character.from_dict({"id": "p9"})), "and is never claimable")


func test_claiming_a_left_abode_follows_f4_ac_ca_13() -> void:
	var gd := game_data()
	var db := WorldDB.new()
	var place := _place("l1", 3, "p7")
	place.qi.layer1.p7["tended_abode"] = {"level": 2}
	place.qi.abode.state = "left"
	var c := Character.from_dict({"id": "p1", "realm_index": 2, "linh_thach": 1000})
	var r: Dictionary = CaveAbode.claim(gd, db, c, place)
	assert_true(bool(r.ok), "claimed")
	assert_eq([c.linh_thach, CaveAbode.grade_of(place.qi.abode), str(place.qi.abode.owner)], [875, 2, "p1"], "fee 125, grade 3 - 1, the claimant's")
	assert_eq(int(place.qi.layer1.p1.tended_abode.level), 2, "the permanent work passes to the claimant")
	assert_false(CaveAbode.claimable(place, Character.from_dict({"id": "p2"})), "a second claimant is refused")
	var one := _place("l2", 1, "p7")
	one.qi.abode.state = "ruin"
	CaveAbode.claim(gd, db, c, one)
	assert_eq(CaveAbode.grade_of(one.qi.abode), 1, "an old grade 1 stays 1; a Ruin on the same terms")
	var five := _place("l3", 5, "p7")
	five.qi.abode.state = "left"
	for id in ["tended_abode", "private_spring", "focus_array"]:
		five.qi.layer1.p7[id] = {"level": 1, "element": "hoa"}
	var lk := Character.from_dict({"id": "p5", "realm_index": 0, "linh_thach": 100})
	lk.formations = {"tu_linh": 1, "thanh_moc": 1}
	CaveAbode.claim(gd, db, lk, five)
	assert_eq(CaveAbode.grade_of(five.qi.abode), 3, "a Qi Refining claimant holds at most grade 3")
	assert_eq(Array(five.qi.abode.dormant).size(), 1, "works beyond the 4 slots go dormant")


func test_a_dead_owners_abode_is_a_ruin_an_heir_claims_like_anyone_ac_ca_17() -> void:
	var gd := game_data()
	var db := WorldDB.new()
	var place := _place("l1", 2, "p7")
	CaveAbode.ruin(place)
	assert_eq(str(place.qi.abode.state), "ruin", "a Ruin")
	var heir := Character.from_dict({"id": "p8", "realm_index": 2, "linh_thach": 1000})
	assert_true(CaveAbode.claimable(place, heir), "an heir may claim it")
	CaveAbode.claim(gd, db, heir, place)
	assert_eq([CaveAbode.grade_of(place.qi.abode), heir.linh_thach], [1, 875], "at grade - 1 and the usual fee")
