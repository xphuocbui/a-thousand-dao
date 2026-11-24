class_name SectWindow
extends GameWindow
## The sect window (design/ux/sect-window.md) in the window host. Member view: rank, contribution and standing, the
## ladder, the next rank's gate as a checklist, Promote (confirm in place), the sect's facts, other sects' standing,
## Leave on good terms or Desert (each confirm names its consequence). Loose view: the sect seated here with the join
## checklist and Join, other sects, the great sects. Built from [method GameQuery.sect]; actions through
## [signal GameWindow.action_requested] ("promote", "join_sect", "leave_sect").
## Laid out as the approved round-3 mock-up (prototypes/ui-mood/out/r3-sect-l.png, user 2026-11-24): the sect's own
## place painting as a hero banner with its name, the head's portrait beside the facts as icon tiles, the notable
## members as portrait medallions, then each section as a parchment inset on the dark wood ground.

var _armed: String = ""   # "promote", "join", "leave", "desert": the confirm row shown
var _g: VBoxContainer = null      # the wood ground of this build
var _into: Control = null         # the inset the builders write into


func kind() -> String:
	return "sect"


func window_title(v: Dictionary) -> String:
	return tr("Sect") + ((": " + str(v.sect.name)) if not (v.get("sect", {}) as Dictionary).is_empty() else "")


## The armed confirm ("" when none), for tests.
func armed() -> String:
	return _armed


func cancel_inline() -> bool:
	if _armed == "":
		return false
	_armed = ""
	_rebuild()
	return true


func show_view(v: Dictionary, section: String, is_locked: bool) -> void:
	if str(v.get("sect", {}).get("id", "")) != str(view.get("sect", {}).get("id", "-")):
		_armed = ""
	super.show_view(v, section, is_locked)


func _sec(key: String, title: String) -> void:
	_into = section_in(_g, key, title)


func _ln(text: String) -> Label:
	return line(text, _into)


func _rw(label: String, value: String) -> void:
	row(label, value, null, _into)


func _rebuild() -> void:
	var y: int = scroll.scroll_vertical
	super.show_view(view, "", locked)
	scroll.set_deferred("scroll_vertical", y)


func _build() -> void:
	var v: Dictionary = view
	var sc: Dictionary = v.get("sect", {})
	var mode: String = str(v.get("mode", "loose"))
	var top := Label.new()
	top.theme_type_variation = &"HeadingLabel"
	top.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if sc.is_empty():   # with a sect the banner carries its name and the block under it the kind
		top.text = tr("Loose cultivator (tán tu)")
		header.add_child(top)
	else:
		top.free()
	var you := Label.new()
	you.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if mode == "member":
		var y: Dictionary = v.you
		you.text = tr("You: %s · contribution %s · standing %d%s") % [str(y.rank_name), HudReadouts.stones_text(float(y.contribution)), int(y.standing), ("  (" + tr("hostile") + ")") if bool(y.hostile) else ""]
		TooltipLayer.set_tip(you, {"title": tr("Contribution and standing"), "summary": tr("Contribution (cống hiến) is earned by sect duties and missions and buys ranks. Standing (−100 to 100) is how the sect regards you; deeds move it; at %d or below it treats you as hostile.") % int(view.get("leave_preview", {}).get("hostile_threshold", -30))})
	elif mode == "loose":
		you.text = tr("You belong to no sect (tán tu).")
	else:
		you.text = tr("You are not of this sect.") + ((" " + tr("Its standing with you: %d") % int(v.join.standing)) if v.get("join", {}).has("standing") else "")
	header.add_child(you)
	_g = Illustrated.ground(body)
	_into = _g
	if not sc.is_empty():
		_build_hero(sc)
	if str(sc.get("status", "active")) == "fallen":
		_sec("fallen", tr("Fallen"))
		_ln(tr("Fell in year %d: %s") % [int(sc.fell_year), str(sc.cause)])
	if mode == "member":
		_build_place(v)
	if mode != "member" and not (v.get("join", {}) as Dictionary).is_empty():
		_build_join(v)
	elif mode == "loose":
		_sec("here", tr("Sect here"))
		_ln(tr("No sect has its seat here. Sects recruit only at their seat."))
	if not sc.is_empty():
		_build_facts(sc)
	_sec("others", tr("Other sects"))
	var others: Array = Array(v.get("others", []))
	if others.is_empty():
		_ln(tr("none: no other sect has a standing with you yet"))
	for o in others:
		_link_row(str(o.name), "sect", str(o.id), tr("standing %d") % int(o.standing) + (("  (" + tr("hostile") + ")") if bool(o.hostile) else ""))
	if mode == "loose":
		_sec("great", tr("Great sects"))
		for g in Array(v.get("great", [])):
			_link_row(str(g.name), "sect", str(g.id), " · ".join([tr("seat %s") % str(g.seat) if str(g.seat) != "" else "", str(g.region), str(g.alignment)].filter(func(x): return str(x) != "")))
	if mode == "member":
		_sec("services", tr("Services"))
		_ln(tr("Services bought with contribution (residence, treasure loans, teaching) are not in the game yet."))
		_build_leave()
	bar_open(tr("Character"), "character")
	bar_open(tr("Places"), "places")


