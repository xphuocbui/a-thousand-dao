extends DaoTestSuite
## Knowing and finding on continent 11 (design/gdd/travel-map.md rules 14-17 and 28-30, Formula F): the player starts
## knowing the overview and the home region, sees along their trips, hears rumours, searches with clues, and finds
## hidden places and tile secrets; a found blessed land's layer 3 turns on.


func _session(origin: String = "tan_tu") -> GameSession:
	var gd := game_data()
	var llm := LlmService.new(gd)
	llm.enabled = false
	var s := GameSession.new(gd, llm, TestFixtures.tree())
	s.new_game(4242, {"mode": "roll", "name": "Thám", "gender": "male", "origin": origin})
	s.pending_event = {}
	return s


func test_the_player_starts_knowing_the_overview_and_the_home_region() -> void:
	var s := _session()
	var k: MapKnowledge = s.knowledge
	assert_true(k != null, "a continent life carries map knowledge")
	var home: Dictionary = s.db.get_record("places", s.player.home_id)
	for p in s.db.all("places"):
		if bool(p.get("hidden", false)):
			assert_false(k.knows_place(str(p.id)), "a hidden place is known to no one (%s)" % p.name)
		elif str(p.get("kind", "")) in ["city", "great_seat", "minor_seat"]:
			assert_true(k.knows_place(str(p.id)), "every city and seat is common knowledge (%s)" % p.name)
		elif str(p.region_id) == str(home.region_id):
			assert_true(k.knows_place(str(p.id)), "the home region is known (%s)" % p.name)
	assert_true(k.knows_tile(int(home.tile[0]), int(home.tile[1])), "the home tile is known")


func test_sight_grows_with_divine_sense_as_formula_f_says() -> void:
	var gd := game_data()
	assert_eq(MapKnowledge.sight_radius(gd, 135.0), 4, "FE at DS 135: r 4")
	assert_eq(MapKnowledge.sight_radius(gd, 450.0), 8, "CF at DS 450: r 8")
	assert_eq(MapKnowledge.sight_radius(gd, 1.0e9), 36, "never past r_max")
	assert_near(MapKnowledge.detect(450.0, 300.0), 0.6, 0.0001, "p_detect = DS / (DS + H)")


func test_a_trip_reveals_tiles_and_places_along_the_way() -> void:
	var s := _session()
	var before: int = s.knowledge.known_tile_count()
	var target: Dictionary = {}
	for p in s.db.all("places"):
		if str(p.get("kind", "")) == "city" and str(p.region_id) != str(s.db.get_record("places", s.player.home_id).region_id):
			target = p
			break
	var r: Dictionary = s.travel(str(target.id))
	assert_true(r.ok, "travelled: %s" % str(r.lines))
	assert_true(s.knowledge.known_tile_count() > before, "the band along the path is known now")
	assert_true(s.knowledge.crossed_tile(int(target.tile[0]), int(target.tile[1])), "the arrival tile was crossed")


func test_an_unknown_place_cannot_be_travelled_to() -> void:
	var s := _session()
	var hidden: Array = s.db.find("places", func(p): return bool(p.get("hidden", false)))
	var r: Dictionary = s.travel(str(hidden[0].id))
	assert_false(r.ok, "no one travels to a place they have never heard of")


func test_formula_f_search_chance_matches_the_example() -> void:
	# Formula F's example: CF, DS 450 (r 8), H 300 (p 0.6), a jade slip over 400 tiles of cost-1 ground: 37 % a season
	var gd := game_data()
	var slip := {"kind": "jade_slip", "quality": 1.0}
	var p: float = Discovery.search_chance(gd, slip, 450.0, 300.0, 1.0, 0, 1.0)
	assert_near(p, 1.0 - exp(-1.0 * 18.0 * 17.0 * 0.6 / 400.0), 0.0001, "1 - exp(-q (v/c) (2r+1) p / A)")
	assert_near(p, 0.37, 0.01, "about 37 %")
	assert_eq(Discovery.search_chance(gd, {"kind": "rumour", "quality": 1.0, "false": true}, 450.0, 300.0, 1.0, 8000, 1.0), 0.0, "a false clue never finds")


func test_an_exact_map_finds_the_place_on_arrival_and_a_blessed_land_turns_on() -> void:
	var s := _session()
	var led: Dictionary = Discovery.ledger(s.db)
	var slot: String = ""
	for k in led:
		if str(led[k].get("kind", "")) == "blessed_small":
			slot = str(k)
			break
	assert_true(slot != "", "a small blessed land slot")
	var place: Dictionary = s.db.get_record("places", str(led[slot].place_id))
	s.knowledge.clues.append({"slot": slot, "kind": "map", "region": str(place.region_id), "quality": 1.5, "false": false})
	var r: Dictionary = s.travel(str(place.id))
	assert_true(r.ok, "a map lets you travel there: %s" % str(r.lines))
	assert_true(s.knowledge.found.has(slot), "arriving with an exact map is a sure find")
	assert_true(s.knowledge.knows_place(str(place.id)), "the place joins the map")
	assert_true(LandQi.active_layer3(place.qi).size() > 0, "its layer 3 is on for everyone there now")
	assert_true(s.db.events_of(str(place.id)).any(func(e): return str(e.type) == "discovery"), "the find is recorded")


func test_knowledge_survives_a_save() -> void:
	var s := _session()
	s.knowledge.clues.append({"slot": "R-1", "kind": "rumour", "region": "r1", "quality": 0.7, "false": false})
	var d: Dictionary = JSON.parse_string(JSON.stringify(s.to_dict()))
	var t := GameSession.new(game_data(), LlmService.new(game_data()), TestFixtures.tree())
	var res: Dictionary = t.load_dict(d)
	assert_true(res.ok, "loads: %s" % str(res.lines))
	assert_eq(t.knowledge.known_tile_count(), s.knowledge.known_tile_count(), "the same known tiles")
	assert_eq(t.knowledge.clues.size(), 1, "and clues")
	assert_eq(t.knowledge.places.size(), s.knowledge.places.size(), "and places")
