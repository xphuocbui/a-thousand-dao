class_name EventTemplateSource
extends RefCounted
## Unified offline event template source across [code]events_templates.json[/code],
## [code]events_hooks.json[/code], and [code]events_stories.json[/code]
## (design/gdd/event-engine.md Rules 1-4, 7, 22; Formulas B).
##
## Evaluates eligibility and effective weights via [EventConditions], binds scopes
## ([code]other[/code], [code]place[/code], [code]sect[/code]), substitutes Rule 22 placeholders
## and variant arrays, and converts [code]budget_frac[/code] ranges into concrete amounts.
## Preserves Dialogue #30 [code]on_talk[/code] scenes and Codex #12 [code]requires_past_ties[/code]
## isolation cleanly.
##
## Usage:
## [codeblock]
## var src := EventTemplateSource.new(gd, db, builds)
## var raw: Dictionary = src.generate(ctx, rng)       # {} if nothing fits
## var res: Dictionary = validator.normalize(raw, ctx, rng, raw.source)
## [/codeblock]

const _EventConditions = preload("res://src/gameplay/events/event_conditions.gd")

var _gd: GameData
var _db: WorldDB
var _builds: BuildGenerator


func _init(gd: GameData, db: WorldDB, builds: BuildGenerator) -> void:
	_gd = gd
	_db = db
	_builds = builds


## Returns all templates combined across [code]events_templates.json[/code],
## [code]events_hooks.json[/code], and [code]events_stories.json[/code].
func all_templates() -> Array:
	var out: Array = []
	out.append_array(Array(_gd.event_templates().get("templates", [])))
	var hooks_doc: Dictionary = _gd.file("events_hooks")
	if not hooks_doc.is_empty():
		out.append_array(Array(hooks_doc.get("templates", [])))
	var stories_doc: Dictionary = _gd.file("events_stories")
	if not stories_doc.is_empty():
		out.append_array(Array(stories_doc.get("events", [])))
	return out


## Finds one template or story event record by [param template_id] across all three event files, or {}.
func get_template(template_id: String) -> Dictionary:
	if template_id == "":
		return {}
	for t in all_templates():
		if t is Dictionary and str((t as Dictionary).get("id", "")) == template_id:
			return t as Dictionary
	return {}


## Returns the hook registry config entry for [param hook_id] from [code]events_hooks.json[/code], or {}.
func hook_config(hook_id: String) -> Dictionary:
	var hooks_doc: Dictionary = _gd.file("events_hooks")
	return Dictionary(Dictionary(hooks_doc.get("hooks", {})).get(hook_id, {}))


## Returns all authored story definitions from [code]events_stories.json[/code].
func all_stories() -> Array:
	var stories_doc: Dictionary = _gd.file("events_stories")
	return Array(stories_doc.get("stories", []))


## Finds one story definition by [param story_id] from [code]events_stories.json[/code], or {}.
func get_story(story_id: String) -> Dictionary:
	if story_id == "":
		return {}
	for st in all_stories():
		if st is Dictionary and str((st as Dictionary).get("id", "")) == story_id:
			return st as Dictionary
	return {}


## Returns all [code]kind == "pulse"[/code] templates (excluding hooks, follow-up-only, and story events).
func pulse_templates(include_hooks_file: bool = true) -> Array:
	var out: Array = []
	for t in Array(_gd.event_templates().get("templates", [])):
		if t is Dictionary and _is_pulse_record(t as Dictionary):
			out.append(t)
	if include_hooks_file:
		var hooks_doc: Dictionary = _gd.file("events_hooks")
		for t in Array(hooks_doc.get("templates", [])):
			if t is Dictionary and _is_pulse_record(t as Dictionary):
				out.append(t)
	return out


## Returns all event records registered under [param hook_id].
func hook_templates(hook_id: String, include_templates_file: bool = true) -> Array:
	var out: Array = []
	var hooks_doc: Dictionary = _gd.file("events_hooks")
	for t in Array(hooks_doc.get("templates", [])):
		if t is Dictionary and str((t as Dictionary).get("hook", "")) == hook_id:
			out.append(t)
	if include_templates_file:
		for t in Array(_gd.event_templates().get("templates", [])):
			if t is Dictionary and str((t as Dictionary).get("hook", "")) == hook_id:
				out.append(t)
	return out


