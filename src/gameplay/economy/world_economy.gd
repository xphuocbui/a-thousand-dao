class_name WorldEconomy
extends RefCounted

## The seasonal market tick of Regional Economy & Trade (design/gdd/regional-economy-trade.md rules 1-11, 19-20;
## Formulas A-E, L1): one market per great sect over the regions it holds; each season it reads the map's production
## contract (the regions' [code]production_value[/code]), works out access, supply, demand, stock and the price of each
## raw class, and writes each region's local price back as the [code]price_index[/code] Travel & Map's demand factor
## reads. The formulas are [EconomyRules]'; this class keeps the state, in the World DB's [code]markets[/code] table
## (one record per market, id [code]mk:<sect id>[/code]), so a saved world resumes the same.
##
## A raw class is a kind and rarity band (Trade Goods rule 8a: herb 1-3, ore 1-2, beast 1, special 1-2, from the goods
## that exist), taking its kind's parameters; goods map to kinds by the herb list and map_resources.json's
## resource_kind. Each class pool carries its composition (Trade Goods Formula B: each good's value), and price, cover
## and flows read the shelved part. A kind's demand is split over its bands by their season-0 world supply shares
## (bs). Each region's price_index holds its local price by class and, for Travel & Map's demand factor and the
## baskets, by kind (the value-weighted mean of the kind's classes). The sects' spending and the crafted classes join
## later steps of the plan (production/plans/world-economy.md).
##
## Usage:
## [codeblock]
## WorldEconomy.build(gd, db)     # once, at world generation: markets, d_scale calibration, starting stock
## WorldEconomy.season(gd, db)    # each season, after MapProduction.season
## [/codeblock]

const TABLE := "markets"
const FILE := "economy"


## The kind (raw class) of good [param good_id].
static func kind_of(gd: GameData, good_id: String) -> String:
	if not gd.herb(good_id).is_empty():
		return "herb"
	return str(gd.file(MapProduction.DATA_FILE).get("resource_kind", {}).get(good_id, "ore"))


## The raw class of good [param good_id] (Trade Goods rule 8a).
static func class_of(gd: GameData, good_id: String) -> String:
	var key: String = "%d|%s" % [gd.get_instance_id(), good_id]   # the goods' classes are data: cached
	var hit = _class_cache.get(key)
	if hit != null:
		return hit
	var c: String = TradeGoods.class_of(gd, good_id, kind_of(gd, good_id))
	_class_cache[key] = c
	return c


static var _class_cache: Dictionary = {}


## The kind a class id belongs to ("herb2" -> "herb").
static func kind_of_class(cid: String) -> String:
	return cid.rstrip("0123456789")


## The raw classes that exist: each kind's bands that hold a catalogued good (herbs, and materials whose resource kind
## is listed), in kind order then band.
static func class_ids(gd: GameData) -> Array:
	var cfg: Dictionary = gd.file(FILE)
	var seen := {}
	for h in gd.file("items_herbs").get("herbs", []):
		seen[TradeGoods.class_of(gd, str(h.id), "herb")] = true
	var rk: Dictionary = gd.file(MapProduction.DATA_FILE).get("resource_kind", {})
	for m in gd.materials():
		var k: String = str(rk.get(str(m.id), ""))
		if k == "" and str(m.id) in gd.file(MapProduction.DATA_FILE).get("ore_by_element", {}).values():
			k = "ore"
		if k == "" and str(m.id) == "tu_kim_sa":
			k = "ore"
		if k != "" and k != "linh_thach":
			seen[TradeGoods.class_of(gd, str(m.id), k)] = true
	var out: Array = []
	for k in cfg.classes.order:
		for b in [1, 2, 3]:
			if seen.has("%s%d" % [k, b]):
				out.append("%s%d" % [k, b])
	return out


## The market id of a sect id.
static func market_id(sect_id: String) -> String:
	return "mk:%s" % sect_id


## The market a region belongs to ("" when its holder is no active great sect).
static func market_of_region(db: WorldDB, region: Dictionary) -> String:
	var s: Dictionary = db.get_record("sects", str(region.get("holder", "")))
	if s.is_empty() or str(s.get("kind", "")) != "great" or str(s.get("status", "")) != "active":
		return ""
	return market_id(str(s.id))


## Creates the markets (rule 1), works out each region's distance to its market's hub, and calibrates each class's
## demand scale and starting stock so the no-shock world is at rest at P = 1 (Formula C's calibration, Formula D's
## starting stock).
static func build(gd: GameData, db: WorldDB, grid: TravelGrid = null) -> void:
	var cids: Array = class_ids(gd)
	for s in db.find("sects", func(x): return str(x.get("kind", "")) == "great" and str(x.get("status", "")) == "active"):
		var hub: Dictionary = db.get_record("places", str(s.get("hq_place_id", "")))
		var classes := {}
		for cid in cids:
			classes[cid] = {"kind": kind_of_class(cid), "p": 1.0, "stock": 0.0, "stock_sh": 0.0, "pool": {}, "s": 0.0, "d": 0.0,
				"cover": 0.0, "short": 0.0, "d_scale": 1.0, "d_min": 1.0, "bs": 1.0}
		db.put(TABLE, {"id": market_id(str(s.id)), "sect_id": str(s.id), "hub_place_id": str(hub.get("id", "")),
			"hub_tile": hub.get("tile", [0, 0]), "classes": classes, "regions": {}, "fill": [1.0, 1.0, 1.0, 1.0, 1.0],
			"player": {}, "season": 0})
	for r in db.all("regions"):
		var mid: String = market_of_region(db, r)
		if mid == "":
			continue
		var m: Dictionary = db.get_record(TABLE, mid)
		m.regions[str(r.id)] = {"d": _hub_distance(r, m, grid), "p_loc": {}}
	_build_links(gd, db, grid)
	_calibrate(gd, db)
	_world_shares(db)


