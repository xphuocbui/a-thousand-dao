extends DaoTestSuite
## Land qi on continent 11 (design/gdd/travel-map.md rules 3-5, Formulas A and C; tools/design/map/land_qi.py): every
## place carries Formula C's built qi, the grid's qi layers agree with it, and Formula A's land match multiplies the
## cultivation rate without a ceiling, floored at match_land_min.

const SEAT := 1   # Thúy Vi Tông, a great seat


func _cont() -> Dictionary:
	return game_data().file("world_continent")


func _mu() -> Dictionary:
	return _cont().mu


func test_every_place_has_built_qi_in_range() -> void:
	var places: Array = _cont().places
	assert_true(places.size() >= 200, "the continent's places")
	for p in places:
		assert_true(p.has("qi"), "%s has qi" % p.name)
		var d: float = float(p.density)
		assert_true(d >= 0.3 and d <= 2.4, "%s density %.3f in 0.3-2.4" % [p.name, d])
		assert_true(int(p.danger) >= 1, "%s danger at least 1" % p.name)
		var total: float = 0.0
		for e in p.qi.shares:
			total += float(p.qi.shares[e])
		assert_near(total, 100.0, 0.5, "%s base shares sum to 100" % p.name)


func test_world_means_of_the_base_elements_sum_to_one() -> void:
	var total: float = 0.0
	for e in ["moc", "hoa", "tho", "kim", "thuy"]:
		total += float(_mu()[e])
	assert_near(total, 1.0, 0.01, "Formula A: base mu_e sum to 1")


func test_the_grid_qi_layers_match_the_place_records() -> void:
	var g := ContinentGrid.from_continent(game_data())
	assert_true(g.errors.is_empty(), "grid and qi load: %s" % str(g.errors))
	assert_true(g.has_qi(), "qi layers loaded")
	var p: Dictionary = _cont().places.filter(func(x): return int(x.id) == SEAT)[0]
	var q: Dictionary = g.part_qi(int(p.tile[0]), int(p.tile[1]), int(p.qi.part))
	assert_near(float(q.density), float(p.qi.land_density), 0.002, "the part's density is the place's land density")
	assert_near(float(q.shares.kim), float(p.qi.shares.kim), 0.02, "and its Metal share")
	var t: Dictionary = g.tile_qi(int(p.tile[0]), int(p.tile[1]))
	assert_true(float(t.density) > 0.0, "a tile reads its land parts")


func test_land_match_follows_formula_a() -> void:
	var gd := game_data()
	var c := TestFixtures.character({"hoa": 86.0, "moc": 40.0, "thuy": 10.0})
	var qi := {"shares": {"moc": 0.0, "hoa": 66.0, "tho": 27.0, "kim": 7.0, "thuy": 0.0}, "variants": {}}
	var mu: Dictionary = _mu()
	var want: float = 1.0
	for e in ["hoa", "moc", "thuy"]:
		want += c.linh_can.purity(e) / 100.0 * (float(qi.shares[e]) / 100.0 - float(mu[e]))
	assert_near(LandQi.land_match(c, gd, qi).total, want, 0.0001, "1 + k sum q_e (s_e/100 - mu_e), k = 1")


func test_land_match_has_no_ceiling_and_a_floor() -> void:
	var gd := game_data()
	var pure := TestFixtures.character({"moc": 200.0})
	var wood := {"shares": {"moc": 90.0, "hoa": 2.0, "tho": 3.0, "kim": 2.0, "thuy": 3.0}, "variants": {}}
	assert_true(LandQi.land_match(pure, gd, wood).total > 2.0, "purity 200 on Wood 90 ground passes x2: no ceiling")
	var floor_v: float = float(gd.file("world_map").match.match_land_min)
	var none := {"shares": {"moc": 0.0, "hoa": 25.0, "tho": 25.0, "kim": 25.0, "thuy": 25.0}, "variants": {}}
	assert_near(LandQi.land_match(pure, gd, none).total, floor_v, 0.0001, "mismatched ground stops at the floor")


func test_road_purity_counts_at_the_unowned_rate() -> void:
	var gd := game_data()
	var c := TestFixtures.character({"hoa": 60.0})
	c.linh_can.add_road_purity(gd, "kim", 20.0)
	var qi := {"shares": {"moc": 0.0, "hoa": 0.0, "tho": 0.0, "kim": 100.0, "thuy": 0.0}, "variants": {}}
	var mu: Dictionary = _mu()
	var u: float = float(gd.file("world_map").match.match_unowned_rate)
	var want: float = 1.0 + 0.6 * (0.0 - float(mu.hoa)) + u * c.linh_can.purity("kim") / 100.0 * (1.0 - float(mu.kim))
	assert_near(LandQi.land_match(c, gd, qi).total, want, 0.0001, "unowned Metal from roads counts at u = 0.5")


func test_a_place_without_qi_leaves_the_rate_unchanged() -> void:
	var gd := game_data()
	var c := TestFixtures.character({"hoa": 60.0})
	var sh := StatSheet.build(c, gd, null, TestFixtures.tree())
	var plain: float = CultivationRules.rate_per_season(c, gd, null, sh, 1.0).total
	assert_near(CultivationRules.rate_per_season(c, gd, null, sh, 1.0, false, {}).total, plain, 0.0001, "x1 without qi")
	var fire := {"shares": {"moc": 0.0, "hoa": 80.0, "tho": 20.0, "kim": 0.0, "thuy": 0.0}, "variants": {}}
	var m: float = LandQi.land_match(c, gd, fire).total
	assert_near(CultivationRules.rate_per_season(c, gd, null, sh, 1.0, false, fire).total, plain * m, 0.001, "times the match")
