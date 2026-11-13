class_name FightLogRow
extends RefCounted
## One row of a fight's timeline log (ADR-0001: built only when the request turns the log on). The layout matches
## the sim's parity log ([code]Fight.plog[/code]) so the parity suite compares them directly.

enum Kind { PULSE, ART, HIT }

var kind: Kind
var t_ms: int
## "A" or "B": the side pulsing, firing, or (for a hit) attacking.
var side: String
## For a hit: art, basic or companion.
var hit_kind: StringName = &""
## The art's id; for a basic attack or companion hit, the hit kind.
var art_id: StringName = &""
## PULSE: hp, qi. ART: cost, hp, qi. HIT: amount before defence, dealt, defender hp, defender qi, attacker hp,
## attacker qi.
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
	for v in values:
		out.append(v)
	return out
