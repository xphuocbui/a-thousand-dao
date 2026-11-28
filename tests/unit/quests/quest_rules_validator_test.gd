extends DaoTestSuite
## Deterministic unit tests for Template Quests (#31) Wave 1 W1B:
## QuestRules (Formulas A-E), QuestValidator (load-time & reject-never-repair offer-time),
## QuestGenerator (keyed-stream draws, slot binding, parameter ranges, Legendary downgrade),
## and QuestBoard (3-slot refresh, Errand/Ordinary cap, zero-attitude, town-no-sect).
## Covers AC-QS-01..28, 30..33, 38..40, 46, 51, 64..66, 76..78, 82..86, 90..92, 95, 99,
## 101..104, 106..114, 118, 124..127, 131..135, 137..138, 140..144, 146..150.

const _QuestRules := preload("res://src/gameplay/quests/quest_rules.gd")
const _QuestValidator := preload("res://src/gameplay/quests/quest_validator.gd")
const _QuestGenerator := preload("res://src/gameplay/quests/quest_generator.gd")
const _QuestBoard := preload("res://src/gameplay/quests/quest_board.gd")


# --- Fixture helpers ----------------------------------------------------------------------------------------------

func _base_world() -> Dictionary:
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
	var pid: String = db.add("people", player.to_dict())
	player.id = pid

	var sect_id: String = db.add("sects", {
		"name": "Thanh Vân Tông", "status": "active", "hq_place_id": pl1,
		"leader_id": "", "members": [], "treasury": 50000
	})
	db.get_record("places", pl1)["holder"] = sect_id

	var head_id: String = _add_npc(db, "Vân Tông Chủ", pl1, sect_id, "tong_chu", 2, 0)
	db.get_record("sects", sect_id)["leader_id"] = head_id
	var master_id: String = _add_npc(db, "Trần Trưởng Lão", pl1, sect_id, "truong_lao", 1, 0)
	var offerer_id: String = _add_npc(db, "Lý Chấp Sự", pl1, sect_id, "noi_mon", 0, 0, master_id)
	var disciple_id: String = _add_npc(db, "Tiểu Minh", pl1, sect_id, "ngoai_mon", 0, 0, offerer_id)
	db.get_record("sects", sect_id)["members"] = [head_id, master_id, offerer_id, disciple_id]

	var rival_sect_id: String = db.add("sects", {
		"name": "Huyết Sát Môn", "status": "active", "hq_place_id": pl2,
		"leader_id": "", "members": [], "treasury": 40000
	})
	var adv_head_id: String = _add_npc(db, "Huyết Môn Chủ", pl2, rival_sect_id, "tong_chu", 2, 0)
	db.get_record("sects", rival_sect_id)["leader_id"] = adv_head_id
	var adv_master_id: String = _add_npc(db, "Huyết Sư Phụ", pl2, rival_sect_id, "truong_lao", 2, 0)
	var adv_id: String = _add_npc(db, "Huyết Đồ", pl2, rival_sect_id, "noi_mon", 1, 0, adv_master_id)
	db.get_record("sects", rival_sect_id)["members"] = [adv_head_id, adv_master_id, adv_id]

	var fact_id: String = db.log_event(
		100, 0, "grudge", "Huyết Đồ cướp linh thảo của Lý Chấp Sự.",
		[offerer_id, adv_id], [pl1, pl2], [], {"adversary_id": adv_id}
	)
	var fact: Dictionary = db.get_record("events", fact_id)
	var sheet := StatSheet.build(player, gd, db, TestFixtures.tree())
	return {
		"gd": gd, "db": db, "player": player, "sheet": sheet,
		"pl1": pl1, "pl2": pl2, "pl3": pl3,
		"sect_id": sect_id, "head_id": head_id, "master_id": master_id,
		"offerer_id": offerer_id, "disciple_id": disciple_id,
		"rival_sect_id": rival_sect_id, "adv_head_id": adv_head_id,
		"adv_master_id": adv_master_id, "adv_id": adv_id,
		"fact": fact,
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
	calling: String = "wanderer"
) -> String:
	var c := TestFixtures.character({"moc": 50.0}, 50, realm_idx, 0)
	c.name = npc_name
	c.location_id = place_id
	c.sect_id = sect_id
	c.sect_rank = sect_rank
	c.attitude = attitude
	c.master_id = master_id
	c.npc_traits = {"calling": calling, "personality": [], "fate": [], "gained": []}
	return db.add("people", c.to_dict())


func _fx_plan(w: Dictionary, overrides: Dictionary = {}) -> Dictionary:
	var plan := {
		"template_id": "fx_plan",
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
			{"kind": "craft", "window": 3, "place_id": w.pl1, "rewards": [{"type": "material", "value": 9}]},
			{"kind": "deliver", "window": 2, "place_id": w.pl1, "deliver_price": 20, "rewards": [{"type": "linh_thach", "amount": 8}, {"type": "artifact", "value": 39}]},
		],
		"outcomes": [
			{"on": "completed", "role": "offerer", "effect": "wealth", "amount_share": 0.30},
		],
	}
	for k in overrides.keys():
		plan[k] = overrides[k]
	return plan


# --- AC-QS-77, 78, 138: Golden tables & config bounds ------------------------------------------------------------

func test_ac_qs_77_golden_table_and_rules_defaults() -> void:
	var gd: GameData = game_data()
	assert_eq(_QuestValidator.validate_rules(gd), [], "shipped quest_rules.json validates with 0 errors")

	var expected_ir := [10, 80, 600, 4000, 30000]
	var expected_er := [80, 600, 5000, 40000, 300000]
	for r in range(5):
		assert_eq(_QuestRules.realm_income_Ir(gd, r), expected_ir[r], "AC-QS-77 I_r realm %d" % r)
		assert_eq(_QuestRules.realm_ceiling_Er(gd, r), expected_er[r], "AC-QS-77 E_r realm %d" % r)
	assert_near(_QuestRules.tree_point_w(gd), 2.58, 0.0001, "AC-QS-77 tree_point_w == 2.58")
	assert_eq(_QuestRules.hostile_threshold(gd), -30, "hostile_threshold == -30")
	assert_eq(_QuestRules.fail_relationship_floor(gd), -29, "AC-QS-77 fail floor == -29")


func test_ac_qs_78_138_rules_config_bounds() -> void:
	var gd: GameData = game_data()
	var base: Dictionary = _QuestRules.config(gd)

	# AC-QS-78: stage_reward_share [0.20, 0.40] and slack [0.30, 1.00]
	for good_s in [0.20, 0.40]:
		var d: Dictionary = base.duplicate(true)
		d["stage_reward_share"] = good_s
		assert_eq(_QuestValidator.validate_rules(gd, d), [], "stage_reward_share %.2f passes" % good_s)
	for bad_s in [0.19, 0.41]:
		var d: Dictionary = base.duplicate(true)
		d["stage_reward_share"] = bad_s
		assert_false(_QuestValidator.validate_rules(gd, d).is_empty(), "stage_reward_share %.2f fails" % bad_s)

	for good_sl in [0.30, 1.00]:
		var d: Dictionary = base.duplicate(true)
		d["slack"] = good_sl
		assert_eq(_QuestValidator.validate_rules(gd, d), [], "slack %.2f passes" % good_sl)
	for bad_sl in [0.29, 1.01]:
		var d: Dictionary = base.duplicate(true)
		d["slack"] = bad_sl
		assert_false(_QuestValidator.validate_rules(gd, d).is_empty(), "slack %.2f fails" % bad_sl)

	# AC-QS-138: stage_hold [0, 8], quest_boon_w [4, 12], quest_gain_cap_w [24, 60]
	for good_h in [0, 8]:
		var d: Dictionary = base.duplicate(true)
		d["stage_hold"] = good_h
		assert_eq(_QuestValidator.validate_rules(gd, d), [], "stage_hold %d passes" % good_h)
	for bad_h in [-1, 9]:
		var d: Dictionary = base.duplicate(true)
		d["stage_hold"] = bad_h
		assert_false(_QuestValidator.validate_rules(gd, d).is_empty(), "stage_hold %d fails" % bad_h)

	for good_bw in [4.0, 12.0]:
		var d: Dictionary = base.duplicate(true)
		d["quest_boon_w"] = good_bw
		assert_eq(_QuestValidator.validate_rules(gd, d), [], "quest_boon_w %.1f passes" % good_bw)
	for bad_bw in [3.9, 12.1]:
		var d: Dictionary = base.duplicate(true)
		d["quest_boon_w"] = bad_bw
		assert_false(_QuestValidator.validate_rules(gd, d).is_empty(), "quest_boon_w %.1f fails" % bad_bw)

	for good_cw in [24.0, 60.0]:
		var d: Dictionary = base.duplicate(true)
		d["quest_gain_cap_w"] = good_cw
		assert_eq(_QuestValidator.validate_rules(gd, d), [], "quest_gain_cap_w %.1f passes" % good_cw)
	for bad_cw in [23.9, 60.1]:
		var d: Dictionary = base.duplicate(true)
		d["quest_gain_cap_w"] = bad_cw
		assert_false(_QuestValidator.validate_rules(gd, d).is_empty(), "quest_gain_cap_w %.1f fails" % bad_cw)


# --- AC-QS-76, 118, 133, 134, 142, 143, 149: Shipped template library & load lint ---------------------------------

