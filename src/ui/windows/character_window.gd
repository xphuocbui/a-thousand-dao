class_name CharacterWindow
extends GameWindow
## The character sheet (design/ux/character-sheet.md) in the window host, laid out as the approved round-3 mock-up
## (prototypes/ui-mood/out/r3-character-l.png, user 2026-11-24): on a dark wood ground, a framed portrait with a name
## plaque and the Thiên phú tiles beside a standing inset (realm, cultivation gauge, the bottleneck block), the linh căn
## gauges in element colours and the vitals tiles, the công pháp slot cards (each with Change and an inline chooser),
## then the remaining sections as parchment insets two by two. Eleven sections in a fixed order, Breakdown tooltips on
## every derived number, a confirm-in-place breakthrough, an action bar to the inventory, Đạo Đồ and rankings.
##
## One window for everyone (user 2026-11-24: "why we cant reuse our character screen for other characters"): the
## subject is "" (the player) or a person id (GameQuery.character(s, id)); another person's sheet is look-only (no slot
## changes, no breakthrough) and gains an Interact tab first (attitude, where, ties, recent history, the verbs of
## npc-interaction-dialogue.md rules 8-11; only Greet runs) with Pin, Relations, Practice fight and Travel there. The
## Interact tab's requests are UI actions ("person_verb", "person_pin", "person_relations", "person_fight",
## "person_travel") the map screen handles itself. It replaced the separate person window (person_panel.gd).
## Built from [method GameQuery.character]; requests set_slot and breakthrough through [signal GameWindow.action_requested].

## The section keys in jump order: the illustrated layout's reading order (left column first, then the right, the
## công pháp cards, the insets two by two), which replaced character-sheet.md's list order on 2026-11-24.
const SECTIONS := ["talents", "cultivation", "traits", "roots", "vitals", "cong_phap", "formation", "combat", "dao_do", "gear", "crafts", "fate", "lifespan"]
## The tabs (the round-3 mock-up's tab row, user 2026-11-24): [key, title, its sections]. Overview holds the mock-up's
## page; a jump to a section on another tab opens that tab first. Interact exists only for another person.
## The verbs of npc-interaction-dialogue.md rules 8-11, by group; only Greet runs in the greybox.
## The verbs the game runs today (npc-interaction-dialogue.md; the rest show as "Coming later").
const BUILT_VERBS := ["greet"]
const PERSON_VERBS := [
	["Social", ["greet:Greet (Hàn huyên)", "news:Ask for news (Hỏi tin)", "about:Ask about someone (Hỏi về người)", "gift:Give a gift (Tặng lễ)", "work:Ask for work (Xin việc)"]],
	["Favours", ["teach:Ask for teaching (Thỉnh giáo)", "help:Ask for help (Nhờ giúp)", "trade:Trade (Giao dịch)"]],
	["Conflict", ["spar:Spar (Luận bàn)", "threaten:Threaten (Uy hiếp)", "provoke:Provoke (Khiêu khích)"]],
	["Bonds", ["companion:Recruit a companion", "disciple:Take a disciple", "brotherhood:Swear brotherhood (kết nghĩa)", "dao_lu:Seek Dao companionship (đạo lữ)"]],
]
const TABS := [["interact", "Interact", ["interact", "verbs"]], ["overview", "Overview", ["talents", "cultivation", "traits", "roots", "vitals", "cong_phap"]],
	["combat", "Combat", ["formation", "combat"]], ["equipment", "Equipment", ["dao_do", "gear", "crafts"]], ["fate", "Fate & life", ["fate", "lifespan"]]]
## Hán marks per element (a shape beside the colour; accessibility-requirements.md colour audit).
const ELEMENT_MARKS := {"kim": "金", "moc": "木", "thuy": "水", "hoa": "火", "tho": "土"}

## The lifespan share left under which the age line warns (hud.md lifespan_warn_share).
var lifespan_warn_share: float = 0.1

var _chooser_slot: Dictionary = {}   # the slot whose chooser is open ({slot, index}), {} when none
var _armed: bool = false             # the breakthrough confirm is armed
var _tab: String = "overview"        # the open tab (TABS)
var _trigger_held: bool = false      # a trigger already stepped a tab and has not been released
var _event_locked: bool = false      # an event waits (the Interact tab's verbs say so); `locked` also covers look-only


## The open tab's key (for tests).
func tab() -> String:
	return _tab


## Opens tab [param key] (a TABS key).
func open_tab(key: String) -> void:
	if key == _tab:
		return
	_tab = key
	_chooser_slot = {}
	_armed = false
	super.show_view(view, "", locked)


## The tab that holds section [param section_key] ("" when none does).
static func tab_of(section_key: String) -> String:
	for t in TABS:
		if Array(t[2]).has(section_key):
			return str(t[0])
	return ""


func jump_to(key: String) -> void:
	var t: String = tab_of(key)
	if t != "" and t != _tab:
		_tab = t
		super.show_view(view, "", locked)
	super.jump_to(key)


func kind() -> String:
	return "character"


func window_title(v: Dictionary) -> String:
	var who: String = tr("Character") if bool(v.get("is_player", true)) else str(v.get("name", tr("Person")))
	return who + ("" if bool(v.get("alive", true)) else " (" + tr("died") + ")")


## True while the window shows someone other than the player.
func shows_other() -> bool:
	return not bool(view.get("is_player", true)) and not view.is_empty()


## Opens the Interact tab and focuses its first live verb (the V key).
func jump_to_verbs() -> void:
	if shows_other():
		jump_to("verbs")


## The chooser state, for tests: {slot, index} or {}.
func chooser_open() -> Dictionary:
	return _chooser_slot.duplicate()


## True while the breakthrough confirm is armed.
func armed() -> bool:
	return _armed


func show_view(v: Dictionary, section: String, is_locked: bool) -> void:
	if v.get("id", "") != view.get("id", "-"):
		_chooser_slot = {}
		_armed = false
		_tab = "overview" if bool(v.get("is_player", true)) else "interact"
	if section != "" and tab_of(section) != "":
		_tab = tab_of(section)
	super.show_view(v, section, is_locked)


func _build() -> void:
	var v: Dictionary = view
	if bool(v.get("gone", false)):
		line(tr("This window's subject is gone."))
		return
	_build_header(v)
	var dead: bool = not bool(v.get("alive", true))
	_event_locked = locked
	locked = locked or dead or not bool(v.get("is_player", true))   # another person's sheet is look-only
	_build_tabs()
	var g: VBoxContainer = Illustrated.ground(body)
	if _tab == "interact":
		_build_interact(v, g)
		return
	if _tab != "overview":
		var rest: GridContainer = Illustrated.grid(g, 1 if compact else 2, 10)
		match _tab:
			"combat":
				_build_combat(v, g)   # alone on its tab: the full width
			"equipment":
				_build_dao_do(v, rest)
				_build_gear(v, rest)
				_build_crafts(v, rest)
			"fate":
				_build_fate(v, rest)
				_build_lifespan(v, rest)
		_bar_buttons()
		return
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 12)
	g.add_child(top)
	# left: the portrait, the name plaque, the Thiên phú tiles
	var pw: float = 200.0 if compact else 300.0   # wide enough for the Thiên phú tiles with their icons
	var left := VBoxContainer.new()
	left.add_theme_constant_override("separation", 8)
	left.custom_minimum_size = Vector2(pw, 0)
	top.add_child(left)
	var portrait: Control = Illustrated.framed(PortraitPicker.texture_for(v.get("portrait", {})), Vector2(pw, pw * 1.15), "?")
	portrait.name = "Portrait"
	left.add_child(portrait)
	left.add_child(Illustrated.plaque(str(v.get("name", ""))))
	_build_talents(v, left)
	# right: standing and cultivation, roots and vitals
	var right := VBoxContainer.new()
	right.add_theme_constant_override("separation", 10)
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(right)
	_build_cultivation(v, right)
	_build_traits(v, right)
	var mid: BoxContainer = VBoxContainer.new() if compact else HBoxContainer.new()
	mid.add_theme_constant_override("separation", 10)
	right.add_child(mid)
	_build_roots(v, mid)
	_build_vitals(v, mid)
	# the công pháp cards under them (the mock-up's right column)
	_build_cong_phap(v, right)
	_bar_buttons()


