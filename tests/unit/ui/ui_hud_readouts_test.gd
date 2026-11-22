extends DaoTestSuite
## HudReadouts (design/ux/hud.md, HUD Element Specifications 2, 9, 10): pure formatting of the always-on readouts.


func test_cultivation_share_is_clamped_and_zero_requirement_is_full() -> void:
	assert_near(HudReadouts.cultivation_share(62.0, 100.0), 0.62, 1e-6, "62 of 100")
	assert_eq(HudReadouts.cultivation_share(150.0, 100.0), 1.0, "over the requirement clamps to 1")
	assert_eq(HudReadouts.cultivation_share(-5.0, 100.0), 0.0, "below zero clamps to 0")
	assert_eq(HudReadouts.cultivation_share(10.0, 0.0), 1.0, "no requirement reads full")


func test_cultivation_text_rounds_down() -> void:
	assert_eq(HudReadouts.cultivation_text(62.9, 100.0), "62%", "62.9 % shows 62 %")


func test_lifespan_text_shows_whole_years() -> void:
	assert_eq(HudReadouts.lifespan_text(84.75, 220.4), "age 84 / 220", "whole years, rounded down")


func test_lifespan_warning_at_the_share_boundary() -> void:
	# Boundary value test: the exact numbers are the point (lifespan_warn_share 0.10).
	assert_true(HudReadouts.lifespan_warning(90.0, 100.0, 0.10), "exactly 10 % left warns")
	assert_false(HudReadouts.lifespan_warning(89.0, 100.0, 0.10), "11 % left does not")
	assert_true(HudReadouts.lifespan_warning(5.0, 0.0, 0.10), "no lifespan warns")


func test_stones_text_groups_thousands() -> void:
	assert_eq(HudReadouts.stones_text(1240.0), "1,240", "thousands")
	assert_eq(HudReadouts.stones_text(999.0), "999", "under a thousand")
	assert_eq(HudReadouts.stones_text(1234567.0), "1,234,567", "millions")
	assert_eq(HudReadouts.stones_text(-1500.0), "-1,500", "negative")
	assert_eq(HudReadouts.stones_text(0.0), "0", "zero")
