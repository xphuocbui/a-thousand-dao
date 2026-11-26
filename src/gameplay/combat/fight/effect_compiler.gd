class_name EffectCompiler
extends RefCounted
## Compiles Effect records into [EffectDef]s (ADR-0001 decision 3) and validates them as the sim's validate() does:
## an unknown event, action, mod key, op, damage type, element, readable, status or counter stops the load, never
## silently matching nothing. Actions, events and readables a later slice ports are refused by name.
##
## Usage:
## [codeblock]
## var c := EffectCompiler.new(k)
## var e: EffectDef = c.compile(record, "fighter.effects[0]", counter_ids)
## if not c.errors.is_empty(): push_error("\n".join(c.errors))
## [/codeblock]

## Events nothing raises yet (none since slice 5).
const EVENTS_LATER := []
const OPS := ["<=", ">=", "<", ">", "=="]
## Readables with no parameter, on a side.
const SIDE_READS := ["hp_share", "hp_missing_share", "qi_share", "qi_missing_share", "distinct_statuses", "fired",
	"curses", "ward_paid", "body_shield_share", "boss", "tam_ma", "state.any", "buff_elements", "evade", "since_hit",
	"hp_max_lead", "composed", "composed_time", "pressing", "foe_pressed", "since_act", "field_up", "broken", "wounded"]
## Filter and mod-argument keys that are not mod keys.
const FILTER_KEYS := ["for", "dtype", "element", "tags", "kind", "stack", "status", "art_id", "not_tags", "is_crit", "source"]

var errors: PackedStringArray = []
## Records that compile but will not do what they say in this fighter: a read of a counter nothing in the fighter
## defines reads 0, as in the sim (an art whose engine comes from another piece the fighter does not have).
var warnings: PackedStringArray = []
var _k: CombatConstants
var _events: Dictionary = {}
var _alias: Dictionary = {}
var _mod_keys: Dictionary = {}
var _actions: Dictionary = {}


## [param k] supplies the vocabulary (EVENTS, MOD_KEYS, ACTIONS) and the Status Catalogue.
func _init(k: CombatConstants) -> void:
	_k = k
	for x in k.events:
		_events[str(x)] = true
	_alias = k.event_alias
	for x in k.mod_keys:
		_mod_keys[str(x)] = true
	for x in k.actions:
		_actions[str(x)] = true


## Compiles one record. Returns null with [member errors] naming each problem. [param counters] holds the side's
## counter ids, so a read or action naming another counter is refused.
func compile(d: Dictionary, where: String, counters: Dictionary) -> EffectDef:
	var n0: int = errors.size()
	var e := EffectDef.new()
	e.id = str(d.get("id", ""))
	if e.id == "":
		errors.append("%s: an Effect has no id" % where)
		return null
	var w: String = "%s (%s)" % [where, e.id]
	for key in d:
		if not (str(key) in ["id", "on", "filter", "if", "scale", "limit", "chance", "held", "do", "name", "text", "source"]):
			errors.append("%s: unknown Effect field %s" % [w, str(key)])
	e.on = str(d.get("on", ""))
	e.on = str(_alias.get(e.on, e.on))   # batch_expired is batch_ended, healed is heal_restored
	if not _events.has(e.on):
		errors.append("%s: event %s is not in the engine" % [w, e.on])
	elif e.on in EVENTS_LATER:
		errors.append("%s: event %s is not ported yet (a later slice)" % [w, e.on])
	e.filter = d.get("filter", {}) if d.get("filter") is Dictionary else {}
	_check_filter(e.filter, w, "filter")
	for c in d.get("if", []):
		var cd: EffectDef.CondDef = _cond(c, w, counters)
		if cd != null:
			e.conds.append(cd)
	if d.get("scale") is Dictionary:
		var sc: Dictionary = d.scale
		e.scale = EffectDef.ScaleDef.new()
		e.scale.read = _read(str(sc.get("read", "")), w, counters)
		e.scale.per = float(sc.get("per", 1))
		e.scale.do_floor = bool(sc.get("floor", true))
		if sc.get("cap") != null:
			e.scale.has_cap = true
			e.scale.cap = float(sc.cap)
	var lim: Dictionary = d.get("limit", {}) if d.get("limit") is Dictionary else {}
	if lim.has("per_fight"):
		e.per_fight = int(lim.per_fight)
	if lim.has("per_pulse"):
		e.per_pulse = int(lim.per_pulse)
	if lim.has("cooldown"):
		e.cooldown = float(lim.cooldown)
	if lim.has("per_firing"):
		e.per_firing = int(lim.per_firing)
	if lim.has("scale_per_pulse"):
		e.scale_per_pulse = float(lim.scale_per_pulse)
	e.chance = float(d.get("chance", 1.0))
	if d.get("held") is Dictionary:
		e.held = true
		e.held_until = str(d.held.get("until", ""))
		if d.held.get("cap") != null:
			e.held_cap = float(d.held.cap)
	for a in d.get("do", []):
		var ad: EffectDef.ActionDef = _action(a, w, counters)
		if ad != null:
			e.actions.append(ad)
	return e if errors.size() == n0 else null


