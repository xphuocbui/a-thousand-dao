class_name EventDataValidator
extends RefCounted
## Strict load-time validator for Event Engine data files (design/gdd/event-engine.md
## Rules 1, 3, 4, 12, 14, 19, 22; AC-EV-04, AC-EV-23, AC-EV-33, AC-EV-41, AC-EV-45).
##
## Validates [code]events_budgets.json[/code], [code]events_templates.json[/code],
## [code]events_hooks.json[/code], and [code]events_stories.json[/code]: rejects unknown
## conditions, retired/unknown place kinds, unknown or retired effects (such as [code]dao_an[/code]),
## player-only effects on [code]npc_capable[/code] records, empty player-facing text,
## missing trait [code]event:*[/code] hook wiring (all 54 hooks in [code]traits.json[/code]),
## missing hidden-chronicle uncoverings, and secret realms lacking a closing event.

const FILE_BUDGETS := "events_budgets"
const FILE_TEMPLATES := "events_templates"
const FILE_HOOKS := "events_hooks"
const FILE_STORIES := "events_stories"
const FILE_HISTORY := "world_history"
const RETIRED_TREASURES := ["dao_an"]


## Validates the complete shipped Event Engine dataset loaded in [param gd].
## Returns [code]{ok: bool, errors: Array[String], warnings: Array[String]}[/code].
static func validate_all(gd: GameData) -> Dictionary:
	var templates_doc: Dictionary = gd.file(FILE_TEMPLATES)
	var hooks_doc: Dictionary = gd.file(FILE_HOOKS)
	var stories_doc: Dictionary = gd.file(FILE_STORIES)
	var history_doc: Dictionary = gd.file(FILE_HISTORY)
	return validate_dataset(gd, templates_doc, hooks_doc, stories_doc, history_doc)


