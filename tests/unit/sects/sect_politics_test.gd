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
