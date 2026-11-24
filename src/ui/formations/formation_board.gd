class_name FormationBoard
extends Control
## A combat formation (trận đồ) drawn as a glowing array on a dark lacquered board (design/ux/diagram-editor.md C2,
## design/ux/fight-screen.md; the user's picks 2026-11-24, mock-ups r5-tab-a and r5-fight-b2): the formation's figure in
## gold strokes, curved links (feeds as light-blue arrows with their seconds, adjacency as plain strokes), and one round
## node per formation node holding its art's painted icon, with a + / − / ? badge; a node or link closed at the
## current level is dashed and marked "L<n>". Built from a [method GameQuery.diagram_view]; display only: clicks are
## signals, the owner asks the session.
##
## Nodes are child buttons ([method node_button]) so focus, keyboard and tooltips work; the fight screen may put its
## own slot widgets on them ([method node_rect]).

## A node was pressed (1-based index).
signal node_pressed(n: int)

const GOLD := Color(0.87, 0.70, 0.40)
const FEED := Color(0.47, 0.80, 1.0)
const ADJ := Color(0.67, 0.59, 0.47)
const BOARD := Color(0.04, 0.05, 0.09)
const POL := {"+": Color(0.43, 0.75, 0.41), "-": Color(0.86, 0.37, 0.33), "?": Color(0.45, 0.67, 0.92)}

## The view drawn ({} draws an empty board).
var view: Dictionary = {}
## The node radius in px at scale 1 (the board shrinks it to fit).
var node_px: float = 30.0
## Dim the whole drawing (a carried formation on the fight screen).
var dim: float = 1.0
## The selected node (1-based, 0 none): its ring glows.
var selected: int = 0
## Draw seconds on feeds and "L<n>" on closed parts.
var labels: bool = true
## Draw the art icons in the nodes (off when the fight screen lays its own slot widgets over them).
var draw_icons: bool = true
## A thumbnail (the collection's medallions): no node buttons, no labels, nodes as small dots, no board fill.
var thumb: bool = false

var _buttons: Array = []
var _font: Font = null
var _attached: Dictionary = {}   # node (1-based) -> a Control laid over it (the fight screen's live art slot)


## Lays [param c] over node [param n] (it becomes this board's child and follows its layout).
func attach(n: int, c: Control) -> void:
	if c.get_parent() != self:
		add_child(c)
	_attached[n] = c
	_layout()


func _init() -> void:
	clip_contents = true
	mouse_filter = Control.MOUSE_FILTER_PASS
	custom_minimum_size = Vector2(200, 160)


## Shows [param v] (a diagram view).
func show_view(v: Dictionary) -> void:
	view = v
	for b in _buttons:
		b.queue_free()
	_buttons.clear()
	for nd in (Array(v.get("nodes", [])) if not thumb else []):
		var b := Button.new()
		b.name = "Node_%d" % int(nd.n)
		b.flat = true
		b.focus_mode = Control.FOCUS_ALL
		b.mouse_filter = Control.MOUSE_FILTER_STOP
		b.accessibility_name = _node_words(nd)
		var n: int = int(nd.n)
		b.pressed.connect(func(): node_pressed.emit(n))
		var empty := StyleBoxEmpty.new()
		for st in ["normal", "hover", "pressed", "focus", "disabled"]:
			b.add_theme_stylebox_override(st, empty)
		TooltipLayer.set_tip(b, {"title": tr("Node %d") % n + ("  ·  " + str(nd.art_name) if str(nd.get("art_name", "")) != "" else ""),
			"fact": {"+": tr("benefit"), "-": tr("drawback"), "?": tr("condition")}.get(str(nd.polarity), ""),
			"summary": str(nd.words) + ("" if bool(nd.open) else "  ·  " + tr("opens at level %d") % int(nd.unlock))})
		add_child(b)
		_buttons.append(b)
	_layout()
	queue_redraw()


## The button of node [param n] (1-based; null when none), for tests and the fight screen.
func node_button(n: int) -> Button:
	return _buttons[n - 1] if n >= 1 and n <= _buttons.size() else null


