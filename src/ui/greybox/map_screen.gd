extends Control
## Greybox of the map screen (design/ux/hud.md, approved 2026-11-22; slice 2 adds the map bubbles): the continent map
## with the HUD zones in Godot's default look. Z1 top bar, Z2 window buttons, Z3 portrait cluster, Z4 map modes and
## zoom, Z5 the season turn, Z6 one panel, Z7 the summary, the event card and the focus comparison; on the map, your
## bubble, the abode bubble and, at region zoom, the area bubbles. It plays the real game through the session's existing commands; it
## never changes game state itself.
##
## Launch (windowed, by scene path; run/main_scene stays unset):
##   Godot_v4.7.1-stable_win64.exe --path . --windowed --resolution 1280x720 res://src/ui/greybox/map_screen.tscn
##       [-- --seed N] [--demo --shot-dir res://production/qa/evidence/hud-greybox]
## [--ratings-off] switches Power Rankings' fights off for the run (the demo uses it).
## --demo plays a fixed script (sheet, seasons, events, a journey, region zoom and bubbles) and saves a screenshot at each step to
## --shot-dir, then quits: the run-and-observe evidence (.claude/docs/run-and-observe.md).
##
## Greybox limits (stated on screen): the LLM is off.

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
var _focus := Button.new()
var _zoom_button := Button.new()
var _comparison := FocusComparison.new()
var _zones: Array = []   # Z1-Z5 controls: bubbles are hidden under them
var _trip_key: String = ""
var _trip_cache: Array = []
var _end_turn := Button.new()
var _turn_note := Label.new()
var _sheet_button := Button.new()
var _portrait := Button.new()
var _panel := TextPanel.new()
var _person := PersonPanel.new()
var _fight := FightScreen.new()
var _people_list := VBoxContainer.new()
var _places := PlacesPanel.new()
var _places_button: Button = null
var _tips := TooltipLayer.new()
var _centre := CentreWindow.new()
var _dim := ColorRect.new()
var _summary_pending_event: bool = false
var _shots: int = 0
## The UI scale setting in percent (design/ux/hud.md Scaling rule; 75-150 %). The settings menu is not in the greybox, so
## --ui-scale=N sets it for the run.
var _ui_scale_pct: int = 100
var _scaling := false
var _world_start_msec: int = 0
var _known_cache: Array = []
var _talk_target: String = ""
var _person_after_fight: bool = true   # GameQuery.known_places of the last refresh


func _ready() -> void:
	_args = OS.get_cmdline_user_args()
	_ui_scale_pct = int(_arg_value("--ui-scale", "100"))
	_apply_scale()
	get_window().size_changed.connect(_apply_scale)
	_build_layout()
	_show_loading(tr("Generating the world…"))
	gd = GameData.load_from("res://assets/data")
	_cfg = gd.file(UI_FILE)
	_tips.configure(_cfg.get("tooltips", {}))
	_fight.configure(_cfg.get("fight_screen", {}))
	LinkStyle.configure(_cfg.get("link_styles", {}))
	# The readouts with a tooltip, styled once the table is loaded (hud.md Tooltips: Link styles).
	LinkStyle.apply(_stones, "number")
	LinkStyle.apply(_season, "term")
	LinkStyle.apply(_realm, "term")
	LinkStyle.apply(_lifespan, "number")
	_tips.chain.resolve = func(key: String) -> Dictionary: return TooltipLayer.term_content(gd.file("ui_terms").get("terms", {}), key)
	# Power Rankings runs (rule 13 one season late and worker processes, 2026-11-22); --ratings-off switches its fights
	# off for this run (the demo presses through seasons with no pause, which would wait for every batch).
	if _args.has("--ratings-off"):
		var rankings: Dictionary = gd.file("combat_rankings")
		if rankings.has("enabled"):
			rankings["enabled"] = false
	var seed_v: int = int(_arg_value("--seed", str(_greybox().get("seed", 7))))
	_job_kind = "new_game"
	_world_start_msec = Time.get_ticks_msec()
	_job.start(_new_game.bind(seed_v))
	if _args.has("--demo"):
		_run_demo.call_deferred()


## Applies the scaling rule (UiScale) to the window: a smaller window gives less room, never smaller text, and the
## layout area never drops below 1280×720. Runs at start and on every resize; the saved setting is kept.
func _apply_scale() -> void:
	if _scaling:
		return   # setting the content scale raises size_changed again
	_scaling = true
	var win: Window = get_window()
	if win.min_size != Vector2i(UiScale.MIN_W, UiScale.MIN_H):
		win.min_size = Vector2i(UiScale.MIN_W, UiScale.MIN_H)
	if win.content_scale_mode != Window.CONTENT_SCALE_MODE_CANVAS_ITEMS:
		win.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	if win.content_scale_aspect != Window.CONTENT_SCALE_ASPECT_EXPAND:
		win.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
	# Measured 2026-11-22: a zero base size makes Godot stretch from the project's default 1152x648, so the base is the
	# window's own size (no stretch) and only the content scale factor applies: layout area = window / factor.
	if win.content_scale_size != win.size:
		win.content_scale_size = win.size
	var f: float = UiScale.factor(_ui_scale_pct, win.size.x, win.size.y)
	if not is_equal_approx(win.content_scale_factor, f):
		win.content_scale_factor = f
	_scaling = false


## --shot-and-quit=<path>: closes the first summary, saves one frame of the map screen and quits, printing the window
## size, the layout size and the content scale (the scaling rule's on-screen check).
func _shot_and_quit(path: String) -> void:
	_centre.hide_window()
	_on_centre_closed()
	if _arg_value("--zoom", "") == "region":
		_toggle_zoom()
	# --turns=N: ends N seasons first (answering events with the first affordable option), printing each End turn wait,
	# so the default path (rating fights on) can be timed; --quit-in-turn quits while the last season is resolving.
	var turns: int = int(_arg_value("--turns", "0"))
	for t in turns:
		await _demo_answer_events(ProjectSettings.globalize_path("user://"), "turns")
		await _demo_wait_cooldown()
		var t0: int = Time.get_ticks_msec()
		_try_end_turn()
		if t == turns - 1 and _args.has("--quit-in-turn"):
			await _frames(30)
			print("TURN %d quitting while it resolves" % (t + 1))
			get_tree().quit()
			return
		await _wait_job()
		print("TURN %d End turn wait %d ms" % [t + 1, Time.get_ticks_msec() - t0])
		await _frames(3)
		await _demo_close_centre()
	var resize: String = _arg_value("--resize-to", "")
	if resize != "":
		var wh: PackedStringArray = resize.split("x")
		get_window().size = Vector2i(int(wh[0]), int(wh[1]))
		for i in 10:
			await get_tree().process_frame
	if _args.has("--tip"):
		_stones.grab_focus()
		await _frames(2)
		await _key(KEY_Q)
		await _key(KEY_ENTER)
	for i in 20:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	print("SCALE window=%s factor=%.3f layout=%s end_turn_font=%d" % [str(get_window().size), get_window().content_scale_factor, str(size), _end_turn.get_theme_font_size("font_size")])
	get_viewport().get_texture().get_image().save_png(ProjectSettings.globalize_path(path))
	get_tree().quit()


func _greybox() -> Dictionary:
	return _cfg.get("greybox", {})


func _bubble_cfg() -> Dictionary:
	return _cfg.get("bubbles", {})


func _new_game(seed_v: int) -> Dictionary:
	var llm := LlmService.new(gd)
	llm.enabled = false
	var s := GameSession.new(gd, llm)
	var r: Dictionary = s.new_game(seed_v, {"mode": "roll", "name": "Vô Danh", "gender": "male", "origin": "tan_tu"})
	var grid := ContinentGrid.from_continent(gd)
	return {"session": s, "result": r, "grid": grid}


func _process(_delta: float) -> void:
	_process_dim()
	_fill_place_routes()
	if not _job.is_done():
		return
	var out: Variant = _job.finish()
	if not (out is Dictionary):
		out = {"ok": false, "lines": [tr("The game hit an error working this out; nothing was changed by the screen.")], "events": []}
	var kind: String = _job_kind
	_job_kind = ""
	match kind:
		"new_game":
			_on_world_ready(out)
		"end_turn":
			_on_turn_done(out)
		"choose":
			_on_choice_done(out)
		"talk":
			_on_talk_done(out)


