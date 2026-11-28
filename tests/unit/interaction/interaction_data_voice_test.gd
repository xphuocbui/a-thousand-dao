extends DaoTestSuite
## Wave 1 tests for NPC Interaction & Dialogue (#30) + 19 Trait verb: hooks:
## data validation (AC-NI-04), 17 base verbs + 19 traits.json verb_hooks parity,
## generic voice coverage (AC-NI-26), 5-step fallback & deterministic reload (AC-NI-23),
## tone/tie differentiation & same-sect address forms (AC-NI-24), and appended event templates.


func _make_person(id: String, name_v: String, opts: Dictionary = {}) -> Dictionary:
	return {
		"id": id,
		"name": name_v,
		"gender": str(opts.get("gender", "male")),
		"age": float(opts.get("age", 30.0)),
		"alive": true,
		"realm_index": int(opts.get("realm_index", 0)),
		"stage": int(opts.get("stage", 0)),
		"sect_id": str(opts.get("sect_id", "")),
		"sect_rank": str(opts.get("sect_rank", "")),
		"location_id": str(opts.get("location_id", "")),
		"attitude": int(opts.get("attitude", 0)),
		"cast_key": str(opts.get("cast_key", "")),
		"is_player": bool(opts.get("is_player", false)),
		"npc_traits": opts.get("npc_traits", {"personality": [], "calling": "", "fate": [], "gained": []}),
	}


# --- Shipped Data Validation & Parity --------------------------------------------------------------------------------

func test_shipped_data_validates_with_zero_errors() -> void:
	var gd := game_data()
	var errs: Array = InteractionValidator.validate(gd)
	assert_eq(errs, [], "shipped interaction/dialogue/template data must validate cleanly: %s" % str(errs))
	assert_eq(InteractionValidator.validate_all(gd), [], "validate_all alias matches validate")


func test_all_17_base_verbs_and_19_trait_verb_hooks_present_and_synced() -> void:
	var gd := game_data()
	var inter: Dictionary = gd.file(InteractionValidator.INTERACTIONS_FILE)
	var traits_doc: Dictionary = gd.file(NpcTraits.FILE)
	var verbs: Array = Array(inter.get("verbs", []))
	var base_ids: Array = []
	var trait_by_id := {}
	for v in verbs:
		var vd: Dictionary = v as Dictionary
		if str(vd.get("trait_hook", "")) == "":
			base_ids.append(str(vd.id))
		else:
			trait_by_id[str(vd.id)] = vd
	assert_eq(base_ids.size(), 17, "exactly 17 base verbs")
	for expected_base in [
		"greet", "news", "about", "gift", "work", "teach", "help", "trade",
		"spar", "threaten", "provoke", "declare_enmity",
		"companion", "disciple", "brotherhood", "dao_lu", "repay",
	]:
		assert_true(base_ids.has(expected_base), "base verb '%s' present" % expected_base)

	var hooks: Array = Array(traits_doc.get("verb_hooks", []))
	assert_eq(hooks.size(), 19, "19 verb_hooks in traits.json")
	assert_eq(trait_by_id.size(), 19, "exactly 19 trait verbs in npc_interactions.json")
	for h in hooks:
		var hd: Dictionary = h as Dictionary
		var hid: String = str(hd.id)
		assert_true(trait_by_id.has(hid), "trait verb '%s' exists in npc_interactions.json" % hid)
		var vd: Dictionary = trait_by_id[hid]
		assert_eq(str(vd.trait_hook), "verb:" + hid, "trait_hook matches for %s" % hid)
		assert_eq(str(vd.source_trait), str(hd.trait), "source_trait synced for %s" % hid)
		assert_eq(str(vd.side), str(hd.side), "side synced for %s" % hid)


# --- AC-NI-04: Validator rejects unknown condition/effect naming the verb --------------------------------------------

