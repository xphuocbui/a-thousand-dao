extends DaoTestSuite
## Codex domain unit tests: 10-book metadata, Fated vs Self-made/cheated writing
## gate (AC-CK-12), remembered recipe lookup (AC-CK-13), hidden-place candidate
## masking (AC-CK-14), variant root tier reveal, removed-id hiding, and hidden history.


func _char(birth_mode: String = "thien_dinh", char_name: String = "Lâm") -> Character:
	var c := Character.new()
	c.name = char_name
	c.birth_mode = birth_mode
	c.origin = "tan_tu"
	c.realm_index = 1
	c.stage = 0
	c.age = 38.0
	return c


func test_meta_codex_defines_all_ten_books() -> void:
	var gd := game_data()
	var codex := Codex.new(gd, CodexStore.new())
	var metas: Array = codex.books_meta()
	assert_eq(metas.size(), 10, "meta_codex.json defines all 10 Codex books")
	var ids: Array = metas.map(func(b): return str(b.id))
	for expected_id in Codex.ALL_BOOKS:
		assert_true(ids.has(expected_id), "book %s present in meta_codex.json" % expected_id)
	assert_false(bool(codex.book_meta(Codex.BOOK_LIVES).get("counts_for_karma", true)), "Lives book excluded from K_new karma")


func test_ac_ck_12_writing_gate_fated_vs_self_made_and_cheated() -> void:
	var gd := game_data()
	var store := CodexStore.new()
	var codex := Codex.new(gd, store)

	# Self-made life cannot write knowledge entries.
	var self_made := _char("tu_dinh", "Tự Định")
	assert_false(Codex.can_write(self_made, false), "Self-made cannot write")
	var k_self: bool = codex.record(Codex.BOOK_RECIPES, "tu_khi_dan", CodexStore.LEVEL_KNOWN, self_made, false, 1201)
	assert_false(k_self, "Self-made craft does not mark newly known")
	assert_eq(store.level_of(Codex.BOOK_RECIPES, "tu_khi_dan"), CodexStore.LEVEL_NONE, "AC-CK-12: Self-made writes nothing")

	# Cheated Fated life cannot write knowledge entries.
	var fated := _char("thien_dinh", "Thiên Định")
	assert_false(Codex.can_write(fated, true), "Cheated Fated cannot write")
	var k_cheat: bool = codex.record(Codex.BOOK_RECIPES, "tu_khi_dan", CodexStore.LEVEL_KNOWN, fated, true, 1201)
	assert_false(k_cheat, "Cheated craft does not mark newly known")
	assert_eq(store.level_of(Codex.BOOK_RECIPES, "tu_khi_dan"), CodexStore.LEVEL_NONE, "AC-CK-12: cheated writes nothing")

	# Uncheated Fated life writes immediately and returns newly_known = true once.
	assert_true(Codex.can_write(fated, false), "Uncheated Fated can write")
	var k_first: bool = codex.record(Codex.BOOK_RECIPES, "tu_khi_dan", CodexStore.LEVEL_KNOWN, fated, false, 1202)
	assert_true(k_first, "AC-CK-12: first Fated craft returns newly_known = true")
	assert_eq(store.level_of(Codex.BOOK_RECIPES, "tu_khi_dan"), CodexStore.LEVEL_KNOWN, "AC-CK-12: recipe recorded known at once")
	var k_second: bool = codex.record(Codex.BOOK_RECIPES, "tu_khi_dan", CodexStore.LEVEL_KNOWN, fated, false, 1203)
	assert_false(k_second, "second Fated craft does not recount newly_known")

	# Lives chronicle ALWAYS writes on death — even for Self-made and cheated lives.
	var llm := LlmService.new(gd)
	llm.enabled = false
	var s := GameSession.new(gd, llm, TestFixtures.tree())
	s.new_game(4242, {"mode": "custom", "name": "Tự Định", "gender": "male", "origin": "tan_tu", "thien_phu": {}, "purities": {"hoa": 60}, "variants": []})
	s.cheated = true
	s.epitaph_text = "Fell while testing."
	var life_rec: Dictionary = codex.record_life(s, "Old age", "one_life", "pt_self_1")
	assert_eq(store.lives.size(), 1, "AC-CK-12: Lives entry written even for Self-made cheated life")
	assert_eq(str(life_rec.playthrough_id), "pt_self_1", "Lives entry records playthrough_id")
	assert_eq(str(life_rec.birth_mode), "tu_dinh", "Lives entry records birth_mode")