## Returns all NPC-capable pulse templates ([code]npc_capable == true[/code], [code]kind == "pulse"[/code]).
func npc_capable_templates() -> Array:
	return pulse_templates(true).filter(func(t):
		return bool(t.get("npc_capable", false)) or (typeof(t.get("npc")) == TYPE_BOOL and bool(t.get("npc"))))


## Builds an [EventConditions] evaluation environment dictionary from an [EventContext] [param ctx]
## and optional bound [param other] / [param story] records.
func env_from_ctx(ctx: Dictionary, other: Dictionary = {}, story: Dictionary = {}) -> Dictionary:
	var pid: String = str(Dictionary(ctx.get("player", {})).get("id", ""))
	var root_rec: Dictionary = _db.get_record("people", pid) if (_db != null and pid != "") else {}
	var root_merged: Dictionary = root_rec.duplicate()
	for k in Dictionary(ctx.get("player", {})):
		if not root_merged.has(k) or k in ["at_bottleneck", "tam_ma", "linh_thach", "realm_index"]:
			root_merged[k] = ctx.player[k]
	var place_id: String = str(Dictionary(ctx.get("place", {})).get("id", ""))
	var place_rec: Dictionary = _db.get_record("places", place_id) if (_db != null and place_id != "") else {}
	var place_merged: Dictionary = place_rec.duplicate()
	for k in Dictionary(ctx.get("place", {})):
		if not place_merged.has(k):
			place_merged[k] = ctx.place[k]
	var sect_id: String = str(Dictionary(ctx.get("sect", {})).get("id", root_merged.get("sect_id", "")))
	var sect_rec: Dictionary = _db.get_record("sects", sect_id) if (_db != null and sect_id != "") else {}
	var spy: int = int(_gd.cultivation_rules().get("seasons_per_year", 4)) if _gd != null else 4
	var year: int = int(ctx.get("year", 0))
	var season: int = int(ctx.get("season", 0))
	var now_season: int = int(ctx.get("now_season", year * spy + season))
	return {
		"root": root_merged,
		"other": other,
		"place": place_merged,
		"sect": sect_rec,
		"story": story,
		"now_season": now_season,
		"year": year,
		"season": season,
		"edge": bool(ctx.get("edge", false)),
		"co_duyen_left": int(ctx.get("co_duyen_left", 0)),
		"biome": str(ctx.get("biome", place_merged.get("biome", Dictionary(place_merged.get("qi", {})).get("part_biome", "")))),
		"travel_mode": str(ctx.get("travel_mode", "")),
		"extra": Dictionary(ctx.get("extra", {})).merged({"at_bottleneck": bool(Dictionary(ctx.get("player", {})).get("at_bottleneck", false))}, false),
	}


## Pulse templates eligible in this context (excludes hooked, follow-up-only, and story templates).
func eligible(ctx: Dictionary) -> Array:
	var env: Dictionary = env_from_ctx(ctx)
	var ptype: String = str(Dictionary(ctx.get("place", {})).get("type", ""))
	var pkind: String = _EventConditions.place_kind_of(env.place, _gd)
	var pool: Array = pulse_templates(true)
	return pool.filter(func(t):
		return is_template_eligible(t, ctx, env, ptype, pkind))


