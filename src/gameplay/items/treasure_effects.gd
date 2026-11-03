class_name TreasureEffects
extends RefCounted
## Using rare treasures (items_treasures.json). Linh Căn Quả grows a new base element
## (or strengthens one when all five are owned); afterwards biến dị are re-checked by
## the normal rule, so a new pair may mutate. Design: game-concept.md § Changing linh căn.
##
## Usage:
## [codeblock]
## var r: Dictionary = TreasureEffects.use(player, gd, db, rng, item_id)   # {ok, message}
## [/codeblock]


## Uses one treasure from the player's possessions. Returns {ok, message}.
static func use(c: Character, gd: GameData, db: WorldDB, rng: RandomNumberGenerator, item_id: String) -> Dictionary:
	var item: Dictionary = db.get_record("items", item_id)
	if item.is_empty() or item.owner_id != c.id or item.kind != "treasure":
		return {"ok": false, "message": "You have no treasure %s." % item_id}
	var def: Dictionary = gd.treasure(str(item.template))
	var fx: Dictionary = def.get("effect", {})
	var msg: String = ""
	match str(fx.get("type", "")):
		"add_element":
			var elem: String = str(item.get("element", ""))
			var missing: Array = gd.element_cycle().filter(func(e): return not c.linh_can.elements.has(e))
			if elem == "" or c.linh_can.elements.has(elem):
				elem = str(RngUtils.pick(rng, missing)) if not missing.is_empty() else elem
			if elem != "" and not c.linh_can.elements.has(elem):
				var p: int = rng.randi_range(int(fx.purity[0]), int(fx.purity[1]))
				c.linh_can.add_element(elem, p)
				msg = "A new spiritual root grows: %s %d. You are now %s." % [gd.element_name(elem), p, c.linh_can.tier_name()]
			else:
				var target: String = elem if elem != "" else c.linh_can.weakest_element()
				var before: int = int(c.linh_can.purity(target))
				c.linh_can.raise_purity(target, int(fx.raise))
				msg = "Your %s root deepens: %d -> %d." % [gd.element_name(target), before, int(c.linh_can.purity(target))]
			msg += new_bien_di_text(c, gd, rng)
		_:
			return {"ok": false, "message": "%s has no use yet." % item.name}
	db.remove("items", item_id)
	return {"ok": true, "message": "You consume %s. %s" % [item.name, msg]}


## Re-checks biến dị after the root changed; returns " Biến dị: X!" for new ones, or "".
static func new_bien_di_text(c: Character, gd: GameData, rng: RandomNumberGenerator) -> String:
	var before: Array = c.linh_can.bien_di.keys()
	c.linh_can.derive_bien_di(gd, rng)
	var fresh: Array = c.linh_can.bien_di.keys().filter(func(b): return not before.has(b))
	if fresh.is_empty():
		return ""
	return " Biến dị awakens: %s!" % ", ".join(fresh.map(func(b): return "%s %d" % [gd.bien_di(b).name, int(c.linh_can.bien_di[b])]))
