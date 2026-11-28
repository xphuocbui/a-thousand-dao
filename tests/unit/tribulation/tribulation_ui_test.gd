extends DaoTestSuite
## Wave 3 Track A3 UI & Terminal tests for Heavenly Tribulation (#22): AC-TK-80..83.
## Verifies TribulationScreen (attempt confirmation, boss pool, escape-art warning, no leaked draw,
## wave headers, fight summaries, step-by-step progression, Watch Fight replay signal, survival buff
## & reward picker, failure summary, ADR-0005 custom tooltips, accessibility_name), TerminalViews
## formatting helpers, and CharacterWindow tribulation bottleneck / tribulation_tempered readouts.


static func _find(root: Node, node_name: String) -> Node:
	return root.find_child(node_name, true, false)


static func _all_label_text(root: Node) -> String:
	var parts: PackedStringArray = []
	for l in root.find_children("*", "Label", true, false):
		parts.append((l as Label).text)
	return "\n".join(parts)


static func _sample_pool() -> Array:
	return [
		{
			"id": "tk_kim_loi_ton",
			"name": "Kim Lôi Tôn (Golden Thunder Sovereign)",
			"main_kind": "body",
			"weight": 2.0,
			"boss_pool_mult": 1.15,
			"off_estimate": 420.0,
			"ehp_estimate": 8200.0,
			"off_shares": {"body": 0.65, "qi": 0.25, "soul": 0.10},
			"resist": {"phys": 25.0, "lightning": 40.0},
			"arts": ["iron-spark", "anchor-drop", "bone-turning-palm"],
			"reward_label": "Lôi Kích Mộc ×3 (Lightning-Struck Wood)",
			"provisional": true,
		},
		{
			"id": "tk_thien_hoa_kiem",
			"name": "Thiên Hỏa Kiếp (Skyfire Tribulation)",
			"main_kind": "qi",
			"weight": 2.0,
			"boss_pool_mult": 1.10,
			"off_estimate": 430.0,
			"ehp_estimate": 7800.0,
			"off_shares": {"body": 0.20, "qi": 0.65, "soul": 0.15},
			"resist": {"fire": 40.0, "lightning": 40.0},
			"arts": ["forked-light", "rolling-thunder", "cut-the-horse"],
			"reward_label": "Địa Hỏa Tinh ×4 (Earth-Fire Essence)",
			"provisional": true,
		},
		{
			"id": "tk_tam_ma_loi_anh",
			"name": "Tâm Ma Lôi Ảnh (Heart-Demon Thunder Shade)",
			"main_kind": "soul",
			"weight": 1.0,
			"boss_pool_mult": 1.05,
			"off_estimate": 400.0,
			"ehp_estimate": 7600.0,
			"off_shares": {"body": 0.22, "qi": 0.30, "soul": 0.48},
			"resist": {"soul": 30.0, "lightning": 35.0},
			"arts": ["heart-lamp-lance", "mind-thorn", "forked-light"],
			"reward_label": "Linh Căn Quả (Spirit Root Fruit)",
			"provisional": true,
		},
	]


static func _sample_preview(has_escape: bool = false) -> Dictionary:
	return {
		"enabled": true,
		"active": true,
		"step_id": "nguyen_anh_to_hoa_than",
		"from_realm": "nguyen_anh",
		"to_realm": "hoa_than",
		"wave_count": 3,
		"pool": _sample_pool(),
		"setup": {
			"realm_index": 3,
			"realm_label": "Nguyên Anh Đại viên mãn",
			"vitality": 0.95,
			"diagram_id": "ngu_hanh_tran",
			"place_id": "pl_1",
			"place_tags": ["vein"],
			"arts": ["iron-spark", "forked-light", "wind-escape"] if has_escape else ["iron-spark", "forked-light"],
			"talismans": {"loi_phu": 2},
		},
		"has_escape_art": has_escape,
		"escape_warning": "Escape arts cannot flee a Heavenly Tribulation — fleeing fails the tribulation." if has_escape else "",
	}


