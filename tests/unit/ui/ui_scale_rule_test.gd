extends DaoTestSuite
## UiScale (design/ux/hud.md, Platform Adaptation: Scaling rule): the automatic factor, the UI scale cap per window and
## the effective scale. The window sizes are the spec's acceptance values, so the exact numbers are the point.


func test_automatic_factor_never_shrinks_and_ignores_tall_or_narrow_windows() -> void:
	assert_eq(UiScale.auto_factor(1280, 720), 1.0, "a small window never shrinks the UI")
	assert_eq(UiScale.auto_factor(1920, 1080), 1.0, "the base size")
	assert_near(UiScale.auto_factor(2560, 1440), 4.0 / 3.0, 1e-9, "1440p is 1.33x")
	assert_eq(UiScale.auto_factor(3840, 2160), 2.0, "4K is 2x")
	assert_eq(UiScale.auto_factor(1280, 1600), 1.0, "a tall narrow window does not inflate it")
	assert_eq(UiScale.auto_factor(2560, 1080), 1.0, "21:9 at 1080 is the base")


func test_cap_keeps_the_layout_area_at_least_1280_by_720() -> void:
	for wh in [[1920, 1080], [2560, 1440], [3840, 2160], [1920, 1200], [2560, 1080]]:
		assert_eq(UiScale.max_scale_pct(wh[0], wh[1]), 150, "%dx%d caps at 150 %%" % wh)
	assert_eq(UiScale.max_scale_pct(1280, 720), 100, "1280x720 caps at 100 %")
	assert_eq(UiScale.max_scale_pct(1280, 1600), 100, "1280x1600 caps at 100 %")
	assert_eq(UiScale.max_scale_pct(1366, 768), 106, "1366x768 caps at 106 % (rounded down)")


func test_the_layout_area_at_the_cap_is_never_below_1280_by_720() -> void:
	for wh in [[1920, 1080], [2560, 1440], [3840, 2160], [1920, 1200], [2560, 1080], [1280, 720], [1280, 1600], [1366, 768], [2000, 1125]]:
		var f: float = UiScale.factor(UiScale.max_scale_pct(wh[0], wh[1]), wh[0], wh[1])
		assert_true(float(wh[0]) / f >= 1280.0 - 1e-6 and float(wh[1]) / f >= 720.0 - 1e-6, "%dx%d at its cap: layout %.1f x %.1f" % [wh[0], wh[1], float(wh[0]) / f, float(wh[1]) / f])


func test_effective_scale_is_the_setting_within_the_cap_and_keeps_the_setting() -> void:
	assert_eq(UiScale.effective_pct(150, 1366, 768), 106, "a 150 % setting at 1366x768 runs at its 106 % cap")
	assert_eq(UiScale.effective_pct(150, 2560, 1440), 150, "and at 150 % on a larger window")
	assert_eq(UiScale.effective_pct(75, 1920, 1080), 75, "75 % is the floor and allowed")
	assert_eq(UiScale.effective_pct(50, 1920, 1080), 75, "below the floor reads 75 %")


func test_factor_combines_the_setting_and_the_automatic_factor() -> void:
	assert_near(UiScale.factor(100, 2560, 1440), 4.0 / 3.0, 1e-9, "100 % at 1440p is 1.33x")
	assert_near(UiScale.factor(150, 1920, 1080), 1.5, 1e-9, "150 % at 1080p is 1.5x")
