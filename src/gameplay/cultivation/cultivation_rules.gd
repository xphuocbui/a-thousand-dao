class_name CultivationRules
extends RefCounted
## Cultivation base (tu vi), climbing the level ladder, great breakthroughs and lifespan.
## Design: design/gdd/canh-gioi.md. Ladder arithmetic: [Ladder].
## Constants: cultivation_realms.json, character_attributes.json (element_count_curve).
##
## Usage:
## [codeblock]
## var rate: Breakdown = CultivationRules.rate_per_season(c, gd, db, sheet, place_density)
## var res: Dictionary = CultivationRules.add_tu_vi(c, gd, rate.total)
## if CultivationRules.at_bottleneck(c, gd):
##     var chance: Breakdown = CultivationRules.breakthrough_chance(c, gd, sheet, pill_rank)
## [/codeblock]


## Curve factor: element_count_curve[n_eff][stage group].
static func curve_factor(c: Character, gd: GameData) -> float:
	var groups: Array = gd.realm(c.realm_index).stage_curve_groups
	var group: String = groups[clampi(c.stage, 0, groups.size() - 1)]
	return float(gd.attributes().element_count_curve.get(str(c.linh_can.n_eff(gd)), {}).get(group, 1.0))


## Formulas I: cultivation per season, computed once at the start of the season.
## [param density] is the place's spiritual qi.
static func rate_per_season(c: Character, gd: GameData, db: WorldDB, sheet: StatSheet, density: float) -> Breakdown:
	var rules: Dictionary = gd.cultivation_rules()
	var realm: Dictionary = gd.realm(c.realm_index)
	var b := Breakdown.new("Tu vi / season")
	b.base("%s base rate" % realm.name, float(realm.base_rate))
	b.mul("Root curve (row %d)" % c.linh_can.n_eff(gd), curve_factor(c, gd))
	var cp_factor: Dictionary = CongPhap.speed_factor(c, gd)
	b.mul(cp_factor.label, cp_factor.mult)
	b.mul("Ngộ tính %d" % int(sheet.effective("ngo_tinh", c)), 1.0 + sheet.effective("ngo_tinh", c) / float(rules.ngo_tinh_divisor))
	b.mul("Linh khí density", maxf(density + sheet.total("density_bonus"), 0.1))
	if not sheet.has_flag("dan_doc_no_penalty") and c.dan_doc > 0.0:
		b.mul("Đan độc %d" % int(c.dan_doc), maxf(1.0 - c.dan_doc / float(rules.dan_doc_divisor), 0.0))
	var pct: float = sheet.total("cultivation_speed_pct") + sheet.total("cultivation_speed_per_element_pct") * float(c.linh_can.base_count())
	b.add_pct("cultivation_speed_pct", pct)
	b.clamp_to(0.0, INF)
	return b


## Cost of the next level, or the bottleneck bar at great perfection. 0 when Capped.
static func level_requirement(c: Character, gd: GameData) -> float:
	var hi: int = Ladder.band(gd, c.realm_index)[1]
	if c.level >= hi:
		return Ladder.bar_cost(gd, c.realm_index)
	return Ladder.level_cost(gd, c.level)


## Total cost of the character's current stage (capability #9, event budgets).
static func stage_cost(c: Character, gd: GameData) -> float:
	return Ladder.stage_total_cost(gd, c.realm_index, c.stage)


## True at the top of the ladder: level_cap reached, no next realm, the bar stops.
static func is_capped(c: Character, gd: GameData) -> bool:
	return c.level >= int(gd.ladder().level_cap)


## True at great perfection of a realm with a next realm (the bar may still be filling).
static func at_great_perfection(c: Character, gd: GameData) -> bool:
	return c.level >= Ladder.band(gd, c.realm_index)[1] and c.realm_index < gd.realms().size() - 1


## True with the bottleneck bar full, when a great breakthrough may be attempted.
static func at_bottleneck(c: Character, gd: GameData) -> bool:
	return at_great_perfection(c, gd) and c.tu_vi >= Ladder.bar_cost(gd, c.realm_index) - 1e-6


