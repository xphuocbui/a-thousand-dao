class_name Discovery
extends RefCounted

## Hidden places, clues, searching and tile secrets (design/gdd/travel-map.md rules 15-17 and 28-30, Formula F).
## The truth (which tile each hidden slot and tile secret rolled) lives in the world's ledger (WorldBuilder, World
## Generation Core Rule 10) and is never shown; the player learns it only through [MapKnowledge].
##
## - A rumour names the region a hidden place lies in (or, for a false one, a region where it does not), heard while
##   exploring a settlement (travel_rules.json search.rumour_chance).
## - Searching a season in a clue's region finds the place with Formula F's chance
##   P = 1 - exp(-q * (v_wild_eff / c_area) * (2r + 1) * p_detect / A), p_detect = DS / (DS + H); a false clue gives 0.
## - Arriving on (or passing over) a hidden place's or secret's tile is one roll of p_detect (x fly_detect_mult when
##   flying over); an exact map makes arrival a sure find.
## - A found blessed land's layer 3 becomes active for everyone there; a found secret is the finder's alone.
##
## Usage:
## [codeblock]
## var line: String = Discovery.rumour(gd, db, knowledge, rng, region_id, year)
## var res: Dictionary = Discovery.search(gd, db, knowledge, rng, player, ds, region_id, year, season)
## [/codeblock]

const RULES_FILE := "travel_rules"


static func _cfg(gd: GameData) -> Dictionary:
	return gd.file(RULES_FILE).get("search", {})


static func ledger(db: WorldDB) -> Dictionary:
	return db.get_record("world", "w_meta").get("ledger", {})


## The region (World DB id) a rolled slot lies in: its hidden place's region, or a tile secret's region.
static func _slot_region(db: WorldDB, slot: String, roll: Dictionary) -> String:
	if roll.has("place_id"):
		return str(db.get_record("places", str(roll.place_id)).get("region_id", ""))
	var cid: int = int(roll.get("region", 0))
	for r in db.all("regions"):
		if int(r.get("continent_id", -1)) == cid:
			return str(r.id)
	return ""


## Maybe hears a rumour in [param region_id] (rule 16): about an unfound hidden place, true with
## 1 - rumour_false_share, else false (naming this region for a place that lies elsewhere). Returns a line or "".
static func rumour(gd: GameData, db: WorldDB, k: MapKnowledge, rng: RandomNumberGenerator, region_id: String) -> String:
	var cfg: Dictionary = _cfg(gd)
	if rng.randf() >= float(cfg.get("rumour_chance", 0.25)):
		return ""
	var led: Dictionary = ledger(db)
	var here: Array = []
	var elsewhere: Array = []
	for slot in led:
		var roll: Dictionary = led[slot]
		if str(roll.get("family", "")) != "slot" or k.found.has(str(slot)):
			continue
		if k.clues.any(func(c): return str(c.slot) == str(slot) and str(c.region) == region_id):
			continue
		if _slot_region(db, str(slot), roll) == region_id:
			here.append(str(slot))
		else:
			elsewhere.append(str(slot))
	var false_one: bool = rng.randf() < float(cfg.get("rumour_false_share", 0.2))
	var pool: Array = elsewhere if (false_one or here.is_empty()) else here
	if pool.is_empty():
		return ""
	var slot: String = str(pool[rng.randi_range(0, pool.size() - 1)])
	var q_range: Array = cfg.get("rumour_quality", [0.5, 1.0])
	var clue := {"slot": slot, "kind": "rumour", "region": region_id, "quality": snappedf(rng.randf_range(float(q_range[0]), float(q_range[1])), 0.01),
		"false": not here.has(slot)}
	k.clues.append(clue)
	var kind: String = str(led[slot].get("kind", ""))
	var region_name: String = str(db.get_record("regions", region_id).get("name", ""))
	return "  A rumour: somewhere in %s lies %s. ('clues', then 'search' in that region)" % [region_name, _kind_words(kind)]


static func _kind_words(kind: String) -> String:
	match kind:
		"secret_realm":
			return "the gate of a secret realm"
		"ruin":
			return "the ruins of a vanished sect"
		"abode":
			return "a dead cultivator's cave abode"
		"blessed_small", "blessed_large":
			return "a blessed land"
	return "something hidden"


## Formula F's search chance for a season with [param clue], divine sense [param ds], speed factor [param f] and the
## region's wilderness tiles [param region_tiles] and mean tile cost [param c_area].
static func search_chance(gd: GameData, clue: Dictionary, ds: float, h: float, f: float, region_tiles: int, c_area: float) -> float:
	if bool(clue.get("false", false)):
		return 0.0
	var cfg: Dictionary = _cfg(gd)
	var r: int = MapKnowledge.sight_radius(gd, ds)
	var v: float = float(gd.file(RULES_FILE).speed.wilderness) * f
	var area: float
	match str(clue.kind):
		"jade_slip":
			area = float(cfg.get("jade_slip_area", 400))
		"map":
			return 1.0
		_:
			area = maxf(1.0, float(region_tiles) * float(cfg.get("rumour_area_share", 0.2)))
	var p: float = MapKnowledge.detect(ds, h)
	return 1.0 - exp(-float(clue.get("quality", 1.0)) * (v / maxf(c_area, 0.1)) * float(2 * r + 1) * p / area)


