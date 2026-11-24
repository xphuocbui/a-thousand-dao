extends DaoTestSuite
## ADR-0006 decision 1: reads never change the world. Every GameSession read method and Guidance read
## (StateSnapshot, Advisor, GameQuery) leaves to_dict() (which holds the World DB and the session random stream's state)
## exactly as it was. A small world with Power Rankings on, so the power reads have rating records to touch.

static var _on: GameData


static func _gd_on() -> GameData:
	if _on == null:
		_on = GameData.load_from("res://assets/data")
		_on.world_gen().people.world_cultivators = 80
		_on.world_gen().people.world_cultivators_min = 0
		var k: Dictionary = _on.file("combat_rankings")
		k["enabled"] = true
		k["season_fight_budget"] = 240
		k["worldgen_fight_budget"] = 120
	return _on


func _session() -> GameSession:
	var gd := _gd_on()
	var llm := LlmService.new(gd)
	llm.enabled = false
	var s := GameSession.new(gd, llm, TestFixtures.tree())
	s.new_game(5151, {"mode": "roll", "name": "Đọc Thử", "gender": "male", "origin": "tan_tu"})
	return s


static func _state(s: GameSession) -> String:
	return JSON.stringify(s.to_dict(), "", true)


func test_reading_the_power_of_a_stale_player_changes_nothing() -> void:
	# The player's build moves ahead of its rating between actions; the HUD then reads the power number. Before ADR-0006
	# that read synced the record, marked it Stale and ran the player's panel: the world changed because the UI looked.
	var s := _session()
	assert_eq(str(s.ratings.refresh_person(s.db.get_record("people", s.player.id)).state), RatingService.RATED, "precondition: the player is rated at world generation")
	s.player.level += 1   # the build changed (as between two actions)
	var before: String = _state(s)
	s.player_power()
	StateSnapshot.take(s)
	assert_eq(_state(s), before, "reading the power changed the world")
	s.shutdown()


