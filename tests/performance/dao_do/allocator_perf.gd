extends SceneTree
## AC-KMD-54 (Đạo Đồ Computational budget): the NPC allocator on the v5 map. Not a gdUnit test. Measures
## Time.get_ticks_usec() around BuildGenerator.allocate only, for 200 seeded Deity Transformation NPCs at 566 points
## (p95 <= 50 ms, max <= 100 ms) and 200 Foundation Establishment NPCs at 120 points (p95 <= 5 ms).
##   godot --headless --path . -s res://tests/performance/dao_do/allocator_perf.gd
## Prints one line per group: median, p95, max (ms) and PASS or FAIL against the budget. Exits 1 on a FAIL.

const CYCLE := ["moc", "hoa", "tho", "kim", "thuy"]


func _init() -> void:
	var gd := GameData.load_from("res://assets/data")
	var tree := DaoDoTree.load_map(gd)
	var gen := BuildGenerator.new(gd, tree, WorldDB.new())
	var ok := true
	for g in [{"name": "Deity Transformation, 566 points", "realm": 4, "points": 566, "p95": 50.0, "max": 100.0},
			{"name": "Foundation Establishment, 120 points", "realm": 1, "points": 120, "p95": 5.0, "max": 1e9}]:
		var times: Array = []
		var rng := RandomNumberGenerator.new()
		rng.seed = 54
		for i in 200:
			var c := Character.new()
			var n: int = 1 + i % 3
			for k in n:
				c.linh_can.elements[CYCLE[(i + k * 2) % 5]] = float(30 + (i * 7 + k * 13) % 70)
			c.realm_index = int(g.realm)
			var sid: int = tree.npc_start(c.linh_can, gd)
			c.tree_nodes = [sid]
			c.tree_points = int(g.points)
			var t0 := Time.get_ticks_usec()
			gen.allocate(c, rng, [c.linh_can.strongest_element()])
			times.append(float(Time.get_ticks_usec() - t0) / 1000.0)
		times.sort()
		var med: float = times[times.size() / 2]
		var p95: float = times[int(times.size() * 0.95)]
		var mx: float = times[-1]
		var passed: bool = p95 <= float(g.p95) and mx <= float(g.max)
		ok = ok and passed
		print("ALLOC %s: median %.2f ms, p95 %.2f ms, max %.2f ms -> %s (budget p95 %s ms, max %s ms)" % [g.name, med, p95, mx, "PASS" if passed else "FAIL", str(g.p95), str(g.max)])
	print("CPU %s" % OS.get_processor_name())
	quit(0 if ok else 1)
