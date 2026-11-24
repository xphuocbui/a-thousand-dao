class_name RosewoodTheme
extends RefCounted
## Builds the Rosewood Campaign Table theme (design/art/art-bible.md 7.10-7.12 and 8.7) from ui_hud.json "theme" and
## the cut kit (assets/ui/kit.json: nine-slice margins in 2x pixels; the theme uses the `_1x` textures, because a
## StyleBoxTexture draws its fixed corners at the texture's own pixel size).
##
## Type variations (set [member Control.theme_type_variation]):
## - Panels: "WindowPanel" (rosewood frame, parchment body), "BoardPanel" (the frame only, over the wood board),
##   "PaperPanel" (a flat parchment inset), "WoodPanel" (a flat rosewood strip), "TooltipPanel" (the parchment card).
## - Labels: default Label is ink (for parchment); "WoodLabel" bone (for wood); "HeadingLabel" / "TitleLabel" the
##   heading face on parchment; "WoodHeading" the heading face in brass on wood; "RowLabel" small gilt caps on
##   parchment; "WoodRowLabel" small brass caps on wood.
## - Buttons: default Button is the wood plaque; "CommitButton" the cinnabar plaque (End turn, an event choice).
## Every state (hover, pressed, disabled, focus) is drawn by the engine from one texture (art bible 7.7, 7.12).
##
## Usage:
## [codeblock]
## var built: Dictionary = RosewoodTheme.build(gd.file("ui_hud").get("theme", {}))
## fight_screen.theme = built.theme
## for e in built.errors: push_warning(e)
## [/codeblock]

const KIT_DEFAULT := "res://assets/ui/kit.json"


