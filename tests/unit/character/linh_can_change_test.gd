extends DaoTestSuite
## Changing linh căn, rarely (game-concept.md § Changing linh căn): Tẩy Tủy Đan raises the
## weakest element; Linh Căn Quả adds a missing element; both re-roll biến dị by rule;
## Linh Căn Quả is only granted by events from Trúc Cơ up.


func _session(origin: String = "tan_tu") -> GameSession:
	var gd := game_data()
	var llm := LlmService.new(gd)
	llm.enabled = false
	var s := GameSession.new(gd, llm, TestFixtures.tree())
	s.new_game(4242, {"mode": "custom", "name": "Đổi", "gender": "male", "origin": origin,
		"thien_phu": {}, "purities": {"hoa": 70, "moc": 30}, "bien_di": []})
	s.pending_event = {}
	return s


func test_tay_tuy_dan_raises_the_weakest_element_and_has_a_limit() -> void:
	var s := _session()
	var c: Character = s.player
	var max_uses: int = int(s.gd.recipe("tay_tuy_dan").effect.max_uses)
	var pid: String = s.alchemy.add_pills(c, "tay_tuy_dan", 0, max_uses + 1)
	var moc_before: float = c.linh_can.purity("moc")
	var hoa_before: float = c.linh_can.purity("hoa")
	var r: Dictionary = s.use_item(pid)
	assert_true(r.ok, "used: %s" % str(r.lines))
	assert_true(c.linh_can.purity("moc") > moc_before, "Mộc (weakest) rose")
	assert_eq(c.linh_can.purity("hoa"), hoa_before, "Hỏa unchanged")
	for i in max_uses - 1:
		c.dan_doc = 0.0
		s.use_item(pid)
	c.dan_doc = 0.0
	assert_false(s.use_item(pid).ok, "refused after %d uses" % max_uses)


func test_linh_can_qua_adds_a_missing_element() -> void:
	var s := _session()
	var c: Character = s.player
	var t: Dictionary = s.items.treasure("linh_can_qua", "tho")
	t["owner_id"] = c.id
	var tid: String = s.db.add("items", t)
	var before: int = c.linh_can.base_count()
	var r: Dictionary = s.use_item(tid)
	assert_true(r.ok, "used: %s" % str(r.lines))
	assert_eq(c.linh_can.base_count(), before + 1, "one more element")
	var p: float = c.linh_can.purity("tho")
	var rng_range: Array = s.gd.treasure("linh_can_qua").effect.purity
	assert_true(p >= float(rng_range[0]) and p <= float(rng_range[1]), "purity in range: %.0f" % p)
	assert_false(s.db.has_record("items", tid), "consumed")


func test_linh_can_qua_raises_an_owned_element_when_all_five_are_owned() -> void:
	var s := _session()
	var c: Character = s.player
	for e in s.gd.element_cycle():
		c.linh_can.add_element(e, 40)
	var t: Dictionary = s.items.treasure("linh_can_qua", "kim")
	t["owner_id"] = c.id
	var tid: String = s.db.add("items", t)
	var kim_before: float = c.linh_can.purity("kim")
	assert_true(s.use_item(tid).ok, "used")
	assert_true(c.linh_can.purity("kim") > kim_before, "Kim purity rose instead")


func test_events_grant_linh_can_qua_only_from_truc_co() -> void:
	var s := _session()
	var raw := {"title": "Quả lạ", "text": "Một trái cây phát sáng.", "choices": [
		{"label": "Hái", "check": {"type": "none"}, "success": {"text": "Được.", "effects": [{"type": "treasure", "treasure": "linh_can_qua"}]}},
		{"label": "Đi", "check": {"type": "none"}, "success": {"text": "Đi.", "effects": []}},
	]}
	var ctx_lk: Dictionary = EventContext.build(s.player, s.gd, s.db, s.sheet(), s.year, s.season, "vi")
	var lk: Dictionary = s.validator.normalize(raw.duplicate(true), ctx_lk, s.rng, "llm")
	assert_eq(lk.event.choices[0].success.effects.size(), 0, "dropped at Luyện Khí: %s" % str(lk.warnings))
	s.player.realm_index = 1
	var ctx_tc: Dictionary = EventContext.build(s.player, s.gd, s.db, s.sheet(), s.year, s.season, "vi")
	var tc: Dictionary = s.validator.normalize(raw.duplicate(true), ctx_tc, s.rng, "llm")
	assert_eq(tc.event.choices[0].success.effects.size(), 1, "allowed at Trúc Cơ")
	var before: int = s.db.items_of(s.player.id).filter(func(i): return i.kind == "treasure").size()
	s.pending_event = tc.event
	s.pending_meta = {"source": "llm"}
	s.choose(0)
	assert_eq(s.db.items_of(s.player.id).filter(func(i): return i.kind == "treasure").size(), before + 1, "treasure granted")
