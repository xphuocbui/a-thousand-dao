extends DaoTestSuite
## ADR-0003 decision 13 (worker processes, 2026-11-22): a season batch run in worker processes gives exactly the
## results of the same batch run on threads, and a worker failure falls back to threads with the same results. A small
## generated world (80 cultivators) with ratings on in this suite's own copy of the data.

const BUDGET := 240


static var _on: GameData


static func _gd_on() -> GameData:
	if _on == null:
		_on = GameData.load_from("res://assets/data")
		_on.world_gen().people.world_cultivators = 80
		_on.world_gen().people.world_cultivators_min = 0
		var k: Dictionary = _on.file("combat_rankings")
		k["enabled"] = true
		k["season_fight_budget"] = BUDGET
		k["worldgen_fight_budget"] = 120
		_on.file(RatingService.WORKERS_FILE)["rating_workers"] = 0   # the session itself on threads; the test adds a pool
	return _on


func _session(seed: int) -> GameSession:
	var llm := LlmService.new(_gd_on())
	llm.enabled = false
	var s := GameSession.new(_gd_on(), llm, TestFixtures.tree())
	s.ratings_background = false
	s.new_game(seed, {"mode": "roll", "name": "Thí Sinh", "gender": "male", "origin": "tan_tu"})
	return s


## Two identical plans of the season's batch (planning reads the same state twice), with the build files the workers
## need.
func _two_plans(s: GameSession) -> Array:
	var out: Array = []
	for i in 2:
		var b: SeasonBatch = s.ratings.plan_season(s.seed_value, s.season_index(), s.year, s.season, s.player, s.sheet())
		for p in b.panels:
			if s.ratings._compiled.has(p.id):
				b.builds[p.id] = s.ratings._compiled[p.id].build
		for f in b.pairs:
			b.builds[f.a] = s.ratings._compiled[f.a].build
			b.builds[f.b] = s.ratings._compiled[f.b].build
		out.append(b)
	return out


static func _results(b: SeasonBatch) -> Array:
	return [b.panels.map(func(p): return [p.id, p.result, p.counts]), b.pairs.map(func(f): return [f.a, f.b, f.index, f.score]),
		b.panel_fights, b.pair_fights]


func test_a_batch_in_worker_processes_matches_threads_exactly() -> void:
	var s := _session(41)
	var plans: Array = _two_plans(s)
	var threads: SeasonBatch = plans[0]
	var procs: SeasonBatch = plans[1]
	threads.run(true)
	procs.pool = RatingWorkerPool.new(_gd_on(), 4, 120.0)
	procs.run(true)
	assert_true(procs.worker_tasks > 0, "fights ran in worker processes (%d tasks)" % procs.worker_tasks)
	assert_eq(procs.fallback_tasks, 0, "no task fell back to threads")
	assert_true(threads.pair_fights + threads.panel_fights > 0, "the batch had fights to run")
	assert_eq(_results(procs), _results(threads), "every panel result, rung count and pair score identical")
	s.shutdown()


func test_a_failed_worker_falls_back_to_threads_with_the_same_results() -> void:
	var s := _session(42)
	var plans: Array = _two_plans(s)
	var threads: SeasonBatch = plans[0]
	var broken: SeasonBatch = plans[1]
	threads.run(true)
	broken.pool = RatingWorkerPool.new(_gd_on(), 4, 0.0)   # no time at all: every worker is killed
	broken.run(true)
	assert_eq(broken.worker_tasks, 0, "no worker result was used")
	assert_true(broken.fallback_tasks > 0, "every task fell back to threads (%d)" % broken.fallback_tasks)
	assert_eq(_results(broken), _results(threads), "the same results, only slower")
	s.shutdown()


func test_worker_count_follows_the_knob() -> void:
	assert_eq(RatingWorkerPool.worker_count(0, 12), 0, "0 means threads only")
	var auto: int = RatingWorkerPool.worker_count(-1, 12)
	assert_eq(auto, clampi(OS.get_processor_count() - 2, 0, 12), "-1 means the core count minus 2, capped")
	assert_true(RatingWorkerPool.worker_count(9999, 12) <= OS.get_processor_count(), "never more workers than cores")
