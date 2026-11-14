class_name RatingService
extends RefCounted
## Power Rankings' ratings (design/gdd/power-rankings.md; ADR-0003): each fighter's base from a ladder panel, its
## learned offset, its state, kept in the World DB's "ratings" table under the fighter's id. Covers provisional
## ratings, panels, the season batch (matchmaking, round robins, rule 14's scheduling, rule 13's ordered apply,
## Formulas D) and world generation's coarse panels (rule 16). Behind combat_rankings.json "enabled" (off): callers
## check [method enabled].
##
## Build changes (rule 5) are detected, not signalled: [method refresh] compares each fighter's build signature
## (realm, stage, level and chiến lực, which every build change of rule 5 moves) with the one its panel ran on. Until
## each system raises its own build-change signal, a change that leaves chiến lực exactly unchanged is not seen.
##
## Usage:
## [codeblock]
## var rs := RatingService.new(gd, db)
## rs.sheet_fn = builds.sheet_of                               # NPC sheets with their Kinh Mạch Đồ
## rs.worldgen(game_seed, player, player_sheet, start_place)    # rule 16, while the game loads
## var batch: SeasonBatch = rs.plan_season(game_seed, key, year, s, player, player_sheet)
## batch.run(true)
## rs.apply_batch(batch)
## var shown: int = rs.power_number(c)                         # Formulas E
## [/codeblock]

const TABLE := "ratings"
## The ratings-table record holding the season work that outlives a season (the year's Kết Đan round robin).
const SEASON_RECORD := "~season"

## The state names stored on a rating record (GDD States and Transitions).
const PROVISIONAL := "provisional"
const RATED := "rated"
const STALE := "stale"
const GONE := "gone"

## The ADR-0002 keyed-stream prefix of a matchmaking draw (rule 7): game seed, season, realm, round.
const MATCH_KEY := "rankm:%d:%d:%d:%d"
## The prefix of the Kết Đan round robin's slice order (rule 8): game seed, year, season.
const KD_KEY := "rankkd:%d:%d:%d"
## The realms of the every-season round robin and of the yearly one (rule 8).
const TOP_REALMS := [3, 4]
const KD_REALM := 2

var ladder: RatingLadder
## Callable(c: Character) -> StatSheet used to compile NPCs; defaults to a sheet without the Kinh Mạch Đồ.
var sheet_fn: Callable
## Problems met while rating (compile refusals, fighters off a ladder end), newest last; the caller may clear it.
var log_lines: PackedStringArray = []
var _gd: GameData
var _db: WorldDB
var _k: CombatConstants
var _knobs: Dictionary
var _compiled: Dictionary = {}     # person id -> {sig, profile} (NPCs only)
var _max_fights: Dictionary = {}   # "start_k:step:stop:fights" -> PanelSearch.max_fights
var _prebuilt := false


## [param db] holds the ratings table; the ladder and knobs come from [param gd].
func _init(gd: GameData, db: WorldDB) -> void:
	_gd = gd
	_db = db
	ladder = RatingLadder.from_game_data(gd)
	_knobs = ladder.data
	_k = CombatConstants.from_game_data(gd)
	sheet_fn = func(c: Character) -> StatSheet: return StatSheet.build(c, _gd, _db, null)


## The feature flag (combat_rankings.json "enabled").
func enabled() -> bool:
	return bool(_knobs.get("enabled", false))


## A knob from combat_rankings.json (for callers and tests).
func knob(key: String) -> Variant:
	return _knobs.get(key)


## [param c]'s rating record, made Provisional (Formulas G) when it has none. Fields: base, offset, n, state, realm
## (of its base), version (the data version its base was measured on), sig (the build signature its panel ran on),
## seeds (the season and per-rung fight counts that keep panel seeds distinct within a season).
func ensure(c: Character) -> Dictionary:
	return _ensure(c.id, c.realm_index, c.stage)