func _bar_buttons() -> void:
	if shows_other():
		_person_bar()
		return
	bar_open(tr("Inventory"), "inventory")
	bar_open(tr("Đạo Đồ"), "dao_do")
	bar_open(tr("Rankings"), "rankings")


# Another person's action bar (person.md P5): Pin / Unpin, Relations, Practice fight, Travel there.
func _person_bar() -> void:
	var v: Dictionary = view
	var p: Dictionary = v.get("person", {})
	var pid: String = str(v.get("id", ""))
	var pin := Button.new()
	pin.name = "Pin"
	var on: bool = bool(v.get("pinned", false))
	pin.text = tr("Unpin") if on else tr("Pin")
	TooltipLayer.set_tip(pin, tr("Follow this person in the outliner (where they are each season)."))
	pin.pressed.connect(func(): action_requested.emit("person_pin", [pid, not on]))
	bar.add_child(pin)
	var rel := Button.new()
	rel.name = "Relations"
	rel.text = tr("Relations")
	TooltipLayer.set_tip(rel, tr("Your relationships page, filtered to this person."))
	var pname: String = str(v.get("name", ""))
	rel.pressed.connect(func(): action_requested.emit("person_relations", [pname]))
	bar.add_child(rel)
	if bool(v.get("alive", true)) and not bool(p.get("is_beast", false)):
		var fight := Button.new()
		fight.name = "PracticeFight"
		fight.text = tr("Practice fight")
		TooltipLayer.set_tip(fight, tr("Watch a practice fight with this person on the fight screen. It changes nothing: a preview of how a fight would go."))
		fight.pressed.connect(func(): action_requested.emit("person_fight", [pid]))
		bar.add_child(fight)
	if not bool(p.get("here", false)) and str(p.get("place_id", "")) != "" and bool(v.get("alive", true)):
		var travel := Button.new()
		travel.name = "TravelThere"
		travel.text = tr("Travel there")
		var plid: String = str(p.place_id)
		travel.pressed.connect(func(): action_requested.emit("person_travel", [plid]))
		bar.add_child(travel)


# The Interact tab (person.md P3 Character and ties, Verbs, More): attitude and where, ties with portraits, recent
# history, and the verbs (only Greet runs; the rest say why not).
func _build_interact(v: Dictionary, g: Control) -> void:
	var p: Dictionary = v.get("person", {})
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 12)
	g.add_child(top)
	var pw: float = 160.0 if compact else 200.0
	var pf: Control = Illustrated.framed(PortraitPicker.texture_for(v.get("portrait", {})), Vector2(pw, pw * 1.25), "")
	pf.name = "Portrait"
	top.add_child(pf)
	var who: VBoxContainer = section_in(top, "interact", tr("Who they are"))
	var realm := Label.new()
	realm.text = str(v.get("realm_label", ""))
	realm.theme_type_variation = &"TitleLabel"
	who.add_child(realm)
	line(_standing_rest(v) + ((" · " + str(p.archetype)) if str(p.get("archetype", "")) != "" else ""), who)
	var att: String = tr("not met") if not bool(p.get("met", false)) else "%s %+d" % [str(p.get("band", "")), int(p.get("attitude", 0))]
	row(tr("Attitude"), att, null, who)
	row(tr("Where"), str(p.get("place", "")) + ("  (" + tr("here") + ")" if bool(p.get("here", false)) else ""), null, who)
	row(tr("Home"), str(p.get("home", "")) if str(p.get("home", "")) != "" else tr("none"), null, who)
	var ts: Array = Array(v.get("traits", []))
	if not ts.is_empty():
		var flow := HFlowContainer.new()
		flow.add_theme_constant_override("h_separation", 6)
		flow.add_theme_constant_override("v_separation", 6)
		who.add_child(flow)
		for t in ts:
			flow.add_child(Illustrated.trait_chip(t, 44.0))
	var cols: GridContainer = Illustrated.grid(g, 1 if compact else 2, 10)
	var ties_box: VBoxContainer = Illustrated.inset(cols, tr("Ties"))
	var ties: Array = Array(p.get("ties", []))
	if ties.is_empty():
		line(tr("none"), ties_box)
	for t in ties:
		var r := HBoxContainer.new()
		r.add_theme_constant_override("separation", 8)
		r.add_child(Illustrated.medallion(PortraitPicker.texture_for(t.get("portrait", {})), 36.0))
		var l := Label.new()
		l.text = ", ".join(Array(t.kinds)) + ":"
		r.add_child(l)
		var b := LinkButton.new()
		b.text = str(t.partner)
		LinkStyle.apply(b, "person", "", "paper")
		var tid: String = str(t.partner_id)
		b.pressed.connect(func(): open_requested.emit("person", tid, ""))
		r.add_child(b)
		ties_box.add_child(r)
	var hist_box: VBoxContainer = Illustrated.inset(cols, tr("Recent history"))
	var hist: Array = Array(p.get("history", []))
	if hist.is_empty():
		line(tr("none"), hist_box)
	for h in hist:
		line(str(h), hist_box)
	# Only the verbs the game has are buttons; the planned ones are one muted line (weak-point review 2026-11-24:
	# designer notes shown as dead rows made the window read as a spec).
	var vb: VBoxContainer = section_in(g, "verbs", tr("Verbs"))
	var here: bool = bool(p.get("here", false)) and bool(v.get("alive", true)) and not bool(p.get("is_beast", false))
	var first: Button = null
	var row := HFlowContainer.new()
	row.add_theme_constant_override("h_separation", 8)
	vb.add_child(row)
	var planned: Array = []
	for group in PERSON_VERBS:
		for entry in group[1]:
			var parts: PackedStringArray = str(entry).split(":", true, 1)
			if not BUILT_VERBS.has(parts[0]):
				planned.append(tr(parts[1]).get_slice(" (", 0))
				continue
			var reason: String = ""
			if not here:
				reason = tr("not here: %s") % str(p.get("place", "?"))
			elif _event_locked:
				reason = tr("locked while an event waits (look only)")
			var b := Button.new()
			b.name = "Verb_" + parts[0]
			b.text = tr(parts[1])
			b.theme_type_variation = &"CommitButton" if reason == "" else &""
			b.disabled = reason != ""
			b.accessibility_name = tr(parts[1]) + ((": " + reason) if reason != "" else "")
			TooltipLayer.set_tip(b, {"title": tr(parts[1]), "summary": reason if reason != "" else tr("They will accept.")})
			var vid: String = parts[0]
			var pid: String = str(v.get("id", ""))
			b.pressed.connect(func(): action_requested.emit("person_verb", [pid, vid]))
			row.add_child(b)
			if first == null and not b.disabled:
				first = b
	if not planned.is_empty():
		var more := Label.new()
		more.name = "PlannedVerbs"
		more.text = tr("Coming later: %s.") % ", ".join(planned)
		more.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		more.modulate = Color(1, 1, 1, 0.65)
		vb.add_child(more)
	if first != null:
		focus_later(first)
	_person_bar()


