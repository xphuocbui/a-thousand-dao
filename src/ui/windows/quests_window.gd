class_name QuestsWindow
extends GameWindow
## The Quests & Stories window (Template Quests #31 Rules 6-18 + Event Engine #23 Rule 12; Z6 hotkey J).
## Built strictly from read-only [method GameQuery.quests_journal] / [method GameQuery.quest_offer_view]
## dictionaries (ADR-0006): never reads or mutates [GameSession].
##
## Four sub-tabs:
## - "journal": Active & Orphaned quests (stage tracker, seasons left, tight-deadline warning, actions).
## - "offers":  Open person/sect offers (tier, offerer, source fact, adversary & resolved world outcomes,
##              budget Breakdown, stage 1 full / later stages kind+place only, lasting-gain / cap-0 notice).
## - "board":   Local sect hall / town board (up to 3 Errand/Ordinary slots, zero-cooldown browsing).
## - "stories": Active Event Engine non-quest stories (stage, last event, remaining budget/items/timeout).

## Emitted when the player switches between the 4 sub-tabs.
signal tab_selected(tab_id: String)

const TAB_JOURNAL := "journal"
const TAB_OFFERS := "offers"
const TAB_BOARD := "board"
const TAB_STORIES := "stories"
const TAB_ORDER := [TAB_JOURNAL, TAB_OFFERS, TAB_BOARD, TAB_STORIES]
const DEFAULT_NAV_WIDTH := 230

## Optional `ui_windows.json` configuration.
var cfg: Dictionary = {}

var _active_tab: String = TAB_JOURNAL
var _focus_id: String = ""


func kind() -> String:
	return "quests"


func window_title(v: Dictionary) -> String:
	var tab_name: String = _tab_title(_active_tab)
	var act_n: int = Array(v.get("active", [])).size()
	var cap: int = int(v.get("active_cap", 3))
	if _active_tab == TAB_JOURNAL:
		return "%s — %s (%d/%d)" % [tr("Quests (Ủy thác)"), tab_name, act_n, cap]
	return "%s — %s" % [tr("Quests (Ủy thác)"), tab_name]


## Returns the currently active sub-tab id.
func active_tab() -> String:
	return _active_tab


## Returns the currently focused quest or story id ("" when none).
func focused_id() -> String:
	return _focus_id


## Switches to sub-tab [param tab_id] and rebuilds in place.
func select_tab(tab_id: String) -> void:
	if not (tab_id in TAB_ORDER) or tab_id == _active_tab:
		return
	_active_tab = tab_id
	tab_selected.emit(tab_id)
	if not view.is_empty():
		show_view(view, "", locked)


func show_view(v: Dictionary, section: String, is_locked: bool) -> void:
	var req_tab: String = str(v.get("active_tab", ""))
	var req_focus: String = str(v.get("focus_id", ""))
	if section != "":
		if section in TAB_ORDER:
			_active_tab = section
		elif section.begins_with("story:"):
			_active_tab = TAB_STORIES
			req_focus = section.substr(6)
		elif section.begins_with("quest:"):
			req_focus = section.substr(6)
			_active_tab = _infer_tab_for_id(v, req_focus)
		else:
			var inferred: String = _infer_tab_for_id(v, section)
			if inferred != "":
				_active_tab = inferred
				req_focus = section
	elif req_tab != "" and req_tab in TAB_ORDER:
		_active_tab = req_tab
	if req_focus != "":
		_focus_id = req_focus
		var inferred_f: String = _infer_tab_for_id(v, _focus_id)
		if inferred_f != "" and section == "" and req_tab == "":
			_active_tab = inferred_f
	super.show_view(v, "", is_locked)


func _build() -> void:
	var v: Dictionary = view
	var active_list: Array = Array(v.get("active", []))
	var offers_list: Array = Array(v.get("offers", []))
	var board_list: Array = Array(v.get("board", []))
	var stories_list: Array = Array(v.get("stories", []))
	var cap: int = int(v.get("active_cap", 3))
	var gain_w: float = float(v.get("gain_total_w", 0.0))
	var cap_w: float = float(v.get("gain_cap_w", 48.0))
	var can_boon: bool = bool(v.get("can_gain_boon", gain_w < cap_w))

	_build_header(active_list, offers_list, board_list, stories_list, cap, gain_w, cap_w, can_boon)

	var ground: VBoxContainer = Illustrated.ground(body)
	if not compact:
		use_side(DEFAULT_NAV_WIDTH, true)
		_build_nav(Illustrated.ground(side), active_list, offers_list, board_list, stories_list, cap, gain_w, cap_w, can_boon)

	match _active_tab:
		TAB_OFFERS:
			_build_offers_tab(ground, offers_list, active_list.size(), cap, gain_w, cap_w, can_boon)
		TAB_BOARD:
			_build_board_tab(ground, board_list, active_list.size(), cap)
		TAB_STORIES:
			_build_stories_tab(ground, stories_list)
		_:
			_build_journal_tab(ground, active_list, Array(v.get("completed", [])), cap)

	var foot := Label.new()
	foot.text = tr("Ủy thác (J) · Tối đa %d ủy thác đang nhận · Thưởng vĩnh viễn: %.1f / %.0f W") % [cap, gain_w, cap_w]
	foot.theme_type_variation = &"RowLabel"
	foot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	foot.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bar.add_child(foot)


