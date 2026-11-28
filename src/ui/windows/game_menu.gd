class_name GameMenu
extends PanelContainer
## The game menu (design/ux/game-menu.md): a modal centre window with four pages, Menu, Save, Load and Settings, the
## world seed and date in its footer and a status line. It does no work itself: saving, loading, quitting and the wiki
## are requested by signals (the map screen runs the jobs); settings are written to the [PlayerSettings] it is given.

## Save the game under [param name].
signal save_requested(name: String, overwrite_slot: String)
## Load save [param slot].
signal load_requested(slot: String)
## Quit the game; [param save_first] saves to the quick slot first.
signal quit_requested(save_first: bool)
## Open the wiki.
signal wiki_requested
## Start a new game with [param spec] ({playthrough_mode, birth_mode, tribulation_enabled, origin, name, seed}).
signal new_game_requested(spec: Dictionary)
## The menu closed.
signal closed

const PAGES := ["menu", "new_game", "save", "load", "settings"]
const NEW_GAME_ORIGINS := [
	{"id": "tan_tu", "name": "Tán tu", "desc": "Nobody. Free, poor, no sect obligations."},
	{"id": "tong_mon", "name": "Đệ tử tông môn", "desc": "Outer disciple of a sect: stipend and missions."},
	{"id": "gia_toc", "name": "Con cháu gia tộc", "desc": "Minor clan heir: more linh thạch and a growing herb field."},
]

## The settings store the Settings page edits (set before opening).
var settings: PlayerSettings = null
## The save rows: [{slot, name, date, realm, time, ok, reason}], newest first (set by the map screen).
var saves: Array = []
## The default name for a new save.
var default_name: String = ""
## The footer: "World seed 7 · Xuân, year 1200".
var footer_text: String = ""
## The world seed, for Copy seed (world-generation.md: the seed is shown and can be shared).
var seed_text: String = ""

var _page: String = "menu"
var _title := Label.new()
var _body := VBoxContainer.new()
var _scroll := ScrollContainer.new()
var _footer := Label.new()
var _status := Label.new()
var _opener: Control = null
var _busy: bool = false
var _armed: String = ""          # "quit", or "overwrite:<slot>": the confirm-in-place row shown
var _name_field: LineEdit = null
var _settings_only: bool = false  # in a fight or tribulation Esc opens settings only (hud.md Esc rules)
var _copy := Button.new()
var _box: Control = null          # the page's parchment inset (rebuilt with the page)
var _new_mode: String = KarmicRules.MODE_ONE_LIFE
var _new_birth_mode: String = "thien_dinh"
var _new_tribulation: bool = true
var _new_origin: String = "tan_tu"
var _new_name: String = "Lâm Phong"
var _new_seed: String = ""
static var _cfg_cache: Dictionary = {}


# ui_windows.json "menu" (banner: the painting over the main page), read once.
static func _menu_cfg() -> Dictionary:
	if _cfg_cache.is_empty():
		var d: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://assets/data/ui_windows.json"))
		_cfg_cache = (d as Dictionary).get("menu", {"banner": ""}) if d is Dictionary else {"banner": ""}
	return _cfg_cache


func _init() -> void:
	visible = false
	custom_minimum_size = Vector2(520, 0)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	add_child(box)
	var frame := HBoxContainer.new()
	_title.theme_type_variation = &"HeadingLabel"
	_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	frame.add_child(_title)
	var close := Button.new()
	close.text = "×"
	close.accessibility_name = tr("Close the game menu")
	TooltipLayer.set_tip(close, tr("Resume (Esc)"))
	close.pressed.connect(close_menu)
	frame.add_child(close)
	box.add_child(frame)
	box.add_child(HSeparator.new())
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll.custom_minimum_size = Vector2(0, 520)   # room for the banner and every button without scrolling (fit_height trims it on short screens)
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(_scroll)
	_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_body.add_theme_constant_override("separation", 6)
	_scroll.add_child(_body)
	box.add_child(HSeparator.new())
	var foot := HBoxContainer.new()
	_footer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_footer.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	foot.add_child(_footer)
	_copy.text = tr("Copy seed")
	_copy.accessibility_name = tr("Copy the world seed")
	_copy.pressed.connect(_copy_seed)
	foot.add_child(_copy)
	box.add_child(foot)
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_status.accessibility_live = AccessibilityServer.LIVE_POLITE
	box.add_child(_status)


