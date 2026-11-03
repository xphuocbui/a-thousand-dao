class_name LinhCan
extends RefCounted
## A cultivator's linh căn (spiritual root): a purity 0-100 per base element plus any
## biến dị (mutated roots) with derived purity. Design: game-concept.md § Linh Căn.
##
## Rules implemented here:
## - Element count tier: more elements is better late, slower early (curve in data).
## - Biến dị form by rule: each owned parent pair may mutate with chance
##   (purity_a * purity_b / 10000) * factor; higher orders use a smaller factor.
## - Biến dị purity = geometric mean of parents * bien_di_purity_factor.
##
## Usage:
## [codeblock]
## var lc := LinhCan.roll(game_data, rng)
## print(lc.describe(game_data))   # "Song linh căn: Hỏa 78, Mộc 52 | Quang 51"
## [/codeblock]

## Base element id -> purity (1..100). Absent elements are not stored.
var elements: Dictionary = {}
## Biến dị id -> purity.
var bien_di: Dictionary = {}


## Rolls a random linh căn: element count by weight, purity per element, then biến dị.
static func roll(gd: GameData, rng: RandomNumberGenerator) -> LinhCan:
	var cfg: Dictionary = gd.attributes().linh_can
	var weights: Dictionary = cfg.count_weights
	var counts: Array = []
	var w: Array = []
	for k in weights.keys():
		counts.append(int(k))
		w.append(float(weights[k]))
	var count: int = counts[RngUtils.weighted_index(rng, w)]
	var chosen: Array = RngUtils.shuffled(rng, gd.element_cycle()).slice(0, count)
	var lc := LinhCan.new()
	for e in chosen:
		lc.elements[e] = int(RngUtils.normal_clamped(rng, cfg.purity_mean, cfg.purity_sd, cfg.purity_min, cfg.purity_max))
	lc.derive_bien_di(gd, rng)
	return lc


## Builds a linh căn from explicit purities (Tự Định mode). Biến dị still roll unless
## [param forced_bien_di] lists the ones to grant (then no roll happens).
static func from_purities(gd: GameData, purities: Dictionary, rng: RandomNumberGenerator, forced_bien_di: Array = []) -> LinhCan:
	var lc := LinhCan.new()
	for e in purities.keys():
		var p: int = clampi(int(purities[e]), 0, 100)
		if p > 0 and gd.element(e).size() > 0:
			lc.elements[e] = p
	if forced_bien_di.is_empty():
		lc.derive_bien_di(gd, rng)
	else:
		for b in forced_bien_di:
			lc.grant_bien_di(gd, b)
	return lc


## Rolls biến dị for every definition whose parents are all owned, lowest order first.
func derive_bien_di(gd: GameData, rng: RandomNumberGenerator) -> void:
	var cfg: Dictionary = gd.attributes().linh_can
	var defs: Array = gd.bien_di_defs().duplicate()
	defs.sort_custom(func(a, b): return int(a.order) < int(b.order))
	for d in defs:
		if bien_di.has(d.id) or not _has_parents(d.parents):
			continue
		var factor: float = float(cfg.bien_di_chance_factor)
		if int(d.order) > 1:
			factor = float(cfg.bien_di_higher_order_factor) / float(int(d.order) - 1)
		var chance: float = 1.0
		for parent in d.parents:
			chance *= purity(parent) / 100.0
		if RngUtils.chance(rng, chance * factor):
			bien_di[d.id] = _derived_purity(gd, d.parents)


## Grants a biến dị if its parents are owned (used by treasures, bí thuật and Tự Định).
## Returns false if a parent is missing.
func grant_bien_di(gd: GameData, bien_di_id: String) -> bool:
	var d: Dictionary = gd.bien_di(bien_di_id)
	if d.is_empty() or not _has_parents(d.parents):
		return false
	bien_di[bien_di_id] = _derived_purity(gd, d.parents)
	return true


