extends DaoTestSuite
## Deterministic UI tests for Codex & Karmic Carryover (#12) Wave 3 B3 windows:
## - CodexWindow: 10 books, seen-vs-known ink styling & stated effects (AC-CK-19),
##   variant root formation gating, hidden place candidate-only rumours (AC-CK-14),
##   Lives chronicle list, corruption notice, search filter, book switching.
## - SuccessionScreen: epitaph scroll, karma breakdown (earned + carried), heir cards &
##   unaffordable greying (AC-CK-18, AC-CK-20), Rebirth panel (3 free origins + Lineage
##   sect/clan survival badges & cost), destiny perk extra selector clamped against karma,
##   perk_extra_max, unheld perks, and Self-made mode, End playthrough confirm-in-place,
##   and clean signal emission without mutating GameSession.
## - GameMenu: New Game One Life vs Continue selector & save-slot mode badges (AC-CK-01).
## - Zero built-in Control.tooltip_text on every constructed UI subtree (ADR-0005).

static func _find(root: Node, node_name: String) -> Node:
	return root.find_child(node_name, true, false)


static func _assert_no_builtin_tooltips(suite: DaoTestSuite, root: Node, label: String) -> void:
	var stack: Array = [root]
	while not stack.is_empty():
		var cur: Node = stack.pop_back()
		if cur is Control:
			suite.assert_eq((cur as Control).tooltip_text, "", "%s: %s must have empty tooltip_text (use TooltipLayer)" % [label, cur.name])
		for ch in cur.get_children():
			stack.append(ch)


