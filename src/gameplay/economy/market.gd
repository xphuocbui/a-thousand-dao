class_name Market
extends RefCounted
## Phường thị trading. Each market place holds a generated stock (items owned by
## "market:<place id>") that restocks yearly. On the continent, prices follow Regional Economy & Trade Formula G at the
## shop's region's local price ([WorldEconomy]) and the money moves through the market's commons pool
## ([MoneyLedger]); elsewhere value x buy_markup when buying, value x sell_ratio when selling, both nudged by Mị lực.
## Data: session_actions.json (market).
##
## Usage:
## [codeblock]
## var m := Market.new(gd, db, items)
## m.ensure_stock(rng, place_id, year, realm_index)
## for it in m.stock(place_id): print(m.buy_price(c, sheet, it), " ", it.name)
## var r: Dictionary = m.buy(c, sheet, place_id, item_id)
## [/codeblock]

var _gd: GameData
var _db: WorldDB
var _items: ItemFactory


func _init(gd: GameData, db: WorldDB, items: ItemFactory) -> void:
	_gd = gd
	_db = db
	_items = items


## Owner id used for a place's stock.
static func owner_of(place_id: String) -> String:
	return "market:" + place_id


## Each breakthrough recipe's main herb: the ingredient with the most herb-years (qty x min_age).
## Random stock never holds these (canh-gioi.md Formulas D, decision 2026-11-05).
static func breakthrough_main_herbs(gd: GameData) -> Array:
	var out: Array = []
	for r in gd.recipes():
		if r.effect.type != "breakthrough":
			continue
		var main: String = ""
		var most: float = -1.0
		for ing in r.ingredients:
			var years: float = float(ing.qty) * float(ing.min_age)
			if years > most:
				most = years
				main = str(ing.herb)
		if not out.has(main):
			out.append(main)
	return out


## Regenerates stock if the place has a market and the stock is older than the restock period.
func ensure_stock(rng: RandomNumberGenerator, place_id: String, year: int, realm_index: int, root: LinhCan = null) -> void:
	var place: Dictionary = _db.get_record("places", place_id)
	if place.is_empty() or not bool(place.get("market", false)):
		return
	var cfg: Dictionary = _gd.session().market
	if place.has("stock_year") and year - int(place.stock_year) < int(cfg.restock_every_years):
		return
	for old in stock(place_id):
		if not bool(old.get("reserved", false)):
			_db.remove("items", old.id)
	var owner: String = owner_of(place_id)
	var tier: int = clampi(realm_index, 0, _gd.realms().size() - 1)
	var barred: Array = breakthrough_main_herbs(_gd)
	var herbs: Array = _gd.herbs().filter(func(t): return int(t.rarity) <= int(cfg.stock_herb_rarity_max) and not barred.has(t.id))
	for i in int(cfg.stock_herbs) if not herbs.is_empty() else 0:
		var t: Dictionary = RngUtils.weighted_pick(rng, herbs.map(func(x): return {"id": x.id, "weight": 1.0 / float(x.rarity)}))
		var h: Dictionary = _items.herb(t.id, RngUtils.range_f(rng, [0.0, float(cfg.aged_herb_max_years)]))
		h["owner_id"] = owner
		_db.add("items", h)
	for i in int(cfg.stock_artifacts):
		var a: Dictionary = _items.artifact(rng, tier, _items.roll_grade(rng, int(cfg.stock_artifact_grade_base) + tier / 2))
		a["owner_id"] = owner
		_db.add("items", a)
	var price_cap: float = float(_gd.realm_budget(tier).get("pill_price_max", 0)) * float(cfg.stock_pill_price_budget_mult)
	var next_tag: String = ""
	if tier + 1 < _gd.realms().size():
		next_tag = str(_gd.realm(tier + 1).entry_requirement.item_tag)
	var recipes: Array = []
	for r in _gd.recipes():
		if r.effect.type == "breakthrough":
			if str(r.effect.get("tag", "")) == next_tag and rng.randf() < float(cfg.stock_breakthrough_pill_chance):
				recipes.append(r)
		elif float(r.price) <= price_cap:
			recipes.append(r)
	for i in int(cfg.stock_pills):
		if recipes.is_empty():
			break
		var r: Dictionary = RngUtils.pick(rng, recipes)
		var p: Dictionary = _items.pill(r.id, rng.randi_range(0, int(cfg.stock_pill_quality_max)), rng.randi_range(1, int(cfg.stock_pill_qty_max)))
		p["owner_id"] = owner
		_db.add("items", p)
	var mat_rarity: int = int(_gd.realm_budget(tier).get("material_rarity_max", 2))
	for i in int(cfg.get("stock_materials", 0)):
		var m: Dictionary = _items.random_material(rng, mat_rarity)
		m["qty"] = rng.randi_range(1, int(cfg.get("stock_material_qty_max", 1)))
		m["owner_id"] = owner
		_db.add("items", m)
	for i in int(cfg.stock_cong_phap):
		var cp_kind: String = "secret" if rng.randf() < float(cfg.get("stock_secret_art_chance", 0.0)) else "main"
		var cp: Dictionary = _items.cong_phap(rng, clampi(tier, 0, 3), [], "", {"kind": cp_kind, "root": root})
		cp["owner_id"] = owner
		_db.add("items", cp)
	place["stock_year"] = year