func _build_header(
	active_list: Array,
	offers_list: Array,
	board_list: Array,
	stories_list: Array,
	cap: int,
	gain_w: float,
	cap_w: float,
	can_boon: bool
) -> void:
	var summary := Label.new()
	summary.name = "QuestsSummary"
	summary.text = tr("Ủy thác đang làm: %d/%d  ·  Lời mời: %d  ·  Bảng ủy thác: %d  ·  Chuỗi sự kiện: %d") % [
		active_list.size(), cap, offers_list.size(), board_list.size(), stories_list.size(),
	]
	summary.theme_type_variation = &"RowLabel"
	summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	TooltipLayer.set_tip(summary, {
		"title": tr("Sổ Ủy Thác & Chuỗi Sự Kiện"),
		"fact": tr("Thưởng vĩnh viễn: %.1f / %.0f W") % [gain_w, cap_w],
		"summary": tr("Nhận tối đa %d ủy thác cùng lúc. Chuỗi sự kiện tách biệt khỏi hạn mức ủy thác.") % cap,
	})
	header.add_child(summary)

	if compact:
		var tabs := HFlowContainer.new()
		tabs.name = "CompactQuestTabs"
		tabs.add_theme_constant_override("h_separation", 6)
		tabs.add_theme_constant_override("v_separation", 4)
		for tid in TAB_ORDER:
			tabs.add_child(_make_tab_button(tid, _tab_count_label(tid, active_list, offers_list, board_list, stories_list, cap), true))
		header.add_child(tabs)


func _build_nav(
	parent: Control,
	active_list: Array,
	offers_list: Array,
	board_list: Array,
	stories_list: Array,
	cap: int,
	gain_w: float,
	cap_w: float,
	can_boon: bool
) -> void:
	var nav_box: VBoxContainer = Illustrated.inset(parent, tr("Danh mục (Sections)"))
	nav_box.get_parent().name = "QuestNav"
	for tid in TAB_ORDER:
		nav_box.add_child(_make_tab_button(tid, _tab_count_label(tid, active_list, offers_list, board_list, stories_list, cap), false))

	var meter_box: VBoxContainer = Illustrated.inset(parent, tr("Thưởng vĩnh viễn (Cap)"))
	var ml := Label.new()
	ml.text = "%.1f / %.0f W%s" % [gain_w, cap_w, (" (0 W còn lại)" if not can_boon else "")]
	ml.theme_type_variation = &"RowLabel"
	ml.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ml.add_theme_color_override("font_color", Illustrated.CINNABAR if not can_boon else Illustrated.INK)
	meter_box.add_child(ml)
	meter_box.add_child(Illustrated.gauge(gain_w / maxf(1.0, cap_w), Illustrated.CINNABAR if not can_boon else Illustrated.BRASS, 10.0))

	# Compact active stories overview in sidebar so story budget left stays visible alongside Journal (AC-QS-81).
	if not stories_list.is_empty():
		var sb: VBoxContainer = Illustrated.inset(parent, tr("Chuỗi sự kiện đang chạy"))
		sb.get_parent().name = "SidebarStories"
		for raw_s in stories_list:
			if not (raw_s is Dictionary):
				continue
			var st: Dictionary = raw_s as Dictionary
			var sl := Label.new()
			sl.text = "• %s\n  %s · Quỹ còn: %d LT" % [
				str(st.get("name", "")),
				str(st.get("stage_label", st.get("stage", ""))),
				int(st.get("budget_left", 0)),
			]
			sl.theme_type_variation = &"RowLabel"
			sl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			sl.add_theme_color_override("font_color", Illustrated.INK)
			sb.add_child(sl)


func _make_tab_button(tab_id: String, count_str: String, is_compact: bool) -> Button:
	var active: bool = tab_id == _active_tab
	var b := Button.new()
	b.name = "Tab_" + tab_id
	b.theme_type_variation = &"CommitButton" if active else &"TextButton"
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	var title: String = _tab_title(tab_id)
	if is_compact:
		b.text = "%s (%s)" % [title, count_str]
	else:
		b.text = "%s%s  [%s]" % [("▸ " if active else ""), title, count_str]
	b.accessibility_name = "%s, %s" % [title, count_str]
	TooltipLayer.set_tip(b, {"title": title, "fact": count_str, "summary": _tab_summary(tab_id)})
	b.pressed.connect(func(): select_tab(tab_id))
	return b


# --- Tab 1: Active Journal -------------------------------------------------------------------------------------------

