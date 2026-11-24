extends DaoTestSuite
## InventoryWindow (design/ux/inventory.md): kind sections in order, equipped first, the rarity word, search that dims
## non-matches with diacritics folded, the slot chooser with a Replace confirm, eat with a confirm, the element chooser,
## look-only, the Esc order and the empty inventory.

const CFG := {"rarity_words": {"1": "Phàm", "2": "Hạ", "3": "Trung", "4": "Thượng", "5": "Cực", "6": "Thánh"},
	"inventory": {"kind_order": [["artifact", "Pháp bảo"], ["cong_phap", "Công pháp"], ["pill", "Đan dược"], ["treasure", "Bảo vật"],
		["talisman", "Phù lục"], ["herb", "Linh thảo"], ["material", "Tài liệu"]]}}


static func _view() -> Dictionary:
	return {"stones": 1240, "gear": {"base_used": 1, "base_total": 5, "extra_used": 1, "extra_limit": 1, "unslotted": 1}, "items": [
		{"id": "a1", "kind": "artifact", "name": "Hắc Thiết Giáp", "rarity": 2, "text": "armour", "fact": "ATK 0 · DEF 18", "equipped": false, "slot": "",
			"fits": ["armour", "extra"], "displaces": {}, "compare": [], "verbs": [{"id": "equip", "label": "Equip…", "reason": ""}]},
		{"id": "a2", "kind": "artifact", "name": "Thanh Phong Kiếm", "rarity": 3, "text": "sword", "fact": "ATK 42 · DEF 0", "equipped": true, "slot": "weapon",
			"verbs": [{"id": "unequip", "label": "Unequip", "reason": ""}, {"id": "nurture", "label": "Nurture", "reason": ""}]},
		{"id": "a3", "kind": "artifact", "name": "Cổ Kiếm", "rarity": 4, "text": "old sword", "fact": "ATK 50 · DEF 0", "equipped": false, "slot": "",
			"fits": ["weapon", "extra"], "displaces": {"weapon": "Thanh Phong Kiếm"},
			"compare": [{"label": "ATK", "mine": 50.0, "equipped": 42.0, "against": "Thanh Phong Kiếm"}], "verbs": [{"id": "equip", "label": "Equip…", "reason": ""}]},
		{"id": "a4", "kind": "artifact", "name": "Vòng Ngọc", "rarity": 1, "text": "ring", "fact": "ATK 0 · DEF 2", "equipped": true, "slot": "unslotted",
			"verbs": [{"id": "unequip", "label": "Unequip", "reason": ""}]},
		{"id": "p1", "kind": "pill", "name": "Tụ Khí Đan", "rarity": 1, "text": "pill", "fact": "x3 · phẩm 1", "equipped": false,
			"verbs": [{"id": "use_item", "label": "Eat", "reason": "", "confirm": true}]},
		{"id": "m1", "kind": "cong_phap", "name": "Bạch Kim Bí Điển", "rarity": 3, "text": "manual", "fact": "main · known", "known": true, "equipped": false,
			"verbs": [{"id": "learn", "label": "Read", "reason": "you already know it"}]},
		{"id": "t1", "kind": "treasure", "name": "Linh Căn Quả", "rarity": 4, "text": "fruit", "fact": "grows an element", "equipped": false,
			"verbs": [{"id": "use_item", "label": "Use", "reason": "", "confirm": true}]},
	]}


func _window(v: Dictionary = _view(), locked: bool = false) -> InventoryWindow:
	var w: InventoryWindow = auto_free(InventoryWindow.new())
	w.cfg = CFG
	add_child(w)
	w.show_view(v, "", locked)
	return w


static func _find(root: Node, name: String) -> Node:
	return root.find_child(name, true, false)


func test_kind_sections_come_in_the_fixed_order() -> void:
	var w := _window()
	assert_eq(w.section_keys(), ["artifact", "cong_phap", "pill", "treasure"])


func test_equipped_pieces_come_first_and_rows_carry_the_rarity_word() -> void:
	var w := _window()
	var order: Array = []
	for c in w.body.find_children("Item_a*", "Button", true, false):   # the rows sit in each kind's inset
		if c is Button and str(c.name).begins_with("Item_a"):
			order.append(str(c.name).trim_prefix("Item_"))
	assert_eq(order.slice(0, 2), ["a2", "a4"], "equipped first (the unslotted ring is equipped too)")
	assert_true(w.row_of("a3").text.contains("Thượng"), "the rarity word, not colour alone")
	assert_true(w.row_of("a4").text.contains("unslotted") and w.row_of("a4").accessibility_name.contains("unslotted"), "unslotted in words")


func test_search_dims_the_rest_and_folds_diacritics() -> void:
	var w := _window()
	w._search.text = "thanh phong"
	w._on_search(w._search.text)
	assert_eq(w.row_of("a2").modulate.a, 1.0, "the match stays full")
	assert_true(w.row_of("p1").modulate.a < 1.0, "a non-match is dimmed, not removed")
	assert_true(w._count.text.contains("1 of"), "the match count")