func test_every_read_method_and_guidance_read_leaves_the_world_unchanged() -> void:
	var s := _session()
	var here: String = str(s.player.location_id)
	var other: String = ""
	for p in s.db.all("places"):
		if str(p.id) != here and p.has("tile"):
			other = str(p.id)
			break
	var npc: String = ""
	for p in s.db.all("people"):
		if not bool(p.get("is_player", false)) and bool(p.get("alive", true)):
			npc = str(p.id)
			break
	var reads := {
		"clock_label": func(): return s.clock_label(),
		"season_index": func(): return s.season_index(),
		"has_pending_event": func(): return s.has_pending_event(),
		"teleport_fee": func(): return s.teleport_fee(other),
		"clue_lines": func(): return s.clue_lines(),
		"abode_lines": func(): return s.abode_lines(),
		"work_lines": func(): return s.work_lines(),
		"array_lines": func(): return s.array_lines(),
		"ratings_on": func(): return s.ratings_on(),
		"player_power": func(): return s.player_power(),
		"power_of_person": func(): return s.power_of_person(npc),
		"place_density": func(): return s.place_density(here),
		"tree_starts": func(): return s.tree_starts(),
		"talisman_available": func(): return s.talisman_available(),
		"local_density": func(): return s.local_density(s.sheet()),
		"sheet": func(): return s.sheet(),
		"StateSnapshot.take": func(): return StateSnapshot.take(s),
		"Advisor.goals": func(): return Advisor.goals(s),
		"Advisor.progress": func(): return Advisor.progress(s),
		"Advisor.breakthrough_odds": func(): return Advisor.breakthrough_odds(s),
		"Advisor.actions": func(): return Advisor.actions(s),
		"Advisor.can_work_here": func(): return Advisor.can_work_here(s),
		"GameQuery.clock": func(): return GameQuery.clock(s),
		"GameQuery.player": func(): return GameQuery.player(s),
		"GameQuery.here": func(): return GameQuery.here(s),
		"GameQuery.place": func(): return GameQuery.place(s, other),
		"GameQuery.known_places": func(): return GameQuery.known_places(s),
		"GameQuery.people_met_at": func(): return GameQuery.people_met_at(s, here),
		"GameQuery.route_seasons": func(): return GameQuery.route_seasons(s, other),
		"GameQuery.has_clues": func(): return GameQuery.has_clues(s),
		"GameQuery.pending_event": func(): return GameQuery.pending_event(s),
		"GameQuery.market_lines": func(): return GameQuery.market_lines(s, here),
		"GameQuery.breakdown rate": func(): return GameQuery.breakdown(s, "rate"),
		"GameQuery.breakdown lifespan": func(): return GameQuery.breakdown(s, "lifespan"),
		"GameQuery.level_requirement": func(): return GameQuery.level_requirement(s),
		"GameQuery.travel_factor": func(): return GameQuery.travel_factor(s),
		"GameQuery.place_lines": func(): return GameQuery.place_lines(s, here),
		"GameQuery.place_lore": func(): return GameQuery.place_lore(s, here),
		"GameQuery.regions": func(): return GameQuery.regions(s),
		"GameQuery.resources": func(): return GameQuery.resources(s),
		"GameQuery.sheet_lines": func(): return GameQuery.sheet_lines(s),
		"GameQuery.person": func(): return GameQuery.person(s, npc),
		"GameQuery.people_at": func(): return GameQuery.people_at(s, here),
		"GameQuery.practice_fight": func(): return GameQuery.practice_fight(s, npc),
		"GameQuery.character": func(): return GameQuery.character(s),
		"GameQuery.character (another person)": func(): return GameQuery.character(s, npc),
		"GameQuery.world_seed": func(): return GameQuery.world_seed(s),
		"GameQuery.inventory": func(): return GameQuery.inventory(s),
		"GameQuery.relationships": func(): return GameQuery.relationships(s),
		"GameQuery.rankings": func(): return GameQuery.rankings(s, s.player.realm_index),
		"GameQuery.rankings top": func(): return GameQuery.rankings(s, "top"),
		"GameQuery.sect": func(): return GameQuery.sect(s, ""),
		"GameQuery.abode": func(): return GameQuery.abode(s),
		"GameQuery.formations": func(): return GameQuery.formations(s),
		"GameQuery.formation_catalogue": func(): return GameQuery.formation_catalogue(s),
		"GameSession.diagram_raise_check": func(): return s.diagram_raise_check(str(Diagrams.cfg(s.gd).starter)),
		"GameQuery.outliner": func(): return GameQuery.outliner(s, [npc]),
		"GameQuery.dao_do": func(): return GameQuery.dao_do(s),
		"GameQuery.dao_do_node": func(): return GameQuery.dao_do_node(s, int(s.tree.frontier(s.player, s.gd)[0]) if not s.tree.frontier(s.player, s.gd).is_empty() else 0, []),
		"GameQuery.sect other": func(): return GameQuery.sect(s, str(s.db.all("sects")[0].id)),
	}
	for name in reads:
		var before: String = _state(s)
		(reads[name] as Callable).call()
		assert_eq(_state(s), before, "%s changed the world" % name)
	s.shutdown()


func test_a_build_changing_action_refreshes_the_rating_and_opening_the_number_runs_no_panel_ac_pr_39() -> void:
	var s := _session()
	s.player.level += 1   # the build changed (as cultivating does) ...
	var starts: Array = s.tree_starts().filter(func(x): return bool(x.current))
	assert_true(not starts.is_empty(), "precondition: the player has a Đạo Đồ start")
	assert_true(bool(s.tree_choose_start(str(starts[0].key)).ok), "... then an action that can change the build runs")
	var rec: Dictionary = s.db.get_record(RatingService.TABLE, s.player.id)
	assert_eq(str(rec.state), RatingService.RATED, "the action ran the player's panel for the new build")
	assert_eq(str(rec.get("sig", "")), s.ratings.build_sig(s.db.get_record("people", s.player.id)), "rated for the build it has now")
	var before: String = _state(s)
	s.player_power()
	s.player_power()
	assert_eq(_state(s), before, "opening the power number twice runs no panel")
	s.shutdown()


func test_run_hands_back_the_events_of_the_action() -> void:
	var s := _session()
	var r: Dictionary = s.run(func():
		s._end_life("a test")
		return {"ok": true, "lines": []})
	var kinds: Array = Array(r.events).map(func(e): return str(e.kind))
	assert_true(kinds.has("life_ended"), "the end of the life is in the result")
	assert_eq(str((r.events[kinds.find("life_ended")] as Dictionary).summary.cause), "a test")
	var r2: Dictionary = s.run(func(): return null)
	assert_true(not bool(r2.ok) and Array(r2.events).is_empty(), "a non-Dictionary result is a failed action, and events do not carry over")
	s.shutdown()


