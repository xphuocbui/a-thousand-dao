extends DaoTestSuite
## World Generation Rule 8a & Formula E (AC-WG-42..48) and Living World Tick births & F21 pool intake.

const WORLD_SEED := "9001"

var _builder: WorldBuilder
var _db: WorldDB
var _spy_log: Array = []


func before() -> void:
	_spy_log = []
	var r := RandomNumberGenerator.new()
	r.seed = 9001
	_builder = WorldBuilder.new(game_data(), TestFixtures.tree())
	_builder.birth_spy = func(ev: Dictionary) -> void:
		_spy_log.append(ev)
	_db = _builder.generate(r, WORLD_SEED)


func _script(draws: Array) -> ScriptedRng:
	var out: Array = []
	for d in draws:
		out.append(d[0])
		out.append(d[1])
	return ScriptedRng.new(out)


func _make_mini_db() -> WorldDB:
	var db := WorldDB.new()
	db.put("regions", {"id": "r1", "name": "Bắc Vực", "places": ["pl_a", "pl_x", "pl_y", "pl_w1"]})
	db.put("regions", {"id": "r2", "name": "Nam Vực", "places": ["pl_s2", "pl_w2"]})
	db.put("places", {
		"id": "pl_a", "continent_id": 10, "name": "A Thành", "kind": "city", "type": "thanh",
		"region_id": "r1", "territory": "s_a", "tile": [10, 10], "density": 1.0, "qi": {},
	})
	db.put("places", {
		"id": "pl_x", "continent_id": 20, "name": "X Trấn", "kind": "town", "type": "tran",
		"region_id": "r1", "territory": "s_x", "tile": [100, 100], "density": 1.0, "qi": {},
	})
	db.put("places", {
		"id": "pl_y", "continent_id": 30, "name": "Y Trấn", "kind": "town", "type": "tran",
		"region_id": "r1", "territory": "s_y", "tile": [99, 100], "density": 1.0, "qi": {},
	})
	db.put("places", {
		"id": "pl_w1", "continent_id": 40, "name": "Bắc Sơn", "kind": "peak", "type": "son",
		"region_id": "r1", "territory": "", "tile": [50, 50], "density": 1.2, "qi": {},
	})
	db.put("places", {
		"id": "pl_s2", "continent_id": 50, "name": "Nam Thành", "kind": "city", "type": "thanh",
		"region_id": "r2", "territory": "", "tile": [200, 200], "density": 1.0, "qi": {},
	})
	db.put("places", {
		"id": "pl_w2", "continent_id": 60, "name": "Nam Cốc", "kind": "gorge", "type": "coc",
		"region_id": "r2", "territory": "", "tile": [205, 205], "density": 1.4, "qi": {},
	})
	return db


# --- AC-WG-42: Birthplace set before root roll and root before any admission test ---

func test_birthplace_set_before_root_and_before_admission_ac_wg_42() -> void:
	var gd := game_data()
	assert_true(_builder.errors.is_empty(), "world built cleanly: %s" % str(_builder.errors))
	assert_false(_spy_log.is_empty(), "birth_spy observed Rule 8a draws")

	var rolled_seen := {}
	var birth_events: int = 0
	var admission_events: int = 0
	for ev in _spy_log:
		var key: String = "%d:%d" % [int(ev.candidate_index), int(ev.try_index)]
		if str(ev.event) == "birth_rolled":
			birth_events += 1
			assert_true(str(ev.birthplace_id) != "", "birthplace set before root roll (%s)" % key)
			assert_false(rolled_seen.has(key), "one birth_rolled per (candidate, try)")
			rolled_seen[key] = ev
			# Verify root equals LinhCan.roll for that birthplace's province and stream
			var brng := RandomNumberGenerator.new()
			brng.seed = RngUtils.stable_hash(str(ev.stream_key))
			if str(ev.phase) == "sect":
				brng.randf()   # u_g
				brng.randf()   # place pick
			else:
				brng.randf()   # region place pick
			var expected_lc: LinhCan = LinhCan.roll(gd, brng, LinhCan.province_land(gd, ev.birthplace))
			assert_eq((ev.linh_can as LinhCan).to_dict(), expected_lc.to_dict(),
				"rolled root matches LinhCan.roll(birthplace province, stream) for %s" % key)
		elif str(ev.event) == "admission_test":
			admission_events += 1
			assert_true(rolled_seen.has(key), "birthplace & root rolled strictly before admission test (%s)" % key)
	assert_true(birth_events > 0, "observed birth rolls: %d" % birth_events)
	assert_true(admission_events > 0, "observed admission tests: %d" % admission_events)

	# Every random cultivator in the built world carries a valid settled birthplace
	var settled_kinds: Array = gd.world_gen().continent.settled_kinds
	var random_people: Array = _db.find("people", func(p): return p.alive and str(p.get("created_by", "")) == "worldgen")
	assert_true(random_people.size() > 0, "random cultivators exist")
	for p in random_people:
		var bp_id: String = str(p.get("birthplace", ""))
		assert_true(bp_id != "", "random person %s has birthplace" % p.id)
		var bp: Dictionary = _db.get_record("places", bp_id)
		assert_false(bp.is_empty(), "birthplace %s exists in DB" % bp_id)
		assert_true(settled_kinds.has(str(bp.get("kind", ""))), "birthplace %s is settled (kind=%s)" % [bp_id, bp.get("kind", "")])


