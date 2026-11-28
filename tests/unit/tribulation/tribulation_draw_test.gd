extends DaoTestSuite
## Heavenly Tribulation boss draw and deterministic seeding (design/gdd/thien-kiep.md, AC-TK-13..21).


static func _fx_pool() -> Array:
	return [
		{"id": "B1", "name": "Body Boss 1", "main_kind": "body", "weight": 2.0, "boss_pool_mult": 1.0, "reward": {"kind": "material", "template": "loi_kich_moc", "qty": 1, "rarity": 5}},
		{"id": "B2", "name": "Body Boss 2", "main_kind": "body", "weight": 1.0, "boss_pool_mult": 1.0, "reward": {"kind": "material", "template": "tu_kim_sa", "qty": 1, "rarity": 5}},
		{"id": "Q1", "name": "Qi Boss 1", "main_kind": "qi", "weight": 2.0, "boss_pool_mult": 1.0, "reward": {"kind": "material", "template": "dia_hoa_tinh", "qty": 1, "rarity": 4}},
		{"id": "Q2", "name": "Qi Boss 2", "main_kind": "qi", "weight": 1.0, "boss_pool_mult": 1.0, "reward": {"kind": "treasure", "template": "dao_an", "qty": 1, "rarity": 4}},
		{"id": "S1", "name": "Soul Boss 1", "main_kind": "soul", "weight": 2.0, "boss_pool_mult": 1.0, "reward": {"kind": "treasure", "template": "linh_can_qua", "qty": 1, "rarity": 5}},
		{"id": "S2", "name": "Soul Boss 2", "main_kind": "soul", "weight": 1.0, "boss_pool_mult": 1.0, "reward": {"kind": "talisman", "template": "pha_canh", "qty": 1, "rarity": 4}},
	]


static func _stub_win(req: FightRequest) -> FightResult:
	var r := FightResult.new()
	r.winner = FightResult.Winner.A
	r.ending = FightResult.Ending.KNOCKOUT
	r.seconds = 10.0
	r.deciding_layer = 0
	r.a_end = FighterEnd.new()
	r.a_end.health = 5000.0
	r.a_end.health_max = 6400.0
	r.a_end.linh_luc = 1500.0
	r.a_end.linh_luc_base = 2600.0
	r.b_end = FighterEnd.new()
	return r


func test_thousand_seeds_draw_three_distinct_bosses_ac13() -> void:
	var pool := _fx_pool()
	for s in 1000:
		var tk_id: int = TribulationRules.tribulation_id(42, "hero", "nguyen_anh_to_hoa_than", s, 999)
		var drawn: Array = TribulationRules.draw_waves(pool, 3, tk_id)
		assert_eq(drawn.size(), 3, "seed %d draws 3 bosses" % s)
		var ids := {}
		for b in drawn:
			ids[b.id] = true
		assert_eq(ids.size(), 3, "seed %d draws 3 distinct bosses" % s)


func test_ten_thousand_seeds_match_weighted_odds_ac14_ac15() -> void:
	var pool := _fx_pool()
	var n: int = 10000
	var wave1_counts := {"B1": 0, "B2": 0, "Q1": 0, "Q2": 0, "S1": 0, "S2": 0}
	var in_list_counts := {"B1": 0, "B2": 0, "Q1": 0, "Q2": 0, "S1": 0, "S2": 0}
	for s in n:
		var tk_id: int = TribulationRules.tribulation_id(777, "hero", "nguyen_anh_to_hoa_than", s, 12345)
		var drawn: Array = TribulationRules.draw_waves(pool, 3, tk_id)
		var first_id: String = str(drawn[0].id)
		wave1_counts[first_id] = int(wave1_counts[first_id]) + 1
		for b in drawn:
			var bid: String = str(b.id)
			in_list_counts[bid] = int(in_list_counts[bid]) + 1
	# AC-TK-14: wave 1 weight-2 = 2/9 (0.2222), weight-1 = 1/9 (0.1111) +/- 0.02
	for bid in ["B1", "Q1", "S1"]:
		assert_near(float(wave1_counts[bid]) / float(n), 0.2222, 0.02, "wave 1 odds for weight-2 %s" % bid)
		assert_near(float(in_list_counts[bid]) / float(n), 0.6262, 0.02, "inclusion odds for weight-2 %s" % bid)
	for bid in ["B2", "Q2", "S2"]:
		assert_near(float(wave1_counts[bid]) / float(n), 0.1111, 0.02, "wave 1 odds for weight-1 %s" % bid)
		assert_near(float(in_list_counts[bid]) / float(n), 0.3738, 0.02, "inclusion odds for weight-1 %s" % bid)