func _sample_codex_view() -> Dictionary:
	var books := [
		{"id": "recipes", "name": "Đan & Khí Phương (Recipes)", "effect": "Known recipes appear in the craft list from day one.", "seen": 1, "known": 1, "total": 2},
		{"id": "variants", "name": "Biến Dị Linh Căn (Variant Roots)", "effect": "Seen: description. Known: formation conditions.", "seen": 1, "known": 1, "total": 2},
		{"id": "secrets", "name": "Bí Cảnh & Bí Mật (Secrets & Hidden Places)", "effect": "Known: lore and candidate regions/sites as rumours (never this game's rolled site).", "seen": 1, "known": 1, "total": 2},
		{"id": "cast", "name": "Nhân Vật Chí (Fixed Cast)", "effect": "Profile and fates across past lives.", "seen": 1, "known": 0, "total": 1},
		{"id": "history", "name": "Cổ Sử (World History)", "effect": "Learned history and uncovered hidden annals.", "seen": 0, "known": 1, "total": 1},
		{"id": "techniques", "name": "Công Pháp (Techniques)", "effect": "Requirements and description; never the manual itself.", "seen": 1, "known": 0, "total": 1},
		{"id": "items", "name": "Danh Bảo (Named Items)", "effect": "Requirements and description; never the item itself.", "seen": 0, "known": 1, "total": 1},
		{"id": "beasts", "name": "Linh Thú (Spirit Beasts)", "effect": "Kinds, stages and taming traits.", "seen": 0, "known": 0, "total": 0},
		{"id": "herbs", "name": "Linh Thảo (Herbs)", "effect": "Elements, ages and uses.", "seen": 0, "known": 1, "total": 1},
		{"id": "lives", "name": "Ký Lục Kiếp Trước (Lives)", "effect": "Epitaph, chronicle summary, realm, age and cause of death of every life.", "seen": 0, "known": 2, "total": 2},
	]
	var by_book := {
		"recipes": {
			"id": "recipes",
			"name": "Đan & Khí Phương (Recipes)",
			"effect": "Known recipes appear in the craft list from day one.",
			"seen": 1, "known": 1, "total": 2,
			"entries": [
				{"id": "tu_khi_dan", "book": "recipes", "level": "known", "title": "Tụ Khí Đan", "desc": "Basic Qi gathering pill.", "effect": "Known recipes appear in the craft list from day one.", "first_year": 1201, "first_life": "Lâm Phong"},
				{"id": "truc_co_dan", "book": "recipes", "level": "seen", "title": "Trúc Cơ Đan", "desc": "Foundation pill.", "effect": "Known recipes appear in the craft list from day one.", "first_year": 1205, "first_life": "Lâm Phong"},
			],
		},
		"variants": {
			"id": "variants",
			"name": "Biến Dị Linh Căn (Variant Roots)",
			"effect": "Seen: description. Known: formation conditions.",
			"seen": 1, "known": 1, "total": 2,
			"entries": [
				{"id": "bang", "book": "variants", "level": "known", "title": "Băng Linh Căn", "desc": "Ice variant root.", "effect": "Seen: description. Known: formation conditions.", "formation_known": true, "origin": "transmutation", "requires": ["thuy"]},
				{"id": "loi", "book": "variants", "level": "seen", "title": "Lôi Linh Căn", "desc": "Thunder variant root.", "effect": "Seen: description. Known: formation conditions.", "formation_known": false, "origin": "", "requires": []},
			],
		},
		"secrets": {
			"id": "secrets",
			"name": "Bí Cảnh & Bí Mật (Secrets & Hidden Places)",
			"effect": "Known: lore and candidate regions/sites as rumours (never this game's rolled site).",
			"seen": 1, "known": 1, "total": 2,
			"entries": [
				{
					"id": "R-1", "book": "secrets", "level": "known", "title": "R-1 (ancient_ruin)",
					"desc": "Sunken frost hall.",
					"effect": "Known: lore and candidate regions/sites as rumours (never this game's rolled site).",
					"candidates": [
						{"index": 0, "region_id": 1, "region_name": "Bắc Hàn", "tile": [12, 34]},
						{"index": 1, "region_id": 2, "region_name": "Đông Lâm", "tile": [56, 78]},
					],
					"candidate_regions": [
						{"region_id": 1, "region_name": "Bắc Hàn"},
						{"region_id": 2, "region_name": "Đông Lâm"},
					],
				},
				{"id": "R-2", "book": "secrets", "level": "seen", "title": "R-2 (hidden_cave)", "desc": "Rumoured grotto.", "effect": "Known: lore and candidate regions/sites as rumours."},
			],
		},
		"cast": {
			"id": "cast",
			"name": "Nhân Vật Chí (Fixed Cast)",
			"effect": "Profile and fates across past lives.",
			"seen": 1, "known": 0, "total": 1,
			"entries": [
				{"id": "so_ngoc_ho", "book": "cast", "level": "seen", "title": "Sở Ngọc Hồ", "desc": "Elder of Băng Tâm.", "effect": "Profile and fates across past lives.", "fates": [{"year": 1220, "life": "Lâm Phong", "fate": "Met at Frost Lake."}]},
			],
		},
		"history": {"id": "history", "name": "Cổ Sử (World History)", "effect": "Learned history.", "seen": 0, "known": 1, "total": 1, "entries": [{"id": "H-1", "book": "history", "level": "known", "title": "H-1 (Year 800)", "desc": "Ancient war.", "effect": "Learned history."}]},
		"techniques": {"id": "techniques", "name": "Công Pháp (Techniques)", "effect": "Requirements only.", "seen": 1, "known": 0, "total": 1, "entries": [{"id": "t1", "book": "techniques", "level": "seen", "title": "Hàn Băng Quyết", "desc": "Ice art.", "effect": "Requirements only."}]},
		"items": {"id": "items", "name": "Danh Bảo (Named Items)", "effect": "Requirements only.", "seen": 0, "known": 1, "total": 1, "entries": [{"id": "i1", "book": "items", "level": "known", "title": "Thanh Liên Kiếm", "desc": "Lotus sword.", "effect": "Requirements only."}]},
		"beasts": {"id": "beasts", "name": "Linh Thú (Spirit Beasts)", "effect": "Kinds and traits.", "seen": 0, "known": 0, "total": 0, "entries": []},
		"herbs": {"id": "herbs", "name": "Linh Thảo (Herbs)", "effect": "Elements and uses.", "seen": 0, "known": 1, "total": 1, "entries": [{"id": "ngung_khi_thao", "book": "herbs", "level": "known", "title": "Ngưng Khí Thảo", "desc": "Basic herb.", "effect": "Elements and uses."}]},
		"lives": {
			"id": "lives",
			"name": "Ký Lục Kiếp Trước (Lives)",
			"effect": "Epitaph, chronicle summary, realm, age and cause of death of every life.",
			"seen": 0, "known": 2, "total": 2,
			"entries": [
				{"playthrough_id": "pt_1", "mode": "one_life", "name": "Lâm Phong", "realm_label": "Trúc Cơ Hậu Kỳ", "age": 142.0, "year": 1326, "cause": "Old age", "epitaph": "Walked softly through frost.", "chronicle_summary": "Reached Foundation Establishment."},
				{"playthrough_id": "pt_2", "mode": "continue", "name": "Trần Hạo", "realm_label": "Kết Đan Sơ Kỳ", "age": 210.0, "year": 1410, "cause": "Heavenly Tribulation", "epitaph": "Faced the ninefold thunder.", "chronicle_summary": "Formed the Golden Core."},
			],
		},
	}
	return {
		"books": books,
		"by_book": by_book,
		"total_entries": 11,
		"lives_count": 2,
		"notice": "Codex file was unreadable; started with an empty Codex and saved a backup.",
	}


