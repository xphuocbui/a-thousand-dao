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


# ---- slice 2a (2026-11-26): the Status Catalogue rows Off Guard, Bound, Charmed, Drunk, Sleep (test_engine.py) ----
static func _spec(id: String, extra: Dictionary = {}) -> StatusSpec:
	var s := StatusSpec.new()
	s.id = id
	s.extra = extra
	return s


static func _landed(f: Fight, n: int) -> int:
	var got: int = 0
	for _i in n:
		var hp: float = f.b.hp
		f.hit(f.a, f.b, 0.01, &"phys", null, Fight.KIND_ART)
		if f.b.hp < hp:
			got += 1
		f.b.hp = f.b.hp_max
	return got


func test_off_guard_makes_every_hit_land_against_evade() -> void:
	var f: Fight = M._fight(M._dummy(), M._dummy({"evade": 0.4, "ward_pts": 0.0, "block": 0.0}))
	f.apply_status(f.a, f.b, _spec("off_guard", {"dur": 2}))
	assert_eq(_landed(f, 40), 40, "Off Guard: every hit lands")
	assert_eq(f.b.statuses["off_guard"].until, f.t + 2000)
	var g: Fight = M._fight(M._dummy(), M._dummy({"evade": 0.4, "ward_pts": 0.0, "block": 0.0}))
	assert_bool(_landed(g, 40) < 40).is_true()


func test_bound_holds_and_a_recast_does_nothing() -> void:
	var f: Fight = M._fight(M._dummy(), M._dummy())
	f.apply_status(f.a, f.b, _spec("bound", {"dur": 2}))
	var u: int = f.b.statuses["bound"].until
	f.t = 500
	f.apply_status(f.a, f.b, _spec("bound", {"dur": 2}))
	assert_near(f.b.st("bound"), 1.0, 1e-9)
	assert_eq(f.b.statuses["bound"].until, u)


func test_drunk_stacks_run_their_own_time_and_slow_timers() -> void:
	var f: Fight = M._fight(M._dummy(), M._dummy({"ward_pts": 0.0, "block": 0.0}))
	f.apply_status(f.a, f.b, _spec("drunk"))
	f.t = 1000
	f.apply_status(f.a, f.b, _spec("drunk"))
	assert_near(f.b.st("drunk"), 2.0, 1e-9, "no stack cap")
	assert_near(f.slow(f.b), 1.16, 1e-12, "8 % per stack")
	f.t = 3000
	f.pulse(f.b)
	assert_near(f.b.st("drunk"), 1.0, 1e-9, "the first stack ends on its own time")
	f.t = 4000
	f.pulse(f.b)
	assert_bool(f.b.statuses.has("drunk")).is_false()


func test_drunk_three_stacks_lose_aim_and_take_more_from_water() -> void:
	var f: Fight = M._fight(M._dummy(), M._dummy({"ward_pts": 0.0, "block": 0.0}))
	for _i in 3:
		f.apply_status(f.b, f.a, _spec("drunk"))
	var got: int = _landed(f, 400)
	assert_bool(got >= 240 and got <= 320).override_failure_message("landed %d of 400" % got).is_true()
	var g: Fight = M._fight(M._dummy({}, [{"name": "w", "c": 1.0, "cost": 0.05, "cd": 3.0, "element": "water"},
			{"name": "m", "c": 1.0, "cost": 0.05, "cd": 3.0, "element": "metal"}]), M._dummy({"ward_pts": 0.0, "block": 0.0}))
	var water: ArtDef = g.a.p.arts[0]
	var metal: ArtDef = g.a.p.arts[1]
	var lost: Array = []
	for step in 3:
		if step == 1:
			for _i in 3:
				g.apply_status(g.a, g.b, _spec("drunk"))
		var hp: float = g.b.hp
		g.hit(g.a, g.b, 1.0, &"phys", metal if step == 2 else water, Fight.KIND_ART)
		lost.append(hp - g.b.hp)
		g.b.hp = g.b.hp_max
	assert_near(float(lost[1]) / float(lost[0]), 1.10, 1e-9, "Water parts +10 %")
	assert_near(float(lost[2]) / float(lost[0]), 1.0, 1e-9, "other parts unchanged")


