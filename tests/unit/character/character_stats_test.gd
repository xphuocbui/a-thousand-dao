extends DaoTestSuite
## Character Stats (design/gdd/character-stats.md): sheet stacking, ceilings, derived values,
## toxicity and heart demon, capabilities.


func _c(stat_value: int = 50) -> Character:
	return TestFixtures.character({"hoa": 50}, stat_value)


func _sheet(c: Character) -> StatSheet:
	return StatSheet.build(c, game_data(), null, null)


func test_ceiling_clamps_positive_modifiers_only() -> void:
	var c := _c()
	var sheet := _sheet(c)
	sheet.add_mod("a", "herb_growth_pct", 60.0)
	assert_eq(sheet.total("herb_growth_pct"), 10.0, "min(60, 10)")
	sheet.add_mod("b", "herb_growth_pct", -20.0)
	assert_eq(sheet.total("herb_growth_pct"), -10.0, "penalty after the cap")
	assert_near(sheet.mult("herb_growth_pct"), 0.9, 1e-9, "x 0.9")


func test_alchemy_success_ceiling_is_three() -> void:
	var sheet := _sheet(_c())
	sheet.add_mod("a", "alchemy_success", 2.0)
	sheet.add_mod("b", "alchemy_success", 2.0)
	sheet.add_mod("c", "alchemy_success", 3.0)
	assert_eq(sheet.total("alchemy_success"), 3.0, "min(7, 3)")


func test_pct_multiplier_floors_at_zero() -> void:
	var sheet := _sheet(_c())
	sheet.add_mod("a", "attack_pct", -150.0)
	assert_eq(sheet.mult("attack_pct"), 0.0, "never negative")


func test_modifiers_are_floored_to_their_grid() -> void:
	var sheet := _sheet(_c())
	sheet.add_mod("a", "attack_pct", 27.125)
	assert_eq(sheet.total("attack_pct"), 27.1, "0.1 grid")
	sheet.add_mod("b", "ngo_tinh", 0.29)
	assert_eq(sheet.total("ngo_tinh"), 0.29, "0.01 grid survives float error")


func test_effective_talent_clamps_and_grade_stays_base() -> void:
	var gd := game_data()
	var c := _c(5)
	var sheet := _sheet(c)
	sheet.add_mod("a", "mi_luc", -10.0)
	assert_eq(sheet.effective("mi_luc", c), 1.0, "floor")
	sheet.add_mod("b", "ngo_tinh", 200.0)
	assert_eq(sheet.effective("ngo_tinh", c), 150.0, "cap")
	assert_eq(gd.grade_name(float(c.base_stat("ngo_tinh"))), "Hạ", "grade from the base")


func test_derived_values_match_the_table() -> void:
	var gd := game_data()
	var c := TestFixtures.character({"hoa": 50}, 45, 2, 2)
	c.level = Ladder.stage_first_level(gd, 2, 2)
	var sheet := _sheet(c)
	assert_near(CharacterRules.than_thuc(c, gd, sheet).total, 45.0 * 10.0 * 1.30, 0.01, "divine sense")
	assert_near(CharacterRules.khi_huyet_max(c, gd, sheet).total, 45.0 * 10.0 * 15.0 * 1.30, 0.01, "vitality")
	assert_near(CharacterRules.linh_luc(c, gd, sheet).total, 6000.0 * 1.30 * 0.5, 0.01, "no main method: 0.5")


func test_resist_factor_clamps_both_ways() -> void:
	var gd := game_data()
	assert_near(CharacterRules.resist_factor(gd, 20.0), 0.8, 1e-9, "20 %")
	assert_near(CharacterRules.resist_factor(gd, 95.0), 0.1, 1e-9, "floor")
	assert_near(CharacterRules.resist_factor(gd, -150.0), 2.0, 1e-9, "penalty stops at x2")


func test_penalty_raises_a_toxicity_gain() -> void:
	var gd := game_data()
	var c := _c()
	var sheet := _sheet(c)
	sheet.add_mod("a", "dan_doc_resist_pct", -50.0)
	assert_near(CharacterRules.add_dan_doc(c, gd, sheet, 10.0), 15.0, 1e-9, "x1.5")


func test_natural_heart_demon_decay_is_a_quarter() -> void:
	assert_eq(float(game_data().attributes().derived.tam_ma_natural_decay), 0.25, "changed from 0.5")


func test_deviation_chance_scales_with_qi_deviation_pct() -> void:
	var gd := game_data()
	var c := _c(30)
	c.tam_ma = 28.0
	var sheet := _sheet(c)
	assert_near(CultivationRules.backlash_chance(c, gd, sheet).total, 13.0, 1e-6, "28 - 15")
	sheet.add_mod("a", "qi_deviation_pct", 100.0)
	assert_near(CultivationRules.backlash_chance(c, gd, sheet).total, 26.0, 1e-6, "doubled")


