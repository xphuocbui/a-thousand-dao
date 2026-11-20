class_name WorldBuilder
extends RefCounted

## Builds a new game's world on the authored continent with its authored history (design/gdd/world-generation.md,
## Core Rules 1-15; production/plans/continent-world.md). It replaces [WorldGenerator]'s random world and writes the
## same record shapes the game reads (places with links, density, danger, market, bounties, type, region_id,
## sect_id; sects with hq_place_id, members, leader_id; people as Character records; the event log).
##
## Inputs, all exported data (runtime never reads design/): world_continent.json ([ContinentData]: regions, places
## with their Formula C qi, routes, sects, origins), world_history.json (tools/design/world/export_world.py: sects'
## authored start, the cast, the chronicle and annals, legendary items, territory, hidden slots and tile secrets) and
## world_generation.json "continent" (how places map to types, sect capacity, where people live).
##
## The nine steps (Core Rule 1), each reading only what earlier steps wrote:
## 1. base: regions, places, routes as links (Travel & Map Formula D times, in seasons);
## 2. the 30 sects with their authored start, and the fallen sects as history;
## 3. the chronicle and the annals into the event log (canon Vietnamese text);
## 4. the fixed cast: the living as full people at their authored realm, sect, rank and home; the dead as records;
## 5. the seeded rolls: each hidden slot's and tile secret's tile (Formula C, keyed on the game seed and the slot id),
##    into the never-shown ledger [member ledger]; the famous sites become places, each hidden slot a hidden place at
##    its rolled tile, and blessed lands give their places layer 3 (qi.layer3);
## 6. the random cultivators: Formula A's headcount per realm less the living cast (Formula B), sect members up to
##    Sects F17's target with a join year (Formula D) and maybe a master, the rest settled or on chosen wild ground;
## 7. the unique named items (Item Database rule 20d), placed without invented history;
## 8. (Power Rankings start: GameSession, after the build, as before);
## 9. (the player: GameSession, by origin, from the approved home lists).
##
## Usage:
## [codeblock]
## var b := WorldBuilder.new(gd, tree)
## var db: WorldDB = b.generate(rng, "12345")
## if not b.errors.is_empty(): push_error("\n".join(b.errors))
## print(b.current_year, " ", db.count("people"))
## [/codeblock]

const HISTORY_FILE := "world_history"
const TRAVEL_FILE := "travel_rules"

## The year play starts (world_history.json start_year, Core Rule 11).
var current_year: int = 0
## The per-game rolls (Core Rule 10): slot id -> {kind, tile, candidate}; saved with the world, never shown.
var ledger: Dictionary = {}
## Problems found while building; empty on success (World Generation's Failed state names them).
var errors: PackedStringArray = []
## Continent place id -> World DB place id; sect key -> World DB sect id; cast key -> World DB person id.
var place_ids: Dictionary = {}
var sect_ids: Dictionary = {}
var person_ids: Dictionary = {}

var _gd: GameData
var _tree: DaoDoTree
var _db: WorldDB
var _builds: BuildGenerator
var _items: ItemFactory
var _cd: ContinentData
var _hist: Dictionary
var _cfg: Dictionary
var _seed: String = ""


func _init(gd: GameData, tree: DaoDoTree) -> void:
	_gd = gd
	_tree = tree


## Builds the whole world into a new WorldDB. [param rng] drives the random cultivators; [param game_seed] keys the
## hidden-spot rolls (Formula C), so they do not depend on the order of anything else.
func generate(rng: RandomNumberGenerator, game_seed: String = "") -> WorldDB:
	_seed = game_seed if game_seed != "" else str(rng.seed)
	_db = WorldDB.new()
	_builds = BuildGenerator.new(_gd, _tree, _db)
	_items = ItemFactory.new(_gd)
	_cd = ContinentData.from_game_data(_gd)
	_hist = _gd.file(HISTORY_FILE)
	_cfg = _gd.world_gen().get("continent", {})
	if not _cd.errors.is_empty():
		errors.append_array(_cd.errors)
	if _hist.is_empty():
		errors.append("world_history.json is not in the game data (run tools/design/world/export_world.py)")
	if not errors.is_empty():
		return _db
	current_year = int(_hist.start_year)
	_step_base()
	_step_sects()
	_step_history()
	_step_cast()
	_step_rolls()
	_step_sites()
	_step_resource_sites()
	_step_random_fill(rng)
	_step_named_items(rng)
	# Core Rules 10 and 13: the ledger of truth and the data versions are saved with the world, never shown
	_db.add("world", {"id": "w_meta", "builder": "continent", "data_version": str(_hist.get("data_version", "")),
		"map_version": str(_gd.file(ContinentData.DATA_FILE).get("map_version", "")), "seed": _seed, "ledger": ledger})
	return _db


