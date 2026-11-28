extends DaoTestSuite
## Wave 1 W1A unit tests for Event Engine (#23) Data & Core Rules:
## EventDataValidator (AC-EV-04, AC-EV-23, AC-EV-33, AC-EV-41, AC-EV-45, 54 trait event: hooks, 5 hidden chronicles),
## EventConditions (AC-EV-02, AC-EV-05, AC-EV-10, AC-EV-40),
## EventStore (AC-EV-15, pacing/cooldowns/once/stories/save round-trip),
## EventBudget (AC-EV-21..25), and EventValidator baseline (AC-EV-01, AC-EV-38).

const _EventStore = preload("res://src/gameplay/events/event_store.gd")
const _EventConditions = preload("res://src/gameplay/events/event_conditions.gd")
const _EventDataValidator = preload("res://src/gameplay/events/event_data_validator.gd")
const _EventBudget = preload("res://src/gameplay/events/event_budget.gd")


func _char(gd: GameData, realm_idx: int, fortune: int, cid: String = "p_root") -> Character:
	var c := Character.new()
	c.id = cid
	c.name = "Lâm Thanh"
	c.realm_index = realm_idx
	c.stage = 0
	c.level = int(Ladder.band(gd, realm_idx)[0])
	c.thien_phu = {
		"ngo_tinh": 50,
		"can_cot": 50,
		"than_hon": 50,
		"khi_van": fortune,
		"dao_tam": 50,
		"mi_luc": 50,
	}
	c.linh_can = LinhCan.new()
	c.linh_can.elements = {"moc": 50.0, "hoa": 50.0}
	return c


# --- AC-EV-41 & Full Shipped Dataset Validation --------------------------------------------------

func test_shipped_event_data_validates_cleanly_with_all_54_trait_hooks_and_5_hidden_chronicles_ac_ev_41() -> void:
	var gd := game_data()
	var res: Dictionary = _EventDataValidator.validate_all(gd)
	assert_true(bool(res.ok), "shipped event data validates with 0 errors: %s" % str(res.errors))
	assert_eq(res.errors, [], "zero validation errors")
	assert_eq(res.warnings, [], "zero validation warnings on shipped data: %s" % str(res.warnings))

	var trait_hooks: Array = _EventDataValidator.trait_event_hooks_in(gd)
	assert_eq(trait_hooks.size(), 54, "traits.json exposes exactly 54 unique event:* hooks")

	var hooks_doc: Dictionary = gd.file("events_hooks")
	assert_true(Array(hooks_doc.get("templates", [])).size() >= 70, "events_hooks.json has all trait, game-moment, follow-up, and NPC templates")
	var stories_doc: Dictionary = gd.file("events_stories")
	assert_true(Array(stories_doc.get("stories", [])).size() >= 10, "events_stories.json has 5 chronicle + 4 cast + 1 abode stories")
	assert_true(Array(stories_doc.get("events", [])).size() >= 30, "events_stories.json has all stage events")


# --- AC-EV-04, AC-EV-23, AC-EV-33, AC-EV-45: Strict Load-Time Rejections -------------------------

func test_data_validator_rejects_unknown_condition_place_kind_and_dao_an_effect_ac_ev_04() -> void:
	var gd := game_data()
	var bad_templates := {
		"templates": [
			{
				"id": "bad_rec_04",
				"kind": "pulse",
				"weight": 5,
				"place_kinds": ["thanh"],
				"conditions": {"type": "foo"},
				"title": "Tiêu đề thử",
				"text": "Nội dung thử.",
				"log": "{root} thử.",
				"choices": [
					{
						"label": "A",
						"check": {"type": "none"},
						"success": {"text": "Xong A.", "effects": [{"type": "treasure", "treasure": "dao_an"}]},
					},
					{
						"label": "B",
						"check": {"type": "none"},
						"success": {"text": "Xong B.", "effects": [{"type": "dao_an"}]},
					},
				],
			},
		],
	}
	var errs: Array[String] = []
	var warns: Array[String] = []
	_EventDataValidator.validate_event_record(bad_templates.templates[0], "events_templates", gd, errs, warns)
	assert_true(errs.any(func(s): return s.contains("events_templates") and s.contains("bad_rec_04") and s.contains("foo")),
		"unknown condition 'foo' rejected with file & id: %s" % str(errs))
	assert_true(errs.any(func(s): return s.contains("events_templates") and s.contains("bad_rec_04") and s.contains("thanh")),
		"retired place kind 'thanh' rejected with file & id: %s" % str(errs))
	assert_true(errs.any(func(s): return s.contains("events_templates") and s.contains("bad_rec_04") and s.contains("dao_an")),
		"retired effect 'dao_an' rejected with file & id: %s" % str(errs))


