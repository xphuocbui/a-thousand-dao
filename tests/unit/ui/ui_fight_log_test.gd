extends DaoTestSuite
## FightLog (design/ux/interaction-patterns.md "Log list"; design/ux/fight-screen.md "Fight log"): Summary entries join
## an art's firing with its same-instant hits, fold repeats within the gap and sum what they dealt; filters by side
## and kind; Full has one entry per pulse with damage by type and the readings after; the result line states
## recorded facts about the losing side.


static func _row(kind: String, t_ms: int, side: String, art: String = "", values: Array = [], other: String = "") -> Dictionary:
	return {"kind": kind, "t_ms": t_ms, "side": side, "other": other, "art": art, "hit_kind": "", "values": values}


func _fight() -> Dictionary:
	return {"winner": "B", "ending": "knockout", "seconds": 4.0,
		"a": {"arts": [{"id": "cut", "cd": 2.0, "cost": 10.0, "pool": "qi", "element": "", "dtype": "phys"}]},
		"b": {"arts": [{"id": "stone", "cd": 4.0, "cost": 20.0, "pool": "qi", "element": "earth", "dtype": "phys"}]},
		"rows": [
			_row("pulse", 0, "A", "", [100.0, 50.0]),
			_row("pulse", 0, "B", "", [200.0, 80.0]),
			_row("art", 0, "A", "cut", [10.0, 100.0, 40.0]),
			_row("hit", 0, "A", "cut", [30.0, 25.0, 175.0, 80.0, 100.0, 40.0]),
			_row("tick", 400, "A", "burn", [8.0, 8.0, 167.0, 80.0], "B"),
			_row("pulse", 1000, "A", "", [100.0, 8.0]),
			_row("pulse", 1000, "B", "", [167.0, 80.0]),
			_row("art", 1000, "B", "stone", [20.0, 167.0, 60.0]),
			_row("hit", 1000, "B", "stone", [70.0, 60.0, 40.0, 8.0, 167.0, 60.0]),
			_row("tick", 1400, "A", "burn", [8.0, 6.0, 161.0, 60.0], "B"),
			_row("tick", 2400, "A", "burn", [8.0, 7.0, 154.0, 60.0], "B"),
			_row("pulse", 2000, "A", "", [40.0, 5.0]),
			_row("hit", 3000, "B", "", [45.0, 40.0, 0.0, 5.0, 154.0, 60.0]),
			_row("tick", 6000, "A", "burn", [8.0, 8.0, 146.0, 60.0], "B"),
			_row("down", 3000, "A", "", []),
		]}


func _opts() -> Dictionary:
	return FightLog.default_options({"fold_gap_ms": 1500})


func test_summary_joins_an_art_with_its_same_instant_hit() -> void:
	var f: Dictionary = _fight()
	var lines: Array = FightLog.summary(f.rows, _opts())
	var cut: Dictionary = lines.filter(func(e): return e.kind == "art" and e.art == "cut")[0]
	assert_eq(cut.hits, 1, "the hit at the art's instant joins the art")
	assert_eq(cut.total, 25.0, "and its dealt amount (not the amount before defence) is the art's total")
	assert_true(lines.all(func(e): return e.kind != "pulse"), "pulse rows are never entries on their own")
	assert_eq(lines.filter(func(e): return e.kind == "hit").size(), 1, "only the basic attack stays a separate hit")


func test_summary_folds_repeats_within_the_gap_and_their_total_equals_the_rows() -> void:
	var f: Dictionary = _fight()
	var lines: Array = FightLog.summary(f.rows, _opts())
	var burns: Array = lines.filter(func(e): return e.kind == "tick")
	assert_eq(burns.size(), 2, "three burns 1 s apart fold; the one 3.6 s later starts a new entry")
	assert_eq(burns[0].count, 3, "the folded entry counts its repeats")
	var sum: float = 0.0
	for i in burns[0].rows:
		sum += FightLog.dealt(f.rows[i])
	assert_eq(burns[0].total, sum, "a folded total equals the sum of its expanded rows")
	assert_eq(burns[0].total, 21.0, "8 + 6 + 7 dealt")
	assert_eq(burns[0].t_last, 2400, "the folded entry sits at its latest repeat")


func test_summary_is_the_same_whether_scrubbed_or_played_to_a_time() -> void:
	var f: Dictionary = _fight()
	var upto: Array = f.rows.filter(func(r): return int(r.t_ms) <= 1400)
	var a: Array = FightLog.summary(upto, _opts())
	var b: Array = FightLog.summary(upto.duplicate(true), _opts())
	assert_eq(a.map(func(e): return [e.id, e.count, e.total]), b.map(func(e): return [e.id, e.count, e.total]),
		"the log is a pure function of the rows up to the time")
	assert_eq(a.filter(func(e): return e.kind == "tick")[0].count, 2, "by 1.4 s two burns have folded")


func test_filters_by_side_and_by_kind() -> void:
	var f: Dictionary = _fight()
	var o: Dictionary = _opts()
	o.sides.B = false
	assert_true(FightLog.summary(f.rows, o).all(func(e): return e.side == "A"), "the foe's lines are hidden")
	var o2: Dictionary = _opts()
	o2.groups.damage = false
	var lines: Array = FightLog.summary(f.rows, o2)
	assert_true(lines.all(func(e): return e.kind != "tick" and e.kind != "hit"), "damage lines are hidden")
	assert_true(lines.any(func(e): return e.kind == "art"), "a fired art stays while arts are shown")