## Keeps the menu inside a short layout area (1280x720: the menu touched the screen edges, round-2 review): the
## scroll area is at most the layout height minus the frame, title and footer.
func fit_height(layout_h: float) -> void:
	_scroll.custom_minimum_size.y = clampf(layout_h - 260.0, 280.0, 520.0)


## Opens the menu at [param page]; [param opener] gets focus back on close. [param settings_only]: the fight and
## tribulation variant (only the Settings page; no save, load or quit; Esc closes).
func open_menu(page: String = "menu", opener: Control = null, settings_only: bool = false) -> void:
	_opener = opener
	_status.text = ""
	_armed = ""
	_settings_only = settings_only
	visible = true
	if is_inside_tree():
		fit_height(get_viewport_rect().size.y)
	show_page("settings" if settings_only else page)


## Shows [param page] ("menu", "save", "load", "settings").
func show_page(page: String) -> void:
	_page = page if PAGES.has(page) else "menu"
	_armed = "" if page != _page else _armed
	_build()


## The page shown ("" when closed).
func page() -> String:
	return _page if visible else ""


## Esc (game-menu.md Interaction Map): disarm a confirm, then back to Menu from a page, then close.
func back_or_close() -> void:
	if _busy:
		show_status(tr("Please wait: the game is still saving or loading."))
		return
	if _armed != "":
		_armed = ""
		_build()
	elif _page != "menu" and not _settings_only:
		show_page("menu")
	else:
		close_menu()


func close_menu() -> void:
	if not visible or _busy:
		return
	visible = false
	if _opener != null and is_instance_valid(_opener) and _opener.is_inside_tree():
		_opener.grab_focus()
	closed.emit()


## Marks a save or load as running ([param on]) with [param text] in the status line.
func set_busy(on: bool, text: String = "") -> void:
	_busy = on
	_status.text = text
	_build()


## Shows [param text] in the status line (announced politely).
func show_status(text: String) -> void:
	_status.text = text


## The status line's text.
func status_text() -> String:
	return _status.text


## Currently selected playthrough mode on the New Game page ("one_life" or "continue").
func selected_playthrough_mode() -> String:
	return _new_mode


## Sets the playthrough mode on the New Game page ("one_life" or "continue") and refreshes if open.
func set_playthrough_mode(mode: String) -> void:
	_new_mode = KarmicRules.normalize_mode(mode)
	if visible and _page == "new_game":
		_build()


## Currently selected Heavenly Tribulation toggle on the New Game page (default true).
func selected_tribulation_enabled() -> bool:
	return _new_tribulation


## Sets the Heavenly Tribulation toggle on the New Game page and refreshes if open.
func set_tribulation_enabled(on: bool) -> void:
	_new_tribulation = on
	if visible and _page == "new_game":
		_build()


## Formats the playthrough mode and lifecycle badge for a save row (empty string when absent on legacy rows).
static func mode_badge(s: Dictionary) -> String:
	var mode: String = str(s.get("playthrough_mode", s.get("mode", "")))
	if mode == "":
		return ""
	var status: String = str(s.get("playthrough_status", s.get("status", "")))
	var label: String = "Continue · Luân Hồi" if mode == KarmicRules.MODE_CONTINUE else "One Life · Nhất Sinh"
	if status == KarmicRules.STATUS_ENDED:
		return "[%s · Ended]" % label
	if status == KarmicRules.STATUS_SUCCESSION:
		return "[%s · Succession]" % label
	return "[%s]" % label


