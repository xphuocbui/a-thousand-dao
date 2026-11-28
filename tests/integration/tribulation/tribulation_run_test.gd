extends DaoTestSuite
## Heavenly Tribulation (#22) Session & World integration tests:
## AC-TK-05 (fated NPCs never trigger tribulation),
## AC-TK-07 (1-season lifespan check runs after survival),
## AC-TK-10..12 (atomic abort/reload, reload determinism, JSON-only boss in real Combat),
## AC-TK-44..57 (survival advancement, tempered buff + save/reload, rewards, stock spend,
## failure death/no-advance/no-cap9/no-mercy), AC-TK-80..81 (preview purity & escape warning).


func _gd_tk(enabled: bool, extra_bosses: Array = []) -> GameData:
	var base := game_data()
	var files_copy: Dictionary = base.registry.files().duplicate()
	var tk_rules: Dictionary = base.file("tribulation_rules").duplicate(true)
	tk_rules["tribulation_enabled"] = enabled
	files_copy["tribulation_rules"] = tk_rules
	if not extra_bosses.is_empty():
		var tb: Dictionary = base.file("tribulation_bosses").duplicate(true)
		var arr: Array = Array(tb.get("bosses", [])).duplicate(true)
		for b in extra_bosses:
			arr.append(b)
		tb["bosses"] = arr
		files_copy["tribulation_bosses"] = tb
	var wg: Dictionary = base.file("world_generation").duplicate(true)
	wg["people"]["world_cultivators"] = 45
	wg["people"]["world_cultivators_min"] = 0
	files_copy["world_generation"] = wg
	var rk: Dictionary = base.file("combat_rankings").duplicate(true)
	rk["enabled"] = false
	files_copy["combat_rankings"] = rk
	var gd := GameData.new()
	gd.setup(DataRegistry.from_files(files_copy))
	return gd


func _session(gd: GameData, seed_v: int = 7101) -> GameSession:
	var llm := LlmService.new(gd)
	llm.enabled = false
	var s := GameSession.new(gd, llm, TestFixtures.tree())
	s.ratings_background = false
	s.new_game(seed_v, {
		"mode": "custom", "name": "Độ Kiếp", "gender": "male", "origin": "tan_tu",
		"thien_phu": {"ngo_tinh": 95, "dao_tam": 95, "can_cot": 90, "than_hon": 90, "khi_van": 80, "mi_luc": 60},
		"purities": {"hoa": 90, "kim": 80}, "variants": [], "edge": true,
	})
	s.pending_event = {}
	return s


func _prep_ns_gate(s: GameSession) -> void:
	var c: Character = s.player
	c.realm_index = 3   # Nascent Soul -> Deity Transformation (listed step)
	c.level = Ladder.band(s.gd, 3)[1]
	c.level_peak = c.level
	c.stage = Ladder.stage_of_level(s.gd, c.level)
	c.tu_vi = Ladder.bar_cost(s.gd, 3)
	c.has_insight = true
	c.tam_ma = 0.0
	c.vitality = 1.0
	c.age = 500.0
	var tag: String = str(s.gd.realm(4).entry_requirement.item_tag)
	s.alchemy.add_pills(c, tag, 3, 2)
	s.sync_player()


static func _stub_result(winner: FightResult.Winner, ending: FightResult.Ending, hp_end: float, hp_max: float, qi_end: float, qi_max: float, secs: float = 12.0) -> FightResult:
	var r := FightResult.new()
	r.winner = winner
	r.ending = ending
	r.seconds = secs
	r.deciding_layer = 0
	var ae := FighterEnd.new()
	ae.health = hp_end
	ae.health_max = hp_max
	ae.linh_luc = qi_end
	ae.linh_luc_base = qi_max
	ae.down = hp_end <= 0.0
	r.a_end = ae
	var be := FighterEnd.new()
	be.health = 0.0 if winner == FightResult.Winner.A else 500.0
	be.health_max = 1000.0
	be.down = winner == FightResult.Winner.A
	r.b_end = be
	return r