func _ensure(id: String, realm: int, stage: int) -> Dictionary:
	var rec: Dictionary = _db.get_record(TABLE, id)
	if rec.is_empty():
		var r: int = clampi(realm, 0, 4)
		rec = {"id": id, "base": _snap(ladder.provisional(r, stage, _gd)), "offset": 0.0, "n": 0, "state": PROVISIONAL,
			"realm": r, "version": str(_knobs.get("data_version", "")), "sig": "", "seeds": {"season": -1, "counts": {}}}
		_db.put(TABLE, rec)
	return rec


## [param c]'s rating, base + offset (Core Rules rule 2).
func rating(c: Character) -> float:
	var rec: Dictionary = ensure(c)
	return float(rec.base) + float(rec.offset)


## The rating of the fighter with id [param id] (0 when it has no record).
func rating_of(id: String) -> float:
	var rec: Dictionary = _db.get_record(TABLE, id)
	return 0.0 if rec.is_empty() else float(rec.base) + float(rec.offset)


## [param c]'s shown power number (Formulas E).
func power_number(c: Character) -> int:
	return ladder.power_number(rating(c))


## Marks [param c] Stale after a build change (Core Rules rule 5); its rating stands until its panel runs.
func mark_stale(c: Character) -> void:
	var rec: Dictionary = ensure(c)
	if str(rec.state) == RATED:
		rec["state"] = STALE


## A person record's build signature (rule 5): a hash of what a build change changes — realm, stage, level, talents
## (without khí vận: AC-PR-08), linh căn, each technique's layer, the slotted techniques, the equipped items' records
## and slots, opened huyệt, capabilities, perks and the nurtured item. Not chiến lực: it moves with injury, and a
## technique's mastery moves every season, neither of which is a build change. Numbers are normalised so a save and
## load (ints back as floats) leaves it unchanged.
func build_sig(person: Dictionary) -> String:
	var layers := {}
	var techs: Dictionary = person.get("techniques", {})
	for k in techs:
		layers[str(k)] = int((techs[k] as Dictionary).get("layer", 0)) if techs[k] is Dictionary else 0
	var talents: Dictionary = (person.get("thien_phu", {}) as Dictionary).duplicate()
	talents.erase("khi_van")
	var worn: Array = []
	var eq: Array = Array(person.get("equipped", [])).map(func(x): return str(x))
	eq.sort()
	for id in eq:
		worn.append(_db.get_record("items", id))
	var parts: Array = [int(person.get("realm_index", 0)), int(person.get("stage", 0)), int(person.get("level", 0)),
		talents, person.get("linh_can", {}), layers, person.get("main_tech", ""), person.get("aux_tech", []),
		person.get("second_tech", ""), person.get("equip_slots", {}), person.get("tree_nodes", []),
		person.get("capabilities", []), person.get("perks", []), person.get("nurtured_id", ""), worn]
	return str(RngUtils.stable_hash(JSON.stringify(_norm(parts), "", true)))


## [param v] with every whole-number float made an int, recursively (JSON gives back 3 as 3.0).
static func _norm(v: Variant) -> Variant:
	if v is float and is_finite(v) and float(v) == floorf(v) and absf(v) < 1e15:
		return int(v)
	if v is Array:
		return (v as Array).map(func(x): return _norm(x))
	if v is Dictionary:
		var out := {}
		for k in v:
			out[str(k)] = _norm(v[k])
		return out
	return v


## Brings every person's rating record up to date with the World DB (States and Transitions): a new fighter becomes
## Provisional; a dead one Gone; one at a new realm Provisional there, its offset carried (Edge Cases); a Rated one
## whose build signature or data version changed Stale; a Provisional one's base follows its stage (Formulas G).
func refresh() -> void:
	for p in _db.all("people"):
		refresh_person(p)


