class_name WorldMoney
extends RefCounted

## The world's money flows each season (design/gdd/regional-economy-trade.md rule 5 and Formulas H, I, L2; Sects F3's
## income, stipends and treasury rule), every one through [MoneyLedger] so the season's books balance:
## 1. **Mines** mint their output (the only faucet): stash_mine_share of it goes to the market's lost-stash pool (user
##    decision 2026-11-20), then a held site's sect collects collect_mine of the rest (Formula I) and the market's commons
##    pool the remainder; a wild site's goes half to the stash, half to the pool.
## 2. **Stipends**: each sect pays its members' cash stipends by realm (the kind share is goods, not cash).
## 3. **Commons missions**: each pool posts about a third of its balance as missions (it keeps 2-4 seasons of mission
##    cash); the market's cultivators take them, at most one a season at their realm's pay, shared pro rata.
## 4. **Baskets and stones** (Formulas L2, J): every cultivator buys what their purse above reserve allows of their
##    realm's provision basket at their region's local prices, paid to the commons pool, then absorbs s_spend of what
##    is left in linh thach (burned, up to the absorb cap at the realm's reference rate); the market's mean fill by
##    realm is kept for Formula C's demand next season, and each NPC's provisioned bonus (prov) and stone boost
##    (stone_boost, tu vi from stones over the rate) speed its advance (user decision 2026-11-20).
## 5. **The sects' market income**: tax on the market's turnover (Sects F3), and the goods each sect collected and sold
##    (Formula I's Inc_goods), both paid by the commons pool, limited by what it holds.
## 6. **The treasury rule** (Formula H): invest = max(0, Tr − R) · inv_frac with R = reserve_mult · Cost; inv_miss of it
##    is paid out as missions to the sect's own members, and the rest goes to a track, goods_frac in kind (the goods are
##    kept from next season's sales) and the rest in cash, burned.
## A death's purse is settled by [method settle_death]. Numbers are economy.json's.
##
## Usage:
## [codeblock]
## var money := MoneyLedger.new(db)
## WorldMoney.season(gd, db, money)   # after WorldEconomy.season
## [/codeblock]


## One season of the money flows (steps 1-6 above). Returns the season's figures by flow, for the harness.
static func season(gd: GameData, db: WorldDB, money: MoneyLedger, year: int = 0, season_i: int = 0) -> Dictionary:
	var out := {}
	var idx := _index(db)
	out["mines"] = _mines(gd, db, money)
	out["stipends"] = _stipends(gd, db, money, idx)
	out["commons_missions"] = _commons_missions(gd, db, money, idx)
	out["baskets"] = _baskets(gd, db, money, idx)
	out["market_income"] = _market_income(gd, db, money)
	out["sects"] = SectEconomy.season(gd, db, money)   # upkeep and tribute (Sects F1, F4) before the treasury rule
	out["works_upkeep"] = SectWorks.upkeep(gd, db, money)   # the sects' layer-2 works (Travel & Map Formula J)
	out["invest"] = _treasury_rule(gd, db, money, idx, year, season_i)
	return out


# The season's living cultivators (not the player, not beasts), once: by market, by sect, and each one's region.
static func _index(db: WorldDB) -> Dictionary:
	var region_market := {}
	for m in WorldEconomy._sorted_markets(db):
		for rid in m.regions:
			region_market[rid] = str(m.id)
	var place_region := {}
	for pl in db.all("places"):
		place_region[str(pl.id)] = str(pl.get("region_id", ""))
	var by_market := {}
	var by_sect := {}
	var region_of := {}
	for p in db.all("people"):
		if not bool(p.get("alive", false)) or bool(p.get("is_player", false)) or bool(p.get("is_beast", false)):
			continue
		var rid: String = str(place_region.get(str(p.get("location_id", "")), ""))
		region_of[str(p.id)] = rid
		var mid: String = str(region_market.get(rid, ""))
		if mid != "":
			if not by_market.has(mid):
				by_market[mid] = []
			by_market[mid].append(p)
		var sid: String = str(p.get("sect_id", ""))
		if sid != "":
			if not by_sect.has(sid):
				by_sect[sid] = []
			by_sect[sid].append(p)
	return {"by_market": by_market, "by_sect": by_sect, "region_of": region_of}


