extends DaoTestSuite
## Provinces rule 9 for the player (provinces-runtime Stage 8): funding a province building through one's sect, and
## the query that lists what can be funded.


func _session_in_sect() -> GameSession:
	var gd := game_data()
	var llm := LlmService.new(gd)
	llm.enabled = false
	var s := GameSession.new(gd, llm, TestFixtures.tree())
	s.new_game(4242, {"mode": "roll", "name": "Thợ Đất", "gender": "male", "origin": "tan_tu"})
	s.pending_event = {}
	var sect: Dictionary = s.db.find("sects", func(x): return str(x.get("key", "")) == "thien_xu")[0]
	s.player.sect_id = str(sect.id)
	s.player.sect_rank = "ngoai_mon"
	s.sync_player()
	return s


func _first_order(s: GameSession) -> Array:
	for v in s.db.all(Provinces.TABLE):
		var n: int = str(v.id).substr(1).to_int()
		var orders: Array = GameQuery.province_orders(s, n)
		if not orders.is_empty():
			return [v, orders[0]]
	return []


func test_the_player_funds_a_building_for_their_sect() -> void:
	var s := _session_in_sect()
	var pick: Array = _first_order(s)
	assert_false(pick.is_empty(), "Thiên Xu has something to order somewhere")
	var v: Dictionary = pick[0]
	var o: Dictionary = pick[1]
	s.player.linh_thach = int(o.cost) + 100
	var before_c: int = s.sect_members.contribution(s.player.sect_id, s.player.id)
	var r: Dictionary = s.fund_building(str(v.id), str(o.kind))
	assert_true(bool(r.ok), "funded: %s" % str(r.lines))
	assert_eq(s.player.linh_thach, 100, "paid the level's price")
	var b: Array = Array(v.buildings).filter(func(x): return str(x.get("funded_by", "")) == s.player.id and str(x.kind) == str(o.kind))
	assert_eq(b.size(), 1, "the order is on the province, marked as the player's")
	assert_eq(str(b[0].state), "building", "building over its seasons")
	assert_true(s.sect_members.contribution(s.player.sect_id, s.player.id) > before_c, "it earns contribution")


func test_funding_is_refused_outside_the_sects_provinces_or_without_the_money() -> void:
	var s := _session_in_sect()
	var other: Dictionary = {}
	for v in s.db.all(Provinces.TABLE):
		if ProvinceBuildings.payer(s.db, v) != s.player.sect_id:
			other = v
			break
	assert_false(bool(s.fund_building(str(other.id), "road").ok), "not a province the sect pays for")
	var pick: Array = _first_order(s)
	s.player.linh_thach = 0
	var r: Dictionary = s.fund_building(str(pick[0].id), str(pick[1].kind))
	assert_false(bool(r.ok), "no money, no order")
	s.player.sect_id = ""
	assert_eq(GameQuery.province_orders(s, str(pick[0].id).substr(1).to_int()), [], "no sect: nothing to fund")
