extends DaoTestSuite
## Heavenly Tribulation data lint boundary checks (design/gdd/thien-kiep.md, AC-TK-68..79).


static func _fx_boss(id: String, kind: String, weight: float, reward_tpl: String, reward_kind: String = "material", reward_rarity: int = 4) -> Dictionary:
	var shares := {"body": 0.65, "qi": 0.25, "soul": 0.10}
	if kind == "qi":
		shares = {"body": 0.20, "qi": 0.65, "soul": 0.15}
	elif kind == "soul":
		shares = {"body": 0.25, "qi": 0.30, "soul": 0.45}
	return {
		"id": id,
		"name": id,
		"steps": ["nguyen_anh_to_hoa_than"],
		"weight": weight,
		"main_kind": kind,
		"boss_pool_mult": 1.0,
		"off_estimate": 400.0,
		"ehp_estimate": 8000.0,
		"off_shares": shares,
		"build": {
			"layers": [210, 35, 25, 15, 10],
			"n_body": 1.0,
			"n_qi": 1.0,
			"ward": {"ws_base": 75.0, "block": 12.0},
			"purity": {"thunder": 75.0},
			"divine_sense": 4.0,
			"arts": [{"lib": "iron-spark"}, {"lib": "forked-light"}],
		},
		"reward": {
			"kind": reward_kind,
			"template": reward_tpl,
			"qty": 1,
			"rarity": reward_rarity,
			"label": id,
		},
	}


static func _fx_pool() -> Array:
	return [
		_fx_boss("B1", "body", 2.0, "loi_kich_moc", "material", 5),
		_fx_boss("B2", "body", 1.0, "tu_kim_sa", "material", 5),
		_fx_boss("Q1", "qi", 2.0, "dia_hoa_tinh", "material", 4),
		_fx_boss("Q2", "qi", 1.0, "dao_an", "treasure", 4),
		_fx_boss("S1", "soul", 2.0, "linh_can_qua", "treasure", 5),
		_fx_boss("S2", "soul", 1.0, "pha_canh", "talisman", 4),
	]


func test_shipped_data_files_pass_lint_cleanly() -> void:
	var errs: PackedStringArray = TribulationRules.validate(game_data())
	assert_true(errs.is_empty(), "shipped tribulation_rules.json + tribulation_bosses.json pass lint: %s" % "; ".join(errs))


func test_multiplier_bounds_ac68() -> void:
	var gd := game_data()
	var p_lo := _fx_pool()
	p_lo[0].boss_pool_mult = 1.0
	assert_true(TribulationRules.lint(gd, {}, p_lo).is_empty(), "1.0 passes")
	var p_hi := _fx_pool()
	p_hi[0].boss_pool_mult = 1.5
	assert_true(TribulationRules.lint(gd, {}, p_hi).is_empty(), "1.5 passes")

	var p_bad_lo := _fx_pool()
	p_bad_lo[0].boss_pool_mult = 0.99
	assert_false(TribulationRules.lint(gd, {}, p_bad_lo).is_empty(), "0.99 rejected")
	var p_bad_hi := _fx_pool()
	p_bad_hi[0].boss_pool_mult = 1.51
	assert_false(TribulationRules.lint(gd, {}, p_bad_hi).is_empty(), "1.51 rejected")
	assert_false(TribulationRules.lint(gd, {"bm_max": 1.6}, _fx_pool()).is_empty(), "bm_max 1.6 > pool_ramp 1.5 rejected")


func test_ramp_bounds_ac69() -> void:
	var gd := game_data()
	assert_true(TribulationRules.lint(gd, {"wave_count": 5}, _fx_pool()).is_empty(), "wave_count 5 passes (7.59375 <= 10)")
	assert_false(TribulationRules.lint(gd, {"wave_count": 6}, _fx_pool()).is_empty(), "wave_count 6 rejected (11.390625 > 10)")
	assert_false(TribulationRules.lint(gd, {"pool_ramp": 0.99}, _fx_pool()).is_empty(), "pool_ramp 0.99 rejected")


func test_power_band_ac70() -> void:
	var gd := game_data()
	var p_lo := _fx_pool()
	p_lo[0].off_estimate = 400.0
	p_lo[0].ehp_estimate = 3525.0   # r_b = 0.10
	assert_true(TribulationRules.lint(gd, {}, p_lo).is_empty(), "ehp 3525 (0.10) passes")
	var p_hi := _fx_pool()
	p_hi[0].off_estimate = 400.0
	p_hi[0].ehp_estimate = 12337.5   # r_b = 0.35
	assert_true(TribulationRules.lint(gd, {}, p_hi).is_empty(), "ehp 12337.5 (0.35) passes")

	var p_low_bad := _fx_pool()
	p_low_bad[0].off_estimate = 400.0
	p_low_bad[0].ehp_estimate = 3500.0   # 0.09929
	assert_false(TribulationRules.lint(gd, {}, p_low_bad).is_empty(), "ehp 3500 rejected")
	var p_hi_bad := _fx_pool()
	p_hi_bad[0].off_estimate = 400.0
	p_hi_bad[0].ehp_estimate = 12500.0   # 0.35461
	assert_false(TribulationRules.lint(gd, {}, p_hi_bad).is_empty(), "ehp 12500 rejected")


