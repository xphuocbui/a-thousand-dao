extends DaoTestSuite
## Herb element rework and crafting fuel (production/plans/herb-element-rework.md, 2026-11-21):
## uncapped plots (Spirit Herbs F2, Character Stats Formulas G), talisman ink as a share of value,
## Formula B's effective knee and doubling, multi-element herbs, recipes by element value with a
## strict breakthrough main herb, brew fuel and the designed p_brew form (Alchemy).


func _sheet(c: Character) -> StatSheet:
	return StatSheet.build(c, game_data(), null, null)


# --- Step 1: plots have no upper bound (max_plots removed 2026-11-10) ---

func test_plots_have_no_upper_bound() -> void:
	var gd := game_data()
	var c := TestFixtures.character({"tho": 100}, 50)
	var sh := _sheet(c)
	sh.add_mod("test", "field_plots", 20.0)
	var b: Breakdown = CharacterRules.field_plots(c, gd, sh)
	var expect: float = 3.0 + floorf(100.0 * float(gd.element_effects().field_plots_per_purity)) + 20.0
	assert_eq(b.total, expect, "3 base + Thổ 100 + 20 from the stat, past the old cap of 12")


func test_plots_floor_at_one() -> void:
	var c := TestFixtures.character({"hoa": 50}, 50)
	var sh := _sheet(c)
	sh.add_mod("test", "field_plots", -50.0)
	assert_eq(CharacterRules.field_plots(c, game_data(), sh).total, 1.0, "never below 1")


# --- Step 2: talisman ink is a share of the batch's value (Talismans quick spec, 2026-11-21) ---

func test_ink_is_a_share_of_batch_value() -> void:
	var gd := game_data()
	var t := Talismans.new(gd, WorldDB.new(), ItemFactory.new(gd))
	assert_eq(t.ink("hoa_cau"), 15, "ceil(0.625 x 12 x 2)")
	assert_eq(t.ink("kim_cuong"), 15, "ceil(0.625 x 12 x 2)")
	assert_eq(t.ink("than_hanh"), 25, "ceil(0.625 x 20 x 2)")
	assert_eq(t.ink("pha_canh"), 188, "ceil(0.625 x 300 x 1); was 150")


# --- Step 3: Formula B's effective knee and doubling (Item Database, 2026-11-21) ---

func test_short_lived_herb_does_not_compound_within_a_decade() -> void:
	var gd := game_data()
	# Ngưng Khí Thảo matures in 1 year: knee at max(3, 30 / 1) = 30 mature-ages, so at age 10 it is still on the plateau
	assert_near(ItemFactory.equivalents_at(gd, "ngung_khi_thao", 10.0), 1.9, 1e-6, "1 + 0.1 x 9 (it was about 56,000 before)")


func test_doubling_is_at_least_ten_years() -> void:
	var gd := game_data()
	# Hoàng Tinh Sâm (mature 10): knee max(3, 3) = 3, doubling max(0.45, 1.0) = 1 mature-age = 10 years
	assert_near(ItemFactory.equivalents_at(gd, "hoang_tinh_sam", 40.0), 2.4, 1e-6, "1.2 x 2^1")
	assert_near(ItemFactory.equivalents_at(gd, "hoang_tinh_sam", 60.0), 9.6, 1e-6, "1.2 x 2^3")


func test_long_lived_herb_keeps_the_old_curve() -> void:
	var gd := game_data()
	# Kim Tủy Quả (mature 50): 30 / 50 and 10 / 50 are below x_k and d, so nothing changes
	assert_near(ItemFactory.equivalents_at(gd, "kim_tuy_qua", 42.0), 0.84, 1e-9, "below maturity")
	assert_near(ItemFactory.equivalents_at(gd, "kim_tuy_qua", 200.0), 1.2 * pow(2.0, 1.0 / 0.45), 1e-6, "4 mature-ages, as before")


# --- Step 4: five basic herbs and six multi-element herbs (Item Database catalogue, 2026-11-21) ---

func _place(t: float, r: float, shares: Dictionary, density: float = 1.1) -> Dictionary:
	var ci: Dictionary = game_data().file("world_map").climate_index
	var t_c: float = float(ci.t_c[0]) + t / 100.0 * (float(ci.t_c[1]) - float(ci.t_c[0]))
	var r_mm: float = float(ci.r_mm[0]) + r / 100.0 * (float(ci.r_mm[1]) - float(ci.r_mm[0]))
	return {"temp_c": t_c, "rain_mm": r_mm, "density": density, "qi": {"shares": shares, "variants": {}}}


