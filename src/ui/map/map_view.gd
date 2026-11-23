class_name MapView
extends Control
## The continent map of the map screen (design/ux/hud.md, Information Architecture Group 3, Map bubbles, and Map zoom
## and the political map): one continuous zoom measured in screen px per tile, from the fit (the whole continent) to
## zoom_max_px. Below the transition band the paper map (far layer) shows with the political map (each region tinted in
## its great sect's colour, bold ink where the holder changes, the great sects' names large across their territory);
## above it the painted relief (near layer), streamed in tiles at 48 px per tile when zoomed in close (near_hi); inside
## the band the two cross-fade. Place art shows in the place panel, not on the map (user, 2026-11-23: a town painted
## to scale never fits the map). Known places are
## diamonds; the player's bubble (element 30), the abode bubble (31) and, on the region side of the band, the area
## bubbles (32). Drag with the left or middle button, or the arrow keys, to pan; the wheel zooms about the cursor, + and
## - about the centre, 0 back to the fit. Display only: it never changes game state; clicks are reported through
## signals.

## The player clicked the known place [param place_id] (not a bubble).
signal place_clicked(place_id: String)
## The player pressed a bubble of [param kind] at [param place_id] ("player", "abode" or an area kind).
signal bubble_pressed(kind: String, place_id: String)
## The zoom crossed the middle of the transition band ([param region] true on the region side).
signal zoom_changed(region: bool)

const DRAG_THRESHOLD := 5.0
const PAN_STEP := 40.0

var _texture: ImageTexture = null
## The painted layers (art bible Section 1, Principle 2: one map, two distances); null falls back to the biome colours.
var _far: Texture2D = null
var _near: Texture2D = null
## Place art on the near layer (assets/map/places/manifest.json): place id -> {texture (loaded on first draw), tile,
## size_tiles}. Drawn for known places only, so the art never reveals a place the player has not found.
var _sprites: Dictionary = {}
var _sprite_dir: String = ""
var _place_art_on_map: bool = false   # ui_hud.json greybox.place_art_on_map (off: the art is the panel's picture)
## The streamed near tiles (assets/map/near_hi/manifest.json): {dir, chunk_tiles, px_per_tile, pad, cols, rows}, empty
## when absent. Loaded tiles: "cx_cy" -> {tex, used (msec)}; requested and not yet loaded: "cx_cy" -> path.
var _hi: Dictionary = {}
var _hi_tex: Dictionary = {}
var _hi_pending: Dictionary = {}
## Place symbols (ui_hud.json greybox.place_symbols; user 2026-11-23, style G): kind -> Texture2D for built places
## (seats, cities, towns, markets, villages, mines); natural landmarks have none, they are painted into the terrain.
## The data-driven terrain (TerrainView, ui_hud.json greybox.terrain_shader; user 2026-11-23): when it loads, it is
## the near layer (the painted relief and its streamed tiles are not drawn).
var _terrain: TerrainView = null
var _symbols: Dictionary = {}
var _symbol_px: Dictionary = {}     # kind -> screen px of the symbol's longest side at the relief's start
var _symbol_grow: float = 1.3       # how much bigger at the deepest zoom
## Region names at continent zoom: [{name, centre: Vector2 (tile)}] (art bible 7.14: engine-drawn, never painted).
var _regions: Array = []
var _region_font: Font = null
## The colour around the map image (the paper at continent zoom, the open sea at region zoom).
var _backdrop_far := Color(0.08, 0.1, 0.14)
var _backdrop_near := Color(0.08, 0.1, 0.14)
var _grid_size := Vector2i.ZERO
var _regn := PackedInt32Array()   # the grid's region id per tile (0 = sea)
## Known places: [{id, name, tile: Vector2i, kind}].
var _places: Array = []
var _player_tile := Vector2i(-1, -1)
var _player_place: String = ""
var _destination_id: String = ""
var _place_radius: float = 3.0
var _hover_id: String = ""
var _hover_region: int = -1
var _region_factor: float = 4.0
var _zcfg: Dictionary = {}        # ui_hud.json greybox.map_zoom
var _px: float = 0.0              # screen px per tile now (0 until the first layout: the fit)
var _px_target: float = 0.0
var _anchor_tile := Vector2(-1, -1)   # the tile kept under _anchor_pos while the zoom moves
var _anchor_pos := Vector2.ZERO
var _zvel: float = 0.0                # the zoom's speed, in log px per tile per second (momentum)
var _glide_t: float = -1.0            # a glide's progress 0..1 (-1: none)
var _glide_from_px: float = 0.0
var _glide_to_px: float = 0.0
var _glide_from_c := Vector2.ZERO
var _glide_to_c := Vector2.ZERO
var _pan_vel := Vector2.ZERO          # a released drag's fling, screen px per second
var _key_vel := Vector2.ZERO          # held arrow keys' pan, screen px per second
var _drag_samples: Array = []         # recent [time, position] while dragging (the fling's speed)
var _reduced_motion: bool = false
var _colourblind: bool = false
var _was_region: bool = false
var _center := Vector2.ZERO       # the tile point at the middle of the view
var _drag_from := Vector2.ZERO
var _dragging: bool = false
var _press_pos := Vector2.ZERO
var _pressed: bool = false
var _layer := Control.new()
var _blocked: Array = []          # global Rect2s where bubbles are not drawn or clickable (the HUD zones)
## The political map, baked from the region grid and the holders (hud.md: recoloured only when a holder changes).
var _politics_sig: String = ""
var _tint: ImageTexture = null
var _lines_bold: Array = []   # smoothed border polylines in tile coordinates (PackedVector2Array each)
var _lines_thin: Array = []
var _lines_prov: Array = []   # between two provinces of one region: the faintest, fading in as the zoom closes
## The provinces' border lines (assets/map/continent_11_provinces.json): [{a, b, pts}], a and b the provinces they
## separate; with them the region and holder borders come from the same smoothed lines, so nothing doubles up.
var _prov_lines: Array = []
var _prov_region: Dictionary = {}   # province id -> grid region id
var _borders_on: bool = true        # element 13's Borders toggle: region and province lines (never the holder lines)
var _realms: Array = []                 # [{name, centre: Vector2 tile, width_tiles}]
var _region_info: Dictionary = {}       # grid region id -> {name, holder_name}


func _init() -> void:
	clip_contents = true
	focus_mode = Control.FOCUS_ALL
	_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_layer)


