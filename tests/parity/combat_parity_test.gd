extends DaoTestSuite
## ADR-0001 decision 4: the parity suite. Each chance-free fixture's expected file (tests/parity/expected/, written
## by tools/design/combat_sim/parity_export.py from tests/parity/fixtures/) must be matched exactly by the GDScript
## engine with the fixed order: the same event rows, every number within 1e-6, the same winner and end state.
## Regenerate the expected files after a sim change: python -I tools/design/combat_sim/parity_export.py

const EXPECTED_DIR := "res://tests/parity/expected/"
const TOL := 1e-6
## The fixtures each slice added; the suite fails if any goes missing.
const SLICE_1 := ["t1_hazards", "t1_mirror_qr", "t1_realm_gap", "t1_stall"]
const SLICE_2 := ["t2_wards_exact", "t2_shield_cycles", "t2_crit_evade_mirror", "t2_crit_vs_wards"]
const SLICE_3 := ["t3_stacks_exact", "t3_statuses_exact", "t3_soul_exact", "t3_chancy_marks"]
const SLICE_4 := ["t4_effects_exact_a", "t4_effects_exact_b", "t4_mechanics_exact", "t4_sealed_exact", "t4_effects_chancy",
	"t4b_library_exact", "t4b_mechanics_exact", "t4b_chancy"]
const SLICE_5 := ["t5_steps_exact_1", "t5_steps_exact_2", "t5_chancy"]
## ADR-0001 decision 4 (amended 2026-11-13): chancy fixtures over 1,000 seeds; mean fight time within 5 %, each win
## share within 0.05 of the sim's reference (which parity_export.py takes over 10x the seeds).
const TIME_TOL := 0.05
const SHARE_TOL := 0.05


static func _read(path: String) -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed if parsed is Dictionary else {}


static func _constants() -> CombatConstants:
	return CombatConstants.load_file()


## Loads both fighters of an expected file. Returns [a, b], or [] with the loader's errors in [param out_errors].
static func _profiles(doc: Dictionary, name: String, k: CombatConstants, out_errors: Array) -> Array:
	var loader := FighterProfileLoader.new(k)
	var a: FighterProfile = loader.from_sim_build(doc.a, name + ".a")
	var b: FighterProfile = loader.from_sim_build(doc.b, name + ".b")
	out_errors.append_array(loader.errors)
	return [a, b] if loader.errors.is_empty() else []


## The first difference between two rows, or "".
static func _row_diff(got: Array, want: Array) -> String:
	if got.size() != want.size():
		return "row length %d, sim %d: %s vs %s" % [got.size(), want.size(), str(got), str(want)]
	for j in want.size():
		var w: Variant = want[j]
		var g: Variant = got[j]
		if w is String:
			if str(g) != w:
				return "field %d is %s, sim %s: %s vs %s" % [j, str(g), w, str(got), str(want)]
		elif absf(float(g) - float(w)) > TOL:
			return "field %d is %.9f, sim %.9f (diff %s): %s vs %s" % [j, float(g), float(w), str(float(g) - float(w)), str(got), str(want)]
	return ""


## Compares a run with an expected file. Returns the first difference, or "".
static func _compare(doc: Dictionary, r: FightResult) -> String:
	var rows: Array = doc.rows
	var n: int = mini(rows.size(), r.log_rows.size())
	for i in n:
		var d: String = _row_diff(r.log_rows[i].to_array(), rows[i])
		if d != "":
			return "row %d: %s" % [i, d]
	if r.log_rows.size() != rows.size():
		return "%d rows, sim %d" % [r.log_rows.size(), rows.size()]
	var res: Dictionary = doc.result
	if r.t_ms != int(res.t_ms):
		return "ended at %d ms, sim %d" % [r.t_ms, int(res.t_ms)]
	if r.win_code() != str(res.win):
		return "win %s, sim %s" % [r.win_code(), str(res.win)]
	for side in [["A", r.a_end], ["B", r.b_end]]:
		var want: Dictionary = res[side[0]]
		var e: FighterEnd = side[1]
		for pair in [["hp", e.health], ["qi", e.linh_luc], ["hp_max", e.health_max], ["qi_base", e.linh_luc_base],
				["dealt", e.dealt], ["spent", e.spent], ["fat", e.fatigue], ["healed", e.healed],
				["ward_paid", e.ward_paid]]:
			if absf(float(pair[1]) - float(want[pair[0]])) > TOL:
				return "%s %s is %.9f, sim %.9f" % [side[0], pair[0], float(pair[1]), float(want[pair[0]])]
		if Array(e.fired) != want.fired.map(func(x): return int(x)):
			return "%s fired %s, sim %s" % [side[0], str(e.fired), str(want.fired)]
		if e.down != bool(want.down):
			return "%s down %s, sim %s" % [side[0], str(e.down), str(want.down)]
	return ""


func test_the_constants_load_from_the_shared_file() -> void:
	var k := _constants()
	assert_true(k.errors.is_empty(), "combat_engine.json loads: %s" % "; ".join(k.errors))
	assert_eq(k.pulse_ms, 1000, "a pulse is 1000 ms")


func test_every_slice_fixture_has_an_expected_file() -> void:
	for name in SLICE_1 + SLICE_2 + SLICE_3 + SLICE_4 + SLICE_5:
		assert_true(FileAccess.file_exists(EXPECTED_DIR + name + ".json"), "%s.json is there" % name)


