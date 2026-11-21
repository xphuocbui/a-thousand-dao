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


func test_war_and_rebel_odds_replace_the_default() -> void:
	# Sects F15: a Cautious head's war odds 1.2 and rebel odds 1.3 replace the defaults; with none, nothing is set
	var gd := game_data()
	var p := NpcTraits.pulls(gd, {"npc_traits": {"personality": ["cautious"], "calling": "", "fate": [], "gained": []}})
	assert_eq(float(p.war_odds), 1.2, "war odds")
	assert_eq(float(p.rebel_odds), 1.3, "rebel odds")
	var none := NpcTraits.pulls(gd, {})
	assert_false(none.has("war_odds") or none.has("rebel_odds"), "no trait, no odds")
	var both := NpcTraits.pulls(gd, {"npc_traits": {"personality": ["cautious", "cruel"], "calling": "", "fate": [], "gained": []}})
	assert_eq(float(both.war_odds), 0.8, "with several, the lowest")


func test_compassionate_truce_and_callous_losses() -> void:
	var gd := game_data()
	var p := NpcTraits.pulls(gd, {"npc_traits": {"personality": ["compassionate"], "calling": "", "fate": [], "gained": []}})
	assert_eq(float(p.weariness), 0.0, "the general limit is untouched")
	assert_eq(float(p.weariness_truce), -10.0, "a truce 10 earlier")
	var q := NpcTraits.pulls(gd, {"npc_traits": {"personality": ["callous"], "calling": "", "fate": [], "gained": []}})
	assert_true(bool(q.half_loss_weariness), "half weariness from losses")


func test_trait_rows_reach_the_stat_sheet_and_survive_a_round_trip() -> void:
	# rule 5: Brave's boon maximum health +2.0 % and cost evade -0.8 pp, under the trait's name
	var gd := game_data()
	var c := Character.new()
	c.npc_traits = {"personality": ["brave"], "calling": "", "fate": [], "gained": []}
	var back := Character.from_dict(c.to_dict())
	assert_eq(back.npc_traits, c.npc_traits, "round trip")
	var sheet := StatSheet.build(back, gd, null, null)
	assert_eq(sheet.total("khi_huyet_pct"), 2.0, "boon")
	assert_eq(sheet.total("evade_pct"), -0.8, "cost")
	assert_eq(str(sheet.sources("khi_huyet_pct")[0].source), "Tính tình: dũng mãnh", "source")


func test_invest_ties_go_to_the_leaders_first_track() -> void:
	# F19 rule 3: a sect with nothing invested goes to the leader's first track; a tie goes to it too
	var gd := game_data()
	var s := {"invested": {"holdings": 0.0, "institutions": 0.0, "military": 0.0, "trade": 0.0}, "dials": {"war_readiness": 2}}
	assert_eq(SectEconomy.invest_track(gd, s, "trade"), "trade", "nothing invested")
	assert_eq(SectEconomy.invest_track(gd, s, ""), SectEconomy.invest_track(gd, s), "no first track: as before")


func test_catalogue_data_checks() -> void:
	# AC-NTC-02, 03, 04, 05, 07, 08 on assets/data/traits.json
	var gd := game_data()
	var f: Dictionary = gd.file(NpcTraits.FILE)
	var sets := {}
	for t in f.personality:
		sets[int(t.set)] = true
	assert_eq([f.personality.size(), sets.size(), f.callings.size(), f.fate.size(), f.gained.size()], [37, 18, 14, 10, 16], "AC-NTC-07 counts")
	var core := {}
	for t in f.personality:
		var twos: int = 0
		assert_true(Dictionary(t.tags).size() <= 3, "%s: at most three weights" % t.id)
		for tag in t.tags:
			if float(t.tags[tag]) == 2.0:
				twos += 1
				core[tag] = int(core.get(tag, 0)) + 1
		assert_true(twos <= 1, "%s: at most one 2.0" % t.id)
		assert_eq([Array(t.boon).size(), Array(t.cost).size()], [1, 1], "AC-NTC-04 %s: one boon, one cost" % t.id)
	assert_eq(core.size(), 20, "AC-NTC-02: 20 core tags")
	assert_eq(core.values().filter(func(n): return n != 1).size(), 0, "each the core of exactly one trait")
	var reach := {}
	for arch in f.calling_weights:
		if arch == "sect_member":
			continue
		var sum: float = 0.0
		for cid in f.calling_weights[arch]:
			sum += float(f.calling_weights[arch][cid])
			reach[cid] = true
		assert_eq(sum, 10.0, "AC-NTC-03 %s weights sum to 10" % arch)
	for cid in f.calling_weights.sect_member:
		reach[cid] = true
	assert_eq(reach.size(), 14, "all 14 callings reachable")
	for t in f.callings:
		assert_eq(Array(t.tags.values()).filter(func(w): return float(w) != 1.5 and float(w) != 0.67).size(), 0, "AC-NTC-03 %s tags" % t.id)
		for r in Array(t.boon) + Array(t.cost):
			assert_false(str(r.stat) == "attack_pct" or str(r.stat).begins_with("crit"), "AC-NTC-04 no offence row")
	for t in f.gained:
		assert_true(str(t.trigger) != "", "AC-NTC-05 %s has a trigger" % t.id)
	var by := {}
	for t in f.personality:
		by[str(t.id)] = t
	for id in ["brave", "ambitious"]:
		assert_eq(float(by[id].pulls.rebel_odds), 0.8, "AC-NTC-08 %s" % id)
	for id in ["cautious", "content"]:
		assert_eq(float(by[id].pulls.rebel_odds), 1.3, "AC-NTC-08 %s" % id)


