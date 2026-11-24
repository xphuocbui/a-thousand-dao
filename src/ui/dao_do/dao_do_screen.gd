class_name DaoDoScreen
extends GameWindow
## The Đạo Đồ full screen (design/ux/dao-do-view.md), laid out like Path of Exile's passive tree (user 2026-11-24): the
## tree fills the screen ([DaoDoCanvas]: painted node icons, gold allocated paths); a slim bar on top with the points,
## the next point source, search, Apply / Reset and zoom; hovering a mark shows a PoE-style card beside the pointer (its
## name in its class colour, then its stats one per line, a capability or Effect, and what reaching it costs). Clicking
## a mark plans its route (the pale path); clicking a planned mark takes it and everything after it back out of the plan.
## Apply runs only when the points cover the whole plan (rule 3: nothing is spent partway) and after a confirm
## ("permanent: never refunded"). The plan is this screen's state for the session (not saved).
##
## [member node_reader] (set by the map screen) is func(node_id, pending) -> Dictionary, GameQuery.dao_do_node.

## The leave prompt was answered: [param go] true to go back to the map (keep or discard), false to stay.
signal leave_decided(go: bool)

## Reads one node: func(node_id: int, pending: Array) -> Dictionary.
var node_reader: Callable = func(_id: int, _p: Array) -> Dictionary: return {}
## The static map (DaoDoTree), set once by the map screen.
var tree: DaoDoTree = null
## ui_windows.json dao_do (families, colours, open_scale, icons).
var cfg: Dictionary = {}

const CLASS_COLOURS := {"notable": Color("#e9c46a"), "keystone": Color("#ff8a5c"), "start": Color("#f4f1ea"),
	"small": Color("#c8c2b4"), "road": Color("#b9a987")}
const STAT_COLOUR := Color("#8f9cff")      # PoE's mod blue
const NOTE_COLOUR := Color("#a79f8f")

var _canvas := DaoDoCanvas.new()
var _card := PanelContainer.new()
var _card_box := VBoxContainer.new()
var _search := LineEdit.new()
var _count := Label.new()
var _apply := Button.new()
var _reset := Button.new()
var _counters := Label.new()
var _plan: Array = []          # pending node ids, in the order they will open
var _sel: int = -1
var _card_id: int = -2
var _matches: Array = []
var _match_at: int = -1
var _armed: String = ""        # "apply", "leave", "start:<key>"
var _set_up: bool = false
var _names: Dictionary = {}    # node id -> folded name + stat words, for search


func kind() -> String:
	return "dao_do"


func window_title(_v: Dictionary) -> String:
	return tr("Đạo Đồ")


func full_width() -> bool:
	return true


## The plan (pending node ids), for tests and the leave prompt.
func plan() -> Array:
	return _plan.duplicate()


## True while a plan is pending (hud.md: a full screen with uncommitted edits asks before leaving).
func has_uncommitted() -> bool:
	return not _plan.is_empty()


## Clears the plan (Reset, or Discard on leaving).
func reset_plan() -> void:
	_plan.clear()
	_refresh_state()
	_build_bar()


## The canvas (for tests and the shot arguments).
func canvas() -> DaoDoCanvas:
	return _canvas


## The hover card's text (for tests): every Label in it.
func card_text() -> String:
	var out: PackedStringArray = []
	for l in _card_box.find_children("*", "Label", true, false):
		out.append((l as Label).text)
	return "\n".join(out)


func first_focus() -> Control:
	return _canvas


func cancel_inline() -> bool:
	if _armed != "":
		_armed = ""
		_build_bar()
		return true
	if _sel >= 0:
		_sel = -1
		_canvas.select(-1)
		return true
	return false


func show_view(v: Dictionary, section: String, is_locked: bool) -> void:
	view = v
	locked = is_locked or bool(v.get("event_waiting", false))
	if not _set_up:
		_set_up_layout()
	var open: Array = Array(v.get("open", []))
	_plan = _plan.filter(func(n): return not open.has(int(n)))   # marks opened meanwhile drop out of the plan
	_refresh_state()
	_build_bar()
	_hide_card()
	if section == "":
		_canvas.centre_on_set(open, float(cfg.get("open_scale", 18.0)))


