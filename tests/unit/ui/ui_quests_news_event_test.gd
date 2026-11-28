extends DaoTestSuite
## Wave 4 UI unit tests for Event Engine (#23) & Template Quests (#31):
## - ui_windows.json enables quests (J) & news (N) with widths
## - CentreWindow Event Card (AC-EV-42: badges, trait option, stat breakdown, fight ambush odds,
##   hidden '?', deadly hidden warning, disabled unaffordable reason) + Mercy result buttons (AC-EV-30)
## - QuestsWindow (Active Journal tight deadline & orphan, Offers AC-QS-79/89/119/128, Board AC-QS-80, Stories AC-QS-81)
## - NewsWindow (World News AC-EV-36 + Uncovered Chronicles AC-WG-56 + hidden chronicle filter)
## - OutlinerPanel Quests/Stories/Mercy sections & signal routing
## - Zero built-in tooltip_text across all new/edited controls (ADR-0005)

const _QuestsWindow := preload("res://src/ui/windows/quests_window.gd")
const _NewsWindow := preload("res://src/ui/windows/news_window.gd")


static func _all_texts(root: Node) -> String:
	var out: PackedStringArray = PackedStringArray()
	for l in root.find_children("*", "Label", true, false):
		out.append((l as Label).text)
	for b in root.find_children("*", "Button", true, false):
		out.append((b as Button).text)
	for r in root.find_children("*", "RichTextLabel", true, false):
		out.append((r as RichTextLabel).text)
	return "\n".join(out)


static func _assert_no_builtin_tips(suite: DaoTestSuite, root: Node) -> void:
	for c in root.find_children("*", "Control", true, false):
		var ctrl: Control = c as Control
		suite.assert_eq(ctrl.tooltip_text, "", "ADR-0005: Control %s must not use built-in tooltip_text" % ctrl.name)


func test_ui_windows_json_enables_quests_and_news_with_widths() -> void:
	var gd := GameData.load_from("res://assets/data")
	var wcfg: Dictionary = gd.file("ui_windows")
	var widths: Dictionary = Dictionary(wcfg.get("widths", {}))
	assert_true(is_equal_approx(float(widths.get("quests", 0.0)), 0.62), "quests width is 0.62")
	assert_true(is_equal_approx(float(widths.get("news", 0.0)), 0.58), "news width is 0.58")
	var by_kind: Dictionary = {}
	for entry in Array(Dictionary(wcfg.get("window_buttons", {})).get("list", [])):
		if entry is Dictionary:
			by_kind[str((entry as Dictionary).get("kind", ""))] = entry
	assert_true(by_kind.has("quests") and bool(by_kind["quests"].get("built", false)), "quests button is built: true")
	assert_eq(str(by_kind["quests"].get("key", "")), "J", "quests hotkey is J")
	assert_false(by_kind["quests"].has("reason"), "quests unbuilt reason removed")
	assert_true(by_kind.has("news") and bool(by_kind["news"].get("built", false)), "news button is built: true")
	assert_eq(str(by_kind["news"].get("key", "")), "N", "news hotkey is N")
	assert_false(by_kind["news"].has("reason"), "news unbuilt reason removed")


