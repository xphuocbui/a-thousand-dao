class_name MapProduction
extends RefCounted

## Resource sites, production and reserves (design/gdd/travel-map.md rules 19-22 and 25, Formulas H, I and L). A site
## is a place of a site kind (map_resources.json); WorldBuilder gives it its resource, grade, base output and start
## reserve ([method init_site]); every season the world tick runs [method season]: each site produces Formula H's
## amount, its reserve moves by Formula I, and the production contract (totals per region and territory, with the
## population) is published on the region records for Regional Economy & Trade (#43), which does not exist yet: until
## it does, nothing consumes the production and the Market works as built (rule 25).
##
## Usage:
## [codeblock]
## MapProduction.season(gd, db)   # once a season
## print(db.get_record("regions", "r3").production)
## [/codeblock]

const DATA_FILE := "map_resources"


static func _cfg(gd: GameData) -> Dictionary:
	return gd.file(DATA_FILE)


## Rule 20: the resource a site yields: {resource, kind}. An authored resource (a mine's name, a lair's or special
## site's good) takes its kind from map_resources.json's resource_kind (ore when unlisted); otherwise the land decides
## between linh thạch and its top element's ore.
static func site_resource(gd: GameData, place: Dictionary) -> Dictionary:
	var cfg: Dictionary = _cfg(gd)
	if str(place.get("resource", "")) != "":   # authored by the mine's name (user decision 2026-11-20)
		var r: String = str(place.resource)
		return {"resource": r, "kind": str(cfg.get("resource_kind", {}).get(r, "ore"))}
	var shares: Dictionary = place.get("qi", {}).get("shares", {})
	var land: float = float(place.get("qi", {}).get("land_density", place.get("density", 1.0)))
	var em: float = float(shares.get("tho", 0.0)) + float(shares.get("kim", 0.0))
	if str(place.get("kind", "")) == "spirit_vein" or (land >= float(cfg.linh_thach_density_min) and em >= float(cfg.linh_thach_shares_min)):
		return {"resource": "linh_thach", "kind": "linh_thach"}
	var top: String = "tho"
	for e in shares:
		if float(shares[e]) > float(shares.get(top, 0.0)):
			top = str(e)
	return {"resource": str(cfg.ore_by_element.get(top, "tinh_thiet")), "kind": "ore"}


## The site record WorldBuilder stores on a place: resource, grade, base output (Formula H) and reserve (Formula I),
## the start reserve picked by [param pick] (an index into reserve_start_choices).
static func init_site(gd: GameData, place: Dictionary, pick: int) -> Dictionary:
	var cfg: Dictionary = _cfg(gd)
	var res: Dictionary = site_resource(gd, place)
	var land: float = float(place.get("qi", {}).get("land_density", place.get("density", 1.0)))
	var grade: String = "small"
	for g in cfg.grade_by_density:
		if land >= float(g[0]):
			grade = str(g[1])
			break
	var base: float = float(cfg.site_grade_value[grade]) * float(cfg.kind_value_mult[res.kind]) / maxf(1.0, float(cfg.unit_value.get(res.resource, 1)))
	var rmax: float = float(cfg.reserve_seasons) * base
	var choices: Array = cfg.reserve_start_choices
	return {"resource": res.resource, "kind": res.kind, "grade": grade, "base_output": snappedf(base, 0.01),
		"reserve_max": snappedf(rmax, 0.01), "reserve": snappedf(rmax * float(choices[clampi(pick, 0, choices.size() - 1)]), 0.01),
		"worked": true, "last_output": 0.0}


## A herb site on a place that holds herb grounds (Travel & Map rule 20's herb ground kind; Trade Goods rule 5): its
## Formula H value of herbs a season by its grade (land density), shared among the grounds' herbs by Trade Goods
## Formula A ([method herb_split]); reserve and recovery as any site.
static func init_herb_site(gd: GameData, place: Dictionary, pick: int) -> Dictionary:
	var cfg: Dictionary = _cfg(gd)
	var land: float = float(place.get("qi", {}).get("land_density", place.get("density", 1.0)))
	var grade: String = "small"
	for g in cfg.grade_by_density:
		if land >= float(g[0]):
			grade = str(g[1])
			break
	var base: float = float(cfg.site_grade_value[grade]) * float(cfg.kind_value_mult.herb)
	var rmax: float = float(cfg.reserve_seasons) * base
	var choices: Array = cfg.reserve_start_choices
	return {"resource": "herb", "kind": "herb", "grade": grade, "base_output": snappedf(base, 0.01),
		"reserve_max": snappedf(rmax, 0.01), "reserve": snappedf(rmax * float(choices[clampi(pick, 0, choices.size() - 1)]), 0.01),
		"worked": true, "last_output": 0.0}


