class_name FightScreen
extends ColorRect
## The fight screen (design/ux/fight-screen.md), greybox: plays back a recorded fight ([method GameQuery.practice_fight])
## in the approved layout: a header (situation, clock, pulse, the foe's realm); two mirrored columns, each with a
## portrait, name, realm and roots, the stat bars (health, body shield, ward shield, linh lực with its reserved share),
## the FORMATION row of art slots (painted icons, cooldown fill, fire flash, step and ⚡ badges, a dim veil when it
## cannot be paid), WARDS, ITEMS, BUFFS, DEBUFFS and STATUS; the fight log in the middle ([FightLog], [FightLogView]):
## newest at the top, coloured by side, Summary (folded repeats) or Full (one line per pulse), filter chips by side and
## kind, and the result-and-reasons line first once the fight has ended; one floating number per side per pulse over
## the struck side's health bar and a link line along each feed; and the playback bar.
## Every slot, chip and bar has a tooltip. The outcome is fixed before playback; the screen computes no combat
## ([FightPlayback] only adds up recorded events).
##
## Keys: Space play / pause, . and , next and previous event, 1 / 2 / 3 speed, S skip to the end, Esc closes once the
## fight has ended. What is still missing, and why, is listed in production/plans/ui-greybox-build.md.

## Esc mid-fight: the map screen opens the settings-only game menu (design/ux/game-menu.md).
signal settings_requested
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
var _log_key: String = ""
## The log's mode ("summary" or "full"), its filters ([method FightLog.default_options]) and the expanded entries.
var _log_mode: String = "summary"
var _log_opts: Dictionary = {}
var _expanded: Dictionary = {}
## Shown line id -> the entry it stands for (expand and detail on activation).
var _line_entries: Dictionary = {}
var _icon_cache: Dictionary = {}

var _situation := Label.new()
var _clock := Label.new()
var _pulse := Label.new()
var _foe_realm := Label.new()
var _cols := {}
var _log := FightLogView.new()
var _filter_buttons: Dictionary = {}
var _overlay := Control.new()
var _board := TextureRect.new()
var _play := Button.new()
var _time := Label.new()
var _scrub := HSlider.new()
var _result := Label.new()
var _back := Button.new()
var _syncing: bool = false
var _strips: Array[TextureRect] = []   # the carved strips behind the header and the playback bar (the top bar's)
var _vignette := TextureRect.new()     # a soft darkening at the board's edges (depth, as in the picked mock-up)
var _plate := StyleBoxFlat.new()       # the floating numbers' plate (fight-screen.md Accessibility)


func _init() -> void:
	visible = false
	color = Color("#2A1A12")   # the rosewood board under the tiled texture (art bible Section 2, fight replay)
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_board.stretch_mode = TextureRect.STRETCH_TILE
	_board.set_anchors_preset(Control.PRESET_FULL_RECT)
	_board.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_board)
	var grad := Gradient.new()
	grad.set_color(0, Color(0, 0, 0, 0.0))
	grad.set_color(1, Color(0, 0, 0, 0.5))
	grad.add_point(0.6, Color(0, 0, 0, 0.08))
	var vt := GradientTexture2D.new()
	vt.gradient = grad
	vt.fill = GradientTexture2D.FILL_RADIAL
	vt.fill_from = Vector2(0.5, 0.5)
	vt.fill_to = Vector2(1.15, 1.15)
	_vignette.texture = vt
	_vignette.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_vignette.stretch_mode = TextureRect.STRETCH_SCALE
	_vignette.set_anchors_preset(Control.PRESET_FULL_RECT)
	_vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_vignette)
	_plate.bg_color = Color(0.08, 0.05, 0.03, 0.78)
	_plate.set_corner_radius_all(4)
	_plate.set_border_width_all(1)
	var root := VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.offset_left = 12
	root.offset_top = 10
	root.offset_right = -12
	root.offset_bottom = -10
	root.add_theme_constant_override("separation", 6)
	add_child(root)
	var head: HBoxContainer = _strip_row(root)   # the header on the top bar's carved strip
	head.add_theme_constant_override("separation", 24)
	_situation.theme_type_variation = &"WoodHeading"
	head.add_child(_situation)
	for l in [_clock, _pulse]:
		l.theme_type_variation = &"WoodLabel"
		l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		head.add_child(l)
	TooltipLayer.set_tip(_clock, tr("The fight clock: seconds since the fight began"))
	TooltipLayer.set_tip(_pulse, tr("Pulses so far: once a second each side regenerates and its ticks resolve"))
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(spacer)
	# the result sits in the header strip, centred, so the ending costs no height (the playback bar stays on screen)
	_result.theme_type_variation = &"WoodHeading"
	_result.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_result.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	head.add_child(_result)
	var spacer2 := Control.new()
	spacer2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(spacer2)
	_foe_realm.theme_type_variation = &"WoodLabel"
	_foe_realm.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	head.add_child(_foe_realm)
	var mid := HBoxContainer.new()
	mid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	mid.add_theme_constant_override("separation", 12)
	root.add_child(mid)
	_cols["A"] = _column_shell(mid)
	var log_window := PanelContainer.new()   # the log is a parchment window (art bible 7.10)
	log_window.theme_type_variation = &"WindowPanel"
	log_window.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	log_window.size_flags_stretch_ratio = 0.8
	mid.add_child(log_window)
	var centre := VBoxContainer.new()
	centre.add_theme_constant_override("separation", 6)
	log_window.add_child(centre)
	var title_row := HBoxContainer.new()   # "FIGHT LOG" with the Summary / Full mode beside it (fight-screen.md)
	centre.add_child(title_row)
	var lt := Label.new()
	lt.text = tr("Fight log").to_upper()
	lt.theme_type_variation = &"HeadingLabel"
	lt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_row.add_child(lt)
	_build_log_filters(centre, title_row)
	_log.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_log.line_activated.connect(_on_line_activated)
	centre.add_child(_log)
	_cols["B"] = _column_shell(mid)
	var bar: HBoxContainer = _strip_row(root)   # the playback controls on the same carved strip
	bar.add_theme_constant_override("separation", 8)
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
	_time.theme_type_variation = &"WoodLabel"
	var time_box := PanelContainer.new()   # the time in a small dark frame
	var tb := StyleBoxFlat.new()
	tb.bg_color = Color(0.1, 0.06, 0.04, 0.9)
	tb.border_color = Color(0.79, 0.64, 0.35, 0.8)
	tb.set_border_width_all(1)
	tb.set_corner_radius_all(3)
	tb.content_margin_left = 10
	tb.content_margin_right = 10
	tb.content_margin_top = 2
	tb.content_margin_bottom = 2
	time_box.add_theme_stylebox_override(&"panel", tb)
	time_box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	time_box.add_child(_time)
	bar.add_child(time_box)
	_back.text = tr("Back to the map (Esc)")
	_back.visible = false
	_back.pressed.connect(close_screen)
	bar.add_child(_back)
	# floating numbers and link lines, drawn above the columns
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.draw.connect(_draw_overlay)
	add_child(_overlay)


