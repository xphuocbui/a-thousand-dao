extends DaoTestSuite
## NPC Relationships' store against design/gdd/npc-relationships.md: the record (rules 1, 1a, 2), Formula A (tie value),
## Formula B (lazy fade), Formula C (strength changes), rule 10 (writing a strength), caps and eviction (rules 5-7),
## the notable gate (rule 6), the data checks and a save round trip. Season 100 unless a case says otherwise.

const S := 100


# FX-PAIR and friends: ordinary Luyện Khí people p1..p<n>, no traits, no sect; the clock at season 100.
func _db(n: int = 12) -> WorldDB:
	var db := WorldDB.new()
	for i in range(1, n + 1):
		db.put("people", {"id": "p%d" % i, "alive": true, "realm_index": 0, "sect_rank": "",
			"npc_traits": {"personality": [], "calling": "", "fate": [], "gained": []}})
	Ties.set_now(db, S)
	return db


func _soft(db: WorldDB, holder: String, other: String) -> Dictionary:
	var rec: Dictionary = db.tie_between(holder, other)
	return rec.get("soft", {})


func test_one_record_per_pair_holds_pinned_flags_a_soft_kind_and_a_debt_ac_nr_01() -> void:
	var gd := game_data()
	var db := _db()
	Ties.add_pinned(gd, db, "p2", "p1", "su_do", S, true)
	Ties.add_pinned(gd, db, "p1", "p2", "kin", S, true)
	Ties.write_soft(gd, db, "p1", "p2", "enmity", 40, S)
	Ties.write_debt(gd, db, "p1", "p2", 30, S)
	assert_eq(db.count("ties"), 1, "one record")
	var rec: Dictionary = db.tie_between("p1", "p2")
	assert_eq(Dictionary(rec.pin).keys().size(), 2, "flags sư đồ and kin")
	assert_eq(Ties.soft_s(Ties.cfg(gd), rec, "p1", S), 4000, "enmity 40")
	assert_eq([str(rec.debt.debtor), int(rec.debt.s)], ["p1", 3000], "debt 30 p1 -> p2")
	assert_eq([db.ties_of("p1").size(), db.ties_of("p2").size()], [1, 1], "each counts it once")


func test_one_living_master_and_one_living_dao_lu_and_companions_are_the_players_ac_nr_02_03() -> void:
	var gd := game_data()
	var db := _db()
	assert_true(bool(Ties.set_master(gd, db, "p1", "p2", S).ok), "a first master")
	assert_eq(str(db.get_record("people", "p1").master_id), "p2", "master_id written with the tie")
	assert_false(bool(Ties.set_master(gd, db, "p1", "p3", S).ok), "a second living master is refused")
	assert_true(bool(Ties.add_pinned(gd, db, "p4", "p5", "dao_lu", S, true).ok), "a first đạo lữ")
	assert_false(bool(Ties.add_pinned(gd, db, "p4", "p6", "dao_lu", S, true).ok), "a second living đạo lữ is refused")
	assert_false(bool(Ties.add_pinned(gd, db, "p7", "p8", "companion", S, true).ok), "a companion between two NPCs")


func test_tie_value_follows_formula_a_ac_nr_04() -> void:
	var gd := game_data()
	var db := _db()
	Ties.add_pinned(gd, db, "p1", "p2", "ket_nghia", S, true)
	Ties.write_soft(gd, db, "p1", "p2", "friend", 60, S)
	assert_near(Ties.tie_value(gd, db, "p1", "p2", S), 55.0, 1e-9, "kết nghĩa 40 + friend 25 x 0.6")
	db.tie_between("p1", "p2")["soft"] = {}
	assert_near(Ties.tie_value(gd, db, "p1", "p2", S), 40.0, 1e-9, "friend removed")
	Ties.add_pinned(gd, db, "p4", "p3", "su_do", S, true)
	Ties.add_pinned(gd, db, "p3", "p4", "kin", S, true)
	assert_near(Ties.tie_value(gd, db, "p3", "p4", S), 30.0, 1e-9, "kin and sư đồ count +30 once")
	Ties.write_soft(gd, db, "p5", "p6", "friend", 60, S)
	Ties.write_debt(gd, db, "p5", "p6", 60, S)
	assert_near(Ties.tie_value(gd, db, "p5", "p6", S), 33.0, 1e-9, "debtor: 15 + 18")
	assert_near(Ties.tie_value(gd, db, "p6", "p5", S), 21.0, 1e-9, "creditor: 15 + 6")


