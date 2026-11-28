class_name CodexWindow
extends GameWindow
## The 10-book ink-wash Codex (Thiên Thư) window (design/gdd/codex-karmic-carryover.md, Rules 7-10,
## AC-CK-14, AC-CK-19). Built strictly from read-only [method GameQuery.codex_view] dictionaries
## (ADR-0006): never reads or mutates [GameSession].
##
## Layout: two-pane rosewood-and-parchment spread mirroring [WikiWindow] (left pinned 10-book index
## with seen/known counts; right scrolling entries pane). Seen entries are rendered in faint ink
## (`modulate.a = 0.65`) and known entries in full ink (`modulate.a = 1.0`), each book stating its
## gameplay effect. Known hidden places list only authored candidate regions/sites as rumours, never
## any per-game rolled site.

## Emitted when the player switches to another Codex book.
signal book_selected(book_id: String)

const SEEN_INK_ALPHA := 0.65
const KNOWN_INK_ALPHA := 1.0
const DEFAULT_NAV_WIDTH := 270
const FALLBACK_BOOK_ORDER := [
	"recipes", "variants", "secrets", "cast", "history",
	"techniques", "items", "beasts", "herbs", "lives",
]

## Optional `ui_windows.json` config dictionary (reads `codex.seen_alpha`, `codex.known_alpha`, `codex.nav_width`).
var cfg: Dictionary = {}

var _selected_book: String = ""
var _search := LineEdit.new()
var _count := Label.new()
var _entry_rows: Array = []   # [[Control, folded_search_text]]


func kind() -> String:
	return "codex"


func window_title(v: Dictionary) -> String:
	var active: String = _resolve_book(v)
	for b in Array(v.get("books", [])):
		if b is Dictionary and str(b.get("id", "")) == active:
			return "%s: %s" % [tr("Codex (Thiên Thư)"), str(b.get("name", active))]
	return tr("Codex (Thiên Thư)")


func first_focus() -> Control:
	if _search.is_inside_tree() and _search.visible:
		return _search
	return super.first_focus()


## The currently displayed book id ("" if view has no books).
func selected_book() -> String:
	return _selected_book


## Switches the displayed book to [param book_id] and rebuilds the view in place.
func select_book(book_id: String) -> void:
	if book_id == "" or book_id == _selected_book:
		return
	_selected_book = book_id
	book_selected.emit(book_id)
	if not view.is_empty():
		var saved_search: String = _search.text
		show_view(view, "", locked)
		_search.text = saved_search
		_on_search(saved_search)


func show_view(v: Dictionary, section: String, is_locked: bool) -> void:
	for c in [_search, _count]:
		if c.get_parent() != null:
			c.get_parent().remove_child(c)
	var req_book: String = str(v.get("active_book", ""))
	if req_book != "":
		_selected_book = req_book
	elif section != "" and _has_book(v, section):
		_selected_book = section
	super.show_view(v, "", is_locked)


func _build() -> void:
	var v: Dictionary = view
	_entry_rows.clear()
	var books: Array = Array(v.get("books", []))
	_selected_book = _resolve_book(v)
	_build_header(v, books)

	var ground: VBoxContainer = Illustrated.ground(body)
	if not compact and not books.is_empty():
		var nav_w: int = int(Dictionary(cfg.get("codex", {})).get("nav_width", DEFAULT_NAV_WIDTH))
		use_side(nav_w, true)
		_build_book_nav(Illustrated.ground(side), books)

	var book_data: Dictionary = _book_payload(v, _selected_book)
	_build_book_header(ground, book_data)
	if _selected_book == "lives":
		_build_lives_entries(ground, Array(book_data.get("entries", [])))
	else:
		_build_knowledge_entries(ground, book_data)

	var foot := Label.new()
	foot.text = tr("Thiên Thư · Profile memory shared across playthroughs (knowledge only, never stat power)")
	foot.theme_type_variation = &"RowLabel"
	foot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	foot.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bar.add_child(foot)
	_on_search(_search.text)


