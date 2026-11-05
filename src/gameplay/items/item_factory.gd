class_name ItemFactory
extends RefCounted
## Generates item records (Dictionaries ready for the WorldDB "items" table):
## linh thảo, đan dược, pháp khí/pháp bảo with affixes, công pháp manuals, materials.
## The engine owns every number: callers (including the LLM event layer) choose only
## category, element, grade within budget and an optional flavor name.
## Design: game-concept.md § Core Mechanics 3-4. Data: items_*.json.
##
## Usage:
## [codeblock]
## var f := ItemFactory.new(gd)
## var sword: Dictionary = f.artifact(rng, 1, 2, "kim", "phi_kiem")   # Trúc Cơ tier, Trung phẩm
## var cp: Dictionary = f.cong_phap(rng, 1, ["hoa"])                   # Huyền giai Hỏa manual
## db.add("items", sword)
## [/codeblock]

var _gd: GameData


func _init(gd: GameData) -> void:
	_gd = gd


# --- Herbs ------------------------------------------------------------------------

## A linh thảo of a template at an age (years).
func herb(template_id: String, age: float) -> Dictionary:
	var t: Dictionary = _gd.herb(template_id)
	return {
		"kind": "herb", "template": template_id, "name": t.get("name", template_id),
		"element": t.get("element", ""), "age": maxf(age, 0.0), "rarity": int(t.get("rarity", 1)),
		"owner_id": "", "plot": -1,
	}


## Random herb up to a rarity, optionally of an element, with age in [param age_range].
func random_herb(rng: RandomNumberGenerator, rarity_max: int, age_range: Array, element: String = "") -> Dictionary:
	var pool: Array = _gd.herbs().filter(func(h): return int(h.rarity) <= rarity_max and (element == "" or h.element == element))
	if pool.is_empty():
		pool = _gd.herbs().filter(func(h): return int(h.rarity) <= maxi(rarity_max, 1))
	var t: Dictionary = RngUtils.weighted_pick(rng, pool.map(func(h): return {"id": h.id, "weight": 1.0 / float(h.rarity)}))
	return herb(t.id, RngUtils.range_f(rng, age_range))


## Potency of a herb: 1 + per_doubling x log2(age / mature_years), clamped.
## A herb younger than its mature age has potency below 1.
func herb_potency(item: Dictionary) -> float:
	var cfg: Dictionary = _gd.file("items_herbs").potency
	var mature: float = float(_gd.herb(item.template).get("mature_years", 1.0))
	var age: float = maxf(float(item.age), 0.01)
	var p: float = 1.0 + float(cfg.per_doubling) * (log(age / mature) / log(2.0))
	return clampf(p, 0.1, float(cfg.max_potency))


## Market value of a herb (base value x potency, at least 1).
func herb_value(item: Dictionary) -> int:
	return maxi(1, int(roundf(float(_gd.herb(item.template).get("base_value", 1)) * herb_potency(item))))


# --- Pills ------------------------------------------------------------------------

## A stack of pills of a recipe at a quality rank (0..3).
func pill(recipe_id: String, quality: int, qty: int) -> Dictionary:
	var r: Dictionary = _gd.recipe(recipe_id)
	return {
		"kind": "pill", "template": recipe_id, "name": r.get("name", recipe_id),
		"quality": clampi(quality, 0, 3), "qty": maxi(qty, 1), "owner_id": "",
	}


## Value of one pill.
func pill_value(item: Dictionary) -> int:
	return int(float(_gd.recipe(item.template).get("price", 1)) * (1.0 + 0.5 * float(item.get("quality", 0))))


# --- Artifacts ----------------------------------------------------------------------

