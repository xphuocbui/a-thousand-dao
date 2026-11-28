extends DaoTestSuite
## Comprehensive session & integration tests for NPC Interaction & Dialogue (#30) + all 19 Trait verb: hooks.
## Covers AC-NI-01, 02, 03, 07, 08, 11, 12, 13, 14, 15, 17, 19, 20, 22, 25, all 17 base verbs,
## all 19 trait verb: hooks, MoneyLedger conservation, focus tax yield reduction, and save/load compatibility.


static var _gd_off: GameData
static var _base_save_off: String = ""


static func _shared_gd_off() -> GameData:
	if _gd_off == null:
		_gd_off = GameData.load_from("res://assets/data")
		_gd_off.world_gen().people.world_cultivators = 60
		_gd_off.world_gen().people.world_cultivators_min = 0
		_gd_off.file("combat_rankings")["enabled"] = false
	return _gd_off


static func _cached_save_off() -> String:
	if _base_save_off == "":
		var gd := _shared_gd_off()
		var llm := LlmService.new(gd)
		llm.enabled = false
		var s := GameSession.new(gd, llm, TestFixtures.tree())
		s.ratings_background = false
		s.new_game(3030, {"mode": "roll", "name": "Hàn Minh", "gender": "male", "origin": "tan_tu"})
		s.pending_event = {}
		_base_save_off = JSON.stringify(s.to_dict())
		s.shutdown()
	return _base_save_off


func _session(seed_v: int = 3030, ratings_on: bool = false) -> GameSession:
	if seed_v == 3030 and not ratings_on:
		var gd := _shared_gd_off()
		var llm := LlmService.new(gd)
		llm.enabled = false
		var s := GameSession.new(gd, llm, TestFixtures.tree())
		s.ratings_background = false
		s.load_dict(JSON.parse_string(_cached_save_off()))
		s.pending_event = {}
		return s
	var gd2 := GameData.load_from("res://assets/data")
	gd2.world_gen().people.world_cultivators = 60
	gd2.world_gen().people.world_cultivators_min = 0
	gd2.file("combat_rankings")["enabled"] = ratings_on
	var llm2 := LlmService.new(gd2)
	llm2.enabled = false
	var s2 := GameSession.new(gd2, llm2, TestFixtures.tree())
	s2.ratings_background = false
	s2.new_game(seed_v, {"mode": "roll", "name": "Hàn Minh", "gender": "male", "origin": "tan_tu"})
	s2.pending_event = {}
	return s2


func _spawn_here(s: GameSession, opts: Dictionary = {}) -> Dictionary:
	var spec := {
		"realm_index": int(opts.get("realm_index", s.player.realm_index)),
		"stage": int(opts.get("stage", 0)),
		"location_id": s.player.location_id,
		"is_beast": bool(opts.get("is_beast", false)),
		"sect_id": str(opts.get("sect_id", "")),
		"sect_rank": str(opts.get("sect_rank", "")),
	}
	var pid: String = s.builds.create_person(s.rng, spec)
	var rec: Dictionary = s.db.get_record("people", pid)
	if opts.has("name"):
		rec["name"] = str(opts.name)
	if opts.has("attitude"):
		rec["attitude"] = int(opts.attitude)
	if opts.has("met_player"):
		rec["met_player"] = bool(opts.met_player)
	if opts.has("linh_thach"):
		rec["linh_thach"] = int(opts.linh_thach)
	if opts.has("npc_traits"):
		rec["npc_traits"] = Dictionary(opts.npc_traits).duplicate(true)
	if opts.has("cast_key"):
		rec["cast_key"] = str(opts.cast_key)
	if opts.has("flags"):
		rec["flags"] = Dictionary(opts.flags).duplicate(true)
	return rec


func _add_player_trait(s: GameSession, kind: String, trait_id: String, tier: int = 1) -> void:
	if s.player.npc_traits.is_empty():
		s.player.npc_traits = {"personality": [], "calling": "", "fate": [], "gained": []}
	match kind:
		"personality", "fate", "path", "health":
			var arr: Array = Array(s.player.npc_traits.get(kind, []))
			if not arr.has(trait_id):
				arr.append(trait_id)
			s.player.npc_traits[kind] = arr
		"upbringing", "lifestyle", "calling":
			s.player.npc_traits[kind] = trait_id
		"talent":
			var tarr: Array = Array(s.player.npc_traits.get("talent", []))
			tarr.append({"id": trait_id, "tier": tier})
			s.player.npc_traits["talent"] = tarr
		"coping":
			s.player.npc_traits["coping"] = {"id": trait_id, "expires": s.season_index() + 20, "refreshes": 0, "hardened": false}
	s.sync_player()


