extends DaoTestSuite
## Heavenly Tribulation wave endings (design/gdd/thien-kiep.md, AC-TK-38..43).


static func _fx_pool() -> Array:
	return [
		{"id": "B1", "name": "B1", "main_kind": "body", "weight": 2.0, "boss_pool_mult": 1.0, "reward": {"kind": "material", "template": "loi_kich_moc", "qty": 1, "rarity": 5}},
		{"id": "Q1", "name": "Q1", "main_kind": "qi", "weight": 2.0, "boss_pool_mult": 1.0, "reward": {"kind": "material", "template": "dia_hoa_tinh", "qty": 1, "rarity": 4}},
		{"id": "S1", "name": "S1", "main_kind": "soul", "weight": 2.0, "boss_pool_mult": 1.0, "reward": {"kind": "treasure", "template": "dao_an", "qty": 1, "rarity": 4}},
	]


static func _make_result(winner: FightResult.Winner, ending: FightResult.Ending, a_hp: float, a_hp_max: float, b_hp: float = 0.0, sec: float = 12.0, wound: FighterEnd.Wound = FighterEnd.Wound.NONE) -> FightResult:
	var r := FightResult.new()
	r.winner = winner
	r.ending = ending
	r.seconds = sec
	r.deciding_layer = 0 if ending == FightResult.Ending.KNOCKOUT else -1
	r.a_end = FighterEnd.new()
	r.a_end.health = a_hp
	r.a_end.health_max = a_hp_max
	r.a_end.linh_luc = 1200.0
	r.a_end.linh_luc_base = 2600.0
	r.a_end.wound = wound
	r.b_end = FighterEnd.new()
	r.b_end.health = b_hp
	r.b_end.health_max = 8000.0
	return r


func _run_with_wave2(wave2_res: FightResult, health_max: float = 6400.0) -> Dictionary:
	var gd := game_data()
	var prof := FighterCompiler.from_data("typical", 3, gd)
	var req_count := [0]
	var wave3_h := [-1.0]
	var fn := func(req: FightRequest, ctx: Dictionary) -> FightResult:
		req_count[0] += 1
		var w: int = int(ctx.wave)
		if w == 2:
			return wave2_res
		if w == 3:
			wave3_h[0] = req.start_health_share
		return _make_result(FightResult.Winner.A, FightResult.Ending.KNOCKOUT, health_max * 0.8, health_max)
	var out: Dictionary = TribulationRunner.run({
		"world_seed": 21,
		"char_id": "p1",
		"step_id": "nguyen_anh_to_hoa_than",
		"pool": _fx_pool(),
		"player_profile": prof,
		"abs_season": 3,
	}, gd, fn)
	out["_req_count"] = req_count[0]
	out["_wave3_h"] = wave3_h[0]
	return out


func test_player_down_fails_and_stops_wave3_ac38() -> void:
	var out := _run_with_wave2(_make_result(FightResult.Winner.B, FightResult.Ending.KNOCKOUT, 0.0, 6400.0, 2000.0))
	assert_false(out.survived, "player Down fails tribulation")
	assert_eq(out.final_ending, "failed", "final ending is failed")
	assert_eq(int(out.waves_cleared), 1, "only wave 1 cleared")
	assert_eq(int(out._req_count), 2, "no wave 3 request sent")
	assert_true(out.reward_choices.is_empty(), "no rewards on failure")
	assert_true(out.tempered_buff.is_empty(), "no buff on failure")


func test_draw_with_grave_wound_fails_ac39() -> void:
	var out := _run_with_wave2(_make_result(FightResult.Winner.DRAW, FightResult.Ending.DRAW, 1.0, 6400.0, 1.0, 25.0, FighterEnd.Wound.GRAVE))
	assert_false(out.survived, "draw at 1 health wound: grave fails tribulation")
	assert_eq(int(out._req_count), 2, "no wave 3 request sent")