## Builds the theme. [param cfg] is ui_hud.json "theme"; [param kit] is assets/ui/kit.json's content (read from
## cfg.kit when empty). Returns {theme: Theme, errors: PackedStringArray, fonts: {body, strong, heading}}: errors
## names every texture or font that could not be loaded (its style falls back to a flat colour), so a missing asset
## is reported, never silent.
static func build(cfg: Dictionary, kit: Dictionary = {}, surface: String = "paper") -> Dictionary:
	var errors: PackedStringArray = []
	if kit.is_empty():
		kit = load_kit(str(cfg.get("kit", KIT_DEFAULT)), errors)
	var pieces: Dictionary = kit.get("pieces", {})
	var pal: Dictionary = cfg.get("palette", {})
	var c := func(key: String, fallback: String) -> Color: return Color.from_string(str(pal.get(key, fallback)), Color(fallback))
	var ink: Color = c.call("ink", "#2B2118")
	var bone: Color = c.call("bone", "#E8D9B5")
	var brass: Color = c.call("brass", "#C9A25A")
	var gilt: Color = c.call("gilt", "#5E4316")
	var wood: Color = c.call("rosewood", "#2A1A12")
	var paper: Color = c.call("parchment", "#E3D4AE")
	var sizes: Dictionary = cfg.get("sizes", {})
	var size_of := func(key: String, fallback: int) -> int: return int(sizes.get(key, fallback))
	var fonts_cfg: Dictionary = cfg.get("fonts", {})
	var body_base: Font = _load_font(str(fonts_cfg.get("body", "")), errors)
	var head_base: Font = _load_font(str(fonts_cfg.get("heading", "")), errors)
	var body: Font = variation(body_base, int(fonts_cfg.get("body_weight", 400)), true)
	var strong: Font = variation(body_base, int(fonts_cfg.get("strong_weight", 600)), true)
	var heading: Font = variation(head_base, int(fonts_cfg.get("heading_weight", 600)), false)
	var t := Theme.new()
	t.default_font = body
	t.default_font_size = size_of.call("body", 16)
	# labels: ink on parchment by default; a "wood" theme (the HUD) is bone on wood
	var text_col: Color = bone if surface == "wood" else ink
	t.set_color(&"font_color", &"Label", text_col)
	_variation(t, &"WoodLabel", &"Label")
	t.set_color(&"font_color", &"WoodLabel", bone)
	_variation(t, &"HeadingLabel", &"Label")
	t.set_font(&"font", &"HeadingLabel", heading)
	t.set_font_size(&"font_size", &"HeadingLabel", size_of.call("heading", 22))
	_variation(t, &"TitleLabel", &"Label")
	t.set_font(&"font", &"TitleLabel", heading)
	t.set_font_size(&"font_size", &"TitleLabel", size_of.call("title", 28))
	_variation(t, &"WoodHeading", &"Label")
	t.set_font(&"font", &"WoodHeading", heading)
	t.set_font_size(&"font_size", &"WoodHeading", size_of.call("heading", 22))
	t.set_color(&"font_color", &"WoodHeading", brass)
	_variation(t, &"RowLabel", &"Label")
	t.set_font(&"font", &"RowLabel", strong)
	t.set_font_size(&"font_size", &"RowLabel", size_of.call("small", 14))
	t.set_color(&"font_color", &"RowLabel", gilt)
	_variation(t, &"WoodRowLabel", &"Label")
	t.set_font(&"font", &"WoodRowLabel", strong)
	t.set_font_size(&"font_size", &"WoodRowLabel", size_of.call("small", 14))
	t.set_color(&"font_color", &"WoodRowLabel", brass)
	t.set_color(&"default_color", &"RichTextLabel", text_col)
	t.set_font(&"normal_font", &"RichTextLabel", body)
	t.set_font(&"bold_font", &"RichTextLabel", strong)
	# panels
	var window: StyleBox = _frame(pieces.get("frame_window", {}), paper, errors, true)
	t.set_stylebox(&"panel", &"WindowPanel", window)
	_variation(t, &"WindowPanel", &"PanelContainer")
	var board: StyleBox = _frame(pieces.get("frame_board", pieces.get("frame_window", {})), paper, errors, false)
	t.set_stylebox(&"panel", &"BoardPanel", board)
	_variation(t, &"BoardPanel", &"PanelContainer")
	t.set_stylebox(&"panel", &"PaperPanel", _tiled(str(cfg.get("paper_texture", "")), paper, 8.0, errors))
	_variation(t, &"PaperPanel", &"PanelContainer")
	t.set_stylebox(&"panel", &"WoodPanel", _tiled(str(cfg.get("wood_texture", "")), wood, 6.0, errors))
	_variation(t, &"WoodPanel", &"PanelContainer")
	var card: StyleBox = _nine(pieces.get("card_tooltip", {}), paper, errors, 12.0)
	t.set_stylebox(&"panel", &"TooltipPanel", card)
	_variation(t, &"TooltipPanel", &"PanelContainer")
	# buttons: one plaque, every state drawn by modulation; the toggled-on state reads as pressed with brass text
	var st: Dictionary = cfg.get("states", {})
	var mod := func(key: String, fallback: Array) -> Color:
		var v: Array = st.get(key, fallback)
		return Color(float(v[0]), float(v[1]), float(v[2]))
	for spec in [[&"Button", pieces.get("plaque_wood", {}), wood], [&"CommitButton", pieces.get("plaque_cinnabar", {}), c.call("cinnabar", "#84191B")]]:
		var type: StringName = spec[0]
		if type != &"Button":
			_variation(t, type, &"Button")
		var normal: StyleBox = _nine(spec[1], spec[2], errors, 6.0)
		t.set_stylebox(&"normal", type, normal)
		t.set_stylebox(&"hover", type, _modulated(normal, mod.call("hover", [1.18, 1.14, 1.05]), 0))
		t.set_stylebox(&"pressed", type, _modulated(normal, mod.call("pressed", [0.78, 0.74, 0.7]), 1))
		t.set_stylebox(&"hover_pressed", type, _modulated(normal, mod.call("pressed", [0.78, 0.74, 0.7]), 1))
		# disabled on parchment: a flat faint outline, not a dimmed live plaque, so a greyed action never reads as a live
		# one (weak-point review 2026-11-24: "information and action look alike"); on wood (the HUD, over the map) the
		# opaque dimmed plaque stays, a see-through box there would show the map through it
		if surface != "wood":
			var off := StyleBoxFlat.new()
			off.bg_color = Color(wood, 0.10)
			off.border_color = Color(brass, 0.35)
			off.set_border_width_all(1)
			off.set_corner_radius_all(3)
			off.set_content_margin_all(6.0)
			t.set_stylebox(&"disabled", type, off)
		else:
			t.set_stylebox(&"disabled", type, _modulated(normal, mod.call("disabled", [0.55, 0.52, 0.5]), 0))
		t.set_stylebox(&"focus", type, focus_ring(bone, ink))
		t.set_color(&"font_color", type, bone)
		t.set_color(&"font_hover_color", type, bone.lightened(0.1))
		t.set_color(&"font_focus_color", type, bone)
		t.set_color(&"font_pressed_color", type, brass.lightened(0.15))
		t.set_color(&"font_hover_pressed_color", type, brass.lightened(0.15))
		# readable but plainly off: muted ink on parchment, faded bone on wood
		t.set_color(&"font_disabled_color", type, Color(ink, 0.62) if surface != "wood" else Color(bone, 0.45))
	# the third button tier: a link to another window, drawn as text (no plaque), underlined in brass on hover
	_variation(t, &"TextButton", &"Button")
	var flat := StyleBoxEmpty.new()
	flat.set_content_margin_all(4.0)
	var under := StyleBoxFlat.new()
	under.bg_color = Color(0, 0, 0, 0)
	under.border_color = brass
	under.border_width_bottom = 2
	under.set_content_margin_all(4.0)
	for state in [&"normal", &"pressed", &"disabled"]:
		t.set_stylebox(state, &"TextButton", flat)
	t.set_stylebox(&"hover", &"TextButton", under)
	t.set_stylebox(&"hover_pressed", &"TextButton", under)
	t.set_color(&"font_color", &"TextButton", gilt if surface != "wood" else brass)
	t.set_color(&"font_hover_color", &"TextButton", ink if surface != "wood" else bone)
	t.set_color(&"font_focus_color", &"TextButton", ink if surface != "wood" else bone)
	t.set_color(&"font_disabled_color", &"TextButton", Color(gilt, 0.4))
	# default panels: on wood the HUD plates are the wood plaque with its rivets; on parchment a nested panel is plain
	if surface == "wood":
		var plate: StyleBox = _nine(pieces.get("plaque_wood", {}), wood, errors, 8.0)
		plate.content_margin_left = 12.0
		plate.content_margin_right = 12.0
		plate.content_margin_top = 8.0
		plate.content_margin_bottom = 8.0
		t.set_stylebox(&"panel", &"PanelContainer", plate)
	else:
		var plain := StyleBoxEmpty.new()
		t.set_stylebox(&"panel", &"PanelContainer", plain)
	# bars, the timeline, separators, scroll bars
	var trough: StyleBox = _nine(pieces.get("bar_trough", {}), wood, errors, 3.0)
	t.set_stylebox(&"background", &"ProgressBar", trough)
	var fill := StyleBoxFlat.new()   # progress (cultivation): brass, inside the trough's rim
	fill.bg_color = brass.darkened(0.1)
	fill.set_expand_margin_all(-3.0)
	t.set_stylebox(&"fill", &"ProgressBar", fill)
	t.set_color(&"font_color", &"ProgressBar", bone)
	t.set_color(&"font_outline_color", &"ProgressBar", Color(0, 0, 0, 0.8))
	t.set_constant(&"outline_size", &"ProgressBar", 3)
	t.set_stylebox(&"trough", &"FightStatBar", trough)
	t.set_stylebox(&"slider", &"HSlider", trough)
	var grab := StyleBoxFlat.new()
	grab.bg_color = brass
	grab.set_content_margin_all(2)
	t.set_stylebox(&"grabber_area", &"HSlider", grab)
	t.set_stylebox(&"grabber_area_highlight", &"HSlider", grab)
	var line := StyleBoxLine.new()
	line.color = Color(brass, 0.6)
	line.thickness = 1
	t.set_stylebox(&"separator", &"HSeparator", line)
	var sbar := StyleBoxFlat.new()
	sbar.bg_color = Color(brass, 0.7)
	sbar.set_corner_radius_all(2)
	for s in [&"grabber", &"grabber_highlight", &"grabber_pressed"]:
		t.set_stylebox(s, &"VScrollBar", sbar)
	var lane := StyleBoxFlat.new()
	lane.bg_color = Color(ink, 0.18)
	t.set_stylebox(&"scroll", &"VScrollBar", lane)
	# lists and text fields: a slightly darker inset with a thin gilt line (parchment) or a dark recess (wood), ink or
	# bone text, a cinnabar or brass selection band, the double focus ring (art bible 7.12)
	var inset := StyleBoxFlat.new()
	inset.bg_color = c.call("parchment_dark", "#D8C7A0") if surface != "wood" else c.call("recess", "#150D09")
	inset.border_color = Color(gilt if surface != "wood" else brass, 0.55)
	inset.set_border_width_all(1)
	inset.set_corner_radius_all(2)
	inset.set_content_margin_all(6)
	var picked := StyleBoxFlat.new()
	picked.bg_color = Color(c.call("cinnabar", "#84191B"), 0.16) if surface != "wood" else Color(brass, 0.22)
	picked.border_color = c.call("cinnabar", "#84191B") if surface != "wood" else brass
	picked.border_width_left = 3
	for type in [&"ItemList", &"Tree"]:
		t.set_stylebox(&"panel", type, inset)
		t.set_stylebox(&"focus", type, focus_ring(bone, ink))
		t.set_stylebox(&"selected", type, picked)
		t.set_stylebox(&"selected_focus", type, picked)
		t.set_stylebox(&"cursor", type, StyleBoxEmpty.new())
		t.set_stylebox(&"cursor_unfocused", type, StyleBoxEmpty.new())
		t.set_color(&"font_color", type, text_col)
		t.set_color(&"font_selected_color", type, text_col)
		t.set_color(&"font_hovered_color", type, text_col)
		t.set_color(&"guide_color", type, Color(text_col, 0.12))
	var hovered := StyleBoxFlat.new()
	hovered.bg_color = Color(text_col, 0.06)
	t.set_stylebox(&"hovered", &"ItemList", hovered)
	t.set_stylebox(&"normal", &"LineEdit", inset)
	t.set_stylebox(&"focus", &"LineEdit", focus_ring(bone, ink))
	t.set_stylebox(&"read_only", &"LineEdit", inset)
	t.set_color(&"font_color", &"LineEdit", text_col)
	t.set_color(&"font_placeholder_color", &"LineEdit", Color(gilt if surface != "wood" else brass, 0.85))
	t.set_color(&"caret_color", &"LineEdit", text_col)
	t.set_color(&"selection_color", &"LineEdit", Color(brass, 0.35))
	# custom-drawn fight controls read these colours (art bible 7.1, 7.12)
	t.set_color(&"edge", &"FightSlot", c.call("tile_edge", "#1A100B"))
	# an empty slot is a recess in its surface: pressed-in parchment with a gilt dash on paper, a dark hole on wood
	t.set_color(&"dash", &"FightSlot", Color(gilt, 0.7) if surface != "wood" else Color(brass, 0.75))
	t.set_color(&"recess", &"FightSlot", c.call("parchment_recess", "#CDBA8E") if surface != "wood" else c.call("recess", "#150D09"))
	t.set_color(&"ring_outer", &"FightSlot", bone)
	t.set_color(&"ring_inner", &"FightSlot", ink)
	t.set_color(&"text", &"FightStatBar", bone)
	return {"theme": t, "errors": errors, "fonts": {"body": body, "strong": strong, "heading": heading}}