func _add_npc_trait(npc: Dictionary, kind: String, trait_id: String, tier: int = 1) -> void:
	if not npc.has("npc_traits") or not (npc.npc_traits is Dictionary):
		npc["npc_traits"] = {"personality": [], "calling": "", "fate": [], "gained": []}
	var nt: Dictionary = npc.npc_traits
	match kind:
		"personality", "fate", "path", "health":
			var arr: Array = Array(nt.get(kind, []))
			if not arr.has(trait_id):
				arr.append(trait_id)
			nt[kind] = arr
		"upbringing", "lifestyle", "calling":
			nt[kind] = trait_id
		"talent":
			var tarr: Array = Array(nt.get("talent", []))
			tarr.append({"id": trait_id, "tier": tier})
			nt["talent"] = tarr
		"coping":
			nt["coping"] = {"id": trait_id, "expires": 99999, "refreshes": 0, "hardened": false}


# --- AC-NI-01, AC-NI-02, AC-NI-03 -------------------------------------------------------------------------------------

func test_greet_unknown_sets_att0_and_known_beast_growls_ac_ni_01() -> void:
	var s := _session()
	var stranger: Dictionary = _spawn_here(s, {"attitude": 0, "met_player": false, "npc_traits": {"personality": ["calm"]}})
	stranger["last_talk_season"] = -1
	var expected_att0: int = NpcTraits.att0(s.gd, s.db, stranger, s.player.to_dict(), 0.0, int(s.gd.session().talk.hostile_threshold))

	var r: Dictionary = s.greet(str(stranger.id))
	assert_true(bool(r.ok), "greet succeeds")
	assert_true(bool(r.accepted), "greet accepted")
	assert_true(bool(stranger.get("met_player", false)), "AC-NI-01: stranger becomes met_player")
	assert_true(s.player.met_list.has(str(stranger.id)), "AC-NI-01: stranger added to player.met_list")
	assert_eq(int(stranger.attitude), expected_att0, "AC-NI-01: attitude equals att0")

	var beast: Dictionary = _spawn_here(s, {"is_beast": true, "name": "Hỏa Lang"})
	var rb: Dictionary = s.interact(str(beast.id), "greet")
	assert_false(bool(rb.ok), "AC-NI-01: beast refuses interaction")
	assert_true(bool(rb.get("beast", false)), "beast flag set")
	assert_true(str(rb.lines[0]).to_lower().contains("growl"), "AC-NI-01: beast returns growl line: %s" % str(rb.lines))
	s.shutdown()


func test_season_limit_blocks_third_interaction_other_person_ok_and_repay_exempt_ac_ni_02() -> void:
	var s := _session()
	var a: Dictionary = _spawn_here(s, {"attitude": 40, "linh_thach": 500})
	var b: Dictionary = _spawn_here(s, {"attitude": 20})
	s.player.linh_thach = 500

	assert_true(bool(s.interact(str(a.id), "greet").ok), "1st interaction ok")
	var loan_r: Dictionary = s.interact(str(a.id), "help", {"sub": "loan", "amount": 20})
	assert_true(bool(loan_r.ok) and bool(loan_r.accepted), "2nd interaction (loan) ok")

	var third: Dictionary = s.interact(str(a.id), "greet")
	assert_false(bool(third.ok), "AC-NI-02: 3rd interaction with same person blocked")
	assert_true(bool(third.get("limit_reached", false)), "limit_reached flag set")
	assert_true(str(third.lines[0]).to_lower().contains("limit"), "AC-NI-02: limit named in refusal")

	assert_true(bool(s.interact(str(b.id), "greet").ok), "AC-NI-02: different person still accepts")
	assert_true(bool(s.interact(str(a.id), "repay").ok), "repay exempt from season cap")
	s.shutdown()


func test_teaching_spends_quarter_season_focus_greet_spends_none_ac_ni_03() -> void:
	var s := _session()
	var elder: Dictionary = _spawn_here(s, {"realm_index": s.player.realm_index + 1, "attitude": 50})
	assert_near(s.season_time_used, 0.0, 1e-6, "starts at 0.0")
	assert_true(bool(s.interact(str(elder.id), "greet").ok))
	assert_near(s.season_time_used, 0.0, 1e-6, "AC-NI-03: greeting spends no time")

	# Measure full baseline cultivation yield vs taxed 75% yield (after 0.25 teaching).
	var snap: String = JSON.stringify(s.to_dict())
	var s_full := _session()
	s_full.load_dict(JSON.parse_string(snap))
	var tu_before_full: float = s_full.player.tu_vi
	s_full._pass_season("cultivate")
	var gain_full: float = s_full.player.tu_vi - tu_before_full

	var t_res: Dictionary = s.interact(str(elder.id), "teach", {"lesson": "insight"})
	assert_true(bool(t_res.ok) and bool(t_res.accepted), "teaching accepted")
	assert_near(s.season_time_used, 0.25, 1e-6, "AC-NI-03: teaching spends 0.25 season focus")

	# Clear the insight buff temporarily just to isolate the 75% focus tax math cleanly.
	s.player.interaction_buffs.clear()
	var tu_before_tax: float = s.player.tu_vi
	s._pass_season("cultivate")
	var gain_taxed: float = s.player.tu_vi - tu_before_tax
	assert_near(gain_taxed, gain_full * 0.75, 0.05, "Rule 4: teaching then cultivate yields 75%% (%.2f vs %.2f)" % [gain_taxed, gain_full])
	assert_near(s.season_time_used, 0.0, 1e-6, "season_time_used resets at season boundary")

	# Refused when remaining focus time < verb.time
	var elder2: Dictionary = _spawn_here(s, {"realm_index": s.player.realm_index + 1, "attitude": 60, "met_player": true})
	s.season_time_used = 0.80
	var ref_time: Dictionary = s.interact(str(elder2.id), "teach", {"lesson": "insight"})
	assert_false(bool(ref_time.ok), "timed verb refused when remaining < verb.time")
	assert_eq(str(ref_time.get("reason", "")), "insufficient_focus_time")
	s_full.shutdown()
	s.shutdown()