## Adds a new base element (rare treasure). Returns false if already owned.
func add_element(element_id: String, purity_value: int) -> bool:
	if elements.has(element_id):
		return false
	elements[element_id] = clampi(purity_value, 1, 100)
	return true


## Raises an owned base element's purity (capped at 100). Returns the new purity, or -1
## if the element is not owned.
func raise_purity(element_id: String, amount: int) -> int:
	if not elements.has(element_id):
		return -1
	elements[element_id] = clampi(int(elements[element_id]) + amount, 1, 100)
	return int(elements[element_id])


## The owned base element with the lowest purity ("" if none).
func weakest_element() -> String:
	var best: String = ""
	for e in elements.keys():
		if best == "" or int(elements[e]) < int(elements[best]):
			best = e
	return best


## Purity of a base element or biến dị; 0 if absent.
func purity(id: String) -> float:
	if elements.has(id):
		return float(elements[id])
	return float(bien_di.get(id, 0))


## True if the base element or biến dị is owned.
func has(id: String) -> bool:
	return elements.has(id) or bien_di.has(id)


## Number of base elements.
func base_count() -> int:
	return elements.size()


## Element count used by the tier curve (base + biến dị when configured), capped.
func counted_elements(gd: GameData) -> int:
	var cfg: Dictionary = gd.attributes().linh_can
	var n: int = elements.size()
	if bool(cfg.get("bien_di_counts_as_element", true)):
		n += bien_di.size()
	return clampi(n, 1, int(cfg.get("max_counted_elements", 8)))


## Tier name such as "Tam linh căn".
func tier_name() -> String:
	match elements.size():
		1: return "Đơn linh căn"
		2: return "Song linh căn"
		3: return "Tam linh căn"
		4: return "Tứ linh căn"
		5: return "Ngũ Hành linh căn"
	return "Phàm thể"


## Highest-purity base element id ("" if none).
func strongest_element() -> String:
	var best: String = ""
	var best_p: int = -1
	for e in elements.keys():
		if int(elements[e]) > best_p:
			best_p = int(elements[e])
			best = e
	return best


## Average purity of the given element ids (0 if any is missing).
func average_purity(ids: Array) -> float:
	if ids.is_empty():
		return 0.0
	var total: float = 0.0
	for id in ids:
		if not has(id):
			return 0.0
		total += purity(id)
	return total / float(ids.size())


## One-line description.
func describe(gd: GameData) -> String:
	var parts: PackedStringArray = []
	for e in gd.element_cycle():
		if elements.has(e):
			parts.append("%s %d" % [gd.element_name(e), int(elements[e])])
	var s: String = "%s: %s" % [tier_name(), ", ".join(parts)]
	if not bien_di.is_empty():
		var b: PackedStringArray = []
		for id in bien_di.keys():
			b.append("%s %d" % [gd.element_name(id), int(bien_di[id])])
		s += " | biến dị: " + ", ".join(b)
	return s


## Serializable form.
func to_dict() -> Dictionary:
	return {"elements": elements.duplicate(), "bien_di": bien_di.duplicate()}


## Restores from [method to_dict] output (JSON floats become ints).
static func from_dict(d: Dictionary) -> LinhCan:
	var lc := LinhCan.new()
	for k in d.get("elements", {}).keys():
		lc.elements[k] = int(d.elements[k])
	for k in d.get("bien_di", {}).keys():
		lc.bien_di[k] = int(d.bien_di[k])
	return lc


func _has_parents(parents: Array) -> bool:
	for p in parents:
		if not has(p):
			return false
	return true


func _derived_purity(gd: GameData, parents: Array) -> int:
	var product: float = 1.0
	for p in parents:
		product *= maxf(purity(p), 1.0)
	var mean: float = pow(product, 1.0 / float(parents.size()))
	return clampi(int(roundf(mean * float(gd.attributes().linh_can.bien_di_purity_factor))), 1, 100)
