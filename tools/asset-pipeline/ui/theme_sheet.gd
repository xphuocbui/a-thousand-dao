extends SceneTree
## Theme sheet (art bible 7.10-7.12, 8.7): renders the UI kit through real Godot controls once, saves a screenshot and
## quits, so frame thickness, plaque states, 1x textures at UI scale and the fonts can be judged before the theme is
## built. Throwaway tool: no game state, no input, no cursor moves.
##
## usage: godot --path . --windowed --resolution 1280x720 -s res://tools/asset-pipeline/ui/theme_sheet.gd -- --out <png>
##        [--scale 1.5]   (with --resolution 1920x1080 for the 150 % check)

const UI := "res://assets/ui/"
const INK := Color("#2B2118")
const BONE := Color("#E8D9B5")
const BRASS := Color("#C9A25A")
const CINNABAR := Color("#84191B")
const VI := "Tiêu Lăng · Luyện Khí Sơ kỳ · Đơn linh căn Thổ 31 · Thiên Nguyên lịch năm 1201, Thu · Tụ Linh trận"

var _lit: FontFile
var _cor: FontFile


func _init() -> void:
	var args := OS.get_cmdline_user_args()
	var out: String = _arg(args, "--out", "user://theme_sheet.png")
	var scale: float = float(_arg(args, "--scale", "1.0"))
	await process_frame   # the window's scale settings only take once the tree is running
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
	root.content_scale_size = Vector2i(int(root.size.x / scale), int(root.size.y / scale))
	_lit = load("res://assets/fonts/literata/literata_vf.ttf")
	_cor = load("res://assets/fonts/cormorant_garamond/cormorant_garamond_vf.ttf")
	var bg := TextureRect.new()
	bg.texture = load(UI + "textures/tex_rosewood.png")
	bg.stretch_mode = TextureRect.STRETCH_TILE
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(bg)
	var col := VBoxContainer.new()
	col.position = Vector2(16, 12)
	col.add_theme_constant_override("separation", 14)
	root.add_child(col)
	# row 1: the window frame at three border widths
	var r1 := HBoxContainer.new()
	r1.add_theme_constant_override("separation", 16)
	col.add_child(r1)
	r1.add_child(_window("", "8 px (art bible 7.10; 6 and 10 px were compared on 2026-11-22)"))
	# row 2: plaque states, the commit plaque, the tooltip card, a bar trough
	var r2 := HBoxContainer.new()
	r2.add_theme_constant_override("separation", 12)
	col.add_child(r2)
	var states := VBoxContainer.new()
	states.add_theme_constant_override("separation", 6)
	r2.add_child(states)
	var row_a := HBoxContainer.new()
	row_a.add_theme_constant_override("separation", 8)
	states.add_child(row_a)
	for st in [["Bình thường", Color(1, 1, 1), 0, false], ["Hover", Color(1.18, 1.14, 1.05), 0, false],
			["Pressed", Color(0.78, 0.74, 0.7), 1, false], ["Disabled", Color(0.55, 0.52, 0.5), 0, true]]:
		row_a.add_child(_plaque("plaques/plaque_wood_1x.png", str(st[0]), st[1], int(st[2]), bool(st[3]), false))
	var row_b := HBoxContainer.new()
	row_b.add_theme_constant_override("separation", 8)
	states.add_child(row_b)
	row_b.add_child(_plaque("plaques/plaque_wood_1x.png", "Focus (Q)", Color(1, 1, 1), 0, false, true))
	row_b.add_child(_plaque("plaques/plaque_cinnabar_1x.png", "Kết thúc lượt: Tu luyện", Color(1, 1, 1), 0, false, false))
	var bars := VBoxContainer.new()
	bars.add_theme_constant_override("separation", 4)
	states.add_child(bars)
	for b in [["Khí huyết 341 / 358", Color("#C04040"), 0.92], ["Linh lực 75 / 93", Color("#4A8CE6"), 0.8]]:
		bars.add_child(_bar(str(b[0]), b[1], float(b[2])))
	r2.add_child(_tooltip())
	# row 3: type samples
	var r3 := VBoxContainer.new()
	r3.add_theme_constant_override("separation", 2)
	col.add_child(r3)
	for sz in [14, 16, 18]:
		r3.add_child(_label("Literata %d: %s" % [sz, VI], _font(_lit, 400, false), sz, BONE))
	r3.add_child(_label("Literata 16 tnum: 1 111 · 8 888 · 120 / 120 · 0,25 %", _font(_lit, 400, true), 16, BONE))
	r3.add_child(_label("Cormorant Garamond 22 / 28 SemiBold: Tiêu Lăng, Thiên Kiếp · digits 0123456789 · tnum:",
		_font(_cor, 600, false), 22, BRASS))
	r3.add_child(_label("Vô Danh (Bạn) · 1 111 / 8 888 · 0123456789", _font(_cor, 600, true), 28, BRASS))
	for i in 8:
		await process_frame
	var img: Image = root.get_texture().get_image()
	img.save_png(out)
	print("THEME SHEET ", out, " window ", root.size, " factor ", scale)
	quit()


