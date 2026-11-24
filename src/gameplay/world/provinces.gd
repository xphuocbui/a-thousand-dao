class_name Provinces
extends RefCounted

## Provinces as live world records (design/gdd/provinces.md; ADR-0008; production/plans/provinces-runtime.md Stage 1,
## "in shadow": the province contract is published beside the region one and nothing reads it yet).
## - [method build]: world generation makes the provinces table from the static shapes (world_provinces.json) and gives
##   every place a province_id (a place outside every listed province, such as a lake, takes the province of its
##   nearest land tile).
## - [method add_value]: MapProduction adds each place's season output (base value per good) to its province, in the
##   same loop that fills the region totals, so the two sum alike by construction.
## - [method season]: after MapProduction, before the economy (ADR-0008 decision 4): F2 passes wilderness output to the
##   settlement provinces of the same region by shared border, hop by hop within wild_hops; F4 production (places +
##   wilderness share; the building term is 0 until Stage 2, no modifiers until Stage 7); F1 goods fixed at the first
##   season; F5 slots. Population stays the settlements' start value until Stage 5 (F3).
## Knobs: assets/data/provinces.json.
##
## Usage:
## [codeblock]
## Provinces.build(gd, db)                       # WorldBuilder, after the places
## Provinces.season(gd, db)                      # WorldTicker, after MapProduction.season
## var v: Dictionary = Provinces.of_place(gd, db, place)
## [/codeblock]

const FILE := "provinces"
const TABLE := "provinces"

static var _ids: PackedByteArray = PackedByteArray()
static var _ids_path: String = ""
static var _order: Dictionary = {}   # WorldDB instance id -> [wilderness records farthest first, with their targets]
static var _class: Dictionary = {}   # good id -> raw class (data: never changes in a run)


static func cfg(gd: GameData) -> Dictionary:
	return gd.file(FILE)


## The record id of continent province [param n].
static func rid(n: int) -> String:
	return "v%d" % n


## The province id at tile [param t] from the province raster, "" over water or off the grid.
static func id_at_tile(gd: GameData, t: Vector2i) -> String:
	var path: String = str(cfg(gd).get("province_ids_file", ""))
	if _ids_path != path:
		_ids_path = path
		_ids = FileAccess.get_file_as_bytes(path) if path != "" and FileAccess.file_exists(path) else PackedByteArray()
	var size: Array = gd.file(ContinentData.DATA_FILE).get("grid", [540, 360])
	var w: int = int(size[0])
	var h: int = int(size[1])
	if t.x < 0 or t.y < 0 or t.x >= w or t.y >= h or _ids.size() < w * h * 2:
		return ""
	var n: int = _ids.decode_u16((t.y * w + t.x) * 2)
	return rid(n) if n > 0 else ""


## The province of a place on water: the nearest land tile's province within lake_search_radius (rings outward, the
## lowest province id on a tie), "" if none.
static func nearest_land(gd: GameData, t: Vector2i) -> String:
	var here: String = id_at_tile(gd, t)
	if here != "":
		return here
	for r in range(1, int(cfg(gd).get("lake_search_radius", 12)) + 1):
		var best: int = 0
		for dy in range(-r, r + 1):
			for dx in range(-r, r + 1):
				if maxi(absi(dx), absi(dy)) != r:
					continue
				var v: String = id_at_tile(gd, t + Vector2i(dx, dy))
				if v != "":
					var n: int = v.substr(1).to_int()
					if best == 0 or n < best:
						best = n
		if best > 0:
			return rid(best)
	return ""


## The province record of [param place] (its province_id, found and stored from its tile when missing), {} if none.
static func of_place(gd: GameData, db: WorldDB, place: Dictionary) -> Dictionary:
	var v: String = str(place.get("province_id", ""))
	if v == "" and place.has("tile"):
		v = nearest_land(gd, Vector2i(int(place.tile[0]), int(place.tile[1])))
		place["province_id"] = v
	return db.get_record(TABLE, v) if v != "" else {}


