extends SceneTree
## A rating worker process (ADR-0003 decision 13, 2026-11-22): a headless copy of the game, started by
## [RatingWorkerPool] for one season batch, that runs its share of each of the batch's waves and writes the results.
## It reads only files in its batch folder, in Godot's binary Variant format (never JSON: JSON's float parse is not
## exact): the batch file (the coordinator's data snapshot and every fighter's build file) once, then each wave's job
## file. It rebuilds each fighter from its build file exactly as the coordinator compiled it
## ([method FighterCompiler.from_build_file]) and runs the same [RatingService] code the threads run, so its results are
## identical to a threaded run.
##
## Started as:
##   <godot binary> --headless [--path <project>] -s res://src/gameplay/combat/ranking/rating_worker.gd -- --dir=<folder>
##       --slice=<i> --of=<n>
## Then for k = 1, 2, …: it waits for `job_<k>.bin` (or `quit`), runs tasks i, i + n, i + 2n, … of it (dealt round
## robin: a batch lists its costly top-realm fights first) and writes `out_<k>_<i>.bin`. A task is ["p", id, realm, warm,
## start_k, coarse, counts, game_seed, season] (a panel) or ["f", a, b, seed] (a pair fight); the result is
## {index: [result, counts]} for a panel and {index: score} for a pair fight. It quits on `quit`, or when no job comes for
## the batch file's idle_s (a coordinator that died).


func _init() -> void:
	quit(_run(OS.get_cmdline_user_args()))


static func _arg(args: PackedStringArray, key: String, dflt: String) -> String:
	for a in args:
		if a.begins_with(key + "="):
			return a.trim_prefix(key + "=")
	return dflt


static func _read(path: String) -> Variant:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return null
	var v: Variant = f.get_var()
	f.close()
	return v


## Writes [param v] to [param path] through a temporary file and a rename, so the reader never sees half a file.
static func _write(path: String, v: Variant) -> bool:
	var tmp: String = path + ".tmp"
	var f := FileAccess.open(tmp, FileAccess.WRITE)
	if f == null:
		return false
	f.store_var(v)
	f.close()
	return DirAccess.rename_absolute(tmp, path) == OK


## Runs the worker; returns the exit code (0 when it quit as asked).
static func _run(args: PackedStringArray) -> int:
	var dir: String = _arg(args, "--dir", "")
	var slice: int = int(_arg(args, "--slice", "0"))
	var of: int = maxi(1, int(_arg(args, "--of", "1")))
	var t0: int = Time.get_ticks_usec()
	var batch: Variant = _read(dir.path_join("batch.bin"))
	if not (batch is Dictionary):
		return 3
	var files: Variant = _read(str(batch.get("data_file", "")))
	if not (files is Dictionary):
		return 5
	var gd := GameData.new()
	gd.setup(DataRegistry.from_files(files))
	var rs := RatingService.new(gd, WorldDB.new())
	var builds: Dictionary = batch.get("builds", {})
	var idle_ms: int = int(float(batch.get("idle_s", 120.0)) * 1000.0)
	var profiles: Dictionary = {}
	var load_s: float = (Time.get_ticks_usec() - t0) / 1e6
	var k: int = 1
	var waited: int = 0
	while true:
		if FileAccess.file_exists(dir.path_join("quit")):
			return 0
		var job_path: String = dir.path_join("job_%d.bin" % k)
		if not FileAccess.file_exists(job_path):
			OS.delay_msec(2)
			waited += 2
			if waited > idle_ms:
				return 7
			continue
		waited = 0
		var job: Variant = _read(job_path)
		if not (job is Dictionary):
			return 8
		var t1: int = Time.get_ticks_usec()
		var tasks: Array = job.get("tasks", [])
		var out: Dictionary = {}
		for i in range(slice, tasks.size(), of):
			var t: Array = tasks[i]
			if str(t[0]) == "p":
				var p: FighterProfile = _profile(str(t[1]), builds, profiles, gd)
				if p == null:
					continue
				var counts: Dictionary = Dictionary(t[6]).duplicate()
				var res: Dictionary = rs.panel_core(p, int(t[2]), str(t[1]), bool(t[3]), int(t[4]), bool(t[5]), counts, int(t[7]), int(t[8]))
				out[i] = [res, counts]
			else:
				var a: FighterProfile = _profile(str(t[1]), builds, profiles, gd)
				var b: FighterProfile = _profile(str(t[2]), builds, profiles, gd)
				if a == null or b == null:
					continue
				out[i] = rs.fight_score(a, b, int(t[3]), true)
		if not _write(dir.path_join("out_%d_%d.bin" % [k, slice]), {"results": out, "load_s": load_s, "work_s": (Time.get_ticks_usec() - t1) / 1e6}):
			return 6
		load_s = 0.0
		k += 1
	return 0


static func _profile(id: String, builds: Dictionary, cache: Dictionary, gd: GameData) -> FighterProfile:
	if not cache.has(id):
		cache[id] = FighterCompiler.from_build_file(builds[id], gd) if builds.has(id) else null
	return cache[id]
