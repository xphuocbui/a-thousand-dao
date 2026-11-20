extends DaoTestSuite
## Trade Goods' composition, scarcity and specialty (design/gdd/trade-goods.md Formulas B, C, D) against the GDD's
## worked examples.


func _cfg() -> Dictionary:
	return game_data().file("economy")


func test_bands_follow_rule_8a() -> void:
	assert_eq([TradeGoods.band_of(1), TradeGoods.band_of(2), TradeGoods.band_of(3), TradeGoods.band_of(4), TradeGoods.band_of(5), TradeGoods.band_of(6)],
		[1, 1, 2, 2, 3, 3], "rarity 1-2, 3-4, 5-6")
	assert_eq(TradeGoods.class_of(game_data(), "anh_tam_lien", "herb"), "herb3", "a rarity-5 herb is band 3")
	assert_eq(TradeGoods.class_of(game_data(), "tinh_thiet", "ore"), "ore1", "a rarity-1 ore is band 1")


func test_composition_follows_formula_b() -> void:
	# stock 3,000 (Hỏa Linh Chi share 0.2), own supply 14,463 (Hỏa Linh Chi 1,500), an import of 859 at the exporter's
	# share 0.5, the player sells 120: X = 600 + 1,500 + 429.5 + 120 = 2,649.5; ΣX = 18,442; sh' = 0.1437 (no draw)
	var pool := {"hoa_linh_chi": 600.0, "other": 2400.0}
	var own := {"hoa_linh_chi": 1500.0, "other": 12963.0}
	var imp := {"hoa_linh_chi": 429.5, "other": 429.5}
	var v := {"hoa_linh_chi": 10.0, "other": 2.0}
	var r := TradeGoods.compose(_cfg(), pool, own, imp, {"hoa_linh_chi": 120.0}, {}, 0.0, 0.0, v)
	var tot: float = 0.0
	for g in r.pool:
		tot += float(r.pool[g])
	assert_near(float(r.pool.hoa_linh_chi), 2649.5, 0.01, "X of Hỏa Linh Chi")
	assert_near(tot, 18442.0, 0.01, "ΣX")
	assert_near(float(r.pool.hoa_linh_chi) / tot, 0.1437, 0.0001, "sh'")


func test_the_shared_draw_never_touches_an_unshelved_good() -> void:
	# a rare good under one unit builds up instead of being drawn down (rule 6, design-review 3)
	var v := {"cheap": 2.0, "rare": 900.0}
	var r := TradeGoods.compose(_cfg(), {"cheap": 1000.0, "rare": 300.0}, {"cheap": 500.0, "rare": 100.0}, {}, {}, {}, 1200.0, 0.0, v)
	assert_near(float(r.pool.rare), 400.0, 1e-6, "300 + 100, untouched by the draw")
	assert_near(float(r.pool.cheap), 300.0, 1e-6, "1,500 less the 1,200 draw")


func test_scarcity_follows_formula_d() -> void:
	# a herb band-2 class of Băng Tâm Thảo (world share 0.04) and Xích Huyết Đằng (0.96): at its source (0.15 / 0.85)
	# Băng Tâm Thảo 0.811 and Xích Huyết Đằng 1.033; where it is absent, Băng Tâm Thảo 1.505 and Xích Huyết Đằng 1.000
	var cfg := _cfg()
	var wsh := {"btt": 0.04, "xhd": 0.96}
	var v := {"btt": 1.0, "xhd": 1.0}
	var src := TradeGoods.scarcity(cfg, {"btt": 150.0, "xhd": 850.0}, wsh, v)
	assert_near(float(src.btt), 0.811, 0.001, "at its source")
	assert_near(float(src.xhd), 1.033, 0.001, "the common good at that source")
	var none := TradeGoods.scarcity(cfg, {"xhd": 1000.0}, wsh, v)
	assert_near(float(none.btt), 1.505, 0.001, "where it is absent")
	assert_near(float(none.xhd), 1.000, 0.001, "the only shelved good")


func test_specialty_follows_formula_c() -> void:
	# Băng Tâm Thảo making 2,400 / 900 / 300 / 150 / 40 in five regions: the bar is 240, three regions pass
	var by := {"r1": {"btt": 2400.0}, "r2": {"btt": 900.0}, "r3": {"btt": 300.0}, "r4": {"btt": 150.0}, "r5": {"btt": 40.0}}
	var sp := TradeGoods.specialties(_cfg(), by, {"btt": 60.0})
	assert_eq(sp.get("btt", []), ["r1", "r2", "r3"], "a specialty of three regions")
