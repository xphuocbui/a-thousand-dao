# PROTOTYPE - NOT FOR PRODUCTION
# Question: Does drafting/fusing fragments into a chain engine make players rework builds, and can a local LLM narrate it within engine budgets?
# Date: 2026-11-02
extends Control

# Single-screen prototype: draft fragments, arrange/fuse them, preview the chain, fight 3 stages.
# Hypothesis A telemetry: rework actions (move/fuse/discard), runs started, stage reached.
# Hypothesis B: LLM narrate / invent-event / benchmark buttons.

const Core := preload("res://core.gd")
const Llm := preload("res://llm.gd")

var core = Core.new()
var llm = Llm.new()
var rng := RandomNumberGenerator.new()

var build: Array = []
var offers: Array = []
var stage: int = 0
var picks_left: int = 3
var run_over: bool = false
var last_result: Dictionary = {}
var last_enemy: Dictionary = {}
var last_won: bool = false

var rework_actions: int = 0
var runs_started: int = 0
var telemetry: Array = []

var title_label: Label
var slot_list: ItemList
var offer_buttons: Array = []
var preview: RichTextLabel
var log_view: RichTextLabel
var llm_out: RichTextLabel
var status_label: Label
var llm_status: Label
var fight_btn: Button
var url_edit: LineEdit
var model_edit: LineEdit


func _ready() -> void:
	theme = Theme.new()
	theme.default_font_size = 15
	add_child(llm)
	_build_ui()
	new_run()
	if OS.get_cmdline_user_args().has("--autoplay"):
		for k in 3:
			_on_offer(0)
		_on_fight()


func _label(text: String) -> Label:
	var l := Label.new()
	l.text = text
	return l


func _button(text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.pressed.connect(cb)
	return b


func _build_ui() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 8)
	add_child(margin)
	var root := VBoxContainer.new()
	margin.add_child(root)

	title_label = _label("")
	root.add_child(title_label)

	var cols := HBoxContainer.new()
	cols.size_flags_vertical = Control.SIZE_EXPAND_FILL
	cols.size_flags_stretch_ratio = 1.0
	root.add_child(cols)

	# left: build
	var left := VBoxContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.size_flags_stretch_ratio = 1.0
	cols.add_child(left)
	left.add_child(_label("Your Dao (chain order = slot order, left to right)"))
	slot_list = ItemList.new()
	slot_list.select_mode = ItemList.SELECT_MULTI
	slot_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left.add_child(slot_list)
	var row := HBoxContainer.new()
	left.add_child(row)
	row.add_child(_button("Move up", _on_move.bind(-1)))
	row.add_child(_button("Move down", _on_move.bind(1)))
	row.add_child(_button("Fuse 2 selected", _on_fuse))
	row.add_child(_button("Discard", _on_discard))

	# middle: offers
	var mid := VBoxContainer.new()
	mid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cols.add_child(mid)
	mid.add_child(_label("Draft: pick 1 of 3 (shows best placement)"))
	for i in 3:
		var b := Button.new()
		b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		b.custom_minimum_size = Vector2(0, 90)
		b.pressed.connect(_on_offer.bind(i))
		mid.add_child(b)
		offer_buttons.append(b)
	fight_btn = _button("FIGHT!", _on_fight)
	fight_btn.custom_minimum_size = Vector2(0, 50)
	mid.add_child(fight_btn)
	mid.add_child(_button("New run", new_run))
	status_label = _label("")
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	mid.add_child(status_label)

	# right: preview
	var right := VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.size_flags_stretch_ratio = 1.2
	cols.add_child(right)
	right.add_child(_label("Chain preview (expected damage over 5 rounds, no dice)"))
	preview = RichTextLabel.new()
	preview.bbcode_enabled = true
	preview.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right.add_child(preview)

	# bottom: clash log + LLM
	var bottom := HBoxContainer.new()
	bottom.custom_minimum_size = Vector2(0, 250)
	bottom.size_flags_vertical = Control.SIZE_EXPAND_FILL
	bottom.size_flags_stretch_ratio = 1.0
	root.add_child(bottom)
	var lv := VBoxContainer.new()
	lv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom.add_child(lv)
	lv.add_child(_label("Clash log (engine) + templated narration"))
	log_view = RichTextLabel.new()
	log_view.bbcode_enabled = true
	log_view.size_flags_vertical = Control.SIZE_EXPAND_FILL
	lv.add_child(log_view)

	var rv := VBoxContainer.new()
	rv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom.add_child(rv)
	var cfg := HBoxContainer.new()
	rv.add_child(cfg)
	url_edit = LineEdit.new()
	url_edit.text = llm.url
	url_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cfg.add_child(url_edit)
	model_edit = LineEdit.new()
	model_edit.text = llm.model
	model_edit.custom_minimum_size = Vector2(130, 0)
	cfg.add_child(model_edit)
	var lrow := HBoxContainer.new()
	rv.add_child(lrow)
	lrow.add_child(_button("Narrate (LLM)", _on_llm_narrate))
	lrow.add_child(_button("Invent event (LLM)", _on_llm_event))
	lrow.add_child(_button("Benchmark x10", _on_llm_bench))
	llm_status = _label("LLM: not called yet")
	llm_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rv.add_child(llm_status)
	llm_out = RichTextLabel.new()
	llm_out.bbcode_enabled = true
	llm_out.size_flags_vertical = Control.SIZE_EXPAND_FILL
	rv.add_child(llm_out)