func test_feuds_and_the_range_of_formula_a_ac_nr_05() -> void:
	var gd := game_data()
	var db := _db()
	Ties.add_pinned(gd, db, "p1", "p2", "kin", S, true)
	Ties.set_feud(gd, db, "p2", "p1", S)
	assert_near(Ties.tie_value(gd, db, "p2", "p1", S), -30.0, 1e-9, "kin 30 - feud 60")
	assert_near(Ties.tie_value(gd, db, "p1", "p2", S), 30.0, 1e-9, "the target feels nothing from it")
	Ties.write_soft(gd, db, "p3", "p4", "rival", 100, S)
	Ties.set_feud(gd, db, "p3", "p4", S)
	Ties.write_soft(gd, db, "p3", "p4", "rival", 100, S)
	assert_near(Ties.tie_value(gd, db, "p3", "p4", S), -70.0, 1e-9, "a feud plus a full rivalry")
	Ties.add_pinned(gd, db, "p5", "p6", "dao_lu", S, true)
	Ties.write_soft(gd, db, "p5", "p6", "friend", 100, S)
	Ties.write_debt(gd, db, "p5", "p6", 100, S)
	assert_near(Ties.tie_value(gd, db, "p5", "p6", S), 105.0, 1e-9, "đạo lữ, full friend, full debt as debtor")
	Ties.set_feud(gd, db, "p7", "p8", S)
	assert_false(bool(Ties.write_soft(gd, db, "p7", "p8", "enmity", 40, S, {"deed": true}).ok), "the feud carries it")
	assert_near(Ties.tie_value(gd, db, "p7", "p8", S), -60.0, 1e-9, "no soft enmity is stored")


func test_a_grudge_and_enmity_toward_one_person_are_one_term_ac_nr_06() -> void:
	var gd := game_data()
	var db := _db()
	db.get_record("people", "p1").npc_traits.gained = [{"id": "grudge", "expires": 9999, "target": "p2"}]
	Ties.write_soft(gd, db, "p1", "p2", "enmity", 80, S)
	var a: Dictionary = db.get_record("people", "p1")
	var b: Dictionary = db.get_record("people", "p2")
	assert_near(NpcTraits.opinion(gd, db, a, b), -50.0, 1e-9, "the more negative of -50 and -40")
	Ties.write_soft(gd, db, "p1", "p2", "enmity", 20, S)
	assert_near(NpcTraits.opinion(gd, db, a, b), -50.0, 1e-9, "enmity 100: min(-50, -50)")
	Ties.set_feud(gd, db, "p1", "p2", S)
	assert_near(NpcTraits.opinion(gd, db, a, b), -60.0, 1e-9, "hardened: min(-50, -60)")


func test_strengths_fade_lazily_and_a_faded_part_is_swept_when_touched_ac_nr_08() -> void:
	var gd := game_data()
	var db := _db()
	Ties.write_soft(gd, db, "p1", "p2", "friend", 70, S)
	var c: Dictionary = Ties.cfg(gd)
	var rec: Dictionary = db.tie_between("p1", "p2")
	assert_eq([int(ceil(Ties.soft_s(c, rec, "p1", 148) / 100.0)), int(ceil(Ties.soft_s(c, rec, "p1", 169) / 100.0)),
		Ties.soft_s(c, rec, "p1", 170)], [22, 1, 0], "22 at 148, 1 at 169, 0 at 170")
	assert_eq(db.count("ties"), 1, "still stored until touched")
	Ties.sweep(gd, db, "p1", 170)
	assert_eq(db.count("ties"), 0, "swept with nothing else on it")


func test_a_future_set_season_reads_as_stored_and_bad_data_is_rejected_ac_nr_09() -> void:
	var gd := game_data()
	var c: Dictionary = Ties.cfg(gd)
	assert_eq(Ties.s_now(c, "friend", {"s": 5000, "set": 120}, 100), 5000, "no increase, no error")
	assert_eq(Ties.validate(c), [], "the shipped data passes")
	var bad: Dictionary = c.duplicate(true)
	bad.rate.enmity = 0
	assert_eq(Ties.validate(bad).size(), 1, "a fade rate of 0 is rejected")
	var bad2: Dictionary = c.duplicate(true)
	bad2.soft_reserve.ordinary = int(c.cap_ordinary) + 1
	assert_eq(Ties.validate(bad2).size(), 1, "a reserve above its cap is rejected")