static func _sample_confirm_view(has_escape: bool = false) -> Dictionary:
	return {
		"mode": "confirm",
		"preview": _sample_preview(has_escape),
		"chance": 0.222,
		"backlash": 12.0,
		"pill": "Hóa Thần Đan",
		"pill_quality": 3,
		"talisman": "held",
		"confirm_bare": false,
		"use_talisman": true,
		"burn_life": false,
		# Even if a caller accidentally passes a leaked draw key, confirm mode must never show it.
		"drawn": ["SECRET_LEAKED_WAVE_1"],
	}


static func _sample_result(survived: bool = true, step_mode: bool = false) -> Dictionary:
	var waves: Array = [
		{
			"wave": 1,
			"header": "Wave 1/3 — Kim Lôi Tôn (Golden Thunder Sovereign) | Start HP 100.0% · Qi 100.0%",
			"boss_id": "tk_kim_loi_ton",
			"boss_name": "Kim Lôi Tôn (Golden Thunder Sovereign)",
			"main_kind": "body",
			"m_eff": 1.15,
			"m_capped": false,
			"start_h": 1.0,
			"start_q": 1.0,
			"fight_seed": 1111,
			"winner": "A",
			"ending": "knockout",
			"seconds": 21.5,
			"health_end": 4200.0,
			"health_max": 6400.0,
			"qi_end": 1200.0,
			"qi_max": 2600.0,
			"deciding_layer": 0,
			"log_rows": [],
			"cleared": true,
		},
		{
			"wave": 2,
			"header": "Wave 2/3 — Thiên Hỏa Kiếp (Skyfire Tribulation) | Start HP 65.6% · Qi 74.2%",
			"boss_id": "tk_thien_hoa_kiem",
			"boss_name": "Thiên Hỏa Kiếp (Skyfire Tribulation)",
			"main_kind": "qi",
			"m_eff": 1.65,
			"m_capped": false,
			"start_h": 0.65625,
			"start_q": 0.742,
			"fight_seed": 2222,
			"winner": "A" if survived else "B",
			"ending": "knockout",
			"seconds": 32.0,
			"health_end": 2100.0 if survived else 0.0,
			"health_max": 6400.0,
			"qi_end": 650.0 if survived else 120.0,
			"qi_max": 2600.0,
			"deciding_layer": 1,
			"log_rows": [],
			"cleared": survived,
		},
	]
	if survived:
		waves.append({
			"wave": 3,
			"header": "Wave 3/3 — Tâm Ma Lôi Ảnh (Heart-Demon Thunder Shade) | Start HP 32.8% · Qi 53.0%",
			"boss_id": "tk_tam_ma_loi_anh",
			"boss_name": "Tâm Ma Lôi Ảnh (Heart-Demon Thunder Shade)",
			"main_kind": "soul",
			"m_eff": 2.3625,
			"m_capped": false,
			"start_h": 0.328125,
			"start_q": 0.53,
			"fight_seed": 3333,
			"winner": "A",
			"ending": "knockout",
			"seconds": 38.4,
			"health_end": 640.0,
			"health_max": 6400.0,
			"qi_end": 410.0,
			"qi_max": 2600.0,
			"deciding_layer": 2,
			"log_rows": [],
			"cleared": true,
		})
	var buff := {
		"step_id": "nguyen_anh_to_hoa_than",
		"source": "tribulation_tempered",
		"label": "Thiên Kiếp tôi luyện (Tribulation-Tempered)",
		"mods": [
			{"stat": "attack_pct", "value": 30.0},
			{"stat": "defense_pct", "value": 30.0},
		],
	}
	var rewards: Array = [
		{"kind": "material", "template": "loi_kich_moc", "qty": 3, "rarity": 5, "label": "Lôi Kích Mộc ×3 (Lightning-Struck Wood)"},
		{"kind": "material", "template": "dia_hoa_tinh", "qty": 4, "rarity": 4, "label": "Địa Hỏa Tinh ×4 (Earth-Fire Essence)"},
		{"kind": "treasure", "template": "linh_can_qua", "qty": 1, "rarity": 5, "label": "Linh Căn Quả (Spirit Root Fruit)"},
	]
	return {
		"ok": true,
		"step_mode": step_mode,
		"tribulation_id": 900123 if survived else 900456,
		"step_id": "nguyen_anh_to_hoa_than",
		"survived": survived,
		"final_ending": "survived" if survived else "failed",
		"fail_reason": "" if survived else "knockout",
		"waves_cleared": 3 if survived else 1,
		"wave_count": 3,
		"waves": waves,
		"fatal_wave": 0 if survived else 2,
		"fatal_boss": {} if survived else {"id": "tk_thien_hoa_kiem", "name": "Thiên Hỏa Kiếp (Skyfire Tribulation)"},
		"tempered_buff": buff if survived else {},
		"reward_choices": rewards if survived else [],
		"pending_reward": {"step_id": "nguyen_anh_to_hoa_than", "choices": rewards, "buff": buff} if survived else {},
		"notes": [],
	}