func test_data_validator_rejects_player_only_effect_on_npc_event_ac_ev_33() -> void:
	var gd := game_data()
	var npc_bad := {
		"id": "npc_cduyen_bad",
		"kind": "pulse",
		"npc_capable": true,
		"weight": 5,
		"place_kinds": ["any"],
		"title": "Sự kiện NPC sai",
		"text": "Nội dung.",
		"log": "{root} thử.",
		"choices": [
			{
				"label": "Nhận cơ duyên",
				"check": {"type": "none"},
				"success": {"text": "Nhận đan.", "effects": [{"type": "breakthrough_pill"}]},
			},
			{
				"label": "Bỏ qua",
				"check": {"type": "none"},
				"success": {"text": "Bỏ qua.", "effects": []},
			},
		],
	}
	var errs: Array[String] = []
	var warns: Array[String] = []
	_EventDataValidator.validate_event_record(npc_bad, "events_hooks", gd, errs, warns)
	assert_true(errs.any(func(s): return s.contains("npc_cduyen_bad") and s.contains("breakthrough_pill")),
		"AC-EV-33: npc_capable event with breakthrough_pill rejected: %s" % str(errs))


func test_data_validator_rejects_missing_secret_realm_closing_event_ac_ev_45() -> void:
	var gd := game_data()
	var hist: Dictionary = gd.file("world_history").duplicate(true)
	var sites: Array = Array(hist.get("famous_sites", [])).duplicate(true)
	sites.append({"name": "Huyền Băng Cảnh", "kind": "secret_realm"})
	hist["famous_sites"] = sites
	var res: Dictionary = _EventDataValidator.validate_dataset(
		gd, gd.file("events_templates"), gd.file("events_hooks"), gd.file("events_stories"), hist
	)
	assert_false(bool(res.ok), "AC-EV-45: missing secret realm closing event must fail load")
	assert_true(Array(res.errors).any(func(s): return str(s).contains("Huyền Băng Cảnh")),
		"AC-EV-45: error names missing secret realm: %s" % str(res.errors))


func test_data_validator_clamps_story_budget_mult_over_max_with_warning_ac_ev_23() -> void:
	var gd := game_data()
	var st := {
		"id": "st_over_budget",
		"name": "Truyện vượt hạn",
		"budget_mult": 4.0,
		"items_max": 2,
		"stages": [{"id": "s1", "event_id": "st_lang_dao_1"}],
		"log_done": "Xong.",
		"log_failed": "Hỏng.",
		"log_timeout": "Quá hạn.",
	}
	var errs: Array[String] = []
	var warns: Array[String] = []
	_EventDataValidator.validate_story_record(st, "events_stories", gd, errs, warns)
	assert_eq(errs, [], "over-max budget_mult is clamped, not an error")
	assert_near(float(st.budget_mult), 3.0, 0.0001, "AC-EV-23: m=4 clamped to m_story_max=3")
	assert_true(warns.any(func(w): return w.contains("st_over_budget") and w.contains("budget_mult")),
		"AC-EV-23: clamp emits warning naming story: %s" % str(warns))


# --- AC-EV-02, AC-EV-05, AC-EV-10, AC-EV-40: Conditions AST, Weights & Text ----------------------

