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


## Success chance (percent) as a breakdown.
func success_chance(c: Character, sheet: StatSheet, recipe: Dictionary) -> Breakdown:
	var cfg: Dictionary = _gd.file("items_recipes").alchemy
	var fx: Dictionary = _gd.element_effects()
	var b := Breakdown.new("Luyện đan success %")
	b.base("100 - difficulty %d" % int(recipe.difficulty), 100.0 - float(recipe.difficulty))
	b.add("Đan Đạo level %d" % c.skill_level(SKILL), float(c.skill_level(SKILL)) * float(cfg.skill_success_per_level))
	b.add("Hỏa purity %d" % int(c.linh_can.purity("hoa")), c.linh_can.purity("hoa") * float(fx.alchemy_success_per_purity))
	b.add("Ngộ tính %d" % int(sheet.effective("ngo_tinh", c)), sheet.effective("ngo_tinh", c) * float(cfg.ngo_tinh_success_per_point))
	if sheet.total("alchemy_success") != 0.0:
		b.add("alchemy_success", sheet.total("alchemy_success"))
	b.clamp_to(float(cfg.min_success), float(cfg.max_success))
	return b


## Picks the youngest qualifying herbs for each ingredient (keeping older herbs).
## Returns {ok, items: [item ids], missing: [text]}.
func find_ingredients(c: Character, recipe: Dictionary) -> Dictionary:
	var used: Dictionary = {}
	var chosen: Array = []
	var missing: Array = []
	var owned: Array = _db.items_of(c.id).filter(func(i): return i.kind == "herb" and int(i.get("plot", -1)) < 0)
	owned.sort_custom(func(a, b): return float(a.age) < float(b.age))
	for ing in recipe.ingredients:
		var need: int = int(ing.qty)
		for item in owned:
			if need == 0:
				break
			if used.has(item.id) or item.template != ing.herb or float(item.age) < float(ing.min_age):
				continue
			used[item.id] = true
			chosen.append(item.id)
			need -= 1
		if need > 0:
			missing.append("%d x %s (>= %.0f năm)" % [need, _gd.herb(ing.herb).get("name", ing.herb), float(ing.min_age)])
	return {"ok": missing.is_empty(), "items": chosen, "missing": missing}


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
	var potency: float = 0.0
	for iid in plan.items:
		potency += _items.herb_potency(_db.get_record("items", iid))
		_db.remove("items", iid)
	potency /= float(plan.items.size())
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
