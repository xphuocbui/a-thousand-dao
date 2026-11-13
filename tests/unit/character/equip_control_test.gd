extends DaoTestSuite
## Item Database rule 11 (AC-ID-42, user decision 2026-11-13): a piece past the extra-slot count adds nothing, its
## affixes included, and counts again once a slot frees up, either by thần thức opening one or by an earlier extra
## piece leaving. The pieces here have no base, so no role, so they sit in extra slots.


func _piece(db: WorldDB, affixes: Array = []) -> String:
	return db.add("items", {
		"kind": "artifact", "name": "Thử", "base": "", "element": "", "attack": 10.0, "defense": 0.0,
		"affixes": affixes, "owner_id": "", "value": 1,
	})


func _khi_huyet(value: float) -> Array:
	return [{"id": "t", "word": "", "stat": "khi_huyet_pct", "value": value}]


func test_a_piece_past_the_extra_slots_applies_no_affix() -> void:
	var gd := game_data()
	var db := WorldDB.new()
	var c := TestFixtures.character({"hoa": 50})
	var a: String = _piece(db)
	var b: String = _piece(db)
	var past: String = _piece(db, _khi_huyet(10.0))
	c.equipped = [a, b, past]
	assert_eq(StatSheet.build(c, gd, db, null).total("khi_huyet_pct"), 0.0, "the third extra piece adds nothing")
	c.equipped = [b, past]
	assert_eq(StatSheet.build(c, gd, db, null).total("khi_huyet_pct"), 10.0, "counts once an earlier extra leaves")


func test_than_thuc_opening_a_slot_makes_the_piece_count() -> void:
	var gd := game_data()
	var db := WorldDB.new()
	var c := TestFixtures.character({"hoa": 50})
	var past: String = _piece(db, _khi_huyet(10.0))
	c.equipped = [_piece(db), _piece(db), past]
	c.thien_phu["than_hon"] = 79   # 79 >= 1.75 x 45: a third extra slot at Qi Refining
	assert_eq(StatSheet.build(c, gd, db, null).total("khi_huyet_pct"), 10.0, "the new slot holds it")


func test_the_sheet_and_combat_power_agree_on_what_counts() -> void:
	var gd := game_data()
	var db := WorldDB.new()
	var c := TestFixtures.character({"hoa": 50})
	var a: String = _piece(db)
	var b: String = _piece(db)
	var past: String = _piece(db)
	c.equipped = [a, b, past]
	var p: Dictionary = CombatPower.compute(c, gd, db, StatSheet.build(c, gd, db, null))
	assert_eq(p.used_artifacts, [a, b], "the first two count")
	assert_eq(p.overflow, [past], "the third is past the count")
	assert_eq(p.extra_used, 2, "two extra slots used")
	assert_eq(p.extra_limit, 2, "of two")
