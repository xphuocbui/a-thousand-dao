class_name Alchemy
extends RefCounted
## Luyện đan: recipes consume aged linh thảo and produce đan dược whose quality depends
## on ingredient potency. Success rises with Đan Đạo level, Hỏa purity, alchemy_success
## and Ngộ tính; Khí vận can crit for extra yield. Practice levels Đan Đạo.
## Design: game-concept.md § Core Mechanics 3. Data: items_recipes.json (alchemy, recipes).
##
## Usage:
## [codeblock]
## var alch := Alchemy.new(gd, db, items)
## var plan: Dictionary = alch.find_ingredients(c, gd.recipe("tu_khi_dan"))
## var chance: Breakdown = alch.success_chance(c, sheet, gd.recipe("tu_khi_dan"))
## var result: Dictionary = alch.craft(c, sheet, rng, "tu_khi_dan")
## [/codeblock]

const SKILL := "dan_dao"

var _gd: GameData
var _db: WorldDB
var _items: ItemFactory


func _init(gd: GameData, db: WorldDB, items: ItemFactory) -> void:
	_gd = gd
	_db = db
	_items = items


## Success chance (percent) as a breakdown: the designed form shared with Realms Formula D and Character Stats rule 14.
## The base (100 - difficulty + Đan Đạo level + comprehension + Fire purity) sets the failure chance, and a positive
## alchemy_success divides it (fail' = fail / (1 + alchemy_success / 100)); clamped to min..max (Alchemy F1).
func success_chance(c: Character, sheet: StatSheet, recipe: Dictionary) -> Breakdown:
	var cfg: Dictionary = _gd.file("items_recipes").alchemy
	var fx: Dictionary = _gd.element_effects()
	var b := Breakdown.new("Luyện đan success %")
	b.base("100 - difficulty %d" % int(recipe.get("difficulty", 50)), 100.0 - float(recipe.get("difficulty", 50)))
	b.add("Đan Đạo level %d" % c.skill_level(SKILL), float(c.skill_level(SKILL)) * float(cfg.skill_success_per_level))
	b.add("Hỏa purity %s" % LinhCan.fmt(c.linh_can.purity("hoa")), c.linh_can.purity("hoa") * float(fx.alchemy_success_per_purity))
	b.add("Ngộ tính %d" % int(sheet.effective("ngo_tinh", c)), sheet.effective("ngo_tinh", c) * float(cfg.ngo_tinh_success_per_point))
	var alch: float = maxf(0.0, sheet.total("alchemy_success"))
	if alch > 0.0:
		var fail: float = maxf(0.0, 100.0 - b.total)
		b.add("alchemy_success %+.0f divides the failure %.1f%% by %.2f" % [alch, fail, 1.0 + alch / 100.0], fail - fail / (1.0 + alch / 100.0))
	b.clamp_to(float(cfg.min_success), float(cfg.max_success))
	return b


## Whether a recipe ingredient is a strict main herb {herb, min_age, qty} (breakthrough recipes) rather than an element
## value {element, value} (Alchemy rule 5).
static func is_herb_entry(ing: Dictionary) -> bool:
	return ing.has("herb")


## The basic herb of [param element] (Item Database catalogue): the herb a plan grows for an element value.
static func basic_herb(gd: GameData, element: String) -> String:
	for h in gd.herbs():
		if ItemFactory.is_basic_herb(h) and str(h.get("element", "")) == element:
			return str(h.id)
	return ""


## A herb's value at [param age] (Item Database Formula B): base_value x E.
static func value_at(gd: GameData, herb_id: String, age: float) -> float:
	return float(gd.herb(herb_id).get("base_value", 1)) * ItemFactory.equivalents_at(gd, herb_id, age)


## The value an ingredient needs: an element entry its value; a main herb qty x its value at min_age (for pill quality).
static func entry_need(gd: GameData, ing: Dictionary) -> float:
	if is_herb_entry(ing):
		return float(ing.qty) * value_at(gd, str(ing.herb), float(ing.min_age))
	return float(ing.value)


## Short text for an ingredient: "2x Hoàng Tinh Sâm>=40y" or "Hỏa >= 11".
static func entry_label(gd: GameData, ing: Dictionary) -> String:
	if is_herb_entry(ing):
		return "%dx %s>=%.0fy" % [int(ing.qty), gd.herb(str(ing.herb)).get("name", ing.herb), float(ing.min_age)]
	return "%s >= %.0f" % [gd.element_name(str(ing.element)), float(ing.value)]