# Rule 12's candidate links, once: markets whose territories border (a road link, hub to hub by the ground path) and,
# where they do not, markets that both hold a teleport array in their territory (an array link). Eligibility (Trade,
# Openness, war) is read each season by [method links].
static func _build_links(gd: GameData, db: WorldDB, grid: TravelGrid) -> void:
	var cd := ContinentData.from_game_data(gd)
	var markets: Array = _sorted_markets(db)
	var cid_market := {}
	var arrays := {}
	for m in markets:
		for rid in m.regions:
			cid_market[int(db.get_record("regions", rid).get("continent_id", -1))] = str(m.id)
	for p in db.all("places"):
		if bool(p.get("array", false)):
			var mid: String = market_of_region(db, db.get_record("regions", str(p.get("region_id", ""))))
			if mid != "":
				arrays[mid] = true
	var border := {}
	for cid in cd.regions:
		var a: String = str(cid_market.get(int(cid), ""))
		for nb in cd.regions[cid].get("neighbours", []):
			var b: String = str(cid_market.get(int(nb.region), ""))
			if a != "" and b != "" and a != b:
				border["%s|%s" % ([a, b] if a < b else [b, a])] = true
	var out: Array = []
	for i in markets.size():
		for j in range(i + 1, markets.size()):
			var a: Dictionary = markets[i]
			var b: Dictionary = markets[j]
			var key: String = "%s|%s" % [a.id, b.id]
			var road: bool = border.has(key)
			if not road and not (arrays.has(str(a.id)) and arrays.has(str(b.id))):
				continue
			var d: float = _hub_distance({"centre_tile": a.hub_tile}, b, grid)
			out.append({"a": str(a.id), "b": str(b.id), "d": d, "array": not road})
	db.put(TABLE, {"id": "mk_links", "links": out})


# Formula A's d_r: tiles along the ground path from the region's centre to the hub (straight-line when no path).
static func _hub_distance(region: Dictionary, market: Dictionary, grid: TravelGrid) -> float:
	var a := Vector2i(int(region.centre_tile[0]), int(region.centre_tile[1]))
	var b := Vector2i(int(market.hub_tile[0]), int(market.hub_tile[1]))
	if grid != null:
		var t: Dictionary = grid.trip(a, b)
		if not t.is_empty():
			var n: float = 0.0
			for st in t.steps:
				n += 1.0
			return n
	return Vector2(a).distance_to(Vector2(b))


# The season's inputs of one market: per class the reached value (Σ value · acc), the population need and, per
# region, value, access and own demand need.
static func _inputs(gd: GameData, db: WorldDB, m: Dictionary, heads_all: Dictionary = {}, wset_all: Dictionary = {}) -> Dictionary:
	var cfg: Dictionary = gd.file(FILE)
	var kinds: Array = cfg.classes.order
	var cids: Array = m.classes.keys()
	var sect: Dictionary = db.get_record("sects", str(m.sect_id))
	var lv: Dictionary = sect.get("levels", {})
	var heads_by_region: Dictionary = heads_all if not heads_all.is_empty() else _heads(db)
	var wset_by_region: Dictionary = wset_all if not wset_all.is_empty() else _settlement_weight(gd, db)
	var reached := {}
	var reached_g := {}
	var need := {}
	var regions := {}
	for cid in cids:
		reached[cid] = 0.0
		reached_g[cid] = {}
	for k in kinds:
		need[k] = 0.0
	for rid in m.regions:
		var r: Dictionary = db.get_record("regions", rid)
		var acc: float = float(EconomyRules.access(cfg, float(m.regions[rid].d), int(lv.get("trade", 0)), int(lv.get("military", 0)), bool(r.get("war", false))).acc)
		var val := {}
		for cid in cids:
			val[cid] = 0.0
		for g in r.get("production_value", {}):
			var cid: String = class_of(gd, str(g))
			if not val.has(cid):
				continue
			var gv: float = float(r.production_value[g])
			val[cid] = float(val[cid]) + gv
			reached[cid] = float(reached[cid]) + gv * acc
			reached_g[cid][str(g)] = float(reached_g[cid].get(str(g), 0.0)) + gv * acc
		var heads: Array = heads_by_region.get(rid, [0, 0, 0, 0, 0])
		var nd := {}
		for k in kinds:
			nd[k] = EconomyRules.population_need(cfg, k, heads, m.fill, float(wset_by_region.get(rid, 0.0)))
			need[k] = float(need[k]) + float(nd[k])
		regions[rid] = {"acc": acc, "value": val, "need": nd}
	return {"collect": _collect(cfg, int(lv.get("holdings", 0))), "reached": reached, "reached_g": reached_g, "need": need, "regions": regions}


