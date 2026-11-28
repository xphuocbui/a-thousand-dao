extends DaoTestSuite
## Multi-season end-to-end integration tests for NPC Interaction & Dialogue (#30) + 19 Trait verb: hooks.
## Verifies full player-NPC lifecycles through GameSession + GameQuery + WorldTicker + MoneyLedger + Ties +
## RatingService, plus full JSON save/load round-trip and backwards compatibility with pre-#30 saves.

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
		s.new_game(4040, {"mode": "roll", "name": "Hàn Lập", "gender": "male", "origin": "tan_tu"})
		s.pending_event = {}
		_base_save_off = JSON.stringify(s.to_dict())
		s.shutdown()
	return _base_save_off


func _session(seed_v: int = 4040, ratings_on: bool = false) -> GameSession:
	if seed_v == 4040 and not ratings_on:
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
	s2.new_game(seed_v, {"mode": "roll", "name": "Hàn Lập", "gender": "male", "origin": "tan_tu"})
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


static func _find_verb(pv: Dictionary, verb_id: String) -> Dictionary:
	for grp in Array(pv.get("groups", [])):
		for v in Array((grp as Dictionary).get("verbs", [])):
			if str((v as Dictionary).get("id", "")) == verb_id:
				return v as Dictionary
	return {}


# --- 1. Greet + on_talk scenes + Ask for news + Active visit stage (AC-NI-08, AC-NI-12, AC-NI-25) --------------------

func test_greet_on_talk_scenes_news_and_visit_lifecycle_ac_ni_08_12_25() -> void:
	var s := _session()
	var mac: Dictionary = _spawn_here(s, {"cast_key": "mac_quy_khu", "name": "Mạc Quỷ Khu", "attitude": 20, "met_player": true})
	var so: Dictionary = _spawn_here(s, {"cast_key": "so_ngoc_ho", "name": "Sở Ngọc Hồ", "attitude": 15, "met_player": false})
	so["last_talk_season"] = -1
	s.player.active_visits.append({"quest_id": "q_visit_mac", "npc_id": str(mac.id), "completed": false})

	var pr: float = s.sheet().effective("mi_luc", s.player) - 50.0
	var expected_greet: int = InteractionRules.greet_delta(s.gd, pr, 0)

	# Greet met cast NPC -> single greeting gain, visit stage completed, on_talk_mac_quy_khu_first fired.
	var r_mac: Dictionary = s.interact(str(mac.id), "greet")
	assert_true(bool(r_mac.ok) and bool(r_mac.accepted), "greet Mạc Quỷ Khu ok")
	assert_true(bool(r_mac.scene_started), "AC-NI-25: on_talk_mac_quy_khu_first triggered")
	assert_eq(str(s.pending_event.source), "template:on_talk_mac_quy_khu_first")
	assert_eq(int(mac.attitude), 20 + expected_greet, "AC-NI-25: greeting gain applies exactly once")
	assert_true(bool(s.player.active_visits[0].completed), "AC-NI-12: active visit stage completed on greet")

	# Dismiss scene and greet again -> once:true prevents refiring.
	s.pending_event = {}
	var r_mac2: Dictionary = s.interact(str(mac.id), "greet")
	assert_true(bool(r_mac2.ok) and not bool(r_mac2.scene_started), "once:true scene does not refire")

	# Greet unmet cast NPC Sở Ngọc Hồ -> meets her (att0 + known_people) and triggers on_talk_so_ngoc_ho_vessel.
	var r_so: Dictionary = s.interact(str(so.id), "greet")
	assert_true(bool(r_so.ok) and bool(r_so.scene_started), "AC-NI-25: on_talk_so_ngoc_ho_vessel triggered")
	assert_eq(str(s.pending_event.source), "template:on_talk_so_ngoc_ho_vessel")
	assert_true(bool(so.get("met_player", false)), "Sở Ngọc Hồ marked met")
	var known: Array = GameQuery.known_people(s)
	assert_true(known.any(func(k): return str(k.id) == str(so.id)), "GameQuery.known_people includes Sở Ngọc Hồ")
	s.pending_event = {}

	# AC-NI-08: Ask for news reveals unknown place, then nothing_new spends neither season count nor cooldown.
	var informant: Dictionary = _spawn_here(s, {"attitude": 35, "met_player": true})
	var hidden_or_new: String = s.db.add("places", {
		"name": "Thanh Vân Cổ Động", "type": "son", "kind": "ruin", "region_id": "", "hidden": false, "links": [],
	})
	informant["known_places"] = [hidden_or_new]
	assert_false(s.knowledge.knows_place(hidden_or_new), "precondition: place unknown")

	var rn1: Dictionary = s.interact(str(informant.id), "news")
	assert_true(bool(rn1.ok) and bool(rn1.accepted) and not bool(rn1.get("nothing_new", false)))
	assert_true(s.knowledge.knows_place(hidden_or_new), "AC-NI-08: place revealed by ask news")
	assert_eq(int(GameQuery.person_verbs(s, str(informant.id)).interactions_used), 1)

	# Exhaust remaining news sources & clear cooldown so second ask has nothing new.
	informant.interact_meta.cooldowns.erase("news")
	informant["known_places"] = []
	informant["visited"] = []
	var cur_reg: String = str(s.db.get_record("places", s.player.location_id).get("region_id", ""))
	for p in s.db.all("places"):
		if str(p.get("region_id", "")) == cur_reg:
			s.knowledge.places[str(p.id)] = true
	var spyr: int = int(s.gd.cultivation_rules().seasons_per_year)
	var seen_ev: Array = []
	for ev in s.db.all("events"):
		if s.season_index() - (int(ev.get("year", 0)) * spyr + int(ev.get("season", 0))) <= 4:
			seen_ev.append(str(ev.id))
	informant["shared_news_events"] = seen_ev

	var rn2: Dictionary = s.interact(str(informant.id), "news")
	assert_true(bool(rn2.ok) and bool(rn2.get("nothing_new", false)), "AC-NI-08: nothing_new returned")
	assert_eq(int(GameQuery.person_verbs(s, str(informant.id)).interactions_used), 1, "AC-NI-08: nothing_new spends no season count")
	assert_false(Dictionary(informant.interact_meta.cooldowns).has("news"), "AC-NI-08: nothing_new sets no cooldown")
	s.shutdown()


