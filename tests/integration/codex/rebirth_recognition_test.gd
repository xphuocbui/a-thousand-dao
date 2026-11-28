extends DaoTestSuite
## Codex & Karmic Carryover (#12) Rebirth Recognition & Cross-Life Knowledge integration tests:
## AC-CK-22 (past-life recognition events capped at recognition_max = 2, naming past_ties only,
##           no automatic ties unless formed by event choice),
## AC-CK-13 (known recipe remembered in new life's craft list, craft requirements unchanged),
## AC-CK-14 (entered hidden place shows authored candidates only, never new game's rolled site).


func _small_gd() -> GameData:
	var base := game_data()
	var files_copy: Dictionary = base.registry.files().duplicate()
	var wg: Dictionary = base.file("world_generation").duplicate(true)
	wg["people"]["world_cultivators"] = 40
	wg["people"]["world_cultivators_min"] = 0
	files_copy["world_generation"] = wg
	var rk: Dictionary = base.file("combat_rankings").duplicate(true)
	rk["enabled"] = false
	files_copy["combat_rankings"] = rk
	var gd := GameData.new()
	gd.setup(DataRegistry.from_files(files_copy))
	return gd


func _session(gd: GameData, store: CodexStore, mode: String, seed_v: int) -> GameSession:
	var llm := LlmService.new(gd)
	llm.enabled = false
	var s := GameSession.new(gd, llm, TestFixtures.tree(), store)
	s.ratings_background = false
	s.new_game(seed_v, {
		"mode": "roll", "name": "Tiền Kiếp", "gender": "male", "origin": "tan_tu",
		"playthrough_mode": mode,
	})
	s.pending_event = {}
	return s


func test_rebirth_recognition_capped_at_2_and_no_automatic_ties_ac22() -> void:
	var gd := _small_gd()
	var store := CodexStore.new("")
	var s := _session(gd, store, "continue", 8401)
	var old_id: String = s.player.id

	# Create 5 long-lived Nguyên Anh NPCs with ties to the player so they survive the 64-season gap.
	var past_ids: Array = []
	for i in 5:
		var pid: String = s.builds.create_person(s.rng, {
			"realm_index": 3, "stage": 0, "age": 220.0,
			"location_id": s.player.location_id,
		})
		Ties.add_pinned(gd, s.db, old_id, pid, "ket_nghia", s.season_index())
		past_ids.append(pid)

	s._end_life("Tọa hóa", "", "old_age")
	var reb: Dictionary = s.succeed_rebirth({"name": "Hậu Thế", "origin": "tan_tu"})
	assert_true(bool(reb.ok), "rebirth succeeded")

	# Ensure all 5 past-tie NPCs are alive for the recognition check.
	for pid in past_ids:
		var rec: Dictionary = s.db.get_record("people", str(pid))
		rec["alive"] = true
		s.db.put("people", rec)

	# AC-CK-22: NO tie carries over automatically to the reborn player.
	assert_eq(s.db.ties_of(s.player.id).size(), 0, "AC-CK-22: reborn starts with zero automatic ties")
	assert_eq(s.recognition_used, 0, "recognition_used starts at 0")

	# Draw random events until we exhaust recognition_max (2) or 80 rolls.
	var rec_events_fired: int = 0
	var recognized_npcs: Array = []
	for _i in 80:
		s.pending_event = {}
		s.start_event("")
		if s.has_pending_event() and str(s.pending_event.get("source", "")).begins_with("template:tien_kiep_"):
			rec_events_fired += 1
			var bound_npc: String = str(s.pending_event.get("npc_id", ""))
			assert_true(past_ids.has(bound_npc), "AC-CK-22: recognition event bound one of the 5 past_ties (%s)" % bound_npc)
			recognized_npcs.append(bound_npc)
			# Choose option 1 (decline / keep distance) on first recognition -> must NOT form a tie.
			if rec_events_fired == 1:
				var ch_decline: Dictionary = s.choose(1)
				assert_true(bool(ch_decline.ok), "decline choice resolved")
				TieTick.run(gd, s.db, s.season_index())
				assert_true(s.db.tie_between(s.player.id, bound_npc).is_empty(), "AC-CK-22: declining forms no tie")
			else:
				# On second recognition, accept -> may form a new tie via event effect.
				s.choose(0)
				TieTick.run(gd, s.db, s.season_index())
		else:
			s.pending_event = {}

	assert_true(rec_events_fired >= 1 and rec_events_fired <= 2, "AC-CK-22: at most recognition_max (2) past-life events fired (got %d)" % rec_events_fired)
	assert_true(s.recognition_used <= KarmicRules.recognition_max(gd), "recognition_used capped at recognition_max")

	# Once recognition_used == 2, past-life templates are completely excluded from eligible().
	s.recognition_used = KarmicRules.recognition_max(gd)
	var elig_after: Array = s.templates.eligible(s.event_context())
	for t in elig_after:
		assert_false(bool(t.get("requires_past_ties", false)), "AC-CK-22: no past-life template eligible after cap reached")
	s.shutdown()


