extends DaoTestSuite
## Mechanism tests of the GDScript fight engine, slice 1 (ADR-0001: the sim's mechanism tests become GdUnit tests with
## the same names and numbers). Ported from tools/design/combat_sim/test_engine.py: slice 1 t_split (R23), t_charges,
## t_hp_cost, t_ward_bill (AC-CD-84); slice 2 t_pieces (AC-CD-82), t_bypass (AC-CD-80), t_extra_wards (CD&H rules
## 5-8), t_convert. The others land with their slices. Fighters are built like the sim's dummy():
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
	DefencePath.defend(k, f1.a, f1.b, 100.0, &"phys", null, false, 0, 1)
	var bill: float = q0 - f1.b.qi
	var f2 := _fight(_dummy(), _dummy())
	var q1: float = f2.b.qi
	DefencePath.defend(k, f2.a, f2.b, 100.0, &"phys", null, false, 0, 1)
	assert_near(bill / (q1 - f2.b.qi), 1.3, 1e-6, "AC-CD-84 ward_bill_pct 30 -> bill x1.3")


func test_log_off_builds_no_rows() -> void:
	# ADR-0001: a FightLogRow is built only when the log is on.
	var r: FightResult = _fight(_dummy({}, [{"name": "jab", "c": 1.0}]), _dummy()).run()
	assert_eq(r.log_rows.size(), 0, "no rows with the log off")