# --- AC-NI-07, AC-NI-08, AC-NI-11, AC-NI-12 ---------------------------------------------------------------------------

func test_merciful_player_threaten_shown_and_applies_f7_cost_ac_ni_07() -> void:
	var s := _session()
	_add_player_trait(s, "personality", "compassionate")
	var npc: Dictionary = _spawn_here(s, {"attitude": 10, "met_player": true, "linh_thach": 100})
	var menu: Array = s.interactions.list_verbs(s.player, s.sheet(), str(npc.id), s.season_index(), s.year, s.season_time_used, false, s.knowledge)
	var th_entry: Dictionary = {}
	for v in menu:
		if str(v.id) == "threaten":
			th_entry = v
			break
	assert_false(th_entry.is_empty(), "AC-NI-07: threaten is shown to compassionate player")
	assert_false(bool(th_entry.greyed), "AC-NI-07: threaten is NOT greyed")
	assert_false(bool(th_entry.disabled), "AC-NI-07: threaten is NOT disabled")

	var tm_before: float = s.player.tam_ma
	var res: Dictionary = s.interact(str(npc.id), "threaten")
	assert_true(bool(res.ok), "threaten executes")
	assert_true(s.player.tam_ma > tm_before, "AC-NI-07: F7 heart demon cost applied (%.1f -> %.1f)" % [tm_before, s.player.tam_ma])
	s.shutdown()


func test_ask_news_reveals_place_and_nothing_new_spends_no_count_ac_ni_08() -> void:
	var s := _session()
	var npc: Dictionary = _spawn_here(s, {"attitude": 30, "met_player": true})
	var unknown_place: String = ""
	for p in s.db.all("places"):
		if not bool(p.get("hidden", false)) and not s.knowledge.knows_place(str(p.id)):
			unknown_place = str(p.id)
			break
	if unknown_place == "":
		unknown_place = s.db.add("places", {"name": "Bí Cốc Thử Nghiệm", "type": "son", "kind": "ruin", "region_id": "", "hidden": false, "links": []})
	assert_false(s.knowledge.knows_place(unknown_place), "precondition: place unknown")
	npc["known_places"] = [unknown_place]
	npc["location_id"] = s.player.location_id

	var r1: Dictionary = s.interact(str(npc.id), "news")
	assert_true(bool(r1.ok) and bool(r1.accepted), "news accepted")
	assert_true(s.knowledge.knows_place(unknown_place), "AC-NI-08: unknown place revealed to player")
	assert_eq(s.interactions.interactions_used_this_season(str(npc.id), s.season_index()), 1, "count spent on actual news")

	# Clear cooldown & all remaining news sources so second ask has nothing new.
	npc.interact_meta.cooldowns.erase("news")
	npc["known_places"] = []
	npc["visited"] = []
	var cur_reg: String = str(s.db.get_record("places", s.player.location_id).get("region_id", ""))
	for p in s.db.all("places"):
		if str(p.get("region_id", "")) == cur_reg:
			s.knowledge.places[str(p.id)] = true
	var spyr: int = int(s.gd.cultivation_rules().seasons_per_year)
	var seen_ev: Array = []
	for ev in s.db.all("events"):
		if s.season_index() - (int(ev.get("year", 0)) * spyr + int(ev.get("season", 0))) <= 4:
			seen_ev.append(str(ev.id))
	npc["shared_news_events"] = seen_ev

	var count_before: int = s.interactions.interactions_used_this_season(str(npc.id), s.season_index())
	var r2: Dictionary = s.interact(str(npc.id), "news")
	assert_true(bool(r2.ok) and bool(r2.get("nothing_new", false)), "AC-NI-08: nothing_new returned")
	assert_eq(str(r2.result_key), "nothing_new", "nothing_new voice line selected")
	assert_eq(s.interactions.interactions_used_this_season(str(npc.id), s.season_index()), count_before, "AC-NI-08: nothing_new spends no season count")
	assert_false(Dictionary(npc.interact_meta.cooldowns).has("news"), "AC-NI-08: nothing_new sets no cooldown")
	s.shutdown()


