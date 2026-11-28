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


func _gd_with_cast_ratings(patch_cast: Variant) -> GameData:
	var base := game_data()
	var files_copy: Dictionary = base.registry.files().duplicate()
	if patch_cast == null:
		files_copy.erase(RatingService.CAST_RATINGS_FILE)
	else:
		files_copy[RatingService.CAST_RATINGS_FILE] = patch_cast
	var gd := GameData.new()
	gd.setup(DataRegistry.from_files(files_copy))
	return gd


func _make_cast_person(id: String, cast_key: String, realm: int, alive: bool = true) -> Dictionary:
	var c := TestFixtures.character({"hoa": 60}, 55, realm, 0)
	c.id = id
	c.alive = alive
	var rec: Dictionary = c.to_dict()
	rec["cast_key"] = cast_key
	return rec


func test_shipped_cast_ratings_file_matches_headers_and_counts_ac_pr_58() -> void:
	var shipped := GameData.load_from("res://assets/data")
	assert_true(shipped.registry.has_file(RatingService.CAST_RATINGS_FILE), "cast_ratings.json is loaded by DataRegistry")
	var pre: Dictionary = shipped.file(RatingService.CAST_RATINGS_FILE)
	var hist: Dictionary = shipped.file(WorldBuilder.HISTORY_FILE)
	assert_eq(int(pre.get("schema_version", 0)), 1, "schema_version is 1")
	assert_eq(str(pre.get("data_version", "")), str(shipped.file(RatingLadder.DATA_FILE).get("data_version", "")), "data_version matches combat_rankings.json")
	assert_eq(int(pre.get("world_data_version", -1)), int(hist.get("world_data_version", 0)), "world_data_version matches world_history.json")
	assert_eq(str(pre.get("world_history_version", "")), str(hist.get("data_version", "")), "world_history_version matches world_history.json")
	assert_eq(str(pre.get("asset_digest", "")), RatingService.cast_asset_digest(shipped), "asset_digest matches shipped combat/build data")
	assert_eq(int(pre.get("cast_count", 0)), 1748, "1,748 living authored cast")
	assert_eq(int(pre.get("beast_count", 0)), 21, "21 living authored beasts")
	assert_eq(int(pre.get("count", 0)), 1769, "1,769 total precomputed entries")
	var entries: Dictionary = pre.get("entries", {})
	assert_eq(entries.size(), 1769, "entries dictionary has 1,769 keys")
	assert_true(float(entries["thoi_khinh_hong"].base) > float(entries["mac_quy_khu"].base), "thoi_khinh_hong > mac_quy_khu on base rating")


func test_precomputed_cast_loads_matching_entries_and_reacts_to_build_changes_ac_pr_58() -> void:
	var base_gd := game_data()
	var db := WorldDB.new()
	var living_p: Dictionary = _make_cast_person("p1", "cast_live", 2, true)
	var dead_p: Dictionary = _make_cast_person("p2", "cast_dead", 2, false)
	db.put("people", living_p)
	db.put("people", dead_p)
	var tmp_rs := RatingService.new(base_gd, db)
	var sig_live: String = tmp_rs.build_sig(living_p)
	var sig_dead: String = tmp_rs.build_sig(dead_p)
	var hist: Dictionary = base_gd.file(WorldBuilder.HISTORY_FILE)
	var payload := {
		"schema_version": 1,
		"data_version": str(tmp_rs.knob("data_version")),
		"world_data_version": int(hist.get("world_data_version", 0)),
		"world_history_version": str(hist.get("data_version", "")),
		"asset_digest": RatingService.cast_asset_digest(base_gd),
		"entries": {
			"cast_live": {"base": 44123.44, "realm": 2, "sig": sig_live, "fights": 36},
			"cast_dead": {"base": 44000.0, "realm": 2, "sig": sig_dead, "fights": 36},
		},
	}
	var gd := _gd_with_cast_ratings(payload)
	var rs := RatingService.new(gd, db)
	var out: Dictionary = rs.worldgen(99, null, null, "")
	assert_eq(int(out.precomputed_cast), 1, "only living cast applied")
	assert_eq(int(out.coarse_panels), 0, "0 coarse panels spent on precomputed cast")
	assert_eq(int(out.fights), 0, "0 worldgen fights spent on precomputed cast")
	var rec: Dictionary = db.get_record(RatingService.TABLE, "p1")
	assert_eq(str(rec.state), RatingService.RATED, "matching cast starts Rated")
	assert_near(float(rec.base), 44123.4, 1e-9, "base snapped to 0.1")
	assert_near(float(rec.offset), 0.0, 1e-9, "offset starts at 0.0")
	assert_eq(int(rec.n), 0, "n starts at 0 (panel fights do not count)")
	assert_eq(str(rec.sig), sig_live, "sig recorded")
	assert_true(db.get_record(RatingService.TABLE, "p2").is_empty(), "dead cast never rated")
	# Post-load build change marks Rated -> Stale; realm breakthrough marks -> Provisional.
	living_p["stage"] = 1
	rs.refresh_person(living_p)
	assert_eq(str(rec.state), RatingService.STALE, "stage change after load marks cast Stale")
	living_p["realm_index"] = 3
	rs.refresh_person(living_p)
	assert_eq(str(rec.state), RatingService.PROVISIONAL, "realm breakthrough marks cast Provisional")


