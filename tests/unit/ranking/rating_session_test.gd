extends DaoTestSuite
## Power Rankings in a running game (design/gdd/power-rankings.md rules 1, 7, 11, 13, 14, 16; ADR-0003 step 3): a
## small generated world (80 cultivators) with the flag on in this test's own copy of the data, and a small season
## budget so a season stays quick. The shipped combat_rankings.json stays off (rating_service_test).

const BUDGET := 240
const WORLDGEN_BUDGET := 120


static var _on: GameData


## A GameData of its own with ratings on (shared by this suite only; the fixture's copy stays off).
static func _gd_on() -> GameData:
	if _on == null:
		_on = GameData.load_from("res://assets/data")
		_on.world_gen().people.world_cultivators = 80
		_on.world_gen().people.world_cultivators_min = 0
		var k: Dictionary = _on.file("combat_rankings")
		k["enabled"] = true
		k["season_fight_budget"] = BUDGET
		k["worldgen_fight_budget"] = WORLDGEN_BUDGET
	return _on


func _session(seed: int, background: bool = false) -> GameSession:
	var gd := _gd_on()
	var llm := LlmService.new(gd)
	llm.enabled = false
	var s := GameSession.new(gd, llm, TestFixtures.tree())
	s.ratings_background = background
	s.new_game(seed, {"mode": "roll", "name": "Thí Sinh", "gender": "male", "origin": "tan_tu"})
	return s


static func _ratings(s: GameSession) -> Dictionary:
	var out := {}
	for rec in s.db.all(RatingService.TABLE):
		if str(rec.id) != RatingService.SEASON_RECORD:
			out[rec.id] = [float(rec.base), float(rec.offset), int(rec.n), str(rec.state)]
	return out


func test_world_generation_rates_the_player_and_the_load_set_ac_pr_26() -> void:
	var s := _session(31)
	var prec: Dictionary = s.db.get_record(RatingService.TABLE, s.player.id)
	assert_eq(str(prec.state), RatingService.RATED, "the player is Rated from a full panel")
	var high: Array = s.db.find("people", func(p): return p.alive and not p.get("is_player", false) and int(p.realm_index) >= 2)
	var stale := 0
	for p in s.db.all("people"):
		if not p.alive or p.get("is_player", false):
			continue
		var st: String = str(s.db.get_record(RatingService.TABLE, p.id).state)
		assert_true(st == RatingService.STALE or st == RatingService.PROVISIONAL, "%s starts Stale or Provisional" % p.id)
		if st == RatingService.STALE:
			stale += 1
	assert_true(stale > 0, "some coarse panels ran (%d)" % stale)
	if not high.is_empty():
		high.sort_custom(func(x, y): return int(x.realm_index) > int(y.realm_index) or (int(x.realm_index) == int(y.realm_index) and RatingService.id_less(x.id, y.id)))
		assert_eq(str(s.db.get_record(RatingService.TABLE, high[0].id).state), RatingService.STALE, "the strongest realm's first NPC got a coarse panel")


func test_the_batch_follows_rule_14s_order_and_never_pairs_the_player_or_beasts_ac_pr_24_13_01() -> void:
	var s := _session(32)
	s.player.stage = mini(s.player.stage + 1, 3)   # a build change: the player is Stale
	s.sync_player()
	var b: SeasonBatch = s.ratings.plan_season(s.seed_value, s.season_index(), s.year, s.season, s.player, s.sheet())
	assert_eq(b.panels[0].id, s.player.id, "the player's panel first")
	var last_realm := 99
	for i in range(1, b.panels.size()):
		assert_true(b.panels[i].realm <= last_realm, "then higher realms first")
		last_realm = b.panels[i].realm
	var kinds: Array = b.pairs.map(func(f): return f.kind)
	var rank := {"rr": 0, "match": 1, "kd": 2}
	for i in range(1, kinds.size()):
		assert_true(rank[kinds[i]] >= rank[kinds[i - 1]], "round robin, then matchmaking, then the Kết Đan slice")
	var beasts := {}
	for p in s.db.all("people"):
		if p.get("is_beast", false):
			beasts[p.id] = true
	for f in b.pairs:
		assert_true(f.a != s.player.id and f.b != s.player.id, "the player is never paired")
		assert_false(beasts.has(f.a) or beasts.has(f.b), "beasts are never paired")
	var top: int = s.db.find("people", func(p): return p.alive and not p.get("is_player", false) and not p.get("is_beast", false) and int(p.realm_index) >= 3).size()
	assert_eq(kinds.count("rr"), top * (top - 1) / 2, "every top-realm pair once (AC-PR-14)")


func test_a_season_runs_its_budget_and_applies_ac_pr_25() -> void:
	var s := _session(33)
	s.cultivate(1)
	var lb: Dictionary = s.last_rating_batch
	assert_false(lb.is_empty(), "a batch applied at the season's end")
	assert_true(int(lb.panel_fights) <= BUDGET / 2, "panels within their share")
	assert_true(int(lb.panel_fights) + int(lb.pair_fights) <= BUDGET, "within the season budget")
	var rated: int = s.db.all(RatingService.TABLE).filter(func(r): return str(r.get("state", "")) == RatingService.RATED).size()
	assert_true(rated > 1, "NPCs became Rated (%d)" % rated)
	var moved: int = s.db.all(RatingService.TABLE).filter(func(r): return int(r.get("n", 0)) > 0).size()
	assert_true(moved > 0, "pair fights moved offsets")