func _sample_succession_view(karma_total_v: int = 5, karma_earned_v: int = 3, birth_mode_v: String = "thien_dinh", sect_alive_v: bool = true) -> Dictionary:
	return {
		"status": "succession",
		"mode": "continue",
		"epitaph": "Here rests Lâm Phong of Băng Tâm, who shattered three bottlenecks before falling at year 1350.",
		"karma": karma_total_v,
		"karma_earned": karma_earned_v,
		"birth_mode": birth_mode_v,
		"total_perks": 8,
		"heirs": [
			{
				"id": "h_lk", "name": "Lâm Tiểu Vũ", "relation": "child", "realm_index": 0,
				"realm_label": "Luyện Khí Tầng 6", "age": 22.0, "sect_id": "s_bt", "sect_name": "Băng Tâm Các",
				"place_id": "p_1", "place_name": "Hàn Sơn", "cost": 0, "affordable": true, "greyed": false,
				"unheld_perks": 8,
				"notable_ties": [{"id": "n1", "name": "Sở Ngọc Hồ", "kinds": ["master"]}],
				"portrait": {},
			},
			{
				"id": "h_kd", "name": "Lý Thanh", "relation": "disciple", "realm_index": 2,
				"realm_label": "Kết Đan Sơ Kỳ", "age": 68.0, "sect_id": "s_bt", "sect_name": "Băng Tâm Các",
				"place_id": "p_2", "place_name": "Tuyết Cốc", "cost": 3, "affordable": karma_total_v >= 3, "greyed": karma_total_v < 3,
				"unheld_perks": 2,
				"notable_ties": [],
				"portrait": {},
			},
			{
				"id": "h_na", "name": "Chu Vô Nhai", "relation": "child & disciple", "realm_index": 3,
				"realm_label": "Nguyên Anh Sơ Kỳ", "age": 180.0, "sect_id": "s_bt", "sect_name": "Băng Tâm Các",
				"place_id": "p_3", "place_name": "Thiên Xu Phong", "cost": 6, "affordable": karma_total_v >= 6, "greyed": karma_total_v < 6,
				"unheld_perks": 5,
				"notable_ties": [],
				"portrait": {},
			},
		],
		"lineage": {
			"sect_id": "s_bt", "sect_name": "Băng Tâm Các", "sect_alive": sect_alive_v,
			"clan_region_id": "reg_1", "clan_surname": "Lâm", "clan_available": true,
			"cost": 3, "affordable": karma_total_v >= 3,
		},
		"origins": [
			{"id": "tan_tu", "name": "Tán tu", "desc": "Nobody. Free, poor, no sect obligations."},
			{"id": "tong_mon", "name": "Đệ tử tông môn", "desc": "Outer disciple of a sect."},
			{"id": "gia_toc", "name": "Con cháu gia tộc", "desc": "Minor clan heir."},
		],
		"rebirth_years": 16,
		"rebirth_seasons": 64,
		"perk_extra_max": 3,
	}


# --- CodexWindow tests (AC-CK-14, AC-CK-19) ----------------------------------------

