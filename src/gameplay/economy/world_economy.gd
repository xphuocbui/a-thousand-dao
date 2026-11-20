class_name WorldEconomy
extends RefCounted

## The seasonal market tick of Regional Economy & Trade (design/gdd/regional-economy-trade.md rules 1-11, 19-20;
## Formulas A-E, L1): one market per great sect over the regions it holds; each season it reads the map's production
## contract (the regions' [code]production_value[/code]), works out access, supply, demand, stock and the price of each
## raw class, and writes each region's local price back as the [code]price_index[/code] Travel & Map's demand factor
## reads. The formulas are [EconomyRules]'; this class keeps the state, in the World DB's [code]markets[/code] table
## (one record per market, id [code]mk:<sect id>[/code]), so a saved world resumes the same.
##
## A raw class is a kind (herb, ore, beast, special); goods map to kinds by the herb list and map_resources.json's
## resource_kind. Links between markets, the sects' spending and the crafted classes join later steps of the plan
## (production/plans/world-economy.md); until then their terms are 0.
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
	var cfg: Dictionary = gd.file(FILE)
	var kinds: Array = cfg.classes.order
	for s in db.find("sects", func(x): return str(x.get("kind", "")) == "great" and str(x.get("status", "")) == "active"):
		var hub: Dictionary = db.get_record("places", str(s.get("hq_place_id", "")))
		var classes := {}
		for k in kinds:
			classes[k] = {"p": 1.0, "stock": 0.0, "s": 0.0, "d": 0.0, "cover": 0.0, "short": 0.0, "d_scale": 1.0, "d_min": 1.0}
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
	var sect: Dictionary = db.get_record("sects", str(m.sect_id))
	var lv: Dictionary = sect.get("levels", {})
	var heads_by_region: Dictionary = heads_all if not heads_all.is_empty() else _heads(db)
	var wset_by_region: Dictionary = wset_all if not wset_all.is_empty() else _settlement_weight(gd, db)
	var reached := {}
	var need := {}
	var regions := {}
	for k in kinds:
		reached[k] = 0.0
		need[k] = 0.0
	for rid in m.regions:
		var r: Dictionary = db.get_record("regions", rid)
		var acc: float = float(EconomyRules.access(cfg, float(m.regions[rid].d), int(lv.get("trade", 0)), int(lv.get("military", 0)), bool(r.get("war", false))).acc)
		var val := {}
		for k in kinds:
			val[k] = 0.0
		for g in r.get("production_value", {}):
			var k: String = kind_of(gd, str(g))
			if val.has(k):
				val[k] = float(val[k]) + float(r.production_value[g])
		var heads: Array = heads_by_region.get(rid, [0, 0, 0, 0, 0])
		var nd := {}
		for k in kinds:
			reached[k] = float(reached[k]) + float(val[k]) * acc
			nd[k] = EconomyRules.population_need(cfg, k, heads, m.fill, float(wset_by_region.get(rid, 0.0)))
			need[k] = float(need[k]) + float(nd[k])
		regions[rid] = {"acc": acc, "value": val, "need": nd}
	return {"collect": _collect(cfg, int(lv.get("holdings", 0))), "reached": reached, "need": need, "regions": regions}


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
	for p in db.all("people"):
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