func _note(event: String) -> void:
	telemetry.append("%d %s" % [Time.get_ticks_msec(), event])
	var f := FileAccess.open("user://session.log", FileAccess.WRITE)
	if f:
		f.store_string("\n".join(telemetry))


func new_run() -> void:
	rng.randomize()
	build = []
	stage = 0
	picks_left = 3
	run_over = false
	last_result = {}
	offers = core.draw_offers(rng)
	runs_started += 1
	log_view.text = ""
	_note("new_run %d" % runs_started)
	refresh()


func best_insert(f: Dictionary) -> Dictionary:
	var best_total: float = -1.0
	var best_pos: int = 0
	for pos in range(build.size() + 1):
		var cand: Array = build.duplicate()
		cand.insert(pos, f)
		var t: float = core.simulate(cand).total
		if t > best_total:
			best_total = t
			best_pos = pos
	return {"total": best_total, "pos": best_pos}


func refresh() -> void:
	var enemy: Dictionary = Core.ENEMIES[stage]
	title_label.text = "Stage %d/3 vs %s (HP %.0f) | picks left %d | slots %d/%d | rework actions %d | runs %d" % [stage + 1, enemy.name, enemy.hp, picks_left, build.size(), Core.MAX_SLOTS, rework_actions, runs_started]
	slot_list.clear()
	for i in build.size():
		var f: Dictionary = build[i]
		slot_list.add_item("%d. %s [%s %s] %s" % [i + 1, f.name, f.elem, f.kind, f.desc])
	var current: float = core.simulate(build).total if build.size() > 0 else 0.0
	for i in 3:
		var b: Button = offer_buttons[i]
		if picks_left > 0 and i < offers.size():
			var f: Dictionary = offers[i]
			var bi: Dictionary = best_insert(f)
			b.text = "%s [%s %s]\n%s\nBest at slot %d -> chain total %.0f (%+.0f)" % [f.name, f.elem, f.kind, f.desc, bi.pos + 1, bi.total, bi.total - current]
			b.disabled = build.size() >= Core.MAX_SLOTS or run_over
			if build.size() >= Core.MAX_SLOTS:
				b.text += "\nSLOTS FULL: fuse or discard first"
		else:
			b.text = "(no pick available)"
			b.disabled = true
	fight_btn.disabled = run_over or picks_left > 0 or build.size() == 0
	_refresh_preview()


func _refresh_preview() -> void:
	var enemy: Dictionary = Core.ENEMIES[stage]
	var res: Dictionary = core.simulate(build)
	var t: String = ""
	for i in build.size():
		var val: float = res.per_slot[i]
		var tag: String = ""
		if build[i].kind == "amp":
			var without: Array = build.duplicate()
			without.remove_at(i)
			val = res.total - core.simulate(without).total
			tag = " (+ to later slots, already counted below)"
		var share: float = val / max(res.total, 1.0)
		t += "%d. %-18s %s %.0f%s\n" % [i + 1, build[i].name, "#".repeat(clampi(int(share * 30), 0, 30)), val, tag]
	var col: String = "green" if res.total >= enemy.hp else "red"
	t += "\nExpected total: [color=%s]%.0f[/color] vs enemy HP %.0f (dice +-10%%)" % [col, res.total, enemy.hp]
	preview.text = t


func _on_offer(i: int) -> void:
	if picks_left <= 0 or build.size() >= Core.MAX_SLOTS or i >= offers.size():
		return
	var pos: int = best_insert(offers[i]).pos
	build.insert(pos, offers[i])
	picks_left -= 1
	_note("pick %s at %d" % [offers[i].name, pos])
	offers = core.draw_offers(rng) if picks_left > 0 else []
	status_label.text = ""
	refresh()


func _selected() -> Array:
	return Array(slot_list.get_selected_items())


func _on_move(dir: int) -> void:
	var sel: Array = _selected()
	if sel.size() != 1:
		return
	var i: int = sel[0]
	var j: int = i + dir
	if j < 0 or j >= build.size():
		return
	var tmp: Dictionary = build[i]
	build[i] = build[j]
	build[j] = tmp
	rework_actions += 1
	_note("move %d->%d" % [i, j])
	refresh()
	slot_list.select(j)


func _on_fuse() -> void:
	var sel: Array = _selected()
	if sel.size() != 2:
		status_label.text = "Select exactly 2 slots (ctrl/shift-click) to fuse."
		return
	sel.sort()
	var f: Dictionary = core.fuse(build[sel[0]], build[sel[1]])
	build.remove_at(sel[1])
	build[sel[0]] = f
	rework_actions += 1
	_note("fuse -> %s" % f.name)
	refresh()


