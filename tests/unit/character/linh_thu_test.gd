extends DaoTestSuite
## Linh thú: taming, the beast's share of chiến lực, following the owner, feeding and
## loyalty (design/quick-specs/phu-luc-linh-thu-thanh-tuu.md).


func _session() -> GameSession:
	var gd := game_data()
	var llm := LlmService.new(gd)
	llm.enabled = false
	var s := GameSession.new(gd, llm, TestFixtures.tree())
	s.new_game(4242, {"mode": "roll", "name": "Ngự", "gender": "male", "origin": "tan_tu"})
	s.pending_event = {}
	return s


func _beast(s: GameSession) -> String:
	return s.builds.create_person(s.rng, {"realm_index": 0, "stage": 5, "is_beast": true, "location_id": s.player.location_id})


func test_tame_chance_grows_with_than_hon() -> void:
	var s := _session()
	var bid: String = _beast(s)
	var low: float = s.beasts.tame_chance(s.player, s.sheet(), bid).total
	s.player.thien_phu["than_hon"] = 95
	var high: float = s.beasts.tame_chance(s.player, s.sheet(), bid).total
	assert_true(high > low, "Thần hồn helps: %.2f -> %.2f" % [low, high])


func test_a_tamed_beast_adds_to_chien_luc_and_follows_its_owner() -> void:
	var s := _session()
	var before: float = CombatPower.compute(s.player, s.gd, s.db, s.sheet()).total
	var bid: String = _beast(s)
	assert_true(s.beasts.tame(s.player, bid).ok, "tamed")
	s.sync_player()
	var p: Dictionary = CombatPower.compute(s.player, s.gd, s.db, s.sheet())
	assert_true(float(p.total) > before, "beast adds power: %.0f -> %.0f" % [before, float(p.total)])
	assert_true(str(p.lines).contains("Linh thú"), "breakdown names the beast")
	var dest: String = s.db.get_record("places", s.player.location_id).links[0].to
	s.travel(dest)
	s.pending_event = {}
	assert_eq(str(s.db.get_record("people", bid).location_id), s.player.location_id, "beast travelled along")


func test_unfed_beasts_lose_loyalty_and_leave_at_zero() -> void:
	var s := _session()
	var bid: String = _beast(s)
	s.beasts.tame(s.player, bid)
	s.player.linh_thach = 0
	var start: int = int(s.db.get_record("people", bid).loyalty)
	var lines: Array = s.beasts.feed(s.player)
	assert_true(int(s.db.get_record("people", bid).loyalty) < start, "loyalty fell")
	assert_false(lines.is_empty(), "reported")
	for i in 10:
		s.beasts.feed(s.player)
	assert_eq(str(s.db.get_record("people", bid).get("owner_id", "")), "", "the beast left")
	assert_false(s.player.beasts.has(bid), "no longer listed")


func test_owned_beasts_grow_with_the_world_tick_and_wild_ones_do_not() -> void:
	var s := _session()
	var owned: String = _beast(s)
	var wild: String = _beast(s)
	s.beasts.tame(s.player, owned)
	s.db.get_record("people", owned)["stage"] = 0
	s.db.get_record("people", wild)["stage"] = 0
	for i in 200:
		s.ticker.tick(s.rng, s.year, 0)
	var o: Dictionary = s.db.get_record("people", owned)
	var w: Dictionary = s.db.get_record("people", wild)
	assert_true(int(o.stage) > 0 or int(o.realm_index) > 0 or not o.alive, "owned beast grew")
	assert_eq(int(w.stage), 0, "wild beast unchanged")


func test_owned_beasts_survive_save_and_load() -> void:
	var s := _session()
	var bid: String = _beast(s)
	s.beasts.tame(s.player, bid)
	s.sync_player()
	var d: Dictionary = JSON.parse_string(JSON.stringify(s.to_dict()))
	var gd := game_data()
	var llm := LlmService.new(gd)
	llm.enabled = false
	var t := GameSession.new(gd, llm, TestFixtures.tree())
	t.load_dict(d)
	assert_true(t.player.beasts.has(bid), "owner keeps the beast")
	assert_eq(str(t.db.get_record("people", bid).owner_id), t.player.id, "beast keeps its owner")