# The tab row in the sticky header: one toggle per tab, the open one pressed (Ctrl+Tab / Ctrl+Shift+Tab step them).
func _build_tabs() -> void:
	var row := HBoxContainer.new()
	row.name = "Tabs"
	row.add_theme_constant_override("separation", 4)
	header.add_child(row)
	for t in TABS:
		if str(t[0]) == "interact" and not shows_other():
			continue
		var b := Button.new()
		b.name = "Tab_" + str(t[0])
		b.toggle_mode = true
		b.text = tr(str(t[1]))
		b.button_pressed = str(t[0]) == _tab
		b.accessibility_name = b.text + ((", " + tr("selected")) if b.button_pressed else "")
		b.pressed.connect(open_tab.bind(str(t[0])))
		row.add_child(b)


func _unhandled_input(event: InputEvent) -> void:
	if is_visible_in_tree() and event is InputEventKey and event.is_pressed() and (event as InputEventKey).ctrl_pressed \
			and (event as InputEventKey).physical_keycode == KEY_TAB:
		step_tab(-1 if (event as InputEventKey).shift_pressed else 1)
		get_viewport().set_input_as_handled()
		return
	# the gamepad's LT / RT step the tabs here (a tab's sections are short; decided 2026-11-24, round-2 review)
	if is_visible_in_tree() and _owns_focus() and event is InputEventJoypadMotion:
		var m := event as InputEventJoypadMotion
		if m.axis == JOY_AXIS_TRIGGER_LEFT or m.axis == JOY_AXIS_TRIGGER_RIGHT:
			if m.axis_value > 0.6 and not _trigger_held:
				_trigger_held = true
				step_tab(-1 if m.axis == JOY_AXIS_TRIGGER_LEFT else 1)
			elif m.axis_value < 0.3:
				_trigger_held = false
			get_viewport().set_input_as_handled()
			return
	super._unhandled_input(event)


## Opens the next ([param dir] 1) or previous (-1) tab, wrapping; Interact only exists for another person.
func step_tab(dir: int) -> void:
	var keys: Array = TABS.map(func(t): return str(t[0])).filter(func(k): return k != "interact" or shows_other())
	open_tab(str(keys[posmod(keys.find(_tab) + dir, keys.size())]))


func _build_header(v: Dictionary) -> void:
	var name := Label.new()
	name.text = str(v.get("name", ""))
	name.theme_type_variation = &"HeadingLabel"
	var standing_text: String = _standing(v)
	TooltipLayer.set_tip(name, {"title": name.text, "fact": standing_text})   # the standing itself sits in the Cultivation inset
	var nums := HBoxContainer.new()
	# one line: the name with the numbers (the portrait's plaque carries the name large; weak-point review 2026-11-24)
	name.text += "  ·  "
	nums.add_child(name)
	var age := Label.new()
	var age_v: float = float(v.get("age", 0.0))
	var life: float = float(v.get("lifespan", 0.0))
	var warn: bool = HudReadouts.lifespan_warning(age_v, life, lifespan_warn_share)
	age.text = tr("Age %d / %d") % [int(age_v), int(life)] + " (" + HudReadouts.years_left_text(age_v, life) + ")" + (" ⌛" if warn else "")
	age.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if warn:
		age.modulate = Color(1.0, 0.78, 0.35)
	TooltipLayer.set_tip(age, breakdown_tip(tr("Lifespan (thọ nguyên)"), v.get("breakdowns", {}).get("lifespan", {}), tr("When age reaches lifespan, this life ends.")))
	nums.add_child(age)
	var power := Label.new()
	var p: int = int(v.get("power", -1))
	power.text = tr("Rating") + " " + ("—" if p < 0 else (("~" if bool(v.get("provisional", false)) else "") + HudReadouts.stones_text(float(p))))
	TooltipLayer.set_tip(power, {"title": tr("Rating"), "summary": tr("Your power number, from rated fights; ~ while provisional, — before any rating.")})
	nums.add_child(power)
	header.add_child(nums)
	header.accessibility_name = tr("Character sheet") + ", " + name.text


func _standing(v: Dictionary) -> String:
	var parts: Array = [str(v.get("realm_label", "")) + " L%d" % int(v.get("level", 1)) + ((" (" + tr("tầng %d") % int(v.layer) + ")") if int(v.get("layer", 0)) > 0 else "")]
	if str(v.get("sect", "")) != "":
		parts.append(str(v.sect) + ((", " + str(v.rank)) if str(v.get("rank", "")) != "" else ""))
	else:
		parts.append(tr("loose cultivator (tán tu)"))
	return " · ".join(parts)