# --- 2. Gift diminishing returns across a year & reset next year + MoneyLedger conservation --------------------------

func test_gift_diminishing_returns_across_seasons_and_year_reset() -> void:
	var s := _session()
	s.season = 0   # Start at Spring so 4 seasons cross cleanly into next year.
	s.player.linh_thach = 4000
	s.sync_player()
	var npc: Dictionary = _spawn_here(s, {"realm_index": 1, "attitude": 0, "met_player": true, "linh_thach": 100, "npc_traits": {"personality": ["calm"]}})
	var ledger := MoneyLedger.new(s.db, s.player)
	ledger.open_season()

	var g1: Dictionary = s.interact(str(npc.id), "gift", {"stones": 400})
	assert_true(bool(g1.ok) and bool(g1.accepted), "1st gift ok")
	var d1: int = int(g1.attitude_after) - int(g1.attitude_before)

	var g2: Dictionary = s.interact(str(npc.id), "gift", {"stones": 400})
	assert_true(bool(g2.ok) and bool(g2.accepted), "2nd gift ok")
	var d2: int = int(g2.attitude_after) - int(g2.attitude_before)
	assert_true(d1 > d2 and d2 > 0, "2nd gift same year halves attitude gain (%d -> %d)" % [d1, d2])
	assert_true(InteractionRules.npc_flags(npc).has("gifted_by"), "notable gift sets gifted_by flag")
	assert_near(float(ledger.season_check().gap), 0.0, 1e-6, "MoneyLedger exact conservation on gifts")

	# Advance 1 season (still same year) -> 3rd gift diminishes further!
	s._pass_season("")
	var g3: Dictionary = s.interact(str(npc.id), "gift", {"stones": 400})
	var d3: int = int(g3.attitude_after) - int(g3.attitude_before)
	assert_true(d2 > d3 and d3 >= 0, "3rd gift same year diminishes further (%d -> %d)" % [d2, d3])

	# Advance remaining 3 seasons into the next year -> gift_year_count resets!
	for _i in 3:
		s._pass_season("")
	npc["attitude"] = 0
	var g_next_yr: Dictionary = s.interact(str(npc.id), "gift", {"stones": 400})
	var d_next: int = int(g_next_yr.attitude_after) - int(g_next_yr.attitude_before)
	assert_eq(d_next, d1, "new year resets gift diminishing returns (%d == %d)" % [d_next, d1])
	s.shutdown()


