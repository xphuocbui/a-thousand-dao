extends DaoTestSuite
## NPC Traits v2 runtime, StatSheet integration, F4b/F5b/F6b/F7/F3-lk, hooks/verbs, retired fates, and scoped rows
## (design/gdd/npc-traits.md AC-NT-37..54).


func _person_with(nt: Dictionary, id: String = "p1") -> Dictionary:
	return {"id": id, "npc_traits": nt}


# --- AC-NT-37: Doubled personality rows, unchanged calling rows ------------------------------------------------------

func test_ac_nt_37_doubled_personality_rows_and_unchanged_callings() -> void:
	var gd := game_data()
	var f: Dictionary = gd.file(NpcTraits.FILE)
	assert_eq(float(f.get("row_premium", {}).get("personality", 0.0)), 2.0, "personality premium 2.0")
	assert_eq(float(f.get("row_premium", {}).get("callings", 0.0)), 1.0, "calling premium 1.0")
	var c_brave := Character.new()
	c_brave.npc_traits = {"personality": ["brave"], "calling": "", "fate": [], "gained": []}
	var s_brave := StatSheet.build(c_brave, gd, null, null)
	assert_near(s_brave.total("khi_huyet_pct"), 4.0, 1e-6, "Brave +4.0 khi_huyet_pct")
	assert_near(s_brave.total("evade_pct"), -1.6, 1e-6, "Brave -1.6 evade_pct")
	var c_greedy := Character.new()
	c_greedy.npc_traits = {"personality": ["greedy"], "calling": "", "fate": [], "gained": []}
	var s_greedy := StatSheet.build(c_greedy, gd, null, null)
	assert_near(s_greedy.total("mission_income_pct"), 3.4, 1e-6, "Greedy +3.4 mission_income_pct")
	assert_near(s_greedy.total("tam_ma_resist_pct"), -1.6, 1e-6, "Greedy -1.6 tam_ma_resist_pct")
	var c_content := Character.new()
	c_content.npc_traits = {"personality": ["content"], "calling": "", "fate": [], "gained": []}
	var s_content := StatSheet.build(c_content, gd, null, null)
	assert_near(s_content.total("cultivation_speed_pct"), -1.0, 1e-6, "Content -1.0 cultivation_speed_pct")
	var c_strat := Character.new()
	c_strat.npc_traits = {"personality": [], "calling": "strategist", "fate": [], "gained": []}
	var s_strat := StatSheet.build(c_strat, gd, null, null)
	assert_near(s_strat.total("escape_pct"), 1.2, 1e-6, "Strategist +1.2 escape_pct unchanged")
	assert_near(s_strat.total("cultivation_speed_pct"), -0.5, 1e-6, "Strategist -0.5 cultivation_speed_pct unchanged")
	var row_count: int = 0
	for t in f.personality:
		row_count += Array(t.boon).size() + Array(t.cost).size()
	assert_eq(row_count, 74, "74 personality rows")


# --- AC-NT-38 & AC-NT-48: v2 catalogue counts, validation, no environment conditions ---------------------------------

func test_ac_nt_38_and_48_catalogue_load_and_rule_7a_validation() -> void:
	var gd := game_data()
	var f: Dictionary = gd.file(NpcTraits.FILE)
	assert_eq(Array(f.upbringing).size(), 12, "12 upbringings")
	assert_eq(Array(f.talent).size(), 12, "12 talent families")
	assert_eq(Array(f.path).size(), 24, "24 paths")
	assert_eq(Array(f.lifestyle).size(), 14, "14 lifestyles")
	assert_eq(Array(f.health).size(), 10, "10 health")
	assert_eq(Array(f.coping).size(), 8, "8 coping")
	var errs: Array = NpcTraits.validate_catalogue(gd)
	assert_eq(errs, [], "live traits.json validates clean: %s" % str(errs))
	# AC-NT-38: reject more row, unknown/Pending stat key, unknown like target
	var bad_more: Dictionary = f.duplicate(true)
	bad_more.path[0].rows.append({"stat": "damage_more", "value": 5})
	var e_more: Array = NpcTraits.validate_catalogue(gd, bad_more)
	assert_true(e_more.any(func(s): return str(s).contains(str(bad_more.path[0].id))), "more row rejected naming trait")
	var bad_stat: Dictionary = f.duplicate(true)
	bad_stat.lifestyle[0].rows.append({"stat": "pending_imaginary_stat", "value": 3})
	var e_stat: Array = NpcTraits.validate_catalogue(gd, bad_stat)
	assert_true(e_stat.any(func(s): return str(s).contains(str(bad_stat.lifestyle[0].id))), "unknown stat rejected naming trait")
	var bad_like: Dictionary = f.duplicate(true)
	bad_like.upbringing[0].likes.append("nonexistent_trait_xyz")
	var e_like: Array = NpcTraits.validate_catalogue(gd, bad_like)
	assert_true(e_like.any(func(s): return str(s).contains(str(bad_like.upbringing[0].id))), "unknown like rejected naming trait")
	# AC-NT-48: reject extra row field or environment scope
	var bad_field: Dictionary = f.duplicate(true)
	bad_field.health[0].rows[0]["condition"] = "rain"
	var e_field: Array = NpcTraits.validate_catalogue(gd, bad_field)
	assert_true(e_field.any(func(s): return str(s).contains(str(bad_field.health[0].id))), "extra row field rejected naming trait")
	var bad_env: Dictionary = f.duplicate(true)
	bad_env.path[0].rows[0]["scope"] = ["winter"]
	var e_env: Array = NpcTraits.validate_catalogue(gd, bad_env)
	assert_true(e_env.any(func(s): return str(s).contains(str(bad_env.path[0].id))), "environment scope rejected naming trait")


# --- AC-NT-39: F1b talent tier math & StatSheet ordering before CongPhap --------------------------------------------