func test_charmed_holds_the_target_and_its_caster_until_the_charmer_strikes() -> void:
	var arts := [{"name": "cut", "c": 1.0, "cost": 0.01, "cd": 2.0}, {"name": "mend", "c": 0.0, "cost": 0.01, "cd": 2.0, "heal": 0.05}]
	var f: Fight = M._fight(M._dummy({}, arts), M._dummy({}, arts))
	f.t = 5000
	f.a.ready = PackedInt64Array([5000, 5000])
	f.b.ready = PackedInt64Array([5000, 5000])
	f.apply_status(f.a, f.b, _spec("charmed"))
	assert_eq(f.b.statuses["charmed"].until, 7000)
	f.act(f.b)
	assert_eq(Array(f.b.fired), [0, 0], "the target's arts all wait")
	f.act(f.a)
	assert_eq(Array(f.a.fired), [0, 1], "the charmer's damaging art waits, its heal fires")
	f.tick(f.a, f.b, 5.0, &"fire", "burn")
	assert_near(f.b.st("charmed"), 1.0, 1e-9, "a tick does not end it")
	f.hit(f.a, f.b, 0.01, &"phys", null, Fight.KIND_COMPANION)
	assert_near(f.b.st("charmed"), 1.0, 1e-9, "a companion hit does not end it")
	f.hit(f.a, f.b, 0.01, &"phys", null, Fight.KIND_TRIGGER, true)
	assert_near(f.b.st("charmed"), 0.0, 1e-9, "the charmer's free hit ends it")
	assert_eq(int(f.b.lockouts["charmed"]), f.t + 10000)
	f.act(f.b)
	assert_eq(int(f.b.fired[0]), 1, "freed, the target fires again")


func test_charmed_is_shortened_by_timer_resistance_and_the_delay_falloff() -> void:
	var f: Fight = M._fight(M._dummy(), M._dummy({"timer_resist": 50.0}))
	f.apply_status(f.a, f.b, _spec("charmed"))
	assert_eq(f.b.statuses["charmed"].until, f.t + 1000, "timer resistance 50")
	var delay := {"id": "d", "on": "fight_start", "do": [{"timer": {"side": "foe", "by": 0.2}}]}
	var g: Fight = M._fight(M._dummy({"effects": [delay]}), M._dummy({}, [{"name": "x", "c": 1.0, "cost": 0.05, "cd": 4.0}]))
	EffectRunner.fire(g, g.a, "fight_start", {})
	g.apply_status(g.a, g.b, _spec("charmed"))
	assert_eq(g.b.statuses["charmed"].until, g.t + 1000, "the falloff halves it after a delay")


func test_sleep_stops_the_clock_and_a_landed_hit_wakes_it_for_less() -> void:
	var f: Fight = M._fight(M._dummy(), M._dummy({"ward_pts": 0.0, "block": 0.0}, [{"name": "cut", "c": 1.0, "cost": 0.01, "cd": 2.0}]))
	f.t = 5000
	f.b.ready = PackedInt64Array([4000])
	f.b.basic_ready = 5500
	f.apply_status(f.a, f.b, _spec("sleep"))
	assert_eq(int(f.b.ready[0]), 8000, "a ready art waits too")
	assert_eq(f.b.basic_ready, 8500)
	assert_eq(f.b.statuses["sleep"].until, 8000)
	f.act(f.b)
	assert_eq(int(f.b.fired[0]), 0, "asleep, nothing fires")
	f.tick(f.a, f.b, 5.0, &"fire", "burn")
	assert_near(f.b.st("sleep"), 1.0, 1e-9, "a tick does not wake it")
	f.b.hp = f.b.hp_max
	f.a.basic_ready = f.t
	f.act(f.a)
	assert_near(f.b.hp, f.b.hp_max, 1e-9, "the caster is held: its basic attack does not hit")
	f.t = 6000
	f.b.basic_ready = 9000
	var hp0: float = f.b.hp
	f.hit(f.a, f.b, 1.0, &"phys", null, Fight.KIND_COMPANION)
	var woke: float = hp0 - f.b.hp
	assert_near(f.b.st("sleep"), 0.0, 1e-9, "a companion hit wakes it")
	assert_eq(int(f.b.lockouts["sleep"]), 12000)
	assert_eq(int(f.b.ready[0]), 6000, "the unused 2 s come back")
	assert_eq(f.b.basic_ready, 9000, "a timer set during the sleep keeps its time")
	var hp1: float = f.b.hp
	f.hit(f.a, f.b, 1.0, &"phys", null, Fight.KIND_COMPANION)
	assert_near(woke / (hp1 - f.b.hp), 0.8, 1e-9, "the waking hit deals 20 % less")


func test_sleep_ends_on_its_own_with_nothing_given_back() -> void:
	var f: Fight = M._fight(M._dummy(), M._dummy({}, [{"name": "cut", "c": 1.0, "cost": 0.01, "cd": 2.0}]))
	f.apply_status(f.a, f.b, _spec("sleep"))
	f.t = 3000
	f.pulse(f.b)
	assert_bool(f.b.statuses.has("sleep")).is_false()


