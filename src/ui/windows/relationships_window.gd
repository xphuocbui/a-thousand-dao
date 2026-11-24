class_name RelationshipsWindow
extends GameWindow
## The relationships page (design/ux/relationships-page.md) in the window host: the cap line and the next eviction,
## search, sort and group chips in a sticky header; the player's ties grouped Pinned, Feuds, Soft and debts, then the
## people met with no tie. Illustrated (user 2026-11-24, "the character list, show the character and some info"): each
## person is a card with their painted portrait medallion (PortraitPicker), name, realm, sect and place, attitude, and
## a badge per tie kind (glyph, Vietnamese and English, band strokes and direction in words), two cards a row.
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
	var ground: VBoxContainer = Illustrated.ground(body)
	for g in GROUPS:
		var gk: String = str(g[0])
		if _groups_off.has(gk):
			var off: VBoxContainer = section_in(ground, gk, tr(str(g[1])))   # sections never vanish (pattern library)
			line("  " + tr("hidden by the filter"), off)
			continue
		var rows: Array = Array(v.get("met", [])) if gk == "met" else ties.filter(func(t): return str(t.group) == gk)
		rows.sort_custom(_sorter(gk))
		var box: VBoxContainer = section_in(ground, gk, "%s (%d)" % [tr(str(g[1])), rows.size()])
		if rows.is_empty():
			line("  " + tr("none"), box)
			continue
		var grid: GridContainer = Illustrated.grid(box, 1 if compact else 2, 8)
		for r in rows:
			if gk == "met":
				_met_row(r, grid)
			else:
				_tie_row(r, grid)
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


# Tie kinds by family, for the badge colour: pinned brass, feud cinnabar, enmity dark red, soft ties teal, debt amber.
const BADGE := {"feud": "#84191B", "enmity": "#6E2A22", "debt": "#8A6420", "master": "#6D5426", "disciple": "#6D5426",
	"kin": "#6D5426", "ket_nghia": "#6D5426", "dao_lu": "#6D5426", "companion": "#6D5426"}
const BADGE_SOFT := "#2F5D58"


# A person card: the portrait medallion, the name link, who they are, and [param badges] under it.
func _card(parent: Control, node_name: String, id: String, name_text: String, d: Dictionary, badges: Array, att: int, medal: float) -> PanelContainer:
	var card := PanelContainer.new()
	card.name = node_name
	card.add_theme_stylebox_override("panel", Illustrated.box(Illustrated.PAPER_TILE, Illustrated.BRASS_DIM, 1, 8.0, 2))
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.focus_mode = Control.FOCUS_ALL
	parent.add_child(card)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	card.add_child(row)
	row.add_child(Illustrated.medallion(PortraitPicker.texture_for(d.get("portrait", {})), medal, not bool(d.get("alive", true))))
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 1)
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(col)
	var name := LinkButton.new()
	name.text = name_text + ("" if bool(d.get("alive", true)) else " †")
	LinkStyle.apply(name, "person", "friend" if att >= 30 else ("hostile" if att <= -30 else "neutral"), "paper")
	name.pressed.connect(func(): open_requested.emit("person", id, ""))
	name.accessibility_name = tr("Open %s") % name_text
	col.add_child(name)
	var who := Label.new()
	who.text = " · ".join([str(d.get("realm", "")), str(d.get("sect", "")) if str(d.get("sect", "")) != "" else tr("loose cultivator"),
		(tr("at %s") % str(d.place)) if str(d.get("place", "")) != "" else ""].filter(func(x): return str(x) != ""))
	who.theme_type_variation = &"RowLabel"
	who.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(who)
	var mood := Label.new()
	mood.text = "%s %+d" % [tr(str(d.get("band_word", ""))), att] + ("" if bool(d.get("alive", true)) else "  · " + tr("died"))
	col.add_child(mood)
	if not badges.is_empty():
		var flow := HFlowContainer.new()
		flow.add_theme_constant_override("h_separation", 4)
		flow.add_theme_constant_override("v_separation", 4)
		col.add_child(flow)
		for b in badges:
			var pill := PanelContainer.new()
			pill.add_theme_stylebox_override("panel", Illustrated.box(Color(str(b[1])), Illustrated.BRASS_DIM, 1, 4.0, 3))
			var bl := Label.new()
			bl.text = str(b[0])
			bl.add_theme_color_override("font_color", Illustrated.BONE)
			bl.add_theme_font_size_override("font_size", 13)
			pill.add_child(bl)
			flow.add_child(pill)
	return card


func _tie_row(t: Dictionary, parent: Control) -> void:
	var badges: Array = []
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
		badges.append([" · ".join(words), BADGE.get(str(k.kind), BADGE_SOFT)])
		spoken.append(", ".join(words))
		tip_lines.append(" · ".join(words) + ((" — " + tr("strength %d") % int(k.strength)) if int(k.get("strength", -1)) >= 0 else "") +
			((" — " + str(k.cause)) if str(k.get("cause", "")) != "" and not bool(k.get("inherited", false)) else ""))
	if str(t.get("favour", "")) != "":
		badges.append([tr("favour owed: %s") % str(t.favour), BADGE.debt])
	var pid: String = str(t.partner_id)
	var card: PanelContainer = _card(parent, "Tie_" + pid, pid, str(t.partner), t, badges, int(t.get("attitude", 0)), 64.0)
	var fav: Dictionary = t.get("favour_info", {})
	if not fav.is_empty():
		tip_lines.append(tr("Favour owed to %s: awaiting call-in (presented within %d seasons of joining; presented and accepted are not recorded yet).") % [str(t.favour), int(fav.call_seasons)])
		tip_lines.append(tr("Refusing it is a slight: friend −%d, or enmity +%d. Paying %s linh thạch clears it.") % [int(fav.refuse_delta), int(fav.refuse_delta), HudReadouts.stones_text(float(fav.cost))])
	card.accessibility_name = "%s, %s" % ["; ".join(spoken), str(t.partner)]
	TooltipLayer.set_tip(card, {"id": pid, "title": str(t.partner), "fact": str(t.get("realm", "")), "lines": tip_lines})
	_rows.append([card, WorldDB.fold(str(t.partner))])


func _met_row(m: Dictionary, parent: Control) -> void:
	var pid: String = str(m.id)
	var card: PanelContainer = _card(parent, "Met_" + pid, pid, str(m.name), m, [], int(m.get("attitude", 0)), 52.0)
	card.accessibility_name = "%s, %s" % [str(m.name), str(m.get("realm", ""))]
	_rows.append([card, WorldDB.fold(str(m.name))])


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