## The database being built (valid after [method generate]).
func db() -> WorldDB:
	return _db


# --- 1. Base --------------------------------------------------------------------------------------------------------

func _step_base() -> void:
	var kinds: Dictionary = _cfg.kinds
	var travel: Dictionary = _gd.file(TRAVEL_FILE)
	var grid := ContinentGrid.load_file(str(_gd.file(ContinentData.DATA_FILE).get("grid_file", "")))
	for rid in _sorted_keys(_cd.regions):
		var r: Dictionary = _cd.regions[rid]
		var id: String = _db.add("regions", {"name": str(r.name), "name_han": str(r.get("name_han", "")),
			"gloss": str(r.get("gloss", "")), "places": [], "continent_id": int(rid), "holder": str(r.get("holder", "")),
			"centre_tile": r.get("centre_tile", [0, 0])})
		r["_db"] = id
	for pid in _sorted_keys(_cd.places):
		var p: Dictionary = _cd.places[pid]
		var k: Dictionary = kinds.get(str(p.kind), {"type": "son", "market": false, "bounties": false})
		var region: Dictionary = _cd.regions.get(int(p.region), {})
		var rec := {"name": str(p.name), "type": str(k.type), "kind": str(p.kind), "region_id": str(region.get("_db", "")),
			"density": float(p.get("density", 1.0)), "danger": int(p.get("danger", 1)), "market": bool(k.market),
			"bounties": bool(k.bounties), "links": [], "sect_id": "", "continent_id": int(pid), "tile": p.tile,
			"qi": Dictionary(p.get("qi", {})).duplicate(true), "holder": str(p.get("holder", "")), "territory": str(p.get("territory", "")),
			"name_han": str(p.get("name_han", "")), "gloss": str(p.get("gloss", ""))}
		for key in ["founded", "former", "lived", "former_name", "port", "river", "coast", "array"]:
			if p.has(key):
				rec[key] = p[key]
		_climate(rec, grid)
		var works_cfg: Dictionary = _gd.file(MapWorks.DATA_FILE)
		if not rec.qi.is_empty() and str(p.kind) in works_cfg.get("settled_kinds", []):
			# Formula M: settlements and seats start with layer-2 upkept works, kept up by their holders
			rec.qi["settled"] = true
			rec.qi["prebuilt"] = float(works_cfg.get("prebuilt_density", {}).get(str(p.kind), 0.0))
		var id: String = _db.add("places", rec)
		place_ids[int(pid)] = id
		if not region.is_empty():
			_db.get_record("regions", str(region._db)).places.append(id)
	for rt in _cd.routes:
		var a: String = place_ids.get(int(rt.a), "")
		var b: String = place_ids.get(int(rt.b), "")
		if a == "" or b == "":
			continue
		var t: float = snappedf(ContinentData.trip_seasons(rt, travel), 0.001)
		_link(a, b, t, rt)
		_link(b, a, t, rt)


## One link per pair of places: where a road and a sea lane join the same two, the quicker one (Formula D).
func _link(a: String, b: String, t: float, rt: Dictionary) -> void:
	var links: Array = _db.get_record("places", a).links
	for l in links:
		if str(l.to) == b:
			if t < float(l.seasons):
				l.seasons = t
				l.kind = str(rt.kind)
				l.km = float(rt.km)
			return
	links.append({"to": b, "seasons": t, "kind": str(rt.kind), "km": float(rt.km)})


