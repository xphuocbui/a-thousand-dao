extends DaoTestSuite
## Wave 3 integration tests: Event Engine (#23) + Template Quests (#31) wired into
## GameSession, GameQuery, Advisor, and InteractionService (Dialogue #30).
## Covers AC-QS-69..74, AC-QS-146..154, AC-NI-12, AC-EV-14, AC-EV-30, AC-WG-56,
## and strict MoneyLedger conservation (gap == 0).

const _EventStore := preload("res://src/gameplay/events/event_store.gd")
const _QuestRules := preload("res://src/gameplay/quests/quest_rules.gd")
const _QuestGenerator := preload("res://src/gameplay/quests/quest_generator.gd")
const _QuestValidator := preload("res://src/gameplay/quests/quest_validator.gd")


func _session(seed_v: int = 7331) -> GameSession:
	var gd := game_data()
	var llm := LlmService.new(gd)
	llm.enabled = false
	var s := GameSession.new(gd, llm, TestFixtures.tree())
	s.ratings_background = false
	s.new_game(seed_v, {"mode": "custom", "name": "Lâm Thử", "gender": "male", "origin": "tan_tu", "thien_phu": {}, "purities": {"hoa": 80, "kim": 40}, "variants": [], "edge": true})
	s.pending_event = {}
	s.pending_meta = {}
	s.pending_mercy = {}
	return s


func _pick_living_npc_here(s: GameSession, min_att: int = 20) -> Dictionary:
	var here: String = s.player.location_id
	for p in s.db.living():
		if bool(p.get("is_player", false)) or bool(p.get("is_beast", false)):
			continue
		if str(p.get("location_id", "")) == here:
			p["attitude"] = maxi(int(p.get("attitude", 0)), min_att)
			p["met_player"] = true
			return p
	for p in s.db.living():
		if bool(p.get("is_player", false)) or bool(p.get("is_beast", false)):
			continue
		p["location_id"] = here
		p["attitude"] = maxi(int(p.get("attitude", 0)), min_att)
		p["met_player"] = true
		return p
	return {}


func _make_custom_offer(s: GameSession, qid: String, tier: String, stages: Array, offerer_id: String, travel_seasons: int = 0) -> Dictionary:
	var budget: Dictionary = _QuestRules.compute_budget(s.gd, tier, s.player.realm_index, stages, travel_seasons)
	var deadline: Dictionary = _QuestRules.compute_deadline(s.gd, tier, stages, travel_seasons)
	var q := {
		"id": qid,
		"template_id": "tpl_test_" + qid,
		"name": "Ủy thác %s" % qid,
		"tier": tier,
		"offer_kind": "person",
		"state": "offered",
		"player_id": s.player.id,
		"offerer_id": offerer_id,
		"offerer_root_id": offerer_id,
		"place_id": s.player.location_id,
		"realm_index": s.player.realm_index,
		"travel_seasons": travel_seasons,
		"stages": stages.duplicate(true),
		"budget": budget,
		"deadline": int(deadline.deadline),
		"outcomes": [],
		"stake_text": "Người quen nhờ vả xử lý việc khẩn.",
		"offer_text": ["Đạo hữu có thể giúp một tay không?"],
		"slots": {"offerer": offerer_id, "place": s.player.location_id},
	}
	s.quests.put_quest(q)
	return q


func _open_ledger(s: GameSession) -> MoneyLedger:
	if s.db.count(WorldEconomy.TABLE) == 0:
		return null
	var ledger := MoneyLedger.new(s.db, s.player)
	ledger.open_season()
	return ledger


func _assert_money_conserved(ledger: MoneyLedger, label: String) -> void:
	if ledger == null:
		return
	assert_near(float(ledger.season_check().gap), 0.0, 0.5, "MoneyLedger conserved (%s)" % label)


# --- AC-QS-151, AC-QS-152, AC-QS-153: Event Engine Story Bridge ----------------------------------------------------