func _build_place(v: Dictionary) -> void:
	_sec("place", tr("Your place"))
	var ladder: Array = Array(v.get("ladder", []))
	_ln(tr("Ladder:") + " " + " · ".join(ladder.map(func(r): return ("▶ " if bool(r.current) else "") + str(r.name))))
	var nx: Dictionary = v.get("next", {})
	if bool(nx.get("top", false)):
		_ln(tr("You hold the highest rank."))
		return
	_ln(tr("Next: %s") % str(nx.get("rank_name", "")))
	if not bool(nx.get("reachable", false)):
		for m in Array(nx.get("missing", [])):
			_ln("   ✗ " + str(m))
		_ln("   " + tr("(The head's trial is not in the game yet.)"))
		return
	var all_met: bool = true
	for g in Array(nx.get("gate", [])):
		all_met = all_met and bool(g.met)
		var l := _ln("   %s %s %s of %s — %s" % ["✓" if bool(g.met) else "✗", tr(str(g.label)), str(g.have), str(g.need), tr("met") if bool(g.met) else tr("not met")])
		l.accessibility_name = "%s %s of %s, %s" % [tr(str(g.label)), str(g.have), str(g.need), tr("met") if bool(g.met) else tr("not met")]
	_ln(tr("Missions are a season focus: choose Mission in the turn to earn contribution."))
	var row := HBoxContainer.new()
	_into.add_child(row)
	if _armed == "promote" and not locked:
		_confirm_row(tr("Promote to %s? Spends %s contribution.") % [str(nx.rank_name), HudReadouts.stones_text(float(nx.cost))], "promote", [])
	else:
		var b := _arm_button(tr("Promote"), "promote", row, "" if all_met else "; ".join(Array(nx.get("missing", []))))
		b.name = "Promote"


func _build_join(v: Dictionary) -> void:
	var j: Dictionary = v.join
	_sec("here", tr("Sect here") if bool(j.get("here", false)) else tr("Joining"))
	_ln(tr("Its standing with you: %d") % int(j.get("standing", 0)))
	for r in Array(j.get("reasons", [])):
		_ln("   ✗ " + str(r))
	if bool(j.get("ok", false)):
		_ln("   ✓ " + tr("it would take you as an outer disciple"))
	var row := HBoxContainer.new()
	_into.add_child(row)
	if _armed == "join" and not locked:
		_confirm_row(tr("Join %s as an outer disciple? A sect asks duties of its members.") % str(v.sect.name), "join_sect", [str(v.sect.id)])
	else:
		var b := _arm_button(tr("Join"), "join", row, "" if bool(j.get("ok", false)) else tr("not now: see the reasons above"))
		b.name = "Join"


