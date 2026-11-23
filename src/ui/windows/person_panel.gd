class_name PersonPanel
extends PanelContainer
## The person window (design/ux/person.md), greybox: one person in the HUD's Z6 panel. A sticky header (who they are and
## how strong), a scrolling body (Made of, Character and ties, Verbs, More), a reply strip and a pinned action bar.
## The player always sees everything about everyone. Data comes from [method GameQuery.person] (a copy); the panel
## never reads the session itself and changes nothing: verbs and fights are requested through signals.
##
## Greybox limits: the verb system is designed but not built (npc-interaction-dialogue.md), so only Greet works (the
## session's existing talk); the other verbs are listed greyed with that reason. Pins, the relationships page and window
## history are not built yet.

## Open another person's window (a tie partner).
signal person_requested(person_id: String)
## Watch a practice fight with this person (the fight screen).
signal fight_requested(person_id: String)
## Travel to where this person is (the focus comparison).
signal travel_requested(place_id: String)
## Use a verb (only "greet" in the greybox).
signal verb_requested(person_id: String, verb_id: String)
## The panel was closed.
signal closed

## The verbs of npc-interaction-dialogue.md rules 8-11, by group; only Greet runs in the greybox.
const VERBS := [
	["Social", ["greet:Greet (Hàn huyên)", "news:Ask for news (Hỏi tin)", "about:Ask about someone (Hỏi về người)", "gift:Give a gift (Tặng lễ)", "work:Ask for work (Xin việc)"]],
	["Favours", ["teach:Ask for teaching (Thỉnh giáo)", "help:Ask for help (Nhờ giúp)", "trade:Trade (Giao dịch)"]],
	["Conflict", ["spar:Spar (Luận bàn)", "threaten:Threaten (Uy hiếp)", "provoke:Provoke (Khiêu khích)"]],
	["Bonds", ["companion:Recruit a companion", "disciple:Take a disciple", "brotherhood:Swear brotherhood (kết nghĩa)", "dao_lu:Seek Dao companionship (đạo lữ)"]],
]

var _view: Dictionary = {}
var _opener: Control = null
var _title := Label.new()
var _close := Button.new()
var _name := Label.new()
var _standing := Label.new()
var _numbers := Label.new()
var _scroll := ScrollContainer.new()
var _body := VBoxContainer.new()
var _reply := Label.new()
var _bar := HBoxContainer.new()
var _verbs_heading: Control = null
var _locked: bool = false


func _init() -> void:
	visible = false
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	add_child(box)
	# P1 frame
	var frame := HBoxContainer.new()
	box.add_child(frame)
	_title.text = tr("Person")
	_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	frame.add_child(_title)
	_close.text = "×"
	TooltipLayer.set_tip(_close, tr("Close (Esc)"))
	_close.pressed.connect(close_panel)
	frame.add_child(_close)
	# P2 sticky header
	_name.add_theme_font_size_override("font_size", 20)
	box.add_child(_name)
	_standing.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(_standing)
	box.add_child(_numbers)
	box.add_child(HSeparator.new())
	# P3 body
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(_scroll)
	_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_scroll.add_child(_body)
	# P4 reply strip
	_reply.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_reply.visible = false
	_reply.modulate = Color(1.0, 0.92, 0.7)
	box.add_child(_reply)
	# P5 action bar
	box.add_child(HSeparator.new())
	box.add_child(_bar)


## Shows [param view] (a [method GameQuery.person] copy); [param locked] marks look-only (an event waits);
## [param opener] gets focus back on close.
func open_person(view: Dictionary, locked: bool, opener: Control) -> void:
	_view = view
	_locked = locked
	_opener = opener
	_reply.visible = false
	_build()
	visible = true
	_close.grab_focus.call_deferred()


## Shows the reply to a verb in the reply strip.
func show_reply(lines: Array) -> void:
	_reply.text = "\n".join(lines.slice(0, 4).map(func(l): return str(l)))
	_reply.visible = not lines.is_empty()


## The person shown ("" when closed).
func person_id() -> String:
	return str(_view.get("id", "")) if visible else ""


## Scrolls to the verb list and focuses its first live verb (the Verbs button, V).
func jump_to_verbs() -> void:
	if _verbs_heading == null:
		return
	_scroll.scroll_vertical = int(_verbs_heading.position.y)
	var first: Control = _verbs_heading.get_meta(&"first_verb", null)
	if first != null:
		first.grab_focus()


func close_panel() -> void:
	if not visible:
		return
	visible = false
	if _opener != null and is_instance_valid(_opener):
		_opener.grab_focus()
	closed.emit()


