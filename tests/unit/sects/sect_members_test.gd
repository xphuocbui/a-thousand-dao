extends DaoTestSuite
## Sects & Missions, the member's side (design/gdd/sects.md rules 19-22, 25; Formulas F10, F12, F13): standing,
## contribution, joining, promotion, leaving and desertion, and a sect mission's contribution and standing.


func _setup() -> Array:
	var gd := game_data()
	var db := WorldDB.new()
	var sm := SectMembers.new(gd, db)
	db.put("places", {"id": "l1", "name": "Seat", "region_id": "r1", "sect_id": "s1"})
	db.put("places", {"id": "l2", "name": "Town", "region_id": "r1", "sect_id": ""})
	var sect := {"id": "s1", "name": "Thanh Vân Tông", "hq_place_id": "l1", "region_id": "r1", "members": [], "status": "active"}
	db.put("sects", sect)
	var c := TestFixtures.character({"hoa": 50}, 50, 0, 0)
	c.id = "p1"
	c.location_id = "l1"
	return [gd, db, sm, sect, c]


func test_a_gain_is_smoothed_and_a_fall_is_full_f10() -> void:
	assert_near(SectMembers.standing_step(50.0, 3.0), 1.5, 1e-9, "the GDD example: +1.5 at St 50")
	assert_near(SectMembers.standing_step(0.0, 3.0), 3.0, 1e-9, "full gain at 0")
	assert_near(SectMembers.standing_step(-20.0, 3.0), 3.0, 1e-9, "a gain below 0 is taken in full")
	assert_near(SectMembers.standing_step(50.0, -5.0), -5.0, 1e-9, "a fall is taken in full")
	assert_near(SectMembers.standing_step(-98.0, -5.0), -2.0, 1e-9, "never below -100")
	assert_true(50.0 + SectMembers.standing_step(99.9, 3.0) <= 100.0, "and never above 100")


func test_a_loose_cultivator_joins_at_the_seat_when_the_sect_will_take_them_rule_20() -> void:
	var t: Array = _setup()
	var sm: SectMembers = t[2]
	var c: Character = t[4]
	assert_true(bool(sm.can_join(c, t[3]).ok), "at the seat, standing 0 against recruit line 0: %s" % str(sm.can_join(c, t[3]).reasons))
	c.location_id = "l2"
	assert_false(bool(sm.can_join(c, t[3]).ok), "only at its seat")
	c.location_id = "l1"
	sm.change_standing("s1", "p1", -10.0)
	assert_false(bool(sm.can_join(c, t[3]).ok), "standing below the recruit line refuses")
	sm.change_standing("s1", "p1", 10.0)
	sm.join(c, t[3])
	assert_eq([c.sect_id, c.sect_rank], ["s1", "ngoai_mon"], "joins as an outer disciple")
	assert_true((t[3].members as Array).has("p1"), "on the member list")
	assert_false(bool(sm.can_join(c, t[3]).ok), "a member cannot join again")


func test_promotion_needs_the_realm_the_contribution_and_the_standing_f13() -> void:
	var t: Array = _setup()
	var sm: SectMembers = t[2]
	var c: Character = t[4]
	sm.join(c, t[3])
	var r: Dictionary = sm.promote(c)
	assert_false(bool(r.ok), "Luyện Khí with no contribution")
	assert_true(str(r.lines).contains("realm") and str(r.lines).contains("contribution 0 of 400"), "says what is missing: %s" % str(r.lines))
	c.realm_index = 1
	sm.record("s1", "p1")["contribution"] = 450
	r = sm.promote(c)
	assert_true(bool(r.ok), "Trúc Cơ, 450 contribution, standing 0: inner disciple")
	assert_eq(c.sect_rank, "noi_mon", "inner disciple")
	assert_eq(sm.contribution("s1", "p1"), 50, "400 spent")
	c.realm_index = 2
	sm.record("s1", "p1")["contribution"] = 3000
	assert_false(bool(sm.promote(c).ok), "elder also needs standing 40")
	sm.record("s1", "p1")["standing"] = 40.0
	assert_true(bool(sm.promote(c).ok), "then elder")
	var head: Dictionary = sm.promotion_needs(c)
	assert_eq(head.rank, "tong_chu", "next is the head seat")
	assert_true(str(head.missing).contains("not reached by promotion"), "which promotion never reaches (rule 28)")


func test_desertion_falls_forty_and_caps_at_minus_thirty_hostile_rule_22() -> void:
	var t: Array = _setup()
	var sm: SectMembers = t[2]
	var c: Character = t[4]
	sm.join(c, t[3])
	sm.record("s1", "p1")["standing"] = 20.0
	var r: Dictionary = sm.leave(c, true)
	assert_true(bool(r.ok), "deserted")
	assert_near(sm.standing("s1", "p1"), -30.0, 1e-9, "20 - 40 = -20, then at most -30")
	assert_true(sm.hostile("s1", "p1"), "hostile at the threshold")
	assert_eq(c.sect_id, "", "no longer a member")
	assert_false((t[3].members as Array).has("p1"), "off the member list")
	assert_false(bool(sm.can_join(c, t[3]).ok), "a hostile sect will not take them back")


