class_name MaterialBag
extends RefCounted
## Counting and spending a character's crafting materials by minimum rarity, cheapest
## first. Shared by trận pháp and phù lục (luyện khí picks per unit, see Refinery).
##
## Usage:
## [codeblock]
## if MaterialBag.count(c, gd, db, 2) >= 3:
##     MaterialBag.spend(c, gd, db, 2, 3)
## [/codeblock]


## Units of material owned with rarity ≥ [param rarity].
static func count(c: Character, gd: GameData, db: WorldDB, rarity: int) -> int:
	var n: int = 0
	for it in db.items_of(c.id):
		if it.kind == "material" and int(gd.material(str(it.template)).get("rarity", 0)) >= rarity:
			n += int(it.get("qty", 1))
	return n


## Spends [param qty] units of rarity ≥ [param rarity], cheapest first. Returns units spent.
static func spend(c: Character, gd: GameData, db: WorldDB, rarity: int, qty: int) -> int:
	var owned: Array = db.items_of(c.id).filter(func(i): return i.kind == "material" and int(gd.material(str(i.template)).get("rarity", 0)) >= rarity)
	owned.sort_custom(func(a, b): return int(gd.material(str(a.template)).base_value) < int(gd.material(str(b.template)).base_value))
	var left: int = qty
	for it in owned:
		if left <= 0:
			break
		var take: int = mini(int(it.get("qty", 1)), left)
		it["qty"] = int(it.get("qty", 1)) - take
		left -= take
		if int(it.qty) <= 0:
			db.remove("items", it.id)
	return qty - left
