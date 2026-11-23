class_name ProvincePanel
extends PanelContainer
## The province panel (design/ux/province-panel.md, draft 2026-11-23; user: "Design a panel for provinces, learn from
## eu4 or eu5 ... use the unique place catalogue images for the province if it has it"). EU4's province view and EU5's
## location panel lead its shape: a picture and the name with its holder, a strip of the four numbers a player scans
## first (population, development, market access, main good), then tabs for the land, the places, the economy, the
## works and the modifiers. It shows one record of assets/data/world_provinces.json (Provinces rule 3's inventory) and
## never changes the world. Focus moves into it on open and back to the opener on close.

## The panel was closed.
signal closed
## A place line was pressed: [param continent_id] of an existing place (new places have none yet).
signal place_pressed(continent_id: int)

const TABS := ["Overview", "Places", "Economy", "Works", "Modifiers"]
## A raw good class is its kind and rarity band (TradeGoods.class_of: band = ceil(rarity / 2)), so "herb2" is herbs of
## rarity 3-4; the panel names it that way.
const GOOD_KINDS := {"herb": "Herbs", "ore": "Ore", "beast": "Beast parts", "special": "Specialties"}
const KIND_NAMES := {"great_seat": "Great sect seat", "minor_seat": "Minor sect seat", "city": "City", "town": "Town",
	"market": "Market", "village": "Village", "mine": "Mine", "ruin": "Ruin", "peak": "Peak", "spirit_vein": "Spirit vein",
	"hot_spring": "Hot spring", "lake": "Lake", "forest": "Forest", "beast_lair": "Beast lair", "gorge": "Gorge",
	"volcano": "Volcano", "lava_vent": "Lava vent", "lightning_wood": "Lightning wood", "island": "Island"}

var _title := Label.new()
var _han := Label.new()
var _sub := Label.new()
var _image := TextureRect.new()
var _stats := HBoxContainer.new()
var _tabs := TabBar.new()
var _body := RichTextLabel.new()
var _close_button := Button.new()
var _opener: Control = null
var _rec: Dictionary = {}
var _ctx: Dictionary = {}


func _init() -> void:
	visible = false
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	add_child(box)
	var head := HBoxContainer.new()
	box.add_child(head)
	var names := VBoxContainer.new()
	names.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(names)
	_title.theme_type_variation = &"HeadingLabel"
	names.add_child(_title)
	names.add_child(_han)
	_close_button.text = "×"
	TooltipLayer.set_tip(_close_button, tr("Close (Esc)"))
	_close_button.pressed.connect(close_panel)
	head.add_child(_close_button)
	_sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(_sub)
	_image.visible = false   # the province's own painting: its seat's, else its most notable place's (place catalogue)
	_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_image.custom_minimum_size = Vector2(0, 170)
	box.add_child(_image)
	_stats.add_theme_constant_override("separation", 8)
	box.add_child(_stats)
	for t in TABS:
		_tabs.add_tab(tr(t))
	_tabs.tab_changed.connect(func(_i): _fill())
	box.add_child(_tabs)
	_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_body.bbcode_enabled = true
	_body.scroll_active = true
	_body.focus_mode = Control.FOCUS_ALL
	_body.meta_clicked.connect(func(m): place_pressed.emit(int(str(m))))
	box.add_child(_body)


## Opens the panel on province [param rec] (a world_provinces.json record); [param ctx] carries what the record does not:
## {region_name, holder_name, lord_name}; [param image] is the province's painting or null; [param opener] gets focus
## back on close.
func open_province(rec: Dictionary, ctx: Dictionary, image: Texture2D = null, opener: Control = null) -> void:
	_rec = rec
	_ctx = ctx
	var name: String = str(rec.get("name", ""))
	_title.text = name if name != "" else tr("Unnamed land")
	var han: String = str(rec.get("name_han", ""))
	var gloss: String = str(rec.get("gloss", ""))
	_han.text = han + ("  ·  " + gloss if gloss != "" else "")
	_han.visible = _han.text.strip_edges() != ""
	var kind: String = tr("Wilderness") if str(rec.get("kind", "")) == "wilderness" else tr(KIND_NAMES.get(str(rec.get("seat_kind", "")), "Settlement"))
	var bits: Array = [kind]
	if str(ctx.get("region_name", "")) != "":
		bits.append(tr("in %s") % str(ctx.region_name))
	if str(ctx.get("holder_name", "")) != "":
		bits.append(tr("held by %s") % str(ctx.holder_name))
	_sub.text = " · ".join(bits)
	_image.texture = image
	_image.visible = image != null
	_build_stats()
	_tabs.current_tab = 0
	_fill()
	_opener = opener
	visible = true
	_body.grab_focus.call_deferred()


