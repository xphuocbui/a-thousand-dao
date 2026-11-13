class_name FighterEnd
extends RefCounted
## One side's state when a fight ends (Combat AC-CB-06, ADR-0001 FightResult). Slice 1 fills the pools and tallies;
## the wound grade comes with the Down step's later slice.

enum Wound { NONE, GRAVE, MORTAL }

var health: float
var health_max: float
var linh_luc: float
var linh_luc_base: float
var wound: Wound = Wound.NONE
var down: bool
## Resources spent: linh lực paid for arts; damage dealt; fatigue taken; health healed; ward bills paid.
var spent: float
var dealt: float
var fatigue: float
var healed: float
var ward_paid: float
## Firings per art, in slot order.
var fired: PackedInt32Array


## The end state of [param s].
static func of(s: FighterState) -> FighterEnd:
	var e := FighterEnd.new()
	e.health = s.hp
	e.health_max = s.hp_max
	e.linh_luc = s.qi
	e.linh_luc_base = s.qi_base
	e.down = s.down
	e.spent = s.spent
	e.dealt = s.dealt
	e.fatigue = s.fat
	e.healed = s.healed
	e.ward_paid = s.ward_paid
	e.fired = s.fired.duplicate()
	return e