func test_game_query_returns_deep_copies_so_changing_one_leaves_the_world_alone() -> void:
	var s := _session()
	var before: String = _state(s)
	var h: Dictionary = GameQuery.here(s)
	assert_true(h.has("qi") and not (h.qi as Dictionary).is_empty(), "precondition: the place has a qi table")
	(h.qi as Dictionary)[(h.qi as Dictionary).keys()[0]] = -999   # a nested value
	h["name"] = "changed"
	for p in GameQuery.known_places(s):
		(p as Dictionary)["name"] = "changed"
	var ev: Dictionary = GameQuery.pending_event(s)
	ev["title"] = "changed"
	assert_eq(_state(s), before, "a copy reached the world")
	assert_true(str(GameQuery.here(s).name) != "changed", "the place's name is untouched")
	s.shutdown()


func test_an_effect_record_id_resolves_to_its_effect_name_and_rule() -> void:
	var gd := _gd_on()
	var lib: Dictionary = gd.file("combat_effects").get("effects", {})
	assert_true(lib.has("Layered Earth"), "precondition: the Effect is in combat_effects.json")
	var e: Dictionary = GameQuery.effect_of(gd, "eff:Layered Earth block")
	assert_eq(e.name, "Layered Earth", "a suffixed record id belongs to the longest Effect name it starts with")
	assert_eq(e.rule, str(lib["Layered Earth"].rule), "and carries that Effect's rule for the tooltip")
	assert_eq(GameQuery.effect_of(gd, "eff:Not An Effect").name, "Not An Effect", "an unknown id comes back as its own name")
	assert_eq(GameQuery.effect_of(gd, "eff:Not An Effect").rule, "", "with no rule")


func test_the_practice_fight_carries_each_side_s_sheet_for_the_portrait() -> void:
	var s := _session()
	var npc: String = ""
	for p in s.db.all("people"):
		if not bool(p.get("is_player", false)) and bool(p.get("alive", true)) and not bool(p.get("is_beast", false)):
			npc = str(p.id)
			break
	var f: Dictionary = GameQuery.practice_fight(s, npc)
	assert_true(bool(f.get("ok", false)), "the practice fight runs")
	for side in ["a", "b"]:
		var sh: Dictionary = f[side].get("sheet", {})
		for key in ["ward_pts", "ward_layer", "drain", "resist", "soul_res", "divine_sense", "crit_mult", "power"]:
			assert_true(sh.has(key), "side %s's sheet has %s" % [side, key])
		assert_true(f[side].has("effect_info"), "side %s names its Effects" % side)
	s.shutdown()   # joins the season rating batch new_game started; without it the process exits under the thread


func test_a_place_carries_its_catalogue_look_and_lore() -> void:
	var s := _session()
	var here: String = str(s.player.location_id)
	var lore: Dictionary = GameQuery.place_lore(s, here)
	assert_true(str(lore.get("look", "")) != "" and str(lore.get("lore", "")) != "", "the player's place has a look and lore")
	var rec: Dictionary = s.db.get_record("places", here)
	var cat: Dictionary = s.gd.file("world_place_lore").places
	assert_eq(str(lore.get("name", "")), str(cat[str(int(rec.continent_id))].name), "keyed by the continent place id")
	assert_eq(GameQuery.place_lore(s, "no_such_place"), {}, "an unknown place has none")
	s.shutdown()


func test_the_character_read_carries_every_section_of_the_sheet() -> void:
	# design/ux/character-sheet.md Acceptance Criteria: one read returns every field the window shows, Breakdowns included.
	var s := _session()
	var v: Dictionary = GameQuery.character(s)
	for key in ["name", "realm_label", "age", "lifespan", "power", "cultivation", "roots", "talents", "vitals", "combat", "slots",
			"known", "gear", "crafts", "dao_do", "fate", "breakdowns"]:
		assert_true(v.has(key), "the character read has %s" % key)
	assert_eq(Array(v.roots.elements).size(), 5, "all five elements, owned or not")
	assert_eq(Array(v.talents).size(), s.gd.thien_phu_defs().size(), "every talent")
	for key in ["rate", "lifespan", "health", "linh_luc", "than_thuc", "dan_doc", "backlash"]:
		assert_true(Array(v.breakdowns.get(key, {}).get("lines", [])).size() > 0, "a %s Breakdown with lines" % key)
	assert_eq(str(v.slots[0].slot), "main", "the main slot first")
	assert_eq((v.cultivation.bottleneck as Dictionary).is_empty(), not CultivationRules.at_great_perfection(s.player, s.gd),
		"the bottleneck block exactly at great perfection")
	s.shutdown()


