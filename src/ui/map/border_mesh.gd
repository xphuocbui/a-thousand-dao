class_name BorderMesh
extends MeshInstance2D
## The map's dashed borders as one static mesh drawn by a shader (the map's framerate, user 2026-11-24: "zooming in
## and out is still a bit laggy"). Built once from the lines in tile units; each segment is a quad whose vertices the
## vertex shader pushes out to a constant screen width, and the fragment shader cuts the dashes from the distance
## along the line in screen px. A pan or a zoom only moves the node (position = the map's origin, scale = px per
## tile) and sets two uniforms: nothing is rebuilt and no point is moved on the CPU.
##
## Two sets: province lines (dash-dot, faded in by zoom) and region lines (dashed). The holder lines (double) stay in
## MapView._draw_borders.

const SHADER := """shader_type canvas_item;
render_mode skip_vertex_transform;
uniform float px_per_tile = 4.0;
uniform float half_width_px = 0.7;
uniform vec4 ink = vec4(0.15, 0.1, 0.07, 0.8);   // as given (no colour-space hint), like the old draw_multiline
uniform float prov_alpha = 1.0;
uniform float thin_alpha = 1.0;
uniform vec4 dash_dot = vec4(9.0, 4.0, 1.6, 4.0);
uniform vec2 dash = vec2(9.0, 5.0);
varying float v_arc;
varying float v_side;
varying float v_kind;
void vertex() {
	vec2 n = COLOR.rg * 2.0 - 1.0;
	float side = UV.y;
	// to canvas space first (position + px per tile scale), then out to a constant width in px
	VERTEX = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy + n * side * (half_width_px + 1.0);
	v_arc = UV.x;
	v_side = side;
	v_kind = COLOR.a;
}
void fragment() {
	float len = v_arc * px_per_tile;
	float a;
	bool on;
	if (v_kind > 0.5) {
		float period = dash_dot.x + dash_dot.y + dash_dot.z + dash_dot.w;
		float t = mod(len, period);
		on = t < dash_dot.x || (t > dash_dot.x + dash_dot.y && t < dash_dot.x + dash_dot.y + dash_dot.z);
		a = prov_alpha;
	} else {
		float t = mod(len, dash.x + dash.y);
		on = t < dash.x;
		a = thin_alpha;
	}
	if (!on || a <= 0.001) {
		discard;
	}
	float d = abs(v_side) * (half_width_px + 1.0);   // px from the line's middle
	float edge = clamp(half_width_px + 0.5 - d, 0.0, 1.0);   // solid to the line's width, a one-pixel soft edge past it
	COLOR = vec4(ink.rgb, ink.a * a * edge);
}
"""

var _mat := ShaderMaterial.new()


func _init() -> void:
	show_behind_parent = true   # under the map's places and names, above the terrain
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	var sh := Shader.new()
	sh.code = SHADER
	_mat.shader = sh
	material = _mat


## Builds the mesh from [param prov] (province lines) and [param thin] (region lines), each an Array of
## PackedVector2Array polylines in tiles. An empty set draws nothing.
func build(prov: Array, thin: Array) -> void:
	var v := PackedVector2Array()
	var uv := PackedVector2Array()
	var col := PackedColorArray()
	var idx := PackedInt32Array()
	for pair in [[prov, 1.0], [thin, 0.0]]:
		for ln in pair[0]:
			var pts: PackedVector2Array = ln
			var arc: float = 0.0
			for i in pts.size() - 1:
				var a: Vector2 = pts[i]
				var b: Vector2 = pts[i + 1]
				var d: Vector2 = b - a
				var l: float = d.length()
				if l <= 0.0:
					continue
				var n := Vector2(-d.y, d.x) / l
				var c := Color(n.x * 0.5 + 0.5, n.y * 0.5 + 0.5, 0.0, float(pair[1]))
				var base: int = v.size()
				for q in [[a, arc, -1.0], [a, arc, 1.0], [b, arc + l, 1.0], [b, arc + l, -1.0]]:
					v.append(q[0])
					uv.append(Vector2(q[1], q[2]))
					col.append(c)
				idx.append_array([base, base + 1, base + 2, base, base + 2, base + 3])
				arc += l
	if v.is_empty():
		mesh = null
		return
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = v
	arrays[Mesh.ARRAY_TEX_UV] = uv
	arrays[Mesh.ARRAY_COLOR] = col
	arrays[Mesh.ARRAY_INDEX] = idx
	var m := ArrayMesh.new()
	m.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays, [], {}, Mesh.ARRAY_FLAG_USE_2D_VERTICES)
	mesh = m


## Places the mesh for the map's view: [param origin] (screen px of tile 0,0) and [param sc] px per tile, with the
## province and region lines' opacities (0 hides a set) and the line look from the config.
func set_view(origin: Vector2, sc: float, prov_alpha: float, thin_alpha: float) -> void:
	position = origin
	scale = Vector2(sc, sc)
	_mat.set_shader_parameter("px_per_tile", sc)
	_mat.set_shader_parameter("prov_alpha", prov_alpha)
	_mat.set_shader_parameter("thin_alpha", thin_alpha)


## The line look: width in px, ink colour, and the two dash patterns (px).
func set_look(width_px: float, ink: Color, dash_dot: Array, dash_pat: Array) -> void:
	_mat.set_shader_parameter("half_width_px", width_px * 0.5)
	_mat.set_shader_parameter("ink", ink)
	if dash_dot.size() >= 4:
		_mat.set_shader_parameter("dash_dot", Vector4(dash_dot[0], dash_dot[1], dash_dot[2], dash_dot[3]))
	if dash_pat.size() >= 2:
		_mat.set_shader_parameter("dash", Vector2(dash_pat[0], dash_pat[1]))
