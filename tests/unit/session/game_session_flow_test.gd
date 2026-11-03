extends DaoTestSuite
## GameSession end-to-end through the public API with the LLM disabled (templates only).
## Deterministic: fixed seeds.


func _session(seed_v: int = 4242) -> GameSession:
	var gd := game_data()
	var llm := LlmService.new(gd)
	llm.enabled = false
	var s := GameSession.new(gd, llm, TestFixtures.tree())
	s.new_game(seed_v, {"mode": "roll", "name": "Thử Nghiệm", "gender": "male", "origin": "gia_toc"})
	return s


func test_new_game_registers_player_and_world() -> void:
	var s := _session()
	assert_true(s.db.count("people") > 50, "people generated: %d" % s.db.count("people"))
	assert_true(s.db.count("events") > 100, "history generated: %d" % s.db.count("events"))
	assert_eq(s.db.get_record("people", s.player.id).name, "Thử Nghiệm", "player in people table")
	assert_true(s.player.cong_phap_id != "", "starting công pháp")
	assert_true(not s.field.planted(s.player).is_empty(), "gia tộc starts with planted herbs")


func test_same_seed_same_world() -> void:
	var a := _session(99)
	var b := _session(99)
	assert_eq(a.db.count("people"), b.db.count("people"), "people")
	assert_eq(a.db.count("events"), b.db.count("events"), "events")
	assert_eq(a.player.linh_can.to_dict(), b.player.linh_can.to_dict(), "player root")


func test_cultivate_passes_time_and_gains_tu_vi() -> void:
	var s := _session()
	s.pending_event = {}
	var age_before: float = s.player.age
	var r: Dictionary = s.cultivate(1)
	assert_true(r.ok, "ok")
	assert_near(s.player.age - age_before, 0.25, 0.001, "one season")
	assert_true(s.player.tu_vi > 0.0 or s.player.stage > 0, "tu vi gained")


func test_herbs_age_with_time() -> void:
	var s := _session()
	var planted: Dictionary = s.field.planted(s.player)
	var first: Dictionary = planted.values()[0]
	var before: float = float(first.age)
	s.closed_door(1)
	assert_true(float(first.age) > before + 0.9, "aged about a year or more: %f -> %f" % [before, float(first.age)])


func test_template_event_resolves_and_is_logged() -> void:
	var s := _session()
	s.pending_event = {}
	s.start_event("tam_ma_xam_nhap")
	if not s.has_pending_event():
		# requires tâm ma >= 20 when picked randomly, but forcing by id bypasses eligibility
		fail("forced template did not produce an event")
		return
	var before: int = s.db.events_of(s.player.id).size()
	var r: Dictionary = s.choose(1)
	assert_true(r.ok, "choose ok")
	assert_false(s.has_pending_event(), "cleared")
	assert_eq(s.db.events_of(s.player.id).size(), before + 1, "story event logged for the player")


func test_save_load_round_trip() -> void:
	var s := _session()
	s.cultivate(2)
	var d: Dictionary = s.to_dict()
	var json: String = JSON.stringify(d)
	var parsed: Dictionary = JSON.parse_string(json)
	var gd := game_data()
	var llm := LlmService.new(gd)
	llm.enabled = false
	var t := GameSession.new(gd, llm, TestFixtures.tree())
	var r: Dictionary = t.load_dict(parsed)
	assert_true(r.ok, "loaded")
	assert_eq(t.player.name, s.player.name, "player")
	assert_near(t.player.tu_vi, s.player.tu_vi, 0.001, "tu vi")
	assert_eq(t.year, s.year, "year")
	assert_eq(t.db.count("items"), s.db.count("items"), "items")
	assert_eq(t.rng.state, s.rng.state, "rng state restored exactly")


func test_event_where_every_choice_costs_still_has_a_free_exit() -> void:
	# Regression: an LLM event whose every choice costs linh thạch could not be
	# answered by a broke player, and nothing else could happen until it was (softlock).
	var s := _session()
	s.player.linh_thach = 0
	var ctx: Dictionary = EventContext.build(s.player, s.gd, s.db, s.sheet(), s.year, s.season, "vi")
	var raw := {
		"title": "Trạm thu phí", "text": "Muốn qua phải nộp linh thạch.",
		"choices": [
			{"label": "Nộp", "always": [{"type": "linh_thach", "amount": -10}], "success": {"text": "Qua.", "effects": []}},
			{"label": "Nộp nhiều", "always": [{"type": "linh_thach", "amount": -20}], "success": {"text": "Qua nhanh.", "effects": []}},
		],
	}
	var ev: Dictionary = s.validator.normalize(raw, ctx, s.rng, "llm").event
	var affordable := 0
	for i in ev.choices.size():
		if s.resolver.can_choose(s.player, ev, i).ok:
			affordable += 1
	assert_true(affordable >= 1, "a broke player can always answer the event")


func test_validator_clamps_llm_overreach() -> void:
	var s := _session()
	var ctx: Dictionary = EventContext.build(s.player, s.gd, s.db, s.sheet(), s.year, s.season, "vi")
	var raw := {
		"title": "Kho báu", "text": "Một rương báu.",
		"npc": {"existing_id": "p999999"},
		"choices": [
			{"label": "Mở", "check": {"type": "stat", "stat": "ngo_tinh", "difficulty": 500},
				"success": {"text": "Giàu to", "effects": [{"type": "linh_thach", "amount": 999999}, {"type": "artifact", "grade": 9}, {"type": "summon_dragon"}]}},
			{"label": "Bỏ đi", "check": {"type": "combat"}},
		],
	}
	var res: Dictionary = s.validator.normalize(raw, ctx, s.rng, "llm")
	assert_true(res.ok, "still valid after clamping")
	var ev: Dictionary = res.event
	assert_eq(ev.npc_id, "", "nonexistent npc dropped")
	assert_eq(ev.choices[0].check.difficulty, 95.0, "difficulty clamped")
	var fx: Array = ev.choices[0].success.effects
	assert_eq(fx.size(), 2, "unknown effect dropped")
	assert_true(float(fx[0].amount) <= float(ctx.budget.linh_thach_max), "linh thạch clamped to budget")
	assert_true(int(fx[1].grade) <= int(ctx.budget.artifact_grade_max), "grade clamped")
	assert_eq(ev.choices[1].check.type, "stat", "combat without npc becomes a stat check")
	assert_true(res.warnings.size() >= 4, "clamps reported: %s" % str(res.warnings))