func test_capability_four_penalty_is_strictly_below_thirty_percent() -> void:
	var c := _c()
	c.grant_capability(4)
	c.vitality = 0.05 + 0.25
	assert_eq(_sheet(c).total("attack_pct"), 0.0, "exactly 30 %")
	c.vitality = 0.29
	assert_eq(_sheet(c).total("attack_pct"), -20.0, "below 30 %")


func test_capability_four_adds_spiritual_power_after_the_pct_step() -> void:
	var gd := game_data()
	var c := _c()
	c.grant_capability(4)
	var sheet := _sheet(c)
	sheet.add_mod("a", "linh_luc_pct", 100.0)
	var kh: float = CharacterRules.khi_huyet_max(c, gd, sheet).total
	assert_near(CharacterRules.linh_luc(c, gd, sheet).total, 100.0 * 0.5 * 2.0 + 0.2 * kh, 0.01, "not multiplied")


func test_capability_twenty_five_turns_heart_demon_to_attack() -> void:
	var c := _c()
	c.grant_capability(25)
	c.tam_ma = 50.0
	assert_eq(_sheet(c).total("attack_pct"), 0.0, "exactly 50")
	c.tam_ma = 54.25
	var sheet := _sheet(c)
	assert_eq(sheet.total("attack_pct"), 27.1, "54.25 / 2, floored")
	assert_eq(sheet.total("qi_deviation_pct"), 100.0, "always doubles deviation")


func test_a_capability_granted_twice_is_held_once() -> void:
	var c := _c()
	c.grant_capability(9)
	c.grant_capability(9)
	assert_eq(c.capabilities.size(), 1, "duplicate ignored")


func test_saves_clamp_state_and_default_capabilities() -> void:
	var c := Character.from_dict({"dan_doc": 140.0, "tam_ma": -5.0})
	assert_eq(c.dan_doc, 100.0, "clamped high")
	assert_eq(c.tam_ma, 0.0, "clamped low")
	assert_eq(c.capabilities, [], "empty set")


func test_talent_gain_rounds_with_a_floor_of_one_ac06() -> void:
	assert_eq(PillEffects.talent_gain(5.0, 1.5), 8, "round(7.5)")
	assert_eq(PillEffects.talent_gain(2.0, 0.75), 2, "round(1.5)")
	assert_eq(PillEffects.talent_gain(2.0, 0.48), 1, "floor of one")
	assert_eq(PillEffects.talent_gain(2.0, 0.0), 1, "zero potency")


func test_a_talent_pill_at_full_toxicity_still_gives_one_and_spends_a_use() -> void:
	var gd := game_data()
	var db := WorldDB.new()
	var c := _c(50)
	c.dan_doc = 100.0
	var id: String = db.add("items", {"owner_id": c.id, "kind": "pill", "template": "huyet_khi_dan", "name": "Huyết Khí Đan", "quality": 0, "qty": 1})
	var r: Dictionary = PillEffects.consume(c, gd, db, _sheet(c), id)
	assert_true(bool(r.ok), "taken")
	assert_eq(c.base_stat("can_cot"), 51, "minimum +1")
	assert_eq(int(c.pill_uses.get("huyet_khi_dan", 0)), 1, "one use spent")


func test_a_talent_pill_gain_stops_at_one_hundred_ac06() -> void:
	var gd := game_data()
	var db := WorldDB.new()
	var c := _c(99)
	var id: String = db.add("items", {"owner_id": c.id, "kind": "pill", "template": "huyet_khi_dan", "name": "Huyết Khí Đan", "quality": 0, "qty": 1})
	PillEffects.consume(c, gd, db, _sheet(c), id)
	assert_eq(c.base_stat("can_cot"), 100, "clamped")


func test_vitality_floor_has_one_copy_ac36() -> void:
	var gd := game_data()
	assert_false(gd.attributes().derived.has("vitality_floor"), "no copy in derived")
	assert_near(float(gd.breakthrough_rules().vitality_floor), 0.05, 1e-9, "owned by Realms")


func test_capability_two_adds_its_divine_sense_line_ac55() -> void:
	var gd := game_data()
	var c := TestFixtures.character({"hoa": 50}, 45, 2, 0)
	assert_near(CharacterRules.than_thuc(c, gd, _sheet(c)).total, 450.0, 1e-6, "without #2")
	c.grant_capability(2)
	assert_near(CharacterRules.than_thuc(c, gd, _sheet(c)).total, 540.0, 1e-6, "with #2")


func test_lifespan_pct_sources_stay_inside_the_bound_ac56() -> void:
	var gd := game_data()
	var total: float = 0.0
	var sources: Array = []
	for p in gd.file("character_edges").perks:
		for fx in p.effects:
			if str(fx.stat) == "lifespan_pct":
				total += float(fx.value)
				sources.append(str(p.id))
	var keystones: Dictionary = gd.file("meridian_tree").keystones
	for e in keystones.keys():
		for ks in keystones[e]:
			for m in ks.mods:
				if str(m.stat) == "lifespan_pct":
					total += float(m.value)
					sources.append(str(ks.name))
	assert_eq(sources.size(), 2, "the two named sources")
	assert_true(total <= 45.0, "bound +45")