## The record shown now (for tests).
func record() -> Dictionary:
	return _rec


## The body's text on the current tab, without markup (for tests).
func body_text() -> String:
	return _body.get_parsed_text()


## Shows tab [param i] (0 Overview .. 4 Modifiers).
func show_tab(i: int) -> void:
	_tabs.current_tab = clampi(i, 0, TABS.size() - 1)
	_fill()


## Closes the panel and returns focus to its opener.
func close_panel() -> void:
	if not visible:
		return
	visible = false
	if _opener != null and is_instance_valid(_opener):
		_opener.grab_focus()
	closed.emit()


func _unhandled_key_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		close_panel()
		get_viewport().set_input_as_handled()


## The display name of raw good class [param c] ("herb2" -> "Herbs, rarity 3–4"; an unknown class as it is).
static func good_name(c: String) -> String:
	for k in GOOD_KINDS:
		if c.begins_with(k) and c.substr(k.length()).is_valid_int():
			var band: int = int(c.substr(k.length()))
			return "%s, %s" % [TranslationServer.translate(GOOD_KINDS[k]), TranslationServer.translate("rarity %d–%d") % [band * 2 - 1, band * 2]]
	return c


func _build_stats() -> void:
	for c in _stats.get_children():
		_stats.remove_child(c)
		c.queue_free()
	var st: Dictionary = _rec.get("stats", {})
	var wild: bool = str(_rec.get("kind", "")) == "wilderness"
	var acc: Variant = st.get("access", null)
	var good: String = str(st.get("main_good", ""))
	var items: Array = [
		[tr("Population"), "—" if wild else "%.1f / %.1f" % [float(st.get("population", 0)), float(st.get("capacity", 0))],
			tr("Mortal population now / capacity, in settlement units (Provinces F3)")],
		[tr("Development"), str(int(st.get("development", 0))), tr("Built levels plus population units (a display index)")],
		[tr("Access"), "—" if acc == null else "%d %%" % int(round(float(acc) * 100.0)),
			tr("Market access: infrastructure / usage, at most 100 % (Provinces F6)")],
		[tr("Main good"), good_name(good) if good != "" else tr("none"), tr("The class with the largest potential (Provinces F1)")],
	]
	for it in items:
		var cell := VBoxContainer.new()
		cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var a := Label.new()
		a.text = str(it[0])
		a.add_theme_font_size_override("font_size", 12)
		var b := Label.new()
		b.text = str(it[1])
		b.theme_type_variation = &"HeadingLabel"
		cell.add_child(a)
		cell.add_child(b)
		TooltipLayer.set_tip(cell, str(it[2]))
		_stats.add_child(cell)


