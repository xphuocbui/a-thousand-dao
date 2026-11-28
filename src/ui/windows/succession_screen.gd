class_name SuccessionScreen
extends GameWindow
## The Continue-mode succession screen (design/gdd/codex-karmic-carryover.md, Rules 4-6, Formulas B,
## UI Requirements, AC-CK-18, AC-CK-20). Shown inside [FullScreenHost] after a Continue-mode death.
## Built strictly from read-only [method GameQuery.succession_view] dictionaries (ADR-0006): never
## reads or mutates [GameSession]; emits clean signals and [signal GameWindow.action_requested].
##
## Displays: epitaph scroll, karma total (`earned + carried` breakdown), heir candidate cards
## (portrait, relation, realm, age, sect, place, notable ties, karma cost — unaffordable heirs greyed
## with cost label), Rebirth panel (3 free origins + Lineage sect/clan with karma cost and survival
## badge), destiny perk extra-options selector (`0..max_perk_extra` clamped against remaining unheld
## perks), and an "End this playthrough" confirm-in-place control.

## Emitted when the player confirms succeeding as heir [param heir_id] with [param opts].
signal heir_chosen(heir_id: String, opts: Dictionary)
## Emitted when the player confirms rebirth with [param opts].
signal rebirth_chosen(opts: Dictionary)
## Emitted when the player confirms ending this playthrough.
signal end_playthrough_chosen

const DEFAULT_BASE_PERKS := 3
const DEFAULT_TOTAL_PERKS := 8
const UNAFFORDABLE_ALPHA := 0.55

var _selected_kind: String = ""          # "heir" | "rebirth_origin" | "rebirth_lineage_sect" | "rebirth_lineage_clan"
var _selected_id: String = ""            # heir_id or origin_id
var _rebirth_name: String = "Tái Sinh"
var _rebirth_gender: String = "male"
var _rebirth_birth_mode: String = "thien_dinh"
var _perk_extra: int = 0
var _armed_end: bool = false


func kind() -> String:
	return "succession"


func window_title(_v: Dictionary) -> String:
	return tr("Succession (Luân Hồi Kế Thừa)")


func column_width() -> int:
	return 900 if compact else 1440


## The active choice kind ("heir", "rebirth_origin", "rebirth_lineage_sect", "rebirth_lineage_clan", or "").
func selected_kind() -> String:
	return _selected_kind


## The active heir id or origin id ("" for lineage or no selection).
func selected_id() -> String:
	return _selected_id


## Total karma available at this succession (earned + carried).
func karma_total() -> int:
	return maxi(0, int(view.get("karma", 0)))


## Karma earned by the life that just ended.
func karma_earned() -> int:
	return maxi(0, int(view.get("karma_earned", 0)))


## Karma carried over from earlier successions of this playthrough.
func karma_carried() -> int:
	return maxi(0, karma_total() - karma_earned())


## Base karma cost of the currently selected heir or lineage option (0 for free origin / Luyện Khí heir).
func base_cost() -> int:
	if _selected_kind == "heir":
		var h: Dictionary = _find_heir(_selected_id)
		return maxi(0, int(h.get("cost", 0)))
	if _selected_kind == "rebirth_lineage_sect" or _selected_kind == "rebirth_lineage_clan":
		return maxi(0, int(Dictionary(view.get("lineage", {})).get("cost", 3)))
	return 0


## Effective birth mode of the selected successor (Rule 5: heir keeps dead life's mode; reborn chooses it).
func effective_birth_mode() -> String:
	if _selected_kind == "heir":
		var bm: String = str(view.get("birth_mode", "thien_dinh"))
		return bm if bm != "" else "thien_dinh"
	return _rebirth_birth_mode


## Unheld destiny perk count for the currently selected successor.
func current_unheld_perks() -> int:
	var total_p: int = int(view.get("total_perks", DEFAULT_TOTAL_PERKS))
	if _selected_kind == "heir":
		var h: Dictionary = _find_heir(_selected_id)
		if h.has("unheld_perks"):
			return maxi(0, int(h.unheld_perks))
		if h.has("perks"):
			return maxi(0, total_p - Array(h.perks).size())
	if view.has("unheld_perks"):
		return maxi(0, int(view.unheld_perks))
	return maxi(0, total_p)