func _screen(v: Dictionary, locked: bool = false) -> TribulationScreen:
	var s: TribulationScreen = auto_free(TribulationScreen.new())
	add_child(s)
	s.show_view(v, "", locked)
	return s


func test_ac_tk_80_tribulation_screen_confirm_shows_odds_warning_pool_setup_and_no_draw() -> void:
	var sc: TribulationScreen = _screen(_sample_confirm_view(false))
	assert_eq(sc.kind(), "tribulation")
	assert_eq(sc.active_mode(), TribulationScreen.MODE_CONFIRM)
	assert_true(_find(sc, "TribulationWarningBanner") != null, "high-stakes warning banner shown")
	assert_true(_find(sc, "OddsSummary") != null, "odds summary inset shown")
	assert_true(_find(sc, "SetupSummary") != null, "player setup summary inset shown")
	assert_true(_find(sc, "BossPool") != null, "boss pool inset shown")
	assert_true(_find(sc, "DrawHiddenNote") != null, "explicitly notes draw is hidden")
	assert_true(_find(sc, "EscapeArtWarning") == null, "escape-art warning hidden when no escape art is slotted")

	var txt: String = _all_label_text(sc)
	assert_true(txt.contains("22.2 %"), "shows pill roll chance")
	assert_true(txt.contains("3 consecutive boss waves"), "shows wave_count")
	assert_true(txt.contains("Kim Lôi Tôn"), "pool boss 1 shown")
	assert_true(txt.contains("Thiên Hỏa Kiếp"), "pool boss 2 shown")
	assert_true(txt.contains("Tâm Ma Lôi Ảnh"), "pool boss 3 shown")
	assert_true(txt.contains("Weight 2.0 (40%)"), "shows boss draw weight and share")
	assert_true(txt.contains("ngu_hanh_tran"), "shows player setup formation")
	assert_true(txt.contains("vein, tribulation"), "shows ground tags including tribulation")
	assert_false(txt.contains("SECRET_LEAKED_WAVE_1"), "never shows any pre-rolled draw (AC-TK-80)")

	var got: Array = []
	sc.action_requested.connect(func(a: String, args: Array): got.append([a, args]))
	var cancelled: Array = []
	sc.confirm_cancelled.connect(func(): cancelled.append(true))
	(_find(sc, "ConfirmAttempt") as Button).pressed.emit()
	(_find(sc, "BackOut") as Button).pressed.emit()
	assert_eq(got, [["breakthrough", [false, true, false]]], "Confirm Attempt emits breakthrough action")
	assert_eq(cancelled.size(), 1, "Back out emits confirm_cancelled")


func test_ac_tk_81_tribulation_screen_escape_art_warning_only_when_slotted() -> void:
	var sc: TribulationScreen = _screen(_sample_confirm_view(true))
	var warn: Node = _find(sc, "EscapeArtWarning")
	assert_true(warn != null, "escape-art warning shown when escape art is slotted (AC-TK-81)")
	var lbl: Label = _find(sc, "EscapeArtWarningLabel") as Label
	assert_true(lbl != null and lbl.text.contains("Escape arts cannot flee"), "warning explains fleeing fails tribulation")