func _build() -> void:
	var v: Dictionary = _view
	_name.text = str(v.get("name", ""))
	LinkStyle.apply(_name, "person", _relation(), "paper")
	var standing: Array = [str(v.get("realm_label", ""))]
	if str(v.get("sect", "")) != "":
		standing.append(str(v.sect) + ((", " + str(v.rank)) if str(v.get("rank", "")) != "" else ""))
	else:
		standing.append(tr("loose cultivator (tán tu)"))
	_standing.text = " · ".join(standing)
	var att: String = tr("not met") if not bool(v.get("met", false)) else "%s %+d" % [str(v.get("band", "")), int(v.get("attitude", 0))]
	_numbers.text = "%s     %s %s" % [str(v.get("power", "")), tr("Attitude:"), att]
	for c in _body.get_children():
		_body.remove_child(c)
		c.queue_free()
	for c in _bar.get_children():
		_bar.remove_child(c)
		c.queue_free()
	if not bool(v.get("alive", true)):
		_section(tr("DIED"), [tr("Died: %s") % str(v.get("death_cause", "")), tr("The sheet below is as at death.")])
	_section(tr("MADE OF"), [])
	_row(tr("Linh căn"), str(v.get("linh_can", "")))
	for st in Array(v.get("stats", [])):
		_row(str(st.label), HudReadouts.stones_text(float(st.value)) if float(st.value) >= 10.0 else "%.2f" % float(st.value))
	var techs: Array = Array(v.get("techniques", []))
	if techs.is_empty():
		_row(tr("Công pháp"), tr("none"))
	for t in techs:
		_row(tr("Công pháp") + (" (%s)" % str(t.slot) if str(t.slot) != "" else ""), "%s  L%d/%d" % [str(t.name), int(t.layer), int(t.layers)])
	_section(tr("CHARACTER AND TIES"), [])
	var traits: Array = Array(v.get("traits", []))
	if traits.is_empty():
		_row(tr("Traits"), tr("none"))
	for t in traits:
		_row(tr("Trait") + " (%s)" % str(t.group), str(t.name) + ((" (%s)" % str(t.name_vi)) if str(t.get("name_vi", "")) != "" else ""))
	var ties: Array = Array(v.get("ties", []))
	if ties.is_empty():
		_row(tr("Ties"), tr("none"))
	for t in ties:
		var b := LinkButton.new()
		b.text = str(t.partner)
		LinkStyle.apply(b, "person", "", "paper")
		var pid: String = str(t.partner_id)
		b.pressed.connect(func(): person_requested.emit(pid))
		var row := HBoxContainer.new()
		var l := Label.new()
		l.text = ", ".join(Array(t.kinds)) + ":"
		l.custom_minimum_size = Vector2(150, 0)
		row.add_child(l)
		row.add_child(b)
		_body.add_child(row)
	_verbs_heading = _section(tr("VERBS"), [tr("look-only: an event waits") if _locked else ""])
	var here: bool = bool(v.get("here", false)) and bool(v.get("alive", true)) and not bool(v.get("is_beast", false))
	var first: Control = null
	for group in VERBS:
		var gl := Label.new()
		gl.text = "  " + tr(str(group[0]))
		gl.modulate = Color(0.8, 0.8, 0.8)
		_body.add_child(gl)
		for entry in group[1]:
			var parts: PackedStringArray = str(entry).split(":", true, 1)
			var b := Button.new()
			b.alignment = HORIZONTAL_ALIGNMENT_LEFT
			b.custom_minimum_size = Vector2(0, 32)
			var reason: String = ""
			if bool(v.get("is_player", false)):
				reason = tr("that is you")
			elif not here:
				reason = tr("not here: %s") % str(v.get("place", "?"))
			elif _locked:
				reason = tr("locked while an event waits (look only)")
			elif parts[0] != "greet":
				reason = tr("not in the game yet (the verb system is designed, not built)")
			b.text = "    " + tr(parts[1]) + ("   v " + tr("will accept") if reason == "" else "   — " + reason)
			b.disabled = reason != ""
			var vid: String = parts[0]
			b.pressed.connect(func(): verb_requested.emit(str(_view.id), vid))
			_body.add_child(b)
			if first == null and not b.disabled:
				first = b
	if first != null:
		_verbs_heading.set_meta(&"first_verb", first)
	_section(tr("MORE"), [])
	_row(tr("Where"), str(v.get("place", "")) + ("  (" + tr("here") + ")" if bool(v.get("here", false)) else ""))
	_row(tr("Home"), str(v.get("home", "")) if str(v.get("home", "")) != "" else tr("none"))
	_row(tr("Age"), "%d" % int(v.get("age", 0)))
	_row(tr("Archetype"), str(v.get("archetype", "")))
	for t in Array(v.get("talents", [])):
		_row(str(t.label), "%d" % int(t.value))
	var hist: Array = Array(v.get("history", []))
	_section(tr("RECENT HISTORY"), hist if not hist.is_empty() else [tr("none")])
	# The pinned action bar.
	var verbs := Button.new()
	verbs.text = tr("Verbs (V)")
	verbs.pressed.connect(jump_to_verbs)
	_bar.add_child(verbs)
	if bool(v.get("alive", true)) and not bool(v.get("is_player", false)) and not bool(v.get("is_beast", false)):
		var fight := Button.new()
		fight.text = tr("Practice fight")
		TooltipLayer.set_tip(fight, tr("Watch a practice fight with this person on the fight screen. It changes nothing: a preview of how a fight would go."))
		fight.pressed.connect(func(): fight_requested.emit(str(_view.id)))
		_bar.add_child(fight)
	if not bool(v.get("here", false)) and str(v.get("place_id", "")) != "" and bool(v.get("alive", true)):
		var travel := Button.new()
		travel.text = tr("Travel there")
		travel.pressed.connect(func(): travel_requested.emit(str(_view.place_id)))
		_bar.add_child(travel)


func _relation() -> String:
	var a: int = int(_view.get("attitude", 0))
	return "friend" if a >= 30 else ("hostile" if a <= -30 else "neutral")


func _section(title: String, lines: Array) -> Control:
	var h := Label.new()
	h.text = title
	h.add_theme_font_size_override("font_size", 14)
	h.theme_type_variation = &"RowLabel"   # gilt section caps on parchment (art bible 7.11)
	h.focus_mode = Control.FOCUS_ALL
	_body.add_child(h)
	for line in lines:
		if str(line) == "":
			continue
		var l := Label.new()
		l.text = "  " + str(line)
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.custom_minimum_size = Vector2(300, 0)
		_body.add_child(l)
	return h


func _row(label: String, value: String) -> void:
	var row := HBoxContainer.new()
	var l := Label.new()
	l.text = "  " + label
	l.custom_minimum_size = Vector2(150, 0)
	row.add_child(l)
	var val := Label.new()
	val.text = value
	val.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	val.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(val)
	_body.add_child(row)
