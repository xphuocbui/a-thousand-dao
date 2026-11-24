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
	assert_eq(cd.minor_sects.size(), 43, "23 minor sects (Thu Phần Các added with the territory history, 2026-11-15) and the 20 provinces-v2 sects (2026-11-24)")
	assert_eq(cd.places.size(), 1494, "204 places, 8 sacred places, 17 ruins and one minor seat from the territory history, 24 lairs and special sites, and the 1,240 provinces-v2 places (2026-11-24)")
	assert_eq(cd.places.values().filter(func(p): return p.kind == "beast_lair" and not p.has("v2_slot")).size(), 14, "the approved beast lairs (sites.json, 2026-11-20)")
	assert_eq(cd.places.values().filter(func(p): return p.has("v2_slot")).size(), 1240, "the provinces-v2 places, appended after the authored ones")
	assert_eq(cd.arrays.size(), 7, "7 teleport arrays, one per great sect")
	var tiers := {1: 0, 2: 0}
	for k in cd.great_sects:
		tiers[int(cd.great_sects[k].tier)] += 1
	assert_eq(tiers, {1: 4, 2: 3}, "4 tier-1 and 3 tier-2 great sects (Thính Vũ Lâu promoted to tier 1, f5b6fa0)")


func test_every_settlement_but_two_off_road_minor_seats_reaches_every_other_ac_tm_128() -> void:
	# Findings: Hồng Lô Cốc (2026-11-15), a minor seat on a landmass of its own, has no road and no port in the design
	# data (places.py's own reach check does not count minor seats); Thu Phần Các (2026-11-20), the minor seat added with
	# the territory history (history_places.json), has no road drawn yet. Both are reached on foot once wilderness
	# travel exists (Travel & Map rule 10). This pins them so a change shows.
	var cd := _cd()
	var settled: Array = cd.settled_ids()
	assert_eq(settled.size(), 623, "181 settlements and 442 provinces-v2 ones (villages, towns, mines, sect seats)")
	var main: Dictionary = cd.reachable_from(int(settled[0]))
	var cut: Array = settled.filter(func(id): return not main.has(id))
	var old_cut: Array = cut.filter(func(id): return not cd.places[id].has("v2_slot"))
	assert_eq(old_cut.map(func(id): return str(cd.places[id].name)), ["Hồng Lô Cốc", "Thu Phần Các"], "the two cut-off authored settlements")
	for id in old_cut:
		assert_eq(str(cd.places[id].kind), "minor_seat", "%s is a minor seat" % cd.places[id].name)
	# provinces-v2 (2026-11-24): the new settlements reach the network by road or track, except those on a landmass
	# with no network (Hồng Lô Cốc's, the far south isles), reached once wilderness or sea travel exists
	assert_eq(cut.size() - old_cut.size(), 17, "17 new settlements on landmasses with no network")


func test_routes_are_symmetric_and_have_lengths() -> void:
	var cd := _cd()
	for rt in cd.routes:
		assert_true(cd.neighbours(rt.a).any(func(n): return n.to == rt.b), "%d -> %d" % [rt.a, rt.b])
		assert_true(cd.neighbours(rt.b).any(func(n): return n.to == rt.a), "%d -> %d" % [rt.b, rt.a])
	var kinds := {}
	for rt in cd.routes:
		kinds[str(rt.kind)] = true
	assert_eq(kinds.keys().size(), 4, "roads, trunk roads, sea lanes and tracks (provinces-v2, 2026-11-24)")


func test_broken_references_are_named() -> void:
	var d: Dictionary = (game_data().file(ContinentData.DATA_FILE) as Dictionary).duplicate(true)
	(d.routes as Array).append({"a": 1, "b": 99999, "kind": "road", "tiles": 1.0, "km": 25.0})
	(d.regions as Array)[0]["holder"] = "nobody"
	var cd := ContinentData.from_dict(d)
	assert_true(Array(cd.errors).any(func(e): return e.contains("route 1-99999")), "the bad route: %s" % "; ".join(cd.errors))
	assert_true(Array(cd.errors).any(func(e): return e.contains("holder nobody")), "the bad holder")
	assert_false(ContinentData.from_dict({}).errors.is_empty(), "no data is an error")


func test_trip_time_is_formula_d() -> void:
	var travel: Dictionary = game_data().file("travel_rules")
	# the GDD's example, its road part: 36 grassland road tiles (c_t 1) with travel_speed_pct +20
	assert_near(ContinentData.trip_seasons({"kind": "road", "cost": 36.0}, travel, 20.0), 36.0 / 64.8, 1e-9, "0.556 seasons")
	assert_near(ContinentData.trip_seasons({"kind": "lane", "cost": 90.0}, travel), 1.0, 1e-9, "90 sea tiles in a season")
	assert_near(ContinentData.trip_seasons({"kind": "road", "cost": 54.0}, travel, -90.0), 4.0, 1e-9, "the floor: never below x0.25")
	var cd := _cd()
	for rt in cd.routes:
		assert_true(float(rt.cost) >= float(rt.tiles) - 1e-6, "%d-%d: terrain never speeds a road (c_t >= 1)" % [rt.a, rt.b])