# --- 3. Teach + 0.25 season focus tax -> 75% next focus yield + insight buff lifecycle --------------------------------

func test_teach_quarter_season_focus_tax_75_pct_yield_and_buff_lifecycle() -> void:
	var s := _session()
	s.player.realm_index = 1   # Trúc Cơ
	s.player.level = Ladder.stage_first_level(s.gd, 1, 0)
	s.sync_player()
	var teacher: Dictionary = _spawn_here(s, {"realm_index": 2, "attitude": 65, "met_player": true})

	# Clone identical baseline session to compare 100% vs 75% cultivation yield cleanly.
	var snap: String = JSON.stringify(s.to_dict())
	var s_base := _session()
	s_base.load_dict(JSON.parse_string(snap))
	var tu_base0: float = s_base.player.tu_vi
	s_base._pass_season("cultivate")
	var gain_base: float = s_base.player.tu_vi - tu_base0
	assert_true(gain_base > 0.0, "baseline cultivation gain positive")

	var speed_before: float = s.sheet().total("cultivation_speed_pct")
	var r_teach: Dictionary = s.interact(str(teacher.id), "teach", {"lesson": "insight"})
	assert_true(bool(r_teach.ok) and bool(r_teach.accepted), "teach accepted")
	assert_near(s.season_time_used, 0.25, 1e-6, "0.25 season focus spent")
	assert_eq(int(GameQuery.season_focus_yield(s).pct), 75, "GameQuery.season_focus_yield reports 75%")
	assert_eq(int(GameQuery.person_verbs(s, str(teacher.id)).focus_yield_pct), 75, "GameQuery.person_verbs reports 75%")

	# Isolate focus-tax arithmetic first (temporarily stash insight buff), then verify insight buff next season.
	var saved_buffs: Array = s.player.interaction_buffs.duplicate(true)
	assert_eq(saved_buffs.size(), 1, "insight buff recorded")
	s.player.interaction_buffs.clear()
	var tu_tax0: float = s.player.tu_vi
	s._pass_season("cultivate")
	var gain_taxed: float = s.player.tu_vi - tu_tax0
	assert_near(gain_taxed, gain_base * 0.75, 0.05, "Rule 4: 0.25 focus tax reduces next focus yield to 75%% (%.2f vs %.2f)" % [gain_taxed, gain_base])
	assert_eq(int(GameQuery.season_focus_yield(s).pct), 100, "focus yield resets to 100% next season")

	# Restore insight buff for its valid next season, verify StatSheet reflects +20%, then expires one season later.
	s.player.interaction_buffs = saved_buffs
	assert_near(s.sheet().total("cultivation_speed_pct"), speed_before + 20.0, 1e-6, "insight buff +20%% active in next season")
	s._pass_season("")
	assert_near(s.sheet().total("cultivation_speed_pct"), speed_before, 1e-6, "insight buff expires after next season")
	s_base.shutdown()
	s.shutdown()


# --- 4. Loan -> WorldTicker overdue tick -> loan_collection -> repay + MoneyLedger conservation (AC-NI-15) -----------

