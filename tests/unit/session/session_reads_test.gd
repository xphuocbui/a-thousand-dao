extends DaoTestSuite
## ADR-0006 decision 1: reads never change the world. Every GameSession read method and Guidance read
## (StateSnapshot, Advisor, GameQuery) leaves to_dict() (which holds the World DB and the session random stream's state)
## exactly as it was. A small world with Power Rankings on, so the power reads have rating records to touch.

static var _on: GameData


static func _gd_on() -> GameData:
	if _on == null:
		_on = GameData.load_from("res://assets/data")
		_on.world_gen().people.world_cultivators = 80
		_on.world_gen().people.world_cultivators_min = 0
		var k: Dictionary = _on.file("combat_rankings")
		k["enabled"] = true
		k["season_fight_budget"] = 240
		k["worldgen_fight_budget"] = 120
	return _on


func _session() -> GameSession:
	var gd := _gd_on()
	var llm := LlmService.new(gd)
	llm.enabled = false
	var s := GameSession.new(gd, llm, TestFixtures.tree())
	s.new_game(5151, {"mode": "roll", "name": "Đọc Thử", "gender": "male", "origin": "tan_tu"})
	return s


static func _state(s: GameSession) -> String:
	return JSON.stringify(s.to_dict(), "", true)


func test_reading_the_power_of_a_stale_player_changes_nothing() -> void:
	# The player's build moves ahead of its rating between actions; the HUD then reads the power number. Before ADR-0006
	# that read synced the record, marked it Stale and ran the player's panel: the world changed because the UI looked.
	var s := _session()
	assert_eq(str(s.ratings.refresh_person(s.db.get_record("people", s.player.id)).state), RatingService.RATED, "precondition: the player is rated at world generation")
	s.player.level += 1   # the build changed (as between two actions)
	var before: String = _state(s)
	s.player_power()
	StateSnapshot.take(s)
	assert_eq(_state(s), before, "reading the power changed the world")
	s.shutdown()


func test_every_read_method_and_guidance_read_leaves_the_world_unchanged() -> void:
	var s := _session()
	var here: String = str(s.player.location_id)
	var other: String = ""
	for p in s.db.all("places"):
		if str(p.id) != here and p.has("tile"):
			other = str(p.id)
			break
	var npc: String = ""
	for p in s.db.all("people"):
		if not bool(p.get("is_player", false)) and bool(p.get("alive", true)):
			npc = str(p.id)
			break
	var reads := {
		"clock_label": func(): return s.clock_label(),
		"season_index": func(): return s.season_index(),
		"has_pending_event": func(): return s.has_pending_event(),
		"teleport_fee": func(): return s.teleport_fee(other),
		"clue_lines": func(): return s.clue_lines(),
		"abode_lines": func(): return s.abode_lines(),
		"work_lines": func(): return s.work_lines(),
		"array_lines": func(): return s.array_lines(),
		"ratings_on": func(): return s.ratings_on(),
		"player_power": func(): return s.player_power(),
		"power_of_person": func(): return s.power_of_person(npc),
		"place_density": func(): return s.place_density(here),
		"tree_starts": func(): return s.tree_starts(),
		"talisman_available": func(): return s.talisman_available(),
		"local_density": func(): return s.local_density(s.sheet()),
		"sheet": func(): return s.sheet(),
		"StateSnapshot.take": func(): return StateSnapshot.take(s),
		"Advisor.goals": func(): return Advisor.goals(s),
		"Advisor.progress": func(): return Advisor.progress(s),
		"Advisor.breakthrough_odds": func(): return Advisor.breakthrough_odds(s),
		"Advisor.actions": func(): return Advisor.actions(s),
		"Advisor.can_work_here": func(): return Advisor.can_work_here(s),
		"GameQuery.clock": func(): return GameQuery.clock(s),
		"GameQuery.player": func(): return GameQuery.player(s),
		"GameQuery.here": func(): return GameQuery.here(s),
		"GameQuery.place": func(): return GameQuery.place(s, other),
		"GameQuery.known_places": func(): return GameQuery.known_places(s),
		"GameQuery.people_met_at": func(): return GameQuery.people_met_at(s, here),
		"GameQuery.route_seasons": func(): return GameQuery.route_seasons(s, other),
		"GameQuery.has_clues": func(): return GameQuery.has_clues(s),
		"GameQuery.pending_event": func(): return GameQuery.pending_event(s),
		"GameQuery.market_lines": func(): return GameQuery.market_lines(s, here),
		"GameQuery.breakdown rate": func(): return GameQuery.breakdown(s, "rate"),
		"GameQuery.breakdown lifespan": func(): return GameQuery.breakdown(s, "lifespan"),
		"GameQuery.level_requirement": func(): return GameQuery.level_requirement(s),
		"GameQuery.travel_factor": func(): return GameQuery.travel_factor(s),
		"GameQuery.place_lines": func(): return GameQuery.place_lines(s, here),
		"GameQuery.sheet_lines": func(): return GameQuery.sheet_lines(s),
	}
	for name in reads:
		var before: String = _state(s)
		(reads[name] as Callable).call()
		assert_eq(_state(s), before, "%s changed the world" % name)
	s.shutdown()


func test_a_build_changing_action_refreshes_the_rating_and_opening_the_number_runs_no_panel_ac_pr_39() -> void:
	var s := _session()
	s.player.level += 1   # the build changed (as cultivating does) ...
	var starts: Array = s.tree_starts().filter(func(x): return bool(x.current))
	assert_true(not starts.is_empty(), "precondition: the player has a Đạo Đồ start")
	assert_true(bool(s.tree_choose_start(str(starts[0].key)).ok), "... then an action that can change the build runs")
	var rec: Dictionary = s.db.get_record(RatingService.TABLE, s.player.id)
	assert_eq(str(rec.state), RatingService.RATED, "the action ran the player's panel for the new build")
	assert_eq(str(rec.get("sig", "")), s.ratings.build_sig(s.db.get_record("people", s.player.id)), "rated for the build it has now")
	var before: String = _state(s)
	s.player_power()
	s.player_power()
	assert_eq(_state(s), before, "opening the power number twice runs no panel")
	s.shutdown()


func test_run_hands_back_the_events_of_the_action() -> void:
	var s := _session()
	var r: Dictionary = s.run(func():
		s._end_life("a test")
		return {"ok": true, "lines": []})
	var kinds: Array = Array(r.events).map(func(e): return str(e.kind))
	assert_true(kinds.has("life_ended"), "the end of the life is in the result")
	assert_eq(str((r.events[kinds.find("life_ended")] as Dictionary).summary.cause), "a test")
	var r2: Dictionary = s.run(func(): return null)
	assert_true(not bool(r2.ok) and Array(r2.events).is_empty(), "a non-Dictionary result is a failed action, and events do not carry over")
	s.shutdown()


func test_game_query_returns_deep_copies_so_changing_one_leaves_the_world_alone() -> void:
	var s := _session()
	var before: String = _state(s)
	var h: Dictionary = GameQuery.here(s)
	assert_true(h.has("qi") and not (h.qi as Dictionary).is_empty(), "precondition: the place has a qi table")
	(h.qi as Dictionary)[(h.qi as Dictionary).keys()[0]] = -999   # a nested value
	h["name"] = "changed"
	for p in GameQuery.known_places(s):
		(p as Dictionary)["name"] = "changed"
	var ev: Dictionary = GameQuery.pending_event(s)
	ev["title"] = "changed"
	assert_eq(_state(s), before, "a copy reached the world")
	assert_true(str(GameQuery.here(s).name) != "changed", "the place's name is untouched")
	s.shutdown()
