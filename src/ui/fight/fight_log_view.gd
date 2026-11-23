class_name FightLogView
extends ScrollContainer
## The fight log's list (design/ux/interaction-patterns.md "Log list"): one wrapping label per line (never truncated),
## one Tab stop for the whole list, Up / Down move the selected line, Enter or a click activates it. The selected line
## is kept by its id across rebuilds, so lines arriving during playback never move the selection. Display only: the
## lines come from [FightLog] through the fight screen.

## The player activated (clicked, or pressed Enter on) the line with [param id].
signal line_activated(id: String)

var _box := VBoxContainer.new()
var _labels: Array[Label] = []
var _ids: PackedStringArray = []
var _sel_id: String = ""
var _font_px: int = 14
var _sel_color := Color(1, 1, 1, 0.12)
var _ring_color := Color(0.95, 0.8, 0.45)


func _init() -> void:
	focus_mode = Control.FOCUS_ALL
	horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_box.add_theme_constant_override("separation", 2)
	_box.draw.connect(_draw_selection)
	add_child(_box)
	focus_entered.connect(_box.queue_redraw)
	focus_exited.connect(_box.queue_redraw)


## Sets the list's look from ui_hud.json fight_screen "log" (font_px, sel_color, ring_color).
func configure(cfg: Dictionary) -> void:
	_font_px = int(cfg.get("font_px", 14))
	_sel_color = Color.from_string(str(cfg.get("sel_color", "#FFFFFF1F")), _sel_color)
	_ring_color = Color.from_string(str(cfg.get("ring_color", "#F2CC73")), _ring_color)


## Shows [param lines] ([{id, text, color}]), top to bottom, reusing the labels it has.
func set_lines(lines: Array) -> void:
	while _labels.size() < lines.size():
		var l := Label.new()
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		l.mouse_filter = Control.MOUSE_FILTER_PASS   # clicks select; the wheel still reaches the scroll
		l.add_theme_font_size_override("font_size", _font_px)
		var idx: int = _labels.size()
		l.gui_input.connect(func(e: InputEvent): _on_label_input(idx, e))
		_box.add_child(l)
		_labels.append(l)
	_ids.resize(lines.size())
	for i in _labels.size():
		var l: Label = _labels[i]
		l.visible = i < lines.size()
		if not l.visible:
			continue
		var x: Dictionary = lines[i]
		l.text = str(x.text)
		l.add_theme_color_override("font_color", x.get("color", Color.WHITE))
		_ids[i] = str(x.id)
	if _sel_id != "" and not _ids.has(_sel_id):
		_sel_id = ""
	_box.queue_redraw()


## The id of the selected line ("" when none).
func selected_id() -> String:
	return _sel_id


## The ids of the shown lines, top to bottom (for the demo checks).
func line_ids() -> PackedStringArray:
	return _ids


## The text of the shown line [param i].
func line_text(i: int) -> String:
	return _labels[i].text if i < _ids.size() else ""


## Selects the line with [param id] and scrolls it into view.
func select_id(id: String) -> void:
	_sel_id = id if _ids.has(id) else ""
	var i: int = _ids.find(_sel_id)
	if i >= 0:
		ensure_control_visible.call_deferred(_labels[i])
	_box.queue_redraw()


func _gui_input(event: InputEvent) -> void:
	if _ids.is_empty():
		return
	var i: int = _ids.find(_sel_id)
	if event.is_action_pressed("ui_down", true):
		select_id(_ids[mini(i + 1, _ids.size() - 1)])
	elif event.is_action_pressed("ui_up", true):
		select_id(_ids[maxi(i - 1, 0)])
	elif event.is_action_pressed("ui_accept") and i >= 0:
		line_activated.emit(_sel_id)
	else:
		return
	accept_event()


func _on_label_input(i: int, event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT and i < _ids.size():
		grab_focus()
		select_id(_ids[i])
		line_activated.emit(_ids[i])
		_labels[i].accept_event()


func _draw_selection() -> void:
	var i: int = _ids.find(_sel_id)
	if i < 0:
		return
	var r: Rect2 = _labels[i].get_rect().grow(1.0)
	_box.draw_rect(r, _sel_color)
	if has_focus():
		_box.draw_rect(r, _ring_color, false, 2.0)