func test_f3_example_starting_attitude() -> void:
	# F3's example: a Brave, Vengeful, Devout (chính) NPC meets a Brave, Forgiving, Humble, ma-aligned player with
	# standing −20: +10 (Brave shared) − 10 (Vengeful against Forgiving) + 5 (Humble) − 10 (Devout to the opposite
	# alignment) − 5 (a quarter of the standing) = −10
	var gd := game_data()
	var db := WorldDB.new()
	db.put("sects", {"id": "s1", "alignment": "chinh", "attitude": {}, "relation": {}, "leader_id": ""})
	db.put("sects", {"id": "s2", "alignment": "ma", "attitude": {}, "relation": {}, "leader_id": ""})
	var npc := {"id": "p1", "sect_id": "s1", "npc_traits": {"personality": ["brave", "vengeful", "devout"], "calling": "", "fate": [], "gained": []}}
	var pl := {"id": "p2", "sect_id": "s2", "is_player": true, "npc_traits": {"personality": ["brave", "forgiving", "humble"], "calling": "", "fate": [], "gained": []}}
	assert_eq(NpcTraits.opinion(gd, db, npc, pl), -5.0, "opinion before standing")
	assert_eq(NpcTraits.att0(gd, db, npc, pl, -20.0, -30), -10, "att0")
	# traits alone never make a stranger hostile: the floor is the hostile threshold + 1
	npc.npc_traits.gained = [{"id": "grudge", "expires": 99, "target": "p2"}]
	assert_eq(NpcTraits.att0(gd, db, npc, pl, -100.0, -30), -29, "the floor")


func test_f3_example_master_and_disciple() -> void:
	# a Brave master and a Brave disciple in different sects: 10 + 30 = 40 (50 in the same sect)
	var gd := game_data()
	var db := WorldDB.new()
	db.put("sects", {"id": "s1", "alignment": "trung", "attitude": {"s2": 0.0}, "relation": {}, "leader_id": ""})
	db.put("sects", {"id": "s2", "alignment": "trung", "attitude": {"s1": 0.0}, "relation": {}, "leader_id": ""})
	var m := {"id": "p1", "sect_id": "s1", "npc_traits": {"personality": ["brave"], "calling": "", "fate": [], "gained": []}}
	var d := {"id": "p2", "sect_id": "s2", "master_id": "p1", "npc_traits": {"personality": ["brave"], "calling": "", "fate": [], "gained": []}}
	assert_eq(NpcTraits.opinion(gd, db, m, d), 40.0, "different sects")
	d.sect_id = "s1"
	assert_eq(NpcTraits.opinion(gd, db, m, d), 50.0, "same sect")


func test_f2_choice_weights_and_the_pick() -> void:
	# F2's example, a Wrathful, Vengeful NPC: retaliate (aggressive, vengeful) 1.5 x 2.0 = 3.0; endure (cautious) 0.67;
	# reconcile (merciful) 0.67 by the catalogue (the GDD example reads 0.5, flagged for the user)
	var gd := game_data()
	var p := {"id": "p1", "npc_traits": {"personality": ["wrathful", "vengeful"], "calling": "", "fate": [], "gained": []}}
	assert_near(NpcTraits.choice_weight(gd, p, ["aggressive", "vengeful"]), 3.0, 1e-9, "retaliate")
	assert_near(NpcTraits.choice_weight(gd, p, ["cautious"]), 0.67, 1e-9, "endure")
	assert_near(NpcTraits.choice_weight(gd, p, ["merciful"]), 0.67, 1e-9, "reconcile")
	var honest := {"id": "p2", "npc_traits": {"personality": ["honest"], "calling": "", "fate": [], "gained": []}}
	assert_eq(NpcTraits.choice_weight(gd, honest, ["deceitful"]), 0.0, "Honest never deceives")
	var choices := [{"base": 1.0, "tags": ["aggressive", "vengeful"]}, {"base": 1.0, "tags": ["cautious"]}, {"base": 1.0, "tags": ["merciful"]}]
	var counts := [0, 0, 0]
	for s in 2000:
		counts[NpcTraits.pick_choice(gd, p, choices, "insult", s)] += 1
	assert_true(absf(counts[0] / 2000.0 - 3.0 / 4.34) < 0.03, "retaliate about 69 %% (got %d)" % counts[0])
	assert_eq(NpcTraits.pick_choice(gd, p, choices, "insult", 5), NpcTraits.pick_choice(gd, p, choices, "insult", 5), "keyed")
	assert_eq(NpcTraits.pick_choice(gd, honest, [{"base": 1.0, "tags": ["deceitful"]}], "lie", 1), 0, "all zero: base weights")