func test_each_origin_starts_where_the_fixed_world_decisions_say() -> void:
	# a sect disciple at any of the 30 seats (Thu Phần Các added 2026-11-15), a loose cultivator at one of the 10 markets, a clan heir in one of 7 towns
	var cd := _cd()
	var kinds := func(oid: String) -> Array:
		var out := {}
		for id in cd.origin_homes.get(oid, []):
			out[str(cd.places[id].kind)] = true
		var k: Array = out.keys()
		k.sort()
		return k
	assert_eq(cd.origin_homes.get("tong_mon", []).size(), 30, "30 seats")
	assert_eq(kinds.call("tong_mon"), ["great_seat", "minor_seat"], "only seats")
	assert_eq(cd.origin_homes.get("tan_tu", []).size(), 10, "10 markets")
	assert_eq(kinds.call("tan_tu"), ["market"], "only markets")
	assert_eq(cd.origin_homes.get("gia_toc", []).size(), 7, "7 clan towns")
	assert_eq(kinds.call("gia_toc"), ["town"], "only towns")


# --- The tile grid (ContinentGrid) --------------------------------------------------------------------------------

func _grid() -> ContinentGrid:
	return ContinentGrid.from_continent(game_data())


func test_the_grid_loads_every_layer_at_the_continents_size() -> void:
	var g := _grid()
	assert_eq(g.errors.size(), 0, "no errors: %s" % "; ".join(g.errors))
	assert_eq([g.width, g.height], [540, 360], "540 x 360")


func test_the_grid_agrees_with_the_places() -> void:
	# every place sits in its region's tiles, on its main biome, and a place on a road is on a road tile
	var g := _grid()
	var cd := _cd()
	var bad_region: Array = []
	var bad_biome: Array = []
	var bad_road: Array = []
	for id in cd.places:
		var p: Dictionary = cd.places[id]
		var x: int = int(p.tile[0])
		var y: int = int(p.tile[1])
		if g.region(x, y) != int(p.region):
			bad_region.append(str(p.name))
		if str(p.get("biome", "")) != "" and g.biome_name(g.main_biome(x, y)).replace("_", " ") != str(p.biome).to_lower():
			bad_biome.append("%s %s/%s" % [str(p.name), g.biome_name(g.main_biome(x, y)), str(p.biome)])
		if bool(p.get("on_road", false)) and g.road(x, y) == ContinentGrid.ROAD_NONE:
			bad_road.append(str(p.name))
	assert_eq(bad_region, [], "places in their regions")
	assert_eq(bad_biome, [], "places on their main biome")
	assert_eq(bad_road, [], "places on roads are on road tiles")


func test_land_tiles_have_shares_summing_to_100_and_values_in_range() -> void:
	var g := _grid()
	var odd: Array = []
	for y in range(0, g.height, 7):
		for x in range(0, g.width, 7):
			var mix: Array = g.biome_mix(x, y)
			var tot := 0
			for part in mix:
				tot += int(part[1])
			if tot != 100:
				odd.append("%d,%d sums %d" % [x, y, tot])
			if g.temperature_c(x, y) < -50.0 or g.temperature_c(x, y) > 77.5:
				odd.append("%d,%d temperature %.1f" % [x, y, g.temperature_c(x, y)])
	assert_eq(odd, [], "every sampled tile's mix sums to 100")
	var seat: Dictionary = _cd().places[int(_cd().great_sects["thien_xu"].seat)]
	assert_eq(g.elevation_m(int(seat.tile[0]), int(seat.tile[1])), 2070, "Thiên Xu Tông's seat at 2,070 m (politics: 2.07 km)")


func test_reading_the_continent_leaves_the_loaded_data_as_it_was() -> void:
	# a regression: from_dict turned the loaded file's ids into ints in place, and the world build stamped its record
	# ids ("_db") into those same region dictionaries
	var d: Dictionary = (game_data().file(ContinentData.DATA_FILE) as Dictionary).duplicate(true)
	(d.regions as Array)[0]["id"] = float((d.regions as Array)[0].id)
	var before: String = JSON.stringify(d)
	var cd := ContinentData.from_dict(d)
	cd.regions[cd.regions.keys()[0]]["_db"] = "probe"
	assert_eq(JSON.stringify(d), before, "the continent data is read, never written")
	assert_eq(typeof((d.regions as Array)[0].id), TYPE_FLOAT, "the source keeps its own id types")