## Applies the Rosewood theme ([method RosewoodTheme.build]) and the board's wood texture ([param wood], a tiled
## texture path from ui_hud.json "theme").
func apply_theme(t: Theme, wood: String, strip: String = "") -> void:
	theme = t
	if wood != "" and ResourceLoader.exists(wood):
		_board.texture = load(wood)
	if strip != "" and ResourceLoader.exists(strip):   # the top bar's carved strip (art bible 7.13)
		var tex: Texture2D = load(strip)
		for r in _strips:
			r.texture = tex
	# the timeline: a brass line with a brass diamond to drag (the picked mock-up)
	var line := StyleBoxFlat.new()
	line.bg_color = Color(0.79, 0.64, 0.35, 0.85)
	line.content_margin_top = 2
	line.content_margin_bottom = 2
	var area := line.duplicate() as StyleBoxFlat
	area.bg_color = Color(0.93, 0.78, 0.45)
	_scrub.add_theme_stylebox_override(&"slider", line)
	_scrub.add_theme_stylebox_override(&"grabber_area", area)
	_scrub.add_theme_stylebox_override(&"grabber_area_highlight", area)
	var d: ImageTexture = _diamond_texture(20, Color(0.85, 0.68, 0.36), Color(0.16, 0.1, 0.06))
	_scrub.add_theme_icon_override(&"grabber", d)
	_scrub.add_theme_icon_override(&"grabber_highlight", _diamond_texture(20, Color(0.98, 0.84, 0.5), Color(0.16, 0.1, 0.06)))


## A row on a carved strip (the header and the playback bar): the strip behind, the row's controls on it.
func _strip_row(parent: Control) -> HBoxContainer:
	var holder := Control.new()
	holder.custom_minimum_size = Vector2(0, 52)
	parent.add_child(holder)
	var bg := TextureRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.stretch_mode = TextureRect.STRETCH_TILE
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(bg)
	_strips.append(bg)
	var row := HBoxContainer.new()
	row.set_anchors_preset(Control.PRESET_FULL_RECT)
	row.offset_left = 14
	row.offset_right = -14
	row.alignment = BoxContainer.ALIGNMENT_BEGIN
	holder.add_child(row)
	return row


## A small diamond of [param px] in [param fill] with a [param edge] outline (the timeline's handle).
static func _diamond_texture(px: int, fill: Color, edge: Color) -> ImageTexture:
	var img := Image.create(px, px, false, Image.FORMAT_RGBA8)
	var c: float = (px - 1) * 0.5
	for y in px:
		for x in px:
			var d: float = absf(x - c) + absf(y - c)
			if d <= c - 1.5:
				img.set_pixel(x, y, fill if d < c - 4.0 else fill.darkened(0.25))
			elif d <= c:
				img.set_pixel(x, y, edge)
	return ImageTexture.create_from_image(img)


## Sets the screen's knobs (ui_hud.json "fight_screen").
func configure(cfg: Dictionary) -> void:
	_cfg = cfg
	_log.configure(cfg.get("log", {}))
	_log_opts = FightLog.default_options(cfg.get("log", {}))


## Shows [param fight] (a [method GameQuery.practice_fight] result) from the start, paused.
func open_fight(fight: Dictionary, situation: String) -> void:
	_fight = fight
	_pb = FightPlayback.from_fight(fight)
	_scrub.max_value = float(_pb.end_ms)
	_situation.text = situation
	_foe_realm.text = "%s: %s" % [tr("Foe"), str(fight.b.realm)]
	_foe_realm.add_theme_color_override("font_color", _side_colour("B"))
	for side in ["A", "B"]:
		_build_column(side, fight.a if side == "A" else fight.b)
	_t = 0.0
	_playing = false
	_log_key = ""
	_expanded = {}
	if _log_opts.is_empty():
		_log_opts = FightLog.default_options({})
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
			else:
				settings_requested.emit()   # no exit mid-fight: Esc opens the settings-only menu (hud.md Esc rules)
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
	_render_log()
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
		status.append(_effect_chip(side, eid, int(st.effects[eid]), st.bank.get(eid, null)))
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
	return {"key": "s:" + sid, "icon": _status_icon(sid),
		"count": str(int(round(float(st.stacks)))), "polarity": "debuff", "short": _pretty(sid),
		"tip": {"title": _pretty(sid), "fact": "%s ×%d · %s" % [tr("Status"), int(round(float(st.stacks))), left],
			"summary": tr("A status on this side (Status Catalogue).")}}


