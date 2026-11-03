class_name CultivationRules
extends RefCounted
## Tu vi accumulation, stage advancement, bình cảnh breakthroughs and thọ nguyên.
## Design: game-concept.md § Cảnh Giới, § Linh Căn (slow-early / fast-crossover curve),
## § Character Stats (draft formulas). Constants: cultivation_realms.json,
## character_attributes.json (element_count_curve).
##
## Usage:
## [codeblock]
## var rate: Breakdown = CultivationRules.rate_per_season(c, gd, db, sheet, place_density)
## var res: Dictionary = CultivationRules.add_tu_vi(c, gd, rate.total)
## if CultivationRules.at_bottleneck(c, gd):
##     var chance: Breakdown = CultivationRules.breakthrough_chance(c, gd, sheet, pill_rank)
## [/codeblock]


## Linh căn curve multiplier for the character's element count at its current stage.
static func curve_factor(c: Character, gd: GameData) -> float:
	var n: int = mini(c.linh_can.counted_elements(gd), 5)
	var groups: Array = gd.realm(c.realm_index).stage_curve_groups
	var group: String = groups[clampi(c.stage, 0, groups.size() - 1)]
	return float(gd.attributes().element_count_curve.get(str(n), {}).get(group, 1.0))


## Cultivation per season (one turn of tu luyện). [param density] is the place's linh khí.
static func rate_per_season(c: Character, gd: GameData, db: WorldDB, sheet: StatSheet, density: float) -> Breakdown:
	var rules: Dictionary = gd.cultivation_rules()
	var realm: Dictionary = gd.realm(c.realm_index)
	var b := Breakdown.new("Tu vi / season")
	b.base("%s base rate" % realm.name, float(realm.base_rate))
	b.mul("Linh căn curve (%d elements)" % mini(c.linh_can.counted_elements(gd), 5), curve_factor(c, gd))
	var cp: Dictionary = db.get_record("items", c.cong_phap_id) if db != null else {}
	var cp_factor: Dictionary = cong_phap_factor(c, gd, cp)
	b.mul(cp_factor.label, cp_factor.mult)
	b.mul("Ngộ tính %d" % int(sheet.effective("ngo_tinh", c)), 1.0 + sheet.effective("ngo_tinh", c) / float(rules.ngo_tinh_divisor))
	b.mul("Linh khí density", maxf(density + sheet.total("density_bonus"), 0.1))
	if not sheet.has_flag("dan_doc_no_penalty") and c.dan_doc > 0.0:
		b.mul("Đan độc %d" % int(c.dan_doc), maxf(1.0 - c.dan_doc / float(rules.dan_doc_divisor), 0.0))
	var pct: float = sheet.total("cultivation_speed_pct") + sheet.total("cultivation_speed_per_element_pct") * float(c.linh_can.base_count())
	b.add_pct("cultivation_speed_pct", pct)
	b.clamp_to(0.0, INF)
	return b


## How the active công pháp scales cultivation: {mult, label}.
## Tier speed x average purity of its elements / 100; without a usable công pháp the
## character cultivates crudely at no_cong_phap_mult x strongest purity.
static func cong_phap_factor(c: Character, gd: GameData, cp: Dictionary) -> Dictionary:
	var rules: Dictionary = gd.cultivation_rules()
	if not cp.is_empty():
		var purity: float = c.linh_can.average_purity(cp.get("elements", []))
		if purity > 0.0:
			var mult: float = float(cp.speed_mult) * purity / 100.0
			var label: String = "Công pháp %s (%.1fx, purity %d)" % [cp.name, float(cp.speed_mult), int(purity)]
			if c.realm_index > gd.realm_index(str(cp.get("max_realm", "hoa_than"))):
				mult *= 0.25
				label += " [beyond its realm: x0.25]"
			return {"mult": mult, "label": label}
	var best: float = c.linh_can.purity(c.linh_can.strongest_element())
	return {"mult": float(rules.no_cong_phap_mult) * maxf(best, 1.0) / 100.0, "label": "No usable công pháp"}


## Tu vi required to complete the current stage.
static func stage_requirement(c: Character, gd: GameData) -> float:
	var req: Array = gd.realm(c.realm_index).tu_vi_required
	return float(req[clampi(c.stage, 0, req.size() - 1)])


## True at the last stage of a realm with full tu vi, when a breakthrough is needed.
static func at_bottleneck(c: Character, gd: GameData) -> bool:
	var last_stage: bool = c.stage >= gd.stage_count(c.realm_index) - 1
	var has_next: bool = c.realm_index < gd.realms().size() - 1
	return last_stage and has_next and c.tu_vi >= stage_requirement(c, gd)


## Adds tu vi, advancing stages inside the realm automatically. Excess at a bình cảnh is
## lost. Returns {gained, stages, tree_points, bottleneck}.
static func add_tu_vi(c: Character, gd: GameData, amount: float) -> Dictionary:
	var stages: int = 0
	var points: int = 0
	c.tu_vi += maxf(amount, 0.0)
	var last: int = gd.stage_count(c.realm_index) - 1
	while c.tu_vi >= stage_requirement(c, gd):
		if c.stage >= last:
			c.tu_vi = stage_requirement(c, gd)
			break
		c.tu_vi -= stage_requirement(c, gd)
		c.stage += 1
		stages += 1
		points += int(gd.realm(c.realm_index).tree_points_per_stage)
	c.tree_points += points
	return {"gained": amount, "stages": stages, "tree_points": points, "bottleneck": at_bottleneck(c, gd)}


