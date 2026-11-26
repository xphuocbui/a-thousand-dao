class_name ProvinceBuildings
extends RefCounted

## Province buildings (design/gdd/provinces.md rules 7-10 and States; design/quick-specs/province-building-catalogue.md;
## provinces-runtime Stage 2). One catalogue (assets/data/province_buildings.json); the province record holds each
## building: {id, kind, level (built), target, state, left (build seasons), unpaid, element}. States: building (a first
## build or an upgrade; an upgrade keeps counting at the built level), active, unpaid (an upkept building counts 0, a
## permanent one keeps its gain), ruined (after ruin_seasons unpaid: counts 0 until repaired). The record of truth is the
## province: [method project] writes each building's effective level as a Travel & Map work (by "province") at the
## places it acts on, so Formula B, match and Formula H's G_f read it unchanged; a place's own works (a player's abode)
## are left alone. Kinds with live false are placed for slots but not billed, ordered or projected until their stage.
##
## Usage:
## [codeblock]
## ProvinceBuildings.place_start(gd, db)          # WorldBuilder, after the first province season (goods known)
## ProvinceBuildings.season(gd, db, v)            # Provinces.season: advance, then project
## var paid := ProvinceBuildings.pay(gd, db, sect, money)   # WorldMoney (SectWorks.upkeep): upkeep by priority
## [/codeblock]

const FILE := "province_buildings"
const BY := "province"
const PRIORITY := ["production", "logistics", "society", "cultivation"]   # D3 (user, 2026-11-24): production first


static func cfg(gd: GameData) -> Dictionary:
	return gd.file(FILE)


static func kind(gd: GameData, k: String) -> Dictionary:
	return cfg(gd).get("kinds", {}).get(k, {})


## The level a building counts at (F4's effective level): its built level while active (or while upgrading); 0 while a
## first build, ruined, or an upkept building unpaid; a permanent building keeps its gain while unpaid.
static func effective(gd: GameData, b: Dictionary) -> int:
	var st: String = str(b.get("state", "active"))
	if st == "ruined" or st == "cancelled":
		return 0
	if st == "unpaid" and str(kind(gd, str(b.kind)).get("kind", "")) == "upkept":
		return 0
	return int(b.get("level", 0))


## Seasons a level takes to build: permanent kinds seasons x level, upkept 1 + floor(level / 3).
static func build_seasons(gd: GameData, k: String, level: int) -> int:
	var kd: Dictionary = kind(gd, k)
	if str(kd.get("kind", "")) == "permanent":
		return maxi(1, int(kd.get("seasons", 1)) * level)
	return 1 + level / 3


## The linh thach a level costs: cost_lt x growth^(L-1), x track_surcharge per level above [param free_level] (>= 0).
static func cost(gd: GameData, k: String, level: int, free_level: int = -1) -> int:
	var kd: Dictionary = kind(gd, k)
	var sur: float = pow(float(MapWorks.cfg(gd).get("track_surcharge", 2.0)), float(maxi(0, level - free_level))) if free_level >= 0 else 1.0
	return int(round(float(kd.get("cost_lt", 0)) * pow(float(kd.get("growth", 2.0)), float(level - 1)) * sur))


## The places building kind [param k] acts on in province [param v] (rule 8, "Where a building acts").
static func acting_places(gd: GameData, db: WorldDB, v: Dictionary, k: String) -> Array:
	var kd: Dictionary = kind(gd, k)
	var acts: String = str(kd.get("acts", "province"))
	if acts == "seat":
		var seat: Dictionary = db.get_record("places", str(v.get("seat_place", "")))
		return [] if seat.is_empty() or not seat.has("qi") else [seat]
	var out: Array = []
	if acts == "sites" or acts == "all_sites":
		var kinds: Array = kd.get("sites", [])
		for pid in v.places:
			var p: Dictionary = db.get_record("places", str(pid))
			if p.has("site") and p.has("qi") and (acts == "all_sites" or kinds.has(str(p.get("kind", "")))):
				out.append(p)
	return out


## Who pays and orders province [param v]'s buildings (rule 9): a sect seated at its seat place (the local lord; a
## great seat there makes the great sect the payer, rule 2a, 2026-11-25/26), else the holder of its region; "" when
## nobody holds it.
static func payer(db: WorldDB, v: Dictionary) -> String:
	var seat: Dictionary = db.get_record("places", str(v.get("seat_place", "")))
	if not seat.is_empty() and str(seat.get("kind", "")) in ["minor_seat", "great_seat"] and str(seat.get("sect_id", "")) != "":
		var s: Dictionary = db.get_record("sects", str(seat.sect_id))
		if not s.is_empty() and str(s.get("status", "")) == "active":
			return str(s.id)
	return str(db.get_record("regions", str(v.get("region_id", ""))).get("holder", ""))


