class_name WorldTicker
extends RefCounted
## The seasonal living-world tick: NPCs age, cultivate, break through, die of old age
## and fight, whether or not the player is there. Abstract by design (no per-tick
## simulation of bodies, economy or pathing). Design: game-concept.md § Core Mechanics 7
## and the granular-simulation anti-pillar. Data: world_generation.json (tick, history.texts).
##
## Usage:
## [codeblock]
## var ticker := WorldTicker.new(gd, db, builds)
## var news: Array = ticker.tick(rng, year, season)   # event ids logged this season
## [/codeblock]

var _gd: GameData
var _db: WorldDB
var _builds: BuildGenerator


func _init(gd: GameData, db: WorldDB, builds: BuildGenerator) -> void:
	_gd = gd
	_db = db
	_builds = builds


## Advances the world by one season. Returns the ids of events logged.
func tick(rng: RandomNumberGenerator, year: int, season: int) -> Array:
	var cfg: Dictionary = _gd.world_gen().tick
	var texts: Dictionary = _gd.world_gen().history.texts
	var season_years: float = 1.0 / float(_gd.cultivation_rules().seasons_per_year)
	var news: Array = []
	var stage_chance: float = 1.0 / maxf(float(cfg.npc_cultivation_seasons_per_stage), 1.0)
	var cultivators: int = 0
	for p in _db.all("people"):
		if not p.alive or p.get("is_player", false):
			continue
		if not p.get("is_beast", false):
			cultivators += 1
		p["age"] = float(p.age) + season_years
		# Read the record directly: a full Character per NPC per season is too slow at world size.
		var realm_index: int = int(p.realm_index)
		var stage: int = int(p.get("stage", 0))
		var base_life: float = float(_gd.realm(realm_index).lifespan)
		var lifespan: float = base_life + minf(float(p.get("lifespan_bonus", 0.0)), base_life * float(_gd.attributes().bonus_ceilings.lifespan_frac))
		if float(p.age) >= lifespan:
			p["alive"] = false
			p["death_cause"] = "Thọ nguyên cạn kiệt"
			p["death_year"] = year
			news.append(_log(year, season, "tick_death", texts, {"a": p.id, "realm": _gd.realm(realm_index).name}))
			continue
		if p.get("is_beast", false) and str(p.get("owner_id", "")) == "":
			continue
		if stage < _gd.stage_count(realm_index) - 1:
			if rng.randf() < stage_chance:
				p["stage"] = stage + 1
				p["level"] = Ladder.stage_first_level(_gd, realm_index, stage + 1)
				_builds.refresh_power(p.id)
		elif realm_index < _gd.realms().size() - 1:
			# Fate is rolled once per realm at the bình cảnh (ProgressionEdges, per-gate odds); a
			# fated NPC breaks through within a few years.
			var fate: Dictionary = p.get("bt_fate", {})
			if int(fate.get("realm", -1)) != realm_index:
				fate = {"realm": realm_index, "ok": rng.randf() < ProgressionEdges.npc_step_chance(p, _gd).total}
				p["bt_fate"] = fate
			if bool(fate.ok) and rng.randf() < float(ProgressionEdges.config(_gd).npc.fated_breakthrough_per_season):
				p["realm_index"] = realm_index + 1
				p["stage"] = 0
				p["level"] = Ladder.stage_first_level(_gd, realm_index + 1, 0)
				_builds.refresh_power(p.id)
				news.append(_log(year, season, "tick_breakthrough", texts, {"a": p.id, "realm": _gd.realm(realm_index + 1).name}))
	_intake(rng, cultivators)
	if rng.randf() < float(cfg.event_chance_per_season):
		var fighters: Array = _db.find("people", func(x): return x.alive and not x.get("is_player", false) and not x.get("is_beast", false))
		if fighters.size() >= 2:
			var pair: Array = RngUtils.shuffled(rng, fighters).slice(0, 2)
			var a: Dictionary = pair[0]
			var b: Dictionary = pair[1]
			var duel: Dictionary = CombatPower.duel(float(a.get("power", 1.0)), float(b.get("power", 1.0)), float(a.thien_phu.get("khi_van", 50)), float(b.thien_phu.get("khi_van", 50)), _gd, rng)
			var winner: Dictionary = a if duel.win else b
			var place: String = str(a.location_id) if str(a.location_id) != "" else str(RngUtils.pick(rng, _db.all("places")).id)
			news.append(_log(year, season, "tick_duel", texts, {"a": a.id, "b": b.id, "winner": winner.id, "place": place}))
	return news


## New cultivators (canh-gioi.md rule 12): each season the world replaces its dead, back up to
## world_cultivators. Tied to the target, not to the population, so it cannot drift.
func _intake(rng: RandomNumberGenerator, cultivators: int) -> void:
	for i in maxi(int(_gd.world_gen().people.world_cultivators) - cultivators, 0):
		new_cultivator(rng)


## One new Qi Refining cultivator, age 16, loose or in a sect at a rolled rank.
func new_cultivator(rng: RandomNumberGenerator) -> void:
	var npc: Dictionary = ProgressionEdges.config(_gd).npc
	var opts := {"realm_index": 0, "stage": 0, "age": 16.0}
	var sects: Array = _db.all("sects").filter(func(s): return str(s.get("status", "active")) == "active")
	var sect: Dictionary = {}
	if not sects.is_empty() and rng.randf() < float(npc.intake_sect_share):
		sect = RngUtils.pick(rng, sects)
		opts["sect_id"] = sect.id
		opts["location_id"] = sect.hq_place_id
		var u: float = rng.randf()
		var rank: String = "ngoai_mon"
		for r in npc.intake_rank_shares.keys():
			u -= float(npc.intake_rank_shares[r])
			if u < 0.0:
				rank = str(r)
				break
		opts["sect_rank"] = rank
	else:
		opts["location_id"] = str(RngUtils.pick(rng, _db.all("places")).id)
	var pid: String = _builds.create_person(rng, opts)
	if not sect.is_empty():
		sect.members.append(pid)


func _log(year: int, season: int, type: String, texts: Dictionary, refs: Dictionary) -> String:
	var text: String = str(texts.get(type, type))
	var people: Array = []
	var places: Array = []
	for key in refs.keys():
		var v: String = str(refs[key])
		var rec: Dictionary = _db.lookup(v)
		text = text.replace("{%s}" % key, str(rec.get("name", v)) if not rec.is_empty() else v)
		match _db.table_of(v):
			"people":
				if not people.has(v):
					people.append(v)
			"places":
				places.append(v)
	return _db.log_event(year, season, type, text, people, places, [], {"refs": refs, "news": true})
