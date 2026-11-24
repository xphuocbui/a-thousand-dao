class_name OutlinerPanel
extends VBoxContainer
## The outliner (design/ux/outliner.md; hud.md element 6) in Z2 under the window buttons: pinned people with where they
## are now, the home and the sect seat with the travel time, what is ongoing. Built from [method GameQuery.outliner];
## it never reads the session itself. Collapsible (the player setting outliner_open).

## Open that person's window.
signal person_requested(id: String)
## Open that place's details.
signal place_requested(id: String)
## Open the abode screen.
signal abode_requested
## Open the waiting event.
signal event_requested
## Unpin that person.
signal unpin_requested(id: String)
## The header was toggled.
signal toggled(open: bool)

var _head := Button.new()
var _rows := VBoxContainer.new()
var _open: bool = true


func _init() -> void:
	add_theme_constant_override("separation", 2)
	_head.alignment = HORIZONTAL_ALIGNMENT_LEFT
	_head.pressed.connect(_on_head)
	add_child(_head)
	_rows.add_theme_constant_override("separation", 1)
	add_child(_rows)
	set_open(true)


func _on_head() -> void:
	set_open(not _open)
	toggled.emit(_open)


## Expands or collapses the rows.
func set_open(on: bool) -> void:
	_open = on
	_rows.visible = on
	_head.text = tr("Outliner") + (" ▾" if on else " ▸")
	_head.accessibility_name = tr("Outliner, expanded") if on else tr("Outliner, collapsed")


## True while expanded.
func is_open() -> bool:
	return _open


## Rebuilds the rows from [param v] (a GameQuery.outliner copy).
func show_view(v: Dictionary) -> void:
	for c in _rows.get_children():
		_rows.remove_child(c)
		c.queue_free()
	var people: Array = Array(v.get("people", []))
	var any: bool = false
	if not people.is_empty():
		_heading(tr("People"))
		for p in people:
			_person_row(p)
		any = true
	var home: Dictionary = v.get("home", {})
	var seat: Dictionary = v.get("seat", {})
	if not home.is_empty() or not seat.is_empty():
		_heading(tr("Places"))
		if not home.is_empty():
			_place_row(tr("Home") + ": " + str(home.name), home, true)
		if not seat.is_empty():
			_place_row(tr("Seat") + ": " + str(seat.name), seat, false)
	var ev: Dictionary = v.get("event", {})
	if not ev.is_empty():
		_heading(tr("Ongoing"))
		var b := _small_button("! " + tr("Event waiting: %s") % str(ev.title))
		b.pressed.connect(func(): event_requested.emit())
		_rows.add_child(b)
		any = true
	if not any:
		# one line (weak-point review 2026-11-24 #7); how to pin is in its tooltip (quests are not in the game yet)
		var l := _small_label(tr("Nothing pinned yet"))
		l.name = "Empty"
		l.mouse_filter = Control.MOUSE_FILTER_STOP
		TooltipLayer.set_tip(l, {"title": tr("Outliner"), "summary": tr("Pin a person or a place (the Pin button on its window) to follow it here.")})
		_rows.add_child(l)


## The number of person rows (for tests).
func person_rows() -> int:
	return _rows.get_children().filter(func(c): return str(c.name).begins_with("Pin_")).size()


func _heading(text: String) -> void:
	var h := Label.new()
	h.text = text.to_upper()
	h.theme_type_variation = &"WoodRowLabel"
	_rows.add_child(h)


func _person_row(p: Dictionary) -> void:
	var row := HBoxContainer.new()
	row.name = "Pin_" + str(p.id)
	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(col)
	var name := _small_button(str(p.name) + ("" if bool(p.alive) else " † " + tr("died")))
	var pid: String = str(p.id)
	name.pressed.connect(func(): person_requested.emit(pid))
	col.add_child(name)
	var where: String = tr("died") if not bool(p.alive) else (tr("travelling") if bool(p.get("travelling", false)) else str(p.place))
	var sub := _small_label("  " + where + ("" if not bool(p.alive) else " · " + tr(str(p.band))))
	col.add_child(sub)
	name.accessibility_name = "%s, %s%s" % [str(p.name), where, ("" if not bool(p.alive) else ", " + tr(str(p.band)))]
	TooltipLayer.set_tip(name, {"title": str(p.name), "fact": str(p.get("realm", "")), "summary": "%s · %s %+d" % [where, tr(str(p.band)), int(p.attitude)]})
	var x := Button.new()
	x.name = "Unpin"
	x.text = "×"
	x.flat = true
	x.accessibility_name = tr("Unpin %s") % str(p.name)
	TooltipLayer.set_tip(x, tr("Unpin (Delete)"))
	x.pressed.connect(func(): unpin_requested.emit(pid))
	row.add_child(x)
	name.gui_input.connect(func(e: InputEvent):
		if e is InputEventKey and e.is_pressed() and (e as InputEventKey).physical_keycode == KEY_DELETE:
			unpin_requested.emit(pid))
	_rows.add_child(row)


func _place_row(text: String, r: Dictionary, is_home: bool) -> void:
	var b := _small_button(text)
	var id: String = str(r.id)
	if is_home:
		b.pressed.connect(func(): abode_requested.emit())
	else:
		b.pressed.connect(func(): place_requested.emit(id))
	# the place and how far it is on one row, the distance right-aligned (it wrapped under the name before)
	var row := HBoxContainer.new()
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.custom_minimum_size = Vector2(80, 0)
	row.add_child(b)
	var when: String = tr("here") if bool(r.here) else (tr("%s seasons") % ("%.1f" % float(r.seasons)) if float(r.seasons) >= 0.0 else tr("no route"))
	var wl := _small_label(when)
	wl.custom_minimum_size = Vector2(0, 0)
	wl.autowrap_mode = TextServer.AUTOWRAP_OFF
	wl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(wl)
	_rows.add_child(row)
	b.accessibility_name = "%s, %s" % [text, when]


func _small_button(text: String) -> Button:
	var b := Button.new()
	b.text = text
	b.flat = true
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	b.custom_minimum_size = Vector2(120, 0)
	return b


func _small_label(text: String) -> Label:
	var l := Label.new()
	l.text = text
	l.theme_type_variation = &"WoodLabel"
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size = Vector2(120, 0)
	return l
