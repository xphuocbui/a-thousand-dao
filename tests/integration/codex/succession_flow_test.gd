extends DaoTestSuite
## Codex & Karmic Carryover (#12) Continue-mode Succession integration tests:
## AC-CK-04 (world death settlement S8b & Tick rule 9 BEFORE offering heirs; killer excluded),
## AC-CK-05 (heir keeps realm, items/estate, ties, sect, place, traits; no starting Phá Cảnh Phù),
## AC-CK-06 (rebirth runs 64 world tick seasons, spawns age-16 stranger, world history advances),
## AC-CK-11 (lineage rebirth into sect destroyed during 64 ticks refunds lineage_cost & falls back to tan_tu).


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


func _continue_session(gd: GameData, store: CodexStore, origin: String = "tan_tu", seed_v: int = 8201) -> GameSession:
	var llm := LlmService.new(gd)
	llm.enabled = false
	var s := GameSession.new(gd, llm, TestFixtures.tree(), store)
	s.ratings_background = false
	s.new_game(seed_v, {
		"mode": "roll", "name": "Lâm Tiền Bối", "gender": "male", "origin": origin,
		"playthrough_mode": "continue",
	})
	s.pending_event = {}
	return s


func _make_npc(s: GameSession, name_v: String, realm_idx: int, age_v: float) -> String:
	var pid: String = s.builds.create_person(s.rng, {
		"realm_index": realm_idx, "stage": 0, "age": age_v,
		"location_id": s.player.location_id, "sect_id": s.player.sect_id,
	})
	var rec: Dictionary = s.db.get_record("people", pid)
	rec["name"] = name_v
	s.db.put("people", rec)
	return pid


func test_continue_death_settles_world_and_offers_eligible_heirs_ac04() -> void:
	var gd := _small_gd()
	var store := CodexStore.new("")
	var s := _continue_session(gd, store, "tan_tu", 8201)
	s.player.realm_index = 2   # Kết Đan -> earns 2 karma on death
	s.player.linh_thach = 500
	s.sync_player()
	var dead_id: String = s.player.id
	var p_rec: Dictionary = s.db.get_record("people", dead_id)

	# 2 living children + 3 living disciples (1 of whom is the known killer).
	var child1: String = _make_npc(s, "Lâm Con Một", 0, 20.0)
	var child2: String = _make_npc(s, "Lâm Con Hai", 1, 28.0)
	Families.link(gd, s.db, s.db.get_record("people", child1), p_rec, s.season_index(), true)
	Families.link(gd, s.db, s.db.get_record("people", child2), p_rec, s.season_index(), true)

	var disc1: String = _make_npc(s, "Đồ Đệ Một", 0, 22.0)
	var disc2: String = _make_npc(s, "Đồ Đệ Hai", 1, 32.0)
	var killer_disc: String = _make_npc(s, "Nghịch Đồ", 1, 35.0)
	for did in [disc1, disc2, killer_disc]:
		Ties.set_master(gd, s.db, did, dead_id, s.season_index())

	# Give player an unbound artifact to verify world death item settlement.
	var sw: Dictionary = s.items.artifact(s.rng, 1, 2, "kim", "phi_kiem", "Thanh Phong Kiếm")
	sw["owner_id"] = dead_id
	var sw_id: String = s.db.add("items", sw)

	s._end_life("Bị nghịch đồ sát hại", killer_disc, "duel")

	assert_eq(s.playthrough_status, "succession", "AC-CK-04: Continue enters succession status")
	assert_eq(s.karma, 2, "Kết Đan life earned 2 karma")
	# World death settlement ran BEFORE offering succession:
	assert_eq(s.db.ties_of(dead_id).size(), 0, "AC-CK-04: S8b cleaned up dead player's ties before succession")
	assert_eq(str(s.db.get_record("items", sw_id).get("owner_id", "")), killer_disc, "AC-CK-04: killer looted unbound item in world death settlement")
	assert_eq(s.player.linh_thach, 0, "dead player purse settled")

	var opts: Dictionary = GameQuery.succession_view(s)
	var heir_ids: Array = Array(opts.heirs).map(func(h): return str(h.id))
	assert_eq(heir_ids.size(), 4, "AC-CK-04: 2 children + 2 non-killer disciples offered (got %s)" % str(heir_ids))
	assert_true(heir_ids.has(child1) and heir_ids.has(child2), "both living children offered")
	assert_true(heir_ids.has(disc1) and heir_ids.has(disc2), "both non-killer disciples offered")
	assert_false(heir_ids.has(killer_disc), "AC-CK-04: known killer excluded from heirs")
	assert_true(Array(opts.origins).size() >= 3, "rebirth origins offered")
	s.shutdown()


