extends SceneTree
## Probe (observation only): what makes the season tick slower as the world ages. At years 5 and N, the table sizes and
## each step's ms a season over 8 seasons (production, economy, money, politics, map; the people step is the rest).
##   -s res://tests/performance/world/tick_growth_probe.gd -- [years]

var gd: GameData
var db: WorldDB
var ticker: WorldTicker
var rng := RandomNumberGenerator.new()
var year: int


func _init() -> void:
	var args := OS.get_cmdline_user_args()
	var years: int = int(args[0]) if args.size() > 0 else 150
	gd = GameData.load_from("res://assets/data")
	gd.file("combat_rankings")["enabled"] = false
	rng.seed = 11
	var tree := DaoDoTree.load_map(gd)
	var builder := WorldBuilder.new(gd, tree)
	db = builder.generate(rng, "11")
	year = builder.current_year
	ticker = WorldTicker.new(gd, db, BuildGenerator.new(gd, tree, db))
	_run(5)
	_measure()
	_run(years - 5)
	_measure()
	quit()


func _run(n: int) -> void:
	for y in n:
		for s in 4:
			ticker.tick(rng, year, s)
		year += 1


func _measure() -> void:
	var sizes: Array = []
	for t in WorldDB.TABLES:
		sizes.append("%s %d" % [t, db.count(t)])
	print("year %d sizes: %s; living %d" % [year, ", ".join(PackedStringArray(sizes)), db.living().size()])
	var t := {"tick": 0.0, "production": 0.0, "economy": 0.0, "money": 0.0, "politics": 0.0, "map": 0.0}
	var seed_s: String = str(db.get_record("world", "w_meta").get("seed", ""))
	for i in 8:
		var s: int = i % 4
		var u: int = Time.get_ticks_usec()
		ticker.tick(rng, year, s)
		t.tick += float(Time.get_ticks_usec() - u)
		var money := MoneyLedger.new(db)
		money.open_season()
		u = Time.get_ticks_usec(); MapProduction.season(gd, db, s == 0); t.production += float(Time.get_ticks_usec() - u)
		u = Time.get_ticks_usec(); WorldEconomy.season(gd, db, money); t.economy += float(Time.get_ticks_usec() - u)
		u = Time.get_ticks_usec(); WorldMoney.season(gd, db, money, year, s); t.money += float(Time.get_ticks_usec() - u)
		u = Time.get_ticks_usec(); SectPolitics.season(gd, db, money, year, s, seed_s); t.politics += float(Time.get_ticks_usec() - u)
		u = Time.get_ticks_usec(); MapChange.season(db, year, s, seed_s); t.map += float(Time.get_ticks_usec() - u)
		if s == 3:
			year += 1
	var o: Array = []
	for k in t:
		o.append("%s %.0f" % [k, float(t[k]) / 8000.0])
	print("year %d ms a season: %s" % [year, ", ".join(PackedStringArray(o))])