func _set_up_layout() -> void:
	_set_up = true
	scroll.visible = false   # the canvas fills the body instead of the scrolling column
	var holder := Control.new()   # the canvas with the hover card floating over it
	holder.name = "CanvasHolder"
	holder.size_flags_vertical = Control.SIZE_EXPAND_FILL
	holder.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(holder)
	move_child(holder, scroll.get_index())
	_canvas.set_anchors_preset(Control.PRESET_FULL_RECT)
	_canvas.colours = cfg.get("colours", {})
	_canvas.families = cfg.get("families", {})
	holder.add_child(_canvas)
	# the PoE-style hover card: a dark plate with a gold edge; it ignores the mouse so it never blocks the tree
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.03, 0.03, 0.05, 0.94)
	sb.border_color = Color("#8a6d3b")
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(3)
	sb.set_content_margin_all(10)
	_card.add_theme_stylebox_override("panel", sb)
	_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_card.visible = false
	_card_box.add_theme_constant_override("separation", 2)
	_card_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_card.add_child(_card_box)
	holder.add_child(_card)
	if tree != null:
		_canvas.setup(tree)
		_canvas.load_icons(str(cfg.get("icons", "res://assets/icons/dao_do/game/icons.json")))
		for id in tree.nodes:
			var nd: Dictionary = tree.nodes[id]
			var words: String = str(nd.get("name", ""))
			for m in Array(nd.get("mods", [])):
				words += " " + str(m.get("stat", "")).replace("_", " ")
			_names[int(id)] = WorldDB.fold(words)
	_canvas.hovered.connect(_on_hover)
	_canvas.selected.connect(_on_click)
	_canvas.gui_input.connect(_canvas_keys)
	_search.placeholder_text = tr("Search marks by name or stat…  (Ctrl+F; Enter: next)")
	_search.accessibility_name = tr("Search the Đạo Đồ")
	_search.custom_minimum_size = Vector2(340, 0)
	_search.text_changed.connect(_on_search)
	_search.text_submitted.connect(_on_search_enter)


func _build() -> void:
	pass   # the bar is built by _build_bar; the canvas lives outside the body


func _build_bar() -> void:
	for keep in [_search, _count, _counters, _apply, _reset]:   # kept across rebuilds: out of the old rows first
		if keep.get_parent() != null:
			keep.get_parent().remove_child(keep)
	for c in header.get_children():
		header.remove_child(c)
		c.queue_free()
	var v: Dictionary = view
	var cost: int = _plan.size()
	var pts: int = int(v.get("points", 0))
	var row := HFlowContainer.new()
	row.add_theme_constant_override("h_separation", 10)
	header.add_child(row)
	_counters.text = tr("%d points unspent") % pts + (("  ·  " + tr("plan %d (%s)") % [cost, tr("covered") if cost <= pts else tr("%d short") % (cost - pts)]) if cost > 0 else "")
	_counters.theme_type_variation = &"WoodHeading"
	row.add_child(_counters)
	row.add_child(_search)
	_count.theme_type_variation = &"WoodLabel"
	_count.visible = _count.text != ""
	row.add_child(_count)
	_apply.text = tr("Apply (%d)") % cost
	var why: String = ""
	if locked:
		why = tr("locked while an event waits")
	elif cost == 0:
		why = tr("click marks to plan a route first")
	elif cost > pts:
		why = tr("the plan costs %d points; you have %d (rule 3: nothing is spent partway)") % [cost, pts]
	_apply.disabled = why != ""
	_apply.theme_type_variation = &"CommitButton"
	_apply.accessibility_name = _apply.text + ((": " + why) if why != "" else "")
	TooltipLayer.set_tip(_apply, {"title": tr("Apply the plan"), "summary": why if why != "" else tr("Opens the planned marks in order. Permanent: the Đạo Đồ is never refunded.")})
	if not _apply.pressed.is_connected(_arm_apply):
		_apply.pressed.connect(_arm_apply)
	row.add_child(_apply)
	_reset.text = tr("Reset")
	_reset.disabled = cost == 0
	if not _reset.pressed.is_connected(reset_plan):
		_reset.pressed.connect(reset_plan)
	row.add_child(_reset)
	for zb in [["−", func(): _canvas.zoom_by(1.0 / 1.4)], ["+", func(): _canvas.zoom_by(1.4)], [tr("Whole tree"), func(): _canvas.fit()],
			[tr("My marks"), func(): _canvas.centre_on_set(Array(view.get("open", [])), float(cfg.get("open_scale", 18.0)))]]:
		var b := Button.new()
		b.text = str(zb[0])
		b.pressed.connect(zb[1])
		row.add_child(b)
	if str(v.get("next_points", "")) != "":
		var np := Label.new()
		np.text = str(v.next_points)
		np.theme_type_variation = &"WoodLabel"
		row.add_child(np)
	if _armed == "apply":
		_confirm_row(tr("Open %d marks for %d points? Permanent: the Đạo Đồ is never refunded.") % [cost, cost],
			[[tr("Confirm"), "ConfirmApply", _apply_plan], [tr("Cancel"), "CancelApply", cancel_inline]])
	elif _armed == "leave":
		_confirm_row(tr("You have a plan of %d marks. Keep it for next time, discard it, or stay?") % cost,
			[[tr("Keep the plan"), "Leave_keep", _leave_choice.bind("keep")], [tr("Discard"), "Leave_discard", _leave_choice.bind("discard")],
			[tr("Stay"), "Leave_stay", _leave_choice.bind("stay")]])
	var starts: Array = Array(v.get("starts", []))
	if bool(v.get("can_change_start", false)) and starts.size() > 1:
		var sr := HFlowContainer.new()
		header.add_child(sr)
		var sl := Label.new()
		sl.text = tr("Start (until your first mark):")
		sl.theme_type_variation = &"WoodLabel"
		sr.add_child(sl)
		for st in starts:
			var b3 := Button.new()
			b3.text = str(st.name) + (" ✓" if bool(st.get("current", false)) else "")
			b3.disabled = bool(st.get("current", false)) or locked
			var key: String = str(st.key)
			if _armed == "start:" + key:
				b3.text = tr("Confirm: start at %s") % str(st.name)
				b3.pressed.connect(_choose_start.bind(key))
			else:
				b3.pressed.connect(_arm.bind("start:" + key))
			sr.add_child(b3)


