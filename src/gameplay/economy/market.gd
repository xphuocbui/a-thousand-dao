class_name Market
extends RefCounted
## Phường thị trading. Each market place holds a generated stock (items owned by
## "market:<place id>") that restocks yearly. Prices: value x buy_markup when buying,
## value x sell_ratio when selling, both nudged by Mị lực.
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
	for i in int(cfg.stock_herbs):
		var h: Dictionary = _items.random_herb(rng, int(cfg.stock_herb_rarity_max), [0.0, float(cfg.aged_herb_max_years)])
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
	r.seed = hash("%d:%s" % [par, element])
	return r


## Items for sale at a place.
func stock(place_id: String) -> Array:
	return _db.items_of(owner_of(place_id))


## Mị lực price factor: 1 - (Mị lực - 50) x per_point when buying.
func _charm(c: Character, sheet: StatSheet) -> float:
	return (sheet.effective("mi_luc", c) - 50.0) * float(_gd.session().market.mi_luc_price_per_point)


## Price to buy one unit.
func buy_price(c: Character, sheet: StatSheet, item: Dictionary) -> int:
	var v: float = float(_items.value_of(item)) * float(_gd.session().market.buy_markup) * (1.0 - _charm(c, sheet))
	return maxi(1, int(ceilf(v - 1e-6)))


## Price received for selling one unit.
func sell_price(c: Character, sheet: StatSheet, item: Dictionary) -> int:
	var v: float = float(_items.value_of(item)) * float(_gd.session().market.sell_ratio) * (1.0 + _charm(c, sheet))
	return maxi(1, int(floorf(v + 1e-6)))


## Buys one unit (stacks split). Returns {ok, message, item_id}.
func buy(c: Character, sheet: StatSheet, place_id: String, item_id: String) -> Dictionary:
	var item: Dictionary = _db.get_record("items", item_id)
	if item.is_empty() or item.owner_id != owner_of(place_id):
		return {"ok": false, "message": "That item is not for sale here."}
	var price: int = buy_price(c, sheet, item)
	if c.linh_thach < price:
		return {"ok": false, "message": "%s costs %d linh thạch; you have %d." % [item.name, price, c.linh_thach]}
	c.linh_thach -= price
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
		if item.kind in ["pill", "material"]:
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
	var price: int = sell_price(c, sheet, item)
	c.linh_thach += price
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
