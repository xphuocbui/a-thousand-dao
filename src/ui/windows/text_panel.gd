class_name TextPanel
extends PanelContainer
## Z6, the panel over the left of the map (design/ux/hud.md, Layout Zones). Greybox slice 1 shows one panel, the
## character sheet, as the debug terminal's text view; the real panels get their own UX specs. Focus moves into it on
## open and back to the opener on close.

## The panel was closed.
signal closed

var _title := Label.new()
var _body := RichTextLabel.new()
var _close_button := Button.new()
var _opener: Control = null
var _image := TextureRect.new()


func _init() -> void:
	visible = false
	var box := VBoxContainer.new()
	add_child(box)
	var head := HBoxContainer.new()
	box.add_child(head)
	_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_title.theme_type_variation = &"HeadingLabel"
	head.add_child(_title)
	_close_button.text = "×"
	TooltipLayer.set_tip(_close_button, tr("Close (Esc)"))
	_close_button.pressed.connect(close_panel)
	head.add_child(_close_button)
	_image.visible = false   # a place's own painting, above its text (art bible Section 1, Principle 2)
	_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_image.custom_minimum_size = Vector2(0, 170)
	box.add_child(_image)
	_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_body.scroll_active = true
	_body.focus_mode = Control.FOCUS_ALL
	box.add_child(_body)


## Opens the panel with [param title] and [param lines]; [param opener] gets focus back on close.
## [param image] (optional) shows above the text.
func open_panel(title: String, lines: Array, opener: Control = null, image: Texture2D = null) -> void:
	_title.text = title
	_image.texture = image
	_image.visible = image != null
	_body.text = "\n".join(lines.map(func(l): return str(l)))
	_opener = opener
	visible = true
	_body.grab_focus.call_deferred()


## Closes the panel and returns focus to its opener.
func close_panel() -> void:
	if not visible:
		return
	visible = false
	if _opener != null and is_instance_valid(_opener):
		_opener.grab_focus()
	closed.emit()
