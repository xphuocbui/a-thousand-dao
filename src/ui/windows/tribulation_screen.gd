class_name TribulationScreen
extends GameWindow
## Full-screen Heavenly Tribulation (Thiên Kiếp) flow UI (design/gdd/thien-kiep.md, AC-TK-80..83).
##
## Strictly read-only (ADR-0006): reads only the view Dictionary snapshot passed to [method show_view]
## (from [method GameQuery.tribulation_preview] or [method GameQuery.tribulation_result]) and never
## accesses or mutates [GameSession]. Emits clean signals for actions, replay handoff, and navigation.
## Every tooltip uses [TooltipLayer.set_tip] (ADR-0005, zero built-in tooltip_text).
##
## Two modes (auto-detected from [member view]):
## - **Confirmation mode** ([code]mode == "confirm"[/code] or a preview snapshot with [code]pool[/code]
##   and no [code]waves[/code]): shows breakthrough odds, high-stakes warning, [code]wave_count[/code],
##   full boss pool profiles & draw weights, player setup summary, and escape-art warning when slotted.
##   Never reveals any pre-rolled draw (AC-TK-80, AC-TK-81).
## - **Wave progression & result mode** ([code]mode == "result"[/code] or a result snapshot with
##   [code]waves[/code]): displays ordered wave headers ([code]Wave k / N — <Boss> | Start HP X% · Qi Y%[/code];
##   AC-TK-82), fight summary (ending, duration, HP/Qi left, deciding layer), [code]Watch Fight[/code]
##   handoff signal for [FightScreen], and survival buff ([code]tribulation_tempered[/code] 60 W) plus
##   selectable reward choice cards, or a failure summary naming the fatal wave and boss (AC-TK-83).

## Player pressed "Watch Fight" on wave [param wave_index] (0-based); [param fight_data] carries the
## wave's replay payload for [FightScreen].
signal watch_fight_requested(wave_index: int, fight_data: Dictionary)
## Player backed out of the attempt confirmation view.
signal confirm_cancelled
## Player pressed Continue on the final result view ([param survived] is true on survival, false on death).
signal continue_requested(survived: bool)

const MODE_CONFIRM := "confirm"
const MODE_RESULT := "result"

const THREAT_LABELS := {
	"body": "Body (Physical)",
	"qi": "Qi (Elemental)",
	"soul": "Soul",
}

const DECIDING_LAYER_LABELS := {
	0: "Body (Physical)",
	1: "Qi (Elemental)",
	2: "Soul",
	3: "Fatigue",
	-1: "None / Draw",
}

const ENDING_LABELS := {
	"knockout": "Knockout",
	"draw": "Draw",
	"flight": "Flight",
	"time": "Time / Fatigue",
	"error": "Error",
}

## When true, waves reveal one at a time with Next Wave / View Final Result controls.
## Defaults to false (all waves and the outcome render immediately) unless [code]view.step_mode[/code] is true.
var step_mode: bool = false

var _last_tk_id: int = -1
var _revealed_count: int = 0
var _final_shown: bool = true
var _primary_focus: Control = null


func kind() -> String:
	return "tribulation"


func column_width() -> int:
	return 900 if compact else 1360


func window_title(v: Dictionary) -> String:
	if _detect_mode(v) == MODE_CONFIRM:
		return tr("Heavenly Tribulation (Thiên Kiếp) — Attempt Confirmation")
	if bool(v.get("survived", false)):
		return tr("Heavenly Tribulation (Thiên Kiếp) — Survived")
	if v.has("waves"):
		return tr("Heavenly Tribulation (Thiên Kiếp) — Result")
	return tr("Heavenly Tribulation (Thiên Kiếp)")


func first_focus() -> Control:
	if _primary_focus != null and is_instance_valid(_primary_focus):
		return _primary_focus
	var base: Control = super.first_focus()
	if base != null:
		return base
	return self


## Returns the active mode ("confirm" or "result") for the current [member view].
func active_mode() -> String:
	return _detect_mode(view)


## Number of waves currently revealed in result mode (for tests and step-by-step pacing).
func revealed_count() -> int:
	return _revealed_count


## True when the final outcome block (survival buff + rewards, or failure summary) is visible.
func showing_final() -> bool:
	return _final_shown


## Reveals the next wave in step-by-step mode, or reveals the final outcome once all waves are visible.
func reveal_next_wave() -> void:
	var waves: Array = Array(view.get("waves", []))
	if _revealed_count < waves.size():
		_revealed_count += 1
	else:
		_final_shown = true
	var y: int = scroll.scroll_vertical
	super.show_view(view, "", locked)
	scroll.set_deferred("scroll_vertical", y)


## Reveals every wave and the final outcome immediately.
func reveal_all_waves() -> void:
	var waves: Array = Array(view.get("waves", []))
	_revealed_count = waves.size()
	_final_shown = true
	var y: int = scroll.scroll_vertical
	super.show_view(view, "", locked)
	scroll.set_deferred("scroll_vertical", y)


