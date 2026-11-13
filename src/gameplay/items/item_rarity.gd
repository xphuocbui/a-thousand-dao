class_name ItemRarity
extends RefCounted
## The shared rarity ladder (item-database.md rule 7, Formulas A) and Lost-item decay (rule 14). Data: items_rarity.json.
##
## Usage:
## [codeblock]
## var r: int = ItemRarity.of(gd, item)                       # 1..rarity_max
## var gone: Array = ItemRarity.decay_lost(gd, db, year)       # removes decayed Lost items, returns them
## [/codeblock]


## An item's rarity: its kind's rank plus the kind's offset, clamped to 1..rarity_max.
static func of(gd: GameData, item: Dictionary) -> int:
	var cfg: Dictionary = gd.file("items_rarity")
	var kind: String = str(item.get("kind", ""))
	var rank: int = 1
	match kind:
		"herb":
			rank = int(gd.herb(str(item.get("template", ""))).get("rarity", item.get("rarity", 1)))
		"material":
			rank = int(gd.material(str(item.get("template", ""))).get("rarity", 1))
		"artifact":
			rank = int(item.get("grade", 0))
		"cong_phap":
			rank = int(item.get("tier", 0))
		"pill":
			var price: float = float(gd.recipe(str(item.get("template", ""))).get("price", 1))
			rank = 1
			for edge in cfg.pill_band_edges:
				if price > float(edge):
					rank += 1
		"talisman":
			rank = int(_talisman(gd, str(item.get("template", ""))).get("material_rarity", 1))
		"treasure":
			rank = int(_treasure(gd, str(item.get("template", ""))).get("rarity", 4))
	return clampi(rank + int(cfg.kind_offset.get(kind, 0)), 1, int(cfg.rarity_max))


## Whether a Lost item may decay at all: not named, bound or reserved, and under `lost_decay_rarity_max`.
static func can_decay(gd: GameData, item: Dictionary) -> bool:
	if str(item.get("named", "")) != "" or bool(item.get("bound", false)) or bool(item.get("reserved", false)):
		return false
	return of(gd, item) < int(gd.file("items_rarity").lost_decay_rarity_max)


## Removes every ordinary item Lost at a place for `lost_decay_years` or more by [param year]. Returns the removed
## records. An item Lost before tracking began (no `lost_since`) starts its count now.
static func decay_lost(gd: GameData, db: WorldDB, year: int) -> Array:
	var wait: int = int(gd.file("items_rarity").lost_decay_years)
	var gone: Array = []
	for item in db.find("items", func(i): return bool(i.get("lost", false))):
		if not item.has("lost_since"):
			item["lost_since"] = year
			continue
		if year - int(item.lost_since) >= wait and can_decay(gd, item):
			gone.append(item)
	for item in gone:
		db.remove("items", str(item.id))
	return gone


static func _talisman(gd: GameData, talisman_id: String) -> Dictionary:
	for t in gd.file("crafting_talismans").get("talismans", []):
		if str(t.id) == talisman_id:
			return t
	return {}


static func _treasure(gd: GameData, treasure_id: String) -> Dictionary:
	for t in gd.file("items_treasures").get("treasures", []):
		if str(t.id) == treasure_id:
			return t
	return {}
