extends DaoTestSuite
## Codex & Karmic Carryover (#12) Playthrough Modes integration tests:
## AC-CK-01 (mode stored & immutable in save),
## AC-CK-02 (One Life death ends playthrough, writes Lives entry, no succession),
## AC-CK-03 (loading pre-death save resumes play while Codex keeps death Lives entry).


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


func _session(gd: GameData, store: CodexStore, mode: String, seed_v: int = 8101) -> GameSession:
	var llm := LlmService.new(gd)
	llm.enabled = false
	var s := GameSession.new(gd, llm, TestFixtures.tree(), store)
	s.ratings_background = false
	s.new_game(seed_v, {
		"mode": "roll", "name": "Nhất Sinh Giả", "gender": "male", "origin": "tan_tu",
		"playthrough_mode": mode,
	})
	s.pending_event = {}
	return s


func test_playthrough_mode_persisted_and_immutable_in_save_ac01() -> void:
	var gd := _small_gd()
	var store := CodexStore.new("")
	var s_one := _session(gd, store, "one_life", 8101)
	var s_cont := _session(gd, store, "continue", 8102)

	assert_eq(s_one.playthrough_mode, "one_life", "One Life set at new_game")
	assert_eq(s_cont.playthrough_mode, "continue", "Continue set at new_game")
	assert_eq(s_one.playthrough_status, "active", "active at start")
	assert_eq(s_cont.karma, 0, "new Continue starts at 0 karma")

	# Round-trip save/load preserves mode verbatim.
	var d_one: Dictionary = JSON.parse_string(JSON.stringify(s_one.to_dict()))
	var d_cont: Dictionary = JSON.parse_string(JSON.stringify(s_cont.to_dict()))
	assert_eq(str(d_one.playthrough_mode), "one_life", "AC-CK-01: One Life saved")
	assert_eq(str(d_cont.playthrough_mode), "continue", "AC-CK-01: Continue saved")

	var llm := LlmService.new(gd)
	llm.enabled = false
	var loaded := GameSession.new(gd, llm, TestFixtures.tree(), store)
	assert_true(bool(loaded.load_dict(d_cont).ok), "Continue save loaded")
	assert_eq(loaded.playthrough_mode, "continue", "AC-CK-01: mode restored from save")
	assert_eq(str(GameQuery.playthrough_meta(loaded).playthrough_mode), "continue", "GameQuery reports mode")
	# Confirm no public mutator method exists to flip playthrough_mode after creation.
	assert_false(loaded.has_method("set_playthrough_mode"), "AC-CK-01: mode is immutable once created")

	s_one.shutdown()
	s_cont.shutdown()
	loaded.shutdown()


func test_one_life_death_ends_playthrough_writes_lives_and_blocks_succession_ac02() -> void:
	var gd := _small_gd()
	var store := CodexStore.new("")
	var s := _session(gd, store, "one_life", 8103)
	assert_eq(store.lives.size(), 0, "no Lives entry before death")

	var res: Dictionary = s.run(func():
		s._end_life("Tử chiến tại bí cảnh", "", "duel")
		return {"ok": true, "lines": []})
	assert_true(s.life_over, "life ended")
	assert_eq(s.playthrough_status, "ended", "AC-CK-02: One Life status == ended")
	assert_eq(s.karma, 0, "One Life earns 0 karma")
	assert_eq(store.lives.size(), 1, "AC-CK-02: Lives entry written to profile Codex")
	assert_eq(str(store.lives[0].playthrough_id), s.playthrough_id, "Lives entry tagged with playthrough_id")
	assert_eq(str(store.lives[0].mode), "one_life", "Lives entry records mode")

	var life_evs: Array = Array(res.events).filter(func(e): return str(e.kind) == "life_ended")
	assert_eq(life_evs.size(), 1, "life_ended event emitted")
	assert_eq(str(life_evs[0].summary.status), "ended", "summary reports ended status")

	# Succession actions are refused in One Life.
	assert_false(bool(s.succeed_rebirth({"name": "Nope"}).ok), "AC-CK-02: rebirth refused in One Life")
	assert_false(bool(s.succeed_heir("p1").ok), "AC-CK-02: heir succession refused in One Life")
	assert_false(bool(s.cultivate(1).ok), "actions blocked after death")
	s.shutdown()


func test_loading_pre_death_save_resumes_play_while_codex_retains_death_ac03() -> void:
	var gd := _small_gd()
	var store := CodexStore.new("")
	var s := _session(gd, store, "one_life", 8104)
	var pre_death_save: String = JSON.stringify(s.to_dict())

	# Player dies -> Codex records the Lives entry.
	s._end_life("Ngã xuống trước tâm ma")
	assert_eq(s.playthrough_status, "ended", "ended after death")
	assert_eq(store.lives.size(), 1, "Codex recorded the death")

	# Load the earlier pre-death save into a session sharing the same profile CodexStore.
	var llm := LlmService.new(gd)
	llm.enabled = false
	var s_resumed := GameSession.new(gd, llm, TestFixtures.tree(), store)
	s_resumed.ratings_background = false
	var load_r: Dictionary = s_resumed.load_dict(JSON.parse_string(pre_death_save))
	assert_true(bool(load_r.ok), "AC-CK-03: pre-death save loads cleanly")
	assert_false(s_resumed.life_over, "AC-CK-03: life is active again")
	assert_eq(s_resumed.playthrough_status, "active", "AC-CK-03: status is active")
	assert_true(bool(s_resumed.cultivate(1).ok), "AC-CK-03: resumed play runs normally")
	assert_eq(store.lives.size(), 1, "AC-CK-03: Codex retains the prior death's Lives entry")

	s.shutdown()
	s_resumed.shutdown()