func test_centre_window_event_card_ac_ev_42_and_mercy_result() -> void:
	var cw: CentreWindow = auto_free(CentreWindow.new())
	add_child(cw)
	var ev := {
		"title": "Hẻm Núi Tùng Đào",
		"text": "Kẻ cũ chặn đường đòi cổ phổ.",
		"kind": "story",
		"story_name": "Bản Nhạc Không Chữ",
		"story_stage": "Giai đoạn 2",
		"followup_of": "Bến Ngư Ca",
		"choices": [
			{
				"label": "Soi trận pháp",
				"affordable": true,
				"always_costs": [],
				"check": {"type": "stat", "stat": "than_thuc", "difficulty": 50},
				"check_breakdown": {"type": "stat", "stat": "than_thuc", "difficulty": 50.0, "chance": 0.60, "lines": ["Thần thức: 60", "Độ khó: 50"]},
				"fight_odds": {},
				"outcome_summary": "Thành công: +180 tu vi",
				"hidden": false,
				"deadly": false,
			},
			{
				"label": "Nghênh chiến",
				"affordable": true,
				"trait_badge": "sword_heart",
				"trait_label": "Kiếm Tâm",
				"always_costs": [{"type": "khi_huyet_loss_pct", "amount": 5}],
				"check": {"type": "combat", "enemy": "npc_1", "situation": "ambush"},
				"fight_odds": {"enemy_name": "Lục Vô Tâm", "chance": 0.58, "player_power": 140.0, "enemy_power": 125.0, "situation": "ambush"},
				"outcome_summary": "Thành công: +180 LT",
				"hidden": false,
				"deadly": false,
			},
			{
				"label": "Nhảy xuống vực",
				"affordable": true,
				"hidden": true,
				"deadly": true,
			},
			{
				"label": "Mua đường 500 LT",
				"affordable": false,
				"disable_reason": "Không đủ linh thạch",
				"always_costs": [{"type": "linh_thach", "amount": -500}],
				"hidden": false,
				"deadly": false,
			},
		],
	}
	var odds := [
		{"ok": true, "chance": 0.60, "text": "Thần thức 60 vs 50", "reason": ""},
		{"ok": true, "chance": 0.58, "text": "Giao đấu", "reason": ""},
		{"ok": true, "chance": -1.0, "text": "Ẩn", "reason": ""},
		{"ok": false, "chance": -1.0, "text": "", "reason": "Không đủ linh thạch"},
	]
	cw.show_event(ev, odds)
	var txt: String = _all_texts(cw)
	assert_true(cw.showing_event and not cw.showing_mercy, "regular event card active")
	assert_true(txt.contains("Bản Nhạc Không Chữ"), "story badge rendered")
	assert_true(txt.contains("Bến Ngư Ca"), "follow-up badge rendered")
	assert_true(txt.contains("60%"), "stat check chance rendered")
	assert_true(txt.contains("[Kiếm Tâm]"), "trait badge rendered")
	assert_true(txt.contains("58%") and txt.contains("ambush"), "fight odds and ambush situation rendered")
	assert_true(txt.contains("Có thể tử vong"), "deadly hidden warning rendered")
	assert_true(txt.contains("Không đủ linh thạch"), "unaffordable disable reason rendered")
	var btn_disabled: Button = cw.find_child("Choice_3", true, false) as Button
	assert_true(btn_disabled != null and btn_disabled.disabled, "unaffordable button is disabled")
	var picked: Array = []
	cw.option_chosen.connect(func(idx: int): picked.append(idx))
	(cw.find_child("Choice_1", true, false) as Button).pressed.emit()
	assert_eq(picked, [1], "clicking affordable choice emits option_chosen")
	_assert_no_builtin_tips(self, cw)

	# Post-fight Mercy result view (AC-EV-30)
	var mercy_picks: Array = []
	cw.mercy_chosen.connect(func(kill: bool): mercy_picks.append(kill))
	cw.show_mercy_result("Kết cục giao đấu", "⚔ Thắng lợi (58%)", ["+180 LT", "-12% khí huyết"], "Lục Vô Tâm gục ngã.", {"mercy_target_name": "Lục Vô Tâm"})
	var mtxt: String = _all_texts(cw)
	assert_true(cw.showing_event and cw.showing_mercy, "mercy card active")
	assert_true(mtxt.contains("Thắng lợi") and mtxt.contains("+180 LT") and mtxt.contains("Tha mạng") and mtxt.contains("Kết liễu"), "mercy result fields rendered")
	(cw.find_child("MercySpare", true, false) as Button).pressed.emit()
	(cw.find_child("MercyKill", true, false) as Button).pressed.emit()
	assert_eq(mercy_picks, [false, true], "mercy buttons emit false (spare) and true (kill)")
	_assert_no_builtin_tips(self, cw)