func _build_journal_tab(parent: Control, active_list: Array, completed_list: Array, cap: int) -> void:
	var box: VBoxContainer = section_in(parent, "active_journal", tr("Nhật ký ủy thác đang làm (%d/%d)") % [active_list.size(), cap])
	box.get_parent().name = "ActiveJournalSection"
	if active_list.is_empty():
		var empty_l := line(tr("Chưa nhận ủy thác nào. Xem mục Lời mời hoặc Bảng ủy thác tại địa điểm hiện tại."), box)
		empty_l.name = "EmptyJournal"
	else:
		for raw_q in active_list:
			if raw_q is Dictionary:
				_add_active_quest_card(box, raw_q as Dictionary)

	if not completed_list.is_empty():
		var cbox: VBoxContainer = section_in(parent, "completed_quests", tr("Ủy thác đã kết thúc (%d)") % completed_list.size())
		for raw_c in completed_list.slice(0, 8):
			if not (raw_c is Dictionary):
				continue
			var cq: Dictionary = raw_c as Dictionary
			var row_l := Label.new()
			row_l.text = "• [%s] %s — %s (%s)" % [
				_tier_label(str(cq.get("tier", ""))),
				str(cq.get("name", "")),
				_state_label(str(cq.get("state", ""))),
				str(cq.get("offerer_name", "")),
			]
			row_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			cbox.add_child(row_l)


func _add_active_quest_card(parent: Control, q: Dictionary) -> void:
	var qid: String = str(q.get("id", ""))
	var state_s: String = str(q.get("state", "active"))
	var is_orphaned: bool = state_s == "orphaned"
	var is_focused: bool = _focus_id != "" and _focus_id == qid
	var stage_n: int = int(q.get("stage", 1))
	var stage_cnt: int = maxi(1, int(q.get("stage_count", 1)))
	var seasons_left: int = int(q.get("seasons_left", 0))
	var rem_s: int = int(q.get("remaining_s_i", 0))
	var tight: bool = bool(q.get("tight_deadline_warn", false))
	var cur: Dictionary = Dictionary(q.get("current_stage", {}))
	var cur_kind: String = str(cur.get("kind", ""))

	var card := PanelContainer.new()
	card.name = "QuestCard_" + qid
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.add_theme_stylebox_override("panel", Illustrated.box(
		Illustrated.PAPER,
		Illustrated.CINNABAR if (tight or is_focused) else Illustrated.BRASS,
		2,
		8.0,
		3
	))

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 4)
	card.add_child(col)

	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 8)
	col.add_child(top)

	var title_l := Label.new()
	title_l.text = str(q.get("name", qid))
	title_l.theme_type_variation = &"HeadingLabel"
	title_l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	top.add_child(title_l)

	top.add_child(_badge_pill(_tier_label(str(q.get("tier", ""))), Illustrated.PAPER_TILE, Illustrated.GILT))
	top.add_child(_badge_pill(
		tr("Khuyết chủ (Orphaned)") if is_orphaned else tr("Giai đoạn %d/%d") % [stage_n, stage_cnt],
		Illustrated.CINNABAR if is_orphaned else Illustrated.PAPER_TILE,
		Illustrated.BONE if is_orphaned else Illustrated.INK
	))

	# Progress gauge + deadline line.
	col.add_child(Illustrated.gauge(float(stage_n) / float(stage_cnt), Illustrated.CINNABAR if tight else Illustrated.BRASS, 10.0))

	var meta := Label.new()
	meta.name = "QuestMeta_" + qid
	meta.theme_type_variation = &"RowLabel"
	meta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var offerer_str: String = str(q.get("offerer_name", ""))
	var budget_b: int = int(Dictionary(q.get("budget", {})).get("B", 0))
	var paid_tot: int = int(q.get("paid_total", 0))
	meta.text = tr("Người giao: %s  ·  Còn lại: %d mùa (cần ~%d mùa)  ·  Ngân sách: %d LT (đã nhận %d LT)") % [
		offerer_str if offerer_str != "" else tr("Bảng ủy thác"),
		seasons_left,
		rem_s,
		budget_b,
		paid_tot,
	]
	col.add_child(meta)

	if tight:
		var warn_panel := PanelContainer.new()
		warn_panel.name = "TightDeadlineWarn_" + qid
		warn_panel.add_theme_stylebox_override("panel", Illustrated.box(Illustrated.PAPER_TILE, Illustrated.CINNABAR, 1, 6.0, 2))
		var wl := Label.new()
		wl.text = tr("⚠ Cảnh báo gấp hạn! Chỉ còn %d mùa nhưng các bước còn lại cần ít nhất %d mùa.") % [seasons_left, rem_s]
		wl.theme_type_variation = &"RowLabel"
		wl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		wl.add_theme_color_override("font_color", Illustrated.CINNABAR)
		warn_panel.add_child(wl)
		col.add_child(warn_panel)

	if not cur.is_empty():
		var st_box: VBoxContainer = Illustrated.inset(col, tr("Bước hiện tại (%d/%d): %s") % [stage_n, stage_cnt, _stage_kind_label(cur_kind)])
		var st_title: String = str(cur.get("title", ""))
		var st_place: String = str(cur.get("place_name", cur.get("place_id", "")))
		var st_desc: String = str(cur.get("description", _text_join(cur.get("text", []))))
		var head_txt: String = st_title
		if st_place != "":
			head_txt += (" — " if head_txt != "" else "") + tr("Địa điểm: %s") % st_place
		if head_txt != "":
			var hl := Label.new()
			hl.text = head_txt
			hl.theme_type_variation = &"RowLabel"
			hl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			st_box.add_child(hl)
		if st_desc != "":
			var dl := Label.new()
			dl.text = st_desc
			dl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			st_box.add_child(dl)

	var later: Array = Array(q.get("later_stages", []))
	if not later.is_empty():
		var parts: PackedStringArray = PackedStringArray()
		for ls in later:
			if ls is Dictionary:
				var ld: Dictionary = ls as Dictionary
				var lp: String = str(ld.get("place_name", ld.get("place_id", "")))
				parts.append(tr("Bước %d: [%s]%s") % [
					int(ld.get("stage", 0)),
					_stage_kind_label(str(ld.get("kind", ""))),
					(" tại %s" % lp) if lp != "" else "",
				])
		var ll := Label.new()
		ll.text = tr("Các bước sau (chỉ loại & nơi): ") + " · ".join(parts)
		ll.theme_type_variation = &"RowLabel"
		ll.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		ll.add_theme_color_override("font_color", Color(Illustrated.INK, 0.78))
		col.add_child(ll)

	# Action buttons row.
	var actions := HFlowContainer.new()
	actions.add_theme_constant_override("h_separation", 8)
	actions.add_theme_constant_override("v_separation", 6)
	col.add_child(actions)

	match cur_kind:
		"deliver":
			var db := action_button(tr("Giao nộp vật phẩm (1 mùa)"), "quest_deliver", [qid, ""], actions)
			db.name = "Deliver_" + qid
			db.theme_type_variation = &"CommitButton"
		"mission":
			var mb := action_button(tr("Làm nhiệm vụ ủy thác (1 mùa)"), "quest_mission", [qid], actions)
			mb.name = "Mission_" + qid
			mb.theme_type_variation = &"CommitButton"
		"event", "defeat":
			var sb := action_button(tr("Bắt đầu bước này (1 mùa)"), "quest_start_stage", [qid], actions)
			sb.name = "StartStage_" + qid
			sb.theme_type_variation = &"CommitButton"

	var cur_place_id: String = str(cur.get("place_id", ""))
	if cur_place_id != "":
		var tb := action_button(tr("Đi tới %s") % str(cur.get("place_name", cur_place_id)), "travel_place", [cur_place_id], actions)
		tb.name = "Travel_" + qid
		tb.theme_type_variation = &"TextButton"

	if is_orphaned:
		var drop_b := action_button(tr("Bỏ ủy thác (không phạt)"), "quest_drop", [qid], actions)
		drop_b.name = "Drop_" + qid
	else:
		var ab := action_button(tr("Từ bỏ (Abandon)"), "quest_abandon", [qid], actions)
		ab.name = "Abandon_" + qid

	parent.add_child(card)


