class_name EventTemplateSource
extends RefCounted
## Offline event source: picks a template from events_templates.json that fits the
## place and the player, binds an NPC (new, sect-mate, anyone with a history, or a
## demon beast), fills the text from the world database and converts budget fractions
## into concrete amounts. Output goes through [EventValidator] like LLM output.
## Also the fallback whenever the LLM is unavailable or returns something invalid.
##
## Usage:
## [codeblock]
## var src := EventTemplateSource.new(gd, db, builds)
## var raw: Dictionary = src.generate(ctx, rng)       # {} if nothing fits
## var res: Dictionary = validator.normalize(raw, ctx, rng, raw.source)
## [/codeblock]

var _gd: GameData
var _db: WorldDB
var _builds: BuildGenerator


func _init(gd: GameData, db: WorldDB, builds: BuildGenerator) -> void:
	_gd = gd
	_db = db
	_builds = builds


## Templates eligible in this context.
func eligible(ctx: Dictionary) -> Array:
	var ptype: String = str(ctx.place.type)
	return _gd.event_templates().templates.filter(func(t):
		if str(t.get("hook", "")) != "":
			return false
		var types: Array = t.get("place_types", ["any"])
		if not (types.has("any") or types.has(ptype)):
			return false
		if bool(t.get("requires_sect", false)) and str(ctx.sect.id) == "":
			return false
		if int(t.get("requires_realm_min", 0)) > int(ctx.player.get("realm_index", 0)):
			return false
		if bool(t.get("requires_edge", false)) and not (bool(ctx.get("edge", false)) and int(ctx.get("co_duyen_left", 0)) > 0):
			return false
		if bool(t.get("requires_bottleneck", false)) and not bool(ctx.player.get("at_bottleneck", false)):
			return false
		if float(t.get("requires_tam_ma", 0)) > float(ctx.player.tam_ma):
			return false
		return true)


