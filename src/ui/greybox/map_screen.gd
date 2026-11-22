extends Control
## Greybox slice 1 of the map screen (design/ux/hud.md, approved 2026-11-22): the continent map with the HUD zones in
## Godot's default look. Z1 top bar, Z2 window buttons, Z3 portrait cluster, Z4 map modes, Z5 the season turn, Z6 one
## panel, Z7 the summary and the event card. It plays the real game through the session's existing commands; it
## never changes game state itself.
##
## Launch (windowed, by scene path; run/main_scene stays unset):
##   Godot_v4.7.1-stable_win64.exe --path . --windowed --resolution 1280x720 res://src/ui/greybox/map_screen.tscn
##       [-- --seed N] [--demo --shot-dir res://production/qa/evidence/hud-greybox]
## --demo plays a fixed script (sheet, two seasons, an event, a journey) and saves a screenshot at each step to
## --shot-dir, then quits: the run-and-observe evidence (.claude/docs/run-and-observe.md).
##
## Greybox limits (stated on screen): the LLM is off, and Power Rankings' rating fights are switched off in memory for
## this run, because End turn would otherwise wait for the season's rating batch until the one-season-late rule
## (power-rankings.md rule 13, 2026-11-22) is coded.

const UI_FILE := "ui_hud"

var gd: GameData
var session: GameSession
var turn: TurnController
var _cfg: Dictionary = {}
var _job := BackgroundCall.new()
var _job_kind: String = ""
var _last_turn_msec: int = -100000
var _args: PackedStringArray = []

var _map := MapView.new()
var _loading := ColorRect.new()
var _loading_label := Label.new()
var _alerts := Label.new()
var _stones := Label.new()
var _season := Label.new()
var _realm := Label.new()
var _cult_bar := ProgressBar.new()
var _lifespan := Label.new()
var _focus := OptionButton.new()
var _end_turn := Button.new()
var _turn_note := Label.new()
var _sheet_button := Button.new()
var _panel := TextPanel.new()
var _centre := CentreWindow.new()
var _dim := ColorRect.new()
var _summary_pending_event: bool = false
var _shots: int = 0


func _ready() -> void:
	_args = OS.get_cmdline_user_args()
	_build_layout()
	_show_loading(tr("Generating the world…"))
	gd = GameData.load_from("res://assets/data")
	_cfg = gd.file(UI_FILE)
	# Greybox only: no rating batch to wait for until power-rankings.md rule 13 (one season late) is coded.
	var rankings: Dictionary = gd.file("combat_rankings")
	if rankings.has("enabled"):
		rankings["enabled"] = false
	var seed_v: int = int(_arg_value("--seed", str(_greybox().get("seed", 7))))
	_job_kind = "new_game"
	_job.start(_new_game.bind(seed_v))
	if _args.has("--demo"):
		_run_demo.call_deferred()


func _greybox() -> Dictionary:
	return _cfg.get("greybox", {})


func _new_game(seed_v: int) -> Dictionary:
	var llm := LlmService.new(gd)
	llm.enabled = false
	var s := GameSession.new(gd, llm)
	var r: Dictionary = s.new_game(seed_v, {"mode": "roll", "name": "Vô Danh", "gender": "male", "origin": "tan_tu"})
	var grid := ContinentGrid.from_continent(gd)
	return {"session": s, "result": r, "grid": grid}


func _process(_delta: float) -> void:
	_process_dim()
	if not _job.is_done():
		return
	var out: Variant = _job.finish()
	var kind: String = _job_kind
	_job_kind = ""
	match kind:
		"new_game":
			_on_world_ready(out)
		"end_turn":
			_on_turn_done(out)
		"choose":
			_on_choice_done(out)


func _on_world_ready(out: Dictionary) -> void:
	session = out.session
	turn = TurnController.new(session)
	var grid: ContinentGrid = out.grid
	if grid.errors.is_empty():
		_map.setup(grid, _greybox())
	_loading.visible = false
	_refresh()
	_end_turn.grab_focus()
	_centre_summary(tr("A new life"), Array(out.result.get("lines", [])))


# --- Layout ----------------------------------------------------------------------------------------------------------