func test_ac_nt_39_talent_tiers_and_stat_sheet_ordering() -> void:
	var gd := game_data()
	# Base comprehension 45 + quick_minded 3 -> effective 65, cultivation_speed_pct +6 %, Genius +20
	var c := TestFixtures.character({"hoa": 60}, 45, 0)
	c.npc_traits = {"talent": [{"id": "quick_minded", "tier": 3}]}
	var sheet := StatSheet.build(c, gd, null, null)
	assert_near(sheet.effective("ngo_tinh", c), 65.0, 1e-6, "45 + 20 = 65")
	assert_near(sheet.total("cultivation_speed_pct"), 6.0, 1e-6, "Genius +6 % cultivation speed")
	var srcs: Array = NpcTraits.talent_tier_sources(gd, {"npc_traits": c.npc_traits}, "ngo_tinh")
	assert_eq(srcs.size(), 1, "one talent source")
	assert_eq(str(srcs[0].name), "Genius", "tier 3 English name")
	assert_eq(str(srcs[0].name_vi), "thiên tài", "tier 3 Vietnamese name")
	assert_near(float(srcs[0].value), 20.0, 1e-6, "+20 flat")
	# Base 10 + slow_witted 3 -> clamped to 1
	var c_low := TestFixtures.character({"hoa": 60}, 10, 0)
	c_low.npc_traits = {"talent": [{"id": "slow_witted", "tier": 3}]}
	assert_near(StatSheet.build(c_low, gd, null, null).effective("ngo_tinh", c_low), 1.0, 1e-6, "10 - 20 clamped to 1")
	# Base 100 + 40 flat + quick_minded 3 -> clamped to 150
	var c_hi := TestFixtures.character({"hoa": 60}, 100, 0)
	c_hi.npc_traits = {"talent": [{"id": "quick_minded", "tier": 3}]}
	var s_hi := StatSheet.build(c_hi, gd, null, null)
	s_hi.add_mod("test", "ngo_tinh", 40.0)
	assert_near(s_hi.effective("ngo_tinh", c_hi), 150.0, 1e-6, "100 + 40 + 20 clamped to 150")
	# comely 2 -> mi_luc +12 and no other row
	var c_comely := TestFixtures.character({"hoa": 60}, 45, 0)
	c_comely.npc_traits = {"talent": [{"id": "comely", "tier": 2}]}
	var s_comely := StatSheet.build(c_comely, gd, null, null)
	assert_near(s_comely.total("mi_luc"), 12.0, 1e-6, "Beautiful +12 mi_luc")
	assert_eq(s_comely.stat_keys(), ["mi_luc"], "no other stat rows for comely 2")
	# StatSheet ordering: trait talent tier raises effective can_cot/ngo_tinh BEFORE CongPhap.bonus_lines
	var db := WorldDB.new()
	var items := ItemFactory.new(gd)
	var manual: Dictionary = items.cong_phap(rng(5), 2, ["hoa"])
	var c_base := TestFixtures.character({"hoa": 70}, 45, 1)
	CongPhap.learn(c_base, manual)
	c_base.main_tech = str(manual.tech_id)
	c_base.techniques[c_base.main_tech]["layer"] = 6
	var c_boosted := Character.from_dict(c_base.to_dict())
	c_boosted.npc_traits = {"talent": [{"id": "quick_minded", "tier": 3}, {"id": "sturdy_frame", "tier": 3}]}
	var lines_base: Array = CongPhap.bonus_lines(c_base, gd, 45.0, 45.0)
	var lines_boosted: Array = CongPhap.bonus_lines(c_boosted, gd, 65.0, 65.0)
	var sheet_boosted := StatSheet.build(c_boosted, gd, db, null)
	if not lines_base.is_empty() and not lines_boosted.is_empty():
		var stat_k: String = str(lines_boosted[0].stat)
		var cp_val: float = 0.0
		for m in sheet_boosted.sources(stat_k):
			if str(m.source) == str(lines_boosted[0].source):
				cp_val += float(m.value)
		assert_near(cp_val, float(lines_boosted[0].value), 0.11, "CongPhap reads effective talent after trait mods")


# --- AC-NT-40: Rule 2a caps and opposition ---------------------------------------------------------------------------

func test_ac_nt_40_rule_2a_caps_and_opposition() -> void:
	var gd := game_data()
	var p := {"id": "p1", "npc_traits": {"personality": ["brave", "honest", "calm"], "calling": "duelist",
		"fate": ["spirit_eyed"], "gained": [], "upbringing": "village_born", "talent": [], "path": [],
		"lifestyle": "", "health": [], "coping": {}}}
	# Events never grant upbringing or talent
	assert_eq(NpcTraits.grant_v2(gd, p, "clan_heir", 10), "refused", "upbringing refused for events")
	assert_eq(NpcTraits.grant_v2(gd, p, "quick_minded", 10), "refused", "talent refused for events")
	assert_eq(str(p.npc_traits.upbringing), "village_born", "upbringing unchanged")
	# Creation-time talent caps & opposition
	assert_eq(NpcTraits.add_talent(gd, p, "keen_soul", 2, 2), "granted", "keen_soul allowed with Spirit-eyed")
	assert_eq(NpcTraits.add_talent(gd, p, "thin_soul", 1, 2), "refused", "thin_soul refused with Spirit-eyed")
	assert_eq(NpcTraits.add_talent(gd, p, "quick_minded", 1, 2), "granted", "2nd talent granted")
	assert_eq(NpcTraits.add_talent(gd, p, "slow_witted", 1, 2), "refused", "opposed talent refused")
	assert_eq(NpcTraits.add_talent(gd, p, "sturdy_frame", 1, 2), "refused", "3rd talent refused at cap 2")
	assert_eq(NpcTraits.add_talent(gd, p, "sturdy_frame", 1, 3), "granted", "3rd talent allowed for tier A cap 3")
	assert_eq(NpcTraits.add_talent(gd, p, "lucky", 1, 3), "refused", "4th talent always refused")
	# Path cap 2 + opposed replacement
	assert_eq(NpcTraits.grant_v2(gd, p, "perfect_foundation", 10), "granted", "1st path")
	assert_eq(NpcTraits.grant_v2(gd, p, "sword_heart", 10), "granted", "2nd path")
	assert_eq(NpcTraits.grant_v2(gd, p, "body_tempered", 10), "refused", "3rd non-opposed path refused")
	assert_eq(NpcTraits.grant_v2(gd, p, "flawed_foundation", 10), "replaced", "opposed path replaces opposite")
	assert_eq(p.npc_traits.path, ["flawed_foundation", "sword_heart"], "perfect_foundation replaced")
	# Lifestyle cap 1 replaces old
	assert_eq(NpcTraits.grant_v2(gd, p, "tea_master", 10), "granted", "1st lifestyle")
	assert_eq(NpcTraits.grant_v2(gd, p, "poet", 11), "replaced", "2nd lifestyle replaces old")
	assert_eq(str(p.npc_traits.lifestyle), "poet", "exactly 1 lifestyle")
	# Health cap 2 (non-waning refused)
	assert_eq(NpcTraits.grant_v2(gd, p, "old_wound", 10), "granted", "1st health")
	assert_eq(NpcTraits.grant_v2(gd, p, "maimed", 11), "granted", "2nd health")
	assert_eq(NpcTraits.grant_v2(gd, p, "blind", 12), "refused", "3rd non-waning health refused")
	assert_eq(p.npc_traits.health, ["old_wound", "maimed"], "health stays at 2")