## A new building record of kind [param k] (active at [param level], or building toward it when [param build]).
static func make(v: Dictionary, k: String, level: int, build: bool = false, seasons: int = 1, element: String = "") -> Dictionary:
	var n: int = int(v.get("next_building", 1))
	v["next_building"] = n + 1
	return {"id": "%s_b%d" % [str(v.id), n], "kind": k, "level": 0 if build else level, "target": level,
		"state": "building" if build else "active", "left": seasons if build else 0, "unpaid": 0, "element": element}


## Rule 10 at world generation: each settlement province's buildings by seat kind, its main good's production building,
## a landing for a town, market or city on a coast or a river, and a wilderness province's mine works when it has a mine;
## then the lore (user request 2026-11-24): each building's level follows its payer sect's authored level in the kind's
## track (start_level), each sect's seat province gains the halls of its specialty and craft (lore_specialty,
## lore_craft), and sect_extra adds authored extras. All active. Off when start_enabled is false.
static func place_start(gd: GameData, db: WorldDB) -> void:
	var c: Dictionary = cfg(gd)
	if not bool(c.get("start_enabled", true)):
		return
	var lore := {}   # sect key -> its world_history record (specialty, craft)
	for h in gd.file("world_history").get("sects", []):
		lore[str(h.get("key", ""))] = h
	# province id -> the ids of the sects seated in it (rule 2a: a great seat and a minor seat may share one province)
	var seat_of := {}
	for s in db.all("sects"):
		var sp: Dictionary = db.get_record("places", str(s.get("hq_place_id", "")))
		if not sp.is_empty():
			var pv: String = str(sp.get("province_id", ""))
			if not seat_of.has(pv):
				seat_of[pv] = []
			seat_of[pv].append(str(s.id))
	for v in db.all(Provinces.TABLE):
		var list: Array = []
		var water: bool = bool(v.get("coast", false)) or int(v.get("river_tiles", 0)) >= int(c.get("landing_river_tiles", 6))
		if str(v.kind) == "settlement":
			for e in c.get("start", {}).get(str(v.seat_kind), []):
				list.append(str(e[0]))
			var good: String = str(v.get("main_good", ""))
			for gk in c.get("good_building", {}):
				if good.begins_with(str(gk)):
					list.append(str(c.good_building[gk]))
			if str(v.seat_kind) in c.get("landing_seats", []) and water:
				list.append("landing")
		else:
			for pid in v.places:
				if str(db.get_record("places", str(pid)).get("kind", "")) == "mine":
					list.append("mine_works")
					break
		var payer_id: String = payer(db, v)
		var sect: Dictionary = db.get_record("sects", payer_id) if payer_id != "" else {}
		var at_seat: bool = seat_of.has(str(v.id)) and Array(seat_of[str(v.id)]).has(payer_id)
		if not sect.is_empty():
			var h: Dictionary = lore.get(str(sect.get("key", "")), {})
			if at_seat:
				var sk: String = str(c.get("lore_specialty", {}).get(str(h.get("specialty", "")), ""))
				if sk != "" and not list.has(sk):
					list.append(sk)
				var craft: String = str(h.get("craft", "")).to_lower()
				for kw in c.get("lore_craft", []):
					var k: String = str(kw[1])
					if craft.contains(str(kw[0]).to_lower()) and not list.has(k) and (k != "landing" or water):
						list.append(k)
			for k in c.get("sect_extra", {}).get(str(sect.get("key", "")), {}).get("held_provinces", []):
				if not list.has(str(k)):
					list.append(str(k))
		var bs: Array = v.get("buildings", [])
		for k in list:
			bs.append(make(v, k, start_level(gd, sect, str(k), at_seat)))
		v["buildings"] = bs


## A starting building's level (user request 2026-11-24): max(1, round(the payer sect's authored level in the kind's
## track x per_track_level)), x away_factor outside its seat province; 1 on unheld land.
static func start_level(gd: GameData, sect: Dictionary, k: String, at_seat: bool) -> int:
	var sl: Dictionary = cfg(gd).get("start_level", {})
	if sect.is_empty() or Array(sl.get("flat_groups", [])).has(str(kind(gd, k).get("group", ""))):
		return 1   # unheld land, and production (flat_groups: the economy's calibrated start)
	var t: float = float(sect.get("levels", {}).get(str(kind(gd, k).get("track", "holdings")), 0))
	var lv: float = t * float(sl.get("per_track_level", 0.34)) * (1.0 if at_seat else float(sl.get("away_factor", 0.5)))
	return maxi(1, int(round(lv)))


