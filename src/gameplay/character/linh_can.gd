class_name LinhCan
extends RefCounted
## A cultivator's spiritual root (linh căn): an integer purity per base element plus the
## owned variant roots (biến dị linh căn). The root only grows. Design: design/gdd/linh-can.md.
##
## Rules implemented here:
## - Birth roll with a fixed draw order (Formulas A). [param rng] is duck-typed: anything with
##   randf() and randfn(mean, sd) works, so tests can script the draws.
## - Three origins: innate (rolled at birth only), convergence and transmutation (derived:
##   one roll when first eligible, purity recomputed from the current element purities).
## - n_base names the tier and counts pairs; n_eff = min(n_cap, n_base + innate variants)
##   reads the curve only.
##
## Usage:
## [codeblock]
## var lc := LinhCan.roll(game_data, rng)
## print(lc.describe(game_data))   # "Dual root: Fire [Hỏa] 86, Water [Thủy] 60 + Wind [Phong] 62 (counts as 3)"
## [/codeblock]

## Variant ids moved to the Way (design/gdd/linh-can.md rule 16) are dropped by [method migrate_record].

## Base element id -> purity (10..100). Absent elements are not stored.
var elements: Dictionary = {}
## Variant id -> purity.
var variants: Dictionary = {}
## Every variant id that has rolled or been marked rolled.
var rolled: Array = []
## Variant ids a Self-made life left unpicked: they never roll, not even by Awakening.
var declined: Array = []


# --- Birth ------------------------------------------------------------------------

## Fated birth (Thiên Định): count, elements, purities, innate rolls, derived rolls, in the
## order of Formulas A. The seed fixes the root.
static func roll(gd: GameData, rng: Variant) -> LinhCan:
	var cfg: Dictionary = gd.attributes().linh_can
	var lc := LinhCan.new()
	var count: int = _roll_count(cfg, rng.randf())
	var pool: Array = gd.element_cycle().duplicate()
	for i in count:
		var j: int = i + int(floorf(rng.randf() * float(pool.size() - i)))
		var tmp: Variant = pool[i]
		pool[i] = pool[j]
		pool[j] = tmp
	var chosen: Array = pool.slice(0, count)
	for e in gd.element_cycle():
		if chosen.has(e):
			lc.elements[e] = purity_from_draw(cfg, rng.randfn(float(cfg.purity_mean), float(cfg.purity_sd)))
	for def in gd.variant_defs():
		if def.origin == "innate":
			lc._roll_innate(gd, def, cfg, rng)
	lc.roll_newly_eligible(gd, rng)
	return lc


## Self-made birth (Tự Định): the player's picks stand and nothing is rolled. Every variant
## that qualifies goes into the rolled set; the unpicked ones are declined. Call
## [method self_made_error] first: this assumes valid input.
static func self_made(gd: GameData, purities: Dictionary, picks: Array = []) -> LinhCan:
	var cfg: Dictionary = gd.attributes().linh_can
	var lc := LinhCan.new()
	for e in gd.element_cycle():
		if purities.has(e):
			lc.elements[e] = int(purities[e])
	for def in gd.variant_defs():
		var id: String = str(def.id)
		if not lc.qualifies_at_birth(gd, id):
			continue
		lc.rolled.append(id)
		if picks.has(id):
			lc.variants[id] = int(cfg.purity_mean) if def.origin == "innate" else lc.derived_purity(gd, id)
		else:
			lc.declined.append(id)
	return lc