func _fill() -> void:
	var st: Dictionary = _rec.get("stats", {})
	var lines: Array = []
	match _tabs.current_tab:
		0:   # Overview: the lore and the land
			if str(_rec.get("lore", "")) != "":
				lines.append(str(_rec.lore))
				lines.append("")
			lines.append("[b]%s[/b]" % tr("Land"))
			var land: Dictionary = _rec.get("land", {})
			for k in land:
				lines.append("  %s  %d %%" % [str(k).replace("_", " ").capitalize(), int(round(float(land[k]) * 100.0))])
			lines.append("  " + tr("%d tiles, height %d–%d m") % [int(_rec.get("tiles", 0)), int(float(_rec.get("elev_mean", 0))), int(float(_rec.get("elev_max", 0)))])
			var water: Array = []
			if int(_rec.get("river_tiles", 0)) > 0:
				water.append(tr("a river (%d tiles)") % int(_rec.river_tiles))
			if bool(_rec.get("coast", false)):
				water.append(tr("the coast"))
			if not water.is_empty():
				lines.append("  " + tr("On %s") % tr(" and ").join(water))
			if str(_ctx.get("lord_name", "")) != "":
				lines.append("")
				lines.append(tr("Local lord: %s") % str(_ctx.lord_name))
		1:   # Places
			for p in _rec.get("places", []):
				var nm: String = str(p.get("name", ""))
				if nm == "":
					nm = tr("(unnamed)")
				var kind: String = tr(KIND_NAMES.get(str(p.get("kind", "")), str(p.get("kind", "")).capitalize()))
				var tag: String = ""
				if bool(p.get("proposal", false)):
					tag = "  [i]%s[/i]" % tr("proposed sect")
				elif bool(p.get("new", false)):
					tag = "  [i]%s[/i]" % tr("new")
				var han: String = str(p.get("name_han", ""))
				var line: String = "%s %s — %s%s" % [nm, ("(" + han + ")") if han != "" else "", kind, tag]
				if p.has("id"):
					line = "[url=%d]%s[/url]" % [int(p.id), line]
				lines.append(line)
				# what one sees there and its story, small, under the name (new places have no panel of their own yet)
				var gl: String = str(p.get("gloss", ""))
				var desc: Array = []
				if gl != "":
					desc.append("[i]%s.[/i]" % gl.trim_suffix("."))
				if str(p.get("look", "")) != "":
					desc.append(str(p.look))
				if bool(p.get("new", false)) and str(p.get("lore", "")) != "":
					desc.append(str(p.lore))
				if not desc.is_empty():
					lines.append("[font_size=13][indent]%s[/indent][/font_size]" % " ".join(desc))
				lines.append("")
		2:   # Economy
			var prod: Dictionary = st.get("production", {})
			var own: Dictionary = st.get("own_output", {})
			if str(_rec.get("kind", "")) == "wilderness":
				lines.append("[b]%s[/b]" % tr("Output, gathered by its neighbours"))
				for k in own:
					lines.append("  %s  %.0f" % [good_name(str(k)), float(own[k])])
				var to: Array = _rec.get("passes_to", [])
				if not to.is_empty():
					lines.append("")
					lines.append(tr("Passed on to:"))
					for t in to:
						var who: String = str(t.get("name", "")) if str(t.get("name", "")) != "" else str(t.province)
						lines.append("  %s  %d %%" % [who, int(round(float(t.share) * 100.0))])
			else:
				lines.append("[b]%s[/b]" % tr("Production a season"))
				for k in prod:
					var from_wild: float = float(prod[k]) - float(own.get(k, 0.0))
					var extra: String = ("  (" + tr("%.0f from the wilds") % from_wild + ")") if from_wild > 0.5 else ""
					lines.append("  %s  %.0f%s" % [good_name(str(k)), float(prod[k]), extra])
				var sec: Array = st.get("secondary_goods", [])
				if not sec.is_empty():
					lines.append("")
					lines.append(tr("Also known for: %s") % ", ".join(sec.map(func(g): return good_name(str(g)))))
				lines.append("")
				lines.append("[b]%s[/b]" % tr("Market access"))
				lines.append("  " + tr("Infrastructure %d against usage %d") % [int(st.get("infrastructure", 0)), int(st.get("usage", 0))])
				if int(st.get("infra_old", 0)) > 0:
					lines.append("  " + tr("of which old roads and porters: %d") % int(st.infra_old))
		3:   # Works
			var b: Array = st.get("buildings", [])
			lines.append("[b]%s[/b]  %d / %d" % [tr("Buildings"), b.size(), int(st.get("slots", 0))])
			for it in b:
				lines.append("  %s  %s" % [tr(str(it.get("name", it.get("kind", "")))), "●".repeat(int(it.get("level", 1))) + "○".repeat(maxi(0, 5 - int(it.get("level", 1))))])
			for i in maxi(0, int(st.get("slots", 0)) - b.size()):
				lines.append("  [i]%s[/i]" % tr("empty slot"))
			lines.append("")
			lines.append(tr("Road tiles %d · river tiles %d") % [int(_rec.get("road_tiles", 0)), int(_rec.get("river_tiles", 0))])
		4:   # Modifiers
			var mods: Array = st.get("modifiers", [])
			if mods.is_empty():
				lines.append(tr("No modifiers: no works, scars, events or policies touch this province yet."))
			for m in mods:
				lines.append("  %s — %s" % [str(m.get("text", "")), str(m.get("source", ""))])
	_body.text = "\n".join(lines)
