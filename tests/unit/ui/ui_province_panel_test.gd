extends DaoTestSuite
## The province window (design/ux/province-panel.md, draft; in the window host since 2026-11-24) and the map's province lookup (Provinces rule 1's tile
## index): the panel shows one record's name, holder, four numbers and five sections; open land under the cursor resolves to
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


func _window(v: Dictionary) -> ProvinceWindow:
	var w := ProvinceWindow.new()
	add_child(w)
	auto_free(w)
	w.show_view(v, "", false)
	return w


func _view(extra: Dictionary = {}) -> Dictionary:
	var v := _settlement()
	v["region_name"] = "Thử Vực"
	v["holder_name"] = "Thử Tông"
	v["place_ids"] = {"5": "l5"}
	v["art_order"] = [-1]   # no painting
	v.merge(extra, true)
	return v


func test_the_window_shows_the_name_holder_and_four_numbers() -> void:
	# Arrange / Act
	var w := _window(_view())
	# Assert
	assert_eq(w.kind(), "provinces", "its kind in the host")
	assert_eq(w.window_title(w.view), "Thử Trấn", "the province's name is the title")
	var texts: Array = w.header.get_children().filter(func(c): return c is Label).map(func(c): return (c as Label).text)
	assert_true(texts.any(func(t): return str(t).contains("試鎮")), "the Chinese name in the header")
	assert_true(texts.any(func(t): return str(t).contains("Thử Tông")), "the holder in the sub line")
	var strip: HBoxContainer = w.header.get_children().filter(func(c): return c is HBoxContainer)[0]
	assert_eq(strip.get_child_count(), 4, "population, development, access, main good")


func test_each_section_shows_its_part_of_the_record() -> void:
	var w := _window(_view())
	assert_eq(w.section_keys(), ["overview", "places", "economy", "works", "modifiers"], "five sections, jump targets")
	assert_true(w.section_text("overview").contains("A town of trials."), "Overview: the lore")
	assert_true(w.section_text("places").contains("Thiết Khoáng"), "Places: every place")
	assert_true(w.section_text("economy").contains("50 from the wilds"), "Economy: the gathered share is its own line")
	assert_true(w.section_text("works").contains("2 / 3"), "Works: buildings standing of slots")
	assert_true(w.section_text("works").contains("empty slot"), "and the empty slot")
	assert_true(w.section_text("modifiers").contains("No modifiers"), "Modifiers: says so when there are none")


func test_a_known_place_link_opens_its_place_panel() -> void:
	var w := _window(_view())
	var seen: Array = []
	w.open_requested.connect(func(k, sub, _sec): seen.append([k, sub]))
	w._on_link("5")
	w._on_link("99")   # not known: no link
	assert_eq(seen, [["place", "l5"]], "the session id of the known place")


func test_a_wilderness_province_shows_what_it_passes_on_and_no_population() -> void:
	var v := _view()
	v.kind = "wilderness"
	v.stats.access = null
	v.passes_to = [{"province": "prov_a", "share": 0.75}, {"province": "prov_b", "share": 0.25}]
	var w := _window(v)
	assert_true(w.section_text("economy").contains("prov_a  75 %"), "its output's share to each gatherer")
	var strip: HBoxContainer = w.header.get_children().filter(func(c): return c is HBoxContainer)[0]
	assert_eq((strip.get_child(0).get_child(1) as Label).text, "—", "no population in the wilderness")


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


func test_good_classes_are_named_by_kind_and_rarity_band() -> void:
	assert_eq(ProvinceWindow.good_name("herb2"), "Herbs, rarity 3–4", "band 2 = rarity 3-4 (TradeGoods.class_of)")
	assert_eq(ProvinceWindow.good_name("special1"), "Specialties, rarity 1–2", "specialties too")
	assert_eq(ProvinceWindow.good_name("odd"), "odd", "an unknown class shows as it is")


func test_population_shows_as_people_one_unit_a_thousand_mortals() -> void:
	# user decision 2026-11-24: population as people, 1 settlement unit = 1,000 mortals (display only)
	assert_eq(ProvinceWindow.people(3.4), "3,400", "3.4 units")
	assert_eq(ProvinceWindow.people(0.04), "0", "rounded to the hundred")
	assert_eq(ProvinceWindow.people(1234.5), "1,234,500", "thousands separators")
	assert_eq(ProvinceWindow.people(2.0, 500.0), "1,000", "the scale is a knob")


func test_a_province_without_a_painting_shows_the_placeholder_not_a_stand_in() -> void:
	# .claude/rules/ui-code.md (user 2026-11-24): missing art is shown as an obvious placeholder
	var w := _window(_view())
	assert_true(w.shows_placeholder(), "no painting: the placeholder shows")
	var cid: int = -1
	for f in DirAccess.get_files_at("res://assets/art/places"):
		if f.ends_with(".webp") and str(f.get_basename()).is_valid_int():
			cid = int(f.get_basename())
			break
	assert_true(cid >= 0, "a painted place exists")
	w.show_view(_view({"art_order": [cid]}), "", false)
	assert_false(w.shows_placeholder(), "a painting: no placeholder")


func test_the_placeholder_is_obvious() -> void:
	var c: Control = PlaceholderArt.make(Vector2(0, 100), "No painting yet")
	auto_free(c)
	assert_true(bool(c.get_meta("placeholder", false)), "marked as a placeholder")
	var tip: String = str(c.get_meta(TooltipLayer.META, ""))
	assert_true(tip.contains("PLACEHOLDER") and tip.contains("No painting yet"), tip)
	var tex: Texture2D = PlaceholderArt.texture()
	assert_true(PlaceholderArt.is_placeholder(tex), "the shared texture")
	var im: Image = tex.get_image()
	assert_eq(im.get_pixel(0, 0), PlaceholderArt.MAGENTA, "magenta stripes")
