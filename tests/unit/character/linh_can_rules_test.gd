extends DaoTestSuite
## Spiritual Roots (design/gdd/linh-can.md): birth roll, counts, pairs, variants, saves.

const RELOCATED := ["dung_nham", "trong", "sinh_menh", "doc", "vu", "kiem", "thien_loi", "huy_diet", "tu", "dan_hoa", "linh_thuc", "tinh_kim", "tran", "hon", "huyen", "tinh_than", "khong_gian", "am_tinh", "duong", "luan_hoi", "thai_cuc", "thoi_gian"]


func _lc(elements: Dictionary, variants: Dictionary = {}) -> LinhCan:
	var lc := LinhCan.new()
	lc.elements = elements
	lc.variants = variants
	return lc


func _script(draws: Array) -> ScriptedRng:
	var out: Array = []
	for d in draws:
		out.append(d[0])
		out.append(d[1])
	return ScriptedRng.new(out)


func _sorted(a: Array) -> Array:
	var b: Array = a.duplicate()
	b.sort()
	return b


# --- Birth ------------------------------------------------------------------------

func test_count_draws_land_on_either_side_of_each_boundary_ac01() -> void:
	var cfg: Dictionary = game_data().attributes().linh_can
	var us: Array = [0.0, 0.30, 0.449, 0.451, 0.60, 0.769, 0.771, 0.80, 0.919, 0.921, 0.95, 0.984, 0.986, 0.99, 0.9999]
	var want: Array = [1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4, 5, 5, 5]
	for i in us.size():
		assert_eq(LinhCan._roll_count(cfg, us[i]), want[i], "count at u=%s" % str(us[i]))


func test_purity_rounds_then_clamps_ac03() -> void:
	var cfg: Dictionary = game_data().attributes().linh_can
	var raw: Array = [59.6, 84.5, 10.4, 10.5, 99.5, 2.0, 130.0]
	var want: Array = [60, 85, 10, 11, 100, 10, 100]
	for i in raw.size():
		assert_eq(LinhCan.purity_from_draw(cfg, raw[i]), want[i], "raw %s" % str(raw[i]))


func test_triple_root_draw_order_ac04() -> void:
	var gd := game_data()
	var r := _script([["U", 0.80], ["U", 0.0], ["U", 0.0], ["U", 0.9], ["N", 40.0], ["N", 86.0], ["N", 10.0], ["U", 0.021], ["N", 60.0], ["U", 0.40], ["U", 0.05], ["U", 0.20]])
	var lc := LinhCan.roll(gd, r)
	assert_true(r.done(), "draws exact: %s %s" % [r.error, str(r.log)])
	assert_eq(lc.elements, {"moc": 40, "hoa": 86, "thuy": 10}, "elements")
	assert_eq(lc.variants, {"phong": 60, "quang": 69}, "variants")
	assert_eq(lc.tier_name(gd), "Triple root", "tier")
	assert_eq(lc.n_eff(gd), 4, "n_eff")
	assert_eq(_sorted(lc.rolled), _sorted(["phong", "huyet", "quang", "bang"]), "rolled set")


func test_dual_root_with_void_draw_order_ac05() -> void:
	var gd := game_data()
	var r := _script([["U", 0.50], ["U", 0.30], ["U", 0.60], ["N", 86.0], ["N", 40.0], ["U", 0.99], ["U", 0.010], ["N", 30.0], ["U", 0.004], ["N", 75.0], ["U", 0.10], ["U", 0.99]])
	var lc := LinhCan.roll(gd, r)
	assert_true(r.done(), "draws exact: %s %s" % [r.error, str(r.log)])
	assert_eq(lc.elements, {"hoa": 86, "kim": 40}, "elements")
	assert_eq(lc.variants, {"huyet": 30, "hu_khong": 75, "loi": 47}, "variants")
	assert_eq(lc.base_count(), 2, "n_base")
	assert_eq(lc.n_eff(gd), 4, "n_eff")
	assert_eq(_sorted(lc.rolled), _sorted(["phong", "huyet", "hu_khong", "loi", "quang"]), "rolled set")


