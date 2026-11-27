extends DaoTestSuite
## CharacterWindow (design/ux/character-sheet.md): built from a GameQuery.character-shaped view, eleven sections in order,
## a Change button per slot with an inline chooser that requests set_slot, a confirm-in-place breakthrough, look-only.


static func _view(at_bottleneck: bool = false) -> Dictionary:
	var v := {
		"id": "p1", "name": "Lâm Phong", "alive": true, "realm_label": "Luyện Khí Sơ kỳ", "level": 3, "layer": 3,
		"sect": "", "rank": "", "age": 18.0, "lifespan": 120.0, "power": 640, "provisional": true,
		"cultivation": {"tu_vi": 50.0, "requirement": 100.0, "rate": 12.0, "seasons_to_next": 5, "held": false, "top": false, "bottleneck": {}},
		"roots": {"tier": "Song linh căn", "speed": 1.2, "elements": [
			{"id": "hoa", "name": "Hỏa", "purity": 62.0, "grade": "Trung phẩm", "role": "attack"},
			{"id": "moc", "name": "Mộc", "purity": 0.0, "grade": "", "role": "growth"}], "variants": []},
		"talents": [{"id": "can_cot", "name": "Căn cốt", "value": 54.0, "grade": "Trung", "bonus": 2}],
		"vitals": [{"key": "health", "label": "Health (khí huyết)", "value": 80.0, "max": 100.0}],
		"combat": [{"key": "block", "label": "Block", "value": 0.12}],
		"slots": [{"slot": "main", "index": 0, "tech": {"key": "t_main", "name": "Liệt Hỏa Quyết", "kind": "main", "layer": 2, "layers": 9, "mastery": 3.0, "next_cost": 10.0, "gated": false, "usable": true}},
			{"slot": "aux", "index": 0, "tech": {}}, {"slot": "aux", "index": 1, "tech": {}}],
		"known": [{"key": "t_main", "name": "Liệt Hỏa Quyết", "kind": "main", "layer": 2, "layers": 9, "usable": true, "slotted": true},
			{"key": "t_main2", "name": "Thanh Mộc Quyết", "kind": "main", "layer": 1, "layers": 9, "usable": true, "slotted": false},
			{"key": "t_art", "name": "Hỏa Cầu Thuật", "kind": "art", "layer": 1, "layers": 5, "usable": true, "slotted": false}],
		"speed_label": "fire = x1.00", "gear": [], "crafts": [], "dao_do": {"open": 4, "unspent": 1},
		"fate": {"origin": "Tán tu", "background": "", "birth_mode": "thien_dinh", "perks": []},
		"breakdowns": {"rate": {"total": 12.0, "lines": ["rate = 12"]}, "lifespan": {"total": 120.0, "lines": ["lifespan = 120"]}},
	}
	if at_bottleneck:
		v.cultivation.bottleneck = {"tu_vi": 500.0, "bar_cost": 500.0, "full": true, "condition": "", "condition_met": true,
			"pill": "Trúc Cơ Đan", "pill_quality": 2, "talisman": "none", "chance": 0.62, "backlash": 8.0, "bare_attempts": 0, "bare_cap": 3}
	return v


func _window(v: Dictionary, locked: bool = false) -> CharacterWindow:
	var w: CharacterWindow = auto_free(CharacterWindow.new())
	add_child(w)
	w.show_view(v, "", locked)
	return w


static func _find(root: Node, name: String) -> Node:
	return root.find_child(name, true, false)


func test_the_tabs_hold_the_twelve_sections_in_order() -> void:
	var v0 := _view()
	v0["formations"] = _formations()   # the player's sheet carries the formation editor (Combat tab)
	var w := _window(v0)
	var all: Array = []
	for t in CharacterWindow.TABS:
		if str(t[0]) == "interact":
			continue   # only another person's sheet has it
		w.open_tab(str(t[0]))
		assert_eq(w.section_keys(), Array(t[2]), "tab %s" % t[0])
		all += Array(t[2])
	assert_eq(all.size(), 13, "the eleven of character-sheet.md, the traits row and the formation editor (2026-11-24)")
	for k in CharacterWindow.SECTIONS:
		assert_true(all.has(k), "%s is on a tab" % k)


