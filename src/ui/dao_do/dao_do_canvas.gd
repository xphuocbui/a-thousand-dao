class_name DaoDoCanvas
extends Control
## The Đạo Đồ canvas (design/ux/dao-do-view.md; interaction-patterns.md Tree view), drawn like Path of Exile's passive
## tree (user 2026-11-24: "It should be like PoE's skill tree. Please add with icon, and hovering over it gives the
## stat"): a dark navy ground, every node its painted icon in its frame (the v5 viewer artifact's icons, built by
## tools/asset-pipeline/icons/game_icons_dao_do.py into assets/icons/dao_do/game/), unallocated nodes dimmed, allocated
## ones bright with gold lines between them, the reachable ones lit a little, the plan and the hovered route as pale
## lines, search matches pulsing. Far out (below [member icons_from] px per unit) the icons give way to dots in the
## nodes' stat-family colours. Godot draws it as one Control (8,051 nodes would be far too many Controls) and skips what
## is off screen. It reads only the static map (DaoDoTree), the icon sheet and the state the screen gives it.

## The pointer is over a node (-1 when over none); [param at] is the pointer in canvas coordinates.
signal hovered(node_id: int, at: Vector2)
## A node was clicked.
signal selected(node_id: int)

## Colours by role (ui_windows.json dao_do.colours).
var colours: Dictionary = {}
## The stat family table ({family: [stat keys]}) for the far-zoom dots.
var families: Dictionary = {}
## The icon diameter in map units by frame (the viewer's ICON_D, drawn at 85 %).
var icon_d: Dictionary = {"road": 0.53, "small": 0.68, "notable": 1.02, "capability": 1.15, "keystone": 1.62, "start": 1.79}
## Below this zoom (px per map unit) the icons give way to dots.
var icons_from: float = 9.0
## Reduced motion: matches are ringed without pulsing.
var reduced_motion: bool = false

const DEFAULTS := {"map": "#070a12", "map_glow": "#141b2c", "line": "#3a3226", "line_open": "#e3b860", "line_plan": "#9fd3ff",
	"line_route": "#cfe6ff", "dot": "#5a5244", "notable": "#deb25c", "key": "#e15f50", "start": "#f0f0f0", "chaos": "#9b6bff",
	"match": "#5fd0b4", "ring_frontier": "#e8d9a8", "fam_offence": "#ff7a59", "fam_defence": "#6aa9ff", "fam_sustain": "#63d68f",
	"fam_cultivation": "#c792ea", "fam_craft": "#e6c55a"}
## Brightness of a node's icon by state (PoE: unallocated nodes are dark).
const DIM := {"open": 1.0, "planned": 0.95, "frontier": 0.78, "rest": 0.55}

var _ids := PackedInt32Array()
var _pos := PackedVector2Array()
var _kind: Array = []
var _cluster := PackedInt32Array()
var _gated := PackedByteArray()
var _index: Dictionary = {}
var _nbrs: Dictionary = {}
var _fam_of_cluster: Dictionary = {}
var _edges := PackedVector2Array()
var _edge_ids := PackedInt32Array()    # pairs of node ids, parallel to _edges
var _bounds := Rect2()
var _centre := Vector2.ZERO
var _scale: float = 2.0
var _fitted: bool = false
var _pending_centre: Array = []
var _open: Dictionary = {}
var _frontier: Dictionary = {}
var _planned: Dictionary = {}
var _matches: Dictionary = {}
var _route: Dictionary = {}
var _sel: int = -1
var _hover: int = -1
var _drag_from := Vector2.INF
var _dragging: bool = false
var _pulse: float = 0.0
var _icon: Dictionary = {}             # node id -> [sheet index, Rect2 region, frame, tint]
var _sheets: Array = []                # Texture2D per sheet (mipmapped)
var _hole: Dictionary = {}
## How many redraws ran (tests: it redraws only on a change).
var draws: int = 0
## Nodes drawn in the last redraw (tests: off-screen nodes are skipped).
var drawn_nodes: int = 0
## Icons drawn in the last redraw.
var drawn_icons: int = 0


