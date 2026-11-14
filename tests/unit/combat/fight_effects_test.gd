extends DaoTestSuite
## Mechanism tests of the GDScript Effect interpreter (slices 4a, 4b), ported from tools/design/combat_sim/test_engine.py
## with the same numbers (ADR-0001 decision 4): t_delay_falloff, t_refusal_budget, t_cull, t_strip_steal, t_consume,
## t_held, t_trigger_budget, t_states, t_summon_echo, t_or_guard, t_cleanse_curses, t_since, t_reserved,
## t_refresh_and_hold, t_new_readables, t_scoped_art_reads, t_status_duration_and_resist, t_heal_taken, t_qi_on_crit,
## t_art_cost_health, t_pen_and_pierce, t_stack_grant, t_elem_type_scope. (t_unknown_action is covered by the loader
## refusal test in fight_mechanisms_test.gd.) Fighters are the sim's dummy(): its Build defaults, crit 0, no arts.

const DEFAULTS_PATH := "res://tests/parity/sim_defaults.json"


static func _k() -> CombatConstants:
	return CombatConstants.load_file()


static func _dummy(fields: Dictionary = {}, arts: Array = []) -> Dictionary:
	var d: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(DEFAULTS_PATH))
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


static func _fight(a: Dictionary, b: Dictionary, fight_seed: int = 3) -> Fight:
	var k := _k()
	var loader := FighterProfileLoader.new(k)
	var pa: FighterProfile = loader.from_sim_build(a, "a")
	var pb: FighterProfile = loader.from_sim_build(b, "b")
	assert(loader.errors.is_empty(), "; ".join(loader.errors))
	return Fight.new(pa, pb, k, fight_seed, Fight.Order.FIXED)


## An "always" Effect holding these mods (the sim's _fx).
static func _fx(mods: Array) -> Array:
	var do_list: Array = []
	for mm in mods:
		do_list.append({"mod": mm})
	return [{"id": "t", "on": "always", "do": do_list}]


## Runs [param actions] for side [param s] as the sim's f.do(s, {"id", "on": "always"}, actions, 1.0, ev).
static func _do(f: Fight, s: FighterState, actions: Array, ev: Dictionary = {}) -> void:
	var c := EffectCompiler.new(f.k)
	var e: EffectDef = c.compile({"id": "t", "on": "always", "do": actions}, "test", s.p.counter_def)
	assert(e != null, "; ".join(c.errors))
	EffectRunner.run(f, s, e, e.actions, 1.0, ev)


static func _read(f: Fight, s: FighterState, key: String) -> float:
	var c := EffectCompiler.new(f.k)
	return EffectRunner.read(f, s, c._read(key, "test", s.p.counter_def), null)


static func _spec(fields: Dictionary) -> StatusSpec:
	var spec := StatusSpec.new()
	spec.id = str(fields.id)
	spec.stacks = float(fields.get("stacks", 1))
	for key in fields:
		if not (str(key) in ["id", "stacks", "chance"]):
			spec.extra[str(key)] = fields[key]
	return spec


static func _refuse(id: String) -> Dictionary:
	return {"id": id, "on": "down", "limit": {"per_fight": 1}, "do": [{"refuse_down": true}]}


func test_delay_falloff_halves_each_delay_and_timer_resistance_trims_it() -> void:
	# t_delay_falloff (AC-EF-71): three 1 s delays land 1 + 0.5 + 0.25 s; timer resistance 20 turns 1 s into 0.8 s.
	var f := _fight(_dummy(), _dummy({}, [{"name": "x", "c": 1.0, "cost": 0.05, "cd": 4.0}]))
	var base: int = f.b.ready[0]
	for i in 3:
		_do(f, f.a, [{"timer": {"side": "foe", "by": 1.0}}])
	assert_eq(f.b.ready[0] - base, 1750, "AC-EF-71 delay falloff 1 + 0.5 + 0.25 s")
	var g := _fight(_dummy(), _dummy({"timer_resist": 20}, [{"name": "x", "c": 1.0, "cost": 0.05, "cd": 4.0}]))
	var base2: int = g.b.ready[0]
	_do(g, g.a, [{"timer": {"side": "foe", "by": 1.0}}])
	assert_eq(g.b.ready[0] - base2, 800, "AC-EF-71 timer resistance 20 -> 0.8 s")