## Builds the map image from [param grid] with [param cfg] (ui_hud.json "greybox", its "map_zoom" block for the zoom
## and the political map) and [param region_factor] (kept for callers; the zoom is in px per tile now).
func setup(grid: ContinentGrid, cfg: Dictionary, region_factor: float) -> void:
	_place_radius = float(cfg.get("place_radius_px", 3.0))
	_region_factor = region_factor
	_zcfg = cfg.get("map_zoom", {})
	_grid_size = Vector2i(grid.width, grid.height)
	_center = Vector2(_grid_size) * 0.5
	var colours: Dictionary = cfg.get("biome_colours", {})
	var unknown := Color(str(cfg.get("unknown_colour", "#808080")))
	var by_id: Dictionary = {}
	var img := Image.create(grid.width, grid.height, false, Image.FORMAT_RGB8)
	_regn.resize(grid.width * grid.height)
	for y in grid.height:
		for x in grid.width:
			var b: int = grid.main_biome(x, y)
			if not by_id.has(b):
				var name: String = grid.biome_name(b)
				by_id[b] = Color(str(colours[name])) if colours.has(name) else unknown
			img.set_pixel(x, y, by_id[b])
			_regn[y * grid.width + x] = grid.region(x, y)
	_texture = ImageTexture.create_from_image(img)
	_far = _layer_texture(str(cfg.get("far_layer", "")))
	_near = _layer_texture(str(cfg.get("near_layer", "")))
	_load_sprites(str(cfg.get("place_sprites", "")))
	_place_art_on_map = bool(cfg.get("place_art_on_map", false))
	_load_hi(str(cfg.get("near_hi", "")))
	_load_symbols(cfg.get("place_symbols", {}))
	_load_terrain(cfg.get("terrain_shader", {}))
	_load_provinces(str(cfg.get("provinces_file", "")))
	_backdrop_far = Color.from_string(str(cfg.get("backdrop_far", "#141A24")), Color(0.08, 0.1, 0.14))
	_backdrop_near = Color.from_string(str(cfg.get("backdrop_near", "#141A24")), Color(0.08, 0.1, 0.14))
	mouse_filter = Control.MOUSE_FILTER_STOP
	_px = 0.0
	_relayout()


## Sets the known places, the player's tile and place, and the destination.
func set_state(places: Array, player_tile: Vector2i, player_place: String, destination_id: String) -> void:
	_places = places
	_player_tile = player_tile
	_player_place = player_place
	_destination_id = destination_id
	_relayout()


## Replaces the bubbles with [param bubbles]: [{kind, place_id, count, tile: Vector2i, tooltip, locked}]. The player and
## abode bubbles show at every zoom; area bubbles only on the region side of the band (the caller passes them always).
func set_bubbles(bubbles: Array) -> void:
	# keep keyboard focus across the rebuild: the bubble of the same kind at the same place gets it back
	var focused_key: String = ""
	for c in _layer.get_children():
		if (c as Control).has_focus():
			focused_key = "%s|%s" % [c.kind, c.place_id]
		_layer.remove_child(c)
		c.queue_free()
	var per_place: Dictionary = {}
	for b in bubbles:
		var mb := MapBubble.new()
		mb.setup(str(b.kind), str(b.place_id), int(b.get("count", 0)), str(b.get("tooltip", "")))
		mb.tile = b.tile
		mb.locked = bool(b.get("locked", false))
		if mb.kind == "player":
			mb.cluster_offset = Vector2(0, 0)
		elif mb.kind == "abode":
			mb.cluster_offset = Vector2(0, 24)
		else:
			var i: int = int(per_place.get(mb.place_id, 0))
			per_place[mb.place_id] = i + 1
			mb.cluster_offset = Vector2(-26 + 30 * i, -30)
		mb.pressed.connect(func(): bubble_pressed.emit(mb.kind, mb.place_id))
		_layer.add_child(mb)
		if focused_key == "%s|%s" % [mb.kind, mb.place_id]:
			mb.grab_focus.call_deferred()
	_relayout()


## Rectangles (global coordinates) under the HUD zones: bubbles there are hidden and take no click.
func set_blocked_rects(rects: Array) -> void:
	_blocked = rects
	_relayout()


## Reduced motion (hud.md: a zoom step lands at once) and the red-green colourblind palette (sect_colours_cb).
func set_accessibility(reduced_motion: bool, colourblind: bool) -> void:
	_reduced_motion = reduced_motion
	if colourblind != _colourblind:
		_colourblind = colourblind
		_politics_sig = ""


## True on the region side of the transition band (the relief's weight is at least 0.5).
func is_region_zoom() -> bool:
	return near_weight() >= 0.5


## The relief's weight now: 0 below near_from_px, 1 at or above near_to_px, a smooth step between.
func near_weight() -> float:
	var a: float = float(_zcfg.get("near_from_px", 6.6))
	var b: float = float(_zcfg.get("near_to_px", 9.6))
	return smoothstep(a, b, tile_scale())


## Zooms to region zoom (region_zoom_px, or keeps a deeper zoom) centred on [param at_tile], or back to the fit when
## [param on] is false; both glide (an ease-in-out on zoom and pan together).
func set_region_zoom(on: bool, at_tile: Vector2 = Vector2(-1, -1)) -> void:
	if on:
		_glide_to(maxf(tile_scale(), float(_zcfg.get("region_zoom_px", 12.0))), at_tile if at_tile.x >= 0 else _center)
	else:
		zoom_fit()


## Centres the view on [param tile] at region zoom (the Places panel's selected row).
func centre_on(tile: Vector2i) -> void:
	set_region_zoom(true, Vector2(tile) + Vector2(0.5, 0.5))


## One zoom step by [param factor] about [param at] (local; outside the view: the centre). With motion it is an
## impulse on the zoom's speed (hud.md Map zoom: momentum), so quick steps accelerate and friction brings the zoom to
## rest; a single step travels by about [param factor]. With reduced motion it lands at once.
func zoom_by(factor: float, at: Vector2 = Vector2(-1, -1)) -> void:
	var pos: Vector2 = at if at.x >= 0 else size * 0.5
	_glide_t = -1.0
	_anchor_tile = local_to_tile(pos)
	_anchor_pos = pos
	if _px <= 0.0:
		_px = _fit_px()
	if _reduced_motion:
		_zvel = 0.0
		_set_px(clampf(tile_scale() * factor, _fit_px(), _max_px()))
		return
	var k: float = float(_zcfg.get("zoom_friction", 8.0))
	var vmax: float = float(_zcfg.get("zoom_speed_max", 6.0))
	_zvel = clampf(_zvel + log(factor) * k, -vmax, vmax)
	set_process(true)


## Back to the fit: the whole continent, centred (a glide).
func zoom_fit() -> void:
	_glide_to(_fit_px(), Vector2(_grid_size) * 0.5)


## The visible bubbles in order (for tests and the demo).
func visible_bubbles() -> Array:
	return _layer.get_children().filter(func(b): return b.visible)


## Screen pixels per tile now.
func tile_scale() -> float:
	if _grid_size == Vector2i.ZERO:
		return 1.0
	if _px <= 0.0:
		return _fit_px()
	return _px


## True while the view is moving (a glide, the zoom's momentum or a pan), for the demo checks.
func is_moving() -> bool:
	return is_processing()


## The fit: the zoom at which the whole continent fills the view.
func _fit_px() -> float:
	if _grid_size == Vector2i.ZERO or size.x <= 0.0:
		return 1.0
	return minf(size.x / float(_grid_size.x), size.y / float(_grid_size.y))


func _max_px() -> float:
	return maxf(_fit_px(), float(_zcfg.get("zoom_max_px", 18.0)))


## A glide: zoom (in log space) and centre move together from where they are to [param px] and [param centre] with an
## ease-in-out over glide_seconds, so a jump speeds up and slows down instead of snapping.
func _glide_to(px: float, centre: Vector2) -> void:
	if _px <= 0.0:
		_px = _fit_px()
	_zvel = 0.0
	_pan_vel = Vector2.ZERO
	_anchor_tile = Vector2(-1, -1)
	_glide_from_px = tile_scale()
	_glide_to_px = clampf(px, _fit_px(), _max_px())
	_glide_from_c = _center
	_glide_to_c = centre
	if _reduced_motion or float(_zcfg.get("glide_seconds", 0.45)) <= 0.0:
		_glide_t = -1.0
		_center = centre
		_set_px(_glide_to_px)
		return
	_glide_t = 0.0
	set_process(true)


