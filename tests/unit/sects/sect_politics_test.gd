extends DaoTestSuite
## The politics between sects against design/gdd/sects.md's worked examples and rules (Formulas F5, F7, F8, F9, F18).


func _db_two(align_a: String, align_b: String) -> WorldDB:
	var db := WorldDB.new()
	for x in [["s1", align_a], ["s2", align_b]]:
		db.put("sects", {"id": x[0], "name": x[0], "kind": "great", "status": "active", "alignment": x[1],
			"levels": {"military": 6}, "dials": {"tax": 2, "expansion": 2, "openness": 2, "war_readiness": 2, "recruitment": 2},
			"attitude": {}, "grudge": {}, "relation": {}, "truce": {}, "wars": []})
	return db


func test_attitude_steps_toward_its_target_f7() -> void:
	# chính vs ma, 2 shared borders, a Cruel head (-10): A_tgt -50; from -20 it runs -25, -29, -32, -35, -37, -39, -41
	var gd := game_data()
	var a: float = -20.0
	var seen: Array = []
	for i in 7:
		a = SectPolitics.attitude_step(gd, a, -50.0)
		seen.append(int(a))
	assert_eq(seen, [-25, -29, -32, -35, -37, -39, -41], "the feud starts in season 7")


func test_alignment_sets_the_attitude_target() -> void:
	var gd := game_data()
	var db := _db_two("chinh", "ma")
	var a: Dictionary = db.get_record("sects", "s1")
	var b: Dictionary = db.get_record("sects", "s2")
	assert_eq(SectPolitics.attitude_target(gd, db, a, b, {}), -30.0, "chính against ma, no border (fixture regions are none)")
	var db2 := _db_two("chinh", "chinh")
	assert_eq(SectPolitics.attitude_target(gd, db2, db2.get_record("sects", "s1"), db2.get_record("sects", "s2"), {}), 20.0, "the same alignment")


func test_war_strength_follows_f8() -> void:
	# a tier-1 sect with 300 / 75 / 20 / 4 / 1 members: 6,700 x 1.6 = 10,720 at Military 6 (no vassals)
	var gd := game_data()
	var db := _db_two("chinh", "ma")
	var counts := [300, 75, 20, 4, 1]
	var n: int = 0
	for rl in counts.size():
		for i in counts[rl]:
			n += 1
			db.put("people", {"id": "p%d" % n, "alive": true, "realm_index": rl, "sect_id": "s1"})
	assert_near(float(SectPolitics.strengths(gd, db).s1), 10720.0, 0.01, "6,700 x 1.6")


func test_loyalty_states_follow_the_lines() -> void:
	var gd := game_data()
	assert_eq(SectPolitics.loyalty_state(gd, 75.0), "loyal", "60 and above")
	assert_eq(SectPolitics.loyalty_state(gd, 45.0), "restless", "30-59")
	assert_eq(SectPolitics.loyalty_state(gd, 20.0), "defiant", "below the break line")


func test_the_built_world_starts_with_attitudes_grudges_and_peace() -> void:
	var gd := game_data()
	var r := RandomNumberGenerator.new()
	r.seed = 7
	var db: WorldDB = WorldBuilder.new(gd, TestFixtures.tree()).generate(r, "7")
	var tx: Dictionary = db.find("sects", func(s): return str(s.get("key", "")) == "thien_xu")[0]
	var tv: Dictionary = db.find("sects", func(s): return str(s.get("key", "")) == "thinh_vu")[0]
	assert_eq(float(tx.grudge.get(str(tv.id), 0.0)), -15.0, "the authored grudge (broken halberds, cinnabar vein)")
	assert_true(float(tx.get("s0", 0.0)) > 0.0, "S0 stored")
	assert_true(Array(tx.wars).is_empty(), "no war at the start")
	for s in db.all("sects"):
		if str(s.get("kind", "")) == "minor" and str(s.get("status", "")) == "active":
			assert_true(s.has("loyalty_state"), "%s has a loyalty state" % s.id)


