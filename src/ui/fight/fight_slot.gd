class_name FightSlot
extends Control
## A loadout icon on the fight screen (design/ux/interaction-patterns.md, Loadout icon): an art or ward slot with its
## painted icon, a cooldown fill that sweeps up as it charges, a flash when it fires, and badges (step number,
## ⚡ empowered, a dim veil when it cannot be paid). An empty slot draws a dashed frame. Display only.

## The icon, or null for an empty slot.
var icon: Texture2D = null
## 0 = just fired (dark), 1 = ready (clear); below 1 a dark veil covers the uncharged share from the top.
var charge: float = 1.0
## 0..1 strength of the fire flash (1 the instant it fires).
var flash: float = 0.0
## Badges: a step number (0 none), empowered, and whether it can be paid now.
var step: int = 0
var empowered: bool = false
var affordable: bool = true
## The frame style: "art" round-cornered, "ward" chamfered double frame (art bible 7.3), "empty" dashed.
var frame: String = "art"
## A small text badge at the bottom (uses left, or a count).
var badge: String = ""


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS
	focus_mode = Control.FOCUS_ALL


## Sets the slot size in pixels (square).
func set_px(px: int) -> void:
	custom_minimum_size = Vector2(px, px)


func _draw() -> void:
	var r := Rect2(Vector2.ZERO, size)
	if frame == "empty" or icon == null:
		draw_rect(r, Color(0.1, 0.11, 0.13))
		_dashed(r, Color(0.4, 0.4, 0.46))
		return
	draw_texture_rect(icon, r.grow(-2), false)
	if charge < 1.0:
		var h: float = (size.y - 4.0) * (1.0 - clampf(charge, 0.0, 1.0))
		draw_rect(Rect2(Vector2(2, 2), Vector2(size.x - 4, h)), Color(0, 0, 0, 0.62))
		draw_line(Vector2(2, 2 + h), Vector2(size.x - 2, 2 + h), Color(1, 1, 1, 0.55), 1.0)
	if not affordable:
		draw_rect(r.grow(-2), Color(0.05, 0.05, 0.1, 0.55))
	var edge := Color(0.55, 0.56, 0.62)
	if frame == "ward":
		_chamfer(r, edge)
		_chamfer(r.grow(-3), edge.darkened(0.3))
	else:
		draw_rect(r, edge, false, 1.5)
	if flash > 0.0:
		draw_rect(r.grow(1), Color(1.0, 0.95, 0.7, flash), false, 3.0)
		draw_rect(r.grow(-2), Color(1.0, 0.95, 0.7, flash * 0.35))
	if has_focus():
		draw_rect(r.grow(2), Color(1, 1, 1), false, 2.0)
	var font: Font = get_theme_default_font()
	if step > 0:
		_badge(font, Vector2(3, 3), str(step), Color(0.2, 0.45, 0.9))
	if empowered:
		_badge(font, Vector2(size.x - 17, 3), "⚡", Color(0.85, 0.6, 0.1))
	if badge != "":
		_badge(font, Vector2(size.x - 6 - font.get_string_size(badge, HORIZONTAL_ALIGNMENT_LEFT, -1, 13).x, size.y - 18), badge, Color(0.15, 0.15, 0.18))


func _badge(font: Font, at: Vector2, text: String, bg: Color) -> void:
	var w: float = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 13).x + 6.0
	draw_rect(Rect2(at, Vector2(w, 15)), bg)
	draw_string(font, at + Vector2(3, 12), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(1, 1, 1))


func _chamfer(r: Rect2, c: Color) -> void:
	var k: float = 6.0
	var p := PackedVector2Array([r.position + Vector2(k, 0), Vector2(r.end.x - k, r.position.y), Vector2(r.end.x, r.position.y + k),
		Vector2(r.end.x, r.end.y - k), Vector2(r.end.x - k, r.end.y), Vector2(r.position.x + k, r.end.y),
		Vector2(r.position.x, r.end.y - k), Vector2(r.position.x, r.position.y + k), r.position + Vector2(k, 0)])
	draw_polyline(p, c, 1.5)


func _dashed(r: Rect2, c: Color) -> void:
	var pts := [r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y), r.position]
	for i in 4:
		var a: Vector2 = pts[i]
		var b: Vector2 = pts[i + 1]
		var n: int = int(a.distance_to(b) / 6.0)
		for j in range(0, n, 2):
			draw_line(a.lerp(b, float(j) / n), a.lerp(b, float(j + 1) / n), c, 1.0)
