class_name CraftEconomy
extends RefCounted

## Crafted goods as priced classes (design/gdd/trade-goods.md rules 11-14, Formulas E, F, G, H): each market's
## workshops turn raw goods into pills, talismans and artifacts, each kind split into value tiers, on a plan that answers
## the class's price against its inputs' cost and its cover. A recipe's inputs are named goods (a pill's herbs) or a
## group ("any material of rarity r or more", a talisman's or an artifact's), spread over the group's goods on the shelf
## by their available value. The plan's inputs are demand in the raw classes (craft_in) and a draw from their pools
## (cd), capped by what the shelves hold; its output is the crafted class's supply. Demand: the pill share of the
## provision baskets (each realm buys its own tier), Military's goods spending on talismans and artifacts (spread over
## tiers by the realms' heads and baskets), and the player's buying. Price and stock follow Regional Economy Formulas D
## and E with each kind's parameters. All in base value; workshops move goods, not money.
##
## Not yet (plan production/plans/world-economy.md): breakthrough demand (D_bt, a Realms handoff), crafted flows between
## markets, origin tags, regional crafted supply. State lives on each market record's [code]crafted[/code] block.

const KINDS := ["pill", "talisman", "artifact"]


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
	return "pill%d" % tier_of(gd, float(recipe.get("price", 1)))


## The crafted class of a finished item: a pill by its recipe's price, a talisman or artifact by its own value at quality
## 0 (Formula E's V_q0). "" for anything else.
static func class_of_item(gd: GameData, item: Dictionary, value: float) -> String:
	match str(item.get("kind", "")):
		"pill":
			var r: Dictionary = gd.recipe(str(item.get("template", "")))
			return "" if r.is_empty() else class_of_recipe(gd, r)
		"talisman":
			return "talisman%d" % tier_of(gd, value)
		"artifact":
			return "artifact%d" % tier_of(gd, value)
	return ""


## The kind of a crafted class id ("artifact3" -> "artifact").
static func kind_of_class(cid: String) -> String:
	return cid.rstrip("0123456789")


# The materials of rarity [param r] or more (a talisman's or artifact's input group), with the cheapest one's value.
static func _group(gd: GameData, r: int) -> Dictionary:
	var goods: Array = []
	var v_min: float = INF
	for m in gd.materials():
		if int(m.get("rarity", 1)) >= r and str(m.id) != "linh_thach_khoang":
			goods.append(str(m.id))
			v_min = minf(v_min, float(m.get("base_value", 1)))
	goods.sort()
	return {"goods": goods, "v": v_min if v_min < INF else 1.0}


## Every crafted class and its recipes: {cid: {kind, tier, realm, recipes: [{id, out, share, mu, a | group}]}}. A pill
## recipe's inputs are its herbs at their mature-equivalent value (Item Database Formula B); a talisman's are
## `materials` of `material_rarity` or more; an artifact's (one per refining tier) are that tier's materials of its
## minimum rarity, valued at the cheapest eligible good (what a workshop uses), its output the tier's expected value
## over the grades. A class's realm is the realm whose basket or Military spending it serves (Formula H's ω).
static func specs(gd: GameData) -> Dictionary:
	var key: int = gd.get_instance_id()   # built once per game data (the recipes are data)
	if _specs_cache.has(key):
		return _specs_cache[key]
	var built := _build_specs(gd)
	_specs_cache[key] = built
	return built


static var _specs_cache: Dictionary = {}


