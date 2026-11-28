class_name WindowHost
extends PanelContainer
## HUD Z6's window host (design/ux/hud.md Layout Zones; interaction-patterns.md Side panel with history): one window
## at a time over the left of the map, a frame with back / forward / title / close, a browser-like history of the
## last [member history_max] windows (opening a new window after going back drops the forward entries), focus moved
## into the window on open and back to the opener on close.
##
## The host never reads the session: [member reader] (set by the map screen) returns a window's view, a GameQuery
## copy, or {} when it cannot be read now (a job runs). Windows' action requests come out as [signal action_requested].

## A window asked for a session command; the map screen runs it as a job and calls [method refresh] after.
signal action_requested(kind: String, action: String, args: Array)
## The host was closed.
signal closed
## A window kind the host does not have was asked for (e.g. a full screen the map screen owns).
signal unknown_requested(kind: String, subject: String, section: String)

## Returns the view of window [param kind] about [param subject]: func(kind, subject) -> Dictionary.
var reader: Callable = func(_k: String, _s: String) -> Dictionary: return {}
## Returns true while an event waits (windows go look-only).
var is_locked: Callable = func() -> bool: return false
## The history length (ui_windows.json history_max; hud.md: 20).
var history_max: int = 20
## The host's width as a share of the screen per window kind (ui_windows.json widths; the illustrated windows of the
## round-3 mock-ups are wider than the default third); kinds not named use [member default_share].
var widths: Dictionary = {}
## The width share for kinds not in [member widths] (ui_windows.json panel_share).
var default_share: float = 0.33

var _windows: Dictionary = {}   # kind -> GameWindow
var _history: Array = []        # [{kind, subject, section}]
var _at: int = -1
var _opener: Control = null
var _back := Button.new()
var _fwd := Button.new()
var _title := Label.new()
var _close := Button.new()
var _holder := MarginContainer.new()


func _init() -> void:
	visible = false
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	add_child(box)
	var frame := HBoxContainer.new()
	box.add_child(frame)
	_back.text = "<"
	_back.accessibility_name = tr("Back")
	TooltipLayer.set_tip(_back, tr("Back (Alt+←)"))
	_back.pressed.connect(back)
	frame.add_child(_back)
	_fwd.text = ">"
	_fwd.accessibility_name = tr("Forward")
	TooltipLayer.set_tip(_fwd, tr("Forward (Alt+→)"))
	_fwd.pressed.connect(forward)
	frame.add_child(_fwd)
	_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_title.theme_type_variation = &"HeadingLabel"
	_title.clip_text = true
	frame.add_child(_title)
	_close.text = "×"
	TooltipLayer.set_tip(_close, tr("Close (Esc)"))
	_close.pressed.connect(close_panel)
	frame.add_child(_close)
	_holder.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(_holder)


## Adds window [param w] under its kind.
func register(w: GameWindow) -> void:
	_windows[w.kind()] = w
	w.visible = false
	_holder.add_child(w)
	var k: String = w.kind()
	w.action_requested.connect(func(action: String, args: Array): action_requested.emit(k, action, args))
	w.open_requested.connect(func(kind: String, subject: String, sect: String): open(kind, subject, sect))
	for sig_name in ["tab_selected", "book_selected", "filter_selected"]:
		if w.has_signal(sig_name):
			w.connect(sig_name, func(_sub: String): sync_title())


## Refreshes the frame title from the currently shown window (e.g. after switching a sub-tab).
func sync_title() -> void:
	var w: GameWindow = current()
	if w == null:
		return
	_title.text = w.window_title(w.view)
	accessibility_name = _title.text


## True when the host has a window of [param kind].
func has_kind(kind: String) -> bool:
	return _windows.has(kind)


## The window of [param kind] (null when none).
func window(kind: String) -> GameWindow:
	return _windows.get(kind)