func test_fated_npcs_at_gates_never_trigger_tribulation_ac05() -> void:
	var gd := _gd_tk(true)
	var s := _session(gd, 7102)
	# Seed 6 fated Nascent Soul great-perfection NPCs ready to break through to Deity Transformation.
	var fated_ids: Array = []
	for i in 6:
		var pid: String = s.builds.create_person(s.rng, {
			"realm_index": 3, "stage": 3, "age": 300.0,
			"location_id": s.player.location_id,
		})
		var rec: Dictionary = s.db.get_record("people", pid)
		rec["bt_fate"] = {"realm": 3, "ok": true}
		fated_ids.append(pid)

	var events_before: int = s.db.count("events")
	var rng_tick := RandomNumberGenerator.new()
	rng_tick.seed = 9090
	var adv: Dictionary = s.ticker.advance_seasons(rng_tick, s.year, s.season, 100)
	var crossed: int = 0
	for pid in fated_ids:
		var rec: Dictionary = s.db.get_record("people", str(pid))
		if int(rec.get("realm_index", 0)) >= 4:
			crossed += 1
	assert_true(crossed >= 1, "at least one fated NPC crossed into Deity Transformation during 100 ticks")
	assert_true(s.last_tribulation.is_empty(), "AC-TK-05: NPC breakthroughs never ran TribulationRunner")
	var tk_evs: Array = s.db.all("events").filter(func(e):
		var et: String = str(e.get("type", ""))
		return et == "player_tribulation_survived" or et == "player_tribulation_failed"
	)
	assert_eq(tk_evs.size(), 0, "AC-TK-05: zero tribulation events logged for NPCs")
	assert_true(s.db.count("events") >= events_before, "events table intact")
	assert_true(Array(adv.news).size() > 0, "world ticked normally")
	s.shutdown()


func test_abort_reload_equals_pre_attempt_and_reload_matches_uninterrupted_ac10_ac11() -> void:
	var gd := _gd_tk(true)
	var s1 := _session(gd, 7103)
	_prep_ns_gate(s1)
	# Force guaranteed breakthrough roll so real Combat tribulation runs deterministically.
	s1.gd.breakthrough_rules()["chance_min"] = 1.0
	var pre_year: int = s1.year
	var pre_season: int = s1.season
	var pre_rng_state: int = s1.rng.state
	var pre_items: int = s1.db.count("items")
	var pre_events: int = s1.db.count("events")
	var pre_save: Dictionary = s1.to_dict()
	var pre_json: String = JSON.stringify(pre_save, "", false, true)

	var r1: Dictionary = s1.breakthrough()
	assert_true(bool(r1.ok), "breakthrough with real Combat tribulation executed")
	assert_false(s1.last_tribulation.is_empty(), "tribulation ran")
	var tk1: Dictionary = s1.last_tribulation.duplicate(true)
	assert_true(Array(tk1.waves).size() >= 1, "at least wave 1 ran in real Combat")

	# AC-TK-10 & AC-TK-11: reload pre-attempt save -> equals pre-attempt state, and identical attempt produces identical draw & result.
	var s_base := _session(gd, 9998)
	assert_true(bool(s_base.load_dict(JSON.parse_string(pre_json)).ok), "baseline reload ok")
	var s2 := _session(gd, 9999)
	var load_res: Dictionary = s2.load_dict(JSON.parse_string(pre_json))
	assert_true(bool(load_res.ok), "pre-attempt save loaded")
	assert_eq(s2.year, pre_year, "AC-TK-10: year restored")
	assert_eq(s2.season, pre_season, "AC-TK-10: season restored")
	assert_eq(s2.rng.state, pre_rng_state, "AC-TK-10: rng state restored")
	assert_eq(s2.db.count("items"), pre_items, "AC-TK-10: items count restored")
	assert_eq(s2.db.count("events"), pre_events, "AC-TK-10: events count restored")
	assert_true(JSON.stringify(s2.to_dict(), "", false, true) == JSON.stringify(s_base.to_dict(), "", false, true), "AC-TK-10: reloaded save matches pre-attempt state deterministically")
	s_base.shutdown()

	var r2: Dictionary = s2.breakthrough()
	assert_true(bool(r2.ok), "reloaded breakthrough executed")
	var tk2: Dictionary = s2.last_tribulation
	assert_eq(int(tk2.tribulation_id), int(tk1.tribulation_id), "AC-TK-11: identical tribulation_id after reload")
	assert_eq(bool(tk2.survived), bool(tk1.survived), "AC-TK-11: identical survival outcome")
	assert_eq(int(tk2.waves_cleared), int(tk1.waves_cleared), "AC-TK-11: identical waves_cleared")
	assert_eq(Array(tk2.waves).size(), Array(tk1.waves).size(), "AC-TK-11: identical wave count")
	for i in Array(tk1.waves).size():
		assert_eq(str(tk2.waves[i].boss_id), str(tk1.waves[i].boss_id), "AC-TK-11: wave %d identical boss" % (i + 1))
		assert_eq(int(tk2.waves[i].fight_seed), int(tk1.waves[i].fight_seed), "AC-TK-11: wave %d identical fight_seed" % (i + 1))
		assert_eq(str(tk2.waves[i].ending), str(tk1.waves[i].ending), "AC-TK-11: wave %d identical ending" % (i + 1))
	s1.shutdown()
	s2.shutdown()


