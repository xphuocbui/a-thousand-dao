extends DaoTestSuite
## CultivationRules: the linh căn curve, stage advancement, bình cảnh and breakthroughs.


func test_curve_parity_points_match_design() -> void:
	# Design: 2-3 elements reach parity at Trúc Cơ trung kỳ, 4 at hậu kỳ, 5+ at Kết Đan sơ kỳ.
	var gd := game_data()
	var two := TestFixtures.character({"kim": 50, "moc": 50}, 50, 1, 1)
	var three := TestFixtures.character({"kim": 50, "moc": 50, "hoa": 50}, 50, 1, 1)
	var four := TestFixtures.character({"kim": 50, "moc": 50, "hoa": 50, "tho": 50}, 50, 1, 2)
	var five := TestFixtures.character({"kim": 50, "moc": 50, "hoa": 50, "tho": 50, "thuy": 50}, 50, 2, 0)
	assert_eq(CultivationRules.curve_factor(two, gd), 1.0, "Song at TC trung")
	assert_eq(CultivationRules.curve_factor(three, gd), 1.0, "Tam at TC trung")
	assert_eq(CultivationRules.curve_factor(four, gd), 1.0, "Tứ at TC hậu")
	assert_eq(CultivationRules.curve_factor(five, gd), 1.0, "Ngũ at KĐ sơ")


func test_many_elements_slower_early() -> void:
	var gd := game_data()
	var one := TestFixtures.character({"hoa": 50}, 50, 0, 0)
	var five := TestFixtures.character({"kim": 50, "moc": 50, "hoa": 50, "tho": 50, "thuy": 50}, 50, 0, 0)
	assert_true(CultivationRules.curve_factor(five, gd) < CultivationRules.curve_factor(one, gd), "Ngũ slower in Luyện Khí")


func test_add_tu_vi_advances_stages_and_grants_points() -> void:
	# Arrange: Luyện Khí tầng 1 needs 30, tầng 2 needs 35 (cultivation_realms.json).
	var gd := game_data()
	var c := TestFixtures.character({"hoa": 50})
	# Act
	var res: Dictionary = CultivationRules.add_tu_vi(c, gd, 70.0)
	# Assert
	assert_eq(c.stage, 2, "two stages gained")
	assert_near(c.tu_vi, 5.0, 0.001, "remainder carried")
	assert_eq(res.tree_points, 2, "1 point per Luyện Khí stage")
	assert_eq(c.tree_points, 2, "points credited")


func test_tu_vi_caps_at_bottleneck() -> void:
	var gd := game_data()
	var c := TestFixtures.character({"hoa": 50}, 50, 0, 12)
	var res: Dictionary = CultivationRules.add_tu_vi(c, gd, 10000.0)
	assert_eq(c.stage, 12, "stays at tầng 13")
	assert_eq(c.tu_vi, 200.0, "capped at requirement")
	assert_true(res.bottleneck, "bình cảnh reached")
	assert_true(CultivationRules.at_bottleneck(c, gd), "at_bottleneck")


func test_breakthrough_chance_higher_with_pill() -> void:
	var gd := game_data()
	var c := TestFixtures.character({"hoa": 50}, 50, 0, 12)
	var sheet := StatSheet.new()
	var without: float = CultivationRules.breakthrough_chance(c, gd, sheet, -1).total
	var with_pill: float = CultivationRules.breakthrough_chance(c, gd, sheet, 0).total
	var req: Dictionary = gd.realm(1).entry_requirement
	assert_true(with_pill > without, "pill matters: %f vs %f" % [with_pill, without])
	assert_near(with_pill - without, float(req.pill_chance) - float(req.base_chance), 0.0001, "the pill adds exactly its data difference")


func test_successful_breakthrough_enters_next_realm() -> void:
	var gd := game_data()
	var c := TestFixtures.character({"hoa": 50}, 100, 0, 12)
	c.tu_vi = 200.0
	var sheet := StatSheet.new()
	sheet.add_mod("test", "breakthrough_chance", 100.0)   # force success
	var res: Dictionary = CultivationRules.attempt_breakthrough(c, gd, sheet, rng(1), 3)
	assert_true(res.success, "success")
	assert_eq(c.realm_index, 1, "Trúc Cơ")
	assert_eq(c.stage, 0, "sơ kỳ")
	assert_eq(c.tree_points, int(gd.realm(1).tree_points_per_stage), "entry points")


func test_failed_breakthrough_costs_tu_vi_and_adds_tam_ma() -> void:
	var gd := game_data()
	var c := TestFixtures.character({"hoa": 50}, 1, 0, 12)
	c.tu_vi = 200.0
	var sheet := StatSheet.new()
	sheet.add_mod("test", "breakthrough_chance", -100.0)   # force failure
	var res: Dictionary = CultivationRules.attempt_breakthrough(c, gd, sheet, rng(1), -1)
	assert_false(res.success, "failure")
	assert_near(c.tu_vi, 200.0 * (1.0 - float(gd.breakthrough_rules().failure_tu_vi_loss_pct)), 0.01, "tu vi lost")
	assert_true(c.tam_ma > 0.0, "tâm ma gained")


func test_rate_breakdown_explains_every_factor() -> void:
	var gd := game_data()
	var c := TestFixtures.character({"hoa": 60}, 50, 0, 0)
	var b: Breakdown = CultivationRules.rate_per_season(c, gd, null, StatSheet.new(), 1.0)
	# base 10 x curve 1 x crude 0.3*0.6 x (1+50/200) x density 1
	assert_near(b.total, 10.0 * 0.3 * 0.6 * 1.25, 0.001, "rate")
	assert_true(b.lines().size() >= 5, "explained")
