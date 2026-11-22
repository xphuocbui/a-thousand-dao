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
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.08, 0.1, 0.14))
	if _texture != null:
		draw_texture_rect(_texture, Rect2(_origin(), Vector2(_grid_size) * tile_scale()), false)
	var dot: float = _place_radius * (1.6 if _region else 1.0)
	for p in _places:
		var at: Vector2 = tile_to_local(p.tile)
		var col := Color(0.95, 0.92, 0.8) if p.id != _hover_id else Color(1, 1, 0.4)
		draw_circle(at, dot, Color(0.1, 0.1, 0.1))
		draw_circle(at, dot - 1.0, col)
		if p.id == _destination_id:
			draw_arc(at, dot + 5.0, 0.0, TAU, 24, Color(1, 0.85, 0.2), 2.0)
		if _region:
			draw_string(get_theme_default_font(), at + Vector2(8, 4), str(p.name), HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(1, 1, 1, 0.9))


func _place_at(pos: Vector2) -> Dictionary:
	var best: Dictionary = {}
	var best_d: float = maxf(_place_radius * 2.5, 8.0)
	for p in _places:
		var d: float = tile_to_local(p.tile).distance_to(pos)
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
