extends DaoTestSuite
## NPC Relationships' season step S8b (TieTick) against design/gdd/npc-relationships.md: hardening (rule 11), betrayal
## (rule 12), death and inheritance (rule 13, Formula D, the FX-FAM fixtures), ends and their news kinds (rules 1b, 14),
## repaying a debt (rule 14), lost notability (rule 6), the queue's order (rule 9) and the hook pass (rule 15a).

const S := 100


func _person(db: WorldDB, id: String, born: int = 1000, extra: Dictionary = {}) -> void:
	var p := {"id": id, "alive": true, "realm_index": 0, "sect_rank": "", "born_year": born, "location_id": "l1",
		"npc_traits": {"personality": [], "calling": "", "fate": [], "gained": []}}
	p.merge(extra, true)
	db.put("people", p)


# FX-FAM: sect head H (notable), children C1 (elder) and C2, disciples D1 (eldest) to D30, a sibling S; K (notable)
# holds 16 ties (4 pinned, 12 soft-only), none with them.
func _fam() -> WorldDB:
	var gd := game_data()
	var db := WorldDB.new()
	Ties.set_now(db, S)
	_person(db, "p100", 700, {"sect_rank": "tong_chu"})   # H
	_person(db, "p101", 900, {"parent_id": "p100"})   # C1
	_person(db, "p102", 910, {"parent_id": "p100"})   # C2
	_person(db, "p103", 690)   # S
	_person(db, "p200", 800, {"sect_rank": "truong_lao"})   # K
	for i in range(1, 31):
		_person(db, "p%d" % (110 + i), 920 + i)   # D1..D30
	Ties.add_pinned(gd, db, "p100", "p101", "kin", S, true)
	Ties.add_pinned(gd, db, "p100", "p102", "kin", S, true)
	Ties.add_pinned(gd, db, "p100", "p103", "kin", S, true)
	for i in range(1, 31):
		Ties.set_master(gd, db, "p%d" % (110 + i), "p100", S)
	for i in range(1, 17):   # K's own ties
		_person(db, "p%d" % (300 + i), 950)
		if i <= 4:
			Ties.add_pinned(gd, db, "p200", "p%d" % (300 + i), "kin", S, true)
		else:
			Ties.write_soft(gd, db, "p200", "p%d" % (300 + i), "friend", 40, S)
	return db


func _d(i: int) -> String:
	return "p%d" % (110 + i)


func _feud(db: WorldDB, holder: String, target: String) -> Dictionary:
	return db.tie_between(holder, target).get("feud", {}).get(holder, {})


func _enm(gd: GameData, db: WorldDB, holder: String, target: String) -> int:
	var rec: Dictionary = db.tie_between(holder, target)
	if str(rec.get("soft", {}).get("kind", "")) != "enmity":
		return 0
	return int(ceil(Ties.soft_s(Ties.cfg(gd), rec, holder, S) / 100.0))


func _kill(db: WorldDB, killer: String, dead: String, known: bool = true) -> void:
	db.get_record("people", dead)["alive"] = false
	TieTick.enqueue(db, {"kind": "death", "dead": dead, "killer": killer, "known": known, "place": "l1", "cause": "kill", "event": "e1"})


func test_a_known_kill_leaves_three_heirs_and_five_mourners_ac_nr_18() -> void:
	var gd := game_data()
	var db := _fam()
	_kill(db, "p200", "p100")
	TieTick.run(gd, db, S)
	for h in ["p101", "p102", _d(1)]:
		assert_true(bool(_feud(db, h, "p200").get("inherited", false)), "%s holds an inherited feud" % h)
	for m in ["p103", _d(2), _d(3), _d(4), _d(5)]:
		assert_eq(_enm(gd, db, m, "p200"), 50, "%s mourns at 50" % m)
	for i in range(6, 31):
		assert_true(db.tie_between(_d(i), "p200").is_empty(), "D%d takes nothing" % i)
	assert_eq(db.ties_of("p200").size(), 24, "K: 16 + 8")
	assert_eq(Ties.soft_only(db, "p200").size(), 12, "K's earlier soft ties remain; the mourners' sit outside its cap")
	assert_eq(db.ties_of("p100").size(), 0, "H has no records left")