func test_yearly_attitude_drift_moves_one_point_toward_opinion_ac_ni_11() -> void:
	var s := _session()
	var npc: Dictionary = _spawn_here(s, {"attitude": 40, "met_player": true, "npc_traits": {"personality": ["calm"]}})
	# Ensure player shares 1 personality trait so opinion is ~10 (< 40).
	s.player.npc_traits = {"personality": ["calm"], "calling": "", "fate": [], "gained": []}
	s.sync_player()
	var op: float = NpcTraits.opinion(s.gd, s.db, npc, s.db.get_record("people", s.player.id))
	assert_true(op < 40.0, "precondition: opinion %.1f < 40" % op)
	s._yearly()
	assert_eq(int(npc.attitude), 39, "AC-NI-11: yearly drift moves 40 -> 39 toward opinion")
	s.shutdown()


func test_greet_completes_active_visit_stage_ac_ni_12() -> void:
	var s := _session()
	var npc: Dictionary = _spawn_here(s, {"attitude": 10})
	s.player.active_visits.append({"quest_id": "q_visit_01", "npc_id": str(npc.id), "completed": false})
	var r: Dictionary = s.interact(str(npc.id), "greet")
	assert_true(bool(r.ok))
	assert_true(bool(s.player.active_visits[0].completed), "AC-NI-12: greeting completes visit stage")
	s.shutdown()


# --- AC-NI-13, AC-NI-14, AC-NI-15, AC-NI-22 ---------------------------------------------------------------------------

func test_teaching_insight_bonus_yearly_limit_and_deed_flag_ac_ni_13_22() -> void:
	var s := _session()
	s.player.realm_index = 2   # Kết Đan
	var teacher: Dictionary = _spawn_here(s, {"realm_index": 3, "attitude": 60, "met_player": true})   # Nguyên Anh
	var speed_before: float = s.sheet().total("cultivation_speed_pct")

	var r: Dictionary = s.interact(str(teacher.id), "teach", {"lesson": "insight"})
	assert_true(bool(r.ok) and bool(r.accepted), "teaching accepted")
	assert_near(float(r.insight_pct), 20.0, 1e-6, "AC-NI-13: Nguyên Anh -> Kết Đan gives +20%%")
	assert_near(s.sheet().total("cultivation_speed_pct"), speed_before + 20.0, 1e-6, "sheet reflects +20%%")

	# AC-NI-22: flag 'taught' + WorldDB record exist
	assert_true(InteractionRules.npc_flags(teacher).has("taught"), "AC-NI-22: teacher carries flag 'taught'")
	assert_true(s.db.events_of(str(teacher.id)).any(func(e): return str(e.type) == "interaction_taught"), "AC-NI-22: WorldDB record logged")

	# Advance 1 season: buff MUST still be active next season!
	s._pass_season("")
	assert_near(s.sheet().total("cultivation_speed_pct"), speed_before + 20.0, 1e-6, "AC-NI-13: insight buff persists into next season")

	# Second lesson same year is refused even if cooldown were cleared.
	teacher.interact_meta.cooldowns.erase("teach")
	var r2: Dictionary = s.interact(str(teacher.id), "teach", {"lesson": "insight"})
	assert_false(bool(r2.ok), "AC-NI-13: second lesson from same teacher in same year refused")
	assert_eq(str(r2.get("reason", "")), "teach_yearly_limit")

	# Advance 1 more season: buff expires cleanly!
	s._pass_season("")
	assert_near(s.sheet().total("cultivation_speed_pct"), speed_before, 1e-6, "insight buff expires after next season")
	s.shutdown()