func _init() -> void:
	clip_contents = true
	focus_mode = Control.FOCUS_ALL
	mouse_filter = Control.MOUSE_FILTER_STOP
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	accessibility_name = tr("The Đạo Đồ: hover a mark for its stats; search finds marks by name or stat")


func _ready() -> void:
	set_process(not _matches.is_empty() and not reduced_motion)   # only the search pulse animates (Godot enables _process at ready)


## Loads the map from [param tree] (static data).
func setup(tree: DaoDoTree) -> void:
	_ids.clear()
	_pos.clear()
	_kind.clear()
	_cluster.clear()
	_gated.clear()
	_index.clear()
	_nbrs.clear()
	_fam_of_cluster.clear()
	_edges.clear()
	_edge_ids.clear()
	var ids: Array = tree.nodes.keys()
	ids.sort()
	for id in ids:
		var nd: Dictionary = tree.nodes[id]
		_index[int(id)] = _ids.size()
		_ids.append(int(id))
		_pos.append(Vector2(float(nd.get("x", 0.0)), float(nd.get("y", 0.0))))
		_kind.append(str(nd.get("kind", "small")))
		_cluster.append(int(nd.get("cluster", -1)))
		_gated.append(1 if bool(nd.get("gated", false)) else 0)
		_nbrs[int(id)] = tree.neighbors(int(id))
	var counts: Dictionary = {}   # the far-zoom dots' colour: the stat family most of a cluster's stats belong to
	for id in ids:
		var nd2: Dictionary = tree.nodes[id]
		var cl: int = int(nd2.get("cluster", -1))
		if cl < 0 or str(nd2.get("kind", "")) == "road":
			continue
		if not counts.has(cl):
			counts[cl] = {}
		for m in Array(nd2.get("mods", [])):
			var f: String = _family_of(str(m.get("stat", "")))
			counts[cl][f] = int(counts[cl].get(f, 0)) + 1
	for cl in counts:
		var best: String = ""
		for f in counts[cl]:
			if best == "" or int(counts[cl][f]) > int(counts[cl][best]):
				best = str(f)
		if best != "":
			_fam_of_cluster[cl] = best
	for id in ids:
		for nb in _nbrs[int(id)]:
			if int(nb) > int(id) and _index.has(int(nb)):
				_edges.append(_pos[_index[int(id)]])
				_edges.append(_pos[_index[int(nb)]])
				_edge_ids.append(int(id))
				_edge_ids.append(int(nb))
	if not _pos.is_empty():
		var r := Rect2(_pos[0], Vector2.ZERO)
		for p in _pos:
			r = r.expand(p)
		_bounds = r
	_fitted = false
	fit()


## Loads the icon sheet index [param json_path] (assets/icons/dao_do/game/icons.json) and its sheets, mipmapped so the
## icons stay smooth at every zoom. Returns the number of nodes with an icon.
func load_icons(json_path: String) -> int:
	_icon.clear()
	_sheets.clear()
	if not FileAccess.file_exists(json_path):
		return 0
	var d: Variant = JSON.parse_string(FileAccess.get_file_as_string(json_path))
	if not (d is Dictionary):
		return 0
	var dir: String = json_path.get_base_dir()
	for sh in Array(d.get("sheets", [])):
		var tex: Texture2D = load(dir.path_join(str(sh[0])))
		if tex == null:
			_sheets.append(null)
			continue
		var img: Image = tex.get_image()
		if img != null and not img.has_mipmaps():
			if img.is_compressed():
				img.decompress()
			img.generate_mipmaps()
			tex = ImageTexture.create_from_image(img)
		_sheets.append(tex)
	_hole = d.get("hole", {})
	var atlas: Dictionary = d.get("atlas", {})
	var n: int = 0
	for nid in d.get("n", {}):
		var e: Array = d.n[nid]
		var a: Array = atlas.get(str(e[0]), [])
		if a.size() < 4:
			continue
		_icon[int(nid)] = [int(a[0]), Rect2(float(a[1]), float(a[2]), float(a[3]), float(a[3])), str(e[1]), Color.from_string(str(e[2]), Color.WHITE)]
		n += 1
	queue_redraw()
	return n


