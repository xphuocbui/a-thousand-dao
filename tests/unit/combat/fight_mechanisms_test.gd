extends DaoTestSuite
## Mechanism tests of the GDScript fight engine, slice 1 (ADR-0001: the sim's mechanism tests become GdUnit tests with
## the same names and numbers). Ported from tools/design/combat_sim/test_engine.py: t_split (R23), t_charges,
## t_hp_cost, t_ward_bill (AC-CD-84). The others land with their slices. Fighters are built like the sim's dummy():
## the sim's Build defaults (tests/parity/sim_defaults.json, written by parity_export.py), no crit, no arts.

const DEFAULTS_PATH := "res://tests/parity/sim_defaults.json"


static func _defaults() -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(DEFAULTS_PATH))
	return parsed if parsed is Dictionary else {}


## The sim's dummy(**kw): defaults, crit 0, no arts, then [param fields]; [param arts] are merged over the art
## defaults.
static func _dummy(fields: Dictionary = {}, arts: Array = []) -> Dictionary:
	var d: Dictionary = _defaults()
	var build: Dictionary = (d.build as Dictionary).duplicate(true)
	build.crit = 0.0
	build.merge(fields, true)
	var list: Array = []
	for a in arts:
		var art: Dictionary = (d.art as Dictionary).duplicate(true)
		art.merge(a, true)
		list.append(art)
	build.arts = list
	return build


static func _fight(a: Dictionary, b: Dictionary, log_on: bool = false) -> Fight:
	var k := CombatConstants.load_file()
	var loader := FighterProfileLoader.new(k)
	var pa: FighterProfile = loader.from_sim_build(a, "a")
	var pb: FighterProfile = loader.from_sim_build(b, "b")
	assert(loader.errors.is_empty(), "; ".join(loader.errors))
	return Fight.new(pa, pb, k, 3, Fight.Order.FIXED, log_on)


func test_split_art_lands_three_sub_hits() -> void:
	# test_engine.py t_split (R23): an art with split [0.4, 0.4, 0.4] lands three sub-hits.
	var f := _fight(_dummy({}, [{"name": "rain", "c": 1.2, "cost": 0.05, "cd": 2.0, "split": [0.4, 0.4, 0.4]}]),
			_dummy(), true)
	f.t = f.a.ready[0]
	f.act(f.a)
	var art_hits := 0
	for row in f.log_rows():
		if row.kind == FightLogRow.Kind.HIT and row.side == "A" and row.art_id == &"rain":
			art_hits += 1
	assert_eq(art_hits, 3, "R23 split hit: 3 sub-hits")


func test_charges_refire_after_cooldown_min_then_wait_the_full_cooldown() -> void:
	# test_engine.py t_charges: two charges; the second firing comes after cooldown_min (500 ms), then the full 4 s.
	var f := _fight(_dummy({}, [{"name": "twin", "c": 1.0, "cost": 0.02, "cd": 4.0, "charges": 2}]), _dummy())
	f.t = f.a.ready[0]
	f.act(f.a)
	var second: int = f.a.ready[0] - f.t
	f.t = f.a.ready[0]
	f.act(f.a)
	assert_eq(second, 500, "second firing after cooldown_min")
	assert_eq(f.a.ready[0] - f.t, 4000, "then the full cooldown")
	assert_eq(f.a.fired[0], 2, "fired twice")


func test_art_paid_in_health_costs_its_share_of_health_max() -> void:
	# test_engine.py t_hp_cost: hp_cost 0.1 takes 10 % of health_max on firing.
	var f := _fight(_dummy({}, [{"name": "blood", "c": 1.0, "cost": 0.04, "cd": 3.0, "hp_cost": 0.1}]), _dummy())
	f.t = f.a.ready[0]
	var hp0: float = f.a.hp
	f.act(f.a)
	assert_near(hp0 - f.a.hp, 0.1 * f.a.hp_max, 1e-6, "art paid in health: 10 % of health_max")


func test_ward_bill_pct_30_raises_the_bill_by_a_third() -> void:
	# test_engine.py t_ward_bill (AC-CD-84): the attacker's ward_bill_pct 30 makes the defender's bill x1.3.
	var k := CombatConstants.load_file()
	var f1 := _fight(_dummy({"ward_bill_pct": 30}), _dummy())
	var q0: float = f1.b.qi
	DefencePath.defend(k, f1.a, f1.b, 100.0, &"phys", null, false)
	var bill: float = q0 - f1.b.qi
	var f2 := _fight(_dummy(), _dummy())
	var q1: float = f2.b.qi
	DefencePath.defend(k, f2.a, f2.b, 100.0, &"phys", null, false)
	assert_near(bill / (q1 - f2.b.qi), 1.3, 1e-6, "AC-CD-84 ward_bill_pct 30 -> bill x1.3")


func test_log_off_builds_no_rows() -> void:
	# ADR-0001: a FightLogRow is built only when the log is on.
	var r: FightResult = _fight(_dummy({}, [{"name": "jab", "c": 1.0}]), _dummy()).run()
	assert_eq(r.log_rows.size(), 0, "no rows with the log off")


func test_loader_refuses_a_chancy_or_unported_field_by_name() -> void:
	var k := CombatConstants.load_file()
	var cases := [
		[_dummy({"crit": 0.15}), "crit"],
		[_dummy({"effects": [{"id": "x", "on": "crit", "do": []}]}), "effects"],
		[_dummy({"teleport": 1.0}), "teleport"],
		[_dummy({}, [{"name": "seal", "statuses": [{"id": "sundered"}]}]), "statuses"],
		[_dummy({}, [{"name": "dream", "pool": "tam_ma"}]), "pool"],
	]
	for c in cases:
		var loader := FighterProfileLoader.new(k)
		var p: FighterProfile = loader.from_sim_build(c[0], "case")
		assert_true(p == null, "%s is refused" % c[1])
		assert_true("; ".join(loader.errors).contains(c[1]), "the error names %s: %s" % [c[1], "; ".join(loader.errors)])


func test_loader_refuses_a_record_missing_a_field() -> void:
	var d := _dummy()
	d.erase("ward_pts")
	var loader := FighterProfileLoader.new(CombatConstants.load_file())
	assert_true(loader.from_sim_build(d, "case") == null, "refused")
	assert_true("; ".join(loader.errors).contains("ward_pts"), "names ward_pts")