func _set_px(v: float) -> void:
	_px = v
	_px_target = v
	if _anchor_tile.x >= 0:
		_center = _anchor_tile - (_anchor_pos - size * 0.5) / _px
	_clamp_center()
	_relayout()
	var region: bool = is_region_zoom()
	if region != _was_region:
		_was_region = region
		zoom_changed.emit(region)


## The motion each frame: a glide, the zoom's momentum, the pan's fling and held arrow keys; processing stops when
## everything is at rest.
func _process(delta: float) -> void:
	_stream_hi()
	var busy: bool = false
	if _glide_t >= 0.0:
		_glide_t = minf(1.0, _glide_t + delta / maxf(0.01, float(_zcfg.get("glide_seconds", 0.45))))
		var e: float = _glide_t * _glide_t * (3.0 - 2.0 * _glide_t)   # ease in, ease out
		_center = _glide_from_c.lerp(_glide_to_c, e)
		_set_px(exp(lerpf(log(_glide_from_px), log(_glide_to_px), e)))
		busy = _glide_t < 1.0
		if not busy:
			_glide_t = -1.0
	if absf(_zvel) > 0.0005:
		var lp: float = log(tile_scale()) + _zvel * delta
		var lo: float = log(_fit_px())
		var hi: float = log(_max_px())
		if lp <= lo or lp >= hi:   # the ends stop the zoom softly
			lp = clampf(lp, lo, hi)
			_zvel = 0.0
		_zvel *= exp(-float(_zcfg.get("zoom_friction", 8.0)) * delta)
		_set_px(exp(lp))
		busy = true
	else:
		_zvel = 0.0
	# held arrow keys: the pan speeds up to pan_speed and slows when released (while the map has focus)
	var dir := Vector2.ZERO
	if has_focus():
		dir = Vector2(float(Input.is_physical_key_pressed(KEY_RIGHT)) - float(Input.is_physical_key_pressed(KEY_LEFT)),
			float(Input.is_physical_key_pressed(KEY_DOWN)) - float(Input.is_physical_key_pressed(KEY_UP)))
	if dir != Vector2.ZERO:
		var target: Vector2 = dir.normalized() * float(_zcfg.get("pan_speed", 900.0))
		_key_vel = _key_vel.lerp(target, 1.0 - exp(-delta * float(_zcfg.get("pan_accel", 6.0))))
	else:
		_key_vel *= exp(-delta * float(_zcfg.get("pan_friction", 6.0)) * 1.5)
	var vel: Vector2 = _key_vel + (_pan_vel if not _dragging else Vector2.ZERO)
	if vel.length() > 2.0:
		var want: Vector2 = _center + vel * delta / tile_scale()
		_center = want
		_clamp_center()
		for k in 2:   # an edge stops the pan on that axis, losing its speed (hud.md Map zoom)
			if absf(_center[k] - want[k]) > 0.0001:
				_pan_vel[k] = 0.0
				_key_vel[k] = 0.0
		_relayout()
		busy = true
	if not _dragging:
		_pan_vel *= exp(-delta * float(_zcfg.get("pan_friction", 6.0)))
		if _pan_vel.length() < 2.0:
			_pan_vel = Vector2.ZERO
	if _key_vel.length() < 2.0 and dir == Vector2.ZERO:
		_key_vel = Vector2.ZERO
	# idle: stop processing, unless streamed tiles are still loading (they are collected here)
	if not busy and dir == Vector2.ZERO and _pan_vel == Vector2.ZERO and _key_vel == Vector2.ZERO and _hi_pending.is_empty():
		set_process(false)


## Pan stops at the continent's edges; an axis that fits in the view is centred.
func _clamp_center() -> void:
	var sc: float = tile_scale()
	var half: Vector2 = size * 0.5 / sc
	for k in 2:
		var g: float = float(_grid_size[k])
		if g <= half[k] * 2.0:
			_center[k] = g * 0.5
		else:
			_center[k] = clampf(_center[k], half[k], g - half[k])


## The screen position (local) of the top-left corner of the map image.
func _origin() -> Vector2:
	return size * 0.5 - _center * tile_scale()


## The local position of the centre of tile [param tile].
func tile_to_local(tile: Vector2i) -> Vector2:
	return _origin() + (Vector2(tile) + Vector2(0.5, 0.5)) * tile_scale()


## The tile point under local position [param pos].
func local_to_tile(pos: Vector2) -> Vector2:
	return (pos - _origin()) / tile_scale()


func _relayout() -> void:
	if _px <= 0.0 and size.x > 0.0 and _grid_size != Vector2i.ZERO:
		_px = _fit_px()
		_px_target = _px
		_clamp_center()
	if hi_active():
		set_process(true)   # the view changed: request the streamed tiles now in view (an instant zoom has no motion)
	var w: float = near_weight()
	for b in _layer.get_children():
		var mb: MapBubble = b
		var area: bool = mb.kind != "player" and mb.kind != "abode"
		var at: Vector2 = tile_to_local(mb.tile) + mb.cluster_offset - mb.size * 0.5
		mb.position = at
		var r := Rect2(global_position + at, mb.size)
		# a faded-in bubble is drawn, clickable and counted only once its weight reaches 0.5 (hud.md Map zoom)
		var shown: bool = (not area or w >= 0.5) and Rect2(Vector2.ZERO, size).encloses(Rect2(at, mb.size))
		for z in _blocked:
			if (z as Rect2).intersects(r):
				shown = false
		mb.visible = shown
		mb.modulate.a = 1.0 if not area else clampf(w, 0.0, 1.0)
	queue_redraw()


