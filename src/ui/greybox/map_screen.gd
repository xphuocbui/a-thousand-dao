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
## --demo plays a fixed script (sheet, seasons, events, a journey, region zoom and bubbles) and saves a screenshot at each step to
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
		_map.setup(grid, _greybox(), float(_bubble_cfg().get("region_zoom", 4.0)))
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
	_zones.append(z2)
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
	_zones.append(z3)
	var row := HBoxContainer.new()
	z3.add_child(row)
	# Element 7: the portrait is a button; a click (or Enter / gamepad A on it) opens the character sheet.
	_portrait.custom_minimum_size = Vector2(80, 80)
	_portrait.tooltip_text = tr("Your character: click to open the sheet (C)")
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
	_cult_bar.tooltip_text = tr("Cultivation progress to the next level")
	col.add_child(_cult_bar)
	col.add_child(_lifespan)

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
		b.tooltip_text = tr("Map mode") if m[1] else tr("Not in the greybox yet")
		z4.add_child(b)
	_zoom_button.text = tr("Region view")
	_zoom_button.tooltip_text = tr("Zoom in around you to see what you can do nearby (+ / −, or the mouse wheel)")
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
	_focus.tooltip_text = tr("Season focus: opens the focus comparison")
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
	_focus.text = tr("Focus:") + " " + turn.focus_label() + "  ▾"
	_zoom_button.text = tr("Continent view") if _map.is_region_zoom() else tr("Region view")


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
	_map.set_state(places, tile, location_id, turn.destination_id)
	_map.set_bubbles(_bubbles(places, location_id, tile))
	var rects: Array = []
	for z in _zones:
		rects.append((z as Control).get_global_rect())
	if _panel.visible:
		rects.append(_panel.get_global_rect())
	_map.set_blocked_rects(rects)


## The bubbles for the map (design/ux/hud.md, Map bubbles): yours, the abode's, and the area bubbles from BubbleModel
## over what the player knows.
func _bubbles(places: Array, here_id: String, here_tile: Vector2i) -> Array:
	var out: Array = []
	var c: Character = session.player
	if here_tile.x >= 0:
		out.append({"kind": "player", "place_id": here_id, "tile": here_tile,
			"tooltip": "%s — %s — %s (%s)" % [c.name, gd.realm_label(c.realm_index, c.stage), str(session.db.get_record("places", here_id).get("name", "")), tr("click: character sheet")]})
	var home: Dictionary = session.db.get_record("places", str(c.home_id))
	if str(c.home_id) != "" and home.has("tile"):
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
	var met_here: int = session.db.find("people", func(x): return bool(x.get("alive", true)) and not bool(x.get("is_player", false)) and bool(x.get("met_player", false)) and str(x.get("location_id", "")) == here_id).size()
	var kinds_by_place: Dictionary = {}
	for id in dist:
		var rec: Dictionary = session.db.get_record("places", id)
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
	var tg: TravelGrid = TravelGrid.of(gd)
	var f: float = Travel.speed_factor(gd, session.sheet().total("travel_speed_pct"))
	var radius: float = float(_bubble_cfg().get("prefilter_tiles_per_season", 90.0)) * reach
	for pl in places:
		if pl.id == here_id or here_tile.x < 0 or Vector2(pl.tile - here_tile).length() > radius:
			continue
		var t: float = -1.0
		if tg.errors.is_empty():
			var trip: Dictionary = tg.trip(here_tile, pl.tile, "ground", f)
			if not trip.is_empty():
				t = float(trip.seasons)
		if t < 0.0:
			var route: Dictionary = Travel.quickest(session.db, here_id, str(pl.id), f)
			if not route.is_empty():
				t = float(route.seasons)
		if t >= 0.0 and t <= reach + 1e-9:
			out.append({"to": str(pl.id), "seasons": t})
	_trip_key = key
	_trip_cache = out
	return out


func _kind_name(kind: String, count: int) -> String:
	match kind:
		"market": return tr("Market")
		"sect": return tr("Sect")
		"work": return tr("Missions and bounties")
		"people": return tr("People you know") + " (%d)" % count
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
	if place_id == str(session.player.location_id):
		_open_comparison(TurnController.FOCUS_CULTIVATE, "")
	else:
		_open_comparison(TurnController.FOCUS_TRAVEL, place_id)


func _toggle_zoom() -> void:
	if session == null:
		return
	var here: Dictionary = session.db.get_record("places", str(session.player.location_id))
	var at := Vector2(-1, -1)
	if here.has("tile"):
		at = Vector2(int(here.tile[0]), int(here.tile[1])) + Vector2(0.5, 0.5)
	_map.set_region_zoom(not _map.is_region_zoom(), at)


func _on_bubble_pressed(kind: String, place_id: String) -> void:
	if _busy():
		return
	var here: String = str(session.player.location_id)
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
			_panel.open_panel(tr("Sect"), Array(session.sect_status().get("lines", [])), _end_turn)
		"people":
			_panel.open_panel(tr("People you know here"), _people_lines(here), _end_turn)
		"work":
			_open_comparison(TurnController.FOCUS_MISSION, "")
		"explore":
			_open_comparison(TurnController.FOCUS_EXPLORE, "")


## The market's current stock, read only (stocking it would draw from the game's random streams, which the UI must
## not do); the trade window is not in the greybox yet.
func _market_lines(place_id: String) -> Array:
	var lines: Array = [tr("The trade window is not in the greybox yet."), ""]
	var stock: Array = session.market.stock(place_id)
	if stock.is_empty():
		lines.append(tr("No stock seen yet: it appears when you trade here."))
	for it in stock:
		lines.append(session.items.describe(it))
	return lines


func _people_lines(place_id: String) -> Array:
	var lines: Array = [tr("Person cards are not in the greybox yet."), ""]
	for x in session.db.find("people", func(q): return bool(q.get("alive", true)) and not bool(q.get("is_player", false)) and bool(q.get("met_player", false)) and str(q.get("location_id", "")) == place_id):
		lines.append(TerminalViews.person_line(session, x))
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
		var rec: Dictionary = session.db.get_record("places", dest)
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
		turn.choose_travel(dest, str(session.db.get_record("places", dest).get("name", dest)))
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
	_open_sheet_from(_sheet_button)


## Opens the character sheet in Z6; [param opener] gets focus back when it closes.
func _open_sheet_from(opener: Control) -> void:
	if _busy():
		return
	_panel.open_panel(tr("Character"), TerminalViews.sheet(session, TerminalIO.new()), opener)


func _unhandled_key_input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return
	var key: Key = (event as InputEventKey).physical_keycode
	var owner_ctl: Control = get_viewport().gui_get_focus_owner()
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
		if _comparison.visible:
			_comparison.cancel()
			get_viewport().set_input_as_handled()
		elif _panel.visible:
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
		var rec: Dictionary = session.db.get_record("places", target)
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
	await _demo_answer_events_by_click(dir, tag)
	await _demo_bubbles(dir, tag)


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
	var here: String = str(session.player.location_id)
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


## The nearest known place whose dot no bubble covers (a bubble on a place wins the click, per the spec), so the
## demo's real click lands on the place itself.
func _clickable_known_place() -> String:
	var here: Dictionary = session.db.get_record("places", str(session.player.location_id))
	var best: String = ""
	var best_d: float = INF
	for p in session.db.all("places"):
		if str(p.id) == str(session.player.location_id) or not p.has("tile") or bool(p.get("hidden", false)):
			continue
		if session.knowledge != null and not session.knowledge.knows_place(str(p.id)):
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