## Maximum valid `perk_extra` for the current selection (Formula B, AC-CK-09, AC-CK-17).
func max_perk_extra() -> int:
	if effective_birth_mode() != "thien_dinh":
		return 0
	var cap_data: int = int(view.get("perk_extra_max", 3))
	var cap_karma: int = karma_total() - base_cost()
	var cap_pool: int = maxi(0, current_unheld_perks() - DEFAULT_BASE_PERKS)
	return maxi(0, mini(mini(cap_data, cap_karma), cap_pool))


## Current selected extra destiny perk options (`0..max_perk_extra()`).
func perk_extra() -> int:
	return clampi(_perk_extra, 0, max_perk_extra())


## Total karma cost of the current selection (`base_cost() + perk_extra()`).
func total_cost() -> int:
	return base_cost() + perk_extra()


## Selects affordable heir [param heir_id]. Returns false if not found or unaffordable.
func select_heir(heir_id: String) -> bool:
	var h: Dictionary = _find_heir(heir_id)
	if h.is_empty() or not _is_heir_affordable(h):
		return false
	_selected_kind = "heir"
	_selected_id = heir_id
	_armed_end = false
	_perk_extra = clampi(_perk_extra, 0, max_perk_extra())
	_rebuild()
	return true


## Selects a free rebirth origin [param origin_id]. Returns false if unknown.
func select_rebirth_origin(origin_id: String) -> bool:
	if not _has_origin(origin_id):
		return false
	_selected_kind = "rebirth_origin"
	_selected_id = origin_id
	_armed_end = false
	_perk_extra = clampi(_perk_extra, 0, max_perk_extra())
	_rebuild()
	return true


## Selects a paid lineage rebirth ([param lineage_kind] is `"sect"` or `"clan"`). Returns false if unavailable/unaffordable.
func select_rebirth_lineage(lineage_kind: String) -> bool:
	var lin: Dictionary = Dictionary(view.get("lineage", {}))
	var cost: int = int(lin.get("cost", 3))
	var affordable: bool = bool(lin.get("affordable", karma_total() >= cost)) and karma_total() >= cost
	if not affordable:
		return false
	if lineage_kind == "sect":
		if str(lin.get("sect_id", "")) == "" or not bool(lin.get("sect_alive", false)):
			return false
		_selected_kind = "rebirth_lineage_sect"
		_selected_id = ""
	elif lineage_kind == "clan":
		if not bool(lin.get("clan_available", false)):
			return false
		_selected_kind = "rebirth_lineage_clan"
		_selected_id = ""
	else:
		return false
	_armed_end = false
	_perk_extra = clampi(_perk_extra, 0, max_perk_extra())
	_rebuild()
	return true


## Sets extra destiny perk options clamped to `0..max_perk_extra()`.
func set_perk_extra(n: int) -> void:
	_perk_extra = clampi(n, 0, max_perk_extra())
	_rebuild()


## Sets rebirth birth mode (`"thien_dinh"` or `"tu_dinh"`).
func set_rebirth_birth_mode(mode: String) -> void:
	_rebirth_birth_mode = "tu_dinh" if mode == "tu_dinh" else "thien_dinh"
	_perk_extra = clampi(_perk_extra, 0, max_perk_extra())
	_rebuild()


## Emits the selected heir or rebirth succession signal and [signal GameWindow.action_requested].
func confirm_selection() -> bool:
	if locked or _selected_kind == "":
		return false
	var extra: int = perk_extra()
	if _selected_kind == "heir":
		var h: Dictionary = _find_heir(_selected_id)
		if h.is_empty() or not _is_heir_affordable(h):
			return false
		var opts := {"perk_extra": extra}
		heir_chosen.emit(_selected_id, opts)
		action_requested.emit("succeed_heir", [_selected_id, opts])
		return true
	var lin_kind: String = ""
	var origin: String = _selected_id
	if _selected_kind == "rebirth_lineage_sect":
		lin_kind = "sect"
		origin = "tong_mon"
	elif _selected_kind == "rebirth_lineage_clan":
		lin_kind = "clan"
		origin = "gia_toc"
	var clean_name: String = _rebirth_name.strip_edges()
	var ropts := {
		"name": clean_name if clean_name != "" else "Tái Sinh",
		"gender": _rebirth_gender,
		"origin": origin if origin != "" else "tan_tu",
		"birth_mode": _rebirth_birth_mode,
		"mode": "custom" if _rebirth_birth_mode == "tu_dinh" else "roll",
		"lineage_kind": lin_kind,
		"perk_extra": extra,
	}
	rebirth_chosen.emit(ropts)
	action_requested.emit("succeed_rebirth", [ropts])
	return true