func test_an_avenger_takes_an_heirs_slot_with_its_own_feud_ac_nr_16() -> void:
	var gd := game_data()
	var db := _fam()
	Ties.write_soft(gd, db, _d(6), "p200", "enmity", 10, S, {"force": true})   # written directly (FX-FAM's note)
	_kill(db, "p200", "p100")
	TieTick.run(gd, db, S)
	assert_false(bool(_feud(db, _d(6), "p200").get("inherited", true)), "D6's feud is its own")
	assert_eq(_enm(gd, db, _d(6), "p200"), 0, "its soft enmity is removed")
	assert_true(bool(_feud(db, "p101", "p200").inherited) and bool(_feud(db, "p102", "p200").inherited), "C1 and C2 inherit")
	assert_true(_feud(db, _d(1), "p200").is_empty(), "D1 is displaced")
	for m in ["p103", _d(1), _d(2), _d(3), _d(4)]:
		assert_eq(_enm(gd, db, m, "p200"), 50, "%s mourns" % m)


func test_hardening_turns_enmity_into_a_feud_on_the_same_record_ac_nr_16() -> void:
	var gd := game_data()
	var db := _fam()
	Ties.write_soft(gd, db, "p301", "p302", "enmity", 50, S)
	TieTick.enqueue(db, {"kind": "soft", "holder": "p301", "other": "p302", "sk": "enmity", "delta": 40, "cause": {"kind": "event"}})
	TieTick.run(gd, db, S)
	var rec: Dictionary = db.tie_between("p301", "p302")
	assert_false(bool(_feud(db, "p301", "p302").get("inherited", true)), "a pinned feud, not inherited")
	assert_true(Dictionary(rec.get("soft", {})).is_empty(), "no soft enmity")
	assert_eq(db.ties_of("p301").filter(func(r): return Ties._other(r, "p301") == "p302").size(), 1, "the same record")


func test_strongest_avengers_displace_the_children_and_mourners_keep_the_stronger_enmity_ac_nr_46() -> void:
	var gd := game_data()
	var db := _fam()
	for i in [1, 2, 3]:
		Ties.write_soft(gd, db, _d(i), "p200", "enmity", 85, S, {"force": true})
	Ties.write_soft(gd, db, _d(4), "p200", "enmity", 80, S, {"force": true})
	_kill(db, "p200", "p100")
	TieTick.run(gd, db, S)
	for i in [1, 2, 3]:
		assert_false(bool(_feud(db, _d(i), "p200").get("inherited", true)), "D%d an avenger" % i)
	assert_eq([_enm(gd, db, "p101", "p200"), _enm(gd, db, "p102", "p200"), _enm(gd, db, "p103", "p200"),
		_enm(gd, db, _d(4), "p200"), _enm(gd, db, _d(5), "p200")], [50, 50, 50, 80, 50], "C1, C2, S, D4 keeps 80, D5")


func test_an_unknown_kill_leaves_no_feud_and_a_killing_heir_is_struck_ac_nr_19() -> void:
	var gd := game_data()
	var db := _fam()
	_kill(db, "p200", "p100", false)
	TieTick.run(gd, db, S)
	assert_eq(db.ties_of("p200").size(), 16, "nothing toward K")
	var db2 := _fam()
	_kill(db2, _d(1), "p100")
	TieTick.run(gd, db2, S)
	assert_true(_feud(db2, _d(1), _d(1)).is_empty() and not _feud(db2, _d(2), _d(1)).is_empty(), "D2 takes the third heir slot")
	for m in ["p103", _d(3), _d(4), _d(5), _d(6)]:
		assert_eq(_enm(gd, db2, m, _d(1)), 50, "%s mourns D1's victim" % m)