func test_conditions_ast_compound_and_scope_checks_ac_ev_02_ac_ev_05() -> void:
	var gd := game_data()
	var db := WorldDB.new()
	var sect_id: String = db.add("sects", {"name": "Tùng Đào Cung", "key": "tung_dao", "alignment": "chinh", "wars": ["s_enemy"]})
	var root := {
		"id": "p_root", "name": "Hàn Minh", "realm_index": 1, "stage": 1, "age": 40.0,
		"alive": true, "sect_id": "", "sect_rank": "", "linh_thach": 500, "tam_ma": 25.0,
		"npc_traits": {"personality": ["calm"], "path": ["sword_heart"]},
	}
	var other := {
		"id": "p_other", "name": "Mạc Quy Khư", "realm_index": 4, "stage": 0, "alive": true,
		"attitude": 35, "cast_key": "mac_quy_khu", "wants": "Tìm người đáp câu hỏi", "secret": "Bí mật Quy Khư Bình",
	}
	db.add("people", root)
	db.add("people", other)
	var place := {"id": "l_gorge", "name": "Thanh Hạp", "kind": "gorge", "danger": 3, "biome": "high_mountain"}

	var env := {
		"root": root, "other": other, "place": place, "sect": {}, "story": {},
		"now_season": 10, "year": 1202, "season": 2,
		"edge": true, "co_duyen_left": 1, "biome": "desert", "travel_mode": "wilderness", "extra": {},
	}

	# AC-EV-05: all[realm >= truc_co, not flag X, any[place_kind = peak, place_kind = gorge]]
	var cond_05 := {
		"type": "all",
		"items": [
			{"type": "realm_min", "value": "truc_co"},
			{"type": "not", "item": {"type": "has_flag", "scope": "root", "flag": "X"}},
			{"type": "any", "items": [
				{"type": "place_kind", "value": "peak"},
				{"type": "place_kind", "value": "gorge"},
			]},
		],
	}
	assert_true(_EventConditions.evaluate(cond_05, env, gd, db), "AC-EV-05: true for Trúc Cơ root at gorge without flag X")
	_EventStore.set_flag(db, "p_root", "X")
	assert_false(_EventConditions.evaluate(cond_05, env, gd, db), "AC-EV-05: false once flag X is set")

	# AC-EV-02: sect requirement fails for loose root, passes once root joins sect
	assert_false(_EventConditions.evaluate({"type": "has_sect", "scope": "root", "value": true}, env, gd, db),
		"AC-EV-02: loose root without sect fails has_sect")
	root["sect_id"] = sect_id
	root["sect_rank"] = "noi_mon"
	env["sect"] = db.get_record("sects", sect_id)
	assert_true(_EventConditions.evaluate({"type": "has_sect", "scope": "root", "value": true}, env, gd, db), "has_sect passes after joining")
	assert_true(_EventConditions.evaluate({"type": "sect_rank_min", "value": "ngoai_mon"}, env, gd, db), "noi_mon >= ngoai_mon")
	assert_true(_EventConditions.evaluate({"type": "sect_at_war", "value": true}, env, gd, db), "sect_at_war true when wars non-empty")

	# Trait event hook, want, secret, biome, travel_mode
	assert_true(_EventConditions.evaluate({"type": "has_event_hook", "scope": "root", "hook": "event:sword_challenge"}, env, gd, db),
		"sword_heart opens event:sword_challenge")
	assert_false(_EventConditions.evaluate({"type": "has_event_hook", "scope": "root", "hook": "event:gambling_debt"}, env, gd, db),
		"root without gambler lacks event:gambling_debt")
	assert_true(_EventConditions.evaluate({"type": "has_secret", "scope": "other", "value": true}, env, gd, db), "has_secret reads cast secret")
	assert_true(_EventConditions.evaluate({"type": "has_want", "scope": "other", "value": true}, env, gd, db), "has_want reads cast want")
	assert_true(_EventConditions.evaluate({"type": "biome", "value": "desert"}, env, gd, db), "biome condition matches")
	assert_true(_EventConditions.evaluate({"type": "travel_mode", "value": "wilderness"}, env, gd, db), "travel_mode condition matches")


func test_effective_weight_formulas_b_ac_ev_10() -> void:
	var gd := game_data()
	var db := WorldDB.new()
	var env := {"root": {"id": "p1", "realm_index": 2}, "other": {}, "place": {}, "sect": {}, "now_season": 1, "extra": {}}

	var rec_mid := {
		"weight": 5.0,
		"weight_mods": [
			{"factor": 2.0, "conditions": {"type": "realm_min", "value": 1}},
			{"factor": 1.5, "conditions": {"type": "realm_min", "value": 2}},
			{"factor": 1.5, "conditions": {}},
			{"factor": 9.0, "conditions": {"type": "realm_min", "value": 4}}, # inactive
		],
	}
	assert_near(_EventConditions.effective_weight(rec_mid, env, gd, db), 22.5, 0.0001, "AC-EV-10: 5 * (2 * 1.5 * 1.5) = 22.5")

	var rec_hi := {
		"weight": 5.0,
		"weight_mods": [
			{"factor": 2.0}, {"factor": 2.0}, {"factor": 2.0}, {"factor": 2.0}, {"factor": 2.0},
		],
	}
	assert_near(_EventConditions.effective_weight(rec_hi, env, gd, db), 50.0, 0.0001, "AC-EV-10: 5 * clamp(32, 0.1, 10) = 50")

	var rec_zero := {
		"weight": 5.0,
		"weight_mods": [{"factor": 2.0}, {"factor": 0.0}],
	}
	assert_near(_EventConditions.effective_weight(rec_zero, env, gd, db), 0.0, 0.0001, "AC-EV-10: any 0 factor yields 0 (never clamped up)")


