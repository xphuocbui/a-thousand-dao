class_name MapView
extends Control
## The continent map of the greybox map screen (design/ux/hud.md, Information Architecture Group 3 and Map bubbles):
## the authored grid drawn one flat colour per main biome, a dot for each place the player knows, the player's bubble
## (element 30), the abode bubble (31) and, at region zoom, the area bubbles (32). Continent zoom fits the whole
## continent; region zoom magnifies around a point. Drag with the left or middle button, or the arrow keys while the
## map has focus, to pan; the wheel or [method set_region_zoom] switches zoom. Display only: it never changes game
## state; clicks are reported through signals.

## The player clicked the known place [param place_id] (not a bubble).
signal place_clicked(place_id: String)
## The player pressed a bubble of [param kind] at [param place_id] ("player", "abode" or an area kind).
signal bubble_pressed(kind: String, place_id: String)
## The zoom changed ([param region] true for region zoom).
signal zoom_changed(region: bool)

const DRAG_THRESHOLD := 5.0
const PAN_STEP := 40.0

var _texture: ImageTexture = null
## The painted layers (art bible Section 1, Principle 2: one map, two distances): the far layer (paper campaign map)
## at continent zoom, the near layer (painted relief) at region zoom; null falls back to the biome colours.
var _far: Texture2D = null
var _near: Texture2D = null
## Place art on the near layer (assets/map/places/manifest.json): place id -> {texture (loaded on first draw), tile,
## size_tiles}. Drawn at region zoom for known places only, so the art never reveals a place the player has not found.
var _sprites: Dictionary = {}
var _sprite_dir: String = ""
## Region names at continent zoom: [{name, centre: Vector2 (tile)}] (art bible 7.14: engine-drawn, never painted).
var _regions: Array = []
var _region_font: Font = null
## The colour around the map image (the paper at continent zoom, the open sea at region zoom).
var _backdrop_far := Color(0.08, 0.1, 0.14)
var _backdrop_near := Color(0.08, 0.1, 0.14)
var _grid_size := Vector2i.ZERO
## Known places: [{id, name, tile: Vector2i, kind}].
var _places: Array = []
var _player_tile := Vector2i(-1, -1)
var _player_place: String = ""
var _destination_id: String = ""
var _place_radius: float = 3.0
var _hover_id: String = ""
var _region: bool = false
var _region_factor: float = 4.0
var _center := Vector2.ZERO   # the tile point at the middle of the view in region zoom
var _drag_from := Vector2.ZERO
var _dragging: bool = false
var _press_pos := Vector2.ZERO
var _pressed: bool = false
var _layer := Control.new()
var _blocked: Array = []   # global Rect2s where bubbles are not drawn or clickable (the HUD zones)


func _init() -> void:
	clip_contents = true
	focus_mode = Control.FOCUS_ALL
	_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_layer)


## Builds the map image from [param grid] with [param cfg] (ui_hud.json "greybox") and [param region_factor].
func setup(grid: ContinentGrid, cfg: Dictionary, region_factor: float) -> void:
	_place_radius = float(cfg.get("place_radius_px", 3.0))
	_region_factor = region_factor
	_grid_size = Vector2i(grid.width, grid.height)
	_center = Vector2(_grid_size) * 0.5
	var colours: Dictionary = cfg.get("biome_colours", {})
	var unknown := Color(str(cfg.get("unknown_colour", "#808080")))
	var by_id: Dictionary = {}
	var img := Image.create(grid.width, grid.height, false, Image.FORMAT_RGB8)
	for y in grid.height:
		for x in grid.width:
			var b: int = grid.main_biome(x, y)
			if not by_id.has(b):
				var name: String = grid.biome_name(b)
				by_id[b] = Color(str(colours[name])) if colours.has(name) else unknown
			img.set_pixel(x, y, by_id[b])
	_texture = ImageTexture.create_from_image(img)
	_far = _layer_texture(str(cfg.get("far_layer", "")))
	_near = _layer_texture(str(cfg.get("near_layer", "")))
	_load_sprites(str(cfg.get("place_sprites", "")))
	_backdrop_far = Color.from_string(str(cfg.get("backdrop_far", "#141A24")), Color(0.08, 0.1, 0.14))
	_backdrop_near = Color.from_string(str(cfg.get("backdrop_near", "#141A24")), Color(0.08, 0.1, 0.14))
	mouse_filter = Control.MOUSE_FILTER_STOP
	_relayout()


## Sets the known places, the player's tile and place, and the destination.
func set_state(places: Array, player_tile: Vector2i, player_place: String, destination_id: String) -> void:
	_places = places
	_player_tile = player_tile
	_player_place = player_place
	_destination_id = destination_id
	_relayout()


## Replaces the bubbles with [param bubbles]: [{kind, place_id, count, tile: Vector2i, tooltip, locked}]. The player and
## abode bubbles show at every zoom; area bubbles only at region zoom (the caller passes them always).
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


## True at region zoom.
func is_region_zoom() -> bool:
	return _region


