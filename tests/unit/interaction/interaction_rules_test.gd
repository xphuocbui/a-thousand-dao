extends DaoTestSuite
## Unit tests for InteractionRules (pure static formulas & preconditions for NPC Interaction & Dialogue #30):
## Formula A (AC-NI-05, AC-NI-06, Honest x deceitful never), Formula B (AC-NI-09, AC-NI-10),
## Formula C, Formula D (AC-NI-16), Formula E (AC-NI-18), Formula F (loan cap), attitude bands (AC-NI-21),
## focus tax helpers, haggle no-arbitrage clamp, trait side gating, and StatSheet interaction_buffs.


func _npc(opts: Dictionary = {}) -> Dictionary:
	return {
		"id": str(opts.get("id", "p_npc")),
		"name": str(opts.get("name", "Lâm Hạc")),
		"alive": true,
		"realm_index": int(opts.get("realm_index", 1)),
		"stage": 0,
		"sect_id": str(opts.get("sect_id", "")),
		"attitude": int(opts.get("attitude", 0)),
		"linh_thach": int(opts.get("linh_thach", 500)),
		"met_player": bool(opts.get("met_player", true)),
		"equipped": Array(opts.get("equipped", [])),
		"npc_traits": opts.get("npc_traits", {"personality": [], "calling": "", "fate": [], "gained": []}),
		"flags": Dictionary(opts.get("flags", {})),
	}


func test_acceptance_score_teaching_threshold_and_determinism_ac_ni_05() -> void:
	var gd := game_data()
	var db := WorldDB.new()
	var player := TestFixtures.character({"hoa": 50}, 50, 0, 0)
	player.id = "p_pl"
	var sh := StatSheet.build(player, gd, db, null)
	var teach: Dictionary = InteractionRules.verb_def(gd, "teach")

	var elder_30: Dictionary = _npc({"realm_index": 1, "attitude": 30})
	var r1: Dictionary = InteractionRules.acceptance_score(gd, db, teach, player, sh, elder_30, 0.0)
	assert_near(float(r1.score), 0.0, 1e-6, "AC-NI-05: -25 + 30 + 0 - 5 = 0")
	assert_true(bool(r1.accept), "AC-NI-05: score 0 accepts")
	var r1_again: Dictionary = InteractionRules.acceptance_score(gd, db, teach, player, sh, elder_30, 0.0)
	assert_eq(r1_again.score, r1.score, "AC-NI-05: same state gives exact same score")
	assert_eq(r1_again.accept, r1.accept, "AC-NI-05: same state gives exact same verdict")

	var elder_25: Dictionary = _npc({"realm_index": 1, "attitude": 25})
	var r2: Dictionary = InteractionRules.acceptance_score(gd, db, teach, player, sh, elder_25, 0.0)
	assert_near(float(r2.score), -5.0, 1e-6, "AC-NI-05: at attitude 25, S = -5")
	assert_false(bool(r2.accept), "AC-NI-05: S = -5 refuses")
	assert_true(Array(r2.parts).size() >= 5, "score breakdown parts populated")


func test_trait_term_bounds_minus_33_and_plus_23_ac_ni_06() -> void:
	var gd := game_data()
	assert_near(InteractionRules.trait_term_for_m(gd, 0.1), -33.0, 1e-6, "AC-NI-06: M=0.1 -> -33")
	assert_near(InteractionRules.trait_term_for_m(gd, 5.0), 23.0, 1e-6, "AC-NI-06: M=5.0 -> +23")
	assert_near(InteractionRules.trait_term_for_m(gd, 2.0), 10.0, 1e-6, "M=2 -> +10")
	assert_near(InteractionRules.trait_term_for_m(gd, 0.5), -10.0, 1e-6, "M=0.5 -> -10")