func test_ac_tk_82_tribulation_screen_wave_headers_summary_step_mode_and_watch_fight_signal() -> void:
	# Step-by-step progression reveals wave 1 first, then wave 2, wave 3, then final outcome.
	var sc: TribulationScreen = _screen(_sample_result(true, true))
	assert_eq(sc.active_mode(), TribulationScreen.MODE_RESULT)
	assert_eq(sc.revealed_count(), 1, "step_mode starts with wave 1 revealed")
	assert_false(sc.showing_final(), "final outcome held until waves revealed")
	assert_true(_find(sc, "WaveHeader_1") != null)
	assert_true(_find(sc, "WaveHeader_2") == null, "wave 2 not revealed yet")
	assert_true(_find(sc, "NextWave") is Button)

	var h1: Label = _find(sc, "WaveHeader_1") as Label
	assert_eq(h1.text, "Wave 1 / 3 — Kim Lôi Tôn (Golden Thunder Sovereign) | Start HP 100% · Qi 100%")
	var s1: Label = _find(sc, "WaveSummary_1") as Label
	assert_true(s1.text.contains("Knockout") and s1.text.contains("21.5 s") and s1.text.contains("Body (Physical)"),
		"wave 1 summary names ending, time, HP/Qi, and deciding layer: %s" % s1.text)

	# Watch Fight signal emits wave index and fight replay payload for FightScreen
	var watched: Array = []
	sc.watch_fight_requested.connect(func(idx: int, data: Dictionary): watched.append([idx, data]))
	(_find(sc, "WatchFight_1") as Button).pressed.emit()
	assert_eq(watched.size(), 1, "WatchFight_1 emits watch_fight_requested")
	assert_eq(int(watched[0][0]), 0, "wave_index is 0-based")
	var payload: Dictionary = watched[0][1]
	assert_eq(str(payload.boss_id), "tk_kim_loi_ton")
	assert_eq(int(payload.fight_seed), 1111)
	assert_eq(int(payload.deciding_layer), 0)

	# Advance waves -> reveal wave 2, wave 3, then final result
	(_find(sc, "NextWave") as Button).pressed.emit()
	assert_eq(sc.revealed_count(), 2)
	var h2: Label = _find(sc, "WaveHeader_2") as Label
	assert_true(h2 != null and h2.text.begins_with("Wave 2 / 3 — Thiên Hỏa Kiếp") and h2.text.contains("Start HP 65.6%") and h2.text.contains("Qi 74.2%"),
		"wave 2 header matches AC-TK-82: %s" % (h2.text if h2 != null else "null"))
	(_find(sc, "NextWave") as Button).pressed.emit()
	assert_eq(sc.revealed_count(), 3)
	assert_true(_find(sc, "ShowResult") is Button, "ShowResult offered after last wave")
	(_find(sc, "ShowResult") as Button).pressed.emit()
	assert_true(sc.showing_final(), "final result revealed")
	assert_true(_find(sc, "TemperedBuffPanel") != null)


func test_ac_tk_83_tribulation_screen_survival_buff_and_reward_choice_signal() -> void:
	var sc: TribulationScreen = _screen(_sample_result(true, false))
	assert_true(_find(sc, "TemperedBuffPanel") != null, "tribulation_tempered buff panel shown")
	assert_true(_find(sc, "RewardPicker") != null, "reward choice picker shown")
	var txt: String = _all_label_text(sc)
	assert_true(txt.contains("tribulation_tempered") and txt.contains("60 W"), "buff source and 60 W shown")
	assert_true(txt.contains("+30%") and txt.contains("attack_pct") and txt.contains("defense_pct"), "buff stat mods shown")
	assert_true(txt.contains("Lôi Kích Mộc") and txt.contains("Địa Hỏa Tinh") and txt.contains("Linh Căn Quả"), "all 3 reward choices shown")

	var picked: Array = []
	sc.action_requested.connect(func(a: String, args: Array): picked.append([a, args]))
	(_find(sc, "ChooseReward_1") as Button).pressed.emit()
	assert_eq(picked, [["choose_tribulation_reward", [1]]], "ChooseReward_1 emits choose_tribulation_reward with index 1")

	var cont: Array = []
	sc.continue_requested.connect(func(ok: bool): cont.append(ok))
	(_find(sc, "ContinueAfterTribulation") as Button).pressed.emit()
	assert_eq(cont, [true])


