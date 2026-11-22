class_name FightScreen
extends ColorRect
## The fight screen (design/ux/fight-screen.md), greybox: plays back a recorded fight ([method GameQuery.practice_fight])
## in the approved layout: a header (situation, clock, pulse, the foe's realm); two mirrored columns, each with a
## portrait, name, realm and roots, the stat bars (health, body shield, ward shield, linh lực with its reserved share),
## the FORMATION row of art slots (painted icons, cooldown fill, fire flash, step and ⚡ badges, a dim veil when it
## cannot be paid), WARDS, ITEMS, BUFFS, DEBUFFS and STATUS; the fight log in the middle, newest at the top, coloured by
## side; floating numbers over the struck side's health bar and a link line along each feed; and the playback bar.
## Every slot, chip and bar has a tooltip. The outcome is fixed before playback; the screen computes no combat
## ([FightPlayback] only adds up recorded events).
##
## Keys: Space play / pause, . and , next and previous event, 1 / 2 / 3 speed, S skip to the end, Esc closes once the
## fight has ended. What is still missing, and why, is listed in production/plans/ui-greybox-build.md.

## The player closed the screen after the fight.
signal closed

const SPEEDS := [1.0, 2.0, 4.0]
const ICONS := "res://assets/icons/"

var _cfg: Dictionary = {}
var _fight: Dictionary = {}
var _pb: FightPlayback = null
var _state: Dictionary = {}
var _t: float = 0.0
var _playing: bool = false
var _speed: float = 1.0
var _log_count: int = -1
var _icon_cache: Dictionary = {}

var _situation := Label.new()
var _clock := Label.new()
var _pulse := Label.new()
var _foe_realm := Label.new()
var _cols := {}
var _log := ItemList.new()
var _overlay := Control.new()
var _play := Button.new()
var _time := Label.new()
var _scrub := HSlider.new()
var _result := Label.new()
var _back := Button.new()
var _syncing: bool = false


func _init() -> void:
	visible = false
	color = Color(0.07, 0.08, 0.1, 1.0)
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var root := VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.offset_left = 12
	root.offset_top = 10
	root.offset_right = -12
	root.offset_bottom = -10
	root.add_theme_constant_override("separation", 6)
	add_child(root)
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 24)
	root.add_child(head)
	_situation.add_theme_font_size_override("font_size", 18)
	head.add_child(_situation)
	for l in [_clock, _pulse]:
		l.add_theme_font_size_override("font_size", 18)
		head.add_child(l)
	TooltipLayer.set_tip(_clock, tr("The fight clock: seconds since the fight began"))
	TooltipLayer.set_tip(_pulse, tr("Pulses so far: once a second each side regenerates and its ticks resolve"))
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(spacer)
	_foe_realm.add_theme_font_size_override("font_size", 18)
	head.add_child(_foe_realm)
	root.add_child(HSeparator.new())
	var mid := HBoxContainer.new()
	mid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	mid.add_theme_constant_override("separation", 12)
	root.add_child(mid)
	_cols["A"] = _column_shell(mid)
	var centre := VBoxContainer.new()
	centre.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	centre.size_flags_stretch_ratio = 0.8
	mid.add_child(centre)
	var lt := Label.new()
	lt.text = tr("FIGHT LOG")
	lt.add_theme_font_size_override("font_size", 14)
	lt.modulate = Color(0.95, 0.8, 0.45)
	centre.add_child(lt)
	_log.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_log.focus_mode = Control.FOCUS_ALL
	_log.add_theme_font_size_override("font_size", 14)
	centre.add_child(_log)
	_cols["B"] = _column_shell(mid)
	_result.add_theme_font_size_override("font_size", 20)
	_result.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(_result)
	var bar := HBoxContainer.new()
	bar.add_theme_constant_override("separation", 8)
	root.add_child(bar)
	_button(bar, "◀◀", tr("Previous event (,)"), func(): _step(-1))
	_play.text = tr("Play")
	TooltipLayer.set_tip(_play, tr("Play / pause (Space)"))
	_play.pressed.connect(_toggle)
	bar.add_child(_play)
	_button(bar, "▶▶", tr("Next event (.)"), func(): _step(1))
	for i in SPEEDS.size():
		var sp: float = SPEEDS[i]
		_button(bar, "%d×" % int(sp), tr("Speed (%d)") % (i + 1), func(): _speed = sp)
	_button(bar, tr("Skip to result"), tr("Skip to the end (S)"), _skip)
	_scrub.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_scrub.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_scrub.step = 1.0
	_scrub.value_changed.connect(func(val: float): if not _syncing: _seek(val))
	TooltipLayer.set_tip(_scrub, tr("The timeline: drag to any moment of the fight"))
	bar.add_child(_scrub)
	bar.add_child(_time)
	_back.text = tr("Back to the map (Esc)")
	_back.visible = false
	_back.pressed.connect(close_screen)
	bar.add_child(_back)
	# floating numbers and link lines, drawn above the columns
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.draw.connect(_draw_overlay)
	add_child(_overlay)


