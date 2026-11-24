class_name GameWindow
extends VBoxContainer
## One window kind shown inside the [WindowHost] (design/ux/interaction-patterns.md: Side panel with history, Sticky
## header and pinned action bar, Section jumps, Reply strip). A window is built from a view Dictionary that the host
## reads for it (a GameQuery copy, ADR-0006): it never reads the session, and it changes nothing itself. Actions are
## requested with [signal action_requested]; other windows with [signal open_requested].
##
## Layout: a sticky header ([member header]), a scrolling body ([member body]) whose section headings are jump targets,
## a reply strip and a pinned action bar ([member bar]). Subclasses fill them in [method _build].

## Open another window (a link or an action-bar button). [param section] scrolls it to a section.
signal open_requested(kind: String, subject: String, section: String)
## Run a session command ([param action] is its name; the map screen runs it through session.run as a job).
signal action_requested(action: String, args: Array)

## The sticky header (never scrolls).
var header := VBoxContainer.new()
## The scrolling body.
var scroll := ScrollContainer.new()
## The body's column of sections.
var body := VBoxContainer.new()
## The pinned action bar (at most 4 buttons).
var bar := HBoxContainer.new()
## The pinned side pane beside the body (weak-point review 2026-11-24: the inventory's Selected panel and the wiki's
## Contents scrolled away with the body): empty and hidden unless a window builds into it ([method use_side]); it
## scrolls on its own.
var side := VBoxContainer.new()
var _side_scroll := ScrollContainer.new()
var _split_row := HBoxContainer.new()
## The view this window was last built from.
var view: Dictionary = {}
## True while the window is look-only (an event waits): actions are disabled with a lock mark.
var locked: bool = false
## True in the compact layout (below ui_windows.json compact_width, e.g. 1280×720): windows drop or fold secondary
## columns and lines (the character sheet's standing line, the rankings' Sect column).
var compact: bool = false
## The illustrated windows' look (ui_windows.json illustrated: element colours, icons), set by the map screen.
var style: Dictionary = {}

var _reply := VBoxContainer.new()
var _reply_text := Label.new()
var _more := TextureRect.new()   # the scroll cue over the body's bottom edge
var _headings: Dictionary = {}   # section key -> its heading Label (focusable)
var _heading_order: Array = []


func _init() -> void:
	add_theme_constant_override("separation", 6)
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(header)
	add_child(HSeparator.new())
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	# never shown, not disabled: a disabled horizontal scroll passes the body's minimum width up, and one unwrapped label
	# then grew the window past its share over the map's buttons (the --crowded evidence, 2026-11-24); now the window
	# keeps its share and such a line is cut at the window's edge instead
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	# the scroll cue (weak-point review 2026-11-24: "clips with no scroll cue"): a dark fade with a chevron over the
	# body's bottom edge while more lies below; it never takes the mouse
	var wrap := MarginContainer.new()
	wrap.size_flags_vertical = Control.SIZE_EXPAND_FILL
	wrap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_split_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_split_row.add_theme_constant_override("separation", 10)
	add_child(_split_row)
	_split_row.add_child(wrap)
	_side_scroll.name = "Side"
	_side_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_side_scroll.visible = false
	side.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	side.add_theme_constant_override("separation", 8)
	_side_scroll.add_child(side)
	_split_row.add_child(_side_scroll)
	wrap.add_child(scroll)
	_more.name = "ScrollCue"
	_more.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_more.size_flags_vertical = Control.SIZE_SHRINK_END
	_more.custom_minimum_size = Vector2(0, 40)
	var grad := Gradient.new()
	grad.set_color(0, Color(0, 0, 0, 0.0))
	grad.set_color(1, Color(0, 0, 0, 0.45))
	var gt := GradientTexture2D.new()
	gt.gradient = grad
	gt.fill_from = Vector2(0, 0)
	gt.fill_to = Vector2(0, 1)
	_more.texture = gt
	_more.stretch_mode = TextureRect.STRETCH_SCALE
	_more.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	var chev := Label.new()
	chev.text = "▾"
	chev.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	chev.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	chev.set_anchors_preset(Control.PRESET_FULL_RECT)
	chev.add_theme_color_override("font_color", Color("#F2E6C8"))
	chev.add_theme_font_size_override("font_size", 20)
	chev.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_more.add_child(chev)
	_more.visible = false
	wrap.add_child(_more)
	scroll.get_v_scroll_bar().changed.connect(_update_scroll_cue)
	scroll.get_v_scroll_bar().value_changed.connect(func(_v): _update_scroll_cue())
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 3)
	scroll.add_child(body)
	# Reply strip (pattern): up to 3 wrapped lines and a dismiss button, announced politely.
	_reply.visible = false
	var rrow := HBoxContainer.new()
	_reply_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_reply_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_reply_text.max_lines_visible = 3
	rrow.add_child(_reply_text)
	var dismiss := Button.new()
	dismiss.text = "×"
	dismiss.accessibility_name = tr("Dismiss the reply")
	TooltipLayer.set_tip(dismiss, tr("Dismiss"))
	dismiss.pressed.connect(func(): _reply.visible = false)
	rrow.add_child(dismiss)
	_reply.add_child(HSeparator.new())
	_reply.add_child(rrow)
	add_child(_reply)
	add_child(HSeparator.new())
	add_child(bar)


