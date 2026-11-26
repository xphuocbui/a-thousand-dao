class_name FighterProfileLoader
extends RefCounted
## Builds a [FighterProfile] from a fighter record in the sim's [code]Build[/code] format, fully resolved (every
## field present), as [code]tools/design/combat_sim/parity_export.py[/code] writes them. ADR-0001: the early form of
## [code]FighterCompiler.from_data[/code], used by the parity suite and for data-built enemies.
##
## Never silent: a field this engine slice has not ported, set to anything but its neutral value, is an error naming
## the field, so a fixture cannot pass by skipping a rule. Unknown fields are errors too.
##
## Usage:
## [codeblock]
## var loader := FighterProfileLoader.new(k)
## var p := loader.from_sim_build(record, "t1_mirror_qr.a")
## if not loader.errors.is_empty():
##     push_error("\n".join(loader.errors))
## [/codeblock]

## Damage types and elements the engine knows (one copy, on CombatConstants).
const DTYPES := CombatConstants.DTYPES
const ELEMENTS := CombatConstants.ELEMENTS

## The largest added Soul part an art may carry (R11; the sim's validate()).
const SOUL_PART_MAX := 0.30
## Build fields slices 1-3 read, as float (the profile field when it differs).
const BUILD_FLOATS := {
	"M": "m", "n_body": "", "n_qi": "", "ward_pts": "", "drain": "", "block": "", "regen_bonus": "", "hregen": "",
	"cost_red": "", "gain_on_hit": "", "leech_qi": "", "leech_hp": "", "hp_pay": "", "healing": "",
	"art_speed_pct": "", "basic_speed_pct": "", "opening_haste_pct": "", "basic_coef_add": "", "ward_layer": "",
	"body_pts": "", "body_block": "", "bs_mult": "", "ward_bill_pct": "", "reserved": "",
	"crit": "", "crit_mult": "", "evade": "", "acc": "", "body_shield": "",
	"cleanse_cost": "", "cleanse_share": "", "divine_sense": "", "soul_res": "", "x_soul": "", "tam_ma": "",
	"timer_resist": "", "stage_mult": "",
}
## Build fields with no effect until a later slice ports what reads them (accepted, not used yet): refusals with
## the Down step (slice 4b).
const BUILD_NEUTRAL := ["name", "tags"]
## Build fields a later slice ports; they must be zero or empty here.
const BUILD_NOT_PORTED := [
]
## Art fields slices 1-3 read.
const ART_PORTED := [
	"name", "c", "cost", "cd", "element", "dtype", "m_mult", "split", "charges", "heal", "qi_restore", "hp_cost",
	"bypass", "tags", "pool", "convert", "buff", "debuff", "cleanse", "statuses", "soul_pct", "soul_part", "guards",
	"group", "steps", "empower", "escape",
]
const ART_NEUTRAL := []
## Art fields added after the records were resolved: absent means the default (world-depth Stage 5: escape 0, not an
## escape art), so earlier build files and the compile cases stay as they were.
const ART_OPTIONAL := ["escape"]
const ART_NOT_PORTED := [
]

## Problems found by the last calls; empty when every profile loaded.
var errors: PackedStringArray = []
## Things that load but will not work as written (an undefined counter read reads 0); see EffectCompiler.warnings.
var warnings: PackedStringArray = []
var _k: CombatConstants
## While loading one fighter: its Effect compiler and counters, so its arts' guards compile against them.
var _compiler: EffectCompiler
var _counters_for_arts: Dictionary = {}
## Steps whose art is built once the base art is complete: [base ArtDef, StepDef, ArtOverride].
var _pending_steps: Array = []


## [param k] supplies defaults that live in the constants (a companion's cooldown).
func _init(k: CombatConstants) -> void:
	_k = k