## Rule 18: stocks a reserved copy of each par-tier single-element main method for every realm
## from Core Formation up. The copies survive restocks and appear once per manual.
func stock_guaranteed(place_id: String) -> void:
	var owner: String = owner_of(place_id)
	var have: Array = stock(place_id).map(func(it): return str(it.get("tech_id", "")))
	for r in range(2, _gd.realms().size()):
		var par: int = CongPhap.par_tier(_gd, r)
		for e in _gd.element_cycle():
			var m: Dictionary = _par_manual(par, str(e))
			if m.is_empty() or have.has(str(m.tech_id)):
				continue
			m["reserved"] = true
			m["owner_id"] = owner
			_db.add("items", m)
			have.append(str(m.tech_id))


func _par_manual(par: int, element: String) -> Dictionary:
	for t in _gd.cong_phap_file().get("templates", []):
		if int(t.tier) == par and t.tech_kind == "main" and t.names == [element]:
			return _items.manual_from_template(t)
	var m: Dictionary = _items.cong_phap(_rng_for(par, element), par, [element])
	m["tech_id"] = "par_%d_%s" % [par, element]
	return m


func _rng_for(par: int, element: String) -> RandomNumberGenerator:
	var r := RandomNumberGenerator.new()
	r.seed = RngUtils.stable_hash("%d:%s" % [par, element])
	return r


## Items for sale at a place.
func stock(place_id: String) -> Array:
	return _db.items_of(owner_of(place_id))


## Mị lực price factor: 1 - (Mị lực - 50) x per_point when buying.
func _charm(c: Character, sheet: StatSheet) -> float:
	return (sheet.effective("mi_luc", c) - 50.0) * float(_gd.session().market.mi_luc_price_per_point)


## The class an item trades in (Regional Economy & Trade rule 4, Trade Goods rule 8a): a herb or material is a raw good
## of its kind and rarity band ([method WorldEconomy.class_of]); anything else is a finished good, priced at P = 1
## until Trade Goods' crafted classes exist. {raw, k (class id), good}.
func item_class(item: Dictionary) -> Dictionary:
	match str(item.get("kind", "")):
		"herb", "material":
			var t: String = str(item.get("template", ""))
			return {"raw": true, "k": WorldEconomy.class_of(_gd, t), "good": t}
	return {"raw": false, "k": "", "good": ""}


# The place an item is offered at: its shop for stock, else [param place_id].
func _place_for(item: Dictionary, place_id: String) -> Dictionary:
	var owner: String = str(item.get("owner_id", ""))
	if owner.begins_with("market:"):
		return _db.get_record("places", owner.substr(7))
	return _db.get_record("places", place_id)


# Formula G's inputs at [param place] for [param item]: its local price, raw or finished, the place's kind, the
# market and region. {} when the place has no market price (no continent markets, or a region no great sect holds).
func _shop_ctx(item: Dictionary, place: Dictionary) -> Dictionary:
	if place.is_empty() or _db.count(WorldEconomy.TABLE) == 0:
		return {}
	var region: Dictionary = _db.get_record("regions", str(place.get("region_id", "")))
	var mid: String = WorldEconomy.market_of_region(_db, region)
	if mid == "":
		return {}
	var ic: Dictionary = item_class(item)
	var p_loc: float = 1.0
	var sf: float = 1.0
	if bool(ic.raw):
		p_loc = WorldEconomy.local_price(_db, str(region.id), str(ic.k))
		sf = WorldEconomy.scarcity_factor(_gd, _db, mid, str(ic.good))   # Trade Goods Formula D
	return {"raw": bool(ic.raw), "k": str(ic.k), "good": str(ic.good), "p_loc": p_loc, "sf": sf, "kind": str(place.get("kind", "")),
		"market": mid, "region": str(region.id), "place": str(place.id)}


