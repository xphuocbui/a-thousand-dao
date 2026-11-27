extends DaoTestSuite
## Sects & Missions root admission (F20, rules 20c-20d) and intake fill (F21): AC-SM-59, AC-SM-60, AC-SM-62, AC-SM-67.


func _root(elements: Dictionary, variants: Dictionary = {}, road: Dictionary = {}) -> LinhCan:
	var lc := LinhCan.new()
	for k in elements.keys():
		lc.elements[str(k)] = float(elements[k])
	for k in variants.keys():
		lc.variants[str(k)] = float(variants[k])
	for k in road.keys():
		lc.road[str(k)] = float(road[k])
	return lc


func test_f20_variant_base_and_no_lean_admission_ac_sm_59() -> void:
	var gd := game_data()
	var bang_tam := {"id": "bang_tam", "lineage_elements": ["bang", "thuy"]}
	var w62 := _root({"thuy": 62})
	assert_true(SectAdmission.admits_outer(gd, bang_tam, w62), "Water 62 no Ice passes outer")
	assert_false(SectAdmission.admits_core(gd, bang_tam, w62), "Water 62 no Ice fails core")
	assert_false(SectAdmission.admits_head(gd, bang_tam, w62), "Water 62 no Ice fails head")

	var w29 := _root({"thuy": 29})
	assert_false(SectAdmission.admits_outer(gd, bang_tam, w29), "Water 29 no Ice fails outer")
	assert_false(SectAdmission.admits_core(gd, bang_tam, w29), "Water 29 no Ice fails core")

	var w40_i12 := _root({"thuy": 40}, {"bang": 12})
	assert_true(SectAdmission.admits_outer(gd, bang_tam, w40_i12), "Water 40 + Ice 12 passes outer")
	assert_true(SectAdmission.admits_core(gd, bang_tam, w40_i12), "Water 40 + Ice 12 passes core")
	assert_false(SectAdmission.admits_head(gd, bang_tam, w40_i12), "Water 40 + Ice 12 fails head (12 < 50)")

	var w86_i84 := _root({"thuy": 86}, {"bang": 84})
	assert_true(SectAdmission.admits_head(gd, bang_tam, w86_i84), "Water 86 + Ice 84 passes head")

	# leans fallback with English names produces the same canonical elements
	var bang_tam_leans := {"id": "bang_tam", "leans": ["Water", "Ice"]}
	assert_eq(SectAdmission.base_elements_of(gd, bang_tam_leans), ["thuy"], "leans Water -> thuy")
	assert_eq(SectAdmission.variants_of(gd, bang_tam_leans), ["bang"], "leans Ice -> bang")
	assert_true(SectAdmission.admits_outer(gd, bang_tam_leans, w62), "leans fallback outer")
	assert_false(SectAdmission.admits_core(gd, bang_tam_leans, w62), "leans fallback core")

	# Base lineage [kim, hoa]
	var thinh_vu := {"id": "thinh_vu", "lineage_elements": ["kim", "hoa"]}
	assert_true(SectAdmission.admits_core(gd, thinh_vu, _root({"kim": 45})), "Metal 45 passes core")
	assert_false(SectAdmission.admits_core(gd, thinh_vu, _root({"kim": 44})), "Metal 44 fails core")
	assert_true(SectAdmission.admits_head(gd, thinh_vu, _root({"kim": 50})), "Metal 50 passes head")
	assert_false(SectAdmission.admits_head(gd, thinh_vu, _root({"kim": 49})), "Metal 49 fails head")
	assert_true(SectAdmission.admits_outer(gd, thinh_vu, _root({"hoa": 30})), "Fire 30 alone passes outer")
	assert_false(SectAdmission.admits_outer(gd, thinh_vu, _root({"hoa": 29})), "Fire 29 alone fails outer")
	assert_false(SectAdmission.admits_core(gd, thinh_vu, _root({"hoa": 80})), "Fire alone fails Metal-main core")

	# No-lean lineage [] (including precedence of empty lineage_elements over legacy leans)
	var tam_kiem := {"id": "tam_kiem", "lineage_elements": [], "leans": ["Metal", "Water"]}
	assert_true(SectAdmission.is_no_lean(gd, tam_kiem), "empty lineage_elements is no-lean even when leans is set")
	var weak := _root({"hoa": 10})
	assert_true(SectAdmission.admits_outer(gd, tam_kiem, weak), "no-lean passes outer")
	assert_true(SectAdmission.admits_core(gd, tam_kiem, weak), "no-lean passes core")
	assert_true(SectAdmission.admits_head(gd, tam_kiem, weak), "no-lean passes head")

	# Road purity on unowned elements/variants must never pass admission
	var road_only := _root({"hoa": 50}, {}, {"thuy": 80, "bang": 80})
	assert_false(SectAdmission.admits_outer(gd, bang_tam, road_only), "unowned road purity never passes outer")
	assert_false(SectAdmission.admits_core(gd, bang_tam, road_only), "unowned road purity never passes core")
	assert_false(SectAdmission.admits_head(gd, bang_tam, road_only), "unowned road purity never passes head")
	var owned_plus_road := _root({"thuy": 25}, {}, {"thuy": 10})
	assert_true(SectAdmission.admits_outer(gd, bang_tam, owned_plus_road), "owned base + road counts toward purity")


