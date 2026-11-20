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

## The qi layers' element tags (tools/design/map/land_qi.py): the five base elements are S layers, the variants V.
const QI_TAGS := {"moc": "MO", "hoa": "HO", "tho": "TH", "kim": "KI", "thuy": "TY", "phong": "PH", "huyet": "HU",
	"hu_khong": "HK", "loi": "LO", "am": "AM", "hon_don": "HD", "quang": "QU", "bang": "BA"}
## Biome ids of the water parts (world_continent.json legend).
const LAKE_ID := 17
const SEA_ID := 18

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
	if not g._read(path):
		return g
	for tag in ["BIO1", "BIO2", "BIO3", "SHR1", "SHR2", "SHR3", "MAIN", "ELEV", "TEMP", "RAIN", "FEAT", "ROAD", "REGN"]:
		if not g._layers.has(tag):
			g.errors.append("%s: layer %s is missing" % [path, tag])
	return g


## Adds the land-qi layers (Travel & Map Formula C, tools/design/map/land_qi.py; world_continent.json "qi_file"):
## per tile part k = 1..3, S<k><el> and V<k><el> (base shares and variants x 100), DEN<k> (density x 1000), DAN<k>.
## Returns false (with [member errors]) when the file is missing, has another size, or lacks a layer.
func load_qi(path: String) -> bool:
	var w0: int = width
	var h0: int = height
	if not _read(path):
		return false
	if width != w0 or height != h0:
		errors.append("%s: %d x %d, the grid is %d x %d" % [path, width, height, w0, h0])
		return false
	var ok: bool = true
	for k in range(1, 4):
		for e in QI_TAGS:
			if not _layers.has("S%d%s" % [k, QI_TAGS[e]]) and not _layers.has("V%d%s" % [k, QI_TAGS[e]]):
				errors.append("%s: no layer for %s, part %d" % [path, e, k])
				ok = false
		for t in ["DEN%d" % k, "DAN%d" % k]:
			if not _layers.has(t):
				errors.append("%s: layer %s is missing" % [path, t])
				ok = false
	return ok


## Whether the land-qi layers are loaded.
func has_qi() -> bool:
	return _layers.has("DEN1")


## The qi of part [param k] (0-2, largest first) of tile ([param x], [param y]): {shares: {el: 0-100}, variants:
## {el: points}, density, danger}; {} when qi is not loaded or the tile has no such part.
func part_qi(x: int, y: int, k: int) -> Dictionary:
	if not has_qi() or k < 0 or k > 2 or value("SHR%d" % (k + 1), x, y) == 0:
		return {}
	var shares := {}
	var variants := {}
	for e in QI_TAGS:
		var tag: String = QI_TAGS[e]
		if _layers.has("S%d%s" % [k + 1, tag]):
			shares[e] = value("S%d%s" % [k + 1, tag], x, y) / 100.0
		else:
			var v: float = value("V%d%s" % [k + 1, tag], x, y) / 100.0
			if v > 0.0:
				variants[e] = v
	return {"shares": shares, "variants": variants, "density": value("DEN%d" % (k + 1), x, y) / 1000.0,
		"danger": value("DAN%d" % (k + 1), x, y)}


## Formula C tile_values: the tile's qi over its land parts, weighted by share (lake and sea parts are left out; a
## tile with no land part reads its largest part). {} when qi is not loaded.
func tile_qi(x: int, y: int) -> Dictionary:
	if not has_qi():
		return {}
	var parts: Array = []
	for k in 3:
		var b: int = value("BIO%d" % (k + 1), x, y)
		var w: int = value("SHR%d" % (k + 1), x, y)
		if w > 0 and b != SEA_ID and b != LAKE_ID:
			parts.append([k, float(w)])
	if parts.is_empty():
		return part_qi(x, y, 0)
	var out := {"shares": {}, "variants": {}, "density": 0.0, "danger": 0.0}
	var tot: float = 0.0
	for pw in parts:
		var q: Dictionary = part_qi(x, y, pw[0])
		tot += pw[1]
		out.density += q.density * pw[1]
		out.danger += float(q.danger) * pw[1]
		for e in q.shares:
			out.shares[e] = float(out.shares.get(e, 0.0)) + q.shares[e] * pw[1]
		for e in q.variants:
			out.variants[e] = float(out.variants.get(e, 0.0)) + q.variants[e] * pw[1]
	out.density /= tot
	out.danger = int(floor(out.danger / tot + 0.5))
	for e in out.shares:
		out.shares[e] /= tot
	for e in out.variants:
		out.variants[e] /= tot
	return out


func _read(path: String) -> bool:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		errors.append("%s: cannot open (%s)" % [path, error_string(FileAccess.get_open_error())])
		return false
	var buf: PackedByteArray = f.get_buffer(f.get_length())
	f.close()
	if buf.size() < 14 or buf.slice(0, 8).get_string_from_ascii() != MAGIC:
		errors.append("%s: not a continent grid" % path)
		return false
	width = buf.decode_u16(8)
	height = buf.decode_u16(10)
	var n: int = buf.decode_u16(12)
	var at: int = 14
	for i in n:
		if at + 14 > buf.size():
			errors.append("%s: layer %d is cut short" % [path, i])
			return false
		var tag: String = buf.slice(at, at + 4).get_string_from_ascii()
		var nb: int = buf.decode_u8(at + 4)
		var signed: bool = buf.decode_u8(at + 5) == 1
		var raw_len: int = buf.decode_u32(at + 6)
		var comp_len: int = buf.decode_u32(at + 10)
		at += 14
		var data: PackedByteArray = buf.slice(at, at + comp_len).decompress(raw_len, FileAccess.COMPRESSION_DEFLATE)
		at += comp_len
		if data.size() != raw_len or raw_len != width * height * nb:
			errors.append("%s: layer %s has %d bytes, wanted %d" % [path, tag, data.size(), width * height * nb])
			continue
		_layers[tag] = {"bytes": nb, "signed": signed, "data": data}
	return true


## The continent's grid from its data ([ContinentData]), with the land-qi layers when the data names them.
static func from_continent(gd: GameData) -> ContinentGrid:
	var d: Dictionary = gd.file(ContinentData.DATA_FILE)
	var g := load_file(str(d.get("grid_file", "")), d.get("legend", {}))
	if g.errors.is_empty() and str(d.get("qi_file", "")) != "":
		g.load_qi(str(d.qi_file))
	return g


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
