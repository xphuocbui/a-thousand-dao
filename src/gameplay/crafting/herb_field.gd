class_name HerbField
extends RefCounted
## Linh điền: the plots in a cultivator's động phủ where linh thảo age. Herbs are items
## in the WorldDB with a `plot` index (>= 0 while planted). Planted herbs age every season
## at a rate set by Mộc purity and herb_growth_pct, so long-term planning matters
## (pillar: Every Season Counts). Data: session_actions.json (field), items_herbs.json.
##
## Usage:
## [codeblock]
## var field := HerbField.new(gd, db, items)
## var r: Dictionary = field.plant_seed(c, sheet, "hoang_tinh_sam")
## field.grow(c, sheet, 4)              # one year
## var h: Dictionary = field.harvest(c, 0)
## [/codeblock]

var _gd: GameData
var _db: WorldDB
var _items: ItemFactory


func _init(gd: GameData, db: WorldDB, items: ItemFactory) -> void:
	_gd = gd
	_db = db
	_items = items


## Number of plots available to this character.
func plot_count(c: Character, sheet: StatSheet) -> int:
	return int(CharacterRules.field_plots(c, _gd, sheet).total)


## Herbs currently planted, as a Dictionary plot -> item record.
func planted(c: Character) -> Dictionary:
	var out: Dictionary = {}
	for item in _db.items_of(c.id):
		if item.kind == "herb" and int(item.get("plot", -1)) >= 0:
			out[int(item.plot)] = item
	return out


## First free plot index, or -1.
func free_plot(c: Character, sheet: StatSheet) -> int:
	var used: Dictionary = planted(c)
	for i in plot_count(c, sheet):
		if not used.has(i):
			return i
	return -1


## Herb templates whose seeds can be bought anywhere at a realm (seed_rarity_by_realm).
func seed_catalog(realm_index: int = 0) -> Array:
	var max_r: int = int(_gd.session().field.seed_rarity_by_realm[realm_index])
	return _gd.herbs().filter(func(h): return int(h.rarity) <= max_r)


## Buys a seed and plants it. Returns {ok, message, item_id}.
func plant_seed(c: Character, sheet: StatSheet, herb_id: String) -> Dictionary:
	var t: Dictionary = _gd.herb(herb_id)
	if t.is_empty():
		return {"ok": false, "message": "Unknown herb '%s'." % herb_id}
	if not seed_catalog(c.realm_index).has(t):
		return {"ok": false, "message": "%s seeds are too rare to buy; find or buy a living plant and transplant it." % t.name}
	var check: Dictionary = _can_work(c, sheet)
	if not check.ok:
		return check
	var price: int = int(t.seed_price)
	if c.linh_thach < price:
		return {"ok": false, "message": "A %s seed costs %d linh thạch; you have %d." % [t.name, price, c.linh_thach]}
	c.linh_thach -= price
	var item: Dictionary = _items.herb(herb_id, 0.0)
	item["owner_id"] = c.id
	item["plot"] = check.plot
	var iid: String = _db.add("items", item)
	return {"ok": true, "message": "Planted %s in plot %d (-%d linh thạch)." % [t.name, check.plot, price], "item_id": iid}


## Transplants an owned herb item into a free plot (keeps its age).
func transplant(c: Character, sheet: StatSheet, item_id: String) -> Dictionary:
	var item: Dictionary = _db.get_record("items", item_id)
	if item.is_empty() or item.owner_id != c.id or item.kind != "herb":
		return {"ok": false, "message": "You do not own a herb %s." % item_id}
	if int(item.get("plot", -1)) >= 0:
		return {"ok": false, "message": "%s is already planted." % item.name}
	var check: Dictionary = _can_work(c, sheet)
	if not check.ok:
		return check
	item["plot"] = check.plot
	return {"ok": true, "message": "Transplanted %s (%.1f năm) into plot %d." % [item.name, float(item.age), check.plot], "item_id": item_id}


## Harvests the herb in a plot into the inventory. Returns {ok, message, item_id}.
func harvest(c: Character, plot: int) -> Dictionary:
	var p: Dictionary = planted(c)
	if not p.has(plot):
		return {"ok": false, "message": "Plot %d is empty." % plot}
	if bool(_gd.session().field.must_be_home) and c.location_id != c.home_id and not c.has_capability(14):
		return {"ok": false, "message": "You must be at your động phủ to harvest."}
	var item: Dictionary = p[plot]
	item["plot"] = -1
	return {"ok": true, "message": "Harvested %s." % _items.describe(item), "item_id": item.id}


## Ages every planted herb by [param seasons]. Returns the growth multiplier used.
func grow(c: Character, sheet: StatSheet, seasons: int) -> float:
	var mult: float = CharacterRules.herb_growth(c, _gd, sheet).total
	var years: float = float(seasons) / float(_gd.cultivation_rules().seasons_per_year) * mult
	for item in planted(c).values():
		item["age"] = float(item.age) + years
	if c.has_capability(12):
		var rate: float = float(_gd.capability(12).params.rate)
		for item in _db.items_of(c.id):
			if item.kind == "herb" and int(item.get("plot", -1)) < 0:
				item["age"] = float(item.age) + years * rate
	return mult


## Years until a planted herb reaches [param target_age] at the current growth rate.
func years_until(c: Character, sheet: StatSheet, item: Dictionary, target_age: float) -> float:
	var mult: float = CharacterRules.herb_growth(c, _gd, sheet).total
	return maxf(target_age - float(item.age), 0.0) / maxf(mult, 0.01)


func _can_work(c: Character, sheet: StatSheet) -> Dictionary:
	if bool(_gd.session().field.must_be_home) and c.location_id != c.home_id and not c.has_capability(14):
		return {"ok": false, "message": "You must be at your động phủ (home) to tend the field."}
	var plot: int = free_plot(c, sheet)
	if plot == -1:
		return {"ok": false, "message": "All %d plots are in use." % plot_count(c, sheet)}
	return {"ok": true, "plot": plot}