# --- AC-NT-41: F3 likes and dislikes ---------------------------------------------------------------------------------

func test_ac_nt_41_f3_likes_and_dislikes() -> void:
	var gd := game_data()
	var db := WorldDB.new()
	# Two Reclusive, Hermit-taught people -> op = 20 each way
	var a := _person_with({"personality": ["reclusive"], "calling": "", "fate": [], "gained": [], "upbringing": "hermit_taught"}, "a")
	var b := _person_with({"personality": ["reclusive"], "calling": "", "fate": [], "gained": [], "upbringing": "hermit_taught"}, "b")
	assert_near(NpcTraits.opinion(gd, db, a, b), 20.0, 1e-6, "Hermit-taught + Reclusive: +10 shared + 10 lk = 20")
	assert_near(NpcTraits.opinion(gd, db, b, a), 20.0, 1e-6, "symmetric 20")
	# Street orphan vs Clan heir -> lk = -10 each way
	var so := _person_with({"personality": [], "calling": "", "fate": [], "gained": [], "upbringing": "street_orphan"}, "so")
	var ch := _person_with({"personality": [], "calling": "", "fate": [], "gained": [], "upbringing": "clan_heir"}, "ch")
	assert_near(NpcTraits.opinion_lk(gd, so, ch), -10.0, 1e-6, "street_orphan dislikes clan_heir")
	assert_near(NpcTraits.opinion_lk(gd, ch, so), -10.0, 1e-6, "clan_heir dislikes street_orphan")
	# Sect-raised vs Loyal -> directed: +5 vs 0
	var sr := _person_with({"personality": [], "calling": "", "fate": [], "gained": [], "upbringing": "sect_raised"}, "sr")
	var lo := _person_with({"personality": ["loyal"], "calling": "", "fate": [], "gained": []}, "lo")
	assert_near(NpcTraits.opinion_lk(gd, sr, lo), 5.0, 1e-6, "sect_raised likes Loyal (+5)")
	assert_near(NpcTraits.opinion_lk(gd, lo, sr), 0.0, 1e-6, "directed: Loyal has no v2 likes (0)")
	# Two quick_minded holders at tiers 1 and 3 -> lk = +5 each way
	var q1 := _person_with({"personality": [], "calling": "", "fate": [], "gained": [], "talent": [{"id": "quick_minded", "tier": 1}]}, "q1")
	var q3 := _person_with({"personality": [], "calling": "", "fate": [], "gained": [], "talent": [{"id": "quick_minded", "tier": 3}]}, "q3")
	assert_near(NpcTraits.opinion_lk(gd, q1, q3), 5.0, 1e-6, "talent matches across tiers")
	assert_near(NpcTraits.opinion_lk(gd, q3, q1), 5.0, 1e-6, "symmetric across tiers")


# --- AC-NT-42: F4b cap, determinism, and path root bonds -------------------------------------------------------------

