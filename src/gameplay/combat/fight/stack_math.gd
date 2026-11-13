class_name StackMath
extends RefCounted
## Element stack power (Effects rule 9a; Spiritual Roots rule 8a, Formulas H; modifiers.md stack_effect_pct and
## stack_duration_pct), as the sim's [code]stack_pct[/code] and [code]stack_power[/code]. Static and pure.


## A build's stack effect or duration % for one element and kind: the sum of its lines keyed "<el>|<kind>",
## "<el>|*", "*|<kind>" and "*|*" (the sim's order, so a kind of "*" counts the element-only line twice, as there).
static func stack_pct(table: Dictionary, el: String, kind: String) -> float:
	var tot: float = 0.0
	for key in ["%s|%s" % [el, kind], "%s|*" % el, "*|%s" % kind, "*|*"]:
		tot += float(table.get(key, 0.0))
	return tot


## The power of one stack of [param el] of [param kind] ("buff" or "debuff") from fighter [param p]:
## (1 + purity_stack_power x purity) x (1 + stack effect % / 100). Water and Ice each count water_ice_share of the
## other's purity.
static func stack_power(k: CombatConstants, p: FighterProfile, el: String, kind: String) -> float:
	var pur: float = float(p.purity.get(el, 0.0))
	if el == "water":
		pur += k.water_ice_share * float(p.purity.get("ice", 0.0))
	elif el == "ice":
		pur += k.water_ice_share * float(p.purity.get("water", 0.0))
	var extra: float = stack_pct(p.stack_eff, el, kind) if not p.stack_eff.is_empty() else 0.0
	return (1.0 + k.purity_stack_power * pur) * (1.0 + extra / 100.0)
