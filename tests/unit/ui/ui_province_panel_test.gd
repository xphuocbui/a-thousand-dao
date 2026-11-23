extends DaoTestSuite
## The province panel (design/ux/province-panel.md, draft) and the map's province lookup (Provinces rule 1's tile
## index): the panel shows one record's name, holder, four numbers and five tabs; open land under the cursor resolves to
## its province. Fixture records are built here, not read from the shipped data.


func _settlement() -> Dictionary:
	return {"id": 7, "key": "prov_test", "region": 3, "kind": "settlement", "seat_kind": "town", "seat_place": null,
		"name": "Thử Trấn", "name_han": "試鎮", "gloss": "Trial Town", "lore": "A town of trials.",
		"tiles": 90, "centre": [10, 10], "land": {"grassland": 0.7, "temperate_forest": 0.3}, "river_tiles": 4,
		"road_tiles": 6, "coast": false, "elev_mean": 120.0, "elev_max": 300.0,
		"places": [{"id": 5, "name": "Cổ Tự", "name_han": "古寺", "kind": "ruin", "new": false},
			{"slot": "prov_test_mine_1", "name": "Thiết Khoáng", "name_han": "鐵礦", "kind": "mine", "new": true, "proposal": false}],
		"stats": {"population": 4.0, "capacity": 4.8, "production": {"herb1": 300.0, "ore1": 120.0},
			"own_output": {"herb1": 250.0, "ore1": 120.0}, "main_good": "herb1", "secondary_goods": ["ore1"],
			"buildings": [{"kind": "road", "name": "Road", "level": 1}, {"kind": "granary", "name": "Granary", "level": 2}],
			"slots": 3, "infrastructure": 640, "infra_old": 0, "usage": 420, "access": 1.0, "development": 7}}


func _panel() -> ProvincePanel:
	var p := ProvincePanel.new()
	add_child(p)
	auto_free(p)
	return p


func test_the_panel_shows_the_name_holder_and_four_numbers() -> void:
	# Arrange
	var p := _panel()
	# Act
	p.open_province(_settlement(), {"region_name": "Thử Vực", "holder_name": "Thử Tông"})
	# Assert
	assert_true(p.visible, "open")
	assert_eq(p._title.text, "Thử Trấn", "the province's name")
	assert_true(p._han.text.contains("試鎮"), "the Chinese name under it")
	assert_true(p._sub.text.contains("Thử Tông"), "the holder in the sub line")
	assert_eq(p._stats.get_child_count(), 4, "population, development, access, main good")


func test_each_tab_shows_its_part_of_the_record() -> void:
	var p := _panel()
	p.open_province(_settlement(), {})
	assert_true(p.body_text().contains("A town of trials."), "Overview: the lore")
	p.show_tab(1)
	assert_true(p.body_text().contains("Thiết Khoáng") and p.body_text().contains("new"), "Places: a new place is marked new")
	p.show_tab(2)
	assert_true(p.body_text().contains("50 from the wilds"), "Economy: the gathered share is its own line")
	p.show_tab(3)
	assert_true(p.body_text().contains("2 / 3"), "Works: buildings standing of slots")
	assert_true(p.body_text().contains("empty slot"), "and the empty slot")
	p.show_tab(4)
	assert_true(p.body_text().contains("No modifiers"), "Modifiers: says so when there are none")


func test_a_wilderness_province_shows_what_it_passes_on_and_no_population() -> void:
	var r := _settlement()
	r.kind = "wilderness"
	r.stats.access = null
	r.passes_to = [{"province": "prov_a", "share": 0.75}, {"province": "prov_b", "share": 0.25}]
	var p := _panel()
	p.open_province(r, {})
	p.show_tab(2)
	assert_true(p.body_text().contains("prov_a  75 %"), "its output's share to each gatherer")
	var pop_value: Label = p._stats.get_child(0).get_child(1)
	assert_eq(pop_value.text, "—", "no population in the wilderness")