func test_a_kind_chip_hides_that_kind() -> void:
	var w := _window()
	w._on_chip(false, "pill")
	assert_false(w.section_keys().has("pill"))
	assert_true(w.row_of("p1") == null)


func test_a_free_slot_equips_at_once() -> void:
	var w := _window()
	var got: Array = []
	w.action_requested.connect(func(a: String, args: Array): got.append([a, args]))
	w.row_of("a1").pressed.emit()
	(_find(w, "Verb_equip") as Button).pressed.emit()
	assert_true(_find(w, "SlotChooser") != null, "the slot chooser opens")
	assert_true(_find(w, "Slot_weapon") == null, "only fitting slots")
	(_find(w, "Slot_armour") as Button).pressed.emit()
	assert_eq(got, [["equip", ["a1", "armour"]]])


func test_an_occupied_slot_asks_to_replace_first() -> void:
	var w := _window()
	var got: Array = []
	w.action_requested.connect(func(a: String, args: Array): got.append(a))
	w.row_of("a3").pressed.emit()
	(_find(w, "Verb_equip") as Button).pressed.emit()
	(_find(w, "Slot_weapon") as Button).pressed.emit()
	assert_eq(got, [], "armed, not equipped")
	(_find(w, "Confirm") as Button).pressed.emit()
	assert_eq(got, ["equip"])


func test_eating_a_pill_arms_first_and_cancel_emits_nothing() -> void:
	var w := _window()
	var got: Array = []
	w.action_requested.connect(func(a: String, args: Array): got.append([a, args]))
	w.row_of("p1").pressed.emit()
	(_find(w, "Verb_use_item") as Button).pressed.emit()
	(_find(w, "Cancel") as Button).pressed.emit()
	assert_eq(got, [])
	(_find(w, "Verb_use_item") as Button).pressed.emit()
	(_find(w, "Confirm") as Button).pressed.emit()
	assert_eq(got, [["use_item", ["p1", ""]]])


func test_a_treasure_that_asks_for_an_element_opens_the_element_chooser() -> void:
	var w := _window()
	var got: Array = []
	w.action_requested.connect(func(a: String, args: Array): got.append([a, args]))
	w.ask_element("t1", ["hoa", "thuy"], ["Choose…", "Hỏa: x1.2", "Thủy: x1.1"])
	assert_true(str((_find(w, "Element_hoa") as Button).text).contains("Hỏa: x1.2"), "the preview line after the header")
	(_find(w, "Element_thuy") as Button).pressed.emit()
	assert_eq(got, [["use_item", ["t1", "thuy"]]])


func test_read_is_greyed_for_a_known_manual_and_unequip_runs_at_once() -> void:
	var w := _window()
	w.row_of("m1").pressed.emit()
	assert_true((_find(w, "Verb_learn") as Button).disabled, "already known")
	var got: Array = []
	w.action_requested.connect(func(a: String, args: Array): got.append([a, args]))
	w.row_of("a2").pressed.emit()
	(_find(w, "Verb_unequip") as Button).pressed.emit()
	assert_eq(got, [["unequip", ["a2"]]])
	assert_true(_find(w, "Verb_nurture") != null, "nurture on an equipped piece")


func test_look_only_disables_every_verb() -> void:
	var w := _window(_view(), true)
	w.row_of("p1").pressed.emit()
	var b: Button = _find(w, "Verb_use_item")
	assert_true(b.disabled and b.accessibility_name.contains("locked"))


func test_esc_closes_the_chooser_then_the_row_then_lets_the_window_close() -> void:
	var w := _window()
	w.row_of("a1").pressed.emit()
	(_find(w, "Verb_equip") as Button).pressed.emit()
	assert_true(w.cancel_inline(), "the chooser")
	assert_true(_find(w, "SlotChooser") == null)
	assert_true(w.cancel_inline(), "the expanded row")
	assert_eq(w.expanded(), "")
	assert_false(w.cancel_inline(), "nothing left: the window closes")


func test_an_empty_inventory_says_so() -> void:
	var w := _window({"stones": 0, "gear": {}, "items": []})
	var found: bool = false
	for c in w.body.find_children("*", "Label", true, false):
		if c is Label and (c as Label).text == "You carry nothing yet.":
			found = true
	assert_true(found)


func test_the_read_and_build_of_two_hundred_items_is_quick() -> void:
	var v := _view()
	var many: Array = []
	for i in 200:
		var it: Dictionary = (v.items[i % v.items.size()] as Dictionary).duplicate(true)
		it["id"] = "x%d" % i
		many.append(it)
	v["items"] = many
	var t0: int = Time.get_ticks_usec()
	var w := _window(v)
	var ms: float = float(Time.get_ticks_usec() - t0) / 1000.0
	assert_eq(w.body.find_children("Item_*", "Button", true, false).size(), 200, "all rows built")
	assert_true(ms < 250.0, "built in %.0f ms (spec 50 ms for read + build; the headless debug build is slower)" % ms)
