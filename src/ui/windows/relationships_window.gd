class_name RelationshipsWindow
extends GameWindow
## The relationships page (design/ux/relationships-page.md) in the window host: the cap line and the next eviction,
## search, sort and group chips in a sticky header; the player's ties grouped Pinned, Feuds, Soft and debts, each row
## with a glyph, the kind in Vietnamese and English, band and direction in words; then the people met with no tie.
## Read-only: partners' names open their person window ([signal GameWindow.open_requested] "person").

## ui_windows.json (tie_kinds).
var cfg: Dictionary = {}

const GROUPS := [["pinned", "Pinned"], ["feud", "Feuds"], ["soft", "Soft ties and debts"], ["met", "Met, no tie"]]
const SORTS := ["kind", "strength", "name", "realm"]
const DIRECTIONS := {"toward_you": "toward you", "toward_them": "toward them", "you_owe": "you owe", "they_owe": "they owe"}

var _search := LineEdit.new()
var _count := Label.new()
var _sort: String = "kind"
var _groups_off: Dictionary = {}
var _rows: Array = []   # [Control, folded search text]


func kind() -> String:
	return "relationships"


func window_title(_v: Dictionary) -> String:
	return tr("Relationships")


func first_focus() -> Control:
	return _search


## Fills the search (the person window's "Relations" action opens the page filtered to that person); every group
## is shown again so the filter never hides them.
func preset_search(text: String) -> void:
	_groups_off.clear()
	_search.text = text
	_rebuild()


## The sort in use (for tests).
func sort_key() -> String:
	return _sort


func show_view(v: Dictionary, section: String, is_locked: bool) -> void:
	for c in [_search, _count]:
		if c.get_parent() != null:
			c.get_parent().remove_child(c)
	super.show_view(v, section, is_locked)


func _rebuild() -> void:
	var y: int = scroll.scroll_vertical
	show_view(view, "", locked)
	scroll.set_deferred("scroll_vertical", y)


## The label of tie kind [param k]: "glyph Vietnamese (English)".
func kind_label(k: String) -> String:
	var t: Array = Array(cfg.get("tie_kinds", {}).get(k, ["·", k, k]))
	return "%s %s (%s)" % [str(t[0]), str(t[1]), tr(str(t[2]))]


func _build() -> void:
	var v: Dictionary = view
	_rows.clear()
	if bool(v.get("off", false)):
		line(tr("Relationships are switched off in this build (npc_relationships.json is not loaded)."))
		return
	var cap_line := Label.new()
	cap_line.text = tr("Ties %d / %d") % [int(v.get("held", 0)), int(v.get("cap", 0))] + \
		((" (" + tr("+%d outside the cap") % int(v.outside_cap) + ")") if int(v.get("outside_cap", 0)) > 0 else "") + \
		"  ·  " + tr("Soft slots %d / %d") % [int(v.get("soft_used", 0)), int(v.get("soft_limit", 0))]
	cap_line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	TooltipLayer.set_tip(cap_line, {"title": tr("The cap"), "summary": tr("Pinned ties (kin, master and disciple, sworn siblings, Dao companions, companions, blood feuds) are never pushed out. Soft ties and debts share the rest, and the weakest goes first when a new one needs room.")})
	header.add_child(cap_line)
	var ev: Dictionary = v.get("next_evict", {})
	var evl := Label.new()
	evl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if not ev.is_empty():
		evl.text = tr("Next to go if a new tie forms: %s (%s, %s)") % [str(ev.partner), kind_label(str(ev.kind)), tr(str(ev.band))]
	else:
		evl.text = tr("Room for %d more soft ties or debts.") % int(v.get("room", 0))
	TooltipLayer.set_tip(evl, {"title": tr("Who goes first"), "summary": tr("The weakest soft tie or debt, then the oldest, then the lower id (rule 7).")})
	header.add_child(evl)
	_search.placeholder_text = tr("Search people…  (Ctrl+F)")
	_search.accessibility_name = tr("Search people")
	if not _search.text_changed.is_connected(_on_search):
		_search.text_changed.connect(_on_search)
	header.add_child(_search)
	_count.accessibility_live = AccessibilityServer.LIVE_POLITE
	header.add_child(_count)
	var tools := HFlowContainer.new()
	header.add_child(tools)
	var sort := OptionButton.new()
	sort.name = "Sort"
	for i in SORTS.size():
		sort.add_item(tr("Sort: %s") % tr(SORTS[i]), i)
		if SORTS[i] == _sort:
			sort.select(i)
	sort.accessibility_name = tr("Sort by")
	sort.item_selected.connect(_on_sort)
	tools.add_child(sort)
	for g in GROUPS:
		var chip := Button.new()
		chip.toggle_mode = true
		chip.text = tr(str(g[1]))
		chip.name = "Chip_" + str(g[0])
		chip.button_pressed = not _groups_off.has(str(g[0]))
		chip.modulate.a = 1.0 if chip.button_pressed else 0.6
		chip.toggled.connect(_on_chip.bind(str(g[0])))
		tools.add_child(chip)
	var ties: Array = Array(v.get("ties", []))
	if ties.is_empty():
		line(tr("You hold no ties yet."))
	for g in GROUPS:
		var gk: String = str(g[0])
		if _groups_off.has(gk):
			section(gk, tr(str(g[1])))   # sections never vanish (pattern library): a filtered group keeps its heading
			line("  " + tr("hidden by the filter"))
			continue
		var rows: Array = Array(v.get("met", [])) if gk == "met" else ties.filter(func(t): return str(t.group) == gk)
		rows.sort_custom(_sorter(gk))
		section(gk, "%s (%d)" % [tr(str(g[1])), rows.size()])
		if rows.is_empty():
			line("  " + tr("none"))
		for r in rows:
			if gk == "met":
				_met_row(r)
			else:
				_tie_row(r)
	bar_open(tr("Character"), "character")
	_on_search(_search.text)


