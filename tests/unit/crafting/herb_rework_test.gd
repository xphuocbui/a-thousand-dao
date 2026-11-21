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
