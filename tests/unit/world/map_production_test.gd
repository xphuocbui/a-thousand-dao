extends DaoTestSuite
## Resource sites, production and reserves (design/gdd/travel-map.md rules 19-22 and 25, Formulas H, I and L).


func test_reserve_factor_follows_formula_i() -> void:
	var gd := game_data()
	assert_eq(MapProduction.reserve_factor(gd, 0.9), 1.0, "rich")
	assert_near(MapProduction.reserve_factor(gd, 0.55), 0.85, 0.0001, "worked: 0.70 + 0.30 x 0.25 / 0.50")
	assert_near(MapProduction.reserve_factor(gd, 0.10), 0.25, 0.0001, "the floor")


func test_the_gdd_mine_produces_9104_a_season() -> void:
	# Formula H's example: a medium linh thach mine (10,000) near a town (0.85), worked, reserve 0.55, works G_f 1.26
	var gd := game_data()
	var place := {"holder": "s1", "site": {"base_output": 10000.0, "reserve": 330000.0, "reserve_max": 600000.0, "worked": true, "works_prod": 0.26}}
	assert_eq(float(MapProduction.production(gd, place, 0.85).output), 9104.0, "0.85 x 0.85 x 1.26 x 10,000, half up")


func test_over_mining_thins_and_rest_recovers() -> void:
	var gd := game_data()
	var site := {"base_output": 10000.0, "reserve": 330000.0, "reserve_max": 600000.0}
	assert_near(MapProduction.next_reserve(gd, site, 9104.0, 0.01), 330000.0 - 2104.0, 0.01, "drains E - S = 2,104")
	var wild := {"base_output": 10000.0, "reserve": 60000.0, "reserve_max": 600000.0}
	assert_near(MapProduction.next_reserve(gd, wild, 625.0, 0.01), 60000.0 + 0.01 * 600000.0 * (1.0 - 625.0 / 7000.0), 0.01, "a rested site recovers about 5,464")


func test_the_built_world_has_sites_that_produce_each_season() -> void:
	var r := RandomNumberGenerator.new()
	r.seed = 7
	var b := WorldBuilder.new(game_data(), TestFixtures.tree())
	var db: WorldDB = b.generate(r, "7")
	var sites: Array = db.find("places", func(p): return p.has("site"))
	assert_true(sites.size() >= 20, "the mines and veins are sites (%d)" % sites.size())
	for p in sites:
		var lt: bool = str(p.site.resource) == "linh_thach"
		if str(p.kind) == "spirit_vein":
			assert_true(lt, "a spirit vein yields linh thach")
		assert_true(float(p.site.reserve) <= float(p.site.reserve_max), "%s starts within its reserve" % p.name)
	MapProduction.season(game_data(), db)
	var total: float = 0.0
	for reg in db.all("regions"):
		for k in reg.get("production", {}):
			total += float(reg.production[k])
	assert_true(total > 0.0, "the contract publishes production by region")
	assert_true(db.all("regions").any(func(x): return int(x.get("population", 0)) > 0), "with each region's population")


func test_an_authored_site_yields_its_own_good_of_its_kind() -> void:
	# a mine by its name, a beast lair and a hot spring (user decisions 2026-11-20) yield their authored good, whatever
	# the land under them would infer; the kind picks Formula H's kind_value_mult row
	var gd := game_data()
	var rich := {"qi": {"land_density": 1.6, "shares": {"tho": 30.0, "kim": 40.0}}}
	assert_eq(MapProduction.site_resource(gd, rich).resource, "linh_thach", "the land alone: rich Earth + Metal is a linh thach mine")
	var mine := rich.duplicate(true)
	mine["resource"] = "tinh_thiet"
	assert_eq(MapProduction.site_resource(gd, mine), {"resource": "tinh_thiet", "kind": "ore"}, "an iron mine by its name")
	var lair := rich.duplicate(true)
	lair["kind"] = "beast_lair"
	lair["resource"] = "yeu_cot"
	assert_eq(MapProduction.site_resource(gd, lair), {"resource": "yeu_cot", "kind": "beast"}, "a lair yields beast bone")
	var spring := rich.duplicate(true)
	spring["resource"] = "linh_tuyen_thuy"
	assert_eq(MapProduction.site_resource(gd, spring).kind, "special", "a hot spring's water is a special good")