func test_ac_qs_76_118_133_134_142_143_149_shipped_templates_and_load_lint() -> void:
	var gd: GameData = game_data()
	var errs: Array = _QuestValidator.validate_templates(gd)
	assert_eq(errs, [], "100%% of shipped quest_templates.json passes load validation")

	var tpls: Array = _QuestRules.templates(gd)
	assert_true(tpls.size() >= 40, "shipped library has >= 40 authored templates (got %d)" % tpls.size())

	var seen_tiers: Dictionary = {}
	var seen_kinds: Dictionary = {}
	for t in tpls:
		seen_tiers[str(t.tier)] = int(seen_tiers.get(str(t.tier), 0)) + 1
		for st in Array(t.get("stages", [])):
			seen_kinds[str(st.kind)] = true
	for req_tier in ["errand", "ordinary", "major", "legendary"]:
		assert_true(int(seen_tiers.get(req_tier, 0)) >= 6, "tier %s has >= 6 templates" % req_tier)
	for req_kind in ["event", "visit", "deliver", "craft", "mission", "reach", "defeat"]:
		assert_true(seen_kinds.has(req_kind), "stage kind '%s' covered in templates" % req_kind)

	# AC-QS-149: template with BOTH reach and defeat loads cleanly; two reach stages rejected at load.
	var reach_defeat_tpl := {
		"id": "t_rd", "name": "Thử thách", "tier": "ordinary", "offer_kinds": ["person"],
		"fact_kinds": ["any"], "place_kinds": ["any"], "realm_min": 0, "realm_max": 4,
		"stake_text": "Cần rèn luyện.", "offer_text": ["Thử sức cùng đối thủ."],
		"slots": {}, "params": {},
		"stages": [
			{"kind": "reach", "target_level": 5, "window": 6, "title": "Đạt tầng 5", "text": ["Tu luyện."]},
			{"kind": "defeat", "window": 3, "title": "Tỉ thí", "text": ["Giao thủ."]},
		],
		"outcomes": [{"on": "completed", "role": "offerer", "effect": "wealth", "amount_share": 0.2}],
	}
	assert_eq(_QuestValidator.validate_template(gd, reach_defeat_tpl), [], "AC-QS-149 reach+defeat template loads")

	var two_reach_tpl: Dictionary = reach_defeat_tpl.duplicate(true)
	two_reach_tpl["stages"] = [
		{"kind": "reach", "target_level": 4, "window": 4, "title": "A", "text": ["A"]},
		{"kind": "reach", "target_level": 6, "window": 4, "title": "B", "text": ["B"]},
		{"kind": "event", "window": 2, "title": "C", "text": ["C"]},
	]
	assert_false(_QuestValidator.validate_template(gd, two_reach_tpl).is_empty(), "AC-QS-149 two reach rejected at load")

	# AC-QS-118: unknown outcome role or effect rejected at load.
	var bad_role: Dictionary = reach_defeat_tpl.duplicate(true)
	bad_role["outcomes"] = [{"on": "completed", "role": "stranger", "effect": "wealth", "amount_share": 0.2}]
	assert_false(_QuestValidator.validate_template(gd, bad_role).is_empty(), "AC-QS-118 unknown outcome role rejected")
	var bad_eff: Dictionary = reach_defeat_tpl.duplicate(true)
	bad_eff["outcomes"] = [{"on": "completed", "role": "offerer", "effect": "teleport", "amount": 1}]
	assert_false(_QuestValidator.validate_template(gd, bad_eff).is_empty(), "AC-QS-118 unknown outcome effect rejected")

	# AC-QS-133: person template with no completed gain for offerer's side rejected at load.
	var no_benefit: Dictionary = reach_defeat_tpl.duplicate(true)
	no_benefit["outcomes"] = []
	assert_false(_QuestValidator.validate_template(gd, no_benefit).is_empty(), "AC-QS-133 person template without offerer gain rejected")

	# AC-QS-134: board template with Major tier or relationship with sect head rejected at load.
	var board_major: Dictionary = reach_defeat_tpl.duplicate(true)
	board_major["tier"] = "major"
	board_major["offer_kinds"] = ["board"]
	board_major["stages"] = [
		{"kind": "event", "window": 2, "title": "1", "text": ["1"]},
		{"kind": "event", "window": 2, "title": "2", "text": ["2"]},
		{"kind": "event", "window": 2, "title": "3", "text": ["3"]},
		{"kind": "event", "window": 2, "title": "4", "text": ["4"]},
	]
	assert_false(_QuestValidator.validate_template(gd, board_major).is_empty(), "board Major template rejected at load")

	var board_rel := {
		"id": "t_brel", "name": "Bảng", "tier": "errand", "offer_kinds": ["board"],
		"fact_kinds": ["any"], "place_kinds": ["any"], "realm_min": 0, "realm_max": 4,
		"offer_text": ["Nhiệm vụ bảng."], "slots": {}, "params": {},
		"stages": [
			{"kind": "event", "window": 2, "title": "1", "text": ["1"]},
			{"kind": "event", "window": 2, "title": "2", "text": ["2"], "rewards": [{"type": "relationship", "role": "offerer", "amount": 5}]},
		],
		"outcomes": [],
	}
	assert_false(_QuestValidator.validate_template(gd, board_rel).is_empty(), "AC-QS-134 board template with head relationship rejected")

	# AC-QS-142, AC-QS-143: Errand deadline_max=12 with template_travel_max=4 -> window_sum 8 passes, 9 fails.
	var err_w8 := {
		"id": "t_ew8", "name": "Tạp vụ 8", "tier": "errand", "offer_kinds": ["board"],
		"fact_kinds": ["any"], "place_kinds": ["any"], "realm_min": 0, "realm_max": 4,
		"offer_text": ["Tạp vụ."], "slots": {}, "params": {},
		"stages": [
			{"kind": "event", "window": 4, "title": "1", "text": ["1"]},
			{"kind": "event", "window": 4, "title": "2", "text": ["2"]},
		],
		"outcomes": [],
	}
	assert_eq(_QuestValidator.validate_template(gd, err_w8), [], "AC-QS-142/143 Errand windows 8 + travel_max 4 = 12 loads")
	var err_w9: Dictionary = err_w8.duplicate(true)
	err_w9["stages"][1]["window"] = 5
	assert_false(_QuestValidator.validate_template(gd, err_w9).is_empty(), "AC-QS-142/143 Errand windows 9 + travel_max 4 = 13 rejected at load")


# --- AC-QS-22..28, 83: Formula A ---------------------------------------------------------------------------------

func test_ac_qs_22_to_28_83_formula_a_budgets_and_caps() -> void:
	var gd: GameData = game_data()

	# AC-QS-22: FX-PLAN at Qi Refining & Deity Transformation
	var fx_stages := [{"kind": "event", "window": 2}, {"kind": "craft", "window": 3}, {"kind": "deliver", "window": 2}]
	var b_qr: Dictionary = _QuestRules.compute_budget(gd, "ordinary", 0, fx_stages, 0)
	assert_eq(b_qr.S_plan, 4, "FX-PLAN S_plan")
	assert_eq(b_qr.B, 60, "AC-QS-22 Qi Refining B=60")
	assert_eq(b_qr.stage_pays, [4, 9, 47], "AC-QS-22 Qi Refining pays 4, 9, 47")
	assert_eq(b_qr.cash_max, 12, "FX-PLAN cash_max=12")
	assert_eq(b_qr.deliver_max, 30, "FX-PLAN deliver_max=30")

	var b_dt: Dictionary = _QuestRules.compute_budget(gd, "ordinary", 4, fx_stages, 0)
	assert_eq(b_dt.B, 180000, "AC-QS-22 Deity Trans B=180,000")
	assert_eq(b_dt.stage_pays, [13500, 27000, 139500], "AC-QS-22 Deity Trans pays 13500, 27000, 139500")

	# AC-QS-23: visit + event -> S_plan 1, B 15, pays 0, 15
	var b_ve: Dictionary = _QuestRules.compute_budget(gd, "ordinary", 0, [{"kind": "visit"}, {"kind": "event"}], 0)
	assert_eq(b_ve.S_plan, 1, "AC-QS-23 S_plan=1")
	assert_eq(b_ve.B, 15, "AC-QS-23 B=15")
	assert_eq(b_ve.stage_pays, [0, 15], "AC-QS-23 pays 0, 15")

	# AC-QS-24: Ordinary caps
	assert_eq(_QuestRules.compute_budget(gd, "ordinary", 0, [{"kind": "mission", "seasons": 4}, {"kind": "event"}], 0).B, 75, "AC-QS-24 QR S_plan 5 -> 75")
	assert_eq(_QuestRules.compute_budget(gd, "ordinary", 0, [{"kind": "mission", "seasons": 4}, {"kind": "craft"}], 0).B, 80, "AC-QS-24 QR S_plan 6 -> 80")
	assert_eq(_QuestRules.compute_budget(gd, "ordinary", 1, [{"kind": "mission", "seasons": 4}, {"kind": "event"}], 0).B, 600, "AC-QS-24 FE S_plan 5 -> 600")
	assert_eq(_QuestRules.compute_budget(gd, "ordinary", 1, [{"kind": "mission", "seasons": 4}, {"kind": "craft"}], 0).B, 600, "AC-QS-24 FE S_plan 6 -> 600")

	# AC-QS-25: Major caps & Deity Trans 5x craft
	var maj7 := [{"kind": "craft"}, {"kind": "craft"}, {"kind": "craft"}, {"kind": "event"}]
	var maj8 := [{"kind": "craft"}, {"kind": "craft"}, {"kind": "craft"}, {"kind": "event"}, {"kind": "deliver"}]
	var maj9 := [{"kind": "craft"}, {"kind": "craft"}, {"kind": "craft"}, {"kind": "craft"}, {"kind": "deliver"}]
	assert_eq(_QuestRules.compute_budget(gd, "major", 0, maj7, 0).B, 140, "AC-QS-25 Major QR 7 -> 140")
	var b_maj8: Dictionary = _QuestRules.compute_budget(gd, "major", 0, maj8, 0)
	assert_eq(b_maj8.B, 160, "AC-QS-25 Major QR 8 -> 160")
	assert_eq(b_maj8.stage_pays, [12, 12, 12, 6, 118], "FX-MAJ pays 12, 12, 12, 6, 118")
	assert_eq(_QuestRules.compute_budget(gd, "major", 0, maj9, 0).B, 160, "AC-QS-25 Major QR 9 -> 160")

	var dt_maj := [{"kind": "craft"}, {"kind": "craft"}, {"kind": "craft"}, {"kind": "craft"}, {"kind": "craft"}]
	var b_dt_maj: Dictionary = _QuestRules.compute_budget(gd, "major", 4, dt_maj, 0)
	assert_eq(b_dt_maj.B, 600000, "AC-QS-25 DT Major 5x2 -> 600,000")
	assert_eq(b_dt_maj.stage_pays, [36000, 36000, 36000, 36000, 456000], "AC-QS-25 DT Major pays")

	# AC-QS-26: FX-PLAN + travel 2
	var b_tr: Dictionary = _QuestRules.compute_budget(gd, "ordinary", 0, fx_stages, 2)
	var d_tr: Dictionary = _QuestRules.compute_deadline(gd, "ordinary", fx_stages, 2)
	assert_eq(b_tr.S_plan, 6, "AC-QS-26 S_plan=6")
	assert_eq(b_tr.B, 80, "AC-QS-26 B=80")
	assert_eq(b_tr.stage_pays, [4, 8, 68], "AC-QS-26 pays 4, 8, 68")
	assert_eq(d_tr.deadline, 14, "AC-QS-26 deadline=14")

	# AC-QS-83: Errand & Legendary caps
	assert_eq(_QuestRules.compute_budget(gd, "errand", 0, [{"kind": "craft"}, {"kind": "event"}], 0).B, 37, "AC-QS-83 Errand QR S_plan 3 -> 37")
	assert_eq(_QuestRules.compute_budget(gd, "errand", 0, [{"kind": "craft"}, {"kind": "craft"}], 0).B, 40, "AC-QS-83 Errand QR S_plan 4 -> 40")
	assert_eq(_QuestRules.compute_budget(gd, "legendary", 2, dt_maj, 0).B, 15000, "AC-QS-83 Legendary CF S_plan 10 -> 15000")
	assert_eq(_QuestRules.compute_budget(gd, "legendary", 2, dt_maj, 1).B, 15000, "AC-QS-83 Legendary CF S_plan 11 -> 15000")

	# AC-QS-27: Every realm, tier, n=2..5, s_i=0..4 -> sum(stage_pays) == B & non-final stage pay <= ceil * I_r * s_i
	var max_per_s := {"errand": 0.375, "ordinary": 0.45, "major": 0.60, "legendary": 0.75}
	for r_idx in range(5):
		var i_r: float = float(_QuestRules.realm_income_Ir(gd, r_idx))
		for tier in ["errand", "ordinary", "major", "legendary"]:
			for n in [2, 3, 4, 5]:
				for s_val in [1, 2, 4]:
					var st_arr: Array = [{"kind": "visit"}]
					for _k in range(n - 1):
						st_arr.append({"kind": "mission", "seasons": s_val})
					var res: Dictionary = _QuestRules.compute_budget(gd, tier, r_idx, st_arr, 0)
					var total_paid: int = 0
					for p_idx in range(res.stage_pays.size()):
						total_paid += int(res.stage_pays[p_idx])
						if p_idx < n - 1:
							var s_i: int = _QuestRules.stage_seasons(gd, st_arr[p_idx])
							if s_i > 0:
								assert_true(float(res.stage_pays[p_idx]) <= float(max_per_s[tier]) * i_r * float(s_i) + 0.001,
									"AC-QS-27 stage pay ceiling %s r=%d" % [tier, r_idx])
					assert_eq(total_paid, int(res.B), "AC-QS-27 pays sum to B (%s r=%d n=%d)" % [tier, r_idx, n])

	# AC-QS-28: tu_vi cap (Qi Ref 0.25 pass / 0.26 fail; Deity Trans 0.10 pass / 0.11 fail)
	var w: Dictionary = _base_world()
	var p_tv_ok: Dictionary = _fx_plan(w, {"tu_vi_total": 0.25})
	var p_tv_bad: Dictionary = _fx_plan(w, {"tu_vi_total": 0.26})
	assert_true(_QuestValidator.validate_plan(gd, w.db, w.player, w.sheet, p_tv_ok).ok, "AC-QS-28 QR tu_vi 0.25 passes")
	assert_false(_QuestValidator.validate_plan(gd, w.db, w.player, w.sheet, p_tv_bad).ok, "AC-QS-28 QR tu_vi 0.26 fails")
	var p_dt_ok: Dictionary = _fx_plan(w, {"realm_index": 4, "tu_vi_total": 0.10})
	var p_dt_bad: Dictionary = _fx_plan(w, {"realm_index": 4, "tu_vi_total": 0.11})
	assert_true(_QuestValidator.validate_plan(gd, w.db, w.player, w.sheet, p_dt_ok).ok, "AC-QS-28 DT tu_vi 0.10 passes")
	assert_false(_QuestValidator.validate_plan(gd, w.db, w.player, w.sheet, p_dt_bad).ok, "AC-QS-28 DT tu_vi 0.11 fails")