func test_the_character_read_shows_the_bottleneck_block_at_great_perfection() -> void:
	var s := _session()
	s.player.level = int(Ladder.band(s.gd, s.player.realm_index)[1])   # the realm's last level: great perfection
	s.player.stage = Ladder.stage_of_level(s.gd, s.player.level)
	s.player.tu_vi = Ladder.bar_cost(s.gd, s.player.realm_index)
	assert_true(CultivationRules.at_bottleneck(s.player, s.gd), "precondition: at the bottleneck")
	var before: String = _state(s)
	var v: Dictionary = GameQuery.character(s)
	var bn: Dictionary = v.cultivation.bottleneck
	assert_false(bn.is_empty(), "the block is there at great perfection")
	assert_true(bool(bn.full) and bn.has("chance") and bn.has("backlash"), "a full bar, the chance and the risk")
	assert_eq(_state(s), before, "the read changed nothing")
	s.shutdown()


func test_the_inventory_read_lists_owned_items_with_their_verbs() -> void:
	var s := _session()
	var v: Dictionary = GameQuery.inventory(s)
	var owned: int = 0
	for it in s.db.items_of(s.player.id):
		if not (str(it.get("kind", "")) == "herb" and int(it.get("plot", -1)) >= 0):
			owned += 1
	assert_eq(Array(v.items).size(), owned, "every owned item except planted herbs")
	for row in v.items:
		assert_true(int(row.rarity) >= 1 and str(row.text) != "", "%s has a rarity and its text" % str(row.id))
		if str(row.kind) == "artifact":
			assert_true(Array(row.verbs).size() > 0, "a pháp bảo has a verb")
	assert_true(int(v.gear.base_total) >= 5, "the base slots counted")
	s.shutdown()


func test_the_relationships_read_matches_the_tie_store() -> void:
	var s := _session()
	var v: Dictionary = GameQuery.relationships(s)
	var pid: String = s.player.id
	assert_eq(int(v.cap), Ties.cap(s.gd, s.db, pid), "the cap")
	assert_eq(int(v.soft_limit), Ties.soft_limit(s.gd, s.db, pid), "the soft limit")
	assert_eq(Array(v.ties).size(), s.db.ties_of(pid).size(), "one row per tie record")
	for t in v.ties:
		assert_true(Array(t.kinds).size() > 0, "a tie row has a kind")
	s.shutdown()


func test_the_rankings_read_orders_by_rating_lists_the_player_and_agrees_with_the_box() -> void:
	var s := _session()
	var v: Dictionary = GameQuery.rankings(s, s.player.realm_index)
	assert_true(bool(v.on), "ratings are on in this suite")
	assert_true(int(v.player_rank) > 0, "the player is listed")
	var rows: Array = v.rows
	for i in range(1, rows.size()):
		var a: Dictionary = rows[i - 1]
		var b: Dictionary = rows[i]
		if (a.state == RatingService.PROVISIONAL) == (b.state == RatingService.PROVISIONAL):
			assert_true(float(a.rating) >= float(b.rating), "rule 9 order at %d" % i)
	var me: Dictionary = rows[int(v.player_rank) - 1]
	assert_eq(int(me.power), int(GameQuery.resources(s).power), "the window and the rating box show one number")
	var top: Dictionary = GameQuery.rankings(s, "top")
	for r in top.rows:
		assert_true(["Nguyên Anh", "Hóa Thần"].has(str(r.realm)), "the top list is Nguyên Anh and Hóa Thần only")
	s.shutdown()


