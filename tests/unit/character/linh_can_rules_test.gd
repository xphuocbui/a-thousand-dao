extends DaoTestSuite
## LinhCan: element counting, biến dị derivation and serialization.


func test_bien_di_purity_is_geometric_mean_times_factor() -> void:
	# Arrange
	var gd := game_data()
	var lc := LinhCan.new()
	lc.elements = {"moc": 80, "hoa": 45}
	var factor: float = float(gd.attributes().linh_can.bien_di_purity_factor)
	# Act
	var granted: bool = lc.grant_bien_di(gd, "quang")
	# Assert
	assert_true(granted, "Mộc + Hỏa can grant Quang")
	assert_eq(int(lc.bien_di.quang), int(roundf(sqrt(80.0 * 45.0) * factor)), "Quang purity")


func test_grant_bien_di_without_parent_fails() -> void:
	var gd := game_data()
	var lc := LinhCan.new()
	lc.elements = {"moc": 80}
	assert_false(lc.grant_bien_di(gd, "quang"), "Quang needs Hỏa")
	assert_true(lc.bien_di.is_empty(), "nothing granted")


func test_counted_elements_includes_bien_di() -> void:
	var gd := game_data()
	var lc := LinhCan.new()
	lc.elements = {"kim": 50, "hoa": 50}
	lc.grant_bien_di(gd, "loi")
	assert_eq(lc.base_count(), 2, "base count")
	assert_eq(lc.counted_elements(gd), 3, "Lôi counts as an element")


func test_hon_don_requires_all_five_elements() -> void:
	var gd := game_data()
	var four := LinhCan.new()
	four.elements = {"kim": 60, "moc": 60, "thuy": 60, "hoa": 60}
	var five := LinhCan.new()
	five.elements = {"kim": 60, "moc": 60, "thuy": 60, "hoa": 60, "tho": 60}
	assert_false(four.grant_bien_di(gd, "hon_don"), "four elements")
	assert_true(five.grant_bien_di(gd, "hon_don"), "five elements")


func test_roll_is_deterministic_for_a_seed() -> void:
	var gd := game_data()
	var a := LinhCan.roll(gd, rng(7))
	var b := LinhCan.roll(gd, rng(7))
	assert_eq(a.to_dict(), b.to_dict(), "same seed, same root")


func test_roll_count_distribution_follows_weights() -> void:
	# 2000 rolls: single-element roots must be the most common, five-element the rarest.
	var gd := game_data()
	var r := rng(99)
	var counts := {1: 0, 2: 0, 3: 0, 4: 0, 5: 0}
	for i in 2000:
		counts[LinhCan.roll(gd, r).base_count()] += 1
	assert_true(counts[1] > counts[2] and counts[2] > counts[3] and counts[3] > counts[4] and counts[4] > counts[5], "weights 45/30/15/7/3: %s" % str(counts))


func test_dict_round_trip_converts_json_floats() -> void:
	var lc := LinhCan.from_dict({"elements": {"hoa": 78.0}, "bien_di": {"quang": 51.0}})
	assert_eq(typeof(lc.elements.hoa), TYPE_INT, "purity is int")
	assert_eq(lc.purity("quang"), 51.0, "biến dị purity")