## Adds cultivation base, climbing levels; surplus carries over, and anything past a full bar
## is lost. Returns {gained, levels, stages, tree_points, bottleneck, wasted, levels_gained,
## stages_reached}: levels_gained lists levels above the peak (level_gained events),
## stages_reached the stages entered (stage_reached events).
static func add_tu_vi(c: Character, gd: GameData, amount: float) -> Dictionary:
	var out := {"gained": amount, "levels": 0, "stages": 0, "tree_points": 0, "bottleneck": false, "wasted": 0.0, "levels_gained": [], "stages_reached": []}
	if is_capped(c, gd):
		out.wasted = maxf(amount, 0.0)
		return out
	c.tu_vi += maxf(amount, 0.0)
	var hi: int = Ladder.band(gd, c.realm_index)[1]
	while true:
		if c.level >= hi:
			if at_great_perfection(c, gd):
				var bar: float = Ladder.bar_cost(gd, c.realm_index)
				if c.tu_vi > bar:
					out.wasted = c.tu_vi - bar
					c.tu_vi = bar
			else:
				out.wasted = c.tu_vi
				c.tu_vi = 0.0
			break
		var cost: float = Ladder.level_cost(gd, c.level)
		if c.tu_vi < cost:
			break
		c.tu_vi -= cost
		_climb(c, gd, c.level + 1, out)
	out.bottleneck = at_bottleneck(c, gd)
	return out


## Moves to [param level], paying points for a new peak and noting stages entered.
static func _climb(c: Character, gd: GameData, level: int, out: Dictionary) -> void:
	var before: int = c.stage
	c.level = level
	c.stage = Ladder.stage_of_level(gd, level)
	out.levels += 1
	if c.stage != before:
		out.stages += 1
		out.stages_reached.append(c.stage)
	if level > c.level_peak:
		var points: int = Ladder.points_total(gd, level) - Ladder.points_total(gd, c.level_peak)
		c.level_peak = level
		c.tree_points += points
		out.tree_points += points
		out.levels_gained.append(level)


## The lifespan cap (Realms rule 14, Character Stats Formulas I). Pill years and positive
## lifespan_years meet the ceiling; penalties apply after it.
static func lifespan(c: Character, gd: GameData, sheet: StatSheet) -> Breakdown:
	var b := Breakdown.new("Thọ nguyên")
	var base_life: float = float(gd.realm(c.realm_index).lifespan)
	b.base("%s lifespan" % gd.realm(c.realm_index).name, base_life)
	var positive: float = c.lifespan_bonus + sheet.positive("lifespan_years")
	var ceiling: float = float(gd.attributes().bonus_ceilings.lifespan_frac) * base_life
	if positive > 0.0:
		b.add("Lifespan bonus" if positive <= ceiling else "Lifespan bonus (%.1f, ceiling %.1f)" % [positive, ceiling], minf(positive, ceiling))
	if sheet.negative("lifespan_years") != 0.0:
		b.add("lifespan_years penalties", sheet.negative("lifespan_years"))
	b.add_pct("lifespan_pct", sheet.total("lifespan_pct"))
	return b


## Whether the realm condition of the next great breakthrough holds: {met, text}. No condition
## is met by default. [param density] is the local qi plus density_bonus.
static func breakthrough_condition(c: Character, gd: GameData, density: float) -> Dictionary:
	var next: Dictionary = gd.realm(c.realm_index + 1)
	var req: Variant = next.get("entry_requirement")
	if req == null or req.get("condition") == null:
		return {"met": true, "text": ""}
	var cond: Dictionary = req.condition
	match str(cond.type):
		"density_min":
			return {"met": density >= float(cond.value) - 1e-6, "text": "spiritual qi %.2f, needs %.2f" % [density, float(cond.value)]}
		"tam_ma_max":
			return {"met": c.tam_ma <= float(cond.value), "text": "heart demon %.2f, at most %.0f" % [c.tam_ma, float(cond.value)]}
		"insight":
			return {"met": c.has_insight, "text": "breakthrough insight %s" % ("held" if c.has_insight else "not gained")}
	return {"met": true, "text": ""}


## The step's failure insight as a fraction, after [param failed] failed pill attempts.
static func failure_insight(gd: GameData, failed: int) -> float:
	var rules: Dictionary = gd.breakthrough_rules()
	return minf(float(failed) * float(rules.failure_insight_pp), float(rules.failure_insight_cap)) / 100.0