## Why a Self-made choice is invalid, or "" if it is accepted (rule 2).
static func self_made_error(gd: GameData, purities: Dictionary, picks: Array = []) -> String:
	var cfg: Dictionary = gd.attributes().linh_can
	if purities.is_empty():
		return "Pick at least one element."
	var lc := LinhCan.new()
	for e in purities.keys():
		if gd.element(e).is_empty():
			return "Unknown element %s." % e
		var p: float = float(purities[e])
		if p < float(cfg.purity_min) or p > float(cfg.purity_max) or p != floorf(p):
			return "Purity must be a whole number from %d to %d." % [int(cfg.purity_min), int(cfg.purity_max)]
		lc.elements[e] = int(p)
	for id in picks:
		if gd.variant(str(id)).is_empty():
			return "Unknown variant %s." % id
		if not lc.qualifies_at_birth(gd, str(id)):
			return "This root does not qualify for %s." % gd.element_label(str(id))
	return ""


## Purity from one raw normal draw: rounded, then clamped (AC-LC-03).
static func purity_from_draw(cfg: Dictionary, raw: float) -> int:
	return clampi(int(roundf(raw)), int(cfg.purity_min), int(cfg.purity_max))


# --- Variants ---------------------------------------------------------------------

## True if [param variant_id] can be held by this root at birth.
func qualifies_at_birth(gd: GameData, variant_id: String) -> bool:
	var def: Dictionary = gd.variant(variant_id)
	if def.is_empty():
		return false
	if def.origin == "innate":
		if variant_id == "hu_khong":
			return base_count() <= int(gd.attributes().linh_can.void_max_elements)
		return true
	return requirement_met(gd, variant_id)


## True if a derived variant's required base elements are all owned (false for innate ones).
func requirement_met(gd: GameData, variant_id: String) -> bool:
	var def: Dictionary = gd.variant(variant_id)
	if def.is_empty() or def.origin == "innate":
		return false
	for e in def.requires:
		if not elements.has(e):
			return false
	return true


## Formulas D1: the chance a variant forms at the current purities.
func variant_chance(gd: GameData, variant_id: String) -> float:
	var cfg: Dictionary = gd.attributes().linh_can
	var def: Dictionary = gd.variant(variant_id)
	if def.is_empty():
		return 0.0
	if def.origin == "innate":
		return float(cfg.innate_chance.get(variant_id, 0.0))
	var factor: float = float(cfg.transmutation_factor)
	if def.origin == "convergence":
		factor = float(cfg.chaos_factor) if def.requires.size() > 2 else float(cfg.convergence_factor)
	var chance: float = factor
	for e in def.requires:
		chance *= float(elements.get(e, 0)) / 100.0
	return minf(chance, 1.0)


## Formulas D2: a derived variant's purity from the current element purities.
func derived_purity(gd: GameData, variant_id: String) -> int:
	var cfg: Dictionary = gd.attributes().linh_can
	var req: Array = gd.variant(variant_id).get("requires", [])
	if req.is_empty():
		return 0
	var product: float = 1.0
	for e in req:
		product *= float(elements.get(e, 0))
	var mean: float = pow(product, 1.0 / float(req.size()))
	return clampi(int(roundf(float(cfg.variant_purity_factor) * mean)), 1, 100)


## Rolls every derived variant that has just become eligible, in catalogue order, one
## uniform draw each. Returns the ids formed.
func roll_newly_eligible(gd: GameData, rng: Variant) -> Array:
	var formed: Array = []
	for def in gd.variant_defs():
		var id: String = str(def.id)
		if rolled.has(id) or declined.has(id) or not requirement_met(gd, id):
			continue
		rolled.append(id)
		if rng.randf() < variant_chance(gd, id):
			variants[id] = derived_purity(gd, id)
			formed.append(id)
	return formed


## Mutation Awakening: one more roll for every derived variant that is not owned, not
## declined and whose requirement is met, including earlier failures. Returns the ids formed.
func awakening_pass(gd: GameData, rng: Variant) -> Array:
	var formed: Array = []
	for def in gd.variant_defs():
		var id: String = str(def.id)
		if variants.has(id) or declined.has(id) or not requirement_met(gd, id):
			continue
		if not rolled.has(id):
			rolled.append(id)
		if rng.randf() < variant_chance(gd, id):
			variants[id] = derived_purity(gd, id)
			formed.append(id)
	return formed


