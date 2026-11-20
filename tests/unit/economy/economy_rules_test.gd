extends DaoTestSuite
## Regional Economy & Trade's formulas against the GDD's worked examples (design/gdd/regional-economy-trade.md,
## Formulas A-L2). The examples' inputs are the fixture; the shipped economy.json supplies the parameters, which are
## the GDD's guesses.


func _cfg() -> Dictionary:
	return game_data().file("economy").duplicate(true)


func test_access_follows_formula_a() -> void:
	# 150 tiles, Trade 6, Military 6, peace
	var a := EconomyRules.access(_cfg(), 150.0, 6, 6, false)
	assert_near(a.reach, 0.7292, 0.0001, "e^-0.316")
	assert_near(a.safe, 0.9836, 0.0001, "1 - 0.1 x 0.606 x 0.271")
	assert_near(a.acc, 0.7172, 0.0001, "acc")


func test_supply_follows_formula_b() -> void:
	# herbs: seat 12,000 (acc 1) + a region of 8,000 at acc 0.7172, Holdings 6 (collect 0.3231), imports 1,200
	var cfg := _cfg()
	assert_near(EconomyRules.h_f(cfg, 0.3231), 0.8154, 0.0001, "h_f")
	assert_near(EconomyRules.supply(cfg, 0.3231, 12000.0 + 8000.0 * 0.7172, 0.0, 1200.0), 15663.2, 0.5, "15,663.2")


func test_demand_follows_formula_c() -> void:
	# heads 600 / 130 / 30 / 5 / 1, 60 settlement weight, bmix[herb] 0.5 (the example's), d_scale 2.2, Institutions
	# 327, the player's 400
	var cfg := _cfg()
	cfg.classes.bmix.herb = 0.5
	var need := EconomyRules.population_need(cfg, "herb", [600, 130, 30, 5, 1], [1, 1, 1, 1, 1], 60.0)
	assert_eq(need, 13025.0, "10,025 + 3,000")
	assert_near(EconomyRules.demand(cfg, "herb", 2.2, need, 0.0, 327.0, 0.0, 0.0, 400.0), 14891.0, 0.5, "14,891")


func test_subsistence_floor_keeps_staple_need_when_purses_are_empty() -> void:
	var cfg := _cfg()
	assert_eq(EconomyRules.population_need(cfg, "herb", [100], [0.0], 0.0), 150.0, "herb: half a basket of need at fill 0")
	assert_eq(EconomyRules.population_need(cfg, "ore", [100], [0.0], 0.0), 0.0, "ore has no floor")


func test_stock_follows_formula_d() -> void:
	var s := EconomyRules.stock_update(_cfg(), "herb", 3000.0, 15663.2, 14891.0, 1.0)
	assert_near(s.stock, 3017.76, 0.01, "0.80 x (3,000 + 15,663.2 - 14,891)")
	assert_eq(s.short, 0.0, "no shortage")


func test_price_follows_formula_e() -> void:
	var e := EconomyRules.price(_cfg(), "herb", 1.0, 3000.0, 15663.2, 14891.0, 1.0)
	assert_near(e.cover, 1.2533, 0.0001, "cover")
	assert_near(e.p_star, 1.1341, 0.0001, "P*")
	assert_near(e.p, 1.0649, 0.0001, "P' after alpha")


func test_price_moves_at_most_delta_a_season() -> void:
	var e := EconomyRules.price(_cfg(), "ore", 1.0, 0.0, 0.0, 1000.0, 1.0)
	assert_near(e.p, 1.10, 0.0001, "an empty ore market rises by delta 1.10 at most")


func test_link_flow_follows_formula_f() -> void:
	# herbs: P_A 0.90, D_A 20,000, cover 1.25; P_B 1.30, D_B 15,000, cover 1.0; Openness 2; 200 tiles; trade_mult
	# 1.9 / 1.6; safe 0.97
	var cfg := _cfg()
	var f := EconomyRules.link_flow(cfg, "herb", 0.90, 1.30, 1.25, 1.0, 20000.0, 15000.0, 1.0, 2, 200.0, 1.9, 1.6, 1e9)
	assert_near(f.tau, 0.10714, 0.00001, "tau")
	assert_near(f.gap, 0.14757, 0.00001, "gap")
	assert_near(f.q_close, 1718.6, 0.5, "Q_close")
	assert_near(f.q, 859.3, 0.5, "beta x Q_close")
	assert_near(EconomyRules.link_capacity(cfg, 1.9, 1.6, 0.97), 9312.0, 0.01, "Cap")
	assert_near(EconomyRules.tariff(cfg, 2) * 1.30 * f.q, 134.1, 0.1, "tariff to B")