func test_strength_changes_follow_formula_c_ac_nr_10_44() -> void:
	var gd := game_data()
	var db := _db()
	var c: Dictionary = Ties.cfg(gd)
	Ties.write_debt(gd, db, "p1", "p2", 30, S)
	Ties.write_debt(gd, db, "p1", "p2", 60, S + 2)
	var rec: Dictionary = db.tie_between("p1", "p2")
	assert_eq(Ties.debt_s(c, rec, S + 2), 8950, "30 faded 0.5 in 2 seasons, then a rescue: 89.5")
	assert_eq(int(rec.debt.set), S + 2, "its set season is now")
	Ties.write_soft(gd, db, "p3", "p4", "friend", 50, S)
	Ties.write_soft(gd, db, "p3", "p4", "friend", 20, S)
	assert_eq(Ties.soft_s(c, db.tie_between("p3", "p4"), "p3", S), 7000, "50 + 20")
	Ties.write_soft(gd, db, "p3", "p4", "friend", -100, S)
	assert_true(db.tie_between("p3", "p4").is_empty(), "removed at once")
	Ties.write_soft(gd, db, "p5", "p6", "enmity", 60, S)
	for i in range(1, 21):
		Ties.write_soft(gd, db, "p5", "p6", "enmity", 1, S + i)
	assert_eq(Ties.soft_s(c, db.tie_between("p5", "p6"), "p5", S + 20), 7000, "60 + 20 - 20 x 0.5: no fade lost")
	Ties.write_soft(gd, db, "p7", "p8", "friend", -10, S)
	assert_true(db.tie_between("p7", "p8").is_empty(), "a negative change on nothing makes nothing")


func test_another_soft_kind_replaces_only_a_weaker_one_and_a_debt_sits_beside_it_ac_nr_11() -> void:
	var gd := game_data()
	var db := _db()
	var c: Dictionary = Ties.cfg(gd)
	Ties.write_soft(gd, db, "p1", "p2", "enmity", 80, S)
	Ties.write_soft(gd, db, "p1", "p2", "rival", 30, S)
	assert_eq(str(_soft(db, "p1", "p2").kind), "enmity", "enmity 80 stays")
	Ties.write_soft(gd, db, "p3", "p4", "enmity", 20, S)
	Ties.write_soft(gd, db, "p3", "p4", "rival", 30, S)
	assert_eq([str(_soft(db, "p3", "p4").kind), Ties.soft_s(c, db.tie_between("p3", "p4"), "p3", S)], ["rival", 3000], "rival 30 replaces 20")
	Ties.write_debt(gd, db, "p2", "p1", 60, S)
	var rec: Dictionary = db.tie_between("p1", "p2")
	assert_eq([str(rec.soft.kind), Ties.debt_s(c, rec, S)], ["enmity", 6000], "enmity 80 and the debt 60")


func test_debts_the_other_way_are_netted_ac_nr_45() -> void:
	var gd := game_data()
	var db := _db()
	var c: Dictionary = Ties.cfg(gd)
	Ties.write_debt(gd, db, "p1", "p2", 60, S)
	Ties.write_debt(gd, db, "p2", "p1", 40, S)
	var rec: Dictionary = db.tie_between("p1", "p2")
	assert_eq([str(rec.debt.debtor), Ties.debt_s(c, rec, S)], ["p1", 2000], "p1 owes 20")
	Ties.write_debt(gd, db, "p2", "p1", 20, S)
	assert_true(db.tie_between("p1", "p2").is_empty(), "netted to 0: removed")


func test_eviction_takes_the_weakest_then_the_older_ac_nr_12() -> void:
	var gd := game_data()
	var db := _db()
	Ties.add_pinned(gd, db, "p1", "p9", "kin", S, true)
	Ties.add_pinned(gd, db, "p1", "p10", "kin", S, true)
	Ties.write_soft(gd, db, "p1", "p2", "friend", 10, S)
	Ties.write_soft(gd, db, "p1", "p3", "friend", 30, S - 10)   # reads 20 at season 100
	Ties.write_soft(gd, db, "p1", "p4", "friend", 20, S)
	Ties.write_soft(gd, db, "p1", "p5", "friend", 50, S)
	assert_eq(db.ties_of("p1").size(), 6, "at the cap")
	Ties.write_soft(gd, db, "p1", "p6", "friend", 30, S)
	assert_true(db.tie_between("p1", "p2").is_empty(), "the weakest (10) goes")
	assert_eq(db.ties_of("p2").size(), 0, "its partner's count falls")
	Ties.write_soft(gd, db, "p1", "p7", "friend", 30, S)
	assert_true(db.tie_between("p1", "p3").is_empty(), "equal 20s: the older set season goes")
	assert_false(db.tie_between("p1", "p4").is_empty(), "the newer 20 stays")