## Cancels an armed "End this playthrough" confirm on Esc (FullScreenHost convention).
func cancel_inline() -> bool:
	if _armed_end:
		_armed_end = false
		_rebuild()
		return true
	return false


func show_view(v: Dictionary, section: String, is_locked: bool) -> void:
	# Reset stale selection when a brand-new view arrives.
	if v != view:
		_selected_kind = ""
		_selected_id = ""
		_perk_extra = 0
		_armed_end = false
		_rebirth_birth_mode = str(v.get("birth_mode", "thien_dinh"))
		if _rebirth_birth_mode != "tu_dinh":
			_rebirth_birth_mode = "thien_dinh"
	super.show_view(v, section, is_locked)


func _rebuild() -> void:
	var y: int = scroll.scroll_vertical
	super.show_view(view, "", locked)
	scroll.set_deferred("scroll_vertical", y)


func _build() -> void:
	var v: Dictionary = view
	_perk_extra = clampi(_perk_extra, 0, max_perk_extra())

	_build_sticky_header()
	var g: VBoxContainer = Illustrated.ground(body)
	_build_epitaph_and_karma(g, v)

	var left_col: VBoxContainer = g
	var right_col: VBoxContainer = g
	if not compact:
		var cols := HBoxContainer.new()
		cols.add_theme_constant_override("separation", 12)
		g.add_child(cols)
		left_col = VBoxContainer.new()
		left_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		left_col.add_theme_constant_override("separation", 8)
		cols.add_child(left_col)
		right_col = VBoxContainer.new()
		right_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		right_col.add_theme_constant_override("separation", 8)
		cols.add_child(right_col)

	_build_heirs_section(left_col, Array(v.get("heirs", [])))
	_build_rebirth_section(right_col, v)
	_build_perk_extra_section(g)
	_build_action_bar()


func _build_sticky_header() -> void:
	var k_total: int = karma_total()
	var k_earn: int = karma_earned()
	var k_carry: int = karma_carried()
	var spent: int = total_cost()
	var rem: int = maxi(0, k_total - spent)

	var kh := Label.new()
	kh.name = "KarmaSummary"
	kh.theme_type_variation = &"HeadingLabel"
	kh.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	kh.text = tr("Karma (Nghiệp Duyên): %d  (earned %d + carried %d)  ·  Selected spend: %d  ·  Remaining: %d") % [
		k_total, k_earn, k_carry, spent, rem,
	]
	TooltipLayer.set_tip(kh, {
		"title": tr("Karma (Nghiệp Duyên)"),
		"fact": tr("%d total (%d earned + %d carried)") % [k_total, k_earn, k_carry],
		"summary": tr("Karma belongs to this Continue playthrough only. Spend it on heirs, lineage rebirth, or extra destiny perk options; unspent karma carries to future successions."),
	})
	header.add_child(kh)


func _build_epitaph_and_karma(parent: Control, v: Dictionary) -> void:
	var box: VBoxContainer = section_in(parent, "epitaph", tr("Epitaph Scroll (Bia Mộ)"))
	box.get_parent().name = "EpitaphScroll"

	var ep_text: String = str(v.get("epitaph", "")).strip_edges()
	var ep := Label.new()
	ep.name = "EpitaphText"
	ep.text = ep_text if ep_text != "" else tr("A cultivator's flame dims, yet the world remembers the path they walked.")
	ep.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ep.add_theme_color_override("font_color", Illustrated.INK)
	box.add_child(ep)


