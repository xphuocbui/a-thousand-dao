extends DaoTestSuite
## RosewoodTheme (design/art/art-bible.md 7.10-7.12, 8.7): the theme is built from ui_hud.json "theme" and the cut
## kit; panels and plaques are nine-slice textures at 1x with the kit's margins halved; text defaults to ink for
## parchment; numbers use tabular figures; every state comes from one texture; a missing asset is reported and falls
## back to a flat style instead of failing silently.


static func _cfg() -> Dictionary:
	var gd := GameData.load_from("res://assets/data")
	return gd.file("ui_hud").get("theme", {})


func test_panels_and_plaques_are_kit_textures_with_halved_margins() -> void:
	var built: Dictionary = RosewoodTheme.build(_cfg())
	assert_eq(built.errors.size(), 0, "every kit texture and font loads (errors: %s)" % str(built.errors))
	var t: Theme = built.theme
	var kit: Dictionary = RosewoodTheme.load_kit("res://assets/ui/kit.json", PackedStringArray()).pieces
	var win: StyleBox = t.get_stylebox(&"panel", &"WindowPanel")
	assert_true(win is StyleBoxTexture, "the window panel is the frame texture")
	assert_eq((win as StyleBoxTexture).texture_margin_left, float(kit.frame_window.margins[0]) / 2.0, "the 1x margin is half the 2x one")
	assert_true((win as StyleBoxTexture).draw_center, "a window draws its parchment body")
	assert_true(not (t.get_stylebox(&"panel", &"BoardPanel") as StyleBoxTexture).draw_center, "a board panel is the frame only")
	assert_true(str((t.get_stylebox(&"normal", &"Button") as StyleBoxTexture).texture.resource_path).ends_with("plaque_wood_1x.png"),
		"buttons are the wood plaque at 1x")
	assert_true(str((t.get_stylebox(&"normal", &"CommitButton") as StyleBoxTexture).texture.resource_path).ends_with("plaque_cinnabar_1x.png"),
		"commit buttons are the cinnabar plaque")


func test_states_come_from_one_texture_and_text_is_ink_with_tabular_digits() -> void:
	var t: Theme = RosewoodTheme.build(_cfg()).theme
	var normal: StyleBoxTexture = t.get_stylebox(&"normal", &"Button")
	var hover: StyleBoxTexture = t.get_stylebox(&"hover", &"Button")
	var pressed: StyleBoxTexture = t.get_stylebox(&"pressed", &"Button")
	assert_eq(hover.texture, normal.texture, "hover reuses the plaque")
	assert_true(hover.modulate_color.r > 1.0, "hover brightens it")
	assert_true(pressed.modulate_color.r < 1.0 and pressed.content_margin_top > normal.content_margin_top, "pressed is darker and 1 px lower")
	assert_eq(t.get_color(&"font_color", &"Label"), Color("#2B2118"), "text defaults to ink, for parchment")
	assert_eq(t.get_color(&"font_color", &"WoodLabel"), Color("#E8D9B5"), "bone on wood")
	var f: FontVariation = t.default_font
	var tnum: int = TextServerManager.get_primary_interface().name_to_tag("tnum")
	assert_eq(int(f.opentype_features.get(tnum, 0)), 1, "the default font uses tabular figures")
	var w1: float = f.get_string_size("1", HORIZONTAL_ALIGNMENT_LEFT, -1, 32).x
	var w8: float = f.get_string_size("8", HORIZONTAL_ALIGNMENT_LEFT, -1, 32).x
	assert_eq(w1, w8, "so a 1 and an 8 are the same width")


func test_a_missing_kit_is_reported_and_falls_back_to_flat_styles() -> void:
	var cfg: Dictionary = _cfg().duplicate(true)
	cfg["kit"] = "res://assets/ui/no_such_kit.json"
	cfg["paper_texture"] = "res://assets/ui/textures/no_such.png"
	var built: Dictionary = RosewoodTheme.build(cfg)
	assert_true(Array(built.errors).any(func(e): return str(e).contains("no_such_kit.json")), "the missing manifest is named")
	assert_true(Array(built.errors).any(func(e): return str(e).contains("no_such.png")), "so is the missing texture")
	assert_true(built.theme.get_stylebox(&"panel", &"WindowPanel") is StyleBoxFlat, "the window falls back to a flat panel")
	assert_true(built.theme.get_stylebox(&"normal", &"Button") is StyleBoxFlat, "and the plaque to a flat button")
