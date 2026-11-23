class_name ResourceBox
extends Button
## One top-bar resource box (design/ux/hud.md, HUD Element Specifications: Resource box; art bible 7.13): the
## resource's icon, its tabular number and the change since the last End turn as a ▲ / ▼ mark with a sign, at a fixed
## width so a changing number never moves the bar. One focusable control: Q or hover opens its tooltip (set by the
## screen through TooltipLayer.set_tip), Enter or a click emits [signal pressed] (the screen opens the window).
##
## var box := ResourceBox.new("Linh thạch", "◆", 144)
## box.show_value("1,240", "▲ +30", "Linh thạch 1,240, up 30 this season")

## The resource's name ("Linh thạch"), the start of the accessible name.
var resource_name: String = ""
## The cultivation box's progress bar (null for other boxes).
var bar: ProgressBar = null

var _icon := Label.new()            # the glyph stand-in, shown until set_art gives the painted icon
var _socket := TextureRect.new()    # the brass socket (art bible 7.13), holding the medallion icon
var _art := TextureRect.new()
var _number := Label.new()
var _change := Label.new()
var _row := HBoxContainer.new()


## A box for [param title] with icon glyph [param icon] (a stand-in for the painted icon) at [param width] layout px;
## [param with_bar] adds a thin progress strip under the text (the cultivation box).
func _init(title: String = "", icon: String = "", width: float = 144.0, with_bar: bool = false) -> void:
	resource_name = title
	focus_mode = Control.FOCUS_ALL
	clip_contents = true
	custom_minimum_size = Vector2(width, 0)
	_row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_row.offset_left = 8
	_row.offset_right = -8
	_row.add_theme_constant_override("separation", 6)
	_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_row)
	_icon.text = icon
	# A slot on the bar's carved strip, not a plaque: no frame of its own; a faint brass wash on hover; the theme's focus
	# ring stays (hud.md Resource box).
	for st: StringName in [&"normal", &"pressed", &"disabled"]:
		add_theme_stylebox_override(st, StyleBoxEmpty.new())
	var wash := StyleBoxFlat.new()
	wash.bg_color = Color(0.79, 0.64, 0.35, 0.12)
	wash.set_corner_radius_all(3)
	add_theme_stylebox_override(&"hover", wash)
	_socket.visible = false
	_socket.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_socket.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_socket.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_socket.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_socket.add_child(_art)
	_row.add_child(_socket)
	_number.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_number.clip_text = true
	_change.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_icon.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_row.add_child(_icon)
	_number.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_number.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var text_col := VBoxContainer.new()   # the number, with the cultivation box's thin progress strip under it
	text_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_col.alignment = BoxContainer.ALIGNMENT_CENTER
	text_col.add_theme_constant_override("separation", 1)
	text_col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	text_col.add_child(_number)
	_row.add_child(text_col)
	if with_bar:
		bar = ProgressBar.new()
		bar.show_percentage = false
		bar.custom_minimum_size = Vector2(0, 4)
		bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bar.focus_mode = Control.FOCUS_NONE
		var trough := StyleBoxFlat.new()   # flat and thin: the theme's trough is taller than the strip
		trough.bg_color = Color(0.08, 0.05, 0.03, 0.9)
		trough.content_margin_top = 0
		trough.content_margin_bottom = 0
		var fill := StyleBoxFlat.new()
		fill.bg_color = Color(0.85, 0.68, 0.35)
		bar.add_theme_stylebox_override(&"background", trough)
		bar.add_theme_stylebox_override(&"fill", fill)
		text_col.add_child(bar)
	_change.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_change.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_row.add_child(_change)


## The painted medallion [param icon] (shown at [param icon_px]) in the brass [param socket]; the glyph stand-in hides.
## A null icon keeps the glyph (a missing file is reported by the screen, never silent).
func set_art(icon: Texture2D, socket: Texture2D, icon_px: float) -> void:
	if icon == null:
		return
	_icon.visible = false
	_socket.visible = true
	_socket.texture = socket
	_socket.custom_minimum_size = Vector2(icon_px, icon_px) * 1.25
	var inset: float = icon_px * 0.125
	_art.texture = icon
	_art.offset_left = inset
	_art.offset_top = inset
	_art.offset_right = -inset
	_art.offset_bottom = -inset


## The number in [param strong] (the bold face) and the change at [param small_px] (the smaller face).
func set_faces(strong: Font, small_px: int) -> void:
	if strong != null:
		_number.add_theme_font_override("font", strong)
	_change.add_theme_font_size_override("font_size", small_px)


## Shows [param number] and [param change] (HudReadouts.change_text, or the mark alone in the compact layout; "" for
## none), and sets the accessible name to [param spoken].
func show_value(number: String, change: String, spoken: String) -> void:
	_number.text = number
	_change.text = change
	_change.visible = change != ""
	accessibility_name = spoken


## The shown number (for checks and tests).
func number_text() -> String:
	return _number.text


## The shown change (for checks and tests).
func change_text() -> String:
	return _change.text


## Colours the number (the amber lifespan); [param on] false restores the theme colour.
func set_warning(on: bool, warn_color: Color) -> void:
	if on:
		_number.add_theme_color_override("font_color", warn_color)
	else:
		_number.remove_theme_color_override("font_color")


## Icon and change mark only, the number in the tooltip and the accessible name (Visual Budget drop order step 5).
func set_icon_only(on: bool) -> void:
	_number.visible = not on


## Sets the box's width (base or compact, Visual Budget drop order step 4).
func set_width(width: float) -> void:
	custom_minimum_size.x = width