## True for a window that fills the width of a full screen (the Đạo Đồ canvas) instead of the parchment column.
func full_width() -> bool:
	return false


## The parchment column's width on a full screen, in layout pixels (FullScreenHost); a two-column screen asks for more.
func column_width() -> int:
	return 900


## The window kind ("character", "inventory", ...).
func kind() -> String:
	return ""


## The frame title for [param v].
func window_title(_v: Dictionary) -> String:
	return ""


## Builds the window from [param v]; scrolls to [param section] ("" = the top). [param is_locked] marks look-only.
func show_view(v: Dictionary, section: String, is_locked: bool) -> void:
	view = v
	locked = is_locked
	_headings.clear()
	_heading_order.clear()
	for box in [header, body, bar, side]:
		for c in (box as Control).get_children():
			box.remove_child(c)
			c.queue_free()
	_side_scroll.visible = false
	_build()
	if section != "":
		jump_to.call_deferred(section)
	else:
		scroll.scroll_vertical = 0


## The row holding the scrolling body and the side pane: a window that replaces the body with its own canvas (the
## Đạo Đồ) hides this and puts its canvas at this index.
func body_area() -> Control:
	return _split_row


## Shows the pinned side pane, [param width] layout pixels wide, on the right (or the left with [param on_left]);
## call it from _build, then build into [member side].
func use_side(width: int, on_left: bool = false) -> void:
	_side_scroll.visible = true
	_side_scroll.custom_minimum_size = Vector2(width, 0)
	_split_row.move_child(_side_scroll, 0 if on_left else _split_row.get_child_count() - 1)


## The control focus goes to when the window opens.
func first_focus() -> Control:
	for c in bar.get_children():
		if c is Control and (c as Control).focus_mode != Control.FOCUS_NONE:
			return c
	return _headings.get(_heading_order[0]) if not _heading_order.is_empty() else null


## Shows [param lines] (the first 3) in the reply strip; an empty array hides it.
func show_reply(lines: Array) -> void:
	_reply_text.text = "\n".join(lines.slice(0, 3).map(func(l): return str(l)))
	_reply.visible = not lines.is_empty()


## The reply strip's text ("" when hidden).
func reply_text() -> String:
	return _reply_text.text if _reply.visible else ""


## Section keys in body order.
func section_keys() -> Array:
	return _heading_order.duplicate()


## Scrolls the body to section [param key] and focuses its heading.
func jump_to(key: String) -> void:
	var h: Control = _headings.get(key)
	if h == null:
		return
	scroll.scroll_vertical = int(_y_in_body(h))
	h.grab_focus()
	# headings inside insets get their place only once the containers are laid out: scroll again after two frames
	if is_inside_tree():
		await get_tree().process_frame
		await get_tree().process_frame
		if is_instance_valid(h) and h.is_inside_tree():
			scroll.scroll_vertical = int(_y_in_body(h))


