extends SceneTree
## Probe (observation only): the age spread a mature world settles into (plan decision 4, 2026-11-21). Runs the built
## continent for --years (400) and prints, per realm, the living people's ages as a 10-bin histogram of
## x = (age − age_min[r]) / (lifespan[r] − age_min[r]), at the start and every 100 years.

func _hist(gd: GameData, db: WorldDB) -> Array:
	var people: Dictionary = gd.world_gen().people
	var out: Array = []
	for r in gd.realms().size():
		out.append([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
	for p in db.living():
		if bool(p.get("is_beast", false)) or bool(p.get("is_player", false)):
			continue
		var r: int = int(p.get("realm_index", 0))
		var lo: float = float(people.age_min_by_realm[r])
		var hi: float = float(gd.realm(r).lifespan)
		var x: float = (float(p.age) - lo) / maxf(hi - lo, 1.0)
		var b: int = clampi(int(floor(x * 10.0)), 0, 10)   # bin 10: past the base lifespan (lifespan bonuses)
		out[r][b] += 1
	return out


func _init() -> void:
	var years: int = 400
	var args := OS.get_cmdline_user_args()
	if args.find("--years") >= 0:
		years = int(args[args.find("--years") + 1])
	var gd := GameData.load_from("res://assets/data")
	gd.file("combat_rankings")["enabled"] = false
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	var tree := DaoDoTree.load_map(gd)
	var builder := WorldBuilder.new(gd, tree)
	var db: WorldDB = builder.generate(rng, "11")
	var year: int = builder.current_year
	var ticker := WorldTicker.new(gd, db, BuildGenerator.new(gd, tree, db))
	print("year %d: %s" % [year, str(_hist(gd, db))])
	for y in years:
		for s in 4:
			ticker.tick(rng, year, s)
		year += 1
		if (y + 1) % 100 == 0:
			print("year %d: %s" % [year, str(_hist(gd, db))])
	quit()