func test_honest_npc_never_accepts_deceitful_verb() -> void:
	var gd := game_data()
	var db := WorldDB.new()
	var player := TestFixtures.character({"hoa": 50}, 150, 1, 0)
	player.id = "p_pl"
	var sh := StatSheet.build(player, gd, db, null)
	var tempt: Dictionary = InteractionRules.verb_def(gd, "tempt")
	var honest_npc: Dictionary = _npc({
		"realm_index": 1,
		"attitude": 100,
		"npc_traits": {"personality": ["honest"], "calling": "", "fate": [], "gained": []},
	})
	var res: Dictionary = InteractionRules.acceptance_score(gd, db, tempt, player, sh, honest_npc, 100.0)
	assert_true(bool(res.never), "honest x deceitful triggers never flag")
	assert_false(bool(res.accept), "honest NPC must never accept deceitful verb even at max attitude & presence")
	assert_true(Array(res.parts).any(func(p): return str(p.key) == "trait_never"), "breakdown explains never penalty")


func test_gift_attitude_formula_truc_co_halving_and_ket_dan_ac_ni_09() -> void:
	var gd := game_data()
	var truc_co: Dictionary = _npc({"realm_index": 1})
	var ket_dan: Dictionary = _npc({"realm_index": 2})
	var pr: float = 70.0 - 50.0
	assert_eq(InteractionRules.gift_delta(gd, 300, truc_co, pr, 0), 7, "AC-NI-09: 300 stones to Trúc Cơ at presence 70 -> +7")
	assert_eq(InteractionRules.gift_delta(gd, 300, truc_co, pr, 1), 4, "AC-NI-09: second equal gift same year -> +4 (3.54 rounded)")
	assert_eq(InteractionRules.gift_delta(gd, 300, ket_dan, pr, 0), 1, "AC-NI-09: 300 stones to Kết Đan -> +1")
	assert_eq(InteractionRules.gift_delta(gd, 0, truc_co, pr, 0), 0, "worthless gift gives 0")


func test_attitude_loss_not_scaled_by_presence_ac_ni_10() -> void:
	var gd := game_data()
	var pr_high: float = 150.0 - 50.0
	assert_eq(InteractionRules.attitude_delta(gd, -10.0, pr_high), -10, "AC-NI-10: loss of 10 at presence 150 is exactly -10")
	assert_eq(InteractionRules.attitude_delta(gd, 10.0, pr_high), 20, "positive gain scales x2.0 at presence 150")


