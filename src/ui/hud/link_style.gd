class_name LinkStyle
extends RefCounted
## How tooltipable text looks (design/ux/hud.md, Tooltips: Content; user decision 2026-11-22): every piece of text or
## number that has a tooltip is underlined, then styled by what it is: terms in the term colour, numbers bold, people
## bold in a relation colour, places italic, items in their rarity colour, sects bold italic in the sect's colour.
## Buttons, bubbles and icons keep their own look. The underline is the constant cue, so colour is never the only one.
## The table is data: ui_hud.json "link_styles".

## The kinds, in the order the spec lists them.
const KINDS := ["term", "number", "person", "place", "item", "sect"]

static var _cfg: Dictionary = {}
static var _fonts: Dictionary = {}
## The theme's bold and italic faces (art bible 7.11), set by [method set_fonts]; null keeps the engine fallback.
static var _bold_base: Font = null
static var _italic_base: Font = null


## Sets the style table (ui_hud.json "link_styles"); takes effect for controls styled after it.
static func configure(cfg: Dictionary) -> void:
	_cfg = cfg
	_fonts = {}


## Uses the theme's faces for bold and italic links (Literata semibold and italic) instead of a synthetic slant.
static func set_fonts(bold: Font, italic: Font) -> void:
	_bold_base = bold
	_italic_base = italic
	_fonts = {}


## The style of [param kind] (one of [constant KINDS]; unknown kinds read as "term") with an optional [param variant]:
## a key of the kind's "colours" table (a relation, a rarity) or a colour given directly as "#RRGGBB" (a sect's own
## colour). Returns {colour: Color or null (keep the theme's), bold: bool, italic: bool}.
static func style_of(kind: String, variant: String = "", surface: String = "wood") -> Dictionary:
	var name: String = kind if KINDS.has(kind) else "term"
	var k: Dictionary = _cfg.get(name, {}).duplicate(true)
	if surface == "paper":   # on parchment the table's "paper" overrides apply (art bible Section 4: dark on light)
		var over: Dictionary = _cfg.get("paper", {}).get(name, {})
		for key in over:
			k[key] = over[key]
	var hex: String = str(k.get("colour", ""))
	var table: Dictionary = k.get("colours", {})
	if variant.begins_with("#"):
		hex = variant
	elif variant != "" and table.has(variant):
		hex = str(table[variant])
	return {"colour": Color.html(hex) if hex != "" and Color.html_is_valid(hex) else null,
		"bold": bool(k.get("bold", false)), "italic": bool(k.get("italic", false))}


## The kind a highlighted word's key names: "place:dao_thanh" is a place, a bare key ("linh_khi") is a term.
static func kind_of_key(key: String) -> String:
	var i: int = key.find(":")
	if i > 0 and KINDS.has(key.substr(0, i)):
		return key.substr(0, i)
	return "term"


## Styles [param c] (a Label or a LinkButton) as tooltipable text of [param kind] / [param variant]: underline, colour,
## bold and italic per the table.
## [param surface] is "wood" (the HUD) or "paper" (windows, tooltips).
static func apply(c: Control, kind: String, variant: String = "", surface: String = "wood") -> void:
	var st: Dictionary = style_of(kind, variant, surface)
	var font: Font = _font(bool(st.bold), bool(st.italic))
	if font != null:
		c.add_theme_font_override(&"font", font)
	if st.colour != null:
		for n in [&"font_color", &"font_hover_color", &"font_focus_color", &"font_pressed_color", &"font_hover_pressed_color"]:
			c.add_theme_color_override(n, st.colour)
	if c is LinkButton:
		(c as LinkButton).underline = LinkButton.UNDERLINE_MODE_ALWAYS
	elif c is Label and not c.has_meta(&"link_underline"):
		# Label has no underline of its own: draw one under the text, in the text's colour.
		c.set_meta(&"link_underline", true)
		c.draw.connect(_draw_underline.bind(c))
		c.queue_redraw()


static func _font(bold: bool, italic: bool) -> Font:
	if not bold and not italic:
		return null
	var key: String = "%s|%s" % [bold, italic]
	if not _fonts.has(key):
		var f := FontVariation.new()
		var base: Font = _italic_base if italic and _italic_base != null else (_bold_base if _bold_base != null else ThemeDB.fallback_font)
		f.base_font = base
		if bold and (italic or _bold_base == null):
			f.variation_embolden = 0.7
		if italic and _italic_base == null:
			f.variation_transform = Transform2D(Vector2(1, 0), Vector2(0.2, 1), Vector2.ZERO)   # a synthetic slant
		_fonts[key] = f
	return _fonts[key]


static func _draw_underline(l: Label) -> void:
	if l.text == "":
		return
	var font: Font = l.get_theme_font(&"font")
	var fs: int = l.get_theme_font_size(&"font_size")
	var sb: StyleBox = l.get_theme_stylebox(&"normal")
	var w: float = font.get_string_size(l.text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	var h: float = font.get_height(fs)
	var ml: float = sb.get_margin(SIDE_LEFT) if sb != null else 0.0
	var mr: float = sb.get_margin(SIDE_RIGHT) if sb != null else 0.0
	var mt: float = sb.get_margin(SIDE_TOP) if sb != null else 0.0
	var mb: float = sb.get_margin(SIDE_BOTTOM) if sb != null else 0.0
	var x: float = ml
	match l.horizontal_alignment:
		HORIZONTAL_ALIGNMENT_CENTER:
			x = (l.size.x - w) / 2.0
		HORIZONTAL_ALIGNMENT_RIGHT:
			x = l.size.x - mr - w
	var top: float = mt
	match l.vertical_alignment:
		VERTICAL_ALIGNMENT_CENTER:
			top = (l.size.y - h) / 2.0
		VERTICAL_ALIGNMENT_BOTTOM:
			top = l.size.y - mb - h
	var y: float = top + font.get_ascent(fs) + maxf(2.0, fs * 0.12)
	l.draw_line(Vector2(x, y), Vector2(x + w, y), l.get_theme_color(&"font_color"), maxf(1.0, fs / 14.0))
