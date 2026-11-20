extends DaoTestSuite
## Herb fit (design/gdd/travel-map.md rule 18, Formula G): the GDD's three examples, the labels, and a place without
## land qi growing as before.


func _place(t: float, r: float, shares: Dictionary, density: float = 1.1) -> Dictionary:
	# climate_index maps -20..30 C and 0..4000 mm onto 0..100: invert it for a wanted index
	return {"temp_c": -20.0 + t / 2.0, "rain_mm": r * 40.0, "density": density,
		"qi": {"shares": shares, "variants": {}}}


func test_hoa_linh_chi_on_a_volcano_is_excellent() -> void:
	var gd := game_data()
	var f: Dictionary = HerbFit.fit(gd, gd.herb("hoa_linh_chi"), _place(80.0, 20.0, {"moc": 0.0, "hoa": 60.0, "tho": 30.0, "kim": 10.0, "thuy": 0.0}))
	assert_near(float(f.fit), 1.0, 0.0001, "every factor 1")
	assert_eq(str(f.label), "excellent", "excellent")
	assert_near(float(f.growth), 1.2, 0.0001, "growth x1.2")


func test_hoa_linh_chi_on_a_glacier_cannot_be_planted() -> void:
	var gd := game_data()
	var f: Dictionary = HerbFit.fit(gd, gd.herb("hoa_linh_chi"), _place(5.0, 50.0, {"moc": 5.0, "hoa": 0.0, "tho": 15.0, "kim": 15.0, "thuy": 65.0}))
	assert_false(bool(f.plantable), "unplantable")
	assert_eq(str(f.label), "unplantable", "says so")
	assert_true(f.lines.any(func(x): return str(x).begins_with("temperature 5")), "and says why")


func test_thanh_tam_lien_in_a_temperate_forest_is_good() -> void:
	var gd := game_data()
	var f: Dictionary = HerbFit.fit(gd, gd.herb("thanh_tam_lien"), _place(55.0, 50.0, {"moc": 50.0, "hoa": 5.0, "tho": 10.0, "kim": 5.0, "thuy": 30.0}))
	assert_near(float(f.fit), 0.825 * (1.0 - 5.0 / 30.0), 0.001, "f_e 0.825 x f_R 0.833")
	assert_eq(str(f.label), "good", "good")
	assert_near(float(f.growth), 1.2 * float(f.fit), 0.0001, "growth x0.83")


func test_ground_without_qi_grows_as_before() -> void:
	var gd := game_data()
	var f: Dictionary = HerbFit.fit(gd, gd.herb("hoa_linh_chi"), {"density": 1.0})
	assert_eq(float(f.growth), 1.0, "x1 in an old generated world")
	assert_true(bool(f.plantable), "and plantable")


func test_a_field_grows_at_its_fit_on_continent_ground() -> void:
	var gd := game_data()
	var llm := LlmService.new(gd)
	llm.enabled = false
	var s := GameSession.new(gd, llm, TestFixtures.tree())
	s.new_game(4242, {"mode": "roll", "name": "Nông", "gender": "male", "origin": "gia_toc"})
	var home: Dictionary = s.db.get_record("places", s.player.home_id)
	var planted: Dictionary = s.field.planted(s.player)
	if planted.is_empty():
		return
	var item: Dictionary = planted.values()[0]
	var before: float = float(item.age)
	var mult: float = s.field.grow(s.player, s.sheet(), 4)
	var fit: Dictionary = HerbFit.fit(gd, gd.herb(str(item.template)), home)
	assert_near(float(item.age) - before, mult * float(fit.growth), 0.0001, "a year x the field multiplier x g_max x fit")
