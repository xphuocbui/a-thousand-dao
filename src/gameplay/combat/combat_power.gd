class_name CombatPower
extends RefCounted
## Chiến lực (combat power) — never raised directly; always computed from realm,
## công pháp, equipped pháp bảo (limited by thần thức), Kinh Mạch Đồ and biến dị,
## and always shown as a breakdown (pillar: Power Is Built, Not Given).
## Duels compare powers with a ratio curve so vượt cấp is possible only through
## what you built. Data: combat_rules.json, items_artifacts.json.
##
## Usage:
## [codeblock]
## var p: Dictionary = CombatPower.compute(c, gd, db, sheet)
## print(p.total); print("\n".join(p.lines))
## var duel: Dictionary = CombatPower.duel(p.total, enemy_power, 50.0, 40.0, gd, rng)
## [/codeblock]


## Computes chiến lực. Returns {total, offense, defense, lines, used_artifacts, overflow}.
static func compute(c: Character, gd: GameData, db: WorldDB, sheet: StatSheet) -> Dictionary:
	var cfg: Dictionary = gd.combat().power
	var realm: Dictionary = gd.realm(c.realm_index)
	var base: float = float(realm.power_base) * (1.0 + float(c.stage) * float(realm.stage_power_step))
	var lines := PackedStringArray()
	lines.append("Realm %s: base %.0f" % [gd.realm_label(c.realm_index, c.stage), base])

	var offense := Breakdown.new("Offense")
	offense.base("Realm share", base * float(cfg.base_offense_share))
	var defense := Breakdown.new("Defense")
	defense.base("Realm share", base * float(cfg.base_defense_share))

	var cp: Dictionary = db.get_record("items", c.cong_phap_id) if db != null else {}
	if not cp.is_empty():
		offense.add("Công pháp %s" % cp.name, base * float(cfg.cong_phap_share) * float(cp.get("power_mult", 1.0)))

	# Artifacts, limited by thần thức capacity and the single-artifact keystone.
	var capacity: float = CharacterRules.than_thuc(c, gd, sheet).total
	var used: Array = []
	var overflow: Array = []
	var spent: float = 0.0
	var single: bool = sheet.has_flag("single_artifact")
	var art_cfg: Dictionary = gd.artifacts_file()
	for item_id in c.equipped:
		var art: Dictionary = db.get_record("items", item_id) if db != null else {}
		if art.is_empty():
			continue
		var cost: float = float(art.than_thuc_cost) * clampf(1.0 + _affix(art, "than_thuc_cost_pct") / 100.0, 0.1, 2.0)
		if spent + cost > capacity or (single and not used.is_empty()):
			overflow.append(item_id)
			continue
		spent += cost
		used.append(item_id)
		var mult: float = 1.0 + sheet.total("artifact_power_pct") / 100.0
		if art.element != "" and c.linh_can.has(art.element):
			mult += (float(art_cfg.element_match_bonus_pct) + _affix(art, "element_affinity_pct")) / 100.0
		if single:
			mult *= float(art_cfg.equip.single_artifact_keystone_mult)
		var atk: float = float(art.attack) * (1.0 + _affix(art, "artifact_attack_pct") / 100.0) * mult
		var dfn: float = float(art.defense) * (1.0 + _affix(art, "artifact_defense_pct") / 100.0) * mult
		if atk > 0.0:
			offense.add(str(art.name), atk)
		if dfn > 0.0:
			defense.add(str(art.name), dfn)
	for b in BeastKeeper.power_shares(c, gd, db):
		offense.add("Linh thú %s" % b.name, float(b.power))
	offense.add_pct("attack_pct", sheet.total("attack_pct"))
	defense.add_pct("defense_pct", sheet.total("defense_pct"))

	var kh: float = CharacterRules.khi_huyet_max(c, gd, sheet).total
	var ll: float = CharacterRules.linh_luc(c, gd, db, sheet).total
	defense.add("Khí huyết %.0f x %s" % [kh, str(cfg.khi_huyet_weight)], kh * float(cfg.khi_huyet_weight))
	offense.add("Linh lực %.0f x %s" % [ll, str(cfg.linh_luc_weight)], ll * float(cfg.linh_luc_weight))

	var total := Breakdown.new("Chiến lực")
	total.base("Offense", offense.total)
	total.add("Defense", defense.total)
	var floor_v: float = float(gd.combat().duel.injured_power_floor)
	if c.vitality < 1.0:
		total.mul("Injured (khí huyết %d%%)" % int(c.vitality * 100.0), maxf(c.vitality, floor_v))
	if c.is_beast:
		total.mul("Yêu thú", float(gd.combat().beast.power_mult))

	lines.append_array(offense.lines())
	lines.append_array(defense.lines())
	lines.append_array(total.lines())
	lines.append("Thần thức used %.0f / %.0f%s" % [spent, capacity, ("  (not enough for: %s)" % ", ".join(overflow)) if not overflow.is_empty() else ""])
	return {"total": total.total, "offense": offense.total, "defense": defense.total, "lines": lines, "used_artifacts": used, "overflow": overflow, "than_thuc_used": spent, "than_thuc_capacity": capacity}


## Resolves a duel. Win chance = A^k / (A^k + B^k) + (Khí vận A - Khí vận B) x k2, clamped.
## Returns {win, chance, roll}.
static func duel(power_a: float, power_b: float, khi_van_a: float, khi_van_b: float, gd: GameData, rng: RandomNumberGenerator) -> Dictionary:
	var cfg: Dictionary = gd.combat().duel
	var k: float = float(cfg.ratio_exponent)
	var a: float = pow(maxf(power_a, 1.0), k)
	var b: float = pow(maxf(power_b, 1.0), k)
	var chance: float = a / (a + b) + (khi_van_a - khi_van_b) * float(cfg.khi_van_per_point)
	chance = clampf(chance, float(cfg.min_win_chance), float(cfg.max_win_chance))
	var roll: float = rng.randf()
	return {"win": roll < chance, "chance": chance, "roll": roll}


static func _affix(art: Dictionary, stat: String) -> float:
	var t: float = 0.0
	for a in art.get("affixes", []):
		if str(a.stat) == stat:
			t += float(a.value)
	return t
