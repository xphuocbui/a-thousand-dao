class_name ContinentData
extends RefCounted
## The authored continent every game is played on (design/research/fixed-world-decisions.md; Travel & Map), loaded
## from assets/data/world_continent.json, which tools/design/map/export_continent.py writes from the approved design
## data in design/map/continent-11. Regions, the 7 great and 22 minor sects with their seats, the places (settled,
## wild and sacred), the routes between them (road, trunk road, sea lane; lengths in tiles and km) and the teleport-array
## cities. Read-only; [member errors] lists every broken cross-reference found at load.
##
## Groundwork (2026-11-15): nothing in the game reads it yet. World Generation & History (#27) is to build the world
## from it instead of generating one, and Travel & Map's Formula D is to turn route lengths into travel time.
##
## Usage:
## [codeblock]
## var cd := ContinentData.from_game_data(gd)
## if not cd.errors.is_empty(): push_error("\n".join(cd.errors))
## for r in cd.neighbours(55): print(cd.places[r.to].name, " ", r.km, " km by ", r.kind)
## [/codeblock]

const DATA_FILE := "world_continent"
## The kinds of place that are settlements (the reachability check of Travel & Map AC-TM-128 counts these).
const SETTLED := ["great_seat", "minor_seat", "city", "market", "town", "sect_hall", "village", "mine"]
const ROUTE_KINDS := ["road", "trunk", "lane", "track"]   # track: a provinces-v2 footpath (2026-11-24)

var grid: Vector2i = Vector2i.ZERO
var km_per_tile: float = 0.0
## Region id -> record; great and minor sect key -> record; place id -> record.
var regions: Dictionary = {}
var great_sects: Dictionary = {}
var minor_sects: Dictionary = {}
var places: Dictionary = {}
## Every route record {a, b, kind, tiles, km, cost}, a < b (cost: Formula D's sum of c_t along it).
var routes: Array = []
## The teleport-array cities' place ids.
var arrays: PackedInt32Array = []
## The origins' home choices, as approved, and per origin id the place ids its characters may start at.
var origins: Dictionary = {}
var origin_homes: Dictionary = {}
## Problems found while loading; empty when the data is consistent.
var errors: PackedStringArray = []
var _adj: Dictionary = {}   # place id -> [{to, kind, tiles, km}]


## The continent in the game's loaded data.
static func from_game_data(gd: GameData) -> ContinentData:
	return from_dict(gd.file(DATA_FILE))


## The continent from the parsed file (ids come back from JSON as floats; they are made ints here). It reads a copy:
## [param src] is the loaded game data, shared by every game in the process, and stays as it was.
static func from_dict(src: Dictionary) -> ContinentData:
	var cd := ContinentData.new()
	var d: Dictionary = src.duplicate(true)
	if d.is_empty():
		cd.errors.append("world_continent.json is not in the game data (run tools/design/map/export_continent.py)")
		return cd
	var g: Array = d.get("grid", [0, 0])
	cd.grid = Vector2i(int(g[0]), int(g[1]))
	cd.km_per_tile = float(d.get("km_per_tile", 0.0))
	for r in d.get("regions", []):
		r["id"] = int(r.id)
		cd.regions[r.id] = r
	for s in d.get("great_sects", []):
		cd.great_sects[str(s.key)] = s
	for s in d.get("minor_sects", []):
		cd.minor_sects[str(s.key)] = s
	for p in d.get("places", []):
		p["id"] = int(p.id)
		p["region"] = int(p.region)
		cd.places[p.id] = p
	for rt in d.get("routes", []):
		rt["a"] = int(rt.a)
		rt["b"] = int(rt.b)
		cd.routes.append(rt)
		for end in [[rt.a, rt.b], [rt.b, rt.a]]:
			if not cd._adj.has(end[0]):
				cd._adj[end[0]] = []
			cd._adj[end[0]].append({"to": end[1], "kind": str(rt.kind), "tiles": float(rt.tiles), "km": float(rt.km),
				"cost": float(rt.get("cost", rt.tiles))})
	for id in d.get("arrays", []):
		cd.arrays.append(int(id))
	cd.origins = d.get("origins", {})
	var oh: Dictionary = d.get("origin_homes", {})
	for oid in oh:
		cd.origin_homes[str(oid)] = (oh[oid] as Array).map(func(x): return int(x))
	cd._validate()
	return cd


## The routes leaving place [param place_id]: [{to, kind, tiles, km, cost}] ([] for a place no route reaches).
func neighbours(place_id: int) -> Array:
	return _adj.get(place_id, [])