func test_one_refusal_per_fight_unless_the_build_has_two() -> void:
	# t_refusal_budget (AC-EF-75).
	var f := _fight(_dummy({"effects": [_refuse("r1"), _refuse("r2")]}), _dummy())
	f.a.hp = -5.0
	f._defeat_check()
	var first: bool = (not f.a.down) and f.a.hp == 1.0
	f.a.hp = -5.0
	f._defeat_check()
	assert_true(first and f.a.down, "AC-EF-75 one refusal per fight")
	var g := _fight(_dummy({"refusals": 2, "effects": [_refuse("r1"), _refuse("r2")]}), _dummy())
	g.a.hp = -1.0
	g._defeat_check()
	g.a.hp = -1.0
	g._defeat_check()
	var two: bool = not g.a.down
	g.a.hp = -1.0
	g._defeat_check()
	assert_true(two and g.a.down, "AC-EF-75 'twice' capstone: two refusals")


func test_cull_is_refused_once_then_culls() -> void:
	# t_cull (AC-EF-76).
	var f := _fight(_dummy({"effects": [{"id": "cull", "on": "always", "do": [{"cull": 0.08}]}]}),
			_dummy({"effects": [_refuse("r")]}))
	f.b.hp = 0.07 * f.b.hp_max
	f._defeat_check()
	var saved: bool = not f.b.down and f.b.hp == 1.0
	f._defeat_check()
	assert_true(saved and f.b.down, "AC-EF-76 cull refused once, then culled")


func test_strip_takes_the_oldest_stacks_and_steal_keeps_them() -> void:
	# t_strip_steal (AC-EF-73): 3 of the foe's 6 Fire buff stacks, oldest batch first, stolen.
	var f := _fight(_dummy(), _dummy())
	f.add_stacks(f.b, f.b, "fire", 2.0, 5.0, true)
	f.add_stacks(f.b, f.b, "fire", 4.0, 9.0, true)
	_do(f, f.a, [{"strip": {"n": 3, "el": "fire", "steal": true}}])
	assert_eq(EffectRunner._count(f.b.buffs, "fire"), 3.0, "the foe keeps 3")
	assert_eq(EffectRunner._count(f.a.buffs, "fire"), 3.0, "the striker gains 3")


func test_consume_takes_every_stack_it_finds() -> void:
	# t_consume (AC-EF-74): consume up to 10 Ice debuffs on the foe; it has 6.
	var f := _fight(_dummy(), _dummy())
	f.add_stacks(f.a, f.b, "ice", 6.0, 9.0, false)
	_do(f, f.a, [{"consume": {"el": "ice", "side": "foe", "n": 10, "then": [{"gain_qi": {"share": 0.01}}]}}])
	assert_eq(EffectRunner._count(f.b.debuffs, "ice"), 0.0, "AC-EF-74 consume takes 6 of 6")


func test_held_payload_is_banked_then_spent() -> void:
	# t_held (AC-EF-79): a crit banks +20 L5 until an art fires.
	var f := _fight(_dummy({"effects": [{"id": "h", "on": "crit", "held": {"until": "art_fired"}, "do": [{"mod": {"L5": 20}}]}]}), _dummy())
	EffectRunner.fire(f, f.a, "crit", {})
	var banked: bool = f.a.banked.size() == 1 and f.m(f.a, "L5", null) == 20.0
	EffectRunner.spend_banked(f, f.a, "art_fired", {})
	assert_true(banked and f.a.banked.is_empty() and f.m(f.a, "L5", null) == 0.0, "AC-EF-79 held payload banked, then spent")