func _confirm_row(text: String, buttons: Array) -> void:
	var r := HFlowContainer.new()
	header.add_child(r)
	var ask := Label.new()
	ask.text = text
	ask.theme_type_variation = &"WoodLabel"
	ask.accessibility_name = text
	r.add_child(ask)
	var last: Button = null
	for b in buttons:
		var btn := Button.new()
		btn.text = str(b[0])
		btn.name = str(b[1])
		btn.pressed.connect(b[2])
		r.add_child(btn)
		last = btn
	if last != null:
		focus_later(last)


## The leave prompt (FullScreenHost asks before going back while a plan is pending). Returns true when it showed.
func ask_leave() -> bool:
	if _plan.is_empty():
		return false
	_armed = "leave"
	_build_bar()
	return true


func _leave_choice(choice: String) -> void:
	_armed = ""
	if choice == "discard":
		reset_plan()
	_build_bar()
	leave_decided.emit(choice != "stay")


func _choose_start(key: String) -> void:
	_armed = ""
	action_requested.emit("tree_choose_start", [key])


func _arm(what: String) -> void:
	_armed = what
	_build_bar()


func _arm_apply() -> void:
	_arm("apply")


func _apply_plan() -> void:
	_armed = ""
	var ids: Array = _plan.duplicate()
	_build_bar()
	action_requested.emit("tree_apply", [ids])


## A click: plan the route to an unplanned mark; on a planned mark, take it and the marks planned after it back out.
func _on_click(id: int) -> void:
	_sel = id
	if id < 0 or locked:
		return
	var at: int = _plan.find(id)
	if at >= 0:
		_plan = _plan.slice(0, at)
		_refresh_state()
		_build_bar()
		_card_id = -2
		_show_card(id, _canvas.screen_pos_of(id))
		return
	_plan_route(id)


## Adds the route to [param id] (from the open marks or the plan's end) to the plan.
func _plan_route(id: int) -> void:
	if locked:
		return
	var nd: Dictionary = node_reader.call(id, _plan)
	if nd.is_empty() or not bool(nd.get("ok", false)):
		show_reply([str(nd.get("reason", tr("That mark cannot be planned.")))])
		return
	for n in Array(nd.get("route", [])):
		if not _plan.has(int(n)):
			_plan.append(int(n))
	_refresh_state()
	_build_bar()
	_card_id = -2
	_show_card(id, _canvas.screen_pos_of(id))


func _refresh_state() -> void:
	_canvas.set_state(Array(view.get("open", [])), Array(view.get("frontier", [])), _plan)


func _on_hover(id: int, at: Vector2) -> void:
	if id < 0:
		_hide_card()
		return
	_show_card(id, at)


func _hide_card() -> void:
	_card.visible = false
	_card_id = -2
	_canvas.set_route([])