## Returns the profile, or null with [member errors] naming each problem. [param where] prefixes the messages.
func from_sim_build(d: Dictionary, where: String) -> FighterProfile:
	var n0: int = errors.size()
	var p := FighterProfile.new()
	for key in d:
		var name: String = str(key)
		if BUILD_FLOATS.has(name) or name in ["realm", "resist", "arts", "companions", "shields", "wards", "purity",
				"stack_eff", "stack_dur", "cleanse_pulse", "effects", "counters", "layers", "boss", "states", "refusals",
			"stack_alias", "pill"] \
				or name in BUILD_NEUTRAL:
			continue
		if name in BUILD_NOT_PORTED:
			if not _is_neutral(d[key]):
				errors.append("%s: %s = %s is not ported yet (a later slice)" % [where, name, str(d[key])])
			continue
		errors.append("%s: unknown field %s" % [where, name])
	for key in BUILD_FLOATS:
		if not d.has(key):
			errors.append("%s: %s is missing (fighter records must be fully resolved)" % [where, key])
			continue
		var field: String = BUILD_FLOATS[key] if BUILD_FLOATS[key] != "" else key
		p.set(field, float(d[key]))
	p.id = str(d.get("name", where))
	p.realm = int(d.get("realm", -1))
	if p.realm < 0 or p.realm > 4:
		errors.append("%s: realm %s is not 0-4" % [where, str(d.get("realm"))])
	var resist: Dictionary = d.get("resist", {})
	for t in resist:
		if not (str(t) in DTYPES):
			errors.append("%s: resist type %s is not one of %s" % [where, str(t), str(DTYPES)])
		p.resist[StringName(str(t))] = float(resist[t])
	p.boss = bool(d.get("boss", false))
	p.refusals = int(d.get("refusals", 1))
	for st in d.get("states", []):
		if not (st is Dictionary) or str(st.get("id", "")) == "":
			errors.append("%s: a state has no id" % where)
			continue
		var mods: Dictionary = st.get("mods", {})
		if absf(float(mods.get("cost_red", 0.0))) > 1.0:
			errors.append("%s: state %s: cost_red %s is a share of the cost (0.1 = 10 %%), not points" % [where, str(st.id), str(mods.cost_red)])
		for mk in mods:
			if not (str(mk) in _k.mod_keys):
				errors.append("%s: state %s: mod key %s is not in the engine" % [where, str(st.id), str(mk)])
		p.states[str(st.id)] = st
		if bool(st.get("start", false)) and p.state_start == "":
			p.state_start = str(st.id)
	if d.get("layers") is Array:
		p.layers = PackedFloat64Array(d.layers)
	if d.get("pill") is Dictionary:   # a prepared pill (world-depth Stage 5, smoke only)
		p.pill = (d.pill as Dictionary).duplicate()
	for c in d.get("counters", []):
		if not (c is Dictionary) or str(c.get("id", "")) == "":
			errors.append("%s: a counter has no id" % where)
			continue
		p.counter_def[str(c.id)] = c
	var eff_comp := EffectCompiler.new(_k)
	for i in (d.get("effects", []) as Array).size():
		var e: EffectDef = eff_comp.compile(d.effects[i], "%s.effects[%d]" % [where, i], p.counter_def)
		if e != null:
			p.effects.append(e)
	_counters_for_arts = p.counter_def
	_compiler = eff_comp
	for i in (d.get("arts", []) as Array).size():
		var art: ArtDef = _art(d.arts[i], "%s.arts[%d]" % [where, i])
		if art != null:
			p.arts.append(art)
	for i in (d.get("companions", []) as Array).size():
		var comp: FighterProfile.Companion = _companion(d.companions[i], "%s.companions[%d]" % [where, i])
		if comp != null:
			p.companions.append(comp)
	p.cleanse_pulse = int(d.get("cleanse_pulse", 0))
	for key in ["purity", "stack_eff", "stack_dur"]:
		var src: Dictionary = d.get(key, {})
		var dst: Dictionary = p.get(key)
		for kk in src:
			dst[str(kk)] = float(src[kk])
	var alias_src: Dictionary = d.get("stack_alias", {}) if d.get("stack_alias") is Dictionary else {}
	for el in alias_src:
		var listed: Array[String] = []
		for el2 in alias_src[el]:
			listed.append(str(el2))
			if not (str(el2) in ELEMENTS):
				errors.append("%s: stack_alias element %s is not one of %s" % [where, str(el2), str(ELEMENTS)])
		if not (str(el) in ELEMENTS):
			errors.append("%s: stack_alias element %s is not one of %s" % [where, str(el), str(ELEMENTS)])
		p.stack_alias[str(el)] = listed
	for el in p.purity:
		if not (str(el) in ELEMENTS):
			errors.append("%s: purity element %s is not one of %s" % [where, str(el), str(ELEMENTS)])
	for i in (d.get("shields", []) as Array).size():
		p.shields.append(_shield(d.shields[i], "%s.shields[%d]" % [where, i]))
	for i in (d.get("wards", []) as Array).size():
		p.wards.append(_ward(d.wards[i], "%s.wards[%d]" % [where, i]))
	errors.append_array(eff_comp.errors)
	warnings.append_array(eff_comp.warnings)
	_compiler = null
	_index_effects(p)
	for e in p.effects:
		for a in e.actions:
			if a.verb == "state" and a.arg is Dictionary and a.arg.get("set") != null and not p.states.has(str(a.arg.set)):
				errors.append("%s: Effect %s: state %s is not defined" % [where, e.id, str(a.arg.set)])
	return p if errors.size() == n0 else null


