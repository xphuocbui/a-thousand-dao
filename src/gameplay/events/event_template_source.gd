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


func _bind_npc(spec: Dictionary, ctx: Dictionary, rng: RandomNumberGenerator) -> String:
	var mode: String = str(spec.get("mode", "none"))
	var realm: int = clampi(int(ctx.player.realm_index) + int(spec.get("realm_offset", 0)), 0, _gd.realms().size() - 1)
	match mode:
		"new":
			return _builds.create_person(rng, {"realm_index": realm, "archetype": str(spec.get("archetype", "")), "location_id": ctx.place.id, "created_by": "event"})
		"beast":
			return _builds.create_person(rng, {"realm_index": realm, "is_beast": true, "location_id": ctx.place.id, "created_by": "event"})
		"existing_sect":
			var mates: Array = _db.find("people", func(p): return p.alive and not p.get("is_player", false) and str(p.sect_id) == str(ctx.sect.id) and str(ctx.sect.id) != "")
			return str(RngUtils.pick(rng, mates).id) if not mates.is_empty() else "!"
		"existing_any":
			var known: Array = _db.find("people", func(p): return p.alive and not p.get("is_player", false) and not p.get("is_beast", false) and not _db.events_of(p.id).is_empty())
			if known.is_empty():
				return "!"
			var pick: Dictionary = RngUtils.pick(rng, known)
			pick["location_id"] = ctx.place.id
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