func test_validator_rejects_unknown_condition_or_effect_naming_verb_ac_ni_04() -> void:
	var gd := game_data()
	var inter: Dictionary = gd.file(InteractionValidator.INTERACTIONS_FILE)
	var lines_doc: Dictionary = gd.file(InteractionValidator.LINES_FILE)

	var bad_cond: Dictionary = inter.duplicate(true)
	(bad_cond.verbs[1].requirements as Array).append({"type": "imaginary_condition_xyz"})
	var e_cond: Array = InteractionValidator.validate(gd, bad_cond, lines_doc)
	assert_true(e_cond.any(func(s): return str(s).contains("news") and str(s).contains("imaginary_condition_xyz")),
		"unknown condition error names verb 'news': %s" % str(e_cond))

	var bad_fx: Dictionary = inter.duplicate(true)
	(bad_fx.verbs[5].accept_effects as Array).append({"type": "summon_meteor_xyz"})
	var e_fx: Array = InteractionValidator.validate(gd, bad_fx, lines_doc)
	assert_true(e_fx.any(func(s): return str(s).contains("teach") and str(s).contains("summon_meteor_xyz")),
		"unknown effect error names verb 'teach': %s" % str(e_fx))

	var bad_side: Dictionary = inter.duplicate(true)
	for v in bad_side.verbs:
		if str(v.id) == "invoke_clan":
			v["side"] = "other"
	var e_side: Array = InteractionValidator.validate(gd, bad_side, lines_doc)
	assert_true(e_side.any(func(s): return str(s).contains("invoke_clan")),
		"mismatched trait hook side reported: %s" % str(e_side))

	var bad_tok: Dictionary = lines_doc.duplicate(true)
	(bad_tok.lines.greet.accept.generic as Array).append("Xin chào {broken_placeholder}.")
	var e_tok: Array = InteractionValidator.validate(gd, inter, bad_tok)
	assert_true(e_tok.any(func(s): return str(s).contains("{broken_placeholder}")),
		"unsupported placeholder rejected: %s" % str(e_tok))

	var missing_gen: Dictionary = lines_doc.duplicate(true)
	missing_gen.lines.spar.accept.erase("generic")
	var e_gen: Array = InteractionValidator.validate(gd, inter, missing_gen)
	assert_true(e_gen.any(func(s): return str(s).contains("spar") and str(s).contains("generic")),
		"missing generic line rejected: %s" % str(e_gen))


# --- AC-NI-26: Generic line coverage & zero leftover {token} markers -------------------------------------------------

func test_shipped_library_has_generic_line_for_every_verb_and_result_ac_ni_26() -> void:
	var gd := game_data()
	var db := WorldDB.new()
	var place_id: String = db.add("places", {"name": "Thanh Vân Trấn", "type": "tran", "region": "Đông Hoang"})
	var sect_id: String = db.add("sects", {"name": "Tùng Đào Cung"})
	var player := _make_person("p_player", "Hàn Minh", {"gender": "male", "realm_index": 1, "location_id": place_id})
	var npc := _make_person("p_npc", "Lâm Hạc", {"gender": "male", "realm_index": 1, "sect_id": sect_id, "location_id": place_id, "attitude": 15, "npc_traits": {"personality": ["calm"]}})
	db.add("people", player)
	db.add("people", npc)

	var inter: Dictionary = gd.file(InteractionValidator.INTERACTIONS_FILE)
	var lines_doc: Dictionary = gd.file(InteractionValidator.LINES_FILE)
	var extra_subs := {
		"{rumour}": "có bí cảnh mở ở phía đông",
		"{target}": "Trần Vô Kỵ",
		"{item}": "Hỏa Linh Chi",
		"{amount}": "120",
		"{lesson}": "Thanh Phong Kiếm Quyết",
	}
	var checked_pairs: int = 0
	for v in inter.verbs:
		var vid: String = str(v.id)
		var req_res: Array = Array(v.get("required_results", ["accept", "refuse"]))
		assert_true(lines_doc.lines.has(vid), "lines has verb %s" % vid)
		for r in req_res:
			var rkey: String = str(r)
			var gen: Array = Array(lines_doc.lines[vid][rkey].get("generic", []))
			assert_true(not gen.is_empty(), "%s.%s has generic lines" % [vid, rkey])
			var reply: Dictionary = DialogueVoice.pick_line(gd, db, npc, player, vid, rkey, extra_subs, 777, 12)
			var txt: String = str(reply.text)
			assert_true(txt.strip_edges() != "", "%s.%s renders non-empty text" % [vid, rkey])
			assert_false(txt.contains("{") or txt.contains("}"), "%s.%s has zero leftover tokens: %s" % [vid, rkey, txt])
			checked_pairs += 1
	assert_true(checked_pairs >= 76, "verified all verb x result pairs (%d)" % checked_pairs)


# --- AC-NI-23: 5-step fallback chain & deterministic reload ----------------------------------------------------------

