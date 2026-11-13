class_name FighterState
extends RefCounted
## One side's changing state during a [Fight] (ADR-0001): pools, timers and tallies, copied from its
## [FighterProfile] at the start. The profile is only read. No reference to the [Fight] or the other side
## (ADR-0001: no back-pointers; cyclic RefCounted references leak).
##
## Mirrors the sim's [code]Side[/code] (tools/design/combat_sim/engine.py). Slices 1-2 fields.


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


## The compiled fighter (read only).
var p: FighterProfile
## "A" or "B", as in the sim's logs.
var label: String
## The realm's unit U and defence factor d_r.
var u: float
var g: float
var hp_max: float
var qi_base: float
var hp: float
var qi: float
## Per art, in slot order: next ready time (ms), charges left, firings.
var ready: PackedInt64Array = []
var charges: PackedInt32Array = []
var fired: PackedInt32Array = []
## Next basic attack (ms) and next hit per companion (ms).
var basic_ready: int = 0
var comp_ready: PackedInt64Array = []
var down: bool = false
## The body shield bar, and the ward shield bars in order (the build's shields, then standing ward shields).
var body_bar: float = 0.0
var wshields: Array[ShieldState] = []
var xwards: Array[WardState] = []
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

var _reserve_keep: float


## Sets up the side as the sim's Side does: full health, linh lực less the reserved share.
func _init(profile: FighterProfile, side_label: String, k: CombatConstants) -> void:
	p = profile
	label = side_label
	u = k.u[p.realm]
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
	for i in n:
		charges[i] = p.arts[i].charges
	comp_ready.resize(p.companions.size())
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


## Maximum linh lực (Water stacks raise it in a later slice).
func qi_max() -> float:
	return qi_base


## Usable linh lực: the maximum less what reservations hold (Combat Defence & Healing rule 10).
func qi_use() -> float:
	return qi_max() * _reserve_keep