func _build() -> void:
	for c in _body.get_children():
		_body.remove_child(c)
		c.queue_free()
	# the illustrated windows (user 2026-11-24): a painted banner over the main page, each page on parchment
	var g: VBoxContainer = Illustrated.ground(_body)
	if _page == "menu" and not _settings_only:
		var art: Texture2D = Illustrated.tex(str(_menu_cfg().get("banner", "")))
		var hero: PanelContainer = Illustrated.framed(art, Vector2(0, 150), "")
		hero.name = "Banner"
		g.add_child(hero)
	_box = Illustrated.inset(g, "")
	_name_field = null
	_footer.text = footer_text
	match _page:
		"menu":
			_title.text = tr("Game menu")
			_build_menu()
			if not _settings_only:
				var ng_box: VBoxContainer = Illustrated.inset(g, "")
				ng_box.get_parent().name = "NewGameBox"
				var ng_btn := _button(tr("New game"), ng_box, show_page.bind("new_game"))
				ng_btn.name = "NewGame"
				TooltipLayer.set_tip(ng_btn, {
					"title": tr("New game"),
					"summary": tr("Start a fresh playthrough in One Life (Nhất Sinh) or Continue (Luân Hồi Kế Thừa) mode."),
				})
		"new_game":
			_title.text = tr("New game")
			_build_new_game()
		"save":
			_title.text = tr("Save game")
			_build_save()
		"load":
			_title.text = tr("Load game")
			_build_load()
		"settings":
			_title.text = tr("Settings")
			_build_settings()
	accessibility_name = _title.text
	var first: Control = _first_focusable(_body)
	if first != null:
		_focus_now.bind(first).call_deferred()


func _focus_now(c: Control) -> void:
	if is_instance_valid(c) and c.is_inside_tree() and c.is_visible_in_tree():
		c.grab_focus()


func _first_focusable(n: Node) -> Control:
	for c in n.get_children():
		if c is Control and (c as Control).focus_mode != Control.FOCUS_NONE and c.visible and not (c is BaseButton and (c as BaseButton).disabled):
			if c is Button or c is LineEdit or c is Range:
				return c
		var deep: Control = _first_focusable(c)
		if deep != null:
			return deep
	return null


func _button(text: String, parent: Control, on: Callable, hint: String = "") -> Button:
	var b := Button.new()
	b.text = text + (("    " + hint) if hint != "" else "")
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.disabled = _busy
	b.accessibility_name = text
	b.pressed.connect(on)
	parent.add_child(b)
	return b


func _build_menu() -> void:
	_button(tr("Resume"), _box, close_menu, "Esc").name = "Resume"
	_button(tr("Save game"), _box, show_page.bind("save"), "Ctrl+S").name = "Save"
	_button(tr("Load game"), _box, show_page.bind("load"), "Ctrl+L").name = "Load"
	_button(tr("Settings"), _box, show_page.bind("settings")).name = "Settings"
	_button(tr("Wiki"), _box, func(): wiki_requested.emit(), "F1").name = "Wiki"
	if _armed == "quit":
		var ask := Label.new()
		ask.text = tr("Quit? Progress since your last save is lost.")
		ask.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_box.add_child(ask)
		var row := HBoxContainer.new()
		_box.add_child(row)
		_button(tr("Save and quit"), row, func(): quit_requested.emit(true)).name = "SaveAndQuit"
		_button(tr("Quit"), row, func(): quit_requested.emit(false)).name = "QuitNow"
		var cancel := _button(tr("Cancel"), row, _disarm)
		cancel.name = "CancelQuit"
		_focus_now.bind(cancel).call_deferred()
	else:
		_button(tr("Quit to desktop"), _box, _arm.bind("quit")).name = "Quit"