func test_loan_lifecycle_world_ticker_overdue_collection_repay_and_conservation_ac_ni_15() -> void:
	var s := _session()
	s.player.linh_thach = 500
	s.sync_player()
	var lender: Dictionary = _spawn_here(s, {"realm_index": 1, "attitude": 75, "met_player": true, "linh_thach": 1000})
	var ledger := MoneyLedger.new(s.db, s.player)
	ledger.open_season()

	var p0: int = s.player.linh_thach
	var l0: int = int(lender.linh_thach)
	var r_loan: Dictionary = s.interact(str(lender.id), "help", {"sub": "loan", "amount": 250})
	assert_true(bool(r_loan.ok) and bool(r_loan.accepted), "loan accepted")
	assert_eq(s.player.linh_thach, p0 + 250, "player receives 250")
	assert_eq(int(lender.linh_thach), l0 - 250, "lender purse decreases by 250")
	assert_near(float(ledger.season_check().gap), 0.0, 1e-6, "MoneyLedger gap == 0 on borrow")
	assert_eq(Array(GameQuery.person_verbs(s, str(lender.id)).open_loans).size(), 1, "GameQuery shows 1 open loan")

	# Advance 8 seasons through real _pass_season -> WorldTicker.tick() -> InteractionService.tick_world_season().
	for _i in 7:
		s._pass_season("")
		s.pending_event = {}
	assert_eq(str(InteractionService.loans_of(s.db, s.player.id, str(lender.id))[0].status), "open", "still open at season 7")
	var att_before: int = int(lender.attitude)
	s._pass_season("")
	assert_eq(str(InteractionService.loans_of(s.db, s.player.id, str(lender.id))[0].status), "overdue", "WorldTicker marks loan overdue at season 8")
	var expected_drop: int = 30 + (1 if s.season == 0 else 0)
	assert_eq(int(lender.attitude), att_before - expected_drop, "AC-NI-15: overdue drops lender attitude by 30 (plus yearly drift on year boundary)")
	assert_true(InteractionRules.npc_flags(lender).has("owes_loan_overdue"), "owes_loan_overdue flag set")

	# Trigger scheduled loan_collection event deterministically.
	s.pending_event = {}
	var ev_lines: Array = s._maybe_event(0.0)
	assert_false(ev_lines.is_empty(), "loan_collection event fires")
	assert_eq(str(s.pending_event.source), "template:loan_collection")
	s.pending_event = {}

	# Repay overdue loan directly via interact("repay") with strict MoneyLedger conservation.
	ledger.open_season()
	var p_pre_repay: int = s.player.linh_thach
	var l_pre_repay: int = int(lender.linh_thach)
	var r_repay: Dictionary = s.interact(str(lender.id), "repay")
	assert_true(bool(r_repay.ok) and bool(r_repay.accepted), "repay overdue loan succeeds")
	assert_eq(s.player.linh_thach, p_pre_repay - 250, "player pays 250")
	assert_eq(int(lender.linh_thach), l_pre_repay + 250, "lender receives 250")
	assert_near(float(ledger.season_check().gap), 0.0, 1e-6, "MoneyLedger gap == 0 on repay")
	assert_true(Array(GameQuery.person_verbs(s, str(lender.id)).open_loans).is_empty(), "no open loans remain")
	assert_false(InteractionRules.npc_flags(lender).has("owes_loan"), "owes_loan flag cleared")
	assert_false(InteractionRules.npc_flags(lender).has("owes_loan_overdue"), "owes_loan_overdue flag cleared")

	# Edge case: lender death writes off open loan without altering purses (#46 rule 13).
	var lender2: Dictionary = _spawn_here(s, {"realm_index": 1, "attitude": 75, "met_player": true, "linh_thach": 400})
	assert_true(bool(s.interact(str(lender2.id), "help", {"sub": "loan", "amount": 100}).accepted))
	var p_before_death: int = s.player.linh_thach
	s.ticker.old_age_death(lender2, s.year, s.season)
	assert_eq(str(InteractionService.loans_of(s.db, s.player.id, str(lender2.id))[0].status), "written_off", "lender death writes off loan")
	assert_eq(s.player.linh_thach, p_before_death, "player purse untouched on lender death write-off")
	s.shutdown()


# --- 5. Non-lethal foreseen rated spar + Provoke duel with mercy choice (AC-NI-17, AC-NI-19) -------------------------

