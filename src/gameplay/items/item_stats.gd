class_name ItemStats
extends RefCounted
## The plain numbers a worn piece carries: a rolled piece's affixes and a named piece's authored modifiers
## (Item Database rules 20a and 21). An affix or a named modifier with a scope (`["fire"]`, `["sword"]`) acts only on what the
## scope names, which needs the art-based combat the game does not have yet, so only unscoped modifiers count here;
## every modifier stays on the record for that combat.
##
## Usage:
## [codeblock]
## for line in ItemStats.lines(art):        # [{stat, value}]
##     sheet.add_mod(art.name, line.stat, line.value)
## var pct: float = ItemStats.total(art, "artifact_attack_pct")
## [/codeblock]


## The stat lines a piece applies: its affixes, then its unscoped named modifiers.
static func lines(art: Dictionary) -> Array:
	var out: Array = []
	for a in art.get("affixes", []):
		if Array(a.get("scope", [])).is_empty():   # a scoped affix (Thiết Bích, Physical) waits for art combat
			out.append({"stat": str(a.stat), "value": float(a.value)})
	for m in art.get("modifiers", []):
		if Array(m.get("scope", [])).is_empty():
			out.append({"stat": str(m.key), "value": float(m.value)})
	return out


## The sum of one stat over [method lines].
static func total(art: Dictionary, stat: String) -> float:
	var t: float = 0.0
	for line in lines(art):
		if line.stat == stat:
			t += float(line.value)
	return t
