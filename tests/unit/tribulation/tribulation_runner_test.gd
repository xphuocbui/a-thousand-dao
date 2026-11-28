extends DaoTestSuite
## Heavenly Tribulation wave runner, setup contract, determinism, and real Combat integration
## (design/gdd/thien-kiep.md, AC-TK-06..09, AC-TK-22..24).


static func _fx_pool() -> Array:
	return [
		{"id": "B1", "name": "B1", "main_kind": "body", "weight": 2.0, "boss_pool_mult": 1.0, "reward": {"kind": "material", "template": "loi_kich_moc", "qty": 1, "rarity": 5}},
		{"id": "Q1", "name": "Q1", "main_kind": "qi", "weight": 2.0, "boss_pool_mult": 1.0, "reward": {"kind": "material", "template": "dia_hoa_tinh", "qty": 1, "rarity": 4}},
		{"id": "S1", "name": "S1", "main_kind": "soul", "weight": 2.0, "boss_pool_mult": 1.0, "reward": {"kind": "treasure", "template": "dao_an", "qty": 1, "rarity": 4}},
	]


func test_dt_stage_loss_never_retriggers_tribulation_ac06() -> void:
	var base := game_data()
	var files_copy: Dictionary = base.registry.files().duplicate()
	var tk_rules: Dictionary = base.file("tribulation_rules").duplicate(true)
	tk_rules["tribulation_enabled"] = true
	files_copy["tribulation_rules"] = tk_rules
	var gd := GameData.new()
	gd.setup(DataRegistry.from_files(files_copy))

	var c := TestFixtures.character({"hoa": 60}, 60)
	c.realm_index = 4   # Deity Transformation
	c.level = 107
	c.level_peak = 107
	c.stage = 2
	CultivationRules.lose_stage(c, gd)
	assert_eq(c.realm_index, 4, "stage loss never crosses a realm")
	assert_false(TribulationRules.should_trigger(gd, c.realm_index), "DT character never faces tribulation again")


func test_lifespan_check_follows_survival_ac07() -> void:
	var gd := game_data()
	var c := TestFixtures.character({"hoa": 60}, 60)
	c.realm_index = 3
	c.level = 100
	c.level_peak = 100
	c.stage = 3
	c.tu_vi = Ladder.bar_cost(gd, 3)
	var sheet_before := StatSheet.build(c, gd, null, null)
	var cap_before: float = CultivationRules.lifespan(c, gd, sheet_before).total
	# 1 season (0.25 yr) of lifespan left before attempting breakthrough
	c.age = cap_before - 0.25
	assert_true(c.age < cap_before, "alive before attempt")
	# Survive tribulation -> enter DT -> age advances by 1 season AFTER survival
	CultivationRules.enter_next_realm(c, gd)
	c.age += 0.25
	var sheet_after := StatSheet.build(c, gd, null, null)
	var cap_after: float = CultivationRules.lifespan(c, gd, sheet_after).total
	assert_true(cap_after > cap_before, "DT lifespan cap is higher (%.0f > %.0f)" % [cap_after, cap_before])
	assert_true(c.age < cap_after, "age check after survival sees new DT lifespan cap")