static func _cfg(gd: GameData) -> Dictionary:
	return gd.file(WorldEconomy.FILE)


# The active sect a holder id names ({} for none).
static func _sect(db: WorldDB, sid: String) -> Dictionary:
	var s: Dictionary = db.get_record("sects", sid)
	return s if not s.is_empty() and str(s.get("status", "")) == "active" else {}


# The great sect whose market a place's region belongs to ("" for none).
static func _market_sect(db: WorldDB, place: Dictionary) -> String:
	var mid: String = WorldEconomy.market_of_region(db, db.get_record("regions", str(place.get("region_id", ""))))
	return "" if mid == "" else str(db.get_record(WorldEconomy.TABLE, mid).get("sect_id", ""))


# 1. The mine faucet (Travel & Map Formula L's linh thach, Formula I's collect_mine, Formula H's wild split).
static func _mines(gd: GameData, db: WorldDB, money: MoneyLedger) -> float:
	var cfg: Dictionary = _cfg(gd)
	var total: float = 0.0
	for s in db.all("sects"):   # each sect's income before costs this season (Sects F4's gross_v)
		s["gross_income"] = 0.0
	for p in db.all("places"):
		if not p.has("site") or str(p.site.get("kind", "")) != "linh_thach":
			continue
		var out: float = float(p.site.get("last_output", 0.0))
		if out <= 0.0:
			continue
		var ms: String = _market_sect(db, p)
		var pool: String = "pool:%s" % ms if ms != "" else ""
		if ms != "":   # losses, theft and buried caches: the stash that found money is drawn from (user decision 2026-11-20)
			var lost: float = out * float(cfg.money.stash_mine_share)
			money.mint("stash:%s" % ms, lost, "mine")
			total += lost
			out -= lost
		var holder: Dictionary = _sect(db, str(p.get("holder", "")))
		if not holder.is_empty():
			var share: float = EconomyRules.collect_mine(cfg, WorldEconomy._collect(cfg, int(holder.get("levels", {}).get("holdings", 0))))
			money.mint("sect:%s" % holder.id, out * share, "mine")
			holder["gross_income"] = float(holder.get("gross_income", 0.0)) + out * share
			if pool != "":
				money.mint(pool, out * (1.0 - share), "mine")
			else:
				money.mint("sect:%s" % holder.id, out * (1.0 - share), "mine")
		elif pool != "":
			var st: float = float(cfg.money.stash_share)
			money.mint("stash:%s" % ms, out * st, "mine")
			money.mint(pool, out * (1.0 - st), "mine")
		else:
			continue
		total += out
	return total


# 2. Cash stipends by realm (Sects F3; the kind share is paid in goods).
static func _stipends(gd: GameData, db: WorldDB, money: MoneyLedger, idx: Dictionary) -> float:
	var cfg: Dictionary = _cfg(gd)
	var stip: Array = cfg.money.stipend
	var cash_share: float = 1.0 - float(cfg.money.kind_stipend)
	var total: float = 0.0
	var by_sect := {}
	for sid in idx.by_sect:
		if _sect(db, sid).is_empty():
			continue
		var pays: Array = []
		var due: float = 0.0
		for p in idx.by_sect[sid]:
			var amt: float = float(stip[clampi(int(p.get("realm_index", 0)), 0, stip.size() - 1)]) * cash_share
			pays.append(["npc:%s" % p.id, amt])
			due += amt
		var paid: float = money.pay_out("sect:%s" % sid, pays, "stipend")
		by_sect[sid] = paid
		total += paid
		if paid + 1e-6 < due:   # Sects F3: an unpaid sect loses members (Luyện Khí first, to the loose)
			_desert(gd, db, idx.by_sect[sid])
	db.put(MoneyLedger.TABLE, {"id": "m_stipends", "by_sect": by_sect})
	return total