# --- AC-QS-30..33, 84: Formula B fight ratios --------------------------------------------------------------------

func test_ac_qs_30_to_33_84_formula_b_fight_ratios() -> void:
	var w: Dictionary = _base_world()
	var gd: GameData = w.gd
	w.player.realm_index = 3  # FX-NS
	var f_player: float = 1.41e7

	var check_ehp := func(tier: String, ehp: float) -> bool:
		var n_stages: int = 4 if tier == "major" else (5 if tier == "legendary" else 2)
		var stages: Array = [{"kind": "defeat", "window": 2, "place_id": w.pl1, "target_id": w.adv_id}]
		for _i in range(n_stages - 1):
			stages.append({"kind": "event", "window": 2, "place_id": w.pl1})
		var plan := _fx_plan(w, {"tier": tier, "realm_index": 3, "stages": stages})
		var opts := {"fight_power_fn": func(_st, _pl): return {"f_opp": 400.0 * ehp, "f_player": f_player}}
		return bool(_QuestValidator.validate_plan(gd, w.db, w.player, w.sheet, plan, opts).ok)

	# AC-QS-30
	assert_near(_QuestRules.fight_ratio(400.0 * 8000.0, f_player), 0.22695, 0.0001, "AC-QS-30 r=0.22695")
	assert_true(check_ehp.call("ordinary", 8000.0), "AC-QS-30 Ordinary accepts ehp 8000")
	assert_false(check_ehp.call("errand", 8000.0), "AC-QS-30 Errand rejects ehp 8000")

	# AC-QS-31
	assert_true(check_ehp.call("ordinary", 12337.5), "AC-QS-31 Ordinary accepts 0.35")
	assert_false(check_ehp.call("ordinary", 12338.0), "AC-QS-31 Ordinary rejects 0.350014")
	assert_false(check_ehp.call("ordinary", 14100.0), "AC-QS-31 Ordinary rejects 0.40")

	# AC-QS-32
	assert_true(check_ehp.call("major", 14100.0), "AC-QS-32 Major accepts 0.40")
	assert_true(check_ehp.call("major", 21150.0), "AC-QS-32 Major accepts 0.60")
	assert_false(check_ehp.call("major", 21151.0), "AC-QS-32 Major rejects 0.600028")

	# AC-QS-33 floor 0.02
	assert_true(check_ehp.call("ordinary", 705.0), "AC-QS-33 floor 0.02 passes")
	assert_false(check_ehp.call("ordinary", 704.0), "AC-QS-33 below floor 0.019972 rejected")

	# AC-QS-84 Errand 0.20/0.21, Legendary 0.80/0.81
	assert_true(check_ehp.call("errand", 7050.0), "AC-QS-84 Errand 0.20 passes")
	assert_false(check_ehp.call("errand", 7402.5), "AC-QS-84 Errand 0.21 rejected")
	assert_true(check_ehp.call("legendary", 28200.0), "AC-QS-84 Legendary 0.80 passes")
	assert_false(check_ehp.call("legendary", 28552.5), "AC-QS-84 Legendary 0.81 rejected")


# --- AC-QS-38..40, 85, 92, 101: Formula C deadlines & windows -----------------------------------------------------

func test_ac_qs_38_to_40_85_92_101_formula_c_deadlines_and_windows() -> void:
	var gd: GameData = game_data()
	var mk := func(ws: Array) -> Array:
		var arr: Array = []
		for x in ws:
			arr.append({"kind": "event", "window": x})
		return arr

	# AC-QS-38
	assert_eq(_QuestRules.compute_deadline(gd, "ordinary", mk.call([2, 2]), 0).deadline, 6, "AC-QS-38 (2,2)->6")
	assert_eq(_QuestRules.compute_deadline(gd, "ordinary", mk.call([2, 2, 3, 2, 2]), 0).deadline, 17, "AC-QS-38 (2,2,3,2,2)->17")
	assert_eq(_QuestRules.compute_deadline(gd, "ordinary", mk.call([1, 1]), 0).deadline, 3, "AC-QS-38 (1,1)->3")
	assert_eq(_QuestRules.compute_deadline(gd, "major", mk.call([1, 1, 1, 1]), 0).deadline, 6, "AC-QS-38 Major (1,1,1,1)->6")

	# AC-QS-39
	assert_eq(_QuestRules.compute_deadline(gd, "ordinary", mk.call([7, 6]), 0).deadline, 20, "AC-QS-39 Ordinary 13->20")
	assert_eq(_QuestRules.compute_deadline(gd, "ordinary", mk.call([7, 7]), 0).deadline, 20, "AC-QS-39 Ordinary 14->20")
	var ord20: Dictionary = _QuestRules.compute_deadline(gd, "ordinary", mk.call([10, 10]), 0)
	assert_eq(ord20.deadline, 20, "AC-QS-39 Ordinary 20->20")
	assert_true(ord20.ok, "AC-QS-39 Ordinary 20 ok")
	assert_false(_QuestRules.compute_deadline(gd, "ordinary", mk.call([11, 10]), 0).ok, "AC-QS-39 Ordinary 21 rejected")

	assert_eq(_QuestRules.compute_deadline(gd, "major", mk.call([6, 5, 5, 5]), 0).deadline, 32, "AC-QS-39 Major 21->32")
	var maj32: Dictionary = _QuestRules.compute_deadline(gd, "major", mk.call([8, 8, 8, 8]), 0)
	assert_eq(maj32.deadline, 32, "AC-QS-39 Major 32->32")
	assert_true(maj32.ok, "AC-QS-39 Major 32 ok")
	assert_false(_QuestRules.compute_deadline(gd, "major", mk.call([9, 8, 8, 8]), 0).ok, "AC-QS-39 Major 33 rejected")

	# AC-QS-40 slack 0.3
	assert_eq(_QuestRules.compute_deadline(gd, "ordinary", mk.call([4, 3]), 0, {"slack": 0.3}).deadline, 10, "AC-QS-40 slack 0.3, 7->10")
	assert_eq(_QuestRules.compute_deadline(gd, "ordinary", mk.call([5, 5]), 0, {"slack": 0.3}).deadline, 13, "AC-QS-40 slack 0.3, 10->13")

	# AC-QS-85 Errand & Legendary
	assert_eq(_QuestRules.compute_deadline(gd, "errand", mk.call([4, 4]), 0).deadline, 12, "AC-QS-85 Errand 8->12")
	assert_true(_QuestRules.compute_deadline(gd, "errand", mk.call([6, 6]), 0).ok, "AC-QS-85 Errand 12 ok")
	assert_false(_QuestRules.compute_deadline(gd, "errand", mk.call([7, 6]), 0).ok, "AC-QS-85 Errand 13 rejected")
	assert_eq(_QuestRules.compute_deadline(gd, "legendary", mk.call([6, 6, 5, 5, 5]), 0).deadline, 40, "AC-QS-85 Legendary 27->40")
	assert_true(_QuestRules.compute_deadline(gd, "legendary", mk.call([8, 8, 8, 8, 8]), 0).ok, "AC-QS-85 Legendary 40 ok")
	assert_false(_QuestRules.compute_deadline(gd, "legendary", mk.call([9, 8, 8, 8, 8]), 0).ok, "AC-QS-85 Legendary 41 rejected")
	assert_eq(_QuestRules.compute_deadline(gd, "legendary", mk.call([1, 1, 1, 1, 1]), 0).deadline, 8, "AC-QS-85 Legendary 1x5->8")

	# AC-QS-92 stage window bounds [s_i..12]
	var w: Dictionary = _base_world()
	var ev_w1: Dictionary = _fx_plan(w, {"stages": [{"kind": "event", "window": 1, "place_id": w.pl1}, {"kind": "event", "window": 2, "place_id": w.pl1}]})
	var ev_w0: Dictionary = _fx_plan(w, {"stages": [{"kind": "event", "window": 0, "place_id": w.pl1}, {"kind": "event", "window": 2, "place_id": w.pl1}]})
	assert_true(_QuestValidator.validate_plan(gd, w.db, w.player, w.sheet, ev_w1).ok, "AC-QS-92 event window 1 passes")
	assert_false(_QuestValidator.validate_plan(gd, w.db, w.player, w.sheet, ev_w0).ok, "AC-QS-92 event window 0 rejected")

	var cr_w1: Dictionary = _fx_plan(w, {"stages": [{"kind": "craft", "window": 1, "place_id": w.pl1}, {"kind": "event", "window": 2, "place_id": w.pl1}]})
	var cr_w2: Dictionary = _fx_plan(w, {"stages": [{"kind": "craft", "window": 2, "place_id": w.pl1}, {"kind": "event", "window": 2, "place_id": w.pl1}]})
	assert_false(_QuestValidator.validate_plan(gd, w.db, w.player, w.sheet, cr_w1).ok, "AC-QS-92 craft window 1 rejected")
	assert_true(_QuestValidator.validate_plan(gd, w.db, w.player, w.sheet, cr_w2).ok, "AC-QS-92 craft window 2 passes")

	var w12: Dictionary = _fx_plan(w, {"stages": [{"kind": "event", "window": 12, "place_id": w.pl1}, {"kind": "event", "window": 2, "place_id": w.pl1}]})
	var w13: Dictionary = _fx_plan(w, {"stages": [{"kind": "event", "window": 13, "place_id": w.pl1}, {"kind": "event", "window": 2, "place_id": w.pl1}]})
	assert_true(_QuestValidator.validate_plan(gd, w.db, w.player, w.sheet, w12).ok, "AC-QS-92 window 12 passes")
	assert_false(_QuestValidator.validate_plan(gd, w.db, w.player, w.sheet, w13).ok, "AC-QS-92 window 13 rejected")

	# AC-QS-101: defeat hold extends deadline past deadline_max (12 + 4 = 16)
	var err_dl: int = _QuestRules.compute_deadline(gd, "errand", mk.call([4, 4]), 0).deadline
	var hold_max: int = int(_QuestRules.config(gd).stage_hold)
	assert_eq(err_dl + hold_max, 16, "AC-QS-101 Errand deadline 12 + stage_hold 4 == 16")


# --- AC-QS-14..21, 91, 95: Plan validation boundaries ------------------------------------------------------------