# Sects F2: collect = s_max · (H + 1) / (H + 1 + H_half).
static func _collect(cfg: Dictionary, holdings: int) -> float:
	var s_max: float = float(cfg.supply.s_max)
	var half: float = float(cfg.supply.get("h_half", 6))
	return s_max * (holdings + 1) / (holdings + 1 + half)


# Heads by realm per region (the contract's pop_cultivators).
static func _heads(db: WorldDB) -> Dictionary:
	var place_region := {}
	for pl in db.all("places"):
		place_region[str(pl.id)] = str(pl.get("region_id", ""))
	var out := {}
	for p in db.living():
		if not bool(p.get("alive", false)) or bool(p.get("is_beast", false)):
			continue
		var rid: String = str(place_region.get(str(p.get("location_id", "")), ""))
		if rid == "":
			continue
		if not out.has(rid):
			out[rid] = [0, 0, 0, 0, 0]
		var rl: int = clampi(int(p.get("realm_index", 0)), 0, 4)
		out[rid][rl] = int(out[rid][rl]) + 1
	return out


# The contract's pop_settlement_weight per region: Σ of Travel & Map Formula H2's population P of its settlements
# (the kind weights city 8, town 4, market 3, village 1 where a place has no population record).
static func _settlement_weight(gd: GameData, db: WorldDB) -> Dictionary:
	var w: Dictionary = gd.file(FILE).shop.w_place
	var out := {}
	for p in db.all("places"):
		var rid: String = str(p.get("region_id", ""))
		if not w.has(str(p.get("kind", ""))) or bool(p.get("hidden", false)):
			continue
		var pop: float = float(p.local.pop) if p.has("local") else float(w[str(p.kind)])
		out[rid] = float(out.get(rid, 0.0)) + pop
	return out


# Formula C's calibration and Formula D's starting stock: Σ_m S / Σ_m D = 1 + dk · (c_ref − 1) for each class, D at
# the season-0 baskets with no shocks or spending; then each market starts at cover c_ref (stock max(0, c_ref · D − S)).
static func _calibrate(gd: GameData, db: WorldDB) -> void:
	var cfg: Dictionary = gd.file(FILE)
	var kinds: Array = cfg.classes.order
	var markets: Array = _sorted_markets(db)
	var ins := {}
	var s_tot := {}
	var n_tot := {}
	for k in kinds:
		s_tot[k] = 0.0
		n_tot[k] = 0.0
	var heads_all := _heads(db)
	var wset_all := _settlement_weight(gd, db)
	for m in markets:
		ins[str(m.id)] = _inputs(gd, db, m, heads_all, wset_all)
	# Trade Goods Formulas E and G: the crafted classes at rest, and the raw inputs their workshops draw; with the sects'
	# goods spending (Formula C's goods_frac term), d_scale is solved against them (AC-RE-51)
	var reached := {}
	for mid in ins:
		var rg := {}
		for cid in ins[mid].reached_g:
			for g in ins[mid].reached_g[cid]:
				rg[g] = float(ins[mid].reached_g[cid][g])
		reached[mid] = rg
	var craft_draw: Dictionary = CraftEconomy.build(gd, db, CraftEconomy.heads_by_market(db, heads_all), reached)
	var sect_k := {}
	for m in markets:
		var sd := _sect_raw_demand(gd, db, m)
		for k in sd:
			sect_k[k] = float(sect_k.get(k, 0.0)) + float(sd[k])
	var craft_kind := {}
	var craft_cls := {}
	for mid in craft_draw:
		for g in craft_draw[mid]:
			var gk: String = kind_of(gd, str(g))
			craft_kind[gk] = float(craft_kind.get(gk, 0.0)) + float(craft_draw[mid][g])
			var gc: String = class_of(gd, str(g))
			if not craft_cls.has(mid):
				craft_cls[mid] = {}
			craft_cls[mid][gc] = float(craft_cls[mid].get(gc, 0.0)) + float(craft_draw[mid][g])
	var s_cls := {}
	for m in markets:
		var x: Dictionary = ins[str(m.id)]
		for cid in m.classes:
			var k: String = kind_of_class(cid)
			var sv: float = EconomyRules.supply(cfg, float(x.collect), float(x.reached[cid]))
			s_tot[k] = float(s_tot[k]) + sv
			s_cls[cid] = float(s_cls.get(cid, 0.0)) + sv
		for k in kinds:
			n_tot[k] = float(n_tot[k]) + float(cfg.classes.bmix.get(k, 0.0)) * float(x.need[k])
	var dscale := {}
	for k in kinds:
		var target: float = 1.0 + float(cfg.classes.dk[k]) * (float(cfg.classes.c_ref[k]) - 1.0)
		dscale[k] = 1.0 if float(n_tot[k]) <= 0.0 else maxf(0.0, float(s_tot[k]) / target - float(craft_kind.get(k, 0.0)) - float(sect_k.get(k, 0.0))) / float(n_tot[k])
	var bs := {}
	for cid in s_cls:   # Trade Goods rule 8a: a band's share of its kind's season-0 world supply
		var k: String = kind_of_class(cid)
		bs[cid] = 0.0 if float(s_tot[k]) <= 0.0 else float(s_cls[cid]) / float(s_tot[k])
	for m in markets:
		var x: Dictionary = ins[str(m.id)]
		var sd_m := _sect_raw_demand(gd, db, m)
		for cid in m.classes:
			var k: String = kind_of_class(cid)
			var c: Dictionary = m.classes[cid]
			c.d_scale = dscale[k]
			c.bs = float(bs.get(cid, 0.0))
			var s: float = EconomyRules.supply(cfg, float(x.collect), float(x.reached[cid]))
			var d: float = c.bs * (EconomyRules.demand(cfg, k, float(dscale[k]), float(x.need[k])) + float(sd_m.get(k, 0.0))) + float(craft_cls.get(str(m.id), {}).get(cid, 0.0))
			c.d_min = maxf(1.0, float(cfg.demand.d_min_share) * d)
			c.stock = maxf(0.0, float(cfg.classes.c_ref[k]) * d - s)
			if c.stock <= 0.0:   # a glut market starts with what its first season would leave (Formula D), so its shelves are not empty
				c.stock = (1.0 - float(cfg.classes.dk[k])) * maxf(0.0, s - d)
			# the starting pool is made of the market's own goods in their supply shares (all on the shelf)
			var pool := {}
			var rg: Dictionary = x.reached_g[cid]
			var rsum: float = 0.0
			for g in rg:
				rsum += float(rg[g])
			for g in rg:
				if rsum > 0.0 and float(rg[g]) > 0.0:
					pool[g] = c.stock * float(rg[g]) / rsum
			c.pool = pool
			c.stock_sh = _shelved(gd, pool)
			c.s = s
			c.d = d
			c.cover = (c.stock + s) / maxf(d, c.d_min)
		for rid in x.regions:   # each region's own demand (Formula L1's D_r), which the shops' slippage reads from day one
			var d_own := {}
			for cid in m.classes:
				var k: String = kind_of_class(cid)
				d_own[cid] = float(bs.get(cid, 0.0)) * float(dscale[k]) * float(cfg.classes.bmix.get(k, 0.0)) * float(x.regions[rid].need[k])
			m.regions[rid]["d_r"] = d_own
	db.put(TABLE, {"id": "mk_calibration", "d_scale": dscale, "bs": bs})


