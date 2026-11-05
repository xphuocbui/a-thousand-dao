extends DaoTestSuite
## Realms & Bottlenecks (design/gdd/canh-gioi.md): the ladder, level costs, stage multiplier,
## attempts, failure and lifespan.


func _at(level: int, purities: Dictionary = {"hoa": 50}, stat_value: int = 50) -> Character:
	var gd := game_data()
	var c := TestFixtures.character(purities, stat_value)
	c.realm_index = Ladder.realm_of_level(gd, level)
	c.level = level
	c.level_peak = level
	c.stage = Ladder.stage_of_level(gd, level)
	return c


func _gate(realm_idx: int, purities: Dictionary = {"hoa": 50}, stat_value: int = 50) -> Character:
	var gd := game_data()
	var c := _at(Ladder.band(gd, realm_idx)[1], purities, stat_value)
	c.tu_vi = Ladder.bar_cost(gd, realm_idx)
	return c


func _sheet(c: Character) -> StatSheet:
	return StatSheet.build(c, game_data(), null, null)


# --- The ladder -------------------------------------------------------------------

func test_levels_fix_the_realm_and_clamp_ac01() -> void:
	var gd := game_data()
	var want := {1: 0, 39: 0, 40: 1, 79: 1, 80: 2, 129: 2, 130: 3, 199: 3, 200: 4, 300: 4}
	for l in want.keys():
		assert_eq(Ladder.realm_of_level(gd, l), want[l], "level %d" % l)
	assert_eq(Ladder.clamp_level(gd, 0), 1, "floor")
	assert_eq(Ladder.clamp_level(gd, 301), 300, "cap")


func test_stage_starts_match_the_table_ac02() -> void:
	var gd := game_data()
	var want: Array = [[14, 27, 39], [53, 66, 79], [96, 113, 129], [153, 176, 199], [233, 267, 300]]
	for i in want.size():
		assert_eq(Ladder.stage_starts(gd, i), want[i], "realm %d" % i)
	assert_eq(Ladder.stage_of_level(gd, 52), 0, "FE 52 early")
	assert_eq(Ladder.stage_of_level(gd, 53), 1, "FE 53 middle")
	assert_eq(Ladder.stage_of_level(gd, 66), 2, "FE 66 late")
	assert_eq(Ladder.stage_of_level(gd, 79), 3, "FE 79 great perfection")


func test_layer_label_is_ceil_of_a_third_ac03() -> void:
	var gd := game_data()
	var want := {1: 1, 4: 2, 14: 5, 27: 9, 39: 13}
	for l in want.keys():
		assert_eq(Ladder.layer_of_level(gd, l), want[l], "level %d" % l)


func test_level_costs_match_the_table_ac04() -> void:
	var gd := game_data()
	var cases: Array = [[1, 9.60], [20, 24.09], [38, 57.60], [40, 78.67], [59, 136.26], [78, 236.01], [80, 469.87], [104, 813.84], [128, 1409.60], [130, 2194.04], [164, 3800.19], [198, 6582.13], [200, 10152.05], [250, 17681.70], [299, 30456.15]]
	for c in cases:
		assert_near(Ladder.level_cost(gd, c[0]), c[1], c[1] * 0.001, "level %d" % c[0])


func test_costs_sum_to_the_climb_total_and_bars_match_ac05() -> void:
	var gd := game_data()
	var bars: Array = [230.40, 2360.11, 14096.04, 65821.26, 0.0]
	for i in gd.realms().size():
		var b: Array = Ladder.band(gd, i)
		var sum: float = 0.0
		for l in range(b[0], b[1]):
			sum += Ladder.level_cost(gd, l)
		assert_near(sum, float(gd.realm(i).climb_total), float(gd.realm(i).climb_total) * 1e-6, "realm %d total" % i)
		assert_near(Ladder.bar_cost(gd, i), bars[i], 0.01, "realm %d bar" % i)