# --- AC-WG-43: Formula E own-ground cutoff, Wind exemption, weighted draw shares ---

func test_formula_e_birthplace_draw_and_weights_ac_wg_43() -> void:
	var own_p := [{"id": "own_1"}, {"id": "own_2"}, {"id": "own_3"}]
	var own_w := [4.0, 3.0, 1.0]
	var all_p := [{"id": "cont_1"}, {"id": "cont_2"}]
	var all_w := [1.0, 1.0]

	# u_g = 0.74 < 0.75 -> own ground
	var r_own := _script([["U", 0.74], ["U", 0.0]])
	var p_own: Dictionary = WorldBuilder.draw_birthplace(r_own, own_p, own_w, all_p, all_w, 0.75, false)
	assert_true(r_own.done(), "own draws exact")
	assert_eq(str(p_own.id), "own_1", "u_g 0.74 < 0.75 picks own ground")

	# u_g = 0.75 >= 0.75 -> continent
	var r_cont := _script([["U", 0.75], ["U", 0.0]])
	var p_cont: Dictionary = WorldBuilder.draw_birthplace(r_cont, own_p, own_w, all_p, all_w, 0.75, false)
	assert_true(r_cont.done(), "continent draws exact")
	assert_eq(str(p_cont.id), "cont_1", "u_g 0.75 >= 0.75 draws from continent")

	# Wind lineage with u_g = 0.10 -> still continent
	var r_wind := _script([["U", 0.10], ["U", 0.0]])
	var p_wind: Dictionary = WorldBuilder.draw_birthplace(r_wind, own_p, own_w, all_p, all_w, 0.75, true)
	assert_true(r_wind.done(), "wind draws exact")
	assert_eq(str(p_wind.id), "cont_1", "Wind lineage ignores own ground even at u_g 0.10")

	# 10,000 draws on weights 4 / 3 / 1 -> 0.50 / 0.375 / 0.125 within ±0.02
	var counts := {"own_1": 0, "own_2": 0, "own_3": 0}
	var rr := rng(20261125)
	var draws_n: int = 10000
	for _i in draws_n:
		var picked: Dictionary = WorldBuilder.draw_birthplace(rr, own_p, own_w, all_p, all_w, 1.0, false)
		counts[str(picked.id)] = int(counts[str(picked.id)]) + 1
	assert_near(float(counts["own_1"]) / float(draws_n), 0.50, 0.02, "weight 4 share ~0.50")
	assert_near(float(counts["own_2"]) / float(draws_n), 0.375, 0.02, "weight 3 share ~0.375")
	assert_near(float(counts["own_3"]) / float(draws_n), 0.125, 0.02, "weight 1 share ~0.125")


# --- AC-WG-44: Every random sect member passes SectAdmission.admits_for_rank; no-lean never refuses ---

func test_random_sect_members_pass_admission_and_no_lean_accepts_all_ac_wg_44() -> void:
	var gd := game_data()
	var checked: int = 0
	var no_lean_keys := {}
	for s in _db.find("sects", func(x): return str(x.get("status", "")) == "active"):
		if SectAdmission.is_no_lean(gd, s):
			no_lean_keys[str(s.key)] = true
		for mid in s.members:
			var m: Dictionary = _db.get_record("people", str(mid))
			if str(m.get("created_by", "")) != "worldgen":
				continue
			checked += 1
			var lc: LinhCan = LinhCan.from_dict(m.linh_can)
			assert_true(SectAdmission.admits_for_rank(gd, s, lc, str(m.sect_rank)),
				"random member %s (%s) passes %s admission at %s" % [m.id, lc.describe(gd), s.key, m.sect_rank])
	assert_true(checked > 0, "checked random sect members (%d)" % checked)
	assert_eq(no_lean_keys.size(), 11, "all 11 no-lean sects preserved with empty lineage_elements")

	# Verify in spy log that no no-lean sect ever failed an admission test
	for ev in _spy_log:
		if str(ev.event) == "admission_test" and no_lean_keys.has(str(ev.sect_key)):
			assert_true(bool(ev.passed), "no-lean sect %s never refuses for root" % ev.sect_key)