func show_view(v: Dictionary, section: String, is_locked: bool) -> void:
	var mode: String = _detect_mode(v)
	if mode == MODE_RESULT:
		var tk_id: int = int(v.get("tribulation_id", -1))
		var waves: Array = Array(v.get("waves", []))
		var use_step: bool = step_mode or bool(v.get("step_mode", false))
		var is_new_run: bool = (tk_id != _last_tk_id) or (tk_id == -1 and _revealed_count == 0)
		if is_new_run:
			_last_tk_id = tk_id
			if use_step and not waves.is_empty():
				_revealed_count = 1
				_final_shown = false
			else:
				_revealed_count = waves.size()
				_final_shown = true
		elif not use_step:
			_revealed_count = waves.size()
			_final_shown = true
	else:
		_last_tk_id = -1
		_revealed_count = 0
		_final_shown = true
	super.show_view(v, section, is_locked)


## Formats a share (0..1) cleanly: whole percentages as "100%", fractional as "43.8%".
static func format_pct(share: float) -> String:
	var pct: float = clampf(share, 0.0, 1.0) * 100.0
	if absf(pct - roundf(pct)) < 0.05:
		return "%d%%" % int(roundf(pct))
	return "%.1f%%" % pct


## Canonical wave header (AC-TK-82): "Wave k / N — <Boss> | Start HP X% · Qi Y%".
static func format_wave_header(w: Dictionary, wave_count: int) -> String:
	var k: int = int(w.get("wave", 1))
	var n: int = maxi(wave_count, k)
	var bname: String = str(w.get("boss_name", w.get("boss_id", "?")))
	var hp_s: String = format_pct(float(w.get("start_h", 1.0)))
	var qi_s: String = format_pct(float(w.get("start_q", 1.0)))
	return "Wave %d / %d — %s | Start HP %s · Qi %s" % [k, n, bname, hp_s, qi_s]


## Human-readable deciding layer name for [member FightResult.deciding_layer].
static func deciding_layer_label(layer: int) -> String:
	return str(DECIDING_LAYER_LABELS.get(layer, "Layer %d" % layer))


## Human-readable ending name.
static func ending_label(ending: String) -> String:
	return str(ENDING_LABELS.get(ending, ending.capitalize()))


## Formats one tempered-buff stat modifier dictionary ({stat, value}) for display.
static func format_mod_line(m: Dictionary) -> String:
	var stat: String = str(m.get("stat", ""))
	var val: float = float(m.get("value", 0.0))
	var is_pct: bool = stat.ends_with("_pct")
	var num_s: String = ("%+d" % int(roundf(val))) if absf(val - roundf(val)) < 0.01 else ("%+.1f" % val)
	var suffix: String = "%" if is_pct else ""
	var label: String = stat.trim_suffix("_pct").replace("_", " ").capitalize()
	return "%s%s %s (%s)" % [num_s, suffix, label, stat]


func _build() -> void:
	_primary_focus = null
	if view.is_empty():
		line(tr("No Heavenly Tribulation data to show."))
		return
	var mode: String = _detect_mode(view)
	var g: VBoxContainer = Illustrated.ground(body)
	if mode == MODE_CONFIRM:
		_build_confirmation(view, g)
	else:
		_build_result(view, g)


static func _detect_mode(v: Dictionary) -> String:
	var explicit: String = str(v.get("mode", ""))
	if explicit == MODE_CONFIRM or explicit == MODE_RESULT:
		return explicit
	if v.has("waves") and v.get("waves") is Array:
		return MODE_RESULT
	return MODE_CONFIRM


# --- Attempt Confirmation View (AC-TK-80, AC-TK-81) -------------------------------------------------------------

