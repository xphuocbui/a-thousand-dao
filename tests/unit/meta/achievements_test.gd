extends DaoTestSuite
## Thành tựu: earned once, only in Thiên Định lives, kept by the (in-memory) store.


func _session(mode: String = "roll") -> GameSession:
	var gd := game_data()
	var llm := LlmService.new(gd)
	llm.enabled = false
	var s := GameSession.new(gd, llm, TestFixtures.tree())
	var spec := {"mode": mode, "name": "Thành", "gender": "male", "origin": "tan_tu", "thien_phu": {}, "purities": {"hoa": 60}, "bien_di": []}
	s.new_game(4242, spec)
	s.pending_event = {}
	return s


func _ids(list: Array) -> Array:
	return list.map(func(a): return str(a.id))


func test_reaching_truc_co_earns_it_once() -> void:
	var s := _session()
	var book := Achievements.new(s.gd, AchievementStore.new())
	assert_false(_ids(book.check(s)).has("truc_co"), "not yet")
	s.player.realm_index = 1
	assert_true(_ids(book.check(s)).has("truc_co"), "earned on reaching Trúc Cơ")
	assert_false(_ids(book.check(s)).has("truc_co"), "only once")
	assert_true(book.store.has("truc_co"), "stored")


func test_tu_dinh_lives_earn_nothing() -> void:
	var s := _session("custom")
	assert_eq(s.player.birth_mode, "tu_dinh", "custom birth is Tự Định")
	var book := Achievements.new(s.gd, AchievementStore.new())
	s.player.realm_index = 2
	assert_eq(book.check(s).size(), 0, "casual lives earn no achievements")


func test_conditions_with_origin_age_and_skill() -> void:
	var s := _session()
	var book := Achievements.new(s.gd, AchievementStore.new())
	var by_id: Dictionary = {}
	for a in book.all():
		by_id[a.id] = a
	s.player.realm_index = 2
	assert_true(book.met(s, by_id.tan_tu_ket_dan.condition), "a tán tu at Kết Đan")
	s.player.origin = "gia_toc"
	assert_false(book.met(s, by_id.tan_tu_ket_dan.condition), "wrong origin")
	s.player.age = 60.0
	s.player.realm_index = 1
	assert_false(book.met(s, by_id.thieu_nien_truc_co.condition), "too old for the young Trúc Cơ")
	s.player.add_skill_xp("dan_dao", 99999.0, 100.0, 9)
	assert_true(book.met(s, by_id.dan_su.condition), "Đan Đạo 6+")
