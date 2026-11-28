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
	Ties.set_now(_db, MapChange.abs_season(year, season))   # NPC Relationships: the clock tie fades read
	var cultivators: int = 0
	var money: MoneyLedger = null
	if _db.count(WorldEconomy.TABLE) > 0:   # the season's money books (Regional Economy & Trade Formula H, AC-RE-07)
		money = MoneyLedger.new(_db)
		money.open_season()
	if _db.has_record("world", "w_meta"):   # the continent's sites produce and their reserves move (Travel & Map rules 21-22, 25)
		MapProduction.season(_gd, _db, season == 0)
		Provinces.season(_gd, _db, season, year)   # ADR-0008: the province contract (population yearly, Stage 5; events, Stage 7)
		if money != null:   # the markets read the season's production, then the money moves (rule 19)
			WorldEconomy.season(_gd, _db, money)
			last_money = WorldMoney.season(_gd, _db, money, year, season)
			news.append_array(SectPolitics.season(_gd, _db, money, year, season, str(_db.get_record("world", "w_meta").get("seed", ""))))
			# Cave Abode rule 12, F5: loose cultivators' abodes, one burn_abode aggregate
			CaveAbode.npc_season(_gd, _db, money, str(_db.get_record("world", "w_meta").get("seed", "")), MapChange.abs_season(year, season))
		news.append_array(MapChange.season(_db, year, season, str(_db.get_record("world", "w_meta").get("seed", ""))))
	if season == 0:   # Lost items left untouched long enough decay (item-database.md rule 14)
		for item in ItemRarity.decay_lost(_gd, _db, year):
			news.append(_log(year, season, "tick_item_decay", texts, {"item": str(item.get("name", item.id)), "place": str(item.owner_id)}))
	var q_cache := {}   # Living World Tick Formulas H: each place's stacked density, once this season
	if season == 0:   # Formulas H: the talent means are recomputed in Spring, before the people step
		TalentPlace.recompute(_gd, _db, q_cache)
	var abs_season: int = MapChange.abs_season(year, season)
	var has_traits_file: bool = _gd.registry.has_file(NpcTraits.FILE)
	for p in _db.living():
		if not p.alive or p.get("is_player", false):
			continue
		p["age"] = float(p.age) + season_years
		var nt: Dictionary = p.get("npc_traits", {})
		var has_gained: bool = not Array(nt.get("gained", [])).is_empty()
		var cop: Variant = nt.get("coping", {})
		var has_coping: bool = (cop is Dictionary and not (cop as Dictionary).is_empty()) or (cop is String and str(cop) != "")
		if has_gained or has_coping:   # NPC Traits rules 12 & F6b: gained and coping traits fade
			NpcTraits.fade(p, abs_season)
		# Read the record directly: a full Character per NPC per season is too slow at world size.
		var realm_index: int = int(p.realm_index)
		var stage: int = int(p.get("stage", 0))
		var base_life: float = float(_gd.realm(realm_index).lifespan)
		var lifespan: float = base_life + CultivationRules.lifespan_bonus_curved(_gd, realm_index, float(p.get("lifespan_bonus", 0.0)))
		if float(p.age) >= lifespan:
			news.append_array(old_age_death(p, year, season))
			continue
		if not p.get("is_beast", false) and has_traits_file:
			NpcTraits.update_waning(_gd, p, float(p.age), lifespan)
		if not p.get("is_beast", false):
			cultivators += 1
		if p.get("is_beast", false) and str(p.get("owner_id", "")) == "":
			continue
		if stage < _gd.stage_count(realm_index) - 1:
			# money speeds NPCs (user decision 2026-11-20): last season's provision bonus and stone boost (WorldMoney)
			# NPC Relationships rule 15a (user decision 2026-11-21): a master's and a đạo lữ's cultivation rows speed NPCs too
			var tie_mult: float = 1.0 + tie_cult_pct(p) / 100.0
			# Living World Tick Formulas A and H: p_stage = min(m_i / N_stage, 1), m_i by root and the place's density
			var p_stage: float = minf(stage_chance * TalentPlace.mult(_gd, _db, p, q_cache), 1.0)
			if rng.randf() < p_stage * (1.0 + float(p.get("prov", 0.0))) * (1.0 + float(p.get("stone_boost", 0.0))) * tie_mult:
				p["stage"] = stage + 1
				p["level"] = Ladder.stage_first_level(_gd, realm_index, stage + 1)
				_builds.refresh_power(p.id)
		elif realm_index < _gd.realms().size() - 1:
			# Fate is rolled once per realm at the bình cảnh (ProgressionEdges, per-gate odds); a
			# fated NPC breaks through within a few years.
			# Heavenly Tribulation (#22, Rule 1, AC-TK-05): NPC breakthroughs never trigger tribulation.
			var fate: Dictionary = p.get("bt_fate", {})
			if int(fate.get("realm", -1)) != realm_index:
				fate = {"realm": realm_index, "ok": rng.randf() < ProgressionEdges.npc_step_chance(p, _gd, _db).total}
				p["bt_fate"] = fate
			if bool(fate.ok) and rng.randf() < float(ProgressionEdges.config(_gd).npc.fated_breakthrough_per_season):
				p["realm_index"] = realm_index + 1
				_db.mark_hook_dirty(str(p.id))   # rule 15a: a master's or disciple's realm changed
				p["stage"] = 0
				p["level"] = Ladder.stage_first_level(_gd, realm_index + 1, 0)
				_builds.refresh_power(p.id)
				news.append(_log(year, season, "tick_breakthrough", texts, {"a": p.id, "realm": _gd.realm(realm_index + 1).name}))
	_intake(rng, cultivators)
	if rng.randf() < float(cfg.event_chance_per_season):
		var fighters: Array = _db.living().filter(func(x): return x.alive and not x.get("is_player", false) and not x.get("is_beast", false))
		if fighters.size() >= 2:
			var pair: Array = RngUtils.shuffled(rng, fighters).slice(0, 2)
			var a: Dictionary = pair[0]
			var b: Dictionary = pair[1]
			var duel: Dictionary
			var gap: float = INF
			if ratings != null and ratings.enabled():
				gap = absf(ratings.rating_of(str(a.id)) - ratings.rating_of(str(b.id)))
				duel = ratings.world_fight(a, b, rng)   # one session draw, as the duel (rule 11)
			else:
				duel = CombatPower.duel(float(a.get("power", 1.0)), float(b.get("power", 1.0)), float(a.thien_phu.get("khi_van", 50)), float(b.thien_phu.get("khi_van", 50)), _gd, rng)
			var winner: Dictionary = a if duel.win else b
			var loser: Dictionary = b if duel.win else a
			if float(winner.get("power", 0.0)) < float(loser.get("power", 0.0)):   # NPC Traits: defeated_by_lesser
				_grant(loser, "humbled", year, season)
			var place: String = str(a.location_id) if str(a.location_id) != "" else str(RngUtils.pick(rng, _db.all("places")).id)
			news.append(_log(year, season, "tick_duel", texts, {"a": a.id, "b": b.id, "winner": winner.id, "place": place}))
			# NPC Relationships decision 2 (user, 2026-11-21): a duel can kill, naming the winner, so world feuds form
			var kp: float = minf(float(cfg.get("duel_kill_p", 0.0)) * float(winner.get("power", 1.0)) / maxf(float(loser.get("power", 1.0)), 1.0),
				float(cfg.get("duel_kill_p_max", 0.25)))
			if kp > 0.0 and not bool(loser.get("is_player", false)) and rng.randf() < kp:
				news.append_array(npc_death(loser, year, season, "Tử trận", "duel", str(winner.id), "tick_duel_kill", {"a": winner.id, "b": loser.id, "place": place}))
			if gap == INF:   # Rankings off (the sims): close by power, the weaker at rival_power_ratio of the stronger (user, 2026-11-21)
				var pa: float = float(a.get("power", 1.0))
				var pb: float = float(b.get("power", 1.0))
				gap = 0.0 if minf(pa, pb) >= float(Ties.cfg(_gd).get("rival_power_ratio", 2.0)) * maxf(pa, pb) else INF
			if Ties.enabled(_gd) and gap <= float(Ties.cfg(_gd).rival_gap):   # NPC Relationships rule 8: a close world fight
				TieTick.enqueue(_db, {"kind": "soft", "holder": str(a.id), "other": str(b.id), "sk": "rival",
					"delta": int(Ties.cfg(_gd).delta.close_fight_rival), "cause": {"kind": "fight", "event": str(news[-1])}})
	# NPC Relationships rule 9: S8b, after the season's events
	news.append_array(TieTick.run(_gd, _db, MapChange.abs_season(year, season)))
	# NPC Interaction & Dialogue (#30): tick overdue loans & expire temporary seasonal buffs
	news.append_array(InteractionService.tick_world_season(_gd, _db, abs_season, year, season))
	return news