## Recomputes every owned derived variant (after any element purity change). No roll.
func recompute_derived(gd: GameData) -> void:
	for id in variants.keys():
		if gd.variant(id).get("origin", "") != "innate":
			variants[id] = derived_purity(gd, id)


## Formulas E: the stat lines of one owned variant at its current purity, as
## {stat, value}. Floors to 0.1 in integer arithmetic on hundredths, so 0.30 x 51 is 15.3.
func variant_lines(gd: GameData, variant_id: String) -> Array:
	var out: Array = []
	var p: int = int(variants.get(variant_id, 0))
	for fx in gd.variant_effects(variant_id):
		var hundredths: int = int(roundf(float(fx.per_purity) * 100.0))
		out.append({"stat": str(fx.stat), "value": float((hundredths * p) / 10) / 10.0})
	return out


# --- Root changes -----------------------------------------------------------------

## Adds a new base element (Linh Căn Quả). Returns false if it is already owned.
## The caller rolls [method roll_newly_eligible] next.
func add_element(element_id: String, purity_value: int) -> bool:
	if elements.has(element_id):
		return false
	elements[element_id] = clampi(purity_value, 1, 100)
	return true


## Raises an owned base element (capped at 100) and recomputes derived variants. Returns the
## new purity, or -1 if the element is not owned. Never rolls.
func raise_purity(gd: GameData, element_id: String, amount: int) -> int:
	if not elements.has(element_id):
		return -1
	elements[element_id] = clampi(int(elements[element_id]) + amount, 1, 100)
	recompute_derived(gd)
	return int(elements[element_id])


## The owned base element with the lowest purity, ties in cycle order ("" if none).
func weakest_element(gd: GameData) -> String:
	var best: String = ""
	for e in gd.element_cycle():
		if elements.has(e) and (best == "" or int(elements[e]) < int(elements[best])):
			best = e
	return best


## True if every owned base element is at the purity ceiling.
func all_at_max() -> bool:
	for e in elements.keys():
		if int(elements[e]) < 100:
			return false
	return true


# --- Reads ------------------------------------------------------------------------

## Purity of a base element or variant; 0 if absent.
func purity(id: String) -> float:
	if elements.has(id):
		return float(elements[id])
	return float(variants.get(id, 0))


## True if the base element or variant is owned.
func has(id: String) -> bool:
	return elements.has(id) or variants.has(id)


## n_base: the number of base elements.
func base_count() -> int:
	return elements.size()


## n_innate: the number of innate variants owned.
func innate_count(gd: GameData) -> int:
	var n: int = 0
	for id in variants.keys():
		if gd.variant(id).get("origin", "") == "innate":
			n += 1
	return n


## n_eff: the curve row. Read by the curve only.
func n_eff(gd: GameData) -> int:
	return mini(int(gd.attributes().linh_can.n_cap), base_count() + innate_count(gd))


## The generating pairs held, as {from, to} element ids in cycle order.
func generating_pairs(gd: GameData) -> Array:
	var out: Array = []
	var cycle: Array = gd.element_cycle()
	for i in cycle.size():
		var a: String = cycle[i]
		var b: String = cycle[(i + 1) % cycle.size()]
		if elements.has(a) and elements.has(b):
			out.append({"from": a, "to": b})
	return out


## Tier name by n_base, such as "Triple root".
func tier_name(gd: GameData) -> String:
	return str(gd.elements_file().tiers.get(str(base_count()), "Mortal"))


## Highest-purity base element id, ties in insertion order ("" if none).
func strongest_element() -> String:
	var best: String = ""
	var best_p: int = -1
	for e in elements.keys():
		if int(elements[e]) > best_p:
			best_p = int(elements[e])
			best = e
	return best


## Average purity of the given ids (0 if any is missing).
func average_purity(ids: Array) -> float:
	if ids.is_empty():
		return 0.0
	var total: float = 0.0
	for id in ids:
		if not has(id):
			return 0.0
		total += purity(id)
	return total / float(ids.size())


