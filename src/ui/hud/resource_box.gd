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

var _icon := Label.new()
var _number := Label.new()
var _change := Label.new()
var _row := HBoxContainer.new()


## A box for [param title] with icon glyph [param icon] (a stand-in for the painted icon) at [param width] layout px;
## [param with_bar] adds a thin progress strip along the bottom edge (the cultivation box).
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
	_number.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_number.clip_text = true
	_change.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	for l: Label in [_icon, _number]:
		l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		l.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_row.add_child(l)
	if with_bar:   # a thin strip along the box's bottom edge, so the realm name keeps the row's width
		bar = ProgressBar.new()
		bar.show_percentage = false
		bar.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
		bar.offset_left = 6
		bar.offset_right = -6
		bar.offset_top = -7
		bar.offset_bottom = -3
		bar.custom_minimum_size = Vector2(0, 4)
		bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bar.focus_mode = Control.FOCUS_NONE
		add_child(bar)
	_change.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_change.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_row.add_child(_change)


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