# --- 2. Sects -------------------------------------------------------------------------------------------------------

func _step_sects() -> void:
	var align_names := {}
	for a in _gd.world_gen().sects.alignments:
		align_names[str(a.id)] = str(a.name)
	for s in _hist.sects:
		var seat: String = place_ids.get(int(s.seat), "")
		var hq: Dictionary = _db.get_record("places", seat)
		var rec := {"name": str(s.name), "key": str(s.key), "kind": str(s.kind), "name_han": str(s.get("name_han", "")),
			"gloss": str(s.get("gloss", "")), "alignment": str(s.alignment), "alignment_name": str(align_names.get(str(s.alignment), "")),
			"specialty": str(s.specialty), "hq_place_id": seat, "region_id": str(hq.get("region_id", "")), "leader_id": "",
			"members": [], "status": "active", "founded_year": int(s.founded), "levels": s.levels, "treasury": int(s.treasury),
			"leans": s.get("leans", []), "tier": int(s.get("tier", 0)), "loyalty": s.get("loyalty", null)}
		var id: String = _db.add("sects", rec)
		sect_ids[str(s.key)] = id
		if not hq.is_empty():
			hq["sect_id"] = id
	for s in _hist.sects:
		var rec: Dictionary = _db.get_record("sects", sect_ids[str(s.key)])
		rec["lord_id"] = sect_ids.get(str(s.get("lord", "")), "")
		var regions: Array = []
		for rid in s.get("regions", []):
			var r: Dictionary = _cd.regions.get(int(rid), {})
			if not r.is_empty():
				regions.append(str(r._db))
		rec["regions"] = regions
	for f in _hist.fallen_sects:
		var ruin: String = place_ids.get(int(f.ruin), "") if f.get("ruin") != null else ""
		sect_ids[str(f.key)] = _db.add("sects", {"name": str(f.name), "key": str(f.key), "name_han": str(f.get("name_han", "")),
			"gloss": str(f.get("gloss", "")), "status": "fallen", "founded_year": int(f.founded), "fell_year": int(f.fell),
			"cause": str(f.get("cause", "")), "hq_place_id": ruin, "region_id": "", "leader_id": "", "members": [],
			"alignment": "", "alignment_name": "", "specialty": "", "ruin_slot": str(f.get("ruin_slot", ""))})
	for p in _db.all("places"):
		for key in ["holder", "territory"]:
			p[key] = sect_ids.get(str(p.get(key, "")), "")
	for r in _db.all("regions"):
		r["holder"] = sect_ids.get(str(r.get("holder", "")), "")


# --- 3. The chronicle and the annals ---------------------------------------------------------------------------------

func _step_history() -> void:
	for p in _hist.people:
		# ids for every authored person first, so events can name them; step 4 fills the records
		person_ids[str(p.key)] = _db.add("people", {"name": str(p.name), "alive": false, "pending": true})
	for e in _hist.events:
		var people: Array = []
		for k in e.get("people", []):
			if person_ids.has(str(k)):
				people.append(person_ids[str(k)])
		for k in e.get("sects", []):
			if sect_ids.has(str(k)):
				people.append(sect_ids[str(k)])
		var places: Array = []
		if e.has("place"):
			places.append(place_ids.get(int(e.place), ""))
		var data := {"id": str(e.id), "tier": str(e.tier), "authored": true, "text_en": str(e.get("text_en", ""))}
		for key in ["region", "slot", "item", "war", "famous", "feature", "tile", "secret", "writ", "judgement", "note"]:
			if e.has(key):
				data[key] = e[key]
		if e.has("region"):
			var r: Dictionary = _cd.regions.get(int(e.region), {})
			data["region_id"] = str(r.get("_db", ""))
		_db.log_event(int(e.year), 0, str(e.kind), str(e.text_vi), people, places.filter(func(x): return x != ""), [], data)


# --- 4. The fixed cast ------------------------------------------------------------------------------------------------

