extends DaoTestSuite
## The season batch (design/gdd/power-rankings.md Core Rules rules 7, 8, 13, 14; Formulas D; ADR-0003 step 3):
## Formulas D's arithmetic, matchmaking's pairing, the round robins' pair sets, the budget, rule 13's ordered apply
## and determinism across worker threads. Pairing tests use plain people and rating records (no fights); budget and
## determinism tests fight the realm's own ladder rungs, which compile from the reference data alone.


func _rs(db: WorldDB = null) -> RatingService:
	return RatingService.new(game_data(), db if db != null else WorldDB.new())


static func _rec(id: String, base: float, offset: float, n: int, state: String = RatingService.RATED, realm: int = 1) -> Dictionary:
	return {"id": id, "base": base, "offset": offset, "n": n, "state": state, "realm": realm, "version": "", "sig": "",
		"seeds": {"season": -1, "counts": {}}}


## [param count] living NPC people of realm [param realm], ids p<start>.., each with a rating record, rating falling
## with the id (so the rating order is the id order).
static func _people(db: WorldDB, count: int, realm: int, start: int = 1) -> Array:
	var out: Array = []
	for i in count:
		var id := "p%d" % (start + i)
		var p := {"id": id, "alive": true, "realm_index": realm, "stage": 0, "level": 0, "power": 1.0}
		db.put("people", p)
		db.put(RatingService.TABLE, _rec(id, 5000.0 - 10.0 * i, 0.0, 0, RatingService.RATED, realm))
		out.append(p)
	return out


func _batch(rs: RatingService, seed: int = 7, season: int = 1201) -> SeasonBatch:
	var b := SeasonBatch.new(rs)
	b.game_seed = seed
	b.season = season
	return b


# --- Formulas D -------------------------------------------------------------------------------------------------

func test_k_halves_at_n_half_and_floors_at_k_min_ac_pr_32() -> void:
	var rs := _rs()
	assert_eq([rs.k_factor(0), rs.k_factor(10), rs.k_factor(20), rs.k_factor(40)], [48.0, 24.0, 16.0, 16.0], "K 48 / 24 / 16 / 16")


func test_the_formulas_d_example_ac_pr_31() -> void:
	var rs := _rs()
	var a := _rec("a", 1450.0, 0.0, 4)
	var b := _rec("b", 1400.0, 0.0, 14)
	rs.apply_fight(a, b, 0.0)
	assert_near(float(a.offset), -19.6, 0.05, "a loses 19.6 (K 34.3, E 0.571)")
	assert_near(float(b.offset), 11.4, 0.05, "b gains 11.4 (K 20)")
	assert_eq([int(a.n), int(b.n)], [5, 15], "both n rise by 1")


func test_the_offset_is_capped_ac_pr_09() -> void:
	var rs := _rs()
	var a := _rec("a", 1000.0, 195.0, 0)
	var b := _rec("b", 1195.0, 0.0, 0)    # equal ratings: E 0.5
	rs.apply_fight(a, b, 1.0)
	assert_near(float(a.offset), 200.0, 0.05, "+195 + 24 clamps to +200")
	var c := _rec("c", 1000.0, -195.0, 0)
	var d := _rec("d", 805.0, 0.0, 0)
	rs.apply_fight(c, d, 0.0)
	assert_near(float(c.offset), -200.0, 0.05, "the mirror clamps to -200")


func test_farming_a_much_weaker_fighter_moves_almost_nothing_ac_pr_47() -> void:
	var rs := _rs()
	var a := _rec("a", 1800.0, 0.0, 0)
	var b := _rec("b", 1000.0, 0.0, 0)
	rs.apply_fight(a, b, 1.0)
	assert_near(float(a.offset), 0.5, 0.05, "+0.5 at E 0.990")
	for i in 1000:
		b["offset"] = 0.0
		rs.apply_fight(a, b, 1.0)
	assert_true(float(a.offset) <= 200.0, "never above +200")


# --- Rule 13: seeds and order -------------------------------------------------------------------------------------

func test_a_pair_seed_does_not_depend_on_side_order_and_each_meeting_has_its_own_ac_pr_23() -> void:
	var rs := _rs()
	var b1 := _batch(rs)
	var b2 := _batch(rs)
	rs._add_pair(b1, "p12", "p3", "match", {})
	rs._add_pair(b2, "p3", "p12", "match", {})
	assert_eq([b1.pairs[0].a, b1.pairs[0].b], ["p3", "p12"], "ids sorted (p3 before p12)")
	assert_eq(b1.pairs[0].seed, b2.pairs[0].seed, "same seed either way round")
	var met := {}
	var b3 := _batch(rs)
	rs._add_pair(b3, "p3", "p12", "kd", met)
	rs._add_pair(b3, "p12", "p3", "match", met)
	assert_eq([b3.pairs[0].index, b3.pairs[1].index], [0, 1], "a second meeting in the season is fight index 1")
	assert_true(b3.pairs[0].seed != b3.pairs[1].seed, "and has its own seed")


