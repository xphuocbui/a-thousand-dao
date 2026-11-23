extends SceneTree
## Renders the terrain shader (src/ui/map/canvas_map_terrain.gdshader) for given tile boxes into PNG guides for the
## hybrid repaint (user 2026-11-23: the shader is correct but "looks so bad"; the image model paints over it).
## usage (windowed; the GPU renders): godot --path . -s res://tools/asset-pipeline/map/terrain/render_guide.gd --
##        --out=<dir> --px=<px per tile> --boxes=x,y,w,h;x,y,w,h...   (tiles; each written as guide_<x>_<y>.png)

var _jobs: Array = []
var _vp: SubViewport
var _tv: TerrainView
var _out: String = ""
var _px: float = 24.0
var _frames: int = 0


func _init() -> void:
	var args: Dictionary = {}
	for a in OS.get_cmdline_user_args():
		var kv: PackedStringArray = a.trim_prefix("--").split("=", true, 1)
		args[kv[0]] = kv[1] if kv.size() > 1 else ""
	_out = str(args.get("out", "user://guides"))
	_px = float(args.get("px", "24"))
	for b in str(args.get("boxes", "")).split(";", false):
		var v: PackedStringArray = b.split(",")
		_jobs.append(Rect2(float(v[0]), float(v[1]), float(v[2]), float(v[3])))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(_out) if _out.begins_with("res://") or _out.begins_with("user://") else _out)


func _process(_delta: float) -> bool:
	if _vp == null:
		var cfg: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/data/ui_hud.json")).greybox.terrain_shader
		_vp = SubViewport.new()
		_vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		_tv = TerrainView.new()
		# guide mode (hybrid.py): soft biome blends, strong relief, plain water; the model paints the shore and the sea
		var guide: Dictionary = cfg.duplicate()
		guide.merge({"blend_sharpness": 0.9, "edge_warp": 3.2, "relief": 1.15, "foam_strength": 0.0, "shore_tint": 0.0,
			"macro_var": 0.18}, true)
		if not _tv.load_data(str(cfg.dir), guide):
			push_error("terrain data missing")
			return true
		_vp.add_child(_tv)
		get_root().add_child(_vp)
		_next()
		return false
	_frames += 1
	if _frames < 4:
		return false
	var r: Rect2 = _jobs.pop_front()
	var img: Image = _vp.get_texture().get_image()
	var path: String = "%s/guide_%d_%d.png" % [_out, int(r.position.x), int(r.position.y)]
	img.save_png(ProjectSettings.globalize_path(path) if path.begins_with("res://") or path.begins_with("user://") else path)
	print("guide ", path, " ", img.get_size())
	if _jobs.is_empty():
		return true
	_next()
	return false


func _next() -> void:
	var r: Rect2 = _jobs[0]
	var sz := Vector2i(int(r.size.x * _px), int(r.size.y * _px))
	_vp.size = sz
	_tv.size = Vector2(sz)
	_tv.set_view(-r.position * _px, _px, Vector2(540, 360))
	_frames = 0
