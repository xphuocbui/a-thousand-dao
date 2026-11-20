extends DaoTestSuite
## The seasonal markets on the built continent (design/gdd/regional-economy-trade.md rules 1-11, 19-20; Formulas A-E,
## L1; AC-RE-01, AC-RE-51, AC-RE-57). One world is built for the suite; each test works on its own copy.

var _base: Dictionary = {}


func before() -> void:
	var r := RandomNumberGenerator.new()
	r.seed = 7
	_base = WorldBuilder.new(game_data(), TestFixtures.tree()).generate(r, "7").to_dict()


func _world() -> WorldDB:
	return WorldDB.from_dict(_base.duplicate(true))


func _markets(db: WorldDB) -> Array:
	var ms: Array = db.find(WorldEconomy.TABLE, func(x): return str(x.id).begins_with("mk:"))
	ms.sort_custom(func(a, b): return str(a.id) < str(b.id))
	return ms


func test_one_market_per_great_sect_over_its_regions() -> void:
	var db := _world()
	var ms := _markets(db)
	assert_eq(ms.size(), 7, "AC-RE-01: seven markets")
	var seen := {}
	for m in ms:
		for rid in m.regions:
			assert_false(seen.has(rid), "%s is in one market only" % rid)
			seen[rid] = true
			assert_eq(WorldEconomy.market_of_region(db, db.get_record("regions", rid)), str(m.id), "%s's market is its holder's" % rid)
	assert_eq(seen.size(), db.count("regions"), "every region is held by a great sect")


func test_calibration_starts_every_market_at_rest() -> void:
	# Formula C's calibration and D's starting stock: price 1 and cover at c_ref (above it in a glut market)
	var db := _world()
	var cfg: Dictionary = game_data().file("economy")
	for m in _markets(db):
		assert_eq(m.classes.keys(), ["herb1", "herb2", "herb3", "ore1", "ore2", "beast1", "special1", "special2"], "Trade Goods rule 8a's eight raw classes")
		for k in m.classes:
			var c: Dictionary = m.classes[k]
			assert_eq(float(c.p), 1.0, "%s %s starts at P 1" % [m.id, k])
			assert_true(float(c.cover) >= float(cfg.classes.c_ref[c.kind]) - 1e-6, "%s %s starts at cover c_ref or above" % [m.id, k])


func test_a_season_writes_local_prices_back_as_price_index() -> void:
	var db := _world()
	var gd := game_data()
	MapProduction.season(gd, db, true)
	WorldEconomy.season(gd, db)
	var band: float = float(gd.file("economy").local.loc_band)
	for m in _markets(db):
		for rid in m.regions:
			var pi: Dictionary = db.get_record("regions", rid).get("price_index", {})
			for k in ["herb", "ore", "beast", "special"]:
				assert_true(pi.has(k), "%s has a local price of the kind %s (Travel & Map's demand factor)" % [rid, k])
			for k in m.classes:
				assert_true(pi.has(k), "%s has a local price of class %s" % [rid, k])
				var p: float = float(m.classes[k].p)
				assert_true(float(pi[k]) >= p * (1.0 - band) - 1e-6 and float(pi[k]) <= p * (1.0 + band) + 1e-6, "%s %s within loc_band of its market" % [rid, k])


func test_a_supply_shock_raises_the_price() -> void:
	# rule 10: the market answers a lost harvest with a higher price, over seasons, within delta a season
	var db := _world()
	var gd := game_data()
	var m: Dictionary = _markets(db)[0]
	var before: float = float(m.classes.herb1.p)
	for s in 3:
		MapProduction.season(gd, db, true)
		for rid in m.regions:
			var r: Dictionary = db.get_record("regions", rid)
			for g in r.production_value.keys():
				if WorldEconomy.kind_of(gd, str(g)) == "herb":
					r.production_value[g] = 0.0
		WorldEconomy.season(gd, db)
	var after: float = float(m.classes.herb1.p)
	assert_true(after > before, "herb price rose after three lost harvests (%.3f -> %.3f)" % [before, after])
	assert_true(after <= before * pow(float(gd.file("economy").classes.delta.herb), 3) + 1e-6, "within delta a season")


func test_the_players_buying_raises_the_local_price_next_season() -> void:
	# Formula L1 with the player's trades: buying in a region lifts its local price at the next tick
	var gd := game_data()
	var a := _world()
	var b := _world()
	var m: Dictionary = _markets(a)[0]
	var rid: String = ""
	for r in m.regions:
		if float(m.regions[r].d) > 0.0:
			rid = r
			break
	for db in [a, b]:
		MapProduction.season(gd, db, true)
	WorldEconomy.record_player_trade(gd, a, rid, "herb1", 3000.0, true)
	WorldEconomy.season(gd, a)
	WorldEconomy.season(gd, b)
	assert_true(WorldEconomy.local_price(a, rid, "herb1") > WorldEconomy.local_price(b, rid, "herb1"), "the bought region is dearer than without the purchase")


func test_a_saved_world_resumes_the_same_prices() -> void:
	# all market state is in the World DB, so a save and load re-ticks identically
	var gd := game_data()
	var a := _world()
	MapProduction.season(gd, a, true)
	WorldEconomy.season(gd, a)
	var b := WorldDB.from_dict(a.to_dict().duplicate(true))
	for db in [a, b]:
		MapProduction.season(gd, db, false)
		WorldEconomy.season(gd, db)
	for k in _markets(a)[2].classes:
		assert_eq(_markets(b)[2].classes[k].p, _markets(a)[2].classes[k].p, "%s price after a reload" % k)
		assert_eq(_markets(b)[2].classes[k].pool, _markets(a)[2].classes[k].pool, "%s composition after a reload" % k)
