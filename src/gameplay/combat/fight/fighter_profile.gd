class_name FighterProfile
extends RefCounted
## A compiled fighter (ADR-0001 decision 2): everything a [Fight] reads about one side. Shared and cached, so it is
## read-only by contract: a [Fight] copies what it changes into its [FighterState] and never writes here (GDScript
## has no immutable objects; the parity suite runs the same profiles twice to catch a slip).
##
## Field names and meanings follow the sim's [code]Build[/code] (tools/design/combat_sim/engine.py). Slices 1-2 carry
## the timeline, damage and defence-path fields; later slices add stacks, statuses, soul and Effects.


## A companion: a hit of its own on its own cooldown, one per source (Combat Formulas J, R31).
class Companion extends RefCounted:
	var c: float = 0.0
	var dtype: StringName = &"phys"
	var cd: float = 1.0


var id: String = ""
## Realm index 0-4 (Qi Refining .. Nascent Soul).
var realm: int = 0
## Offence multiplier M (Combat Formulas A).
var m: float = 3.273
## Health and linh lực sheet multipliers.
var n_body: float = 1.0
var n_qi: float = 1.0
## Crit chance (share) and crit multiplier; evade and accuracy (shares) (Combat Formulas I).
var crit: float = 0.0
var crit_mult: float = 1.7
var evade: float = 0.0
var acc: float = 0.0
## Body shield bar as a share of health_max; chaos and Soul pass it.
var body_shield: float = 0.0
## Ward shields and extra wards (Combat Defence & Healing rules 5-9).
var shields: Array[WardShieldDef] = []
var wards: Array[ExtraWardDef] = []
## Main ward resistance points (count only while linh lực lasts), its layer and its drain.
var ward_pts: float = 0.0
var ward_layer: float = 1.0
var drain: float = 0.0
## Block points (x the realm's block unit).
var block: float = 0.0
var body_pts: float = 0.0
var body_block: float = 0.0
## Body cultivation multiplier on body points, body block and health regeneration.
var bs_mult: float = 1.0
## Typed resistance points by damage type; negative amplifies.
var resist: Dictionary = {}
var regen_bonus: float = 0.0
var hregen: float = 0.0
var healing: float = 0.0
## Shares (0.2 = 20 %).
var cost_red: float = 0.0
var hp_pay: float = 0.0
var gain_on_hit: float = 0.0
var leech_qi: float = 0.0
var leech_hp: float = 0.0
var reserved: float = 0.0
## Percent values.
var art_speed_pct: float = 0.0
var basic_speed_pct: float = 0.0
var opening_haste_pct: float = 0.0
var ward_bill_pct: float = 0.0
var basic_coef_add: float = 0.0
## Slotted arts in slot order.
var arts: Array[ArtDef] = []
var companions: Array[Companion] = []
