extends DaoTestSuite
## Edges over the baseline progression (design/quick-specs/progression-and-edges.md):
## thiên mệnh perks, the Phá Cảnh Phù starting item, cơ duyên, and NPC edges and fate.


func _session(edge: bool = true, perk: String = "") -> GameSession:
	var gd := game_data()
	var llm := LlmService.new(gd)
	llm.enabled = false
	var s := GameSession.new(gd, llm, TestFixtures.tree())
	var spec := {"mode": "roll", "name": "Mệnh", "gender": "male", "origin": "tan_tu", "edge": edge}
	if perk != "":
		spec["perk"] = perk
	s.new_game(4242, spec)
	s.pending_event = {}
	return s


func _to_bottleneck(s: GameSession) -> void:
	var c: Character = s.player
	c.realm_index = 0
	c.stage = s.gd.stage_count(0) - 1
	c.tu_vi = CultivationRules.stage_requirement(c, s.gd)


func _starting_pha_canh(s: GameSession) -> int:
	for si in s.gd.file("character_edges").player.starting_items:
		if str(si.get("talisman", "")) == "pha_canh":
			return int(si.qty)
	return 0


func _talismans(s: GameSession, id: String) -> int:
	var n: int = 0
	for it in s.db.items_of(s.player.id):
		if it.kind == "talisman" and it.template == id:
			n += int(it.qty)
	return n


func test_a_life_with_the_edge_gets_a_perk_and_a_pha_canh_phu() -> void:
	var s := _session(true)
	assert_eq(s.player.perks.size(), 1, "one thiên mệnh")
	assert_eq(_talismans(s, "pha_canh"), _starting_pha_canh(s), "starting Phá Cảnh Phù")
	var plain := _session(false)
	assert_eq(plain.player.perks.size(), 0, "baseline life: no perk")
	assert_eq(_talismans(plain, "pha_canh"), 0, "baseline life: no starting item")


func test_a_perk_shows_on_the_sheet_under_its_name() -> void:
	var s := _session(true, "dao_cot")
	var src: Array = s.sheet().sources("breakthrough_chance").map(func(m): return str(m.source))
	assert_true(src.any(func(x): return x.contains("Đạo Cốt Thiên Sinh")), "explain names the perk: %s" % str(src))


func test_linh_can_thuan_tinh_raises_every_root_at_birth() -> void:
	var gd := game_data()
	var c := CharacterFactory.roll_player(gd, rng(7), "A", "male", "tan_tu")
	var before: Dictionary = c.linh_can.elements.duplicate()
	ProgressionEdges.apply_birth(c, gd, "linh_can_thuan_tinh")
	for e in before.keys():
		assert_eq(int(c.linh_can.elements[e]), mini(int(before[e]) + 8, 100), "%s purer" % e)


func test_bat_diet_dao_tam_keeps_tu_vi_on_a_failed_breakthrough() -> void:
	var s := _session(true, "bat_diet_dao_tam")
	_to_bottleneck(s)
	var c: Character = s.player
	var sh: StatSheet = s.sheet()
	sh.add_mod("test: force failure", "breakthrough_chance", -1000.0)
	var tu_vi: float = c.tu_vi
	var r: Dictionary = CultivationRules.attempt_breakthrough(c, s.gd, sh, s.rng, -1)
	assert_false(r.success, "failed")
	assert_near(c.tu_vi, tu_vi, 0.001, "no tu vi lost")


func test_pha_canh_phu_is_previewed_then_used_by_the_breakthrough() -> void:
	var s := _session(true, "tho_nguyen")
	_to_bottleneck(s)
	var with_t: float = Advisor.breakthrough_odds(s).chance
	var plain := _session(false)
	_to_bottleneck(plain)
	var without_t: float = Advisor.breakthrough_odds(plain).chance
	assert_true(with_t > without_t, "talisman in the odds: %.2f vs %.2f" % [with_t, without_t])
	var held: int = _starting_pha_canh(s)
	assert_eq(_talismans(s, "pha_canh"), held, "preview uses nothing")
	s.breakthrough()
	assert_eq(_talismans(s, "pha_canh"), held - 1, "one used by the attempt")


func test_co_duyen_needs_the_edge_and_a_binh_canh_and_comes_once_per_realm() -> void:
	var s := _session(true)
	var ids := func(sess: GameSession) -> Array:
		var ctx: Dictionary = sess.event_context()
		return sess.templates.eligible(ctx).filter(func(t): return bool(t.get("requires_edge", false))).map(func(t): return t.id)
	assert_eq(ids.call(s).size(), 0, "not before the bình cảnh")
	_to_bottleneck(s)
	assert_true(ids.call(s).size() > 0, "eligible at the bình cảnh")
	s.co_duyen_used[0] = int(s.gd.file("character_edges").player.co_duyen_per_realm)
	assert_eq(ids.call(s).size(), 0, "not after this realm's cơ duyên")
	var plain := _session(false)
	_to_bottleneck(plain)
	assert_eq(ids.call(plain).size(), 0, "never without the edge")


func test_npc_step_chance_runs_from_base_to_max() -> void:
	var gd := game_data()
	var cfg: Dictionary = gd.file("character_edges").npc
	var plain := {"linh_can": {"elements": {"kim": 40}, "bien_di": {}}, "sect_rank": "", "background": "", "perks": []}
	assert_near(ProgressionEdges.npc_step_chance(plain, gd).total, float(cfg.base_step), 0.001, "no edge: base")
	var gifted := {"linh_can": {"elements": {"kim": 95, "hoa": 95}, "bien_di": {"loi": 80, "phong": 80}}, "sect_rank": "tong_chu", "background": "rich_family", "perks": ["dao_cot"]}
	assert_near(ProgressionEdges.npc_step_chance(gifted, gd).total, float(cfg.max_step), 0.001, "all edges: capped at max")


func test_fated_npcs_break_through_and_unfated_ones_do_not() -> void:
	var s := _session(false)
	var fated: String = s.builds.create_person(s.rng, {"realm_index": 0, "stage": s.gd.stage_count(0) - 1, "location_id": s.player.location_id, "age": 30.0})
	var doomed: String = s.builds.create_person(s.rng, {"realm_index": 0, "stage": s.gd.stage_count(0) - 1, "location_id": s.player.location_id, "age": 30.0})
	s.db.get_record("people", fated)["bt_fate"] = {"realm": 0, "ok": true}
	s.db.get_record("people", doomed)["bt_fate"] = {"realm": 0, "ok": false}
	for i in 200:
		s.ticker.tick(s.rng, s.year, 0)
	assert_true(int(s.db.get_record("people", fated).realm_index) >= 1, "fated NPC reached Trúc Cơ")
	assert_eq(int(s.db.get_record("people", doomed).realm_index), 0, "unfated NPC stayed")
