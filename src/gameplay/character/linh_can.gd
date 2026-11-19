class_name LinhCan
extends RefCounted
## A cultivator's spiritual root (linh căn): a purity per base element plus the owned variant roots
## (biến dị linh căn). The root only grows. Design: design/gdd/linh-can.md.
##
## Purity is a float with no upper cap (rules 8, 8a; ADR-0004 decision 2). Birth draws, the Tẩy Tủy Đan and the
## birth perk stop at 100; the Đạo Đồ's roads and the Linh Căn Quả on a five-element root go past it. Purity a road
## grants is kept in [member road], apart from the owned elements, and added on read ([method purity]), so a road
## never makes the root own an element (rule 8a).
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

## Base element id -> owned purity (birth, pills, fruits; 10+). Absent elements are not stored.
var elements: Dictionary = {}
## Variant id -> purity before road purity (a derived variant's is recomputed from its parents).
var variants: Dictionary = {}
## Element or variant id -> purity granted by the Đạo Đồ's roads (owned or not). Added by [method purity].
var road: Dictionary = {}
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
			lc.elements[e] = float(purities[e])
	for def in gd.variant_defs():
		var id: String = str(def.id)
		if not lc.qualifies_at_birth(gd, id):
			continue
		lc.rolled.append(id)
		if picks.has(id):
			lc.variants[id] = float(cfg.purity_mean) if def.origin == "innate" else lc.derived_purity(gd, id)
		else:
			lc.declined.append(id)
	lc.recompute_derived(gd)
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
		lc.elements[e] = p
	for id in picks:
		if gd.variant(str(id)).is_empty():
			return "Unknown variant %s." % id
		if not lc.qualifies_at_birth(gd, str(id)):
			return "This root does not qualify for %s." % gd.element_label(str(id))
	return ""


## Purity from one raw normal draw: rounded, then clamped (AC-LC-03).
static func purity_from_draw(cfg: Dictionary, raw: float) -> float:
	return clampf(roundf(raw), float(cfg.purity_min), float(cfg.purity_max))


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
		chance *= purity(str(e)) / 100.0
	return minf(chance, 1.0)


## Formulas D2: a derived variant's purity from the current element purities (roads included). A variant
## listed in `variant_parents` (Thunder, Ice, Chaos) takes its parents' purity as its own, the geometric mean with
## no discount (linh-can.md rule 10, 2026-11-19); Light and Darkness keep `variant_purity_factor`. At least 1, no
## upper clamp (rule 10).
func derived_purity(gd: GameData, variant_id: String) -> float:
	var cfg: Dictionary = gd.attributes().linh_can
	if cfg.get("variant_parents", {}).has(variant_id):
		return maxf(parent_purity(gd, variant_id), 1.0)
	var req: Array = gd.variant(variant_id).get("requires", [])
	if req.is_empty():
		return 0.0
	var product: float = 1.0
	for e in req:
		product *= purity(str(e))
	var mean: float = pow(product, 1.0 / float(req.size()))
	return maxf(roundf(float(cfg.variant_purity_factor) * mean), 1.0)


## A variant's parents' purity (`variant_parents`, roads included): the parent's own for one parent (Ice = Water),
## else the round of the geometric mean (rule 10); 0 when it has none or a parent has purity 0.
func parent_purity(gd: GameData, variant_id: String) -> float:
	var parents: Array = gd.attributes().linh_can.get("variant_parents", {}).get(variant_id, [])
	if parents.is_empty():
		return 0.0
	if parents.size() == 1:
		return purity(str(parents[0]))
	var product: float = 1.0
	for e in parents:
		product *= purity(str(e))
	return roundf(pow(product, 1.0 / float(parents.size())))


## Rolls every derived variant that has just become eligible, in catalogue order, one
## uniform draw each, then recomputes the owned variants. Returns the ids formed.
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
	recompute_derived(gd)
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


## Recomputes every owned derived variant (after any element purity change). An innate variant
## with parents (Wind: Water and Wood) rises to its parents' purity and never falls below its own
## (rule 10). No roll.
func recompute_derived(gd: GameData) -> void:
	for id in variants.keys():
		if gd.variant(id).get("origin", "") != "innate":
			variants[id] = derived_purity(gd, id)
		else:
			variants[id] = maxf(float(variants[id]), parent_purity(gd, id))


## Formulas E: the stat lines of one owned variant at its current purity, as
## {stat, value}, at the variant's full purity (roads included). Floors to 0.1 on hundredths, so 0.30 x 51 is 15.3.
func variant_lines(gd: GameData, variant_id: String) -> Array:
	var out: Array = []
	var p: float = purity(variant_id) if variants.has(variant_id) else 0.0
	for fx in gd.variant_effects(variant_id):
		var hundredths: int = int(roundf(float(fx.per_purity) * 100.0))
		out.append({"stat": str(fx.stat), "value": floorf(float(hundredths) * p / 10.0 + 1e-6) / 10.0})
	return out