func test_ac_qs_14_to_21_91_95_plan_validation_boundaries() -> void:
	var w: Dictionary = _base_world()
	var gd: GameData = w.gd

	# AC-QS-14: stage counts & unknown kind
	var st_n := func(tier: String, n: int, realm_i: int = 0) -> bool:
		var arr: Array = []
		for _i in range(n):
			arr.append({"kind": "event", "window": 2, "place_id": w.pl1})
		return bool(_QuestValidator.validate_plan(gd, w.db, w.player, w.sheet, _fx_plan(w, {"tier": tier, "realm_index": realm_i, "stages": arr})).ok)

	assert_true(st_n.call("ordinary", 2), "AC-QS-14 n=2 passes")
	assert_true(st_n.call("ordinary", 5), "AC-QS-14 n=5 passes")
	assert_false(st_n.call("ordinary", 1), "AC-QS-14 n=1 rejected")
	assert_false(st_n.call("ordinary", 6), "AC-QS-14 n=6 rejected")
	assert_true(st_n.call("errand", 3), "AC-QS-14 Errand 3 passes")
	assert_false(st_n.call("errand", 4), "AC-QS-14 Errand 4 rejected")
	assert_true(st_n.call("major", 4), "AC-QS-14 Major 4 passes")
	assert_false(st_n.call("major", 3), "AC-QS-14 Major 3 rejected")
	assert_true(st_n.call("legendary", 5, 2), "AC-QS-14 Legendary 5 passes")
	assert_false(st_n.call("legendary", 4, 2), "AC-QS-14 Legendary 4 rejected")
	assert_false(_QuestValidator.validate_plan(gd, w.db, w.player, w.sheet,
		_fx_plan(w, {"stages": [{"kind": "unknown_kind", "window": 2, "place_id": w.pl1}, {"kind": "event", "window": 2, "place_id": w.pl1}]})).ok,
		"AC-QS-14 unknown stage kind rejected")

	# AC-QS-15: two reach rejected; visit+reach rejected; event+reach passes
	var r_opts := {"reach_estimate_fn": func(_st, _pl): return 3.0}
	var two_r: Dictionary = _fx_plan(w, {"stages": [
		{"kind": "reach", "target_level": 5, "window": 4, "place_id": w.pl1},
		{"kind": "reach", "target_level": 8, "window": 4, "place_id": w.pl1},
		{"kind": "event", "window": 2, "place_id": w.pl1},
	]})
	var vis_r: Dictionary = _fx_plan(w, {"stages": [
		{"kind": "visit", "window": 2, "place_id": w.pl1},
		{"kind": "reach", "target_level": 5, "window": 4, "place_id": w.pl1},
	]})
	var ev_r: Dictionary = _fx_plan(w, {"stages": [
		{"kind": "event", "window": 2, "place_id": w.pl1},
		{"kind": "reach", "target_level": 5, "window": 4, "place_id": w.pl1},
	]})
	assert_false(_QuestValidator.validate_plan(gd, w.db, w.player, w.sheet, two_r, r_opts).ok, "AC-QS-15 two reach rejected")
	assert_false(_QuestValidator.validate_plan(gd, w.db, w.player, w.sheet, vis_r, r_opts).ok, "AC-QS-15 visit+reach rejected")
	assert_true(_QuestValidator.validate_plan(gd, w.db, w.player, w.sheet, ev_r, r_opts).ok, "AC-QS-15 event+reach passes")

	# AC-QS-16: reach estimate 6 -> window 6 passes, 5 rejected; already met rejected
	var stub6 := {"reach_estimate_fn": func(_st, _pl): return 6.0}
	var r_w6: Dictionary = _fx_plan(w, {"stages": [{"kind": "event", "window": 2, "place_id": w.pl1}, {"kind": "reach", "target_level": 10, "window": 6, "place_id": w.pl1}]})
	var r_w5: Dictionary = _fx_plan(w, {"stages": [{"kind": "event", "window": 2, "place_id": w.pl1}, {"kind": "reach", "target_level": 10, "window": 5, "place_id": w.pl1}]})
	var r_met: Dictionary = _fx_plan(w, {"stages": [{"kind": "event", "window": 2, "place_id": w.pl1}, {"kind": "reach", "target_level": 1, "window": 6, "place_id": w.pl1}]})
	assert_true(_QuestValidator.validate_plan(gd, w.db, w.player, w.sheet, r_w6, stub6).ok, "AC-QS-16 window 6 passes estimate 6")
	assert_false(_QuestValidator.validate_plan(gd, w.db, w.player, w.sheet, r_w5, stub6).ok, "AC-QS-16 window 5 fails estimate 6")
	assert_false(_QuestValidator.validate_plan(gd, w.db, w.player, w.sheet, r_met, stub6).ok, "AC-QS-16 reach already met rejected")

	# AC-QS-17: unregistered entity rejected
	var unreg: Dictionary = _fx_plan(w, {"stages": [{"kind": "visit", "window": 2, "place_id": "l9999"}, {"kind": "event", "window": 2, "place_id": w.pl1}]})
	assert_false(_QuestValidator.validate_plan(gd, w.db, w.player, w.sheet, unreg).ok, "AC-QS-17 unregistered place rejected")

	# AC-QS-18, 19, 20: total 60/61, craft stage 9/10, cash 12/13, total 50/60, deliver 30/31
	assert_true(_QuestValidator.validate_plan(gd, w.db, w.player, w.sheet, _fx_plan(w)).ok, "AC-QS-18 FX-PLAN 60 passes")
	assert_false(_QuestValidator.validate_plan(gd, w.db, w.player, w.sheet, _fx_plan(w, {"total_value": 61})).ok, "AC-QS-18 total 61 rejected")
	var craft_10: Dictionary = _fx_plan(w)
	craft_10["stages"][1]["rewards"] = [{"type": "material", "value": 10}]
	assert_false(_QuestValidator.validate_plan(gd, w.db, w.player, w.sheet, craft_10).ok, "AC-QS-18 craft stage 10 (>9) rejected")

	assert_true(_QuestValidator.validate_plan(gd, w.db, w.player, w.sheet, _fx_plan(w, {"cash_total": 12})).ok, "AC-QS-19 cash 12 passes")
	assert_false(_QuestValidator.validate_plan(gd, w.db, w.player, w.sheet, _fx_plan(w, {"cash_total": 13})).ok, "AC-QS-19 cash 13 rejected")
	var under_b: Dictionary = _fx_plan(w)
	under_b["stages"][2]["rewards"] = [{"type": "linh_thach", "amount": 8}, {"type": "artifact", "value": 29}]
	assert_true(_QuestValidator.validate_plan(gd, w.db, w.player, w.sheet, under_b).ok, "AC-QS-19 total 50 of B 60 passes")

	var del_30: Dictionary = _fx_plan(w)
	del_30["stages"][2]["deliver_price"] = 30
	assert_true(_QuestValidator.validate_plan(gd, w.db, w.player, w.sheet, del_30).ok, "AC-QS-20 deliver 30 passes")
	var del_31: Dictionary = _fx_plan(w)
	del_31["stages"][2]["deliver_price"] = 31
	assert_false(_QuestValidator.validate_plan(gd, w.db, w.player, w.sheet, del_31).ok, "AC-QS-20 deliver 31 rejected")

	# AC-QS-21: Errand/Ordinary with tree point or boon rejected
	assert_false(_QuestValidator.validate_plan(gd, w.db, w.player, w.sheet,
		_fx_plan(w, {"tier": "ordinary", "rare_reward": {"type": "tree_point", "tree_points": 1}})).ok, "AC-QS-21 Ordinary tree_point rejected")
	assert_false(_QuestValidator.validate_plan(gd, w.db, w.player, w.sheet,
		_fx_plan(w, {"tier": "errand", "stages": [{"kind": "event", "window": 2, "place_id": w.pl1}, {"kind": "event", "window": 2, "place_id": w.pl1}],
			"rare_reward": {"type": "quest_boon", "mods": [{"stat": "attack_pct", "value": 4.0}]}})).ok, "AC-QS-21 Errand boon rejected")

	# AC-QS-91: 3 non-final pass / 4 fail; 6 final pass / 7 fail; multi-key quest_boon counts 1; outcomes count 0
	var maj_stages := [
		{"kind": "craft", "window": 3, "place_id": w.pl1, "rewards": [
			{"type": "material", "value": 3}, {"type": "herb", "value": 3}, {"type": "access", "label": "A"}
		]},
		{"kind": "craft", "window": 3, "place_id": w.pl1, "rewards": []},
		{"kind": "craft", "window": 3, "place_id": w.pl1, "rewards": []},
		{"kind": "deliver", "window": 2, "place_id": w.pl1, "rewards": [
			{"type": "linh_thach", "amount": 10},
			{"type": "material", "value": 20},
			{"type": "herb", "value": 20},
			{"type": "relationship", "role": "offerer", "amount": 10},
			{"type": "access", "label": "B"},
			{"type": "quest_boon", "mods": [{"stat": "attack_pct", "value": 2.0}, {"stat": "defense_pct", "value": 2.0}, {"stat": "khi_huyet_pct", "value": 2.0}]},
		]},
	]
	var p91: Dictionary = _fx_plan(w, {"tier": "major", "stages": maj_stages})
	assert_true(_QuestValidator.validate_plan(gd, w.db, w.player, w.sheet, p91).ok, "AC-QS-91 3 non-final & 6 final with 3-key boon passes")
	var p91_nf4: Dictionary = p91.duplicate(true)
	p91_nf4["stages"][0]["rewards"].append({"type": "tu_vi", "amount": 0.05})
	assert_false(_QuestValidator.validate_plan(gd, w.db, w.player, w.sheet, p91_nf4).ok, "AC-QS-91 4 non-final rejected")
	var p91_f7: Dictionary = p91.duplicate(true)
	p91_f7["stages"][3]["rewards"].append({"type": "tu_vi", "amount": 0.05})
	assert_false(_QuestValidator.validate_plan(gd, w.db, w.player, w.sheet, p91_f7).ok, "AC-QS-91 7 final rejected")

	# AC-QS-95: skip on last stage rejected; unknown if_target_lost rejected
	var skip_last: Dictionary = _fx_plan(w)
	skip_last["stages"][2]["if_target_lost"] = "skip"
	assert_false(_QuestValidator.validate_plan(gd, w.db, w.player, w.sheet, skip_last).ok, "AC-QS-95 skip on last stage rejected")
	var bad_lost: Dictionary = _fx_plan(w)
	bad_lost["stages"][0]["if_target_lost"] = "ignore"
	assert_false(_QuestValidator.validate_plan(gd, w.db, w.player, w.sheet, bad_lost).ok, "AC-QS-95 unknown if_target_lost rejected")


# --- AC-QS-64..66, 86, 90, 99, 135, 137: Rare rewards, rarity 6, insight, recipe, orphan payout -------------------