func _build_confirmation(v: Dictionary, g: VBoxContainer) -> void:
	var prev: Dictionary = v.get("preview", v) if v.get("preview") is Dictionary else v
	var wave_count: int = int(prev.get("wave_count", v.get("wave_count", 3)))
	var from_realm: String = str(prev.get("from_realm", ""))
	var to_realm: String = str(prev.get("to_realm", ""))
	var has_escape: bool = bool(prev.get("has_escape_art", false))
	var escape_warn: String = str(prev.get("escape_warning", ""))
	if has_escape and escape_warn == "":
		escape_warn = tr("Escape arts cannot flee a Heavenly Tribulation — fleeing fails the tribulation.")

	# Sticky header
	var htitle := Label.new()
	htitle.name = "ConfirmTitle"
	htitle.text = tr("Heavenly Tribulation (Thiên Kiếp) — %d Waves") % wave_count
	htitle.theme_type_variation = &"HeadingLabel"
	header.add_child(htitle)
	var hsub := Label.new()
	var step_text: String = "%s → %s · " % [from_realm.replace("_", " ").capitalize(), to_realm.replace("_", " ").capitalize()] if (from_realm != "" and to_realm != "") else ""
	hsub.text = step_text + tr("Foreseen · No healing between waves · Boss draw hidden until each wave begins")
	hsub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	header.add_child(hsub)

	# High-stakes warning banner
	var warn_box := PanelContainer.new()
	warn_box.name = "TribulationWarningBanner"
	warn_box.add_theme_stylebox_override("panel", Illustrated.box(Illustrated.CINNABAR, Illustrated.BRASS, 2, 10.0, 3))
	warn_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	g.add_child(warn_box)
	var wcol := VBoxContainer.new()
	wcol.add_theme_constant_override("separation", 4)
	warn_box.add_child(wcol)
	var wh := Label.new()
	wh.text = tr("⚠ HIGH-STAKES WARNING — HEAVENLY TRIBULATION")
	wh.theme_type_variation = &"TitleLabel"
	wh.add_theme_color_override("font_color", Illustrated.BONE)
	wcol.add_child(wh)
	var wb := Label.new()
	wb.text = tr("If your breakthrough roll succeeds, you immediately face %d consecutive boss waves drawn from the pool below. Health carries exactly with no healing; linh lực recovers briefly between waves; build and preparation are locked once confirmed. Clearing all %d waves enters the next realm with full vitality, a lasting buff, and a chosen reward. Losing ANY wave is death.") % [wave_count, wave_count]
	wb.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	wb.add_theme_color_override("font_color", Illustrated.BONE)
	wcol.add_child(wb)
	TooltipLayer.set_tip(warn_box, {
		"title": tr("Heavenly Tribulation Rules"),
		"fact": tr("%d waves · Foreseen · Death on failure") % wave_count,
		"summary": tr("Only a knockout win clears a wave. Draw, time/fatigue defeat, or fleeing all fail the tribulation."),
	})

	# Escape-art warning (AC-TK-81)
	if has_escape:
		var esc_box := PanelContainer.new()
		esc_box.name = "EscapeArtWarning"
		esc_box.add_theme_stylebox_override("panel", Illustrated.box(Color("#4A1416"), Color("#E6A94C"), 2, 10.0, 3))
		esc_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		g.add_child(esc_box)
		var esc_lbl := Label.new()
		esc_lbl.name = "EscapeArtWarningLabel"
		esc_lbl.text = "⚠ " + escape_warn
		esc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		esc_lbl.add_theme_color_override("font_color", Color("#FFD98A"))
		esc_box.add_child(esc_lbl)
		esc_box.focus_mode = Control.FOCUS_ALL
		esc_box.accessibility_name = esc_lbl.text
		TooltipLayer.set_tip(esc_box, {
			"title": tr("Slotted Escape Art Warning"),
			"fact": tr("Wasted slot in Tribulation"),
			"summary": tr("A successful flight fails the Heavenly Tribulation and kills the character. Replace the escape art before confirming."),
		})

	# Odds + Setup side by side
	var top_grid: GridContainer = Illustrated.grid(g, 1 if compact else 2, 10)
	_build_odds_inset(v, prev, wave_count, top_grid)
	_build_setup_inset(Dictionary(prev.get("setup", {})), top_grid)

	# Full Boss Pool (AC-TK-80: full profile & draw weight, NEVER any pre-rolled draw)
	_build_boss_pool_inset(Array(prev.get("pool", [])), wave_count, g)

	# Action bar
	var confirm_bare: bool = bool(v.get("confirm_bare", false))
	var use_talisman: bool = bool(v.get("use_talisman", true))
	var burn_life: bool = bool(v.get("burn_life", false))

	var confirm_btn: Button = action_button(
		tr("Confirm Attempt"),
		"breakthrough",
		[confirm_bare, use_talisman, burn_life],
		bar
	)
	confirm_btn.name = "ConfirmAttempt"
	confirm_btn.theme_type_variation = &"CommitButton"
	confirm_btn.accessibility_name = tr("Confirm Heavenly Tribulation breakthrough attempt (%d waves)") % wave_count
	TooltipLayer.set_tip(confirm_btn, {
		"title": tr("Confirm Attempt"),
		"fact": tr("Commits your current setup"),
		"summary": tr("Rolls the breakthrough and, on success, runs all %d Heavenly Tribulation waves atomically.") % wave_count,
	})
	_primary_focus = confirm_btn

	var prep_btn: Button = bar_open(tr("Prepare (Combat)"), "character", "", "combat")
	prep_btn.name = "PrepareCombat"
	TooltipLayer.set_tip(prep_btn, tr("Adjust your formation, arts, and equipment before committing."))

	var back_btn := Button.new()
	back_btn.name = "BackOut"
	back_btn.text = tr("Back out")
	back_btn.accessibility_name = tr("Back out of attempt confirmation")
	TooltipLayer.set_tip(back_btn, tr("Cancel without attempting the breakthrough."))
	back_btn.pressed.connect(func(): confirm_cancelled.emit())
	bar.add_child(back_btn)


func _build_odds_inset(v: Dictionary, prev: Dictionary, wave_count: int, parent: Control) -> void:
	var box: VBoxContainer = section_in(parent, "odds", tr("Attempt & Odds"))
	box.name = "OddsSummary"
	var chance: float = float(v.get("chance", prev.get("chance", -1.0)))
	if chance >= 0.0:
		var pct: float = chance * 100.0 if chance <= 1.0 else chance
		row(tr("Pill roll chance"), "%.1f %%" % pct, breakdown_tip(tr("Breakthrough chance"), v.get("breakthrough_breakdown", {})), box)
	else:
		row(tr("Pill roll chance"), tr("See bottleneck sheet"), null, box)
	if v.has("backlash"):
		row(tr("Qi deviation if roll fails"), "%.0f %%" % float(v.get("backlash", 0.0)), null, box)
	var pill_name: String = str(v.get("pill", ""))
	if pill_name != "":
		var pq: int = int(v.get("pill_quality", -1))
		row(tr("Breakthrough pill"), ("%s (quality %d)" % [pill_name, pq]) if pq >= 0 else pill_name, null, box)
	elif v.has("pill"):
		row(tr("Breakthrough pill"), tr("none held (bare attempt)"), null, box)
	if v.has("talisman"):
		row(tr("Breakthrough talisman"), str(v.get("talisman", "none")), null, box)
	row(tr("Tribulation waves"), tr("%d consecutive boss waves") % wave_count, {
		"title": tr("Wave count"),
		"fact": "%d" % wave_count,
		"summary": tr("Distinct bosses drawn weighted without replacement. Each wave's boss pool scales up."),
	}, box)
	var draw_note: Label = line(tr("Boss draw is sealed until each wave starts — no boss is pre-rolled here."), box)
	draw_note.name = "DrawHiddenNote"
	draw_note.add_theme_color_override("font_color", Color(Illustrated.INK, 0.78))