## Sets the screen's knobs (ui_hud.json "fight_screen").
func configure(cfg: Dictionary) -> void:
	_cfg = cfg


## Shows [param fight] (a [method GameQuery.practice_fight] result) from the start, paused.
func open_fight(fight: Dictionary, situation: String) -> void:
	_fight = fight
	_pb = FightPlayback.from_fight(fight)
	_scrub.max_value = float(_pb.end_ms)
	_situation.text = situation
	_foe_realm.text = "%s: %s" % [tr("Foe"), str(fight.b.realm)]
	_foe_realm.modulate = _side_colour("B")
	for side in ["A", "B"]:
		_build_column(side, fight.a if side == "A" else fight.b)
	_t = 0.0
	_playing = false
	_log_count = -1
	_render()
	visible = true
	_play.grab_focus.call_deferred()


## True once playback has reached the end.
func ended() -> bool:
	return _pb != null and _t >= float(_pb.end_ms)


## The art slots of [param side] ("A" or "B"), in loadout order (for the demo checks).
func art_slots(side: String) -> Array:
	return _cols[side].slots


## The chips shown in [param side]'s row [param row] ("buffs", "debuffs", "status").
func chips(side: String, row: String) -> Array:
	return _cols[side][row].get_children()


func close_screen() -> void:
	if not visible:
		return
	visible = false
	_playing = false
	closed.emit()


func _process(delta: float) -> void:
	if not visible or not _playing or _pb == null:
		return
	_t = minf(float(_pb.end_ms), _t + delta * 1000.0 * _speed)
	if ended():
		_playing = false
	_render()


## The screen's keys are read before the focused button sees them, so Space on a focused Play button toggles once.
func _input(event: InputEvent) -> void:
	if not visible or not (event is InputEventKey) or not event.pressed or event.echo:
		return
	match (event as InputEventKey).physical_keycode:
		KEY_SPACE:
			_toggle()
		KEY_PERIOD:
			_step(1)
		KEY_COMMA:
			_step(-1)
		KEY_1:
			_speed = SPEEDS[0]
		KEY_2:
			_speed = SPEEDS[1]
		KEY_3:
			_speed = SPEEDS[2]
		KEY_S:
			_skip()
		KEY_ESCAPE:
			if ended():
				close_screen()
		_:
			return
	get_viewport().set_input_as_handled()


func _toggle() -> void:
	if ended():
		_t = 0.0
	_playing = not _playing
	_render()


func _skip() -> void:
	_t = float(_pb.end_ms)
	_playing = false
	_render()


func _seek(t_ms: float) -> void:
	_t = clampf(t_ms, 0.0, float(_pb.end_ms))
	_playing = false
	_render()


## Moves to the next (or previous) event time.
func _step(dir: int) -> void:
	_playing = false
	var target: float = _t if dir > 0 else 0.0
	for r in _pb.rows:
		var tm: float = float(r.t_ms)
		if dir > 0 and tm > _t + 0.5:
			target = tm
			break
		if dir < 0 and tm < _t - 0.5:
			target = tm
	_t = target
	_render()