func test_trigger_hits_stay_within_the_budget_and_the_cap() -> void:
	# t_trigger_budget (Combat Formulas G): trigger damage <= trig_budget x direct damage, at most trig_cap firings.
	var trig := {"id": "t", "on": "hit_landed", "do": [{"free_hit": {"c": 0.8}}]}
	var f := _fight(_dummy({"effects": [trig], "M": 3.0}), _dummy({"ward_pts": 0.0, "block": 0.0}))
	f.a.direct_dmg = 10.0
	var c := EffectCompiler.new(f.k)
	var e: EffectDef = c.compile(trig, "t", {})
	for i in 10:
		EffectRunner.run(f, f.a, e, e.actions, 1.0, {})
	assert_true(f.a.trig_dmg <= 0.5 * 10.0 + 1e-6 and f.a.trig_count <= 6,
			"Formulas G budget and cap: dmg %.2f count %d" % [f.a.trig_dmg, f.a.trig_count])


func test_a_stance_applies_its_mods_and_suppresses_its_art() -> void:
	# t_states (R29).
	var f := _fight(_dummy({"states": [{"id": "storm", "mods": {"art_speed": 50}, "suppress": ["slow"]}]},
			[{"name": "slow", "c": 1.0, "cost": 0.02, "cd": 4.0}]), _dummy())
	_do(f, f.a, [{"state": {"set": "storm"}}])
	f.t = f.a.ready[0]
	f.act(f.a)
	assert_eq(f.m(f.a, "art_speed", null), 50.0, "the stance's mods apply")
	assert_eq(f.a.fired[0], 0, "the suppressed art does not fire")
	assert_eq(_read(f, f.a, "own.state.storm"), 1.0, "the state is readable")


func test_a_summon_hits_for_its_duration_and_fire_art_echoes_the_last_art() -> void:
	# t_summon_echo: a 3 s summon on a 1 s cooldown hits twice; fire_art last at share 0.5 deals half a hit.
	var f := _fight(_dummy({}, [{"name": "pal", "c": 1.0, "cost": 0.02, "cd": 4.0}]), _dummy({"ward_pts": 0.0, "block": 0.0}))
	_do(f, f.a, [{"summon": {"c": 0.5, "cd": 1.0, "for": 3}}])
	var hp0: float = f.b.hp
	for t in [1000, 2000, 3000, 4000]:
		f.t = t
		f.a.basic_ready = 1000000000
		f.a.ready[0] = 1000000000
		f.act(f.a)
	var unit: float = _k().u[0] * 0.5 * f.a.p.m
	assert_eq(snappedf((hp0 - f.b.hp) / unit, 0.001), 2.0, "the summon hits twice")
	f.a.last_art = 0
	var hp1: float = f.b.hp
	_do(f, f.a, [{"fire_art": {"which": "last", "share": 0.5}}])
	assert_near(hp1 - f.b.hp, unit, 1e-6, "fire_art echoes the last art at half")


func test_an_or_guard_holds_when_one_branch_does() -> void:
	# t_or_guard.
	var f := _fight(_dummy(), _dummy())
	var c := EffectCompiler.new(f.k)
	var g: Array = c.compile_conds([{"any": [{"read": "own.hp_share", "op": "<=", "value": 0.5},
		{"read": "time", "op": ">=", "value": 10}]}], "g", {})
	var first: bool = EffectRunner.holds(f, f.a, g, null)
	f.t = 10000
	assert_true((not first) and EffectRunner.holds(f, f.a, g, null), "false, then true when one branch holds")


func test_cleanse_two_curses_leaves_one() -> void:
	# t_cleanse_curses.
	var f := _fight(_dummy(), _dummy())
	for sid in ["sundered", "exposed", "withering"]:
		f.apply_status(f.b, f.a, _spec({"id": sid}))
	_do(f, f.a, [{"cleanse": {"curses": 2}}])
	assert_eq(f.a.statuses.size(), 1, "cleanse 2 curses")