func test_text_rendering_substitutes_all_placeholders_ac_ev_40() -> void:
	var subs := {
		"npc": "Mạc Quy Khư",
		"place": "Quy Khư Đảo",
		"other_history": "từng vượt thiên kiếp năm xưa",
		"paid": "200",
	}
	var rendered: String = _EventConditions.render_text(
		["Tại {place}, {npc} ({other_history}) giao ngươi {paid} linh thạch."],
		subs,
		"ev_test:p1:10:text"
	)
	assert_false(rendered.contains("{") or rendered.contains("}"), "AC-EV-40: zero unreplaced placeholders: %s" % rendered)
	assert_true(rendered.contains("Mạc Quy Khư") and rendered.contains("Quy Khư Đảo") and rendered.contains("200"),
		"AC-EV-40: substituted values present: %s" % rendered)


# --- AC-EV-15 & EventStore Pacing / Persistence --------------------------------------------------

func test_event_store_flags_expiry_var_clamping_pacing_and_roundtrip_ac_ev_15() -> void:
	var gd := game_data()
	var db := WorldDB.new()

	# AC-EV-15: flag set with expiry 4 at season t=10 -> expires_season = 14
	_EventStore.set_flag(db, "p1", "spared_bandit", 14, true)
	assert_true(_EventStore.has_flag(db, "p1", "spared_bandit", 13), "AC-EV-15: true at t+3 (13)")
	assert_false(_EventStore.has_flag(db, "p1", "spared_bandit", 14), "AC-EV-15: false at t+4 (14)")
	_EventStore.expire_flags(db, 14)
	assert_false(_EventStore.has_flag(db, "p1", "spared_bandit", 10), "expired flag purged after expire_flags")

	# AC-EV-15: var range 0..10 at 9 + 5 -> 10 with clamp warning
	var warns: Array = []
	_EventStore.set_var(db, "st1", "trust", 9, 0, 10, warns)
	assert_eq(warns, [], "setting 9 in 0..10 emits no warning")
	var v_after: int = _EventStore.add_var(db, "st1", "trust", 5, 0, 10, warns)
	assert_eq(v_after, 10, "AC-EV-15: 9 + 5 clamped to 10")
	assert_eq(_EventStore.get_var(db, "st1", "trust"), 10, "get_var returns 10")
	assert_true(warns.any(func(w): return str(w).contains("trust") and str(w).contains("clamped")),
		"AC-EV-15: clamp warning names variable: %s" % str(warns))

	# Pacing: cooldown 8, once_per_life, once_per_world, season cap 2
	var ev_cd := {"id": "ev_cd", "cooldown_seasons": 8}
	assert_true(_EventStore.can_fire_pacing(db, gd, ev_cd, "p1", 10), "eligible initially")
	_EventStore.mark_fired(db, "ev_cd", "p1", 10, false, false)
	assert_false(_EventStore.can_fire_pacing(db, gd, ev_cd, "p1", 17), "blocked at t+7")
	assert_true(_EventStore.can_fire_pacing(db, gd, ev_cd, "p1", 18), "eligible at t+8")

	var ev_world := {"id": "ev_once_w", "once_per_world": true, "cooldown_seasons": 0}
	_EventStore.mark_fired(db, "ev_once_w", "p1", 10, false, true)
	assert_false(_EventStore.can_fire_pacing(db, gd, ev_world, "p2", 100), "once_per_world blocks any root forever")

	_EventStore.increment_season_events(db, 20)
	_EventStore.increment_season_events(db, 20)
	assert_eq(_EventStore.season_events_count(db, 20), 2, "season count tracks 2 events")
	assert_false(_EventStore.can_fire_pacing(db, gd, {"id": "ev_other"}, "p1", 20), "blocked once season cap (2) reached")

	# Active stories exclude quest stories when include_quests == false (Quests Rule 19)
	_EventStore.add_story(db, {"story_id": "s_norm", "root_id": "p1", "status": "active", "is_quest": false, "started_season": 1})
	_EventStore.add_story(db, {"story_id": "s_quest", "root_id": "p1", "status": "active", "is_quest": true, "started_season": 2})
	assert_eq(_EventStore.active_stories(db, "p1", false).size(), 1, "quest stories excluded from non-quest story cap")
	assert_eq(_EventStore.active_stories(db, "p1", true).size(), 2, "include_quests=true returns both")

	# Round-trip serialization through WorldDB.to_dict / from_dict
	_EventStore.set_flag(db, "p1", "kept_flag", -1, "ok")
	var restored: WorldDB = WorldDB.from_dict(db.to_dict())
	assert_true(_EventStore.has_flag(restored, "p1", "kept_flag", 99), "flag persists through WorldDB round-trip")
	assert_eq(_EventStore.get_var(restored, "st1", "trust"), 10, "var persists through WorldDB round-trip")
	assert_eq(_EventStore.active_stories(restored, "p1", false).size(), 1, "stories persist through WorldDB round-trip")