func _build_new_game() -> void:
	var mode_head := Label.new()
	mode_head.text = tr("Playthrough mode (fixed for the entire playthrough)")
	mode_head.theme_type_variation = &"RowLabel"
	_box.add_child(mode_head)

	var modes := [
		{
			"id": KarmicRules.MODE_ONE_LIFE,
			"label": tr("One Life (Nhất Sinh)"),
			"desc": tr("First death ends the playthrough. Eligible for One Life prestige achievements."),
		},
		{
			"id": KarmicRules.MODE_CONTINUE,
			"label": tr("Continue (Luân Hồi Kế Thừa)"),
			"desc": tr("On death, continue in the same world as an heir or reborn successor using Karma."),
		},
	]
	for md in modes:
		var mid: String = str(md.id)
		var sel: bool = _new_mode == mid
		var mb := _button(("%s%s — %s" % [("✓ " if sel else ""), str(md.label), str(md.desc)]), _box, func():
			_new_mode = mid
			_build()
		)
		mb.name = "Mode_" + mid
		mb.theme_type_variation = &"CommitButton" if sel else &""
		mb.accessibility_name = "%s: %s" % [str(md.label), str(md.desc)]
		TooltipLayer.set_tip(mb, {"title": str(md.label), "summary": str(md.desc)})

	var bm_head := Label.new()
	bm_head.text = tr("Birth mode")
	bm_head.theme_type_variation = &"RowLabel"
	_box.add_child(bm_head)
	var bm_row := HBoxContainer.new()
	bm_row.add_theme_constant_override("separation", 6)
	_box.add_child(bm_row)
	for bm_pair in [["thien_dinh", tr("Fated (Thiên Định)")], ["tu_dinh", tr("Self-made (Tự Định)")]]:
		var bmid: String = str(bm_pair[0])
		var bsel: bool = _new_birth_mode == bmid
		var bmb := _button(("%s%s" % [("✓ " if bsel else ""), str(bm_pair[1])]), bm_row, func():
			_new_birth_mode = bmid
			_build()
		)
		bmb.name = "NewBirth_" + bmid
		bmb.theme_type_variation = &"CommitButton" if bsel else &""
		TooltipLayer.set_tip(bmb, {
			"title": str(bm_pair[1]),
			"summary": tr("Writes to the Codex and earns Karma and achievements.") if bmid == "thien_dinh" else tr("Custom build; reads the Codex but writes only Lives and earns 0 Karma."),
		})

	var tk_head := Label.new()
	tk_head.text = tr("Heavenly Tribulation (Thiên Kiếp)")
	tk_head.theme_type_variation = &"RowLabel"
	_box.add_child(tk_head)
	var tk_row := HBoxContainer.new()
	tk_row.add_theme_constant_override("separation", 6)
	_box.add_child(tk_row)
	for tk_pair in [
		[true, "on", tr("On — 3-wave Hóa Thần gauntlet"), tr("Default: crossing from Nguyên Anh to Hóa Thần triggers the 3-wave Heavenly Tribulation gauntlet. Fixed for the playthrough.")],
		[false, "off", tr("Off — Classic breakthrough roll"), tr("Disables Heavenly Tribulation for this playthrough: breakthroughs resolve via the classic Realms roll only.")],
	]:
		var tk_val: bool = bool(tk_pair[0])
		var tk_key: String = str(tk_pair[1])
		var tk_sel: bool = _new_tribulation == tk_val
		var tkb := _button(("%s%s" % [("✓ " if tk_sel else ""), str(tk_pair[2])]), tk_row, func():
			_new_tribulation = tk_val
			_build()
		)
		tkb.name = "NewTribulation_" + tk_key
		tkb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tkb.theme_type_variation = &"CommitButton" if tk_sel else &""
		TooltipLayer.set_tip(tkb, {
			"title": tr("Heavenly Tribulation: %s") % (tr("On") if tk_val else tr("Off")),
			"summary": str(tk_pair[3]),
		})

	var orig_head := Label.new()
	orig_head.text = tr("Origin")
	orig_head.theme_type_variation = &"RowLabel"
	_box.add_child(orig_head)
	for o in NEW_GAME_ORIGINS:
		var oid: String = str(o.id)
		var osel: bool = _new_origin == oid
		var ob := _button(("%s%s — %s" % [("✓ " if osel else ""), str(o.name), tr(str(o.desc))]), _box, func():
			_new_origin = oid
			_build()
		)
		ob.name = "NewOrigin_" + oid
		ob.theme_type_variation = &"CommitButton" if osel else &""
		TooltipLayer.set_tip(ob, {"title": str(o.name), "summary": tr(str(o.desc))})

	var meta_row := HBoxContainer.new()
	meta_row.add_theme_constant_override("separation", 6)
	_box.add_child(meta_row)
	var nm := LineEdit.new()
	nm.name = "NewName"
	nm.text = _new_name
	nm.placeholder_text = tr("Character name")
	nm.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	nm.accessibility_name = tr("Character name")
	nm.editable = not _busy
	nm.text_changed.connect(func(t: String): _new_name = t)
	meta_row.add_child(nm)

	var sd := LineEdit.new()
	sd.name = "NewSeed"
	sd.text = _new_seed
	sd.placeholder_text = tr("World seed (optional)")
	sd.custom_minimum_size = Vector2(150, 0)
	sd.accessibility_name = tr("World seed")
	sd.editable = not _busy
	sd.text_changed.connect(func(t: String): _new_seed = t)
	meta_row.add_child(sd)

	var act_row := HBoxContainer.new()
	act_row.add_theme_constant_override("separation", 8)
	_box.add_child(act_row)
	var start_b := _button(tr("Start new game"), act_row, _emit_new_game)
	start_b.name = "StartNewGame"
	start_b.theme_type_variation = &"CommitButton"
	TooltipLayer.set_tip(start_b, {
		"title": tr("Start new game"),
		"summary": tr("Begin a new playthrough in %s mode.") % (tr("Continue") if _new_mode == KarmicRules.MODE_CONTINUE else tr("One Life")),
	})
	_button(tr("Back"), act_row, show_page.bind("menu")).name = "BackNewGame"


