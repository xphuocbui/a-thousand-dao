class_name BeastKeeper
extends RefCounted
## Linh thú: taming beasts beaten in a fight, feeding them yearly, and their loyalty.
## An owned beast is a people record with owner_id; its owner lists it in
## [member Character.beasts]. The world tick grows owned beasts (wild ones stay as they
## are), CombatPower adds a share of their power to the owner, and travel moves them
## along. Spec: design/quick-specs/phu-luc-linh-thu-thanh-tuu.md. Data: creatures_linh_thu.json.
##
## Usage:
## [codeblock]
## var keeper := BeastKeeper.new(gd, db)
## var chance: Breakdown = keeper.tame_chance(player, sheet, beast_id)
## var r: Dictionary = keeper.try_tame(player, sheet, rng, beast_id)   # {ok, tamed, message}
## var notes: Array = keeper.feed(player)                              # yearly
## [/codeblock]

var _gd: GameData
var _db: WorldDB


func _init(gd: GameData, db: WorldDB) -> void:
	_gd = gd
	_db = db


## creatures_linh_thu.json content.
func config() -> Dictionary:
	return _gd.file("creatures_linh_thu")


## How many beasts the character can keep (Thần hồn raises it).
func capacity(c: Character, sheet: StatSheet) -> int:
	var cfg: Dictionary = config()
	var extra: int = int(gd_extra_beasts(c))
	return extra + int(cfg.max_beasts_base) + int(sheet.effective("than_hon", c) / float(cfg.than_hon_per_extra_beast))


## Chance (0..1) to tame a beaten beast, as a breakdown.
func tame_chance(c: Character, sheet: StatSheet, beast_id: String) -> Breakdown:
	var t: Dictionary = config().tame
	var skill: String = str(config().skill)
	var b := Breakdown.new("Tame chance")
	b.base("Base", float(t.base))
	b.add("Thần hồn %d" % int(sheet.effective("than_hon", c)), (sheet.effective("than_hon", c) - float(t.than_hon_neutral)) * float(t.than_hon_per_point))
	b.add("Ngự thú level %d" % c.skill_level(skill), float(c.skill_level(skill)) * float(t.per_skill_level))
	b.clamp_to(float(t.min), float(t.max))
	return b


## Rolls to tame a beaten beast. Returns {ok, tamed, message}.
func try_tame(c: Character, sheet: StatSheet, rng: RandomNumberGenerator, beast_id: String) -> Dictionary:
	var rec: Dictionary = _db.get_record("people", beast_id)
	if rec.is_empty() or not rec.get("is_beast", false) or not rec.alive or str(rec.get("owner_id", "")) != "":
		return {"ok": false, "tamed": false, "message": ""}
	if c.beasts.size() >= capacity(c, sheet):
		return {"ok": true, "tamed": false, "message": "%s flees; you cannot keep more linh thú (Thần hồn limits you to %d)." % [rec.name, capacity(c, sheet)]}
	var chance: float = tame_chance(c, sheet, beast_id).total
	var roll: float = rng.randf()
	if roll >= chance:
		return {"ok": true, "tamed": false, "message": "%s escapes into the wilds (tame %.0f%%, roll %.0f)." % [rec.name, chance * 100.0, roll * 100.0]}
	tame(c, beast_id)
	return {"ok": true, "tamed": true, "message": "%s bows its head: it is your linh thú now (tame %.0f%%, roll %.0f)." % [rec.name, chance * 100.0, roll * 100.0]}


## Makes the beast the character's own (no roll). Returns {ok, message}.
func tame(c: Character, beast_id: String) -> Dictionary:
	var rec: Dictionary = _db.get_record("people", beast_id)
	if rec.is_empty() or not rec.get("is_beast", false):
		return {"ok": false, "message": "No beast %s." % beast_id}
	var cfg: Dictionary = config()
	rec["owner_id"] = c.id
	rec["loyalty"] = int(cfg.loyalty.start)
	rec["location_id"] = c.location_id
	if not c.beasts.has(beast_id):
		c.beasts.append(beast_id)
	c.add_skill_xp(str(cfg.skill), float(cfg.xp_per_tame), float(cfg.xp_per_level), int(cfg.max_level))
	return {"ok": true, "message": "%s is now your linh thú." % rec.name}