## Reads the kit manifest at [param path]; appends to [param errors] and returns {} when it cannot.
static func load_kit(path: String, errors: PackedStringArray) -> Dictionary:
	if not FileAccess.file_exists(path):
		errors.append("kit manifest missing: " + path)
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not (parsed is Dictionary):
		errors.append("kit manifest unreadable: " + path)
		return {}
	return parsed


## A FontVariation of [param base] at [param weight] (the variable font's wght axis), with tabular figures when
## [param tnum] (art bible 7.11: numbers use tabular digits). A null base gives the engine's fallback font.
static func variation(base: Font, weight: int, tnum: bool) -> FontVariation:
	var ts := TextServerManager.get_primary_interface()
	var fv := FontVariation.new()
	if base != null:
		fv.base_font = base
	fv.variation_opentype = {ts.name_to_tag("wght"): weight}
	if tnum:
		fv.opentype_features = {ts.name_to_tag("tnum"): 1}
	return fv


## The double focus ring (art bible 7.12): bone outside, ink inside, the same on wood and parchment.
static func focus_ring(outer: Color, inner: Color) -> StyleBoxFlat:
	var ring := StyleBoxFlat.new()
	ring.draw_center = false
	ring.border_color = outer
	ring.set_border_width_all(2)
	ring.set_corner_radius_all(3)
	ring.set_expand_margin_all(2)
	ring.shadow_color = inner
	ring.shadow_size = 1
	return ring