func test_ac_nt_42_f4b_caps_determinism_and_root_bonds() -> void:
	var gd := game_data()
	var saw_talent_cap: bool = false
	var saw_fate_cap: bool = false
	for i in 400:
		var t: Dictionary = NpcTraits.roll(gd, "cap:%d" % i, "kiem_tu", false, [], {}, {"realm_index": 2, "birthplace_kind": "city"})
		assert_true(str(t.upbringing) != "", "every rolled person holds 1 upbringing")
		var total_n: int = NpcTraits.held({"npc_traits": t}).size()
		if Array(t.fate).is_empty() and Array(t.talent).size() == 1:
			saw_talent_cap = true
			assert_eq(total_n, 6, "0 fate + 1 talent -> exactly 6 traits")
			assert_true(Array(t.path).is_empty() and Array(t.health).is_empty() and str(t.lifestyle) == "" and Dictionary(t.coping).is_empty(),
				"no optional draw after cap 6")
		if Array(t.fate).size() == 1:
			saw_fate_cap = true
			assert_eq(total_n, 6, "1 fate -> cap 6 reached, no optional v2")
			assert_true(Array(t.talent).is_empty() and Array(t.path).is_empty() and Array(t.health).is_empty()
				and str(t.lifestyle) == "" and Dictionary(t.coping).is_empty(), "1 fate skips all optional v2 draws")
	assert_true(saw_talent_cap and saw_fate_cap, "observed both cap scenarios")
	# Child with 1 fate + 2 inherited talents keeps all (8 traits) and skips optional draws
	var par_a := {"personality": ["brave", "honest", "calm"], "talent": [{"id": "quick_minded", "tier": 3}, {"id": "sturdy_frame", "tier": 3}]}
	var par_b := {"personality": ["brave", "honest", "calm"], "talent": [{"id": "quick_minded", "tier": 3}, {"id": "sturdy_frame", "tier": 3}]}
	var saw_8: bool = false
	for i in 1500:
		var child: Dictionary = NpcTraits.roll(gd, "inh8:%d" % i, "kiem_tu", false, [], {}, {"parents": [par_a, par_b], "realm_index": 3})
		if Array(child.fate).size() == 1 and Array(child.talent).size() == 2:
			saw_8 = true
			assert_eq(NpcTraits.held({"npc_traits": child}).size(), 8, "1 fate + 2 inherited talents = 8 traits")
			assert_true(Array(child.path).is_empty() and str(child.lifestyle) == "" and Array(child.health).is_empty() and Dictionary(child.coping).is_empty(),
				"no optional v2 draws past cap")
			break
	assert_true(saw_8, "observed 1 fate + 2 inherited talents keeping all 8 traits")
	# Determinism: person 4,321 rolled alone equals full run
	var solo: Dictionary = NpcTraits.roll(gd, "seed9:p4321", "dan_su", true, [], {"ngo_tinh": 60}, {"realm_index": 1, "birthplace_kind": "village"})
	assert_eq(solo, NpcTraits.roll(gd, "seed9:p4321", "dan_su", true, [], {"ngo_tinh": 60}, {"realm_index": 1, "birthplace_kind": "village"}), "keyed deterministic")
	# Path root bonds
	var lc_water := LinhCan.from_dict({"elements": {"thuy": 60}})
	var lc_fire := LinhCan.from_dict({"elements": {"hoa": 60}})
	var lc_fm := LinhCan.from_dict({"elements": {"hoa": 50, "kim": 50}})
	assert_true(NpcTraits.path_bond_met(gd, "frost_veined", lc_water), "frost_veined accepts Water")
	assert_false(NpcTraits.path_bond_met(gd, "frost_veined", lc_fire), "frost_veined rejects Fire-only")
	assert_true(NpcTraits.path_bond_met(gd, "fire_tempered", lc_fire), "fire_tempered accepts Fire")
	assert_true(NpcTraits.path_bond_met(gd, "thunder_struck", lc_fm), "thunder_struck accepts Fire+Metal")
	assert_false(NpcTraits.path_bond_met(gd, "thunder_struck", lc_fire), "thunder_struck rejects Fire-only")
	assert_true(NpcTraits.path_bond_met(gd, "pure_root_devotee", lc_fire), "pure_root_devotee accepts single base")
	assert_false(NpcTraits.path_bond_met(gd, "pure_root_devotee", lc_fm), "pure_root_devotee rejects dual base")


# --- AC-NT-43: F4b world statistics (4,000 rolls) --------------------------------------------------------------------

func test_ac_nt_43_f4b_world_statistics() -> void:
	var gd := game_data()
	var n: int = 4000
	var c5: int = 0
	var c6: int = 0
	var c7: int = 0
	var n_tal: int = 0
	var n_life: int = 0
	var n_path: int = 0
	var n_hp: int = 0
	var n_cop: int = 0
	var tiers := [0, 0, 0]
	var lc_all := LinhCan.from_dict({"elements": {"hoa": 50, "thuy": 50, "kim": 50}})
	for i in n:
		var pct: int = i % 100
		var ri: int = 0 if pct < 70 else (1 if pct < 92 else (2 if pct < 98 else 3))
		var t: Dictionary = NpcTraits.roll(gd, "stat:%d" % i, "tan_tu", false, [], {}, {"realm_index": ri, "linh_can": lc_all})
		var cnt: int = NpcTraits.held({"npc_traits": t}).size()
		if cnt == 5:
			c5 += 1
		elif cnt == 6:
			c6 += 1
		elif cnt == 7:
			c7 += 1
		if not Array(t.talent).is_empty():
			n_tal += 1
			for te in t.talent:
				tiers[int(te.tier) - 1] += 1
		if str(t.lifestyle) != "":
			n_life += 1
		if not Array(t.path).is_empty():
			n_path += 1
		if not Array(t.health).is_empty():
			n_hp += 1
		if not Dictionary(t.coping).is_empty():
			n_cop += 1
	var p5: float = 100.0 * c5 / n
	var p6: float = 100.0 * c6 / n
	var p7: float = 100.0 * c7 / n
	var ptal: float = 100.0 * n_tal / n
	var plife: float = 100.0 * n_life / n
	var ppath: float = 100.0 * n_path / n
	var php: float = 100.0 * n_hp / n
	var pcop: float = 100.0 * n_cop / n
	var t_sum: int = maxi(1, tiers[0] + tiers[1] + tiers[2])
	var t1: float = 100.0 * tiers[0] / t_sum
	var t2: float = 100.0 * tiers[1] / t_sum
	var t3: float = 100.0 * tiers[2] / t_sum
	assert_true(p5 >= 33.0 and p5 <= 41.0, "5 traits 33-41 %% (got %.2f %%)" % p5)
	assert_true(p6 >= 58.0 and p6 <= 66.0, "6 traits 58-66 %% (got %.2f %%)" % p6)
	assert_true(p7 <= 1.0, "7 traits <= 1 %% (got %.2f %%)" % p7)
	assert_true(ptal >= 21.0 and ptal <= 27.0, "talent 21-27 %% (got %.2f %%)" % ptal)
	assert_true(plife >= 17.0 and plife <= 23.0, "lifestyle 17-23 %% (got %.2f %%)" % plife)
	assert_true(ppath >= 6.0 and ppath <= 11.0, "path 6-11 %% (got %.2f %%)" % ppath)
	assert_true(php >= 3.5 and php <= 6.5, "health 3.5-6.5 %% (got %.2f %%)" % php)
	assert_true(pcop >= 0.5 and pcop <= 2.0, "coping 0.5-2.0 %% (got %.2f %%)" % pcop)
	assert_true(absf(t1 - 70.0) <= 3.0 and absf(t2 - 24.0) <= 3.0 and absf(t3 - 6.0) <= 3.0,
		"tiers 70/24/6 +-3 pp (got %.1f/%.1f/%.1f)" % [t1, t2, t3])


# --- AC-NT-44: F5b talent inheritance with drift ---------------------------------------------------------------------