func test_json_only_fixture_boss_completes_real_combat_ac12() -> void:
	var custom_boss := {
		"id": "tk_fixture_json_only",
		"name": "Huyền Lôi Kiếm Chủ (Fixture Thunder Blade)",
		"provisional": true,
		"steps": ["nguyen_anh_to_hoa_than"],
		"weight": 1.0,
		"main_kind": "qi",
		"boss_pool_mult": 1.05,
		"off_estimate": 420.0,
		"ehp_estimate": 7800.0,
		"off_shares": {"body": 0.20, "qi": 0.65, "soul": 0.15},
		"resist": {"lightning": 30.0},
		"build": {
			"layers": [220, 35, 30, 15, 10],
			"n_body": 1.0,
			"n_qi": 1.0,
			"ward": {"ws_base": 75.0, "block": 12.0},
			"purity": {"thunder": 80.0},
			"divine_sense": 4.0,
			"stage_mult": 1.0,
			"arts": [
				{"lib": "forked-light"},
				{"lib": "rolling-thunder"},
			],
		},
		"reward": {"kind": "material", "template": "loi_kich_moc", "qty": 2, "rarity": 5, "label": "Lôi Kích Mộc ×2"},
	}
	var gd := _gd_tk(true, [custom_boss])
	assert_eq(TribulationRules.lint(gd), PackedStringArray(), "AC-TK-12: JSON-only fixture boss passes TribulationRules.lint")
	var s := _session(gd, 7104)
	_prep_ns_gate(s)
	var prof: FighterProfile = FighterCompiler.compile(s.player, gd, s.db, s.sheet())
	var out: Dictionary = TribulationRunner.run({
		"world_seed": 7104,
		"char_id": s.player.id,
		"step_id": "nguyen_anh_to_hoa_than",
		"pool": [custom_boss],
		"wave_count": 1,
		"player_profile": prof,
		"prep": {},
		"place_tags": ["vein"],
		"start_vitality": 1.0,
		"abs_season": 10,
		"log_enabled": true,
	}, gd)
	assert_true(bool(out.ok), "AC-TK-12: JSON-only boss ran cleanly through real CombatService: %s" % str(out.get("error", "")))
	assert_eq(Array(out.waves).size(), 1, "1 wave resolved")
	assert_true(Array(out.waves[0].log_rows).size() > 0, "real Combat log rows produced")
	s.shutdown()


