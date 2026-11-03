class_name Refinery
extends RefCounted
## Luyện khí: refines a pháp bảo from a base design, materials and linh thạch fuel.
## Kim purity is the refining affinity (as Hỏa is for alchemy). Spec:
## design/quick-specs/luyen-khi-and-tran-phap.md. Data: crafting_refining.json,
## items_artifacts.json (bases, grades, tiers), items_materials.json.
##
## Usage:
## [codeblock]
## var refinery := Refinery.new(gd, db, items)
## var check: Dictionary = refinery.check(c, "phi_kiem", 1)   # {ok, reason, fuel, materials}
## var r: Dictionary = refinery.refine(c, sheet, rng, "phi_kiem", 1)
## [/codeblock]

var _gd: GameData
var _db: WorldDB
var _items: ItemFactory


func _init(gd: GameData, db: WorldDB, items: ItemFactory) -> void:
	_gd = gd
	_db = db
	_items = items


## crafting_refining.json content.
func config() -> Dictionary:
	return _gd.file("crafting_refining")


## Luyện khí skill id.
func skill() -> String:
	return str(config().skill)


## Linh thạch fuel for one attempt.
func fuel_cost(base_id: String, tier: int) -> int:
	var base: Dictionary = _gd.artifact_base(base_id)
	return int(roundf(float(base.get("base_value", 0)) * float(_gd.artifact_tier(tier).value_scale) * float(config().fuel_mult)))


## Success chance (percent) for a tier, as a breakdown.
func success_chance(c: Character, sheet: StatSheet, tier: int) -> Breakdown:
	var cfg: Dictionary = config()
	var t: int = clampi(tier, 0, cfg.difficulty.size() - 1)
	var b := Breakdown.new("Luyện khí success %")
	b.base("100 - difficulty %d (%s)" % [int(cfg.difficulty[t]), _gd.artifact_tier(t).name], 100.0 - float(cfg.difficulty[t]))
	b.add("Luyện khí level %d" % c.skill_level(skill()), float(c.skill_level(skill())) * float(cfg.success_per_level))
	b.add("Kim purity %d" % int(c.linh_can.purity("kim")), c.linh_can.purity("kim") * float(cfg.kim_success_per_purity))
	b.add("Ngộ tính %d" % int(sheet.effective("ngo_tinh", c)), sheet.effective("ngo_tinh", c) * float(cfg.ngo_tinh_per_point))
	if sheet.total("refining_success") != 0.0:
		b.add("refining_success", sheet.total("refining_success"))
	b.clamp_to(float(cfg.min_success), float(cfg.max_success))
	return b


## The cheapest owned materials that satisfy a tier: {ok, units: [{id, take}], missing}.
func pick_materials(c: Character, tier: int) -> Dictionary:
	var cfg: Dictionary = config()
	var need: int = int(cfg.materials[tier])
	var min_r: int = int(cfg.min_rarity[tier])
	var owned: Array = _db.items_of(c.id).filter(func(i): return i.kind == "material" and int(_gd.material(str(i.template)).get("rarity", 0)) >= min_r)
	owned.sort_custom(func(a, b): return int(_gd.material(str(a.template)).base_value) < int(_gd.material(str(b.template)).base_value))
	var units: Array = []
	var left: int = need
	for it in owned:
		if left <= 0:
			break
		var take: int = mini(int(it.get("qty", 1)), left)
		units.append({"id": it.id, "take": take})
		left -= take
	return {"ok": left <= 0, "units": units, "missing": "" if left <= 0 else "%d more material(s) of rarity ≥ %d" % [left, min_r]}


