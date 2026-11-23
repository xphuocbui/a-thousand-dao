extends DaoTestSuite
## MapView's zoom and political map (design/ux/hud.md, Map zoom and the political map): the momentum zoom, gliding
## jumps, the transition band's weights, reduced motion, and the political bake. The view is driven frame by frame
## through _process with a fixed 1/60 s step, so no timing depends on the machine.

const DT := 1.0 / 60.0


func _view(reduced: bool = false) -> MapView:
	var gd := game_data()
	var cfg: Dictionary = gd.file("ui_hud").get("greybox", {}).duplicate(true)
	cfg["far_layer"] = ""   # the zoom and political rules do not need the painted layers
	cfg["near_layer"] = ""
	cfg["place_sprites"] = ""
	var v := MapView.new()
	v.size = Vector2(1920, 1080)
	v.setup(ContinentGrid.from_continent(gd), cfg, 4.0)
	v.set_accessibility(reduced, false)
	auto_free(v)
	return v


func _run(v: MapView, seconds: float) -> Array:
	var trace: Array = []
	for i in int(round(seconds / DT)):
		v._process(DT)
		trace.append(v.tile_scale())
	return trace


func test_one_notch_travels_about_one_zoom_step_and_comes_to_rest() -> void:
	var v := _view()
	var z0: float = v.tile_scale()
	v.zoom_by(1.25, v.size * 0.5)
	var trace: Array = _run(v, 0.6)
	assert_near(float(trace[-1]) / z0, 1.25, 0.25 * 0.03 * 1.25 + 0.01, "one notch travels about zoom_step within 0.6 s")
	var steps: Array = []
	for i in range(1, trace.size()):
		steps.append(float(trace[i]) - float(trace[i - 1]))
	assert_true(float(steps[0]) > float(steps[steps.size() - 1]), "it decelerates: the first frame moves more than the last")


func test_a_quick_burst_of_notches_builds_speed() -> void:
	var one := _view()
	one.zoom_by(1.25, one.size * 0.5)
	var a: Array = _run(one, 0.3)
	var burst := _view()
	burst.zoom_by(1.25, burst.size * 0.5)
	_run(burst, 0.1)
	burst.zoom_by(1.25, burst.size * 0.5)
	_run(burst, 0.1)
	burst.zoom_by(1.25, burst.size * 0.5)
	var b: Array = _run(burst, 0.1)
	assert_true(float(b[-1]) > float(a[-1]) * 1.2, "three notches 0.1 s apart zoom further and faster than one (%.2f vs %.2f)" % [b[-1], a[-1]])


func test_a_glide_speeds_up_then_slows_down() -> void:
	var v := _view()
	v.set_region_zoom(true, Vector2(270, 180))
	var trace: Array = _run(v, 0.6)
	assert_near(float(trace[-1]), 12.0, 0.05, "the glide lands on region_zoom_px")
	var d: Array = []
	for i in range(1, trace.size()):
		d.append(absf(float(trace[i]) - float(trace[i - 1])))
	var peak: int = 0
	for i in d.size():
		if float(d[i]) > float(d[peak]):
			peak = i
	assert_true(peak > 2 and peak < d.size() - 3, "the speed peaks in the middle (frame %d of %d): ease in, ease out" % [peak, d.size()])


func test_reduced_motion_lands_at_once() -> void:
	var v := _view(true)
	var z0: float = v.tile_scale()
	v.zoom_by(1.25, v.size * 0.5)
	assert_near(v.tile_scale() / z0, 1.25, 0.001, "a step lands at once")
	v.zoom_fit()
	assert_near(v.tile_scale(), z0, 0.001, "a glide lands at once")
	assert_false(v.is_moving(), "nothing carries on")


func test_the_zoom_stays_between_the_fit_and_the_deepest_zoom() -> void:
	var v := _view(true)
	var fit: float = v.tile_scale()
	v.zoom_by(0.5, v.size * 0.5)
	assert_near(v.tile_scale(), fit, 0.001, "never past the fit")
	for i in 20:
		v.zoom_by(1.25, v.size * 0.5)
	assert_near(v.tile_scale(), 18.0, 0.5, "the deepest zoom is zoom_max_px")


func test_the_band_weights_and_region_zoom() -> void:
	var v := _view(true)
	assert_near(v.near_weight(), 0.0, 0.001, "at the fit (3 px per tile) the paper map leads")
	v.zoom_by(8.1 / v.tile_scale(), v.size * 0.5)
	assert_near(v.near_weight(), 0.5, 0.02, "the band's middle (8.1 px per tile) weighs 0.5")
	v.zoom_by(9.6 / v.tile_scale(), v.size * 0.5)
	assert_near(v.near_weight(), 1.0, 0.001, "near_to_px: the relief alone")
	assert_true(v.is_region_zoom(), "region zoom")


func test_the_political_map_tints_each_region_by_its_holder_and_draws_bold_borders_between_holders() -> void:
	var v := _view(true)
	var regions: Array = [
		{"name": "A", "centre": [100, 100], "grid_id": 1, "holder_key": "tung_dao", "holder_name": "Tùng Đào Cung"},
		{"name": "B", "centre": [200, 100], "grid_id": 2, "holder_key": "thien_xu", "holder_name": "Thiên Xu Tông"}]
	v.set_regions(regions, null)
	var cfg: Dictionary = game_data().file("ui_hud").greybox.map_zoom
	var probe: Dictionary = v.politics_probe(1)
	var want := Color.from_string(str(cfg.sect_colours.tung_dao), Color.BLACK)
	assert_near((probe.colour as Color).r, want.r, 0.01, "region 1 takes its holder's colour")
	assert_true(int(probe.realms) == 2, "one name per great sect")
	var again: Dictionary = v.politics_probe(1)
	v.set_regions(regions, null)
	assert_eq(v.politics_probe(1).bold, again.bold, "the same holders rebake nothing new")


func test_province_lines_are_hidden_at_the_fit_on_any_screen_and_full_by_1_7_times_it() -> void:
	for sz in [Vector2(1280, 720), Vector2(1920, 1080), Vector2(3840, 2160)]:
		var v := _view(true)
		v.size = sz
		v.zoom_fit()
		assert_near(v.province_line_weight(), 0.0, 0.001, "hidden at the fit at %s" % str(sz))
		v.zoom_by(1.7, v.size * 0.5)
		assert_near(v.province_line_weight(), 1.0, 0.001, "full at 1.7 x the fit at %s" % str(sz))


func test_province_lines_lie_only_between_provinces_of_one_region() -> void:
	var v := _view(true)
	var regions: Array = [{"name": "A", "centre": [100, 100], "grid_id": 1, "holder_key": "tung_dao", "holder_name": "T"}]
	v.set_regions(regions, null)
	var probe: Dictionary = v.politics_probe(1)
	assert_true(int(probe.provinces) > 0, "the provinces file gives province lines (%d)" % int(probe.provinces))
	for ln in v._prov_lines:
		var same: bool = int(v._prov_region[int(ln.a)]) == int(v._prov_region[int(ln.b)])
		assert_eq(v._lines_prov.has(ln.pts), same, "a line is a province line exactly when both sides share a region")


func test_every_file_line_lands_in_exactly_one_set() -> void:
	var v := _view(true)
	v.set_regions([{"name": "A", "centre": [100, 100], "grid_id": 1, "holder_key": "tung_dao", "holder_name": "T"}], null)
	var p: Dictionary = v.politics_probe(1)
	assert_eq(int(p.bold) + int(p.thin) + int(p.provinces), v._prov_lines.size(), "holder + region + province = the file's lines")