## Checks whether one template record [param t] passes place, legacy requirement, condition AST,
## and positive effective weight checks for [param ctx] / [param env].
func is_template_eligible(t: Dictionary, ctx: Dictionary, env: Dictionary, ptype: String = "", pkind: String = "") -> bool:
	var pk_now: String = pkind if pkind != "" else _EventConditions.place_kind_of(Dictionary(env.get("place", {})), _gd)
	var pt_now: String = ptype if ptype != "" else str(Dictionary(ctx.get("place", {})).get("type", ""))
	if t.has("place_kinds") and t.place_kinds is Array and not (t.place_kinds as Array).is_empty():
		var pks: Array = t.place_kinds as Array
		if not (pks.has("any") or pks.has(pk_now) or (pt_now != "" and pks.has(pt_now))):
			return false
	elif t.has("place_types") and t.place_types is Array and not (t.place_types as Array).is_empty():
		var pts: Array = t.place_types as Array
		if not (pts.has("any") or pts.has(pt_now) or pts.has(pk_now)):
			return false
	var sect_id: String = str(Dictionary(ctx.get("sect", {})).get("id", Dictionary(env.get("root", {})).get("sect_id", "")))
	if bool(t.get("requires_sect", false)) and sect_id == "":
		return false
	var realm_idx: int = int(Dictionary(ctx.get("player", {})).get("realm_index", Dictionary(env.get("root", {})).get("realm_index", 0)))
	if int(t.get("requires_realm_min", 0)) > realm_idx:
		return false
	if bool(t.get("requires_edge", false)) and not (bool(ctx.get("edge", false)) and int(ctx.get("co_duyen_left", 0)) > 0):
		return false
	if bool(t.get("requires_bottleneck", false)) and not bool(Dictionary(ctx.get("player", {})).get("at_bottleneck", false)):
		return false
	if float(t.get("requires_tam_ma", 0)) > float(Dictionary(ctx.get("player", {})).get("tam_ma", Dictionary(env.get("root", {})).get("tam_ma", 0.0))):
		return false
	if bool(t.get("requires_past_ties", false)):
		if int(ctx.get("recognition_left", 0)) <= 0:
			return false
		if not _has_living_past_tie(ctx):
			return false
	if t.has("conditions") and t.conditions is Dictionary and not (t.conditions as Dictionary).is_empty():
		if not _EventConditions.evaluate(t.conditions as Dictionary, env, _gd, _db):
			return false
	if _EventConditions.effective_weight(t, env, _gd, _db) <= 0.0:
		return false
	return true


## Returns authored [code]on_talk[/code] scene templates from [code]events_templates.json[/code]
## eligible for [param npc] in [param ctx] (NPC Interaction & Dialogue #30 Rule 18, AC-NI-25).
## Does not alter random [method eligible] rolls.
func eligible_on_talk(ctx: Dictionary, npc: Dictionary) -> Array:
	if npc.is_empty():
		return []
	var cast_key: String = str(npc.get("cast_key", ""))
	var seen: Array = Array(npc.get("seen_scenes", []))
	var flags: Dictionary = InteractionRules.npc_flags(npc)
	var cur_band: String = InteractionRules.attitude_band(_gd, int(npc.get("attitude", 0)))
	var cur_rank: int = InteractionRules.band_rank(cur_band)
	return Array(_gd.event_templates().get("templates", [])).filter(func(t):
		if str(t.get("hook", "")) != "on_talk":
			return false
		if bool(t.get("once", false)) and seen.has(str(t.get("id", ""))):
			return false
		var cks: Array = Array(t.get("cast_keys", []))
		if not cks.is_empty() and not cks.has(cast_key):
			return false
		var req_flags: Array = Array(t.get("requires_npc_flags", []))
		for rf in req_flags:
			var rfs: String = str(rf)
			if not flags.has(rfs) or (typeof(flags[rfs]) == TYPE_BOOL and not bool(flags[rfs])):
				return false
		var min_b: String = str(t.get("attitude_band_min", ""))
		if min_b != "" and cur_rank < InteractionRules.band_rank(min_b):
			return false
		if bool(t.get("requires_sect", false)) and str(ctx.sect.id) == "":
			return false
		if int(t.get("requires_realm_min", 0)) > int(ctx.player.get("realm_index", 0)):
			return false
		return true)