## Node [param n]'s rect in this control (the fight screen lays its slot widget over it).
func node_rect(n: int) -> Rect2:
	var b: Button = node_button(n)
	return Rect2(b.position, b.size) if b != null else Rect2()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_layout()
		queue_redraw()


# --- the board's own transform: the view's positions (and figure) fitted into this control ---------------------
var _sc: float = 1.0
var _off := Vector2.ZERO
var _r: float = 30.0


func _fit() -> void:
	var pts: Array = []
	for nd in Array(view.get("nodes", [])):
		pts.append(Vector2(float(nd.pos[0]), float(nd.pos[1])))
	for f in Array(view.get("figure", [])):
		for p in _figure_extent(f):
			pts.append(p)
	if pts.is_empty():
		_sc = 1.0
		_off = size * 0.5
		return
	var lo := Vector2(INF, INF)
	var hi := Vector2(-INF, -INF)
	for p in pts:
		lo = Vector2(minf(lo.x, p.x), minf(lo.y, p.y))
		hi = Vector2(maxf(hi.x, p.x), maxf(hi.y, p.y))
	var span := Vector2(maxf(hi.x - lo.x, 0.8), maxf(hi.y - lo.y, 0.8))
	var pad: float = node_px * 2.2 if not thumb else 6.0
	var pad_y: float = node_px * 1.5 if not thumb else 6.0
	# a flat shape (a row, a line) is fitted by its width only: its height must not shrink it to nothing
	var sy: float = (size.y - pad_y * 2.0) / span.y if hi.y - lo.y > 0.05 else INF
	_sc = minf((size.x - pad * 2.0) / span.x, sy)
	_sc = maxf(_sc, 1.0)
	_r = clampf(minf(node_px, _sc * 0.32), 12.0 if not thumb else 2.0, node_px)
	_off = size * 0.5 - (lo + hi) * 0.5 * _sc


func _figure_extent(f: Dictionary) -> Array:
	var out: Array = []
	for key in ["c", "from", "to"]:
		if f.has(key):
			out.append(Vector2(float(f[key][0]), float(f[key][1])))
	for p in Array(f.get("points", [])):
		out.append(Vector2(float(p[0]), float(p[1])))
	var r: float = float(f.get("r", f.get("r1", f.get("size", 0.0) * 0.5 if f.has("size") else (f.get("len", 0.0) * 0.5 if f.has("len") else 0.0))))
	if f.has("c") and r > 0.0:
		var c := Vector2(float(f.c[0]), float(f.c[1]))
		out.append_array([c - Vector2(r, r), c + Vector2(r, r)])
	return out


func _t(p: Variant) -> Vector2:
	return Vector2(float(p[0]), float(p[1])) * _sc + _off


func _layout() -> void:
	_fit()
	var nodes: Array = view.get("nodes", [])
	for i in _buttons.size():
		var c: Vector2 = _t(nodes[i].pos)
		_buttons[i].position = c - Vector2(_r, _r)
		_buttons[i].size = Vector2(_r, _r) * 2.0
	for n in _attached:
		if int(n) >= 1 and int(n) <= nodes.size():
			var c2: Vector2 = _t(nodes[int(n) - 1].pos)
			(_attached[n] as Control).position = c2 - Vector2(_r, _r)
			(_attached[n] as Control).size = Vector2(_r, _r) * 2.0


