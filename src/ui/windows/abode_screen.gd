class_name AbodeScreen
extends GameWindow
## The abode screen (design/ux/abode-screen.md; cave-abode.md UI Requirements): the home's grade, slots, upkeep or rent,
## the next grade and Raise, each work's level, effective level, gain and state with Raise / Sleep / Wake, the clamp
## lines, the home-work catalogue with Build; with no home, residences to rent here and a claimable abode. Shown in a
## [FullScreenHost] (it replaces the map; Z1 stays). Built from [method GameQuery.abode]; commands through
## [signal GameWindow.action_requested] (raise_abode, build_work, formation_build, abode_sleep, take_residence,
## claim_abode).

const ELEMENTS := [["kim", "Kim 金"], ["moc", "Mộc 木"], ["thuy", "Thủy 水"], ["hoa", "Hỏa 火"], ["tho", "Thổ 土"]]

var _armed: Dictionary = {}     # {action, args, text}
var _element_for: String = ""   # the share work whose element chooser is open ("" when none)


func kind() -> String:
	return "abode"


func window_title(v: Dictionary) -> String:
	return tr("Abode") + ((": " + str(v.home_place.name)) if bool(v.get("has_home", false)) else "")


## The armed confirm's action ("" when none), for tests.
func armed() -> String:
	return str(_armed.get("action", ""))


func cancel_inline() -> bool:
	if not _armed.is_empty():
		_armed = {}
	elif _element_for != "":
		_element_for = ""
	else:
		return false
	_rebuild()
	return true


func _rebuild() -> void:
	var y: int = scroll.scroll_vertical
	super.show_view(view, "", locked)
	scroll.set_deferred("scroll_vertical", y)


func _away_reason() -> String:
	if locked:
		return tr("locked while an event waits")
	if bool(view.get("has_home", false)) and not bool(view.get("here", false)):
		return tr("you are away: travel home to change it")
	return ""


