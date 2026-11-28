class_name NewsWindow
extends GameWindow
## The World News & Uncovered Chronicles window (Event Engine #23 Rule 20 AC-EV-36 + World Gen AC-WG-56;
## Z6 hotkey N). Built strictly from read-only [method GameQuery.event_news] dictionaries (ADR-0006):
## never reads or mutates [GameSession], and strictly never displays still-hidden secret chronicles.

## Emitted when the player changes the filter tab ("all", "news", "chronicles").
signal filter_selected(filter_id: String)

const FILTER_ALL := "all"
const FILTER_NEWS := "news"
const FILTER_CHRONICLES := "chronicles"
const FILTER_ORDER := [FILTER_ALL, FILTER_NEWS, FILTER_CHRONICLES]

## Optional `ui_windows.json` config.
var cfg: Dictionary = {}

var _filter: String = FILTER_ALL
var _search := LineEdit.new()
var _count := Label.new()
var _rows: Array = []   # [[Control, folded_text]]


func kind() -> String:
	return "news"


func window_title(_v: Dictionary) -> String:
	return tr("News & Chronicles (Tin Giang Hồ & Bí Sử)")


func first_focus() -> Control:
	if _search.is_inside_tree() and _search.visible:
		return _search
	return super.first_focus()


## The active filter ("all", "news", "chronicles").
func active_filter() -> String:
	return _filter


## Switches filter to [param filter_id] and rebuilds in place.
func select_filter(filter_id: String) -> void:
	if not (filter_id in FILTER_ORDER) or filter_id == _filter:
		return
	_filter = filter_id
	filter_selected.emit(filter_id)
	if not view.is_empty():
		var saved: String = _search.text
		show_view(view, "", locked)
		_search.text = saved
		_on_search(saved)


func show_view(v: Dictionary, section: String, is_locked: bool) -> void:
	for c in [_search, _count]:
		if c.get_parent() != null:
			c.get_parent().remove_child(c)
	if section in FILTER_ORDER:
		_filter = section
	elif str(v.get("active_filter", "")) in FILTER_ORDER:
		_filter = str(v.get("active_filter", ""))
	super.show_view(v, "", is_locked)


func _build() -> void:
	var v: Dictionary = view
	_rows.clear()
	var news_list: Array = _filter_visible(Array(v.get("news", [])))
	var annals_list: Array = _filter_visible(Array(v.get("annals_uncovered", [])))

	_build_header(news_list.size(), annals_list.size())

	var ground: VBoxContainer = Illustrated.ground(body)
	if _filter in [FILTER_ALL, FILTER_CHRONICLES]:
		_build_chronicles_section(ground, annals_list)
	if _filter in [FILTER_ALL, FILTER_NEWS]:
		_build_news_section(ground, news_list)

	var foot := Label.new()
	foot.text = tr("Tin giang hồ (N) · Chỉ hiển thị tin người quen, sự kiện chấn động và bí sử đã giải mật")
	foot.theme_type_variation = &"RowLabel"
	foot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	foot.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bar.add_child(foot)
	_on_search(_search.text)


func _build_header(news_n: int, annals_n: int) -> void:
	var summary := Label.new()
	summary.name = "NewsSummary"
	summary.text = tr("Tin giang hồ: %d  ·  Bí sử đã khai mở kiếp này: %d") % [news_n, annals_n]
	summary.theme_type_variation = &"RowLabel"
	summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	TooltipLayer.set_tip(summary, {
		"title": tr("Tin Giang Hồ & Bí Sử"),
		"summary": tr("Ghi nhận biến cố của nhân vật đã quen biết, sự kiện lớn toàn giới (AC-EV-36), và các thiên bí sử đã được giải mật trong kiếp này (AC-WG-56)."),
	})
	header.add_child(summary)

	var tabs := HBoxContainer.new()
	tabs.name = "NewsFilterTabs"
	tabs.add_theme_constant_override("separation", 6)
	for fid in FILTER_ORDER:
		var b := Button.new()
		b.name = "Filter_" + fid
		var active: bool = fid == _filter
		b.theme_type_variation = &"CommitButton" if active else &"TextButton"
		match fid:
			FILTER_ALL:
				b.text = tr("Tất cả (%d)") % (news_n + annals_n)
			FILTER_NEWS:
				b.text = tr("Tin giang hồ (%d)") % news_n
			FILTER_CHRONICLES:
				b.text = tr("Bí sử đã khai mở (%d)") % annals_n
		TooltipLayer.set_tip(b, b.text)
		b.pressed.connect(func(): select_filter(fid))
		tabs.add_child(b)
	header.add_child(tabs)

	_search.placeholder_text = tr("Tìm kiếm tin tức hoặc bí sử…  (Ctrl+F)")
	_search.accessibility_name = tr("Search news and uncovered chronicles")
	if not _search.text_changed.is_connected(_on_search):
		_search.text_changed.connect(_on_search)
	header.add_child(_search)

	_count.accessibility_live = AccessibilityServer.LIVE_POLITE
	header.add_child(_count)