func _step_cast() -> void:
	var ranks: Dictionary = _cfg.authored_rank
	for p in _hist.people:
		var pid: String = person_ids[str(p.key)]
		var sect: String = sect_ids.get(str(p.get("sect", "")), "")
		if not bool(p.alive):
			var c := Character.new()
			c.name = str(p.name)
			c.alive = false
			c.gender = "female" if str(p.sex) == "F" else "male"
			c.realm_index = _realm_index(str(p.get("peak_realm", "luyen_khi")))
			c.death_cause = str(p.get("cause", ""))
			c.sect_id = sect
			c.sect_rank = str(ranks.get(str(p.get("rank", "")), ""))
			c.age = float(int(p.get("died", 0)) - int(p.born))
			var rec: Dictionary = c.to_dict()
			rec["id"] = pid
			rec["death_year"] = int(p.get("died", 0))
			rec["born_year"] = int(p.born)
			rec["created_by"] = "history"
			rec["cast_key"] = str(p.key)
			rec["role"] = str(p.get("role", ""))
			for key in ["abode_slot", "served_under"]:
				if p.has(key):
					rec[key] = str(p[key])
			_db.put("people", rec)
			continue
		var home: String = place_ids.get(int(p.home), "") if p.get("home") != null else ""
		var realm: int = _realm_index(str(p.realm))
		var opts := {"realm_index": realm, "sect_id": sect, "sect_rank": str(ranks.get(str(p.get("rank", "")), "")),
			"location_id": home, "name": str(p.name), "gender": "female" if str(p.sex) == "F" else "male",
			"age": float(current_year - int(p.born)), "created_by": "cast", "id": pid}
		var sect_rec: Dictionary = _db.get_record("sects", sect) if sect != "" else {}
		if not sect_rec.is_empty():
			opts["archetype"] = str(sect_rec.specialty)
		# Core Rule 6: builds are hand-authored (user decision 2026-11-20; design/world/cast_builds.json); a person whose
		# build is not written yet is filled from a stream keyed on the person alone, the same in every game.
		var authored: Dictionary = _hist.get("cast_builds", {}).get(str(p.key), {})
		if not authored.is_empty():
			CastBuilds.make(_gd, _tree, _db, _items, _builds, p, authored, pid, sect, str(opts.sect_rank), home, current_year)
		else:
			var crng := RandomNumberGenerator.new()
			crng.seed = RngUtils.stable_hash("cast:" + str(p.key))
			_builds.create_person(crng, opts)
		var rec: Dictionary = _db.get_record("people", pid)
		rec["cast_key"] = str(p.key)
		rec["born_year"] = int(p.born)
		rec["role"] = str(p.get("role", ""))
		rec["npc_traits"] = p.get("traits", {})
		rec["build_source"] = "authored" if not authored.is_empty() else "stand-in"
		rec.erase("pending")
		if not sect_rec.is_empty():
			sect_rec.members.append(pid)
			if str(p.get("rank", "")) == "tong_chu":
				sect_rec.leader_id = pid
	for p in _hist.people:
		var rec: Dictionary = _db.get_record("people", person_ids[str(p.key)])
		if p.has("master"):
			rec["master_id"] = person_ids.get(str(p.master), "")
	for s in _db.find("sects", func(x): return x.status == "active" and str(x.leader_id) == ""):
		errors.append("sect %s has no living leader" % s.name)


# --- 5. Seeded rolls --------------------------------------------------------------------------------------------------

## Formula C: the candidate index for [param slot_id] of [param kind] (slot, tile_secret or reserve) among [param n].
func slot_pick(kind: String, slot_id: String, n: int) -> int:
	return RngUtils.stable_hash("%s:%s:%s" % [_seed, kind, slot_id]) % maxi(n, 1)


func _step_rolls() -> void:
	for s in _hist.hidden_slots:
		var i: int = slot_pick("slot", str(s.slot), s.candidates.size())
		ledger[str(s.slot)] = {"family": "slot", "kind": str(s.kind), "tile": s.candidates[i], "candidate": i,
			"origin": str(s.get("origin", ""))}
	for s in _hist.tile_secrets:
		var i: int = slot_pick("tile_secret", str(s.slot), s.candidates.size())
		ledger[str(s.slot)] = {"family": "tile_secret", "kind": str(s.kind), "tile": s.candidates[i], "candidate": i,
			"region": int(s.region)}


