extends DaoTestSuite
## Float, uncapped purity and road purity (design/gdd/linh-can.md rules 8, 8a, 10, 13; Đạo Đồ rule 4; ADR-0004
## decision 2): AC-LC-43, AC-LC-56, AC-LC-57, AC-LC-58 and the purity half of AC-KMD-97.


func _lc(elements: Dictionary, variants: Dictionary = {}) -> LinhCan:
	var c := TestFixtures.character(elements)
	c.linh_can.variants = variants.duplicate()
	c.linh_can.recompute_derived(game_data())
	return c.linh_can


func test_road_purity_on_an_unowned_element_owns_nothing_ac_kmd_97() -> void:
	var gd := game_data()
	var lc := _lc({"hoa": 70})
	lc.add_road_purity(gd, "kim", 0.5)
	lc.add_road_purity(gd, "kim", 0.5)
	assert_eq(lc.purity("kim"), 1.0, "Metal purity 1.0 for its stacks")
	assert_false(lc.elements.has("kim"), "no base element")
	assert_eq(lc.base_count(), 1, "n_base unchanged")
	assert_false(lc.has("kim"), "not owned")


func test_road_purity_has_no_cap_ac_kmd_97() -> void:
	var gd := game_data()
	var lc := _lc({"hoa": 99})
	lc.add_road_purity(gd, "hoa", 0.5)
	assert_eq(lc.purity("hoa"), 99.5, "fractional")
	lc.add_road_purity(gd, "hoa", 0.5)
	assert_eq(lc.purity("hoa"), 100.0, "99.5 + 0.5")
	lc.add_road_purity(gd, "hoa", 0.5)
	assert_eq(lc.purity("hoa"), 100.5, "no cap")


func test_border_roads_raise_wind_through_its_parents_ac_lc_56() -> void:
	var gd := game_data()
	var lc := _lc({"thuy": 60, "moc": 60}, {"phong": 50})
	assert_eq(lc.purity("phong"), 60.0, "Wind takes round(sqrt(60 x 60))")
	for i in 8:
		lc.add_road_purity(gd, "thuy", 0.25)
		lc.add_road_purity(gd, "moc", 0.25)
	assert_eq(lc.purity("thuy"), 62.0, "Water 62")
	assert_eq(lc.purity("moc"), 62.0, "Wood 62")
	assert_eq(lc.purity("phong"), 62.0, "Wind 62, no Wind roads of its own")


func test_thunder_follows_its_parents_past_100_ac_lc_56() -> void:
	var lc := _lc({"hoa": 160, "kim": 140}, {"loi": 1})
	assert_eq(lc.purity("loi"), 150.0, "round(sqrt(22400))")


func test_ice_is_water_with_its_roads_ac_lc_58() -> void:
	var gd := game_data()
	var lc := _lc({"thuy": 70}, {"bang": 1})
	assert_eq(lc.purity("bang"), 70.0, "Ice = Water")
	lc.add_road_purity(gd, "thuy", 0.5)
	assert_eq(lc.purity("bang"), 70.5, "a Water road raises Ice exactly (one parent, no rounding)")


func test_island_roads_raise_the_variant_on_top_ac_lc_56() -> void:
	var gd := game_data()
	var lc := _lc({"hoa": 64, "kim": 100}, {"loi": 1})
	assert_eq(lc.purity("loi"), 80.0, "round(sqrt(6400))")
	lc.add_road_purity(gd, "loi", 0.5)
	assert_eq(lc.purity("loi"), 80.5, "Thunder's own road adds on top")
	lc.raise_purity(gd, "hoa", 17)
	assert_eq(lc.purity("loi"), 90.5, "parents move it, its road purity stays: round(sqrt(81 x 100)) + 0.5")


func test_pill_stops_at_100_counting_roads() -> void:
	var gd := game_data()
	var lc := _lc({"hoa": 97})
	lc.add_road_purity(gd, "hoa", 2.0)
	lc.raise_purity(gd, "hoa", 6)
	assert_eq(lc.purity("hoa"), 100.0, "the pill fills to 100 and no further")
	lc.add_road_purity(gd, "hoa", 1.5)
	lc.raise_purity(gd, "hoa", 6)
	assert_eq(lc.purity("hoa"), 101.5, "a pill never lowers a purity roads raised past 100")


func test_fruit_onto_a_road_raised_element_ac_lc_57() -> void:
	var gd := game_data()
	var lc := _lc({"hoa": 70})
	lc.add_road_purity(gd, "kim", 40.0)
	lc.add_element("kim", 28.0)
	assert_eq(lc.purity("kim"), 40.0, "owned at 40, nothing lost")
	var lc2 := _lc({"hoa": 70})
	lc2.add_road_purity(gd, "kim", 15.0)
	lc2.add_element("kim", 28.0)
	assert_eq(lc2.purity("kim"), 28.0, "owned at 28")


func test_saves_keep_road_purity_and_read_old_ints() -> void:
	var gd := game_data()
	var lc := _lc({"hoa": 30})
	lc.add_road_purity(gd, "hoa", 0.5)
	var back := LinhCan.from_dict(JSON.parse_string(JSON.stringify(lc.to_dict())))
	assert_eq(back.purity("hoa"), 30.5, "round trip")
	var old := LinhCan.from_dict({"elements": {"hoa": 70}, "variants": {}, "rolled": [], "declined": []})
	assert_eq(old.purity("hoa"), 70.0, "an old integer save reads as a float with no road purity")


func test_display_rounds_whole_numbers_only() -> void:
	assert_eq(LinhCan.fmt(30.0), "30", "whole")
	assert_eq(LinhCan.fmt(30.5), "30.5", "one decimal")
	var gd := game_data()
	var lc := _lc({"hoa": 30})
	lc.add_road_purity(gd, "hoa", 0.5)
	assert_true(lc.describe(gd).contains("30.5"), "the root line shows 30.5")