## The profile's Effect indexes: always-on mod entries per stat key, and listeners per event, both in record order.
func _index_effects(p: FighterProfile) -> void:
	var mod_keys := {}
	for x in _k.mod_keys:
		mod_keys[str(x)] = true
	for e in p.effects:
		if e.on == "always":
			for a in e.actions:
				if a.verb != "mod" or not (a.arg is Dictionary):
					continue
				for key in a.arg:
					if mod_keys.has(str(key)):
						if not p.always_by_key.has(str(key)):
							p.always_by_key[str(key)] = []
						p.always_by_key[str(key)].append([e, float(a.arg[key]), a.arg])
		else:
			if not p.listeners.has(e.on):
				p.listeners[e.on] = []
			p.listeners[e.on].append(e)


## A status an art applies, from the sim's spec dict. Internal Injury is an Effect's stored damage (the Effect
## slice).
func _status(d: Dictionary, where: String) -> StatusSpec:
	var spec := StatusSpec.new()
	spec.id = str(d.get("id", ""))
	if spec.id != "internal_injury" and not _k.status.has(spec.id):
		errors.append("%s: status %s is not in the Status Catalogue" % [where, spec.id])
		return null
	for key in d:
		var name: String = str(key)
		if name in ["id", "stacks", "chance"]:
			continue
		if name in ["dur", "cap", "layer", "tag", "crossing", "no_lockout", "every"]:
			spec.extra[name] = d[key]
		else:
			errors.append("%s: unknown status field %s" % [where, name])
	spec.stacks = int(d.get("stacks", 1))
	spec.chance = float(d.get("chance", 1.0))
	return spec


func _cmp() -> EffectCompiler:
	if _compiler == null:
		_compiler = EffectCompiler.new(_k)
	return _compiler


func _pay(actions: Array, where: String) -> Array[EffectDef.ActionDef]:
	var out: Array[EffectDef.ActionDef] = []
	var e: EffectDef = _cmp().compile({"id": "pay", "on": "art_fired", "do": actions}, where, _counters_for_arts)
	if e != null:
		out = e.actions
	return out


## The pseudo Effect a step's or empower's pay runs as (the sim's {"id": name-step, "on": "art_fired"}).
func _pseudo(id: String) -> EffectDef:
	var e := EffectDef.new()
	e.id = id
	e.on = "art_fired"
	return e


## Compiles a step's or empower's override. Keys the sim's override() ignores are refused here, so authored
## content never silently does nothing ([param skip] are its unlock/if and pay keys).
func _override(spec: Dictionary, where: String, skip: Array) -> ArtOverride:
	var ov := ArtOverride.new()
	for key in spec:
		var name: String = str(key)
		if name in skip:
			continue
		if name == "c_mult":
			ov.has_c_mult = true
			ov.c_mult = float(spec[key])
		elif name == "add_statuses":
			for j in (spec[key] as Array).size():
				var st: StatusSpec = _status(spec[key][j], "%s.add_statuses[%d]" % [where, j])
				if st != null:
					ov.add_statuses.append(st)
		elif ArtOverride.FIELDS.has(name):
			ov.keys.append(name)
			if name == "statuses":
				var sts: Array[StatusSpec] = []
				for j in (spec[key] as Array).size():
					var st2: StatusSpec = _status(spec[key][j], "%s.statuses[%d]" % [where, j])
					if st2 != null:
						sts.append(st2)
				ov.values[name] = sts
			else:
				ov.values[name] = spec[key]
			if name in ["dtype", "kind"] and not (str(spec[key]) in DTYPES):
				errors.append("%s: dtype %s is not one of %s" % [where, str(spec[key]), str(DTYPES)])
		else:
			errors.append("%s: field %s is not run by either engine (the sim's override ignores it)" % [where, name])
	return ov


