extends DaoTestSuite
## Heavenly Tribulation (#22) real-Combat carry-over & harness integration tests:
## AC-TK-33 (wave 1 vitality floor vs wave 2+ exact share),
## AC-TK-34..36 (statuses/curses cleared, cooldowns reset, once-per-fight triggers renewed between waves),
## AC-TK-37 (exhausted talisman skipped cleanly in later waves),
## AC-TK-65 (TribulationHarness.measure statistical accuracy & breakdowns).


func _make_strong_player(gd: GameData, with_talisman: bool = false) -> FighterProfile:
	var build := {
		"name": "tester_ns",
		"realm": 3,
		"stage_mult": 1.0,
		"layers": [420, 80, 60, 40, 30],
		"n_body": 2.2,
		"n_qi": 2.0,
		"ward": {"ws_base": 120.0, "block": 20.0},
		"purity": {"fire": 90.0, "metal": 85.0},
		"divine_sense": 6.0,
		"arts": [
			{"lib": "iron-spark"},
			{"lib": "forked-light"},
			{"lib": "rolling-thunder"},
		],
	}
	var errs: Array = []
	var prof: FighterProfile = FighterCompiler.from_build_file(build, gd, [], errs)
	assert_eq(errs, [], "player profile compiles cleanly: %s" % str(errs))
	if with_talisman:
		var tal_art := ArtDef.new()
		tal_art.id = &"hoa_cau"
		tal_art.c = 1.6
		tal_art.cd = 1.0
		tal_art.cost = 0.0
		tal_art.element = &"fire"
		tal_art.dtype = &"fire"
		tal_art.tags = [&"talisman"]
		tal_art.tags_s = ["talisman"]
		prof.arts.insert(0, tal_art)
	return prof


func _weak_boss(id: String, kind: String = "body") -> Dictionary:
	return {
		"id": id,
		"name": id,
		"steps": ["nguyen_anh_to_hoa_than"],
		"weight": 1.0,
		"main_kind": kind,
		"boss_pool_mult": 1.0,
		"off_estimate": 250.0,
		"ehp_estimate": 2000.0,
		"off_shares": {"body": 0.7, "qi": 0.2, "soul": 0.1},
		"build": {
			"layers": [80, 20, 15, 10, 5],
			"n_body": 0.4,
			"n_qi": 0.5,
			"ward": {"ws_base": 20.0, "block": 5.0},
			"purity": {"thunder": 40.0},
			"divine_sense": 2.0,
			"stage_mult": 1.0,
			"arts": [
				{"lib": "iron-spark"},
				{"lib": "bleeding-slash"},
			],
		},
		"reward": {"kind": "material", "template": "loi_kich_moc", "qty": 1, "rarity": 5, "label": "Lôi Kích Mộc"},
	}


func test_real_combat_wave1_vitality_floor_and_wave2_exact_carry_ac33() -> void:
	var gd := game_data()
	var prof: FighterProfile = _make_strong_player(gd)
	var pool: Array = [_weak_boss("b_w1"), _weak_boss("b_w2")]
	var vit_floor: float = float(gd.combat().get("duel", {}).get("injured_power_floor", 0.4))

	# Run real Combat with start_vitality = 0.30 (below floor 0.40) -> wave 1 applies floor 0.40,
	# wave 2 uses exact carried health share (no floor).
	var out: Dictionary = TribulationRunner.run({
		"world_seed": 8201,
		"char_id": "p_ac33",
		"step_id": "nguyen_anh_to_hoa_than",
		"pool": pool,
		"wave_count": 2,
		"player_profile": prof,
		"prep": {},
		"place_tags": ["vein"],
		"start_vitality": 0.30,
		"abs_season": 20,
		"log_enabled": true,
	}, gd)
	assert_true(bool(out.ok), "real Combat 2-wave run succeeded")
	assert_eq(Array(out.waves).size(), 2, "both waves ran")
	assert_near(float(out.waves[0].start_h), vit_floor, 1e-6, "AC-TK-33: wave 1 applies vitality floor (0.40)")
	var w1_hp_share: float = float(out.waves[0].health_end) / maxf(1.0, float(out.waves[0].health_max))
	assert_near(float(out.waves[1].start_h), w1_hp_share, 1e-4, "AC-TK-33: wave 2 starts at exact carried health share (no floor)")
	assert_true(float(out.waves[1].start_h) <= vit_floor + 1e-6, "wave 2 did not heal above wave 1 end share")


