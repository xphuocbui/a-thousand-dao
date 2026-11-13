extends Node
## Timing spike for the GDScript fight engine (ADR-0001 Risks "Performance of the GDScript hot loop", Validation
## Criteria: a fight resolves in under 50 ms in a headless export build). Runs several fight shapes, 200 seeded fights
## each with the coin order and the log off, and reports p50, p95 and max wall time per fight against the budget.
##
## Slice 1 has no Effects, statuses or stacks, so this measures a lower bound; the spike is repeated after the Effect
## slice, where the many-Effect shape is the real risk.
##
## Run in the export build (preset "Windows Combat Bench", feature combat_bench):
##   build/bench/combat_bench.console.exe --headless -- --runs=200
## or in the editor binary for comparison:
##   godot --headless --path . res://tests/performance/combat/combat_bench.tscn -- --runs=200
## Prints a table and one line "BENCH_JSON {...}". Exit code 0 when every shape's p95 is within the budget, else 1.

const BUDGET_MS := 50.0
const EXPECTED := "res://tests/parity/expected/"


func _ready() -> void:
	var runs := 200
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--runs="):
			runs = int(arg.trim_prefix("--runs="))
	var report: Dictionary = run_all(runs)
	print(table(report))
	print("BENCH_JSON " + JSON.stringify(report))
	get_tree().quit(0 if report.ok else 1)


## The shapes: fighter record pairs in the sim's resolved format, from the parity fixtures' expected files.
static func shapes() -> Array:
	var mirror: Dictionary = _doc("t1_mirror_qr")
	var top_a: Dictionary = (mirror.a as Dictionary).duplicate(true)
	var top_b: Dictionary = (mirror.b as Dictionary).duplicate(true)
	top_a.realm = 4
	top_b.realm = 4
	var gap: Dictionary = _doc("t1_realm_gap")
	var heavy_a: Dictionary = (gap.a as Dictionary).duplicate(true)
	heavy_a.realm = 2
	heavy_a.ward_pts = 1400.0
	var heavy_arts: Array = []
	for i in 8:
		var art: Dictionary = (gap.a.arts[0] as Dictionary).duplicate(true)
		art.name = "heavy-%d" % i
		art.c = 0.9
		art.cost = 0.01
		art.cd = 1.0 + 0.25 * i
		art.split = [0.25, 0.25, 0.25, 0.25]
		art.charges = 2
		heavy_arts.append(art)
	heavy_a.arts = heavy_arts
	var heavy_b: Dictionary = heavy_a.duplicate(true)
	heavy_b.name = "heavy-b"
	return [
		{"id": "mirror_qr", "doc": "typical mirror at Qi Refining, 3 arts each", "a": mirror.a, "b": mirror.b},
		{"id": "mirror_top", "doc": "the same mirror at realm 4", "a": top_a, "b": top_b},
		{"id": "stall", "doc": "heavy wards and regeneration, ends in fatigue", "a": _doc("t1_stall").a, "b": _doc("t1_stall").b},
		{"id": "hazards", "doc": "health costs, heals, restores, splits", "a": _doc("t1_hazards").a, "b": _doc("t1_hazards").b},
		{"id": "art_heavy", "doc": "8 arts with 4-way splits and charges plus a companion, each side", "a": heavy_a, "b": heavy_b},
		{"id": "wards", "doc": "every extra ward model, pieced shields, body shield, conversion (slice 2)",
			"a": _doc("t2_wards_exact").a, "b": _doc("t2_wards_exact").b},
		{"id": "crit_mirror", "doc": "crits, evades and a cast evade ward, each side (slice 2)",
			"a": _doc("t2_crit_evade_mirror").a, "b": _doc("t2_crit_evade_mirror").b},
		{"id": "stacks", "doc": "every element's stacks, ticks, purity, cleansing (slice 3)",
			"a": _doc("t3_stacks_exact").a, "b": _doc("t3_stacks_exact").b},
		{"id": "statuses", "doc": "every status and curse, slots, lockouts, Crossing the Line (slice 3)",
			"a": _doc("t3_statuses_exact").a, "b": _doc("t3_statuses_exact").b},
		{"id": "lib_effects", "doc": "21 library Effects across both sides (slice 4a)",
			"a": _doc("t4_effects_exact_a").a, "b": _doc("t4_effects_exact_a").b},
		{"id": "mechanics", "doc": "counters, held payloads, timed mods, ~30 mod keys, triggers (slice 4a)",
			"a": _doc("t4_mechanics_exact").a, "b": _doc("t4_mechanics_exact").b},
		{"id": "fx_chancy", "doc": "crit and evade Effects with counters and free hits (slice 4a)",
			"a": _doc("t4_effects_chancy").a, "b": _doc("t4_effects_chancy").b},
	]


