extends DaoTestSuite
## Wave 3 UI tests for NPC Interaction & Dialogue (#30) + 19 Trait verb: hooks (AC-NI-27):
## verifies all 4 verb groups, zero "Coming later" text, acceptance badges + Formula A breakdown tooltips
## (using TooltipLayer metadata, zero built-in tooltip_text), greyed bond verbs showing missing requirements,
## trait-unlocked verb badges across self/other/either sides, inline picker & confirm flows, Esc cancellation,
## live voiced reply display, and season focus-tax display across CharacterWindow and TurnController.

static var _gd: GameData


static func _data() -> GameData:
	if _gd == null:
		_gd = GameData.load_from("res://assets/data")
	return _gd


func _mini_session() -> Dictionary:
	var gd: GameData = _data()
	var llm := LlmService.new(gd)
	llm.enabled = false
	var s := GameSession.new(gd, llm, TestFixtures.tree())
	s.ratings_background = false
	s.db = WorldDB.new()
	s.year = 1200
	s.season = 0
	s.seed_value = 9001
	s.rng.seed = 9001
	var place_id: String = s.db.add("places", {
		"name": "Thanh Phong Trấn", "type": "tran", "kind": "town", "region_id": "",
		"density": 1.0, "danger": 1, "market": true, "bounties": true, "links": [], "sect_id": "",
		"qi": {"land_density": 1.0, "shares": {"hoa": 0.5, "moc": 0.5}, "variants": []},
	})
	var p := TestFixtures.character({"hoa": 65}, 55, 0)
	p.name = "Lâm Thanh"
	p.location_id = place_id
	p.home_id = place_id
	p.linh_thach = 400
	p.npc_traits = {"upbringing": "merchant_child", "lifestyle": "tea_master", "personality": ["compassionate"]}
	p.id = s.db.add("people", p.to_dict())
	s.player = p
	s._wire()
	# Create a met NPC at the same place with higher realm (can teach) + "other" trait hook (chronicler) + spare item.
	var npc_c := TestFixtures.character({"hoa": 70}, 60, 1)
	npc_c.name = "Mạc Sư Huynh"
	npc_c.location_id = place_id
	npc_c.home_id = place_id
	npc_c.linh_thach = 300
	npc_c.npc_traits = {"personality": ["generous"], "calling": "chronicler"}
	var npc_d: Dictionary = npc_c.to_dict()
	npc_d["met_player"] = true
	npc_d["attitude"] = 20   # warm: below friendly -> companion & brotherhood greyed, dao_lu greyed!
	npc_d["is_player"] = false
	var npc_id: String = s.db.add("people", npc_d)
	# Give player a spare giftable item and NPC a spare trade item.
	var p_item: Dictionary = s.items.material("huyen_thiet", 2)
	p_item["owner_id"] = p.id
	var p_item_id: String = s.db.add("items", p_item)
	var n_item: Dictionary = s.items.material("huyen_thiet", 1)
	n_item["owner_id"] = npc_id
	s.db.add("items", n_item)
	p.met_list = [npc_id]
	s.sync_player()
	return {"session": s, "npc_id": npc_id, "player_item_id": p_item_id}


func _window_for(s: GameSession, npc_id: String, locked: bool = false) -> CharacterWindow:
	var w: CharacterWindow = auto_free(CharacterWindow.new())
	add_child(w)
	var v: Dictionary = GameQuery.character(s, npc_id)
	w.show_view(v, "", locked)
	return w


static func _find(root: Node, node_name: String) -> Node:
	return root.find_child(node_name, true, false)