func _on_world_ready(out: Dictionary) -> void:
	print("World ready in %d ms" % (Time.get_ticks_msec() - _world_start_msec))
	session = out.session
	turn = TurnController.new(session)
	var grid: ContinentGrid = out.grid
	if grid.errors.is_empty():
		_map.setup(grid, _greybox(), float(_bubble_cfg().get("region_zoom", 4.0)))
	_loading.visible = false
	_refresh()
	_end_turn.grab_focus()
	_centre_summary(tr("A new life"), Array(out.result.get("lines", [])))
	var shot: String = _arg_value("--shot-and-quit", "")
	if shot != "":
		_shot_and_quit.call_deferred(shot)


# --- Layout ----------------------------------------------------------------------------------------------------------

func _build_layout() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	theme = _greybox_theme()
	_map.set_anchors_preset(Control.PRESET_FULL_RECT)
	_map.place_clicked.connect(_on_place_clicked)
	_map.bubble_pressed.connect(_on_bubble_pressed)
	_map.zoom_changed.connect(func(_r: bool): _refresh())
	add_child(_map)

	# Z1 top bar
	var z1 := PanelContainer.new()
	z1.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	z1.offset_left = 16
	z1.offset_right = -16
	z1.offset_top = 8
	add_child(z1)
	_zones.append(z1)
	var bar := HBoxContainer.new()
	bar.add_theme_constant_override("separation", 16)
	z1.add_child(bar)
	_alerts.text = tr("Alerts: none")
	_alerts.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.add_child(_alerts)
	TooltipLayer.set_tip(_stones, _tip_stones)
	_stones.focus_mode = Control.FOCUS_ALL
	_stones.mouse_filter = Control.MOUSE_FILTER_STOP
	var stones_word := Label.new()
	stones_word.text = tr("Linh thạch")
	var stones_box := HBoxContainer.new()
	stones_box.add_theme_constant_override("separation", 6)
	stones_box.add_child(stones_word)
	stones_box.add_child(_stones)
	bar.add_child(stones_box)
	TooltipLayer.set_tip(_season, _tip_season)
	bar.add_child(_season)
	for t in [["W", tr("Wiki (not in the greybox yet)")], ["≡", tr("Game menu (not in the greybox yet)")]]:
		var b := Button.new()
		b.text = t[0]
		TooltipLayer.set_tip(b, t[1])
		b.disabled = true
		bar.add_child(b)

	var note := Label.new()
	note.text = tr("Greybox: LLM off.") + ((" " + tr("Rating fights off for this run (--ratings-off).")) if _args.has("--ratings-off") else "")
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
	_zones.append(z2)
	_sheet_button.text = tr("Character") + " (C)"
	_sheet_button.pressed.connect(_open_sheet)
	z2.add_child(_sheet_button)
	for name in ["Inventory", "Relationships", "Sect", "Quests", "Rankings", "News", "Places", "Đạo Đồ", "Abode"]:
		var b := Button.new()
		b.text = tr(name)
		if name == "Places":
			b.text = tr("Places") + " (P)"
			b.pressed.connect(func(): _toggle_places(b))
			_places_button = b
		else:
			b.disabled = true
			TooltipLayer.set_tip(b, tr("Not in the greybox yet"))
		z2.add_child(b)

	# Z3 portrait cluster
	var z3 := PanelContainer.new()
	z3.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	z3.offset_left = 16
	z3.offset_bottom = -16
	z3.offset_top = -112
	z3.offset_right = 380
	add_child(z3)
	_zones.append(z3)
	var row := HBoxContainer.new()
	z3.add_child(row)
	# Element 7: the portrait is a button; a click (or Enter / gamepad A on it) opens the character sheet.
	_portrait.custom_minimum_size = Vector2(80, 80)
	TooltipLayer.set_tip(_portrait, tr("Your character: click to open the sheet (C)"))
	var face := StyleBoxFlat.new()
	face.bg_color = Color(0.3, 0.3, 0.35)
	_portrait.add_theme_stylebox_override(&"normal", face)
	var face_hover := face.duplicate() as StyleBoxFlat
	face_hover.bg_color = Color(0.38, 0.38, 0.45)
	_portrait.add_theme_stylebox_override(&"hover", face_hover)
	_portrait.add_theme_stylebox_override(&"pressed", face_hover)
	_portrait.pressed.connect(_open_sheet_from.bind(_portrait))
	row.add_child(_portrait)
	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(col)
	col.add_child(_realm)
	_cult_bar.custom_minimum_size = Vector2(220, 20)
	TooltipLayer.set_tip(_cult_bar, _tip_cultivation)
	_cult_bar.focus_mode = Control.FOCUS_ALL
	TooltipLayer.set_tip(_realm, _tip_realm)
	TooltipLayer.set_tip(_lifespan, _tip_lifespan)
	col.add_child(_cult_bar)
	var life_row := HBoxContainer.new()
	life_row.add_theme_constant_override("separation", 6)
	var age_word := Label.new()
	age_word.text = tr("age")
	life_row.add_child(age_word)
	life_row.add_child(_lifespan)
	col.add_child(life_row)

	# Z4 map modes
	var z4 := HBoxContainer.new()
	z4.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	z4.offset_bottom = -16
	z4.offset_top = -52
	z4.offset_left = -230
	z4.offset_right = 230
	add_child(z4)
	_zones.append(z4)
	for m in [["Terrain", true], ["Sect", false], ["Qi", false], ["Prices", false]]:
		var b := Button.new()
		b.text = tr(m[0])
		b.toggle_mode = true
		b.button_pressed = m[1]
		b.disabled = not m[1]
		TooltipLayer.set_tip(b, tr("Map mode") if m[1] else tr("Not in the greybox yet"))
		z4.add_child(b)
	_zoom_button.text = tr("Region view")
	TooltipLayer.set_tip(_zoom_button, tr("Zoom in around you to see what you can do nearby (+ / −, or the mouse wheel)"))
	_zoom_button.pressed.connect(_toggle_zoom)
	z4.add_child(_zoom_button)

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
	_zones.append(z5)
	var turn_box := VBoxContainer.new()
	z5.add_child(turn_box)
	TooltipLayer.set_tip(_focus, tr("Season focus: opens the focus comparison"))
	_focus.alignment = HORIZONTAL_ALIGNMENT_LEFT
	_focus.pressed.connect(func(): _open_comparison(turn.focus, turn.destination_id))
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
	for p in [_person]:
		p.set_anchors_preset(Control.PRESET_LEFT_WIDE)
		p.anchor_right = 0.33
		p.offset_left = 16
		p.offset_top = 80
		p.offset_bottom = -132
		add_child(p)
	_person.person_requested.connect(func(id: String): _open_person(id, _person))
	_person.fight_requested.connect(_open_practice_fight)
	_person.travel_requested.connect(func(place_id: String): _person.close_panel(); _open_comparison(TurnController.FOCUS_TRAVEL, place_id))
	_person.verb_requested.connect(_on_verb)
	_person.closed.connect(func(): _refresh())
	_panel.visibility_changed.connect(_on_panel_visibility)
	_panel.closed.connect(func(): if not _person.visible: _people_list.visible = false)
	_places.set_anchors_preset(Control.PRESET_LEFT_WIDE)
	_places.anchor_right = 0.33
	_places.offset_left = 16
	_places.offset_top = 80
	_places.offset_bottom = -132
	add_child(_places)
	_places.place_selected.connect(_on_places_selected)
	_places.travel_requested.connect(func(id: String): _open_comparison(TurnController.FOCUS_TRAVEL, id))
	_places.details_requested.connect(_open_place_details)
	_places.action_requested.connect(func(kind: String): _on_bubble_pressed(kind, _here_id()))
	_places.closed.connect(func(): _refresh())

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
	centre_box.add_child(_comparison)
	_comparison.confirmed.connect(_on_comparison_confirmed)
	_comparison.cancelled.connect(_on_comparison_closed)
	_centre.closed.connect(_on_centre_closed)
	_centre.option_chosen.connect(_on_option_chosen)

	# Loading overlay
	_loading.color = Color(0.05, 0.06, 0.08, 0.92)
	_loading.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_loading)
	_loading_label.set_anchors_preset(Control.PRESET_CENTER)
	_loading_label.add_theme_font_size_override("font_size", 24)
	_loading.add_child(_loading_label)

	add_child(_fight)   # configured in _ready once ui_hud.json is loaded
	_fight.closed.connect(func():
		if _person.person_id() == "" and _person_after_fight:
			_person.visible = true
		_refresh())
	# The tooltip layer, above everything (Layout Zones: Tooltip layer)
	add_child(_tips)
	_tips.fallback_focus = func() -> Control: return _end_turn
	_tips.busy = _busy   # no tip reads the session while its job runs (ADR-0005)
	_tips.wiki_requested.connect(_open_wiki)


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
	_dim.visible = _centre.visible or _comparison.visible or _job_kind == "choose"