## A ward shield from the sim's Shield record (size, body, standing, stops, pieces, floor).
func _shield(d: Dictionary, where: String) -> WardShieldDef:
	for key in d:
		if not (str(key) in ["size", "body", "standing", "stops", "pieces", "floor"]):
			errors.append("%s: unknown shield field %s" % [where, str(key)])
	var sd := WardShieldDef.new()
	sd.size = float(d.get("size", 0.0))
	sd.body = bool(d.get("body", false))
	sd.standing = bool(d.get("standing", true))
	sd.pieces = int(d.get("pieces", 1))
	sd.floor_share = float(d.get("floor", 0.0))
	var stops: Dictionary = d.get("stops", {})
	for t in stops:
		if not (str(t) in DTYPES or str(t) == "ticks"):
			errors.append("%s: stops type %s is not a damage type or ticks" % [where, str(t)])
		sd.stops[StringName(str(t))] = float(stops[t])
	return sd


## An extra ward from the sim's ward dict (model, payload, block, shield, cost, drain, cooldown, up, evade).
func _ward(d: Dictionary, where: String) -> ExtraWardDef:
	const MODELS := {"drain": ExtraWardDef.Model.DRAIN, "per_hit": ExtraWardDef.Model.PER_HIT,
		"reserved": ExtraWardDef.Model.RESERVED, "cast": ExtraWardDef.Model.CAST}
	for key in d:
		if not (str(key) in ["id", "name", "source", "own_slot", "model", "payload", "block", "shield", "cost", "drain",
				"cooldown", "up", "evade"]):
			errors.append("%s: unknown ward field %s" % [where, str(key)])
	var w := ExtraWardDef.new()
	w.id = str(d.get("id", d.get("name", where)))
	var model: String = str(d.get("model", ""))
	if not MODELS.has(model):
		errors.append("%s: ward model %s is not drain, per_hit, reserved or cast" % [where, model])
	else:
		w.model = MODELS[model]
	var payload: Dictionary = d.get("payload", {})
	for t in payload:
		if not (str(t) in DTYPES or str(t) == "all"):
			errors.append("%s: payload type %s is not a damage type or all" % [where, str(t)])
		w.payload[StringName(str(t))] = float(payload[t])
	w.block = float(d.get("block", 0.0))
	w.shield = float(d.get("shield", 0.0))
	w.cost = float(d.get("cost", 0.0))
	w.drain = float(d.get("drain", 0.0))
	w.cooldown = float(d.get("cooldown", 5.0))
	w.up = float(d.get("up", 3.0))
	w.evade = float(d.get("evade", 0.0))
	return w