static func _build_specs(gd: GameData) -> Dictionary:
	var by := {}
	for r in gd.recipes():   # pills
		var cid: String = class_of_recipe(gd, r)
		var a := {}
		var tot: float = 0.0
		for ing in r.ingredients:
			var v: float = float(ing.qty) * ItemFactory.equivalents_at(gd, str(ing.herb), float(ing.min_age)) * float(gd.herb(str(ing.herb)).get("base_value", 1))
			a[str(ing.herb)] = float(a.get(str(ing.herb), 0.0)) + v
			tot += v
		for g in a:
			a[g] = float(a[g]) / maxf(tot, 1e-9)
		_add(by, cid, int(cid.substr(4)) - 1, {"id": str(r.id), "out": float(r.get("price", 1)) * float(r.get("yield", 1)), "a": a, "in": tot})
	for t in gd.file("crafting_talismans").get("talismans", []):
		var g: Dictionary = _group(gd, int(t.get("material_rarity", 1)))
		var out_v: float = float(t.base_value) * float(t.get("yield", 1))
		var cid: String = "talisman%d" % tier_of(gd, float(t.base_value))
		_add(by, cid, clampi(int(t.get("material_rarity", 1)) - 1, 0, 4), {"id": str(t.id), "out": out_v, "group": g.goods, "in": float(t.get("materials", 1)) * float(g.v)})
	var rf: Dictionary = gd.file("crafting_refining")
	var af: Dictionary = gd.file("items_artifacts")
	var base_mean: float = 0.0
	for b in af.get("bases", []):
		base_mean += float(b.get("base_value", 1))
	base_mean /= maxf(1.0, float(af.get("bases", []).size()))
	var gw: float = 0.0
	var gv: float = 0.0
	for gr in af.get("grades", []):
		gw += float(gr.get("weight", 1))
		gv += float(gr.get("weight", 1)) * float(gr.get("value_mult", 1))
	for ti in Array(rf.get("materials", [])).size():
		var g: Dictionary = _group(gd, int(rf.min_rarity[ti]))
		var out_v: float = base_mean * gv / maxf(gw, 1e-9) * float(af.tiers[ti].get("value_scale", 1))
		var cid: String = "artifact%d" % tier_of(gd, out_v)
		_add(by, cid, ti, {"id": "refine_%d" % ti, "out": out_v, "group": g.goods, "in": float(rf.materials[ti]) * float(g.v)})
	for cid in by:
		var tot: float = 0.0
		for rr in by[cid].recipes:
			tot += float(rr.out)
		for rr in by[cid].recipes:
			rr["share"] = float(rr.out) / maxf(tot, 1e-9)
			rr["mu"] = float(rr.out) / maxf(float(rr["in"]), 1e-9)
	return by


static func _add(by: Dictionary, cid: String, realm: int, recipe: Dictionary) -> void:
	if not by.has(cid):
		by[cid] = {"kind": kind_of_class(cid), "tier": int(cid.substr(kind_of_class(cid).length())), "realm": realm, "recipes": []}
	by[cid].recipes.append(recipe)
	by[cid].realm = mini(int(by[cid].realm), realm)


# Formula H: a class's demand this season. Pills: the heads of the realms whose basket buys that tier × basket ×
# bmix[pill] × fill. Talismans and artifacts: Military's goods spending × mil_cr[kind] × ω, ω the class's share of the
# kind's classes by the heads × baskets of the realms they serve.
static func class_demand(gd: GameData, spec: Dictionary, all_specs: Dictionary, heads: Array, fill: Array, mil_spend: float) -> float:
	var cfg: Dictionary = _cfg(gd)
	var basket: Array = cfg.demand.basket
	var kind: String = str(spec.kind)
	if kind == "pill":
		var tp: Array = cfg.crafted.tp_by_realm
		var d: float = 0.0
		for rl in mini(heads.size(), basket.size()):
			if int(tp[rl]) == int(spec.tier):
				d += float(heads[rl]) * float(basket[rl]) * float(cfg.classes.bmix.get("pill", 0.0)) * (float(fill[rl]) if rl < fill.size() else 1.0)
		return d
	var w_self: float = 0.0
	var w_all: float = 0.0
	for cid in all_specs:
		if str(all_specs[cid].kind) != kind:
			continue
		var rl: int = clampi(int(all_specs[cid].realm), 0, mini(heads.size(), basket.size()) - 1)
		var w: float = float(heads[rl]) * float(basket[rl])
		w_all += w
		if all_specs[cid] == spec:
			w_self = w
	var share: float = 0.0 if w_all <= 0.0 else w_self / w_all
	return float(cfg.demand.goods_frac) * mil_spend * float(cfg.demand.mix.military.get(kind, 0.0)) * share


## Formula H's basket term of a pill class (kept for callers and tests): heads of the realms whose basket buys that tier.
static func basket_demand(gd: GameData, cid: String, heads: Array, fill: Array) -> float:
	return class_demand(gd, {"kind": "pill", "tier": int(cid.substr(4))}, {}, heads, fill, 0.0)


## Military's track spending (Formula H's spend_Mil, the mean of the last mil_window seasons) over a market's sects (its great sect and their vassals).
static func military_spend(db: WorldDB, m: Dictionary) -> float:
	var t: float = 0.0
	for s in db.all("sects"):
		if str(s.get("status", "")) != "active":
			continue
		if str(s.id) == str(m.sect_id) or str(s.get("lord_id", "")) == str(m.sect_id):
			t += SectEconomy.mil_spend_mean(s)   # Formula H: the mean of the last mil_window seasons
	return t