func test_spar_nonlethal_rated_and_provoke_mercy_duel_ac_ni_17_19() -> void:
	var s := _session(4041, true)
	var partner: Dictionary = _spawn_here(s, {"realm_index": s.player.realm_index, "attitude": 55, "met_player": true})
	var p_vit0: float = s.player.vitality
	var n_vit0: float = float(partner.get("vitality", 1.0))

	var r_spar: Dictionary = s.interact(str(partner.id), "spar")
	assert_true(bool(r_spar.ok) and bool(r_spar.accepted), "AC-NI-17: spar accepted")
	assert_true(s.player.alive and bool(partner.alive), "AC-NI-17: non-lethal — neither dies")
	assert_near(s.season_time_used, 0.10, 1e-6, "spar spends 0.10 season focus")
	assert_eq(int(GameQuery.season_focus_yield(s).pct), 90, "focus yield drops to 90% after spar")
	var sr: Dictionary = Dictionary(r_spar.spar_result)
	assert_eq(str(sr.situation), "foreseen", "foreseen situation")
	assert_true(bool(sr.rated), "AC-NI-17: rated via RatingService")
	var expected_loss: float = (float(s.gd.session().mission.injury_khi_huyet_loss_pct) / 100.0) * float(InteractionRules.knobs(s.gd).spar_loss_share)
	if bool(sr.win):
		assert_near(n_vit0 - float(partner.vitality), expected_loss, 1e-5, "loser takes half normal vitality loss")
	else:
		assert_near(p_vit0 - s.player.vitality, expected_loss, 1e-5, "loser takes half normal vitality loss")
	assert_true(InteractionRules.npc_flags(partner).has("sparred"), "sparred flag recorded")

	# AC-NI-19: Provoke strong player vs weak rival -> foreseen duel -> win -> mercy choice -> spare -> on_talk_spared_rival!
	s.player.realm_index = 2
	s.player.level = Ladder.stage_first_level(s.gd, 2, 0)
	s.sync_player()
	var rival: Dictionary = _spawn_here(s, {"realm_index": 0, "attitude": 0, "met_player": true})
	var r_prov: Dictionary = s.interact(str(rival.id), "provoke")
	assert_true(bool(r_prov.ok) and bool(r_prov.scene_started), "AC-NI-19: provoke opens duel")
	assert_eq(str(s.pending_event.source), "template:provoke_duel")
	assert_eq(str(s.pending_event.get("situation", "")), "foreseen")
	var duel_r: Dictionary = s.choose(0)
	assert_true(bool(duel_r.ok) and s.has_pending_event(), "win opens mercy follow-up event")
	assert_eq(str(s.pending_event.source), "interaction:mercy_choice")
	assert_true(bool(s.choose(0).ok), "choose Spare")
	assert_false(s.has_pending_event())
	assert_true(bool(rival.alive), "spared rival lives")
	assert_true(InteractionRules.npc_flags(rival).has("spared_by"), "spared_by flag set")

	# Greeting a spared rival fires on_talk_spared_rival authored scene!
	rival["interact_meta"] = {}
	var r_after: Dictionary = s.interact(str(rival.id), "greet")
	assert_true(bool(r_after.ok) and bool(r_after.scene_started), "spared_by flag triggers on_talk_spared_rival")
	assert_eq(str(s.pending_event.source), "template:on_talk_spared_rival")
	s.shutdown()


# --- 6. Trait-unlocked verbs across self (haggle), other (ask_history), either (share_tea) ---------------------------