## Herb templates that can fill an ingredient: the main herb, or every herb listing the element.
static func entry_herbs(gd: GameData, ing: Dictionary) -> Array:
	if is_herb_entry(ing):
		return [str(ing.herb)]
	return gd.herbs().filter(func(h): return ItemFactory.herb_elements(h).has(str(ing.element))).map(func(h): return str(h.id))


## The ages of herbs one plot plan grows for an element value with the element's basic herb: the cheaper in
## herb-years of cycling mature herbs or growing one herb old (Formula B), for the Advisor's plot packing.
static func companion_ages(gd: GameData, element: String, value: float) -> Array:
	var hid: String = basic_herb(gd, element)
	if hid == "":
		return []
	var t: Dictionary = gd.herb(hid)
	var mature: float = maxf(float(t.get("mature_years", 1.0)), 1.0)
	var n: int = int(ceil(value / maxf(float(t.get("base_value", 1)), 1e-9) - 1e-9))
	var cycle: Array = []
	for i in n:
		cycle.append(mature)
	var age: float = mature
	while value_at(gd, hid, age) < value - 1e-9 and age < 2000.0:
		age += 1.0
	return [age] if age < float(n) * mature else cycle


## The value of an owned herb (Item Database Formula B).
func herb_value_of(item: Dictionary) -> float:
	return value_at(_gd, str(item.template), float(item.get("age", 0.0)))


## Picks herbs for each ingredient (Alchemy rule 5): a main herb takes qty herbs of that herb, each at least min_age
## (youngest qualifying first, never substituted); an element value takes unplanted herbs listing the element, basic
## herbs before multi-element ones and the youngest first, until their values reach it; a herb fills one ingredient
## and is never split. Returns {ok, items, missing, need, put} (need and put in value, for pill quality, F3).
func find_ingredients(c: Character, recipe: Dictionary) -> Dictionary:
	var used: Dictionary = {}
	var chosen: Array = []
	var missing: Array = []
	var owned: Array = _db.items_of(c.id).filter(func(i): return i.kind == "herb" and int(i.get("plot", -1)) < 0)
	owned.sort_custom(func(a, b): return float(a.age) < float(b.age) or (float(a.age) == float(b.age) and str(a.id) < str(b.id)))
	var need_tot: float = 0.0
	var put_tot: float = 0.0
	for ing in recipe.get("ingredients", []):
		if is_herb_entry(ing):
			need_tot += entry_need(_gd, ing)
			var got: int = 0
			for item in owned:
				if got >= int(ing.qty):
					break
				if used.has(item.id) or item.template != ing.herb or float(item.age) < float(ing.min_age) - 1e-9:
					continue
				used[item.id] = true
				chosen.append(item.id)
				put_tot += herb_value_of(item)
				got += 1
			if got < int(ing.qty):
				missing.append("%s >= %.0f năm: %d of %d" % [_gd.herb(ing.herb).get("name", ing.herb), float(ing.min_age), got, int(ing.qty)])
			continue
		var need: float = float(ing.value)
		need_tot += need
		var el: String = str(ing.element)
		var pool: Array = owned.filter(func(i): return not used.has(i.id) and (i.get("elements", []) as Array).has(el) if i.has("elements") else ItemFactory.herb_elements(_gd.herb(str(i.template))).has(el))
		pool.sort_custom(func(a, b):
			var ba: bool = ItemFactory.is_basic_herb(_gd.herb(str(a.template)))
			var bb: bool = ItemFactory.is_basic_herb(_gd.herb(str(b.template)))
			if ba != bb:
				return ba
			return float(a.age) < float(b.age) or (float(a.age) == float(b.age) and str(a.id) < str(b.id)))
		var have: float = 0.0
		for item in pool:
			if have >= need - 1e-9:
				break
			used[item.id] = true
			chosen.append(item.id)
			have += herb_value_of(item)
		put_tot += have
		if have < need - 1e-9:
			missing.append("%s %.0f needed, %.0f held" % [_gd.element_name(el), need, have])
	return {"ok": missing.is_empty(), "items": chosen, "missing": missing, "need": need_tot, "put": put_tot}


## Whether [param recipe] is a breakthrough pill: it names a main herb (Alchemy rule 2).
static func is_breakthrough(recipe: Dictionary) -> bool:
	return Array(recipe.get("ingredients", [])).any(func(ing): return is_herb_entry(ing))


