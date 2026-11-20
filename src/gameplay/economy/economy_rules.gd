class_name EconomyRules
extends RefCounted

## The formulas of Regional Economy & Trade (design/gdd/regional-economy-trade.md, Formulas A-L2), pure and static:
## every value comes in as an argument or from [code]assets/data/economy.json[/code] ([param cfg] is that file's
## content), so each formula is testable against the GDD's worked examples. The seasonal tick that applies them to
## the world is [WorldEconomy]. A raw class k is a kind (herb, ore, beast, special); a rarity band takes its kind's
## parameters (rule 4).
##
## Usage:
## [codeblock]
## var cfg: Dictionary = gd.file("economy")
## var a := EconomyRules.access(cfg, 150.0, 6, 6, false)   # {reach 0.729, safe 0.984, acc 0.717}
## [/codeblock]


## Formula A: a region's market access from its distance [param d_r] (tiles to the hub), the holder's Trade and
## Military levels and whether war touches it. {reach, safe, acc}.
static func access(cfg: Dictionary, d_r: float, trade_level: int, military_level: int, war: bool) -> Dictionary:
	var a: Dictionary = cfg.access
	var tm: float = trade_mult(cfg, trade_level)
	var reach: float = exp(-d_r / (float(a.d_reach) * tm))
	var dmg: float = pow(float(a.road_danger), military_level)
	var safe: float = clampf(1.0 - float(a.lambda_road) * dmg * (1.0 - reach) - float(a.lambda_war) * (1.0 if war else 0.0), 0.0, 1.0)
	return {"reach": reach, "safe": safe, "acc": reach * safe}


## Sects F2's trade multiplier 1 + 0.15 · T.
static func trade_mult(cfg: Dictionary, trade_level: int) -> float:
	return 1.0 + float(cfg.access.trade_mult_per_level) * trade_level


## Formula B's share that reaches the market: h_f = h0 + (1 − h0) · collect / s_max.
static func h_f(cfg: Dictionary, collect: float) -> float:
	var h0: float = float(cfg.supply.h0)
	return h0 + (1.0 - h0) * collect / float(cfg.supply.s_max)


## Formula B: supply of a class from the market's regions' base value times access ([param reached], Σ value · acc),
## the shock, imports and exports.
static func supply(cfg: Dictionary, collect: float, reached: float, shock: float = 0.0, imp: float = 0.0, exp_: float = 0.0) -> float:
	return h_f(cfg, collect) * reached * (1.0 - shock) + imp - exp_


## Formula C's population term before d_scale and bmix: Σ_rl heads · basket · max(fill, sub_floor) + set_w · W_set.
## [param heads] and [param fill] are arrays by realm.
static func population_need(cfg: Dictionary, k: String, heads: Array, fill: Array, w_set: float) -> float:
	var basket: Array = cfg.demand.basket
	var floor_k: float = float(cfg.classes.sub_floor.get(k, 0.0))
	var t: float = 0.0
	for rl in mini(heads.size(), basket.size()):
		var f: float = float(fill[rl]) if rl < fill.size() else 1.0
		t += float(heads[rl]) * float(basket[rl]) * maxf(f, floor_k)
	return t + float(cfg.demand.set_w) * w_set


## Formula C: demand of class k. [param track_spend] is Σ_T spend_T · mix[T,k] (last season's), [param works_due] the
## works upkeep, [param craft_in] the workshops' draw, [param p_eff] the player's bounded net buying.
static func demand(cfg: Dictionary, k: String, d_scale: float, need: float, shock: float = 0.0, track_spend: float = 0.0,
		works_due: float = 0.0, craft_in: float = 0.0, p_eff: float = 0.0) -> float:
	var gf: float = float(cfg.demand.goods_frac)
	var pop: float = d_scale * float(cfg.classes.bmix.get(k, 0.0)) * need * (1.0 + shock)
	return maxf(0.0, pop + gf * (track_spend + works_due * float(cfg.demand.wmix.get(k, 0.0))) + craft_in + p_eff)


## Formula D: next stock and the unmet demand. {stock, short}.
static func stock_update(cfg: Dictionary, k: String, stock: float, s: float, d: float, d_min: float) -> Dictionary:
	var dk: float = float(cfg.classes.dk[k])
	var cap: float = float(cfg.classes.s_cap[k]) * maxf(d, d_min)
	return {"stock": minf((1.0 - dk) * maxf(0.0, stock + s - d), cap), "short": maxf(0.0, d - stock - s)}


