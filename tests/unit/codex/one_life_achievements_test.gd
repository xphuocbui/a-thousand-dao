extends DaoTestSuite
## One Life prestige achievements unit tests (Rule 11, AC-CK-21).


func _session(mode: String = "roll") -> GameSession:
	var gd := game_data()
	var llm := LlmService.new(gd)
	llm.enabled = false
	var s := GameSession.new(gd, llm, TestFixtures.tree())
	var spec := {"mode": mode, "name": "Nhất Sinh", "gender": "male", "origin": "tan_tu", "thien_phu": {}, "purities": {"hoa": 60}, "variants": []}
	s.new_game(4242, spec)
	s.pending_event = {}
	return s


func _ids(list: Array) -> Array:
	return list.map(func(a): return str(a.id))


func test_unbroken_one_life_earns_prestige_achievements() -> void:
	var s := _session()
	s.set_meta("playthrough_mode", "one_life")
	s.set_meta("death_reloaded", false)
	var book := Achievements.new(s.gd, AchievementStore.new())
	s.player.realm_index = 1
	var earned: Array = _ids(book.check(s))
	assert_true(earned.has("truc_co"), "normal Trúc Cơ earned")
	assert_true(earned.has("one_life_truc_co"), "unbroken One Life earns one_life_truc_co")


func test_ac_ck_21_death_reloaded_blocks_one_life_achievements_but_keeps_normal() -> void:
	var s := _session()
	var codex_store := CodexStore.new()
	var pt_id := "pt_one_life_001"
	assert_false(Achievements.should_mark_death_reloaded("one_life", pt_id, codex_store), "not marked before any death")

	# Player dies -> Codex records Lives entry with playthrough_id.
	codex_store.add_life({"playthrough_id": pt_id, "mode": "one_life", "name": s.player.name, "cause": "Slain"})
	assert_true(Achievements.should_mark_death_reloaded("one_life", pt_id, codex_store), "AC-CK-21: loading pre-death save detects prior death for playthrough_id")
	assert_false(Achievements.should_mark_death_reloaded("one_life", "pt_other", codex_store), "different playthrough_id is unaffected")
	assert_false(Achievements.should_mark_death_reloaded("continue", pt_id, codex_store), "Continue saves are not marked death_reloaded")

	# Mark the reloaded save death_reloaded = true; normal achievements still work, one_life ones are blocked.
	s.set_meta("playthrough_mode", "one_life")
	s.set_meta("death_reloaded", true)
	var book := Achievements.new(s.gd, AchievementStore.new())
	s.player.realm_index = 2
	var earned: Array = _ids(book.check(s))
	assert_true(earned.has("truc_co"), "normal truc_co still earned after reload")
	assert_true(earned.has("ket_dan"), "normal ket_dan still earned after reload")
	assert_false(earned.has("one_life_truc_co"), "AC-CK-21: one_life_truc_co blocked on death_reloaded save")
	assert_false(earned.has("one_life_ket_dan"), "AC-CK-21: one_life_ket_dan blocked on death_reloaded save")


func test_ac_ck_21_continue_mode_never_earns_one_life_achievements() -> void:
	var s := _session()
	s.set_meta("playthrough_mode", "continue")
	s.set_meta("death_reloaded", false)
	var book := Achievements.new(s.gd, AchievementStore.new())
	s.player.realm_index = 4
	var earned: Array = _ids(book.check(s))
	assert_true(earned.has("truc_co"), "Continue earns normal truc_co")
	assert_true(earned.has("ket_dan"), "Continue earns normal ket_dan")
	assert_true(earned.has("nguyen_anh"), "Continue earns normal nguyen_anh")
	assert_false(earned.has("one_life_truc_co"), "AC-CK-21: Continue never earns one_life_truc_co")
	assert_false(earned.has("one_life_ket_dan"), "AC-CK-21: Continue never earns one_life_ket_dan")
	assert_false(earned.has("one_life_nguyen_anh"), "AC-CK-21: Continue never earns one_life_nguyen_anh")
	assert_false(earned.has("one_life_hoa_than"), "AC-CK-21: Continue never earns one_life_hoa_than")

	# Also verify explicit override parameter on check().
	var s2 := _session()
	var book2 := Achievements.new(s2.gd, AchievementStore.new())
	s2.player.realm_index = 1
	var earned2: Array = _ids(book2.check(s2, "continue", false))
	assert_true(earned2.has("truc_co"), "explicit Continue earns normal achievement")
	assert_false(earned2.has("one_life_truc_co"), "explicit Continue blocks one_life achievement")


func test_cheated_or_self_made_blocks_all_achievements_including_one_life() -> void:
	var s := _session()
	s.set_meta("playthrough_mode", "one_life")
	s.cheated = true
	s.player.realm_index = 4
	var book := Achievements.new(s.gd, AchievementStore.new())
	assert_eq(book.check(s).size(), 0, "cheated One Life earns zero achievements")

	var s_custom := _session("custom")
	s_custom.set_meta("playthrough_mode", "one_life")
	s_custom.player.realm_index = 4
	assert_eq(book.check(s_custom).size(), 0, "Self-made One Life earns zero achievements")