func _window(suffix: String, caption: String) -> Control:
	var kit: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(UI + ("kit%s.json" % suffix if suffix != "" else "kit.json")))
	var p: Dictionary = kit.get("frame_window", kit.get("pieces", {}).get("frame_window", {}))
	var sb := StyleBoxTexture.new()
	sb.texture = load(UI + "frames/frame_window%s_1x.png" % suffix)
	var m: Array = p.margins
	sb.texture_margin_left = float(m[0]) / 2.0
	sb.texture_margin_top = float(m[1]) / 2.0
	sb.texture_margin_right = float(m[2]) / 2.0
	sb.texture_margin_bottom = float(m[3]) / 2.0
	sb.content_margin_left = float(p.border_1x) + 10.0
	sb.content_margin_right = float(p.border_1x) + 10.0
	sb.content_margin_top = float(m[1]) / 2.0 + 8.0
	sb.content_margin_bottom = float(m[3]) / 2.0 + 8.0
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", sb)
	panel.custom_minimum_size = Vector2(400, 200)
	var v := VBoxContainer.new()
	panel.add_child(v)
	v.add_child(_label("Người · Tiêu Lăng", _font(_cor, 600, false), 22, INK))
	v.add_child(_label("Frame %s" % caption, _font(_lit, 600, false), 14, Color("#5E4316")))
	v.add_child(_label("Luyện Khí Sơ kỳ · tán tu · chiến lực 147", _font(_lit, 400, false), 16, INK))
	v.add_child(_label("Linh căn: Đơn linh căn Thổ 31", _font(_lit, 400, false), 16, INK))
	v.add_child(_label("Bạn: Vô Danh · Địch: Tiêu Lăng", _font(_lit, 400, false), 16, Color("#284177")))
	v.add_child(_label("Liên kết: linh thạch (cinnabar, underlined)", _font(_lit, 400, false), 14, CINNABAR))
	return panel