func test_every_chance_free_fixture_matches_the_sim_exactly() -> void:
	var k := _constants()
	var ran := 0
	for file in DirAccess.get_files_at(EXPECTED_DIR):
		if not file.ends_with(".json"):
			continue
		var doc := _read(EXPECTED_DIR + file)
		if not bool(doc.get("chance_free", false)):
			continue
		var errs: Array = []
		var pr: Array = _profiles(doc, file, k, errs)
		assert_true(errs.is_empty(), "%s loads: %s" % [file, "; ".join(errs)])
		if pr.is_empty():
			continue
		var r: FightResult = Fight.new(pr[0], pr[1], k, int(doc.seed), Fight.Order.FIXED, true).run()
		var diff: String = _compare(doc, r)
		assert_eq(diff, "", "%s matches the sim" % file)
		ran += 1
	assert_true(ran >= SLICE_1.size(), "ran %d chance-free fixtures" % ran)


func test_the_same_profiles_fight_twice_the_same_way() -> void:
	# ADR-0001 Risks: GDScript has no immutable objects, so a fight that wrote to a cached profile would change the
	# next fight. Two fights from the same profile objects must give the same rows.
	var k := _constants()
	var doc := _read(EXPECTED_DIR + "t1_hazards.json")
	var errs: Array = []
	var pr: Array = _profiles(doc, "t1_hazards", k, errs)
	assert_true(not pr.is_empty(), "loads")
	if pr.is_empty():
		return
	var first: FightResult = Fight.new(pr[0], pr[1], k, 3, Fight.Order.FIXED, true).run()
	var second: FightResult = Fight.new(pr[0], pr[1], k, 3, Fight.Order.FIXED, true).run()
	assert_eq(second.log_rows.size(), first.log_rows.size(), "same row count")
	var same := true
	for i in first.log_rows.size():
		if first.log_rows[i].to_array() != second.log_rows[i].to_array():
			same = false
			break
	assert_true(same, "every row the same")


func test_the_coin_order_is_seeded_and_fair_in_a_mirror() -> void:
	# ADR-0001 (amended 2026-11-13): a coin at each moment decides who acts first. The same seed replays the same
	# fight; over many seeds an exact mirror is won by both sides (A-first would win it every time).
	var k := _constants()
	var doc := _read(EXPECTED_DIR + "t1_mirror_qr.json")
	var errs: Array = []
	var pr: Array = _profiles(doc, "t1_mirror_qr", k, errs)
	if pr.is_empty():
		assert_true(false, "mirror loads: %s" % "; ".join(errs))
		return
	var r1: FightResult = Fight.new(pr[0], pr[1], k, 42).run()
	var r2: FightResult = Fight.new(pr[0], pr[1], k, 42).run()
	assert_eq(r2.t_ms, r1.t_ms, "same seed, same end time")
	assert_eq(r2.win_code(), r1.win_code(), "same seed, same winner")
	var wins := {"A": 0, "B": 0, "draw": 0, "time": 0}
	for s in 60:
		var r: FightResult = Fight.new(pr[0], pr[1], k, s).run()
		wins[r.win_code()] += 1
	assert_true(wins.A > 0 and wins.B > 0, "both sides win some mirrors: %s" % str(wins))


func test_every_chancy_fixture_matches_the_sim_statistically() -> void:
	var k := _constants()
	var ran := 0
	for file in DirAccess.get_files_at(EXPECTED_DIR):
		if not file.ends_with(".json"):
			continue
		var doc := _read(EXPECTED_DIR + file)
		if bool(doc.get("chance_free", true)):
			continue
		var errs: Array = []
		var pr: Array = _profiles(doc, file, k, errs)
		assert_true(errs.is_empty(), "%s loads: %s" % [file, "; ".join(errs)])
		if pr.is_empty():
			continue
		var n: int = int(doc.seeds)
		var wins := {"A": 0, "B": 0, "draw": 0, "time": 0}
		var total_t := 0.0
		for s in n:
			var r: FightResult = Fight.new(pr[0], pr[1], k, s).run()
			wins[r.win_code()] += 1
			total_t += r.seconds
		var want: Dictionary = doc.stats
		var mean_t: float = total_t / n
		var rel: float = absf(mean_t - float(want.mean_t)) / float(want.mean_t)
		print("PARITY %s: GDScript %d seeds mean %.2f s, A %.3f B %.3f draw %.3f | sim %d seeds mean %.2f s, A %.3f B %.3f draw %.3f" % [
			file, n, mean_t, float(wins.A) / n, float(wins.B) / n, float(wins.draw) / n, int(doc.get("ref_seeds", n)),
			float(want.mean_t), float(want.share.A), float(want.share.B), float(want.share.draw)])
		assert_true(rel <= TIME_TOL, "%s mean fight %.2f s, sim %.2f s (%.1f %%)" % [file, mean_t, float(want.mean_t), rel * 100.0])
		for key in wins:
			var share: float = float(wins[key]) / n
			assert_near(share, float(want.share[key]), SHARE_TOL, "%s %s share over %d seeds" % [file, key, n])
		ran += 1
	assert_true(ran >= 2, "ran %d chancy fixtures" % ran)
