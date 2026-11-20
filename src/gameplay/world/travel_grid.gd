class_name TravelGrid
extends RefCounted

## Travel across the continent's tiles (design/gdd/travel-map.md rules 9-13, Formulas D and E). Every tile has a
## mode and a cost: a road or trunk-road tile is walked at road speed with c_t = 1 + r_share * (c_wild - 1); a sea-lane
## tile is sailed at sea speed; a river or lake tile is boated, downstream or upstream by the elevation step; any
## other land tile is wilderness at c_wild (the land parts' biome costs by share, water parts walked around); sea
## tiles off the lanes are impassable. Flight (Foundation Establishment and up) ignores terrain at its realm's speed.
## A trip is the quickest tile path (AStarGrid2D), and its time is Formula D's sum over the tiles, divided by the
## speed factor.
##
## Formula E: each season of a trip (a stretch) draws at most one encounter, with chance
## 1 - exp(-sum h[d_t] * m_mode * dt_t) over the stretch's tiles.
##
## The grid is built once per game data ([method of]); it reads [ContinentGrid] (biome mix, ROAD, FEAT river bit,
## ELEV, the qi layer's danger) and travel_rules.json.
##
## Usage:
## [codeblock]
## var tg := TravelGrid.of(gd)
## var trip: Dictionary = tg.trip(Vector2i(147, 95), Vector2i(244, 206), "ground", 1.2)
## print(trip.seasons, " seasons, ", trip.by_mode)
## [/codeblock]

const RULES_FILE := "travel_rules"
const MODE_NONE := 0
const MODE_WILD := 1
const MODE_ROAD := 2
const MODE_RIVER := 3
const MODE_SEA := 4
const MODE_NAMES := ["none", "wilderness", "road", "river", "sea", "flight"]
const RIVER_BIT := 8

static var _cache: Dictionary = {}

## Problems found while building; empty when travel by tile is usable.
var errors: PackedStringArray = []
var width: int = 0
var height: int = 0
var _rules: Dictionary
var _grid: ContinentGrid
var _mode: PackedByteArray
var _cost: PackedFloat32Array     # c_t per tile (seasons per tile at base speed = c_t / v_mode)
var _danger: PackedByteArray
var _elev: PackedInt32Array
var _ground: AStarGrid2D
var _air: AStarGrid2D
var _unit: float = 1.0            # the cheapest seasons-per-tile: A* weights are dt / _unit, so they stay >= 1
var _regions: Dictionary = {}     # continent region id -> {tiles: wilderness tiles, mean_cost: their mean c_t}


## The travel grid of [param gd]'s continent, built once and cached; null when the continent has no grid.
static func of(gd: GameData) -> TravelGrid:
	var key: int = gd.get_instance_id()
	if not _cache.has(key):
		var tg := TravelGrid.new()
		tg._build(gd)
		_cache[key] = tg
	return _cache[key]