func test_voice_fallback_chain_and_deterministic_reload_variant_ac_ni_23() -> void:
	var gd := game_data()
	var db := WorldDB.new()
	var player := _make_person("p_pl", "Lý An", {"realm_index": 0})
	var haughty_elder := _make_person("p_el", "Chu Huyền", {
		"realm_index": 2,
		"attitude": 40,
		"npc_traits": {"personality": ["arrogant"]},
	})
	db.add("people", player)
	db.add("people", haughty_elder)

	# AC-NI-23 exact scenario: no own line, Haughty tone, friendly band, senior; library has only (band) and generic.
	var custom_lines := {
		"tone_by_trait": {"arrogant": "haughty"},
		"address_table": gd.file(InteractionValidator.LINES_FILE).address_table,
		"person_lines": {},
		"lines": {
			"teach": {
				"accept": {
					"friendly": ["Lời thân tình A cho {you}.", "Lời thân tình B cho {you}.", "Lời thân tình C cho {you}."],
					"generic": ["Lời chung cho {you}."],
				},
			},
		},
	}
	var first: Dictionary = DialogueVoice.pick_line(gd, db, haughty_elder, player, "teach", "accept", {}, 1001, 5, custom_lines)
	assert_eq(str(first.tone), "haughty", "tone resolved as haughty")
	assert_eq(str(first.band), "friendly", "band resolved as friendly")
	assert_eq(str(first.seniority), "senior", "seniority resolved as senior")
	assert_eq(str(first.key), "friendly", "fallback selected (band) line 'friendly'")
	assert_eq(int(first.fallback_level), 3, "fallback_level == 3 for band")
	assert_true(str(first.text).begins_with("Lời thân tình"), "rendered friendly band line: %s" % str(first.text))

	# Reload determinism: identical inputs always produce the exact same variant and text.
	var reload: Dictionary = DialogueVoice.pick_line(gd, db, haughty_elder, player, "teach", "accept", {}, 1001, 5, custom_lines)
	assert_eq(reload.variant, first.variant, "reload preserves variant index")
	assert_eq(reload.text, first.text, "reload preserves exact rendered text")

	# Level 0 (person override), Level 1 (tone:band:seniority), Level 2 (tone:band), Level 4 (generic).
	var rich_lines: Dictionary = custom_lines.duplicate(true)
	rich_lines.person_lines["mac_quy_khu"] = {"teach": {"accept": ["Riêng Mạc lão cho {you}."]} }
	rich_lines.lines.teach.accept["haughty:friendly:senior"] = ["Cao ngạo trưởng bối cho {you}."]
	rich_lines.lines.teach.accept["haughty:friendly"] = ["Cao ngạo thân tình cho {you}."]
	rich_lines.lines.teach["refuse"] = {"generic": ["Từ chối chung."]}

	var l1: Dictionary = DialogueVoice.pick_line(gd, db, haughty_elder, player, "teach", "accept", {}, 1001, 5, rich_lines)
	assert_eq(int(l1.fallback_level), 1, "level 1 tone:band:seniority")
	assert_eq(str(l1.key), "haughty:friendly:senior")

	var peer_haughty := _make_person("p_ph", "Tôn Ngạo", {"realm_index": 0, "attitude": 40, "npc_traits": {"personality": ["arrogant"]}})
	var l2: Dictionary = DialogueVoice.pick_line(gd, db, peer_haughty, player, "teach", "accept", {}, 1001, 5, rich_lines)
	assert_eq(int(l2.fallback_level), 2, "level 2 tone:band")
	assert_eq(str(l2.key), "haughty:friendly")

	var l4: Dictionary = DialogueVoice.pick_line(gd, db, haughty_elder, player, "teach", "refuse", {}, 1001, 5, rich_lines)
	assert_eq(int(l4.fallback_level), 4, "level 4 generic")
	assert_eq(str(l4.key), "generic")

	var famous := _make_person("p_mk", "Mạc Quy Khư", {"realm_index": 4, "attitude": 40, "cast_key": "mac_quy_khu", "npc_traits": {"personality": ["reclusive"]}})
	var l0: Dictionary = DialogueVoice.pick_line(gd, db, famous, player, "teach", "accept", {}, 1001, 5, rich_lines)
	assert_eq(int(l0.fallback_level), 0, "level 0 person override")
	assert_eq(str(l0.key), "person:mac_quy_khu")