# --- Tab 2: Offers (AC-QS-79, 80, 89, 119, 128) ----------------------------------------------------------------------

func _build_offers_tab(
	parent: Control,
	offers_list: Array,
	active_count: int,
	cap: int,
	gain_w: float,
	cap_w: float,
	can_boon: bool
) -> void:
	var box: VBoxContainer = section_in(parent, "quest_offers", tr("Lời mời ủy thác cá nhân & tông môn (%d)") % offers_list.size())
	box.get_parent().name = "OffersSection"
	if offers_list.is_empty():
		var empty_l := line(tr("Hiện không có lời mời ủy thác nào. Gặp gỡ nhân vật hoặc hỏi việc (Hỏi việc / Ask for work) để nhận đề nghị."), box)
		empty_l.name = "EmptyOffers"
		return
	for raw_o in offers_list:
		if raw_o is Dictionary:
			_add_offer_card(box, raw_o as Dictionary, active_count, cap, gain_w, cap_w, can_boon, false)


func _add_offer_card(
	parent: Control,
	q: Dictionary,
	active_count: int,
	cap: int,
	gain_w: float,
	cap_w: float,
	can_boon_global: bool,
	is_board: bool
) -> void:
	var qid: String = str(q.get("id", ""))
	var tier: String = str(q.get("tier", "ordinary"))
	var offer_kind: String = str(q.get("offer_kind", "board" if is_board else "person"))
	var deadline: int = int(q.get("deadline", q.get("seasons_left", 0)))
	var offerer_name: String = str(q.get("offerer_name", q.get("offerer_id", "")))
	var place_name: String = str(q.get("place_name", q.get("place_id", "")))
	var adversary_name: String = str(q.get("adversary_name", q.get("adversary_id", "")))
	var source_fact: Dictionary = Dictionary(q.get("source_fact", {}))
	var stake_text: String = str(q.get("stake_text", ""))
	var offer_lines: Array = Array(q.get("offer_text", []))
	var budget: Dictionary = Dictionary(q.get("budget", {}))
	var outcomes: Array = Array(q.get("outcomes", []))
	var stage_1: Dictionary = Dictionary(q.get("stage_1", q.get("current_stage", {})))
	var later_stages: Array = Array(q.get("later_stages", []))
	var has_lasting: bool = bool(q.get("has_lasting_gain", false))
	var can_boon: bool = bool(q.get("can_gain_boon", can_boon_global))

	var card := PanelContainer.new()
	card.name = ("BoardCard_" if is_board else "OfferCard_") + qid
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.add_theme_stylebox_override("panel", Illustrated.box(
		Illustrated.PAPER,
		Illustrated.CINNABAR if tier in ["major", "legendary"] else Illustrated.BRASS,
		2,
		8.0,
		3
	))

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 4)
	card.add_child(col)

	# Header: Name + Tier + Offer kind + Deadline
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 8)
	col.add_child(top)

	var tl := Label.new()
	tl.text = str(q.get("name", qid))
	tl.theme_type_variation = &"HeadingLabel"
	tl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	top.add_child(tl)

	top.add_child(_badge_pill(
		_tier_label(tier),
		Illustrated.CINNABAR if tier in ["major", "legendary"] else Illustrated.PAPER_TILE,
		Illustrated.BONE if tier in ["major", "legendary"] else Illustrated.GILT
	))
	top.add_child(_badge_pill(tr("Hạn: %d mùa") % deadline, Illustrated.PAPER_TILE, Illustrated.INK))

	# Offerer, Place, Source Fact, Adversary (Rule 6, AC-QS-79, AC-QS-119)
	var meta_lines: PackedStringArray = PackedStringArray()
	if offerer_name != "":
		meta_lines.append(tr("Người giao (%s): %s") % [_offer_kind_label(offer_kind), offerer_name])
	if place_name != "":
		meta_lines.append(tr("Địa điểm: %s") % place_name)
	if not meta_lines.is_empty():
		var ml := Label.new()
		ml.text = "  ·  ".join(meta_lines)
		ml.theme_type_variation = &"RowLabel"
		ml.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		col.add_child(ml)

	var sf_text: String = _format_source_fact(source_fact, stake_text)
	if sf_text != "":
		var sfl := Label.new()
		sfl.name = "SourceFact_" + qid
		sfl.text = tr("Nguyên do (Source fact): %s") % sf_text
		sfl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		sfl.add_theme_color_override("font_color", Illustrated.INK)
		col.add_child(sfl)

	var offer_body: String = _text_join(offer_lines)
	if offer_body != "":
		var obl := Label.new()
		obl.text = offer_body
		obl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		obl.add_theme_color_override("font_color", Color(Illustrated.INK, 0.9))
		col.add_child(obl)

	if adversary_name != "":
		var adv_l := Label.new()
		adv_l.name = "Adversary_" + qid
		adv_l.text = tr("Đối thủ liên quan (Adversary): %s") % adversary_name
		adv_l.theme_type_variation = &"RowLabel"
		adv_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		adv_l.add_theme_color_override("font_color", Illustrated.CINNABAR)
		col.add_child(adv_l)

	# Resolved world effects (outcomes: ending, role, effect, amount; AC-QS-119, AC-QS-128)
	if not outcomes.is_empty():
		var ob: VBoxContainer = Illustrated.inset(col, tr("Tác động thế giới (Resolved World Outcomes)"))
		ob.get_parent().name = "WorldOutcomes_" + qid
		var ogrid: GridContainer = Illustrated.grid(ob, 1 if compact else 2, 4)
		for raw_oc in outcomes:
			if not (raw_oc is Dictionary):
				continue
			var oc: Dictionary = raw_oc as Dictionary
			var ocl := Label.new()
			ocl.text = "• " + _format_world_outcome(oc)
			ocl.theme_type_variation = &"RowLabel"
			ocl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			ocl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			ogrid.add_child(ocl)

	# Budget Breakdown (Rule 6, Formula A)
	var b_val: int = int(budget.get("B", 0))
	var stage_pays: Array = Array(budget.get("stage_pays", []))
	var final_pay: int = int(budget.get("final_pay", 0))
	var cash_max: int = int(budget.get("cash_max", 0))
	var deliver_max: int = int(budget.get("deliver_max", 0))
	var s_plan: int = int(budget.get("S_plan", 0))
	var sp_strs: PackedStringArray = PackedStringArray()
	for sp in stage_pays:
		sp_strs.append("%d LT" % int(sp))
	var bd_lines: Array = [
		tr("Tổng ngân sách B: %d LT (S_plan = %d mùa)") % [b_val, s_plan],
		tr("Thưởng các bước: %s") % (", ".join(sp_strs) if not sp_strs.is_empty() else "—"),
		tr("Thưởng chốt (Final): %d LT") % final_pay,
		tr("Trần tiền mặt (20%%): %d LT  ·  Trần giao nộp (50%%): %d LT") % [cash_max, deliver_max],
	]
	var bd_panel := PanelContainer.new()
	bd_panel.name = "BudgetBreakdown_" + qid
	bd_panel.focus_mode = Control.FOCUS_ALL
	bd_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	bd_panel.add_theme_stylebox_override("panel", Illustrated.box(Illustrated.PAPER_TILE, Illustrated.BRASS_DIM, 1, 8.0, 2))
	var bd_lbl := Label.new()
	bd_lbl.text = tr("Ngân sách B = %d LT  (Các bước: %s · Chốt: %d LT · Trần tiền mặt: %d LT)") % [
		b_val,
		", ".join(sp_strs) if not sp_strs.is_empty() else "0",
		final_pay,
		cash_max,
	]
	bd_lbl.theme_type_variation = &"RowLabel"
	bd_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bd_panel.add_child(bd_lbl)
	TooltipLayer.set_tip(bd_panel, {
		"title": tr("Chi tiết ngân sách ủy thác (Budget Breakdown)"),
		"fact": "%d LT" % b_val,
		"summary": tr("Ngân sách bị khóa cố định ngay khi nhận ủy thác (Formula A)."),
		"lines": bd_lines,
	})
	col.add_child(bd_panel)

	# Stage 1 in full + Later stages as kind & place ONLY (AC-QS-79)
	if not stage_1.is_empty():
		var s1_kind: String = str(stage_1.get("kind", ""))
		var s1_box: VBoxContainer = Illustrated.inset(col, tr("Bước 1 (Chi tiết đầy đủ): %s") % _stage_kind_label(s1_kind))
		s1_box.get_parent().name = "Stage1Full_" + qid
		var s1_title: String = str(stage_1.get("title", ""))
		var s1_place: String = str(stage_1.get("place_name", stage_1.get("place_id", "")))
		var s1_win: int = int(stage_1.get("window", 0))
		var s1_head: String = s1_title
		if s1_place != "":
			s1_head += (" — " if s1_head != "" else "") + tr("Tại: %s") % s1_place
		if s1_win > 0:
			s1_head += tr(" (Cửa sổ: %d mùa)") % s1_win
		if s1_head != "":
			var shl := Label.new()
			shl.text = s1_head
			shl.theme_type_variation = &"RowLabel"
			shl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			s1_box.add_child(shl)
		var s1_desc: String = str(stage_1.get("description", _text_join(stage_1.get("text", []))))
		if s1_desc != "":
			var sdl := Label.new()
			sdl.text = s1_desc
			sdl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			s1_box.add_child(sdl)

	if not later_stages.is_empty():
		var l_parts: PackedStringArray = PackedStringArray()
		for i in later_stages.size():
			var ls: Dictionary = later_stages[i] if later_stages[i] is Dictionary else {}
			var st_num: int = int(ls.get("stage", i + 2))
			var lk: String = _stage_kind_label(str(ls.get("kind", "")))
			var lp: String = str(ls.get("place_name", ls.get("place_id", "")))
			l_parts.append(tr("Bước %d: [%s]%s") % [st_num, lk, (" tại %s" % lp) if lp != "" else ""])
		var lsl := Label.new()
		lsl.name = "LaterStages_" + qid
		lsl.text = tr("Các bước sau (chỉ hiện loại & địa điểm): ") + "  ·  ".join(l_parts)
		lsl.theme_type_variation = &"RowLabel"
		lsl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lsl.add_theme_color_override("font_color", Color(Illustrated.INK, 0.8))
		col.add_child(lsl)

	# Lasting-gain / Cap-0 notice (AC-QS-89)
	if has_lasting or (not can_boon and tier in ["major", "legendary"]):
		var lg_panel := PanelContainer.new()
		lg_panel.name = "LastingGainNotice_" + qid
		var no_room: bool = not can_boon
		lg_panel.add_theme_stylebox_override("panel", Illustrated.box(
			Illustrated.PAPER_TILE,
			Illustrated.CINNABAR if no_room else Illustrated.BRASS,
			1,
			6.0,
			2
		))
		var lgl := Label.new()
		lgl.theme_type_variation = &"RowLabel"
		lgl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		if no_room:
			lgl.text = tr("⚠ Không còn hạn mức thưởng vĩnh viễn (%.1f / %.0f W — còn 0 W): hoàn thành ủy thác này sẽ KHÔNG trao thưởng chỉ số vĩnh viễn hay điểm Đạo Đồ.") % [gain_w, cap_w]
			lgl.add_theme_color_override("font_color", Illustrated.CINNABAR)
		else:
			lgl.text = tr("✦ Có cơ hội nhận thưởng vĩnh viễn (Quest Boon / Điểm Đạo Đồ · Đã dùng %.1f / %.0f W).") % [gain_w, cap_w]
			lgl.add_theme_color_override("font_color", Illustrated.GILT)
		lg_panel.add_child(lgl)
		col.add_child(lg_panel)

	# Accept / Decline buttons
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 10)
	col.add_child(actions)

	var accept_reason: String = tr("Đã đủ %d/%d ủy thác đang làm.") % [active_count, cap] if active_count >= cap else ""
	var acc := action_button(tr("Nhận ủy thác (Accept)"), "quest_accept", [qid], actions, accept_reason)
	acc.name = "Accept_" + qid
	acc.theme_type_variation = &"CommitButton"

	if not is_board:
		var dec := action_button(tr("Từ chối (Decline)"), "quest_decline", [qid], actions)
		dec.name = "Decline_" + qid

	parent.add_child(card)


