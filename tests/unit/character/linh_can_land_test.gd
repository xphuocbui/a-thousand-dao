extends DaoTestSuite
## Spiritual Roots follow the land (design/gdd/linh-can.md rule 2, Formulas A2 & D4):
## AC-LC-59 through AC-LC-65 plus province_land lookup and fallback checks.

const WORLD_MEANS := {
	"moc": 31.1,
	"hoa": 15.1,
	"tho": 20.1,
	"kim": 13.7,
	"thuy": 20.0,
}

const FLAT_MEANS := {
	"moc": 20.0,
	"hoa": 20.0,
	"tho": 20.0,
	"kim": 20.0,
	"thuy": 20.0,
}


func _script(draws: Array) -> ScriptedRng:
	var out: Array = []
	for d in draws:
		out.append(d[0])
		out.append(d[1])
	return ScriptedRng.new(out)


func _land(qi: Dictionary, vmax: Dictionary = {}, means: Dictionary = WORLD_MEANS) -> Dictionary:
	return {"land_qi": qi, "variant_max": vmax, "means": means}


# --- AC-LC-59: Even land parity ---------------------------------------------------

func test_even_land_matches_uniform_roll_draw_for_draw_ac59() -> void:
	var gd := game_data()
	var even_land := _land(WORLD_MEANS.duplicate(), {}, WORLD_MEANS.duplicate())
	var f_empty: Dictionary = LinhCan.land_factors(gd, {})
	var f_even: Dictionary = LinhCan.land_factors(gd, even_land)
	for e in gd.element_cycle():
		assert_near(float(f_empty[e]), 1.0, 1e-9, "empty land factor %s" % e)
		assert_near(float(f_even[e]), 1.0, 1e-9, "even land factor %s" % e)
	for s in range(1, 501):
		var uniform_dict: Dictionary = LinhCan.roll(gd, rng(s)).to_dict()
		var empty_dict: Dictionary = LinhCan.roll(gd, rng(s), {}).to_dict()
		var even_dict: Dictionary = LinhCan.roll(gd, rng(s), even_land).to_dict()
		assert_eq(empty_dict, uniform_dict, "seed %d empty land matches uniform" % s)
		assert_eq(even_dict, uniform_dict, "seed %d even land matches uniform" % s)


# --- AC-LC-60: Weighted Fisher-Yates element pick ---------------------------------

func test_weighted_element_pick_follows_intervals_ac60() -> void:
	var gd := game_data()
	# Flat means 20.0 with Water 40.0 yields exact factors {moc:1, hoa:1, tho:1, kim:1, thuy:2}.
	var land := _land({"moc": 20.0, "hoa": 20.0, "tho": 20.0, "kim": 20.0, "thuy": 40.0}, {}, FLAT_MEANS)
	var factors: Dictionary = LinhCan.land_factors(gd, land)
	assert_eq(factors, {"moc": 1.0, "hoa": 1.0, "tho": 1.0, "kim": 1.0, "thuy": 2.0}, "expected factors")

	# u = 0.9 -> W = 6, u * W = 5.4 in Water's [4, 6) -> single Water.
	var r_water := _script([["U", 0.10], ["U", 0.9], ["N", 50.0], ["U", 0.99], ["U", 0.99], ["U", 0.99], ["U", 0.99]])
	var lc_water := LinhCan.roll(gd, r_water, land)
	assert_true(r_water.done(), "water scripted draws exact: %s" % r_water.error)
	assert_eq(lc_water.elements.keys(), ["thuy"], "u=0.9 picks single Water")

	# u = 0.6 -> W = 6, u * W = 3.6 in Metal's [3, 4) -> single Metal.
	var r_metal := _script([["U", 0.10], ["U", 0.6], ["N", 50.0], ["U", 0.99], ["U", 0.99], ["U", 0.99]])
	var lc_metal := LinhCan.roll(gd, r_metal, land)
	assert_true(r_metal.done(), "metal scripted draws exact: %s" % r_metal.error)
	assert_eq(lc_metal.elements.keys(), ["kim"], "u=0.6 picks single Metal")

	# Boundary check: u = 4.0 / 6.0 -> target == 4.0 falls in Water's half-open [4, 6).
	var r_edge := _script([["U", 0.10], ["U", 4.0 / 6.0], ["N", 50.0], ["U", 0.99], ["U", 0.99], ["U", 0.99], ["U", 0.99]])
	var lc_edge := LinhCan.roll(gd, r_edge, land)
	assert_true(r_edge.done(), "edge scripted draws exact: %s" % r_edge.error)
	assert_eq(lc_edge.elements.keys(), ["thuy"], "u=4/6 lands in Water [4, 6)")