func _build_heirs_section(parent: Control, heirs: Array) -> void:
	var box: VBoxContainer = section_in(parent, "heirs", tr("Heirs (Kế Thừa) — %d candidates") % heirs.size())
	box.get_parent().name = "HeirsPanel"

	if heirs.is_empty():
		var none := line(tr("No living children or disciples are eligible to succeed you. Choose Rebirth or end this playthrough."), box)
		none.name = "NoHeirsLabel"
		return

	var note := Label.new()
	note.theme_type_variation = &"RowLabel"
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.text = tr("Continue directly as a living child or disciple, keeping their realm, items, ties, sect, and place. Keeps the dead life's birth mode.")
	box.add_child(note)

	for raw in heirs:
		if not (raw is Dictionary):
			continue
		var h: Dictionary = raw
		var hid: String = str(h.get("id", ""))
		var hname: String = str(h.get("name", hid))
		var rel: String = str(h.get("relation", "heir"))
		var realm_lbl: String = str(h.get("realm_label", ""))
		var age_n: int = int(roundf(float(h.get("age", 16.0))))
		var sect_name: String = str(h.get("sect_name", ""))
		var place_name: String = str(h.get("place_name", ""))
		var cost: int = maxi(0, int(h.get("cost", 0)))
		var affordable: bool = _is_heir_affordable(h)
		var is_sel: bool = _selected_kind == "heir" and _selected_id == hid

		var card := PanelContainer.new()
		card.name = "HeirCard_" + hid
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.focus_mode = Control.FOCUS_ALL
		card.set_meta(&"heir_id", hid)
		card.set_meta(&"affordable", affordable)
		card.set_meta(&"heir_cost", cost)
		card.add_theme_stylebox_override("panel", Illustrated.box(
			Illustrated.PAPER if is_sel else Illustrated.PAPER_TILE,
			Illustrated.CINNABAR if is_sel else (Illustrated.BRASS if affordable else Illustrated.BRASS_DIM),
			3 if is_sel else (2 if affordable else 1),
			8.0,
			2
		))
		if not affordable:
			card.modulate = Color(0.78, 0.78, 0.78, UNAFFORDABLE_ALPHA)

		var row_box := HBoxContainer.new()
		row_box.add_theme_constant_override("separation", 10)
		card.add_child(row_box)

		var portrait_dict: Dictionary = Dictionary(h.get("portrait", {}))
		var ptex: Texture2D = PortraitPicker.texture_for(portrait_dict) if not portrait_dict.is_empty() else null
		var med: Control = Illustrated.medallion(ptex, 60.0, not affordable)
		med.name = "HeirPortrait_" + hid
		row_box.add_child(med)

		var info := VBoxContainer.new()
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		info.add_theme_constant_override("separation", 2)
		row_box.add_child(info)

		var head_row := HBoxContainer.new()
		head_row.add_theme_constant_override("separation", 8)
		info.add_child(head_row)

		var nl := Label.new()
		nl.text = "%s (%s)" % [hname, rel]
		nl.theme_type_variation = &"HeadingLabel"
		nl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		nl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		head_row.add_child(nl)

		var cost_l := Label.new()
		cost_l.name = "HeirCost_" + hid
		cost_l.theme_type_variation = &"RowLabel"
		cost_l.text = tr("Free (0 karma)") if cost == 0 else tr("Cost: %d karma") % cost
		cost_l.add_theme_color_override("font_color", Illustrated.CINNABAR if not affordable else Illustrated.GILT)
		head_row.add_child(cost_l)

		var det := Label.new()
		det.name = "HeirDetails_" + hid
		det.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		det.text = tr("%s · Age %d · %s · %s") % [
			realm_lbl,
			age_n,
			sect_name if sect_name != "" else tr("Loose cultivator"),
			place_name if place_name != "" else tr("Unknown place"),
		]
		info.add_child(det)

		var ties_text: String = _format_notable_ties(Array(h.get("notable_ties", [])))
		var tl := Label.new()
		tl.name = "HeirTies_" + hid
		tl.theme_type_variation = &"RowLabel"
		tl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		tl.text = tr("Notable ties: %s") % (ties_text if ties_text != "" else tr("None"))
		info.add_child(tl)

		var btn := Button.new()
		btn.name = "SelectHeir_" + hid
		btn.theme_type_variation = &"CommitButton" if is_sel else &""
		btn.disabled = locked or not affordable
		if is_sel:
			btn.text = tr("Selected ✓")
		elif not affordable:
			btn.text = tr("Need %d karma") % cost
		else:
			btn.text = tr("Choose Heir")
		btn.accessibility_name = "%s, %s, %s, %s" % [hname, rel, realm_lbl, cost_l.text]
		if not affordable:
			TooltipLayer.set_tip(btn, {
				"title": hname,
				"fact": cost_l.text,
				"summary": tr("Not enough karma: costs %d karma, you have %d.") % [cost, karma_total()],
			})
		else:
			TooltipLayer.set_tip(btn, {
				"title": hname,
				"fact": "%s · %s" % [realm_lbl, cost_l.text],
				"summary": tr("Continue immediately as %s (%s) at %s.") % [hname, rel, place_name],
			})
		btn.pressed.connect(func(): select_heir(hid))
		info.add_child(btn)

		card.accessibility_name = "%s, %s, %s, age %d, %s" % [hname, rel, realm_lbl, age_n, cost_l.text]
		box.add_child(card)