# --- Tone & Tie Distinction + AC-NI-24 Same-Sect Address Forms -------------------------------------------------------

func test_voice_distinguishes_tones_and_relation_ties() -> void:
	var gd := game_data()
	var db := WorldDB.new()
	var player := _make_person("p_pl", "Trần Bình", {"gender": "male", "realm_index": 1, "age": 24.0, "is_player": true})
	var kind_npc := _make_person("p_kind", "Diệp Thanh", {"gender": "female", "realm_index": 1, "attitude": 20, "npc_traits": {"personality": ["compassionate"]}})
	var proud_npc := _make_person("p_proud", "Vương Cửu", {"gender": "male", "realm_index": 2, "attitude": 40, "npc_traits": {"personality": ["arrogant"]}})
	var hostile_npc := _make_person("p_hate", "Lục Sát", {"gender": "male", "realm_index": 1, "attitude": -50, "npc_traits": {"personality": ["cruel"]}})
	db.add("people", player)
	db.add("people", kind_npc)
	db.add("people", proud_npc)
	db.add("people", hostile_npc)

	var r_kind: Dictionary = DialogueVoice.pick_line(gd, db, kind_npc, player, "greet", "accept", {}, 42, 1)
	var r_proud: Dictionary = DialogueVoice.pick_line(gd, db, proud_npc, player, "greet", "accept", {}, 42, 1)
	var r_hostile: Dictionary = DialogueVoice.pick_line(gd, db, hostile_npc, player, "greet", "accept", {}, 42, 1)

	assert_eq(str(r_kind.tone), "gentle", "compassionate maps to gentle")
	assert_eq(str(r_proud.tone), "haughty", "arrogant maps to haughty")
	assert_eq(str(r_hostile.tone), "cold", "cruel maps to cold")
	assert_eq(str(r_hostile.band), "hostile", "attitude -50 is hostile")
	assert_true(str(r_kind.text) != str(r_proud.text), "kind vs proud produce distinct lines")
	assert_true(str(r_kind.text) != str(r_hostile.text), "kind vs hostile produce distinct lines")
	assert_true(str(r_proud.text) != str(r_hostile.text), "proud vs hostile produce distinct lines")
	assert_eq(str(r_hostile.forms.you), "ngươi", "hostile uses ngươi")
	assert_eq(str(r_hostile.forms.self), "ta", "hostile uses ta")

	# Master/disciple, dao_lu, and ket_nghia ties produce their dedicated address forms.
	var master_npc := _make_person("p_m", "Trương Trưởng Lão", {"gender": "male", "realm_index": 3, "attitude": 45})
	var partner_npc := _make_person("p_dl", "Tô Thanh Yên", {"gender": "female", "realm_index": 1, "attitude": 75})
	var sib_npc := _make_person("p_kn", "Tiêu Phong", {"gender": "male", "realm_index": 1, "age": 30.0, "attitude": 55})
	db.add("people", master_npc)
	db.add("people", partner_npc)
	db.add("people", sib_npc)
	assert_true(bool(Ties.set_master(gd, db, player.id, master_npc.id, 1).ok), "su_do tie created")
	assert_true(bool(Ties.add_pinned(gd, db, player.id, partner_npc.id, "dao_lu", 1).ok), "dao_lu tie created")
	assert_true(bool(Ties.add_pinned(gd, db, player.id, sib_npc.id, "ket_nghia", 1).ok), "ket_nghia tie created")

	var f_master: Dictionary = DialogueVoice.address_forms(gd, db, master_npc, player, "friendly", "courteous", "senior")
	assert_eq(str(f_master.you), "đồ nhi", "master addresses disciple as đồ nhi")
	assert_eq(str(f_master.self), "vi sư", "master calls self vi sư")

	var f_dl: Dictionary = DialogueVoice.address_forms(gd, db, partner_npc, player, "close", "gentle", "peer")
	assert_eq(str(f_dl.you), "đạo lữ", "dao_lu addresses partner as đạo lữ")

	var f_kn: Dictionary = DialogueVoice.address_forms(gd, db, sib_npc, player, "friendly", "wild", "peer")
	assert_eq(str(f_kn.you), "hiền đệ", "older sworn brother addresses male player as hiền đệ")
	assert_eq(str(f_kn.self), "vi huynh", "older sworn brother calls self vi huynh")