func _effect_chip(side: String, eid: String, n: int, bank: Variant) -> Dictionary:
	var info: Dictionary = _effect_info(side, eid)
	var lines: Array = [tr("Fired %d times so far") % n]
	if bank != null:
		lines.append(tr("Banked scale %s") % HudReadouts.stones_text(float(bank)))
	var rel: String = str(_cfg.get("effect_icons", {}).get(str(info.name), ""))
	return {"key": "e:" + eid, "icon": _icon(rel) if rel != "" else null,
		"count": str(n), "polarity": "neutral", "short": str(info.name),
		"tip": {"title": str(info.name), "fact": tr("Effect"), "summary": str(info.rule) if str(info.rule) != "" else tr("An Effect of this side's build that has fired."),
			"lines": lines}}


## The Effect a fight record id belongs to ({name, rule}, from the fight's effect_info), else the id made readable.
func _effect_info(side: String, eid: String) -> Dictionary:
	var info: Dictionary = (_fight.a if side == "A" else _fight.b).get("effect_info", {}).get(eid, {})
	if info.is_empty():
		return {"name": _pretty(eid.trim_prefix("eff:")), "rule": ""}
	return info


## A status's icon: the status_icons table (ui_hud.json) where an engine id and its icon file differ, else
## status/status_<id>.png.
func _status_icon(sid: String) -> Texture2D:
	var rel: String = str(_cfg.get("status_icons", {}).get(sid, "status/status_%s.png" % _file_id(sid)))
	return _icon(rel)


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


## One recorded row as a log line, built from a tr() template with named slots (Log list pattern).
func _line(r: Dictionary) -> String:
	var v: Array = Array(r.values)
	var target: String = str(r.other) if str(r.get("other", "")) in ["A", "B"] else FightPlayback.foe_of(str(r.side))
	var slots := {"t": "%5.1f" % (float(r.t_ms) / 1000.0), "who": _who(str(r.side)), "target": _who(target),
		"art": _art_name(str(r.side), str(r.art)), "id": _pretty(str(r.art)), "dealt": _amount(FightLog.dealt(r)),
		"n": str(int(v[0])) if v.size() > 0 else "0"}
	match str(r.kind):
		"art":
			return tr("{t}  {who} ◈ {art}").format(slots)
		"hit":
			slots.art = slots.art if str(r.art) != "" else _hit_kind_name(str(r.get("hit_kind", "")))
			return tr("{t}  {who} hits with {art}: {dealt}").format(slots)
		"tick":
			return tr("{t}  {id} ticks on {target}: {dealt}").format(slots)
		"qi_tick":
			slots.n = _amount(float(v[0]) if v.size() > 0 else 0.0)
			return tr("{t}  {who}: {id} drains {n} linh lực from {target}").format(slots)
		"soul":
			slots.qi = _amount(float(v[1]) if v.size() > 1 else 0.0)
			return tr("{t}  Soul hit on {target}: −{dealt} health, −{qi} linh lực").format(slots)
		"reflect":
			return tr("{t}  {who} reflects {dealt} back at {target}").format(slots)
		"return":
			return tr("{t}  {who} strikes back at {target}: {dealt}").format(slots)
		"step":
			return tr("{t}  {who}: {art} reaches step {n}").format(slots)
		"empower":
			return tr("{t}  {who}: {art} ⚡ empowered").format(slots)
		"feed":
			slots.to = _slot_art(str(r.side), int(v[1]) if v.size() > 1 else -1)
			slots.s = "%.1f" % ((float(v[2]) if v.size() > 2 else 0.0) / 1000.0)
			slots.art = _slot_art(str(r.side), int(v[0]) if v.size() > 0 else -1)
			return tr("{t}  {who}: {art} feeds {to}  −{s} s").format(slots)
		"stacks":
			slots.kind = tr("buff") if v.size() > 2 and float(v[2]) > 0.5 else tr("debuff")
			return tr("{t}  {who}: +{n} {id} {kind} on {target}").format(slots)
		"status":
			return tr("{t}  {who}: {id} ×{n} on {target}").format(slots)
		"cleanse":
			return tr("{t}  {who} cleanses {n} stacks").format(slots)
		"effect":
			slots.id = str(_effect_info(str(r.side), str(r.art)).name)
			return tr("{t}  {who}: {id} fires").format(slots)
		"bank":
			slots.id = str(_effect_info(str(r.side), str(r.art)).name)
			slots.n = HudReadouts.stones_text(float(v[0]) if v.size() > 0 else 0.0)
			return tr("{t}  {who}: {id} banks scale {n}").format(slots)
		"cull":
			return tr("{t}  {who} culls").format(slots)
		"down":
			return tr("{t}  {who} is down").format(slots)
		"pulse":
			return tr("{t}  {who}: pulse").format(slots)
	slots.kind = str(r.kind)
	return tr("{t}  {who}: {kind}").format(slots)