func _build_header(v: Dictionary, books: Array) -> void:
	var summary := Label.new()
	summary.name = "CodexSummary"
	summary.text = tr("Codex (Thiên Thư) · %d knowledge entries · %d lives recorded") % [
		int(v.get("total_entries", 0)),
		int(v.get("lives_count", 0)),
	]
	summary.theme_type_variation = &"RowLabel"
	summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	TooltipLayer.set_tip(summary, {
		"title": tr("Codex (Thiên Thư)"),
		"summary": tr("Entries are written the moment they are discovered in Fated-birth uncheated lives and never roll back on reload. Seen entries show in faint ink; known entries show in full ink."),
	})
	header.add_child(summary)

	var notice: String = str(v.get("notice", "")).strip_edges()
	if notice != "":
		var notice_panel := PanelContainer.new()
		notice_panel.name = "CodexNotice"
		notice_panel.add_theme_stylebox_override("panel", Illustrated.box(Illustrated.PAPER_TILE, Illustrated.CINNABAR, 2, 6.0, 2))
		var nl := Label.new()
		nl.text = notice
		nl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		nl.add_theme_color_override("font_color", Illustrated.CINNABAR)
		notice_panel.add_child(nl)
		header.add_child(notice_panel)

	if compact and not books.is_empty():
		var tabs := HFlowContainer.new()
		tabs.name = "CompactBookTabs"
		tabs.add_theme_constant_override("h_separation", 6)
		tabs.add_theme_constant_override("v_separation", 4)
		for b in books:
			if not (b is Dictionary):
				continue
			tabs.add_child(_make_book_button(b, true))
		header.add_child(tabs)

	_search.placeholder_text = tr("Search this book…  (Ctrl+F)")
	_search.accessibility_name = tr("Search this Codex book")
	if not _search.text_changed.is_connected(_on_search):
		_search.text_changed.connect(_on_search)
	header.add_child(_search)

	_count.accessibility_live = AccessibilityServer.LIVE_POLITE
	header.add_child(_count)


func _build_book_nav(parent: Control, books: Array) -> void:
	var box: VBoxContainer = Illustrated.inset(parent, tr("Ten Books (Thập Quyển)"))
	box.get_parent().name = "BookList"
	for b in books:
		if not (b is Dictionary):
			continue
		box.add_child(_make_book_button(b, false))


func _make_book_button(b: Dictionary, is_compact: bool) -> Button:
	var bid: String = str(b.get("id", ""))
	var bname: String = str(b.get("name", bid))
	var seen_n: int = int(b.get("seen", 0))
	var known_n: int = int(b.get("known", 0))
	var total_n: int = int(b.get("total", seen_n + known_n))
	var active: bool = bid == _selected_book

	var btn := Button.new()
	btn.name = "Book_" + bid
	btn.theme_type_variation = &"CommitButton" if active else &"TextButton"
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	var count_str: String = "%d" % total_n if bid == "lives" else ("%d/%d" % [known_n, total_n])
	if is_compact:
		btn.text = "%s (%s)" % [bname.split(" (")[0], count_str]
	else:
		btn.text = ("%s%s  [%s]" % [("▸ " if active else ""), bname, count_str])
	btn.accessibility_name = "%s, %s" % [bname, _book_count_summary(bid, seen_n, known_n, total_n)]
	TooltipLayer.set_tip(btn, {
		"title": bname,
		"fact": _book_count_summary(bid, seen_n, known_n, total_n),
		"summary": str(b.get("effect", "")),
	})
	btn.pressed.connect(func(): select_book(bid))
	return btn


func _build_book_header(parent: Control, book_data: Dictionary) -> void:
	var bid: String = str(book_data.get("id", _selected_book))
	var bname: String = str(book_data.get("name", bid))
	var box: VBoxContainer = section_in(parent, "book_header", bname)
	box.get_parent().name = "BookHeader"

	var effect_txt: String = str(book_data.get("effect", ""))
	if effect_txt != "":
		var ef := Label.new()
		ef.name = "BookEffect"
		ef.text = tr("Effect: %s") % effect_txt
		ef.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		ef.add_theme_color_override("font_color", Illustrated.INK)
		box.add_child(ef)

	var seen_n: int = int(book_data.get("seen", 0))
	var known_n: int = int(book_data.get("known", 0))
	var total_n: int = int(book_data.get("total", seen_n + known_n))
	var counts := Label.new()
	counts.name = "BookCounts"
	counts.theme_type_variation = &"RowLabel"
	counts.text = _book_count_summary(bid, seen_n, known_n, total_n)
	box.add_child(counts)