## Validates an arbitrary Event Engine dataset (shipped or synthetic test fixture).
## Returns [code]{ok: bool, errors: Array[String], warnings: Array[String]}[/code].
static func validate_dataset(
	gd: GameData,
	templates_doc: Dictionary,
	hooks_doc: Dictionary,
	stories_doc: Dictionary,
	history_doc: Dictionary = {}
) -> Dictionary:
	var errors: Array[String] = []
	var warnings: Array[String] = []
	var cfg: Dictionary = gd.budgets()

	_validate_budgets(cfg, errors)

	var seen_event_ids := {}
	var all_events: Array = []
	var wired_trait_hooks := {}
	var uncovered_chronicles := {}
	var closing_realms_by_name := {}
	var closing_realms_by_slot := {}
	var story_event_ids := {}
	var story_ids := {}

	# 1. Validate events_templates.json
	for t in Array(templates_doc.get("templates", [])):
		if not (t is Dictionary):
			errors.append("%s: non-dictionary template record" % FILE_TEMPLATES)
			continue
		var td: Dictionary = t as Dictionary
		validate_event_record(td, FILE_TEMPLATES, gd, errors, warnings)
		_track_event(td, FILE_TEMPLATES, seen_event_ids, all_events, wired_trait_hooks, uncovered_chronicles, closing_realms_by_name, closing_realms_by_slot, errors)

	# 2. Validate events_hooks.json
	var allowed_hooks: Array = Array(cfg.get("allowed_hooks", []))
	var hook_reg: Dictionary = Dictionary(hooks_doc.get("hooks", {}))
	for hk in hook_reg:
		if not allowed_hooks.has(str(hk)):
			errors.append("%s: unknown hook '%s' in hooks registry" % [FILE_HOOKS, str(hk)])
	for t in Array(hooks_doc.get("templates", [])):
		if not (t is Dictionary):
			errors.append("%s: non-dictionary template record" % FILE_HOOKS)
			continue
		var td: Dictionary = t as Dictionary
		validate_event_record(td, FILE_HOOKS, gd, errors, warnings)
		_track_event(td, FILE_HOOKS, seen_event_ids, all_events, wired_trait_hooks, uncovered_chronicles, closing_realms_by_name, closing_realms_by_slot, errors)

	# 3. Validate events_stories.json (events first so stories can cross-check stage event_ids)
	for ev in Array(stories_doc.get("events", [])):
		if not (ev is Dictionary):
			errors.append("%s: non-dictionary story event record" % FILE_STORIES)
			continue
		var evd: Dictionary = ev as Dictionary
		validate_event_record(evd, FILE_STORIES, gd, errors, warnings)
		var eid: String = str(evd.get("id", ""))
		if eid != "":
			story_event_ids[eid] = evd
		_track_event(evd, FILE_STORIES, seen_event_ids, all_events, wired_trait_hooks, uncovered_chronicles, closing_realms_by_name, closing_realms_by_slot, errors)

	for st in Array(stories_doc.get("stories", [])):
		if not (st is Dictionary):
			errors.append("%s: non-dictionary story record" % FILE_STORIES)
			continue
		var std: Dictionary = st as Dictionary
		var sid: String = str(std.get("id", ""))
		if sid != "":
			if story_ids.has(sid):
				errors.append("%s: duplicate story id '%s'" % [FILE_STORIES, sid])
			story_ids[sid] = std
		validate_story_record(std, FILE_STORIES, gd, errors, warnings, story_event_ids)
		_collect_hooks_from_cond(Dictionary(Dictionary(std.get("start", {})).get("conditions", {})), wired_trait_hooks)
		for stage in Array(std.get("stages", [])):
			if stage is Dictionary:
				_collect_hooks_from_cond(Dictionary((stage as Dictionary).get("conditions", {})), wired_trait_hooks)

	# 4. Cross-reference follow-up and story_start targets
	for pair in all_events:
		var evd: Dictionary = pair.rec
		var fname: String = str(pair.file)
		var eid: String = str(evd.get("id", "?"))
		for ch in Array(evd.get("choices", [])):
			if not (ch is Dictionary):
				continue
			for bucket in _choice_effect_lists(ch as Dictionary):
				for fx in bucket:
					if not (fx is Dictionary):
						continue
					var fxd: Dictionary = fx as Dictionary
					var ftype: String = str(fxd.get("type", ""))
					if ftype == "schedule_followup":
						var target_ev: String = str(fxd.get("event_id", ""))
						if target_ev == "" or not seen_event_ids.has(target_ev):
							errors.append("%s [%s]: schedule_followup references missing event_id '%s'" % [fname, eid, target_ev])
					elif ftype == "story_start":
						var target_st: String = str(fxd.get("story_id", ""))
						if target_st == "" or not story_ids.has(target_st):
							errors.append("%s [%s]: story_start references missing story_id '%s'" % [fname, eid, target_st])

	# 5. Verify all 54 trait event:* hooks from traits.json are wired
	var required_trait_hooks: Array = trait_event_hooks_in(gd)
	for hk in required_trait_hooks:
		if not wired_trait_hooks.has(str(hk)):
			errors.append("%s: trait hook '%s' from traits.json is not wired in any event condition or show_conditions" % [FILE_HOOKS, str(hk)])

	# 6. Verify hidden chronicles & secret realm closing events against world_history.json
	var hist: Dictionary = history_doc if not history_doc.is_empty() else gd.file(FILE_HISTORY)
	if not hist.is_empty():
		var valid_chronicle_ids := {}
		var hidden_chronicle_ids: Array = []
		for ce in Array(hist.get("events", [])):
			if ce is Dictionary:
				var ced: Dictionary = ce as Dictionary
				var cid: String = str(ced.get("id", ""))
				if cid != "":
					valid_chronicle_ids[cid] = true
				if str(ced.get("kind", "")) == "hidden":
					hidden_chronicle_ids.append(cid)
		for cid in uncovered_chronicles:
			if not valid_chronicle_ids.has(str(cid)):
				errors.append("%s: uncover_chronicle references unknown chronicle id '%s'" % [FILE_STORIES, str(cid)])
		for hcid in hidden_chronicle_ids:
			if not uncovered_chronicles.has(str(hcid)):
				errors.append("%s: hidden chronicle '%s' has no uncover_chronicle outcome" % [FILE_STORIES, str(hcid)])

		# AC-EV-45: every secret realm must have an authored closing event
		for fs in Array(hist.get("famous_sites", [])):
			if fs is Dictionary and str((fs as Dictionary).get("kind", "")) == "secret_realm":
				var sr_name: String = str((fs as Dictionary).get("name", ""))
				if sr_name != "" and not closing_realms_by_name.has(sr_name):
					errors.append("%s: secret realm '%s' is missing a closing event (on_secret_realm)" % [FILE_HOOKS, sr_name])
		for hs in Array(hist.get("hidden_slots", [])):
			if hs is Dictionary and str((hs as Dictionary).get("kind", "")) == "secret_realm":
				var sr_slot: String = str((hs as Dictionary).get("slot", ""))
				if sr_slot != "" and not closing_realms_by_slot.has(sr_slot):
					errors.append("%s: secret realm '%s' is missing a closing event (on_secret_realm)" % [FILE_HOOKS, sr_slot])

	return {"ok": errors.is_empty(), "errors": errors, "warnings": warnings}


