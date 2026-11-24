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
			"road_tiles": int(s.get("road_tiles", 0)), "next_building": 1, "access": 1.0, "infra": 0.0, "usage": 0.0,
			"infra_old": -1.0})
	for p in db.all("places"):   # the lakes and any place no shape lists
		if str(p.get("province_id", "")) == "":
			of_place(gd, db, p)
	_follow_province_regions(gd, db)
	for v in db.all(TABLE):   # F3's start: the settlements' population (Travel & Map H2), fixed until Stage 5
		var pop: float = 0.0
		for pid in v.places:
			pop += float(db.get_record("places", str(pid)).get("local", {}).get("pop", 0.0))
		v["population"] = pop
		v["p0"] = pop
		v["capacity"] = pop
	_wild_hops(gd, db)


# The places in a province of another region join that region (user decision 2026-11-24: the 15 border places follow
# their province); a place its old region's holder held passes to the new region's holder.
static func _follow_province_regions(gd: GameData, db: WorldDB) -> void:
	for p in db.all("places"):
		var v: Dictionary = db.get_record(TABLE, str(p.get("province_id", "")))
		if v.is_empty() or str(v.region_id) == "" or str(v.region_id) == str(p.get("region_id", "")):
			continue
		var old: Dictionary = db.get_record("regions", str(p.get("region_id", "")))
		var new: Dictionary = db.get_record("regions", str(v.region_id))
		if not old.is_empty():
			old.places.erase(str(p.id))
			if str(p.get("holder", "")) != "" and str(p.get("holder", "")) == str(old.get("holder", "")):
				p["holder"] = str(new.get("holder", ""))
		if not Array(new.places).has(str(p.id)):
			new.places.append(str(p.id))
		p["region_id"] = str(v.region_id)


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
static func season(gd: GameData, db: WorldDB, season_i: int = -1, year: int = 0) -> void:
	if db.count(TABLE) == 0:
		return
	if season_i >= 0:
		events(gd, db, year, season_i)   # Stage 7: modifiers age, new shocks strike
	if season_i == 0:
		yearly(gd, db)   # rule 13 step 2: population, once a year in Spring (Stage 5)
	region_pop(db)
	_season(gd, db)
	ProvinceBuildings.tally_halls(gd, db)   # Stage 4: the halls' totals for the hooks


static func _season(gd: GameData, db: WorldDB) -> void:
	var carry := {}   # wilderness province -> {good: value} still to pass on
	var gathered := {}   # settlement province -> {good: value} from wilderness
	var wild: Array = _wild_order(db)
	for row in wild:
		carry[str(row[0].id)] = modified(gd, row[0], row[0].own_value)   # F4: a wilderness province's own modifiers
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
		if settled:
			prod = modified(gd, v, prod)   # F4: x max(0, 1 + sum inc) x prod max(0, 1 + more) by good kind (rule 12)
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
		if settled:
			_access(gd, db, v, prod)   # F6 (Stage 6)
		v["states"] = states(gd, db, v)   # Stage 7: Normal, Under-connected, Struck, War-touched
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
		var cap: float = p0 * (1.0 + float(c.get("cap0", 0.2)) + capb) * mult_of(v, "capacity", "")
		var cover: float = _staple_cover(db, v)
		var fam: float = float(c.get("famine_cover", 0.6))
		var fed: bool = cover >= fam
		var safe: bool = not _at_war(db, v) and not has_event(v, "beast_tide")   # F3: war or an active tide
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


