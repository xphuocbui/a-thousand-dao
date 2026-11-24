class_name RankingsWindow
extends GameWindow
## The rankings (design/ux/rankings.md) in the window host: the player's standing and the last season's batch in a
## sticky header with realm tabs (and the Vấn Đỉnh Bảng), search and Jump to me; the ranking's top rows, a gap, and
## the rows around the player. Built from [method GameQuery.rankings] (subject: "" the player's realm, "0".."4", "top");
## a tab opens the same window about another realm (one history step). Read-only.

## ui_windows.json (rankings.top_rows, rankings.around; realm names come with the view).
var cfg: Dictionary = {}
## The realm names for the tabs (gd realms, set by the map screen).
var realm_names: Array = []

var _search := LineEdit.new()
var _count := Label.new()
var _expanded_gaps: Dictionary = {}   # "a-b" -> true
var _rows_by_rank: Dictionary = {}    # rank -> its row control
var _me_row: Control = null


func kind() -> String:
	return "rankings"


func window_title(v: Dictionary) -> String:
	return tr("Rankings") + ((": " + str(v.get("title", ""))) if str(v.get("title", "")) != "" else "")


func first_focus() -> Control:
	return _me_row if _me_row != null else _search


## The row control of rank [param r] (null when it is in a closed gap or filtered out), for tests.
func row_of_rank(r: int) -> Control:
	return _rows_by_rank.get(r)


func show_view(v: Dictionary, section: String, is_locked: bool) -> void:
	for c in [_search, _count]:
		if c.get_parent() != null:
			c.get_parent().remove_child(c)
	if str(v.get("which", "")) != str(view.get("which", "-")):
		_expanded_gaps.clear()
	super.show_view(v, section, is_locked)
	if _me_row != null:
		_scroll_to.call_deferred(_me_row)


func _scroll_to(c: Control) -> void:
	if is_instance_valid(c) and scroll.is_ancestor_of(c) and not c.is_queued_for_deletion():
		scroll.ensure_control_visible(c)


func _rebuild() -> void:
	var y: int = scroll.scroll_vertical
	show_view(view, "", locked)
	scroll.set_deferred("scroll_vertical", y)


