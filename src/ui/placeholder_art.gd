class_name PlaceholderArt
extends RefCounted
## The one obvious placeholder for missing art (.claude/rules/ui-code.md; user 2026-11-24: "use a placeholder
## (something obviously that it's a placeholder) for missing photos"): magenta and ink stripes, the classic
## missing-texture signal, with the word PLACEHOLDER over them. Use it wherever a painting, portrait or picture that
## should exist is missing, instead of a stand-in that looks finished.
##
## Usage:
## [codeblock]
## var tex: Texture2D = PortraitPicker.place_painting(cid)
## var pic: Control = PlaceholderArt.make(Vector2(0, 220), tr("No painting yet")) if tex == null else ...
## [/codeblock]

const MAGENTA := Color("#FF00FF")
const INK := Color("#1A1018")
const STRIPE := 16   # stripe width in px of the texture

static var _tex: ImageTexture = null


## The striped texture (cached, 128 x 128, tiles seamlessly).
static func texture() -> Texture2D:
	if _tex == null:
		var img := Image.create(128, 128, false, Image.FORMAT_RGB8)
		for y in 128:
			for x in 128:
				img.set_pixel(x, y, MAGENTA if ((x + y) / STRIPE) % 2 == 0 else INK)
		_tex = ImageTexture.create_from_image(img)
	return _tex


## Whether [param tex] is the placeholder (for tests and callers that check).
static func is_placeholder(tex: Texture2D) -> bool:
	return tex != null and tex == _tex


## A Control of at least [param min_size]: the stripes tiled, and PLACEHOLDER with [param what] (what is missing,
## e.g. "No painting yet") on a dark band, both as text and as the tooltip.
static func make(min_size: Vector2, what: String = "") -> Control:
	var root := PanelContainer.new()
	root.custom_minimum_size = min_size
	var sb := StyleBoxFlat.new()
	sb.bg_color = INK
	sb.border_color = MAGENTA
	sb.set_border_width_all(2)
	root.add_theme_stylebox_override("panel", sb)
	var stripes := TextureRect.new()
	stripes.texture = texture()
	stripes.stretch_mode = TextureRect.STRETCH_TILE
	stripes.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stripes.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(stripes)
	var band := PanelContainer.new()
	band.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var bs := StyleBoxFlat.new()
	bs.bg_color = Color(INK, 0.85)
	bs.set_content_margin_all(6)
	band.add_theme_stylebox_override("panel", bs)
	band.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var l := Label.new()
	l.name = "PlaceholderLabel"
	l.text = TranslationServer.translate("PLACEHOLDER") + ((" · " + what) if what != "" else "")
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_color_override("font_color", MAGENTA)
	band.add_child(l)
	root.add_child(band)
	root.tooltip_text = l.text
	root.set_meta("placeholder", true)
	return root