## A pháp khí/pháp bảo. [param realm_tier] = realm index the item is made for,
## [param grade] = 0..4 (Phàm..Cực phẩm). Empty [param element]/[param base_id] roll randomly
## ("none" forces no element). [param flavor_name] overrides the generated name.
func artifact(rng: RandomNumberGenerator, realm_tier: int, grade: int, element: String = "", base_id: String = "", flavor_name: String = "") -> Dictionary:
	var cfg: Dictionary = _gd.artifacts_file()
	var base: Dictionary = _gd.artifact_base(base_id)
	if base.is_empty():
		base = RngUtils.weighted_pick(rng, cfg.bases)
	var g: Dictionary = _gd.artifact_grade(grade)
	var tier: Dictionary = _gd.artifact_tier(realm_tier)
	var elem: String = element
	if elem == "":
		elem = RngUtils.pick(rng, _gd.element_cycle()) if rng.randf() < float(cfg.element_chance) else ""
	elif elem == "none":
		elem = ""
	var scale: float = float(g.power_mult) * float(tier.power_scale)
	var affixes: Array = []
	var pool: Array = cfg.affixes.duplicate()
	for i in int(g.affixes):
		if pool.is_empty():
			break
		var a: Dictionary = RngUtils.weighted_pick(rng, pool)
		pool.erase(a)
		if bool(a.get("element_bound", false)) and elem == "":
			continue
		var v: float = snappedf(rng.randf_range(float(a.min), float(a.max)), 0.1)
		affixes.append({"id": a.id, "word": a.word, "stat": a.stat, "value": v})
	var item := {
		"kind": "artifact", "base": base.id, "grade": int(g.rank), "tier": realm_tier,
		"element": elem, "attack": float(base.attack) * scale, "defense": float(base.defense) * scale,
		# Control cost grows with the realm thần thức multiplier so a realm-appropriate
		# cultivator can wield about two of its own tier.
		"than_thuc_cost": float(base.than_thuc_cost) * float(_gd.realm(realm_tier).than_thuc_mult),
		"affixes": affixes, "owner_id": "",
		"value": int(float(base.base_value) * float(g.value_mult) * float(tier.value_scale)),
	}
	item["name"] = flavor_name.substr(0, 40) if flavor_name != "" else _artifact_name(base, elem, affixes)
	return item


## Grade rank rolled by data weights, clamped to [param grade_max].
func roll_grade(rng: RandomNumberGenerator, grade_max: int) -> int:
	var grades: Array = _gd.artifacts_file().grades.filter(func(g): return int(g.rank) <= grade_max)
	return int(RngUtils.weighted_pick(rng, grades).rank)


func _artifact_name(base: Dictionary, elem: String, affixes: Array) -> String:
	var parts: PackedStringArray = []
	if elem != "":
		parts.append(str(_gd.element(elem).get("word", "")))
	for a in affixes:
		if str(a.word) != "":
			parts.append(str(a.word))
			break
	parts.append(str(base.name))
	return " ".join(parts)


# --- Công pháp ------------------------------------------------------------------