func test_ac_ck_13_remembered_recipes_lookup() -> void:
	var gd := game_data()
	var codex := Codex.new(gd, CodexStore.new())
	var c := _char("thien_dinh")

	# Seen recipe is not yet remembered/known.
	codex.record(Codex.BOOK_RECIPES, "tu_khi_dan", CodexStore.LEVEL_SEEN, c, false, 1201)
	assert_true(codex.is_seen(Codex.BOOK_RECIPES, "tu_khi_dan"), "seen recipe is seen")
	assert_false(codex.is_recipe_known("tu_khi_dan"), "seen recipe is not yet known")
	assert_false(codex.is_recipe_remembered("tu_khi_dan"), "seen recipe is not yet remembered")
	assert_eq(codex.remembered_recipes().size(), 0, "no remembered recipes yet")

	# Crafting promotes it to known -> remembered across lives.
	codex.record(Codex.BOOK_RECIPES, "tu_khi_dan", CodexStore.LEVEL_KNOWN, c, false, 1202)
	assert_true(codex.is_recipe_known("tu_khi_dan"), "crafted recipe is known")
	assert_true(codex.is_recipe_remembered("tu_khi_dan"), "crafted recipe is remembered")
	var rem: Array = codex.remembered_recipes()
	assert_eq(rem.size(), 1, "one remembered recipe returned")
	assert_eq(str(rem[0].id), "tu_khi_dan", "recipe id matches")
	assert_true(bool(rem[0].remembered), "recipe marked remembered")


func test_ac_ck_14_hidden_place_candidate_masking_never_exposes_rolled_site() -> void:
	var gd := game_data()
	var codex := Codex.new(gd, CodexStore.new())
	var c := _char("thien_dinh")

	# Verify authored hidden slot R-1 has 3 candidate sites in world_history.json.
	var authored_slots: Array = gd.file("world_history").get("hidden_slots", [])
	assert_true(authored_slots.size() > 0, "world_history has hidden_slots")
	var slot_rec: Dictionary = authored_slots[0]
	var slot_id: String = str(slot_rec.slot)
	var expected_count: int = Array(slot_rec.candidates).size()
	assert_true(expected_count >= 2, "authored hidden slot has 2-3 candidate sites")

	# Rumour ("seen") does not expose candidate sites yet.
	codex.record(Codex.BOOK_SECRETS, slot_id, CodexStore.LEVEL_SEEN, c, false, 1201)
	assert_eq(codex.hidden_place_candidates(slot_id).size(), 0, "seen-only secret hides candidate sites")

	# Entering ("known") exposes ALL authored candidate sites and NEVER any rolled site marker.
	codex.record(Codex.BOOK_SECRETS, slot_id, CodexStore.LEVEL_KNOWN, c, false, 1202)
	var cands: Array = codex.hidden_place_candidates(slot_id)
	assert_eq(cands.size(), expected_count, "AC-CK-14: returns all authored candidate sites")
	for cand in cands:
		assert_false(cand.has("rolled"), "AC-CK-14: candidate never leaks rolled flag")
		assert_false(cand.has("chosen"), "AC-CK-14: candidate never leaks chosen flag")
		assert_false(cand.has("place_id"), "AC-CK-14: candidate never leaks live world place_id")
		assert_true(int(cand.region_id) > 0, "candidate carries region_id")
		assert_true(str(cand.region_name) != "", "candidate carries region_name")

	var regs: Array = codex.hidden_place_candidate_regions(slot_id)
	assert_true(regs.size() >= 1, "deduplicated candidate regions returned")

	# Visible entries in secrets book also carry only candidate list, never a rolled site.
	var vis: Array = codex.visible_entries(Codex.BOOK_SECRETS)
	assert_eq(vis.size(), 1, "one visible secret entry")
	assert_eq(Array(vis[0].candidates).size(), expected_count, "visible entry exposes all candidate sites")


