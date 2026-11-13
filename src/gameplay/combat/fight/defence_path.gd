class_name DefencePath
extends RefCounted
## The defence path a hit part meets (Combat Defence & Healing rules 1, 5-9, Formulas A-C; ADR-0001), ported from the
## sim's [code]Fight.defend[/code], [code]resistance[/code] and [code]extra_wards[/code] in the same operation
## order, so chance-free fights match it to 1e-6.
##
## Slices 1-2: resistance (main ward points while linh lực lasts, body and typed points, extra wards' points;
## negative amplifies) with the drain bill (the main ward's and drain wards'), block (with ward block), ward shields
## (stops by type, pieces, the floor, bypass), the body shield, the minimum hit, health. Penetration, curses and
## ticks' block share come with later slices; the loader refuses fighters that need them.


## Runs one hit part of [param amount] and type [param dtype] from [param att] into [param dfn] at time [param t_ms].
## [param hit_id] identifies the hit or tick this part belongs to, so a per-hit ward pays one fee for all its parts.
## Changes the defender's linh lực (the bill, per-hit fees), its shields and health. Returns the health removed.
static func defend(k: CombatConstants, att: FighterState, dfn: FighterState, amount: float, dtype: StringName,
		art: ArtDef, is_tick: bool, t_ms: int, hit_id: int) -> float:
	if dtype == &"soul":
		dfn.hp -= amount
		return amount
	var dp: FighterProfile = dfn.p
	var rw: float = dp.ward_pts * dp.ward_layer if dfn.qi > 0.0 else 0.0
	var ro: float = dp.body_pts * dp.bs_mult + float(dp.resist.get(dtype, 0.0))
	var xs: Array[FighterState.WardState] = []
	var xs_pts: PackedFloat64Array = []
	if not dfn.xwards.is_empty():
		var met: Array = extra_wards(dfn, dtype, hit_id)
		xs = met[0]
		xs_pts = met[1]
	var x_sum: float = 0.0
	for r in xs_pts:
		x_sum += r
	var r_raw: float = rw + ro + x_sum
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
	for i in xs.size():
		# an extra drain ward bills for the share of prevention it holds
		if xs[i].def.model == ExtraWardDef.Model.DRAIN and r > 0.0 and r_raw > 0.0 and prevented > 0.0:
			var share: float = prevented * xs_pts[i] / r_raw
			bill_share += share
			bill += share * xs[i].def.drain * k.drain_scale / dp.ward_layer / dfn.g * bill_up
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
	var x_blk: float = 0.0
	for xw in xs:
		x_blk += xw.def.block
	var blk: float = k.block_unit[dp.realm] * (dp.block + dp.body_block * dp.bs_mult + x_blk)
	if is_tick:
		blk *= 0.0   # ticks meet block only through an Effect's tick_block share (a later slice)
	a = maxf(0.0, a - blk)
	if a > 0.0:
		var byp: float = 0.0 if is_tick else minf(k.bypass_cap, art.bypass if art != null else 0.0)
		var through: float = a * byp
		var rest: float = a - through
		for w in dfn.wshields:
			if rest <= 0.0:
				break
			var sd: WardShieldDef = w.def
			var stop: float = float(sd.stops.get(dtype, 0.0 if (is_tick or dtype == &"soul") else 1.0))
			if is_tick and sd.stops.has(&"ticks"):
				stop = float(sd.stops[&"ticks"])
			if stop <= 0.0 or (w.left <= 0.0 and sd.floor_share == 0.0):
				continue
			var part: float = rest * stop
			var soak: float
			if w.left <= 0.0:
				soak = part * sd.floor_share
			else:
				var piece: float = sd.size * dfn.qi_base / maxi(1, sd.pieces)
				soak = minf(minf(part, w.left), piece if sd.pieces > 1 else w.left)
				w.left -= soak
				if w.left <= 1e-9:
					w.left = 0.0
			w.quiet_since = t_ms
			rest -= soak
		a = rest + through
		if a > 0.0 and dfn.body_bar > 0.0 and dtype != &"chaos" and dtype != &"soul":
			var bsoak: float = minf(a, dfn.body_bar)
			dfn.body_bar -= bsoak
			a -= bsoak
	var dealt: float = 0.0 if a <= 1e-12 else (a if is_tick else maxf(k.min_hit, a))
	dfn.hp -= dealt
	return dealt


## The extra wards up against a part of type [param dtype] (Combat Defence & Healing rules 5-8). Returns
## [code][Array[FighterState.WardState], PackedFloat64Array][/code]: the wards met and their resistance points
## (x ward_layer). A per-hit ward pays its fee once per
## [param hit_id] (all the hit's parts) and is skipped when linh lực cannot pay it; every ward but a reserved one needs
## live linh lực, as the main ward does. Public for mechanism tests.
static func extra_wards(dfn: FighterState, dtype: StringName, hit_id: int) -> Array:
	var out: Array[FighterState.WardState] = []
	var out_pts: PackedFloat64Array = []
	for xw in dfn.xwards:
		var w: ExtraWardDef = xw.def
		if not xw.up or (w.model != ExtraWardDef.Model.RESERVED and dfn.qi <= 0.0):
			continue
		var pts: float = float(w.payload.get(dtype, 0.0)) + float(w.payload.get(&"all", 0.0))
		if pts <= 0.0 and w.block == 0.0:
			continue
		if w.model == ExtraWardDef.Model.PER_HIT and xw.paid_hit != hit_id:
			var fee: float = w.cost * dfn.qi_max()
			if dfn.qi + 1e-9 < fee:
				continue
			dfn.qi -= fee
			dfn.spent += fee
			xw.paid_hit = hit_id
		out.append(xw)
		out_pts.append(pts * dfn.p.ward_layer)
	return [out, out_pts]