func test_catalogue_has_five_basic_and_six_multi_element_herbs() -> void:
	var gd := game_data()
	var basic := {"ngung_khi_thao": "moc", "thanh_tam_lien": "thuy", "hoa_linh_chi": "hoa", "hoang_tinh_sam": "tho", "thiet_tuyen_thao": "kim"}
	for id in basic:
		assert_eq(ItemFactory.herb_elements(gd.herb(id)), [basic[id]], "%s is a basic %s herb" % [id, basic[id]])
	var multi := {"xich_huyet_dang": ["hoa", "moc"], "bang_tam_thao": ["thuy", "kim"], "kim_tuy_qua": ["kim", "tho"],
		"van_nien_moc_linh": ["moc", "tho"], "anh_tam_lien": ["thuy", "moc"], "hoa_than_qua": ["hoa", "kim"]}
	for id in multi:
		assert_eq(ItemFactory.herb_elements(gd.herb(id)), multi[id], "%s elements" % id)
	var tt: Dictionary = gd.herb("thiet_tuyen_thao")
	assert_eq([int(tt.rarity), int(tt.base_value), float(tt.mature_years)], [1, 3, 1.0], "Thiết Tuyến Thảo: rarity 1, value 3, mature 1 year")


func test_herb_item_carries_its_elements() -> void:
	var gd := game_data()
	var items := ItemFactory.new(gd)
	assert_eq(items.herb("kim_tuy_qua", 10.0).elements, ["kim", "tho"], "multi-element item")
	assert_eq(items.herb("ngung_khi_thao", 1.0).elements, ["moc"], "basic item")


func test_multi_element_fit_reads_its_largest_share() -> void:
	var gd := game_data()
	var place := _place(40.0, 40.0, {"moc": 0.0, "hoa": 0.0, "tho": 40.0, "kim": 0.0, "thuy": 0.0}, 2.0)
	var ktq: Dictionary = gd.herb("kim_tuy_qua").duplicate()
	ktq["temp_ideal"] = 40
	ktq["rain_ideal"] = 40
	var f: Dictionary = HerbFit.fit(gd, ktq, place)
	assert_true(str(f.lines[0]).begins_with("element tho"), "the Earth share is the larger: %s" % str(f.lines[0]))
	assert_near(float(f.fit), 1.0, 1e-6, "no Metal on the land, full Earth: fit 1")


func test_basic_seeds_sold_at_every_realm() -> void:
	var gd := game_data()
	var field := HerbField.new(gd, WorldDB.new(), ItemFactory.new(gd))
	var ids: Array = field.seed_catalog(0).map(func(h): return str(h.id))
	for id in ["ngung_khi_thao", "thanh_tam_lien", "hoa_linh_chi", "hoang_tinh_sam", "thiet_tuyen_thao"]:
		assert_true(ids.has(id), "%s seeds at Qi Refining" % id)
	assert_false(ids.has("kim_tuy_qua"), "a rarity-4 multi-element herb is still gated at Qi Refining")


# --- Step 5: recipes by element value, a strict breakthrough main herb, fuel and the designed p_brew (Alchemy) ---

func _alch_with(herbs: Array, stones: int = 0) -> Dictionary:
	var gd := game_data()
	var db := WorldDB.new()
	var items := ItemFactory.new(gd)
	var c := TestFixtures.character({"hoa": 60})
	c.linh_thach = stones
	c.id = db.add("people", c.to_dict())
	for h in herbs:
		var it := items.herb(str(h[0]), float(h[1]))
		it["owner_id"] = c.id
		db.add("items", it)
	return {"gd": gd, "db": db, "c": c, "items": items, "alchemy": Alchemy.new(gd, db, items)}


func test_breakthrough_recipe_has_a_main_herb_and_a_companion_value() -> void:
	var r: Dictionary = game_data().recipe("truc_co_dan")
	assert_eq(r.ingredients[0], {"herb": "hoang_tinh_sam", "min_age": 40, "qty": 2}, "main herb kept as calibrated")
	assert_eq(str(r.ingredients[1].element), "hoa", "companion by element")
	assert_eq(int(r.ingredients[1].value), 11, "Fire >= 11")


func test_main_herb_is_never_substituted() -> void:
	var r: Dictionary = game_data().recipe("ngung_nguyen_dan")
	var w := _alch_with([["kim_tuy_qua", 42.0], ["kim_tuy_qua", 30.0], ["kim_tuy_qua", 30.0], ["thiet_tuyen_thao", 1.0], ["xich_huyet_dang", 20.0]])
	var plan: Dictionary = w.alchemy.find_ingredients(w.c, r)
	assert_false(plan.ok, "one Kim Tủy Quả at 42 and younger ones do not make the main herb")
	var ok := _alch_with([["kim_tuy_qua", 42.0], ["kim_tuy_qua", 45.0], ["xich_huyet_dang", 20.0]])
	assert_true(ok.alchemy.find_ingredients(ok.c, r).ok, "two at 42 or more, and Fire 45 from the vine")


