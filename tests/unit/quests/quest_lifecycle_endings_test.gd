extends DaoTestSuite
## Deterministic unit tests for Template Quests (#31) Wave 2 W2B — QuestService lifecycle,
## stage handlers, Formula B holds, Formula D lasting gains, orphaning, target loss,
## save/reload determinism, and MoneyLedger conservation.
## Covers AC-QS-29, 34..37, 41..45, 47..72, 87..88, 93..101, 136.

const _QuestRules := preload("res://src/gameplay/quests/quest_rules.gd")
const _QuestBoard := preload("res://src/gameplay/quests/quest_board.gd")
const _QuestService := preload("res://src/gameplay/quests/quest_service.gd")
const _EventStore := preload("res://src/gameplay/events/event_store.gd")


# --- Fixture helpers ----------------------------------------------------------------------------------------------

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
	var pl3: String = db.add("places", {
		"name": "Bạch Thạch Trấn", "kind": "town", "type": "tran", "region_id": "r1",
		"bounties": true, "density": 0.9, "links": []
	})
	db.get_record("places", pl1)["links"] = [{"to": pl2, "seasons": 1.0}, {"to": pl3, "seasons": 1.0}]
	db.get_record("places", pl2)["links"] = [{"to": pl1, "seasons": 1.0}]
	db.get_record("places", pl3)["links"] = [{"to": pl1, "seasons": 1.0}]

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
	var master_id: String = _add_npc(db, "Trần Trưởng Lão", pl1, sect_id, "truong_lao", 1, 0, "", 3000)
	var offerer_id: String = _add_npc(db, "Lý Chấp Sự", pl1, sect_id, "noi_mon", 0, 0, master_id, 2000)
	var recipient_id: String = _add_npc(db, "Chu Dược Sư", pl1, sect_id, "noi_mon", 0, 0, "", 1000)
	db.get_record("sects", sect_id)["members"] = [head_id, master_id, offerer_id, recipient_id]

	var rival_sect_id: String = db.add("sects", {
		"name": "Huyết Sát Môn", "status": "active", "hq_place_id": pl2,
		"leader_id": "", "members": [], "treasury": 40000.0
	})
	var adv_head_id: String = _add_npc(db, "Huyết Môn Chủ", pl2, rival_sect_id, "tong_chu", 2, 0, "", 5000)
	db.get_record("sects", rival_sect_id)["leader_id"] = adv_head_id
	var adv_id: String = _add_npc(db, "Huyết Đồ", pl2, rival_sect_id, "noi_mon", 1, 0, "", 1500)
	db.get_record("sects", rival_sect_id)["members"] = [adv_head_id, adv_id]

	var fact_id: String = db.log_event(
		100, 0, "grudge", "Huyết Đồ gây sự với Lý Chấp Sự.",
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
		"pl1": pl1, "pl2": pl2, "pl3": pl3,
		"sect_id": sect_id, "head_id": head_id, "master_id": master_id,
		"offerer_id": offerer_id, "recipient_id": recipient_id,
		"rival_sect_id": rival_sect_id, "adv_head_id": adv_head_id, "adv_id": adv_id,
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


func _make_fx_plan_quest(w: Dictionary, qid: String = "q_fx_plan", overrides: Dictionary = {}) -> Dictionary:
	var plan := {
		"template_id": "fx_plan",
		"name": "Ủy thác thử nghiệm",
		"tier": "ordinary",
		"realm_index": w.player.realm_index,
		"offer_kind": "person",
		"offerer_id": w.offerer_id,
		"offerer_root_id": w.offerer_id,
		"offerer_sect_id": w.sect_id,
		"adversary_id": "",
		"place_id": w.pl1,
		"source_fact": w.fact,
		"travel_seasons": 0,
		"stages": [
			{"kind": "event", "window": 2, "place_id": w.pl1, "rewards": [{"type": "linh_thach", "amount": 4}]},
			{"kind": "craft", "item_class": "pill", "quality_min": 0, "window": 3, "place_id": w.pl1, "rewards": [{"type": "linh_thach", "amount": 9}]},
			{"kind": "deliver", "item_class": "pill", "quality_min": 0, "deliver_price": 20, "window": 2, "place_id": w.pl1, "target_id": w.recipient_id, "if_target_lost": "orphan", "rewards": [{"type": "linh_thach", "amount": 47}]},
		],
		"outcomes": [
			{"on": "completed", "role": "offerer", "effect": "wealth", "amount_share": 0.30},
		],
	}
	for k in overrides.keys():
		if k in ["stages", "tier", "realm_index", "offer_kind", "offerer_id", "offerer_root_id", "offerer_sect_id", "adversary_id", "place_id", "rare_reward", "outcomes", "travel_seasons"]:
			plan[k] = overrides[k]
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
		"place_id": str(plan.place_id),
		"source_fact_id": str(overrides.get("source_fact_id", w.fact_id)),
		"source_fact": w.fact.duplicate(true),
		"plan": plan,
		"outcomes": Array(plan.outcomes).duplicate(true),
		"state": "offered",
		"stage": 1,
		"offered_season": int(overrides.get("offered_season", 0)),
		"player_id": w.player.id,
	}
	for k in overrides.keys():
		if not q.has(k) or k in ["offered_season", "source_fact_id", "state"]:
			q[k] = overrides[k]
	w.svc.put_quest(q)
	return q


func _add_pill(w: Dictionary, owner_id: String, quality: int = 0) -> String:
	var p: Dictionary = w.items.pill("tu_khi_dan", quality, 1)
	p["owner_id"] = owner_id
	return w.db.add("items", p)


# --- AC-QS-29, 70, 72: Frozen budget across promotion, reach+deliver, reload plan stability ----------------------