# ---- slice 2b (2026-11-26): tick to heal (Bitter Medicine) and upkeep on a self-counter (test_engine.py) ----
func test_a_poison_tick_heals_instead_while_under_ten_stacks() -> void:
	var bitter := {"id": "bm", "on": "always", "if": [{"read": "own.debuff.wood", "op": "<", "value": 10}],
			"do": [{"mod": {"tick_to_heal": 50, "element": "wood"}}]}
	var f: Fight = M._fight(M._dummy(), M._dummy({"effects": [bitter], "ward_pts": 0.0, "block": 0.0}))
	f.b.hp = f.b.hp_max - 100.0
	var got: float = f.tick(f.a, f.b, 40.0, &"chaos", "wood")
	assert_near(got, 0.0, 1e-9, "deals nothing")
	assert_near(f.b.hp_max - f.b.hp, 80.0, 1e-9, "heals half of it")
	var hp: float = f.b.hp
	f.tick(f.a, f.b, 40.0, &"fire", "fire")
	assert_bool(f.b.hp < hp).override_failure_message("a Burn tick still hurts").is_true()
	f.add_stacks(f.a, f.b, "wood", 10.0, 30.0, false)
	hp = f.b.hp
	f.tick(f.a, f.b, 40.0, &"chaos", "wood")
	assert_bool(f.b.hp < hp).override_failure_message("at 10 stacks it hurts").is_true()


func test_tick_to_heal_counts_as_healing_under_withering() -> void:
	var bitter := {"id": "bm", "on": "always", "do": [{"mod": {"tick_to_heal": 50, "element": "wood"}}]}
	var f: Fight = M._fight(M._dummy(), M._dummy({"effects": [bitter]}))
	f.b.hp = f.b.hp_max - 100.0
	f.apply_status(f.a, f.b, _spec("withering"))
	var hp: float = f.b.hp
	f.tick(f.a, f.b, 40.0, &"chaos", "wood")
	assert_near(f.b.hp - hp, 10.0, 1e-9, "Withering halves the heal")


func test_upkeep_pays_each_stack_and_ends_the_unpaid() -> void:
	var f: Fight = M._fight(M._dummy({"counters": [{"id": "ward", "upkeep": {"pool": "qi", "per_stack": 0.1}}]}), M._dummy())
	var up: Dictionary = f.a.p.counter_def["ward"].upkeep
	f.a.counters["ward"] = 3.0
	f.a.qi = 0.35 * f.a.qi_max()
	f.upkeep(f.a, "ward", up)
	assert_near(float(f.a.counters["ward"]), 3.0, 1e-9)
	assert_near(f.a.qi, 0.05 * f.a.qi_max(), 1e-9)
	f.a.qi = 0.25 * f.a.qi_max()
	f.upkeep(f.a, "ward", up)
	assert_near(float(f.a.counters["ward"]), 2.0, 1e-9, "the third ends")


func test_upkeep_on_charges_drops_the_nearest_end_and_health_keeps_its_floor() -> void:
	var f: Fight = M._fight(M._dummy({"counters": [{"id": "stele", "each_for": 9, "upkeep": {"pool": "qi", "per_stack": 0.1}}]}), M._dummy())
	f.t = 1000
	f.a.counter_times["stele"] = [5000, 3000, 4000]
	f.a.qi = 0.15 * f.a.qi_max()
	f.upkeep(f.a, "stele", f.a.p.counter_def["stele"].upkeep)
	assert_eq(f.a.counter_times["stele"], [5000])
	var g: Fight = M._fight(M._dummy({"counters": [{"id": "blood", "upkeep": {"pool": "hp", "per_stack": 0.5}}]}), M._dummy())
	g.a.counters["blood"] = 3.0
	g.upkeep(g.a, "blood", g.a.p.counter_def["blood"].upkeep)
	assert_near(float(g.a.counters["blood"]), 1.0, 1e-9)
	assert_bool(g.a.hp >= g.k.pay_keep_health).is_true()


# ---- slice 2c (2026-11-26): the extended last act (Effects rule 11, The Fifteenth Layer; test_engine.py) ----
static func _pine() -> Dictionary:
	return {"id": "pine", "on": "down", "do": [{"last_act_window": {"seconds": 6, "every": 1.0, "spend": "waves",
			"hits": [{"c": 0.4, "dtype": "phys"}, {"c": 0.4, "dtype": "cold"}]}}]}


func test_the_window_keeps_a_down_side_in_until_its_bank_runs_dry() -> void:
	var f: Fight = M._fight(M._dummy({"effects": [_pine()], "counters": [{"id": "waves"}]}), M._dummy({"ward_pts": 0.0, "block": 0.0}))
	f.a.counters["waves"] = 3.0
	f.t = 10000
	f.a.hp = -5.0
	f._defeat_check()
	assert_bool(f.a.window_on and not f.a.down).override_failure_message("the window opens").is_true()
	assert_near(f.hit(f.b, f.a, 1.0, &"phys", null, Fight.KIND_ART), 0.0, 1e-9, "cannot be struck")
	f.heal(f.a, 50.0)
	assert_near(f.a.hp, -5.0, 1e-9, "cannot be healed")
	var hp: float = f.b.hp
	f.t = 11000
	f.act(f.a)
	assert_bool(f.b.hp < hp).override_failure_message("a round of waves fires").is_true()
	assert_near(float(f.a.counters["waves"]), 2.0, 1e-9)
	f.t = 13000
	f.act(f.a)
	f._defeat_check()
	assert_bool(f.a.down).override_failure_message("the bank runs dry: Down").is_true()