func test_level_rises_when_the_bar_reaches_the_cost_ac06() -> void:
	var gd := game_data()
	var c := _at(60)
	for i in 4:
		CultivationRules.add_tu_vi(c, gd, 31.25)
	assert_eq(c.level, 60, "still 60")
	assert_near(c.tu_vi, 125.0, 0.01, "bar")
	CultivationRules.add_tu_vi(c, gd, 31.25)
	assert_eq(c.level, 61, "level 61")
	assert_near(c.tu_vi, 15.99, 0.01, "surplus")


func test_rate_multiplies_every_factor_ac07() -> void:
	var gd := game_data()
	var c := _at(45, {"hoa": 50})
	c.main_tech = ""
	var sheet := StatSheet.new()
	sheet.add_mod("test", "cultivation_speed_pct", 6.0)
	var b: Breakdown = CultivationRules.rate_per_season(c, gd, null, sheet, 1.0)
	# base 25 x curve 1 x crude 0.15 x comp 1.25 x 1.06
	assert_near(b.total, 25.0 * 0.15 * 1.25 * 1.06, 0.001, "multiplied, not added")
	var neg := StatSheet.new()
	neg.add_mod("test", "cultivation_speed_pct", -150.0)
	assert_eq(CultivationRules.rate_per_season(c, gd, null, neg, 1.0).total, 0.0, "never negative")


func test_one_grant_climbs_several_levels_and_stages_ac08() -> void:
	var gd := game_data()
	var c := _at(13)
	var r: Dictionary = CultivationRules.add_tu_vi(c, gd, 336.52)
	assert_eq(c.level, 27, "level 27")
	assert_near(c.tu_vi, 1.0, 0.05, "bar 1")
	assert_eq(r.stages_reached, [1, 2], "middle then late")
	assert_eq(r.levels_gained.size(), 14, "14 levels")
	assert_near(Ladder.stage_mult(gd, c.stage), 1.30, 1e-9, "stage_mult")


func test_overflow_past_a_full_bar_is_wasted_ac09_ac10() -> void:
	var gd := game_data()
	var c := _at(38)
	var r: Dictionary = CultivationRules.add_tu_vi(c, gd, 357.60)
	assert_eq(c.level, 39, "great perfection")
	assert_near(c.tu_vi, 230.40, 0.01, "bar full")
	assert_near(r.wasted, 69.60, 0.05, "wasted")
	assert_true(r.bottleneck, "at the bottleneck")
	assert_near(CultivationRules.add_tu_vi(c, gd, 50.0).wasted, 50.0, 0.001, "further gain wasted")


func test_level_300_is_capped_ac11() -> void:
	var gd := game_data()
	var c := _at(300)
	var r: Dictionary = CultivationRules.add_tu_vi(c, gd, 1000000.0)
	assert_eq(c.level, 300, "level")
	assert_eq(c.tu_vi, 0.0, "bar")
	assert_false(CultivationRules.at_bottleneck(c, gd), "no bottleneck")
	assert_eq(r.levels, 0, "nothing fires")


func test_stage_multiplier_steps_at_each_small_breakthrough_ac13() -> void:
	var gd := game_data()
	var want := {13: 1.00, 14: 1.15, 26: 1.15, 27: 1.30, 38: 1.30, 39: 1.45, 40: 1.00, 80: 1.00, 130: 1.00, 200: 1.00}
	for l in want.keys():
		assert_near(Ladder.stage_mult(gd, Ladder.stage_of_level(gd, l)), want[l], 1e-9, "level %d" % l)


