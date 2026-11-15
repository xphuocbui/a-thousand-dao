class_name ContinentGrid
extends RefCounted
## The authored continent's tile grid (540 x 360 tiles of 25 km; design/research/map-making-rules.md), read exactly
## from the binary file tools/design/map/export_continent.py writes (world_continent.json "grid_file"): per tile up to
## three biomes with their shares, the main biome, elevation, temperature, rainfall, feature bits, the road layer and
## the region. Read-only. Groundwork (2026-11-15): Travel & Map's land qi (Formula C), wilderness travel (Formula D)
## and encounters will read it; nothing does yet.
##
## Usage:
## [codeblock]
## var g := ContinentGrid.load_file(cd.grid_file)
## if not g.errors.is_empty(): push_error("\n".join(g.errors))
## for part in g.biome_mix(147, 95): print(g.biome_name(part[0]), " ", part[1], " %")
## [/codeblock]

const MAGIC := "DAOGRID1"
## The ROAD layer's values.
const ROAD_NONE := 0
const ROAD_ROAD := 1
const ROAD_TRUNK := 2
const ROAD_LANE := 3

var width: int = 0
var height: int = 0
## Problems found while loading; empty when the grid is usable.
var errors: PackedStringArray = []
var _layers: Dictionary = {}   # tag -> {bytes, signed, data: PackedByteArray}
var _biome_names: Dictionary = {}


## Reads the grid at [param path]; [param legend] is world_continent.json "legend" (biome names; may be empty).
static func load_file(path: String, legend: Dictionary = {}) -> ContinentGrid:
	var g := ContinentGrid.new()
	for k in legend.get("biome_ids", {}):
		g._biome_names[int(k)] = str(legend.biome_ids[k])
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		g.errors.append("%s: cannot open (%s)" % [path, error_string(FileAccess.get_open_error())])
		return g
	var buf: PackedByteArray = f.get_buffer(f.get_length())
	f.close()
	if buf.size() < 14 or buf.slice(0, 8).get_string_from_ascii() != MAGIC:
		g.errors.append("%s: not a continent grid" % path)
		return g
	g.width = buf.decode_u16(8)
	g.height = buf.decode_u16(10)
	var n: int = buf.decode_u16(12)
	var at: int = 14
	for i in n:
		if at + 14 > buf.size():
			g.errors.append("%s: layer %d is cut short" % [path, i])
			return g
		var tag: String = buf.slice(at, at + 4).get_string_from_ascii()
		var nb: int = buf.decode_u8(at + 4)
		var signed: bool = buf.decode_u8(at + 5) == 1
		var raw_len: int = buf.decode_u32(at + 6)
		var comp_len: int = buf.decode_u32(at + 10)
		at += 14
		var data: PackedByteArray = buf.slice(at, at + comp_len).decompress(raw_len, FileAccess.COMPRESSION_DEFLATE)
		at += comp_len
		if data.size() != raw_len or raw_len != g.width * g.height * nb:
			g.errors.append("%s: layer %s has %d bytes, wanted %d" % [path, tag, data.size(), g.width * g.height * nb])
			continue
		g._layers[tag] = {"bytes": nb, "signed": signed, "data": data}
	for tag in ["BIO1", "BIO2", "BIO3", "SHR1", "SHR2", "SHR3", "MAIN", "ELEV", "TEMP", "RAIN", "FEAT", "ROAD", "REGN"]:
		if not g._layers.has(tag):
			g.errors.append("%s: layer %s is missing" % [path, tag])
	return g


## The continent's grid from its data ([ContinentData]).
static func from_continent(gd: GameData) -> ContinentGrid:
	var d: Dictionary = gd.file(ContinentData.DATA_FILE)
	return load_file(str(d.get("grid_file", "")), d.get("legend", {}))


## The raw value of layer [param tag] at tile ([param x], [param y]); 0 off the grid.
func value(tag: String, x: int, y: int) -> int:
	if x < 0 or y < 0 or x >= width or y >= height or not _layers.has(tag):
		return 0
	var l: Dictionary = _layers[tag]
	var i: int = (y * width + x) * int(l.bytes)
	var data: PackedByteArray = l.data
	if int(l.bytes) == 1:
		return data.decode_u8(i)
	return data.decode_s16(i) if bool(l.signed) else data.decode_u16(i)


## The tile's biomes and their shares, largest first: [[biome id, share %], ...] (1 to 3 parts).
func biome_mix(x: int, y: int) -> Array:
	var out: Array = []
	for k in 3:
		var b: int = value("BIO%d" % (k + 1), x, y)
		var sh: int = value("SHR%d" % (k + 1), x, y)
		if b != 255 and sh > 0:
			out.append([b, sh])
	return out


## The tile's main biome id (sea when sea covers half of it or more).
func main_biome(x: int, y: int) -> int:
	return value("MAIN", x, y)


## A biome's name (the legend's id; "" when unknown).
func biome_name(id: int) -> String:
	return str(_biome_names.get(id, ""))


## Elevation in metres (below 0 under the sea).
func elevation_m(x: int, y: int) -> int:
	return value("ELEV", x, y)


## Annual mean temperature in degrees C.
func temperature_c(x: int, y: int) -> float:
	return float(value("TEMP", x, y)) / 2.0 - 50.0


## Annual rainfall in mm.
func rainfall_mm(x: int, y: int) -> int:
	return value("RAIN", x, y)


## The tile's feature bits (world_continent.json legend.feature_bits).
func features(x: int, y: int) -> int:
	return value("FEAT", x, y)


## ROAD_NONE, ROAD_ROAD, ROAD_TRUNK or ROAD_LANE.
func road(x: int, y: int) -> int:
	return value("ROAD", x, y)


## The tile's region id (0 for sea).
func region(x: int, y: int) -> int:
	return value("REGN", x, y)
