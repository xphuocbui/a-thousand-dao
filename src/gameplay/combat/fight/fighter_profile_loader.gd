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

## Build fields slices 1-2 read, as float (the profile field when it differs).
const BUILD_FLOATS := {
	"M": "m", "n_body": "", "n_qi": "", "ward_pts": "", "drain": "", "block": "", "regen_bonus": "", "hregen": "",
	"cost_red": "", "gain_on_hit": "", "leech_qi": "", "leech_hp": "", "hp_pay": "", "healing": "",
	"art_speed_pct": "", "basic_speed_pct": "", "opening_haste_pct": "", "basic_coef_add": "", "ward_layer": "",
	"body_pts": "", "body_block": "", "bs_mult": "", "ward_bill_pct": "", "reserved": "",
	"crit": "", "crit_mult": "", "evade": "", "acc": "", "body_shield": "",
}
## Build fields with no effect until a later slice ports what reads them (accepted, not used yet): the soul
## fields only with soul arts; tam_ma with its pool; timer_resist with Slowed Time; refusals with refuse_down
## Effects; layers with layer mods.
const BUILD_NEUTRAL := [
	"name", "layers", "divine_sense", "soul_res", "x_soul", "tam_ma", "timer_resist", "refusals",
	"boss", "tags",
]
## Build fields a later slice ports; they must be zero or empty here.
const BUILD_NOT_PORTED := [
	"cleanse_pulse", "cleanse_cost", "cleanse_share", "purity", "effects", "counters", "states", "stack_eff",
	"stack_dur",
]
## Art fields slices 1-2 read.
const ART_PORTED := [
	"name", "c", "cost", "cd", "element", "dtype", "m_mult", "split", "charges", "heal", "qi_restore", "hp_cost",
	"bypass", "tags", "pool", "convert",
]
const ART_NEUTRAL := ["group"]
const ART_NOT_PORTED := [
	"buff", "debuff", "cleanse", "guards", "statuses", "soul_pct", "soul_part", "steps", "empower",
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
		if BUILD_FLOATS.has(name) or name in ["realm", "resist", "arts", "companions", "shields", "wards"] \
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
	for i in (d.get("shields", []) as Array).size():
		p.shields.append(_shield(d.shields[i], "%s.shields[%d]" % [where, i]))
	for i in (d.get("wards", []) as Array).size():
		p.wards.append(_ward(d.wards[i], "%s.wards[%d]" % [where, i]))
	return p if errors.size() == n0 else null


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
	if str(d.get("pool", "qi")) != "qi":
		errors.append("%s: pool %s is not ported yet (a later slice)" % [where, str(d.get("pool"))])
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
