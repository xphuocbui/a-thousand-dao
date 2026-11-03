extends DaoTestSuite
## Luyện khí and trận pháp: acceptance criteria from
## design/quick-specs/luyen-khi-and-tran-phap.md.


func _session() -> GameSession:
	var gd := game_data()
	var llm := LlmService.new(gd)
	llm.enabled = false
	var s := GameSession.new(gd, llm, TestFixtures.tree())
	s.new_game(4242, {"mode": "roll", "name": "Thợ", "gender": "male", "origin": "tan_tu"})
	s.pending_event = {}
	return s


func _give_material(s: GameSession, material_id: String, qty: int) -> void:
	var m: Dictionary = s.items.material(material_id, qty)
	m["owner_id"] = s.player.id
	s.db.add("items", m)


func _material_count(s: GameSession) -> int:
	var n: int = 0
	for it in s.db.items_of(s.player.id):
		if it.kind == "material":
			n += int(it.get("qty", 1))
	return n


func test_refine_spends_fuel_and_materials_and_passes_a_season() -> void:
	var s := _session()
	_give_material(s, "tinh_thiet", 3)
	s.player.linh_thach = 1000
	var fuel: int = s.refinery.fuel_cost("phi_kiem", 0)
	var arts_before: int = s.db.items_of(s.player.id).filter(func(i): return i.kind == "artifact").size()
	var season_before: int = s.season_index()
	var r: Dictionary = s.refine("phi_kiem", 0)
	assert_true(r.ok, "refine ran: %s" % str(r.lines))
	assert_eq(s.player.linh_thach, 1000 - fuel, "fuel spent")
	assert_eq(_material_count(s), 1, "two materials used for tier 0")
	assert_eq(s.season_index(), season_before + 1, "one season passed")
	var arts_after: int = s.db.items_of(s.player.id).filter(func(i): return i.kind == "artifact").size()
	assert_true(arts_after == arts_before + 1 or str(r.lines).contains("Failed"), "an artifact on success")


func test_refine_refused_without_materials_spends_nothing() -> void:
	var s := _session()
	for it in s.db.items_of(s.player.id):
		if it.kind == "material":
			s.db.remove("items", it.id)
	s.player.linh_thach = 1000
	var season_before: int = s.season_index()
	var r: Dictionary = s.refine("phi_kiem", 0)
	assert_false(r.ok, "refused")
	assert_eq(s.player.linh_thach, 1000, "no fuel spent")
	assert_eq(s.season_index(), season_before, "no time passed")


func test_tier_above_realm_is_refused() -> void:
	var s := _session()
	_give_material(s, "linh_moc_tam", 6)
	s.player.linh_thach = 100000
	var r: Dictionary = s.refine("phi_kiem", 2)
	assert_false(r.ok, "Luyện Khí cannot refine a Linh bảo")


func test_higher_kim_purity_raises_refining_success() -> void:
	var s := _session()
	var c: Character = s.player
	var low: float = s.refinery.success_chance(c, s.sheet(), 0).total
	c.linh_can.elements["kim"] = 90
	var high: float = s.refinery.success_chance(c, s.sheet(), 0).total
	assert_true(high > low, "Kim helps: %.1f -> %.1f" % [low, high])


func test_build_formation_raises_level_and_shows_its_source() -> void:
	var s := _session()
	var c: Character = s.player
	c.location_id = c.home_id
	_give_material(s, "huyen_hoang_thach", 2)
	c.linh_thach = 1000
	var cost: Dictionary = s.formations.build_cost("tu_linh", 1)
	var r: Dictionary = s.formation_build("tu_linh")
	assert_true(r.ok, "built: %s" % str(r.lines))
	assert_eq(s.formations.level(c, "tu_linh"), 1, "level 1")
	assert_eq(c.linh_thach, 1000 - int(cost.lt), "cost paid")
	var src: Array = s.sheet().sources("density_bonus").map(func(m): return str(m.source))
	assert_true(src.any(func(x): return x.contains("Tụ Linh")), "explain names the formation: %s" % str(src))


func test_tu_linh_raises_cultivation_only_at_home() -> void:
	var s := _session()
	var c: Character = s.player
	c.location_id = c.home_id
	c.formations = {"tu_linh": 2}
	var home: float = s.sheet().total("density_bonus")
	var away_place: String = s.db.get_record("places", c.home_id).links[0].to
	c.location_id = away_place
	var away: float = s.sheet().total("density_bonus")
	assert_true(home > 0.0, "bonus at home")
	assert_near(away, 0.0, 0.0001, "no bonus away")


func test_unpaid_upkeep_drops_a_level() -> void:
	var s := _session()
	var c: Character = s.player
	c.formations = {"thanh_moc": 2}
	c.linh_thach = 0
	var lines: Array = s.formations.pay_upkeep(c)
	assert_eq(s.formations.level(c, "thanh_moc"), 1, "dropped one level")
	assert_false(lines.is_empty(), "reported")


func test_formations_survive_save_and_load() -> void:
	var s := _session()
	s.player.formations = {"ho_son": 3}
	s.sync_player()
	var d: Dictionary = JSON.parse_string(JSON.stringify(s.to_dict()))
	var gd := game_data()
	var llm := LlmService.new(gd)
	llm.enabled = false
	var t := GameSession.new(gd, llm, TestFixtures.tree())
	assert_true(t.load_dict(d).ok, "loaded")
	assert_eq(t.formations.level(t.player, "ho_son"), 3, "level kept")


func test_tinh_kim_helps_refining_and_tran_strengthens_formations() -> void:
	var s := _session()
	var c: Character = s.player
	c.location_id = c.home_id
	c.formations = {"tu_linh": 2}
	var chance_before: float = s.refinery.success_chance(c, s.sheet(), 0).total
	var density_before: float = s.sheet().total("density_bonus")
	c.linh_can.bien_di["tinh_kim"] = 50.0
	c.linh_can.bien_di["tran"] = 50.0
	var sh: StatSheet = s.sheet()
	assert_true(s.refinery.success_chance(c, sh, 0).total > chance_before, "Tinh Kim raises refining success")
	var formation_part: float = 0.0
	for m in sh.sources("density_bonus"):
		if str(m.source).begins_with("Trận pháp"):
			formation_part = float(m.value)
	assert_true(formation_part > density_before, "Trận makes the formation stronger: %.2f vs %.2f" % [formation_part, density_before])