func _art(d: Dictionary, where: String) -> ArtDef:
	for key in d:
		var name: String = str(key)
		if name in ART_PORTED or name in ART_NEUTRAL:
			continue
		if name in ART_NOT_PORTED:
			if not _is_neutral(d[key]):
				errors.append("%s: %s = %s is not ported yet (a later slice)" % [where, name, str(d[key])])
			continue
		errors.append("%s: unknown art field %s" % [where, name])
	for key in ART_PORTED:
		if not d.has(key) and not ART_OPTIONAL.has(key):
			errors.append("%s: %s is missing (art records must be fully resolved)" % [where, key])
	if not (str(d.get("pool", "qi")) in ["qi", "tam_ma", "than_thuc"]):
		errors.append("%s: pool %s is not qi, tam_ma or than_thuc" % [where, str(d.get("pool"))])
	var a := ArtDef.new()
	a.id = StringName(str(d.get("name", "")))
	a.c = float(d.get("c", 0.0))
	a.cost = float(d.get("cost", 0.0))
	a.cd = float(d.get("cd", 0.0))
	a.element = StringName(str(d.get("element", "")))
	a.dtype = StringName(str(d.get("dtype", "phys")))
	a.m_mult = float(d.get("m_mult", 1.0))
	a.split = PackedFloat64Array(d.get("split", []))
	a.charges = int(d.get("charges", 1))
	a.heal = float(d.get("heal", 0.0))
	a.qi_restore = float(d.get("qi_restore", 0.0))
	a.hp_cost = float(d.get("hp_cost", 0.0))
	a.bypass = float(d.get("bypass", 0.0))
	a.pool = StringName(str(d.get("pool", "qi")))
	a.group = str(d.get("group", ""))
	if not (d.get("guards", []) as Array).is_empty():
		var gc: EffectCompiler = _compiler if _compiler != null else EffectCompiler.new(_k)
		a.guards = gc.compile_conds(d.guards, where + ".guards", _counters_for_arts)
		if gc != _compiler:
			errors.append_array(gc.errors)
	var bf: Array = d.get("buff", [])
	if not bf.is_empty():
		a.buff_n = float(bf[0])
		a.buff_dur = -1.0 if bf[1] == null else float(bf[1])
	var dbf: Array = d.get("debuff", [])
	if not dbf.is_empty():
		a.debuff_n = float(dbf[0])
		a.debuff_dur = -1.0 if dbf[1] == null else float(dbf[1])
	a.cleanse = int(d.get("cleanse", 0))
	a.soul_pct = float(d.get("soul_pct", 0.0))
	a.soul_part = float(d.get("soul_part", 0.0))
	a.escape = float(d.get("escape", 0.0))
	if a.soul_part > SOUL_PART_MAX + 1e-9:
		errors.append("%s: added Soul part %s is over %s (R11)" % [where, str(a.soul_part), str(SOUL_PART_MAX)])
	for j in (d.get("statuses", []) as Array).size():
		var spec: StatusSpec = _status(d.statuses[j], "%s.statuses[%d]" % [where, j])
		if spec != null:
			a.statuses.append(spec)
	for j in (d.get("steps", []) as Array).size():
		var sd := ArtOverride.StepDef.new()
		var spec: Dictionary = d.steps[j]
		var sw: String = "%s.steps[%d]" % [where, j]
		sd.conds = _cmp().compile_conds(spec.get("unlock", []), sw, _counters_for_arts)
		sd.pay = _pay(spec.get("pay", []), sw)
		sd.pay_effect = _pseudo(str(d.get("name", "")) + "-step")
		sd.hp_cost = float(spec.get("hp_cost", 0.0))
		sd.art = null
		_pending_steps.append([a, sd, _override(spec, sw, ["unlock", "pay", "hp_cost"])])
		a.steps.append(sd)
	for j in (d.get("empower", []) as Array).size():
		var ed := ArtOverride.EmpowerDef.new()
		var espec: Dictionary = d.empower[j]
		var ew: String = "%s.empower[%d]" % [where, j]
		ed.conds = _cmp().compile_conds(espec.get("if", []), ew, _counters_for_arts)
		ed.pay = _pay(espec.get("pay", []), ew)
		ed.pay_effect = _pseudo(str(d.get("name", "")) + "-empower")
		ed.ov = _override(espec, ew, ["if", "pay"])
		a.empower.append(ed)
	var conv: Dictionary = d.get("convert", {})
	if float(conv.get("share", 0.0)) != 0.0:
		a.convert_to = StringName(str(conv.get("to", "")))
		a.convert_share = float(conv.share)
		if not (str(a.convert_to) in DTYPES):
			errors.append("%s: convert to %s is not one of %s" % [where, str(a.convert_to), str(DTYPES)])
	for t in d.get("tags", []):
		a.tags.append(StringName(str(t)))
		a.tags_s.append(str(t))
	a.ctx = {"dtype": str(a.dtype), "element": str(a.element), "tags": a.tags_s, "kind": "art", "art_id": str(a.id)}
	# a step's art is the base art with the step applied (the base art is complete only now)
	for pend in _pending_steps:
		if pend[0] == a:
			pend[1].art = (pend[2] as ArtOverride).apply(a)
	_pending_steps = _pending_steps.filter(func(x): return x[0] != a)
	if not (str(a.dtype) in DTYPES):
		errors.append("%s: dtype %s is not one of %s" % [where, str(a.dtype), str(DTYPES)])
	if not (str(a.element) in ELEMENTS):
		errors.append("%s: element %s is not one of %s" % [where, str(a.element), str(ELEMENTS)])
	if a.charges < 1:
		errors.append("%s: charges %d must be at least 1" % [where, a.charges])
	return a


func _companion(d: Dictionary, where: String) -> FighterProfile.Companion:
	for key in d:
		if not (str(key) in ["c", "dtype", "cd"]):
			errors.append("%s: unknown companion field %s" % [where, str(key)])
	var comp := FighterProfile.Companion.new()
	comp.c = float(d.get("c", 0.0))
	comp.dtype = StringName(str(d.get("dtype", "phys")))
	comp.cd = float(d.get("cd", _k.basic_cooldown))
	if not (str(comp.dtype) in DTYPES):
		errors.append("%s: dtype %s is not one of %s" % [where, str(comp.dtype), str(DTYPES)])
	return comp


## True for a field's neutral value: 0, false, null, "" or an empty list or dictionary.
static func _is_neutral(v: Variant) -> bool:
	match typeof(v):
		TYPE_NIL:
			return true
		TYPE_BOOL:
			return not v
		TYPE_INT, TYPE_FLOAT:
			return v == 0
		TYPE_STRING, TYPE_STRING_NAME:
			return str(v) == ""
		TYPE_ARRAY, TYPE_DICTIONARY:
			return v.is_empty()
	return false
