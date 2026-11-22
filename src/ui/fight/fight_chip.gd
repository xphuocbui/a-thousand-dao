class_name FightChip
extends Control
## A status chip on the fight screen (design/ux/interaction-patterns.md, Status chip; art bible 7.4): only an icon and
## a number. A buff or debuff's painted icon carries its green or red halo; the chip adds the backup cues so colour is
## never the only one: a ↑ or ↓ pip, and a soft round (buff) or dashed (debuff) outline. A neutral chip (a build
## counter or a fired Effect) has neither. Without an icon it shows the first letters of its name. Display only.

## The painted icon, or null.
var icon: Texture2D = null
## The number shown (stacks, pulses left, firings).
var count: String = ""
## "buff", "debuff" or "neutral".
var polarity: String = "neutral"
## Shown when there is no icon.
var short: String = ""


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS
	custom_minimum_size = Vector2(32, 32)


func _draw() -> void:
	var r := Rect2(Vector2.ZERO, size)
	if icon != null:
		draw_texture_rect(icon, r, false)
	else:
		draw_rect(r.grow(-2), Color(0.18, 0.19, 0.24))
		draw_string(get_theme_default_font(), Vector2(4, size.y * 0.5 + 5), short, HORIZONTAL_ALIGNMENT_LEFT, size.x - 6, 12, Color(0.9, 0.9, 0.95))
	match polarity:
		"buff":
			draw_arc(size * 0.5, size.x * 0.5 - 1, 0, TAU, 32, Color(0.36, 0.84, 0.42, 0.9), 1.5)
			_pip("↑", Color(0.36, 0.84, 0.42))
		"debuff":
			for i in 12:   # dashed: the debuff halo's shape differs from the buff's (accessibility: never colour alone)
				var a0: float = TAU * i / 12.0
				draw_arc(size * 0.5, size.x * 0.5 - 1, a0, a0 + TAU / 24.0, 4, Color(0.9, 0.22, 0.31, 0.95), 2.0)
			_pip("↓", Color(0.9, 0.22, 0.31))
	if count != "":
		var font: Font = get_theme_default_font()
		var w: float = font.get_string_size(count, HORIZONTAL_ALIGNMENT_LEFT, -1, 14).x
		var at := Vector2(size.x - w - 2, size.y - 2)
		draw_string_outline(font, at, count, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, 4, Color(0, 0, 0))
		draw_string(font, at, count, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(1, 1, 1))


func _pip(glyph: String, c: Color) -> void:
	var font: Font = get_theme_default_font()
	draw_rect(Rect2(Vector2(0, 0), Vector2(11, 13)), Color(0, 0, 0, 0.75))
	draw_string(font, Vector2(1, 11), glyph, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, c)