static func _doc(name: String) -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(EXPECTED + name + ".json"))
	return parsed if parsed is Dictionary else {}


## Runs every shape [param runs] times. Returns {ok, budget_ms, runs, build, shapes: [{id, p50_ms, p95_ms, ...}]}.
static func run_all(runs: int) -> Dictionary:
	var k := CombatConstants.load_file()
	var out := {"ok": true, "budget_ms": BUDGET_MS, "runs": runs, "errors": [],
		"build": "debug" if OS.is_debug_build() else "release", "export": OS.has_feature("template"),
		"engine": Engine.get_version_info().string, "shapes": []}
	if not k.errors.is_empty():
		out.ok = false
		out.errors.append_array(k.errors)
		return out
	for shape in shapes():
		var loader := FighterProfileLoader.new(k)
		var pa: FighterProfile = loader.from_sim_build(shape.a, shape.id + ".a")
		var pb: FighterProfile = loader.from_sim_build(shape.b, shape.id + ".b")
		if not loader.errors.is_empty():
			out.ok = false
			out.errors.append_array(loader.errors)
			continue
		# events per fight, from one logged fight (not timed)
		var logged: FightResult = Fight.new(pa, pb, k, 0, Fight.Order.COIN, true).run()
		for s in 10:   # warm-up
			Fight.new(pa, pb, k, 1000 + s).run()
		var times: Array[float] = []
		var secs := 0.0
		for s in runs:
			var t0: int = Time.get_ticks_usec()
			var r: FightResult = Fight.new(pa, pb, k, s).run()
			times.append((Time.get_ticks_usec() - t0) / 1000.0)
			secs += r.seconds
		times.sort()
		var mean := 0.0
		for x in times:
			mean += x
		mean /= times.size()
		var p95: float = times[mini(times.size() - 1, int(ceil(0.95 * times.size())) - 1)]
		var row := {
			"id": shape.id, "doc": shape.doc, "fight_s": secs / runs, "events": logged.log_rows.size(),
			"mean_ms": mean, "p50_ms": times[times.size() / 2], "p95_ms": p95, "max_ms": times[-1],
			"us_per_event": mean * 1000.0 / maxf(1.0, logged.log_rows.size()),
		}
		out.shapes.append(row)
		if p95 > BUDGET_MS:
			out.ok = false
	return out


## A plain-text table of [param report].
static func table(report: Dictionary) -> String:
	var lines := PackedStringArray()
	lines.append("Combat timing spike: %s %s build (export: %s), %d fights per shape, budget %.0f ms (p95)" % [
		report.engine, report.build, str(report.export), report.runs, report.budget_ms])
	lines.append("%-11s %8s %7s %8s %8s %8s %8s %9s" % ["shape", "fight s", "events", "mean ms", "p50 ms", "p95 ms", "max ms", "us/event"])
	for r in report.shapes:
		lines.append("%-11s %8.1f %7d %8.3f %8.3f %8.3f %8.3f %9.2f" % [r.id, r.fight_s, r.events, r.mean_ms, r.p50_ms,
			r.p95_ms, r.max_ms, r.us_per_event])
	for e in report.errors:
		lines.append("ERROR " + str(e))
	lines.append("RESULT " + ("within budget" if report.ok else "OVER BUDGET or errors"))
	return "\n".join(lines)
