class_name InventoryWindow
extends GameWindow
## The inventory (design/ux/inventory.md) in the window host: a sticky header (linh thạch, gear slots, search, kind
## chips), one section per kind in a fixed order, item rows with the rarity word and colour, the item tooltip with the
## comparison first, and each item's verbs (equip with a slot chooser and a Replace confirm, unequip, nurture, eat or
## use with a confirm, read a manual, the element chooser a treasure may ask for). Built from [method GameQuery.inventory];
## the verbs are requested through [signal GameWindow.action_requested].

## ui_windows.json (rarity_words, inventory.kind_order).
var cfg: Dictionary = {}

var _search := LineEdit.new()
var _count := Label.new()
var _chips_off: Dictionary = {}    # kind -> true while its chip is off (persists across opens)
var _expanded: String = ""         # the item id whose verbs show
var _chooser: String = ""          # "slot" or "element" while a chooser shows under the expanded row
var _armed: Dictionary = {}        # {verb, args, text}: the confirm row shown
var _elements: Array = []          # the element options a treasure asked for, with preview lines
var _rows: Dictionary = {}         # item id -> its row Button


func kind() -> String:
	return "inventory"


func window_title(_v: Dictionary) -> String:
	return tr("Inventory")


## The expanded item id ("" when none), for tests.
func expanded() -> String:
	return _expanded


## The row button of [param item_id] (null when not shown), for tests.
func row_of(item_id: String) -> Button:
	return _rows.get(item_id)


## A treasure asked for an element ([param options] from the session's use_item answer, [param lines] its preview):
## opens the element chooser under that item's row.
func ask_element(item_id: String, options: Array, lines: Array) -> void:
	_expanded = item_id
	_chooser = "element"
	_elements = []
	var off: int = 1 if lines.size() == options.size() + 1 else 0   # the session's preview: a header, then one line each
	for i in options.size():
		_elements.append({"id": str(options[i]), "line": str(lines[i + off]) if i + off < lines.size() else str(options[i])})
	_rebuild()


## Esc inside the window (inventory.md Interaction Map): the confirm, then the chooser, then the expanded row. Returns
## true when it did something (the window closes otherwise).
func cancel_inline() -> bool:
	if not _armed.is_empty():
		_armed = {}
	elif _chooser != "":
		_chooser = ""
	elif _expanded != "":
		_expanded = ""
	else:
		return false
	_rebuild()
	return true


func show_view(v: Dictionary, section: String, is_locked: bool) -> void:
	_armed = {}
	_chooser = "" if _chooser != "element" else _chooser
	_detach_keepers()
	super.show_view(v, section, is_locked)


## The search field and its count live across rebuilds (the typed text and focus stay): taken out of the header
## before the base class frees the header's children.
func _detach_keepers() -> void:
	for c in [_search, _count]:
		if c.get_parent() != null:
			c.get_parent().remove_child(c)


func _open_slots() -> void:
	_chooser = "slot"
	_rebuild()


func _confirm(verb: String, args: Array) -> void:
	_armed = {}
	action_requested.emit(verb, args)


func _pick(verb: String, args: Array) -> void:
	_chooser = ""
	_elements = []
	action_requested.emit(verb, args)


func first_focus() -> Control:
	return _search


func _rebuild() -> void:
	var y: int = scroll.scroll_vertical
	var keep: String = _search.text
	_detach_keepers()
	super.show_view(view, "", locked)
	_search.text = keep
	scroll.set_deferred("scroll_vertical", y)