func test_quests_window_offers_journal_board_stories_and_actions() -> void:
	var qw: GameWindow = auto_free(_QuestsWindow.new())
	add_child(qw)
	var view := {
		"active_cap": 3,
		"gain_total_w": 48.0,
		"gain_cap_w": 48.0,
		"can_gain_boon": false,
		"active": [
			{
				"id": "q_act",
				"name": "Hộ Tống Linh Thảo",
				"tier": "ordinary",
				"state": "active",
				"stage": 2,
				"stage_count": 4,
				"offerer_name": "Sở Ngọc Hồ",
				"seasons_left": 2,
				"remaining_s_i": 4,
				"tight_deadline_warn": true,
				"budget": {"B": 360},
				"paid_total": 45,
				"current_stage": {"kind": "mission", "title": "Vượt đèo", "place_id": "p1", "place_name": "Hắc Phong Cốc", "description": "Áp tiêu 1 mùa."},
				"later_stages": [{"stage": 3, "kind": "deliver", "place_name": "Thanh Vân Thành"}],
			},
			{
				"id": "q_orph",
				"name": "Mảnh Trận Bàn",
				"tier": "errand",
				"state": "orphaned",
				"stage": 2,
				"stage_count": 2,
				"offerer_name": "Trần Hạc Niên",
				"seasons_left": 4,
				"remaining_s_i": 1,
				"tight_deadline_warn": false,
				"budget": {"B": 120},
				"paid_total": 20,
				"current_stage": {"kind": "deliver", "title": "Nộp trận bàn", "place_id": "p2", "place_name": "Tùng Hạ Thị", "description": "Giao di sản."},
				"later_stages": [],
			},
		],
		"offers": [
			{
				"id": "q_off",
				"name": "Đòi Lại Cổ Phổ",
				"tier": "major",
				"offer_kind": "sect",
				"offerer_name": "Vi Thanh Âm",
				"adversary_name": "Lục Vô Tâm",
				"place_name": "Vạn Hác Sơn",
				"source_fact": {"kind": "grudge", "text": "Cướp tiêu mùa trước"},
				"stake_text": "Bảo vệ cổ phổ",
				"offer_text": ["Hãy đoạt lại cổ phổ."],
				"deadline": 24,
				"budget": {"B": 640, "S_plan": 8, "stage_pays": [48, 48, 96, 448], "final_pay": 448, "cash_max": 128, "deliver_max": 320},
				"stage_1": {"kind": "visit", "title": "Hỏi chứng nhân", "place_name": "Bến Ngư Ca", "window": 3, "description": "Gặp lão lái đò."},
				"later_stages": [{"stage": 2, "kind": "deliver", "place_name": "Thanh Vân Thành", "description": "SECRET_SHOULD_NOT_SHOW"}],
				"outcomes": [
					{"on": "completed", "role": "offerer", "effect": "wealth", "amount": 240},
					{"on": "completed", "role": "adversary", "effect": "injury", "amount": 0.25},
				],
				"has_lasting_gain": true,
				"can_gain_boon": false,
			},
		],
		"board": [
			{"id": "qb_1", "name": "Dọn Yêu Thú", "tier": "errand", "offer_kind": "board", "offerer_name": "Bảng Tùng Hạ", "place_name": "Tùng Hạ Thị", "deadline": 8, "budget": {"B": 100, "stage_pays": [30, 70], "final_pay": 70, "cash_max": 20, "deliver_max": 50, "S_plan": 2}, "stage_1": {"kind": "defeat", "title": "Đuổi yêu thú", "place_name": "Mỏ đá", "window": 2, "description": "Đánh bại đầu đàn."}, "later_stages": [], "outcomes": []},
		],
		"stories": [
			{"id": "st_1", "name": "Bản Nhạc Không Chữ", "stage": "s2", "stage_label": "Giai đoạn 2", "last_event": "Hẻm Tùng Đào", "budget_left": 540, "items_left": 2, "timeout_left": 18},
		],
		"completed": [],
	}
	var actions: Array = []
	qw.action_requested.connect(func(act: String, args: Array): actions.append([act, args]))

	# 1. Offers tab (AC-QS-79, 89, 119, 128)
	qw.show_view(view, "offers", false)
	var otxt: String = _all_texts(qw)
	assert_true(otxt.contains("Trọng vụ"), "tier Trọng vụ shown")
	assert_true(otxt.contains("Vi Thanh Âm") and otxt.contains("Lục Vô Tâm"), "offerer and adversary shown")
	assert_true(otxt.contains("Cướp tiêu mùa trước"), "source fact shown")
	assert_true(otxt.contains("+240 LT") and otxt.contains("25%"), "resolved world outcomes shown")
	assert_true(otxt.contains("640 LT") and otxt.contains("Gặp lão lái đò"), "budget and stage 1 full shown")
	assert_true(otxt.contains("Thanh Vân Thành") and not otxt.contains("SECRET_SHOULD_NOT_SHOW"), "later stages show kind+place only")
	assert_true(otxt.contains("0 W"), "cap-0 lasting gain notice shown")
	(qw.find_child("Accept_q_off", true, false) as Button).pressed.emit()
	(qw.find_child("Decline_q_off", true, false) as Button).pressed.emit()
	assert_eq(actions, [["quest_accept", ["q_off"]], ["quest_decline", ["q_off"]]], "offer actions emit properly")
	_assert_no_builtin_tips(self, qw)

	# 2. Journal tab (AC-QS-81)
	actions.clear()
	qw.show_view(view, "journal", false)
	var jtxt: String = _all_texts(qw)
	assert_true(jtxt.contains("Hộ Tống Linh Thảo") and jtxt.contains("gấp hạn"), "active quest & tight-deadline warning shown")
	assert_true(jtxt.contains("Khuyết chủ"), "orphaned quest shown")
	(qw.find_child("Mission_q_act", true, false) as Button).pressed.emit()
	(qw.find_child("Abandon_q_act", true, false) as Button).pressed.emit()
	(qw.find_child("Drop_q_orph", true, false) as Button).pressed.emit()
	assert_eq(actions, [["quest_mission", ["q_act"]], ["quest_abandon", ["q_act"]], ["quest_drop", ["q_orph"]]], "journal actions emit properly")

	# 3. Board & Stories tabs
	qw.show_view(view, "board", false)
	assert_true(_all_texts(qw).contains("Dọn Yêu Thú") and _all_texts(qw).contains("KHÔNG kích hoạt hồi chiêu"), "board tab shows slot and zero-cooldown note")
	qw.show_view(view, "stories", false)
	var stxt: String = _all_texts(qw)
	assert_true(stxt.contains("Bản Nhạc Không Chữ") and stxt.contains("540 LT"), "stories tab shows active story and budget left")
	_assert_no_builtin_tips(self, qw)