## The number of nodes loaded.
func node_count() -> int:
	return _ids.size()


## The family of cluster [param cl] ("" when none), for tests.
func family_of_cluster(cl: int) -> String:
	return str(_fam_of_cluster.get(cl, ""))


## Sets the player's state: [param open], [param frontier] and [param planned] node ids.
func set_state(open: Array, frontier: Array, planned: Array) -> void:
	_open = _set_of(open)
	_frontier = _set_of(frontier)
	_planned = _set_of(planned)
	queue_redraw()


## Marks the search matches (pulsing rings; still rings under reduced motion).
func set_matches(ids: Array) -> void:
	_matches = _set_of(ids)
	set_process(not _matches.is_empty() and not reduced_motion)
	queue_redraw()


## Draws [param ids] as the hovered route preview.
func set_route(ids: Array) -> void:
	_route = _set_of(ids)
	queue_redraw()


## Selects [param id] (-1 for none).
func select(id: int) -> void:
	_sel = id
	queue_redraw()


## The whole tree in view.
func fit() -> void:
	_centre = _bounds.get_center()
	if _bounds.size == Vector2.ZERO or size == Vector2.ZERO:
		return
	_scale = minf(size.x / _bounds.size.x, size.y / _bounds.size.y) * 0.95
	_fitted = true
	queue_redraw()


## Centres on node [param id] at at least [param min_scale] px per unit.
func centre_on(id: int, min_scale: float = 18.0) -> void:
	if not _index.has(id):
		return
	_centre = _pos[_index[id]]
	_scale = maxf(_scale, min_scale)
	_fitted = true
	queue_redraw()


## Centres on the middle of [param ids] at [param at_scale] px per unit (at the first layout when not laid out yet).
func centre_on_set(ids: Array, at_scale: float = 18.0) -> void:
	if size == Vector2.ZERO:
		_pending_centre = [ids.duplicate(), at_scale]
		return
	var sum := Vector2.ZERO
	var n: int = 0
	for id in ids:
		if _index.has(int(id)):
			sum += _pos[_index[int(id)]]
			n += 1
	if n > 0:
		_centre = sum / float(n)
		_scale = at_scale
		_fitted = true
		queue_redraw()


## Zooms by [param f] about [param at] (a screen point; the centre when INF).
func zoom_by(f: float, at: Vector2 = Vector2.INF) -> void:
	var p: Vector2 = size * 0.5 if at == Vector2.INF else at
	var before: Vector2 = to_world(p)
	_scale = clampf(_scale * f, 0.5, 140.0)
	_centre += before - to_world(p)
	queue_redraw()


## Pans by [param d] screen pixels.
func pan(d: Vector2) -> void:
	_centre -= d / _scale
	queue_redraw()


## The px per map unit.
func scale_px() -> float:
	return _scale


func to_screen(w: Vector2) -> Vector2:
	return (w - _centre) * _scale + size * 0.5


func to_world(s: Vector2) -> Vector2:
	return (s - size * 0.5) / _scale + _centre


## Node [param id]'s framed icon at its full sheet size, for the hover card (user 2026-11-24: on the tree the icons
## are 30-60 px, too small for the painting to read; the card shows it at its own size). null without an icon.
func icon_texture(id: int) -> Texture2D:
	if not _icon.has(id) or int(_icon[id][0]) >= _sheets.size() or _sheets[int(_icon[id][0])] == null:
		return null
	var t := AtlasTexture.new()
	t.atlas = _sheets[int(_icon[id][0])]
	t.region = _icon[id][1]
	return t


## The screen position of node [param id] (for the hover card).
func screen_pos_of(id: int) -> Vector2:
	return to_screen(_pos[_index[id]]) if _index.has(id) else Vector2.ZERO


## The node under screen point [param p] (within its icon, or [param slop] px of its dot), or -1.
func node_at(p: Vector2, slop: float = 7.0) -> int:
	var w: Vector2 = to_world(p)
	var best: int = -1
	var best_d: float = INF
	var icons_on: bool = _scale >= icons_from and not _sheets.is_empty()
	for i in _ids.size():
		var r: float = maxf(slop / _scale, _icon_d(_ids[i], _kind[i]) * 0.5 if icons_on else 0.0)
		var d: float = _pos[i].distance_squared_to(w)
		if d <= r * r and d < best_d:
			best_d = d
			best = _ids[i]
	return best