func test_background_and_blocking_seasons_give_identical_ratings_ac_pr_52() -> void:
	var a := _session(34, false)
	var b := _session(34, true)
	a.cultivate(2)
	b.cultivate(2)
	b._finish_ratings()
	a._finish_ratings()
	assert_eq(_ratings(a), _ratings(b), "every base, offset, n and state")
	assert_eq(a.rng.state, b.rng.state, "the session stream moved the same")


func test_ratings_and_the_seasons_pending_work_survive_a_save_ac_pr_48() -> void:
	# The pending batch is not saved: it is planned again from the saved state, so it must come out identical. (A
	# reloaded game's world tick itself drifts from an unsaved one's after a season, ratings on or off: a Save / Load
	# finding outside Power Rankings, reported 2026-11-14; once fixed this test can compare the next season too.)
	var a := _session(35)
	a.cultivate(1)
	var saved: Dictionary = JSON.parse_string(JSON.stringify(a.to_dict()))
	var llm := LlmService.new(_gd_on())
	llm.enabled = false
	var b := GameSession.new(_gd_on(), llm, TestFixtures.tree())
	b.ratings_background = false
	b.load_dict(saved)
	var ra: Dictionary = _ratings(a)
	var rb: Dictionary = _ratings(b)
	assert_eq(rb.size(), ra.size(), "every rating record")
	for id in ra:
		assert_eq(str(rb[id]), str(ra[id]), "%s: base, offset, n and state" % id)
	var pa: SeasonBatch = a._rating_batch
	var pb: SeasonBatch = b._rating_batch
	assert_eq(pb.panels.map(func(p): return [p.id, p.warm, p.start_k, p.counts.size()]),
		pa.panels.map(func(p): return [p.id, p.warm, p.start_k, p.counts.size()]), "the same panels in the same order")
	assert_eq(pb.pairs.map(func(f): return f.seed), pa.pairs.map(func(f): return f.seed), "the same pair fights and seeds")
	assert_eq(str(b.db.get_record(RatingService.TABLE, RatingService.SEASON_RECORD).kd_ids),
		str(a.db.get_record(RatingService.TABLE, RatingService.SEASON_RECORD).kd_ids), "the year's Kết Đan round robin")


func test_a_world_fight_is_formulas_f_on_the_ratings_ac_pr_19_34() -> void:
	var gd := game_data()
	var db := WorldDB.new()
	var rs := RatingService.new(gd, db)
	var a := {"id": "p1", "alive": true, "realm_index": 1, "stage": 0, "level": 0, "power": 1.0, "thien_phu": {"khi_van": 60}}
	var b := {"id": "p2", "alive": true, "realm_index": 1, "stage": 0, "level": 0, "power": 1.0, "thien_phu": {"khi_van": 50}}
	db.put("people", a)
	db.put("people", b)
	for pr in [["p1", 1450.0], ["p2", 1400.0]]:
		db.put(RatingService.TABLE, {"id": pr[0], "base": pr[1], "offset": 0.0, "n": 0, "state": RatingService.RATED, "realm": 1,
			"version": "", "sig": rs.build_sig(a), "seeds": {"season": -1, "counts": {}}})
	var rng := RandomNumberGenerator.new()
	rng.seed = 9
	var before: int = rng.state
	var r: Dictionary = rs.world_fight(a, b, rng)
	assert_near(float(r.chance), 0.581, 0.001, "0.571 + 10 khí vận x 0.001")
	var once := RandomNumberGenerator.new()
	once.seed = 9
	once.randf()
	assert_eq(rng.state, once.state, "exactly one session draw")
	assert_true(before != rng.state, "the stream moved")
	a["vitality"] = 0.9
	a.thien_phu.khi_van = 50
	var hurt: float = float(rs.world_fight(a, b, rng).chance)
	var he: float = float(rs.knob("health_elo"))
	assert_near(hurt, PanelSearch.expected(1450.0 + he * log(0.9) / log(10.0), 1400.0), 1e-9, "the injury lowers the roll rating")
	a["vitality"] = 0.05
	var floor_hit: float = float(rs.world_fight(a, b, rng).chance)
	a["vitality"] = 0.4
	assert_eq(floor_hit, float(rs.world_fight(a, b, rng).chance), "v below v_c reads v_c")
	assert_near(float(db.get_record(RatingService.TABLE, "p1").base), 1450.0, 1e-9, "the stored rating is untouched")
	assert_eq(int(db.get_record(RatingService.TABLE, "p1").n), 0, "and no offset moved")


func test_the_ranking_orders_by_rating_then_fights_then_age_then_id_provisional_last_ac_pr_16() -> void:
	var gd := game_data()
	var db := WorldDB.new()
	var rs := RatingService.new(gd, db)
	var rows := [["p7", 1500.0, 10, 50.0, RatingService.RATED], ["p9", 1500.0, 10, 80.0, RatingService.RATED],
		["p3", 1500.0, 12, 30.0, RatingService.RATED], ["p5", 1600.0, 0, 40.0, RatingService.PROVISIONAL]]
	for row in rows:
		var p := {"id": row[0], "alive": true, "realm_index": 1, "stage": 0, "level": 0, "power": 1.0, "age": row[3]}
		db.put("people", p)
		db.put(RatingService.TABLE, {"id": row[0], "base": row[1], "offset": 0.0, "n": row[2], "state": row[4], "realm": 1,
			"version": str(rs.knob("data_version")), "sig": rs.build_sig(p), "seeds": {"season": -1, "counts": {}}})
	var order: Array = rs.ranking([1]).map(func(r): return r.id)
	assert_eq(order, ["p3", "p9", "p7", "p5"], "n, then age, then id; the Provisional one last")
