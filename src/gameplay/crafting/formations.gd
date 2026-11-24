class_name Formations
extends RefCounted
## Trận pháp at the động phủ: formations raised level by level with linh thạch and
## materials, each adding a stat (linh khí density at home, herb growth, defense at home),
## each costing yearly upkeep (cut by Thổ purity). Spec:
## design/quick-specs/luyen-khi-and-tran-phap.md. Data: crafting_formations.json.
## Levels live in [member Character.formations] (id -> level).
##
## Usage:
## [codeblock]
## var f := Formations.new(gd, db)
## var cost: Dictionary = f.build_cost("tu_linh", 1)     # {lt, materials, rarity}
## var r: Dictionary = f.build(c, "tu_linh")             # at home
## var notes: Array = f.pay_upkeep(c)                    # yearly
## Formations.add_mods(c, gd, sheet)                     # used by StatSheet.build
## [/codeblock]

var _gd: GameData
var _db: WorldDB


func _init(gd: GameData, db: WorldDB) -> void:
	_gd = gd
	_db = db


## crafting_formations.json content.
func config() -> Dictionary:
	return _gd.file("crafting_formations")


## Formation definition by id, or {}.
func def(formation_id: String) -> Dictionary:
	for f in config().formations:
		if f.id == formation_id:
			return f
	return {}


## Current level of a formation (0 = not built).
func level(c: Character, formation_id: String) -> int:
	return int(c.formations.get(formation_id, 0))


## Cost of raising a formation to [param target_level]: {lt, materials, rarity}.
func build_cost(formation_id: String, target_level: int) -> Dictionary:
	var f: Dictionary = def(formation_id)
	var lt: float = float(f.cost_lt) * pow(float(f.cost_growth), float(target_level - 1))
	return {"lt": int(roundf(lt)), "materials": int(f.materials_per_level) * target_level, "rarity": int(f.material_rarity)}


## The level an array is billed at: 0 when dormant, else its level (Cave Abode rule 9; no ceiling since 2026-11-24).
func _billed_level(c: Character, formation_id: String) -> int:
	var home: Dictionary = _db.get_record("places", c.home_id) if _db != null else {}
	return CaveAbode.eff_level(_gd, home.get("qi", {}), c.id, "f:%s" % formation_id, int(c.formations[formation_id]), _work_max(c, formation_id))


## A standing array's own maximum as a home work: none since 2026-11-24 (0); the skill cap below bounds it.
func _work_max(_c: Character, _formation_id: String) -> int:
	return 0


## Highest level the character can build for this formation now: the Trận pháp skill + 1, and Capability #15 lets a
## standing array stand its extra_levels above that (Formations F3; user decision 2026-11-24: no max_level for standing arrays).
func max_level(c: Character, formation_id: String) -> int:
	var extra: int = int(_gd.capability(15).params.extra_levels) if c.has_capability(15) else 0
	return c.skill_level(str(config().skill)) + 1 + extra