func test_ac_nt_44_f5b_talent_inheritance_drift() -> void:
	var gd := game_data()
	var n: int = 10000
	# Case 1: both parents hold quick_minded (tiers 3 and 2) -> tier 3 ~39 %, tier 2 ~26 %, none ~35 %
	var pa := {"talent": [{"id": "quick_minded", "tier": 3}]}
	var pb := {"talent": [{"id": "quick_minded", "tier": 2}]}
	var b_t3: int = 0
	var b_t2: int = 0
	var b_none: int = 0
	for i in n:
		var got: Array = NpcTraits.inherit_talents(gd, "f5b_both:%d" % i, [pa, pb])
		if got.is_empty():
			b_none += 1
		elif int(got[0].tier) == 3:
			b_t3 += 1
		elif int(got[0].tier) == 2:
			b_t2 += 1
	assert_true(absf(100.0 * b_t3 / n - 39.0) <= 2.0, "both parents tier 3 ~39 %% (got %.2f %%)" % (100.0 * b_t3 / n))
	assert_true(absf(100.0 * b_t2 / n - 26.0) <= 2.0, "both parents tier 2 ~26 %% (got %.2f %%)" % (100.0 * b_t2 / n))
	assert_true(absf(100.0 * b_none / n - 35.0) <= 2.0, "both parents none ~35 %% (got %.2f %%)" % (100.0 * b_none / n))
	# Case 2: one parent with sturdy_frame 1 -> tier 1 ~15.75 %, tier 2 ~5.25 %, none ~79 %
	var p1 := {"talent": [{"id": "sturdy_frame", "tier": 1}]}
	var s_t1: int = 0
	var s_t2: int = 0
	var s_none: int = 0
	for i in n:
		var got: Array = NpcTraits.inherit_talents(gd, "f5b_one:%d" % i, [p1])
		if got.is_empty():
			s_none += 1
		elif int(got[0].tier) == 1:
			s_t1 += 1
		elif int(got[0].tier) == 2:
			s_t2 += 1
	assert_true(absf(100.0 * s_t1 / n - 15.75) <= 1.5, "one parent tier 1 ~15.75 %% (got %.2f %%)" % (100.0 * s_t1 / n))
	assert_true(absf(100.0 * s_t2 / n - 5.25) <= 1.5, "one parent tier 2 ~5.25 %% (got %.2f %%)" % (100.0 * s_t2 / n))
	assert_true(absf(100.0 * s_none / n - 79.0) <= 1.5, "one parent none ~79 %% (got %.2f %%)" % (100.0 * s_none / n))
	# Case 3: opposed gift and flaw both passing cancel both
	var pg := {"talent": [{"id": "quick_minded", "tier": 3}]}
	var pf := {"talent": [{"id": "slow_witted", "tier": 3}]}
	var saw_cancel: bool = false
	for i in 200:
		var key: String = "f5b_cancel:%d" % i
		var g_only: Array = NpcTraits.inherit_talents(gd, key, [pg])
		var f_only: Array = NpcTraits.inherit_talents(gd, key, [pf])
		if not g_only.is_empty() and not f_only.is_empty():
			var both_got: Array = NpcTraits.inherit_talents(gd, key, [pg, pf])
			assert_true(both_got.is_empty(), "opposed gift + flaw both cancel")
			saw_cancel = true
			break
	assert_true(saw_cancel, "observed opposed gift+flaw cancellation")
	# Case 4: 3 inherited families keep top 2 by descending tier (ties by catalogue order)
	var p3a := {"talent": [{"id": "quick_minded", "tier": 2}, {"id": "sturdy_frame", "tier": 3}, {"id": "lucky", "tier": 3}]}
	var p3b := {"talent": [{"id": "quick_minded", "tier": 2}, {"id": "sturdy_frame", "tier": 3}, {"id": "lucky", "tier": 3}]}
	var saw_cap2: bool = false
	for i in 500:
		var key: String = "f5b_top2:%d" % i
		var got: Array = NpcTraits.inherit_talents(gd, key, [p3a, p3b])
		assert_true(got.size() <= 2, "at most 2 inherited families")
		# Check when all 3 pass individually
		var g1: Array = NpcTraits.inherit_talents(gd, key, [{"talent": [{"id": "quick_minded", "tier": 2}]}, {"talent": [{"id": "quick_minded", "tier": 2}]}])
		var g2: Array = NpcTraits.inherit_talents(gd, key, [{"talent": [{"id": "sturdy_frame", "tier": 3}]}, {"talent": [{"id": "sturdy_frame", "tier": 3}]}])
		var g3: Array = NpcTraits.inherit_talents(gd, key, [{"talent": [{"id": "lucky", "tier": 3}]}, {"talent": [{"id": "lucky", "tier": 3}]}])
		if not g1.is_empty() and not g2.is_empty() and not g3.is_empty():
			var all3: Array = [g1[0], g2[0], g3[0]]
			all3.sort_custom(func(x, y): return int(x.tier) > int(y.tier))
			assert_eq(got.size(), 2, "capped to 2")
			assert_true(int(got[0].tier) >= int(got[1].tier), "sorted descending by tier")
			assert_true(int(got[1].tier) >= int(all3[2].tier), "lowest tier dropped")
			saw_cap2 = true
			break
	assert_true(saw_cap2, "observed top-2 tier selection")


# --- AC-NT-45: F6b coping fade and hardening -------------------------------------------------------------------------

