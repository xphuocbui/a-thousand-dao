extends DaoTestSuite
## Character Stats rule 15: every stat key used by data is in the labels table, and the
## data values the GDDs pin down are as written.


func _check(stat: String, where: String) -> void:
	var labels: Dictionary = game_data().file("character_stat_labels").labels
	assert_true(labels.has(stat), "%s in %s" % [stat, where])


func test_every_data_stat_key_has_a_label() -> void:
	var gd := game_data()
	for id in gd.elements_file().variant_effects.keys():
		for fx in gd.elements_file().variant_effects[id]:
			_check(str(fx.stat), "variant %s" % id)
	for p in gd.file("character_edges").perks:
		for fx in p.get("effects", []):
			_check(str(fx.stat), "perk %s" % p.id)
	for b in gd.cong_phap_file().bonus_pool:
		_check(str(b.stat), "bonus pool")
	for t in gd.cong_phap_file().templates:
		for b in t.bonuses:
			_check(str(b.stat), "template %s" % t.id)
	var themes: Dictionary = gd.tree_config().themes
	for k in themes.keys():
		for stat in themes[k].stats:
			_check(str(stat), "theme %s" % k)


func test_the_capability_catalogue_is_complete() -> void:
	var gd := game_data()
	var caps: Array = gd.capabilities()
	assert_eq(caps.size(), 25, "25 entries")
	for i in caps.size():
		assert_eq(int(caps[i].id), i + 1, "ids in order")
		assert_true(str(caps[i].npc_effect.type) in ["chien_luc_mult", "p_step_add", "survive_once", "none"], "closed set")


func test_realm_data_matches_the_gdd_ac58() -> void:
	var gd := game_data()
	var pills: Array = [0.04, 0.045, 0.02, 0.0225]
	var bare: Array = [0.004, 0.0037, 0.0037, 0.003]
	for i in 4:
		var r: Dictionary = gd.realm(i + 1).entry_requirement
		assert_eq(float(r.pill_chance), pills[i], "pill %d" % i)
		assert_eq(float(r.base_chance), bare[i], "bare %d" % i)
	assert_eq(int(gd.ladder().level_cap), 110, "level cap")
	assert_eq(float(gd.ladder().stage_power_step), 0.15, "stage step")
	assert_eq(int(gd.ladder().bare_attempt_cap), 3, "bare cap")


func test_every_breakthrough_pill_has_a_recipe() -> void:
	var gd := game_data()
	for i in range(1, gd.realms().size()):
		var tag: String = str(gd.realm(i).entry_requirement.item_tag)
		assert_false(Advisor.recipe_for_tag(gd, tag).is_empty(), tag)


func test_buying_rounds_up_and_selling_rounds_down_cs_h() -> void:
	var gd := game_data()
	var items := ItemFactory.new(gd)
	var db := WorldDB.new()
	var m := Market.new(gd, db, items)
	var c := TestFixtures.character({"hoa": 50})
	var sheet := StatSheet.build(c, gd, null, null)
	var item := {"kind": "material", "template": "x", "value": 10, "qty": 1}
	assert_eq(m.buy_price(c, sheet, item), 15, "x1.5")
	assert_eq(m.sell_price(c, sheet, item), 6, "x0.6")