func test_codex_window_displays_all_10_books_and_seen_vs_known_ink_styling() -> void:
	var w: CodexWindow = auto_free(CodexWindow.new())
	add_child(w)
	var v: Dictionary = _sample_codex_view()
	w.show_view(v, "", false)

	assert_eq(w.kind(), "codex", "CodexWindow kind is codex")
	for bid in Codex.ALL_BOOKS:
		assert_true(_find(w, "Book_" + bid) != null, "10-book nav includes %s" % bid)

	assert_true(_find(w, "CodexNotice") != null, "corruption recovery notice shown when present")
	var eff: Label = _find(w, "BookEffect") as Label
	assert_true(eff != null and eff.text.contains("craft list"), "AC-CK-19: book effect stated")

	# Recipes book: known vs seen visual ink distinction
	var known_card: PanelContainer = _find(w, "Entry_tu_khi_dan") as PanelContainer
	var seen_card: PanelContainer = _find(w, "Entry_truc_co_dan") as PanelContainer
	assert_true(known_card != null and seen_card != null, "both known and seen entries rendered")
	assert_near(known_card.modulate.a, 1.0, 0.01, "AC-CK-19: known entry in full ink")
	assert_near(seen_card.modulate.a, 0.65, 0.01, "AC-CK-19: seen entry in faint ink")
	var known_badge: Label = _find(known_card, "LevelBadge") as Label
	var seen_badge: Label = _find(seen_card, "LevelBadge") as Label
	assert_true(known_badge.text.contains("Known"), "known badge shown")
	assert_true(seen_badge.text.contains("Seen"), "seen badge shown")
	_assert_no_builtin_tooltips(self, w, "CodexWindow(recipes)")


func test_codex_window_secrets_show_candidate_rumours_only_and_variants_gate_formation() -> void:
	var w: CodexWindow = auto_free(CodexWindow.new())
	add_child(w)
	var switched: Array = []
	w.book_selected.connect(func(bid: String): switched.append(bid))
	w.show_view(_sample_codex_view(), "", false)

	# Switch to variants book
	w.select_book("variants")
	assert_eq(w.selected_book(), "variants", "switched to variants")
	assert_eq(switched, ["variants"], "book_selected signal emitted")
	var known_v: Label = _find(w, "VariantFormation_bang") as Label
	var seen_v: Label = _find(w, "VariantFormation_loi") as Label
	assert_true(known_v != null and known_v.text.contains("transmutation") and known_v.text.contains("thuy"), "known variant reveals formation conditions")
	assert_true(seen_v != null and seen_v.text.contains("unknown"), "seen variant hides formation conditions")

	# Switch to secrets book (AC-CK-14)
	w.select_book("secrets")
	var reg_lbl: Label = _find(w, "CandidateRegions_R-1") as Label
	var sites_lbl: Label = _find(w, "CandidateSites_R-1") as Label
	assert_true(reg_lbl != null and reg_lbl.text.contains("Bắc Hàn") and reg_lbl.text.contains("Đông Lâm"), "AC-CK-14: known secret lists all candidate regions as rumours")
	assert_true(sites_lbl != null and sites_lbl.text.contains("(12, 34)") and sites_lbl.text.contains("(56, 78)"), "AC-CK-14: known secret lists candidate site coordinates")
	assert_true(reg_lbl.text.contains("varies each game"), "AC-CK-14: explicitly framed as rumours, never revealing current rolled site")
	assert_true(_find(w, "CandidateRegions_R-2") == null, "seen-only secret does not list candidate sites yet")
	_assert_no_builtin_tooltips(self, w, "CodexWindow(secrets)")


func test_codex_window_lives_book_displays_chronicle_entries() -> void:
	var w: CodexWindow = auto_free(CodexWindow.new())
	add_child(w)
	w.show_view(_sample_codex_view(), "lives", false)
	assert_eq(w.selected_book(), "lives", "opening with section 'lives' selects Lives book")

	var l0: PanelContainer = _find(w, "Life_0") as PanelContainer
	var l1: PanelContainer = _find(w, "Life_1") as PanelContainer
	assert_true(l0 != null and l1 != null, "both recorded lives displayed")
	assert_true((_find(w, "LifeModeBadge_0") as Label).text.contains("One Life"), "life 0 shows One Life mode")
	assert_true((_find(w, "LifeModeBadge_1") as Label).text.contains("Continue"), "life 1 shows Continue mode")
	assert_true((_find(w, "LifeFacts_0") as Label).text.contains("Trúc Cơ Hậu Kỳ") and (_find(w, "LifeFacts_0") as Label).text.contains("Old age"), "life 0 shows realm and cause of death")
	assert_true((_find(w, "LifeEpitaph_1") as Label).text.contains("ninefold thunder"), "life 1 shows epitaph")
	_assert_no_builtin_tooltips(self, w, "CodexWindow(lives)")