func test_the_rankings_change_column_counts_places_since_the_snapshot() -> void:
	var s := _session()
	var realm: int = s.player.realm_index
	var v0: Dictionary = GameQuery.rankings(s, realm)
	assert_true(Array(v0.rows).all(func(r): return int(r.move) == 0 and not bool(r.new)), "no change before any season's results")
	s.ratings.snapshot_prev()   # what RatingService.apply_batch does before a season's results land
	# a stored record from the lower half climbs past everyone
	var climber: Dictionary = {}
	for r in Array(v0.rows).slice(int(v0.rows.size() / 2)):
		if not s.db.get_record(RatingService.TABLE, str(r.id)).is_empty() and not bool(r.you):
			climber = r
			break
	assert_false(climber.is_empty(), "a rated record to move")
	var rec: Dictionary = s.db.get_record(RatingService.TABLE, str(climber.id))
	rec["offset"] = float(rec.offset) + 100000.0
	var v1: Dictionary = GameQuery.rankings(s, realm)
	var now: Dictionary = Array(v1.rows).filter(func(r): return str(r.id) == str(climber.id))[0]
	assert_eq(int(now.rank), 1, "it leads now")
	assert_eq(int(now.move), int(climber.rank) - 1, "it climbed from its old place")
	assert_true(Array(v1.rows).filter(func(r): return int(r.move) < 0).size() > 0, "someone it passed fell")
	s.shutdown()


func test_the_abode_read_shows_the_starting_home() -> void:
	var s := _session()
	var v: Dictionary = GameQuery.abode(s)
	assert_true(bool(v.has_home), "a starting home (a free grade-1 room)")
	assert_eq(int(v.grade), 1)
	assert_true(int(v.slots) >= 1 and int(v.used) <= int(v.slots))
	assert_true(Array(v.catalogue).size() > 0, "home works to build")
	s.shutdown()


func test_the_dao_do_node_route_is_the_tree_s_route() -> void:
	var s := _session()
	var fr: Array = s.tree.frontier(s.player, s.gd)
	assert_true(not fr.is_empty(), "a frontier")
	var far: int = -1
	for nb in s.tree.neighbors(int(fr[0])):
		if not s.player.tree_nodes.has(nb) and not fr.has(nb):
			far = int(nb)
	if far < 0:
		far = int(fr[0])
	var v: Dictionary = GameQuery.dao_do_node(s, far, [])
	assert_eq(Array(v.route), s.tree.path_to(s.player, s.gd, far), "the route is DaoDoTree.path_to's")
	var planned: Dictionary = GameQuery.dao_do_node(s, far, [int(fr[0])])
	assert_true(Array(planned.route).size() <= Array(v.route).size(), "a plan shortens the route from its end")
	assert_eq(int(GameQuery.dao_do(s).points), s.player.tree_points)
	s.shutdown()


func test_a_sheet_about_someone_no_longer_in_the_world_says_gone() -> void:
	var s := _session()
	var v: Dictionary = GameQuery.character(s, "p_nobody")
	assert_true(bool(v.get("gone", false)), "a stale history entry reads as gone, not as an error")
	s.shutdown()   # joins the rating batch new_game started


func test_a_new_character_knows_and_sets_the_starter_formation_and_can_change_it() -> void:
	var s := _session()
	var starter: String = str(Diagrams.cfg(s.gd).starter)
	assert_eq(s.player.known_diagrams.map(func(k): return str(k.id)), [starter], "the starter is known")
	assert_eq(str(s.player.diagram.get("id", "")), starter, "and set")
	var v: Dictionary = GameQuery.formations(s)
	assert_eq(str(v.set), starter)
	assert_eq(Array(v.known).size(), 2, "the Plain Row and the starter")
	assert_true(int(v.current.open_nodes) == 2, "the Long Serpent Line opens with two nodes")
	var placed: Array = Array(v.current.nodes).filter(func(n): return str(n.art) != "")
	assert_true(placed.size() >= 1, "arts are placed by fit")
	# move an art to the other open node
	var art: String = str(placed[0].art)
	var other: int = 2 if int(placed[0].n) == 1 else 1
	assert_true(bool(s.place_diagram_art(other, art).ok))
	assert_eq(str(Array(s.player.diagram.placement)[other - 1]), art, "the art moved")
	assert_false(bool(s.place_diagram_art(3, art).ok), "node 3 opens at level 2")
	assert_true(bool(s.set_diagram_lay(false).ok))
	assert_false(bool(s.player.diagram.lay))
	assert_true(bool(s.set_diagram("").ok), "back to the Plain Row")
	assert_true(s.player.diagram.is_empty())
	assert_false(bool(s.set_diagram("bat_quai").ok), "an unknown formation is refused")
	s.shutdown()