func _build() -> void:
	var v: Dictionary = view
	var head := Label.new()
	head.theme_type_variation = &"HeadingLabel"
	head.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	header.add_child(head)
	if not bool(v.get("has_home", false)):
		head.text = tr("You have no home yet.")
		_build_no_home(v)
		return
	var ab: bool = str(v.get("kind", "")) == "abode"
	head.text = "%s · %s" % [str(v.home_place.name), tr("cave abode (động phủ)") if ab else (tr("starting room") if bool(v.get("origin", false)) else tr("residence"))]
	var line1 := Label.new()
	var cost_txt: String = ""
	if ab:
		cost_txt = " · " + tr("upkeep %s linh thạch a season") % HudReadouts.stones_text(float(v.upkeep))
	elif int(v.get("rent_paid", 0)) > 0:
		cost_txt = " · " + tr("rent %s linh thạch a season") % HudReadouts.stones_text(float(v.rent_paid))
	line1.text = tr("Grade %d · %d of %d slots") % [int(v.grade), int(v.used), int(v.slots)] + cost_txt + \
		((" · " + tr("raising to grade %d (next season)") % int(v.pending)) if int(v.get("pending", 0)) > 0 else "")
	line1.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	TooltipLayer.set_tip(line1, {"title": tr("Grade and slots"), "summary": tr("Each work takes one slot; the grade sets the slots and the highest level a work counts at. A cave abode pays grade upkeep each season; three unpaid seasons drop it a grade (grade 1 never falls).")})
	header.add_child(line1)
	if int(v.get("unpaid", 0)) > 0:
		var warn := Label.new()
		warn.text = "⚠ " + tr("Upkeep unpaid for %d season(s): the abode falls a grade if it stays unpaid.") % int(v.unpaid)
		warn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		header.add_child(warn)
	var where := Label.new()
	where.text = tr("You are here.") if bool(v.get("here", false)) else ("🔒 " + tr("You are away (at %s): changes need you here.") % str(v.get("at", "")))
	where.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	header.add_child(where)
	# Home
	section("home", tr("Home"))
	var nx: Dictionary = v.get("next", {})
	if not ab:
		line(tr("A residence's grade is fixed: rent or buy a better one, or open a cave abode."))
	elif nx.is_empty():
		line(tr("The highest grade."))
	else:
		line(tr("Next grade %d: %s linh thạch, %d slots, a season's work%s.") % [int(nx.grade), HudReadouts.stones_text(float(nx.cost)), int(nx.slots),
			"" if bool(nx.realm_ok) else " (" + tr("needs a higher realm") + ")"])
		if str(_armed.get("action", "")) == "raise_abode":
			_confirm_rows()
		else:
			var why: String = _away_reason()
			if why == "" and not bool(nx.realm_ok):
				why = tr("needs a higher realm")
			if why == "" and int(v.get("pending", 0)) > 0:
				why = tr("already being raised")
			_act(tr("Raise to grade %d…") % int(nx.grade), body, why, {"action": "raise_abode", "args": [],
				"text": tr("Raise the abode to grade %d? %s linh thạch now; it takes effect next season.") % [int(nx.grade), HudReadouts.stones_text(float(nx.cost))]}).name = "RaiseGrade"
	var dens: Dictionary = v.get("density", {})
	var dl := row(tr("Density at home"), num(float(dens.get("total", 0.0))) + ((" (" + tr("works add %s") % num(float(dens.works)) + ")") if float(dens.get("works", 0.0)) > 0.0 else ""),
		{"title": tr("Density at home"), "fact": num(float(dens.get("total", 0.0))), "summary": tr("What you cultivate at there; the lines are the home works' layer."), "lines": Array(dens.get("lines", []))})
	dl.name = "Density"
	var leave := Button.new()
	leave.name = "Leave"
	leave.text = tr("Leave this home")
	leave.disabled = true
	leave.accessibility_name = tr("Leave this home: not in the game yet")
	TooltipLayer.set_tip(leave, {"title": tr("Leave this home"), "summary": tr("Not in the game yet: a home is left when you open, claim or rent another (cave-abode.md rule 10).")})
	leave.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	body.add_child(leave)
	# Works
	var works: Array = Array(v.get("works", []))
	section("works", tr("Works (%d)") % works.size())
	if works.any(func(w): return bool(w.dormant)):
		line("⚠ " + tr("A slot is short, so a work sleeps. Choose which one sleeps with Sleep / Wake (the latest built sleeps by default)."))
	if works.is_empty():
		line(tr("none yet: build one below"))
	for w in works:
		_work_row(w)
	# Clamps
	section("clamps", tr("Clamps"))
	var clamps: Array = Array(v.get("clamps", []))
	if clamps.is_empty():
		line(tr("none: no cap holds a gain back"))
	for c in clamps:
		line("  " + str(c))
	# Build a work
	section("build", tr("Build a work"))
	var cat: Array = Array(v.get("catalogue", []))
	if cat.is_empty():
		line(tr("Every home work is built."))
	for c in cat:
		_catalogue_row(c)
	if not Array(v.get("rent", [])).is_empty():
		_build_rent(v)
	if not (v.get("claim", {}) as Dictionary).is_empty():
		_build_claim(v)