func test_codex_window_loads_real_game_data_view_without_session_mutation() -> void:
	var gd := game_data()
	var store := CodexStore.new()
	var codex := Codex.new(gd, store)
	var fated := Character.new()
	fated.name = "Lâm"
	fated.birth_mode = "thien_dinh"
	codex.record(Codex.BOOK_RECIPES, "tu_khi_dan", CodexStore.LEVEL_KNOWN, fated, false, 1201)
	codex.record(Codex.BOOK_HERBS, "ngung_khi_thao", CodexStore.LEVEL_SEEN, fated, false, 1202)
	codex.record_life_data({"playthrough_id": "pt_real", "mode": "continue", "name": "Lâm", "realm_label": "Luyện Khí", "age": 80.0, "year": 1264, "cause": "Old age", "epitaph": "Peace."})

	var books_out: Array = []
	var by_book: Dictionary = {}
	for bm in codex.books_meta():
		var bid: String = str(bm.get("id", ""))
		var counts: Dictionary = store.count_book(bid)
		var bcopy := {
			"id": bid, "name": str(bm.get("name", bid)), "effect": str(bm.get("effect", "")),
			"seen": int(counts.seen), "known": int(counts.known), "total": int(counts.total),
		}
		books_out.append(bcopy)
		var full_b: Dictionary = bcopy.duplicate(true)
		full_b["entries"] = codex.visible_entries(bid)
		by_book[bid] = full_b

	var w: CodexWindow = auto_free(CodexWindow.new())
	add_child(w)
	w.show_view({"books": books_out, "by_book": by_book, "total_entries": store.total_entries(), "lives_count": store.lives.size(), "notice": ""}, "", false)
	assert_eq(books_out.size(), 10, "real meta_codex.json provides all 10 books")
	assert_true(_find(w, "Entry_tu_khi_dan") != null, "real authored recipe renders in CodexWindow")


# --- SuccessionScreen tests (AC-CK-18, AC-CK-20) -----------------------------------

func test_succession_screen_displays_epitaph_karma_breakdown_and_unaffordable_heir_greying() -> void:
	var s: SuccessionScreen = auto_free(SuccessionScreen.new())
	add_child(s)
	s.show_view(_sample_succession_view(5, 3, "thien_dinh", true), "", false)

	assert_eq(s.kind(), "succession", "SuccessionScreen kind is succession")
	assert_eq(s.karma_total(), 5, "total karma 5")
	assert_eq(s.karma_earned(), 3, "earned karma 3")
	assert_eq(s.karma_carried(), 2, "carried karma 2")

	var kh: Label = _find(s, "KarmaSummary") as Label
	assert_true(kh != null and kh.text.contains("earned 3 + carried 2"), "AC-CK-18: karma earned + carried breakdown shown")
	var ep: Label = _find(s, "EpitaphText") as Label
	assert_true(ep != null and ep.text.contains("Lâm Phong"), "AC-CK-18: epitaph scroll displayed")

	# AC-CK-20: with 5 karma, LK (0) and KD (3) are affordable; NA (6) is greyed out and disabled
	var lk_btn: Button = _find(s, "SelectHeir_h_lk") as Button
	var kd_btn: Button = _find(s, "SelectHeir_h_kd") as Button
	var na_btn: Button = _find(s, "SelectHeir_h_na") as Button
	var na_card: PanelContainer = _find(s, "HeirCard_h_na") as PanelContainer
	assert_false(lk_btn.disabled, "Luyện Khí heir (0 karma) selectable")
	assert_false(kd_btn.disabled, "Kết Đan heir (3 karma) selectable at 5 karma")
	assert_true(na_btn.disabled, "AC-CK-20: Nguyên Anh heir (6 karma) disabled at 5 karma")
	assert_true(na_card.modulate.a < 0.8, "AC-CK-20: unaffordable heir card visually greyed out")
	assert_true((_find(s, "HeirCost_h_na") as Label).text.contains("6"), "AC-CK-20: unaffordable heir displays its cost label")
	assert_false(s.select_heir("h_na"), "programmatic select rejects unaffordable heir")

	# Rebirth panel: 3 free origins + lineage badges
	for oid in ["tan_tu", "tong_mon", "gia_toc"]:
		assert_true(_find(s, "Origin_" + oid) != null, "free origin %s shown" % oid)
	assert_true((_find(s, "LineageSectBadge") as Label).text.contains("Active"), "active sect lineage badge shown")
	assert_false((_find(s, "LineageSect") as Button).disabled, "active affordable sect lineage enabled")
	_assert_no_builtin_tooltips(self, s, "SuccessionScreen")