func _draw() -> void:
	var w: float = near_weight()
	var sc: float = tile_scale()
	var map_rect := Rect2(_origin(), Vector2(_grid_size) * sc)
	var terrain: bool = _terrain != null and _terrain.is_ready()
	if terrain:   # the terrain shader draws behind this node; the paper map fades out over it
		_terrain.set_view(_origin(), sc, Vector2(_grid_size))
		if _terrain.is_painted():
			# the painted land at every zoom (user 2026-11-23: "use what we have for the zoomed in, then use it for the
			# zoomed out"): the overview cut from the streamed tiles, then the tiles in view, all under the game's water
			var layers: Array = []
			if _near != null:
				layers.append([_near, map_rect, null])
			layers.append_array(_hi_layers())
			_terrain.set_layers(layers)
		if not _terrain.is_painted():
			draw_rect(Rect2(Vector2.ZERO, size), Color(_backdrop_far, 1.0 - w))
	else:
		draw_rect(Rect2(Vector2.ZERO, size), _backdrop_far.lerp(_backdrop_near, w))
	var far: Texture2D = _far if _far != null else (_near if _near != null else _texture)
	var near: Texture2D = _near if _near != null else far
	var painted: bool = terrain and _terrain.is_painted()   # painted land: the same map at every zoom, no separate paper
	if w < 1.0 and far != null and not painted:   # every layer is registered to the grid: it covers the whole continent
		draw_texture_rect(far, map_rect, false, Color(1, 1, 1, 1.0 - w) if terrain else Color.WHITE)
	if w > 0.0 and near != null and not terrain:   # the relief cross-fades in over the paper map
		draw_texture_rect(near, map_rect, false, Color(1, 1, 1, w))
	var pol: float = 1.0 - w   # the sect names (and the paper map) fade out as the map closes in
	# the political tint and the sect borders stay when zoomed in, lighter (user 2026-11-23: "keep the political overlay
	# when zoomed in, especially showing provinces"): political_near / border_bold_near of their full strength
	var pol_tint: float = lerpf(1.0, float(_zcfg.get("political_near", 0.45)), w)
	if pol_tint > 0.0 and _tint != null:
		draw_texture_rect(_tint, map_rect, false, Color(1, 1, 1, float(_zcfg.get("political_alpha", 0.35)) * pol_tint))
	_draw_borders(lerpf(1.0, float(_zcfg.get("border_bold_near", 0.8)), w))
	if w > 0.0 and not _hi.is_empty() and not terrain:
		_draw_hi(w)
	if w > 0.0 and _near != null and _place_art_on_map:
		var by_rank: Array = _places.duplicate()   # small places first, so seats and cities sit on top where patches meet
		by_rank.sort_custom(func(a, b): return _label_rank(a) > _label_rank(b))
		for p in by_rank:   # each known place's own art, painted into its patch of the near layer
			var rec: Dictionary = p.get("rec", {})   # the art is keyed by the authored continent id, not the session id
			var spr: Dictionary = _sprites.get(str(int(rec.get("continent_id", -1))), {})
			if spr.is_empty():
				continue
			var tex: Texture2D = _sprite_texture(spr)
			if tex != null:
				var side: float = float(spr.size_tiles) * sc
				draw_texture_rect(tex, Rect2(tile_to_local(p.tile) - Vector2(side, side) * 0.5, Vector2(side, side)), false, Color(1, 1, 1, w))
	if pol > 0.0 and _region_font != null:
		_draw_names(pol)
	var dot: float = _place_radius * lerpf(1.0, 1.6, w)
	var font: Font = get_theme_default_font()
	var taken: Array = []   # label boxes already drawn: a name that would overlap one is skipped (hover always shows)
	var order: Array = _places.duplicate()
	order.sort_custom(func(a, b): return _label_rank(a) < _label_rank(b))
	for p in order:
		var at: Vector2 = _marker_at(p)
		var hover: bool = p.id == _hover_id
		var side: float = symbol_side(str(p.get("kind", "")))
		var label_at: Vector2 = at
		if side > 0.0 and w > 0.0:
			# a built place on the relief: its symbol stands on the tile (the tile point is its base), fading in with w
			var tex: Texture2D = _symbols[str(p.kind)]
			var c := Color(1, 1, 1, w) if not hover else Color(1.15, 1.05, 0.8, w)
			draw_texture_rect(tex, Rect2(at - Vector2(side * 0.5, side * 0.92), Vector2(side, side)), false, c)
			if p.id == _destination_id:
				draw_arc(at - Vector2(0, side * 0.4), side * 0.55, 0.0, TAU, 32, Color(1, 0.85, 0.2, w), 2.0)
			label_at = at + Vector2(side * 0.3, -side * 0.35)
		if side <= 0.0 or w < 0.5:
			# a diamond marks a fixed named place (art bible Section 3): cinnabar on the paper map, bone on the relief
			var fill := Color(0.52, 0.1, 0.11).lerp(Color(0.91, 0.85, 0.71), w)
			if hover:
				fill = Color(1, 0.86, 0.4)
			var da: float = 1.0 if side <= 0.0 else 1.0 - w * 2.0
			_diamond(at, dot + 1.5, Color(0.1, 0.07, 0.05, da))
			_diamond(at, dot, Color(fill, da))
			if p.id == _destination_id and side <= 0.0:
				draw_arc(at, dot + 6.0, 0.0, TAU, 24, Color(1, 0.85, 0.2), 2.0)
		if w >= 0.5:   # the name on a dark, see-through backing (7.14), fading in with the relief
			var name: String = str(p.name)
			var fs: int = 13
			var sz: Vector2 = font.get_string_size(name, HORIZONTAL_ALIGNMENT_LEFT, -1, fs)
			var box := Rect2(label_at + Vector2(8, -sz.y * 0.5 - 1), sz + Vector2(8, 3))
			if not hover and taken.any(func(r): return (r as Rect2).intersects(box)):
				continue
			taken.append(box)
			draw_rect(box, Color(0.08, 0.05, 0.03, 0.62 * w))
			draw_string(font, box.position + Vector2(4, font.get_ascent(fs) + 1), name, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(0.96, 0.92, 0.82, w))


## Border lines, one width and one ink, told apart by pattern (user 2026-11-23: "double border for country borders,
## dash for regions, dash + dot for provinces, one thickness"): a double line where the holder changes (part of the
## political overlay, so it fades with [param pol]), a dashed line between a great sect's own regions and a dash-dot
## line between provinces of one region (both with the Borders toggle; provinces fade in as the map closes in).
func _draw_borders(pol: float) -> void:
	var sc: float = tile_scale()
	var o: Vector2 = _origin()
	var view := Rect2(Vector2(-8, -8), size + Vector2(16, 16))
	var width: float = float(_zcfg.get("border_px", 1.4))
	var ink := Color(0.15, 0.1, 0.07, float(_zcfg.get("border_alpha", 0.8)))
	var to_screen := func(pts: PackedVector2Array) -> PackedVector2Array:
		var tr2 := PackedVector2Array()
		tr2.resize(pts.size())
		var any_in: bool = false
		for i in pts.size():
			tr2[i] = o + pts[i] * sc
			if not any_in and view.has_point(tr2[i]):
				any_in = true
		return tr2 if any_in else PackedVector2Array()
	# provinces: invisible at the fit, fading in up to the band (Paradox shows provinces as you close in)
	# keyed to the fit, so they are hidden zoomed out on any screen (hud.md: province_from_fit, province_full_fit)
	var fit: float = _fit_px()
	var pa: float = smoothstep(fit * float(_zcfg.get("province_from_fit", 1.15)), fit * float(_zcfg.get("province_full_fit", 1.7)), tile_scale())
	if pa > 0.0 and _borders_on:
		var segs := PackedVector2Array()
		for ln in _lines_prov:
			_pattern_segments(to_screen.call(ln), _zcfg.get("border_dash_dot", [9.0, 4.0, 1.6, 4.0]), segs)
		if not segs.is_empty():
			draw_multiline(segs, Color(ink, ink.a * pa), width, true)
	if _borders_on:
		var segs := PackedVector2Array()
		for ln in _lines_thin:
			_pattern_segments(to_screen.call(ln), _zcfg.get("border_dash", [9.0, 5.0]), segs)
		if not segs.is_empty():
			draw_multiline(segs, ink, width, true)
	if pol > 0.0:
		var gap: float = float(_zcfg.get("border_double_gap", 3.0)) * 0.5
		for ln in _lines_bold:
			var s: PackedVector2Array = to_screen.call(ln)
			if s.size() < 2:
				continue
			draw_polyline(_offset_line(s, gap), Color(ink, ink.a * pol), width, true)
			draw_polyline(_offset_line(s, -gap), Color(ink, ink.a * pol), width, true)


## The dash pattern [param pattern] (on, off, on, off ... lengths in screen px) along the screen polyline [param pts],
## appended to [param out] as segment pairs for draw_multiline.
static func _pattern_segments(pts: PackedVector2Array, pattern: Array, out: PackedVector2Array) -> void:
	if pts.size() < 2 or pattern.is_empty():
		return
	var k: int = 0
	var left: float = float(pattern[0])
	for i in pts.size() - 1:
		var a: Vector2 = pts[i]
		var b: Vector2 = pts[i + 1]
		var seg: float = a.distance_to(b)
		var t: float = 0.0
		while seg - t > 1e-4:
			var step: float = minf(left, seg - t)
			if k % 2 == 0:
				out.append(a.lerp(b, t / seg))
				out.append(a.lerp(b, (t + step) / seg))
			t += step
			left -= step
			if left <= 1e-4:
				k = (k + 1) % pattern.size()
				left = float(pattern[k])