func _plaque(file: String, text: String, mod: Color, offset: int, disabled: bool, focus: bool) -> Control:
	var sb := StyleBoxTexture.new()
	sb.texture = load(UI + file)
	sb.set_texture_margin_all(6.0)
	sb.modulate_color = mod
	sb.content_margin_left = 14.0
	sb.content_margin_right = 14.0
	sb.content_margin_top = 6.0 + offset
	sb.content_margin_bottom = 6.0 - offset
	var b := Button.new()
	b.text = text
	b.disabled = disabled
	b.focus_mode = Control.FOCUS_NONE
	for s in ["normal", "hover", "pressed", "disabled", "focus"]:
		b.add_theme_stylebox_override(s, sb if s != "focus" else StyleBoxEmpty.new())
	b.add_theme_font_override("font", _font(_lit, 500, false))
	b.add_theme_font_size_override("font_size", 16)
	for c in ["font_color", "font_hover_color", "font_pressed_color"]:
		b.add_theme_color_override(c, BONE)
	b.add_theme_color_override("font_disabled_color", Color(BONE, 0.45))
	if not focus:
		return b
	var wrap := PanelContainer.new()   # the double focus ring (7.12): bone outside, ink inside
	var ring := StyleBoxFlat.new()
	ring.draw_center = false
	ring.border_color = BONE
	ring.set_border_width_all(2)
	ring.set_corner_radius_all(3)
	ring.shadow_color = INK
	ring.shadow_size = 1
	ring.set_content_margin_all(3)
	wrap.add_theme_stylebox_override("panel", ring)
	wrap.add_child(b)
	return wrap


func _bar(text: String, fill: Color, share: float) -> Control:
	var trough := StyleBoxTexture.new()
	trough.texture = load(UI + "bars/bar_trough_1x.png")
	trough.set_texture_margin_all(4.0)
	var bar := ProgressBar.new()
	bar.custom_minimum_size = Vector2(360, 22)
	bar.show_percentage = false
	bar.value = share * 100.0
	var f := StyleBoxFlat.new()
	f.bg_color = fill
	f.set_content_margin_all(0)
	f.expand_margin_top = -3
	f.expand_margin_bottom = -3
	f.expand_margin_left = -3
	bar.add_theme_stylebox_override("background", trough)
	bar.add_theme_stylebox_override("fill", f)
	var l := _label(text, _font(_lit, 500, true), 14, BONE)
	l.set_anchors_preset(Control.PRESET_FULL_RECT)
	l.offset_left = 8
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
	l.add_theme_constant_override("outline_size", 3)
	bar.add_child(l)
	return bar


func _tooltip() -> Control:
	var kit: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(UI + "kit.json")).pieces
	var p: Dictionary = kit.card_tooltip
	var sb := StyleBoxTexture.new()
	sb.texture = load(UI + "frames/card_tooltip_1x.png")
	sb.set_texture_margin_all(float(p.margins[0]) / 2.0)
	sb.set_content_margin_all(12.0)
	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel", sb)
	card.custom_minimum_size = Vector2(380, 0)
	var rt := RichTextLabel.new()
	rt.bbcode_enabled = true
	rt.fit_content = true
	rt.custom_minimum_size = Vector2(350, 0)
	rt.add_theme_font_override("normal_font", _font(_lit, 400, false))
	rt.add_theme_font_override("bold_font", _font(_lit, 600, false))
	rt.add_theme_font_size_override("normal_font_size", 14)
	rt.add_theme_font_size_override("bold_font_size", 14)
	rt.add_theme_color_override("default_color", INK)
	rt.text = "[b]Linh thạch[/b]  ·  đang giữ 30\nTiền duy nhất của giới tu tiên. Chợ, dịch vụ tông môn và trận truyền tống định giá bằng [color=#84191B][u]linh thạch[/u][/color]; chúng cũng làm nhiên liệu cho [color=#84191B][u]trận pháp[/u][/color]."
	card.add_child(rt)
	return card


func _font(base: FontFile, weight: int, tnum: bool) -> FontVariation:
	var ts := TextServerManager.get_primary_interface()
	var fv := FontVariation.new()
	fv.base_font = base
	fv.variation_opentype = {ts.name_to_tag("wght"): weight}
	if tnum:
		fv.opentype_features = {ts.name_to_tag("tnum"): 1}
	return fv


func _label(text: String, font: Font, size: int, colour: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_override("font", font)
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", colour)
	return l


static func _arg(args: PackedStringArray, key: String, default: String) -> String:
	for a in args:
		if a.begins_with(key + "="):
			return a.substr(key.length() + 1)
	var i: int = args.find(key)
	return args[i + 1] if i >= 0 and i + 1 < args.size() else default