func test_interact_tab_renders_all_groups_badges_trait_verbs_and_greyed_bonds_ac_ni_27() -> void:
	var ctx: Dictionary = _mini_session()
	var s: GameSession = ctx.session
	var npc_id: String = str(ctx.npc_id)
	var w: CharacterWindow = _window_for(s, npc_id)

	assert_eq(w.tab(), "interact", "opens on Interact tab for another person")
	# All 4 verb groups rendered
	for gid in ["social", "favour", "conflict", "bond"]:
		assert_true(_find(w, "VerbGroup_" + gid) != null, "group %s rendered" % gid)
		assert_true(_find(w, "VerbGroupHeader_" + gid) is Label, "header for %s rendered" % gid)

	# Zero "Coming later" text anywhere in the window
	assert_true(_find(w, "PlannedVerbs") == null, "PlannedVerbs stub removed")
	for lbl in w.find_children("*", "Label", true, false):
		assert_false(str((lbl as Label).text).to_lower().contains("coming later"), "no Coming later text: %s" % str((lbl as Label).text))

	# Acceptance status badges (word + symbol) and Formula A breakdown tooltip (via TooltipLayer, never built-in tooltip_text)
	var teach_btn: Button = _find(w, "Verb_teach") as Button
	assert_true(teach_btn != null, "Ask for teaching button present (NPC is higher realm)")
	assert_eq(teach_btn.tooltip_text, "", "built-in tooltip_text must stay empty (ADR-0005)")
	var tip: Variant = teach_btn.get_meta(TooltipLayer.META, {})
	assert_true(tip is Dictionary, "custom TooltipLayer tip attached to Verb_teach")
	var lines_joined: String = " | ".join(Array((tip as Dictionary).get("lines", [])))
	assert_true(lines_joined.contains("Base ask") and lines_joined.contains("Attitude") and lines_joined.contains("Total score"),
		"Formula A breakdown lines present in tooltip: %s" % lines_joined)

	var teach_status: Label = _find(w, "VerbStatus_teach") as Label
	assert_true(teach_status != null, "VerbStatus_teach rendered")
	assert_true(teach_status.text.contains("✓") or teach_status.text.contains("✗"), "acceptance badge uses symbol + word: %s" % teach_status.text)

	# Greyed bond verb shows missing requirement and is disabled
	var comp_btn: Button = _find(w, "Verb_companion") as Button
	assert_true(comp_btn != null, "Bond verb companion rendered greyed when attitude is warm (< friendly)")
	assert_true(comp_btn.disabled, "greyed bond verb is disabled")
	var comp_status: Label = _find(w, "VerbStatus_companion") as Label
	assert_true(comp_status != null and comp_status.text.contains("friendly"), "greyed bond shows missing friendly requirement: %s" % (comp_status.text if comp_status != null else "null"))

	# Trait-unlocked verb badges across self (haggle via merchant_child), other (ask_history via chronicler), and either (share_tea via tea_master)
	for pair in [["haggle", "Merchant"], ["ask_history", "Chronicler"], ["share_tea", "Tea"]]:
		var vid: String = str(pair[0])
		var badge: Node = _find(w, "TraitBadge_" + vid)
		assert_true(badge != null, "TraitBadge_%s rendered" % vid)
		var btext: String = ""
		for l in badge.find_children("*", "Label", true, false):
			btext += str((l as Label).text)
		assert_true(btext.contains("[Trait:") and btext.contains(str(pair[1])), "trait badge names source trait for %s: %s" % [vid, btext])

	# F7 trait conflict warning for compassionate player on threaten (button stays enabled per Rule 7 / AC-NI-07!)
	var thr_btn: Button = _find(w, "Verb_threaten") as Button
	assert_true(thr_btn != null and not thr_btn.disabled, "threaten stays clickable for compassionate player")
	var thr_f7: Label = _find(w, "VerbF7_threaten") as Label
	assert_true(thr_f7 != null and thr_f7.text.contains("tâm ma"), "F7 warning shown on threaten")
	s.shutdown()


func test_inline_pickers_confirm_cancel_and_live_reply_flow() -> void:
	var ctx: Dictionary = _mini_session()
	var s: GameSession = ctx.session
	var npc_id: String = str(ctx.npc_id)
	var w: CharacterWindow = _window_for(s, npc_id)
	var got: Array = []
	w.action_requested.connect(func(a: String, args: Array): got.append([a, args]))

	# 1. Free parameterless verb emits exact 2-arg signal immediately
	(_find(w, "Verb_greet") as Button).pressed.emit()
	assert_eq(got, [["person_verb", [npc_id, "greet"]]], "free parameterless verb keeps 2-arg signal")

	# 2. Gift picker opens inline, selects preset, and Confirm emits 3-arg payload
	got.clear()
	(_find(w, "Verb_gift") as Button).pressed.emit()
	assert_eq(w.active_verb(), "gift", "gift inline picker opened")
	assert_true(_find(w, "VerbPanel_gift") != null, "VerbPanel_gift exists")
	(_find(w, "GiftPreset_100") as Button).pressed.emit()
	(_find(w, "ConfirmVerb_gift") as Button).pressed.emit()
	assert_eq(w.active_verb(), "", "picker closes after confirm")
	assert_eq(got.size(), 1)
	assert_eq(got[0][0], "person_verb")
	assert_eq(str(got[0][1][0]), npc_id)
	assert_eq(str(got[0][1][1]), "gift")
	assert_eq(int((got[0][1][2] as Dictionary).get("stones", 0)), 100, "gift confirm passes stones=100")

	# 3. Teach picker opens inline and Esc (cancel_inline) closes it without emitting
	got.clear()
	(_find(w, "Verb_teach") as Button).pressed.emit()
	assert_eq(w.active_verb(), "teach")
	assert_true(_find(w, "LessonOpt_insight") is Button, "teach picker offers insight")
	assert_true(w.cancel_inline(), "cancel_inline closes open verb panel")
	assert_eq(w.active_verb(), "")
	assert_eq(got, [], "cancel emits no action")

	# 4. Execute live greet through GameSession.interact and verify voiced Vietnamese reply in reply strip
	var res: Dictionary = s.interact(npc_id, "greet")
	assert_true(bool(res.get("ok", false)), "live greet succeeds")
	assert_true(str(res.get("reply", "")).strip_edges() != "", "live greet produces non-empty voiced reply")
	w.show_view(GameQuery.character(s, npc_id), "", false)
	w.show_reply(Array(res.get("lines", [])))
	assert_true(w.reply_text().contains(str(res.reply)), "reply strip displays voiced reply")
	s.shutdown()