func _build_setup_inset(setup: Dictionary, parent: Control) -> void:
	var box: VBoxContainer = section_in(parent, "setup", tr("Your Setup (Locked on Confirm)"))
	box.name = "SetupSummary"
	if setup.is_empty():
		line(tr("Current character build and equipment."), box)
		return
	var rlabel: String = str(setup.get("realm_label", ""))
	if rlabel != "":
		row(tr("Fighting as"), rlabel, {
			"title": tr("Pre-breakthrough realm"),
			"summary": tr("You fight every wave at your pre-breakthrough realm against destination-realm bosses."),
		}, box)
	row(tr("Starting vitality"), format_pct(float(setup.get("vitality", 1.0))), null, box)
	var diag_id: String = str(setup.get("diagram_id", ""))
	row(tr("Formation"), diag_id if diag_id != "" else tr("Plain Row"), null, box)
	var ptags: Array = Array(setup.get("place_tags", []))
	var tag_strs: PackedStringArray = []
	for pt in ptags:
		tag_strs.append(str(pt))
	if not tag_strs.has("tribulation"):
		tag_strs.append("tribulation")
	row(tr("Ground tags"), ", ".join(tag_strs), null, box)
	var arts: Array = Array(setup.get("arts", []))
	row(tr("Slotted arts (%d)") % arts.size(), ", ".join(arts.map(func(a): return str(a))) if not arts.is_empty() else tr("none"), null, box)
	var tals: Dictionary = setup.get("talismans", {}) if setup.get("talismans") is Dictionary else {}
	var tal_parts: PackedStringArray = []
	for tk in tals.keys():
		tal_parts.append("%s ×%d" % [str(tk), int(tals[tk])])
	row(tr("Prepared talismans"), ", ".join(tal_parts) if not tal_parts.is_empty() else tr("none"), null, box)


func _build_boss_pool_inset(pool: Array, wave_count: int, parent: Control) -> void:
	var box: VBoxContainer = section_in(parent, "pool", tr("Tribulation Boss Pool (%d Bosses · %d Drawn Without Replacement)") % [pool.size(), wave_count])
	box.name = "BossPool"
	if pool.is_empty():
		line(tr("No bosses configured for this tribulation step."), box)
		return
	var total_weight: float = 0.0
	for raw_b in pool:
		if raw_b is Dictionary:
			total_weight += maxf(0.0, float((raw_b as Dictionary).get("weight", 0.0)))
	var grid: GridContainer = Illustrated.grid(box, 1 if compact else 3, 8)
	for raw_b in pool:
		if not (raw_b is Dictionary):
			continue
		grid.add_child(_boss_pool_card(raw_b as Dictionary, total_weight))