## The cultivation_speed_pct an NPC record's tie rows give (TieTick.hook_pass writes them; 0 for most people).
static func tie_cult_pct(p: Dictionary) -> float:
	var v: float = 0.0
	for r in p.get("tie_rows", []):
		if str(r.get("stat", "")) == "cultivation_speed_pct":
			v += float(r.get("value", 0.0))
	return v


## An NPC dies of old age: the record is marked dead, and with no killer a close relationship or the sect successor
## inherits, else the items are Lost where the NPC died (item-database.md rule 14); a dead sect leader's successor
## takes the leadership. Returns the ids of the events logged.
func old_age_death(p: Dictionary, year: int, season: int) -> Array:
	return npc_death(p, year, season, "Thọ nguyên cạn kiệt", "old_age", "", "tick_death", {"a": p.id, "realm": _gd.realm(int(p.realm_index)).name})


## An NPC dies of [param cause_key] (shown as [param cause]). With [param killer] "" a close relationship or the sect
## successor inherits; with a killer (a world duel), the killer takes the purse and the unbound items and the death is a
## known kill for NPC Relationships rule 13. Logs [param text_id] with [param args]. Returns the ids of the events.
func npc_death(p: Dictionary, year: int, season: int, cause: String, cause_key: String, killer: String, text_id: String, args: Dictionary) -> Array:
	var texts: Dictionary = _gd.world_gen().history.texts
	var news: Array = []
	var heir: String = killer if killer != "" else Inheritance.heir_of(_db, _gd, p)
	if _db.count(WorldEconomy.TABLE) > 0:   # the purse goes to the killer, the heir, the sect or the lost stash (Formula H)
		WorldMoney.settle_death(_gd, _db, MoneyLedger.new(_db), p, heir)
	p["alive"] = false
	p["death_cause"] = cause
	p["death_year"] = year
	_bereave(p, year, season)
	InteractionService.on_npc_death(_db, str(p.id), year, season)
	news.append(_log(year, season, text_id, texts, args))
	TieTick.enqueue(_db, {"kind": "death", "dead": str(p.id), "killer": killer, "known": killer != "", "cause": cause_key,
		"place": str(p.get("location_id", "")), "event": str(news[-1])})   # NPC Relationships rule 13 at S8b
	_db.items_on_death(p.id, str(p.get("location_id", "")), killer, heir)
	var succ: String = _succeed_leader(p)
	if succ != "":
		news.append(_log(year, season, "tick_succession", texts, {"a": succ, "b": p.id}))
	return news


