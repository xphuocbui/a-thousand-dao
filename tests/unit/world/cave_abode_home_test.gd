extends DaoTestSuite
## Cave Abode's home rules against design/gdd/cave-abode.md: slots and the level ceiling (rules 3, 4, F3), raising the
## grade (rule 6, F1), the grade upkeep, its falls and the grade-1 floor (rule 8, F2), dormancy (rule 9), layer 1's caps
## with their clamp lines (rule 7, AC-CA-08), a residence's fixed grade (rule 6), and the skill cap (AC-CA-19).


func _abode(grade: int) -> Dictionary:
	return {"abode": {"owner": "p1", "grade": grade, "unpaid": 0, "pending": 0, "state": "open", "order": [], "dormant": []}, "layer1": {"p1": {}}}


func _char(realm: int, lt: int) -> Character:
	var c := Character.from_dict({"id": "p1", "realm_index": realm, "linh_thach": lt})
	return c


func test_slots_and_the_level_ceiling_bound_the_works_ac_ca_03_04() -> void:
	var gd := game_data()
	var qi := _abode(3)
	var c := _char(2, 0)
	for id in ["tended_abode", "private_spring", "focus_array"]:
		qi.layer1.p1[id] = {"level": 1, "unpaid": 0, "element": ""}
	c.formations = {"tu_linh": 1}
	CaveAbode.reconcile(gd, qi, c)
	assert_eq(CaveAbode.used(qi, c), 4, "three works and Tu Linh: 4 of 4 slots (an array takes 1)")
	assert_false(bool(CaveAbode.can_raise(gd, qi, c, "f:thanh_moc", 1, 5).ok), "a fifth work is refused for slots")
	assert_true(bool(CaveAbode.can_raise(gd, qi, c, "f:tu_linh", 5, 5).ok), "grade 3 allows level 5")
	var qi1 := _abode(1)
	assert_false(bool(CaveAbode.can_raise(gd, qi1, c, "f:tu_linh", 4, 5).ok), "grade 1: no work past level 3")
	assert_true(bool(CaveAbode.can_raise(gd, qi1, c, "f:tu_linh", 3, 5).ok), "level 3 at grade 1")


func test_raising_the_grade_pays_now_and_applies_next_season_ac_ca_02_06_07() -> void:
	var gd := game_data()
	var db := WorldDB.new()
	var qi := _abode(2)
	var c := _char(2, 5000)
	var r: Dictionary = CaveAbode.raise(gd, db, c, qi)
	assert_true(bool(r.ok), "Core Formation raises 2 to 3")
	assert_eq([c.linh_thach, CaveAbode.grade_of(qi.abode)], [1250, 2], "3,750 paid; the old grade holds this season")
	CaveAbode.season(gd, db, c, qi)
	assert_eq([CaveAbode.grade_of(qi.abode), c.linh_thach], [3, 1245], "grade 3 from the next season; the season paid grade 2's 5")
	var qt := _abode(3)
	var tc := _char(1, 1000000)
	assert_false(bool(CaveAbode.raise(gd, db, tc, qt).ok), "Truc Co cannot raise to grade 4")
	assert_eq(tc.linh_thach, 1000000, "nothing spent")
	var res := {"residences": {"p1": {"grade": 3, "own": false, "rent": 10}}}
	var rr: Dictionary = CaveAbode.raise(gd, db, tc, res)
	assert_false(bool(rr.ok), "a residence is not raised")
	assert_true(str(rr.lines[0]).contains("grade is fixed"), "with the reason")


func test_the_grade_upkeep_falls_a_grade_after_four_unpaid_seasons_and_grade_1_is_a_floor_ac_ca_10() -> void:
	var gd := game_data()
	var db := WorldDB.new()
	var qi := _abode(3)
	var c := _char(2, 0)
	for i in 4:
		CaveAbode.season(gd, db, c, qi)
	assert_eq(CaveAbode.grade_of(qi.abode), 2, "4 unpaid seasons: grade 2")
	for i in 4:
		CaveAbode.season(gd, db, c, qi)
	assert_eq(CaveAbode.grade_of(qi.abode), 1, "4 more: grade 1")
	for i in 12:
		CaveAbode.season(gd, db, c, qi)
	assert_eq([CaveAbode.grade_of(qi.abode), str(qi.abode.state)], [1, "open"], "grade 1 stays, still the home")
	var q2 := _abode(3)
	var c2 := _char(2, 0)
	for i in 3:
		CaveAbode.season(gd, db, c2, q2)
	c2.linh_thach = 100
	CaveAbode.season(gd, db, c2, q2)
	assert_eq([CaveAbode.grade_of(q2.abode), int(q2.abode.unpaid)], [3, 0], "a paid season resets the clock")


