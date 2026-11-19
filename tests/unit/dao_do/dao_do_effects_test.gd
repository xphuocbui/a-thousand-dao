extends DaoTestSuite
## The Đạo Đồ's keystone and crown Effects (ADR-0004 decision 3; design/gdd/effects.md "Đạo Đồ Effects"): the library
## holds every Effect the map names, closings reach the stat sheet, an Effect whose host is outside fights adds
## nothing, the fighter receives the held Effects by name, and every record compiles in the GDScript engine.

const UNYIELDING_BREATH := 4787   # keystone: refusal; closes maximum health -15 %
const MOUNTAINS_WEIGHT := 9009    # keystone: L5 by health lead; closes art speed -20 %
const SPIRIT_GARDEN := 6496       # keystone whose host (spirit fields, seasons) is outside fights
const HUNDRED_REFINEMENTS := 9012 # keystone: half the artifact power counts as attack


func _lib() -> Dictionary:
	return game_data().file("combat_effects").effects


func _holder(ids: Array, realm: int = 2) -> Character:
	var c := TestFixtures.character({"hoa": 60, "tho": 60}, 50, realm)
	c.tree_nodes.append_array(ids)
	return c


func test_every_effect_on_the_map_is_in_the_library() -> void:
	var names := {}
	for n in TestFixtures.tree().nodes.values():
		if str(n.get("effect", "")) != "":
			names[str(n.effect).split(" (")[0]] = true
	assert_eq(names.size(), 55, "43 keystones and 12 crown notables name 55 Effects")
	for name in names:
		assert_true(_lib().has(name), "%s has an engine form" % name)
		assert_eq(str(_lib()[name].get("source", "")), "Đạo Đồ", "%s is marked a Đạo Đồ Effect" % name)


func test_held_effects_follow_the_open_nodes() -> void:
	var c := _holder([MOUNTAINS_WEIGHT, UNYIELDING_BREATH])
	var held: Array = TestFixtures.tree().held_effects(c)
	assert_eq(held.size(), 2, "two held")
	assert_true(held.any(func(x): return str(x).begins_with("Mountain's Weight")), "Mountain's Weight")


func test_a_closing_reaches_the_sheet() -> void:
	var gd := game_data()
	var t := TestFixtures.tree()
	var c := _holder([UNYIELDING_BREATH])
	var sheet := StatSheet.build(c, gd, null, t)
	var src: String = "Đạo Đồ: %s" % str(t.node(UNYIELDING_BREATH).effect)
	var found: Array = sheet.sources("khi_huyet_pct").filter(func(m): return str(m.source) == src)
	assert_eq(found.size(), 1, "the closing line, under the Effect's name")
	assert_eq(float(found[0].value), -15.0, "maximum health -15 %")


func test_an_effect_outside_fights_adds_nothing() -> void:
	var gd := game_data()
	var t := TestFixtures.tree()
	var c := _holder([SPIRIT_GARDEN])
	var sheet := StatSheet.build(c, gd, null, t)
	var src: String = "Đạo Đồ: %s" % str(t.node(SPIRIT_GARDEN).effect)   # the keystone's own lines carry "#<id>"
	for key in sheet.stat_keys():
		for m in sheet.sources(key):
			assert_false(str(m.source) == src, "no line from the Pending Effect (%s)" % key)
	assert_true(str(_lib()["Spirit Garden"].get("not_run", "")) != "", "listed as not run, with its host")


func test_hundred_refinements_counts_half_the_artifact_power_as_attack() -> void:
	var gd := game_data()
	var t := TestFixtures.tree()
	var c := _holder([HUNDRED_REFINEMENTS])
	var sheet := StatSheet.build(c, gd, null, t)
	var src: String = "Đạo Đồ: %s" % str(t.node(HUNDRED_REFINEMENTS).effect)
	var from: Array = sheet.sources("attack_pct").filter(func(m): return str(m.source) == src)
	assert_eq(from.size(), 1, "one attack line")
	assert_near(float(from[0].value), 0.5 * sheet.total("artifact_power_pct"), 0.1, "half the artifact power")


func test_the_fighter_build_file_names_the_held_effects() -> void:
	var gd := game_data()
	var t := TestFixtures.tree()
	var c := _holder([MOUNTAINS_WEIGHT])
	var db := WorldDB.new()
	var d: Dictionary = FighterCompiler.character_build_file(c, gd, db, StatSheet.build(c, gd, db, t))
	assert_eq(d.tree_effects, [str(t.node(MOUNTAINS_WEIGHT).effect)], "named")
	assert_true(bool(d.tree_lines_on_sheet), "the sheet already holds the lines")
	assert_eq(int(d.counts.root_elements), 2, "owned base elements counted")
	var bfc := BuildFileCompiler.new(gd)
	var rec: Dictionary = bfc.compile(d)
	assert_true(not rec.is_empty(), "compiles: %s" % str(bfc.errors))
	assert_true(Array(rec.effects).any(func(e): return str(e.id) == "eff:Mountain's Weight"), "its record is in the fighter")


func test_every_tree_record_compiles_in_the_engine() -> void:
	var gd := game_data()
	var k := CombatConstants.from_game_data(gd)
	for name in _lib():
		var e: Dictionary = _lib()[name]
		if str(e.get("source", "")) != "Đạo Đồ":
			continue
		var counters := {}
		for cdef in e.get("counters", []):
			counters[str(cdef.id)] = true
		for r in e.get("records", []):
			var rec: Dictionary = (r as Dictionary).duplicate(true)
			rec.erase("fixed")
			var ec := EffectCompiler.new(k)
			var compiled: EffectDef = ec.compile(rec, "Đạo Đồ %s" % name, counters)
			assert_true(compiled != null and ec.errors.is_empty(), "%s %s: %s" % [name, str(r.id), str(ec.errors)])


func test_a_keystone_holder_fights() -> void:
	var gd := game_data()
	var t := TestFixtures.tree()
	var c := _holder([MOUNTAINS_WEIGHT, UNYIELDING_BREATH])
	var db := WorldDB.new()
	var errors: Array = []
	var me: FighterProfile = FighterCompiler.compile(c, gd, db, StatSheet.build(c, gd, db, t), [], errors)
	assert_true(me != null, "compiles and loads: %s" % str(errors))
	var foe: FighterProfile = FighterCompiler.from_data("typical", 2, gd, errors)
	var r: FightResult = Fight.new(me, foe, k_of(gd), 7).run()
	assert_true(r.seconds > 0.0, "a fight runs to an end")


func k_of(gd: GameData) -> CombatConstants:
	return CombatConstants.from_game_data(gd)
