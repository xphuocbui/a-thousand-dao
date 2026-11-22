extends DaoTestSuite
## FightPlayback (design/ux/fight-screen.md, Data Requirements): the fight screen's picture at a playback time is
## rebuilt from recorded rows only: bars, art tallies and charge, steps and empowers, stacks by expiry and cleanse,
## statuses, fired Effects, and the recent rows that drive floating numbers and link lines.


static func _row(kind: String, t_ms: int, side: String, art: String = "", values: Array = [], other: String = "") -> Dictionary:
	return {"kind": kind, "t_ms": t_ms, "side": side, "other": other, "art": art, "hit_kind": "", "values": values}


func _fight() -> Dictionary:
	return {"a": {"arts": [{"id": "cut", "cd": 2.0}]}, "b": {"arts": [{"id": "stone", "cd": 4.0}]}, "rows": [
		_row("pulse", 0, "A", "", [100.0, 50.0]),
		_row("pulse", 0, "B", "", [200.0, 80.0]),
		_row("art", 1000, "A", "cut", [10.0, 100.0, 40.0]),
		_row("hit", 1000, "A", "cut", [30.0, 25.0, 175.0, 80.0, 100.0, 40.0]),
		_row("stacks", 1000, "A", "fire", [3.0, 3000.0, 0.0], "B"),
		_row("stacks", 1000, "A", "wood", [2.0, -1.0, 1.0], "A"),
		_row("status", 1500, "A", "bleed", [2.0, 2500.0], "B"),
		_row("step", 2000, "A", "cut", [2.0]),
		_row("empower", 2500, "A", "cut", []),
		_row("cleanse", 2600, "B", "", [1.0]),
		_row("effect", 2700, "A", "twin_flames", []),
		_row("art", 3000, "A", "cut", [10.0, 100.0, 30.0]),
		_row("down", 5000, "B", "", []),
	]}


func test_bars_follow_the_latest_reading_and_keep_the_largest_as_maximum() -> void:
	var pb := FightPlayback.from_fight(_fight())
	assert_eq(pb.end_ms, 5000, "the last row's time ends the fight")
	assert_eq(pb.max_hp.B, 200.0, "the largest health seen is the bar's maximum")
	var st: Dictionary = pb.state_at(1200.0)
	assert_eq(st.sides.B.hp, 175.0, "the hit's defender health")
	assert_eq(st.sides.A.qi, 40.0, "the art's caster linh lực")
	assert_eq(st.pulses, 1, "pulses are counted once (side A's)")


func test_art_tally_charge_step_and_empower() -> void:
	var pb := FightPlayback.from_fight(_fight())
	assert_eq(pb.charge("A", "cut", 500.0), 0.5, "before its first firing: the share of the wait to it")
	assert_eq(pb.charge("A", "cut", 2000.0), 0.5, "between firings: the share of the recorded gap")
	assert_eq(pb.charge("A", "cut", 4000.0), 0.5, "after the last firing: the share of its cooldown")
	assert_eq(pb.charge("B", "stone", 100.0), 1.0, "an art that never fires reads ready")
	var st: Dictionary = pb.state_at(2800.0)
	assert_eq(st.sides.A.arts.cut.count, 1, "fired once by 2.8 s")
	assert_eq(st.sides.A.arts.cut.dmg, 25.0, "its damage so far is the dealt amount")
	assert_eq(st.sides.A.arts.cut.step, 2, "the step it reached")
	assert_true(st.sides.A.arts.cut.empowered, "empowered until it fires again")
	assert_true(not pb.state_at(3100.0).sides.A.arts.cut.empowered, "the next firing spends the empower")


func test_stacks_expire_and_cleanse_removes_the_oldest_first() -> void:
	var pb := FightPlayback.from_fight(_fight())
	var st: Dictionary = pb.state_at(2000.0)
	assert_eq(st.sides.B.debuff_totals.fire.n, 3.0, "three fire debuff stacks on B")
	assert_eq(st.sides.A.buff_totals.wood.n, 2.0, "a buff lands on its target (A on itself)")
	assert_eq(st.sides.A.buff_totals.wood.until, -1.0, "no expiry")
	assert_eq(pb.state_at(2700.0).sides.B.debuff_totals.fire.n, 2.0, "the cleanse removed one")
	assert_true(not pb.state_at(3100.0).sides.B.debuff_totals.has("fire"), "expired at 3.0 s")


func test_statuses_effects_and_down() -> void:
	var pb := FightPlayback.from_fight(_fight())
	assert_eq(pb.state_at(2000.0).sides.B.statuses.bleed.stacks, 2.0, "bleed on B")
	assert_true(not pb.state_at(2600.0).sides.B.statuses.has("bleed"), "gone after its expiry")
	assert_eq(pb.state_at(2800.0).sides.A.effects.twin_flames, 1, "a fired Effect is counted")
	assert_true(pb.state_at(5000.0).sides.B.down, "down at the end")
	assert_true(not pb.state_at(4999.0).sides.B.down, "not before")


func test_recent_rows_drive_floating_numbers() -> void:
	var pb := FightPlayback.from_fight(_fight())
	var recent: Array = pb.state_at(1500.0, 900.0).recent
	assert_true(recent.any(func(r): return str(r.kind) == "hit"), "a hit 0.5 s ago is recent")
	assert_true(pb.state_at(2500.0, 900.0).recent.all(func(r): return str(r.kind) != "hit"), "1.5 s later it is gone")