## Formulas C: the attempt chance as a breakdown. [param pill_rank] is the pill's quality, or
## -1 for a bare attempt. [param talisman] puts a breakthrough talisman on a pill attempt.
static func breakthrough_chance(c: Character, gd: GameData, sheet: StatSheet, pill_rank: int, talisman: bool = false) -> Breakdown:
	var rules: Dictionary = gd.breakthrough_rules()
	var next: Dictionary = gd.realm(c.realm_index + 1)
	var req: Variant = next.get("entry_requirement")
	var b := Breakdown.new("Breakthrough chance")
	if req == null:
		b.base("No bottleneck", 1.0)
		return b
	if pill_rank < 0:
		b.base("Bare attempt, no %s" % req.item_tag, float(req.base_chance))
		return b
	b.base("Pill attempt, %s" % req.item_tag, float(req.pill_chance))
	var ngo: float = sheet.effective("ngo_tinh", c)
	var dao: float = sheet.effective("dao_tam", c)
	var extras: Array = [
		["Pill quality %d" % pill_rank, float(pill_rank) * float(rules.pill_quality_bonus_per_grade)],
		["Ngộ tính %d" % int(ngo), ngo * float(rules.ngo_tinh_bonus_per_point)],
		["Đạo tâm %d" % int(dao), dao * float(rules.dao_tam_bonus_per_point)],
	]
	var q_tree: float = sheet.tree_breakthrough() / 100.0
	if q_tree != 0.0:
		extras.append(["Kinh Mạch breakthrough chance", q_tree])
	var q_event: float = sheet.other_breakthrough() / 100.0
	if q_event != 0.0:
		extras.append(["Item and event bonuses", q_event])
	var sum: float = 0.0
	for e in extras:
		b.add(e[0], e[1])
		sum += float(e[1])
	var ceiling: float = float(rules.q_extras_ceiling_pp) / 100.0
	if sum > ceiling:
		b.add("q extras %.4f, ceiling %.2f" % [sum, ceiling], ceiling - sum)
	var destiny: float = sheet.perk_breakthrough() / 100.0
	if destiny != 0.0:
		b.add("Thiên mệnh", destiny)
	var insight: float = failure_insight(gd, c.failed_pills)
	if insight > 0.0:
		b.add("Failure insight (%d failed pill attempt%s)" % [c.failed_pills, "" if c.failed_pills == 1 else "s"], insight)
	if talisman:
		b.add("Phá Cảnh Phù", talisman_value(gd))
	b.clamp_to(float(rules.chance_min), float(rules.chance_max))
	return b


## τ: the breakthrough talisman's bonus as a fraction.
static func talisman_value(gd: GameData) -> float:
	for t in gd.file("crafting_talismans").talismans:
		if str(t.get("use", "")) == "breakthrough":
			return float(t.value) / 100.0
	return 0.0


## Formulas E: qi deviation chance in percent, as a breakdown.
static func backlash_chance(c: Character, gd: GameData, sheet: StatSheet) -> Breakdown:
	var rules: Dictionary = gd.breakthrough_rules()
	var b := Breakdown.new("Qi deviation chance (%)")
	b.base("Tâm ma", c.tam_ma)
	b.add("Đạo tâm / %s" % str(rules.tam_ma_backlash_divisor), -sheet.effective("dao_tam", c) / float(rules.tam_ma_backlash_divisor))
	b.clamp_to(0.0, 100.0)
	b.mul("qi_deviation_pct", maxf(0.0, 1.0 + sheet.total("qi_deviation_pct") / 100.0))
	b.clamp_to(0.0, 100.0)
	return b


## Formulas H: S_guard, the lower bound on crossing this realm, from the pill attempts made
## and one per held pill at the current chance [param q_held].
static func guard_success(c: Character, gd: GameData, held_pills: int, q_held: float) -> float:
	var fail: float = 1.0
	for q in c.attempt_log:
		fail *= 1.0 - float(q)
	for i in held_pills:
		fail *= 1.0 - q_held
	return minf(1.0 - fail, float(gd.file("cultivation_realms").guard.s_max))


## Meridian Map E2: #22's chance for an attempt, without τ. [param s] is S_guard. The attempt
## succeeds with this plus [param tau].
static func q_desperate(gd: GameData, q: float, tau: float, s: float) -> float:
	var p: Dictionary = gd.capability(22).params
	var q_max: float = float(gd.breakthrough_rules().chance_max)
	if s >= 1.0:
		return q
	return minf(minf(2.0 * q, q + float(p.delta_desp)), minf(q_max - tau, q + float(p.delta_max) * (1.0 - q - tau) / (1.0 - s)))


