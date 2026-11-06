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


func test_buying_the_last_talisman_merges_into_the_owned_stack_ac_id_31() -> void:
	var gd := game_data()
	var db := WorldDB.new()
	var items := ItemFactory.new(gd)
	var m := Market.new(gd, db, items)
	var c := TestFixtures.character({"hoa": 50})
	c.id = "p1"
	c.linh_thach = 10000
	var pid: String = db.add("places", {"name": "Thử Thành", "market": true})
	var own: Dictionary = items.talisman("hoa_cau", 1)
	own["owner_id"] = c.id
	var own_id: String = db.add("items", own)
	var stock: Dictionary = items.talisman("hoa_cau", 1)
	stock["owner_id"] = Market.owner_of(pid)
	var stock_id: String = db.add("items", stock)
	var r: Dictionary = m.buy(c, StatSheet.build(c, gd, db, null), pid, stock_id)
	assert_true(r.ok, "bought")
	assert_eq(r.item_id, own_id, "merged into the owned stack")
	assert_eq(int(db.get_record("items", own_id).qty), 2, "one stack of two")
	assert_eq(db.items_of(c.id).size(), 1, "no second record")


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


func test_the_market_never_stocks_a_breakthrough_main_herb_ac71() -> void:
	# Regression (design review 2026-11-05): ripe ginseng and Kim Tủy Quả bypassed Formulas D.
	var gd := game_data()
	var db := WorldDB.new()
	var m := Market.new(gd, db, ItemFactory.new(gd))
	var barred: Array = ["hoang_tinh_sam", "kim_tuy_qua", "anh_tam_lien", "hoa_than_qua"]
	var companions: int = 0
	for seed_v in 120:
		var pid: String = db.add("places", {"name": "Thử Thành", "market": true})
		m.ensure_stock(rng(seed_v), pid, 300, 0)
		for it in m.stock(pid):
			if it.kind != "herb":
				continue
			assert_false(barred.has(it.template), "%s is a main herb" % it.template)
			if it.template == "hoa_linh_chi":
				companions += 1
	assert_true(companions > 0, "companion herbs are still sold")


func test_main_herbs_are_derived_from_the_breakthrough_recipes_ac71() -> void:
	var main: Array = Market.breakthrough_main_herbs(game_data())
	main.sort()
	assert_eq(main, ["anh_tam_lien", "hoa_than_qua", "hoang_tinh_sam", "kim_tuy_qua"], "one per recipe, no companions")
