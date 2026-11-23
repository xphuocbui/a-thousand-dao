extends DaoTestSuite
## The map's alive layer (design/ux/hud.md Map zoom, Alive layer; user 2026-11-23: "animated water, cloud shadows,
## seasonal snow, chimney smoke") and the border line patterns (user 2026-11-23: "double border for country borders,
## dash for regions, dash + dot for provinces, one thickness"). The clock is driven through _process with a fixed step.

const DT := 1.0 / 60.0


func _layer(cfg: Dictionary) -> AliveLayer:
	var a := AliveLayer.new()
	a.setup(cfg, null)
	auto_free(a)
	return a


func test_the_clock_runs_when_enabled_and_motion_is_allowed() -> void:
	# Arrange
	var a := _layer({"enabled": true})
	# Act
	for i in 60:
		a._process(DT)
	# Assert
	assert_true(a.is_running(), "enabled and not reduced: running")
	assert_near(a.clock(), 1.0, 0.001, "60 frames of 1/60 s make one second")


func test_reduced_motion_stops_the_clock_at_zero_and_hides_the_smoke() -> void:
	# Arrange
	var a := _layer({"enabled": true})
	for i in 30:
		a._process(DT)
	# Act
	a.set_reduced_motion(true)
	# Assert
	assert_false(a.is_running(), "reduced motion: nothing moves")
	assert_near(a.clock(), 0.0, 0.0001, "the clock is held at zero (the shader's water and clouds stand still)")
	assert_false(a.is_processing(), "no per-frame work while still")


func test_a_disabled_layer_never_runs() -> void:
	var a := _layer({"enabled": false})
	assert_false(a.is_running(), "greybox.alive.enabled false: off")


func test_smoke_kinds_and_zoom_come_from_the_config() -> void:
	var a := _layer({"enabled": true, "smoke": {"kinds": ["city"], "from_px": 20.0}})
	assert_eq(a.smoke_kinds(), ["city"], "kinds from greybox.alive.smoke.kinds")
	assert_near(a.smoke_from_px(), 20.0, 0.0001, "from_px from the config")


func test_the_shipped_config_shifts_winter_colder_than_summer() -> void:
	var alive: Dictionary = game_data().file("ui_hud").get("greybox", {}).get("alive", {})
	var sh: Array = alive.get("season_temp_shift", [])
	assert_eq(sh.size(), 4, "one shift per season (Xuan, Ha, Thu, Dong)")
	assert_true(float(sh[3]) < float(sh[0]) and float(sh[0]) < float(sh[1]), "winter colder than spring, spring than summer")


func test_a_dash_pattern_draws_only_its_on_lengths() -> void:
	# Arrange: a straight 100 px line, dashes of 9 on / 5 off
	var segs := PackedVector2Array()
	# Act
	MapView._pattern_segments(PackedVector2Array([Vector2(0, 0), Vector2(100, 0)]), [9.0, 5.0], segs)
	# Assert: 100 = 7 x 14 + 2, so 7 full dashes and a 2 px start of the eighth
	var on: float = 0.0
	for i in range(0, segs.size(), 2):
		on += segs[i].distance_to(segs[i + 1])
	assert_eq(segs.size() / 2, 8, "eight dashes on a 100 px line")
	assert_near(on, 7 * 9.0 + 2.0, 0.001, "only the on lengths are drawn")


func test_the_dash_pattern_carries_across_a_corner() -> void:
	# a 6 px leg then a 6 px leg: the 9 px dash runs 6 + 3 across the corner, not restarting at it
	var segs := PackedVector2Array()
	MapView._pattern_segments(PackedVector2Array([Vector2(0, 0), Vector2(6, 0), Vector2(6, 6)]), [9.0, 5.0], segs)
	var first_leg_on: float = segs[0].distance_to(segs[1])
	var second_on: float = segs[2].distance_to(segs[3])
	assert_near(first_leg_on, 6.0, 0.001, "the dash fills the first leg")
	assert_near(second_on, 3.0, 0.001, "and its last 3 px continue round the corner")


func test_a_double_border_is_two_strokes_the_gap_apart() -> void:
	var line := PackedVector2Array([Vector2(0, 0), Vector2(50, 0), Vector2(100, 0)])
	var a: PackedVector2Array = MapView._offset_line(line, 1.5)
	var b: PackedVector2Array = MapView._offset_line(line, -1.5)
	for i in line.size():
		assert_near(a[i].distance_to(b[i]), 3.0, 0.001, "the two strokes stay 3 px apart at point %d" % i)