# --- Rendering --------------------------------------------------------------------------------------------------------

func _render() -> void:
	_state = _pb.state_at(_t, float(_cfg.get("recent_ms", 900)))
	var log_rows: Array = _state.log
	if log_rows.size() != _log_count:
		_log_count = log_rows.size()
		_log.clear()
		for i in range(log_rows.size() - 1, -1, -1):   # newest at the top
			var line: String = _line(log_rows[i])
			if line != "":
				var idx: int = _log.add_item(line)
				_log.set_item_custom_fg_color(idx, _side_colour(str(log_rows[i].side)))
		if _log.item_count > 0:
			_log.select(0)
			_log.ensure_current_is_visible()
	for side in ["A", "B"]:
		_render_column(side)
	_clock.text = "⏱ %.1f s" % (_t / 1000.0)
	_pulse.text = "%s %d" % [tr("pulse"), int(_state.pulses)]
	_syncing = true
	_scrub.value = _t
	_syncing = false
	_time.text = "%.1f / %.1f s" % [_t / 1000.0, float(_pb.end_ms) / 1000.0]
	_play.text = tr("Pause") if _playing else tr("Play")
	if ended():
		var w: String = str(_fight.get("winner", ""))
		var who: String = tr("you won") if w == "A" else (tr("you lost") if w == "B" else tr("no winner"))
		_result.text = "%s: %s  (%.1f s)" % [tr(str(_fight.get("ending", "")).capitalize()), who, float(_fight.get("seconds", 0.0))]
	else:
		_result.text = ""
	_back.visible = ended()
	_overlay.queue_redraw()


func _render_column(side: String) -> void:
	var col: Dictionary = _cols[side]
	var st: Dictionary = _state.sides[side]
	var info: Dictionary = _fight.a if side == "A" else _fight.b
	col.hp.set_reading(float(st.hp), float(_pb.max_hp[side]))
	col.qi.set_reading(float(st.qi), float(_pb.max_qi[side]), _reserved_amount(info, float(_pb.max_qi[side])))
	var flash_ms: float = float(_cfg.get("flash_ms", 350))
	for i in col.slots.size():
		var slot: FightSlot = col.slots[i]
		var art: Dictionary = info.arts[i]
		var id: String = str(art.id)
		var a: Dictionary = st.arts.get(id, {})
		slot.charge = _pb.charge(side, id, _t)
		var last: float = _last_fire(side, id)
		slot.flash = clampf(1.0 - (_t - last) / flash_ms, 0.0, 1.0) if last >= 0.0 else 0.0
		slot.step = int(a.get("step", 0))
		slot.empowered = bool(a.get("empowered", false))
		slot.affordable = float(st.qi) >= float(art.get("cost", 0.0)) or str(art.get("pool", "qi")) != "qi"
		slot.queue_redraw()
	var buffs: Array = []
	for el in st.buff_totals:
		buffs.append(_stack_chip(side, el, st.buff_totals[el], true))
	_set_chips(col.buffs, buffs)
	var debuffs: Array = []
	for el in st.debuff_totals:
		debuffs.append(_stack_chip(side, el, st.debuff_totals[el], false))
	_set_chips(col.debuffs, debuffs)
	var status: Array = []
	for sid in st.statuses:
		status.append(_status_chip(sid, st.statuses[sid]))
	for eid in st.effects:
		status.append(_effect_chip(eid, int(st.effects[eid]), st.bank.get(eid, null)))
	_set_chips(col.status, status)
	col.down.text = tr("DOWN") if bool(st.down) else ""


func _last_fire(side: String, art_id: String) -> float:
	var last: float = -1.0
	for tm in _pb.fires[side].get(art_id, []):
		if float(tm) <= _t:
			last = float(tm)
	return last


static func _reserved_amount(info: Dictionary, qi_max: float) -> float:
	var r: float = float(info.get("reserved", 0.0))
	return r * qi_max if r <= 1.0 else r


