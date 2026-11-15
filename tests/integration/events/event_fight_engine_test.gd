extends DaoTestSuite
## ADR-0001 step 4: an event's combat check runs a real fight when combat_rules.json fight_engine.enabled is on, with
## both sides compiled by FighterCompiler and the seed one draw from the session stream (ADR-0002 decision 3).


func _session(seed_v: int) -> GameSession:
	var gd := game_data()
	var llm := LlmService.new(gd)
	llm.enabled = false
	var s := GameSession.new(gd, llm, TestFixtures.tree())
	s.new_game(seed_v, {"mode": "roll", "name": "Kiếm", "gender": "male", "origin": "tan_tu"})
	return s


func _combat_event(s: GameSession, enemy_id: String) -> Dictionary:
	return {"title": "Thử", "text": "", "npc_id": enemy_id, "place_id": s.player.location_id, "choices": [
		{"label": "A", "check": {"type": "combat", "enemy": enemy_id}, "always": [], "success": {"text": "", "effects": []}, "failure": {"text": "", "effects": []}},
	]}


func _set_flag(gd: GameData, on: bool) -> void:
	gd.combat()["fight_engine"]["enabled"] = on


## Resolves one combat check; returns [result, the session stream's state before it, its state after it].
func _resolve(seed_v: int, on: bool) -> Array:
	var s := _session(seed_v)
	var enemy_id: String = s.builds.create_person(s.rng, {"realm_index": 0, "archetype": "kiem_tu", "location_id": s.player.location_id})
	_set_flag(s.gd, on)
	var before: int = s.rng.state
	var r: Dictionary = s.resolver.resolve(s.player, s.sheet(), s.rng, _combat_event(s, enemy_id), 0)
	_set_flag(s.gd, false)
	return [r, before, s.rng.state]


## The shipped flag is on (user decision 2026-11-15, commit 046dc4d); switched off, the duel roll still runs.
func test_the_flag_is_on_in_shipped_data_and_off_runs_the_duel() -> void:
	assert_true(bool(game_data().combat().fight_engine.enabled), "on in the shipped data")
	var r: Dictionary = _resolve(11, false)[0]
	assert_true(str(r.check_line).contains("chiến lực"), "the duel line: %s" % r.check_line)


func test_with_the_flag_on_a_fight_decides_the_check() -> void:
	var r: Dictionary = _resolve(11, true)[0]
	assert_true(str(r.check_line).begins_with("Combat: fight against"), "a fight ran: %s" % r.check_line)
	assert_eq(bool(r.success), str(r.check_line).contains("VICTORY"), "success is a win: %s" % r.check_line)


func test_a_fight_takes_exactly_one_draw_from_the_session_stream() -> void:
	# ADR-0002 decision 3: fight_seed = session_rng.randi(), and the fight's own draws never touch the session stream.
	# (The player carries no talismans, so the check makes no other draw; the duel's one draw is a randf.)
	for seed_v in [23, 24, 25]:
		var on: Array = _resolve(seed_v, true)
		assert_true(str(on[0].check_line).begins_with("Combat: fight against"), "the fight ran")
		var probe := RandomNumberGenerator.new()
		probe.state = on[1]
		probe.randi()
		assert_eq(on[2], probe.state, "seed %d: one randi() and nothing more" % seed_v)
		var off: Array = _resolve(seed_v, false)
		probe.state = off[1]
		probe.randf()
		assert_eq(off[2], probe.state, "seed %d: the duel's one randf()" % seed_v)


func test_the_same_seed_gives_the_same_fight() -> void:
	var a: Dictionary = _resolve(31, true)[0]
	var b: Dictionary = _resolve(31, true)[0]
	assert_eq(a.check_line, b.check_line, "same fight")


func test_the_debug_terminal_prints_the_last_fight_log() -> void:
	var s := _session(41)
	var io := TerminalIO.new()
	assert_true(str(TerminalViews.fight_log(s, io, 10)[0]).contains("No event fight yet"), "nothing before a fight")
	var enemy_id: String = s.builds.create_person(s.rng, {"realm_index": 0, "archetype": "kiem_tu", "location_id": s.player.location_id})
	_set_flag(s.gd, true)
	s.resolver.resolve(s.player, s.sheet(), s.rng, _combat_event(s, enemy_id), 0)
	_set_flag(s.gd, false)
	var r: FightResult = s.resolver.last_fight
	assert_true(r != null and r.log_rows.size() > 10, "the event fight kept its log")
	var lines: Array = TerminalViews.fight_log(s, io, 10)
	assert_eq(lines.size(), 11, "a heading and the last 10 rows")
	assert_true(str(lines[0]).contains("Fight:"), "the heading: %s" % lines[0])


func test_the_card_shows_the_fight_engines_own_odds_without_moving_the_stream() -> void:
	var s := _session(53)
	var enemy_id: String = s.builds.create_person(s.rng, {"realm_index": 0, "archetype": "kiem_tu", "location_id": s.player.location_id})
	s.pending_event = _combat_event(s, enemy_id)
	var duel: Dictionary = Advisor.choice_odds(s, 0)
	assert_true(str(duel.text).contains("chiến lực"), "flag off: the duel's odds")
	_set_flag(s.gd, true)
	var before: int = s.rng.state
	var a: Dictionary = Advisor.choice_odds(s, 0)
	var b: Dictionary = Advisor.choice_odds(s, 0)
	_set_flag(s.gd, false)
	assert_true(str(a.text).contains("trial fights"), "flag on: the fight engine's odds: %s" % a.text)
	assert_true(float(a.chance) >= 0.0 and float(a.chance) <= 1.0, "a share")
	assert_eq(a.chance, b.chance, "the same odds each time it is shown")
	assert_eq(s.rng.state, before, "showing odds never moves the session stream")