func _draw() -> void:
	if _font == null:
		_font = get_theme_default_font()
	if not thumb:
		draw_rect(Rect2(Vector2.ZERO, size), BOARD)
	if view.is_empty():
		return
	if thumb:
		_draw_thumb()
		return
	var a: float = dim
	for f in Array(view.get("figure", [])):
		for ln in _figure_lines(f):
			if ln.size() >= 2:
				draw_polyline(ln, Color(GOLD, 0.16 * a), 7.0, true)
				draw_polyline(ln, Color(GOLD, 0.78 * a), 1.6, true)
		if str(f.shape) == "stars":
			var rnd := RandomNumberGenerator.new()
			rnd.seed = 7
			var c := Vector2(float(f.c[0]), float(f.c[1]))
			for i in int(f.n):
				var ang: float = rnd.randf_range(0.0, TAU)
				var rr: float = float(f.r) * sqrt(rnd.randf_range(0.05, 1.0))
				draw_circle(_t([c.x + rr * cos(ang), c.y + rr * sin(ang)]), 1.6, Color(0.94, 0.88, 0.7, 0.85 * a))
	var nodes: Array = view.get("nodes", [])
	for l in Array(view.get("links", [])):
		var pa: Vector2 = _t(nodes[int(l.a) - 1].pos)
		var pb: Vector2 = _t(nodes[int(l.b) - 1].pos)
		var pts: PackedVector2Array = _bez(pa, pb, float(l.get("bend", 0.0)))
		var cut := PackedVector2Array()
		for p in pts:
			if p.distance_to(pa) > _r + 3.0 and p.distance_to(pb) > _r + 7.0:
				cut.append(p)
		if cut.size() < 2:
			continue
		var open: bool = bool(l.get("open", true))
		var col: Color = FEED if str(l.kind) == "feed" else ADJ
		col.a = (0.95 if open else 0.45) * a
		if str(l.kind) == "feed" and open:
			draw_polyline(cut, Color(FEED, 0.18 * a), 7.0, true)
		if open:
			draw_polyline(cut, col, 2.4, true)
		else:
			_dashed(cut, col, 2.0)
		if str(l.kind) == "feed":
			var e: Vector2 = cut[cut.size() - 1]
			var d: Vector2 = (e - cut[cut.size() - 2]).normalized()
			for da in [2.6, -2.6]:
				draw_line(e, e + d.rotated(da) * 10.0, col, 2.4, true)
			if labels:
				var m: Vector2 = cut[cut.size() / 2]
				draw_string(_font, m + Vector2(5, -5), ("%.1fs" % float(l.seconds)) + ("" if open else "  L%d" % int(l.unlock)), HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.7, 0.88, 1.0, a))
	for nd in nodes:
		var c: Vector2 = _t(nd.pos)
		var open: bool = bool(nd.open)
		var pol: Color = POL.get(str(nd.polarity), GOLD)
		draw_circle(c, _r + 5.0, Color(0.43, 0.32, 0.16, a) if open else Color(0.22, 0.2, 0.19, a))
		draw_circle(c, _r, Color(0.06, 0.05, 0.08, a))
		if int(nd.n) == selected:
			draw_arc(c, _r + 8.0, 0.0, TAU, 40, Color(1.0, 0.86, 0.45, a), 3.0, true)
		var tex: Texture2D = Illustrated.tex(str(nd.get("icon", ""))) if str(nd.get("icon", "")) != "" else null
		if tex != null and open and draw_icons:
			var s: float = _r * 1.62
			draw_texture_rect(tex, Rect2(c - Vector2(s, s) * 0.5, Vector2(s, s)), false, Color(1, 1, 1, a))
		if open:
			draw_arc(c, _r, 0.0, TAU, 40, Color(pol, a), 3.0, true)
		else:
			for k in 12:
				draw_arc(c, _r, TAU * k / 12.0, TAU * (k + 0.55) / 12.0, 4, Color(0.6, 0.56, 0.5, a), 2.0, true)
		if str(nd.polarity) != "":   # a plain slot (the Plain Row) has no polarity badge
			var bp: Vector2 = c + Vector2(_r * 0.72, -_r * 0.72)
			draw_circle(bp, 9.0, Color(pol, a) if open else Color(0.4, 0.38, 0.36, a))
			var mark: String = {"+": "+", "-": "−", "?": "?"}.get(str(nd.polarity), "")
			draw_string(_font, bp + Vector2(-4.5, 5.5), mark, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color(1, 0.98, 0.92, a))
		if not open and labels:
			draw_string(_font, c + Vector2(-9, 5), "L%d" % int(nd.unlock), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(0.9, 0.84, 0.66, a))


