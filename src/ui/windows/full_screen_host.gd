class_name FullScreenHost
extends PanelContainer
## A full screen (design/ux/hud.md Layout Zones: "Full screens ... replace the map and all zones except Z1"): a board
## over everything below the top bar, a "← Back to map" button (HUD element 26) and one [GameWindow] centred in a
## parchment column. Like [WindowHost] it never reads the session: [member reader] returns the view. Esc inside the
## screen cancels an armed confirm first, then goes back.

## The player asked to go back to the map.
signal back_requested
## The screen's window asked for a session command.
signal action_requested(kind: String, action: String, args: Array)
## The screen's window asked for another window (a link).
signal open_requested(kind: String, subject: String, section: String)

## Returns the view of the screen's window: func(kind, subject) -> Dictionary.
var reader: Callable = func(_k: String, _s: String) -> Dictionary: return {}
## Returns true while an event waits (look-only).
var is_locked: Callable = func() -> bool: return false

var _screens: Dictionary = {}
var _current: GameWindow = null
var _subject: String = ""
var _title := Label.new()
var _back := Button.new()
var _column := PanelContainer.new()


func _init() -> void:
	visible = false
	theme_type_variation = &"WoodPanel"   # opaque: the map and the other zones are hidden behind it (hud.md full screens)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	add_child(box)
	var top := HBoxContainer.new()
	box.add_child(top)
	_back.text = "← " + tr("Back to map")
	_back.accessibility_name = tr("Back to the map")
	TooltipLayer.set_tip(_back, tr("Back to the map (Esc)"))
	_back.pressed.connect(request_back)
	top.add_child(_back)
	_title.theme_type_variation = &"WoodHeading"
	_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	top.add_child(_title)
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(_back.get_minimum_size().x + 120, 0)
	top.add_child(spacer)
	var centre := HBoxContainer.new()   # the parchment column, centred and as tall as the screen
	centre.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(centre)
	for i in 2:
		var pad := Control.new()
		pad.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		pad.mouse_filter = Control.MOUSE_FILTER_IGNORE
		centre.add_child(pad)
	_column.theme_type_variation = &"WindowPanel"
	_column.custom_minimum_size = Vector2(900, 0)
	_column.size_flags_vertical = Control.SIZE_EXPAND_FILL
	centre.add_child(_column)
	centre.move_child(_column, 1)


## Adds the full screen [param w] under its kind.
func register(w: GameWindow) -> void:
	_screens[w.kind()] = w
	w.visible = false
	_column.add_child(w)
	var k: String = w.kind()
	w.action_requested.connect(func(a: String, args: Array): action_requested.emit(k, a, args))
	w.open_requested.connect(func(kind: String, sub: String, sec: String): open_requested.emit(kind, sub, sec))


## True when the host has a screen of [param kind].
func has_kind(kind: String) -> bool:
	return _screens.has(kind)


## Opens screen [param kind] about [param subject]. Returns false when it could not be read.
func open(kind: String, subject: String = "", section: String = "") -> bool:
	if not _screens.has(kind):
		return false
	var v: Dictionary = reader.call(kind, subject)
	if v.is_empty():
		return false
	_show(kind, v, section)
	_subject = subject
	visible = true
	var f: Control = _current.first_focus()
	_current.focus_later(f if f != null else _back)
	return true


## Shows screen [param kind] from a view given directly (the fixture shots: nothing is read).
func open_view(kind: String, v: Dictionary) -> void:
	_show(kind, v, "")
	visible = true


## Re-reads the shown screen (after a job).
func refresh() -> void:
	if not visible or _current == null:
		return
	var v: Dictionary = reader.call(_current.kind(), _subject)
	if not v.is_empty():
		var y: int = _current.scroll.scroll_vertical
		_show(_current.kind(), v, "")
		_current.scroll.set_deferred("scroll_vertical", y)


## The shown screen (null when closed).
func current() -> GameWindow:
	return _current if visible else null


## Shows [param lines] in the screen's reply strip.
func show_reply(lines: Array) -> void:
	if _current != null:
		_current.show_reply(lines)


## Esc: an armed confirm or open chooser first, then back. Returns true when it handled it.
func escape() -> bool:
	if not visible:
		return false
	if _current != null and _current.has_method("cancel_inline") and _current.call("cancel_inline"):
		return true
	request_back()
	return true


## Back to the map; a screen with uncommitted edits asks first (hud.md: keep, discard or cancel).
func request_back() -> void:
	if _current != null and _current.has_method("ask_leave") and _current.call("ask_leave"):
		if not _current.is_connected("leave_decided", _on_leave_decided):
			_current.connect("leave_decided", _on_leave_decided)
		return
	back_requested.emit()


func _on_leave_decided(go: bool) -> void:
	if go:
		back_requested.emit()


func close_screen() -> void:
	visible = false


func _show(kind: String, v: Dictionary, section: String) -> void:
	for k in _screens:
		(_screens[k] as Control).visible = k == kind
	_current = _screens[kind]
	# a wide screen (the Đạo Đồ canvas) takes the whole width; the others keep the centred parchment column
	_column.custom_minimum_size = Vector2(0 if _current.full_width() else 900, 0)
	# a wide screen draws its own ground (the Đạo Đồ's dark tree): no parchment column around it
	if _current.full_width():
		_column.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	else:
		_column.remove_theme_stylebox_override("panel")
	_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL if _current.full_width() else Control.SIZE_FILL
	for pad in _column.get_parent().get_children():
		if pad != _column:
			(pad as Control).visible = not _current.full_width()
	_current.show_view(v, section, bool(is_locked.call()))
	_title.text = _current.window_title(v)
	accessibility_name = _title.text
