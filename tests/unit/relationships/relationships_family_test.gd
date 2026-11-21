extends DaoTestSuite
## Families (user decision 2026-11-21): World Generation rule 8's families at the start, Living World Tick rule 5's
## births, and a gia_toc player's family, each writing NPC Relationships kin (rule 8; AC-NR-30's generated kin).


func _session(origin: String = "tan_tu") -> GameSession:
	var gd := game_data()
	var llm := LlmService.new(gd)
	llm.enabled = false
	var s := GameSession.new(gd, llm, TestFixtures.tree())
	s.new_game(4242, {"mode": "roll", "name": "Lâm Vô Danh", "gender": "male", "origin": origin})
	s.pending_event = {}
	return s


func _check_family(s: GameSession, child: Dictionary) -> void:
	var par: Dictionary = s.db.get_record("people", str(child.parent_id))
	assert_false(par.is_empty(), "the parent exists")
	assert_true(Ties.has_pin(s.db, str(par.id), str(child.id), "kin"), "parent and child hold kin")
	assert_true(float(par.get("age", 0.0)) >= float(child.get("age", 0.0)) + 18.0 - 1.0, "the parent is at least 18 years older (born as aged)")


func test_the_start_gives_about_kin_share_of_the_random_cultivators_a_parent_with_kin() -> void:
	var s := _session()
	var pool: Array = s.db.all("people").filter(func(p): return str(p.get("created_by", "")) == "worldgen" and not bool(p.get("is_beast", false)))
	var kids: Array = pool.filter(func(p): return str(p.get("parent_id", "")) != "")
	var share: float = float(kids.size()) / maxf(float(pool.size()), 1.0)
	assert_true(share > 0.05 and share <= 0.16, "about 15 %% have a parent: %.3f of %d" % [share, pool.size()])
	for k in kids.slice(0, 20):
		_check_family(s, k)
		var par: Dictionary = s.db.get_record("people", str(k.parent_id))
		assert_eq(Families.surname_of(s.gd, str(k.name)), Families.surname_of(s.gd, str(par.name)), "the child has the parent's surname")
	var counts := {}
	for k in kids:
		counts[str(k.parent_id)] = int(counts.get(str(k.parent_id), 0)) + 1
	assert_true(counts.values().max() <= 3, "at most children_max children")
	var sib_pairs: int = 0
	for pid in counts:
		if int(counts[pid]) >= 2:
			var two: Array = kids.filter(func(k): return str(k.parent_id) == pid).slice(0, 2)
			assert_true(Ties.has_pin(s.db, str(two[0].id), str(two[1].id), "kin"), "siblings hold kin")
			sib_pairs += 1
	assert_true(sib_pairs > 0, "some families have siblings")


func test_births_are_born_to_a_living_cultivator_where_the_parent_is() -> void:
	var s := _session()
	var fam: Dictionary = Families.cfg(s.gd)
	var saved: float = float(fam.birth_share)
	fam["birth_share"] = 1.0
	var people: Dictionary = s.gd.world_gen().people
	var target: int = maxi(int(people.world_cultivators), int(people.world_cultivators_min))
	var n0: int = s.db.count("people")
	var npcs: Array = s.db.living().filter(func(x): return not bool(x.get("is_player", false)) and not bool(x.get("is_beast", false)) and bool(x.get("alive", true)))
	# the fixed cast (never parents, rule 8) and the young go first, so ordinary parents stay
	npcs.sort_custom(func(a, b): return [0 if a.has("cast_key") else 1, float(a.get("age", 0.0))] < [0 if b.has("cast_key") else 1, float(b.get("age", 0.0))])
	for i in maxi(npcs.size() - target + 30, 0):   # make room under the headcount so the intake runs
		npcs[i]["alive"] = false
	var rng := RandomNumberGenerator.new()
	rng.seed = 9
	s.ticker.tick(rng, 1200, 0)
	fam["birth_share"] = saved
	var born: Array = s.db.all("people").slice(n0).filter(func(p): return not bool(p.get("is_beast", false)) and float(p.get("age", 0.0)) <= 16.5)
	assert_true(born.size() >= 30, "the intake refilled: %d" % born.size())
	var with_parent: Array = born.filter(func(p): return str(p.get("parent_id", "")) != "")
	assert_true(with_parent.size() >= born.size() * 0.8, "birth_share 1: nearly all born to a parent (%d of %d)" % [with_parent.size(), born.size()])
	for b in with_parent.slice(0, 10):
		_check_family(s, b)
		var par: Dictionary = s.db.get_record("people", str(b.parent_id))
		if str(par.get("sect_id", "")) == "":
			assert_eq(str(b.location_id), str(par.location_id), "a loose parent's child starts where the parent is")
		else:
			assert_eq(str(b.sect_id), str(par.sect_id), "a sect parent's child joins that sect")
	assert_true(target > 0, "a headcount target")


func test_a_clan_heir_has_a_living_parent_in_the_clan_town() -> void:
	var s := _session("gia_toc")
	assert_true(s.player.parent_id != "", "the gia_toc player has a parent")
	var par: Dictionary = s.db.get_record("people", s.player.parent_id)
	assert_true(bool(par.get("alive", false)), "living")
	assert_eq(str(par.location_id), s.player.home_id, "in the clan town")
	assert_true(Ties.has_pin(s.db, str(par.id), s.player.id, "kin"), "kin")
	assert_eq(Families.surname_of(s.gd, str(par.name)), Families.surname_of(s.gd, s.player.name), "the parent bears the player's surname")
	var d: Dictionary = JSON.parse_string(JSON.stringify(s.to_dict()))
	var t := GameSession.new(s.gd, s.llm, TestFixtures.tree())
	assert_true(bool(t.load_dict(d).ok), "loaded")
	assert_eq(t.player.parent_id, s.player.parent_id, "the parent survives a save")


func test_two_word_surnames_are_kept_whole() -> void:
	var gd := game_data()
	var two: Array = Array(gd.names().surnames).filter(func(x): return str(x).contains(" "))
	if two.is_empty():
		return
	var sn: String = str(two[0])
	assert_eq(Families.surname_of(gd, sn + " Lan"), sn, "a two-word surname")
	assert_eq(Families.with_surname(gd, sn + " Lan", "Chu"), "Chu Lan", "replaced whole")
