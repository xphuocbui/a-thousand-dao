class_name DefencePath
extends RefCounted
## The defence path a hit part meets (Combat Defence & Healing rules 1, 5-9, Formulas A-C; ADR-0001), ported from the
## sim's [code]Fight.defend[/code], [code]resistance[/code] and [code]extra_wards[/code] in the same operation
## order, so chance-free fights match it to 1e-6.
##
## Resistance (main ward points while linh lực lasts, body, typed and Effect resistance, extra wards' points, Sundered
## and Exposed; penetration; negative amplifies) with the drain bill (main and drain wards', raised by ward_bill and
## Leaking Ward), block (Effect block, ward block; ticks only through tick_block), ward shields (stops by type, pieces,
## the floor, bypass), the body shield, the minimum hit, health. It raises foe_ward_paid and shield_broken where the
## sim does, and marks the context "stopped" when nothing reached the body or health. Static: the [Fight] is an
## argument, never stored.


## Runs one hit part of [param amount] and type [param dtype] from [param att] into [param dfn] for fight [param f].
## [param ctx] is the hit's context (dtype, element, tags, kind, art_id); it gets "stopped" when the part was stopped.
## Changes the defender's linh lực (the bill, per-hit fees), its shields and health. Returns the health removed.

static func defend(f: Fight, att: FighterState, dfn: FighterState, amount: float, dtype: StringName, art: ArtDef,
		ctx: Dictionary, is_tick: bool) -> float:
	var k: CombatConstants = f.k
	if dtype == &"soul":
		dfn.hp -= amount
		return amount
	var dp: FighterProfile = dfn.p
	var sdt: String = str(dtype)
	var rw: float = dp.ward_pts * dp.ward_layer if dfn.qi > 0.0 else 0.0
	if rw != 0.0 and f.has_mods(dfn):
		# live ward strength (Layered Earth, Open Sky: ward_pct; engine.py resistance())
		rw = dp.ward_pts * dp.ward_layer * maxf(0.0, 1.0 + f.m(dfn, "ward_pct", null) / 100.0)
	var ro: float = dp.body_pts * dp.bs_mult + float(dp.resist.get(dtype, 0.0))
	if f.has_mods(dfn):
		f.dt_ctx["dtype"] = sdt   # a reused one-key context: m() only reads it
		ro += f.m(dfn, "resist", f.dt_ctx)
	# curses on resistance: Sundered (points per stack) and Exposed (all types) (Status Catalogue)
	if not dfn.statuses.is_empty():
		ro += dfn.st("sundered") * k.sundered_res_pts + dfn.st("exposed") * k.exposed_res_all
	var xs: Array = EffectRunner._NONE_A
	var xs_pts: PackedFloat64Array   # empty packed arrays hold no buffer, so this allocates nothing
	if not dfn.xwards.is_empty():
		var met: Array = extra_wards(dfn, dtype, f.hit_id)
		xs = met[0]
		xs_pts = met[1]
	var x_sum: float = 0.0
	for r in xs_pts:
		x_sum += r
	var r_raw: float = rw + ro + x_sum
	# penetration in points, its type scope matching this part's final type (CD&H rule 4, AC-CD-13)
	var r: float = r_raw
	if f.has_mods(att):
		# the hit's context already carries this part's type in the usual case; a copy only when it does not
		var pen_ctx: Dictionary = ctx
		if str(ctx.get("dtype", "")) != sdt or ctx.size() == 0:
			pen_ctx = ctx.duplicate()
			pen_ctx["dtype"] = sdt
		r = r_raw - f.m(att, "pen", pen_ctx)
	var prevented: float
	var bill_share: float
	if r >= 0.0:
		prevented = amount * r / (100.0 + r) if r > 0.0 else 0.0
		bill_share = prevented * rw / r_raw if (r > 0.0 and r_raw > 0.0) else 0.0
	else:
		prevented = -amount * absf(r) / 100.0
		bill_share = 0.0
	var am: bool = f.has_mods(att)
	var dm: bool = f.has_mods(dfn)
	var bill_up: float = 1.0 + (att.p.ward_bill_pct + (f.m(att, "ward_bill", null) if am else 0.0)) / 100.0
	if not dfn.statuses.is_empty():
		bill_up *= 1.0 + dfn.st("leaking_ward") * k.leaking_bill_up
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
		if paid > 0.0 and f.listens(att, "foe_ward_paid"):
			EffectRunner.fire(f, att, "foe_ward_paid", {"amount": paid})
	var a: float = amount - prevented
	var ward_took: float = bill_share if bill_share > 0.0 else 0.0   # the drain ward's part (world-depth Stage 5)
	var x_blk: float = 0.0
	for xw in xs:
		x_blk += xw.def.block
	var blk: float = k.block_unit[dp.realm] * dp.stage_mult * (dp.block + (f.m(dfn, "block", null) if dm else 0.0) + dp.body_block * dp.bs_mult + x_blk)
	if is_tick:
		blk *= (f.m(dfn, "tick_block", null) if dm else 0.0) / 100.0
	# Keen Edge, Hidden Moon: the defender's own block counts nothing, or the attacker's hits ignore it
	if (dm and f.m(dfn, "no_block", null) > 0.0) or (att != null and am and f.m(att, "ignore_block", null) > 0.0):
		blk = 0.0
	var blocked: float = minf(maxf(0.0, a), blk)
	a = maxf(0.0, a - blk)
	if blocked > 0.0 and not is_tick and f.listens(dfn, "blocked"):
		# the part a block stopped (Thorns, Layered Earth)
		var bev: Dictionary = ctx.duplicate()
		bev["amount"] = blocked
		bev["dtype"] = sdt
		EffectRunner.fire(f, dfn, "blocked", bev)
	var reached := false
	if a > 0.0:
		var byp: float = 0.0 if is_tick else minf(k.bypass_cap, (art.bypass if art != null else 0.0) + (f.m(att, "bypass", ctx) if am else 0.0))
		if ctx is Dictionary and bool((ctx as Dictionary).get("pass_shields", false)):   # a free hit passing shields
			byp = 1.0
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
					if f.listens(dfn, "shield_broken"):
						EffectRunner.fire(f, dfn, "shield_broken", {})
			w.quiet_since = f.t
			rest -= soak
			ward_took += soak
		if rest > 0.0 and dfn.sward > 0.0 and not is_tick and dtype != &"soul":   # the stance ward (W1, 2026-11-26)
			var ssoak: float = minf(rest, dfn.sward)
			if not (dm and f.m(dfn, "ward_fixed", null) > 0.0):   # Hold a ward: it stops hits but loses nothing
				dfn.sward -= ssoak
				if dfn.sward <= 1e-9:
					dfn.sward = 0.0
					if f.listens(dfn, "shield_broken"):
						EffectRunner.fire(f, dfn, "shield_broken", {"stance_ward": 1})
			rest -= ssoak
			ward_took += ssoak
		a = rest + through
		if a > 0.0 and dfn.body_bar > 0.0 and dtype != &"chaos" and dtype != &"soul" \
				and not (dm and f.m(dfn, "no_body_shield", null) > 0.0):
			var bsoak: float = minf(a, dfn.body_bar)
			dfn.body_bar -= bsoak
			a -= bsoak
			reached = bsoak > 0.0
	var dealt: float = 0.0 if a <= 1e-12 else (a if is_tick else maxf(k.min_hit, a))
	if dealt > 0.0:
		reached = true
	if ward_took > 0.0 and not is_tick and f.listens(dfn, "ward_absorbed"):
		# Effects rule 5 (2026-11-26): a ward absorbed a hit, or a share of it
		var wev: Dictionary = ctx.duplicate()
		wev["amount"] = ward_took
		wev["dtype"] = dtype
		EffectRunner.fire(f, dfn, "ward_absorbed", wev)
	dfn.hp -= dealt
	if not reached and not is_tick and amount > 0.0:
		ctx["stopped"] = true
	return dealt


## The extra wards up against a part of type [param dtype] (Combat Defence & Healing rules 5-8). Returns
## [code][Array[FighterState.WardState], PackedFloat64Array][/code]: the wards met and their resistance points
## (x ward_layer). A per-hit ward pays its fee once per [param hit_id] (all the hit's parts) and is skipped when linh
## lực cannot pay it; every ward but a reserved one needs live linh lực, as the main ward does. Public for mechanism
## tests.
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