# NPC Traits rule 11 with the catalogue's trigger `bereaved`: the dead person's living close ties (NPC Relationships
# rule 13's set: master, disciples, kin, đạo lữ, kết nghĩa; user decision 2026-11-21) become Grieving. Read before S8b
# removes the dead's records.
func _bereave(dead: Dictionary, year: int, season: int) -> void:
	for pid in TieTick.close_ties(_db, str(dead.id)).all:
		var p: Dictionary = _db.get_record("people", str(pid))
		if bool(p.get("alive", false)):
			_grant(p, "grieving", year, season)


# Grants gained trait [param id] to [param p] (NPC Traits rule 11), when the catalogue is loaded.
func _grant(p: Dictionary, id: String, year: int, season: int) -> void:
	if _gd.registry.has_file(NpcTraits.FILE) and not bool(p.get("is_player", false)):
		NpcTraits.grant(_gd, p, id, MapChange.abs_season(year, season))


## Advances the living world by [param count] seasons without a player (used during Continue-mode
## rebirth gaps, Codex & Karmic Carryover #12 Rule 4, AC-CK-06). Returns `{year, season, news}`.
func advance_seasons(rng: RandomNumberGenerator, start_year: int, start_season: int, count: int) -> Dictionary:
	var spy: int = maxi(1, int(_gd.cultivation_rules().seasons_per_year))
	var y: int = start_year
	var s: int = start_season
	var news: Array = []
	for _i in maxi(0, count):
		s += 1
		if s >= spy:
			s = 0
			y += 1
		news.append_array(tick(rng, y, s))
	return {"year": y, "season": s, "news": news}