func _build() -> void:
	var v: Dictionary = view
	_rows_by_rank.clear()
	_me_row = null
	if not bool(v.get("on", false)):
		line(tr("Power Rankings is off in this run."))
		bar_open(tr("Character"), "character")
		return
	var you := Label.new()
	var rank: int = int(v.get("player_rank", 0))
	var my: Dictionary = {}
	for r in Array(v.get("rows", [])):
		if bool(r.you):
			my = r
	var prov_n: int = Array(v.get("rows", [])).filter(func(r): return str(r.state) == "provisional").size()
	if rank > 0:
		# rule 9 (user decision 2026-11-24): one order by rating, provisional people mixed in by their estimate (marked ~)
		var mine_prov: bool = str(my.state) == "provisional"
		you.text = tr("You: %s of %d %s · power %s%s") % [_ordinal(rank), int(v.get("total", 0)), str(v.title), "~" if mine_prov else "", HudReadouts.stones_text(float(my.power))] + \
			(" (" + tr("stale") + ")" if str(my.state) == "stale" else "") + \
			(("  ·  " + tr("~ %s still provisional (estimated until they fight rated matches)") % HudReadouts.stones_text(float(prov_n))) if prov_n > 0 else "")
	else:
		you.text = tr("You are not in this list (you are in %s).") % _realm_name(int(v.get("player_realm", 0)))
	you.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	TooltipLayer.set_tip(you, {"title": tr("Your power number"), "summary": tr("Your rating as a power number (each realm is ×10). Fights move it; the ranking shows them one season late. ~ while provisional; stale when your build changed since your last panel.")})
	header.add_child(you)
	var lb: Dictionary = v.get("last_batch", {})
	if not lb.is_empty():
		var bl := Label.new()
		bl.text = tr("Shown one season late. Last season: %d of %d panels, %d fights.") % [int(lb.panels), int(lb.queued), int(lb.panel_fights) + int(lb.pair_fights)]
		bl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		header.add_child(bl)
	var tabs := HFlowContainer.new()
	tabs.name = "Tabs"
	header.add_child(tabs)
	if compact:
		# the compact layout folds the realm tabs into one dropdown, leaving the body room for rows
		var pick := OptionButton.new()
		pick.name = "RealmPick"
		pick.accessibility_name = tr("Which ranking")
		for i in realm_names.size() + 1:
			var key0: String = str(i) if i < realm_names.size() else "top"
			pick.add_item(_realm_name(i) if i < realm_names.size() else tr("Vấn Đỉnh Bảng"), i)
			pick.set_item_metadata(i, key0)
			if str(v.get("which", "")) == key0:
				pick.select(i)
		pick.item_selected.connect(func(i: int): open_requested.emit("rankings", str(pick.get_item_metadata(i)), ""))
		tabs.add_child(pick)
	for i in (0 if compact else realm_names.size() + 1):
		var key: String = str(i) if i < realm_names.size() else "top"
		var t := Button.new()
		t.name = "Tab_" + key
		t.toggle_mode = true
		t.text = _realm_name(i) if i < realm_names.size() else tr("Vấn Đỉnh Bảng")
		t.button_pressed = str(v.get("which", "")) == key
		t.accessibility_name = t.text + (", " + tr("selected") if t.button_pressed else "")
		t.pressed.connect(func(): open_requested.emit("rankings", key, ""))
		tabs.add_child(t)
	var tools := HBoxContainer.new()
	header.add_child(tools)
	_search.placeholder_text = tr("Search names…  (Ctrl+F)")
	_search.accessibility_name = tr("Search the ranking")
	_search.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if not _search.text_changed.is_connected(_on_search):
		_search.text_changed.connect(_on_search)
	tools.add_child(_search)
	var jump := Button.new()
	jump.name = "JumpToMe"
	jump.text = tr("Jump to me")
	jump.disabled = rank <= 0
	jump.pressed.connect(_jump_me)
	tools.add_child(jump)
	_count.accessibility_live = AccessibilityServer.LIVE_POLITE
	header.add_child(_count)
	_column_head()
	var rows: Array = Array(v.get("rows", []))
	var q: String = WorldDB.fold(_search.text.strip_edges())
	if q != "":
		var hits: Array = rows.filter(func(r): return WorldDB.fold(str(r.name)).contains(q))
		_count.text = tr("%d matches") % hits.size()
		for r in hits:
			_row(r)
	else:
		_count.text = ""
		var top_n: int = int(cfg.get("rankings", {}).get("top_rows", 50))
		var around: int = int(cfg.get("rankings", {}).get("around", 5))
		var shown: Array = []
		for r in rows:
			var rk: int = int(r.rank)
			if rk <= top_n or (rank > 0 and absi(rk - rank) <= around):
				shown.append(rk)
		var last: int = 0
		for rk in shown:
			if rk > last + 1:
				_gap(last + 1, rk - 1, rows)
			_row(rows[rk - 1])
			last = rk
		if last < rows.size():
			_gap(last + 1, rows.size(), rows)
	_count.visible = _count.text != ""
	if rows.is_empty():
		line(tr("Nobody is ranked here yet."))
	bar_open(tr("Character"), "character")


func _realm_name(i: int) -> String:
	return str(realm_names[i]) if i >= 0 and i < realm_names.size() else "?"


func _ordinal(n: int) -> String:
	var suffix: String = "th"
	if n % 100 < 11 or n % 100 > 13:
		suffix = {1: "st", 2: "nd", 3: "rd"}.get(n % 10, "th")
	return tr("%d%s") % [n, suffix]


func _column_head() -> void:
	var h := HBoxContainer.new()
	var cols: Array = [["#", 48], [tr("Name"), 0], [tr("Sect"), 120], [tr("Stage"), 160], [tr("Power"), 80], [tr("Fights"), 50]]
	if str(view.get("which", "")) == "top":
		cols.insert(3, [tr("Realm"), 90])   # the Vấn Đỉnh Bảng holds two realms (rule 9)
	if compact:
		cols.remove_at(2)   # the compact layout drops the Sect column (the sect is in the row's tooltip and name)
	for pair in cols:
		var l := Label.new()
		l.text = str(pair[0])
		l.theme_type_variation = &"RowLabel"
		if int(pair[1]) > 0:
			l.custom_minimum_size = Vector2(int(pair[1]), 0)
		else:
			l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		h.add_child(l)
	body.add_child(h)


