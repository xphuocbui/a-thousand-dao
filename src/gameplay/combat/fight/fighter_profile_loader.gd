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

## Damage types and elements the engine knows (the sim's DTYPES and ELEMENTS).
const DTYPES := ["phys", "elem", "fire", "cold", "lightning", "force", "chaos", "soul"]
const ELEMENTS := ["", "fire", "water", "earth", "metal", "wood", "ice", "thunder", "wind"]

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
	"timer_resist": "",
}
## Build fields with no effect until the Effect slice ports what reads them (accepted, not used yet): refusals
## with refuse_down Effects; layers with layer mods.
const BUILD_NEUTRAL := ["name", "layers", "refusals", "boss", "tags"]
## Build fields a later slice ports; they must be zero or empty here.
const BUILD_NOT_PORTED := [
	"effects", "counters", "states",
]
## Art fields slices 1-3 read.
const ART_PORTED := [
	"name", "c", "cost", "cd", "element", "dtype", "m_mult", "split", "charges", "heal", "qi_restore", "hp_cost",
	"bypass", "tags", "pool", "convert", "buff", "debuff", "cleanse", "statuses", "soul_pct", "soul_part",
]
const ART_NEUTRAL := ["group"]
const ART_NOT_PORTED := [
	"guards", "steps", "empower",
]

## Problems found by the last calls; empty when every profile loaded.
var errors: PackedStringArray = []
var _k: CombatConstants


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
				"stack_eff", "stack_dur", "cleanse_pulse"] \
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
	for el in p.purity:
		if not (str(el) in ELEMENTS):
			errors.append("%s: purity element %s is not one of %s" % [where, str(el), str(ELEMENTS)])
	for i in (d.get("shields", []) as Array).size():
		p.shields.append(_shield(d.shields[i], "%s.shields[%d]" % [where, i]))
	for i in (d.get("wards", []) as Array).size():
		p.wards.append(_ward(d.wards[i], "%s.wards[%d]" % [where, i]))
	return p if errors.size() == n0 else null


## A status an art applies, from the sim's spec dict. Internal Injury is an Effect's stored damage (the Effect
## slice).
func _status(d: Dictionary, where: String) -> StatusSpec:
	var spec := StatusSpec.new()
	spec.id = str(d.get("id", ""))
	if spec.id == "internal_injury":
		errors.append("%s: internal_injury is not ported yet (the Effect slice)" % where)
		return null
	if not _k.status.has(spec.id):
		errors.append("%s: status %s is not in the Status Catalogue" % [where, spec.id])
		return null
	for key in d:
		var name: String = str(key)
		if name in ["id", "stacks", "chance"]:
			continue
		if name in ["dur", "cap", "layer", "tag", "crossing", "no_lockout"]:
			spec.extra[name] = d[key]
		else:
			errors.append("%s: unknown status field %s" % [where, name])
	spec.stacks = int(d.get("stacks", 1))
	spec.chance = float(d.get("chance", 1.0))
	return spec


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
		if not d.has(key):
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
	if a.soul_part > SOUL_PART_MAX + 1e-9:
		errors.append("%s: added Soul part %s is over %s (R11)" % [where, str(a.soul_part), str(SOUL_PART_MAX)])
	for j in (d.get("statuses", []) as Array).size():
		var spec: StatusSpec = _status(d.statuses[j], "%s.statuses[%d]" % [where, j])
		if spec != null:
			a.statuses.append(spec)
	var conv: Dictionary = d.get("convert", {})
	if float(conv.get("share", 0.0)) != 0.0:
		a.convert_to = StringName(str(conv.get("to", "")))
		a.convert_share = float(conv.share)
		if not (str(a.convert_to) in DTYPES):
			errors.append("%s: convert to %s is not one of %s" % [where, str(a.convert_to), str(DTYPES)])
	for t in d.get("tags", []):
		a.tags.append(StringName(str(t)))
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