func test_loader_refuses_a_chancy_or_unported_field_by_name() -> void:
	var k := CombatConstants.load_file()
	var cases := [
		[_dummy({"purity": {"fire": 40.0}}), "purity"],
		[_dummy({}, [{"name": "dream-lance", "soul_pct": 0.05}]), "soul_pct"],
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


# --- slice 2: the defence path and wards ---------------------------------------------------------------------------

func test_shield_piece_soaks_one_piece_and_the_rest_moves_on() -> void:
	# test_engine.py t_pieces (AC-CD-82): a 300 bar in 3 pieces meets a 250 hit; one piece soaks 100, 150 moves on.
	var k := CombatConstants.load_file()
	var size: float = 300.0 / (26.0 * k.u[0] * 1.053)
	var f := _fight(_dummy(), _dummy({"ward_pts": 0.0, "block": 0.0,
			"shields": [{"size": size, "body": false, "standing": true, "stops": {}, "pieces": 3, "floor": 0.0}]}))
	f.b.wshields[0].left = 300.0
	var hp0: float = f.b.hp
	DefencePath.defend(k, f.a, f.b, 250.0, &"phys", null, false, 0, 1)
	assert_near(hp0 - f.b.hp, 150.0, 1e-6, "AC-CD-82 one piece soaks 100, 150 moves on")


func test_bypass_is_capped_at_half() -> void:
	# test_engine.py t_bypass (AC-CD-80): bypass 0.6 is capped at 0.5, so half of a 100 hit passes a large shield.
	var k := CombatConstants.load_file()
	var f := _fight(_dummy({}, [{"name": "b", "bypass": 0.6}]), _dummy({"ward_pts": 0.0, "block": 0.0,
			"shields": [{"size": 1.0, "body": false, "standing": true, "stops": {}, "pieces": 1, "floor": 0.0}]}))
	var hp0: float = f.b.hp
	DefencePath.defend(k, f.a, f.b, 100.0, &"phys", f.a.p.arts[0], false, 0, 1)
	assert_near(hp0 - f.b.hp, 50.0, 1e-6, "AC-CD-80 bypass capped at 50 %")


func test_converted_part_meets_its_own_resistance() -> void:
	# test_engine.py t_convert: 40 % of a Physical hit becomes Fire and meets Fire resistance 100 (halved).
	var f := _fight(_dummy({}, [{"name": "spark", "c": 2.0, "convert": {"to": "fire", "share": 0.4}}]),
			_dummy({"ward_pts": 0.0, "block": 0.0, "resist": {"fire": 100.0}}))
	var hp0: float = f.b.hp
	f.hit(f.a, f.b, 2.0, &"phys", f.a.p.arts[0], Fight.KIND_ART)
	var d: float = CombatConstants.load_file().u[0] * 2.0 * f.a.p.m
	assert_near(hp0 - f.b.hp, d * 0.6 + d * 0.4 / 2.0, 1e-6, "60 % Physical full, 40 % Fire at /2")


func test_per_hit_ward_pays_once_per_hit_and_meets_only_its_types() -> void:
	# test_engine.py t_extra_wards, per-hit part (CD&H rule 6).
	var f := _fight(_dummy(), _dummy({"ward_pts": 0.0,
			"wards": [{"id": "veil", "model": "per_hit", "payload": {"fire": 200.0}, "cost": 0.02}]}))
	var q0: float = f.b.qi
	var met: Array = DefencePath.extra_wards(f.b, &"fire", 1)
	assert_true(met[0].size() == 1 and absf(q0 - f.b.qi - 0.02 * f.b.qi_max()) < 1e-9, "meets a Fire hit and pays its fee")
	var q1: float = f.b.qi
	assert_true(DefencePath.extra_wards(f.b, &"fire", 1)[0].size() == 1 and f.b.qi == q1,
			"a second part of the same hit pays no second fee")
	assert_eq(DefencePath.extra_wards(f.b, &"phys", 1)[0].size(), 0, "meets no Physical part")
	var q2: float = f.b.qi
	assert_true(DefencePath.extra_wards(f.b, &"fire", 2)[0].size() == 1 and absf(q2 - f.b.qi - 0.02 * f.b.qi_max()) < 1e-9,
			"the next hit or tick pays one fee and is met")


func test_cast_ward_is_up_for_its_window_then_down() -> void:
	# test_engine.py t_extra_wards, cast part (CD&H rule 7).
	var f := _fight(_dummy(), _dummy({"wards": [{"id": "shell", "model": "cast", "payload": {"phys": 70.0}, "cost": 0.03,
			"cooldown": 5.0, "up": 2.0}]}))
	assert_eq(DefencePath.extra_wards(f.b, &"phys", 1)[0].size(), 0, "down before it is cast")
	f.cast_wards(f.b)
	var up: int = DefencePath.extra_wards(f.b, &"phys", 2)[0].size()
	f.t += 2500
	f.cast_wards(f.b)
	assert_eq(up, 1, "up for its window")
	assert_eq(DefencePath.extra_wards(f.b, &"phys", 3)[0].size(), 0, "then down until its cooldown")


func test_cast_shield_bar_lasts_its_window() -> void:
	# test_engine.py t_extra_wards, cast shield part.
	var f := _fight(_dummy(), _dummy({"wards": [{"id": "gold", "model": "cast", "payload": {}, "shield": 0.1,
			"cost": 0.02, "cooldown": 4.0, "up": 3.0}]}))
	var n0: int = f.b.wshields.size()
	f.cast_wards(f.b)
	assert_true(f.b.wshields.size() == n0 + 1 and absf(f.b.wshields[-1].left - 0.1 * f.b.qi_base) < 1e-9,
			"casting adds a bar of 0.1 x qi_base")
	f.t += 3500
	f.cast_wards(f.b)
	assert_eq(f.b.wshields.size(), n0, "the bar is gone when the window ends")


func test_reserved_ward_holds_with_no_linh_luc() -> void:
	# test_engine.py t_extra_wards, reserved part (CD&H rule 8).
	var f := _fight(_dummy(), _dummy({"wards": [{"id": "lake", "model": "reserved", "payload": {"all": 50.0}}]}))
	f.b.qi = 0.0
	assert_eq(DefencePath.extra_wards(f.b, &"phys", 1)[0].size(), 1, "up even with no linh lực left")


func test_evade_and_crit_chances_stop_at_their_caps() -> void:
	# Combat Formulas I: evade within 0 and evade_cap (0.4), crit within crit_cap (1.0); accuracy lowers evade.
	var k := CombatConstants.load_file()
	var f := _fight(_dummy({"crit": 1.5, "acc": 0.1}), _dummy({"evade": 0.9}))
	assert_near(f.evade_chance(f.a, f.b), k.evade_cap, 1e-12, "evade 0.9 - acc 0.1 caps at evade_cap")
	assert_near(f.crit_chance(f.a), k.crit_cap, 1e-12, "crit 1.5 caps at crit_cap")
	var g := _fight(_dummy({"acc": 0.5}), _dummy({"evade": 0.2}))
	assert_near(g.evade_chance(g.a, g.b), 0.0, 1e-12, "accuracy above evade floors at 0")
	var w := _fight(_dummy(), _dummy({"evade": 0.1, "wards": [{"id": "fog", "model": "reserved", "payload": {}, "evade": 8.0}]}))
	assert_near(w.evade_chance(w.a, w.b), 0.18, 1e-12, "a reserved evade ward adds its points")