func test_full_has_one_entry_per_pulse_with_damage_by_type_and_readings_after() -> void:
	var f: Dictionary = _fight()
	var type_of := func(r): return FightLog.type_label(r, {"A": f.a.arts, "B": f.b.arts})
	var lines: Array = FightLog.full(f.rows, _opts(), type_of)
	assert_eq(lines.size(), 3, "pulses at 0, 1 and 2 s (side A's pulse rows are the boundaries)")
	assert_eq(lines[0].sides.A.dealt, {"phys": 25.0, "burn": 8.0}, "first pulse: the cut (phys) and a burn tick")
	assert_eq(lines[1].sides.B.dealt, {"earth": 60.0}, "the stone art's element labels its damage")
	assert_eq(lines[1].sides.A.hp, 40.0, "the side's health after the pulse")
	assert_eq(lines[1].sides.A.qi, 8.0, "and its linh lực")
	assert_eq(lines[0].sides.A.arts, {"cut": 1}, "arts fired in the pulse")


func test_result_states_recorded_facts_about_the_losing_side() -> void:
	var f: Dictionary = _fight()
	var type_of := func(r): return FightLog.type_label(r, {"A": f.a.arts, "B": f.b.arts})
	var res: Dictionary = FightLog.result(f, type_of)
	assert_eq(res.subject, "A", "the reasons are about the side that lost")
	assert_eq(res.reasons.size(), 3, "at most three reasons")
	assert_eq(res.reasons[0].key, "qi_low", "linh lực sat below the cheapest art's cost")
	assert_near(float(res.reasons[0].share), 5000.0 / 6000.0, 1e-9, "from 1.0 s to the last row at 6.0 s")
	assert_eq(res.reasons[1].key, "taken_share", "then the largest share of damage taken")
	assert_eq(res.reasons[1].label, "earth", "60 of 100 taken was Earth")
	assert_eq(res.reasons[1].share, 0.6, "a 60 % share")
	assert_eq(res.reasons[2].key, "dealt_taken", "the stone art is the whole Earth share, so it is not repeated")


func test_result_names_the_top_source_when_it_is_not_the_whole_type_share() -> void:
	var f: Dictionary = _fight()
	f.rows.append(_row("hit", 3500, "B", "", [30.0, 30.0, 0.0, 5.0, 154.0, 60.0]))   # basic: phys 70 > earth 60
	f.b.arts.append({"id": "pebble", "cd": 2.0, "cost": 5.0, "pool": "qi", "element": "", "dtype": "phys"})
	f.rows.append(_row("hit", 3600, "B", "pebble", [20.0, 20.0, 0.0, 5.0, 154.0, 60.0]))
	var type_of := func(r): return FightLog.type_label(r, {"A": f.a.arts, "B": f.b.arts})
	var res: Dictionary = FightLog.result(f, type_of, 4)
	assert_eq(res.reasons[1].label, "phys", "basic 70 and pebble 20 make phys the largest type (90 of 150)")
	assert_eq(res.reasons[2], {"key": "top_source", "side": "B", "art": "", "share": 70.0 / 150.0},
		"the basic attacks (70) are only part of the phys share, so they are named")


func test_rows_in_time_order_keep_the_record_order_within_an_instant() -> void:
	var rows: Array = [_row("pulse", 2000, "A"), _row("art", 1000, "A", "x"), _row("hit", 1000, "A", "x"), _row("pulse", 0, "A")]
	var ordered: Array = FightLog.in_time_order(rows)
	assert_eq(ordered.map(func(r): return r.kind), ["pulse", "art", "hit", "pulse"], "by time, the art before its hit")
	assert_eq(ordered.map(func(r): return r.t_ms), [0, 1000, 1000, 2000], "times ascending")


func test_reflect_return_soul_and_qi_tick_rows_are_credited_to_their_actor() -> void:
	# As the engine writes them (fight.gd, effect_runner.gd): REFLECT and RETURN are dealt by the row's side to its foe,
	# with the foe's readings; SOUL removes the foe's health; QI_TICK drains the foe's linh lực (no damage dealt).
	var rows: Array = [
		_row("pulse", 0, "A", "", [100.0, 50.0]),
		_row("pulse", 0, "B", "", [100.0, 50.0]),
		_row("reflect", 100, "A", "", [10.0, 9.0, 91.0, 50.0]),
		_row("return", 200, "A", "", [5.0, 4.0, 87.0, 50.0]),
		_row("soul", 300, "A", "mind_spike", [6.0, 2.0, 81.0, 48.0]),
		_row("qi_tick", 400, "A", "leech", [3.0, 81.0, 45.0]),
	]
	var f := {"winner": "A", "ending": "knockout", "seconds": 1.0, "rows": rows, "a": {"arts": []}, "b": {"arts": []}}
	var type_of := func(r): return FightLog.type_label(r, {})
	var res: Dictionary = FightLog.result(f, type_of, 5)
	assert_eq(res.subject, "B", "B lost")
	var dt: Dictionary = res.reasons.filter(func(x): return x.key == "dealt_taken")[0]
	assert_eq(dt.taken, 19.0, "B took the reflect (9), the return (4) and the Soul hit (6); a linh lực drain is not damage")
	assert_eq(res.reasons.filter(func(x): return x.key == "taken_share")[0].label, "reflect", "reflect is the largest share")
	var pb := FightPlayback.from_fight(f)
	var st: Dictionary = pb.state_at(400.0)
	assert_eq(st.sides.B.hp, 81.0, "every reading lands on B")
	assert_eq(st.sides.B.qi, 45.0, "the drain's reading is B's linh lực")
	assert_eq(st.sides.A.hp, 100.0, "A's health is untouched")
	assert_eq(FightLog.type_label(rows[4], {}), "soul", "a Soul hit is labelled Soul")