# --- AC-WG-45: Step 6 own-ground preference & Step 7 L>0 loose vs L=0 redraws/empty ---

func test_step6_own_ground_preference_and_step7_loose_vs_redraws_ac_wg_45() -> void:
	var gd := game_data()
	var people_cfg: Dictionary = gd.world_gen().people
	var cont_cfg: Dictionary = gd.world_gen().continent
	var saved_n: int = int(people_cfg.world_cultivators)
	var saved_min: int = int(people_cfg.world_cultivators_min)
	var saved_local: float = float(cont_cfg.local_recruit)
	var saved_tries: int = int(cont_cfg.admit_tries)

	# Part 1: Step 6 — candidate born on sect X's ground fails sect A (hon_don impossible at low rank -> use bang with no Water/Ice, or Fire-only vs Ice sect), passes X and Y (Y closer by tile distance but NOT on own ground).
	# Make sect A require Chaos ("hon_don") so practically every draw fails A; X and Y are no-lean; place X's ground at pl_x, Y closer to pl_x than X's seat!
	var db1 := _make_mini_db()
	# Set pl_x as the ONLY settled place in X's ground, and give A own_ground = [pl_x] by setting A as minor under X in r1,
	# while Y is great with territory s_y (pl_y) and seat tile [100, 100] (distance 0 to pl_x!), X has seat tile [0, 0] (farther) but pl_x has territory s_x!
	db1.get_record("places", "pl_x")["territory"] = "s_x"
	db1.put("sects", {
		"id": "s_a", "key": "a_strict", "name": "Strict", "kind": "minor", "lord_id": "s_x",
		"region_id": "r1", "hq_place_id": "pl_a", "status": "active", "founded_year": 100,
		"levels": {"institutions": 0}, "members": [], "specialty": "kiem_tu",
		"lineage_elements": ["hon_don"],   # virtually never passes
	})
	db1.put("sects", {
		"id": "s_x", "key": "x_ground", "name": "Own Ground X", "kind": "great", "lord_id": "",
		"region_id": "r1", "hq_place_id": "pl_a",   # tile [10, 10] — far from pl_x [100, 100]
		"regions": ["r1"], "status": "active", "founded_year": 100,
		"levels": {"institutions": 0}, "members": [], "specialty": "kiem_tu",
		"lineage_elements": [],   # passes everyone
	})
	db1.put("sects", {
		"id": "s_y", "key": "y_near", "name": "Closer Y", "kind": "great", "lord_id": "",
		"region_id": "r1", "hq_place_id": "pl_y",   # tile [99, 100] — distance 1 from pl_x, closer than X!
		"regions": [], "status": "active", "founded_year": 100,
		"levels": {"institutions": 0}, "members": [], "specialty": "kiem_tu",
		"lineage_elements": [],   # passes everyone
	})
	# Remove pl_a and pl_s2 so A's own ground is strictly [pl_x] (territory s_x in r1)
	people_cfg.world_cultivators = 5
	people_cfg.world_cultivators_min = 0
	cont_cfg.local_recruit = 1.0   # force A to draw strictly from its own ground [pl_x]
	var wb1 := WorldBuilder.new(gd, TestFixtures.tree())
	wb1.run_random_fill(rng(101), db1, BuildGenerator.new(gd, TestFixtures.tree(), db1), "ac45_step6")
	var joined_x: int = 0
	var joined_y: int = 0
	for p in db1.all("people"):
		if str(p.get("birthplace", "")) == "pl_x" and str(p.get("sect_id", "")) == "s_x":
			joined_x += 1
		elif str(p.get("birthplace", "")) == "pl_x" and str(p.get("sect_id", "")) == "s_y":
			joined_y += 1
	assert_true(joined_x > 0, "candidates born on X's ground that failed A joined X (%d)" % joined_x)
	assert_eq(joined_y, 0, "none went to closer-seat Y while X (own ground) had openings")

	# Part 2: Step 7 with L > 0 — root fails only sect -> stays loose in birthplace's region, no redraws
	var db2 := _make_mini_db()
	# Single minor sect: capacity = 25, target = floor(0.9 * 25) = 22. Set N = 30 -> L = 30 - 22 - 0 = 8 > 0!
	db2.put("sects", {
		"id": "s_only", "key": "only_impossible", "name": "Impossible", "kind": "minor", "lord_id": "",
		"region_id": "r1", "hq_place_id": "pl_a", "status": "active", "founded_year": 100,
		"levels": {"institutions": 0}, "members": [], "specialty": "kiem_tu",
		"lineage_elements": ["hon_don"],
	})
	people_cfg.world_cultivators = 30
	people_cfg.world_cultivators_min = 0
	cont_cfg.local_recruit = 0.75
	cont_cfg.admit_tries = 4
	var wb2 := WorldBuilder.new(gd, TestFixtures.tree())
	var rep2: Dictionary = wb2.run_random_fill(rng(202), db2, BuildGenerator.new(gd, TestFixtures.tree(), db2), "ac45_L_pos")
	assert_eq(db2.count("people"), 30, "L>0 world holds exact N=30")
	assert_true(int(rep2.loose_count) >= 8, "L>0 puts failing candidates loose")
	assert_true(int(rep2.empty_openings) > 0, "once L exhausted, remaining openings hit empty_openings")
	for p in db2.all("people"):
		if str(p.get("sect_id", "")) == "":
			var bp_reg: String = str(db2.get_record("places", str(p.birthplace)).region_id)
			var loc_reg: String = str(db2.get_record("places", str(p.location_id)).region_id)
			assert_eq(loc_reg, bp_reg, "Step 7 loose person %s lives in its birthplace's region" % p.id)

	# Part 3: Step 7 with L = 0 — every failing candidate redraws exactly admit_tries times, counts empty opening, kept loose
	var db3 := _make_mini_db()
	# Single minor sect: target = 22. Set N = 6 -> L = 6 - 22 = -16 <= 0! Every candidate must redraw admit_tries=3 times.
	db3.put("sects", {
		"id": "s_only", "key": "only_impossible", "name": "Impossible", "kind": "minor", "lord_id": "",
		"region_id": "r1", "hq_place_id": "pl_a", "status": "active", "founded_year": 100,
		"levels": {"institutions": 0}, "members": [], "specialty": "kiem_tu",
		"lineage_elements": ["hon_don"],
	})
	people_cfg.world_cultivators = 6
	people_cfg.world_cultivators_min = 0
	cont_cfg.admit_tries = 3
	var tries_by_cand := {}
	var wb3 := WorldBuilder.new(gd, TestFixtures.tree())
	wb3.birth_spy = func(ev: Dictionary) -> void:
		if str(ev.event) == "birth_rolled":
			var c: int = int(ev.candidate_index)
			tries_by_cand[c] = int(tries_by_cand.get(c, 0)) + 1
	var rep3: Dictionary = wb3.run_random_fill(rng(303), db3, BuildGenerator.new(gd, TestFixtures.tree(), db3), "ac45_L_zero")
	people_cfg.world_cultivators = saved_n
	people_cfg.world_cultivators_min = saved_min
	cont_cfg.local_recruit = saved_local
	cont_cfg.admit_tries = saved_tries

	assert_eq(db3.count("people"), 6, "L=0 world still holds exact N=6")
	assert_eq(int(rep3.empty_openings), 6, "all 6 openings stay empty after admit_tries redraws")
	assert_eq(int(rep3.redraws), 6 * 3, "exact admit_tries=3 redraws per failing opening (18)")
	assert_eq(int(rep3.loose_count), 6, "all 6 last draws kept as loose")
	for c in tries_by_cand.keys():
		assert_eq(int(tries_by_cand[c]), 4, "candidate %d drew 1 initial + 3 retries" % c)