## Public entry for sect leader succession when a player or NPC sect leader dies (Tick rule 9).
func settle_sect_leader(dead: Dictionary) -> String:
	return _succeed_leader(dead)


## Public entry for bereaving close living ties of [param dead] before S8b removes the dead's ties.
func bereave_close_ties(dead: Dictionary, year: int, season: int) -> void:
	_bereave(dead, year, season)


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


## New cultivators (canh-gioi.md rule 12; Living World Tick rule 5 & Formulas D; Sects F21): each season the world
## replaces that season's dead back up to max(world_cultivators, world_cultivators_min). Parent births roll their root
## from the parent's province and join the parent's sect only if they pass its outer admission test; failing births,
## loose-parent births, and random newcomers enter the seasonal pool and are allocated across active sects by Formulas D
## claims and Sects F21 admission/scoring.
func _intake(rng: RandomNumberGenerator, cultivators: int) -> void:
	var people: Dictionary = _gd.world_gen().people
	var n: int = maxi(maxi(int(people.world_cultivators), int(people.world_cultivators_min)) - cultivators, 0)
	if n <= 0:
		return
	var share: float = float(Families.cfg(_gd).get("birth_share", 0.0))
	var idx: Dictionary = Families.index(_db) if share > 0.0 else {}
	var settled_info: Dictionary = _settled_places()
	var settled: Array = settled_info.places
	var settled_w: Array = settled_info.weights
	var pool: Array = []
	for i in n:
		var parent: Dictionary = {}
		if not idx.is_empty() and rng.randf() < share:   # Living World Tick rule 5, Births (user, 2026-11-21)
			parent = Families.pick_parent(_gd, idx, "*", 16.0, "birth:%d:%d" % [Ties.now(_db), i])
		if not parent.is_empty():
			var rec: Dictionary = _birth_to_parent(rng, parent, idx)
			if str(rec.get("sect_id", "")) == "":
				pool.append(rec)
		else:
			var bp_rec: Dictionary = _weighted_place(rng, settled, settled_w)
			var bp_id: String = str(bp_rec.get("id", ""))
			var lc: LinhCan = LinhCan.roll(_gd, rng, LinhCan.province_land(_gd, bp_rec))
			var opts := {
				"realm_index": 0, "stage": 0, "age": 16.0,
				"sect_id": "", "sect_rank": "",
				"location_id": bp_id, "birthplace": bp_id, "linh_can": lc,
			}
			var pid: String = _builds.create_person(rng, opts)
			pool.append(_db.get_record("people", pid))
	if pool.is_empty():
		return
	var active_sects: Array = _db.all("sects").filter(func(s): return str(s.get("status", "active")) == "active")
	if active_sects.is_empty():
		return
	var sects_in_order: Array = active_sects.duplicate()
	sects_in_order.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var ga: int = 0 if str(a.get("kind", "")) == "great" else 1
		var gb: int = 0 if str(b.get("kind", "")) == "great" else 1
		if ga != gb:
			return ga < gb
		return str(a.id) < str(b.id))
	var claims: Dictionary = {}
	if sects_in_order.any(func(s): return s.has("invested")):
		var living_count: Dictionary = {}
		for p in _db.living():
			if bool(p.get("alive", false)) and not bool(p.get("is_beast", false)):
				var sid: String = str(p.get("sect_id", ""))
				if sid != "":
					living_count[sid] = int(living_count.get(sid, 0)) + 1
		var demands: Dictionary = {}
		for s in sects_in_order:
			var sid: String = str(s.id)
			var st: String = str(s.get("state", "steady"))
			if st == "strained" or st == "collapsing":
				demands[sid] = 0
			else:
				demands[sid] = SectEconomy.intake(_gd, _db, s, int(living_count.get(sid, 0)))
		claims = allocate_claims(sects_in_order, demands, pool.size())
	else:
		# Legacy non-continent WorldGenerator worlds lack invested tracks; preserve compatible intake share.
		var share_sect: float = float(ProgressionEdges.config(_gd).npc.get("intake_sect_share", 0.9))
		var target_total: int = clampi(int(round(float(pool.size()) * share_sect)), 0, pool.size())
		var demands: Dictionary = {}
		for s in sects_in_order:
			demands[str(s.id)] = maxi(target_total, 1)
		claims = allocate_claims(sects_in_order, demands, target_total)
	var home_fn := func(sect: Dictionary, person: Dictionary) -> bool:
		return _is_home_ground(sect, person)
	var kin_fn := func(sect: Dictionary, person: Dictionary) -> bool:
		return _is_sect_kin(sect, person)
	var res: Dictionary = SectAdmission.fill_claims(_gd, sects_in_order, claims, pool, home_fn, kin_fn)
	for s in sects_in_order:
		var sid: String = str(s.id)
		for rec in res.admitted.get(sid, []):
			rec["sect_id"] = sid
			rec["sect_rank"] = "ngoai_mon"
			rec["location_id"] = str(s.get("hq_place_id", ""))
			s.members.append(str(rec.id))
			var mid: String = SectEconomy.pick_master(_gd, _db, s, 0, rng)
			if mid != "":
				Ties.set_master(_gd, _db, str(rec.id), mid, Ties.now(_db))
				if rec.has("npc_traits") and not rec.has("cast_key") and _gd.registry.has_file(NpcTraits.FILE):
					var master: Dictionary = _db.get_record("people", mid)
					var bp_id: String = str(rec.get("birthplace", ""))
					var bp_kind: String = str(_db.get_record("places", bp_id).get("kind", "")) if bp_id != "" else ""
					var parents: Array = []
					if str(rec.get("parent_id", "")) != "":
						var par: Dictionary = _db.get_record("people", str(rec.parent_id))
						if not par.is_empty():
							parents.append(par.get("npc_traits", {}))
					var roll_opts := {
						"realm_index": int(rec.get("realm_index", 0)),
						"linh_can": rec.get("linh_can", {}),
						"birthplace_kind": bp_kind,
						"parents": parents,
						"now": Ties.now(_db),
					}
					rec["npc_traits"] = NpcTraits.roll(_gd, _builds.trait_key(str(rec.id)), str(rec.get("archetype", "")), true,
						master.get("npc_traits", {}).get("personality", []), rec.get("thien_phu", {}), roll_opts)
					_builds.refresh_power(str(rec.id))