func test_leaving_on_good_terms_keeps_standing() -> void:
	var t: Array = _setup()
	var sm: SectMembers = t[2]
	var c: Character = t[4]
	sm.join(c, t[3])
	sm.record("s1", "p1")["standing"] = 25.0
	sm.leave(c, false)
	assert_near(sm.standing("s1", "p1"), 25.0, 1e-9, "no fall")
	assert_eq(c.sect_id, "", "left")


func test_a_sect_mission_pays_contribution_and_standing_f12_f10() -> void:
	var t: Array = _setup()
	var sm: SectMembers = t[2]
	var c: Character = t[4]
	sm.join(c, t[3])
	var r: Dictionary = sm.mission_reward(c, 936)
	assert_eq(int(r.contribution), 234, "the GDD's example: 936 cash earns 234 contribution (c_share 0.25)")
	assert_near(float(r.standing), 3.0, 1e-9, "+3 standing at 0")
	sm.mission_reward(c, 10)
	assert_eq(sm.contribution("s1", "p1"), 234 + 3, "round(0.25 x 10) = 3 more")


func test_in_a_session_a_member_earns_contribution_on_sect_missions() -> void:
	var gd := game_data()
	var llm := LlmService.new(gd)
	llm.enabled = false
	var s := GameSession.new(gd, llm, TestFixtures.tree())
	s.new_game(91, {"mode": "roll", "name": "Đệ Tử", "gender": "male", "origin": "tan_tu"})
	var sect: Dictionary = s.db.find("sects", func(x): return x.status == "active")[0]
	s.player.location_id = sect.hq_place_id
	var j: Dictionary = s.join_sect()
	assert_true(bool(j.ok), "joined: %s" % str(j.lines))
	s.pending_event = {}
	var m: Dictionary = s.mission()
	assert_true(bool(m.ok), "mission ran: %s" % str(m.lines))
	assert_true(str(m.lines).contains("contribution"), "the result names the contribution: %s" % str(m.lines))
	assert_true(s.sect_members.contribution(sect.id, s.player.id) > 0, "contribution earned")
	assert_true(s.sect_members.standing(sect.id, s.player.id) > 0.0, "standing rose")
	var st: Dictionary = s.sect_status()
	assert_true(str(st.lines).contains(str(sect.name)), "the status names the sect: %s" % str(st.lines))


func test_the_advisor_points_to_joining_and_to_a_promotion() -> void:
	var gd := game_data()
	var llm := LlmService.new(gd)
	llm.enabled = false
	var s := GameSession.new(gd, llm, TestFixtures.tree())
	s.new_game(92, {"mode": "roll", "name": "Đệ Tử", "gender": "male", "origin": "tan_tu"})
	var sect: Dictionary = s.db.find("sects", func(x): return x.status == "active")[0]
	s.player.location_id = sect.hq_place_id
	var ids: Array = Advisor.goals(s).map(func(g): return str(g.id))
	assert_true(ids.has("sect_join"), "a sect seated here suggests joining: %s" % str(ids))
	s.join_sect()
	assert_false(Advisor.goals(s).map(func(g): return str(g.id)).has("sect_join"), "not once a member")
	s.player.realm_index = 1
	s.sect_members.record(sect.id, s.player.id)["contribution"] = 400
	var g: Array = Advisor.goals(s).filter(func(x): return str(x.id) == "sect_promote")
	assert_eq(g.size(), 1, "a met gate suggests promotion")
	assert_eq(str(g[0].command), "promote", "with the command")


func test_the_player_is_never_made_head_by_succession_rule_28() -> void:
	# Regression (night 2026-11-15): with promotion the player can be the strongest elder, and the world tick's
	# succession picked them as head with no choice of theirs. Rule 28: the player stands for an open seat by choice.
	var gd := game_data()
	var db := WorldDB.new()
	db.put("sects", {"id": "s1", "name": "Thanh Vân Tông", "leader_id": "p1", "members": ["p1", "p2", "p3"], "status": "active"})
	db.put("people", {"id": "p1", "alive": false, "sect_id": "s1", "sect_rank": "tong_chu", "realm_index": 3, "stage": 0})
	db.put("people", {"id": "p2", "alive": true, "sect_id": "s1", "sect_rank": "truong_lao", "realm_index": 3, "stage": 3, "is_player": true})
	db.put("people", {"id": "p3", "alive": true, "sect_id": "s1", "sect_rank": "truong_lao", "realm_index": 2, "stage": 0})
	assert_eq(Inheritance.sect_successor(db, gd, db.get_record("people", "p1")), "p3", "the NPC elder, though the player is stronger")
	db.get_record("people", "p3")["alive"] = false
	assert_eq(Inheritance.sect_successor(db, gd, db.get_record("people", "p1")), "", "no NPC left: no successor, never the player")