# The shelved part of a class pool: goods at one unit or more (Trade Goods Formula B).
static func _shelved(gd: GameData, pool: Dictionary) -> float:
	var t: float = 0.0
	for g in pool:
		if float(pool[g]) >= TradeGoods.unit_value(gd, str(g)):
			t += float(pool[g])
	return t


## One season of every market (rule 19 steps (a), (c), (d), (e)): supply and demand, the flows on the links between
## markets (Formula F, paid pool to pool with the importer's tariff to its sect, Formula H), then stock, price, local
## prices and the price_index written back to the regions. [param money] books the flows' payments (a ledger over
## [param db] when null).
static func season(gd: GameData, db: WorldDB, money: MoneyLedger = null) -> void:
	var cfg: Dictionary = gd.file(FILE)
	var kinds: Array = cfg.classes.order
	if money == null:
		money = MoneyLedger.new(db)
	_sync_regions(db)
	var markets: Array = _sorted_markets(db)
	var ins := {}
	var pre := {}
	var heads_all := _heads(db)
	var wset_all := _settlement_weight(gd, db)
	for m in markets:   # (c) supply before flows, and demand
		var x := _inputs(gd, db, m, heads_all, wset_all)
		ins[str(m.id)] = x
		var sd_m := _sect_raw_demand(gd, db, m)
		var pl: Dictionary = m.get("player", {})
		var hf: float = EconomyRules.h_f(cfg, float(x.collect))
		var row := {}
		for cid in m.classes:
			var k: String = kind_of_class(cid)
			var c: Dictionary = m.classes[cid]
			c["tariff_in"] = 0.0
			var s: float = EconomyRules.supply(cfg, float(x.collect), float(x.reached[cid]))
			var d_pre: float = float(c.bs) * (EconomyRules.demand(cfg, k, float(c.d_scale), float(x.need[k])) + float(sd_m.get(k, 0.0)))
			var cap: float = float(cfg.shop.player_cap) * d_pre
			var p_eff: float = clampf(float(pl.get("buy", {}).get(cid, 0.0)) - float(pl.get("sell", {}).get(cid, 0.0)), -cap, cap)
			var own := {}
			for g in x.reached_g[cid]:
				own[g] = hf * float(x.reached_g[cid][g])
			var sold: Dictionary = pl.get("sold_g", {}).get(cid, {})
			var bought: Dictionary = pl.get("bought_g", {}).get(cid, {})
			# each good's pre-draw value and the export shares of the shelved goods (Formula B's X_pre and ex)
			var x_pre := {}
			var sh_tot: float = 0.0
			var s_sh: float = 0.0
			for g in _goods(c.pool, own, sold, bought):
				var vg: float = float(c.pool.get(g, 0.0)) + float(own.get(g, 0.0)) + float(sold.get(g, 0.0))
				x_pre[g] = maxf(0.0, vg - minf(float(bought.get(g, 0.0)), vg))
				if float(c.pool.get(g, 0.0)) >= TradeGoods.unit_value(gd, str(g)):
					sh_tot += float(x_pre[g])
					s_sh += float(own.get(g, 0.0))
			var ex := {}
			for g in x_pre:
				ex[g] = float(x_pre[g]) / sh_tot if sh_tot > 0.0 and float(c.pool.get(g, 0.0)) >= TradeGoods.unit_value(gd, str(g)) else 0.0
			row[cid] = {"s": s, "s_sh": s_sh, "d": maxf(0.0, d_pre + p_eff), "imp": 0.0, "exp": 0.0, "own": own, "sold": sold,
				"bought": bought, "x_pre": x_pre, "ex": ex, "avail": maxf(0.0, sh_tot - maxf(0.0, d_pre + p_eff)), "imp_g": {}}
		pre[str(m.id)] = row
	CraftEconomy.draw_inputs(gd, db, pre)   # Trade Goods Formulas F and G: the workshops' draw and craft_in demand
	for mid in pre:
		for cid in pre[mid]:
			pre[mid][cid].avail = maxf(0.0, float(pre[mid][cid].avail) - float(pre[mid][cid].get("craft_in", 0.0)))
	if bool(cfg.links.get("enabled", true)):
		_flows(gd, db, money, pre)   # (d)
	for m in markets:   # (e)
		var x: Dictionary = ins[str(m.id)]
		var tot_value := {}
		var tot_d := {}
		for cid in m.classes:
			var k: String = kind_of_class(cid)
			var c: Dictionary = m.classes[cid]
			var r: Dictionary = pre[str(m.id)][cid]
			var s: float = float(r.s) + float(r.imp) - float(r.exp)
			var d: float = float(r.d)
			var strained: bool = float(c.cover) < float(cfg.price.c_short)
			# price and cover read the shelved stock and the shelved goods' supply (Trade Goods Formula B)
			var pr := EconomyRules.price(cfg, k, float(c.p), float(c.stock_sh), float(r.s_sh) + float(r.imp) - float(r.exp), d, float(c.d_min), strained)
			# the shared draw: exports first, then demand, spoilage and the storage overflow (#43 Formula D)
			var total: float = float(r.imp)
			for g in r.x_pre:
				total += float(r.x_pre[g])
			var left: float = maxf(0.0, total - float(r.exp) - d)
			var d_shared: float = maxf(0.0, d - float(r.get("craft_in", 0.0)))   # the workshops' draw is goods-specific (in bought)
			var spoil: float = float(cfg.classes.dk[k]) * left
			var over: float = maxf(0.0, (left - spoil) - float(cfg.classes.s_cap[k]) * maxf(d, float(c.d_min)))
			var v := {}
			for g in _goods(c.pool, r.own, r.imp_g, r.sold):
				v[g] = TradeGoods.unit_value(gd, str(g))
			var comp := TradeGoods.compose(cfg, c.pool, r.own, r.imp_g, r.sold, r.bought, float(r.exp) + d_shared + spoil + over, float(r.exp), v)
			c.pool = comp.pool
			c.stock_sh = float(comp.shelved)
			var stock: float = 0.0
			for g in c.pool:
				stock += float(c.pool[g])
			c.short = maxf(0.0, d - (total - float(r.exp)))
			c.p = snappedf(float(pr.p), 0.000001)
			c.cover = float(pr.cover)
			c.s = s
			c.d = d
			c.imp = float(r.imp)
			c.exp = float(r.exp)
			c.stock = stock
			var tv: float = 0.0
			var td: float = 0.0
			for rid in x.regions:
				tv += float(x.regions[rid].value[cid])
				td += float(c.bs) * float(c.d_scale) * float(cfg.classes.bmix.get(k, 0.0)) * float(x.regions[rid].need[k])
			tot_value[cid] = tv
			tot_d[cid] = td
		_local_prices(gd, db, m, x, tot_value, tot_d)
	CraftEconomy.settle(gd, db, CraftEconomy.heads_by_market(db, heads_all))   # crafted demand, prices, next plans
	for m in markets:   # crafted local prices are the market's (regional crafted supply comes later)
		for rid in m.regions:
			var r: Dictionary = db.get_record("regions", rid)
			var pi: Dictionary = r.get("price_index", {})
			var kw := {}
			for cid in m.get("crafted", {}):
				var cc: Dictionary = m.crafted[cid]
				pi[cid] = float(cc.p)
				var kk: String = str(cc.kind)
				if not kw.has(kk):
					kw[kk] = [0.0, 0.0]
				kw[kk][0] += maxf(float(cc.d), 1e-6) * float(cc.p)
				kw[kk][1] += maxf(float(cc.d), 1e-6)
			for kk in kw:   # each crafted kind's demand-weighted price (the basket reads the pill one)
				pi[kk] = snappedf(float(kw[kk][0]) / maxf(float(kw[kk][1]), 1e-12), 0.000001)
			r["price_index"] = pi
		m["player_last"] = m.get("player", {})
		m["player"] = {}
		m.season = int(m.season) + 1
	_world_shares(db)