## Formula H2's record for a settlement: its population P = w_size · livability, the herbs that fit it ([param herbs],
## {herb, fit}) and the ore of its strongest base element with that element's share.
static func init_local(gd: GameData, place: Dictionary, herbs: Array) -> Dictionary:
	var cfg: Dictionary = _cfg(gd)
	var so: Dictionary = cfg.get("settlement_output", {})
	var liv: float = float(place.get("livability", 0.0))
	if liv <= 0.0:   # places the map tools laid without a livability (sect seats, history sites) count as average land
		liv = float(so.get("livability_default", 1.0))
	var pop: float = float(so.get("w_size", {}).get(str(place.get("kind", "")), 0.0)) * liv
	var shares: Dictionary = place.get("qi", {}).get("shares", {})
	var top: String = ""
	for e in ["moc", "hoa", "tho", "kim", "thuy"]:
		if top == "" or float(shares.get(e, 0.0)) > float(shares.get(top, 0.0)):
			top = e
	return {"pop": snappedf(pop, 0.001), "herbs": herbs, "ore": str(cfg.ore_by_element.get(top, "tinh_thiet")),
		"s_top": float(shares.get(top, 0.0)), "last_herbs": {}, "last_ore": 0.0}


## Formula H2: a settlement's herb value and ore value this season, before the split among herbs, times D_f.
static func local_output(gd: GameData, db: WorldDB, place: Dictionary) -> Dictionary:
	var cfg: Dictionary = _cfg(gd)
	var so: Dictionary = cfg.get("settlement_output", {})
	var loc: Dictionary = place.get("local", {})
	var omega: float = float(cfg.get("rarity_weight", 0.5))
	var land: float = float(place.get("qi", {}).get("land_density", place.get("density", 1.0)))
	var wsum: float = 0.0
	for g in loc.get("herbs", []):
		wsum += float(g.fit) * pow(omega, int(gd.herb(str(g.herb)).get("rarity", 1)) - 1)
	var base: float = float(loc.get("pop", 0.0)) * land
	var d_herb: float = clampf(1.0 + float(cfg.demand_elasticity) * (_price_index(db, place, "herb") - 1.0), float(cfg.demand_min), float(cfg.demand_max))
	var d_ore: float = clampf(1.0 + float(cfg.demand_elasticity) * (_price_index(db, place, "ore") - 1.0), float(cfg.demand_min), float(cfg.demand_max))
	return {"herb": floor(float(so.get("h_s", 0.0)) * base * wsum * d_herb + 0.5),
		"ore": floor(float(so.get("o_s", 0.0)) * base * float(loc.get("s_top", 0.0)) / 100.0 * d_ore + 0.5)}


## Trade Goods Formula A: [param value] split among the herbs of [param grounds] ({herb, fit}) by w = fit · ω^(rarity − 1),
## in whole base value by largest remainder (ties to the lower herb id), so the parts sum to [param value] exactly.
static func herb_split(gd: GameData, grounds: Array, value: int) -> Dictionary:
	var omega: float = float(_cfg(gd).get("rarity_weight", 0.5))
	var ws := []
	var total: int = 0
	for g in grounds:
		var h: Dictionary = gd.herb(str(g.herb))
		var w: int = int(round(float(g.fit) * pow(omega, int(h.get("rarity", 1)) - 1) * 1000000.0))
		ws.append([str(g.herb), w])
		total += w
	var out := {}
	if total <= 0 or value <= 0:
		return out
	var rems := []
	var given: int = 0
	for e in ws:
		var part: int = (value * int(e[1])) / total
		out[e[0]] = part
		given += part
		rems.append([(value * int(e[1])) % total, e[0]])
	rems.sort_custom(func(a, b): return a[0] > b[0] or (a[0] == b[0] and str(a[1]) < str(b[1])))
	for i in value - given:
		out[rems[i][1]] = int(out[rems[i][1]]) + 1
	return out


## Trade Goods Formula A for a beast lair: its [param value] shared among the beast goods (bone, hide, demon cores) by
## ω^(rarity − 1), whole base value by largest remainder; any other site keeps its one [param resource].
static func kind_split(gd: GameData, kind: String, resource: String, value: int) -> Dictionary:
	if kind != "beast" or value <= 0:
		return {resource: value}
	var rk: Dictionary = _cfg(gd).get("resource_kind", {})
	var grounds: Array = []
	for g in rk:
		if str(rk[g]) == "beast" and not gd.material(str(g)).is_empty():
			grounds.append(str(g))
	grounds.sort()
	var omega: float = float(_cfg(gd).get("rarity_weight", 0.5))
	var ws := []
	var total: int = 0
	for g in grounds:
		var w: int = int(round(pow(omega, int(gd.material(g).get("rarity", 1)) - 1) * 1000000.0))
		ws.append([g, w])
		total += w
	if total <= 0:
		return {resource: value}
	var out := {}
	var given: int = 0
	var rems := []
	for e in ws:
		var part: int = (value * int(e[1])) / total
		out[e[0]] = part
		given += part
		rems.append([(value * int(e[1])) % total, e[0]])
	rems.sort_custom(func(a, b): return a[0] > b[0] or (a[0] == b[0] and str(a[1]) < str(b[1])))
	for i in value - given:
		out[rems[i][1]] = int(out[rems[i][1]]) + 1
	return out