## Formula E: cover, target price and the next price of class k from price [param p]. {cover, p_star, p}.
## [param strained] lifts the ceiling to P_maxeff (States).
static func price(cfg: Dictionary, k: String, p: float, stock: float, s: float, d: float, d_min: float, strained: bool = false) -> Dictionary:
	var c: Dictionary = cfg.classes
	var p_hi: float = float(c.p_maxeff[k] if strained else c.p_max[k])
	var cover: float = (stock + s) / maxf(d, d_min)
	var p_star: float = p_hi if cover <= 0.0 else clampf(pow(cover / float(c.c_ref[k]), -float(c.eps[k])), float(c.p_min[k]), p_hi)
	var dl: float = float(c.delta[k])
	var nxt: float = clampf(p * pow(p_star / p, float(cfg.price.alpha)), p / dl, p * dl)
	return {"cover": cover, "p_star": p_star, "p": nxt}


## Formula F: the flow of class k from the cheaper market A to the dearer B on one link, before the link's capacity
## scales it. [param o_b] is B's Openness (1-4); [param d_ab] the hub-to-hub road distance in tiles ([param array]
## for an array link); [param tm_a], [param tm_b] the trade multipliers. Covers are last season's. {tau, gap, q_close,
## q}.
static func link_flow(cfg: Dictionary, k: String, p_a: float, p_b: float, c_a: float, c_b: float, d_a: float, d_b: float,
		d_min: float, o_b: int, d_ab: float, tm_a: float, tm_b: float, avail_a: float, array: bool = false) -> Dictionary:
	var l: Dictionary = cfg.links
	var tau: float = float(l.tau0) + (float(l.tau_array) if array else float(l.tau_tile) * d_ab / ((tm_a + tm_b) / 2.0))
	var tar: float = tariff(cfg, o_b)
	var gap: float = p_b * (1.0 - tar) - p_a * (1.0 + tau)
	if gap <= 0.0:
		return {"tau": tau, "gap": gap, "q_close": 0.0, "q": 0.0}
	var cs: float = float(cfg.price.c_short)
	var den: float = float(cfg.classes.eps[k]) * (p_a / (maxf(c_a, cs) * maxf(d_a, d_min)) + p_b / (maxf(c_b, cs) * maxf(d_b, d_min)))
	var q_close: float = gap / den
	return {"tau": tau, "gap": gap, "q_close": q_close, "q": minf(float(l.beta) * q_close, maxf(0.0, avail_a))}


## Formula F's link capacity: cap_base · min(trade_mult) · safe.
static func link_capacity(cfg: Dictionary, tm_a: float, tm_b: float, safe_ab: float) -> float:
	return float(cfg.links.cap_base) * minf(tm_a, tm_b) * safe_ab


## The importer's tariff by Openness (Formula F; 0 at Openness 0, which has no link).
static func tariff(cfg: Dictionary, openness: int) -> float:
	var t: Array = cfg.links.tariff
	var v = t[clampi(openness, 0, t.size() - 1)]
	return 0.0 if v == null else float(v)


## Formula G's sell slippage after [param q_sold] base value already sold of the class at the place this season.
static func slip(cfg: Dictionary, k: String, q_sold: float, v: float, dp: float) -> float:
	return pow(1.0 + (q_sold + v) / maxf(1.0, dp), -float(cfg.classes.eps[k]))


## Formula G: the player's buy price of an item of base value [param v] at local price [param p_loc]. Raw goods take
## the bulk spread with no charm or standing; finished goods the retail spread, charm [param mi_luc] and standing
## [param st]. [param sf] is Trade Goods' scarcity factor; [param place_kind] picks the margin.
static func buy_price(cfg: Dictionary, v: float, p_loc: float, raw: bool, place_kind: String, mi_luc: int = 50, st: int = 0, sf: float = 1.0) -> int:
	var sh: Dictionary = cfg.shop
	var ch: float = 0.0 if raw else clampf((mi_luc - 50) * float(sh.ch_step), -float(sh.ch_max), float(sh.ch_max))
	var stp: float = 1.0 if raw else 1.0 - 0.002 * st
	var bm: float = float(sh.bm_raw if raw else sh.bm_fin)
	return maxi(1, ceili(v * p_loc * sf * bm * (1.0 - ch) * stp * float(sh.mg_buy.get(place_kind, 1.0)) - 1e-6))


## Formula G: the player's sell price ([param tar_in] the tariff on goods from another market, [param slip_f] the
## slippage).
static func sell_price(cfg: Dictionary, v: float, p_loc: float, raw: bool, place_kind: String, mi_luc: int = 50, st: int = 0,
		sf: float = 1.0, tar_in: float = 0.0, slip_f: float = 1.0) -> int:
	var sh: Dictionary = cfg.shop
	var ch: float = 0.0 if raw else clampf((mi_luc - 50) * float(sh.ch_step), -float(sh.ch_max), float(sh.ch_max))
	var sts: float = 1.0 if raw else 1.0 + 0.001 * st
	var sr: float = float(sh.sr_raw if raw else sh.sr_fin)
	return maxi(1, floori(v * p_loc * sf * sr * (1.0 + ch) * sts * float(sh.mg_sell.get(place_kind, 1.0)) * (1.0 - tar_in) * slip_f + 1e-6))