# Rule 2: a region whose holder changed (Sects rules 17-18) joins the new holder's market this season, with its
# distance to the new hub (straight-line; the ground path is measured once at world generation); a fallen sect's
# market closes once it holds no region.
# Regional Economy Formula C's goods_frac term: the market's sects' (its great sect's and its vassals') track spending
# last season, met in goods, by each track's raw mix (Institutions herbs; Military ore and beast parts; Holdings and
# Trade ore). Military's crafted share goes to talismans and artifacts (CraftEconomy). {kind: base value}.
static func _sect_raw_demand(gd: GameData, db: WorldDB, m: Dictionary) -> Dictionary:
	var cfg: Dictionary = gd.file(FILE)
	var mix: Dictionary = cfg.demand.mix
	var gf: float = float(cfg.demand.goods_frac)
	var out := {}
	for s in db.all("sects"):
		if str(s.get("status", "")) != "active":
			continue
		if str(s.id) != str(m.sect_id) and str(s.get("lord_id", "")) != str(m.sect_id):
			continue
		for tr in s.get("spend", {}):
			for k in mix.get(tr, {}):
				if cfg.classes.order.has(k):
					var sp_t: float = SectEconomy.mil_spend_mean(s) if str(tr) == "military" else float(s.spend[tr])   # Formula C
					out[k] = float(out.get(k, 0.0)) + gf * sp_t * float(mix[tr][k])
		for k in cfg.demand.wmix:   # the works' upkeep, met in goods (Formula C's works_due · wmix)
			out[k] = float(out.get(k, 0.0)) + gf * float(s.get("works_due", 0.0)) * float(cfg.demand.wmix[k])
	return out


