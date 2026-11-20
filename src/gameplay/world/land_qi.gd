class_name LandQi
extends RefCounted

## Land qi on the authored continent (design/gdd/travel-map.md rules 3-5, Formulas A and C). The qi itself is built
## once, offline, by tools/design/map/land_qi.py and stored with the map: each place carries "qi" (its tile part's
## five base shares summing to 100 and its variants outside the 100) beside its density, and world_continent.json
## holds the world means mu_e. This class reads them; it never recomputes Formula C.
##
## Formula A, the land layer of the element match: M4 = max(M4_min, 1 + k * sum_e q_e * (s_e / 100 - mu_e)),
## q_e = u_e * p_e / 100, over the 5 base elements and the 8 variants; u_e is 1 for an owned element and
## match_unowned_rate (0.5) when the purity comes only from rare sources (road purity on an unowned element). No ceiling.
##
## Usage:
## [codeblock]
## var m: Breakdown = LandQi.land_match(c, gd, place.get("qi", {}))
## print(m.total)   # 1.0 on a place without qi (the old generated world)
## [/codeblock]

const DATA_FILE := "world_map"
const CONTINENT_FILE := "world_continent"


## Formula A's land match of [param c] on ground with [param qi] ({shares, variants}); 1.0 when qi is empty.
static func land_match(c: Character, gd: GameData, qi: Dictionary) -> Breakdown:
	var b := Breakdown.new("Land match")
	if qi.is_empty() or not qi.has("shares"):
		b.base("No land qi here", 1.0)
		return b
	var cfg: Dictionary = gd.file(DATA_FILE).get("match", {})
	var mu: Dictionary = gd.file(CONTINENT_FILE).get("mu", {})
	var k: float = float(cfg.get("match_gain", 1.0))
	var floor_v: float = float(cfg.get("match_land_min", 0.8))
	var unowned: float = float(cfg.get("match_unowned_rate", 0.5))
	var sum: float = 0.0
	var shares: Dictionary = qi.get("shares", {})
	var variants: Dictionary = qi.get("variants", {})
	for e in mu:
		var p: float = c.linh_can.purity(str(e))
		if p <= 0.0:
			continue
		var owned: bool = c.linh_can.elements.has(str(e)) or c.linh_can.variants.has(str(e))
		var q: float = (1.0 if owned else unowned) * p / 100.0
		var s: float = float(shares.get(e, variants.get(e, 0.0)))
		sum += q * (s / 100.0 - float(mu[e]))
	b.base("Land", 1.0)
	b.add("Elements of the ground (Formula A)", k * sum)
	b.clamp_to(floor_v, INF)
	# Formula B, layer 3: an active blessed land or secret pushes shares (not renormalised), its gain capped at m3
	var l3: float = 0.0
	var cs3: float = float(cfg.get("share_cap_l3", 80))
	var names: PackedStringArray = []
	for item in active_layer3(qi):
		for e in item.get("push", {}):
			var p: float = c.linh_can.purity(str(e))
			if p <= 0.0:
				continue
			var owned: bool = c.linh_can.elements.has(str(e)) or c.linh_can.variants.has(str(e))
			l3 += k * (1.0 if owned else unowned) * p / 100.0 * minf(cs3, float(item.push[e])) / 100.0
		names.append(str(item.name))
	if l3 > 0.0:
		b.add("Layer 3: %s (Formula B)" % ", ".join(names), minf(float(cfg.get("match_cap_l3", 0.3)), l3))
	b.clamp_to(float(cfg.get("match_stack_min", 0.8)), INF)
	return b


## The active layer-3 items of a place's qi (a famous blessed land, or a hidden one once found).
static func active_layer3(qi: Dictionary) -> Array:
	return Array(qi.get("layer3", [])).filter(func(x): return bool(x.get("active", false)))


## Formula B's layer-3 density add for a place's qi: min(c3, sum of the active items' dD).
static func layer3_density(gd: GameData, qi: Dictionary) -> float:
	var add: float = 0.0
	for item in active_layer3(qi):
		add += float(item.get("dD", 0.0))
	return minf(float(gd.file(DATA_FILE).get("match", {}).get("density_cap_l3", 1.0)), add)
