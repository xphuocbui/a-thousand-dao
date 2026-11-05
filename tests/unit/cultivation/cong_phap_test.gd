extends DaoTestSuite
## Cultivation Techniques (design/gdd/cong-phap.md): speed, mastery, power, harmony, slots.


func _def(tier: int, kind: String, names: Array, bonuses: Array = []) -> Dictionary:
	var layers: Array = [6, 9, 12, 15]
	return {"tech_id": "t", "name": "T", "tier": tier, "tech_kind": kind, "names": names, "layers": layers[tier], "bonuses": bonuses, "abilities": [], "seal_clusters": [], "origin": "authored"}


func _give(c: Character, key: String, def: Dictionary, layer: int = 1) -> Dictionary:
	var d: Dictionary = def.duplicate(true)
	d["tech_id"] = key
	c.techniques[key] = {"def": d, "layer": layer, "mastery": 0.0, "seal_seasons": 0}
	return c.techniques[key]


func _in_realm(c: Character, realm_idx: int) -> Character:
	c.realm_index = realm_idx
	c.level = Ladder.band(game_data(), realm_idx)[0]
	return c


func test_speed_matches_the_worked_example() -> void:
	var gd := game_data()
	var c := _in_realm(TestFixtures.character({"moc": 40, "hoa": 86}), 2)
	var e := _give(c, "a", _def(1, "main", ["moc", "hoa"]), 8)
	c.main_tech = "a"
	assert_near(CongPhap.speed_factor(c, gd).mult, 2.0 / 1.22 * 0.63 * 0.94, 1e-6, "CF layer 8: 0.97")
	c.realm_index = 3
	# Beyond its realm: cap 9, d = 1, x0.25 = 0.243, below crude 0.258.
	assert_near(CongPhap.tech_one(c, gd, e), 2.0 / 1.22 * 0.63 * 0.94 * 0.25, 1e-6, "beyond")
	var f: Dictionary = CongPhap.speed_factor(c, gd)
	assert_near(f.mult, 0.258, 1e-6, "crude floor")
	assert_true(str(f.label).contains("crude floor"), "the line says so")


func test_par_technique_at_match_half_gives_exactly_one() -> void:
	var gd := game_data()
	for r in 5:
		var c := _in_realm(TestFixtures.character({"hoa": 50}), r)
		var par: int = CongPhap.par_tier(gd, r)
		_give(c, "a", _def(par, "main", ["hoa"]), mini(3 * (r + 1), [6, 9, 12, 15][par]))
		c.main_tech = "a"
		assert_near(CongPhap.speed_factor(c, gd).mult, 1.0, 1e-6, "realm %d" % r)


func test_count_gain_divides_out_the_strongest_purity() -> void:
	var gd := game_data()
	var two := TestFixtures.character({"hoa": 50, "kim": 50})
	var five := TestFixtures.character({"hoa": 50, "kim": 50, "moc": 50, "tho": 50, "thuy": 50})
	assert_eq(CongPhap.count_gain(two, gd), 1.22, "two")
	assert_eq(CongPhap.count_gain(five, gd), 1.27, "five in QR")
	five.realm_index = 1
	assert_eq(CongPhap.count_gain(five, gd), 1.46, "five later")
	var wind := TestFixtures.character({"hoa": 50, "kim": 50})
	wind.linh_can.variants = {"phong": 50}
	assert_eq(CongPhap.count_gain(wind, gd), 1.22, "AC-LC-36: reads n_base")


func test_no_main_method_is_crude_with_low_power() -> void:
	var gd := game_data()
	var c := TestFixtures.character({"hoa": 60})
	assert_near(CongPhap.speed_factor(c, gd).mult, 0.18, 1e-6, "0.3 x 0.6")
	assert_eq(CongPhap.tech_power(c, gd), 0.5, "no_tech_power")