func _build_cultivation(v: Dictionary, parent: Control) -> void:
	var box: VBoxContainer = section_in(parent, "cultivation", tr("Cultivation"))
	var realm := Label.new()
	realm.text = str(v.get("realm_label", "")) + ((" · " + tr("tầng %d") % int(v.layer)) if int(v.get("layer", 0)) > 0 else "") + "  L%d" % int(v.get("level", 1))
	realm.theme_type_variation = &"TitleLabel"
	box.add_child(realm)
	line(_standing_rest(v), box)
	var cu: Dictionary = v.get("cultivation", {})
	var bds: Dictionary = v.get("breakdowns", {})
	if bool(cu.get("top", false)):
		line(tr("The highest realm: there is no next level."), box)
		return
	var req: float = float(cu.get("requirement", 0.0))
	var share: float = HudReadouts.cultivation_share(float(cu.get("tu_vi", 0.0)), req)
	var bar_box: ProgressBar = Illustrated.gauge(share, Illustrated.BRASS, 16.0)
	bar_box.accessibility_name = tr("Cultivation %d percent, %s of %s") % [int(share * 100.0), num(float(cu.tu_vi)), num(req)]
	box.add_child(bar_box)
	# tu vi and rate on one line under the bar (weak-point review 2026-11-24 #2: two rows pushed the sections below off
	# screen): "tu vi 120 / 400 (30 %) · +12 a season here · next level in 24 seasons"
	var rate_text: String = ("+" + num(float(cu.get("rate", 0.0))) + " " + tr("a season here")) if not bool(cu.get("held", false)) else tr("held: at the bottleneck or a realm cap")
	var nxt: int = int(cu.get("seasons_to_next", -1))
	if nxt > 0 and not bool(cu.get("held", false)):
		rate_text += " · " + tr("next level in %d seasons") % nxt
	var tl: Label = line(tr("Tu vi") + " %s / %s (%d %%) · %s" % [num(float(cu.tu_vi)), num(req), int(share * 100.0), rate_text], box)
	tl.name = "TuViRate"
	TooltipLayer.set_tip(tl, breakdown_tip(tr("Cultivation per season here"), bds.get("rate", {})))
	var bn: Dictionary = cu.get("bottleneck", {})
	if bn.is_empty():
		return
	var block := VBoxContainer.new()
	block.name = "Bottleneck"
	box.add_child(block)
	line(tr("BOTTLENECK: great perfection"), block).theme_type_variation = &"RowLabel"
	row(tr("Bar"), "%s / %s%s" % [num(float(bn.tu_vi)), num(float(bn.bar_cost)), (" (" + tr("full") + ")") if bool(bn.full) else ""], null, block)
	if str(bn.get("condition", "")) != "":
		row(tr("Condition"), ("✓ " if bool(bn.condition_met) else "✗ ") + str(bn.condition) + " — " + (tr("met") if bool(bn.condition_met) else tr("not met")), null, block)
	row(tr("Pill"), (str(bn.pill) + " (" + tr("quality %d") % int(bn.pill_quality) + ")") if str(bn.get("pill", "")) != "" else tr("none held (a bare attempt)"), null, block)
	row(tr("Talisman"), {"used": tr("used this breakthrough"), "held": tr("held: burns on a pill attempt"), "none": tr("none held")}.get(str(bn.talisman), ""), null, block)
	var chance: float = float(bn.get("chance", 0.0)) * 100.0
	var risk: float = float(bn.get("backlash", 0.0))
	row(tr("This attempt"), "%.1f %% " % chance + tr("success"), breakdown_tip(tr("Breakthrough chance"), bds.get("breakthrough", {})), block)
	row(tr("Qi deviation"), "%.0f %% " % risk + tr("if it fails"), breakdown_tip(tr("Qi deviation chance"), bds.get("backlash", {})), block)
	row(tr("Bare attempts"), "%d / %d" % [int(bn.bare_attempts), int(bn.bare_cap)], null, block)
	var actions := HBoxContainer.new()
	block.add_child(actions)
	if not bool(bn.full):
		line(tr("Fill the bar to attempt."), block)
		return
	if _armed and not locked:
		var ask := Label.new()
		ask.text = tr("Attempt the breakthrough? %.0f %% success; %.0f %% qi deviation if it fails.") % [chance, risk]
		ask.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		ask.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		ask.accessibility_name = ask.text + " " + tr("Confirm or Cancel")
		block.add_child(ask)
		block.move_child(ask, actions.get_index())
		var confirm := action_button(tr("Confirm"), "breakthrough", [str(bn.get("pill", "")) != "" and not bool(bn.condition_met), true], actions)
		confirm.name = "ConfirmBreakthrough"
		confirm.theme_type_variation = &"CommitButton"
		confirm.pressed.connect(func(): _armed = false)
		var cancel := Button.new()
		cancel.name = "CancelBreakthrough"
		cancel.text = tr("Cancel")
		cancel.pressed.connect(_disarm)
		actions.add_child(cancel)
		focus_later(cancel)
	else:
		var attempt := Button.new()
		attempt.name = "AttemptBreakthrough"
		attempt.text = ("🔒 " if locked else "") + tr("Attempt breakthrough")
		attempt.disabled = locked
		attempt.accessibility_name = tr("Attempt breakthrough") + ((": " + tr("locked while an event waits")) if locked else "")
		if locked:
			TooltipLayer.set_tip(attempt, {"title": tr("Attempt breakthrough"), "summary": tr("locked while an event waits")})
		attempt.pressed.connect(_arm)
		actions.add_child(attempt)


func _arm() -> void:
	_armed = true
	_rebuild_keep("cultivation")


func _disarm() -> void:
	_armed = false
	_rebuild_keep("cultivation")


## Esc closes an open chooser or disarms first (character-sheet.md Interaction Map). Returns true when it did.
func cancel_inline() -> bool:
	if _armed:
		_disarm()
		return true
	if not _chooser_slot.is_empty():
		_chooser_slot = {}
		_rebuild_keep("cong_phap")
		return true
	return false


func _rebuild_keep(sect: String) -> void:
	var y: int = scroll.scroll_vertical
	super.show_view(view, "", locked)
	scroll.set_deferred("scroll_vertical", y)
	if sect != "":
		pass


# The traits row (the mock-up's medallions): personality, calling, fate and gained traits as chips.
func _build_traits(v: Dictionary, parent: Control) -> void:
	var box: VBoxContainer = section_in(parent, "traits", tr("Traits"))
	var ts: Array = Array(v.get("traits", []))
	if ts.is_empty():
		line(tr("none yet: deeds and fate give traits as your life goes on"), box)
		return
	var flow := HFlowContainer.new()
	flow.add_theme_constant_override("h_separation", 6)
	flow.add_theme_constant_override("v_separation", 6)
	box.add_child(flow)
	for t in ts:   # icons only; hover (or Q) shows the trait (user 2026-11-24: "much like in ck")
		flow.add_child(Illustrated.trait_chip(t, 48.0))


# The standing line without the realm (the inset's title shows it): sect and rank, or loose; age.
func _standing_rest(v: Dictionary) -> String:
	var parts: Array = []
	if str(v.get("sect", "")) != "":
		parts.append(str(v.sect) + ((", " + str(v.rank)) if str(v.get("rank", "")) != "" else ""))
	else:
		parts.append(tr("loose cultivator (tán tu)"))
	parts.append(tr("age %d / %d") % [int(float(v.get("age", 0.0))), int(float(v.get("lifespan", 0.0)))])
	return " · ".join(parts)


func _build_roots(v: Dictionary, parent: Control) -> void:
	var r: Dictionary = v.get("roots", {})
	var box: VBoxContainer = section_in(parent, "roots", tr("Linh căn") + " · %s · x%.2f" % [str(r.get("tier", "")), float(r.get("speed", 1.0))])
	var cols: Dictionary = style.get("element_colours", {})
	for e in Array(r.get("elements", [])):
		var rr := HBoxContainer.new()
		rr.add_theme_constant_override("separation", 6)
		var mark := Label.new()
		mark.text = str(ELEMENT_MARKS.get(str(e.id), "·"))
		mark.custom_minimum_size = Vector2(22, 0)
		rr.add_child(mark)
		var nm := Label.new()
		nm.text = str(e.name)
		nm.custom_minimum_size = Vector2(56, 0)
		rr.add_child(nm)
		var pb: ProgressBar = Illustrated.gauge(float(e.purity) / 100.0, Color(str(cols.get(str(e.id), "#C9A25A"))), 14.0)
		pb.custom_minimum_size = Vector2(100, 14)
		if float(e.purity) <= 0.0:   # an absent element: an empty trough, its name and mark faded
			nm.modulate.a = 0.55
			mark.modulate.a = 0.55
		rr.add_child(pb)
		var val := Label.new()
		val.text = ("%s %s" % [LinhCan.fmt(float(e.purity)), str(e.grade)]) if float(e.purity) > 0.0 else "—"
		val.custom_minimum_size = Vector2(84, 0)
		rr.add_child(val)
		rr.accessibility_name = ("%s purity %s, %s" % [str(e.name), LinhCan.fmt(float(e.purity)), str(e.grade)]) if float(e.purity) > 0.0 else "%s: none" % str(e.name)
		rr.focus_mode = Control.FOCUS_ALL
		TooltipLayer.set_tip(rr, {"title": str(e.name), "fact": val.text.strip_edges(), "summary": str(e.get("role", ""))})
		box.add_child(rr)
	for x in Array(r.get("variants", [])):
		row(str(x.name), "%s  (%s)  %s" % [LinhCan.fmt(float(x.purity)), str(x.origin), ", ".join(Array(x.lines))], null, box)