func test_trait_unlocked_verbs_self_other_either_and_game_query() -> void:
	var s := _session()
	s.player.linh_thach = 1500
	s.player.tam_ma = 25.0
	s.player.npc_traits = {"upbringing": "merchant_child", "lifestyle": "tea_master", "personality": ["calm"]}
	s.sync_player()
	var npc: Dictionary = _spawn_here(s, {
		"realm_index": 1, "attitude": 50, "met_player": true, "linh_thach": 1000,
		"npc_traits": {"personality": ["generous"], "calling": "chronicler"},
	})
	# Give NPC a spare item for haggle + trade check, and log a historical event for ask_history.
	var spare: Dictionary = s.items.material("huyen_thiet", 2)
	spare["owner_id"] = str(npc.id)
	var spare_id: String = s.db.add("items", spare)
	s.db.log_event(105, 0, "history", "Đại chiến cổ tông diễn ra tại vùng này.", [str(npc.id)], [s.player.location_id], [])

	var pv: Dictionary = GameQuery.person_verbs(s, str(npc.id))
	var v_haggle: Dictionary = _find_verb(pv, "haggle")
	var v_hist: Dictionary = _find_verb(pv, "ask_history")
	var v_tea: Dictionary = _find_verb(pv, "share_tea")
	assert_false(v_haggle.is_empty(), "self trait verb 'haggle' exposed via GameQuery")
	assert_eq(str(v_haggle.side), "self")
	assert_eq(str(v_haggle.source_trait), "merchant_child")
	assert_false(v_hist.is_empty(), "other trait verb 'ask_history' exposed via GameQuery")
	assert_eq(str(v_hist.side), "other")
	assert_eq(str(v_hist.source_trait), "chronicler")
	assert_false(v_tea.is_empty(), "either trait verb 'share_tea' exposed via GameQuery")
	assert_eq(str(v_tea.side), "either")
	assert_eq(str(v_tea.source_trait), "tea_master")

	# Execute haggle -> verify trade buy price drops and stays > sell price (zero arbitrage) + MoneyLedger conservation.
	var base_buy: int = s.market.buy_price(s.player, s.sheet(), spare, s.player.location_id)
	var base_sell: int = s.market.sell_price(s.player, s.sheet(), spare, s.player.location_id)
	var rh: Dictionary = s.interact(str(npc.id), "haggle")
	assert_true(bool(rh.ok) and bool(rh.accepted), "haggle accepted")
	var hp: Dictionary = InteractionRules.haggle_prices(s.gd, base_buy, base_sell, true)
	assert_true(int(hp.buy) <= base_buy and int(hp.buy) > int(hp.sell), "haggle discounts buy without arbitrage (buy %d > sell %d)" % [int(hp.buy), int(hp.sell)])

	var ledger := MoneyLedger.new(s.db, s.player)
	ledger.open_season()
	var rt: Dictionary = s.interact(str(npc.id), "trade", {"trade_action": "buy", "item_id": spare_id})
	assert_true(bool(rt.ok) and bool(rt.accepted), "haggled trade buy succeeds")
	assert_eq(int(rt.price), int(hp.buy), "trade buy applied haggled price")
	assert_near(float(ledger.season_check().gap), 0.0, 1e-6, "MoneyLedger gap == 0 on haggled trade")

	# Next season: execute other-side ask_history and either-side share_tea.
	s._pass_season("")
	var r_hist: Dictionary = s.interact(str(npc.id), "ask_history")
	assert_true(bool(r_hist.ok) and bool(r_hist.accepted) and not bool(r_hist.get("nothing_new", false)), "ask_history reveals historical lore")
	var tm0: float = s.player.tam_ma
	var att0: int = int(npc.attitude)
	var r_tea: Dictionary = s.interact(str(npc.id), "share_tea")
	assert_true(bool(r_tea.ok) and bool(r_tea.accepted), "share_tea succeeds")
	assert_true(s.player.tam_ma < tm0, "share_tea reduces tâm ma")
	assert_true(int(npc.attitude) > att0, "share_tea raises attitude")
	s.shutdown()


# --- 7. Bond formation lifecycle (companion, disciple, brotherhood, dao_lu) through GameQuery + GameSession ----------