func test_f20_convergence_variant_vs_non_convergence_ac_sm_60() -> void:
	var gd := game_data()
	var conv := {"id": "conv_fix", "lineage_elements": ["loi", "kim", "hoa"]}
	assert_true(SectAdmission.admits_core(gd, conv, _root({"kim": 52})), "Metal 52 no Thunder passes core")
	assert_true(SectAdmission.admits_head(gd, conv, _root({"kim": 52})), "Metal 52 no Thunder passes head")

	assert_true(SectAdmission.admits_core(gd, conv, _root({"kim": 47})), "Metal 47 no Thunder passes core")
	assert_false(SectAdmission.admits_head(gd, conv, _root({"kim": 47})), "Metal 47 no Thunder fails head")

	assert_true(SectAdmission.admits_head(gd, conv, _root({"kim": 47, "hoa": 30}, {"loi": 50})), "Metal 47 + Thunder 50 passes head")

	var f60_m20 := _root({"hoa": 60, "kim": 20})
	assert_true(SectAdmission.admits_outer(gd, conv, f60_m20), "Fire 60 + Metal 20 passes outer")
	assert_false(SectAdmission.admits_core(gd, conv, f60_m20), "Fire 60 + Metal 20 fails core (b1 is Metal)")

	assert_true(SectAdmission.admits_core(gd, conv, _root({"kim": 20, "hoa": 30}, {"loi": 8})), "Thunder 8 + Metal 20 passes core")

	# Non-convergence Ice lineage: no 'or' fallback to Water
	var bang_tam := {"id": "bang_tam", "lineage_elements": ["bang", "thuy"]}
	assert_false(SectAdmission.admits_core(gd, bang_tam, _root({"thuy": 90})), "Water 90 no Ice fails core (Ice is not convergence)")
	assert_false(SectAdmission.admits_head(gd, bang_tam, _root({"thuy": 90})), "Water 90 no Ice fails head")


func test_rank_dispatch_and_rule_20c_exceptions() -> void:
	var gd := game_data()
	var bang_tam := {"id": "bang_tam", "lineage_elements": ["bang", "thuy"]}
	var fire70 := _root({"hoa": 70})
	for r in ["ngoai_mon", "noi_mon", "chan_truyen", "chap_su", "truong_lao", "thai_thuong", "tong_chu"]:
		assert_false(SectAdmission.admits_for_rank(gd, bang_tam, fire70, r), "Fire 70 fails %s at Băng Tâm" % r)
	assert_true(SectAdmission.admits_for_rank(gd, bang_tam, fire70, "khach_khanh"), "guest elder skips root test")
	assert_true(SectAdmission.admits_for_rank(gd, bang_tam, fire70, "tap_dich"), "servant skips root test")
	assert_true(SectAdmission.admits_for_rank(gd, bang_tam, fire70, "truong_lao", "guest_elder"), "named exception skips root test")
	assert_true(SectAdmission.admits_for_rank(gd, bang_tam, fire70, "noi_mon", "root_changed"), "root_changed exception skips root test")


