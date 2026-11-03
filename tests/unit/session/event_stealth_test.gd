extends DaoTestSuite
## Stealth (from Ám / Vụ / Huyễn biến dị and a Kinh Mạch notable) helps evade checks:
## escape and hiding choices marked "evade" in templates or by the LLM.


func _session() -> GameSession:
	var gd := game_data()
	var llm := LlmService.new(gd)
	llm.enabled = false
	var s := GameSession.new(gd, llm, TestFixtures.tree())
	s.new_game(4242, {"mode": "roll", "name": "Ẩn", "gender": "male", "origin": "tan_tu"})
	s.pending_event = {}
	return s


func _stealthy(s: GameSession) -> void:
	s.player.linh_can.bien_di["am"] = 60.0


func test_stealth_raises_only_evade_checks() -> void:
	var s := _session()
	var plain: float = s.resolver.stat_check_chance(s.player, s.sheet(), "than_hon", 50.0, true).total
	_stealthy(s)
	var sh: StatSheet = s.sheet()
	assert_true(sh.total("stealth") > 0.0, "Ám biến dị gives stealth")
	var evade: float = s.resolver.stat_check_chance(s.player, sh, "than_hon", 50.0, true).total
	var normal: float = s.resolver.stat_check_chance(s.player, sh, "than_hon", 50.0, false).total
	assert_near(evade - plain, sh.total("stealth") * float(s.gd.budgets().check.stealth_per_point), 0.0001, "stealth bonus on evade")
	assert_near(normal, plain, 0.0001, "no bonus on other checks")


func test_validator_keeps_the_evade_flag_and_templates_use_it() -> void:
	var s := _session()
	var ctx: Dictionary = EventContext.build(s.player, s.gd, s.db, s.sheet(), s.year, s.season, "vi")
	var raw := {"title": "Truy sát", "text": "Có kẻ đuổi theo.", "choices": [
		{"label": "Ẩn mình", "check": {"type": "stat", "stat": "than_hon", "difficulty": 50, "evade": true}, "success": {"text": "Thoát.", "effects": []}},
		{"label": "Đối mặt", "check": {"type": "stat", "stat": "can_cot", "difficulty": 50}, "success": {"text": "Ổn.", "effects": []}},
	]}
	var ev: Dictionary = s.validator.normalize(raw, ctx, s.rng, "llm").event
	assert_true(bool(ev.choices[0].check.get("evade", false)), "evade kept")
	assert_false(bool(ev.choices[1].check.get("evade", false)), "absent means false")
	var evading: int = 0
	for t in s.gd.event_templates().templates:
		for ch in t.choices:
			if bool(ch.get("check", {}).get("evade", false)):
				evading += 1
	assert_true(evading >= 2, "escape choices in templates are marked evade: %d" % evading)


func test_choice_odds_show_the_stealth_bonus() -> void:
	var s := _session()
	_stealthy(s)
	s.pending_event = {"title": "x", "text": "", "npc_id": "", "place_id": s.player.location_id, "choices": [
		{"label": "Ẩn", "check": {"type": "stat", "stat": "than_hon", "difficulty": 50.0, "evade": true}, "always": [], "success": {"text": "", "effects": []}, "failure": {"text": "", "effects": []}},
		{"label": "Đi", "check": {"type": "none"}, "always": [], "success": {"text": "", "effects": []}, "failure": {"text": "", "effects": []}},
	]}
	var o: Dictionary = Advisor.choice_odds(s, 0)
	assert_true(str(o.text).contains("stealth"), "odds text names stealth: %s" % o.text)
	assert_near(float(o.chance), s.resolver.stat_check_chance(s.player, s.sheet(), "than_hon", 50.0, true).total, 0.0001, "card odds = resolver odds")