func test_ac_nt_45_f6b_coping_fade_and_hardening() -> void:
	var gd := game_data()
	var p := {"id": "p1", "npc_traits": {}}
	assert_eq(NpcTraits.grant_v2(gd, p, "drowns_in_wine", 50), "granted", "granted at 50")
	assert_eq(int(p.npc_traits.coping.expires), 70, "expires at 70")
	assert_eq(NpcTraits.grant_v2(gd, p, "drowns_in_wine", 60), "refreshed", "repeat at 60")
	assert_eq(int(p.npc_traits.coping.expires), 80, "expires at 80")
	assert_eq(int(p.npc_traits.coping.refreshes), 1, "refreshes 1")
	NpcTraits.fade(p, 79)
	assert_eq(str(p.npc_traits.coping.get("id", "")), "drowns_in_wine", "still held at 79")
	NpcTraits.fade(p, 80)
	assert_true(Dictionary(p.npc_traits.coping).is_empty(), "faded at 80")
	# Hardening after 3 repeats (90 -> 100, 110, 120)
	assert_eq(NpcTraits.grant_v2(gd, p, "drowns_in_wine", 90), "granted", "granted again at 90")
	assert_eq(NpcTraits.grant_v2(gd, p, "drowns_in_wine", 100), "refreshed", "repeat 1")
	assert_eq(NpcTraits.grant_v2(gd, p, "drowns_in_wine", 110), "refreshed", "repeat 2")
	assert_false(bool(p.npc_traits.coping.hardened), "not yet hardened at 2")
	assert_eq(NpcTraits.grant_v2(gd, p, "drowns_in_wine", 120), "refreshed", "repeat 3 hardens")
	assert_true(bool(p.npc_traits.coping.hardened), "hardened at 120")
	assert_false(Dictionary(p.npc_traits.coping).has("expires"), "expiry cleared on harden")
	NpcTraits.fade(p, 1000)
	assert_eq(str(p.npc_traits.coping.get("id", "")), "drowns_in_wine", "still held at 1,000")
	assert_eq(NpcTraits.grant_v2(gd, p, "rage_flares", 1001), "refused", "new coping refused while hardened")
	assert_true(NpcTraits.remove_v2(gd, p, "drowns_in_wine"), "deed removes hardened coping")
	assert_true(Dictionary(p.npc_traits.coping).is_empty(), "hardened coping gone after deed")


# --- AC-NT-46: F6b Waning years --------------------------------------------------------------------------------------

func test_ac_nt_46_f6b_waning_years() -> void:
	var gd := game_data()
	var p := {"id": "p1", "npc_traits": {"health": ["old_wound", "maimed"]}}
	assert_false(NpcTraits.update_waning(gd, p, 449.0, 500.0), "51 years left > 10 %%: no waning")
	assert_true(NpcTraits.update_waning(gd, p, 450.0, 500.0), "50 years left == 10 %%: waning granted")
	assert_eq(p.npc_traits.health, ["maimed", "waning_years"], "replaces older health[0] when full")
	NpcTraits.fade(p, 9999)
	assert_eq(p.npc_traits.health, ["maimed", "waning_years"], "health traits never fade")
	assert_true(NpcTraits.update_waning(gd, p, 450.0, 520.0), "pill extends lifespan -> 70/520 > 10 %%: waning removed")
	assert_eq(p.npc_traits.health, ["maimed"], "waning_years gone")


# --- AC-NT-47: Rule 8a hooks, dialogue verbs, and policy pulls -------------------------------------------------------

func test_ac_nt_47_rule_8a_hooks_verbs_and_policy_pulls() -> void:
	var gd := game_data()
	var stub := [
		{"id": "share_tea", "side": "either"},
		{"id": "haggle", "side": "self"},
		{"id": "ask_history", "side": "other"},
	]
	var plain := _person_with({}, "plain")
	var tea := _person_with({"lifestyle": "tea_master"}, "tea")
	var merch := _person_with({"upbringing": "merchant_child"}, "merch")
	var chron := _person_with({"lifestyle": "chronicler"}, "chron")
	var gamb := _person_with({"lifestyle": "gambler"}, "gamb")
	# share_tea (either)
	assert_eq(NpcTraits.available_verbs(gd, tea, plain, stub), ["share_tea"], "Tea-master player sees share_tea with anyone")
	assert_eq(NpcTraits.available_verbs(gd, plain, tea, stub), ["share_tea"], "plain player sees share_tea with Tea-master")
	assert_eq(NpcTraits.available_verbs(gd, plain, plain, stub), [], "plain vs plain: no share_tea")
	# haggle (self)
	assert_eq(NpcTraits.available_verbs(gd, merch, plain, stub), ["haggle"], "Merchant's-child player sees haggle with anyone")
	assert_eq(NpcTraits.available_verbs(gd, plain, merch, stub), [], "plain player never sees haggle")
	# ask_history (other)
	assert_eq(NpcTraits.available_verbs(gd, chron, plain, stub), [], "Chronicler player alone does not see ask_history")
	assert_eq(NpcTraits.available_verbs(gd, chron, chron, stub), ["ask_history"], "Chronicler player sees ask_history with another Chronicler")
	# Unregistered hook (gambler -> verb:wager not in stub)
	assert_eq(NpcTraits.available_verbs(gd, gamb, plain, stub), [], "unregistered verb hook adds nothing")
	assert_true(NpcTraits.opened_hooks(gd, gamb).has("verb:wager"), "opened_hooks still reports verb:wager")
	# Policy hooks into Sects F15 pulls
	var p_sr := NpcTraits.pulls(gd, _person_with({"upbringing": "sect_raised"}))
	assert_near(float(p_sr.dials.get("openness", 0.0)), -1.0, 1e-6, "policy:tradition -> openness -1")
	var p_mc := NpcTraits.pulls(gd, merch)
	assert_eq(str(p_mc.first_track), "trade", "policy:trade -> first_track trade")
	var p_go := NpcTraits.pulls(gd, _person_with({"lifestyle": "go_player"}))
	assert_near(float(p_go.war_odds), 1.2, 1e-6, "policy:caution -> war_odds 1.2")
	var p_th := NpcTraits.pulls(gd, _person_with({"lifestyle": "teacher_at_heart"}))
	assert_near(float(p_th.dials.get("openness", 0.0)), 1.0, 1e-6, "policy:openness -> openness +1")


# --- AC-NT-49 & AC-NT-24: Retired fates migration, 10k F4 draws, Callous+Cruel ---------------------------------------