func test_ac_qs_64_to_66_86_90_99_135_137_rare_rewards_and_orphan_payout() -> void:
	var w: Dictionary = _base_world()
	var gd: GameData = w.gd
	var maj_stages := [
		{"kind": "craft", "window": 3, "place_id": w.pl1},
		{"kind": "craft", "window": 3, "place_id": w.pl1},
		{"kind": "craft", "window": 3, "place_id": w.pl1},
		{"kind": "event", "window": 2, "place_id": w.pl1},
	]

	# AC-QS-64: 8 W passes, 8.01 rejected, 2nd lasting gain rejected
	var b8: Dictionary = _fx_plan(w, {"tier": "major", "stages": maj_stages, "rare_reward": {"type": "quest_boon", "mods": [{"stat": "attack_pct", "value": 8.0}]}})
	var b801: Dictionary = _fx_plan(w, {"tier": "major", "stages": maj_stages, "rare_reward": {"type": "quest_boon", "mods": [{"stat": "attack_pct", "value": 8.01}]}})
	assert_true(_QuestValidator.validate_plan(gd, w.db, w.player, w.sheet, b8).ok, "AC-QS-64 8 W passes")
	assert_false(_QuestValidator.validate_plan(gd, w.db, w.player, w.sheet, b801).ok, "AC-QS-64 8.01 W rejected")
	var two_boons: Dictionary = b8.duplicate(true)
	two_boons["stages"][3]["rewards"] = [{"type": "tree_point", "amount": 1}]
	assert_false(_QuestValidator.validate_plan(gd, w.db, w.player, w.sheet, two_boons).ok, "AC-QS-64 2nd lasting gain rejected")

	# AC-QS-65: tree_point_w = 2.58 -> 3 points = 7.74 W <= 8.0; QR 1 passes / 2 fails; DT 3 passes / 4 fails
	assert_near(_QuestRules.boon_weight(gd, {"tree_points": 3}), 7.74, 0.0001, "AC-QS-65 3 * 2.58 = 7.74 W")
	assert_true(_QuestValidator.validate_plan(gd, w.db, w.player, w.sheet,
		_fx_plan(w, {"tier": "major", "realm_index": 0, "stages": maj_stages, "rare_reward": {"type": "tree_point", "tree_points": 1}})).ok, "AC-QS-65 QR 1 tp passes")
	assert_false(_QuestValidator.validate_plan(gd, w.db, w.player, w.sheet,
		_fx_plan(w, {"tier": "major", "realm_index": 0, "stages": maj_stages, "rare_reward": {"type": "tree_point", "tree_points": 2}})).ok, "AC-QS-65 QR 2 tp rejected")
	assert_true(_QuestValidator.validate_plan(gd, w.db, w.player, w.sheet,
		_fx_plan(w, {"tier": "major", "realm_index": 4, "stages": maj_stages, "rare_reward": {"type": "tree_point", "tree_points": 3}})).ok, "AC-QS-65 DT 3 tp passes")
	assert_false(_QuestValidator.validate_plan(gd, w.db, w.player, w.sheet,
		_fx_plan(w, {"tier": "major", "realm_index": 4, "stages": maj_stages, "rare_reward": {"type": "tree_point", "tree_points": 4}})).ok, "AC-QS-65 DT 4 tp rejected")

	# AC-QS-66: room at 40 -> 8, 44 -> 4, 48 -> 0
	assert_near(_QuestRules.lasting_gain_room(gd, 40.0).allowed_w, 8.0, 0.0001, "AC-QS-66 total 40 -> 8")
	assert_near(_QuestRules.lasting_gain_room(gd, 44.0).allowed_w, 4.0, 0.0001, "AC-QS-66 total 44 -> 4")
	assert_near(_QuestRules.lasting_gain_room(gd, 48.0).allowed_w, 0.0, 0.0001, "AC-QS-66 total 48 -> 0")

	# AC-QS-86: rarity 6 on Legendary Core Formation inside B passes; 2nd, over-B, or Major rejected
	var leg_stages := [
		{"kind": "craft", "window": 3, "place_id": w.pl1},
		{"kind": "craft", "window": 3, "place_id": w.pl1},
		{"kind": "craft", "window": 3, "place_id": w.pl1},
		{"kind": "craft", "window": 3, "place_id": w.pl1},
		{"kind": "craft", "window": 3, "place_id": w.pl1},
	]
	var leg_r6: Dictionary = _fx_plan(w, {
		"tier": "legendary", "realm_index": 2, "stages": leg_stages,
		"rare_reward": {"type": "above_cap_item", "rarity": 6, "price": 10000}
	})
	assert_true(_QuestValidator.validate_plan(gd, w.db, w.player, w.sheet, leg_r6).ok, "AC-QS-86 Legendary CF 1 rarity-6 item passes")
	var leg_r6_over_b: Dictionary = leg_r6.duplicate(true)
	leg_r6_over_b["rare_reward"]["price"] = 15001
	assert_false(_QuestValidator.validate_plan(gd, w.db, w.player, w.sheet, leg_r6_over_b).ok, "AC-QS-86 above-cap item over B rejected")
	var leg_r6_two: Dictionary = leg_r6.duplicate(true)
	leg_r6_two["stages"][4]["rewards"] = [{"type": "above_cap_item", "rarity": 6, "price": 1000}]
	assert_false(_QuestValidator.validate_plan(gd, w.db, w.player, w.sheet, leg_r6_two).ok, "AC-QS-86 second above-cap item rejected")
	var maj_r6: Dictionary = leg_r6.duplicate(true)
	maj_r6["tier"] = "major"
	assert_false(_QuestValidator.validate_plan(gd, w.db, w.player, w.sheet, maj_r6).ok, "AC-QS-86 Major with rarity-6 rejected")

	# AC-QS-135: insight ONLY in Nascent Soul, !has_insight, Major/Legendary, B unchanged, max 1
	w.player.realm_index = 3
	w.player.has_insight = false
	var ins_ok: Dictionary = _fx_plan(w, {"tier": "major", "realm_index": 3, "stages": maj_stages, "rare_reward": {"type": "insight"}})
	var ins_res: Dictionary = _QuestValidator.validate_plan(gd, w.db, w.player, w.sheet, ins_ok)
	assert_true(ins_res.ok, "AC-QS-135 NS Major insight passes")
	assert_eq(ins_res.budget.B, _QuestRules.compute_budget(gd, "major", 3, maj_stages, 0).B, "AC-QS-135 insight does not charge B")

	w.player.has_insight = true
	assert_false(_QuestValidator.validate_plan(gd, w.db, w.player, w.sheet, ins_ok).ok, "AC-QS-135 player holding insight rejected")
	w.player.has_insight = false
	assert_false(_QuestValidator.validate_plan(gd, w.db, w.player, w.sheet,
		_fx_plan(w, {"tier": "major", "realm_index": 2, "stages": maj_stages, "rare_reward": {"type": "insight"}})).ok, "AC-QS-135 Core Formation insight rejected")
	assert_false(_QuestValidator.validate_plan(gd, w.db, w.player, w.sheet,
		_fx_plan(w, {"tier": "ordinary", "realm_index": 3, "rare_reward": {"type": "insight"}})).ok, "AC-QS-135 Ordinary insight rejected")
	var two_ins: Dictionary = ins_ok.duplicate(true)
	two_ins["stages"][3]["rewards"] = [{"type": "insight"}]
	assert_false(_QuestValidator.validate_plan(gd, w.db, w.player, w.sheet, two_ins).ok, "AC-QS-135 second insight rejected")

	# AC-QS-137: recipe rejected until Open Question 11
	assert_false(_QuestValidator.validate_plan(gd, w.db, w.player, w.sheet,
		_fx_plan(w, {"tier": "major", "realm_index": 3, "stages": maj_stages, "rare_reward": {"type": "recipe", "recipe_id": "tu_khi_dan"}})).ok,
		"AC-QS-137 recipe rare_reward rejected")
	var st_rec: Dictionary = _fx_plan(w, {"tier": "major", "realm_index": 3, "stages": maj_stages})
	st_rec["stages"][3]["rewards"] = [{"type": "recipe", "recipe_id": "tu_khi_dan"}]
	assert_false(_QuestValidator.validate_plan(gd, w.db, w.player, w.sheet, st_rec).ok, "AC-QS-137 recipe stage effect rejected")

	# AC-QS-90, AC-QS-99: orphan payout
	assert_eq(_QuestRules.orphan_payout(gd, 160, 2, 8), 20, "AC-QS-90 FX-MAJ stage 1 orphan payout == 20")
	assert_eq(_QuestRules.orphan_payout(gd, 118, 1, 1), 59, "AC-QS-90 FX-MAJ last stage orphan payout == 59")
	assert_eq(_QuestRules.orphan_payout(gd, 100, 0, 5), 10, "AC-QS-90 visit s_i=0 uses s'=1 -> 10")
	assert_eq(_QuestRules.orphan_payout(gd, 67, 2, 3), 22, "AC-QS-99 FX-SKIP unpaid 67 s'=2 S'=3 -> 22")


# --- AC-QS-51, 102..114, 124..127, 131..134, 140..141, 144: Outcomes & Formula E reactions ------------------------