# --- AC-WG-46: Determinism across same seed and reversed sect order in memory ---

func test_determinism_and_reverse_sect_order_ac_wg_46() -> void:
	var gd := game_data()
	var people_cfg: Dictionary = gd.world_gen().people
	var saved_n: int = int(people_cfg.world_cultivators)
	var saved_min: int = int(people_cfg.world_cultivators_min)
	people_cfg.world_cultivators = 25
	people_cfg.world_cultivators_min = 0

	var build_snapshot := func(reverse_sects: bool) -> Array:
		var db := _make_mini_db()
		var sect_defs: Array = [
			{"id": "s1", "key": "alpha_fire", "name": "Alpha", "kind": "minor", "lord_id": "", "region_id": "r1",
				"hq_place_id": "pl_a", "status": "active", "founded_year": 100, "levels": {"institutions": 0},
				"members": [], "specialty": "dan_su", "lineage_elements": ["hoa"]},
			{"id": "s2", "key": "beta_water", "name": "Beta", "kind": "minor", "lord_id": "", "region_id": "r1",
				"hq_place_id": "pl_x", "status": "active", "founded_year": 100, "levels": {"institutions": 0},
				"members": [], "specialty": "phap_tu", "lineage_elements": ["thuy"]},
			{"id": "s3", "key": "gamma_open", "name": "Gamma", "kind": "minor", "lord_id": "", "region_id": "r2",
				"hq_place_id": "pl_s2", "status": "active", "founded_year": 100, "levels": {"institutions": 0},
				"members": [], "specialty": "kiem_tu", "lineage_elements": []},
		]
		if reverse_sects:
			sect_defs.reverse()
		for sd in sect_defs:
			db.put("sects", sd)
		var wb := WorldBuilder.new(gd, TestFixtures.tree())
		wb.run_random_fill(rng(4646), db, BuildGenerator.new(gd, TestFixtures.tree(), db), "det_seed_46")
		var snap: Array = []
		for p in db.all("people"):
			var skey: String = ""
			if str(p.get("sect_id", "")) != "":
				skey = str(db.get_record("sects", str(p.sect_id)).key)
			snap.append({"bp": str(p.get("birthplace", "")), "root": p.linh_can, "sect_key": skey})
		return snap

	var snap_a: Array = build_snapshot.call(false)
	var snap_b: Array = build_snapshot.call(false)
	var snap_rev: Array = build_snapshot.call(true)
	people_cfg.world_cultivators = saved_n
	people_cfg.world_cultivators_min = saved_min

	assert_eq(snap_a, snap_b, "same seed produces identical birthplaces, roots, and sect choices")
	assert_eq(snap_a, snap_rev, "reversing sects in memory produces identical birthplaces, roots, and sect choices")