## A Summary entry's line: a fired art with what its hits dealt; a folded entry with its count and total.
func _entry_text(e: Dictionary) -> String:
	var rows: Array = _state.log
	var slots := {"t": "%5.1f" % (float(e.t_last) / 1000.0), "who": _who(str(e.side)), "art": _art_name(str(e.side), str(e.art)),
		"dealt": _amount(float(e.total)), "n": str(int(e.count)), "hits": str(int(e.hits))}
	if str(e.kind) == "art":
		if int(e.hits) > 1:
			return tr("{t}  {who} ◈ {art}: {dealt} in {hits} hits").format(slots)
		if int(e.hits) == 1:
			return tr("{t}  {who} ◈ {art}: {dealt}").format(slots)
		return tr("{t}  {who} ◈ {art}").format(slots)
	if int(e.count) > 1:
		if FightLog.DEALT_AT.has(str(e.kind)):
			if str(e.kind) == "hit":
				slots.name = _hit_kind_name(str(e.hit_kind)) if str(e.art) == "" else slots.art
			else:
				slots.name = _pretty(str(e.art))
			return tr("{t}  {who}: {name} ×{n}, {dealt} total").format(slots)
		slots.line = _line(rows[int(e.rows[0])]).substr(7)   # the first repeat's line without its time
		return tr("{t}  {line}  ×{n}").format(slots)
	return _line(rows[int(e.rows[0])])


## A Full entry's line: per shown side, the arts fired, damage dealt by type and health / linh lực after the pulse.
func _pulse_text(e: Dictionary) -> String:
	var parts: PackedStringArray = []
	for side in ["A", "B"]:
		if not bool(_log_opts.sides.get(side, true)):
			continue
		var s: Dictionary = e.sides[side]
		var arts: PackedStringArray = []
		for id in s.arts:
			arts.append(_art_name(side, str(id)) + (" ×%d" % int(s.arts[id]) if int(s.arts[id]) > 1 else ""))
		var by_type: PackedStringArray = []
		for label in s.dealt:
			by_type.append("%s %s" % [_type_name(str(label)), _amount(float(s.dealt[label]))])
		var slots := {"who": _who(side), "arts": ", ".join(arts) if not arts.is_empty() else tr("no art fired"),
			"dealt": _amount(float(s.total)), "types": ", ".join(by_type),
			"hp": _amount(maxf(0.0, float(s.hp))) if bool(s.seen) else "?", "qi": _amount(maxf(0.0, float(s.qi))) if bool(s.seen) else "?"}
		var tpl: String = tr("{who}: {arts} · after {hp} health, {qi} linh lực")
		if not by_type.is_empty():
			tpl = tr("{who}: {arts} · dealt {dealt} ({types}) · after {hp} health, {qi} linh lực")
		parts.append(tpl.format(slots))
	return "%5.1f  %s" % [float(e.t_ms) / 1000.0, "  │  ".join(parts)]


## The result-and-reasons line (only once playback has ended): the ending and who won, then up to three recorded facts.
func _result_line() -> String:
	var res: Dictionary = FightLog.result(_fight, _type_of(), 3, float(_cfg.get("log", {}).get("qi_low_share", 0.5)))
	var w: String = str(res.winner)
	var who: String = tr("you won") if w == "A" else (tr("you lost") if w == "B" else tr("no winner"))
	var head: String = tr("{ending} at {s} s: {result}").format({"ending": tr(str(res.ending).capitalize()),
		"s": "%.1f" % float(res.seconds), "result": who})
	var subj: String = str(res.subject)
	var whose: String = tr("your") if subj == "A" else tr("{name}'s").format({"name": str(_fight.b.name)})
	var said: PackedStringArray = []
	for r in res.reasons:
		match str(r.key):
			"qi_low":
				said.append(tr("{whose} linh lực was below the cheapest art's cost for {share} % of the fight").format(
					{"whose": whose, "share": "%d" % roundi(float(r.share) * 100.0)}))
			"taken_share":
				said.append(tr("{share} % of the damage {who} took was {label}").format(
					{"share": "%d" % roundi(float(r.share) * 100.0), "who": _who(subj), "label": _type_name(str(r.label))}))
			"top_source":
				var src: String = str(r.art)
				var src_name: String = _art_name(str(r.side), src)
				if src == "" or src == "basic":
					src_name = tr("Basic attacks")
				elif src.contains(":"):
					src_name = _pretty(src.get_slice(":", 1))
				said.append(tr("{art} dealt {share} % of it").format({"art": src_name, "share": "%d" % roundi(float(r.share) * 100.0)}))
			"dealt_taken":
				said.append(tr("{who} dealt {dealt} and took {taken}").format(
					{"who": _who(subj), "dealt": _amount(float(r.dealt)), "taken": _amount(float(r.taken))}))
	if said.is_empty():
		return head + "."
	var body: String = "; ".join(said)
	return "%s. %s." % [head, body.left(1).to_upper() + body.substr(1)]


