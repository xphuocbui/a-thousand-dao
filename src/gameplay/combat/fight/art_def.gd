class_name ArtDef
extends RefCounted
## One slotted art as the fight engine reads it (ADR-0001; Combat GDD rule 13, Formulas A2, C, E). Read-only once
## loaded: a [Fight] never writes to it. Slices 1-3 carry these fields;
## [FighterProfileLoader] refuses art records that need a later slice (guards, steps, empowers).

## The art's id (the sim's art name).
var id: StringName
## Damage coefficient c_art; 0 for an art that only heals or restores.
var c: float = 0.0
## Cost share before cost_scale (the sim's pre-#44 cost share).
var cost: float = 0.0
## Cooldown in seconds.
var cd: float = 3.0
## Element, for scoped reads in later slices.
var element: StringName = &""
## Damage type of its hits (Combat Damage Types).
var dtype: StringName = &"phys"
## Multiplier on the fighter's M for this art.
var m_mult: float = 1.0
## Sub-hit shares (R23); empty means one hit at share 1.
var split: PackedFloat64Array = []
## Firings stored; spent ones come back together after the cooldown.
var charges: int = 1
## Healing coefficient (x U x health_mult); a heal that lands refunds the art's linh lực cost.
var heal: float = 0.0
## Share of maximum linh lực restored on firing.
var qi_restore: float = 0.0
## Share of health_max paid on firing, besides linh lực (Effects 6).
var hp_cost: float = 0.0
## Share of the hit that passes ward shields (R2), capped by bypass_cap.
var bypass: float = 0.0
## Conversion (Combat Damage Types): this share of each hit becomes [member convert_to] and meets that type's
## defence; 0 for none.
var convert_to: StringName = &""
var convert_share: float = 0.0
## Element stacks granted on firing (buff, to self) and on hit (debuff, to the target): count and duration in
## seconds; a duration of -1 lasts the fight (the sim's None). Count 0: none.
var buff_n: float = 0.0
var buff_dur: float = -1.0
var debuff_n: float = 0.0
var debuff_dur: float = -1.0
## Debuff batches cleansed from self on firing.
var cleanse: int = 0
## Statuses applied on hit (Status Catalogue).
var statuses: Array[StatusSpec] = []
## A soul art (Combat 24, E2): share of the target's pools removed, before rho and caps; 0 for none.
var soul_pct: float = 0.0
## An added Soul part (R11): this share of each hit meets soul resistance only.
var soul_part: float = 0.0
## The pool it is paid from (Combat 11, R12): qi, tam_ma or than_thuc.
var pool: StringName = &"qi"
## Formations rule 5: a diagram node's Modifier on this art, in points (0 outside a diagram): art speed added to the
## side's art speed, and art cost (−20 = 20 % cheaper; the cost factor never goes below 0.5).
var node_speed_pct: float = 0.0
var node_cost_pct: float = 0.0
## Guards (Combat 13): conditions that must all hold for the art to fire.
var guards: Array[EffectDef.CondDef] = []
## The technique (cong phap) that carries it, for fired_within group reads.
var group: String = ""
## Tags, for scoped reads and Silence; the same as Strings for Effect filters and reads.
var tags: Array[StringName] = []
var tags_s: Array = []
## The art's own context for scoped reads (the sim's art_ctx): dtype, element, tags, kind "art", art_id.
var ctx: Dictionary = {}
## Multi-step arts and empowers (slice 5; Combat 13, Effects 6): the steps tried in order, and the empowers checked
## on every firing.
var steps: Array = []
var empower: Array = []


## A shallow copy (the sim's copy.copy): lists are shared, since compiled records are read-only.
func copy() -> ArtDef:
	var b := ArtDef.new()
	for prop in get_property_list():
		if prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			b.set(prop.name, get(prop.name))
	return b