func _action(a: Variant, w: String, counters: Dictionary) -> EffectDef.ActionDef:
	if not (a is Dictionary) or (a as Dictionary).size() != 1:
		errors.append("%s: one verb per action, got %s" % [w, str(a)])
		return null
	var verb: String = str((a as Dictionary).keys()[0])
	var ad := EffectDef.ActionDef.new()
	ad.verb = verb
	ad.arg = a[verb]
	if verb != "cull" and not _actions.has(verb):   # cull is read by the Down step, as in the sim
		errors.append("%s: action %s is not in the engine" % [w, verb])
		return null
	var arg: Dictionary = ad.arg if ad.arg is Dictionary else {}
	match verb:
		"mod":
			_check_filter(arg, w, "mod")
			if absf(float(arg.get("cost_red", 0.0))) > 1.0:
				errors.append("%s: cost_red %s is a share of the cost (0.1 = 10 %%), not points" % [w, str(arg.cost_red)])
			for key in arg:
				if not _mod_keys.has(str(key)) and not (str(key) in FILTER_KEYS):
					errors.append("%s: mod key %s is not in the engine" % [w, str(key)])
		"counter":
			if not counters.has(str(arg.get("id", ""))):
				errors.append("%s: counter %s is not defined" % [w, str(arg.get("id"))])
		"consume":
			for t in arg.get("then", []):
				var sub: EffectDef.ActionDef = _action(t, w, counters)
				if sub != null:
					ad.then.append(sub)
		"status":
			var sid: String = str(arg.get("id", ""))
			if sid != "internal_injury" and not _k.status.has(sid):
				errors.append("%s: status %s is not in the Status Catalogue" % [w, sid])
		"stacks":
			if not (str(arg.get("el", "")) in CombatConstants.ELEMENTS):
				errors.append("%s: stacks element %s is not an element" % [w, str(arg.get("el"))])
		"emit":
			if not _events.has(str(arg.get("event", ""))):
				errors.append("%s: emit event %s is not in the engine" % [w, str(arg.get("event"))])
		"free_hit", "self_hit":
			var dt: String = str(arg.get("dtype", "phys"))
			if not (dt in CombatConstants.DTYPES or (verb == "free_hit" and dt == "same")):
				errors.append("%s: %s dtype %s is not a damage type" % [w, verb, dt])
	return ad


func _check_filter(filt: Dictionary, w: String, where: String) -> void:
	if filt.has("dtype") and not (str(filt.dtype) in CombatConstants.DTYPES):
		errors.append("%s: %s dtype %s is not one of %s" % [w, where, str(filt.dtype), str(CombatConstants.DTYPES)])
	if filt.has("element") and not (str(filt.element) in CombatConstants.ELEMENTS):
		errors.append("%s: %s element %s is not one of %s" % [w, where, str(filt.element), str(CombatConstants.ELEMENTS)])


## Compiles a list of conditions (an art's guards). Problems go to [member errors].
func compile_conds(conds: Array, where: String, counters: Dictionary) -> Array[EffectDef.CondDef]:
	var out: Array[EffectDef.CondDef] = []
	for c in conds:
		var cd: EffectDef.CondDef = _cond(c, where, counters)
		if cd != null:
			out.append(cd)
	return out