func _boss_pool_card(b: Dictionary, total_weight: float) -> PanelContainer:
	var bid: String = str(b.get("id", "boss"))
	var bname: String = str(b.get("name", bid))
	var mk: String = str(b.get("main_kind", ""))
	var mk_label: String = str(THREAT_LABELS.get(mk, mk.capitalize()))
	var w: float = float(b.get("weight", 1.0))
	var w_share: float = (w / total_weight) if total_weight > 0.0 else 0.0
	var mult: float = float(b.get("boss_pool_mult", 1.0))
	var off_est: float = float(b.get("off_estimate", 0.0))
	var ehp_est: float = float(b.get("ehp_estimate", 0.0))
	var arts: Array = Array(b.get("arts", []))
	var shares: Dictionary = b.get("off_shares", {}) if b.get("off_shares") is Dictionary else {}
	var resist: Dictionary = b.get("resist", {}) if b.get("resist") is Dictionary else {}
	var reward_lbl: String = str(b.get("reward_label", ""))

	var card := PanelContainer.new()
	card.name = "BossCard_" + bid
	card.add_theme_stylebox_override("panel", Illustrated.box(Illustrated.PAPER_TILE, Illustrated.BRASS_DIM, 1, 8.0, 2))
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.focus_mode = Control.FOCUS_ALL

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 3)
	card.add_child(col)

	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 6)
	col.add_child(top)
	var nm := Label.new()
	nm.text = bname + (" [provisional]" if bool(b.get("provisional", false)) else "")
	nm.theme_type_variation = &"HeadingLabel"
	nm.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	nm.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(nm)

	var wbadge := Label.new()
	wbadge.name = "BossWeight_" + bid
	wbadge.text = tr("Weight %.1f (%s)") % [w, format_pct(w_share)]
	wbadge.theme_type_variation = &"RowLabel"
	top.add_child(wbadge)

	var stats_lbl := Label.new()
	stats_lbl.text = tr("Threat: %s · Pool ×%.2f · Off %.0f · eHP %.0f") % [mk_label, mult, off_est, ehp_est]
	stats_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(stats_lbl)

	if not shares.is_empty():
		var sh_lbl := Label.new()
		sh_lbl.text = tr("Offence shares: Body %s · Qi %s · Soul %s") % [
			format_pct(float(shares.get("body", 0.0))),
			format_pct(float(shares.get("qi", 0.0))),
			format_pct(float(shares.get("soul", 0.0))),
		]
		sh_lbl.add_theme_color_override("font_color", Color(Illustrated.INK, 0.8))
		sh_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		col.add_child(sh_lbl)

	var arts_text: String = ", ".join(arts.map(func(a): return str(a))) if not arts.is_empty() else tr("none")
	var arts_lbl := Label.new()
	arts_lbl.text = tr("Arts (%d): %s") % [arts.size(), arts_text]
	arts_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(arts_lbl)

	var res_parts: PackedStringArray = []
	for rk in resist.keys():
		res_parts.append("%s %+.0f" % [str(rk), float(resist[rk])])
	if not res_parts.is_empty():
		var res_lbl := Label.new()
		res_lbl.text = tr("Resistances: %s") % ", ".join(res_parts)
		res_lbl.add_theme_color_override("font_color", Color(Illustrated.INK, 0.82))
		res_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		col.add_child(res_lbl)

	if reward_lbl != "":
		var rew_lbl := Label.new()
		rew_lbl.text = tr("Defeat reward offer: %s") % reward_lbl
		rew_lbl.add_theme_color_override("font_color", Illustrated.GILT)
		rew_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		col.add_child(rew_lbl)

	card.accessibility_name = "%s, %s, weight %.1f (%s), pool mult %.2f, arts %s" % [
		bname, mk_label, w, format_pct(w_share), mult, arts_text]
	var tip_lines: Array = [
		tr("Main threat: %s") % mk_label,
		tr("Draw weight: %.1f (%s of pool)") % [w, format_pct(w_share)],
		tr("Base pool mult: ×%.2f") % mult,
		tr("Estimates: Off %.0f · eHP %.0f") % [off_est, ehp_est],
		tr("Arts: %s") % arts_text,
	]
	if not res_parts.is_empty():
		tip_lines.append(tr("Resist: %s") % ", ".join(res_parts))
	if reward_lbl != "":
		tip_lines.append(tr("Reward if beaten: %s") % reward_lbl)
	TooltipLayer.set_tip(card, {
		"id": "tk_boss:" + bid,
		"title": bname,
		"fact": "%s · Weight %.1f" % [mk_label, w],
		"summary": tr("Part of the step's visible boss pool. May appear in any wave with pool scaling."),
		"lines": tip_lines,
	})
	return card


# --- Wave-by-Wave Progression & Result View (AC-TK-82, AC-TK-83) ------------------------------------------------

func _build_result(v: Dictionary, g: VBoxContainer) -> void:
	var waves: Array = Array(v.get("waves", []))
	var wave_count: int = int(v.get("wave_count", waves.size()))
	var waves_cleared: int = int(v.get("waves_cleared", 0))
	var survived: bool = bool(v.get("survived", false))
	var shown_n: int = clampi(_revealed_count, 0, waves.size())
	if shown_n == 0 and not waves.is_empty():
		shown_n = waves.size()

	# Sticky header
	var htitle := Label.new()
	htitle.name = "ResultTitle"
	if _final_shown:
		htitle.text = (tr("Heavenly Tribulation Survived — %d / %d Waves Cleared") % [waves_cleared, wave_count]) if survived \
			else (tr("Heavenly Tribulation Failed — %d / %d Waves Cleared") % [waves_cleared, wave_count])
	else:
		htitle.text = tr("Heavenly Tribulation — Wave %d of %d") % [shown_n, wave_count]
	htitle.theme_type_variation = &"HeadingLabel"
	header.add_child(htitle)

	# Waves section
	var waves_box: VBoxContainer = section_in(g, "waves", tr("Tribulation Waves (%d / %d)") % [shown_n, wave_count])
	waves_box.name = "WavesSection"
	if waves.is_empty():
		line(tr("No waves recorded."), waves_box)
	else:
		for i in shown_n:
			if waves[i] is Dictionary:
				waves_box.add_child(_wave_card(i, waves[i] as Dictionary, wave_count))

	# Step-by-step progression button when waves remain hidden or final outcome is pending
	if not _final_shown:
		var prog_row := HBoxContainer.new()
		prog_row.name = "WaveProgressionRow"
		prog_row.add_theme_constant_override("separation", 8)
		g.add_child(prog_row)
		if shown_n < waves.size():
			var next_btn := Button.new()
			next_btn.name = "NextWave"
			next_btn.text = tr("Next Wave (%d / %d) ›") % [shown_n + 1, wave_count]
			next_btn.theme_type_variation = &"CommitButton"
			next_btn.accessibility_name = tr("Reveal wave %d of %d") % [shown_n + 1, wave_count]
			TooltipLayer.set_tip(next_btn, tr("Advance to the next tribulation wave."))
			next_btn.pressed.connect(reveal_next_wave)
			prog_row.add_child(next_btn)
			_primary_focus = next_btn
		else:
			var fin_btn := Button.new()
			fin_btn.name = "ShowResult"
			fin_btn.text = tr("View Final Result ›")
			fin_btn.theme_type_variation = &"CommitButton"
			fin_btn.accessibility_name = tr("View final Heavenly Tribulation outcome")
			TooltipLayer.set_tip(fin_btn, tr("Show the survival buff, reward choice, or failure summary."))
			fin_btn.pressed.connect(reveal_next_wave)
			prog_row.add_child(fin_btn)
			_primary_focus = fin_btn
		var skip_btn := Button.new()
		skip_btn.name = "RevealAllWaves"
		skip_btn.text = tr("Show All")
		skip_btn.accessibility_name = tr("Reveal all waves and the final result")
		TooltipLayer.set_tip(skip_btn, tr("Show every wave and the final result at once."))
		skip_btn.pressed.connect(reveal_all_waves)
		prog_row.add_child(skip_btn)
		return

	# Final outcome section (AC-TK-83)
	if survived:
		_build_survival_outcome(v, g)
	else:
		_build_failure_outcome(v, g)

	var notes: Array = Array(v.get("notes", []))
	if not notes.is_empty():
		var notes_box: VBoxContainer = section_in(g, "notes", tr("Tribulation Log Notes"))
		for n in notes:
			line("• " + str(n), notes_box)

	# Action bar
	var cont := Button.new()
	cont.name = "ContinueAfterTribulation"
	cont.text = tr("Continue")
	cont.theme_type_variation = &"CommitButton"
	cont.accessibility_name = tr("Continue after Heavenly Tribulation")
	TooltipLayer.set_tip(cont, tr("Return to the map.") if survived else tr("Proceed to the life-ended / succession view."))
	cont.pressed.connect(func(): continue_requested.emit(survived))
	bar.add_child(cont)
	if _primary_focus == null:
		_primary_focus = cont