func _process(delta: float) -> void:
	_pulse = fmod(_pulse + delta, 1.0)
	queue_redraw()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		if not _pending_centre.is_empty() and size != Vector2.ZERO:
			var pc: Array = _pending_centre
			_pending_centre = []
			centre_on_set(pc[0], pc[1])
		elif not _fitted:
			fit()
	elif what == NOTIFICATION_MOUSE_EXIT:
		if _hover != -1:
			_hover = -1
			queue_redraw()
		hovered.emit(-1, Vector2.ZERO)


func _draw() -> void:
	draws += 1
	drawn_nodes = 0
	drawn_icons = 0
	# the ground: PoE's dark navy, a soft glow towards the middle
	draw_rect(Rect2(Vector2.ZERO, size), _c("map"))
	var glow_c: Vector2 = to_screen(_bounds.get_center())
	var glow_r: float = _bounds.size.length() * 0.5 * _scale
	for k in 6:
		draw_circle(glow_c, glow_r * (1.0 - k * 0.15), Color(_c("map_glow"), 0.10))
	var view := Rect2(to_world(Vector2.ZERO), size / _scale).grow(2.0)
	var icons_on: bool = _scale >= icons_from and not _sheets.is_empty()
	# lines: unallocated dark bronze; allocated gold with a glow; the plan and the hovered route pale blue
	var base := PackedVector2Array()
	var gold := PackedVector2Array()
	var plan := PackedVector2Array()
	var route := PackedVector2Array()
	for i in range(0, _edges.size(), 2):
		var a: Vector2 = _edges[i]
		var b: Vector2 = _edges[i + 1]
		if not (view.has_point(a) or view.has_point(b)):
			continue
		var ia: int = _edge_ids[i]
		var ib: int = _edge_ids[i + 1]
		var sa: Vector2 = to_screen(a)
		var sb: Vector2 = to_screen(b)
		var oa: bool = _open.has(ia)
		var ob: bool = _open.has(ib)
		if oa and ob:
			gold.append(sa)
			gold.append(sb)
		elif (_planned.has(ia) or oa) and (_planned.has(ib) or ob):
			plan.append(sa)
			plan.append(sb)
		elif (_route.has(ia) or _route.has(ib)) and (_route.has(ia) or oa or _planned.has(ia)) and (_route.has(ib) or ob or _planned.has(ib)):
			route.append(sa)
			route.append(sb)
		else:
			base.append(sa)
			base.append(sb)
	if not base.is_empty():
		draw_multiline(base, _c("line"), maxf(1.0, _scale * 0.12))
	if not route.is_empty():
		draw_multiline(route, _c("line_route"), maxf(1.5, _scale * 0.16))
	if not plan.is_empty():
		draw_multiline(plan, _c("line_plan"), maxf(1.5, _scale * 0.18))
	if not gold.is_empty():
		draw_multiline(gold, Color(_c("line_open"), 0.35), maxf(3.0, _scale * 0.42))
		draw_multiline(gold, _c("line_open"), maxf(1.5, _scale * 0.18))
	for i in _ids.size():
		var p: Vector2 = _pos[i]
		if not view.has_point(p):
			continue
		drawn_nodes += 1
		var id: int = _ids[i]
		var k: String = _kind[i]
		var sp: Vector2 = to_screen(p)
		var state: String = "open" if _open.has(id) else ("planned" if _planned.has(id) or _route.has(id) else ("frontier" if _frontier.has(id) else "rest"))
		var bright: float = float(DIM[state])
		if icons_on and _icon.has(id):
			var ic: Array = _icon[id]
			var dpx: float = _icon_d(id, k) * _scale
			var tex: Texture2D = _sheets[int(ic[0])]
			if tex != null:
				var mod := Color(bright, bright, bright)
				if _gated[i] == 1 and state != "open":
					mod = Color(0.62, 0.5, 0.85) * bright   # the Chaos land, locked: violet
				draw_texture_rect_region(tex, Rect2(sp - Vector2(dpx, dpx) * 0.5, Vector2(dpx, dpx)), ic[1], mod)
				drawn_icons += 1
				# the enamel ring in the land's colour, inside the frame (the viewer's ring)
				var hole: float = float(_hole.get(str(ic[2]), 0.3))
				draw_arc(sp, (hole + 0.007) * dpx, 0.0, TAU, 28, Color(ic[3], 0.85 * bright), maxf(1.0, 0.012 * dpx))
		else:
			var r: float = maxf(1.2, _dot_r(k) * _scale)
			var col: Color = _dot_colour(i, k)
			draw_circle(sp, r, col if state != "rest" else col.darkened(0.45))
			if _gated[i] == 1 and state != "open":
				draw_circle(sp, r, Color(_c("chaos"), 0.5))
		var rr: float = (_icon_d(id, k) * 0.5 if icons_on else _dot_r(k)) * _scale
		if state == "frontier":
			draw_arc(sp, rr + maxf(1.0, _scale * 0.05), 0.0, TAU, 28, Color(_c("ring_frontier"), 0.7), maxf(1.0, _scale * 0.04))
		if _matches.has(id):
			var a2: float = 1.0 if reduced_motion else 0.35 + 0.65 * absf(sin(_pulse * PI))
			draw_arc(sp, rr + maxf(3.0, _scale * 0.15), 0.0, TAU, 28, Color(_c("match"), a2), maxf(1.5, _scale * 0.08))
		if id == _sel or id == _hover:
			draw_arc(sp, rr + maxf(2.0, _scale * 0.08), 0.0, TAU, 28, Color(1, 1, 1, 0.9 if id == _sel else 0.6), 2.0)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_WHEEL_UP and mb.pressed:
			zoom_by(1.2, mb.position)
			accept_event()
		elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN and mb.pressed:
			zoom_by(1.0 / 1.2, mb.position)
			accept_event()
		elif mb.button_index == MOUSE_BUTTON_LEFT:
			if mb.pressed:
				_drag_from = mb.position
				_dragging = false
			else:
				if not _dragging:
					var id: int = node_at(mb.position)
					select(id)
					selected.emit(id)
				_drag_from = Vector2.INF
			grab_focus()
			accept_event()
	elif event is InputEventMouseMotion:
		var mm := event as InputEventMouseMotion
		if _drag_from != Vector2.INF and (mm.button_mask & MOUSE_BUTTON_MASK_LEFT) != 0:
			if _dragging or mm.position.distance_to(_drag_from) > 4.0:
				_dragging = true
				pan(mm.relative)
				hovered.emit(-1, mm.position)
		else:
			var h: int = node_at(mm.position)
			if h != _hover:
				_hover = h
				queue_redraw()
			hovered.emit(h, mm.position)


func _icon_d(id: int, k: String) -> float:
	var fk: String = str(_icon[id][2]) if _icon.has(id) else k
	return float(icon_d.get(fk, 0.68))


func _dot_r(k: String) -> float:
	return float({"start": 0.9, "road": 0.28, "small": 0.34, "notable": 0.55, "keystone": 0.8}.get(k, 0.34))


func _dot_colour(i: int, k: String) -> Color:
	match k:
		"notable":
			return _c("notable")
		"keystone":
			return _c("key")
		"start":
			return _c("start")
		"small":
			return _c("fam_" + str(_fam_of_cluster[_cluster[i]])) if _fam_of_cluster.has(_cluster[i]) else _c("dot")
	return _c("dot")


func _family_of(stat: String) -> String:
	for f in families:
		if Array(families[f]).has(stat):
			return str(f)
	return "craft"


func _c(role: String) -> Color:
	return Color.from_string(str(colours.get(role, DEFAULTS.get(role, "#ff00ff"))), Color.MAGENTA)


static func _set_of(ids: Array) -> Dictionary:
	var d: Dictionary = {}
	for i in ids:
		d[int(i)] = true
	return d