func _emit_new_game() -> void:
	if _busy:
		return
	var clean_name: String = _new_name.strip_edges()
	var seed_txt: String = _new_seed.strip_edges()
	var spec := {
		"playthrough_mode": _new_mode,
		"birth_mode": _new_birth_mode,
		"tribulation_enabled": _new_tribulation,
		"mode": "custom" if _new_birth_mode == "tu_dinh" else "roll",
		"origin": _new_origin,
		"name": clean_name if clean_name != "" else "Lâm Phong",
	}
	if seed_txt.is_valid_int():
		spec["seed"] = int(seed_txt)
	new_game_requested.emit(spec)


func _build_save() -> void:
	var row := HBoxContainer.new()
	_box.add_child(row)
	_name_field = LineEdit.new()
	_name_field.name = "SaveName"
	_name_field.text = default_name
	_name_field.max_length = 48
	_name_field.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_name_field.accessibility_name = tr("Save name")
	_name_field.editable = not _busy
	_name_field.text_submitted.connect(func(t: String): _save_as(t, ""))
	row.add_child(_name_field)
	_button(tr("Save"), row, func(): _save_as(_name_field.text, "")).name = "SaveNew"
	if saves.is_empty():
		_line(tr("No saves yet."))
	for s in saves:
		var r := HBoxContainer.new()
		_box.add_child(r)
		var slot: String = str(s.slot)
		var col := VBoxContainer.new()
		col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		col.add_theme_constant_override("separation", 2)
		r.add_child(col)
		var l := Label.new()
		l.text = _row_text(s)
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		col.add_child(l)
		_add_mode_badge(col, s, slot)
		if _armed == "overwrite:" + slot:
			_button(tr("Overwrite?"), r, func(): _save_as(str(s.get("name", slot)), slot)).name = "ConfirmOverwrite"
			_button(tr("Cancel"), r, _disarm)
		else:
			_button(tr("Overwrite"), r, _arm.bind("overwrite:" + slot))
	_button(tr("Back"), _box, show_page.bind("menu"))