func _wave_card(idx: int, w: Dictionary, wave_count: int) -> PanelContainer:
	var k: int = int(w.get("wave", idx + 1))
	var bname: String = str(w.get("boss_name", w.get("boss_id", "?")))
	var mk: String = str(w.get("main_kind", ""))
	var cleared: bool = bool(w.get("cleared", false))
	var ending: String = str(w.get("ending", ""))
	var secs: float = float(w.get("seconds", 0.0))
	var hp_end: float = float(w.get("health_end", 0.0))
	var hp_max: float = float(w.get("health_max", 0.0))
	var qi_end: float = float(w.get("qi_end", 0.0))
	var qi_max: float = float(w.get("qi_max", 0.0))
	var layer: int = int(w.get("deciding_layer", -1))
	var m_eff: float = float(w.get("m_eff", 1.0))
	var m_capped: bool = bool(w.get("m_capped", false))
	var header_text: String = format_wave_header(w, wave_count)

	var card := PanelContainer.new()
	card.name = "WaveCard_%d" % k
	var edge: Color = Color("#2C6E49") if cleared else Illustrated.CINNABAR
	card.add_theme_stylebox_override("panel", Illustrated.box(Illustrated.PAPER_TILE, edge, 2, 6.0, 2))
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 2)
	card.add_child(col)

	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 8)
	col.add_child(top)

	var h_lbl := Label.new()
	h_lbl.name = "WaveHeader_%d" % k
	h_lbl.text = header_text
	h_lbl.theme_type_variation = &"HeadingLabel"
	h_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	h_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(h_lbl)

	var st_lbl := Label.new()
	st_lbl.name = "WaveStatus_%d" % k
	st_lbl.text = ("✓ " + tr("CLEARED")) if cleared else ("✗ " + tr("FAILED"))
	st_lbl.theme_type_variation = &"RowLabel"
	st_lbl.add_theme_color_override("font_color", Color("#1F5E2E") if cleared else Illustrated.CINNABAR)
	top.add_child(st_lbl)

	# Health / Qi start-vs-end summary
	var hp_pct: String = format_pct(hp_end / hp_max) if hp_max > 0.0 else "—"
	var qi_pct: String = format_pct(qi_end / qi_max) if qi_max > 0.0 else "—"
	var sum_lbl := Label.new()
	sum_lbl.name = "WaveSummary_%d" % k
	sum_lbl.text = tr("Ending: %s · Time: %.1f s · HP left: %.0f / %.0f (%s) · Qi left: %.0f / %.0f (%s) · Deciding layer: %s") % [
		ending_label(ending), secs, hp_end, hp_max, hp_pct, qi_end, qi_max, qi_pct, deciding_layer_label(layer)
	]
	sum_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(sum_lbl)

	var meta_row := HBoxContainer.new()
	meta_row.add_theme_constant_override("separation", 10)
	col.add_child(meta_row)

	var meta_lbl := Label.new()
	var mk_txt: String = str(THREAT_LABELS.get(mk, mk.capitalize())) if mk != "" else tr("Unknown")
	meta_lbl.text = tr("Threat: %s · Pool mult ×%.2f%s") % [mk_txt, m_eff, (" [CAPPED]" if m_capped else "")]
	meta_lbl.add_theme_color_override("font_color", Color(Illustrated.INK, 0.78))
	meta_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	meta_row.add_child(meta_lbl)

	var watch := Button.new()
	watch.name = "WatchFight_%d" % k
	watch.text = tr("Watch Fight")
	watch.accessibility_name = tr("Watch Fight — Wave %d of %d against %s") % [k, wave_count, bname]
	var log_n: int = Array(w.get("log_rows", [])).size()
	TooltipLayer.set_tip(watch, {
		"title": tr("Watch Fight (Wave %d)") % k,
		"fact": tr("%s · %.1f s · %d log rows") % [bname, secs, log_n],
		"summary": tr("Opens this wave's recorded combat in the Fight Screen to inspect every pulse and Breakdown."),
	})
	var payload: Dictionary = _wave_replay_payload(idx, w, wave_count)
	watch.pressed.connect(func(): watch_fight_requested.emit(idx, payload))
	meta_row.add_child(watch)

	return card