# --- AC-EV-21..25: EventBudget Formulas C --------------------------------------------------------

func test_event_budget_ceilings_chain_spending_items_and_realm_carryover_ac_ev_21_to_25() -> void:
	var gd := game_data()
	var db := WorldDB.new()

	# AC-EV-22: fortune multiplier boundary (uncapped above 100)
	assert_near(_EventBudget.fortune_multiplier(gd, 0.0), 0.75, 0.0001, "AC-EV-22: fortune 0 -> 0.75")
	assert_near(_EventBudget.fortune_multiplier(gd, 100.0), 1.25, 0.0001, "AC-EV-22: fortune 100 -> 1.25")
	assert_near(_EventBudget.fortune_multiplier(gd, 140.0), 1.45, 0.0001, "AC-EV-22: fortune 140 -> 1.45")

	# AC-EV-21: Trúc Cơ (realm 1, linh_thach_max 600), fortune 60 (c_kv = 1.05) -> B_ev = 630, B_ch = 945
	var c := _char(gd, 1, 60, "p_bud")
	var ceil_d: Dictionary = _EventBudget.event_ceiling(gd, c, null)
	assert_near(float(ceil_d.linh_thach), 630.0, 0.01, "AC-EV-21: Trúc Cơ fortune 60 B_ev = 630")

	var ch_id: String = _EventBudget.create_chain(db, gd, c, null, 1.5, 2)
	var rec: Dictionary = _EventStore.get_chain_budget(db, ch_id)
	assert_near(float(rec.total.linh_thach), 945.0, 0.01, "AC-EV-21: chain B_ch = 945")

	var w: Array = []
	assert_near(_EventBudget.spend_scalar(db, ch_id, "linh_thach", 500.0, 630.0, w), 500.0, 0.01, "step 1 grants 500")
	assert_eq(w.size(), 0, "no warning on unclamped step 1")
	assert_near(_EventBudget.spend_scalar(db, ch_id, "linh_thach", 600.0, 630.0, w), 445.0, 0.01, "AC-EV-21: step 2 asking 600 gets 445")
	assert_eq(w.size(), 1, "clamp warning emitted on step 2")
	assert_near(_EventBudget.spend_scalar(db, ch_id, "linh_thach", 100.0, 630.0, w), 0.0, 0.01, "AC-EV-21: step 3 gets 0")

	# AC-EV-24: item cap 2 -> 3rd item dropped with warning
	var wi: Array = []
	assert_true(_EventBudget.try_spend_item(db, ch_id, wi), "item 1 allowed")
	assert_true(_EventBudget.try_spend_item(db, ch_id, wi), "item 2 allowed")
	assert_false(_EventBudget.try_spend_item(db, ch_id, wi), "AC-EV-24: 3rd item dropped")
	assert_eq(wi.size(), 1, "AC-EV-24: warning emitted on 3rd item")

	# AC-EV-23: story m=3 step asking 2*B_ev (1260) gets 1*B_ev (630)
	var st_ch: String = _EventBudget.create_chain(db, gd, c, null, 3.0, 4)
	var ws: Array = []
	assert_near(_EventBudget.spend_scalar(db, st_ch, "linh_thach", 1260.0, 630.0, ws), 630.0, 0.01,
		"AC-EV-23: single step capped at 1 event ceiling (630)")
	assert_eq(ws.size(), 1, "AC-EV-23: clamp warning emitted")

	# AC-EV-25: realm carryover 300/945 at Trúc Cơ -> Kết Đan (5000*1.05*1.5 = 7875) -> 2500 left
	var c2 := _char(gd, 1, 60, "p_carry")
	var carry_ch: String = _EventBudget.create_chain(db, gd, c2, null, 1.5, 2)
	var wc: Array = []
	# Spend 645 across two steps so exactly 300 of 945 remains
	_EventBudget.spend_scalar(db, carry_ch, "linh_thach", 500.0, 630.0, wc)
	_EventBudget.spend_scalar(db, carry_ch, "linh_thach", 145.0, 630.0, wc)
	assert_near(float(_EventStore.get_chain_budget(db, carry_ch).left.linh_thach), 300.0, 0.01, "300 left before breakthrough")
	c2.realm_index = 2
	c2.level = int(Ladder.band(gd, 2)[0])
	_EventBudget.on_realm_change(db, gd, c2, null)
	var after_rec: Dictionary = _EventStore.get_chain_budget(db, carry_ch)
	assert_near(float(after_rec.total.linh_thach), 7875.0, 0.05, "AC-EV-25: Kết Đan chain total = 7875")
	assert_near(float(after_rec.left.linh_thach), 2500.0, 0.05, "AC-EV-25: unspent share 300/945 * 7875 = 2500")


