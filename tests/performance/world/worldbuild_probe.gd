extends SceneTree
## Builds one continent world (WorldBuilder) and prints its counts and time (observation; World Generation's 30 s
## load budget, ADR-0003 decision 12). Run: godot --headless --path . -s res://tests/performance/world/worldbuild_probe.gd


func _init() -> void:
	var gd := GameData.load_from("res://assets/data")
	gd.file("combat_rankings")["enabled"] = false
	var tree := DaoDoTree.load_map(gd)
	var rng := RandomNumberGenerator.new()
	rng.seed = 101
	var t0: int = Time.get_ticks_msec()
	var b := WorldBuilder.new(gd, tree)
	var db: WorldDB = b.generate(rng, "101")
	var ms: int = Time.get_ticks_msec() - t0
	print("errors: ", b.errors)
	var alive: Array = db.find("people", func(p): return p.alive and not p.get("is_beast", false))
	var by := [0, 0, 0, 0, 0]
	for p in alive:
		by[int(p.realm_index)] += 1
	var members: int = 0
	for s in db.find("sects", func(x): return x.status == "active"):
		members += s.members.size()
	print("built in %d ms: %d places, %d regions, %d sects, %d events, %d alive %s, %d in sects, ledger %d, year %d" % [
		ms, db.count("places"), db.count("regions"), db.count("sects"), db.count("events"), alive.size(), str(by), members,
		b.ledger.size(), b.current_year])
	quit()