## Formula L1: a region's local price of class k from its market price [param p], its own output and demand, its
## access, the market's ratio [param rho] and the player's remembered trades there.
static func local_price(cfg: Dictionary, k: String, p: float, value_r: float, d_r: float, acc_r: float, rho: float = 1.0,
		sell_pl: float = 0.0, buy_pl: float = 0.0) -> float:
	var band: float = float(cfg.local.loc_band)
	var bal: float = ((value_r + sell_pl + 1.0) / (d_r + buy_pl + 1.0)) / maxf(rho, 1e-9)
	return clampf(p * pow(bal, -float(cfg.classes.eps[k]) * (1.0 - acc_r)), p * (1.0 - band), p * (1.0 + band))


## Formula L2: the cost of a full basket for realm [param rl] at local prices [param p_loc] (class → price).
static func basket_cost(cfg: Dictionary, rl: int, p_loc: Dictionary) -> float:
	var b: float = float(cfg.demand.basket[clampi(rl, 0, cfg.demand.basket.size() - 1)])
	var t: float = 0.0
	var bmix: Dictionary = cfg.classes.bmix
	for k in bmix:
		t += b * float(bmix[k]) * float(p_loc.get(k, 1.0))
	return t


## Formula L2: an NPC's basket purchase and what is left for stones (J). {basket_spend, fill, prov, stones}.
static func npc_spend(cfg: Dictionary, rl: int, purse: float, cost: float) -> Dictionary:
	var m: Dictionary = cfg.money
	var reserve: float = float(m.reserve_by_realm[clampi(rl, 0, m.reserve_by_realm.size() - 1)])
	var excess: float = maxf(0.0, purse - reserve)
	var spend: float = minf(cost, excess)
	var fill: float = 1.0 if cost <= 0.0 else minf(1.0, spend / cost)
	return {"basket_spend": spend, "fill": fill, "prov": float(cfg.provision.prov_max) * fill,
		"stones": float(m.s_spend) * maxf(0.0, excess - spend)}


## Formula J: tu vi from [param stones] at realm [param rl] with the season's rate; stones beyond the absorb cap are not
## spent. {tu_vi, spent}.
static func stone_tu_vi(cfg: Dictionary, rl: int, stones: float, rate: float) -> Dictionary:
	var m: Dictionary = cfg.money
	var spt: float = float(m.spt[clampi(rl, 0, m.spt.size() - 1)])
	var cap: float = float(m.absorb_cap) * rate
	var tv: float = minf(stones / spt, cap)
	return {"tu_vi": tv, "spent": tv * spt}


## Formula H's treasury rule: Sects F3's invest = max(0, Tr + Inc − Cost − R) · inv_frac, R = reserve_mult · Cost; of
## it inv_miss is reserved for missions and the rest goes to the track, goods_frac in kind and the rest in cash, burned.
## {invest, missions, track, track_cash, track_kind, cash_out}.
static func treasury_invest(cfg: Dictionary, tr: float, inc: float, cost: float) -> Dictionary:
	var m: Dictionary = cfg.money
	var r: float = float(m.reserve_mult) * cost
	var invest: float = maxf(0.0, tr + inc - cost - r) * float(m.inv_frac)
	var miss: float = invest * float(m.inv_miss)
	var track: float = invest - miss
	var cash: float = track * (1.0 - float(cfg.demand.goods_frac))
	return {"invest": invest, "missions": miss, "track": track, "track_cash": cash, "track_kind": track - cash, "cash_out": miss + cash}


## Formula I: collect_mine = cm0 + (1 − cm0) · collect.
static func collect_mine(cfg: Dictionary, collect: float) -> float:
	var cm0: float = float(cfg.money.cm0)
	return cm0 + (1.0 - cm0) * collect


## Formula I's goods income of one class: what the sect collected beyond its own use and kind stipends, sold at P ·
## sell_bulk. {sold, short, income}.
static func goods_income(cfg: Dictionary, collected: float, own_use: float, kind_stipend: float, p: float) -> Dictionary:
	var sold: float = maxf(0.0, collected - own_use - kind_stipend)
	return {"sold": sold, "short": maxf(0.0, own_use + kind_stipend - collected), "income": sold * p * float(cfg.money.sell_bulk)}


## Formula K: what an event may grant from a holder's balance.
static func loot_grant(budget: float, balance: float) -> float:
	return maxf(0.0, minf(budget, balance))