## Switches to region zoom centred on [param at_tile] (or back to continent zoom when [param on] is false).
func set_region_zoom(on: bool, at_tile: Vector2 = Vector2(-1, -1)) -> void:
	_region = on
	if on and at_tile.x >= 0:
		_center = at_tile
	_relayout()
	zoom_changed.emit(_region)


## Centres the view on [param tile] at region zoom (the Places panel's selected row).
func centre_on(tile: Vector2i) -> void:
	_center = Vector2(tile) + Vector2(0.5, 0.5)
	if not _region:
		set_region_zoom(true, _center)
	else:
		_relayout()


## The visible bubbles in order (for tests and the demo).
func visible_bubbles() -> Array:
	return _layer.get_children().filter(func(b): return b.visible)


## Pixels per tile at the current zoom.
func tile_scale() -> float:
	if _grid_size == Vector2i.ZERO:
		return 1.0
	var fit: float = minf(size.x / float(_grid_size.x), size.y / float(_grid_size.y))
	return fit * (_region_factor if _region else 1.0)


## The screen position (local) of the top-left corner of the map image.
func _origin() -> Vector2:
	var sc: float = tile_scale()
	if not _region:
		return (size - Vector2(_grid_size) * sc) * 0.5
	return size * 0.5 - _center * sc


## The local position of the centre of tile [param tile].
func tile_to_local(tile: Vector2i) -> Vector2:
	return _origin() + (Vector2(tile) + Vector2(0.5, 0.5)) * tile_scale()


## The tile point under local position [param pos].
func local_to_tile(pos: Vector2) -> Vector2:
	return (pos - _origin()) / tile_scale()


func _relayout() -> void:
	for b in _layer.get_children():
		var mb: MapBubble = b
		var area: bool = mb.kind != "player" and mb.kind != "abode"
		var at: Vector2 = tile_to_local(mb.tile) + mb.cluster_offset - mb.size * 0.5
		mb.position = at
		var r := Rect2(global_position + at, mb.size)
		var shown: bool = (not area or _region) and Rect2(Vector2.ZERO, size).encloses(Rect2(at, mb.size))
		for z in _blocked:
			if (z as Rect2).intersects(r):
				shown = false
		mb.visible = shown
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), _backdrop_near if _region else _backdrop_far)
	var art: Texture2D = (_near if _near != null else _far) if _region else (_far if _far != null else _near)
	if art == null:
		art = _texture
	if art != null:   # every layer is registered to the grid: its full size covers the whole continent
		draw_texture_rect(art, Rect2(_origin(), Vector2(_grid_size) * tile_scale()), false)
	if _region and art == _near and _near != null:
		var by_rank: Array = _places.duplicate()   # small places first, so seats and cities sit on top where patches meet
		by_rank.sort_custom(func(a, b): return _label_rank(a) > _label_rank(b))
		for p in by_rank:   # each known place's own art, painted into its patch of the near layer
			var rec: Dictionary = p.get("rec", {})   # the art is keyed by the authored continent id, not the session id
			var spr: Dictionary = _sprites.get(str(int(rec.get("continent_id", -1))), {})
			if spr.is_empty():
				continue
			var tex: Texture2D = _sprite_texture(spr)
			if tex != null:
				var side: float = float(spr.size_tiles) * tile_scale()
				draw_texture_rect(tex, Rect2(tile_to_local(p.tile) - Vector2(side, side) * 0.5, Vector2(side, side)), false)
	if not _region and _region_font != null:   # region names: letter-spaced heading face, ink with a paper halo
		for r in _regions:
			var label: String = " ".join(Array(str(r.name).to_upper().split("")))
			var fs: int = int(clampf(tile_scale() * 6.0, 13.0, 26.0))
			var w: float = _region_font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
			var at: Vector2 = tile_to_local(Vector2i(r.centre)) - Vector2(w * 0.5, -fs * 0.35)
			draw_string_outline(_region_font, at, label, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, 4, Color(0.89, 0.83, 0.68, 0.75))
			draw_string(_region_font, at, label, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(0.24, 0.16, 0.1, 0.85))
	var dot: float = _place_radius * (1.6 if _region else 1.0)
	var font: Font = get_theme_default_font()
	var taken: Array = []   # label boxes already drawn: a name that would overlap one is skipped (hover always shows)
	var order: Array = _places.duplicate()
	order.sort_custom(func(a, b): return _label_rank(a) < _label_rank(b))
	for p in order:
		var at: Vector2 = _marker_at(p)
		var hover: bool = p.id == _hover_id
		# a diamond marks a fixed named place (art bible Section 3): bone on the painted relief, cinnabar on the paper map
		var fill := Color(0.91, 0.85, 0.71) if _region else Color(0.52, 0.1, 0.11)
		if hover:
			fill = Color(1, 0.86, 0.4)
		_diamond(at, dot + 1.5, Color(0.1, 0.07, 0.05))
		_diamond(at, dot, fill)
		if p.id == _destination_id:
			draw_arc(at, dot + 6.0, 0.0, TAU, 24, Color(1, 0.85, 0.2), 2.0)
		if _region:   # the name on a dark, see-through backing (7.14)
			var name: String = str(p.name)
			var fs: int = 13
			var sz: Vector2 = font.get_string_size(name, HORIZONTAL_ALIGNMENT_LEFT, -1, fs)
			var box := Rect2(at + Vector2(8, -sz.y * 0.5 - 1), sz + Vector2(8, 3))
			if not hover and taken.any(func(r): return (r as Rect2).intersects(box)):
				continue
			taken.append(box)
			draw_rect(box, Color(0.08, 0.05, 0.03, 0.62))
			draw_string(font, box.position + Vector2(4, font.get_ascent(fs) + 1), name, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(0.96, 0.92, 0.82))