## The tile's climate on a place record (Formula G reads it): annual mean temperature (C) and rainfall (mm).
static func _climate(rec: Dictionary, grid: ContinentGrid) -> void:
	if grid == null or not grid.errors.is_empty() or not rec.has("tile"):
		return
	rec["temp_c"] = snappedf(grid.temperature_c(int(rec.tile[0]), int(rec.tile[1])), 0.1)
	rec["rain_mm"] = grid.rainfall_mm(int(rec.tile[0]), int(rec.tile[1]))


## The history's sites (Travel & Map rules 15 and 28): the famous ones are places from the start; each hidden slot
## becomes a place at its rolled tile, hidden (seen by no one) until found. Every place on a blessed land's tiles gets
## its layer 3 (Formula B) in qi.layer3, active for a famous land and for a hidden one once it is found.
func _step_sites() -> void:
	var kinds: Dictionary = _cfg.kinds
	var lands: Array = []
	var grid := ContinentGrid.load_file(str(_gd.file(ContinentData.DATA_FILE).get("grid_file", "")))
	for f in _hist.get("famous_sites", []):
		var k: Dictionary = kinds.get(str(f.kind), {"type": "son"})
		var tile: Array = f.tile
		var region_cid: int = int(f.region) if int(f.region) > 0 else grid.region(int(tile[0]), int(tile[1]))
		var rec := {"name": str(f.name), "type": str(k.type), "kind": str(f.kind), "region_id": _region_db(region_cid),
			"density": float(f.get("density", 1.0)), "danger": int(f.get("danger", 1)), "market": false, "bounties": false,
			"links": [], "sect_id": "", "tile": tile, "qi": f.get("qi", {}).duplicate(true), "famous": true,
			"holder": sect_ids.get(str(f.get("holder", "")), ""), "name_han": str(f.get("name_han", "")),
			"gloss": str(f.get("gloss", ""))}
		if f.has("cycle"):
			rec["cycle"] = f.cycle
		_climate(rec, grid)
		var id: String = _db.add("places", rec)
		_add_to_region(id, rec.region_id)
		if str(f.kind) == "blessed_land":
			var tiles: Array = f.get("tile_list", [tile])
			lands.append({"name": str(f.name), "tiles": tiles, "dD": float(f.get("dD3", 0.0)), "element": str(f.get("element", "")),
				"push": float(f.get("push", 0)), "slot": "", "active": true})
	for s in _hist.hidden_slots:
		var roll: Dictionary = ledger[str(s.slot)]
		var i: int = int(roll.candidate)
		var cq: Dictionary = s.candidate_qi[i] if i < s.candidate_qi.size() else {}
		var kind: String = "blessed_land" if str(s.kind).begins_with("blessed") else str(s.kind)
		var k: Dictionary = kinds.get(kind, {"type": "son"})
		var region: String = _region_db(int(s.regions[i]) if i < s.regions.size() else 0)
		var rec := {"name": _hidden_name(s, kind, region), "type": str(k.type), "kind": kind, "region_id": region,
			"density": float(cq.get("density", 1.0)), "danger": int(cq.get("danger", 1)), "market": false, "bounties": false,
			"links": [], "sect_id": "", "tile": s.candidates[i], "qi": cq.get("qi", {}).duplicate(true), "hidden": true,
			"slot": str(s.slot), "hidden_h": float(s.get("hidden_h", 1000)), "origin_event": str(s.get("origin", "")),
			"owner_key": str(s.get("owner", ""))}
		_climate(rec, grid)
		var id: String = _db.add("places", rec)
		_add_to_region(id, region)
		roll["place_id"] = id
		if kind == "blessed_land":
			var tiles: Array = s.tile_lists[i] if s.has("tile_lists") else [s.candidates[i]]
			lands.append({"name": rec.name, "tiles": tiles, "dD": float(s.get("dD3", 0.0)), "element": str(s.get("element", "")),
				"push": float(s.get("push", 0)), "slot": str(s.slot), "active": false})
	var names: Dictionary = _cfg.get("element_names", {})
	var by_tile := {}
	for p in _db.all("places"):
		if p.has("tile"):
			var key := Vector2i(int(p.tile[0]), int(p.tile[1]))
			if not by_tile.has(key):
				by_tile[key] = []
			by_tile[key].append(p)
	for land in lands:
		var push := {}
		var el: String = str(names.get(str(land.element), ""))
		if el != "":
			push[el] = float(land.push)
		for t in land.tiles:
			for p in by_tile.get(Vector2i(int(t[0]), int(t[1])), []):
				if not p.qi.has("layer3"):
					p.qi["layer3"] = []
				p.qi.layer3.append({"name": land.name, "dD": land.dD, "push": push, "slot": land.slot, "active": land.active})