# --- AC-LC-61: Purity shift and clamping ------------------------------------------

func test_purity_shift_rounds_and_clamps_ac61() -> void:
	var gd := game_data()
	# f_Water = 2.55 (Water 40%, Ice 22, mean 20.0): 50 + 6 * 1.55 = 59.3 -> 59.
	var frost_land := _land({"moc": 25.0, "hoa": 10.0, "tho": 15.0, "kim": 10.0, "thuy": 40.0}, {"bang": 22.0})
	assert_near(float(LinhCan.land_factors(gd, frost_land)["thuy"]), 2.55, 1e-9, "frost Water factor 2.55")
	var r_high := _script([["U", 0.10], ["U", 0.95], ["N", 50.0], ["U", 0.99], ["U", 0.99], ["U", 0.99], ["U", 0.99]])
	var lc_high := LinhCan.roll(gd, r_high, frost_land)
	assert_true(r_high.done(), "high-factor draws exact: %s" % r_high.error)
	assert_eq(lc_high.elements, {"thuy": 59.0}, "f=2.55 draw 50 -> 59")

	# f_Water = 0.25 (Water 0%, no Ice): 50 + 6 * (-0.75) = 45.5 -> 46; draw 12 -> 7.5 -> 10 (clamp).
	var arid_land := _land({"moc": 31.1, "hoa": 15.1, "tho": 20.1, "kim": 13.7, "thuy": 0.0})
	assert_near(float(LinhCan.land_factors(gd, arid_land)["thuy"]), 0.25, 1e-9, "arid Water factor 0.25")
	# Weights: 1 + 1 + 1 + 1 + 0.25 = 4.25; Water is [4.0, 4.25), u = 0.99 -> 4.2075 -> Water.
	var r_low := _script([["U", 0.10], ["U", 0.99], ["N", 50.0], ["U", 0.99], ["U", 0.99], ["U", 0.99], ["U", 0.99]])
	var lc_low := LinhCan.roll(gd, r_low, arid_land)
	assert_true(r_low.done(), "low-factor draws exact: %s" % r_low.error)
	assert_eq(lc_low.elements, {"thuy": 46.0}, "f=0.25 draw 50 -> 46 (45.5 rounded)")

	var r_clamp := _script([["U", 0.10], ["U", 0.99], ["N", 12.0], ["U", 0.99], ["U", 0.99], ["U", 0.99], ["U", 0.99]])
	var lc_clamp := LinhCan.roll(gd, r_clamp, arid_land)
	assert_true(r_clamp.done(), "clamp draws exact: %s" % r_clamp.error)
	assert_eq(lc_clamp.elements, {"thuy": 10.0}, "f=0.25 draw 12 -> 10 (clamped)")

	# Upper clamp check: f_Water = 3.0 (Water 100%, mean 20.0) with draw 95 -> 95 + 12 = 107 -> 100.
	var cap_land := _land({"moc": 0.0, "hoa": 0.0, "tho": 0.0, "kim": 0.0, "thuy": 100.0})
	var r_cap := _script([["U", 0.10], ["U", 0.99], ["N", 95.0], ["U", 0.99], ["U", 0.99], ["U", 0.99], ["U", 0.99]])
	var lc_cap := LinhCan.roll(gd, r_cap, cap_land)
	assert_true(r_cap.done(), "cap draws exact: %s" % r_cap.error)
	assert_eq(lc_cap.elements, {"thuy": 100.0}, "f=3.0 draw 95 -> 100 (clamped)")


# --- AC-LC-62: Land factor formula & bounds ---------------------------------------