## A season of searching in [param region_id] with every clue held for it. Returns {lines, found: [slot]}.
static func search(gd: GameData, db: WorldDB, k: MapKnowledge, rng: RandomNumberGenerator, c: Character, ds: float, f: float,
		region_id: String, year: int, season: int) -> Dictionary:
	var led: Dictionary = ledger(db)
	var lines: Array = []
	var found: Array = []
	var clues: Array = k.clues.filter(func(x): return str(x.region) == region_id and not k.found.has(str(x.slot)))
	if clues.is_empty():
		return {"lines": ["You hold no clue for %s; you search the wilds and find nothing you were looking for." % db.get_record("regions", region_id).get("name", "")], "found": []}
	var region: Dictionary = db.get_record("regions", region_id)
	var tg := TravelGrid.of(gd)
	var stats: Dictionary = tg.region_stats(int(region.get("continent_id", 0)))
	for clue in clues:
		var roll: Dictionary = led.get(str(clue.slot), {})
		var place: Dictionary = db.get_record("places", str(roll.get("place_id", "")))
		var h: float = float(place.get("hidden_h", 1000.0))
		var p: float = search_chance(gd, clue, ds, h, f, int(stats.tiles), float(stats.mean_cost))
		if rng.randf() < p:
			lines.append_array(discover(gd, db, k, c, str(clue.slot), year, season, "search"))
			found.append(str(clue.slot))
		else:
			lines.append("  You search for %s in %s, without luck (%.0f%% a season)." % [_kind_words(str(roll.get("kind", ""))), region.get("name", ""), p * 100.0])
	return {"lines": lines, "found": found}


## Rolls p_detect for every hidden place and tile secret whose tile is on [param tiles] (rule 30; flying over a tile
## counts at fly_detect_mult). Returns the lines of what was found.
static func check_path(gd: GameData, db: WorldDB, k: MapKnowledge, rng: RandomNumberGenerator, c: Character, ds: float,
		tiles: Array, flying: bool, year: int, season: int) -> Array:
	var cfg: Dictionary = _cfg(gd)
	var on := {}
	for t in tiles:
		var v := Vector2i(t) if t is Vector2i else Vector2i(int(t[0]), int(t[1]))
		on[v] = true
	var lines: Array = []
	var led: Dictionary = ledger(db)
	for slot in led:
		if k.found.has(str(slot)):
			continue
		var roll: Dictionary = led[slot]
		var tile := Vector2i(int(roll.tile[0]), int(roll.tile[1]))
		if not on.has(tile):
			continue
		var sure: bool = k.clues.any(func(x): return str(x.slot) == str(slot) and str(x.kind) == "map" and not bool(x.get("false", false)))
		var h: float = float(db.get_record("places", str(roll.get("place_id", ""))).get("hidden_h", _secret_h(gd, roll)))
		var p: float = MapKnowledge.detect(ds, h) * (float(cfg.get("fly_detect_mult", 0.5)) if flying else 1.0)
		if sure or rng.randf() < p:
			lines.append_array(discover(gd, db, k, c, str(slot), year, season, "map" if sure else "passing"))
	return lines


static func _secret_h(gd: GameData, roll: Dictionary) -> float:
	var hs: Dictionary = _cfg(gd).get("secret_hidden", {})
	return float(hs.get(str(roll.get("kind", "")), 300.0))


## Records a find (rule 17, 30): the slot joins the finder's knowledge, a hidden place joins their map and the World
## Database's log, a found blessed land's layer 3 turns on for everyone there, and a secret pays what it holds.
static func discover(gd: GameData, db: WorldDB, k: MapKnowledge, c: Character, slot: String, year: int, season: int, how: String) -> Array:
	var roll: Dictionary = ledger(db).get(slot, {})
	k.found[slot] = {"year": year, "how": how}
	var lines: Array = []
	if roll.has("place_id"):
		var place: Dictionary = db.get_record("places", str(roll.place_id))
		k.places[str(place.id)] = true
		place["found_by"] = Array(place.get("found_by", [])) + [c.id]
		if str(place.get("kind", "")) == "blessed_land":
			for p in db.all("places"):
				for item in p.get("qi", {}).get("layer3", []):
					if str(item.get("slot", "")) == slot:
						item["active"] = true
		db.log_event(year, season, "discovery", "%s tìm thấy %s." % [c.name, place.name], [c.id], [str(place.id)], [], {"slot": slot, "how": how})
		lines.append("  !!! You find %s (%s). It is on your map now." % [place.name, _kind_words(str(roll.get("kind", "")))])
	else:
		db.log_event(year, season, "secret_found", "%s tìm thấy một bí mật nhỏ." % c.name, [c.id], [], [], {"slot": slot, "kind": str(roll.get("kind", "")), "tile": roll.get("tile", [])})
		lines.append("  !!! You find a %s here (tile %s). It is yours to know." % [str(roll.get("kind", "secret")), str(roll.get("tile", []))])
		var pay: Dictionary = _cfg(gd).get("secret_pay", {}).get(str(roll.get("kind", "")), {})
		if pay.has("linh_thach_frac"):
			var lt: int = int(round(float(gd.realm_budget(c.realm_index).get("linh_thach_max", 0)) * float(pay.linh_thach_frac)))
			c.linh_thach += lt
			lines.append("  The cache holds %d linh thạch." % lt)
	return lines