func _build(gd: GameData) -> void:
	_rules = gd.file(RULES_FILE)
	_grid = ContinentGrid.from_continent(gd)
	if not _grid.errors.is_empty():
		errors.append_array(_grid.errors)
		return
	width = _grid.width
	height = _grid.height
	var n: int = width * height
	_mode.resize(n)
	_cost.resize(n)
	_danger.resize(n)
	_elev.resize(n)
	var bcost: Dictionary = _rules.biome_cost
	var names: Dictionary = {}
	var legend: Dictionary = gd.file(ContinentData.DATA_FILE).get("legend", {}).get("biome_ids", {})
	for k in legend:
		names[int(k)] = str(legend[k]).to_lower().replace(" ", "_")
	var share_r: float = float(_rules.road_terrain_share)
	var sp: Dictionary = _rules.speed
	_unit = 1.0 / maxf(float(sp.sea), float(sp.river_down))
	_ground = AStarGrid2D.new()
	_ground.region = Rect2i(0, 0, width, height)
	_ground.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ALWAYS   # as the exported routes step (export_continent.py N8)
	_ground.update()
	var place_tiles := {}
	for p in gd.file(ContinentData.DATA_FILE).get("places", []):
		place_tiles[Vector2i(int(p.tile[0]), int(p.tile[1]))] = true
	for y in height:
		for x in width:
			var i: int = y * width + x
			_elev[i] = _grid.elevation_m(x, y)
			_danger[i] = _tile_danger(x, y)
			var road: int = _grid.road(x, y)
			var main: int = _grid.main_biome(x, y)
			var c_wild: float = _wild_cost(x, y, bcost, names)
			var mode: int = MODE_WILD
			var c: float = c_wild
			if road == ContinentGrid.ROAD_LANE:
				mode = MODE_SEA
				c = 1.0
			elif road == ContinentGrid.ROAD_ROAD or road == ContinentGrid.ROAD_TRUNK:
				mode = MODE_ROAD
				c = 1.0 + share_r * (c_wild - 1.0)
			elif _grid.features(x, y) & RIVER_BIT or main == ContinentGrid.LAKE_ID:
				mode = MODE_RIVER   # boats on rivers and lakes (rule 9), so a lake place can be rowed to
				c = 1.0
			elif main == ContinentGrid.SEA_ID or c_wild <= 0.0:
				mode = MODE_NONE
				if place_tiles.has(Vector2i(x, y)):   # a lake or island place: its own tile can be stood on
					mode = MODE_WILD
					c = maxf(c_wild, 1.0)
			_mode[i] = mode
			_cost[i] = c
			if mode == MODE_WILD:
				var rid: int = _grid.region(x, y)
				var st: Dictionary = _regions.get(rid, {"tiles": 0, "sum": 0.0})
				st.tiles += 1
				st.sum += c
				_regions[rid] = st
			if mode == MODE_NONE:
				_ground.set_point_solid(Vector2i(x, y), true)
			else:
				# plan rivers at the slower upstream speed; the trip's time is worked out exactly afterwards
				_ground.set_point_weight_scale(Vector2i(x, y), c / _speed(mode, false) / _unit)
	_air = AStarGrid2D.new()
	_air.region = Rect2i(0, 0, width, height)
	_air.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ALWAYS
	_air.update()


## The tile's danger over its land parts by share (Formula C tile_values), 1-4; the largest part for a water tile.
func _tile_danger(x: int, y: int) -> int:
	if not _grid.has_qi():
		return 1
	var tot: float = 0.0
	var w: float = 0.0
	for k in 3:
		var b: int = _grid.value("BIO%d" % (k + 1), x, y)
		var s: float = float(_grid.value("SHR%d" % (k + 1), x, y))
		if s <= 0.0 or b == ContinentGrid.SEA_ID or b == ContinentGrid.LAKE_ID or b == 255:
			continue
		tot += s * float(_grid.value("DAN%d" % (k + 1), x, y))
		w += s
	if w <= 0.0:
		return clampi(_grid.value("DAN1", x, y), 1, 4)
	return clampi(int(floor(tot / w + 0.5)), 1, 4)


## c_wild of a tile: its land parts' biome costs weighted by share; 0 when it has no land part.
func _wild_cost(x: int, y: int, bcost: Dictionary, names: Dictionary) -> float:
	var tot: float = 0.0
	var w: float = 0.0
	for k in 3:
		var b: int = _grid.value("BIO%d" % (k + 1), x, y)
		var s: float = float(_grid.value("SHR%d" % (k + 1), x, y))
		if s <= 0.0 or b == ContinentGrid.SEA_ID or b == ContinentGrid.LAKE_ID or b == 255:
			continue
		tot += s * float(bcost.get(names.get(b, ""), 1.5))
		w += s
	return tot / w if w > 0.0 else 0.0


func _speed(mode: int, downstream: bool) -> float:
	var sp: Dictionary = _rules.speed
	match mode:
		MODE_ROAD:
			return float(sp.road)
		MODE_SEA:
			return float(sp.sea)
		MODE_RIVER:
			return float(sp.river_down) if downstream else float(sp.river_up)
		_:
			return float(sp.wilderness)


## A region's wilderness for Formula F's search: {tiles, mean_cost} (continent region id).
func region_stats(region_cid: int) -> Dictionary:
	var st: Dictionary = _regions.get(region_cid, {"tiles": 0, "sum": 0.0})
	return {"tiles": int(st.tiles), "mean_cost": float(st.sum) / maxf(1.0, float(st.tiles)) if int(st.tiles) > 0 else 1.5}


## The flight speed of realm [param realm_id] (tiles a season), 0 when that realm cannot fly.
func flight_speed(realm_id: String) -> float:
	return float(_rules.speed.flight.get(realm_id, 0.0))


