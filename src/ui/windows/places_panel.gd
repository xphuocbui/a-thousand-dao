class_name PlacesPanel
extends PanelContainer
## The Places panel (design/ux/hud.md, Places panel): every place the player knows as a searchable list, grouped by
## region, the keyboard and screen-reader path to the custom-drawn map. Selecting a row centres the map on it and shows
## its route as text; "Travel here" opens the focus comparison; Enter (or Details) opens the place's details. The
## current place's free actions are buttons at the top. Display only: every action is a request through a signal.

## The player selected [param place_id] (the screen centres the map on it).
signal place_selected(place_id: String)
## "Travel here" on [param place_id].
signal travel_requested(place_id: String)
## Details (or Enter) on [param place_id].
signal details_requested(place_id: String)
## A free action button at the current place: [param kind] is a map bubble kind ("market", "sect", "people").
signal action_requested(kind: String)
## The panel was closed.
signal closed

var _here := Label.new()
var _actions := HBoxContainer.new()
var _clues := Label.new()
var _search := LineEdit.new()
var _list := ItemList.new()
var _route := Label.new()
var _travel := Button.new()
var _details := Button.new()
var _rows: Array = []        # [{id, name, region, text, seasons, ...}]
var _shown: Array = []       # the ids in list order (search applied)
var _opener: Control = null
var _here_name: String = ""


func _init() -> void:
	visible = false
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	add_child(box)
	var head := HBoxContainer.new()
	box.add_child(head)
	var title := Label.new()
	title.text = tr("Places")
	title.add_theme_font_size_override("font_size", 20)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(title)
	var close := Button.new()
	close.text = "×"
	TooltipLayer.set_tip(close, tr("Close (Esc)"))
	close.pressed.connect(close_panel)
	head.add_child(close)
	_here.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(_here)
	box.add_child(_actions)
	_clues.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_clues.visible = false
	box.add_child(_clues)
	_search.placeholder_text = tr("Search places")
	_search.text_changed.connect(func(_t: String): _fill())
	box.add_child(_search)
	_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_list.custom_minimum_size = Vector2(0, 160)
	_list.item_selected.connect(_on_selected)
	# The whole row as a tooltip (the panel can be too narrow to show it): the row under the pointer, or the selected
	# row for Q.
	TooltipLayer.set_tip(_list, func(at: Vector2) -> Variant:
		var i: int = (_list.get_selected_items()[0] if not _list.get_selected_items().is_empty() else -1) if at == Vector2.INF else _list.get_item_at_position(at, true)
		if i < 0 or i >= _shown.size() or str(_shown[i]) == "":
			return ""   # a region header
		return {"id": _shown[i], "title": _row_text(_find(_shown[i]))})
	_list.item_activated.connect(func(i: int): details_requested.emit(_shown[i]))
	box.add_child(_list)
	_route.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(_route)
	var buttons := HBoxContainer.new()
	box.add_child(buttons)
	_travel.text = tr("Travel here")
	_travel.disabled = true
	_travel.pressed.connect(func(): if _selected() != "": travel_requested.emit(_selected()))
	buttons.add_child(_travel)
	_details.text = tr("Details (Enter)")
	_details.disabled = true
	_details.pressed.connect(func(): if _selected() != "": details_requested.emit(_selected()))
	buttons.add_child(_details)


## Opens the panel. [param here_name] is the current place; [param here_actions] the free action kinds there (with
## [param locked] true while a blocking event locks them); [param rows] the known places
## ([{id, name, region, kind, danger, match, holder, people, market, sect, actions, here}]); [param clue_lines] the
## active clues ([] when none). [param opener] gets focus back on close.
func open_panel(here_name: String, here_actions: Array, locked: bool, rows: Array, clue_lines: Array, opener: Control) -> void:
	_opener = opener
	_here_name = here_name
	_here.text = tr("You are here:") + " " + here_name
	for c in _actions.get_children():
		_actions.remove_child(c)
		c.queue_free()
	for k in here_actions:
		var b := Button.new()
		b.text = _kind_word(str(k)) + (" 🔒" if locked else "")
		TooltipLayer.set_tip(b, tr("locked while an event waits (look only)") if locked else "")
		b.pressed.connect(func(): action_requested.emit(str(k)))
		_actions.add_child(b)
	_clues.text = (tr("Clue search areas:") + "\n" + "\n".join(clue_lines)) if not clue_lines.is_empty() else ""
	_clues.visible = not clue_lines.is_empty()
	_rows = rows
	for r in _rows:
		r["seasons"] = float(r.get("seasons", -1.0))
	_fill()
	visible = true
	(_list if _list.item_count > 0 else _search).grab_focus.call_deferred()