# Sects F3's stipend-shortfall desertions: desert_share of the sect's Luyện Khí members leave and become loose.
static func _desert(gd: GameData, db: WorldDB, members: Array) -> void:
	var lk: Array = members.filter(func(p): return int(p.get("realm_index", 0)) == 0 and not p.has("cast_key"))
	lk.sort_custom(func(a, b): return str(a.id) < str(b.id))
	var n: int = int(floor(float(gd.file("sects_members").economy.desert_share) * lk.size()))
	for i in n:
		var p: Dictionary = lk[i]
		p["sect_id"] = ""
		p["sect_rank"] = ""
		p["deserted"] = true


# Mission pay of realm [param rl] (Sects F12: base · scale[rl]).
static func mission_pay(gd: GameData, rl: int) -> float:
	var mp: Dictionary = _cfg(gd).money
	return float(mp.mission_base) * float(mp.mission_scale[clampi(rl, 0, mp.mission_scale.size() - 1)])


# Pays [param budget] from [param payer] to [param takers] (people records) as missions: each takes at most one at
# their realm's pay, all scaled alike when the budget is short. Returns what was paid.
static func _pay_missions(gd: GameData, money: MoneyLedger, payer: String, takers: Array, budget: float, cause: String) -> float:
	if takers.is_empty() or budget <= 0.0:
		return 0.0
	var want: float = 0.0
	for p in takers:
		want += mission_pay(gd, int(p.get("realm_index", 0)))
	var f: float = minf(1.0, budget / maxf(want, 1e-9))
	var pays: Array = []
	for p in takers:
		pays.append(["npc:%s" % p.id, mission_pay(gd, int(p.get("realm_index", 0))) * f])
	return money.pay_out(payer, pays, cause)


# 3. Commons missions: a pool keeps pool_band seasons of mission cash, so it posts balance / mid-band a season.
static func _commons_missions(gd: GameData, db: WorldDB, money: MoneyLedger, idx: Dictionary) -> float:
	var cfg: Dictionary = _cfg(gd)
	var band: Array = cfg.money.pool_band
	var mid: float = (float(band[0]) + float(band[1])) / 2.0
	var takers_by: Dictionary = idx.by_market
	var total: float = 0.0
	for m in WorldEconomy._sorted_markets(db):
		var pool: String = "pool:%s" % str(m.sect_id)
		total += _pay_missions(gd, money, pool, takers_by.get(str(m.id), []), money.balance(pool) / mid, "commons_mission")
	return total


# 4. Baskets (Formula L2): bought at local prices from the purse above reserve, paid to the pool; the market's mean
# fill by realm is kept (Formula C reads last season's), and each NPC's provisioned bonus is noted for its advance.
static func _baskets(gd: GameData, db: WorldDB, money: MoneyLedger, idx: Dictionary) -> float:
	var cfg: Dictionary = _cfg(gd)
	var total: float = 0.0
	var takers_by: Dictionary = idx.by_market
	var cost_of := {}
	var price_of := {}
	for r in db.all("regions"):
		price_of[str(r.id)] = r.get("price_index", {})
	for m in WorldEconomy._sorted_markets(db):
		var pool: String = "pool:%s" % str(m.sect_id)
		var sum_fill := [0.0, 0.0, 0.0, 0.0, 0.0]
		var n := [0, 0, 0, 0, 0]
		var turnover: float = 0.0
		var takes: Array = []
		var stones: Array = []
		for p in takers_by.get(str(m.id), []):
			var rl: int = clampi(int(p.get("realm_index", 0)), 0, 4)
			var rid: String = str(idx.region_of.get(str(p.id), ""))
			var ck: String = "%s|%d" % [rid, rl]
			if not cost_of.has(ck):
				cost_of[ck] = EconomyRules.basket_cost(cfg, rl, price_of.get(rid, {}))
			var cost: float = float(cost_of[ck])
			var sp: Dictionary = EconomyRules.npc_spend(cfg, rl, float(p.get("linh_thach", 0.0)), cost)
			var paid: float = minf(float(sp.basket_spend), float(p.get("linh_thach", 0.0)))
			takes.append(["npc:%s" % p.id, paid])
			var fill: float = 1.0 if cost <= 0.0 else minf(1.0, paid / cost)
			p["prov"] = float(cfg.provision.prov_max) * fill
			# Formula J: s_spend of what is left above reserve goes to stones, up to the absorb cap at the realm's rate
			var rate: float = float(cfg.money.npc_rate_ref[rl])
			var st: Dictionary = EconomyRules.stone_tu_vi(cfg, rl, float(sp.stones), rate)
			var burned: float = minf(float(st.spent), maxf(0.0, float(p.get("linh_thach", 0.0)) - paid))
			stones.append(["npc:%s" % p.id, burned])
			p["stone_boost"] = 0.0 if rate <= 0.0 else burned / float(cfg.money.spt[rl]) / rate
			sum_fill[rl] += fill
			n[rl] += 1
			turnover += paid
		money.collect_in(takes, pool, "basket")
		for e in stones:
			money.burn(str(e[0]), float(e[1]), "stones")
		var fills: Array = []
		for rl in 5:
			fills.append(1.0 if n[rl] == 0 else float(sum_fill[rl]) / float(n[rl]))
		m["fill"] = fills
		m["turnover"] = float(m.get("turnover_player", 0.0)) + turnover
		m["turnover_player"] = 0.0
		total += turnover
	return total