func test_f21_intake_fill_example_lapse_kin_and_1000_seasons_ac_sm_62() -> void:
	var gd := game_data()
	# 1. Exact F21 worked example: Băng Tâm claims 2 from pool A-E
	var bang_tam := {"id": "bang_tam", "lineage_elements": ["bang", "thuy"]}
	var p_a := {"id": "A", "linh_can": _root({"thuy": 62}), "thien_phu": {}, "home": true}
	var p_b := {"id": "B", "linh_can": _root({"thuy": 48}, {"bang": 21}), "thien_phu": {}, "home": false}
	var p_c := {"id": "C", "linh_can": _root({"hoa": 70, "tho": 35}), "thien_phu": {}, "home": true}
	var p_d := {"id": "D", "linh_can": _root({"thuy": 31, "moc": 50}), "thien_phu": {}, "home": true}
	var p_e := {"id": "E", "linh_can": _root({"thuy": 29}), "thien_phu": {}, "home": false}
	assert_near(SectAdmission.candidate_score(gd, bang_tam, p_a.linh_can, {}, false, true), 562.0, 1e-9, "A scores 562")
	assert_near(SectAdmission.candidate_score(gd, bang_tam, p_b.linh_can, {}, false, false), 121.0, 1e-9, "B scores 121")
	assert_near(SectAdmission.candidate_score(gd, bang_tam, p_d.linh_can, {}, false, true), 531.0, 1e-9, "D scores 531")

	var home_fn := func(_s: Dictionary, p: Dictionary) -> bool: return bool(p.get("home", false))
	var res := SectAdmission.fill_claims(gd, [bang_tam], {"bang_tam": 2}, [p_a, p_b, p_c, p_d, p_e], home_fn)
	var admitted_ids: Array = Array(res.admitted["bang_tam"]).map(func(x): return str(x.id))
	var loose_ids: Array = Array(res.loose).map(func(x): return str(x.id))
	assert_eq(admitted_ids, ["A", "D"], "Băng Tâm admits A (562) and D (531)")
	assert_eq(loose_ids, ["B", "C", "E"], "B, C, E stay in pool / loose")

	# 2. Claim lapse: claim 3 with 1 passing member -> 1 admitted, 2 lapse
	var lapse_res := SectAdmission.fill_claims(gd, [bang_tam], {"bang_tam": 3}, [p_c, p_d, p_e], home_fn)
	assert_eq(Array(lapse_res.admitted["bang_tam"]).size(), 1, "only 1 passing member admitted out of claim 3")
	assert_eq(Array(lapse_res.loose).size(), 2, "2 non-passing stay loose")

	# 3. Kin sect: member's child with lowest talent is admitted before high-talent outsider
	var kin_sect := {"id": "kin_minor", "lineage_elements": [], "recruit_by": {"talent": "can_cot", "kin": true}}
	var outsider := {"id": "p_out", "linh_can": _root({"hoa": 80}), "thien_phu": {"can_cot": 99}, "home": true, "kin": false}
	var child := {"id": "p_kin", "linh_can": _root({"tho": 15}), "thien_phu": {"can_cot": 1}, "home": false, "kin": true}
	var kin_fn := func(_s: Dictionary, p: Dictionary) -> bool: return bool(p.get("kin", false))
	var kin_res := SectAdmission.fill_claims(gd, [kin_sect], {"kin_minor": 1}, [outsider, child], home_fn, kin_fn)
	assert_eq(Array(kin_res.admitted["kin_minor"]).map(func(x): return str(x.id)), ["p_kin"], "kin child admitted first despite talent 1 vs 99")

	# Non-kin sect ignores kin flag
	var non_kin_sect := {"id": "nokin_minor", "lineage_elements": [], "recruit_by": {"talent": "can_cot", "kin": false}}
	var nokin_res := SectAdmission.fill_claims(gd, [non_kin_sect], {"nokin_minor": 1}, [outsider, child], home_fn, kin_fn)
	assert_eq(Array(nokin_res.admitted["nokin_minor"]).map(func(x): return str(x.id)), ["p_out"], "non-kin sect does not apply kin bonus")

	# 4. 1,000 seeded seasons invariant: admitted + loose == pool, no duplicates, all admitted pass outer
	var sects: Array = [
		{"id": "s_ice", "lineage_elements": ["bang", "thuy"]},
		{"id": "s_metal", "lineage_elements": ["kim", "hoa"]},
		{"id": "s_thunder", "lineage_elements": ["loi", "kim", "hoa"]},
		{"id": "s_wood", "lineage_elements": ["moc"]},
		{"id": "s_nolean_kin", "lineage_elements": [], "recruit_by": {"talent": "dao_tam", "kin": true}},
	]
	var r := rng(20261125)
	var base_ids: Array = gd.element_cycle()
	var var_ids: Array = ["bang", "loi", "phong", "quang", "am"]
	var s_home_fn := func(s: Dictionary, p: Dictionary) -> bool: return str(p.home_sect) == str(s.id)
	var s_kin_fn := func(s: Dictionary, p: Dictionary) -> bool: return str(p.kin_sect) == str(s.id)
	for season in 1000:
		var pool_size: int = r.randi_range(6, 16)
		var pool: Array = []
		for i in pool_size:
			var els: Dictionary = {}
			var cnt: int = r.randi_range(1, 3)
			for _k in cnt:
				els[str(base_ids[r.randi_range(0, base_ids.size() - 1)])] = float(r.randi_range(10, 95))
			var vrs: Dictionary = {}
			if r.randf() < 0.25:
				vrs[str(var_ids[r.randi_range(0, var_ids.size() - 1)])] = float(r.randi_range(5, 90))
			pool.append({
				"id": "p_%d_%02d" % [season, i],
				"linh_can": _root(els, vrs),
				"thien_phu": {"dao_tam": r.randi_range(1, 100)},
				"home_sect": str(sects[r.randi_range(0, sects.size() - 1)].id),
				"kin_sect": str(sects[r.randi_range(0, sects.size() - 1)].id) if r.randf() < 0.15 else "",
			})
		var claims: Dictionary = {}
		for s in sects:
			claims[str(s.id)] = r.randi_range(0, 4)
		var out := SectAdmission.fill_claims(gd, sects, claims, pool, s_home_fn, s_kin_fn)
		var seen: Dictionary = {}
		var total_admitted: int = 0
		for s in sects:
			var sid: String = str(s.id)
			var list: Array = out.admitted[sid]
			assert_true(list.size() <= int(claims[sid]), "season %d sect %s never exceeds claim" % [season, sid])
			for p in list:
				var pid: String = str(p.id)
				assert_false(seen.has(pid), "season %d person %s admitted twice" % [season, pid])
				seen[pid] = true
				assert_true(SectAdmission.admits_outer(gd, s, p.linh_can), "season %d %s passes %s outer" % [season, pid, sid])
				total_admitted += 1
		for p in out.loose:
			var pid: String = str(p.id)
			assert_false(seen.has(pid), "season %d person %s both admitted and loose" % [season, pid])
			seen[pid] = true
		assert_eq(total_admitted + Array(out.loose).size(), pool_size, "season %d conservation: admitted + loose == pool" % season)


