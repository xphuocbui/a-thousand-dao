class_name CentreWindow
extends PanelContainer
## Z7, the centre window (design/ux/hud.md, Layout Zones): the season summary and the event card. One window at a
## time; it takes focus when it opens. Display only: an event option is a request the screen sends to the session.

## The player closed the summary.
signal closed
## The player picked event option [param index] (0-based).
signal option_chosen(index: int)

## True while the window shows an event card (blocking), false for a summary (non-blocking).
var showing_event: bool = false
var _title := Label.new()
var _body := RichTextLabel.new()
var _buttons := VBoxContainer.new()


func _init() -> void:
	visible = false
	custom_minimum_size = Vector2(520, 0)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	add_child(box)
	_title.theme_type_variation = &"HeadingLabel"
	box.add_child(_title)
	_body.fit_content = true
	_body.scroll_active = true
	_body.custom_minimum_size = Vector2(480, 80)
	_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(_body)
	box.add_child(_buttons)


## Shows the season summary [param lines] under [param title], with a Continue button.
func show_summary(title: String, lines: Array) -> void:
	showing_event = false
	_title.text = title
	_body.text = "\n".join(lines.map(func(l): return str(l)))
	_clear_buttons()
	var b := Button.new()
	b.text = tr("Continue")
	b.pressed.connect(func(): _close())
	_buttons.add_child(b)
	_open(b)


## Shows the session's pending event as a card: [param ev] is GameSession.pending_event; [param odds] gives per
## option {ok, chance, text, reason} (Advisor.choice_odds).
func show_event(ev: Dictionary, odds: Array) -> void:
	showing_event = true
	_title.text = str(ev.get("title", ""))
	_body.text = str(ev.get("text", ""))
	_clear_buttons()
	var first: Button = null
	var choices: Array = ev.get("choices", [])
	for i in choices.size():
		var o: Dictionary = odds[i] if i < odds.size() else {}
		var b := Button.new()
		var label: String = "%d) %s" % [i + 1, str(choices[i].get("label", ""))]
		if float(o.get("chance", -1.0)) >= 0.0:
			label += "   (%d%%)" % int(round(float(o.chance) * 100.0))
		b.text = label
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		if not bool(o.get("ok", true)):
			b.disabled = true
			TooltipLayer.set_tip(b, str(o.get("reason", "")))
		else:
			TooltipLayer.set_tip(b, str(o.get("text", "")))
			b.pressed.connect(func(): option_chosen.emit(i))
			if first == null:
				first = b
		_buttons.add_child(b)
	_open(first)


## Hides the window.
func hide_window() -> void:
	visible = false


func _close() -> void:
	visible = false
	closed.emit()


func _open(focus_target: Control) -> void:
	visible = true
	if focus_target != null:
		focus_target.grab_focus.call_deferred()


func _clear_buttons() -> void:
	for c in _buttons.get_children():
		c.queue_free()