func _stack_chip(side: String, el: String, tot: Dictionary, buff: bool) -> Dictionary:
	var left: String = tr("no time limit") if float(tot.until) < 0.0 else tr("%.1f s left") % ((float(tot.until) - _t) / 1000.0)
	var word: String = tr("Buff") if buff else tr("Debuff")
	return {"key": "%s:%s" % ["b" if buff else "d", el], "icon": _icon("status/%s_%s.png" % ["buff" if buff else "debuff", el]),
		"count": str(int(round(float(tot.n)))), "polarity": "buff" if buff else "debuff", "short": _pretty(el),
		"tip": {"title": "%s %s ×%d" % [_pretty(el), tr("stacks"), int(round(float(tot.n)))],
			"fact": "%s · %s" % [word, left],
			"summary": tr("Element stacks: each stack strengthens its holder (buff) or weakens them (debuff) by its element's rule."),
			"lines": [tr("Counted from the record: caps and merges inside the engine are not shown yet.")]}}


func _status_chip(sid: String, st: Dictionary) -> Dictionary:
	var left: String = tr("no time limit") if float(st.until) < 0.0 else tr("%.1f s left") % ((float(st.until) - _t) / 1000.0)
	return {"key": "s:" + sid, "icon": _first_icon(["status/status_%s.png" % sid, "status/counter_%s.png" % sid, "status/stance_%s.png" % sid]),
		"count": str(int(round(float(st.stacks)))), "polarity": "debuff", "short": _pretty(sid),
		"tip": {"title": _pretty(sid), "fact": "%s ×%d · %s" % [tr("Status"), int(round(float(st.stacks))), left],
			"summary": tr("A status on this side (Status Catalogue).")}}


func _effect_chip(eid: String, n: int, bank: Variant) -> Dictionary:
	var lines: Array = [tr("Fired %d times so far") % n]
	if bank != null:
		lines.append(tr("Banked scale %s") % HudReadouts.stones_text(float(bank)))
	return {"key": "e:" + eid, "icon": _first_icon(["status/counter_%s.png" % eid, "status/stance_%s.png" % eid]),
		"count": str(n), "polarity": "neutral", "short": _pretty(eid),
		"tip": {"title": _pretty(eid), "fact": tr("Effect"), "summary": tr("An Effect of this side's build that has fired."), "lines": lines}}


## Shows [param items] in [param flow]; rebuilds the chips only when the set changes, else updates them in place.
func _set_chips(flow: Control, items: Array) -> void:
	var keys: Array = items.map(func(x): return str(x.key))
	var have: Array = flow.get_children().map(func(c): return str(c.get_meta("key", "")))
	if keys != have:
		for c in flow.get_children():
			flow.remove_child(c)
			c.queue_free()
		var px: int = int(_cfg.get("chip_px", 32))
		for x in items:
			var chip := FightChip.new()
			chip.custom_minimum_size = Vector2(px, px)
			chip.set_meta("key", str(x.key))
			flow.add_child(chip)
	var kids: Array = flow.get_children()
	for i in items.size():
		var chip: FightChip = kids[i]
		var x: Dictionary = items[i]
		chip.icon = x.icon
		chip.count = str(x.count)
		chip.polarity = str(x.polarity)
		chip.short = str(x.short)
		TooltipLayer.set_tip(chip, x.tip)
		chip.queue_redraw()