## Rule 13 step 1 and the projection: build seasons count down (a finished level turns active), unpaid upkept
## buildings show as unpaid and turn ruined after ruin_seasons, then every live building's effective level is written to
## the places it acts on.
static func season(gd: GameData, db: WorldDB, v: Dictionary) -> void:
	var ruin: int = int(cfg(gd).get("ruin_seasons", 4))
	for b in v.get("buildings", []):
		if str(b.state) == "building":
			b["left"] = int(b.get("left", 1)) - 1
			if int(b.left) <= 0:
				b["level"] = int(b.target)
				b["state"] = "active"
				b["unpaid"] = 0
		elif str(b.state) in ["active", "unpaid"]:
			if int(b.get("unpaid", 0)) >= ruin and str(kind(gd, str(b.kind)).get("kind", "")) == "upkept":
				b["state"] = "ruined"
			elif int(b.get("unpaid", 0)) > 0:
				b["state"] = "unpaid"
			else:
				b["state"] = "active"
	grow_sites(gd, db, v)
	project(gd, db, v)


## Stage 3, site growth (Provinces rule 8's bullet, user decisions 2026-11-24; D5a): a site that started at grade minor
## (an authored new site) stands one grade step higher for each level of its province's matching production building
## above level 1 (minor, small, medium, large), never above the grade its land density gives it (grade_by_density); the
## grade follows the building down as well as up, and the reserve keeps its fraction of the new reserve_max.
static func grow_sites(gd: GameData, db: WorldDB, v: Dictionary) -> void:
	var mp: Dictionary = gd.file(MapProduction.DATA_FILE)
	var order: Array = ["minor", "small", "medium", "large"]
	var levels := {}   # place id -> the matching buildings' effective levels, summed
	for b in v.get("buildings", []):
		var kd: Dictionary = kind(gd, str(b.kind))
		if not bool(kd.get("live", false)) or str(kd.get("acts", "")) != "sites":
			continue
		for p in acting_places(gd, db, v, str(b.kind)):
			levels[str(p.id)] = int(levels.get(str(p.id), 0)) + effective(gd, b)
	for pid in v.places:
		var p: Dictionary = db.get_record("places", str(pid))
		if not p.has("site") or str(p.get("site_grade", "")) != "minor" or Array(cfg(gd).get("growth_skip_kinds", [])).has(str(p.site.get("kind", ""))):
			continue   # stone sites keep their grade (user decision 2026-11-24: growth doubled minting)
		var land: float = float(p.get("qi", {}).get("land_density", p.get("density", 1.0)))
		var cap: String = "small"
		for g in mp.grade_by_density:
			if land >= float(g[0]):
				cap = str(g[1])
				break
		var per: int = maxi(1, int(cfg(gd).get("growth_step_levels", {}).get(str(p.site.get("kind", "")), 1)))   # Stage 9
		var want: int = mini(maxi(0, int(levels.get(str(p.id), 0)) - 1) / per, order.find(cap))
		var grade: String = str(order[want])
		if grade == str(p.site.get("grade", "")):
			continue
		var frac: float = float(p.site.reserve) / maxf(float(p.site.reserve_max), 1e-9)
		var base: float = float(mp.site_grade_value[grade]) * float(mp.kind_value_mult[str(p.site.kind)]) / maxf(1.0, float(mp.unit_value.get(str(p.site.resource), 1)))
		p.site["grade"] = grade
		p.site["base_output"] = snappedf(base, 0.01)
		p.site["reserve_max"] = snappedf(float(mp.reserve_seasons) * base, 0.01)
		p.site["reserve"] = snappedf(frac * float(p.site.reserve_max), 0.01)


## Writes [param v]'s live buildings as works (by "province") at the places they act on, replacing what the province
## wrote before, and refreshes those sites' works_prod (Formula H's G_f). A qi channel is keyed by its element.
static func project(gd: GameData, db: WorldDB, v: Dictionary) -> void:
	var touched := {}
	for pid in v.places:
		var p: Dictionary = db.get_record("places", str(pid))
		if p.has("qi") and p.qi.has("layer2"):
			for key in p.qi.layer2.keys():
				if str(p.qi.layer2[key].get("by", "")) == BY:
					p.qi.layer2.erase(key)
					touched[str(p.id)] = p
	for b in v.get("buildings", []):
		var kd: Dictionary = kind(gd, str(b.kind))
		if not bool(kd.get("live", false)) or str(kd.get("work", "")) == "":
			continue
		var lv: int = effective(gd, b)
		if lv <= 0:
			continue
		var key: String = str(kd.work) + ((":" + str(b.element)) if bool(kd.get("element", false)) else "")
		for p in acting_places(gd, db, v, str(b.kind)):
			if not p.qi.has("layer2"):
				p.qi["layer2"] = {}
			var e: Dictionary = p.qi.layer2.get(key, {"level": 0, "unpaid": 0, "element": str(b.element), "by": BY})
			if str(e.get("by", "")) != BY:
				continue   # the place's own work of the same kind (a player's abode) is left as it is
			e["level"] = int(e.level) + lv
			p.qi.layer2[key] = e
			touched[str(p.id)] = p
	for pid in touched:
		var p: Dictionary = touched[pid]
		if p.has("site"):
			p.site["works_prod"] = MapWorks.production_gain(gd, p.qi)


