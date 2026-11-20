class_name CraftEconomy
extends RefCounted

## Crafted goods as priced classes (design/gdd/trade-goods.md rules 11-14, Formulas E, F, G, H): each market's
## workshops turn raw goods into pills of five tiers by recipe price, on a plan that answers the class's price against
## its inputs' cost and its cover. The plan's inputs are demand in the raw classes (craft_in) and a draw from their
## pools (cd), capped by what the shelves hold; its output is the crafted class's supply. Demand is the pill share of
## the provision baskets (each realm buys its own tier) and the player's buying. Price and stock follow Regional
## Economy Formulas D and E with the crafted parameters. All in base value; workshops move goods, not money.
##
## Not yet (plan production/plans/world-economy.md): talismans and artifacts, breakthrough demand (D_bt, a Realms
## handoff), Military's crafted spending (D_mil), crafted flows between markets, origin tags, regional crafted supply.
## State lives on each market record's [code]crafted[/code] block.

const KIND := "pill"


static func _cfg(gd: GameData) -> Dictionary:
	return gd.file(WorldEconomy.FILE)


## Formula E: the tier of a value against the band edges.
static func tier_of(gd: GameData, value: float) -> int:
	var t: int = 1
	for e in gd.file("items_rarity").get("pill_band_edges", [20, 150, 1500, 8000, 60000]):
		if float(e) < value:
			t += 1
	return t


## The crafted class of a pill recipe ("pill3").
static func class_of_recipe(gd: GameData, recipe: Dictionary) -> String:
	return "%s%d" % [KIND, tier_of(gd, float(recipe.get("price", 1)))]


## Each pill class's recipes: {cid: {a: {good: share of the class's input value}, mu, recipes: [{id, share, a, mu}]}},
## from the recipe data (inputs at their mature-equivalent value, Item Database Formula B: q · E(min_age) mature herbs).
## A recipe's share is its part of the class's output value; each recipe draws and fills on its own, so a missing herb
## stops only the pills that need it.
static func class_recipes(gd: GameData) -> Dictionary:
	var by := {}
	for r in gd.recipes():
		var cid: String = class_of_recipe(gd, r)
		if not by.has(cid):
			by[cid] = {"in": {}, "in_tot": 0.0, "out_tot": 0.0, "recipes": []}
		var b: Dictionary = by[cid]
		var a := {}
		var tot: float = 0.0
		for ing in r.ingredients:
			var e: float = float(ing.qty) * ItemFactory.equivalents_at(gd, str(ing.herb), float(ing.min_age))
			var v: float = e * float(gd.herb(str(ing.herb)).get("base_value", 1))
			a[str(ing.herb)] = float(a.get(str(ing.herb), 0.0)) + v
			b["in"][str(ing.herb)] = float(b["in"].get(str(ing.herb), 0.0)) + v
			tot += v
		b.in_tot = float(b.in_tot) + tot
		var out_v: float = float(r.get("price", 1)) * float(r.get("yield", 1))
		b.out_tot = float(b.out_tot) + out_v
		for g in a:
			a[g] = float(a[g]) / maxf(tot, 1e-9)
		b.recipes.append({"id": str(r.id), "out": out_v, "a": a, "mu": out_v / maxf(tot, 1e-9)})
	var out := {}
	for cid in by:
		var b: Dictionary = by[cid]
		var a := {}
		for g in b["in"]:
			a[g] = float(b["in"][g]) / maxf(float(b.in_tot), 1e-9)
		for rr in b.recipes:
			rr["share"] = float(rr.out) / maxf(float(b.out_tot), 1e-9)
		out[cid] = {"a": a, "mu": float(b.out_tot) / maxf(float(b.in_tot), 1e-9), "recipes": b.recipes}
	return out


# Formula H's basket term of a pill class: heads of the realms whose basket buys that tier, times basket · bmix[pill]
# · fill.
static func basket_demand(gd: GameData, cid: String, heads: Array, fill: Array) -> float:
	var cfg: Dictionary = _cfg(gd)
	var tp: Array = cfg.crafted.tp_by_realm
	var basket: Array = cfg.demand.basket
	var t: int = int(cid.substr(KIND.length()))
	var d: float = 0.0
	for rl in mini(heads.size(), basket.size()):
		if int(tp[rl]) == t:
			d += float(heads[rl]) * float(basket[rl]) * float(cfg.classes.bmix.get(KIND, 0.0)) * (float(fill[rl]) if rl < fill.size() else 1.0)
	return d