## Rebuilds the log's lines when the rows shown, the mode, a filter, an expansion or the ending changed.
func _render_log() -> void:
	var rows: Array = _state.log
	var key: String = "%d|%s|%s|%s|%s|%s" % [rows.size(), _log_mode, str(_log_opts.sides), str(_log_opts.groups),
		str(_expanded.keys()), str(ended())]
	if key == _log_key:
		return
	_log_key = key
	var lines: Array = []
	_line_entries = {}
	var result_colour: Color = Color.from_string(str(_cfg.get("log", {}).get("result_color", "#F2CC73")), Color(0.95, 0.8, 0.45))
	var full_colour: Color = Color.from_string(str(_cfg.get("log", {}).get("full_color", "#DCDEE6")), Color(0.86, 0.87, 0.9))
	if ended():
		lines.append({"id": "result", "text": _result_line(), "color": result_colour})
	var entries: Array = FightLog.summary(rows, _log_opts) if _log_mode == "summary" else FightLog.full(rows, _log_opts, _type_of())
	var prefix: String = "s:" if _log_mode == "summary" else "f:"
	for k in range(entries.size() - 1, -1, -1):   # newest at the top
		var e: Dictionary = entries[k]
		var id: String = prefix + str(e.id)
		_line_entries[id] = e
		var open: bool = _expanded.has(id)
		var mark: String = "  "
		if _expandable(e):
			mark = "▾ " if open else "▸ "
		var text: String = _pulse_text(e) if _log_mode == "full" else _entry_text(e)
		var colour: Color = _side_paper(str(e.side)) if _log_mode == "summary" else full_colour
		lines.append({"id": id, "text": mark + text, "color": colour})
		if open:
			for child in _expansion(e):
				lines.append({"id": "%s>%d" % [id, int(child.row)], "text": "      " + str(child.text),
					"color": _side_paper(str(child.side)).lightened(0.15)})
	_log.set_lines(lines)


## True when activating the entry shows more: a folded entry's rows, a pulse's rows, or a hit's recorded amounts.
func _expandable(e: Dictionary) -> bool:
	return str(e.kind) in ["pulse", "hit"] or int(e.get("count", 1)) > 1 or int(e.get("hits", 0)) > 0


## The lines an expanded entry opens: its rows newest first, and for a single hit (or a fired art's hits) the amounts
## the record holds. The defence steps are not recorded yet, so this is not the Breakdown.
func _expansion(e: Dictionary) -> Array:
	var rows: Array = _state.log
	var out: Array = []
	var idx: Array = Array(e.rows)
	var single_hit: bool = str(e.kind) == "hit" and int(e.get("count", 1)) == 1
	if single_hit or (str(e.kind) == "art" and int(e.get("hits", 0)) > 0):
		for i in idx:
			var r: Dictionary = rows[int(i)]
			if str(r.kind) != "hit":
				continue
			var v: Array = Array(r.values)
			var tpl: String = tr("{before} before defence, {dealt} dealt; {target} at {hp} health. The defence steps are not recorded yet.")
			out.append({"row": int(i), "side": str(r.side), "text": tpl.format({"before": _amount(float(v[0]) if v.size() > 0 else 0.0),
				"dealt": _amount(FightLog.dealt(r)), "target": _who(FightPlayback.foe_of(str(r.side))),
				"hp": _amount(float(v[2]) if v.size() > 2 else 0.0)})})
		return out
	for k in range(idx.size() - 1, -1, -1):
		var r2: Dictionary = rows[int(idx[k])]
		out.append({"row": int(idx[k]), "side": str(r2.side), "text": _line(r2)})
	return out


## Clicking or pressing Enter on a line pauses playback and opens or closes what the line holds.
func _on_line_activated(id: String) -> void:
	_playing = false
	var base: String = id.get_slice(">", 0)
	if _line_entries.has(base) and _expandable(_line_entries[base]):
		if _expanded.has(base):
			_expanded.erase(base)
		else:
			_expanded[base] = true
	_render()
	_log.select_id(base)


## Switches the log to [param mode] ("summary" or "full").
func set_log_mode(mode: String) -> void:
	_log_mode = mode
	_expanded = {}
	for m in ["summary", "full"]:
		(_filter_buttons[m] as Button).set_pressed_no_signal(m == mode)
	if _pb != null:
		_render()


## Shows or hides [param key] in the log: a side ("A", "B") or a group (FightLog.FILTER_GROUPS).
func set_log_filter(key: String, on: bool) -> void:
	if key in ["A", "B"]:
		_log_opts.sides[key] = on
	else:
		_log_opts.groups[key] = on
	(_filter_buttons[key] as Button).set_pressed_no_signal(on)
	_dim_off(_filter_buttons[key])
	if _pb != null:
		_render()


## The log's list (for the demo checks).
func log_view() -> FightLogView:
	return _log


## The side ("A" or "B") whose entry the shown log line [param id] stands for, "" for the result line and expansions.
func log_line_side(id: String) -> String:
	return str(_line_entries[id].get("side", "")) if _line_entries.has(id) else ""


## The log's filter button for [param key] (a mode, a side or a group; for the demo checks).
func log_button(key: String) -> Button:
	return _filter_buttons.get(key)


func _build_log_filters(parent: Control, title_row: Control) -> void:
	var group := ButtonGroup.new()   # the mode: a small two-part switch beside the title
	var seg := HBoxContainer.new()
	seg.add_theme_constant_override("separation", 0)
	title_row.add_child(seg)
	_filter_button(seg, "summary", tr("Summary"), tr("One line per event; repeats fold (click a line to open it)"), group)
	_filter_button(seg, "full", tr("Full"), tr("One line per pulse: arts, damage by type, health and linh lực after"), group)
	var flow := HFlowContainer.new()   # the filters: light chips by side and by kind (interaction-patterns.md)
	flow.add_theme_constant_override("h_separation", 4)
	flow.add_theme_constant_override("v_separation", 4)
	parent.add_child(flow)
	var show := Label.new()
	show.text = tr("Show:")
	show.theme_type_variation = &"RowLabel"
	flow.add_child(show)
	_filter_button(flow, "A", tr("You"), tr("Show your lines"), null)
	_filter_button(flow, "B", tr("Foe"), tr("Show the foe's lines"), null)
	var names := {"damage": tr("Damage"), "arts": tr("Arts"), "stacks": tr("Stacks"), "status": tr("Status"),
		"feeds": tr("Feeds"), "qi": tr("Linh lực")}
	for g in FightLog.FILTER_GROUPS:
		_filter_button(flow, g, str(names[g]), tr("Show or hide {kind} lines").format({"kind": str(names[g]).to_lower()}), null)


