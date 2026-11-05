class_name WorldGenerator
extends RefCounted
## Generates a fresh world for each life: regions, places with linh khí density and
## travel links, sects with ranked members, loose cultivators, legendary artifacts and
## a few centuries of backfilled history (legends) consistent with the present state.
## Everything is written to the WorldDB the LLM later reads from.
## Design: game-concept.md § Core Mechanics 6 (world generation with history),
## Unique Hook (Dwarf Fortress adventure-mode layer). Data: world_generation.json, world_names.json.
##
## Usage:
## [codeblock]
## var gen := WorldGenerator.new(gd, tree)
## var db: WorldDB = gen.generate(rng)
## print(db.count("people"), " people, ", db.count("events"), " legends")
## print(gen.current_year)
## [/codeblock]

## Calendar year at the end of history (the year play starts).
var current_year: int = 0

var _gd: GameData
var _tree: MeridianTree
var _db: WorldDB
var _builds: BuildGenerator
var _items: ItemFactory
var _used_names: Dictionary = {}


func _init(gd: GameData, tree: MeridianTree) -> void:
	_gd = gd
	_tree = tree


## Generates a complete world into a new WorldDB.
func generate(rng: RandomNumberGenerator) -> WorldDB:
	_db = WorldDB.new()
	_builds = BuildGenerator.new(_gd, _tree, _db)
	_items = ItemFactory.new(_gd)
	var wg: Dictionary = _gd.world_gen()
	current_year = int(wg.history.years)
	_make_geography(rng)
	_make_sects(rng)
	_make_loose_cultivators(rng)
	_simulate_history(rng)
	return _db


## The database being generated (valid after [method generate]).
func db() -> WorldDB:
	return _db


# --- Geography ------------------------------------------------------------------

func _make_geography(rng: RandomNumberGenerator) -> void:
	var wg: Dictionary = _gd.world_gen()
	var names: Dictionary = _gd.names()
	var region_count: int = rng.randi_range(int(wg.regions.min), int(wg.regions.max))
	var region_names: Array = RngUtils.shuffled(rng, names.regions).slice(0, region_count)
	var region_places: Array = []
	for rname in region_names:
		var rid: String = _db.add("regions", {"name": rname, "places": []})
		var count: int = rng.randi_range(int(wg.places_per_region.min), int(wg.places_per_region.max))
		var ids: Array = []
		# Every region gets one market town so trade is always reachable.
		for i in count:
			var ptype: Dictionary = _gd.place_type("thanh") if i == 0 else RngUtils.weighted_pick(rng, wg.place_types)
			var pid: String = _db.add("places", {
				"name": "%s %s" % [_unique_word(rng, names.place_words), ptype.suffix],
				"type": ptype.id, "region_id": rid,
				"density": snappedf(RngUtils.range_f(rng, ptype.density), 0.01),
				"danger": int(ptype.danger), "market": bool(ptype.market), "bounties": bool(ptype.bounties),
				"links": [], "sect_id": "",
			})
			ids.append(pid)
		_db.get_record("regions", rid)["places"] = ids
		# Chain + a few extra links inside the region.
		var same: int = int(wg.travel.same_region_seasons)
		for i in ids.size() - 1:
			_link_places(ids[i], ids[i + 1], same)
		for k in int(wg.travel.extra_links_per_region):
			var a: String = RngUtils.pick(rng, ids)
			var b: String = RngUtils.pick(rng, ids)
			if a != b:
				_link_places(a, b, same)
		region_places.append(ids)
	# Ring of cross-region roads between market towns.
	var cross: int = int(wg.travel.cross_region_seasons)
	for i in region_places.size():
		var j: int = (i + 1) % region_places.size()
		if i != j:
			_link_places(region_places[i][0], region_places[j][0], cross)


func _link_places(a: String, b: String, seasons: int) -> void:
	var pa: Dictionary = _db.get_record("places", a)
	var pb: Dictionary = _db.get_record("places", b)
	for l in pa.links:
		if l.to == b:
			return
	pa.links.append({"to": b, "seasons": seasons})
	pb.links.append({"to": a, "seasons": seasons})


# --- Sects ------------------------------------------------------------------------