static func _other() -> Dictionary:
	var v := _view()
	v["id"] = "p9"
	v["name"] = "Hàn Mặc"
	v["is_player"] = false
	v["person"] = {"met": true, "attitude": 40, "band": "friendly", "place": "Tùng Hạ Thị", "place_id": "l2", "here": true,
		"home": "Tùng Hạ Thị", "archetype": "Kiếm tu", "is_beast": false,
		"ties": [{"partner_id": "p3", "partner": "Lâm Dã Hạc", "kinds": ["friend"], "portrait": {}}], "history": ["Year 1199: travelled."]}
	return v


func test_another_person_opens_on_the_interact_tab_with_their_verbs() -> void:
	var w := _window(_other())
	assert_eq(w.tab(), "interact")
	assert_true(w.shows_other())
	assert_eq(w.window_title(w.view), "Hàn Mặc")
	assert_false((_find(w, "Verb_greet") as Button).disabled, "Greet runs: they are here")
	assert_true(_find(w, "Verb_trade") == null, "a verb the game does not have is no button")
	assert_true(str((_find(w, "PlannedVerbs") as Label).text).contains("Trade"), "it is named in the Coming later line")
	assert_true(_find(w, "Pin") is Button and _find(w, "PracticeFight") is Button)


func test_another_person_s_sheet_is_look_only() -> void:
	var w := _window(_other())
	w.open_tab("overview")
	assert_true((_find(w, "Change_main_0") as Button).disabled, "no slot changes for someone else")


func test_the_interact_tab_requests_the_map_screen_s_actions() -> void:
	var w := _window(_other())
	var got: Array = []
	w.action_requested.connect(func(a: String, args: Array): got.append([a, args]))
	(_find(w, "Verb_greet") as Button).pressed.emit()
	(_find(w, "Pin") as Button).pressed.emit()
	(_find(w, "PracticeFight") as Button).pressed.emit()
	assert_eq(got, [["person_verb", ["p9", "greet"]], ["person_pin", ["p9", true]], ["person_fight", ["p9"]]])


func test_the_player_s_sheet_has_no_interact_tab() -> void:
	var w := _window(_view())
	assert_true(_find(w, "Tab_interact") == null)
	assert_true(_find(w, "Tab_overview") is Button)


func test_a_jump_to_a_section_on_another_tab_opens_that_tab() -> void:
	var w := _window(_view())
	assert_eq(w.tab(), "overview")
	w.jump_to("fate")
	assert_eq(w.tab(), "fate")
	assert_true(w.section_keys().has("fate"))


func test_every_slot_has_a_change_button() -> void:
	var w := _window(_view())
	for name in ["Change_main_0", "Change_aux_0", "Change_aux_1"]:
		assert_true(_find(w, name) is Button, name)


func test_choosing_a_technique_in_the_chooser_requests_set_slot_with_its_key() -> void:
	var w := _window(_view())
	var got: Array = []
	w.action_requested.connect(func(a: String, args: Array): got.append([a, args]))
	(_find(w, "Change_aux_0") as Button).pressed.emit()
	assert_eq(w.chooser_open(), {"slot": "aux", "index": 0})
	var chooser: Node = _find(w, "Chooser")
	assert_true(chooser != null, "the chooser is open under the slot")
	var picked: Button = null
	for b in chooser.get_children():
		if b is Button and str((b as Button).text).contains("Hỏa Cầu Thuật"):
			picked = b
		assert_false(b is Button and str((b as Button).text).contains("Thanh Mộc Quyết"), "a main method is not offered for an art slot")
	assert_true(picked != null and not picked.disabled, "the art is offered")
	picked.pressed.emit()
	assert_eq(got, [["set_slot", ["aux", 0, "t_art", false]]])
	assert_true(w.chooser_open().is_empty(), "the chooser closes on a pick")