func test_five_element_birth_makes_thirteen_uniform_draws_ac06() -> void:
	var gd := game_data()
	var draws: Array = [["U", 0.99], ["U", 0.0], ["U", 0.0], ["U", 0.0], ["U", 0.0], ["U", 0.0], ["N", 60.0], ["N", 50.0], ["N", 45.0], ["N", 70.0], ["N", 55.0]]
	for i in 7:
		draws.append(["U", 0.99])
	var r := _script(draws)
	LinhCan.roll(gd, r)
	assert_true(r.done(), "draws exact: %s" % r.error)
	assert_eq(r.log.count("U"), 13, "uniform draws")
	assert_eq(r.log.count("N"), 5, "normal draws")


func test_single_root_makes_no_derived_draw_ac06() -> void:
	var gd := game_data()
	var r := _script([["U", 0.30], ["U", 0.0], ["N", 50.0], ["U", 0.99], ["U", 0.99], ["U", 0.99]])
	var lc := LinhCan.roll(gd, r)
	assert_true(r.done(), "draws exact: %s" % r.error)
	assert_eq(lc.elements, {"moc": 50}, "Wood root")


func test_same_seed_gives_the_same_root_ac06() -> void:
	var gd := game_data()
	assert_eq(LinhCan.roll(gd, rng(7)).to_dict(), LinhCan.roll(gd, rng(7)).to_dict(), "same seed")


func test_birth_rates_match_the_catalogue_ac02_ac23() -> void:
	var gd := game_data()
	var r := rng(20261105)
	var n: int = 200000
	var tiers := {1: 0, 2: 0, 3: 0, 4: 0, 5: 0}
	var eff := {1: 0, 2: 0, 3: 0, 4: 0, 5: 0}
	var owned := {}
	var any: int = 0
	var innate: int = 0
	for i in n:
		var lc := LinhCan.roll(gd, r)
		tiers[lc.base_count()] += 1
		eff[lc.n_eff(gd)] += 1
		if not lc.variants.is_empty():
			any += 1
		if lc.innate_count(gd) > 0:
			innate += 1
		for id in lc.variants.keys():
			owned[id] = int(owned.get(id, 0)) + 1
	var want_tier := {1: 45.0, 2: 32.0, 3: 15.0, 4: 6.5, 5: 1.5}
	for k in want_tier.keys():
		assert_near(100.0 * tiers[k] / n, want_tier[k], 0.5, "tier %d" % k)
	var want_eff := {1: [43.00, 0.45], 2: [32.55, 0.45], 3: [15.83, 0.35], 4: [6.85, 0.25], 5: [1.76, 0.12]}
	for k in want_eff.keys():
		assert_near(100.0 * eff[k] / n, want_eff[k][0], want_eff[k][1], "n_eff %d" % k)
	assert_near(100.0 * any / n, 12.14, 0.30, "at least one variant")
	assert_near(100.0 * innate / n, 4.34, 0.20, "at least one innate")
	var want_v := {"phong": [2.50, 0.15], "huyet": [1.50, 0.12], "hu_khong": [0.385, 0.06], "loi": [1.97, 0.15], "am": [1.97, 0.15], "quang": [2.25, 0.15], "bang": [2.25, 0.15], "hon_don": [0.236, 0.05]}
	for id in want_v.keys():
		assert_near(100.0 * int(owned.get(id, 0)) / n, want_v[id][0], want_v[id][1], id)


func test_ranges_hold_over_seeded_births_ac07() -> void:
	var gd := game_data()
	var r := rng(11)
	for i in 10000:
		var lc := LinhCan.roll(gd, r)
		for e in lc.elements.keys():
			assert_true(lc.elements[e] is int and lc.elements[e] >= 10 and lc.elements[e] <= 100, "element range")
		for id in lc.variants.keys():
			var lo: int = 10 if gd.variant(id).origin == "innate" else 8
			var hi: int = 100 if gd.variant(id).origin == "innate" else 80
			assert_true(lc.variants[id] >= lo and lc.variants[id] <= hi, "%s range" % id)
	assert_eq(_lc({"tho": 10, "thuy": 10}).derived_purity(gd, "am"), 8, "Darkness floor")


