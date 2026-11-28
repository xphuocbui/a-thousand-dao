extends DaoTestSuite
## Deterministic unit tests for Template Quests (#31) Wave 2 W2B — QuestService world outcomes,
## Formula E reactions, hostility rules, immediate knockout death, stage-1 abandon/player-death immunity,
## board zero-attitude rules, offer summary, and MoneyLedger conservation.
## Covers AC-QS-105, 115..117, 120..123, 128..130, 134, 140..141, 145.

const _QuestService := preload("res://src/gameplay/quests/quest_service.gd")
const _QuestBoard := preload("res://src/gameplay/quests/quest_board.gd")


func _world() -> Dictionary:
	var gd: GameData = game_data()
	var db := WorldDB.new()
	var pl1: String = db.add("places", {
		"name": "Thanh Vân Thành", "kind": "city", "type": "thanh", "region_id": "r1",
		"bounties": true, "density": 1.0, "links": []
	})
	var pl2: String = db.add("places", {
		"name": "Hàn Phong Cốc", "kind": "gorge", "type": "coc", "region_id": "r1",
		"bounties": false, "density": 1.2, "links": []
	})
	db.get_record("places", pl1)["links"] = [{"to": pl2, "seasons": 1.0}]
	db.get_record("places", pl2)["links"] = [{"to": pl1, "seasons": 1.0}]

	var player := TestFixtures.character({"hoa": 60.0}, 50, 0, 0)
	player.name = "Lâm Thanh"
	player.is_player = true
	player.location_id = pl1
	player.linh_thach = 500
	var pid: String = db.add("people", player.to_dict())
	player.id = pid

	var sect_id: String = db.add("sects", {
		"name": "Thanh Vân Tông", "status": "active", "hq_place_id": pl1,
		"leader_id": "", "members": [], "treasury": 50000.0
	})
	db.get_record("places", pl1)["holder"] = sect_id

	var head_id: String = _add_npc(db, "Vân Tông Chủ", pl1, sect_id, "tong_chu", 2, 0, "", 5000)
	db.get_record("sects", sect_id)["leader_id"] = head_id
	var master_id: String = _add_npc(db, "Trần Trưởng Lão", pl1, sect_id, "truong_lao", 1, 0, "", 1000)
	var offerer_id: String = _add_npc(db, "Lý Chấp Sự", pl1, sect_id, "noi_mon", 0, 0, master_id, 1000)
	var disc1_id: String = _add_npc(db, "Đệ Tử Nhất", pl1, sect_id, "ngoai_mon", 0, 0, offerer_id, 500)
	var disc2_id: String = _add_npc(db, "Đệ Tử Nhị", pl1, sect_id, "ngoai_mon", 0, 0, offerer_id, 500)
	var disc3_id: String = _add_npc(db, "Đệ Tử Tam", pl1, sect_id, "ngoai_mon", 0, 0, offerer_id, 500)
	db.get_record("sects", sect_id)["members"] = [head_id, master_id, offerer_id, disc1_id, disc2_id, disc3_id]

	var rival_sect_id: String = db.add("sects", {
		"name": "Huyết Sát Môn", "status": "active", "hq_place_id": pl2,
		"leader_id": "", "members": [], "treasury": 40000.0
	})
	var adv_head_id: String = _add_npc(db, "Huyết Môn Chủ", pl2, rival_sect_id, "tong_chu", 2, 0, "", 4000)
	db.get_record("sects", rival_sect_id)["leader_id"] = adv_head_id
	var adv_master_id: String = _add_npc(db, "Huyết Sư Phụ", pl2, rival_sect_id, "truong_lao", 2, 0, "", 2000)
	var adv_id: String = _add_npc(db, "Huyết Đồ", pl2, rival_sect_id, "noi_mon", 1, 0, adv_master_id, 1500)
	db.get_record("sects", rival_sect_id)["members"] = [adv_head_id, adv_master_id, adv_id]

	var fact_id: String = db.log_event(
		100, 0, "grudge", "Huyết Đồ gây hấn với Lý Chấp Sự.",
		[offerer_id, adv_id], [pl1, pl2], [], {"adversary_id": adv_id}
	)
	var fact: Dictionary = db.get_record("events", fact_id)
	var sheet := StatSheet.build(player, gd, db, TestFixtures.tree())
	var items := ItemFactory.new(gd)
	var board := _QuestBoard.new(gd, db, null)
	var svc := _QuestService.new(gd, db, null, items, null, board)
	var money := MoneyLedger.new(db, player)
	money.open_season()
	return {
		"gd": gd, "db": db, "player": player, "sheet": sheet,
		"items": items, "board": board, "svc": svc, "money": money,
		"pl1": pl1, "pl2": pl2,
		"sect_id": sect_id, "head_id": head_id, "master_id": master_id,
		"offerer_id": offerer_id, "disc1_id": disc1_id, "disc2_id": disc2_id, "disc3_id": disc3_id,
		"rival_sect_id": rival_sect_id, "adv_head_id": adv_head_id,
		"adv_master_id": adv_master_id, "adv_id": adv_id,
		"fact_id": fact_id, "fact": fact,
	}


