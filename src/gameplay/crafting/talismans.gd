class_name Talismans
extends RefCounted
## Phù lục: talismans drawn from cheap materials and linh thạch ink (one season per
## batch), then used automatically on the one check they help — attack and defense
## talismans at the start of a fight, Thần Hành Phù when fleeing or hiding. Thần hồn and
## Phù lục skill set the drawing chance. Spec: design/quick-specs/phu-luc-linh-thu-thanh-tuu.md.
## Data: crafting_talismans.json.
##
## Usage:
## [codeblock]
## var t := Talismans.new(gd, db, items)
## var r: Dictionary = t.draw(c, sheet, rng, "hoa_cau")      # {ok, success, message, qty}
## # Before resolving a check (consume=false only previews, e.g. for the odds on a card):
## var used: Array = Talismans.apply_for_check(c, gd, db, sheet, "combat", false, true)
## [/codeblock]

var _gd: GameData
var _db: WorldDB
var _items: ItemFactory


func _init(gd: GameData, db: WorldDB, items: ItemFactory) -> void:
	_gd = gd
	_db = db
	_items = items


## crafting_talismans.json content.
func config() -> Dictionary:
	return _gd.file("crafting_talismans")


## Talisman definition by id, or {}.
func def(talisman_id: String) -> Dictionary:
	return Talismans.def_of(_gd, talisman_id)


## Talisman definition by id from game data, or {}.
static func def_of(gd: GameData, talisman_id: String) -> Dictionary:
	for t in gd.file("crafting_talismans").get("talismans", []):
		if t.id == talisman_id:
			return t
	return {}


## Drawing success chance (percent) as a breakdown.
func success_chance(c: Character, sheet: StatSheet, talisman_id: String) -> Breakdown:
	var cfg: Dictionary = config()
	var d: Dictionary = def(talisman_id)
	var skill: String = str(cfg.skill)
	var b := Breakdown.new("Phù lục success %")
	b.base("100 - difficulty %d" % int(d.get("difficulty", 50)), 100.0 - float(d.get("difficulty", 50)))
	b.add("Phù lục level %d" % c.skill_level(skill), float(c.skill_level(skill)) * float(cfg.success_per_level))
	b.add("Thần hồn %d" % int(sheet.effective("than_hon", c)), (sheet.effective("than_hon", c) - float(cfg.than_hon_neutral)) * float(cfg.than_hon_per_point))
	b.clamp_to(float(cfg.min_success), float(cfg.max_success))
	return b


## Whether a batch can be drawn: {ok, reason}.
func check(c: Character, talisman_id: String) -> Dictionary:
	var d: Dictionary = def(talisman_id)
	if d.is_empty():
		return {"ok": false, "reason": "unknown talisman '%s' (%s)" % [talisman_id, ", ".join(config().talismans.map(func(t): return t.id))]}
	if c.skill_level(str(config().skill)) < int(d.min_level):
		return {"ok": false, "reason": "%s needs Phù lục level %d" % [d.name, int(d.min_level)]}
	if c.linh_thach < int(d.ink_lt):
		return {"ok": false, "reason": "needs %d linh thạch of ink" % int(d.ink_lt)}
	if MaterialBag.count(c, _gd, _db, int(d.material_rarity)) < int(d.materials):
		return {"ok": false, "reason": "needs %d material(s) of rarity ≥ %d" % [int(d.materials), int(d.material_rarity)]}
	return {"ok": true, "reason": ""}


## Draws one batch. Ink and materials are spent either way.
## Returns {ok, success, message, qty, levels}.
func draw(c: Character, sheet: StatSheet, rng: RandomNumberGenerator, talisman_id: String) -> Dictionary:
	var ck: Dictionary = check(c, talisman_id)
	if not ck.ok:
		return {"ok": false, "message": "Cannot draw: %s." % ck.reason}
	var cfg: Dictionary = config()
	var d: Dictionary = def(talisman_id)
	c.linh_thach -= int(d.ink_lt)
	MaterialBag.spend(c, _gd, _db, int(d.material_rarity), int(d.materials))
	var chance: float = success_chance(c, sheet, talisman_id).total
	var roll: float = rng.randf() * 100.0
	var out := {"ok": true, "success": roll < chance, "qty": 0, "levels": 0}
	var xp: float = float(d.xp)
	if out.success:
		out.qty = int(d.yield)
		_add(c, talisman_id, out.qty)
		out.message = "Success (%.0f%% vs roll %.0f): %d × %s." % [chance, roll, out.qty, d.name]
	else:
		xp *= float(cfg.fail_xp_fraction)
		out.message = "Failed (%.0f%% vs roll %.0f): the ink blots and the talisman paper burns." % [chance, roll]
	out.levels = c.add_skill_xp(str(cfg.skill), xp, float(cfg.xp_per_level), int(cfg.max_level))
	if out.levels > 0:
		out.message += " Phù lục rises to level %d." % c.skill_level(str(cfg.skill))
	return out


## Adds the talismans that help a check of [param check_type] ("combat", "breakthrough",
## or "stat" with [param evade]) to [param sheet]; with [param consume] one of each kind
## is used up.
## Returns the names applied.
static func apply_for_check(c: Character, gd: GameData, db: WorldDB, sheet: StatSheet, check_type: String, evade: bool, consume: bool) -> Array:
	var want: String = check_type if check_type in ["combat", "breakthrough"] else ("evade" if evade else "")
	if want == "" or db == null:
		return []
	var used: Array = []
	var seen: Dictionary = {}
	for it in db.items_of(c.id):
		if it.kind != "talisman" or seen.has(it.template):
			continue
		var d: Dictionary = def_of(gd, str(it.template))
		if str(d.get("use", "")) != want:
			continue
		seen[it.template] = true
		sheet.add_mod("Phù lục: %s" % d.name, str(d.stat), float(d.value))
		used.append(str(d.name))
		if consume:
			it["qty"] = int(it.qty) - 1
			if int(it.qty) <= 0:
				db.remove("items", it.id)
	return used


func _add(c: Character, talisman_id: String, qty: int) -> void:
	for it in _db.items_of(c.id):
		if it.kind == "talisman" and it.template == talisman_id:
			it["qty"] = int(it.qty) + qty
			return
	var t: Dictionary = _items.talisman(talisman_id, qty)
	t["owner_id"] = c.id
	_db.add("items", t)
