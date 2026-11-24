extends DaoTestSuite
## RelationshipsWindow (design/ux/relationships-page.md): groups in order, soft slots and the eviction line, both
## directions of an enmity with their bands, the feud's "does not fade", the favour block, sorting, names that open the
## person window, filters that keep headings, and the Relations entry.

const CFG := {"tie_kinds": {"kin": ["家", "Thân tộc", "kin"], "master": ["✎", "Sư phụ", "master"], "ket_nghia": ["🍶", "Kết nghĩa", "sworn sibling"],
	"friend": ["☺", "Bằng hữu", "friend"], "rival": ["⚔", "Đối thủ", "rival"], "debt": ["✋", "Ân tình", "debt of gratitude"],
	"enmity": ["☁", "Thù hận", "enmity"], "feud": ["🗡", "Huyết thù", "blood feud"]}}


static func _view(full: bool = false) -> Dictionary:
	return {"cap": 16, "held": 4, "outside_cap": 1, "soft_used": 12 if full else 2, "soft_limit": 12, "room": 0 if full else 10,
		"next_evict": {"partner_id": "p3", "partner": "Lý Hàn", "kind": "friend", "band": "faint"} if full else {},
		"ties": [
			{"partner_id": "p1", "partner": "Trần Vân", "realm": "Trúc Cơ", "place": "Thanh Vân", "attitude": 18, "band_word": "warm", "alive": true, "group": "pinned", "strength": 0,
				"kinds": [{"kind": "master", "strength": -1, "band": "", "direction": "", "inherited": false, "cause": ""}], "favour": ""},
			{"partner_id": "p2", "partner": "Hắc Sát", "realm": "Kết Đan", "place": "", "attitude": -70, "band_word": "hostile", "alive": true, "group": "feud", "strength": 80,
				"kinds": [{"kind": "feud", "strength": -1, "band": "", "direction": "toward_you", "inherited": true, "cause": "your master was slain"},
					{"kind": "enmity", "strength": 50, "band": "firm", "direction": "toward_them", "inherited": false, "cause": ""},
					{"kind": "enmity", "strength": 80, "band": "deep", "direction": "toward_you", "inherited": false, "cause": ""}], "favour": ""},
			{"partner_id": "p3", "partner": "Lý Hàn", "realm": "Luyện Khí", "place": "", "attitude": 5, "band_word": "neutral", "alive": true, "group": "soft", "strength": 10,
				"kinds": [{"kind": "friend", "strength": 10, "band": "faint", "direction": "", "inherited": false, "cause": ""}], "favour": ""},
			{"partner_id": "p4", "partner": "An Nhiên", "realm": "Luyện Khí", "place": "", "attitude": 40, "band_word": "friendly", "alive": true, "group": "soft", "strength": 70,
				"kinds": [{"kind": "rival", "strength": 70, "band": "deep", "direction": "", "inherited": false, "cause": ""}], "favour": ""},
			{"partner_id": "p5", "partner": "Đỗ Cường", "realm": "Trúc Cơ", "place": "", "attitude": 30, "band_word": "friendly", "alive": true, "group": "pinned", "strength": 0,
				"kinds": [{"kind": "ket_nghia", "strength": -1, "band": "", "direction": "", "inherited": false, "cause": ""}], "favour": "Lâm Phong",
				"favour_info": {"state": "awaiting", "recorded": false, "refuse_delta": 30, "cost": 200, "call_seasons": 4}},
		],
		"met": [{"id": "m1", "name": "Ngô Đức", "realm": "Luyện Khí", "place": "Chợ", "attitude": 2, "band_word": "neutral", "alive": true}]}


func _window(v: Dictionary = _view()) -> RelationshipsWindow:
	var w: RelationshipsWindow = auto_free(RelationshipsWindow.new())
	w.cfg = CFG
	add_child(w)
	w.show_view(v, "", false)
	return w


static func _find(root: Node, name: String) -> Node:
	return root.find_child(name, true, false)


static func _texts(n: Node) -> String:
	var out: PackedStringArray = []
	for l in n.find_children("*", "Label", true, false):
		out.append((l as Label).text)
	return "\n".join(out)


func test_groups_come_in_order() -> void:
	var w := _window()
	assert_eq(w.section_keys(), ["pinned", "feud", "soft", "met"])


func test_the_header_shows_soft_slots_and_room_when_not_full() -> void:
	var w := _window()
	var t: String = _texts(w.header)
	assert_true(t.contains("Soft slots 2 / 12"), t)
	assert_true(t.contains("Room for 10 more"), "room, not an eviction")
	var full := _window(_view(true))
	assert_true(_texts(full.header).contains("Next to go if a new tie forms: Lý Hàn"), "the eviction line only when full")


func test_enmity_shows_both_directions_with_bands_and_the_feud_does_not_fade() -> void:
	var w := _window()
	var row: Control = _find(w, "Tie_p2")
	var spoken: String = row.accessibility_name
	assert_true(spoken.contains("toward them") and spoken.contains("firm") and spoken.contains("toward you") and spoken.contains("deep"), spoken)
	assert_true(spoken.contains("does not fade") and spoken.contains("inherited: your master was slain"), spoken)
	assert_true(spoken.contains("Huyết thù") and spoken.contains("blood feud"), "the kind in both languages")


func test_a_sworn_sibling_owed_a_favour_carries_the_favour_block() -> void:
	var w := _window()
	var row: Control = _find(w, "Tie_p5")
	assert_true(_texts(row).contains("favour owed: Lâm Phong"))
	var tip: Dictionary = row.get_meta(TooltipLayer.META)
	var lines: String = "\n".join(Array(tip.lines))
	assert_true(lines.contains("awaiting call-in") and lines.contains("−30") and lines.contains("200"), lines)


func test_sorting_by_strength_puts_the_strongest_soft_tie_first() -> void:
	var w := _window()
	w._on_sort(RelationshipsWindow.SORTS.find("strength"))
	var order: Array = []
	for c in w.body.find_children("Tie_*", "", true, false):   # the cards sit in each group's grid
		if str(c.name).begins_with("Tie_p3") or str(c.name).begins_with("Tie_p4"):
			order.append(str(c.name))
	assert_eq(order, ["Tie_p4", "Tie_p3"])


func test_a_name_opens_the_person_window() -> void:
	var w := _window()
	var got: Array = []
	w.open_requested.connect(func(k: String, sub: String, _s: String): got.append([k, sub]))
	var link: LinkButton = null
	for c in _find(w, "Tie_p1").find_children("*", "LinkButton", true, false):
		link = c
	link.pressed.emit()
	assert_eq(got, [["person", "p1"]])


func test_a_filtered_group_keeps_its_heading() -> void:
	var w := _window()
	w._on_chip(false, "met")
	assert_true(w.section_keys().has("met"), "the heading stays")
	assert_true(_find(w, "Met_m1") == null, "its rows are hidden")
	assert_true(_texts(w.body).contains("hidden by the filter"))


func test_the_relations_entry_turns_groups_back_on_and_fills_the_search() -> void:
	var w := _window()
	w._on_chip(false, "met")
	w.preset_search("ngo duc")
	assert_true(_find(w, "Met_m1") != null, "the met group is back")
	assert_eq(_find(w, "Met_m1").modulate.a, 1.0, "the match is full")
	assert_true(_find(w, "Tie_p1").modulate.a < 1.0, "others dimmed")
