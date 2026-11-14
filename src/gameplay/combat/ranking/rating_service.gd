class_name RatingService
extends RefCounted
## Power Rankings' ratings (design/gdd/power-rankings.md; ADR-0003): each fighter's base from a ladder panel, its
## learned offset, its state, kept in the World DB's "ratings" table under the fighter's id. This slice (ADR-0003
## Migration Plan step 3) covers provisional ratings and panels; matchmaking, round robins, the season batch and world
## fights come next. Behind combat_rankings.json "enabled" (off): callers check [method enabled].
##
## Usage:
## [codeblock]
## var rs := RatingService.new(gd, db)
## var rec: Dictionary = rs.ensure(c)                         # provisional on first sight (Formulas G)
## var done: Dictionary = rs.run_panel(c, sheet, game_seed, season)   # a full panel (Formulas B)
## var shown: int = rs.power_number(c)                        # Formulas E
## [/codeblock]

const TABLE := "ratings"

## The state names stored on a rating record (GDD States and Transitions).
const PROVISIONAL := "provisional"
const RATED := "rated"
const STALE := "stale"
const GONE := "gone"

var ladder: RatingLadder
var _gd: GameData
var _db: WorldDB
var _service: CombatService
var _knobs: Dictionary


## [param db] holds the ratings table; the ladder and knobs come from [param gd].
func _init(gd: GameData, db: WorldDB) -> void:
	_gd = gd
	_db = db
	ladder = RatingLadder.from_game_data(gd)
	_knobs = ladder.data
	_service = CombatService.new(CombatConstants.from_game_data(gd))


## The feature flag (combat_rankings.json "enabled").
func enabled() -> bool:
	return bool(_knobs.get("enabled", false))


## [param c]'s rating record, made Provisional (Formulas G) when it has none. Fields: base, offset, n, state, realm
## (of its base), version (the data version its base was measured on), seeds (the season and per-rung fight counts
## that keep panel seeds distinct within a season).
func ensure(c: Character) -> Dictionary:
	var rec: Dictionary = _db.get_record(TABLE, c.id)
	if rec.is_empty():
		var r: int = clampi(c.realm_index, 0, 4)
		rec = {"id": c.id, "base": ladder.provisional(r, c.stage, _gd), "offset": 0.0, "n": 0, "state": PROVISIONAL,
			"realm": r, "version": str(_knobs.get("data_version", "")), "seeds": {"season": -1, "counts": {}}}
		_db.put(TABLE, rec)
	return rec


## [param c]'s rating, base + offset (Core Rules rule 2).
func rating(c: Character) -> float:
	var rec: Dictionary = ensure(c)
	return float(rec.base) + float(rec.offset)


## [param c]'s shown power number (Formulas E).
func power_number(c: Character) -> int:
	return ladder.power_number(rating(c))


## Marks [param c] Stale after a build change (Core Rules rule 5); its rating stands until its panel runs.
func mark_stale(c: Character) -> void:
	var rec: Dictionary = ensure(c)
	if str(rec.state) == RATED:
		rec["state"] = STALE


## Runs a panel for [param c] now (the player's synchronous panel, ADR-0003 decision 5, and the batch's unit of work):
## compiles it, searches its realm's ladder (warm from its rating when it already has a base at this realm, else cold;
## [param coarse] for a world-generation coarse search) and sets its base, applying offset_keep once.
## Returns {ok, base, fights, probes} or {ok: false, errors}.
func run_panel(c: Character, sheet: StatSheet, game_seed: int, season: int, coarse: bool = false) -> Dictionary:
	var errors: Array = []
	var p: FighterProfile = FighterCompiler.compile(c, _gd, _db, sheet, [], errors)
	if p == null:
		return {"ok": false, "errors": errors}
	var rec: Dictionary = ensure(c)
	var r: int = clampi(c.realm_index, 0, 4)
	var res: Dictionary = panel(p, r, rec, game_seed, season, coarse)
	var had_base: bool = str(rec.state) != PROVISIONAL
	rec["base"] = float(res.base)
	if had_base or float(rec.offset) != 0.0:
		rec["offset"] = float(rec.offset) * float(_knobs.offset_keep)
		rec["n"] = floori(float(rec.n) * float(_knobs.offset_keep))
	rec["state"] = STALE if coarse else RATED
	rec["realm"] = r
	rec["version"] = str(_knobs.get("data_version", ""))
	return {"ok": true, "base": res.base, "fights": res.fights, "probes": res.probes}


## Formulas B for a compiled fighter [param p] at realm [param r]: the search with real fights against the realm's
## rungs, seeded per ADR-0003 decision 4 ("rankp:<game seed>:<season>:<fighter>:<realm>:<rung>" plus the fight's index
## among this fighter's fights against that rung this season, counted in [param rec].seeds). Public for tests.
func panel(p: FighterProfile, r: int, rec: Dictionary, game_seed: int, season: int, coarse: bool) -> Dictionary:
	var k_max: int = ladder.k_max
	var warm: bool = not coarse and str(rec.state) != PROVISIONAL and int(rec.get("realm", -1)) == r
	var start_k: int = ladder.nearest_rung(r, float(rec.base) + float(rec.offset)) if warm else 0
	var step: int = int(_knobs.warm_step) if warm else int(_knobs.cold_step)
	var fights: int = int(_knobs.coarse_probe_fights) if coarse else int(_knobs.probe_fights)
	var stop: int = int(_knobs.coarse_bracket) if coarse else 1
	if int(rec.seeds.season) != season:
		rec["seeds"] = {"season": season, "counts": {}}
	var counts: Dictionary = rec.seeds.counts
	var fid: String = str(rec.id)
	var probe := func(k: int, n: int) -> float:
		var rung: FighterProfile = ladder.rung_profile(r, k)
		var key := str(k)
		var base_seed: int = RngUtils.stable_hash("rankp:%d:%d:%s:%d:%d" % [game_seed, season, fid, r, k])
		var s := 0.0
		for i in n:
			var idx: int = int(counts.get(key, 0))
			counts[key] = idx + 1
			s += _score(p, rung, base_seed + idx, i % 2 == 0)
		return s
	return PanelSearch.search(probe, ladder.ladder(r), k_max, start_k, step, stop, fights, float(_knobs.prior_games))


## One fight's score for [param p] against [param rung]: 1 a win, 0.5 a draw or the time limit, 0 a loss; [param p] is
## side A when [param as_a] (half the fights on each side, Formulas B).
func _score(p: FighterProfile, rung: FighterProfile, fight_seed: int, as_a: bool) -> float:
	var req := FightRequest.new()
	req.a = p if as_a else rung
	req.b = rung if as_a else p
	req.fight_seed = fight_seed
	var res: FightResult = _service.resolve(req)
	match res.win_code():
		"A":
			return 1.0 if as_a else 0.0
		"B":
			return 0.0 if as_a else 1.0
	return 0.5