func test_esc_closes_the_chooser_first() -> void:
	var w := _window(_view())
	(_find(w, "Change_main_0") as Button).pressed.emit()
	assert_true(w.cancel_inline(), "an open chooser is cancelled")
	assert_true(w.chooser_open().is_empty())
	assert_false(w.cancel_inline(), "nothing left to cancel: the window closes next")


func test_the_breakthrough_arms_first_and_runs_only_on_confirm() -> void:
	var w := _window(_view(true))
	var got: Array = []
	w.action_requested.connect(func(a: String, args: Array): got.append(a))
	(_find(w, "AttemptBreakthrough") as Button).pressed.emit()
	assert_true(w.armed(), "the first press arms")
	assert_eq(got, [], "nothing runs on the first press")
	var ask_named: bool = false
	for l in w.find_children("*", "Label", true, false):
		if str((l as Label).text).contains("62 % success") and str((l as Label).text).contains("8 % qi deviation"):
			ask_named = true
	assert_true(ask_named, "the armed row names the chance and the risk")
	(_find(w, "CancelBreakthrough") as Button).pressed.emit()
	assert_false(w.armed(), "Cancel disarms")
	assert_eq(got, [], "Cancel runs nothing")
	(_find(w, "AttemptBreakthrough") as Button).pressed.emit()
	(_find(w, "ConfirmBreakthrough") as Button).pressed.emit()
	assert_eq(got, ["breakthrough"], "Confirm runs it")


func test_no_bottleneck_block_before_great_perfection() -> void:
	var w := _window(_view(false))
	assert_true(_find(w, "Bottleneck") == null)


func test_look_only_disables_change_and_attempt() -> void:
	var w := _window(_view(true), true)
	assert_true((_find(w, "Change_main_0") as Button).disabled, "Change locked")
	assert_true((_find(w, "AttemptBreakthrough") as Button).disabled, "Attempt locked")
	assert_true(str((_find(w, "Change_main_0") as Button).accessibility_name).contains("locked"), "the reason is in the accessible name")


func test_the_reply_strip_shows_at_most_three_lines() -> void:
	var w := _window(_view())
	w.show_reply(["a", "b", "c", "d"])
	assert_eq(w.reply_text(), "a\nb\nc")


func test_the_compact_layout_folds_the_standing_line_into_the_name() -> void:
	var w: CharacterWindow = auto_free(CharacterWindow.new())
	w.compact = true
	add_child(w)
	w.show_view(_view(), "", false)
	assert_eq(w.header.get_child_count(), 2, "one line (name and numbers) and the tab row (the standing line sits in the Cultivation inset)")


func test_the_tabs_step_and_wrap_with_the_player_skipping_interact() -> void:
	var w := _window(_view())
	w.step_tab(1)
	assert_eq(w.tab(), "combat")
	w.step_tab(-1)
	w.step_tab(-1)
	assert_eq(w.tab(), "fate", "wraps back past Overview; the player's sheet has no Interact tab")


func test_block_is_points_and_evade_a_share_in_the_combat_groups() -> void:
	var v := _view()
	v["combat"] = [{"key": "block", "label": "Block", "value": 3.91}, {"key": "evade", "label": "Evade", "value": 0.12},
		{"key": "resist:fire", "label": "Resistance: fire", "value": 14.0}]
	var w := _window(v)
	w.open_tab("combat")
	assert_false(str((_find(w, "Stat_block") as PanelContainer).accessibility_name).contains("%"), "block is points, not a share")
	assert_true(str((_find(w, "Stat_evade") as PanelContainer).accessibility_name).contains("12 %"))
	assert_true(_find(w, "Stat_resist_fire") != null, "typed resistances get their own group")


