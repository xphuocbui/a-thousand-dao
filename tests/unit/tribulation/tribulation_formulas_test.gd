extends DaoTestSuite
## Heavenly Tribulation logging, formulas, and balance harness primitives
## (design/gdd/thien-kiep.md, AC-TK-58..66).


static func _fx_pool() -> Array:
	return [
		{"id": "B1", "name": "Body Boss 1", "main_kind": "body", "weight": 2.0, "boss_pool_mult": 1.0, "reward": {"kind": "material", "template": "loi_kich_moc", "qty": 1, "rarity": 5}},
		{"id": "B2", "name": "Body Boss 2", "main_kind": "body", "weight": 1.0, "boss_pool_mult": 1.0, "reward": {"kind": "material", "template": "tu_kim_sa", "qty": 1, "rarity": 5}},
		{"id": "Q1", "name": "Qi Boss 1", "main_kind": "qi", "weight": 2.0, "boss_pool_mult": 1.0, "reward": {"kind": "material", "template": "dia_hoa_tinh", "qty": 1, "rarity": 4}},
		{"id": "Q2", "name": "Qi Boss 2", "main_kind": "qi", "weight": 1.0, "boss_pool_mult": 1.0, "reward": {"kind": "treasure", "template": "dao_an", "qty": 1, "rarity": 4}},
		{"id": "S1", "name": "Soul Boss 1", "main_kind": "soul", "weight": 2.0, "boss_pool_mult": 1.0, "reward": {"kind": "treasure", "template": "linh_can_qua", "qty": 1, "rarity": 5}},
		{"id": "S2", "name": "Soul Boss 2", "main_kind": "soul", "weight": 1.0, "boss_pool_mult": 1.0, "reward": {"kind": "talisman", "template": "pha_canh", "qty": 1, "rarity": 4}},
	]


func test_wave_summaries_and_full_combat_logs_kept_ac58_ac59() -> void:
	var gd := game_data()
	var prof := FighterCompiler.from_data("typical", 3, gd)
	var fn := func(_req: FightRequest, ctx: Dictionary) -> FightResult:
		var r := FightResult.new()
		r.winner = FightResult.Winner.A
		r.ending = FightResult.Ending.KNOCKOUT
		r.seconds = 10.0 + float(ctx.wave)
		r.deciding_layer = int(ctx.wave) % 3
		r.a_end = FighterEnd.new()
		r.a_end.health = 4000.0
		r.a_end.health_max = 6400.0
		r.a_end.linh_luc = 1500.0
		r.a_end.linh_luc_base = 2600.0
		r.b_end = FighterEnd.new()
		var row := FightLogRow.new()
		row.kind = FightLogRow.Kind.HIT
		row.t_ms = 1000 * int(ctx.wave)
		row.side = "A"
		row.art_id = &"test_strike"
		r.log_rows = [row]
		return r

	var out: Dictionary = TribulationRunner.run({
		"world_seed": 12,
		"char_id": "p1",
		"step_id": "nguyen_anh_to_hoa_than",
		"pool": _fx_pool(),
		"player_profile": prof,
		"abs_season": 5,
		"log_enabled": true,
	}, gd, fn)
	assert_true(out.ok and out.survived, "run survived")
	assert_eq(int(out.waves_cleared), 3, "waves_cleared = 3")
	assert_eq(str(out.final_ending), "survived", "final_ending = survived")
	assert_eq(out.waves.size(), 3, "3 wave entries")
	for w in out.waves:
		for field in ["boss_id", "boss_name", "ending", "seconds", "health_end", "qi_end", "deciding_layer", "log_rows"]:
			assert_true(w.has(field), "AC-TK-58 wave has %s" % field)
		assert_eq((w.log_rows as Array).size(), 1, "AC-TK-59 full Combat log kept per wave")


func test_effective_pool_mult_and_cap_log_ac60_ac61() -> void:
	# AC-TK-60: mult 1.2, ramp 1.5 -> 1.2, 1.8, 2.7
	assert_near(float(TribulationRules.effective_pool_mult(1.2, 1.5, 1, 10.0).m_eff), 1.2, 0.0001, "wave 1")
	assert_near(float(TribulationRules.effective_pool_mult(1.2, 1.5, 2, 10.0).m_eff), 1.8, 0.0001, "wave 2")
	assert_near(float(TribulationRules.effective_pool_mult(1.2, 1.5, 3, 10.0).m_eff), 2.7, 0.0001, "wave 3")
	# AC-TK-61: mult 1.5, ramp 2.0, k = 5 -> raw 24, capped at 10
	var cap_info: Dictionary = TribulationRules.effective_pool_mult(1.5, 2.0, 5, 10.0)
	assert_near(float(cap_info.raw), 24.0, 0.0001, "raw = 24")
	assert_near(float(cap_info.m_eff), 10.0, 0.0001, "capped at 10")
	assert_true(bool(cap_info.capped), "capped flag true")
	# Runner logs the cap note
	var gd := game_data()
	var pool := _fx_pool()
	for b in pool:
		b["boss_pool_mult"] = 1.5
	var prof := FighterCompiler.from_data("typical", 3, gd)
	var win_fn := func(_req: FightRequest) -> FightResult:
		var r := FightResult.new()
		r.winner = FightResult.Winner.A
		r.ending = FightResult.Ending.KNOCKOUT
		r.a_end = FighterEnd.new()
		r.a_end.health = 5000.0
		r.a_end.health_max = 6400.0
		r.a_end.linh_luc = 2000.0
		r.a_end.linh_luc_base = 2600.0
		r.b_end = FighterEnd.new()
		return r
	var out: Dictionary = TribulationRunner.run({
		"world_seed": 1,
		"char_id": "cap_test",
		"step_id": "nguyen_anh_to_hoa_than",
		"pool": pool,
		"player_profile": prof,
		"rules_override": {"wave_count": 5, "pool_ramp": 2.0, "m_cap": 10.0},
	}, gd, win_fn)
	assert_true(out.ok and out.survived, "5-wave capped run completes")
	assert_near(float(out.waves[4].m_eff), 10.0, 0.0001, "wave 5 m_eff stopped at 10")
	assert_true(bool(out.waves[4].m_capped), "wave 5 marked capped")
	assert_true("; ".join(out.notes).contains("capped"), "AC-TK-61 log says m_eff was capped")