## [method refresh] for one person record; returns its rating record (empty for a dead person never rated).
func refresh_person(p: Dictionary) -> Dictionary:
	var id: String = str(p.id)
	if not bool(p.get("alive", true)):
		var gone: Dictionary = _db.get_record(TABLE, id)
		if not gone.is_empty():
			gone["state"] = GONE
		_compiled.erase(id)
		return gone
	var realm: int = clampi(int(p.get("realm_index", 0)), 0, 4)
	var stage: int = int(p.get("stage", 0))
	var rec: Dictionary = _ensure(id, realm, stage)
	var state: String = str(rec.state)
	if state == GONE:
		return rec
	if int(rec.realm) != realm:
		rec["state"] = PROVISIONAL
		rec["realm"] = realm
		rec["base"] = _snap(ladder.provisional(realm, stage, _gd))
	elif state == PROVISIONAL:
		rec["base"] = _snap(ladder.provisional(realm, stage, _gd))
	elif state == RATED and (str(rec.get("sig", "")) != build_sig(p) or str(rec.get("version", "")) != str(_knobs.get("data_version", ""))):
		rec["state"] = STALE
	return rec


## Runs a panel for [param c] now (the player's synchronous panel, ADR-0003 decision 5): compiles it, searches its
## realm's ladder (warm from its rating when it already has a base at this realm, else cold; [param coarse] for a
## world-generation coarse search) and sets its base, applying offset_keep once. Returns {ok, base, fights, probes} or
## {ok: false, errors}.
func run_panel(c: Character, sheet: StatSheet, game_seed: int, season: int, coarse: bool = false) -> Dictionary:
	var errors: Array = []
	var p: FighterProfile = FighterCompiler.compile(c, _gd, _db, sheet, [], errors)
	if p == null:
		return {"ok": false, "errors": errors}
	var rec: Dictionary = ensure(c)
	var r: int = clampi(c.realm_index, 0, 4)
	_prebuild(null)
	var res: Dictionary = panel(p, r, rec, game_seed, season, coarse)
	_set_base(rec, float(res.base), r, coarse, build_sig(_db.get_record("people", c.id)))
	return {"ok": true, "base": rec.base, "fights": res.fights, "probes": res.probes}


## Formulas B for a compiled fighter [param p] at realm [param r], from its record [param rec] (whose per-season seed
## counts it continues). Public for tests.
func panel(p: FighterProfile, r: int, rec: Dictionary, game_seed: int, season: int, coarse: bool) -> Dictionary:
	var warm: bool = _is_warm(rec, r, coarse)
	var start_k: int = ladder.nearest_rung(r, float(rec.base) + float(rec.offset)) if warm else 0
	if int(rec.seeds.season) != season:
		rec["seeds"] = {"season": season, "counts": {}}
	return panel_core(p, r, str(rec.id), warm, start_k, coarse, rec.seeds.counts, game_seed, season)


## The search with real fights against realm [param r]'s rungs, seeded per rule 13 / ADR-0003 decision 4
## ("rankp:<game seed>:<season>:<fighter>:<realm>:<rung>" plus the fight's index among this fighter's fights against
## that rung this season, kept in [param counts], which it advances). Touches no shared state, so a batch runs it on
## worker threads once the realm's rungs are prebuilt ([method RatingLadder.prebuild]).
func panel_core(p: FighterProfile, r: int, fid: String, warm: bool, start_k: int, coarse: bool, counts: Dictionary,
		game_seed: int, season: int) -> Dictionary:
	var step: int = int(_knobs.warm_step) if warm else int(_knobs.cold_step)
	var fights: int = int(_knobs.coarse_probe_fights) if coarse else int(_knobs.probe_fights)
	var stop: int = int(_knobs.coarse_bracket) if coarse else 1
	var probe := func(k: int, n: int) -> float:
		var rung: FighterProfile = ladder.rung_profile(r, k)
		var key := str(k)
		var base_seed: int = RngUtils.stable_hash("rankp:%d:%d:%s:%d:%d" % [game_seed, season, fid, r, k])
		var s := 0.0
		for i in n:
			var idx: int = int(counts.get(key, 0))
			counts[key] = idx + 1
			s += fight_score(p, rung, base_seed + idx, i % 2 == 0)
		return s
	return PanelSearch.search(probe, ladder.ladder(r), ladder.k_max, start_k, step, stop, fights, float(_knobs.prior_games))