func _work_row(w: Dictionary) -> void:
	var box := VBoxContainer.new()
	box.name = "Work_" + str(w.id)
	body.add_child(box)
	var state: String = ""
	if bool(w.dormant):
		state = tr("dormant: gives nothing")
	elif int(w.eff) < int(w.level):
		state = tr("counts at %d: the grade's ceiling") % int(w.eff)
	var l := Label.new()
	l.text = "  %s  ·  %s  ·  %s%s%s" % [str(w.name), tr("level %d / %d") % [int(w.level), int(w.max)], str(w.gain) if str(w.gain) != "" else tr("nothing"),
		("  ·  " + state) if state != "" else "", ("  ·  " + tr("upkeep %d") % int(w.upkeep)) if int(w.get("upkeep", 0)) > 0 else ""]
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.accessibility_name = l.text.strip_edges()
	box.add_child(l)
	var row2 := HBoxContainer.new()
	box.add_child(row2)
	var why: String = _away_reason()
	if int(w.level) < int(w.max):
		var nc: Dictionary = w.get("next_cost", {})
		var action: String = "build_work" if str(w.kind) == "work" else "formation_build"
		var args: Array = [str(w.id), str(w.get("element", ""))] if str(w.kind) == "work" else [str(w.id)]
		var cost_text: String = (tr("%s linh thạch, %d material(s), %d season(s)") % [HudReadouts.stones_text(float(nc.get("lt", 0))), int(nc.get("materials", 0)), int(nc.get("seasons", 0))]) if not nc.is_empty() else tr("its array cost")
		if str(_armed.get("key", "")) == "raise:" + str(w.id):
			_confirm_rows()
		else:
			_act(tr("Raise to level %d…") % (int(w.level) + 1), row2, why, {"action": action, "args": args, "key": "raise:" + str(w.id),
				"text": tr("Raise %s to level %d? %s.") % [str(w.name), int(w.level) + 1, cost_text]}).name = "Raise_" + str(w.id)
	var sleep := Button.new()
	sleep.name = ("Wake_" if bool(w.dormant) else "Sleep_") + str(w.id)
	sleep.text = tr("Wake") if bool(w.dormant) else tr("Sleep")
	var any_dormant: bool = Array(view.get("works", [])).any(func(x): return bool(x.dormant))
	var swhy: String = why if why != "" else ("" if any_dormant else tr("only while a slot is short (rule 9)"))
	sleep.disabled = swhy != ""
	sleep.accessibility_name = sleep.text + " " + str(w.name) + ((": " + swhy) if swhy != "" else "")
	if swhy != "":
		TooltipLayer.set_tip(sleep, {"title": sleep.text, "summary": swhy})
	var key: String = str(w.key)
	if bool(w.dormant):
		# waking this one puts the latest built active one to sleep (CaveAbode.sleep: a swap)
		var active: Array = Array(view.get("works", [])).filter(func(x): return not bool(x.dormant))
		var to_sleep: String = str(active[-1].id) if not active.is_empty() else ""
		var wake_id: String = str(w.id)
		sleep.pressed.connect(func(): action_requested.emit("abode_sleep", [to_sleep, wake_id]))
	else:
		var sleep_id: String = str(w.id)
		sleep.pressed.connect(func(): action_requested.emit("abode_sleep", [sleep_id, ""]))
	row2.add_child(sleep)


func _catalogue_row(c: Dictionary) -> void:
	var box := VBoxContainer.new()
	box.name = "Cat_" + str(c.id)
	body.add_child(box)
	var nc: Dictionary = c.get("next_cost", {})
	var l := Label.new()
	l.text = "  %s  ·  %s %s  ·  %s  ·  %s" % [str(c.name), str(c.gain), tr("per level"),
		tr("%s linh thạch, %d material(s), %d season(s)") % [HudReadouts.stones_text(float(nc.get("lt", 0))), int(nc.get("materials", 0)), int(nc.get("seasons", 0))],
		tr("max %d, counts up to %d here") % [int(c.max), int(c.ceiling)]] + ((" · " + tr("upkeep %d") % int(c.upkeep)) if int(c.get("upkeep", 0)) > 0 else "")
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(l)
	var why: String = _away_reason()
	if why == "" and not bool(c.get("ok", true)):
		why = str(c.reason)
	if _element_for == str(c.id):
		var ch := HFlowContainer.new()
		ch.name = "ElementChooser"
		box.add_child(ch)
		for e in ELEMENTS:
			var b := Button.new()
			b.name = "Element_" + str(e[0])
			b.text = str(e[1])
			b.pressed.connect(_arm.bind({"action": "build_work", "args": [str(c.id), str(e[0])], "key": "build:" + str(c.id),
				"text": tr("Build %s pushing %s? %s linh thạch.") % [str(c.name), str(e[1]), HudReadouts.stones_text(float(nc.get("lt", 0)))]}))
			ch.add_child(b)
		focus_later(ch.get_child(0))
	elif str(_armed.get("key", "")) == "build:" + str(c.id):
		_confirm_rows()
	else:
		var row2 := HBoxContainer.new()
		box.add_child(row2)
		var b := _act(tr("Build…"), row2, why, {"action": "build_work", "args": [str(c.id), ""], "key": "build:" + str(c.id),
			"text": tr("Build %s? %s linh thạch, %d material(s).") % [str(c.name), HudReadouts.stones_text(float(nc.get("lt", 0))), int(nc.get("materials", 0))]})
		b.name = "Build_" + str(c.id)
		if bool(c.get("share", false)) and why == "":
			# a share work asks for its element first (cave-abode.md UI Requirements: the work picker)
			for cn in b.pressed.get_connections():
				b.pressed.disconnect(cn.callable)
			b.pressed.connect(_open_elements.bind(str(c.id)))


