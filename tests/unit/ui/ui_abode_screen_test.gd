extends DaoTestSuite
## AbodeScreen and FullScreenHost (design/ux/abode-screen.md): works' states in words (dormant; no level cap),
## the clamp lines, confirms before every build or raise, the element chooser for a share work, Sleep / Wake swaps,
## away is read-only, the no-home view's rent confirm warns that the old home is left, Esc order, the back request.


func _screen(v: Dictionary = AbodeScreen.sample_view(), locked: bool = false) -> AbodeScreen:
	var w: AbodeScreen = auto_free(AbodeScreen.new())
	add_child(w)
	w.show_view(v, "", locked)
	return w


static func _find(root: Node, name: String) -> Node:
	return root.find_child(name, true, false)


static func _texts(n: Node) -> String:
	var out: PackedStringArray = []
	for l in n.find_children("*", "Label", true, false):
		out.append((l as Label).text)
	return "\n".join(out)


func test_work_states_are_in_words_and_the_clamps_show() -> void:
	var w := _screen()
	var t: String = _texts(w.body)
	assert_true(t.contains("Dưỡng động phủ  ·  level 3  ·"), "a work has no highest level (max 0): just its level")
	assert_true(t.contains("level 5 / 5"), "an array keeps its Trận Pháp cap")
	assert_false(t.contains("ceiling"), "no grade ceiling any more (works scale without a cap, 2026-11-24)")
	assert_true(t.contains("dormant: gives nothing"), "the dormant spring")
	assert_true(t.contains("clamped at 0.75"), "the clamp line")
	assert_true(w.section_keys() == ["home", "works", "clamps", "build"], str(w.section_keys()))


func test_raising_a_work_arms_first_and_runs_on_confirm() -> void:
	var w := _screen()
	var got: Array = []
	w.action_requested.connect(func(a: String, args: Array): got.append([a, args]))
	(_find(w, "Raise_focus_array") as Button).pressed.emit()
	assert_eq(got, [], "armed")
	assert_eq(w.armed(), "build_work")
	(_find(w, "Confirm") as Button).pressed.emit()
	assert_eq(got, [["build_work", ["focus_array", "hoa"]]], "the work's own element is kept")


func test_the_next_grade_needs_a_higher_realm_and_says_so() -> void:
	var w := _screen()
	var b: Button = _find(w, "RaiseGrade")
	assert_true(b.disabled and b.accessibility_name.contains("needs a higher realm"))


func test_waking_a_dormant_work_swaps_with_the_latest_active_one() -> void:
	var w := _screen()
	var got: Array = []
	w.action_requested.connect(func(a: String, args: Array): got.append([a, args]))
	(_find(w, "Wake_private_spring") as Button).pressed.emit()
	assert_eq(got, [["abode_sleep", ["focus_array", "private_spring"]]], "bare work ids (CaveAbode.sleep)")


func test_a_share_work_in_the_catalogue_asks_for_its_element() -> void:
	var v := AbodeScreen.sample_view()
	v["catalogue"] = [{"id": "private_spring", "name": "Linh tuyền", "stat": "share", "per_level": 2.0, "gain": "+2 share", "next_cost": {"lt": 300, "materials": 1, "seasons": 1},
		"upkeep": 0, "kind": "permanent", "max": 0, "free_level": 3, "surcharge": 1.0, "ok": true, "reason": "", "share": true}]
	var w := _screen(v)
	var got: Array = []
	w.action_requested.connect(func(a: String, args: Array): got.append([a, args]))
	(_find(w, "Build_private_spring") as Button).pressed.emit()
	(_find(w, "Element_moc") as Button).pressed.emit()
	(_find(w, "Confirm") as Button).pressed.emit()
	assert_eq(got, [["build_work", ["private_spring", "moc"]]])


func test_away_from_home_everything_is_read_only() -> void:
	var v := AbodeScreen.sample_view()
	v["here"] = false
	v["at"] = "Chợ Đông"
	var w := _screen(v)
	var b: Button = _find(w, "Raise_focus_array")
	assert_true(b.disabled and b.accessibility_name.contains("away"))
	assert_true(_texts(w.header).contains("You are away (at Chợ Đông)"))


func test_renting_warns_that_the_current_home_is_left() -> void:
	var w := _screen({"has_home": false, "here": false, "home_place": {"id": "", "name": ""}, "rent": [{"grade": 1, "rent": 5, "price": 80, "realm_ok": true, "realm_need": "", "slots": 2}],
		"claim": {}, "catalogue": [], "works": []})
	var buttons: Array = w.body.find_children("*", "Button", true, false).filter(func(b): return (b as Button).text == "Rent")
	(buttons[0] as Button).pressed.emit()
	assert_true(_texts(w.body).contains("your current home is left"))


func test_esc_disarms_first_and_the_host_then_asks_to_go_back() -> void:
	var host: FullScreenHost = auto_free(FullScreenHost.new())
	add_child(host)
	host.register(AbodeScreen.new())
	host.open_view("abode", AbodeScreen.sample_view())
	var back: Array = []
	host.back_requested.connect(func(): back.append(true))
	(_find(host, "Raise_focus_array") as Button).pressed.emit()
	assert_true(host.escape(), "handled")
	assert_eq(back, [], "the first Esc disarms")
	host.escape()
	assert_eq(back, [true], "the second goes back")