func _line(r: Dictionary) -> String:
	var who: String = str(_fight.a.name) if str(r.side) == "A" else str(_fight.b.name)
	var t: String = "%5.1f" % (float(r.t_ms) / 1000.0)
	var v: Array = Array(r.values)
	var target_name: String = str(_fight.a.name) if str(r.other) == "A" else str(_fight.b.name)
	match str(r.kind):
		"art":
			return "%s  %s ◈ %s" % [t, who, _art_name(str(r.side), str(r.art))]
		"hit":
			var label: String = _art_name(str(r.side), str(r.art)) if str(r.art) != "" else tr("Basic")
			return "%s  %s hits with %s: %s" % [t, who, label, HudReadouts.stones_text(float(v[1])) if v.size() > 1 else "?"]
		"step":
			return "%s  %s: %s reaches step %d" % [t, who, _art_name(str(r.side), str(r.art)), int(v[0]) if v.size() > 0 else 0]
		"empower":
			return "%s  %s: %s ⚡ empowered" % [t, who, _art_name(str(r.side), str(r.art))]
		"feed":
			return "%s  %s: feed → %s  −%.1f s" % [t, who, _art_name(str(r.side), str(r.art)), (float(v[2]) if v.size() > 2 else 0.0) / 1000.0]
		"stacks":
			var buff: bool = v.size() > 2 and float(v[2]) > 0.5
			return "%s  %s: %s +%d %s on %s" % [t, who, _pretty(str(r.art)), int(v[0]), tr("buff") if buff else tr("debuff"), target_name]
		"status":
			return "%s  %s: %s ×%d on %s" % [t, who, _pretty(str(r.art)), int(v[0]) if v.size() > 0 else 1, target_name]
		"cleanse":
			return "%s  %s cleanses %d stacks" % [t, who, int(v[0]) if v.size() > 0 else 0]
		"effect":
			return "%s  %s: %s" % [t, who, _pretty(str(r.art))]
		"down":
			return "%s  %s is down" % [t, who]
	return ""


# --- Overlay: floating numbers and link lines -------------------------------------------------------------------------

func _draw_overlay() -> void:
	if _pb == null or _state.is_empty():
		return
	var recent_ms: float = float(_cfg.get("recent_ms", 900))
	var link_ms: float = float(_cfg.get("link_ms", 700))
	var font: Font = get_theme_default_font()
	var n: int = 0
	for r in _state.recent:
		var age: float = _t - float(r.t_ms)
		var kind: String = str(r.kind)
		var v: Array = Array(r.values)
		if kind == "hit" or kind == "tick":
			var target: String = FightPlayback.foe_of(str(r.side)) if kind == "hit" else (str(r.other) if str(r.other) in ["A", "B"] else FightPlayback.foe_of(str(r.side)))
			var bar: Control = _cols[target].hp
			var rect: Rect2 = Rect2(bar.global_position - _overlay.global_position, bar.size)
			var share: float = age / recent_ms
			var jitter: float = float((n * 53) % 120) - 60.0
			n += 1
			var dealt: float = float(v[1]) if v.size() > 1 else 0.0
			var text: String = HudReadouts.stones_text(dealt) if dealt > 0.0 else tr("stopped")
			var c: Color = _hit_colour(r)
			c.a = 1.0 - share
			var fs: int = 22 if kind == "hit" else 16
			var at := Vector2(rect.get_center().x + jitter, rect.end.y + 26.0 - share * 34.0)   # rises over the bar
			draw_string_outline_on(font, at, text, fs, c)
		elif kind == "feed" and age <= link_ms:
			var slots: Array = _cols[str(r.side)].slots
			var i: int = int(v[0]) if v.size() > 0 else -1
			var j: int = int(v[1]) if v.size() > 1 else -1
			if i >= 0 and j >= 0 and i < slots.size() and j < slots.size():
				var a: Vector2 = (slots[i] as Control).get_global_rect().get_center() - _overlay.global_position
				var b: Vector2 = (slots[j] as Control).get_global_rect().get_center() - _overlay.global_position
				var c2 := Color(0.95, 0.85, 0.4, 1.0 - age / link_ms)
				_overlay.draw_line(a, b, c2, 3.0)
				var dir: Vector2 = (b - a).normalized()
				_overlay.draw_line(b - dir * 14.0, b - dir * 24.0 + dir.orthogonal() * 7.0, c2, 3.0)
				_overlay.draw_line(b - dir * 14.0, b - dir * 24.0 - dir.orthogonal() * 7.0, c2, 3.0)
				draw_string_outline_on(font, b + Vector2(-16, -30), "−%.1f s" % ((float(v[2]) if v.size() > 2 else 0.0) / 1000.0), 14, c2)


func draw_string_outline_on(font: Font, at: Vector2, text: String, fs: int, c: Color) -> void:
	_overlay.draw_string_outline(font, at, text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, 5, Color(0, 0, 0, c.a))
	_overlay.draw_string(font, at, text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, c)