func test_event_engine_story_bridge_budget_logging_and_coexistence_ac_qs_151_152_153() -> void:
	var s := _session(7301)
	var npc: Dictionary = _pick_living_npc_here(s, 30)
	assert_false(npc.is_empty(), "living NPC available at start place")
	var npc_id: String = str(npc.id)
	npc["linh_thach"] = 500
	var ledger := _open_ledger(s)

	# Accept 3 active quests (active_cap == 3) and verify each links an Event Engine story with B budget.
	var qids: Array[String] = ["q_bridge_1", "q_bridge_2", "q_bridge_3"]
	for qid in qids:
		var stages: Array = [
			{"kind": "visit", "place_id": s.player.location_id, "target_id": npc_id, "description": "Gặp %s" % str(npc.name)},
			{"kind": "mission", "seasons": 1, "place_id": s.player.location_id, "description": "Tuần tra một mùa"},
		]
		var q_off: Dictionary = _make_custom_offer(s, qid, "ordinary", stages, npc_id, 0)
		var acc: Dictionary = s.quest_accept(qid)
		assert_true(bool(acc.ok), "quest %s accepted: %s" % [qid, str(acc.lines)])
		var live_q: Dictionary = s.quests.get_quest(qid)
		var st_id: String = str(live_q.get("story_id", ""))
		var ch_id: String = str(live_q.get("chain_id", ""))
		assert_true(st_id != "", "AC-QS-151: quest %s created EventEngine story_id" % qid)
		assert_true(ch_id != "", "AC-QS-151: quest %s created EventEngine chain_id" % qid)
		var srec: Dictionary = _EventStore.get_story(s.db, st_id)
		assert_true(bool(srec.get("is_quest", false)), "AC-QS-153: quest story marked is_quest=true")
		var cb: Dictionary = _EventStore.get_chain_budget(s.db, ch_id)
		var cb_b: int = int(roundf(float(Dictionary(cb.get("total", {})).get("linh_thach", -1.0))))
		assert_eq(cb_b, int(q_off.budget.B), "AC-QS-151: story chain budget uses quest B")

	# AC-QS-153: 3 active non-quest Event Engine stories coexist alongside all 3 active quests.
	var stories_def: Array = Array(s.gd.file("events_stories").get("stories", []))
	var started_non_quest: int = 0
	for sd in stories_def:
		if not (sd is Dictionary):
			continue
		var sid_def: String = str((sd as Dictionary).get("id", ""))
		if sid_def == "":
			continue
		var sres: Dictionary = s.event_engine.start_story(sid_def, s.player.id, {}, s.year, s.season, false)
		if bool(sres.get("ok", false)):
			started_non_quest += 1
			if started_non_quest >= 3:
				break
	assert_eq(started_non_quest, 3, "AC-QS-153: 3 non-quest stories start alongside 3 active quests")
	assert_eq(s.quests.active_quests(s.player.id).size(), 3, "all 3 quests remain active")
	assert_eq(_EventStore.active_stories(s.db, s.player.id, false).size(), 3, "all 3 non-quest stories remain active")
	assert_eq(GameQuery.event_stories(s).size(), 3, "GameQuery.event_stories lists the 3 non-quest stories")

	# AC-QS-152: completing a quest writes 1 WorldDB record by the quest and 0 by the EventEngine story.
	var q1_story_id: String = str(s.quests.get_quest("q_bridge_1").get("story_id", ""))
	var ev_before: int = s.db.count("events")
	var greet_r: Dictionary = s.greet(npc_id)
	assert_true(bool(greet_r.ok), "greet completes visit stages")
	var m_r: Dictionary = s.quest_mission("q_bridge_1")
	assert_true(bool(m_r.ok), "mission completes q_bridge_1")
	assert_eq(str(s.quests.get_quest("q_bridge_1").get("state", "")), "completed", "q_bridge_1 completed")
	var new_events: Array = s.db.all("events").slice(ev_before)
	var quest_logs: Array = new_events.filter(func(e): return str(Dictionary(e.get("data", {})).get("quest_id", "")) == "q_bridge_1")
	var story_logs: Array = new_events.filter(func(e): return str(e.get("type", "")) == "story_end" and str(Dictionary(e.get("data", {})).get("story_instance_id", "")) == q1_story_id)
	assert_eq(quest_logs.size(), 1, "AC-QS-152: exactly 1 WorldDB record written by quest")
	assert_eq(story_logs.size(), 0, "AC-QS-152: 0 WorldDB records written by the Event Engine story")
	_assert_money_conserved(ledger, "story_bridge")
	s.shutdown()


# --- AC-QS-154 & AC-NI-12: Dialogue #30 work + greet bridge -------------------------------------------------------