func test_element_value_adds_up_young_herbs() -> void:
	var r: Dictionary = game_data().recipe("hoang_long_dan")
	var herbs: Array = [["hoa_linh_chi", 5.0], ["hoa_linh_chi", 5.0]]
	for i in 4:
		herbs.append(["hoang_tinh_sam", 2.5])   # value 5 each
	var w := _alch_with(herbs)
	var plan: Dictionary = w.alchemy.find_ingredients(w.c, r)
	assert_true(plan.ok, "Earth 4 x 5 = 20 and Fire 2 x 10 = 20: %s" % str(plan.missing))
	var short := _alch_with(herbs.slice(0, 5))
	assert_false(short.alchemy.find_ingredients(short.c, r).ok, "three young roots (15) fall short of Earth 20")


func test_multi_element_herb_fills_one_ingredient_only() -> void:
	var r := {"id": "t", "ingredients": [{"element": "hoa", "value": 40}, {"element": "moc", "value": 40}]}
	var w := _alch_with([["xich_huyet_dang", 20.0]])   # Fire + Wood, value 45
	assert_false(w.alchemy.find_ingredients(w.c, r).ok, "one vine cannot fill both")
	var w2 := _alch_with([["xich_huyet_dang", 20.0], ["xich_huyet_dang", 20.0]])
	assert_true(w2.alchemy.find_ingredients(w2.c, r).ok, "two vines fill one each")


func test_brew_burns_fuel_win_or_lose_and_is_refused_without_it() -> void:
	var gd := game_data()
	var r: Dictionary = gd.recipe("tu_khi_dan")
	var fuel: int = int(ceil(float(gd.file("items_recipes").alchemy.fuel_frac) * float(r.price) - 1e-6))
	var w := _alch_with([["ngung_khi_thao", 1.0], ["ngung_khi_thao", 1.0]], 100)
	var res: Dictionary = w.alchemy.craft(w.c, StatSheet.build(w.c, gd, null, null), rng(7), "tu_khi_dan")
	assert_true(res.ok, "brewed: %s" % str(res.get("message", "")))
	assert_eq(w.c.linh_thach, 100 - fuel, "fuel %d burned" % fuel)
	var broke := _alch_with([["ngung_khi_thao", 1.0], ["ngung_khi_thao", 1.0]], 0)
	var res2: Dictionary = broke.alchemy.craft(broke.c, StatSheet.build(broke.c, gd, null, null), rng(7), "tu_khi_dan")
	assert_false(res2.ok, "no fuel, no brew")
	assert_eq(broke.db.items_of(broke.c.id).filter(func(i): return i.kind == "herb").size(), 2, "herbs untouched")


func test_breakthrough_pills_burn_no_fuel_market_pills_do() -> void:
	# Arrange: Alchemy rule 6 (user decision 2026-11-22, after the A/B): a breakthrough recipe (one with a main herb)
	# burns no fuel; a market pill burns ceil(fuel_frac x price).
	var gd := game_data()
	var w := _alch_with([])
	# Act / Assert
	for rid in ["truc_co_dan", "ngung_nguyen_dan", "hoa_anh_dan", "hoa_than_dan"]:
		assert_eq(w.alchemy.fuel(gd.recipe(rid)), 0, "%s is a breakthrough pill: no fuel" % rid)
	var r: Dictionary = gd.recipe("hoang_long_dan")
	assert_eq(w.alchemy.fuel(r), int(ceil(float(gd.file("items_recipes").alchemy.fuel_frac) * float(r.price) - 1e-6)), "a market pill still burns fuel")
	assert_true(w.alchemy.fuel(r) > 0, "fuel_frac x 90 rounds up above 0")


func test_alchemy_success_divides_the_failure_chance() -> void:
	var gd := game_data()
	var w := _alch_with([])
	w.c.skills["dan_dao"] = {"level": 5, "xp": 0.0}
	var recipe := {"id": "t", "difficulty": 70}
	var sh := StatSheet.build(w.c, gd, null, null)
	var p0: float = w.alchemy.success_chance(w.c, sh, recipe).total
	sh.add_mod("test", "alchemy_success", 20.0)
	var p20: float = w.alchemy.success_chance(w.c, sh, recipe).total
	var alch: float = sh.total("alchemy_success")
	assert_eq(alch, 20.0, "no cap on alchemy_success (Character Stats rule 14)")
	assert_near(100.0 - p20, (100.0 - p0) / (1.0 + alch / 100.0), 0.01, "failure %.2f -> %.2f divided by 1 + %.0f %%" % [100.0 - p0, 100.0 - p20, alch])
	var easy := {"id": "e", "difficulty": 0}
	assert_eq(w.alchemy.success_chance(w.c, sh, easy).total, 95.0, "clamped at 95")


func test_market_never_stocks_the_four_main_herbs() -> void:
	assert_eq(Market.breakthrough_main_herbs(game_data()), ["hoang_tinh_sam", "kim_tuy_qua", "anh_tam_lien", "hoa_than_qua"], "main herbs")