func test_ac_qs_29_70_72_frozen_plan_promotion_reach_and_reload() -> void:
	var w: Dictionary = _world()
	# AC-QS-29: FX-PLAN accepted at Qi Refining (pays 4, 9, 47); player promoted mid-quest to Foundation Establishment.
	_make_fx_plan_quest(w, "q_promo")
	assert_true(w.svc.accept(w.player, "q_promo", 0).ok, "accept FX-PLAN")
	var r1: Dictionary = w.svc.trigger_stage_event(w.player, w.sheet, RandomNumberGenerator.new(), "q_promo", {"year": 1, "season": 0, "season_idx": 1})
	assert_eq(int(r1.stage_paid), 4, "AC-QS-29 stage 1 pays 4")

	# Promote player mid-quest to realm 1 (Foundation Establishment, I_r = 80 instead of 10).
	w.player.realm_index = 1
	# AC-QS-72: save & reload WorldDB at stage 2 -> frozen plan is byte-identical.
	var before_plan: Dictionary = w.svc.get_quest("q_promo").plan.duplicate(true)
	var saved_db: Dictionary = w.db.to_dict()
	var reloaded_db := WorldDB.from_dict(saved_db)
	var svc2 := _QuestService.new(w.gd, reloaded_db, null, w.items)
	assert_eq(svc2.get_quest("q_promo").plan, before_plan, "AC-QS-72 stage 2 reload plan byte-identical")

	# Continue on original db: craft & deliver still pay 9 and 47 (frozen at offer realm!).
	var pill_id: String = _add_pill(w, w.player.id)
	w.svc.on_item_crafted(w.player, pill_id, 2)
	var r2: Dictionary = w.svc.on_craft(w.player, "q_promo", pill_id, 1, 2, {"season_idx": 2})
	assert_eq(int(r2.stage_paid), 9, "AC-QS-29 stage 2 still pays 9 after promotion")
	var r3: Dictionary = w.svc.on_deliver(w.player, "q_promo", pill_id, 1, 3, {"season_idx": 3})
	assert_eq(int(r3.stage_paid), 47, "AC-QS-29 stage 3 still pays 47 after promotion")
	assert_eq(str(r3.state), "completed", "AC-QS-29 completed")
	assert_near(float(w.money.season_check().gap), 0.0, 1e-6, "MoneyLedger conservation gap == 0")

	# AC-QS-70: FX-PLAN with a reach stage before deliver -> S_plan 4, B 60, pays 4, 9, 0, 47.
	var w2: Dictionary = _world()
	_make_fx_plan_quest(w2, "q_reach_del", {
		"stages": [
			{"kind": "event", "window": 2, "place_id": w2.pl1, "rewards": [{"type": "linh_thach", "amount": 4}]},
			{"kind": "craft", "item_class": "pill", "quality_min": 0, "window": 3, "place_id": w2.pl1, "rewards": [{"type": "linh_thach", "amount": 9}]},
			{"kind": "reach", "target_level": 5, "window": 4, "place_id": w2.pl1, "rewards": []},
			{"kind": "deliver", "item_class": "pill", "quality_min": 0, "window": 2, "place_id": w2.pl1, "rewards": [{"type": "linh_thach", "amount": 47}]},
		]
	})
	w2.svc.accept(w2.player, "q_reach_del", 0)
	var b70: Dictionary = w2.svc.get_quest("q_reach_del").budget
	assert_eq(int(b70.S_plan), 4, "AC-QS-70 S_plan=4")
	assert_eq(int(b70.B), 60, "AC-QS-70 B=60")
	assert_eq(b70.stage_pays, [4, 9, 0, 47], "AC-QS-70 pays 4, 9, 0, 47")
	w2.svc.trigger_stage_event(w2.player, w2.sheet, RandomNumberGenerator.new(), "q_reach_del", {"season_idx": 1})
	var p70: String = _add_pill(w2, w2.player.id)
	w2.svc.on_item_crafted(w2.player, p70, 2)
	w2.svc.on_craft(w2.player, "q_reach_del", p70, 0, 2, {"season_idx": 2})
	w2.player.level = 5
	var reach_evs: Array = w2.svc.on_reach(w2.player, w2.sheet, 0, 3, {"season_idx": 3})
	assert_eq(reach_evs.size(), 1, "AC-QS-70 reach stage completed")
	assert_eq(int(reach_evs[0].stage_paid), 0, "AC-QS-70 reach stage pays 0")
	assert_false(bool(reach_evs[0].action_spent), "AC-QS-70/43 reach consumes no season action")
	var del70: Dictionary = w2.svc.on_deliver(w2.player, "q_reach_del", p70, 1, 0, {"season_idx": 4})
	assert_eq(int(del70.stage_paid), 47, "AC-QS-70 deliver pays 47")


# --- AC-QS-34..37, 101: Formula B defeat holds, draw/flight, knockout win vs player Down fail -------------------

func test_ac_qs_34_to_37_101_defeat_hold_and_outcomes() -> void:
	var w: Dictionary = _world()
	# AC-QS-34: Ordinary defeat stage with r=0.40 at start, falling to 0.30 after 2 seasons -> opens & deadline +2.
	_make_fx_plan_quest(w, "q_def34", {
		"stages": [
			{"kind": "defeat", "window": 2, "place_id": w.pl1, "target_id": w.adv_id, "rewards": [{"type": "linh_thach", "amount": 5}]},
			{"kind": "event", "window": 2, "place_id": w.pl1, "rewards": [{"type": "linh_thach", "amount": 10}]},
		]
	})
	w.svc.accept(w.player, "q_def34", 0)
	var orig_dl: int = int(w.svc.get_quest("q_def34").deadline_season)
	assert_eq(orig_dl, 6, "initial deadline (2+2)*1.5 = 6")

	# Two seasons at r = 0.40 (> 0.35): stage holds and deadline shifts by 2.
	var blocked: Dictionary = w.svc.on_defeat(w.player, w.sheet, RandomNumberGenerator.new(), "q_def34", Callable(), {"fight_ratio": 0.40})
	assert_false(bool(blocked.ok), "fight blocked while held at r=0.40")
	w.svc.tick_season(w.player, w.sheet, 0, 1, {"season_idx": 1, "fight_ratio": 0.40})
	w.svc.tick_season(w.player, w.sheet, 0, 2, {"season_idx": 2, "fight_ratio": 0.40})
	assert_eq(int(w.svc.get_quest("q_def34").deadline_season), orig_dl + 2, "AC-QS-34 deadline moved 2 later")

	# Ratio drops to 0.30 -> fight opens.
	# AC-QS-36: draw and flight leave stage open & deadline running.
	var r_draw: Dictionary = w.svc.on_defeat(w.player, w.sheet, RandomNumberGenerator.new(), "q_def34", func(_q, _st, _pl): return "draw", {"fight_ratio": 0.30, "season_idx": 3})
	assert_true(bool(r_draw.ok) and not bool(r_draw.stage_completed), "AC-QS-36 draw leaves stage open")
	var r_flee: Dictionary = w.svc.on_defeat(w.player, w.sheet, RandomNumberGenerator.new(), "q_def34", func(_q, _st, _pl): return "flight", {"fight_ratio": 0.30, "season_idx": 3})
	assert_true(bool(r_flee.ok) and not bool(r_flee.stage_completed), "AC-QS-36 flight leaves stage open")
	assert_eq(int(w.svc.get_quest("q_def34").stage), 1, "AC-QS-36 still stage 1")

	# AC-QS-37: knockout win completes the stage.
	var r_win: Dictionary = w.svc.on_defeat(w.player, w.sheet, RandomNumberGenerator.new(), "q_def34", func(_q, _st, _pl): return "knockout", {"fight_ratio": 0.30, "season_idx": 4})
	assert_true(bool(r_win.stage_completed), "AC-QS-37 knockout completes defeat stage")
	assert_eq(int(w.svc.get_quest("q_def34").stage), 2, "AC-QS-37 advanced to stage 2")

	# AC-QS-35 & AC-QS-101: Errand with deadline 12 held 4 seasons at r=0.40 -> deadline becomes 16, opens on season 5.
	var w2: Dictionary = _world()
	_make_fx_plan_quest(w2, "q_def35", {
		"tier": "errand",
		"stages": [
			{"kind": "defeat", "window": 4, "place_id": w2.pl1, "target_id": w2.adv_id},
			{"kind": "event", "window": 4, "place_id": w2.pl1},
		]
	})
	w2.svc.accept(w2.player, "q_def35", 0)
	assert_eq(int(w2.svc.get_quest("q_def35").deadline_season), 12, "Errand deadline_max = 12")
	for s in range(1, 5):
		w2.svc.tick_season(w2.player, w2.sheet, 0, s, {"season_idx": s, "fight_ratio": 0.40})
	assert_eq(int(w2.svc.get_quest("q_def35").deadline_season), 16, "AC-QS-35/101 4 held seasons shift Errand deadline 12 -> 16")
	var hold_s5: Dictionary = w2.svc.evaluate_defeat_hold(w2.player, w2.sheet, w2.svc.get_quest("q_def35"), {"fight_ratio": 0.40})
	assert_true(bool(hold_s5.open), "AC-QS-35 fight opens after 4 held seasons even at r=0.40")
	w2.svc.tick_season(w2.player, w2.sheet, 1, 1, {"season_idx": 5, "fight_ratio": 0.40})
	assert_eq(int(w2.svc.get_quest("q_def35").deadline_season), 16, "AC-QS-35 season 5 counts against deadline (no 5th shift)")

	# AC-QS-37: player Down and alive -> Failed, -15 attitude on offerer.
	var r_down: Dictionary = w2.svc.on_defeat(w2.player, w2.sheet, RandomNumberGenerator.new(), "q_def35", func(_q, _st, _pl): return "down", {"fight_ratio": 0.15, "season_idx": 5})
	assert_eq(str(r_down.state), "failed", "AC-QS-37 player Down fails quest")
	assert_eq(int(w2.db.get_record("people", w2.offerer_id).attitude), -15, "AC-QS-37 offerer attitude -15")


# --- AC-QS-41..45, 47..48, 98: Time, free visit/reach, slots, offers, cooldowns & withdrawal ---------------------

