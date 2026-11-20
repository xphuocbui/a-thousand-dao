class_name MapWorks
extends RefCounted

## Works on the land and developed ground (design/gdd/travel-map.md rules 8, 31-34; Formulas B, J and M).
## Layers live on the place's qi:
## - qi.layer2: {work id: {level, unpaid, element}} shared works, built by whoever holds the place;
## - qi.prebuilt: the layer-2 upkept density a settlement or sect seat starts with (kept up by its holder);
## - qi.layer1: {person id: {work id: {level, unpaid, element}}} home works, for that person alone at their home.
## A residence (rule 34) is a person's grade at a settlement or seat; its furnishing is a fixed layer-1 density.
## Formula B adds each layer within its cap: density by min(c2p, permanent) + min(c2u, upkept) + min(c1p, ...) +
## min(c1u, ...), share pushes within 30 a layer (permanent 10 and upkept 20 on layer 2), and the match gain within
## m2 and m1; a home in a settlement or sect ground stays below settled_density_cap.
##
## Usage:
## [codeblock]
## var d: Dictionary = MapWorks.density(gd, place.qi, c)       # {l2, l1, lines}
## var r: Dictionary = MapWorks.build(gd, db, c, place, "spirit_grove")
## [/codeblock]

const DATA_FILE := "map_works"


static func cfg(gd: GameData) -> Dictionary:
	return gd.file(DATA_FILE)


static func work(gd: GameData, id: String) -> Dictionary:
	return cfg(gd).get("works", {}).get(id, {})


## Formula J: the linh thach a level-[param level] work costs, its materials and its seasons.
static func cost(gd: GameData, id: String, level: int) -> Dictionary:
	var w: Dictionary = work(gd, id)
	var seasons: int = int(w.get("seasons_per_level", 0)) * level if str(w.get("kind", "")) == "permanent" else 1
	return {"lt": int(round(float(w.get("cost_lt", 0)) * pow(float(w.get("cost_growth", 2.0)), float(level - 1)))),
		"materials": int(w.get("materials_per_level", 0)) * level, "rarity_min": int(w.get("rarity_min", 0)), "seasons": maxi(seasons, 1)}


## Formula B's density adds from layers 2 and 1 for [param c] at a place with [param qi]: {l2, l1, lines}.
static func density(gd: GameData, qi: Dictionary, c: Character, residence_grade: int = 0) -> Dictionary:
	var caps: Dictionary = cfg(gd).get("caps", {})
	var l2p: float = 0.0
	var l2u: float = float(qi.get("prebuilt", 0.0))
	var lines: Array = []
	if l2u > 0.0:
		lines.append("Layer 2: the ground's own works +%.2f" % l2u)
	for id in qi.get("layer2", {}):
		var w: Dictionary = work(gd, str(id))
		if str(w.get("stat", "")) != "density":
			continue
		var v: float = float(w.per_level) * float(qi.layer2[id].level)
		if str(w.kind) == "permanent":
			l2p += v
		else:
			l2u += v
	var l1p: float = 0.0
	var l1u: float = 0.0
	var mine: Dictionary = qi.get("layer1", {}).get(c.id, {}) if c != null else {}
	for id in mine:
		var w: Dictionary = work(gd, str(id))
		if str(w.get("stat", "")) != "density":
			continue
		var v: float = float(w.per_level) * float(mine[id].level)
		if str(w.kind) == "permanent":
			l1p += v
		else:
			l1u += v
	var furnish: float = 0.0
	if residence_grade > 0:
		furnish = float(cfg(gd).get("furnish_per_grade", 0.05)) * float(residence_grade)
		lines.append("Layer 1: residence grade %d furnishing" % residence_grade)
	var l2: float = minf(float(caps.get("c2p", 0.1)), l2p) + minf(float(caps.get("c2u", 0.5)), l2u)
	var l1: float = minf(float(caps.get("c1p", 0.1)), l1p) + minf(float(caps.get("c1u", 0.75)), l1u) + furnish
	return {"l2": l2, "l1": l1, "lines": lines}


