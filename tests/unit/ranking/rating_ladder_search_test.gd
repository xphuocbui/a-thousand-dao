extends DaoTestSuite
## Power Rankings Formulas A, B, E, G (design/gdd/power-rankings.md) on the GDD's illustrative test ladder (A_1 5400,
## 240 a rung, k_max 32). Expected values come from the Python twin (export_rankings_calibration.py search() and
## solve_base()), so the GDScript port is checked against the calibration's own search.

const ANCHORS := [1000.0, 5400.0, 9800.0, 14200.0, 18300.0]
const POWER_BASE := [100.0, 1000.0, 10000.0, 100000.0, 1000000.0]


static func _test_ladder() -> PackedFloat64Array:
	var lad := PackedFloat64Array()
	for k in range(-32, 33):
		lad.append(5400.0 + 240.0 * k)
	return lad


static func _test_rating_ladder() -> RatingLadder:
	var rows: Array = []
	for r in 5:
		var row := PackedFloat64Array()
		for k in range(-32, 33):
			row.append(ANCHORS[r] + 240.0 * k)
		rows.append(row)
	return RatingLadder.from_dict({"k_max": 32, "rung_div": 4, "anchors": ANCHORS, "ladders": rows}, [], POWER_BASE)


static func _scripted(scores: Dictionary) -> Callable:
	return func(k: int, fights: int) -> float: return float(scores[k])


func test_expected_score_is_elo() -> void:
	# Formulas A, AC-PR-27
	assert_near(PanelSearch.expected(1450.0, 1400.0), 0.5715, 0.0005, "1450 against 1400")
	assert_near(PanelSearch.expected(1450.0, 1400.0) + PanelSearch.expected(1400.0, 1450.0), 1.0, 1e-12, "symmetric")


func test_the_formulas_b_cold_search_example() -> void:
	# GDD Formulas B example: 4/4 at 0, 0/4 at 8, 3/4 at 4, 1/4 at 6, 2/4 at 5 -> bracket [4, 5], 20 fights, base 6,559
	var r: Dictionary = PanelSearch.search(_scripted({0: 4, 8: 0, 4: 3, 6: 1, 5: 2}), _test_ladder(), 32, 0, 8, 1, 4, 1.0)
	assert_eq(r.probes.map(func(p): return p[0]), [0, 8, 4, 6, 5], "probe order")
	assert_eq(int(r.fights), 20, "20 fights")
	assert_near(float(r.base), 6558.616, 0.01, "base as the Python twin")


func test_warm_and_coarse_searches_ac_pr_06() -> void:
	var wins_to_4 := func(k: int, fights: int) -> float: return float(fights) if k <= 4 else 0.0
	var warm: Dictionary = PanelSearch.search(wins_to_4, _test_ladder(), 32, 3, 2, 1, 4, 1.0)
	assert_eq(warm.probes.map(func(p): return p[0]), [3, 5, 4], "warm from rung 3")
	assert_eq(int(warm.fights), 12, "12 fights")
	assert_near(float(warm.base), 6484.52, 0.01, "warm base as the Python twin")
	var coarse: Dictionary = PanelSearch.search(wins_to_4, _test_ladder(), 32, 0, 8, 4, 2, 1.0)
	assert_eq(coarse.probes.map(func(p): return p[0]), [0, 8, 4], "coarse cold search")
	assert_eq(int(coarse.fights), 6, "6 fights")
	assert_near(float(coarse.base), 6542.457, 0.01, "coarse base as the Python twin")


func test_off_the_ladder_ends_the_prior_keeps_the_base_finite() -> void:
	var sweep: Dictionary = PanelSearch.search(func(k, n): return float(n), _test_ladder(), 32, 0, 8, 1, 4, 1.0)
	assert_eq(sweep.probes.map(func(p): return p[0]), [0, 8, 24, 32], "doubling steps to the top")
	assert_near(float(sweep.base), 13418.043, 0.01, "about 340 above the top rung (13,080)")
	var loss: Dictionary = PanelSearch.search(func(k, n): return 0.0, _test_ladder(), 32, 0, 8, 1, 4, 1.0)
	assert_near(float(loss.base), -2618.043, 0.01, "about 340 below the bottom rung")


func test_an_irregular_scripted_fighter_matches_the_python_twin() -> void:
	var outs := [4, 2, 2, 4, 0, 3, 1, 0, 1, 0, 2, 3, 1, 3, 4, 0, 4, 1, 0, 1, 3, 2, 1, 3, 1, 0, 1, 4, 4, 3, 1, 1, 0, 0, 1,
		1, 1, 1, 2, 2, 1, 4, 1, 1, 1, 3, 2, 0, 2, 3, 1, 1, 2, 0, 2, 2, 4, 4, 0, 4, 2, 0, 2, 2, 2]
	var r: Dictionary = PanelSearch.search(func(k, n): return float(outs[k + 32]), _test_ladder(), 32, -5, 8, 1, 4, 1.0)
	assert_eq(r.probes.map(func(p): return p[0]), [-5, 3, -1, -3, -2], "probe order")
	assert_near(float(r.base), 4888.758973, 1e-4, "base")


func test_power_number_is_log_linear_between_anchors() -> void:
	# Formulas E, AC-PR-33 (illustrative anchors)
	var lad := _test_rating_ladder()
	assert_eq(lad.power_number(6500.0), 1780, "1000 x 10^(1100 / 4400) = 1,778 -> 1,780")
	for r in 5:
		assert_eq(lad.power_number(ANCHORS[r]), int(POWER_BASE[r]), "realm %d's typical shows its power base" % r)
	# below A_0 the Luyện Khí slope continues; whole numbers below 100
	var r59: float = 1000.0 + 4400.0 * log(0.5925) / log(10.0)
	assert_eq(lad.power_number(r59), 59, "59.25 shows as 59")
	assert_eq(lad.power_number(-50000.0), 1, "floor 1")


func test_provisional_reads_the_ladder_at_stage_strength() -> void:
	# Formulas G example: Trúc Cơ stage 2 is rung 3.03 -> 5400 + 727 = 6,127 (test ladder), power 1,460
	var lad := _test_rating_ladder()
	var gd := game_data()
	var prov: float = lad.provisional(1, 2, gd)
	var sm: float = Ladder.stage_mult(gd, 2)
	assert_near(prov, 5400.0 + 240.0 * 4.0 * log(sm * sm) / log(2.0), 1e-6, "the ladder at stage_mult squared")
	assert_near(prov, 6127.0, 1.0, "about 6,127")
	assert_eq(lad.power_number(prov), 1460, "power 1,460")
	assert_near(lad.provisional(1, 0, gd), 5400.0, 1e-9, "stage 0 is the anchor")