func test_twenty_seasons_produce_at_least_five_distinct_lists_ac16() -> void:
	var pool := _fx_pool()
	var lists := {}
	for season in 20:
		var tk_id: int = TribulationRules.tribulation_id(100, "hero", "nguyen_anh_to_hoa_than", season, 555)
		var drawn: Array = TribulationRules.draw_waves(pool, 3, tk_id)
		var key: String = "%s|%s|%s" % [drawn[0].id, drawn[1].id, drawn[2].id]
		lists[key] = true
	assert_true(lists.size() >= 5, "20 seasons yield >= 5 distinct lists, got %d" % lists.size())


func test_setup_hash_sensitivity_and_stability_ac17_ac21() -> void:
	var gd := game_data()
	var pool := _fx_pool()
	var prof := FighterCompiler.from_data("typical", 3, gd)
	var prep_a := {"ward": "iron", "slots": ["a1", "a2", "a3"], "place_id": "p1"}
	var prep_b := {"place_id": "p1", "slots": ["a1", "a2", "a3"], "ward": "iron"}
	var h1: int = TribulationRules.setup_hash(prof, prep_a)
	var h2: int = TribulationRules.setup_hash(prof, prep_b)
	assert_eq(h1, h2, "identical setup (even different dict key order) yields identical setup_hash (AC-TK-21)")
	var tk1: int = TribulationRules.tribulation_id(101, "p0", "nguyen_anh_to_hoa_than", 40, h1)
	var tk2: int = TribulationRules.tribulation_id(101, "p0", "nguyen_anh_to_hoa_than", 40, h2)
	assert_eq(tk1, tk2, "reloaded save with unchanged setup yields identical tribulation_id")
	assert_eq(TribulationRules.draw_waves(pool, 3, tk1), TribulationRules.draw_waves(pool, 3, tk2), "identical lists")

	var lists := {}
	for i in 20:
		var p_mod := {"ward": "iron", "slots": ["art_%d" % i, "a2", "a3"], "place_id": "p1"}
		var hi: int = TribulationRules.setup_hash(prof, p_mod)
		var tki: int = TribulationRules.tribulation_id(101, "p0", "nguyen_anh_to_hoa_than", 40, hi)
		var drawn: Array = TribulationRules.draw_waves(pool, 3, tki)
		lists["%s|%s|%s" % [drawn[0].id, drawn[1].id, drawn[2].id]] = true
	assert_true(lists.size() >= 5, "20 single-slot setup diffs yield >= 5 distinct lists, got %d" % lists.size())


func test_wave1_log_names_no_later_boss_ac18() -> void:
	var gd := game_data()
	var pool := _fx_pool()
	var prof := FighterCompiler.from_data("typical", 3, gd)
	var wave1_header := ""
	var wave1_ctx_str := ""
	var on_start := func(k: int, _boss: Dictionary, header: String) -> void:
		if k == 1:
			wave1_header = header
	var fn := func(req: FightRequest, ctx: Dictionary) -> FightResult:
		if int(ctx.wave) == 1:
			wave1_ctx_str = str(ctx)
		return _stub_win(req)
	var out: Dictionary = TribulationRunner.run({
		"world_seed": 7,
		"char_id": "p1",
		"step_id": "nguyen_anh_to_hoa_than",
		"pool": pool,
		"player_profile": prof,
		"abs_season": 12,
		"on_wave_start": on_start,
	}, gd, fn)
	assert_true(out.ok and out.survived, "run completed")
	var b2_id: String = str(out.waves[1].boss_id)
	var b2_name: String = str(out.waves[1].boss_name)
	var b3_id: String = str(out.waves[2].boss_id)
	var b3_name: String = str(out.waves[2].boss_name)
	assert_false(wave1_header.contains(b2_id) or wave1_header.contains(b2_name), "wave 1 header hides wave 2 boss")
	assert_false(wave1_header.contains(b3_id) or wave1_header.contains(b3_name), "wave 1 header hides wave 3 boss")
	assert_false(wave1_ctx_str.contains(b2_id) or wave1_ctx_str.contains(b3_id), "wave 1 ctx hides later bosses")


func test_wave_seeds_differ_and_outer_rng_untouched_ac19_ac20() -> void:
	var gd := game_data()
	var pool := _fx_pool()
	var tk_id: int = TribulationRules.tribulation_id(55, "hero", "nguyen_anh_to_hoa_than", 9, 777)
	var s1: int = TribulationRules.wave_seed(tk_id, 1)
	var s2: int = TribulationRules.wave_seed(tk_id, 2)
	var s3: int = TribulationRules.wave_seed(tk_id, 3)
	assert_true(s1 != s2 and s2 != s3 and s1 != s3, "wave 1-3 seeds all differ")

	var outer := rng(98765)
	var state_before: int = outer.state
	var prof := FighterCompiler.from_data("typical", 3, gd)
	var out: Dictionary = TribulationRunner.run({
		"world_seed": 55,
		"char_id": "hero",
		"step_id": "nguyen_anh_to_hoa_than",
		"pool": pool,
		"player_profile": prof,
		"abs_season": 9,
	}, gd, _stub_win)
	assert_true(out.ok, "run ok")
	assert_eq(outer.state, state_before, "outer RNG state unchanged after full run")