func test_focus_tax_surfaces_in_game_query_character_window_and_turn_controller() -> void:
	var ctx: Dictionary = _mini_session()
	var s: GameSession = ctx.session
	var npc_id: String = str(ctx.npc_id)
	# Raise attitude so teach accepts cleanly, then run teach (0.25 season)
	s.db.get_record("people", npc_id)["attitude"] = 60
	var res: Dictionary = s.interact(npc_id, "teach", {"lesson": "insight"})
	assert_true(bool(res.get("ok", false)) and bool(res.get("accepted", false)), "teach accepted")

	var fy: Dictionary = GameQuery.season_focus_yield(s)
	assert_near(float(fy.used), 0.25, 1e-6)
	assert_near(float(fy.remaining), 0.75, 1e-6)
	assert_eq(int(fy.pct), 75, "focus yield is 75% after 0.25-season teach")

	# CharacterWindow shows focus left label
	var w: CharacterWindow = _window_for(s, npc_id)
	var fy_lbl: Label = _find(w, "FocusYieldLabel") as Label
	assert_true(fy_lbl != null and fy_lbl.text.contains("75%"), "Interact tab shows 75%% season focus left: %s" % (fy_lbl.text if fy_lbl != null else "null"))

	# TurnController surfaces 75% yield in focus_label and button_label, and resets after_turn
	var tc := TurnController.new(s)
	tc.set_focus_yield(int(fy.pct))
	assert_eq(tc.focus_yield_note(), "75% yield")
	assert_true(tc.focus_label().contains("75% yield"), "focus_label surfaces 75%% yield: %s" % tc.focus_label())
	assert_true(tc.button_label().contains("75% yield"), "button_label surfaces 75%% yield: %s" % tc.button_label())
	tc.after_turn({"ok": true, "lines": []}, s.player.location_id)
	assert_eq(tc.focus_yield_pct, 100, "after_turn resets focus yield to 100%")
	assert_false(tc.focus_label().contains("yield"), "100% yield stays clean without suffix")

	# GameQuery.known_people includes met NPC with taught flag
	var known: Array = GameQuery.known_people(s)
	assert_eq(known.size(), 1)
	assert_eq(str(known[0].id), npc_id)
	assert_true(Array(known[0].flags).any(func(f): return str(f.key) == "taught"), "known_people carries active taught flag")
	s.shutdown()


func test_inline_trade_help_and_conflict_confirm_panels() -> void:
	var ctx: Dictionary = _mini_session()
	var s: GameSession = ctx.session
	var npc_id: String = str(ctx.npc_id)
	var p_item_id: String = str(ctx.player_item_id)
	var w: CharacterWindow = _window_for(s, npc_id)
	var got: Array = []
	w.action_requested.connect(func(a: String, args: Array): got.append([a, args]))

	# Trade inline barter panel lists both NPC buyable goods and player sellable spare item
	(_find(w, "Verb_trade") as Button).pressed.emit()
	assert_eq(w.active_verb(), "trade")
	assert_true(_find(w, "VerbPanel_trade") != null)
	var sell_btn: Button = _find(w, "TradeSell_" + p_item_id) as Button
	assert_true(sell_btn != null and not sell_btn.disabled, "player spare item sellable in trade panel")
	sell_btn.pressed.emit()
	assert_eq(got.size(), 1)
	assert_eq(str((got[0][1][2] as Dictionary).get("trade_action", "")), "sell")
	assert_eq(str((got[0][1][2] as Dictionary).get("item_id", "")), p_item_id)

	# Help inline panel selects loan amount and emits help payload
	got.clear()
	(_find(w, "Verb_help") as Button).pressed.emit()
	assert_eq(w.active_verb(), "help")
	assert_true(_find(w, "HelpSub_loan") is Button)
	assert_true(_find(w, "LoanAmountLabel") is Label)
	(_find(w, "ConfirmVerb_help") as Button).pressed.emit()
	assert_eq(got.size(), 1)
	assert_eq(str(got[0][1][1]), "help")
	assert_eq(str((got[0][1][2] as Dictionary).get("sub", "")), "loan")
	assert_true(int((got[0][1][2] as Dictionary).get("amount", 0)) > 0)

	# Conflict confirm-in-place (provoke) requires Confirm before emitting
	got.clear()
	(_find(w, "Verb_provoke") as Button).pressed.emit()
	assert_eq(w.active_verb(), "provoke")
	assert_eq(got, [], "provoke does not fire before Confirm")
	(_find(w, "ConfirmVerb_provoke") as Button).pressed.emit()
	assert_eq(got.size(), 1)
	assert_eq(str(got[0][1][1]), "provoke")
	s.shutdown()