func test_a_panel_applies_before_that_seasons_fights_ac_pr_53() -> void:
	var db := WorldDB.new()
	var rs := _rs(db)
	_people(db, 2, 1)
	db.get_record(RatingService.TABLE, "p1").merge({"state": RatingService.STALE, "offset": 40.0, "n": 15}, true)
	var b := _batch(rs)
	var pj := SeasonBatch.PanelJob.new()
	pj.id = "p1"
	pj.realm = 1
	pj.result = {"base": 5000.0, "probes": [[0, 4, 2.0]], "fights": 4}
	b.panels.append(pj)
	rs._add_pair(b, "p1", "p2", "match", {})
	b.pairs[0].score = 1.0
	rs.apply_batch(b)
	var a: Dictionary = db.get_record(RatingService.TABLE, "p1")
	# panel first: offset 20, n 7; then the win against p2 (4990, n 0) reads them: K(7) = 48 / 1.7
	var e: float = PanelSearch.expected(5020.0, 4990.0)
	assert_near(float(a.offset), snappedf(20.0 + 48.0 / 1.7 * (1.0 - e), 0.1), 1e-6, "the halved offset, then the fight with K(7)")
	assert_eq(int(a.n), 8, "n halved to 7, then +1")
	assert_eq(str(a.state), RatingService.RATED, "rated")


func test_a_fighter_who_died_since_planning_is_skipped_ac_pr_43() -> void:
	var db := WorldDB.new()
	var rs := _rs(db)
	_people(db, 3, 1)
	var b := _batch(rs)
	rs._add_pair(b, "p1", "p2", "match", {})
	rs._add_pair(b, "p1", "p3", "match", {})
	b.pairs[0].score = 1.0
	b.pairs[1].score = 1.0
	db.get_record("people", "p3")["alive"] = false
	rs.apply_batch(b)
	assert_eq(int(db.get_record(RatingService.TABLE, "p1").n), 1, "only the fight with the living p2 applied")
	assert_eq(int(db.get_record(RatingService.TABLE, "p3").n), 0, "the dead fighter's pending fight dropped")
	rs.refresh()
	assert_eq(str(db.get_record(RatingService.TABLE, "p3").state), RatingService.GONE, "Gone, its rating kept")


# --- Rule 7: matchmaking ------------------------------------------------------------------------------------------

func test_matchmaking_pairs_each_npc_at_most_once_a_round_within_the_window_ac_pr_11_12() -> void:
	var db := WorldDB.new()
	var rs := _rs(db)
	var people: Array = _people(db, 25, 1)
	var b := _batch(rs)
	rs._matchmake(b, people, 1, {})
	var count := {}
	for f in b.pairs:
		count[f.a] = int(count.get(f.a, 0)) + 1
		count[f.b] = int(count.get(f.b, 0)) + 1
		var gap: int = absi(int(f.a.substr(1)) - int(f.b.substr(1)))   # rating order is id order here
		assert_true(gap <= 10, "%s-%s within the widened window" % [f.a, f.b])
		assert_eq(f.kind, "match", "matchmaking")
	for id in count:
		assert_true(int(count[id]) <= 2, "%s fights at most match_fights[1] = 2" % id)
	assert_true(b.pairs.size() >= 20, "nearly everyone pairs both rounds (%d pairs)" % b.pairs.size())
	var narrow: int = b.pairs.filter(func(f): return absi(int(f.a.substr(1)) - int(f.b.substr(1))) <= 5).size()
	assert_true(narrow >= b.pairs.size() - 4, "almost all inside 5 places")


func test_matchmaking_is_keyed_on_seed_season_and_realm() -> void:
	var db := WorldDB.new()
	var rs := _rs(db)
	var people: Array = _people(db, 25, 1)
	var pairs_of := func(seed: int, season: int) -> Array:
		var b := _batch(rs, seed, season)
		rs._matchmake(b, people, 1, {})
		return b.pairs.map(func(f): return f.a + "|" + f.b)
	assert_eq(pairs_of.call(7, 1201), pairs_of.call(7, 1201), "same seed and season, same pairs")
	assert_true(pairs_of.call(7, 1201) != pairs_of.call(7, 1202), "another season draws again")


