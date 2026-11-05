class_name TreasureEffects
extends RefCounted
## Using rare treasures (items_treasures.json). Linh Căn Quả grows a new base element, or
## raises the weakest one when all five are owned; a new element lets the derived variants it
## makes eligible roll once. Design: design/gdd/linh-can.md rule 13, Formulas F.
##
## Usage:
## [codeblock]
## var r: Dictionary = TreasureEffects.use(player, gd, db, rng, item_id)   # {ok, message, changes}
## [/codeblock]


## Uses one treasure from the player's possessions. Returns {ok, message, changes}. A refused
## treasure is kept.
static func use(c: Character, gd: GameData, db: WorldDB, rng: Variant, item_id: String) -> Dictionary:
	var item: Dictionary = db.get_record("items", item_id)
	if item.is_empty() or item.owner_id != c.id or item.kind != "treasure":
		return {"ok": false, "message": "You have no treasure %s." % item_id, "changes": []}
	var def: Dictionary = gd.treasure(str(item.template))
	var fx: Dictionary = def.get("effect", {})
	var msg: String = ""
	var changes: Array = []
	match str(fx.get("type", "")):
		"add_element":
			var r: Dictionary = apply_fruit(c, gd, rng, fx, str(item.get("element", "")))
			if not r.ok:
				return {"ok": false, "message": "%s can do nothing for a root already perfect." % item.name, "changes": []}
			msg = r.message
			changes = r.changes
		"unseal_item":
			return {"ok": true, "message": "", "changes": [], "unseal_item": item_id}
		_:
			return {"ok": false, "message": "%s has no use yet." % item.name, "changes": []}
	db.remove("items", item_id)
	return {"ok": true, "message": "You consume %s. %s" % [item.name, msg], "changes": changes}


## Applies a Linh Căn Quả to [param c]. Draw order (Formulas F): element (skipped when the
## event names a valid missing one), purity, then one per newly eligible derived variant. With
## all five owned the weakest gains the raise, no draws; refused when all are at 100.
## Returns {ok, message, changes}, where changes are {what, id, from, to} for the World Database.
static func apply_fruit(c: Character, gd: GameData, rng: Variant, fx: Dictionary, named: String = "") -> Dictionary:
	var lc: LinhCan = c.linh_can
	var missing: Array = gd.element_cycle().filter(func(e): return not lc.elements.has(e))
	if missing.is_empty():
		if lc.all_at_max():
			return {"ok": false, "message": "", "changes": []}
		var target: String = lc.weakest_element(gd)
		var before: int = int(lc.purity(target))
		lc.raise_purity(gd, target, int(fx.raise))
		return {"ok": true, "message": "Your %s root deepens: %d -> %d." % [gd.element_label(target), before, int(lc.purity(target))],
			"changes": [{"what": "purity", "id": target, "from": before, "to": int(lc.purity(target))}]}
	var elem: String = named if missing.has(named) else str(missing[int(floorf(rng.randf() * float(missing.size())))])
	var lo: int = int(fx.purity[0])
	var p: int = lo + int(floorf(rng.randf() * float(int(fx.purity[1]) - lo + 1)))
	lc.add_element(elem, p)
	var changes: Array = [{"what": "element", "id": elem, "from": 0, "to": p}]
	var msg: String = "A new spiritual root grows: %s %d. You are now %s." % [gd.element_label(elem), p, lc.tier_name(gd)]
	var formed: Array = lc.roll_newly_eligible(gd, rng)
	msg += variants_text(gd, lc, formed)
	for id in formed:
		changes.append({"what": "variant", "id": id, "from": 0, "to": int(lc.variants[id])})
	return {"ok": true, "message": msg, "changes": changes}


## " A variant root forms: X 47!" for the ids given, or "".
static func variants_text(gd: GameData, lc: LinhCan, ids: Array) -> String:
	if ids.is_empty():
		return ""
	return " A variant root forms: %s!" % ", ".join(ids.map(func(b): return "%s %d" % [gd.element_label(b), int(lc.variants[b])]))