## Fills in a row's route time once it is worked out ([param seasons] -1 when there is no route).
func set_seasons(place_id: String, seasons: float) -> void:
	for r in _rows:
		if r.id == place_id:
			r.seasons = seasons
			r["seasons_known"] = true
	var i: int = _shown.find(place_id)
	if i >= 0:
		_list.set_item_text(i, _row_text(_find(place_id)))
		if _list.is_selected(i):
			_on_selected(i)


## The name of the place the panel was opened at ("You are here").
func here_name() -> String:
	return _here_name


## The ids of rows still waiting for a route time, in list order.
func pending_ids() -> Array:
	return _rows.filter(func(r): return not bool(r.get("seasons_known", false))).map(func(r): return r.id)


## Selects the row of [param place_id] (keyboard, tests, the demo).
func select_place(place_id: String) -> void:
	var i: int = _shown.find(place_id)
	if i >= 0:
		_list.select(i)
		_list.ensure_current_is_visible()
		_on_selected(i)


## Closes the panel and returns focus to its opener.
func close_panel() -> void:
	if not visible:
		return
	visible = false
	if _opener != null and is_instance_valid(_opener):
		_opener.grab_focus()
	closed.emit()


func _fill() -> void:
	var q: String = _search.text.strip_edges().to_lower()
	_list.clear()
	_shown = []
	var rows: Array = _rows.duplicate()
	rows.sort_custom(func(a, b):
		if str(a.region) != str(b.region):
			return str(a.region) < str(b.region)
		return str(a.name) < str(b.name))
	var region: String = "~"   # no region yet (no region name starts with it)
	for r in rows:
		if q != "" and not str(r.name).to_lower().contains(q) and not str(r.region).to_lower().contains(q):
			continue
		if str(r.region) != region:
			region = str(r.region)
			var h: int = _list.add_item("— " + region + " —")
			_list.set_item_selectable(h, false)
			_list.set_item_disabled(h, true)
			_shown.append("")
		var i: int = _list.add_item(_row_text(r))
		_list.set_item_tooltip_enabled(i, false)
		_shown.append(str(r.id))
	_travel.disabled = true
	_details.disabled = true
	_route.text = ""


func _row_text(r: Dictionary) -> String:
	var parts: PackedStringArray = []
	parts.append(str(r.name) + (" (" + tr("you are here") + ")" if bool(r.get("here", false)) else ""))
	parts.append(str(r.kind).replace("_", " "))
	var s: float = float(r.get("seasons", -1.0))
	if bool(r.get("here", false)):
		pass
	elif not bool(r.get("seasons_known", false)):
		parts.append("…")
	elif s < 0.0:
		parts.append(tr("no route"))
	else:
		parts.append(tr("%.1f season(s)") % s)
	parts.append(tr("danger") + " %d" % int(r.get("danger", 0)))
	parts.append(tr("qi match") + " ×%.2f" % float(r.get("match", 0.0)))
	if str(r.get("holder", "")) != "":
		parts.append(tr("held by") + " " + str(r.holder))
	var people: int = int(r.get("people", -1))
	parts.append(tr("known people") + " " + (str(people) if people >= 0 else "—"))
	parts.append(tr("prices seen") + " —")
	var marks: PackedStringArray = []
	for k in r.get("actions", []):
		marks.append(_kind_word(str(k)))
	if not marks.is_empty():
		parts.append(", ".join(marks))
	return " · ".join(parts)


func _kind_word(kind: String) -> String:
	match kind:
		"market": return tr("Market")
		"sect": return tr("Sect")
		"work": return tr("Missions")
		"people": return tr("People here")
		"explore": return tr("Explore")
	return kind


func _find(place_id: String) -> Dictionary:
	for r in _rows:
		if r.id == place_id:
			return r
	return {}


func _selected() -> String:
	var sel: PackedInt32Array = _list.get_selected_items()
	if sel.is_empty():
		return ""
	return str(_shown[sel[0]])


func _on_selected(i: int) -> void:
	var id: String = str(_shown[i]) if i < _shown.size() else ""
	if id == "":
		return
	var r: Dictionary = _find(id)
	_travel.disabled = bool(r.get("here", false))
	_details.disabled = false
	var s: float = float(r.get("seasons", -1.0))
	var route: String
	if bool(r.get("here", false)):
		route = tr("You are here.")
	elif not bool(r.get("seasons_known", false)):
		route = tr("Working out the route…")
	elif s < 0.0:
		route = tr("No route you know of.")
	else:
		route = tr("Route:") + " %.1f %s, %s %d" % [s, tr("season(s) on the ground"), tr("danger"), int(r.get("danger", 0))]
		if int(r.get("fee", -1)) >= 0:
			route += ", " + tr("teleport fee") + " %d %s" % [int(r.fee), tr("linh thạch")]
	_route.text = route
	place_selected.emit(id)