func test_an_odd_or_crowded_realm_widens_once_then_sits_out_with_no_repeat_ac_pr_36() -> void:
	var db := WorldDB.new()
	var rs := _rs(db)
	var people: Array = _people(db, 3, 0)   # Luyện Khí: 1 round
	var b := _batch(rs)
	rs._matchmake(b, people, 0, {})
	assert_eq(b.pairs.size(), 1, "3 NPCs, 1 round: one pair, one sits out")
	# forced: 2 rounds (Trúc Cơ) over 2 NPCs; the second round would repeat the pair, so both sit out
	var db2 := WorldDB.new()
	var rs2 := _rs(db2)
	var two: Array = _people(db2, 2, 1)
	var b2 := _batch(rs2)
	rs2._matchmake(b2, two, 1, {})
	assert_eq(b2.pairs.size(), 1, "no pair repeats in a season")
	# widening: 12 NPCs where the walker's 5-place window is used up, so it reaches into 6-10
	var db3 := WorldDB.new()
	var rs3 := _rs(db3)
	var twelve: Array = _people(db3, 12, 0)
	var used := {}
	var order: Array = twelve.map(func(x): return str(x.id))
	for i in range(1, 6):
		used[order[i]] = true
	assert_true(rs3._candidates(order, 0, 5, used, {}).is_empty(), "nobody free within 5")
	assert_eq(rs3._candidates(order, 0, 10, used, {}), order.slice(6, 11), "places 6-10 within the widened window")


func test_a_realm_with_one_npc_has_no_matchmaking_ac_pr_42() -> void:
	var db := WorldDB.new()
	var rs := _rs(db)
	var b := _batch(rs)
	rs._matchmake(b, _people(db, 1, 1), 1, {})
	assert_eq(b.pairs.size(), 0, "no pairs")


# --- Rule 8: round robins -----------------------------------------------------------------------------------------

func test_the_kd_round_robin_deals_every_pair_once_across_the_year_ac_pr_15() -> void:
	var db := WorldDB.new()
	var rs := _rs(db)
	var kd: Array = _people(db, 200, 2)
	var seen := {}
	for s in 4:
		var b := _batch(rs, 7, 1200 + s)
		rs._kd_slice(b, kd, 300, s, {})
		assert_eq(b.pairs.size(), 4975, "season %d: 4,975 pairs" % s)
		for f in b.pairs:
			var key: String = f.a + "|" + f.b
			assert_false(seen.has(key), "each pair once")
			seen[key] = true
	assert_eq(seen.size(), 19900, "19,900 pairs in the year")


func test_a_truncated_kd_slice_is_a_keyed_shuffle_not_id_order_ac_pr_15() -> void:
	var db := WorldDB.new()
	var rs := _rs(db)
	var kd: Array = _people(db, 200, 2)
	var b1 := _batch(rs, 11, 1200)
	var b2 := _batch(rs, 11, 1200)
	rs._kd_slice(b1, kd, 300, 0, {})
	db.remove(RatingService.TABLE, RatingService.SEASON_RECORD)
	rs._kd_slice(b2, kd, 300, 0, {})
	assert_eq(b1.pairs.map(func(f): return f.seed), b2.pairs.map(func(f): return f.seed), "identical for the same seed")
	for seed in 20:
		db.remove(RatingService.TABLE, RatingService.SEASON_RECORD)
		var b := _batch(rs, 100 + seed, 1200)
		rs._kd_slice(b, kd, 300, 0, {})
		var kept: Array = b.pairs.slice(0, int(b.pairs.size() * 0.35))
		var total := {}
		var played := {}
		for f in b.pairs:   # a pair counts for each band it touches
			for band in _bands(f):
				total[band] = int(total.get(band, 0)) + 1
		for f in kept:
			for band in _bands(f):
				played[band] = int(played.get(band, 0)) + 1
		for band in total:
			var share: float = float(played.get(band, 0)) / float(total[band])
			assert_true(share >= 0.25 and share <= 0.45, "seed %d band %d plays %.2f of its pairs" % [seed, band, share])


static func _bands(f: SeasonBatch.PairFight) -> Array:
	var x: int = (int(f.a.substr(1)) - 1) / 20
	var y: int = (int(f.b.substr(1)) - 1) / 20
	return [x] if x == y else [x, y]


func test_a_kd_fighter_gone_from_the_realm_drops_its_pairs() -> void:
	var db := WorldDB.new()
	var rs := _rs(db)
	var kd: Array = _people(db, 10, 2)
	var b := _batch(rs, 7, 1200)
	rs._kd_slice(b, kd, 300, 0, {})
	var b2 := _batch(rs, 7, 1201)
	rs._kd_slice(b2, kd.slice(1), 300, 1, {})   # p1 broke through after the year was dealt
	assert_true(b2.pairs.all(func(f): return f.a != "p1" and f.b != "p1"), "p1's pairs drop")
	assert_true(b2.pairs.size() > 0, "the rest still play")


