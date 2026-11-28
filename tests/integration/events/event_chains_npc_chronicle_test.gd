extends DaoTestSuite
## Wave 2 W2A integration tests for Event Engine (#23) chains, combat/mercy, Formula K economy,
## NPC traits F2, player-rooted NPC follow-ups, save/reload parity, and hidden chronicle uncoverings:
## Covers AC-EV-08, 14, 26, 29, 30, 35, 37, 46, and AC-WG-56.

const _EventStore = preload("res://src/gameplay/events/event_store.gd")
const _EventEngine = preload("res://src/gameplay/events/event_engine.gd")


static var _gd_cached: GameData
static var _world_snap: String = ""


static func _shared_gd() -> GameData:
	if _gd_cached == null:
		_gd_cached = GameData.load_from("res://assets/data")
		_gd_cached.world_gen().people.world_cultivators = 80
		_gd_cached.world_gen().people.world_cultivators_min = 0
		_gd_cached.file("combat_rankings")["enabled"] = false
	return _gd_cached


static func _session_fresh() -> GameSession:
	var gd := _shared_gd()
	if _world_snap == "":
		var llm0 := LlmService.new(gd)
		llm0.enabled = false
		var s0 := GameSession.new(gd, llm0, TestFixtures.tree())
		s0.ratings_background = false
		s0.new_game(4401, {"mode": "roll", "name": "Trần Mặc", "gender": "male", "origin": "tan_tu"})
		s0.pending_event = {}
		_world_snap = JSON.stringify(s0.to_dict())
		s0.shutdown()
	var llm := LlmService.new(gd)
	llm.enabled = false
	var s := GameSession.new(gd, llm, TestFixtures.tree())
	s.ratings_background = false
	s.load_dict(JSON.parse_string(_world_snap))
	s.pending_event = {}
	return s


# --- AC-EV-08: Travel stretch filters on_travel_stretch by biome & mode, zero pulse roll ---------

func test_travel_stretch_filters_by_biome_and_mode_without_pulse_ac_ev_08() -> void:
	var s := _session_fresh()
	var eng := _EventEngine.new(s.gd, s.db, s.builds, s.templates, s.validator, s.resolver)
	var r := eng.raise_hook("on_travel_stretch", s.player, s.sheet(), s.rng, {
		"year": s.year, "season": s.season, "biome": "desert", "travel_mode": "wilderness", "chance_override": 1.0,
	})
	assert_true(bool(r.ok) and bool(r.get("fired", false)), "AC-EV-08: desert wilderness stretch fires an event")
	assert_eq(str(r.event.hook), "on_travel_stretch", "AC-EV-08: strictly from on_travel_stretch hook")
	var tpl: Dictionary = s.templates.get_template(str(r.event.template_id))
	assert_eq(str(tpl.get("hook", "")), "on_travel_stretch", "template is on_travel_stretch")
	assert_eq(str(tpl.get("kind", "")), "hook", "not a pulse template")
	s.shutdown()


# --- AC-EV-14: Pending event refuses cultivate naming event title --------------------------------

func test_pending_event_refuses_cultivate_naming_title_ac_ev_14() -> void:
	var s := _session_fresh()
	s.pending_event = {
		"title": "Khách Lạ Ghé Thăm", "text": "Có người gõ cửa.", "npc_id": "", "place_id": s.player.location_id,
		"source": "test", "choices": [
			{"label": "Mở", "check": {"type": "none"}, "always": [], "success": {"text": "Mở.", "effects": []}, "failure": {"text": "Mở.", "effects": []}},
			{"label": "Đóng", "check": {"type": "none"}, "always": [], "success": {"text": "Đóng.", "effects": []}, "failure": {"text": "Đóng.", "effects": []}},
		],
	}
	var res: Dictionary = s.cultivate(1)
	assert_false(bool(res.ok), "AC-EV-14: cultivate refused while event pending")
	assert_true("\n".join(res.lines).contains("Khách Lạ Ghé Thăm"), "AC-EV-14: refusal names event title: %s" % str(res.lines))
	s.shutdown()


# --- AC-EV-26: Formula K commons pool cap (500 from 200 -> pays 200, pool=0, text=200, gap=0) -----