## Validates one event record against Rules 1, 3, 4, 19, and 22 (AC-EV-04, AC-EV-33, AC-EV-41).
static func validate_event_record(rec: Dictionary, file_name: String, gd: GameData, errors: Array, warnings: Array) -> void:
	var cfg: Dictionary = gd.budgets()
	var eid: String = str(rec.get("id", ""))
	if eid == "":
		errors.append("%s: event record missing 'id'" % file_name)
		eid = "<missing_id>"

	var allowed_kinds: Array = Array(cfg.get("allowed_kinds", []))
	var kind: String = str(rec.get("kind", "hook" if str(rec.get("hook", "")) != "" else "pulse"))
	if not allowed_kinds.has(kind):
		errors.append("%s [%s]: unknown event kind '%s'" % [file_name, eid, kind])

	var allowed_hooks: Array = Array(cfg.get("allowed_hooks", []))
	var hk: String = str(rec.get("hook", ""))
	if kind == "hook":
		if hk == "" or not allowed_hooks.has(hk):
			errors.append("%s [%s]: invalid or missing hook '%s'" % [file_name, eid, hk])
	elif hk != "" and not allowed_hooks.has(hk):
		errors.append("%s [%s]: unknown hook '%s'" % [file_name, eid, hk])

	# Place kinds (Rule 4, AC-EV-04): reject any retired/unknown place kind in place_kinds or non-empty place_types
	var allowed_places: Array = Array(cfg.get("allowed_place_kinds", []))
	if rec.has("place_kinds"):
		var pks: Variant = rec.place_kinds
		if not (pks is Array):
			errors.append("%s [%s]: place_kinds must be an array" % [file_name, eid])
		else:
			for pk in (pks as Array):
				var pks_str: String = str(pk)
				if not allowed_places.has(pks_str):
					errors.append("%s [%s]: unknown place kind '%s'" % [file_name, eid, pks_str])
	if rec.has("place_types"):
		var pts: Variant = rec.place_types
		if pts is Array and not (pts as Array).is_empty():
			for pt in (pts as Array):
				var pts_str: String = str(pt)
				if not allowed_places.has(pts_str):
					errors.append("%s [%s]: retired or unknown place kind '%s' in place_types" % [file_name, eid, pts_str])

	# Conditions AST & weight modifiers (Rule 4, AC-EV-04)
	var allowed_conds: Array = Array(cfg.get("allowed_conditions", []))
	if rec.has("conditions") and rec.conditions is Dictionary:
		_validate_cond(rec.conditions as Dictionary, file_name, eid, allowed_conds, errors)
	for wm in Array(rec.get("weight_mods", [])):
		if wm is Dictionary and (wm as Dictionary).has("conditions") and (wm as Dictionary).conditions is Dictionary:
			_validate_cond((wm as Dictionary).conditions as Dictionary, file_name, eid, allowed_conds, errors)

	# Text completeness (Rule 22, AC-EV-41)
	if not _non_empty_text(rec.get("title", "")):
		errors.append("%s [%s]: empty title" % [file_name, eid])
	if not _non_empty_text(rec.get("text", "")):
		errors.append("%s [%s]: empty text" % [file_name, eid])
	if rec.has("log") and not _non_empty_text(rec.get("log", "")):
		errors.append("%s [%s]: empty log line" % [file_name, eid])

	# Choices & effects (Rules 1, 4, 19, 22)
	var choices: Variant = rec.get("choices", [])
	var min_ch: int = int(cfg.get("min_choices", 2))
	var max_ch: int = int(cfg.get("max_choices", 4))
	if not (choices is Array):
		errors.append("%s [%s]: choices must be an array" % [file_name, eid])
		return
	var ch_arr: Array = choices as Array
	if ch_arr.size() < min_ch or ch_arr.size() > max_ch:
		errors.append("%s [%s]: choice count %d outside %d..%d" % [file_name, eid, ch_arr.size(), min_ch, max_ch])

	var allowed_tags: Array = Array(cfg.get("allowed_choice_tags", []))
	var allowed_stats: Array = Array(cfg.get("allowed_check_stats", []))
	var allowed_fx: Array = Array(cfg.get("allowed_effect_types", []))
	var player_only: Array = Array(cfg.get("player_only_effects", []))
	var allowed_sources: Array = Array(cfg.get("allowed_money_sources", []))
	var is_npc_event: bool = bool(rec.get("npc_capable", false)) or (typeof(rec.get("npc")) == TYPE_BOOL and bool(rec.get("npc")))

	for i in ch_arr.size():
		var ch_v: Variant = ch_arr[i]
		if not (ch_v is Dictionary):
			errors.append("%s [%s] choice %d: not an object" % [file_name, eid, i])
			continue
		var ch: Dictionary = ch_v as Dictionary
		if not _non_empty_text(ch.get("label", "")):
			errors.append("%s [%s] choice %d: empty label" % [file_name, eid, i])
		for tag in Array(ch.get("tags", [])):
			if not allowed_tags.has(str(tag)):
				errors.append("%s [%s] choice %d: unknown choice tag '%s'" % [file_name, eid, i, str(tag)])
		if ch.has("show_conditions") and ch.show_conditions is Dictionary:
			_validate_cond(ch.show_conditions as Dictionary, file_name, eid, allowed_conds, errors)
		var chk: Dictionary = Dictionary(ch.get("check", {"type": "none"}))
		var chk_type: String = str(chk.get("type", "none"))
		if not (chk_type in ["none", "stat", "combat"]):
			errors.append("%s [%s] choice %d: unknown check type '%s'" % [file_name, eid, i, chk_type])
		elif chk_type == "stat":
			var st: String = str(chk.get("stat", ""))
			if not allowed_stats.has(st):
				errors.append("%s [%s] choice %d: unknown check stat '%s'" % [file_name, eid, i, st])
		var suc: Variant = ch.get("success", null)
		if not (suc is Dictionary) or not _non_empty_text((suc as Dictionary).get("text", "")):
			errors.append("%s [%s] choice %d: missing or empty success text" % [file_name, eid, i])
		if ch.has("failure"):
			var fail_v: Variant = ch.get("failure")
			if not (fail_v is Dictionary) or not _non_empty_text((fail_v as Dictionary).get("text", "")):
				errors.append("%s [%s] choice %d: empty failure text" % [file_name, eid, i])
		for bucket in _choice_effect_lists(ch):
			for fx in bucket:
				if not (fx is Dictionary):
					errors.append("%s [%s] choice %d: non-object effect" % [file_name, eid, i])
					continue
				_validate_effect(fx as Dictionary, file_name, eid, is_npc_event, allowed_fx, player_only, allowed_sources, gd, errors, warnings)