func _cond(c: Variant, w: String, counters: Dictionary) -> EffectDef.CondDef:
	if not (c is Dictionary):
		errors.append("%s: a condition is not an object: %s" % [w, str(c)])
		return null
	var cd := EffectDef.CondDef.new()
	if c.has("any"):
		cd.is_any = true
		for x in c.any:
			var sub: EffectDef.CondDef = _cond(x, w, counters)
			if sub != null:
				cd.any.append(sub)
		return cd
	cd.read = _read(str(c.get("read", "")), w, counters)
	cd.op = str(c.get("op", ">="))
	if not (cd.op in OPS):
		errors.append("%s: unknown op %s" % [w, cd.op])
	cd.value = float(c.get("value", 0))
	return cd


## Parses a readable (Effects rule 5) once. Unknown keys, elements, statuses and counters are errors.
func _read(key: String, w: String, counters: Dictionary) -> EffectDef.ReadDef:
	var r := EffectDef.ReadDef.new()
	if key == "time" or key.begins_with("event."):
		r.side = 2
		r.key = "time" if key == "time" else "event"
		r.param = key.trim_prefix("event.")
		return r
	if key.begins_with("tag."):   # a kept request tag (tribulation; Combat rule 12, AC-CB-104): no side
		r.side = 2
		r.key = "tag"
		r.param = key.substr(4)
		return r
	if key.begins_with("cycle."):   # the pulse index modulo n: no side
		r.side = 2
		r.key = "cycle"
		r.param = key.substr(6)
		r.window_ms = int(r.param) if r.param.is_valid_int() else 0
		if r.window_ms < 1:
			errors.append("%s: read %s: cycle.<n> needs a whole n of at least 1" % [w, key])
		return r
	var dot: int = key.find(".")
	var side: String = key.substr(0, dot) if dot >= 0 else ""
	if side != "own" and side != "foe":
		errors.append("%s: unknown readable %s" % [w, key])
		return r
	r.side = 0 if side == "own" else 1
	var k: String = key.substr(dot + 1)
	r.key = k
	if k in SIDE_READS:
		return r
	for pre in ["buff.", "debuff.", "status.", "counter.", "state.", "since.", "step."]:
		if k.begins_with(pre):
			r.key = pre.trim_suffix(".")
			r.param = k.substr(pre.length())
			if pre in ["buff.", "debuff."] and (r.param == "" or not (r.param in CombatConstants.ELEMENTS)):
				errors.append("%s: read %s: %s is not an element" % [w, key, r.param])
			if pre == "status." and not _k.status.has(r.param) and r.param != "internal_injury":
				errors.append("%s: read %s: %s is not a status" % [w, key, r.param])
			if pre == "counter." and not counters.has(r.param):
				# the sim reads an undefined counter as 0 (engine.py read()); a write to one is still an error
				warnings.append("%s: reads counter %s, which nothing in this fighter builds (reads 0)" % [w, r.param])
			return r
	if k.begins_with("lost_last."):   # own.lost_last.<hp|qi>.<seconds> (2026-11-26)
		var lp: PackedStringArray = k.split(".")
		r.key = "lost_last"
		if lp.size() != 3 or not (lp[1] in ["hp", "qi"]) or not lp[2].is_valid_float():
			errors.append("%s: read %s: lost_last.<hp|qi>.<seconds>" % [w, key])
			return r
		r.param = lp[1]
		r.window_ms = CombatConstants.ms(float(lp[2]))
		return r
	for pre_h in ["counter_hours.", "counter_this_hour."]:   # a charge counter's fight hours (2026-11-26)
		if k.begins_with(pre_h):
			r.key = pre_h.trim_suffix(".")
			r.param = k.substr(pre_h.length())
			return r
	if k.begins_with("fired_within."):
		var parts: PackedStringArray = k.split(".")
		r.key = "fired_within"
		if parts.size() < 3 or not (parts[2] in ["all", "tag", "group", "art"]):
			errors.append("%s: read %s: fired_within.<seconds>.<all|tag|group|art>[.<value>]" % [w, key])
			return r
		r.window_ms = CombatConstants.ms(float(parts[1]))
		r.what = parts[2]
		r.param = ".".join(parts.slice(3))
		return r
	errors.append("%s: unknown readable %s" % [w, key])
	return r