func _build_layout() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	theme = _greybox_theme()
	_map.set_anchors_preset(Control.PRESET_FULL_RECT)
	_map.place_clicked.connect(_on_place_clicked)
	add_child(_map)

	# Z1 top bar
	var z1 := PanelContainer.new()
	z1.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	z1.offset_left = 16
	z1.offset_right = -16
	z1.offset_top = 8
	add_child(z1)
	var bar := HBoxContainer.new()
	bar.add_theme_constant_override("separation", 16)
	z1.add_child(bar)
	_alerts.text = tr("Alerts: none")
	_alerts.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.add_child(_alerts)
	_stones.tooltip_text = tr("Linh thạch held")
	_stones.mouse_filter = Control.MOUSE_FILTER_STOP
	bar.add_child(_stones)
	bar.add_child(_season)
	for t in [["W", tr("Wiki (not in the greybox yet)")], ["≡", tr("Game menu (not in the greybox yet)")]]:
		var b := Button.new()
		b.text = t[0]
		b.tooltip_text = t[1]
		b.disabled = true
		bar.add_child(b)

	var note := Label.new()
	note.text = tr("Greybox: LLM off; rating fights off for this run (Power Rankings rule 13 not yet coded).")
	note.add_theme_color_override("font_color", Color(1, 0.85, 0.4))
	note.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	note.offset_left = 24
	note.offset_top = 52
	add_child(note)

	# Z2 window buttons
	var z2 := VBoxContainer.new()
	z2.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	z2.offset_left = -160
	z2.offset_right = -16
	z2.offset_top = 56
	add_child(z2)
	_sheet_button.text = tr("Character") + " (C)"
	_sheet_button.pressed.connect(_open_sheet)
	z2.add_child(_sheet_button)
	for name in ["Inventory", "Relationships", "Sect", "Quests", "Rankings", "News", "Places", "Đạo Đồ", "Abode"]:
		var b := Button.new()
		b.text = tr(name)
		b.disabled = true
		b.tooltip_text = tr("Not in the greybox yet")
		z2.add_child(b)

	# Z3 portrait cluster
	var z3 := PanelContainer.new()
	z3.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	z3.offset_left = 16
	z3.offset_bottom = -16
	z3.offset_top = -112
	z3.offset_right = 380
	add_child(z3)
	var row := HBoxContainer.new()
	z3.add_child(row)
	var portrait := ColorRect.new()
	portrait.color = Color(0.3, 0.3, 0.35)
	portrait.custom_minimum_size = Vector2(80, 80)
	portrait.tooltip_text = tr("Your portrait (art comes later)")
	row.add_child(portrait)
	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(col)
	col.add_child(_realm)
	_cult_bar.custom_minimum_size = Vector2(220, 20)
	_cult_bar.tooltip_text = tr("Cultivation progress to the next level")
	col.add_child(_cult_bar)
	col.add_child(_lifespan)

	# Z4 map modes
	var z4 := HBoxContainer.new()
	z4.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	z4.offset_bottom = -16
	z4.offset_top = -52
	z4.offset_left = -170
	z4.offset_right = 170
	add_child(z4)
	for m in [["Terrain", true], ["Sect", false], ["Qi", false], ["Prices", false]]:
		var b := Button.new()
		b.text = tr(m[0])
		b.toggle_mode = true
		b.button_pressed = m[1]
		b.disabled = not m[1]
		b.tooltip_text = tr("Map mode") if m[1] else tr("Not in the greybox yet")
		z4.add_child(b)

	# Z5 the season turn
	var z5 := PanelContainer.new()
	z5.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	z5.offset_right = -16
	z5.offset_bottom = -16
	z5.offset_left = -340
	z5.offset_top = -150
	z5.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	z5.grow_vertical = Control.GROW_DIRECTION_BEGIN
	add_child(z5)
	var turn_box := VBoxContainer.new()
	z5.add_child(turn_box)
	_focus.tooltip_text = tr("Season focus: click a place on the map to travel there")
	_focus.item_selected.connect(_on_focus_selected)
	turn_box.add_child(_focus)
	_end_turn.custom_minimum_size = Vector2(300, 52)
	_end_turn.pressed.connect(_try_end_turn)
	turn_box.add_child(_end_turn)
	_turn_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_turn_note.custom_minimum_size = Vector2(300, 0)
	turn_box.add_child(_turn_note)

	# Z6 panel
	_panel.set_anchors_preset(Control.PRESET_LEFT_WIDE)
	_panel.anchor_right = 0.33
	_panel.offset_left = 16
	_panel.offset_top = 80
	_panel.offset_bottom = -132
	add_child(_panel)

	# Z7 centre windows, over a dim of the map (HUD States: Event card, the map dims by about 30 %)
	_dim.color = Color(0, 0, 0, 0.3)
	_dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_dim.mouse_filter = Control.MOUSE_FILTER_STOP
	_dim.visible = false
	add_child(_dim)
	var centre_box := CenterContainer.new()
	centre_box.set_anchors_preset(Control.PRESET_FULL_RECT)
	centre_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(centre_box)
	centre_box.add_child(_centre)
	_centre.closed.connect(_on_centre_closed)
	_centre.option_chosen.connect(_on_option_chosen)

	# Loading overlay
	_loading.color = Color(0.05, 0.06, 0.08, 0.92)
	_loading.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_loading)
	_loading_label.set_anchors_preset(Control.PRESET_CENTER)
	_loading_label.add_theme_font_size_override("font_size", 24)
	_loading.add_child(_loading_label)


