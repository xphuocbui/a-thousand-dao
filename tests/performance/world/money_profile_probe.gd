extends SceneTree
## Probe (observation only): WorldMoney.season's sub-steps in ms a season (5-year warm-up, then 12 seasons).

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
	var t := {}
	var steps := ["index", "mines", "stipends", "commons", "baskets", "market", "sects", "works", "heads", "treasury"]
	for k in steps:
		t[k] = 0
	for i in 12:
		var money := MoneyLedger.new(db)
		money.open_season()
		var u: int = Time.get_ticks_usec()
		var idx: Dictionary = WorldMoney._index(db)
		t.index += Time.get_ticks_usec() - u
		u = Time.get_ticks_usec(); WorldMoney._mines(gd, db, money); t.mines += Time.get_ticks_usec() - u
		u = Time.get_ticks_usec(); WorldMoney._stipends(gd, db, money, idx); t.stipends += Time.get_ticks_usec() - u
		u = Time.get_ticks_usec(); WorldMoney._commons_missions(gd, db, money, idx); t.commons += Time.get_ticks_usec() - u
		u = Time.get_ticks_usec(); WorldMoney._baskets(gd, db, money, idx); t.baskets += Time.get_ticks_usec() - u
		u = Time.get_ticks_usec(); WorldMoney._market_income(gd, db, money); t.market += Time.get_ticks_usec() - u
		u = Time.get_ticks_usec(); SectEconomy.season(gd, db, money); t.sects += Time.get_ticks_usec() - u
		u = Time.get_ticks_usec(); SectWorks.upkeep(gd, db, money); t.works += Time.get_ticks_usec() - u
		u = Time.get_ticks_usec(); WorldMoney._heads_draw(gd, db, money); t.heads += Time.get_ticks_usec() - u
		u = Time.get_ticks_usec(); WorldMoney._treasury_rule(gd, db, money, idx, year, i % 4); t.treasury += Time.get_ticks_usec() - u
	var o: Array = []
	for k in steps:
		o.append("%s %.1f" % [k, float(t[k]) / 12000.0])
	print("money ms a season: " + ", ".join(PackedStringArray(o)))
	quit()