func test_tribulation_screen_failure_summary_names_fatal_wave_boss_and_layer() -> void:
	var sc: TribulationScreen = _screen(_sample_result(false, false))
	assert_true(_find(sc, "FailureSummary") != null, "failure summary rendered")
	assert_true(_find(sc, "TemperedBuffPanel") == null, "no buff panel on failure")
	assert_true(_find(sc, "RewardPicker") == null, "no reward picker on failure")
	var head: Label = _find(sc, "FailureHeadline") as Label
	var det: Label = _find(sc, "FailureDetail") as Label
	assert_true(head.text.contains("Wave 2") and head.text.contains("Thiên Hỏa Kiếp"), "names fatal wave and boss")
	assert_true(det.text.contains("Qi (Elemental)") and det.text.contains("1 / 3"), "names deciding layer and waves cleared")


func test_tribulation_screen_uses_custom_tooltips_and_accessibility_names() -> void:
	for v in [_sample_confirm_view(true), _sample_result(true, false)]:
		var sc: TribulationScreen = _screen(v)
		for ctrl in sc.find_children("*", "Control", true, false):
			assert_eq((ctrl as Control).tooltip_text, "", "zero built-in tooltip_text on %s (ADR-0005)" % ctrl.name)
		for btn in sc.find_children("*", "Button", true, false):
			var b: Button = btn as Button
			assert_true(b.accessibility_name != "", "button %s has accessibility_name" % b.name)
		assert_true(sc.first_focus() != null, "first_focus returns a valid Control")


func test_ac_tk_80_81_terminal_views_preview_pool_escape_warning_and_no_draw() -> void:
	var io := TerminalIO.new()
	io.color = false
	var prev_no_esc: Dictionary = _sample_preview(false)
	prev_no_esc["drawn"] = ["LEAKED_BOSS_NEVER_PRINT"]
	var odds := {"chance": 0.222, "pill": {"name": "Hóa Thần Đan", "quality": 3}, "backlash": 12.0}
	var lines: Array = TerminalViews.tribulation_preview(prev_no_esc, io, odds)
	var joined: String = "\n".join(lines)
	assert_true(joined.contains("22.2%"), "terminal preview shows pill roll chance")
	assert_true(joined.contains("DEATH"), "terminal preview shows high-stakes warning")
	assert_true(joined.contains("Waves: 3"), "terminal preview shows wave_count")
	assert_true(joined.contains("Kim Lôi Tôn") and joined.contains("weight 2.0 (40%)"), "terminal preview lists boss pool + weights")
	assert_true(joined.contains("ngu_hanh_tran") and joined.contains("vein, tribulation"), "terminal preview lists setup + ground tags")
	assert_false(joined.contains("Escape Art"), "no escape-art warning when none slotted")
	assert_false(joined.contains("LEAKED_BOSS_NEVER_PRINT"), "never prints a pre-rolled draw")

	var lines_esc: Array = TerminalViews.tribulation_preview(_sample_preview(true), io, odds)
	var joined_esc: String = "\n".join(lines_esc)
	assert_true(joined_esc.contains("WARNING (Escape Art)") and joined_esc.contains("Escape arts cannot flee"),
		"terminal preview warns about slotted escape art (AC-TK-81)")