static func _wave_replay_payload(idx: int, w: Dictionary, wave_count: int) -> Dictionary:
	var out: Dictionary = {
		"wave_index": idx,
		"wave": int(w.get("wave", idx + 1)),
		"wave_count": wave_count,
		"header": format_wave_header(w, wave_count),
		"boss_id": str(w.get("boss_id", "")),
		"boss_name": str(w.get("boss_name", "")),
		"main_kind": str(w.get("main_kind", "")),
		"fight_seed": int(w.get("fight_seed", 0)),
		"winner": str(w.get("winner", "")),
		"ending": str(w.get("ending", "")),
		"seconds": float(w.get("seconds", 0.0)),
		"start_h": float(w.get("start_h", 1.0)),
		"start_q": float(w.get("start_q", 1.0)),
		"health_end": float(w.get("health_end", 0.0)),
		"health_max": float(w.get("health_max", 0.0)),
		"qi_end": float(w.get("qi_end", 0.0)),
		"qi_max": float(w.get("qi_max", 0.0)),
		"deciding_layer": int(w.get("deciding_layer", -1)),
		"log_rows": Array(w.get("log_rows", [])).duplicate(),
	}
	if w.get("fight") is Dictionary:
		out["fight"] = (w.fight as Dictionary).duplicate(true)
	return out


func _build_survival_outcome(v: Dictionary, g: VBoxContainer) -> void:
	var box: VBoxContainer = section_in(g, "outcome", tr("Tribulation Survived — Ascension & Spoils"))
	box.name = "TribulationOutcome"

	var banner := PanelContainer.new()
	banner.name = "SurvivalBanner"
	banner.add_theme_stylebox_override("panel", Illustrated.box(Color("#1F3B28"), Illustrated.BRASS, 2, 6.0, 3))
	box.add_child(banner)
	var bl := Label.new()
	bl.text = tr("✦ All %d waves cleared! You cross into the next realm with full vitality.") % int(v.get("waves_cleared", v.get("wave_count", 3)))
	bl.theme_type_variation = &"TitleLabel"
	bl.add_theme_color_override("font_color", Illustrated.BONE)
	bl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	banner.add_child(bl)

	# Lasting Buff (tribulation_tempered, 60 W budget)
	var pend: Dictionary = v.get("pending_reward", {}) if v.get("pending_reward") is Dictionary else {}
	var buff: Dictionary = v.get("tempered_buff", {}) if v.get("tempered_buff") is Dictionary else {}
	if buff.is_empty() and pend.get("buff") is Dictionary:
		buff = pend.buff
	var buff_panel := PanelContainer.new()
	buff_panel.name = "TemperedBuffPanel"
	buff_panel.add_theme_stylebox_override("panel", Illustrated.box(Illustrated.PAPER_TILE, Illustrated.BRASS, 1, 6.0, 2))
	buff_panel.focus_mode = Control.FOCUS_ALL
	box.add_child(buff_panel)
	var bcol := VBoxContainer.new()
	bcol.add_theme_constant_override("separation", 2)
	buff_panel.add_child(bcol)
	var btitle := Label.new()
	var buff_src: String = str(buff.get("source", "tribulation_tempered"))
	var buff_label: String = str(buff.get("label", tr("Thiên Kiếp tôi luyện (Tribulation-Tempered)")))
	btitle.name = "TemperedBuffTitle"
	btitle.text = tr("Lasting Buff: %s [%s · 60 W]") % [buff_label, buff_src]
	btitle.theme_type_variation = &"HeadingLabel"
	btitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bcol.add_child(btitle)
	var mod_lines: Array = []
	for raw_m in Array(buff.get("mods", [])):
		if raw_m is Dictionary:
			mod_lines.append(format_mod_line(raw_m as Dictionary))
	var m_lbl := Label.new()
	m_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if mod_lines.is_empty():
		m_lbl.text = "  • " + tr("tribulation_tempered active for the rest of this life")
	else:
		m_lbl.text = "  • " + "   ·   ".join(mod_lines)
	bcol.add_child(m_lbl)
	buff_panel.accessibility_name = "%s: %s" % [btitle.text, ", ".join(mod_lines)]
	TooltipLayer.set_tip(buff_panel, {
		"id": "tk_buff:" + buff_src,
		"title": buff_label,
		"fact": "%s (60 W budget)" % buff_src,
		"summary": tr("Permanent sheet modifier line carried for the rest of this life and across save/reload."),
		"lines": mod_lines,
	})

	# Reward Choice Picker (AC-TK-83)
	var choices: Array = Array(pend.get("choices", []))
	var claimed: bool = bool(v.get("reward_claimed", false))
	if choices.is_empty() and not claimed:
		choices = Array(v.get("reward_choices", []))

	var picker := VBoxContainer.new()
	picker.name = "RewardPicker"
	picker.add_theme_constant_override("separation", 6)
	box.add_child(picker)
	var rh := Label.new()
	rh.text = tr("CHOOSE ONE TRIBULATION REWARD")
	rh.theme_type_variation = &"RowLabel"
	picker.add_child(rh)

	if claimed:
		line(tr("Tribulation reward claimed."), picker)
	elif choices.is_empty():
		line(tr("No reward choices pending."), picker)
	else:
		var rgrid: GridContainer = Illustrated.grid(picker, 1 if compact else mini(3, choices.size()), 8)
		for i in choices.size():
			if not (choices[i] is Dictionary):
				continue
			var ch: Dictionary = choices[i] as Dictionary
			var rcard := _reward_choice_card(i, ch)
			rgrid.add_child(rcard)


