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
	if not sc.is_empty():
		_build_notables(sc)
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
		_link_row(str(o.name), "sect", str(o.id), (("  (" + tr("hostile") + ")") if bool(o.hostile) else ""))
		_standing_meter(float(o.standing), _into)
	if mode == "loose":
		_sec("great", tr("Great sects"))
		_ln(tr("Sects recruit only at their seat: travel there to ask to join."))
		var cards: GridContainer = Illustrated.grid(_into, 1 if compact else 2, 10)
		for g in Array(v.get("great", [])):
			cards.add_child(_great_card(g))
	if not Array(v.get("teaching", [])).is_empty() and not (v.get("sect", {}) as Dictionary).is_empty():
		_build_teaching(v)
	if mode == "member":
		_sec("services", tr("Services"))
		_ln(tr("Services bought with contribution (residence, treasure loans, teaching) are not in the game yet."))
		_build_leave()
	bar_open(tr("Character"), "character")
	bar_open(tr("Places"), "places")
	# the one decision the player is here for, pinned in the bar: Join for an outsider, Promote for a member
	var jn: Dictionary = v.get("join", {})
	if mode != "member" and not jn.is_empty():
		bar_jump(tr("Join"), "here", "" if bool(jn.get("ok", false)) else tr("not now: see the reasons"))
	elif mode == "member":
		var nx: Dictionary = v.get("next", {}) if v.get("next") is Dictionary else {}
		if not nx.is_empty() and not bool(nx.get("top", false)):
			bar_jump(tr("Promote"), "place")


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
	kind_l.text = tr("Great sect") if str(sc.kind) == "great" else tr("Minor sect")
	kind_l.theme_type_variation = &"HeadingLabel"
	kind_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	fc.add_child(kind_l)
	_into = fc
	if str(head.get("name", "")) != "":
		_link_row(tr("Head") + ": " + str(head.name), "person", str(head.id), str(head.get("realm_label", "")))
	if str(sc.seat.get("name", "")) != "":
		_link_row(tr("Seat") + ": " + str(sc.seat.name), "place", str(sc.seat.id), str(sc.get("region", "")))
	var tiles: GridContainer = Illustrated.grid(fc, 2 if compact else 4, 6)
	# what a player choosing a sect needs first: its path and craft, then its size and wealth (weak-point review)
	var path_t: PanelContainer = Illustrated.tile(null, tr("Path"), str(sc.get("alignment_name", "")) if str(sc.get("alignment_name", "")) != "" else "—", "", 0.0)
	TooltipLayer.set_tip(path_t, {"title": tr("Path"), "summary": tr("Righteous (chính đạo), demonic (ma đạo) or neutral (trung lập): how the sect deals with the world.")})
	tiles.add_child(path_t)
	tiles.add_child(Illustrated.tile(null, tr("Craft"), str(sc.get("specialty_name", "")) if str(sc.get("specialty_name", "")) != "" else "—", "", 0.0))
	var members_t: PanelContainer = Illustrated.tile(Illustrated.tex("res://assets/icons/ui/sect_members.png"), tr("Members"), "%d" % int(sc.get("members", 0)),
		tr("since %d") % int(sc.get("founded_year", 0)), 0.0)
	tiles.add_child(members_t)
	tiles.add_child(Illustrated.tile(Illustrated.tex("res://assets/icons/hud/res_linh_thach.png"), tr("Treasury"), HudReadouts.stones_text(float(sc.get("treasury", 0))), "", 0.0))
	var regions: Array = Array(sc.get("regions", []))
	var holds_l := Label.new()   # the regions held, as a line under the tiles (the tiles carry path, craft, size, wealth)
	holds_l.text = tr("Holds: %s") % (", ".join(regions) if not regions.is_empty() else tr("no region"))
	holds_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	fc.add_child(holds_l)
	if str(sc.get("lore", "")) != "":   # the seat's look from the place catalogue, as in the mock-up's lore card
		var lore := Label.new()
		lore.name = "Lore"
		lore.text = str(sc.lore)
		lore.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lore.add_theme_color_override("font_color", Color(Illustrated.INK, 0.85))
		fc.add_child(lore)
	_into = _g


# The notable members as portrait medallions (in the member view after "Your place", so Promote stays near the top at
# 1280x720: round-2 review, decided 2026-11-24).
func _build_notables(sc: Dictionary) -> void:
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