## A technique manual of tier rank 0..3 (cong-phap.md rule 17, Formulas E). Tiers above the
## commons are authored, so they come from the catalogue. [param names] fixes the elements
## (empty = roll). [param opts]: kind ("main" or "secret"), root (the LinhCan a player offer
## leans toward).
func cong_phap(rng: RandomNumberGenerator, tier_rank: int, names: Array = [], flavor_name: String = "", opts: Dictionary = {}) -> Dictionary:
	var cfg: Dictionary = _gd.cong_phap_file()
	var kind: String = str(opts.get("kind", "main"))
	if not Array(cfg.commons_tiers).map(func(t): return int(t)).has(tier_rank):
		var t: Dictionary = _catalogue_pick(rng, tier_rank, kind, names)
		if not t.is_empty():
			return manual_from_template(t)
		tier_rank = int(cfg.commons_tiers[-1])
	var tier: Dictionary = _gd.cong_phap_tier(tier_rank)
	var elems: Array = names.duplicate()
	if elems.is_empty():
		elems = _roll_names(rng, cfg, opts.get("root"))
	var prefix_key: String = elems[0] if elems.size() == 1 else "multi"
	var name: String = flavor_name.substr(0, 40)
	if name == "":
		name = "%s %s" % [RngUtils.pick(rng, cfg.element_prefixes[prefix_key]), RngUtils.pick(rng, cfg.suffixes)]
	var bonuses: Array = []
	var pool: Array = cfg.bonus_pool.filter(func(b): return not bool(b.get("authored_only", false)))
	var q_sum: float = 0.0
	var n: int = int(tier.bonus_count) + (int(cfg.secret_art_bonus_extra) if kind == "secret" else 0)
	for i in n:
		var b: Dictionary = RngUtils.pick(rng, pool)
		pool.erase(b)
		var v: float = snappedf(rng.randf_range(float(b.min), float(b.max)), 0.1)
		bonuses.append({"stat": b.stat, "value": v})
		q_sum += clampf((v - float(b.min)) / (float(b.max) - float(b.min)), 0.0, 1.0)
	var q: float = q_sum / float(n) if n > 0 else 0.5
	return {
		"kind": "cong_phap", "name": name, "tech_id": "gen_%d" % rng.randi(), "tier": int(tier.rank), "tier_name": tier.name,
		"tech_kind": kind, "names": elems, "layers": int(tier.layers), "bonuses": bonuses, "abilities": [],
		"seal_clusters": [], "origin": "generated", "value": _manual_price(cfg, tier, q), "owner_id": "",
	}


## A manual of an authored template.
func manual_from_template(t: Dictionary) -> Dictionary:
	var cfg: Dictionary = _gd.cong_phap_file()
	var tier: Dictionary = _gd.cong_phap_tier(int(t.tier))
	return {
		"kind": "cong_phap", "name": t.name, "tech_id": t.id, "tier": int(t.tier), "tier_name": tier.name,
		"tech_kind": t.tech_kind, "names": t.names.duplicate(), "layers": int(t.layers), "bonuses": t.bonuses.duplicate(true),
		"abilities": t.abilities.duplicate(true), "seal_clusters": t.seal_clusters.duplicate(), "origin": "authored",
		"value": _manual_price(cfg, tier, 0.5), "owner_id": "",
	}


func _catalogue_pick(rng: RandomNumberGenerator, tier_rank: int, kind: String, names: Array) -> Dictionary:
	var all: Array = _gd.cong_phap_file().get("templates", []).filter(func(t): return int(t.tier) == tier_rank and str(t.tech_kind) == kind)
	var fit: Array = all.filter(func(t): return not names.is_empty() and names.has(t.names[0] if not t.names.is_empty() else ""))
	var from: Array = fit if not fit.is_empty() else all
	return RngUtils.pick(rng, from) if not from.is_empty() else {}


## Formulas E: 1 or 2 elements, each leaning toward [param root] on a player offer.
func _roll_names(rng: RandomNumberGenerator, cfg: Dictionary, root: Variant) -> Array:
	var n: int = int(cfg.multi_element_count[0]) if rng.randf() < float(cfg.multi_element_chance) else 1
	var out: Array = []
	for i in n:
		var left: Array = _gd.element_cycle().filter(func(e): return not out.has(e))
		var from: Array = left
		if root != null and rng.randf() < float(cfg.root_bias):
			var own: Array = left.filter(func(e): return root.elements.has(e))
			if not own.is_empty():
				from = own
		out.append(RngUtils.pick(rng, from))
	return out


func _manual_price(cfg: Dictionary, tier: Dictionary, q: float) -> int:
	return int(roundf(float(tier.value) * (float(cfg.price_base) + float(cfg.price_spread) * q)))


# --- Materials --------------------------------------------------------------------