## Whether a refine can start: {ok, reason, fuel, materials}.
func check(c: Character, base_id: String, tier: int) -> Dictionary:
	var cfg: Dictionary = config()
	if _gd.artifact_base(base_id).is_empty():
		return {"ok": false, "reason": "unknown pháp bảo design '%s' (%s)" % [base_id, ", ".join(_gd.artifacts_file().bases.map(func(b): return b.id))]}
	if tier < 0 or tier >= cfg.difficulty.size():
		return {"ok": false, "reason": "tier must be 0..%d" % (cfg.difficulty.size() - 1)}
	if tier > c.realm_index:
		return {"ok": false, "reason": "a %s needs a %s refiner" % [_gd.artifact_tier(tier).name, _gd.realm(tier).name]}
	if c.skill_level(skill()) < int(cfg.min_level[tier]):
		return {"ok": false, "reason": "%s needs Luyện khí level %d (you have %d)" % [_gd.artifact_tier(tier).name, int(cfg.min_level[tier]), c.skill_level(skill())]}
	var fuel: int = fuel_cost(base_id, tier)
	if c.linh_thach < fuel:
		return {"ok": false, "reason": "needs %d linh thạch of fuel (you have %d)" % [fuel, c.linh_thach]}
	var mats: Dictionary = pick_materials(c, tier)
	if not mats.ok:
		return {"ok": false, "reason": "needs %s" % mats.missing}
	return {"ok": true, "reason": "", "fuel": fuel, "materials": mats.units}


## Refines one pháp bảo. Fuel and materials are spent either way.
## Returns {ok, success, message, item_id, chance, roll, levels}.
func refine(c: Character, sheet: StatSheet, rng: RandomNumberGenerator, base_id: String, tier: int) -> Dictionary:
	var cfg: Dictionary = config()
	var ck: Dictionary = check(c, base_id, tier)
	if not ck.ok:
		return {"ok": false, "message": "Cannot refine: %s." % ck.reason}
	c.linh_thach -= int(ck.fuel)
	var elements: Dictionary = {}
	var rarity_sum: float = 0.0
	var units: int = 0
	for u in ck.materials:
		var it: Dictionary = _db.get_record("items", u.id)
		var m: Dictionary = _gd.material(str(it.template))
		rarity_sum += float(m.rarity) * float(u.take)
		units += int(u.take)
		if str(m.element) != "":
			elements[m.element] = int(elements.get(m.element, 0)) + int(u.take)
		it["qty"] = int(it.get("qty", 1)) - int(u.take)
		if int(it.qty) <= 0:
			_db.remove("items", it.id)
	var chance: float = success_chance(c, sheet, tier).total
	var roll: float = rng.randf() * 100.0
	var out := {"ok": true, "success": roll < chance, "chance": chance, "roll": roll, "item_id": "", "levels": 0}
	var xp: float = float(cfg.xp[tier])
	if out.success:
		var avg_rarity: float = rarity_sum / float(maxi(units, 1))
		var cap: int = clampi(c.skill_level(skill()) / int(cfg.levels_per_grade) + int(avg_rarity) - 1, 0, _gd.artifacts_file().grades.size() - 1)
		var element: String = "none"
		var best: int = 0
		for e in elements.keys():
			if int(elements[e]) > best:
				best = int(elements[e])
				element = e
		var art: Dictionary = _items.artifact(rng, tier, _items.roll_grade(rng, cap), element, base_id)
		art["owner_id"] = c.id
		art["maker_id"] = c.id
		out.item_id = _db.add("items", art)
		out.message = "Success (%.0f%% vs roll %.0f): %s [%s]." % [chance, roll, _items.describe(art), out.item_id]
	else:
		xp *= float(cfg.fail_xp_fraction)
		out.message = "Failed (%.0f%% vs roll %.0f): the materials crack in the furnace." % [chance, roll]
	out.levels = c.add_skill_xp(skill(), xp, float(cfg.xp_per_level), int(cfg.max_level))
	if out.levels > 0:
		out.message += " Luyện khí rises to level %d." % c.skill_level(skill())
	out.message = "Fuel %d linh thạch. " % int(ck.fuel) + out.message
	return out