func test_land_factors_formula_and_bounds_ac62() -> void:
	var gd := game_data()
	var frost := _land({"moc": 25.0, "hoa": 10.0, "tho": 15.0, "kim": 10.0, "thuy": 40.0}, {"bang": 22.0})
	var f_frost: Dictionary = LinhCan.land_factors(gd, frost)
	assert_near(float(f_frost["thuy"]), 2.55, 1e-9, "s'_Water=51, mean=20.0 -> f=2.55")

	var extreme := _land({"moc": 0.0, "hoa": 100.0, "tho": 0.0, "kim": 0.0, "thuy": 100.0})
	var f_ext: Dictionary = LinhCan.land_factors(gd, extreme)
	assert_near(float(f_ext["moc"]), 0.25, 1e-9, "share 0 -> floor 0.25")
	assert_near(float(f_ext["tho"]), 0.25, 1e-9, "share 0 -> floor 0.25")
	assert_near(float(f_ext["kim"]), 0.25, 1e-9, "share 0 -> floor 0.25")
	assert_near(float(f_ext["hoa"]), 3.0, 1e-9, "share 100 -> cap 3.0")
	assert_near(float(f_ext["thuy"]), 3.0, 1e-9, "share 100 -> cap 3.0")

	# Guard against zero/missing means: stays 1.0 without error.
	var zero_mean := _land({"moc": 50.0}, {}, {"moc": 0.0, "hoa": 0.0, "tho": 0.0, "kim": 0.0, "thuy": 0.0})
	var f_zero: Dictionary = LinhCan.land_factors(gd, zero_mean)
	for e in gd.element_cycle():
		assert_near(float(f_zero[e]), 1.0, 1e-9, "zero mean safe fallback %s" % e)


# --- AC-LC-63: Formulas D4 variant land boost & draw count invariance -------------

func test_variant_land_boost_and_draw_count_invariance_ac63() -> void:
	var gd := game_data()
	# Three Ice land settings: 22 (boost 3.2 -> 0.192), 60 (capped 5.0 -> 0.30), 0 (boost 1.0 -> 0.06).
	var land_22 := _land(WORLD_MEANS.duplicate(), {"bang": 22.0})
	var land_60 := _land(WORLD_MEANS.duplicate(), {"bang": 60.0})
	var land_0 := _land(WORLD_MEANS.duplicate(), {})

	assert_near(LinhCan.variant_land_boost(gd, "bang", land_22), 3.2, 1e-9, "Ice 22 -> boost 3.2")
	assert_near(LinhCan.variant_land_boost(gd, "bang", land_60), 5.0, 1e-9, "Ice 60 -> boost capped 5.0")
	assert_near(LinhCan.variant_land_boost(gd, "bang", land_0), 1.0, 1e-9, "No Ice land -> boost 1.0")
	assert_near(LinhCan.variant_land_boost(gd, "bang", {}), 1.0, 1e-9, "Empty land -> boost 1.0")

	# Non-land variants stay at 1.0 even if present in variant_max.
	var bad_vmax := _land(WORLD_MEANS.duplicate(), {"hon_don": 50.0, "huyet": 50.0, "hu_khong": 50.0, "phong": 20.0})
	assert_near(LinhCan.variant_land_boost(gd, "hon_don", bad_vmax), 1.0, 1e-9, "Chaos reads no land")
	assert_near(LinhCan.variant_land_boost(gd, "huyet", bad_vmax), 1.0, 1e-9, "Blood reads no land")
	assert_near(LinhCan.variant_land_boost(gd, "hu_khong", bad_vmax), 1.0, 1e-9, "Void reads no land")
	assert_near(LinhCan.variant_land_boost(gd, "phong", bad_vmax), 3.0, 1e-9, "Wind reads Wind land")

	# Helper to roll a single Water 50 root on given land with a scripted Ice draw u_ice.
	var roll_water_50 := func(land: Dictionary, u_ice: float) -> Dictionary:
		var f_w: float = float(LinhCan.land_factors(gd, land)["thuy"])
		var shift: float = float(gd.attributes().linh_can.land_purity_shift) * (f_w - 1.0)
		var r := _script([
			["U", 0.10], ["U", 0.99],
			["N", 50.0 - shift],
			["U", 0.99], ["U", 0.99], ["U", 0.99],
			["U", u_ice],
		])
		var lc := LinhCan.roll(gd, r, land)
		assert_true(r.done(), "draws exact: %s" % r.error)
		assert_eq(lc.elements, {"thuy": 50.0}, "Water 50")
		return {"lc": lc, "u_count": r.log.count("U")}

	# Ice land 22: chance' = 0.12 * 0.50 * 3.2 = 0.192.
	var hit_22: Dictionary = roll_water_50.call(land_22, 0.191)
	var miss_22: Dictionary = roll_water_50.call(land_22, 0.192)
	assert_true(hit_22.lc.variants.has("bang"), "Ice 22 forms at 0.191 < 0.192")
	assert_false(miss_22.lc.variants.has("bang"), "Ice 22 fails at 0.192")

	# Ice land 60: chance' = 0.12 * 0.50 * 5.0 = 0.30.
	var hit_60: Dictionary = roll_water_50.call(land_60, 0.299)
	var miss_60: Dictionary = roll_water_50.call(land_60, 0.30)
	assert_true(hit_60.lc.variants.has("bang"), "Ice 60 forms at 0.299 < 0.30")
	assert_false(miss_60.lc.variants.has("bang"), "Ice 60 fails at 0.30")

	# No Ice land: chance' = 0.12 * 0.50 * 1.0 = 0.06.
	var hit_0: Dictionary = roll_water_50.call(land_0, 0.059)
	var miss_0: Dictionary = roll_water_50.call(land_0, 0.06)
	assert_true(hit_0.lc.variants.has("bang"), "No Ice land forms at 0.059 < 0.06")
	assert_false(miss_0.lc.variants.has("bang"), "No Ice land fails at 0.06")

	# Uniform draw count identical across all three cases (1 count + 1 elem + 3 innate + 1 derived = 6).
	assert_eq(hit_22.u_count, 6, "Ice 22 draw count")
	assert_eq(hit_60.u_count, 6, "Ice 60 draw count")
	assert_eq(hit_0.u_count, 6, "No Ice land draw count")

	# Wind innate boost at birth: Wind 20 -> boost 3.0 -> 0.025 * 3.0 = 0.075.
	var wind_land := _land(WORLD_MEANS.duplicate(), {"phong": 20.0})
	var r_wind_hit := _script([["U", 0.10], ["U", 0.0], ["N", 50.0], ["U", 0.074], ["N", 55.0], ["U", 0.99], ["U", 0.99]])
	var lc_wind := LinhCan.roll(gd, r_wind_hit, wind_land)
	assert_true(r_wind_hit.done(), "wind hit exact: %s" % r_wind_hit.error)
	assert_true(lc_wind.variants.has("phong"), "Wind 20 boosts 0.025 -> 0.075 (0.074 succeeds)")

	# Post-birth rolls (roll_newly_eligible without land, awakening_pass) read NO land.
	var post_lc := LinhCan.new()
	post_lc.elements = {"thuy": 50.0}
	post_lc.rolled = ["phong", "huyet", "hu_khong"]
	var r_post := _script([["U", 0.10]])
	assert_eq(post_lc.roll_newly_eligible(gd, r_post), [], "post-birth roll uses unboosted 0.06 (0.10 fails)")
	var r_awake := _script([["U", 0.10]])
	assert_eq(post_lc.awakening_pass(gd, r_awake), [], "awakening uses unboosted 0.06 (0.10 fails)")