func _make_sects(rng: RandomNumberGenerator) -> void:
	var wg: Dictionary = _gd.world_gen()
	var names: Dictionary = _gd.names()
	var cfg: Dictionary = wg.sects
	var count: int = rng.randi_range(int(cfg.min), int(cfg.max))
	var fallen: int = int(wg.history.get("fallen_sects", 0))
	var candidates: Array = _db.find("places", func(p): return p.type in ["son", "coc", "ho", "dao"])
	if candidates.is_empty():
		candidates = _db.all("places")
	candidates = RngUtils.shuffled(rng, candidates)
	var leader_realm: int = _gd.realm_index(str(wg.npc_builds.leader_realm_min))
	var elder_realm: int = _gd.realm_index(str(wg.npc_builds.elder_realm_min))
	for i in count + fallen:
		var hq: Dictionary = candidates[i % candidates.size()]
		var align: Dictionary = RngUtils.weighted_pick(rng, cfg.alignments)
		var arch: Dictionary = RngUtils.weighted_pick(rng, wg.archetypes)
		var is_fallen: bool = i >= count
		var sid: String = _db.add("sects", {
			"name": "%s %s" % [_unique_word(rng, names.sect_first), RngUtils.pick(rng, names.sect_suffix)],
			"alignment": align.id, "alignment_name": align.name, "specialty": arch.id,
			"hq_place_id": hq.id, "region_id": hq.region_id, "leader_id": "", "members": [],
			"status": "fallen" if is_fallen else "active", "founded_year": rng.randi_range(0, current_year / 3),
		})
		if is_fallen:
			continue
		if hq.sect_id == "":
			hq["sect_id"] = sid
		var sect: Dictionary = _db.get_record("sects", sid)
		var leader: String = _builds.create_person(rng, {
			"realm_index": rng.randi_range(leader_realm, mini(leader_realm + 1, _gd.realms().size() - 1)),
			"archetype": arch.id, "sect_id": sid, "sect_rank": "tong_chu", "location_id": hq.id,
		})
		sect.leader_id = leader
		sect.members.append(leader)
		var n: int = rng.randi_range(int(cfg.members_min), int(cfg.members_max))
		for k in n:
			var rank: String = "truong_lao" if k < 2 else ("noi_mon" if k < n / 2 else "ngoai_mon")
			var realm: int
			match rank:
				"truong_lao":
					realm = rng.randi_range(elder_realm, leader_realm)
				"noi_mon":
					realm = rng.randi_range(0, elder_realm)
				_:
					realm = 0
			var a: String = arch.id if rng.randf() < float(cfg.member_archetype_share) else ""
			var pid: String = _builds.create_person(rng, {"realm_index": realm, "archetype": a, "sect_id": sid, "sect_rank": rank, "location_id": hq.id})
			sect.members.append(pid)


func _make_loose_cultivators(rng: RandomNumberGenerator) -> void:
	var places: Array = _db.all("places")
	var pcfg: Dictionary = _gd.world_gen().people
	# Towns and cities always have a few residents to meet and talk to.
	for place in places.filter(func(p): return p.type in ["thanh", "tran", "phuong_thi"]):
		for k in rng.randi_range(int(pcfg.townsfolk_per_town.min), int(pcfg.townsfolk_per_town.max)):
			_builds.create_person(rng, {"realm_index": rng.randi_range(0, int(pcfg.townsfolk_realm_max)), "location_id": place.id})
	var made: int = _db.find("people", func(p): return p.alive and not p.get("is_beast", false)).size()
	for i in maxi(maxi(int(pcfg.world_cultivators), int(pcfg.world_cultivators_min)) - made, 0):
		var place: Dictionary = RngUtils.pick(rng, places)
		_builds.create_person(rng, {"archetype": "tan_tu" if rng.randf() < float(_gd.world_gen().people.loose_tan_tu_share) else "", "location_id": place.id})


# --- History ------------------------------------------------------------------------

func _simulate_history(rng: RandomNumberGenerator) -> void:
	var h: Dictionary = _gd.world_gen().history
	# Founding events.
	for sect in _db.all("sects"):
		var founder_name: String = _builds.person_name(rng, "male")
		var founder: String = _db.add("people", _dead_person(founder_name, rng.randi_range(int(h.founder_realm_range[0]), int(h.founder_realm_range[1])), "Khai tông tổ sư", int(sect.founded_year) + 200, sect.id))
		_log(int(sect.founded_year), "sect_founded", {"a": founder, "s1": sect.id, "place": sect.hq_place_id})
	# Legendary artifacts held by the strong, or lost somewhere.
	var strong: Array = _db.find("people", func(p): return p.alive and int(p.realm_index) >= 2)
	for i in int(h.legendary_artifacts):
		var holder: Dictionary = RngUtils.pick(rng, strong) if not strong.is_empty() else {}
		var tier: int = int(holder.get("realm_index", 2))
		var art: Dictionary = _items.artifact(rng, tier, rng.randi_range(3, 4))
		art["legendary"] = true
		art["owner_id"] = ""
		var aid: String = _db.add("items", art)
		var year: int = rng.randi_range(current_year / 3, current_year - 1)
		if not holder.is_empty() and rng.randf() < float(h.legend_held_chance):
			_db.give_item(aid, holder.id)
			_log(year, "treasure_found", {"a": holder.id, "item": aid, "place": holder.location_id})
		else:
			var place: Dictionary = RngUtils.pick(rng, _db.all("places"))
			art["owner_id"] = place.id
			art["lost"] = true
			var former: String = _db.add("people", _dead_person(_builds.person_name(rng, "male"), tier, "Mất tích", year, ""))
			_log(year, "treasure_lost", {"a": former, "item": aid, "place": place.id})
	# Fallen sects die in a war.
	for sect in _db.find("sects", func(s): return s.status == "fallen"):
		var winners: Array = _db.find("sects", func(s): return s.status == "active")
		if winners.is_empty():
			continue
		var w: Dictionary = RngUtils.pick(rng, winners)
		_log(rng.randi_range(int(sect.founded_year) + 10, current_year - 20), "sect_war_fall", {"s1": w.id, "s2": sect.id, "place": sect.hq_place_id})
	# Yearly events.
	var weights: Array = h.event_weights
	for year in current_year:
		var n: int = int(floor(float(h.events_per_year)))
		if rng.randf() < float(h.events_per_year) - float(n):
			n += 1
		for k in n:
			_history_event(rng, year, str(RngUtils.weighted_pick(rng, weights).type))
	_sort_events_by_time()