func test_sect_members_can_join_and_promote_root_gates_ac_sm_67() -> void:
	var gd := game_data()
	var db := WorldDB.new()
	var sm := SectMembers.new(gd, db)
	db.put("places", {"id": "l_bt", "name": "Ngọc Hồ", "region_id": "r1", "sect_id": "bang_tam"})
	db.put("places", {"id": "l_tk", "name": "Kiếm Các", "region_id": "r1", "sect_id": "tam_kiem"})
	var bang_tam := {
		"id": "bang_tam", "name": "Băng Tâm Các", "hq_place_id": "l_bt", "region_id": "r1",
		"members": [], "status": "active", "lineage_elements": ["bang", "thuy"],
	}
	var tam_kiem := {
		"id": "tam_kiem", "name": "Tầm Kiếm Đường", "hq_place_id": "l_tk", "region_id": "r1",
		"members": [], "status": "active", "lineage_elements": [],
	}
	db.put("sects", bang_tam)
	db.put("sects", tam_kiem)

	# AC-SM-67: Fire 70 root (no Water or Ice) refused by Băng Tâm with exact reason, admitted by Tầm Kiếm
	var player := TestFixtures.character({"hoa": 70}, 50, 0, 0)
	player.id = "p_fire"
	player.location_id = "l_bt"
	var res_bt: Dictionary = sm.can_join(player, bang_tam)
	assert_false(bool(res_bt.ok), "Fire 70 refused by Băng Tâm")
	assert_true(Array(res_bt.reasons).has("root: needs Water 30 or Ice"),
		"exact AC-SM-67 reason: %s" % str(res_bt.reasons))

	player.location_id = "l_tk"
	var res_tk: Dictionary = sm.can_join(player, tam_kiem)
	assert_true(bool(res_tk.ok), "Fire 70 admitted by Tầm Kiếm (no-lean): %s" % str(res_tk.reasons))

	# Outer passes Water 62 -> inner promotion blocked until Ice awakens
	var disciple := TestFixtures.character({"thuy": 62}, 50, 1, 0)
	disciple.id = "p_water"
	disciple.location_id = "l_bt"
	assert_true(bool(sm.can_join(disciple, bang_tam).ok), "Water 62 passes Băng Tâm outer gate")
	sm.join(disciple, bang_tam)
	sm.record("bang_tam", "p_water")["contribution"] = 500
	var promo_fail: Dictionary = sm.promote(disciple)
	assert_false(bool(promo_fail.ok), "Water 62 without Ice blocked from inner promotion")
	assert_true(str(promo_fail.lines).contains("root: needs Ice"), "says root needs Ice: %s" % str(promo_fail.lines))

	disciple.linh_can.variants["bang"] = 12.0
	var promo_ok: Dictionary = sm.promote(disciple)
	assert_true(bool(promo_ok.ok), "with Ice 12 inner promotion passes: %s" % str(promo_ok.lines))
	assert_eq(disciple.sect_rank, "noi_mon", "promoted to inner disciple")