func test_tier_ignores_variants_ac08() -> void:
	var gd := game_data()
	assert_eq(_lc({"hoa": 50, "kim": 50}, {"loi": 40}).tier_name(gd), "Dual root", "Thunder")
	assert_eq(_lc({"moc": 50}, {"phong": 40}).tier_name(gd), "Single root", "Wind")
	assert_eq(_lc({"moc": 50, "hoa": 50, "tho": 50, "kim": 50, "thuy": 50}, {"hon_don": 40}).tier_name(gd), "Five-element root", "Chaos")


func test_self_made_rolls_nothing_and_declines_the_rest_ac09() -> void:
	var gd := game_data()
	var lc := LinhCan.self_made(gd, {"hoa": 86, "kim": 40}, ["loi", "phong"])
	assert_eq(lc.variants, {"loi": 47, "phong": 50}, "picked")
	assert_eq(_sorted(lc.rolled), _sorted(["phong", "huyet", "hu_khong", "loi", "quang"]), "rolled")
	assert_eq(_sorted(lc.declined), _sorted(["huyet", "hu_khong", "quang"]), "declined")


func test_self_made_input_is_checked_ac09() -> void:
	var gd := game_data()
	assert_true(LinhCan.self_made_error(gd, {"hoa": 9}) != "", "9 rejected")
	assert_true(LinhCan.self_made_error(gd, {"hoa": 101}) != "", "101 rejected")
	assert_eq(LinhCan.self_made_error(gd, {"hoa": 10, "kim": 100}), "", "bounds accepted")
	assert_true(LinhCan.self_made_error(gd, {"hoa": 86}, ["loi"]) != "", "Thunder needs Metal")
	assert_true(LinhCan.self_made_error(gd, {"hoa": 50, "kim": 50, "thuy": 50}, ["hu_khong"]) != "", "Void on three")
	assert_eq(LinhCan.self_made_error(gd, {"hoa": 50, "kim": 50}, ["hu_khong"]), "", "Void on two")
	var all_five := {"moc": 100, "hoa": 100, "tho": 100, "kim": 100, "thuy": 100}
	var picks: Array = ["loi", "am", "hon_don", "quang", "bang", "phong", "huyet"]
	assert_eq(LinhCan.self_made_error(gd, all_five, picks), "", "strongest root accepted")
	var lc := LinhCan.self_made(gd, all_five, picks)
	for id in ["loi", "am", "hon_don", "quang", "bang"]:
		assert_eq(lc.variants[id], 80, "%s at 80" % id)


# --- Counts and pairs -------------------------------------------------------------

func test_n_eff_counts_innate_variants_only_ac11() -> void:
	var gd := game_data()
	var cases: Array = [
		[{"hoa": 50}, {}, 1],
		[{"hoa": 50}, {"phong": 50}, 2],
		[{"hoa": 50}, {"phong": 50, "huyet": 50, "hu_khong": 50}, 4],
		[{"hoa": 50, "thuy": 50}, {"phong": 50}, 3],
		[{"hoa": 50, "kim": 50}, {"loi": 40, "quang": 40}, 2],
		[{"hoa": 50, "kim": 50}, {"phong": 50, "huyet": 50, "hu_khong": 50}, 5],
		[{"hoa": 50, "kim": 50, "thuy": 50, "moc": 50}, {"phong": 50, "huyet": 50}, 5],
		[{"hoa": 50, "kim": 50, "thuy": 50, "moc": 50, "tho": 50}, {"hon_don": 40}, 5],
	]
	for c in cases:
		assert_eq(_lc(c[0], c[1]).n_eff(gd), c[2], str(c))


func test_curve_shape_ac13() -> void:
	var curve: Dictionary = game_data().attributes().element_count_curve
	assert_eq(curve["2"].tc_trung, 1.0, "row 2 parity")
	assert_eq(curve["3"].tc_trung, 1.0, "row 3 parity")
	assert_eq(curve["4"].tc_hau, 1.0, "row 4 parity")
	assert_eq(curve["5"].kd_so, 1.0, "row 5 parity")
	var order: Array = ["lk_early", "lk_mid", "lk_late", "tc_so", "tc_trung", "tc_hau", "tc_dvm", "kd_so", "kd_trung", "kd_hau", "kd_dvm", "na", "ht"]
	for row in ["1", "2", "3", "4", "5"]:
		for i in order.size() - 1:
			assert_true(float(curve[row][order[i + 1]]) >= float(curve[row][order[i]]), "row %s does not fall at %s" % [row, order[i]])


