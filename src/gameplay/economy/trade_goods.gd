class_name TradeGoods
extends RefCounted

## Trade Goods (design/gdd/trade-goods.md rules 7-9, 8a; Formulas B, C, D): the named goods inside a market's class
## pools. A raw good's class is its kind and rarity band ([method class_of]: band = ceil(rarity / 2)); each class pool
## carries a composition (each good's value), updated each season by Formula B ([method compose]); a good's shop price
## is its class's local price times its scarcity factor (Formula D, [method scarcity]); a good made by 3 or fewer regions
## is a specialty (Formula C, [method specialties]). Pure functions over plain dictionaries; [WorldEconomy] keeps the
## state. Values are economy.json's [code]goods[/code] block.


## The rarity band of a rarity (rule 8a): 1-2 -> 1, 3-4 -> 2, 5-6 -> 3.
static func band_of(rarity: int) -> int:
	return int(ceil(maxf(1.0, float(rarity)) / 2.0))


## The raw class id of a good: its kind and band ("herb2"). [param kind] from [method WorldEconomy.kind_of].
static func class_of(gd: GameData, good_id: String, kind: String) -> String:
	var r: int = 1
	var h: Dictionary = gd.herb(good_id)
	if not h.is_empty():
		r = int(h.get("rarity", 1))
	else:
		r = int(gd.material(good_id).get("rarity", 1))
	return "%s%d" % [kind, band_of(r)]


## A good's unit value V_g (Item Database rule 9): a herb's base value, a material's template value.
static func unit_value(gd: GameData, good_id: String) -> float:
	var h: Dictionary = gd.herb(good_id)
	if not h.is_empty():
		return maxf(1.0, float(h.get("base_value", 1)))
	return maxf(1.0, float(gd.material(good_id).get("base_value", 1)))


## Formula B for one class pool. [param pool] {good: X'_prev} (last tick's end values), [param stock] that pool's
## class stock before this tick (Σ X'_prev), [param own] {good: S_own} this season's own supply, [param imports]
## {good: value} already split by the exporters' shares, [param sold] / [param bought] the player's sales and
## purchases {good: value}, [param draw] the class's shared draw (exports first, then spoilage, the rest of demand and
## the overflow; #43 Formulas D and F) and [param exports] the exported value, both in base value. [param v] {good:
## V_g}. Returns {pool: {good: X'}, shelved: Σ X' of goods at one unit or more, ex: {good: export share}}.
static func compose(cfg: Dictionary, pool: Dictionary, own: Dictionary, imports: Dictionary, sold: Dictionary,
		bought: Dictionary, draw: float, exports: float, v: Dictionary) -> Dictionary:
	var dust: float = float(cfg.goods.dust)
	var goods: Array = []
	for d in [pool, own, imports, sold, bought]:
		for g in d:
			if not goods.has(g):
				goods.append(g)
	goods.sort()
	# pre-draw value of each good (X_pre): last end value + own supply + the player's sales, less the player's purchase
	var x_pre := {}
	for g in goods:
		var vg: float = float(pool.get(g, 0.0)) + float(own.get(g, 0.0)) + float(sold.get(g, 0.0))
		x_pre[g] = maxf(0.0, vg - minf(float(bought.get(g, 0.0)), vg))
	# shelved this tick: last tick's end value at one unit or more
	var shelved := {}
	var sh_pre: float = 0.0
	for g in goods:
		if float(pool.get(g, 0.0)) >= float(v.get(g, 1.0)):
			shelved[g] = true
			sh_pre += float(x_pre[g])
	var ex := {}
	for g in goods:
		ex[g] = float(x_pre[g]) / sh_pre if shelved.has(g) and sh_pre > 0.0 else 0.0
	var x := {}
	for g in goods:
		x[g] = float(x_pre[g]) + float(imports.get(g, 0.0)) - exports * float(ex[g])
	var rest: float = maxf(0.0, draw - exports)
	var sh_x: float = 0.0
	for g in shelved:
		sh_x += maxf(0.0, float(x[g]))
	var take: float = minf(rest, sh_x)   # the shared draw is capped at the shelved value
	var out := {}
	var stock_sh: float = 0.0
	for g in goods:
		var e: float = float(x[g])
		if shelved.has(g) and sh_x > 0.0:
			e -= take * maxf(0.0, e) / sh_x
		e = maxf(0.0, e)
		var inflow: float = float(own.get(g, 0.0)) + float(imports.get(g, 0.0)) + float(sold.get(g, 0.0))
		if inflow <= 0.0 and e < dust * float(v.get(g, 1.0)):
			e = 0.0
		if e > 0.0:
			out[g] = e
			if e >= float(v.get(g, 1.0)):
				stock_sh += e
	return {"pool": out, "shelved": stock_sh, "ex": ex}


## Formula D: each good's scarcity factor in a class pool [param pool] {good: X'} against the world shares
## [param wsh] {good: share of the world's class pool}, normalised so the shelved goods' share-weighted mean is 1.
## [param v] {good: V_g}. Returns {good: sf}; a good absent here (and nothing to normalise against) takes the raw limit.
static func scarcity(cfg: Dictionary, pool: Dictionary, wsh: Dictionary, v: Dictionary) -> Dictionary:
	var sigma: float = float(cfg.goods.sigma)
	var eta: float = float(cfg.goods.eta)
	var wmin: float = float(cfg.goods.wsh_min)
	var total: float = 0.0
	for g in pool:
		total += float(pool[g])
	var raw := {}
	for g in wsh:
		var w: float = maxf(float(wsh[g]), wmin)
		var sh: float = 0.0 if total <= 0.0 else float(pool.get(g, 0.0)) / total
		raw[g] = pow((sh + sigma * w) / ((1.0 + sigma) * w), -eta)
	var stock_sh: float = 0.0
	for g in pool:
		if float(pool[g]) >= float(v.get(g, 1.0)):
			stock_sh += float(pool[g])
	var mean: float = 0.0
	for g in pool:
		if float(pool[g]) >= float(v.get(g, 1.0)) and raw.has(g):
			mean += float(pool[g]) / stock_sh * float(raw[g])
	var out := {}
	for g in raw:
		out[g] = float(raw[g]) if stock_sh <= 0.0 or mean <= 0.0 or float(wsh.get(g, 0.0)) <= 0.0 else float(raw[g]) / mean
	return out


## Formula C: the specialties among [param by_region] {region: {good: value}}: goods 1 to N_spec regions make at
## max(V_g / 16, θ_s · the top region's output) or more. Returns {good: [regions]}.
static func specialties(cfg: Dictionary, by_region: Dictionary, v: Dictionary) -> Dictionary:
	var theta: float = float(cfg.goods.theta_s)
	var n_spec: int = int(cfg.goods.n_spec)
	var top := {}
	for r in by_region:
		for g in by_region[r]:
			top[g] = maxf(float(top.get(g, 0.0)), float(by_region[r][g]))
	var out := {}
	for g in top:
		var bar: float = maxf(float(v.get(g, 1.0)) / 16.0, theta * float(top[g]))
		var rs: Array = []
		for r in by_region:
			if float(by_region[r].get(g, 0.0)) >= bar and float(by_region[r].get(g, 0.0)) > 0.0:
				rs.append(r)
		rs.sort()
		if rs.size() >= 1 and rs.size() <= n_spec:
			out[g] = rs
	return out
