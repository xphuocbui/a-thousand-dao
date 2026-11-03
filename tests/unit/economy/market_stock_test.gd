extends DaoTestSuite
## Market: stock fits the realm budget.


func test_luyen_khi_market_sells_no_late_game_pills() -> void:
	# Regression: a starting town sold Diên Thọ Đan (price 5000) to a Luyện Khí player.
	var gd := game_data()
	var db := WorldDB.new()
	var items := ItemFactory.new(gd)
	var m := Market.new(gd, db, items)
	var cap: float = float(gd.realm_budget(0).pill_price_max) * float(gd.session().market.stock_pill_price_budget_mult)
	for seed_v in 30:
		var pid: String = db.add("places", {"name": "Thử Thành", "market": true})
		m.ensure_stock(rng(seed_v), pid, 300, 0)
		for it in m.stock(pid):
			if it.kind != "pill":
				continue
			var r: Dictionary = gd.recipe(it.template)
			if r.effect.type == "breakthrough":
				assert_eq(str(r.effect.tag), "truc_co_dan", "only the next realm's breakthrough pill")
			else:
				assert_true(float(r.price) <= cap, "%s price %d over cap %d" % [r.name, int(r.price), int(cap)])


func test_buy_moves_item_and_charges_price() -> void:
	var gd := game_data()
	var db := WorldDB.new()
	var items := ItemFactory.new(gd)
	var m := Market.new(gd, db, items)
	var c := TestFixtures.character({"hoa": 50})
	c.id = db.add("people", c.to_dict())
	c.linh_thach = 10000
	var pid: String = db.add("places", {"name": "Thử Thành", "market": true})
	m.ensure_stock(rng(1), pid, 300, 0)
	var it: Dictionary = m.stock(pid).filter(func(x): return x.kind == "artifact")[0]
	var price: int = m.buy_price(c, StatSheet.new(), it)
	var r: Dictionary = m.buy(c, StatSheet.new(), pid, it.id)
	assert_true(r.ok, r.message)
	assert_eq(c.linh_thach, 10000 - price, "charged")
	assert_eq(db.get_record("items", it.id).owner_id, c.id, "owned")