func test_pairs_over_all_subsets_ac16() -> void:
	var gd := game_data()
	var cycle: Array = gd.element_cycle()
	for mask in range(1, 32):
		var el: Dictionary = {}
		for i in 5:
			if mask & (1 << i):
				el[cycle[i]] = 50
		var pairs: int = _lc(el).generating_pairs(gd).size()
		match el.size():
			1: assert_eq(pairs, 0, "one")
			2: assert_true(pairs <= 1, "two")
			3: assert_true(pairs == 1 or pairs == 2, "three")
			4: assert_eq(pairs, 3, "four")
			5: assert_eq(pairs, 5, "five")
	assert_eq(_lc({"hoa": 50, "thuy": 50, "moc": 50}).generating_pairs(gd).size(), 2, "Wood-Fire, Water-Wood")
	assert_eq(_lc({"hoa": 50, "kim": 50}, {"loi": 40, "phong": 50}).generating_pairs(gd).size(), 0, "overcoming pair")


func test_pairs_reach_the_stat_sheet_with_data_names_ac17() -> void:
	var gd := game_data()
	var c := TestFixtures.character({"moc": 50, "hoa": 50, "thuy": 50})
	var sheet := StatSheet.build(c, gd, null, null)
	var sources: Array = sheet.sources("cultivation_speed_pct").map(func(m): return m.source)
	assert_eq(sheet.total("cultivation_speed_pct"), 6.0, "two pairs")
	assert_true(sources.has("Tương sinh: Mộc → Hỏa"), "Wood to Fire: %s" % str(sources))
	assert_true(sources.has("Tương sinh: Thủy → Mộc"), "Water to Wood: %s" % str(sources))


# --- Variants ---------------------------------------------------------------------

func test_catalogue_is_the_eight_variants_in_roll_order_ac18() -> void:
	var gd := game_data()
	assert_false(gd.elements_file().has("bien_di"), "old key gone")
	var ids: Array = gd.variant_defs().map(func(v): return v.id)
	assert_eq(ids, ["phong", "huyet", "hu_khong", "loi", "am", "hon_don", "quang", "bang"], "order")


func test_chances_match_formula_d1_ac20() -> void:
	var gd := game_data()
	assert_near(_lc({"hoa": 86, "kim": 40}).variant_chance(gd, "loi"), 0.2064, 1e-9, "Thunder")
	assert_near(_lc({"hoa": 86}).variant_chance(gd, "quang"), 0.1032, 1e-9, "Light")
	assert_near(_lc({"moc": 60, "hoa": 50, "tho": 45, "kim": 70, "thuy": 55}).variant_chance(gd, "hon_don"), 0.259875, 1e-9, "Chaos")
	assert_near(_lc({"thuy": 10}).variant_chance(gd, "bang"), 0.012, 1e-9, "Ice low")
	assert_near(_lc({"tho": 100, "thuy": 100}).variant_chance(gd, "am"), 0.6, 1e-9, "Darkness high")
	var five := func(p): return {"moc": p, "hoa": p, "tho": p, "kim": p, "thuy": p}
	assert_near(_lc(five.call(72)).variant_chance(gd, "hon_don"), 0.967458816, 1e-9, "Chaos 72")
	assert_near(_lc(five.call(73)).variant_chance(gd, "hon_don"), 1.0, 1e-9, "Chaos clamp")
	assert_near(_lc({"hoa": 50}).variant_chance(gd, "phong"), 0.025, 1e-9, "Wind")


func test_a_draw_equal_to_the_chance_fails_ac20() -> void:
	var gd := game_data()
	var r := _script([["U", 0.30], ["U", 0.0], ["N", 50.0], ["U", 0.025], ["U", 0.99], ["U", 0.99]])
	assert_false(LinhCan.roll(gd, r).variants.has("phong"), "U 0.025 does not form Wind")


func test_derived_purity_matches_d2_ac21() -> void:
	var gd := game_data()
	assert_eq(_lc({"hoa": 86, "kim": 40}).derived_purity(gd, "loi"), 47, "86/40")
	assert_eq(_lc({"hoa": 86, "kim": 48}).derived_purity(gd, "loi"), 51, "86/48")
	assert_eq(_lc({"hoa": 86, "kim": 28}).derived_purity(gd, "loi"), 39, "86/28")
	assert_eq(_lc({"hoa": 86}).derived_purity(gd, "quang"), 69, "Light")
	assert_eq(_lc({"moc": 60, "hoa": 50, "tho": 45, "kim": 70, "thuy": 55}).derived_purity(gd, "hon_don"), 44, "Chaos")