## Validates one story record against Rule 12 and Formulas C (AC-EV-23, AC-EV-41).
## Clamps [code]budget_mult > m_story_max[/code] with a warning (AC-EV-23).
static func validate_story_record(
	rec: Dictionary,
	file_name: String,
	gd: GameData,
	errors: Array,
	warnings: Array,
	story_event_ids: Dictionary = {}
) -> void:
	var cfg: Dictionary = gd.budgets()
	var sid: String = str(rec.get("id", ""))
	if sid == "":
		errors.append("%s: story record missing 'id'" % file_name)
		sid = "<missing_story_id>"
	if not _non_empty_text(rec.get("name", "")):
		errors.append("%s [%s]: empty story name" % [file_name, sid])
	for lk in ["log_done", "log_failed", "log_timeout"]:
		if not _non_empty_text(rec.get(lk, "")):
			errors.append("%s [%s]: empty %s" % [file_name, sid, lk])

	var cb: Dictionary = Dictionary(cfg.get("chain_budgets", {}))
	var m_max: float = float(cb.get("m_story_max", 3.0))
	var mult: float = float(rec.get("budget_mult", 1.5))
	if mult > m_max:
		warnings.append("%s [%s]: story budget_mult %s exceeds m_story_max %s; clamped to %s" % [file_name, sid, str(mult), str(m_max), str(m_max)])
		rec["budget_mult"] = m_max
	elif mult <= 0.0:
		errors.append("%s [%s]: story budget_mult must be > 0" % [file_name, sid])

	var items_max_cap: int = int(cb.get("story_items_max", 4))
	var items_max: int = int(rec.get("items_max", 2))
	if items_max > items_max_cap:
		warnings.append("%s [%s]: story items_max %d exceeds story_items_max %d; clamped to %d" % [file_name, sid, items_max, items_max_cap, items_max_cap])
		rec["items_max"] = items_max_cap

	var allowed_conds: Array = Array(cfg.get("allowed_conditions", []))
	var start: Dictionary = Dictionary(rec.get("start", {}))
	if start.has("conditions") and start.conditions is Dictionary:
		_validate_cond(start.conditions as Dictionary, file_name, sid, allowed_conds, errors)

	var stages: Variant = rec.get("stages", [])
	if not (stages is Array) or (stages as Array).is_empty():
		errors.append("%s [%s]: story must define at least 1 stage" % [file_name, sid])
		return
	for st_v in (stages as Array):
		if not (st_v is Dictionary):
			errors.append("%s [%s]: non-object stage" % [file_name, sid])
			continue
		var st: Dictionary = st_v as Dictionary
		if str(st.get("id", "")) == "":
			errors.append("%s [%s]: stage missing id" % [file_name, sid])
		var ev_id: String = str(st.get("event_id", ""))
		if ev_id == "":
			errors.append("%s [%s] stage '%s': missing event_id" % [file_name, sid, str(st.get("id", "?"))])
		elif not story_event_ids.is_empty() and not story_event_ids.has(ev_id):
			errors.append("%s [%s] stage '%s': references missing story event '%s'" % [file_name, sid, str(st.get("id", "?")), ev_id])
		if st.has("conditions") and st.conditions is Dictionary:
			_validate_cond(st.conditions as Dictionary, file_name, sid, allowed_conds, errors)


