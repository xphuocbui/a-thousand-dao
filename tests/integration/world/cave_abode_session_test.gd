extends DaoTestSuite
## Cave Abode through GameSession (design/gdd/cave-abode.md): the starting residence, opening an abode, the slot
## refusal, raising a grade (next season), burn_abode in the books (AC-CA-16), a save round trip, leaving for a new
## abode, reclaiming the old one (rule 11), a sect member housed by the sect, and loose NPCs' one aggregate burn.


func _session(origin: String = "tan_tu") -> GameSession:
	var gd := game_data()
	var llm := LlmService.new(gd)
	llm.enabled = false
	var s := GameSession.new(gd, llm, TestFixtures.tree())
	s.new_game(4242, {"mode": "roll", "name": "Thợ Đất", "gender": "male", "origin": origin})
	s.pending_event = {}
	return s


func _open_near(s: GameSession, dy: int) -> Dictionary:
	var here: Dictionary = s.db.get_record("places", s.player.location_id)
	var tg := TravelGrid.of(s.gd)
	for dx in range(2, 14):
		var t := Vector2i(int(here.tile[0]) + dx, int(here.tile[1]) + dy)
		if tg.passable(t) and s.db.find("places", func(p): return p.has("tile") and int(p.tile[0]) == t.x and int(p.tile[1]) == t.y).is_empty():
			return s.open_abode(t.x, t.y)
	return {"ok": false, "lines": ["no open land"]}


func _give(s: GameSession, material_id: String, qty: int) -> void:
	var m: Dictionary = s.items.material(material_id, qty)
	m["owner_id"] = s.player.id
	s.db.add("items", m)


func _abode_burned(s: GameSession) -> float:
	return float(MoneyLedger.new(s.db).books().get("burned", {}).get("abode", 0.0))


func test_a_life_at_the_abode_from_the_starting_room_to_a_reclaim() -> void:
	var s := _session()
	var start: Dictionary = s.db.get_record("places", s.player.home_id)
	var rec0: Dictionary = CaveAbode.home_rec(start.qi, s.player.id)
	assert_eq([int(rec0.get("grade", 0)), bool(rec0.get("origin", false))], [1, true], "a free grade-1 starting residence")
	s.player.linh_thach = 100000
	assert_true(bool(_open_near(s, 0).ok), "an abode opened")
	assert_false(start.qi.get("residences", {}).has(s.player.id), "the starting room is given up")
	var home: Dictionary = s.db.get_record("places", s.player.home_id)
	assert_eq(CaveAbode.grade_of(home.qi.abode), 1, "a new abode is grade 1")
	s.player.location_id = s.player.home_id
	_give(s, "huyen_hoang_thach", 10)
	assert_true(bool(s.formation_build("tu_linh").ok), "Tu Linh: slot 1")
	assert_true(bool(s.formation_build("ho_son").ok), "Ho Son: slot 2")
	var third: Dictionary = s.formation_build("thanh_moc")
	assert_false(bool(third.ok), "a third array has no slot at grade 1")
	assert_true(" ".join(PackedStringArray(third.lines)).contains("slot"), "refused for the slot: %s" % str(third.lines))
	var cost: int = CaveAbode.grade_cost(s.gd, 2, s.player.realm_index)
	var burned0: float = _abode_burned(s)   # this season's books also hold the loose NPCs' aggregate
	var r: Dictionary = CaveAbode.raise(s.gd, s.db, s.player, home.qi)
	assert_true(bool(r.ok), "raise to grade 2: %s" % str(r.lines))
	if s.db.count(WorldEconomy.TABLE) > 0:
		assert_eq(_abode_burned(s) - burned0, float(cost), "the raise is booked as burn_abode")
	assert_eq(CaveAbode.grade_of(home.qi.abode), 1, "the old grade holds this season")
	s.cultivate(1)
	s.pending_event = {}   # a world event may land in the season (it depends on how the world played); this test is about the abode
	assert_eq(CaveAbode.grade_of(home.qi.abode), 2, "grade 2 from the next season")
	assert_true(bool(s.formation_build("thanh_moc").ok), "the third slot")
	s.sync_player()
	var d: Dictionary = JSON.parse_string(JSON.stringify(s.to_dict()))
	var t := GameSession.new(s.gd, s.llm, TestFixtures.tree())
	assert_true(bool(t.load_dict(d).ok), "loaded")
	var th: Dictionary = t.db.get_record("places", t.player.home_id)
	assert_eq([CaveAbode.grade_of(th.qi.abode), CaveAbode.used(th.qi, t.player)], [2, 3], "grade and works survive a save")
	var old_id: String = str(t.player.home_id)
	t.player.linh_thach = 100000
	assert_true(bool(_open_near(t, 2).ok), "a second abode opened")
	var old: Dictionary = t.db.get_record("places", old_id)
	assert_eq([str(old.qi.abode.state), CaveAbode.grade_of(old.qi.abode)], ["left", 2], "the old abode is Left at grade 2")
	assert_eq(t.player.formations, {}, "the arrays stayed behind")
	t.player.location_id = old_id
	var fee: int = CaveAbode.claim_fee(t.gd, t.player.realm_index)
	var before: int = t.player.linh_thach
	var c: Dictionary = t.claim_abode()
	assert_true(bool(c.ok), "its old owner reclaims it: %s" % str(c.lines))
	assert_eq(t.player.home_id, old_id, "home again")
	assert_eq(CaveAbode.grade_of(old.qi.abode), 1, "at grade 2 - 1")
	assert_true(before - t.player.linh_thach >= fee, "the fee was paid")