## Lets a beast go. Returns {ok, message}.
func release(c: Character, beast_id: String) -> Dictionary:
	if not c.beasts.has(beast_id):
		return {"ok": false, "message": "%s is not your linh thú." % beast_id}
	var rec: Dictionary = _db.get_record("people", beast_id)
	rec["owner_id"] = ""
	c.beasts.erase(beast_id)
	return {"ok": true, "message": "You release %s into the wilds." % rec.get("name", beast_id)}


## Living owned beast records.
func owned(c: Character) -> Array:
	return c.beasts.map(func(id): return _db.get_record("people", id)).filter(func(r): return not r.is_empty() and r.alive)


## Linh thạch a year to feed every owned beast.
func feed_cost(c: Character) -> int:
	var by_realm: Array = config().feed_lt_by_realm
	var total: int = 0
	for b in owned(c):
		total += int(by_realm[clampi(int(b.realm_index), 0, by_realm.size() - 1)])
	return total


## Yearly feeding: fed beasts gain loyalty, unfed ones lose it and leave at zero; dead
## beasts are dropped from the list. Returns lines for anything worth telling.
func feed(c: Character) -> Array:
	var cfg: Dictionary = config()
	var by_realm: Array = cfg.feed_lt_by_realm
	var lines: Array = []
	for id in c.beasts.duplicate():
		var b: Dictionary = _db.get_record("people", id)
		if b.is_empty() or not b.alive:
			c.beasts.erase(id)
			lines.append("Your linh thú %s has died." % b.get("name", id))
			continue
		var cost: int = int(by_realm[clampi(int(b.realm_index), 0, by_realm.size() - 1)])
		if c.linh_thach >= cost:
			c.linh_thach -= cost
			b["loyalty"] = mini(int(b.get("loyalty", 0)) + int(cfg.loyalty.fed_gain), int(cfg.loyalty.max))
			c.add_skill_xp(str(cfg.skill), float(cfg.xp_per_year_fed), float(cfg.xp_per_level), int(cfg.max_level))
			continue
		b["loyalty"] = int(b.get("loyalty", 0)) - int(cfg.loyalty.unfed_loss)
		if c.has_capability(16):
			b["loyalty"] = maxi(int(b.loyalty), int(_gd.capability(16).params.loyalty_floor))
		if int(b.loyalty) <= 0:
			b["owner_id"] = ""
			c.beasts.erase(id)
			lines.append("Unfed, %s turns wild and leaves you." % b.name)
		else:
			lines.append("%s goes hungry (needs %d linh thạch): loyalty %d." % [b.name, cost, int(b.loyalty)])
	return lines


## The owner's share of each owned beast's chiến lực: [{name, power}] (used by CombatPower).
static func power_shares(c: Character, gd: GameData, db: WorldDB) -> Array:
	if db == null or c.beasts.is_empty():
		return []
	var share: float = float(gd.file("creatures_linh_thu").power_share)
	var out: Array = []
	var strongest: int = -1
	for id in c.beasts:
		var b: Dictionary = db.get_record("people", id)
		if not b.is_empty() and b.alive and str(b.get("owner_id", "")) == c.id:
			out.append({"name": str(b.name), "power": float(b.get("power", 0.0)) * share})
			if strongest < 0 or float(out[-1].power) > float(out[strongest].power):
				strongest = out.size() - 1
	if c.has_capability(17) and strongest >= 0:
		out[strongest].power = float(out[strongest].power) / share
	return out


## Capability #16's extra beasts.
func gd_extra_beasts(c: Character) -> int:
	return int(_gd.capability(16).params.extra_beasts) if c.has_capability(16) else 0