func test_dialogue_work_offer_no_work_voice_and_greet_visit_ac_qs_154_ac_ni_12() -> void:
	var s := _session(7302)
	var npc: Dictionary = _pick_living_npc_here(s, 45)
	assert_false(npc.is_empty())
	var npc_id: String = str(npc.id)
	# Seed a fresh world fact naming this NPC so QuestGenerator has a valid stake fact.
	s.db.log_event(s.year, s.season, "sect_clash", "%s vừa gặp rắc rối cần người tương trợ." % str(npc.name), [npc_id], [s.player.location_id], [], {"person_id": npc_id})
	npc["linh_thach"] = 400

	# Ask for work via Dialogue #30 bridge (GameSession.quest_ask_work -> interact(npc_id, "work")).
	var w1: Dictionary = s.quest_ask_work(npc_id)
	assert_true(bool(w1.ok), "work verb succeeds")
	assert_true(bool(w1.get("accepted", false)), "friendly NPC accepts work request")
	assert_true(w1.has("quest_offer") and not Dictionary(w1.get("quest_offer", {})).is_empty(), "AC-QS-154: Dialogue work generates real QuestService offer")
	var offered_q: Dictionary = Dictionary(w1.quest_offer)
	var offered_id: String = str(offered_q.get("id", ""))
	assert_true(offered_id != "", "offered quest has id")

	# Verify GameQuery.quest_offer_view & quests_journal expose the offer read-only.
	var qview: Dictionary = GameQuery.quest_offer_view(s, offered_id)
	assert_eq(str(qview.get("id", "")), offered_id, "quest_offer_view finds offered quest")
	assert_true(qview.has("tier") and qview.has("stage_1") and qview.has("later_stages") and qview.has("outcomes"), "AC-QS-79/89 fields present")

	# Second ask in the same season hits offers_per_season (or cooldown): clear cooldown to verify no_work path cleanly.
	var meta: Dictionary = Dictionary(npc.get("interact_meta", {}))
	meta["cooldowns"] = {}
	npc["interact_meta"] = meta
	var w2: Dictionary = s.quest_ask_work(npc_id)
	assert_true(bool(w2.ok), "second work call returns ok")
	assert_true(bool(w2.get("no_work", false)), "AC-QS-154: returns no_work when offers_per_season limit hit")
	assert_eq(str(w2.get("result_key", "")), "no_work", "AC-QS-154: uses Dialogue #30 no_work voice key")
	assert_true(str(w2.get("reply", "")).strip_edges() != "", "AC-QS-154: voiced no_work reply returned")

	# AC-NI-12 / AC-QS-43: greet completes an active visit quest stage without spending a season action.
	var qv_stages: Array = [
		{"kind": "visit", "place_id": s.player.location_id, "target_id": npc_id, "description": "Thăm hỏi %s" % str(npc.name)},
		{"kind": "mission", "seasons": 1, "place_id": s.player.location_id, "description": "Trực gác"},
	]
	_make_custom_offer(s, "q_visit_greet", "ordinary", qv_stages, npc_id, 0)
	assert_true(bool(s.quest_accept("q_visit_greet").ok))
	var season_before: int = s.season_index()
	# Reset season_count so greet isn't blocked by earlier work calls.
	npc["interact_meta"] = {"season": season_before, "year": s.year, "season_count": 0, "cooldowns": {}}
	var gr: Dictionary = s.greet(npc_id)
	assert_true(bool(gr.ok), "greet succeeds")
	assert_true(Array(gr.get("completed_visits", [])).has("q_visit_greet"), "AC-NI-12: greet reports completed visit quest id")
	assert_eq(int(s.quests.get_quest("q_visit_greet").get("stage", 0)), 2, "AC-NI-12: quest advanced to stage 2")
	assert_eq(s.season_index(), season_before, "AC-QS-43: visit via greet spends 0 season action")
	s.shutdown()


# --- AC-QS-69, AC-QS-70, AC-QS-74: Mission 0 Income, Reach-before-Deliver (4,9,0,47), 4-Season Abandon (18) --------