func _build_chronicles_section(parent: Control, annals_list: Array) -> void:
	var box: VBoxContainer = section_in(parent, "uncovered_chronicles", tr("Bí sử đã giải mật — Uncovered Chronicles (%d)") % annals_list.size())
	box.get_parent().name = "ChroniclesSection"
	if annals_list.is_empty():
		var empty_l := line(tr("Chưa giải mật thiên bí sử nào trong kiếp này. Theo đuổi các chuỗi sự kiện cổ sử để khai mở."), box)
		empty_l.name = "EmptyChronicles"
		return
	for i in annals_list.size():
		var ev: Dictionary = annals_list[i] as Dictionary
		var data: Dictionary = Dictionary(ev.get("data", {}))
		var cid: String = str(data.get("id", ev.get("id", "chron_%d" % i)))
		var title: String = str(data.get("title", data.get("name", cid)))
		var text: String = str(ev.get("text", ""))
		var year_n: int = int(ev.get("year", 0))
		var season_n: int = int(ev.get("season", 0))

		var card := PanelContainer.new()
		card.name = "Chronicle_" + cid
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.focus_mode = Control.FOCUS_ALL
		card.add_theme_stylebox_override("panel", Illustrated.box(Illustrated.PAPER, Illustrated.CINNABAR, 2, 10.0, 3))

		var col := VBoxContainer.new()
		col.add_theme_constant_override("separation", 4)
		card.add_child(col)

		var top := HBoxContainer.new()
		top.add_theme_constant_override("separation", 8)
		col.add_child(top)

		var id_badge := PanelContainer.new()
		id_badge.add_theme_stylebox_override("panel", Illustrated.box(Illustrated.CINNABAR, Illustrated.BRASS, 1, 4.0, 2))
		var id_l := Label.new()
		id_l.text = cid
		id_l.theme_type_variation = &"RowLabel"
		id_l.add_theme_color_override("font_color", Illustrated.BONE)
		id_badge.add_child(id_l)
		top.add_child(id_badge)

		var tl := Label.new()
		tl.text = title if title != cid else tr("Bí sử cổ đại")
		tl.theme_type_variation = &"HeadingLabel"
		tl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		top.add_child(tl)

		var uncov_badge := Label.new()
		uncov_badge.text = tr("✦ Bí sử đã giải mật")
		uncov_badge.theme_type_variation = &"RowLabel"
		uncov_badge.add_theme_color_override("font_color", Illustrated.CINNABAR)
		top.add_child(uncov_badge)

		var date_l := Label.new()
		date_l.text = tr("Năm %d · %s  ·  Hạng sử: %s") % [year_n, _season_name(season_n), str(data.get("tier", "annal"))]
		date_l.theme_type_variation = &"RowLabel"
		date_l.add_theme_color_override("font_color", Illustrated.GILT)
		col.add_child(date_l)

		var body_l := Label.new()
		body_l.text = text
		body_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		col.add_child(body_l)

		TooltipLayer.set_tip(card, {
			"title": "%s (%s)" % [title, cid],
			"fact": tr("Bí sử đã giải mật · Năm %d") % year_n,
			"summary": text,
		})
		box.add_child(card)
		_rows.append([card, WorldDB.fold(cid + " " + title + " " + text)])