# A control's top relative to the body (headings may sit inside insets and grids).
func _y_in_body(c: Control) -> float:
	return c.global_position.y - body.global_position.y if c.is_inside_tree() and body.is_inside_tree() else c.position.y


## Section jumps (pattern): Home / End and the gamepad triggers move between headings.
func _unhandled_input(event: InputEvent) -> void:
	if is_visible_in_tree() and _owns_focus():
		_jump_input(event)


func _jump_input(event: InputEvent) -> void:
	if _heading_order.is_empty() or not event.is_pressed() or event.is_echo():
		return
	var step: int = 0
	if event is InputEventKey:
		match (event as InputEventKey).physical_keycode:
			KEY_HOME:
				jump_to(str(_heading_order[0]))
				get_viewport().set_input_as_handled()
				return
			KEY_END:
				jump_to(str(_heading_order[-1]))
				get_viewport().set_input_as_handled()
				return
	elif event is InputEventJoypadMotion:   # LT / RT arrive as axes; the shoulders belong to the HUD's window buttons
		var m := event as InputEventJoypadMotion
		if m.axis_value > 0.6:
			step = -1 if m.axis == JOY_AXIS_TRIGGER_LEFT else (1 if m.axis == JOY_AXIS_TRIGGER_RIGHT else 0)
	if step != 0:
		var at: int = _current_heading_index()
		jump_to(str(_heading_order[clampi(at + step, 0, _heading_order.size() - 1)]))
		get_viewport().set_input_as_handled()


func _current_heading_index() -> int:
	var y: int = scroll.scroll_vertical
	var at: int = 0
	for i in _heading_order.size():
		if int(_y_in_body(_headings[_heading_order[i]] as Control)) <= y + 4:
			at = i
	return at


func _owns_focus() -> bool:
	var f: Control = get_viewport().gui_get_focus_owner() if get_viewport() != null else null
	return f != null and (f == self or is_ancestor_of(f))


# --- Builders for subclasses ------------------------------------------------------------------------------------

## Subclasses build header, body and bar here from [member view].
func _build() -> void:
	pass


## A section heading (gilt caps, a focus stop and a jump target) under [param key].
func section(key: String, title: String) -> Label:
	var h := Label.new()
	h.text = title.to_upper()
	h.theme_type_variation = &"RowLabel"
	h.focus_mode = Control.FOCUS_ALL
	h.accessibility_name = title
	if not _heading_order.is_empty():
		var gap := Control.new()
		gap.custom_minimum_size = Vector2(0, 6)
		body.add_child(gap)
	body.add_child(h)
	_headings[key] = h
	_heading_order.append(key)
	return h


## A section as an illustrated parchment inset (Illustrated.inset) in [param parent], its heading a focus stop and a
## jump target under [param key] like [method section]. Returns the inset's content column.
func section_in(parent: Control, key: String, title: String, expand: bool = true) -> VBoxContainer:
	var col: VBoxContainer = Illustrated.inset(parent, "", expand)
	var h := Label.new()
	h.text = title.to_upper()
	h.theme_type_variation = &"RowLabel"
	h.focus_mode = Control.FOCUS_ALL
	h.accessibility_name = title
	col.add_child(h)
	var rule := ColorRect.new()
	rule.color = Color(Illustrated.BRASS, 0.7)
	rule.custom_minimum_size = Vector2(0, 1)
	col.add_child(rule)
	_headings[key] = h
	_heading_order.append(key)
	return col