func _build_rebirth_section(parent: Control, v: Dictionary) -> void:
	var years: int = int(v.get("rebirth_years", 16))
	var seasons: int = int(v.get("rebirth_seasons", 64))
	var box: VBoxContainer = section_in(parent, "rebirth", tr("Rebirth (Chuyển Thế) — +%d years") % years)
	box.get_parent().name = "RebirthPanel"

	var desc := Label.new()
	desc.theme_type_variation = &"RowLabel"
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.text = tr("The same world advances %d years (%d seasons) while a new age-16 cultivator grows up. Begins with 2 Phá Cảnh Phù and no starting ties.") % [years, seasons]
	box.add_child(desc)

	# Name, gender, birth mode controls for rebirth
	var id_row := HBoxContainer.new()
	id_row.add_theme_constant_override("separation", 6)
	box.add_child(id_row)

	var name_ed := LineEdit.new()
	name_ed.name = "RebirthName"
	name_ed.text = _rebirth_name
	name_ed.placeholder_text = tr("Successor name")
	name_ed.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_ed.accessibility_name = tr("Reborn cultivator name")
	name_ed.text_changed.connect(func(t: String): _rebirth_name = t)
	id_row.add_child(name_ed)

	for g_pair in [["male", tr("Male")], ["female", tr("Female")]]:
		var gid: String = str(g_pair[0])
		var gb := Button.new()
		gb.name = "RebirthGender_" + gid
		gb.text = str(g_pair[1])
		gb.theme_type_variation = &"CommitButton" if _rebirth_gender == gid else &"TextButton"
		gb.accessibility_name = tr("Gender: %s") % str(g_pair[1])
		gb.pressed.connect(func():
			_rebirth_gender = gid
			_rebuild()
		)
		id_row.add_child(gb)

	var bm_row := HBoxContainer.new()
	bm_row.add_theme_constant_override("separation", 6)
	box.add_child(bm_row)
	var bm_lbl := Label.new()
	bm_lbl.text = tr("Birth mode:")
	bm_lbl.theme_type_variation = &"RowLabel"
	bm_row.add_child(bm_lbl)
	for bm_pair in [["thien_dinh", tr("Fated (Thiên Định)")], ["tu_dinh", tr("Self-made (Tự Định)")]]:
		var bmid: String = str(bm_pair[0])
		var bmb := Button.new()
		bmb.name = "BirthMode_" + bmid
		bmb.text = str(bm_pair[1])
		bmb.theme_type_variation = &"CommitButton" if _rebirth_birth_mode == bmid else &"TextButton"
		bmb.accessibility_name = tr("Rebirth birth mode: %s") % str(bm_pair[1])
		TooltipLayer.set_tip(bmb, {
			"title": str(bm_pair[1]),
			"summary": tr("Writes to the Codex, earns karma, and rolls 3 + extra destiny perks.") if bmid == "thien_dinh" else tr("Custom stats and free perk pick; earns 0 karma and writes no Codex knowledge."),
		})
		bmb.pressed.connect(func(): set_rebirth_birth_mode(bmid))
		bm_row.add_child(bmb)

	# Free origins
	var orig_head := Label.new()
	orig_head.text = tr("Ordinary Origins (Free · 0 karma)")
	orig_head.theme_type_variation = &"RowLabel"
	box.add_child(orig_head)

	var origins: Array = Array(v.get("origins", []))
	if origins.is_empty():
		origins = [
			{"id": "tan_tu", "name": "Tán tu", "desc": "Loose cultivator — free, poor, no sect obligations."},
			{"id": "tong_mon", "name": "Đệ tử tông môn", "desc": "Outer disciple of a sect — stipend and missions."},
			{"id": "gia_toc", "name": "Con cháu gia tộc", "desc": "Minor clan heir — more stones and a growing herb field."},
		]
	for raw_o in origins:
		if not (raw_o is Dictionary):
			continue
		var o: Dictionary = raw_o
		var oid: String = str(o.get("id", ""))
		var oname: String = str(o.get("name", oid))
		var odesc: String = str(o.get("desc", ""))
		var is_sel: bool = _selected_kind == "rebirth_origin" and _selected_id == oid

		var ob := Button.new()
		ob.name = "Origin_" + oid
		ob.alignment = HORIZONTAL_ALIGNMENT_LEFT
		ob.theme_type_variation = &"CommitButton" if is_sel else &""
		ob.disabled = locked
		ob.text = "%s%s — %s  [Free]" % [("✓ " if is_sel else ""), oname, odesc]
		ob.accessibility_name = "%s, free origin. %s" % [oname, odesc]
		TooltipLayer.set_tip(ob, {"title": oname, "fact": tr("Free (0 karma)"), "summary": odesc})
		ob.pressed.connect(func(): select_rebirth_origin(oid))
		box.add_child(ob)

	# Lineage rebirth (sect / clan) with survival badge and karma cost
	var lin: Dictionary = Dictionary(v.get("lineage", {}))
	var lin_cost: int = int(lin.get("cost", 3))
	var lin_afford: bool = bool(lin.get("affordable", karma_total() >= lin_cost)) and karma_total() >= lin_cost

	var lhead := Label.new()
	lhead.text = tr("Lineage Rebirth (Huyết Mạch / Tông Môn) — %d karma") % lin_cost
	lhead.theme_type_variation = &"RowLabel"
	box.add_child(lhead)

	var lbox := VBoxContainer.new()
	lbox.name = "LineageBox"
	lbox.add_theme_constant_override("separation", 6)
	box.add_child(lbox)

	# Sect lineage row
	var sect_id: String = str(lin.get("sect_id", ""))
	var sect_name: String = str(lin.get("sect_name", ""))
	var sect_alive: bool = bool(lin.get("sect_alive", false)) and sect_id != ""
	var sect_ok: bool = sect_alive and lin_afford
	var sect_sel: bool = _selected_kind == "rebirth_lineage_sect"
	var sect_row := HBoxContainer.new()
	sect_row.name = "LineageSectRow"
	sect_row.add_theme_constant_override("separation", 8)
	lbox.add_child(sect_row)

	var sect_badge := Label.new()
	sect_badge.name = "LineageSectBadge"
	sect_badge.theme_type_variation = &"RowLabel"
	if sect_id == "":
		sect_badge.text = tr("[No Sect]")
		sect_badge.add_theme_color_override("font_color", Illustrated.BRASS_DIM)
	elif sect_alive:
		sect_badge.text = tr("[Sect Active · Tồn Tại]")
		sect_badge.add_theme_color_override("font_color", Color("#2E6B3E"))
	else:
		sect_badge.text = tr("[Sect Fallen · Đã Diệt]")
		sect_badge.add_theme_color_override("font_color", Illustrated.CINNABAR)
	sect_row.add_child(sect_badge)

	var sect_btn := Button.new()
	sect_btn.name = "LineageSect"
	sect_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sect_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	sect_btn.theme_type_variation = &"CommitButton" if sect_sel else &""
	sect_btn.disabled = locked or not sect_ok
	var sect_title: String = sect_name if sect_name != "" else tr("Dead life's sect")
	sect_btn.text = "%s%s (%d karma)" % [("✓ " if sect_sel else ""), tr("Outer disciple of %s") % sect_title, lin_cost]
	sect_btn.accessibility_name = "%s, %s, %d karma" % [sect_btn.text, sect_badge.text, lin_cost]
	TooltipLayer.set_tip(sect_btn, {
		"title": tr("Sect Lineage Rebirth"),
		"fact": "%s · %d karma" % [sect_badge.text, lin_cost],
		"summary": tr("Begin as an outer disciple of %s. If the sect falls during the %d-year rebirth gap, your %d karma is refunded and you start as a loose cultivator in that region.") % [sect_title, years, lin_cost],
	})
	sect_btn.pressed.connect(func(): select_rebirth_lineage("sect"))
	sect_row.add_child(sect_btn)

	# Clan lineage row
	var clan_avail: bool = bool(lin.get("clan_available", false))
	var clan_surname: String = str(lin.get("clan_surname", ""))
	var clan_ok: bool = clan_avail and lin_afford
	var clan_sel: bool = _selected_kind == "rebirth_lineage_clan"
	var clan_row := HBoxContainer.new()
	clan_row.name = "LineageClanRow"
	clan_row.add_theme_constant_override("separation", 8)
	lbox.add_child(clan_row)

	var clan_badge := Label.new()
	clan_badge.name = "LineageClanBadge"
	clan_badge.theme_type_variation = &"RowLabel"
	clan_badge.text = tr("[Clan Active · Tồn Tại]") if clan_avail else tr("[Clan Unavailable]")
	clan_badge.add_theme_color_override("font_color", Color("#2E6B3E") if clan_avail else Illustrated.CINNABAR)
	clan_row.add_child(clan_badge)

	var clan_btn := Button.new()
	clan_btn.name = "LineageClan"
	clan_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	clan_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	clan_btn.theme_type_variation = &"CommitButton" if clan_sel else &""
	clan_btn.disabled = locked or not clan_ok
	var clan_label: String = (tr("%s clan") % clan_surname) if clan_surname != "" else tr("Dead life's clan")
	clan_btn.text = "%s%s (%d karma)" % [("✓ " if clan_sel else ""), tr("Born into %s") % clan_label, lin_cost]
	clan_btn.accessibility_name = "%s, %s, %d karma" % [clan_btn.text, clan_badge.text, lin_cost]
	TooltipLayer.set_tip(clan_btn, {
		"title": tr("Clan Lineage Rebirth"),
		"fact": "%s · %d karma" % [clan_badge.text, lin_cost],
		"summary": tr("Begin in your predecessor's clan region. Refunded if the clan is gone when you enter."),
	})
	clan_btn.pressed.connect(func(): select_rebirth_lineage("clan"))
	clan_row.add_child(clan_btn)


