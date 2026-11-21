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
		for t in [1, 2, 3, 4, 5]:
			assert_true(m.crafted.has("pill%d" % t), "%s has pill tier %d" % [m.id, t])
		assert_true(m.crafted.keys().any(func(k): return str(k).begins_with("talisman")), "%s has talisman classes" % m.id)
		assert_true(m.crafted.keys().any(func(k): return str(k).begins_with("artifact")), "%s has artifact classes" % m.id)
		for cid in m.crafted:
			var c: Dictionary = m.crafted[cid]
			assert_true(float(c.get("fill_now", 0.0)) >= 0.0 and float(c.get("fill_now", 0.0)) <= 1.0 + 1e-9, "%s %s fill within 0-1" % [m.id, cid])
			var cfg: Dictionary = gd.file("economy").classes
			assert_true(float(c.p) >= float(cfg.p_min[c.kind]) - 1e-9 and float(c.p) <= float(cfg.p_maxeff[c.kind]) + 1e-9, "%s %s price within its band" % [m.id, cid])
	var money := MoneyLedger.new(db)
	assert_true(money.money_in_world() > 0.0, "the world still has its money")


func test_military_spending_buys_talismans_and_artifacts_formula_h() -> void:
	# Military spending 1,000 (goods half 500) gives artifacts 100 and talismans 50, spread over their tiers
	var gd := game_data()
	var sp := CraftEconomy.specs(gd)
	var heads := [300, 75, 20, 4, 1]
	var art: float = 0.0
	var tal: float = 0.0
	for cid in sp:
		var d: float = CraftEconomy.class_demand(gd, sp[cid], sp, heads, [1, 1, 1, 1, 1], 1000.0)
		if str(sp[cid].kind) == "artifact":
			art += d
		elif str(sp[cid].kind) == "talisman":
			tal += d
	assert_near(art, 100.0, 1e-6, "artifacts")
	assert_near(tal, 50.0, 1e-6, "talismans")


func test_a_talisman_draws_any_material_of_its_rarity() -> void:
	# Phá Cảnh Phù takes 2 materials of rarity 3 or more: its group holds every such material, and none below
	var gd := game_data()
	var sp := CraftEconomy.specs(gd)
	var pc: Dictionary = {}
	for cid in sp:
		for rr in sp[cid].recipes:
			if str(rr.id) == "pha_canh":
				pc = rr
	assert_false(pc.is_empty(), "Phá Cảnh Phù is a crafted recipe")
	assert_true(Array(pc.group).has("linh_moc_tam") and Array(pc.group).has("tu_kim_sa"), "rarity 3 and 4 materials")
	assert_false(Array(pc.group).has("tinh_thiet"), "not a rarity-1 material")


func test_the_plan_at_rest_drifts_toward_demand_formula_f() -> void:
	# Formula F (user decision 2026-11-21): plan_ref' = plan_ref + 0.05 (D - plan_ref); 100 at demand 300 gives 110,
	# and a class whose demand stays at 300 closes half the gap in about 14 seasons
	var cfg: Dictionary = game_data().file("economy")
	assert_near(CraftEconomy.ref_next(cfg, 100.0, 300.0), 110.0, 1e-9, "one season")
	assert_near(CraftEconomy.ref_next(cfg, 100.0, 40.0), 97.0, 1e-9, "it shrinks too")
	var r: float = 100.0
	for i in 14:
		r = CraftEconomy.ref_next(cfg, r, 300.0)
	assert_near(r, 200.0, 5.0, "half the gap in about 3.5 years")
