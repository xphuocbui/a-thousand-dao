class_name WikiWindow
extends GameWindow
## The in-game wiki (design/ux/wiki.md) in the window host: an index of categories with search, and entries whose
## highlighted words and related names are links to other entries (one history step each). Built from
## [method WikiData.view]; read-only. Illustrated (user 2026-11-24): the index is a parchment inset per category with
## a flow of entries, each its link beside its trait medallion or item icon where it has one (the PlaceholderArt
## stripes when that art is missing); an entry opens with its icon framed large.

var _search := LineEdit.new()
var _count := Label.new()
var _entry_rows: Array = []   # [Control, folded text] on the index


func kind() -> String:
	return "wiki"


func window_title(v: Dictionary) -> String:
	if bool(v.get("index", false)) or bool(v.get("unknown", false)):
		return tr("Wiki")
	return tr("Wiki") + ": " + str(v.get("title", "")) + ((" (" + str(v.name_vi) + ")") if str(v.get("name_vi", "")) != "" else "")


func first_focus() -> Control:
	return _search if bool(view.get("index", false)) else super.first_focus()


func show_view(v: Dictionary, section: String, is_locked: bool) -> void:
	for c in [_search, _count]:
		if c.get_parent() != null:
			c.get_parent().remove_child(c)
	super.show_view(v, section, is_locked)


func _build() -> void:
	var v: Dictionary = view
	_entry_rows.clear()
	if bool(v.get("index", false)):
		_build_index(v)
	elif bool(v.get("unknown", false)):
		line(tr("No entry for this word yet."))
		_link(tr("← Index"), "")
	else:
		_build_entry(v)


func _build_index(v: Dictionary) -> void:
	_search.placeholder_text = tr("Search the wiki…  (Ctrl+F)")
	_search.accessibility_name = tr("Search the wiki")
	if not _search.text_changed.is_connected(_on_search):
		_search.text_changed.connect(_on_search)
	header.add_child(_search)
	_count.accessibility_live = AccessibilityServer.LIVE_POLITE
	header.add_child(_count)
	var g: VBoxContainer = Illustrated.ground(body)
	for cat in Array(v.get("categories", [])):
		var entries: Array = Array(cat.get("entries", []))
		var box: VBoxContainer = section_in(g, str(cat.id), "%s (%d)" % [tr(str(cat.title)), entries.size()])
		var flow := HFlowContainer.new()
		flow.add_theme_constant_override("h_separation", 14)
		flow.add_theme_constant_override("v_separation", 6)
		box.add_child(flow)
		for e in entries:
			var cell := HBoxContainer.new()
			cell.add_theme_constant_override("separation", 6)
			flow.add_child(cell)
			if str(e.get("icon", "")) != "":
				var ic := TextureRect.new()
				ic.texture = PlaceholderArt.texture() if str(e.icon) == "placeholder" else Illustrated.tex(str(e.icon))
				ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				ic.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
				ic.custom_minimum_size = Vector2(32, 32)
				cell.add_child(ic)
			var b := _link(str(e.title) + ((" (" + str(e.name_vi) + ")") if str(e.get("name_vi", "")) != "" else ""), str(e.key), cell)
			b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			if str(e.get("summary", "")) != "":
				TooltipLayer.set_tip(b, {"title": str(e.title), "summary": str(e.summary)})
			_entry_rows.append([cell, WorldDB.fold(str(e.title) + " " + str(e.get("name_vi", "")) + " " + str(e.get("summary", "")))])
	_on_search(_search.text)


func _build_entry(v: Dictionary) -> void:
	if str(v.get("icon", "")) != "":   # the entry's own art, large (a trait medallion, an item icon)
		var pic := TextureRect.new()
		pic.name = "EntryArt"
		pic.texture = PlaceholderArt.texture() if str(v.icon) == "placeholder" else Illustrated.tex(str(v.icon))
		pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		pic.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		pic.custom_minimum_size = Vector2(112, 112)
		pic.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		header.add_child(pic)
	var kind_l := Label.new()
	kind_l.text = tr(str(v.get("category", "")))
	kind_l.theme_type_variation = &"RowLabel"
	header.add_child(kind_l)
	if str(v.get("summary", "")) != "":
		var s := Label.new()
		s.text = str(v.summary)
		s.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		header.add_child(s)
	var segs: Array = Array(v.get("body", []))
	if not segs.is_empty():
		var rt := RichTextLabel.new()
		rt.name = "Body"
		rt.bbcode_enabled = true
		rt.fit_content = true
		rt.scroll_active = false
		rt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var text: String = ""
		for seg in segs:
			if seg is Dictionary:
				text += "[url=%s][u]%s[/u][/url]" % [str(seg.key), str(seg.text)]
			else:
				text += str(seg).replace("[", "[lb]")
		rt.text = text
		rt.meta_clicked.connect(func(meta: Variant): open_requested.emit("wiki", str(meta), ""))
		rt.focus_mode = Control.FOCUS_ALL
		rt.accessibility_name = rt.get_parsed_text()
		body.add_child(rt)
		for seg in segs:   # the highlighted words again as focusable links, for keyboard and screen readers
			if seg is Dictionary:
				_link("→ " + str(seg.text), str(seg.key))
	for f in Array(v.get("facts", [])):
		line(tr(str(f)))
	for l in Array(v.get("links", [])):
		_link(str(l.title), str(l.key))
	_link(tr("← Index"), "")


func _link(text: String, key: String, parent: Control = null) -> LinkButton:
	var b := LinkButton.new()
	b.text = text
	LinkStyle.apply(b, "term", "", "paper")
	b.accessibility_name = text + ", " + tr("opens in the wiki")
	b.pressed.connect(func(): open_requested.emit("wiki", key, ""))
	(parent if parent != null else body).add_child(b)
	return b


func _on_search(text: String) -> void:
	var q: String = WorldDB.fold(text.strip_edges())
	var hit: int = 0
	for r in _entry_rows:
		var m: bool = q == "" or str(r[1]).contains(q)
		(r[0] as Control).modulate.a = 1.0 if m else 0.4   # Searchable list: matches stay, the rest are dimmed in place
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
