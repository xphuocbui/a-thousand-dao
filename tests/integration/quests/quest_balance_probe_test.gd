extends DaoTestSuite
## Wave 3 deterministic balance probes for Template Quests (#31):
## - AC-QS-75 (Provisional): fixed-seed board farming sold value vs sect mission income I_r.
## - AC-QS-139: 2,000-year life taking 1 person/sect quest per 8 seasons -> ~20 Legendary,
##   ~100 Major+Legendary (±30%), lifetime lasting gain <= 48 W, above-cap items bounded.

const _QuestRules := preload("res://src/gameplay/quests/quest_rules.gd")
const _QuestGenerator := preload("res://src/gameplay/quests/quest_generator.gd")


func _session(seed_v: int = 8101) -> GameSession:
	var gd := game_data()
	var llm := LlmService.new(gd)
	llm.enabled = false
	var s := GameSession.new(gd, llm, TestFixtures.tree())
	s.ratings_background = false
	s.new_game(seed_v, {"mode": "custom", "name": "Hành Giả", "gender": "male", "origin": "tan_tu", "thien_phu": {}, "purities": {"kim": 75, "hoa": 45}, "variants": [], "edge": false})
	s.pending_event = {}
	s.pending_meta = {}
	s.pending_mercy = {}
	return s


func _find_board_place(s: GameSession) -> String:
	for p in s.db.all("places"):
		if bool(p.get("market", false)) and s.quest_board.has_board(str(p.id)):
			return str(p.id)
	for p in s.db.all("places"):
		if s.quest_board.has_board(str(p.id)):
			return str(p.id)
	return s.player.location_id


func _complete_board_quest_fast(s: GameSession, q: Dictionary) -> int:
	var qid: String = str(q.get("id", ""))
	var seasons_used: int = 0
	var guard: int = 0
	while guard < 12:
		guard += 1
		var live: Dictionary = s.quests.get_quest(qid)
		if live.is_empty() or not (str(live.get("state", "")) in ["active", "orphaned"]):
			break
		var plan_q: Dictionary = Dictionary(live.get("plan", live))
		var stages: Array = Array(plan_q.get("stages", live.get("stages", [])))
		var st_idx: int = clampi(int(live.get("stage", 1)) - 1, 0, maxi(0, stages.size() - 1))
		if stages.is_empty():
			break
		var st: Dictionary = Dictionary(stages[st_idx])
		var kind: String = str(st.get("kind", ""))
		match kind:
			"mission":
				var mr: Dictionary = s.quests.run_mission_stage(s.player, qid, s.year, s.season, {"season_idx": s.season_index()})
				if not bool(mr.get("ok", false)):
					break
				seasons_used += 1
				s.season += 1
				if s.season >= 4:
					s.season = 0
					s.year += 1
			"visit":
				var target_id: String = str(st.get("target_id", ""))
				if target_id != "":
					s.quests.on_greet_npc(s.player, target_id, s.year, s.season, {"season_idx": s.season_index()})
				else:
					var pl_id: String = str(st.get("place_id", s.player.location_id))
					s.quests.on_arrive_place(s.player, pl_id, s.year, s.season, {"season_idx": s.season_index()})
			"event":
				var er: Dictionary = s.quests.trigger_stage_event(s.player, s.sheet(), s.rng, qid, {
					"event_result": true,
					"year": s.year,
					"season": s.season,
					"season_idx": s.season_index(),
				})
				if not bool(er.get("ok", false)):
					break
				seasons_used += 1
				s.season += 1
				if s.season >= 4:
					s.season = 0
					s.year += 1
			"deliver":
				var ic: String = str(st.get("item_class", "herb"))
				var dprice: int = maxi(1, int(st.get("deliver_price", 5)))
				if ic == "linh_thach":
					if s.player.linh_thach < dprice:
						break
					var dr0: Dictionary = s.quests.submit_deliver(s.player, qid, "", s.year, s.season, {"season_idx": s.season_index(), "ignore_place": true})
					if not bool(dr0.get("ok", false)):
						break
				else:
					var stub: Dictionary = s.items.herb("hoang_tinh_sam", 5.0)
					stub["kind"] = ic
					stub["quality"] = int(st.get("quality_min", 0))
					stub["qty"] = maxi(1, int(st.get("qty", 1)))
					stub["owner_id"] = s.player.id
					var sid: String = s.db.add("items", stub)
					var dr1: Dictionary = s.quests.submit_deliver(s.player, qid, sid, s.year, s.season, {"season_idx": s.season_index(), "ignore_place": true})
					if not bool(dr1.get("ok", false)):
						break
				seasons_used += 1
				s.season += 1
				if s.season >= 4:
					s.season = 0
					s.year += 1
			"craft":
				var ic2: String = str(st.get("item_class", "pill"))
				var stub2: Dictionary = s.items.pill("hoi_linh_dan", int(st.get("quality_min", 0)), maxi(1, int(st.get("qty", 1))))
				stub2["kind"] = ic2
				stub2["owner_id"] = s.player.id
				var cid: String = s.db.add("items", stub2)
				s.quests.on_item_crafted(s.player, cid, s.season_index())
				s.quests.on_season_end(s.player, s.sheet(), s.year, s.season, {"season_idx": s.season_index()})
				seasons_used += 1
				s.season += 1
				if s.season >= 4:
					s.season = 0
					s.year += 1
			"defeat":
				var dfr: Dictionary = s.quests.run_defeat_stage(s.player, s.sheet(), s.rng, qid, func(_q, _st, _p): return "knockout", {
					"year": s.year,
					"season": s.season,
					"season_idx": s.season_index(),
					"force_open": true,
				})
				if not bool(dfr.get("ok", false)):
					break
				seasons_used += 1
				s.season += 1
				if s.season >= 4:
					s.season = 0
					s.year += 1
			_:
				break
	return seasons_used


