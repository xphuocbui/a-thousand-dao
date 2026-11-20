extends SceneTree
## The economy's starting figures on the built continent (observation, before Regional Economy & Trade #43 is built):
## the mine faucet a season against the GDD's ~124,000, the non-mine production value at P = 1 against
## world_production_guess 250,000, the money in the world at year 0 against M_0 ~1,200,000, and the world tick's time a
## season. Run: godot --headless --path . -s res://tests/performance/world/economy_probe.gd


func _init() -> void:
	var gd := GameData.load_from("res://assets/data")
	gd.file("combat_rankings")["enabled"] = false
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	var tree := DaoDoTree.load_map(gd)
	var db: WorldDB = WorldBuilder.new(gd, tree).generate(rng, "11")
	MapProduction.season(gd, db, true)
	var lt: float = 0.0
	var by_res := {}
	var sites: int = 0
	for p in db.all("places"):
		if not p.has("site"):
			continue
		sites += 1
		var out: float = float(p.site.last_output)
		by_res[str(p.site.resource)] = float(by_res.get(str(p.site.resource), 0.0)) + out
		if str(p.site.resource) == "linh_thach":
			lt += out
	var unit: Dictionary = gd.file(MapProduction.DATA_FILE).unit_value
	var non_mine_value: float = 0.0
	for r in by_res:
		if r != "linh_thach":
			non_mine_value += float(by_res[r]) * float(unit.get(r, 1))
	print("sites %d; linh thach a season %.0f (GDD faucet ~124,000); other output %s; their value at P=1 %.0f (GDD world_production_guess 250,000)" % [sites, lt, str(by_res), non_mine_value])
	var by_kind := {}
	var herb_sites: int = 0
	var kind_of: Dictionary = gd.file(MapProduction.DATA_FILE).get("resource_kind", {})
	for r in db.all("regions"):
		for g in r.get("production_value", {}):
			var k: String = "herb" if not gd.herb(str(g)).is_empty() else str(kind_of.get(str(g), "ore"))
			by_kind[k] = float(by_kind.get(k, 0.0)) + float(r.production_value[g])
	for p in db.all("places"):
		if p.has("herb_site"):
			herb_sites += 1
	var tot: float = 0.0
	for k in by_kind:
		tot += float(by_kind[k])
	print("contract value_lt by kind %s = %.0f (world_production_guess 250,000); %d herb sites" % [str(by_kind), tot, herb_sites])
	var treas: float = 0.0
	for s in db.find("sects", func(x): return x.status == "active"):
		treas += float(s.get("treasury", 0))
	var purses: float = 0.0
	var alive: int = 0
	for p in db.find("people", func(x): return x.alive and not x.get("is_beast", false)):
		purses += float(p.get("linh_thach", 0))
		alive += 1
	var m0: float = MoneyLedger.new(db).money_in_world()
	print("money at year 0: treasuries %.0f + %d NPC purses %.0f + pools %.0f = M_0 %.0f (GDD M_0 ~1,200,000)" % [treas, alive, purses, m0 - treas - purses, m0])
	var ticker := WorldTicker.new(gd, db, BuildGenerator.new(gd, tree, db))
	var t0: int = Time.get_ticks_msec()
	for i in 20:
		ticker.tick(rng, 1200 + i / 4, i % 4)
	print("world tick %.1f ms a season (20 seasons)" % (float(Time.get_ticks_msec() - t0) / 20.0))
	quit()