## A stack of a material.
func material(material_id: String, qty: int) -> Dictionary:
	var m: Dictionary = _gd.material(material_id)
	return {"kind": "material", "template": material_id, "name": m.get("name", material_id), "element": m.get("element", ""), "qty": maxi(qty, 1), "owner_id": "", "value": int(m.get("base_value", 1))}


## A treasure item. A Linh Căn Quả holds no element: the player picks one at use (linh-can.md
## rule 13).
func treasure(treasure_id: String) -> Dictionary:
	var t: Dictionary = _gd.treasure(treasure_id)
	return {"kind": "treasure", "template": treasure_id, "name": str(t.get("name", treasure_id)), "qty": 1, "owner_id": "", "value": int(t.get("base_value", 1))}


## A stack of talismans (crafting_talismans.json).
func talisman(talisman_id: String, qty: int) -> Dictionary:
	var t: Dictionary = Talismans.def_of(_gd, talisman_id)
	return {"kind": "talisman", "template": talisman_id, "name": str(t.get("name", talisman_id)), "qty": maxi(qty, 1), "owner_id": "", "value": int(t.get("base_value", 1))}


## Random material up to a rarity, optionally matching an element.
func random_material(rng: RandomNumberGenerator, rarity_max: int, element: String = "") -> Dictionary:
	var pool: Array = _gd.materials().filter(func(m): return int(m.rarity) <= rarity_max and (element == "" or m.element == element))
	if pool.is_empty():
		pool = _gd.materials().filter(func(m): return int(m.rarity) <= maxi(rarity_max, 1))
	var m: Dictionary = RngUtils.pick(rng, pool)
	return material(m.id, 1)


# --- Shared -------------------------------------------------------------------------

## Market value of any item record (per unit for stacks).
func value_of(item: Dictionary) -> int:
	match str(item.get("kind", "")):
		"herb":
			return herb_value(item)
		"pill":
			return pill_value(item)
		_:
			return int(item.get("value", 1))


## One-line description of any item.
func describe(item: Dictionary) -> String:
	match str(item.get("kind", "")):
		"herb":
			return "%s [%s] %.1f năm, potency %.2f" % [item.name, _gd.element_name(item.element), float(item.age), herb_potency(item)]
		"pill":
			return "%s x%d (phẩm %d)" % [item.name, int(item.qty), int(item.quality)]
		"artifact":
			var aff: PackedStringArray = []
			for a in item.affixes:
				aff.append(_gd.format_mod(str(a.stat), float(a.value)))
			return "%s [%s %s%s] ATK %.0f DEF %.0f thần thức %.0f%s" % [
				item.name, _gd.artifact_grade(int(item.grade)).name, _gd.artifact_tier(int(item.tier)).name,
				(", " + _gd.element_name(item.element)) if item.element != "" else "",
				float(item.attack), float(item.defense), float(item.than_thuc_cost),
				(" | " + ", ".join(aff)) if not aff.is_empty() else ""]
		"cong_phap":
			var els: PackedStringArray = []
			for e in item.get("names", []):
				els.append(_gd.element_name(e))
			var bon: PackedStringArray = []
			for b in item.bonuses:
				bon.append(_gd.format_mod(str(b.stat), float(b.value)))
			var tier: Dictionary = _gd.cong_phap_tier(int(item.tier))
			return "%s [%s %s, %s] %d layers, up to %s%s" % [item.name, item.tier_name, item.tech_kind, "/".join(els) if not els.is_empty() else "body", int(item.layers), _gd.realm(_gd.realm_index(str(tier.max_realm))).name, (" | " + ", ".join(bon)) if not bon.is_empty() else ""]
		"material":
			return "%s x%d" % [item.name, int(item.qty)]
		"treasure":
			return "%s — %s" % [item.name, str(_gd.treasure(str(item.template)).get("desc", ""))]
		"talisman":
			return "%s x%d — %s" % [item.name, int(item.qty), str(Talismans.def_of(_gd, str(item.template)).get("desc", ""))]
	return str(item.get("name", "?"))
