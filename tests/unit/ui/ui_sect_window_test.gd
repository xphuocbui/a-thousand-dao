extends DaoTestSuite
## SectWindow (design/ux/sect-window.md): the member view's ladder and gate checklist, Promote only when met and only
## on confirm, the desertion confirm's standing preview, the loose view's join checklist, look-only.


static func _member(met: bool = false) -> Dictionary:
	return {"mode": "member", "in_sect": true, "event_waiting": false,
		"sect": {"id": "s1", "name": "Thanh Vân Tông", "name_han": "青雲宗", "gloss": "", "kind": "great", "alignment_name": "chính đạo", "specialty": "sword",
			"status": "active", "founded_year": 400, "fell_year": 0, "cause": "", "seat": {"id": "pl1", "name": "Thanh Vân Sơn"}, "region": "Đông",
			"head": {"id": "p9", "name": "Trần Vân"}, "members": 64, "treasury": 12400, "levels": {}, "regions": ["Đông"], "liege": {"id": "", "name": ""}},
		"you": {"rank": "ngoai_mon", "rank_name": "outer disciple", "contribution": 85, "standing": 12.0, "hostile": false},
		"ladder": [{"rank": "ngoai_mon", "name": "outer disciple", "current": true}, {"rank": "noi_mon", "name": "inner disciple", "current": false},
			{"rank": "truong_lao", "name": "elder", "current": false}, {"rank": "tong_chu", "name": "sect head", "current": false}],
		"next": {"rank": "noi_mon", "rank_name": "inner disciple", "reachable": true, "top": false, "cost": 400,
			"missing": [] if met else ["contribution 85 of 400"],
			"gate": [{"label": "realm", "have": "Trúc Cơ", "need": "Trúc Cơ", "met": true}, {"label": "contribution", "have": 85 if not met else 400, "need": 400, "met": met},
				{"label": "standing", "have": 12, "need": 0, "met": true}]},
		"leave_preview": {"standing_now": 12.0, "desert_standing": -30.0, "desert_hostile": true, "hostile_threshold": -30.0},
		"join": {}, "others": [], "great": []}


static func _loose() -> Dictionary:
	return {"mode": "loose", "in_sect": false, "sect": {"id": "s1", "name": "Thanh Vân Tông", "name_han": "", "gloss": "", "kind": "great", "alignment_name": "",
		"specialty": "", "status": "active", "founded_year": 400, "seat": {"id": "pl1", "name": "Thanh Vân Sơn"}, "region": "", "head": {"id": "", "name": ""},
		"members": 3, "treasury": 0, "levels": {}, "regions": [], "liege": {"id": "", "name": ""}},
		"join": {"here": true, "ok": false, "reasons": ["your realm is below the sect's floor"], "standing": 0.0},
		"others": [], "great": [{"id": "s1", "name": "Thanh Vân Tông", "seat": "Thanh Vân Sơn", "region": "", "alignment": ""}]}


func _window(v: Dictionary, locked: bool = false) -> SectWindow:
	var w: SectWindow = auto_free(SectWindow.new())
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


func test_the_gate_lists_each_need_with_met_or_not_in_words() -> void:
	var w := _window(_member())
	var t: String = _texts(w.body)
	assert_true(t.contains("✗ contribution 85 of 400 — not met") and t.contains("✓ standing 12 of 0 — met"), t)
	assert_true(t.contains("▶ outer disciple"), "the ladder marks the current rank")


func test_promote_is_greyed_until_the_gate_is_met() -> void:
	var w := _window(_member(false))
	var b: Button = _find(w, "Promote")
	assert_true(b.disabled and b.accessibility_name.contains("contribution 85 of 400"), "greyed with the reason")


func test_promote_arms_first_and_runs_on_confirm() -> void:
	var w := _window(_member(true))
	var got: Array = []
	w.action_requested.connect(func(a: String, args: Array): got.append(a))
	(_find(w, "Promote") as Button).pressed.emit()
	assert_eq(got, [], "armed")
	assert_true(_texts(w.body).contains("Spends 400 contribution"))
	(_find(w, "Confirm") as Button).pressed.emit()
	assert_eq(got, ["promote"])


func test_the_desertion_confirm_previews_the_standing_and_hostility() -> void:
	var w := _window(_member())
	var got: Array = []
	w.action_requested.connect(func(a: String, args: Array): got.append([a, args]))
	(_find(w, "Desert") as Button).pressed.emit()
	var t: String = _texts(w.body)
	assert_true(t.contains("from 12 to -30") and t.contains("hostile"), t)
	(_find(w, "Cancel") as Button).pressed.emit()
	assert_eq(got, [], "Cancel runs nothing")
	(_find(w, "Desert") as Button).pressed.emit()
	(_find(w, "Confirm") as Button).pressed.emit()
	assert_eq(got, [["leave_sect", [true]]])


func test_the_loose_view_shows_the_join_reasons_and_greys_join() -> void:
	var w := _window(_loose())
	assert_true(_texts(w.body).contains("✗ your realm is below the sect's floor"))
	assert_true((_find(w, "Join") as Button).disabled)
	assert_true(w.section_keys().has("great"), "the great sects list")


func test_look_only_disables_the_actions() -> void:
	var w := _window(_member(true), true)
	for n in ["Promote", "Leave", "Desert"]:
		assert_true((_find(w, n) as Button).disabled, n)