# --- Tab 3: Board (AC-QS-80) -----------------------------------------------------------------------------------------

func _build_board_tab(parent: Control, board_list: Array, active_count: int, cap: int) -> void:
	var box: VBoxContainer = section_in(parent, "quest_board", tr("Bảng ủy thác địa phương (%d/3)") % board_list.size())
	box.get_parent().name = "BoardSection"
	var info := Label.new()
	info.name = "BoardInfo"
	info.text = tr("Bảng ủy thác tại Tông môn / Trấn thị đăng tối đa 3 phiếu (Tạp vụ / Thường vụ). Xem hoặc bỏ qua phiếu trên bảng KHÔNG kích hoạt hồi chiêu.")
	info.theme_type_variation = &"RowLabel"
	info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(info)
	if board_list.is_empty():
		var empty_l := line(tr("Địa điểm hiện tại không có phiếu nào trên bảng ủy thác."), box)
		empty_l.name = "EmptyBoard"
		return
	for raw_b in board_list:
		if raw_b is Dictionary:
			_add_offer_card(box, raw_b as Dictionary, active_count, cap, 0.0, 48.0, false, true)


# --- Tab 4: Stories (AC-QS-81) ---------------------------------------------------------------------------------------

func _build_stories_tab(parent: Control, stories_list: Array) -> void:
	var box: VBoxContainer = section_in(parent, "active_stories", tr("Chuỗi sự kiện đang diễn ra (%d)") % stories_list.size())
	box.get_parent().name = "StoriesSection"
	if stories_list.is_empty():
		var empty_l := line(tr("Chưa có chuỗi sự kiện nào đang mở. Khám phá thế giới, trò chuyện với nhân vật hoặc kích hoạt cơ duyên để mở mạch truyện."), box)
		empty_l.name = "EmptyStories"
		return
	for raw_st in stories_list:
		if not (raw_st is Dictionary):
			continue
		var st: Dictionary = raw_st as Dictionary
		var sid: String = str(st.get("id", ""))
		var is_focused: bool = _focus_id != "" and _focus_id == sid
		var card := PanelContainer.new()
		card.name = "StoryCard_" + sid
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.add_theme_stylebox_override("panel", Illustrated.box(
			Illustrated.PAPER,
			Illustrated.CINNABAR if is_focused else Illustrated.BRASS,
			2,
			10.0,
			3
		))
		var col := VBoxContainer.new()
		col.add_theme_constant_override("separation", 4)
		card.add_child(col)

		var top := HBoxContainer.new()
		top.add_theme_constant_override("separation", 8)
		col.add_child(top)

		var tl := Label.new()
		tl.text = str(st.get("name", sid))
		tl.theme_type_variation = &"HeadingLabel"
		tl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		top.add_child(tl)

		top.add_child(_badge_pill(str(st.get("stage_label", st.get("stage", ""))), Illustrated.PAPER_TILE, Illustrated.GILT))

		var last_ev: String = str(st.get("last_event", ""))
		if last_ev != "":
			var le := Label.new()
			le.text = tr("Sự kiện gần nhất: %s") % last_ev
			le.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			col.add_child(le)

		var meta := Label.new()
		meta.name = "StoryBudget_" + sid
		meta.theme_type_variation = &"RowLabel"
		meta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		meta.text = tr("Ngân sách chuỗi còn lại: %d LT  ·  Vật phẩm còn lại: %d  ·  Hết hạn sau: %d mùa") % [
			int(st.get("budget_left", 0)),
			int(st.get("items_left", 0)),
			int(st.get("timeout_left", 0)),
		]
		col.add_child(meta)
		box.add_child(card)


