class_name FighterProfile
extends RefCounted
## A compiled fighter (ADR-0001 decision 2): everything a [Fight] reads about one side. Shared and cached, so it is
## read-only by contract: a [Fight] copies what it changes into its [FighterState] and never writes here (GDScript
## has no immutable objects; the parity suite runs the same profiles twice to catch a slip).
##
## Field names and meanings follow the sim's [code]Build[/code] (tools/design/combat_sim/engine.py). Slices 1-3 carry
## the timeline, damage, defence path, stacks, statuses and soul; the Effect slice adds Effects.


## A companion: a hit of its own on its own cooldown, one per source (Combat Formulas J, R31).
class Companion extends RefCounted:
	var c: float = 0.0
	var dtype: StringName = &"phys"
	var cd: float = 1.0
	## The companion's tags (crane, bird), carried by its hits (2026-11-26).
	var tags: Array = []


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
## Realms stage multiplier (1.00-1.45 through a realm): on the damage unit and on block, not on pools or fatigue.
var stage_mult: float = 1.0
## Percent values.
var art_speed_pct: float = 0.0
var basic_speed_pct: float = 0.0
var opening_haste_pct: float = 0.0
var ward_bill_pct: float = 0.0
## Element stacks (Effects rule 9a): purity by element; stack effect and duration % keyed "<el>|<kind>" with "*"
## for any. Keys are Strings.
var purity: Dictionary = {}
var stack_eff: Dictionary = {}
var stack_dur: Dictionary = {}
## Buff stacks of an element that also count as others' ({"water": ["wood"]}: Water Begets Wood); Array[String] values.
var stack_alias: Dictionary = {}
## The cleansing ward (Combat Defence & Healing): debuff stacks cleansed per pulse and the fee for each (share
## of qi_max); a share of every debuff batch cleansed per pulse.
var cleanse_pulse: int = 0
var cleanse_cost: float = 0.0
var cleanse_share: float = 0.0
## Soul (Combat 24, E2; R11, R12): divine sense, soul resistance, soul damage %, heart-demon pool (tam_ma),
## Slowed Time resistance %.
var divine_sense: float = 1.0
var soul_res: float = 0.0
var x_soul: float = 0.0
var tam_ma: float = 0.0
var timer_resist: float = 0.0
var basic_coef_add: float = 0.0
## Slotted arts in slot order.
var arts: Array[ArtDef] = []
## Formations rule 6: a diagram's feeds [from slot, to slot, ms]: when the art in the first slot fires, the second's
## timer drops by the ms, never below cooldown_min and never raised. Empty with the default line.
var feeds: Array = []
## Effects (slice 4a): the compiled records in order; self-counter definitions by id ({cap, decay_per_pulse,
## each_for}); per stat key, the always-on mod entries [EffectDef, value, mod dict] in Effect and action order (the
## order the sim sums them); per event, the Effects listening (held ones included) in order. Built by the loader.
var effects: Array[EffectDef] = []
var counter_def: Dictionary = {}
## A prepared pill, {element, grade, fail} (world-depth Stage 5, smoke only); empty: none.
var pill: Dictionary = {}
## Technique id -> layer, read as own.tech_layer.<id> (2026-11-26).
var tech_layers: Dictionary = {}
var always_by_key: Dictionary = {}
var listeners: Dictionary = {}
## Damage layer points x1..x5 (Combat Formulas A), when given; layer mods then meet exact caps.
var layers: PackedFloat64Array = []
## A boss (the boss readable).
var boss: bool = false
## Stances and forms (R29) by id: {"mods": {key: value}, "suppress": [art ids], "start": bool}; the one it starts in
## ("" none). Refusals of Down per fight (Effects rule 11).
var states: Dictionary = {}
var state_start: String = ""
var refusals: int = 1
var companions: Array[Companion] = []