## Travel & Map rules 19-20: every place of a site kind becomes a resource site; its start reserve is rolled from the
## hand-set sizes by Formula C (kind "reserve", keyed on the place's continent id), so it differs by game.
func _step_resource_sites() -> void:
	var kinds: Array = _gd.file(MapProduction.DATA_FILE).get("site_kinds", [])
	var n: int = Array(_gd.file(MapProduction.DATA_FILE).get("reserve_start_choices", [1.0])).size()
	for p in _db.all("places"):
		if str(p.get("kind", "")) in kinds and not bool(p.get("hidden", false)):
			var pick: int = slot_pick("reserve", str(p.get("continent_id", p.id)), n)
			p["site"] = MapProduction.init_site(_gd, p, pick)
			ledger["reserve:%s" % str(p.get("continent_id", p.id))] = {"family": "reserve", "candidate": pick, "place_id": str(p.id)}


func _hidden_name(s: Dictionary, kind: String, region: String) -> String:
	var rname: String = str(_db.get_record("regions", region).get("name", ""))
	var owner: String = str(s.get("owner", ""))
	if owner != "":
		var person: String = person_ids.get(owner, "")
		if person != "":
			return "Động phủ của %s" % _db.get_record("people", person).name
		for f in _hist.fallen_sects:
			if str(f.key) == owner:
				return "Di chỉ %s" % f.name
	match kind:
		"secret_realm":
			return "Bí cảnh ở %s" % rname
		"blessed_land":
			return "Phúc địa ở %s" % rname
		"ruin":
			return "Di tích ở %s" % rname
	return "Động phủ ở %s" % rname


func _region_db(continent_region: int) -> String:
	return str(_cd.regions.get(continent_region, {}).get("_db", ""))


func _add_to_region(place_id: String, region_id: String) -> void:
	var r: Dictionary = _db.get_record("regions", region_id)
	if not r.is_empty():
		r.places.append(place_id)


# --- 6. The random cultivators ---------------------------------------------------------------------------------------

## Formula A: the realm headcount targets for a world of [param n] (largest remainder, ties to the lower realm).
static func realm_targets(n: int, weights: Array) -> Array:
	var total: float = 0.0
	for w in weights:
		total += float(w)
	var raw: Array = []
	var t: Array = []
	for w in weights:
		raw.append(float(n) * float(w) / total)
		t.append(int(floor(raw[-1])))
	var left: int = n
	for x in t:
		left -= int(x)
	var order: Array = range(weights.size())
	order.sort_custom(func(a, b): return (raw[a] - t[a]) > (raw[b] - t[b]) or ((raw[a] - t[a]) == (raw[b] - t[b]) and a < b))
	for k in left:
		t[order[k]] += 1
	return t


