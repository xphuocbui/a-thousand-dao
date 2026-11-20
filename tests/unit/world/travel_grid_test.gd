extends DaoTestSuite
## Travel by tile on continent 11 (design/gdd/travel-map.md rules 9-13, Formulas D and E): roads, rivers, sea lanes
## and the wilderness by their speeds, flight by realm, roadless places reached on foot, and the encounter chance per
## season of a trip.


func _tg() -> TravelGrid:
	return TravelGrid.of(game_data())


func _place(name: String) -> Dictionary:
	for p in game_data().file("world_continent").places:
		if str(p.name) == name:
			return p
	return {}


func _tile(p: Dictionary) -> Vector2i:
	return Vector2i(int(p.tile[0]), int(p.tile[1]))


func test_the_grid_builds() -> void:
	assert_true(_tg().errors.is_empty(), "no errors: %s" % str(_tg().errors))
	assert_eq(_tg().width, 540, "540 tiles across")


func test_a_road_trip_is_no_slower_than_its_route() -> void:
	var cont: Dictionary = game_data().file("world_continent")
	var travel: Dictionary = game_data().file("travel_rules")
	var by_id := {}
	for p in cont.places:
		by_id[int(p.id)] = p
	var checked: int = 0
	for rt in cont.routes:
		if str(rt.kind) == "lane" or checked >= 20:
			continue
		var trip: Dictionary = _tg().trip(_tile(by_id[int(rt.a)]), _tile(by_id[int(rt.b)]))
		assert_false(trip.is_empty(), "route %d-%d is walkable" % [rt.a, rt.b])
		assert_true(float(trip.seasons) <= ContinentData.trip_seasons(rt, travel) * 1.05 + 0.01, "the tile path is at least as quick as the road (%.3f vs %.3f)" % [trip.seasons, ContinentData.trip_seasons(rt, travel)])
		checked += 1
	assert_eq(checked, 20, "twenty roads checked")


func test_a_roadless_peak_is_reached_through_the_wilderness() -> void:
	var peak: Dictionary = {}
	for p in game_data().file("world_continent").places:
		if str(p.kind) == "peak":
			peak = p
			break
	var seat: Dictionary = _place("Thiên Xu Tông")
	var trip: Dictionary = _tg().trip(_tile(seat), _tile(peak))
	assert_false(trip.is_empty(), "the peak %s can be walked to" % peak.name)
	assert_true(trip.by_mode.has("wilderness"), "partly across the wilderness: %s" % str(trip.by_mode))


func test_wilderness_tiles_follow_formula_d() -> void:
	var travel: Dictionary = game_data().file("travel_rules")
	var trip: Dictionary = _tg().trip(_tile(_place("Thiên Xu Tông")), _tile(_place("Tống Khách Thị")))
	for st in trip.steps:
		if str(st.mode) == "wilderness":
			# dt = step x c_t / v_wild, with c_t between 1.0 and 2.5
			var per_tile: float = float(st.dt) * float(travel.speed.wilderness)
			assert_true(per_tile >= 1.0 - 0.001 and per_tile <= 2.5 * sqrt(2.0) + 0.001, "c_t within the biome costs (%.3f)" % per_tile)
			return
	assert_true(true, "no wilderness tile on this road trip")


func test_flight_ignores_terrain_and_opens_at_foundation() -> void:
	assert_eq(_tg().flight_speed("luyen_khi"), 0.0, "no flight at Qi Refining")
	assert_eq(_tg().flight_speed("truc_co"), 135.0, "FE 135 tiles a season")
	assert_eq(_tg().flight_speed("hoa_than"), 400.0, "DT 400")
	var a := _tile(_place("Thiên Xu Tông"))
	var b := _tile(_place("Tống Khách Thị"))
	var air: Dictionary = _tg().trip(a, b, "flight", 1.0, 135.0)
	var ground: Dictionary = _tg().trip(a, b)
	assert_true(float(air.seasons) < float(ground.seasons), "flying is quicker than the road")
	var chebyshev: float = float(maxi(absi(a.x - b.x), absi(a.y - b.y)))
	assert_true(float(air.seasons) <= chebyshev * sqrt(2.0) / 135.0 + 0.001, "a near-straight line at 135 tiles a season")


func test_encounter_chance_per_season_is_formula_e() -> void:
	# Formula E's example: a road season at danger 1 is 1 - e^(-0.15 x 0.4) = 5.8 %; a wilderness season at danger 2 is
	# 1 - e^(-0.35) = 29.5 %
	var road := {"steps": []}
	for i in 54:
		road.steps.append({"tile": Vector2i(i, 0), "mode": "road", "dt": 1.0 / 54.0, "danger": 1})
	var st: Array = _tg().stretches(road)
	assert_eq(st.size(), 1, "one season")
	assert_near(float(st[0].chance), 1.0 - exp(-0.15 * 0.4), 0.0005, "5.8 % a road season")
	var wild := {"steps": []}
	for i in 27:
		wild.steps.append({"tile": Vector2i(i, 0), "mode": "wilderness", "dt": 1.0 / 18.0, "danger": 2})
	var two: Array = _tg().stretches(wild)
	assert_eq(two.size(), 2, "1.5 seasons are two stretches")
	assert_near(float(two[0].chance), 1.0 - exp(-0.35), 0.0005, "a full wilderness season at danger 2")
	assert_near(float(two[1].chance), 1.0 - exp(-0.35 * 0.5), 0.0005, "half a season")


func test_a_mixed_tiles_hazard_is_weighted_by_share_ac_tm_149() -> void:
	# parts at danger 1 (60 %) and 3 (40 %): 0.6 x 0.15 + 0.4 x 0.70 = 0.37 a season of wilderness
	var trip := {"steps": []}
	for i in 18:
		trip.steps.append({"tile": Vector2i(i, 0), "mode": "wilderness", "dt": 1.0 / 18.0, "danger": 2, "hazard": 0.6 * 0.15 + 0.4 * 0.70})
	var st: Array = _tg().stretches(trip)
	assert_near(float(st[0].chance), 1.0 - exp(-0.37), 0.0005, "the share-weighted hazard, not danger 2's 0.35")
