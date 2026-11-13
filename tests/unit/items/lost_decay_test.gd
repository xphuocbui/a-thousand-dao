extends DaoTestSuite
## Item Database rule 7 / Formulas A (the rarity ladder), rule 14 (Lost-item decay, AC-ID-92) and rule 20e (Markets
## never stock a named item, AC-ID-91). Data: items_rarity.json.


func _lost(db: WorldDB, fields: Dictionary) -> String:
	var rec := {"kind": "artifact", "name": "Bảo", "grade": 1, "owner_id": "l1", "lost": true, "lost_since": 0}
	rec.merge(fields, true)
	return db.add("items", rec)


func test_the_rarity_ladder_matches_formulas_a() -> void:
	var gd := game_data()
	assert_eq(ItemRarity.of(gd, {"kind": "pill", "template": "truc_co_dan"}), 4, "Trúc Cơ Đan: band 3 + 1")
	assert_eq(ItemRarity.of(gd, {"kind": "artifact", "grade": 4}), 5, "a Cực artifact is rarity 5")
	assert_eq(ItemRarity.of(gd, {"kind": "artifact", "grade": 0}), 1, "a Phàm artifact is rarity 1")
	assert_eq(ItemRarity.of(gd, {"kind": "cong_phap", "tier": 3}), 5, "a Thiên manual is rarity 5")


func test_an_ordinary_lost_item_decays_in_year_30() -> void:
	# AC-ID-92: rarity 2 (grade 1), Lost since year 0, with lost_decay_years 30.
	var gd := game_data()
	var db := WorldDB.new()
	var wait: int = int(gd.file("items_rarity").lost_decay_years)
	var item: String = _lost(db, {})
	ItemRarity.decay_lost(gd, db, wait - 1)
	assert_true(db.has_record("items", item), "still there a year early")
	var gone: Array = ItemRarity.decay_lost(gd, db, wait)
	assert_false(db.has_record("items", item), "removed on time")
	assert_eq(gone.size(), 1, "and reported")


func test_an_item_picked_up_never_decays() -> void:
	var gd := game_data()
	var db := WorldDB.new()
	var item: String = _lost(db, {})
	var finder: String = db.add("people", {"name": "Tìm", "alive": true})
	db.give_item(item, finder)
	ItemRarity.decay_lost(gd, db, 100)
	assert_true(db.has_record("items", item), "owned, so it never decays")
	assert_false(db.get_record("items", item).has("lost"), "no longer Lost")


func test_named_bound_reserved_and_rare_lost_items_never_decay() -> void:
	var gd := game_data()
	var db := WorldDB.new()
	var keep: Array = [_lost(db, {"named": "x"}), _lost(db, {"bound": true}), _lost(db, {"reserved": true}),
		_lost(db, {"grade": 3})]
	ItemRarity.decay_lost(gd, db, 100)
	for id in keep:
		assert_true(db.has_record("items", id), "kept %s" % id)


func test_an_unstamped_lost_item_starts_its_count_at_the_first_check() -> void:
	var gd := game_data()
	var db := WorldDB.new()
	var item: String = _lost(db, {})
	db.get_record("items", item).erase("lost_since")
	ItemRarity.decay_lost(gd, db, 300)
	assert_eq(int(db.get_record("items", item).lost_since), 300, "stamped now")
	ItemRarity.decay_lost(gd, db, 329)
	assert_true(db.has_record("items", item), "lasts its full span from then")


func test_markets_never_stock_a_named_item() -> void:
	# AC-ID-91 (rule 20e): stock generation and restock over 100 years make no named item.
	var gd := game_data()
	var db := WorldDB.new()
	var market := Market.new(gd, db, ItemFactory.new(gd))
	var place: String = db.add("places", {"name": "Chợ", "market": true, "region_id": "r1"})
	var r := RandomNumberGenerator.new()
	r.seed = 9
	for year in 100:
		market.ensure_stock(r, place, year, 2)
	assert_true(market.stock(place).size() > 0, "the market stocked something")
	for it in db.all("items"):
		assert_eq(str(it.get("named", "")), "", "no named item in stock")