func test_a_sect_member_is_housed_by_the_sect_not_a_starting_room() -> void:
	var s := _session("tong_mon")
	if s.player.sect_id == "":
		return
	var seat: Dictionary = s.db.get_record("places", s.player.home_id)
	var rec: Dictionary = seat.get("qi", {}).get("residences", {}).get(s.player.id, {})
	assert_true(bool(rec.get("sect", false)), "a sect residence: %s" % str(rec))
	assert_false(rec.has("origin"), "not a starting room")


func test_loose_npcs_abode_payments_are_one_burn_abode_aggregate_ac_ca_16() -> void:
	var s := _session()
	if s.db.count(WorldEconomy.TABLE) == 0:
		return
	var loose: Array = s.db.living().filter(func(p): return not bool(p.get("is_player", false)) and not bool(p.get("is_beast", false)) and str(p.get("sect_id", "")) == "")
	assert_false(loose.is_empty(), "loose cultivators exist")
	var money := MoneyLedger.new(s.db)
	money.open_season()
	var paid: float = CaveAbode.npc_season(s.gd, s.db, money, "t", 3)
	assert_true(paid > 0.0, "some paid")
	assert_near(float(money.books().burned.get("abode", 0.0)), paid, 1e-6, "booked as one burn_abode")
	assert_near(float(money.season_check().gap), 0.0, 1e-3, "the books close (AC-RE-07)")


func test_a_lost_lease_leaves_a_plain_grade_1_room_so_the_limits_still_hold() -> void:
	var s := _session()
	var home: Dictionary = s.db.get_record("places", s.player.home_id)
	home.qi.residences[s.player.id] = {"grade": 3, "own": false, "rent": 50, "order": ["f:tu_linh", "f:ho_son", "f:thanh_moc"], "dormant": []}
	s.player.formations = {"tu_linh": 1, "ho_son": 1, "thanh_moc": 1}
	s.player.linh_thach = 0
	var lines: Array = s._bill_residence()
	var rec: Dictionary = CaveAbode.home_rec(home.qi, s.player.id)
	assert_eq([int(rec.get("grade", 0)), int(rec.get("rent", -1))], [1, 0], "a free grade-1 room: %s" % str(lines))
	assert_eq(Array(rec.dormant), ["f:thanh_moc"], "the latest built goes dormant at 2 slots")
	assert_false(bool(CaveAbode.can_raise(s.gd, home.qi, s.player, "w:tended_abode", 1, 5).ok), "no slot for a new work")