# --- AC-LC-64: Parts tilt from variant land ---------------------------------------

func test_variant_parts_tilt_ac64() -> void:
	var gd := game_data()
	var thunder_land := _land(WORLD_MEANS.duplicate(), {"loi": 40.0})
	var f: Dictionary = LinhCan.land_factors(gd, thunder_land)
	# s'_Fire = 15.1 + 0.5 * 40 = 35.1 -> f = 1 + (35.1 - 15.1) / 15.1 = 2.3245...
	# s'_Metal = 13.7 + 0.5 * 40 = 33.7 -> f = 1 + (33.7 - 13.7) / 13.7 = 2.4598...
	assert_near(float(f["hoa"]), 1.0 + 20.0 / 15.1, 1e-9, "Fire tilted by Thunder 40")
	assert_near(float(f["hoa"]), 2.32, 0.01, "Fire factor ~2.32")
	assert_near(float(f["kim"]), 1.0 + 20.0 / 13.7, 1e-9, "Metal tilted by Thunder 40")
	assert_near(float(f["kim"]), 2.46, 0.01, "Metal factor ~2.46")
	assert_near(float(f["moc"]), 1.0, 1e-9, "Wood not tilted")
	assert_near(float(f["tho"]), 1.0, 1e-9, "Earth not tilted")
	assert_near(float(f["thuy"]), 1.0, 1e-9, "Water not tilted")

	# Wind and Chaos tilt no base element.
	var wind_chaos_land := _land(WORLD_MEANS.duplicate(), {"phong": 40.0, "hon_don": 40.0})
	var f_wc: Dictionary = LinhCan.land_factors(gd, wind_chaos_land)
	for e in gd.element_cycle():
		assert_near(float(f_wc[e]), 1.0, 1e-9, "Wind/Chaos do not tilt %s" % e)