## Where a place's diamond and name sit: on its tile, or, at region zoom when the place has its own art, just below
## the art so the marker never covers the place's signature (the place art is centred on the tile).
func _marker_at(p: Dictionary) -> Vector2:
	var at: Vector2 = tile_to_local(p.tile)
	if not _region or _near == null:
		return at
	var spr: Dictionary = _sprites.get(str(int(p.get("rec", {}).get("continent_id", -1))), {})
	if spr.is_empty():
		return at
	return at + Vector2(0, float(spr.size_tiles) * tile_scale() * 0.3)


## Label priority: sect seats and cities first, then towns and markets, then everything else (lower draws first).
static func _label_rank(p: Dictionary) -> int:
	match str(p.get("kind", "")):
		"great_seat", "city": return 0
		"minor_seat", "town", "market": return 1
		"village": return 3
	return 2


func _diamond(at: Vector2, r: float, c: Color) -> void:
	draw_colored_polygon(PackedVector2Array([at + Vector2(0, -r), at + Vector2(r, 0), at + Vector2(0, r), at + Vector2(-r, 0)]), c)


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


## Sets the region names drawn at continent zoom ([param regions] from GameQuery.regions) in [param font].
func set_regions(regions: Array, font: Font) -> void:
	_regions = regions.map(func(r): return {"name": str(r.name), "centre": Vector2(float(r.centre[0]), float(r.centre[1])) + Vector2(0.5, 0.5)})
	_region_font = font
	queue_redraw()


## The place art of the authored place [param continent_id] (its patch of the near map), or null.
func place_art(continent_id: int) -> Texture2D:
	var spr: Dictionary = _sprites.get(str(continent_id), {})
	return _sprite_texture(spr) if not spr.is_empty() else null


## Which layer is drawn now: "near", "far" or "biome" (for the demo checks).
func drawn_layer() -> String:
	if _region:
		return "near" if _near != null else ("far" if _far != null else "biome")
	return "far" if _far != null else ("near" if _near != null else "biome")


func _place_at(pos: Vector2) -> Dictionary:
	var best: Dictionary = {}
	var best_d: float = maxf(_place_radius * 2.5, 8.0)
	for p in _places:
		var d: float = minf(tile_to_local(p.tile).distance_to(pos), _marker_at(p).distance_to(pos))
		if d < best_d:
			best_d = d
			best = p
	return best


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_WHEEL_UP and mb.pressed:
			set_region_zoom(true, local_to_tile(mb.position))
			accept_event()
		elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN and mb.pressed:
			set_region_zoom(false)
			accept_event()
		elif mb.button_index == MOUSE_BUTTON_LEFT or mb.button_index == MOUSE_BUTTON_MIDDLE:
			if mb.pressed:
				_pressed = true
				_dragging = false
				_press_pos = mb.position
				_drag_from = mb.position
			else:
				if _pressed and not _dragging and mb.button_index == MOUSE_BUTTON_LEFT:
					var p: Dictionary = _place_at(mb.position)
					if not p.is_empty():
						place_clicked.emit(str(p.id))
				_pressed = false
				_dragging = false
			accept_event()
	elif event is InputEventMouseMotion:
		var mm := event as InputEventMouseMotion
		if _pressed and _region and (_dragging or mm.position.distance_to(_press_pos) > DRAG_THRESHOLD):
			_dragging = true
			_center -= (mm.position - _drag_from) / tile_scale()
			_drag_from = mm.position
			_relayout()
		var p: Dictionary = _place_at(mm.position)
		var id: String = str(p.get("id", ""))
		if id != _hover_id:
			_hover_id = id
			TooltipLayer.set_tip(self, str(p.get("name", "")))
			queue_redraw()
	elif event is InputEventKey and event.pressed and _region:
		var step := Vector2.ZERO
		match (event as InputEventKey).physical_keycode:
			KEY_LEFT: step = Vector2(-1, 0)
			KEY_RIGHT: step = Vector2(1, 0)
			KEY_UP: step = Vector2(0, -1)
			KEY_DOWN: step = Vector2(0, 1)
		if step != Vector2.ZERO:
			_center += step * PAN_STEP / tile_scale()
			_relayout()
			accept_event()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_relayout()