func test_heir_succession_preserves_state_and_gives_no_starting_talismans_ac05() -> void:
	var gd := _small_gd()
	var store := CodexStore.new("")
	var s := _continue_session(gd, store, "tong_mon", 8202)
	s.player.realm_index = 2
	s.sync_player()
	var dead_id: String = s.player.id
	var disc_id: String = _make_npc(s, "Kế Thừa Đồ Đệ", 1, 40.0)
	Ties.set_master(gd, s.db, disc_id, dead_id, s.season_index())

	# Give the heir a distinct item, tie with a friend, and custom trait.
	var friend_id: String = _make_npc(s, "Đạo Hữu Của Đồ Đệ", 1, 38.0)
	var tie_r: Dictionary = Ties.add_pinned(gd, s.db, disc_id, friend_id, "ket_nghia", s.season_index(), true)
	assert_true(bool(tie_r.ok), "setup ket_nghia tie on heir succeeded: %s" % str(tie_r.get("reason", "")))
	var heir_item: Dictionary = s.items.artifact(s.rng, 1, 1, "hoa", "phi_kiem", "Hỏa Văn Kiếm")
	heir_item["owner_id"] = disc_id
	var heir_item_id: String = s.db.add("items", heir_item)
	var dead_item: Dictionary = s.items.artifact(s.rng, 2, 2, "kim", "phi_kiem", "Di Bảo Sư Phụ")
	dead_item["owner_id"] = dead_id
	var dead_item_id: String = s.db.add("items", dead_item)

	var disc_before: Dictionary = s.db.get_record("people", disc_id).duplicate(true)
	s._end_life("Tọa hóa", "", "old_age")
	assert_eq(s.karma, 2, "2 karma earned; Trúc Cơ heir costs 1")
	var pha_canh_before_succ: int = 0
	for it in s.db.items_of(disc_id):
		if str(it.get("kind", "")) == "talisman" and str(it.get("template", "")) == "pha_canh":
			pha_canh_before_succ += int(it.get("qty", 1))

	var succ: Dictionary = s.succeed_heir(disc_id, {})
	assert_true(bool(succ.ok), "AC-CK-05: heir succession succeeded: %s" % str(succ.lines))
	assert_eq(s.playthrough_status, "active", "playthrough active again")
	assert_false(s.life_over, "life_over cleared")
	assert_eq(s.player.id, disc_id, "AC-CK-05: player is now the heir")
	assert_eq(s.player.realm_index, 1, "AC-CK-05: heir keeps own Trúc Cơ realm")
	assert_eq(s.player.sect_id, str(disc_before.sect_id), "AC-CK-05: heir keeps own sect")
	assert_eq(s.player.location_id, str(disc_before.location_id), "AC-CK-05: heir keeps own place")
	assert_eq(s.karma, 1, "Trúc Cơ heir cost 1 karma (2 - 1 = 1 left)")
	assert_true(s.is_heir_life and s.start_realm_this_life == 1, "heir life tracking set")

	# Heir keeps own item + inherited estate item, keeps own tie, and gets NO starting Phá Cảnh Phù.
	var owned_ids: Array = s.db.items_of(s.player.id).map(func(it): return str(it.id))
	assert_true(owned_ids.has(heir_item_id), "AC-CK-05: heir keeps own item")
	assert_true(owned_ids.has(dead_item_id), "AC-CK-05: heir inherited predecessor's unbound item")
	assert_false(s.db.tie_between(disc_id, friend_id).is_empty(), "AC-CK-05: heir keeps existing ties")
	var pha_canh_after_succ: int = 0
	for it in s.db.items_of(s.player.id):
		if str(it.get("kind", "")) == "talisman" and str(it.get("template", "")) == "pha_canh":
			pha_canh_after_succ += int(it.get("qty", 1))
	assert_eq(pha_canh_after_succ, pha_canh_before_succ, "AC-CK-07: succeed_heir grants 0 starting Phá Cảnh Phù")
	assert_true(s.player.perks.size() >= 1, "AC-CK-07: heir received destiny perk")
	s.shutdown()