## Price to buy one unit. On the continent: Regional Economy & Trade Formula G at the shop's region's local price (raw
## goods at the bulk spread, no charm; finished goods at the retail spread with charm); elsewhere the flat built price.
func buy_price(c: Character, sheet: StatSheet, item: Dictionary, place_id: String = "") -> int:
	var ctx := _shop_ctx(item, _place_for(item, place_id))
	if not ctx.is_empty():
		var mi: int = int(sheet.effective("mi_luc", c))
		return EconomyRules.buy_price(_gd.file(WorldEconomy.FILE), float(_items.value_of(item)), float(ctx.p_loc), bool(ctx.raw), str(ctx.kind), mi, 0, float(ctx.sf))
	var v: float = float(_items.value_of(item)) * float(_gd.session().market.buy_markup) * (1.0 - _charm(c, sheet))
	return maxi(1, int(ceilf(v - 1e-6)))


## Price received for selling one unit at [param place_id] (Formula G with the sell slippage of what the player already
## sold of the class there this season; the flat built price off the continent).
func sell_price(c: Character, sheet: StatSheet, item: Dictionary, place_id: String = "") -> int:
	var ctx := _shop_ctx(item, _place_for(item, place_id if place_id != "" else c.location_id))
	if not ctx.is_empty():
		var cfg: Dictionary = _gd.file(WorldEconomy.FILE)
		var v: float = float(_items.value_of(item))
		var sl: float = 1.0
		if bool(ctx.raw):
			sl = EconomyRules.slip(cfg, WorldEconomy.kind_of_class(str(ctx.k)), _sold_here(ctx), v, _place_demand(ctx))
		var mi: int = int(sheet.effective("mi_luc", c))
		return EconomyRules.sell_price(cfg, v, float(ctx.p_loc), bool(ctx.raw), str(ctx.kind), mi, 0, float(ctx.sf), 0.0, sl)
	var vv: float = float(_items.value_of(item)) * float(_gd.session().market.sell_ratio) * (1.0 + _charm(c, sheet))
	return maxi(1, int(floorf(vv + 1e-6)))


# Formula G's q_sold: base value of the class the player sold at this place this season.
func _sold_here(ctx: Dictionary) -> float:
	var m: Dictionary = _db.get_record(WorldEconomy.TABLE, str(ctx.market))
	return float(m.get("player", {}).get("sold_at", {}).get(str(ctx.place), {}).get(str(ctx.k), 0.0))


# Formula G's Dp: the place's share of its region's demand for the class, by settlement weight.
func _place_demand(ctx: Dictionary) -> float:
	var cfg: Dictionary = _gd.file(WorldEconomy.FILE)
	var m: Dictionary = _db.get_record(WorldEconomy.TABLE, str(ctx.market))
	var d_r: float = float(m.regions.get(str(ctx.region), {}).get("d_r", {}).get(str(ctx.k), 0.0))
	var w: Dictionary = cfg.shop.w_place
	var tot: float = 0.0
	for pid in _db.get_record("regions", str(ctx.region)).get("places", []):
		tot += float(w.get(str(_db.get_record("places", str(pid)).get("kind", "")), 0.0))
	return maxf(1.0, d_r * float(w.get(str(ctx.kind), 0.0)) / maxf(1.0, tot))


# The player's trade at a continent shop: the money goes through the market's commons pool (Formula H) and a raw
# trade enters the market's books (P_eff, Formula L1's buy_pl / sell_pl, Formula G's q_sold). Returns what moved.
func _book_trade(c: Character, ctx: Dictionary, value: float, price: int, buy: bool) -> int:
	var money := MoneyLedger.new(_db, c)
	var pool: String = "pool:%s" % str(_db.get_record(WorldEconomy.TABLE, str(ctx.market)).sect_id)
	var moved: int = int(money.transfer("player", pool, price, "shop_buy")) if buy else int(money.transfer(pool, "player", price, "shop_sell"))
	if buy and moved > 0:   # the player's purchases are part of the market's turnover (Sects F3's Turn_m)
		var mk: Dictionary = _db.get_record(WorldEconomy.TABLE, str(ctx.market))
		mk["turnover_player"] = float(mk.get("turnover_player", 0.0)) + moved
	if bool(ctx.raw) and moved > 0:
		WorldEconomy.record_player_trade(_gd, _db, str(ctx.region), str(ctx.k), value, buy, str(ctx.good))
		if not buy:
			var m: Dictionary = _db.get_record(WorldEconomy.TABLE, str(ctx.market))
			if not m.player.has("sold_at"):
				m.player["sold_at"] = {}
			if not m.player.sold_at.has(str(ctx.place)):
				m.player.sold_at[str(ctx.place)] = {}
			m.player.sold_at[str(ctx.place)][str(ctx.k)] = float(m.player.sold_at[str(ctx.place)].get(str(ctx.k), 0.0)) + value
	return moved