func _save_as(name: String, slot: String) -> void:
	if _busy or name.strip_edges() == "":
		return
	var target: String = slot if slot != "" else slot_name(name)
	if slot == "" and saves.any(func(x): return str(x.slot) == target):
		# a new name whose file-safe slot already exists goes through the overwrite confirm (game-menu.md)
		_armed = "overwrite:" + target
		_build()
		show_status(tr("A save file \"%s\" already exists: overwrite it?") % target)
		return
	_armed = ""
	save_requested.emit(name.strip_edges(), target)


## The file-safe slot for a save name: ASCII letters and digits kept (lower case), every other run of characters one
## "_"; "save" when nothing is left. Two names can share a slot, so a new save checks for it first.
static func slot_name(name: String) -> String:
	var out: String = ""
	var gap: bool = false
	for ch in name.strip_edges().to_lower():
		var code: int = ch.unicode_at(0)
		if (code >= 97 and code <= 122) or (code >= 48 and code <= 57):
			out += ch
			gap = false
		elif not gap and out != "":
			out += "_"
			gap = true
	out = out.trim_suffix("_")
	return out if out != "" else "save"


func _build_load() -> void:
	if saves.is_empty():
		_line(tr("No saves yet."))
	for s in saves:
		var r := HBoxContainer.new()
		_box.add_child(r)
		var slot: String = str(s.slot)
		var col := VBoxContainer.new()
		col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		col.add_theme_constant_override("separation", 2)
		r.add_child(col)
		var l := Label.new()
		l.text = _row_text(s) + ("" if bool(s.get("ok", true)) else "\n" + str(s.get("reason", "")))
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		col.add_child(l)
		_add_mode_badge(col, s, slot)
		l.focus_mode = Control.FOCUS_ALL   # a greyed row stays reachable, its reason in its name
		l.accessibility_name = l.text.replace("\n", ", ")
		if _armed == "load:" + slot:
			var ask := _button(tr("Load? Unsaved progress is lost."), r, func(): load_requested.emit(slot))
			ask.name = "ConfirmLoad"
			_button(tr("Cancel"), r, _disarm).name = "CancelLoad"
		else:
			var b := _button(tr("Load"), r, _arm.bind("load:" + slot))
			b.name = "Load_" + slot
			b.disabled = _busy or not bool(s.get("ok", true))
			b.accessibility_name = tr("Load %s") % str(s.get("name", slot))
	_button(tr("Back"), _box, show_page.bind("menu"))


func _add_mode_badge(parent: Control, s: Dictionary, slot: String) -> void:
	var badge: String = mode_badge(s)
	if badge == "":
		return
	var mode: String = str(s.get("playthrough_mode", s.get("mode", "")))
	var b := Label.new()
	b.name = "ModeBadge_" + slot
	b.text = badge
	b.theme_type_variation = &"RowLabel"
	b.add_theme_color_override("font_color", Illustrated.GILT if mode == KarmicRules.MODE_CONTINUE else Illustrated.CINNABAR)
	TooltipLayer.set_tip(b, {
		"title": badge,
		"summary": tr("Continue mode: death opens succession in the same world.") if mode == KarmicRules.MODE_CONTINUE else tr("One Life mode: first death ends the playthrough."),
	})
	parent.add_child(b)


func _row_text(s: Dictionary) -> String:
	var badge: String = mode_badge(s)
	var head: String = str(s.get("name", s.get("slot", "")))
	if badge != "":
		head += "  " + badge
	return "%s\n%s · %s · %s" % [head, str(s.get("date", "")), str(s.get("realm", "")), str(s.get("time", ""))]