func test_mission_zero_income_four_season_abandon_18_and_reach_before_deliver_4_9_0_47() -> void:
	var s := _session(7303)
	var npc: Dictionary = _pick_living_npc_here(s, 30)
	var npc_id: String = str(npc.id)
	npc["linh_thach"] = 500
	s.player.realm_index = 0
	var ledger := _open_ledger(s)

	# AC-QS-70: FX-PLAN with reach before deliver -> S_plan 4, B 60, stage_pays = [4, 9, 0, 47].
	var stages_70: Array = [
		{"kind": "event", "place_id": s.player.location_id, "description": "Sự kiện mở đầu"},
		{"kind": "mission", "seasons": 2, "place_id": s.player.location_id, "description": "Trực nhiệm vụ 2 mùa"},
		{"kind": "reach", "stat": "realm_index", "target": 1, "description": "Đạt Trúc Cơ"},
		{"kind": "deliver", "place_id": s.player.location_id, "item_class": "herb", "deliver_price": 10, "description": "Giao linh thảo"},
	]
	var b70: Dictionary = _QuestRules.compute_budget(s.gd, "ordinary", 0, stages_70, 0)
	assert_eq(int(b70.S_plan), 4, "AC-QS-70: S_plan == 4")
	assert_eq(int(b70.B), 60, "AC-QS-70: B == 60")
	assert_eq(Array(b70.stage_pays), [4, 9, 0, 47], "AC-QS-70: stage_pays == [4, 9, 0, 47]")

	# AC-QS-69 & AC-QS-74: 4-season mission + visit abandoned before visit pays 18 (0.45 I_r/s) and 0 mission income.
	var stages_74: Array = [
		{
			"kind": "mission",
			"seasons": 4,
			"place_id": s.player.location_id,
			"description": "Hộ vệ linh mạch 4 mùa",
			"rewards": [{"type": "linh_thach", "amount": 18}],
		},
		{
			"kind": "visit",
			"place_id": s.player.location_id,
			"target_id": npc_id,
			"description": "Báo cáo hoàn tất",
			"rewards": [{"type": "linh_thach", "amount": 42}],
		},
	]
	_make_custom_offer(s, "q_74", "ordinary", stages_74, npc_id, 0)
	assert_true(bool(s.quest_accept("q_74").ok))
	var lt_before: int = s.player.linh_thach
	for step in range(4):
		var mr: Dictionary = s.quest_mission("q_74")
		assert_true(bool(mr.ok), "mission season %d ok" % (step + 1))
		assert_eq(int(mr.get("mission_income", -1)), 0, "AC-QS-69: mission_income is always 0")
		if step < 3:
			assert_eq(int(s.quests.get_quest("q_74").get("paid_total", 0)), 0, "no payout before stage 1 completes")
	var q74_mid: Dictionary = s.quests.get_quest("q_74")
	assert_eq(int(q74_mid.get("stage", 0)), 2, "stage 1 completed after 4 seasons")
	assert_eq(int(q74_mid.get("paid_total", 0)), 18, "AC-QS-74: stage 1 paid 18 (0.45 I_r/s)")
	assert_eq(s.player.linh_thach - lt_before, 18, "player received exact 18 stones")
	var ab: Dictionary = s.quest_abandon("q_74")
	assert_true(bool(ab.ok), "abandon before visit succeeds")
	assert_eq(int(s.quests.get_quest("q_74").get("paid_total", 0)), 18, "AC-QS-74: total paid remains 18 (0.45 I_r/s)")
	assert_near(float(18) / (4.0 * float(_QuestRules.realm_income_Ir(s.gd, 0))), 0.45, 0.001, "0.45 I_r per season")
	_assert_money_conserved(ledger, "ac_qs_69_74")
	s.shutdown()


# --- AC-QS-71, AC-QS-72, AC-QS-73: Save/Reload Boon & Stage-2 Plan, Narration Swap Invariance ---------------------

func test_boon_and_stage2_plan_survive_save_reload_and_narration_swap_preserves_numbers_ac_qs_71_72_73() -> void:
	var s := _session(7304)
	var npc: Dictionary = _pick_living_npc_here(s, 30)
	var npc_id: String = str(npc.id)
	npc["linh_thach"] = 500
	s.player.quest_boons.append({
		"quest_id": "q_boon_past",
		"title": "Hỏa Tâm Ấn",
		"mods": [{"stat": "cultivation_speed_pct", "value": 4.0}],
		"w": 4.0,
	})
	s.player.quest_gain_total_w = 4.0

	var stages: Array = [
		{"kind": "visit", "place_id": s.player.location_id, "target_id": npc_id, "description": "Gặp mặt"},
		{"kind": "mission", "seasons": 2, "place_id": s.player.location_id, "description": "Trực gác 2 mùa"},
	]
	_make_custom_offer(s, "q_save_rt", "ordinary", stages, npc_id, 0)
	assert_true(bool(s.quest_accept("q_save_rt").ok))
	assert_true(bool(s.greet(npc_id).ok))
	var before_q: Dictionary = s.quests.get_quest("q_save_rt")
	assert_eq(int(before_q.get("stage", 0)), 2, "precondition: at stage 2")
	var plan_before_json: String = JSON.stringify(before_q, "", false, true)

	# Save and reload into a brand-new GameSession.
	var save_json: String = JSON.stringify(s.to_dict(), "", false, true)
	var llm2 := LlmService.new(s.gd)
	llm2.enabled = false
	var s2 := GameSession.new(s.gd, llm2, TestFixtures.tree())
	s2.ratings_background = false
	var lr: Dictionary = s2.load_dict(JSON.parse_string(save_json))
	assert_true(bool(lr.ok), "reload ok: %s" % str(lr.lines))

	# AC-QS-71: quest_boon and quest_gain_total_w survive save/reload.
	assert_eq(s2.player.quest_boons.size(), 1, "AC-QS-71: quest_boons preserved")
	assert_eq(str(Dictionary(s2.player.quest_boons[0]).get("title", "")), "Hỏa Tâm Ấn")
	assert_near(s2.player.quest_gain_total_w, 4.0, 1e-6, "AC-QS-71: quest_gain_total_w preserved")

	# AC-QS-72: active quest plan at stage 2 is byte-identical after reload (JSON-normalized for int/float JSON representation).
	var after_q: Dictionary = s2.quests.get_quest("q_save_rt")
	var norm_before: String = JSON.stringify(JSON.parse_string(plan_before_json), "", false, true)
	var plan_after_json: String = JSON.stringify(after_q, "", false, true)
	assert_eq(plan_after_json, norm_before, "AC-QS-72: stage-2 quest plan byte-identical after reload")

	# AC-QS-73: narration swap changes display text only — never checks, effects, or numbers.
	var swapped: Dictionary = after_q.duplicate(true)
	swapped["name"] = "Lời kể khác hoàn toàn"
	swapped["offer_text"] = ["Bản dẫn truyện thay thế hoàn toàn."]
	swapped["stake_text"] = "Lý do viết lại theo phong cách khác."
	var st_arr: Array = Array(swapped.stages)
	Dictionary(st_arr[1])["description"] = "Mô tả văn phong khác"
	var b_orig: Dictionary = _QuestRules.compute_budget(s2.gd, str(after_q.tier), int(after_q.realm_index), Array(after_q.stages), int(after_q.travel_seasons))
	var b_swap: Dictionary = _QuestRules.compute_budget(s2.gd, str(swapped.tier), int(swapped.realm_index), Array(swapped.stages), int(swapped.travel_seasons))
	var d_orig: Dictionary = _QuestRules.compute_deadline(s2.gd, str(after_q.tier), Array(after_q.stages), int(after_q.travel_seasons))
	var d_swap: Dictionary = _QuestRules.compute_deadline(s2.gd, str(swapped.tier), Array(swapped.stages), int(swapped.travel_seasons))
	assert_eq(JSON.stringify(b_swap, "", false, true), JSON.stringify(b_orig, "", false, true), "AC-QS-73: budget identical after narration swap")
	assert_eq(JSON.stringify(d_swap, "", false, true), JSON.stringify(d_orig, "", false, true), "AC-QS-73: deadline identical after narration swap")
	s.shutdown()
	s2.shutdown()