func test_three_ordered_requests_and_setup_consistency_ac08_ac22_ac23_ac24() -> void:
	var gd := game_data()
	var prof := FighterCompiler.from_data("typical", 3, gd)
	prof.stage_mult = Ladder.stage_mult(gd, 3)   # Nascent Soul great perfection: 1.45
	var captured: Array = []
	var fn := func(req: FightRequest, _ctx: Dictionary) -> FightResult:
		captured.append({
			"a_id": req.a.id,
			"a_realm": req.a.realm,
			"a_stage_mult": req.a.stage_mult,
			"a_ward_pts": req.a.ward_pts,
			"a_arts": req.a.arts.map(func(x): return str(x.id)),
			"b_id": req.b.id,
			"b_realm": req.b.realm,
			"situation": req.situation,
			"ground_tags": req.ground_tags.duplicate(),
			"no_heal": req.no_heal,
		})
		var r := FightResult.new()
		r.winner = FightResult.Winner.A
		r.ending = FightResult.Ending.KNOCKOUT
		r.seconds = 9.0
		r.deciding_layer = 0
		r.a_end = FighterEnd.new()
		r.a_end.health = 5000.0
		r.a_end.health_max = 6400.0
		r.a_end.linh_luc = 1800.0
		r.a_end.linh_luc_base = 2600.0
		r.b_end = FighterEnd.new()
		return r

	var out: Dictionary = TribulationRunner.run({
		"world_seed": 33,
		"char_id": "ns_gp",
		"step_id": "nguyen_anh_to_hoa_than",
		"pool": _fx_pool(),
		"player_profile": prof,
		"place_tags": [&"vein"],
		"abs_season": 8,
	}, gd, fn)
	assert_true(out.ok and out.survived, "all 3 waves cleared")
	assert_eq(captured.size(), 3, "AC-TK-08: 3 requests sent in order")
	var boss_ids := {}
	for i in 3:
		var c: Dictionary = captured[i]
		boss_ids[c.b_id] = true
		# AC-TK-22: profile, ward, slot order identical across all 3 waves
		assert_eq(c.a_id, captured[0].a_id, "profile matches wave %d" % (i + 1))
		assert_eq(c.a_ward_pts, captured[0].a_ward_pts, "ward matches wave %d" % (i + 1))
		assert_eq(c.a_arts, captured[0].a_arts, "slot order matches wave %d" % (i + 1))
		# AC-TK-23: Foreseen, requester A, ground tags exact [vein, tribulation], no_heal true
		assert_eq(c.situation, FightRequest.Situation.FORESEEN, "situation is Foreseen")
		assert_eq(c.ground_tags, [&"vein", &"tribulation"], "ground tags exact [vein, tribulation]")
		assert_true(bool(c.no_heal), "no_heal set on every tribulation wave")
		# AC-TK-24: player NS GP (realm 3, stage_mult 1.45), boss dest realm 4 -> gap g = 1
		assert_eq(int(c.a_realm), 3, "player realm is Nascent Soul (3)")
		assert_near(float(c.a_stage_mult), 1.45, 1e-6, "player stage_mult is great perfection (1.45)")
		assert_eq(int(c.b_realm), 4, "boss realm is Deity Transformation (4)")
		assert_eq(int(c.b_realm) - int(c.a_realm), 1, "realm gap g = 1")
	assert_eq(boss_ids.size(), 3, "one distinct boss per wave")


func test_identical_inputs_are_byte_identical_with_real_combat_ac09() -> void:
	var gd := game_data()
	var prof := FighterCompiler.from_data("top_end", 3, gd)
	prof.stage_mult = 1.45
	var params := {
		"world_seed": 2026,
		"char_id": "hero_det",
		"step_id": "nguyen_anh_to_hoa_than",
		"player_profile": prof,
		"place_tags": [&"vein"],
		"abs_season": 16,
		"log_enabled": true,
	}
	var r1: Dictionary = TribulationRunner.run(params, gd)
	var r2: Dictionary = TribulationRunner.run(params, gd)
	assert_true(r1.ok and r2.ok, "real Combat tribulation runs cleanly against provisional pool")
	assert_eq(r1.tribulation_id, r2.tribulation_id, "same tribulation_id")
	assert_eq(r1.survived, r2.survived, "same survival verdict")
	assert_eq(r1.waves_cleared, r2.waves_cleared, "same waves_cleared")
	assert_eq(r1.waves.size(), r2.waves.size(), "same wave count")
	for i in r1.waves.size():
		var w1: Dictionary = r1.waves[i]
		var w2: Dictionary = r2.waves[i]
		assert_eq(w1.boss_id, w2.boss_id, "same boss wave %d" % (i + 1))
		assert_eq(w1.winner, w2.winner, "same winner wave %d" % (i + 1))
		assert_eq(w1.ending, w2.ending, "same ending wave %d" % (i + 1))
		assert_eq(w1.seconds, w2.seconds, "same time wave %d" % (i + 1))
		assert_eq(w1.health_end, w2.health_end, "same health_end wave %d" % (i + 1))
		assert_eq(w1.qi_end, w2.qi_end, "same qi_end wave %d" % (i + 1))
		assert_eq(w1.deciding_layer, w2.deciding_layer, "same deciding_layer wave %d" % (i + 1))
		var rows1: Array = (w1.log_rows as Array).map(func(row): return row.to_array())
		var rows2: Array = (w2.log_rows as Array).map(func(row): return row.to_array())
		assert_eq(JSON.stringify(rows1), JSON.stringify(rows2), "byte-identical Combat log wave %d" % (i + 1))