func _row(r: Dictionary) -> void:
	var h := HBoxContainer.new()
	h.name = "Rank_%d" % int(r.rank)
	var you: bool = bool(r.get("you", false))
	var cells: Array = [["%d%s" % [int(r.rank), " ▶" if you else ""], 48]]
	var num_l := Label.new()
	num_l.text = str(cells[0][0])
	num_l.custom_minimum_size = Vector2(48, 0)
	h.add_child(num_l)
	var name := LinkButton.new()
	name.text = str(r.name) + (" (" + tr("you") + ")" if you else "")
	name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	LinkStyle.apply(name, "person", "neutral", "paper")
	var pid: String = str(r.id)
	if not you:
		name.pressed.connect(func(): open_requested.emit("person", pid, ""))
	h.add_child(name)
	var prov: bool = str(r.state) == "provisional"
	var cells2: Array = [[str(r.sect) if str(r.sect) != "" else "—", 120], [str(r.stage), 160],
			[("~" if prov else "") + HudReadouts.stones_text(float(r.power)) + (" (" + tr("stale") + ")" if str(r.state) == "stale" else ""), 80], ["%d" % int(r.n), 50]]
	if str(view.get("which", "")) == "top":
		cells2.insert(1, [str(r.get("realm", "")), 90])
	if compact:
		cells2.remove_at(0)
	for cell in cells2:
		var l := Label.new()
		l.text = str(cell[0])
		l.custom_minimum_size = Vector2(int(cell[1]), 0)
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		h.add_child(l)
	h.focus_mode = Control.FOCUS_ALL
	h.accessibility_name = "%s, %s, %s, %s, %s %s%s, %d %s%s" % [_ordinal(int(r.rank)), str(r.name), str(r.sect) if str(r.sect) != "" else tr("no sect"), str(r.stage),
		tr("power"), (tr("about") + " ") if prov else "", HudReadouts.stones_text(float(r.power)), int(r.n), tr("rated fights"), (", " + tr("you")) if you else ""]
	TooltipLayer.set_tip(h, {"id": pid, "title": str(r.name) + ((" · " + str(r.sect)) if str(r.sect) != "" else ""), "fact": tr("Rating %.1f = base %.1f + offset %+.1f") % [float(r.rating), float(r.base), float(r.offset)],
		"summary": tr("Provisional: from realm and stage until a panel at this realm.") if prov else (tr("Stale: the build changed since the last panel.") if str(r.state) == "stale" else "")})
	if you:
		var frame := PanelContainer.new()
		frame.theme_type_variation = &"BoardPanel"
		frame.name = h.name
		h.name = "RankYou"
		frame.add_child(h)
		body.add_child(frame)
		_me_row = h
	else:
		body.add_child(h)
	_rows_by_rank[int(r.rank)] = h


func _gap(a: int, b: int, rows: Array) -> void:
	var key: String = "%d-%d" % [a, b]
	if _expanded_gaps.has(key):
		for rk in range(a, b + 1):
			_row(rows[rk - 1])
		return
	var g := Button.new()
	g.name = "Gap_" + key
	g.flat = true
	g.alignment = HORIZONTAL_ALIGNMENT_LEFT
	g.text = "  …  " + tr("ranks %d–%d: %d people (show)") % [a, b, b - a + 1]
	g.pressed.connect(_open_gap.bind(key))
	body.add_child(g)


func _jump_me() -> void:
	if _me_row != null:
		_scroll_to(_me_row)
		_me_row.grab_focus()


func _open_gap(key: String) -> void:
	_expanded_gaps[key] = true
	_rebuild()


func _on_search(_text: String) -> void:
	_rebuild()
	_search.grab_focus()
	_search.caret_column = _search.text.length()


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
