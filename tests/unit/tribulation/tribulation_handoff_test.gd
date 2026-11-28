extends DaoTestSuite
## Heavenly Tribulation hand-off rules (design/gdd/thien-kiep.md, AC-TK-01..04).


func _gate_char(realm_idx: int) -> Character:
	var gd := game_data()
	var c := TestFixtures.character({"hoa": 60}, 60)
	c.realm_index = realm_idx
	c.level = Ladder.band(gd, realm_idx)[1]
	c.level_peak = c.level
	c.stage = Ladder.stage_of_level(gd, c.level)
	c.tu_vi = Ladder.bar_cost(gd, realm_idx)
	c.has_insight = true
	return c


func _gd_with_enabled(enabled: bool) -> GameData:
	var base := game_data()
	var files_copy: Dictionary = base.registry.files().duplicate()
	var tk_rules: Dictionary = base.file("tribulation_rules").duplicate(true)
	tk_rules["tribulation_enabled"] = enabled
	files_copy["tribulation_rules"] = tk_rules
	var gd := GameData.new()
	gd.setup(DataRegistry.from_files(files_copy))
	return gd


func test_listed_step_triggers_and_defers_realm_entry_ac01() -> void:
	var gd := _gd_with_enabled(true)
	var c := _gate_char(3)   # Nascent Soul great perfection -> Deity Transformation
	assert_true(TribulationRules.should_trigger(gd, c.realm_index), "listed step triggers when enabled")
	var step: Dictionary = TribulationRules.step_for(gd, c.realm_index)
	assert_eq(str(step.id), "nguyen_anh_to_hoa_than", "step id")
	var sheet := StatSheet.build(c, gd, null, null)
	var res: Dictionary = CultivationRules.resolve_attempt(c, gd, sheet, ScriptedRng.new(["U", 0.0]), 0.5, true, true)
	assert_true(res.success and res.deferred, "roll succeeded and deferred realm advance")
	assert_eq(c.realm_index, 3, "character stays at Nascent Soul during tribulation")
	assert_eq(c.level, 100, "character stays at level 100 during tribulation")
	assert_eq(res.points, 0, "points are not paid before surviving")
	var pts: int = CultivationRules.enter_next_realm(c, gd)
	assert_eq(c.realm_index, 4, "enters Deity Transformation on survival")
	assert_eq(c.level, 101, "level 101 early DT")
	assert_eq(c.stage, 0, "early stage")
	assert_eq(c.tu_vi, 0.0, "bar reset")
	assert_eq(c.vitality, 1.0, "full vitality on survival")
	assert_true(pts > 0, "realm breakthrough points paid after survival")


func test_unlisted_step_skips_tribulation_and_advances_ac02() -> void:
	var gd := _gd_with_enabled(true)
	for realm_idx in [0, 1, 2]:
		assert_false(TribulationRules.should_trigger(gd, realm_idx), "realm %d is unlisted" % realm_idx)
		assert_true(TribulationRules.step_for(gd, realm_idx).is_empty(), "no step row for realm %d" % realm_idx)
	var c := _gate_char(2)   # Core Formation -> Nascent Soul (unlisted)
	var sheet := StatSheet.build(c, gd, null, null)
	var res: Dictionary = CultivationRules.resolve_attempt(c, gd, sheet, ScriptedRng.new(["U", 0.0]), 0.5, true, false)
	assert_true(res.success and not res.deferred, "unlisted step advances immediately")
	assert_eq(c.realm_index, 3, "entered Nascent Soul")


func test_capability_23_extra_roll_triggers_one_tribulation_ac03() -> void:
	var gd := _gd_with_enabled(true)
	var c := _gate_char(3)
	var sheet := StatSheet.build(c, gd, null, null)
	# First roll fails (0.99 >= 0.5); capability #23 retry roll succeeds (0.0 < q_retry) with defer_advance=true
	var r1: Dictionary = CultivationRules.resolve_attempt(c, gd, sheet, ScriptedRng.new(["U", 0.99, "U", 0.99]), 0.5, true, true)
	assert_false(r1.success, "first roll fails")
	var retry_q: float = CultivationRules.q_retry(gd, 0.5, CultivationRules.failure_insight(gd, c.failed_pills), 0.5, CultivationRules.gate_factor(c, gd))
	assert_true(retry_q > 0.0, "retry chance positive")
	var r2: Dictionary = CultivationRules.resolve_attempt(c, gd, sheet, ScriptedRng.new(["U", 0.0]), retry_q, true, true)
	assert_true(r2.success and r2.deferred, "retry roll succeeds and hands off to tribulation")
	assert_true(TribulationRules.should_trigger(gd, c.realm_index), "one tribulation starts for the retry success")
	assert_eq(c.realm_index, 3, "still at pre-breakthrough realm until waves clear")


func test_disabled_flag_keeps_realms_fallback_ac04() -> void:
	var live_gd := game_data()
	assert_true(TribulationRules.is_enabled(live_gd), "default tribulation_enabled in live data is true")
	assert_true(TribulationRules.should_trigger(live_gd, 3), "listed step triggers by default on live data")
	assert_false(TribulationRules.should_trigger(live_gd, 3, false), "session toggle OFF disables tribulation on live data")
	var gd := _gd_with_enabled(false)
	assert_false(TribulationRules.is_enabled(gd), "config tribulation_enabled=false disables tribulation")
	assert_false(TribulationRules.should_trigger(gd, 3), "does not trigger when tribulation_enabled is false")
	var c := _gate_char(3)
	var sheet := StatSheet.build(c, gd, null, null)
	var defer: bool = TribulationRules.should_trigger(gd, c.realm_index)
	var res: Dictionary = CultivationRules.resolve_attempt(c, gd, sheet, ScriptedRng.new(["U", 0.0]), 0.5, true, defer)
	assert_true(res.success and not res.deferred, "Realms fallback stands")
	assert_eq(c.realm_index, 4, "crosses directly into Deity Transformation when disabled")
