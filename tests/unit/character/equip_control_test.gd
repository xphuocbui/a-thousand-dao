extends DaoTestSuite
## Item Database rule 11 (AC-ID-42): a piece the wearer cannot control adds nothing, its
## affixes included, and a cheaper later piece that fits still counts.


func _piece(db: WorldDB, cost: float, affixes: Array = []) -> String:
	return db.add("items", {
		"kind": "artifact", "name": "Thử", "base": "", "element": "", "attack": 10.0, "defense": 0.0,
		"than_thuc_cost": cost, "affixes": affixes, "owner_id": "", "value": 1,
	})


func _khi_huyet(value: float) -> Array:
	return [{"id": "t", "word": "", "stat": "khi_huyet_pct", "value": value}]


func _capacity(c: Character, db: WorldDB) -> float:
	return CharacterRules.than_thuc(c, game_data(), StatSheet.build(c, game_data(), db, null)).total


func test_a_piece_the_wearer_cannot_control_applies_no_affix() -> void:
	var gd := game_data()
	var db := WorldDB.new()
	var c := TestFixtures.character({"hoa": 50})
	var cap: float = _capacity(c, db)
	var full: String = _piece(db, cap)
	var extra: String = _piece(db, cap, _khi_huyet(10.0))
	c.equipped = [full, extra]
	assert_eq(StatSheet.build(c, gd, db, null).total("khi_huyet_pct"), 0.0, "overflow piece adds nothing")
	c.equipped = [extra]
	assert_eq(StatSheet.build(c, gd, db, null).total("khi_huyet_pct"), 10.0, "controlled once it fits")


func test_a_cheaper_later_piece_still_counts_past_an_overflow() -> void:
	var gd := game_data()
	var db := WorldDB.new()
	var c := TestFixtures.character({"hoa": 50})
	var cap: float = _capacity(c, db)
	var first: String = _piece(db, cap * 0.6)
	var too_big: String = _piece(db, cap * 0.6, _khi_huyet(10.0))
	var cheap: String = _piece(db, cap * 0.2, _khi_huyet(5.0))
	c.equipped = [first, too_big, cheap]
	assert_eq(StatSheet.build(c, gd, db, null).total("khi_huyet_pct"), 5.0, "only the piece that fits")


func test_the_sheet_and_combat_power_agree_on_what_is_controlled() -> void:
	var gd := game_data()
	var db := WorldDB.new()
	var c := TestFixtures.character({"hoa": 50})
	var cap: float = _capacity(c, db)
	var first: String = _piece(db, cap * 0.6)
	var too_big: String = _piece(db, cap * 0.6)
	c.equipped = [first, too_big]
	var p: Dictionary = CombatPower.compute(c, gd, db, StatSheet.build(c, gd, db, null))
	assert_eq(p.used_artifacts, [first], "first piece used")
	assert_eq(p.overflow, [too_big], "second piece overflows")
