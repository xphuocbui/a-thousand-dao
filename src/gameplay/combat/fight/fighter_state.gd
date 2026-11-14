class_name FighterState
extends RefCounted
## One side's changing state during a [Fight] (ADR-0001): pools, timers and tallies, copied from its
## [FighterProfile] at the start. The profile is only read. No reference to the [Fight] or the other side
## (ADR-0001: no back-pointers; cyclic RefCounted references leak).
##
## Mirrors the sim's [code]Side[/code] (tools/design/combat_sim/engine.py). Slices 1-4a fields.
## A stack batch or status names its source by side index (0 = A, 1 = B), never by reference, so the two states
## never point at each other.


## A batch of element stacks: element, count, expiry ms (-1: the whole fight), source side and profile, length.
class StackBatch extends RefCounted:
	var el: String
	var n: float
	var until: int = -1
	var src_idx: int
	var src_p: FighterProfile
	var length: int = -1
	## Stack power, fixed at the grant: profiles never change in a fight, so this equals the sim's read-time value.
	var power: float = 1.0


## A status on this side: stacks, expiry ms (-1: until cleansed), source side, and the spec's extras.
class StatusState extends RefCounted:
	## Stacks may be fractional when an Effect grants them at a fractional scale, as in the sim.
	var stacks: float = 0.0
	var until: int = -1
	var src_idx: int
	var tag: String = ""
	var layer: int = 4
	var crossing: bool = false
	var no_lockout: bool = false
	## Internal Injury (not a catalogue status): damage stored, release period (s), next release (ms).
	var stored: float = 0.0
	var every: float = 3.0
	var next_release: int = 0


## A ward shield bar in this fight: its definition, what is left, when it was last hit (ms), pieces left.
class ShieldState extends RefCounted:
	var def: WardShieldDef
	var left: float = 0.0
	var quiet_since: int = 0
	var pieces_left: int = 1


## An extra ward in this fight: up or down, cast window end and next cast (ms), its cast bar, the last hit that
## paid its per-hit fee.
class WardState extends RefCounted:
	var def: ExtraWardDef
	var up: bool = true
	var until: int = 0
	var ready: int = 0
	var bar: ShieldState = null
	var paid_hit: int = -1


## A timed mod from an Effect's mod action (the sim's temp_mods row): key, value, expiry ms, filter, Effect id.
class TempMod extends RefCounted:
	var key: String
	var v: float
	var until: int
	var filt: Dictionary
	var eid: String


## A held payload in the bank (Effects rule 16): its Effect, actions and banked scale.
class Banked extends RefCounted:
	var e: EffectDef
	var actions: Array[EffectDef.ActionDef]
	var n: float


## The compiled fighter (read only).
var p: FighterProfile
## "A" or "B", as in the sim's logs.
var label: String
## The realm's unit U and defence factor d_r.
var u: float
## The damage unit: u x the stage multiplier (Combat Formulas A); hits, ticks, trigger floors, heal arts.
var u_att: float
var g: float
var hp_max: float
var qi_base: float
var hp: float
var qi: float
## Per art, in slot order: next ready time (ms), charges left, firings.
var ready: PackedInt64Array = []
var charges: PackedInt32Array = []
var fired: PackedInt32Array = []
## Per art: the step a multi-step art tries next (0 = its first form).
var step: PackedInt32Array = []
## Next basic attack (ms) and next hit per companion (ms).
var basic_ready: int = 0
var comp_ready: PackedInt64Array = []
var down: bool = false
## The body shield bar, and the ward shield bars in order (the build's shields, then standing ward shields).
var body_bar: float = 0.0
var wshields: Array[ShieldState] = []
var xwards: Array[WardState] = []
## Element stacks on this side (buffs it gave itself, debuffs the foe gave it), statuses by id (insertion order,
## as the sim's dict), and the ms until each status may be reapplied.
var buffs: Array[StackBatch] = []
var debuffs: Array[StackBatch] = []
var statuses: Dictionary = {}
var lockouts: Dictionary = {}
## Second pools (Combat 11, R12): heart-demon points left and the share of divine sense spent; soul lockout ms.
var tam_ma: float = 0.0
var ts_spent: float = 0.0
var soul_ready: int = 0
## Tallies for the result.
var dealt: float = 0.0
var direct_dmg: float = 0.0
var spent: float = 0.0
var fat: float = 0.0
var healed: float = 0.0
var ward_paid: float = 0.0
## The last art's linh lực cost and health paid (a heal art refunds the former).
var last_cost: float = 0.0
var hp_paid: float = 0.0
## Effects (slice 4a): limits per Effect id ([fight, pulse, next ms]), timed mods, the bank, self-counters (and the
## per-stack expiry times of counters with each_for), triggers this pulse and their damage, the stance ("" none),
## the arts fired in the last fire_log_ms ([t, art id, tags, group]), the event of the art being fired, the last
## art's slot.
var eff_state: Dictionary = {}
var temp_mods: Array[TempMod] = []
var banked: Array[Banked] = []
var counters: Dictionary = {}
var counter_times: Dictionary = {}
var trig_count: int = 0
var trig_dmg: float = 0.0
var state: String = ""
var fire_log: Array = []
var cur_ev: Variant = null
var last_art: int = -1
## Slice 4b: delays this side took (ms, for the falloff), summons ([c, dtype, cd ms, next ms, until ms]), the
## elements whose own debuff batches a cleanse skips ({for_first, swap_buff}), refusals of Down left.
var delays: Array = []
var summons: Array = []
var protect: Dictionary = {}
var refusals_left: int = 1

