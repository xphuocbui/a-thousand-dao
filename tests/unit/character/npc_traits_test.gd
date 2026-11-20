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


func test_gained_traits_grant_refresh_replace_and_fade() -> void:
	# rules 11-13 and F6: fade 40 seasons; a refresh moves the expiry; the opposed trait replaces; a third grant takes the
	# oldest slot of grade at most its own
	var gd := game_data()
	var p := {"npc_traits": {"personality": [], "calling": "", "fate": [], "gained": []}}
	assert_eq(NpcTraits.grant(gd, p, "battle_hardened", 100), "granted", "granted")
	assert_eq(int(p.npc_traits.gained[0].expires), 140, "expires 40 seasons on")
	assert_eq(NpcTraits.grant(gd, p, "battle_hardened", 130), "refreshed", "refreshed")
	assert_eq(int(p.npc_traits.gained[0].expires), 170, "the expiry moves")
	assert_eq(NpcTraits.grant(gd, p, "shaken", 131), "replaced", "the opposed trait replaces")
	assert_eq(p.npc_traits.gained.map(func(e): return e.id), ["shaken"], "only Shaken")
	assert_eq(NpcTraits.grant(gd, p, "renowned", 132), "granted", "a second slot")
	assert_eq(NpcTraits.grant(gd, p, "humbled", 133), "replaced", "a third takes the oldest")
	assert_eq(p.npc_traits.gained.map(func(e): return e.id), ["humbled", "renowned"], "Shaken went")
	assert_eq(NpcTraits.grant(gd, p, "brave", 133), "refused", "not a gained trait")
	NpcTraits.fade(p, 171)
	assert_eq(p.npc_traits.gained.map(func(e): return e.id), ["humbled", "renowned"], "not yet expired")
	NpcTraits.fade(p, 172)   # F6: removed when now >= expires
	assert_eq(p.npc_traits.gained.map(func(e): return e.id), ["humbled"], "Renowned expires at 172")
	NpcTraits.fade(p, 173)
	assert_true(p.npc_traits.gained.is_empty(), "Humbled at 173")


func test_directed_regard_reaches_the_pulls() -> void:
	# F3: Cruel -10 to rivals, Devout -10 to the opposite alignment, Demon-seeded -10 from righteous people
	var gd := game_data()
	var p := NpcTraits.pulls(gd, {"npc_traits": {"personality": ["cruel", "devout"], "calling": "", "fate": ["demon_seeded"], "gained": []}})
	assert_eq(p.bias_dir, {"rivals": -10.0, "opposite": -10.0, "from_righteous": -10.0}, "directed regard")