func test_ac_qs_51_102_to_114_124_to_127_131_132_140_141_144_outcomes_and_reactions() -> void:
	var w: Dictionary = _base_world()
	var gd: GameData = w.gd
	var db: WorldDB = w.db

	# AC-QS-51: fail floor -29
	assert_eq(_QuestRules.apply_fail_floor(0, -15, gd), -15, "AC-QS-51 0 -15 -> -15")
	assert_eq(_QuestRules.apply_fail_floor(-15, -15, gd), -14, "AC-QS-51 -15 -15 -> -29 (delta -14)")
	assert_eq(_QuestRules.apply_fail_floor(-21, -8, gd), -8, "AC-QS-51 -21 -8 -> -29")
	assert_eq(_QuestRules.apply_fail_floor(-22, -8, gd), -7, "AC-QS-51 -22 -8 -> -29 (delta -7)")
	for low_att in [-29, -30, -40]:
		assert_eq(_QuestRules.apply_fail_floor(low_att, -15, gd), 0, "AC-QS-51 %d unchanged" % low_att)

	# AC-QS-102: offerer stake (named, master named, vs unrelated)
	var unrelated_fact := {"id": "e_unrel", "type": "trade", "people": [w.adv_id], "places": [w.pl2], "data": {}}
	var master_fact := {"id": "e_mast", "type": "trade", "people": [w.master_id], "places": [w.pl1], "data": {}}
	assert_false(_QuestValidator.offerer_has_stake_in_fact(db, w.offerer_id, w.offerer_id, unrelated_fact), "AC-QS-102 unrelated NPC has no stake")
	assert_true(_QuestValidator.offerer_has_stake_in_fact(db, w.offerer_id, w.offerer_id, master_fact), "AC-QS-102 NPC whose master is named has stake")

	# AC-QS-103: attitude -30 rejected, -29 passes
	db.get_record("people", w.offerer_id)["attitude"] = -30
	assert_false(_QuestValidator.validate_plan(gd, db, w.player, w.sheet, _fx_plan(w)).ok, "AC-QS-103 attitude -30 rejected")
	db.get_record("people", w.offerer_id)["attitude"] = -29
	assert_true(_QuestValidator.validate_plan(gd, db, w.player, w.sheet, _fx_plan(w)).ok, "AC-QS-103 attitude -29 passes")
	db.get_record("people", w.offerer_id)["attitude"] = 0

	# AC-QS-104: offerer benefit required & no harm on completion
	assert_false(_QuestValidator.validate_plan(gd, db, w.player, w.sheet, _fx_plan(w, {"outcomes": []})).ok, "AC-QS-104 missing completed offerer gain rejected")
	assert_false(_QuestValidator.validate_plan(gd, db, w.player, w.sheet,
		_fx_plan(w, {"outcomes": [{"on": "completed", "role": "offerer", "effect": "wealth", "amount": -10}]})).ok, "AC-QS-104 completed harm to offerer rejected")

	# AC-QS-106: player as adversary or two adversaries rejected
	assert_false(_QuestValidator.validate_plan(gd, db, w.player, w.sheet, _fx_plan(w, {"adversary_id": w.player.id})).ok, "AC-QS-106 player as adversary rejected")
	assert_false(_QuestValidator.validate_plan(gd, db, w.player, w.sheet, _fx_plan(w, {"adversaries": [w.adv_id, w.adv_head_id]})).ok, "AC-QS-106 two adversaries rejected")

	# AC-QS-107, 108, 109, 110, 111, 127, 134, 140, 141: Formula E reactions
	var maj_quest := {
		"offer_kind": "person",
		"offerer_id": w.offerer_id,
		"offerer_root_id": w.offerer_id,
		"adversary_id": w.adv_id,
		"adversary_root_id": w.adv_id,
		"offerer_relationship_reward": 12,
		"outcomes": [
			{"on": "completed", "role": "offerer", "effect": "wealth", "amount_share": 0.3},
			{"on": "completed", "role": "adversary", "effect": "wealth", "amount_share": -0.3},
			{"on": "completed", "role": "adversary", "effect": "injury", "amount": 0.3},
		],
	}
	var rx_comp: Array = _QuestRules.compute_reactions(gd, db, maj_quest, "completed")
	var by_pid := {}
	for r in rx_comp:
		by_pid[str(r.person_id)] = int(r.delta)
	assert_eq(by_pid.get(w.offerer_id, 0), 12, "AC-QS-107 offerer +12")
	assert_eq(by_pid.get(w.master_id, 0), 6, "AC-QS-107 offerer master +6")
	assert_eq(by_pid.get(w.disciple_id, 0), 6, "AC-QS-107 offerer disciple +6")
	assert_eq(by_pid.get(w.head_id, 0), 3, "AC-QS-107 offerer sect head +3")
	assert_eq(by_pid.get(w.adv_id, 0), -15, "AC-QS-107 adversary -15")
	assert_eq(by_pid.get(w.adv_master_id, 0), -7, "AC-QS-107 adversary master -7")
	assert_eq(by_pid.get(w.adv_head_id, 0), -3, "AC-QS-107 adversary sect head -3")

	# Killed adversary: master -15, sect head -7
	var rx_kill: Array = _QuestRules.compute_reactions(gd, db, maj_quest, "completed", true)
	var kill_map := {}
	for r in rx_kill:
		kill_map[str(r.person_id)] = int(r.delta)
	assert_false(kill_map.has(w.adv_id), "AC-QS-107 killed adversary skipped")
	assert_eq(kill_map.get(w.adv_master_id, 0), -15, "AC-QS-107 killed adversary master -15")
	assert_eq(kill_map.get(w.adv_head_id, 0), -7, "AC-QS-107 killed adversary head -7")

	# AC-QS-108: master who is ALSO sect head changes by -7 only; NPC on both sides takes both changes
	var bystander_id: String = _add_npc(db, "Người Ngoài", w.pl1, w.sect_id, "ngoai_mon", 0, 0)
	db.get_record("people", w.adv_id)["master_id"] = w.adv_head_id  # adv_head is now both master and sect head!
	var rx_dedup: Array = _QuestRules.compute_reactions(gd, db, maj_quest, "completed")
	var adv_head_entries: Array = rx_dedup.filter(func(x): return str(x.person_id) == w.adv_head_id)
	assert_eq(adv_head_entries.size(), 1, "AC-QS-108 master==sect_head reacts once")
	assert_eq(int(adv_head_entries[0].delta), -7, "AC-QS-108 master==sect_head takes larger share (-7)")
	assert_eq(rx_dedup.filter(func(x): return str(x.person_id) == bystander_id).size(), 0, "AC-QS-111 unrelated sect member untouched")

	# Put offerer's master as adversary's master too -> takes offerer side (+6) first, then adversary side (-7)
	db.get_record("people", w.adv_id)["master_id"] = w.master_id
	var rx_both: Array = _QuestRules.compute_reactions(gd, db, maj_quest, "completed")
	var both_entries: Array = rx_both.filter(func(x): return str(x.person_id) == w.master_id)
	assert_eq(both_entries.size(), 2, "AC-QS-108 NPC on both sides reacts twice")
	assert_eq(str(both_entries[0].side), "offerer", "AC-QS-108 offerer side runs first")
	assert_eq(int(both_entries[0].delta), 6, "AC-QS-108 offerer side +6")
	assert_eq(str(both_entries[1].side), "adversary", "AC-QS-108 adversary side runs second")
	assert_eq(int(both_entries[1].delta), -7, "AC-QS-108 adversary side -7")
	assert_eq(int(both_entries[1].after), -1, "AC-QS-108 cumulative 0 + 6 - 7 = -1")
	db.get_record("people", w.adv_id)["master_id"] = w.adv_master_id

	# AC-QS-109: Failed (-15/-7/-3), Lapsed (-8/-4/-2), tie at -25 on Failed -> -29; adversary untouched
	db.get_record("people", w.master_id)["attitude"] = -25
	var rx_fail: Array = _QuestRules.compute_reactions(gd, db, maj_quest, "failed")
	var fm := {}
	for r in rx_fail:
		fm[str(r.person_id)] = r
	assert_eq(int(fm[w.offerer_id].delta), -15, "AC-QS-109 Failed offerer -15")
	assert_eq(int(fm[w.master_id].after), -29, "AC-QS-109 Failed tie at -25 clamped to -29")
	assert_eq(int(fm[w.head_id].delta), -3, "AC-QS-109 Failed head -3")
	assert_false(fm.has(w.adv_id), "AC-QS-109 Failed leaves adversary untouched")
	db.get_record("people", w.master_id)["attitude"] = 0

	var rx_lapse: Array = _QuestRules.compute_reactions(gd, db, maj_quest, "lapsed")
	var lm := {}
	for r in rx_lapse:
		lm[str(r.person_id)] = int(r.delta)
	assert_eq(lm.get(w.offerer_id, 0), -8, "AC-QS-109 Lapsed offerer -8")
	assert_eq(lm.get(w.master_id, 0), -4, "AC-QS-109 Lapsed master -4")
	assert_eq(lm.get(w.head_id, 0), -2, "AC-QS-109 Lapsed head -2")

	# AC-QS-110: tie at -95 taking -15 clamps at -100; severity sum 40 capped at -30
	db.get_record("people", w.adv_master_id)["attitude"] = -95
	var rx_clamp: Array = _QuestRules.compute_reactions(gd, db, maj_quest, "completed", true)
	var cm := {}
	for r in rx_clamp:
		cm[str(r.person_id)] = r
	assert_eq(int(cm[w.adv_master_id].after), -100, "AC-QS-110 -95 -15 clamps at -100")
	db.get_record("people", w.adv_master_id)["attitude"] = 0

	var sev40_q: Dictionary = maj_quest.duplicate(true)
	sev40_q["outcomes"] = [
		{"on": "completed", "role": "offerer", "effect": "wealth", "amount_share": 0.2},
		{"on": "completed", "role": "adversary", "effect": "rank"},
		{"on": "completed", "role": "adversary", "effect": "death"},
	]
	var rx_s40: Array = _QuestRules.compute_reactions(gd, db, sev40_q, "completed")
	var adv_r40: Array = rx_s40.filter(func(x): return str(x.person_id) == w.adv_id)
	assert_eq(int(adv_r40[0].delta), -30, "AC-QS-110 severity 45 caps d_adversary at -30")

	# AC-QS-127: wealth (5) + standing (5) -> d_adversary -10
	var ws_q: Dictionary = maj_quest.duplicate(true)
	ws_q["outcomes"] = [
		{"on": "completed", "role": "offerer", "effect": "wealth", "amount_share": 0.2},
		{"on": "completed", "role": "adversary", "effect": "wealth", "amount_share": -0.2},
		{"on": "completed", "role": "adversary_sect", "effect": "standing", "amount": -5},
	]
	var adv_ws: Array = _QuestRules.compute_reactions(gd, db, ws_q, "completed").filter(func(x): return str(x.person_id) == w.adv_id)
	assert_eq(int(adv_ws[0].delta), -10, "AC-QS-127 wealth + standing -> d_adversary -10")

	# AC-QS-134: board quest moves zero attitudes
	var board_q: Dictionary = maj_quest.duplicate(true)
	board_q["offer_kind"] = "board"
	assert_eq(_QuestRules.compute_reactions(gd, db, board_q, "completed"), [], "AC-QS-134 board completed 0 reactions")
	assert_eq(_QuestRules.compute_reactions(gd, db, board_q, "failed"), [], "AC-QS-134 board failed 0 reactions")

	# AC-QS-141: sect adversary resolves to head H without duplicate head tie
	db.get_record("people", w.adv_head_id)["master_id"] = w.adv_master_id
	var sect_adv_q: Dictionary = maj_quest.duplicate(true)
	sect_adv_q["adversary_id"] = w.rival_sect_id
	sect_adv_q.erase("adversary_root_id")
	var rx_sa: Array = _QuestRules.compute_reactions(gd, db, sect_adv_q, "completed")
	var h_rows: Array = rx_sa.filter(func(x): return str(x.person_id) == w.adv_head_id)
	var m_rows: Array = rx_sa.filter(func(x): return str(x.person_id) == w.adv_master_id)
	assert_eq(h_rows.size(), 1, "AC-QS-141 sect head reacts once as root")
	assert_eq(int(h_rows[0].delta), -15, "AC-QS-141 head takes -15")
	assert_eq(int(m_rows[0].delta), -7, "AC-QS-141 head's master takes -7")

	# AC-QS-112, 113, 114, 124, 125, 131, 132, 144: Outcome schema, tier gates, limits, rank & death rules
	var err_st := [{"kind": "event", "window": 2, "place_id": w.pl1}, {"kind": "event", "window": 2, "place_id": w.pl1}]
	var maj_st := [
		{"kind": "craft", "window": 3, "place_id": w.pl1},
		{"kind": "craft", "window": 3, "place_id": w.pl1},
		{"kind": "defeat", "window": 3, "place_id": w.pl1, "target_id": w.adv_id},
		{"kind": "event", "window": 2, "place_id": w.pl1},
	]
	var f_ok := {"fight_power_fn": func(_st, _pl): return {"f_opp": 300.0, "f_player": 1000.0}}

	# Errand wealth passes, Errand injury fails; Ordinary rank fails, Ordinary 2 completed fails, 1+1 passes
	assert_true(_QuestValidator.validate_plan(gd, db, w.player, w.sheet,
		_fx_plan(w, {"tier": "errand", "stages": err_st, "outcomes": [{"on": "completed", "role": "offerer", "effect": "wealth", "amount_share": 0.2}]})).ok, "AC-QS-112 Errand wealth passes")
	assert_false(_QuestValidator.validate_plan(gd, db, w.player, w.sheet,
		_fx_plan(w, {"tier": "errand", "stages": err_st, "outcomes": [
			{"on": "completed", "role": "offerer", "effect": "wealth", "amount_share": 0.2},
			{"on": "failed", "role": "offerer", "effect": "injury", "amount": 0.2}
		]})).ok, "AC-QS-112 Errand injury rejected")
	assert_false(_QuestValidator.validate_plan(gd, db, w.player, w.sheet,
		_fx_plan(w, {"tier": "ordinary", "outcomes": [{"on": "completed", "role": "offerer", "effect": "rank"}]})).ok, "AC-QS-112 Ordinary rank rejected")
	assert_false(_QuestValidator.validate_plan(gd, db, w.player, w.sheet,
		_fx_plan(w, {"tier": "ordinary", "outcomes": [
			{"on": "completed", "role": "offerer", "effect": "wealth", "amount": 10},
			{"on": "completed", "role": "offerer_sect", "effect": "standing", "amount": 5},
		]})).ok, "AC-QS-131 Ordinary 2 completed rejected")
	assert_true(_QuestValidator.validate_plan(gd, db, w.player, w.sheet,
		_fx_plan(w, {"tier": "ordinary", "outcomes": [
			{"on": "completed", "role": "offerer", "effect": "wealth", "amount": 10},
			{"on": "failed", "role": "offerer", "effect": "wealth", "amount": -10},
		]})).ok, "AC-QS-131 Ordinary 1 completed + 1 failed passes")

	# AC-QS-113, 125, 132: wealth 30/31, amount_share 0.50/0.51, injury 0.40/0.41, standing 10/11
	assert_true(_QuestValidator.validate_plan(gd, db, w.player, w.sheet,
		_fx_plan(w, {"outcomes": [{"on": "completed", "role": "offerer", "effect": "wealth", "amount": 30}]})).ok, "AC-QS-113 wealth 30 passes")
	assert_false(_QuestValidator.validate_plan(gd, db, w.player, w.sheet,
		_fx_plan(w, {"outcomes": [{"on": "completed", "role": "offerer", "effect": "wealth", "amount": 31}]})).ok, "AC-QS-113 wealth 31 rejected")
	assert_false(_QuestValidator.validate_plan(gd, db, w.player, w.sheet,
		_fx_plan(w, {"outcomes": [{"on": "completed", "role": "offerer", "effect": "wealth", "amount_share": 0.51}]})).ok, "AC-QS-132 amount_share 0.51 rejected")
	assert_true(_QuestValidator.validate_plan(gd, db, w.player, w.sheet,
		_fx_plan(w, {"outcomes": [{"on": "completed", "role": "offerer", "effect": "wealth", "amount": 10}, {"on": "failed", "role": "offerer", "effect": "injury", "amount": 0.40}]})).ok, "AC-QS-113 injury 0.40 passes")
	assert_false(_QuestValidator.validate_plan(gd, db, w.player, w.sheet,
		_fx_plan(w, {"outcomes": [{"on": "completed", "role": "offerer", "effect": "wealth", "amount": 10}, {"on": "failed", "role": "offerer", "effect": "injury", "amount": 0.41}]})).ok, "AC-QS-113 injury 0.41 rejected")
	assert_true(_QuestValidator.validate_plan(gd, db, w.player, w.sheet,
		_fx_plan(w, {"outcomes": [{"on": "completed", "role": "offerer_sect", "effect": "standing", "amount": 10}]})).ok, "AC-QS-125 standing 10 passes")
	assert_false(_QuestValidator.validate_plan(gd, db, w.player, w.sheet,
		_fx_plan(w, {"outcomes": [{"on": "completed", "role": "offerer_sect", "effect": "standing", "amount": 11}]})).ok, "AC-QS-125 standing 11 rejected")

	# AC-QS-114, 124, 144: death needs defeat & adversary & completed; rank cannot touch head or promote into head; rank with amount rejected
	var maj_no_defeat: Array = maj_st.duplicate(true)
	maj_no_defeat[2] = {"kind": "event", "window": 3, "place_id": w.pl1}
	assert_false(_QuestValidator.validate_plan(gd, db, w.player, w.sheet,
		_fx_plan(w, {"tier": "major", "adversary_id": w.adv_id, "stages": maj_no_defeat, "outcomes": [
			{"on": "completed", "role": "offerer", "effect": "wealth", "amount_share": 0.2},
			{"on": "completed", "role": "adversary", "effect": "death"}
		]})).ok, "AC-QS-114 death without defeat rejected")
	assert_true(_QuestValidator.validate_plan(gd, db, w.player, w.sheet,
		_fx_plan(w, {"tier": "major", "adversary_id": w.adv_id, "stages": maj_st, "outcomes": [
			{"on": "completed", "role": "offerer", "effect": "wealth", "amount_share": 0.2},
			{"on": "completed", "role": "adversary", "effect": "wealth", "amount_share": -0.2},
			{"on": "completed", "role": "adversary", "effect": "injury", "amount": 0.4},
		]}), f_ok).ok, "AC-QS-144 Major 3 completed entries pass")
	assert_false(_QuestValidator.validate_plan(gd, db, w.player, w.sheet,
		_fx_plan(w, {"tier": "major", "adversary_id": w.adv_id, "stages": maj_st, "outcomes": [
			{"on": "completed", "role": "offerer", "effect": "wealth", "amount_share": 0.2},
			{"on": "completed", "role": "adversary", "effect": "wealth", "amount_share": -0.2},
			{"on": "completed", "role": "adversary", "effect": "injury", "amount": 0.4},
			{"on": "completed", "role": "adversary", "effect": "death"},
		]}), f_ok).ok, "AC-QS-144 Major 4th completed entry rejected")
	assert_false(_QuestValidator.validate_plan(gd, db, w.player, w.sheet,
		_fx_plan(w, {"tier": "major", "stages": maj_st, "outcomes": [
			{"on": "completed", "role": "offerer", "effect": "rank", "amount": 1}
		]}), f_ok).ok, "AC-QS-144 rank with amount rejected")
	assert_false(_QuestValidator.validate_plan(gd, db, w.player, w.sheet,
		_fx_plan(w, {"tier": "major", "offerer_id": w.head_id, "offerer_root_id": w.head_id, "stages": maj_st, "outcomes": [
			{"on": "completed", "role": "offerer", "effect": "rank"}
		]}), f_ok).ok, "AC-QS-114 rank on sect head rejected")
	assert_false(_QuestValidator.validate_plan(gd, db, w.player, w.sheet,
		_fx_plan(w, {"tier": "major", "offerer_id": w.master_id, "offerer_root_id": w.master_id, "stages": maj_st, "outcomes": [
			{"on": "completed", "role": "offerer", "effect": "rank"}
		]}), f_ok).ok, "AC-QS-114 rank promoting elder into sect head rejected")
	assert_false(_QuestValidator.validate_plan(gd, db, w.player, w.sheet,
		_fx_plan(w, {"tier": "major", "stages": maj_st, "outcomes": [
			{"on": "completed", "role": "offerer", "effect": "wealth", "amount_share": 0.2},
			{"on": "failed", "role": "offerer", "effect": "wealth", "amount_share": 0.2},
		]}), f_ok).ok, "AC-QS-124 failed gain on offerer rejected")
	assert_false(_QuestValidator.validate_plan(gd, db, w.player, w.sheet,
		_fx_plan(w, {"tier": "major", "stages": maj_st, "outcomes": [
			{"on": "completed", "role": "offerer", "effect": "wealth", "amount_share": 0.2},
			{"on": "failed", "role": "adversary", "effect": "death"},
		]}), f_ok).ok, "AC-QS-124 death on failed rejected")
	assert_false(_QuestValidator.validate_plan(gd, db, w.player, w.sheet,
		_fx_plan(w, {"tier": "major", "stages": maj_st, "outcomes": [
			{"on": "completed", "role": "offerer_sect", "effect": "rank"},
		]}), f_ok).ok, "AC-QS-124 rank on sect role rejected")


