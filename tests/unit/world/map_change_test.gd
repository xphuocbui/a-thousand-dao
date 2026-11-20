extends DaoTestSuite
## How the map changes (design/gdd/travel-map.md rule 26): secret realms on cycles, territory changing hands, scars.


func test_a_cycled_realm_is_open_for_its_seasons_and_rumoured_ahead() -> void:
	var place := {"name": "Thử Cảnh", "cycle": {"every_seasons": 40, "open_seasons": 3, "rumour_lead": 4}}
	var open_count: int = 0
	var t_open: int = -1
	for t in 40:
		var st: Dictionary = MapChange.realm_state(place, t, "seed")
		if bool(st.open):
			open_count += 1
			if t_open < 0:
				t_open = t
	assert_eq(open_count, 3, "open 3 seasons in every 40")
	var db := WorldDB.new()
	var id: String = db.add("places", place.duplicate(true))
	var rumoured: bool = false
	for t in 80:
		var news: Array = MapChange.season(db, t / 4, t % 4, "seed")
		if news.any(func(x): return str(x).contains("sẽ mở")):
			rumoured = true
	assert_true(rumoured, "a rumour runs ahead of an opening")
	assert_true(db.events_of(id).any(func(e): return str(e.type) == "realm_opened"), "openings are recorded")


func test_the_timing_differs_by_game_and_the_gate_does_not_move() -> void:
	var place := {"name": "Thiết Mã Cảnh", "cycle": {"every_seasons": 120, "open_seasons": 4}}
	var a: Array = []
	var b: Array = []
	for t in 120:
		a.append(bool(MapChange.realm_state(place, t, "1").open))
		b.append(bool(MapChange.realm_state(place, t, "2").open))
	assert_true(a != b, "another seed opens it at other times")


func test_territory_moves_with_its_places_and_is_recorded() -> void:
	var db := WorldDB.new()
	var s1: String = db.add("sects", {"name": "A"})
	var s2: String = db.add("sects", {"name": "B"})
	var p: String = db.add("places", {"name": "Thôn", "holder": s1, "territory": s1})
	var r: String = db.add("regions", {"name": "Vùng", "holder": s1, "places": [p]})
	assert_true(MapChange.transfer(db, r, s2, 1201, 0, "a war"), "moved")
	assert_eq(str(db.get_record("places", p).holder), s2, "the region's places go with it")
	assert_true(db.all("events").any(func(e): return str(e.type) == "territory_change"), "a territory change event")


func test_a_scar_changes_the_land_for_good() -> void:
	var db := WorldDB.new()
	var p: String = db.add("places", {"name": "Cốc", "density": 1.2, "qi": {"shares": {"moc": 40.0, "hoa": 10.0, "tho": 20.0, "kim": 10.0, "thuy": 20.0}}})
	assert_true(MapChange.scar(db, p, -0.3, {"hoa": 30.0}, 1201, 0, "a great battle"), "scarred")
	var rec: Dictionary = db.get_record("places", p)
	assert_near(float(rec.density), 0.9, 0.0001, "density down 0.3")
	var tot: float = 0.0
	for e in rec.qi.shares:
		tot += float(rec.qi.shares[e])
	assert_near(tot, 100.0, 0.001, "shares renormalised")
	assert_true(float(rec.qi.shares.hoa) > 10.0, "a Fire crater")
	assert_eq(rec.scars.size(), 1, "stored on the place")
