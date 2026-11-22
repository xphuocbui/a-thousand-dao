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


func _init() -> void:
	visible = false
	var box := VBoxContainer.new()
	add_child(box)
	var head := HBoxContainer.new()
	box.add_child(head)
	_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_title.add_theme_font_size_override("font_size", 20)
	head.add_child(_title)
	_close_button.text = "×"
	TooltipLayer.set_tip(_close_button, tr("Close (Esc)"))
	_close_button.pressed.connect(close_panel)
	head.add_child(_close_button)
	_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_body.scroll_active = true
	_body.focus_mode = Control.FOCUS_ALL
	box.add_child(_body)


## Opens the panel with [param title] and [param lines]; [param opener] gets focus back on close.
func open_panel(title: String, lines: Array, opener: Control = null) -> void:
	_title.text = title
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