## One fight's score for [param p] against [param q]: 1 a win, 0.5 a draw or the time limit, 0 a loss; [param p] is
## side A when [param as_a]. Runs the engine directly (CombatService keeps per-call errors, so it is not shared
## across threads).
func fight_score(p: FighterProfile, q: FighterProfile, fight_seed: int, as_a: bool) -> float:
	var res: FightResult = Fight.new(p if as_a else q, q if as_a else p, _k, fight_seed, Fight.Order.COIN, false).run()
	match res.win_code():
		"A":
			return 1.0 if as_a else 0.0
		"B":
			return 0.0 if as_a else 1.0
	return 0.5


## Formulas D's K for a fighter with [param n] rated fights.
func k_factor(n: int) -> float:
	return maxf(float(_knobs.K_min), float(_knobs.K_0) / (1.0 + float(n) / float(_knobs.n_half)))


## Formulas D for one rated fight that [param a] scored [param s_a] in against [param b]: both offsets move from the
## ratings and n as they stand (both read before either changes), clamped to ±offset_cap and stored to 0.1; both n
## rise by 1.
func apply_fight(a: Dictionary, b: Dictionary, s_a: float) -> void:
	var ra: float = float(a.base) + float(a.offset)
	var rb: float = float(b.base) + float(b.offset)
	var ka: float = k_factor(int(a.n))
	var kb: float = k_factor(int(b.n))
	var e_a: float = PanelSearch.expected(ra, rb)
	var cap: float = float(_knobs.offset_cap)
	a["offset"] = _snap(clampf(float(a.offset) + ka * (s_a - e_a), -cap, cap))
	b["offset"] = _snap(clampf(float(b.offset) + kb * ((1.0 - s_a) - (1.0 - e_a)), -cap, cap))
	a["n"] = int(a.n) + 1
	b["n"] = int(b.n) + 1


# --- The season batch ---------------------------------------------------------------------------------------------

## Plans season [param season_key]'s batch (rule 14), after [method refresh]: the player's panel, the Stale and
## Provisional panels (higher realm, then the player's region, then id), the Nguyên Anh and Hóa Thần round robin,
## matchmaking (rule 7, on the ratings as they stand now) and the Kết Đan slice (rule 8, dealt at the year's first
## planning). Compiles on this (the main) thread and prebuilds the rungs the panels need. [param player] may be null.
func plan_season(game_seed: int, season_key: int, year: int, season_in_year: int, player: Character,
		player_sheet: StatSheet) -> SeasonBatch:
	refresh()
	var b := SeasonBatch.new(self)
	b.game_seed = game_seed
	b.season = season_key
	b.budget = int(_knobs.season_fight_budget)
	b.panel_budget = floori(float(b.budget) * float(_knobs.panel_budget_share))
	var region: String = ""
	if player != null:
		region = str(_db.get_record("places", player.location_id).get("region_id", ""))
	# the player's panel first
	if player != null:
		var prec: Dictionary = ensure(player)
		if str(prec.state) == STALE or str(prec.state) == PROVISIONAL:
			var pp: FighterProfile = FighterCompiler.compile(player, _gd, _db, player_sheet, [], [])
			if pp != null:
				b.panels.append(_queue_panel(prec, pp, false, build_sig(_db.get_record("people", player.id)), season_key))
	var living: Array = _db.all("people").filter(func(x): return bool(x.get("alive", true)) and not bool(x.get("is_player", false)))
	var waiting: Array = living.filter(func(x):
		var st: String = str(_db.get_record(TABLE, str(x.id)).state)
		return st == STALE or st == PROVISIONAL)
	var region_of := {}
	for x in waiting:
		region_of[x.id] = str(_db.get_record("places", str(x.get("location_id", ""))).get("region_id", ""))
	waiting.sort_custom(func(x, y):
		var rx: int = int(x.realm_index)
		var ry: int = int(y.realm_index)
		if rx != ry:
			return rx > ry
		var hx: bool = region != "" and region_of[x.id] == region
		var hy: bool = region != "" and region_of[y.id] == region
		if hx != hy:
			return hx
		return id_less(str(x.id), str(y.id)))
	for x in waiting:
		var p: FighterProfile = _profile(x)
		if p != null:
			b.panels.append(_queue_panel(_db.get_record(TABLE, str(x.id)), p, false, build_sig(x), season_key))
	_prebuild(b)
	# pair fights: round robin, matchmaking, Kết Đan slice (rule 14's order)
	var fighters: Array = living.filter(func(x): return not bool(x.get("is_beast", false)) and _profile(x) != null)
	var met := {}
	var top: Array = fighters.filter(func(x): return TOP_REALMS.has(int(x.realm_index))).map(func(x): return str(x.id))
	top.sort_custom(id_less)
	for i in top.size():
		for j in range(i + 1, top.size()):
			_add_pair(b, top[i], top[j], "rr", met)
	for r in 5:
		_matchmake(b, fighters.filter(func(x): return int(x.realm_index) == r), r, met)
	_kd_slice(b, fighters, year, season_in_year, met)
	for f in b.pairs:
		b.profiles[f.a] = _compiled[f.a].profile
		b.profiles[f.b] = _compiled[f.b].profile
	return b


