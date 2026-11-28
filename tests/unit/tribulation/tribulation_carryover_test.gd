extends DaoTestSuite
## Heavenly Tribulation carry-over formulas & stock/pill persistence (design/gdd/thien-kiep.md, AC-TK-25..32).


static func _fx_pool() -> Array:
	return [
		{"id": "B1", "name": "B1", "main_kind": "body", "weight": 2.0, "boss_pool_mult": 1.0, "reward": {"kind": "material", "template": "loi_kich_moc", "qty": 1, "rarity": 5}},
		{"id": "Q1", "name": "Q1", "main_kind": "qi", "weight": 2.0, "boss_pool_mult": 1.0, "reward": {"kind": "material", "template": "dia_hoa_tinh", "qty": 1, "rarity": 4}},
		{"id": "S1", "name": "S1", "main_kind": "soul", "weight": 2.0, "boss_pool_mult": 1.0, "reward": {"kind": "treasure", "template": "dao_an", "qty": 1, "rarity": 4}},
	]


func test_health_carryover_exact_ac25() -> void:
	var c: Dictionary = TribulationRules.carry_over_shares(2800.0, 6400.0, 1000.0, 2600.0, 8, 0.035, 0.08, 0.0)
	assert_near(float(c.h_next), 0.4375, 0.0001, "2800 / 6400 = 0.4375")


func test_qi_carryover_base_and_log_curve_ac26_ac27() -> void:
	# AC-TK-26: 300 / 2600 + 8 * 0.035 = 0.1153846 + 0.28 = 0.39538
	var c0: Dictionary = TribulationRules.carry_over_shares(3200.0, 6400.0, 300.0, 2600.0, 8, 0.035, 0.08, 0.0)
	assert_near(float(c0.q_next), 0.39538, 0.0001, "AC-TK-26 base regen 0.035")
	# AC-TK-27: regen_bonus 0.06 -> 0.75354; regen_bonus 0.10 -> 0.91438
	var c6: Dictionary = TribulationRules.carry_over_shares(3200.0, 6400.0, 300.0, 2600.0, 8, 0.035, 0.08, 0.06)
	assert_near(float(c6.q_next), 0.75354, 0.0001, "AC-TK-27 regen_bonus 0.06")
	var c10: Dictionary = TribulationRules.carry_over_shares(3200.0, 6400.0, 300.0, 2600.0, 8, 0.035, 0.08, 0.10)
	assert_near(float(c10.q_next), 0.91438, 0.0001, "AC-TK-27 regen_bonus 0.10")


func test_qi_carryover_cap_zero_and_curses_cleared_ac28_ac29_ac30() -> void:
	# AC-TK-28: 2400 -> capped at 1.0
	var c_cap: Dictionary = TribulationRules.carry_over_shares(3200.0, 6400.0, 2400.0, 2600.0, 8, 0.035, 0.08, 0.0)
	assert_near(float(c_cap.q_next), 1.0, 0.0001, "AC-TK-28 cap at 1.0")
	# AC-TK-29: qi_end = 0 -> rest_pulses * regen_base (0.28 at #44 0.035, 0.16 at legacy 0.02); rest_pulses = 0 -> 0
	var c_zero_44: Dictionary = TribulationRules.carry_over_shares(3200.0, 6400.0, 0.0, 2600.0, 8, 0.035, 0.08, 0.0)
	assert_near(float(c_zero_44.q_next), 0.28, 0.0001, "AC-TK-29 zero qi with #44 regen_base 0.035")
	var c_zero_legacy: Dictionary = TribulationRules.carry_over_shares(3200.0, 6400.0, 0.0, 2600.0, 8, 0.02, 0.08, 0.0)
	assert_near(float(c_zero_legacy.q_next), 0.16, 0.0001, "AC-TK-29 zero qi with legacy regen_base 0.02")
	var c_norest: Dictionary = TribulationRules.carry_over_shares(3200.0, 6400.0, 0.0, 2600.0, 0, 0.035, 0.08, 0.0)
	assert_near(float(c_norest.q_next), 0.0, 0.0001, "AC-TK-29 rest_pulses 0 gives 0")
	# AC-TK-30: regeneration curse does not carry; regeneration computes un-dampened
	var c_curse_44: Dictionary = TribulationRules.carry_over_shares(3200.0, 6400.0, 300.0, 2600.0, 8, 0.035, 0.08, 0.0)
	assert_near(float(c_curse_44.q_next), 0.39538, 0.0001, "AC-TK-30 un-dampened at 0.035")
	var c_curse_legacy: Dictionary = TribulationRules.carry_over_shares(3200.0, 6400.0, 300.0, 2600.0, 8, 0.02, 0.08, 0.0)
	assert_near(float(c_curse_legacy.q_next), 0.27538, 0.0001, "AC-TK-30 un-dampened at legacy 0.02")