func test_since_reads_never_then_the_seconds_since_the_art() -> void:
	# t_since. The GDScript engine keeps the fire log only for sides whose Effects or guards can read it, so A gets
	# an Effect that reads since (the sim keeps it always; the reads agree either way).
	var g := _fight(_dummy({"effects": [{"id": "z", "on": "always", "if": [{"read": "own.since.a1", "op": ">=", "value": 0}], "do": []}]},
			[{"name": "a1", "c": 0.5, "cost": 0.02, "cd": 2.0}]), _dummy())
	var never: float = _read(g, g.a, "own.since.a1")
	g.t = g.a.ready[0]
	g.a.basic_ready = 1000000000
	g.act(g.a)
	g.t += 1500
	assert_true(never >= 1e8, "never fired: %s" % never)
	assert_near(_read(g, g.a, "own.since.a1"), 1.5, 1e-9, "1.5 s after it fired")


func test_reserved_linh_luc_caps_the_start_and_gains() -> void:
	# t_reserved (Combat Defence & Healing rule 10).
	var f := _fight(_dummy({"reserved": 0.25}), _dummy())
	assert_near(f.a.qi, 0.75 * f.a.qi_base, 1e-9, "the fight starts at 75 %")
	_do(f, f.a, [{"gain_qi": {"share": 1.0}}])
	assert_true(absf(f.a.qi - f.a.qi_use()) < 1e-9 and f.a.qi_use() < f.a.qi_max(), "gains stop at the usable maximum")
	var g := _fight(_dummy({"reserved": 0.95}), _dummy())
	assert_near(g.a.qi, 0.1 * g.a.qi_base, 1e-9, "reserved above reserve_cap 0.9 is held at 0.9")


func test_refresh_restarts_my_batches_and_hold_keeps_them() -> void:
	# t_refresh_and_hold (Fan the Pyre, Verdict Stands).
	var f := _fight(_dummy(), _dummy())
	f.add_stacks(f.a, f.b, "fire", 3.0, 6.0, false)
	f.add_stacks(f.b, f.b, "fire", 3.0, 6.0, false)
	f.t += 4000
	_do(f, f.a, [{"refresh": {"el": "fire"}}])
	assert_eq(f.b.debuffs[0].until, 10000, "my Burn batch restarts its 6 s at t = 4 s")
	assert_eq(f.b.debuffs[1].until, 6000, "another side's batch is left alone")
	_do(f, f.a, [{"refresh": {"el": "fire", "hold": true}}])
	assert_eq(f.b.debuffs[0].until, -1, "hold: my batch never ends")


func test_curses_readable_and_foe_ward_paid_refills() -> void:
	# t_new_readables (Weight of Names, Water Table).
	var f := _fight(_dummy({"effects": [{"id": "wt", "on": "foe_ward_paid", "do": [{"gain_qi": {"of": "amount", "share": 0.3}}]}]}), _dummy())
	for row in [["withering", 1.0], ["sundered", 2.0]]:
		var st := FighterState.StatusState.new()
		st.stacks = row[1]
		st.until = 1 << 40
		f.b.statuses[row[0]] = st
	assert_eq(_read(f, f.a, "foe.curses"), 2.0, "foe.curses counts curse statuses")
	f.a.qi = 0.0
	DefencePath.defend(f, f.a, f.b, 50.0, &"phys", null, {}, false)
	assert_true(f.b.ward_paid > 0.0 and absf(f.a.qi - 0.3 * f.b.ward_paid) < 1e-9,
			"the bill raises foe_ward_paid: %s %s" % [f.b.ward_paid, f.a.qi])


func test_art_scoped_speed_and_cost_reach_only_their_art() -> void:
	# t_scoped_art_reads.
	var fx := [{"id": "fast-fire", "on": "always", "do": [{"mod": {"art_speed": 100, "element": "fire"}},
		{"mod": {"cost_red": 0.5, "element": "fire"}}]}]
	var f := _fight(_dummy({"effects": fx}, [{"name": "fire", "c": 1.0, "cost": 0.05, "cd": 4.0, "element": "fire"},
			{"name": "other", "c": 1.0, "cost": 0.05, "cd": 4.0}]), _dummy())
	assert_eq(Array(f.a.ready), [2000, 4000], "a Fire-scoped art speed halves only the Fire art's opening")
	f.a.qi = f.a.qi_max()
	var q0: float = f.a.qi
	f.pay(f.a, f.a.p.arts[0])
	var paid_fire: float = q0 - f.a.qi
	f.a.qi = q0
	f.pay(f.a, f.a.p.arts[1])
	var paid_other: float = q0 - f.a.qi
	assert_near(paid_fire, 0.5 * paid_other, 1e-9, "a Fire-scoped cost reduction halves only the Fire art's cost")


