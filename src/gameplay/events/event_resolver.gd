class_name EventResolver
extends RefCounted
## Resolves a normalized event choice with engine rules only: pays "always" costs, rolls
## the check (thiên phú vs difficulty, or a duel against the event NPC), then applies
## the outcome's effects. Every roll and effect is reported as text so the result is
## explainable, and the LLM can only narrate what happened here.
## Data: events_budgets.json (check).
##
## Usage:
## [codeblock]
## var r := EventResolver.new(gd, db, builds, items)
## var ok: Dictionary = r.can_choose(c, event, 0)
## var result: Dictionary = r.resolve(c, sheet, rng, event, 0)
## for line in result.lines: print(line)
## [/codeblock]

var _gd: GameData
var _db: WorldDB
var _builds: BuildGenerator
var _items: ItemFactory
var _alchemy: Alchemy
## Set by the session: Callable(kind: String) -> String, unseals a cluster and returns its line.
var unseal_fn: Callable


func _init(gd: GameData, db: WorldDB, builds: BuildGenerator, items: ItemFactory) -> void:
	_gd = gd
	_db = db
	_builds = builds
	_items = items
	_alchemy = Alchemy.new(gd, db, items)


## True if the player can afford the choice's "always" costs. Returns {ok, reason}.
func can_choose(c: Character, event: Dictionary, index: int) -> Dictionary:
	if index < 0 or index >= event.choices.size():
		return {"ok": false, "reason": "choose 1..%d" % event.choices.size()}
	for fx in event.choices[index].always:
		if fx.type == "linh_thach" and float(fx.amount) < 0.0 and c.linh_thach < int(-float(fx.amount)):
			return {"ok": false, "reason": "needs %d linh thạch (you have %d)" % [int(-float(fx.amount)), c.linh_thach]}
	return {"ok": true, "reason": ""}


## Chance (0..1) of passing a stat check, as a breakdown. [param evade] adds stealth
## (fleeing or hiding checks).
func stat_check_chance(c: Character, sheet: StatSheet, stat: String, difficulty: float, evade: bool = false) -> Breakdown:
	var cfg: Dictionary = _gd.budgets().check
	var v: float = sheet.effective(stat, c)
	var b := Breakdown.new("Check chance")
	b.base("Base", float(cfg.base))
	b.add("%s %d vs difficulty %d" % [stat, int(v), int(difficulty)], (v - difficulty) * float(cfg.per_point))
	if stat != "khi_van":
		b.add("Khí vận %d" % int(sheet.effective("khi_van", c)), (sheet.effective("khi_van", c) - float(cfg.khi_van_neutral)) * float(cfg.khi_van_per_point))
	if evade and sheet.total("stealth") != 0.0:
		b.add("Stealth %d (evading)" % int(sheet.total("stealth")), sheet.total("stealth") * float(cfg.get("stealth_per_point", 0.0)))
	b.clamp_to(float(cfg.min), float(cfg.max))
	return b