## F6 (Stage 6): infrastructure from the land (infra0 by seat, road tiles, a river up to river_cap), the old roads and
## porters (infra_old, fixed at the first season to lift a province to start_access_min against its usage then) and
## its logistics buildings at their effective level; usage = the sum over raw kinds of |production - D_loc| in base
## value (D_loc: its share by population of its region's own demand last season, 0 before the first economy tick);
## access = 1 if usage <= infra, else infra / usage. Writes v.infra, v.usage, v.access.
static func _access(gd: GameData, db: WorldDB, v: Dictionary, prod: Dictionary) -> void:
	var a: Dictionary = cfg(gd).get("access", {})
	var land: float = float(a.get("infra0", {}).get(str(v.seat_kind), 100.0)) + float(a.get("i_road", 40.0)) * float(v.get("road_tiles", 0)) \
		+ float(a.get("i_river", 25.0)) * float(mini(int(v.get("river_tiles", 0)), int(a.get("river_cap", 20))))
	var built: float = 0.0
	for b in v.get("buildings", []):
		built += float(ProvinceBuildings.kind(gd, str(b.kind)).get("infra", 0.0)) * float(ProvinceBuildings.effective(gd, b))
	var by_kind := {}
	for g in prod:
		var k: String = WorldEconomy.kind_of(gd, str(g))
		by_kind[k] = float(by_kind.get(k, 0.0)) + float(prod[g])
	var reg: Dictionary = db.get_record("regions", str(v.get("region_id", "")))
	var need: Dictionary = reg.get("d_loc", {})
	var share: float = float(v.get("population", 0.0)) / maxf(float(reg.get("pop_units", 0.0)), 1e-9) if not need.is_empty() else 0.0
	var usage: float = 0.0
	var kinds := {}
	for k in by_kind:
		kinds[k] = true
	for k in need:
		kinds[k] = true
	for k in kinds:
		if not str(k) in a.get("raw_kinds", ["herb", "ore", "beast", "special"]):
			continue
		usage += absf(float(by_kind.get(k, 0.0)) - float(need.get(k, 0.0)) * share)
	if float(v.get("infra_old", -1.0)) < 0.0:   # fixed once: the start floor against the whole production then
		var u0: float = 0.0
		for k in by_kind:
			u0 += float(by_kind[k])
		v["infra_old"] = maxf(0.0, float(a.get("start_access_min", 0.5)) * u0 - (land + built))
	var infra: float = (land + built + float(v.infra_old)) * mult_of(v, "infra", "")   # rule 12: infrastructure modifiers
	v["infra"] = infra
	v["usage"] = usage
	v["access"] = 1.0 if usage <= infra else infra / usage


## Before the economy reads them: each region's settlement population units (for D_loc shares), once a season.
static func region_pop(db: WorldDB) -> void:
	for r in db.all("regions"):
		r["pop_units"] = 0.0
	for v in db.all(TABLE):
		if str(v.kind) == "settlement":
			var r: Dictionary = db.get_record("regions", str(v.get("region_id", "")))
			if not r.is_empty():
				r["pop_units"] = float(r.pop_units) + float(v.get("population", 0.0))


## Rule 12: the factor of province [param v]'s modifiers on [param stat] for good kind [param scope] ("" for any):
## max(0, 1 + sum of inc) x prod of max(0, 1 + more). A modifier with no scope applies to every kind.
static func mult_of(v: Dictionary, stat: String, scope: String) -> float:
	var inc: float = 0.0
	var more: float = 1.0
	for m in v.get("modifiers", []):
		if str(m.get("stat", "")) != stat:
			continue
		if str(m.get("scope", "")) != "" and str(m.get("scope", "")) != scope:
			continue
		if str(m.get("kind", "inc")) == "more":
			more *= maxf(0.0, 1.0 + float(m.value))
		else:
			inc += float(m.value)
	return maxf(0.0, 1.0 + inc) * more


## F4's modifiers on a production dict ({good: value}): each good by its kind's production factor.
static func modified(gd: GameData, v: Dictionary, prod: Dictionary) -> Dictionary:
	if Array(v.get("modifiers", [])).is_empty():
		return Dictionary(prod).duplicate()
	var out := {}
	for g in prod:
		out[g] = float(prod[g]) * mult_of(v, "production", WorldEconomy.kind_of(gd, str(g)))
	return out