func _build_talents(v: Dictionary, parent: Control) -> void:
	var box: VBoxContainer = section_in(parent, "talents", tr("Thiên phú"))
	var bds: Dictionary = v.get("breakdowns", {})
	var icons: Dictionary = style.get("talent_icons", {})
	var g: GridContainer = Illustrated.grid(box, 2, 6)
	for t in Array(v.get("talents", [])):
		var bonus: int = int(t.get("bonus", 0))
		var tl: PanelContainer = Illustrated.tile(Illustrated.tex(_icon_path(str(icons.get(str(t.id), "")))), str(t.name), "%d" % int(t.value),
			str(t.grade) + (("  %+d" % bonus) if bonus != 0 else ""), 0.0)
		TooltipLayer.set_tip(tl, breakdown_tip(str(t.name), bds.get("talent:" + str(t.id), {})))
		g.add_child(tl)


func _icon_path(rel: String) -> String:
	return ("res://assets/icons/" + rel) if rel != "" else ""


func _build_vitals(v: Dictionary, parent: Control) -> void:
	var box: VBoxContainer = section_in(parent, "vitals", tr("Vitals"))
	var bds: Dictionary = v.get("breakdowns", {})
	var icons: Dictionary = style.get("vital_icons", {})
	var g: GridContainer = Illustrated.grid(box, 2, 6)
	for st in Array(v.get("vitals", [])):
		var text: String = num(float(st.value))
		if st.has("max"):
			text = "%s / %s" % [num(float(st.value)), num(float(st.max))]
		if str(st.get("unit", "")) != "":
			text = "%d %s" % [int(float(st.value)), str(st.unit)]
		var tl: PanelContainer = Illustrated.tile(Illustrated.tex(_icon_path(str(icons.get(str(st.key), "")))), tr(str(st.label)), text, str(st.get("note", "")), 0.0)
		if bds.has(str(st.key)):
			TooltipLayer.set_tip(tl, breakdown_tip(tr(str(st.label)), bds.get(str(st.key), {})))
		g.add_child(tl)


## The Combat tab's groups (weak-point review 2026-11-24: "a bare table in a dark void"): [title, keys]; a key not
## listed (a typed resistance) goes under Resistances. Shares show as %; block, wards and resistances are points.
const COMBAT_GROUPS := [["Defence", ["ward_pts", "ward_layer", "block", "body_shield", "evade", "soul_res"]],
	["Offence", ["crit", "crit_mult"]], ["Sustain", ["hregen"]]]
const COMBAT_SHARES := ["evade", "crit", "body_shield"]
const COMBAT_HINTS := {
	"ward_pts": "Main ward resistance points: they count only while your linh lực lasts.",
	"ward_layer": "How many layers your main ward has.",
	"block": "Block points, times your realm's block unit: blocked damage is taken off each hit.",
	"body_shield": "A shield bar as a share of your health; Chaos and Soul damage pass it.",
	"evade": "The chance a hit misses you outright.",
	"soul_res": "Resistance to Soul damage.",
	"crit": "The chance a hit of yours is critical.",
	"crit_mult": "How much a critical hit multiplies damage.",
	"hregen": "Health you regain each second of a fight.",
}


# The Combat tab (the user's pick 2026-11-24, mock-up r5-tab-a; design/ux/diagram-editor.md): the formation editor,
# then every combat number in its groups.
func _build_combat(v: Dictionary, parent: Control) -> void:
	if v.has("formations") and not (v.formations as Dictionary).is_empty():
		_build_formations(v.formations, parent)
	_build_combat_numbers(v, parent)


var _sel_node: int = 0   # the formation node selected for placing an art (1-based; 0 none)