## Opens window [param kind] about [param subject], scrolled to [param section]; [param opener] gets focus back on
## close (kept from the first open while the host stays open). Returns false when it could not be read.
func open(kind: String, subject: String = "", section: String = "", opener: Control = null) -> bool:
	if not _windows.has(kind):
		unknown_requested.emit(kind, subject, section)
		return false
	if not _show(kind, subject, section):
		return false
	if not visible or opener != null:
		_opener = opener if opener != null else _opener
	# History: drop forward entries, then append (a repeat of the current entry only updates its section).
	var entry := {"kind": kind, "subject": subject, "section": section}
	if _at >= 0 and _at < _history.size() and _history[_at].kind == kind and _history[_at].subject == subject:
		_history[_at] = entry
	else:
		_history = _history.slice(0, _at + 1)
		_history.append(entry)
		while _history.size() > history_max:
			_history.pop_front()
		_at = _history.size() - 1
	_sync_arrows()
	visible = true
	var f: Control = _windows[kind].first_focus()
	if f != null:
		(_windows[kind] as GameWindow).focus_later(f)
	return true


## Re-reads and rebuilds the current window in place (after a job); keeps its scroll position.
func refresh() -> void:
	if not visible or _at < 0:
		return
	var e: Dictionary = _history[_at]
	var w: GameWindow = _windows[e.kind]
	var y: int = w.scroll.scroll_vertical
	if _show(str(e.kind), str(e.subject), ""):
		_restore_scroll.call_deferred(w, y)


## Steps back in the history.
func back() -> void:
	if _at > 0:
		_at -= 1
		_step()


## Steps forward in the history.
func forward() -> void:
	if _at < _history.size() - 1:
		_at += 1
		_step()


## Closes the host and returns focus to the opener.
func close_panel() -> void:
	if not visible:
		return
	visible = false
	if _opener != null and is_instance_valid(_opener):
		_opener.grab_focus()
	_opener = null
	closed.emit()


## The shown window's kind ("" when closed).
func current_kind() -> String:
	return str(_history[_at].kind) if visible and _at >= 0 else ""


## The shown window (null when closed).
func current() -> GameWindow:
	return _windows.get(current_kind())


## The history as [{kind, subject, section}] and the current index (for tests).
func history() -> Dictionary:
	return {"entries": _history.duplicate(true), "at": _at}


## True when [param c] is the host or inside it.
func owns(c: Control) -> bool:
	return c != null and (c == self or is_ancestor_of(c))


## Shows [param lines] in the current window's reply strip.
func show_reply(lines: Array) -> void:
	var w: GameWindow = current()
	if w != null:
		w.show_reply(lines)


func _unhandled_input(event: InputEvent) -> void:
	if not visible or not (event is InputEventKey or event is InputEventMouseButton) or not event.is_pressed():
		return
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if not get_global_rect().has_point(mb.global_position):
			return
		if mb.button_index == MOUSE_BUTTON_XBUTTON1:
			back()
		elif mb.button_index == MOUSE_BUTTON_XBUTTON2:
			forward()
		else:
			return
		get_viewport().set_input_as_handled()
	elif (event as InputEventKey).alt_pressed and owns(get_viewport().gui_get_focus_owner()):
		match (event as InputEventKey).physical_keycode:
			KEY_LEFT:
				back()
			KEY_RIGHT:
				forward()
			_:
				return
		get_viewport().set_input_as_handled()


func _step() -> void:
	var e: Dictionary = _history[_at]
	if not _show(str(e.kind), str(e.subject), str(e.section)):
		var w: GameWindow = _windows[e.kind]
		w.show_view({"gone": true}, "", true)
	_sync_arrows()
	var f: Control = current().first_focus() if current() != null else null
	if f != null:
		current().focus_later(f)


func _show(kind: String, subject: String, section: String) -> bool:
	var v: Dictionary = reader.call(kind, subject)
	if v.is_empty():
		return false
	for k in _windows:
		(_windows[k] as Control).visible = k == kind
	var w: GameWindow = _windows[kind]
	anchor_right = float(widths.get(kind, default_share))
	w.show_view(v, section, bool(is_locked.call()))
	_title.text = w.window_title(v)
	accessibility_name = _title.text
	return true


func _sync_arrows() -> void:
	_back.disabled = _at <= 0
	_fwd.disabled = _at >= _history.size() - 1


func _restore_scroll(w: GameWindow, y: int) -> void:
	w.scroll.scroll_vertical = y