func _step_random_fill(rng: RandomNumberGenerator) -> void:
	var pc: Dictionary = _gd.world_gen().people
	var n: int = maxi(int(pc.world_cultivators), int(pc.world_cultivators_min))
	var weights: Array = _gd.world_gen().realm_distribution.map(func(x): return float(x.weight))
	var targets: Array = realm_targets(n, weights)
	var living: Array = _db.find("people", func(p): return p.alive and not p.get("is_beast", false))
	var fill: Array = []
	for r in targets.size():
		var k: int = living.filter(func(p): return int(p.realm_index) == r).size()
		for i in maxi(int(targets[r]) - k, 0):
			fill.append(r)
	fill = RngUtils.shuffled(rng, fill)
	# sect places: up to F17's target, by Sects F2's capacity
	var cap: Dictionary = _cfg.sect_capacity
	var seats: Array = []
	for s in _db.find("sects", func(x): return x.status == "active"):
		var base: float = float(cap.cap_base.great if str(s.kind) == "great" else cap.cap_base.minor)
		var capacity: int = int(floor(base * (1.0 + float(cap.i) * float(s.levels.institutions))))
		var want: int = int(floor(float(cap.fill) * float(capacity))) - s.members.size()
		s["capacity"] = capacity
		for i in maxi(want, 0):
			seats.append(s.id)
	seats = RngUtils.shuffled(rng, seats)
	var settled: Array = _db.find("places", func(p): return str(p.kind) in _cfg.settled_kinds)
	var settle_w: Array = settled.map(func(p): return float(_cfg.settle_weight.get(str(p.kind), 1)))
	var realm_by_rank: Array = _cfg.rank_by_realm
	# Formulas M: npc_settled_share counts everyone in settlements and sect grounds, members at their seats
	# included, so the loose cultivators settle at the share that brings the whole world to it
	var members: int = mini(seats.size(), fill.size()) + living.filter(func(p): return str(p.get("sect_id", "")) != "").size()
	var loose: int = maxi(1, fill.size() + living.size() - members)
	var loose_settle: float = clampf((float(_cfg.npc_settled_share) * float(fill.size() + living.size()) - float(members)) / float(loose), 0.0, 1.0)
	var idx_by_realm := {}
	for r in fill:
		var k: int = int(idx_by_realm.get(r, 0))
		idx_by_realm[r] = k + 1
		var opts := {"realm_index": r, "created_by": "worldgen"}
		var sect: Dictionary = {}
		if not seats.is_empty():
			sect = _db.get_record("sects", str(seats.pop_back()))
			opts["sect_id"] = str(sect.id)
			opts["sect_rank"] = str(realm_by_rank[clampi(r, 0, realm_by_rank.size() - 1)])
			opts["location_id"] = str(sect.hq_place_id)
			if rng.randf() < float(_gd.world_gen().sects.member_archetype_share):
				opts["archetype"] = str(sect.specialty)
		elif rng.randf() < loose_settle:
			opts["location_id"] = str(_weighted(rng, settled, settle_w).id)
		else:
			opts["archetype"] = "tan_tu" if rng.randf() < float(pc.loose_tan_tu_share) else ""
		var pid: String = _builds.create_person(rng, opts)
		var rec: Dictionary = _db.get_record("people", pid)
		rec["born_year"] = current_year - int(floor(float(rec.age)))
		if not sect.is_empty():
			sect.members.append(pid)
			_join(rec, sect, r, k)
		elif str(rec.location_id) == "":
			rec["location_id"] = _wild_home(rec, rng)


## Formula D: the join year of a random member, and maybe a master who was in the sect then, of a higher realm.
func _join(rec: Dictionary, sect: Dictionary, realm: int, k: int) -> void:
	var lo: int = maxi(current_year - int(floor(float(rec.age))) + 16, int(sect.founded_year))
	lo = mini(lo, current_year)
	rec["joined_year"] = lo + RngUtils.stable_hash("%s:join:%d:%d" % [_seed, realm, k]) % (current_year - lo + 1)
	var roll: float = float(RngUtils.stable_hash("%s:master:%s" % [_seed, rec.id]) % 10000) / 10000.0
	if roll >= float(_cfg.master_share):
		return
	var masters: Array = []
	for mid in sect.members:
		var m: Dictionary = _db.get_record("people", str(mid))
		if m.is_empty() or str(m.id) == str(rec.id) or int(m.realm_index) <= realm:
			continue
		if int(m.get("joined_year", m.get("born_year", 0))) <= int(rec.joined_year):
			masters.append(m)
	if not masters.is_empty():
		var pick: Dictionary = masters[RngUtils.stable_hash("%s:master_pick:%s" % [_seed, rec.id]) % masters.size()]
		rec["master_id"] = str(pick.id)