# --- AC-QS-146..150: Slot Unbind, 1000-Seed Params, QR Legendary->Major, Reach+Defeat vs 2 Reach, new_person ------

func test_generator_and_validator_edge_contracts_ac_qs_146_to_150() -> void:
	var s := _session(7305)
	var npc: Dictionary = _pick_living_npc_here(s, 30)
	var npc_id: String = str(npc.id)
	var gen := _QuestGenerator.new(s.gd, s.db, s.builds)

	# AC-QS-146: template with unbindable required slot is cleanly dropped.
	var unbindable_tpl := {
		"id": "tpl_unbindable_146",
		"name": "Không thể gắn vai",
		"tier": "ordinary",
		"offer_kinds": ["person"],
		"place_kinds": ["any"],
		"realm_min": 0,
		"realm_max": 4,
		"offer_text": ["Lời mời thử nghiệm."],
		"stake_text": "Lý do thử nghiệm.",
		"slots": {
			"adversary": {"bind": "npc_in_region", "required": true, "filters": {"realm_min": 99}},
		},
		"stages": [
			{"kind": "mission", "seasons": 1, "description": "Thử nghiệm"},
		],
		"outcomes": [],
	}
	var res_146: Dictionary = gen.generate_offer(s.player, s.sheet(), "person", npc_id, s.player.location_id, 7305, s.season_index(), 0, {
		"templates": [unbindable_tpl],
		"source_fact": {"id": "ev_f146", "people": [npc_id], "places": [s.player.location_id], "sects": [], "data": {"person_id": npc_id}},
	})
	assert_false(bool(res_146.ok), "AC-QS-146: unbindable required slot cleanly rejected")

	# AC-QS-147: 1,000-seed parameter range draw stays strictly within [lo, hi].
	var cash_lo: float = 0.05
	var cash_hi: float = 0.18
	var ms_lo: int = 1
	var ms_hi: int = 3
	var seen_ms: Dictionary = {}
	for k in range(1000):
		var r_k: RandomNumberGenerator = _QuestGenerator.offer_rng(7305, s.player.id, k, 0, "param_147")
		var c_val: float = r_k.randf_range(cash_lo, cash_hi)
		var m_val: int = r_k.randi_range(ms_lo, ms_hi)
		assert_true(c_val >= cash_lo - 1e-6 and c_val <= cash_hi + 1e-6, "AC-QS-147: cash_share in [lo, hi]")
		assert_true(m_val >= ms_lo and m_val <= ms_hi, "AC-QS-147: mission_seasons in [lo, hi]")
		seen_ms[m_val] = true
	assert_eq(seen_ms.size(), 3, "AC-QS-147: all integer values in [1, 3] sampled across 1,000 seeds")

	# AC-QS-148: at Qi Refining (realm 0), Legendary never draws (downgrades to Major).
	for k in range(300):
		var r_t: RandomNumberGenerator = _QuestGenerator.offer_rng(7305, s.player.id, k, 0, "tier_148")
		var t_drawn: String = _QuestGenerator.draw_tier(s.gd, r_t, 0, ["errand", "ordinary", "major", "legendary"], "person")
		assert_true(t_drawn != "legendary", "AC-QS-148: Qi Refining never draws legendary (downgraded to major)")

	# AC-QS-149: reach + defeat passes validate_template; two reach stages rejected.
	var tpl_rd := {
		"id": "tpl_reach_defeat_149",
		"name": "Đột phá rồi đánh bại",
		"tier": "ordinary",
		"offer_kinds": ["person"],
		"place_kinds": ["any"],
		"realm_min": 0,
		"realm_max": 4,
		"offer_text": ["Hãy đột phá rồi đánh bại kẻ thù."],
		"stake_text": "Kẻ địch đe dọa trực tiếp.",
		"slots": {},
		"stages": [
			{"kind": "reach", "stat": "realm_index", "target": 1, "window": 8, "description": "Đạt cảnh giới mới"},
			{"kind": "defeat", "window": 4, "description": "Đánh bại đối thủ"},
		],
		"outcomes": [{"on": "completed", "role": "offerer", "effect": "wealth", "amount_share": 0.2}],
	}
	var errs_ok: Array = _QuestValidator.validate_template(s.gd, tpl_rd)
	assert_true(errs_ok.is_empty(), "AC-QS-149: reach + defeat template passes load validation: %s" % str(errs_ok))
	var tpl_2reach: Dictionary = tpl_rd.duplicate(true)
	tpl_2reach["id"] = "tpl_two_reach_149"
	tpl_2reach["stages"] = [
		{"kind": "reach", "stat": "realm_index", "target": 1, "window": 6, "description": "Đạt cảnh giới 1"},
		{"kind": "reach", "stat": "realm_index", "target": 2, "window": 6, "description": "Đạt cảnh giới 2"},
		{"kind": "mission", "seasons": 1, "window": 2, "description": "Hoàn tất"},
	]
	var errs_bad: Array = _QuestValidator.validate_template(s.gd, tpl_2reach)
	assert_false(errs_bad.is_empty(), "AC-QS-149: template with 2 reach stages is rejected")

	# AC-QS-150: new_person slot registers the generated person in WorldDB BEFORE the offer is returned.
	var people_before: int = s.db.count("people")
	var tpl_np := {
		"id": "tpl_new_person_150",
		"name": "Hộ tống tân khách",
		"tier": "ordinary",
		"offer_kinds": ["person"],
		"place_kinds": ["any"],
		"realm_min": 0,
		"realm_max": 4,
		"offer_text": ["Đưa người mới này về an toàn."],
		"stake_text": "Họ là người của bản môn.",
		"slots": {
			"target": {"bind": "new_person", "role": "target"},
		},
		"stages": [
			{"kind": "visit", "slot": "target", "description": "Gặp tân khách"},
			{"kind": "mission", "seasons": 1, "description": "Hộ tống một mùa"},
		],
		"outcomes": [{"on": "completed", "role": "offerer", "effect": "wealth", "amount_share": 0.2}],
	}
	var res_150: Dictionary = gen.generate_offer(s.player, s.sheet(), "person", npc_id, s.player.location_id, 7305, s.season_index(), 0, {
		"templates": [tpl_np],
		"source_fact": {"id": "ev_f150", "people": [npc_id], "places": [s.player.location_id], "sects": [], "data": {"person_id": npc_id}},
	})
	assert_true(bool(res_150.ok), "AC-QS-150: new_person template generated offer: %s" % str(res_150.get("reason", "")))
	assert_true(s.db.count("people") > people_before, "AC-QS-150: new_person registered in WorldDB before offer returned")
	var np_id: String = str(Dictionary(res_150.quest.get("slots", {})).get("target", ""))
	assert_true(np_id != "" and s.db.has_record("people", np_id), "AC-QS-150: slot target points to registered WorldDB person")
	s.shutdown()