# The contract's pop_settlement_weight per region (city 8, town 4, market 3, village 1).
static func _settlement_weight(gd: GameData, db: WorldDB) -> Dictionary:
	var w: Dictionary = gd.file(FILE).shop.w_place
	var out := {}
	for p in db.all("places"):
		var rid: String = str(p.get("region_id", ""))
		if w.has(str(p.get("kind", ""))) and not bool(p.get("hidden", false)):
			out[rid] = float(out.get(rid, 0.0)) + float(w[str(p.kind)])
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
		var x := _inputs(gd, db, m, heads_all, wset_all)
		ins[str(m.id)] = x
		for k in kinds:
			s_tot[k] = float(s_tot[k]) + EconomyRules.supply(cfg, float(x.collect), float(x.reached[k]))
			n_tot[k] = float(n_tot[k]) + float(cfg.classes.bmix.get(k, 0.0)) * float(x.need[k])
	var dscale := {}
	for k in kinds:
		var target: float = 1.0 + float(cfg.classes.dk[k]) * (float(cfg.classes.c_ref[k]) - 1.0)
		dscale[k] = 1.0 if float(n_tot[k]) <= 0.0 else float(s_tot[k]) / (target * float(n_tot[k]))
	for m in markets:
		var x: Dictionary = ins[str(m.id)]
		for k in kinds:
			var c: Dictionary = m.classes[k]
			c.d_scale = dscale[k]
			var s: float = EconomyRules.supply(cfg, float(x.collect), float(x.reached[k]))
			var d: float = EconomyRules.demand(cfg, k, float(dscale[k]), float(x.need[k]))
			c.d_min = maxf(1.0, float(cfg.demand.d_min_share) * d)
			c.stock = maxf(0.0, float(cfg.classes.c_ref[k]) * d - s)
			c.s = s
			c.d = d
			c.cover = (c.stock + s) / maxf(d, c.d_min)
		for rid in x.regions:   # each region's own demand (Formula L1's D_r), which the shops' slippage reads from day one
			var d_own := {}
			for k in kinds:
				d_own[k] = float(dscale[k]) * float(cfg.classes.bmix.get(k, 0.0)) * float(x.regions[rid].need[k])
			m.regions[rid]["d_r"] = d_own
	db.put(TABLE, {"id": "mk_calibration", "d_scale": dscale})