func test_status_duration_raises_curses_and_resistance_rolls_against_them() -> void:
	# t_status_duration_and_resist (modifiers.md; Combat Formulas F).
	var f := _fight(_dummy({"effects": _fx([{"status_dur": 50, "tags": ["curse"]}])}), _dummy())
	f.apply_status(f.a, f.b, _spec({"id": "sundered", "dur": 2}))
	assert_eq(f.b.statuses["sundered"].until, 3000, "status_duration_pct 50 on curses: 2 pulses -> 3")
	f.apply_status(f.a, f.b, _spec({"id": "withering", "dur": 4}))
	assert_eq(f.b.statuses["withering"].until, 5000, "the curse clamp still holds after the raise")
	var landed := 0
	for s in 400:
		var g := _fight(_dummy(), _dummy({"effects": _fx([{"status_resist": 60}])}), s)
		g.apply_status(g.a, g.b, _spec({"id": "sundered"}))
		if g.b.statuses.has("sundered"):
			landed += 1
	var share_l: float = landed / 400.0
	assert_true(share_l > 0.33 and share_l < 0.47, "resist 60: a sure status lands about 40 percent: %s" % share_l)
	var h := _fight(_dummy(), _dummy({"effects": _fx([{"status_resist": 200}])}))
	var hits := 0
	for s in 2000:
		h.rng.seed = s
		h.b.statuses.clear()
		h.apply_status(h.a, h.b, _spec({"id": "sundered"}))
		if h.b.statuses.has("sundered"):
			hits += 1
	var share_h: float = hits / 2000.0
	assert_true(share_h > 0.03 and share_h < 0.07, "resistance above 100 leaves the 5 percent floor: %s" % share_h)


func test_healing_taken_scales_heals_and_is_floored() -> void:
	# t_heal_taken (Combat Defence & Healing E).
	var f := _fight(_dummy({"effects": _fx([{"heal_taken": 50}])}), _dummy())
	f.a.hp = f.a.hp_max / 2.0
	var h0: float = f.a.hp
	f.heal(f.a, 10.0)
	assert_near(f.a.hp - h0, 15.0, 1e-9, "healing_taken_pct 50: 10 restores 15")
	var g := _fight(_dummy({"effects": _fx([{"heal_taken": -90}])}), _dummy())
	g.a.hp = g.a.hp_max / 2.0
	var h1: float = g.a.hp
	g.heal(g.a, 10.0)
	assert_near(g.a.hp - h1, 5.0, 1e-9, "healing taken never falls below -50 percent")


func test_a_crit_restores_linh_luc_on_crit() -> void:
	# t_qi_on_crit (modifiers.md linh_luc_on_crit_pct).
	var f := _fight(_dummy({"crit": 1.0, "effects": _fx([{"qi_on_crit": 2.0}])}, [{"name": "x", "c": 1.0}]), _dummy())
	f.a.qi = 0.0
	f.hit(f.a, f.b, 1.0, &"phys", f.a.p.arts[0], Fight.KIND_ART)
	assert_near(f.a.qi, 0.02 * f.a.qi_max(), 1e-9, "a crit restores 2 percent of maximum")


