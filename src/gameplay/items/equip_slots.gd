class_name EquipSlots
extends RefCounted
## Which slot each worn piece sits in (Item Database rule 11, user decision 2026-11-13).
##
## Every slot is free: no piece costs thần thức. Base slots are the same at every realm (`equip.base_slots`: 1 weapon,
## 1 armour, 2 rings, 1 necklace) and take a piece whose role fits (`equip.slot_roles`). Extra slots take any piece; how
## many there are (Formulas D, item slots):
##   extra = extra_slots_by_realm[r] + floor(than_thuc / (artifact_slot_sense_step · ds_ref[r])) + artifact_slots
## with no cap on the thần thức term. A thần thức or `artifact_slots` grant from a piece in an extra slot never counts
## toward the count (no piece opens its own slot); the same grant from a base-slot piece does. The player may pin a
## piece to a slot ([member Character.equip_slots]); an unpinned piece fills a fitting base slot first, then an extra
## slot, in equip order. Extra pieces past the count stay equipped but add nothing.
##
## Usage:
## [codeblock]
## var a: Dictionary = EquipSlots.assign(c, gd, db, sheet)
## a.slot_of[item_id]      # "weapon", "armour", "ring", "necklace" or "extra"
## a.extra                 # extra pieces that have a slot, in equip order
## a.unslotted             # pieces past the extra-slot count: worn, but they add nothing
## a.limit                 # how many extra slots there are
## [/codeblock]

const EXTRA := "extra"


## The roles a piece has: a named or rolled record's own `roles`, else its base's. A piece with no base has none,
## so it fits only an extra slot.
static func roles(gd: GameData, art: Dictionary) -> Array:
	if art.has("roles"):
		return art.roles
	return gd.artifact_base(str(art.get("base", ""))).get("roles", [])


## The base slot names, in the order an unpinned piece tries them.
static func base_slot_names(gd: GameData) -> Array:
	return gd.artifacts_file().equip.base_slots.keys()


## How many pieces a base slot holds (2 for rings).
static func base_slot_size(gd: GameData, slot: String) -> int:
	return int(gd.artifacts_file().equip.base_slots.get(slot, 0))


## Whether a piece may sit in [param slot]: an extra slot takes any piece, a base slot only a fitting role.
static func fits(gd: GameData, art: Dictionary, slot: String) -> bool:
	if slot == EXTRA:
		return true
	var allowed: Array = gd.artifacts_file().equip.slot_roles.get(slot, [])
	for r in roles(gd, art):
		if allowed.has(r):
			return true
	return false


## The realm's reference thần thức, ds_ref[r] (Combat Defence & Healing Formulas D): the reference talent × thần thức
## per point × the realm's thần thức multiplier (45 / 135 / 450 / 1,350 / 4,500).
static func sense_ref(c: Character, gd: GameData) -> float:
	var eq: Dictionary = gd.artifacts_file().equip
	return float(eq.sense_ref_talent) * float(gd.attributes().derived.than_thuc_per_than_hon) \
		* float(gd.realm(c.realm_index).than_thuc_mult)


## The thần thức one further extra slot takes: artifact_slot_sense_step × ds_ref[r].
static func sense_step(c: Character, gd: GameData) -> float:
	return float(gd.artifacts_file().equip.artifact_slot_sense_step) * sense_ref(c, gd)


## Thần thức as the slot count reads it: the sheet's, less any `than_thuc_pct` worn pieces put on the sheet, plus
## [param base_pct] (the `than_thuc_pct` of pieces in base slots).
static func slot_than_thuc(c: Character, gd: GameData, sheet: StatSheet, base_pct: float = 0.0) -> float:
	var ds: float = CharacterRules.than_thuc(c, gd, sheet).total
	var on_sheet: float = sheet.mult("than_thuc_pct")
	if on_sheet <= 0.0:
		return 0.0
	var pct: float = sheet.total_except_kind("than_thuc_pct", StatSheet.KIND_ITEM) + base_pct
	return ds / on_sheet * maxf(0.0, 1.0 + pct / 100.0)