## Generates an authored [code]on_talk[/code] scene for [param npc] by weight (Event Engine Rule 7),
## or {} if none is eligible (NPC Interaction & Dialogue #30 Rule 18, AC-NI-25).
func generate_on_talk(ctx: Dictionary, npc: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	return generate_for_npc(ctx, npc, rng, "")


## Generates a hooked event bound directly to [param npc] (either forced by [param template_id],
## e.g. [code]provoke_duel[/code] / [code]threat_ambush[/code] / [code]loan_collection[/code],
## or picked by weight from [method eligible_on_talk] when [param template_id] is empty).
func generate_for_npc(ctx: Dictionary, npc: Dictionary, rng: RandomNumberGenerator, template_id: String = "") -> Dictionary:
	if npc.is_empty():
		return {}
	var pool: Array = eligible_on_talk(ctx, npc) if template_id == "" else _templates_with_id(template_id)
	if pool.is_empty():
		return {}
	var t: Dictionary = RngUtils.weighted_pick(rng, pool)
	return fill_template(t, ctx, str(npc.get("id", "")), rng)


## Generates a raw event, or {} if no template fits. [param template_id] forces one across all files.
func generate(ctx: Dictionary, rng: RandomNumberGenerator, template_id: String = "") -> Dictionary:
	var env: Dictionary = env_from_ctx(ctx)
	var pool: Array = eligible(ctx)
	if template_id != "":
		pool = _templates_with_id(template_id)
	for _attempt in maxi(6, mini(pool.size(), 16)):
		if pool.is_empty():
			return {}
		var t: Dictionary = _pick_weighted(pool, env, rng)
		var npc_id: String = bind_other_scope(t, ctx, rng, str(ctx.get("bound_npc_id", "")))
		if npc_id == "!":
			if template_id != "":
				npc_id = ""   # forced template lookup (e.g. Dialogue #30 tests binding raw["npc"] afterwards)
			else:
				pool.erase(t)
				continue
		var filled: Dictionary = fill_template(t, ctx, npc_id, rng)
		if filled.is_empty():
			pool.erase(t)
			continue
		return filled
	return {}


## Binds the [code]other[/code] / [code]npc[/code] scope for [param t] in [param ctx].
## Returns "" when no other person is needed, "!" when the required scope cannot bind (making the
## event ineligible per Rule 2), or the bound WorldDB person id.
func bind_other_scope(t: Dictionary, ctx: Dictionary, rng: RandomNumberGenerator, bound_npc_id: String = "") -> String:
	var spec: Dictionary = {}
	var raw_scopes: Variant = t.get("scopes", {})
	if raw_scopes is Dictionary and (raw_scopes as Dictionary).get("other") is Dictionary:
		spec = (raw_scopes as Dictionary).other as Dictionary
	elif t.get("npc") is Dictionary:
		spec = t.npc as Dictionary
	else:
		spec = {"mode": "none"}
	return _bind_npc(spec, ctx, rng, bound_npc_id)


## Fills a template record [param t] into a raw event Dictionary with all Rule 22 placeholders,
## variant selection, show_conditions filtering, and budget_frac expansion.
## Returns {} if fewer than [code]min_choices[/code] options survive [code]show_conditions[/code].
func fill_template(
	t: Dictionary,
	ctx: Dictionary,
	npc_id: String,
	rng: RandomNumberGenerator,
	extra_subs: Dictionary = {},
	story_rec: Dictionary = {}
) -> Dictionary:
	var npc: Dictionary = _db.get_record("people", npc_id) if (_db != null and npc_id != "") else {}
	var env: Dictionary = env_from_ctx(ctx, npc, story_rec)
	var root_id: String = str(Dictionary(ctx.get("player", {})).get("id", ""))
	var root_name: String = str(Dictionary(ctx.get("player", {})).get("name", ""))
	var root_realm: String = str(Dictionary(ctx.get("player", {})).get("realm", ""))
	var place_name: String = str(Dictionary(ctx.get("place", {})).get("name", ""))
	var region_name: String = str(Dictionary(ctx.get("place", {})).get("region", ""))
	var sect_name: String = str(Dictionary(ctx.get("sect", {})).get("name", ""))
	var npc_name: String = str(npc.get("name", ""))
	var npc_realm: String = _gd.realm_label(int(npc.get("realm_index", 0)), int(npc.get("stage", 0))) if not npc.is_empty() else ""
	var hist_line: String = _history_line(npc_id)
	var subs := {
		"player": root_name,
		"root": root_name,
		"root_realm": root_realm,
		"place": place_name,
		"region": region_name,
		"sect": sect_name,
		"npc": npc_name,
		"other": npc_name,
		"npc_realm": npc_realm,
		"other_realm": npc_realm,
		"npc_history": hist_line,
		"other_history": hist_line,
		"story_name": str(story_rec.get("name", "")),
	}
	if not story_rec.is_empty():
		var svars: Dictionary = Dictionary(story_rec.get("variables", {}))
		for vk in svars:
			subs["var:%s" % str(vk)] = str(svars[vk])
	for ek in extra_subs:
		subs[str(ek)] = str(extra_subs[ek])

	var tid: String = str(t.get("id", ""))
	var abs_s: int = int(env.get("now_season", 0))
	var title: String = _EventConditions.render_text(t.get("title", ""), subs, "ev_text:%s:%s:%d:title" % [tid, root_id, abs_s])
	var body: String = _EventConditions.render_text(t.get("text", ""), subs, "ev_text:%s:%s:%d:text" % [tid, root_id, abs_s])
	var log_line: String = _EventConditions.render_text(t.get("log", ""), subs, "ev_text:%s:%s:%d:log" % [tid, root_id, abs_s])

	var raw_choices: Array = []
	var ch_list: Array = Array(t.get("choices", []))
	for ci in ch_list.size():
		var c: Dictionary = ch_list[ci]
		if c.has("show_conditions") and c.show_conditions is Dictionary and not (c.show_conditions as Dictionary).is_empty():
			if not _EventConditions.evaluate(c.show_conditions as Dictionary, env, _gd, _db):
				continue
		var suc_src: Dictionary = Dictionary(c.get("success", {}))
		var fail_src: Dictionary = Dictionary(c.get("failure", suc_src))
		var ch_out := {
			"label": _EventConditions.render_text(c.get("label", ""), subs, "ev_text:%s:%s:%d:ch%d_lbl" % [tid, root_id, abs_s, ci]),
			"tags": Array(c.get("tags", [])).duplicate(),
			"trait_badge": str(c.get("trait_badge", "")),
			"check": Dictionary(c.get("check", {"type": "none"})).duplicate(true),
			"always": _amounts(Array(c.get("always", [])), ctx, rng),
			"success": {
				"text": _EventConditions.render_text(suc_src.get("text", ""), subs, "ev_text:%s:%s:%d:ch%d_suc" % [tid, root_id, abs_s, ci]),
				"empty_text": _EventConditions.render_text(suc_src.get("empty_text", ""), subs, "ev_text:%s:%s:%d:ch%d_sempty" % [tid, root_id, abs_s, ci]),
				"hidden": bool(suc_src.get("hidden", false)),
				"deadly": bool(suc_src.get("deadly", false)),
				"effects": _amounts(Array(suc_src.get("effects", [])), ctx, rng),
			},
			"failure": {
				"text": _EventConditions.render_text(fail_src.get("text", ""), subs, "ev_text:%s:%s:%d:ch%d_fail" % [tid, root_id, abs_s, ci]),
				"empty_text": _EventConditions.render_text(fail_src.get("empty_text", ""), subs, "ev_text:%s:%s:%d:ch%d_fempty" % [tid, root_id, abs_s, ci]),
				"hidden": bool(fail_src.get("hidden", false)),
				"deadly": bool(fail_src.get("deadly", false)),
				"effects": _amounts(Array(fail_src.get("effects", [])), ctx, rng),
			},
		}
		raw_choices.append(ch_out)

	var min_ch: int = int(_gd.budgets().get("min_choices", 2))
	if raw_choices.size() < min_ch:
		return {}

	var raw := {
		"source": "template:%s" % tid,
		"template_id": tid,
		"kind": str(t.get("kind", "hook" if str(t.get("hook", "")) != "" else "pulse")),
		"hook": str(t.get("hook", "")),
		"story_id": str(story_rec.get("story_id", t.get("story_id", ""))),
		"story_instance_id": str(story_rec.get("id", "")),
		"story_name": str(story_rec.get("name", "")),
		"story_stage": str(story_rec.get("stage", "")),
		"chain_id": str(story_rec.get("chain_id", ctx.get("chain_id", ""))),
		"followup_of": str(ctx.get("followup_of", "")),
		"once": bool(t.get("once", false)),
		"once_per_life": bool(t.get("once_per_life", t.get("once", false))),
		"once_per_world": bool(t.get("once_per_world", false)),
		"cooldown_seasons": int(t.get("cooldown_seasons", _gd.budgets().get("pacing", {}).get("default_cooldown_seasons", 8))),
		"npc_capable": bool(t.get("npc_capable", false)),
		"newsworthy": bool(t.get("newsworthy", false)),
		"situation": str(t.get("situation", "")),
		"ground_tags": Array(t.get("ground_tags", [])).duplicate(),
		"no_heal": bool(t.get("no_heal", false)),
		"mercy_choice": bool(t.get("mercy_choice", false)),
		"illustration": str(t.get("illustration", "")),
		"title": title,
		"text": body,
		"log": log_line,
		"npc": {"id_resolved": npc_id} if npc_id != "" else null,
		"sect_id": str(Dictionary(ctx.get("sect", {})).get("id", "")),
		"choices": raw_choices,
	}
	return raw


# --- Internal Helpers ----------------------------------------------------------------------------

static func _is_pulse_record(t: Dictionary) -> bool:
	if str(t.get("hook", "")) != "":
		return false
	var k: String = str(t.get("kind", "pulse"))
	return k == "pulse"


func _templates_with_id(template_id: String) -> Array:
	var rec: Dictionary = get_template(template_id)
	return [] if rec.is_empty() else [rec]


func _pick_weighted(pool: Array, env: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	var weighted: Array = []
	for t in pool:
		var w: float = _EventConditions.effective_weight(t, env, _gd, _db)
		if w > 0.0:
			weighted.append({"rec": t, "weight": w})
	if weighted.is_empty():
		return pool[0]
	return RngUtils.weighted_pick(rng, weighted).rec


## Marks a person an event created with the season it joined the world (Power Rankings AC-PR-48: the season's batch,
## planned before the event, takes them only from the next season, so a reloaded game plans the same batch).
func _joined(pid: String, ctx: Dictionary) -> String:
	var rec: Dictionary = _db.get_record("people", pid)
	if not rec.is_empty():
		rec["joined_season"] = int(ctx.get("year", 0)) * int(_gd.cultivation_rules().seasons_per_year) + int(ctx.get("season", 0))
	return pid


func _bind_npc(spec: Dictionary, ctx: Dictionary, rng: RandomNumberGenerator, bound_npc_id: String = "") -> String:
	var mode: String = str(spec.get("mode", "none"))
	var root_id: String = str(Dictionary(ctx.get("player", {})).get("id", ""))
	var realm: int = clampi(int(Dictionary(ctx.get("player", {})).get("realm_index", 0)) + int(spec.get("realm_offset", 0)), 0, _gd.realms().size() - 1)
	var place_id: String = str(Dictionary(ctx.get("place", {})).get("id", ""))
	var sect_id: String = str(Dictionary(ctx.get("sect", {})).get("id", ""))
	match mode:
		"none", "":
			return ""
		"bound":
			if bound_npc_id == "":
				return "!"
			var brec: Dictionary = _db.get_record("people", bound_npc_id)
			if brec.is_empty() or not bool(brec.get("alive", false)) or str(brec.get("id", "")) == root_id:
				return "!"
			return bound_npc_id
		"new":
			return _joined(_builds.create_person(rng, {"realm_index": realm, "archetype": str(spec.get("archetype", "")), "location_id": place_id, "created_by": "event"}), ctx)
		"beast":
			return _joined(_builds.create_person(rng, {"realm_index": realm, "is_beast": true, "location_id": place_id, "created_by": "event"}), ctx)
		"existing_sect", "sect_mate":
			if sect_id == "":
				return "!"
			var mates: Array = _db.find("people", func(p):
				return bool(p.get("alive", false)) and str(p.get("id", "")) != root_id and not bool(p.get("is_beast", false)) and str(p.get("sect_id", "")) == sect_id)
			return str(RngUtils.pick(rng, mates).id) if not mates.is_empty() else "!"
		"existing_any", "known":
			var known: Array = _db.find("people", func(p):
				if not bool(p.get("alive", false)) or str(p.get("id", "")) == root_id or bool(p.get("is_beast", false)):
					return false
				if bool(p.get("met_player", false)) or int(p.get("attitude", 0)) != 0:
					return true
				return not _db.events_of(str(p.id)).is_empty())
			if known.is_empty():
				return "!"
			var pick: Dictionary = RngUtils.pick(rng, known)
			if mode == "existing_any" and place_id != "":
				pick["location_id"] = place_id
				_db.mark_hook_dirty(str(pick.id))   # NPC Relationships rule 15a: a đạo lữ may have moved
			return str(pick.id)
		"past_tie":
			var pt_cands: Array = _living_past_ties(ctx)
			if pt_cands.is_empty():
				return "!"
			var pick_pt: Dictionary = RngUtils.pick(rng, pt_cands)
			if place_id != "":
				pick_pt["location_id"] = place_id
				_db.mark_hook_dirty(str(pick_pt.id))
			return str(pick_pt.id)
		"cast_key":
			var ck: String = str(spec.get("key", spec.get("cast_key", "")))
			if ck == "":
				return "!"
			for p in _db.living():
				if str(p.get("cast_key", "")) == ck and bool(p.get("alive", false)) and str(p.get("id", "")) != root_id:
					return str(p.id)
			return "!"
		"flag":
			var fname: String = str(spec.get("flag", ""))
			if fname == "":
				return "!"
			var spy: int = int(_gd.cultivation_rules().get("seasons_per_year", 4))
			var now_s: int = int(ctx.get("now_season", int(ctx.get("year", 0)) * spy + int(ctx.get("season", 0))))
			var flagged: Array = []
			for p in _db.living():
				if str(p.get("id", "")) == root_id or bool(p.get("is_beast", false)):
					continue
				if _EventConditions.evaluate({"type": "has_flag", "scope": str(p.id), "flag": fname}, {"now_season": now_s}, _gd, _db):
					flagged.append(p)
			return str(RngUtils.pick(rng, flagged).id) if not flagged.is_empty() else "!"
	return ""


func _has_living_past_tie(ctx: Dictionary) -> bool:
	return not _living_past_ties(ctx).is_empty()


func _living_past_ties(ctx: Dictionary) -> Array:
	var out: Array = []
	var seen := {}
	for entry in Array(ctx.get("past_ties", [])):
		var pid: String = str(entry.get("id", "")) if entry is Dictionary else str(entry)
		if pid == "" or seen.has(pid):
			continue
		var prec: Dictionary = _db.get_record("people", pid)
		if not prec.is_empty() and bool(prec.get("alive", false)) and not bool(prec.get("is_player", false)) and not bool(prec.get("is_beast", false)):
			seen[pid] = true
			out.append(prec)
	return out


## Converts budget_frac ranges into amounts using the context budget.
func _amounts(effects: Array, ctx: Dictionary, rng: RandomNumberGenerator) -> Array:
	var b: Dictionary = Dictionary(ctx.get("budget", {}))
	var out: Array = []
	for fx in effects:
		if not (fx is Dictionary):
			continue
		var e: Dictionary = (fx as Dictionary).duplicate(true)
		if e.has("budget_frac"):
			var frac: float = RngUtils.range_f(rng, e.budget_frac)
			match str(e.get("type", "")):
				"linh_thach":
					e["amount"] = roundf(frac * float(b.get("linh_thach_max", 80)))
				"tu_vi":
					e["amount"] = roundf(frac * float(b.get("tu_vi_max", 100)))
			e.erase("budget_frac")
		out.append(e)
	return out


func _history_line(npc_id: String) -> String:
	if npc_id == "" or _db == null:
		return ""
	var events: Array = _db.events_of(npc_id).filter(func(e):
		return str(e.get("type", "")) != "hidden" and not bool(Dictionary(e.get("data", {})).get("secret", false)))
	if events.is_empty():
		return "sống ẩn dật"
	return str(events[-1].text).trim_suffix(".")


static func _sub(text: String, subs: Dictionary) -> String:
	var out: String = text
	for k in subs.keys():
		out = out.replace(k, str(subs[k]))
	return out
