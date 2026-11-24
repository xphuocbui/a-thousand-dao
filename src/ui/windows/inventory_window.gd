class_name InventoryWindow
extends GameWindow
## The inventory (design/ux/inventory.md) in the window host: a sticky header (linh thạch, gear slots, search, kind
## chips), one section per kind in a fixed order, item rows with the rarity word and colour, the item tooltip with the
## comparison first, and each item's verbs (equip with a slot chooser and a Replace confirm, unequip, nurture, eat or
## use with a confirm, read a manual, the element chooser a treasure may ask for). Built from [method GameQuery.inventory];
## the verbs are requested through [signal GameWindow.action_requested].
## Laid out as an inventory (weak-point review 2026-11-24: "a list, not an inventory"): on the left each kind is a
## parchment inset holding a grid of item tiles (painted icon in a frame of its rarity colour, the name under it, the
## count, a gold edge when equipped); on the right the Equipped panel lists each gear slot and what sits in it (empty
## slots as recessed sockets), and the Selected panel shows the chosen item large with its facts, the comparison and
## its verbs.

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
		var was: String = _expanded
		_expanded = ""
		_rebuild()
		if _rows.has(was):
			focus_later(_rows[was])   # back to the tile it came from
		return true
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
	var left: VBoxContainer = _g
	# the Equipped and Selected panels pinned beside the grid (they stay in view while the bag scrolls); compact:
	# Selected heads the body and Equipped follows the bag
	var right: VBoxContainer = null
	if compact:
		right = VBoxContainer.new()
		right.add_theme_constant_override("separation", 10)
	else:
		use_side(380)
		right = Illustrated.ground(side)
	_into = left
	if items.is_empty():
		line(tr("You carry nothing yet."), left)
	# Selected first (its verbs stay in view), Equipped under it
	_detail_box = Illustrated.inset(right if not compact else left, tr("Selected"))
	_detail_box.name = "Selected"
	var picked: Dictionary = {}
	for it in items:
		if str(it.id) == _expanded:
			picked = it
	if picked.is_empty():
		line(tr("Select an item to see it and what you can do with it."), _detail_box)
	else:
		_build_detail(picked)
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
		var sec: VBoxContainer = section_in(left, k, "%s (%d)" % [tr(str(pair[1])), of_kind.size()])
		_into = HFlowContainer.new()
		_into.name = "Grid_" + k
		_into.add_theme_constant_override("h_separation", 8)
		_into.add_theme_constant_override("v_separation", 8)
		sec.add_child(_into)
		for it in of_kind:
			_item_row(it)
	_build_equipped(left if compact else right)
	bar_open(tr("Character"), "character")
	_on_search(_search.text)


var _g: VBoxContainer = null   # the wood ground of this build
var _into: Control = null      # the kind's tile grid the tiles go into (the Selected panel while its verbs build)
var _detail_box: VBoxContainer = null   # the Selected panel


# The Equipped panel: each gear slot (EquipSlots base slots, then extra) with its pieces, empty places as sockets.
func _build_equipped(parent: Control) -> void:
	var box: VBoxContainer = Illustrated.inset(parent, tr("Equipped"))
	box.get_parent().name = "Equipped"
	for sl in Array(view.get("slots", [])):
		var r := HBoxContainer.new()
		r.add_theme_constant_override("separation", 6)
		var l := Label.new()
		l.text = tr(str(sl.slot)).capitalize()
		l.theme_type_variation = &"RowLabel"
		l.custom_minimum_size = Vector2(86, 0)
		l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		r.add_child(l)
		var held: Array = Array(sl.get("items", []))
		for i in maxi(int(sl.get("size", 0)), held.size()):
			if i < held.size():
				var h: Dictionary = held[i]
				var b := Button.new()
				b.name = "Socket_%s_%d" % [str(sl.slot), i]
				b.custom_minimum_size = Vector2(48, 48)
				b.icon = _icon_tex(str(h.get("icon", "")))
				b.expand_icon = true
				b.add_theme_stylebox_override("normal", Illustrated.box(Color("#1B120C"), _rarity_colour(int(h.get("rarity", 1))), 2, 3.0, 3))
				b.accessibility_name = "%s: %s" % [l.text, str(h.name)]
				TooltipLayer.set_tip(b, {"title": str(h.name), "fact": l.text})
				var hid: String = str(h.id)
				b.pressed.connect(_toggle_row.bind(hid))
				r.add_child(b)
			else:
				var empty := PanelContainer.new()   # a recessed empty socket
				empty.custom_minimum_size = Vector2(48, 48)
				empty.add_theme_stylebox_override("panel", Illustrated.box(Color("#BFAE84"), Illustrated.BRASS_DIM, 1, 0.0, 3))
				TooltipLayer.set_tip(empty, {"title": l.text, "summary": tr("Empty: equip a piece that fits it.")})
				r.add_child(empty)
		box.add_child(r)
	var gear: Dictionary = view.get("gear", {})
	if int(gear.get("unslotted", 0)) > 0:
		line("⚠ " + tr("%d equipped piece(s) unslotted: they add nothing until a slot is free.") % int(gear.unslotted), box)