func test_roll_target_and_wave_loss_formulas_ac62_ac63_ac64() -> void:
	# AC-TK-62: p_t_ref 0.90, 0.84, 0.10, 1.0 -> 0.22222, 0.23810, 1.0, 0.20
	assert_near(TribulationRules.roll_target(0.90), 0.22222, 0.0001, "0.90 -> 0.22222")
	assert_near(TribulationRules.roll_target(0.84), 0.23810, 0.0001, "0.84 -> 0.23810")
	assert_near(TribulationRules.roll_target(0.10), 1.0, 0.0001, "0.10 -> 1.0")
	assert_near(TribulationRules.roll_target(1.0), 0.20, 0.0001, "1.0 -> 0.20")
	# AC-TK-63: FX-B (400 * 8000 = 3.2e6) vs FX-P (1500 * 9400 = 1.41e7)
	var est: Dictionary = TribulationRules.wave_loss_estimate(400.0 * 8000.0, 1500.0 * 9400.0, 3, 1.5)
	assert_near(float(est.r_b), 0.22695, 0.0001, "r_b")
	assert_near(float(est.losses[0]), 0.22695, 0.0001, "loss_1")
	assert_near(float(est.losses[1]), 0.34043, 0.0001, "loss_2")
	assert_near(float(est.losses[2]), 0.51064, 0.0001, "loss_3")
	# AC-TK-64: sum 1.07801 fails; r_b 0.21 sum 0.9975 does not fail
	assert_near(float(est.total_loss), 1.07801, 0.0001, "sum 1.07801")
	assert_true(bool(est.fails), "1.07801 reads as failing")
	var est_ok: Dictionary = TribulationRules.wave_loss_estimate(0.21, 1.0, 3, 1.5)
	assert_near(float(est_ok.total_loss), 0.9975, 0.0001, "0.21 * 4.75 = 0.9975")
	assert_false(bool(est_ok.fails), "0.9975 reads as not failing")


func test_harness_measure_and_summarize_ac65_ac66() -> void:
	var gd := game_data()
	var prof := FighterCompiler.from_data("typical", 3, gd)
	# AC-TK-65: FX-STUB losing only to S1 over N = 4,000 -> p_t_hat ~ 0.37381 +/- 0.005
	var lose_s1 := func(_req: FightRequest, ctx: Dictionary) -> FightResult:
		var r := FightResult.new()
		r.ending = FightResult.Ending.KNOCKOUT
		r.winner = FightResult.Winner.B if str(ctx.boss.id) == "S1" else FightResult.Winner.A
		r.a_end = FighterEnd.new()
		r.a_end.health = 0.0 if r.winner == FightResult.Winner.B else 5000.0
		r.a_end.health_max = 6400.0
		r.a_end.linh_luc = 1500.0
		r.a_end.linh_luc_base = 2600.0
		r.b_end = FighterEnd.new()
		return r
	var m: Dictionary = TribulationHarness.measure(gd, prof, "nguyen_anh_to_hoa_than", 4000, 1000, lose_s1, {"pool": _fx_pool()})
	assert_eq(int(m.n), 4000, "N = 4000")
	assert_near(float(m.p_t_hat), 0.37381, 0.02, "AC-TK-65 p_t_hat matches 1 - 0.62619")
	assert_eq(int(m.by_boss_kind.get("soul", 0)), int(m.failed), "all failures attributed to soul boss S1")

	# AC-TK-66: 3600 / 4000 -> 0.90, SE 0.00474
	var sum := TribulationHarness.summarize(4000, 3600, {"knockout": 300, "draw": 100}, {1: 50, 2: 150, 3: 200}, {"body": 100, "qi": 150, "soul": 150})
	assert_near(float(sum.p_t_hat), 0.90, 0.0001, "AC-TK-66 p_t_hat = 0.90")
	assert_near(float(sum.se), 0.00474, 0.0001, "AC-TK-66 SE = 0.00474")
	assert_eq(int(sum.by_ending.draw), 100, "by_ending preserved")
	assert_eq(int(sum.by_wave[3]), 200, "by_wave preserved")
	assert_eq(int(sum.by_boss_kind.soul), 150, "by_boss_kind preserved")
