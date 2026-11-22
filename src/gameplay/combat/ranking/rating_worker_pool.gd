class_name RatingWorkerPool
extends RefCounted
## Runs a season batch's rating fights in worker processes (ADR-0003 decision 13, 2026-11-22). [method begin] starts N
## copies of the game's own binary running `rating_worker.gd` for the batch and hands them the data snapshot and every
## fighter's build file once; [method run] hands each wave to them (dealt round robin) and returns each task's result;
## [method end] stops them. Work travels in Godot's binary Variant format through files under `user://rating_workers/`.
## A task whose worker failed or ran past [member timeout_s] comes back null, and the caller runs it on threads, so a
## failure only costs time; after a failure the rest of the batch runs on threads.
##
## Usage:
## [codeblock]
## var pool := RatingWorkerPool.new(gd, 8, 120.0)
## if pool.begin(builds):
##     var results: Array = pool.run(tasks)   # one entry per task: the result, or null
##     pool.end()
## [/codeblock]

const WORKER_SCRIPT := "res://src/gameplay/combat/ranking/rating_worker.gd"
const ROOT := "user://rating_workers"
## Seconds after which a left-behind pool folder is swept.
const STALE_S := 3600

## Worker processes per batch.
var workers: int = 0
## Seconds one wave may take before the pool gives up on its workers.
var timeout_s: float = 120.0
## Set by the last [method run]: how many tasks came back from the workers, and how many did not.
var last_done: int = 0
var last_failed: int = 0
## Per wave, for measurements: [{tasks, workers, wall_s, load_s_max, work_s_max}].
var wave_stats: Array = []

## One batch at a time uses worker processes (one season late, two batches can be in flight; two sets of workers on
## the same cores would only slow each other): held from [method begin] to [method end].
static var _gate := Mutex.new()

var _gd: GameData
var _root: String = ""
var _data_file: String = ""
var _holds_gate := false
var _batch_dir: String = ""
var _batches: int = 0
var _pids: Array = []
var _wave: int = 0
var _broken := false


func _init(gd: GameData, workers_v: int, timeout_v: float, shared_from: RatingWorkerPool = null) -> void:
	_gd = gd
	workers = workers_v
	timeout_s = timeout_v
	if shared_from != null and shared_from._prepare():
		_root = shared_from._root
		_data_file = shared_from._data_file


## A pool for one more batch with the same settings, sharing this pool's data snapshot.
func for_batch() -> RatingWorkerPool:
	return RatingWorkerPool.new(_gd, workers, timeout_s, self)


## The worker count for [param knob] (combat_rating_workers.json "rating_workers"): a negative knob means the core count
## minus 2, capped at [param cap]; 0 means threads only. Never more workers than cores.
static func worker_count(knob: int, cap: int) -> int:
	var cores: int = OS.get_processor_count()
	if knob == 0:
		return 0
	if knob < 0:
		return clampi(cores - 2, 0, cap)
	return clampi(knob, 0, cores)


## True where this build can start worker processes (desktop; consoles and mobile do not allow child processes).
static func supported() -> bool:
	return OS.has_feature("pc") and not OS.has_feature("web")


## Starts the batch's workers with the fighters' [param builds] (id -> build file). Returns false when they could not be
## started (the caller then runs on threads).
func begin(builds: Dictionary) -> bool:
	_gate.lock()
	_holds_gate = true
	_broken = false
	_wave = 0
	if not _prepare():
		_broken = true
		_release()
		return false
	_batches += 1
	_batch_dir = _root.path_join("batch_%d_%d" % [get_instance_id(), _batches])
	if DirAccess.make_dir_recursive_absolute(_batch_dir) != OK:
		_broken = true
		_release()
		return false
	var f := FileAccess.open(_batch_dir.path_join("batch.bin"), FileAccess.WRITE)
	if f == null:
		_broken = true
		_release()
		return false
	f.store_var({"data_file": _data_file, "builds": builds, "idle_s": timeout_s})
	f.close()
	var exe: String = OS.get_executable_path()
	_pids = []
	for wi in workers:
		var argv := PackedStringArray(["--headless"])
		if not OS.has_feature("template"):
			argv.append_array(["--path", ProjectSettings.globalize_path("res://")])
		argv.append_array(["-s", WORKER_SCRIPT, "--", "--dir=" + _batch_dir, "--slice=%d" % wi, "--of=%d" % workers])
		_pids.append(OS.create_process(exe, argv))
	if _pids.any(func(p): return int(p) <= 0):
		end()
		_broken = true
		return false
	return true