func test_formula_k_commons_pool_pays_available_balance_and_conserves_money_ac_ev_26() -> void:
	var s := _session_fresh()
	var m_sect: String = MoneyLedger.market_sect_of(s.db, s.player.location_id)
	assert_true(m_sect != "", "player starts in a market region")
	var pool_id: String = "pool:%s" % m_sect
	s.db.get_record(MoneyLedger.TABLE, pool_id)["balance"] = 200.0
	var ledger := MoneyLedger.new(s.db, s.player)
	ledger.open_season()
	var pl_before: int = s.player.linh_thach

	var ev := {
		"title": "Kho báu chợ", "text": "Một hòm linh thạch.", "npc_id": "", "place_id": s.player.location_id, "source": "test",
		"choices": [{
			"label": "Nhận thưởng", "check": {"type": "none"}, "always": [],
			"success": {"text": "Ngươi thu được {paid} linh thạch.", "effects": [{"type": "linh_thach", "amount": 500, "source": "commons"}]},
			"failure": {"text": "", "effects": []},
		}],
	}
	var res: Dictionary = s.resolver.resolve(s.player, s.sheet(), s.rng, ev, 0, {"year": s.year, "season": s.season})
	assert_eq(int(res.paid), 200, "AC-EV-26: paid clamped to pool balance 200")
	assert_eq(s.player.linh_thach, pl_before + 200, "AC-EV-26: player gained 200")
	assert_near(ledger.balance(pool_id), 0.0, 1e-6, "AC-EV-26: pool balance is now 0")
	assert_true(str(res.outcome_text).contains("200"), "AC-EV-26: outcome text shows actual paid 200: %s" % str(res.outcome_text))
	assert_near(float(ledger.season_check().gap), 0.0, 1e-6, "AC-EV-26: MoneyLedger gap == 0 (no money created)")
	s.shutdown()


# --- AC-EV-29 & AC-EV-30: Combat situation/ground_tags pass-through & cultivator Mercy ------------

func test_combat_situation_ground_tags_and_cultivator_mercy_ac_ev_29_ac_ev_30() -> void:
	var s := _session_fresh()
	# Make player strong enough to win decisively against a Qi Refining foe
	s.player.realm_index = 2
	s.player.level = Ladder.stage_first_level(s.gd, 2, 0)
	s.sync_player()
	var foe_id: String = s.builds.create_person(s.rng, {"realm_index": 0, "archetype": "kiem_tu", "location_id": s.player.location_id})
	var ev := {
		"title": "Tập kích động phủ", "text": "Kẻ địch đột nhập.", "npc_id": foe_id, "place_id": s.player.location_id, "source": "test",
		"choices": [{
			"label": "Nghênh chiến",
			"check": {"type": "combat", "enemy": foe_id, "situation": "ambush", "ground_tags": ["own_abode"], "no_heal": false, "mercy_allowed": true},
			"always": [],
			"success": {"text": "Ngươi áp chế đối thủ.", "effects": []},
			"failure": {"text": "Ngươi bị đẩy lui.", "effects": []},
		}],
	}
	s.gd.combat()["fight_engine"]["enabled"] = true
	var res: Dictionary = s.resolver.resolve(s.player, s.sheet(), s.rng, ev, 0, {"year": s.year, "season": s.season})
	assert_eq(int(s.resolver.last_fight_request.situation_raw), FightRequest.Situation.AMBUSH, "AC-EV-29: ambush passed to Combat")
	assert_true(Array(s.resolver.last_fight_request.ground_tags).has("own_abode"), "AC-EV-29: own_abode passed to Combat")
	assert_true(s.resolver.last_fight != null and Array(s.resolver.last_fight.notes).any(func(n): return str(n).contains("own_abode")), "AC-EV-29/AC-CB-104: CombatService received & noted own_abode")
	assert_true(bool(res.success), "Kết Đan player beats Luyện Khí foe")
	assert_true(bool(res.mercy_pending) and str(res.mercy_target_id) == foe_id, "AC-EV-30: cultivator win offers mercy")

	# Spare -> foe lives with spared_by = player.id
	var sp: Dictionary = s.resolver.resolve_mercy(s.player, foe_id, false, s.year, s.season)
	assert_true(bool(sp.ok) and not bool(sp.killed), "AC-EV-30: spare succeeds")
	assert_true(bool(s.db.get_record("people", foe_id).alive), "AC-EV-30: spared foe stays alive")
	assert_eq(str(_EventStore.get_flag(s.db, foe_id, "spared_by", s.season_index(), "")), s.player.id, "AC-EV-30: spared_by flag set to player id")

	# Kill on a second foe -> foe dies in WorldDB with record
	var foe2_id: String = s.builds.create_person(s.rng, {"realm_index": 0, "archetype": "tan_tu", "location_id": s.player.location_id})
	var kl: Dictionary = s.resolver.resolve_mercy(s.player, foe2_id, true, s.year, s.season)
	assert_true(bool(kl.ok) and bool(kl.killed), "AC-EV-30: kill succeeds")
	assert_false(bool(s.db.get_record("people", foe2_id).alive), "AC-EV-30: killed foe marked dead in WorldDB")
	assert_true(s.db.events_of(foe2_id).size() >= 1, "AC-EV-30: kill logged in WorldDB")

	# Beast win offers taming (no mercy_pending)
	var beast_id: String = s.builds.create_person(s.rng, {"realm_index": 0, "is_beast": true, "location_id": s.player.location_id})
	var ev_b := ev.duplicate(true)
	ev_b["npc_id"] = beast_id
	ev_b.choices[0].check["enemy"] = beast_id
	var rb: Dictionary = s.resolver.resolve(s.player, s.sheet(), s.rng, ev_b, 0, {"year": s.year, "season": s.season})
	assert_false(bool(rb.mercy_pending), "AC-EV-30: beast fight never offers cultivator mercy")
	s.shutdown()


