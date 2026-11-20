extends SceneTree
## The authored cast in a built world (observation): every living member's build source, and the cast's chiến lực
## against the random cultivators of the same realm (median), so a hand-authored head is visibly a power of its realm.
## Run: godot --headless --path . -s res://tests/performance/world/cast_power_probe.gd


func _init() -> void:
	var gd := GameData.load_from("res://assets/data")
	gd.file("combat_rankings")["enabled"] = false
	var rng := RandomNumberGenerator.new()
	rng.seed = 5
	var b := WorldBuilder.new(gd, DaoDoTree.load_map(gd))
	var db: WorldDB = b.generate(rng, "5")
	print("errors: ", b.errors)
	var cast: Array = db.find("people", func(p): return p.alive and p.has("cast_key"))
	var sources := {}
	for p in cast:
		sources[str(p.get("build_source", "?"))] = int(sources.get(str(p.get("build_source", "?")), 0)) + 1
	print("cast %d living, build sources %s" % [cast.size(), str(sources)])
	for r in range(1, 5):
		var rand: Array = db.find("people", func(p): return p.alive and int(p.realm_index) == r and not p.has("cast_key") and not p.get("is_beast", false)).map(func(p): return float(p.get("power", 0.0)))
		var mine: Array = cast.filter(func(p): return int(p.realm_index) == r).map(func(p): return float(p.get("power", 0.0)))
		rand.sort()
		mine.sort()
		if mine.is_empty() or rand.is_empty():
			continue
		print("%s: cast %d median power %.0f (min %.0f max %.0f) vs random %d median %.0f p90 %.0f" % [gd.realm(r).name, mine.size(), mine[mine.size() / 2], mine[0], mine[-1], rand.size(), rand[rand.size() / 2], rand[rand.size() * 9 / 10]])
	for p in cast.slice(0, 4):
		print("  %s (%s, %s): root %s, main %s, %d tree nodes, %d gear, power %.0f" % [p.name, gd.realm(int(p.realm_index)).name, str(p.sect_rank), str(p.linh_can.elements), str(p.main_tech), Array(p.tree_nodes).size(), Array(p.equipped).size(), float(p.power)])
	quit()
