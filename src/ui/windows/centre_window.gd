class_name CentreWindow
extends PanelContainer
## Z7, the centre window (design/ux/hud.md, Layout Zones): the season summary, the Event Engine (#23) card
## (Rule 23, AC-EV-42), and post-duel cultivator Mercy decision (Rule 17, AC-EV-30). One window at a time;
## takes focus when it opens. Display only: choices and mercy decisions emit signals to the map screen.

## The player closed the summary.
signal closed
## The player picked event option [param index] (0-based).
signal option_chosen(index: int)
## The player chose Mercy after a cultivator duel: [param kill] == false spares, true kills.
signal mercy_chosen(kill: bool)

## True while the window shows a blocking event or mercy card, false for a non-blocking summary.
var showing_event: bool = false
## True while the window shows the post-duel cultivator Mercy buttons.
var showing_mercy: bool = false

var _badges := HFlowContainer.new()
var _title := Label.new()
var _scroll := ScrollContainer.new()
var _content := VBoxContainer.new()
var _check_banner := PanelContainer.new()
var _check_label := Label.new()
var _body := RichTextLabel.new()
var _effects_box := VBoxContainer.new()
var _buttons := VBoxContainer.new()


func _init() -> void:
	visible = false
	custom_minimum_size = Vector2(720, 0)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	add_child(box)

	_badges.name = "EventBadges"
	_badges.add_theme_constant_override("h_separation", 6)
	_badges.add_theme_constant_override("v_separation", 4)
	_badges.visible = false
	box.add_child(_badges)

	_title.name = "CentreTitle"
	_title.theme_type_variation = &"HeadingLabel"
	_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(_title)

	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	_scroll.custom_minimum_size = Vector2(680, 120)
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(_scroll)

	_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content.add_theme_constant_override("separation", 8)
	_scroll.add_child(_content)

	_check_banner.name = "CheckBanner"
	_check_banner.visible = false
	_check_banner.add_theme_stylebox_override("panel", Illustrated.box(Illustrated.PAPER_TILE, Illustrated.BRASS, 1, 8.0, 3))
	_check_label.name = "CheckLine"
	_check_label.theme_type_variation = &"RowLabel"
	_check_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_check_banner.add_child(_check_label)
	_content.add_child(_check_banner)

	_body.name = "CentreBody"
	_body.fit_content = true
	_body.scroll_active = false
	_body.custom_minimum_size = Vector2(640, 56)
	_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content.add_child(_body)

	_effects_box.name = "EffectLines"
	_effects_box.visible = false
	_effects_box.add_theme_constant_override("separation", 4)
	_content.add_child(_effects_box)

	_buttons.name = "ChoiceButtons"
	_buttons.add_theme_constant_override("separation", 8)
	box.add_child(_buttons)


## Shows the season summary [param lines] under [param title], with a Continue button.
func show_summary(title: String, lines: Array) -> void:
	showing_event = false
	showing_mercy = false
	_clear_badges()
	_clear_effects()
	_check_banner.visible = false
	_scroll.custom_minimum_size = Vector2(680, 140)
	_title.text = title
	_body.text = "\n".join(lines.map(func(l): return str(l)))
	_clear_buttons()
	var b := Button.new()
	b.name = "ContinueButton"
	b.text = tr("Continue")
	b.pressed.connect(func(): _close())
	_buttons.add_child(b)
	_open(b)


## Shows the session's pending event as a rich Event Engine (#23) card (Rule 23, AC-EV-42):
## [param ev] is [method GameQuery.pending_event]; [param odds] gives per-option {ok, chance, text, reason}.
## When [param ev] represents a pending cultivator Mercy decision (empty choices + mercy_pending),
## delegates directly to [method show_mercy_result].
func show_event(ev: Dictionary, odds: Array) -> void:
	var choices: Array = Array(ev.get("choices", []))
	if bool(ev.get("mercy_pending", false)) and choices.is_empty():
		show_mercy_result(
			str(ev.get("title", tr("Định đoạt sinh tử"))),
			str(ev.get("check_line", "")),
			Array(ev.get("effect_lines", [])),
			str(ev.get("text", "")),
			ev
		)
		return
	showing_event = true
	showing_mercy = false
	_clear_badges()
	_clear_effects()
	_check_banner.visible = false
	_populate_event_badges(ev)
	_title.text = str(ev.get("title", ""))
	_body.text = str(ev.get("text", ""))
	_scroll.custom_minimum_size = Vector2(680, 110)
	_clear_buttons()

	var first: Button = null
	for i in choices.size():
		var ch: Dictionary = choices[i] if choices[i] is Dictionary else {}
		var o: Dictionary = odds[i] if i < odds.size() and odds[i] is Dictionary else {}
		var btn: Button = _build_choice_card(i, ch, o)
		if first == null and btn != null and not btn.disabled:
			first = btn
	_open(first)