static func _formations() -> Dictionary:
	var nodes: Array = [{"n": 1, "polarity": "+", "words": "+12% art speed", "pos": [0, 0], "open": true, "unlock": 1, "art": "a1", "art_name": "Quick Cut", "icon": "", "slot": 0},
		{"n": 2, "polarity": "+", "words": "+10% damage", "pos": [1, 0], "open": true, "unlock": 1, "art": "", "art_name": "", "icon": "", "slot": -1},
		{"n": 3, "polarity": "-", "words": "+12% art cost", "pos": [2, 0], "open": false, "unlock": 2, "art": "", "art_name": "", "icon": "", "slot": -1}]
	var cur := {"id": "fx", "name": "Fixture Line", "name_vi": "Thử Trận", "grade": 0, "level": 1, "level_eff": 1, "max_level": 2, "strength": 1.0,
		"nodes": nodes, "links": [{"kind": "feed", "a": 2, "b": 1, "seconds": 0.8, "bend": 0.3, "open": true, "unlock": 1}], "figure": [],
		"open_nodes": 2, "total_nodes": 3, "reserve_share": 0.02, "idea": "", "taught_by": ""}
	return {"slots": 3, "set": "fx", "lay": true, "current": cur, "fuel": 1, "stones": 30, "reserved": 0.02, "reserve_cap": 0.9,
		"shares": {"laid": 1.0, "carried": 0.7, "blind": 0.5}, "event_waiting": false,
		"known": [{"id": "", "name": "Plain Row", "name_vi": "", "set": false, "can": true, "reason": "", "view": {"nodes": []}},
			{"id": "fx", "name": "Fixture Line", "name_vi": "Thử Trận", "set": true, "can": true, "reason": "", "view": cur},
			{"id": "big", "name": "Too Big", "name_vi": "", "set": false, "can": false, "reason": "5 nodes but 3 art slots", "view": cur}],
		"pool": [{"id": "a1", "name": "Quick Cut", "icon": "", "tags": [], "node": 1}, {"id": "a2", "name": "Heavy Palm", "icon": "", "tags": [], "node": 0}]}


func test_the_formation_editor_places_an_art_in_the_chosen_node() -> void:
	var v := _view()
	v["formations"] = _formations()
	var w := _window(v)
	w.open_tab("combat")
	var got: Array = []
	w.action_requested.connect(func(a: String, args: Array): got.append([a, args]))
	assert_true((_find(w, "Art_a2") as Button).disabled, "no node selected: an art cannot be placed yet")
	(_find(w, "Board") as FormationBoard).node_button(2).pressed.emit()
	(_find(w, "Art_a2") as Button).pressed.emit()
	assert_eq(got, [["place_diagram_art", [2, "a2"]]], "node 2, then the art")
	assert_true((_find(w, "Formation_big") as Button).disabled, "a formation that cannot be set is greyed")
	(_find(w, "Formation_plain") as Button).pressed.emit()
	assert_eq(got[1], ["set_diagram", [""]], "the Plain Row sets the default line")


func test_the_formation_editor_is_look_only_while_an_event_waits() -> void:
	var v := _view()
	var f := _formations()
	f["event_waiting"] = true
	v["formations"] = f
	var w := _window(v)
	w.open_tab("combat")
	assert_true((_find(w, "Formation_plain") as Button).disabled)
	assert_true((_find(w, "LayToggle") as Button).disabled)


# --- Stage 10C: C3 talent grade display (Character Stats rule 5 / AC-NT-39) & traits_view v2 -------------------------

func _mini_session(c: Character) -> GameSession:
	var gd := game_data()
	var llm := LlmService.new(gd)
	llm.enabled = false
	var s := GameSession.new(gd, llm, TestFixtures.tree())
	s.ratings_background = false
	s.db = WorldDB.new()
	s.db.add("places", {"id": "loc_1", "name": "Test Vale", "kind": "village", "region_id": "", "qi": {"density": 1.0}})
	c.id = "p_test"
	c.location_id = "loc_1"
	s.player = c
	s.db.add("people", c.to_dict())
	return s