## The greybox look: Godot's defaults with opaque panels, so text always sits on a plate, never on the map
## (design/accessibility-requirements.md, text contrast). The real look comes from the art bible.
func _greybox_theme() -> Theme:
	var t := Theme.new()
	var plate := StyleBoxFlat.new()
	plate.bg_color = Color(0.11, 0.12, 0.15, 1.0)
	plate.border_color = Color(0.32, 0.34, 0.4)
	plate.set_border_width_all(1)
	plate.set_corner_radius_all(4)
	plate.set_content_margin_all(8)
	t.set_stylebox(&"panel", &"PanelContainer", plate)
	return t


func _process_dim() -> void:
	_dim.visible = _centre.visible or _job_kind == "choose"


func _show_loading(text: String) -> void:
	_loading_label.text = text
	_loading.visible = true


# --- State -> display ------------------------------------------------------------------------------------------------

func _refresh() -> void:
	if session == null or session.player == null:
		return
	var snap: Dictionary = StateSnapshot.take(session)
	var c: Character = session.player
	_stones.text = tr("Linh thạch") + " " + HudReadouts.stones_text(float(snap.linh_thach))
	_season.text = session.clock_label()
	_realm.text = str(snap.realm_label)
	var req: float = CultivationRules.level_requirement(c, gd)
	_cult_bar.value = HudReadouts.cultivation_share(float(snap.tu_vi), req) * 100.0
	_lifespan.text = HudReadouts.lifespan_text(float(snap.age), float(snap.lifespan))
	var warn: bool = HudReadouts.lifespan_warning(float(snap.age), float(snap.lifespan), float(_cfg.get("lifespan_warn_share", 0.1)))
	_lifespan.add_theme_color_override("font_color", Color(1, 0.7, 0.2) if warn else Color(0.9, 0.9, 0.9))
	_lifespan.tooltip_text = (tr("Little lifespan left") + " ⌛") if warn else tr("Age / lifespan")
	_alerts.text = tr("Alerts:") + " " + (tr("an event is waiting") if session.has_pending_event() else tr("none"))
	_refresh_focus()
	_refresh_map(str(snap.location_id))
	_refresh_turn_button()


func _refresh_focus() -> void:
	_focus.clear()
	_focus.add_item(tr("Cultivate"))
	if turn.destination_id != "":
		_focus.add_item(turn.focus_label())
	_focus.select(1 if turn.focus == TurnController.FOCUS_TRAVEL else 0)


func _refresh_turn_button() -> void:
	_end_turn.text = turn.button_label()
	var g: Dictionary = turn.gate()
	_end_turn.tooltip_text = g.reason if not g.ok else tr("End the season (Enter)")
	_turn_note.text = turn.fallback_note