func _filter_button(flow: Control, key: String, text: String, tip: String, grp: ButtonGroup) -> void:
	var b := Button.new()
	b.text = text
	b.toggle_mode = true
	b.button_group = grp
	b.button_pressed = key != "full"
	b.add_theme_font_size_override("font_size", int(_cfg.get("log", {}).get("chip_font_px", 14)))
	_chip_style(b, grp != null)
	TooltipLayer.set_tip(b, tip)
	if grp != null:
		b.pressed.connect(func(): set_log_mode(key))
	else:
		b.toggled.connect(func(on: bool): set_log_filter(key, on))
	_filter_buttons[key] = b
	flow.add_child(b)
	_dim_off(b)


## A light parchment chip (a filter) or a part of the mode switch ([param mode]: pressed is ink-dark with bone text);
## the text stays ink or bone in every state, so it never turns into the wood theme's colours.
func _chip_style(b: Button, mode: bool) -> void:
	var ink := Color("#2B2118")
	var bone := Color("#E8D9B5")
	var mk := func(bg: Color, border: Color) -> StyleBoxFlat:
		var sb := StyleBoxFlat.new()
		sb.bg_color = bg
		sb.border_color = border
		sb.set_border_width_all(1)
		sb.set_corner_radius_all(0 if mode else 3)
		sb.content_margin_left = 8
		sb.content_margin_right = 8
		sb.content_margin_top = 2
		sb.content_margin_bottom = 2
		return sb
	var off: Color = Color("#D8C7A0")
	var on: Color = Color("#5E4316") if mode else Color("#C9B183")
	b.add_theme_stylebox_override(&"normal", mk.call(off, Color(0.37, 0.26, 0.09, 0.55)))
	b.add_theme_stylebox_override(&"hover", mk.call(off.lightened(0.08), Color(0.37, 0.26, 0.09, 0.8)))
	b.add_theme_stylebox_override(&"pressed", mk.call(on, Color(0.37, 0.26, 0.09, 0.9)))
	b.add_theme_stylebox_override(&"hover_pressed", mk.call(on.lightened(0.06), Color(0.37, 0.26, 0.09, 0.9)))
	for k: StringName in [&"font_color", &"font_hover_color", &"font_focus_color"]:
		b.add_theme_color_override(k, ink)
	for k: StringName in [&"font_pressed_color", &"font_hover_pressed_color"]:
		b.add_theme_color_override(k, bone if mode else ink)


## An off filter is drawn dimmed as well as unpressed, so its state does not rest on the button shade alone.
func _dim_off(b: Button) -> void:
	if b.button_group == null:
		b.modulate.a = 1.0 if b.button_pressed else 0.45


func _type_of() -> Callable:
	var arts_of := {"A": Array(_fight.a.get("arts", [])), "B": Array(_fight.b.get("arts", []))}
	return func(r: Dictionary) -> String: return FightLog.type_label(r, arts_of)


func _who(side: String) -> String:
	if side == "A":
		return str(_fight.a.name)
	if side == "B":
		return str(_fight.b.name)
	return "?"


func _amount(x: float) -> String:
	return HudReadouts.stones_text(x)


func _hit_kind_name(kind: String) -> String:
	return tr("a companion") if kind == "companion" else tr("a basic attack")


## The art in [param side]'s slot [param i] (feeds name slots).
func _slot_art(side: String, i: int) -> String:
	var arts: Array = Array((_fight.a if side == "A" else _fight.b).get("arts", []))
	if i >= 0 and i < arts.size():
		return _art_name(side, str(arts[i].id))
	return tr("slot {n}").format({"n": i + 1})


# --- Overlay: floating numbers and link lines -------------------------------------------------------------------------

