class_name WikiData
extends RefCounted
## The in-game wiki's content (design/ux/wiki.md), read from the data files only: glossary terms (ui_terms.json),
## traits (traits.json: personality, callings, fate, gained), realms (cultivation_realms.json), elements
## (character_elements.json) and tie kinds (ui_windows.json tie_kinds). No session state is read, so a view can be
## built at any time. Keys: "term:<id>", "trait:<id>", "realm:<index>", "element:<id>", "tie:<kind>",
## "item:<kind>_<template>" (the item templates with a painted icon: artifact bases, herbs, materials, pills, talismans,
## treasures); a bare term id (from a tooltip) resolves to "term:<id>". Entries carry "icon" (a res:// path or "").

const TRAIT_GROUPS := [["personality", "Personality traits"], ["callings", "Callings"], ["fate", "Fate traits"], ["gained", "Gained traits"]]
## Item templates by kind: [kind, data file, list key, category title] (the items with a painted icon,
## tools/asset-pipeline/icons/gen_item_icons.py).
const ITEM_GROUPS := [["artifact", "items_artifacts", "bases", "Artifacts"], ["pill", "items_recipes", "recipes", "Pills"],
	["herb", "items_herbs", "herbs", "Herbs"], ["material", "items_materials", "materials", "Materials"],
	["talisman", "crafting_talismans", "talismans", "Talismans"], ["treasure", "items_treasures", "treasures", "Treasures"]]


## The painted icon of item template [param kind]_[param id], or "placeholder" when its file is missing (the window
## then shows PlaceholderArt; entries that never have art, like terms and realms, carry "").
static func item_icon(kind: String, id: String) -> String:
	var p: String = "res://assets/icons/items/%s_%s.png" % [kind, id]
	return p if ResourceLoader.exists(p) else "placeholder"   # should have art: the window shows the stripes


## The trait medallion of [param id], or "placeholder" when its file is missing.
static func trait_icon(id: String) -> String:
	var p: String = "res://assets/icons/traits/%s.png" % id
	return p if ResourceLoader.exists(p) else "placeholder"


## The view for [param key]: "" (the index) -> {index: true, categories}; an entry -> {key, category, title, name_vi,
## summary, body (segments), facts, links}; an unknown key -> {unknown: true, key}.
static func view(gd: GameData, key: String) -> Dictionary:
	if key == "":
		return {"index": true, "categories": categories(gd)}
	var k: String = key if key.contains(":") else "term:" + key
	var kind: String = k.get_slice(":", 0)
	var id: String = k.substr(kind.length() + 1)
	match kind:
		"term":
			var t: Dictionary = gd.file("ui_terms").get("terms", {}).get(id, {})
			if not t.is_empty():
				return {"key": k, "category": "Term", "title": str(t.get("title", id)), "name_vi": "", "summary": str(t.get("summary", "")),
					"body": TooltipLayer.parse_body(str(t.get("body", ""))), "facts": [], "links": []}
		"trait":
			for g in TRAIT_GROUPS:
				for t in Array(gd.file("traits").get(str(g[0]), [])):
					if str(t.get("id", "")) == id:
						return _trait_entry(gd, k, str(g[1]), t)
		"realm":
			var realms: Array = gd.realms()
			var i: int = int(id)
			if id.is_valid_int() and i >= 0 and i < realms.size():
				var r: Dictionary = realms[i]
				var band: Array = Ladder.band(gd, i)
				var facts: Array = ["Levels %d–%d" % [int(band[0]), int(band[1])]]
				if r.has("lifespan"):
					facts.append("Lifespan %s years" % str(r.lifespan))
				return {"key": k, "category": "Realm", "title": str(r.get("name", "")), "name_vi": str(r.get("name_han", "")),
					"summary": str(r.get("desc", r.get("description", ""))), "body": [], "facts": facts,
					"links": ([{"key": "realm:%d" % (i - 1), "title": "← " + str(realms[i - 1].name)}] if i > 0 else []) + ([{"key": "realm:%d" % (i + 1), "title": str(realms[i + 1].name) + " →"}] if i + 1 < realms.size() else [])}
		"element":
			var e: Dictionary = gd.element(id)
			if not e.is_empty():
				return {"key": k, "category": "Element", "title": gd.element_name(id), "name_vi": "", "summary": str(e.get("role_desc", "")),
					"body": [], "facts": [], "links": []}
		"item":
			for g in ITEM_GROUPS:
				if not id.begins_with(str(g[0]) + "_"):
					continue
				var tid: String = id.substr(str(g[0]).length() + 1)
				for t in Array(gd.file(str(g[1])).get(str(g[2]), [])):
					if str(t.get("id", "")) == tid:
						var facts: Array = []
						if t.has("base_value") or t.has("price"):
							facts.append("Value: %s linh thạch" % str(t.get("base_value", t.get("price", ""))))
						if str(t.get("element", "")) != "":
							facts.append("Element: " + gd.element_name(str(t.element)))
						return {"key": k, "category": str(g[3]).trim_suffix("s"), "title": str(t.get("name", tid)), "name_vi": "",
							"summary": str(t.get("desc", "")), "body": [], "facts": facts, "links": [], "icon": item_icon(str(g[0]), tid)}
		"tie":
			var tk: Array = Array(gd.file("ui_windows").get("tie_kinds", {}).get(id, []))
			if not tk.is_empty():
				return {"key": k, "category": "Tie", "title": "%s %s" % [str(tk[0]), str(tk[1])], "name_vi": str(tk[2]), "summary": "", "body": [],
					"facts": ["A tie between two people (NPC Relationships): see your relationships page."], "links": []}
	return {"unknown": true, "key": k}