## A label / value row in the body; [param tip] (a tooltip content or String) goes on the whole row.
func row(label: String, value: String, tip: Variant = null, parent: Control = null) -> HBoxContainer:
	var r := HBoxContainer.new()
	var l := Label.new()
	l.text = label
	l.custom_minimum_size = Vector2(170, 0)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	r.add_child(l)
	var v := Label.new()
	v.text = value
	v.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	r.add_child(v)
	if tip != null:
		TooltipLayer.set_tip(r, tip)
		r.mouse_filter = Control.MOUSE_FILTER_STOP
		r.focus_mode = Control.FOCUS_ALL   # Q opens the tip from the keyboard
		r.accessibility_name = "%s %s" % [label, value]
	(parent if parent != null else body).add_child(r)
	return r


## A plain wrapped line in the body (or [param parent]).
func line(text: String, parent: Control = null) -> Label:
	var l := Label.new()
	l.text = text
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size = Vector2(200, 0)
	(parent if parent != null else body).add_child(l)
	return l


## An action-bar button that opens window [param target_kind].
func bar_open(text: String, target_kind: String, subject: String = "", sect: String = "") -> Button:
	var b := Button.new()
	b.text = text + "  ›"
	b.theme_type_variation = &"TextButton"   # a link to another window: the third button tier, not an action
	b.accessibility_name = tr("Open %s") % text
	b.pressed.connect(func(): open_requested.emit(target_kind, subject, sect))
	bar.add_child(b)
	return b


## The window's one primary call in the action bar (weak-point review 2026-11-24: "the call to action is below the
## fold"): a gold CommitButton that scrolls to section [param key], where the action and its confirm live.
func bar_jump(text: String, key: String, reason: String = "") -> Button:
	var b := Button.new()
	b.name = "BarJump_" + key
	b.text = text + "  ↓"
	b.theme_type_variation = &"CommitButton"
	b.accessibility_name = text + ((": " + reason) if reason != "" else "")
	TooltipLayer.set_tip(b, {"title": text, "summary": reason if reason != "" else tr("Go to it: the confirm is there.")})
	b.pressed.connect(func(): jump_to(key))
	bar.add_child(b)
	bar.move_child(b, 0)
	return b


## A button that requests [param action]; disabled with a lock mark and reason while look-only.
func action_button(text: String, action: String, args: Array, parent: Control, reason: String = "") -> Button:
	var b := Button.new()
	var why: String = reason
	if why == "" and locked:
		why = tr("locked while an event waits")
	b.text = ("🔒 " if why != "" and locked else "") + text
	b.disabled = why != ""
	b.accessibility_name = text + ((": " + why) if why != "" else "")
	if why != "":
		TooltipLayer.set_tip(b, {"title": text, "summary": why})
	b.pressed.connect(func(): action_requested.emit(action, args))
	parent.add_child(b)
	return b


## A Breakdown tooltip content from a view's {total, lines}.
static func breakdown_tip(title: String, bd: Variant, summary: String = "") -> Dictionary:
	var d: Dictionary = bd if bd is Dictionary else {}
	return {"title": title, "fact": Breakdown._fmt(float(d.get("total", 0.0))) if d.has("total") else "", "summary": summary,
		"lines": Array(d.get("lines", []))}


## A number as the HUD shows it: thousands grouped, following the language.
static func num(v: float) -> String:
	return HudReadouts.stones_text(v) if absf(v) >= 10.0 else ("%.2f" % v).rstrip("0").rstrip(".")


## Focuses [param c] on the next frame if it is still in the tree and shown (a deferred grab_focus on a node a test or
## a rebuild has removed would error).
func focus_later(c: Control) -> void:
	_focus_now.bind(c).call_deferred()


func _focus_now(c: Control) -> void:
	if is_instance_valid(c) and c.is_inside_tree() and c.is_visible_in_tree():
		c.grab_focus()


## Shows the scroll cue while the body has more below the visible part.
func _update_scroll_cue() -> void:
	var bar: VScrollBar = scroll.get_v_scroll_bar()
	_more.visible = bar.max_value - bar.page > 4.0 and bar.value < bar.max_value - bar.page - 4.0


## True while the scroll cue shows (for tests).
func shows_scroll_cue() -> bool:
	return _more.visible