## The PoE-style card for node [param id] beside [param at] (canvas coordinates): the name in its class colour, the
## class and land, the stats one per line in mod blue, a capability or Effect and its rule, then the cost to reach it.
func _show_card(id: int, at: Vector2) -> void:
	if id != _card_id:
		_card_id = id
		for c in _card_box.get_children():
			_card_box.remove_child(c)
			c.queue_free()
		var nd: Dictionary = node_reader.call(id, _plan)
		if nd.is_empty():
			_card.visible = false
			return
		_canvas.set_route(Array(nd.get("route", [])))
		var k: String = str(nd.get("kind", "small"))
		var art: Texture2D = _canvas.icon_texture(id)
		if art != null:   # the node's painting at its own size: on the tree it is too small to read
			var pic := TextureRect.new()
			pic.name = "CardArt"
			pic.texture = art
			pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			pic.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
			var side: float = art.get_width()
			pic.custom_minimum_size = Vector2(side, side)
			pic.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			pic.mouse_filter = Control.MOUSE_FILTER_IGNORE
			_card_box.add_child(pic)
		var title: String = str(nd.get("name", ""))
		if title == "" or title == "Đạo văn":
			title = {"small": tr("Small mark (đạo văn)"), "road": tr("Road"), "notable": tr("Notable"), "keystone": tr("Keystone")}.get(k, tr("Mark"))
		_card_label(title, CLASS_COLOURS.get(k, Color.WHITE), 20 if k in ["notable", "keystone", "start"] else 17)
		_card_label("%s · %s" % [tr(k).capitalize(), _area_words(str(nd.get("area", "")))], NOTE_COLOUR, 16)
		_card_box.add_child(HSeparator.new())
		for st in Array(nd.get("stats", [])):
			_card_label(str(st), STAT_COLOUR, 16)
		if Array(nd.get("stats", [])).is_empty() and int(nd.get("cap", 0)) == 0 and str(nd.get("effect", "")) == "":
			_card_label(tr("No stats"), NOTE_COLOUR, 16)
		if not is_equal_approx(float(nd.get("scale", 1.0)), 1.0):
			_card_label(tr("×%.2f from your root's purity in this land") % float(nd.scale), NOTE_COLOUR, 16)
		if int(nd.get("cap", 0)) > 0:
			_card_label(tr("Capability: %s") % str(nd.cap_name), Color("#5fd0b4"), 16)
			if str(nd.get("cap_desc", "")) != "":
				_card_label(str(nd.cap_desc), NOTE_COLOUR, 16)
		if str(nd.get("effect", "")) != "":
			_card_label("%s: %s" % [tr("Keystone") if k == "keystone" else tr("Effect"), str(nd.effect)], Color("#f08cc0"), 16)
			if str(nd.get("effect_rule", "")) != "":
				_card_label(str(nd.effect_rule), NOTE_COLOUR, 16)
		if str(nd.get("closes", "")) != "":
			_card_label(tr("Price: %s") % str(nd.closes), Color("#ff8a5c"), 16)
		_card_box.add_child(HSeparator.new())
		if bool(nd.get("open", false)):
			_card_label(tr("Allocated"), Color("#e3b860"), 16)
		elif bool(nd.get("planned", false)):
			_card_label(tr("In the plan: click to take it out"), Color("#9fd3ff"), 16)
		elif not bool(nd.get("ok", false)):
			_card_label("✗ " + str(nd.get("reason", "")), Color("#ff8a5c"), 16)
		else:
			_card_label(tr("Click to plan: %d point(s)") % int(nd.cost) + ((" " + tr("after the plan")) if not _plan.is_empty() else ""), Color("#9fd3ff"), 16)
			var gains: Dictionary = nd.get("gains", {})
			var now_p: Dictionary = nd.get("purity_now", {})
			for e in gains:
				_card_label("  %s %s → %s" % [str(e), LinhCan.fmt(float(now_p.get(e, 0.0))), LinhCan.fmt(float(now_p.get(e, 0.0)) + float(gains[e]))], NOTE_COLOUR, 16)
		_card.accessibility_name = title
		_card.reset_size()
	_card.visible = true
	var area: Vector2 = _canvas.size
	var cs: Vector2 = _card.get_combined_minimum_size()
	var pos: Vector2 = at + Vector2(22, 18)
	if pos.x + cs.x > area.x - 8:
		pos.x = at.x - cs.x - 22
	if pos.y + cs.y > area.y - 8:
		pos.y = maxf(8.0, area.y - cs.y - 8)
	_card.position = pos.max(Vector2(8, 8))


