extends DaoTestSuite
## BuildFileCompiler against fight.py (ADR-0001 step 3): every case in tests/parity/compile/compile_cases.json, written
## by tools/design/combat_sim/compile_parity_export.py, must compile to the same resolved fighter record and the same
## unmodelled report, and the record must load. The cases hold every named item and every library art.

const CASES := "res://tests/parity/compile/compile_cases.json"
const TOL := 1e-9
## Arts the Godot loader refuses on purpose, waiting on a content decision: art id -> the error it must give. Empty
## since 2026-11-14 (reckless-gale's step hp_cost now runs in both engines).
const KNOWN_REFUSALS := {}


static func _cases() -> Array:
	var f := FileAccess.open(CASES, FileAccess.READ)
	return JSON.parse_string(f.get_as_text()).cases


## The first path where [param got] and [param want] differ, or "" when they agree (numbers within TOL).
static func _diff(got: Variant, want: Variant, path: String) -> String:
	if (got is float or got is int) and (want is float or want is int):
		var g: float = float(got)
		var w: float = float(want)
		return "" if absf(g - w) <= TOL * maxf(1.0, absf(w)) else "%s: %s vs %s" % [path, str(g), str(w)]
	if got is Dictionary and want is Dictionary:
		for k in want:
			if not got.has(k):
				return "%s.%s: missing" % [path, str(k)]
			var d: String = _diff(got[k], want[k], "%s.%s" % [path, str(k)])
			if d != "":
				return d
		for k in got:
			if not want.has(k):
				return "%s.%s: extra" % [path, str(k)]
		return ""
	if got is Array and want is Array:
		if got.size() != want.size():
			return "%s: %d items vs %d" % [path, got.size(), want.size()]
		for i in want.size():
			var d: String = _diff(got[i], want[i], "%s[%d]" % [path, i])
			if d != "":
				return d
		return ""
	if got == null and want == null:
		return ""
	if typeof(got) != typeof(want) or got != want:
		return "%s: %s vs %s" % [path, str(got), str(want)]
	return ""


func test_every_case_compiles_like_fight_py() -> void:
	var gd := game_data()
	var bfc := BuildFileCompiler.new(gd)
	assert_true(bfc.errors.is_empty(), "library loads: %s" % "; ".join(bfc.errors))
	var cases: Array = _cases()
	assert_true(cases.size() >= 50, "the cases are there (%d)" % cases.size())
	for c in cases:
		assert_false(c.has("refused"), "%s: fight.py refused it: %s" % [c.name, str(c.get("refused"))])
		var rec: Dictionary = bfc.compile(c.input)
		assert_true(bfc.errors.is_empty(), "%s compiles: %s" % [c.name, "; ".join(bfc.errors)])
		assert_eq(_diff(rec, c.build, c.name), "", "%s matches fight.py" % c.name)
		assert_eq(_diff(Array(bfc.unmodelled), c.unmodelled, c.name + ".unmodelled"), "", "%s report" % c.name)


func test_every_compiled_record_loads() -> void:
	var gd := game_data()
	var bfc := BuildFileCompiler.new(gd)
	var loader := FighterProfileLoader.new(CombatConstants.from_game_data(gd))
	var refused_as_known := 0
	for c in _cases():
		var rec: Dictionary = bfc.compile(c.input)
		var p: FighterProfile = loader.from_sim_build(rec, c.name)
		var known: Array = KNOWN_REFUSALS.keys().filter(func(id): return c.input.arts.any(func(a): return a.lib == id))
		if p == null and not known.is_empty():
			# only the known refusal, nothing else
			for e in loader.errors:
				assert_true(KNOWN_REFUSALS.values().any(func(m): return e.contains(m)), "%s: only the known refusal: %s" % [c.name, e])
			refused_as_known += 1
		else:
			assert_true(p != null, "%s loads: %s" % [c.name, "; ".join(loader.errors)])
		loader.errors = []
	assert_eq(refused_as_known, KNOWN_REFUSALS.size(), "each known refusal still refuses (remove it here once decided)")


func test_the_cases_cover_every_item_and_art() -> void:
	var lib: Dictionary = game_data().file("combat_library")
	var items := {}
	var arts := {}
	for c in _cases():
		for i in c.input.items:
			items[i] = true
		for a in c.input.arts:
			arts[a.lib] = true
	assert_eq(items.size(), lib.items.size(), "every named item")
	assert_eq(arts.size(), lib.arts.size(), "every library art")


func test_fields_a_character_does_not_have_are_refused_by_name() -> void:
	var bfc := BuildFileCompiler.new(game_data())
	var c: Dictionary = _cases()[0].input.duplicate(true)
	c["keystones"] = {"k_art": 0.1}
	assert_true(bfc.compile(c).is_empty(), "refused")
	assert_true("; ".join(bfc.errors).contains("keystones"), "named: %s" % "; ".join(bfc.errors))