func _build() -> void:
	var v: Dictionary = view
	_rows.clear()
	var gear: Dictionary = v.get("gear", {})
	var top := Label.new()
	top.text = tr("Linh thạch %s") % HudReadouts.stones_text(float(v.get("stones", 0))) + "  ·  " + \
		tr("Gear %d of %d base, %d of %d extra") % [int(gear.get("base_used", 0)), int(gear.get("base_total", 0)), int(gear.get("extra_used", 0)), int(gear.get("extra_limit", 0))] + \
		(("  ·  ⚠ " + tr("%d unslotted") % int(gear.unslotted)) if int(gear.get("unslotted", 0)) > 0 else "")
	top.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	TooltipLayer.set_tip(top, {"title": tr("Gear slots"), "summary": tr("Base slots: 1 weapon, 1 armour, 2 rings, 1 necklace. Extra slots grow by realm and with artifact slots. Equipping costs no thần thức. A piece past the extra count stays equipped but adds nothing (unslotted).")})
	header.add_child(top)
	# search + count (Searchable list): highlight in place
	_search.placeholder_text = tr("Search items…  (Ctrl+F)")
	_search.accessibility_name = tr("Search items")
	if not _search.text_changed.is_connected(_on_search):
		_search.text_changed.connect(_on_search)
	header.add_child(_search)
	_count.accessibility_live = AccessibilityServer.LIVE_POLITE
	header.add_child(_count)
	var items: Array = Array(v.get("items", []))
	var chips := HFlowContainer.new()
	header.add_child(chips)
	var present: Dictionary = {}
	for it in items:
		present[str(it.kind)] = true
	if present.size() > 1:
		var all := Button.new()
		all.name = "Chip_all"
		all.text = tr("All")
		all.accessibility_name = tr("Show all kinds")
		all.pressed.connect(_show_all)
		chips.add_child(all)
	for pair in _kind_order():
		if not present.has(str(pair[0])):
			continue
		var chip := Button.new()
		chip.toggle_mode = true
		chip.text = tr(str(pair[1]))
		var k: String = str(pair[0])
		chip.button_pressed = not _chips_off.has(k)
		chip.modulate.a = 1.0 if chip.button_pressed else 0.6
		chip.accessibility_name = "%s, %s" % [chip.text, tr("shown") if chip.button_pressed else tr("hidden")]
		chip.toggled.connect(_on_chip.bind(k))
		chips.add_child(chip)
	_g = Illustrated.ground(body)
	_into = _g
	if items.is_empty():
		line(tr("You carry nothing yet."), _g)
	for pair in _kind_order():
		var k: String = str(pair[0])
		if _chips_off.has(k):
			continue
		var of_kind: Array = items.filter(func(x): return str(x.kind) == k)
		if of_kind.is_empty():
			continue
		of_kind.sort_custom(func(a, b):
			if bool(a.equipped) != bool(b.equipped):
				return bool(a.equipped)
			if int(a.rarity) != int(b.rarity):
				return int(a.rarity) > int(b.rarity)
			return str(a.name) < str(b.name))
		_into = section_in(_g, k, "%s (%d)" % [tr(str(pair[1])), of_kind.size()])
		for it in of_kind:
			_item_row(it)
	bar_open(tr("Character"), "character")
	_on_search(_search.text)


var _g: VBoxContainer = null   # the wood ground of this build
var _into: Control = null      # the kind's inset the rows go into


func _kind_order() -> Array:
	return Array(cfg.get("inventory", {}).get("kind_order", [["artifact", "Pháp bảo"], ["cong_phap", "Công pháp"], ["pill", "Đan dược"],
		["treasure", "Bảo vật"], ["talisman", "Phù lục"], ["herb", "Linh thảo"], ["material", "Tài liệu"]]))


## The rarity word of rank [param r] (item-database.md Formulas A; ui_windows.json rarity_words).
func rarity_word(r: int) -> String:
	return str(cfg.get("rarity_words", {}).get(str(r), "r%d" % r))


func _item_row(it: Dictionary) -> void:
	var b := Button.new()
	b.name = "Item_" + str(it.id)
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.flat = true
	var marks: Array = []
	if str(it.get("slot", "")) == "unslotted":
		marks.append("⚠ " + tr("unslotted (adds nothing)"))
	elif bool(it.get("equipped", false)):
		marks.append("[%s]" % tr(str(it.slot)))
	b.text = "%s  ·  %s  ·  %s%s" % [str(it.name), rarity_word(int(it.rarity)), str(it.get("fact", "")), ("  " + "  ".join(marks)) if not marks.is_empty() else ""]
	b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	LinkStyle.apply(b, "item", str(int(it.rarity)), "paper")
	b.accessibility_name = "%s, %s, %s, %s%s" % [str(it.name), tr(_kind_title(str(it.kind))), rarity_word(int(it.rarity)), str(it.get("fact", "")),
		(", " + ", ".join(marks)) if not marks.is_empty() else ""]
	TooltipLayer.set_tip(b, _item_tip(it))
	var iid: String = str(it.id)
	b.pressed.connect(_toggle_row.bind(iid))
	b.set_meta(&"search", WorldDB.fold(str(it.name) + " " + _kind_title(str(it.kind)) + " " + rarity_word(int(it.rarity))))
	b.set_meta(&"text", str(it.get("text", "")))
	b.gui_input.connect(_row_input.bind(b))
	# the painted icon in a frame of the item's rarity colour (the illustrated windows, user 2026-11-24)
	var row := HBoxContainer.new()
	row.name = "ItemRow_" + str(it.id)
	row.add_theme_constant_override("separation", 8)
	var frame := PanelContainer.new()
	var rst: Dictionary = LinkStyle.style_of("item", str(int(it.rarity)), "paper")
	var rc: Color = rst.colour if rst.colour is Color else Illustrated.BRASS
	frame.add_theme_stylebox_override("panel", Illustrated.box(Color("#1B120C"), rc, 2, 2.0, 3))
	frame.custom_minimum_size = Vector2(56, 56)
	frame.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var ic := TextureRect.new()
	ic.texture = Illustrated.tex(str(it.get("icon", "")))
	ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	ic.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	frame.add_child(ic)
	if int(it.get("qty", 1)) > 1:
		var q := Label.new()
		q.text = "×%d" % int(it.qty)
		q.add_theme_color_override("font_color", Illustrated.BONE)
		q.add_theme_color_override("font_outline_color", Color.BLACK)
		q.add_theme_constant_override("outline_size", 4)
		q.add_theme_font_size_override("font_size", 13)
		q.size_flags_horizontal = Control.SIZE_SHRINK_END
		q.size_flags_vertical = Control.SIZE_SHRINK_END
		frame.add_child(q)
	row.add_child(frame)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(b)
	_into.add_child(row)
	_rows[iid] = b
	if _expanded == iid:
		_verbs(it)