func test_a_long_run_keeps_money_conserved_through_wars() -> void:
	# politics moves members to their deaths and territory between markets; the books still balance
	var gd := game_data()
	var r := RandomNumberGenerator.new()
	r.seed = 7
	var tree := TestFixtures.tree()
	var db: WorldDB = WorldBuilder.new(gd, tree).generate(r, "7")
	for s in db.all("sects"):   # every great sect spoiling for a fight: wars come sooner
		if str(s.get("kind", "")) == "great":
			s.dials["war_readiness"] = 4
			s.dials["expansion"] = 4
			for o in s.attitude.keys():
				s.attitude[o] = -60.0
	var ticker := WorldTicker.new(gd, db, BuildGenerator.new(gd, tree, db))
	var money := MoneyLedger.new(db)
	for i in 12:
		ticker.tick(r, 1200 + i / 4, i % 4)
		assert_near(money.season_check().gap, 0.0, 0.5, "season %d" % i)
	assert_true(db.find("events", func(e): return str(e.get("type", "")) == "sect_war").size() > 0, "a war was declared")


func test_a_defiant_vassal_with_a_backer_rebels_and_new_sects_fill_a_thinned_territory() -> void:
	# F5b check 2 and rule 30 on the built world: a vassal pushed to defiance with a strong backer goes to war on its
	# lord; a territory that lost a vassal sees a new sect founded by a loose cultivator, paid from their purse
	var gd := game_data()
	var r := RandomNumberGenerator.new()
	r.seed = 7
	var db: WorldDB = WorldBuilder.new(gd, TestFixtures.tree()).generate(r, "7")
	var money := MoneyLedger.new(db)
	var v: Dictionary = db.find("sects", func(s): return str(s.get("kind", "")) == "minor" and str(s.get("status", "")) == "active")[0]
	var lord: Dictionary = db.get_record("sects", str(v.lord_id))
	var backer: Dictionary = db.find("sects", func(s): return str(s.get("kind", "")) == "great" and str(s.id) != str(lord.id))[0]
	backer.attitude[str(v.id)] = 80.0
	backer.attitude[str(lord.id)] = -80.0
	v["loyalty"] = 5.0
	v["loyalty_state"] = "defiant"
	var st := SectPolitics.strengths(gd, db)
	st[str(backer.id)] = float(st.get(str(lord.id), 1.0)) * 3.0
	var news := SectPolitics._maybe_rebel(gd, db, v, lord, st, 1200, 0)
	assert_false(news.is_empty(), "it rebels")
	assert_true(Array(v.wars).has(str(lord.id)), "at war with its lord")
	# a thinned territory: drop a vassal, force the founding chance
	var g: Dictionary = lord
	var other: Array = SectEconomy.vassals(db, g)
	other[0]["status"] = "fallen"
	gd.file("sects_members").politics["found_chance"] = 1.0
	var m_before: float = money.money_in_world()
	var born := SectPolitics._found_sects(gd, db, money, 1200, 1, "7")
	gd.file("sects_members").politics["found_chance"] = 0.02
	assert_false(born.is_empty(), "a new sect is founded")
	assert_eq(SectEconomy.vassals(db, g).size(), int(g.minor_start), "the territory is whole again")
	assert_near(money.money_in_world(), m_before, 1e-6, "the founder paid the treasury: no money made")


