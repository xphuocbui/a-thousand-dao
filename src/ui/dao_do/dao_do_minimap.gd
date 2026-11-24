class_name DaoDoMinimap
extends Control
## The Đạo Đồ minimap (weak-point review 2026-11-24 #11: "no orientation"): the whole tree in a corner plate, every
## mark a faint dot, the opened marks gold, the planned route blue, and the canvas's view as a brass frame. Click or
## drag on it to move the view there. Reads the canvas through its accessors only; never changes the plan.

## The canvas it shows and moves.
var canvas: DaoDoCanvas = null

var _tex: ImageTexture = null
var _baked_for := Vector2.ZERO
var _key := Vector4.INF
var _scale: float = 1.0
var _off := Vector2.ZERO
var _origin := Vector2.ZERO

const PAD := 8.0
const DOT := Color(0.78, 0.71, 0.56, 0.5)
const OPEN := Color("#e3b860")
const PLAN := Color("#9fd3ff")


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_NONE   # a mouse aid: the keyboard has Whole tree and My marks
	accessibility_name = tr("Đạo Đồ minimap")
	TooltipLayer.set_tip(self, {"title": tr("Minimap"), "summary": tr("The whole Đạo Đồ: gold your marks, blue your plan, the frame what you see. Click or drag to move the view.")})


func _process(_d: float) -> void:
	if canvas == null or not is_visible_in_tree():
		return
	var k: Vector4 = canvas.view_key()
	k.w += float(canvas.open_count() * 7919 + canvas.planned_count())
	if k != _key or size != _baked_for:
		_key = k
		queue_redraw()


# The faint dots of every mark, painted once into a texture at this control's size.
func _bake() -> void:
	var b: Rect2 = canvas.world_bounds()
	if b.size.x <= 0.0 or b.size.y <= 0.0 or size.x < 20.0 or size.y < 20.0:
		return
	_scale = minf((size.x - PAD * 2.0) / b.size.x, (size.y - PAD * 2.0) / b.size.y)
	_origin = b.position
	_off = (size - b.size * _scale) * 0.5
	var img := Image.create(int(size.x), int(size.y), false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for p in canvas.node_positions():
		var q: Vector2 = _to_mini(p)
		var x: int = clampi(int(q.x), 0, img.get_width() - 1)
		var y: int = clampi(int(q.y), 0, img.get_height() - 1)
		img.set_pixel(x, y, DOT)
	_tex = ImageTexture.create_from_image(img)
	_baked_for = size


func _to_mini(w: Vector2) -> Vector2:
	return (w - _origin) * _scale + _off


func _to_world(m: Vector2) -> Vector2:
	return (m - _off) / maxf(_scale, 1e-6) + _origin


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.03, 0.03, 0.05, 0.88))
	draw_rect(Rect2(Vector2.ZERO, size), Color("#8a6d3b"), false, 1.5)
	if canvas == null:
		return
	if size != _baked_for:
		_bake()
	if _tex != null:
		draw_texture(_tex, Vector2.ZERO)
	for w in canvas.planned_positions():
		draw_rect(Rect2(_to_mini(w) - Vector2(1.5, 1.5), Vector2(3, 3)), PLAN)
	for w in canvas.open_positions():
		draw_rect(Rect2(_to_mini(w) - Vector2(1.5, 1.5), Vector2(3, 3)), OPEN)
	var vr: Rect2 = canvas.view_world_rect()
	var r := Rect2(_to_mini(vr.position), vr.size * _scale).intersection(Rect2(Vector2.ONE, size - Vector2(2, 2)))
	if r.size.x > 0.0 and r.size.y > 0.0:
		draw_rect(r, Color(0.89, 0.72, 0.38, 0.95), false, 1.5)


func _gui_input(event: InputEvent) -> void:
	if canvas == null:
		return
	var press: bool = event is InputEventMouseButton and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT and event.is_pressed()
	var drag: bool = event is InputEventMouseMotion and ((event as InputEventMouseMotion).button_mask & MOUSE_BUTTON_MASK_LEFT) != 0
	if press or drag:
		canvas.centre_at(_to_world((event as InputEventMouse).position))
		accept_event()


## The world point a minimap point [param m] stands for (for tests).
func world_at(m: Vector2) -> Vector2:
	if size != _baked_for and canvas != null:
		_bake()
	return _to_world(m)