func test_closing_hides_the_panel_and_emits_closed() -> void:
	var p := _panel()
	p.open_province(_settlement(), {})
	var seen := [false]
	p.closed.connect(func(): seen[0] = true)
	p.close_panel()
	assert_false(p.visible, "hidden")
	assert_true(seen[0], "closed emitted")


func test_the_shipped_provinces_all_have_a_key_and_a_start_record() -> void:
	var provs: Array = game_data().file("world_provinces").get("provinces", [])
	assert_true(provs.size() > 273, "more provinces than the first cut")
	var keys := {}
	for r in provs:
		assert_false(str(r.get("key", "")) == "", "every province has a key")
		assert_false(keys.has(r.key), "keys are unique: %s" % str(r.key))
		keys[r.key] = true
		assert_true(r.has("stats") and r.stats.has("development"), "every province has its start record")


func test_the_map_finds_the_province_under_open_land() -> void:
	# Arrange: a map with the shipped tile index
	var gd := game_data()
	var cfg: Dictionary = gd.file("ui_hud").get("greybox", {}).duplicate(true)
	for k in ["far_layer", "near_layer", "place_sprites", "near_hi"]:
		cfg[k] = ""
	cfg["terrain_shader"] = {}
	cfg["alive"] = {}
	var v := MapView.new()
	v.size = Vector2(1920, 1080)
	v.setup(ContinentGrid.from_continent(gd), cfg, 4.0)
	auto_free(v)
	# Act: the province record of Bình Thủy Môn's tile (its seat province) and the one the map finds there
	var want: int = 0
	for r in gd.file("world_provinces").get("provinces", []):
		if str(r.key) == "prov_binh_thuy":
			want = int(r.id)
	var at: Vector2 = v.tile_to_local(Vector2i(125, 247))
	# Assert
	assert_true(want > 0, "the seat's province is in the data")
	assert_eq(v.province_at(at), want, "the tile index puts the seat in its own province")
	assert_eq(v.province_at(v.tile_to_local(Vector2i(0, 0))), 0, "open sea has no province")


func test_a_province_map_mode_replaces_the_political_tint_and_turns_off_again() -> void:
	# Arrange
	var gd := game_data()
	var cfg: Dictionary = gd.file("ui_hud").get("greybox", {}).duplicate(true)
	for k in ["far_layer", "near_layer", "place_sprites", "near_hi"]:
		cfg[k] = ""
	cfg["terrain_shader"] = {}
	cfg["alive"] = {}
	var v := MapView.new()
	v.size = Vector2(1920, 1080)
	v.setup(ContinentGrid.from_continent(gd), cfg, 4.0)
	auto_free(v)
	# Act / Assert
	v.set_province_colours({1: Color.RED, 2: Color.BLUE})
	assert_true(v.province_mode_on(), "colours given: the mode is on")
	v.set_province_colours({})
	assert_false(v.province_mode_on(), "an empty set turns it off")


func test_v_opens_the_province_at_the_view_centre() -> void:
	# Arrange: a map centred on Bình Thủy Môn's tile
	var gd := game_data()
	var cfg: Dictionary = gd.file("ui_hud").get("greybox", {}).duplicate(true)
	for k in ["far_layer", "near_layer", "place_sprites", "near_hi"]:
		cfg[k] = ""
	cfg["terrain_shader"] = {}
	cfg["alive"] = {}
	var v := MapView.new()
	v.size = Vector2(1920, 1080)
	v.setup(ContinentGrid.from_continent(gd), cfg, 4.0)
	auto_free(v)
	v.set_region_zoom(true, Vector2(125.5, 247.5))
	var got := [0]
	v.province_clicked.connect(func(id): got[0] = id)
	# Act
	var ev := InputEventKey.new()
	ev.physical_keycode = KEY_V
	ev.pressed = true
	v._gui_input(ev)
	# Assert
	assert_eq(got[0], v.province_at(v.size * 0.5), "V asks for the province under the view's centre")
	assert_true(got[0] > 0, "there is land there")