func _add_npc(
	db: WorldDB,
	npc_name: String,
	place_id: String,
	sect_id: String,
	sect_rank: String,
	realm_idx: int,
	attitude: int,
	master_id: String = "",
	cash: int = 500
) -> String:
	var c := TestFixtures.character({"moc": 50.0}, 50, realm_idx, 0)
	c.name = npc_name
	c.location_id = place_id
	c.sect_id = sect_id
	c.sect_rank = sect_rank
	c.attitude = attitude
	c.master_id = master_id
	c.linh_thach = cash
	return db.add("people", c.to_dict())


func _make_quest(w: Dictionary, qid: String, overrides: Dictionary = {}) -> Dictionary:
	var plan := {
		"template_id": "fx_oc",
		"name": "Ủy thác thế sự",
		"tier": str(overrides.get("tier", "ordinary")),
		"realm_index": int(overrides.get("realm_index", w.player.realm_index)),
		"offer_kind": str(overrides.get("offer_kind", "person")),
		"offerer_id": str(overrides.get("offerer_id", w.offerer_id)),
		"offerer_root_id": str(overrides.get("offerer_root_id", w.offerer_id)),
		"offerer_sect_id": str(overrides.get("offerer_sect_id", w.sect_id)),
		"adversary_id": str(overrides.get("adversary_id", "")),
		"adversary_root_id": str(overrides.get("adversary_root_id", overrides.get("adversary_id", ""))),
		"place_id": w.pl1,
		"source_fact": w.fact,
		"travel_seasons": 0,
		"stages": overrides.get("stages", [
			{"kind": "event", "window": 2, "place_id": w.pl1, "rewards": [{"type": "linh_thach", "amount": 4}]},
			{"kind": "craft", "window": 3, "place_id": w.pl1, "rewards": [{"type": "linh_thach", "amount": 9}]},
			{"kind": "event", "window": 2, "place_id": w.pl1, "rewards": [{"type": "linh_thach", "amount": 47}]},
		]),
		"outcomes": overrides.get("outcomes", [
			{"on": "completed", "role": "offerer", "effect": "wealth", "amount": 30},
			{"on": "failed", "role": "offerer", "effect": "wealth", "amount": -20},
		]),
	}
	var q := {
		"id": qid,
		"template_id": str(plan.template_id),
		"name": str(plan.name),
		"tier": str(plan.tier),
		"realm_index": int(plan.realm_index),
		"offer_kind": str(plan.offer_kind),
		"offerer_id": str(plan.offerer_id),
		"offerer_root_id": str(plan.offerer_root_id),
		"offerer_sect_id": str(plan.offerer_sect_id),
		"adversary_id": str(plan.adversary_id),
		"adversary_root_id": str(plan.adversary_root_id),
		"place_id": w.pl1,
		"source_fact_id": str(overrides.get("source_fact_id", w.fact_id)),
		"source_fact": w.fact.duplicate(true),
		"plan": plan,
		"outcomes": Array(plan.outcomes).duplicate(true),
		"state": "offered",
		"stage": 1,
		"offered_season": 0,
		"player_id": w.player.id,
	}
	w.svc.put_quest(q)
	return q