# The formation editor: the collection (left), the board with its level track (centre), the arts (right), the prices.
func _build_formations(f: Dictionary, parent: Control) -> void:
	var box: VBoxContainer = section_in(parent, "formation", tr("Formation (trận đồ)"))
	var look_only: bool = locked or bool(f.get("event_waiting", false))
	var cols: BoxContainer = VBoxContainer.new() if compact else HBoxContainer.new()
	cols.add_theme_constant_override("separation", 10)
	box.add_child(cols)
	# C1 the collection
	var coll := VBoxContainer.new()
	coll.name = "Collection"
	coll.custom_minimum_size = Vector2(0 if compact else 250, 0)
	coll.add_theme_constant_override("separation", 6)
	cols.add_child(coll)
	var ch := Label.new()
	ch.text = tr("FORMATIONS")
	ch.theme_type_variation = &"RowLabel"
	coll.add_child(ch)
	var list: Container = HFlowContainer.new() if compact else VBoxContainer.new()
	list.add_theme_constant_override("separation", 6)
	coll.add_child(list)
	for k in Array(f.get("known", [])):
		list.add_child(_formation_card(k, look_only))
	# C2 the board
	var centre := VBoxContainer.new()
	centre.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	centre.size_flags_stretch_ratio = 2.2
	centre.add_theme_constant_override("separation", 6)
	cols.add_child(centre)
	var cur: Dictionary = f.get("current", {})
	var plaque: PanelContainer = Illustrated.plaque(("%s · %s" % [str(cur.name), str(cur.name_vi)]) if not cur.is_empty() else tr("Plain Row · your arts in plain slots"))
	plaque.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	centre.add_child(plaque)
	if cur.is_empty():
		var row := HFlowContainer.new()
		row.name = "PlainRow"
		row.add_theme_constant_override("h_separation", 8)
		centre.add_child(row)
		for a in Array(f.get("pool", [])):
			row.add_child(_art_icon(str(a.icon), 56.0, str(a.name)))
		line(tr("No rules, no reservation, no fuel. Choose a formation on the left to arrange your arts."), centre)
	else:
		var board := FormationBoard.new()
		board.name = "Board"
		board.custom_minimum_size = Vector2(0, 260 if compact else 360)
		board.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		board.node_px = 30.0
		board.selected = _sel_node
		board.show_view(cur)
		board.node_pressed.connect(_on_formation_node.bind(look_only))
		centre.add_child(board)
		# the level track: one pip per level, lit to the current, and what the next level does
		var lt := HBoxContainer.new()
		lt.name = "LevelTrack"
		lt.alignment = BoxContainer.ALIGNMENT_CENTER
		lt.add_theme_constant_override("separation", 4)
		centre.add_child(lt)
		for L in range(1, int(cur.max_level) + 1):
			var pip := Label.new()
			pip.text = "●" if L <= int(cur.level_eff) else "○"
			pip.add_theme_color_override("font_color", Color("#C9A25A") if L <= int(cur.level_eff) else Color("#8A7A5A"))
			pip.add_theme_font_size_override("font_size", 22)
			lt.add_child(pip)
		var lw := Label.new()
		lw.text = "  " + _level_words(cur)
		lw.theme_type_variation = &"RowLabel"
		lt.add_child(lw)
		var rz: Dictionary = f.get("raise", {})
		if int(cur.max_level) > 1 and not rz.is_empty():   # F3: raise it a level (at home, for linh thạch)
			var rb := Button.new()
			rb.name = "RaiseFormation"
			rb.text = tr("Raise to level %d (%d linh thạch)…") % [int(rz.target), int(rz.cost)] if int(rz.target) <= int(cur.max_level) else tr("Raise…")
			rb.disabled = look_only or not bool(rz.ok)
			TooltipLayer.set_tip(rb, {"title": tr("Raise the formation"), "summary": str(rz.reason) if not bool(rz.ok) else tr("Raises it a level now; higher levels are stronger, and some open nodes or links.")})
			var rid: String = str(cur.id)
			rb.pressed.connect(func(): action_requested.emit("raise_diagram", [rid]))
			lt.add_child(rb)
		if str(cur.get("idea", "")) != "":
			var idea := line(str(cur.idea), centre)
			idea.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	# C3 the arts
	var arts := VBoxContainer.new()
	arts.name = "Arts"
	arts.custom_minimum_size = Vector2(0 if compact else 230, 0)
	arts.add_theme_constant_override("separation", 6)
	cols.add_child(arts)
	var ah := Label.new()
	ah.text = tr("YOUR ARTS")
	ah.theme_type_variation = &"RowLabel"
	arts.add_child(ah)
	var alist: Container = HFlowContainer.new() if compact else VBoxContainer.new()
	alist.add_theme_constant_override("separation", 6)
	arts.add_child(alist)
	for a in Array(f.get("pool", [])):
		alist.add_child(_art_card(a, look_only or cur.is_empty()))
	if _sel_node > 0 and not cur.is_empty():
		var held: String = ""
		for nd in Array(cur.nodes):
			if int(nd.n) == _sel_node:
				held = str(nd.art)
		var hint := line(tr("Node %d selected: click an art to place it.") % _sel_node, arts)
		hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		if held != "":
			var empty := Button.new()
			empty.name = "EmptyNode"
			empty.text = tr("Empty node %d") % _sel_node
			empty.disabled = look_only
			var nsel: int = _sel_node
			empty.pressed.connect(func():
				_sel_node = 0
				action_requested.emit("place_diagram_art", [nsel, ""]))
			arts.add_child(empty)
	# C4 the price of the choice
	var prices: GridContainer = Illustrated.grid(box, 2 if compact else 4, 8)
	prices.name = "Prices"
	var stones: int = int(f.get("stones", 0))
	var fuel: int = int(f.get("fuel", 0))
	var short: bool = fuel > stones and not cur.is_empty()
	prices.add_child(Illustrated.tile(Illustrated.tex("res://assets/icons/hud/res_linh_thach.png"), tr("Lay fuel"),
		(tr("%d of %d linh thạch") % [fuel, stones]) if not cur.is_empty() else tr("none"), tr("short: carried at 70 %") if short else tr("burnt when a foreseen fight begins")))
	prices.add_child(Illustrated.tile(Illustrated.tex("res://assets/icons/hud/res_cultivation.png"), tr("Linh lực reserved"),
		"%.0f %%" % (float(f.get("reserved", 0.0)) * 100.0), tr("cap %.0f %% with wards") % (float(f.get("reserve_cap", 0.9)) * 100.0)))
	var sh: Dictionary = f.get("shares", {})
	prices.add_child(Illustrated.tile(null, tr("Strength"), tr("laid %.0f %%") % (float(sh.get("laid", 1.0)) * 100.0),
		tr("ambush %.0f %% · blind %.0f %%") % [float(sh.get("carried", 0.7)) * 100.0, float(sh.get("blind", 0.5)) * 100.0]))
	var lay := Button.new()
	lay.name = "LayToggle"
	lay.toggle_mode = true
	lay.button_pressed = bool(f.get("lay", true))
	lay.text = tr("Lay when foreseen: %s") % (tr("On") if lay.button_pressed else tr("Off"))
	lay.disabled = look_only or cur.is_empty()
	TooltipLayer.set_tip(lay, {"title": tr("Lay when foreseen"), "summary": tr("On: in a foreseen fight the formation is laid (its fuel burnt) and works at 100 %. Off: it is always carried at 70 % and burns nothing.")})
	lay.toggled.connect(func(on: bool): action_requested.emit("set_diagram_lay", [on]))
	lay.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	prices.add_child(lay)


func _level_words(cur: Dictionary) -> String:
	if int(cur.max_level) <= 1:
		return tr("One level: complete as taught")
	var L: int = int(cur.level_eff)
	if L >= int(cur.max_level):
		return tr("Level %d of %d: the highest") % [L, int(cur.max_level)]
	var opens: Array = Array(cur.nodes).filter(func(n): return int(n.unlock) == L + 1).map(func(n): return str(n.n))
	var links: int = Array(cur.links).filter(func(l): return int(l.unlock) == L + 1).size()
	var next: String = (tr("opens node %s") % ", ".join(opens)) if not opens.is_empty() else (tr("opens %d links") % links if links > 0 else tr("more strength"))
	return tr("Level %d of %d · next level: %s") % [L, int(cur.max_level), next]


func _on_formation_node(n: int, look_only: bool) -> void:
	if look_only:
		return
	_sel_node = 0 if _sel_node == n else n
	show_view(view, "formation", locked)


# A collection card: the formation's shape as a small gold drawing, its name, and what it is now.
func _formation_card(k: Dictionary, look_only: bool) -> Button:
	var b := Button.new()
	b.name = "Formation_" + (str(k.id) if str(k.id) != "" else "plain")
	b.custom_minimum_size = Vector2(240 if not compact else 170, 64)
	b.toggle_mode = true
	b.button_pressed = bool(k.set)
	b.disabled = look_only or not bool(k.can)
	var edge: Color = Color("#E3B860") if bool(k.set) else Illustrated.BRASS_DIM
	for st in ["normal", "hover", "pressed", "hover_pressed", "focus", "disabled"]:
		b.add_theme_stylebox_override(st, Illustrated.box(Color("#2A1C12") if st != "hover" else Color("#3A2718"), edge, 3 if bool(k.set) else 1, 4.0, 3))
	var row := HBoxContainer.new()
	row.set_anchors_preset(Control.PRESET_FULL_RECT)
	row.offset_left = 6
	row.offset_right = -6
	row.add_theme_constant_override("separation", 8)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(row)
	var th := FormationBoard.new()
	th.thumb = true
	th.custom_minimum_size = Vector2(52, 52)
	th.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	th.mouse_filter = Control.MOUSE_FILTER_IGNORE
	th.dim = 1.0 if bool(k.can) else 0.45
	var kv: Dictionary = k.view
	if Array(kv.get("nodes", [])).is_empty():   # the Plain Row: a row of dots
		kv = {"nodes": [{"pos": [0, 0], "open": true}, {"pos": [1, 0], "open": true}, {"pos": [2, 0], "open": true}], "links": [], "figure": []}
	th.show_view(kv)
	row.add_child(th)
	var col := VBoxContainer.new()
	col.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(col)
	var nm := Label.new()
	nm.text = str(k.name) + ("  ✓" if bool(k.set) else "")
	nm.add_theme_color_override("font_color", Illustrated.BONE if bool(k.can) else Color(Illustrated.BONE, 0.5))
	nm.add_theme_font_size_override("font_size", 16)
	nm.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	nm.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(nm)
	var sub := Label.new()
	var vv: Dictionary = k.view
	sub.text = str(k.get("name_vi", "")) if str(k.id) == "" else (tr("%d nodes · L%d") % [int(vv.get("open_nodes", 0)), int(vv.get("level_eff", 1))])
	sub.add_theme_color_override("font_color", Color(Illustrated.BONE, 0.7))
	sub.add_theme_font_size_override("font_size", 16)
	sub.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(sub)
	TooltipLayer.set_tip(b, {"title": "%s · %s" % [str(k.name), str(k.get("name_vi", ""))], "fact": str(k.reason) if not bool(k.can) else "",
		"summary": str(vv.get("idea", "")) + (("  " + tr("Taught by: %s.") % str(vv.taught_by)) if str(vv.get("taught_by", "")) != "" else "")})
	b.accessibility_name = "%s, %s%s" % [str(k.name), tr("set") if bool(k.set) else tr("known"), (", " + str(k.reason)) if not bool(k.can) else ""]
	var id: String = str(k.id)
	b.pressed.connect(func():
		_sel_node = 0
		action_requested.emit("set_diagram", [id]))
	return b