func test_an_inherited_feud_passes_on_as_soft_enmity_with_its_origin_ac_nr_20() -> void:
	var gd := game_data()
	var db := _fam()
	_person(db, "p401", 960, {"parent_id": "p101"})   # X1
	_person(db, "p402", 965, {"parent_id": "p101"})   # X2
	_person(db, "p403", 970)   # Y1
	Ties.add_pinned(gd, db, "p101", "p401", "kin", S, true)
	Ties.add_pinned(gd, db, "p101", "p402", "kin", S, true)
	Ties.set_master(gd, db, "p403", "p101", S)
	var origin := {"dead": "p999", "killer": "p200", "season": 90, "place": "l9"}
	Ties.set_feud(gd, db, "p101", "p200", S, {"inherited": true, "generation": 0, "cause": {"kind": "inherited", "origin": origin}})
	db.get_record("people", "p101")["alive"] = false
	TieTick.enqueue(db, {"kind": "death", "dead": "p101", "killer": "", "known": false, "cause": "old_age"})
	TieTick.run(gd, db, S)
	for x in ["p401", "p402", "p403"]:
		var rec: Dictionary = db.tie_between(x, "p200")
		assert_eq(_enm(gd, db, x, "p200"), 50, "%s holds enmity 50" % x)
		assert_true(_feud(db, x, "p200").is_empty(), "%s holds no pinned feud" % x)
		assert_eq(str(rec.outside_cap), "p200", "outside K's cap")
		var cause: Dictionary = rec.soft.dir[x].cause
		assert_eq([JSON.stringify(cause.origin), int(cause.generation)], [JSON.stringify(origin), 1], "the origin, generation 1")


func test_debts_owed_to_the_dead_pass_to_the_heirs_and_debts_it_owed_are_cancelled_ac_nr_21() -> void:
	var gd := game_data()
	var db := _fam()
	_person(db, "p500")
	Ties.write_debt(gd, db, "p500", "p100", 80, S)
	db.get_record("people", "p100")["alive"] = false
	TieTick.enqueue(db, {"kind": "death", "dead": "p100", "cause": "old_age"})
	TieTick.run(gd, db, S)
	var c: Dictionary = Ties.cfg(gd)
	for h in ["p101", "p102", _d(1)]:
		var rec: Dictionary = db.tie_between("p500", h)
		assert_eq([str(rec.get("debt", {}).get("debtor", "")), Ties.debt_s(c, rec, S)], ["p500", 4000], "owes %s 40" % h)
	var db2 := _fam()
	_person(db2, "p500")
	Ties.write_debt(gd, db2, "p500", "p100", 80, S)
	for i in 3:   # two free slots left
		_person(db2, "p6%02d" % i)
		Ties.write_soft(gd, db2, "p500", "p6%02d" % i, "friend", 60, S)
	db2.get_record("people", "p100")["alive"] = false
	TieTick.enqueue(db2, {"kind": "death", "dead": "p100", "cause": "old_age"})
	TieTick.run(gd, db2, S)
	assert_false(db2.tie_between("p500", "p101").is_empty() or db2.tie_between("p500", "p102").is_empty(), "C1 and C2")
	assert_true(db2.tie_between("p500", _d(1)).is_empty(), "D1 is skipped: no weaker record to evict")
	var db3 := _fam()
	_person(db3, "p500")
	Ties.write_debt(gd, db3, "p100", "p500", 60, S)
	db3.get_record("people", "p100")["alive"] = false
	TieTick.enqueue(db3, {"kind": "death", "dead": "p100", "cause": "old_age"})
	TieTick.run(gd, db3, S)
	assert_true(db3.ties_of("p500").is_empty(), "the debt the dead owed is cancelled")


func _end_news(db: WorldDB) -> Array:
	return db.all("events").filter(func(e): return str(e.type) == "tie_end").map(func(e): return str(e.data.news))


