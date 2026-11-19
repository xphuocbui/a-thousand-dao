class_name FightLogRow
extends RefCounted
## One row of a fight's timeline log (ADR-0001: built only when the request turns the log on). The layout matches
## the sim's parity log ([code]Fight.plog[/code]) so the parity suite compares them directly.

enum Kind { PULSE, ART, HIT, TICK, QI_TICK, STACKS, STATUS, SOUL, CLEANSE, EFFECT, BANK, CULL, DOWN, STEP, EMPOWER, REFLECT, RETURN }

var kind: Kind
var t_ms: int
## "A" or "B": the side pulsing, firing, or (for a hit) attacking.
var side: String
## For a hit: art, basic or companion.
var hit_kind: StringName = &""
## For stacks and statuses: the side that received them.
var other: String = ""
## The art's id; for a basic attack or companion hit, the hit kind; for a tick or status, the status or element
## id; for stacks, the element.
var art_id: StringName = &""
## PULSE: hp, qi. ART: cost, hp, qi. HIT: amount before defence, dealt, defender hp, defender qi, attacker hp,
## attacker qi. TICK: amount, dealt, target hp, target qi. QI_TICK: amount, target hp, target qi. STACKS: count,
## expiry ms (-1 none), 1 for a buff. STATUS: stacks, expiry ms (-1 none). SOUL: health and linh lực removed, target
## hp, target qi. CLEANSE: stacks removed. EFFECT: none (art_id is the Effect id). BANK: the banked scale.
var values: PackedFloat64Array = []


## The row in the sim's plog layout: ["pulse", t, side, hp, qi], ["art", t, side, art, cost, hp, qi],
## ["hit", t, attacker, kind, art_id, D, dealt, defender hp, defender qi, attacker hp, attacker qi].
func to_array() -> Array:
	var out: Array = []
	match kind:
		Kind.PULSE:
			out = ["pulse", t_ms, side]
		Kind.ART:
			out = ["art", t_ms, side, str(art_id)]
		Kind.HIT:
			out = ["hit", t_ms, side, str(hit_kind), str(art_id)]
		Kind.TICK:
			out = ["tick", t_ms, side, str(art_id)]
		Kind.QI_TICK:
			out = ["qi_tick", t_ms, side, str(art_id)]
		Kind.STACKS:
			out = ["stacks", t_ms, side, other, str(art_id)]
		Kind.STATUS:
			out = ["status", t_ms, side, other, str(art_id)]
		Kind.SOUL:
			out = ["soul", t_ms, side, str(art_id)]
		Kind.CLEANSE:
			out = ["cleanse", t_ms, side]
		Kind.EFFECT:
			out = ["effect", t_ms, side, str(art_id)]
		Kind.BANK:
			out = ["bank", t_ms, side, str(art_id)]
		Kind.CULL:
			out = ["cull", t_ms, side]
		Kind.DOWN:
			out = ["down", t_ms, side, str(art_id)]
		Kind.STEP:
			out = ["step", t_ms, side, str(art_id)]
		Kind.EMPOWER:
			out = ["empower", t_ms, side, str(art_id)]
		Kind.REFLECT:
			out = ["reflect", t_ms, side]
		Kind.RETURN:
			out = ["return", t_ms, side]
	for v in values:
		out.append(v)
	return out
