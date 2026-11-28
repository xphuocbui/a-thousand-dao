extends DaoTestSuite
## Codex & Karmic Carryover (#12) One Life save/reload achievement block integration test (AC-CK-21).


func _small_gd() -> GameData:
	var base := game_data()
	var files_copy: Dictionary = base.registry.files().duplicate()
	var wg: Dictionary = base.file("world_generation").duplicate(true)
	wg["people"]["world_cultivators"] = 40
	wg["people"]["world_cultivators_min"] = 0
	files_copy["world_generation"] = wg
	var rk: Dictionary = base.file("combat_rankings").duplicate(true)
	rk["enabled"] = false
	files_copy["combat_rankings"] = rk
	var gd := GameData.new()
	gd.setup(DataRegistry.from_files(files_copy))
	return gd


func _ids(list: Array) -> Array:
	return list.map(func(a): return str(a.id))


func test_one_life_reload_after_death_marks_death_reloaded_and_blocks_prestige_ac21() -> void:
	var gd := _small_gd()
	var codex_store := CodexStore.new("")
	var llm := LlmService.new(gd)
	llm.enabled = false

	# 1. Start a Fated One Life and save BEFORE dying.
	var s1 := GameSession.new(gd, llm, TestFixtures.tree(), codex_store)
	s1.ratings_background = false
	s1.new_game(8301, {
		"mode": "roll", "name": "Bất Tử Thử", "gender": "male", "origin": "tan_tu",
		"playthrough_mode": "one_life",
	})
	s1.pending_event = {}
	assert_false(s1.death_reloaded, "fresh One Life has death_reloaded == false")
	var pre_death_json: String = JSON.stringify(s1.to_dict())

	# 2. Player dies -> CodexStore permanently records a Lives entry with s1.playthrough_id.
	s1._end_life("Tử trận ngoài ý muốn", "", "duel")
	assert_true(codex_store.has_life_for_playthrough(s1.playthrough_id), "Codex recorded death for playthrough_id")

	# 3. Reload the pre-death save into a fresh session sharing the same profile CodexStore.
	var s_reloaded := GameSession.new(gd, llm, TestFixtures.tree(), codex_store)
	s_reloaded.ratings_background = false
	var load_r: Dictionary = s_reloaded.load_dict(JSON.parse_string(pre_death_json))
	assert_true(bool(load_r.ok), "pre-death save loaded")
	assert_true(s_reloaded.death_reloaded, "AC-CK-21: loading pre-death One Life save marks death_reloaded = true")
	assert_true(bool(GameQuery.playthrough_meta(s_reloaded).death_reloaded), "GameQuery exposes death_reloaded")

	# Saving and re-loading keeps death_reloaded = true even on an empty CodexStore.
	var resaved: String = JSON.stringify(s_reloaded.to_dict())
	var s_again := GameSession.new(gd, llm, TestFixtures.tree(), CodexStore.new(""))
	s_again.ratings_background = false
	assert_true(bool(s_again.load_dict(JSON.parse_string(resaved)).ok))
	assert_true(s_again.death_reloaded, "AC-CK-21: death_reloaded persists in the save file")

	# 4. Subsequent achievements on reloaded save: normal achievements earn, one_life prestige ones are blocked.
	var book := Achievements.new(gd, AchievementStore.new())
	s_reloaded.player.realm_index = 2
	var earned: Array = _ids(book.check(s_reloaded))
	assert_true(earned.has("truc_co") and earned.has("ket_dan"), "normal achievements still earn on reloaded save")
	assert_false(earned.has("one_life_truc_co"), "AC-CK-21: one_life_truc_co blocked after reload")
	assert_false(earned.has("one_life_ket_dan"), "AC-CK-21: one_life_ket_dan blocked after reload")

	# 5. Contrast: unbroken One Life earns one_life prestige achievements.
	var s_clean := GameSession.new(gd, llm, TestFixtures.tree(), codex_store)
	s_clean.ratings_background = false
	s_clean.new_game(8302, {
		"mode": "roll", "name": "Nhất Sinh Thuần", "gender": "male", "origin": "tan_tu",
		"playthrough_mode": "one_life",
	})
	var book_clean := Achievements.new(gd, AchievementStore.new())
	s_clean.player.realm_index = 1
	var earned_clean: Array = _ids(book_clean.check(s_clean))
	assert_true(earned_clean.has("one_life_truc_co"), "unbroken One Life earns one_life_truc_co")

	# 6. Contrast: Continue mode never earns one_life prestige achievements.
	var s_cont := GameSession.new(gd, llm, TestFixtures.tree(), codex_store)
	s_cont.ratings_background = false
	s_cont.new_game(8303, {
		"mode": "roll", "name": "Luân Hồi Giả", "gender": "male", "origin": "tan_tu",
		"playthrough_mode": "continue",
	})
	var book_cont := Achievements.new(gd, AchievementStore.new())
	s_cont.player.realm_index = 4
	var earned_cont: Array = _ids(book_cont.check(s_cont))
	assert_true(earned_cont.has("nguyen_anh"), "Continue earns normal achievements")
	assert_false(earned_cont.has("one_life_truc_co") or earned_cont.has("one_life_hoa_than"), "AC-CK-21: Continue never earns one_life achievements")

	s1.shutdown()
	s_reloaded.shutdown()
	s_again.shutdown()
	s_clean.shutdown()
	s_cont.shutdown()