func _build_perk_extra_section(parent: Control) -> void:
	var box: VBoxContainer = section_in(parent, "perks", tr("Destiny Perk Options (Thiên Mệnh)"))
	box.get_parent().name = "PerkExtraPanel"

	var bm: String = effective_birth_mode()
	var unheld: int = current_unheld_perks()
	var max_ex: int = max_perk_extra()
	var cur_ex: int = perk_extra()

	var info := Label.new()
	info.name = "PerkExtraInfo"
	info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if bm != "thien_dinh":
		info.text = tr("Self-made birth: choose any of the %d unheld destiny perks directly (extra perk options are not offered).") % unheld
	elif unheld <= 0:
		info.text = tr("This successor already holds all destiny perks.")
	elif unheld <= DEFAULT_BASE_PERKS:
		info.text = tr("All %d remaining unheld destiny perks will be offered (0 extra karma needed).") % unheld
	else:
		var shown_opts: int = mini(unheld, DEFAULT_BASE_PERKS + cur_ex)
		info.text = tr("Roll %d destiny perk options (3 base + %d extra at 1 karma each; %d unheld perks remaining, max extra: %d).") % [
			shown_opts, cur_ex, unheld, max_ex,
		]
	box.add_child(info)

	var ctrl_row := HBoxContainer.new()
	ctrl_row.add_theme_constant_override("separation", 8)
	box.add_child(ctrl_row)

	var minus := Button.new()
	minus.name = "PerkExtraMinus"
	minus.text = "−"
	minus.disabled = locked or cur_ex <= 0 or bm != "thien_dinh"
	minus.accessibility_name = tr("Decrease extra destiny perk options")
	TooltipLayer.set_tip(minus, tr("Remove 1 extra destiny perk option (refunds 1 karma)."))
	minus.pressed.connect(func(): set_perk_extra(cur_ex - 1))
	ctrl_row.add_child(minus)

	var val := Label.new()
	val.name = "PerkExtraValue"
	val.text = tr("Extra options: +%d / %d") % [cur_ex, max_ex]
	val.theme_type_variation = &"HeadingLabel"
	ctrl_row.add_child(val)

	var plus := Button.new()
	plus.name = "PerkExtraPlus"
	plus.text = "+"
	plus.disabled = locked or cur_ex >= max_ex or bm != "thien_dinh"
	plus.accessibility_name = tr("Increase extra destiny perk options")
	TooltipLayer.set_tip(plus, tr("Spend 1 karma for +1 extra destiny perk option (up to %d).") % max_ex)
	plus.pressed.connect(func(): set_perk_extra(cur_ex + 1))
	ctrl_row.add_child(plus)