func _on_discard() -> void:
	var sel: Array = _selected()
	if sel.size() != 1:
		return
	build.remove_at(sel[0])
	rework_actions += 1
	_note("discard")
	refresh()


func _on_fight() -> void:
	var enemy: Dictionary = Core.ENEMIES[stage]
	var res: Dictionary = core.simulate(build, rng)
	var won: bool = res.total >= enemy.hp
	last_result = res
	last_enemy = enemy
	last_won = won
	var t: String = ""
	for r in range(1, Core.ROUNDS + 1):
		var rt: float = 0.0
		var parts: String = ""
		for l in res.lines:
			if l.round == r:
				rt += l.dealt
				parts += "  %s %.0f%s\n" % [l.name, l.dealt, (" (" + l.note + ")") if l.note != "" else ""]
		t += "[b]Round %d: %.0f[/b]\n%s" % [r, rt, parts]
	t += "\n[b]Total %.0f vs HP %.0f -> %s[/b]\n\n" % [res.total, enemy.hp, "VICTORY" if won else "DEFEAT"]
	t += "[i]" + core.narrate_template(res, enemy, won) + "[/i]"
	log_view.text = t
	_note("fight stage %d total %.0f hp %.0f won %s" % [stage + 1, res.total, enemy.hp, won])
	if not won:
		run_over = true
		status_label.text = "RESULT: you fell at stage %d. Press New run." % (stage + 1)
	elif stage == Core.ENEMIES.size() - 1:
		run_over = true
		status_label.text = "RESULT: tribulation survived. Ascended! Press New run."
	else:
		stage += 1
		picks_left = 3
		offers = core.draw_offers(rng)
		status_label.text = "RESULT: stage cleared. Draft 3 more."
	refresh()


func _sync_llm_cfg() -> void:
	llm.url = url_edit.text
	llm.model = model_edit.text


func _on_llm_narrate() -> void:
	if last_result.is_empty():
		llm_status.text = "LLM: fight first so there is a result to narrate."
		return
	_sync_llm_cfg()
	llm_status.text = "LLM: narrating..."
	var s: String = "Enemy: %s. Outcome: %s. Total damage %.0f against HP %.0f.\n" % [last_enemy.name, "victory" if last_won else "defeat", last_result.total, last_enemy.hp]
	var hits: Array = last_result.lines.filter(func(l): return l.dealt > 0.0)
	hits.sort_custom(func(a, b): return a.dealt > b.dealt)
	for k in range(min(5, hits.size())):
		s += "Round %d: %s dealt %.0f.\n" % [hits[k].round, hits[k].name, hits[k].dealt]
	var rx := RegEx.new()
	rx.compile("\\d+")
	var allowed: Array = []
	for m in rx.search_all(s):
		allowed.append(m.get_string())
	var r: Dictionary = await llm.narrate(s, allowed)
	if not r.ok:
		llm_status.text = "LLM: FAILED (%s, %d ms). Templated narration still works." % [r.error, r.ms]
		return
	llm_status.text = "LLM: narrated in %d ms | numbers faithful: %s %s" % [r.ms, str(r.faithful), "" if r.faithful else "stray: " + str(r.stray)]
	llm_out.text = r.text


func _on_llm_event() -> void:
	_sync_llm_cfg()
	llm_status.text = "LLM: inventing event..."
	var names: Array = build.map(func(f): return f.name)
	var r: Dictionary = await llm.invent_event(stage, "Stage %d of 3. Player Dao: %s." % [stage + 1, ", ".join(names)])
	if not r.ok:
		llm_status.text = "LLM: FAILED (%s, %d ms). " % [r.error, r.ms] + llm.stats_text()
		return
	llm_status.text = "LLM: %d ms | strict JSON %s | keys valid %s | clamped to budget %s %s" % [r.ms, str(r.strict), str(r.keys), str(r.was_clamped), str(r.budget)]
	llm_out.text = JSON.stringify(r.event, "  ") if r.keys else "(invalid event)"


func _on_llm_bench() -> void:
	_sync_llm_cfg()
	llm.reset_stats()
	llm_out.text = ""
	for n in 10:
		llm_status.text = "LLM: benchmark %d/10..." % (n + 1)
		await llm.invent_event(n % 3, "Benchmark call %d. Player is a wandering cultivator." % n)
	var avg: int = llm.total_ms / max(llm.calls, 1)
	var pass_speed: bool = avg < 5000
	var pass_valid: bool = llm.keys_ok >= 9
	llm_status.text = "BENCH: " + llm.stats_text()
	llm_out.text = "Hypothesis B signals\n  avg latency < 5000 ms: %s (%d ms)\n  >= 9/10 valid events: %s (%d/10)\n  out-of-budget values clamped by engine: %d" % ["PASS" if pass_speed else "FAIL", avg, "PASS" if pass_valid else "FAIL", llm.keys_ok, llm.clamped]
	_note("bench avg %d keys_ok %d" % [avg, llm.keys_ok])
