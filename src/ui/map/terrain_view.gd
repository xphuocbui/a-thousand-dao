class_name TerrainView
extends ColorRect
## The map's near terrain drawn by a shader from the game's own data (canvas_map_terrain.gdshader; user 2026-11-23:
## "Paradox-style shader"): biome textures blended by the biome map, lit by the true elevation, the shore at the true
## coast, water coloured by depth, rivers from the river cells. MapView places it behind its own drawing and tells it
## where the map is each time the view changes. Display only.

const SHADER := preload("res://src/ui/map/canvas_map_terrain.gdshader")

var _ready_ok: bool = false


## Loads the baked data in [param dir] (tools/asset-pipeline/map/terrain/bake_data.py) and the texture array; returns
## false (and draws nothing) when a file is missing.
func load_data(dir: String, knobs: Dictionary = {}) -> bool:
	_ready_ok = false
	var meta_path: String = dir + "/meta.json"
	if not FileAccess.file_exists(meta_path) or not ResourceLoader.exists(dir + "/biomes_array.png"):
		return false
	var meta: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(meta_path))
	var w: int = int(meta.width)
	var h: int = int(meta.height)
	var mat := ShaderMaterial.new()
	mat.shader = SHADER
	mat.set_shader_parameter("biome_map", _raw(dir + "/biome.bin", w, h, Image.FORMAT_R8))
	mat.set_shader_parameter("coast_map", _raw(dir + "/coast.bin", w, h, Image.FORMAT_RF))
	mat.set_shader_parameter("elev_map", _raw(dir + "/elev.bin", w, h, Image.FORMAT_RF))
	mat.set_shader_parameter("river_map", _raw(dir + "/river.bin", w * 2, h * 2, Image.FORMAT_R8))
	mat.set_shader_parameter("relief_map", _raw(dir + "/relief.bin", w * 2, h * 2, Image.FORMAT_RG8))
	mat.set_shader_parameter("biome_tex", load(dir + "/biomes_array.png"))
	mat.set_shader_parameter("fine", Vector2(w, h))
	var noise := NoiseTexture2D.new()
	noise.width = 512
	noise.height = 512
	noise.seamless = true
	noise.noise = FastNoiseLite.new()
	noise.noise.frequency = 0.012
	noise.noise.seed = 11
	mat.set_shader_parameter("noise_map", noise)
	for k in knobs:   # ui_hud.json greybox.terrain_shader: any shader uniform by name
		if not str(k).begins_with("_") and k not in ["enabled", "dir"]:
			var v: Variant = knobs[k]
			if v is String and str(v).begins_with("#"):   # colours are written as #rrggbb in the config
				v = Color.from_string(str(v), Color.WHITE)
			mat.set_shader_parameter(str(k), v)
	material = mat
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	show_behind_parent = true
	_ready_ok = true
	return true


var _layers: Array = []   # painted land to draw this frame: [texture, dst Rect2, src Rect2 or null]


## Painted-land mode (ui_hud greybox.terrain_shader.painted_land): the textures MapView wants drawn this frame, each as
## [texture, dst rect (local px), src rect in texture px or null for the whole texture]; the shader puts the game's
## water over them along the true coast.
func set_layers(layers: Array) -> void:
	_layers = layers
	queue_redraw()


func _draw() -> void:
	for l in _layers:
		if l[2] == null:
			draw_texture_rect(l[0], l[1], false)
		else:
			draw_texture_rect_region(l[0], l[1], l[2])


## Whether the land is the painted layer (true) or the shader's biome textures (false).
func is_painted() -> bool:
	return _ready_ok and bool((material as ShaderMaterial).get_shader_parameter("painted_land"))


## Whether the data and textures loaded.
func is_ready() -> bool:
	return _ready_ok


## Tells the shader where the map is: [param origin] the local px of tile (0, 0), [param px] screen px per tile, and
## [param grid] the map size in tiles.
func set_view(origin: Vector2, px: float, grid: Vector2) -> void:
	if not _ready_ok:
		return
	var mat := material as ShaderMaterial
	mat.set_shader_parameter("rect_size", size)
	mat.set_shader_parameter("map_origin", origin)
	mat.set_shader_parameter("px_per_tile", px)
	mat.set_shader_parameter("grid", grid)


static func _raw(path: String, w: int, h: int, fmt: int) -> ImageTexture:
	var bytes: PackedByteArray = FileAccess.get_file_as_bytes(path)
	var img := Image.create_from_data(w, h, false, fmt, bytes)
	return ImageTexture.create_from_image(img)