# 5. Market tax (Sects F3: tf · trade_mult · Turn_m, tf = tf0 + tf_step · Tax) and Inc_goods (Formula I: what each
# great sect collected of its market's goods, less what it keeps in kind, sold at P · sell_bulk), paid by the pool.
static func _market_income(gd: GameData, db: WorldDB, money: MoneyLedger) -> float:
	var cfg: Dictionary = _cfg(gd)
	var total: float = 0.0
	for m in WorldEconomy._sorted_markets(db):
		var s: Dictionary = _sect(db, str(m.sect_id))
		if s.is_empty():
			continue
		var lv: Dictionary = s.get("levels", {})
		var pool: String = "pool:%s" % str(s.id)
		var treasury: String = "sect:%s" % str(s.id)
		var tax_dial: int = int(s.get("dials", {}).get("tax", 2))
		var tf: float = float(cfg.money.tf0) + float(cfg.money.tf_step) * tax_dial
		var tax: float = tf * EconomyRules.trade_mult(cfg, int(lv.get("trade", 0))) * float(m.get("turnover", 0.0))
		var shares := _v_own_shares(gd, db, m)
		for sid in shares:   # Sects F3: each sect of the market taxes its share of the land's value (share_s)
			var got: float = money.transfer(pool, "sect:%s" % sid, tax * float(shares[sid]), "market_tax")
			var rec: Dictionary = db.get_record("sects", str(sid))
			rec["gross_income"] = float(rec.get("gross_income", 0.0)) + got
			total += got
		var collect: float = WorldEconomy._collect(cfg, int(lv.get("holdings", 0)))
		var kind_left: float = float(s.get("kind_due", 0.0))
		var income: float = 0.0
		for k in m.classes:
			var c: Dictionary = m.classes[k]
			var reached: float = 0.0
			for rid in m.regions:
				reached += _region_value(gd, db, rid, k) * float(m.regions[rid].get("acc", 1.0))
			var coll: float = collect * reached
			var own: float = minf(coll, kind_left)
			kind_left -= own
			income += EconomyRules.goods_income(cfg, coll, own, 0.0, float(c.p)).income
		s["kind_due"] = maxf(0.0, kind_left)
		var sold: float = money.transfer(pool, treasury, income, "goods_sold")
		s["gross_income"] = float(s.get("gross_income", 0.0)) + sold
		total += sold
	return total


