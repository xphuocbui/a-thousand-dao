extends DaoTestSuite
## MapView's streamed near tiles (assets/map/paper_hi since 2026-11-23, was near_hi; user 2026-11-23: "4x + deeper zoom") with the shipped files: zoomed
## in close, the tiles in view load in the background and are drawn over the overview layer.


func test_zoomed_in_close_the_tiles_in_view_load() -> void:
	# Arrange: the shipped map config and files
	var gd := game_data()
	var cfg: Dictionary = gd.file("ui_hud").get("greybox", {}).duplicate(true)
	cfg["terrain_shader"] = {}   # the painted-tile path (the terrain shader does not stream tiles)
	cfg["near_hi"] = "res://assets/map/paper_hi/manifest.json"   # the streamed tiles (the shipped paper map uses one texture)
	var v := MapView.new()
	v.size = Vector2(1920, 1080)
	add_child(v)
	v.setup(ContinentGrid.from_continent(gd), cfg, 4.0)
	v.set_accessibility(true, false)
	assert_false(v._hi.is_empty(), "the tile manifest is read from greybox.near_hi")
	# Act: zoom to 40 px per tile on a land tile and let the frames run
	v.centre_on(Vector2i(350, 120))
	v.zoom_by(40.0 / v.tile_scale(), v.size * 0.5)
	assert_true(v.hi_active(), "at 40 px per tile the streamed tiles are active")
	var frames: int = 0
	while frames < 600 and (int(v.hi_probe().loaded) == 0 or int(v.hi_probe().pending) > 0):
		await get_tree().process_frame
		frames += 1
	# Assert
	assert_true(int(v.hi_probe().loaded) > 0, "tiles in view loaded within 10 s (%s)" % str(v.hi_probe()))
	v.queue_free()


func test_an_instant_zoom_on_an_idle_map_still_loads_the_tiles() -> void:
	# Arrange: reduced motion (zooms land at once) and the map idle, its processing off, as in the game after a while
	var gd := game_data()
	var cfg: Dictionary = gd.file("ui_hud").get("greybox", {}).duplicate(true)
	cfg["terrain_shader"] = {}   # the painted-tile path (the terrain shader does not stream tiles)
	cfg["near_hi"] = "res://assets/map/paper_hi/manifest.json"   # the streamed tiles (the shipped paper map uses one texture)
	var v := MapView.new()
	v.size = Vector2(1920, 1080)
	add_child(v)
	v.setup(ContinentGrid.from_continent(gd), cfg, 4.0)
	v.set_accessibility(true, false)
	for i in 5:
		await get_tree().process_frame
	v.set_process(false)
	# Act
	v.centre_on(Vector2i(230, 118))
	v.zoom_by(40.0 / v.tile_scale(), v.size * 0.5)
	var frames: int = 0
	while frames < 600 and (int(v.hi_probe().loaded) == 0 or int(v.hi_probe().pending) > 0):
		await get_tree().process_frame
		frames += 1
	# Assert
	assert_true(int(v.hi_probe().loaded) > 0, "an instant zoom wakes the stream (%s)" % str(v.hi_probe()))
	v.queue_free()


func test_the_terrain_shader_draws_the_game_water_over_the_streamed_painted_land() -> void:
	# Arrange: the shipped config (terrain_shader enabled with painted_land, user 2026-11-23)
	var gd := game_data()
	var cfg: Dictionary = gd.file("ui_hud").get("greybox", {}).duplicate(true)
	cfg["near_hi"] = "res://assets/map/paper_hi/manifest.json"
	var v := MapView.new()
	v.size = Vector2(1920, 1080)
	add_child(v)
	# Act
	v.setup(ContinentGrid.from_continent(gd), cfg, 4.0)
	v.set_accessibility(true, false)
	v.zoom_by(40.0 / v.tile_scale(), v.size * 0.5)
	# Assert
	assert_true(v.terrain_active(), "the baked terrain data and texture array load")
	assert_true(v._terrain.is_painted(), "painted_land: the land is the painting, the water is the game's (user 2026-11-23)")
	assert_true(v.hi_active(), "zoomed in, the painted tiles stream under the game's water")
	v.queue_free()