## The root line: tier, elements in cycle order, then owned variants. "(counts as n)"
## appears only when an innate variant moves the curve row.
func describe(gd: GameData) -> String:
	var parts: PackedStringArray = []
	for e in gd.element_cycle():
		if elements.has(e):
			parts.append("%s %d" % [gd.element_label(e), int(elements[e])])
	var s: String = "%s: %s" % [tier_name(gd), ", ".join(parts)]
	var v: PackedStringArray = []
	for def in gd.variant_defs():
		if variants.has(def.id):
			v.append("%s %d" % [gd.element_label(str(def.id)), int(variants[def.id])])
	if not v.is_empty():
		s += " + " + ", ".join(v)
	if n_eff(gd) != base_count():
		s += " (counts as %d)" % n_eff(gd)
	return s


# --- Saving -----------------------------------------------------------------------

## Serializable form.
func to_dict() -> Dictionary:
	return {"elements": elements.duplicate(), "variants": variants.duplicate(), "rolled": rolled.duplicate(), "declined": declined.duplicate()}


## Restores from [method to_dict] output (JSON floats become ints).
static func from_dict(d: Dictionary) -> LinhCan:
	var lc := LinhCan.new()
	for k in d.get("elements", {}).keys():
		lc.elements[k] = int(d.elements[k])
	for k in d.get("variants", {}).keys():
		lc.variants[k] = int(d.variants[k])
	lc.rolled = Array(d.get("rolled", [])).map(func(x): return str(x))
	lc.declined = Array(d.get("declined", [])).map(func(x): return str(x))
	return lc


## Converts a saved root from before the redesign, or one with no rolled set, to the current
## form (Edge Cases, Saves): relocated mutations are dropped, derived purities are recomputed,
## kept innate purities are clamped, and everything already decided is marked rolled so no
## first roll is gained. A current record is returned unchanged.
static func migrate_record(d: Dictionary, gd: GameData) -> Dictionary:
	if d.has("variants") and d.has("rolled"):
		return d
	var cfg: Dictionary = gd.attributes().linh_can
	var lc := LinhCan.new()
	for k in d.get("elements", {}).keys():
		lc.elements[k] = int(d.elements[k])
	var old: Dictionary = d.get("variants", d.get("bien_di", {}))
	for id in old.keys():
		var def: Dictionary = gd.variant(str(id))
		if def.is_empty():
			continue
		if def.origin == "innate":
			lc.variants[id] = clampi(int(old[id]), int(cfg.purity_min), int(cfg.purity_max))
		else:
			lc.variants[id] = lc.derived_purity(gd, str(id))
	for id in d.get("rolled", []):
		if not gd.variant(str(id)).is_empty():
			lc.rolled.append(str(id))
	for def in gd.variant_defs():
		var id: String = str(def.id)
		var decided: bool = def.origin == "innate" or lc.requirement_met(gd, id)
		if decided and not lc.rolled.has(id):
			lc.rolled.append(id)
	return lc.to_dict()


func _roll_innate(gd: GameData, def: Dictionary, cfg: Dictionary, rng: Variant) -> void:
	var id: String = str(def.id)
	if not qualifies_at_birth(gd, id):
		return
	rolled.append(id)
	if rng.randf() < variant_chance(gd, id):
		variants[id] = purity_from_draw(cfg, rng.randfn(float(cfg.purity_mean), float(cfg.purity_sd)))


## Smallest n with u x sum(w) below the cumulative weight of n (half-open intervals).
static func _roll_count(cfg: Dictionary, u: float) -> int:
	var weights: Dictionary = cfg.count_weights
	var total: float = 0.0
	for k in weights.keys():
		total += float(weights[k])
	var target: float = u * total
	var cumulative: float = 0.0
	for n in range(1, weights.size() + 1):
		cumulative += float(weights[str(n)])
		if target < cumulative:
			return n
	return weights.size()
