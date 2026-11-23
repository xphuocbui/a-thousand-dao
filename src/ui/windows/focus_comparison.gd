class_name FocusComparison
extends PanelContainer
## A first version of the focus comparison (design/ux/hud.md, element 29): every season focus the player can take,
## one preselected, set only when the player confirms. Unavailable focuses show greyed with their reason. The preview
## numbers (gain, seasons, lifespan, risk) wait on the session's preview contract, so each row carries only a note.

## The player confirmed focus [param option_id] (an option's "id").
signal confirmed(option_id: String)
## The player closed the window without choosing.
signal cancelled

var _title := Label.new()
var _rows := VBoxContainer.new()
var _confirm := Button.new()
var _group := ButtonGroup.new()
var _selected: String = ""


func _init() -> void:
	visible = false
	custom_minimum_size = Vector2(460, 0)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	add_child(box)
	_title.text = tr("Season focus")
	_title.theme_type_variation = &"HeadingLabel"
	box.add_child(_title)
	var hint := Label.new()
	hint.text = tr("Pick what this season is for; End turn then resolves it.")
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(hint)
	box.add_child(_rows)
	var buttons := HBoxContainer.new()
	box.add_child(buttons)
	_confirm.text = tr("Confirm")
	_confirm.pressed.connect(func(): _finish(true))
	buttons.add_child(_confirm)
	var cancel := Button.new()
	cancel.text = tr("Cancel")
	cancel.pressed.connect(func(): _finish(false))
	buttons.add_child(cancel)


## Shows [param options] ([{id, label, note, enabled, reason}]) with [param preselect_id] selected.
func open(options: Array, preselect_id: String) -> void:
	for c in _rows.get_children():
		_rows.remove_child(c)
		c.queue_free()
	_selected = ""
	var focus_target: Button = null
	var target_id: String = ""
	for o in options:
		var b := Button.new()
		b.toggle_mode = true
		b.button_group = _group
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.text = str(o.label) + (("   — " + str(o.note)) if str(o.get("note", "")) != "" else "")
		var id: String = str(o.id)
		if not bool(o.get("enabled", true)):
			b.disabled = true
			TooltipLayer.set_tip(b, str(o.get("reason", "")))
		else:
			b.toggled.connect(func(on: bool): if on: _selected = id)
			if id == preselect_id or focus_target == null:
				focus_target = b
				target_id = id
		_rows.add_child(b)
	if focus_target != null:
		focus_target.button_pressed = true
		_selected = target_id
	visible = true
	(focus_target if focus_target != null else _confirm).grab_focus.call_deferred()


## The option id currently selected ("" when none).
func selected_id() -> String:
	return _selected


## Confirms the current selection, as the Confirm button does.
func confirm() -> void:
	_finish(true)


## Closes without choosing, as Cancel or Esc does.
func cancel() -> void:
	_finish(false)


func _finish(ok: bool) -> void:
	if not visible:
		return
	visible = false
	if ok and _selected != "":
		confirmed.emit(_selected)
	else:
		cancelled.emit()
