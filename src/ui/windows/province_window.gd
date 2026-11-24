class_name ProvinceWindow
extends GameWindow
## The province window (design/ux/province-panel.md; user 2026-11-23: "Design a panel for provinces, learn from eu4 or
## eu5 ... use the unique place catalogue images"; moved into the window host 2026-11-24). EU4's province view and
## EU5's location panel lead its shape: the name with its holder and a picture in the sticky header, the four numbers
## a player scans first (population, development, market access, main good), then the land, the places, the economy,
## the works and the modifiers as sections (jump targets). It shows GameQuery.province's copy (Provinces rule 3's
## inventory) and never changes the world. A known place opens its place panel.

## The sections, in order (keys are jump targets).
const SECTIONS := [["overview", "Overview"], ["places", "Places"], ["economy", "Economy"], ["works", "Works"],
	["modifiers", "Modifiers"]]
## A raw good class is its kind and rarity band (TradeGoods.class_of: band = ceil(rarity / 2)), so "herb2" is herbs of
## rarity 3-4; the window names it that way.
const GOOD_KINDS := {"herb": "Herbs", "ore": "Ore", "beast": "Beast parts", "special": "Specialties"}
const KIND_NAMES := {"great_seat": "Great sect seat", "minor_seat": "Minor sect seat", "city": "City", "town": "Town",
	"market": "Market", "village": "Village", "mine": "Mine", "ruin": "Ruin", "peak": "Peak", "spirit_vein": "Spirit vein",
	"hot_spring": "Hot spring", "lake": "Lake", "forest": "Forest", "beast_lair": "Beast lair", "gorge": "Gorge",
	"volcano": "Volcano", "lava_vent": "Lava vent", "lightning_wood": "Lightning wood", "island": "Island"}

## Mortals per settlement unit for the display (ui_hud.json greybox.mortals_per_unit; user decision 2026-11-24).
var mortals_per_unit: float = 1000.0
var _picture: Control = null
var _texts: Dictionary = {}   # section key -> its RichTextLabel


func kind() -> String:
	return "provinces"


func window_title(v: Dictionary) -> String:
	var name: String = str(v.get("name", ""))
	return name if name != "" else tr("Unnamed land")


## Whether the picture is the missing-art placeholder (no painting for this province; tests).
func shows_placeholder() -> bool:
	return _picture != null and _picture.get_children().any(func(c): return bool(c.get_meta("placeholder", false)))


## The text of section [param key] without markup (tests).
func section_text(key: String) -> String:
	var t: RichTextLabel = _texts.get(key)
	return t.get_parsed_text() if t != null else ""


func _build() -> void:
	_texts.clear()
	var v: Dictionary = view
	var han: String = str(v.get("name_han", ""))
	var gloss: String = str(v.get("gloss", ""))
	if han != "" or gloss != "":
		header.add_child(_label(han + ("  ·  " + gloss if gloss != "" else "")))
	var kind_s: String = tr("Wilderness") if str(v.get("kind", "")) == "wilderness" else tr(KIND_NAMES.get(str(v.get("seat_kind", "")), "Settlement"))
	var bits: Array = [kind_s]
	if str(v.get("region_name", "")) != "":
		bits.append(tr("in %s") % str(v.region_name))
	if str(v.get("holder_name", "")) != "":
		bits.append(tr("held by %s") % str(v.holder_name))
	var sub := _label(" · ".join(bits))
	sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	header.add_child(sub)
	# the seat's painting, else the first place's that has one; else the missing-art placeholder (Illustrated.framed)
	var tex: Texture2D = null
	for cid in v.get("art_order", []):
		tex = PortraitPicker.place_painting(int(cid))
		if tex != null:
			break
	_picture = Illustrated.framed(tex, Vector2(0, 170), tr("No painting yet"))
	header.add_child(_picture)
	header.add_child(_stat_strip(v))
	for sk in SECTIONS:
		section(str(sk[0]), tr(str(sk[1])))
		var t := RichTextLabel.new()
		t.bbcode_enabled = true
		t.fit_content = true
		t.scroll_active = false
		t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		t.text = "\n".join(section_lines(v, str(sk[0])))
		t.meta_clicked.connect(_on_link)
		body.add_child(t)
		_texts[str(sk[0])] = t