## Season 0 (Formula E's calibration): each market's crafted classes, the plan at rest plan_ref = D · (1 + dk (c_ref −
## 1)), starting stock c_ref · D − plan_ref. [param reached_g] {market id: {good: value}} spreads a group's inputs over
## its goods by the market's own supply. Returns the craft input each market draws at rest {market id: {good: value}},
## which the raw calibration adds to demand (AC-RE-51).
static func build(gd: GameData, db: WorldDB, heads_by_market: Dictionary, reached_g: Dictionary = {}) -> Dictionary:
	var cfg: Dictionary = _cfg(gd)
	var sp := specs(gd)
	var ps: float = float(cfg.crafted.ps)
	var draws := {}
	var cids: Array = sp.keys()
	cids.sort()
	for m in WorldEconomy._sorted_markets(db):
		var heads: Array = heads_by_market.get(str(m.id), [0, 0, 0, 0, 0])
		var mil: float = military_spend(db, m)
		var crafted := {}
		var draw := {}
		for cid in cids:
			var kind: String = str(sp[cid].kind)
			var dk: float = float(cfg.classes.dk[kind])
			var cref: float = float(cfg.classes.c_ref[kind])
			var d: float = class_demand(gd, sp[cid], sp, heads, [1.0, 1.0, 1.0, 1.0, 1.0], mil)
			var plan_ref: float = d * (1.0 + dk * (cref - 1.0))
			var t: int = int(sp[cid].tier)
			var v_lo: float = float(cfg.crafted.v_lo[clampi(t - 1, 0, cfg.crafted.v_lo.size() - 1)])
			crafted[cid] = {"kind": kind, "tier": t, "p": 1.0, "plan": plan_ref, "plan_ref": plan_ref, "fill": 1.0,
				"stock": maxf(0.0, cref * d - plan_ref), "s": plan_ref, "d": d, "cover": cref, "d_min": maxf(v_lo, 0.05 * d)}
			for rr in sp[cid].recipes:
				var need: float = plan_ref * float(rr.share) / (float(rr.mu) * ps)
				for g in _spread(rr, need, reached_g.get(str(m.id), {})):
					draw[g] = float(draw.get(g, 0.0)) + float(_spread(rr, need, reached_g.get(str(m.id), {}))[g])
		m["crafted"] = crafted
		draws[str(m.id)] = draw
	return draws


# A recipe's need of [param need] base value spread over its goods: a named recipe by its shares; a group by
# [param avail] {good: value available} (evenly when nothing is available).
static func _spread(rr: Dictionary, need: float, avail: Dictionary) -> Dictionary:
	var out := {}
	if rr.has("a"):
		for g in rr.a:
			out[g] = need * float(rr.a[g])
		return out
	var tot: float = 0.0
	for g in rr.group:
		tot += maxf(0.0, float(avail.get(g, 0.0)))
	for g in rr.group:
		out[g] = need / float(rr.group.size()) if tot <= 0.0 else need * maxf(0.0, float(avail.get(g, 0.0))) / tot
	return out


## Formulas F and G before the raw stock update: for each market, each recipe's share of its class's plan draws its
## inputs (a group's spread over the shelved goods by what each holds), the draw is capped by what each good holds on
## the shelf (fill, then scaled so no good gives more than it holds), the draw [code]cd[/code] and last season's
## craft_in demand are added to the raw rows ([param pre] from WorldEconomy), and the output becomes the class's supply.
static func draw_inputs(gd: GameData, db: WorldDB, pre: Dictionary) -> void:
	var cfg: Dictionary = _cfg(gd)
	var sp := specs(gd)
	var ps: float = float(cfg.crafted.ps)
	for m in WorldEconomy._sorted_markets(db):
		if not m.has("crafted"):
			continue
		var rows: Dictionary = pre.get(str(m.id), {})
		var avail := {}
		for cid in sp:
			for rr in sp[cid].recipes:
				for g in (rr.a.keys() if rr.has("a") else rr.group):
					avail[g] = _avail(gd, rows, str(g))
		var units: Array = []   # [class, recipe, {good: need}, fill] in class then recipe order
		var raw := {}
		var cids: Array = m.crafted.keys()
		cids.sort()
		for cid in cids:
			var c: Dictionary = m.crafted[cid]
			for rr in sp.get(cid, {}).get("recipes", []):
				var need: float = float(c.plan) * float(rr.share) / (float(rr.mu) * ps)
				units.append([cid, rr, _spread(rr, need, avail), 1.0])
		for u in units:   # each recipe's fill: the least share of its inputs the shelves can give
			var f: float = 1.0
			var nd: Dictionary = u[2]
			if u[1].has("a"):
				for g in nd:
					f = minf(f, 1.0 if float(nd[g]) <= 0.0 else minf(1.0, float(avail.get(g, 0.0)) / float(nd[g])))
			else:   # a group: what all its goods hold together
				var need_t: float = 0.0
				var have_t: float = 0.0
				for g in nd:
					need_t += float(nd[g])
					have_t += float(avail.get(g, 0.0))
				f = 1.0 if need_t <= 0.0 else minf(1.0, have_t / need_t)
			u[3] = f
			for g in nd:
				raw[g] = float(raw.get(g, 0.0)) + float(nd[g]) * f
		for u in units:   # the draw scale: together the recipes never draw more of a good than it holds
			var sc: float = 1.0
			for g in u[2]:
				if float(raw.get(g, 0.0)) > 0.0:
					sc = minf(sc, minf(1.0, float(avail.get(g, 0.0)) / float(raw[g])))
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