## Living World Tick Formulas D: splits [param pool_size] across [param sects] given per-sect demands
## `{sect_id: d_s}` via largest remainder (ties to lower `str(sect.id)`). Returns `{sect_id: claim_s}`.
static func allocate_claims(sects: Array, demands: Dictionary, pool_size: int) -> Dictionary:
	var claims: Dictionary = {}
	var total_d: int = 0
	for s in sects:
		var sid: String = str(s.id)
		var d_s: int = maxi(0, int(demands.get(sid, 0)))
		claims[sid] = 0
		total_d += d_s
	if pool_size <= 0 or total_d <= 0:
		return claims
	if total_d <= pool_size:
		for s in sects:
			var sid: String = str(s.id)
			claims[sid] = maxi(0, int(demands.get(sid, 0)))
		return claims
	var rems: Array = []
	var used: int = 0
	for s in sects:
		var sid: String = str(s.id)
		var d_s: int = maxi(0, int(demands.get(sid, 0)))
		var exact: float = float(pool_size) * float(d_s) / float(total_d)
		var fl: int = int(floor(exact))
		claims[sid] = fl
		used += fl
		rems.append({"id": sid, "rem": exact - float(fl)})
	rems.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var ra: float = float(a.rem)
		var rb: float = float(b.rem)
		if not is_equal_approx(ra, rb):
			return ra > rb
		return str(a.id) < str(b.id))
	var left: int = pool_size - used
	for k in mini(left, rems.size()):
		var sid: String = str(rems[k].id)
		claims[sid] = int(claims[sid]) + 1
	return claims