func test_survival_advances_realm_buff_reward_stock_log_and_lifespan_ac44_to_54_ac07() -> void:
	var gd := _gd_tk(true)
	gd.breakthrough_rules()["chance_min"] = 1.0
	var s := _session(gd, 7105)
	_prep_ns_gate(s)
	# AC-TK-07: leave only 0.25 years (1 season) of lifespan before breakthrough; surviving lifts DT lifespan!
	var life_before: float = CultivationRules.lifespan(s.player, gd, s.sheet()).total
	s.player.age = life_before - 0.25
	# Give 3 combat talismans; wave 1 & 2 spend 1 each -> total spent = 2, remaining = 1 (AC-TK-53).
	var tal: Dictionary = s.items.talisman("hoa_cau", 3)
	tal["owner_id"] = s.player.id
	var tal_id: String = s.db.add("items", tal)

	var bt_signals: Array = []
	s.breakthrough_succeeded.connect(func(r_idx: int): bt_signals.append(r_idx))

	s.tribulation_fight_fn = func(_req: FightRequest, wctx: Dictionary) -> FightResult:
		var wk: int = int(wctx.wave)
		if wk <= 2:
			wctx.spent_out["hoa_cau"] = 1
		# AC-TK-47: survive wave 3 at 1 HP
		var hp_left: float = 1.0 if wk == 3 else 4000.0
		return _stub_result(FightResult.Winner.A, FightResult.Ending.KNOCKOUT, hp_left, 6400.0, 2000.0, 4000.0, 14.0)

	var res: Dictionary = s.run(s.breakthrough)
	assert_true(bool(res.ok), "breakthrough succeeded")
	assert_false(s.life_over, "AC-TK-07 & AC-TK-47: survived at 1 HP and age check used new DT lifespan")
	assert_eq(s.player.realm_index, 4, "AC-TK-44: entered Deity Transformation")
	assert_eq(s.player.level, 101, "AC-TK-44: level 101 early DT")
	assert_eq(s.player.stage, 0, "AC-TK-44: early stage")
	assert_eq(s.player.tu_vi, 0.0, "AC-TK-44: bar reset to 0")
	assert_eq(s.player.vitality, 1.0, "AC-TK-48: full vitality restored on survival")
	assert_eq(bt_signals, [4], "AC-TK-45: breakthrough_succeeded fired exactly once after wave 3")

	# AC-TK-49: tribulation_tempered buff present in StatSheet and persists across save/reload.
	var sh_after: StatSheet = s.sheet()
	assert_true(sh_after.sources("attack_pct").any(func(m): return str(m.source) == "tribulation_tempered" and is_equal_approx(float(m.value), 30.0)), "AC-TK-49: attack_pct +30 from tribulation_tempered")
	assert_true(sh_after.sources("defense_pct").any(func(m): return str(m.source) == "tribulation_tempered" and is_equal_approx(float(m.value), 30.0)), "AC-TK-49: defense_pct +30 from tribulation_tempered")
	var saved_json: String = JSON.stringify(s.to_dict())
	var s_reloaded := _session(gd, 1111)
	assert_true(bool(s_reloaded.load_dict(JSON.parse_string(saved_json)).ok), "reloaded survived save")
	assert_true(s_reloaded.sheet().sources("attack_pct").any(func(m): return str(m.source) == "tribulation_tempered"), "AC-TK-49: tribulation_tempered persists after save/reload")
	s_reloaded.shutdown()

	# AC-TK-53: talisman stock decremented once (3 - 2 = 1).
	assert_eq(int(s.db.get_record("items", tal_id).get("qty", 0)), 1, "AC-TK-53: talisman stock decremented once to 1")

	# AC-TK-51 & AC-TK-52: pending reward choices offered and claimed into inventory.
	var choices: Array = Array(s.pending_tribulation_reward.get("choices", []))
	assert_true(choices.size() >= 1 and choices.size() <= 3, "AC-TK-51: reward choices offered from cleared waves")
	var items_before: int = s.db.items_of(s.player.id).size()
	var claim: Dictionary = s.claim_tribulation_reward(0)
	assert_true(bool(claim.ok), "AC-TK-51: reward claimed ok")
	assert_eq(s.db.items_of(s.player.id).size(), items_before + 1, "AC-TK-51: reward added to player inventory")
	assert_true(s.pending_tribulation_reward.is_empty(), "pending reward cleared after claim")

	# AC-TK-54: World DB record logged.
	var surv_evs: Array = s.db.events_of(s.player.id).filter(func(e): return str(e.get("type", "")) == "player_tribulation_survived")
	assert_eq(surv_evs.size(), 1, "AC-TK-54: tribulation survival logged in WorldDB")
	assert_eq(int(surv_evs[0].data.waves_cleared), 3, "AC-TK-54: waves_cleared == 3")
	s.shutdown()