# --- AC-QS-105, 115, 116, 117, 128: Post-accept hostility, outcomes gating, ending log chaining, offer summary ---

func test_ac_qs_105_115_116_117_128_hostility_outcomes_log_and_summary() -> void:
	var w: Dictionary = _world()
	_make_quest(w, "q_105", {
		"outcomes": [
			{"on": "completed", "role": "offerer", "effect": "wealth", "amount_share": 0.50},
			{"on": "failed", "role": "offerer", "effect": "wealth", "amount": -20},
		]
	})
	# AC-QS-128: offer summary shows each resolved outcome with ending, role, effect, and amount.
	var q_off: Dictionary = w.svc.get_quest("q_105")
	q_off["budget"] = {"B": 60, "stage_pays": [4, 9, 47]}
	var sum: Dictionary = w.svc.offer_summary(w.player, q_off)
	assert_eq(Array(sum.outcomes).size(), 2, "AC-QS-128 both resolved outcomes listed")
	assert_eq(str(sum.outcomes[0].on), "completed", "AC-QS-128 ending field")
	assert_eq(str(sum.outcomes[0].role), "offerer", "AC-QS-128 role field")
	assert_eq(int(sum.outcomes[0].amount), 30, "AC-QS-128 amount_share 0.5 * 60 = 30")

	# AC-QS-105: attitude falling to -50 after acceptance leaves quest Active.
	w.svc.accept(w.player, "q_105", 0)
	w.db.get_record("people", w.offerer_id)["attitude"] = -50
	w.svc.tick_season(w.player, w.sheet, 0, 1, {"season_idx": 1})
	assert_eq(str(w.svc.get_quest("q_105").state), "active", "AC-QS-105 attitude -50 after accept stays Active")

	# AC-QS-115: completed outcomes apply on Completed (skipping dead), apply on finished Orphaned, and Dropped/Declined/Withdrawn apply none.
	var q_cur: Dictionary = w.svc.get_quest("q_105")
	q_cur["stage"] = 3
	w.svc.put_quest(q_cur)
	var off_cash0: float = float(w.db.get_record("people", w.offerer_id).linh_thach)
	var comp: Dictionary = w.svc.trigger_stage_event(w.player, w.sheet, RandomNumberGenerator.new(), "q_105", {"season_idx": 2})
	assert_eq(str(comp.state), "completed", "completed")
	assert_eq(int(w.db.get_record("people", w.offerer_id).linh_thach), int(off_cash0 - 47 + 30), "AC-QS-115/120 offerer wealth +30 applied (-47 reward paid)")
	assert_near(float(w.money.season_check().gap), 0.0, 1e-6, "MoneyLedger gap == 0 after wealth outcome")

	# AC-QS-116: ending logged event names people involved and can source a later offer!
	var end_ev: Dictionary = w.db.get_record("events", str(comp.event_id))
	assert_true(Array(end_ev.people).has(w.offerer_id), "AC-QS-116 ending event names offerer")
	w.db.get_record("people", w.offerer_id)["attitude"] = 0
	var chained_offer: Dictionary = w.svc.offer_from_person(w.player, w.sheet, w.offerer_id, w.pl1, 777, 10, {"source_fact": end_ev})
	assert_true(bool(chained_offer.ok), "AC-QS-116 ending event can source a later offer")

	# AC-QS-117: a tie turned hostile makes NO quest offer to the player.
	w.db.get_record("people", w.adv_master_id)["attitude"] = -30
	var adv_fact: String = w.db.log_event(101, 0, "trade", "Sự việc của Huyết Sư Phụ", [w.adv_master_id], [w.pl2], [], {})
	var host_offer: Dictionary = w.svc.offer_from_person(w.player, w.sheet, w.adv_master_id, w.pl2, 888, 12, {
		"source_fact": w.db.get_record("events", adv_fact)
	})
	assert_false(bool(host_offer.ok), "AC-QS-117 hostile tie (-30) makes no offer")

	# AC-QS-115: Dropped, Declined, Withdrawn apply zero outcomes; dead NPC skipped on finished Orphaned.
	var w2: Dictionary = _world()
	_make_quest(w2, "q_decl")
	var c0: float = float(w2.db.get_record("people", w2.offerer_id).linh_thach)
	w2.svc.decline("q_decl", 1)
	assert_eq(float(w2.db.get_record("people", w2.offerer_id).linh_thach), c0, "AC-QS-115 Declined applies no outcomes")

	_make_quest(w2, "q_orph_dead", {
		"outcomes": [
			{"on": "completed", "role": "offerer", "effect": "wealth", "amount": 30},
			{"on": "completed", "role": "offerer_sect", "effect": "standing", "amount": 5},
		]
	})
	w2.svc.accept(w2.player, "q_orph_dead", 0)
	w2.db.get_record("people", w2.offerer_id)["alive"] = false
	w2.db.get_record("people", w2.offerer_id)["estate_at_death"] = 500.0
	w2.svc.tick_season(w2.player, w2.sheet, 0, 1, {"season_idx": 1})
	var dead_cash_before: float = float(w2.db.get_record("people", w2.offerer_id).linh_thach)
	var fin_od: Dictionary = w2.svc.trigger_stage_event(w2.player, w2.sheet, RandomNumberGenerator.new(), "q_orph_dead", {"season_idx": 2})
	assert_eq(str(fin_od.state), "completed", "orphaned completed")
	# Dead offerer skipped for wealth gain; sect standing +5 still applied!
	assert_eq(Array(fin_od.outcomes).filter(func(o): return str(o.effect) == "wealth").size(), 0, "AC-QS-115 dead NPC skipped for completed wealth outcome")
	assert_true(SectMembers.new(w2.gd, w2.db).standing(w2.sect_id, w2.player.id) > 0.0, "AC-QS-115 living sect standing applied on finished Orphaned")
	assert_true(float(w2.db.get_record("people", w2.offerer_id).linh_thach) <= dead_cash_before, "dead offerer gained no wealth")


