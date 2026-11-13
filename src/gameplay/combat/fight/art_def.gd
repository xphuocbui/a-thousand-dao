class_name ArtDef
extends RefCounted
## One slotted art as the fight engine reads it (ADR-0001; Combat GDD rule 13, Formulas A2, C, E). Read-only once
## loaded: a [Fight] never writes to it. Slices 1-2 (timeline, damage, defence path) carry these fields;
## [FighterProfileLoader] refuses art records that need a later slice (buffs, statuses, soul, steps...).

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
## Tags, for scoped reads in later slices.
var tags: Array[StringName] = []