## One new Qi Refining cultivator, age 16. When [param parent] is non-empty, rolls the child's root from the parent's
## location province and joins the parent's active sect only if the root passes outer admission (sects.md F21); else
## starts loose at the parent's location.
func new_cultivator(rng: RandomNumberGenerator, parent: Dictionary = {}, idx: Dictionary = {}) -> void:
	if not parent.is_empty():
		_birth_to_parent(rng, parent, idx)
		return
	var settled_info: Dictionary = _settled_places()
	var bp_rec: Dictionary = _weighted_place(rng, settled_info.places, settled_info.weights)
	var bp_id: String = str(bp_rec.get("id", ""))
	var lc: LinhCan = LinhCan.roll(_gd, rng, LinhCan.province_land(_gd, bp_rec))
	var npc: Dictionary = ProgressionEdges.config(_gd).npc
	var opts := {"realm_index": 0, "stage": 0, "age": 16.0, "location_id": bp_id, "birthplace": bp_id, "linh_can": lc}
	var sects: Array = _db.all("sects").filter(func(s): return str(s.get("status", "active")) == "active")
	var sect: Dictionary = {}
	if not sects.is_empty() and rng.randf() < float(npc.intake_sect_share):
		var cand: Dictionary = _intake_sect(rng, sects)
		if not cand.is_empty() and SectAdmission.admits_outer(_gd, cand, lc):
			sect = cand
			opts["sect_id"] = str(sect.id)
			opts["location_id"] = str(sect.hq_place_id)
			opts["sect_rank"] = "ngoai_mon"
			opts["master_id"] = SectEconomy.pick_master(_gd, _db, sect, 0, rng)
	var pid: String = _builds.create_person(rng, opts)
	if not sect.is_empty():
		sect.members.append(pid)


# Spawns a child born to [param parent] at age 16 Qi Refining with root rolled from the parent's location province.
# Joins the parent's active sect at ngoai_mon iff the root passes SectAdmission.admits_outer; else stays loose.
func _birth_to_parent(rng: RandomNumberGenerator, parent: Dictionary, idx: Dictionary) -> Dictionary:
	var bp_id: String = str(parent.get("location_id", ""))
	var parent_place: Dictionary = _db.get_record("places", bp_id) if bp_id != "" else {}
	var lc: LinhCan = LinhCan.roll(_gd, rng, LinhCan.province_land(_gd, parent_place))
	var opts := {
		"realm_index": 0, "stage": 0, "age": 16.0,
		"location_id": bp_id, "birthplace": bp_id, "linh_can": lc,
		"parent_traits": [parent.get("npc_traits", {})],
	}
	var psect: Dictionary = _db.get_record("sects", str(parent.get("sect_id", ""))) if str(parent.get("sect_id", "")) != "" else {}
	if not psect.is_empty() and str(psect.get("status", "active")) != "active":
		psect = {}
	var joined: Dictionary = {}
	if not psect.is_empty() and SectAdmission.admits_outer(_gd, psect, lc):
		joined = psect
		opts["sect_id"] = str(psect.id)
		opts["sect_rank"] = "ngoai_mon"
		opts["location_id"] = str(psect.hq_place_id)
		opts["master_id"] = SectEconomy.pick_master(_gd, _db, psect, 0, rng)
	else:
		opts["sect_id"] = ""
		opts["sect_rank"] = ""
	var pid: String = _builds.create_person(rng, opts)
	if not joined.is_empty():
		joined.members.append(pid)
	var rec: Dictionary = _db.get_record("people", pid)
	Families.link(_gd, _db, rec, parent, Ties.now(_db), false, idx)
	return rec