func test_rebirth_ticks_64_seasons_and_spawns_age_16_ac06() -> void:
	var gd := _small_gd()
	var store := CodexStore.new("")
	var s := _continue_session(gd, store, "tan_tu", 8203)
	var old_id: String = s.player.id
	var year_before: int = s.year
	var season_before: int = s.season
	var events_before: int = s.db.count("events")

	s._end_life("Thọ nguyên cạn kiệt", "", "old_age")
	var reb: Dictionary = s.succeed_rebirth({"name": "Tái Sinh Nhân", "origin": "tan_tu"})
	assert_true(bool(reb.ok), "AC-CK-06: rebirth succeeded: %s" % str(reb.lines))
	assert_eq(int(reb.seasons_passed), 64, "AC-CK-06: exactly 64 seasons passed")
	assert_eq(s.year, year_before + 16, "AC-CK-06: world clock advanced by 16 years")
	assert_eq(s.season, season_before, "same season after 64 seasons (16 full years)")
	assert_true(s.player.id != old_id, "reborn is a brand-new person")
	assert_eq(s.player.age, 16.0, "AC-CK-06: reborn starts at age 16")
	assert_eq(s.player.realm_index, 0, "reborn starts at Luyện Khí")
	assert_false(s.is_heir_life, "not an heir life")
	assert_true(s.db.count("events") > events_before, "AC-CK-06: world chronicle recorded events during the 64-season gap")
	var pha_canh_qty: int = 0
	for it in s.db.items_of(s.player.id):
		if str(it.get("kind", "")) == "talisman" and str(it.get("template", "")) == "pha_canh":
			pha_canh_qty += int(it.get("qty", 1))
	assert_eq(pha_canh_qty, 2, "AC-CK-07: reborn receives 2 starting Phá Cảnh Phù")
	s.shutdown()


func test_destroyed_lineage_during_64_ticks_refunds_karma_and_falls_back_ac11() -> void:
	var gd := _small_gd()
	var store := CodexStore.new("")
	var s := _continue_session(gd, store, "tong_mon", 8204)
	assert_true(s.player.sect_id != "", "precondition: player starts in a sect")
	var old_sect_id: String = s.player.sect_id
	var old_region_id: String = str(s.db.get_record("places", s.player.location_id).get("region_id", ""))
	s.player.realm_index = 3   # Nguyên Anh -> earns 4 karma
	s.sync_player()

	s._end_life("Vẫn lạc", "", "duel")
	assert_eq(s.karma, 4, "4 karma available before lineage rebirth")

	# Destroy the old sect midway through the 64-season rebirth gap.
	var destroy_sect := func() -> void:
		var srec: Dictionary = s.db.get_record("sects", old_sect_id)
		srec["status"] = "fallen"
		s.db.put("sects", srec)

	var reb: Dictionary = s.succeed_rebirth({
		"name": "Cô Nhi Tông Môn",
		"lineage_kind": "sect",
		"on_mid_gap": destroy_sect,
	})
	assert_true(bool(reb.ok), "AC-CK-11: rebirth completed with fallback")
	assert_true(bool(reb.lineage_refunded), "AC-CK-11: lineage_refunded == true")
	assert_eq(int(reb.refund_amount), 3, "AC-CK-11: refunded lineage_cost (3)")
	assert_eq(s.karma, 4, "AC-CK-11: full 3 karma returned (4 - 3 + 3 = 4)")
	assert_eq(s.player.origin, "tan_tu", "AC-CK-11: fell back to tan_tu origin")
	assert_eq(s.player.sect_id, "", "AC-CK-11: no longer in fallen sect")
	var start_region: String = str(s.db.get_record("places", s.player.location_id).get("region_id", ""))
	assert_eq(start_region, old_region_id, "AC-CK-11: placed in the dead life's region")
	s.shutdown()