# --- Helpers ---------------------------------------------------------------------------------------------------------

func _infer_tab_for_id(v: Dictionary, target_id: String) -> String:
	for raw in Array(v.get("active", [])):
		if raw is Dictionary and str((raw as Dictionary).get("id", "")) == target_id:
			return TAB_JOURNAL
	for raw in Array(v.get("offers", [])):
		if raw is Dictionary and str((raw as Dictionary).get("id", "")) == target_id:
			return TAB_OFFERS
	for raw in Array(v.get("board", [])):
		if raw is Dictionary and str((raw as Dictionary).get("id", "")) == target_id:
			return TAB_BOARD
	for raw in Array(v.get("stories", [])):
		if raw is Dictionary and str((raw as Dictionary).get("id", "")) == target_id:
			return TAB_STORIES
	return ""


static func _badge_pill(text: String, bg: Color, fg: Color) -> PanelContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", Illustrated.box(bg, Illustrated.BRASS, 1, 4.0, 3))
	var l := Label.new()
	l.text = text
	l.theme_type_variation = &"RowLabel"
	l.add_theme_color_override("font_color", fg)
	p.add_child(l)
	return p


static func _tab_title(tab_id: String) -> String:
	match tab_id:
		TAB_JOURNAL: return "Nhật ký (Journal)"
		TAB_OFFERS: return "Lời mời (Offers)"
		TAB_BOARD: return "Bảng ủy thác (Board)"
		TAB_STORIES: return "Chuỗi sự kiện (Stories)"
	return tab_id