## Applies a run batch in rule 13's fixed order: every panel by fighter id (base, then offset_keep once), then every
## pair fight by sorted ids and index (Formulas D). A fighter dead since planning, or a panel whose fighter is no
## longer at the panel's realm, is skipped.
func apply_batch(b: SeasonBatch) -> void:
	var done: Array = b.panels.filter(func(p): return not p.result.is_empty())
	done.sort_custom(func(x, y): return id_less(x.id, y.id))
	for p in done:
		var rec: Dictionary = _db.get_record(TABLE, p.id)
		if rec.is_empty() or not _alive(p.id) or int(rec.realm) != p.realm or str(rec.state) == GONE:
			continue
		if int(rec.get("panels", 0)) != p.panels_before:
			continue   # a panel already ran for it since planning (the player's on-open panel, Edge Cases)
		rec["seeds"] = {"season": b.season, "counts": p.counts}
		_set_base(rec, float(p.result.base), p.realm, p.coarse, p.sig)
		for pr in p.result.probes:   # Edge Cases: off the ladder's end, the id is logged
			if (int(pr[0]) == ladder.k_max and float(pr[2]) >= float(pr[1])) or (int(pr[0]) == -ladder.k_max and float(pr[2]) <= 0.0):
				log_lines.append("panel of %s ran off its ladder's end (rung %d)" % [p.id, int(pr[0])])
	var fought: Array = b.pairs.filter(func(f): return f.score >= 0.0)
	fought.sort_custom(func(x, y):
		if x.a != y.a:
			return id_less(x.a, y.a)
		if x.b != y.b:
			return id_less(x.b, y.b)
		return x.index < y.index)
	for f in fought:
		if not _alive(f.a) or not _alive(f.b):
			continue
		apply_fight(_db.get_record(TABLE, f.a), _db.get_record(TABLE, f.b), f.score)


## World generation's ratings (rule 16), outside any season budget: the player's full panel, then coarse panels for
## every generated NPC of Kết Đan and above, then the NPCs at [param start_place], higher realm first then by id, until
## worldgen_fight_budget fights have run. Those NPCs start Stale; the rest stay Provisional. Seeds use season 0.
## Returns {player_fights, coarse_panels, fights}.
func worldgen(game_seed: int, player: Character, player_sheet: StatSheet, start_place: String) -> Dictionary:
	refresh()
	var out := {"player_fights": 0, "coarse_panels": 0, "fights": 0}
	if player != null:
		var done: Dictionary = run_panel(player, player_sheet, game_seed, 0)
		out.player_fights = int(done.get("fights", 0))
	var living: Array = _db.all("people").filter(func(x): return bool(x.get("alive", true)) and not bool(x.get("is_player", false)))
	var by_realm := func(x, y):
		if int(x.realm_index) != int(y.realm_index):
			return int(x.realm_index) > int(y.realm_index)
		return id_less(str(x.id), str(y.id))
	var high: Array = living.filter(func(x): return int(x.realm_index) >= KD_REALM)
	high.sort_custom(by_realm)
	var local: Array = living.filter(func(x): return int(x.realm_index) < KD_REALM and str(x.get("location_id", "")) == start_place)
	local.sort_custom(by_realm)
	var b := SeasonBatch.new(self)
	b.game_seed = game_seed
	b.season = 0
	b.budget = int(_knobs.worldgen_fight_budget)
	b.panel_budget = b.budget
	for x in high + local:
		var p: FighterProfile = _profile(x)
		if p != null:
			b.panels.append(_queue_panel(_db.get_record(TABLE, str(x.id)), p, true, build_sig(x), 0))
	_prebuild(b)
	b.run(true)
	apply_batch(b)
	out.coarse_panels = b.panels.filter(func(p): return not p.result.is_empty()).size()
	out.fights = b.panel_fights
	return out