## Resolves a choice. Returns {success, lines: [String], items: [ids], died, check_line}.
func resolve(c: Character, sheet: StatSheet, rng: RandomNumberGenerator, event: Dictionary, index: int) -> Dictionary:
	var choice: Dictionary = event.choices[index]
	var lines: Array = []
	var items: Array = []
	for fx in choice.always:
		lines.append(_apply(c, sheet, rng, event, fx, items))
	var success: bool = true
	var check_line: String = ""
	var used: Array = Talismans.apply_for_check(c, _gd, _db, sheet, str(choice.check.type), bool(choice.check.get("evade", false)), true, rng)
	if not used.is_empty():
		lines.append("used %s" % ", ".join(used))
	match str(choice.check.type):
		"stat":
			var chance: float = stat_check_chance(c, sheet, choice.check.stat, float(choice.check.difficulty), bool(choice.check.get("evade", false))).total
			var roll: float = rng.randf()
			success = roll < chance
			check_line = "%s check: %.0f%% chance, roll %.0f -> %s" % [choice.check.stat, chance * 100.0, roll * 100.0, "SUCCESS" if success else "FAILURE"]
			if not success and c.has_capability(19) and not c.cap_used.has("19"):
				c.cap_used["19"] = true
				roll = rng.randf()
				success = roll < chance
				check_line += "; Khí Vận Chi Tử rerolls %.0f -> %s" % [roll * 100.0, "SUCCESS" if success else "FAILURE"]
		"combat":
			var enemy_rec: Dictionary = _db.get_record("people", str(choice.check.enemy))
			var enemy := Character.from_dict(enemy_rec)
			var mine: float = CombatPower.compute(c, _gd, _db, sheet).total
			var theirs: float = _builds.power_of(enemy)
			var duel: Dictionary = CombatPower.duel(mine, theirs, sheet.effective("khi_van", c), float(enemy.base_stat("khi_van")), _gd, rng)
			success = duel.win
			check_line = "Combat: chiến lực %.0f vs %s %.0f -> %.0f%% chance, roll %.0f -> %s" % [mine, enemy.name, theirs, duel.chance * 100.0, duel.roll * 100.0, "VICTORY" if success else "DEFEAT"]
			if success and not enemy.is_beast and c.has_capability(9):
				var p9: Dictionary = _gd.capability(9).params
				var drained: Dictionary = CultivationRules.add_tu_vi(c, _gd, float(p9.stage_frac) * CultivationRules.stage_cost(c, _gd))
				CharacterRules.add_tam_ma(c, _gd, sheet, float(p9.tam_ma))
				lines.append("Hấp Tinh Đại Pháp: tu vi +%.0f" % (float(drained.gained) - float(drained.wasted)))
			if success and enemy.is_beast:
				var tame: Dictionary = BeastKeeper.new(_gd, _db).try_tame(c, sheet, rng, str(choice.check.enemy))
				if str(tame.get("message", "")) != "":
					lines.append(tame.message)
	if check_line != "":
		lines.push_front(check_line)
	var outcome: Dictionary = choice.success if success else choice.failure
	for fx in outcome.effects:
		lines.append(_apply(c, sheet, rng, event, fx, items))
	var died: bool = false
	if c.vitality <= 0.0 and bool(_gd.session().death.khi_huyet_zero_dies):
		if c.has_capability(5) and not c.cap_used.has("5"):
			c.cap_used["5"] = true
			c.vitality = float(_gd.breakthrough_rules().vitality_floor)
			CultivationRules.lose_stage(c, _gd)
			lines.append("Linh Hồn Xuất Khiếu: your soul slips free; you live, one stage lower.")
		else:
			c.alive = false
			c.death_cause = "Tử nạn: %s" % event.title
			died = true
	return {"success": success, "lines": lines.filter(func(l): return l != ""), "items": items, "died": died, "check_line": check_line, "outcome_text": outcome.text}