static func _variation(t: Theme, type: StringName, base: StringName) -> void:
	t.set_type_variation(type, base)


static func _load_font(path: String, errors: PackedStringArray) -> Font:
	if path == "" or not ResourceLoader.exists(path):
		errors.append("font missing: " + path)
		return null
	return load(path) as Font


static func _texture(rel: String, errors: PackedStringArray) -> Texture2D:
	var path: String = "res://assets/ui/" + rel
	if rel == "" or not ResourceLoader.exists(path):
		errors.append("texture missing: " + path)
		return null
	return load(path) as Texture2D


## The 1x file of a kit piece ("frames/frame_window.png" -> "frames/frame_window_1x.png").
static func _one_x(piece: Dictionary) -> String:
	var f: String = str(piece.get("file", ""))
	return f.get_basename() + "_1x." + f.get_extension() if f != "" else ""


## A nine-slice StyleBoxTexture of a kit piece at 1x, or a flat fallback in [param fallback] (reported in errors).
static func _nine(piece: Dictionary, fallback: Color, errors: PackedStringArray, pad: float) -> StyleBox:
	var tex: Texture2D = _texture(_one_x(piece), errors)
	if tex == null:
		var flat := StyleBoxFlat.new()
		flat.bg_color = fallback
		flat.set_content_margin_all(pad)
		return flat
	var m: Array = piece.get("margins", [0, 0, 0, 0])
	var sb := StyleBoxTexture.new()
	sb.texture = tex
	sb.texture_margin_left = float(m[0]) / 2.0
	sb.texture_margin_top = float(m[1]) / 2.0
	sb.texture_margin_right = float(m[2]) / 2.0
	sb.texture_margin_bottom = float(m[3]) / 2.0
	sb.content_margin_left = maxf(pad, float(m[0]) / 4.0)
	sb.content_margin_right = maxf(pad, float(m[2]) / 4.0)
	sb.content_margin_top = pad
	sb.content_margin_bottom = pad
	return sb


