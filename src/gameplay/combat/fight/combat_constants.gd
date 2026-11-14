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

## Damage types and elements the engine knows (the sim's DTYPES and ELEMENTS).
const DTYPES := ["phys", "elem", "fire", "cold", "lightning", "force", "chaos", "soul"]
const ELEMENTS := ["", "fire", "water", "earth", "metal", "wood", "ice", "thunder", "wind"]
## Where the game keeps the constants.
const DEFAULT_PATH := "res://assets/data/combat_engine.json"
## The K keys this engine slice reads; a missing one stops the load.
const REQUIRED_K := [
	"fatigue_start", "fatigue_units", "fatigue_pow", "time_limit", "realm_def", "fatigue_by_realm", "health_mult",
	"regen_base", "regen_k", "cost_scale", "drain_scale", "cooldown_min", "basic_cooldown", "pulse", "bypass_cap",
	"pierce_cap", "health_units", "qi_units", "cost_red_cap", "reserve_cap", "pay_keep_health", "min_hit",
	"crit_cap", "evade_cap", "recharge_delay", "shield_recharge",
	"min_batch", "curse_slots", "curse_duration_max", "slowed_time_pct", "soul_beta", "rho_min", "soul_cap",
	"soul_lockout", "curse_heal_taken_max", "status_chance_min", "status_chance_max", "purity_stack_power",
	"water_ice_share", "cleanse_min_stacks", "trig_cap", "trig_depth", "trig_budget", "trig_floor_u", "layer_caps",
	"l1_soft", "delay_window", "delay_falloff", "summon_c", "summon_for", "injury_every", "refuse_down_health",
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
## Caps on crit and evade chance (shares); a standing shield refills shield_recharge of its bar per pulse after
## recharge_delay seconds without a hit.
var crit_cap: float
var evade_cap: float
var recharge_delay: float
var shield_recharge: float
## Element stacks and statuses (Effects rule 9a, Status Catalogue; Combat Formulas F, R22): the shortest batch
## (s), curse slots, the curse duration clamp (pulses), Slowed Time's slow per stack, the status chance clamp,
## purity's stack power and the Water/Ice share.
var min_batch: float
var curse_slots: int
var curse_duration_max: float
var slowed_time_pct: float
var status_chance_min: float
var status_chance_max: float
var purity_stack_power: float
var water_ice_share: float
## A debuff batch below this many stacks after the cleansing ward's share is gone.
var cleanse_min_stacks: float
## Triggers (Combat Formulas G): firings per side per pulse, the depth of events Effects may raise, the trigger
## damage budget and its floor in U. Damage layers (Combat Formulas A): caps per layer x1..x5, and x1's soft cap
## (threshold, share kept above it).
var trig_cap: int
var trig_depth: int
var trig_budget: float
var trig_floor_u: float
var layer_caps: PackedFloat64Array
var l1_soft: PackedFloat64Array
## Timers (R1): a delay's falloff per delay taken within delay_window seconds. Summons' default coefficient and
## seconds; Internal Injury's default release period (s); the health a refused Down leaves (Effects rule 11).
var delay_window: float
var delay_window_ms: int
var delay_falloff: float
var summon_c: float
var summon_for: float
var injury_every: float
var refuse_down_health: float
## The Effect vocabulary (Effects GDD rules 5-6) and an "elem" art's usual damage type by element.
var events: Array = []
var mod_keys: Array = []
var actions: Array = []
var elem_type: Dictionary = {}
## Soul attacks (Combat 24, E2): the exponent on rho, the rho floor, the cap per hit, the lockout (s); and the
## floor on healing taken with curses (Combat Defence & Healing E).
var soul_beta: float
var rho_min: float
var soul_cap: float
var soul_lockout: float
var curse_heal_taken_max: float
## Tables: per element, the stat each buff or debuff stack adds; the Status Catalogue by id; an element
## debuff's tick type. Keys are Strings, as in the file.
var buff: Dictionary = {}
var debuff: Dictionary = {}
var status: Dictionary = {}
var tick_type: Dictionary = {}
## The curse numbers the hot path reads, copied from the Status Catalogue at load (typed, no lookups per hit).
var sundered_res_pts: float
var exposed_res_all: float
var leaking_bill_up: float
var heavy_cost_up: float
var stagnation_dampen: float
var withering_heal_taken: float
var slackened_soul_res: float
var slowed_cap: int
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
var recharge_delay_ms: int
var soul_lockout_ms: int

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
	for key in ["BUFF", "DEBUFF", "STATUS", "TICK_TYPE"]:
		if not (d.get(key) is Dictionary):
			k.errors.append("combat_engine.json: %s is missing" % key)
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
	k.crit_cap = float(kd.crit_cap)
	k.evade_cap = float(kd.evade_cap)
	k.recharge_delay = float(kd.recharge_delay)
	k.shield_recharge = float(kd.shield_recharge)
	k.min_batch = float(kd.min_batch)
	k.curse_slots = int(kd.curse_slots)
	k.curse_duration_max = float(kd.curse_duration_max)
	k.slowed_time_pct = float(kd.slowed_time_pct)
	k.status_chance_min = float(kd.status_chance_min)
	k.status_chance_max = float(kd.status_chance_max)
	k.purity_stack_power = float(kd.purity_stack_power)
	k.water_ice_share = float(kd.water_ice_share)
	k.cleanse_min_stacks = float(kd.cleanse_min_stacks)
	k.trig_cap = int(kd.trig_cap)
	k.trig_depth = int(kd.trig_depth)
	k.trig_budget = float(kd.trig_budget)
	k.trig_floor_u = float(kd.trig_floor_u)
	k.layer_caps = PackedFloat64Array(kd.layer_caps)
	k.l1_soft = PackedFloat64Array(kd.l1_soft)
	k.delay_window = float(kd.delay_window)
	k.delay_window_ms = ms(k.delay_window)
	k.delay_falloff = float(kd.delay_falloff)
	k.summon_c = float(kd.summon_c)
	k.summon_for = float(kd.summon_for)
	k.injury_every = float(kd.injury_every)
	k.refuse_down_health = float(kd.refuse_down_health)
	k.events = d.get("EVENTS", [])
	k.mod_keys = d.get("MOD_KEYS", [])
	k.actions = d.get("ACTIONS", [])
	k.elem_type = d.get("ELEM_TYPE", {})
	k.soul_beta = float(kd.soul_beta)
	k.rho_min = float(kd.rho_min)
	k.soul_cap = float(kd.soul_cap)
	k.soul_lockout = float(kd.soul_lockout)
	k.curse_heal_taken_max = float(kd.curse_heal_taken_max)
	k.buff = d.BUFF
	k.debuff = d.DEBUFF
	k.status = d.STATUS
	k.tick_type = d.TICK_TYPE
	for sid in ["sundered", "exposed", "leaking_ward", "heavy_breath", "stagnation", "withering", "slackened_soul", "slowed_time"]:
		if not k.status.has(sid):
			k.errors.append("combat_engine.json: STATUS.%s is missing" % sid)
			return k
	k.sundered_res_pts = float(k.status.sundered.res_pts)
	k.exposed_res_all = float(k.status.exposed.res_all)
	k.leaking_bill_up = float(k.status.leaking_ward.bill_up)
	k.heavy_cost_up = float(k.status.heavy_breath.cost_up)
	k.stagnation_dampen = float(k.status.stagnation.regen_dampen)
	k.withering_heal_taken = float(k.status.withering.heal_taken)
	k.slackened_soul_res = float(k.status.slackened_soul.soul_res)
	k.slowed_cap = int(k.status.slowed_time.cap)
	k.u = PackedFloat64Array(d.U)
	k.supp = PackedFloat64Array(d.SUPP)
	k.block_unit = PackedFloat64Array(d.BLOCK_UNIT)
	k.pulse_ms = ms(k.pulse)
	k.time_limit_ms = ms(k.time_limit)
	k.fatigue_start_ms = ms(k.fatigue_start)
	k.cooldown_min_ms = ms(k.cooldown_min)
	k.recharge_delay_ms = ms(k.recharge_delay)
	k.soul_lockout_ms = ms(k.soul_lockout)
	if k.realm_def.size() != 5:
		k.errors.append("combat_engine.json: K.realm_def must list 5 realms")
	return k