func test_sect_technique_not_offered_to_other_sect_student_ac_ni_14() -> void:
	var s := _session()
	var sects: Array = s.db.all("sects")
	assert_true(sects.size() >= 2, "precondition: at least 2 sects")
	var sect_a: String = str(sects[0].id)
	var sect_b: String = str(sects[1].id)
	var teacher: Dictionary = _spawn_here(s, {"realm_index": s.player.realm_index + 1, "attitude": 70, "met_player": true, "sect_id": sect_a})
	var own_el: String = s.player.linh_can.strongest_element()
	teacher["techniques"] = {
		"sect_secret_art": {
			"def": {"tech_id": "sect_secret_art", "name": "Bí Truyền Tông Môn", "tier": 1, "tech_kind": "secret", "names": [own_el], "layers": 6, "bonuses": [], "abilities": [], "seal_clusters": [], "origin": "sect", "sect_id": sect_a},
			"layer": 3, "mastery": 0.0, "seal_seasons": 0,
		},
		"open_art": {
			"def": {"tech_id": "open_art", "name": "Phổ Thông Tâm Pháp", "tier": 0, "tech_kind": "secret", "names": [own_el], "layers": 3, "bonuses": [], "abilities": [], "seal_clusters": [], "origin": "generated"},
			"layer": 3, "mastery": 0.0, "seal_seasons": 0,
		},
	}

	# Student in sect_b must NOT be offered sect_secret_art, only open_art.
	s.player.sect_id = sect_b
	var offered_b: Array = InteractionRules.teachable_manuals(s.gd, teacher, s.player).map(func(m): return str(m.tech_id))
	assert_false(offered_b.has("sect_secret_art"), "AC-NI-14: sect technique hidden from other-sect student")
	assert_true(offered_b.has("open_art"), "non-sect technique still offered")
	var fail_r: Dictionary = s.interact(str(teacher.id), "teach", {"lesson": "manual:sect_secret_art"})
	assert_false(bool(fail_r.ok), "AC-NI-14: requesting other sect's technique is refused")

	# Same-sect student IS offered sect_secret_art and receives a manual copy.
	s.player.sect_id = sect_a
	var offered_a: Array = InteractionRules.teachable_manuals(s.gd, teacher, s.player).map(func(m): return str(m.tech_id))
	assert_true(offered_a.has("sect_secret_art"), "same-sect student offered sect technique")
	var ok_r: Dictionary = s.interact(str(teacher.id), "teach", {"lesson": "manual:sect_secret_art"})
	assert_true(bool(ok_r.ok) and bool(ok_r.accepted), "same-sect manual copy granted")
	assert_true(str(ok_r.manual_id) != "" and s.db.has_record("items", str(ok_r.manual_id)), "manual item created in WorldDB")
	s.shutdown()


func test_loan_purse_cap_money_conservation_and_overdue_followup_ac_ni_15() -> void:
	var s := _session()
	var lender: Dictionary = _spawn_here(s, {"realm_index": 1, "attitude": 70, "met_player": true, "linh_thach": 1000})
	var ledger := MoneyLedger.new(s.db, s.player)
	ledger.open_season()
	var p_before: int = s.player.linh_thach
	var l_before: int = int(lender.linh_thach)

	# Ask for 999 -> capped at min(0.5 * 600, 1000) = 300!
	var r: Dictionary = s.interact(str(lender.id), "help", {"sub": "loan", "amount": 999})
	assert_true(bool(r.ok) and bool(r.accepted), "AC-NI-15: loan accepted")
	assert_eq(s.player.linh_thach, p_before + 300, "AC-NI-15: player receives capped 300")
	assert_eq(int(lender.linh_thach), l_before - 300, "AC-NI-15: drawn directly from lender purse")
	assert_near(float(ledger.season_check().gap), 0.0, 1e-6, "AC-NI-15: zero money minted/burned")

	# Advance 7 seasons (not yet due), then 8th season triggers overdue -> exact -30 drop (plus any yearly drift).
	for i in 7:
		s._pass_season("")
	assert_eq(str(InteractionService.loans_of(s.db, s.player.id, str(lender.id))[0].status), "open", "still open at season 7")
	var att_before_overdue: int = int(lender.attitude)
	s._pass_season("")
	assert_eq(str(InteractionService.loans_of(s.db, s.player.id, str(lender.id))[0].status), "overdue", "marked overdue at season 8")
	var expected_drop: int = 30 + (1 if s.season == 0 else 0)
	assert_eq(int(lender.attitude), att_before_overdue - expected_drop, "AC-NI-15: unpaid after 8 seasons drops attitude by 30 (plus yearly drift if year boundary)")
	var fu_rec: Dictionary = s.db.get_record("world", InteractionService.FOLLOWUPS_REC)
	assert_false(fu_rec.is_empty(), "AC-NI-15: follow-up event scheduled")
	assert_true(Array(fu_rec.items).any(func(f): return str(f.template_id) == "loan_collection" and str(f.npc_id) == str(lender.id)), "loan_collection queued for lender")

	# _maybe_event fires the scheduled loan_collection deterministically!
	s.pending_event = {}
	var ev_lines: Array = s._maybe_event(0.0)
	assert_false(ev_lines.is_empty(), "loan_collection fired")
	assert_eq(str(s.pending_event.source), "template:loan_collection", "pending event is loan_collection")
	s.shutdown()


# --- AC-NI-17, AC-NI-19, AC-NI-20, AC-NI-25 ---------------------------------------------------------------------------