## Returns the sorted unique list of all [code]event:*[/code] hooks declared in [code]traits.json[/code].
static func trait_event_hooks_in(gd: GameData) -> Array:
	var traits_doc: Dictionary = gd.file(NpcTraits.FILE)
	var seen := {}
	for k in NpcTraits.ALL_KINDS:
		for t in Array(traits_doc.get(k, [])):
			if not (t is Dictionary):
				continue
			for h in Array((t as Dictionary).get("opens", [])):
				var hs: String = str(h)
				if hs.begins_with("event:"):
					seen[hs] = true
	var out: Array = seen.keys()
	out.sort()
	return out


# --- Internal Helpers ----------------------------------------------------------------------------

static func _validate_budgets(cfg: Dictionary, errors: Array) -> void:
	for req_key in [
		"pacing", "weights", "chain_budgets", "npc_events",
		"allowed_kinds", "allowed_hooks", "allowed_place_kinds",
		"allowed_conditions", "allowed_effect_types", "player_only_effects",
		"allowed_money_sources", "allowed_choice_tags", "per_realm",
	]:
		if not cfg.has(req_key):
			errors.append("%s: missing required section '%s'" % [FILE_BUDGETS, req_key])


static func _validate_cond(cond: Dictionary, file_name: String, rec_id: String, allowed_conds: Array, errors: Array) -> void:
	if cond.is_empty():
		return
	var ctype: String = str(cond.get("type", ""))
	if ctype == "":
		errors.append("%s [%s]: condition missing 'type'" % [file_name, rec_id])
		return
	if not allowed_conds.has(ctype):
		errors.append("%s [%s]: unknown condition '%s'" % [file_name, rec_id, ctype])
		return
	if ctype == "all" or ctype == "any":
		var items: Variant = cond.get("items", [])
		if not (items is Array):
			errors.append("%s [%s]: condition '%s' requires 'items' array" % [file_name, rec_id, ctype])
			return
		for sub in (items as Array):
			if sub is Dictionary:
				_validate_cond(sub as Dictionary, file_name, rec_id, allowed_conds, errors)
			else:
				errors.append("%s [%s]: condition '%s' contains non-object item" % [file_name, rec_id, ctype])
	elif ctype == "not":
		var sub: Variant = cond.get("item", cond.get("cond", null))
		if sub is Dictionary:
			_validate_cond(sub as Dictionary, file_name, rec_id, allowed_conds, errors)
		else:
			errors.append("%s [%s]: condition 'not' requires 'item' object" % [file_name, rec_id])