func test_a_lost_slot_sends_the_latest_built_to_dormancy_and_it_wakes_when_one_is_free_ac_ca_11() -> void:
	var gd := game_data()
	var db := WorldDB.new()
	var qi := _abode(4)
	var c := _char(2, 0)
	var ids := ["tended_abode", "private_spring", "focus_array"]
	for id in ids:
		qi.layer1.p1[id] = {"level": 2, "unpaid": 0, "element": "hoa"}
		CaveAbode.reconcile(gd, qi, c)
	c.formations = {"tu_linh": 1, "thanh_moc": 1}
	CaveAbode.reconcile(gd, qi, c)
	qi.abode["grade"] = 3
	CaveAbode.reconcile(gd, qi, c)
	var latest: String = str(Array(qi.abode.order)[-1])
	assert_eq(Array(qi.abode.dormant), [latest], "the latest built goes dormant")
	assert_eq(CaveAbode.eff_level(gd, qi, "p1", latest, 1, 5), 0, "it counts for nothing")
	qi.abode["grade"] = 4
	CaveAbode.reconcile(gd, qi, c)
	assert_eq(Array(qi.abode.dormant), [], "a slot opens: it wakes")
	assert_eq(CaveAbode.eff_level(gd, qi, "p1", "w:focus_array", 2, 5), 2, "at its kept level")
	qi.abode["grade"] = 3
	CaveAbode.reconcile(gd, qi, c)
	c.linh_thach = 1000
	var before: int = c.linh_thach
	qi.abode["dormant"] = ["w:focus_array"]
	MapWorks.upkeep(gd, _db_with(qi), c)
	assert_eq(c.linh_thach, before, "a dormant upkept work costs nothing")


func _db_with(qi: Dictionary) -> WorldDB:
	var db := WorldDB.new()
	db.put("places", {"id": "l1", "name": "Home", "qi": qi})
	return db


func test_layer_one_caps_each_and_prints_the_clamps_ac_ca_08() -> void:
	var gd := game_data()
	var works: Dictionary = gd.file("map_works").works
	works["fx_perm"] = {"name": "fx", "layer": 1, "kind": "permanent", "stat": "density", "per_level": 0.2, "max": 1}
	var c := _char(2, 0)
	var qi := _abode(3)
	qi.layer1.p1["fx_perm"] = {"level": 1}
	var d: Dictionary = MapWorks.density(gd, qi, c, 0, 0.9)
	works.erase("fx_perm")
	assert_near(float(d.l1), 0.85, 1e-9, "0.75 + 0.1, each cap separately")
	assert_eq(Array(d.lines).filter(func(l): return str(l).contains("clamped")).size(), 2, "two clamp lines")
	var d2: Dictionary = MapWorks.density(gd, _abode(3), c, 0, 0.75)
	assert_eq(Array(d2.lines).filter(func(l): return str(l).contains("clamped")).size(), 0, "Tu Linh at exactly 0.75: no clamp")


func test_an_array_counts_at_its_skill_cap_ac_ca_19() -> void:
	var gd := game_data()
	var db := WorldDB.new()
	db.put("places", {"id": "l1", "name": "Home", "qi": _abode(3)})
	var c := _char(2, 0)
	c.home_id = "l1"
	c.location_id = "l1"
	c.formations = {"tu_linh": 5}
	c.skills = {"tran_phap": {"level": 2, "xp": 0.0}}
	var sheet := StatSheet.build(c, gd, db, null)
	var per: float = 0.0
	for f in gd.file("crafting_formations").formations:
		if str(f.id) == "tu_linh":
			per = float(f.per_level)
	assert_near(sheet.total("home_array_density"), per * 3.0, 1e-6, "level 5 under ceiling 5 counts at the skill cap 3")
	assert_near(sheet.total("density_bonus"), 0.0, 1e-9, "no longer on density_bonus")


func test_a_dormant_array_owes_no_upkeep_and_one_over_the_ceiling_is_billed_at_it_rule_9() -> void:
	var gd := game_data()
	var db := WorldDB.new()
	var qi := _abode(1)
	qi.abode["order"] = ["f:tu_linh", "f:thanh_moc", "f:ho_son"]
	qi.abode["dormant"] = ["f:ho_son"]
	db.put("places", {"id": "l1", "name": "Home", "qi": qi})
	var c := _char(2, 0)
	c.home_id = "l1"
	c.formations = {"tu_linh": 5, "thanh_moc": 1, "ho_son": 4}
	var f := Formations.new(gd, db)
	assert_eq(f.upkeep(c), 10 * 3 + 8 * 1, "Tu Linh 5 billed at the grade-1 ceiling 3, Ho Son dormant: 0")
	f.pay_upkeep(c)
	assert_eq(int(c.formations.ho_son), 4, "the dormant array never lapses")


func test_the_stat_block_shows_grade_slots_levels_gains_dormancy_upkeep_and_clamps_ac_ca_15() -> void:
	var gd := game_data()
	var qi := _abode(1)
	qi.layer1.p1["tended_abode"] = {"level": 1}
	var c := _char(2, 0)
	c.formations = {"tu_linh": 5, "ho_son": 1}
	qi.abode["order"] = ["f:tu_linh", "w:tended_abode", "f:ho_son"]
	qi.abode["dormant"] = ["f:ho_son"]
	var out: String = "\n".join(PackedStringArray(CaveAbode.lines(gd, qi, c, 0.9)))
	assert_true(out.contains("grade 1: ") and out.contains(" of 2 slots used"), "the grade and slots: %s" % out)
	assert_true(out.contains("upkeep"), "the grade upkeep")
	assert_true(out.contains("Tụ Linh Trận") and out.contains("level 5") and out.contains("counts at 3"), "the level and the ceiling: %s" % out)
	assert_true(out.contains("(dormant)"), "the dormant work")
	assert_true(out.contains("clamped"), "the clamp line")