func _history_event(rng: RandomNumberGenerator, year: int, type: String) -> void:
	var h: Dictionary = _gd.world_gen().history
	var living: Array = _db.find("people", func(p): return p.alive and not p.get("is_beast", false))
	if living.is_empty():
		return
	var years_ago: float = float(current_year - year)
	match type:
		"breakthrough":
			# Each person breaks into each realm at most once, lowest first, so the legends
			# stay consistent with the present (history_realm tracks the last one told).
			var cand: Array = living.filter(func(p): return int(p.get("history_realm", 0)) < int(p.realm_index))
			if cand.is_empty():
				return
			var p: Dictionary = RngUtils.pick(rng, cand)
			var r: int = int(p.get("history_realm", 0)) + 1
			if float(p.age) - years_ago < float(_gd.world_gen().people.age_min_by_realm[r]):
				return
			p["history_realm"] = r
			_log(year, "breakthrough", {"a": p.id, "realm": _gd.realm(r).name})
		"death_age":
			var r2: int = _builds.roll_realm(rng)
			var place: Dictionary = RngUtils.pick(rng, _db.all("places"))
			var dead: String = _db.add("people", _dead_person(_builds.person_name(rng, "male"), r2, "Thọ nguyên cạn kiệt", year, ""))
			_log(year, "death_age", {"a": dead, "realm": _gd.realm(r2).name, "place": place.id})
		"duel":
			var a: Dictionary = RngUtils.pick(rng, living)
			if float(a.age) - years_ago < 16.0:
				return
			var place2: Dictionary = RngUtils.pick(rng, _db.all("places"))
			if rng.randf() < float(h.duel_kill_chance):
				var r3: int = clampi(int(a.realm_index) - rng.randi_range(0, 1), 0, 4)
				var victim: String = _db.add("people", _dead_person(_builds.person_name(rng, "male"), r3, "Bị %s chém giết" % a.name, year, ""))
				_log(year, "duel_kill", {"a": a.id, "b": victim, "realm": _gd.realm(r3).name, "place": place2.id})
			else:
				var b: Dictionary = RngUtils.pick(rng, living)
				if b.id == a.id or float(b.age) - years_ago < 16.0:
					return
				var first: Dictionary = a if float(a.get("power", 0.0)) >= float(b.get("power", 0.0)) else b
				var second: Dictionary = b if first == a else a
				_log(year, "duel_win", {"a": first.id, "b": second.id, "place": place2.id})
		"sect_war":
			var active: Array = _db.find("sects", func(s): return s.status == "active")
			if active.size() < 2:
				return
			var pair: Array = RngUtils.shuffled(rng, active).slice(0, 2)
			_log(year, "sect_war", {"s1": pair[0].id, "s2": pair[1].id, "place": pair[1].hq_place_id})
		"treasure_found":
			var finder: Dictionary = RngUtils.pick(rng, living)
			if float(finder.age) - years_ago < 16.0:
				return
			var item: Dictionary = _items.random_material(rng, 4)
			item["owner_id"] = finder.id
			var iid: String = _db.add("items", item)
			var place3: Dictionary = RngUtils.pick(rng, _db.all("places"))
			_log(year, "treasure_found", {"a": finder.id, "item": iid, "place": place3.id})
		"treasure_lost":
			var art: Dictionary = _items.artifact(rng, rng.randi_range(0, 2), rng.randi_range(1, 3))
			var place4: Dictionary = RngUtils.pick(rng, _db.all("places"))
			art["owner_id"] = place4.id
			art["lost"] = true
			var aid: String = _db.add("items", art)
			var former: String = _db.add("people", _dead_person(_builds.person_name(rng, "male"), int(art.tier), "Mất tích", year, ""))
			_log(year, "treasure_lost", {"a": former, "item": aid, "place": place4.id})
		"disciple":
			var masters: Array = living.filter(func(p): return int(p.realm_index) >= 1)
			if masters.is_empty():
				return
			var m: Dictionary = RngUtils.pick(rng, masters)
			var students: Array = living.filter(func(p): return int(p.realm_index) < int(m.realm_index) and p.master_id == "" and p.id != m.id and str(p.sect_id) == str(m.sect_id))
			if students.is_empty():
				return
			var s: Dictionary = RngUtils.pick(rng, students)
			if float(s.age) - years_ago < 16.0:
				return
			s["master_id"] = m.id
			_log(year, "disciple", {"a": m.id, "b": s.id})
		"betrayal":
			var members: Array = living.filter(func(p): return p.sect_id != "" and p.sect_rank != "tong_chu")
			if members.is_empty():
				return
			var traitor: Dictionary = RngUtils.pick(rng, members)
			var old_sect: Dictionary = _db.get_record("sects", traitor.sect_id)
			var others: Array = _db.find("sects", func(x): return x.status == "active" and x.id != traitor.sect_id)
			old_sect.members.erase(traitor.id)
			if others.is_empty() or rng.randf() < float(h.betrayal_rogue_chance):
				traitor["sect_id"] = ""
				traitor["sect_rank"] = ""
				_log(year, "betrayal_rogue", {"a": traitor.id, "s1": old_sect.id})
			else:
				var ns: Dictionary = RngUtils.pick(rng, others)
				traitor["sect_id"] = ns.id
				traitor["sect_rank"] = "ngoai_mon"
				ns.members.append(traitor.id)
				_log(year, "betrayal", {"a": traitor.id, "s1": old_sect.id, "s2": ns.id})
		"secret_realm":
			var realms: Array = _db.find("places", func(p): return p.type == "bi_canh")
			if realms.is_empty():
				return
			var opener: Dictionary = RngUtils.pick(rng, living)
			_log(year, "secret_realm", {"a": opener.id, "place": RngUtils.pick(rng, realms).id})
		"newcomer":
			var young: Array = living.filter(func(p): return absf(float(p.age) - years_ago - 16.0) < 2.0)
			if young.is_empty():
				return
			var p2: Dictionary = RngUtils.pick(rng, young)
			_log(year, "newcomer", {"a": p2.id, "place": p2.location_id if p2.location_id != "" else RngUtils.pick(rng, _db.all("places")).id})


