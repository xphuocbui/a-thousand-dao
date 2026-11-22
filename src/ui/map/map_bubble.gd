class_name MapBubble
extends Button
## One map bubble (design/ux/hud.md, elements 30-32): a real button, so a click, Tab and Enter, or a gamepad press all
## work and it can carry a tooltip. Each kind has its own shape, never colour alone; area bubbles carry a count; a lock
## mark shows while a blocking event locks what the bubble's window would change.

## "player", "abode", or an area kind from BubbleModel.KINDS.
var kind: String = ""
## The place the bubble belongs to.
var place_id: String = ""
## The count shown on an area bubble (0 hides it).
var count: int = 0
## True while a blocking event locks this bubble's changing actions.
var locked: bool = false
## The place tile the bubble sits by (the map positions it).
var tile := Vector2i.ZERO
## Offset from the tile's screen position, for a place's cluster.
var cluster_offset := Vector2.ZERO


func _init() -> void:
	flat = true
	focus_mode = Control.FOCUS_ALL
	custom_minimum_size = Vector2(28, 28)
	size = Vector2(28, 28)


## Sets the bubble's content and its tooltip (which doubles as its spoken name).
func setup(kind_v: String, place_id_v: String, count_v: int, tooltip: String) -> void:
	kind = kind_v
	place_id = place_id_v
	count = count_v
	tooltip_text = tooltip
	if kind == "player":
		custom_minimum_size = Vector2(32, 32)
		size = Vector2(32, 32)
	queue_redraw()


func _draw() -> void:
	var c := size * 0.5
	var r: float = minf(size.x, size.y) * 0.5 - 1.0
	var ring := Color(0.95, 0.9, 0.75) if has_focus() or is_hovered() else Color(0.15, 0.15, 0.18)
	match kind:
		"player":
			draw_circle(c, r, ring)
			draw_circle(c, r - 2.0, Color(0.55, 0.22, 0.22))
			# a simple face-and-shoulders mark standing in for the portrait
			draw_circle(c + Vector2(0, -4), 5.0, Color(0.95, 0.85, 0.75))
			draw_rect(Rect2(c + Vector2(-7, 2), Vector2(14, 7)), Color(0.95, 0.85, 0.75))
			return
		"abode":
			var roof := PackedVector2Array([c + Vector2(-11, -1), c + Vector2(0, -11), c + Vector2(11, -1)])
			draw_colored_polygon(roof, Color(0.75, 0.35, 0.25))
			draw_rect(Rect2(c + Vector2(-8, -1), Vector2(16, 11)), Color(0.9, 0.85, 0.7))
			draw_rect(Rect2(c + Vector2(-2, 3), Vector2(4, 7)), Color(0.35, 0.25, 0.2))
			draw_polyline(PackedVector2Array([c + Vector2(-11, -1), c + Vector2(0, -11), c + Vector2(11, -1)]), ring, 1.5)
			return
	draw_circle(c, r, ring)
	draw_circle(c, r - 1.5, Color(0.16, 0.17, 0.21))
	var ink := Color(0.95, 0.88, 0.6)
	match kind:
		"market":   # a coin with a square hole
			draw_circle(c, 7.0, ink)
			draw_rect(Rect2(c - Vector2(2.5, 2.5), Vector2(5, 5)), Color(0.16, 0.17, 0.21))
		"sect":   # a pagoda: two roofs over a pillar
			draw_colored_polygon(PackedVector2Array([c + Vector2(-8, -1), c + Vector2(0, -7), c + Vector2(8, -1)]), ink)
			draw_colored_polygon(PackedVector2Array([c + Vector2(-6, 4), c + Vector2(0, -1), c + Vector2(6, 4)]), ink)
			draw_rect(Rect2(c + Vector2(-1.5, 4), Vector2(3, 5)), ink)
		"work":   # a scroll
			draw_rect(Rect2(c + Vector2(-6, -5), Vector2(12, 10)), ink)
			draw_line(c + Vector2(-8, -5), c + Vector2(8, -5), ink, 2.0)
			draw_line(c + Vector2(-8, 5), c + Vector2(8, 5), ink, 2.0)
		"people":   # two heads
			draw_circle(c + Vector2(-4, -2), 3.5, ink)
			draw_circle(c + Vector2(4, -2), 3.5, ink)
			draw_rect(Rect2(c + Vector2(-8, 2), Vector2(16, 5)), ink)
		"explore":   # a mountain
			draw_colored_polygon(PackedVector2Array([c + Vector2(-9, 7), c + Vector2(-2, -6), c + Vector2(2, 0), c + Vector2(5, -3), c + Vector2(9, 7)]), ink)
	if count > 1:
		var f: Font = get_theme_default_font()
		draw_circle(c + Vector2(9, -9), 7.0, Color(0.8, 0.25, 0.2))
		draw_string(f, c + Vector2(5.5, -5), str(count), HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color.WHITE)
	if locked:   # a small padlock
		draw_rect(Rect2(c + Vector2(5, 4), Vector2(8, 6)), Color(0.9, 0.75, 0.3))
		draw_arc(c + Vector2(9, 4), 3.0, PI, TAU, 8, Color(0.9, 0.75, 0.3), 1.5)


func _notification(what: int) -> void:
	if what == NOTIFICATION_FOCUS_ENTER or what == NOTIFICATION_FOCUS_EXIT or what == NOTIFICATION_MOUSE_ENTER or what == NOTIFICATION_MOUSE_EXIT:
		queue_redraw()