## Shows the post-fight result view with check line, itemized effect lines, outcome text, and
## Mercy choice buttons ("Tha mạng" / "Kết liễu") when [param mercy_info] is pending (AC-EV-30).
func show_mercy_result(
	title: String,
	check_line: String,
	effect_lines: Array,
	outcome_text: String,
	mercy_info: Dictionary = {}
) -> void:
	showing_event = true
	showing_mercy = true
	_clear_badges()
	_clear_effects()
	_add_badge(tr("Định đoạt sinh tử (Mercy)"), Illustrated.CINNABAR, Illustrated.BONE)
	var target_name: String = str(mercy_info.get("mercy_target_name", mercy_info.get("target_name", "")))
	if target_name != "":
		_add_badge(tr("Đối thủ: %s") % target_name, Illustrated.PAPER_TILE, Illustrated.INK)
	_badges.visible = _badges.get_child_count() > 0
	_title.text = title if title != "" else tr("Định đoạt sinh tử")

	if check_line.strip_edges() != "":
		_check_label.text = check_line
		_check_banner.visible = true
	else:
		_check_banner.visible = false

	_body.text = outcome_text
	_scroll.custom_minimum_size = Vector2(680, 290 if not effect_lines.is_empty() else 160)

	if not effect_lines.is_empty():
		var inset_col: VBoxContainer = Illustrated.inset(_effects_box, tr("Kết quả & Ảnh hưởng"))
		for raw_line in effect_lines:
			var sline: String = str(raw_line).strip_edges()
			if sline == "":
				continue
			var el := Label.new()
			el.text = "• " + sline
			el.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			el.add_theme_color_override("font_color", Illustrated.INK)
			inset_col.add_child(el)
		_effects_box.visible = true

	_clear_buttons()
	var prompt_panel := PanelContainer.new()
	prompt_panel.name = "MercyPrompt"
	prompt_panel.add_theme_stylebox_override("panel", Illustrated.box(Illustrated.PAPER_TILE, Illustrated.CINNABAR, 2, 10.0, 3))
	var pcol := VBoxContainer.new()
	pcol.add_theme_constant_override("separation", 8)
	prompt_panel.add_child(pcol)

	var prompt_lbl := Label.new()
	prompt_lbl.text = tr("%s đã bại trận. Ngươi chọn tha mạng hay kết liễu?") % (
		target_name if target_name != "" else tr("Đối thủ")
	)
	prompt_lbl.theme_type_variation = &"RowLabel"
	prompt_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	prompt_lbl.add_theme_color_override("font_color", Illustrated.CINNABAR)
	pcol.add_child(prompt_lbl)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	pcol.add_child(row)

	var spare_btn := Button.new()
	spare_btn.name = "MercySpare"
	spare_btn.text = tr("Tha mạng (Spare)")
	spare_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	TooltipLayer.set_tip(spare_btn, {
		"title": tr("Tha mạng (Spare)"),
		"summary": tr("Giữ lại tính mạng đối thủ, ghi dấu ân oán (spared_by); người này có thể xuất hiện lại trong sự kiện sau."),
	})
	spare_btn.pressed.connect(func(): mercy_chosen.emit(false))
	row.add_child(spare_btn)

	var kill_btn := Button.new()
	kill_btn.name = "MercyKill"
	kill_btn.text = tr("Kết liễu (Kill)")
	kill_btn.theme_type_variation = &"CommitButton"
	kill_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	TooltipLayer.set_tip(kill_btn, {
		"title": tr("Kết liễu (Kill)"),
		"summary": tr("Đoạn tuyệt sinh cơ của đối thủ; ghi vào sử ký thế giới và có thể kết huyết thù với thân hữu của họ."),
	})
	kill_btn.pressed.connect(func(): mercy_chosen.emit(true))
	row.add_child(kill_btn)

	_buttons.add_child(prompt_panel)
	_open(spare_btn)