func test_art_cost_health_splits_the_cost() -> void:
	# t_art_cost_health (Combat E).
	var art := {"name": "x", "c": 1.0, "cost": 0.05, "cd": 4.0}
	var f := _fight(_dummy({}, [art]), _dummy())
	f.a.qi = f.a.qi_max()
	var q0: float = f.a.qi
	f.pay(f.a, f.a.p.arts[0])
	var full: float = q0 - f.a.qi
	var g := _fight(_dummy({"effects": _fx([{"art_cost_hp": 100}])}, [art]), _dummy())
	g.a.qi = g.a.qi_max()
	var q1: float = g.a.qi
	var h1: float = g.a.hp
	g.pay(g.a, g.a.p.arts[0])
	assert_near(q1 - g.a.qi, full / 2.0, 1e-9, "linh luc pays half")
	assert_near(h1 - g.a.hp, full / 2.0, 1e-9, "health pays the other half point for point")


func test_pierce_and_penetration_by_final_type() -> void:
	# t_pen_and_pierce (AC-CB-44, AC-CD-13).
	var r0 := _fight(_dummy({"realm": 0}), _dummy({"realm": 2}))
	assert_near(r0._supp(r0.a, r0.b, 0.5), 0.875, 1e-9, "AC-CB-44 supp(2, 0.5) = 0.875")
	var r4 := _fight(_dummy({"realm": 0}), _dummy({"realm": 4}))
	assert_near(r4._supp(r4.a, r4.b, 0.9), 1.0 - 0.75 * 0.25, 1e-9, "pierce 90 stops at P 0.75")
	var r3 := _fight(_dummy({"realm": 3}), _dummy({"realm": 1}))
	assert_eq(r3._supp(r3.a, r3.b, 0.0), 1.0, "an actor above its target has supp 1")
	var got := {}
	for pen in [0, 30]:
		var f := _fight(_dummy({"effects": _fx([{"pen": pen, "dtype": "fire"}])}), _dummy({"resist": {"fire": 448.0, "cold": 448.0}}))
		f.b.qi = 0.0
		for dt in ["fire", "cold"]:
			f.b.hp = f.b.hp_max
			got["%d %s" % [pen, dt]] = DefencePath.defend(f, f.a, f.b, 100.0, StringName(dt), null, {"dtype": dt}, false)
	var g := _fight(_dummy(), _dummy())
	var blk: float = _k().block_unit[0] * g.b.p.block
	var body: float = g.b.p.body_pts * g.b.p.bs_mult
	assert_near(got["30 fire"], 100.0 / (1.0 + (418.0 + body) / 100.0) - blk, 1e-6, "Fire-scoped penetration 30: 448 -> 418")
	assert_near(got["30 cold"], got["0 cold"], 1e-9, "a Cold part is unchanged")
	assert_near(got["0 cold"], 100.0 / (1.0 + (448.0 + body) / 100.0) - blk, 1e-6, "and meets its full resistance")


func test_stack_grant_adds_to_its_element_only() -> void:
	# t_stack_grant (Effects rule 9a).
	var f := _fight(_dummy({"effects": _fx([{"stack_grant": 1, "element": "fire", "kind": "debuff"}])}), _dummy())
	f.add_stacks(f.a, f.b, "fire", 2.0, 6.0, false)
	f.add_stacks(f.a, f.b, "water", 2.0, 6.0, false)
	assert_eq([f.b.debuffs[0].n, f.b.debuffs[1].n], [3.0, 2.0], "Fire debuffs 2 -> 3, Water unchanged")


func test_an_elem_art_meets_its_elements_type_filters() -> void:
	# t_elem_type_scope.
	var f := _fight(_dummy(), _dummy())
	assert_true(EffectRunner.matches(f, {"dtype": "fire"}, {"dtype": "elem", "element": "fire"}), "Fire filter, Fire elem art")
	assert_true(EffectRunner.matches(f, {"dtype": "lightning"}, {"dtype": "elem", "element": "thunder"}), "Lightning filter, Thunder elem art")
	assert_false(EffectRunner.matches(f, {"dtype": "fire"}, {"dtype": "elem", "element": "water"}), "Fire filter, Water elem art")
	assert_false(EffectRunner.matches(f, {"dtype": "phys"}, {"dtype": "elem", "element": "metal"}), "Physical filter, elem art")