func test_succession_screen_perk_extra_clamping_and_signals() -> void:
	var s: SuccessionScreen = auto_free(SuccessionScreen.new())
	add_child(s)
	var heir_ev: Array = []
	var rebirth_ev: Array = []
	var end_ev: Array = []
	var action_ev: Array = []
	s.heir_chosen.connect(func(hid: String, opts: Dictionary): heir_ev.append([hid, opts]))
	s.rebirth_chosen.connect(func(opts: Dictionary): rebirth_ev.append(opts))
	s.end_playthrough_chosen.connect(func(): end_ev.append(true))
	s.action_requested.connect(func(a: String, args: Array): action_ev.append([a, args]))

	s.show_view(_sample_succession_view(5, 3, "thien_dinh", true), "", false)

	# Selecting LK heir (cost 0, unheld 8) with 5 karma -> max_perk_extra = min(3, 5, 5) = 3
	assert_true(s.select_heir("h_lk"), "selected LK heir")
	assert_eq(s.max_perk_extra(), 3, "max perk_extra capped at perk_extra_max=3")
	s.set_perk_extra(9)
	assert_eq(s.perk_extra(), 3, "perk_extra clamped to 3")
	assert_eq(s.total_cost(), 3, "0 heir + 3 perk_extra = 3")

	# Switching to KD heir (cost 3, unheld 2 -> unheld <= 3) clamps perk_extra to 0 (AC-CK-17)
	assert_true(s.select_heir("h_kd"), "selected KD heir")
	assert_eq(s.max_perk_extra(), 0, "AC-CK-17: unheld 2 <= 3 clamps max_perk_extra to 0")
	assert_eq(s.perk_extra(), 0, "perk_extra automatically clamped to 0")

	# Confirm heir emits clean signals without touching any GameSession
	assert_true(s.confirm_selection(), "confirm heir succeeds")
	assert_eq(heir_ev.size(), 1, "heir_chosen emitted")
	assert_eq(heir_ev[0][0], "h_kd", "heir id passed")
	assert_eq(int(heir_ev[0][1].perk_extra), 0, "perk_extra passed")
	assert_eq(action_ev[0][0], "succeed_heir", "action_requested emits succeed_heir")

	# Lineage sect (cost 3) at 5 karma -> remaining 2 karma -> max_perk_extra = 2
	assert_true(s.select_rebirth_lineage("sect"), "selected sect lineage")
	assert_eq(s.max_perk_extra(), 2, "5 karma - 3 lineage = 2 max perk_extra")
	s.set_perk_extra(2)
	assert_eq(s.total_cost(), 5, "3 lineage + 2 perk_extra = 5")
	assert_true(s.confirm_selection(), "confirm lineage rebirth succeeds")
	assert_eq(rebirth_ev.size(), 1, "rebirth_chosen emitted")
	assert_eq(str(rebirth_ev[0].lineage_kind), "sect", "lineage_kind is sect")
	assert_eq(int(rebirth_ev[0].perk_extra), 2, "perk_extra is 2")

	# Self-made rebirth mode disables perk_extra (AC-CK-17)
	s.set_rebirth_birth_mode("tu_dinh")
	assert_eq(s.max_perk_extra(), 0, "Self-made rebirth sets max_perk_extra to 0")
	assert_true((_find(s, "PerkExtraPlus") as Button).disabled, "PerkExtraPlus disabled in Self-made")

	# End this playthrough confirm-in-place and Esc cancel
	(_find(s, "EndPlaythrough") as Button).pressed.emit()
	assert_eq(end_ev.size(), 0, "first click only arms End Playthrough")
	assert_true(s.cancel_inline(), "Esc disarms End Playthrough")
	assert_true(_find(s, "EndPlaythrough") != null, "disarmed returns to EndPlaythrough button")
	(_find(s, "EndPlaythrough") as Button).pressed.emit()
	(_find(s, "ConfirmEndPlaythrough") as Button).pressed.emit()
	assert_eq(end_ev.size(), 1, "ConfirmEndPlaythrough emits end_playthrough_chosen")
	assert_eq(action_ev[-1][0], "end_playthrough", "action_requested emits end_playthrough")