## A hit's colour: its art's damage type (art bible 7.5), physical for a basic attack; a tick's its element.
func _hit_colour(r: Dictionary) -> Color:
	var cols: Dictionary = _cfg.get("dtype_colors", {})
	if str(r.kind) == "tick":
		return Color.from_string(str(_cfg.get("element_colors", {}).get(str(r.art), "#DDDDDD")), Color(0.87, 0.87, 0.87))
	var info: Dictionary = _fight.a if str(r.side) == "A" else _fight.b
	var dtype: String = "phys"
	for art in info.arts:
		if str(art.id) == str(r.art):
			dtype = str(art.get("dtype", "phys"))
	return Color.from_string(str(cols.get(dtype, "#DDDDDD")), Color(0.87, 0.87, 0.87))


# --- Building ---------------------------------------------------------------------------------------------------------

func _column_shell(parent: Control) -> Dictionary:
	var box := VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 4)
	parent.add_child(box)
	return {"box": box, "slots": []}


## Builds [param side]'s column from its loadout [param info].
func _build_column(side: String, info: Dictionary) -> void:
	var col: Dictionary = _cols[side]
	var box: VBoxContainer = col.box
	for c in box.get_children():
		box.remove_child(c)
		c.queue_free()
	var mirror: bool = side == "B"
	# portrait, name, realm and roots
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 8)
	top.alignment = BoxContainer.ALIGNMENT_END if mirror else BoxContainer.ALIGNMENT_BEGIN
	box.add_child(top)
	var px: int = int(_cfg.get("portrait_px", 56))
	var portrait := PanelContainer.new()
	portrait.custom_minimum_size = Vector2(px, px)
	var initial := Label.new()
	initial.text = str(info.name).substr(0, 1)
	initial.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	initial.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	initial.add_theme_font_size_override("font_size", 26)
	portrait.add_child(initial)
	TooltipLayer.set_tip(portrait, {"title": str(info.name), "fact": "%s · %s" % [str(info.realm), str(info.get("roots", ""))],
		"lines": ["%s %.0f %%" % [tr("Crit chance"), float(info.get("crit", 0.0)) * 100.0],
			"%s %.0f %%" % [tr("Evade"), float(info.get("evade", 0.0)) * 100.0],
			"%s %s" % [tr("Block points"), HudReadouts.stones_text(float(info.get("block", 0.0)))]]})
	var names := VBoxContainer.new()
	var nm := Label.new()
	nm.text = str(info.name) + ("  " + tr("(You)") if side == "A" else "")
	nm.add_theme_font_size_override("font_size", 18)
	nm.modulate = _side_colour(side)
	var rl := Label.new()
	rl.text = "%s · %s" % [str(info.realm), str(info.get("roots", ""))]
	rl.add_theme_font_size_override("font_size", 14)
	rl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	names.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for l in [nm, rl]:
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT if mirror else HORIZONTAL_ALIGNMENT_LEFT
		names.add_child(l)
	if mirror:
		top.add_child(names)
		top.add_child(portrait)
	else:
		top.add_child(portrait)
		top.add_child(names)
	# bars
	var bc: Dictionary = _cfg.get("bar_colors", {})
	col.hp = _bar(box, tr("Health"), str(bc.get("health", "#C04040")), mirror, tr("Health: at 0 this side is down."))
	var body: float = float(info.get("body_shield", 0.0))
	if body > 0.0:
		var b := _bar(box, tr("Body shield"), str(bc.get("body", "#B08A5A")), mirror,
			tr("The body shield sits over health; chaos and Soul pass it. Its drain is not in the record yet."))
		b.note = tr("(start)")
		b.set_reading(body * float(_pb.max_hp[side]), body * float(_pb.max_hp[side]))
	var ward_total: float = 0.0
	for sh in Array(info.get("shields", [])):
		if not bool(sh.get("body", false)):
			ward_total += float(sh.get("size", 0.0))
	if ward_total > 0.0:
		var w := _bar(box, tr("Ward shield"), str(bc.get("ward", "#7AB8D8")), mirror,
			tr("Ward shields in slot order. Their soaking is not in the record yet."))
		w.note = tr("(start)")
		w.set_reading(ward_total, ward_total)
	col.qi = _bar(box, tr("Linh lực"), str(bc.get("qi", "#4A8CE6")), mirror,
		tr("Linh lực pays for arts and wards; the hatched end is reserved (wards and formation)."))
	# formation (the default line until formations exist)
	var fh := _row_title(box, tr("FORMATION") + "  " + tr("default line"), mirror,
		tr("The formation diagram is designed but not built in the game yet, so each side fights with its default line: plain slots only."))
	fh.modulate = Color(0.95, 0.8, 0.45)
	var arts_flow := _flow(box, mirror)
	col.slots = []
	var spx: int = int(_cfg.get("slot_px", 48))
	for i in Array(info.arts).size():
		var art: Dictionary = info.arts[i]
		var slot := FightSlot.new()
		slot.set_px(spx)
		slot.icon = _icon("arts/art_%s.png" % _file_id(str(art.id)))
		var sd: String = side
		var idx: int = i
		TooltipLayer.set_tip(slot, func(_at: Vector2) -> Dictionary: return _art_tip(sd, idx))
		arts_flow.add_child(slot)
		col.slots.append(slot)
	# wards, items
	_row_title(box, tr("WARDS"), mirror, tr("Ward slots: up, down and broken states are not in the record yet."))
	var wflow := _flow(box, mirror)
	var wpx: int = int(_cfg.get("ward_px", 40))
	var wards: Array = Array(info.get("wards", []))
	if wards.is_empty():
		var empty := FightSlot.new()
		empty.set_px(wpx)
		empty.frame = "empty"
		TooltipLayer.set_tip(empty, tr("No ward in this slot"))
		wflow.add_child(empty)
	for w in wards:
		var ws := FightSlot.new()
		ws.set_px(wpx)
		ws.frame = "ward"
		ws.icon = _first_icon(["wards/ward_%s.png" % _file_id(str(w.id)), "wards/ward_default.png"])
		TooltipLayer.set_tip(ws, {"title": _pretty(str(w.id)), "fact": "%s · %s" % [tr("Ward"), _pretty(str(w.model))],
			"lines": ["%s %s" % [tr("Cost"), HudReadouts.stones_text(float(w.cost))], "%s %s" % [tr("Drain"), HudReadouts.stones_text(float(w.drain))],
				"%s %.1f s · %s %.1f s" % [tr("Cooldown"), float(w.cooldown), tr("up"), float(w.up)],
				"%s %s · %s %s" % [tr("Shield"), HudReadouts.stones_text(float(w.shield)), tr("block"), HudReadouts.stones_text(float(w.block))]]})
		wflow.add_child(ws)
	_row_title(box, tr("ITEMS"), mirror, tr("Fight items are not in the game yet."))
	var iflow := _flow(box, mirror)
	for _i in int(_cfg.get("item_slots", 2)):
		var it := FightSlot.new()
		it.set_px(wpx)
		it.frame = "empty"
		TooltipLayer.set_tip(it, tr("Item slot: fight items are not in the game yet"))
		iflow.add_child(it)
	# buffs, debuffs, status
	_row_title(box, tr("BUFFS"), mirror, tr("Element stacks that help this side: icon and count, green halo, ↑"))
	col.buffs = _flow(box, mirror)
	_row_title(box, tr("DEBUFFS"), mirror, tr("Element stacks that hurt this side: icon and count, red dashed halo, ↓"))
	col.debuffs = _flow(box, mirror)
	_row_title(box, tr("STATUS"), mirror, tr("Statuses on this side, and the build's Effects that have fired"))
	col.status = _flow(box, mirror)
	col.down = Label.new()
	col.down.add_theme_font_size_override("font_size", 22)
	col.down.modulate = Color(1, 0.45, 0.4)
	col.down.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT if mirror else HORIZONTAL_ALIGNMENT_LEFT
	box.add_child(col.down)