func test_talisman_stock_and_prepared_pill_carry_across_waves_ac31_ac32() -> void:
	var gd := game_data()
	var prof := FighterCompiler.from_data("typical", 3, gd)
	# Pin regen_bonus = 0.0 so this AC-TK-26/31/32 fixture isolates base carry-over independently of typical-r3 Dao Do tuning.
	prof.regen_bonus = 0.0
	prof.pill = {"element": "fire", "grade": 3, "fail": false}
	var seen_stocks: Array = []
	var seen_pills: Array = []
	var seen_req_pills: Array = []
	var fn := func(req: FightRequest, ctx: Dictionary) -> FightResult:
		seen_stocks.append(int(ctx.stock.get("lei_fu", 0)))
		seen_pills.append((ctx.pill as Dictionary).duplicate(true))
		seen_req_pills.append(req.a.pill.duplicate(true))
		if int(ctx.wave) == 1:
			ctx.spent_out["lei_fu"] = 2
		var r := FightResult.new()
		r.winner = FightResult.Winner.A
		r.ending = FightResult.Ending.KNOCKOUT
		r.seconds = 8.0
		r.deciding_layer = 1
		r.a_end = FighterEnd.new()
		r.a_end.health = 2800.0
		r.a_end.health_max = 6400.0
		r.a_end.linh_luc = 300.0
		r.a_end.linh_luc_base = 2600.0
		r.b_end = FighterEnd.new()
		return r
	var out: Dictionary = TribulationRunner.run({
		"world_seed": 5,
		"char_id": "p1",
		"step_id": "nguyen_anh_to_hoa_than",
		"pool": _fx_pool(),
		"player_profile": prof,
		"prep": {"consumable_stock": {"lei_fu": 3}, "pill": {"element": "fire", "grade": 3, "fail": false}},
		"abs_season": 10,
	}, gd, fn)
	assert_true(out.ok and out.survived, "survived")
	assert_eq(seen_stocks, [3, 1, 1], "AC-TK-31: wave 1 spends 2 of 3, leaving stock 1 for waves 2 and 3")
	assert_eq(int(out.remaining_stock.get("lei_fu", -1)), 1, "remaining stock is 1")
	assert_eq(int(out.spent_stock.get("lei_fu", 0)), 2, "total spent stock is 2 for single post-run decrement")
	assert_eq(seen_pills.size(), 3, "3 waves saw prepared pill")
	for i in 3:
		assert_eq(str(seen_pills[i].get("element", "")), "fire", "AC-TK-32 wave %d ctx pill" % (i + 1))
		assert_eq(str(seen_req_pills[i].get("element", "")), "fire", "AC-TK-32 wave %d profile pill" % (i + 1))
	# Also verify wave 2 received carried health & qi shares
	assert_near(float(out.waves[1].start_h), 0.4375, 0.0001, "wave 2 start_h carried")
	assert_near(float(out.waves[1].start_q), 0.39538, 0.0001, "wave 2 start_q carried with rest regen")