## Formula I's reserve factor for r = reserve / reserve_max.
static func reserve_factor(gd: GameData, r: float) -> float:
	var floor_v: float = float(_cfg(gd).reserve_floor)
	if r >= 0.80:
		return 1.0
	if r >= 0.30:
		return 0.70 + 0.30 * (r - 0.30) / 0.50
	return 0.25 + 0.45 * maxf(0.0, r - floor_v) / (0.30 - floor_v)


## Formula H for a site at [param place] with its labour factor [param settle_w]: {output, factors}.
static func production(gd: GameData, place: Dictionary, settle_w: float, price_index: float = 1.0) -> Dictionary:
	var cfg: Dictionary = _cfg(gd)
	var site: Dictionary = place.get("site", {})
	if site.is_empty():
		return {"output": 0.0}
	var r: float = float(site.reserve) / maxf(1.0, float(site.reserve_max))
	var r_f: float = reserve_factor(gd, r)
	var owner_w: float = float(cfg.owner_w.worked if str(place.get("holder", "")) != "" and bool(site.get("worked", true)) else (cfg.owner_w.rested if str(place.get("holder", "")) != "" else cfg.owner_w.wild))
	var d_f: float = clampf(1.0 + float(cfg.demand_elasticity) * (price_index - 1.0), float(cfg.demand_min), float(cfg.demand_max))
	var s_f: float = clampf(float(site.get("scar", 1.0)), 0.0, float(cfg.scar_max))
	var g_f: float = 1.0 + float(site.get("works_prod", 0.0))
	if int(site.get("spoils", 0)) > 0:   # Sects F9: a captured site produces at spoils_mult while its spoils last
		g_f *= float(cfg.get("spoils_mult", 0.5))
	var mult: float = minf(r_f * settle_w * owner_w * d_f * s_f * g_f, float(cfg.prod_mult_cap))
	return {"output": floor(float(site.base_output) * mult + 0.5 + 1e-6), "r_f": r_f, "w_f": settle_w * owner_w, "d_f": d_f, "s_f": s_f, "g_f": g_f}


# Formula H's price_index for a site of [param kind]: its region's local price of the kind (Regional Economy & Trade
# rule 11), 1.0 for linh thach and before the markets have ticked.
static func _price_index(db: WorldDB, place: Dictionary, kind: String) -> float:
	if kind == "linh_thach":
		return 1.0
	return float(db.get_record("regions", str(place.get("region_id", ""))).get("price_index", {}).get(kind, 1.0))


## Formula I: the reserve after a season that extracted [param e].
static func next_reserve(gd: GameData, site: Dictionary, e: float, recover: float) -> float:
	var cfg: Dictionary = _cfg(gd)
	var s: float = float(cfg.sustain_frac) * float(site.base_output)
	var rmax: float = float(site.reserve_max)
	var rr: float = float(site.reserve) - maxf(0.0, e - s) + recover * rmax * maxf(0.0, 1.0 - e / maxf(s, 0.0001))
	return clampf(rr, float(cfg.reserve_floor) * rmax, rmax)


## The labour near a site (Formula H's settle_w): the most developed settlement within settle_reach tiles, or a fixed
## weight for a kind in settle_w_by_kind (beasts are hunted where they live).
static func settle_weight(gd: GameData, db: WorldDB, place: Dictionary) -> float:
	var cfg: Dictionary = _cfg(gd)
	var by_kind: Dictionary = cfg.get("settle_w_by_kind", {})
	if place.has("site") and by_kind.has(str(place.site.get("kind", ""))):
		return float(by_kind[str(place.site.kind)])
	var reach: int = int(cfg.settle_reach)
	var best: float = float(cfg.settle_w.none)
	if not place.has("tile"):
		return best
	for p in db.all("places"):
		if not p.has("tile") or not cfg.settle_w.has(str(p.get("kind", ""))) or bool(p.get("hidden", false)):
			continue
		if maxi(absi(int(p.tile[0]) - int(place.tile[0])), absi(int(p.tile[1]) - int(place.tile[1]))) <= reach:
			best = maxf(best, float(cfg.settle_w[str(p.kind)]))
	return best


