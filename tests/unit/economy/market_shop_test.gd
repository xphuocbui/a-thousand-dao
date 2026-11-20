extends DaoTestSuite
## Shops on the continent (design/gdd/regional-economy-trade.md rules 15-17, Formula G, Formula H's payers): raw goods
## at the bulk spread and the region's local price, money through the market's commons pool, sell slippage, and the
## player's trades entering the market's books. One world is built for the suite; each test works on its own copy.

var _base: Dictionary = {}


func before() -> void:
	var r := RandomNumberGenerator.new()
	r.seed = 7
	_base = WorldBuilder.new(game_data(), TestFixtures.tree()).generate(r, "7").to_dict()


func _setup() -> Dictionary:
	var gd := game_data()
	var db := WorldDB.from_dict(_base.duplicate(true))
	MapProduction.season(gd, db, true)
	WorldEconomy.season(gd, db)
	var place: Dictionary = db.find("places", func(p): return bool(p.get("market", false)) and str(p.get("kind", "")) == "city")[0]
	var c := TestFixtures.character({"moc": 50})
	c.id = "p_test"
	c.location_id = str(place.id)
	c.linh_thach = 5000
	var items := ItemFactory.new(gd)
	return {"gd": gd, "db": db, "place": place, "c": c, "items": items, "market": Market.new(gd, db, items), "sheet": StatSheet.new()}


func _give(f: Dictionary, item: Dictionary) -> String:
	item["owner_id"] = f.c.id
	return f.db.add("items", item)


func test_a_raw_herb_sells_at_the_bulk_spread_and_the_local_price() -> void:
	var f := _setup()
	var cfg: Dictionary = f.gd.file("economy")
	var herb: Dictionary = f.items.herb("hoa_linh_chi", 10.0)
	var id := _give(f, herb)
	var v: float = float(f.items.value_of(herb))
	var p_loc: float = WorldEconomy.local_price(f.db, str(f.place.region_id), "herb")
	var expected: int = EconomyRules.sell_price(cfg, v, p_loc, true, "city", 50, 0, 1.0, 0.0,
		EconomyRules.slip(cfg, "herb", 0.0, v, f.market._place_demand(f.market._shop_ctx(herb, f.place))))
	assert_eq(f.market.sell_price(f.c, f.sheet, f.db.get_record("items", id), str(f.place.id)), expected, "Formula G")
	assert_true(expected > int(v * float(f.gd.session().market.sell_ratio) * p_loc), "raw goods sell above the old retail ratio 0.6")


func test_a_sale_is_paid_by_the_commons_pool_and_conserves_money() -> void:
	var f := _setup()
	var money := MoneyLedger.new(f.db, f.c)
	money.open_season()
	var sect: String = str(f.db.get_record(WorldEconomy.TABLE, WorldEconomy.market_of_region(f.db, f.db.get_record("regions", str(f.place.region_id)))).sect_id)
	var pool_before: float = money.balance("pool:%s" % sect)
	var id := _give(f, f.items.herb("hoang_tinh_sam", 20.0))
	var purse: int = f.c.linh_thach
	var r: Dictionary = f.market.sell(f.c, f.sheet, str(f.place.id), id)
	assert_true(r.ok, r.message)
	var paid: int = f.c.linh_thach - purse
	assert_true(paid > 0, "the player was paid")
	assert_near(money.balance("pool:%s" % sect), pool_before - paid, 1e-6, "the pool paid it")
	assert_near(money.season_check().gap, 0.0, 1e-6, "ΔM = −player_net")


func test_selling_more_of_a_class_at_one_place_fetches_less_each_time() -> void:
	# Formula G's slippage: q_sold grows within the season
	var f := _setup()
	var prices: Array = []
	for i in 4:
		var id := _give(f, f.items.herb("xich_huyet_dang", 30.0))
		prices.append(f.market.sell_price(f.c, f.sheet, f.db.get_record("items", id), str(f.place.id)))
		f.market.sell(f.c, f.sheet, str(f.place.id), id)
	assert_true(int(prices[3]) < int(prices[0]), "the fourth sale fetches less than the first (%s)" % str(prices))


func test_a_purchase_enters_the_markets_books() -> void:
	var f := _setup()
	f.market.ensure_stock(rng(3), str(f.place.id), 0, 0)
	var raw: Array = f.market.stock(str(f.place.id)).filter(func(it): return str(it.kind) == "herb")
	assert_false(raw.is_empty(), "the shop stocks herbs")
	var it: Dictionary = raw[0]
	var r: Dictionary = f.market.buy(f.c, f.sheet, str(f.place.id), str(it.id))
	assert_true(r.ok, r.message)
	var m: Dictionary = f.db.get_record(WorldEconomy.TABLE, WorldEconomy.market_of_region(f.db, f.db.get_record("regions", str(f.place.region_id))))
	assert_true(float(m.player.get("buy", {}).get("herb", 0.0)) > 0.0, "the purchase counts toward P_eff")


func test_a_pool_that_cannot_pay_the_whole_price_does_not_buy() -> void:
	# a part-paid sale would hand the item over for the pool's last stones
	var f := _setup()
	var sect: String = str(f.db.get_record(WorldEconomy.TABLE, WorldEconomy.market_of_region(f.db, f.db.get_record("regions", str(f.place.region_id)))).sect_id)
	var money := MoneyLedger.new(f.db, f.c)
	money.burn("pool:%s" % sect, money.balance("pool:%s" % sect) - 7.0, "test")
	var id := _give(f, f.items.herb("bang_tam_thao", 30.0))
	var purse: int = f.c.linh_thach
	var r: Dictionary = f.market.sell(f.c, f.sheet, str(f.place.id), id)
	assert_false(r.ok, "refused: %s" % r.message)
	assert_eq(f.c.linh_thach, purse, "no stones moved")
	assert_false(f.db.get_record("items", id).is_empty(), "the herb is still the player's")
	assert_eq(money.balance("pool:%s" % sect), 7.0, "the pool keeps its 7")


func test_the_first_sale_of_a_new_world_has_almost_no_slippage() -> void:
	# a regression: before the first season ticked, a region's own demand was unknown, so Dp was 1 and the first small
	# sale lost most of its price to slippage (a 5-stone herb sold for 1)
	var gd := game_data()
	var db := WorldDB.from_dict(_base.duplicate(true))
	var place: Dictionary = db.find("places", func(p): return bool(p.get("market", false)) and str(p.get("kind", "")) == "city")[0]
	var items := ItemFactory.new(gd)
	var market := Market.new(gd, db, items)
	var herb: Dictionary = items.herb("ngung_khi_thao", 8.0)
	var ctx: Dictionary = market._shop_ctx(herb, place)
	assert_true(market._place_demand(ctx) > 100.0, "a city's share of its region's herb demand is known at season 0")
	assert_true(EconomyRules.slip(gd.file("economy"), "herb", 0.0, float(items.value_of(herb)), market._place_demand(ctx)) > 0.95, "a first small sale keeps 95 % or more")
