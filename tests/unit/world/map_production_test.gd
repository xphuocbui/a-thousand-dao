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


func test_settlement_output_follows_formula_h2() -> void:
	# AC-TM-151: a town (weight 4) at livability 1.03 on land of density 1.1, Ngưng Khí Thảo 0.8, Thanh Tâm Liên 0.7 and
	# Hỏa Linh Chi 0.65 (rarity 2), Metal share 38: 44 x 4.12 x 1.1 x 1.825 = 364 of herbs, 98 x 4.12 x 1.1 x 0.38 = 169
	var gd := game_data()
	var so: Dictionary = gd.file(MapProduction.DATA_FILE).settlement_output
	var kept: Array = [so.h_s, so.o_s]   # the test data is shared by every suite: restored below
	so["h_s"] = 44
	so["o_s"] = 98   # the example's values (the shipped o_s is tuned to the continent)
	var place := {"kind": "town", "livability": 1.03, "qi": {"land_density": 1.1, "shares": {"kim": 38.0, "moc": 20.0, "tho": 20.0, "thuy": 12.0, "hoa": 10.0}}}
	place["local"] = MapProduction.init_local(gd, place, [{"herb": "ngung_khi_thao", "fit": 0.8}, {"herb": "thanh_tam_lien", "fit": 0.7}, {"herb": "hoa_linh_chi", "fit": 0.65}])
	assert_near(float(place.local.pop), 4.12, 1e-6, "P = 4 x 1.03")
	assert_eq(str(place.local.ore), "tinh_thiet", "the ore of the strongest element, Metal")
	var out := MapProduction.local_output(gd, WorldDB.new(), place)
	assert_eq(float(out.herb), 364.0, "herbs")
	assert_eq(float(out.ore), 169.0, "Tinh Thiết")
	var split := MapProduction.herb_split(gd, place.local.herbs, 364)
	assert_eq(int(split.ngung_khi_thao) + int(split.thanh_tam_lien) + int(split.hoa_linh_chi), 364, "the split sums to the value")
	assert_true(int(split.ngung_khi_thao) > int(split.hoa_linh_chi), "fit x rarity weights: the common herb takes more")
	so["h_s"] = kept[0]
	so["o_s"] = kept[1]


func test_settlements_give_their_share_of_the_worlds_goods() -> void:
	# AC-TM-152: on continent 11 at season 0, settlements make 25-40 % of herb value and 15-35 % of ore, and the
	# non-mine total is within 20 % of world_production_guess
	var gd := game_data()
	var r := RandomNumberGenerator.new()
	r.seed = 7
	var db: WorldDB = WorldBuilder.new(gd, TestFixtures.tree()).generate(r, "7")
	var by_kind := {}
	for reg in db.all("regions"):
		for g in reg.get("production_value", {}):
			var k: String = WorldEconomy.kind_of(gd, str(g))
			by_kind[k] = float(by_kind.get(k, 0.0)) + float(reg.production_value[g])
	var lh: float = 0.0
	var lo: float = 0.0
	for p in db.all("places"):
		if p.has("local"):
			for g in p.local.last_herbs:
				lh += float(p.local.last_herbs[g])
			lo += float(p.local.last_ore)
	var tot: float = 0.0
	for k in by_kind:
		tot += float(by_kind[k])
	assert_true(lh / float(by_kind.herb) >= 0.25 and lh / float(by_kind.herb) <= 0.40, "settlement herbs %.0f of %.0f" % [lh, float(by_kind.herb)])
	assert_true(lo / float(by_kind.ore) >= 0.15 and lo / float(by_kind.ore) <= 0.35, "settlement ore %.0f of %.0f" % [lo, float(by_kind.ore)])
	# provinces-v2 (user decision 1, 2026-11-24: new sites one province in four at grade minor, about x1.5 on places):
	# the merged world measures 319,216, so the band moves from 250,000 +-20 % to 320,000 +-20 % (an AC-TM-152 delta
	# listed for the user in production/plans/provinces-v2-gdd-deltas.md)
	assert_true(absf(tot - 320000.0) <= 64000.0, "non-mine value %.0f" % tot)


func test_a_lair_yields_bone_hide_and_cores() -> void:
	# Trade Goods Formula A for beast sites: value shared by ω^(rarity - 1): bone and hide (rarity 1) 0.4 each, cores
	# (rarity 2) 0.2, in whole base value
	var gd := game_data()
	var parts := MapProduction.kind_split(gd, "beast", "yeu_cot", 1000)
	assert_eq(parts, {"yeu_cot": 400, "yeu_dan": 200, "yeu_thu_bi": 400}, "the split")
	assert_eq(MapProduction.kind_split(gd, "ore", "tinh_thiet", 500), {"tinh_thiet": 500}, "an ore site keeps its one good")


func test_a_blessed_lands_rare_herbs_are_not_diluted_formula_a() -> void:
	# Trade Goods Formula A (user decision 2026-11-21): Hóa Thần Quả (rarity 6, fit 1.0) and Hỏa Linh Chi (rarity 2,
	# fit 1.0) share 3,300 of value. On a wild ground: w 0.03125 and 0.5, so 194 / 3,106; at a blessed land the rare
	# herb takes fit alone: w 1.0 and 0.5, so 2,200 / 1,100
	var gd := game_data()
	var grounds := [{"herb": "hoa_than_qua", "fit": 1.0}, {"herb": "hoa_linh_chi", "fit": 1.0}]
	var wild: Dictionary = MapProduction.herb_split(gd, grounds, 3300)
	var blessed: Dictionary = MapProduction.herb_split(gd, grounds, 3300, true)
	assert_eq([int(wild.hoa_than_qua), int(wild.hoa_linh_chi)], [194, 3106], "diluted on a wild ground")
	assert_eq([int(blessed.hoa_than_qua), int(blessed.hoa_linh_chi)], [2200, 1100], "a full share at a blessed land")
	var below := [{"herb": "xich_huyet_dang", "fit": 1.0}, {"herb": "hoa_linh_chi", "fit": 1.0}]   # rarity 3: under rare_min
	assert_eq(MapProduction.herb_split(gd, below, 3300, true), MapProduction.herb_split(gd, below, 3300), "rarity 3 keeps ω")