func test_ac_qs_41_to_45_47_48_98_time_slots_and_cooldowns() -> void:
	var w: Dictionary = _world()
	# AC-QS-41 & AC-QS-42: past stage 1 window (2) before deadline (11) -> no state change; season 11 completion vs Lapsed.
	_make_fx_plan_quest(w, "q_dl_ok")
	w.svc.accept(w.player, "q_dl_ok", 0)
	w.svc.tick_season(w.player, w.sheet, 0, 3, {"season_idx": 3})
	assert_eq(str(w.svc.get_quest("q_dl_ok").state), "active", "AC-QS-42 past stage window 2 still active")

	# Finish stages 1 and 2, then finish stage 3 at season 11 (exact deadline season).
	w.svc.trigger_stage_event(w.player, w.sheet, RandomNumberGenerator.new(), "q_dl_ok", {"season_idx": 4})
	var p1: String = _add_pill(w, w.player.id)
	w.svc.on_item_crafted(w.player, p1, 5)
	w.svc.on_craft(w.player, "q_dl_ok", p1, 1, 1, {"season_idx": 5})
	var done11: Dictionary = w.svc.on_deliver(w.player, "q_dl_ok", p1, 2, 3, {"season_idx": 11})
	assert_eq(str(done11.state), "completed", "AC-QS-41 last stage done at season 11 -> Completed")
	# AC-QS-47 & AC-QS-98: Completed fact permanently spent (blocked at +8, +16, +100).
	assert_false(w.svc.is_fact_available(w.fact_id, 19), "AC-QS-98 completed fact spent at +8")
	assert_false(w.svc.is_fact_available(w.fact_id, 27), "AC-QS-98 completed fact spent at +16")
	assert_false(w.svc.is_fact_available(w.fact_id, 111), "AC-QS-98 completed fact spent at +100")

	# Lapsed at season 11 when not done + 8-season cooldown (blocked at 7, open at 8).
	var f2: String = w.db.log_event(100, 1, "trade", "Lý Chấp Sự thiếu hàng.", [w.offerer_id], [w.pl1], [], {})
	_make_fx_plan_quest(w, "q_dl_lapse", {"source_fact_id": f2})
	w.svc.accept(w.player, "q_dl_lapse", 0)
	w.svc.tick_season(w.player, w.sheet, 2, 2, {"season_idx": 10})
	assert_eq(str(w.svc.get_quest("q_dl_lapse").state), "active", "still active at season 10")
	w.svc.tick_season(w.player, w.sheet, 2, 3, {"season_idx": 11})
	assert_eq(str(w.svc.get_quest("q_dl_lapse").state), "lapsed", "AC-QS-41 not done at season 11 -> Lapsed")
	assert_false(w.svc.is_fact_available(f2, 18), "AC-QS-47 Lapsed fact blocked at +7")
	assert_true(w.svc.is_fact_available(f2, 19), "AC-QS-47 Lapsed fact open at +8")

	# AC-QS-43: visit + reach met in a season leave action unspent; event stage spends it.
	var w3: Dictionary = _world()
	_make_fx_plan_quest(w3, "q_vr", {
		"stages": [
			{"kind": "visit", "window": 2, "place_id": w3.pl1, "target_id": w3.recipient_id},
			{"kind": "reach", "target_level": 2, "window": 4, "place_id": w3.pl1},
			{"kind": "event", "window": 2, "place_id": w3.pl1},
		]
	})
	w3.svc.accept(w3.player, "q_vr", 0)
	assert_eq(_QuestService.active_visit_targets(w3.db, w3.player.id), [w3.recipient_id], "active_visit_targets exposes visit NPC")
	var v_res: Array = w3.svc.on_greet_npc(w3.player, w3.recipient_id, 0, 1, {"season_idx": 1})
	assert_eq(v_res.size(), 1, "greet completed visit stage")
	assert_false(bool(v_res[0].action_spent), "AC-QS-43 visit consumes no action")
	w3.player.level = 2
	var r_res: Array = w3.svc.on_reach(w3.player, w3.sheet, 0, 1, {"season_idx": 1})
	assert_eq(r_res.size(), 1, "reach completed")
	assert_false(bool(r_res[0].action_spent), "AC-QS-43 reach consumes no action")
	var e_res: Dictionary = w3.svc.trigger_stage_event(w3.player, w3.sheet, RandomNumberGenerator.new(), "q_vr", {"season_idx": 1})
	assert_true(bool(e_res.action_spent), "AC-QS-43 event stage spends season action")

	# AC-QS-44: active_cap = 3; 4th refused; no person offer generated; board reads but refuses acceptance.
	var w4: Dictionary = _world()
	for i in range(4):
		_make_fx_plan_quest(w4, "q_cap_%d" % i)
	assert_true(w4.svc.accept(w4.player, "q_cap_0", 0).ok, "slot 1")
	assert_true(w4.svc.accept(w4.player, "q_cap_1", 0).ok, "slot 2")
	assert_true(w4.svc.accept(w4.player, "q_cap_2", 0).ok, "slot 3")
	var fourth: Dictionary = w4.svc.accept(w4.player, "q_cap_3", 0)
	assert_false(bool(fourth.ok), "AC-QS-44 4th accept refused")
	assert_eq(str(fourth.reason), "active_cap_reached", "AC-QS-44 cap reason")
	var no_offer: Dictionary = w4.svc.offer_from_person(w4.player, w4.sheet, w4.offerer_id, w4.pl1, 100, 1)
	assert_false(bool(no_offer.ok), "AC-QS-44 no person offer generated at cap")
	var b_list: Array = w4.svc.board_offers(w4.pl1, w4.player, w4.sheet, 100, 1, true)
	assert_eq(b_list.size(), 3, "AC-QS-44 board still readable at cap")
	assert_false(bool(w4.svc.accept(w4.player, str(b_list[0].id), 1).ok), "AC-QS-44 board accept refused at cap")

	# AC-QS-45 & AC-QS-48: offer open after 3 seasons, Declined after 4 (8-season cd); manual decline; offerer death -> Withdrawn (0 cd).
	var w5: Dictionary = _world()
	var f_exp: String = w5.db.log_event(100, 0, "trade", "Giao dịch A", [w5.offerer_id], [w5.pl1], [], {})
	_make_fx_plan_quest(w5, "q_exp", {"source_fact_id": f_exp, "offered_season": 10})
	w5.svc.tick_season(w5.player, w5.sheet, 3, 1, {"season_idx": 13})
	assert_eq(str(w5.svc.get_quest("q_exp").state), "offered", "AC-QS-45 still open after 3 seasons")
	w5.svc.tick_season(w5.player, w5.sheet, 3, 2, {"season_idx": 14})
	assert_eq(str(w5.svc.get_quest("q_exp").state), "declined", "AC-QS-45 Declined after 4 seasons")
	assert_false(w5.svc.is_fact_available(f_exp, 21), "AC-QS-47 Declined blocked at +7")
	assert_true(w5.svc.is_fact_available(f_exp, 22), "AC-QS-47 Declined open at +8")

	var f_man: String = w5.db.log_event(100, 0, "trade", "Giao dịch B", [w5.offerer_id], [w5.pl1], [], {})
	_make_fx_plan_quest(w5, "q_man", {"source_fact_id": f_man, "offered_season": 10})
	assert_eq(str(w5.svc.decline("q_man", 10).state), "declined", "AC-QS-45 manual decline immediate")

	var f_wd: String = w5.db.log_event(100, 0, "trade", "Giao dịch C", [w5.offerer_id], [w5.pl1], [], {})
	_make_fx_plan_quest(w5, "q_wd", {"source_fact_id": f_wd, "offered_season": 10})
	w5.db.get_record("people", w5.offerer_id)["alive"] = false
	w5.svc.tick_season(w5.player, w5.sheet, 2, 3, {"season_idx": 11})
	assert_eq(str(w5.svc.get_quest("q_wd").state), "withdrawn", "AC-QS-48 dead offerer withdraws offer")
	assert_true(w5.svc.is_fact_available(f_wd, 11), "AC-QS-48/98 Withdrawn has 0 cooldown")


