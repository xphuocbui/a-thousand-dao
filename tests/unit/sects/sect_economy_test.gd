extends DaoTestSuite
## The sects' development and money against design/gdd/sects.md's worked examples (Formulas F1, F2, F4, F17, F19).


func _sect(levels: Dictionary, kind: String = "great") -> Dictionary:
	var gd := game_data()
	var inv := {}
	for tr in SectEconomy.TRACKS:
		inv[tr] = SectEconomy.total_cost(gd, tr, float(levels.get(tr, 0)))
	return {"id": "s_x", "kind": kind, "status": "active", "levels": levels.duplicate(), "invested": inv,
		"dials": {"tax": 2, "war_readiness": 2, "recruitment": 2, "openness": 2, "expansion": 2}}


func test_track_cost_and_upkeep_follow_f1() -> void:
	var gd := game_data()
	assert_near(SectEconomy.level_cost(gd, "holdings", 10), 41322.0, 1.0, "Holdings 10 costs 2,000 x 1.4^9")
	assert_near(SectEconomy.total_cost(gd, "holdings", 10), 139627.0, 1.0, "C for Holdings 10")
	var s := _sect({"holdings": 10})
	assert_near(SectEconomy.upkeep(gd, s), 1396.27, 0.5, "upkeep 1 % of C")
	assert_near(SectEconomy.level_of(gd, "holdings", 139627.0), 10.0, 0.001, "the inverse")


func test_a_lords_effective_level_counts_half_its_vassals_f1() -> void:
	# a lord at Holdings 10 with four vassals at Holdings 5 (C 21,891 each): L_eff 10.8
	var gd := game_data()
	var db := WorldDB.new()
	var lord := _sect({"holdings": 10})
	db.put("sects", lord)
	for i in 4:
		var v := _sect({"holdings": 5}, "minor")
		v.id = "s_v%d" % i
		v["lord_id"] = "s_x"
		db.put("sects", v)
	assert_near(SectEconomy.total_cost(gd, "holdings", 5), 21891.0, 1.0, "C for Holdings 5")
	assert_near(SectEconomy.effective_level(gd, db, lord, "holdings"), 10.8, 0.05, "log1.4(1 + 0.4 x 183,409 / 2,000)")


func test_seat_capacity_follows_f2() -> void:
	var gd := game_data()
	var db := WorldDB.new()
	var s := _sect({"holdings": 6, "institutions": 6, "military": 6, "trade": 6})
	db.put("sects", s)
	assert_eq(SectEconomy.capacity(gd, db, s), 400, "a tier-1 sect at 6/6/6/6 houses 400")


func test_tribute_follows_f4() -> void:
	# Tax 2 gives a rate of 0.175; a vassal grossing 1,394 pays 244
	var gd := game_data()
	var db := WorldDB.new()
	var lord := _sect({"holdings": 6})
	lord["treasury"] = 0.0
	db.put("sects", lord)
	var v := _sect({"holdings": 3}, "minor")
	v.id = "s_v"
	v["lord_id"] = "s_x"
	v["treasury"] = 5000.0
	v["gross_income"] = 1394.0
	v["invested"] = {}   # no upkeep, so the treasury pays only the tribute
	db.put("sects", v)
	var money := MoneyLedger.new(db)
	var out := SectEconomy.season(gd, db, money)
	assert_near(float(out.tribute), 243.95, 0.01, "0.175 x 1,394")
	assert_near(money.balance("sect:s_x") , 243.95, 0.01, "the lord received it")


func test_the_investment_track_follows_f19() -> void:
	# FX-T1 at 6/6/6/6 at peace: C shares 0.25 / 0.31 / 0.25 / 0.19 against the mix 0.25 / 0.20 / 0.30 / 0.25 -> Trade
	var gd := game_data()
	var s := _sect({"holdings": 6, "institutions": 6, "military": 6, "trade": 6})
	assert_eq(SectEconomy.invest_track(gd, s), "trade", "Trade has the largest deficit")
	s.dials.war_readiness = 4
	assert_eq(SectEconomy.invest_track(gd, s), "military", "War readiness 4 lifts the Military share to 0.50")


func test_investment_raises_a_level() -> void:
	var gd := game_data()
	var s := _sect({"holdings": 6, "institutions": 6, "military": 6, "trade": 6})
	var tr := SectEconomy.invest(gd, s, SectEconomy.level_cost(gd, "trade", 7))
	assert_eq(tr, "trade", "the F19 track")
	assert_eq(int(s.levels.trade), 7, "the next level's cost buys it")


func test_intake_follows_f17() -> void:
	# a minor sect at capacity 56 with 38 members and Recruitment 2: target 50, intake round(0.10 x 12) = 1
	var gd := game_data()
	var db := WorldDB.new()
	var s := _sect({"institutions": 5}, "minor")
	db.put("sects", s)
	assert_eq(SectEconomy.capacity(gd, db, s), 56, "25 x (1 + 0.25 x 5)")
	assert_eq(SectEconomy.intake(gd, db, s, 38), 1, "one Luyện Khí member")
	assert_eq(SectEconomy.intake(gd, db, s, 51), 0, "none at or above the target")


func test_military_demand_reads_the_mean_of_the_last_four_seasons() -> void:
	# Trade Goods H's spend_Mil (user decision 2026-11-21): committed Military spending 100, 470, 100, 390 reads 265
	# after four seasons; the first season reads its own value; a fifth season drops the oldest
	var gd := game_data()
	var db := WorldDB.new()
	var s := _sect({"military": 2})
	s["treasury"] = 1e9
	db.put("sects", s)
	var money := MoneyLedger.new(db)
	var reads: Array = []
	for v in [100.0, 470.0, 100.0, 390.0, 470.0]:
		s["spend"] = {"military": v}   # the season's committed value (upkeep plus investment)
		reads.append(SectEconomy.mil_spend_mean(s))   # what the markets read next season
		SectEconomy.season(gd, db, money)   # the next season resets the spending
	assert_near(float(reads[0]), 100.0, 1e-9, "one season: its own value")
	assert_near(float(reads[1]), 285.0, 1e-9, "two seasons")
	assert_near(float(reads[3]), 265.0, 1e-9, "four seasons: (100 + 470 + 100 + 390) / 4")
	assert_near(float(reads[4]), 357.5, 1e-9, "the fifth drops the oldest: (470 + 100 + 390 + 470) / 4")