func _build_knowledge_entries(parent: Control, book_data: Dictionary) -> void:
	var bid: String = str(book_data.get("id", _selected_book))
	var entries: Array = Array(book_data.get("entries", []))
	var box: VBoxContainer = section_in(parent, "entries", tr("Entries (%d)") % entries.size())
	box.get_parent().name = "Entries"
	if entries.is_empty():
		var empty_l := line(tr("No entries recorded in this book yet."), box)
		empty_l.name = "EmptyNotice"
		return

	var seen_alpha: float = float(Dictionary(cfg.get("codex", {})).get("seen_alpha", SEEN_INK_ALPHA))
	var known_alpha: float = float(Dictionary(cfg.get("codex", {})).get("known_alpha", KNOWN_INK_ALPHA))
	for raw in entries:
		if not (raw is Dictionary):
			continue
		var e: Dictionary = raw
		var eid: String = str(e.get("id", ""))
		var lv: String = str(e.get("level", CodexStore.LEVEL_SEEN))
		var is_known: bool = lv == CodexStore.LEVEL_KNOWN
		var title: String = str(e.get("title", eid))
		var desc: String = str(e.get("desc", ""))
		var effect_txt: String = str(e.get("effect", book_data.get("effect", "")))

		var card := PanelContainer.new()
		card.name = "Entry_" + eid
		card.focus_mode = Control.FOCUS_ALL
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.set_meta(&"entry_id", eid)
		card.set_meta(&"entry_level", lv)
		# Visual ink-wash distinction: faint ink for seen, full ink for known (GDD Visual/Audio, AC-CK-19).
		card.add_theme_stylebox_override("panel", Illustrated.box(
			Illustrated.PAPER if is_known else Illustrated.PAPER_TILE,
			Illustrated.BRASS if is_known else Illustrated.BRASS_DIM,
			2 if is_known else 1,
			8.0,
			2
		))
		card.modulate = Color(1.0, 1.0, 1.0, known_alpha if is_known else seen_alpha)

		var col := VBoxContainer.new()
		col.add_theme_constant_override("separation", 4)
		card.add_child(col)

		var top := HBoxContainer.new()
		top.add_theme_constant_override("separation", 8)
		col.add_child(top)

		var title_l := Label.new()
		title_l.name = "EntryTitle"
		title_l.text = title
		title_l.theme_type_variation = &"HeadingLabel"
		title_l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		title_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		top.add_child(title_l)

		var badge := Label.new()
		badge.name = "LevelBadge"
		badge.text = tr("Known · Đã Thông") if is_known else tr("Seen · Đã Thấy")
		badge.theme_type_variation = &"RowLabel"
		badge.add_theme_color_override("font_color", Illustrated.CINNABAR if is_known else Color("#5E4F3D"))
		top.add_child(badge)

		if desc != "":
			var dl := Label.new()
			dl.text = desc
			dl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			col.add_child(dl)

		var search_extra: String = ""
		if bid == Codex.BOOK_VARIANTS:
			var vline := Label.new()
			vline.name = "VariantFormation_" + eid
			vline.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			if bool(e.get("formation_known", false)):
				var reqs: PackedStringArray = PackedStringArray()
				for rq in Array(e.get("requires", [])):
					reqs.append(str(rq))
				var req_text: String = ", ".join(reqs) if not reqs.is_empty() else tr("special")
				var orig_text: String = str(e.get("origin", ""))
				vline.text = tr("Formation conditions: %s (requires: %s)") % [orig_text if orig_text != "" else tr("awakened"), req_text]
				search_extra += " " + vline.text
			else:
				vline.text = tr("Formation conditions: unknown (own this variant root to record).")
			col.add_child(vline)
		elif bid == Codex.BOOK_SECRETS:
			search_extra += _append_secret_candidates(col, eid, is_known, e)
		elif bid == Codex.BOOK_CAST:
			search_extra += _append_cast_fates(col, eid, Array(e.get("fates", [])))

		if effect_txt != "":
			var eff_l := Label.new()
			eff_l.name = "EntryEffect"
			eff_l.text = tr("Effect: %s") % effect_txt
			eff_l.theme_type_variation = &"RowLabel"
			eff_l.add_theme_color_override("font_color", Color(Illustrated.INK, 0.85))
			eff_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			col.add_child(eff_l)

		var first_year: int = int(e.get("first_year", 0))
		var first_life: String = str(e.get("first_life", ""))
		if first_year > 0 or first_life != "":
			var meta_l := Label.new()
			meta_l.theme_type_variation = &"RowLabel"
			meta_l.add_theme_color_override("font_color", Color(Illustrated.INK, 0.65))
			meta_l.text = tr("First recorded: Year %d%s") % [first_year, (" · " + first_life) if first_life != "" else ""]
			col.add_child(meta_l)

		card.accessibility_name = "%s, %s. %s" % [title, badge.text, desc]
		TooltipLayer.set_tip(card, {
			"title": title,
			"fact": badge.text,
			"summary": effect_txt if effect_txt != "" else desc,
		})
		box.add_child(card)
		_entry_rows.append([card, WorldDB.fold(title + " " + desc + " " + lv + " " + search_extra)])