func test_burn_abode_takes_the_raise_the_upkeep_and_the_claim_and_never_the_arrays_ac_ca_16() -> void:
	var s := _session()
	if s.db.count(WorldEconomy.TABLE) == 0:
		return
	s.player.linh_thach = 100000
	assert_true(bool(_open_near(s, 0).ok), "an abode")
	var p: Character = s.player
	p.realm_index = 2
	p.linh_can.elements.erase("tho")
	p.linh_can.variants.erase("tho")
	p.formations = {"ho_son": 1}
	var home: Dictionary = s.db.get_record("places", p.home_id)
	home.qi.abode["grade"] = 2
	var money := MoneyLedger.new(s.db)
	money.open_season()
	CaveAbode.raise(s.gd, s.db, p, home.qi)
	CaveAbode.season(s.gd, s.db, p, home.qi)
	s.formations.pay_upkeep(p)
	var b: Dictionary = MoneyLedger.new(s.db).books()
	assert_eq(float(b.burned.get("abode", 0.0)), 3755.0, "season N: the raise 3,750 and grade 2's upkeep 5")
	assert_true(float(b.burned.get("formation", 0.0)) > 0.0, "the array's upkeep is burn_formation")
	assert_near(float(b.player_net), -(3755.0 + float(b.burned.formation)), 1e-6, "both are the player's purchases")
	assert_near(float(MoneyLedger.new(s.db).season_check().gap), 0.0, 1e-6, "M is unchanged by the player's share")
	money.open_season()
	CaveAbode.season(s.gd, s.db, p, home.qi)
	assert_eq(float(MoneyLedger.new(s.db).books().burned.get("abode", 0.0)), 13.0, "season N+1: grade 3's upkeep 12.5 -> 13")
	var other: Dictionary = {"id": "lx", "name": "old", "owner_id": "p_other", "qi": {"layer1": {}, "abode": {"owner": "p_other", "grade": 2, "unpaid": 0, "pending": 0, "state": "left", "order": [], "dormant": []}}}
	money.open_season()
	CaveAbode.claim(s.gd, s.db, p, other)
	CaveAbode.season(s.gd, s.db, p, other.qi)
	assert_eq(float(MoneyLedger.new(s.db).books().burned.get("abode", 0.0)), 125.0, "the claim season: the fee 125, no upkeep")


func test_a_dead_hermit_at_grade_3_leaves_a_capped_claimable_ruin_rule_12() -> void:
	var s := _session()
	var loose: Array = s.db.living().filter(func(p): return not bool(p.get("is_player", false)) and not bool(p.get("is_beast", false)) and str(p.get("sect_id", "")) == "" and s.db.get_record("places", str(p.get("location_id", ""))).has("tile"))
	assert_true(loose.size() >= 3, "loose cultivators on the map")
	var low: Dictionary = loose[2]
	low["abode_grade"] = 2
	for i in 2:
		loose[i]["abode_grade"] = 3
	CaveAbode.npc_ruins(s.gd, s.db, 10)
	var tracked: Dictionary = s.db.get_record("world", "w_abode_npcs").tracked
	assert_true(tracked.has(str(loose[0].id)) and not tracked.has(str(low.id)), "grade 3+ tracked, grade 2 not")
	var places0: int = s.db.count("places")
	loose[0]["alive"] = false
	low["alive"] = false
	var made: Array = CaveAbode.npc_ruins(s.gd, s.db, 11)
	assert_eq(made.size(), 1, "one Ruin, for the grade-3 hermit only")
	var ruin: Dictionary = s.db.get_record("places", str(made[0]))
	assert_eq([str(ruin.qi.abode.state), CaveAbode.grade_of(ruin.qi.abode)], ["ruin", 3], "a Ruin at its grade")
	assert_true(CaveAbode.claimable(ruin, s.player), "anyone may claim it")
	var cfg: Dictionary = s.gd.file(CaveAbode.FILE)
	var cap0 = cfg.get("ruin_cap", 40)
	cfg["ruin_cap"] = 1
	loose[1]["alive"] = false
	var made2: Array = CaveAbode.npc_ruins(s.gd, s.db, 12)
	cfg["ruin_cap"] = cap0
	assert_eq(made2, made, "at the cap the oldest Ruin is reused")
	assert_eq(s.db.count("places"), places0 + 1, "the places table stays bounded")
	assert_true(str(s.db.get_record("places", str(made[0])).name).contains(str(loose[1].name)), "now the newer hermit's")