## [param pts] moved [param d] px to its left (a negative d to its right), each point along the average of its two
## segments' normals, for the double country border.
static func _offset_line(pts: PackedVector2Array, d: float) -> PackedVector2Array:
	var out := PackedVector2Array()
	out.resize(pts.size())
	for i in pts.size():
		var t := Vector2.ZERO
		if i > 0:
			t += (pts[i] - pts[i - 1]).normalized()
		if i < pts.size() - 1:
			t += (pts[i + 1] - pts[i]).normalized()
		var n := Vector2(-t.y, t.x).normalized() if t.length() > 1e-5 else Vector2.ZERO
		out[i] = pts[i] + n * d
	return out


## The great sects' names large across their territory, region names smaller beneath (art bible 7.14), ink with a
## paper halo; a sect's name that would not fit inside its territory is not drawn (the legend and hover carry it).
func _draw_names(alpha: float) -> void:
	var sc: float = tile_scale()
	var halo := Color(0.89, 0.83, 0.68, 0.75 * alpha)
	var ink := Color(0.24, 0.16, 0.1, 0.85 * alpha)
	var taken: Array = []   # name boxes drawn: a region name that would overlap one is skipped
	var rp: Array = _zcfg.get("realm_name_px", [18, 40])
	for realm in _realms:
		var label: String = " ".join(Array(str(realm.name).to_upper().split("")))
		var room: float = float(realm.width_tiles) * sc * 0.8
		var w20: float = _region_font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 20).x
		var fs: float = minf(20.0 * room / maxf(1.0, w20), float(rp[1]))
		if fs < float(rp[0]):
			continue
		var tw: float = _region_font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, int(fs)).x
		var at: Vector2 = _origin() + Vector2(realm.centre) * sc - Vector2(tw * 0.5, -fs * 0.35)
		taken.append(Rect2(at + Vector2(0, -fs), Vector2(tw, fs * 1.25)).grow(4))
		draw_string_outline(_region_font, at, label, HORIZONTAL_ALIGNMENT_LEFT, -1, int(fs), 6, halo)
		draw_string(_region_font, at, label, HORIZONTAL_ALIGNMENT_LEFT, -1, int(fs), Color(ink.r, ink.g, ink.b, 0.78 * alpha))
	var rn: Array = _zcfg.get("region_name_px", [13, 20])
	for r in _regions:
		var label: String = " ".join(Array(str(r.name).to_upper().split("")))
		var fs: int = int(clampf(sc * 4.5, float(rn[0]), float(rn[1])))
		var tw: float = _region_font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
		var base: Vector2 = tile_to_local(Vector2i(r.centre)) - Vector2(tw * 0.5, -fs * 0.35)
		var drawn: bool = false
		for dy in [0.0, fs * 1.6, -fs * 1.6, fs * 3.2]:   # its centre first, then just below or above a sect's name
			var at: Vector2 = base + Vector2(0, dy)
			var box := Rect2(at + Vector2(0, -fs), Vector2(tw, fs * 1.25)).grow(2)
			if taken.any(func(t): return (t as Rect2).intersects(box)):
				continue
			taken.append(box)
			draw_string_outline(_region_font, at, label, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, 4, halo)
			draw_string(_region_font, at, label, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, ink)
			drawn = true
			break


## Where a place's diamond and name sit: on its tile, or, on the region side when the place has its own art, just below
## the art so the marker never covers the place's signature (the place art is centred on the tile).
func _marker_at(p: Dictionary) -> Vector2:
	var at: Vector2 = tile_to_local(p.tile)
	if _near == null or not _place_art_on_map:
		return at
	var spr: Dictionary = _sprites.get(str(int(p.get("rec", {}).get("continent_id", -1))), {})
	if spr.is_empty():
		return at
	return at + Vector2(0, float(spr.size_tiles) * tile_scale() * 0.3 * near_weight())


## Label priority: sect seats and cities first, then towns and markets, then everything else (lower draws first).
static func _label_rank(p: Dictionary) -> int:
	match str(p.get("kind", "")):
		"great_seat", "city": return 0
		"minor_seat", "town", "market": return 1
		"village": return 3
	return 2


func _diamond(at: Vector2, r: float, c: Color) -> void:
	draw_colored_polygon(PackedVector2Array([at + Vector2(0, -r), at + Vector2(r, 0), at + Vector2(0, r), at + Vector2(-r, 0)]), c)


## Element 13's Borders toggle: shows or hides the region and province lines (the bold holder lines stay with the tint).
func set_borders(on: bool) -> void:
	_borders_on = on
	queue_redraw()


## Province lines' drawn opacity now, 0..1 of province_alpha (for tests and the demo).
func province_line_weight() -> float:
	var fit: float = _fit_px()
	return smoothstep(fit * float(_zcfg.get("province_from_fit", 1.15)), fit * float(_zcfg.get("province_full_fit", 1.7)), tile_scale())


## Reads the provinces file at [param path] (missing: region borders are chained from the grid instead).
func _load_provinces(path: String) -> void:
	_prov_lines = []
	_prov_region = {}
	if path == "" or not FileAccess.file_exists(path):
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not (parsed is Dictionary):
		return
	for p in (parsed as Dictionary).get("provinces", []):
		_prov_region[int(p.id)] = int(p.region)
	for ln in (parsed as Dictionary).get("lines", []):
		var flat: Array = ln.points
		var pts := PackedVector2Array()
		pts.resize(flat.size() / 2)
		for i in pts.size():
			pts[i] = Vector2(float(flat[2 * i]), float(flat[2 * i + 1]))
		_prov_lines.append({"a": int(ln.a), "b": int(ln.b), "pts": pts})


## Reads the streamed near-tile manifest at [param path] (missing: the overview near layer alone).
func _load_hi(path: String) -> void:
	_hi = {}
	if path == "" or not FileAccess.file_exists(path):
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if parsed is Dictionary:
		_hi = parsed


## Whether the streamed tiles are drawn at the zoom now (from hi_from_px, map_zoom, up; and only with a near layer).
func hi_active() -> bool:
	return not _hi.is_empty() and (not terrain_active() or _terrain.is_painted()) and near_weight() > 0.0 and tile_scale() >= float(_zcfg.get("hi_from_px", 14.0))


## The streamed tiles that cover [param view] (a rect in game tiles), tiles of [param chunk] game tiles in a
## [param cols] x [param rows] grid, widened by [param margin] tiles, as [Vector2i(cx, cy)].
static func chunks_in_view(view: Rect2, chunk: int, cols: int, rows: int, margin: float = 0.0) -> Array:
	var out: Array = []
	if chunk <= 0:
		return out
	var r := view.grow(margin)
	var cx0: int = clampi(int(floor(r.position.x / chunk)), 0, cols - 1)
	var cy0: int = clampi(int(floor(r.position.y / chunk)), 0, rows - 1)
	var cx1: int = clampi(int(floor(r.end.x / chunk)), 0, cols - 1)
	var cy1: int = clampi(int(floor(r.end.y / chunk)), 0, rows - 1)
	if r.end.x < 0.0 or r.end.y < 0.0 or r.position.x >= float(cols * chunk) or r.position.y >= float(rows * chunk):
		return out
	for cy in range(cy0, cy1 + 1):
		for cx in range(cx0, cx1 + 1):
			out.append(Vector2i(cx, cy))
	return out