# --- AC-EV-35: Wrathful+Vengeful NPC choice share matches NpcTraits F2 within ±3 pts -------------

func test_npc_traits_f2_choice_share_matches_over_1000_keyed_trials_ac_ev_35() -> void:
	var s := _session_fresh()
	var npc_rec := {
		"id": "p_wrath_35", "name": "Liệt Hỏa", "alive": true, "realm_index": 1, "stage": 0,
		"location_id": s.player.location_id, "linh_thach": 100.0,
		"thien_phu": {"ngo_tinh": 50, "can_cot": 50, "than_hon": 50, "khi_van": 50, "dao_tam": 50, "mi_luc": 50},
		"npc_traits": {"personality": ["wrathful", "vengeful"], "calling": "wanderer", "fate": [], "gained": []},
	}
	s.db.put("people", npc_rec)
	var ev := {
		"template_id": "ev_f2_trial", "title": "Tranh chấp", "log": "{root} quyết định.", "place_id": s.player.location_id, "npc_id": "",
		"choices": [
			{"label": "Đánh thẳng", "tags": ["aggressive", "vengeful"], "check": {"type": "none"}, "always": [], "success": {"text": "Đánh.", "effects": []}},
			{"label": "Tha thứ", "tags": ["merciful"], "check": {"type": "none"}, "always": [], "success": {"text": "Tha.", "effects": []}},
		],
	}
	var w_agg: float = NpcTraits.choice_weight(s.gd, npc_rec, ["aggressive", "vengeful"], 1.0)
	var w_mer: float = NpcTraits.choice_weight(s.gd, npc_rec, ["merciful"], 1.0)
	var expected_share: float = w_agg / (w_agg + w_mer)
	var agg_count: int = 0
	for trial in 1000:
		var r: Dictionary = s.resolver.resolve_npc(npc_rec, ev, 1200 + trial, 0, 5000 + trial, null, s.player.id)
		if int(r.choice_index) == 0:
			agg_count += 1
	var got_share: float = float(agg_count) / 1000.0
	assert_true(absf(got_share - expected_share) <= 0.03,
		"AC-EV-35: aggressive share %.3f within ±0.03 of F2 expected %.3f" % [got_share, expected_share])
	s.shutdown()


# --- AC-EV-37: NPC event schedules player-rooted follow-up ---------------------------------------

