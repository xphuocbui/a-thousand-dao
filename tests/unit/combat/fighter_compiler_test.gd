extends DaoTestSuite
## FighterCompiler (ADR-0001 decision 2): the reference fighters come from game data, written by the design tool from
## fight.py's own definitions, and fight exactly as the parity fixtures built from the same path do.


func test_every_reference_fighter_loads_at_every_realm() -> void:
	var gd := game_data()
	for kind in ["typical", "top_end", "top_end_the_tu"]:
		for r in 5:
			var errors: Array = []
			var p: FighterProfile = FighterCompiler.from_data(kind, r, gd, errors)
			assert_true(p != null and errors.is_empty(), "%s realm %d loads: %s" % [kind, r, "; ".join(errors)])
			if p != null:
				assert_eq(p.realm, r, "%s realm %d has its realm" % [kind, r])
				assert_eq(p.arts.size(), 3, "%s realm %d carries the reference kit" % [kind, r])


func test_an_unknown_reference_fighter_is_refused_by_name() -> void:
	var errors: Array = []
	assert_true(FighterCompiler.from_data("dragon", 0, game_data(), errors) == null, "refused")
	assert_true("; ".join(errors).contains("dragon"), "names it")
	var errors2: Array = []
	assert_true(FighterCompiler.from_data("typical", 7, game_data(), errors2) == null, "realm 7 refused")


func test_the_constants_come_through_game_data() -> void:
	var k: CombatConstants = CombatConstants.from_game_data(game_data())
	var direct: CombatConstants = CombatConstants.load_file()
	assert_true(k.errors.is_empty(), "loads through GameData")
	assert_eq(k.pulse_ms, direct.pulse_ms, "the same constants as the file read directly")
	assert_eq(k.time_limit_ms, direct.time_limit_ms, "the same constants as the file read directly")


func test_a_data_built_typical_mirror_fights_as_its_parity_fixture() -> void:
	# The game-data typical enemy and the t6 parity fixture come from the same fight.py path, so a fight between them
	# at the same seed must be identical, row for row.
	var gd := game_data()
	var k: CombatConstants = CombatConstants.from_game_data(gd)
	var errors: Array = []
	var pa: FighterProfile = FighterCompiler.from_data("typical", 2, gd, errors)
	var pb: FighterProfile = FighterCompiler.from_data("typical", 2, gd, errors)
	var doc: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/parity/expected/t6_typical_mirror_r2.json"))
	var loader := FighterProfileLoader.new(k)
	var fa: FighterProfile = loader.from_sim_build(doc.a, "a")
	var fb: FighterProfile = loader.from_sim_build(doc.b, "b")
	assert_true(errors.is_empty() and loader.errors.is_empty(), "both load")
	for s in 10:
		var r1: FightResult = Fight.new(pa, pb, k, s, Fight.Order.COIN, true).run()
		var r2: FightResult = Fight.new(fa, fb, k, s, Fight.Order.COIN, true).run()
		assert_eq(r1.t_ms, r2.t_ms, "seed %d: same end" % s)
		assert_eq(r1.log_rows.size(), r2.log_rows.size(), "seed %d: same rows" % s)