func test_fatigue_mutual_down_and_larger_boss_pool_fail_ac40() -> void:
	# Part 1: scripted mutual fatigue draw at 66 s -> Failed
	var out := _run_with_wave2(_make_result(FightResult.Winner.DRAW, FightResult.Ending.DRAW, 0.0, 6400.0, 0.0, 66.0))
	assert_false(out.survived, "mutual fatigue down at 66 s fails tribulation")
	assert_eq(int(out._req_count), 2, "no wave 3 request sent")

	# Part 2: real Combat fight where both sides deal negligible damage and boss has larger pool -> player falls to fatigue first
	var gd := game_data()
	var k := CombatConstants.from_game_data(gd)
	var player := FighterProfile.new()
	player.id = "tank_player"
	player.realm = 3
	player.m = 0.01
	player.n_body = 1.0
	player.n_qi = 1.0
	player.ward_pts = 5000.0
	player.block = 5000.0

	var boss := FighterProfile.new()
	boss.id = "larger_boss"
	boss.realm = 4
	boss.boss = true
	boss.m = 0.01
	boss.n_body = 2.0
	boss.n_qi = 2.0
	boss.ward_pts = 5000.0
	boss.block = 5000.0

	var req := FightRequest.new()
	req.a = player
	req.b = boss
	req.no_heal = true
	req.fight_seed = 42
	var res: FightResult = CombatService.new(k).resolve(req)
	assert_true(res != null, "fatigue fight resolves")
	assert_true(res.seconds >= k.fatigue_start, "fight ran into fatigue past %.0f s (got %.1f s)" % [k.fatigue_start, res.seconds])
	assert_true(res.winner != FightResult.Winner.A, "player falls to fatigue first against larger boss pool")
	assert_eq(res.deciding_layer, 3, "fatigue deciding_layer recorded")


func test_flight_with_boss_alive_fails_ac41() -> void:
	var out := _run_with_wave2(_make_result(FightResult.Winner.DRAW, FightResult.Ending.FLIGHT, 4000.0, 6400.0, 1200.0))
	assert_false(out.survived, "player flight with boss alive fails tribulation")
	assert_eq(int(out._req_count), 2, "no wave 3 request sent")


func test_flight_with_boss_zero_ko_win_clears_ac42() -> void:
	# Combat rule 10: if player fled on the same instant boss reached 0 HP, Combat reports Winner.A + Ending.KNOCKOUT
	var out := _run_with_wave2(_make_result(FightResult.Winner.A, FightResult.Ending.KNOCKOUT, 3200.0, 6400.0, 0.0))
	assert_true(out.survived, "flight with boss HP 0 reported as knockout win clears the wave")
	assert_eq(int(out.waves_cleared), 3, "all 3 waves cleared")
	assert_eq(int(out._req_count), 3, "wave 3 ran")


func test_double_ko_win_clears_and_carries_one_health_ac43() -> void:
	# Legacy 1600 health_max -> 1 / 1600 = 0.000625
	var out_1600 := _run_with_wave2(_make_result(FightResult.Winner.A, FightResult.Ending.KNOCKOUT, 0.0, 1600.0, -50.0), 1600.0)
	assert_true(out_1600.survived, "double-KO win clears wave 2")
	assert_true(bool(out_1600.waves[1].double_ko_win), "flagged as double_ko_win")
	assert_near(float(out_1600._wave3_h), 0.000625, 0.00001, "AC-TK-43: 1 / 1600 = 0.000625")
	# #44 6400 health_max -> 1 / 6400 = 0.00015625
	var out_6400 := _run_with_wave2(_make_result(FightResult.Winner.A, FightResult.Ending.KNOCKOUT, 0.0, 6400.0, -50.0), 6400.0)
	assert_true(out_6400.survived, "double-KO win clears wave 2 at 6400 HP")
	assert_near(float(out_6400._wave3_h), 1.0 / 6400.0, 0.00001, "1 / 6400 = 0.00015625")