# --- Rule 14: the budget ------------------------------------------------------------------------------------------

## A batch fighting realm 0's own rungs: [param panels] panels of rungs 0, 3, 6.. and [param pairs] pair fights
## between rungs -2..2.
func _rung_batch(rs: RatingService, panels: int, pairs: int) -> SeasonBatch:
	var b := _batch(rs)
	rs.ladder.prebuild(0)
	for i in panels:
		var pj := SeasonBatch.PanelJob.new()
		pj.id = "p%d" % (i + 1)
		pj.realm = 0
		pj.profile = rs.ladder.rung_profile(0, 3 * i)
		pj.max_fights = PanelSearch.max_fights(rs.ladder.k_max, 0, int(rs.knob("cold_step")), 1, int(rs.knob("probe_fights")))
		b.panels.append(pj)
	var met := {}
	for i in pairs:
		var x := "p%d" % (100 + i % 5)
		var y := "p%d" % (200 + i % 7)
		rs._add_pair(b, x, y, "match", met)
		b.profiles[x] = rs.ladder.rung_profile(0, i % 5 - 2)
		b.profiles[y] = rs.ladder.rung_profile(0, i % 7 - 3)
	return b


func test_a_season_runs_exactly_its_budget_with_panels_inside_their_share_ac_pr_25() -> void:
	var rs := _rs()
	var b := _rung_batch(rs, 6, 300)
	b.budget = 200
	b.panel_budget = 100
	b.run(false)
	assert_true(b.panel_fights <= 100, "panels within their share (%d)" % b.panel_fights)
	assert_true(b.panel_fights > 0, "some panels ran")
	assert_eq(b.panel_fights + b.pair_fights, 200, "exactly 200 fights")
	var waiting: int = b.panels.filter(func(p): return p.result.is_empty()).size()
	assert_true(waiting > 0, "panels beyond the share wait (carry to next season)")
	assert_eq(b.pairs.filter(func(f): return f.score < 0.0).size(), 300 - b.pair_fights, "unplayed pairs drop")


func test_share_left_by_panels_goes_to_pair_fights_ac_pr_25() -> void:
	var rs := _rs()
	var b := _rung_batch(rs, 1, 300)
	b.budget = 200
	b.panel_budget = 100
	b.run(false)
	assert_true(b.panel_fights <= 40, "one panel")
	assert_eq(b.pair_fights, 200 - b.panel_fights, "the rest are pair fights")


func test_the_worst_case_bound_holds_for_scripted_fighters() -> void:
	# PanelSearch.max_fights against every threshold and some irregular fighters on the test ladder
	var lad := PackedFloat64Array()
	for k in range(-32, 33):
		lad.append(5400.0 + 240.0 * k)
	var bound: int = PanelSearch.max_fights(32, 0, 8, 1, 4)
	var rng := RandomNumberGenerator.new()
	rng.seed = 5
	for t in 200:
		var outs: Array = []
		for k in 65:
			outs.append(rng.randi_range(0, 4))
		var r: Dictionary = PanelSearch.search(func(k, n): return float(outs[k + 32]), lad, 32, 0, 8, 1, 4, 1.0)
		assert_true(int(r.fights) <= bound, "irregular fighter %d: %d fights within %d" % [t, int(r.fights), bound])
	assert_eq(PanelSearch.max_fights(32, 0, 8, 4, 2), 2 * 5, "coarse cold: at most 5 probes (0, 8, 24, then 2 bisections)")


# --- AC-PR-52: determinism across threads -------------------------------------------------------------------------

func test_a_batch_is_identical_inline_and_on_worker_threads_ac_pr_52() -> void:
	var rs := _rs()
	var one := _rung_batch(rs, 3, 40)
	var many := _rung_batch(rs, 3, 40)
	one.budget = 1000
	one.panel_budget = 500
	many.budget = 1000
	many.panel_budget = 500
	one.run(false)
	many.run(true)
	for i in 3:
		assert_eq(one.panels[i].result.base, many.panels[i].result.base, "panel %d base" % i)
		assert_eq(one.panels[i].counts, many.panels[i].counts, "panel %d seed counts" % i)
	assert_eq(one.pairs.map(func(f): return f.score), many.pairs.map(func(f): return f.score), "every pair score")
	var bg := _rung_batch(rs, 3, 40)
	bg.budget = 1000
	bg.panel_budget = 500
	bg.start()
	bg.finish()
	assert_eq(bg.pairs.map(func(f): return f.score), one.pairs.map(func(f): return f.score), "and on a background thread")
