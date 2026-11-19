extends SceneTree
## AC-KMD-54, second half: world generation on the v5 map (every NPC's Đạo Đồ allocated by BuildGenerator) within
## 30 s in total. Not a gdUnit test. Ratings are off, so only generation is timed.
##   godot --headless --path . -s res://tests/performance/dao_do/worldgen_perf.gd
## Prints "WORLDGEN <people> people, <ms> ms, <per> ms a person -> PASS|FAIL (budget 30 s)". Exits 1 on a FAIL.


func _init() -> void:
	var gd := GameData.load_from("res://assets/data")
	gd.file("combat_rankings")["enabled"] = false
	var tree := DaoDoTree.load_map(gd)
	var rng := RandomNumberGenerator.new()
	rng.seed = 4242
	var gen := WorldGenerator.new(gd, tree)
	var t0 := Time.get_ticks_usec()
	var db: WorldDB = gen.generate(rng)
	var ms: float = float(Time.get_ticks_usec() - t0) / 1000.0
	var people: int = db.count("people")
	var ok: bool = ms <= 30000.0
	print("WORLDGEN %d people, %.0f ms, %.2f ms a person -> %s (budget 30 s)" % [people, ms, ms / maxf(1.0, float(people)), "PASS" if ok else "FAIL"])
	print("CPU %s" % OS.get_processor_name())
	quit(0 if ok else 1)