func _on_link(meta: Variant) -> void:
	var sid: String = str(Dictionary(view.get("place_ids", {})).get(str(meta), ""))
	if sid != "":
		open_requested.emit("place", sid, "")


func _label(text: String) -> Label:
	var l := Label.new()
	l.text = text
	return l


func _stat_strip(v: Dictionary) -> HBoxContainer:
	var strip := HBoxContainer.new()
	strip.add_theme_constant_override("separation", 8)
	var st: Dictionary = v.get("stats", {})
	var wild: bool = str(v.get("kind", "")) == "wilderness"
	var acc: Variant = st.get("access", null)
	var good: String = str(st.get("main_good", ""))
	var items: Array = [
		[tr("Population"), "—" if wild else "%s / %s" % [people(float(st.get("population", 0)), mortals_per_unit),
				people(float(st.get("capacity", 0)), mortals_per_unit)],
			tr("Mortals now / capacity (Provinces F3; one settlement unit shown as %s mortals)") % people(1.0, mortals_per_unit)],
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
		strip.add_child(cell)
	return strip


## A good class's display name: "herb2" -> "Herbs, rarity 3–4" (the kind and its rarity band).
static func good_name(c: String) -> String:
	for k in GOOD_KINDS:
		if c.begins_with(k) and c.substr(k.length()).is_valid_int():
			var band: int = int(c.substr(k.length()))
			return "%s, %s" % [TranslationServer.translate(GOOD_KINDS[k]), TranslationServer.translate("rarity %d–%d") % [band * 2 - 1, band * 2]]
	return c


## Mortals shown for [param units] settlement units (user decision 2026-11-24: population as people, 1 unit = 1,000
## mortals; the game computes in units), rounded to the hundred, with thousands separators: 3.4 -> "3,400".
static func people(units: float, per_unit: float = 1000.0) -> String:
	var n: int = int(round(units * per_unit / 100.0)) * 100
	var s: String = str(absi(n))
	var out: String = ""
	while s.length() > 3:
		out = "," + s.substr(s.length() - 3) + out
		s = s.substr(0, s.length() - 3)
	return ("-" if n < 0 else "") + s + out


## The BBCode lines of section [param key] for province view [param v] (overview, places, economy, works, modifiers).
## A known place's line is a link ([url=<continent id>]).
static func section_lines(v: Dictionary, key: String) -> Array:
	var T := func(s: String) -> String: return TranslationServer.translate(s)
	var st: Dictionary = v.get("stats", {})
	var lines: Array = []
	match key:
		"overview":   # the lore and the land
			if str(v.get("lore", "")) != "":
				lines.append(str(v.lore))
				lines.append("")
			lines.append("[b]%s[/b]" % T.call("Land"))
			var land: Dictionary = v.get("land", {})
			for k in land:
				lines.append("  %s  %d %%" % [str(k).replace("_", " ").capitalize(), int(round(float(land[k]) * 100.0))])
			lines.append("  " + T.call("%d tiles, height %d–%d m") % [int(v.get("tiles", 0)), int(float(v.get("elev_mean", 0))), int(float(v.get("elev_max", 0)))])
			var water: Array = []
			if int(v.get("river_tiles", 0)) > 0:
				water.append(T.call("a river (%d tiles)") % int(v.river_tiles))
			if bool(v.get("coast", false)):
				water.append(T.call("the coast"))
			if not water.is_empty():
				lines.append("  " + T.call("On %s") % T.call(" and ").join(water))
			if str(v.get("lord_name", "")) != "":
				lines.append("")
				lines.append(T.call("Local lord: %s") % str(v.lord_name))
		"places":
			var ids: Dictionary = v.get("place_ids", {})
			for p in v.get("places", []):
				var nm: String = str(p.get("name", ""))
				if nm == "":
					nm = T.call("(unnamed)")
				var kind_s: String = T.call(KIND_NAMES.get(str(p.get("kind", "")), str(p.get("kind", "")).capitalize()))
				var han: String = str(p.get("name_han", ""))
				var line: String = "%s %s — %s" % [nm, ("(" + han + ")") if han != "" else "", kind_s]
				if p.has("id") and ids.has(str(int(p.id))):   # a known place opens its panel
					line = "[url=%d]%s[/url]" % [int(p.id), line]
				lines.append(line)
				var desc: Array = []
				var gl: String = str(p.get("gloss", ""))
				if gl != "":
					desc.append("[i]%s.[/i]" % gl.trim_suffix("."))
				if str(p.get("look", "")) != "":
					desc.append(str(p.look))
				if str(p.get("lore", "")) != "":   # the provinces-v2 places carry their lore here
					desc.append(str(p.lore))
				if not desc.is_empty():
					lines.append("[font_size=13][indent]%s[/indent][/font_size]" % " ".join(desc))
				lines.append("")
		"economy":
			var prod: Dictionary = st.get("production", {})
			var own: Dictionary = st.get("own_output", {})
			if str(v.get("kind", "")) == "wilderness":
				lines.append("[b]%s[/b]" % T.call("Output, gathered by its neighbours"))
				for k in own:
					lines.append("  %s  %.0f" % [good_name(str(k)), float(own[k])])
				var to: Array = v.get("passes_to", [])
				if not to.is_empty():
					lines.append("")
					lines.append(T.call("Passed on to:"))
					for t in to:
						var who: String = str(t.get("name", "")) if str(t.get("name", "")) != "" else str(t.province)
						lines.append("  %s  %d %%" % [who, int(round(float(t.share) * 100.0))])
			else:
				lines.append("[b]%s[/b]" % T.call("Production a season"))
				for k in prod:
					var from_wild: float = float(prod[k]) - float(own.get(k, 0.0))
					var extra: String = ("  (" + T.call("%.0f from the wilds") % from_wild + ")") if from_wild > 0.5 else ""
					lines.append("  %s  %.0f%s" % [good_name(str(k)), float(prod[k]), extra])
				var sec: Array = st.get("secondary_goods", [])
				if not sec.is_empty():
					lines.append("")
					lines.append(T.call("Also known for: %s") % ", ".join(sec.map(func(g): return good_name(str(g)))))
				lines.append("")
				lines.append("[b]%s[/b]" % T.call("Market access"))
				lines.append("  " + T.call("Infrastructure %d against usage %d") % [int(st.get("infrastructure", 0)), int(st.get("usage", 0))])
				if int(st.get("infra_old", 0)) > 0:
					lines.append("  " + T.call("of which old roads and porters: %d") % int(st.infra_old))
		"works":
			var b: Array = st.get("buildings", [])
			lines.append("[b]%s[/b]  %d / %d" % [T.call("Buildings"), b.size(), int(st.get("slots", 0))])
			for it in b:
				var lv: int = int(it.get("level", 1))
				lines.append("  %s  %s" % [T.call(str(it.get("name", it.get("kind", "")))), "●".repeat(lv) + "○".repeat(maxi(0, 5 - lv))])
			for i in maxi(0, int(st.get("slots", 0)) - b.size()):
				lines.append("  [i]%s[/i]" % T.call("empty slot"))
			lines.append("")
			lines.append(T.call("Road tiles %d · river tiles %d") % [int(v.get("road_tiles", 0)), int(v.get("river_tiles", 0))])
		"modifiers":
			var mods: Array = st.get("modifiers", [])
			if mods.is_empty():
				lines.append(T.call("No modifiers: no works, scars, events or policies touch this province yet."))
			for m in mods:
				lines.append("  %s — %s" % [str(m.get("text", "")), str(m.get("source", ""))])
	return lines