static func _validate_effect(
	fx: Dictionary,
	file_name: String,
	eid: String,
	is_npc_event: bool,
	allowed_fx: Array,
	player_only: Array,
	allowed_sources: Array,
	gd: GameData,
	errors: Array,
	_warnings: Array
) -> void:
	var ftype: String = str(fx.get("type", ""))
	if not allowed_fx.has(ftype):
		errors.append("%s [%s]: unknown effect '%s'" % [file_name, eid, ftype])
		return
	if ftype == "treasure":
		var tid: String = str(fx.get("treasure", ""))
		if RETIRED_TREASURES.has(tid) or tid == "" or gd.treasure(tid).is_empty():
			errors.append("%s [%s]: retired or unknown treasure effect '%s'" % [file_name, eid, tid])
	if ftype == "linh_thach" and fx.has("source") and str(fx.source) != "":
		var src: String = str(fx.source)
		if not allowed_sources.has(src):
			errors.append("%s [%s]: unknown money source '%s'" % [file_name, eid, src])
	if ftype == "uncover_chronicle" and str(fx.get("chronicle_id", "")) == "":
		errors.append("%s [%s]: uncover_chronicle missing chronicle_id" % [file_name, eid])
	if is_npc_event:
		var po_key: String = ftype if ftype != "talisman" else ("talisman:" + str(fx.get("talisman", "")))
		if player_only.has(ftype) or player_only.has(po_key):
			errors.append("%s [%s]: player-only effect '%s' is forbidden on npc_capable event" % [file_name, eid, po_key])


static func _track_event(
	rec: Dictionary,
	file_name: String,
	seen_ids: Dictionary,
	all_events: Array,
	wired_hooks: Dictionary,
	uncovered_chronicles: Dictionary,
	closing_by_name: Dictionary,
	closing_by_slot: Dictionary,
	errors: Array
) -> void:
	var eid: String = str(rec.get("id", ""))
	if eid != "":
		if seen_ids.has(eid):
			errors.append("%s: duplicate event id '%s'" % [file_name, eid])
		seen_ids[eid] = true
	all_events.append({"file": file_name, "rec": rec})
	if rec.has("conditions") and rec.conditions is Dictionary:
		_collect_hooks_from_cond(rec.conditions as Dictionary, wired_hooks)
	for wm in Array(rec.get("weight_mods", [])):
		if wm is Dictionary and (wm as Dictionary).has("conditions") and (wm as Dictionary).conditions is Dictionary:
			_collect_hooks_from_cond((wm as Dictionary).conditions as Dictionary, wired_hooks)
	for ch in Array(rec.get("choices", [])):
		if not (ch is Dictionary):
			continue
		var chd: Dictionary = ch as Dictionary
		if chd.has("show_conditions") and chd.show_conditions is Dictionary:
			_collect_hooks_from_cond(chd.show_conditions as Dictionary, wired_hooks)
		for bucket in _choice_effect_lists(chd):
			for fx in bucket:
				if fx is Dictionary and str((fx as Dictionary).get("type", "")) == "uncover_chronicle":
					var cid: String = str((fx as Dictionary).get("chronicle_id", ""))
					if cid != "":
						uncovered_chronicles[cid] = true
	if str(rec.get("hook", "")) == "on_secret_realm" and str(rec.get("secret_realm_phase", "")) == "closing":
		var sr_name: String = str(rec.get("secret_realm_name", ""))
		if sr_name != "":
			closing_by_name[sr_name] = eid
		var sr_slot: String = str(rec.get("secret_realm_slot", ""))
		if sr_slot != "":
			closing_by_slot[sr_slot] = eid


static func _collect_hooks_from_cond(cond: Dictionary, out: Dictionary) -> void:
	if cond.is_empty():
		return
	var ctype: String = str(cond.get("type", ""))
	if ctype == "has_event_hook":
		var hk: String = str(cond.get("hook", cond.get("value", "")))
		if hk != "":
			if not hk.begins_with("event:"):
				hk = "event:" + hk
			out[hk] = true
	elif ctype == "all" or ctype == "any":
		for sub in Array(cond.get("items", [])):
			if sub is Dictionary:
				_collect_hooks_from_cond(sub as Dictionary, out)
	elif ctype == "not":
		var sub: Variant = cond.get("item", cond.get("cond", null))
		if sub is Dictionary:
			_collect_hooks_from_cond(sub as Dictionary, out)


static func _choice_effect_lists(ch: Dictionary) -> Array:
	var lists: Array = []
	lists.append(Array(ch.get("always", [])))
	if ch.get("success") is Dictionary:
		lists.append(Array((ch.success as Dictionary).get("effects", [])))
	if ch.get("failure") is Dictionary:
		lists.append(Array((ch.failure as Dictionary).get("effects", [])))
	return lists


static func _non_empty_text(v: Variant) -> bool:
	if v is Array:
		var arr: Array = v as Array
		if arr.is_empty():
			return false
		for x in arr:
			if str(x).strip_edges() == "":
				return false
		return true
	return v != null and str(v).strip_edges() != ""