# Every good named in any of [param pools], sorted (market-id and good-id order keeps results bit-identical).
static func _goods(a: Dictionary, b: Dictionary, c: Dictionary = {}, d: Dictionary = {}) -> Array:
	var out: Array = []
	for x in [a, b, c, d]:
		for g in x:
			if not out.has(g):
				out.append(g)
	out.sort()
	return out


static func _sync_regions(db: WorldDB) -> void:
	var where := {}
	for m in _sorted_markets(db):
		for rid in m.regions.keys():
			where[rid] = str(m.id)
	for r in db.all("regions"):
		var rid: String = str(r.id)
		var want: String = market_of_region(db, r)
		var have: String = str(where.get(rid, ""))
		if want == have:
			continue
		var entry := {"d": 0.0, "p_loc": {}}
		if have != "":
			var old: Dictionary = db.get_record(TABLE, have)
			entry = old.regions[rid]
			old.regions.erase(rid)
		if want != "":
			var m: Dictionary = db.get_record(TABLE, want)
			entry["d"] = Vector2(float(r.centre_tile[0]), float(r.centre_tile[1])).distance_to(Vector2(float(m.hub_tile[0]), float(m.hub_tile[1])))
			entry["trades"] = {}
			m.regions[rid] = entry
	for m in _sorted_markets(db):
		if m.regions.is_empty():
			db.remove(TABLE, str(m.id))


## The links between markets (rule 12): two markets whose territories border, or whose seats both hold a teleport
## array, with both sects at Trade 1 or more, Openness above 0 and not at war with each other. Each link has its hub
## distance (built once, [method build]) and whether it runs through the arrays. Sorted by (id_A, id_B).
static func links(gd: GameData, db: WorldDB) -> Array:
	var out: Array = []
	for l in db.get_record(TABLE, "mk_links").get("links", []):
		var a: Dictionary = db.get_record(TABLE, str(l.a))
		var b: Dictionary = db.get_record(TABLE, str(l.b))
		if a.is_empty() or b.is_empty():
			continue
		var sa: Dictionary = db.get_record("sects", str(a.sect_id))
		var sb: Dictionary = db.get_record("sects", str(b.sect_id))
		if str(sa.get("status", "")) != "active" or str(sb.get("status", "")) != "active":
			continue
		if int(sa.get("levels", {}).get("trade", 0)) < 1 or int(sb.get("levels", {}).get("trade", 0)) < 1:
			continue
		if _openness(sa) <= 0 or _openness(sb) <= 0:
			continue
		if Array(sa.get("wars", [])).has(str(sb.id)) or Array(sb.get("wars", [])).has(str(sa.id)):
			continue
		out.append(l)
	return out


# Sects rule 12's Openness dial (2, neutral, until the sects set their stance).
static func _openness(sect: Dictionary) -> int:
	return int(sect.get("dials", {}).get("openness", 2))