func _sorter(group: String) -> Callable:
	match _sort:
		"strength":
			return func(a, b): return int(a.get("strength", a.get("attitude", 0))) > int(b.get("strength", b.get("attitude", 0)))
		"name":
			return func(a, b): return WorldDB.fold(str(a.get("partner", a.get("name", "")))) < WorldDB.fold(str(b.get("partner", b.get("name", ""))))
		"realm":
			return func(a, b): return str(a.get("realm", "")) < str(b.get("realm", ""))
	# kind (default): feuds toward the player first among feuds; then by the first kind's name
	return func(a, b):
		var ka: Array = Array(a.get("kinds", []))
		var kb: Array = Array(b.get("kinds", []))
		var ta: bool = ka.any(func(k): return str(k.direction) == "toward_you")
		var tb: bool = kb.any(func(k): return str(k.direction) == "toward_you")
		if group == "feud" and ta != tb:
			return ta
		var na: String = str(ka[0].kind) if not ka.is_empty() else ""
		var nb: String = str(kb[0].kind) if not kb.is_empty() else ""
		return na < nb if na != nb else str(a.get("partner", "")) < str(b.get("partner", ""))


func _tie_row(t: Dictionary) -> void:
	var box := VBoxContainer.new()
	box.name = "Tie_" + str(t.partner_id)
	body.add_child(box)
	var head := HBoxContainer.new()
	box.add_child(head)
	var parts: Array = []
	var spoken: Array = []
	var tip_lines: Array = []
	for k in Array(t.get("kinds", [])):
		var words: Array = [kind_label(str(k.kind))]
		if str(k.get("band", "")) != "":
			words.append(tr(str(k.band)) + " " + {"faint": "│", "firm": "││", "deep": "│││"}.get(str(k.band), ""))   # GDD: 1-3 strokes
		elif str(k.kind) == "feud":
			words.append(tr("does not fade"))
		if str(k.get("direction", "")) != "":
			words.append(tr(str(DIRECTIONS.get(str(k.direction), k.direction))))
		if bool(k.get("inherited", false)):
			words.append(tr("inherited") + ((": " + str(k.cause)) if str(k.get("cause", "")) != "" else ""))
		parts.append(" · ".join(words))
		spoken.append(", ".join(words))
		tip_lines.append(" · ".join(words) + ((" — " + tr("strength %d") % int(k.strength)) if int(k.get("strength", -1)) >= 0 else "") +
			((" — " + str(k.cause)) if str(k.get("cause", "")) != "" and not bool(k.get("inherited", false)) else ""))
	var kinds_l := Label.new()
	kinds_l.text = "  " + "; ".join(parts)
	kinds_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	kinds_l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(kinds_l)
	var name := LinkButton.new()
	name.text = str(t.partner) + ("" if bool(t.get("alive", true)) else " †")
	LinkStyle.apply(name, "person", "friend" if int(t.get("attitude", 0)) >= 30 else ("hostile" if int(t.get("attitude", 0)) <= -30 else "neutral"), "paper")
	var pid: String = str(t.partner_id)
	name.pressed.connect(func(): open_requested.emit("person", pid, ""))
	name.accessibility_name = tr("Open %s") % str(t.partner)
	head.add_child(name)
	var sub := Label.new()
	sub.text = "     %s%s · %s %+d%s" % [str(t.get("realm", "")), (" · " + tr("at %s") % str(t.place)) if str(t.get("place", "")) != "" else "",
		tr(str(t.get("band_word", ""))), int(t.get("attitude", 0)), ("  · " + tr("favour owed: %s") % str(t.favour)) if str(t.get("favour", "")) != "" else ""]
	if not bool(t.get("alive", true)):
		sub.text += "  · " + tr("died")
	var fav: Dictionary = t.get("favour_info", {})
	if not fav.is_empty():
		tip_lines.append(tr("Favour owed to %s: awaiting call-in (presented within %d seasons of joining; presented and accepted are not recorded yet).") % [str(t.favour), int(fav.call_seasons)])
		tip_lines.append(tr("Refusing it is a slight: friend −%d, or enmity +%d. Paying %s linh thạch clears it.") % [int(fav.refuse_delta), int(fav.refuse_delta), HudReadouts.stones_text(float(fav.cost))])
	sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(sub)
	box.focus_mode = Control.FOCUS_ALL
	box.accessibility_name = "%s, %s" % ["; ".join(spoken), str(t.partner)]
	TooltipLayer.set_tip(box, {"id": pid, "title": str(t.partner), "fact": str(t.get("realm", "")), "lines": tip_lines})
	_rows.append([box, WorldDB.fold(str(t.partner))])