func test_ac_tk_82_83_terminal_views_wave_headers_survival_buff_rewards_and_failure() -> void:
	var io := TerminalIO.new()
	io.color = false
	var surv: Array = TerminalViews.tribulation_result(_sample_result(true, false), io)
	var s_txt: String = "\n".join(surv)
	assert_true(s_txt.contains("Wave 1 / 3 — Kim Lôi Tôn (Golden Thunder Sovereign) | Start HP 100% · Qi 100%"), "AC-TK-82 wave 1 header")
	assert_true(s_txt.contains("Wave 2 / 3 — Thiên Hỏa Kiếp (Skyfire Tribulation) | Start HP 65.6% · Qi 74.2%"), "AC-TK-82 wave 2 header")
	assert_true(s_txt.contains("Wave 3 / 3 — Tâm Ma Lôi Ảnh (Heart-Demon Thunder Shade) | Start HP 32.8% · Qi 53%"), "AC-TK-82 wave 3 header")
	assert_true(s_txt.contains("deciding layer: Body (Physical)") and s_txt.contains("deciding layer: Soul"), "fight summaries include deciding layer")
	assert_true(s_txt.contains("LASTING BUFF") and s_txt.contains("tribulation_tempered") and s_txt.contains("+30% attack_pct"), "AC-TK-83 buff readout")
	assert_true(s_txt.contains("1) Lôi Kích Mộc") and s_txt.contains("2) Địa Hỏa Tinh") and s_txt.contains("3) Linh Căn Quả"), "AC-TK-83 numbered rewards")

	var fail: Array = TerminalViews.tribulation_result(_sample_result(false, false), io)
	var f_txt: String = "\n".join(fail)
	assert_true(f_txt.contains("FAILED (1/3)") and f_txt.contains("Wave 2 against Thiên Hỏa Kiếp"), "failure names fatal wave and boss")
	assert_true(f_txt.contains("No lasting buff or reward granted"), "failure confirms no buff/reward")


func test_character_window_surfaces_tribulation_bottleneck_pool_escape_warning_and_tempered_buff() -> void:
	var v := {
		"id": "p_na", "name": "Hàn Lập", "alive": true, "is_player": true,
		"realm_label": "Nguyên Anh Đại viên mãn", "level": 100, "layer": 0,
		"sect": "", "rank": "", "age": 240.0, "lifespan": 1200.0, "power": 50000, "provisional": false,
		"cultivation": {
			"tu_vi": 10000.0, "requirement": 10000.0, "rate": 0.0, "seasons_to_next": -1, "held": true, "top": false,
			"bottleneck": {
				"tu_vi": 10000.0, "bar_cost": 10000.0, "full": true,
				"condition": "", "condition_met": true,
				"pill": "Hóa Thần Đan", "pill_quality": 2, "talisman": "held",
				"chance": 0.25, "backlash": 15.0, "bare_attempts": 0, "bare_cap": 3,
				"tribulation": _sample_preview(true),
			},
		},
		"tribulation_buffs": [{
			"step_id": "nguyen_anh_to_hoa_than",
			"source": "tribulation_tempered",
			"label": "Thiên Kiếp tôi luyện (Tribulation-Tempered)",
			"mods": [{"stat": "attack_pct", "value": 30.0}, {"stat": "defense_pct", "value": 30.0}],
		}],
		"roots": {"tier": "Song linh căn", "speed": 1.2, "elements": [{"id": "hoa", "name": "Hỏa", "purity": 80.0, "grade": "Thượng phẩm", "role": "attack"}], "variants": []},
		"talents": [{"id": "can_cot", "name": "Căn cốt", "value": 70.0, "grade": "Thượng", "bonus": 0}],
		"vitals": [{"key": "health", "label": "Health (khí huyết)", "value": 6400.0, "max": 6400.0}],
		"combat": [{"key": "block", "label": "Block", "value": 12.0}],
		"slots": [{"slot": "main", "index": 0, "tech": {}}, {"slot": "aux", "index": 0, "tech": {}}],
		"known": [], "speed_label": "fire = x1.00", "gear": [], "crafts": [],
		"dao_do": {"open": 20, "unspent": 2},
		"fate": {"origin": "Tán tu", "background": "", "birth_mode": "thien_dinh", "perks": []},
		"breakdowns": {"rate": {"total": 0.0, "lines": []}, "lifespan": {"total": 1200.0, "lines": []}},
	}
	var w: CharacterWindow = auto_free(CharacterWindow.new())
	add_child(w)
	w.show_view(v, "", false)

	assert_true(_find(w, "TribulationStatus") != null, "CharacterWindow shows TribulationStatus in bottleneck")
	assert_true(_find(w, "TribulationEscapeWarning") != null, "CharacterWindow surfaces escape-art warning")
	assert_true(_find(w, "TribulationTemperedBadge") != null, "CharacterWindow surfaces tribulation_tempered buff badge on Overview")
	assert_true(_find(w, "TribulationPoolPreview") == null, "pool preview collapsed initially")

	# Expand pool preview
	(_find(w, "ToggleTribulationPool") as Button).pressed.emit()
	assert_true(_find(w, "TribulationPoolPreview") != null, "pool preview expands on toggle")
	assert_true(_all_label_text(_find(w, "TribulationPoolPreview")).contains("Kim Lôi Tôn"), "expanded pool lists bosses")

	# Arm breakthrough -> shows tribulation armed warning while keeping standard ask line
	(_find(w, "AttemptBreakthrough") as Button).pressed.emit()
	assert_true(_find(w, "TribulationArmedWarning") != null, "armed breakthrough warns about Heavenly Tribulation")

	# Fate tab also lists the tribulation_tempered buff
	w.open_tab("fate")
	assert_true(_find(w, "FateTribulationBuff") != null, "Fate tab shows tribulation_tempered buff")
	assert_eq(w.section_keys(), ["fate", "lifespan"], "section_keys unchanged")