func _show_loading(text: String) -> void:
	_loading_label.text = text
	_loading.visible = true


# --- State -> display ------------------------------------------------------------------------------------------------

func _refresh() -> void:
	if session == null or GameQuery.player(session).is_empty():
		return
	var snap: Dictionary = StateSnapshot.take(session)
	_stones.text = HudReadouts.stones_text(float(snap.linh_thach))
	_season.text = session.clock_label()
	_realm.text = str(snap.realm_label)
	var req: float = GameQuery.level_requirement(session)
	_cult_bar.value = HudReadouts.cultivation_share(float(snap.tu_vi), req) * 100.0
	_lifespan.text = HudReadouts.lifespan_numbers(float(snap.age), float(snap.lifespan))
	var warn: bool = HudReadouts.lifespan_warning(float(snap.age), float(snap.lifespan), float(_cfg.get("lifespan_warn_share", 0.1)))
	_lifespan.add_theme_color_override("font_color", Color(1, 0.7, 0.2) if warn else Color(0.9, 0.9, 0.9))
	_alerts.text = tr("Alerts:") + " " + (tr("an event is waiting") if session.has_pending_event() else tr("none"))
	_refresh_focus()
	_refresh_map(str(snap.location_id))
	_refresh_turn_button()


func _refresh_focus() -> void:
	_focus.text = tr("Focus:") + " " + turn.focus_label() + "  ▾"
	_zoom_button.text = tr("Continent view") if _map.is_region_zoom() else tr("Region view")


func _refresh_turn_button() -> void:
	_end_turn.text = turn.button_label()
	var g: Dictionary = turn.gate()
	TooltipLayer.set_tip(_end_turn, g.reason if not g.ok else tr("End the season (Enter)"))
	_turn_note.text = turn.fallback_note


func _refresh_map(location_id: String) -> void:
	var places: Array = []
	_known_cache = GameQuery.known_places(session)
	for p in _known_cache:
		places.append({"id": str(p.id), "name": str(p.name), "tile": Vector2i(int(p.tile[0]), int(p.tile[1])), "kind": str(p.get("kind", "")), "rec": p})
	var here: Dictionary = GameQuery.here(session)
	var tile := Vector2i(-1, -1)
	if here.has("tile"):
		tile = Vector2i(int(here.tile[0]), int(here.tile[1]))
	_map.set_state(places, tile, location_id, turn.destination_id)
	_map.set_bubbles(_bubbles(places, location_id, tile))
	var rects: Array = []
	for z in _zones:
		rects.append((z as Control).get_global_rect())
	if _panel.visible:
		rects.append(_panel.get_global_rect())
	if _places.visible:
		rects.append(_places.get_global_rect())
	_map.set_blocked_rects(rects)


## The bubbles for the map (design/ux/hud.md, Map bubbles): yours, the abode's, and the area bubbles from BubbleModel
## over what the player knows.
func _bubbles(places: Array, here_id: String, here_tile: Vector2i) -> Array:
	var out: Array = []
	var c: Dictionary = GameQuery.player(session)
	if here_tile.x >= 0:
		out.append({"kind": "player", "place_id": here_id, "tile": here_tile,
			"tooltip": "%s — %s — %s (%s)" % [c.name, c.realm_label, str(GameQuery.here(session).get("name", "")), tr("click: character sheet")]})
	var home: Dictionary = GameQuery.place(session, str(c.home_id)) if str(c.home_id) != "" else {}
	if not home.is_empty() and home.has("tile"):
		out.append({"kind": "abode", "place_id": str(c.home_id), "tile": Vector2i(int(home.tile[0]), int(home.tile[1])),
			"tooltip": tr("Your abode at") + " " + str(home.name) + " (" + tr("click: open it") + ")"})
	var known: Dictionary = {}
	var by_id: Dictionary = {}
	for pl in places:
		known[pl.id] = true
		by_id[pl.id] = pl
	var cfg: Dictionary = _bubble_cfg()
	var links: Dictionary = {here_id: _trip_links(here_id, here_tile, places, float(cfg.get("trip_seasons", 1.0)))}
	var dist: Dictionary = BubbleModel.distances(here_id, links, known, float(cfg.get("trip_seasons", 1.0)))
	var met_here: int = GameQuery.people_at(session, here_id).size()   # everyone here, met or not (design/ux/person.md)
	var kinds_by_place: Dictionary = {}
	for id in dist:
		var rec: Dictionary = by_id.get(id, {}).get("rec", {})
		var can_work: bool = Advisor.can_work_here(session) if id == here_id else bool(rec.get("bounties", false))
		var k: Dictionary = BubbleModel.kinds_for(rec, id == here_id, met_here, can_work, Array(cfg.get("explore_kinds", [])))
		if not k.is_empty():
			kinds_by_place[id] = k
	var locked: bool = session.has_pending_event()
	for b in BubbleModel.build(kinds_by_place, dist, here_id, int(cfg.get("max", 12))):
		var pl: Dictionary = by_id.get(b.place_id, {})
		if pl.is_empty():
			continue
		var name: String = str(pl.name)
		var away: String = tr("here") if b.place_id == here_id else (tr("%.1f season(s) away") % float(b.seasons))
		var tip: String = "%s — %s, %s" % [_kind_name(b.kind, int(b.count)), name, away]
		var lock: bool = locked and b.place_id == here_id and BubbleModel.is_free_here(b.kind) and b.kind == "market"
		if lock:
			tip += " — " + tr("locked while an event waits (look only)")
		out.append({"kind": b.kind, "place_id": b.place_id, "count": b.count, "tile": pl.tile, "tooltip": tip, "locked": lock})
	return out


## Route seasons from the player's place to each known place near enough to matter, by the same terrain route the
## game's Travel uses (TravelGrid.trip; the road network when there is no grid route), as direct links for
## BubbleModel. Cached until the player moves or the season changes.
func _trip_links(here_id: String, here_tile: Vector2i, places: Array, reach: float) -> Array:
	var key: String = "%s|%d" % [here_id, session.season_index()]
	if key == _trip_key:
		return _trip_cache
	var out: Array = []
	var radius: float = float(_bubble_cfg().get("prefilter_tiles_per_season", 90.0)) * reach
	for pl in places:
		if pl.id == here_id or here_tile.x < 0 or Vector2(pl.tile - here_tile).length() > radius:
			continue
		var t: float = GameQuery.route_seasons(session, str(pl.id))
		if t >= 0.0 and t <= reach + 1e-9:
			out.append({"to": str(pl.id), "seasons": t})
	_trip_key = key
	_trip_cache = out
	return out


## Opens or closes the Places panel (P, or its Z2 button).
func _toggle_places(opener: Control) -> void:
	if _busy():
		return
	if _places.visible:
		_places.close_panel()
		return
	_panel.close_panel()
	var here_id: String = _here_id()
	var here: Dictionary = GameQuery.here(session)
	var cfg: Dictionary = _bubble_cfg()
	var met_here: int = GameQuery.people_at(session, here_id).size()   # everyone here, met or not (design/ux/person.md)
	var rows: Array = []
	var here_actions: Array = []
	for p in GameQuery.known_places(session):
		var is_here: bool = str(p.id) == here_id
		var can_work: bool = Advisor.can_work_here(session) if is_here else bool(p.get("bounties", false))
		var kinds: Dictionary = BubbleModel.kinds_for(p, is_here, met_here, can_work, Array(cfg.get("explore_kinds", [])))
		var acts: Array = []
		for k in BubbleModel.KINDS:
			if kinds.has(k):
				acts.append(k)
		if is_here:
			here_actions = acts.filter(func(k): return BubbleModel.is_free_here(k))
		var fee: Dictionary = session.teleport_fee(str(p.id))
		rows.append({"id": str(p.id), "name": str(p.name), "region": str(p.region_name),
			"kind": str(p.get("kind", "")), "danger": int(p.get("danger", 0)),
			"match": float(p.land_match), "holder": str(p.holder_name),
			"people": met_here if is_here else -1, "actions": acts, "here": is_here, "seasons": 0.0 if is_here else -1.0,
			"seasons_known": is_here, "fee": int(fee.get("fee", -1)) if not fee.is_empty() else -1})
	var clues: Array = session.clue_lines() if GameQuery.has_clues(session) else []
	_places.open_panel(str(here.get("name", "")), here_actions, session.has_pending_event(), rows, clues, opener)
	_refresh()