func test_npc_event_schedules_player_followup_under_pacing_cap_ac_ev_37() -> void:
	var s := _session_fresh()
	var eng := _EventEngine.new(s.gd, s.db, s.builds, s.templates, s.validator, s.resolver)
	var rival_id: String = s.builds.create_person(s.rng, {"realm_index": 0, "location_id": s.player.location_id})
	var rival_rec: Dictionary = s.db.get_record("people", rival_id)
	var npc_ev := {
		"template_id": "ev_npc_schedule_revenge", "title": "Oán hận âm ỉ", "log": "%s nuôi oán." % rival_rec.name,
		"place_id": s.player.location_id, "npc_id": "", "newsworthy": true,
		"choices": [{
			"label": "Gửi chiến thư", "tags": ["vengeful"], "check": {"type": "none"}, "always": [],
			"success": {"text": "Đã gửi.", "effects": [
				{"type": "schedule_followup", "event_id": "ev_fu_rival_revenge_call", "target_root": "player", "delay_seasons": [2, 2], "wait_seasons": 4},
			]},
		}],
	}
	var r_npc: Dictionary = s.resolver.resolve_npc(rival_rec, npc_ev, s.year, s.season, 888, null, s.player.id)
	assert_eq(r_npc.scheduled_followups.size(), 1, "AC-EV-37: NPC scheduled a player-rooted follow-up")
	var due_s: int = s.season_index() + 2
	eng.on_season_start(s.player, s.sheet(), s.rng, due_s / 4, due_s % 4)
	var pl_ev: Dictionary = eng.drain_queue(s.player, s.sheet(), s.rng, due_s / 4, due_s % 4)
	assert_eq(str(pl_ev.get("template_id", "")), "ev_fu_rival_revenge_call", "AC-EV-37: player receives the NPC-scheduled follow-up")
	assert_eq(str(pl_ev.get("npc_id", "")), rival_id, "AC-EV-37: follow-up binds the triggering NPC")
	s.shutdown()


# --- AC-EV-46: Save/reload preserves pending event, 2 follow-ups, active story & next 20 draws ---

func test_save_reload_preserves_event_state_and_next_20_draws_ac_ev_46() -> void:
	var s := _session_fresh()
	var eng := _EventEngine.new(s.gd, s.db, s.builds, s.templates, s.validator, s.resolver)
	s.pending_event = {"title": "Chờ chọn", "text": "Vẫn đang chờ.", "npc_id": "", "place_id": s.player.location_id, "source": "test", "choices": []}
	var f1: String = _EventStore.add_followup(s.db, {"event_id": "ev_fu_friend_request", "root_id": s.player.id, "scheduled_at": 100, "due_season": 104, "wait_seasons": 4})
	var f2: String = _EventStore.add_followup(s.db, {"event_id": "ev_fu_debt_collector_arrives", "root_id": s.player.id, "scheduled_at": 101, "due_season": 105, "wait_seasons": 4})
	var st_r: Dictionary = eng.start_story("story_chronicle_lang_dao_03", s.player.id, {}, s.year, s.season, false, -1, s.player, s.sheet())
	var sinst: String = str(st_r.story.id)
	eng.advance_story(sinst, "s2_ledger", s.year, s.season)

	var saved: Dictionary = JSON.parse_string(JSON.stringify(s.to_dict()))
	var draws_orig: Array = []
	for _i in 20:
		draws_orig.append(s.rng.randi())

	var s2 := _session_fresh()
	assert_true(bool(s2.load_dict(saved).ok), "AC-EV-46: reload ok")
	var draws_reloaded: Array = []
	for _i in 20:
		draws_reloaded.append(s2.rng.randi())
	assert_eq(draws_reloaded, draws_orig, "AC-EV-46: next 20 RNG draws match identically after reload")
	assert_eq(str(s2.pending_event.get("title", "")), "Chờ chọn", "AC-EV-46: pending event preserved")
	assert_false(_EventStore.get_followup(s2.db, f1).is_empty(), "AC-EV-46: follow-up 1 preserved")
	assert_false(_EventStore.get_followup(s2.db, f2).is_empty(), "AC-EV-46: follow-up 2 preserved")
	assert_eq(str(_EventStore.get_story(s2.db, sinst).get("stage", "")), "s2_ledger", "AC-EV-46: story stage preserved")
	s.shutdown()
	s2.shutdown()


# --- AC-WG-56 + WorldBuilder cast secrets/wants + WorldTicker NPC step & estate_at_death ---------