func test_f5_a_disciple_leans_toward_the_master() -> void:
	# F5's example: a disciple shares about 0.60 of the master's three traits on average, against 0.24 at random
	var gd := game_data()
	var master: Array = ["brave", "honest", "diligent"]
	var shared: float = 0.0
	var random: float = 0.0
	for i in 600:
		shared += NpcTraits.roll(gd, "d%d" % i, "kiem_tu", true, master).personality.filter(func(x): return master.has(x)).size()
		random += NpcTraits.roll(gd, "d%d" % i, "kiem_tu", true).personality.filter(func(x): return master.has(x)).size()
	assert_true(absf(shared / 600.0 - 0.60) < 0.12, "about 0.60 shared (got %.2f)" % (shared / 600.0))
	assert_true(absf(random / 600.0 - 0.24) < 0.08, "about 0.24 at random (got %.2f)" % (random / 600.0))


func test_humble_counts_once_toward_sect_attitudes() -> void:
	# F7's bias from all is the F15 attitude-bias pull (Humble +5), not also F3's bias_all; Renowned has no sect pull
	var gd := game_data()
	var h := NpcTraits.pulls(gd, {"npc_traits": {"personality": ["humble"], "calling": "", "fate": [], "gained": []}})
	assert_eq(float(h.bias_from_all), 5.0, "Humble +5 once")
	var r := NpcTraits.pulls(gd, {"npc_traits": {"personality": [], "calling": "", "fate": [], "gained": [{"id": "renowned", "expires": 9, "target": ""}]}})
	assert_eq(float(r.bias_from_all), 0.0, "Renowned: no sect-level bias")


func test_f4_fate_weights_follow_the_talent() -> void:
	# F4's example: fortune 72 gives Heaven-favoured g 1.6 and Ill-starred 0.63
	var gd := game_data()
	var rc: Dictionary = gd.file(NpcTraits.FILE).roll
	assert_near(NpcTraits.g_f(rc, "khi_van", {"khi_van": 72}), 1.6, 1e-9, "the gift")
	assert_near(NpcTraits.g_f(rc, "khi_van (inverse)", {"khi_van": 72}), 0.625, 1e-9, "the flaw")
	assert_eq(NpcTraits.g_f(rc, "khi_van", {}), 1.0, "unknown talent")
	assert_eq(NpcTraits.g_f(rc, "khi_van", {"khi_van": 500}), 3.0, "clamped")


func test_the_same_id_is_a_different_person_in_another_world() -> void:
	var gd := game_data()
	var a := NpcTraits.roll(gd, "7:p900", "kiem_tu", false)
	var same := 0
	for i in 40:
		if NpcTraits.roll(gd, "7:p%d" % (900 + i), "kiem_tu", false).personality == NpcTraits.roll(gd, "8:p%d" % (900 + i), "kiem_tu", false).personality:
			same += 1
	assert_true(same < 5, "two worlds' keys roll apart (%d of 40 alike)" % same)
	var b := BuildGenerator.new(gd, TestFixtures.tree(), WorldDB.new())
	b.trait_seed = "7"
	assert_eq(b.trait_key("p900"), "7:p900", "the builder salts the key with the world seed")
	assert_eq(a, NpcTraits.roll(gd, b.trait_key("p900"), "kiem_tu", false), "and rolls by it")


func test_first_meeting_sets_att0_once_and_keeps_an_earlier_attitude() -> void:
	var gd := game_data()
	var db := WorldDB.new()
	var pl := {"id": "pp", "is_player": true, "npc_traits": {"personality": ["brave"], "calling": "", "fate": [], "gained": []}}
	var fresh := {"id": "n1", "attitude": 0, "npc_traits": {"personality": ["brave"], "calling": "", "fate": [], "gained": []}}
	NpcTraits.first_meeting(gd, db, fresh, pl, 0.0, -30)
	assert_eq(int(fresh.attitude), 10, "att0: Brave shared +10")
	fresh.attitude = 3
	NpcTraits.first_meeting(gd, db, fresh, pl, 0.0, -30)
	assert_eq(int(fresh.attitude), 3, "once only")
	var moved := {"id": "n2", "attitude": -8, "npc_traits": {"personality": ["brave"], "calling": "", "fate": [], "gained": []}}
	NpcTraits.first_meeting(gd, db, moved, pl, 0.0, -30)   # an event moved it first (or an older save)
	assert_eq(int(moved.attitude), -8, "an earlier attitude stays")
	assert_true(bool(moved.met_player), "and counts as met")