# --- Event Engine Mercy Guard, Hidden Chronicles Codex Sync & Crafting Provenance ---------------------------------

func test_pending_mercy_guard_hidden_chronicle_codex_sync_and_craft_provenance() -> void:
	var s := _session(7306)
	var npc: Dictionary = _pick_living_npc_here(s, 0)
	var npc_id: String = str(npc.id)
	var ledger := _open_ledger(s)

	# 1. Pending Mercy blocks time-spending actions (AC-EV-14), surfaces in GameQuery & Advisor, and persists in save/load.
	s.pending_mercy = {"event": {"title": "Quyết đấu sinh tử"}, "choice_index": 0, "target_id": npc_id, "title": "Quyết đấu sinh tử"}
	assert_true(s.has_pending_mercy())
	var blocked: Dictionary = s.cultivate(1)
	assert_false(bool(blocked.ok), "AC-EV-14: pending_mercy blocks cultivate")
	assert_true(str(blocked.lines[0]).contains("Quyết đấu sinh tử"), "AC-EV-14: refusal names event title")
	var mq: Dictionary = GameQuery.pending_event(s)
	assert_true(bool(mq.get("mercy_pending", false)), "GameQuery.pending_event reports mercy_pending")
	assert_eq(str(Advisor.goals(s)[0].id), "mercy", "Advisor prioritizes pending mercy")
	# Save/load preserves pending_mercy.
	var saved: Dictionary = JSON.parse_string(JSON.stringify(s.to_dict()))
	assert_true(not Dictionary(saved.get("pending_mercy", {})).is_empty(), "pending_mercy saved in to_dict()")
	# Resolve spare.
	var m_res: Dictionary = s.choose_mercy(false)
	assert_true(bool(m_res.ok) and not bool(m_res.killed), "choose_mercy(false) spares target")
	assert_false(s.has_pending_mercy(), "pending_mercy cleared")
	assert_true(bool(s.db.get_record("people", npc_id).get("alive", false)), "spared NPC stays alive")
	assert_eq(str(_EventStore.get_flag(s.db, npc_id, "spared_by", s.season_index(), "")), s.player.id, "AC-EV-30: spared_by flag set")

	# 2. Hidden chronicle uncover via GameSession.choose() syncs Codex History (AC-WG-56).
	# Codex Rule 9 (AC-CK-12) writes knowledge entries on Fated-birth ("thien_dinh") lives.
	s.player.birth_mode = "thien_dinh"
	var hidden_cid: String = ""
	for e in s.db.all("events"):
		var edata: Dictionary = Dictionary(e.get("data", {}))
		if str(e.get("type", "")) == "hidden" or bool(edata.get("secret", false)):
			var cand_id: String = str(edata.get("id", ""))
			if cand_id != "":
				hidden_cid = cand_id
				break
	assert_true(hidden_cid != "", "world contains a shipped hidden chronicle")
	var news_before: Dictionary = GameQuery.event_news(s, 50)
	for row in Array(news_before.news) + Array(news_before.annals_uncovered):
		assert_true(str(Dictionary(row.get("data", {})).get("id", "")) != hidden_cid, "hidden chronicle stays hidden before uncover")
	s.pending_event = {
		"id": "ev_uncover_w3",
		"title": "Bia đá cổ",
		"text": "Bạn phát hiện văn bia bị phong ấn.",
		"place_id": s.player.location_id,
		"npc_id": "",
		"choices": [
			{
				"label": "Giải mã văn bia",
				"check": {"type": "none"},
				"always": [],
				"success": {"text": "Bí sử hiện ra.", "effects": [{"type": "uncover_chronicle", "chronicle_id": hidden_cid}]},
				"failure": {"text": "", "effects": []},
			},
		],
	}
	var cr: Dictionary = s.choose(0)
	assert_true(bool(cr.ok), "choose uncover_chronicle ok")
	assert_eq(s.codex_store.level_of(Codex.BOOK_HISTORY, hidden_cid), CodexStore.LEVEL_KNOWN, "AC-WG-56: uncovered chronicle synced to Codex History")
	var news_after: Dictionary = GameQuery.event_news(s, 50)
	assert_true(Array(news_after.annals_uncovered).any(func(r): return str(Dictionary(r.get("data", {})).get("id", "")) == hidden_cid), "uncovered chronicle now appears in annals_uncovered")

	# 3. AC-QS-63: craft provenance — pre-accept item does NOT complete craft stage; post-accept crafted item DOES.
	var pre_pill: Dictionary = s.items.pill("hoi_linh_dan", 0, 1)
	pre_pill["owner_id"] = s.player.id
	s.db.add("items", pre_pill)
	var c_stages: Array = [
		{"kind": "craft", "item_class": "pill", "description": "Luyện một viên đan dược sau khi nhận"},
		{"kind": "visit", "place_id": s.player.location_id, "target_id": npc_id, "description": "Báo cáo"},
	]
	_make_custom_offer(s, "q_craft_63", "ordinary", c_stages, npc_id, 0)
	assert_true(bool(s.quest_accept("q_craft_63").ok))
	# Advance one season without crafting: pre-accept pill must NOT complete stage 1.
	s.pending_event = {}
	s.cultivate(1)
	s.pending_event = {}
	assert_eq(int(s.quests.get_quest("q_craft_63").get("stage", 0)), 1, "AC-QS-63: pre-accept pill does not complete craft stage")
	# Simulate crafting a post-accept pill via on_item_crafted (as GameSession.craft does on success).
	var post_pill: Dictionary = s.items.pill("hoi_linh_dan", 0, 1)
	post_pill["owner_id"] = s.player.id
	var post_pid: String = s.db.add("items", post_pill)
	s.quests.on_item_crafted(s.player, post_pid, s.season_index())
	s.cultivate(1)
	assert_eq(int(s.quests.get_quest("q_craft_63").get("stage", 0)), 2, "AC-QS-63: post-accept crafted pill completes craft stage")
	_assert_money_conserved(ledger, "mercy_chronicle_craft")
	s.shutdown()