# --- AC-QS-120..123, 134, 140..141: Wealth outcomes, stage-1 abandon immunity, ties split, board & sect roots ----

func test_ac_qs_120_to_123_134_140_141_outcomes_ties_board_and_sect_roots() -> void:
	# AC-QS-120, 121, 122: stage-1 abandon applies NO failed outcomes; stage-2 abandon applies -20; Lapsed applies -20.
	var w: Dictionary = _world()
	_make_quest(w, "q_s1_ab")
	w.svc.accept(w.player, "q_s1_ab", 0)
	var off0: float = float(w.db.get_record("people", w.offerer_id).linh_thach)
	w.svc.abandon(w.player, "q_s1_ab", 0, 1, {"season_idx": 1})
	assert_eq(float(w.db.get_record("people", w.offerer_id).linh_thach), off0, "AC-QS-122 stage-1 abandon applies NO failed outcomes")

	_make_quest(w, "q_s2_ab")
	w.svc.accept(w.player, "q_s2_ab", 0)
	w.svc.trigger_stage_event(w.player, w.sheet, RandomNumberGenerator.new(), "q_s2_ab", {"season_idx": 1})
	var off_s2: float = float(w.db.get_record("people", w.offerer_id).linh_thach)
	w.svc.abandon(w.player, "q_s2_ab", 0, 2, {"season_idx": 2})
	assert_eq(int(w.db.get_record("people", w.offerer_id).linh_thach), int(off_s2 - 20), "AC-QS-121/122 stage-2 abandon applies failed wealth -20")

	_make_quest(w, "q_lapse_oc")
	w.svc.accept(w.player, "q_lapse_oc", 0)
	var off_l0: float = float(w.db.get_record("people", w.offerer_id).linh_thach)
	w.svc.tick_season(w.player, w.sheet, 2, 3, {"season_idx": 11})
	assert_eq(int(w.db.get_record("people", w.offerer_id).linh_thach), int(off_l0 - 20), "AC-QS-120/121 Lapsed applies failed -20 and NOT completed +30")
	assert_near(float(w.money.season_check().gap), 0.0, 1e-6, "MoneyLedger gap == 0")

	# AC-QS-123: offerer_ties wealth 30 across 4 ties (1 master + 3 disciples) -> 7 each; injury 0.40 -> 0.20 each.
	var wt: Dictionary = _world()
	_make_quest(wt, "q_ties_w", {
		"outcomes": [
			{"on": "completed", "role": "offerer_ties", "effect": "wealth", "amount": 30},
			{"on": "failed", "role": "offerer_ties", "effect": "injury", "amount": 0.40},
		]
	})
	wt.svc.accept(wt.player, "q_ties_w", 0)
	var qt: Dictionary = wt.svc.get_quest("q_ties_w")
	qt["stage"] = 3
	wt.svc.put_quest(qt)
	var tie_ids := [wt.master_id, wt.disc1_id, wt.disc2_id, wt.disc3_id]
	var before_cash := {}
	for tid in tie_ids:
		before_cash[tid] = int(wt.db.get_record("people", tid).linh_thach)
	wt.svc.trigger_stage_event(wt.player, wt.sheet, RandomNumberGenerator.new(), "q_ties_w", {"season_idx": 1})
	for tid in tie_ids:
		assert_eq(int(wt.db.get_record("people", tid).linh_thach) - int(before_cash[tid]), 7, "AC-QS-123 tie %s gets floor(30/4)=7" % tid)
	assert_near(float(wt.money.season_check().gap), 0.0, 1e-6, "AC-QS-123 MoneyLedger gap == 0")

	_make_quest(wt, "q_ties_inj", {
		"outcomes": [
			{"on": "completed", "role": "offerer", "effect": "wealth", "amount": 10},
			{"on": "failed", "role": "offerer_ties", "effect": "injury", "amount": 0.40},
		]
	})
	wt.svc.accept(wt.player, "q_ties_inj", 0)
	var qti: Dictionary = wt.svc.get_quest("q_ties_inj")
	qti["stage"] = 2
	wt.svc.put_quest(qti)
	wt.svc.abandon(wt.player, "q_ties_inj", 0, 2, {"season_idx": 2})
	for tid in tie_ids:
		assert_near(float(wt.db.get_record("people", tid).vitality), 0.80, 0.001, "AC-QS-123 tie %s vitality 1.0 - 0.20 = 0.80" % tid)

	# AC-QS-134: Board quest at sect place with offerer wealth on completed -> head gains wealth, zero attitudes move on Completed/Failed/Lapsed.
	var wb: Dictionary = _world()
	_make_quest(wb, "q_board_oc", {
		"offer_kind": "board",
		"offerer_id": wb.sect_id,
		"offerer_root_id": wb.head_id,
		"offerer_sect_id": wb.sect_id,
		"outcomes": [{"on": "completed", "role": "offerer", "effect": "wealth", "amount": 25}],
	})
	wb.svc.accept(wb.player, "q_board_oc", 0)
	var qb: Dictionary = wb.svc.get_quest("q_board_oc")
	qb["stage"] = 3
	wb.svc.put_quest(qb)
	var h_cash0: int = int(wb.db.get_record("people", wb.head_id).linh_thach)
	wb.svc.trigger_stage_event(wb.player, wb.sheet, RandomNumberGenerator.new(), "q_board_oc", {"season_idx": 1})
	assert_eq(int(wb.db.get_record("people", wb.head_id).linh_thach), h_cash0 + 25, "AC-QS-134 board completed gives sect head wealth +25")
	assert_eq(int(wb.db.get_record("people", wb.head_id).attitude), 0, "AC-QS-134 board completed moves 0 attitudes")

	# AC-QS-140: Sect offer through speaking member M -> on Failed, M -15, M's master -7, sect head -3.
	var ws: Dictionary = _world()
	_make_quest(ws, "q_sect_root", {
		"offer_kind": "sect",
		"offerer_id": ws.sect_id,
		"offerer_root_id": ws.offerer_id,
		"offerer_sect_id": ws.sect_id,
	})
	ws.svc.accept(ws.player, "q_sect_root", 0)
	ws.svc.abandon(ws.player, "q_sect_root", 0, 1, {"season_idx": 1})
	assert_eq(int(ws.db.get_record("people", ws.offerer_id).attitude), -15, "AC-QS-140 speaking member -15")
	assert_eq(int(ws.db.get_record("people", ws.master_id).attitude), -7, "AC-QS-140 speaking member master -7")
	assert_eq(int(ws.db.get_record("people", ws.head_id).attitude), -3, "AC-QS-140 sect head -3")