func _build_no_home(v: Dictionary) -> void:
	_build_rent(v)
	section("open", tr("Open a cave abode"))
	line(tr("A cave abode is opened on a wilderness tile: travel there and pay the opening fee (a season). Choosing the tile on the map is not in the screens yet."))
	_build_claim(v)


func _build_rent(v: Dictionary) -> void:
	section("rent", tr("Rent here"))
	var rent: Array = Array(v.get("rent", []))
	if rent.is_empty():
		line(tr("No residences here: they are let in settlements and sect grounds."))
	for r in rent:
		var box := HBoxContainer.new()
		body.add_child(box)
		var l := Label.new()
		l.text = "  " + tr("Grade %d · %d slots · rent %s a season · buy %s") % [int(r.grade), int(r.slots), HudReadouts.stones_text(float(r.rent)), HudReadouts.stones_text(float(r.price))] + \
			("" if bool(r.realm_ok) else "  (" + tr("needs %s") % str(r.realm_need) + ")")
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		box.add_child(l)
		var why: String = "" if bool(r.realm_ok) else tr("needs %s") % str(r.realm_need)
		if locked:
			why = tr("locked while an event waits")
		var key: String = "rent:%d" % int(r.grade)
		if str(_armed.get("key", "")).begins_with(key):
			_confirm_rows()
		else:
			_act(tr("Rent"), box, why, {"action": "take_residence", "args": [int(r.grade), false], "key": key + ":r",
				"text": tr("Rent a grade %d residence here for %s linh thạch a season? It becomes your home; your current home is left.") % [int(r.grade), HudReadouts.stones_text(float(r.rent))]})
			_act(tr("Buy"), box, why, {"action": "take_residence", "args": [int(r.grade), true], "key": key + ":b",
				"text": tr("Buy a grade %d residence here for %s linh thạch? It becomes your home; your current home is left.") % [int(r.grade), HudReadouts.stones_text(float(r.price))]})



func _build_claim(v: Dictionary) -> void:
	var cl: Dictionary = v.get("claim", {})
	if not cl.is_empty():
		section("claim", tr("Claim"))
		line(tr("A %s abode here: grade %d, back at grade %d; fee %s linh thạch.") % [tr("ruined") if str(cl.state) == "ruin" else tr("left"), int(cl.grade), int(cl.after), HudReadouts.stones_text(float(cl.fee))])
		var kept: Array = Array(cl.get("works", []))
		line(tr("Works kept: %s") % (", ".join(kept.map(func(k): return "%s %d%s" % [str(k.name), int(k.level), (" (" + tr("upkept: if not faded") + ")") if bool(k.upkept) else ""])) if not kept.is_empty() else tr("none")))
		if str(_armed.get("action", "")) == "claim_abode":
			_confirm_rows()
		else:
			_act(tr("Claim…"), body, tr("locked while an event waits") if locked else "", {"action": "claim_abode", "args": [],
				"text": tr("Claim it for %s linh thạch and a season? It becomes your home.") % HudReadouts.stones_text(float(cl.fee))}).name = "Claim"