func _card_label(text: String, col: Color, px: int) -> void:
	var l := Label.new()
	l.text = text
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size = Vector2(280, 0)
	l.add_theme_color_override("font_color", col)
	l.add_theme_font_size_override("font_size", px)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_card_box.add_child(l)


func _area_words(area: String) -> String:
	if area == "chaos":
		return tr("the Chaos land")
	if area == "exact" or area == "":
		return tr("no land")
	if area.begins_with("el:") or area.begins_with("var:"):
		return tr("the %s land") % area.get_slice(":", 1)
	if area.begins_with("border:"):
		return tr("the border of %s and %s") % [area.get_slice(":", 1), area.get_slice(":", 2)]
	return area


func _on_search(text: String) -> void:
	var q: String = WorldDB.fold(text.strip_edges())
	_matches = []
	if q.length() >= 2:
		for id in _names:
			if str(_names[id]).contains(q):
				_matches.append(int(id))
	_matches.sort()
	_match_at = -1
	_canvas.set_matches(_matches)
	_count.text = "" if q == "" else tr("%d matches") % _matches.size()
	_count.visible = _count.text != ""


func _on_search_enter(_t: String) -> void:
	_next_match()


func _next_match() -> void:
	if _matches.is_empty():
		return
	_match_at = (_match_at + 1) % _matches.size()
	var id: int = int(_matches[_match_at])
	_canvas.centre_on(id, 24.0)
	_sel = id
	_canvas.select(id)
	_card_id = -2
	_show_card(id, _canvas.screen_pos_of(id))


## Keys on the canvas: arrows pan, Shift+arrows move the selection to the nearest neighbour that way, + / − zoom,
## 0 fits, Home centres on the player's marks, P / Enter plans (or unplans) the selected mark.
func _canvas_keys(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.is_pressed():
		return
	var k := event as InputEventKey
	var dir := Vector2.ZERO
	match k.physical_keycode:
		KEY_LEFT:
			dir = Vector2.LEFT
		KEY_RIGHT:
			dir = Vector2.RIGHT
		KEY_UP:
			dir = Vector2.UP
		KEY_DOWN:
			dir = Vector2.DOWN
		KEY_EQUAL, KEY_KP_ADD:
			_canvas.zoom_by(1.25)
		KEY_MINUS, KEY_KP_SUBTRACT:
			_canvas.zoom_by(0.8)
		KEY_0, KEY_KP_0:
			_canvas.fit()
		KEY_HOME:
			_canvas.centre_on_set(Array(view.get("open", [])), float(cfg.get("open_scale", 18.0)))
		KEY_P, KEY_ENTER, KEY_KP_ENTER:
			if _sel >= 0:
				_on_click(_sel)
		_:
			return
	if dir != Vector2.ZERO:
		if k.shift_pressed:
			_step_selection(dir)
		else:
			_canvas.pan(-dir * 60.0)
	_canvas.accept_event()


func _step_selection(dir: Vector2) -> void:
	var from: int = _sel if _sel >= 0 else int(view.get("start", -1))
	if tree == null or from < 0:
		return
	var p0 := Vector2(float(tree.node(from).get("x", 0.0)), float(tree.node(from).get("y", 0.0)))
	var best: int = -1
	var best_score: float = -INF
	for nb in tree.neighbors(from):
		var nd: Dictionary = tree.node(int(nb))
		var d := Vector2(float(nd.get("x", 0.0)), float(nd.get("y", 0.0))) - p0
		if d.length() == 0.0:
			continue
		var score: float = d.normalized().dot(dir)
		if score > best_score:
			best_score = score
			best = int(nb)
	if best >= 0 and best_score > 0.2:
		_sel = best
		_canvas.select(best)
		_canvas.centre_on(best, _canvas.scale_px())
		_card_id = -2
		_show_card(best, _canvas.screen_pos_of(best))


func _unhandled_input(event: InputEvent) -> void:
	if is_visible_in_tree() and event is InputEventKey and event.is_pressed() and (event as InputEventKey).ctrl_pressed \
			and (event as InputEventKey).physical_keycode == KEY_F:
		_search.grab_focus()
		get_viewport().set_input_as_handled()


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		for c in [_search, _count, _counters, _apply, _reset]:
			if is_instance_valid(c) and c.get_parent() == null:
				c.free()