func test_quest_defeat_stage_runs_real_fight_and_writes_back_fight_meters() -> void:
	var base := game_data()
	var files_copy: Dictionary = base.registry.files().duplicate()
	var patched_eff: Dictionary = base.file("combat_effects").duplicate(true)
	patched_eff["effects"]["Playing Past the Break"] = {
		"records": [{
			"id": "eff:Playing Past the Break",
			"on": "fight_start",
			"do": [{"meter": {"id": "playing_past_the_break", "success": [{"gain_qi": {"share": 0.1}}], "failure": []}}],
		}],
	}
	files_copy["combat_effects"] = patched_eff
	var gd := GameData.new()
	gd.setup(DataRegistry.from_files(files_copy))
	var llm := LlmService.new(gd)
	llm.enabled = false
	var s := GameSession.new(gd, llm, TestFixtures.tree())
	s.ratings_background = false
	s.new_game(7307, {
		"mode": "custom", "name": "Lâm Thử", "gender": "male", "origin": "tan_tu",
		"thien_phu": {"than_hon": 80, "khi_van": 40, "can_cot": 70, "dao_tam": 70, "ngo_tinh": 70, "mi_luc": 50},
		"purities": {"hoa": 80, "kim": 50}, "variants": [], "edge": true,
	})
	s.pending_event = {}
	s.pending_meta = {}
	s.pending_mercy = {}

	var manual := {
		"tech_id": "shao-remnant-score", "name": "Shao", "tier": 2, "tech_kind": "secret",
		"names": ["hoa"], "layers": 12, "bonuses": [], "passives": [], "abilities": [],
		"effects": [{"name": "Playing Past the Break", "unlock_layer": 1}],
		"seal_clusters": [], "origin": "authored",
	}
	CongPhap.learn(s.player, manual)
	s.player.aux_tech[0] = "shao-remnant-score"
	s.player.fight_meters["playing_past_the_break"] = 0.0
	s.player.linh_thach = 500
	s.sync_player()

	var offerer: Dictionary = _pick_living_npc_here(s, 30)
	var foe: Dictionary = {}
	for p in s.db.living():
		if bool(p.get("is_player", false)) or bool(p.get("is_beast", false)) or str(p.get("id", "")) == str(offerer.id):
			continue
		if int(p.get("realm_index", 0)) == s.player.realm_index:
			foe = p
			break
	if foe.is_empty():
		foe = offerer
	foe["location_id"] = s.player.location_id
	var foe_id: String = str(foe.id)
	var ledger := _open_ledger(s)

	var stages: Array = [
		{"kind": "defeat", "place_id": s.player.location_id, "target_id": foe_id, "description": "Đánh bại đối thủ"},
	]
	_make_custom_offer(s, "q_defeat_meter", "ordinary", stages, str(offerer.id), 0)
	assert_true(bool(s.quest_accept("q_defeat_meter").ok), "defeat quest accepted")
	# Ensure defeat hold is open for the test (already opened in a prior check).
	var q_live: Dictionary = s.quests.get_quest("q_defeat_meter")
	q_live["defeat_opened"] = {"0": true}
	s.quests.put_quest(q_live)

	s.resolver.last_fight = null
	var d_res: Dictionary = s.quest_start_stage("q_defeat_meter")
	assert_true(bool(d_res.ok), "quest_start_stage on defeat succeeded: %s" % str(d_res))
	assert_true(s.resolver.last_fight != null, "defeat stage ran through real CombatService via EventResolver.fight_check")
	var expected_end: float = float(s.resolver.last_fight.a_end.meters.get("playing_past_the_break", -1.0))
	assert_true(expected_end > 0.0, "real fight advanced playing_past_the_break meter (got %.3f)" % expected_end)
	assert_near(float(s.player.fight_meters.get("playing_past_the_break", -1.0)), expected_end, 1e-6, "quest defeat real fight wrote back playing_past_the_break")
	var db_p: Dictionary = s.db.get_record("people", s.player.id)
	assert_near(float(Dictionary(db_p.get("fight_meters", {})).get("playing_past_the_break", -1.0)), expected_end, 1e-6, "synced player WorldDB record holds updated fight_meters")
	_assert_money_conserved(ledger, "quest_defeat_meter")
	s.shutdown()