func _draw_overlay() -> void:
	if _pb == null or _state.is_empty():
		return
	var recent_ms: float = float(_cfg.get("recent_ms", 900))
	var link_ms: float = float(_cfg.get("link_ms", 700))
	var font: Font = get_theme_default_font()
	# One floating number per side per pulse (AC 22): the hits and ticks a side took in a pulse add up into one number,
	# coloured by the largest part, rising from that pulse's latest hit.
	var group_ms: float = float(_cfg.get("float_group_ms", 1000))
	var groups := {}
	for r in _state.recent:
		var kind0: String = str(r.kind)
		if kind0 != "hit" and kind0 != "tick":
			continue
		var target: String = FightPlayback.foe_of(str(r.side))
		if kind0 == "tick" and str(r.other) in ["A", "B"]:
			target = str(r.other)
		var gk: String = "%s|%d" % [target, int(float(r.t_ms) / group_ms)]
		var g: Dictionary = groups.get(gk, {"target": target, "sum": 0.0, "t": 0.0, "big": -1.0, "row": r, "hit": false})
		var d: float = FightLog.dealt(r)
		g.sum = float(g.sum) + d
		g.t = maxf(float(g.t), float(r.t_ms))
		g.hit = bool(g.hit) or kind0 == "hit"
		if d > float(g.big):
			g.big = d
			g.row = r
		groups[gk] = g
	for gk in groups:
		var g: Dictionary = groups[gk]
		var bar: Control = _cols[str(g.target)].hp
		var rect: Rect2 = Rect2(bar.global_position - _overlay.global_position, bar.size)
		var share: float = clampf((_t - float(g.t)) / recent_ms, 0.0, 1.0)
		var text: String = HudReadouts.stones_text(float(g.sum)) if float(g.sum) > 0.0 else tr("stopped")
		var c: Color = _hit_colour(g.row)
		c.a = 1.0 - share
		var fs: int = 22 if bool(g.hit) else 16
		var tw: float = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
		# on the struck bar's far end (the foe's bar is mirrored), rising a little as it fades
		var mirrored: bool = str(g.target) == "B"
		var x: float = rect.position.x + 14.0 if mirrored else rect.end.x - tw - 14.0
		var at := Vector2(x, rect.get_center().y + font.get_ascent(fs) * 0.4 - share * 16.0)
		var plate := Rect2(at + Vector2(-8, -font.get_ascent(fs) - 2), Vector2(tw + 16, font.get_height(fs) + 4))
		_plate.bg_color.a = 0.8 * c.a   # on a plate, so it reads over any bar (fight-screen.md Accessibility)
		_plate.border_color = Color(c.r, c.g, c.b, 0.7 * c.a)
		_overlay.draw_style_box(_plate, plate)
		draw_string_outline_on(font, at, text, fs, c)
	for r in _state.recent:
		var age: float = _t - float(r.t_ms)
		var kind: String = str(r.kind)
		var v: Array = Array(r.values)
		if kind == "feed" and age <= link_ms:
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
	var frame := PanelContainer.new()   # a carved frame over the wood board (art bible 7.10, the picked mock-up)
	frame.theme_type_variation = &"BoardPanel"
	frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(frame)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	frame.add_child(box)
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
	var portrait := PanelContainer.new()   # a dark tile in a brass rim (the picked mock-up), until portraits exist
	var tile := StyleBoxFlat.new()
	tile.bg_color = Color(0.12, 0.08, 0.05)
	tile.border_color = Color(0.79, 0.64, 0.35)
	tile.set_border_width_all(2)
	tile.set_corner_radius_all(2)
	tile.shadow_color = Color(0, 0, 0, 0.45)
	tile.shadow_size = 3
	portrait.add_theme_stylebox_override(&"panel", tile)
	portrait.custom_minimum_size = Vector2(px, px)
	var initial := Label.new()
	initial.text = str(info.name).substr(0, 1)
	initial.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	initial.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	initial.theme_type_variation = &"WoodHeading"
	portrait.add_child(initial)
	TooltipLayer.set_tip(portrait, _sheet_tip(side, info))
	var names := VBoxContainer.new()
	var nm := Label.new()
	nm.text = str(info.name) + ("  " + tr("(You)") if side == "A" else "")
	nm.theme_type_variation = &"WoodHeading"
	nm.add_theme_color_override("font_color", _side_colour(side))
	var rl := Label.new()
	rl.text = "%s · %s" % [str(info.realm), str(info.get("roots", ""))]
	rl.theme_type_variation = &"WoodLabel"
	rl.add_theme_font_size_override("font_size", 14)
	rl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART   # never truncated (Localization)
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
		w.hatched = true
		w.note = tr("(start)")
		w.set_reading(ward_total, ward_total)
	col.qi = _bar(box, tr("Linh lực"), str(bc.get("qi", "#4A8CE6")), mirror,
		tr("Linh lực pays for arts and wards; the hatched end is reserved (wards and formation)."))
	# formation (the default line until formations exist)
	var fh := _row_title(box, tr("FORMATION") + "  " + tr("default line"), mirror, &"WoodRowLabel",
		tr("The formation diagram is designed but not built in the game yet, so each side fights with its default line: plain slots only."))
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
	var rows := VBoxContainer.new()   # one parchment band per row, together filling the column (the picked mock-up)
	rows.add_theme_constant_override("separation", 4)
	rows.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(rows)
	box = rows
	var wflow := _slot_row(box, tr("WARDS"), mirror, tr("Ward slots: up, down and broken states are not in the record yet."))
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
	var iflow := _slot_row(box, tr("ITEMS"), mirror, tr("Fight items are not in the game yet."))
	for _i in int(_cfg.get("item_slots", 2)):
		var it := FightSlot.new()
		it.set_px(wpx)
		it.frame = "empty"
		TooltipLayer.set_tip(it, tr("Item slot: fight items are not in the game yet"))
		iflow.add_child(it)
	# buffs, debuffs, status
	col.buffs = _slot_row(box, tr("BUFFS"), mirror, tr("Element stacks that help this side: icon and count, green halo, ↑"))
	col.debuffs = _slot_row(box, tr("DEBUFFS"), mirror, tr("Element stacks that hurt this side: icon and count, red dashed halo, ↓"))
	col.status = _slot_row(box, tr("STATUS"), mirror, tr("Statuses on this side, and the build's Effects that have fired"))
	col.down = Label.new()
	col.down.theme_type_variation = &"HeadingLabel"
	col.down.add_theme_color_override("font_color", Color("#84191B"))
	col.down.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT if mirror else HORIZONTAL_ALIGNMENT_LEFT
	box.add_child(col.down)