func test_the_foe_going_down_inside_the_window_is_a_draw() -> void:
	var f: Fight = M._fight(M._dummy({"effects": [_pine()], "counters": [{"id": "waves"}]}), M._dummy())
	f.a.counters["waves"] = 9.0
	f.a.hp = -1.0
	f._defeat_check()
	f.t = 2000
	f.b.hp = -1.0
	f._defeat_check()
	assert_bool(f.a.down and f.b.down).is_true()


func test_the_window_ends_on_time_and_a_refusal_comes_first() -> void:
	var f: Fight = M._fight(M._dummy({"effects": [_pine()], "counters": [{"id": "waves"}]}), M._dummy())
	f.a.counters["waves"] = 99.0
	f.a.hp = -1.0
	f._defeat_check()
	for tt in [1000, 2000, 3000, 4000, 5000, 6000, 7000]:
		f.t = tt
		f.act(f.a)
	f._defeat_check()
	assert_bool(f.a.down).is_true()
	assert_near(float(f.a.counters["waves"]), 93.0, 1e-9, "six rounds in 6 s")
	var refuse := {"id": "r", "on": "down", "do": [{"refuse_down": true}]}
	var g: Fight = M._fight(M._dummy({"effects": [refuse, _pine()], "counters": [{"id": "waves"}], "refusals": 1}), M._dummy())
	g.a.counters["waves"] = 3.0
	g.a.hp = -1.0
	g._defeat_check()
	assert_bool(not g.a.window_on and not g.a.down and g.a.hp > 0.0).is_true()


# ---- slice E (2026-11-26): escape (Combat rule 10, Formulas I; test_engine.py t_escape) ----
static func _runner(e_art: float, fields: Dictionary = {}) -> Dictionary:
	return M._dummy(fields, [{"name": "run", "c": 0.0, "cost": 0.01, "cd": 4.0, "escape": e_art, "tags": ["escape", "movement"]}])


func test_an_escape_art_opens_one_channel_and_a_second_waits() -> void:
	var f: Fight = M._fight(_runner(0.55), M._dummy())
	f.t = 3000
	f.a.ready = PackedInt64Array([3000])
	f.act(f.a)
	assert_eq(f.a.channel_until, 4000, "a 1 s channel")
	f.a.ready = PackedInt64Array([3000])
	f.act(f.a)
	assert_eq(int(f.a.fired[0]), 1, "a ready escape art waits while a channel is open")


func test_bound_fails_the_escape_with_no_draw_and_raises_escape_failed() -> void:
	var count := {"id": "c", "on": "escape_failed", "do": [{"counter": {"id": "failed", "add": 1}}]}
	var f: Fight = M._fight(_runner(0.55, {"effects": [count], "counters": [{"id": "failed"}]}), M._dummy())
	f.t = 3000
	f.a.ready = PackedInt64Array([3000])
	f.act(f.a)
	f.apply_status(f.b, f.a, _spec("bound", {"dur": 2}))
	var state_before: int = f.rng.state
	f.t = 4000
	f.escape_rolls()
	assert_bool(f.a.fled).is_false()
	assert_eq(f.rng.state, state_before, "no draw")
	assert_near(float(f.a.counters["failed"]), 1.0, 1e-9, "escape_failed fired")


func test_a_side_at_zero_health_does_not_flee() -> void:
	var f: Fight = M._fight(_runner(0.95), M._dummy())
	f.t = 3000
	f.a.ready = PackedInt64Array([3000])
	f.act(f.a)
	f.a.hp = 0.0
	var state_before: int = f.rng.state
	f.t = 4000
	f.escape_rolls()
	assert_bool(f.a.fled).is_false()
	assert_eq(f.rng.state, state_before, "no draw")


func test_a_near_certain_escape_ends_the_fight_in_flight() -> void:
	var fled: int = 0
	for seed in 10:
		var k := CombatConstants.load_file()
		var loader := FighterProfileLoader.new(k)
		var pa: FighterProfile = loader.from_sim_build(_runner(0.95), "a")
		var pb: FighterProfile = loader.from_sim_build(M._dummy(), "b")
		var r: FightResult = Fight.new(pa, pb, k, seed, Fight.Order.FIXED).run()
		if r.win_code() == "flight":
			fled += 1
	assert_bool(fled >= 8).override_failure_message("fled %d of 10 at p 0.95" % fled).is_true()
