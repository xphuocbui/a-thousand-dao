class_name ArtOverride
extends RefCounted
## The fields a multi-step art's step or an empower changes (the sim's OVERRIDE table and override(); Combat 13,
## Effects 6): a copy of the art with each given field replaced, then c_mult multiplying the coefficient, then
## add_statuses appended. Read-only once compiled.

## Spec keys and the art field each replaces (the sim's OVERRIDE). "kind" is an old spelling of dtype.
const FIELDS := {"c_art": "c", "statuses": "statuses", "buff": "buff", "debuff": "debuff", "split": "split",
	"convert": "convert", "bypass": "bypass", "c_heal": "heal", "qi_restore": "qi_restore", "cleanse": "cleanse",
	"soul_part": "soul_part", "dtype": "dtype", "kind": "dtype", "tags": "tags"}


## A step of a multi-step art: its unlock conditions, what it pays, and the art as it fires (built once at load).
class StepDef extends RefCounted:
	var conds: Array[EffectDef.CondDef] = []
	## The step's own health cost, a share of health_max (paid in Fight.step_health; 2026-11-14, both engines).
	var hp_cost: float = 0.0
	var pay: Array[EffectDef.ActionDef] = []
	var pay_effect: EffectDef
	var art: ArtDef


## An empower: its conditions, what it pays, and the override it adds.
class EmpowerDef extends RefCounted:
	var conds: Array[EffectDef.CondDef] = []
	var pay: Array[EffectDef.ActionDef] = []
	var pay_effect: EffectDef
	var ov: ArtOverride


## The spec's keys in order (the field each sets, applied in this order as the sim's setattr loop).
var keys: Array = []
## The raw values by spec key, with statuses compiled.
var values: Dictionary = {}
var has_c_mult: bool = false
var c_mult: float = 1.0
var add_statuses: Array[StatusSpec] = []


## A copy of [param a] with this override applied (the sim's override()).
func apply(a: ArtDef) -> ArtDef:
	var b: ArtDef = a.copy()
	# the fired form never reads its own steps or empowers (shape() reads the slotted art's), and keeping them would
	# make a cycle (a step's art -> the steps list -> the step -> its art) that RefCounted never frees (ADR-0001 Risks)
	b.steps = []
	b.empower = []
	for key in keys:
		var v: Variant = values[key]
		match str(FIELDS[key]):
			"c":
				b.c = float(v)
			"statuses":
				b.statuses = v
			"buff":
				b.buff_n = float(v[0]) if (v as Array).size() > 0 else 0.0
				b.buff_dur = -1.0 if (v as Array).size() < 2 or v[1] == null else float(v[1])
			"debuff":
				b.debuff_n = float(v[0]) if (v as Array).size() > 0 else 0.0
				b.debuff_dur = -1.0 if (v as Array).size() < 2 or v[1] == null else float(v[1])
			"split":
				b.split = PackedFloat64Array(v)
			"convert":
				var conv: Dictionary = v if v is Dictionary else {}
				b.convert_share = float(conv.get("share", 0.0))
				b.convert_to = StringName(str(conv.get("to", ""))) if b.convert_share != 0.0 else &""
			"bypass":
				b.bypass = float(v)
			"heal":
				b.heal = float(v)
			"qi_restore":
				b.qi_restore = float(v)
			"cleanse":
				b.cleanse = int(v)
			"soul_part":
				b.soul_part = float(v)
			"dtype":
				b.dtype = StringName(str(v))
			"tags":
				var tags: Array[StringName] = []
				var tags_s: Array = []
				for tg in v:
					tags.append(StringName(str(tg)))
					tags_s.append(str(tg))
				b.tags = tags
				b.tags_s = tags_s
	if has_c_mult:
		b.c = b.c * c_mult
	if not add_statuses.is_empty():
		var st: Array[StatusSpec] = b.statuses.duplicate()
		st.append_array(add_statuses)
		b.statuses = st
	b.ctx = {"dtype": str(b.dtype), "element": str(b.element), "tags": b.tags_s, "kind": "art", "art_id": str(b.id)}
	return b