## Season 0 (Formula E's calibration): each market's pill classes, the plan at rest plan_ref = D · (1 + dk (c_ref − 1)),
## starting stock c_ref · D − plan_ref. Returns the craft input each market draws at rest {market id: {good: value}},
## which the raw calibration adds to demand (AC-RE-51).
static func build(gd: GameData, db: WorldDB, heads_by_market: Dictionary) -> Dictionary:
	var cfg: Dictionary = _cfg(gd)
	var rec := class_recipes(gd)
	var dk: float = float(cfg.classes.dk[KIND])
	var cref: float = float(cfg.classes.c_ref[KIND])
	var ps: float = float(cfg.crafted.ps)
	var draws := {}
	for m in WorldEconomy._sorted_markets(db):
		var heads: Array = heads_by_market.get(str(m.id), [0, 0, 0, 0, 0])
		var crafted := {}
		var draw := {}
		var cids: Array = rec.keys()
		cids.sort()
		for cid in cids:
			var d: float = basket_demand(gd, cid, heads, [1.0, 1.0, 1.0, 1.0, 1.0])
			var plan_ref: float = d * (1.0 + dk * (cref - 1.0))
			var t: int = int(cid.substr(KIND.length()))
			var v_lo: float = float(cfg.crafted.v_lo[clampi(t - 1, 0, cfg.crafted.v_lo.size() - 1)])
			crafted[cid] = {"kind": KIND, "tier": t, "p": 1.0, "plan": plan_ref, "plan_ref": plan_ref, "fill": 1.0,
				"stock": maxf(0.0, cref * d - plan_ref), "s": plan_ref, "d": d, "cover": cref, "d_min": maxf(v_lo, 0.05 * d)}
			for g in rec[cid].a:
				draw[g] = float(draw.get(g, 0.0)) + plan_ref * float(rec[cid].a[g]) / (float(rec[cid].mu) * ps)
		m["crafted"] = crafted
		draws[str(m.id)] = draw
	return draws


## Formulas F and G before the raw stock update: for each market, each pill class's plan draws its inputs (need), the
## draw is capped by what each good holds on the shelf (fill, scaled so no good gives more than it holds), the draw
## [code]cd[/code] and last season's craft_in demand are added to the raw rows ([param pre] from WorldEconomy), and the
## output becomes the class's supply. Returns nothing; writes into [param pre] and the market records.
static func draw_inputs(gd: GameData, db: WorldDB, pre: Dictionary) -> void:
	var cfg: Dictionary = _cfg(gd)
	var rec := class_recipes(gd)
	var ps: float = float(cfg.crafted.ps)
	for m in WorldEconomy._sorted_markets(db):
		if not m.has("crafted"):
			continue
		var rows: Dictionary = pre.get(str(m.id), {})
		var units: Array = []   # [class, recipe, {good: need}] in class then recipe order
		var raw := {}    # Σ over recipes of need · fill (before the scale)
		var cids: Array = m.crafted.keys()
		cids.sort()
		for cid in cids:
			var c: Dictionary = m.crafted[cid]
			for rr in rec.get(cid, {}).get("recipes", []):
				var nd := {}
				for g in rr.a:
					nd[g] = float(c.plan) * float(rr.share) * float(rr.a[g]) / (float(rr.mu) * ps)
				units.append([cid, rr, nd, 1.0])
		# each recipe's fill: the least share of its inputs the shelves can give, then scaled so the recipes together
		# never draw more of a good than it holds (Formula F's draw scale)
		for u in units:
			var f: float = 1.0
			for g in u[2]:
				f = minf(f, 1.0 if float(u[2][g]) <= 0.0 else minf(1.0, _avail(gd, rows, str(g)) / float(u[2][g])))
			u[3] = f
			for g in u[2]:
				raw[g] = float(raw.get(g, 0.0)) + float(u[2][g]) * f
		for u in units:
			var sc: float = 1.0
			for g in u[2]:
				if float(raw.get(g, 0.0)) > 0.0:
					sc = minf(sc, minf(1.0, _avail(gd, rows, str(g)) / float(raw[g])))
			u[3] = float(u[3]) * sc
		var out := {}
		for u in units:
			var c: Dictionary = m.crafted[u[0]]
			for g in u[2]:
				var rcid: String = WorldEconomy.class_of(gd, str(g))
				if not rows.has(rcid):
					continue
				var r: Dictionary = rows[rcid]
				r.bought[str(g)] = float(r.bought.get(str(g), 0.0)) + float(u[2][g]) * float(u[3])   # a specific draw
				var ci: float = float(u[2][g]) * float(c.get("fill", 1.0))   # Formula G: last season's fill
				r["craft_in"] = float(r.get("craft_in", 0.0)) + ci
				r.d = float(r.d) + ci
			out[u[0]] = float(out.get(u[0], 0.0)) + float(u[1].share) * float(u[3])
		for cid in cids:
			var c: Dictionary = m.crafted[cid]
			c["fill_now"] = float(out.get(cid, 0.0))   # the class's fill: its recipes' fills by output share
			c["out"] = float(c.plan) * float(c.fill_now)


