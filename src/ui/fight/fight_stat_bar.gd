class_name FightStatBar
extends Control
## A fight-screen stat bar (design/ux/interaction-patterns.md, Stat bar): a filled bar with its name and numbers drawn
## inside, an optional locked (reserved) segment at the far end, and a mirrored fill for the foe's column so both
## columns fill from the outside in. Display only: the fight screen sets [member value], [member max_value] and
## [member reserved] from the recorded fight.

## The bar's name ("Health", "Linh lực").
var title: String = ""
## Current and maximum value.
var value: float = 0.0
var max_value: float = 1.0
## The locked share of [member max_value] drawn as a hatched segment at the far end (reserved linh lực).
var reserved: float = 0.0
## Fill colour.
var fill: Color = Color(0.75, 0.25, 0.25)
## True fills from the right (the foe's column).
var mirrored: bool = false
## Optional words after the numbers ("loadout only: not recorded").
var note: String = ""


func _init() -> void:
	custom_minimum_size = Vector2(0, 22)
	mouse_filter = Control.MOUSE_FILTER_PASS


## Sets the readings and redraws.
func set_reading(v: float, mx: float, res: float = 0.0) -> void:
	value = maxf(0.0, v)
	max_value = maxf(1.0, mx)
	reserved = clampf(res, 0.0, max_value)
	queue_redraw()


func _draw() -> void:
	var r := Rect2(Vector2.ZERO, size)
	draw_rect(r, Color(0.13, 0.14, 0.17))
	var share: float = clampf(value / max_value, 0.0, 1.0)
	var w: float = size.x * share
	var fr := Rect2(Vector2(size.x - w if mirrored else 0.0, 0.0), Vector2(w, size.y))
	draw_rect(fr, fill)
	if reserved > 0.0:
		var rw: float = size.x * reserved / max_value
		var rr := Rect2(Vector2(0.0 if mirrored else size.x - rw, 0.0), Vector2(rw, size.y))
		draw_rect(rr, Color(0.25, 0.25, 0.3))
		var x: float = rr.position.x
		while x < rr.end.x:   # hatching: the reserved share is locked, not empty
			draw_line(Vector2(x, size.y), Vector2(minf(x + size.y, rr.end.x), 0.0), Color(0.5, 0.5, 0.6), 1.0)
			x += 6.0
	draw_rect(r, Color(0.35, 0.36, 0.42), false, 1.0)
	var font: Font = get_theme_default_font()
	var fs: int = 14
	var text: String = "%s  %s / %s%s" % [title, HudReadouts.stones_text(value), HudReadouts.stones_text(max_value),
		("   " + note) if note != "" else ""]
	var tw: float = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	var tx: float = size.x - tw - 6.0 if mirrored else 6.0
	var ty: float = (size.y + font.get_ascent(fs) - font.get_descent(fs)) * 0.5
	draw_string(font, Vector2(tx + 1, ty + 1), text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(0, 0, 0, 0.8))
	draw_string(font, Vector2(tx, ty), text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(0.95, 0.95, 0.95))
