class_name MapView
extends Control
## The continent map of the greybox map screen (design/ux/hud.md, Information Architecture Group 3): the authored
## grid drawn one flat colour per main biome, a dot for each place the player knows, the player's marker and the
## chosen destination. Hovering a place shows its name (a stand-in for the custom tooltip layer); clicking one emits
## [signal place_clicked]. Display only: it never changes game state.

## The player clicked the known place [param place_id].
signal place_clicked(place_id: String)

var _texture: ImageTexture = null
var _grid_size := Vector2i.ZERO
## Known places: [{id, name, tile: Vector2i, kind}].
var _places: Array = []
var _player_tile := Vector2i(-1, -1)
var _destination_id: String = ""
var _place_radius: float = 3.0
var _player_radius: float = 6.0
var _hover_id: String = ""


## Builds the map image from [param grid] with [param cfg] (ui_hud.json "greybox").
func setup(grid: ContinentGrid, cfg: Dictionary) -> void:
	_place_radius = float(cfg.get("place_radius_px", 3.0))
	_player_radius = float(cfg.get("player_radius_px", 6.0))
	_grid_size = Vector2i(grid.width, grid.height)
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
	queue_redraw()


## Sets the known places [param places] ([{id, name, tile, kind}]), the player's tile and the destination.
func set_state(places: Array, player_tile: Vector2i, destination_id: String) -> void:
	_places = places
	_player_tile = player_tile
	_destination_id = destination_id
	queue_redraw()


## The rectangle the map image fills inside this control (aspect kept, centred).
func map_rect() -> Rect2:
	if _grid_size == Vector2i.ZERO:
		return Rect2(Vector2.ZERO, size)
	var scale_f: float = minf(size.x / float(_grid_size.x), size.y / float(_grid_size.y))
	var s := Vector2(_grid_size) * scale_f
	return Rect2((size - s) * 0.5, s)


## The screen position of the centre of tile [param tile].
func tile_to_local(tile: Vector2i) -> Vector2:
	var r: Rect2 = map_rect()
	return r.position + (Vector2(tile) + Vector2(0.5, 0.5)) * (r.size.x / float(maxi(_grid_size.x, 1)))


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.08, 0.1, 0.14))
	if _texture != null:
		draw_texture_rect(_texture, map_rect(), false)
	for p in _places:
		var at: Vector2 = tile_to_local(p.tile)
		var col := Color(0.95, 0.92, 0.8) if p.id != _hover_id else Color(1, 1, 0.4)
		draw_circle(at, _place_radius, Color(0.1, 0.1, 0.1))
		draw_circle(at, _place_radius - 1.0, col)
		if p.id == _destination_id:
			draw_arc(at, _place_radius + 5.0, 0.0, TAU, 24, Color(1, 0.85, 0.2), 2.0)
	if _player_tile.x >= 0:
		var me: Vector2 = tile_to_local(_player_tile)
		draw_circle(me, _player_radius + 1.5, Color(0.05, 0.05, 0.05))
		draw_circle(me, _player_radius, Color(0.85, 0.2, 0.2))


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
	if event is InputEventMouseMotion:
		var p: Dictionary = _place_at(event.position)
		var id: String = str(p.get("id", ""))
		if id != _hover_id:
			_hover_id = id
			tooltip_text = str(p.get("name", ""))
			queue_redraw()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var p: Dictionary = _place_at(event.position)
		if not p.is_empty():
			place_clicked.emit(str(p.id))
			accept_event()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()