# --- AC-QS-129, 130, 145: Immediate knockout death & survival on fail/lapse/drop; player death stage 1 vs 2 ------

func test_ac_qs_129_130_145_knockout_death_and_player_death_outcomes() -> void:
	# AC-QS-129 & AC-QS-130: Major quest with adversary `death` outcome; knockout in stage 3 kills adversary AT ONCE,
	# shifts master -15 & sect head -7 immediately without Rule 5 Fail, and survives subsequent Failed/Lapsed/Dropped.
	var w: Dictionary = _world()
	var maj_stages := [
		{"kind": "event", "window": 2, "place_id": w.pl1, "rewards": [{"type": "linh_thach", "amount": 5}]},
		{"kind": "event", "window": 2, "place_id": w.pl1, "rewards": [{"type": "linh_thach", "amount": 5}]},
		{"kind": "defeat", "window": 3, "place_id": w.pl2, "target_id": w.adv_id, "if_target_lost": "drop", "rewards": [{"type": "linh_thach", "amount": 10}]},
		{"kind": "event", "window": 2, "place_id": w.pl1, "rewards": [{"type": "linh_thach", "amount": 50}]},
	]
	_make_quest(w, "q_kill_adv", {
		"tier": "major",
		"adversary_id": w.adv_id,
		"adversary_root_id": w.adv_id,
		"stages": maj_stages.duplicate(true),
		"outcomes": [
			{"on": "completed", "role": "offerer", "effect": "wealth", "amount": 30},
			{"on": "completed", "role": "adversary", "effect": "death"},
		],
	})
	w.svc.accept(w.player, "q_kill_adv", 0)
	w.svc.trigger_stage_event(w.player, w.sheet, RandomNumberGenerator.new(), "q_kill_adv", {"season_idx": 1})
	w.svc.trigger_stage_event(w.player, w.sheet, RandomNumberGenerator.new(), "q_kill_adv", {"season_idx": 2})
	assert_eq(int(w.svc.get_quest("q_kill_adv").stage), 3, "at stage 3 defeat")

	var ko: Dictionary = w.svc.on_defeat(
		w.player, w.sheet, RandomNumberGenerator.new(), "q_kill_adv",
		func(_q, _st, _pl): return "knockout",
		{"fight_ratio": 0.30, "season_idx": 3}
	)
	assert_true(bool(ko.adversary_killed), "AC-QS-129 adversary killed at knockout")
	assert_false(bool(w.db.get_record("people", w.adv_id).alive), "AC-QS-129 adversary dead at once")
	assert_eq(int(w.db.get_record("people", w.adv_master_id).attitude), -15, "AC-QS-129 adversary master -15 at knockout")
	assert_eq(int(w.db.get_record("people", w.adv_head_id).attitude), -7, "AC-QS-129 adversary sect head -7 at knockout")
	assert_eq(str(w.svc.get_quest("q_kill_adv").state), "active", "AC-QS-129 NOT Failed by Rule 5")
	assert_eq(int(w.svc.get_quest("q_kill_adv").stage), 4, "AC-QS-129 advanced to stage 4")
	assert_near(float(w.money.season_check().gap), 0.0, 1e-6, "AC-QS-129 MoneyLedger gap == 0 after knockout death")

	# AC-QS-130: Quest later Fails (abandoned at stage 4) -> adversary stays dead & ties' -15/-7 stay applied!
	w.svc.abandon(w.player, "q_kill_adv", 1, 0, {"season_idx": 4})
	assert_eq(str(w.svc.get_quest("q_kill_adv").state), "failed", "AC-QS-130 quest failed later")
	assert_false(bool(w.db.get_record("people", w.adv_id).alive), "AC-QS-130 adversary remains dead")
	assert_eq(int(w.db.get_record("people", w.adv_master_id).attitude), -15, "AC-QS-130 master -15 remains")
	assert_eq(int(w.db.get_record("people", w.adv_head_id).attitude), -7, "AC-QS-130 sect head -7 remains")

	# AC-QS-130: Quest that never reaches knockout -> no death applies.
	var w_noko: Dictionary = _world()
	_make_quest(w_noko, "q_noko", {
		"tier": "major",
		"adversary_id": w_noko.adv_id,
		"adversary_root_id": w_noko.adv_id,
		"stages": maj_stages.duplicate(true),
		"outcomes": [
			{"on": "completed", "role": "offerer", "effect": "wealth", "amount": 30},
			{"on": "completed", "role": "adversary", "effect": "death"},
		],
	})
	w_noko.svc.accept(w_noko.player, "q_noko", 0)
	w_noko.svc.abandon(w_noko.player, "q_noko", 0, 1, {"season_idx": 1})
	assert_true(bool(w_noko.db.get_record("people", w_noko.adv_id).alive), "AC-QS-130 no death if knockout never reached")

	# AC-QS-145: Player dies in stage 2 -> failed outcome applies + 16-season cd; dies in stage 1 -> NO failed outcome + 16-season cd.
	var w145: Dictionary = _world()
	var f_s1: String = w145.db.log_event(100, 1, "trade", "S1", [w145.offerer_id], [w145.pl1], [], {})
	var f_s2: String = w145.db.log_event(100, 2, "trade", "S2", [w145.offerer_id], [w145.pl1], [], {})
	_make_quest(w145, "q_pd_s1", {"source_fact_id": f_s1, "outcomes": [{"on": "completed", "role": "offerer", "effect": "wealth", "amount": 20}, {"on": "failed", "role": "offerer", "effect": "wealth", "amount": -20}]})
	_make_quest(w145, "q_pd_s2", {"source_fact_id": f_s2, "outcomes": [{"on": "completed", "role": "offerer", "effect": "wealth", "amount": 20}, {"on": "failed", "role": "offerer", "effect": "wealth", "amount": -25}]})
	w145.svc.accept(w145.player, "q_pd_s1", 0)
	w145.svc.accept(w145.player, "q_pd_s2", 0)
	w145.svc.trigger_stage_event(w145.player, w145.sheet, RandomNumberGenerator.new(), "q_pd_s2", {"season_idx": 1})
	var cash_before_pd: int = int(w145.db.get_record("people", w145.offerer_id).linh_thach)

	w145.svc.on_player_death(w145.player, 0, 2, {"season_idx": 2})
	# Only q_pd_s2's -25 applied; q_pd_s1's -20 did NOT apply!
	assert_eq(int(w145.db.get_record("people", w145.offerer_id).linh_thach), cash_before_pd - 25, "AC-QS-145 stage 2 failed outcome applied, stage 1 skipped")
	assert_false(w145.svc.is_fact_available(f_s1, 17), "AC-QS-145 stage 1 fact still on 16-season cooldown")
	assert_true(w145.svc.is_fact_available(f_s1, 18), "AC-QS-145 stage 1 fact open at +16")
	assert_false(w145.svc.is_fact_available(f_s2, 17), "AC-QS-145 stage 2 fact on 16-season cooldown")
	assert_true(w145.svc.is_fact_available(f_s2, 18), "AC-QS-145 stage 2 fact open at +16")
	assert_near(float(w145.money.season_check().gap), 0.0, 1e-6, "AC-QS-145 MoneyLedger gap == 0")