## One season of the map's production (rules 21-22, 25): every site produces and its reserve moves; the contract per
## region and territory is published on the region records ("production": {resource: units} of the sites' resources;
## "production_value": {good: base value} of every non-money good, herbs included, Formula L's value_lt; with
## [param advance] false the contract is published without moving the reserves (world generation's preview); and with
## [param count_people] the "population", counted once a year by the tick).
static func season(gd: GameData, db: WorldDB, count_people: bool = true, advance: bool = true) -> void:
	var cfg: Dictionary = _cfg(gd)
	var by_region := {}
	var by_territory := {}
	var value_by_region := {}
	for p in db.all("places"):
		if p.has("local"):   # Formula H2: the settlement's fields and diggings
			var lo: Dictionary = local_output(gd, db, p)
			var lr: String = str(p.get("region_id", ""))
			if not value_by_region.has(lr):
				value_by_region[lr] = {}
			var hs: Dictionary = herb_split(gd, p.local.get("herbs", []), int(lo.herb))
			p.local["last_herbs"] = hs
			p.local["last_ore"] = float(lo.ore)
			for g in hs:
				value_by_region[lr][g] = float(value_by_region[lr].get(g, 0.0)) + float(hs[g])
			if float(lo.ore) > 0.0:
				var og: String = str(p.local.ore)
				value_by_region[lr][og] = float(value_by_region[lr].get(og, 0.0)) + float(lo.ore)
		if p.has("herb_site"):
			var hw: float = float(p.herb_site.get("settle_w", -1.0))
			if hw < 0.0:
				hw = settle_weight(gd, db, p)
				p.herb_site["settle_w"] = hw
			var hv: float = float(production(gd, {"holder": p.get("holder", ""), "site": p.herb_site}, hw, _price_index(db, p, "herb")).output)
			p.herb_site["last_output"] = hv
			if advance:
				p.herb_site["reserve"] = snappedf(next_reserve(gd, p.herb_site, hv, float(cfg.recover_rate.herb)), 0.01)
			var split: Dictionary = herb_split(gd, p.get("herb_grounds", []), int(hv))
			p.herb_site["by_good"] = split
			var hr: String = str(p.get("region_id", ""))
			if not value_by_region.has(hr):
				value_by_region[hr] = {}
			for g in split:
				value_by_region[hr][g] = float(value_by_region[hr].get(g, 0.0)) + float(split[g])
		if not p.has("site"):
			continue
		var w: float = float(p.site.get("settle_w", -1.0))
		if w < 0.0:
			w = settle_weight(gd, db, p)
			p.site["settle_w"] = w
		var out: float = float(production(gd, p, w, _price_index(db, p, str(p.site.kind))).output)
		p.site["last_output"] = out
		if advance:
			p.site["reserve"] = snappedf(next_reserve(gd, p.site, out, float(cfg.recover_rate.get(str(p.site.kind), 0.01))), 0.01)
			if int(p.site.get("spoils", 0)) > 0:
				p.site["spoils"] = int(p.site.spoils) - 1
		var rid: String = str(p.get("region_id", ""))
		if not by_region.has(rid):
			by_region[rid] = {}
		by_region[rid][str(p.site.resource)] = float(by_region[rid].get(str(p.site.resource), 0.0)) + out
		if str(p.site.kind) != "linh_thach":
			if not value_by_region.has(rid):
				value_by_region[rid] = {}
			var vv: float = out * float(cfg.unit_value.get(str(p.site.resource), 1))
			var parts: Dictionary = kind_split(gd, str(p.site.kind), str(p.site.resource), int(round(vv)))
			for g in parts:
				value_by_region[rid][g] = float(value_by_region[rid].get(g, 0.0)) + float(parts[g])
		var t: String = str(p.get("territory", ""))
		if t != "":
			if not by_territory.has(t):
				by_territory[t] = {}
			by_territory[t][str(p.site.resource)] = float(by_territory[t].get(str(p.site.resource), 0.0)) + out
	var pop := {}
	if count_people:
		for person in db.living():
			if bool(person.get("alive", false)) and not bool(person.get("is_beast", false)):
				var rid: String = str(db.get_record("places", str(person.get("location_id", ""))).get("region_id", ""))
				pop[rid] = int(pop.get(rid, 0)) + 1
	for r in db.all("regions"):
		r["production"] = by_region.get(str(r.id), {})
		r["production_value"] = value_by_region.get(str(r.id), {})
		if count_people:
			r["population"] = int(pop.get(str(r.id), 0))
	var meta: Dictionary = db.get_record("world", "w_meta")
	if not meta.is_empty():
		meta["territory_production"] = by_territory