## Works out a few of the Places panel's route times each frame (the game's own terrain route, as Travel uses), so the
## panel never stalls the screen.
func _fill_place_routes() -> void:
	if not _places.visible or _busy():
		return
	var pending: Array = _places.pending_ids()
	if pending.is_empty():
		return
	for id in pending.slice(0, int(_greybox().get("routes_per_frame", 3))):
		_places.set_seasons(id, GameQuery.route_seasons(session, id))


## A season or an event can move the player, reveal places and change what can be done here, so an open Places panel
## is rebuilt from the new state (its route times are worked out again from the new place).
func _rebuild_places() -> void:
	if not _places.visible:
		return
	_places.close_panel()
	_toggle_places(_places_button)


func _on_places_selected(place_id: String) -> void:
	var rec: Dictionary = GameQuery.place(session, place_id)
	if rec.has("tile"):
		_map.centre_on(Vector2i(int(rec.tile[0]), int(rec.tile[1])))


func _open_place_details(place_id: String) -> void:
	if _busy():
		return
	var rec: Dictionary = GameQuery.place(session, place_id)
	var lines: Array = [str(rec.get("name", "")) + " — " + str(rec.get("kind", "")).replace("_", " "), ""]
	lines.append_array(GameQuery.place_lines(session, place_id))
	_places.close_panel()
	_panel.open_panel(tr("Place"), lines, _places_button)


func _kind_name(kind: String, count: int) -> String:
	match kind:
		"market": return tr("Market")
		"sect": return tr("Sect")
		"work": return tr("Missions and bounties")
		"people": return tr("People here") + " (%d)" % count
		"explore": return tr("Explore")
	return kind


# --- Actions ---------------------------------------------------------------------------------------------------------

## True while the session is busy on the worker thread: the HUD is inert then and must not read the session
## (BackgroundCall's contract; design/ux/hud.md, The turn: "While a season resolves").
func _busy() -> bool:
	return session == null or _job.is_running()


func _on_place_clicked(place_id: String) -> void:
	if _busy():
		return
	if place_id == _here_id():
		_open_comparison(TurnController.FOCUS_CULTIVATE, "")
	else:
		_open_comparison(TurnController.FOCUS_TRAVEL, place_id)


func _toggle_zoom() -> void:
	if session == null:
		return
	if _busy():
		return
	var here: Dictionary = GameQuery.here(session)
	var at := Vector2(-1, -1)
	if here.has("tile"):
		at = Vector2(int(here.tile[0]), int(here.tile[1])) + Vector2(0.5, 0.5)
	_map.set_region_zoom(not _map.is_region_zoom(), at)


func _on_bubble_pressed(kind: String, place_id: String) -> void:
	if _busy():
		return
	var here: String = _here_id()
	match kind:
		"player":
			_open_sheet_from(_portrait)
			return
		"abode":
			_panel.open_panel(tr("Abode") + " (" + tr("the abode screen is not in the greybox yet") + ")", session.abode_lines(), _end_turn)
			return
	if place_id != here:
		_open_comparison(TurnController.FOCUS_TRAVEL, place_id)
		return
	match kind:
		"market":
			_panel.open_panel(tr("Market"), _market_lines(here), _end_turn)
		"sect":
			_panel.open_panel(tr("Sect"), session.sect_lines(), _end_turn)
		"people":
			_open_people_here(here)
		"work":
			_open_comparison(TurnController.FOCUS_MISSION, "")
		"explore":
			_open_comparison(TurnController.FOCUS_EXPLORE, "")


## The market's current stock, read only (stocking it would draw from the game's random streams, which the UI must
## not do); the trade window is not in the greybox yet.
func _market_lines(place_id: String) -> Array:
	var lines: Array = [tr("The trade window is not in the greybox yet."), ""]
	var stock: Array = GameQuery.market_lines(session, place_id)
	if stock.is_empty():
		lines.append(tr("No stock seen yet: it appears when you trade here."))
	lines.append_array(stock)
	return lines


## The people at a place as a list of names; one opens their person window (design/ux/person.md). With one person
## it opens their window at once, as the HUD's people bubble does.
func _open_people_here(place_id: String) -> void:
	var people: Array = GameQuery.people_at(session, place_id)
	if people.size() == 1:
		_open_person(str(people[0].id), _end_turn)
		return
	var lines: Array = [tr("Click a name in the list on the left to open their window.")]
	_panel.open_panel(tr("People here"), lines, _end_turn)
	_show_people_buttons(people)


func _show_people_buttons(people: Array) -> void:
	for c in _people_list.get_children():
		_people_list.remove_child(c)
		c.queue_free()
	if _people_list.get_parent() == null:
		_people_list.set_anchors_preset(Control.PRESET_TOP_LEFT)
		_people_list.position = Vector2(32, 150)
		add_child(_people_list)
	_people_list.visible = true
	for x in people.slice(0, 14):
		var b := Button.new()
		b.text = "%s · %s%s" % [str(x.name), str(x.realm_label), "" if bool(x.met) else "  (not met)"]
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		var pid: String = str(x.id)
		b.pressed.connect(func(): _open_person(pid, b))
		_people_list.add_child(b)
	if _people_list.get_child_count() > 0:
		(_people_list.get_child(0) as Control).grab_focus.call_deferred()


## Opens the person window for [param person_id]; the player's own name opens the character sheet instead.
func _open_person(person_id: String, opener: Control) -> void:
	if _busy():
		return
	var v: Dictionary = GameQuery.person(session, person_id)
	if v.is_empty():
		_panel.open_panel(tr("Person"), [tr("No record of this person.")], opener)
		return
	if bool(v.get("is_player", false)):
		_open_sheet_from(opener)
		return
	_panel.close_panel()
	_places.close_panel()
	_people_list.visible = false
	_person.open_person(v, session.has_pending_event(), opener)


## Plays a practice fight with [param person_id] on the fight screen (a read: nothing changes).
func _open_practice_fight(person_id: String) -> void:
	if _busy():
		return
	var f: Dictionary = GameQuery.practice_fight(session, person_id)
	if not bool(f.get("ok", false)):
		_person.show_reply([str(f.get("reason", tr("The fight could not run.")))])
		return
	_tips.close_all()
	_person.visible = false   # steps aside while the fight plays; it comes back when the fight screen closes
	_fight.open_fight(f, tr("Practice fight (a preview: nothing changes)"))


## A verb from the person window: only Greet exists in the greybox (the session's talk action).
func _on_verb(person_id: String, verb_id: String) -> void:
	if _busy() or verb_id != "greet":
		return
	_job_kind = "talk"
	_talk_target = person_id
	_job.start(session.run.bind(session.talk.bind(person_id, tr("Greetings."))))


func _on_talk_done(result: Dictionary) -> void:
	var v: Dictionary = GameQuery.person(session, _talk_target)
	_person.open_person(v, session.has_pending_event(), _end_turn)
	_person.show_reply(Array(result.get("lines", [])))
	_refresh()


func _people_lines(place_id: String) -> Array:
	var lines: Array = [tr("Person cards are not in the greybox yet."), ""]
	for x in GameQuery.people_met_at(session, place_id):
		lines.append(str(x.line))
	return lines