func test_succession_screen_fallen_sect_lineage_disabled() -> void:
	var s: SuccessionScreen = auto_free(SuccessionScreen.new())
	add_child(s)
	s.show_view(_sample_succession_view(5, 5, "thien_dinh", false), "", false)
	assert_true((_find(s, "LineageSectBadge") as Label).text.contains("Fallen"), "fallen sect badge shown")
	assert_true((_find(s, "LineageSect") as Button).disabled, "fallen sect lineage button disabled")
	assert_false(s.select_rebirth_lineage("sect"), "cannot select fallen sect lineage")


# --- GameMenu tests (One Life vs Continue mode selector & save slot badges) --------

func test_game_menu_new_game_mode_selector_and_save_slot_badges() -> void:
	var m: GameMenu = auto_free(GameMenu.new())
	m.saves = [
		{"slot": "ol_slot", "name": "Iron Run", "date": "Xuân 1210", "realm": "Trúc Cơ", "time": "12:00", "ok": true, "playthrough_mode": "one_life", "playthrough_status": "ended"},
		{"slot": "ct_slot", "name": "Dynasty Run", "date": "Thu 1245", "realm": "Kết Đan", "time": "13:00", "ok": true, "playthrough_mode": "continue", "playthrough_status": "succession"},
	]
	add_child(m)
	m.open_menu()

	# New game button reachable from menu without altering the 6 direct buttons in _box
	var ng_btn: Button = _find(m, "NewGame") as Button
	assert_true(ng_btn != null, "NewGame button present on menu")
	ng_btn.pressed.emit()
	assert_eq(m.page(), "new_game", "clicking NewGame opens new_game page")
	assert_eq(m.selected_playthrough_mode(), "one_life", "default new game mode is one_life")

	var got: Array = []
	m.new_game_requested.connect(func(spec: Dictionary): got.append(spec))
	(_find(m, "Mode_continue") as Button).pressed.emit()
	assert_eq(m.selected_playthrough_mode(), "continue", "switched to continue mode")
	(_find(m, "NewOrigin_tong_mon") as Button).pressed.emit()
	(_find(m, "StartNewGame") as Button).pressed.emit()
	assert_eq(got.size(), 1, "new_game_requested emitted")
	assert_eq(str(got[0].playthrough_mode), "continue", "emitted continue playthrough_mode")
	assert_eq(str(got[0].origin), "tong_mon", "emitted selected origin")

	# Esc from new_game returns to menu
	m.back_or_close()
	assert_eq(m.page(), "menu", "Esc from new_game returns to menu")

	# Save slot mode badges on Load and Save pages
	m.show_page("load")
	var ol_badge: Label = _find(m, "ModeBadge_ol_slot") as Label
	var ct_badge: Label = _find(m, "ModeBadge_ct_slot") as Label
	assert_true(ol_badge != null and ol_badge.text.contains("One Life") and ol_badge.text.contains("Ended"), "Load page shows One Life + Ended badge")
	assert_true(ct_badge != null and ct_badge.text.contains("Continue") and ct_badge.text.contains("Succession"), "Load page shows Continue + Succession badge")

	m.show_page("save")
	assert_true(_find(m, "ModeBadge_ol_slot") != null and _find(m, "ModeBadge_ct_slot") != null, "Save page shows mode badges too")
	_assert_no_builtin_tooltips(self, m, "GameMenu")
