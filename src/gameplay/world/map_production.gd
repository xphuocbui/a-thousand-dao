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


## Rule 20: the resource a site's land yields: {resource, kind} (kind linh_thach or ore).
static func site_resource(gd: GameData, place: Dictionary) -> Dictionary:
	var cfg: Dictionary = _cfg(gd)
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
	var mult: float = minf(r_f * settle_w * owner_w * d_f * s_f * g_f, float(cfg.prod_mult_cap))
	return {"output": floor(float(site.base_output) * mult + 0.5 + 1e-6), "r_f": r_f, "w_f": settle_w * owner_w, "d_f": d_f, "s_f": s_f, "g_f": g_f}


## Formula I: the reserve after a season that extracted [param e].
static func next_reserve(gd: GameData, site: Dictionary, e: float, recover: float) -> float:
	var cfg: Dictionary = _cfg(gd)
	var s: float = float(cfg.sustain_frac) * float(site.base_output)
	var rmax: float = float(site.reserve_max)
	var rr: float = float(site.reserve) - maxf(0.0, e - s) + recover * rmax * maxf(0.0, 1.0 - e / maxf(s, 0.0001))
	return clampf(rr, float(cfg.reserve_floor) * rmax, rmax)


## The labour near a site (Formula H's settle_w): the most developed settlement within settle_reach tiles.
static func settle_weight(gd: GameData, db: WorldDB, place: Dictionary) -> float:
	var cfg: Dictionary = _cfg(gd)
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
## region and territory is published on the region records ("production": {resource: units}, and with
## [param count_people] the "population", counted once a year by the tick).
static func season(gd: GameData, db: WorldDB, count_people: bool = true) -> void:
	var cfg: Dictionary = _cfg(gd)
	var by_region := {}
	var by_territory := {}
	for p in db.all("places"):
		if not p.has("site"):
			continue
		var w: float = float(p.site.get("settle_w", -1.0))
		if w < 0.0:
			w = settle_weight(gd, db, p)
			p.site["settle_w"] = w
		var out: float = float(production(gd, p, w).output)
		p.site["last_output"] = out
		p.site["reserve"] = snappedf(next_reserve(gd, p.site, out, float(cfg.recover_rate.get(str(p.site.kind), 0.01))), 0.01)
		var rid: String = str(p.get("region_id", ""))
		if not by_region.has(rid):
			by_region[rid] = {}
		by_region[rid][str(p.site.resource)] = float(by_region[rid].get(str(p.site.resource), 0.0)) + out
		var t: String = str(p.get("territory", ""))
		if t != "":
			if not by_territory.has(t):
				by_territory[t] = {}
			by_territory[t][str(p.site.resource)] = float(by_territory[t].get(str(p.site.resource), 0.0)) + out
	var pop := {}
	if count_people:
		for person in db.all("people"):
			if bool(person.get("alive", false)) and not bool(person.get("is_beast", false)):
				var rid: String = str(db.get_record("places", str(person.get("location_id", ""))).get("region_id", ""))
				pop[rid] = int(pop.get(rid, 0)) + 1
	for r in db.all("regions"):
		r["production"] = by_region.get(str(r.id), {})
		if count_people:
			r["population"] = int(pop.get(str(r.id), 0))
	var meta: Dictionary = db.get_record("world", "w_meta")
	if not meta.is_empty():
		meta["territory_production"] = by_territory