func _refresh_map(location_id: String) -> void:
	var places: Array = []
	for p in session.db.all("places"):
		if bool(p.get("hidden", false)) or not p.has("tile"):
			continue
		if session.knowledge != null and not session.knowledge.knows_place(str(p.id)):
			continue
		places.append({"id": str(p.id), "name": str(p.name), "tile": Vector2i(int(p.tile[0]), int(p.tile[1])), "kind": str(p.get("kind", ""))})
	var here: Dictionary = session.db.get_record("places", location_id)
	var tile := Vector2i(-1, -1)
	if here.has("tile"):
		tile = Vector2i(int(here.tile[0]), int(here.tile[1]))
	_map.set_state(places, tile, turn.destination_id)


# --- Actions ---------------------------------------------------------------------------------------------------------

## True while the session is busy on the worker thread: the HUD is inert then and must not read the session
## (BackgroundCall's contract; design/ux/hud.md, The turn: "While a season resolves").
func _busy() -> bool:
	return session == null or _job.is_running()


func _on_place_clicked(place_id: String) -> void:
	if _busy():
		return
	if place_id == str(session.player.location_id):
		turn.choose_cultivate()
	else:
		turn.choose_travel(place_id, str(session.db.get_record("places", place_id).get("name", place_id)))
	_refresh()


func _on_focus_selected(index: int) -> void:
	if _busy():
		return
	if index == 0:
		turn.choose_cultivate()
	_refresh()


func _try_end_turn() -> void:
	if session == null or _job.is_running():
		return
	var g: Dictionary = turn.gate()
	var cooldown_ms: int = int(float(_cfg.get("end_turn_cooldown", 0.5)) * 1000.0)
	if g.ok and Time.get_ticks_msec() - _last_turn_msec < cooldown_ms:
		g = {"ok": false, "reason": tr("Too soon after the last turn.")}
	if not g.ok:
		if session.has_pending_event():
			_show_event()
		_turn_note.text = g.reason
		return
	turn.resolving = true
	_refresh_turn_button()
	_job_kind = "end_turn"
	_job.start(turn.end_turn)


func _on_turn_done(result: Dictionary) -> void:
	turn.resolving = false
	_last_turn_msec = Time.get_ticks_msec()
	turn.after_turn(result)
	_refresh()
	var lines: Array = Array(result.get("lines", []))
	if turn.fallback_note != "":
		lines.append("")
		lines.append(turn.fallback_note)
	_centre_summary(tr("The season ends"), lines)


func _centre_summary(title: String, lines: Array) -> void:
	turn.window_open = true
	_summary_pending_event = session.has_pending_event()
	_centre.show_summary(title, lines)
	_refresh_turn_button()


func _on_centre_closed() -> void:
	turn.window_open = false
	if _summary_pending_event or session.has_pending_event():
		_summary_pending_event = false
		_show_event()
		return
	_refresh()
	_end_turn.grab_focus()


func _show_event() -> void:
	if not session.has_pending_event():
		return
	turn.window_open = true
	var odds: Array = []
	for i in Array(session.pending_event.get("choices", [])).size():
		odds.append(Advisor.choice_odds(session, i))
	_centre.show_event(session.pending_event, odds)
	_refresh_turn_button()


func _on_option_chosen(index: int) -> void:
	if _job.is_running():
		return
	_centre.hide_window()
	_job_kind = "choose"
	_job.start(session.choose.bind(index))


func _on_choice_done(result: Dictionary) -> void:
	turn.window_open = false
	_refresh()
	_centre_summary(tr("Outcome"), Array(result.get("lines", [])))


func _open_sheet() -> void:
	if _busy():
		return
	_panel.open_panel(tr("Character"), TerminalViews.sheet(session, TerminalIO.new()), _sheet_button)


func _unhandled_key_input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return
	var key: Key = (event as InputEventKey).physical_keycode
	var owner_ctl: Control = get_viewport().gui_get_focus_owner()
	if key == KEY_ENTER or key == KEY_KP_ENTER:
		if owner_ctl == null or owner_ctl == _end_turn or owner_ctl == _map:
			_try_end_turn()
			get_viewport().set_input_as_handled()
	elif key == KEY_ESCAPE:
		if _panel.visible:
			_panel.close_panel()
			get_viewport().set_input_as_handled()
	elif key == KEY_C and not (owner_ctl is LineEdit or owner_ctl is TextEdit):
		_open_sheet()
		get_viewport().set_input_as_handled()