## The index: every category with its entries ({key, title, name_vi, summary}).
static func categories(gd: GameData) -> Array:
	var out: Array = []
	var terms: Array = []
	var td: Dictionary = gd.file("ui_terms").get("terms", {})
	for id in td:
		terms.append({"key": "term:" + str(id), "title": str(td[id].get("title", id)), "name_vi": "", "summary": str(td[id].get("summary", ""))})
	out.append({"id": "terms", "title": "Terms", "entries": terms})
	for g in TRAIT_GROUPS:
		var rows: Array = []
		for t in Array(gd.file("traits").get(str(g[0]), [])):
			rows.append({"key": "trait:" + str(t.id), "title": str(t.get("name", t.id)), "name_vi": str(t.get("name_vi", "")), "summary": "",
				"icon": trait_icon(str(t.id))})
		out.append({"id": str(g[0]), "title": str(g[1]), "entries": rows})
	var realms: Array = []
	var rl: Array = gd.realms()
	for i in rl.size():
		realms.append({"key": "realm:%d" % i, "title": str(rl[i].get("name", "")), "name_vi": "", "summary": ""})
	out.append({"id": "realms", "title": "Realms", "entries": realms})
	var els: Array = []
	for e in gd.element_cycle():
		els.append({"key": "element:" + str(e), "title": gd.element_name(e), "name_vi": "", "summary": str(gd.element(e).get("role_desc", ""))})
	out.append({"id": "elements", "title": "Elements", "entries": els})
	var ties: Array = []
	var tk: Dictionary = gd.file("ui_windows").get("tie_kinds", {})
	for k in tk:
		if str(k).begins_with("_"):
			continue
		ties.append({"key": "tie:" + str(k), "title": "%s %s" % [str(tk[k][0]), str(tk[k][1])], "name_vi": str(tk[k][2]), "summary": ""})
	out.append({"id": "ties", "title": "Ties", "entries": ties})
	for g in ITEM_GROUPS:
		var items: Array = []
		for t in Array(gd.file(str(g[1])).get(str(g[2]), [])):
			if not (t is Dictionary) or str(t.get("id", "")) == "":
				continue
			items.append({"key": "item:%s_%s" % [str(g[0]), str(t.id)], "title": str(t.get("name", t.id)), "name_vi": "",
				"summary": str(t.get("desc", "")), "icon": item_icon(str(g[0]), str(t.id))})
		out.append({"id": "items_" + str(g[0]), "title": str(g[3]), "entries": items})
	return out


static func _trait_entry(gd: GameData, key: String, group: String, t: Dictionary) -> Dictionary:
	var facts: Array = []
	for b in Array(t.get("boon", [])):
		facts.append("Boon: " + gd.format_mod(str(b.stat), float(b.value)))
	for c in Array(t.get("cost", [])):
		facts.append("Cost: " + gd.format_mod(str(c.stat), float(c.value)))
	for r in Array(t.get("rows", [])):
		facts.append(gd.format_mod(str(r.stat), float(r.value)))
	var tags: Dictionary = t.get("tags", {})
	var more: Array = []
	var less: Array = []
	for tag in tags:
		(more if float(tags[tag]) >= 1.0 else less).append(str(tag))
	if not more.is_empty() or not less.is_empty():
		facts.append("Leans: %s%s" % [", ".join(more), ("; less " + ", ".join(less)) if not less.is_empty() else ""])
	if t.has("set"):
		facts.append("Personality set %d" % int(t.set))
	if str(t.get("pair", "")) != "":
		facts.append("Pair: " + str(t.pair))
	if str(t.get("world_price", "")) != "":
		facts.append("The world's price: " + str(t.world_price))
	if str(t.get("trigger", "")) != "":
		facts.append("Gained by: " + str(t.trigger).replace("_", " "))
	if str(t.get("grade", "")) != "":
		facts.append("Grade: " + str(t.grade))
	var links: Array = []
	if str(t.get("opposed", "")) != "":
		links.append({"key": "trait:" + str(t.opposed), "title": "Opposed: " + str(t.opposed)})
	return {"key": key, "category": group.trim_suffix("s"), "title": str(t.get("name", t.get("id", ""))), "name_vi": str(t.get("name_vi", "")),
		"summary": "", "body": [], "facts": facts, "links": links, "icon": trait_icon(str(t.get("id", "")))}