func _view_tiles() -> Rect2:
	var a: Vector2 = local_to_tile(Vector2.ZERO)
	return Rect2(a, local_to_tile(size) - a)


## Requests the tiles in view (one ring around them ahead of a pan) on a background thread, collects the loaded ones,
## and drops the least recently drawn above hi_cache (map_zoom). Never blocks the frame.
func _stream_hi() -> void:
	if _hi.is_empty():
		return
	for key in _hi_pending.keys():
		var path: String = _hi_pending[key]
		var st: int = ResourceLoader.load_threaded_get_status(path)
		if st == ResourceLoader.THREAD_LOAD_LOADED:
			_hi_tex[key] = {"tex": ResourceLoader.load_threaded_get(path), "used": Time.get_ticks_msec()}
			_hi_pending.erase(key)
			queue_redraw()
		elif st == ResourceLoader.THREAD_LOAD_FAILED or st == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			_hi_pending.erase(key)
			_hi_tex[key] = {"tex": null, "used": Time.get_ticks_msec()}
	if not hi_active():
		return
	var chunk: int = int(_hi.get("chunk_tiles", 40))
	for c in chunks_in_view(_view_tiles(), chunk, int(_hi.get("cols", 0)), int(_hi.get("rows", 0)), float(chunk)):
		var key: String = "%d_%d" % [c.x, c.y]
		if _hi_tex.has(key) or _hi_pending.has(key):
			continue
		var path: String = "%s/near_%d_%d.jpg" % [str(_hi.get("dir", "")), c.x, c.y]
		if ResourceLoader.exists(path) and ResourceLoader.load_threaded_request(path) == OK:
			_hi_pending[key] = path
	var cap: int = int(_zcfg.get("hi_cache", 30))
	if _hi_tex.size() > cap:
		var keys: Array = _hi_tex.keys()
		keys.sort_custom(func(a, b): return int(_hi_tex[a].used) < int(_hi_tex[b].used))
		for i in keys.size() - cap:
			_hi_tex.erase(keys[i])


## The loaded streamed tiles in view as [texture, dst, src] for the terrain view (painted-land mode).
func _hi_layers() -> Array:
	var out: Array = []
	if not hi_active():
		return out
	var chunk: int = int(_hi.get("chunk_tiles", 40))
	var px: float = float(_hi.get("px_per_tile", 48))
	var pad: float = float(_hi.get("pad", 0))
	var sc: float = tile_scale()
	var now: int = Time.get_ticks_msec()
	for c in chunks_in_view(_view_tiles(), chunk, int(_hi.get("cols", 0)), int(_hi.get("rows", 0))):
		var e: Variant = _hi_tex.get("%d_%d" % [c.x, c.y])
		if e == null or e.tex == null:
			continue
		e.used = now
		var t0 := Vector2(c.x * chunk, c.y * chunk)
		var tw := Vector2(minf(chunk, _grid_size.x - t0.x), minf(chunk, _grid_size.y - t0.y))
		out.append([e.tex, Rect2(_origin() + t0 * sc, tw * sc), Rect2(Vector2(pad, pad), tw * px)])
	return out


## Draws the loaded streamed tiles in view over the overview layer at [param w] opacity (only their inner region, so
## the padding that hides filter seams never shows).
func _draw_hi(w: float) -> void:
	if not hi_active():
		return
	var chunk: int = int(_hi.get("chunk_tiles", 40))
	var px: float = float(_hi.get("px_per_tile", 48))
	var pad: float = float(_hi.get("pad", 0))
	var sc: float = tile_scale()
	var now: int = Time.get_ticks_msec()
	for c in chunks_in_view(_view_tiles(), chunk, int(_hi.get("cols", 0)), int(_hi.get("rows", 0))):
		var e: Variant = _hi_tex.get("%d_%d" % [c.x, c.y])
		if e == null or e.tex == null:
			continue
		e.used = now
		var t0 := Vector2(c.x * chunk, c.y * chunk)
		var tw := Vector2(minf(chunk, _grid_size.x - t0.x), minf(chunk, _grid_size.y - t0.y))
		var dst := Rect2(_origin() + t0 * sc, tw * sc)
		draw_texture_rect_region(e.tex, dst, Rect2(Vector2(pad, pad), tw * px), Color(1, 1, 1, w))


## Streamed tiles loaded and requested now (for tests and the demo).
func hi_probe() -> Dictionary:
	return {"loaded": _hi_tex.size(), "pending": _hi_pending.size(), "active": hi_active()}


## Builds the terrain shader view from [param cfg] (ui_hud.json greybox.terrain_shader: enabled, dir, and any shader
## uniform by name); missing data leaves the painted layers in charge.
func _load_terrain(cfg: Variant) -> void:
	if _terrain != null:
		_terrain.queue_free()
		_terrain = null
	if not (cfg is Dictionary) or not bool(cfg.get("enabled", false)):
		return
	var tv := TerrainView.new()
	if not tv.load_data(str(cfg.get("dir", "")), cfg):
		tv.free()
		return
	tv.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(tv)
	move_child(tv, 0)
	_terrain = tv


## Whether the data-driven terrain is drawing (for tests and the demo).
func terrain_active() -> bool:
	return _terrain != null and _terrain.is_ready()


## Reads the place symbols from [param cfg] (ui_hud.json greybox.place_symbols: dir, px per kind, grow); a kind
## whose file is missing has no symbol and keeps its diamond.
func _load_symbols(cfg: Variant) -> void:
	_symbols = {}
	_symbol_px = {}
	if not (cfg is Dictionary):
		return
	var dir: String = str(cfg.get("dir", ""))
	_symbol_grow = float(cfg.get("grow", 1.3))
	var px: Dictionary = cfg.get("px", {})
	for kind in px:
		var path: String = "%s/%s.png" % [dir, kind]
		if dir != "" and ResourceLoader.exists(path):
			_symbols[str(kind)] = load(path)
			_symbol_px[str(kind)] = float(px[kind])


## The screen size (px) of the symbol of place [param kind] at the zoom now, or 0 when the kind has none (natural
## landmarks, or no file): px from the config at the relief's start, growing to px x grow at the deepest zoom.
func symbol_side(kind: String) -> float:
	if not _symbols.has(kind):
		return 0.0
	var t: float = smoothstep(float(_zcfg.get("near_to_px", 9.6)), _max_px(), tile_scale())
	return float(_symbol_px[kind]) * lerpf(1.0, _symbol_grow, t)


## Reads the place-art manifest at [param path] (missing: no place art, the markers still show).
func _load_sprites(path: String) -> void:
	_sprites = {}
	if path == "" or not FileAccess.file_exists(path):
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not (parsed is Dictionary):
		return
	_sprite_dir = path.get_base_dir()
	for k in (parsed as Dictionary).get("places", {}):
		_sprites[str(k)] = (parsed as Dictionary).places[k].duplicate()


func _sprite_texture(spr: Dictionary) -> Texture2D:
	if not spr.has("texture"):
		var path: String = _sprite_dir + "/" + str(spr.get("file", ""))
		spr["texture"] = load(path) if ResourceLoader.exists(path) else null
	return spr.texture