# Sects F3's share_s: each sect's share of its market's production value (V_own, Formula I: the sites it holds, mines
# in linh thach and goods at P = 1), the great sect taking what no vassal holds. {sect id: share}.
static func _v_own_shares(gd: GameData, db: WorldDB, m: Dictionary) -> Dictionary:
	var unit: Dictionary = gd.file(MapProduction.DATA_FILE).unit_value
	var by := {}
	var total: float = 0.0
	for p in db.all("places"):
		if not m.regions.has(str(p.get("region_id", ""))):
			continue
		var v: float = 0.0
		if p.has("site"):
			v += float(p.site.get("last_output", 0.0)) * float(unit.get(str(p.site.get("resource", "")), 1))
		if p.has("herb_site"):
			v += float(p.herb_site.get("last_output", 0.0))
		if v <= 0.0:
			continue
		var h: Dictionary = _sect(db, str(p.get("holder", "")))
		var sid: String = str(h.id) if not h.is_empty() else str(m.sect_id)
		by[sid] = float(by.get(sid, 0.0)) + v
		total += v
	if total <= 0.0:
		return {str(m.sect_id): 1.0}
	for sid in by:
		by[sid] = float(by[sid]) / total
	return by


# A region's production value of class [param cid] this season (the contract's production_value).
static func _region_value(gd: GameData, db: WorldDB, rid: String, cid: String) -> float:
	var v: float = 0.0
	var pv: Dictionary = db.get_record("regions", rid).get("production_value", {})
	for g in pv:
		if WorldEconomy.class_of(gd, str(g)) == cid:
			v += float(pv[g])
	return v


# 6. The treasury rule (Formula H): invest above R = reserve_mult · Cost (Cost: this season's cash stipends), inv_miss
# of it as missions to the sect's members, the rest to a track: its cash share burned, its kind share kept from next
# season's goods sales.
static func _treasury_rule(gd: GameData, db: WorldDB, money: MoneyLedger, idx: Dictionary, year: int = 0, season_i: int = 0) -> float:
	var cfg: Dictionary = _cfg(gd)
	var stip: Dictionary = db.get_record(MoneyLedger.TABLE, "m_stipends").get("by_sect", {})
	var members: Dictionary = idx.by_sect
	var total: float = 0.0
	for s in db.all("sects"):
		if str(s.get("status", "")) != "active":
			continue
		var treasury: String = "sect:%s" % str(s.id)
		var cost: float = float(stip.get(str(s.id), 0.0)) + float(s.get("cash_costs", 0.0))
		var t: Dictionary = EconomyRules.treasury_invest(cfg, money.balance(treasury), 0.0, cost)
		if float(t.invest) <= 0.0:
			continue
		var paid: float = _pay_missions(gd, money, treasury, members.get(str(s.id), []), float(t.missions), "treasury_mission")
		var burned: float = money.burn(treasury, float(t.track_cash), "works")
		s["kind_due"] = float(s.get("kind_due", 0.0)) + float(t.track_kind)
		var works: float = 0.0
		if SectEconomy.invest_track(gd, s) == "holdings":   # Holdings money first builds works on the sect's land
			works = SectWorks.build_best(gd, db, s, float(t.track), year, season_i)
		SectEconomy.invest(gd, s, float(t.track) - works)   # F19's track takes the rest (F1 raises its level)
		total += paid + burned
	return total


## Settles a dead NPC's purse (Formula H's heirless burn): to the heir (Inheritance.heir_of) if any; else to the sect's
## treasury if a member; else lost_frac burns and the rest goes to the lost-stash pool of the market where they died.
static func settle_death(gd: GameData, db: WorldDB, money: MoneyLedger, dead: Dictionary, heir_id: String) -> void:
	var purse: float = float(dead.get("linh_thach", 0.0))
	if purse <= 0.0:
		return
	var who: String = "npc:%s" % str(dead.id)   # called before the record is marked dead, while the purse counts in M
	if heir_id != "" and db.has_record("people", heir_id) and bool(db.get_record("people", heir_id).get("alive", false)):
		money.transfer(who, "npc:%s" % heir_id, purse, "inheritance")
		return
	var sid: String = str(dead.get("sect_id", ""))
	if sid != "" and not _sect(db, sid).is_empty():
		money.transfer(who, "sect:%s" % sid, purse, "inheritance")
		return
	money.burn(who, purse * float(_cfg(gd).money.lost_frac), "heirless")
	var ms: String = _market_sect(db, db.get_record("places", str(dead.get("location_id", ""))))
	if ms != "":
		money.transfer(who, "stash:%s" % ms, money.balance(who), "heirless")
	else:
		money.burn(who, money.balance(who), "heirless")