## Hides the window.
func hide_window() -> void:
	visible = false


func _populate_event_badges(ev: Dictionary) -> void:
	var story_name: String = str(ev.get("story_name", ""))
	var story_stage: String = str(ev.get("story_stage", ""))
	if story_name != "":
		var st_txt: String = tr("Chuỗi sự kiện: %s") % story_name
		if story_stage != "":
			st_txt += " · " + story_stage
		_add_badge(st_txt, Illustrated.CINNABAR, Illustrated.BONE)
	var followup_of: String = str(ev.get("followup_of", ""))
	if followup_of != "":
		_add_badge(tr("Tiếp nối: %s") % followup_of, Illustrated.PAPER_TILE, Illustrated.GILT)
	var ev_kind: String = str(ev.get("kind", ""))
	var origin_badge: String = str(ev.get("origin_badge", ""))
	if origin_badge != "":
		_add_badge(origin_badge, Illustrated.PAPER_TILE, Illustrated.INK)
	elif ev_kind == "hook" and str(ev.get("hook", "")) != "":
		_add_badge(tr("Cơ duyên · %s") % str(ev.get("hook", "")), Illustrated.PAPER_TILE, Illustrated.INK)
	elif ev_kind == "followup_only" and followup_of == "":
		_add_badge(tr("Hậu quả tiếp nối"), Illustrated.PAPER_TILE, Illustrated.GILT)
	_badges.visible = _badges.get_child_count() > 0


func _add_badge(text: String, bg: Color, fg: Color) -> void:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", Illustrated.box(bg, Illustrated.BRASS, 1, 4.0, 3))
	var l := Label.new()
	l.text = text
	l.theme_type_variation = &"RowLabel"
	l.add_theme_color_override("font_color", fg)
	p.add_child(l)
	_badges.add_child(p)