func test_a_feud_ends_with_its_targets_death_and_the_right_news_ac_nr_22() -> void:
	var gd := game_data()
	for case in [["", "old_age", "feud_end_natural"], ["p1", "kill", "feud_end_avenged"], ["p3", "kill", "feud_end_slain"]]:
		var db := WorldDB.new()
		Ties.set_now(db, S)
		for id in ["p1", "p2", "p3"]:
			_person(db, id)
		Ties.set_feud(gd, db, "p1", "p2", S)
		db.get_record("people", "p2")["alive"] = false
		TieTick.enqueue(db, {"kind": "death", "dead": "p2", "killer": str(case[0]), "known": true, "cause": str(case[1])})
		TieTick.run(gd, db, S)
		assert_eq(_end_news(db), [str(case[2])], "killer '%s'" % case[0])


func test_two_people_who_kill_each_other_leave_no_feud_ac_nr_23() -> void:
	var gd := game_data()
	var db := _fam()
	_kill(db, "p100", "p200")
	_kill(db, "p200", "p100")
	TieTick.run(gd, db, S)
	assert_true(_feud(db, "p101", "p200").is_empty() and _feud(db, "p301", "p100").is_empty(), "no feud toward either")


func test_betrayal_breaks_a_pinned_bond_ac_nr_17() -> void:
	var gd := game_data()
	var db := _fam()
	Ties.add_pinned(gd, db, "p301", "p302", "ket_nghia", S, true)
	db.tie_between("p301", "p302")["favour"] = "p301"
	TieTick.enqueue(db, {"kind": "betrayal", "betrayer": "p302", "betrayed": "p301"})
	TieTick.run(gd, db, S)
	var rec: Dictionary = db.tie_between("p301", "p302")
	assert_eq([Dictionary(rec.pin).has("ket_nghia"), str(rec.favour)], [false, ""], "kết nghĩa and the favour are removed")
	assert_eq([_enm(gd, db, "p301", "p302"), _enm(gd, db, "p302", "p301")], [70, 0], "the betrayed holds enmity 70")
	var db2 := _fam()
	Ties.add_pinned(gd, db2, "p301", "p302", "kin", S, true)
	TieTick.enqueue(db2, {"kind": "betrayal", "betrayer": "p302", "betrayed": "p301"})
	TieTick.run(gd, db2, S)
	assert_true(Dictionary(db2.tie_between("p301", "p302").pin).has("kin"), "kin stays")
	var db3 := _fam()
	Ties.add_pinned(gd, db3, "p301", "p302", "ket_nghia", S, true)
	Ties.write_soft(gd, db3, "p301", "p302", "enmity", 40, S)
	TieTick.enqueue(db3, {"kind": "betrayal", "betrayer": "p302", "betrayed": "p301"})
	TieTick.run(gd, db3, S)
	assert_false(_feud(db3, "p301", "p302").is_empty(), "40 + 70 hardens into a feud at step 6")


func test_repaying_a_rescue_debt_leaves_a_friend_at_the_floor_ac_nr_40() -> void:
	var gd := game_data()
	var db := _fam()
	var c: Dictionary = Ties.cfg(gd)
	Ties.write_debt(gd, db, "p302", "p301", 60, S)
	TieTick.enqueue(db, {"kind": "repay", "debtor": "p302", "creditor": "p301"})
	TieTick.run(gd, db, S)
	var rec: Dictionary = db.tie_between("p301", "p302")
	assert_eq([Dictionary(rec.debt).is_empty(), str(rec.soft.kind), Ties.soft_s(c, rec, "p301", S)], [true, "friend", 3000], "friend 30")
	Ties.write_debt(gd, db, "p304", "p303", 60, S)
	Ties.write_soft(gd, db, "p303", "p304", "friend", 50, S)
	TieTick.enqueue(db, {"kind": "repay", "debtor": "p304", "creditor": "p303"})
	TieTick.run(gd, db, S)
	assert_eq(Ties.soft_s(c, db.tie_between("p303", "p304"), "p303", S), 5000, "friend 50 stays 50")


