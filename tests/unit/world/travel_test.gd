extends DaoTestSuite
## Travel (design/gdd/travel-map.md rules 10-12, Formula D; user decision 2026-11-20): any reachable place by the
## quickest path; a trip of T seasons spends ceil(T) seasons and the rest of the last one cultivates at the
## destination.


func _line_db() -> WorldDB:
	# A - B - C by road (0.3 + 0.4 seasons), and A - C by a slow lane (0.9)
	var db := WorldDB.new()
	for n in ["A", "B", "C", "D"]:
		db.add("places", {"id": "l%s" % n, "name": n, "links": [], "density": 1.0})
	var link := func(a: String, b: String, t: float) -> void:
		db.get_record("places", a).links.append({"to": b, "seasons": t})
		db.get_record("places", b).links.append({"to": a, "seasons": t})
	link.call("lA", "lB", 0.3)
	link.call("lB", "lC", 0.4)
	link.call("lA", "lC", 0.9)
	return db


func test_the_quickest_path_wins_over_the_direct_slow_one() -> void:
	var r: Dictionary = Travel.quickest(_line_db(), "lA", "lC")
	assert_eq(r.path, ["lA", "lB", "lC"], "two legs by road")
	assert_near(float(r.seasons), 0.7, 0.0001, "0.3 + 0.4 seasons")
	assert_eq(int(r.hops), 2, "two legs")


func test_speed_divides_the_trip_and_the_floor_holds() -> void:
	var gd := game_data()
	assert_near(Travel.speed_factor(gd, 40.0), 1.4, 0.0001, "1 + tsp / 100")
	assert_near(Travel.speed_factor(gd, -200.0), float(gd.file("travel_rules").travel_speed_floor), 0.0001, "never below f_min")
	var r: Dictionary = Travel.quickest(_line_db(), "lA", "lC", 1.4)
	assert_near(float(r.seasons), 0.5, 0.0001, "0.7 / 1.4")


func test_an_unreachable_or_same_place_has_no_route() -> void:
	assert_true(Travel.quickest(_line_db(), "lA", "lD").is_empty(), "D has no link")
	assert_true(Travel.quickest(_line_db(), "lA", "lA").is_empty(), "already there")


func test_a_trip_spends_whole_seasons_and_the_last_ones_share() -> void:
	assert_eq(Travel.split(0.7), {"seasons": 1, "last_share": 0.7}, "a short hop: one season, 30 % of it left")
	var s: Dictionary = Travel.split(1.852)
	assert_eq(int(s.seasons), 2, "Formula D's example: season 2 ...")
	assert_near(float(s.last_share), 0.852, 0.0001, "... is 85.2 % travel")
	assert_eq(Travel.split(2.0), {"seasons": 2, "last_share": 1.0}, "a whole number leaves nothing over")


func _session(origin: String, home: String = "") -> GameSession:
	var gd := game_data()
	var llm := LlmService.new(gd)
	llm.enabled = false
	var s := GameSession.new(gd, llm, TestFixtures.tree())
	s.new_game(4242, {"mode": "roll", "name": "Lữ", "gender": "male", "origin": origin, "home": home})
	s.pending_event = {}
	return s


func test_a_short_hop_takes_one_season_and_cultivates_the_rest() -> void:
	var s := _session("tan_tu")
	var here: Dictionary = s.db.get_record("places", s.player.location_id)
	var link: Dictionary = here.links[0]
	for l in here.links:
		if float(l.seasons) < float(link.seasons):
			link = l
	var year0: int = s.year * 4 + s.season
	var tu_vi0: float = s.player.tu_vi
	var r: Dictionary = s.travel(str(link.to))
	assert_true(r.ok, "travelled: %s" % str(r.lines))
	assert_eq(s.player.location_id, str(link.to), "arrived")
	assert_eq(s.year * 4 + s.season - year0, 1, "a hop under a season spends one season")
	if not CultivationRules.at_bottleneck(s.player, s.gd):
		assert_true(s.player.tu_vi > tu_vi0 or s.player.level > 0, "the rest of the season cultivates at the destination")
		assert_true(r.lines.any(func(x): return str(x).contains("cultivate there")), "and says so")


func test_any_reachable_place_can_be_reached_in_one_order() -> void:
	var s := _session("tan_tu")
	var far: Dictionary = {}
	var best: float = 0.0
	for p in s.db.all("places"):
		if not s.knowledge.knows_place(str(p.id)):
			continue
		var q: Dictionary = Travel.quickest(s.db, s.player.location_id, str(p.id))
		if not q.is_empty() and int(q.hops) > 1 and float(q.seasons) > best:
			best = float(q.seasons)
			far = p
	assert_false(far.is_empty(), "a known place several legs away")
	var r: Dictionary = s.travel(str(far.id))
	assert_true(r.ok, "one order: %s" % str(r.lines))
	assert_eq(s.player.location_id, str(far.id), "arrived far away")


func test_each_origin_starts_at_one_of_its_approved_homes() -> void:
	var cont: Dictionary = game_data().file("world_continent")
	for origin in ["tong_mon", "tan_tu", "gia_toc"]:
		var s := _session(origin)
		var home: Dictionary = s.db.get_record("places", s.player.home_id)
		var ids: Array = Array(cont.origin_homes[origin]).map(func(x): return int(x))
		assert_true(ids.has(int(home.continent_id)), "%s starts at an approved home (%s)" % [origin, home.name])
		if origin == "tong_mon":
			assert_eq(str(s.player.sect_id), str(home.sect_id), "a disciple belongs to the sect of that seat")
	var chosen: int = int(cont.origin_homes.tong_mon[3])
	var s2 := _session("tong_mon", str(chosen))
	assert_eq(int(s2.db.get_record("places", s2.player.home_id).continent_id), chosen, "a chosen seat is honoured")


func test_a_teleport_jump_costs_formula_k_and_a_twentieth_of_a_season() -> void:
	var s := _session("tan_tu")
	var arrays: Array = s.db.find("places", func(p): return bool(p.get("array", false)))
	assert_true(arrays.size() >= 2, "array cities")
	s.player.location_id = str(arrays[0].id)
	var fee: Dictionary = s.teleport_fee(str(arrays[1].id))
	var d: int = maxi(absi(int(arrays[0].tile[0]) - int(arrays[1].tile[0])), absi(int(arrays[0].tile[1]) - int(arrays[1].tile[1])))
	var lt_max: float = float(s.gd.realm_budget(s.player.realm_index).linh_thach_max)
	assert_eq(int(fee.fee), int(round(lt_max * minf(0.05 + 0.0005 * float(d), 0.3))), "Formula K")
	s.player.linh_thach = int(fee.fee) + 5
	var r: Dictionary = s.teleport(str(arrays[1].id))
	assert_true(r.ok, "jumped: %s" % str(r.lines))
	assert_eq(s.player.location_id, str(arrays[1].id), "arrived")
	assert_eq(s.player.linh_thach, 5, "paid the fee")
	assert_true(s.teleport_fee(str(s.db.find("places", func(p): return not bool(p.get("array", false)))[0].id)).is_empty(), "no array, no jump")