# An art card: its painted icon, name, and where it sits; with a node selected, a click places it there.
func _art_card(a: Dictionary, disabled: bool) -> Button:
	var b := Button.new()
	b.name = "Art_" + str(a.id)
	b.custom_minimum_size = Vector2(200 if not compact else 150, 56)
	b.disabled = disabled or _sel_node == 0
	for st in ["normal", "hover", "pressed", "focus", "disabled"]:
		b.add_theme_stylebox_override(st, Illustrated.box(Illustrated.PAPER_TILE if st != "hover" else Color("#E6D6AE"), Illustrated.BRASS_DIM, 1, 4.0, 3))
	var row := HBoxContainer.new()
	row.set_anchors_preset(Control.PRESET_FULL_RECT)
	row.offset_left = 4
	row.add_theme_constant_override("separation", 8)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(row)
	var ic := _art_icon(str(a.icon), 46.0, str(a.name))
	ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(ic)
	var col := VBoxContainer.new()
	col.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(col)
	var nm := Label.new()
	nm.text = str(a.name)
	nm.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	nm.custom_minimum_size = Vector2(120, 0)
	nm.add_theme_font_size_override("font_size", 16)
	nm.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(nm)
	var where := Label.new()
	where.text = (tr("in node %d") % int(a.node)) if int(a.get("node", 0)) > 0 else tr("plain slot")
	where.theme_type_variation = &"RowLabel"
	where.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(where)
	b.accessibility_name = "%s, %s" % [str(a.name), where.text]
	TooltipLayer.set_tip(b, {"title": str(a.name), "fact": where.text, "summary": tr("Select a node on the board, then click this art to place it there.") if _sel_node == 0 else tr("Place it in node %d.") % _sel_node})
	var aid: String = str(a.id)
	b.pressed.connect(func():
		var n: int = _sel_node
		_sel_node = 0
		action_requested.emit("place_diagram_art", [n, aid]))
	return b


func _art_icon(path: String, px: float, what: String) -> Control:
	var frame := PanelContainer.new()
	frame.add_theme_stylebox_override("panel", Illustrated.box(Color("#1B120C"), Illustrated.BRASS_DIM, 1, 2.0, 3))
	frame.custom_minimum_size = Vector2(px, px)
	frame.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var t := TextureRect.new()
	t.texture = Illustrated.tex(path)
	if t.texture == null:
		t.texture = PlaceholderArt.texture()
		t.stretch_mode = TextureRect.STRETCH_TILE
	else:
		t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	frame.add_child(t)
	TooltipLayer.set_tip(frame, what)
	return frame


func _build_combat_numbers(v: Dictionary, parent: Control) -> void:
	var box: VBoxContainer = section_in(parent, "combat", tr("Combat numbers"))
	var rows: Array = Array(v.get("combat", []))
	if rows.is_empty():
		line("—", box)
		return
	var by_key: Dictionary = {}
	for st in rows:
		by_key[str(st.key)] = st
	var groups: Array = COMBAT_GROUPS.duplicate(true)
	var res_keys: Array = rows.filter(func(st): return str(st.key).begins_with("resist:")).map(func(st): return str(st.key))
	if not res_keys.is_empty():
		groups.append(["Resistances", res_keys])
	for g in groups:
		var keys: Array = Array(g[1]).filter(func(k): return by_key.has(k))
		if keys.is_empty():
			continue
		var h := Label.new()
		h.text = tr(str(g[0]))
		h.theme_type_variation = &"RowLabel"
		box.add_child(h)
		var grid: GridContainer = Illustrated.grid(box, 2 if compact else 3, 6)
		for k in keys:
			var st: Dictionary = by_key[k]
			var val: float = float(st.value)
			var shown: String = ("%.0f %%" % (val * 100.0)) if k in COMBAT_SHARES else num(val)
			if k == "crit_mult":
				shown = "x%.2f" % val
			var label: String = tr(str(st.label)).trim_prefix(tr("Resistance: "))
			var tl: PanelContainer = Illustrated.tile(null, label, shown, "", 0.0)
			tl.name = "Stat_" + str(k).replace(":", "_")
			TooltipLayer.set_tip(tl, {"title": tr(str(st.label)), "fact": shown,
				"summary": tr(str(COMBAT_HINTS.get(k, "Resistance points against this damage type; negative amplifies it."))) + " " + tr("From the fighter the game compiles for your fights.")})
			grid.add_child(tl)


func _build_cong_phap(v: Dictionary, parent: Control) -> void:
	var box: VBoxContainer = section_in(parent, "cong_phap", tr("Công pháp"))
	line(tr("Speed factor:") + " " + str(v.get("speed_label", "")), box)
	var slot_names := {"main": tr("Main"), "second": tr("Second main"), "aux": tr("Art")}
	var cards := HBoxContainer.new()
	cards.add_theme_constant_override("separation", 8)
	box.add_child(cards)
	var chooser_for: Array = []
	for s in Array(v.get("slots", [])):
		var label: String = str(slot_names.get(str(s.slot), s.slot)) + ((" %d" % (int(s.index) + 1)) if str(s.slot) == "aux" else "")
		var t: Dictionary = s.get("tech", {})
		var col := VBoxContainer.new()
		col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cards.add_child(col)
		var sub: String = ""
		if not t.is_empty():
			sub = "L%d/%d" % [int(t.get("layer", 0)), int(t.get("layers", 0))]
		var cd: PanelContainer = Illustrated.card(_tech_icon(t), label, str(t.get("name", "")) if not t.is_empty() else tr("Empty"), sub)
		cd.size_flags_vertical = Control.SIZE_EXPAND_FILL
		TooltipLayer.set_tip(cd, {"title": str(t.get("name", label)), "summary": _tech_text(t) if not t.is_empty() else tr("An empty slot.")})
		col.add_child(cd)
		var change := Button.new()
		change.name = "Change_%s_%d" % [str(s.slot), int(s.index)]
		change.text = ("🔒 " if locked else "") + tr("Change")
		change.disabled = locked
		change.accessibility_name = tr("Change %s") % label.to_lower() + ((": " + tr("locked while an event waits")) if locked else "")
		if locked:
			TooltipLayer.set_tip(change, {"title": tr("Change"), "summary": tr("locked while an event waits")})
		var slot_id: String = str(s.slot)
		var idx: int = int(s.index)
		change.pressed.connect(_open_chooser.bind(slot_id, idx))
		col.add_child(change)
		if _chooser_slot.get("slot", "") == slot_id and int(_chooser_slot.get("index", -1)) == idx:
			chooser_for = [slot_id, idx, t]
	if not chooser_for.is_empty():
		_build_chooser(v, chooser_for[0], chooser_for[1], chooser_for[2], box)
	var spare: Array = Array(v.get("known", [])).filter(func(k): return not bool(k.get("slotted", false)))
	if spare.is_empty():
		row(tr("Not slotted"), tr("none"), null, box)
	for k in spare:
		row(tr("Known"), _tech_text(k) + ("" if bool(k.get("usable", true)) else "  — " + tr("unusable: your root lacks what it names")), null, box)