# --- AC-EV-01 & AC-EV-38: EventValidator Normalization & Safety Clamps ---------------------------

func test_event_validator_normalize_fallback_and_clamps_ac_ev_01_ac_ev_38() -> void:
	var gd := game_data()
	var llm := LlmService.new(gd)
	llm.enabled = false
	var s := GameSession.new(gd, llm, TestFixtures.tree())
	s.new_game(6101, {"mode": "roll", "name": "Hàn", "gender": "male", "origin": "tan_tu"})
	s.pending_event = {}
	var ctx: Dictionary = EventContext.build(s.player, s.gd, s.db, s.sheet(), s.year, s.season, "vi")

	# AC-EV-01: missing failure outcome uses success outcome
	var raw_01 := {
		"title": "Thử nghiệm chuẩn hóa",
		"text": "Một sự kiện ngắn.",
		"choices": [
			{
				"label": "Chọn một",
				"always": [],
				"check": {"type": "none"},
				"success": {"text": "Thành công một.", "effects": []},
			},
			{
				"label": "Chọn hai",
				"always": [],
				"check": {"type": "stat", "stat": "ngo_tinh", "difficulty": 50},
				"success": {"text": "Thành công hai.", "effects": []},
				"failure": {"text": "Thất bại hai.", "effects": []},
			},
		],
	}
	var res_01: Dictionary = s.validator.normalize(raw_01, ctx, rng(10), "test")
	assert_true(bool(res_01.ok), "AC-EV-01: normalizes ok")
	assert_eq(str(res_01.event.choices[0].failure.text), "Thành công một.", "AC-EV-01: missing failure falls back to success")

	# AC-EV-38: over-cap stones clamped, unknown effect dropped, free exit added, all warned
	var raw_38 := {
		"title": "Thử nghiệm giới hạn",
		"text": "Kiểm tra mọi giới hạn ngân sách.",
		"choices": [
			{
				"label": "Trả phí nhận thưởng lớn",
				"always": [{"type": "linh_thach", "amount": -10}],
				"check": {"type": "none"},
				"success": {
					"text": "Nhận thưởng.",
					"effects": [
						{"type": "linh_thach", "amount": 999999},
						{"type": "imaginary_effect_xyz", "amount": 10},
					],
				},
			},
			{
				"label": "Trả phí khác",
				"always": [{"type": "linh_thach", "amount": -5}],
				"check": {"type": "none"},
				"success": {"text": "Xong.", "effects": []},
			},
		],
	}
	var res_38: Dictionary = s.validator.normalize(raw_38, ctx, rng(11), "test")
	assert_true(bool(res_38.ok), "AC-EV-38: normalizes ok after clamps")
	var fx0: Array = res_38.event.choices[0].success.effects
	assert_eq(fx0.size(), 1, "AC-EV-38: unknown effect dropped")
	assert_true(float(fx0[0].amount) <= float(ctx.budget.linh_thach_max), "AC-EV-38: spirit stones clamped to ceiling")
	assert_eq(res_38.event.choices.size(), 3, "AC-EV-38: free exit added when all choices cost spirit stones")
	assert_true(Array(res_38.warnings).size() >= 3, "AC-EV-38: warnings emitted for clamp, drop, and free exit: %s" % str(res_38.warnings))
	s.shutdown()