func _append_secret_candidates(col: VBoxContainer, eid: String, is_known: bool, e: Dictionary) -> String:
	var cbox := VBoxContainer.new()
	cbox.name = "Candidates_" + eid
	cbox.add_theme_constant_override("separation", 2)
	col.add_child(cbox)
	if not is_known:
		var rum := Label.new()
		rum.text = tr("Heard in rumour — enter this hidden place to record its candidate regions and sites.")
		rum.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		cbox.add_child(rum)
		return rum.text

	# AC-CK-14: display ONLY authored candidate regions and candidate sites as rumours, never the rolled site.
	var reg_names: PackedStringArray = PackedStringArray()
	for r in Array(e.get("candidate_regions", [])):
		if r is Dictionary:
			var rn: String = str(r.get("region_name", ""))
			reg_names.append(rn if rn != "" else ("Region %d" % int(r.get("region_id", 0))))
	var site_parts: PackedStringArray = PackedStringArray()
	for c in Array(e.get("candidates", [])):
		if c is Dictionary:
			var rn: String = str(c.get("region_name", ""))
			var tile: Array = Array(c.get("tile", []))
			var coord: String = "(%d, %d)" % [int(tile[0]), int(tile[1])] if tile.size() >= 2 else ""
			site_parts.append("%s %s" % [rn if rn != "" else ("Region %d" % int(c.get("region_id", 0))), coord])

	var head_l := Label.new()
	head_l.name = "CandidateRegions_" + eid
	head_l.theme_type_variation = &"RowLabel"
	head_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	head_l.text = tr("Candidate regions (rumours — actual site varies each game): %s") % (
		", ".join(reg_names) if not reg_names.is_empty() else tr("none listed")
	)
	cbox.add_child(head_l)

	var sites_text: String = ""
	if not site_parts.is_empty():
		var sl := Label.new()
		sl.name = "CandidateSites_" + eid
		sl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		sl.text = tr("Candidate sites: %s") % " · ".join(site_parts)
		cbox.add_child(sl)
		sites_text = sl.text
	return head_l.text + " " + sites_text


func _append_cast_fates(col: VBoxContainer, eid: String, fates: Array) -> String:
	if fates.is_empty():
		return ""
	var fbox := VBoxContainer.new()
	fbox.name = "CastFates_" + eid
	fbox.add_theme_constant_override("separation", 2)
	col.add_child(fbox)
	var parts: PackedStringArray = PackedStringArray()
	for f in fates:
		if not (f is Dictionary):
			continue
		var txt: String = tr("Year %d (%s): %s") % [
			int(f.get("year", 0)),
			str(f.get("life", "")),
			str(f.get("fate", f.get("text", ""))),
		]
		var fl := Label.new()
		fl.text = "• " + txt
		fl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		fbox.add_child(fl)
		parts.append(txt)
	return " ".join(parts)


