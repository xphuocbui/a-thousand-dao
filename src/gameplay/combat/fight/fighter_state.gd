class_name FighterState
extends RefCounted
## One side's changing state during a [Fight] (ADR-0001): pools, timers and tallies, copied from its
## [FighterProfile] at the start. The profile is only read. No reference to the [Fight] or the other side
## (ADR-0001: no back-pointers; cyclic RefCounted references leak).
##
## Mirrors the sim's [code]Side[/code] (tools/design/combat_sim/engine.py). Slice 1 fields only.

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


## Maximum linh lực (Water stacks raise it in a later slice).
func qi_max() -> float:
	return qi_base


## Usable linh lực: the maximum less what reservations hold (Combat Defence & Healing rule 10).
func qi_use() -> float:
	return qi_max() * _reserve_keep