func test_address_forms_same_sect_senior_su_de_su_huynh_ac_ni_24() -> void:
	var gd := game_data()
	var db := WorldDB.new()
	var sect_id: String = db.add("sects", {"name": "Thiên Xu Tông"})
	var pl_male := _make_person("p_plm", "Lâm Dật", {"gender": "male", "realm_index": 0, "sect_id": sect_id, "sect_rank": "ngoai_mon"})
	var pl_female := _make_person("p_plf", "Lâm Tuyết", {"gender": "female", "realm_index": 0, "sect_id": sect_id, "sect_rank": "ngoai_mon"})
	var senior_bro := _make_person("p_sb", "Tần Hạo", {"gender": "male", "realm_index": 0, "sect_id": sect_id, "sect_rank": "noi_mon", "attitude": 20, "npc_traits": {"personality": ["calm"]}})
	var senior_sis := _make_person("p_ss", "Bạch Linh", {"gender": "female", "realm_index": 0, "sect_id": sect_id, "sect_rank": "noi_mon", "attitude": 20, "npc_traits": {"personality": ["calm"]}})
	db.add("people", pl_male)
	db.add("people", pl_female)
	db.add("people", senior_bro)
	db.add("people", senior_sis)

	assert_eq(DialogueVoice.seniority_of(gd, db, senior_bro, pl_male), "senior", "noi_mon outranks ngoai_mon even at same realm")
	var fm: Dictionary = DialogueVoice.address_forms(gd, db, senior_bro, pl_male, "warm", "courteous", "senior")
	assert_eq(str(fm.you), "sư đệ", "AC-NI-24: male junior addressed as sư đệ")
	assert_eq(str(fm.self), "sư huynh", "AC-NI-24: male senior calls self sư huynh")

	var ff: Dictionary = DialogueVoice.address_forms(gd, db, senior_sis, pl_female, "warm", "courteous", "senior")
	assert_eq(str(ff.you), "sư muội", "AC-NI-24: female junior addressed as sư muội")
	assert_eq(str(ff.self), "sư tỷ", "AC-NI-24: female senior calls self sư tỷ")


# --- Appended Event Templates Load, Stay Isolated From Random Pool & Normalize Cleanly -------------------------------

func test_appended_event_templates_load_and_normalize_cleanly() -> void:
	var gd := game_data()
	var llm := LlmService.new(gd)
	llm.enabled = false
	var s := GameSession.new(gd, llm, TestFixtures.tree())
	s.new_game(5151, {"mode": "roll", "name": "Đào", "gender": "male", "origin": "tan_tu"})
	s.pending_event = {}

	var tpls: Array = Array(gd.event_templates().get("templates", []))
	var by_id := {}
	for t in tpls:
		by_id[str(t.id)] = t
	assert_true(by_id.has("lao_gia_ban_thao"), "existing template lao_gia_ban_thao preserved")
	assert_true(by_id.has("dao_an_co_vat"), "existing template dao_an_co_vat preserved")

	var expected_new := [
		"loan_collection",
		"provoke_duel",
		"threat_ambush",
		"on_talk_mac_quy_khu_first",
		"on_talk_thoi_khinh_hong_retreat",
		"on_talk_so_ngoc_ho_vessel",
		"on_talk_phan_vat_hoa_ledger",
		"on_talk_spared_rival",
	]
	var ctx: Dictionary = EventContext.build(s.player, s.gd, s.db, s.sheet(), s.year, s.season, "vi")
	var elig_ids := {}
	for et in s.templates.eligible(ctx):
		elig_ids[str(et.id)] = true

	var npc_id: String = s.builds.create_person(s.rng, {"realm_index": 0, "archetype": "tan_tu", "location_id": s.player.location_id})
	for tid in expected_new:
		assert_true(by_id.has(tid), "appended template '%s' loaded" % tid)
		assert_false(elig_ids.has(tid), "hooked template '%s' excluded from random eligible() pool" % tid)
		var raw: Dictionary = s.templates.generate(ctx, rng(99), tid)
		assert_false(raw.is_empty(), "template '%s' generates cleanly by id" % tid)
		raw["npc"] = {"id_resolved": npc_id}
		var norm: Dictionary = s.validator.normalize(raw, ctx, rng(100), str(raw.source))
		assert_true(bool(norm.ok), "template '%s' normalizes ok: %s" % [tid, str(norm.get("error", ""))])
		assert_eq(norm.warnings, [], "template '%s' normalizes with zero warnings: %s" % [tid, str(norm.warnings)])
