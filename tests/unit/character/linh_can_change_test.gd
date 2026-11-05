extends DaoTestSuite
## Root changes (design/gdd/linh-can.md rule 13, Formulas F): Tẩy Tủy Đan and Linh Căn Quả.


func _session(purities: Dictionary = {"hoa": 70, "moc": 30}) -> GameSession:
	var gd := game_data()
	var llm := LlmService.new(gd)
	llm.enabled = false
	var s := GameSession.new(gd, llm, TestFixtures.tree())
	s.new_game(4242, {"mode": "custom", "name": "Đổi", "gender": "male", "origin": "tan_tu",
		"thien_phu": {}, "purities": purities, "variants": []})
	s.pending_event = {}
	return s


func _fruit() -> Dictionary:
	return game_data().treasure("linh_can_qua").effect


func _c(elements: Dictionary, variants: Dictionary = {}) -> Character:
	var c := TestFixtures.character(elements)
	c.linh_can.variants = variants
	return c


func test_gain_is_at_least_one_ac37() -> void:
	assert_eq(PillEffects.purity_gain(6.0, 1.25), 8, "round(7.5)")
	assert_eq(PillEffects.purity_gain(6.0, 0.05), 1, "floor of one")
	assert_eq(PillEffects.purity_gain(6.0, 0.0), 1, "zero potency")


func test_weakest_ties_go_in_cycle_order_ac37() -> void:
	var gd := game_data()
	assert_eq(_c({"hoa": 30, "kim": 50, "thuy": 30}).linh_can.weakest_element(gd), "hoa", "Fire before Water")
	assert_eq(_c({"thuy": 30, "moc": 30}).linh_can.weakest_element(gd), "moc", "Wood first")
	assert_eq(_c({"hoa": 40, "kim": 50}, {"phong": 12}).linh_can.weakest_element(gd), "hoa", "variants are not candidates")


func test_raising_recomputes_derived_variants_only_ac38() -> void:
	var gd := game_data()
	var lc: LinhCan = _c({"hoa": 86, "kim": 40}, {"loi": 47, "quang": 69, "phong": 60}).linh_can
	lc.raise_purity(gd, "kim", 8)
	assert_eq(lc.variants, {"loi": 51, "quang": 69, "phong": 60}, "Thunder follows, the rest stay")


func test_tay_tuy_dan_raises_the_weakest_and_stops_at_the_limit_ac39() -> void:
	var s := _session()
	var c: Character = s.player
	var max_uses: int = int(s.gd.recipe("tay_tuy_dan").effect.max_uses)
	var pid: String = s.alchemy.add_pills(c, "tay_tuy_dan", 0, max_uses + 1)
	var hoa_before: float = c.linh_can.purity("hoa")
	var moc_before: float = c.linh_can.purity("moc")
	var r: Dictionary = s.use_item(pid)
	assert_true(r.ok, "used: %s" % str(r.lines))
	assert_true(c.linh_can.purity("moc") > moc_before, "Wood rose")
	assert_eq(c.linh_can.purity("hoa"), hoa_before, "Fire unchanged")
	for i in max_uses - 1:
		c.dan_doc = 0.0
		s.use_item(pid)
	c.dan_doc = 0.0
	var events_before: int = s.db.count("events")
	var purity_before: float = c.linh_can.purity("moc")
	assert_false(s.use_item(pid).ok, "refused after %d uses" % max_uses)
	assert_eq(int(s.db.get_record("items", pid).qty), 1, "the refused pill is kept")
	assert_eq(c.linh_can.purity("moc"), purity_before, "no purity change")
	assert_eq(s.db.count("events"), events_before, "no record")


func test_tay_tuy_dan_is_refused_on_a_perfect_root_ac39() -> void:
	var s := _session({"hoa": 100})
	var pid: String = s.alchemy.add_pills(s.player, "tay_tuy_dan", 0, 1)
	assert_false(s.use_item(pid).ok, "refused at 100")
	assert_eq(int(s.player.pill_uses.get("tay_tuy_dan", 0)), 0, "does not count toward the three")


func test_fruit_with_a_named_element_makes_no_element_draw_ac40() -> void:
	var gd := game_data()
	var c := _c({"hoa": 86, "moc": 40})
	c.linh_can.rolled = ["phong", "huyet", "hu_khong", "quang"]
	# 8/16 of the way through 20..35 is 28; forced success on Thunder.
	var r := ScriptedRng.new(["U", 0.5, "U", 0.0])
	var res: Dictionary = TreasureEffects.apply_fruit(c, gd, r, _fruit(), "kim")
	assert_true(res.ok and r.done(), "draws exact: %s" % r.error)
	assert_eq(c.linh_can.elements.kim, 28, "Metal 28")
	assert_eq(c.linh_can.variants, {"loi": 39}, "Thunder 39; Light does not roll")
	assert_eq(c.linh_can.generating_pairs(gd).size(), 1, "pairs stay at 1")


func test_fruit_ignores_an_owned_named_element_ac40() -> void:
	var gd := game_data()
	var c := _c({"hoa": 86})
	# Missing in cycle order: moc, tho, kim, thuy; 0.9 picks Water, then purity, then Ice, Light has rolled.
	c.linh_can.rolled = ["phong", "huyet", "hu_khong", "quang"]
	var r := ScriptedRng.new(["U", 0.9, "U", 0.0, "U", 0.99])
	TreasureEffects.apply_fruit(c, gd, r, _fruit(), "hoa")
	assert_true(r.done(), "element draw made: %s" % r.error)
	assert_true(c.linh_can.elements.has("thuy"), "Water added, not Fire")
	assert_eq(c.linh_can.elements.thuy, 20, "lowest purity")