func test_each_derived_variant_rolls_only_once_ac24() -> void:
	var gd := game_data()
	var lc := _lc({"hoa": 86, "kim": 40})
	lc.rolled = ["phong", "huyet", "hu_khong", "loi", "quang"]
	var r := ScriptedRng.new([])
	lc.roll_newly_eligible(gd, r)
	assert_eq(r.log.size(), 0, "no draw on a second pass")
	lc.raise_purity(gd, "kim", 8)
	assert_eq(r.log.size(), 0, "a purity change never rolls")
	lc.add_element("thuy", 30)
	var r2 := _script([["U", 0.99]])
	lc.roll_newly_eligible(gd, r2)
	assert_true(r2.done(), "Water makes only Ice eligible: %s" % r2.error)


func test_a_variant_is_not_a_base_element_ac25() -> void:
	var gd := game_data()
	var lc := _lc({"hoa": 86}, {"quang": 69})
	assert_true(lc.has("quang"), "owned")
	assert_eq(lc.purity("quang"), 69.0, "purity")
	assert_eq(lc.purity("hoa"), 86.0, "Fire kept")
	assert_eq(lc.base_count(), 1, "n_base")
	assert_eq(lc.n_eff(gd), 1, "n_eff")
	assert_eq(lc.generating_pairs(gd).size(), 0, "no pairs")


func test_values_floor_in_integer_arithmetic_ac27() -> void:
	var gd := game_data()
	var line := func(id, p, i): return _lc({}, {id: p}).variant_lines(gd, id)[i].value
	assert_eq(line.call("loi", 47, 0), 14.1, "Thunder 47")
	assert_eq(line.call("loi", 51, 0), 15.3, "Thunder 51 (a float floor gives 15.2)")
	assert_eq(line.call("huyet", 47, 0), 11.7, "Blood 47")
	assert_eq(line.call("bang", 47, 0), 8.4, "Ice 47")
	assert_eq(line.call("hon_don", 44, 0), 5.7, "Chaos speed 44")
	assert_eq(line.call("hon_don", 44, 1), 2.6, "Chaos odds 44")
	assert_eq(line.call("hon_don", 80, 0), 10.4, "Chaos speed 80")
	assert_eq(line.call("hon_don", 80, 1), 4.8, "Chaos odds 80 (a float floor gives 4.7)")


func test_variant_lines_reach_the_sheet_with_data_names_ac29() -> void:
	var gd := game_data()
	var c := TestFixtures.character({"hoa": 86})
	c.linh_can.variants = {"quang": 69, "phong": 60, "hu_khong": 75}
	var sheet := StatSheet.build(c, gd, null, null)
	assert_near(sheet.total("tam_ma_resist_pct"), 13.8, 1e-9, "Light")
	assert_eq(sheet.sources("tam_ma_resist_pct")[0].source, "Biến dị: Quang", "source")
	assert_near(sheet.total("travel_speed_pct"), 60.0, 1e-9, "Wind")
	assert_near(sheet.total("co_duyen_pct"), 75.0, 1e-9, "Void")
	assert_eq(sheet.sources("co_duyen_pct")[0].source, "Biến dị: Hư Không", "Void source")
	assert_eq(sheet.total("attack_pct"), 0.0, "an unowned variant adds no line")


# --- Awakening --------------------------------------------------------------------

func test_awakening_rolls_failed_derived_variants_again_ac30() -> void:
	var gd := game_data()
	var lc := _lc({"hoa": 86, "kim": 40})
	lc.rolled = ["phong", "huyet", "hu_khong", "loi", "quang"]
	var fail := _script([["U", 0.99], ["U", 0.99]])
	assert_eq(lc.awakening_pass(gd, fail), [], "forced fail")
	assert_true(fail.done(), "exactly 2 U: %s" % fail.error)
	var win := _script([["U", 0.0], ["U", 0.0]])
	assert_eq(lc.awakening_pass(gd, win), ["loi", "quang"], "forced success, in catalogue order")
	var after := ScriptedRng.new([])
	lc.awakening_pass(gd, after)
	assert_eq(after.log.size(), 0, "owned variants make no further draw")