# What a good holds on the shelf for workshops this season: its pre-draw value if shelved (Formula B's X_pre), less
# what was already drawn, else 0.
static func _avail(gd: GameData, rows: Dictionary, good: String) -> float:
	var rcid: String = WorldEconomy.class_of(gd, good)
	if not rows.has(rcid):
		return 0.0
	var r: Dictionary = rows[rcid]
	if float(r.ex.get(good, 0.0)) <= 0.0:   # unshelved: workshops cannot draw it
		return 0.0
	return maxf(0.0, float(r.x_pre.get(good, 0.0)) - float(r.bought.get(good, 0.0)))


## After the raw classes' prices (step (e)): each crafted class's demand, price, stock and next plan (Formulas E, F, H).
static func settle(gd: GameData, db: WorldDB, heads_by_market: Dictionary) -> void:
	var cfg: Dictionary = _cfg(gd)
	var sp := specs(gd)
	for m in WorldEconomy._sorted_markets(db):
		if not m.has("crafted"):
			continue
		var heads: Array = heads_by_market.get(str(m.id), [0, 0, 0, 0, 0])
		var mil: float = military_spend(db, m)
		var pl: Dictionary = m.get("player", {})
		for cid in m.crafted:
			if not sp.has(cid):
				continue
			var c: Dictionary = m.crafted[cid]
			var kind: String = str(c.kind)
			var d_pre: float = class_demand(gd, sp[cid], sp, heads, m.fill, mil)
			var cap: float = float(cfg.shop.player_cap) * d_pre
			var p_eff: float = clampf(float(pl.get("buy", {}).get(cid, 0.0)) - float(pl.get("sell", {}).get(cid, 0.0)), -cap, cap)
			var d: float = maxf(0.0, d_pre + p_eff)
			var s: float = float(c.get("out", 0.0)) + float(pl.get("sell", {}).get(cid, 0.0))
			var strained: bool = float(c.cover) < float(cfg.price.c_short)
			var pr := EconomyRules.price(cfg, kind, float(c.p), float(c.stock), s, d, float(c.d_min), strained)
			var st := EconomyRules.stock_update(cfg, kind, float(c.stock), s, d, float(c.d_min))
			c.p = snappedf(float(pr.p), 0.000001)
			c.cover = float(pr.cover)
			c.s = s
			c.d = d
			c.stock = float(st.stock)
			# Formula F: the next plan from the price over the inputs' cost and the cover
			var cost: float = 0.0
			for rr in sp[cid].recipes:
				var goods: Array = rr.a.keys() if rr.has("a") else rr.group
				var rc_cost: float = 0.0
				for g in goods:
					var w: float = float(rr.a[g]) if rr.has("a") else 1.0 / float(goods.size())
					var rc: String = WorldEconomy.class_of(gd, str(g))
					rc_cost += w * float(m.classes.get(rc, {}).get("p", 1.0)) * WorldEconomy.scarcity_factor(gd, db, str(m.id), str(g))
				cost += float(rr.share) * rc_cost
			c.plan = float(plan_next(cfg, float(c.plan), float(c.plan_ref), float(c.p) / maxf(cost, 1e-9), float(c.cover), float(c.get("fill_now", 1.0)), kind).plan)
			c.fill = float(c.get("fill_now", 1.0))


## Formula F's plan update from the plan, the plan at rest, the price over the inputs' cost [param ratio], the cover and
## this season's fill: plan* = plan_ref · r^κ · (c_ref / max(c, c_lo))^λ; plan' = clamp(p̂ (plan*/p̂)^α_p, p̂/δ_p, p̂ δ_p)
## with p̂ = max(plan, φ_p plan_ref); never above the plan when the fill is under fill_tol. {star, plan}.
static func plan_next(cfg: Dictionary, plan: float, plan_ref: float, ratio: float, cover: float, fill: float, kind: String = "pill") -> Dictionary:
	var cr: Dictionary = cfg.crafted
	if plan_ref <= 0.0:
		return {"star": 0.0, "plan": 0.0}
	var star: float = plan_ref * pow(ratio, float(cr.kappa)) * pow(float(cfg.classes.c_ref[kind]) / maxf(cover, float(cr.c_lo)), float(cr.lambda))
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