func test_ac_nt_49_retired_fates_migration_and_10k_f4_rolls() -> void:
	var gd := game_data()
	var expected := {
		"Wise-born": ["quick_minded", 3],
		"Iron-boned": ["sturdy_frame", 3],
		"Heaven-favoured": ["lucky", 3],
		"Ill-starred": ["unlucky", 3],
		"Dull-witted": ["slow_witted", 3],
		"Frail": ["frail_frame", 1],
	}
	for fname in expected:
		var t: Dictionary = NpcTraits.from_authored(gd, {"personality": ["Honest", "Just", "Cautious"],
			"calling": "Strategist", "fate_given": [fname], "upbringing": "village_born"})
		assert_true(Array(t.fate).is_empty(), "%s removed from fate" % fname)
		assert_eq(t.talent, [{"id": expected[fname][0], "tier": expected[fname][1]}], "%s loads as talent tier" % fname)
	# Higher tier kept when family already held
	var merged: Dictionary = NpcTraits.migrate_retired_fates(gd, {"fate": ["heaven_favoured"], "talent": [{"id": "lucky", "tier": 1}]})
	assert_eq(merged.talent, [{"id": "lucky", "tier": 3}], "keeps higher tier (3 > 1)")
	var kept_hi: Dictionary = NpcTraits.migrate_retired_fates(gd, {"fate": ["Frail"], "talent": [{"id": "frail_frame", "tier": 3}]})
	assert_eq(kept_hi.talent, [{"id": "frail_frame", "tier": 3}], "keeps higher tier (3 > 1)")
	# Opposed family dropped cleanly on migration
	var replaced_opp: Dictionary = NpcTraits.migrate_retired_fates(gd, {"fate": ["Wise-born"], "talent": [{"id": "slow_witted", "tier": 2}]})
	assert_eq(replaced_opp.talent, [{"id": "quick_minded", "tier": 3}], "opposed family dropped on retired fate migration")
	# 10,000 F4 rolls: no retired fate ever drawn, kept fate rate within 3.0-5.0 %, and AC-NT-24 Callous+Cruel allowed
	var kept_set := {"spirit_eyed": true, "hollow_souled": true, "pure_hearted": true, "demon_seeded": true}
	var with_fate: int = 0
	var callous_and_cruel: int = 0
	var cat := NpcTraits.catalogue(gd)
	for i in 10000:
		var r: Dictionary = NpcTraits.roll(gd, "f4_10k:%d" % i, "tan_tu", false)
		var flist: Array = Array(r.fate)
		if not flist.is_empty():
			with_fate += 1
		for fid in flist:
			assert_true(kept_set.has(str(fid)), "only kept fates drawn (got %s)" % str(fid))
		var plist: Array = Array(r.personality)
		if plist.has("callous") and plist.has("cruel"):
			callous_and_cruel += 1
		for a_i in plist.size():
			for b_i in range(a_i + 1, plist.size()):
				assert_false(NpcTraits.is_opposed(gd, str(plist[a_i]), str(plist[b_i])),
					"no opposed personality pair: %s" % str(plist))
	var f_pct: float = 100.0 * with_fate / 10000.0
	assert_true(f_pct >= 3.0 and f_pct <= 5.0, "AC-NT-35/49 fate rate 3-5 %% (got %.2f %%)" % f_pct)
	assert_true(callous_and_cruel > 0, "AC-NT-24 Callous+Cruel appeared at least once (got %d)" % callous_and_cruel)
	assert_true(cat.by_id.has("spirit_eyed"), "catalogue indexed")


# --- AC-NT-51: 15 choice-weighted v2 traits & F7 alignment -----------------------------------------------------------

func test_ac_nt_51_v2_choice_weights_and_f7_alignment() -> void:
	var gd := game_data()
	var f: Dictionary = gd.file(NpcTraits.FILE)
	var weighted_v2: Array = []
	var unweighted_v2: Array = []
	for k in NpcTraits.KINDS_V2:
		for t in f.get(k, []):
			var tw: Dictionary = t.get("tags", {})
			if not tw.is_empty():
				weighted_v2.append(str(t.id))
				assert_true(tw.size() >= 1 and tw.size() <= 3, "%s: 1-3 tags" % t.id)
				for w in tw.values():
					assert_true(is_equal_approx(float(w), 1.5) or is_equal_approx(float(w), 0.67), "%s: 1.5 or 0.67 only" % t.id)
			else:
				unweighted_v2.append({"kind": k, "id": str(t.id)})
	assert_eq(weighted_v2.size(), 15, "exactly 15 weighted v2 traits")
	# Talent and health traits stay stat-only (1.0 on every tag, neither with nor against)
	var p_stat_only := _person_with({"talent": [{"id": "quick_minded", "tier": 3}], "health": ["old_wound"], "upbringing": "village_born"})
	assert_near(NpcTraits.choice_weight(gd, p_stat_only, ["aggressive", "merciful", "cautious"]), 1.0, 1e-9, "stat-only v2 traits weight 1.0")
	assert_eq(NpcTraits.choice_alignment(gd, p_stat_only, ["aggressive", "merciful"]), {"with": 0, "against": 0}, "stat-only v2 neutral in F7")
	# Demonic path: aggressive -> 1.5 / with; merciful -> 0.67 / against
	var p_dem := _person_with({"path": ["demonic_path"]})
	assert_near(NpcTraits.choice_weight(gd, p_dem, ["aggressive"]), 1.5, 1e-9, "demonic_path aggressive x1.5")
	assert_eq(NpcTraits.choice_alignment(gd, p_dem, ["aggressive"]), {"with": 1, "against": 0}, "demonic_path with aggressive")
	assert_near(NpcTraits.choice_weight(gd, p_dem, ["merciful"]), 0.67, 1e-9, "demonic_path merciful x0.67")
	assert_eq(NpcTraits.choice_alignment(gd, p_dem, ["merciful"]), {"with": 0, "against": 1}, "demonic_path against merciful")
	# F7 netting: Wrathful on [aggressive, cautious] -> 1.5 * 0.67 = 1.005 -> neither
	var p_wrath := _person_with({"personality": ["wrathful"]})
	assert_eq(NpcTraits.choice_alignment(gd, p_wrath, ["aggressive", "cautious"]), {"with": 0, "against": 0}, "1.005 counts neither")
	assert_eq(NpcTraits.choice_alignment(gd, p_wrath, ["cautious"]), {"with": 0, "against": 1}, "cautious alone counts against")


# --- AC-NT-52: F3 lk drift over 10,000 pairs -------------------------------------------------------------------------