# --- AC-LC-65: Self-made reads no land; roll_player passes land -------------------

func test_self_made_reads_no_land_ac65() -> void:
	var gd := game_data()
	var picks_purities := {"hoa": 86, "kim": 40}
	var picks_variants := ["loi", "phong"]
	var c_tan := CharacterFactory.custom_player(gd, rng(1), "A", "male", "tan_tu", {"ngo_tinh": 60}, picks_purities, picks_variants)
	var c_sect := CharacterFactory.custom_player(gd, rng(999), "B", "female", "tong_mon", {"ngo_tinh": 60}, picks_purities, picks_variants)
	var c_clan := CharacterFactory.custom_player(gd, rng(42), "C", "male", "gia_toc", {"ngo_tinh": 60}, picks_purities, picks_variants)
	assert_eq(c_tan.linh_can.to_dict(), c_sect.linh_can.to_dict(), "Self-made identical across tan_tu and tong_mon")
	assert_eq(c_tan.linh_can.to_dict(), c_clan.linh_can.to_dict(), "Self-made identical across tan_tu and gia_toc")

	# CharacterFactory.roll_player passes optional land through to LinhCan.roll.
	var heavy_water := _land({"moc": 0.0, "hoa": 0.0, "tho": 0.0, "kim": 0.0, "thuy": 100.0}, {"bang": 40.0})
	var r_player := rng(77)
	var player_water := CharacterFactory.roll_player(gd, r_player, "W", "male", "tan_tu", heavy_water)
	var r_ref := rng(77)
	CharacterFactory.roll_thien_phu(gd, r_ref)
	var lc_ref := LinhCan.roll(gd, r_ref, heavy_water)
	assert_eq(player_water.linh_can.to_dict(), lc_ref.to_dict(), "roll_player forwards land to LinhCan.roll")

	# Default roll_player (omitted land) matches even land.
	var player_default := CharacterFactory.roll_player(gd, rng(77), "D", "male", "tan_tu")
	var player_empty := CharacterFactory.roll_player(gd, rng(77), "D", "male", "tan_tu", {})
	assert_eq(player_default.linh_can.to_dict(), player_empty.linh_can.to_dict(), "roll_player default matches empty land")


# --- Province land lookup & fallback ----------------------------------------------

func test_province_land_lookup_and_fallbacks() -> void:
	var base_gd := game_data()
	var files: Dictionary = base_gd.registry.files().duplicate()
	var sample_qi := {"moc": 25.0, "hoa": 10.0, "tho": 15.0, "kim": 10.0, "thuy": 40.0}
	var sample_vmax := {"bang": 22.0}
	files["world_provinces"] = {
		"schema_version": 1,
		"land_element_means": WORLD_MEANS.duplicate(),
		"provinces": [
			{
				"id": 1,
				"key": "prov_bang_tam",
				"seat_place": 3,
				"places": [{"id": 3}, {"id": 255}],
				"land_qi": sample_qi,
				"variant_max": sample_vmax,
			},
			{
				"id": 2,
				"key": "prov_no_qi",
				"seat_place": 18,
				"places": [{"id": 18}],
			},
		],
	}
	var synthetic_gd := GameData.new()
	synthetic_gd.setup(DataRegistry.from_files(files))

	# Empty place -> {}.
	assert_eq(LinhCan.province_land(synthetic_gd, {}), {}, "empty place falls back to even land")

	# Lookup by province_id.
	var by_pid: Dictionary = LinhCan.province_land(synthetic_gd, {"province_id": "v1"})
	assert_eq(by_pid.land_qi, sample_qi, "province_id resolves land_qi")
	assert_eq(by_pid.variant_max, sample_vmax, "province_id resolves variant_max")
	assert_eq(by_pid.means, WORLD_MEANS, "province_id resolves means")

	# Lookup by continent_id.
	var by_cid: Dictionary = LinhCan.province_land(synthetic_gd, {"continent_id": 255})
	assert_eq(by_cid.land_qi, sample_qi, "continent_id resolves land_qi")

	# Lookup by tile fallback via Provinces.nearest_land (tile [455, 139] is province 1 Cựu Các).
	var by_tile: Dictionary = LinhCan.province_land(synthetic_gd, {"continent_id": 99999, "tile": [455, 139]})
	assert_eq(by_tile.land_qi, sample_qi, "tile fallback via Provinces.nearest_land resolves v1")

	# Province without land_qi -> {}.
	assert_eq(LinhCan.province_land(synthetic_gd, {"province_id": "v2"}), {}, "missing land_qi returns {}")

	# Minimal fixture without land_element_means -> {}.
	var files_no_means: Dictionary = base_gd.registry.files().duplicate()
	files_no_means["world_provinces"] = {
		"schema_version": 1,
		"provinces": [{"id": 1, "places": [{"id": 3}], "land_qi": sample_qi}],
	}
	var no_means_gd := GameData.new()
	no_means_gd.setup(DataRegistry.from_files(files_no_means))
	assert_eq(LinhCan.province_land(no_means_gd, {"province_id": "v1"}), {}, "missing land_element_means returns {}")