func test_news_window_shows_news_and_uncovered_chronicles_hides_secret() -> void:
	var nw: GameWindow = auto_free(_NewsWindow.new())
	add_child(nw)
	var view := {
		"news": [
			{"id": "n1", "year": 1204, "season": 1, "type": "story", "text": "Sở Ngọc Hồ bảo vệ lô dược liệu.", "data": {"newsworthy": true}},
		],
		"annals_uncovered": [
			{"id": "c1", "year": 942, "season": 2, "type": "tale", "text": "Án thuế ngầm bến Ngư Ca đã giải mật.", "data": {"id": "N-lang_dao-03", "secret": false, "uncovered": true}},
			{"id": "c_secret", "year": 900, "season": 0, "type": "hidden", "text": "MUST_NOT_LEAK", "data": {"id": "N-secret", "secret": true}},
		],
	}
	nw.show_view(view, "all", false)
	var txt: String = _all_texts(nw)
	assert_true(txt.contains("Sở Ngọc Hồ"), "known-NPC news shown (AC-EV-36)")
	assert_true(txt.contains("N-lang_dao-03") and txt.contains("giải mật"), "uncovered chronicle shown (AC-WG-56)")
	assert_false(txt.contains("MUST_NOT_LEAK"), "still-hidden chronicle never leaks in NewsWindow")
	_assert_no_builtin_tips(self, nw)


func test_outliner_renders_quests_stories_mercy_and_emits_signals() -> void:
	var o: OutlinerPanel = auto_free(OutlinerPanel.new())
	add_child(o)
	o.show_view({
		"people": [],
		"home": {},
		"seat": {},
		"event": {},
		"mercy": {"title": "Hẻm Tùng Đào", "target_id": "npc_1"},
		"quests": [{"id": "q1", "name": "Hộ Tống", "stage": 2, "stage_count": 4, "current_kind": "mission", "target_place": "Hắc Phong", "seasons_left": 2, "tight_deadline_warn": true}],
		"stories": [{"id": "s1", "name": "Bản Nhạc Không Chữ", "stage_label": "Giai đoạn 2", "budget_left": 500}],
	})
	assert_eq(o.quest_rows(), 1, "one quest row in outliner")
	assert_eq(o.story_rows(), 1, "one story row in outliner")
	var got_q: Array = []
	var got_s: Array = []
	var got_ev: Array = []
	o.quest_requested.connect(func(id: String): got_q.append(id))
	o.story_requested.connect(func(id: String): got_s.append(id))
	o.event_requested.connect(func(): got_ev.append("mercy"))
	(o.find_child("Quest_q1", true, false).find_children("*", "Button", true, false)[0] as Button).pressed.emit()
	(o.find_child("Story_s1", true, false).find_children("*", "Button", true, false)[0] as Button).pressed.emit()
	(o.find_child("MercyWaiting", true, false) as Button).pressed.emit()
	assert_eq(got_q, ["q1"], "quest click emits quest_requested")
	assert_eq(got_s, ["s1"], "story click emits story_requested")
	assert_eq(got_ev, ["mercy"], "mercy row click emits event_requested")
	_assert_no_builtin_tips(self, o)