## Formulas M: a loose cultivator outside the settlements picks among the best wild places of a region (by density x
## land match for their root), the band narrowing with realm.
func _wild_home(rec: Dictionary, rng: RandomNumberGenerator) -> String:
	var wild: Array = _db.find("places", func(p): return str(p.kind) in _cfg.wild_kinds and not bool(p.get("hidden", false)))
	if wild.is_empty():
		return str(RngUtils.pick(rng, _db.all("places")).id)
	var region: String = str(RngUtils.pick(rng, wild).region_id)
	var here: Array = wild.filter(func(p): return str(p.region_id) == region)
	var c := Character.from_dict(rec)
	here.sort_custom(func(a, b): return float(a.density) * LandQi.land_match(c, _gd, a.qi).total > float(b.density) * LandQi.land_match(c, _gd, b.qi).total)
	var tops: Array = _cfg.npc_wild_pick_top
	var share: float = float(tops[clampi(int(rec.realm_index), 0, tops.size() - 1)])
	var n: int = maxi(1, int(ceil(share * float(here.size()))))
	return str(here[rng.randi_range(0, n - 1)].id)


# --- 7. Unique named items -------------------------------------------------------------------------------------------

## Item Database rule 20d: every unique named template exists once, held by a living NPC whose realm fits it (equipped
## where a slot is free) or Lost at a wild place. The legendary items of the history are lore only until their Effects
## exist (legendary_items_proposal.json), so none is placed. No history is invented for a placement.
func _step_named_items(rng: RandomNumberGenerator) -> void:
	var cfg: Dictionary = _gd.artifacts_file().named
	var held_chance: float = float(_gd.world_gen().history.legend_held_chance)
	var candidates: Array = _db.find("people", func(p): return p.alive and not p.get("is_beast", false) and int(p.realm_index) >= int(cfg.holder_realm_min))
	var wild: Array = _db.find("places", func(p): return str(p.kind) in _cfg.wild_kinds or str(p.kind) == "ruin")
	for t in _gd.named_items():
		if not _items.is_unique(str(t.id)):
			continue
		var holder: Dictionary = {}
		if not candidates.is_empty() and rng.randf() < held_chance:
			holder = RngUtils.pick(rng, candidates)
			candidates.erase(holder)
		var tier: int = int(holder.realm_index) if not holder.is_empty() else rng.randi_range(int(cfg.holder_realm_min), _gd.realms().size() - 1)
		var art: Dictionary = _items.named_artifact(str(t.id), tier, _db, current_year)
		if art.is_empty():
			continue
		var aid: String = _db.add("items", art)
		if not holder.is_empty():
			art["owner_id"] = holder.id
			_equip_held(holder, aid)
		else:
			art["owner_id"] = str(RngUtils.pick(rng, wild).id)
			art["lost"] = true


func _equip_held(holder: Dictionary, item_id: String) -> void:
	var c := Character.from_dict(holder)
	var slot: String = EquipSlots.slot_for(c, _gd, _db, StatSheet.build(c, _gd, _db, _tree), _db.get_record("items", item_id))
	if slot != "":
		holder["equipped"] = Array(holder.get("equipped", [])) + [item_id]
		var slots: Dictionary = holder.get("equip_slots", {})
		slots[item_id] = slot
		holder["equip_slots"] = slots
	_builds.refresh_power(str(holder.id))


# --- helpers ----------------------------------------------------------------------------------------------------------

func _realm_index(id: String) -> int:
	var i: int = _gd.realm_index(id)
	return maxi(i, 0)


static func _sorted_keys(d: Dictionary) -> Array:
	var k: Array = d.keys()
	k.sort()
	return k


static func _weighted(rng: RandomNumberGenerator, items: Array, weights: Array) -> Dictionary:
	var total: float = 0.0
	for w in weights:
		total += float(w)
	var x: float = rng.randf() * total
	for i in items.size():
		x -= float(weights[i])
		if x <= 0.0:
			return items[i]
	return items[-1]