func _build_action_bar() -> void:
	var confirm := Button.new()
	confirm.name = "ConfirmSuccession"
	confirm.theme_type_variation = &"CommitButton"
	confirm.disabled = locked or _selected_kind == ""
	if _selected_kind == "heir":
		var h: Dictionary = _find_heir(_selected_id)
		confirm.text = tr("Continue as %s (%d karma)") % [str(h.get("name", _selected_id)), total_cost()]
	elif _selected_kind == "rebirth_origin":
		confirm.text = tr("Begin Rebirth (%d karma)") % total_cost()
	elif _selected_kind == "rebirth_lineage_sect":
		confirm.text = tr("Rebirth into Sect (%d karma)") % total_cost()
	elif _selected_kind == "rebirth_lineage_clan":
		confirm.text = tr("Rebirth into Clan (%d karma)") % total_cost()
	else:
		confirm.text = tr("Select an heir or rebirth option")
	confirm.accessibility_name = confirm.text
	TooltipLayer.set_tip(confirm, {
		"title": confirm.text,
		"summary": tr("Spend %d karma (%d remaining) and begin the next life.") % [total_cost(), maxi(0, karma_total() - total_cost())],
	})
	confirm.pressed.connect(func(): confirm_selection())
	bar.add_child(confirm)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.add_child(spacer)

	if _armed_end:
		var ask := Button.new()
		ask.name = "ConfirmEndPlaythrough"
		ask.text = tr("Confirm: End this playthrough")
		ask.disabled = locked
		ask.accessibility_name = tr("Confirm ending this playthrough permanently")
		TooltipLayer.set_tip(ask, tr("Marks this Continue playthrough Ended. Your Codex entries remain on your profile."))
		ask.pressed.connect(func():
			_armed_end = false
			end_playthrough_chosen.emit()
			action_requested.emit("end_playthrough", [])
		)
		bar.add_child(ask)

		var cancel := Button.new()
		cancel.name = "CancelEndPlaythrough"
		cancel.text = tr("Cancel")
		cancel.accessibility_name = tr("Cancel ending this playthrough")
		cancel.pressed.connect(func():
			_armed_end = false
			_rebuild()
		)
		bar.add_child(cancel)
	else:
		var end_btn := Button.new()
		end_btn.name = "EndPlaythrough"
		end_btn.text = tr("End this playthrough")
		end_btn.disabled = locked
		end_btn.accessibility_name = tr("End this playthrough")
		TooltipLayer.set_tip(end_btn, tr("Close this Continue playthrough instead of choosing a successor. Your Codex and achievements remain."))
		end_btn.pressed.connect(func():
			_armed_end = true
			_rebuild()
		)
		bar.add_child(end_btn)


