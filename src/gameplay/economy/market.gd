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
			if not Alchemy.is_herb_entry(ing):
				continue   # element values are not main herbs (Alchemy rule 11)
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
	restock_raw(place_id)   # raw goods: a view of the market's pools, each season (continent only)
	var cfg: Dictionary = _gd.session().market
	if place.has("stock_year") and year - int(place.stock_year) < int(cfg.restock_every_years):
		return
	var on_continent: bool = not _shop_ctx({"kind": "herb", "template": "ngung_khi_thao"}, place).is_empty()
	for old in stock(place_id):
		if not bool(old.get("reserved", false)) and not (on_continent and str(old.get("kind", "")) in ["herb", "material"]):
			_db.remove("items", old.id)
	var owner: String = owner_of(place_id)
	var tier: int = clampi(realm_index, 0, _gd.realms().size() - 1)
	var barred: Array = breakthrough_main_herbs(_gd)
	var herbs: Array = _gd.herbs().filter(func(t): return int(t.rarity) <= int(cfg.stock_herb_rarity_max) and not barred.has(t.id))
	if on_continent:   # raw goods come from the market's pools instead (restock_raw, once a season)
		herbs = []
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
	for i in int(cfg.get("stock_materials", 0)) if not on_continent else 0:
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


## Regional Economy & Trade's restock (Edge Cases, AC-RE-35; Trade Goods rules 8 and 10): once a season a continent
## place's raw shelf is rebuilt as a view of its market's pools: each shelved good at the place's share of the pool by
## settlement weight, in whole units, herbs at their mature age (capped at shelf.herb_max items and material_max units
## a good). A view, not a withdrawal: the pool changes only through the player's trades (Formula B's buy_pl).
func restock_raw(place_id: String) -> void:
	var place: Dictionary = _db.get_record("places", place_id)
	if place.is_empty() or not bool(place.get("market", false)):
		return
	var ctx := _shop_ctx({"kind": "herb", "template": "ngung_khi_thao"}, place)
	if ctx.is_empty():
		return
	var m: Dictionary = _db.get_record(WorldEconomy.TABLE, str(ctx.market))
	if int(place.get("shelf_season", -1)) == int(m.get("season", 0)):
		return
	place["shelf_season"] = int(m.get("season", 0))
	for old in stock(place_id):
		if str(old.get("kind", "")) in ["herb", "material"] and not bool(old.get("reserved", false)):
			_db.remove("items", old.id)
	var cfg: Dictionary = _gd.file(WorldEconomy.FILE)
	var w: Dictionary = cfg.shop.w_place
	var tot_w: float = 0.0
	for p in _db.all("places"):
		if bool(p.get("market", false)) and WorldEconomy.market_of_region(_db, _db.get_record("regions", str(p.get("region_id", "")))) == str(ctx.market):
			tot_w += float(w.get(str(p.get("kind", "")), 1.0))
	var share: float = float(w.get(str(place.get("kind", "")), 1.0)) / maxf(tot_w, 1.0)
	var owner: String = owner_of(place_id)
	for cid in m.classes:
		var pool: Dictionary = m.classes[cid].pool
		var goods: Array = pool.keys()
		goods.sort()
		for g in goods:
			var v: float = TradeGoods.unit_value(_gd, str(g))
			if float(pool[g]) < v:   # an unshelved good is not on any shelf
				continue
			var units: int = int(floor(share * float(pool[g]) / v))
			if units <= 0:
				continue
			if not _gd.herb(str(g)).is_empty():
				for i in mini(units, int(cfg.shelf.herb_max)):
					var h: Dictionary = _items.herb(str(g), float(_gd.herb(str(g)).get("mature_years", 1)))
					h["owner_id"] = owner
					_db.add("items", h)
			elif not _gd.material(str(g)).is_empty():
				var mt: Dictionary = _items.material(str(g), mini(units, int(cfg.shelf.material_max)))
				mt["owner_id"] = owner
				_db.add("items", mt)


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
		"pill", "talisman", "artifact":   # Trade Goods rule 11: a crafted class by its tier (a pill by its recipe)
			var cc: String = CraftEconomy.class_of_item(_gd, item, float(_items.value_of(item)))
			if cc != "":
				return {"raw": false, "k": cc, "good": ""}
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
	elif str(ic.k) != "":   # a crafted class: its price, held within loc_band_fin of the market's (Formula G)
		p_loc = WorldEconomy.local_price(_db, str(region.id), str(ic.k))
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
		return EconomyRules.sell_price(cfg, v, float(ctx.p_loc), bool(ctx.raw), str(ctx.kind), mi, 0, float(ctx.sf), _tar_in(item, ctx), sl)
	var vv: float = float(_items.value_of(item)) * float(_gd.session().market.sell_ratio) * (1.0 + _charm(c, sheet))
	return maxi(1, int(floorf(vv + 1e-6)))


# Formula G's tar_in: an item from another market pays this market's import tariff when sold here (rule 16; its
# origin_market is set when a shop sells it, when it is gathered or harvested). 0 for an untagged item or one from here.
func _tar_in(item: Dictionary, ctx: Dictionary) -> float:
	var origin: String = str(item.get("origin_market", ""))
	if origin == "" or origin == str(ctx.market):
		return 0.0
	var sect: Dictionary = _db.get_record("sects", str(_db.get_record(WorldEconomy.TABLE, str(ctx.market)).get("sect_id", "")))
	return EconomyRules.tariff(_gd.file(WorldEconomy.FILE), int(sect.get("dials", {}).get("openness", 2)))


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
	if str(ctx.k) != "" and moved > 0:   # raw and crafted trades enter the market's books (P_eff, L1)
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
		item["origin_market"] = str(ctx.market)   # Formula G: a shop's item carries its market
	var bought_id: String = item_id
	if int(item.get("qty", 1)) > 1:
		item["qty"] = int(item.qty) - 1
		var copy: Dictionary = item.duplicate(true)
		copy.erase("id")
		copy["qty"] = 1
		copy["owner_id"] = c.id
		bought_id = add_or_merge(c, copy)
	else:
		_db.set_owner(item, c.id)
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