## Thọ nguyên = realm lifespan + pill/treasure bonus + lifespan_years, x (1 + lifespan_pct).
static func lifespan(c: Character, gd: GameData, sheet: StatSheet) -> Breakdown:
	var b := Breakdown.new("Thọ nguyên")
	b.base("%s lifespan" % gd.realm(c.realm_index).name, float(gd.realm(c.realm_index).lifespan))
	if c.lifespan_bonus > 0.0:
		b.add("Pills and treasures", c.lifespan_bonus)
	if sheet.total("lifespan_years") != 0.0:
		b.add("lifespan_years", sheet.total("lifespan_years"))
	b.add_pct("lifespan_pct", sheet.total("lifespan_pct"))
	return b


## Chance (0..1) to break into the next realm. [param pill_rank] is the quality rank of
## the required pill, or -1 without one.
static func breakthrough_chance(c: Character, gd: GameData, sheet: StatSheet, pill_rank: int) -> Breakdown:
	var rules: Dictionary = gd.breakthrough_rules()
	var next: Dictionary = gd.realm(c.realm_index + 1)
	var req: Variant = next.get("entry_requirement")
	var b := Breakdown.new("Breakthrough chance")
	if req == null:
		b.base("No bình cảnh", 1.0)
		return b
	if pill_rank >= 0:
		b.base("With %s" % req.item_tag, float(req.pill_chance))
		b.add("Pill quality rank %d" % pill_rank, float(pill_rank) * float(rules.pill_quality_bonus_per_grade))
	else:
		b.base("Without %s" % req.item_tag, float(req.base_chance))
	b.add("Ngộ tính %d" % int(sheet.effective("ngo_tinh", c)), sheet.effective("ngo_tinh", c) * float(rules.ngo_tinh_bonus_per_point))
	b.add("Đạo tâm %d" % int(sheet.effective("dao_tam", c)), sheet.effective("dao_tam", c) * float(rules.dao_tam_bonus_per_point))
	var bonus: float = sheet.total("breakthrough_chance") / 100.0
	if bonus != 0.0:
		b.add("breakthrough_chance", bonus)
	b.clamp_to(0.01, 0.95)
	return b


## Chance (0..1) that a failed breakthrough turns into tẩu hỏa nhập ma backlash:
## max(0, Tâm ma - Đạo tâm / divisor) %.
static func backlash_chance(c: Character, gd: GameData, sheet: StatSheet) -> Breakdown:
	var rules: Dictionary = gd.breakthrough_rules()
	var b := Breakdown.new("Backlash chance (%)")
	b.base("Tâm ma", c.tam_ma)
	b.add("Đạo tâm / %s" % str(rules.tam_ma_backlash_divisor), -sheet.effective("dao_tam", c) / float(rules.tam_ma_backlash_divisor))
	b.clamp_to(0.0, 100.0)
	return b


## Rolls a breakthrough. On success the character enters stage 0 of the next realm.
## Returns {success, chance, roll, backlash, died, tu_vi_lost, tam_ma_gained, points}.
static func attempt_breakthrough(c: Character, gd: GameData, sheet: StatSheet, rng: RandomNumberGenerator, pill_rank: int) -> Dictionary:
	var rules: Dictionary = gd.breakthrough_rules()
	var chance: float = breakthrough_chance(c, gd, sheet, pill_rank).total
	var roll: float = rng.randf()
	var out := {"success": false, "chance": chance, "roll": roll, "backlash": false, "died": false, "tu_vi_lost": 0.0, "tam_ma_gained": 0.0, "points": 0}
	if roll < chance:
		c.realm_index += 1
		c.stage = 0
		c.tu_vi = 0.0
		c.vitality = 1.0
		var pts: int = int(gd.realm(c.realm_index).tree_points_per_stage)
		c.tree_points += pts
		out.success = true
		out.points = pts
		return out
	var safe: bool = sheet.has_flag("safe_failure")
	var lost: float = 0.0 if safe else c.tu_vi * float(rules.failure_tu_vi_loss_pct)
	c.tu_vi -= lost
	out.tu_vi_lost = lost
	out.tam_ma_gained = CharacterRules.add_tam_ma(c, gd, sheet, float(rules.failure_tam_ma_gain) * (0.5 if safe else 1.0))
	c.vitality = maxf(c.vitality - float(rules.failure_khi_huyet_loss_pct), 0.05)
	var backlash: float = backlash_chance(c, gd, sheet).total / 100.0
	if rng.randf() < backlash:
		out.backlash = true
		if c.tam_ma >= float(rules.backlash_death_tam_ma_threshold):
			out.died = true
			c.alive = false
			c.death_cause = "Tẩu hỏa nhập ma khi đột phá"
		else:
			c.vitality = 0.05
	return out