## Whether an event modifier of [param event] is active on [param v].
static func has_event(v: Dictionary, event: String) -> bool:
	return Array(v.get("modifiers", [])).any(func(m): return str(m.get("event", "")) == event)


## The province states (States table): any of under_connected (access below strained_access), struck (an event
## modifier active), war_touched (its holder at war); normal when none holds.
static func states(gd: GameData, db: WorldDB, v: Dictionary) -> Array:
	var out: Array = []
	if str(v.kind) == "settlement" and float(v.get("access", 1.0)) < float(cfg(gd).get("events", {}).get("strained_access", 0.7)):
		out.append("under_connected")
	if Array(v.get("modifiers", [])).any(func(m): return str(m.get("event", "")) != ""):
		out.append("struck")
	if _at_war(db, v):
		out.append("war_touched")
	return out if not out.is_empty() else ["normal"]


## Stage 7, each season: modifiers count down and expire; then each province may be struck, from a stream keyed on the
## world seed, the province and the season (deterministic): a blight (herb production inc -0.7), a raid (all production
## inc -0.3, softened by its warding walls) or a beast tide (no growth that year, F3, and a chance to ruin a building
## that walls lower), each for its seasons, as a modifier with a source line and a news event.
static func events(gd: GameData, db: WorldDB, year: int, season_i: int) -> void:
	var ec: Dictionary = cfg(gd).get("events", {})
	var seed_s: String = str(db.get_record("world", "w_meta").get("seed", ""))
	var abs_s: int = year * 4 + season_i
	for v in db.all(TABLE):
		var keep: Array = []
		for m in v.get("modifiers", []):
			if int(m.get("seasons", -1)) < 0:
				keep.append(m)   # lasting (a building or the land)
			elif int(m.seasons) > 1:
				m["seasons"] = int(m.seasons) - 1
				keep.append(m)
		v["modifiers"] = keep
		for ev in ec.get("kinds", {}):
			var e: Dictionary = ec.kinds[ev]
			if str(e.get("where", "any")) == "settlement" and str(v.kind) != "settlement":
				continue
			if has_event(v, str(ev)):
				continue
			var roll: float = float(RngUtils.stable_hash("%s|%s|%d|%s" % [seed_s, str(v.id), abs_s, str(ev)]) % 1000000) / 1000000.0
			if roll >= float(e.get("chance", 0.0)):
				continue
			var walls: int = 0
			for b in v.get("buildings", []):
				if str(b.kind) == "warding_wall":
					walls += ProvinceBuildings.effective(gd, b)
			var soften: float = 1.0 / (1.0 + float(e.get("wall_soften", 0.0)) * float(walls))
			var val: float = float(e.get("value", 0.0)) * soften
			v.modifiers.append({"stat": str(e.get("stat", "production")), "scope": str(e.get("scope", "")), "kind": "inc",
				"value": val, "seasons": int(e.get("seasons", 1)), "event": str(ev), "source": str(e.get("source", ev))})
			if float(e.get("ruin_chance", 0.0)) > 0.0:   # a tide may wreck a building; walls lower the chance
				var r2: float = float(RngUtils.stable_hash("%s|%s|%d|%s|ruin" % [seed_s, str(v.id), abs_s, str(ev)]) % 1000000) / 1000000.0
				var live: Array = Array(v.get("buildings", [])).filter(func(b): return str(b.state) == "active" and str(b.kind) != "warding_wall")
				if r2 < float(e.ruin_chance) * soften and not live.is_empty():
					live[int(RngUtils.stable_hash("%s|%s|%d|pick" % [seed_s, str(v.id), abs_s]) % live.size())]["state"] = "ruined"
			if bool(ec.get("log", true)):
				db.log_event(year, season_i, "province_" + str(ev), str(e.get("news", "%s: %s.")) % [str(v.get("name", v.id)), str(e.get("source", ev))], [], [], [])


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