## Whether a tile can be stood on (land, a road, a river or a lane).
func passable(t: Vector2i) -> bool:
	return _in(t) and _mode[t.y * width + t.x] != MODE_NONE


## The trip from tile [param a] to tile [param b] by [param how] ("ground" or "flight"), at speed factor [param f]
## (Formula D's max(f_min, 1 + tsp / 100)) and, for flight, the realm's [param fly_speed]: {tiles: [Vector2i],
## steps: [{tile, mode, dt, danger}], seasons, by_mode: {mode name: seasons}}; {} when there is no way.
func trip(a: Vector2i, b: Vector2i, how: String = "ground", f: float = 1.0, fly_speed: float = 0.0) -> Dictionary:
	if not _in(a) or not _in(b) or a == b:
		return {}
	var path: Array[Vector2i] = []
	if how == "flight":
		if fly_speed <= 0.0:
			return {}
		path = _air.get_id_path(a, b)
	else:
		if not passable(a) or not passable(b):
			return {}
		path = _ground.get_id_path(a, b)
	if path.size() < 2:
		return {}
	var steps: Array = []
	var by_mode := {}
	var total: float = 0.0
	for k in range(1, path.size()):
		var p: Vector2i = path[k - 1]
		var t: Vector2i = path[k]
		var i: int = t.y * width + t.x
		var step: float = 1.0 if (p.x == t.x or p.y == t.y) else sqrt(2.0)
		var mode: int = _mode[i]
		var dt: float
		var name: String
		if how == "flight":
			dt = step / (fly_speed * f)
			name = MODE_NAMES[5]
		else:
			var down: bool = _elev[i] < _elev[p.y * width + p.x]
			dt = step * float(_cost[i]) / (_speed(mode, down) * f)
			name = MODE_NAMES[mode]
		total += dt
		by_mode[name] = float(by_mode.get(name, 0.0)) + dt
		steps.append({"tile": t, "mode": name, "dt": dt, "danger": int(_danger[i])})
	return {"tiles": path, "steps": steps, "seasons": total, "by_mode": by_mode}


## Formula E for a trip: the stretches (one per season, by cumulative time) and each one's encounter chance
## 1 - exp(-sum h[d_t] * m_mode * dt_t). Returns [{season, chance, tile, mode, danger}] (tile and mode: where the
## stretch spent most of its time, for the encounter's setting).
func stretches(trip_rec: Dictionary) -> Array:
	var hz: Array = _rules.get("hazard_per_season", [0.15, 0.35, 0.7, 1.2])
	var mf: Dictionary = _rules.get("mode_factor", {})
	var out: Array = []
	var acc: float = 0.0
	var cur := {"season": 0, "sum": 0.0, "weight": {}, "best": {}}
	for st in trip_rec.get("steps", []):
		var dt: float = float(st.dt)
		while dt > 0.0:
			var room: float = float(cur.season + 1) - acc
			var take: float = minf(dt, room)
			var h: float = float(hz[clampi(int(st.danger) - 1, 0, hz.size() - 1)])
			cur.sum += h * float(mf.get(str(st.mode), 1.0)) * take
			var key: String = "%s|%d" % [st.mode, int(st.danger)]
			cur.weight[key] = float(cur.weight.get(key, 0.0)) + take
			if float(cur.weight[key]) >= float(cur.best.get("w", -1.0)):
				cur.best = {"w": cur.weight[key], "tile": st.tile, "mode": st.mode, "danger": int(st.danger)}
			acc += take
			dt -= take
			if acc >= float(cur.season + 1) - 1e-9 and dt > 0.0:
				out.append(_close(cur))
				cur = {"season": int(cur.season) + 1, "sum": 0.0, "weight": {}, "best": {}}
	if not cur.best.is_empty():
		out.append(_close(cur))
	return out


static func _close(cur: Dictionary) -> Dictionary:
	return {"season": int(cur.season), "chance": 1.0 - exp(-float(cur.sum)), "tile": cur.best.tile,
		"mode": str(cur.best.mode), "danger": int(cur.best.danger)}


## The main biome id of a tile (for an encounter's setting).
func biome_at(t: Vector2i) -> int:
	return _grid.main_biome(t.x, t.y) if _in(t) else -1


func _in(t: Vector2i) -> bool:
	return t.x >= 0 and t.y >= 0 and t.x < width and t.y < height