func test_the_soft_reserve_lets_a_full_pinned_person_hold_soft_ties_ac_nr_13() -> void:
	var gd := game_data()
	var db := _db(16)
	for i in range(2, 8):
		Ties.add_pinned(gd, db, "p1", "p%d" % i, "kin", S, true)
	Ties.write_soft(gd, db, "p1", "p8", "friend", 20, S)
	assert_eq(db.ties_of("p1").size(), 7, "soft_reserve 2: forms")
	Ties.write_soft(gd, db, "p1", "p9", "friend", 25, S)
	assert_eq(db.ties_of("p1").size(), 8, "a second")
	Ties.write_soft(gd, db, "p1", "p10", "friend", 40, S)
	assert_eq(db.ties_of("p1").size(), 8, "a stronger third evicts the weaker reserve tie")
	assert_true(db.tie_between("p1", "p8").is_empty(), "the 20 went")
	Ties.add_pinned(gd, db, "p1", "p11", "kin", S, true)
	assert_eq(db.ties_of("p1").size(), 9, "a pinned tie always forms")


func test_ket_nghia_and_dao_lu_need_a_notable_person_ac_nr_15() -> void:
	var gd := game_data()
	var db := _db()
	assert_false(bool(Ties.add_pinned(gd, db, "p1", "p2", "ket_nghia", S).ok), "two ordinary people")
	db.get_record("people", "p2")["sect_rank"] = "truong_lao"
	assert_true(bool(Ties.add_pinned(gd, db, "p1", "p2", "ket_nghia", S).ok), "an elder is notable")


func test_a_soft_part_on_a_pinned_record_is_never_evicted_and_room_needs_a_strictly_weaker_one_ac_nr_42() -> void:
	var gd := game_data()
	var db := _db(20)
	Ties.add_pinned(gd, db, "p1", "p2", "kin", S, true)
	Ties.write_soft(gd, db, "p1", "p2", "friend", 5, S)
	Ties.add_pinned(gd, db, "p1", "p3", "kin", S, true)
	for x in [["p4", 15], ["p5", 40], ["p6", 40], ["p7", 40]]:
		Ties.write_soft(gd, db, "p1", str(x[0]), "friend", int(x[1]), S)
	Ties.write_soft(gd, db, "p1", "p8", "friend", 30, S)
	assert_true(db.tie_between("p1", "p4").is_empty(), "the 15 goes")
	assert_eq(Ties.soft_s(Ties.cfg(gd), db.tie_between("p1", "p2"), "p1", S), 500, "the pinned record keeps its 5")
	for i in range(10, 16):   # p9 at its soft-only limit, every one at 30 or more
		Ties.write_soft(gd, db, "p9", "p%d" % i, "friend", 30, S)
	var before: int = db.count("ties")
	var r := Ties.write_soft(gd, db, "p1", "p9", "friend", 30, S)
	assert_false(bool(r.ok), "30 is not strictly weaker than 30")
	assert_eq(db.count("ties"), before, "nothing changes on either side")


func test_ties_survive_a_save_and_load_ac_nr_29() -> void:
	var gd := game_data()
	var db := _db()
	Ties.set_master(gd, db, "p1", "p2", S)
	Ties.write_soft(gd, db, "p3", "p4", "enmity", 70, S, {"cause": {"kind": "event", "event": "e9"}})
	Ties.write_soft(gd, db, "p4", "p3", "enmity", 30, S)
	Ties.write_debt(gd, db, "p5", "p6", 40, S)
	var back := WorldDB.from_dict(JSON.parse_string(JSON.stringify(db.to_dict())))
	assert_eq(back.ties_of("p3").size(), 1, "the index is rebuilt after a load")
	var want: String = JSON.stringify(JSON.parse_string(JSON.stringify(db.tie_between("p3", "p4"))))   # JSON numbers load as floats
	assert_eq(JSON.stringify(back.tie_between("p3", "p4")), want, "per-direction enmity with causes")
	assert_eq(Ties.soft_s(Ties.cfg(gd), back.tie_between("p3", "p4"), "p4", S), 3000, "the other direction reads after a load")
	assert_eq(Ties.master_of(back, "p1"), "p2", "sư đồ")
	assert_eq(Ties.now(back), S, "the clock")


func test_an_older_save_with_masters_only_in_master_id_gets_its_su_do_records() -> void:
	var gd := game_data()
	var db := WorldDB.new()
	db.put("people", {"id": "p1", "alive": true, "realm_index": 1})
	db.put("people", {"id": "p2", "alive": true, "realm_index": 0, "master_id": "p1"})
	assert_eq(Ties.migrate(gd, db, 400), 1, "one record written")
	assert_eq(Ties.master_of(db, "p2"), "p1", "the master by the store")
	assert_eq(Ties.now(db), 400, "the clock from the save's season")
	assert_eq(Ties.migrate(gd, db, 400), 0, "once")