func test_board_farming_sold_value_vs_sect_mission_income_ac_qs_75() -> void:
	var s := _session(8101)
	var board_place: String = _find_board_place(s)
	assert_true(s.quest_board.has_board(board_place), "found a town/sect with a standing board")
	s.player.location_id = board_place
	s.player.realm_index = 0
	s.sync_player()
	var ledger: MoneyLedger = MoneyLedger.new(s.db, s.player) if s.db.count(WorldEconomy.TABLE) > 0 else null
	if ledger != null:
		ledger.open_season()

	var i_r: float = float(_QuestRules.realm_income_Ir(s.gd, 0))
	var start_stones: int = s.player.linh_thach
	var total_seasons_spent: int = 0
	var completed_count: int = 0
	var total_budget_paid: int = 0

	# Deterministically farm standing board quests across 24 seasonal board refreshes.
	var fact_kinds: Array[String] = ["shortage", "trade", "war", "duel", "grudge"]
	for cycle in range(24):
		# Seed a fresh local world fact at the board place so board generation always has live world activity.
		var fk: String = fact_kinds[cycle % fact_kinds.size()]
		s.db.log_event(s.year, s.season, fk, "Biến cố địa phương #%d tại bảng ủy thác." % cycle, [], [board_place], [], {"cycle": cycle})
		var offers: Array = s.quest_board.refresh_place(board_place, s.player, s.sheet(), 8101, s.season_index())
		if offers.is_empty():
			s.season += 1
			if s.season >= 4:
				s.season = 0
				s.year += 1
			continue
		var pick: Dictionary = Dictionary(offers[0])
		var qid: String = str(pick.get("id", ""))
		var acc: Dictionary = s.quest_accept(qid)
		if not bool(acc.ok):
			s.season += 1
			if s.season >= 4:
				s.season = 0
				s.year += 1
			continue
		var items_before: Dictionary = {}
		for it in s.db.items_of(s.player.id):
			items_before[str(it.id)] = true
		var spent: int = _complete_board_quest_fast(s, pick)
		var final_q: Dictionary = s.quests.get_quest(qid)
		if str(final_q.get("state", "")) == "completed":
			completed_count += 1
			var s_plan: int = int(Dictionary(final_q.get("budget", {})).get("S_plan", 0))
			var travel_s: int = int(Dictionary(pick.get("plan", pick)).get("travel_seasons", pick.get("travel_seasons", 0)))
			total_seasons_spent += maxi(1, maxi(spent + travel_s, s_plan))
			total_budget_paid += int(final_q.get("paid_total", 0))
			# Sell every newly awarded item at the local market to measure sold value.
			for it in s.db.items_of(s.player.id):
				var iid: String = str(it.id)
				if not items_before.has(iid) and not s.player.equipped.has(iid):
					s.sell(iid)
		else:
			s.quest_abandon(qid)

	assert_true(completed_count >= 5, "completed at least 5 board quests in fixed-seed probe (got %d)" % completed_count)
	assert_true(total_seasons_spent > 0, "spent positive seasons farming board")
	var paid_per_season: float = float(total_budget_paid) / float(total_seasons_spent)
	var sold_per_season: float = float(s.player.linh_thach - start_stones) / float(total_seasons_spent)
	# Formula A errand/ordinary board quests pay 1.25x..1.5x I_r in nominal budget, and selling items at market
	# yields a net rate bounded safely near I_r without exploiting past 1.6x I_r (AC-QS-75 provisional check).
	assert_true(paid_per_season <= 1.6 * i_r, "nominal board payout/season %.2f stays bounded vs I_r %.1f" % [paid_per_season, i_r])
	assert_true(sold_per_season <= 1.6 * i_r, "sold board farming/season %.2f stays bounded vs I_r %.1f" % [sold_per_season, i_r])
	assert_true(sold_per_season >= 0.0, "sold board farming is non-negative (%.2f)" % sold_per_season)
	if ledger != null:
		assert_near(float(ledger.season_check().gap), 0.0, 0.5, "MoneyLedger conserved across board farming")
	s.shutdown()