func test_derived_values_take_the_stage_multiplier_ac14() -> void:
	var gd := game_data()
	var c := _at(66)
	var sheet := _sheet(c)
	assert_near(CharacterRules.khi_huyet_max(c, gd, sheet).total, 50.0 * 10.0 * 4.0 * 1.30, 0.01, "vitality")
	assert_near(CharacterRules.than_thuc(c, gd, sheet).total, 50.0 * 1.0 * 3.0 * 1.30, 0.01, "divine sense")
	var power := func(l): return float(gd.realm(Ladder.realm_of_level(gd, l)).power_base) * Ladder.stage_mult(gd, Ladder.stage_of_level(gd, l))
	assert_near(power.call(129), 14500.0, 0.01, "CF 129")
	assert_near(power.call(130), 100000.0, 0.01, "NS 130")


# --- Attempts ---------------------------------------------------------------------

func test_pill_attempt_example_ac19() -> void:
	# FE->CF, rank 1, comprehension 40, Dao heart 30, tree 2 pp: 0.045 + 0.015 + 0.02 + 0.0075 + 0.02.
	var gd := game_data()
	var c := _gate(1)
	c.thien_phu.ngo_tinh = 40
	c.thien_phu.dao_tam = 30
	var sheet := _sheet(c)
	sheet.add_mod("Huyệt", "breakthrough_chance", 2.0, StatSheet.KIND_TREE)
	assert_near(CultivationRules.breakthrough_chance(c, gd, sheet, 1).total, 0.1075, 1e-6, "first attempt")
	c.failed_pills = 1
	assert_near(CultivationRules.breakthrough_chance(c, gd, sheet, 1).total, 0.1275, 1e-6, "after a failure")


func test_a_bare_attempt_uses_the_bare_chance_alone_ac21() -> void:
	var gd := game_data()
	var c := _gate(1, {"hoa": 50}, 100)
	var sheet := _sheet(c)
	sheet.add_mod("Huyệt", "breakthrough_chance", 8.0, StatSheet.KIND_TREE)
	assert_near(CultivationRules.breakthrough_chance(c, gd, sheet, -1).total, 0.0037, 1e-9, "bare")


func test_tree_share_counts_as_eight_points_ac25() -> void:
	var gd := game_data()
	var c := _gate(1)
	var sheet := StatSheet.build(c, gd, null, null)
	sheet.add_mod("Huyệt", "breakthrough_chance", 12.0, StatSheet.KIND_TREE)
	sheet.add_mod("Thiên mệnh: X", "breakthrough_chance", 12.0, StatSheet.KIND_PERK)
	assert_eq(sheet.tree_breakthrough(), 8.0, "tree capped")
	assert_eq(sheet.total("breakthrough_chance"), 20.0, "other sources add on top")


func test_q_extras_clamp_at_the_ceiling_outside_extras_stay_ac65() -> void:
	var gd := game_data()
	var c := _gate(1, {"hoa": 50}, 100)
	var sheet := _sheet(c)
	sheet.add_mod("Huyệt", "breakthrough_chance", 8.0, StatSheet.KIND_TREE)
	sheet.add_mod("Thiên mệnh: X", "breakthrough_chance", 12.0, StatSheet.KIND_PERK)
	c.failed_pills = 1
	# 0.045 + min(extras, 0.10) + 0.12 + 0.02 + talisman 0.05
	assert_near(CultivationRules.breakthrough_chance(c, gd, sheet, 5, true).total, 0.335, 1e-6, "clamped")


func test_chance_clamps_to_ninety_five_ac24() -> void:
	var gd := game_data()
	var c := _gate(1)
	var sheet := _sheet(c)
	sheet.add_mod("Thiên mệnh: X", "breakthrough_chance", 200.0, StatSheet.KIND_PERK)
	assert_near(CultivationRules.breakthrough_chance(c, gd, sheet, 0).total, 0.95, 1e-9, "max")