## Whether the next level can be built: {ok, reason, cost}.
func can_build(c: Character, formation_id: String) -> Dictionary:
	var f: Dictionary = def(formation_id)
	if f.is_empty():
		return {"ok": false, "reason": "unknown formation '%s' (%s)" % [formation_id, ", ".join(config().formations.map(func(x): return x.id))]}
	if c.location_id != c.home_id and not c.has_capability(14):
		return {"ok": false, "reason": "formations are laid at your động phủ"}
	var target: int = level(c, formation_id) + 1
	if target > max_level(c, formation_id):
		return {"ok": false, "reason": "level %d needs Trận pháp level %d (you have %d)" % [target, target - 1, c.skill_level(str(config().skill))]}
	var home: Dictionary = _db.get_record("places", c.home_id) if _db != null else {}
	if not home.is_empty():   # Cave Abode rules 3 and 4: a standing array takes a slot at the home, within the ceiling
		var ab: Dictionary = CaveAbode.can_raise(_gd, home.get("qi", {}), c, "f:%s" % formation_id, target, _work_max(c, formation_id))
		if not bool(ab.ok):
			return {"ok": false, "reason": str(ab.reason)}
	var cost: Dictionary = build_cost(formation_id, target)
	if not home.is_empty():   # Cave Abode F3: the grade prices levels above its free level
		var hr: Dictionary = CaveAbode.home_rec(home.get("qi", {}), c.id)
		if not hr.is_empty():
			cost["lt"] = int(roundf(float(cost.lt) * CaveAbode.price_mult(_gd, CaveAbode.grade_of(hr), target)))
	if c.linh_thach < int(cost.lt):
		return {"ok": false, "reason": "needs %d linh thạch (you have %d)" % [int(cost.lt), c.linh_thach]}
	if MaterialBag.count(c, _gd, _db, int(cost.rarity)) < int(cost.materials):
		return {"ok": false, "reason": "needs %d material(s) of rarity ≥ %d" % [int(cost.materials), int(cost.rarity)]}
	return {"ok": true, "reason": "", "cost": cost}


## Raises a formation one level, paying its cost. Returns {ok, message, level, levels}.
func build(c: Character, formation_id: String) -> Dictionary:
	var ck: Dictionary = can_build(c, formation_id)
	if not ck.ok:
		return {"ok": false, "message": "Cannot build: %s." % ck.reason}
	var f: Dictionary = def(formation_id)
	MoneyLedger.player_pay(_db, c, "", int(ck.cost.lt), "formation")   # Formations rule 17: burn_formation (Formula H)
	MaterialBag.spend(c, _gd, _db, int(ck.cost.rarity), int(ck.cost.materials))
	var lv: int = level(c, formation_id) + 1
	c.formations[formation_id] = lv
	var home_p: Dictionary = _db.get_record("places", c.home_id)
	if not home_p.is_empty():
		CaveAbode.reconcile(_gd, home_p.get("qi", {}), c)
	var cfg: Dictionary = config()
	var gained: int = c.add_skill_xp(str(cfg.skill), float(cfg.xp_per_level_built) * float(lv), float(cfg.xp_per_level), int(cfg.max_skill_level))
	var msg: String = "%s raised to level %d: %s. Upkeep now %d linh thạch a year." % [f.name, lv, _gd.format_mod(str(f.stat), float(f.per_level) * float(lv)), upkeep(c)]
	if gained > 0:
		msg += " Trận pháp rises to level %d." % c.skill_level(str(cfg.skill))
	return {"ok": true, "message": msg, "level": lv, "levels": gained}


## Yearly upkeep in linh thạch for every formation, after the Thổ discount.
func upkeep(c: Character) -> int:
	var total: float = 0.0
	for id in c.formations.keys():
		var per: float = float(def(id).get("upkeep_lt_per_level", 0))
		var lv: int = _billed_level(c, id)
		var over: int = maxi(lv - (c.skill_level(str(config().skill)) + 1), 0) if c.has_capability(15) else 0   # #15's levels over the skill cap
		total += per * float(lv - over) + per * float(over) * (float(_gd.capability(15).params.upkeep_mult) if over > 0 else 1.0)
	var cut: float = clampf(c.linh_can.purity("tho") * float(config().tho_upkeep_cut_per_purity), 0.0, 0.9)
	return int(roundf(total * (1.0 - cut)))