## Stage 4: each season's hall totals, read by the hooks without a search: sect["halls"] {kind: effective levels at its
## own seat province} and region["halls"] {kind: effective levels over the region's provinces} for every kind with a
## hook (value_per_member). Called once a season after every province's step.
static func tally_halls(gd: GameData, db: WorldDB) -> void:
	var kinds: Dictionary = cfg(gd).get("kinds", {})
	var seat_of := {}   # place id -> sect id (the sect seated there)
	for s in db.all("sects"):
		s["halls"] = {}
		if str(s.get("status", "")) == "active":
			seat_of[str(s.get("hq_place_id", ""))] = str(s.id)
	for r in db.all("regions"):
		r["halls"] = {}
	for v in db.all(Provinces.TABLE):
		var here: String = ""
		for pid in v.places:
			if seat_of.has(str(pid)):
				here = str(seat_of[str(pid)])
		var reg: Dictionary = db.get_record("regions", str(v.get("region_id", "")))
		for b in v.get("buildings", []):
			var kd: Dictionary = kinds.get(str(b.kind), {})
			if not kd.has("value_per_member") or not bool(kd.get("live", false)):
				continue
			var lv: int = effective(gd, b)
			if lv <= 0:
				continue
			if here != "":
				var sh: Dictionary = db.get_record("sects", here).halls
				sh[str(b.kind)] = int(sh.get(str(b.kind), 0)) + lv
			if not reg.is_empty():
				reg.halls[str(b.kind)] = int(reg.halls.get(str(b.kind), 0)) + lv


## Hall levels of [param kind] at sect [param sect_id]'s seat this season (0 with no sect or none built).
static func sect_hall(db: WorldDB, sect_id: String, k: String) -> int:
	if sect_id == "" or not db.has_record("sects", sect_id):
		return 0
	return int(db.get_record("sects", sect_id).get("halls", {}).get(k, 0))


## A building's upkeep this season: upkeep x level, or upkeep_site_frac x the acting sites' base value x level (with
## upkeep as the floor for a province with no such site). 0 for a building not live, being first built or ruined.
static func upkeep_of(gd: GameData, db: WorldDB, v: Dictionary, b: Dictionary) -> float:
	var kd: Dictionary = kind(gd, str(b.kind))
	if not bool(kd.get("live", false)) or str(kd.get("kind", "")) != "upkept" or str(b.state) in ["ruined", "cancelled"] or int(b.get("level", 0)) <= 0:
		return 0.0
	var lv: float = float(b.level)
	if kd.has("upkeep_site_frac"):
		var val: float = 0.0
		var units: Dictionary = gd.file(MapProduction.DATA_FILE).unit_value
		for p in acting_places(gd, db, v, str(b.kind)):
			val += float(p.site.get("base_output", 0.0)) * float(units.get(str(p.site.get("resource", "")), 1))
		if val > 0.0:
			return float(kd.upkeep_site_frac) * val * lv
	return float(kd.get("upkeep", 0.0)) * lv


## The buildings [param sect] pays for: [[province, building, upkeep]], in D3's order (production first, then
## logistics, society, cultivation; building id within a group).
static func bills(gd: GameData, db: WorldDB, sect: Dictionary) -> Array:
	var out: Array = []
	for v in db.all(Provinces.TABLE):
		if payer(db, v) != str(sect.id):
			continue
		for b in v.get("buildings", []):
			var u: float = upkeep_of(gd, db, v, b)
			if u > 0.0:
				out.append([v, b, u])
	out.sort_custom(func(a, b):
		var ga: int = PRIORITY.find(str(kind(gd, str(a[1].kind)).get("group", "")))
		var gb: int = PRIORITY.find(str(kind(gd, str(b[1].kind)).get("group", "")))
		return ga < gb or (ga == gb and str(a[1].id) < str(b[1].id)))
	return out


## Marks [param sect]'s bills paid in D3's order for [param frac] (0-1, the share of the cash bill it could pay; the
## in-kind share falls short with it) of the total; the rest count an unpaid season.
static func settle(gd: GameData, db: WorldDB, sect: Dictionary, frac: float) -> void:
	var rows: Array = bills(gd, db, sect)
	var due: float = 0.0
	for row in rows:
		due += float(row[2])
	var left: float = clampf(frac, 0.0, 1.0) * due + 1e-6
	for row in rows:
		var b: Dictionary = row[1]
		if left >= float(row[2]):
			left -= float(row[2])
			b["unpaid"] = 0
		else:
			b["unpaid"] = int(b.get("unpaid", 0)) + 1
			left = 0.0