func test_failure_on_wave_2_kills_without_advance_buff_reward_cap9_or_mercy_ac46_50_53_55_56_57() -> void:
	var gd := _gd_tk(true)
	gd.breakthrough_rules()["chance_min"] = 1.0
	var s := _session(gd, 7106)
	_prep_ns_gate(s)
	s.player.grant_capability(9)   # AC-TK-56: cap #9 must NOT drain tu_vi on tribulation boss defeat
	var tu_vi_before: float = s.player.tu_vi
	var tal: Dictionary = s.items.talisman("hoa_cau", 3)
	tal["owner_id"] = s.player.id
	var tal_id: String = s.db.add("items", tal)

	var bt_signals: Array = []
	s.breakthrough_succeeded.connect(func(r_idx: int): bt_signals.append(r_idx))

	s.tribulation_fight_fn = func(_req: FightRequest, wctx: Dictionary) -> FightResult:
		var wk: int = int(wctx.wave)
		if wk == 1:
			wctx.spent_out["hoa_cau"] = 1
			return _stub_result(FightResult.Winner.A, FightResult.Ending.KNOCKOUT, 3200.0, 6400.0, 2000.0, 4000.0, 10.0)
		return _stub_result(FightResult.Winner.B, FightResult.Ending.KNOCKOUT, 0.0, 6400.0, 500.0, 4000.0, 18.0)

	var res: Dictionary = s.run(s.breakthrough)
	assert_true(bool(res.ok), "breakthrough resolved failure")
	assert_true(s.life_over and not s.player.alive, "AC-TK-55: player died on wave 2 failure")
	assert_eq(s.player.realm_index, 3, "AC-TK-46: did NOT advance realm")
	assert_eq(bt_signals.size(), 0, "AC-TK-45: breakthrough_succeeded did NOT fire on failure")
	assert_true(s.player.tribulation_buffs.is_empty(), "AC-TK-50: no tempered buff on failure")
	assert_true(s.pending_tribulation_reward.is_empty(), "AC-TK-50: no reward choices on failure")
	assert_false(s.has_pending_event(), "AC-TK-57: no mercy/capture/taming event triggered")
	assert_eq(s.player.tu_vi, tu_vi_before, "AC-TK-56: capability #9 gained zero tu_vi from wave 1 boss")
	assert_eq(int(s.db.get_record("items", tal_id).get("qty", 0)), 2, "AC-TK-53: spent talisman still decremented once on death")

	var fail_evs: Array = s.db.events_of(s.player.id).filter(func(e): return str(e.get("type", "")) == "player_tribulation_failed")
	assert_eq(fail_evs.size(), 1, "AC-TK-55: tribulation failure logged in WorldDB")
	assert_eq(str(fail_evs[0].data.cause), "tribulation", "AC-TK-55: cause == tribulation")
	assert_eq(int(fail_evs[0].data.waves_cleared), 1, "AC-TK-55: waves_cleared == 1")
	assert_eq(int(fail_evs[0].data.fatal_wave), 2, "AC-TK-55: fatal_wave == 2")
	assert_true(str(fail_evs[0].data.fatal_boss) != "", "AC-TK-55: fatal_boss recorded")
	s.shutdown()


func test_tribulation_preview_pure_and_shows_pool_without_draw_ac80_81() -> void:
	var gd := _gd_tk(true)
	var s := _session(gd, 7107)
	_prep_ns_gate(s)
	var before: String = JSON.stringify(s.to_dict(), "", false, true)
	var pv: Dictionary = GameQuery.tribulation_preview(s)
	assert_eq(JSON.stringify(s.to_dict(), "", false, true), before, "AC-TK-80: preview is strictly read-only and never moves RNG")
	assert_true(bool(pv.enabled) and bool(pv.active), "active at Nascent Soul gate")
	assert_eq(int(pv.wave_count), 3, "wave_count == 3")
	assert_eq(Array(pv.pool).size(), 6, "all 6 starter pool bosses shown with weights")
	assert_false(pv.has("drawn"), "AC-TK-80: preview never reveals the drawn waves")
	s.shutdown()