func _build_settings() -> void:
	if settings == null:
		_line(tr("Settings are not available."))
		return
	var labels := {"ui_scale": tr("UI scale"), "reduced_motion": tr("Reduced motion"), "colourblind": tr("Colourblind mode"),
		"tooltip_delay": tr("Tooltip delay"), "tooltip_lock_delay": tr("Tooltip lock delay"), "tooltip_close_grace": tr("Tooltip close grace"),
		"lock_timer": tr("Tooltips lock after the delay"), "lock_middle": tr("Tooltips lock on a middle click"),
		"lock_click": tr("Tooltips lock on a click"), "letter_hotkeys": tr("Single-letter window hotkeys (Q and V stay on)"),
		"borders": tr("Region and province borders on the map"), "outliner_open": tr("Outliner shown")}
	var words := {"off": tr("off"), "red_green": tr("red-green")}
	for key in settings.keys():
		var d: Dictionary = settings.def(key)
		var v: Variant = settings.value(key)
		var r := HBoxContainer.new()
		r.name = "Setting_" + key
		_box.add_child(r)
		var l := Label.new()
		l.text = str(labels.get(key, key))
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.custom_minimum_size = Vector2(220, 0)
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		r.add_child(l)
		if v is bool:
			var t := CheckButton.new()
			t.button_pressed = bool(v)
			t.text = tr("on") if bool(v) else tr("off")
			t.accessibility_name = "%s, %s" % [l.text, t.text]
			t.toggled.connect(_on_toggle.bind(key, t, l.text))
			r.add_child(t)
		elif d.has("options"):
			var o := OptionButton.new()
			var opts: Array = Array(d.options)
			for i in opts.size():
				var shown: String = (str(int(opts[i])) + " %") if (opts[i] is float or opts[i] is int) else str(words.get(str(opts[i]), opts[i]))
				o.add_item(shown, i)
				if (opts[i] is float or opts[i] is int) and (v is float or v is int) and is_equal_approx(float(opts[i]), float(v)) or str(opts[i]) == str(v):
					o.select(i)
			o.accessibility_name = l.text
			o.item_selected.connect(func(i: int): settings.set_value(key, opts[i]))
			r.add_child(o)
		else:
			var s := HSlider.new()
			s.min_value = float(d.get("min", 0.0))
			s.max_value = float(d.get("max", 1.0))
			s.step = 0.05
			s.value = float(v)
			s.custom_minimum_size = Vector2(160, 0)
			var n := Label.new()
			n.text = "%.2f s" % float(v)
			s.accessibility_name = "%s, %s" % [l.text, n.text]
			s.value_changed.connect(_on_slider.bind(key, s, n, l.text))
			r.add_child(s)
			r.add_child(n)
	_line(tr("Coming with the settings pass: key bindings, brightness, End turn input, toast duration and alerts by kind."))
	if not _settings_only:
		_button(tr("Back"), _box, show_page.bind("menu"))


func _line(text: String) -> void:
	var l := Label.new()
	l.text = text
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_box.add_child(l)


func _unhandled_input(event: InputEvent) -> void:
	if visible and event is InputEventKey and event.is_pressed() and (event as InputEventKey).physical_keycode == KEY_ESCAPE:
		back_or_close()
		get_viewport().set_input_as_handled()


func _arm(what: String) -> void:
	_armed = what
	_build()


func _disarm() -> void:
	_armed = ""
	_build()


func _on_toggle(on: bool, key: String, t: CheckButton, label: String) -> void:
	settings.set_value(key, on)
	t.text = tr("on") if on else tr("off")
	t.accessibility_name = "%s, %s" % [label, t.text]


func _on_slider(x: float, key: String, sl: HSlider, n: Label, label: String) -> void:
	var stored: Variant = settings.set_value(key, x)
	n.text = "%.2f s" % float(stored)
	sl.accessibility_name = "%s, %s" % [label, n.text]


func _copy_seed() -> void:
	DisplayServer.clipboard_set(seed_text)
	show_status(tr("Seed copied: %s") % seed_text)