func test_success_enters_the_next_realm_and_clears_the_step_ac26() -> void:
	var gd := game_data()
	var c := _gate(1)
	c.failed_pills = 2
	c.bare_attempts = 2
	c.talisman_used = true
	c.vitality = 0.5
	var res: Dictionary = CultivationRules.resolve_attempt(c, gd, _sheet(c), ScriptedRng.new(["U", 0.0]), 0.5, true)
	assert_true(res.success, "success")
	assert_eq(c.realm_index, 2, "Core Formation")
	assert_eq(c.level, 80, "level 80")
	assert_eq(c.stage, 0, "early")
	assert_eq(c.tu_vi, 0.0, "bar 0")
	assert_eq(c.vitality, 1.0, "vitality full")
	assert_eq(c.failed_pills, 0, "insight reset")
	assert_eq(c.bare_attempts, 0, "bare count reset")
	assert_false(c.talisman_used, "talisman flag clear")
	assert_eq(res.points, 17, "137 - 120")


func test_failure_takes_the_penalties_ac34() -> void:
	var gd := game_data()
	var c := _gate(1, {"hoa": 50}, 40)
	var bar: float = c.tu_vi
	var res: Dictionary = CultivationRules.resolve_attempt(c, gd, _sheet(c), ScriptedRng.new(["U", 0.99, "U", 0.99]), 0.1, true)
	assert_false(res.success, "failed")
	assert_near(c.tu_vi, bar * 0.7, 0.01, "bar down 30 %")
	assert_eq(c.tam_ma, 15.0, "heart demon +15")
	assert_near(c.vitality, 0.6, 1e-6, "vitality -40 %")
	assert_eq(c.failed_pills, 1, "insight")
	assert_eq(c.level, 79, "level unchanged")


func test_vitality_floor_holds_ac35() -> void:
	var gd := game_data()
	var c := _gate(1)
	c.vitality = 0.125
	CultivationRules.resolve_attempt(c, gd, _sheet(c), ScriptedRng.new(["U", 0.99, "U", 0.99]), 0.1, true)
	assert_near(c.vitality, 0.05, 1e-6, "floor")


func test_deviation_kills_only_at_ninety_ac36() -> void:
	var gd := game_data()
	var c := _gate(1, {"hoa": 50}, 10)
	c.tam_ma = 70.0
	var low: Dictionary = CultivationRules.resolve_attempt(c, gd, _sheet(c), ScriptedRng.new(["U", 0.99, "U", 0.0]), 0.1, true)
	assert_true(low.backlash and not low.died, "deviation below 90 lives")
	assert_near(c.vitality, 0.05, 1e-6, "floor after a deviation")
	var d := _gate(1, {"hoa": 50}, 10)
	d.tam_ma = 80.0
	var high: Dictionary = CultivationRules.resolve_attempt(d, gd, _sheet(d), ScriptedRng.new(["U", 0.99, "U", 0.0]), 0.1, true)
	assert_true(high.died, "gain lands first, then 95 >= 90 kills")


func test_safe_failure_keeps_the_bar_and_halves_heart_demon_ac37() -> void:
	var gd := game_data()
	var c := _gate(1)
	var bar: float = c.tu_vi
	var sheet := _sheet(c)
	sheet.add_mod("Thiên mệnh: X", "safe_failure", 1.0, StatSheet.KIND_PERK)
	CultivationRules.resolve_attempt(c, gd, sheet, ScriptedRng.new(["U", 0.99, "U", 0.99]), 0.1, true)
	assert_eq(c.tu_vi, bar, "bar kept")
	assert_eq(c.tam_ma, 7.5, "half")


func test_a_failed_bare_attempt_adds_no_insight_ac38() -> void:
	var gd := game_data()
	var c := _gate(1)
	CultivationRules.resolve_attempt(c, gd, _sheet(c), ScriptedRng.new(["U", 0.99, "U", 0.99]), 0.0037, false)
	assert_eq(c.failed_pills, 0, "no insight")
	assert_eq(c.bare_attempts, 1, "counted")


func test_bare_attempts_stop_at_the_cap_ac40a() -> void:
	var gd := game_data()
	var c := _gate(1)
	c.bare_attempts = 2
	assert_true(CultivationRules.bare_attempt_left(c, gd), "third allowed")
	c.bare_attempts = 3
	assert_false(CultivationRules.bare_attempt_left(c, gd), "fourth refused")