func _build_news_section(parent: Control, news_list: Array) -> void:
	var box: VBoxContainer = section_in(parent, "world_news", tr("Tin giang hồ — World News (%d)") % news_list.size())
	box.get_parent().name = "WorldNewsSection"
	if news_list.is_empty():
		var empty_l := line(tr("Chưa có tin tức mới từ người quen hoặc sự kiện lớn nào."), box)
		empty_l.name = "EmptyNews"
		return
	for i in news_list.size():
		var ev: Dictionary = news_list[i] as Dictionary
		var data: Dictionary = Dictionary(ev.get("data", {}))
		var eid: String = str(ev.get("id", "news_%d" % i))
		var text: String = str(ev.get("text", ""))
		var year_n: int = int(ev.get("year", 0))
		var season_n: int = int(ev.get("season", 0))
		var is_major: bool = bool(data.get("newsworthy", false))
		var narration: String = str(data.get("narration", "")).strip_edges()

		var card := PanelContainer.new()
		card.name = "News_" + eid
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.focus_mode = Control.FOCUS_ALL
		card.add_theme_stylebox_override("panel", Illustrated.box(
			Illustrated.PAPER if is_major else Illustrated.PAPER_TILE,
			Illustrated.BRASS if is_major else Illustrated.BRASS_DIM,
			2 if is_major else 1,
			8.0,
			3
		))

		var col := VBoxContainer.new()
		col.add_theme_constant_override("separation", 3)
		card.add_child(col)

		var top := HBoxContainer.new()
		top.add_theme_constant_override("separation", 8)
		col.add_child(top)

		var date_l := Label.new()
		date_l.text = tr("Năm %d · %s") % [year_n, _season_name(season_n)]
		date_l.theme_type_variation = &"RowLabel"
		date_l.add_theme_color_override("font_color", Illustrated.GILT)
		top.add_child(date_l)

		var tag_txt: String = tr("Tin chấn động (Newsworthy)") if is_major else tr("Tin người quen")
		var tag_l := Label.new()
		tag_l.text = tag_txt
		tag_l.theme_type_variation = &"RowLabel"
		tag_l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tag_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		tag_l.add_theme_color_override("font_color", Illustrated.CINNABAR if is_major else Color(Illustrated.INK, 0.72))
		top.add_child(tag_l)

		var body_l := Label.new()
		body_l.text = text
		body_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		col.add_child(body_l)

		if narration != "" and narration != text:
			var nl := Label.new()
			nl.text = narration
			nl.theme_type_variation = &"RowLabel"
			nl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			nl.add_theme_color_override("font_color", Color(Illustrated.INK, 0.78))
			col.add_child(nl)

		TooltipLayer.set_tip(card, {
			"title": tr("Năm %d · %s") % [year_n, _season_name(season_n)],
			"fact": tag_txt,
			"summary": text,
		})
		box.add_child(card)
		_rows.append([card, WorldDB.fold(text + " " + narration + " " + tag_txt)])


## Defensive filter: never show hidden/secret chronicle records even if passed in a malformed view.
static func _filter_visible(items: Array) -> Array:
	var out: Array = []
	for raw in items:
		if not (raw is Dictionary):
			continue
		var ev: Dictionary = raw as Dictionary
		var data: Dictionary = Dictionary(ev.get("data", {}))
		if str(ev.get("type", "")) == "hidden" or bool(data.get("secret", false)):
			continue
		out.append(ev)
	return out


static func _season_name(season_idx: int) -> String:
	match season_idx % 4:
		0: return "Xuân"
		1: return "Hạ"
		2: return "Thu"
		3: return "Đông"
	return "Xuân"


func _on_search(text: String) -> void:
	var q: String = WorldDB.fold(text.strip_edges())
	var hit: int = 0
	for r in _rows:
		var ctrl: Control = r[0] as Control
		var m: bool = q == "" or str(r[1]).contains(q)
		ctrl.visible = m
		hit += 1 if m else 0
	_count.text = "" if q == "" else tr("%d kết quả khớp") % hit
	_count.visible = _count.text != ""


func _unhandled_input(event: InputEvent) -> void:
	if is_visible_in_tree() and event is InputEventKey and event.is_pressed() and (event as InputEventKey).ctrl_pressed \
			and (event as InputEventKey).physical_keycode == KEY_F and _search.is_inside_tree():
		_search.grab_focus()
		get_viewport().set_input_as_handled()
		return
	super._unhandled_input(event)


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		for c in [_search, _count]:
			if is_instance_valid(c) and c.get_parent() == null:
				c.free()