static func _talent_row(v: Dictionary, tid: String) -> Dictionary:
	for t in Array(v.get("talents", [])):
		if str(t.get("id", "")) == tid:
			return t
	return {}


func test_format_talent_grade_and_character_c3_cases_ac_nt_39() -> void:
	var gd := game_data()
	# Direct helper checks
	assert_eq(GameQuery.format_talent_grade("Thượng", "Trung", [{"name": "Genius", "value": 20.0}]),
		"Thượng (base Trung, Genius +20)")
	assert_eq(GameQuery.format_talent_grade("Trung", "Trung", []), "Trung")
	assert_eq(GameQuery.format_talent_grade("Thiên", "Thiên", [{"name": "Genius", "value": 20.0}]), "Thiên")
	assert_eq(GameQuery.format_talent_grade("Hạ", "Hạ", [{"name": "Dull-witted", "value": -20.0}]), "Hạ")
	assert_eq(GameQuery.format_talent_grade("Thượng", "Trung", []), "Thượng (base Trung)")

	# 1) base 45 + quick_minded 3 -> eff 65, "Thượng (base Trung, Genius +20)"
	var c1 := TestFixtures.character({"hoa": 60}, 45, 0)
	c1.npc_traits = {"talent": [{"id": "quick_minded", "tier": 3}]}
	var v1: Dictionary = GameQuery.character(_mini_session(c1))
	var t1: Dictionary = _talent_row(v1, "ngo_tinh")
	assert_near(float(t1.value), 65.0, 1e-6)
	assert_eq(int(t1.base), 45)
	assert_eq(str(t1.grade), "Thượng")
	assert_eq(str(t1.base_grade), "Trung")
	assert_eq(str(t1.grade_display), "Thượng (base Trung, Genius +20)")
	assert_eq(int(t1.bonus), 20)

	# 2) base 45 + 0 -> eff 45, "Trung"
	var c2 := TestFixtures.character({"hoa": 60}, 45, 0)
	var v2: Dictionary = GameQuery.character(_mini_session(c2))
	var t2: Dictionary = _talent_row(v2, "ngo_tinh")
	assert_near(float(t2.value), 45.0, 1e-6)
	assert_eq(str(t2.grade_display), "Trung")

	# 3) base 100 + 30 (quick_minded 3 + non-trait flat +10) -> eff 130, "Thiên"
	var c3 := TestFixtures.character({"hoa": 60}, 100, 0)
	c3.npc_traits = {"talent": [{"id": "quick_minded", "tier": 3}]}
	c3.tie_rows = [{"stat": "ngo_tinh", "value": 10.0, "source": "Test flat", "with": "m1"}]
	var v3: Dictionary = GameQuery.character(_mini_session(c3))
	var t3: Dictionary = _talent_row(v3, "ngo_tinh")
	assert_near(float(t3.value), 130.0, 1e-6)
	assert_eq(str(t3.grade_display), "Thiên")

	# 4) base 10 + slow_witted 3 -> eff 1, "Hạ"
	var c4 := TestFixtures.character({"hoa": 60}, 10, 0)
	c4.npc_traits = {"talent": [{"id": "slow_witted", "tier": 3}]}
	var v4: Dictionary = GameQuery.character(_mini_session(c4))
	var t4: Dictionary = _talent_row(v4, "ngo_tinh")
	assert_near(float(t4.value), 1.0, 1e-6)
	assert_eq(str(t4.grade_display), "Hạ")

	# 5) gear/tree/non-trait-only shift (55 + 10 -> 65, no talent tier) -> "Thượng (base Trung)"
	var c5 := TestFixtures.character({"hoa": 60}, 55, 0)
	c5.tie_rows = [{"stat": "ngo_tinh", "value": 10.0, "source": "Test flat", "with": "m1"}]
	var v5: Dictionary = GameQuery.character(_mini_session(c5))
	var t5: Dictionary = _talent_row(v5, "ngo_tinh")
	assert_near(float(t5.value), 65.0, 1e-6)
	assert_eq(str(t5.grade_display), "Thượng (base Trung)")
	assert_true(Array(t5.talent_tiers).is_empty())
	assert_true(gd.grade_name(65.0) == "Thượng")


