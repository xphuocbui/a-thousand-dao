class_name Ladder
extends RefCounted
## The cultivation ladder: levels 1-110, realm bands, stages, level costs, the stage multiplier
## and Kinh Mạch points. Pure functions of data. Design: design/gdd/canh-gioi.md rules 1-6,
## Formulas A-B; points: design/gdd/kinh-mach-do.md Formulas A.
##
## Usage:
## [codeblock]
## var realm: int = Ladder.realm_of_level(gd, 26)        # 1 (Trúc Cơ)
## var stage: int = Ladder.stage_of_level(gd, 26)        # 1 (middle)
## var cost: float = Ladder.level_cost(gd, 25)           # 183.1
## var total: int = Ladder.points_total(gd, 26)          # 100
## [/codeblock]

## Stage ids: 0 early (sơ kỳ), 1 middle (trung kỳ), 2 late (hậu kỳ), 3 great perfection.
const GREAT_PERFECTION := 3


## First and last level of a realm, as [lo, hi].
static func band(gd: GameData, realm_idx: int) -> Array:
	var l: Array = gd.realm(realm_idx).levels
	return [int(l[0]), int(l[1])]


## Index of the realm a level belongs to; the level is clamped to 1..level_cap.
static func realm_of_level(gd: GameData, level: int) -> int:
	var l: int = clamp_level(gd, level)
	for i in gd.realms().size():
		if l <= int(gd.realm(i).levels[1]):
			return i
	return gd.realms().size() - 1


## A level clamped to 1..level_cap.
static func clamp_level(gd: GameData, level: int) -> int:
	return clampi(level, 1, int(gd.ladder().level_cap))


## First levels of the realm's middle stage, late stage and great perfection, as [t, h, hi].
static func stage_starts(gd: GameData, realm_idx: int) -> Array:
	var b: Array = band(gd, realm_idx)
	var n: int = b[1] - b[0] + 1
	return [b[0] + n / 3, b[0] + (2 * n) / 3, b[1]]


## Stage of a level (0..3), which is also the number of small breakthroughs reached.
static func stage_of_level(gd: GameData, level: int) -> int:
	var starts: Array = stage_starts(gd, realm_of_level(gd, level))
	var s: int = 0
	for start in starts:
		if level >= int(start):
			s += 1
	return s


## First level of a stage in a realm.
static func stage_first_level(gd: GameData, realm_idx: int, stage: int) -> int:
	if stage <= 0:
		return band(gd, realm_idx)[0]
	return int(stage_starts(gd, realm_idx)[mini(stage, 3) - 1])


## The stage multiplier for a stage: 1 + stage_power_step x stage.
static func stage_mult(gd: GameData, stage: int) -> float:
	return 1.0 + float(gd.ladder().stage_power_step) * float(clampi(stage, 0, GREAT_PERFECTION))


## Qi Refining layer of a level (a level is its layer, rule 2), or 0 outside Qi Refining.
static func layer_of_level(gd: GameData, level: int) -> int:
	return level if realm_of_level(gd, level) == 0 else 0


## Formulas A: cultivation base needed to go from [param level] to level + 1.
static func level_cost(gd: GameData, level: int) -> float:
	var realm_idx: int = realm_of_level(gd, level)
	var r: Dictionary = gd.realm(realm_idx)
	var b: Array = band(gd, realm_idx)
	var m: int = b[1] - b[0]
	var ratio: float = pow(float(r.climb_growth), 1.0 / float(m - 1))
	var c0: float = float(r.climb_total) * (ratio - 1.0) / (pow(ratio, float(m)) - 1.0)
	return c0 * pow(ratio, float(level - b[0]))


## The bottleneck bar of a realm, or 0 for a realm with no next realm.
static func bar_cost(gd: GameData, realm_idx: int) -> float:
	var bar: Variant = gd.realm(realm_idx).get("bottleneck_bar")
	return 0.0 if bar == null else float(bar)


## Total cost of a stage: the sum of its levels' costs, or the bar at great perfection.
static func stage_total_cost(gd: GameData, realm_idx: int, stage: int) -> float:
	if stage >= GREAT_PERFECTION:
		return bar_cost(gd, realm_idx)
	var from_level: int = stage_first_level(gd, realm_idx, stage)
	var to_level: int = stage_first_level(gd, realm_idx, stage + 1)
	var total: float = 0.0
	for l in range(from_level, to_level):
		total += level_cost(gd, l)
	return total


## Kinh Mạch Formulas A: points earned by [param level], before event grants. Whole numbers
## from data: each realm's great bonus on entry, and its three small bonuses.
static func points_total(gd: GameData, level: int) -> int:
	var cfg: Dictionary = gd.ladder()
	var great: Array = cfg.great_breakthrough_bonus
	var small: Array = cfg.small_breakthrough_bonus
	var total: int = int(cfg.pts_birth) + level - 1
	for i in gd.realms().size():
		if i > 0 and level >= band(gd, i)[0]:
			total += int(great[i - 1])
		var starts: Array = stage_starts(gd, i)
		for s in starts.size():
			if level >= int(starts[s]):
				total += int(small[i][s])
	return total


## Migrates a saved person from the old stage ladder (canh-gioi.md Edge Cases, Saves): sets
## level and level_peak, and the stage on the new four-stage scale. Returns the record. The
## old cultivation base fraction picks the level inside the old stage.
static func migrate_record(rec: Dictionary, gd: GameData) -> Dictionary:
	if rec.has("level"):
		return rec
	var realm_idx: int = int(rec.get("realm_index", 0))
	var old_stage: int = int(rec.get("stage", 0))
	var legacy: Array = gd.ladder().legacy_tu_vi_required[realm_idx]
	var req: float = float(legacy[clampi(old_stage, 0, legacy.size() - 1)])
	var frac: float = clampf(float(rec.get("tu_vi", 0.0)) / maxf(req, 1.0), 0.0, 1.0)
	var b: Array = band(gd, realm_idx)
	var level: int
	if realm_idx == 0:
		level = 1 + int(floorf((float(old_stage) + frac) * float(b[1] - 1) / float(legacy.size())))
	else:
		var from_level: int = stage_first_level(gd, realm_idx, old_stage)
		var to_level: int = stage_first_level(gd, realm_idx, old_stage + 1) if old_stage < GREAT_PERFECTION else b[1]
		level = from_level + int(floorf(frac * float(to_level - from_level)))
	var last_stage: bool = old_stage >= legacy.size() - 1
	var full: bool = last_stage and frac >= 1.0
	level = clampi(level, b[0], b[1])
	if full:
		level = b[1]
	rec["level"] = level
	rec["level_peak"] = level
	rec["stage"] = stage_of_level(gd, level)
	rec["tu_vi"] = bar_cost(gd, realm_idx) if full else 0.0
	return rec