## Meridian Map E2: #23's extra roll, at most q. [param insight] is the step's current insight
## as a fraction; the roll's failure would add iota, so the guard reserves it.
static func q_retry(gd: GameData, q: float, insight: float, s: float) -> float:
	var rules: Dictionary = gd.breakthrough_rules()
	var cap: float = float(rules.failure_insight_cap) / 100.0
	var iota: float = 0.0 if insight >= cap else minf(float(rules.failure_insight_pp) / 100.0, cap - insight)
	if s >= 1.0:
		return 0.0
	return minf(q, (float(gd.capability(23).params.delta_max) - iota) / (1.0 - s))


## #23's cost: the greater of its flat years and its share of the realm's lifespan.
static func burn_cost(c: Character, gd: GameData) -> float:
	var p: Dictionary = gd.capability(23).params
	return maxf(float(p.burn_years), float(p.burn_frac) * float(gd.realm(c.realm_index).lifespan))


## Edge Cases: loses one stage. The level drops to the previous stage's first level, or the
## realm's first; the bar resets; a realm is never crossed; points stay.
static func lose_stage(c: Character, gd: GameData) -> void:
	c.stage = maxi(c.stage - 1, 0)
	c.level = Ladder.stage_first_level(gd, c.realm_index, c.stage)
	c.tu_vi = 0.0


## True if a bare attempt may still be made in this realm step.
static func bare_attempt_left(c: Character, gd: GameData) -> bool:
	return c.bare_attempts < int(gd.ladder().bare_attempt_cap)


## Rolls an attempt at [param chance]. Success enters the next realm's early stage; failure
## takes rule 10's penalties. [param is_pill] marks a pill attempt for failure insight and the
## attempt log. Returns {success, chance, roll, backlash, died, tu_vi_lost, tam_ma_gained, points}.
static func resolve_attempt(c: Character, gd: GameData, sheet: StatSheet, rng: Variant, chance: float, is_pill: bool) -> Dictionary:
	var rules: Dictionary = gd.breakthrough_rules()
	var roll: float = rng.randf()
	var out := {"success": false, "chance": chance, "roll": roll, "backlash": false, "died": false, "tu_vi_lost": 0.0, "tam_ma_gained": 0.0, "points": 0}
	if is_pill:
		c.attempt_log.append(chance)
	else:
		c.bare_attempts += 1
	if roll < chance:
		_enter_next_realm(c, gd, out)
		return out
	if is_pill:
		c.failed_pills += 1
	var safe: bool = sheet.has_flag("safe_failure")
	var lost: float = 0.0 if safe else c.tu_vi * float(rules.failure_tu_vi_loss_pct)
	c.tu_vi -= lost
	out.tu_vi_lost = lost
	out.tam_ma_gained = CharacterRules.add_tam_ma(c, gd, sheet, float(rules.failure_tam_ma_gain) * (0.5 if safe else 1.0))
	var floor_v: float = float(rules.vitality_floor)
	c.vitality = maxf(c.vitality - float(rules.failure_khi_huyet_loss_frac), floor_v)
	if rng.randf() < backlash_chance(c, gd, sheet).total / 100.0:
		out.backlash = true
		if c.tam_ma >= float(rules.backlash_death_tam_ma_threshold):
			out.died = true
			c.alive = false
			c.death_cause = "Tẩu hỏa nhập ma khi đột phá"
		else:
			c.vitality = floor_v
	return out


## Moves to the next realm: level +1, bar 0, full vitality, points paid, step state cleared.
static func _enter_next_realm(c: Character, gd: GameData, out: Dictionary) -> void:
	var points_before: int = c.tree_points
	c.realm_index += 1
	c.tu_vi = 0.0
	c.vitality = 1.0
	var res := {"levels": 0, "stages": 0, "tree_points": 0, "levels_gained": [], "stages_reached": []}
	_climb(c, gd, Ladder.band(gd, c.realm_index)[0], res)
	c.bare_attempts = 0
	c.failed_pills = 0
	c.talisman_used = false
	c.attempt_log = []
	c.cap_used = {}
	out.success = true
	out.points = c.tree_points - points_before
