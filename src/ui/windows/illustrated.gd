class_name Illustrated
extends RefCounted
## Building blocks of the illustrated windows (round-3 mock-ups prototypes/ui-mood/out/r3-character-l.png and
## r3-sect-l.png, approved by the user 2026-11-24): a dark rosewood ground with parchment insets under small brass
## headings, framed paintings (portraits, place paintings), round portrait medallions, a name plaque, icon tiles with a
## big number, brass gauges and slot cards. Colours come from the Rosewood theme's palette (ui_hud.json theme) where it
## has them; every piece is a plain Control, so windows keep their own tooltips, focus and accessibility names.

const BRASS := Color("#C9A25A")
const BRASS_DIM := Color("#8A6D3B")
const PAPER := Color("#E3D4AE")
const PAPER_TILE := Color("#D6C59C")
const INK := Color("#2B2118")
const GILT := Color("#5E4316")
const BONE := Color("#E8D9B5")
const CINNABAR := Color("#84191B")
const GROUND := Color("#24160F")

static var _round: Shader = null


## A flat box: [param bg] fill, [param edge] border of [param w] px, [param pad] content margin.
static func box(bg: Color, edge: Color, w: int = 2, pad: float = 8.0, radius: int = 2) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = edge
	sb.set_border_width_all(w)
	sb.set_corner_radius_all(radius)
	sb.set_content_margin_all(pad)
	sb.shadow_color = Color(0, 0, 0, 0.35)
	sb.shadow_size = 2 if w > 0 else 0
	return sb


## The dark wood ground of an illustrated window, added to [param parent]; returns its column.
static func ground(parent: Control, gap: int = 10) -> VBoxContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", box(GROUND, BRASS_DIM, 1, 12.0, 3))
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(p)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", gap)
	p.add_child(col)
	return col


## A parchment inset with a small brass-gilt heading (or none when [param title] is ""), added to [param parent];
## returns its content column.
static func inset(parent: Control, title: String, expand: bool = true) -> VBoxContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", box(PAPER, BRASS, 2, 10.0, 2))
	if expand:
		p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(p)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 6)
	p.add_child(col)
	if title != "":
		var h := Label.new()
		h.text = title.to_upper()
		h.theme_type_variation = &"RowLabel"
		col.add_child(h)
		var rule := ColorRect.new()
		rule.color = Color(BRASS, 0.7)
		rule.custom_minimum_size = Vector2(0, 1)
		col.add_child(rule)
	return col


## A framed painting [param tex] at [param min_size] (cropped to cover); when [param tex] is null an ink emblem with
## [param fallback] stands in. Returns the frame.
static func framed(tex: Texture2D, min_size: Vector2, fallback: String = "") -> PanelContainer:
	var f := PanelContainer.new()
	f.add_theme_stylebox_override("panel", box(Color("#120B07"), BRASS, 3, 3.0, 2))
	f.custom_minimum_size = min_size
	if tex != null:
		var r := TextureRect.new()
		r.texture = tex
		r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		r.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		r.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		r.custom_minimum_size = min_size - Vector2(6, 6)
		r.clip_contents = true
		f.add_child(r)
	else:
		var l := Label.new()
		l.text = fallback
		l.theme_type_variation = &"WoodHeading"
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		f.add_child(l)
	return f


## A round portrait medallion of [param tex] [param d] px across with a brass ring; a faded one for the dead.
static func medallion(tex: Texture2D, d: float, faded: bool = false) -> Control:
	var r := TextureRect.new()
	r.custom_minimum_size = Vector2(d, d)
	r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	r.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	r.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	r.texture = tex
	r.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	if _round == null:
		_round = Shader.new()
		_round.code = """shader_type canvas_item;
uniform vec4 ring : source_color = vec4(0.79, 0.64, 0.35, 1.0);
uniform float fade = 0.0;
void fragment() {
	float d = length(vec2(UV.x - 0.5, UV.y - 0.5));
	vec4 c = texture(TEXTURE, UV);
	c.rgb = mix(c.rgb, vec3(dot(c.rgb, vec3(0.3, 0.59, 0.11))), fade);
	float edge = smoothstep(0.5, 0.48, d);
	float band = smoothstep(0.43, 0.45, d) * edge;
	COLOR = vec4(mix(c.rgb, ring.rgb, band), edge);
}"""
	var m := ShaderMaterial.new()
	m.shader = _round
	m.set_shader_parameter("fade", 0.6 if faded else 0.0)
	r.material = m
	return r


