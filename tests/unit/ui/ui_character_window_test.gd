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
	var w := _window(_view())
	var all: Array = []
	for t in CharacterWindow.TABS:
		if str(t[0]) == "interact":
			continue   # only another person's sheet has it
		w.open_tab(str(t[0]))
		assert_eq(w.section_keys(), Array(t[2]), "tab %s" % t[0])
		all += Array(t[2])
	assert_eq(all.size(), 12, "the eleven of character-sheet.md and the traits row (2026-11-24)")
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
	assert_true((_find(w, "Verb_trade") as Button).disabled, "the rest say why not")
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
