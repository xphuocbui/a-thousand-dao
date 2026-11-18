extends Node
## ADR-0003 verification spike (Engine Compatibility, Verification Required (1)): rating fights on WorkerThreadPool.
## Generates a world, compiles real NPC fighters on the main thread (ADR-0003 decision 2: compiling reads the World DB),
## then runs the same seeded fights twice: single-threaded, and as a WorkerThreadPool group task while the main loop
## keeps running. Passes when every result is identical field for field and no main-thread frame gap exceeds 33 ms;
## also reports throughput against the 50,000-fight world-generation target (ADR-0003 decision 12).
##
## Run in the export build (preset "Windows Combat Bench"), through the bench scene:
##   build/bench/combat_bench.console.exe --headless -- --rating-spike --fights=1000
## or in the editor binary:
##   godot --headless --path . res://tests/performance/combat/combat_bench.tscn -- --rating-spike
## Prints a table and "SPIKE_JSON {...}". Exit code 0 on a pass, 1 otherwise.

const FRAME_LIMIT_MS := 33.0
const WORLDGEN_FIGHTS := 50000
const WORLDGEN_TARGET_S := 120.0


## One fight's outcome, written by exactly one task (no two tasks share an object).
class Outcome extends RefCounted:
	var t_ms: int = -1
	var winner: int = -1
	var timed_out: bool = false
	var a_health: float = 0.0
	var b_health: float = 0.0
	var a_dealt: float = 0.0
	var b_dealt: float = 0.0

	func same_as(o: Outcome) -> bool:
		return t_ms == o.t_ms and winner == o.winner and timed_out == o.timed_out and a_health == o.a_health \
			and b_health == o.b_health and a_dealt == o.a_dealt and b_dealt == o.b_dealt


var _k: CombatConstants
## Fight i is fighter _ai[i] against fighter _bi[i]; _sets[0] holds the shared compiled profiles, and with --private
## each chunk c has its own copies in _sets[c + 1] (to tell shared-object contention from engine-wide locks).
var _ai: PackedInt32Array = []
var _bi: PackedInt32Array = []
var _sets: Array = []
var _private := false
## With --private-k each chunk also has its own deep copy of the combat constants (to tell contention on the shared
## constants dictionaries from engine-wide locks).
var _ks: Array = []
var _pending := false
var _seeds: PackedInt64Array = []
var _mt: Array = []
var _single: Array = []
var _group := -1
var _mt_start := 0
var _last_frame := 0
var _gaps: PackedFloat64Array = []
var _report := {}
## One task per worker, each running a contiguous slice of fights (--chunked), against one task per fight.
var _chunks := 0


func _ready() -> void:
	var fights := 1000
	var npcs := 300
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--fights="):
			fights = int(arg.trim_prefix("--fights="))
		elif arg.begins_with("--npcs="):
			npcs = int(arg.trim_prefix("--npcs="))
		elif arg == "--chunked":
			_chunks = OS.get_processor_count()
		elif arg == "--private":
			_chunks = OS.get_processor_count()
			_private = true
		elif arg == "--private-k":
			_chunks = OS.get_processor_count()
			_private = true
			_ks = [null]
	var t0 := Time.get_ticks_usec()
	var gd := GameData.load_from("res://assets/data")
	# Power Rankings is on in the shipped data: off here, or the session's background season batch would share the
	# CPU with the measured fights (and hold the process open at exit).
	gd.file("combat_rankings")["enabled"] = false
	var llm := LlmService.new(gd)
	llm.enabled = false
	var s := GameSession.new(gd, llm, DaoDoTree.generate(gd))
	s.new_game(4242, {"mode": "roll", "name": "Spike", "gender": "male", "origin": "tan_tu"})
	s.shutdown()
	_report.worldgen_ms = (Time.get_ticks_usec() - t0) / 1000.0
	_k = CombatConstants.from_game_data(gd)
	if not _ks.is_empty():
		_ks = []
		for chunk in _chunks:
			_ks.append(CombatConstants.from_dict(gd.file("combat_engine").duplicate(true)))
	# compile on the main thread, grouped by realm (fights are same-realm, as matchmaking and panels are)
	var by_realm := {}
	var chars: Array = []
	var shared: Array = []
	t0 = Time.get_ticks_usec()
	var compiled := 0
	for rec in s.db.all("people"):
		if compiled >= npcs:
			break
		if not bool(rec.get("alive", true)):
			continue
		var c := Character.from_dict(rec)
		var p: FighterProfile = FighterCompiler.compile(c, gd, s.db, s.builds.sheet_of(c))
		if p == null:
			continue
		if not by_realm.has(p.realm):
			by_realm[p.realm] = []
		by_realm[p.realm].append(shared.size())
		shared.append(p)
		chars.append(c)
		compiled += 1
	_report.compile_ms_each = (Time.get_ticks_usec() - t0) / 1000.0 / maxf(1.0, compiled)
	_sets.append(shared)
	if _private:
		for chunk in _chunks:
			_sets.append(chars.map(func(c): return FighterCompiler.compile(c, gd, s.db, s.builds.sheet_of(c))))
	var pick := RandomNumberGenerator.new()
	pick.seed = RngUtils.stable_hash("rating-spike")
	var realms: Array = by_realm.keys().filter(func(r): return by_realm[r].size() >= 2)
	for i in fights:
		var pool: Array = by_realm[realms[pick.randi_range(0, realms.size() - 1)]]
		_ai.append(pool[pick.randi_range(0, pool.size() - 1)])
		_bi.append(pool[pick.randi_range(0, pool.size() - 1)])
		_seeds.append(int(RngUtils.stable_hash("rank:spike:%d" % i)))
		_single.append(Outcome.new())
		_mt.append(Outcome.new())
	_report.fights = fights
	_report.fighters = compiled
	_report.cores = OS.get_processor_count()
	# single-threaded reference
	t0 = Time.get_ticks_usec()
	for i in fights:
		_fight(i, _single, _sets[0])
	_report.single_ms = (Time.get_ticks_usec() - t0) / 1000.0
	_report.chunks = _chunks
	_report.private_profiles = _private
	_pending = true   # the threaded run starts on the first idle frame, so _ready's own time is not a frame gap