func test_bond_formation_lifecycle_companion_disciple_brotherhood_dao_lu() -> void:
	var s := _session()
	s.player.realm_index = 2   # Kết Đan (notable + above Trúc Cơ disciple target)
	s.player.level = Ladder.stage_first_level(s.gd, 2, 0)
	s.sync_player()
	var ally: Dictionary = _spawn_here(s, {"realm_index": 1, "attitude": 20, "met_player": true, "npc_traits": {"personality": ["loyal", "humble"]}})

	# At attitude 20 (warm): companion, brotherhood, dao_lu are shown greyed with clear requirement reasons!
	var pv_warm: Dictionary = GameQuery.person_verbs(s, str(ally.id))
	var v_comp_w: Dictionary = _find_verb(pv_warm, "companion")
	var v_bro_w: Dictionary = _find_verb(pv_warm, "brotherhood")
	var v_dl_w: Dictionary = _find_verb(pv_warm, "dao_lu")
	assert_true(bool(v_comp_w.get("greyed", false)) and str(v_comp_w.get("grey_reason", "")).contains("friendly"), "companion greyed below friendly")
	assert_true(bool(v_bro_w.get("greyed", false)) and str(v_bro_w.get("grey_reason", "")).contains("friendly"), "brotherhood greyed below friendly")
	assert_true(bool(v_dl_w.get("greyed", false)) and str(v_dl_w.get("grey_reason", "")).contains("close"), "dao_lu greyed below close")

	# Raise attitude to 85 (close): all 4 bonds become ungreyed and succeed across seasons!
	ally["attitude"] = 85
	var pv_close: Dictionary = GameQuery.person_verbs(s, str(ally.id))
	for bid in ["companion", "disciple", "brotherhood", "dao_lu"]:
		var vb: Dictionary = _find_verb(pv_close, bid)
		assert_false(vb.is_empty(), "bond verb %s visible at close attitude" % bid)
		assert_false(bool(vb.get("greyed", true)), "bond verb %s not greyed when requirements met" % bid)
		assert_true(bool(vb.get("will_accept", false)), "bond verb %s will accept at attitude 85" % bid)

	assert_true(bool(s.interact(str(ally.id), "companion").accepted), "companion formed")
	assert_true(bool(s.interact(str(ally.id), "disciple").accepted), "disciple formed")
	s._pass_season("")
	assert_true(bool(s.interact(str(ally.id), "brotherhood").accepted), "brotherhood formed")
	assert_true(bool(s.interact(str(ally.id), "dao_lu").accepted), "dao_lu formed")

	assert_true(Ties.has_pin(s.db, s.player.id, str(ally.id), "companion"), "companion pin stored")
	assert_eq(Ties.master_of(s.db, str(ally.id)), s.player.id, "su_do master stored")
	assert_true(Ties.has_pin(s.db, s.player.id, str(ally.id), "ket_nghia"), "ket_nghia pin stored")
	assert_true(Ties.has_pin(s.db, s.player.id, str(ally.id), "dao_lu"), "dao_lu pin stored")

	# After forming disciple and dao_lu, GameQuery greys them with living-master / living-dao-lu reasons.
	s._pass_season("")
	var pv_after: Dictionary = GameQuery.person_verbs(s, str(ally.id))
	var v_disc_after: Dictionary = _find_verb(pv_after, "disciple")
	var v_dl_after: Dictionary = _find_verb(pv_after, "dao_lu")
	assert_true(bool(v_disc_after.get("greyed", false)) and str(v_disc_after.get("grey_reason", "")).to_lower().contains("master"), "disciple greys once target has living master")
	assert_true(bool(v_dl_after.get("greyed", false)) and str(v_dl_after.get("grey_reason", "")).to_lower().contains("dao companion"), "dao_lu greys once living dao_lu exists")
	s.shutdown()


# --- 8. Save/Load JSON round-trip + backwards-compatible load of older saves missing #30 keys ------------------------