## Brew fuel (Alchemy F2): ceil(fuel_frac x price) linh thạch, burned on success or failure; a breakthrough pill burns
## none (rule 6, user decision 2026-11-22: fuel cost a poor Qi Refining life its Foundation pill).
func fuel(recipe: Dictionary) -> int:
	if is_breakthrough(recipe):
		return 0
	var cfg: Dictionary = _gd.file("items_recipes").alchemy
	return int(ceil(float(cfg.get("fuel_frac", 0.0)) * float(recipe.get("price", 0)) - 1e-6))


## Crafts a recipe. Ingredients are consumed whether or not it succeeds.
## Returns {ok, success, message, chance, roll, pill_id, quality, yield, levels}.
func craft(c: Character, sheet: StatSheet, rng: RandomNumberGenerator, recipe_id: String) -> Dictionary:
	var cfg: Dictionary = _gd.file("items_recipes").alchemy
	var recipe: Dictionary = _gd.recipe(recipe_id)
	if recipe.is_empty():
		return {"ok": false, "message": "Unknown recipe '%s'." % recipe_id}
	if c.skill_level(SKILL) + 1 < int(recipe.min_level):
		return {"ok": false, "message": "%s needs Đan Đạo level %d (you have %d; level 0 can attempt level-1 recipes)." % [recipe.name, int(recipe.min_level), c.skill_level(SKILL)]}
	var plan: Dictionary = find_ingredients(c, recipe)
	if not plan.ok:
		return {"ok": false, "message": "Missing: %s" % ", ".join(plan.missing)}
	var fuel_lt: int = fuel(recipe)
	if c.linh_thach < fuel_lt:
		return {"ok": false, "message": "Lighting the cauldron for %s costs %d linh thạch of fuel; you have %d." % [recipe.name, fuel_lt, c.linh_thach]}
	if fuel_lt > 0:
		MoneyLedger.player_pay(_db, c, "", fuel_lt, "craft_fuel")   # Alchemy rule 6: burn_craft (Regional Economy Formula H)
	for iid in plan.items:
		_db.remove("items", iid)
	# Alchemy F3: pill quality reads rho, the value put in over the value the recipe needs
	var potency: float = float(plan.put) / maxf(float(plan.need), 1e-9)
	var chance: float = success_chance(c, sheet, recipe).total
	var roll: float = rng.randf() * 100.0
	var out := {"ok": true, "success": roll < chance, "chance": chance, "roll": roll, "pill_id": "", "quality": 0, "yield": 0, "levels": 0}
	if out.success:
		var quality: int = 0
		var thresholds: Array = cfg.quality_grade_thresholds
		for q in thresholds.size():
			if potency >= float(thresholds[q]):
				quality = q
		var amount: int = int(recipe.yield) + int(sheet.total("alchemy_yield"))
		var crit_chance: float = sheet.effective("khi_van", c) * float(cfg.khi_van_crit_per_point) / 100.0
		var crit: bool = rng.randf() < crit_chance
		if crit:
			amount += int(cfg.crit_extra_yield)
		out.pill_id = add_pills(c, recipe_id, quality, amount)
		out.quality = quality
		out["yield"] = amount
		out.levels = c.add_skill_xp(SKILL, float(recipe.xp), float(cfg.xp_per_level), int(cfg.max_level))
		out.message = "Success (%.0f%% vs roll %.0f): %d x %s, phẩm %d%s." % [chance, roll, amount, recipe.name, quality, " — Khí vận crit!" if crit else ""]
	else:
		out.levels = c.add_skill_xp(SKILL, float(recipe.xp) * float(cfg.fail_xp_fraction), float(cfg.xp_per_level), int(cfg.max_level))
		out.message = "Failed (%.0f%% vs roll %.0f): the cauldron cracks; the herbs are ash." % [chance, roll]
		if c.has_capability(11) and rng.randf() < float(_gd.capability(11).params.chance):
			out.pill_id = add_pills(c, str(cfg.mutated_pill), 0, 1)
			out.message += " Dị Đan Hóa Sinh: a strange pill forms in the ash."
	if out.levels > 0:
		out.message += " Đan Đạo rises to level %d." % c.skill_level(SKILL)
	return out


## Adds pills to the character, merging with an existing stack of the same quality.
func add_pills(c: Character, recipe_id: String, quality: int, qty: int) -> String:
	for item in _db.items_of(c.id):
		if item.kind == "pill" and item.template == recipe_id and int(item.quality) == quality:
			item["qty"] = int(item.qty) + qty
			return item.id
	var p: Dictionary = _items.pill(recipe_id, quality, qty)
	p["owner_id"] = c.id
	return _db.add("items", p)