## Opens the focus comparison (element 29) with [param preselect] chosen; [param travel_place] names a Travel option.
func _open_comparison(preselect: String, travel_place: String) -> void:
	if _busy() or session.has_pending_event():
		return
	var opts: Array = [{"id": TurnController.FOCUS_CULTIVATE, "label": tr("Cultivate"), "note": tr("one season here"), "enabled": true}]
	opts.append({"id": TurnController.FOCUS_EXPLORE, "label": tr("Explore"), "note": tr("search this place for a season"), "enabled": true})
	var work: bool = Advisor.can_work_here(session)
	opts.append({"id": TurnController.FOCUS_MISSION, "label": tr("Mission"), "note": tr("a mission or bounty here"), "enabled": work,
		"reason": tr("No work here: go to your sect's headquarters or a town or city with bounties.")})
	var dest: String = travel_place if travel_place != "" else turn.destination_id
	if dest != "":
		var rec: Dictionary = GameQuery.place(session, dest)
		var what: Array = []
		if bool(rec.get("market", false)):
			what.append(tr("market"))
		if str(rec.get("sect_id", "")) != "":
			what.append(tr("sect"))
		if bool(rec.get("bounties", false)):
			what.append(tr("bounties"))
		opts.append({"id": TurnController.FOCUS_TRAVEL + ":" + dest, "label": tr("Travel to") + " " + str(rec.get("name", dest)),
			"note": ", ".join(what), "enabled": true})
	var pre: String = preselect
	if preselect == TurnController.FOCUS_TRAVEL and dest != "":
		pre = TurnController.FOCUS_TRAVEL + ":" + dest
	turn.window_open = true
	_comparison.open(opts, pre)
	_refresh_turn_button()


func _on_comparison_confirmed(option_id: String) -> void:
	if option_id.begins_with(TurnController.FOCUS_TRAVEL + ":"):
		var dest: String = option_id.substr(TurnController.FOCUS_TRAVEL.length() + 1)
		turn.choose_travel(dest, str(GameQuery.place(session, dest).get("name", dest)))
	else:
		match option_id:
			TurnController.FOCUS_EXPLORE:
				turn.choose_explore()
			TurnController.FOCUS_MISSION:
				turn.choose_mission()
			_:
				turn.choose_cultivate()
	_on_comparison_closed()


func _on_comparison_closed() -> void:
	turn.window_open = false
	_refresh()
	_end_turn.grab_focus()


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
	_tips.close_all()   # a season change closes every tooltip, locked or not
	_refresh_turn_button()
	_job_kind = "end_turn"
	_job.start(turn.end_turn)


func _on_turn_done(result: Dictionary) -> void:
	turn.resolving = false
	_last_turn_msec = Time.get_ticks_msec()
	turn.after_turn(result, _here_id())
	_rebuild_places()
	_refresh()
	var lines: Array = Array(result.get("lines", []))
	if turn.fallback_note != "":
		lines.append("")
		lines.append(turn.fallback_note)
	_centre_summary(tr("The season ends"), lines)


func _centre_summary(title: String, lines: Array) -> void:
	_tips.close_all()   # a window opening over the chain closes it
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
	var ev: Dictionary = GameQuery.pending_event(session)
	var odds: Array = []
	for i in Array(ev.get("choices", [])).size():
		odds.append(Advisor.choice_odds(session, i))
	_centre.show_event(ev, odds)
	_refresh_turn_button()


func _on_option_chosen(index: int) -> void:
	if _job.is_running():
		return
	_centre.hide_window()
	_job_kind = "choose"
	_job.start(session.run.bind(session.choose.bind(index)))


func _on_choice_done(result: Dictionary) -> void:
	turn.window_open = false
	_rebuild_places()
	_refresh()
	_centre_summary(tr("Outcome"), Array(result.get("lines", [])))


func _open_sheet() -> void:
	_open_sheet_from(_sheet_button)


## Opens the character sheet in Z6; [param opener] gets focus back when it closes.
func _open_sheet_from(opener: Control) -> void:
	if _busy():
		return
	_panel.open_panel(tr("Character"), GameQuery.sheet_lines(session), opener)


func _unhandled_key_input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return
	if _fight.visible:
		return   # the fight screen owns the keys while it is up
	var key: Key = (event as InputEventKey).physical_keycode
	var owner_ctl: Control = get_viewport().gui_get_focus_owner()
	if key == KEY_V and _person.visible and not (owner_ctl is LineEdit or owner_ctl is TextEdit):
		_person.jump_to_verbs()
		get_viewport().set_input_as_handled()
		return
	if key == KEY_ENTER or key == KEY_KP_ENTER:
		if owner_ctl == null or owner_ctl == _end_turn or owner_ctl == _map:
			_try_end_turn()
			get_viewport().set_input_as_handled()
	elif key == KEY_EQUAL or key == KEY_KP_ADD or key == KEY_MINUS or key == KEY_KP_SUBTRACT:
		if not (owner_ctl is LineEdit or owner_ctl is TextEdit):
			var want_region: bool = key == KEY_EQUAL or key == KEY_KP_ADD
			if want_region != _map.is_region_zoom():
				_toggle_zoom()
			get_viewport().set_input_as_handled()
	elif key == KEY_ESCAPE:
		_on_escape(owner_ctl)
		get_viewport().set_input_as_handled()
	elif key == KEY_C and not (owner_ctl is LineEdit or owner_ctl is TextEdit):
		_open_sheet()
		get_viewport().set_input_as_handled()
	elif key == KEY_P and not (owner_ctl is LineEdit or owner_ctl is TextEdit):
		_toggle_places(_places_button)
		get_viewport().set_input_as_handled()


func _on_panel_visibility() -> void:
	if _panel.visible:
		_places.close_panel()
		_tips.close_all()


## Esc does one thing (EscRouter): the focused window first, then the ranked list. The greybox has no banner, confirm
## mode, multi-season run or game menu yet, so those answers do nothing.
func _on_escape(owner_ctl: Control) -> void:
	var focus: String = ""
	if _tips.owns(owner_ctl):
		focus = "tooltip"
	elif owner_ctl != null and (_panel == owner_ctl or _panel.is_ancestor_of(owner_ctl) or _person == owner_ctl or _person.is_ancestor_of(owner_ctl) or _people_list.is_ancestor_of(owner_ctl)):
		focus = "panel"
	elif owner_ctl != null and (_places == owner_ctl or _places.is_ancestor_of(owner_ctl)):
		focus = "places"
	elif owner_ctl != null and _centre.is_ancestor_of(owner_ctl):
		focus = "z7"
	var card: bool = _centre.visible and _centre.showing_event
	match EscRouter.pick({"modal_open": _comparison.visible, "focus": focus, "tooltip_open": _tips.is_open(),
			"z7_open": _centre.visible, "card_blocking": card, "panel_open": _panel.visible or _person.visible or _people_list.visible, "places_open": _places.visible}):
		"modal":
			_comparison.cancel()
		"tooltip":
			_tips.close_top()
		"panel":
			if _person.visible:
				_person.close_panel()
			else:
				_panel.close_panel()
			_people_list.visible = false
		"places":
			_places.close_panel()
		"z7":
			_centre.hide_window()
			_on_centre_closed()
		_:
			pass   # "card" (minimise: not in the greybox), "menu" (no game menu yet)


# --- Tooltip content (design/ux/hud.md, Tooltips: name, key fact, one-line summary, then the Breakdown) -------------

func _tip_stones(_at: Vector2) -> Variant:
	if _busy():
		return ""   # never read the session while a job runs on it
	return {"title": tr("Spirit stones (linh thạch)"), "fact": tr("Held:") + " " + HudReadouts.stones_text(float(StateSnapshot.take(session).linh_thach)),
		"summary": tr("The only money."), "body": TooltipLayer.parse_body(tr("Markets, sect services and teleport arrays price in [[linh_thach|spirit stones]].")),
		"wiki": "linh_thach"}


func _tip_season(_at: Vector2) -> Variant:
	if _busy() or GameQuery.player(session).is_empty():
		return ""   # never read the session while a job runs on it
	return {"title": _season.text, "summary": tr("The calendar: one turn is one season."),
		"body": TooltipLayer.parse_body(tr("End the turn to pass one [[mua|season]].")), "wiki": "mua"}


func _tip_realm(_at: Vector2) -> Variant:
	if _busy() or GameQuery.player(session).is_empty():
		return ""   # never read the session while a job runs on it
	return {"title": _realm.text, "summary": tr("Your realm and stage."),
		"body": TooltipLayer.parse_body(tr("Your [[canh_gioi|realm]]: [[luyen_khi|Qi Refining]] is the first.")), "wiki": "canh_gioi"}


