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
	return b