func _build_choice_card(index: int, ch: Dictionary, o: Dictionary) -> Button:
	var affordable: bool = bool(ch.get("affordable", o.get("ok", true)))
	var disable_reason: String = str(ch.get("disable_reason", o.get("reason", "")))
	if not bool(o.get("ok", true)):
		affordable = false
		if disable_reason == "":
			disable_reason = str(o.get("reason", ""))

	var card := PanelContainer.new()
	card.name = "ChoiceCard_%d" % index
	card.add_theme_stylebox_override("panel", Illustrated.box(
		Illustrated.PAPER_TILE if affordable else Color("#CFC3A8"),
		Illustrated.BRASS if affordable else Illustrated.BRASS_DIM,
		1,
		8.0,
		3
	))
	if not affordable:
		card.modulate = Color(1.0, 1.0, 1.0, 0.84)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 4)
	card.add_child(col)

	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 8)
	col.add_child(top)

	var trait_badge: String = str(ch.get("trait_badge", ""))
	var trait_display: String = str(ch.get("trait_label", trait_badge))
	var label_txt: String = str(ch.get("label", ""))
	var btn_text: String = "%d) %s" % [index + 1, label_txt]
	if trait_display != "":
		btn_text = "%d) [%s] %s" % [index + 1, trait_display, label_txt]

	var b := Button.new()
	b.name = "Choice_%d" % index
	b.text = btn_text
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(b)

	# Check / Fight odds pill with Breakdown tooltip (ADR-0005: TooltipLayer.set_tip only).
	var check_bd: Dictionary = Dictionary(ch.get("check_breakdown", {}))
	var fight_odds: Dictionary = Dictionary(ch.get("fight_odds", {}))
	var situation: String = str(ch.get("situation", Dictionary(ch.get("check", {})).get("situation", "")))
	var tip_payload: Variant = str(o.get("text", ""))
	if not fight_odds.is_empty() or str(Dictionary(ch.get("check", {})).get("type", "")) == "combat":
		var f_chance: float = float(fight_odds.get("chance", o.get("chance", 0.5)))
		var sit_key: String = str(fight_odds.get("situation", situation))
		if sit_key == "":
			sit_key = "foreseen"
		var sit_label: String = _situation_label(sit_key)
		var pill_txt: String = "⚔ %d%% · %s" % [roundi(f_chance * 100.0), sit_label]
		var enemy_name: String = str(fight_odds.get("enemy_name", ""))
		var f_lines: Array = []
		if enemy_name != "":
			f_lines.append(tr("Đối thủ: %s") % enemy_name)
		if float(fight_odds.get("player_power", 0.0)) > 0.0 or float(fight_odds.get("enemy_power", 0.0)) > 0.0:
			f_lines.append(tr("Chiến lực: %.0f vs %.0f") % [float(fight_odds.get("player_power", 0.0)), float(fight_odds.get("enemy_power", 0.0))])
		f_lines.append(tr("Tình huống: %s") % sit_label)
		tip_payload = {
			"title": tr("Tỉ lệ giao đấu"),
			"fact": "%d%% · %s" % [roundi(f_chance * 100.0), sit_label],
			"summary": str(o.get("text", tr("Giao đấu quyết định thành bại."))),
			"lines": f_lines,
		}
		var pill := _odds_pill(pill_txt, Illustrated.CINNABAR if sit_key in ["ambush", "blind"] else Illustrated.GILT, tip_payload)
		pill.name = "CheckPill_%d" % index
		top.add_child(pill)
	elif not check_bd.is_empty() or float(o.get("chance", -1.0)) >= 0.0:
		var s_chance: float = float(check_bd.get("chance", o.get("chance", 0.0)))
		var cstat: String = str(check_bd.get("stat", Dictionary(ch.get("check", {})).get("stat", "")))
		var stat_lbl: String = _stat_label(cstat)
		var pill_txt: String = "%d%%" % roundi(s_chance * 100.0)
		if stat_lbl != "":
			pill_txt += " · " + stat_lbl
		var bd_lines: Array = Array(check_bd.get("lines", []))
		tip_payload = {
			"title": tr("Kiểm tra %s") % (stat_lbl if stat_lbl != "" else tr("chỉ số")),
			"fact": "%d%%" % roundi(s_chance * 100.0),
			"summary": str(o.get("text", tr("Độ khó: %.0f") % float(check_bd.get("difficulty", 50.0)))),
			"lines": bd_lines,
		}
		var pill := _odds_pill(pill_txt, Illustrated.GILT, tip_payload)
		pill.name = "CheckPill_%d" % index
		top.add_child(pill)
		if not bd_lines.is_empty():
			var bdl := Label.new()
			bdl.name = "CheckBreakdown_%d" % index
			bdl.text = tr("Chi tiết kiểm tra: ") + " · ".join(bd_lines.map(func(x): return str(x)))
			bdl.theme_type_variation = &"RowLabel"
			bdl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			bdl.add_theme_color_override("font_color", Color(Illustrated.INK, 0.78))
			col.add_child(bdl)

	# Always costs line (AC-EV-42).
	var always_costs: Array = Array(ch.get("always_costs", ch.get("always", [])))
	var cost_txt: String = _format_always_costs(always_costs)
	if cost_txt != "":
		var cl := Label.new()
		cl.name = "AlwaysCost_%d" % index
		cl.text = tr("Chi phí chắc chắn: %s") % cost_txt
		cl.theme_type_variation = &"RowLabel"
		cl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		cl.add_theme_color_override("font_color", Illustrated.GILT)
		col.add_child(cl)

	# Outcome summary / Hidden / Deadly hidden warning (AC-EV-42).
	var is_hidden: bool = bool(ch.get("hidden", false))
	var is_deadly: bool = bool(ch.get("deadly", false))
	var out_summary: String = str(ch.get("outcome_summary", "")).strip_edges()
	if is_hidden:
		var hl := Label.new()
		hl.name = "DeadlyWarn_%d" % index if is_deadly else "HiddenOutcome_%d" % index
		hl.theme_type_variation = &"RowLabel"
		hl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		if is_deadly:
			hl.text = tr("? · ⚠ Có thể tử vong")
			hl.add_theme_color_override("font_color", Illustrated.CINNABAR)
		else:
			hl.text = tr("? · Kết quả ẩn")
			hl.add_theme_color_override("font_color", Color(Illustrated.INK, 0.72))
		col.add_child(hl)
	elif out_summary != "":
		var ol := Label.new()
		ol.name = "OutcomeSummary_%d" % index
		ol.text = out_summary
		ol.theme_type_variation = &"RowLabel"
		ol.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		ol.add_theme_color_override("font_color", Color(Illustrated.INK, 0.88))
		col.add_child(ol)

	# Disabled unaffordable state + explicit reason (AC-EV-42).
	if not affordable:
		b.disabled = true
		var why: String = disable_reason if disable_reason != "" else tr("Không đủ điều kiện")
		TooltipLayer.set_tip(b, {"title": label_txt, "summary": why})
		var rl := Label.new()
		rl.name = "DisableReason_%d" % index
		rl.text = tr("Không thể chọn: %s") % why
		rl.theme_type_variation = &"RowLabel"
		rl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		rl.add_theme_color_override("font_color", Illustrated.CINNABAR)
		col.add_child(rl)
	else:
		TooltipLayer.set_tip(b, tip_payload)
		b.pressed.connect(func(): option_chosen.emit(index))

	_buttons.add_child(card)
	return b


