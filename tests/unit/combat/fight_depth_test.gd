extends DaoTestSuite
## The world-depth engine features (world-depth plan Stage 5; Effects GDD rules 5, 6, 9b, 11 amended 2026-11-26),
## ported from tools/design/combat_sim/test_engine.py with the same names and numbers. Fighters are built like the
## sim's dummy() (the mechanism tests' helpers).

const M := preload("res://tests/unit/combat/fight_mechanisms_test.gd")


static func _soak_counter() -> Dictionary:
	return {"id": "ws", "on": "ward_absorbed", "do": [{"counter": {"id": "soak", "add": 1}}]}


func test_ward_absorbed_fires_once_per_hit_and_never_for_a_tick() -> void:
	# test_engine.py t_ward_absorbed: a 300 ward shield soaks a 120 hit: one event; a tick raises none
	var k := CombatConstants.load_file()
	var size: float = 300.0 / (26.0 * k.u[0] * 1.053)
	var f: Fight = M._fight(M._dummy(), M._dummy({"ward_pts": 0.0, "block": 0.0, "effects": [_soak_counter()],
			"counters": [{"id": "soak"}],
			"shields": [{"size": size, "body": false, "standing": true, "stops": {}, "pieces": 1, "floor": 0.0}]}))
	f.b.wshields[0].left = 300.0
	DefencePath.defend(f, f.a, f.b, 120.0, &"phys", null, {}, false)
	DefencePath.defend(f, f.a, f.b, 50.0, &"fire", null, {}, true)
	assert_near(float(f.b.counters["soak"]), 1.0, 1e-9, "one ward_absorbed for the hit, none for the tick")


func test_no_ward_raises_no_ward_absorbed() -> void:
	var f: Fight = M._fight(M._dummy(), M._dummy({"ward_pts": 0.0, "block": 0.0, "effects": [_soak_counter()],
			"counters": [{"id": "soak"}]}))
	DefencePath.defend(f, f.a, f.b, 120.0, &"phys", null, {}, false)
	assert_near(float(f.b.counters["soak"]), 0.0, 1e-9, "no ward, no event")


func test_stop_clock_moves_the_foes_timers_and_timer_resistance_shortens_it() -> void:
	# test_engine.py t_stop_clock: a 2 s stop moves the foe's art timer 2 s; timer_resist 25 makes it 1.5 s
	var stop := {"id": "s", "on": "fight_start", "do": [{"stop_clock": {"side": "foe", "seconds": 2.0}}]}
	var art := [{"name": "x", "c": 1.0, "cost": 0.05, "cd": 4.0}]
	var f: Fight = M._fight(M._dummy({"effects": [stop]}), M._dummy({}, art))
	var r0: int = f.b.ready[0]
	EffectRunner.fire(f, f.a, "fight_start", {})
	assert_eq(f.b.ready[0] - r0, 2000, "a 2 s stop")
	var g: Fight = M._fight(M._dummy({"effects": [stop]}), M._dummy({"timer_resist": 25.0}, art))
	var r1: int = g.b.ready[0]
	EffectRunner.fire(g, g.a, "fight_start", {})
	assert_eq(g.b.ready[0] - r1, 1500, "timer resistance 25 shortens it to 1.5 s")


func test_heal_restored_reports_the_overflow_lost_to_full_health() -> void:
	# test_engine.py t_heal_overflow: 10 missing, a 25 heal restores 10 and reports 15 overflow
	var count := {"id": "o", "on": "heal_restored", "scale": {"read": "event.overflow", "per": 1}, "do": [{"counter": {"id": "ov", "add": 1}}]}
	var f: Fight = M._fight(M._dummy({"effects": [count], "counters": [{"id": "ov"}]}), M._dummy())
	f.a.hp = f.a.hp_max - 10.0
	f.heal(f.a, 25.0)
	assert_near(float(f.a.counters["ov"]), 15.0, 1e-9, "overflow 15")


func test_a_counter_decays_by_its_share_each_pulse() -> void:
	# test_engine.py t_counter_decay_share: 50 with decay_share 0.1 is 45 after a pulse
	var f: Fight = M._fight(M._dummy({"counters": [{"id": "store", "decay_share": 0.1}]}), M._dummy())
	f.a.counters["store"] = 50.0
	f.pulse(f.a)
	assert_near(float(f.a.counters["store"]), 45.0, 1e-9, "45")


func test_batch_expired_and_healed_load_as_the_engine_events() -> void:
	# test_engine.py t_event_alias: combat_engine.json EVENT_ALIAS
	var f: Fight = M._fight(M._dummy({"effects": [{"id": "w", "on": "batch_expired", "do": []},
			{"id": "h", "on": "healed", "do": []}]}), M._dummy())
	var ons: Array = []
	for e in f.a.p.effects:
		ons.append(e.on)
	assert_eq(ons, ["batch_ended", "heal_restored"])