## Returns authored [code]on_talk[/code] scene templates eligible for [param npc] in [param ctx]
## (NPC Interaction & Dialogue #30 Rule 18, AC-NI-25). Does not alter random [method eligible] rolls.
func eligible_on_talk(ctx: Dictionary, npc: Dictionary) -> Array:
	if npc.is_empty():
		return []
	var cast_key: String = str(npc.get("cast_key", ""))
	var seen: Array = Array(npc.get("seen_scenes", []))
	var flags: Dictionary = InteractionRules.npc_flags(npc)
	var cur_band: String = InteractionRules.attitude_band(_gd, int(npc.get("attitude", 0)))
	var cur_rank: int = InteractionRules.band_rank(cur_band)
	return _gd.event_templates().templates.filter(func(t):
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
	var pool: Array = eligible_on_talk(ctx, npc) if template_id == "" else _gd.event_templates().templates.filter(func(t): return str(t.get("id", "")) == template_id)
	if pool.is_empty():
		return {}
	var t: Dictionary = RngUtils.weighted_pick(rng, pool)
	return _fill(t, ctx, str(npc.get("id", "")), rng)


## Generates a raw event, or {} if no template fits. [param template_id] forces one.
func generate(ctx: Dictionary, rng: RandomNumberGenerator, template_id: String = "") -> Dictionary:
	var pool: Array = eligible(ctx)
	if template_id != "":
		pool = _gd.event_templates().templates.filter(func(t): return t.id == template_id)
	for attempt in 6:
		if pool.is_empty():
			return {}
		var t: Dictionary = RngUtils.weighted_pick(rng, pool)
		var npc_id: String = _bind_npc(t.get("npc", {"mode": "none"}), ctx, rng)
		if npc_id == "!":
			pool.erase(t)
			continue
		return _fill(t, ctx, npc_id, rng)
	return {}


## Marks a person an event created with the season it joined the world (Power Rankings AC-PR-48: the season's batch,
## planned before the event, takes them only from the next season, so a reloaded game plans the same batch).
func _joined(pid: String, ctx: Dictionary) -> String:
	var rec: Dictionary = _db.get_record("people", pid)
	if not rec.is_empty():
		rec["joined_season"] = int(ctx.get("year", 0)) * int(_gd.cultivation_rules().seasons_per_year) + int(ctx.get("season", 0))
	return pid


func _bind_npc(spec: Dictionary, ctx: Dictionary, rng: RandomNumberGenerator) -> String:
	var mode: String = str(spec.get("mode", "none"))
	var realm: int = clampi(int(ctx.player.realm_index) + int(spec.get("realm_offset", 0)), 0, _gd.realms().size() - 1)
	match mode:
		"new":
			return _joined(_builds.create_person(rng, {"realm_index": realm, "archetype": str(spec.get("archetype", "")), "location_id": ctx.place.id, "created_by": "event"}), ctx)
		"beast":
			return _joined(_builds.create_person(rng, {"realm_index": realm, "is_beast": true, "location_id": ctx.place.id, "created_by": "event"}), ctx)
		"existing_sect":
			var mates: Array = _db.find("people", func(p): return p.alive and not p.get("is_player", false) and str(p.sect_id) == str(ctx.sect.id) and str(ctx.sect.id) != "")
			return str(RngUtils.pick(rng, mates).id) if not mates.is_empty() else "!"
		"existing_any":
			var known: Array = _db.find("people", func(p): return p.alive and not p.get("is_player", false) and not p.get("is_beast", false) and not _db.events_of(p.id).is_empty())
			if known.is_empty():
				return "!"
			var pick: Dictionary = RngUtils.pick(rng, known)
			pick["location_id"] = ctx.place.id
			_db.mark_hook_dirty(str(pick.id))   # NPC Relationships rule 15a: a đạo lữ may have moved
			return pick.id
	return ""


func _fill(t: Dictionary, ctx: Dictionary, npc_id: String, rng: RandomNumberGenerator) -> Dictionary:
	var npc: Dictionary = _db.get_record("people", npc_id)
	var subs := {
		"{player}": ctx.player.name, "{place}": ctx.place.name, "{region}": ctx.place.region,
		"{sect}": ctx.sect.name, "{npc}": npc.get("name", ""),
		"{npc_realm}": _gd.realm_label(int(npc.get("realm_index", 0)), int(npc.get("stage", 0))) if not npc.is_empty() else "",
		"{npc_history}": _history_line(npc_id),
	}
	var raw := {
		"source": "template:%s" % t.id,
		"template_id": str(t.id),
		"hook": str(t.get("hook", "")),
		"once": bool(t.get("once", false)),
		"situation": str(t.get("situation", "")),
		"mercy_choice": bool(t.get("mercy_choice", false)),
		"title": _sub(str(t.title), subs), "text": _sub(str(t.text), subs),
		"npc": {"id_resolved": npc_id} if npc_id != "" else null,
		"choices": [],
	}
	for c in t.choices:
		raw.choices.append({
			"label": _sub(str(c.label), subs),
			"check": c.get("check", {"type": "none"}),
			"always": _amounts(c.get("always", []), ctx, rng),
			"success": {"text": _sub(str(c.get("success", {}).get("text", "")), subs), "effects": _amounts(c.get("success", {}).get("effects", []), ctx, rng)},
			"failure": {"text": _sub(str(c.get("failure", c.get("success", {})).get("text", "")), subs), "effects": _amounts(c.get("failure", c.get("success", {})).get("effects", []), ctx, rng)},
		})
	return raw


## Converts budget_frac ranges into amounts using the context budget.
func _amounts(effects: Array, ctx: Dictionary, rng: RandomNumberGenerator) -> Array:
	var b: Dictionary = ctx.budget
	var out: Array = []
	for fx in effects:
		var e: Dictionary = fx.duplicate(true)
		if e.has("budget_frac"):
			var frac: float = RngUtils.range_f(rng, e.budget_frac)
			match str(e.type):
				"linh_thach":
					e["amount"] = roundf(frac * float(b.linh_thach_max))
				"tu_vi":
					e["amount"] = roundf(frac * float(b.tu_vi_max))
			e.erase("budget_frac")
		out.append(e)
	return out


func _history_line(npc_id: String) -> String:
	if npc_id == "":
		return ""
	var events: Array = _db.events_of(npc_id)
	if events.is_empty():
		return "sống ẩn dật"
	return str(events[-1].text).trim_suffix(".")


static func _sub(text: String, subs: Dictionary) -> String:
	var out: String = text
	for k in subs.keys():
		out = out.replace(k, str(subs[k]))
	return out
