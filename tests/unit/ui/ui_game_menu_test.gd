extends DaoTestSuite
## GameMenu and PlayerSettings (design/ux/game-menu.md): pages, Esc steps, confirm-in-place quit / load / overwrite,
## the settings-only fight variant, slot names, and the settings store's defaults, clamping and persistence.

const DEFS := {
	"ui_scale": {"default": 100, "options": [75, 90, 100, 115, 125, 150]},
	"reduced_motion": {"default": false},
	"colourblind": {"default": "off", "options": ["off", "red_green"]},
	"tooltip_delay": {"default": 0.3, "min": 0.0, "max": 2.0},
}


func _menu() -> GameMenu:
	var m: GameMenu = auto_free(GameMenu.new())
	m.settings = PlayerSettings.new(DEFS, "")
	m.saves = [{"slot": "a", "name": "A", "date": "Xuân 1200", "realm": "Luyện Khí", "time": "t", "ok": true},
		{"slot": "old", "name": "Old", "ok": false, "reason": "Made on another map version"}]
	add_child(m)
	m.open_menu()
	return m


static func _find(root: Node, name: String) -> Node:
	return root.find_child(name, true, false)


func test_the_menu_page_has_the_six_buttons_in_order() -> void:
	var m := _menu()
	var names: Array = []
	for c in m._body.get_children():
		if c is Button:
			names.append(str(c.name))
	assert_eq(names, ["Resume", "Save", "Load", "Settings", "Wiki", "Quit"])


func test_esc_goes_back_to_the_menu_from_a_page_then_closes() -> void:
	var m := _menu()
	m.show_page("settings")
	m.back_or_close()
	assert_eq(m.page(), "menu", "back to Menu")
	m.back_or_close()
	assert_false(m.visible, "closed from Menu")


func test_quit_arms_first_and_cancel_emits_nothing() -> void:
	var m := _menu()
	var got: Array = []
	m.quit_requested.connect(func(sf: bool): got.append(sf))
	(_find(m, "Quit") as Button).pressed.emit()
	assert_eq(got, [], "the first press only arms")
	(_find(m, "CancelQuit") as Button).pressed.emit()
	assert_true(_find(m, "Quit") != null, "Cancel disarms")
	(_find(m, "Quit") as Button).pressed.emit()
	(_find(m, "QuitNow") as Button).pressed.emit()
	assert_eq(got, [false])


func test_load_arms_first_and_only_its_confirm_emits() -> void:
	var m := _menu()
	m.show_page("load")
	var got: Array = []
	m.load_requested.connect(func(slot: String): got.append(slot))
	(_find(m, "Load_a") as Button).pressed.emit()
	assert_eq(got, [], "armed, not loaded")
	(_find(m, "ConfirmLoad") as Button).pressed.emit()
	assert_eq(got, ["a"])
	assert_true((_find(m, "Load_old") as Button).disabled, "a save this build cannot load is greyed")


func test_a_new_save_whose_slot_exists_asks_to_overwrite_instead_of_saving() -> void:
	var m := _menu()
	m.show_page("save")
	var got: Array = []
	m.save_requested.connect(func(n: String, slot: String): got.append([n, slot]))
	m._save_as("A", "")
	assert_eq(got, [], "nothing saved over the existing file")
	assert_true(_find(m, "ConfirmOverwrite") != null, "the overwrite confirm is armed")
	(_find(m, "ConfirmOverwrite") as Button).pressed.emit()
	assert_eq(got, [["A", "a"]])
	m._save_as("Brand New", "")
	assert_eq(got[1], ["Brand New", "brand_new"], "a fresh name saves to its own slot")


func test_slot_names_keep_ascii_letters_and_digits() -> void:
	assert_eq(GameMenu.slot_name("Lâm Phong, Xuân 1200"), "l_m_phong_xu_n_1200")
	assert_eq(GameMenu.slot_name("  ***  "), "save")


func test_the_fight_variant_is_settings_only_and_esc_closes_it() -> void:
	var m := _menu()
	m.close_menu()
	m.open_menu("menu", null, true)
	assert_eq(m.page(), "settings", "settings only")
	var has_back: bool = false
	for c in m._body.get_children():
		if c is Button and str((c as Button).text) == "Back":
			has_back = true
	assert_false(has_back, "no Back to the menu in a fight")
	m.back_or_close()
	assert_false(m.visible, "Esc closes it")


func test_esc_while_busy_is_consumed_and_keeps_the_page() -> void:
	var m := _menu()
	m.show_page("save")
	m.set_busy(true, "Saving…")
	m.back_or_close()
	assert_eq(m.page(), "save")
	assert_true(m.status_text().contains("wait"), "the status says to wait")


func test_settings_use_the_data_defaults_and_clamp() -> void:
	var st := PlayerSettings.new(DEFS, "")
	assert_eq(int(st.value("ui_scale")), 100)
	assert_eq(st.value("reduced_motion"), false)
	assert_near(float(st.set_value("tooltip_delay", 9.0)), 2.0, 0.001, "clamped to the max")
	assert_eq(int(st.set_value("ui_scale", 115)), 115, "an int option matches the JSON float")
	assert_eq(int(st.set_value("ui_scale", 333)), 100, "an unknown option falls back to the default")
	assert_eq(st.set_value("colourblind", "red_green"), "red_green")


func test_settings_persist_across_a_reload() -> void:
	var path := "user://test_settings_%d.cfg" % Time.get_ticks_usec()
	var st := PlayerSettings.new(DEFS, path)
	st.set_value("reduced_motion", true)
	var again := PlayerSettings.new(DEFS, path)
	assert_eq(again.value("reduced_motion"), true, "kept in the file")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