func test_lifetime_2000_year_tier_mix_and_lasting_gain_cap_ac_qs_139() -> void:
	var s := _session(8102)
	# Core Formation+ so Legendary is eligible across the 2,000-year life probe (8,000 seasons, 1 offer / 8 seasons = 1,000 offers).
	s.player.realm_index = 2
	var cfg: Dictionary = _QuestRules.config(s.gd)
	var gain_cap_w: float = float(cfg.get("quest_gain_cap_w", 48.0))
	var boon_w: float = float(cfg.get("quest_boon_w", 8.0))

	var counts := {"errand": 0, "ordinary": 0, "major": 0, "legendary": 0}
	var above_cap_items_awarded: int = 0
	var boons_granted: int = 0
	var total_offers: int = 1000   # 2,000 years * 4 seasons/yr / 8 seasons per offer

	for idx in range(total_offers):
		var season_idx: int = idx * 8
		var r: RandomNumberGenerator = _QuestGenerator.offer_rng(8102, s.player.id, season_idx, 0, "life_139")
		var tier: String = _QuestGenerator.draw_tier(s.gd, r, s.player.realm_index, ["errand", "ordinary", "major", "legendary"], "person")
		counts[tier] = int(counts.get(tier, 0)) + 1

		# Simulate completing Major/Legendary rare rewards through QuestRules.lasting_gain_room clamp.
		if tier == "major" or tier == "legendary":
			var room: Dictionary = _QuestRules.lasting_gain_room(s.gd, float(s.player.quest_gain_total_w), int(s.player.quest_tree_points_used))
			var granted_w: float = minf(boon_w, float(room.get("allowed_w", 0.0)))
			if granted_w > 0.0:
				s.player.quest_gain_total_w += granted_w
				s.player.quest_boons.append({"quest_id": "q_life_%d" % idx, "w": granted_w, "mods": [{"stat": "cultivation_speed_pct", "value": granted_w}]})
				boons_granted += 1
		if tier == "legendary":
			above_cap_items_awarded += 1

	var leg_n: int = int(counts["legendary"])
	var maj_plus_leg: int = int(counts["major"]) + leg_n
	# AC-QS-139 targets: ~20 Legendary (2% of 1,000) and ~100 Major+Legendary (10% of 1,000), within ±30%.
	assert_true(leg_n >= 14 and leg_n <= 26, "AC-QS-139: Legendary count %d within 20 ±30%% [14..26]" % leg_n)
	assert_true(maj_plus_leg >= 70 and maj_plus_leg <= 130, "AC-QS-139: Major+Legendary count %d within 100 ±30%% [70..130]" % maj_plus_leg)
	assert_true(s.player.quest_gain_total_w <= gain_cap_w + 1e-6, "AC-QS-139: lifetime quest_gain_total_w %.2f <= cap %.2f" % [s.player.quest_gain_total_w, gain_cap_w])
	assert_near(s.player.quest_gain_total_w, gain_cap_w, 1e-6, "lifetime lasting gain saturates cleanly at 48 W")
	assert_true(boons_granted > 0 and above_cap_items_awarded == leg_n, "boons granted (%d) and above-cap items tracked (%d)" % [boons_granted, above_cap_items_awarded])
	s.shutdown()
