extends DaoTestSuite
## Crafted goods as priced classes (design/gdd/trade-goods.md Formulas E, F, H) against the GDD's worked examples, and the
## pill classes on the built continent.


func test_a_recipes_tier_follows_formula_e() -> void:
	var gd := game_data()
	assert_eq(CraftEconomy.class_of_recipe(gd, gd.recipe("truc_co_dan")), "pill3", "Trúc Cơ Đan (400) is above 20 and 150: tier 3")
	assert_eq(CraftEconomy.class_of_recipe(gd, gd.recipe("tu_khi_dan")), "pill1", "Tụ Khí Đan (12): tier 1")
	assert_eq(CraftEconomy.class_of_recipe(gd, gd.recipe("hoa_than_dan")), "pill5", "Hóa Thần Đan (40,000): tier 5")


func test_basket_demand_follows_formula_h() -> void:
	# 130 Foundation Establishment heads x basket 20 x 0.10 = 260 a season of tier-2 pills
	var gd := game_data()
	assert_near(CraftEconomy.basket_demand(gd, "pill2", [0, 130, 0, 0, 0], [1, 1, 1, 1, 1]), 260.0, 1e-9, "tier 2")
	assert_eq(CraftEconomy.basket_demand(gd, "pill3", [0, 130, 0, 0, 0], [1, 1, 1, 1, 1]), 0.0, "they buy no tier 3")


func test_the_plan_follows_formula_f() -> void:
	# a tier-3 plan of 2,000 (= plan_ref), price 1.30 over inputs 1.02, cover 1.5: plan* 2,257.9, plan' 2,074.1; at
	# cover 3.0: plan* 1,596.6, plan' 1,869.3
	var cfg: Dictionary = game_data().file("economy")
	var a := CraftEconomy.plan_next(cfg, 2000.0, 2000.0, 1.30 / 1.02, 1.5, 1.0)
	assert_near(float(a.star), 2257.9, 0.1, "plan*")
	assert_near(float(a.plan), 2074.1, 0.1, "plan'")
	var b := CraftEconomy.plan_next(cfg, 2000.0, 2000.0, 1.30 / 1.02, 3.0, 1.0)
	assert_near(float(b.star), 1596.6, 0.1, "plan* at cover 3")
	assert_near(float(b.plan), 1869.3, 0.1, "plan' at cover 3")
	assert_eq(float(CraftEconomy.plan_next(cfg, 2000.0, 2000.0, 1.30 / 1.02, 1.5, 0.5).plan), 2000.0, "no windup below fill_tol")


func test_workshops_never_draw_more_than_the_shelves_hold() -> void:
	# a season on the built world: every good's specific draw (the player's and the workshops') is within its pre-draw value
	var gd := game_data()
	var r := RandomNumberGenerator.new()
	r.seed = 7
	var db: WorldDB = WorldBuilder.new(gd, TestFixtures.tree()).generate(r, "7")
	MapProduction.season(gd, db, true)
	WorldEconomy.season(gd, db)
	var ms: Array = db.find(WorldEconomy.TABLE, func(x): return str(x.id).begins_with("mk:"))
	for m in ms:
		assert_eq(m.crafted.keys().size(), 5, "%s has the five pill tiers" % m.id)
		for cid in m.crafted:
			var c: Dictionary = m.crafted[cid]
			assert_true(float(c.get("fill_now", 0.0)) >= 0.0 and float(c.get("fill_now", 0.0)) <= 1.0 + 1e-9, "%s %s fill within 0-1" % [m.id, cid])
			assert_true(float(c.p) >= 0.6 - 1e-9 and float(c.p) <= 2.5 + 1e-9, "%s %s price within its band" % [m.id, cid])
	var money := MoneyLedger.new(db)
	assert_true(money.money_in_world() > 0.0, "the world still has its money")
