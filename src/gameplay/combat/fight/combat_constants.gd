class_name CombatConstants
extends RefCounted
## The fight engine's constants (ADR-0001), loaded from [code]assets/data/combat_engine.json[/code], the one source
## the Python design sim ([code]tools/design/combat_sim/engine.py[/code]) reads too. Values are in seconds as in the
## file; the [code]*_ms[/code] fields are the engine's integer-millisecond forms, rounded as the sim's [code]ms()[/code].
##
## Usage:
## [codeblock]
## var k := CombatConstants.load_file()
## if not k.errors.is_empty():
##     push_error("\n".join(k.errors))
## [/codeblock]

## Where the game keeps the constants.
const DEFAULT_PATH := "res://assets/data/combat_engine.json"
## The K keys this engine slice reads; a missing one stops the load.
const REQUIRED_K := [
	"fatigue_start", "fatigue_units", "fatigue_pow", "time_limit", "realm_def", "fatigue_by_realm", "health_mult",
	"regen_base", "regen_k", "cost_scale", "drain_scale", "cooldown_min", "basic_cooldown", "pulse", "bypass_cap",
	"pierce_cap", "health_units", "qi_units", "cost_red_cap", "reserve_cap", "pay_keep_health", "min_hit",
]

var fatigue_start: float
var fatigue_units: float
var fatigue_pow: float
var time_limit: float
## Realm defence factor d_r per realm (Combat Formulas A, Combat Defence C).
var realm_def: PackedFloat64Array
var fatigue_by_realm: bool
var health_mult: float
var regen_base: float
var regen_k: float
var cost_scale: float
var drain_scale: float
var cooldown_min: float
var basic_cooldown: float
var pulse: float
var bypass_cap: float
var pierce_cap: float
## health_max = health_units x U x n_body x health_mult x d_r; qi_base = qi_units x U x n_qi.
var health_units: float
var qi_units: float
## Caps on the cost-reduction and reserved shares.
var cost_red_cap: float
var reserve_cap: float
## An art paid in health must leave at least this much health.
var pay_keep_health: float
## A hit that reaches health removes at least this much (ticks excepted).
var min_hit: float
## The per-realm unit U.
var u: PackedFloat64Array
## Realm suppression by realm gap (Combat Formulas H).
var supp: PackedFloat64Array
## Block points to health, per realm.
var block_unit: PackedFloat64Array

var pulse_ms: int
var time_limit_ms: int
var fatigue_start_ms: int
var cooldown_min_ms: int

## Load problems; empty when the constants are usable.
var errors: PackedStringArray = []


## Seconds to whole milliseconds, exactly as the sim's [code]ms()[/code]: floor(sec x 1000 + 0.5).
static func ms(sec: float) -> int:
	return floori(sec * 1000.0 + 0.5)


## Loads the constants from [param path]. Check [member errors] before use.
static func load_file(path: String = DEFAULT_PATH) -> CombatConstants:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		var k := CombatConstants.new()
		k.errors.append("%s: cannot open (error %d)" % [path, FileAccess.get_open_error()])
		return k
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		var bad := CombatConstants.new()
		bad.errors.append("%s: not a JSON object" % path)
		return bad
	return from_dict(parsed)


## Builds the constants from the parsed file. Check [member errors] before use.
static func from_dict(d: Dictionary) -> CombatConstants:
	var k := CombatConstants.new()
	var kd: Dictionary = d.get("K", {})
	for key in REQUIRED_K:
		if not kd.has(key):
			k.errors.append("combat_engine.json: K.%s is missing" % key)
	for key in ["U", "SUPP", "BLOCK_UNIT"]:
		if not (d.get(key) is Array) or (d[key] as Array).size() != 5:
			k.errors.append("combat_engine.json: %s must list 5 realms" % key)
	if not k.errors.is_empty():
		return k
	k.fatigue_start = float(kd.fatigue_start)
	k.fatigue_units = float(kd.fatigue_units)
	k.fatigue_pow = float(kd.fatigue_pow)
	k.time_limit = float(kd.time_limit)
	k.realm_def = PackedFloat64Array(kd.realm_def)
	k.fatigue_by_realm = bool(kd.fatigue_by_realm)
	k.health_mult = float(kd.health_mult)
	k.regen_base = float(kd.regen_base)
	k.regen_k = float(kd.regen_k)
	k.cost_scale = float(kd.cost_scale)
	k.drain_scale = float(kd.drain_scale)
	k.cooldown_min = float(kd.cooldown_min)
	k.basic_cooldown = float(kd.basic_cooldown)
	k.pulse = float(kd.pulse)
	k.bypass_cap = float(kd.bypass_cap)
	k.pierce_cap = float(kd.pierce_cap)
	k.health_units = float(kd.health_units)
	k.qi_units = float(kd.qi_units)
	k.cost_red_cap = float(kd.cost_red_cap)
	k.reserve_cap = float(kd.reserve_cap)
	k.pay_keep_health = float(kd.pay_keep_health)
	k.min_hit = float(kd.min_hit)
	k.u = PackedFloat64Array(d.U)
	k.supp = PackedFloat64Array(d.SUPP)
	k.block_unit = PackedFloat64Array(d.BLOCK_UNIT)
	k.pulse_ms = ms(k.pulse)
	k.time_limit_ms = ms(k.time_limit)
	k.fatigue_start_ms = ms(k.fatigue_start)
	k.cooldown_min_ms = ms(k.cooldown_min)
	if k.realm_def.size() != 5:
		k.errors.append("combat_engine.json: K.realm_def must list 5 realms")
	return k