func _tip_cultivation(_at: Vector2) -> Variant:
	if _busy() or GameQuery.player(session).is_empty():
		return ""   # never read the session while a job runs on it
	var snap: Dictionary = StateSnapshot.take(session)
	var rate: Dictionary = GameQuery.breakdown(session, "rate")
	return {"title": tr("Cultivation progress"), "fact": HudReadouts.cultivation_text(float(snap.tu_vi), GameQuery.level_requirement(session)),
		"summary": tr("Cultivating here adds about %s a season.") % Breakdown._fmt(float(rate.total)),
		"body": TooltipLayer.parse_body(tr("Your [[tu_vi|cultivation base]]; when it is full you attempt a [[dot_pha|breakthrough]].")),
		"lines": Array(rate.lines), "wiki": "tu_vi"}


func _tip_lifespan(_at: Vector2) -> Variant:
	if _busy() or GameQuery.player(session).is_empty():
		return ""   # never read the session while a job runs on it
	var snap: Dictionary = StateSnapshot.take(session)
	var life: Dictionary = GameQuery.breakdown(session, "lifespan")
	var warn: bool = HudReadouts.lifespan_warning(float(snap.age), float(life.total), float(_cfg.get("lifespan_warn_share", 0.1)))
	return {"title": tr("Lifespan (thọ nguyên)"), "fact": HudReadouts.lifespan_text(float(snap.age), float(life.total)) + ((" · " + tr("little lifespan left") + " ⌛") if warn else ""),
		"summary": tr("When age reaches lifespan, this life ends."),
		"body": TooltipLayer.parse_body(tr("Every [[mua|season]] costs a quarter year of [[tho_nguyen|lifespan]].")),
		"lines": Array(life.lines), "wiki": "tho_nguyen"}


## The wiki is not in the greybox: its entry text opens in the side panel instead.
func _open_wiki(key: String) -> void:
	var t: Dictionary = gd.file("ui_terms").get("terms", {}).get(key, {})
	_tips.close_all()
	if t.is_empty():
		return
	var body: String = ""
	for seg in TooltipLayer.parse_body(str(t.get("body", ""))):
		body += str(seg.get("text", "")) if seg is Dictionary else str(seg)
	_panel.open_panel(tr("Wiki") + ": " + str(t.get("title", key)), [str(t.get("summary", "")), "", body, "",
		tr("(The in-game wiki is not in the greybox; this is its entry text.)")], _end_turn)


## The player's place id (GameQuery; the screen reads no session member itself, ADR-0006 decision 4).
func _here_id() -> String:
	return str(GameQuery.player(session).get("location_id", ""))


## The value of launch argument [param name], given as "--name value" or "--name=value"; [param fallback] when absent.
func _arg_value(name: String, fallback: String) -> String:
	for a in _args:
		if a.begins_with(name + "="):
			return a.substr(name.length() + 1)
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
	if get_window().content_scale_factor != 1.0:   # a scaled run is named by its window and scale, not its layout size
		tag = "%dx%d-scale%d" % [get_window().size.x, get_window().size.y, roundi(get_window().content_scale_factor * 100.0)]
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
		await _shot(dir, "08-comparison-travel", tag)
		_comparison.confirm()
		await _frames(5)
		await _shot(dir, "08b-travel-focus", tag)
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
	await _click(_portrait.get_global_rect().get_center())
	_check("clicking the portrait opens the character panel", _panel.visible)
	await _shot(dir, "11b-input-sheet-by-portrait", tag)
	await _key(KEY_ESCAPE)
	var target: String = _clickable_known_place()
	if target != "":
		var rec: Dictionary = GameQuery.place(session, target)
		var at: Vector2 = _map.global_position + _map.tile_to_local(Vector2i(int(rec.tile[0]), int(rec.tile[1])))
		await _click(at)
		_check("clicking a place opens the focus comparison with Travel preselected", _comparison.visible and _comparison.selected_id() == TurnController.FOCUS_TRAVEL + ":" + target)
		await _shot(dir, "12-input-place-clicked", tag)
		var confirm_btn: Button = null
		for b in _comparison.find_children("*", "Button", true, false):
			if b.text == tr("Confirm"):
				confirm_btn = b
		if confirm_btn != null:
			await _click(confirm_btn.get_global_rect().get_center())
		_check("confirming in the comparison sets Travel to it", turn.focus == TurnController.FOCUS_TRAVEL and turn.destination_id == target and not _comparison.visible)
	await _demo_wait_cooldown()
	var year_before: int = int(GameQuery.clock(session).index)
	await _click(_end_turn.get_global_rect().get_center())
	await _wait_job()
	await _frames(5)
	_check("clicking End turn passes a season", int(GameQuery.clock(session).index) != year_before)
	_check("the summary opens after the turn", _centre.visible)
	await _shot(dir, "13-input-summary-by-click", tag)
	await _key(KEY_ENTER)
	_check("Enter on the summary closes it", not _centre.visible or session.has_pending_event())
	await _demo_answer_events_by_click(dir, tag)
	await _demo_wait_cooldown()
	_end_turn.grab_focus()
	await _frames(2)
	var before2: int = int(GameQuery.clock(session).index)
	await _key(KEY_ENTER)
	await _wait_job()
	await _frames(5)
	_check("Enter on a focused End turn passes a season", int(GameQuery.clock(session).index) != before2)
	await _shot(dir, "14-input-enter-end-turn", tag)
	await _key(KEY_ENTER)
	await _demo_answer_events_by_click(dir, tag)
	await _demo_bubbles(dir, tag)
	await _demo_places(dir, tag)
	await _demo_tooltips(dir, tag)
	await _demo_person_and_fight(dir, tag)


## The tooltip layer through real input: hover, a nested word, a middle-click lock, a consumed click outside; then the
## keyboard: Q, Enter on a word, Tab wrapping, Esc one level at a time with focus going back; then the 5th level's
## word opening the wiki.
func _demo_tooltips(dir: String, tag: String) -> void:
	_tips.close_all()
	await _frames(10)
	await _move(_stones.get_global_rect().get_center())
	await _seconds(0.6)   # the delay is in seconds (0.3 s); frames run faster than 60 a second here
	_check("hovering the spirit stones opens their tooltip (opened: %s; hovered: %s)" % [str(_tips.chain.levels[0].content.get("title", "")) if _tips.is_open() else "none", str(get_viewport().gui_get_hovered_control())],
		_tips.is_open() and str(_tips.chain.levels[0].content.get("title", "")).contains("Spirit stones"))
	var ws: Array = _tips.words(0)
	if not ws.is_empty():
		await _move((ws[0] as Control).get_global_rect().get_center())
		await _seconds(0.6)   # the delay is in seconds (0.3 s); frames run faster than 60 a second here
		_check("hovering a highlighted word opens a second tooltip", _tips.chain.levels.size() == 2)
		if _tips.view(1) != null:
			await _move(_tips.view(1).get_global_rect().get_center())
			await _frames(3)
			await _mouse_button(_tips.view(1).get_global_rect().get_center(), MOUSE_BUTTON_MIDDLE)
			_check("a middle click locks the chain", _tips.chain.is_locked())
			await _shot(dir, "22-tooltip-nested", tag)
			var away: Vector2 = _map.get_global_rect().get_center() + Vector2(0, 120)
			await _move(away)
			await _seconds(1.0)   # longer than the 0.3 s grace
			_check("a locked chain stays open with the pointer away", _tips.chain.levels.size() == 2)
			await _click(away)
			_check("a click outside closes it and does not reach the map", not _tips.is_open() and not _comparison.visible and not _panel.visible)
	# Keyboard
	_stones.grab_focus()
	await _frames(2)
	await _key(KEY_Q)
	_check("Q opens the focused readout's tooltip, locked, with focus inside", _tips.chain.is_locked() and _tips.owns(get_viewport().gui_get_focus_owner()))
	await _key(KEY_ENTER)
	_check("Enter on a highlighted word opens its tooltip with focus in it", _tips.chain.levels.size() == 2 and _tips.owns(get_viewport().gui_get_focus_owner()))
	for i in 6:
		await _key(KEY_TAB)
	_check("Tab wraps inside the tooltip", _tips.view(1) != null and _tips.view(1).is_ancestor_of(get_viewport().gui_get_focus_owner()))
	var back_to: Control = _tips.words(0)[0] if not _tips.words(0).is_empty() else null
	await _key(KEY_ESCAPE)
	_check("Esc closes only the top tooltip and focus goes back to its word", _tips.chain.levels.size() == 1 and get_viewport().gui_get_focus_owner() == back_to)
	await _key(KEY_ESCAPE)
	_check("Esc again closes the root and focus goes back to the source", not _tips.is_open() and get_viewport().gui_get_focus_owner() == _stones)
	# Depth: Enter down the first words to the 5th level, whose word opens the wiki.
	await _key(KEY_Q)
	for lvl in 4:
		await _key(KEY_ENTER)
	_check("five levels open", _tips.chain.levels.size() == 5)
	await _shot(dir, "23-tooltip-depth-5", tag)
	await _key(KEY_ENTER)
	_check("a word at the 5th level opens the wiki (stub) instead of a 6th level", _panel.visible and not _tips.is_open())
	await _shot(dir, "24-wiki-stub", tag)
	await _key(KEY_ESCAPE)
	_check("Esc closes the wiki panel", not _panel.visible)
	await _demo_answer_events(dir, tag)
	await _demo_wait_cooldown()
	_end_turn.grab_focus()
	_try_end_turn()
	await _wait_job()
	await _frames(5)
	await _key(KEY_ESCAPE)
	_check("Esc closes the season summary (a waiting event's card shows instead)", not _centre.visible or _centre.showing_event)
	await _demo_close_centre()
	await _demo_answer_events(dir, tag)