func _apply(c: Character, sheet: StatSheet, rng: RandomNumberGenerator, event: Dictionary, fx: Dictionary, items: Array) -> String:
	match str(fx.type):
		"linh_thach":
			var amt: int = int(fx.amount)
			if amt < 0:
				amt = -mini(-amt, c.linh_thach)
			c.linh_thach += amt
			return "linh thạch %+d (now %d)" % [amt, c.linh_thach]
		"tu_vi":
			var res: Dictionary = CultivationRules.add_tu_vi(c, _gd, float(fx.amount))
			return "tu vi +%.0f%s" % [float(fx.amount), (" (+%d stage(s), +%d Kinh Mạch points)" % [res.stages, res.tree_points]) if res.stages > 0 else ""]
		"khi_huyet_loss_pct":
			c.vitality = c.vitality - float(fx.amount) / 100.0
			return "khí huyết -%.0f%% (now %d%%)" % [float(fx.amount), int(maxf(c.vitality, 0.0) * 100.0)]
		"tam_ma":
			var applied: float = CharacterRules.add_tam_ma(c, _gd, sheet, float(fx.amount))
			return "tâm ma %+.1f (now %.0f)" % [applied, c.tam_ma]
		"dan_doc":
			var applied2: float = CharacterRules.add_dan_doc(c, _gd, sheet, float(fx.amount))
			return "đan độc %+.1f (now %.0f)" % [applied2, c.dan_doc]
		"relationship":
			var npc_id: String = str(event.npc_id) if str(fx.get("npc", "event_npc")) == "event_npc" else str(fx.npc)
			var rec: Dictionary = _db.get_record("people", npc_id)
			if rec.is_empty():
				return ""
			var cfg: Dictionary = _gd.session().talk
			rec["attitude"] = clampi(int(rec.get("attitude", 0)) + int(fx.amount), int(cfg.relationship_min), int(cfg.relationship_max))
			return "%s's attitude %+d (now %d)" % [rec.name, int(fx.amount), int(rec.attitude)]
		"insight":
			# The Deity Transformation insight: any enlightenment in Nascent Soul (Realms rule 7).
			if c.realm_index == _gd.realm_index("nguyen_anh") and not c.has_insight:
				c.has_insight = true
				return "breakthrough insight gained"
			return ""
		"unseal_sealed", "unseal_open":
			return str(unseal_fn.call(str(fx.type).trim_prefix("unseal_"))) if unseal_fn.is_valid() else ""
		"tree_point":
			c.tree_points += int(fx.amount)
			return "+%d Kinh Mạch point(s)" % int(fx.amount)
		"herb":
			var h: Dictionary
			if str(fx.get("herb", "")) != "":
				h = _items.herb(fx.herb, RngUtils.range_f(rng, fx.age_range))
			else:
				h = _items.random_herb(rng, int(fx.rarity_max), fx.age_range, str(fx.get("element", "")))
			return _give(c, h, items)
		"material":
			var m: Dictionary = _items.material(fx.material, 1) if str(fx.get("material", "")) != "" else _items.random_material(rng, int(fx.rarity_max), str(fx.get("element", "")))
			return _give(c, m, items)
		"artifact":
			var a: Dictionary = _items.artifact(rng, c.realm_index, int(fx.grade), str(fx.get("element", "")), "", str(fx.get("name", "")))
			return _give(c, a, items)
		"cong_phap":
			var elems: Array = [fx.element] if str(fx.get("element", "")) != "" else []
			var cp: Dictionary = _items.cong_phap(rng, int(fx.tier), elems, str(fx.get("name", "")), {"root": c.linh_can})
			return _give(c, cp, items)
		"talisman":
			var tal: Dictionary = _items.talisman(str(fx.talisman), 1)
			return _give(c, tal, items)
		"breakthrough_pill":
			if c.realm_index >= _gd.realms().size() - 1:
				return ""
			var recipe: Dictionary = Advisor.recipe_for_tag(_gd, str(_gd.realm(c.realm_index + 1).entry_requirement.item_tag))
			if recipe.is_empty():
				return ""
			var bp: String = _alchemy.add_pills(c, str(recipe.id), 0, 1)
			items.append(bp)
			return "gained %s" % recipe.name
		"plan_herb":
			if c.realm_index >= _gd.realms().size() - 1:
				return ""
			var r2: Dictionary = Advisor.recipe_for_tag(_gd, str(_gd.realm(c.realm_index + 1).entry_requirement.item_tag))
			for ing in r2.get("ingredients", []):
				var have: int = _db.items_of(c.id).filter(func(i): return i.kind == "herb" and i.template == ing.herb and float(i.age) >= float(ing.min_age)).size()
				if have < int(ing.qty):
					return _give(c, _items.herb(str(ing.herb), float(ing.min_age) + 1.0), items)
			return ""
		"treasure":
			var missing: Array = _gd.element_cycle().filter(func(e): return not c.linh_can.elements.has(e))
			var elem: String = str(RngUtils.pick(rng, missing)) if not missing.is_empty() else str(RngUtils.pick(rng, _gd.element_cycle()))
			return _give(c, _items.treasure(str(fx.treasure), elem), items)
		"pill":
			var pid: String = _alchemy.add_pills(c, str(fx.recipe), 0, 1)
			items.append(pid)
			return "gained %s" % _gd.recipe(fx.recipe).name
	return ""


func _give(c: Character, item: Dictionary, items: Array) -> String:
	item["owner_id"] = c.id
	var iid: String = _db.add("items", item)
	items.append(iid)
	return "gained %s [%s]" % [_items.describe(item), iid]