# The banner: the seat's painting (the place catalogue, assets/art/places) with the sect's name on a dark cartouche.
func _build_hero(sc: Dictionary) -> void:
	var art: Texture2D = PortraitPicker.place_painting(int(sc.get("seat_art", -1)))
	var hero: PanelContainer = Illustrated.framed(art, Vector2(0, 150 if compact else 220), str(sc.get("name", "")))
	hero.name = "Hero"
	_g.add_child(hero)
	var plate := PanelContainer.new()
	plate.add_theme_stylebox_override("panel", Illustrated.box(Color(0.06, 0.09, 0.07, 0.86), Illustrated.BRASS, 2, 10.0, 2))
	plate.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	plate.size_flags_vertical = Control.SIZE_SHRINK_END
	var pc := VBoxContainer.new()
	pc.add_theme_constant_override("separation", 0)
	plate.add_child(pc)
	var nm := Label.new()
	nm.text = str(sc.get("name", "")) + ((" " + str(sc.name_han)) if str(sc.get("name_han", "")) != "" else "")
	nm.theme_type_variation = &"TitleLabel"
	nm.add_theme_color_override("font_color", Illustrated.BONE)
	pc.add_child(nm)
	if str(sc.get("gloss", "")) != "":
		var gl := Label.new()
		gl.text = str(sc.gloss)
		gl.theme_type_variation = &"WoodLabel"
		pc.add_child(gl)
	var pad := MarginContainer.new()
	pad.add_theme_constant_override("margin_left", 18)
	pad.add_theme_constant_override("margin_bottom", 14)
	pad.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pad.add_child(plate)
	hero.add_child(pad)
	# the head's portrait beside the facts, then the notable members
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	_g.add_child(row)
	var head: Dictionary = sc.get("head", {})
	if str(head.get("id", "")) != "":
		var hp: PanelContainer = Illustrated.framed(PortraitPicker.texture_for(head.get("portrait", {})), Vector2(130, 165) if compact else Vector2(160, 200), "?")
		hp.name = "HeadPortrait"
		TooltipLayer.set_tip(hp, {"title": str(head.name), "fact": tr("Head of the sect") + " · " + str(head.get("realm_label", ""))})
		row.add_child(hp)
	var fc: VBoxContainer = Illustrated.inset(row, "")
	var kind_l := Label.new()
	kind_l.text = " · ".join([tr("Great sect") if str(sc.kind) == "great" else tr("Minor sect"), str(sc.alignment_name), str(sc.get("specialty_name", ""))].filter(func(x): return str(x) != ""))
	kind_l.theme_type_variation = &"HeadingLabel"
	kind_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	fc.add_child(kind_l)
	_into = fc
	if str(head.get("name", "")) != "":
		_link_row(tr("Head") + ": " + str(head.name), "person", str(head.id), str(head.get("realm_label", "")))
	if str(sc.seat.get("name", "")) != "":
		_link_row(tr("Seat") + ": " + str(sc.seat.name), "place", str(sc.seat.id), str(sc.get("region", "")))
	var tiles: GridContainer = Illustrated.grid(fc, 2 if compact else 4, 6)
	tiles.add_child(Illustrated.tile(null, tr("Founded"), tr("year %d") % int(sc.get("founded_year", 0)), "", 0.0))
	tiles.add_child(Illustrated.tile(null, tr("Members"), "%d" % int(sc.get("members", 0)), "", 0.0))
	tiles.add_child(Illustrated.tile(Illustrated.tex("res://assets/icons/hud/res_linh_thach.png"), tr("Treasury"), HudReadouts.stones_text(float(sc.get("treasury", 0))), "", 0.0))
	var regions: Array = Array(sc.get("regions", []))
	var holds: PanelContainer = Illustrated.tile(Illustrated.tex("res://assets/icons/hud/res_sect.png"), tr("Holds"), tr("%d regions") % regions.size(), "", 0.0)
	TooltipLayer.set_tip(holds, {"title": tr("Holds"), "summary": ", ".join(regions) if not regions.is_empty() else tr("no region")})
	tiles.add_child(holds)
	var notables: Array = Array(sc.get("notables", []))
	if not notables.is_empty():
		var nc: VBoxContainer = section_in(_g, "members", tr("Notable members"))
		var ng: GridContainer = Illustrated.grid(nc, 1 if compact else 2, 8)
		for m in notables:
			var mr := HBoxContainer.new()
			mr.add_theme_constant_override("separation", 10)
			mr.add_child(Illustrated.medallion(PortraitPicker.texture_for(m.get("portrait", {})), 56.0))
			var mc := VBoxContainer.new()
			mc.add_theme_constant_override("separation", 0)
			mc.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			mr.add_child(mc)
			var l := LinkButton.new()
			l.text = str(m.name)
			LinkStyle.apply(l, "person", "neutral", "paper")
			var pid: String = str(m.id)
			l.pressed.connect(func(): open_requested.emit("person", pid, ""))
			mc.add_child(l)
			var rk := Label.new()
			rk.text = " · ".join([str(m.get("rank", "")), str(m.get("realm_label", ""))].filter(func(x): return str(x) != ""))
			rk.theme_type_variation = &"RowLabel"
			mc.add_child(rk)
			ng.add_child(mr)
	_into = _g