var _reserve_keep: float
var _k: CombatConstants
## Sums of buff and debuff stats by key, valid until the stacks change ([method touch_buffs], [method touch_debuffs]).
var _bcache: Dictionary = {}
var _dcache: Dictionary = {}


## Sets up the side as the sim's Side does: full health, linh lực less the reserved share.
func _init(profile: FighterProfile, side_label: String, k: CombatConstants) -> void:
	p = profile
	label = side_label
	_k = k
	tam_ma = p.tam_ma
	u = k.u[p.realm]
	u_att = u * p.stage_mult
	g = k.realm_def[p.realm]
	hp_max = k.health_units * u * p.n_body * k.health_mult * g
	qi_base = k.qi_units * u * p.n_qi
	_reserve_keep = 1.0 - minf(k.reserve_cap, p.reserved)
	hp = hp_max
	qi = qi_base * _reserve_keep
	var n: int = p.arts.size()
	ready.resize(n)
	charges.resize(n)
	fired.resize(n)
	step.resize(n)
	for i in n:
		charges[i] = p.arts[i].charges
	comp_ready.resize(p.companions.size())
	state = p.state_start
	refusals_left = p.refusals
	for cid in p.counter_def:
		counters[cid] = 0.0
		counter_times[cid] = []
	body_bar = p.body_shield * hp_max
	for sd in p.shields:
		var sh := ShieldState.new()
		sh.def = sd
		sh.left = sd.size * qi_base * (1.0 if sd.pieces != 0 else 0.0)
		sh.pieces_left = sd.pieces
		wshields.append(sh)
	for wd in p.wards:
		var ws := WardState.new()
		ws.def = wd
		ws.up = wd.model != ExtraWardDef.Model.CAST
		xwards.append(ws)
		if wd.shield != 0.0 and wd.model != ExtraWardDef.Model.CAST:
			# a standing ward's shield joins the ward shields
			var bar_def := WardShieldDef.new()
			bar_def.size = wd.shield
			var bar := ShieldState.new()
			bar.def = bar_def
			bar.left = wd.shield * qi_base
			wshields.append(bar)


## Maximum linh lực: qi_base, raised by Water buff stacks.
func qi_max() -> float:
	return qi_base * (1.0 + bsum("qi_max"))


## Stacks of status [param sid] on this side (0 when absent).
func st(sid: String) -> float:
	if statuses.is_empty():
		return 0.0
	var s: StatusState = statuses.get(sid)
	return s.stacks if s != null else 0.0


## The sum of [param key] over this side's buff stacks, each at its own power (the sim's bsum).
func bsum(key: String) -> float:
	if buffs.is_empty():
		return 0.0
	var hit: Variant = _bcache.get(key)
	if hit != null:
		return hit
	var tot: float = 0.0
	for x in buffs:
		var tab: Dictionary = _k.buff.get(x.el, EffectRunner._NONE_D)
		tot += float(tab.get(key, 0.0)) * x.n * x.power
	_bcache[key] = tot
	return tot


## The sum of [param key] over the debuff stacks on this side, each at its source's power (the sim's dsum).
func dsum(key: String) -> float:
	if debuffs.is_empty():
		return 0.0
	var hit: Variant = _dcache.get(key)
	if hit != null:
		return hit
	var tot: float = 0.0
	for x in debuffs:
		var tab: Dictionary = _k.debuff.get(x.el, EffectRunner._NONE_D)
		tot += float(tab.get(key, 0.0)) * x.n * x.power
	_dcache[key] = tot
	return tot


## Call after any change to [member buffs] (a grant, an expiry): the cached sums are dropped.
func touch_buffs() -> void:
	_bcache.clear()


## Call after any change to [member debuffs] (a grant, an expiry, a cleanse): the cached sums are dropped.
func touch_debuffs() -> void:
	_dcache.clear()


## Usable linh lực: the maximum less what reservations hold (Combat Defence & Healing rule 10).
func qi_use() -> float:
	return qi_max() * _reserve_keep