func _build_lives_entries(parent: Control, lives: Array) -> void:
	var box: VBoxContainer = section_in(parent, "lives", tr("Lives Lived (%d)") % lives.size())
	box.get_parent().name = "Entries"
	if lives.is_empty():
		var empty_l := line(tr("No past lives recorded yet."), box)
		empty_l.name = "EmptyNotice"
		return

	for i in lives.size():
		var raw: Variant = lives[i]
		if not (raw is Dictionary):
			continue
		var l: Dictionary = raw
		var card := PanelContainer.new()
		card.name = "Life_%d" % i
		card.focus_mode = Control.FOCUS_ALL
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.set_meta(&"entry_level", CodexStore.LEVEL_KNOWN)
		card.add_theme_stylebox_override("panel", Illustrated.box(Illustrated.PAPER, Illustrated.BRASS, 2, 10.0, 2))
		card.modulate = Color(1.0, 1.0, 1.0, KNOWN_INK_ALPHA)

		var col := VBoxContainer.new()
		col.add_theme_constant_override("separation", 4)
		card.add_child(col)

		var name_str: String = str(l.get("name", tr("Unnamed")))
		var mode_id: String = str(l.get("mode", "one_life"))
		var mode_label: String = tr("Continue (Luân Hồi)") if mode_id == "continue" else tr("One Life (Nhất Sinh)")
		var realm_str: String = str(l.get("realm_label", ""))
		var age_n: int = int(roundf(float(l.get("age", 0.0))))
		var year_n: int = int(l.get("year", 0))
		var cause_str: String = str(l.get("cause", ""))
		var epitaph_str: String = str(l.get("epitaph", "")).strip_edges()
		var chron_str: String = str(l.get("chronicle_summary", "")).strip_edges()

		var top := HBoxContainer.new()
		top.add_theme_constant_override("separation", 8)
		col.add_child(top)

		var tl := Label.new()
		tl.text = "#%d  %s" % [i + 1, name_str]
		tl.theme_type_variation = &"HeadingLabel"
		tl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		top.add_child(tl)

		var mb := Label.new()
		mb.name = "LifeModeBadge_%d" % i
		mb.text = mode_label
		mb.theme_type_variation = &"RowLabel"
		mb.add_theme_color_override("font_color", Illustrated.CINNABAR if mode_id == "one_life" else Illustrated.GILT)
		top.add_child(mb)

		var facts := Label.new()
		facts.name = "LifeFacts_%d" % i
		facts.text = tr("%s · Age %d · Year %d · Cause: %s") % [realm_str, age_n, year_n, cause_str]
		facts.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		col.add_child(facts)

		if epitaph_str != "":
			var ep := Label.new()
			ep.name = "LifeEpitaph_%d" % i
			ep.text = "“%s”" % epitaph_str
			ep.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			ep.add_theme_color_override("font_color", Color(Illustrated.INK, 0.9))
			col.add_child(ep)

		if chron_str != "":
			var ch := Label.new()
			ch.name = "LifeChronicle_%d" % i
			ch.text = chron_str
			ch.theme_type_variation = &"RowLabel"
			ch.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			col.add_child(ch)

		card.accessibility_name = "%s, %s, %s, age %d, %s" % [name_str, mode_label, realm_str, age_n, cause_str]
		TooltipLayer.set_tip(card, {
			"title": name_str,
			"fact": "%s · %s" % [mode_label, realm_str],
			"summary": epitaph_str if epitaph_str != "" else cause_str,
		})
		box.add_child(card)
		_entry_rows.append([card, WorldDB.fold(name_str + " " + mode_label + " " + realm_str + " " + cause_str + " " + epitaph_str + " " + chron_str)])


func _resolve_book(v: Dictionary) -> String:
	var books: Array = Array(v.get("books", []))
	if _selected_book != "" and _has_book(v, _selected_book):
		return _selected_book
	if not books.is_empty() and books[0] is Dictionary:
		return str(books[0].get("id", FALLBACK_BOOK_ORDER[0]))
	return FALLBACK_BOOK_ORDER[0]


func _has_book(v: Dictionary, bid: String) -> bool:
	for b in Array(v.get("books", [])):
		if b is Dictionary and str(b.get("id", "")) == bid:
			return true
	var by_book: Dictionary = Dictionary(v.get("by_book", {}))
	return by_book.has(bid)


func _book_payload(v: Dictionary, bid: String) -> Dictionary:
	var by_book: Dictionary = Dictionary(v.get("by_book", {}))
	if by_book.has(bid) and by_book[bid] is Dictionary:
		return Dictionary(by_book[bid])
	for b in Array(v.get("books", [])):
		if b is Dictionary and str(b.get("id", "")) == bid:
			return b
	return {"id": bid, "name": bid, "effect": "", "seen": 0, "known": 0, "total": 0, "entries": []}


func _book_count_summary(bid: String, seen_n: int, known_n: int, total_n: int) -> String:
	if bid == "lives":
		return tr("%d lives recorded") % total_n
	return tr("Known: %d · Seen: %d · Total: %d") % [known_n, seen_n, total_n]


func _on_search(text: String) -> void:
	var q: String = WorldDB.fold(text.strip_edges())
	var hit: int = 0
	var seen_alpha: float = float(Dictionary(cfg.get("codex", {})).get("seen_alpha", SEEN_INK_ALPHA))
	var known_alpha: float = float(Dictionary(cfg.get("codex", {})).get("known_alpha", KNOWN_INK_ALPHA))
	for r in _entry_rows:
		var ctrl: Control = r[0] as Control
		var m: bool = q == "" or str(r[1]).contains(q)
		var base_a: float = known_alpha if str(ctrl.get_meta(&"entry_level", CodexStore.LEVEL_KNOWN)) == CodexStore.LEVEL_KNOWN else seen_alpha
		ctrl.modulate.a = base_a if m else (base_a * 0.35)
		hit += 1 if m else 0
	_count.text = "" if q == "" else tr("%d matches") % hit
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