## Rule 13's seed for the player's event fight against rated NPC [param npc_id]: a pair fight keyed on the game seed,
## the season and the sorted ids, plus its index among that pair's event fights this season (kept on the player's
## record), so no session draw is taken (ADR-0003 decision 4). The player is never in the batch's pairs, so these
## indexes never meet a batch fight's.
func event_fight_seed(player_id: String, npc_id: String, game_seed: int, season: int) -> int:
	var rec: Dictionary = _db.get_record(TABLE, player_id)
	var ev: Dictionary = rec.get("event_seeds", {})
	if int(ev.get("season", -1)) != season:
		ev = {"season": season, "counts": {}}
	var idx: int = int(ev.counts.get(npc_id, 0))
	ev.counts[npc_id] = idx + 1
	if not rec.is_empty():
		rec["event_seeds"] = ev
	var lo: String = player_id if id_less(player_id, npc_id) else npc_id
	var hi: String = npc_id if lo == player_id else player_id
	return RngUtils.stable_hash(SeasonBatch.PAIR_KEY % [game_seed, season, lo, hi, idx])


# --- Reading ratings ----------------------------------------------------------------------------------------------

## Formulas F, a world fight between person records [param a] and [param b] (rule 11): each side's rating lowered by
## its injury, the Elo chance moved by khí vận, clamped, and one draw from [param rng]. No fight runs and nothing
## stored changes. Returns {win (for a), chance, roll}.
func world_fight(a: Dictionary, b: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	var duel: Dictionary = _gd.combat().duel
	var floor_v: float = float(duel.injured_power_floor)
	var he: float = float(_knobs.health_elo)
	var ra: Dictionary = refresh_person(a)
	var rb: Dictionary = refresh_person(b)
	var roll_a: float = float(ra.base) + float(ra.offset) + he * log(maxf(float(a.get("vitality", 1.0)), floor_v)) / log(10.0)
	var roll_b: float = float(rb.base) + float(rb.offset) + he * log(maxf(float(b.get("vitality", 1.0)), floor_v)) / log(10.0)
	var kv_a: float = float(a.get("thien_phu", {}).get("khi_van", 50))
	var kv_b: float = float(b.get("thien_phu", {}).get("khi_van", 50))
	var chance: float = clampf(PanelSearch.expected(roll_a, roll_b) + (kv_a - kv_b) * float(duel.khi_van_per_point),
		float(duel.min_win_chance), float(duel.max_win_chance))
	var roll: float = rng.randf()
	return {"win": roll < chance, "chance": chance, "roll": roll}


## Rule 9: the ranking of realms [param realms]' living rated NPCs plus [param player_id] when given: Rated and Stale
## by rating (ties: more rated fights, older, id), then Provisional ones the same way. Beasts and the dead are not
## listed. Each row: {id, rating, power, state, n}.
func ranking(realms: Array, player_id: String = "") -> Array:
	var rows: Array = []
	for p in _db.all("people"):
		if not bool(p.get("alive", true)) or bool(p.get("is_beast", false)):
			continue
		if not realms.has(int(p.get("realm_index", 0))):
			continue
		if bool(p.get("is_player", false)) and str(p.id) != player_id:
			continue
		var rec: Dictionary = refresh_person(p)
		var r: float = float(rec.base) + float(rec.offset)
		rows.append({"id": str(p.id), "rating": r, "power": ladder.power_number(r), "state": str(rec.state),
			"n": int(rec.n), "age": float(p.get("age", 0.0))})
	rows.sort_custom(func(x, y):
		var px: bool = x.state == PROVISIONAL
		var py: bool = y.state == PROVISIONAL
		if px != py:
			return py
		if x.rating != y.rating:
			return x.rating > y.rating
		if x.n != y.n:
			return x.n > y.n
		if x.age != y.age:
			return x.age > y.age
		return id_less(x.id, y.id))
	return rows


## Rule 13's id order: shorter ids first, then by text (so "p9" sorts before "p10").
static func id_less(a: String, b: String) -> bool:
	if a.length() != b.length():
		return a.length() < b.length()
	return a < b


func _queue_panel(rec: Dictionary, p: FighterProfile, coarse: bool, sig: String, season_key: int) -> SeasonBatch.PanelJob:
	var q := SeasonBatch.PanelJob.new()
	var r: int = clampi(int(rec.realm), 0, 4)
	q.id = str(rec.id)
	q.realm = r
	q.profile = p
	q.coarse = coarse
	q.warm = _is_warm(rec, r, coarse)
	q.start_k = ladder.nearest_rung(r, float(rec.base) + float(rec.offset)) if q.warm else 0
	q.sig = sig
	q.panels_before = int(rec.get("panels", 0))
	q.counts = (rec.seeds.counts as Dictionary).duplicate() if int(rec.seeds.season) == season_key else {}
	var step: int = int(_knobs.warm_step) if q.warm else int(_knobs.cold_step)
	var fights: int = int(_knobs.coarse_probe_fights) if coarse else int(_knobs.probe_fights)
	var stop: int = int(_knobs.coarse_bracket) if coarse else 1
	var key := "%d:%d:%d:%d" % [q.start_k, step, stop, fights]
	if not _max_fights.has(key):
		_max_fights[key] = PanelSearch.max_fights(ladder.k_max, q.start_k, step, stop, fights)
	q.max_fights = int(_max_fights[key])
	return q


func _is_warm(rec: Dictionary, r: int, coarse: bool) -> bool:
	return not coarse and str(rec.state) != PROVISIONAL and int(rec.get("realm", -1)) == r


func _set_base(rec: Dictionary, base: float, r: int, coarse: bool, sig: String) -> void:
	var had_base: bool = str(rec.state) != PROVISIONAL
	rec["base"] = _snap(base)
	if had_base or float(rec.offset) != 0.0:
		rec["offset"] = _snap(float(rec.offset) * float(_knobs.offset_keep))
		rec["n"] = floori(float(rec.n) * float(_knobs.offset_keep))
	rec["state"] = STALE if coarse else RATED
	rec["realm"] = r
	rec["version"] = str(_knobs.get("data_version", ""))
	rec["sig"] = sig
	rec["panels"] = int(rec.get("panels", 0)) + 1


## An NPC's compiled fighter, cached while its build signature holds; null (logged) when the compiler refuses it.
func _profile(person: Dictionary) -> FighterProfile:
	var id: String = str(person.id)
	var sig: String = build_sig(person)
	var hit: Dictionary = _compiled.get(id, {})
	if not hit.is_empty() and str(hit.sig) == sig:
		return hit.profile
	var c := Character.from_dict(person)
	var errors: Array = []
	var p: FighterProfile = FighterCompiler.compile(c, _gd, _db, sheet_fn.call(c), [], errors)
	if p == null:
		log_lines.append("cannot compile %s: %s" % [id, "; ".join(errors.map(func(e): return str(e)))])
		_compiled.erase(id)
		return null
	_compiled[id] = {"sig": sig, "profile": p}
	return p


## Prebuilds every realm's rungs (once a session): a batch may run in the background while the main thread runs the
## player's own panel, and neither may then add to the rung cache.
func _prebuild(_b: SeasonBatch) -> void:
	if _prebuilt:
		return
	for r in ladder.anchors.size():
		ladder.prebuild(r)
	_prebuilt = true


func _add_pair(b: SeasonBatch, x: String, y: String, kind: String, met: Dictionary) -> void:
	var f := SeasonBatch.PairFight.new()
	f.a = x if id_less(x, y) else y
	f.b = y if f.a == x else x
	var key: String = f.a + "|" + f.b
	f.index = int(met.get(key, 0))
	met[key] = f.index + 1
	f.kind = kind
	f.seed = RngUtils.stable_hash(SeasonBatch.PAIR_KEY % [b.game_seed, b.season, f.a, f.b, f.index])
	b.pairs.append(f)


## Rule 7 and its Edge Cases for realm [param r]'s NPCs [param people].
func _matchmake(b: SeasonBatch, people: Array, r: int, met: Dictionary) -> void:
	var rounds: int = int((_knobs.match_fights as Array)[r]) if r < (_knobs.match_fights as Array).size() else 0
	if rounds <= 0 or people.size() < 2:
		return
	var order: Array = people.map(func(x): return str(x.id))
	var rating := {}
	for id in order:
		rating[id] = rating_of(id)
	order.sort_custom(func(x, y):
		if rating[x] != rating[y]:
			return rating[x] > rating[y]
		return id_less(x, y))
	var w: int = int(_knobs.match_window)
	var matched := {}   # pairs met in this season's matchmaking
	for round in rounds:
		var rng := RandomNumberGenerator.new()
		rng.seed = RngUtils.stable_hash(MATCH_KEY % [b.game_seed, b.season, r, round])
		var used := {}
		for i in order.size():
			var me: String = order[i]
			if used.has(me):
				continue
			var cands: Array = _candidates(order, i, w, used, matched)
			if cands.is_empty():
				cands = _candidates(order, i, 2 * w, used, matched)
			if cands.is_empty():
				continue
			var other: String = cands[rng.randi_range(0, cands.size() - 1)]
			used[me] = true
			used[other] = true
			var a: String = me if id_less(me, other) else other
			matched[a + "|" + (other if a == me else me)] = true
			_add_pair(b, me, other, "match", met)


func _candidates(order: Array, i: int, w: int, used: Dictionary, matched: Dictionary) -> Array:
	var me: String = order[i]
	var out: Array = []
	for j in range(maxi(0, i - w), mini(order.size(), i + w + 1)):
		var o: String = order[j]
		if j == i or used.has(o):
			continue
		var key: String = (me + "|" + o) if id_less(me, o) else (o + "|" + me)
		if matched.has(key):
			continue
		out.append(o)
	return out


## Rule 8's Kết Đan round robin: at the year's first planning its rated Kết Đan NPCs are listed and their pairs dealt
## evenly across the year's seasons (pair t to season t mod seasons); each season plays its slice in a keyed-shuffle
## order. A pair whose fighter has died or left the realm since is dropped; undealt pairs end with the year.
func _kd_slice(b: SeasonBatch, fighters: Array, year: int, season_in_year: int, met: Dictionary) -> void:
	var st: Dictionary = _db.get_record(TABLE, SEASON_RECORD)
	if st.is_empty() or int(st.get("kd_year", -1)) != year:
		var ids: Array = fighters.filter(func(x): return int(x.realm_index) == KD_REALM).map(func(x): return str(x.id))
		ids.sort_custom(id_less)
		st = {"id": SEASON_RECORD, "kd_year": year, "kd_ids": ids}
		_db.put(TABLE, st)
	var here := {}
	for x in fighters:
		if int(x.realm_index) == KD_REALM:
			here[str(x.id)] = true
	var ids2: Array = st.kd_ids
	var spy: int = int(_gd.cultivation_rules().seasons_per_year)
	var slice: Array = []
	var t := 0
	for i in ids2.size():
		for j in range(i + 1, ids2.size()):
			if t % spy == season_in_year and here.has(ids2[i]) and here.has(ids2[j]):
				slice.append([ids2[i], ids2[j]])
			t += 1
	var rng := RandomNumberGenerator.new()
	rng.seed = RngUtils.stable_hash(KD_KEY % [b.game_seed, year, season_in_year])
	for pr in RngUtils.shuffled(rng, slice):
		_add_pair(b, pr[0], pr[1], "kd", met)


func _alive(id: String) -> bool:
	return bool(_db.get_record("people", id).get("alive", false))


static func _snap(x: float) -> float:
	return snappedf(x, 0.1)
