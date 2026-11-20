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
## Power Rankings (rule 11): when set and enabled, a duel is Formulas F's roll on the two ratings instead of chiến lực.
var ratings: RatingService
## The last season's money flows by kind (WorldMoney.season), for the harness and the economy probe.
var last_money: Dictionary = {}


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
	var money: MoneyLedger = null
	if _db.count(WorldEconomy.TABLE) > 0:   # the season's money books (Regional Economy & Trade Formula H, AC-RE-07)
		money = MoneyLedger.new(_db)
		money.open_season()
	if _db.has_record("world", "w_meta"):   # the continent's sites produce and their reserves move (Travel & Map rules 21-22, 25)
		MapProduction.season(_gd, _db, season == 0)
		if money != null:   # the markets read the season's production, then the money moves (rule 19)
			WorldEconomy.season(_gd, _db, money)
			last_money = WorldMoney.season(_gd, _db, money, year, season)
			news.append_array(SectPolitics.season(_gd, _db, money, year, season, str(_db.get_record("world", "w_meta").get("seed", ""))))
		news.append_array(MapChange.season(_db, year, season, str(_db.get_record("world", "w_meta").get("seed", ""))))
	if season == 0:   # Lost items left untouched long enough decay (item-database.md rule 14)
		for item in ItemRarity.decay_lost(_gd, _db, year):
			news.append(_log(year, season, "tick_item_decay", texts, {"item": str(item.get("name", item.id)), "place": str(item.owner_id)}))
	for p in _db.all("people"):
		if not p.alive or p.get("is_player", false):
			continue
		p["age"] = float(p.age) + season_years
		# Read the record directly: a full Character per NPC per season is too slow at world size.
		var realm_index: int = int(p.realm_index)
		var stage: int = int(p.get("stage", 0))
		var base_life: float = float(_gd.realm(realm_index).lifespan)
		var lifespan: float = base_life + minf(float(p.get("lifespan_bonus", 0.0)), base_life * float(_gd.attributes().bonus_ceilings.lifespan_frac))
		if float(p.age) >= lifespan:
			news.append_array(old_age_death(p, year, season))
			continue
		if not p.get("is_beast", false):
			cultivators += 1
		if p.get("is_beast", false) and str(p.get("owner_id", "")) == "":
			continue
		if stage < _gd.stage_count(realm_index) - 1:
			# money speeds NPCs (user decision 2026-11-20): last season's provision bonus and stone boost (WorldMoney)
			if rng.randf() < stage_chance * (1.0 + float(p.get("prov", 0.0))) * (1.0 + float(p.get("stone_boost", 0.0))):
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
			var duel: Dictionary
			if ratings != null and ratings.enabled():
				duel = ratings.world_fight(a, b, rng)   # one session draw, as the duel (rule 11)
			else:
				duel = CombatPower.duel(float(a.get("power", 1.0)), float(b.get("power", 1.0)), float(a.thien_phu.get("khi_van", 50)), float(b.thien_phu.get("khi_van", 50)), _gd, rng)
			var winner: Dictionary = a if duel.win else b
			var place: String = str(a.location_id) if str(a.location_id) != "" else str(RngUtils.pick(rng, _db.all("places")).id)
			news.append(_log(year, season, "tick_duel", texts, {"a": a.id, "b": b.id, "winner": winner.id, "place": place}))
	return news


## An NPC dies of old age: the record is marked dead, and with no killer a close relationship or the sect successor
## inherits, else the items are Lost where the NPC died (item-database.md rule 14); a dead sect leader's successor
## takes the leadership. Returns the ids of the events logged.
func old_age_death(p: Dictionary, year: int, season: int) -> Array:
	var texts: Dictionary = _gd.world_gen().history.texts
	var news: Array = []
	var heir: String = Inheritance.heir_of(_db, _gd, p)
	if _db.count(WorldEconomy.TABLE) > 0:   # the purse goes to the heir, the sect or the lost stash (Formula H)
		WorldMoney.settle_death(_gd, _db, MoneyLedger.new(_db), p, heir)
	p["alive"] = false
	p["death_cause"] = "Thọ nguyên cạn kiệt"
	p["death_year"] = year
	news.append(_log(year, season, "tick_death", texts, {"a": p.id, "realm": _gd.realm(int(p.realm_index)).name}))
	_db.items_on_death(p.id, str(p.get("location_id", "")), "", heir)
	var succ: String = _succeed_leader(p)
	if succ != "":
		news.append(_log(year, season, "tick_succession", texts, {"a": succ, "b": p.id}))
	return news


## When [param dead] led a sect, its successor (Inheritance.sect_successor) becomes the leader. Returns the new
## leader's id, or "".
func _succeed_leader(dead: Dictionary) -> String:
	var sect: Dictionary = _db.get_record("sects", str(dead.get("sect_id", "")))
	if sect.is_empty() or str(sect.get("leader_id", "")) != str(dead.id):
		return ""
	var heir: String = Inheritance.sect_successor(_db, _gd, dead)
	if heir == "":
		return ""
	var ladder: Array = _gd.world_gen().sects.rank_ladder
	sect["leader_id"] = heir
	_db.get_record("people", heir)["sect_rank"] = str(ladder[-1])
	return heir


## New cultivators (canh-gioi.md rule 12): each season the world replaces that season's dead, back
## up to world_cultivators and never below world_cultivators_min. Tied to the target, not to the
## population, so it cannot drift. [param cultivators] counts those alive after the season's deaths.
func _intake(rng: RandomNumberGenerator, cultivators: int) -> void:
	var people: Dictionary = _gd.world_gen().people
	for i in maxi(maxi(int(people.world_cultivators), int(people.world_cultivators_min)) - cultivators, 0):
		new_cultivator(rng)


## One new Qi Refining cultivator, age 16, loose or in a sect at a rolled rank.
func new_cultivator(rng: RandomNumberGenerator) -> void:
	var npc: Dictionary = ProgressionEdges.config(_gd).npc
	var opts := {"realm_index": 0, "stage": 0, "age": 16.0}
	var sects: Array = _db.all("sects").filter(func(s): return str(s.get("status", "active")) == "active")
	var sect: Dictionary = {}
	if not sects.is_empty() and rng.randf() < float(npc.intake_sect_share):
		sect = _intake_sect(rng, sects)
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


# Sects F17: the sect a new cultivator joins, weighted by each sect's intake this season (a sect at or over its target
# takes none); any sect when none has room (as before the economy).
func _intake_sect(rng: RandomNumberGenerator, sects: Array) -> Dictionary:
	if not sects.any(func(s): return s.has("invested")):
		return RngUtils.pick(rng, sects)
	var counts := {}
	for p in _db.all("people"):
		if bool(p.get("alive", false)) and str(p.get("sect_id", "")) != "":
			counts[str(p.sect_id)] = int(counts.get(str(p.sect_id), 0)) + 1
	var w: Array = []
	for s in sects:
		var k: int = SectEconomy.intake(_gd, _db, s, int(counts.get(str(s.id), 0)))
		if k > 0:
			w.append({"id": str(s.id), "weight": float(k)})
	if w.is_empty():
		return RngUtils.pick(rng, sects)
	return _db.get_record("sects", str(RngUtils.weighted_pick(rng, w).id))


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