# --- Root changes -----------------------------------------------------------------

## Adds a new base element (Linh Căn Quả) at [param purity_value], or at the purity roads already gave it if that is
## higher (rule 13: the max of the two, nothing lost). Returns false if it is already owned. The caller rolls
## [method roll_newly_eligible] next.
func add_element(element_id: String, purity_value: float) -> bool:
	if elements.has(element_id):
		return false
	var from_roads: float = float(road.get(element_id, 0.0))
	elements[element_id] = maxf(maxf(purity_value, 1.0) - from_roads, 0.0)
	return true


## Raises an owned base element by [param amount] so that its purity (roads included) goes no higher than
## [param cap] (100 for pills and the birth perk, rule 13; a negative cap is none: the five-element fruit, rule 8a),
## and recomputes derived variants. Returns the new purity, or -1 if the element is not owned. Never rolls or lowers.
func raise_purity(gd: GameData, element_id: String, amount: float, cap: float = 100.0) -> float:
	if not elements.has(element_id):
		return -1.0
	var gain: float = amount if cap < 0.0 else clampf(cap - purity(element_id), 0.0, amount)
	elements[element_id] = float(elements[element_id]) + gain
	recompute_derived(gd)
	return purity(element_id)


## Adds purity a Đạo Đồ road grants (rule 8a; Đạo Đồ rule 4) to an element or variant, owned or not, with no cap,
## and recomputes derived variants (a parent's roads raise its variant, rule 10).
func add_road_purity(gd: GameData, id: String, amount: float) -> void:
	road[id] = float(road.get(id, 0.0)) + amount
	recompute_derived(gd)


## The owned base element with the lowest purity, ties in cycle order ("" if none).
func weakest_element(gd: GameData) -> String:
	var best: String = ""
	for e in gd.element_cycle():
		if elements.has(e) and (best == "" or purity(e) < purity(best)):
			best = e
	return best


## True if every owned base element is at the purity ceiling.
func all_at_max() -> bool:
	for e in elements.keys():
		if purity(str(e)) < 100.0:
			return false
	return true


# --- Reads ------------------------------------------------------------------------

## Purity of a base element or variant: owned purity plus road purity; an unowned id has only its road purity
## (0 if none). Uncapped.
func purity(id: String) -> float:
	var r: float = float(road.get(id, 0.0))
	if elements.has(id):
		return float(elements[id]) + r
	return float(variants.get(id, 0.0)) + r


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
	var best_p: float = -1.0
	for e in elements.keys():
		if purity(str(e)) > best_p:
			best_p = purity(str(e))
			best = e
	return best


## Highest-purity owned base element, ties in generating-cycle order ("" if none; Đạo Đồ rule 3).
func strongest_in_cycle(gd: GameData) -> String:
	var best: String = ""
	for e in gd.element_cycle():
		if elements.has(e) and (best == "" or purity(e) > purity(best)):
			best = e
	return best


## A purity for display: a whole number without decimals, else one decimal (30.5).
static func fmt(p: float) -> String:
	return str(int(p)) if is_equal_approx(p, roundf(p)) else "%.1f" % p


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
			parts.append("%s %s" % [gd.element_label(e), fmt(purity(e))])
	var s: String = "%s: %s" % [tier_name(gd), ", ".join(parts)]
	var v: PackedStringArray = []
	for def in gd.variant_defs():
		if variants.has(def.id):
			v.append("%s %s" % [gd.element_label(str(def.id)), fmt(purity(str(def.id)))])
	if not v.is_empty():
		s += " + " + ", ".join(v)
	if n_eff(gd) != base_count():
		s += " (counts as %d)" % n_eff(gd)
	return s


# --- Saving -----------------------------------------------------------------------

## Serializable form.
func to_dict() -> Dictionary:
	return {"elements": elements.duplicate(), "variants": variants.duplicate(), "road": road.duplicate(),
		"rolled": rolled.duplicate(), "declined": declined.duplicate()}


## Restores from [method to_dict] output. Older saves held integer purities and no road purity; both read as floats.
static func from_dict(d: Dictionary) -> LinhCan:
	var lc := LinhCan.new()
	for k in d.get("elements", {}).keys():
		lc.elements[k] = float(d.elements[k])
	for k in d.get("variants", {}).keys():
		lc.variants[k] = float(d.variants[k])
	for k in d.get("road", {}).keys():
		lc.road[k] = float(d.road[k])
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
		lc.elements[k] = float(d.elements[k])
	var old: Dictionary = d.get("variants", d.get("bien_di", {}))
	for id in old.keys():
		var def: Dictionary = gd.variant(str(id))
		if def.is_empty():
			continue
		if def.origin == "innate":
			lc.variants[id] = clampf(float(old[id]), float(cfg.purity_min), float(cfg.purity_max))
		else:
			lc.variants[id] = lc.derived_purity(gd, str(id))
	lc.recompute_derived(gd)
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