func test_realm_conditions_ac41_to_ac44() -> void:
	var gd := game_data()
	assert_true(CultivationRules.breakthrough_condition(_gate(0), gd, 1.0).met, "FE: pill alone")
	assert_false(CultivationRules.breakthrough_condition(_gate(1), gd, 1.39).met, "CF below 1.4")
	assert_true(CultivationRules.breakthrough_condition(_gate(1), gd, 1.4).met, "CF at 1.4")
	var ns := _gate(2)
	ns.tam_ma = 20.0
	assert_true(CultivationRules.breakthrough_condition(ns, gd, 1.0).met, "NS at 20")
	ns.tam_ma = 20.25
	assert_false(CultivationRules.breakthrough_condition(ns, gd, 1.0).met, "NS above 20")
	var dt := _gate(3)
	assert_false(CultivationRules.breakthrough_condition(dt, gd, 1.0).met, "DT without insight")
	dt.has_insight = true
	assert_true(CultivationRules.breakthrough_condition(dt, gd, 1.0).met, "DT with insight")


func test_failure_insight_stops_at_its_cap_ac64() -> void:
	var gd := game_data()
	assert_eq(CultivationRules.failure_insight(gd, 0), 0.0, "first")
	assert_near(CultivationRules.failure_insight(gd, 1), 0.02, 1e-9, "second")
	assert_near(CultivationRules.failure_insight(gd, 2), 0.04, 1e-9, "third")
	assert_near(CultivationRules.failure_insight(gd, 4), 0.04, 1e-9, "capped")


# --- Lifespan and points ----------------------------------------------------------

func test_lifespan_bonus_meets_the_ceiling_and_penalties_follow_ac61() -> void:
	var gd := game_data()
	var c := _at(10)
	c.lifespan_bonus = 10.0
	var sheet := _sheet(c)
	sheet.add_mod("a", "lifespan_years", 15.0)
	assert_near(CultivationRules.lifespan(c, gd, sheet).total, 138.0, 0.001, "min(25, 18)")
	sheet.add_mod("b", "lifespan_years", -5.0)
	assert_near(CultivationRules.lifespan(c, gd, sheet).total, 133.0, 0.001, "penalty after the cap")


func test_points_match_the_table_kmd01() -> void:
	var gd := game_data()
	var want := {1: 2, 13: 14, 14: 17, 26: 29, 27: 34, 38: 45, 39: 51, 40: 62, 53: 79, 60: 86, 79: 120, 80: 137, 129: 216, 130: 243, 199: 357, 200: 397, 266: 477, 267: 501, 300: 566}
	for l in want.keys():
		assert_eq(Ladder.points_total(gd, l), want[l], "level %d" % l)
	assert_eq(Ladder.share(35, 90), 32, "share rounds half up")
	assert_eq(Ladder.share(25, 90), 23, "share(25, 90)")


func test_points_pay_on_new_peaks_only_kmd04() -> void:
	var gd := game_data()
	var c := _at(59)
	c.level_peak = 60
	c.tree_points = 0
	var r: Dictionary = CultivationRules.add_tu_vi(c, gd, Ladder.level_cost(gd, 59))
	assert_eq(c.level, 60, "regained")
	assert_eq(r.tree_points, 0, "no level pays twice")


func test_old_stage_saves_migrate_to_a_level_ac57() -> void:
	var gd := game_data()
	var mid := Ladder.migrate_record({"realm_index": 0, "stage": 4, "tu_vi": 30.0}, gd)
	assert_eq(mid.level, 14, "layer 5, half way: 3*4 + 1 + 1")
	var full := Ladder.migrate_record({"realm_index": 1, "stage": 3, "tu_vi": 1800.0}, gd)
	assert_eq(full.level, 79, "full bottleneck to great perfection")
	assert_near(float(full.tu_vi), 2360.11, 0.01, "full bar")