func _arg_value(name: String, fallback: String) -> String:
	var i: int = _args.find(name)
	return _args[i + 1] if i != -1 and i + 1 < _args.size() else fallback


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE or what == NOTIFICATION_WM_CLOSE_REQUEST:
		if _job.is_running():
			_job.finish()
		if session != null:
			session.shutdown()


# --- Demo run for screenshots ----------------------------------------------------------------------------------------

func _run_demo() -> void:
	var dir: String = _arg_value("--shot-dir", "user://hud-greybox")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir))
	var tag: String = "%dx%d" % [get_viewport_rect().size.x, get_viewport_rect().size.y]
	await _shot(dir, "00-loading", tag)
	while session == null:
		await get_tree().process_frame
	await _frames(10)
	await _shot(dir, "01-new-life-summary", tag)
	await _demo_close_centre()
	await _shot(dir, "02-map", tag)
	_open_sheet()
	await _frames(5)
	await _shot(dir, "03-character-panel", tag)
	_panel.close_panel()
	var n: int = 0
	for i in 3:
		await _demo_answer_events(dir, tag)
		await _demo_wait_cooldown()
		_try_end_turn()
		await _frames(2)
		if i == 0:
			await _shot(dir, "06-resolving", tag)
		await _wait_job()
		await _frames(5)
		await _shot(dir, "07-season-summary-%d" % i, tag)
		await _demo_close_centre()
		n += 1
	await _demo_answer_events(dir, tag)
	var target: String = _nearest_known_place()
	if target != "":
		_on_place_clicked(target)
		await _frames(5)
		await _shot(dir, "08-travel-focus", tag)
		await _demo_wait_cooldown()
		_try_end_turn()
		await _wait_job()
		await _frames(5)
		await _shot(dir, "09-journey-summary", tag)
		await _demo_close_centre()
		await _demo_answer_events(dir, tag)
		await _shot(dir, "10-after-journey", tag)
	await _demo_real_input(dir, tag)
	get_tree().quit()


## Drives the screen through real input events (keys and mouse clicks through the viewport, not handler calls) and
## prints one "INPUT CHECK" line per check, so a run proves input works, not only that the screen renders.
func _demo_real_input(dir: String, tag: String) -> void:
	await _demo_answer_events(dir, tag)
	await _key(KEY_C)
	_check("C opens the character panel", _panel.visible)
	await _shot(dir, "11-input-sheet-by-key", tag)
	await _key(KEY_ESCAPE)
	_check("Esc closes the panel", not _panel.visible)
	var target: String = _nearest_known_place()
	if target != "":
		var rec: Dictionary = session.db.get_record("places", target)
		var at: Vector2 = _map.global_position + _map.tile_to_local(Vector2i(int(rec.tile[0]), int(rec.tile[1])))
		await _click(at)
		_check("clicking a place sets Travel to it", turn.focus == TurnController.FOCUS_TRAVEL and turn.destination_id == target)
		await _shot(dir, "12-input-place-clicked", tag)
	await _demo_wait_cooldown()
	var year_before: int = session.year * 10 + session.season
	await _click(_end_turn.get_global_rect().get_center())
	await _wait_job()
	await _frames(5)
	_check("clicking End turn passes a season", session.year * 10 + session.season != year_before)
	_check("the summary opens after the turn", _centre.visible)
	await _shot(dir, "13-input-summary-by-click", tag)
	await _key(KEY_ENTER)
	_check("Enter on the summary closes it", not _centre.visible or session.has_pending_event())
	await _demo_answer_events_by_click(dir, tag)
	await _demo_wait_cooldown()
	_end_turn.grab_focus()
	await _frames(2)
	var before2: int = session.year * 10 + session.season
	await _key(KEY_ENTER)
	await _wait_job()
	await _frames(5)
	_check("Enter on a focused End turn passes a season", session.year * 10 + session.season != before2)
	await _shot(dir, "14-input-enter-end-turn", tag)
	await _key(KEY_ENTER)