func test_save_load_preserves_loans_flags_cooldowns_focus_tax_and_buffs_and_loads_old_saves() -> void:
	var s := _session()
	s.player.linh_thach = 1000
	s.player.npc_traits = {"upbringing": "merchant_child", "personality": ["calm"]}
	s.sync_player()
	var elder: Dictionary = _spawn_here(s, {"realm_index": s.player.realm_index + 1, "attitude": 80, "met_player": true, "linh_thach": 800})
	s.player.active_visits.append({"quest_id": "q_save_visit", "npc_id": str(elder.id), "completed": false})

	# Execute teach (sets taught flag, cooldown, season_time_used=0.25, interaction_buffs) + loan (sets w_loans, owes_loan, cooldown).
	assert_true(bool(s.interact(str(elder.id), "teach", {"lesson": "insight"}).accepted), "teach ok")
	assert_true(bool(s.interact(str(elder.id), "help", {"sub": "loan", "amount": 80}).accepted), "loan ok")

	var pv_before: Dictionary = GameQuery.person_verbs(s, str(elder.id))
	var teach_cd_before: int = int(_find_verb(pv_before, "teach").get("cooldown_left", 0))
	var help_cd_before: int = int(_find_verb(pv_before, "help").get("cooldown_left", 0))
	assert_true(teach_cd_before > 0 and help_cd_before > 0, "cooldowns active before save")

	# Full JSON stringify -> parse -> load_dict round-trip.
	var json_blob: String = JSON.stringify(s.to_dict())
	var parsed: Dictionary = JSON.parse_string(json_blob)
	var s2 := _session()
	var lr: Dictionary = s2.load_dict(parsed)
	assert_true(bool(lr.ok), "JSON round-trip load_dict ok")

	assert_near(s2.season_time_used, 0.25, 1e-6, "season_time_used preserved")
	assert_eq(int(GameQuery.season_focus_yield(s2).pct), 75, "focus yield 75% preserved")
	assert_eq(s2.player.interaction_buffs.size(), 1, "interaction_buffs preserved")
	assert_eq(s2.player.active_visits.size(), 1, "active_visits preserved")
	assert_eq(InteractionService.loans_of(s2.db, s2.player.id, str(elder.id)).size(), 1, "w_loans preserved")

	var elder2: Dictionary = s2.db.get_record("people", str(elder.id))
	var flags2: Dictionary = InteractionRules.npc_flags(elder2)
	assert_true(flags2.has("taught") and flags2.has("owes_loan"), "NPC flags preserved")
	var pv_after: Dictionary = GameQuery.person_verbs(s2, str(elder.id))
	assert_eq(int(_find_verb(pv_after, "teach").get("cooldown_left", 0)), teach_cd_before, "teach cooldown preserved")
	assert_eq(int(_find_verb(pv_after, "help").get("cooldown_left", 0)), help_cd_before, "help cooldown preserved")
	assert_eq(int(pv_after.interactions_used), 2, "per-season interaction count preserved")
	assert_eq(Array(pv_after.open_loans).size(), 1, "GameQuery open_loans preserved")

	# Older pre-Dialogue-#30 save missing every new key must load cleanly with safe defaults!
	var legacy: Dictionary = JSON.parse_string(json_blob)
	legacy.erase("season_time_used")
	if legacy.has("db") and legacy.db.has("tables"):
		var tables: Dictionary = legacy.db.tables
		if tables.has("world"):
			(tables.world as Dictionary).erase(InteractionService.LOANS_REC)
			(tables.world as Dictionary).erase(InteractionService.FOLLOWUPS_REC)
		if tables.has("people"):
			for pid in (tables.people as Dictionary).keys():
				var prec: Dictionary = tables.people[pid]
				for k in ["season_time_used", "interaction_buffs", "heart_demon_used", "active_visits", "interaction_flags", "flags", "interact_meta"]:
					prec.erase(k)

	var s3 := _session()
	var lr_old: Dictionary = s3.load_dict(legacy)
	assert_true(bool(lr_old.ok), "legacy save missing all #30 keys loads cleanly")
	assert_near(s3.season_time_used, 0.0, 1e-6, "legacy default season_time_used == 0.0")
	assert_eq(s3.player.interaction_buffs, [], "legacy default interaction_buffs == []")
	assert_eq(s3.player.active_visits, [], "legacy default active_visits == []")
	assert_near(s3.player.heart_demon_used, 0.0, 1e-6, "legacy default heart_demon_used == 0.0")
	assert_eq(InteractionService.loans_of(s3.db, s3.player.id).size(), 0, "legacy default loans == []")

	# GameQuery and live interaction work immediately on the migrated legacy save!
	var pv_old: Dictionary = GameQuery.person_verbs(s3, str(elder.id))
	assert_eq(int(pv_old.interactions_used), 0, "legacy NPC starts with 0 interactions used")
	assert_eq(int(pv_old.focus_yield_pct), 100, "legacy save starts with 100% focus yield")
	var r_old_greet: Dictionary = s3.interact(str(elder.id), "greet")
	assert_true(bool(r_old_greet.ok) and bool(r_old_greet.accepted), "interact works cleanly on legacy save")
	s.shutdown()
	s2.shutdown()
	s3.shutdown()
