extends DaoTestSuite
## CombatService and FightRequest (ADR-0001 decision 5; Combat GDD rule 3 and Edge Cases).


static func _request(gd: GameData, fight_seed: int) -> FightRequest:
	var req := FightRequest.new()
	req.a = FighterCompiler.from_data("typical", 1, gd)
	req.b = FighterCompiler.from_data("typical", 1, gd)
	req.fight_seed = fight_seed
	return req


func test_a_request_runs_one_seeded_fight() -> void:
	var gd := game_data()
	var service := CombatService.new(CombatConstants.from_game_data(gd))
	var r1: FightResult = service.resolve(_request(gd, 7))
	var r2: FightResult = service.resolve(_request(gd, 7))
	assert_true(r1 != null and service.errors.is_empty(), "runs")
	assert_eq(r1.t_ms, r2.t_ms, "the same seed gives the same fight")
	assert_true(r1.seconds >= 0.0 and r1.a_end != null and r1.b_end != null, "a full result")


func test_starting_shares_replace_the_full_start_for_side_a() -> void:
	# Combat rule 3: health_start = health_max x share, qi_start = qi_use x share. A low start loses more often.
	var gd := game_data()
	var service := CombatService.new(CombatConstants.from_game_data(gd))
	var full_wins := 0
	var low_wins := 0
	for s in 40:
		if service.resolve(_request(gd, s)).win_code() == "A":
			full_wins += 1
		var req := _request(gd, s)
		req.start_health_share = 0.4
		req.start_qi_share = 0.5
		if service.resolve(req).win_code() == "A":
			low_wins += 1
	assert_true(low_wins < full_wins, "starting at 40 percent health wins less: %d vs %d" % [low_wins, full_wins])


func test_requests_the_engine_cannot_run_are_refused_by_name() -> void:
	var gd := game_data()
	var service := CombatService.new(CombatConstants.from_game_data(gd))
	var cases := [
		["start_health_share", func(r: FightRequest) -> void: r.start_health_share = 0.0],
		["start_health_share", func(r: FightRequest) -> void: r.start_health_share = 1.5],
		["start_qi_share", func(r: FightRequest) -> void: r.start_qi_share = -0.1],
		["no_heal", func(r: FightRequest) -> void: r.no_heal = true],
	]
	for c in cases:
		var req := _request(gd, 1)
		c[1].call(req)
		assert_true(service.resolve(req) == null, "%s is refused" % c[0])
		assert_true("; ".join(service.errors).contains(c[0]), "the error names %s: %s" % [c[0], "; ".join(service.errors)])


func test_place_tags_are_ignored_once_and_tribulation_is_kept() -> void:
	# Combat rules 12, 26, AC-CB-104 (2026-11-26): a place tag applies nothing and is noted once as ignored; the fight
	# still runs. tribulation is kept (REQUEST_TAGS), so a rule could read it as tag.tribulation.
	var gd := game_data()
	var service := CombatService.new(CombatConstants.from_game_data(gd))
	var req := _request(gd, 1)
	req.ground_tags = [&"own_abode", &"vein", &"own_abode", &"tribulation"]
	var r: FightResult = service.resolve(req)
	assert_true(r != null, "the fight runs: %s" % "; ".join(service.errors))
	if r == null:
		return
	assert_eq(r.notes.size(), 2, "own_abode and vein, once each: %s" % str(r.notes))
	assert_true("; ".join(r.notes).contains("own_abode") and "; ".join(r.notes).contains("vein"))
	assert_false("; ".join(r.notes).contains("tribulation"), "tribulation is kept, not ignored")