func test_a_lost_rank_evicts_soft_ties_down_to_the_ordinary_limit_at_the_next_s8b_ac_nr_14() -> void:
	var gd := game_data()
	var db := WorldDB.new()
	Ties.set_now(db, S)
	_person(db, "p1", 900, {"sect_rank": "truong_lao"})
	for i in range(2, 14):
		_person(db, "p%d" % i)
		if i <= 5:
			Ties.add_pinned(gd, db, "p1", "p%d" % i, "kin", S, true)
		else:
			Ties.write_soft(gd, db, "p1", "p%d" % i, "friend", 10 + i, S)
	assert_eq(db.ties_of("p1").size(), 12, "4 pinned, 8 soft-only")
	db.get_record("people", "p1")["sect_rank"] = ""
	TieTick.enqueue(db, {"kind": "notability", "pid": "p1"})
	assert_eq(db.ties_of("p1").size(), 12, "nothing changes before S8b")
	TieTick.run(gd, db, S)
	assert_eq(db.ties_of("p1").size(), 6, "2 soft-only remain")
	assert_false(db.tie_between("p1", "p13").is_empty(), "the strongest stay")


func test_the_queue_applies_by_step_whatever_the_enqueue_order_ac_nr_25() -> void:
	var gd := game_data()
	var results: Array = []
	for order in [[0, 1, 2, 3], [3, 2, 1, 0]]:
		var db := WorldDB.new()
		Ties.set_now(db, S)
		for id in ["p1", "p2", "p3", "p4", "p5", "p6"]:
			_person(db, id)
		db.get_record("people", "p3")["sect_rank"] = "truong_lao"   # B notable
		# A = p1, master M = p2, B = p3, C = p4, D = p5, K = p6
		Ties.set_master(gd, db, "p1", "p2", S)
		Ties.write_soft(gd, db, "p1", "p6", "enmity", 20, S)
		Ties.add_pinned(gd, db, "p1", "p3", "ket_nghia", S)
		Ties.write_soft(gd, db, "p1", "p4", "enmity", 70, S)
		db.get_record("people", "p2")["alive"] = false
		var ch := [{"kind": "death", "dead": "p2", "killer": "p6", "known": true, "cause": "kill"},
			{"kind": "betrayal", "betrayer": "p3", "betrayed": "p1"},
			{"kind": "soft", "holder": "p1", "other": "p4", "sk": "enmity", "delta": 30},
			{"kind": "soft", "holder": "p1", "other": "p5", "sk": "friend", "delta": 20}]
		for i in order:
			TieTick.enqueue(db, ch[i])
		TieTick.run(gd, db, S)
		results.append([bool(_feud(db, "p1", "p6").get("inherited", true)), _enm(gd, db, "p1", "p3"),
			Dictionary(db.tie_between("p1", "p3").pin).has("ket_nghia"), not _feud(db, "p1", "p4").is_empty(),
			str(db.tie_between("p1", "p5").get("soft", {}).get("kind", ""))])
	assert_eq(results[0], [false, 70, false, true, "friend"], "A's own feud on K; B's betrayal; C hardened; friend D")
	assert_eq(results[1], results[0], "the same in another enqueue order")


