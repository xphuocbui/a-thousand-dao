extends DaoTestSuite
## FighterCompiler.compile for a Character (ADR-0001 step 3; user decisions 2026-11-14: typical layers for the realm,
## the library and modifier table shared with fight.py). The build-file step itself is parity-tested against fight.py
## in tests/parity/compile_parity_test.gd; these tests cover what a Character puts into the build file.

const WEAPON := "blade-mirror-trace-sword"     # a weapon with one art and scoped modifiers
const ROBE := "blade-edge-hiding-robe"         # body gear with a drain ward and pool and divine-sense lines


func _named(db: WorldDB, gd: GameData, tid: String, realm: int) -> String:
	var rec: Dictionary = ItemFactory.new(gd).named_artifact(tid, realm, db)
	assert_false(rec.is_empty(), "%s is made" % tid)
	return db.add("items", rec)


func _ordinary(db: WorldDB, affixes: Array) -> String:
	return db.add("items", {"kind": "artifact", "name": "Thử", "base": "", "element": "", "attack": 10.0,
		"defense": 0.0, "affixes": affixes, "owner_id": "", "value": 1})


func test_a_bare_character_fights_as_the_typical_fighter_of_its_realm_with_its_purity() -> void:
	var gd := game_data()
	var db := WorldDB.new()
	var c := TestFixtures.character({"hoa": 60}, 50, 1)
	var report: Array = []
	var d: Dictionary = FighterCompiler.character_build_file(c, gd, db, StatSheet.build(c, gd, db, null), report)
	var typical: Dictionary = gd.file("combat_library").typical[1]
	assert_eq(d.layers, typical.layers, "the realm's typical layers")
	assert_eq(d.ward, typical.ward, "the realm's typical ward")
	assert_eq(d.arts, typical.arts, "the typical kit stands in for arts")
	assert_true(report.any(func(x): return str(x).contains("typical kit")), "and the report says so")
	assert_eq(d.purity, {"fire": 60.0}, "hỏa purity as Fire")
	var errors: Array = []
	var p: FighterProfile = FighterCompiler.compile(c, gd, db, StatSheet.build(c, gd, db, null), [], errors)
	assert_true(p != null and errors.is_empty(), "compiles: %s" % str(errors))
	var r: FightResult = Fight.new(p, FighterCompiler.from_data("typical", 1, gd), CombatConstants.from_game_data(gd), 3).run()
	assert_true(r.seconds > 0.0, "and fights")


func test_named_pieces_bring_their_arts_wards_and_modifiers() -> void:
	var gd := game_data()
	var db := WorldDB.new()
	var c := TestFixtures.character({"kim": 50}, 50, 2)
	c.equipped = [_named(db, gd, WEAPON, 2), _named(db, gd, ROBE, 2)]
	var sheet := StatSheet.build(c, gd, db, null)
	var d: Dictionary = FighterCompiler.character_build_file(c, gd, db, sheet)
	assert_eq(d.items, [WEAPON, ROBE], "both named pieces compile")
	var lib: Dictionary = gd.file("combat_library")
	assert_eq(d.arts, [{"lib": lib.items[WEAPON].arts[0]}], "the weapon's art, not the kit")
	var errors: Array = []
	var p: FighterProfile = FighterCompiler.compile(c, gd, db, sheet, [], errors)
	assert_true(p != null and errors.is_empty(), "compiles: %s" % str(errors))
	assert_eq(p.arts.size(), 1, "one art")
	assert_eq(p.wards.size(), 1, "the robe's ward")
	assert_true(p.effects.any(func(e): return e.id == "item:" + WEAPON), "the weapon's modifiers run as an Effect")


func test_worn_pieces_count_once() -> void:
	# The sheet already holds an ordinary piece's unscoped affix (KIND_ITEM); the compile takes worn pieces' lines
	# from the pieces, so the sheet's copy is left out.
	var gd := game_data()
	var db := WorldDB.new()
	var c := TestFixtures.character({"hoa": 50}, 50, 1)
	c.equipped = [_ordinary(db, [{"id": "a", "word": "", "stat": "khi_huyet_pct", "value": 10.0},
		{"id": "b", "word": "", "stat": "attack_pct", "value": 6.0, "scope": ["fire"]}])]
	var sheet := StatSheet.build(c, gd, db, null)
	assert_eq(sheet.total("khi_huyet_pct"), 10.0, "the sheet counts the affix")
	var d: Dictionary = FighterCompiler.character_build_file(c, gd, db, sheet)
	var pools: Array = d.modifiers.filter(func(l): return l.key == "khi_huyet_pct")
	assert_eq(pools.size(), 1, "one khi_huyet_pct line")
	assert_eq(float(pools[0].value), 10.0, "worth the affix once")
	var scoped: Array = d.modifiers.filter(func(l): return l.key == "attack_pct")
	assert_eq(scoped.size(), 1, "the scoped affix comes too")
	assert_eq(scoped[0].scope, ["fire"], "with its scope")


func test_sheet_lines_from_other_sources_reach_the_fight() -> void:
	var gd := game_data()
	var db := WorldDB.new()
	var c := TestFixtures.character({"hoa": 50}, 50, 0)
	var sheet := StatSheet.build(c, gd, db, null)
	sheet.add_mod("test perk", "crit_chance_pct", 5.0)
	sheet.add_mod("test perk", "cultivation_speed_pct", 30.0)
	var d: Dictionary = FighterCompiler.character_build_file(c, gd, db, sheet)
	assert_true(d.modifiers.any(func(l): return l.key == "crit_chance_pct" and float(l.value) == 5.0), "crit comes")
	assert_false(d.modifiers.any(func(l): return l.key == "cultivation_speed_pct"), "cultivation speed stays out")
	var p: FighterProfile = FighterCompiler.compile(c, gd, db, sheet)
	assert_true(p.effects.any(func(e): return e.id == "tech:character"), "the sheet's lines run as one Effect")


func test_a_piece_past_the_slot_count_is_not_compiled() -> void:
	# Qi Refining with 50 thần hồn has two extra slots (equip_control_test): the third piece is past the count
	var gd := game_data()
	var db := WorldDB.new()
	var c := TestFixtures.character({"hoa": 50}, 50, 0)
	var a: String = _ordinary(db, [])
	var b: String = _ordinary(db, [])
	var past: String = _ordinary(db, [{"id": "x", "word": "", "stat": "crit_chance_pct", "value": 9.0}])
	c.equipped = [a, b, past]
	var d: Dictionary = FighterCompiler.character_build_file(c, gd, db, StatSheet.build(c, gd, db, null))
	assert_false(d.modifiers.any(func(l): return l.key == "crit_chance_pct"), "the third extra piece adds nothing")