## Formula B's match gains from the share works of layers 2 and 1 for [param c] (each layer within its share and
## match caps).
static func match_gain(gd: GameData, qi: Dictionary, c: Character) -> float:
	var caps: Dictionary = cfg(gd).get("caps", {})
	var mcfg: Dictionary = gd.file(LandQi.DATA_FILE).get("match", {})
	var k: float = float(mcfg.get("match_gain", 1.0))
	var unowned: float = float(mcfg.get("match_unowned_rate", 0.5))
	var gain: float = 0.0
	for layer in [2, 1]:
		var pushes := {}
		var works: Dictionary = qi.get("layer2", {}) if layer == 2 else qi.get("layer1", {}).get(c.id, {})
		for id in works:
			var w: Dictionary = work(gd, str(id))
			if str(w.get("stat", "")) != "share":
				continue
			var e: String = str(works[id].get("element", ""))
			pushes[e] = float(pushes.get(e, 0.0)) + float(w.per_level) * float(works[id].level)
		var cap_s: float = float(caps.get("share_l2" if layer == 2 else "share_l1", 30))
		var sum: float = 0.0
		for e in pushes:
			var p: float = c.linh_can.purity(str(e))
			if p <= 0.0:
				continue
			var owned: bool = c.linh_can.elements.has(str(e)) or c.linh_can.variants.has(str(e))
			sum += k * (1.0 if owned else unowned) * p / 100.0 * minf(cap_s, float(pushes[e])) / 100.0
		gain += minf(float(caps.get("match_l2" if layer == 2 else "match_l1", 0.15)), sum)
	return gain


## A site's production from its works (Formula H's G_f - 1): permanent within prod_perm, upkept within prod_upkept.
static func production_gain(gd: GameData, qi: Dictionary) -> float:
	var caps: Dictionary = cfg(gd).get("caps", {})
	var perm: float = 0.0
	var up: float = 0.0
	for id in qi.get("layer2", {}):
		var w: Dictionary = work(gd, str(id))
		if str(w.get("stat", "")) == "production":
			if str(w.kind) == "permanent":
				perm += float(w.per_level) * float(qi.layer2[id].level)
			else:
				up += float(w.per_level) * float(qi.layer2[id].level)
	return minf(float(caps.get("prod_perm", 0.15)), perm) + minf(float(caps.get("prod_upkept", 0.5)), up)


## Whether [param c] may build layer-2 works at [param place]: they hold it (their own abode) or lead its holder.
static func holds(db: WorldDB, c: Character, place: Dictionary) -> bool:
	if str(place.get("owner_id", "")) == c.id:
		return true
	var holder: String = str(place.get("holder", place.get("sect_id", "")))
	return holder != "" and holder == c.sect_id and c.sect_rank == "tong_chu"


## Builds (or raises) work [param id] at [param place] for [param c], paying linh thach and materials (rarity_min,
## of [param element] for a share work). Returns {ok, lines, seasons}: the caller passes the seasons.
static func build(gd: GameData, db: WorldDB, c: Character, place: Dictionary, id: String, element: String = "") -> Dictionary:
	var w: Dictionary = work(gd, id)
	if w.is_empty():
		return {"ok": false, "lines": ["No work '%s'. Works: %s." % [id, ", ".join(PackedStringArray(cfg(gd).works.keys()))]]}
	var layer: int = int(w.layer)
	if layer == 2 and not holds(db, c, place):
		return {"ok": false, "lines": ["Shared works are built by whoever holds the place; you do not hold %s." % place.name]}
	if layer == 1 and str(place.id) != c.home_id:
		return {"ok": false, "lines": ["Home works are built at your home."]}
	if str(w.stat) == "share" and element == "":
		return {"ok": false, "lines": ["Name the element to push (e.g. 'work build %s hoa')." % id]}
	if not place.has("qi"):
		return {"ok": false, "lines": ["This ground has no land qi to work."]}
	var store: Dictionary
	if layer == 2:
		if not place.qi.has("layer2"):
			place.qi["layer2"] = {}
		store = place.qi.layer2
	else:
		if not place.qi.has("layer1"):
			place.qi["layer1"] = {}
		if not place.qi.layer1.has(c.id):
			place.qi.layer1[c.id] = {}
		store = place.qi.layer1[c.id]
	var cur: int = int(store.get(id, {}).get("level", 0))
	if cur >= int(w.max):
		return {"ok": false, "lines": ["%s is at its highest level (%d)." % [w.name, int(w.max)]]}
	var lv: int = cur + 1
	var price: Dictionary = cost(gd, id, lv)
	if c.linh_thach < int(price.lt):
		return {"ok": false, "lines": ["Level %d of %s costs %d linh thạch; you have %d." % [lv, w.name, int(price.lt), c.linh_thach]]}
	var mats: Array = db.items_of(c.id).filter(func(it): return str(it.kind) == "material" and int(it.get("rarity", _rarity(gd, it))) >= int(price.rarity_min) and (str(w.stat) != "share" or str(it.get("element", "")) == element))
	var have: int = 0
	for m in mats:
		have += int(m.get("qty", 1))
	if have < int(price.materials):
		return {"ok": false, "lines": ["Level %d of %s needs %d units of materials of rarity %d or more%s; you have %d." % [lv, w.name, int(price.materials), int(price.rarity_min), (" (" + element + ")") if str(w.stat) == "share" else "", have]]}
	var need: int = int(price.materials)
	for m in mats:
		if need <= 0:
			break
		var take: int = mini(need, int(m.get("qty", 1)))
		m["qty"] = int(m.get("qty", 1)) - take
		need -= take
		if int(m.qty) <= 0:
			db.remove("items", str(m.id))
	c.linh_thach -= int(price.lt)
	store[id] = {"level": lv, "unpaid": 0, "element": element}
	if place.has("site"):
		place.site["works_prod"] = production_gain(gd, place.qi)
	return {"ok": true, "seasons": int(price.seasons), "lines": ["You build %s to level %d at %s (%d linh thạch%s, %d season(s))." % [w.name, lv, place.name, int(price.lt), (", %d materials" % int(price.materials)) if int(price.materials) > 0 else "", int(price.seasons)]]}