## Travel & Map Formula D for route [param route] (a route record or a [method neighbours] entry): its cost over the
## mode's speed (road and trunk by road, lane by sea; [param travel] is travel_rules.json), the speed raised by
## [param travel_speed_pct] but never below travel_speed_floor. In seasons.
static func trip_seasons(route: Dictionary, travel: Dictionary, travel_speed_pct: float = 0.0) -> float:
	var v: float = float(travel.speed.sea) if str(route.kind) == "lane" else float(travel.speed.road)
	var f: float = maxf(float(travel.travel_speed_floor), 1.0 + travel_speed_pct / 100.0)
	return float(route.get("cost", route.get("tiles", 0.0))) / (v * f)


## Every place reachable from [param place_id] along routes (roads, trunk roads, sea lanes), itself included, as a
## set {id: true}. Teleport arrays are not counted: who may use them is Travel & Map rule 11's.
func reachable_from(place_id: int) -> Dictionary:
	var seen := {place_id: true}
	var todo: Array = [place_id]
	while not todo.is_empty():
		var x: int = todo.pop_back()
		for r in neighbours(x):
			if not seen.has(r.to):
				seen[r.to] = true
				todo.append(r.to)
	return seen


## The ids of the places of the settled kinds.
func settled_ids() -> Array:
	return places.keys().filter(func(id): return SETTLED.has(str(places[id].kind)))


## Whether [param key] is a great or a minor sect's key.
func is_sect(key: String) -> bool:
	return great_sects.has(key) or minor_sects.has(key)


func _validate() -> void:
	if grid.x <= 0 or grid.y <= 0 or km_per_tile <= 0.0:
		errors.append("grid %s or km_per_tile %s is missing" % [str(grid), str(km_per_tile)])
	for id in regions:
		var r: Dictionary = regions[id]
		if not great_sects.has(str(r.holder)):
			errors.append("region %d (%s): holder %s is not a great sect" % [id, str(r.name), str(r.holder)])
	for key in great_sects:
		var s: Dictionary = great_sects[key]
		for rid in s.get("regions", []):
			if not regions.has(int(rid)):
				errors.append("great sect %s: region %s does not exist" % [key, str(rid)])
			elif str(regions[int(rid)].holder) != key:
				errors.append("great sect %s claims region %s, held by %s" % [key, str(rid), str(regions[int(rid)].holder)])
		_check_seat(key, s, "great_seat")
	for key in minor_sects:
		var s: Dictionary = minor_sects[key]
		if not great_sects.has(str(s.lord)):
			errors.append("minor sect %s: lord %s is not a great sect" % [key, str(s.lord)])
		if not regions.has(int(s.region)):
			errors.append("minor sect %s: region %s does not exist" % [key, str(s.region)])
		_check_seat(key, s, "minor_seat")
	for id in places:
		var p: Dictionary = places[id]
		var t: Array = p.get("tile", [])
		if t.size() != 2 or int(t[0]) < 0 or int(t[1]) < 0 or int(t[0]) >= grid.x or int(t[1]) >= grid.y:
			errors.append("place %d (%s): tile %s is off the grid" % [id, str(p.name), str(t)])
		if not regions.has(int(p.region)):
			errors.append("place %d (%s): region %d does not exist" % [id, str(p.name), int(p.region)])
		if str(p.get("holder", "")) != "" and not is_sect(str(p.holder)):
			errors.append("place %d (%s): holder %s is not a sect" % [id, str(p.name), str(p.holder)])
		if not great_sects.has(str(p.get("territory", ""))):
			errors.append("place %d (%s): territory %s is not a great sect" % [id, str(p.name), str(p.get("territory", ""))])
	for rt in routes:
		if not places.has(rt.a) or not places.has(rt.b):
			errors.append("route %d-%d: a place does not exist" % [rt.a, rt.b])
		elif rt.a >= rt.b:
			errors.append("route %d-%d: ends are not in order" % [rt.a, rt.b])
		if not ROUTE_KINDS.has(str(rt.kind)):
			errors.append("route %d-%d: kind %s is not road, trunk or lane" % [rt.a, rt.b, str(rt.kind)])
		if float(rt.km) <= 0.0:
			errors.append("route %d-%d: length %s km" % [rt.a, rt.b, str(rt.km)])
	for id in arrays:
		if not places.has(id) or not bool(places[id].get("array", false)):
			errors.append("array %d is not a teleport-array place" % id)
	for oid in origin_homes:
		for id in origin_homes[oid]:
			if not places.has(id):
				errors.append("origin %s: home %d is not a place" % [oid, id])


func _check_seat(key: String, s: Dictionary, kind: String) -> void:
	if s.get("seat") == null or not places.has(int(s.seat)):
		errors.append("%s %s: seat %s is not a place" % [kind, key, str(s.get("seat"))])
		return
	var seat: Dictionary = places[int(s.seat)]
	if str(seat.kind) != kind or str(seat.get("key", "")) != key:
		errors.append("%s %s: seat %d is a %s of %s" % [kind, key, int(s.seat), str(seat.kind), str(seat.get("key", ""))])
