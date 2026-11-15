extends Node
## Experiment (2026-11-15, Power Rankings Open Question 9; not part of the game): rating fights spread over worker
## PROCESSES instead of threads, end to end. The coordinator generates a world (ratings off), compiles real NPCs on the
## main thread, writes their build files and a seeded fight list to a job file, starts N copies of this binary as
## workers, waits for them, reads their results and compares every one with the same fights run here in one thread
## on the original profiles (so it also tests that the build files arrive bit-exact: they travel in Godot's binary Variant
## format, since JSON's float parse is not exact). Reports the wall time with
## and without worker start-up.
##
## Run in the release export:
##   build/bench/combat_bench.console.exe --headless -- --process-probe --workers=16 --fights=3000
## A worker is the same binary with --fight-worker (started by the coordinator).

const NPCS := 300

var _report := {}


func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	if args.has("--fight-worker"):
		_worker(args)
	else:
		_coordinator(args)


static func _arg(args: PackedStringArray, key: String, dflt: String) -> String:
	for a in args:
		if a.begins_with(key + "="):
			return a.trim_prefix(key + "=")
	return dflt


func _coordinator(args: PackedStringArray) -> void:
	var workers: int = int(_arg(args, "--workers", str(OS.get_processor_count())))
	var fights: int = int(_arg(args, "--fights", "3000"))
	var gd := GameData.load_from("res://assets/data")
	gd.file("combat_rankings")["enabled"] = false
	var llm := LlmService.new(gd)
	llm.enabled = false
	var s := GameSession.new(gd, llm, MeridianTree.generate(gd))
	s.new_game(4242, {"mode": "roll", "name": "P", "gender": "male", "origin": "tan_tu"})
	s.shutdown()
	var k := CombatConstants.from_game_data(gd)
	var builds: Array = []
	var profs: Array = []
	var by_realm := {}
	for rec in s.db.all("people"):
		if profs.size() >= NPCS:
			break
		if not bool(rec.get("alive", true)):
			continue
		var c := Character.from_dict(rec)
		var sheet: StatSheet = s.builds.sheet_of(c)
		var p: FighterProfile = FighterCompiler.compile(c, gd, s.db, sheet)
		if p == null:
			continue
		builds.append(FighterCompiler.character_build_file(c, gd, s.db, sheet))
		if not by_realm.has(p.realm):
			by_realm[p.realm] = []
		by_realm[p.realm].append(profs.size())
		profs.append(p)
	var pick := RandomNumberGenerator.new()
	pick.seed = 99
	var realms: Array = by_realm.keys().filter(func(r): return by_realm[r].size() >= 2)
	var list: Array = []
	for i in fights:
		var pool: Array = by_realm[realms[pick.randi_range(0, realms.size() - 1)]]
		# a seed is a 64-bit hash: as a JSON number it would be rounded to a double, so it travels as text
		list.append([pool[pick.randi_range(0, pool.size() - 1)], pool[pick.randi_range(0, pool.size() - 1)],
			str(RngUtils.stable_hash("proc-probe:%d" % i))])
	# reference: the same fights here, one thread, on the original profiles
	var t0 := Time.get_ticks_usec()
	var ref: Array = []
	for f in list:
		ref.append(_outcome(Fight.new(profs[f[0]], profs[f[1]], k, str(f[2]).to_int(), Fight.Order.COIN, false).run()))
	_report.single_thread_s = (Time.get_ticks_usec() - t0) / 1e6
	# the job file
	var dir: String = ProjectSettings.globalize_path("user://process_probe")
	DirAccess.make_dir_recursive_absolute(dir)
	# Godot's binary Variant format, not JSON: JSON's float parse is not bit-exact (3.8798222222222227 comes back
	# 3.8798222222222223), and the fights must be the same fights
	var job_path: String = dir.path_join("job.bin")
	var jf := FileAccess.open(job_path, FileAccess.WRITE)
	jf.store_var({"builds": builds, "fights": list})
	jf.close()
	# the workers
	t0 = Time.get_ticks_usec()
	var pids: Array = []
	var outs: Array = []
	for wi in workers:
		var out_path: String = dir.path_join("out_%d.bin" % wi)
		if FileAccess.file_exists(out_path):
			DirAccess.remove_absolute(out_path)
		outs.append(out_path)
		pids.append(OS.create_process(OS.get_executable_path(), PackedStringArray(["--headless", "--", "--fight-worker",
			"--job=" + job_path, "--slice=%d" % wi, "--of=%d" % workers, "--out=" + out_path])))
	_report.workers = workers
	_report.fights = fights
	_report.pids_started = pids.filter(func(p): return int(p) > 0).size()
	var running := true
	while running:
		running = false
		for pid in pids:
			if int(pid) > 0 and OS.is_process_running(int(pid)):
				running = true
		if running:
			OS.delay_msec(20)
	_report.workers_wall_s = (Time.get_ticks_usec() - t0) / 1e6
	# compare
	var got: Array = []
	got.resize(fights)
	var fight_s: Array = []
	var load_s: Array = []
	for out_path in outs:
		var rf := FileAccess.open(out_path, FileAccess.READ)
		var d: Variant = rf.get_var() if rf != null else null
		if not (d is Dictionary):
			_report.error = "a worker wrote no result: %s" % out_path
			continue
		fight_s.append(float(d.fight_s))
		load_s.append(float(d.load_s))
		for row in d.results:
			got[int(row[0])] = row.slice(1)
	var mismatched := 0
	var missing := 0
	for i in fights:
		if got[i] == null:
			missing += 1
		elif not _same(got[i], ref[i]):
			mismatched += 1
	_report.mismatched = mismatched
	_report.missing = missing
	_report.worker_load_s_max = load_s.max() if not load_s.is_empty() else 0.0
	_report.worker_fight_s_max = fight_s.max() if not fight_s.is_empty() else 0.0
	_report.speedup_wall = _report.single_thread_s / maxf(0.001, _report.workers_wall_s)
	_report.speedup_fights_only = _report.single_thread_s / maxf(0.001, float(_report.worker_fight_s_max))
	print("Process probe: %d fights, %d workers (%d started)" % [fights, workers, int(_report.pids_started)])
	print("  one thread here: %.2f s (%.2f ms a fight)" % [_report.single_thread_s, 1000.0 * _report.single_thread_s / fights])
	print("  workers, wall from start to last exit: %.2f s (x%.2f); slowest worker's load %.2f s, its fights %.2f s (x%.2f on fights alone)" % [
		_report.workers_wall_s, _report.speedup_wall, float(_report.worker_load_s_max), float(_report.worker_fight_s_max), _report.speedup_fights_only])
	print("  results identical to one thread on the original profiles: %s (%d mismatched, %d missing)" % [
		"yes" if mismatched == 0 and missing == 0 else "NO", mismatched, missing])
	print("PROCESS_JSON " + JSON.stringify(_report))
	get_tree().quit(0 if mismatched == 0 and missing == 0 else 1)