func test_the_practice_fight_record_carries_the_player_s_formation() -> void:
	var s := _session()
	var people: Array = GameQuery.people_at(s, s.player.location_id)
	if people.is_empty():
		s.shutdown()
		return
	var f: Dictionary = GameQuery.practice_fight(s, str(people[0].id))
	assert_true(bool(f.ok))
	assert_eq(str(f.a.diagram.id), str(Diagrams.cfg(s.gd).starter), "the player's side draws its formation")
	assert_true(Dictionary(f.b.diagram).is_empty(), "NPCs keep the default line (npc_use false)")
	assert_true(Array(f.a.diagram_lines).any(func(l): return str(l).begins_with("node ")), "the starter's art sits where a node rule applies: %s" % str(f.a.diagram_lines))
	assert_eq(float(f.a.diagram.share), 1.0, "laid in a foreseen fight (the starter's fuel is affordable)")
	s.shutdown()


func test_raising_a_formation_needs_home_the_skill_and_the_stones() -> void:
	var s := _session()
	var sid: String = str(Diagrams.cfg(s.gd).starter)
	var chk: Dictionary = s.diagram_raise_check(sid)
	assert_eq(int(chk.target), 2)
	assert_eq(int(chk.cost), Diagrams.raise_cost(s.gd, 0, 2), "F3's raise cost")
	assert_false(bool(s.raise_diagram("bat_quai").ok), "an unknown formation cannot be raised")
	if not bool(chk.ok):
		assert_false(bool(s.raise_diagram(sid).ok), "refused for the reason the check gives: %s" % chk.reason)
	s.shutdown()



func test_a_sect_teaches_its_formations_by_rank_for_contribution() -> void:
	var s := _session()
	assert_false(bool(s.sect_teach_check("tam_tai").ok), "a loose cultivator has no sect to teach them")
	var sect: Dictionary = {}
	for r in s.db.all("sects"):
		if str(r.get("key", "")) == "thien_xu":
			sect = r
	assert_false(sect.is_empty(), "the formation sect is in the world")
	s.player.sect_id = str(sect.id)
	s.player.sect_rank = "ngoai_mon"
	s.sect_members.record(str(sect.id), s.player.id)["contribution"] = 100
	var v: Dictionary = GameQuery.sect(s, "")
	assert_true(Array(v.teaching).size() >= 5, "the sect window lists what it teaches")
	assert_true(bool(s.learn_sect_diagram("tam_tai").ok), "grade 0 at outer disciple")
	assert_true(s.player.known_diagrams.any(func(k): return str(k.id) == "tam_tai"))
	assert_eq(s.sect_members.contribution(str(sect.id), s.player.id), 100 - Diagrams.learn_cost(s.gd, 0), "the contribution is spent")
	var inner: Dictionary = s.sect_teach_check("tu_mon")
	assert_false(bool(inner.ok), "a grade 1 formation needs an inner disciple")
	assert_true(str(inner.reason).contains("inner") or str(inner.reason).contains("Nội") or str(inner.reason).to_lower().contains("taught to"), str(inner.reason))
	s.shutdown()


func test_a_formation_manual_teaches_its_formation_when_read() -> void:
	var s := _session()
	var m: Dictionary = s.items.diagram_manual("luong_nghi")
	m["owner_id"] = s.player.id
	var mid: String = s.db.add("items", m)
	assert_eq(ItemRarity.of(s.gd, s.db.get_record("items", mid)), 1, "a grade 0 manual is rarity 1")
	assert_true(bool(s.learn(mid).ok))
	assert_true(s.player.known_diagrams.any(func(k): return str(k.id) == "luong_nghi"))
	assert_false(bool(s.learn(mid).ok), "read twice: already known")
	var rng := RandomNumberGenerator.new()
	var special: Array = Diagrams.teaching(s.gd).special
	for i in 200:
		rng.seed = i
		var pick: String = Diagrams.manual_pick(s.gd, rng, 0)
		assert_false(special.has(pick), "the special five never drop")
		assert_true(int(Diagrams.record_of(s.gd, pick).realm_min) <= 1, "a Luyện Khí finder finds formations up to one realm ahead")
	s.shutdown()