func test_power_tracks_depth_in_the_technique() -> void:
	var gd := game_data()
	var c := TestFixtures.character({"hoa": 60})
	_give(c, "a", _def(2, "main", ["hoa"]), 9)
	c.main_tech = "a"
	assert_near(CongPhap.tech_power(c, gd), 1.7 * (0.6 + 0.4 * 8.0 / 11.0), 1e-6, "layer 9 of 12: 1.51")


func test_harmony_is_directional_and_worst_wins() -> void:
	var gd := game_data()
	assert_eq(CongPhap.harmony(gd, ["moc"], ["thuy"]), 1.15, "main generates art")
	assert_eq(CongPhap.harmony(gd, ["thuy"], ["moc"]), 1.0, "art generates main")
	assert_eq(CongPhap.harmony(gd, ["moc"], ["moc"]), 1.0, "same element")
	assert_eq(CongPhap.harmony(gd, ["moc"], ["kim"]), 0.6, "main overcomes art")
	assert_eq(CongPhap.harmony(gd, ["kim"], ["moc"]), 0.6, "art overcomes main")
	assert_eq(CongPhap.harmony(gd, ["moc", "kim"], ["thuy"]), 1.0, "two arts, worst relation")
	assert_eq(CongPhap.harmony(gd, ["phong"], ["thuy"]), 1.0, "innate variant is neutral")
	assert_eq(CongPhap.harmony(gd, ["loi"], ["hoa"]), 0.6, "Thunder counts as Fire and Metal: Fire overcomes Metal")
	assert_eq(CongPhap.harmony(gd, ["moc"], []), 1.0, "no main method")


func test_bonus_matches_the_worked_example() -> void:
	var gd := game_data()
	var c := TestFixtures.character({"moc": 70, "thuy": 50})
	_give(c, "art", _def(1, "secret", ["moc"], [{"stat": "attack_pct", "value": 12.0}]), 6)
	_give(c, "main", _def(0, "main", ["thuy"]), 1)
	c.main_tech = "main"
	c.aux_tech = ["art", ""]
	var lines: Array = CongPhap.bonus_lines(c, gd, 50.0)
	var v: float = 0.0
	for l in lines:
		if l.stat == "attack_pct":
			v = l.value
	assert_near(v, 12.0 * 0.7375 * 1.2 * 1.15, 1e-6, "12.2 %")
	assert_eq(StatSheet.build(c, gd, null, null).total("attack_pct"), 12.2, "stored on the grid")


func test_body_technique_scales_with_physique() -> void:
	var gd := game_data()
	var c := TestFixtures.character({"hoa": 50})
	_give(c, "b", _def(1, "body", [], [{"stat": "defense_pct", "value": 10.0}]), 9)
	c.aux_tech = ["b", ""]
	assert_near(CongPhap.bonus_lines(c, gd, 60.0)[0].value, 10.0 * 1.1, 1e-6, "F = 1.1")
	assert_near(CongPhap.bonus_lines(c, gd, 150.0)[0].value, 10.0 * 1.5, 1e-6, "F capped")


func test_layer_cost_uses_the_catchup_price_below_the_realm() -> void:
	var gd := game_data()
	var d := _def(2, "main", ["hoa"])
	assert_near(CongPhap.layer_cost(gd, d, 11, 3), 165.0 * 0.33 * 1.4, 1e-6, "76.2")
	assert_near(CongPhap.layer_cost(gd, d, 11, 4), 165.0 * 0.33 * 1.4 * 0.25, 1e-6, "19.06")


func test_mastery_gain_scales_with_comprehension_and_activity() -> void:
	var gd := game_data()
	assert_near(CongPhap.mastery_gain(gd, 45.0, true), 1.45, 1e-6, "cultivating")
	assert_near(CongPhap.mastery_gain(gd, 45.0, false), 0.725, 1e-6, "idle half rate")


