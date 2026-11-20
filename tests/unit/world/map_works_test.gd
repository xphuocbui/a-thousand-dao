extends DaoTestSuite
## Works on the land and developed ground (design/gdd/travel-map.md rules 8, 31-34; Formulas B, J and M).


func _session(origin: String = "tan_tu") -> GameSession:
	var gd := game_data()
	var llm := LlmService.new(gd)
	llm.enabled = false
	var s := GameSession.new(gd, llm, TestFixtures.tree())
	s.new_game(4242, {"mode": "roll", "name": "Thợ Đất", "gender": "male", "origin": origin})
	s.pending_event = {}
	return s


func test_formula_j_costs_grow_by_level() -> void:
	var gd := game_data()
	assert_eq(int(MapWorks.cost(gd, "spirit_grove", 1).lt), 2000, "level 1")
	assert_eq(int(MapWorks.cost(gd, "spirit_grove", 3).lt), 8000, "2,000 x 2^2")
	assert_eq(int(MapWorks.cost(gd, "spirit_grove", 3).seasons), 3, "a permanent work takes its level in seasons")
	assert_eq(int(MapWorks.cost(gd, "sect_array", 5).lt), int(round(3000.0 * pow(2.5, 4.0))), "3,000 x 2.5^4")
	assert_eq(int(MapWorks.cost(gd, "sect_array", 5).seasons), 1, "an upkept work takes one season")


func test_settlements_start_developed_and_homes_there_are_capped() -> void:
	var s := _session()
	var city: Array = s.db.find("places", func(p): return str(p.get("kind", "")) == "city")
	assert_near(float(city[0].qi.prebuilt), 0.30, 0.0001, "a city starts with +0.30 of layer-2 works")
	assert_true(bool(city[0].qi.settled), "settled ground")
	var st: Dictionary = LandQi.stacked_density(s.gd, s.player, city[0].qi, 1.7, 0.5)
	assert_near(float(st.total), 1.8, 0.0001, "a settled home stays below 1.8")
	var wild: Array = s.db.find("places", func(p): return str(p.get("kind", "")) == "peak")
	var w: Dictionary = LandQi.stacked_density(s.gd, s.player, wild[0].qi, 2.4, 1.0)
	assert_near(float(w.total), 3.0, 0.0001, "elsewhere only D_cap 3.0")


func test_a_cave_abode_on_open_wilderness_becomes_home() -> void:
	var s := _session()
	var here: Dictionary = s.db.get_record("places", s.player.location_id)
	s.player.linh_thach = 10000
	var tg := TravelGrid.of(s.gd)
	var target := Vector2i(-1, -1)
	for dx in range(2, 12):
		var t := Vector2i(int(here.tile[0]) + dx, int(here.tile[1]))
		if tg.passable(t) and s.db.find("places", func(p): return p.has("tile") and int(p.tile[0]) == t.x and int(p.tile[1]) == t.y).is_empty():
			target = t
			break
	assert_true(target.x >= 0, "open land near home")
	var r: Dictionary = s.open_abode(target.x, target.y)
	assert_true(r.ok, "opened: %s" % str(r.lines))
	var home: Dictionary = s.db.get_record("places", s.player.home_id)
	assert_eq(str(home.kind), "abode", "home is the new abode")
	assert_eq(home.tile, [target.x, target.y], "on its tile")
	assert_eq(str(home.owner_id), s.player.id, "owned by its founder")
	assert_true(s.knowledge.knows_place(str(home.id)), "on the player's map")
	var cost: int = int(round(float(s.gd.realm_budget(0).linh_thach_max) * 0.05))
	assert_eq(s.player.linh_thach, 10000 - cost, "Formula M's abode cost")


func test_a_held_place_takes_shared_works_and_density_rises() -> void:
	var s := _session()
	s.player.linh_thach = 100000
	var here: Dictionary = s.db.get_record("places", s.player.location_id)
	var tg := TravelGrid.of(s.gd)
	for dx in range(2, 12):
		var t := Vector2i(int(here.tile[0]) + dx, int(here.tile[1]) + 1)
		if tg.passable(t) and s.db.find("places", func(p): return p.has("tile") and int(p.tile[0]) == t.x and int(p.tile[1]) == t.y).is_empty():
			assert_true(s.open_abode(t.x, t.y).ok, "an abode to hold")
			break
	var home: Dictionary = s.db.get_record("places", s.player.home_id)
	var before: float = float(LandQi.stacked_density(s.gd, s.player, home.qi, float(home.density), 0.0).total)
	var mat: Dictionary = s.items.material("linh_moc_tam", 5)
	mat["owner_id"] = s.player.id
	s.db.add("items", mat)
	var r: Dictionary = s.build_work("spirit_grove")
	assert_true(r.ok, "built: %s" % str(r.lines))
	var after: float = float(LandQi.stacked_density(s.gd, s.player, home.qi, float(home.density), 0.0).total)
	assert_near(after - before, 0.02, 0.0001, "a spirit grove level adds 0.02")
	var city: Array = s.db.find("places", func(p): return str(p.get("kind", "")) == "city")
	assert_false(MapWorks.holds(s.db, s.player, city[0]), "but nobody builds on a place they do not hold")


func test_a_residence_is_rented_by_formula_m_and_billed_each_season() -> void:
	var s := _session()
	var city: Dictionary = s.db.find("places", func(p): return str(p.get("kind", "")) == "city")[0]
	s.player.location_id = str(city.id)
	s.player.linh_thach = 1000
	var r: Dictionary = s.take_residence(2)
	assert_true(r.ok, "rented: %s" % str(r.lines))
	var res: Dictionary = city.qi.residences[s.player.id]
	assert_eq(int(res.grade), 2, "grade 2")
	assert_eq(s.player.home_id, str(city.id), "home there")
	var lt: int = s.player.linh_thach
	s.cultivate(4)
	assert_true(int(res.rent) > 0, "a rent is charged")
	assert_eq(s.player.linh_thach, lt - int(res.rent) * 4, "four seasons of rent are billed")
	assert_false(s.take_residence(4).ok, "grade 4 needs Kết Đan")