func _met_row(m: Dictionary) -> void:
	var row := HBoxContainer.new()
	row.name = "Met_" + str(m.id)
	body.add_child(row)
	var name := LinkButton.new()
	name.text = str(m.name) + ("" if bool(m.get("alive", true)) else " †")
	LinkStyle.apply(name, "person", "neutral", "paper")
	var pid: String = str(m.id)
	name.pressed.connect(func(): open_requested.emit("person", pid, ""))
	row.add_child(name)
	var l := Label.new()
	l.text = "  %s%s · %s %+d" % [str(m.get("realm", "")), (" · " + str(m.place)) if str(m.get("place", "")) != "" else "", tr(str(m.get("band_word", ""))), int(m.get("attitude", 0))]
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(l)
	_rows.append([row, WorldDB.fold(str(m.name))])


func _on_sort(i: int) -> void:
	_sort = SORTS[i]
	_rebuild()


func _on_chip(on: bool, g: String) -> void:
	if on:
		_groups_off.erase(g)
	else:
		_groups_off[g] = true
	_rebuild()


func _on_search(text: String) -> void:
	var q: String = WorldDB.fold(text.strip_edges())
	var hit: int = 0
	for r in _rows:
		var m: bool = q == "" or str(r[1]).contains(q)
		(r[0] as Control).modulate.a = 1.0 if m else 0.45
		hit += 1 if m else 0
	_count.text = "" if q == "" else tr("%d of %d match") % [hit, _rows.size()]
	_count.visible = _count.text != ""


func _unhandled_input(event: InputEvent) -> void:
	if is_visible_in_tree() and event is InputEventKey and event.is_pressed() and (event as InputEventKey).ctrl_pressed \
			and (event as InputEventKey).physical_keycode == KEY_F:
		_search.grab_focus()
		get_viewport().set_input_as_handled()
		return
	super._unhandled_input(event)


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		for c in [_search, _count]:
			if is_instance_valid(c) and c.get_parent() == null:
				c.free()