func _art_tip(side: String, i: int) -> Dictionary:
	var info: Dictionary = _fight.a if side == "A" else _fight.b
	var art: Dictionary = info.arts[i]
	var a: Dictionary = _state.get("sides", {}).get(side, {}).get("arts", {}).get(str(art.id), {})
	var lines: Array = [
		"%s %d · %s %s" % [tr("Fired"), int(a.get("count", 0)), tr("damage so far"), HudReadouts.stones_text(float(a.get("dmg", 0.0)))],
		"%s %.0f %%" % [tr("Charged"), _pb.charge(side, str(art.id), _t) * 100.0]]
	if int(art.get("steps", 0)) > 0:
		lines.append("%s %d / %d" % [tr("Step"), int(a.get("step", 0)), int(art.steps)])
	if bool(a.get("empowered", false)):
		lines.append(tr("⚡ Empowered for its next firing"))
	var kind: String = _pretty(str(art.get("dtype", "phys")))
	if str(art.get("element", "")) != "":
		kind = "%s · %s" % [_pretty(str(art.element)), kind]
	if str(art.get("rule", "")) != "":
		lines.push_front(str(art.rule))
	return {"id": "%s:%d" % [side, i], "title": _art_name(side, str(art.id)),
		"fact": "%s %.1f s · %s %s %s" % [tr("Cooldown"), float(art.cd), tr("costs"), HudReadouts.stones_text(float(art.cost)), tr("linh lực")],
		"summary": kind, "lines": lines}