func test_awakening_never_rolls_declined_variants_ac10() -> void:
	var gd := game_data()
	var lc := LinhCan.self_made(gd, {"hoa": 86, "kim": 40}, ["loi", "phong"])
	var r := ScriptedRng.new([])
	assert_eq(lc.awakening_pass(gd, r), [], "Light declined")
	assert_eq(r.log.size(), 0, "no draw")
	lc.add_element("thuy", 30)
	var r2 := _script([["U", 0.0]])
	assert_eq(lc.roll_newly_eligible(gd, r2), ["bang"], "Ice did not qualify at birth, so it rolls")
	assert_true(r2.done(), "Light still makes no draw: %s" % r2.error)


func test_a_root_with_nothing_eligible_makes_no_awakening_draw_ac32() -> void:
	var gd := game_data()
	var r := ScriptedRng.new([])
	_lc({"moc": 40}).awakening_pass(gd, r)
	_lc({"hoa": 86}, {"quang": 69}).awakening_pass(gd, r)
	assert_eq(r.log.size(), 0, "0 draws")


# --- Relocated mutations and saves ------------------------------------------------

func test_relocated_mutations_are_not_variants_ac47() -> void:
	var gd := game_data()
	var lc := _lc({"hoa": 50})
	for id in RELOCATED:
		assert_true(gd.variant(id).is_empty(), "%s absent" % id)
		assert_false(lc.has(id), "%s not owned" % id)
		assert_eq(lc.purity(id), 0.0, "%s purity" % id)


func test_round_trip_keeps_the_rolled_and_declined_sets_ac48() -> void:
	var gd := game_data()
	var lc := LinhCan.self_made(gd, {"hoa": 86, "kim": 40}, ["loi", "phong"])
	var back := LinhCan.from_dict(JSON.parse_string(JSON.stringify(lc.to_dict())))
	assert_eq(back.to_dict(), lc.to_dict(), "round trip")
	assert_true(back.variants.loi is int, "JSON floats become ints")
	var r := ScriptedRng.new([])
	back.awakening_pass(gd, r)
	assert_eq(r.log.size(), 0, "declined stays declined after reload")


func test_a_pre_redesign_save_migrates_ac49() -> void:
	var gd := game_data()
	var old := {"elements": {"moc": 40, "hoa": 86, "kim": 40, "thuy": 60},
		"bien_di": {"quang": 47, "loi": 99, "phong": 39, "huyet": 6, "dan_hoa": 50, "kiem": 50},
		"rolled": ["quang", "loi", "kiem"]}
	var lc := LinhCan.from_dict(LinhCan.migrate_record(old, gd))
	assert_eq(lc.variants, {"quang": 69, "loi": 47, "phong": 39, "huyet": 10}, "kept and recomputed")
	assert_false(lc.rolled.has("kiem"), "relocated id dropped")
	assert_true(lc.rolled.has("bang"), "Ice marked rolled")
	assert_eq(lc.tier_name(gd), "Quadruple root", "tier")
	assert_eq(lc.n_eff(gd), 5, "n_eff")


func test_a_save_with_no_rolled_set_gains_no_first_roll_ac50() -> void:
	var gd := game_data()
	var lc := LinhCan.from_dict(LinhCan.migrate_record({"elements": {"moc": 40, "hoa": 86, "thuy": 60}, "variants": {"quang": 69}}, gd))
	assert_eq(_sorted(lc.rolled), _sorted(["phong", "huyet", "hu_khong", "quang", "bang"]), "marked rolled")
	lc.add_element("tho", 28)
	assert_near(lc.variant_chance(gd, "am"), 0.1008, 1e-9, "Darkness chance")
	var r := _script([["U", 0.99]])
	lc.roll_newly_eligible(gd, r)
	assert_true(r.done(), "Darkness only, not Ice: %s" % r.error)
	var a := _script([["U", 0.99], ["U", 0.99]])
	lc.awakening_pass(gd, a)
	assert_true(a.done(), "Awakening rolls Darkness and Ice: %s" % a.error)
