extends Node
## Thread-scaling probe for ADR-0003's spike follow-up: which kinds of GDScript work scale on WorkerThreadPool (one
## task per logical core, the same work single-threaded for comparison). Run through the bench scene:
##   build/bench/combat_bench.exe --headless -- --scale-probe        (release export; output to a file)
##   godot --headless --path . res://tests/performance/combat/combat_bench.tscn -- --scale-probe   (editor binary)
## Prints one "SCALE" line per kind.

class Blob extends RefCounted:
	var x: float = 0.0
	var y: int = 0

	func take(x2: float, v: float) -> float:
		return v * 0.5 if x2 > 1.0 else v

	static func stake(x2: float, v: float) -> float:
		return v * 0.5 if x2 > 1.0 else v

var _shared_blob := Blob.new()
var _shared_dict := {"bleed": {"c_tick": 0.3, "kind": "tick"}, "a": 1}
var _shared_arr := [1.0, 2.0, 3.0]

var _kind := ""
var _n := 0
var _sink: PackedFloat64Array = []
var _k: CombatConstants
var _a: FighterProfile
var _b: FighterProfile


func _work(t: int) -> void:
	var acc := 0.0
	match _kind:
		"math":
			for i in _n:
				acc += sqrt(float(i) * 1.0001 + acc * 0.5)
		"refcounted":
			for i in _n:
				var b := Blob.new()
				b.x = float(i)
				acc += b.x
		"array":
			for i in _n:
				var a: Array = [i, 2.0, 3]
				var d := {"k": i}
				acc += float(a.size() + d.size())
		"stringname":
			for i in _n:
				var s := StringName("key_%d" % (i % 64))
				acc += float(s.length())
		"conststr":
			for i in _n:
				acc += _take_str("art_speed", float(i))
		"stringname_lit":
			for i in _n:
				acc += _take_sn(&"phys", float(i))
		"local_float":
			for i in _n:
				acc += _take_f(1.5, float(i))
		"shared_obj":
			for i in _n:
				acc += _shared_blob.take(1.5, float(i))
		"own_obj":
			var mine := Blob.new()
			for i in _n:
				acc += mine.take(1.5, float(i))
		"static":
			for i in _n:
				acc += Blob.stake(1.5, float(i))
		"dict_read":
			for i in _n:
				var d: Dictionary = _shared_dict["bleed"]
				acc += float(d["c_tick"])
		"dict_scalar":
			for i in _n:
				acc += float(_shared_dict["a"])
		"own_dict_read":
			var mine := {"bleed": {"c_tick": 0.3}}
			for i in _n:
				var d2: Dictionary = mine["bleed"]
				acc += float(d2["c_tick"])
		"fight":
			for i in _n:
				var r: FightResult = Fight.new(_a, _b, _k, t * 100000 + i, Fight.Order.COIN, false).run()
				acc += r.seconds
	_sink[t] = acc


func _take_str(key: String, v: float) -> float:
	return v * 0.5 if key.length() > 3 else v


func _take_sn(key: StringName, v: float) -> float:
	return v * 0.5 if key == &"phys" else v


func _take_f(x: float, v: float) -> float:
	return v * 0.5 if x > 1.0 else v


func _run(kind: String, n: int, tasks: int) -> Array:
	_kind = kind
	_n = n
	_sink.resize(64)
	var t0 := Time.get_ticks_usec()
	for t in tasks:
		_work(t)
	var single := (Time.get_ticks_usec() - t0) / 1000.0
	t0 = Time.get_ticks_usec()
	var g := WorkerThreadPool.add_group_task(_work, tasks, -1, true, kind)
	WorkerThreadPool.wait_for_group_task_completion(g)
	var mt := (Time.get_ticks_usec() - t0) / 1000.0
	return [single, mt]


func _ready() -> void:
	var gd := GameData.load_from("res://assets/data")
	_k = CombatConstants.from_game_data(gd)
	_a = FighterCompiler.from_data("typical", 1, gd)
	_b = FighterCompiler.from_data("typical", 1, gd)
	var tasks: int = OS.get_processor_count()
	for spec in [["math", 2000000], ["conststr", 2000000], ["stringname_lit", 2000000], ["dict_scalar", 2000000], ["dict_read", 2000000], ["own_dict_read", 2000000], ["array", 400000], ["fight", 20]]:
		var r: Array = _run(spec[0], spec[1], tasks)
		print("SCALE %-10s single %8.0f ms  pool %8.0f ms  speed-up x%.2f  (%d tasks)" % [spec[0], r[0], r[1], r[0] / maxf(0.001, r[1]), tasks])
	get_tree().quit(0)