func _odds_pill(text: String, fg: Color, tip: Variant) -> PanelContainer:
	var p := PanelContainer.new()
	p.focus_mode = Control.FOCUS_ALL
	p.mouse_filter = Control.MOUSE_FILTER_STOP
	p.add_theme_stylebox_override("panel", Illustrated.box(Illustrated.PAPER, Illustrated.BRASS, 1, 5.0, 3))
	var l := Label.new()
	l.text = text
	l.theme_type_variation = &"RowLabel"
	l.add_theme_color_override("font_color", fg)
	p.add_child(l)
	TooltipLayer.set_tip(p, tip)
	return p


static func _situation_label(sit: String) -> String:
	match sit:
		"foreseen":
			return "Chủ động (foreseen)"
		"ambush":
			return "Phục kích (ambush)"
		"blind":
			return "Bất ngờ (blind)"
	return sit


static func _stat_label(stat_id: String) -> String:
	match stat_id:
		"ngo_tinh": return "Ngộ tính"
		"can_cot": return "Căn cốt"
		"than_hon": return "Thần hồn"
		"than_thuc": return "Thần thức"
		"khi_van": return "Khí vận"
		"dao_tam": return "Đạo tâm"
		"mi_luc": return "Mị lực"
		"attack": return "Công kích"
		"defense": return "Phòng ngự"
	return stat_id


static func _format_always_costs(always_costs: Array) -> String:
	var parts: PackedStringArray = PackedStringArray()
	for raw in always_costs:
		if not (raw is Dictionary):
			continue
		var d: Dictionary = raw as Dictionary
		var t: String = str(d.get("type", ""))
		match t:
			"linh_thach":
				parts.append("%+d linh thạch" % int(d.get("amount", 0)))
			"khi_huyet_loss_pct":
				parts.append("-%d%% khí huyết" % int(roundf(absf(float(d.get("amount", 0.0))))))
			"tam_ma":
				parts.append("%+d tâm ma" % int(d.get("amount", 0)))
			"dan_doc":
				parts.append("%+d đan độc" % int(d.get("amount", 0)))
			"relationship":
				parts.append("hảo cảm %+d" % int(d.get("amount", 0)))
			"tu_vi":
				parts.append("%+.0f tu vi" % float(d.get("amount", 0.0)))
			_:
				if t != "":
					var amt: Variant = d.get("amount", "")
					parts.append("%s %s" % [t, str(amt)] if str(amt) != "" else t)
	return ", ".join(parts)


func _close() -> void:
	visible = false
	closed.emit()


func _open(focus_target: Control) -> void:
	visible = true
	if focus_target != null:
		_focus_now.bind(focus_target).call_deferred()


func _focus_now(c: Control) -> void:
	if is_instance_valid(c) and c.is_inside_tree() and c.is_visible_in_tree():
		c.grab_focus()


func _clear_buttons() -> void:
	for c in _buttons.get_children():
		_buttons.remove_child(c)
		c.queue_free()


func _clear_badges() -> void:
	for c in _badges.get_children():
		_badges.remove_child(c)
		c.queue_free()
	_badges.visible = false


func _clear_effects() -> void:
	for c in _effects_box.get_children():
		_effects_box.remove_child(c)
		c.queue_free()
	_effects_box.visible = false