# Formula F over every open link, in (id_A, id_B) order, classes herb, ore, beast, special: goods flow from the cheaper
# market to the dearer, at most beta of the gap-closing amount, limited by the exporter's available stock (depleted as
# it exports), the link's capacity and the importer's commons pool; the importer's pool pays P_A · Q to the exporter's
# pool and tar · P_B · Q to its sect.
static func _flows(gd: GameData, db: WorldDB, money: MoneyLedger, pre: Dictionary) -> void:
	var cfg: Dictionary = gd.file(FILE)
	var avail := {}
	for mid in pre:
		avail[mid] = {}
		for cid in pre[mid]:
			avail[mid][cid] = float(pre[mid][cid].avail)
	for l in links(gd, db):
		var ma: Dictionary = db.get_record(TABLE, str(l.a))
		var mb: Dictionary = db.get_record(TABLE, str(l.b))
		var sa: Dictionary = db.get_record("sects", str(ma.sect_id))
		var sb: Dictionary = db.get_record("sects", str(mb.sect_id))
		var tm_a: float = EconomyRules.trade_mult(cfg, int(sa.get("levels", {}).get("trade", 0)))
		var tm_b: float = EconomyRules.trade_mult(cfg, int(sb.get("levels", {}).get("trade", 0)))
		var mil: float = (float(sa.get("levels", {}).get("military", 0)) + float(sb.get("levels", {}).get("military", 0))) / 2.0
		var reach: float = exp(-float(l.d) / (float(cfg.access.d_reach) * (tm_a + tm_b) / 2.0))
		var safe: float = clampf(1.0 - float(cfg.access.lambda_road) * pow(float(cfg.access.road_danger), mil) * (1.0 - reach), 0.0, 1.0)
		var cap_left: float = EconomyRules.link_capacity(cfg, tm_a, tm_b, safe)
		var flows := {}
		var cids: Array = ma.classes.keys().filter(func(x): return mb.classes.has(x))
		for k in cids:
			var ca: Dictionary = ma.classes[k]
			var cb: Dictionary = mb.classes[k]
			var lo: Dictionary = ma
			var hi: Dictionary = mb
			if float(cb.p) < float(ca.p):
				lo = mb
				hi = ma
			var clo: Dictionary = lo.classes[k]
			var chi: Dictionary = hi.classes[k]
			var s_hi: Dictionary = db.get_record("sects", str(hi.sect_id))
			var f := EconomyRules.link_flow(cfg, kind_of_class(k), float(clo.p), float(chi.p), float(clo.cover), float(chi.cover),
				float(pre[str(lo.id)][k].d), float(pre[str(hi.id)][k].d), float(chi.d_min), _openness(s_hi), float(l.d),
				tm_a, tm_b, float(avail[str(lo.id)][k]), bool(l.get("array", false)))
			flows[k] = {"from": str(lo.id), "to": str(hi.id), "q": float(f.q)}
		var total: float = 0.0
		for k in cids:
			total += float(flows[k].q)
		var scale: float = 1.0 if total <= cap_left or total <= 0.0 else cap_left / total
		for k in cids:
			var fl: Dictionary = flows[k]
			var q: float = float(fl.q) * scale
			if q <= 0.0:
				continue
			var a_m: Dictionary = db.get_record(TABLE, str(fl.from))
			var b_m: Dictionary = db.get_record(TABLE, str(fl.to))
			var p_a: float = float(a_m.classes[k].p)
			var p_b: float = float(b_m.classes[k].p)
			var tar: float = EconomyRules.tariff(cfg, _openness(db.get_record("sects", str(b_m.sect_id))))
			var pool_b: String = "pool:%s" % str(b_m.sect_id)
			var can: float = money.balance(pool_b)
			var unit_cost: float = p_a + tar * p_b
			if can < q * unit_cost:   # a pool that cannot pay limits the flow (Formula H)
				q = can / maxf(unit_cost, 1e-9)
			if q <= 0.0:
				continue
			money.transfer(pool_b, "pool:%s" % str(a_m.sect_id), p_a * q, "link_goods")
			money.transfer(pool_b, "sect:%s" % str(b_m.sect_id), tar * p_b * q, "tariff")
			b_m.classes[k]["tariff_in"] = float(b_m.classes[k].get("tariff_in", 0.0)) + tar * p_b * q
			avail[str(fl.from)][k] = maxf(0.0, float(avail[str(fl.from)][k]) - q)
			pre[str(fl.from)][k].exp = float(pre[str(fl.from)][k].exp) + q
			pre[str(fl.to)][k].imp = float(pre[str(fl.to)][k].imp) + q
			var ex: Dictionary = pre[str(fl.from)][k].ex   # imports arrive split by the exporter's shares (Formula B)
			var ig: Dictionary = pre[str(fl.to)][k].imp_g
			for g in ex:
				if float(ex[g]) > 0.0:
					ig[g] = float(ig.get(g, 0.0)) + q * float(ex[g])