func test_site_friction_lowers_the_attitude_target_f7() -> void:
	# F7's site friction (user decision 2026-11-21): two trung great sects holding neighbouring regions, border sites
	# worth 87,414 a season (a spirit vein's 28,800 stones and a mine's 1,953.8 units of Xich Dong at 30 each): fr =
	# round(30 x (1 - 2^(-87414 / 45000))) = 22, both ways; a site away from the border does not count; no shared
	# border, no friction
	var gd := game_data()
	var regions: Array = gd.file(ContinentData.DATA_FILE).get("regions", [])
	var r0: Dictionary = regions[0]
	var r1: int = int(r0.neighbours[0].region)
	var far: int = -1   # a region bordering neither
	for r in regions:
		var nb: Array = Array(r.get("neighbours", [])).map(func(n): return int(n.region))
		if int(r.id) != int(r0.id) and int(r.id) != r1 and not nb.has(int(r0.id)) and not nb.has(r1):
			far = int(r.id)
			break
	var db := _db_two("trung", "trung")
	db.put("regions", {"id": "r_a", "continent_id": int(r0.id), "holder": "s1"})
	db.put("regions", {"id": "r_b", "continent_id": r1, "holder": "s2"})
	db.put("regions", {"id": "r_far", "continent_id": far, "holder": "s1"})
	db.put("places", {"id": "l_1", "region_id": "r_a", "site": {"base_output": 28800.0}})
	db.put("places", {"id": "l_2", "region_id": "r_b", "site": {"base_output": 1953.8, "resource": "xich_dong"}})
	db.put("places", {"id": "l_3", "region_id": "r_far", "site": {"base_output": 50000.0}})
	var a: Dictionary = db.get_record("sects", "s1")
	var b: Dictionary = db.get_record("sects", "s2")
	SectPolitics._begin(gd, db)
	assert_eq(SectPolitics.friction(gd, db, a, b), 22.0, "87,414 on the border, counted in value")
	assert_eq(SectPolitics.friction(gd, db, b, a), 22.0, "the same both ways")
	var bo: int = SectPolitics._borders(gd, db, a, b)
	assert_eq(SectPolitics.attitude_target(gd, db, a, b, {}), 20.0 + float(gd.file("sects_members").politics.b_k) * bo - 22.0, "the target loses it")
	var db2 := _db_two("trung", "trung")
	db2.put("regions", {"id": "r_a", "continent_id": int(r0.id), "holder": "s1"})
	db2.put("regions", {"id": "r_far", "continent_id": far, "holder": "s2"})
	db2.put("places", {"id": "l_1", "region_id": "r_a", "site": {"base_output": 28800.0}})
	SectPolitics._begin(gd, db2)
	assert_eq(SectPolitics.friction(gd, db2, db2.get_record("sects", "s1"), db2.get_record("sects", "s2")), 0.0, "no shared border")


func test_retuned_war_weariness_and_loss_share_end_stalemates_briskly() -> void:
	# Retuned F9 war resolution: equal-strength rivals lose loss_k / 2 per season, accumulate weariness via
	# weariness_base + weariness_loss_k * loss_share + max(0, -dws) * weariness_score_k, and conclude stalemates
	# briskly in a truce lasting truce_seasons.
	var gd := game_data()
	var c: Dictionary = gd.file("sects_members").politics
	var db := _db_two("chinh", "ma")
	var a: Dictionary = db.get_record("sects", "s1")
	var d: Dictionary = db.get_record("sects", "s2")
	a["treasury"] = 100000.0
	d["treasury"] = 100000.0
	a["wars"] = ["s2"]
	d["wars"] = ["s1"]
	a["relation"] = {"s2": "war"}
	d["relation"] = {"s1": "war"}
	db.put(MoneyLedger.TABLE, {"id": "m_stipends", "by_sect": {"s1": 0.0, "s2": 0.0}})
	db.put("markets", {"id": "mk_s1", "sect_id": "s1", "pool": 0.0})
	db.put("markets", {"id": "mk_s2", "sect_id": "s2", "pool": 0.0})
	for i in 1000:
		db.put("people", {"id": "pa_%d" % i, "alive": true, "realm_index": 0, "sect_id": "s1", "location_id": "pl_1"})
		db.put("people", {"id": "pd_%d" % i, "alive": true, "realm_index": 0, "sect_id": "s2", "location_id": "pl_2"})
	var war := {
		"id": "war_eq", "a": "s1", "d": "s2",
		"goal": {"kind": "vassal", "id": "v_stub", "name": "stub", "threshold": int(c.goal_thresholds.vassal)},
		"ws": 0, "w_a": 0.0, "w_d": 0.0, "seasons": 0, "began": [1200, 0],
	}
	db.put("world", {"id": SectPolitics.WARS, "wars": [war], "next": 2})
	var money := MoneyLedger.new(db)
	var st := {"s1": 10000.0, "s2": 10000.0}
	SectPolitics._begin(gd, db)
	# Season 1: verify per-season loss share (loss_k / 2) and data-driven weariness formula
	SectPolitics._resolve_wars(gd, db, money, st, 1200, 0, "eq_seed")
	var dead_a1: int = db.find("people", func(p): return str(p.get("sect_id", "")) == "s1" and not bool(p.get("alive", false))).size()
	var dead_d1: int = db.find("people", func(p): return str(p.get("sect_id", "")) == "s2" and not bool(p.get("alive", false))).size()
	var expected_losses: int = int(floor((float(c.loss_k) / 2.0) * 1000.0))
	assert_eq(dead_a1, expected_losses, "equal-strength attacker loses floor((loss_k / 2) * N)")
	assert_eq(dead_d1, expected_losses, "equal-strength defender loses floor((loss_k / 2) * N)")
	var la: float = float(c.loss_k) * 0.5
	var dws1: int = int(war.ws)
	var want_wa: float = float(c.weariness_base) + float(c.weariness_loss_k) * la + maxf(0.0, float(-dws1)) * float(c.weariness_score_k)
	var want_wd: float = float(c.weariness_base) + float(c.weariness_loss_k) * la + maxf(0.0, float(dws1)) * float(c.weariness_score_k)
	assert_near(float(war.w_a), want_wa, 1e-6, "attacker weariness uses weariness_base, weariness_loss_k and weariness_score_k")
	assert_near(float(war.w_d), want_wd, 1e-6, "defender weariness uses weariness_base, weariness_loss_k and weariness_score_k")
	# Continue resolving until war concludes; stalemate must end briskly within <= 12 seasons with truce_seasons
	var concluded_season: int = -1
	for s in range(1, 13):
		SectPolitics._resolve_wars(gd, db, money, st, 1200 + s / 4, s % 4, "eq_seed")
		if Array(db.get_record("world", SectPolitics.WARS).wars).is_empty():
			concluded_season = s + 1
			break
	assert_true(concluded_season > 0 and concluded_season <= 12, "stalemate concludes briskly (got %d seasons)" % concluded_season)
	assert_eq(str(a.relation.get("s2", "")), "truce", "stalemate concludes in a truce")
	assert_eq(int(a.truce.get("s2", 0)), int(c.truce_seasons), "truce length matches truce_seasons (%d)" % int(c.truce_seasons))
	assert_eq(int(d.truce.get("s1", 0)), int(c.truce_seasons), "defender truce matches truce_seasons")