# --- AC-WG-47: Step 8 loose person in region R has a settled birthplace in R ---

func test_step8_loose_person_has_settled_birthplace_in_its_region_ac_wg_47() -> void:
	var gd := game_data()
	var people_cfg: Dictionary = gd.world_gen().people
	var cont_cfg: Dictionary = gd.world_gen().continent
	var saved_n: int = int(people_cfg.world_cultivators)
	var saved_min: int = int(people_cfg.world_cultivators_min)
	var saved_share: float = float(cont_cfg.npc_settled_share)

	# No sects -> every candidate goes through Step 8; set npc_settled_share = 0.5 so both settled & wild branches run.
	var db := _make_mini_db()
	people_cfg.world_cultivators = 40
	people_cfg.world_cultivators_min = 0
	cont_cfg.npc_settled_share = 0.5
	var wb := WorldBuilder.new(gd, TestFixtures.tree())
	wb.run_random_fill(rng(4747), db, BuildGenerator.new(gd, TestFixtures.tree(), db), "step8_47")

	people_cfg.world_cultivators = saved_n
	people_cfg.world_cultivators_min = saved_min
	cont_cfg.npc_settled_share = saved_share

	var settled_kinds: Array = cont_cfg.settled_kinds
	var wild_kinds: Array = cont_cfg.wild_kinds
	var wild_cnt: int = 0
	var settled_cnt: int = 0
	assert_eq(db.count("people"), 40, "40 loose people created")
	for p in db.all("people"):
		assert_eq(str(p.get("sect_id", "")), "", "loose")
		var loc: Dictionary = db.get_record("places", str(p.location_id))
		var bp: Dictionary = db.get_record("places", str(p.birthplace))
		assert_false(loc.is_empty() or bp.is_empty(), "location and birthplace exist")
		assert_true(settled_kinds.has(str(bp.kind)), "birthplace %s is settled (kind=%s)" % [bp.id, bp.kind])
		assert_eq(str(bp.region_id), str(loc.region_id), "birthplace region matches placement region R")
		if wild_kinds.has(str(loc.kind)):
			wild_cnt += 1
		else:
			settled_cnt += 1
	assert_true(wild_cnt > 0 and settled_cnt > 0, "both wild (%d) and settled (%d) Step 8 loose people verified" % [wild_cnt, settled_cnt])


# --- AC-WG-48: Living cast preserved (keys, realms, sects, birthplaces) & excluded from random pool ---

func test_living_cast_preserved_with_birthplaces_ac_wg_48() -> void:
	var gd := game_data()
	var hist: Dictionary = gd.file("world_history")
	var living_hist: Array = Array(hist.people).filter(func(p): return bool(p.alive))
	assert_true(living_hist.size() > 1500, "living cast loaded (%d)" % living_hist.size())

	var seen_cast_ids := {}
	for p in living_hist:
		var pid: String = str(_builder.person_ids[str(p.key)])
		seen_cast_ids[pid] = true
		var rec: Dictionary = _db.get_record("people", pid)
		assert_eq(str(rec.get("cast_key", "")), str(p.key), "cast key %s" % p.key)
		assert_eq(str(rec.get("created_by", "")), "cast", "%s not in random pool" % p.key)
		assert_eq(int(rec.realm_index), gd.realm_index(str(p.realm)), "%s realm preserved" % p.key)
		var want_sect: String = str(_builder.sect_ids.get(str(p.get("sect", "")), ""))
		assert_eq(str(rec.get("sect_id", "")), want_sect, "%s sect preserved" % p.key)
		var home_id: String = str(_builder.place_ids.get(int(p.home), "")) if p.get("home") != null else ""
		var want_bp: String = str(_builder.place_ids.get(int(p.birthplace), home_id)) if p.get("birthplace") != null else home_id
		assert_eq(str(rec.get("birthplace", "")), want_bp, "%s birthplace mapped & preserved" % p.key)

	for p in _db.find("people", func(x): return str(x.get("created_by", "")) == "worldgen"):
		assert_false(seen_cast_ids.has(str(p.id)), "no cast member in random pool")