func _kind_title(k: String) -> String:
	for pair in _kind_order():
		if str(pair[0]) == k:
			return str(pair[1])
	return k


## The item tooltip (Item tooltip pattern): name and rarity word, the comparison first, the kind's facts, the text.
func _item_tip(it: Dictionary) -> Dictionary:
	var lines: Array = []
	for c in Array(it.get("compare", [])):
		var d: float = float(c.mine) - float(c.equipped)
		lines.append("%s %s %s  (%s %s)" % [str(c.label), num(float(c.mine)), ("▲ +" + num(d)) if d > 0.0 else (("▼ " + num(d)) if d < 0.0 else "="), tr("vs"), str(c.against)])
	return {"id": str(it.id), "title": "%s  (%s)" % [str(it.name), rarity_word(int(it.rarity))], "fact": str(it.get("fact", "")),
		"summary": str(it.get("text", "")), "lines": lines}


func _row_input(event: InputEvent, b: Button) -> void:
	if event is InputEventKey and event.is_pressed() and (event as InputEventKey).ctrl_pressed and (event as InputEventKey).physical_keycode == KEY_C:
		DisplayServer.clipboard_set(str(b.get_meta(&"text", b.text)))
		show_reply([tr("Copied the item text.")])
		b.accept_event()


func _toggle_row(item_id: String) -> void:
	_expanded = "" if _expanded == item_id else item_id
	_chooser = ""
	_armed = {}
	_rebuild()
	if _rows.has(item_id):
		focus_later(_rows[item_id])


func _verbs(it: Dictionary) -> void:
	var box := VBoxContainer.new()
	box.name = "Verbs"
	_into.add_child(box)
	var row := HBoxContainer.new()
	box.add_child(row)
	var verbs: Array = Array(it.get("verbs", []))
	if verbs.is_empty():
		var note := Label.new()
		note.text = "    " + (tr("Used automatically when it applies.") if str(it.kind) == "talisman" else tr("Crafting uses this (the crafting screens)."))
		note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		box.add_child(note)
	var iid: String = str(it.id)
	for vb in verbs:
		var reason: String = str(vb.get("reason", ""))
		var b: Button
		match str(vb.id):
			"equip":
				b = _verb_button(tr(str(vb.label)), row, reason)
				b.name = "Verb_equip"
				b.pressed.connect(_open_slots)
			"use_item":
				b = _verb_button(tr(str(vb.label)), row, reason)
				b.name = "Verb_use_item"
				var ask: String = (tr("Eat 1 %s?") if str(it.kind) == "pill" else tr("Use %s?")) % str(it.name)
				b.pressed.connect(_arm.bind("use_item", [iid, ""], ask))
			_:
				b = _verb_button(tr(str(vb.label)), row, reason)
				b.name = "Verb_" + str(vb.id)
				b.pressed.connect(func(): action_requested.emit(str(vb.id), [iid]))
	if _chooser == "slot":
		_slot_chooser(it, box)
	elif _chooser == "element":
		_element_chooser(it, box)
	if not _armed.is_empty():
		var ask := Label.new()
		ask.text = "    " + str(_armed.text)
		ask.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		box.add_child(ask)
		var cr := HBoxContainer.new()
		box.add_child(cr)
		var ok := Button.new()
		ok.name = "Confirm"
		ok.text = tr("Confirm")
		ok.theme_type_variation = &"CommitButton"
		var verb: String = str(_armed.verb)
		var args: Array = Array(_armed.args)
		ok.pressed.connect(_confirm.bind(verb, args))
		cr.add_child(ok)
		var cancel := Button.new()
		cancel.name = "Cancel"
		cancel.text = tr("Cancel")
		cancel.pressed.connect(cancel_inline)
		cr.add_child(cancel)
		focus_later(cancel)