static func _tab_summary(tab_id: String) -> String:
	match tab_id:
		TAB_JOURNAL: return "Các ủy thác đang thực hiện và ủy thác khuyết chủ, kèm tiến độ bước và cảnh báo hạn."
		TAB_OFFERS: return "Lời mời ủy thác từ nhân vật và tông môn, hiển thị đầy đủ ngân sách, tác động thế giới và bước 1."
		TAB_BOARD: return "Bảng ủy thác địa phương (3 phiếu, không hồi chiêu khi xem hoặc bỏ qua)."
		TAB_STORIES: return "Các mạch truyện Event Engine đang diễn ra, tách biệt khỏi hạn mức ủy thác."
	return ""


static func _tab_count_label(
	tab_id: String,
	active_list: Array,
	offers_list: Array,
	board_list: Array,
	stories_list: Array,
	cap: int
) -> String:
	match tab_id:
		TAB_JOURNAL: return "%d/%d" % [active_list.size(), cap]
		TAB_OFFERS: return "%d" % offers_list.size()
		TAB_BOARD: return "%d/3" % board_list.size()
		TAB_STORIES: return "%d" % stories_list.size()
	return "0"


static func _tier_label(tier: String) -> String:
	match tier:
		"errand", "minor": return "Tạp vụ"
		"ordinary": return "Thường vụ"
		"major": return "Trọng vụ"
		"legendary": return "Truyền kỳ"
	return tier.capitalize()


