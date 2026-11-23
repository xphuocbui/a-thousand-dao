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
## True draws the fill hatched (ward shields, art bible Section 4).
var hatched: bool = false


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
	var outer := Rect2(Vector2.ZERO, size)
	var trough: StyleBox = get_theme_stylebox(&"trough", &"FightStatBar") if has_theme_stylebox(&"trough", &"FightStatBar") else null
	if trough != null:   # the recessed brass trough (art bible 7.12); the fill sits inside its rim
		draw_style_box(trough, outer)
	else:
		draw_rect(outer, Color(0.13, 0.14, 0.17))
	var r: Rect2 = outer.grow(-3.0) if trough != null else outer
	var share: float = clampf(value / max_value, 0.0, 1.0)
	var w: float = r.size.x * share
	var fr := Rect2(Vector2(r.end.x - w if mirrored else r.position.x, r.position.y), Vector2(w, r.size.y))
	draw_rect(fr, fill)
	draw_rect(Rect2(fr.position, Vector2(fr.size.x, maxf(1.0, fr.size.y * 0.3))), Color(1, 1, 1, 0.12))   # a soft top light
	if hatched and w > 0.0:   # ward shields are hatched, so they never read as linh lực (art bible Section 4)
		var hx: float = fr.position.x
		while hx < fr.end.x:
			draw_line(Vector2(hx, fr.end.y), Vector2(minf(hx + fr.size.y, fr.end.x), fr.position.y), Color(1, 1, 1, 0.35), 1.0)
			hx += 5.0
	if reserved > 0.0:
		var rw: float = r.size.x * reserved / max_value
		var rr := Rect2(Vector2(r.position.x if mirrored else r.end.x - rw, r.position.y), Vector2(rw, r.size.y))
		draw_rect(rr, Color(0.25, 0.25, 0.3))
		var x: float = rr.position.x
		while x < rr.end.x:   # hatching: the reserved share is locked, not empty
			draw_line(Vector2(x, rr.end.y), Vector2(minf(x + rr.size.y, rr.end.x), rr.position.y), Color(0.5, 0.5, 0.6), 1.0)
			x += 6.0
	if trough == null:
		draw_rect(outer, Color(0.35, 0.36, 0.42), false, 1.0)
	var font: Font = get_theme_default_font()
	var fs: int = 14
	var text: String = "%s  %s / %s%s" % [title, HudReadouts.stones_text(value), HudReadouts.stones_text(max_value),
		("   " + note) if note != "" else ""]
	var tw: float = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	var tx: float = size.x - tw - 6.0 if mirrored else 6.0
	var ty: float = (size.y + font.get_ascent(fs) - font.get_descent(fs)) * 0.5
	draw_string(font, Vector2(tx + 1, ty + 1), text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(0, 0, 0, 0.8))
	var ink: Color = get_theme_color(&"text", &"FightStatBar") if has_theme_color(&"text", &"FightStatBar") else Color(0.95, 0.95, 0.95)
	draw_string(font, Vector2(tx, ty), text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, ink)
