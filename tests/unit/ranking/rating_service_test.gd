extends DaoTestSuite
## RatingService (ADR-0003 step 3; Power Rankings rules 2, 4, 5, 6, 13, 15, Formulas B, G) on the measured ladder in
## assets/data/combat_rankings.json.


func _service(gd: GameData) -> RatingService:
	return RatingService.new(gd, WorldDB.new())


func test_the_flag_is_on_in_the_shipped_data_and_off_in_the_shared_test_fixture() -> void:
	# Turned on 2026-11-15 (user decision); the shared fixture turns it off for the other suites (test_fixtures.gd)
	var shipped := GameData.load_from("res://assets/data")
	assert_true(RatingService.new(shipped, WorldDB.new()).enabled(), "combat_rankings.json enabled is true")
	assert_true(bool(shipped.combat().fight_engine.enabled), "combat_rules.json fight_engine.enabled is true (2026-11-15)")
	assert_false(_service(game_data()).enabled(), "the shared fixture keeps ratings off")


func test_a_new_fighter_is_provisional_at_its_stage_strength() -> void:
	# Rule 15, Formulas G
	var gd := game_data()
	var rs := _service(gd)
	var c := TestFixtures.character({"hoa": 50}, 50, 1, 2)
	c.id = "p1"
	var rec: Dictionary = rs.ensure(c)
	assert_eq(str(rec.state), RatingService.PROVISIONAL, "provisional")
	assert_near(float(rec.base), rs.ladder.provisional(1, 2, gd), 0.05, "Formulas G, stored to 0.1")
	assert_true(float(rec.base) > rs.ladder.anchors[1], "stage 2 above the realm's typical")
	assert_eq(rs.power_number(c), rs.ladder.power_number(float(rec.base)), "Formulas E on it")


func test_the_realms_typical_fighter_rates_near_its_anchor() -> void:
	# Formulas A, B: the typical fighter's own rating is A_r; its panel against its own ladder lands near it
	var gd := game_data()
	var rs := _service(gd)
	for r in [0, 2]:
		var rec := {"id": "t%d" % r, "base": 0.0, "offset": 0.0, "n": 0, "state": RatingService.PROVISIONAL, "realm": r,
			"seeds": {"season": -1, "counts": {}}}
		var res: Dictionary = rs.panel(rs.ladder.rung_profile(r, 0), r, rec, 7, 1, false)
		var rung: float = rs.ladder.rung_rating(r, 1) - rs.ladder.rung_rating(r, 0)
		assert_true(absf(float(res.base) - rs.ladder.anchors[r]) <= 3.0 * rung,
			"realm %d: base %.0f within 3 rungs of A_r %.0f" % [r, float(res.base), rs.ladder.anchors[r]])


func test_panel_seeds_are_keyed_and_deterministic() -> void:
	# Rule 13, ADR-0003 decision 4
	var gd := game_data()
	var rs := _service(gd)
	var p: FighterProfile = rs.ladder.rung_profile(1, 20)
	var mk := func() -> Dictionary: return {"id": "x", "base": 0.0, "offset": 0.0, "n": 0, "state": RatingService.PROVISIONAL, "realm": 1, "seeds": {"season": -1, "counts": {}}}
	var a: Dictionary = rs.panel(p, 1, mk.call(), 42, 3, false)
	var b: Dictionary = rs.panel(p, 1, mk.call(), 42, 3, false)
	assert_eq(a.probes, b.probes, "same seed, season and fighter: the same probes and scores")
	assert_eq(a.base, b.base, "and the same base")
	var rec: Dictionary = mk.call()
	rs.panel(p, 1, rec, 42, 3, false)
	var first: Dictionary = (rec.seeds.counts as Dictionary).duplicate()
	var second: Dictionary = rs.panel(p, 1, rec, 42, 3, false)
	var added := {}
	for pr in second.probes:
		added[str(pr[0])] = int(added.get(str(pr[0]), 0)) + int(pr[1])
	for k in rec.seeds.counts:
		assert_eq(int(rec.seeds.counts[k]), int(first.get(k, 0)) + int(added.get(k, 0)),
			"rung %s: the second panel's fights continue the first's index (distinct seeds)" % k)
	rs.panel(p, 1, rec, 42, 4, false)
	assert_true(int(rec.seeds.season) == 4, "a new season starts its counts afresh")


func test_a_real_character_is_rated_and_a_new_panel_keeps_half_its_offset() -> void:
	# Rules 4, 6; AC-PR-10
	var gd := game_data()
	var db := WorldDB.new()
	var rs := RatingService.new(gd, db)
	var c := TestFixtures.character({"hoa": 50}, 50, 1, 0)
	c.id = "p7"
	var sheet := StatSheet.build(c, gd, db, null)
	var done: Dictionary = rs.run_panel(c, sheet, 5, 1)
	assert_true(bool(done.ok), "panel ran: %s" % str(done.get("errors", "")))
	var rec: Dictionary = db.get_record(RatingService.TABLE, "p7")
	assert_eq(str(rec.state), RatingService.RATED, "rated")
	assert_eq(float(rec.base), float(done.base), "base stored")
	rec["offset"] = 40.0
	rec["n"] = 15
	rs.mark_stale(c)
	assert_eq(str(rec.state), RatingService.STALE, "a build change makes it Stale")
	rs.run_panel(c, sheet, 5, 2)
	assert_near(float(rec.offset), 20.0, 1e-9, "offset_keep 0.5")
	assert_eq(int(rec.n), 7, "n kept at floor(15 x 0.5)")
	assert_eq(str(rec.state), RatingService.RATED, "rated again")


func test_an_injury_mastery_or_khi_van_is_not_a_build_change_but_a_stage_is_ac_pr_07_08() -> void:
	# Regression (2026-11-14 play session): the build signature read chiến lực, which an injury lowers, so every
	# injury and every season of recovery made the fighter Stale and re-ran its panel.
	var gd := game_data()
	var db := WorldDB.new()
	var rs := RatingService.new(gd, db)
	var builds := BuildGenerator.new(gd, TestFixtures.tree(), db)
	var c := TestFixtures.character({"hoa": 50}, 50, 1, 0)
	c.id = "p7"
	var rec: Dictionary = c.to_dict()
	rec["power"] = builds.power_of(c)
	db.put("people", rec)
	var r: Dictionary = rs.refresh_person(rec)
	r["state"] = RatingService.RATED
	r["sig"] = rs.build_sig(rec)
	r["version"] = str(rs.knob("data_version"))
	rec["vitality"] = 0.5
	builds.refresh_power("p7")
	rs.refresh_person(rec)
	assert_eq(str(r.state), RatingService.RATED, "an injury is not a build change")
	for k in rec.get("techniques", {}):
		rec.techniques[k]["mastery"] = float(rec.techniques[k].get("mastery", 0.0)) + 10.0
	rs.refresh_person(rec)
	assert_eq(str(r.state), RatingService.RATED, "a season's mastery is not a build change")
	rec.thien_phu["khi_van"] = int(rec.thien_phu.get("khi_van", 50)) + 10
	rs.refresh_person(rec)
	assert_eq(str(r.state), RatingService.RATED, "gaining khí vận is not (AC-PR-08)")
	var saved: Dictionary = JSON.parse_string(JSON.stringify(rec))
	assert_eq(rs.build_sig(saved), rs.build_sig(rec), "a save and load leaves the signature unchanged")
	rec["stage"] = 1
	rs.refresh_person(rec)
	assert_eq(str(r.state), RatingService.STALE, "a stage change is (AC-PR-07)")