# The Selected panel: the item large, its name in its rarity colour, kind and rarity in words, its facts and text, the
# comparison, then its verbs (built by _verbs into this panel).
func _build_detail(it: Dictionary) -> void:
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 10)
	_detail_box.add_child(top)
	var frame := PanelContainer.new()
	frame.add_theme_stylebox_override("panel", Illustrated.box(Color("#1B120C"), _rarity_colour(int(it.rarity)), 3, 3.0, 3))
	frame.custom_minimum_size = Vector2(96, 96)
	var ic := TextureRect.new()
	ic.texture = _icon_tex(str(it.get("icon", "")))
	ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	ic.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	frame.add_child(ic)
	top.add_child(frame)
	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(col)
	var n := Label.new()
	n.text = str(it.name)
	n.theme_type_variation = &"HeadingLabel"
	n.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	n.add_theme_color_override("font_color", _rarity_colour(int(it.rarity)).darkened(0.25))
	col.add_child(n)
	var k := Label.new()
	k.text = "%s · %s" % [tr(_kind_title(str(it.kind))), rarity_word(int(it.rarity))] + \
		((" · " + (tr("unslotted (adds nothing)") if str(it.get("slot", "")) == "unslotted" else tr("equipped: %s") % tr(str(it.slot)))) if bool(it.get("equipped", false)) else "")
	k.theme_type_variation = &"RowLabel"
	k.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(k)
	if str(it.get("fact", "")) != "":
		line(str(it.fact), col)
	if str(it.get("text", "")) != "":
		line(str(it.text), _detail_box)
	for c in Array(it.get("compare", [])):
		var d: float = float(c.mine) - float(c.equipped)
		line("%s %s %s  (%s %s)" % [str(c.label), num(float(c.mine)), ("▲ +" + num(d)) if d > 0.0 else (("▼ " + num(d)) if d < 0.0 else "="), tr("vs"), str(c.against)], _detail_box)
	_into = _detail_box
	_verbs(it)


func _rarity_colour(r: int) -> Color:
	var st: Dictionary = LinkStyle.style_of("item", str(r), "paper")
	return st.colour if st.colour is Color else Illustrated.BRASS


func _icon_tex(path: String) -> Texture2D:
	var t: Texture2D = Illustrated.tex(path)
	return t if t != null else PlaceholderArt.texture()


func _kind_order() -> Array:
	return Array(cfg.get("inventory", {}).get("kind_order", [["artifact", "Pháp bảo"], ["cong_phap", "Công pháp"], ["pill", "Đan dược"],
		["treasure", "Bảo vật"], ["talisman", "Phù lục"], ["herb", "Linh thảo"], ["material", "Tài liệu"]]))


## The rarity word of rank [param r] (item-database.md Formulas A; ui_windows.json rarity_words).
func rarity_word(r: int) -> String:
	return str(cfg.get("rarity_words", {}).get(str(r), "r%d" % r))