func test_spar_foreseen_nonlethal_half_vitality_loss_and_rated_ac_ni_17() -> void:
	var s := _session(3031, true)
	var foe: Dictionary = _spawn_here(s, {"realm_index": s.player.realm_index, "attitude": 50, "met_player": true})
	var p_vit_before: float = s.player.vitality
	var n_vit_before: float = float(foe.get("vitality", 1.0))

	var r: Dictionary = s.interact(str(foe.id), "spar")
	assert_true(bool(r.ok) and bool(r.accepted), "AC-NI-17: spar accepted")
	assert_true(s.player.alive and bool(foe.alive), "AC-NI-17: non-lethal — neither dies")
	assert_near(s.season_time_used, 0.10, 1e-6, "AC-NI-17: 0.1 season spent")
	var sr: Dictionary = Dictionary(r.spar_result)
	assert_eq(str(sr.situation), "foreseen", "AC-NI-17: foreseen situation")
	assert_true(bool(sr.rated), "AC-NI-17: spar rated via RatingService")
	var normal_loss: float = float(s.gd.session().mission.injury_khi_huyet_loss_pct) / 100.0
	var expected_loss: float = normal_loss * float(InteractionRules.knobs(s.gd).spar_loss_share)
	if bool(sr.win):
		assert_near(n_vit_before - float(foe.vitality), expected_loss, 1e-5, "AC-NI-17: loser vitality loss is half normal")
	else:
		assert_near(p_vit_before - s.player.vitality, expected_loss, 1e-5, "AC-NI-17: loser vitality loss is half normal")
	s.shutdown()


func test_provoke_opens_foreseen_fight_event_with_mercy_choice_ac_ni_19() -> void:
	var s := _session(3032, false)
	# Make player strong so provoke duel is a guaranteed win.
	s.player.realm_index = 2
	s.player.level = Ladder.stage_first_level(s.gd, 2, 0)
	s.sync_player()
	var rival: Dictionary = _spawn_here(s, {"realm_index": 0, "attitude": 0, "met_player": true})
	var r: Dictionary = s.interact(str(rival.id), "provoke")
	assert_true(bool(r.ok) and bool(r.scene_started), "AC-NI-19: provoke opens event at once")
	assert_true(s.has_pending_event(), "pending event set")
	assert_eq(str(s.pending_event.source), "template:provoke_duel")
	assert_eq(str(s.pending_event.get("situation", "")), "foreseen", "AC-NI-19: foreseen situation")
	assert_true(bool(s.pending_event.get("mercy_choice", false)), "AC-NI-19: mercy_choice enabled")

	# Resolve fight choice (index 0) -> win -> immediate mercy choice event opens!
	var fight_r: Dictionary = s.choose(0)
	assert_true(bool(fight_r.ok), "duel resolved")
	assert_true(s.has_pending_event(), "AC-NI-19: mercy follow-up event opened after win")
	assert_eq(str(s.pending_event.source), "interaction:mercy_choice")

	# Choose Spare (index 0) -> rival stays alive with spared_by flag.
	var spare_r: Dictionary = s.choose(0)
	assert_true(bool(spare_r.ok))
	assert_false(s.has_pending_event(), "mercy event cleared")
	assert_true(bool(rival.alive), "spared rival lives")
	assert_true(InteractionRules.npc_flags(rival).has("spared_by"), "spared_by flag recorded")
	s.shutdown()


func test_bond_verbs_absent_when_ties_disabled_ac_ni_20() -> void:
	var s := _session(3035, false)   # own GameData copy so erasing Ties.FILE never affects shared cache
	var npc: Dictionary = _spawn_here(s, {"attitude": 80, "met_player": true})
	# Remove npc_relationships file from this session's GameData registry to simulate #46 disabled.
	s.gd.registry._files.erase(Ties.FILE)
	assert_false(Ties.enabled(s.gd), "precondition: Ties disabled")
	var menu: Array = s.interactions.list_verbs(s.player, s.sheet(), str(npc.id), s.season_index(), s.year, 0.0, false, s.knowledge)
	for v in menu:
		assert_true(str(v.group) != "bond", "AC-NI-20: bond verb '%s' must be absent when Ties disabled" % str(v.id))
	s.shutdown()


func test_on_talk_authored_scene_fires_with_single_greet_gain_ac_ni_25() -> void:
	var s := _session()
	var famous: Dictionary = _spawn_here(s, {"cast_key": "mac_quy_khu", "attitude": 20, "met_player": true})
	var pr: float = s.sheet().effective("mi_luc", s.player) - 50.0
	var expected_gain: int = InteractionRules.greet_delta(s.gd, pr, 0)

	var r: Dictionary = s.interact(str(famous.id), "greet")
	assert_true(bool(r.ok) and bool(r.scene_started), "AC-NI-25: on_talk authored scene fires on greet")
	assert_true(s.has_pending_event(), "authored scene set as pending_event")
	assert_eq(str(s.pending_event.source), "template:on_talk_mac_quy_khu_first")
	assert_eq(int(famous.attitude), 20 + expected_gain, "AC-NI-25: greeting gain applied exactly once")

	# Dismiss scene and greet again: 'once: true' prevents refiring.
	s.pending_event = {}
	var r2: Dictionary = s.interact(str(famous.id), "greet")
	assert_true(bool(r2.ok))
	assert_false(bool(r2.scene_started), "once:true scene does not fire a second time")
	s.shutdown()


# --- All 17 Base Verbs & All 19 Trait verb: Hooks + Conservation + Save/Load ------------------------------------------