func _bar(box: Control, title: String, colour: String, mirror: bool, tip: String) -> FightStatBar:
	var b := FightStatBar.new()
	b.title = title
	b.fill = Color.from_string(colour, Color(0.7, 0.3, 0.3))
	b.mirrored = mirror
	TooltipLayer.set_tip(b, tip)
	box.add_child(b)
	return b


func _row_title(box: Control, text: String, mirror: bool, tip: String) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", 14)
	l.modulate = Color(0.75, 0.77, 0.85)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT if mirror else HORIZONTAL_ALIGNMENT_LEFT
	TooltipLayer.set_tip(l, tip)
	box.add_child(l)
	return l


func _flow(box: Control, mirror: bool) -> HFlowContainer:
	var f := HFlowContainer.new()
	f.alignment = FlowContainer.ALIGNMENT_END if mirror else FlowContainer.ALIGNMENT_BEGIN
	f.add_theme_constant_override("h_separation", 6)
	f.add_theme_constant_override("v_separation", 4)
	f.custom_minimum_size = Vector2(0, 32)
	box.add_child(f)
	return f


func _icon(rel: String) -> Texture2D:
	if _icon_cache.has(rel):
		return _icon_cache[rel]
	var path: String = ICONS + rel
	var tex: Texture2D = load(path) as Texture2D if ResourceLoader.exists(path) else null
	_icon_cache[rel] = tex
	return tex


func _first_icon(rels: Array) -> Texture2D:
	for rel in rels:
		var t: Texture2D = _icon(str(rel))
		if t != null:
			return t
	return null


func _side_colour(side: String) -> Color:
	return Color.from_string(str(_cfg.get("side_colors", {}).get(side, "#DDDDDD")), Color(0.87, 0.87, 0.87))


## An engine id as an icon file name (ids use dashes, icon files underscores).
static func _file_id(id: String) -> String:
	return id.replace("-", "_").to_lower()


## An art's shown name: its library name, else the id made readable.
func _art_name(side: String, id: String) -> String:
	var info: Dictionary = _fight.a if side == "A" else _fight.b
	for art in info.get("arts", []):
		if str(art.id) == id and str(art.get("name", "")) != "":
			return str(art.name)
	return _pretty(id)


static func _pretty(id: String) -> String:
	return id.replace("-", " ").replace("_", " ").capitalize()


func _button(parent: Control, text: String, tip: String, fn: Callable) -> Button:
	var b := Button.new()
	b.text = text
	TooltipLayer.set_tip(b, tip)
	b.pressed.connect(fn)
	parent.add_child(b)
	return b
