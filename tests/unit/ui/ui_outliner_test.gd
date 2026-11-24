extends DaoTestSuite
## OutlinerPanel and OutlinerPins (design/ux/outliner.md): pinned people with their place and band, "died", the empty
## line, places with "here" or the travel time, collapse, pins per world kept in memory or in the file, the pin limit.


func _panel(v: Dictionary) -> OutlinerPanel:
	var o: OutlinerPanel = auto_free(OutlinerPanel.new())
	add_child(o)
	o.show_view(v)
	return o


static func _texts(n: Node) -> String:
	var out: PackedStringArray = []
	for l in n.find_children("*", "Label", true, false):
		out.append((l as Label).text)
	for b in n.find_children("*", "Button", true, false):
		out.append((b as Button).text)
	return "\n".join(out)


func test_a_pinned_person_shows_where_they_are_and_the_band() -> void:
	var o := _panel({"people": [{"id": "p1", "name": "Trần Vân", "alive": true, "place": "Thanh Vân", "travelling": false, "attitude": 18, "band": "warm", "realm": "Trúc Cơ"}],
		"home": {}, "seat": {}, "event": {}})
	assert_eq(o.person_rows(), 1)
	assert_true(_texts(o).contains("Thanh Vân · warm"))


func test_a_dead_pin_says_died() -> void:
	var o := _panel({"people": [{"id": "p2", "name": "Hắc Sát", "alive": false, "place": "", "attitude": 0, "band": "neutral"}], "home": {}, "seat": {}, "event": {}})
	assert_true(_texts(o).contains("† died"))


func test_with_nothing_to_show_the_empty_line_shows() -> void:
	var o := _panel({"people": [], "home": {}, "seat": {}, "event": {}})
	assert_true(_texts(o).contains("Pin people, places or quests here"))


func test_places_show_here_or_the_travel_time() -> void:
	var o := _panel({"people": [], "home": {"id": "h", "name": "Tùng Hạ Thị", "here": true, "seasons": 0.0}, "seat": {"id": "s", "name": "Thanh Vân Sơn", "here": false, "seasons": 2.0}, "event": {}})
	var t: String = _texts(o)
	assert_true(t.contains("Home: Tùng Hạ Thị") and t.contains("here") and t.contains("2.0 seasons away"), t)


func test_unpin_and_collapse() -> void:
	var o := _panel({"people": [{"id": "p1", "name": "A", "alive": true, "place": "X", "attitude": 0, "band": "neutral"}], "home": {}, "seat": {}, "event": {}})
	var got: Array = []
	o.unpin_requested.connect(func(id: String): got.append(id))
	(o.find_child("Unpin", true, false) as Button).pressed.emit()
	assert_eq(got, ["p1"])
	o.set_open(false)
	assert_false(o.is_open())


func test_pins_are_per_world_and_capped() -> void:
	var pins := OutlinerPins.new("", 2)
	assert_true(pins.pin("7:p0", "a") and pins.pin("7:p0", "b"))
	assert_false(pins.pin("7:p0", "c"), "the limit")
	assert_eq(pins.pins("8:p0"), [], "another world has its own list")
	pins.unpin("7:p0", "a")
	assert_eq(pins.pins("7:p0"), ["b"])


func test_pins_persist_in_their_file() -> void:
	var path := "user://test_pins_%d.cfg" % Time.get_ticks_usec()
	OutlinerPins.new(path).pin("7:p0", "a")
	assert_eq(OutlinerPins.new(path).pins("7:p0"), ["a"])
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