func _worker(args: PackedStringArray) -> void:
	var t0 := Time.get_ticks_usec()
	var gd := GameData.load_from("res://assets/data")
	var k := CombatConstants.from_game_data(gd)
	var job_f := FileAccess.open(_arg(args, "--job", ""), FileAccess.READ)
	var job: Dictionary = job_f.get_var()
	job_f.close()
	var slice: int = int(_arg(args, "--slice", "0"))
	var of: int = int(_arg(args, "--of", "1"))
	var fights: Array = job.fights
	var lo: int = slice * fights.size() / of
	var hi: int = (slice + 1) * fights.size() / of
	var need := {}
	for i in range(lo, hi):
		need[int(fights[i][0])] = true
		need[int(fights[i][1])] = true
	var profs := {}
	var bfc := BuildFileCompiler.new(gd)
	var loader := FighterProfileLoader.new(k)
	for idx in need:
		var bf: Dictionary = job.builds[idx]
		profs[idx] = loader.from_sim_build(bfc.compile(bf), str(bf.get("name", "")))
	var load_s: float = (Time.get_ticks_usec() - t0) / 1e6
	t0 = Time.get_ticks_usec()
	var rows: Array = []
	for i in range(lo, hi):
		var f: Array = fights[i]
		rows.append([i] + _outcome(Fight.new(profs[int(f[0])], profs[int(f[1])], k, str(f[2]).to_int(), Fight.Order.COIN, false).run()))
	var fight_s: float = (Time.get_ticks_usec() - t0) / 1e6
	var out := FileAccess.open(_arg(args, "--out", ""), FileAccess.WRITE)
	out.store_var({"load_s": load_s, "fight_s": fight_s, "results": rows})
	out.close()
	get_tree().quit(0)


static func _outcome(r: FightResult) -> Array:
	return [r.t_ms, int(r.winner), r.timed_out, r.a_end.health, r.b_end.health, r.a_end.dealt, r.b_end.dealt]


static func _same(a: Array, b: Array) -> bool:
	if a.size() != b.size():
		return false
	for i in a.size():
		if typeof(a[i]) == TYPE_BOOL or typeof(b[i]) == TYPE_BOOL:
			if bool(a[i]) != bool(b[i]):
				return false
		elif float(a[i]) != float(b[i]):
			return false
	return true