# A thumbnail: the figure and links in thin gold, the nodes as dots.
func _draw_thumb() -> void:
	for f in Array(view.get("figure", [])):
		for ln in _figure_lines(f):
			if ln.size() >= 2:
				draw_polyline(ln, Color(GOLD, 0.55 * dim), 1.0, true)
	var nodes: Array = view.get("nodes", [])
	for l in Array(view.get("links", [])):
		draw_polyline(_bez(_t(nodes[int(l.a) - 1].pos), _t(nodes[int(l.b) - 1].pos), float(l.get("bend", 0.0)), 10), Color(GOLD, 0.8 * dim), 1.2, true)
	for nd in nodes:
		draw_circle(_t(nd.pos), 3.0 if bool(nd.get("open", true)) else 2.0, Color(GOLD, (1.0 if bool(nd.get("open", true)) else 0.45) * dim))


func _bez(a: Vector2, b: Vector2, bend: float, n: int = 24) -> PackedVector2Array:
	var m: Vector2 = (a + b) * 0.5
	var d: Vector2 = b - a
	var ctl: Vector2 = m + Vector2(-d.y, d.x) * bend * 0.5
	var out := PackedVector2Array()
	for i in n + 1:
		var t: float = float(i) / n
		out.append(a * (1 - t) * (1 - t) + ctl * 2.0 * (1 - t) * t + b * t * t)
	return out


func _dashed(pts: PackedVector2Array, col: Color, w: float) -> void:
	var acc: float = 0.0
	var on: bool = true
	for i in range(1, pts.size()):
		if on:
			draw_line(pts[i - 1], pts[i], col, w, true)
		acc += pts[i - 1].distance_to(pts[i])
		if acc > (7.0 if on else 6.0):
			acc = 0.0
			on = not on


func _node_words(nd: Dictionary) -> String:
	return "%s %d, %s, %s%s" % [tr("Node"), int(nd.n), {"+": tr("benefit"), "-": tr("drawback"), "?": tr("condition")}.get(str(nd.polarity), ""),
		str(nd.words), (", " + tr("holds %s") % str(nd.art_name)) if str(nd.get("art_name", "")) != "" else (", " + tr("empty") if bool(nd.open) else ", " + tr("opens at level %d") % int(nd.unlock))]


# --- the figure vocabulary (crafting_diagrams.json "figure"; the same shapes as tools/design/render_diagram_draft_v2.py)

func _arcpts(c: Vector2, r: float, a0: float, a1: float, step: float = 4.0, ry: float = -1.0) -> PackedVector2Array:
	var out := PackedVector2Array()
	var a: float = a0
	var yr: float = r if ry < 0.0 else ry
	while a <= a1 + 0.01:
		out.append(_t([c.x + r * cos(deg_to_rad(a)), c.y + yr * sin(deg_to_rad(a))]))
		a += step
	return out


func _seg(a: Array, b: Array) -> PackedVector2Array:
	return PackedVector2Array([_t(a), _t(b)])