func _verb_button(text: String, parent: Control, reason: String) -> Button:
	var b := Button.new()
	var why: String = reason
	if why == "" and locked:
		why = tr("locked while an event waits")
	b.text = ("🔒 " if locked else "") + text + ((" — " + why) if why != "" and not locked else "")
	b.disabled = why != ""
	b.accessibility_name = text + ((": " + why) if why != "" else "")
	if why != "":
		TooltipLayer.set_tip(b, {"title": text, "summary": why})
	parent.add_child(b)
	return b


func _arm(verb: String, args: Array, text: String) -> void:
	_armed = {"verb": verb, "args": args, "text": text}
	_rebuild()


func _slot_chooser(it: Dictionary, box: Control) -> void:
	var ch := VBoxContainer.new()
	ch.name = "SlotChooser"
	box.add_child(ch)
	var iid: String = str(it.id)
	var disp: Dictionary = it.get("displaces", {})
	var first: Button = null
	for slot in Array(it.get("fits", [])):
		var b := Button.new()
		b.name = "Slot_" + str(slot)
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		var held: String = str(disp.get(slot, ""))
		b.text = "    %s — %s" % [tr(str(slot)), (tr("replaces %s") % held) if held != "" else tr("free")]
		var sl: String = str(slot)
		if held != "":
			b.pressed.connect(_arm.bind("equip", [iid, sl], tr("Replace %s with %s?") % [held, str(it.name)]))
		else:
			b.pressed.connect(_pick.bind("equip", [iid, sl]))
		ch.add_child(b)
		if first == null:
			first = b
	var cancel := Button.new()
	cancel.text = "    " + tr("Cancel (Esc)")
	cancel.pressed.connect(cancel_inline)
	ch.add_child(cancel)
	if _armed.is_empty():
		focus_later(first if first != null else cancel)


func _element_chooser(it: Dictionary, box: Control) -> void:
	var ch := VBoxContainer.new()
	ch.name = "ElementChooser"
	box.add_child(ch)
	var iid: String = str(it.id)
	for e in _elements:
		var b := Button.new()
		b.name = "Element_" + str(e.id)
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.text = "    " + str(e.line)
		b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		var eid: String = str(e.id)
		b.pressed.connect(_pick.bind("use_item", [iid, eid]))
		ch.add_child(b)
	var cancel := Button.new()
	cancel.text = "    " + tr("Cancel (Esc)")
	cancel.pressed.connect(cancel_inline)
	ch.add_child(cancel)


func _on_chip(on: bool, k: String) -> void:
	if on:
		_chips_off.erase(k)
	else:
		_chips_off[k] = true
	_rebuild()


## Search (Searchable list): matches stay full, the rest are dimmed; diacritics fold ("thanh phong" finds "Thanh Phong").
func _on_search(text: String) -> void:
	var q: String = WorldDB.fold(text.strip_edges())
	var shown: int = 0
	var hit: int = 0
	for iid in _rows:
		var b: Button = _rows[iid]
		shown += 1
		var m: bool = q == "" or str(b.get_meta(&"search", "")).contains(q)
		if m:
			hit += 1
		b.modulate.a = 1.0 if m else 0.45
	_count.text = "" if q == "" else tr("%d of %d match") % [hit, shown]
	_count.visible = _count.text != ""


func _unhandled_input(event: InputEvent) -> void:
	if is_visible_in_tree() and event is InputEventKey and event.is_pressed() and (event as InputEventKey).ctrl_pressed \
			and (event as InputEventKey).physical_keycode == KEY_F:
		_search.grab_focus()
		get_viewport().set_input_as_handled()
		return
	super._unhandled_input(event)


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		for c in [_search, _count]:
			if is_instance_valid(c) and c.get_parent() == null:
				c.free()   # detached keepers are not freed with the tree


func _show_all() -> void:
	_chips_off.clear()
	_rebuild()