## A button that arms [param confirm] ({action, args, text, key}); disabled with [param why].
func _act(text: String, parent: Control, why: String, confirm: Dictionary) -> Button:
	var b := Button.new()
	b.text = ("🔒 " if why != "" and (locked or why.begins_with(tr("you are away"))) else "") + text + ((" — " + why) if why != "" and not locked else "")
	b.disabled = why != ""
	b.accessibility_name = text + ((": " + why) if why != "" else "")
	if why != "":
		TooltipLayer.set_tip(b, {"title": text, "summary": why})
	b.pressed.connect(_arm.bind(confirm))
	b.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN   # buttons keep their own width in the column
	parent.add_child(b)
	return b


func _arm(confirm: Dictionary) -> void:
	_armed = confirm
	_element_for = ""
	_rebuild()


func _confirm_rows() -> void:
	var ask := line("  " + str(_armed.text))
	ask.accessibility_name = str(_armed.text) + " " + tr("Confirm or Cancel")
	var r := HBoxContainer.new()
	body.add_child(r)
	var ok := Button.new()
	ok.name = "Confirm"
	ok.text = tr("Confirm")
	ok.theme_type_variation = &"CommitButton"
	ok.pressed.connect(_confirm)
	r.add_child(ok)
	var cancel := Button.new()
	cancel.name = "Cancel"
	cancel.text = tr("Cancel")
	cancel.pressed.connect(cancel_inline)
	r.add_child(cancel)
	focus_later(cancel)


func _confirm() -> void:
	var a: Dictionary = _armed
	_armed = {}
	action_requested.emit(str(a.action), Array(a.args))


func _open_elements(work_id: String) -> void:
	_element_for = work_id
	_rebuild()


## A sample view for screenshot evidence and tests (AC-CA-21: a grade-3 abode with a dormant work and a clamped cap).
## It is display data only: nothing reads or changes the session.
static func sample_view() -> Dictionary:
	return {"has_home": true, "here": true, "home_place": {"id": "pl_fix", "name": "Thanh Phong Cốc"}, "at": "Thanh Phong Cốc", "event_waiting": false,
		"kind": "abode", "grade": 3, "slots": 3, "used": 3, "upkeep": 40, "rent_paid": 0, "origin": false, "pending": 0, "unpaid": 0,
		"next": {"grade": 4, "cost": 4800, "slots": 4, "realm_ok": false},
		"works": [
			{"key": "w:tended_abode", "id": "tended_abode", "kind": "work", "name": "Dưỡng động phủ", "level": 3, "max": 3, "eff": 3, "dormant": false, "stat": "density", "share": false, "gain": "+0.06 density", "upkeep": 0, "element": "", "next_cost": {}},
			{"key": "f:tu_linh", "id": "tu_linh", "kind": "array", "name": "Tụ Linh Trận", "level": 5, "max": 5, "eff": 4, "dormant": false, "stat": "home_array_density", "share": false, "gain": "+0.60 home array density", "upkeep": 0, "element": "", "next_cost": {}},
			{"key": "w:focus_array", "id": "focus_array", "kind": "work", "name": "Tụ nguyên trận", "level": 3, "max": 5, "eff": 3, "dormant": false, "stat": "share", "share": true, "gain": "+12 share", "upkeep": 3, "element": "hoa", "next_cost": {"lt": 1250, "materials": 1, "seasons": 0}},
			{"key": "w:private_spring", "id": "private_spring", "kind": "work", "name": "Linh tuyền", "level": 2, "max": 3, "eff": 0, "dormant": true, "stat": "share", "share": true, "gain": "", "upkeep": 0, "element": "thuy", "next_cost": {"lt": 1200, "materials": 1, "seasons": 1}}],
		"clamps": ["layer-1 upkept density 0.85 clamped at 0.75 (c1u)"],
		"density": {"total": 1.85, "lines": ["density = 1.85", "  base 1.10", "  layer 1 +0.75 (clamped at 0.75)"]},
		"catalogue": [], "rent": [], "claim": {}}
