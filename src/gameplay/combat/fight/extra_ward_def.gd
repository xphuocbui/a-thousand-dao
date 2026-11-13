class_name ExtraWardDef
extends RefCounted
## An extra ward beside the main drain ward (Combat Defence & Healing rules 5-8), as the sim's ward dicts: numbers
## already scaled by the build's ward strength and efficiency. Read-only once loaded; a fight keeps its up/down state
## in [FighterState.WardState].

enum Model { DRAIN, PER_HIT, RESERVED, CAST }

var id: String = ""
var model: Model = Model.DRAIN
## Resistance points by damage type; the key &"all" meets every type.
var payload: Dictionary = {}
## Block points while up.
var block: float = 0.0
## A shield bar, as a share of qi_base (standing wards: a standing bar; cast wards: a bar for the window).
var shield: float = 0.0
## Per-hit fee or cast cost, as a share of linh lực (per hit: of qi_max; cast: of qi_base).
var cost: float = 0.0
## A drain ward's drain, in engine drain units.
var drain: float = 0.0
## Cast wards: seconds between casts and seconds up.
var cooldown: float = 5.0
var up: float = 3.0
## Evade points (pp) while up.
var evade: float = 0.0