func test_trade_band_visibility_and_market_presence_pricing_ac_ni_16() -> void:
	var gd := game_data()
	var db := WorldDB.new()
	var items := ItemFactory.new(gd)
	var mkt := Market.new(gd, db, items)
	var place_id: String = db.add("places", {"name": "Chợ", "type": "phuong_thi", "market": true, "region_id": ""})
	var player := TestFixtures.character({"hoa": 50}, 70, 1, 0)
	player.id = "p_pl"
	player.location_id = place_id
	var sh := StatSheet.build(player, gd, db, null)

	var npc: Dictionary = _npc({"id": "p_herb", "attitude": 20})   # warm
	db.add("people", npc)
	# 2 common herbs (rarity 1) + 1 better herb (rarity 3) -> median = 1.0 -> rarity 1 is common, rarity 3 is better.
	var h1: Dictionary = items.herb("ngung_khi_thao", 5.0)
	h1["owner_id"] = npc.id
	var h2: Dictionary = items.herb("ngung_khi_thao", 6.0)
	h2["owner_id"] = npc.id
	var rare_herb_id: String = ""
	for hd in gd.herbs():
		if int(hd.rarity) >= 3 and int(hd.rarity) < 5:
			rare_herb_id = str(hd.id)
			break
	assert_true(rare_herb_id != "", "precondition: rarity 3-4 herb exists")
	var h3: Dictionary = items.herb(rare_herb_id, 50.0)
	h3["owner_id"] = npc.id
	var id1: String = db.add("items", h1)
	var id2: String = db.add("items", h2)
	var id3: String = db.add("items", h3)
	# Equipped artifact must never appear on offer.
	var eq: Dictionary = items.artifact(rng(5), 1, 1, "hoa")
	eq["owner_id"] = npc.id
	var eq_id: String = db.add("items", eq)
	npc["equipped"] = [eq_id]

	var warm_offer: Dictionary = InteractionRules.trade_items_for(gd, db, npc)
	var warm_ids: Array = Array(warm_offer.shown).map(func(it): return str(it.id))
	assert_true(warm_ids.has(id1) and warm_ids.has(id2), "AC-NI-16: warm shows common goods")
	assert_false(warm_ids.has(id3), "AC-NI-16: warm hides better goods")
	assert_false(warm_ids.has(eq_id), "equipped artifact never shown")
	assert_eq(Array(warm_offer.locked).size(), 1, "better item listed as locked")
	assert_eq(str(warm_offer.locked[0].band_needed), "friendly", "better item needs friendly")

	npc["attitude"] = 35   # friendly
	var fr_offer: Dictionary = InteractionRules.trade_items_for(gd, db, npc)
	var fr_ids: Array = Array(fr_offer.shown).map(func(it): return str(it.id))
	assert_true(fr_ids.has(id1) and fr_ids.has(id2) and fr_ids.has(id3), "AC-NI-16: friendly shows common + better")
	var base_b: int = mkt.buy_price(player, sh, db.get_record("items", id1), place_id)
	var base_s: int = mkt.sell_price(player, sh, db.get_record("items", id1), place_id)
	var un_haggled: Dictionary = InteractionRules.haggle_prices(gd, base_b, base_s, false)
	assert_eq(int(un_haggled.buy), base_b, "AC-NI-16: trade price equals Market price with presence")
	assert_eq(int(un_haggled.sell), base_s, "AC-NI-16: sell price equals Market price with presence")


func test_threat_check_formula_and_clamp_ac_ni_18() -> void:
	var gd := game_data()
	var cautious_npc: Dictionary = _npc({"npc_traits": {"personality": ["cautious"]}})
	var m_c: float = NpcTraits.choice_weight(gd, cautious_npc, ["cautious"], 1.0)
	assert_near(m_c, 2.0, 1e-6, "precondition: cautious gives M=2 on cautious")
	var r1: Dictionary = InteractionRules.threat_chance(gd, 0.70, cautious_npc)
	assert_near(float(r1.p), 0.80, 1e-6, "AC-NI-18: q=0.70, M_cautious=2 -> p=0.80")

	var r_hi: Dictionary = InteractionRules.threat_chance(gd, 1.0, cautious_npc)
	assert_near(float(r_hi.p), 0.95, 1e-6, "AC-NI-18: clamped high to 0.95")
	var brave_npc: Dictionary = _npc({"npc_traits": {"personality": ["brave"]}})
	var r_lo: Dictionary = InteractionRules.threat_chance(gd, 0.0, brave_npc)
	assert_near(float(r_lo.p), 0.05, 1e-6, "clamped low to 0.05")


func test_attitude_band_thresholds_ac_ni_21() -> void:
	var gd := game_data()
	assert_eq(InteractionRules.attitude_band(gd, -30), "hostile", "AC-NI-21: -30 hostile")
	assert_eq(InteractionRules.attitude_band(gd, -10), "cold", "AC-NI-21: -10 cold")
	assert_eq(InteractionRules.attitude_band(gd, 0), "neutral", "AC-NI-21: 0 neutral")
	assert_eq(InteractionRules.attitude_band(gd, 10), "warm", "AC-NI-21: 10 warm")
	assert_eq(InteractionRules.attitude_band(gd, 30), "friendly", "AC-NI-21: 30 friendly")
	assert_eq(InteractionRules.attitude_band(gd, 60), "close", "AC-NI-21: 60 close")