func test_a_gated_layer_holds_mastery_at_its_cost() -> void:
	var gd := game_data()
	var c := TestFixtures.character({"hoa": 60})
	var e := _give(c, "a", _def(0, "main", ["hoa"]), 3)
	var cost: float = CongPhap.layer_cost(gd, e.def, 4, 0)
	CongPhap.add_mastery(c, gd, e, cost + 50.0)
	assert_eq(int(e.layer), 3, "layer 4 needs FE")
	assert_near(float(e.mastery), cost, 1e-6, "surplus lost")
	c.realm_index = 1
	CongPhap.add_mastery(c, gd, e, 0.0)
	assert_eq(int(e.layer), 4, "mastered in the required realm")


func test_one_season_can_master_several_layers() -> void:
	var gd := game_data()
	var c := _in_realm(TestFixtures.character({"hoa": 60}), 1)
	var e := _give(c, "a", _def(0, "main", ["hoa"]), 1)
	CongPhap.add_mastery(c, gd, e, 40.0)
	assert_true(int(e.layer) >= 3, "layer %d" % int(e.layer))


func test_great_completion_stores_nothing() -> void:
	var gd := game_data()
	var c := _in_realm(TestFixtures.character({"hoa": 60}), 1)
	var e := _give(c, "a", _def(0, "main", ["hoa"]), 6)
	CongPhap.add_mastery(c, gd, e, 100.0)
	assert_eq(float(e.mastery), 0.0, "no store")


func test_slots_refuse_wrong_kinds_and_duplicates() -> void:
	var gd := game_data()
	var c := TestFixtures.character({"hoa": 60})
	_give(c, "m", _def(0, "main", ["hoa"]))
	_give(c, "s", _def(0, "secret", ["hoa"]))
	_give(c, "x", _def(0, "main", ["kim"]))
	assert_true(CongPhap.set_slot(c, gd, "main", 0, "m").ok, "main fits")
	assert_false(CongPhap.set_slot(c, gd, "aux", 0, "m").ok, "a main method is not an art")
	assert_false(CongPhap.set_slot(c, gd, "main", 0, "s").ok, "an art is not a main method")
	assert_false(CongPhap.set_slot(c, gd, "main", 0, "x").ok, "root lacks Metal")
	assert_true(CongPhap.set_slot(c, gd, "aux", 0, "s").ok, "art fits")
	assert_false(CongPhap.set_slot(c, gd, "aux", 1, "s").ok, "same technique twice")
	assert_false(CongPhap.set_slot(c, gd, "second", 0, "m").ok, "no capability #6")


func test_commons_stay_in_their_tiers_and_authored_fill_the_rest() -> void:
	var gd := game_data()
	var items := ItemFactory.new(gd)
	var r := rng(5)
	var common: Dictionary = items.cong_phap(r, 1)
	assert_eq(common.origin, "generated", "Profound common")
	assert_true(common.names.size() <= 2, "at most 2 elements")
	var earth: Dictionary = items.cong_phap(r, 2, ["hoa"])
	assert_eq(earth.origin, "authored", "Earth is authored")
	assert_eq(earth.names, ["hoa"], "names the element")


func test_every_authored_template_fits_its_tier() -> void:
	var gd := game_data()
	var cfg: Dictionary = gd.cong_phap_file()
	for t in cfg.templates:
		var tier: Dictionary = gd.cong_phap_tier(int(t.tier))
		assert_eq(int(t.layers), int(tier.layers), "%s layers" % t.id)
		var budget: float = 0.0
		for b in t.bonuses:
			var row: Array = cfg.bonus_pool.filter(func(p): return p.stat == b.stat)
			assert_false(row.is_empty(), "%s has a pool row for %s" % [t.id, b.stat])
			var size: float = float(b.value) / float(row[0].max)
			assert_true(size <= float(cfg.bonus_single_cap), "%s single cap" % t.id)
			budget += size
		assert_true(budget <= float(tier.bonus_budget), "%s budget %.2f" % [t.id, budget])
		assert_eq(t.names.is_empty(), t.tech_kind == "body", "%s names" % t.id)