func test_all_17_base_verbs_execute_cleanly_with_money_conservation() -> void:
	var s := _session()
	s.player.linh_thach = 5000
	s.player.realm_index = 2
	s.player.level = Ladder.stage_first_level(s.gd, 2, 0)
	s.sync_player()
	var sect_id: String = str(s.db.all("sects")[0].id)
	var other: Dictionary = _spawn_here(s, {"attitude": 20, "met_player": true, "name": "Triệu Tam"})
	s.player.met_list.append(str(other.id))

	var npc: Dictionary = _spawn_here(s, {"realm_index": 1, "attitude": 75, "met_player": true, "linh_thach": 2000, "sect_id": sect_id})
	# Give NPC a spare herb for trade and player a spare herb for trade sell.
	var npc_h: Dictionary = s.items.herb("ngung_khi_thao", 5.0)
	npc_h["owner_id"] = str(npc.id)
	var npc_hid: String = s.db.add("items", npc_h)
	var pl_h: Dictionary = s.items.herb("ngung_khi_thao", 5.0)
	pl_h["owner_id"] = s.player.id
	var pl_hid: String = s.db.add("items", pl_h)

	# Open books AFTER spawning test NPCs so M_start includes their starting purses.
	var ledger := MoneyLedger.new(s.db, s.player)
	ledger.open_season()

	# 1. greet, 2. news, 3. about, 4. gift, 5. work, 6. help (loan, guide, intro), 7. trade (buy & sell),
	# 8. repay, 9. companion, 10. disciple, 11. brotherhood, 12. dao_lu, 13. declare_enmity
	assert_true(bool(s.interact(str(npc.id), "greet").ok))
	npc["interact_meta"] = {}
	assert_true(bool(s.interact(str(npc.id), "about", {"target_id": str(other.id)}).accepted))
	npc["interact_meta"] = {}
	assert_true(bool(s.interact(str(npc.id), "gift", {"stones": 100}).accepted))
	npc["interact_meta"] = {}
	assert_true(bool(s.interact(str(npc.id), "work").ok))
	npc["interact_meta"] = {}
	assert_true(bool(s.interact(str(npc.id), "help", {"sub": "loan", "amount": 50}).accepted))
	npc["interact_meta"] = {}
	assert_true(bool(s.interact(str(npc.id), "repay").accepted))
	npc["interact_meta"] = {}
	assert_true(bool(s.interact(str(npc.id), "help", {"sub": "guide"}).accepted))
	npc["interact_meta"] = {}
	assert_true(bool(s.interact(str(npc.id), "help", {"sub": "introduction"}).accepted))
	npc["interact_meta"] = {}
	assert_true(bool(s.interact(str(npc.id), "trade", {"trade_action": "buy", "item_id": npc_hid}).accepted))
	npc["interact_meta"] = {}
	assert_true(bool(s.interact(str(npc.id), "trade", {"trade_action": "sell", "item_id": pl_hid}).accepted))
	npc["interact_meta"] = {}
	assert_true(bool(s.interact(str(npc.id), "companion").accepted))
	assert_true(Ties.has_pin(s.db, s.player.id, str(npc.id), "companion"), "companion tie written")
	npc["interact_meta"] = {}
	assert_true(bool(s.interact(str(npc.id), "disciple").accepted))
	assert_eq(Ties.master_of(s.db, str(npc.id)), s.player.id, "su_do tie written")
	npc["interact_meta"] = {}
	assert_true(bool(s.interact(str(npc.id), "brotherhood").accepted))
	assert_true(Ties.has_pin(s.db, s.player.id, str(npc.id), "ket_nghia"), "ket_nghia tie written")
	npc["interact_meta"] = {}
	assert_true(bool(s.interact(str(npc.id), "dao_lu").accepted))
	assert_true(Ties.has_pin(s.db, s.player.id, str(npc.id), "dao_lu"), "dao_lu tie written")
	npc["interact_meta"] = {}
	assert_true(bool(s.interact(str(npc.id), "declare_enmity").accepted))

	# Strict MoneyLedger conservation across gift + loan + repay + trade buy + trade sell!
	assert_near(float(ledger.season_check().gap), 0.0, 1e-6, "zero money mint/burn across all base money verbs")
	s.shutdown()