func _item_row(it: Dictionary) -> void:
	var marks: Array = []
	if str(it.get("slot", "")) == "unslotted":
		marks.append("⚠ " + tr("unslotted (adds nothing)"))
	elif bool(it.get("equipped", false)):
		marks.append("[%s]" % tr(str(it.slot)))
	var iid: String = str(it.id)
	# the tile: the painted icon over the name, framed in the item's rarity colour; gold and thicker when equipped,
	# brass when selected
	var b := Button.new()
	b.name = "Item_" + iid
	b.custom_minimum_size = Vector2(116, 132)   # room for a 64 px icon and two 16 px lines of name
	var rc: Color = _rarity_colour(int(it.rarity))
	var edge: Color = Color("#E3B860") if bool(it.get("equipped", false)) else rc
	var w: int = 3 if bool(it.get("equipped", false)) or _expanded == iid else 2
	for st in ["normal", "hover", "pressed", "focus"]:
		var sb: StyleBoxFlat = Illustrated.box(Color("#2A1C12") if st != "hover" else Color("#3A2718"), edge if _expanded != iid else Color("#F4D28A"), w, 6.0, 3)
		b.add_theme_stylebox_override(st, sb)
	# a fixed 64 px icon over the name (two lines at most), so a long name never shrinks the picture
	var col := VBoxContainer.new()
	col.set_anchors_preset(Control.PRESET_FULL_RECT)
	col.offset_left = 6
	col.offset_right = -6
	col.offset_top = 6
	col.add_theme_constant_override("separation", 2)
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(col)
	var pic := TextureRect.new()
	pic.texture = _icon_tex(str(it.get("icon", "")))
	pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED if not PlaceholderArt.is_placeholder(pic.texture) else TextureRect.STRETCH_TILE
	pic.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	pic.custom_minimum_size = Vector2(64, 64)
	pic.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	pic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(pic)
	var nm := Label.new()
	nm.text = str(it.name)
	nm.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	nm.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	nm.max_lines_visible = 2
	nm.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	nm.add_theme_color_override("font_color", Illustrated.BONE)
	nm.add_theme_font_size_override("font_size", 16)
	nm.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(nm)
	b.accessibility_name = "%s, %s, %s, %s%s" % [str(it.name), tr(_kind_title(str(it.kind))), rarity_word(int(it.rarity)), str(it.get("fact", "")),
		(", " + ", ".join(marks)) if not marks.is_empty() else ""]
	TooltipLayer.set_tip(b, _item_tip(it))
	b.pressed.connect(_toggle_row.bind(iid))
	b.set_meta(&"search", WorldDB.fold(str(it.name) + " " + _kind_title(str(it.kind)) + " " + rarity_word(int(it.rarity))))
	b.set_meta(&"text", str(it.get("text", "")))
	b.gui_input.connect(_row_input.bind(b))
	if int(it.get("qty", 1)) > 1 or not marks.is_empty():   # the count and the unslotted mark in the icon's corner
		var q := Label.new()
		q.text = ("×%d" % int(it.qty) if int(it.get("qty", 1)) > 1 else "") + (" ⚠" if str(it.get("slot", "")) == "unslotted" else "")
		q.add_theme_color_override("font_color", Illustrated.BONE)
		q.add_theme_color_override("font_outline_color", Color.BLACK)
		q.add_theme_constant_override("outline_size", 4)
		q.add_theme_font_size_override("font_size", 16)   # the 16 px text floor
		q.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		q.set_anchors_preset(Control.PRESET_TOP_WIDE)
		q.offset_top = 52
		q.offset_right = -8
		q.mouse_filter = Control.MOUSE_FILTER_IGNORE
		b.add_child(q)
	_into.add_child(b)
	_rows[iid] = b


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
	# opened: focus its first usable verb in the Selected panel (keyboard and gamepad reach the verbs at once; Esc
	# closes it and focus returns to the tile); closed: back to the tile
	var first: Button = null
	if _expanded != "" and _detail_box != null:
		for b in _detail_box.find_children("*", "Button", true, false):
			if not (b as Button).disabled:
				first = b
				break
	if first != null:
		focus_later(first)
	elif _rows.has(item_id):
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