## Runs [param tasks] (see rating_worker.gd) on the started workers. Returns one entry per task: its result, or null
## where its worker failed (all null once the pool is broken).
func run(tasks: Array) -> Array:
	var results: Array = []
	results.resize(tasks.size())
	last_done = 0
	last_failed = tasks.size()
	if tasks.is_empty() or _broken or _pids.is_empty():
		return results
	_wave += 1
	var t0: int = Time.get_ticks_msec()
	var job_path: String = _batch_dir.path_join("job_%d.bin" % _wave)
	var tmp: String = job_path + ".tmp"
	var jf := FileAccess.open(tmp, FileAccess.WRITE)
	if jf == null:
		_broken = true
		return results
	jf.store_var({"tasks": tasks})
	jf.close()
	DirAccess.rename_absolute(tmp, job_path)
	var outs: Array = []
	for wi in _pids.size():
		outs.append(_batch_dir.path_join("out_%d_%d.bin" % [_wave, wi]))
	var load_max: float = 0.0
	var work_max: float = 0.0
	var waiting: Array = range(outs.size())
	while not waiting.is_empty():
		var still: Array = []
		for wi in waiting:
			if FileAccess.file_exists(outs[wi]):
				continue
			if not OS.is_process_running(int(_pids[wi])):
				_broken = true   # it died: its share runs on threads, and so does the rest of the batch
				continue
			still.append(wi)
		waiting = still
		if waiting.is_empty():
			break
		if float(Time.get_ticks_msec() - t0) / 1000.0 > timeout_s:
			_broken = true
			break
		OS.delay_msec(2)
	for wi in outs.size():
		var rf := FileAccess.open(outs[wi], FileAccess.READ)
		if rf == null:
			continue
		var d: Variant = rf.get_var()
		rf.close()
		DirAccess.remove_absolute(outs[wi])
		if not (d is Dictionary) or not (d.get("results") is Dictionary):
			continue
		load_max = maxf(load_max, float(d.get("load_s", 0.0)))
		work_max = maxf(work_max, float(d.get("work_s", 0.0)))
		var got: Dictionary = d.results
		for k in got:
			var i: int = int(k)
			if i >= 0 and i < results.size():
				results[i] = got[k]
	DirAccess.remove_absolute(job_path)
	wave_stats.append({"tasks": tasks.size(), "workers": _pids.size(), "wall_s": float(Time.get_ticks_msec() - t0) / 1000.0,
		"load_s_max": load_max, "work_s_max": work_max})
	last_done = 0
	for r in results:
		if r != null:
			last_done += 1
	last_failed = tasks.size() - last_done
	return results


## Stops the batch's workers, clears its folder and lets the next batch use workers.
func end() -> void:
	if _batch_dir == "":
		_release()
		return
	var qf := FileAccess.open(_batch_dir.path_join("quit"), FileAccess.WRITE)
	if qf != null:
		qf.close()
	var t0: int = Time.get_ticks_msec()
	for pid in _pids:
		while int(pid) > 0 and OS.is_process_running(int(pid)) and Time.get_ticks_msec() - t0 < 2000:
			OS.delay_msec(2)
		if int(pid) > 0 and OS.is_process_running(int(pid)):
			OS.kill(int(pid))
	_pids = []
	for name in DirAccess.get_files_at(_batch_dir):
		DirAccess.remove_absolute(_batch_dir.path_join(name))
	DirAccess.remove_absolute(_batch_dir)
	_batch_dir = ""
	_release()


func _release() -> void:
	if _holds_gate:
		_holds_gate = false
		_gate.unlock()


## Writes the data snapshot once (the coordinator's data as it holds it, in-memory changes included).
func _prepare() -> bool:
	if _data_file != "" and FileAccess.file_exists(_data_file):
		return true
	_sweep_stale(ProjectSettings.globalize_path(ROOT))
	_root = ProjectSettings.globalize_path(ROOT).path_join("%d_%d" % [OS.get_process_id(), get_instance_id()])
	if DirAccess.make_dir_recursive_absolute(_root) != OK:
		return false
	_data_file = _root.path_join("data.bin")
	var f := FileAccess.open(_data_file, FileAccess.WRITE)
	if f == null:
		return false
	f.store_var(_gd.registry.files())
	f.close()
	return true


## Removes pool folders a process left behind when it quit without freeing its pool: only those whose data file is more
## than STALE_S old, since other processes (parallel test groups, a second game) may be using theirs right now.
static func _sweep_stale(root: String) -> void:
	var now: int = int(Time.get_unix_time_from_system())
	for sub in DirAccess.get_directories_at(root):
		var d: String = root.path_join(sub)
		var data: String = d.path_join("data.bin")
		if FileAccess.file_exists(data) and now - int(FileAccess.get_modified_time(data)) < STALE_S:
			continue
		for inner in DirAccess.get_directories_at(d):
			for name in DirAccess.get_files_at(d.path_join(inner)):
				DirAccess.remove_absolute(d.path_join(inner).path_join(name))
			DirAccess.remove_absolute(d.path_join(inner))
		for name in DirAccess.get_files_at(d):
			DirAccess.remove_absolute(d.path_join(name))
		DirAccess.remove_absolute(d)


func _notification(what: int) -> void:
	# inline (no method calls on a RefCounted being freed): stop this pool's workers and clear its batch folder; the
	# shared snapshot folder is swept by age (_sweep_stale)
	if what == NOTIFICATION_PREDELETE:
		for pid in _pids:
			if int(pid) > 0 and OS.is_process_running(int(pid)):
				OS.kill(int(pid))
		if _batch_dir != "":
			for name in DirAccess.get_files_at(_batch_dir):
				DirAccess.remove_absolute(_batch_dir.path_join(name))
			DirAccess.remove_absolute(_batch_dir)
		if _holds_gate:
			_gate.unlock()