func test_ac_nt_52_f3_lk_drift_over_10k_pairs() -> void:
	var gd := game_data()
	var pop: Array = []
	var lc := LinhCan.from_dict({"elements": {"hoa": 50, "thuy": 50}})
	for i in 400:
		var ri: int = 0 if i % 10 < 7 else (1 if i % 10 < 9 else 2)
		pop.append({"id": "lk_%d" % i, "npc_traits": NpcTraits.roll(gd, "lk_pop:%d" % i, "tan_tu", false, [], {}, {"realm_index": ri, "linh_can": lc})})
	var r := RandomNumberGenerator.new()
	r.seed = 20261127
	var sum_lk: float = 0.0
	var pairs: int = 10000
	for _k in pairs:
		var ia: int = r.randi_range(0, pop.size() - 1)
		var ib: int = (ia + 1 + r.randi_range(0, pop.size() - 2)) % pop.size()
		sum_lk += NpcTraits.opinion_lk(gd, pop[ia], pop[ib])
	var mean_lk: float = sum_lk / float(pairs)
	assert_true(mean_lk >= -3.0 and mean_lk <= 3.0, "AC-NT-52 mean lk within [-3, +3] (got %.4f)" % mean_lk)


# --- AC-NT-54: Scoped rows (Hunter [creature] & One-element devotee [own_top_element]) -------------------------------

func test_ac_nt_54_scoped_rows_through_stat_sheet_and_fighter_compiler() -> void:
	var gd := game_data()
	var db := WorldDB.new()
	# 1. Hunter: attack_pct +2 [creature]
	var c_hunt := TestFixtures.character({"hoa": 60}, 50, 1)
	c_hunt.npc_traits = {"lifestyle": "hunter"}
	var s_hunt := StatSheet.build(c_hunt, gd, db, null)
	assert_eq(s_hunt.total("attack_pct"), 0.0, "Hunter scoped attack_pct stays out of unscoped total")
	var h_scoped: Array = s_hunt.scoped("attack_pct")
	assert_eq(h_scoped.size(), 1, "one scoped attack_pct line")
	assert_eq(h_scoped[0].scope, ["creature"], "scoped to creature")
	var bf_hunt: Dictionary = FighterCompiler.character_build_file(c_hunt, gd, db, s_hunt)
	assert_true(bf_hunt.modifiers.any(func(l): return str(l.key) == "attack_pct" and is_equal_approx(float(l.value), 2.0) and Array(l.get("scope", [])) == ["creature"]),
		"Hunter line reaches build file with creature scope")
	var p_hunt: FighterProfile = FighterCompiler.compile(c_hunt, gd, db, s_hunt)
	assert_true(p_hunt != null, "Hunter compiles cleanly")
	var eff_hunt: Array = p_hunt.effects.filter(func(e): return str(e.id) == "tech:character")
	assert_eq(eff_hunt.size(), 1, "tech:character effect present")
	var k_const := CombatConstants.from_game_data(gd)
	var fight_stub := Fight.new(p_hunt, FighterCompiler.from_data("typical", 1, gd), k_const, 1)
	var hunt_mods: Array = (eff_hunt[0] as EffectDef).actions.filter(func(a): return a.verb == "mod" and a.arg.has("L1"))
	assert_eq(hunt_mods.size(), 1, "one L1 mod action from Hunter")
	assert_false(EffectRunner.matches(fight_stub, hunt_mods[0].arg, {"kind": "art", "element": "fire", "tags": []}), "normal foe without creature tag gets 0")
	assert_true(EffectRunner.matches(fight_stub, hunt_mods[0].arg, {"kind": "art", "element": "fire", "tags": ["creature"]}), "creature-tagged foe matches +2")
	# 2. One-element devotee: Fire 70, Wood 20 -> [hoa] -> engine element fire (Water art gets 0)
	var c_fire := TestFixtures.character({"hoa": 70, "moc": 20}, 50, 1)
	c_fire.npc_traits = {"path": ["pure_root_devotee"]}
	var s_fire := StatSheet.build(c_fire, gd, db, null)
	assert_eq(s_fire.scoped("attack_pct").size(), 1, "One-element devotee emits scoped attack_pct")
	assert_eq(s_fire.scoped("attack_pct")[0].scope, ["hoa"], "resolved to hoa")
	assert_near(float(s_fire.scoped("attack_pct")[0].value), 6.0, 1e-6, "+6 value")
	var p_fire: FighterProfile = FighterCompiler.compile(c_fire, gd, db, s_fire)
	var f_eff: EffectDef = p_fire.effects.filter(func(e): return str(e.id) == "tech:character")[0]
	var f_mods: Array = f_eff.actions.filter(func(a): return a.verb == "mod" and a.arg.has("L1"))
	assert_eq(str(f_mods[0].arg.get("element", "")), "fire", "compiled to engine element fire")
	assert_true(EffectRunner.matches(fight_stub, f_mods[0].arg, {"kind": "art", "element": "fire", "tags": []}), "Fire art matches +6")
	assert_false(EffectRunner.matches(fight_stub, f_mods[0].arg, {"kind": "art", "element": "water", "tags": []}), "Water art gets 0")
	# 3. Tie Fire 40, Metal 40 -> resolves to [kim] (Kim > Mộc > Thủy > Hỏa > Thổ)
	var c_tie := TestFixtures.character({"hoa": 40, "kim": 40}, 50, 1)
	c_tie.npc_traits = {"path": ["pure_root_devotee"]}
	var s_tie := StatSheet.build(c_tie, gd, db, null)
	assert_eq(s_tie.scoped("attack_pct")[0].scope, ["kim"], "tie Fire 40 / Metal 40 resolves to kim")
	# 4. Pure Wind root (no base elements) -> no row emitted
	var c_wind := Character.new()
	c_wind.linh_can = LinhCan.from_dict({"elements": {}, "variants": {"phong": 60}})
	c_wind.npc_traits = {"path": ["pure_root_devotee"]}
	var s_wind := StatSheet.build(c_wind, gd, db, null)
	assert_true(s_wind.scoped("attack_pct").is_empty(), "pure Wind root emits no own_top_element row")