# --- AC-QS-49..63, 69: Endings, abandon, orphan, player death, unique item, disambiguation, craft provenance -----

func test_ac_qs_49_to_63_69_endings_orphan_disambiguation_and_craft() -> void:
	# AC-QS-49, 50, 52, 60: Abandon after stage 1 (keeps 4, -15, 16-season cd, slot freed, ending logged) & board/sect fail.
	var w: Dictionary = _world()
	_make_fx_plan_quest(w, "q_ab1")
	w.svc.accept(w.player, "q_ab1", 0)
	var cash0: int = w.player.linh_thach
	w.svc.trigger_stage_event(w.player, w.sheet, RandomNumberGenerator.new(), "q_ab1", {"season_idx": 1})
	assert_eq(w.player.linh_thach, cash0 + 4, "stage 1 paid 4")
	var ab: Dictionary = w.svc.abandon(w.player, "q_ab1", 0, 2, {"season_idx": 2})
	assert_eq(str(ab.state), "failed", "AC-QS-49 abandon -> Failed")
	assert_eq(w.player.linh_thach, cash0 + 4, "AC-QS-49 paid 4 stays")
	assert_eq(int(w.db.get_record("people", w.offerer_id).attitude), -15, "AC-QS-49 offerer -15")
	assert_eq(w.svc.active_quests(w.player.id).size(), 0, "AC-QS-49 slot freed")
	assert_false(w.svc.is_fact_available(w.fact_id, 17), "AC-QS-47 Failed blocked at +15")
	assert_true(w.svc.is_fact_available(w.fact_id, 18), "AC-QS-47 Failed open at +16")
	var log_ev: Dictionary = w.db.get_record("events", str(ab.event_id))
	assert_eq(int(log_ev.data.stages_done), 1, "AC-QS-60 log records stages_done")
	assert_eq(int(log_ev.data.paid_total), 4, "AC-QS-60 log records paid_total")

	# AC-QS-50 & AC-QS-51: Lapsed -> -8; repeat failures stop at -29 floor.
	w.db.get_record("people", w.offerer_id)["attitude"] = 0
	var f_lap: String = w.db.log_event(100, 1, "trade", "Lapse", [w.offerer_id], [w.pl1], [], {})
	_make_fx_plan_quest(w, "q_lap", {"source_fact_id": f_lap})
	w.svc.accept(w.player, "q_lap", 0)
	w.svc.tick_season(w.player, w.sheet, 2, 3, {"season_idx": 11})
	assert_eq(int(w.db.get_record("people", w.offerer_id).attitude), -8, "AC-QS-50 Lapsed -8")
	w.db.get_record("people", w.offerer_id)["attitude"] = -22
	_make_fx_plan_quest(w, "q_lap2", {"source_fact_id": f_lap})
	w.svc.accept(w.player, "q_lap2", 0)
	w.svc.tick_season(w.player, w.sheet, 2, 3, {"season_idx": 11})
	assert_eq(int(w.db.get_record("people", w.offerer_id).attitude), -29, "AC-QS-51 -22 -8 stops at -29")

	# AC-QS-52: Board fail -> 0 attitude change, 16-season cooldown; Sect fail -> speaking member -15, 16-season cooldown.
	var wb: Dictionary = _world()
	var fb: String = wb.db.log_event(100, 1, "trade", "Board", [], [wb.pl1], [], {})
	_make_fx_plan_quest(wb, "q_bf", {"offer_kind": "board", "source_fact_id": fb})
	wb.svc.accept(wb.player, "q_bf", 0)
	wb.svc.abandon(wb.player, "q_bf", 0, 2, {"season_idx": 2})
	assert_eq(int(wb.db.get_record("people", wb.head_id).attitude), 0, "AC-QS-52 board fail 0 attitude")
	assert_false(wb.svc.is_fact_available(fb, 17), "AC-QS-52 board fail 16-season cd")
	assert_true(wb.svc.is_fact_available(fb, 18), "AC-QS-52 board fail open at +16")

	var fs: String = wb.db.log_event(100, 1, "trade", "Sect", [wb.offerer_id], [wb.pl1], [], {})
	_make_fx_plan_quest(wb, "q_sf", {"offer_kind": "sect", "offerer_id": wb.sect_id, "offerer_root_id": wb.offerer_id, "source_fact_id": fs})
	wb.svc.accept(wb.player, "q_sf", 0)
	wb.svc.abandon(wb.player, "q_sf", 0, 2, {"season_idx": 2})
	assert_eq(int(wb.db.get_record("people", wb.offerer_id).attitude), -15, "AC-QS-52 sect speaking member -15")
	assert_false(wb.svc.is_fact_available(fs, 17), "AC-QS-52 sect fail 16-season cd")

	# AC-QS-53 & AC-QS-54: Orphaned after 13 paid -> finishing pays floor(0.5*47)=23, no penalty; keeps slot; deadline -> Dropped; insolvent -> Dropped at once.
	var wo: Dictionary = _world()
	_make_fx_plan_quest(wo, "q_orph")
	wo.svc.accept(wo.player, "q_orph", 0)
	wo.svc.trigger_stage_event(wo.player, wo.sheet, RandomNumberGenerator.new(), "q_orph", {"season_idx": 1})
	var po: String = _add_pill(wo, wo.player.id)
	wo.svc.on_item_crafted(wo.player, po, 2)
	wo.svc.on_craft(wo.player, "q_orph", po, 0, 2, {"season_idx": 2})
	# Offerer dies naturally (purse settled via WorldMoney while preserving estate_at_death) -> Orphaned, keeps active slot.
	var off_rec_o: Dictionary = wo.db.get_record("people", wo.offerer_id)
	off_rec_o["estate_at_death"] = float(off_rec_o.get("linh_thach", 0.0))
	WorldMoney.settle_death(wo.gd, wo.db, wo.money, off_rec_o, "")
	off_rec_o["alive"] = false
	wo.svc.tick_season(wo.player, wo.sheet, 0, 3, {"season_idx": 3})
	assert_eq(str(wo.svc.get_quest("q_orph").state), "orphaned", "AC-QS-53 Orphaned")
	assert_eq(wo.svc.active_quests(wo.player.id).size(), 1, "AC-QS-54 Orphaned keeps active slot")
	var cash_before: int = wo.player.linh_thach
	var fin_o: Dictionary = wo.svc.on_deliver(wo.player, "q_orph", po, 1, 0, {"season_idx": 4})
	assert_eq(str(fin_o.state), "completed", "AC-QS-53 Orphaned finished -> Completed")
	assert_eq(int(fin_o.stage_paid), 23, "AC-QS-53 orphan payout floor(0.5 * 47) = 23")
	assert_eq(wo.player.linh_thach - cash_before, 23, "AC-QS-53 player received 23")
	assert_false(wo.svc.is_fact_available(wo.fact_id, 11), "AC-QS-47/98 Orphaned blocked at +7")
	assert_true(wo.svc.is_fact_available(wo.fact_id, 12), "AC-QS-47/98 Orphaned open at +8")
	assert_near(float(wo.money.season_check().gap), 0.0, 1e-6, "MoneyLedger gap == 0 after orphan payout")

	# Insolvent estate & fallen sect -> Dropped at once (AC-QS-54).
	var wi: Dictionary = _world()
	_make_fx_plan_quest(wi, "q_insolv")
	wi.svc.accept(wi.player, "q_insolv", 0)
	wi.db.get_record("people", wi.offerer_id)["alive"] = false
	wi.db.get_record("people", wi.offerer_id)["linh_thach"] = 0
	wi.db.get_record("people", wi.offerer_id)["estate_at_death"] = 0.0
	wi.db.get_record("sects", wi.sect_id)["status"] = "fallen"
	wi.svc.tick_season(wi.player, wi.sheet, 0, 1, {"season_idx": 1})
	assert_eq(str(wi.svc.get_quest("q_insolv").state), "dropped", "AC-QS-54 no estate/sect -> Dropped at once")

	# AC-QS-56: Player kills offerer -> Failed, no relationship change, NOT Orphaned.
	var wk: Dictionary = _world()
	_make_fx_plan_quest(wk, "q_kill_off")
	wk.svc.accept(wk.player, "q_kill_off", 0)
	wk.svc.on_person_death(wk.offerer_id, wk.player.id, 0, 1, {"season_idx": 1, "player": wk.player})
	assert_eq(str(wk.svc.get_quest("q_kill_off").state), "failed", "AC-QS-56 player kills offerer -> Failed")
	assert_eq(int(wk.db.get_record("people", wk.offerer_id).attitude), 0, "AC-QS-56 no relationship change on dead offerer")
	assert_eq(int(wk.db.get_record("people", wk.master_id).attitude), 0, "AC-QS-56 no relationship change")

	# AC-QS-57: Rule 8 order: offerer dies in completion season -> Completed (47 paid); dies in deadline season with stages left -> Orphaned then Dropped (never Lapsed).
	var w57a: Dictionary = _world()
	_make_fx_plan_quest(w57a, "q_57a", {
		"stages": [
			{"kind": "event", "window": 2, "place_id": w57a.pl1, "rewards": [{"type": "linh_thach", "amount": 4}]},
			{"kind": "craft", "item_class": "pill", "window": 3, "place_id": w57a.pl1, "rewards": [{"type": "linh_thach", "amount": 9}]},
			{"kind": "craft", "item_class": "pill", "window": 2, "place_id": w57a.pl1, "rewards": [{"type": "linh_thach", "amount": 47}]},
		]
	})
	w57a.svc.accept(w57a.player, "q_57a", 0)
	w57a.svc.trigger_stage_event(w57a.player, w57a.sheet, RandomNumberGenerator.new(), "q_57a", {"season_idx": 1})
	var p57_1: String = _add_pill(w57a, w57a.player.id)
	w57a.svc.on_item_crafted(w57a.player, p57_1, 2)
	w57a.svc.on_craft(w57a.player, "q_57a", p57_1, 0, 2, {"season_idx": 2})
	# In season 11, stage 3 craft item is ready AND offerer died naturally -> Step 1 completes BEFORE Step 2 orphaning!
	var p57_2: String = _add_pill(w57a, w57a.player.id)
	w57a.svc.on_item_crafted(w57a.player, p57_2, 11)
	w57a.db.get_record("people", w57a.offerer_id)["alive"] = false
	w57a.db.get_record("people", w57a.offerer_id)["estate_at_death"] = 500.0
	var c_before57: int = w57a.player.linh_thach
	w57a.svc.tick_season(w57a.player, w57a.sheet, 2, 3, {"season_idx": 11})
	assert_eq(str(w57a.svc.get_quest("q_57a").state), "completed", "AC-QS-57 completion stands when offerer dies in same season")
	assert_eq(w57a.player.linh_thach - c_before57, 47, "AC-QS-57 full 47 paid from estate/sect")

	var w57b: Dictionary = _world()
	_make_fx_plan_quest(w57b, "q_57b")
	w57b.svc.accept(w57b.player, "q_57b", 0)
	w57b.db.get_record("people", w57b.offerer_id)["alive"] = false
	w57b.db.get_record("people", w57b.offerer_id)["estate_at_death"] = 500.0
	w57b.svc.tick_season(w57b.player, w57b.sheet, 2, 3, {"season_idx": 11})
	assert_eq(str(w57b.svc.get_quest("q_57b").state), "dropped", "AC-QS-57 offerer dies in deadline season -> Dropped, never Lapsed")
	assert_eq(int(w57b.db.get_record("people", w57b.master_id).attitude), 0, "AC-QS-57 Dropped incurs no penalty")

	# AC-QS-58: Player dies with 3 active quests -> all Failed, 0 relationship change, none active.
	var w58: Dictionary = _world()
	for i in range(3):
		_make_fx_plan_quest(w58, "q_pd_%d" % i)
		w58.svc.accept(w58.player, "q_pd_%d" % i, 0)
	w58.svc.on_player_death(w58.player, 1, 0, {"season_idx": 4})
	assert_eq(w58.svc.active_quests(w58.player.id).size(), 0, "AC-QS-58 no active quests survive death")
	for i in range(3):
		assert_eq(str(w58.svc.get_quest("q_pd_%d" % i).state), "failed", "AC-QS-58 quest %d Failed" % i)
	assert_eq(int(w58.db.get_record("people", w58.offerer_id).attitude), 0, "AC-QS-58 no relationship change on player death")

	# AC-QS-59: Named unique item destroyed -> Failed; class item gone -> stays open then Lapsed.
	var w59: Dictionary = _world()
	var uniq_id: String = _add_pill(w59, w59.player.id)
	_make_fx_plan_quest(w59, "q_uniq", {
		"stages": [
			{"kind": "deliver", "item_id": uniq_id, "window": 2, "place_id": w59.pl1},
			{"kind": "event", "window": 2, "place_id": w59.pl1},
		]
	})
	w59.svc.accept(w59.player, "q_uniq", 0)
	w59.svc.on_item_destroyed(w59.player, uniq_id, 0, 1, {"season_idx": 1})
	assert_eq(str(w59.svc.get_quest("q_uniq").state), "failed", "AC-QS-59 unique item destroyed -> Failed")

	var cls_id: String = _add_pill(w59, w59.player.id)
	_make_fx_plan_quest(w59, "q_cls", {
		"stages": [
			{"kind": "deliver", "item_class": "pill", "window": 2, "place_id": w59.pl1},
			{"kind": "event", "window": 2, "place_id": w59.pl1},
		]
	})
	w59.svc.accept(w59.player, "q_cls", 0)
	w59.db.remove("items", cls_id)
	w59.svc.tick_season(w59.player, w59.sheet, 0, 1, {"season_idx": 1})
	assert_eq(str(w59.svc.get_quest("q_cls").state), "active", "AC-QS-59 class item gone stays open")
	w59.svc.tick_season(w59.player, w59.sheet, 1, 2, {"season_idx": 6})
	assert_eq(str(w59.svc.get_quest("q_cls").state), "lapsed", "AC-QS-59 class item eventually lapses at deadline")

	# AC-QS-61, AC-QS-62, AC-QS-63, AC-QS-69: Disambiguation (2 deliver quests + 1 item; 2 mission quests + 1 action with 0 income; post-accept craft).
	var w61: Dictionary = _world()
	_make_fx_plan_quest(w61, "q_d1", {"stages": [{"kind": "deliver", "item_class": "pill", "window": 2, "place_id": w61.pl1}, {"kind": "event", "window": 2, "place_id": w61.pl1}]})
	_make_fx_plan_quest(w61, "q_d2", {"stages": [{"kind": "deliver", "item_class": "pill", "window": 2, "place_id": w61.pl1}, {"kind": "event", "window": 2, "place_id": w61.pl1}]})
	w61.svc.accept(w61.player, "q_d1", 0)
	w61.svc.accept(w61.player, "q_d2", 0)
	var one_pill: String = _add_pill(w61, w61.player.id)
	assert_true(w61.svc.on_deliver(w61.player, "q_d1", one_pill, 0, 1, {"season_idx": 1}).ok, "AC-QS-61 first deliver takes item")
	assert_false(w61.svc.on_deliver(w61.player, "q_d2", one_pill, 0, 1, {"season_idx": 1}).ok, "AC-QS-61 same item cannot serve second quest")

	var w62: Dictionary = _world()
	_make_fx_plan_quest(w62, "q_m1", {"stages": [{"kind": "mission", "seasons": 1, "window": 2, "place_id": w62.pl1}, {"kind": "event", "window": 2, "place_id": w62.pl1}]})
	_make_fx_plan_quest(w62, "q_m2", {"stages": [{"kind": "mission", "seasons": 1, "window": 2, "place_id": w62.pl1}, {"kind": "event", "window": 2, "place_id": w62.pl1}]})
	w62.svc.accept(w62.player, "q_m1", 0)
	w62.svc.accept(w62.player, "q_m2", 0)
	var m_res: Dictionary = w62.svc.on_mission(w62.player, "q_m1", 0, 1, {"season_idx": 1})
	assert_true(bool(m_res.stage_completed), "AC-QS-62 chosen mission completes")
	assert_eq(int(m_res.mission_income), 0, "AC-QS-69 mission stage pays 0 mission income")
	assert_eq(int(w62.svc.get_quest("q_m2").stage), 1, "AC-QS-62 unchosen mission untouched")

	# AC-QS-63: craft item held BEFORE acceptance does NOT count; crafted AFTER acceptance DOES.
	var w63: Dictionary = _world()
	var old_pill: String = _add_pill(w63, w63.player.id)
	w63.svc.on_item_crafted(w63.player, old_pill, 1)
	_make_fx_plan_quest(w63, "q_cr", {"stages": [{"kind": "craft", "item_class": "pill", "window": 3, "place_id": w63.pl1}, {"kind": "event", "window": 2, "place_id": w63.pl1}]})
	w63.svc.accept(w63.player, "q_cr", 5)
	assert_false(w63.svc.on_craft(w63.player, "q_cr", old_pill, 1, 2, {"season_idx": 6}).ok, "AC-QS-63 pre-accept item rejected")
	w63.svc.tick_season(w63.player, w63.sheet, 1, 2, {"season_idx": 6})
	assert_eq(int(w63.svc.get_quest("q_cr").stage), 1, "AC-QS-63 tick ignores pre-accept item")
	var new_pill: String = _add_pill(w63, w63.player.id)
	w63.svc.on_item_crafted(w63.player, new_pill, 6)
	assert_true(w63.svc.on_craft(w63.player, "q_cr", new_pill, 1, 2, {"season_idx": 6}).ok, "AC-QS-63 post-accept item completes craft stage")


