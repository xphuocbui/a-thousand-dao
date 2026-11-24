extends DaoTestSuite
## Layer-2 works without caps (user decision 2026-11-24; design/gdd/travel-map.md Formulas B, H, J; Sects F2
## free_level; Provinces rule 9): no highest level, prices rise with the track surcharge, no production, share or match
## caps on layer 2, no product cap, and sects save over a few seasons for a level one season cannot pay.

var _db: WorldDB


func before() -> void:
	var r := RandomNumberGenerator.new()
	r.seed = 4242
	_db = WorldBuilder.new(game_data(), TestFixtures.tree()).generate(r, "4242")


func _great() -> Dictionary:
	return _db.all("sects").filter(func(s): return str(s.get("kind", "")) == "great")[0]


func test_a_level_above_the_free_level_costs_the_surcharge_ac_tm_109() -> void:
	var gd := game_data()
	var plain: int = int(MapWorks.cost(gd, "spirit_grove", 6).lt)
	assert_eq(plain, 64000, "level 6 at the plain price (2,000 x 2^5)")
	assert_eq(int(MapWorks.cost(gd, "spirit_grove", 6, 6).lt), 64000, "at the free level: no surcharge")
	assert_eq(int(MapWorks.cost(gd, "spirit_grove", 6, 4).lt), 64000 * 4, "two levels above the free level: x2 x2")
	assert_eq(int(MapWorks.cost(gd, "sect_array", 5, 5).lt), int(round(3000.0 * pow(2.5, 4.0))), "AC-TM-108's level 5 unchanged")


func test_sects_are_offered_levels_past_five_at_their_track_price() -> void:
	var gd := game_data()
	var s: Dictionary = _great()
	var seat: Dictionary = _db.get_record("places", str(s.hq_place_id))
	var saved: Dictionary = Dictionary(seat.qi.get("layer2", {})).duplicate(true)
	if not seat.qi.has("layer2"):
		seat.qi["layer2"] = {}
	seat.qi.layer2["spirit_grove"] = {"level": 7, "unpaid": 0, "element": ""}
	var c: Array = SectWorks.candidates(gd, _db, s).filter(func(x): return str(x.place) == str(seat.id) and str(x.id) == "spirit_grove")
	seat.qi["layer2"] = saved
	assert_eq(c.size(), 1, "the grove's next level is a candidate")
	assert_eq(int(c[0].level), 8, "level 8 (no highest level)")
	var free: int = SectWorks.free_level(gd, _db, s, "spirit_grove")
	assert_eq(int(c[0].cost), int(MapWorks.cost(gd, "spirit_grove", 8, free).lt), "at Institutions' price (free level %d)" % free)


func test_layer_two_production_share_and_match_have_no_cap() -> void:
	var gd := game_data()
	var qi := {"layer2": {"worked_mine": {"level": 8, "unpaid": 0, "element": ""}, "vein_dressing": {"level": 7, "unpaid": 0, "element": ""}}}
	assert_near(MapWorks.production_gain(gd, qi), 0.8 + 0.21, 1e-9, "upkept 0.8 and permanent 0.21, both past the old 0.5 / 0.15")
	var c := Character.new()
	c.linh_can = LinhCan.new()
	c.linh_can.elements = {"hoa": 100.0}
	var low: float = MapWorks.match_gain(gd, {"layer2": {"qi_channel": {"level": 10, "unpaid": 0, "element": "hoa"}}}, c)
	var high: float = MapWorks.match_gain(gd, {"layer2": {"qi_channel": {"level": 40, "unpaid": 0, "element": "hoa"}}}, c)
	assert_near(high, 4.0 * low, 1e-9, "the match gain grows with the push, no share or match cap on layer 2")


func test_a_site_multiplier_has_no_product_cap_ac_tm_82() -> void:
	var gd := game_data()
	var mine: Array = _db.all("places").filter(func(p): return p.has("site") and str(p.site.kind) == "ore")
	var p: Dictionary = Dictionary(mine[0]).duplicate(true)
	p.site["reserve"] = float(p.site.reserve_max)
	p.site["works_prod"] = 3.0
	var r: Dictionary = MapProduction.production(gd, p, 1.0, 1.0)
	assert_true(float(r.g_f) == 4.0, "G_f 4")
	assert_near(float(r.output), floor(float(p.site.base_output) * float(r.r_f) * float(r.w_f) * float(r.d_f) * float(r.s_f) * 4.0 + 0.5 + 1e-6), 1e-6, "the whole product, uncapped")


func test_a_sect_saves_for_a_level_one_season_cannot_pay_and_never_overdraws() -> void:
	var gd := game_data()
	var s: Dictionary = Dictionary(_great()).duplicate(true)   # a copy: the suite's world stays as built
	var cands: Array = SectWorks.candidates(gd, _db, s)
	assert_false(cands.is_empty(), "the sect has works to build")
	var c0: float = float(cands[0].cost)
	var budget: float = c0 / 3.0   # the best costs three seasons of budget
	var cfg: Dictionary = MapWorks.cfg(gd).sects
	assert_true(c0 / maxf(float(cands[0].value), 1e-9) <= float(cfg.save_payback_max), "the best work pays back within save_payback_max (else this fixture tests nothing)")
	var total: float = 0.0
	var seasons: int = 0
	while seasons < 6 and int(_db.get_record("places", str(cands[0].place)).qi.get("layer2", {}).get(str(cands[0].id), {}).get("level", 0)) < int(cands[0].level):
		var spent: float = SectWorks.build_best(gd, _db, s, budget)
		assert_true(spent <= budget + 1e-6, "season %d takes at most its own budget (%.0f of %.0f)" % [seasons, spent, budget])
		total += spent
		seasons += 1
	assert_true(seasons >= 3, "it saved for several seasons (%d)" % seasons)
	assert_true(total >= c0 - 1e-6, "and paid the whole level over them")
