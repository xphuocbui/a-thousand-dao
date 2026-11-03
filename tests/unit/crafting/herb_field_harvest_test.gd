extends DaoTestSuite
## HerbField and the session harvest action.


func _session() -> GameSession:
	var gd := game_data()
	var llm := LlmService.new(gd)
	llm.enabled = false
	var s := GameSession.new(gd, llm, TestFixtures.tree())
	s.new_game(31337, {"mode": "roll", "name": "Nông Phu", "gender": "male", "origin": "tan_tu"})
	for item in s.field.planted(s.player).values():
		s.db.remove("items", item.id)
	return s


func _plant(s: GameSession, herb_id: String, age: float, plot: int) -> Dictionary:
	var h: Dictionary = s.items.herb(herb_id, age)
	h["owner_id"] = s.player.id
	h["plot"] = plot
	s.db.add("items", h)
	return h


func test_harvest_all_leaves_immature_herbs() -> void:
	# Regression: "harvest all" pulled a young Hoàng Tinh Sâm the player was aging for a Trúc Cơ Đan.
	var s := _session()
	var young := _plant(s, "hoang_tinh_sam", 1.3, 0)
	var ripe := _plant(s, "ngung_khi_thao", 2.0, 1)
	s.harvest(-1)
	assert_eq(int(young.plot), 0, "young herb still planted")
	assert_eq(int(ripe.plot), -1, "mature herb harvested")


func test_harvest_named_plot_forces_young_herb() -> void:
	var s := _session()
	var young := _plant(s, "hoang_tinh_sam", 1.3, 0)
	s.harvest(0)
	assert_eq(int(young.plot), -1, "explicit plot harvest is allowed")


func test_growth_scales_with_moc_purity() -> void:
	var s := _session()
	var h := _plant(s, "ngung_khi_thao", 0.0, 0)
	s.player.linh_can.elements = {"moc": 100}
	var mult: float = s.field.grow(s.player, s.sheet(), 4)
	var expected: float = 1.0 + float(s.gd.element_effects().herb_growth_pct_per_purity)
	assert_near(mult, expected, 0.001, "Mộc 100 multiplier")
	assert_near(float(h.age), expected, 0.001, "one year x multiplier")


func test_plant_seed_requires_being_home() -> void:
	var s := _session()
	s.player.location_id = "elsewhere"
	var r: Dictionary = s.field.plant_seed(s.player, s.sheet(), "ngung_khi_thao")
	assert_false(r.ok, "not at home")