# --- AC-QS-01..13, 46, 82, 126, 143, 146..150: Generator & Board -------------------------------------------------

func test_ac_qs_01_to_13_82_146_to_150_generator_and_board_determinism() -> void:
	var w: Dictionary = _base_world()
	var gd: GameData = w.gd
	var db: WorldDB = w.db
	var gen := _QuestGenerator.new(gd, db, null)

	# AC-QS-01, 06, 07, 09: Offer fields, keyed-stream byte-identical replay, stream isolation
	var offer1: Dictionary = gen.generate_offer(w.player, w.sheet, "person", w.offerer_id, w.pl1, 4242, 10, 0)
	var offer2: Dictionary = gen.generate_offer(w.player, w.sheet, "person", w.offerer_id, w.pl1, 4242, 10, 0)
	assert_true(offer1.ok, "AC-QS-01/06 person offer succeeds")
	assert_eq(offer1.quest, offer2.quest, "AC-QS-07 keyed stream produces byte-identical offer on replay")
	for req_key in ["id", "template_id", "tier", "offerer_id", "source_fact_id", "plan", "deadline", "state", "stage", "slots", "params"]:
		assert_true(offer1.quest.has(req_key), "AC-QS-01/06 quest record holds '%s'" % req_key)
	assert_eq(offer1.quest.state, "offered", "initial state is offered")
	assert_eq(offer1.quest.stage, 1, "initial stage is 1")

	# AC-QS-03: No fitting fact -> no offer
	var stranger_id: String = _add_npc(db, "Vô Danh", w.pl3, "", "", 0, 0)
	var no_fact_res: Dictionary = gen.generate_offer(w.player, w.sheet, "person", stranger_id, w.pl3, 4242, 10, 0)
	assert_false(no_fact_res.ok, "AC-QS-03 no fitting source fact -> no offer")
	assert_eq(no_fact_res.reason, "no_source_fact", "AC-QS-03 reason is no_source_fact")

	# AC-QS-08, 82, 148: 10,000-seed tier draw at Core Formation & Qi Refining (Legendary -> Major)
	var counts_cf := {"errand": 0, "ordinary": 0, "major": 0, "legendary": 0}
	var counts_qr := {"errand": 0, "ordinary": 0, "major": 0, "legendary": 0}
	var all_tiers := ["errand", "ordinary", "major", "legendary"]
	for s_i in range(10000):
		var r_cf := _QuestGenerator.offer_rng(100000 + s_i, w.player.id, 1, 0)
		var t_cf: String = _QuestGenerator.draw_tier(gd, r_cf, 2, all_tiers, "person")
		counts_cf[t_cf] = int(counts_cf[t_cf]) + 1
		var r_qr := _QuestGenerator.offer_rng(100000 + s_i, w.player.id, 1, 0)
		var t_qr: String = _QuestGenerator.draw_tier(gd, r_qr, 0, all_tiers, "person")
		counts_qr[t_qr] = int(counts_qr[t_qr]) + 1
	assert_near(float(counts_cf.errand) / 10000.0, 0.45, 0.01, "AC-QS-08 CF Errand ~0.45")
	assert_near(float(counts_cf.ordinary) / 10000.0, 0.45, 0.01, "AC-QS-08 CF Ordinary ~0.45")
	assert_near(float(counts_cf.major) / 10000.0, 0.08, 0.01, "AC-QS-08 CF Major ~0.08")
	assert_near(float(counts_cf.legendary) / 10000.0, 0.02, 0.01, "AC-QS-08 CF Legendary ~0.02")
	assert_near(float(counts_qr.major) / 10000.0, 0.10, 0.01, "AC-QS-08/82/148 QR Legendary->Major ~0.10")
	assert_eq(counts_qr.legendary, 0, "AC-QS-08/82/148 QR Legendary == 0")
	assert_eq(_QuestRules.downgrade_tier_for_realm(gd, "legendary", 1), "major", "AC-QS-82 FE Legendary->Major")
	assert_eq(_QuestRules.downgrade_tier_for_realm(gd, "legendary", 2), "legendary", "AC-QS-82 CF stays Legendary")

	# AC-QS-10, 11: Reject-never-repair up to offer_tries = 6
	var bad_tpl := {
		"id": "bad_1", "name": "Hỏng", "tier": "errand", "offer_kinds": ["person"],
		"fact_kinds": ["any"], "place_kinds": ["any"], "realm_min": 0, "realm_max": 4, "weight": 1000,
		"stake_text": "S", "offer_text": ["T"], "slots": {}, "params": {},
		"stages": [{"kind": "event", "window": 10, "title": "1", "text": ["1"]}, {"kind": "event", "window": 10, "title": "2", "text": ["2"]}],
		"outcomes": [{"on": "completed", "role": "offerer", "effect": "wealth", "amount_share": 0.2}],
	}
	var good_tpl := {
		"id": "good_ok", "name": "Tốt", "tier": "errand", "offer_kinds": ["person"],
		"fact_kinds": ["any"], "place_kinds": ["any"], "realm_min": 0, "realm_max": 4, "weight": 1,
		"stake_text": "S", "offer_text": ["T"], "slots": {}, "params": {},
		"stages": [{"kind": "event", "window": 2, "title": "1", "text": ["1"]}, {"kind": "event", "window": 2, "title": "2", "text": ["2"]}],
		"outcomes": [{"on": "completed", "role": "offerer", "effect": "wealth", "amount_share": 0.2}],
	}
	var res10: Dictionary = gen.generate_offer(w.player, w.sheet, "person", w.offerer_id, w.pl1, 7, 1, 0, {"templates": [bad_tpl, good_tpl]})
	assert_true(res10.ok, "AC-QS-10 invalid dropped and valid offered")
	assert_eq(res10.quest.template_id, "good_ok", "AC-QS-10 selected valid template without repairing bad one")

	var seven_bad: Array = []
	for k in range(7):
		var b_copy: Dictionary = bad_tpl.duplicate(true)
		b_copy["id"] = "bad_%d" % k
		seven_bad.append(b_copy)
	var res11_fail: Dictionary = gen.generate_offer(w.player, w.sheet, "person", w.offerer_id, w.pl1, 7, 1, 0, {"templates": seven_bad})
	assert_false(res11_fail.ok, "AC-QS-11 6 invalid templates -> no offer")
	assert_eq(res11_fail.tries, 6, "AC-QS-11 stops at offer_tries=6 without trying 7th")

	var five_bad_plus_one: Array = seven_bad.slice(0, 5)
	five_bad_plus_one.append(good_tpl)
	var res11_ok: Dictionary = gen.generate_offer(w.player, w.sheet, "person", w.offerer_id, w.pl1, 7, 1, 0, {"templates": five_bad_plus_one})
	assert_true(res11_ok.ok, "AC-QS-11 valid template within 6 tries passes")

	# AC-QS-12: Every Major invalid -> falls down to Ordinary
	var bad_major: Dictionary = bad_tpl.duplicate(true)
	bad_major["id"] = "bad_maj"
	bad_major["tier"] = "major"
	var ok_ord: Dictionary = good_tpl.duplicate(true)
	ok_ord["id"] = "ok_ord"
	ok_ord["tier"] = "ordinary"
	var res12: Dictionary = gen.generate_offer(w.player, w.sheet, "person", w.offerer_id, w.pl1, 99, 2, 0, {"templates": [bad_major, ok_ord]})
	assert_true(res12.ok, "AC-QS-12 fallback from Major to Ordinary succeeds")
	assert_eq(res12.quest.tier, "ordinary", "AC-QS-12 offered tier is Ordinary")

	# AC-QS-13: defeat template deferred when ratio too high, offered once player power rises
	var def_tpl := {
		"id": "def_only", "name": "Tỉ thí", "tier": "ordinary", "offer_kinds": ["person"],
		"fact_kinds": ["any"], "place_kinds": ["any"], "realm_min": 0, "realm_max": 4, "weight": 10,
		"stake_text": "S", "offer_text": ["T"],
		"slots": {"adversary": {"bind": "fact_adversary", "optional": false}}, "params": {},
		"stages": [
			{"kind": "defeat", "window": 3, "target_slot": "adversary", "title": "1", "text": ["1"]},
			{"kind": "event", "window": 2, "title": "2", "text": ["2"]},
		],
		"outcomes": [{"on": "completed", "role": "offerer", "effect": "wealth", "amount_share": 0.2}],
	}
	var r_hi := gen.generate_offer(w.player, w.sheet, "person", w.offerer_id, w.pl1, 11, 1, 0, {
		"templates": [def_tpl],
		"fight_power_fn": func(_st, _pl): return {"f_opp": 600.0, "f_player": 1000.0}
	})
	var r_ok := gen.generate_offer(w.player, w.sheet, "person", w.offerer_id, w.pl1, 11, 1, 0, {
		"templates": [def_tpl],
		"fight_power_fn": func(_st, _pl): return {"f_opp": 600.0, "f_player": 2500.0}
	})
	assert_false(r_hi.ok, "AC-QS-13 defeat template rejected when r=0.60 > 0.35")
	assert_true(r_ok.ok, "AC-QS-13 same defeat template offered after player power rises (r=0.24)")

	# AC-QS-143: Errand window_sum 8 with offer travel 5 (13 > 12) dropped
	var err_w8_tpl := {
		"id": "err_w8", "name": "Xa", "tier": "errand", "offer_kinds": ["person", "board"],
		"fact_kinds": ["any"], "place_kinds": ["any"], "realm_min": 0, "realm_max": 4, "weight": 10,
		"stake_text": "S", "offer_text": ["T"], "slots": {}, "params": {},
		"stages": [{"kind": "event", "window": 4, "title": "1", "text": ["1"]}, {"kind": "event", "window": 4, "title": "2", "text": ["2"]}],
		"outcomes": [{"on": "completed", "role": "offerer", "effect": "wealth", "amount_share": 0.2}],
	}
	assert_false(gen.generate_offer(w.player, w.sheet, "person", w.offerer_id, w.pl1, 12, 1, 0,
		{"templates": [err_w8_tpl], "travel_override": 5}).ok, "AC-QS-143 travel 5 pushes Errand 8+5=13 > 12 -> dropped")

	# AC-QS-146: slot naming nearest_living_calling X with no match -> dropped
	var call_tpl: Dictionary = good_tpl.duplicate(true)
	call_tpl["id"] = "need_alchemist"
	call_tpl["slots"] = {"target_person": {"bind": "nearest_living_calling", "calling": "alchemist", "optional": false}}
	var res146: Dictionary = gen.generate_offer(w.player, w.sheet, "person", w.offerer_id, w.pl1, 13, 1, 0, {"templates": [call_tpl, good_tpl]})
	assert_true(res146.ok, "AC-QS-146 falls through to next template")
	assert_eq(res146.quest.template_id, "good_ok", "AC-QS-146 unbound calling slot dropped")

	# AC-QS-150: new_person slot registers in WorldDB before offer is returned
	var before_people: int = db.count("people")
	var new_p_tpl: Dictionary = good_tpl.duplicate(true)
	new_p_tpl["id"] = "make_npc"
	new_p_tpl["slots"] = {"target_person": {"bind": "new_person", "archetype": "tan_tu", "realm_offset": 0}}
	new_p_tpl["stages"][0]["target_slot"] = "target_person"
	var res150: Dictionary = gen.generate_offer(w.player, w.sheet, "person", w.offerer_id, w.pl1, 14, 1, 0, {"templates": [new_p_tpl]})
	assert_true(res150.ok, "AC-QS-150 new_person template offered")
	assert_eq(db.count("people"), before_people + 1, "AC-QS-150 new person registered in WorldDB before offer")
	var created_pid: String = str(res150.quest.slots.target_person)
	assert_true(db.has_record("people", created_pid), "AC-QS-150 created person exists in WorldDB")

	# AC-QS-147: 1,000 seeded parameter draws all within [3, 5] and <= deadline_max
	var param_tpl := {
		"id": "param_win", "name": "Hẹn mùa", "tier": "ordinary", "offer_kinds": ["person"],
		"fact_kinds": ["any"], "place_kinds": ["any"], "realm_min": 0, "realm_max": 4, "weight": 10,
		"stake_text": "S", "offer_text": ["T"], "slots": {},
		"params": {"stage_win": [3, 5]},
		"stages": [
			{"kind": "event", "window": 3, "window_param": "stage_win", "title": "1", "text": ["1"]},
			{"kind": "event", "window": 2, "title": "2", "text": ["2"]},
		],
		"outcomes": [{"on": "completed", "role": "offerer", "effect": "wealth", "amount_share": 0.2}],
	}
	var seen_vals := {}
	for seed_i in range(1000):
		var r147: Dictionary = gen.generate_offer(w.player, w.sheet, "person", w.offerer_id, w.pl1, 5000 + seed_i, 1, 0, {"templates": [param_tpl]})
		assert_true(r147.ok, "AC-QS-147 seed %d succeeds" % seed_i)
		var drawn_w: int = int(r147.quest.params.stage_win)
		assert_true(drawn_w >= 3 and drawn_w <= 5, "AC-QS-147 drawn %d in [3, 5]" % drawn_w)
		assert_true(int(r147.quest.deadline) <= 20, "AC-QS-147 deadline <= 20")
		seen_vals[drawn_w] = true
	assert_eq(seen_vals.size(), 3, "AC-QS-147 hits all values 3, 4, 5 across 1,000 seeds")

	# AC-QS-04, 05, 46, 126, 134: QuestBoard refresh, oldest replaced, Errand/Ordinary only, town-no-sect drops offerer_sect
	var board := _QuestBoard.new(gd, db, null)
	var b_s1: Array = board.refresh_place(w.pl1, w.player, w.sheet, 888, 1)
	assert_eq(b_s1.size(), 3, "AC-QS-04 board fills to board_size=3")
	for bq in b_s1:
		assert_true(str(bq.tier) in ["errand", "ordinary"], "AC-QS-05 board quest is Errand or Ordinary")
		assert_true(bool(bq.board_no_attitude), "AC-QS-134 board quest has zero attitude changes")
		assert_eq(_QuestRules.compute_reactions(gd, db, bq, "completed"), [], "AC-QS-134 board reactions always empty")
	var oldest_id: String = str(b_s1[0].id)
	var second_id: String = str(b_s1[1].id)
	var read_before: Array = board.list_board(w.pl1)
	assert_eq(read_before, b_s1, "AC-QS-46 reading board returns exact list without mutating")
	var b_s2: Array = board.refresh_place(w.pl1, w.player, w.sheet, 888, 2)
	assert_eq(b_s2.size(), 3, "AC-QS-04 board stays size 3 after season passes")
	assert_eq(str(b_s2[0].id), second_id, "AC-QS-04 oldest slot was replaced")
	assert_false(b_s2.any(func(q): return str(q.id) == oldest_id), "AC-QS-04 oldest quest removed")

	# AC-QS-126: Town with NO sect drops offerer_sect outcome cleanly
	var town_fact: String = db.log_event(100, 1, "trade", "Thị trấn thiếu hàng.", [], [w.pl3], [], {})
	var sect_oc_tpl := {
		"id": "board_sect_oc", "name": "Hội trấn", "tier": "errand", "offer_kinds": ["board"],
		"fact_kinds": ["any"], "place_kinds": ["any"], "realm_min": 0, "realm_max": 4, "weight": 10,
		"offer_text": ["Nhiệm vụ trấn."], "slots": {}, "params": {},
		"stages": [{"kind": "event", "window": 2, "title": "1", "text": ["1"]}, {"kind": "event", "window": 2, "title": "2", "text": ["2"]}],
		"outcomes": [{"on": "completed", "role": "offerer_sect", "effect": "standing", "amount": 5}],
	}
	var b_town: Array = board.refresh_place(w.pl3, w.player, w.sheet, 999, 1, {
		"templates": [sect_oc_tpl],
		"source_fact": db.get_record("events", town_fact),
	})
	assert_true(b_town.size() >= 1, "AC-QS-126 town board offers quest")
	assert_eq(Array(b_town[0].outcomes).size(), 0, "AC-QS-126 town with no sect drops offerer_sect outcome")
	var b_sect: Array = board.refresh_place(w.pl1, w.player, w.sheet, 999, 3, {
		"templates": [sect_oc_tpl],
	})
	var sect_matched: Array = b_sect.filter(func(q): return str(q.template_id) == "board_sect_oc")
	assert_true(sect_matched.size() >= 1, "AC-QS-126 sect place offers board_sect_oc")
	assert_eq(Array(sect_matched[0].outcomes).size(), 1, "AC-QS-126 sect place retains resolved offerer_sect outcome")