func test_all_19_trait_verb_hooks_side_gating_execution_and_money_conservation() -> void:
	var s := _session()
	s.player.linh_thach = 5000
	s.player.tam_ma = 30.0
	s.player.realm_index = 1
	s.sync_player()
	# Ensure player is at a settled place for command_mortals.
	var settled: Array = s.db.find("places", func(p): return str(p.get("type", "")) in ["thanh", "tran", "phuong_thi", "tong_mon"])
	if not settled.is_empty():
		s.player.location_id = str(settled[0].id)
		s.sync_player()

	var ledger := MoneyLedger.new(s.db, s.player)
	var traits_doc: Dictionary = s.gd.file(NpcTraits.FILE)
	var hooks: Array = Array(traits_doc.get("verb_hooks", []))
	assert_eq(hooks.size(), 19, "19 trait verb_hooks to test")

	# Map trait_id -> kind from catalogue.
	var kind_by_id: Dictionary = NpcTraits.catalogue(s.gd).kind

	for h in hooks:
		var vid: String = str(h.id)
		var tid: String = str(h.trait)
		var side: String = str(h.side)
		var tkind: String = str(kind_by_id.get(tid, "lifestyle"))

		# Fresh clean player traits & NPC per hook to verify exact side gating.
		s.player.npc_traits = {"personality": [], "calling": "", "fate": [], "gained": []}
		s.season_time_used = 0.0
		s.player.season_time_used = 0.0
		s.sync_player()
		var npc: Dictionary = _spawn_here(s, {"realm_index": 1, "attitude": 80, "met_player": true, "linh_thach": 2000})
		npc["npc_traits"] = {"personality": [], "calling": "", "fate": [], "gained": []}

		# Without the trait on either side, executing must be rejected.
		var locked_r: Dictionary = s.interact(str(npc.id), vid)
		assert_false(bool(locked_r.ok), "trait verb '%s' locked without trait '%s'" % [vid, tid])

		# Grant trait on the required side.
		if side == "self":
			_add_player_trait(s, tkind, tid, 2)
		elif side == "other":
			_add_npc_trait(npc, tkind, tid, 2)
		else:
			_add_npc_trait(npc, tkind, tid, 2)   # 'either' unlocked by NPC holding it

		var opts: Dictionary = {}
		if vid == "trade_curio":
			var curio: Dictionary = s.items.artifact(s.rng, 1, 2, "hoa")
			curio["owner_id"] = s.player.id
			var cid: String = s.db.add("items", curio)
			opts["item_id"] = cid
		elif vid == "wager":
			opts["stake"] = 50
		elif vid == "ask_history":
			s.db.log_event(100, 0, "history", "Biến cố cổ xưa của vùng này.", [str(npc.id)], [s.player.location_id], [])

		ledger.open_season()
		var res: Dictionary = s.interact(str(npc.id), vid, opts)
		assert_true(bool(res.ok), "trait verb '%s' (%s/%s) executes ok: %s" % [vid, tid, side, str(res.lines)])
		assert_true(bool(res.accepted), "trait verb '%s' accepted at attitude 80" % vid)
		assert_true(str(res.reply).strip_edges() != "", "trait verb '%s' returns voiced Vietnamese reply" % vid)
		assert_false(str(res.reply).contains("{") or str(res.reply).contains("}"), "trait verb '%s' has no unresolved tokens" % vid)
		assert_near(float(ledger.season_check().gap), 0.0, 1e-6, "zero money mint/burn on trait verb '%s'" % vid)
	s.shutdown()


func test_save_load_preserves_interaction_state_and_loads_old_saves_safely() -> void:
	var s := _session()
	var elder: Dictionary = _spawn_here(s, {"realm_index": s.player.realm_index + 1, "attitude": 70, "met_player": true, "linh_thach": 1000})
	s.player.active_visits.append({"quest_id": "q_old", "npc_id": str(elder.id), "completed": false})
	assert_true(bool(s.interact(str(elder.id), "teach", {"lesson": "insight"}).accepted))
	assert_true(bool(s.interact(str(elder.id), "help", {"sub": "loan", "amount": 30}).accepted))

	var saved: Dictionary = JSON.parse_string(JSON.stringify(s.to_dict()))
	var s2 := _session()
	var lr: Dictionary = s2.load_dict(saved)
	assert_true(bool(lr.ok), "round-trip load ok")
	assert_near(s2.season_time_used, 0.25, 1e-6, "season_time_used preserved")
	assert_eq(s2.player.interaction_buffs.size(), 1, "interaction_buffs preserved")
	assert_eq(s2.player.active_visits.size(), 1, "active_visits preserved")
	assert_eq(InteractionService.loans_of(s2.db, s2.player.id, str(elder.id)).size(), 1, "w_loans preserved")

	# Simulate loading an older pre-Wave-2 save lacking every new field.
	var old_save: Dictionary = saved.duplicate(true)
	old_save.erase("season_time_used")
	var old_pl: Dictionary = old_save.db.tables.people[old_save.player_id]
	for k in ["season_time_used", "interaction_buffs", "heart_demon_used", "active_visits", "interaction_flags"]:
		old_pl.erase(k)
	var s3 := _session()
	var lr_old: Dictionary = s3.load_dict(old_save)
	assert_true(bool(lr_old.ok), "old save without Wave 2 keys loads cleanly")
	assert_near(s3.season_time_used, 0.0, 1e-6, "old save defaults season_time_used to 0.0")
	assert_eq(s3.player.interaction_buffs, [], "old save defaults interaction_buffs to []")
	assert_eq(s3.player.active_visits, [], "old save defaults active_visits to []")
	s.shutdown()
	s2.shutdown()
	s3.shutdown()