func test_kill_time_ac71() -> void:
	var gd := game_data()
	# Legacy 30.0 s boundary from pre-#44 AC-TK-71 text: 20,000 * 2.25 / 1500 = 30.0 s
	var p_ok30 := _fx_pool()
	p_ok30[0].off_estimate = 200.0
	p_ok30[0].ehp_estimate = 20000.0
	assert_true(TribulationRules.lint(gd, {"stall_time": 30.0}, p_ok30).is_empty(), "20000 passes at stall_time 30.0 (30.0 s)")
	var p_bad30 := _fx_pool()
	p_bad30[0].off_estimate = 200.0
	p_bad30[0].ehp_estimate = 20100.0
	assert_false(TribulationRules.lint(gd, {"stall_time": 30.0}, p_bad30).is_empty(), "20100 rejected at stall_time 30.0 (30.15 s)")
	# Current #44 60.0 s boundary: 40,000 * 2.25 / 1500 = 60.0 s
	var p_ok60 := _fx_pool()
	p_ok60[0].off_estimate = 100.0
	p_ok60[0].ehp_estimate = 40000.0
	assert_true(TribulationRules.lint(gd, {"stall_time": 60.0}, p_ok60).is_empty(), "40000 passes at stall_time 60.0 (60.0 s)")
	var p_bad60 := _fx_pool()
	p_bad60[0].off_estimate = 100.0
	p_bad60[0].ehp_estimate = 40100.0
	assert_false(TribulationRules.lint(gd, {"stall_time": 60.0}, p_bad60).is_empty(), "40100 rejected at stall_time 60.0 (60.15 s)")


func test_soul_share_ac72() -> void:
	var gd := game_data()
	var p_ok := _fx_pool()
	p_ok[4].off_shares = {"body": 0.25, "qi": 0.25, "soul": 0.50}
	assert_true(TribulationRules.lint(gd, {}, p_ok).is_empty(), "soul share 0.50 passes")
	var p_bad := _fx_pool()
	p_bad[4].off_shares = {"body": 0.24, "qi": 0.25, "soul": 0.51}
	assert_false(TribulationRules.lint(gd, {}, p_bad).is_empty(), "soul share 0.51 rejected")


func test_arts_count_lint_and_escape_forbidden_ac73() -> void:
	var gd := game_data()
	# 2 arts passes (already in _fx_pool); 5 arts passes
	var p5 := _fx_pool()
	p5[0].build.arts = [{"lib": "iron-spark"}, {"lib": "forked-light"}, {"lib": "rolling-thunder"}, {"lib": "anchor-drop"}, {"lib": "bleeding-slash"}]
	assert_true(TribulationRules.lint(gd, {}, p5).is_empty(), "5 valid arts pass")
	# 1 art rejected
	var p1 := _fx_pool()
	p1[0].build.arts = [{"lib": "iron-spark"}]
	assert_false(TribulationRules.lint(gd, {}, p1).is_empty(), "1 art rejected")
	# 6 arts rejected
	var p6 := _fx_pool()
	p6[0].build.arts = [{"lib": "iron-spark"}, {"lib": "forked-light"}, {"lib": "rolling-thunder"}, {"lib": "anchor-drop"}, {"lib": "bleeding-slash"}, {"lib": "binding-thrust"}]
	assert_false(TribulationRules.lint(gd, {}, p6).is_empty(), "6 arts rejected")
	# Art failing Combat's art lint (bad library id or soul_part > 0.30) rejected
	var p_bad_art := _fx_pool()
	p_bad_art[0].build.arts = [{"lib": "iron-spark"}, {"id": "broken_art", "c_art": 1.0, "cooldown": 2.0, "element": "thunder", "kind": "elem", "soul_part": 0.50}]
	assert_false(TribulationRules.lint(gd, {}, p_bad_art).is_empty(), "art failing Combat art lint rejected")
	# Escape art rejected
	var p_esc := _fx_pool()
	p_esc[0].build.arts = [{"lib": "iron-spark"}, {"id": "boss_flee", "c_art": 0.0, "cooldown": 4.0, "element": "", "kind": "phys", "escape": 0.5}]
	assert_false(TribulationRules.lint(gd, {}, p_esc).is_empty(), "escape art rejected")