func test_known_recipe_remembered_in_new_life_with_requirements_unchanged_ac13() -> void:
	var gd := _small_gd()
	var store := CodexStore.new("")
	var s1 := _session(gd, store, "one_life", 8402)
	# Give Life 1 high Đan Đạo and plenty of herbs to craft tu_khi_dan successfully.
	s1.player.skills["dan_dao"] = {"level": 6, "xp": 0.0}
	s1.player.thien_phu["ngo_tinh"] = 100
	s1.player.linh_can.elements["hoa"] = 90.0
	var rec: Dictionary = gd.recipe("tu_khi_dan")
	for ing in rec.get("ingredients", []):
		if Alchemy.is_herb_entry(ing):
			for _q in int(ing.qty):
				var h: Dictionary = s1.items.herb(str(ing.herb), float(ing.min_age) + 10.0)
				h["owner_id"] = s1.player.id
				s1.db.add("items", h)
		else:
			var bh: String = Alchemy.basic_herb(gd, str(ing.element))
			for _q in 6:
				var h2: Dictionary = s1.items.herb(bh, 30.0)
				h2["owner_id"] = s1.player.id
				s1.db.add("items", h2)
	var cr: Dictionary = s1.craft("tu_khi_dan")
	assert_true(bool(cr.ok), "Life 1 crafted tu_khi_dan")
	assert_true(store.level_of(Codex.BOOK_RECIPES, "tu_khi_dan") == CodexStore.LEVEL_KNOWN, "AC-CK-13: crafted recipe written as known to profile Codex")
	assert_true(s1.k_new_this_life >= 1, "k_new_this_life incremented for first-time known recipe")

	# Life 2: fresh playthrough sharing the same CodexStore, zero herbs & Đan Đạo 0.
	var s2 := _session(gd, store, "one_life", 8403)
	for it in s2.db.items_of(s2.player.id):
		if str(it.get("kind", "")) == "herb":
			s2.db.remove("items", str(it.id))
	var rv: Array = GameQuery.recipes_view(s2)
	var found_r: Dictionary = {}
	for row in rv:
		if str(row.id) == "tu_khi_dan":
			found_r = row
			break
	assert_false(found_r.is_empty(), "tu_khi_dan listed in recipes_view")
	assert_true(bool(found_r.remembered), "AC-CK-13: tu_khi_dan marked remembered in new life")
	assert_false(bool(found_r.usable), "AC-CK-13: still unusable without materials")
	assert_false(bool(s2.craft("tu_khi_dan").ok), "AC-CK-13: crafting still enforces materials/skill requirements")

	s1.shutdown()
	s2.shutdown()


func test_entered_hidden_place_masks_rolled_site_across_games_ac14() -> void:
	var gd := _small_gd()
	var store := CodexStore.new("")
	var s1 := _session(gd, store, "one_life", 8404)
	var authored_slots: Array = gd.file("world_history").get("hidden_slots", [])
	assert_true(authored_slots.size() > 0, "world_history has hidden_slots")
	var slot_id: String = str(authored_slots[0].slot)
	var expected_cands: int = Array(authored_slots[0].candidates).size()

	# Game 1 discovers/enters the hidden place -> Codex records slot_id as known.
	if s1.knowledge != null:
		Discovery.discover(gd, s1.db, s1.knowledge, s1.player, slot_id, s1.year, s1.season, "search")
		s1._codex_note_knowledge_secrets()
	else:
		s1._codex_note(Codex.BOOK_SECRETS, slot_id, CodexStore.LEVEL_KNOWN)
	assert_eq(store.level_of(Codex.BOOK_SECRETS, slot_id), CodexStore.LEVEL_KNOWN, "slot recorded known in Codex")

	# Game 2 (different seed, sharing profile CodexStore): Codex shows ALL authored candidates, NEVER Game 2's rolled site.
	var s2 := _session(gd, store, "one_life", 8499)
	var book_v: Dictionary = GameQuery.codex_book(s2, Codex.BOOK_SECRETS)
	var entries: Array = Array(book_v.get("entries", []))
	assert_eq(entries.size(), 1, "AC-CK-14: known hidden place visible in Codex book")
	assert_eq(str(entries[0].id), slot_id, "slot id matches")
	assert_eq(Array(entries[0].candidates).size(), expected_cands, "AC-CK-14: all authored candidate sites listed")
	for cand in Array(entries[0].candidates):
		assert_false(cand.has("rolled"), "AC-CK-14: no rolled marker exposed")
		assert_false(cand.has("place_id"), "AC-CK-14: no live world place_id exposed")
	if s2.knowledge != null:
		assert_false(s2.knowledge.found.has(slot_id), "AC-CK-14: Game 2 has not auto-discovered the hidden place")

	s1.shutdown()
	s2.shutdown()
