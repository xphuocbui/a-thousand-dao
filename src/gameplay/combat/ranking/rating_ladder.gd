class_name RatingLadder
extends RefCounted
## The calibrated rating ladders and anchors of Power Rankings (design/gdd/power-rankings.md Formulas A, C, E, G),
## read from assets/data/combat_rankings.json (written by tools/design/combat_sim/export_rankings_calibration.py).
##
## The rung rule (defined once, in the exporter; applied here the same way): rung k of realm r is the realm's typical
## reference fighter with g = 2^(k / (2 rung_div)): stage_mult, n_body and n_qi x g, block and body_block / g.
##
## Usage:
## [codeblock]
## var lad := RatingLadder.from_game_data(gd)
## var r: float = lad.rung_rating(1, 4)              # L_{1,4}
## var p: FighterProfile = lad.rung_profile(1, 4)    # the fighter at that rung
## var shown: int = lad.power_number(6500.0)          # Formulas E
## var prov: float = lad.provisional(1, 2, gd)        # Formulas G
## [/codeblock]

const DATA_FILE := "combat_rankings"
const REFERENCE_FILE := "combat_reference_fighters"

## The knobs and measured data as read (combat_rankings.json).
var data: Dictionary = {}
var k_max: int = 0
var rung_div: int = 1
var anchors: PackedFloat64Array = []
## Problems found while loading; empty when the ladder is usable.
var errors: PackedStringArray = []
var _ladders: Array = []          # PackedFloat64Array per realm, index k + k_max
var _typical: Array = []          # resolved typical fighter records per realm
var _power_base: PackedFloat64Array = []
var _k: CombatConstants
var _profiles: Dictionary = {}    # "r:k" -> FighterProfile (built on first use)


## Reads the ladder data, the typical fighters and the realms' power bases from [param gd].
static func from_game_data(gd: GameData) -> RatingLadder:
	var pb: Array = []
	for r in gd.realms():
		pb.append(float(r.power_base))
	return from_dict(gd.file(DATA_FILE), gd.file(REFERENCE_FILE).get("fighters", {}).get("typical", []), pb,
		CombatConstants.from_game_data(gd))


## For tests: a ladder from plain data (rung profiles need [param typical] and [param k]).
static func from_dict(d: Dictionary, typical: Array, power_base: Array, k: CombatConstants = null) -> RatingLadder:
	var lad := RatingLadder.new()
	lad.data = d
	lad.k_max = int(d.get("k_max", 0))
	lad.rung_div = int(d.get("rung_div", 1))
	lad.anchors = PackedFloat64Array(d.get("anchors", []))
	for row in d.get("ladders", []):
		lad._ladders.append(PackedFloat64Array(row))
	lad._typical = typical
	lad._power_base = PackedFloat64Array(power_base)
	lad._k = k
	if lad._ladders.is_empty() or lad.anchors.is_empty():
		lad.errors.append("combat_rankings.json has no ladders or anchors (run export_rankings_calibration.py)")
	return lad


## Realm [param r]'s ladder ratings, rung k at index k + k_max.
func ladder(r: int) -> PackedFloat64Array:
	return _ladders[r]


## L_{r,k}: the calibrated rating of rung [param k] of realm [param r].
func rung_rating(r: int, k: int) -> float:
	return _ladders[r][k + k_max]


## The rung nearest [param rating] on realm [param r]'s ladder (a warm search starts there; Formulas B).
func nearest_rung(r: int, rating: float) -> int:
	var lad: PackedFloat64Array = _ladders[r]
	var best := 0
	var best_d := INF
	for i in lad.size():
		var dd: float = absf(lad[i] - rating)
		if dd < best_d:
			best_d = dd
			best = i
	return best - k_max


## The fighter at rung [param k] of realm [param r] (the rung rule), loaded once and cached. Null with [member errors]
## when the record cannot load.
func rung_profile(r: int, k: int) -> FighterProfile:
	var key := "%d:%d" % [r, k]
	if _profiles.has(key):
		return _profiles[key]
	var g: float = pow(2.0, float(k) / (2.0 * float(rung_div)))
	var rec: Dictionary = (_typical[r] as Dictionary).duplicate(true)
	rec["stage_mult"] = float(rec.get("stage_mult", 1.0)) * g
	rec["n_body"] = float(rec.n_body) * g
	rec["n_qi"] = float(rec.n_qi) * g
	rec["block"] = float(rec.block) / g
	rec["body_block"] = float(rec.get("body_block", 0.0)) / g
	rec["name"] = "%s@%d" % [str(rec.get("name", "rung")), k]
	var loader := FighterProfileLoader.new(_k)
	var p: FighterProfile = loader.from_sim_build(rec, str(rec.name))
	errors.append_array(loader.errors)
	_profiles[key] = p
	return p


## Formulas G: the ladder read at strength [param f] (rung k = rung_div log2 f), linear between rungs and clamped to
## the ladder's ends.
func rating_at_strength(r: int, f: float) -> float:
	var k: float = clampf(float(rung_div) * log(f) / log(2.0), -float(k_max), float(k_max))
	var lo: int = floori(k)
	var hi: int = mini(lo + 1, k_max)
	var t: float = k - float(lo)
	return rung_rating(r, lo) * (1.0 - t) + rung_rating(r, hi) * t


## Formulas G: a provisional rating for realm [param r] at stage [param stage] (strength stage_mult squared).
func provisional(r: int, stage: int, gd: GameData) -> float:
	var sm: float = Ladder.stage_mult(gd, stage)
	return rating_at_strength(r, sm * sm)


## Formulas E: the shown power number for [param rating]: log-linear between the anchors, a realm's typical fighter
## showing exactly its power base; 3 significant figures, whole numbers below 100, at least 1.
func power_number(rating: float) -> int:
	var n: int = anchors.size()
	var rs := 0
	for r in range(mini(n - 2, 3), -1, -1):
		if anchors[r] <= rating:
			rs = r
			break
	var raw: float = _power_base[rs] * pow(10.0, (rating - anchors[rs]) / (anchors[rs + 1] - anchors[rs]))
	return maxi(1, roundi(round_3sf(raw)))


## [param x] rounded to 3 significant figures.
static func round_3sf(x: float) -> float:
	if x <= 0.0:
		return 0.0
	var e: int = floori(log(x) / log(10.0))
	var scale: float = pow(10.0, float(e - 2))
	return roundf(x / scale) * scale