func _settled_places() -> Dictionary:
	var cont_cfg: Dictionary = _gd.world_gen().get("continent", {})
	var settled_kinds: Array = Array(cont_cfg.get("settled_kinds", []))
	var settle_w_cfg: Dictionary = Dictionary(cont_cfg.get("settle_weight", {}))
	var places: Array = _db.find("places", func(p): return str(p.get("kind", "")) in settled_kinds and not bool(p.get("hidden", false)))
	if places.is_empty():
		places = _db.all("places").duplicate()
	places.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var ca: int = int(a.get("continent_id", 0))
		var cb: int = int(b.get("continent_id", 0))
		if ca != cb:
			return ca < cb
		return str(a.id) < str(b.id))
	var weights: Array = []
	for p in places:
		weights.append(float(settle_w_cfg.get(str(p.get("kind", "")), 1.0)))
	return {"places": places, "weights": weights}


static func _weighted_place(rng: RandomNumberGenerator, places: Array, weights: Array) -> Dictionary:
	if places.is_empty():
		return {}
	var total: float = 0.0
	for w in weights:
		total += maxf(float(w), 0.0)
	if total <= 0.0:
		return places[rng.randi_range(0, places.size() - 1)]
	var x: float = rng.randf() * total
	for i in places.size():
		x -= maxf(float(weights[i]), 0.0)
		if x < 0.0:
			return places[i]
	return places[-1]


# Sects F21 `home`: birthplace in a great sect's territory/regions, or a minor sect's seat province / held sites.
func _is_home_ground(sect: Dictionary, person: Dictionary) -> bool:
	var bp_id: String = str(person.get("birthplace", person.get("location_id", "")))
	if bp_id == "":
		return false
	var bp: Dictionary = _db.get_record("places", bp_id)
	if bp.is_empty():
		return false
	var sid: String = str(sect.id)
	if str(sect.get("kind", "")) == "great":
		return str(bp.get("territory", "")) == sid or Array(sect.get("regions", [])).has(str(bp.get("region_id", "")))
	if str(bp.get("holder", "")) == sid or str(bp.get("sect_id", "")) == sid or str(bp.get("territory", "")) == sid:
		return true
	var hq: Dictionary = _db.get_record("places", str(sect.get("hq_place_id", "")))
	var hq_prov: String = str(hq.get("province_id", "")) if not hq.is_empty() else ""
	if hq_prov != "":
		return str(bp.get("province_id", "")) == hq_prov
	var lord_id: String = str(sect.get("lord_id", ""))
	if lord_id != "" and str(bp.get("territory", "")) == lord_id and str(bp.get("region_id", "")) == str(sect.get("region_id", "")):
		return true
	return str(sect.get("region_id", "")) != "" and str(bp.get("region_id", "")) == str(sect.get("region_id", ""))


# Sects F21 `kin`: true when a parent or grandparent in WorldDB is a living member of [param sect].
func _is_sect_kin(sect: Dictionary, person: Dictionary) -> bool:
	var sid: String = str(sect.id)
	var par_id: String = str(person.get("parent_id", ""))
	if par_id == "":
		return false
	var par: Dictionary = _db.get_record("people", par_id)
	if par.is_empty():
		return false
	if bool(par.get("alive", false)) and str(par.get("sect_id", "")) == sid:
		return true
	var gp_id: String = str(par.get("parent_id", ""))
	if gp_id == "":
		return false
	var gp: Dictionary = _db.get_record("people", gp_id)
	return not gp.is_empty() and bool(gp.get("alive", false)) and str(gp.get("sect_id", "")) == sid


# Sects F17: the sect a new cultivator joins, weighted by each sect's intake this season (a sect at or over its target
# takes none); any sect when none has room (as before the economy).
func _intake_sect(rng: RandomNumberGenerator, sects: Array) -> Dictionary:
	if not sects.any(func(s): return s.has("invested")):
		return RngUtils.pick(rng, sects)
	var counts := {}
	for p in _db.living():
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