func _figure_lines(f: Dictionary) -> Array:
	var L: Array = []
	var c := Vector2(float(f.get("c", [0, 0])[0]), float(f.get("c", [0, 0])[1]))
	match str(f.shape):
		"circle":
			L.append(_arcpts(c, float(f.r), 0, 360))
		"arc":
			L.append(_arcpts(c, float(f.r), float(f.a0), float(f.a1)))
		"poly", "chevron":
			var pts := PackedVector2Array()
			for p in Array(f.points):
				pts.append(_t(p))
			if bool(f.get("closed", false)) and pts.size() > 0:
				pts.append(pts[0])
			L.append(pts)
		"wave":
			var a := Vector2(float(f.from[0]), float(f.from[1]))
			var b := Vector2(float(f.to[0]), float(f.to[1]))
			var u: Vector2 = (b - a).normalized()
			var nrm := Vector2(-u.y, u.x)
			var pts2 := PackedVector2Array()
			for i in 81:
				var t: float = i / 80.0
				var p: Vector2 = a + (b - a) * t + nrm * float(f.amp) * sin(t * float(f.waves) * TAU)
				pts2.append(_t([p.x, p.y]))
			L.append(pts2)
		"spiral":
			var pts3 := PackedVector2Array()
			for i in 161:
				var t: float = i / 160.0
				var r: float = float(f.r0) + (float(f.r1) - float(f.r0)) * t
				pts3.append(_t([c.x + r * cos(t * float(f.turns) * TAU), c.y + r * sin(t * float(f.turns) * TAU)]))
			L.append(pts3)
		"taiji":
			var r: float = float(f.r)
			L.append(_arcpts(c, r, 0, 360))
			var s := PackedVector2Array()
			for k in range(90, -91, -4):
				s.append(_t([c.x + r / 2 * cos(deg_to_rad(k)), c.y - r / 2 + r / 2 * sin(deg_to_rad(k))]))
			for k in range(270, 89, -4):
				s.append(_t([c.x + r / 2 * cos(deg_to_rad(k)), c.y + r / 2 + r / 2 * sin(deg_to_rad(k))]))
			L.append(s)
		"star":
			var n: int = int(f.n)
			var pts4 := PackedVector2Array()
			for i in n + 1:
				var ang: float = deg_to_rad(-90.0 + 360.0 * ((i * int(f.step)) % n) / n)
				pts4.append(_t([c.x + float(f.r) * cos(ang), c.y + float(f.r) * sin(ang)]))
			L.append(pts4)
		"rays":
			var a0: float = deg_to_rad(float(f.get("a0", 0)))
			var a1: float = deg_to_rad(float(f.get("a1", 360)))
			var full: bool = float(f.get("a1", 360)) - float(f.get("a0", 0)) >= 360.0
			for i in int(f.n):
				var ang: float = a0 + (a1 - a0) * i / (float(f.n) if full else maxf(float(f.n) - 1.0, 1.0))
				L.append(_seg([c.x + float(f.r0) * cos(ang), c.y + float(f.r0) * sin(ang)], [c.x + float(f.r1) * cos(ang), c.y + float(f.r1) * sin(ang)]))
		"trigrams":
			for i in 8:
				var ang: float = -PI / 2 + TAU * i / 8.0
				var px: float = c.x + float(f.r) * cos(ang)
				var py: float = c.y + float(f.r) * sin(ang)
				var tx: float = -sin(ang)
				var ty: float = cos(ang)
				for row in 3:
					var off: float = (row - 1) * 0.07
					var bx: float = px + cos(ang) * off
					var by: float = py + sin(ang) * off
					if (i >> row) & 1:
						for sg in [-1.0, 1.0]:
							L.append(_seg([bx + tx * 0.04 * sg, by + ty * 0.04 * sg], [bx + tx * 0.14 * sg, by + ty * 0.14 * sg]))
					else:
						L.append(_seg([bx - tx * 0.14, by - ty * 0.14], [bx + tx * 0.14, by + ty * 0.14]))
		"petals":
			var n2: int = int(f.n)
			for i in n2:
				var ang: float = -PI / 2 + TAU * i / n2
				var pts5 := PackedVector2Array()
				for k in range(0, 361, 6):
					var tt: float = deg_to_rad(k % 181 if k <= 180 else 360 - k)
					var side: float = float(f.w) * sin(tt) * (1.0 - absf(cos(tt))) * 0.9 * (1.0 if k <= 180 else -1.0)
					var q := Vector2(float(f.r) * sin(tt), side).rotated(ang)
					pts5.append(_t([c.x + q.x, c.y + q.y]))
				L.append(pts5)
		"wheel":
			L.append(_arcpts(c, float(f.r), 0, 360))
			L.append(_arcpts(c, float(f.r) * 0.25, 0, 360, 10))
			for i in int(f.n):
				var ang: float = TAU * i / float(f.n)
				L.append(_seg([c.x + float(f.r) * 0.25 * cos(ang), c.y + float(f.r) * 0.25 * sin(ang)], [c.x + float(f.r) * cos(ang), c.y + float(f.r) * sin(ang)]))
		"sword":
			var a := Vector2(float(f.from[0]), float(f.from[1]))
			var b := Vector2(float(f.to[0]), float(f.to[1]))
			var u: Vector2 = (b - a).normalized()
			var nn := Vector2(-u.y, u.x)
			var w: float = float(f.w)
			var hilt: Vector2 = a + (b - a) * 0.18
			for seg in [[hilt + nn * w, b - u * w * 2 + nn * w * 0.6], [b - u * w * 2 + nn * w * 0.6, b], [b, b - u * w * 2 - nn * w * 0.6],
					[b - u * w * 2 - nn * w * 0.6, hilt - nn * w], [hilt + nn * w * 2.6, hilt - nn * w * 2.6], [a, hilt]]:
				L.append(_seg([seg[0].x, seg[0].y], [seg[1].x, seg[1].y]))
		"branch":
			var a := Vector2(float(f.from[0]), float(f.from[1]))
			var b := Vector2(float(f.to[0]), float(f.to[1]))
			var stem := PackedVector2Array()
			var raw: Array = []
			for i in 41:
				var t: float = i / 40.0
				var p := Vector2(a.x + (b.x - a.x) * t + 0.15 * sin(t * 6.0), a.y + (b.y - a.y) * t)
				raw.append(p)
				stem.append(_t([p.x, p.y]))
			L.append(stem)
			for k in int(f.leaves):
				var q: Vector2 = raw[int((k + 1) * 40 / (int(f.leaves) + 1))]
				var sg: float = 1.0 if k % 2 else -1.0
				L.append(PackedVector2Array([_t([q.x, q.y]), _t([q.x + sg * 0.45, q.y - 0.15]), _t([q.x + sg * 0.2, q.y - 0.3]), _t([q.x, q.y])]))
		"zigzag":
			var a := Vector2(float(f.from[0]), float(f.from[1]))
			var b := Vector2(float(f.to[0]), float(f.to[1]))
			var nn2 := Vector2(-(b - a).normalized().y, (b - a).normalized().x)
			var pts6 := PackedVector2Array()
			for i in int(f.n) + 1:
				var k: float = 0.0 if i == 0 or i == int(f.n) else (1.0 if i % 2 else -1.0)
				var p: Vector2 = a + (b - a) * (float(i) / float(f.n)) + nn2 * float(f.amp) * k
				pts6.append(_t([p.x, p.y]))
			L.append(pts6)
		"mountains":
			var a := Vector2(float(f.from[0]), float(f.from[1]))
			var b := Vector2(float(f.to[0]), float(f.to[1]))
			var pts7 := PackedVector2Array()
			for i in int(f.n):
				var x0: float = a.x + (b.x - a.x) * i / float(f.n)
				var x1: float = a.x + (b.x - a.x) * (i + 1) / float(f.n)
				pts7.append(_t([x0, a.y]))
				pts7.append(_t([(x0 + x1) / 2, a.y - float(f.h) * (0.8 + 0.2 * (i % 2))]))
			pts7.append(_t([b.x, b.y]))
			L.append(pts7)
			L.append(_seg([a.x, a.y], [b.x, b.y]))
		"gates":
			for k in 4:
				var ang: float = PI / 2 * k
				var g := Vector2(c.x + float(f.r) * cos(ang), c.y + float(f.r) * sin(ang))
				var tv := Vector2(-sin(ang), cos(ang))
				var o := Vector2(cos(ang), sin(ang)) * 0.25
				L.append(PackedVector2Array([_t([g.x + tv.x * 0.28 + o.x, g.y + tv.y * 0.28 + o.y]), _t([g.x + tv.x * 0.28, g.y + tv.y * 0.28]),
					_t([g.x - tv.x * 0.28, g.y - tv.y * 0.28]), _t([g.x - tv.x * 0.28 + o.x, g.y - tv.y * 0.28 + o.y])]))
		"strings":
			var a := Vector2(float(f.from[0]), float(f.from[1]))
			var b := Vector2(float(f.to[0]), float(f.to[1]))
			for i in int(f.n):
				if bool(f.get("horizontal", false)):
					L.append(_seg([a.x, a.y + float(f.gap) * i], [b.x, b.y + float(f.gap) * i]))
				else:
					L.append(_seg([a.x + float(f.gap) * i, a.y], [b.x + float(f.gap) * i, b.y]))
		"flame":
			for sc2 in [1.0, 0.6]:
				var pts8 := PackedVector2Array()
				for k in range(-180, 181, 8):
					var tt: float = deg_to_rad(k)
					var r: float = float(f.r) * sc2
					pts8.append(_t([c.x + r * sin(tt) * (0.6 + 0.4 * cos(tt)), c.y - r * 1.4 * (0.5 - 0.5 * cos(tt)) + r * 0.5]))
				L.append(pts8)
		"crystal":
			for i in 6:
				var ang: float = TAU * i / 6.0 - PI / 2
				var e := Vector2(c.x + float(f.r) * cos(ang), c.y + float(f.r) * sin(ang))
				L.append(_seg([c.x, c.y], [e.x, e.y]))
				for fr in [0.45, 0.7]:
					var m := Vector2(c.x + float(f.r) * fr * cos(ang), c.y + float(f.r) * fr * sin(ang))
					for da in [0.5, -0.5]:
						L.append(_seg([m.x, m.y], [m.x + 0.25 * float(f.r) * cos(ang + da), m.y + 0.25 * float(f.r) * sin(ang + da)]))
		"net":
			for k in range(1, int(f.rings) + 1):
				L.append(_arcpts(c, float(f.r) * k / float(f.rings), 0, 360, 5))
			for i in int(f.spokes):
				var ang: float = TAU * i / float(f.spokes)
				L.append(_seg([c.x, c.y], [c.x + float(f.r) * cos(ang), c.y + float(f.r) * sin(ang)]))
		"cloud":
			for e in [[-0.5, 0.1, 0.45], [0.0, -0.2, 0.55], [0.5, 0.1, 0.45]]:
				var pts9 := PackedVector2Array()
				for k in range(0, 541, 10):
					var rr: float = float(e[2]) * float(f.r) * (1.0 - k / 900.0)
					pts9.append(_t([c.x + float(e[0]) * float(f.r) + rr * cos(deg_to_rad(k)), c.y + float(e[1]) * float(f.r) + rr * sin(deg_to_rad(k))]))
				L.append(pts9)
		"bell":
			var r: float = float(f.r)
			var prof := [[-0.25, -1.0], [-0.35, -0.6], [-0.45, 0.2], [-0.75, 0.75], [0.75, 0.75], [0.45, 0.2], [0.35, -0.6], [0.25, -1.0], [-0.25, -1.0]]
			var pts10 := PackedVector2Array()
			for q in prof:
				pts10.append(_t([c.x + q[0] * r, c.y + q[1] * r]))
			L.append(pts10)
			L.append(_seg([c.x - 0.6 * r, c.y + 0.5 * r], [c.x + 0.6 * r, c.y + 0.5 * r]))
			L.append(_arcpts(Vector2(c.x, c.y - 1.12 * r), 0.12 * r, 0, 360, 20))
		"crescent":
			var r: float = float(f.r)
			var pts11 := _arcpts(c, r, 60, 300, 5)
			var a2: float = 285.0
			while a2 >= 75.0:
				pts11.append(_t([c.x + 0.45 * r + r * 0.8 * cos(deg_to_rad(a2)), c.y + r * 0.8 * sin(deg_to_rad(a2))]))
				a2 -= 5.0
			L.append(pts11)
		"grid":
			var h: float = float(f.size) / 2.0
			for i in int(f.n) + 1:
				var v: float = -h + float(f.size) * i / float(f.n)
				L.append(_seg([c.x + v, c.y - h], [c.x + v, c.y + h]))
				L.append(_seg([c.x - h, c.y + v], [c.x + h, c.y + v]))
		"band":
			var a := Vector2(float(f.from[0]), float(f.from[1]))
			var b := Vector2(float(f.to[0]), float(f.to[1]))
			for off in [-float(f.w) / 2.0, float(f.w) / 2.0]:
				var pts12 := PackedVector2Array()
				for i in 41:
					var t: float = i / 40.0
					pts12.append(_t([a.x + (b.x - a.x) * t, a.y + (b.y - a.y) * t + float(f.sag) * 4.0 * t * (1.0 - t) + off]))
				L.append(pts12)
		"vajra":
			var ln: float = float(f.len)
			L.append(_seg([c.x, c.y - 0.15], [c.x, c.y + 0.15]))
			for sg in [-1.0, 1.0]:
				for dx in [-0.35, 0.0, 0.35]:
					L.append(PackedVector2Array([_t([c.x + dx * 0.4, c.y + sg * 0.2]), _t([c.x + dx, c.y + sg * ln * 0.3]), _t([c.x, c.y + sg * ln / 2.0])]))
			L.append(_arcpts(c, 0.25, 0, 360, 15))
		"lanterns":
			var a := Vector2(float(f.from[0]), float(f.from[1]))
			var b := Vector2(float(f.to[0]), float(f.to[1]))
			var pts13 := PackedVector2Array()
			for i in 31:
				var t: float = i / 30.0
				pts13.append(_t([a.x + (b.x - a.x) * t, a.y + (b.y - a.y) * t + 0.25 * sin(t * PI)]))
			L.append(pts13)
			for i in int(f.n):
				var t: float = (i + 0.5) / float(f.n)
				var x: float = a.x + (b.x - a.x) * t
				var y: float = a.y + (b.y - a.y) * t + 0.25 * sin(t * PI)
				L.append(_seg([x, y], [x, y + 0.15]))
				L.append(_arcpts(Vector2(x, y + 0.3), 0.12, 0, 360, 20, 0.16))
		"drill":
			var a := Vector2(float(f.from[0]), float(f.from[1]))
			var b := Vector2(float(f.to[0]), float(f.to[1]))
			var w: float = float(f.w)
			L.append(PackedVector2Array([_t([a.x, a.y - w / 2]), _t([b.x, b.y]), _t([a.x, a.y + w / 2]), _t([a.x, a.y - w / 2])]))
			var pts14 := PackedVector2Array()
			for i in 81:
				var t: float = i / 80.0
				pts14.append(_t([a.x + (b.x - a.x) * t, a.y + (w / 2) * (1 - t) * sin(t * float(f.turns) * TAU)]))
			L.append(pts14)
		"wings":
			for sg in [-1.0, 1.0]:
				for k in 3:
					var fr: float = [1.0, 0.75, 0.5][k]
					var pts15 := PackedVector2Array()
					for i in 25:
						var t: float = i / 24.0
						pts15.append(_t([c.x + sg * float(f.r) * fr * t, c.y - float(f.r) * 0.5 * fr * sin(t * PI) + 0.1 * k]))
					L.append(pts15)
		"cauldron":
			var r: float = float(f.r)
			L.append(_arcpts(c, r, 0, 180, 5, r * 0.75))
			L.append(_seg([c.x - r * 1.05, c.y], [c.x + r * 1.05, c.y]))
			for dx in [-0.6, 0.0, 0.6]:
				L.append(_seg([c.x + dx * r, c.y + r * 0.65], [c.x + dx * r * 1.15, c.y + r * 1.15]))
			for sg in [-1.0, 1.0]:
				L.append(PackedVector2Array([_t([c.x + sg * r * 0.6, c.y]), _t([c.x + sg * r * 0.65, c.y - 0.35 * r]), _t([c.x + sg * r * 0.4, c.y - 0.35 * r])]))
		"swirl":
			for k in int(f.arms):
				var ph: float = TAU * k / float(f.arms)
				var pts16 := PackedVector2Array()
				for i in 61:
					var t: float = i / 60.0
					pts16.append(_t([c.x + float(f.r) * t * cos(ph + t * 4.0), c.y + float(f.r) * t * sin(ph + t * 4.0)]))
				L.append(pts16)
	return L