## The portrait's tooltip: the side's fight sheet (spec Component Inventory, Portrait) as the fight record has it.
func _sheet_tip(side: String, info: Dictionary) -> Dictionary:
	var sh: Dictionary = info.get("sheet", {})
	var lines: Array = [
		tr("Health {hp} · linh lực {qi}").format({"hp": _amount(float(_pb.max_hp[side])), "qi": _amount(float(_pb.max_qi[side]))}),
		tr("Ward {pts} points, layer {layer}, drain {drain}").format({"pts": _amount(float(sh.get("ward_pts", 0.0))),
			"layer": "%.2f" % float(sh.get("ward_layer", 1.0)), "drain": _amount(float(sh.get("drain", 0.0)))}),
		tr("Body shield {share} % of health · block {block} points").format({"share": "%.0f" % (float(info.get("body_shield", 0.0)) * 100.0),
			"block": _amount(float(info.get("block", 0.0)))}),
		tr("Crit {crit} % (×{mult}) · evade {evade} %").format({"crit": "%.0f" % (float(info.get("crit", 0.0)) * 100.0),
			"mult": "%.2f" % float(sh.get("crit_mult", 1.7)), "evade": "%.0f" % (float(info.get("evade", 0.0)) * 100.0)})]
	var res: Dictionary = sh.get("resist", {})
	if not res.is_empty():
		var parts: PackedStringArray = []
		for k in res:
			parts.append("%s %s" % [_type_name(str(k)), _amount(float(res[k]))])
		lines.append(tr("Resistance: {list}").format({"list": ", ".join(parts)}))
	else:
		lines.append(tr("Resistance: none by type"))
	lines.append(tr("Thần thức {ds} · soul resistance {soul}").format({"ds": "%.2f" % float(sh.get("divine_sense", 1.0)),
		"soul": _amount(float(sh.get("soul_res", 0.0)))}))
	var fact: String = "%s · %s" % [str(info.realm), str(info.get("roots", ""))]
	if str(sh.get("power", "")) != "":
		fact += " · " + str(sh.power)
	return {"title": str(info.name), "fact": fact, "lines": lines}


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


func _row_title(box: Control, text: String, mirror: bool, variation: StringName, tip: String) -> Label:
	var l := Label.new()
	l.text = text
	l.theme_type_variation = variation
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT if mirror else HORIZONTAL_ALIGNMENT_LEFT
	TooltipLayer.set_tip(l, tip)
	box.add_child(l)
	return l


## One slot row as its own parchment band in a thin gilt line (the picked mock-up): the title above its slots, on the
## outer side (mirrored for the foe); the bands share the column's height, so five rows fit at 1280x720 and no empty
## parchment is left at 1920x1080 (fight-screen.md AC 15).
func _slot_row(box: Control, text: String, mirror: bool, tip: String) -> HFlowContainer:
	var rim := PanelContainer.new()
	var line := StyleBoxFlat.new()
	line.draw_center = false
	line.border_color = Color(0.37, 0.26, 0.09, 0.6)
	line.set_border_width_all(1)
	line.content_margin_left = 1
	line.content_margin_right = 1
	line.content_margin_top = 1
	line.content_margin_bottom = 1
	rim.add_theme_stylebox_override(&"panel", line)
	rim.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(rim)
	var band := PanelContainer.new()
	band.theme_type_variation = &"PaperPanel"
	rim.add_child(band)
	# tall screens: the title above the slots; below 900 px the title sits beside them, so five bands still fit
	var compact: bool = get_viewport_rect().size.y < float(_cfg.get("band_stack_min_h", 900))
	var inner: BoxContainer = HBoxContainer.new() if compact else VBoxContainer.new()
	inner.add_theme_constant_override("separation", 8 if compact else 2)
	band.add_child(inner)
	var l := _row_title(inner, text, mirror, &"RowLabel", tip)
	if compact:
		l.custom_minimum_size.x = float(_cfg.get("row_label_px", 76))
		l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var f := _flow(inner, mirror)
	f.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if compact and mirror:
		inner.move_child(f, 0)
	return f


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


## A side's colour on wood (names, the header), from fight_screen "side_colors".
func _side_colour(side: String) -> Color:
	return Color.from_string(str(_cfg.get("side_colors", {}).get(side, "#DDDDDD")), Color(0.87, 0.87, 0.87))


## A side's colour on parchment (log lines), from fight_screen "side_colors_paper" (art bible Section 4).
func _side_paper(side: String) -> Color:
	return Color.from_string(str(_cfg.get("side_colors_paper", {}).get(side, "#2B2118")), Color("#2B2118"))


## An engine id as an icon file name (ids use dashes, icon files underscores).
static func _file_id(id: String) -> String:
	return id.replace("-", "_").to_lower()


## A damage label's shown name: a damage type's name (art bible 7.5), else the element or status id made readable.
func _type_name(label: String) -> String:
	var names: Dictionary = {"phys": tr("Physical"), "fire": tr("Fire"), "cold": tr("Cold"), "lightning": tr("Lightning"),
		"force": tr("Force"), "chaos": tr("Chaos"), "soul": tr("Soul")}
	return str(names.get(label, _pretty(label)))


## An art's shown name: its library name, else the id made readable; a basic attack's or companion's hit kind by name.
func _art_name(side: String, id: String) -> String:
	if id == "basic":
		return tr("basic attack")
	if id == "companion":
		return tr("companion")
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