## Buys one unit (stacks split). Returns {ok, message, item_id}.
func buy(c: Character, sheet: StatSheet, place_id: String, item_id: String) -> Dictionary:
	var item: Dictionary = _db.get_record("items", item_id)
	if item.is_empty() or item.owner_id != owner_of(place_id):
		return {"ok": false, "message": "That item is not for sale here."}
	var price: int = buy_price(c, sheet, item, place_id)
	if c.linh_thach < price:
		return {"ok": false, "message": "%s costs %d linh thạch; you have %d." % [item.name, price, c.linh_thach]}
	var ctx := _shop_ctx(item, _db.get_record("places", place_id))
	if ctx.is_empty():
		c.linh_thach -= price
	else:
		_book_trade(c, ctx, float(_items.value_of(item)), price, true)
	var bought_id: String = item_id
	if int(item.get("qty", 1)) > 1:
		item["qty"] = int(item.qty) - 1
		var copy: Dictionary = item.duplicate(true)
		copy.erase("id")
		copy["qty"] = 1
		copy["owner_id"] = c.id
		bought_id = add_or_merge(c, copy)
	else:
		item["owner_id"] = c.id
		if item.kind in ["pill", "material", "talisman"]:
			_db.remove("items", item_id)
			item.erase("id")
			bought_id = add_or_merge(c, item)
	return {"ok": true, "message": "Bought %s for %d linh thạch." % [item.name, price], "item_id": bought_id}


## Sells one unit of an owned item at a market place. Returns {ok, message}.
func sell(c: Character, sheet: StatSheet, place_id: String, item_id: String) -> Dictionary:
	var place: Dictionary = _db.get_record("places", place_id)
	if not bool(place.get("market", false)):
		return {"ok": false, "message": "There is no market here."}
	var item: Dictionary = _db.get_record("items", item_id)
	if item.is_empty() or item.owner_id != c.id:
		return {"ok": false, "message": "You do not own %s." % item_id}
	if c.equipped.has(item_id):
		return {"ok": false, "message": "Unequip %s first." % item.name}
	if item.kind == "herb" and int(item.get("plot", -1)) >= 0:
		return {"ok": false, "message": "Harvest %s before selling it." % item.name}
	var price: int = sell_price(c, sheet, item, place_id)
	var ctx := _shop_ctx(item, place)
	if ctx.is_empty():
		c.linh_thach += price
	else:
		# the commons pool pays (Formula H); a pool that cannot pay the whole price does not buy
		var pool: String = "pool:%s" % str(_db.get_record(WorldEconomy.TABLE, str(ctx.market)).sect_id)
		if MoneyLedger.new(_db, c).balance(pool) < float(price):
			return {"ok": false, "message": "The traders here cannot pay %d linh thạch for %s this season." % [price, item.name]}
		_book_trade(c, ctx, float(_items.value_of(item)), price, false)
	if int(item.get("qty", 1)) > 1:
		item["qty"] = int(item.qty) - 1
	else:
		_db.remove("items", item_id)
	return {"ok": true, "message": "Sold %s for %d linh thạch." % [item.name, price]}


## Gives [param item] to [param c], stacking pills and materials onto an existing stack.
## Returns the id of the stack or new item.
func add_or_merge(c: Character, item: Dictionary) -> String:
	if item.kind in ["pill", "material", "talisman"]:
		for own in _db.items_of(c.id):
			if own.kind == item.kind and own.template == item.template and int(own.get("quality", 0)) == int(item.get("quality", 0)):
				own["qty"] = int(own.qty) + int(item.get("qty", 1))
				return own.id
	return _db.add("items", item)