func _seconds(t: float) -> void:
	await get_tree().create_timer(t).timeout


## The person window and the fight screen through real input: open a person, V to the verbs, Greet, then a practice
## fight played at 4×, skipped to the end and closed with Esc.
func _demo_person_and_fight(dir: String, tag: String) -> void:
	_tips.close_all()
	var here: String = _here_id()
	var people: Array = GameQuery.people_at(session, here)
	var at_home: bool = not people.is_empty()
	if not at_home:   # the Travel step lands where its row sits on screen, so at some sizes the place is empty
		for pl in GameQuery.known_places(session):
			people = GameQuery.people_at(session, str(pl.id))
			if not people.is_empty():
				break
	var pick: String = ""
	var my_realm: int = int(StateSnapshot.take(session).get("realm_index", 0))
	var best: int = -1
	for x in people.slice(0, 20):   # the opponent whose practice fight shows the most stacks, statuses and steps
		var f: Dictionary = GameQuery.practice_fight(session, str(x.id))
		var score: int = Array(f.get("rows", [])).filter(func(r): return str(r.kind) in ["stacks", "status", "step", "feed", "effect"]).size()
		if score > best or (score == best and int(x.realm_index) == my_realm):
			best = score
			pick = str(x.id)
	_check("there is someone to open", pick != "")
	if pick == "":
		return
	# Through the map: the people bubble at your place counts everyone there, met or not, and opens them.
	_refresh()
	await _frames(3)
	var bubble: Control = null
	for c in _map.find_children("*", "MapBubble", true, false):
		if str(c.kind) == "people" and (c as Control).is_visible_in_tree() and at_home:
			bubble = c
	if at_home:
		_check("your place shows a people bubble in a new game", bubble != null)
	else:
		print("INPUT CHECK SKIP: nobody at your place after the Travel step at this size; the person opens directly")
	if bubble != null:
		await _click(bubble.get_global_rect().get_center())
		await _frames(5)
		if not _person.visible and _people_list.visible:
			var want: String = str(GameQuery.person(session, pick).get("name", ""))
			for b in _people_list.get_children():
				if str(b.text).begins_with(want + " ·"):
					await _click(b.get_global_rect().get_center())
					break
			await _frames(5)
	if not _person.visible:
		_open_person(pick, _end_turn)
		await _frames(5)
	_check("the person window opens with the person's sheet", _person.visible and _person.person_id() != "")
	await _shot(dir, "25-person-window", tag)
	await _key(KEY_V)
	await _frames(3)
	await _shot(dir, "26-person-verbs", tag)
	var greet: Button = null
	for b in _person.find_children("*", "Button", true, false):
		if str(b.text).contains("Greet") and not (b as Button).disabled:
			greet = b
	if greet != null:
		await _click(greet.get_global_rect().get_center())
		await _wait_job()
		await _frames(5)
		_check("Greet runs and its reply shows in the reply strip", _person.visible and _person.find_children("*", "Label", true, false).any(func(l): return l.visible and str(l.text) != "" and l.modulate == Color(1.0, 0.92, 0.7)))
		await _shot(dir, "27-person-greet", tag)
	var fight_btn: Button = null
	for b in _person.find_children("*", "Button", true, false):
		if str(b.text) == tr("Practice fight"):
			fight_btn = b
	_check("the window offers a practice fight", fight_btn != null)
	if fight_btn == null:
		return
	await _click(fight_btn.get_global_rect().get_center())
	await _frames(5)
	_check("the practice fight opens the fight screen", _fight.visible)
	_check("each side shows its arts as painted slots", _fight.art_slots("A").size() > 0 and _fight.art_slots("B").size() > 0
		and _fight.art_slots("A").all(func(sl): return sl.icon != null))
	await _shot(dir, "28-fight-start", tag)
	await _key(KEY_3)
	await _key(KEY_SPACE)
	await _seconds(0.8)
	await _shot(dir, "29-fight-playing", tag)
	_check("art slots charge and fire during playback", _fight.art_slots("A").any(func(sl): return sl.charge < 1.0 or sl.flash > 0.0))
	await _key(KEY_S)
	await _frames(3)
	_check("S skips to the end and the ending is labelled", _fight.ended())
	await _shot(dir, "30-fight-end", tag)
	await _demo_fight_log(dir, tag)
	await _key(KEY_ESCAPE)
	await _frames(3)
	_check("Esc closes the fight screen once it has ended", not _fight.visible)
	await _key(KEY_ESCAPE)
	_check("Esc closes the person window", not _person.visible)


## The fight log through real input, on an ended fight: the result line comes first; a folded line opens on a click;
## Up / Down move the selection; the foe filter hides the foe's lines; Full shows one line per pulse.
func _demo_fight_log(dir: String, tag: String) -> void:
	if not _fight.visible or not _fight.ended():
		_check("the fight log checks need an ended fight on screen", false)
		return
	var view: FightLogView = _fight.log_view()
	var table: Dictionary = _cfg.get("fight_screen", {}).get("effect_icons", {})
	var chips: Array = _fight.chips("A", "status") + _fight.chips("B", "status")
	_check("the fight screen has its ui_hud.json settings (it was configured before they loaded)", _fight.log_button("summary") != null
		and table.size() > 1 and chips.all(func(c): return c.icon != null or not table.has(str(c.short))))
	var ids: PackedStringArray = view.line_ids()
	_check("the ended fight's log starts with the result and its reasons", ids.size() > 1 and ids[0] == "result"
		and view.line_text(0).contains(";"))
	var folded: int = -1
	for i in ids.size():
		if ids[i].begins_with("s:") and view.line_text(i).contains("×"):
			folded = i
			break
	_check("repeats fold into one line with a count", folded >= 0)
	if folded >= 0:
		var before: int = ids.size()
		await _click(view.get_child(0).get_child(folded).get_global_rect().get_center())
		await _frames(3)
		_check("clicking a folded line opens its repeats", view.line_ids().size() > before and view.selected_id() == ids[folded])
		await _shot(dir, "31-fight-log-open", tag)
	view.grab_focus()
	var sel: String = view.selected_id()
	await _key(KEY_DOWN)
	await _frames(2)
	_check("Down moves the log's selection", view.selected_id() != sel and view.selected_id() != "")
	await _click(_fight.log_button("B").get_global_rect().get_center())
	await _frames(3)
	var foe_lines: int = Array(view.line_ids()).filter(func(id): return _fight.log_line_side(str(id)) == "B").size()
	_check("the Foe filter hides the foe's lines", not _fight.log_button("B").button_pressed and foe_lines == 0)
	await _shot(dir, "32-fight-log-you-only", tag)
	await _click(_fight.log_button("B").get_global_rect().get_center())
	await _click(_fight.log_button("full").get_global_rect().get_center())
	await _frames(3)
	var full_ids: PackedStringArray = view.line_ids()
	_check("Full shows one line per pulse with health and linh lực after", full_ids.size() > 1 and full_ids[1].begins_with("f:")
		and view.line_text(1).contains(tr("linh lực")))
	await _shot(dir, "33-fight-log-full", tag)
	await _click(_fight.log_button("summary").get_global_rect().get_center())
	await _frames(2)