func test_shop_prices_follow_formula_g() -> void:
	var cfg := _cfg()
	assert_eq(EconomyRules.buy_price(cfg, 120.0, 1.065, true, "village"), 162, "a V 120 herb at P 1.065 in a village")
	assert_eq(EconomyRules.sell_price(cfg, 120.0, 1.30, true, "city", 50, 0, 1.0, 0.12), 123, "carried to a city in B")
	assert_eq(EconomyRules.buy_price(cfg, 120.0, 1.065, true, "city"), 141, "bought in a city instead")
	assert_eq(EconomyRules.sell_price(cfg, 120.0, 1.0, true, "city", 50, 0, 1.0, 0.0, EconomyRules.slip(cfg, "herb", 0.0, 120.0, 2000.0)), 103, "first sale, slip 0.960")
	assert_eq(EconomyRules.sell_price(cfg, 120.0, 1.0, true, "city", 50, 0, 1.0, 0.0, EconomyRules.slip(cfg, "herb", 1000.0, 120.0, 2000.0)), 79, "after 1,000 sold")
	assert_eq(EconomyRules.sell_price(cfg, 120.0, 1.0, true, "city", 50, 0, 1.0, 0.0, EconomyRules.slip(cfg, "herb", 2000.0, 120.0, 2000.0)), 65, "after 2,000 sold")


func test_buying_and_selling_at_one_place_never_pays() -> void:
	var cfg := _cfg()
	for kind in ["city", "town", "village"]:
		assert_true(EconomyRules.buy_price(cfg, 100.0, 1.0, true, kind) > EconomyRules.sell_price(cfg, 100.0, 1.0, true, kind), "raw at a %s" % kind)
		assert_true(EconomyRules.buy_price(cfg, 100.0, 1.0, false, kind, 100, 100) > EconomyRules.sell_price(cfg, 100.0, 1.0, false, kind, 100, 100), "finished at a %s, charm and standing at their limits" % kind)


func test_local_price_follows_formula_l1() -> void:
	var cfg := _cfg()
	assert_near(EconomyRules.local_price(cfg, "herb", 1.065, 8000.0, 2000.0, 0.5), 0.656, 0.001, "a herb region at access 0.5")
	assert_near(EconomyRules.local_price(cfg, "ore", 1.0, 500.0, 3000.0, 0.5), 1.43, 0.005, "an ore-short region")
	assert_near(EconomyRules.local_price(cfg, "herb", 1.065, 8000.0, 2000.0, 0.5, 1.0, 0.0, 2000.0), 0.836, 0.001, "after the player bought 2,000")
	assert_near(EconomyRules.local_price(cfg, "ore", 1.0, 500.0, 3000.0, 0.5, 1.0, 2000.0, 0.0), 1.037, 0.001, "after the player sold 2,000")
	assert_eq(EconomyRules.local_price(cfg, "herb", 1.2, 9000.0, 10.0, 1.0), 1.2, "at the seat the local price is the market's")


func test_treasury_rule_follows_formula_h() -> void:
	# R 40,000 (Cost 10,000), treasury 60,000, Inc = Cost
	var t := EconomyRules.treasury_invest(_cfg(), 60000.0, 10000.0, 10000.0)
	assert_eq(t.invest, 10000.0, "0.5 x 20,000")
	assert_eq(t.missions, 5000.0, "reserved for missions")
	assert_eq(t.track_cash, 2500.0, "burned")
	assert_eq(t.track_kind, 2500.0, "in kind")
	assert_eq(60000.0 - t.cash_out, 52500.0, "the treasury ends at 52,500")
	assert_eq(EconomyRules.treasury_invest(_cfg(), 40000.0, 10000.0, 10000.0).invest, 0.0, "at the reserve nothing is invested")


func test_sect_income_follows_formula_i() -> void:
	var cfg := _cfg()
	var cm := EconomyRules.collect_mine(cfg, 0.323)
	assert_near(cm, 0.6615, 0.00001, "collect_mine")
	assert_near(12000.0 * cm, 7938.0, 0.01, "Inc_mine")
	var g := EconomyRules.goods_income(cfg, 0.323 * 38000.0, 5000.0, 1100.0, 1.05)
	assert_near(g.income, 5834.0, 0.5, "6,174 sold at 1.05 x 0.90")


func test_stone_cultivation_follows_formula_j() -> void:
	# a Core Formation NPC (rate 200, reserve 1,200) with 3,000 stones; basket 50
	var cfg := _cfg()
	var sp := EconomyRules.npc_spend(cfg, 2, 3000.0, 50.0)
	assert_eq(sp.basket_spend, 50.0, "the basket first")
	assert_eq(sp.fill, 1.0, "a full basket")
	assert_near(sp.prov, 0.15, 1e-9, "+15 %")
	assert_eq(sp.stones, 525.0, "0.3 x (1,800 - 50)")
	assert_eq(EconomyRules.stone_tu_vi(cfg, 2, sp.stones, 200.0).tu_vi, 26.25, "525 / 20")
	assert_eq(EconomyRules.stone_tu_vi(cfg, 2, 99999.0, 200.0).spent, 2000.0, "the cap: 100 tu vi x 20 stones")


func test_loot_is_drawn_from_a_holder_formula_k() -> void:
	assert_eq(EconomyRules.loot_grant(300000.0, 40000.0), 40000.0, "a Hoa Than budget against a 40,000 stash")