# --- Living World Tick: Births & F21 Pool Intake ---

func test_living_world_tick_births_read_province_land_and_enforce_outer_admission() -> void:
	var gd := game_data()
	var db := WorldDB.new()
	# Province v11 (Lê Hoa) has Metal 41.56 / Ice 10; pick a real province with strong Water/Ice vs strong Fire!
	var wp: Dictionary = gd.file("world_provinces")
	var fire_prov_id: String = ""
	for pv in wp.provinces:
		if float(pv.get("land_qi", {}).get("hoa", 0.0)) >= 35.0 and float(pv.get("land_qi", {}).get("thuy", 0.0)) <= 10.0:
			fire_prov_id = "v%d" % int(pv.id)
			break
	assert_true(fire_prov_id != "", "found high-Fire low-Water province")
	db.put("regions", {"id": "r1", "name": "Vực", "places": ["pl_fire", "pl_hq"]})
	db.put("places", {"id": "pl_fire", "name": "Hỏa Trấn", "kind": "town", "type": "tran",
		"region_id": "r1", "province_id": fire_prov_id, "density": 1.0, "qi": {}})
	db.put("places", {"id": "pl_hq", "name": "Băng Các", "kind": "great_seat", "type": "tong_mon",
		"region_id": "r1", "province_id": fire_prov_id, "density": 1.5, "qi": {}})
	# Strict Ice/Water sect
	db.put("sects", {
		"id": "s_ice", "key": "bang_tam", "name": "Băng Tâm", "kind": "great", "status": "active",
		"hq_place_id": "pl_hq", "region_id": "r1", "regions": ["r1"], "members": ["p_parent"],
		"lineage_elements": ["bang", "thuy"], "levels": {"institutions": 4},
	})
	# Parent living at pl_fire in s_ice
	db.put("people", {
		"id": "p_parent", "name": "Trần Thanh", "alive": true, "age": 50.0, "realm_index": 1, "stage": 0,
		"sect_id": "s_ice", "sect_rank": "noi_mon", "location_id": "pl_fire", "is_beast": false, "is_player": false,
		"linh_can": {"elements": {"thuy": 60.0}, "variants": {"bang": 40.0}},
	})
	var builds := BuildGenerator.new(gd, TestFixtures.tree(), db)
	var ticker := WorldTicker.new(gd, db, builds)
	var parent: Dictionary = db.get_record("people", "p_parent")

	# Verify deterministic province-land roll parity for birth_to_parent + outer admission gating
	var joined_cnt: int = 0
	var refused_cnt: int = 0
	var parent_place: Dictionary = db.get_record("places", "pl_fire")
	var expected_land: Dictionary = LinhCan.province_land(gd, parent_place)
	assert_false(expected_land.is_empty(), "parent place resolves to non-empty province land")
	for s_i in range(1, 41):
		var r_tick := rng(s_i * 17)
		var r_ref := rng(s_i * 17)
		var expected_lc: LinhCan = LinhCan.roll(gd, r_ref, expected_land)
		var before_n: int = db.count("people")
		ticker.new_cultivator(r_tick, parent)
		var child: Dictionary = db.all("people")[before_n]
		assert_eq(str(child.get("birthplace", "")), "pl_fire", "child birthplace is parent location")
		assert_eq(str(child.get("parent_id", "")), "p_parent", "child linked to parent")
		assert_eq(child.linh_can.elements, expected_lc.elements, "child base root rolled from parent province land")
		assert_eq(child.linh_can.variants, expected_lc.variants, "child variant root rolled from parent province land")
		var passes: bool = SectAdmission.admits_outer(gd, db.get_record("sects", "s_ice"), expected_lc)
		if passes:
			assert_eq(str(child.sect_id), "s_ice", "passing child joins parent sect")
			assert_eq(str(child.sect_rank), "ngoai_mon", "passing child joins as outer disciple")
			joined_cnt += 1
		else:
			assert_eq(str(child.sect_id), "", "failing child refused by parent sect (sects.md F21)")
			assert_eq(str(child.location_id), "pl_fire", "failing child starts loose at birthplace")
			refused_cnt += 1
	assert_true(joined_cnt > 0 and refused_cnt > 0, "observed both passing (%d) and refused (%d) births" % [joined_cnt, refused_cnt])