func _process(_delta: float) -> void:
	if _pending:
		_pending = false
		# threaded: the main loop keeps running while the group task works
		_mt_start = Time.get_ticks_usec()
		_last_frame = _mt_start
		if _chunks > 0:
			_group = WorkerThreadPool.add_group_task(_chunk_task, _chunks, -1, false, "rating spike")
		else:
			_group = WorkerThreadPool.add_group_task(_task, _seeds.size(), -1, false, "rating spike")
		return
	if _group < 0:
		return
	var now := Time.get_ticks_usec()
	_gaps.append((now - _last_frame) / 1000.0)
	_last_frame = now
	if not WorkerThreadPool.is_group_task_completed(_group):
		return
	WorkerThreadPool.wait_for_group_task_completion(_group)
	_group = -1
	_finish((now - _mt_start) / 1000.0)


func _task(i: int) -> void:
	_fight(i, _mt, _sets[0])


func _chunk_task(c: int) -> void:
	var n: int = _seeds.size()
	var profiles: Array = _sets[c + 1] if _private else _sets[0]
	var kk: CombatConstants = _ks[c] if not _ks.is_empty() else _k
	for i in range(c * n / _chunks, (c + 1) * n / _chunks):
		_fight(i, _mt, profiles, kk)


func _fight(i: int, into: Array, profiles: Array, kk: CombatConstants = null) -> void:
	var r: FightResult = Fight.new(profiles[_ai[i]], profiles[_bi[i]], kk if kk != null else _k, _seeds[i], Fight.Order.COIN, false).run()
	var o: Outcome = into[i]
	o.t_ms = r.t_ms
	o.winner = int(r.winner)
	o.timed_out = r.timed_out
	o.a_health = r.a_end.health
	o.b_health = r.b_end.health
	o.a_dealt = r.a_end.dealt
	o.b_dealt = r.b_end.dealt


func _finish(mt_ms: float) -> void:
	var mismatched := 0
	for i in _single.size():
		if not (_single[i] as Outcome).same_as(_mt[i]):
			mismatched += 1
	var order: Array = range(_gaps.size())
	order.sort_custom(func(x, y): return _gaps[x] > _gaps[y])
	_report.largest_gaps = order.slice(0, 5).map(func(i): return "frame %d: %.1f ms" % [i, _gaps[i]])
	var gaps: Array = Array(_gaps)
	gaps.sort()
	var max_gap: float = gaps[-1] if not gaps.is_empty() else 0.0
	var p99: float = gaps[int(0.99 * (gaps.size() - 1))] if not gaps.is_empty() else 0.0
	_report.threaded_ms = mt_ms
	_report.mismatched = mismatched
	_report.frames = gaps.size()
	_report.frame_gap_max_ms = max_gap
	_report.frame_gap_p99_ms = p99
	_report.ms_per_fight_single = _report.single_ms / float(_report.fights)
	_report.speedup = _report.single_ms / maxf(0.001, mt_ms)
	_report.worldgen_fights_s = WORLDGEN_FIGHTS * mt_ms / float(_report.fights) / 1000.0
	_report.ok = mismatched == 0 and max_gap <= FRAME_LIMIT_MS
	print("Rating spike (ADR-0003): %d fights, %d compiled fighters, %d cores" % [_report.fights, _report.fighters, _report.cores])
	print("  world generation %.0f ms; compile %.2f ms a fighter" % [_report.worldgen_ms, _report.compile_ms_each])
	print("  single-threaded %.0f ms (%.2f ms a fight); WorkerThreadPool %.0f ms (x%.2f)" % [_report.single_ms, _report.ms_per_fight_single, mt_ms, _report.speedup])
	print("  results identical: %s (%d mismatched)" % ["yes" if mismatched == 0 else "NO", mismatched])
	print("  main-thread frame gaps during the threaded run: %d frames, p99 %.2f ms, max %.2f ms (limit %.0f)" % [gaps.size(), p99, max_gap, FRAME_LIMIT_MS])
	print("  largest gaps: %s" % ", ".join(_report.largest_gaps))
	print("  50,000 world-generation fights at this rate: %.0f s (target %.0f s on 8 workers)" % [_report.worldgen_fights_s, WORLDGEN_TARGET_S])
	print("SPIKE_JSON " + JSON.stringify(_report))
	get_tree().quit(0 if _report.ok else 1)
