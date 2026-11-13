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
	var base: float = float(realm.power_base) * Ladder.stage_mult(gd, c.stage)
	var lines := PackedStringArray()
	lines.append("Realm %s: base %.0f" % [gd.realm_label(c.realm_index, c.stage), base])

	var offense := Breakdown.new("Offense")
	offense.base("Realm share", base * float(cfg.base_offense_share))
	var defense := Breakdown.new("Defense")
	defense.base("Realm share", base * float(cfg.base_defense_share))

	var main: Dictionary = CongPhap.main_entry(c)
	if not main.is_empty():
		offense.add("Công pháp %s" % main.def.name, base * float(cfg.cong_phap_share) * CongPhap.tech_power(c, gd, sheet.effective("ngo_tinh", c)))

	# Artifacts, limited by the item slots (thần thức adds extra slots) and the single-artifact keystone.
	var control: Dictionary = controlled(c, gd, db, sheet)
	var used: Array = control.used
	var overflow: Array = control.overflow
	var single: bool = sheet.has_flag("single_artifact")
	var art_cfg: Dictionary = gd.artifacts_file()
	for item_id in used:
		var art: Dictionary = db.get_record("items", item_id)
		var nurtured: bool = c.has_capability(3) and item_id == c.nurtured_id
		var mult: float = 1.0 + sheet.total("artifact_power_pct") / 100.0
		if art.element != "" and c.linh_can.has(art.element):
			mult += (float(art_cfg.element_match_bonus_pct) + _affix(art, "element_affinity_pct")) / 100.0
		if single and control.slot_of.get(item_id, "") == EquipSlots.EXTRA:   # the one bonded treasure (rule 11)
			mult *= float(art_cfg.equip.single_artifact_keystone_mult)
		if nurtured:
			var p3: Dictionary = gd.capability(3).params
			mult += minf(float(c.nurture_years) * float(p3.per_year_pct), float(p3.max_pct)) / 100.0
		if c.has_capability(1) and _pair_count(c, db, str(art.get("base", ""))) >= 2:
			mult += float(gd.capability(1).params.attack_pct) / 100.0
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
	var ll: float = CharacterRules.linh_luc(c, gd, sheet).total
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
	lines.append("Extra slots %d / %d, the next at thần thức %.0f%s" % [control.extra_used, control.limit, EquipSlots.next_slot_than_thuc(c, gd, sheet), ("  (past the count: %s)" % ", ".join(overflow)) if not overflow.is_empty() else ""])
	return {"total": total.total, "offense": offense.total, "defense": defense.total, "lines": lines, "used_artifacts": used, "overflow": overflow, "extra_used": control.extra_used, "extra_limit": control.limit}


## Splits the equipped pieces into those that count and those that do not (item-database.md rule 11). No piece costs
## thần thức: every piece in a base slot counts, and extra pieces count in equip order up to the extra-slot count
## (thần thức adds slots); a piece past it adds nothing. Under the one-treasure keystone (`single_artifact`) the base
## slots count as usual and only the first extra piece does.
## Returns {used, overflow, slot_of, limit, extra_used}.
static func controlled(c: Character, gd: GameData, db: WorldDB, sheet: StatSheet) -> Dictionary:
	var used: Array = []
	var overflow: Array = []
	var single: bool = sheet.has_flag("single_artifact")
	var slots: Dictionary = EquipSlots.assign(c, gd, db, sheet)
	var extra_seen: bool = false
	for item_id in c.equipped:
		if not slots.slot_of.has(item_id):
			continue
		var extra: bool = slots.slot_of[item_id] == EquipSlots.EXTRA
		if slots.unslotted.has(item_id) or (single and extra and extra_seen):
			overflow.append(item_id)
			continue
		extra_seen = extra_seen or extra
		used.append(item_id)
	return {"used": used, "overflow": overflow, "slot_of": slots.slot_of, "limit": slots.limit,
		"extra_used": used.filter(func(id): return slots.slot_of[id] == EquipSlots.EXTRA).size()}


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


## How many equipped treasures share a base (capability #1).
static func _pair_count(c: Character, db: WorldDB, base: String) -> int:
	if db == null or base == "":
		return 0
	return c.equipped.filter(func(id): return str(db.get_record("items", id).get("base", "")) == base).size()


## A stat summed over a piece's affixes and unscoped named modifiers.
static func _affix(art: Dictionary, stat: String) -> float:
	return ItemStats.total(art, stat)
