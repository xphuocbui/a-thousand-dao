extends SceneTree
## Generates a world and ticks it forward, printing the headcount by realm and the time taken.
## Measures the world-size targets in canh-gioi.md (Formulas C2, AC-CG-69).
##
##   Godot_console.exe --headless --path . -s res://tools/balance/world_census.gd -- \
##       [--seed 101] [--size 5000] [--years 2000] [--every 500]


func _init() -> void:
	var args: Array = Array(OS.get_cmdline_user_args())
	var seed_v: int = int(_arg(args, "--seed", "101"))
	var years: int = int(_arg(args, "--years", "200"))
	var every: int = int(_arg(args, "--every", "50"))
	var gd: GameData = GameData.load_from("res://assets/data")
	var size: int = int(_arg(args, "--size", str(gd.world_gen().people.world_cultivators)))
	gd.world_gen().people.world_cultivators = size
	gd.world_gen().people.world_cultivators_min = mini(int(gd.world_gen().people.world_cultivators_min), size)
	var tree: MeridianTree = MeridianTree.generate(gd)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_v
	var t0: int = Time.get_ticks_msec()
	var gen := WorldGenerator.new(gd, tree)
	var db: WorldDB = gen.generate(rng)
	print("generated in %.1f s" % [float(Time.get_ticks_msec() - t0) / 1000.0])
	_census(gd, db, 0)
	var builds := BuildGenerator.new(gd, tree, db)
	var ticker := WorldTicker.new(gd, db, builds)
	var edges: int = int(_arg(args, "--edges", "0"))
	if edges > 0:
		_edge_histogram(gd, ticker, db, rng, edges)
		quit(0)
		return
	var seasons: int = int(gd.cultivation_rules().seasons_per_year)
	t0 = Time.get_ticks_msec()
	for y in range(1, years + 1):
		for s in seasons:
			ticker.tick(rng, y, s)
		if y % every == 0:
			var ms: float = float(Time.get_ticks_msec() - t0) / float(y * seasons)
			print("%.1f ms per season" % ms)
			_census(gd, db, y)
	quit(0)


## Prints "EDGE score count" for [param n] new cultivators, in steps of 0.01: the input for
## solving npc.gate_steps against the 1 in 8 / 12 / 15 / 20 targets.
func _edge_histogram(gd: GameData, ticker: WorldTicker, db: WorldDB, rng: RandomNumberGenerator, n: int) -> void:
	var known: Dictionary = {}
	for p in db.all("people"):
		known[p.id] = true
	for i in n:
		ticker.new_cultivator(rng)
	var hist: Dictionary = {}
	for p in db.all("people"):
		if not known.has(p.id):
			var k: int = roundi(ProgressionEdges.npc_edge_score(p, gd).total * 100.0)
			hist[k] = int(hist.get(k, 0)) + 1
	var keys: Array = hist.keys()
	keys.sort()
	for k in keys:
		print("EDGE %d %d" % [k, hist[k]])


func _census(gd: GameData, db: WorldDB, year: int) -> void:
	var counts: Array = []
	counts.resize(gd.realms().size())
	counts.fill(0)
	var total: int = 0
	for p in db.all("people"):
		if p.alive and not p.get("is_beast", false):
			counts[int(p.realm_index)] += 1
			total += 1
	print("year %d: %d cultivators, by realm %s" % [year, total, str(counts)])


func _arg(args: Array, flag: String, default: String) -> String:
	var i: int = args.find(flag)
	return str(args[i + 1]) if i >= 0 and i + 1 < args.size() else default
