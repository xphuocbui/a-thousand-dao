extends DaoTestSuite
## NPC Traits (design/gdd/npc-traits.md F4, the catalogue; Sects F15's pulls).


func test_a_roll_draws_three_non_opposed_traits_a_calling_and_is_keyed() -> void:
	var gd := game_data()
	var cat := NpcTraits.catalogue(gd)
	for i in 50:
		var t := NpcTraits.roll(gd, "p%d" % i, "kiem_tu", i % 2 == 0)
		assert_eq(t.personality.size(), 3, "three personality traits")
		var sets := {}
		for id in t.personality:
			sets[int(cat.by_id[id].set)] = true
		assert_eq(sets.size(), 3, "never two of one set (p%d: %s)" % [i, str(t.personality)])
		assert_true(str(t.calling) != "", "a calling")
		assert_true(t.fate.size() <= 2, "at most two fate-given")
	assert_eq(NpcTraits.roll(gd, "p7", "kiem_tu", false), NpcTraits.roll(gd, "p7", "kiem_tu", false), "the same id rolls the same")


func test_the_cast_keeps_its_authored_traits() -> void:
	var gd := game_data()
	var t := NpcTraits.from_authored(gd, {"personality": ["Honest", "Just", "Cautious"], "calling": "Strategist", "fate_given": []})
	assert_eq(t.personality, ["honest", "just", "cautious"], "ids")
	assert_eq(t.calling, "strategist", "calling")


func test_pulls_follow_sects_f15() -> void:
	# a Greedy, Ambitious, Paranoid Strategist: Tax +1, Expansion +1, War readiness +1, loyalty -2, war odds 0.9; the
	# dial pulls sum to 3, so the leader is bold
	var gd := game_data()
	var p := NpcTraits.pulls(gd, {"npc_traits": {"personality": ["greedy", "ambitious", "paranoid"], "calling": "strategist", "fate": [], "gained": []}})
	assert_eq(p.dials, {"tax": 1.0, "expansion": 1.0, "war_readiness": 1.0}, "dial pulls")
	assert_eq(float(p.loyalty), -2.0, "loyalty")
	assert_eq(float(p.war_odds), 0.9, "war odds")
	assert_eq(float(p.abs_sum), 3.0, "bold by F6's test")
	assert_eq(str(p.first_track), "military", "first track")


func test_the_built_world_gives_every_person_traits() -> void:
	var gd := game_data()
	var r := RandomNumberGenerator.new()
	r.seed = 7
	var db: WorldDB = WorldBuilder.new(gd, TestFixtures.tree()).generate(r, "7")
	var people: Array = db.find("people", func(p): return bool(p.get("alive", false)) and not bool(p.get("is_beast", false)))
	for p in people:
		assert_eq(Array(p.get("npc_traits", {}).get("personality", [])).size(), 3, "%s has three personality traits" % p.id)
	var head: Dictionary = db.get_record("people", str(db.find("sects", func(s): return str(s.get("key", "")) == "thien_xu")[0].leader_id))
	assert_eq(head.npc_traits.personality, ["honest", "just", "cautious"], "Thiên Xu's authored head keeps the authored traits")
