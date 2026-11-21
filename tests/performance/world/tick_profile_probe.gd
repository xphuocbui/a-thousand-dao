extends SceneTree
## Probe (observation only): the world tick's cost by step over 20 seasons after a 5-year warm-up: production,
## the economy, money, politics, map change, and the people step (WorldTicker.tick minus the four), in ms a season.

func _init() -> void:
	var gd := GameData.load_from("res://assets/data")
	gd.file("combat_rankings")["enabled"] = false
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	var tree := DaoDoTree.load_map(gd)
	var builder := WorldBuilder.new(gd, tree)
	var db: WorldDB = builder.generate(rng, "11")
	var year: int = builder.current_year
	var ticker := WorldTicker.new(gd, db, BuildGenerator.new(gd, tree, db))
	for y in 5:
		for s in 4:
			ticker.tick(rng, year, s)
		year += 1
	var t := {"tick": 0.0, "production": 0.0, "economy": 0.0, "money": 0.0, "politics": 0.0, "map": 0.0}
	var seed_s: String = str(db.get_record("world", "w_meta").get("seed", ""))
	for y in 5:
		for s in 4:
			# each step timed on its own on a copy-free rerun would double the season; instead time the steps once,
			# then the full tick on the next season, and subtract the means
			var t0: int = Time.get_ticks_usec()
			ticker.tick(rng, year, s)
			t.tick += float(Time.get_ticks_usec() - t0)
			var money := MoneyLedger.new(db)
			money.open_season()
			t0 = Time.get_ticks_usec()
			MapProduction.season(gd, db, s == 0)
			t.production += float(Time.get_ticks_usec() - t0)
			t0 = Time.get_ticks_usec()
			WorldEconomy.season(gd, db, money)
			t.economy += float(Time.get_ticks_usec() - t0)
			t0 = Time.get_ticks_usec()
			WorldMoney.season(gd, db, money, year, s)
			t.money += float(Time.get_ticks_usec() - t0)
			t0 = Time.get_ticks_usec()
			SectPolitics.season(gd, db, money, year, s, seed_s)
			t.politics += float(Time.get_ticks_usec() - t0)
			t0 = Time.get_ticks_usec()
			MapChange.season(db, year, s, seed_s)
			t.map += float(Time.get_ticks_usec() - t0)
		year += 1
	var out: Array = []
	for k in t:
		out.append("%s %.0f" % [k, float(t[k]) / 20000.0])
	print("ms a season: " + ", ".join(PackedStringArray(out)))
	quit()