func test_precomputed_cast_falls_back_on_header_digest_realm_or_sig_mismatch_ac_pr_58() -> void:
	var base_gd := game_data()
	var hist: Dictionary = base_gd.file(WorldBuilder.HISTORY_FILE)
	var data_ver: String = str(base_gd.file(RatingLadder.DATA_FILE).get("data_version", ""))
	var wdv: int = int(hist.get("world_data_version", 0))
	var whv: String = str(hist.get("data_version", ""))
	var digest: String = RatingService.cast_asset_digest(base_gd)

	var make_valid := func(sig_a: String, sig_b: String) -> Dictionary:
		return {
			"schema_version": 1,
			"data_version": data_ver,
			"world_data_version": wdv,
			"world_history_version": whv,
			"asset_digest": digest,
			"entries": {
				"cast_a": {"base": 45000.0, "realm": 2, "sig": sig_a, "fights": 36},
				"cast_b": {"base": 46000.0, "realm": 2, "sig": sig_b, "fights": 36},
			},
		}

	# Header / missing file mismatches abort precompute completely and fall back to Rule 16 (coarse panel -> STALE).
	var bad_cases: Array = [
		["missing file", null],
		["schema_version", func(d: Dictionary): d["schema_version"] = 2],
		["data_version", func(d: Dictionary): d["data_version"] = "stale_ver"],
		["world_data_version", func(d: Dictionary): d["world_data_version"] = wdv + 99],
		["world_history_version", func(d: Dictionary): d["world_history_version"] = "old_hist"],
		["asset_digest", func(d: Dictionary): d["asset_digest"] = "0000000000000000"],
	]
	for bc in bad_cases:
		var db := WorldDB.new()
		var pa: Dictionary = _make_cast_person("p1", "cast_a", 2, true)
		db.put("people", pa)
		var sig_a: String = RatingService.new(base_gd, db).build_sig(pa)
		var payload: Variant = null
		if bc[1] != null:
			payload = make_valid.call(sig_a, sig_a)
			(bc[1] as Callable).call(payload)
		var gd := _gd_with_cast_ratings(payload)
		var rs := RatingService.new(gd, db)
		var out: Dictionary = rs.worldgen(77, null, null, "")
		assert_eq(int(out.precomputed_cast), 0, "%s mismatch applies 0 precomputed cast" % str(bc[0]))
		assert_eq(str(db.get_record(RatingService.TABLE, "p1").state), RatingService.STALE, "%s falls back to Rule 16 coarse panel" % str(bc[0]))

	# Per-person sig or realm mismatch skips only the mismatched person; valid cast_b still loads as RATED.
	var db2 := WorldDB.new()
	var pa2: Dictionary = _make_cast_person("p1", "cast_a", 2, true)
	var pb2: Dictionary = _make_cast_person("p2", "cast_b", 2, true)
	db2.put("people", pa2)
	db2.put("people", pb2)
	var tmp2 := RatingService.new(base_gd, db2)
	var partial: Dictionary = make_valid.call("wrong_sig", tmp2.build_sig(pb2))
	var gd2 := _gd_with_cast_ratings(partial)
	var rs2 := RatingService.new(gd2, db2)
	var out2: Dictionary = rs2.worldgen(78, null, null, "")
	assert_eq(int(out2.precomputed_cast), 1, "only matching cast_b loaded")
	assert_eq(str(db2.get_record(RatingService.TABLE, "p1").state), RatingService.STALE, "sig-mismatched cast_a fell back to Rule 16")
	assert_eq(str(db2.get_record(RatingService.TABLE, "p2").state), RatingService.RATED, "matching cast_b started Rated")

	var db3 := WorldDB.new()
	var pa3: Dictionary = _make_cast_person("p1", "cast_a", 2, true)
	db3.put("people", pa3)
	var bad_realm: Dictionary = make_valid.call(RatingService.new(base_gd, db3).build_sig(pa3), "unused")
	bad_realm.entries["cast_a"]["realm"] = 3
	var rs3 := RatingService.new(_gd_with_cast_ratings(bad_realm), db3)
	var out3: Dictionary = rs3.worldgen(79, null, null, "")
	assert_eq(int(out3.precomputed_cast), 0, "realm-mismatched entry skipped")
	assert_eq(str(db3.get_record(RatingService.TABLE, "p1").state), RatingService.STALE, "realm-mismatched entry fell back to Rule 16")