func test_the_hook_pass_gives_master_and_dao_lu_rows_and_takes_them_away_ac_nr_32_33() -> void:
	var gd := game_data()
	var db := WorldDB.new()
	Ties.set_now(db, S)
	_person(db, "p1", 900, {"realm_index": 2})
	_person(db, "p2")
	_person(db, "p3", 900, {"sect_rank": "truong_lao"})
	Ties.set_master(gd, db, "p2", "p1", S)
	Ties.add_pinned(gd, db, "p2", "p3", "dao_lu", S)
	TieTick.run(gd, db, S)
	var rows: Array = db.get_record("people", "p2").get("tie_rows", [])
	assert_eq(rows.map(func(r): return [str(r.source), float(r.value)]), [["master", 5.0], ["dao_lu", 8.0]], "master +5 and đạo lữ +8")
	db.get_record("people", "p3")["location_id"] = "l2"
	db.get_record("people", "p1")["realm_index"] = 0
	TieTick.run(gd, db, S + 1)
	assert_false(db.get_record("people", "p2").has("tie_rows"), "apart, and the master no higher: no rows")
	var c := Character.from_dict({"id": "p9", "tie_rows": [{"stat": "cultivation_speed_pct", "value": 5.0, "source": "master"}]})
	var sheet := StatSheet.build(c, gd, null, null)
	assert_true(JSON.stringify(sheet.sources("cultivation_speed_pct")).contains("Quan hệ: sư phụ"), "the sheet reads the row")


func test_the_met_list_makes_someone_notable_until_they_drop_off_it_ac_nr_43() -> void:
	var gd := game_data()
	var db := WorldDB.new()
	Ties.set_now(db, S)
	_person(db, "p0", 900, {"is_player": true})
	_person(db, "p1")   # X
	var met: Array = []
	for pid in ["p1"] + range(2, 501).map(func(i): return "p%d" % (1000 + i)):
		met = Ties.met_after(gd, met, str(pid)).list
	db.get_record("people", "p0")["met_list"] = met
	assert_true(Ties.notable(gd, db, "p1"), "X is on the list (500th)")
	for i in range(2, 4):
		_person(db, "p%d" % i)
		Ties.add_pinned(gd, db, "p1", "p%d" % i, "kin", S, true)
	for i in range(4, 18):
		_person(db, "p%d" % i)
		Ties.write_soft(gd, db, "p1", "p%d" % i, "friend", 20 + i, S)
	assert_eq(db.ties_of("p1").size(), 16, "15 then the 16th forms")
	var m: Dictionary = Ties.met_after(gd, met, "p9999")
	db.get_record("people", "p0")["met_list"] = m.list
	assert_eq(m.dropped, ["p1"], "X drops off the end")
	for x in m.dropped:
		TieTick.enqueue(db, {"kind": "notability", "pid": str(x)})
	TieTick.run(gd, db, S)
	assert_eq(db.ties_of("p1").size(), 6, "evicted down to 4 soft-only")
	assert_eq(Ties.met_after(gd, m.list, "p1").list[0], "p1", "meeting X again puts X at the front")


func test_an_events_tie_effect_is_queued_and_applied_at_s8b_rule_8() -> void:
	var gd := game_data()
	var db := WorldDB.new()
	Ties.set_now(db, S)
	_person(db, "p2")
	var c := Character.from_dict({"id": "p1", "name": "A"})
	db.put("people", c.to_dict())
	db.get_record("people", "p1")["alive"] = true
	var er := EventResolver.new(gd, db, null, ItemFactory.new(gd))
	var line: String = er._apply(c, null, rng(1), {"npc_id": "p2"}, {"type": "tie_add", "kind": "friend", "delta": 20}, [])
	assert_true(db.tie_between("p1", "p2").is_empty(), "queued, not yet applied")
	assert_true(line.contains("friend"), "the outcome says so")
	TieTick.run(gd, db, S)
	assert_eq(str(db.tie_between("p1", "p2").get("soft", {}).get("kind", "")), "friend", "friend 20 at S8b")


