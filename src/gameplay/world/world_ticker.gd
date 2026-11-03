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
	for p in _db.all("people"):
		if not p.alive or p.get("is_player", false):
			continue
		p["age"] = float(p.age) + season_years
		var c := Character.from_dict(p)
		var lifespan: float = float(_gd.realm(c.realm_index).lifespan) + c.lifespan_bonus
		if c.age >= lifespan:
			p["alive"] = false
			p["death_cause"] = "Thọ nguyên cạn kiệt"
			p["death_year"] = year
			news.append(_log(year, season, "tick_death", texts, {"a": p.id, "realm": _gd.realm(c.realm_index).name}))
			continue
		if c.is_beast and c.owner_id == "":
			continue
		if c.stage < _gd.stage_count(c.realm_index) - 1:
			if rng.randf() < stage_chance:
				p["stage"] = c.stage + 1
				_builds.refresh_power(p.id)
		elif c.realm_index < _gd.realms().size() - 1:
			# Fate is rolled once per realm at the bình cảnh (ProgressionEdges: 0.30 baseline,
			# up to 0.70 with edges); a fated NPC breaks through within a few years.
			var fate: Dictionary = p.get("bt_fate", {})
			if int(fate.get("realm", -1)) != c.realm_index:
				fate = {"realm": c.realm_index, "ok": rng.randf() < ProgressionEdges.npc_step_chance(p, _gd).total}
				p["bt_fate"] = fate
			if bool(fate.ok) and rng.randf() < float(ProgressionEdges.config(_gd).npc.fated_breakthrough_per_season):
				p["realm_index"] = c.realm_index + 1
				p["stage"] = 0
				_builds.refresh_power(p.id)
				news.append(_log(year, season, "tick_breakthrough", texts, {"a": p.id, "realm": _gd.realm(c.realm_index + 1).name}))
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
