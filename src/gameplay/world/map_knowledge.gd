class_name MapKnowledge
extends RefCounted

## What the player knows of the map (design/gdd/travel-map.md rules 14-17 and 29-30, Formula F). NPCs know their own
## region, kept abstract, so only the player carries this.
##
## - Known tiles show their main biome; crossed tiles (stood on or travelled over) also show their full mix.
## - Known places: the overview's common knowledge (every city, the sect seats, the famous sites), the home region,
##   and every place seen, visited or heard of since.
## - Clues to hidden places (a rumour names a region, a jade slip a small area, a map the exact tile), each with a
##   quality and sometimes false; the truth stays in the world's ledger and is never shown.
## - Found hidden places and tile secrets (per-character knowledge, rule 29).
##
## Sight (Formula F): r = min(r_max, round(r_k * sqrt(DS / DS_ref))) tiles around each tile of a trip (Chebyshev).
##
## Usage:
## [codeblock]
## var k := MapKnowledge.start(gd, db, player)
## k.reveal_path(trip.tiles, MapKnowledge.sight_radius(gd, divine_sense))
## print(k.knows_place("l52"), " ", k.known_tile_count())
## [/codeblock]

const RULES_FILE := "travel_rules"

var width: int = 0
var height: int = 0
var _known: PackedByteArray
var _crossed: PackedByteArray
## Place ids the player knows.
var places: Dictionary = {}
## Clues held: [{slot, kind (rumour | jade_slip | map), region, area: [[x, y]...] or [], tile, quality, false}].
var clues: Array = []
## Slot ids of hidden places and tile secrets found: {slot: {year, how}}.
var found: Dictionary = {}


## Formula F's sight radius in tiles for divine sense [param ds].
static func sight_radius(gd: GameData, ds: float) -> int:
	var f: Dictionary = gd.file(RULES_FILE).get("search", {})
	var r: float = float(f.get("r_k", 4.4)) * sqrt(maxf(ds, 0.0) / float(f.get("sense_ref", 135.0)))
	return mini(int(f.get("r_max", 36)), int(round(r)))


## Formula F's chance to notice something hidden at [param h] with divine sense [param ds]: DS / (DS + H).
static func detect(ds: float, h: float) -> float:
	return ds / maxf(ds + h, 0.0001)


## The player's knowledge at the start of a life (rule 14): the overview (cities, sect seats, famous sites, the trunk
## roads between cities) and the home region's tiles and places.
static func start(gd: GameData, db: WorldDB, c: Character) -> MapKnowledge:
	var k := MapKnowledge.new()
	var grid := ContinentGrid.from_continent(gd)
	if not grid.errors.is_empty():
		return k
	k.width = grid.width
	k.height = grid.height
	k._known.resize(k.width * k.height / 8 + 1)
	k._crossed.resize(k.width * k.height / 8 + 1)
	var home: Dictionary = db.get_record("places", c.home_id)
	var region_cid: int = int(db.get_record("regions", str(home.get("region_id", ""))).get("continent_id", -1))
	for y in k.height:
		for x in k.width:
			if grid.road(x, y) == ContinentGrid.ROAD_TRUNK or (region_cid > 0 and grid.region(x, y) == region_cid):
				k._bit_set(k._known, x, y)
	var overview: Array = gd.file(RULES_FILE).get("overview_kinds", ["city", "great_seat", "minor_seat"])
	for p in db.all("places"):
		if bool(p.get("hidden", false)):
			continue
		if str(p.get("kind", "")) in overview or bool(p.get("famous", false)) or str(p.get("region_id", "")) == str(home.get("region_id", "")):
			k.places[str(p.id)] = true
	k.places[str(c.home_id)] = true
	k.places[str(c.location_id)] = true
	k.signposts(db, str(c.location_id))
	return k


## The places a road or lane from [param place_id] leads to become known (the signposts where one stands).
func signposts(db: WorldDB, place_id: String) -> void:
	places[place_id] = true
	for l in db.get_record("places", place_id).get("links", []):
		places[str(l.to)] = true


## Marks the tiles of a trip crossed and the band of [param r] tiles around them known; places on those tiles become
## known. Returns the ids of places newly seen.
func reveal_path(db: WorldDB, tiles: Array, r: int) -> Array:
	if width == 0:
		return []
	var seen := {}
	for t in tiles:
		var v := Vector2i(t) if t is Vector2i else Vector2i(int(t[0]), int(t[1]))
		_bit_set(_crossed, v.x, v.y)
		for y in range(maxi(0, v.y - r), mini(height, v.y + r + 1)):
			for x in range(maxi(0, v.x - r), mini(width, v.x + r + 1)):
				_bit_set(_known, x, y)
	var fresh: Array = []
	for p in db.all("places"):
		if bool(p.get("hidden", false)) or places.has(str(p.id)) or not p.has("tile"):
			continue
		if knows_tile(int(p.tile[0]), int(p.tile[1])):
			places[str(p.id)] = true
			fresh.append(str(p.id))
	return fresh


func knows_tile(x: int, y: int) -> bool:
	return _bit_get(_known, x, y)


func crossed_tile(x: int, y: int) -> bool:
	return _bit_get(_crossed, x, y)


func knows_place(id: String) -> bool:
	return places.has(id)


func known_tile_count() -> int:
	var n: int = 0
	for b in _known:
		var v: int = b
		while v:
			n += v & 1
			v >>= 1
	return n


func _bit_set(bits: PackedByteArray, x: int, y: int) -> void:
	if x < 0 or y < 0 or x >= width or y >= height:
		return
	var i: int = y * width + x
	bits[i >> 3] = bits[i >> 3] | (1 << (i & 7))


func _bit_get(bits: PackedByteArray, x: int, y: int) -> bool:
	if x < 0 or y < 0 or x >= width or y >= height or bits.is_empty():
		return false
	var i: int = y * width + x
	return (bits[i >> 3] & (1 << (i & 7))) != 0


func to_dict() -> Dictionary:
	return {"w": width, "h": height, "known": Marshalls.raw_to_base64(_known), "crossed": Marshalls.raw_to_base64(_crossed),
		"places": places.keys(), "clues": clues.duplicate(true), "found": found.duplicate(true)}


static func from_dict(d: Dictionary) -> MapKnowledge:
	var k := MapKnowledge.new()
	k.width = int(d.get("w", 0))
	k.height = int(d.get("h", 0))
	k._known = Marshalls.base64_to_raw(str(d.get("known", "")))
	k._crossed = Marshalls.base64_to_raw(str(d.get("crossed", "")))
	for id in d.get("places", []):
		k.places[str(id)] = true
	k.clues = Array(d.get("clues", [])).duplicate(true)
	k.found = Dictionary(d.get("found", {})).duplicate(true)
	return k