# --- AC-LC-66: World totals over 100,000 Fated births -----------------------------

func test_world_totals_100k_fated_births_ac66() -> void:
	var gd := game_data()
	var wp: Dictionary = gd.file("world_provinces")
	var means: Dictionary = wp.get("land_element_means", {})
	assert_false(means.is_empty(), "world_provinces.json carries land_element_means")
	var settled_kinds := ["city", "town", "village", "market", "sect_hall", "great_seat", "minor_seat"]
	var lands: Array = []
	var cum_w: PackedFloat64Array = PackedFloat64Array()
	var total_w: float = 0.0
	for p in wp.get("provinces", []):
		if not (p is Dictionary) or str(p.get("kind", "")) != "settlement":
			continue
		var lq: Dictionary = p.get("land_qi", {})
		if lq.is_empty():
			continue
		var cnt: int = 0
		for q in p.get("places", []):
			if q is Dictionary and settled_kinds.has(str(q.get("kind", ""))):
				cnt += 1
		var w: float = float(maxi(1, cnt))
		total_w += w
		cum_w.append(total_w)
		lands.append({
			"land_qi": lq,
			"variant_max": p.get("variant_max", {}),
			"means": means,
		})
	assert_true(lands.size() > 400, "real world has > 400 settlement provinces (%d)" % lands.size())

	var r := rng(20261125)
	var n: int = 100000
	var cycle: Array = gd.element_cycle()
	var elem_held := {}
	for e in cycle:
		elem_held[str(e)] = 0
	var purity_sum: float = 0.0
	var purity_cnt: int = 0
	var ge85_cnt: int = 0
	var ice_cnt: int = 0

	var n_lands: int = lands.size()
	for _i in n:
		var u: float = r.randf() * total_w
		var lo: int = 0
		var hi: int = n_lands - 1
		while lo < hi:
			var mid: int = (lo + hi) >> 1
			if cum_w[mid] <= u:
				lo = mid + 1
			else:
				hi = mid
		var lc: LinhCan = LinhCan.roll(gd, r, lands[lo])
		for e in lc.elements.keys():
			var es: String = str(e)
			elem_held[es] = int(elem_held[es]) + 1
			var pv: float = float(lc.elements[e])
			purity_sum += pv
			purity_cnt += 1
			if pv >= 85.0:
				ge85_cnt += 1
		if lc.variants.has("bang"):
			ice_cnt += 1

	var mean_p: float = purity_sum / float(purity_cnt)
	var ge85_share: float = float(ge85_cnt) / float(purity_cnt)
	var ice_share: float = float(ice_cnt) / float(n)
	var parts: PackedStringArray = []
	for e in cycle:
		var share: float = float(elem_held[str(e)]) / float(n)
		parts.append("%s=%.2f%%" % [str(e), share * 100.0])
	print("AC-LC-66 (n=%d): held=[%s], mean_purity=%.3f, ge85=%.3f%%, ice=%.3f%%" % [
		n, ", ".join(parts), mean_p, ge85_share * 100.0, ice_share * 100.0])

	for e in cycle:
		var share: float = float(elem_held[str(e)]) / float(n)
		assert_true(share >= 0.35 and share <= 0.39, "AC-LC-66 %s held share %.4f in [0.35, 0.39]" % [str(e), share])
	assert_true(mean_p >= 50.0 and mean_p <= 52.0, "AC-LC-66 mean base purity %.3f in [50.0, 52.0]" % mean_p)
	assert_true(ge85_share >= 0.04 and ge85_share <= 0.06, "AC-LC-66 purity>=85 share %.4f in [0.04, 0.06]" % ge85_share)
	assert_true(ice_share >= 0.020 and ice_share <= 0.028, "AC-LC-66 Ice share %.4f in [0.020, 0.028]" % ice_share)