## World generation: the provinces table from the shapes, every place's province_id, each province's wilderness hops
## (F2) and its start population (the settlements' P, Travel & Map H2). Call after the places and settlements exist.
static func build(gd: GameData, db: WorldDB) -> void:
	var shapes: Array = gd.file(str(cfg(gd).get("shape_file", "world_provinces"))).get("provinces", [])
	if shapes.is_empty():
		return
	var region_of := {}
	for r in db.all("regions"):
		region_of[int(r.get("continent_id", -1))] = str(r.id)
	var place_of := {}
	for p in db.all("places"):
		if p.has("continent_id"):
			place_of[int(p.continent_id)] = p
	var key_to := {}
	for s in shapes:
		key_to[str(s.key)] = rid(int(s.id))
	for s in shapes:
		var v: String = rid(int(s.id))
		var places: Array = []
		for q in s.get("places", []):
			if not q.has("id"):
				continue
			var p: Dictionary = place_of.get(int(q.id), {})
			if p.is_empty():
				continue
			p["province_id"] = v
			places.append(str(p.id))
		var seat: Dictionary = place_of.get(int(s.seat_place), {}) if s.get("seat_place") != null else {}
		var nb: Array = []
		for n in s.get("neighbours", []):
			if key_to.has(str(n.province)):
				nb.append({"province": key_to[str(n.province)], "border": int(n.get("border_tiles", 1))})
		db.add(TABLE, {"id": v, "key": str(s.key), "name": str(s.get("name", "")), "region_id": str(region_of.get(int(s.region), "")),
			"kind": str(s.kind), "seat_kind": str(s.get("seat_kind", "")) if s.get("seat_kind") != null else "",
			"seat_place": str(seat.get("id", "")), "places": places, "neighbours": nb,
			"population": 0.0, "own_value": {}, "production_value": {}, "production_class": {}, "potential": {},
			"main_good": "", "secondary_goods": [], "goods_fixed": false, "slots": 0, "buildings": [], "modifiers": [],
			"dist": -1, "pass_to": [], "coast": bool(s.get("coast", false)), "river_tiles": int(s.get("river_tiles", 0)),
			"next_building": 1})
	for p in db.all("places"):   # the lakes and any place no shape lists
		if str(p.get("province_id", "")) == "":
			of_place(gd, db, p)
	for v in db.all(TABLE):   # F3's start: the settlements' population (Travel & Map H2), fixed until Stage 5
		var pop: float = 0.0
		for pid in v.places:
			pop += float(db.get_record("places", str(pid)).get("local", {}).get("pop", 0.0))
		v["population"] = pop
		v["p0"] = pop
		v["capacity"] = pop
	_wild_hops(gd, db)


# F2's routes, fixed by the land: each province's hops from the nearest settlement province of its region (breadth first
# over shared borders) and, for a wilderness province within wild_hops, its shares to the neighbours one hop nearer,
# by border length.
static func _wild_hops(gd: GameData, db: WorldDB) -> void:
	var frontier: Array = []
	for v in db.all(TABLE):
		if str(v.kind) == "settlement":
			v["dist"] = 0
			frontier.append(v)
	while not frontier.is_empty():
		var nxt: Array = []
		for v in frontier:
			for n in v.neighbours:
				var u: Dictionary = db.get_record(TABLE, str(n.province))
				if not u.is_empty() and int(u.dist) < 0 and str(u.region_id) == str(v.region_id):
					u["dist"] = int(v.dist) + 1
					nxt.append(u)
		frontier = nxt
	var hops: int = int(cfg(gd).get("wild_hops", 6))
	for v in db.all(TABLE):
		if str(v.kind) == "settlement" or int(v.dist) < 1 or int(v.dist) > hops:
			continue
		var near: Array = []
		var tot: float = 0.0
		for n in v.neighbours:
			var u: Dictionary = db.get_record(TABLE, str(n.province))
			if not u.is_empty() and int(u.dist) == int(v.dist) - 1 and str(u.region_id) == str(v.region_id):
				near.append([str(u.id), float(n.border)])
				tot += float(n.border)
		v["pass_to"] = near.map(func(x): return {"province": x[0], "share": float(x[1]) / maxf(tot, 1.0)})


## MapProduction's hook: adds [param value] of good [param good] produced at [param place] to its province's own value
## this season (a place with no province adds nothing here; it still counts in its region).
static func add_value(gd: GameData, db: WorldDB, place: Dictionary, good: String, value: float) -> void:
	var v: Dictionary = of_place(gd, db, place)
	if v.is_empty():
		return
	v.own_value[good] = float(v.own_value.get(good, 0.0)) + value