func test_loan_cap_focus_tax_and_haggle_no_arbitrage_clamp() -> void:
	var gd := game_data()
	# Trúc Cơ W_r = 600, loan_share = 0.5 -> cap 300 with purse 1000; cap 120 with purse 120.
	assert_eq(InteractionRules.loan_cap(gd, _npc({"realm_index": 1, "linh_thach": 1000})), 300, "loan_cap min(300, 1000)")
	assert_eq(InteractionRules.loan_cap(gd, _npc({"realm_index": 1, "linh_thach": 120})), 120, "loan_cap limited by purse")
	assert_eq(InteractionRules.loan_cap(gd, _npc({"realm_index": 1, "linh_thach": 0})), 0, "empty purse -> 0")

	# Focus tax helpers
	assert_near(InteractionRules.focus_yield_share(0.25), 0.75, 1e-6, "0.25 used -> 75% yield")
	assert_true(InteractionRules.has_focus_time(0.75, 0.25), "exact remaining 0.25 fits")
	assert_false(InteractionRules.has_focus_time(0.80, 0.25), "0.20 remaining refuses 0.25 verb")

	# Haggle no-arbitrage clamp: even if base_buy and base_sell are very close, buy > sell strictly!
	for pair in [[100, 95], [10, 9], [2, 2], [1, 1], [100, 50]]:
		var hp: Dictionary = InteractionRules.haggle_prices(gd, int(pair[0]), int(pair[1]), true)
		assert_true(int(hp.buy) > int(hp.sell), "no arbitrage for (%d, %d): buy=%d > sell=%d" % [pair[0], pair[1], hp.buy, hp.sell])


func test_trait_verb_side_gating_self_other_either() -> void:
	var gd := game_data()
	var empty_p := {"npc_traits": {"personality": []}}
	var clan_p := {"npc_traits": {"upbringing": "clan_heir"}}
	var temple_p := {"npc_traits": {"upbringing": "temple_raised"}}
	var tea_p := {"npc_traits": {"lifestyle": "tea_master"}}

	var v_self: Dictionary = InteractionRules.verb_def(gd, "invoke_clan")
	var v_other: Dictionary = InteractionRules.verb_def(gd, "counsel")
	var v_either: Dictionary = InteractionRules.verb_def(gd, "share_tea")

	assert_true(InteractionRules.check_trait_side(gd, clan_p, empty_p, v_self), "self: player holds clan_heir -> unlocked")
	assert_false(InteractionRules.check_trait_side(gd, empty_p, clan_p, v_self), "self: only NPC holds clan_heir -> locked")

	assert_true(InteractionRules.check_trait_side(gd, empty_p, temple_p, v_other), "other: NPC holds temple_raised -> unlocked")
	assert_false(InteractionRules.check_trait_side(gd, temple_p, empty_p, v_other), "other: only player holds temple_raised -> locked")

	assert_true(InteractionRules.check_trait_side(gd, tea_p, empty_p, v_either), "either: player holds tea_master -> unlocked")
	assert_true(InteractionRules.check_trait_side(gd, empty_p, tea_p, v_either), "either: NPC holds tea_master -> unlocked")
	assert_false(InteractionRules.check_trait_side(gd, empty_p, empty_p, v_either), "either: neither holds tea_master -> locked")


func test_stat_sheet_applies_interaction_buffs() -> void:
	var gd := game_data()
	var c := TestFixtures.character({"hoa": 50}, 50, 1, 0)
	var before: float = StatSheet.build(c, gd, null, null).total("cultivation_speed_pct")
	c.interaction_buffs.append({
		"source": "Thỉnh giáo: Trưởng lão",
		"stat": "cultivation_speed_pct",
		"value": 20.0,
		"expires_season": 10,
	})
	var sh := StatSheet.build(c, gd, null, null)
	assert_near(sh.total("cultivation_speed_pct"), before + 20.0, 1e-6, "interaction buff wired into StatSheet")
	var srcs: Array = sh.sources("cultivation_speed_pct")
	assert_true(srcs.any(func(m): return str(m.kind) == StatSheet.KIND_INTERACTION and is_equal_approx(float(m.value), 20.0)), "buff tagged with KIND_INTERACTION")