func test_hidden_chronicles_uncovering_cast_secrets_and_ticker_conservation_ac_wg_56() -> void:
	var s := _session_fresh()
	# 1. Verify all 5 hidden chronicles start hidden and excluded from public annals/news
	var hidden_ids := ["N-lang_dao-03", "N-suong_tung-02", "N-thai_chi-04", "N-van_hac-03", "N-clans-09"]
	for hid in hidden_ids:
		var matches: Array = s.db.all("events").filter(func(e): return str(Dictionary(e.get("data", {})).get("id", "")) == hid)
		assert_eq(matches.size(), 1, "AC-WG-56: hidden chronicle '%s' present in WorldDB" % hid)
		assert_true(_EventEngine.is_hidden_chronicle(matches[0]), "AC-WG-56: '%s' is hidden at worldgen" % hid)
		assert_false(_EventEngine.is_news_for_player(s.db, matches[0], s.player.id), "AC-WG-56: '%s' excluded from public news" % hid)

	# 2. Uncover N-lang_dao-03 via EventEngine.uncover_chronicle -> revealed with secret=false, tier=annal; 2nd call idempotent
	var u1: Dictionary = _EventEngine.uncover_chronicle(s.db, "N-lang_dao-03")
	assert_true(bool(u1.ok) and bool(u1.changed), "AC-WG-56: first uncovering reveals N-lang_dao-03")
	var rec_after: Dictionary = s.db.get_record("events", str(u1.event_id))
	assert_false(_EventEngine.is_hidden_chronicle(rec_after), "AC-WG-56: no longer hidden")
	assert_false(bool(rec_after.data.get("secret", true)), "AC-WG-56: secret flag cleared")
	assert_eq(str(rec_after.data.get("tier", "")), "annal", "AC-WG-56: promoted to annal tier")
	var u2: Dictionary = _EventEngine.uncover_chronicle(s.db, "N-lang_dao-03")
	assert_true(bool(u2.ok) and not bool(u2.changed), "AC-WG-56: second uncovering is an idempotent no-op")

	# 3. Verify WorldBuilder copied cast secrets and wants onto living cast records
	var cast_with_wants: int = 0
	var cast_with_secrets: int = 0
	for p in s.db.living():
		if str(p.get("cast_key", "")) != "":
			if str(p.get("wants", "")).strip_edges() != "":
				cast_with_wants += 1
			if str(p.get("secrets", "")).strip_edges() != "":
				cast_with_secrets += 1
	assert_true(cast_with_wants > 0, "WorldBuilder copied authored cast wants (%d)" % cast_with_wants)
	assert_true(cast_with_secrets > 0, "WorldBuilder copied authored cast secrets (%d)" % cast_with_secrets)

	# 4. Verify WorldTicker with EventEngine wired conserves MoneyLedger (gap == 0) AND records estate_at_death
	var eng := _EventEngine.new(s.gd, s.db, s.builds, s.templates, s.validator, s.resolver)
	s.ticker.event_engine = eng
	var victims: Array = s.db.living().filter(func(p): return not bool(p.get("is_player", false)) and not bool(p.get("is_beast", false)))
	var victim: Dictionary = victims[0]
	victim["linh_thach"] = 345.0
	victim["age"] = float(s.gd.realm(int(victim.realm_index)).lifespan) + 1.0
	s.ticker.tick(s.rng, s.year, s.season)
	var chk: Dictionary = MoneyLedger.new(s.db, s.player).season_check()
	assert_near(float(chk.gap), 0.0, 0.5, "WorldTicker + EventEngine NPC step preserves MoneyLedger conservation (gap %.4f)" % float(chk.gap))
	assert_false(bool(victim.alive), "aged victim died in tick")
	assert_true(float(victim.get("estate_at_death", 0.0)) >= 345.0, "WorldTicker recorded estate_at_death before settlement (got %.2f)" % float(victim.get("estate_at_death", 0.0)))
	assert_near(float(victim.get("linh_thach", -1.0)), 0.0, 0.01, "purse settled after death")
	# Also verify exact estate_at_death snapshot on direct old_age_death
	var victim2: Dictionary = victims[1]
	victim2["linh_thach"] = 345.0
	s.ticker.old_age_death(victim2, s.year, s.season)
	assert_near(float(victim2.get("estate_at_death", -1.0)), 345.0, 0.01, "old_age_death records exact pre-settlement estate_at_death")
	s.shutdown()