## Clears every province's own value before MapProduction's season fills it.
static func clear_values(db: WorldDB) -> void:
	for v in db.all(TABLE):
		v["own_value"] = {}


## One season (rule 13 steps 3 and 5 in shadow): F2 and F4 production per province from MapProduction's own values,
## F1 goods (fixed at the first season), F5 slots. Returns nothing; the records carry the contract.
static func season(gd: GameData, db: WorldDB, season_i: int = -1) -> void:
	if db.count(TABLE) == 0:
		return
	if season_i == 0:
		yearly(gd, db)   # rule 13 step 2: population, once a year in Spring (Stage 5)
	_season(gd, db)
	ProvinceBuildings.tally_halls(gd, db)   # Stage 4: the halls' totals for the hooks


static func _season(gd: GameData, db: WorldDB) -> void:
	var carry := {}   # wilderness province -> {good: value} still to pass on
	var gathered := {}   # settlement province -> {good: value} from wilderness
	var wild: Array = _wild_order(db)
	for row in wild:
		carry[str(row[0].id)] = Dictionary(row[0].own_value).duplicate()
	for row in wild:
		var c: Dictionary = carry[str(row[0].id)]
		for t in row[1]:   # [to, share, to is a settlement]
			var dest: Dictionary = gathered if bool(t[2]) else carry
			if not dest.has(t[0]):
				dest[t[0]] = {}
			var d: Dictionary = dest[t[0]]
			for g in c:
				d[g] = float(d.get(g, 0.0)) + float(c[g]) * float(t[1])
	var cs: Dictionary = cfg(gd)
	for v in db.all(TABLE):
		var settled: bool = str(v.kind) == "settlement"
		var prod: Dictionary = Dictionary(v.own_value).duplicate() if settled else {}
		for g in gathered.get(str(v.id), {}):
			prod[g] = float(prod.get(g, 0.0)) + float(gathered[str(v.id)][g])
		v["production_value"] = prod   # F4: places + wilderness share (+ buildings from Stage 2, modifiers from Stage 7)
		var by_class := {}
		for g in (prod if settled else v.own_value):
			var k: String = _class_of(gd, str(g))
			by_class[k] = float(by_class.get(k, 0.0)) + float((prod if settled else v.own_value)[g])
		v["production_class"] = by_class
		v["potential"] = by_class.duplicate()   # F1 in shadow: what the land gives with no buildings
		if not bool(v.goods_fixed):   # rule 4: the goods are fixed at world generation (the first season here)
			_fix_goods(cs, v, by_class)
		var base: int = int(cs.get("base_slots", {}).get(str(v.seat_kind), 0)) if settled else int(cs.get("wild_slots", 1))
		var extra: int = int(floor(float(v.population) / maxf(float(cs.get("slot_pop_step", 8.0)), 1e-9))) if settled else 0
		var standing: int = Array(v.buildings).filter(func(b): return str(b.get("state", "")) != "cancelled").size()
		v["slots"] = maxi(base + extra, standing)   # F5: slots never fall below the buildings standing
		ProvinceBuildings.season(gd, db, v)   # rule 13 step 1 (advance) and the projection onto places (Stage 2)


# F2's fixed routes, farthest wilderness first: [[record, [[to id, share, to is a settlement]]]], cached per world.
static func _wild_order(db: WorldDB) -> Array:
	var key: int = db.get_instance_id()
	if _order.has(key):
		return _order[key]
	var wild: Array = db.all(TABLE).filter(func(v): return str(v.kind) != "settlement" and not Array(v.pass_to).is_empty())
	wild.sort_custom(func(a, b): return int(a.dist) > int(b.dist) or (int(a.dist) == int(b.dist) and str(a.id) < str(b.id)))
	var rows: Array = []
	for v in wild:
		rows.append([v, Array(v.pass_to).map(func(t): return [str(t.province), float(t.share), str(db.get_record(TABLE, str(t.province)).get("kind", "")) == "settlement"])])
	_order[key] = rows
	return rows


static func _class_of(gd: GameData, good: String) -> String:
	if not _class.has(good):
		_class[good] = WorldEconomy.class_of(gd, good)
	return str(_class[good])