func test_living_world_tick_formulas_d_and_f21_pool_intake() -> void:
	var gd := game_data()
	# 1. Exact Living World Tick Formulas D worked example: P=10, demands 30/20/10 (D=60) -> claims 5/3/2
	var s_list := [{"id": "s1"}, {"id": "s2"}, {"id": "s3"}]
	var claims_ex: Dictionary = WorldTicker.allocate_claims(s_list, {"s1": 30, "s2": 20, "s3": 10}, 10)
	assert_eq(claims_ex, {"s1": 5, "s2": 3, "s3": 2}, "Formulas D largest remainder 5/3/2")
	# Tie-break to lower sect id
	var claims_tie: Dictionary = WorldTicker.allocate_claims(s_list, {"s1": 10, "s2": 10, "s3": 10}, 5)
	assert_eq(claims_tie, {"s1": 2, "s2": 2, "s3": 1}, "Formulas D tie goes to lower sect id")
	# D <= P gives exact demands with loose remainder
	var claims_under: Dictionary = WorldTicker.allocate_claims(s_list, {"s1": 2, "s2": 1, "s3": 0}, 10)
	assert_eq(claims_under, {"s1": 2, "s2": 1, "s3": 0}, "Formulas D D<=P gives exact demand")

	# 2. End-to-end _intake with continent economy (invested sects): Formulas D + F21 outer admission + Strained demand=0
	var db := _make_mini_db()
	db.put("sects", {
		"id": "s_a", "key": "a_great", "name": "Great Water", "kind": "great", "status": "active", "state": "steady",
		"hq_place_id": "pl_a", "region_id": "r1", "regions": ["r1"], "members": [],
		"lineage_elements": ["thuy"], "levels": {"institutions": 2},
		"invested": {"holdings": 0.0, "institutions": 100.0, "military": 0.0, "trade": 0.0},
		"dials": {"recruitment": 2},
	})
	db.put("sects", {
		"id": "s_b", "key": "b_strained", "name": "Strained Open", "kind": "great", "status": "active", "state": "strained",
		"hq_place_id": "pl_x", "region_id": "r1", "regions": ["r1"], "members": [],
		"lineage_elements": [], "levels": {"institutions": 2},
		"invested": {"holdings": 0.0, "institutions": 100.0, "military": 0.0, "trade": 0.0},
		"dials": {"recruitment": 2},
	})
	db.put("sects", {
		"id": "s_c", "key": "c_minor_kin", "name": "Minor Kin", "kind": "minor", "lord_id": "s_a", "status": "active", "state": "steady",
		"hq_place_id": "pl_y", "region_id": "r1", "members": [],
		"lineage_elements": [], "recruit_by": {"talent": "can_cot", "kin": true}, "levels": {"institutions": 2},
		"invested": {"holdings": 0.0, "institutions": 100.0, "military": 0.0, "trade": 0.0},
		"dials": {"recruitment": 2},
	})
	var people_cfg: Dictionary = gd.world_gen().people
	var fam_cfg: Dictionary = Families.cfg(gd)
	var saved_n: int = int(people_cfg.world_cultivators)
	var saved_min: int = int(people_cfg.world_cultivators_min)
	var saved_birth: float = float(fam_cfg.birth_share)
	people_cfg.world_cultivators = 20
	people_cfg.world_cultivators_min = 0
	fam_cfg.birth_share = 0.0   # pure pool intake

	var builds := BuildGenerator.new(gd, TestFixtures.tree(), db)
	var ticker := WorldTicker.new(gd, db, builds)
	ticker._intake(rng(777), 0)

	people_cfg.world_cultivators = saved_n
	people_cfg.world_cultivators_min = saved_min
	fam_cfg.birth_share = saved_birth

	assert_eq(db.count("people"), 20, "conservation: exact 20 newcomers created")
	var s_a: Dictionary = db.get_record("sects", "s_a")
	var s_b: Dictionary = db.get_record("sects", "s_b")
	var s_c: Dictionary = db.get_record("sects", "s_c")
	assert_eq(Array(s_b.members).size(), 0, "Strained sect gets 0 claims (Formulas D)")
	assert_true(Array(s_a.members).size() > 0, "Great Water sect admitted passing pool members")
	assert_true(Array(s_c.members).size() > 0, "Minor Kin no-lean sect admitted pool members")
	for mid in s_a.members:
		var m: Dictionary = db.get_record("people", str(mid))
		assert_true(SectAdmission.admits_outer(gd, s_a, LinhCan.from_dict(m.linh_can)), "admitted member passes outer test")
		assert_eq(str(m.sect_rank), "ngoai_mon", "pool intake joins as ngoai_mon")
		assert_eq(str(m.location_id), "pl_a", "admitted member moves to sect HQ")
		assert_true(str(m.get("birthplace", "")) != "", "admitted member retains birthplace")
	for p in db.all("people"):
		if str(p.get("sect_id", "")) == "":
			assert_eq(str(p.location_id), str(p.birthplace), "unadmitted loose member stays at birthplace")