# A great sect's card on the loose view (weak-point review 2026-11-24 #15: the view was a half-empty list): its seat's
# painting, the name (a link to the sect), path and craft, seat and region, members, and Visit the seat.
func _great_card(g: Dictionary) -> PanelContainer:
	var card := PanelContainer.new()
	card.name = "Great_" + str(g.id)
	card.add_theme_stylebox_override("panel", Illustrated.box(Illustrated.PAPER_TILE, Illustrated.BRASS, 2, 6.0, 2))
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 4)
	card.add_child(col)
	var art: PanelContainer = Illustrated.framed(PortraitPicker.place_painting(int(g.get("seat_art", -1))), Vector2(0, 110), str(g.get("seat", "")))
	col.add_child(art)
	var nm := LinkButton.new()
	nm.text = str(g.name) + ((" " + str(g.name_han)) if str(g.get("name_han", "")) != "" else "")
	LinkStyle.apply(nm, "person", "neutral", "paper")
	nm.add_theme_font_size_override("font_size", 20)
	var gid: String = str(g.id)
	nm.pressed.connect(func(): open_requested.emit("sect", gid, ""))
	col.add_child(nm)
	var facts := Label.new()
	facts.text = " · ".join([str(g.get("alignment", "")), str(g.get("specialty_name", "")), tr("%d members") % int(g.get("members", 0))].filter(func(x): return str(x) != "" and str(x) != tr("%d members") % 0))
	facts.theme_type_variation = &"RowLabel"
	facts.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(facts)
	var where := Label.new()
	where.text = " · ".join([tr("seat %s") % str(g.seat) if str(g.get("seat", "")) != "" else "", str(g.get("region", ""))].filter(func(x): return str(x) != ""))
	where.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(where)
	var b := Button.new()
	b.name = "Visit_" + gid
	if bool(g.get("here", false)):
		b.text = tr("You are at its seat")
		b.disabled = true
		TooltipLayer.set_tip(b, {"title": tr("Visit the seat"), "summary": tr("You are here: open the sect to ask to join.")})
	else:
		b.text = tr("Visit the seat…")
		var seat_id: String = str(g.get("seat_id", ""))
		b.disabled = locked or seat_id == ""
		TooltipLayer.set_tip(b, {"title": tr("Visit the seat"), "summary": tr("locked while an event waits") if locked else tr("Choose travel to %s as this season's focus.") % str(g.seat)})
		b.pressed.connect(func(): action_requested.emit("travel_place", [seat_id]))
	b.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	col.add_child(b)
	return card


# Standing (−100 to 100) as a meter under its row: the bar from the centre, red below 0, green above, the number in it.
func _standing_meter(st: float, parent: Control) -> void:
	var r := HBoxContainer.new()
	r.add_theme_constant_override("separation", 6)
	var neg: ProgressBar = Illustrated.gauge(clampf(-st / 100.0, 0.0, 1.0), Color("#8E1B2A"), 10.0)
	neg.fill_mode = ProgressBar.FILL_END_TO_BEGIN
	neg.custom_minimum_size = Vector2(90, 10)
	var pos: ProgressBar = Illustrated.gauge(clampf(st / 100.0, 0.0, 1.0), Color("#1F6B3A"), 10.0)
	pos.custom_minimum_size = Vector2(90, 10)
	for g in [neg, pos]:
		g.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		r.add_child(g)
	var n := Label.new()
	n.text = tr("standing %+d") % int(st)
	n.theme_type_variation = &"RowLabel"
	r.add_child(n)
	r.accessibility_name = tr("standing %d of −100 to 100") % int(st)
	parent.add_child(r)


# The sect's formation teaching (Formations rule 8; sects_teaching.json): each formation as its shape, name, grade,
# the rank it needs and its contribution, and Learn (armed: the confirm names the price).
func _build_teaching(v: Dictionary) -> void:
	_sec("teaching", tr("Formations taught (trận đồ)"))
	_ln(tr("Learned formations appear in your Combat tab, where you set one and place your arts in it."))
	var grid: GridContainer = Illustrated.grid(_into, 1 if compact else 2, 8)
	grid.name = "Teaching"
	for t in Array(v.teaching):
		var card := PanelContainer.new()
		card.name = "Teach_" + str(t.id)
		card.add_theme_stylebox_override("panel", Illustrated.box(Illustrated.PAPER_TILE, Illustrated.BRASS_DIM, 1, 6.0, 2))
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		card.add_child(row)
		var th := FormationBoard.new()
		th.thumb = true
		th.custom_minimum_size = Vector2(64, 64)
		th.dim = 1.0 if bool(t.ok) or bool(t.known) else 0.55
		th.show_view(t.view)
		var thb := PanelContainer.new()
		thb.add_theme_stylebox_override("panel", Illustrated.box(Color("#1B120C"), Illustrated.BRASS_DIM, 1, 2.0, 3))
		thb.add_child(th)
		row.add_child(thb)
		var col := VBoxContainer.new()
		col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(col)
		var nm := Label.new()
		nm.text = "%s · %s" % [str(t.name), str(t.name_vi)]
		nm.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		col.add_child(nm)
		var sub := Label.new()
		sub.text = tr("grade %d · %s and above · %d contribution") % [int(t.grade), str(t.rank_name), int(t.cost)]
		sub.theme_type_variation = &"RowLabel"
		sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		col.add_child(sub)
		var tid: String = str(t.id)
		if bool(t.known):
			var k := Label.new()
			k.text = "✓ " + tr("known")
			col.add_child(k)
		elif _armed == "teach:" + tid and not locked:
			var rr := HBoxContainer.new()
			col.add_child(rr)
			var ok := Button.new()
			ok.name = "ConfirmLearn"
			ok.text = tr("Learn for %d contribution") % int(t.cost)
			ok.theme_type_variation = &"CommitButton"
			ok.pressed.connect(func():
				_armed = ""
				action_requested.emit("learn_sect_diagram", [tid]))
			rr.add_child(ok)
			var no := Button.new()
			no.text = tr("Cancel")
			no.pressed.connect(func():
				_armed = ""
				show_view(view, "teaching", locked))
			rr.add_child(no)
		else:
			var b := Button.new()
			b.name = "Learn_" + tid
			b.text = tr("Learn…")
			b.disabled = locked or not bool(t.ok)
			b.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
			TooltipLayer.set_tip(b, {"title": str(t.name), "fact": str(t.reason) if not bool(t.ok) else tr("%d contribution") % int(t.cost), "summary": str(t.idea)})
			b.pressed.connect(func():
				_armed = "teach:" + tid
				show_view(view, "teaching", locked))
			col.add_child(b)
		TooltipLayer.set_tip(card, {"title": "%s · %s" % [str(t.name), str(t.name_vi)], "summary": str(t.idea)})
		grid.add_child(card)


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