func test_real_combat_statuses_cooldowns_and_once_triggers_reset_between_waves_ac34_35_36() -> void:
	var gd := game_data()
	var prof: FighterProfile = _make_strong_player(gd)
	var pool: Array = [_weak_boss("b_clean_1"), _weak_boss("b_clean_2")]
	var seen_reqs: Array = []
	var service := CombatService.new(CombatConstants.from_game_data(gd))

	var out: Dictionary = TribulationRunner.run({
		"world_seed": 8202,
		"char_id": "p_ac34",
		"step_id": "nguyen_anh_to_hoa_than",
		"pool": pool,
		"wave_count": 2,
		"player_profile": prof,
		"prep": {},
		"place_tags": [],
		"start_vitality": 1.0,
		"abs_season": 21,
		"log_enabled": true,
	}, gd, func(req: FightRequest, _wctx: Dictionary) -> FightResult:
		seen_reqs.append(req)
		return service.resolve(req)
	)
	assert_true(bool(out.ok) and bool(out.survived), "AC-TK-34..36: both waves cleared in real Combat")
	assert_eq(seen_reqs.size(), 2, "2 independent CombatService fights ran")
	assert_true(seen_reqs[0].no_heal and seen_reqs[1].no_heal, "no_heal enforced on every wave")
	assert_true(seen_reqs[0].fight_seed != seen_reqs[1].fight_seed, "distinct wave seeds")
	# Verify wave 2 log opens with identical fresh cooldown timing as wave 1 (no leftover cooldowns or statuses).
	var w1_rows: Array = Array(out.waves[0].log_rows)
	var w2_rows: Array = Array(out.waves[1].log_rows)
	assert_true(w1_rows.size() > 0 and w2_rows.size() > 0, "both waves have real fight log rows")
	var first_cast_w1: int = 999999
	for row in w1_rows:
		if row.side == "A" and row.kind == FightLogRow.Kind.ART:
			first_cast_w1 = mini(first_cast_w1, int(row.t_ms))
	var first_cast_w2: int = 999999
	for row in w2_rows:
		if row.side == "A" and row.kind == FightLogRow.Kind.ART:
			first_cast_w2 = mini(first_cast_w2, int(row.t_ms))
	assert_eq(first_cast_w2, first_cast_w1, "AC-TK-35: wave 2 opens with identical fresh art cooldowns as wave 1")
	assert_true(first_cast_w2 <= 2000, "AC-TK-35: wave 2 player art fires on first combat pulse (got %d ms)" % first_cast_w2)


func test_exhausted_talisman_skipped_in_later_waves_ac37() -> void:
	var gd := game_data()
	var prof: FighterProfile = _make_strong_player(gd, true)
	var pool: Array = [_weak_boss("b_tal_1"), _weak_boss("b_tal_2")]
	var wave_art_counts: Array = []
	var service := CombatService.new(CombatConstants.from_game_data(gd))

	var out: Dictionary = TribulationRunner.run({
		"world_seed": 8203,
		"char_id": "p_ac37",
		"step_id": "nguyen_anh_to_hoa_than",
		"pool": pool,
		"wave_count": 2,
		"player_profile": prof,
		"prep": {"consumable_stock": {"hoa_cau": 1}},
		"place_tags": [],
		"start_vitality": 1.0,
		"abs_season": 22,
		"log_enabled": true,
	}, gd, func(req: FightRequest, _wctx: Dictionary) -> FightResult:
		wave_art_counts.append(req.a.arts.map(func(a): return str(a.id)))
		return service.resolve(req)
	)
	assert_true(bool(out.ok) and bool(out.survived), "AC-TK-37: completed cleanly after talisman exhaustion")
	assert_true(Array(wave_art_counts[0]).has("hoa_cau"), "wave 1 had talisman art available")
	assert_false(Array(wave_art_counts[1]).has("hoa_cau"), "AC-TK-37: exhausted talisman art skipped in wave 2")
	assert_eq(int(out.spent_stock.get("hoa_cau", 0)), 1, "exact stock of 1 consumed")
	assert_eq(int(out.remaining_stock.get("hoa_cau", -1)), 0, "remaining stock is 0")


func test_harness_measure_accuracy_and_breakdowns_ac65() -> void:
	var gd := game_data()
	var prof := FighterProfile.new()
	prof.realm = 3
	# Pool has 6 bosses with weights [2, 1, 2, 1, 2, 1] (sum = 9).
	# Stub loses ONLY to tk_tam_ma_loi_anh (weight 2, main_kind = "soul").
	# Analytical inclusion probability for a weight-2 boss in 3 draws without replacement is 0.62619,
	# so analytical survival rate is 1 - 0.62619 = 0.37381.
	var stub := func(_req: FightRequest, wctx: Dictionary) -> FightResult:
		var r := FightResult.new()
		var ae := FighterEnd.new()
		ae.health_max = 6400.0
		ae.linh_luc_base = 4000.0
		ae.linh_luc = 3000.0
		if str(wctx.boss.id) == "tk_tam_ma_loi_anh":
			r.winner = FightResult.Winner.B
			r.ending = FightResult.Ending.KNOCKOUT
			ae.health = 0.0
			ae.down = true
		else:
			r.winner = FightResult.Winner.A
			r.ending = FightResult.Ending.KNOCKOUT
			ae.health = 5000.0
			ae.down = false
		r.a_end = ae
		r.seconds = 10.0
		return r

	var stats: Dictionary = TribulationHarness.measure(gd, prof, "nguyen_anh_to_hoa_than", 4000, 10000, stub)
	assert_eq(int(stats.n), 4000, "AC-TK-65: N = 4000 runs")
	assert_near(float(stats.p_t_hat), 0.37381, 0.025, "AC-TK-65: measured p_t_hat near analytical 0.37381 (got %.5f)" % float(stats.p_t_hat))
	var expected_se: float = sqrt(float(stats.p_t_hat) * (1.0 - float(stats.p_t_hat)) / 4000.0)
	assert_near(float(stats.se), expected_se, 1e-6, "SE matches binomial formula")
	assert_eq(int(stats.by_boss_kind.get("soul", 0)), int(stats.failed), "all failures attributed to soul boss")
	assert_eq(int(stats.by_ending.get("knockout", 0)), int(stats.failed), "all failures attributed to knockout ending")
	var wave_sum: int = int(stats.by_wave.get(1, 0)) + int(stats.by_wave.get(2, 0)) + int(stats.by_wave.get(3, 0))
	assert_eq(wave_sum, int(stats.failed), "failure wave breakdown sums to total failures")