func test_live_game_query_preview_and_result_roundtrip_into_screen_and_terminal() -> void:
	var gd: GameData = game_data().duplicate_for_test() if game_data().has_method("duplicate_for_test") else GameData.load_from("res://assets/data")
	gd.file("tribulation_rules")["tribulation_enabled"] = true
	var llm := LlmService.new(gd)
	llm.enabled = false
	var s := GameSession.new(gd, llm, TestFixtures.tree())
	s.ratings_background = false
	s.db = WorldDB.new()
	s.year = 1400
	s.season = 0
	s.seed_value = 7777
	s.rng.seed = 7777
	var pl_id: String = s.db.add("places", {
		"name": "Lôi Sơn", "type": "mountain", "kind": "wild", "region_id": "",
		"density": 2.5, "danger": 3, "market": false, "bounties": false, "links": [], "sect_id": "",
		"qi": {"land_density": 2.5, "shares": {"hoa": 0.5, "kim": 0.5}, "variants": []},
	})
	var p := TestFixtures.character({"hoa": 80, "kim": 70}, 70, 3)
	p.name = "Lôi Tu"
	p.stage = 3
	p.level = 100
	p.tu_vi = Ladder.bar_cost(gd, 3)
	p.location_id = pl_id
	p.home_id = pl_id
	p.id = s.db.add("people", p.to_dict())
	s.player = p
	s._wire()
	s.sync_player()

	var preview: Dictionary = GameQuery.tribulation_preview(s)
	assert_true(bool(preview.get("active", false)), "GameQuery.tribulation_preview active at NS GP")
	assert_eq(int(preview.get("wave_count", 0)), 3)
	assert_true(Array(preview.get("pool", [])).size() >= 6, "full 6-boss pool exposed")

	var sc: TribulationScreen = _screen(preview)
	assert_eq(sc.active_mode(), TribulationScreen.MODE_CONFIRM)
	assert_true(_find(sc, "BossCard_tk_kim_loi_ton") != null, "renders real boss pool record from GameQuery")

	var io := TerminalIO.new()
	io.color = false
	var t_lines: Array = TerminalViews.tribulation_preview_for(s, io)
	assert_true("\n".join(t_lines).contains("Kim Lôi Tôn"), "TerminalViews.tribulation_preview_for formats live GameQuery preview")
