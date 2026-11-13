class_name DefencePath
extends RefCounted
## The defence path a hit part meets (Combat Defence & Healing rules 1, 9, Formulas A-C; ADR-0001), ported from the
## sim's [code]Fight.defend[/code] and [code]resistance[/code] in the same operation order, so chance-free fights
## match it to 1e-6.
##
## Slice 1: resistance (main ward points while linh lực lasts, body and typed points; negative amplifies) with the
## drain bill, block, bypass arithmetic, the minimum hit, health. Later slices add extra wards, ward and body
## shields, curses, penetration and ticks' block share; the loader refuses fighters that need them.


## Runs one hit part of [param amount] and type [param dtype] from [param att] into [param dfn]. Changes the
## defender's linh lực (the bill) and health. Returns the health removed.
static func defend(k: CombatConstants, att: FighterState, dfn: FighterState, amount: float, dtype: StringName,
		art: ArtDef, is_tick: bool) -> float:
	if dtype == &"soul":
		dfn.hp -= amount
		return amount
	var dp: FighterProfile = dfn.p
	var rw: float = dp.ward_pts * dp.ward_layer if dfn.qi > 0.0 else 0.0
	var ro: float = dp.body_pts * dp.bs_mult + float(dp.resist.get(dtype, 0.0))
	var r_raw: float = rw + ro
	var r: float = r_raw
	var prevented: float
	var bill_share: float
	if r >= 0.0:
		prevented = amount * r / (100.0 + r) if r > 0.0 else 0.0
		bill_share = prevented * rw / r_raw if (r > 0.0 and r_raw > 0.0) else 0.0
	else:
		prevented = -amount * absf(r) / 100.0
		bill_share = 0.0
	var bill_up: float = 1.0 + att.p.ward_bill_pct / 100.0
	var bill: float = bill_share * dp.drain * k.drain_scale / dp.ward_layer / dfn.g * bill_up
	if bill > 0.0:
		var paid: float = minf(bill, dfn.qi)
		if bill > dfn.qi:
			var frac: float = dfn.qi / bill
			dfn.qi = 0.0
			prevented -= bill_share * (1.0 - frac)
		else:
			dfn.qi -= bill
		dfn.ward_paid += paid
	var a: float = amount - prevented
	var blk: float = k.block_unit[dp.realm] * (dp.block + dp.body_block * dp.bs_mult)
	a = maxf(0.0, a - blk)
	if a > 0.0:
		var byp: float = 0.0 if is_tick else minf(k.bypass_cap, art.bypass if art != null else 0.0)
		var through: float = a * byp
		var rest: float = a - through
		a = rest + through
	var dealt: float = 0.0 if a <= 1e-12 else (a if is_tick else maxf(k.min_hit, a))
	dfn.hp -= dealt
	return dealt