func test_feuds_the_dead_held_pass_on_ac_nr_54() -> void:
	var gd := game_data()
	var db := _fam()
	_person(db, "p900")   # T
	Ties.set_feud(gd, db, "p100", "p900", S)
	Ties.write_soft(gd, db, _d(1), "p900", "enmity", 20, S)
	db.get_record("people", "p100")["alive"] = false
	TieTick.enqueue(db, {"kind": "death", "dead": "p100", "cause": "old_age"})
	TieTick.run(gd, db, S)
	for h in ["p101", "p102", _d(1)]:
		assert_true(bool(_feud(db, h, "p900").get("inherited", false)), "%s inherits the feud toward T" % h)
	assert_eq(_enm(gd, db, _d(1), "p900"), 0, "D1's enmity is removed")
	for m in ["p103", _d(2), _d(3), _d(4), _d(5)]:
		assert_eq(_enm(gd, db, m, "p900"), 50, "%s mourns toward T" % m)
	var db2 := _fam()   # T is C2: struck, D2 takes the third slot
	Ties.set_feud(gd, db2, "p100", "p102", S)
	db2.get_record("people", "p100")["alive"] = false
	TieTick.enqueue(db2, {"kind": "death", "dead": "p100", "cause": "old_age"})
	TieTick.run(gd, db2, S)
	assert_true(not _feud(db2, _d(1), "p102").is_empty() and not _feud(db2, _d(2), "p102").is_empty(), "D1 and D2 with C1")
	var db3 := _fam()   # D5's enmity 85 toward T: a mourner, not an heir (no known kill)
	_person(db3, "p900")
	Ties.set_feud(gd, db3, "p100", "p900", S)
	Ties.write_soft(gd, db3, _d(5), "p900", "enmity", 85, S)
	db3.get_record("people", "p100")["alive"] = false
	TieTick.enqueue(db3, {"kind": "death", "dead": "p100", "cause": "old_age"})
	TieTick.run(gd, db3, S)
	assert_true(_feud(db3, _d(5), "p900").is_empty(), "D5 is not an heir")
	assert_eq(_enm(gd, db3, _d(5), "p900"), 85, "and keeps the stronger 85 as a mourner")


func test_an_inherited_feud_is_renewed_by_a_new_kill_and_a_weaker_mourner_enmity_is_dropped_ac_nr_55() -> void:
	var gd := game_data()
	var db := _fam()
	Ties.set_feud(gd, db, _d(1), "p200", S, {"inherited": true})
	Ties.write_soft(gd, db, "p103", "p200", "friend", 60, S, {"force": true})
	_kill(db, "p200", "p100")
	TieTick.run(gd, db, S)
	var f1: Dictionary = _feud(db, _d(1), "p200")
	assert_eq([bool(f1.inherited), str(f1.cause.kind)], [false, "kill"], "D1's feud is its own now")
	assert_true(not _feud(db, "p101", "p200").is_empty() and not _feud(db, "p102", "p200").is_empty(), "C1 and C2 inherit")
	assert_eq(str(db.tie_between("p103", "p200").soft.kind), "friend", "S's friend 60 holds against enmity 50")
	for m in [_d(2), _d(3), _d(4)]:
		assert_eq(_enm(gd, db, m, "p200"), 50, "%s mourns" % m)
	assert_eq(_enm(gd, db, _d(6), "p200"), 0, "S used a slot (with D2 to D5): D6 takes nothing")
	assert_eq(str(db.tie_between(_d(2), "p200").outside_cap), "p200", "mourner enmity sits outside K's cap")


func _news_of(db: WorldDB) -> Array:
	return db.all("events").filter(func(e): return str(e.type) == "tie_end").map(func(e): return [str(e.data.reason), str(e.data.news)])


func _mk3() -> WorldDB:
	var d := WorldDB.new()
	Ties.set_now(d, S)
	for id in ["p1", "p2", "p3"]:
		_person(d, id)
	return d