func _find_heir(heir_id: String) -> Dictionary:
	for raw in Array(view.get("heirs", [])):
		if raw is Dictionary and str(raw.get("id", "")) == heir_id:
			return raw
	return {}


func _is_heir_affordable(h: Dictionary) -> bool:
	var cost: int = maxi(0, int(h.get("cost", 0)))
	if bool(h.get("greyed", false)):
		return false
	return bool(h.get("affordable", cost <= karma_total())) and cost <= karma_total()


func _has_origin(origin_id: String) -> bool:
	var origins: Array = Array(view.get("origins", []))
	if origins.is_empty():
		return origin_id in ["tan_tu", "tong_mon", "gia_toc"]
	for o in origins:
		if o is Dictionary and str(o.get("id", "")) == origin_id:
			return true
	return false


static func _format_notable_ties(ties: Array) -> String:
	var parts: PackedStringArray = PackedStringArray()
	for raw in ties:
		if raw is Dictionary:
			var nm: String = str(raw.get("name", raw.get("id", "")))
			var kinds: PackedStringArray = PackedStringArray()
			for k in Array(raw.get("kinds", [])):
				kinds.append(str(k))
			parts.append("%s (%s)" % [nm, ", ".join(kinds)] if not kinds.is_empty() else nm)
		elif str(raw) != "":
			parts.append(str(raw))
	return ", ".join(parts)