func _dead_person(person_name: String, realm_index: int, cause: String, death_year: int, sect_id: String) -> Dictionary:
	var c := Character.new()
	c.name = person_name
	c.alive = false
	c.realm_index = clampi(realm_index, 0, _gd.realms().size() - 1)
	c.death_cause = cause
	c.sect_id = sect_id
	var rec: Dictionary = c.to_dict()
	rec["death_year"] = death_year
	rec["created_by"] = "history"
	return rec


func _log(year: int, type: String, refs: Dictionary) -> void:
	var template: String = str(_gd.world_gen().history.texts.get(type, type))
	var people: Array = []
	var places: Array = []
	var items: Array = []
	var text: String = template
	for key in refs.keys():
		var v: String = str(refs[key])
		var rec: Dictionary = _db.lookup(v)
		var shown: String = str(rec.get("name", v)) if not rec.is_empty() else v
		text = text.replace("{%s}" % key, shown)
		match _db.table_of(v):
			"people", "sects":
				people.append(v)
			"places":
				places.append(v)
			"items":
				items.append(v)
	_db.log_event(year, 0, type, text, people, places, items, {"refs": refs})


func _sort_events_by_time() -> void:
	# Events were generated out of order (founding, legends, yearly); renumber by year so
	# ids and the event index read chronologically.
	var events: Array = _db.all("events")
	events.sort_custom(func(a, b): return int(a.year) < int(b.year))
	var fresh := WorldDB.new()
	var dump: Dictionary = _db.to_dict()
	dump.tables["events"] = {}
	dump.next_id["events"] = 1
	fresh = WorldDB.from_dict(dump)
	for e in events:
		fresh.log_event(int(e.year), int(e.season), str(e.type), str(e.text), e.people, e.places, e.items, e.data)
	_db = fresh


func _unique_word(rng: RandomNumberGenerator, words: Array) -> String:
	for attempt in 20:
		var w: String = RngUtils.pick(rng, words)
		if not _used_names.has(w):
			_used_names[w] = true
			return w
	return RngUtils.pick(rng, words)