func test_every_end_writes_its_reason_and_news_kind_ac_nr_56() -> void:
	var gd := game_data()
	var db := _mk3()   # (h) betrayed, and the record lives on with the enmity
	db.get_record("people", "p2")["sect_rank"] = "truong_lao"
	Ties.add_pinned(gd, db, "p1", "p2", "ket_nghia", S)
	TieTick.enqueue(db, {"kind": "betrayal", "betrayer": "p2", "betrayed": "p1"})
	TieTick.run(gd, db, S)
	assert_true(_news_of(db).has(["betrayed", "betrayal"]), "(h) betrayed")
	db = _mk3()   # (i) repaid
	Ties.write_debt(gd, db, "p2", "p1", 60, S)
	TieTick.enqueue(db, {"kind": "repay", "debtor": "p2", "creditor": "p1"})
	TieTick.run(gd, db, S)
	assert_true(_news_of(db).has(["repaid", "debt_repaid"]), "(i) repaid")
	db = _mk3()   # (k) replaced: a deed enmity replaces a friend, hardening removes soft enmity
	Ties.write_soft(gd, db, "p1", "p2", "friend", 50, S)
	Ties.write_soft(gd, db, "p1", "p2", "enmity", 95, S, {"deed": true})
	TieTick.harden(gd, db, "p1", S)
	assert_eq(_news_of(db).filter(func(x): return x[0] == "replaced").size(), 2, "(k) replaced twice")
	db = _mk3()   # (f) faded on a record that lives on, (l) cancelled
	Ties.add_pinned(gd, db, "p1", "p2", "kin", S, true)
	Ties.write_soft(gd, db, "p1", "p2", "friend", 10, S)
	Ties.sweep(gd, db, "p1", S + 20)
	Ties.write_debt(gd, db, "p1", "p2", 30, S + 20)
	Ties.write_debt(gd, db, "p2", "p1", 30, S + 20)
	assert_true(_news_of(db).has(["faded", ""]) and _news_of(db).has(["cancelled", ""]), "(f) faded, (l) cancelled")
	db = _mk3()   # (m) the holder and the target die the same season: the target's reason
	Ties.set_feud(gd, db, "p1", "p2", S)
	for d in ["p1", "p2"]:
		db.get_record("people", d)["alive"] = false
		TieTick.enqueue(db, {"kind": "death", "dead": d, "cause": "old_age"})
	TieTick.run(gd, db, S)
	assert_eq(_news_of(db), [["target_died", "feud_end_natural"]], "(m) not holder_died")
	db = _mk3()   # (d) holder_died with no heir, (e) partner_died
	Ties.set_feud(gd, db, "p1", "p2", S)
	Ties.add_pinned(gd, db, "p1", "p3", "kin", S, true)
	db.get_record("people", "p1")["alive"] = false
	TieTick.enqueue(db, {"kind": "death", "dead": "p1", "cause": "old_age"})
	TieTick.run(gd, db, S)
	assert_true(_news_of(db).has(["holder_died", "feud_end_holder_died"]) and _news_of(db).has(["partner_died", ""]), "(d), (e)")


func test_the_master_row_carries_source_tie_and_goes_the_season_the_master_falls_behind_ac_nr_32() -> void:
	var gd := game_data()
	var db := WorldDB.new()
	Ties.set_now(db, S)
	_person(db, "p1", 900, {"realm_index": 1})
	_person(db, "p2")
	Ties.set_master(gd, db, "p2", "p1", S)
	for i in 3:
		TieTick.run(gd, db, S + i)
	var rows: Array = db.get_record("people", "p2").get("tie_rows", [])
	assert_eq(rows.size(), 1, "one row after 3 seasons")
	var c := Character.from_dict(db.get_record("people", "p2"))
	var sheet := StatSheet.build(c, gd, null, null)
	var tie_rows: Array = sheet.sources("cultivation_speed_pct").filter(func(m): return str(m.kind) == StatSheet.KIND_TIE)
	assert_eq(tie_rows.map(func(m): return float(m.value)), [5.0], "+5 with source tie")
	db.get_record("people", "p2")["realm_index"] = 1   # the disciple breaks through to the master's realm
	TieTick.run(gd, db, S + 3)
	assert_false(db.get_record("people", "p2").has("tie_rows"), "removed the same season")