## A display-only view with a fuller bag than a new game carries (the --inventory-fixture screenshot): every kind, real
## painted icons, an equipped weapon and ring, a stack, an unslotted piece. [param crowded] (--crowded) adds 30 more with
## long names, and a few with no painted icon (the placeholder), for the crowding evidence.
static func sample_view(crowded: bool = false) -> Dictionary:
	var it := func(id: String, kind: String, name: String, rarity: int, icon: String, fact: String, extra: Dictionary = {}) -> Dictionary:
		var d := {"id": id, "kind": kind, "name": name, "rarity": rarity, "text": "", "qty": 1, "equipped": false, "slot": "", "known": false,
			"fact": fact, "fits": [], "displaces": {}, "compare": [], "verbs": [], "icon": "res://assets/icons/items/%s.png" % icon}
		d.merge(extra, true)
		return d
	var v := {"stones": 1240, "gear": {"base_used": 2, "base_total": 5, "extra_used": 1, "extra_limit": 2, "unslotted": 1},
		"slots": [{"slot": "weapon", "size": 1, "items": [{"id": "a1", "name": "Mirror-Trace Flying Sword", "icon": "res://assets/icons/items/named_blade-mirror-trace-sword.png", "rarity": 5}]},
			{"slot": "armour", "size": 1, "items": []},
			{"slot": "ring", "size": 2, "items": [{"id": "a3", "name": "Ring of Unbroken Edges", "icon": "res://assets/icons/items/named_blade-unbroken-edge-ring.png", "rarity": 4}]},
			{"slot": "necklace", "size": 1, "items": []}, {"slot": "extra", "size": 2, "items": [{"id": "a4", "name": "Edge-Hiding Robe", "icon": "res://assets/icons/items/named_blade-edge-hiding-robe.png", "rarity": 4}]}],
		"items": [
			it.call("a1", "artifact", "Mirror-Trace Flying Sword", 5, "named_blade-mirror-trace-sword", "ATK 182 · DEF 0", {"equipped": true, "slot": "weapon",
				"verbs": [{"id": "unequip", "label": "Unequip", "reason": ""}, {"id": "nurture", "label": "Nurture", "reason": ""}], "text": "A legendary flying sword that remembers every cut it has made."}),
			it.call("a3", "artifact", "Ring of Unbroken Edges", 4, "named_blade-unbroken-edge-ring", "ATK 40 · DEF 22", {"equipped": true, "slot": "ring"}),
			it.call("a4", "artifact", "Edge-Hiding Robe", 4, "named_blade-edge-hiding-robe", "ATK 0 · DEF 96", {"equipped": true, "slot": "unslotted"}),
			it.call("a5", "artifact", "Bronze Bell", 2, "artifact_chuong", "ATK 12 · DEF 30", {"verbs": [{"id": "equip", "label": "Equip…", "reason": ""}]}),
			it.call("a6", "artifact", "Calabash Gourd", 3, "artifact_ho_lo", "ATK 0 · DEF 18"),
			it.call("m1", "cong_phap", "Bạch Kim Bí Điển", 2, "cong_phap_kim", "main · 6 layers · known", {"known": true}),
			it.call("p1", "pill", "Trúc Cơ Đan", 4, "pill_truc_co_dan", "x1 · phẩm 2"),
			it.call("p2", "pill", "Hồi Xuân Đan", 2, "pill_hoi_xuan_dan", "x6 · phẩm 1", {"qty": 6}),
			it.call("t1", "talisman", "Phá Cảnh Phù", 4, "talisman_pha_canh", "x2 · used automatically", {"qty": 2}),
			it.call("h1", "herb", "Hỏa Linh Chi", 2, "herb_hoa_linh_chi", "Hỏa · 12.0 năm"),
			it.call("h2", "herb", "Hoàng Tinh Sâm", 3, "herb_hoang_tinh_sam", "Thổ · 41.0 năm"),
			it.call("x1", "material", "Tinh Thiết", 1, "material_tinh_thiet", "x8", {"qty": 8}),
			it.call("x2", "material", "Yêu Đan", 3, "material_yeu_dan", "x1"),
		]}
	if crowded:
		var long_names: Array = ["Nine-Layered Crimson Phoenix Feather Fan of the Northern Dipper", "Thousand-Year Black Tortoise Shell Shield",
			"Hồng Liên Nghiệp Hỏa Bảo Đỉnh", "Sword of the Seven Severed Dawns", "Thất Tinh Bắc Đẩu Trấn Hồn Ấn", "Moon-Drinking Jade Gourd"]
		var kinds: Array = [["artifact", "named_blade-mirror-trace-sword", "ATK 60 · DEF 10"], ["pill", "pill_hoi_xuan_dan", "x3 · phẩm 1"],
			["herb", "herb_hoa_linh_chi", "Hỏa · 30.0 năm"], ["material", "material_tinh_thiet", "x12"], ["talisman", "missing_icon", "x1 · used automatically"]]
		for i in 30:
			var k: Array = kinds[i % kinds.size()]
			v.items.append(it.call("c%d" % i, str(k[0]), str(long_names[i % long_names.size()]) + (" %d" % (i + 1) if i >= long_names.size() else ""),
				1 + i % 6, str(k[1]), str(k[2]), {"qty": 1 + (i * 7) % 15}))
	return v