## The window frame: the lattice ends stay fixed, the body stretches; content sits inside the 8 px border, below
## the decorative title bar (titles go in the body, art bible 7.10). [param body] false draws the frame only.
static func _frame(piece: Dictionary, fallback: Color, errors: PackedStringArray, body: bool) -> StyleBox:
	var sb: StyleBox = _nine(piece, fallback, errors, 10.0)
	if sb is StyleBoxTexture:
		var m: Array = piece.get("margins", [0, 0, 0, 0])
		var border: float = float(piece.get("border_1x", 8.0))
		sb.content_margin_left = border + 10.0
		sb.content_margin_right = border + 10.0
		sb.content_margin_top = float(m[1]) / 2.0 + 6.0
		sb.content_margin_bottom = float(m[3]) / 2.0 + 8.0
		(sb as StyleBoxTexture).draw_center = body
	return sb


## A flat inset tiled with [param tex_path] (parchment or rosewood), or a flat colour when it is missing.
static func _tiled(tex_path: String, fallback: Color, pad: float, errors: PackedStringArray) -> StyleBox:
	var tex: Texture2D = null
	if tex_path != "":
		if ResourceLoader.exists(tex_path):
			tex = load(tex_path)
		else:
			errors.append("texture missing: " + tex_path)
	if tex == null:
		var flat := StyleBoxFlat.new()
		flat.bg_color = fallback
		flat.set_content_margin_all(pad)
		return flat
	var sb := StyleBoxTexture.new()
	sb.texture = tex
	sb.axis_stretch_horizontal = StyleBoxTexture.AXIS_STRETCH_MODE_TILE
	sb.axis_stretch_vertical = StyleBoxTexture.AXIS_STRETCH_MODE_TILE
	sb.set_content_margin_all(pad)
	return sb


## A copy of [param sb] tinted by [param tint] (and pushed down [param down] px), for the hover, pressed and
## disabled states of one plaque texture.
static func _modulated(sb: StyleBox, tint: Color, down: int) -> StyleBox:
	var copy: StyleBox = sb.duplicate()
	if copy is StyleBoxTexture:
		(copy as StyleBoxTexture).modulate_color = tint
	elif copy is StyleBoxFlat:
		(copy as StyleBoxFlat).bg_color = (copy as StyleBoxFlat).bg_color * tint
	copy.content_margin_top += down
	copy.content_margin_bottom -= down
	return copy