## F3, once a year (Stage 5): each settlement province's population moves toward its capacity while fed and safe, falls
## in famine and war, and stays within [pop_floor P0, max(C, P (1 - f_fam))]; its settlements' workforce follows P / P0.
static func yearly(gd: GameData, db: WorldDB) -> void:
	var c: Dictionary = cfg(gd).get("population", {})
	for v in db.all(TABLE):
		if str(v.kind) != "settlement":
			continue
		var p0: float = float(v.get("p0", v.population))
		var p: float = float(v.population)
		var capb: float = 0.0
		for b in v.get("buildings", []):
			capb += float(ProvinceBuildings.kind(gd, str(b.kind)).get("cap_b", 0.0)) * float(ProvinceBuildings.effective(gd, b))
		var cap: float = p0 * (1.0 + float(c.get("cap0", 0.2)) + capb)
		var cover: float = _staple_cover(db, v)
		var fam: float = float(c.get("famine_cover", 0.6))
		var fed: bool = cover >= fam
		var safe: bool = not _at_war(db, v)
		var np: float = p
		if not fed:
			np = p * (1.0 - float(c.get("f_fam", 0.2)) * (1.0 - cover / maxf(fam, 1e-9)))
		elif safe:
			np = p + float(c.get("g", 0.03)) * p * (1.0 - p / cap) if cap > 0.0 else 0.0
		if not safe:
			np *= 1.0 - float(c.get("f_war", 0.05))
		np = clampf(np, float(c.get("pop_floor", 0.3)) * p0, maxf(cap, p * (1.0 - float(c.get("f_fam", 0.2)))))
		v["population"] = np
		v["capacity"] = cap
		var ratio: float = np / p0 if p0 > 0.0 else 1.0
		for pid in v.places:   # the workforce of its settlements (Travel & Map H2's P, which output and W_set read)
			var pl: Dictionary = db.get_record("places", str(pid))
			if pl.has("local"):
				if not pl.local.has("pop0"):
					pl.local["pop0"] = float(pl.local.get("pop", 0.0))
				pl.local["pop"] = snappedf(float(pl.local.pop0) * ratio, 0.001)


# F3's cover_st: the mean cover of the herb and beast classes in the province's market (Regional Economy E), 1.0 (fed)
# when it has no market or no such class.
static func _staple_cover(db: WorldDB, v: Dictionary) -> float:
	var mid: String = WorldEconomy.market_of_region(db, db.get_record("regions", str(v.get("region_id", ""))))
	var m: Dictionary = db.get_record(WorldEconomy.TABLE, mid) if mid != "" else {}
	var sum: float = 0.0
	var n: int = 0
	for k in m.get("classes", {}):
		if str(k).begins_with("herb") or str(k).begins_with("beast"):
			sum += float(m.classes[k].get("cover", 1.0))
			n += 1
	return sum / float(n) if n > 0 else 1.0


# F3's safe: the holder of the province's region is at no war (Sects' war state, read at the yearly step).
static func _at_war(db: WorldDB, v: Dictionary) -> bool:
	var s: Dictionary = db.get_record("sects", str(db.get_record("regions", str(v.get("region_id", ""))).get("holder", "")))
	return not s.is_empty() and not Array(s.get("wars", [])).is_empty()


# F1's goods: the main good is the class with the largest value, up to two secondary goods at secondary_share of it.
static func _fix_goods(cs: Dictionary, v: Dictionary, by_class: Dictionary) -> void:
	var rows: Array = []
	for k in by_class:
		rows.append([str(k), float(by_class[k])])
	rows.sort_custom(func(a, b): return float(a[1]) > float(b[1]) or (float(a[1]) == float(b[1]) and str(a[0]) < str(b[0])))
	if rows.is_empty() or float(rows[0][1]) <= 0.0:
		return
	v["main_good"] = str(rows[0][0])
	var sec: Array = []
	for i in range(1, mini(3, rows.size())):
		if float(rows[i][1]) >= float(cs.get("secondary_share", 0.35)) * float(rows[0][1]):
			sec.append(str(rows[i][0]))
	v["secondary_goods"] = sec
	v["goods_fixed"] = true