func test_equiv_realm_forbidden_and_weight_positive_ac74_ac75() -> void:
	var gd := game_data()
	for bad_val in [null, 0, 4, "hoa_than"]:
		var p_eq := _fx_pool()
		p_eq[0]["equiv_realm"] = bad_val
		assert_false(TribulationRules.lint(gd, {}, p_eq).is_empty(), "equiv_realm=%s rejected" % str(bad_val))
	var p_w0 := _fx_pool()
	p_w0[0].weight = 0.0
	assert_false(TribulationRules.lint(gd, {}, p_w0).is_empty(), "weight 0 rejected")


func test_coverage_and_kind_share_ac76_ac77() -> void:
	var gd := game_data()
	# AC-TK-76: empty pool, 3 bosses at wave_count 4, or removing S1 & S2 rejected
	assert_false(TribulationRules.lint(gd, {}, []).is_empty(), "empty pool rejected")
	var p3: Array = [_fx_pool()[0], _fx_pool()[2], _fx_pool()[4]]
	assert_false(TribulationRules.lint(gd, {"wave_count": 4}, p3).is_empty(), "3 bosses at wave_count 4 rejected")
	var p_no_soul: Array = [_fx_pool()[0], _fx_pool()[1], _fx_pool()[2], _fx_pool()[3]]
	assert_false(TribulationRules.lint(gd, {}, p_no_soul).is_empty(), "removing S1 and S2 rejected")

	# AC-TK-77: B1 weight 5 (body 6/12 = 0.50) passes; weight 6 (7/13 = 0.538) rejected
	var p_w5 := _fx_pool()
	p_w5[0].weight = 5.0
	assert_true(TribulationRules.lint(gd, {}, p_w5).is_empty(), "B1 weight 5 (body 0.50) passes")
	var p_w6 := _fx_pool()
	p_w6[0].weight = 6.0
	assert_false(TribulationRules.lint(gd, {}, p_w6).is_empty(), "B1 weight 6 (body 0.538) rejected at pool_target 6")
	# Weight 6 with Q2 removed (5 bosses < pool_target 6) passes
	var p_w6_five := _fx_pool()
	p_w6_five[0].weight = 6.0
	p_w6_five.remove_at(3)   # remove Q2 -> 5 bosses
	assert_true(TribulationRules.lint(gd, {}, p_w6_five).is_empty(), "B1 weight 6 with 5 bosses (< pool_target) passes")
	# main_kind not largest offence share rejected
	var p_bad_mk := _fx_pool()
	p_bad_mk[0].main_kind = "body"
	p_bad_mk[0].off_shares = {"body": 0.20, "qi": 0.65, "soul": 0.15}
	assert_false(TribulationRules.lint(gd, {}, p_bad_mk).is_empty(), "mismatched main_kind rejected")


func test_reward_and_tempered_buff_budget_ac78_ac79() -> void:
	var gd := game_data()
	# AC-TK-78: missing reward or out-of-bounds rarity/template rejected
	var p_norew := _fx_pool()
	p_norew[0].erase("reward")
	assert_false(TribulationRules.lint(gd, {}, p_norew).is_empty(), "missing reward rejected")
	var p_rar7 := _fx_pool()
	p_rar7[0].reward.rarity = 7
	assert_false(TribulationRules.lint(gd, {}, p_rar7).is_empty(), "rarity 7 (> rarity_max 6) rejected")
	var p_badtpl := _fx_pool()
	p_badtpl[0].reward.template = "nonexistent_item_xyz"
	assert_false(TribulationRules.lint(gd, {}, p_badtpl).is_empty(), "unknown reward template rejected")

	# AC-TK-79: tempered buff 60 W passes; 61 W rejected
	var step_ok: Array = TribulationRules.config(gd).tribulation_steps.duplicate(true)
	step_ok[0].tempered_buff.mods = [{"stat": "attack_pct", "value": 30.0}, {"stat": "defense_pct", "value": 30.0}]
	assert_true(TribulationRules.lint(gd, {"tribulation_steps": step_ok}, _fx_pool()).is_empty(), "60 W buff passes")
	var step_over: Array = TribulationRules.config(gd).tribulation_steps.duplicate(true)
	step_over[0].tempered_buff.mods = [{"stat": "attack_pct", "value": 31.0}, {"stat": "defense_pct", "value": 30.0}]
	assert_false(TribulationRules.lint(gd, {"tribulation_steps": step_over}, _fx_pool()).is_empty(), "61 W buff rejected")
