extends DaoTestSuite
## The authored continent's game data (assets/data/world_continent.json; ContinentData), as the user approved it in
## design/map/continent-11: counts, cross-references, and the route network's reach (Travel & Map AC-TM-128).


func _cd() -> ContinentData:
	return ContinentData.from_game_data(game_data())


func test_the_shipped_continent_loads_with_no_broken_references() -> void:
	var cd := _cd()
	assert_eq(cd.errors.size(), 0, "no errors: %s" % "; ".join(cd.errors))
	assert_eq(cd.grid, Vector2i(540, 360), "the 540 x 360 grid")
	assert_near(cd.km_per_tile, 25.0, 1e-9, "25 km tiles")


func test_the_approved_counts() -> void:
	var cd := _cd()
	assert_eq(cd.regions.size(), 20, "20 regions")
	assert_eq(cd.great_sects.size(), 7, "7 great sects")
	assert_eq(cd.minor_sects.size(), 22, "22 minor sects")
	assert_eq(cd.places.size(), 212, "204 places and 8 sacred places")
	assert_eq(cd.arrays.size(), 7, "7 teleport arrays, one per great sect")
	var tiers := {1: 0, 2: 0}
	for k in cd.great_sects:
		tiers[int(cd.great_sects[k].tier)] += 1
	assert_eq(tiers, {1: 3, 2: 4}, "3 tier-1 and 4 tier-2 great sects")


func test_every_settlement_but_one_off_road_minor_seat_reaches_every_other_ac_tm_128() -> void:
	# Finding 2026-11-15: Hồng Lô Cốc, a minor seat on a landmass of its own, has no road and no port in the design
	# data (places.py's own reach check does not count minor seats). This pins it so a change shows.
	var cd := _cd()
	var settled: Array = cd.settled_ids()
	assert_eq(settled.size(), 180, "180 settlements")
	var main: Dictionary = cd.reachable_from(int(settled[0]))
	var cut: Array = settled.filter(func(id): return not main.has(id))
	assert_eq(cut.map(func(id): return str(cd.places[id].name)), ["Hồng Lô Cốc"], "the one cut-off settlement")
	assert_eq(str(cd.places[cut[0]].kind), "minor_seat", "a minor seat")


func test_routes_are_symmetric_and_have_lengths() -> void:
	var cd := _cd()
	for rt in cd.routes:
		assert_true(cd.neighbours(rt.a).any(func(n): return n.to == rt.b), "%d -> %d" % [rt.a, rt.b])
		assert_true(cd.neighbours(rt.b).any(func(n): return n.to == rt.a), "%d -> %d" % [rt.b, rt.a])
	var kinds := {}
	for rt in cd.routes:
		kinds[str(rt.kind)] = true
	assert_eq(kinds.keys().size(), 3, "roads, trunk roads and sea lanes")


func test_broken_references_are_named() -> void:
	var d: Dictionary = (game_data().file(ContinentData.DATA_FILE) as Dictionary).duplicate(true)
	(d.routes as Array).append({"a": 1, "b": 99999, "kind": "road", "tiles": 1.0, "km": 25.0})
	(d.regions as Array)[0]["holder"] = "nobody"
	var cd := ContinentData.from_dict(d)
	assert_true(Array(cd.errors).any(func(e): return e.contains("route 1-99999")), "the bad route: %s" % "; ".join(cd.errors))
	assert_true(Array(cd.errors).any(func(e): return e.contains("holder nobody")), "the bad holder")
	assert_false(ContinentData.from_dict({}).errors.is_empty(), "no data is an error")