func test_character_window_displays_c3_grade_text_on_talent_tile() -> void:
	var c := TestFixtures.character({"hoa": 60}, 45, 0)
	c.npc_traits = {"talent": [{"id": "quick_minded", "tier": 3}]}
	var v: Dictionary = GameQuery.character(_mini_session(c))
	var w := _window(v)
	var tile: PanelContainer = _find(w, "Talent_ngo_tinh") as PanelContainer
	assert_true(tile != null, "Talent_ngo_tinh tile exists")
	assert_eq(str(tile.accessibility_name), "Ngộ tính 65, Thượng (base Trung, Genius +20)")
	var found_note: bool = false
	for l in tile.find_children("*", "Label", true, false):
		if str((l as Label).text) == "Thượng (base Trung, Genius +20)":
			found_note = true
			assert_eq((l as Label).autowrap_mode, TextServer.AUTOWRAP_WORD_SMART, "C3 note wraps cleanly")
	assert_true(found_note, "Talent_ngo_tinh displays C3 grade_display text")


func test_traits_view_renders_all_ten_kinds_and_scoped_lines() -> void:
	var gd := game_data()
	var nt := {
		"personality": ["brave"],
		"calling": "strategist",
		"upbringing": "sect_raised",
		"talent": [{"id": "quick_minded", "tier": 3}],
		"path": ["sword_heart"],
		"lifestyle": "tea_master",
		"health": ["old_wound"],
		"coping": {"id": "drowns_in_wine", "refreshes": 3, "hardened": true},
		"fate": ["spirit_eyed"],
		"gained": [{"id": "scarred", "expires": 120, "target": ""}],
	}
	var rows: Array = GameQuery.traits_view(gd, nt)
	var groups: Array = rows.map(func(r): return str(r.group))
	assert_eq(groups, ["personality", "calling", "upbringing", "talent", "path", "lifestyle", "health", "coping", "fate", "gained"],
		"all 10 kinds in canonical order")
	var by_group := {}
	for r in rows:
		by_group[str(r.group)] = r
	# Talent uses tier name & tier_names_vi, and formats both talent add and tier rows
	assert_eq(str(by_group.talent.name), "Genius")
	assert_eq(str(by_group.talent.name_vi), "thiên tài")
	var t_lines: String = " | ".join(Array(by_group.talent.lines))
	assert_true(t_lines.contains("+20") and t_lines.contains("Ngộ tính"), "talent flat add formatted: %s" % t_lines)
	assert_true(t_lines.contains("+6%") and t_lines.contains("tu luyện"), "talent tier row formatted: %s" % t_lines)
	# Path scoped row appends [sword]
	var p_lines: String = " | ".join(Array(by_group.path.lines))
	assert_true(p_lines.contains("[sword]"), "scoped row shows [sword]: %s" % p_lines)
	# Hardened coping appends " (hardened)"
	assert_eq(str(by_group.coping.name), "Drowns in wine (hardened)")
	# Upbringing, lifestyle, health, gained dict entries resolve to catalogue names and stat lines
	assert_eq(str(by_group.upbringing.name), "Sect-raised")
	assert_eq(str(by_group.lifestyle.name), "Tea master")
	assert_eq(str(by_group.health.name), "Old wound")
	assert_eq(str(by_group.gained.name), "Scarred")
	assert_true(Array(by_group.gained.lines).size() > 0, "gained dict resolves rows")
	# Each row preserves the shape Illustrated.trait_chip expects (and builds a chip cleanly)
	for r in rows:
		for k in ["group", "id", "name", "name_vi", "icon", "lines", "leans"]:
			assert_true((r as Dictionary).has(k), "trait row has %s" % k)
		var chip: PanelContainer = auto_free(Illustrated.trait_chip(r))
		assert_true(chip != null)