## Moves the pointer to [param at] (layout coordinates). Since Godot 4.3 hover follows the real cursor, not pushed
## motion events, so the demo warps the cursor itself (measured 2026-11-22) and also sends the motion event.
func _move(at: Vector2) -> void:
	Input.warp_mouse(at * get_window().content_scale_factor)
	var motion := InputEventMouseMotion.new()
	motion.position = at
	motion.global_position = at
	get_viewport().push_input(motion, true)   # layout coordinates (the UI scale stretches the window)
	await _frames(2)


func _mouse_button(at: Vector2, button: MouseButton) -> void:
	for pressed in [true, false]:
		var ev := InputEventMouseButton.new()
		ev.position = at
		ev.global_position = at
		ev.button_index = button
		ev.pressed = pressed
		get_viewport().push_input(ev, true)
		await _frames(2)


## The Places panel through real input: P, route times filling in, a row selected, Enter for details, Esc, and
## "Travel here" into the comparison.
func _demo_places(dir: String, tag: String) -> void:
	_end_turn.grab_focus()
	await _frames(2)
	await _key(KEY_P)
	_check("P opens the Places panel", _places.visible)
	var guard: int = 0
	while not _places.pending_ids().is_empty() and guard < 600:
		await get_tree().process_frame
		guard += 1
	_check("every route time is worked out", _places.pending_ids().is_empty())
	var plist: ItemList = _places.find_children("*", "ItemList", true, false)[0]
	var row_i: int = -1
	for i in plist.item_count:
		if plist.is_item_selectable(i):
			row_i = i
			break
	if row_i >= 0:
		await _move(plist.get_global_transform() * plist.get_item_rect(row_i).get_center())
		await _seconds(0.6)
		_check("hovering a Places row shows the whole row", _tips.is_open() and str(_tips.chain.levels[0].content.get("title", "")) == plist.get_item_text(row_i))
		await _move(_map.get_global_rect().get_center() + Vector2(0, 160))
		await _seconds(0.6)
		plist.select(row_i)
		plist.grab_focus()
		await _frames(2)
		await _key(KEY_Q)
		_check("Q on the list opens the selected row's tooltip", _tips.chain.is_locked() and str(_tips.chain.levels[0].content.get("title", "")) == plist.get_item_text(row_i))
		await _key(KEY_ESCAPE)
		_check("Esc closes that tooltip and focus goes back to the list", not _tips.is_open() and get_viewport().gui_get_focus_owner() == plist)
	var target: String = _nearest_known_place()
	if target != "":
		_places.select_place(target)
		await _frames(5)
		_check("selecting a row centres the map at region zoom", _map.is_region_zoom())
		await _shot(dir, "20-places-panel", tag)
		var travel_btn: Button = null
		for b in _places.find_children("*", "Button", true, false):
			if b.text == tr("Travel here"):
				travel_btn = b
		if travel_btn != null:
			await _click(travel_btn.get_global_rect().get_center())
			_check("Travel here opens the comparison with Travel preselected", _comparison.visible and _comparison.selected_id() == TurnController.FOCUS_TRAVEL + ":" + target)
			# Travel with the panel open: after the season it must describe the new place, not the old one.
			_comparison.confirm()
			await _demo_wait_cooldown()
			_try_end_turn()
			await _wait_job()
			await _frames(3)
			var now_at: String = str(GameQuery.here(session).get("name", ""))
			_check("after travelling with Places open it shows the new place (%s)" % now_at, _places.visible and _places.here_name() == now_at)
			await _demo_close_centre()
			await _demo_answer_events(dir, tag)
			if not _places.visible:
				await _key(KEY_P)
	if _places.visible:
		var list: ItemList = _places.find_children("*", "ItemList", true, false)[0]
		var row: String = _nearest_known_place()
		if row != "":
			_places.select_place(row)   # the rebuild after the journey leaves no row selected
		list.grab_focus()
		await _frames(2)
		await _key(KEY_ENTER)
		_check("Enter on a row opens the place's details", _panel.visible and not _places.visible)
		await _shot(dir, "21-place-details", tag)
		await _key(KEY_ESCAPE)
	await _key(KEY_P)
	await _key(KEY_P)
	await _key(KEY_ESCAPE)
	_check("Esc closes the Places panel", not _places.visible)


## Region zoom and the map bubbles through real input (keys and clicks).
func _demo_bubbles(dir: String, tag: String) -> void:
	_end_turn.grab_focus()
	await _frames(2)
	var area_before: int = _map.visible_bubbles().filter(func(b): return b.kind != "player" and b.kind != "abode").size()
	_check("continent zoom shows no area bubbles", area_before == 0)
	await _key(KEY_EQUAL)
	_check("+ switches to region zoom", _map.is_region_zoom())
	await _frames(5)
	await _shot(dir, "16-region-bubbles", tag)

	var shown: Array = _map.visible_bubbles()
	var area: Array = shown.filter(func(b): return b.kind != "player" and b.kind != "abode")
	_check("region zoom shows area bubbles (%d)" % area.size(), area.size() > 0)
	_check("no more than bubbles_max area bubbles", area.size() <= int(_bubble_cfg().get("max", 12)))
	var here: String = _here_id()
	var away: Array = area.filter(func(b): return b.place_id != here)
	if not away.is_empty():
		await _click((away[0] as Control).get_global_rect().get_center())
		_check("a bubble at another place opens the comparison with Travel preselected", _comparison.visible and _comparison.selected_id() == TurnController.FOCUS_TRAVEL + ":" + str(away[0].place_id))
		await _shot(dir, "17-bubble-elsewhere-comparison", tag)
		await _key(KEY_ESCAPE)
		_check("Esc closes the comparison without changing the focus", not _comparison.visible)
	# bubbles are rebuilt on every refresh: look them up again after each action
	var mine: Array = _map.visible_bubbles().filter(func(b): return b.kind != "player" and b.kind != "abode" and b.place_id == here)
	if not mine.is_empty():
		var mine_kind: String = mine[0].kind
		(mine[0] as Control).grab_focus()
		await _frames(2)
		await _key(KEY_ENTER)
		_check("Enter on a focused bubble here acts like a click (%s)" % mine_kind, _panel.visible or _comparison.visible)
		await _shot(dir, "18-bubble-here", tag)
		await _key(KEY_ESCAPE)
	var me: Array = _map.visible_bubbles().filter(func(b): return b.kind == "player")
	if not me.is_empty():
		await _click((me[0] as Control).get_global_rect().get_center())
		_check("clicking your bubble opens the character sheet", _panel.visible)
		await _key(KEY_ESCAPE)
	_end_turn.grab_focus()
	await _frames(2)
	await _key(KEY_MINUS)
	_check("- returns to continent zoom", not _map.is_region_zoom())
	await _frames(5)
	await _shot(dir, "19-back-to-continent", tag)


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
	get_viewport().push_input(motion, true)
	await _frames(2)
	for pressed in [true, false]:
		var ev := InputEventMouseButton.new()
		ev.position = at
		ev.global_position = at
		ev.button_index = MOUSE_BUTTON_LEFT
		ev.pressed = pressed
		get_viewport().push_input(ev, true)
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
		for i in Array(GameQuery.pending_event(session).get("choices", [])).size():
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


## The nearest known place whose dot no bubble covers (a bubble on a place wins the click, per the spec), so the
## demo's real click lands on the place itself.
func _clickable_known_place() -> String:
	var here: Dictionary = GameQuery.here(session)
	var best: String = ""
	var best_d: float = INF
	for p in GameQuery.known_places(session):
		if bool(p.here):
			continue
		var at: Vector2 = _map.global_position + _map.tile_to_local(Vector2i(int(p.tile[0]), int(p.tile[1])))
		var covered: bool = false
		for b in _map.visible_bubbles():
			if (b as Control).get_global_rect().grow(4).has_point(at):
				covered = true
		for z in _zones:
			if (z as Control).get_global_rect().has_point(at):
				covered = true
		if covered or not _map.get_global_rect().has_point(at):
			continue
		var d: float = Vector2(int(p.tile[0]) - int(here.tile[0]), int(p.tile[1]) - int(here.tile[1])).length()
		if d < best_d:
			best_d = d
			best = str(p.id)
	return best


func _nearest_known_place() -> String:
	var here: Dictionary = GameQuery.here(session)
	if not here.has("tile"):
		return ""
	var best: String = ""
	var best_d: float = INF
	for p in GameQuery.known_places(session):
		if bool(p.here):
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