func test_fifth_element_rolls_three_derived_variants_in_order_ac41() -> void:
	var gd := game_data()
	var c := _c({"moc": 50, "hoa": 60, "tho": 50, "kim": 40})
	c.linh_can.rolled = ["phong", "huyet", "hu_khong", "loi", "quang"]
	var r := ScriptedRng.new(["U", 10.0 / 16.0, "U", 0.0, "U", 0.0, "U", 0.0])
	TreasureEffects.apply_fruit(c, gd, r, _fruit(), "thuy")
	assert_true(r.done(), "three rolls: %s" % r.error)
	assert_eq(c.linh_can.variants, {"am": 31, "hon_don": 36, "bang": 24}, "Darkness, Chaos, Ice")
	assert_eq(c.linh_can.tier_name(gd), "Five-element root", "tier")
	assert_eq(c.linh_can.generating_pairs(gd).size(), 5, "pairs")


func test_innate_variants_never_roll_later_ac42() -> void:
	var gd := game_data()
	var c := _c({"hoa": 50, "kim": 50}, {"hu_khong": 75})
	c.linh_can.rolled = ["phong", "huyet", "hu_khong", "loi", "quang"]
	var r := ScriptedRng.new(["U", 0.0, "U", 0.99])
	TreasureEffects.apply_fruit(c, gd, r, _fruit(), "thuy")
	assert_true(r.done(), "only Ice rolls: %s" % r.error)
	assert_eq(c.linh_can.variants.hu_khong, 75, "Void kept past two elements")
	assert_eq(c.linh_can.n_eff(gd), 4, "n_base 3 + Void")


func test_all_five_owned_raises_the_weakest_with_no_rolls_ac43() -> void:
	var gd := game_data()
	var c := _c({"moc": 50, "hoa": 30, "tho": 60, "kim": 30, "thuy": 90}, {"loi": 24})
	var r := ScriptedRng.new([])
	TreasureEffects.apply_fruit(c, gd, r, _fruit(), "tho")
	assert_eq(c.linh_can.elements.hoa, 38, "Fire, by cycle order, even with a named element")
	assert_eq(c.linh_can.variants.loi, 27, "Thunder recomputed")
	assert_eq(r.log.size(), 0, "no draw")
	var perfect := _c({"moc": 100, "hoa": 100, "tho": 100, "kim": 100, "thuy": 100})
	assert_false(TreasureEffects.apply_fruit(perfect, gd, r, _fruit()).ok, "refused at 100")


func test_no_change_ever_removes_anything_ac44() -> void:
	var gd := game_data()
	var r := rng(44)
	for i in 1000:
		var c := Character.new()
		c.linh_can = LinhCan.roll(gd, r)
		var before: Dictionary = c.linh_can.to_dict()
		for step in 4:
			match r.randi_range(0, 2):
				0: c.linh_can.raise_purity(gd, c.linh_can.weakest_element(gd), 8)
				1: TreasureEffects.apply_fruit(c, gd, r, _fruit())
				2: c.linh_can.awakening_pass(gd, r)
		for e in before.elements.keys():
			assert_true(c.linh_can.elements[e] >= before.elements[e] and c.linh_can.elements[e] <= 100, "element kept")
		for v in before.variants.keys():
			assert_true(c.linh_can.variants.has(v), "variant kept")


func test_accepted_changes_write_one_record_each_ac45() -> void:
	var s := _session()
	var before: int = s.db.count("events")
	var t: Dictionary = s.items.treasure("linh_can_qua")
	assert_false(t.has("element"), "the fruit holds no element until it is used")
	t["owner_id"] = s.player.id
	var tid: String = s.db.add("items", t)
	var missing: Array = s.gd.element_cycle().filter(func(e): return not s.player.linh_can.has(e))
	var ask: Dictionary = s.use_item(tid)
	assert_true(ask.get("needs_element", false), "no pick: the fruit asks")
	assert_eq(ask.options, missing, "it offers the missing elements")
	assert_true(s.db.has_record("items", tid), "and is kept")
	var r: Dictionary = s.use_item(tid, str(missing[0]))
	assert_true(s.player.linh_can.has(str(missing[0])), "the picked element grew")
	assert_true(r.ok, "used: %s" % str(r.lines))
	assert_false(s.db.has_record("items", tid), "consumed")
	var added: int = 1 + s.player.linh_can.variants.size()
	assert_eq(s.db.count("events"), before + added, "one record per change")


func test_the_birth_perk_raises_every_element_with_no_roll_ac52() -> void:
	var gd := game_data()
	var c := TestFixtures.character({"hoa": 86, "kim": 40})
	c.linh_can.variants["loi"] = 47
	ProgressionEdges.apply_birth(c, gd, "linh_can_thuan_tinh")
	assert_eq(int(c.linh_can.purity("hoa")), 94, "Fire")
	assert_eq(int(c.linh_can.purity("kim")), 48, "Metal")
	assert_eq(int(c.linh_can.purity("loi")), 54, "Thunder recomputed")
	var top := TestFixtures.character({"hoa": 95})
	ProgressionEdges.apply_birth(top, gd, "linh_can_thuan_tinh")
	assert_eq(int(top.linh_can.purity("hoa")), 100, "capped")