func test_even_rivals_hold_cold_feud_below_war_odds() -> void:
	# Equal-strength great sects in a feud at neutral Expansion (2) and war_readiness = 3 stay in cold feud
	# below war_odds (> 1.0), and declare war once attacker strength ratio reaches war_odds.
	var gd := game_data()
	var c: Dictionary = gd.file("sects_members").politics
	var regions: Array = gd.file(ContinentData.DATA_FILE).get("regions", [])
	var r0: Dictionary = regions[0]
	var r1: int = int(r0.neighbours[0].region)
	var db := _db_two("chinh", "ma")
	db.put("regions", {"id": "r_a", "continent_id": int(r0.id), "holder": "s1", "name": "R_A"})
	db.put("regions", {"id": "r_b", "continent_id": r1, "holder": "s2", "name": "R_B"})
	db.put("places", {"id": "pl_site", "region_id": "r_b", "holder": "s2", "name": "Site_B",
		"site": {"base_output": 1000.0, "last_output": 1000.0, "resource": "linh_thach"}})
	db.put("world", {"id": SectPolitics.WARS, "wars": [], "next": 1})
	var a: Dictionary = db.get_record("sects", "s1")
	var b: Dictionary = db.get_record("sects", "s2")
	a.dials["war_readiness"] = 3
	a.dials["expansion"] = 2
	b.dials["war_readiness"] = 3
	b.dials["expansion"] = 2
	a.relation["s2"] = "feud"
	b.relation["s1"] = "feud"
	SectPolitics._begin(gd, db)
	assert_true(float(c.war_odds) > 1.0, "retuned war_odds exceeds 1.0")
	# Equal strength (1.0:1.0) -> cold feud, no war declared
	var news_eq := SectPolitics._declare_wars(gd, db, {"s1": 10000.0, "s2": 10000.0}, 1200, 0)
	assert_true(news_eq.is_empty(), "equal rivals hold cold feud below war_odds")
	assert_true(Array(db.get_record("world", SectPolitics.WARS).wars).is_empty(), "no war started at 1.0:1.0")
	# Just below war_odds -> still no war
	var news_under := SectPolitics._declare_wars(gd, db, {"s1": 10000.0 * (float(c.war_odds) - 0.02), "s2": 10000.0}, 1200, 1)
	assert_true(news_under.is_empty(), "still cold feud just below war_odds")
	# At war_odds -> war is declared
	var news_over := SectPolitics._declare_wars(gd, db, {"s1": 10000.0 * (float(c.war_odds) + 0.01), "s2": 10000.0}, 1200, 2)
	assert_false(news_over.is_empty(), "war declared once strength ratio crosses war_odds")
	assert_eq(Array(db.get_record("world", SectPolitics.WARS).wars).size(), 1, "one war active")