## A name plaque: [param text] in the title face on cinnabar lacquer with a brass edge.
static func plaque(text: String) -> PanelContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", box(CINNABAR, BRASS, 2, 6.0, 2))
	var l := Label.new()
	l.text = text
	l.theme_type_variation = &"TitleLabel"
	l.add_theme_color_override("font_color", BONE)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	p.add_child(l)
	return p


## A stat tile: an [param icon] (or none), a small [param label] and a big [param value]. Returns the tile (focusable,
## for its tooltip); [param note] is a third small line under the value.
static func tile(icon: Texture2D, label: String, value: String, note: String = "", min_w: float = 140.0) -> PanelContainer:
	var t := PanelContainer.new()
	t.add_theme_stylebox_override("panel", box(PAPER_TILE, BRASS_DIM, 1, 8.0, 2))
	t.custom_minimum_size = Vector2(min_w, 0)
	t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	t.focus_mode = Control.FOCUS_ALL
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	t.add_child(row)
	if icon != null:
		var ic := TextureRect.new()
		ic.texture = icon
		ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		ic.custom_minimum_size = Vector2(38, 38)
		ic.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(ic)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 0)
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(col)
	var l := Label.new()
	l.text = label
	l.theme_type_variation = &"RowLabel"
	l.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	col.add_child(l)
	var v := Label.new()
	v.text = value
	v.theme_type_variation = &"HeadingLabel"
	v.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	col.add_child(v)
	if note != "":
		var n := Label.new()
		n.text = note
		n.theme_type_variation = &"RowLabel"
		n.add_theme_color_override("font_color", Color(INK, 0.7))
		col.add_child(n)
	t.accessibility_name = "%s %s%s" % [label, value, (" " + note) if note != "" else ""]
	return t


## A grid of [param cols] columns added to [param parent] (for tiles and cards).
static func grid(parent: Control, cols: int, gap: int = 8) -> GridContainer:
	var g := GridContainer.new()
	g.columns = cols
	g.add_theme_constant_override("h_separation", gap)
	g.add_theme_constant_override("v_separation", gap)
	g.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(g)
	return g


## A brass gauge [param share] (0..1) full of [param fill].
static func gauge(share: float, fill: Color, h: float = 14.0) -> ProgressBar:
	var pb := ProgressBar.new()
	pb.min_value = 0.0
	pb.max_value = 1.0
	pb.value = clampf(share, 0.0, 1.0)
	pb.show_percentage = false
	pb.custom_minimum_size = Vector2(0, h)
	pb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pb.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	pb.add_theme_stylebox_override("background", box(Color("#3A2A1C"), BRASS_DIM, 1, 0.0, 2))
	var f := box(fill, Color(fill.lightened(0.25), 0.9), 1, 0.0, 2)
	f.shadow_size = 0
	pb.add_theme_stylebox_override("fill", f)
	return pb


## A slot card: [param icon] (or an empty recessed frame), the slot's [param kind] and the [param title] under it.
static func card(icon: Texture2D, kind: String, title: String, sub: String = "") -> PanelContainer:
	var t := PanelContainer.new()
	t.add_theme_stylebox_override("panel", box(PAPER_TILE, BRASS, 2, 8.0, 2))
	t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	t.focus_mode = Control.FOCUS_ALL
	var col := VBoxContainer.new()
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	t.add_child(col)
	var frame := PanelContainer.new()
	frame.add_theme_stylebox_override("panel", box(Color("#1B120C") if icon != null else Color("#BFAE84"), BRASS_DIM, 2, 2.0, 2))
	frame.custom_minimum_size = Vector2(72, 72)
	frame.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	col.add_child(frame)
	if icon != null:
		var ic := TextureRect.new()
		ic.texture = icon
		ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		ic.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		frame.add_child(ic)
	var k := Label.new()
	k.text = kind
	k.theme_type_variation = &"RowLabel"
	col.add_child(k)
	var n := Label.new()
	n.text = title
	n.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	n.custom_minimum_size = Vector2(110, 0)
	col.add_child(n)
	if sub != "":
		var s := Label.new()
		s.text = sub
		s.theme_type_variation = &"RowLabel"
		s.add_theme_color_override("font_color", Color(INK, 0.7))
		s.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		col.add_child(s)
	t.accessibility_name = "%s: %s%s" % [kind, title, (", " + sub) if sub != "" else ""]
	return t


## A texture from res:// [param path], or null when it is not there.
static func tex(path: String) -> Texture2D:
	return load(path) if path != "" and ResourceLoader.exists(path) else null
