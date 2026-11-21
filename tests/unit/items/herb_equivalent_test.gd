extends DaoTestSuite
## Herb equivalents (design/gdd/item-database.md Formula B, user decision 2026-11-20): the three-part curve, herb value,
## recipes that count equivalents, and pill quality from ρ (AC-ID-24, AC-ID-97).


func test_the_curve_follows_formula_b() -> void:
	# Hoàng Tinh Sâm (mature 10, base 20): age 5 -> E 0.5, 10 -> 1, 30 -> 1.2, 40 -> 2.4, 60 -> 9.6 (doubling 10 years, D_y)
	var gd := game_data()
	var items := ItemFactory.new(gd)
	var cases := [[5.0, 0.5, 10], [10.0, 1.0, 20], [30.0, 1.2, 24], [40.0, 2.4, 48], [60.0, 9.6, 192]]
	for c in cases:
		var h := items.herb("hoang_tinh_sam", float(c[0]))
		assert_near(items.herb_equivalents(h), float(c[1]), 0.05, "E at age %d" % int(c[0]))
		assert_eq(items.herb_value(h), int(c[2]), "value at age %d" % int(c[0]))
	assert_near(ItemFactory.equivalents_at(gd, "kim_tuy_qua", 42.0), 0.84, 1e-9, "Kim Tủy Quả (mature 50) at 42")


func test_harvesting_at_maturity_beats_waiting_on_the_plateau() -> void:
	# below the knee a standing herb earns s (0.1) a mature-age, a replanted plot 1: the market harvests at maturity
	var gd := game_data()
	for x in [1.5, 2.0, 2.5, 3.0]:
		var e: float = ItemFactory.equivalents_at(gd, "hoang_tinh_sam", 10.0 * x)
		assert_true(e < x, "at %.1f mature-ages a held herb (%.2f) is worth less than the harvests it gave up (%.1f)" % [x, e, x])
	assert_true(ItemFactory.equivalents_at(gd, "hoang_tinh_sam", 60.0) > 6.0, "past the knee waiting pays (6 mature-ages; doubling 10 years)")


func _player_with(herbs: Array) -> Dictionary:
	var gd := game_data()
	var db := WorldDB.new()
	var items := ItemFactory.new(gd)
	var c := TestFixtures.character({"hoa": 60})
	c.id = db.add("people", c.to_dict())
	for h in herbs:
		var it := items.herb(str(h[0]), float(h[1]))
		it["owner_id"] = c.id
		db.add("items", it)
	return {"gd": gd, "db": db, "c": c, "alchemy": Alchemy.new(gd, db, items)}


func test_the_main_herb_is_never_substituted_by_younger_ones() -> void:
	# AC-ID-97 (revised 2026-11-21, Alchemy rules 5 and 11): Trúc Cơ Đan's main herb is 2 Hoàng Tinh Sâm, each >= 40 years,
	# with no substitution; its companion is Fire >= 11 by value, which two mature Hỏa Linh Chi (10 each) fill
	var recipe: Dictionary = game_data().recipe("truc_co_dan")
	var young: Array = []
	for i in 5:
		young.append(["hoang_tinh_sam", 10.0])
	var ok := _player_with(young + [["hoa_linh_chi", 5.0], ["hoa_linh_chi", 5.0]])
	var plan: Dictionary = ok.alchemy.find_ingredients(ok.c, recipe)
	assert_false(plan.ok, "five 10-year roots never stand in for the main herb")
	var old := _player_with([["hoang_tinh_sam", 40.0], ["hoang_tinh_sam", 50.0], ["hoa_linh_chi", 5.0], ["hoa_linh_chi", 5.0]])
	var p2: Dictionary = old.alchemy.find_ingredients(old.c, recipe)
	assert_true(p2.ok, "two roots of 40 and 50 years and Fire 20: %s" % str(p2.missing))
	assert_near(float(p2.put) / float(p2.need), (48.0 + 96.0 + 20.0) / 107.0, 0.01, "ρ 164 / 107: quality rank 1")