func _reward_choice_card(idx: int, ch: Dictionary) -> PanelContainer:
	var label: String = str(ch.get("label", ch.get("template", "Reward %d" % (idx + 1))))
	var rkind: String = str(ch.get("kind", "item"))
	var qty: int = int(ch.get("qty", 1))
	var rarity: int = int(ch.get("rarity", 1))

	var card := PanelContainer.new()
	card.name = "RewardCard_%d" % idx
	card.add_theme_stylebox_override("panel", Illustrated.box(Illustrated.PAPER_TILE, Illustrated.BRASS, 2, 6.0, 2))
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 3)
	card.add_child(col)

	var nm := Label.new()
	nm.text = "%d) %s" % [idx + 1, label]
	nm.theme_type_variation = &"HeadingLabel"
	nm.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(nm)

	var meta := Label.new()
	meta.text = tr("%s · qty %d · rarity %d") % [rkind.capitalize(), qty, rarity]
	meta.add_theme_color_override("font_color", Color(Illustrated.INK, 0.78))
	col.add_child(meta)

	var pick: Button = action_button(tr("Choose Reward"), "choose_tribulation_reward", [idx], col)
	pick.name = "ChooseReward_%d" % idx
	pick.theme_type_variation = &"CommitButton"
	pick.accessibility_name = tr("Choose reward %d: %s (%s, rarity %d)") % [idx + 1, label, rkind, rarity]
	TooltipLayer.set_tip(pick, {
		"id": "tk_reward:%d" % idx,
		"title": label,
		"fact": tr("%s · qty %d · rarity %d") % [rkind.capitalize(), qty, rarity],
		"summary": tr("Claims this reward into your inventory. You may choose only one."),
	})
	if _primary_focus == null and not pick.disabled:
		_primary_focus = pick
	return card


func _build_failure_outcome(v: Dictionary, g: VBoxContainer) -> void:
	var box: VBoxContainer = section_in(g, "outcome", tr("Tribulation Failed"))
	box.name = "TribulationOutcome"

	var panel := PanelContainer.new()
	panel.name = "FailureSummary"
	panel.add_theme_stylebox_override("panel", Illustrated.box(Illustrated.CINNABAR, Illustrated.BRASS, 2, 10.0, 3))
	box.add_child(panel)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 4)
	panel.add_child(col)

	var fatal_wave: int = int(v.get("fatal_wave", int(v.get("waves_cleared", 0)) + 1))
	var fb: Dictionary = v.get("fatal_boss", {}) if v.get("fatal_boss") is Dictionary else {}
	var fb_name: String = str(fb.get("name", fb.get("id", "?")))
	var fail_reason: String = str(v.get("fail_reason", "failed"))
	var waves: Array = Array(v.get("waves", []))
	var last_layer: int = -1
	if not waves.is_empty() and waves[-1] is Dictionary:
		last_layer = int((waves[-1] as Dictionary).get("deciding_layer", -1))

	var title := Label.new()
	title.name = "FailureHeadline"
	title.text = tr("✗ Fallen under Heavenly Tribulation on Wave %d against %s") % [fatal_wave, fb_name]
	title.theme_type_variation = &"TitleLabel"
	title.add_theme_color_override("font_color", Illustrated.BONE)
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(title)

	var detail := Label.new()
	detail.name = "FailureDetail"
	detail.text = tr("Cause: tribulation · Ending: %s · Deciding layer: %s · Waves cleared: %d / %d. No lasting buff or reward is granted.") % [
		ending_label(fail_reason), deciding_layer_label(last_layer), int(v.get("waves_cleared", 0)), int(v.get("wave_count", waves.size()))
	]
	detail.add_theme_color_override("font_color", Illustrated.BONE)
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(detail)
	TooltipLayer.set_tip(panel, {
		"title": tr("Tribulation Failure"),
		"fact": tr("Wave %d · %s") % [fatal_wave, fb_name],
		"summary": tr("Losing any Heavenly Tribulation wave kills the cultivator. Review the fatal wave's Fight Screen to see what your build lacked."),
	})