# --- AC-QS-55, 64..68, 71, 87..88, 136: Formula D lasting gains, StatSheet, Legendary above-cap, insight ---------

func test_ac_qs_55_64_to_68_71_87_88_136_formula_d_boons_legendary_and_insight() -> void:
	# AC-QS-66, AC-QS-67, AC-QS-71: two concurrent Major quests each planning 8 W at total 44 -> 1st pays 4 W, 2nd pays 0 W.
	var w: Dictionary = _world()
	w.player.quest_gain_total_w = 44.0
	var maj_stages := [
		{"kind": "craft", "window": 3, "place_id": w.pl1, "rewards": []},
		{"kind": "craft", "window": 3, "place_id": w.pl1, "rewards": []},
		{"kind": "craft", "window": 3, "place_id": w.pl1, "rewards": []},
		{"kind": "event", "window": 2, "place_id": w.pl1, "rewards": [{"type": "linh_thach", "amount": 20}]},
	]
	_make_fx_plan_quest(w, "q_maj1", {
		"tier": "major", "stages": maj_stages.duplicate(true),
		"rare_reward": {"type": "quest_boon", "title": "Kiếm Tâm Nhất Điểm", "mods": [{"stat": "attack_pct", "value": 8.0}]}
	})
	_make_fx_plan_quest(w, "q_maj2", {
		"tier": "major", "stages": maj_stages.duplicate(true),
		"rare_reward": {"type": "quest_boon", "title": "Thiết Bích Nhị Trọng", "mods": [{"stat": "defense_pct", "value": 8.0}]}
	})
	w.svc.accept(w.player, "q_maj1", 0)
	w.svc.accept(w.player, "q_maj2", 0)
	# Jump both to stage 4 (final) and finish q_maj1 then q_maj2.
	var q1: Dictionary = w.svc.get_quest("q_maj1")
	q1["stage"] = 4
	w.svc.put_quest(q1)
	var q2: Dictionary = w.svc.get_quest("q_maj2")
	q2["stage"] = 4
	w.svc.put_quest(q2)

	var r1: Dictionary = w.svc.trigger_stage_event(w.player, w.sheet, RandomNumberGenerator.new(), "q_maj1", {"season_idx": 1})
	assert_near(float(r1.payment.boon.paid_w), 4.0, 0.001, "AC-QS-67 first Major shrinks from 8 W to remaining 4 W")
	assert_near(w.player.quest_gain_total_w, 48.0, 0.001, "AC-QS-67 lifetime total now at 48 W cap")
	assert_eq(w.player.quest_boons.size(), 1, "AC-QS-67 one boon added")
	assert_near(float(w.player.quest_boons[0].mods[0].value), 4.0, 0.001, "AC-QS-67 attack_pct shrunk to +4.0")

	var r2: Dictionary = w.svc.trigger_stage_event(w.player, w.sheet, RandomNumberGenerator.new(), "q_maj2", {"season_idx": 2})
	assert_near(float(r2.payment.boon.paid_w), 0.0, 0.001, "AC-QS-67 second Major pays 0 W at cap")
	assert_eq(w.player.quest_boons.size(), 1, "AC-QS-67 no second boon added")

	# AC-QS-71: StatSheet KIND_QUEST_BOON + Character save/reload round-trip!
	var reloaded_c := Character.from_dict(w.player.to_dict())
	assert_near(reloaded_c.quest_gain_total_w, 48.0, 0.001, "AC-QS-71 quest_gain_total_w survives save/reload")
	assert_eq(reloaded_c.quest_boons.size(), 1, "AC-QS-71 quest_boons survives save/reload")
	var sheet_after := StatSheet.build(reloaded_c, w.gd, w.db, null)
	assert_near(sheet_after.total("attack_pct"), 4.0, 0.001, "AC-QS-71 StatSheet applies KIND_QUEST_BOON")
	var boon_sources: Array = sheet_after.sources("attack_pct").filter(func(s): return str(s.kind) == StatSheet.KIND_QUEST_BOON)
	assert_eq(boon_sources.size(), 1, "AC-QS-71 source kind == KIND_QUEST_BOON")

	# AC-QS-68: At 1 W room (< tree_point_w = 2.58), a 1-point tree gain pays 0.
	var w68: Dictionary = _world()
	w68.player.quest_gain_total_w = 47.0
	_make_fx_plan_quest(w68, "q_tp68", {
		"tier": "major", "stages": maj_stages.duplicate(true),
		"rare_reward": {"type": "tree_point", "tree_points": 1}
	})
	w68.svc.accept(w68.player, "q_tp68", 0)
	var qt68: Dictionary = w68.svc.get_quest("q_tp68")
	qt68["stage"] = 4
	w68.svc.put_quest(qt68)
	var r68: Dictionary = w68.svc.trigger_stage_event(w68.player, w68.sheet, RandomNumberGenerator.new(), "q_tp68", {"season_idx": 1})
	assert_eq(int(r68.payment.tree_points), 0, "AC-QS-68 < tree_point_w room pays 0 tree points")
	assert_eq(w68.player.tree_points, 0, "AC-QS-68 player tree_points unchanged")
	assert_near(w68.player.quest_gain_total_w, 47.0, 0.001, "AC-QS-68 total W unchanged")

	# AC-QS-55: Orphaned FX-MAJ pays NO lasting gain.
	var w55: Dictionary = _world()
	_make_fx_plan_quest(w55, "q_maj_orph", {
		"tier": "major", "stages": maj_stages.duplicate(true),
		"rare_reward": {"type": "quest_boon", "title": "Không Được Nhận", "mods": [{"stat": "attack_pct", "value": 8.0}]}
	})
	w55.svc.accept(w55.player, "q_maj_orph", 0)
	var q55: Dictionary = w55.svc.get_quest("q_maj_orph")
	q55["stage"] = 4
	w55.svc.put_quest(q55)
	w55.db.get_record("people", w55.offerer_id)["alive"] = false
	w55.db.get_record("people", w55.offerer_id)["estate_at_death"] = 1000.0
	w55.svc.tick_season(w55.player, w55.sheet, 0, 1, {"season_idx": 1})
	assert_eq(str(w55.svc.get_quest("q_maj_orph").state), "orphaned", "AC-QS-55 orphaned")
	w55.svc.trigger_stage_event(w55.player, w55.sheet, RandomNumberGenerator.new(), "q_maj_orph", {"season_idx": 2})
	assert_eq(w55.player.quest_boons.size(), 0, "AC-QS-55 Orphaned Major pays no lasting gain")
	assert_near(w55.player.quest_gain_total_w, 0.0, 0.001, "AC-QS-55 quest_gain_total_w remains 0")

	# AC-QS-87 & AC-QS-88: Two Legendary quests in same life each pay rarity-6 item unchanged; Orphaned Legendary pays no above-cap item.
	var wl: Dictionary = _world()
	wl.player.realm_index = 2  # Core Formation (normal cap 5, Legendary cap 6)
	var leg_stages := [
		{"kind": "craft", "window": 3, "place_id": wl.pl1, "rewards": []},
		{"kind": "craft", "window": 3, "place_id": wl.pl1, "rewards": []},
		{"kind": "craft", "window": 3, "place_id": wl.pl1, "rewards": []},
		{"kind": "craft", "window": 3, "place_id": wl.pl1, "rewards": []},
		{"kind": "event", "window": 2, "place_id": wl.pl1, "rewards": [{"type": "linh_thach", "amount": 500}]},
	]
	for idx in range(2):
		var qid: String = "q_leg_%d" % idx
		_make_fx_plan_quest(wl, qid, {
			"tier": "legendary", "realm_index": 2, "stages": leg_stages.duplicate(true),
			"rare_reward": {"type": "above_cap_item", "item_class": "artifact", "rarity": 6, "price": 5000}
		})
		wl.svc.accept(wl.player, qid, 0)
		var ql: Dictionary = wl.svc.get_quest(qid)
		ql["stage"] = 5
		wl.svc.put_quest(ql)
		var rl: Dictionary = wl.svc.trigger_stage_event(wl.player, wl.sheet, RandomNumberGenerator.new(), qid, {"season_idx": idx + 1})
		assert_eq(int(rl.payment.above_cap_item.rarity), 6, "AC-QS-87 Legendary #%d pays rarity-6 item unchanged" % (idx + 1))

	_make_fx_plan_quest(wl, "q_leg_orph", {
		"tier": "legendary", "realm_index": 2, "stages": leg_stages.duplicate(true),
		"rare_reward": {"type": "above_cap_item", "item_class": "artifact", "rarity": 6, "price": 5000}
	})
	wl.svc.accept(wl.player, "q_leg_orph", 0)
	var qlo: Dictionary = wl.svc.get_quest("q_leg_orph")
	qlo["stage"] = 5
	wl.svc.put_quest(qlo)
	wl.db.get_record("people", wl.offerer_id)["alive"] = false
	wl.db.get_record("people", wl.offerer_id)["estate_at_death"] = 50000.0
	wl.svc.tick_season(wl.player, wl.sheet, 1, 0, {"season_idx": 4})
	var rlo: Dictionary = wl.svc.trigger_stage_event(wl.player, wl.sheet, RandomNumberGenerator.new(), "q_leg_orph", {"season_idx": 5})
	assert_true((rlo.payment.above_cap_item as Dictionary).is_empty(), "AC-QS-88 Orphaned Legendary pays no above-cap item")

	# AC-QS-136: Active quest planning insight, player gains insight elsewhere before payment -> pays nothing, rest of final pay stands.
	var wi: Dictionary = _world()
	wi.player.realm_index = 3  # Nascent Soul
	wi.player.has_insight = false
	_make_fx_plan_quest(wi, "q_ins", {
		"tier": "major", "realm_index": 3, "stages": maj_stages.duplicate(true),
		"rare_reward": {"type": "insight"}
	})
	wi.svc.accept(wi.player, "q_ins", 0)
	var qi: Dictionary = wi.svc.get_quest("q_ins")
	qi["stage"] = 4
	wi.svc.put_quest(qi)
	wi.player.has_insight = true  # gained elsewhere before payment!
	var cash_i0: int = wi.player.linh_thach
	var ri: Dictionary = wi.svc.trigger_stage_event(wi.player, wi.sheet, RandomNumberGenerator.new(), "q_ins", {"season_idx": 1})
	assert_false(bool(ri.payment.insight), "AC-QS-136 insight pays nothing when already held")
	assert_eq(wi.player.linh_thach - cash_i0, 20, "AC-QS-136 rest of final pay stands")