# Formula L1 for every region of the market, and price_index = p_loc (rule 11). The player's trades count with
# memory pl_mem.
static func _local_prices(gd: GameData, db: WorldDB, m: Dictionary, x: Dictionary, tot_value: Dictionary, tot_d: Dictionary) -> void:
	var cfg: Dictionary = gd.file(FILE)
	var mem: float = float(cfg.local.pl_mem)
	for rid in x.regions:
		var rx: Dictionary = x.regions[rid]
		var rm: Dictionary = m.regions[rid]
		var trades: Dictionary = rm.get("trades", {})
		var p_loc := {}
		var d_own := {}
		var kind_w := {}
		for cid in m.classes:
			var k: String = kind_of_class(cid)
			var c: Dictionary = m.classes[cid]
			var rho: float = 1.0 if float(tot_value[cid]) <= 0.0 or float(tot_d[cid]) <= 0.0 else float(tot_value[cid]) / float(tot_d[cid])
			var d_r: float = float(c.bs) * float(c.d_scale) * float(cfg.classes.bmix.get(k, 0.0)) * float(rx.need[k])
			d_own[cid] = d_r
			var t: Dictionary = trades.get(cid, {})
			p_loc[cid] = snappedf(EconomyRules.local_price(cfg, k, float(c.p), float(rx.value[cid]), d_r, float(rx.acc), rho,
				float(t.get("sell", 0.0)), float(t.get("buy", 0.0))), 0.000001)
			if not t.is_empty():
				trades[cid] = {"buy": float(t.get("buy", 0.0)) * mem, "sell": float(t.get("sell", 0.0)) * mem}
			var w: float = maxf(float(c.d), 1e-6)   # the kind's price: its classes weighted by their demand
			if not kind_w.has(k):
				kind_w[k] = [0.0, 0.0]
			kind_w[k][0] += w * float(p_loc[cid])
			kind_w[k][1] += w
		for k in kind_w:
			p_loc[k] = snappedf(float(kind_w[k][0]) / maxf(float(kind_w[k][1]), 1e-12), 0.000001)
		rm["p_loc"] = p_loc
		rm["d_r"] = d_own
		rm["acc"] = float(rx.acc)
		rm["trades"] = trades
		var r: Dictionary = db.get_record("regions", rid)
		r["price_index"] = p_loc


## Trade Goods Formula D: the scarcity factor of good [param good] in market [param mid]'s class pool (1 for a class
## with no composition, or a good of no raw class).
static func scarcity_factor(gd: GameData, db: WorldDB, mid: String, good: String) -> float:
	var m: Dictionary = db.get_record(TABLE, mid)
	var cid: String = class_of(gd, good)
	if m.is_empty() or not m.classes.has(cid):
		return 1.0
	var wsh: Dictionary = db.get_record(TABLE, "mk_world_shares").get(cid, {})
	if wsh.is_empty() or not wsh.has(good):
		return 1.0
	var v := {}
	for g in wsh:
		v[g] = TradeGoods.unit_value(gd, str(g))
	return float(TradeGoods.scarcity(gd.file(FILE), m.classes[cid].pool, wsh, v).get(good, 1.0))


# Formula D's world shares of each good in its class, summed in market-id order after every market's Formula B.
static func _world_shares(db: WorldDB) -> void:
	var tot := {}
	for m in _sorted_markets(db):
		for cid in m.classes:
			if not tot.has(cid):
				tot[cid] = {}
			for g in m.classes[cid].pool:
				tot[cid][g] = float(tot[cid].get(g, 0.0)) + float(m.classes[cid].pool[g])
	var out := {"id": "mk_world_shares"}
	for cid in tot:
		var s: float = 0.0
		for g in tot[cid]:
			s += float(tot[cid][g])
		var sh := {}
		for g in tot[cid]:
			sh[g] = 0.0 if s <= 0.0 else float(tot[cid][g]) / s
		out[cid] = sh
	db.put(TABLE, out)


## The local price of class or kind [param k] in region [param region_id] (1.0 before its market has ticked; rule 11).
static func local_price(db: WorldDB, region_id: String, k: String) -> float:
	return float(db.get_record("regions", region_id).get("price_index", {}).get(k, 1.0))


## Records the player's trade of [param value] base value of class [param k] in a region (rule 16, Formula L1's
## buy_pl / sell_pl and Formula G's P_eff): [param buy] true for a purchase.
static func record_player_trade(gd: GameData, db: WorldDB, region_id: String, k: String, value: float, buy: bool, good: String = "") -> void:
	var r: Dictionary = db.get_record("regions", region_id)
	var mid: String = market_of_region(db, r)
	if mid == "":
		return
	var m: Dictionary = db.get_record(TABLE, mid)
	var side: String = "buy" if buy else "sell"
	if not m.player.has(side):
		m.player[side] = {}
	m.player[side][k] = float(m.player[side].get(k, 0.0)) + value
	if good != "":   # the good itself enters or leaves the class pool (Formula B's sell_pl / buy_pl)
		var gk: String = "bought_g" if buy else "sold_g"
		if not m.player.has(gk):
			m.player[gk] = {}
		if not m.player[gk].has(k):
			m.player[gk][k] = {}
		m.player[gk][k][good] = float(m.player[gk][k].get(good, 0.0)) + value
	var rm: Dictionary = m.regions.get(region_id, {})
	if rm.is_empty():
		return
	if not rm.has("trades"):
		rm["trades"] = {}
	if not rm.trades.has(k):
		rm.trades[k] = {"buy": 0.0, "sell": 0.0}
	rm.trades[k][side] = float(rm.trades[k][side]) + value


static func _sorted_markets(db: WorldDB) -> Array:
	var ms: Array = db.find(TABLE, func(x): return str(x.id).begins_with("mk:"))
	ms.sort_custom(func(a, b): return str(a.id) < str(b.id))
	return ms