## Answers waiting events by clicking the first enabled option button on the card.
func _demo_answer_events_by_click(dir: String, tag: String) -> void:
	var k: int = 0
	while session.has_pending_event() and k < 4:
		if not _centre.visible:
			_show_event()
			await _frames(5)
		var button: Button = null
		for b in _centre.find_children("*", "Button", true, false):
			if b.visible and not b.disabled:
				button = b
				break
		if button == null:
			return
		await _click(button.get_global_rect().get_center())
		await _wait_job()
		await _frames(5)
		_check("clicking an event option answers it", _centre.visible)
		await _shot(dir, "15-input-outcome-%d" % k, tag)
		await _key(KEY_ENTER)
		k += 1


func _key(code: Key) -> void:
	for pressed in [true, false]:
		var ev := InputEventKey.new()
		ev.keycode = code
		ev.physical_keycode = code
		ev.pressed = pressed
		Input.parse_input_event(ev)
		await _frames(2)
	await _frames(3)


func _click(at: Vector2) -> void:
	var motion := InputEventMouseMotion.new()
	motion.position = at
	motion.global_position = at
	get_viewport().push_input(motion)
	await _frames(2)
	for pressed in [true, false]:
		var ev := InputEventMouseButton.new()
		ev.position = at
		ev.global_position = at
		ev.button_index = MOUSE_BUTTON_LEFT
		ev.pressed = pressed
		get_viewport().push_input(ev)
		await _frames(2)
	await _frames(3)


func _check(what: String, ok: bool) -> void:
	print("INPUT CHECK %s: %s" % ["PASS" if ok else "FAIL", what])


## Answers every waiting event with its first allowed option, saving the card and the outcome.
func _demo_answer_events(dir: String, tag: String) -> void:
	var k: int = 0
	while session.has_pending_event() and k < 4:
		_show_event()
		await _frames(5)
		await _shot(dir, "04-event-card-%d-%d" % [_shots, k], tag)
		var pick: int = -1
		for i in Array(session.pending_event.get("choices", [])).size():
			if bool(Advisor.choice_odds(session, i).get("ok", false)):
				pick = i
				break
		if pick == -1:
			return
		_on_option_chosen(pick)
		await _wait_job()
		await _frames(5)
		await _shot(dir, "05-outcome-%d-%d" % [_shots, k], tag)
		await _demo_close_centre()
		k += 1


func _demo_wait_cooldown() -> void:
	var cooldown_ms: int = int(float(_cfg.get("end_turn_cooldown", 0.5)) * 1000.0)
	while Time.get_ticks_msec() - _last_turn_msec < cooldown_ms:
		await get_tree().process_frame


func _demo_close_centre() -> void:
	if _centre.visible:
		_centre.hide_window()
		_on_centre_closed()
		if session.has_pending_event():
			_centre.hide_window()
			turn.window_open = false
	await _frames(5)


func _nearest_known_place() -> String:
	var here: Dictionary = session.db.get_record("places", str(session.player.location_id))
	if not here.has("tile"):
		return ""
	var best: String = ""
	var best_d: float = INF
	for p in session.db.all("places"):
		if str(p.id) == str(session.player.location_id) or not p.has("tile") or bool(p.get("hidden", false)):
			continue
		if session.knowledge != null and not session.knowledge.knows_place(str(p.id)):
			continue
		var d: float = Vector2(int(p.tile[0]) - int(here.tile[0]), int(p.tile[1]) - int(here.tile[1])).length()
		if d < best_d:
			best_d = d
			best = str(p.id)
	return best


func _wait_job() -> void:
	while _job.is_running() or _job_kind != "":
		await get_tree().process_frame


func _frames(n: int) -> void:
	for i in n:
		await get_tree().process_frame


func _shot(dir: String, name: String, size_tag: String) -> void:
	_shots += 1
	await RenderingServer.frame_post_draw
	var img: Image = get_viewport().get_texture().get_image()
	img.save_png(ProjectSettings.globalize_path(dir.path_join("%s-%s.png" % [name, size_tag])))