static func _rarity(gd: GameData, item: Dictionary) -> int:
	return int(gd.material(str(item.get("template", ""))).get("rarity", 1))


## Formula J upkeep for [param c]'s upkept works (layer 1 at home, layer 2 at places they hold) for one season,
## the Earth discount on layer 1; an unpaid work loses a level every fade_seasons unpaid seasons. Returns lines.
static func upkeep(gd: GameData, db: WorldDB, c: Character) -> Array:
	var lines: Array = []
	var cut: float = clampf(c.linh_can.purity("tho") * float(cfg(gd).get("tho_upkeep_cut_per_purity", 0.004)), 0.0, 0.9)
	for p in db.all("places"):
		var qi: Dictionary = p.get("qi", {})
		var sets: Array = []
		if qi.has("layer1") and qi.layer1.has(c.id):
			sets.append([1, qi.layer1[c.id]])
		if qi.has("layer2") and holds(db, c, p):
			sets.append([2, qi.layer2])
		for pair in sets:
			var works: Dictionary = pair[1]
			for id in works.keys():
				var w: Dictionary = work(gd, str(id))
				if str(w.get("kind", "")) != "upkept":
					continue
				var per: float = float(w.get("upkeep", 0))
				if w.has("upkeep_site_frac") and p.has("site"):
					per = float(w.upkeep_site_frac) * float(p.site.base_output)
				var bill: int = int(ceil(per * float(works[id].level) * ((1.0 - cut) if int(pair[0]) == 1 else 1.0)))
				if c.linh_thach >= bill:
					c.linh_thach -= bill
					works[id]["unpaid"] = 0
				else:
					works[id]["unpaid"] = int(works[id].get("unpaid", 0)) + 1
					if int(works[id].unpaid) >= int(w.get("fade_seasons", 2)):
						works[id]["unpaid"] = 0
						works[id]["level"] = int(works[id].level) - 1
						lines.append("  %s at %s fades to level %d (upkeep unpaid)." % [w.name, p.name, int(works[id].level)])
						if int(works[id].level) <= 0:
							works.erase(id)
	return lines


## Formula M: the season's rent of a grade-[param grade] residence at a place of stacked density [param d_res].
static func rent(gd: GameData, realm_index: int, d_res: float) -> int:
	var lt_max: float = float(gd.realm_budget(realm_index).get("linh_thach_max", 0))
	var core: float = float(gd.cultivation_rules().get("core_density_min", 1.4))
	return int(round(lt_max * float(cfg(gd).get("rent_frac", 0.02)) * d_res / core))


## Whether [param place] is settled ground (a settlement or sect seat, rule 33).
static func settled(gd: GameData, place: Dictionary) -> bool:
	return str(place.get("kind", "")) in cfg(gd).get("settled_kinds", [])