# A technique card's icon: its own painted icon when one exists (assets/icons/techniques/tech_<id>.png), else its first
# element's (ui_windows.json illustrated element_icons); null for an empty slot.
func _tech_icon(t: Dictionary) -> Texture2D:
	if t.is_empty():
		return null
	var own: Texture2D = Illustrated.tex(str(t.get("icon", "")))   # GameQuery.tech_icon: its own, else its type's
	if own != null:
		return own
	var els: Array = Array(t.get("elements", []))
	var icons: Dictionary = style.get("element_icons", {})
	return Illustrated.tex(_icon_path(str(icons.get(str(els[0]).to_lower(), "")))) if not els.is_empty() else null


func _tech_text(t: Dictionary) -> String:
	var parts: Array = ["%s  L%d/%d" % [str(t.get("name", "")), int(t.get("layer", 0)), int(t.get("layers", 0))]]
	if float(t.get("next_cost", -1.0)) > 0.0:
		parts.append(tr("mastery %s / %s") % [num(float(t.get("mastery", 0.0))), num(float(t.next_cost))] + (" " + tr("(gated: a higher realm)") if bool(t.get("gated", false)) else ""))
	elif int(t.get("layers", 0)) > 0:
		parts.append(tr("great completion"))
	return " · ".join(parts)


func _open_chooser(slot: String, index: int) -> void:
	if locked:
		return
	_chooser_slot = {"slot": slot, "index": index}
	_rebuild_keep("cong_phap")


## The inline chooser (pattern): the known techniques that fit the slot, then Empty; picking one requests set_slot.
func _build_chooser(v: Dictionary, slot: String, index: int, current: Dictionary, parent: Control) -> void:
	var box := VBoxContainer.new()
	box.name = "Chooser"
	parent.add_child(box)
	var first: Button = null
	for k in Array(v.get("known", [])):
		var fits: bool = (str(k.get("kind", "")) == "main") == (slot != "aux")
		if not fits:
			continue
		var b := Button.new()
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		var why: String = ""
		if not bool(k.get("usable", true)):
			why = tr("unusable: your root lacks what it names")
		elif bool(k.get("slotted", false)) and str(k.key) != str(current.get("key", "")):
			why = tr("already in a slot")
		elif str(k.key) == str(current.get("key", "")):
			why = tr("in this slot now")
		b.text = "    " + str(k.name) + (("  — " + why) if why != "" else "")
		b.disabled = why != ""
		var key: String = str(k.key)
		b.pressed.connect(func(): _pick(slot, index, key))
		box.add_child(b)
		if first == null and not b.disabled:
			first = b
	if box.get_child_count() == 0:
		line("    " + tr("No technique you know fits this slot."), box)
	var empty := Button.new()
	empty.alignment = HORIZONTAL_ALIGNMENT_LEFT
	empty.text = "    " + tr("Empty the slot")
	empty.disabled = current.is_empty()
	empty.pressed.connect(func(): _pick(slot, index, ""))
	box.add_child(empty)
	var cancel := Button.new()
	cancel.text = "    " + tr("Cancel (Esc)")
	cancel.pressed.connect(func(): cancel_inline())
	box.add_child(cancel)
	focus_later(first if first != null else cancel)


func _pick(slot: String, index: int, key: String) -> void:
	_chooser_slot = {}
	action_requested.emit("set_slot", [slot, index, key, false])


func _build_dao_do(v: Dictionary, parent: Control) -> void:
	var box: VBoxContainer = section_in(parent, "dao_do", tr("Đạo Đồ"))
	var d: Dictionary = v.get("dao_do", {})
	row(tr("Dao marks open"), "%d" % int(d.get("open", 0)), null, box)
	row(tr("Points unspent"), "%d" % int(d.get("unspent", 0)), null, box)
	var b := Button.new()
	b.text = tr("Open Đạo Đồ")
	b.pressed.connect(func(): open_requested.emit("dao_do", "", ""))
	box.add_child(b)


func _build_gear(v: Dictionary, parent: Control) -> void:
	var box: VBoxContainer = section_in(parent, "gear", tr("Gear"))
	var gear: Array = Array(v.get("gear", []))
	if gear.is_empty():
		line(tr("none"), box)
	for g in gear:
		row(tr(str(g.slot)).capitalize() if str(g.slot) != "" else tr("Piece"), str(g.name), {"title": str(g.name), "summary": str(g.text)}, box)


func _build_crafts(v: Dictionary, parent: Control) -> void:
	var box: VBoxContainer = section_in(parent, "crafts", tr("Crafts (đạo nghệ)"))
	var crafts: Array = Array(v.get("crafts", []))
	if crafts.is_empty():
		line(tr("none yet (practice raises them)"), box)
	for c in crafts:
		row(tr(str(c.id)).capitalize(), tr("level %d") % int(c.level), null, box)


func _build_fate(v: Dictionary, parent: Control) -> void:
	var box: VBoxContainer = section_in(parent, "fate", tr("Fate"))
	var f: Dictionary = v.get("fate", {})
	row(tr("Origin"), str(f.get("origin", "")), null, box)
	if str(f.get("background", "")) != "":
		row(tr("Background"), str(f.background), null, box)
	row(tr("Birth"), tr("Thiên Định (achievements on)") if str(f.get("birth_mode", "")) == "thien_dinh" else tr("Tự Định (casual)"), null, box)
	var perks: Array = Array(f.get("perks", []))
	if perks.is_empty():
		row(tr("Thiên mệnh"), tr("none"), null, box)
	for p in perks:
		row(tr("Thiên mệnh"), str(p.name), {"title": str(p.name), "summary": str(p.text)}, box)
	row(tr("Renown (danh vọng)"), tr("not tracked yet"), null, box)


func _build_lifespan(v: Dictionary, parent: Control) -> void:
	var box: VBoxContainer = section_in(parent, "lifespan", tr("Lifespan"))
	var bd: Dictionary = v.get("breakdowns", {}).get("lifespan", {})
	row(tr("Lifespan"), tr("%d years") % int(float(v.get("lifespan", 0.0))) + " · " + tr("age %d") % int(float(v.get("age", 0.0))), null, box)
	for l in Array(bd.get("lines", [])):
		line("  " + str(l), box)
