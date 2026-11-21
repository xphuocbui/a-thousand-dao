extends Node
## AC-NR-31 in the release export (user decision 2026-11-21): tie_cost_probe.gd's measurement as a node, so the bench
## scene runs it: `build/bench/combat_bench.exe --headless -- --tie-cost`. Observation only.

func _ready() -> void:
	var gd := GameData.load_from("res://assets/data")
	gd.file("combat_rankings")["enabled"] = false
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	var tree := DaoDoTree.load_map(gd)
	var builder := WorldBuilder.new(gd, tree)
	var db: WorldDB = builder.generate(rng, "11")
	var year: int = builder.current_year
	var ticker := WorldTicker.new(gd, db, BuildGenerator.new(gd, tree, db))
	var hook_ms: Array = []
	var tick_ms: Array = []
	for y in 20:
		for s in 4:
			var t0: int = Time.get_ticks_usec()
			ticker.tick(rng, year, s)
			tick_ms.append(float(Time.get_ticks_usec() - t0) / 1000.0)
			var t1: int = Time.get_ticks_usec()
			TieTick.hook_pass(gd, db, MapChange.abs_season(year, s))
			hook_ms.append(float(Time.get_ticks_usec() - t1) / 1000.0)
		year += 1
	# S8b alone: a run on an empty queue after the tick (the hook pass inside it) and one with 30 queued old-age deaths
	var dead: Array = db.living().filter(func(p): return not bool(p.get("is_player", false))).slice(0, 30)
	var t2: int = Time.get_ticks_usec()
	for p in dead:
		p["alive"] = false
		TieTick.enqueue(db, {"kind": "death", "dead": str(p.id), "cause": "old_age"})
	TieTick.run(gd, db, MapChange.abs_season(year, 0))
	var s8b: float = float(Time.get_ticks_usec() - t2) / 1000.0
	hook_ms.sort()
	tick_ms.sort()
	print("ties %d, hook index %d; tick p50 %.0f ms; hook pass p50 %.2f p95 %.2f ms; S8b with 30 deaths %.2f ms" % [db.count("ties"), db.hook_ties().size(),
		tick_ms[tick_ms.size() / 2], hook_ms[hook_ms.size() / 2], hook_ms[int(hook_ms.size() * 0.95)], s8b])
	print("AC-NR-31 budgets: S8b <= 5 ms, hook pass <= 2 ms at p95 (release export)")
	get_tree().quit()