## Extra slots: by realm, plus one per full sense step of thần thức (no cap), plus `artifact_slots` on [param sheet]
## (the sheet never carries the stat from worn pieces; see [method assign]), plus the slots of capabilities #2 and #3
## (#3's nurtured treasure is carried within the body, so it takes no slot).
static func extra_limit(c: Character, gd: GameData, sheet: StatSheet, base_pct: float = 0.0) -> int:
	var by_realm: Array = gd.artifacts_file().equip.extra_slots_by_realm
	var n: int = int(by_realm[clampi(c.realm_index, 0, by_realm.size() - 1)])
	if sheet != null:
		n += int(sheet.total("artifact_slots"))
		var step: float = sense_step(c, gd)
		if step > 0.0:
			n += int(floor(slot_than_thuc(c, gd, sheet, base_pct) / step + 1e-9))
	for cap in [2, 3]:
		if c.has_capability(cap):
			n += int(gd.capability(cap).params.get("slots", 0))
	return maxi(n, 0)


## Places every equipped piece. Pinned base pieces go first, then the rest in equip order; base-slot pieces may add
## `artifact_slots` and `than_thuc_pct` toward the count, extra pieces never do, and extra pieces past the count are
## unslotted. Returns {slot_of, base, extra, unslotted, limit}.
static func assign(c: Character, gd: GameData, db: WorldDB, sheet: StatSheet) -> Dictionary:
	var free: Dictionary = {}
	for slot in base_slot_names(gd):
		free[slot] = base_slot_size(gd, slot)
	var slot_of: Dictionary = {}
	var arts: Dictionary = {}
	for item_id in c.equipped:
		var art: Dictionary = db.get_record("items", item_id) if db != null else {}
		if not art.is_empty():
			arts[item_id] = art
	# Pinned base pieces first, so an earlier unpinned piece never takes a slot the player chose.
	for item_id in c.equipped:
		if not arts.has(item_id):
			continue
		var want: String = str(c.equip_slots.get(item_id, ""))
		if want != "" and want != EXTRA and int(free.get(want, 0)) > 0 and fits(gd, arts[item_id], want):
			slot_of[item_id] = want
			free[want] -= 1
	for item_id in c.equipped:
		if not arts.has(item_id) or slot_of.has(item_id):
			continue
		slot_of[item_id] = EXTRA
		if str(c.equip_slots.get(item_id, "")) == EXTRA:
			continue
		for slot in base_slot_names(gd):
			if int(free[slot]) > 0 and fits(gd, arts[item_id], slot):
				slot_of[item_id] = slot
				free[slot] -= 1
				break
	var base: Array = []
	var bonus: int = 0
	var base_pct: float = 0.0
	for item_id in c.equipped:
		if slot_of.get(item_id, EXTRA) != EXTRA:
			base.append(item_id)
			bonus += int(ItemStats.total(arts[item_id], "artifact_slots"))
			base_pct += ItemStats.total(arts[item_id], "than_thuc_pct")
	var limit: int = extra_limit(c, gd, sheet, base_pct) + bonus
	var extra: Array = []
	var unslotted: Array = []
	for item_id in c.equipped:
		if slot_of.get(item_id, "") != EXTRA:
			continue
		if extra.size() < limit:
			extra.append(item_id)
		else:
			unslotted.append(item_id)
	return {"slot_of": slot_of, "base": base, "extra": extra, "unslotted": unslotted, "limit": limit}


## The slot a new piece would take: [param wanted] if it fits and is free, else (when [param wanted] is empty) the
## first fitting free base slot, then an extra slot. Returns "" when nothing fits.
static func slot_for(c: Character, gd: GameData, db: WorldDB, sheet: StatSheet, art: Dictionary, wanted: String = "") -> String:
	var a: Dictionary = assign(c, gd, db, sheet)
	var used: Dictionary = {}
	for item_id in a.base:
		var s: String = a.slot_of[item_id]
		used[s] = int(used.get(s, 0)) + 1
	var extra_free: bool = a.extra.size() + a.unslotted.size() < int(a.limit)
	if wanted != "":
		if wanted == EXTRA:
			return EXTRA if extra_free else ""
		if not base_slot_names(gd).has(wanted) or not fits(gd, art, wanted):
			return ""
		return wanted if int(used.get(wanted, 0)) < base_slot_size(gd, wanted) else ""
	for slot in base_slot_names(gd):
		if int(used.get(slot, 0)) < base_slot_size(gd, slot) and fits(gd, art, slot):
			return slot
	return EXTRA if extra_free else ""


## The thần thức at which the next extra slot opens (for the equip panel and the Advisor).
static func next_slot_than_thuc(c: Character, gd: GameData, sheet: StatSheet) -> float:
	var step: float = sense_step(c, gd)
	var now: float = slot_than_thuc(c, gd, sheet)
	return (floor(now / step + 1e-9) + 1.0) * step if step > 0.0 else INF
