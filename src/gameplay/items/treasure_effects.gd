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
static func use(c: Character, gd: GameData, db: WorldDB, rng: Variant, item_id: String, element: String = "") -> Dictionary:
	var item: Dictionary = db.get_record("items", item_id)
	if item.is_empty() or item.owner_id != c.id or item.kind != "treasure":
		return {"ok": false, "message": "You have no treasure %s." % item_id, "changes": []}
	var def: Dictionary = gd.treasure(str(item.template))
	var fx: Dictionary = def.get("effect", {})
	var msg: String = ""
	var changes: Array = []
	match str(fx.get("type", "")):
		"add_element":
			var missing: Array = gd.element_cycle().filter(func(e): return not c.linh_can.elements.has(e))
			if not missing.is_empty() and not missing.has(element):
				return {"ok": false, "needs_element": true, "options": missing, "message": "", "changes": []}
			var r: Dictionary = apply_fruit(c, gd, rng, fx, element)
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


## What each pick would do (linh-can.md UI): tier, n_eff, curve factor, pair bonus and the
## derived variants it would make eligible. The added purity stays a roll, 20-35.
static func preview_lines(c: Character, gd: GameData, options: Array, item_id: String) -> Array:
	var lc: LinhCan = c.linh_can
	var pair: int = int(gd.attributes().linh_can.pair_bonus_pct)
	var before: float = CultivationRules.curve_factor(c, gd)
	var lines: Array = ["Choose the element this fruit grows (purity 20-35): use %s <element>" % item_id]
	for e in options:
		var next: LinhCan = LinhCan.from_dict(lc.to_dict())
		next.add_element(str(e), int(gd.attributes().linh_can.purity_mean))
		c.linh_can = next
		var after: float = CultivationRules.curve_factor(c, gd)
		c.linh_can = lc
		var eligible: Array = []
		for def in gd.variant_defs():
			var id: String = str(def.id)
			if not next.rolled.has(id) and not next.declined.has(id) and next.requirement_met(gd, id):
				eligible.append(gd.element_label(id))
		lines.append("  %-5s %s: %s -> %s, row %d -> %d, speed x%.2f -> x%.2f, pairs +%d%% -> +%d%%%s" % [e, gd.element_label(str(e)), lc.tier_name(gd), next.tier_name(gd), lc.n_eff(gd), next.n_eff(gd), before, after, pair * lc.generating_pairs(gd).size(), pair * next.generating_pairs(gd).size(), (", may form " + ", ".join(eligible)) if not eligible.is_empty() else ""])
	return lines


## Applies a Linh Căn Quả to [param c]. Draw order (Formulas F): element (an NPC's only; the
## player picks), purity, then one per newly eligible derived variant. With
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