func test_living_world_tick_refused_child_enters_pool_and_kin_home_helpers() -> void:
	var gd := game_data()
	var db := _make_mini_db()
	db.get_record("places", "pl_a")["province_id"] = "v1"
	db.get_record("places", "pl_x")["province_id"] = "v1"
	db.get_record("places", "pl_y")["province_id"] = "v2"
	db.put("sects", {
		"id": "s_impossible", "key": "imp", "name": "Impossible", "kind": "great", "status": "active", "state": "steady",
		"hq_place_id": "pl_a", "region_id": "r1", "regions": ["r1"], "members": ["p_parent"],
		"lineage_elements": ["hon_don"], "levels": {"institutions": 2},
		"invested": {"holdings": 0.0, "institutions": 100.0, "military": 0.0, "trade": 0.0},
		"dials": {"recruitment": 2},
	})
	db.put("sects", {
		"id": "s_open", "key": "open_kin", "name": "Open Kin", "kind": "minor", "lord_id": "s_impossible",
		"status": "active", "state": "steady", "hq_place_id": "pl_y", "region_id": "r1", "members": ["p_gp"],
		"lineage_elements": [], "recruit_by": {"talent": "can_cot", "kin": true}, "levels": {"institutions": 2},
		"invested": {"holdings": 0.0, "institutions": 100.0, "military": 0.0, "trade": 0.0},
		"dials": {"recruitment": 2},
	})
	db.put("people", {
		"id": "p_gp", "name": "Trần Lão", "alive": true, "age": 80.0, "realm_index": 2, "stage": 0,
		"sect_id": "s_open", "sect_rank": "truong_lao", "location_id": "pl_y", "is_beast": false, "is_player": false,
		"linh_can": {"elements": {"kim": 60.0}, "variants": {}},
	})
	db.put("people", {
		"id": "p_parent", "name": "Trần Trung", "alive": true, "age": 45.0, "realm_index": 1, "stage": 0,
		"sect_id": "s_impossible", "sect_rank": "noi_mon", "location_id": "pl_a", "parent_id": "p_gp",
		"is_beast": false, "is_player": false,
		"linh_can": {"elements": {"kim": 50.0}, "variants": {}},
	})
	var builds := BuildGenerator.new(gd, TestFixtures.tree(), db)
	var ticker := WorldTicker.new(gd, db, builds)

	# Verify home_ground helper for great (regions/territory) and minor (seat province / held sites)
	var s_imp: Dictionary = db.get_record("sects", "s_impossible")
	var s_open: Dictionary = db.get_record("sects", "s_open")
	assert_true(ticker._is_home_ground(s_imp, {"birthplace": "pl_a"}), "great sect home on own region/territory")
	assert_false(ticker._is_home_ground(s_imp, {"birthplace": "pl_s2"}), "great sect not home on r2")
	assert_true(ticker._is_home_ground(s_open, {"birthplace": "pl_y"}), "minor sect home on seat province v2")
	assert_false(ticker._is_home_ground(s_open, {"birthplace": "pl_x"}), "minor sect not home on other province v1")

	# Verify kin helper detects both parent AND grandparent in sect
	var mock_child := {"id": "p_mock", "parent_id": "p_parent"}
	assert_true(ticker._is_sect_kin(s_imp, mock_child), "kin true via living parent in sect")
	assert_true(ticker._is_sect_kin(s_open, mock_child), "kin true via living grandparent in sect")

	# Run _intake with birth_share=1.0: children born to p_parent fail s_impossible outer test -> enter pool -> claimed by s_open!
	var people_cfg: Dictionary = gd.world_gen().people
	var fam_cfg: Dictionary = Families.cfg(gd)
	var saved_n: int = int(people_cfg.world_cultivators)
	var saved_min: int = int(people_cfg.world_cultivators_min)
	var saved_birth: float = float(fam_cfg.birth_share)
	people_cfg.world_cultivators = 12   # 2 existing + 10 births -> s_open gets positive Formulas D claim
	people_cfg.world_cultivators_min = 0
	fam_cfg.birth_share = 1.0
	ticker._intake(rng(888), 2)
	people_cfg.world_cultivators = saved_n
	people_cfg.world_cultivators_min = saved_min
	fam_cfg.birth_share = saved_birth

	var children: Array = db.all("people").filter(func(p): return str(p.get("parent_id", "")) == "p_parent")
	assert_true(children.size() > 0, "at least one birth to p_parent (%d)" % children.size())
	var claimed_by_open: int = 0
	for ch in children:
		assert_true(str(ch.sect_id) != "s_impossible", "failing child never joins impossible parent sect")
		if str(ch.sect_id) == "s_open":
			claimed_by_open += 1
	assert_true(claimed_by_open > 0, "refused child entered pool and was claimed by s_open (%d)" % claimed_by_open)