## One season of every market (rule 19 steps (a), (c), (d), (e)): supply and demand, the flows on the links between
## markets (Formula F, paid pool to pool with the importer's tariff to its sect, Formula H), then stock, price, local
## prices and the price_index written back to the regions. [param money] books the flows' payments (a ledger over
## [param db] when null).
static func season(gd: GameData, db: WorldDB, money: MoneyLedger = null) -> void:
	var cfg: Dictionary = gd.file(FILE)
	var kinds: Array = cfg.classes.order
	if money == null:
		money = MoneyLedger.new(db)
	var markets: Array = _sorted_markets(db)
	var ins := {}
	var pre := {}
	var heads_all := _heads(db)
	var wset_all := _settlement_weight(gd, db)
	for m in markets:   # (c) supply before flows, and demand
		var x := _inputs(gd, db, m, heads_all, wset_all)
		ins[str(m.id)] = x
		var pl: Dictionary = m.get("player", {})
		var row := {}
		for k in kinds:
			var c: Dictionary = m.classes[k]
			c["tariff_in"] = 0.0
			var s: float = EconomyRules.supply(cfg, float(x.collect), float(x.reached[k]))
			var d_pre: float = EconomyRules.demand(cfg, k, float(c.d_scale), float(x.need[k]))
			var cap: float = float(cfg.shop.player_cap) * d_pre
			var p_eff: float = clampf(float(pl.get("buy", {}).get(k, 0.0)) - float(pl.get("sell", {}).get(k, 0.0)), -cap, cap)
			row[k] = {"s": s, "d": maxf(0.0, d_pre + p_eff), "imp": 0.0, "exp": 0.0}
		pre[str(m.id)] = row
	if bool(cfg.links.get("enabled", true)):
		_flows(gd, db, money, pre)   # (d)
	for m in markets:   # (e)
		var x: Dictionary = ins[str(m.id)]
		var tot_value := {}
		var tot_d := {}
		for k in kinds:
			var c: Dictionary = m.classes[k]
			var r: Dictionary = pre[str(m.id)][k]
			var s: float = float(r.s) + float(r.imp) - float(r.exp)
			var d: float = float(r.d)
			var strained: bool = float(c.cover) < float(cfg.price.c_short)
			var pr := EconomyRules.price(cfg, k, float(c.p), float(c.stock), s, d, float(c.d_min), strained)
			var st := EconomyRules.stock_update(cfg, k, float(c.stock), s, d, float(c.d_min))
			c.p = snappedf(float(pr.p), 0.000001)
			c.cover = float(pr.cover)
			c.s = s
			c.d = d
			c.imp = float(r.imp)
			c.exp = float(r.exp)
			c.stock = float(st.stock)
			c.short = float(st.short)
			var tv: float = 0.0
			var td: float = 0.0
			for rid in x.regions:
				tv += float(x.regions[rid].value[k])
				td += float(c.d_scale) * float(cfg.classes.bmix.get(k, 0.0)) * float(x.regions[rid].need[k])
			tot_value[k] = tv
			tot_d[k] = td
		_local_prices(gd, db, m, x, tot_value, tot_d)
		m["player_last"] = m.get("player", {})
		m["player"] = {}
		m.season = int(m.season) + 1


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
	var kinds: Array = cfg.classes.order
	var avail := {}
	for mid in pre:
		var m: Dictionary = db.get_record(TABLE, mid)
		avail[mid] = {}
		for k in kinds:
			avail[mid][k] = maxf(0.0, float(m.classes[k].stock) + float(pre[mid][k].s) - float(pre[mid][k].d))
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
		for k in kinds:
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
			var f := EconomyRules.link_flow(cfg, k, float(clo.p), float(chi.p), float(clo.cover), float(chi.cover),
				float(pre[str(lo.id)][k].d), float(pre[str(hi.id)][k].d), float(chi.d_min), _openness(s_hi), float(l.d),
				tm_a, tm_b, float(avail[str(lo.id)][k]), bool(l.get("array", false)))
			flows[k] = {"from": str(lo.id), "to": str(hi.id), "q": float(f.q)}
		var total: float = 0.0
		for k in kinds:
			total += float(flows[k].q)
		var scale: float = 1.0 if total <= cap_left or total <= 0.0 else cap_left / total
		for k in kinds:
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
		for k in cfg.classes.order:
			var c: Dictionary = m.classes[k]
			var rho: float = 1.0 if float(tot_value[k]) <= 0.0 or float(tot_d[k]) <= 0.0 else float(tot_value[k]) / float(tot_d[k])
			var d_r: float = float(c.d_scale) * float(cfg.classes.bmix.get(k, 0.0)) * float(rx.need[k])
			d_own[k] = d_r
			var t: Dictionary = trades.get(k, {})
			p_loc[k] = snappedf(EconomyRules.local_price(cfg, k, float(c.p), float(rx.value[k]), d_r, float(rx.acc), rho,
				float(t.get("sell", 0.0)), float(t.get("buy", 0.0))), 0.000001)
			if not t.is_empty():
				trades[k] = {"buy": float(t.get("buy", 0.0)) * mem, "sell": float(t.get("sell", 0.0)) * mem}
		rm["p_loc"] = p_loc
		rm["d_r"] = d_own
		rm["acc"] = float(rx.acc)
		rm["trades"] = trades
		var r: Dictionary = db.get_record("regions", rid)
		r["price_index"] = p_loc


## The local price of class [param k] in region [param region_id] (1.0 before its market has ticked; rule 11).
static func local_price(db: WorldDB, region_id: String, k: String) -> float:
	return float(db.get_record("regions", region_id).get("price_index", {}).get(k, 1.0))


## Records the player's trade of [param value] base value of class [param k] in a region (rule 16, Formula L1's
## buy_pl / sell_pl and Formula G's P_eff): [param buy] true for a purchase.
static func record_player_trade(gd: GameData, db: WorldDB, region_id: String, k: String, value: float, buy: bool) -> void:
	var r: Dictionary = db.get_record("regions", region_id)
	var mid: String = market_of_region(db, r)
	if mid == "":
		return
	var m: Dictionary = db.get_record(TABLE, mid)
	var side: String = "buy" if buy else "sell"
	if not m.player.has(side):
		m.player[side] = {}
	m.player[side][k] = float(m.player[side].get(k, 0.0)) + value
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
