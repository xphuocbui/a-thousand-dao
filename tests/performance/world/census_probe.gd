extends SceneTree
## Probe (observation only): the realm census every 5 years for N years, with the money speed-up as built ("money"),
## switched off ("none": prov_max 0 and no stone boost), to see how much of the census excess money makes. It also
## prints the mean speed factor (1 + prov)(1 + stone_boost) by realm.
##   -s res://tests/performance/world/census_probe.gd -- money|none [years]


func _init() -> void:
	var args := OS.get_cmdline_user_args()
	var mode: String = args[0] if args.size() > 0 else "money"
	var years: int = int(args[1]) if args.size() > 1 else 40
	var gd := GameData.load_from("res://assets/data")
	gd.file("combat_rankings")["enabled"] = false
	if mode == "none":
		gd.file("economy").provision["prov_max"] = 0.0
		gd.file("economy").money["absorb_cap"] = 0.0
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	var tree := DaoDoTree.load_map(gd)
	var builder := WorldBuilder.new(gd, tree)
	var db: WorldDB = builder.generate(rng, "11")
	var year: int = builder.current_year
	var ticker := WorldTicker.new(gd, db, BuildGenerator.new(gd, tree, db))
	for y in years:
		for s in 4:
			ticker.tick(rng, year, s)
		year += 1
		if (y + 1) % 5 == 0:
			var census := [0, 0, 0, 0, 0]
			var fsum := [0.0, 0.0, 0.0, 0.0, 0.0]
			for p in db.all("people"):
				if bool(p.get("alive", false)) and not bool(p.get("is_beast", false)) and not bool(p.get("is_player", false)):
					var rl: int = clampi(int(p.get("realm_index", 0)), 0, 4)
					census[rl] += 1
					fsum[rl] += (1.0 + float(p.get("prov", 0.0))) * (1.0 + float(p.get("stone_boost", 0.0)))
			var f: Array = []
			for rl in 5:
				f.append("%.2f" % (fsum[rl] / maxf(float(census[rl]), 1.0)))
			print("%s year %d census %s speed %s" % [mode, year, str(census), " ".join(PackedStringArray(f))])
	quit()