func test_variant_root_seen_vs_known_reveal_and_hidden_history() -> void:
	var gd := game_data()
	var codex := Codex.new(gd, CodexStore.new())
	var c := _char("thien_dinh")

	# Seen variant root reveals description only, hiding formation conditions.
	codex.record(Codex.BOOK_VARIANTS, "loi", CodexStore.LEVEL_SEEN, c, false, 1201)
	var seen_v: Dictionary = codex.variant_info("loi")
	assert_eq(str(seen_v.level), CodexStore.LEVEL_SEEN, "variant level is seen")
	assert_true(str(seen_v.desc) != "", "seen variant shows description")
	assert_false(bool(seen_v.formation_known), "seen variant hides formation conditions")
	assert_eq(Array(seen_v.requires).size(), 0, "seen variant hides required base elements")

	# Known variant root reveals formation conditions.
	codex.record(Codex.BOOK_VARIANTS, "loi", CodexStore.LEVEL_KNOWN, c, false, 1202)
	var known_v: Dictionary = codex.variant_info("loi")
	assert_true(bool(known_v.formation_known), "known variant reveals formation conditions")
	assert_eq(Array(known_v.requires), ["hoa", "kim"], "known Thunder root reveals Fire + Metal")

	# Hidden history event uncovered in Codex.
	assert_false(codex.is_history_uncovered("C001"), "unlearned history not uncovered")
	codex.record(Codex.BOOK_HISTORY, "C001", CodexStore.LEVEL_KNOWN, c, false, 1202)
	assert_true(codex.is_history_uncovered("C001"), "uncovered history event visible to future lives")


func test_removed_authored_id_kept_in_store_but_hidden_until_returned() -> void:
	# Clone registry so we never mutate shared game_data().
	var base_gd := game_data()
	var files_copy: Dictionary = {}
	for k in base_gd.registry.files():
		if str(k) in ["meta_codex", "items_recipes", "items_herbs", "items_materials", "items_artifacts", "items_named", "items_cong_phap", "character_elements", "character_attributes", "world_generation", "cultivation_realms"]:
			files_copy[k] = Dictionary(base_gd.registry.files()[k]).duplicate(true)
	var reg := DataRegistry.from_files(files_copy)
	var gd := GameData.new()
	gd.setup(reg)

	var store := CodexStore.new()
	var codex := Codex.new(gd, store)
	var c := _char("thien_dinh")
	codex.record(Codex.BOOK_RECIPES, "tu_khi_dan", CodexStore.LEVEL_KNOWN, c, false, 1201)
	# Also store a legacy/removed recipe id directly.
	codex.record(Codex.BOOK_RECIPES, "retired_elixir_v0", CodexStore.LEVEL_KNOWN, c, false, 1201)

	assert_eq(store.level_of(Codex.BOOK_RECIPES, "retired_elixir_v0"), CodexStore.LEVEL_KNOWN, "removed id stays stored")
	var vis_before: Array = codex.visible_entries(Codex.BOOK_RECIPES)
	var ids_before: Array = vis_before.map(func(e): return str(e.id))
	assert_true(ids_before.has("tu_khi_dan"), "valid id is visible")
	assert_false(ids_before.has("retired_elixir_v0"), "Edge Case: removed authored id is hidden")

	# When the authored id returns in a data update, the entry reappears automatically.
	var recipes_file: Dictionary = gd.file("items_recipes")
	recipes_file["recipes"].append({"id": "retired_elixir_v0", "name": "Retired Elixir", "desc": "Returned."})
	var vis_after: Array = codex.visible_entries(Codex.BOOK_RECIPES)
	var ids_after: Array = vis_after.map(func(e): return str(e.id))
	assert_true(ids_after.has("retired_elixir_v0"), "Edge Case: entry reappears when authored id returns")