func _build_facts(sc: Dictionary) -> void:
	_sec("facts", tr("The sect"))
	var levels: Dictionary = sc.get("levels", {})
	if not levels.is_empty():
		var parts: Array = []
		for k in levels:
			parts.append("%s %s" % [str(k), str(levels[k])])
		_rw(tr("Levels"), ", ".join(parts))
	var regions: Array = Array(sc.get("regions", []))
	_rw(tr("Holds"), (tr("%d regions: ") % regions.size() + ", ".join(regions)) if not regions.is_empty() else tr("no region"))
	if str(sc.liege.get("name", "")) != "":
		_link_row(tr("Liege") + ": " + str(sc.liege.name), "sect", str(sc.liege.id), "")


func _build_leave() -> void:
	_sec("leave", tr("Leaving"))
	var lp: Dictionary = view.get("leave_preview", {})
	_ln(tr("Either way you leave your rank; your standing with the sect stays as it is when you leave on good terms."))
	if _armed == "leave" and not locked:
		_confirm_row(tr("Leave on good terms? You lose your rank; the sect's standing with you stays at %d.") % int(lp.get("standing_now", 0)), "leave_sect", [false])
	elif _armed == "desert" and not locked:
		_confirm_row(tr("Desert? The sect's standing with you falls from %d to %d%s.") % [int(lp.get("standing_now", 0)), int(lp.get("desert_standing", 0)),
			(" " + tr("and it will treat you as hostile")) if bool(lp.get("desert_hostile", false)) else ""], "leave_sect", [true])
	else:
		var row := HBoxContainer.new()
		_into.add_child(row)
		_arm_button(tr("Leave on good terms…"), "leave", row, "").name = "Leave"
		_arm_button(tr("Desert…"), "desert", row, "").name = "Desert"


func _arm_button(text: String, what: String, parent: Control, reason: String) -> Button:
	var b := Button.new()
	var why: String = reason
	if locked:
		why = tr("locked while an event waits")
	b.text = ("🔒 " if locked else "") + text + ((" — " + why) if why != "" and not locked else "")
	b.disabled = why != ""
	b.accessibility_name = text + ((": " + why) if why != "" else "")
	if why != "":
		TooltipLayer.set_tip(b, {"title": text, "summary": why})
	b.pressed.connect(_arm.bind(what))
	parent.add_child(b)
	return b


func _arm(what: String) -> void:
	_armed = what
	_rebuild()


func _confirm_row(text: String, action: String, args: Array) -> void:
	var ask := _ln("  " + text)
	ask.accessibility_name = text + " " + tr("Confirm or Cancel")
	var row := HBoxContainer.new()
	_into.add_child(row)
	var ok := Button.new()
	ok.name = "Confirm"
	ok.text = tr("Confirm")
	ok.theme_type_variation = &"CommitButton"
	ok.pressed.connect(_confirm.bind(action, args))
	row.add_child(ok)
	var cancel := Button.new()
	cancel.name = "Cancel"
	cancel.text = tr("Cancel")
	cancel.pressed.connect(cancel_inline)
	row.add_child(cancel)
	focus_later(cancel)


func _confirm(action: String, args: Array) -> void:
	_armed = ""
	action_requested.emit(action, args)


func _link_row(text: String, target: String, id: String, rest: String) -> void:
	var r := HBoxContainer.new()
	_into.add_child(r)
	var l := LinkButton.new()
	l.text = text
	# on parchment a sect link uses the ink person style (the sect style's own colours are for the map, art bible 7.14)
	LinkStyle.apply(l, "person", "neutral", "paper")   # ink links on parchment (the place style is for the map)
	l.pressed.connect(func(): open_requested.emit(target, id, ""))
	r.add_child(l)
	if rest != "":
		var x := Label.new()
		x.text = "  " + rest
		x.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		x.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		r.add_child(x)
