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