# What a good holds on the shelf for workshops this season: its pre-draw value if shelved (Formula B's X_pre), else 0.
static func _avail(gd: GameData, rows: Dictionary, good: String) -> float:
	var rcid: String = WorldEconomy.class_of(gd, good)
	if not rows.has(rcid):
		return 0.0
	var r: Dictionary = rows[rcid]
	if float(r.ex.get(good, 0.0)) <= 0.0:   # unshelved: workshops cannot draw it
		return 0.0
	return maxf(0.0, float(r.x_pre.get(good, 0.0)) - float(r.bought.get(good, 0.0)))


## After the raw classes' prices (step (e)): each pill class's demand, price, stock and next plan (Formulas E, F, H).
static func settle(gd: GameData, db: WorldDB, heads_by_market: Dictionary) -> void:
	var cfg: Dictionary = _cfg(gd)
	var rec := class_recipes(gd)
	for m in WorldEconomy._sorted_markets(db):
		if not m.has("crafted"):
			continue
		var heads: Array = heads_by_market.get(str(m.id), [0, 0, 0, 0, 0])
		var pl: Dictionary = m.get("player", {})
		for cid in m.crafted:
			var c: Dictionary = m.crafted[cid]
			var d_pre: float = basket_demand(gd, cid, heads, m.fill)
			var cap: float = float(cfg.shop.player_cap) * d_pre
			var p_eff: float = clampf(float(pl.get("buy", {}).get(cid, 0.0)) - float(pl.get("sell", {}).get(cid, 0.0)), -cap, cap)
			var d: float = maxf(0.0, d_pre + p_eff)
			var s: float = float(c.get("out", 0.0)) + float(pl.get("sell", {}).get(cid, 0.0))
			var strained: bool = float(c.cover) < float(cfg.price.c_short)
			var pr := EconomyRules.price(cfg, KIND, float(c.p), float(c.stock), s, d, float(c.d_min), strained)
			var st := EconomyRules.stock_update(cfg, KIND, float(c.stock), s, d, float(c.d_min))
			c.p = snappedf(float(pr.p), 0.000001)
			c.cover = float(pr.cover)
			c.s = s
			c.d = d
			c.stock = float(st.stock)
			# Formula F: the next plan from the price over the inputs' cost and the cover
			var cost: float = 0.0
			for g in rec.get(cid, {}).get("a", {}):
				var rc: String = WorldEconomy.class_of(gd, str(g))
				var pin: float = float(m.classes.get(rc, {}).get("p", 1.0)) * WorldEconomy.scarcity_factor(gd, db, str(m.id), str(g))
				cost += float(rec[cid].a[g]) * pin
			c.plan = float(plan_next(cfg, float(c.plan), float(c.plan_ref), float(c.p) / maxf(cost, 1e-9), float(c.cover), float(c.get("fill_now", 1.0))).plan)
			c.fill = float(c.get("fill_now", 1.0))


## Formula F's plan update from the plan, the plan at rest, the price over the inputs' cost [param ratio], the cover and
## this season's fill: plan* = plan_ref · r^κ · (c_ref / max(c, c_lo))^λ; plan' = clamp(p̂ (plan*/p̂)^α_p, p̂/δ_p, p̂ δ_p)
## with p̂ = max(plan, φ_p plan_ref); never above the plan when the fill is under fill_tol. {star, plan}.
static func plan_next(cfg: Dictionary, plan: float, plan_ref: float, ratio: float, cover: float, fill: float) -> Dictionary:
	var cr: Dictionary = cfg.crafted
	if plan_ref <= 0.0:
		return {"star": 0.0, "plan": 0.0}
	var star: float = plan_ref * pow(ratio, float(cr.kappa)) * pow(float(cfg.classes.c_ref[KIND]) / maxf(cover, float(cr.c_lo)), float(cr.lambda))
	var p_hat: float = maxf(plan, float(cr.phi_p) * plan_ref)
	var nxt: float = clampf(p_hat * pow(star / p_hat, float(cr.alpha_p)), p_hat / float(cr.delta_p), p_hat * float(cr.delta_p))
	if fill < float(cr.fill_tol):   # no windup: a short class does not plan more
		nxt = minf(nxt, plan)
	return {"star": star, "plan": nxt}


## Heads by realm in each market (the contract's pop_cultivators summed over its regions).
static func heads_by_market(db: WorldDB, heads_by_region: Dictionary) -> Dictionary:
	var out := {}
	for m in WorldEconomy._sorted_markets(db):
		var h := [0, 0, 0, 0, 0]
		for rid in m.regions:
			var hr: Array = heads_by_region.get(rid, [0, 0, 0, 0, 0])
			for i in 5:
				h[i] = int(h[i]) + int(hr[i])
		out[str(m.id)] = h
	return out