## A painted map layer at [param path], or null when the path is empty or the file is missing (the map then draws the
## biome colours).
static func _layer_texture(path: String) -> Texture2D:
	if path == "" or not ResourceLoader.exists(path):
		return null
	return load(path) as Texture2D


## Sets the regions ([param regions] from GameQuery.regions: names, centres, grid ids and holders) drawn in
## [param font]. The political map is rebaked only when a holder (or the palette) changed, so this can be called on
## every refresh.
func set_regions(regions: Array, font: Font) -> void:
	_regions = regions.map(func(r): return {"name": str(r.name), "centre": Vector2(float(r.centre[0]), float(r.centre[1])) + Vector2(0.5, 0.5)})
	_region_font = font
	var sig: String = ("cb|" if _colourblind else "") + "|".join(regions.map(func(r): return "%s=%s" % [r.get("grid_id", 0), r.get("holder_key", "")]))
	if sig != _politics_sig and _grid_size != Vector2i.ZERO:
		_politics_sig = sig
		_bake_politics(regions)
	queue_redraw()


func _bake_politics(regions: Array) -> void:
	var W: int = _grid_size.x
	var H: int = _grid_size.y
	var palette: Dictionary = _zcfg.get("sect_colours_cb" if _colourblind else "sect_colours", {})
	var holder: Dictionary = {}   # grid id -> holder key
	var col: Dictionary = {}      # grid id -> Color
	_region_info = {}
	for r in regions:
		var gid: int = int(r.get("grid_id", 0))
		var key: String = str(r.get("holder_key", ""))
		holder[gid] = key
		_region_info[gid] = {"name": str(r.name), "holder_name": str(r.get("holder_name", ""))}
		if key != "" and palette.has(key):
			col[gid] = Color.from_string(str(palette[key]), Color(0, 0, 0, 0))
	var data := PackedByteArray()
	data.resize(W * H * 4)
	var stats: Dictionary = {}    # holder key -> {n, sx, sy, minx, maxx, name}
	for y in H:
		for x in W:
			var gid: int = _regn[y * W + x]
			var i: int = (y * W + x) * 4
			if col.has(gid):
				var c: Color = col[gid]
				data[i] = c.r8
				data[i + 1] = c.g8
				data[i + 2] = c.b8
				data[i + 3] = 255
			var key: String = str(holder.get(gid, ""))
			if gid > 0 and key != "":
				if not stats.has(key):
					stats[key] = {"n": 0, "sx": 0.0, "sy": 0.0, "minx": x, "maxx": x, "name": ""}
				var st: Dictionary = stats[key]
				st.n += 1
				st.sx += x
				st.sy += y
				st.minx = mini(st.minx, x)
				st.maxx = maxi(st.maxx, x)
	_tint = ImageTexture.create_from_image(Image.create_from_data(W, H, false, Image.FORMAT_RGBA8, data))
	# borders between two land regions: bold where the holder changes, thin between a sect's own regions; the tile-edge
	# steps are chained into lines and rounded (hud.md Map zoom: no staircase at region zoom)
	var ea := PackedVector2Array()   # unit edges: ends a, b and whether bold
	var eb := PackedVector2Array()
	var ebold := PackedByteArray()
	for y in H:
		for x in W:
			var a: int = _regn[y * W + x]
			if a <= 0:
				continue
			if x + 1 < W:
				var b: int = _regn[y * W + x + 1]
				if b > 0 and b != a:
					ea.append(Vector2(x + 1, y))
					eb.append(Vector2(x + 1, y + 1))
					ebold.append(1 if str(holder.get(a, "")) != str(holder.get(b, "")) else 0)
			if y + 1 < H:
				var b2: int = _regn[(y + 1) * W + x]
				if b2 > 0 and b2 != a:
					ea.append(Vector2(x, y + 1))
					eb.append(Vector2(x + 1, y + 1))
					ebold.append(1 if str(holder.get(a, "")) != str(holder.get(b2, "")) else 0)
	_lines_bold = []
	_lines_thin = []
	_lines_prov = []
	if not _prov_lines.is_empty():   # the provinces' shared lines: a province, region or holder border by its two sides
		for ln in _prov_lines:
			var ra: int = int(_prov_region.get(int(ln.a), 0))
			var rb: int = int(_prov_region.get(int(ln.b), 0))
			if ra == rb:
				_lines_prov.append(ln.pts)
			elif str(holder.get(ra, "")) != str(holder.get(rb, "")):
				_lines_bold.append(ln.pts)
			else:
				_lines_thin.append(ln.pts)
		ea = PackedVector2Array()
	var lines: Array = _chain_edges(ea, eb, ebold) if not ea.is_empty() else []
	for ln in lines:
		var pts: PackedVector2Array = _chaikin(_chaikin(_midpoints(ln.points)))
		if ln.bold:
			_lines_bold.append(pts)
		else:
			_lines_thin.append(pts)
	_realms = []
	var names: Dictionary = {}
	for r in regions:
		if str(r.get("holder_key", "")) != "":
			names[str(r.holder_key)] = str(r.get("holder_name", ""))
	for key in stats:
		var st: Dictionary = stats[key]
		_realms.append({"name": str(names.get(key, key)), "centre": Vector2(st.sx / st.n, st.sy / st.n) + Vector2(0.5, 0.5),
			"width_tiles": float(st.maxx - st.minx + 1)})


## Chains unit edges ([param ea], [param eb], [param bold] per edge) into lines that break where three regions meet,
## where the border kind changes, or at a loop's start: [{points: PackedVector2Array, bold}].
static func _chain_edges(ea: PackedVector2Array, eb: PackedVector2Array, bold: PackedByteArray) -> Array:
	var at: Dictionary = {}   # point -> edge indices
	for i in ea.size():
		for q in [ea[i], eb[i]]:
			if not at.has(q):
				at[q] = []
			at[q].append(i)
	var used := PackedByteArray()
	used.resize(ea.size())
	var out: Array = []
	var walk := func(start: Vector2, first: int) -> PackedVector2Array:
		var pts := PackedVector2Array([start])
		var e: int = first
		var cur: Vector2 = start
		while e >= 0:
			used[e] = 1
			cur = eb[e] if ea[e] == cur else ea[e]
			pts.append(cur)
			var nxt: int = -1
			var here: Array = at[cur]
			if here.size() == 2:   # continue only through a plain bend of the same kind
				for k in here:
					if used[k] == 0 and bold[k] == bold[e]:
						nxt = k
			e = nxt
		return pts
	# open lines first, from points that are not plain bends (junctions, ends, kind changes)
	for q in at:
		var here: Array = at[q]
		var plain: bool = here.size() == 2 and bold[here[0]] == bold[here[1]]
		if plain:
			continue
		for k in here:
			if used[k] == 0:
				out.append({"points": walk.call(q, k), "bold": bold[k] == 1})
	for k in ea.size():   # closed loops
		if used[k] == 0:
			out.append({"points": walk.call(ea[k], k), "bold": bold[k] == 1})
	return out


## The midpoints of a line's steps, its ends kept: a tile staircase becomes a straight diagonal.
static func _midpoints(pts: PackedVector2Array) -> PackedVector2Array:
	if pts.size() < 3:
		return pts
	var out := PackedVector2Array([pts[0]])
	for i in pts.size() - 1:
		out.append((pts[i] + pts[i + 1]) * 0.5)
	out.append(pts[pts.size() - 1])
	return out