# --- AC-QS-93..97, 99..100: if_target_lost (orphan/skip/drop), reload parity, FX-SKIP, place loss ----------------

func test_ac_qs_93_to_97_99_100_target_and_place_loss() -> void:
	# AC-QS-93: FX-PLAN stage 2 current, stage 3 recipient dies naturally -> orphan makes stage 2 last; drop -> Dropped keeping 4.
	var w1: Dictionary = _world()
	_make_fx_plan_quest(w1, "q_93_orph", {"outcomes": [{"on": "completed", "role": "offerer", "effect": "wealth", "amount_share": 0.10}]})
	w1.svc.accept(w1.player, "q_93_orph", 0)
	w1.svc.trigger_stage_event(w1.player, w1.sheet, RandomNumberGenerator.new(), "q_93_orph", {"season_idx": 1})
	var rec93: Dictionary = w1.db.get_record("people", w1.recipient_id)
	WorldMoney.settle_death(w1.gd, w1.db, w1.money, rec93, "")
	rec93["alive"] = false
	w1.svc.tick_season(w1.player, w1.sheet, 0, 2, {"season_idx": 2})
	assert_eq(str(w1.svc.get_quest("q_93_orph").state), "orphaned", "AC-QS-93 later target lost (orphan) -> Orphaned")
	# AC-QS-100: living offerer pays the orphan payout (floor(0.5*56*2/3)=18) when stage target was lost (+6 wealth outcome -> net -12).
	var off_cash0: float = float(w1.db.get_record("people", w1.offerer_id).linh_thach)
	var p93: String = _add_pill(w1, w1.player.id)
	w1.svc.on_item_crafted(w1.player, p93, 3)
	var fin93: Dictionary = w1.svc.on_craft(w1.player, "q_93_orph", p93, 0, 3, {"season_idx": 3})
	assert_eq(str(fin93.state), "completed", "AC-QS-93 stage 2 became last stage")
	assert_eq(int(fin93.stage_paid), 18, "AC-QS-93/100 orphan payout == 18")
	assert_eq(int(w1.db.get_record("people", w1.offerer_id).linh_thach), int(off_cash0) - 18 + 6, "AC-QS-100 living offerer paid orphan reward (-18) + wealth outcome (+6)")
	assert_near(float(w1.money.season_check().gap), 0.0, 1e-6, "AC-QS-100 living offerer MoneyLedger gap == 0")

	var w2: Dictionary = _world()
	_make_fx_plan_quest(w2, "q_93_drop")
	var qd: Dictionary = w2.svc.get_quest("q_93_drop")
	qd.plan.stages[2]["if_target_lost"] = "drop"
	w2.svc.put_quest(qd)
	w2.svc.accept(w2.player, "q_93_drop", 0)
	var cash_d0: int = w2.player.linh_thach
	w2.svc.trigger_stage_event(w2.player, w2.sheet, RandomNumberGenerator.new(), "q_93_drop", {"season_idx": 1})
	w2.db.get_record("people", w2.recipient_id)["alive"] = false
	w2.svc.tick_season(w2.player, w2.sheet, 0, 2, {"season_idx": 2})
	assert_eq(str(w2.svc.get_quest("q_93_drop").state), "dropped", "AC-QS-93 later target lost (drop) -> Dropped")
	assert_eq(w2.player.linh_thach, cash_d0 + 4, "AC-QS-93 paid 4 stays")
	assert_eq(int(w2.db.get_record("people", w2.offerer_id).attitude), 0, "AC-QS-93 no penalty")

	# AC-QS-94: current stage's own target dies -> Dropped at once for both orphan and drop.
	for clause in ["orphan", "drop"]:
		var w94: Dictionary = _world()
		_make_fx_plan_quest(w94, "q_94_" + clause, {
			"stages": [
				{"kind": "visit", "window": 2, "place_id": w94.pl1, "target_id": w94.recipient_id, "if_target_lost": clause},
				{"kind": "event", "window": 2, "place_id": w94.pl1},
			]
		})
		w94.svc.accept(w94.player, "q_94_" + clause, 0)
		w94.db.get_record("people", w94.recipient_id)["alive"] = false
		w94.svc.tick_season(w94.player, w94.sheet, 0, 1, {"season_idx": 1})
		assert_eq(str(w94.svc.get_quest("q_94_" + clause).state), "dropped", "AC-QS-94 current stage target dead (%s) -> Dropped" % clause)

	# AC-QS-95 & AC-QS-99: FX-SKIP (event, deliver[skip], craft, deliver -> pays 4, 4, 9, 58).
	var ws: Dictionary = _world()
	_make_fx_plan_quest(ws, "q_skip", {
		"stages": [
			{"kind": "event", "window": 2, "place_id": ws.pl1, "rewards": [{"type": "linh_thach", "amount": 4}]},
			{"kind": "deliver", "item_class": "pill", "window": 2, "place_id": ws.pl1, "target_id": ws.recipient_id, "if_target_lost": "skip", "rewards": [{"type": "linh_thach", "amount": 4}]},
			{"kind": "craft", "item_class": "pill", "window": 3, "place_id": ws.pl1, "rewards": [{"type": "linh_thach", "amount": 9}]},
			{"kind": "deliver", "item_class": "pill", "window": 2, "place_id": ws.pl1, "rewards": [{"type": "linh_thach", "amount": 58}]},
		]
	})
	ws.svc.accept(ws.player, "q_skip", 0)
	assert_eq(ws.svc.get_quest("q_skip").budget.stage_pays, [4, 4, 9, 58], "FX-SKIP pays 4, 4, 9, 58")
	# Kill recipient BEFORE stage 2 begins.
	ws.db.get_record("people", ws.recipient_id)["alive"] = false
	var s1_res: Dictionary = ws.svc.trigger_stage_event(ws.player, ws.sheet, RandomNumberGenerator.new(), "q_skip", {"season_idx": 1})
	assert_eq(int(ws.svc.get_quest("q_skip").stage), 3, "AC-QS-95 stage 2 auto-skipped, stage 3 starts")
	assert_eq(s1_res.skipped_stages, [2], "AC-QS-95 stage 2 recorded skipped")
	assert_eq(int(ws.svc.get_quest("q_skip").paid_total), 4, "AC-QS-95 stage 2 paid 0")
	assert_eq(int(ws.svc.get_quest("q_skip").budget.stage_pays[3]), 58, "AC-QS-95 final pay stays 58 (not 62)")

	# AC-QS-99: Offerer dies while stage 3 (craft, s'=2, S'=3) is current -> Orphaned, finishing pays floor(0.5*67*2/3) = 22.
	ws.db.get_record("people", ws.offerer_id)["alive"] = false
	ws.db.get_record("people", ws.offerer_id)["estate_at_death"] = 500.0
	ws.svc.tick_season(ws.player, ws.sheet, 0, 2, {"season_idx": 2})
	assert_eq(str(ws.svc.get_quest("q_skip").state), "orphaned", "AC-QS-99 orphaned at stage 3")
	var ps99: String = _add_pill(ws, ws.player.id)
	ws.svc.on_item_crafted(ws.player, ps99, 3)
	var fin99: Dictionary = ws.svc.on_craft(ws.player, "q_skip", ps99, 0, 3, {"season_idx": 3})
	assert_eq(int(fin99.stage_paid), 22, "AC-QS-99 orphan payout floor(0.5 * 67 * 2 / 3) = 22")

	# AC-QS-96 & AC-QS-97: Player kills stage target -> Failed (normal -15); reload after target loss applies same clause.
	var w96: Dictionary = _world()
	_make_fx_plan_quest(w96, "q_96")
	w96.svc.accept(w96.player, "q_96", 0)
	w96.svc.on_person_death(w96.recipient_id, w96.player.id, 0, 1, {"season_idx": 1, "player": w96.player})
	assert_eq(str(w96.svc.get_quest("q_96").state), "failed", "AC-QS-96 player kills stage target -> Failed")
	assert_eq(int(w96.db.get_record("people", w96.offerer_id).attitude), -15, "AC-QS-96 normal -15 relationship loss")

	var w97: Dictionary = _world()
	_make_fx_plan_quest(w97, "q_97")
	var q97: Dictionary = w97.svc.get_quest("q_97")
	q97.plan.stages[2]["if_target_lost"] = "drop"
	w97.svc.put_quest(q97)
	w97.svc.accept(w97.player, "q_97", 0)
	w97.db.get_record("people", w97.recipient_id)["alive"] = false
	var db97_a := WorldDB.from_dict(w97.db.to_dict())
	var db97_b := WorldDB.from_dict(w97.db.to_dict())
	var svc_a := _QuestService.new(w97.gd, db97_a, null, w97.items)
	var svc_b := _QuestService.new(w97.gd, db97_b, null, w97.items)
	svc_a.tick_season(w97.player, w97.sheet, 0, 1, {"season_idx": 1})
	svc_b.tick_season(w97.player, w97.sheet, 0, 1, {"season_idx": 1})
	assert_eq(str(svc_a.get_quest("q_97").state), str(svc_b.get_quest("q_97").state), "AC-QS-97 reload applies identical clause")
	assert_eq(str(svc_a.get_quest("q_97").state), "dropped", "AC-QS-97 frozen drop clause applied")

	# AC-QS-100: Current place removed -> Dropped; later place removed -> Orphaned; board quest orphaned -> holding sect pays.
	var w100: Dictionary = _world()
	_make_fx_plan_quest(w100, "q_p_cur", {
		"stages": [
			{"kind": "event", "window": 2, "place_id": w100.pl2},
			{"kind": "event", "window": 2, "place_id": w100.pl1},
		]
	})
	w100.svc.accept(w100.player, "q_p_cur", 0)
	w100.db.remove("places", w100.pl2)
	w100.svc.tick_season(w100.player, w100.sheet, 0, 1, {"season_idx": 1})
	assert_eq(str(w100.svc.get_quest("q_p_cur").state), "dropped", "AC-QS-100 current stage place lost -> Dropped")

	var w100b: Dictionary = _world()
	_make_fx_plan_quest(w100b, "q_p_lat", {
		"offer_kind": "board",
		"stages": [
			{"kind": "event", "window": 2, "place_id": w100b.pl1, "rewards": [{"type": "linh_thach", "amount": 4}]},
			{"kind": "event", "window": 2, "place_id": w100b.pl2, "rewards": [{"type": "linh_thach", "amount": 26}]},
		]
	})
	w100b.svc.accept(w100b.player, "q_p_lat", 0)
	w100b.db.remove("places", w100b.pl2)
	w100b.svc.tick_season(w100b.player, w100b.sheet, 0, 1, {"season_idx": 1})
	assert_eq(str(w100b.svc.get_quest("q_p_lat").state), "orphaned", "AC-QS-100 later stage place lost -> Orphaned")
	var tr0: float = float(w100b.db.get_record("sects", w100b.sect_id).treasury)
	w100b.svc.trigger_stage_event(w100b.player, w100b.sheet, RandomNumberGenerator.new(), "q_p_lat", {"season_idx": 2})
	assert_true(float(w100b.db.get_record("sects", w100b.sect_id).treasury) < tr0, "AC-QS-100 board sect treasury paid orphan reward")
	assert_near(float(w100b.money.season_check().gap), 0.0, 1e-6, "AC-QS-100 MoneyLedger conservation gap == 0")