## Pays the yearly upkeep. When the player cannot pay, the formation with the highest
## upkeep drops one level (one per year) and whatever linh thạch there is goes to the
## rest. Returns lines describing what happened ([] when all was paid).
func pay_upkeep(c: Character) -> Array:
	var lines: Array = []
	var due: int = upkeep(c)
	if due > 0 and c.linh_thach < due:
		var worst: String = ""
		var worst_cost: float = -1.0
		for id in c.formations.keys():
			if _billed_level(c, id) <= 0:
				continue   # a dormant array never lapses (Formations rule 14, Cave Abode rule 9)
			var per: float = float(def(id).upkeep_lt_per_level)
			if per > worst_cost:
				worst_cost = per
				worst = id
		if worst == "":
			return lines
		c.formations[worst] = int(c.formations[worst]) - 1
		lines.append("Upkeep unpaid: %s weakens to level %d." % [def(worst).name, int(c.formations[worst])])
		if int(c.formations[worst]) <= 0:
			c.formations.erase(worst)
		due = upkeep(c)
	MoneyLedger.player_pay(_db, c, "", mini(due, c.linh_thach), "formation")   # rule 17: burn_formation
	return lines


## Formations F5: a protective array of [param level] for an owner of [param owner_realm], once for one event:
## {defense_pct = per_level × L × (1 + 0.5 × formation_power_pct / 100), burn = trigger_frac × L × linh_thach_max}.
static func protective(gd: GameData, level: int, power_pct: float, owner_realm: int) -> Dictionary:
	var pc: Dictionary = gd.file("crafting_formations").get("protective", {"per_level": 10.0, "trigger_frac": 0.004})
	var budget: float = float(gd.file("events_budgets").per_realm[str(gd.realm(clampi(owner_realm, 0, gd.realms().size() - 1)).id)].linh_thach_max)
	return {"defense_pct": float(pc.per_level) * level * (1.0 + 0.5 * power_pct / 100.0),
		"burn": int(ceil(float(pc.trigger_frac) * level * budget - 1e-6))}


## Formations F5 and rule 15: a protective array triggers once for an event when its owner [param c] can pay the burn
## (booked as burn_formation); otherwise it does not trigger and burns nothing. Returns {fired, defense_pct, burn}.
func trigger_protective(c: Character, level: int, power_pct: float) -> Dictionary:
	var pr: Dictionary = protective(_gd, level, power_pct, c.realm_index)
	if c.linh_thach < int(pr.burn):
		return {"fired": false, "defense_pct": 0.0, "burn": 0}
	MoneyLedger.player_pay(_db, c, "", int(pr.burn), "formation")
	return {"fired": true, "defense_pct": float(pr.defense_pct), "burn": int(pr.burn)}


## Adds formation modifiers to a stat sheet ("home" formations only while at home),
## scaled by formation_power_pct (e.g. the Trận biến dị) already on the sheet.
static func add_mods(c: Character, gd: GameData, sheet: StatSheet, db: WorldDB = null) -> void:
	if c.formations.is_empty():
		return
	var power: float = 1.0 + sheet.total("formation_power_pct") / 100.0
	var home_qi: Dictionary = db.get_record("places", c.home_id).get("qi", {}) if db != null else {}
	var extra: int = int(gd.capability(15).params.extra_levels) if c.has_capability(15) else 0
	for f in gd.file("crafting_formations").get("formations", []):
		var lv: int = int(c.formations.get(f.id, 0))
		if lv <= 0:
			continue
		if str(f.applies) == "home" and c.location_id != c.home_id and not c.has_capability(14):
			continue
		# Cave Abode rule 9 and F3: dormant arrays count for nothing; an array above the ceiling counts at it
		lv = CaveAbode.eff_level(gd, home_qi, c.id, "f:%s" % str(f.id), lv, int(f.max_level) + extra)
		# Cave Abode edge case and Formations F3: the Trận Pháp skill cap wins over a higher level ceiling
		lv = mini(lv, c.skill_level(str(gd.file("crafting_formations").skill)) + 1 + extra)
		if lv <= 0:
			continue
		# Travel & Map rule 32: Tu Linh's density is layer-1 upkept density, capped with the other layer-1 works
		var stat: String = "home_array_density" if str(f.stat) == "density_bonus" else str(f.stat)
		sheet.add_mod("Trận pháp: %s level %d" % [f.name, lv], stat, float(f.per_level) * float(lv) * power)