## One pass of Chaikin corner cutting: each corner becomes two points a quarter in, the ends stay put.
static func _chaikin(pts: PackedVector2Array) -> PackedVector2Array:
	if pts.size() < 3:
		return pts
	var out := PackedVector2Array([pts[0]])
	for i in pts.size() - 1:
		var a: Vector2 = pts[i]
		var b: Vector2 = pts[i + 1]
		if i > 0:
			out.append(a.lerp(b, 0.25))
		if i < pts.size() - 2:
			out.append(a.lerp(b, 0.75))
	out.append(pts[pts.size() - 1])
	return out


## The political map's tint colour of grid region [param grid_id] in the current palette (transparent when none), and
## the number of bold and thin border segments (for tests and the demo).
func politics_probe(grid_id: int) -> Dictionary:
	var c := Color(0, 0, 0, 0)
	if _tint != null:
		var img: Image = _tint.get_image()
		for i in _regn.size():
			if _regn[i] == grid_id:
				c = img.get_pixel(i % _grid_size.x, i / _grid_size.x)
				break
	return {"colour": c, "bold": _lines_bold.size(), "thin": _lines_thin.size(), "provinces": _lines_prov.size(), "realms": _realms.size()}


## The place art of the authored place [param continent_id] (its patch of the near map), or null.
func place_art(continent_id: int) -> Texture2D:
	var spr: Dictionary = _sprites.get(str(continent_id), {})
	return _sprite_texture(spr) if not spr.is_empty() else null


## Which layer leads now: "near" on the region side of the band, else "far" ("biome" with no painted layers).
func drawn_layer() -> String:
	if _far == null and _near == null:
		return "biome"
	if is_region_zoom():
		return "near" if _near != null else "far"
	return "far" if _far != null else "near"


func _place_at(pos: Vector2) -> Dictionary:
	var best: Dictionary = {}
	var best_d: float = maxf(_place_radius * 2.5, 8.0)
	for p in _places:
		var d: float = minf(tile_to_local(p.tile).distance_to(pos), _marker_at(p).distance_to(pos))
		var side: float = symbol_side(str(p.get("kind", ""))) if near_weight() >= 0.5 else 0.0
		if side > 0.0:   # anywhere on a symbol counts as on the place
			var r := Rect2(_marker_at(p) - Vector2(side * 0.45, side * 0.9), Vector2(side * 0.9, side * 0.9))
			if r.has_point(pos):
				d = 0.0
		if d < best_d:
			best_d = d
			best = p
	return best


## The grid region under local [param pos] (0 for sea or off the map).
func _region_under(pos: Vector2) -> int:
	var t: Vector2 = local_to_tile(pos)
	var x: int = int(floor(t.x))
	var y: int = int(floor(t.y))
	if x < 0 or y < 0 or x >= _grid_size.x or y >= _grid_size.y:
		return 0
	return _regn[y * _grid_size.x + x]


func _gui_input(event: InputEvent) -> void:
	var step: float = float(_zcfg.get("zoom_step", 1.25))
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_WHEEL_UP and mb.pressed:
			zoom_by(step, mb.position)
			accept_event()
		elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN and mb.pressed:
			zoom_by(1.0 / step, mb.position)
			accept_event()
		elif mb.button_index == MOUSE_BUTTON_LEFT or mb.button_index == MOUSE_BUTTON_MIDDLE:
			if mb.pressed:
				_pressed = true
				_dragging = false
				_press_pos = mb.position
				_drag_from = mb.position
				_pan_vel = Vector2.ZERO
				_glide_t = -1.0
				_drag_samples = []
			else:
				if _dragging and not _reduced_motion and _drag_samples.size() >= 2:   # fling: keep the drag's speed
					var a0: Array = _drag_samples[0]
					var a1: Array = _drag_samples[-1]
					var dt: float = maxf(0.016, float(int(a1[0]) - int(a0[0])) / 1000.0)
					if Time.get_ticks_msec() - int(a1[0]) < 80:
						_pan_vel = -((a1[1] as Vector2) - (a0[1] as Vector2)) / dt
						_pan_vel = _pan_vel.limit_length(float(_zcfg.get("fling_max", 2400.0)))
						set_process(true)
				if _pressed and not _dragging and mb.button_index == MOUSE_BUTTON_LEFT:
					var p: Dictionary = _place_at(mb.position)
					if not p.is_empty():
						place_clicked.emit(str(p.id))
				_pressed = false
				_dragging = false
			accept_event()
	elif event is InputEventMouseMotion:
		var mm := event as InputEventMouseMotion
		if _pressed and (_dragging or mm.position.distance_to(_press_pos) > DRAG_THRESHOLD):
			_dragging = true
			_center -= (mm.position - _drag_from) / tile_scale()
			_drag_from = mm.position
			_drag_samples.append([Time.get_ticks_msec(), mm.position])
			while _drag_samples.size() > 2 and Time.get_ticks_msec() - int(_drag_samples[0][0]) > 100:
				_drag_samples.pop_front()
			_clamp_center()
			_relayout()
		var p: Dictionary = _place_at(mm.position)
		var id: String = str(p.get("id", ""))
		var reg: int = 0 if id != "" or near_weight() >= 0.5 else _region_under(mm.position)
		if id != _hover_id or reg != _hover_region:
			_hover_id = id
			_hover_region = reg
			if id != "":
				TooltipLayer.set_tip(self, str(p.get("name", "")))
			elif reg > 0 and _region_info.has(reg):   # hover a region while the tint is on: its name and holder
				var info: Dictionary = _region_info[reg]
				var held: String = str(info.holder_name)
				TooltipLayer.set_tip(self, str(info.name) + ((" · " + tr("held by %s") % held) if held != "" else ""))
			else:
				TooltipLayer.set_tip(self, "")
			queue_redraw()
	elif event is InputEventKey and event.pressed:
		var k := event as InputEventKey
		var pan := Vector2.ZERO
		match k.physical_keycode:
			KEY_LEFT: pan = Vector2(-1, 0)
			KEY_RIGHT: pan = Vector2(1, 0)
			KEY_UP: pan = Vector2(0, -1)
			KEY_DOWN: pan = Vector2(0, 1)
			KEY_EQUAL, KEY_KP_ADD:
				zoom_by(step)
				accept_event()
			KEY_MINUS, KEY_KP_SUBTRACT:
				zoom_by(1.0 / step)
				accept_event()
			KEY_0, KEY_KP_0:
				zoom_fit()
				accept_event()
		if pan != Vector2.ZERO:   # held arrow keys pan with acceleration in _process; reduced motion steps at once
			if _reduced_motion:
				_center += pan * PAN_STEP / tile_scale()
				_clamp_center()
				_relayout()
			else:
				set_process(true)
			accept_event()
	elif event is InputEventJoypadMotion:   # the triggers zoom in and out (hud.md Gamepad)
		var jm := event as InputEventJoypadMotion
		if jm.axis_value > 0.6 and jm.axis == JOY_AXIS_TRIGGER_RIGHT:
			zoom_by(step)
			accept_event()
		elif jm.axis_value > 0.6 and jm.axis == JOY_AXIS_TRIGGER_LEFT:
			zoom_by(1.0 / step)
			accept_event()
	elif event is InputEventJoypadButton and event.pressed and (event as InputEventJoypadButton).button_index == JOY_BUTTON_RIGHT_STICK:
		zoom_fit()
		accept_event()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_px = 0.0   # re-fit on a resize (the fit changes); the next layout clamps
		_relayout()