static func _state_label(st: String) -> String:
	match st:
		"active": return "Đang làm"
		"orphaned": return "Khuyết chủ"
		"completed": return "Hoàn thành"
		"failed": return "Thất bại"
		"lapsed": return "Quá hạn"
		"dropped": return "Đã bỏ"
		"declined": return "Từ chối"
		"withdrawn": return "Đã rút"
	return st


static func _offer_kind_label(k: String) -> String:
	match k:
		"person": return "Nhân vật"
		"sect": return "Tông môn"
		"board": return "Bảng ủy thác"
	return k


static func _stage_kind_label(k: String) -> String:
	match k:
		"event": return "Sự kiện (event)"
		"visit": return "Thăm gặp (visit)"
		"deliver": return "Giao nộp (deliver)"
		"craft": return "Luyện chế (craft)"
		"mission": return "Nhiệm vụ (mission)"
		"reach": return "Đột phá / Đạt mốc (reach)"
		"defeat": return "Đánh bại (defeat)"
	return k


static func _format_source_fact(sf: Dictionary, stake_text: String) -> String:
	var sf_txt: String = str(sf.get("text", sf.get("summary", ""))).strip_edges()
	var sf_kind: String = str(sf.get("kind", "")).strip_edges()
	if sf_txt != "" and stake_text != "" and sf_txt != stake_text:
		return "%s — %s" % [sf_txt, stake_text]
	if sf_txt != "":
		return ("[%s] %s" % [sf_kind, sf_txt]) if sf_kind != "" else sf_txt
	if stake_text != "":
		return ("[%s] %s" % [sf_kind, stake_text]) if sf_kind != "" else stake_text
	if sf_kind != "":
		return sf_kind
	return ""


static func _format_world_outcome(oc: Dictionary) -> String:
	var on_key: String = str(oc.get("on", "completed"))
	var on_lbl: String = "Khi hoàn thành" if on_key == "completed" else ("Khi thất bại" if on_key == "failed" else on_key)
	var role_key: String = str(oc.get("role", ""))
	var role_lbl: String = _outcome_role_label(role_key)
	var eff: String = str(oc.get("effect", ""))
	var amt: Variant = oc.get("amount", null)
	var eff_lbl: String = ""
	match eff:
		"wealth":
			var n: int = int(amt) if amt != null else 0
			eff_lbl = "Tài sản %+d LT" % n if n != 0 else "Biến động tài sản"
		"standing":
			var ns: int = int(amt) if amt != null else 0
			eff_lbl = "Danh vọng %+d" % ns if ns != 0 else "Biến động danh vọng"
		"injury":
			var inj: float = float(amt) if amt != null else 0.0
			var pct: int = roundi(inj * 100.0) if inj <= 1.0 and inj > 0.0 else roundi(inj)
			eff_lbl = "Thương tích %d%%" % pct
		"rank":
			eff_lbl = "Biến động chức vị (rank)"
		"death":
			eff_lbl = "Tử vong (death)"
		_:
			eff_lbl = eff
	return "%s · %s · %s" % [on_lbl, role_lbl, eff_lbl]


static func _outcome_role_label(role: String) -> String:
	match role:
		"offerer": return "Người giao"
		"adversary": return "Đối thủ"
		"offerer_ties": return "Thân hữu người giao"
		"adversary_ties": return "Thân hữu đối thủ"
		"offerer_sect": return "Tông môn người giao"
		"adversary_sect": return "Tông môn đối thủ"
	return role


static func _text_join(raw: Variant) -> String:
	if raw is Array:
		var out: PackedStringArray = PackedStringArray()
		for item in raw:
			var s: String = str(item).strip_edges()
			if s != "":
				out.append(s)
		return " ".join(out)
	return str(raw).strip_edges()
