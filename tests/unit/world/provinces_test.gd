extends DaoTestSuite
## Provinces as live world records, Stage 1 in shadow (design/gdd/provinces.md rules 1-7, F1, F2, F4, F5; ADR-0008;
## AC-PV-01 counts as amended to 705 / 468 / 237). One world per suite; the season tests copy nothing and only add
## seasons of MapProduction and the province step.

var _db: WorldDB


func before() -> void:
	var r := RandomNumberGenerator.new()
	r.seed = 4242
	_db = WorldBuilder.new(game_data(), TestFixtures.tree()).generate(r, "4242")


func _session() -> GameSession:
	var gd := game_data()
	var llm := LlmService.new(gd)
	llm.enabled = false
	var s := GameSession.new(gd, llm, TestFixtures.tree())
	s.new_game(4242, {"mode": "roll", "name": "Thợ Đất", "gender": "male", "origin": "tan_tu"})
	s.pending_event = {}
	return s


func test_the_world_has_every_province_of_the_shapes_ac_pv_01() -> void:
	var all: Array = _db.all(Provinces.TABLE)
	assert_eq(all.size(), 705, "every province")
	assert_eq(all.filter(func(v): return str(v.kind) == "settlement").size(), 468, "settlement provinces")
	assert_eq(all.filter(func(v): return str(v.kind) == "wilderness").size(), 237, "wilderness provinces")
	for v in all:
		assert_true(str(v.region_id) != "", "%s sits in a region" % v.id)


func test_every_place_has_a_province_and_lakes_take_the_nearest_land() -> void:
	for p in _db.all("places"):
		var v: String = str(p.get("province_id", ""))
		assert_true(v != "" and _db.has_record(Provinces.TABLE, v), "%s (%s) has a province" % [p.name, p.get("kind", "")])
	var lakes: Array = _db.all("places").filter(func(p): return int(p.get("continent_id", -1)) in [190, 191, 192, 193, 194])
	assert_eq(lakes.size(), 5, "the five lakes outside every listed province")
	for p in lakes:
		var v: String = str(p.province_id)
		var pv: Dictionary = _db.get_record(Provinces.TABLE, v)
		assert_eq(str(pv.region_id), str(p.region_id), "%s's province is in its own region" % p.name)


func test_province_production_adds_up_to_the_regions_every_season() -> void:
	# continent-wide: 15 border places (mostly mines) lie in a province of a neighbouring region, so the per-region sums
	# differ by exactly their output until Stage 6 settles which region they belong to (provinces-runtime plan)
	var gd := game_data()
	for i in 4:
		MapProduction.season(gd, _db, i == 0, true)
		Provinces.season(gd, _db)
		var want := {}
		for r in _db.all("regions"):
			for g in r.get("production_value", {}):
				want[g] = float(want.get(g, 0.0)) + float(r.production_value[g])
		var got := {}
		for v in _db.all(Provinces.TABLE):
			var part: Dictionary = v.production_value if str(v.kind) == "settlement" else ({} if not Array(v.pass_to).is_empty() else v.own_value)
			for g in part:   # settlement production, plus wilderness the hops do not reach (it passes nothing)
				got[g] = float(got.get(g, 0.0)) + float(part[g])
		for g in want:
			assert_near(float(got.get(g, 0.0)), float(want[g]), 1e-6 * maxf(1.0, float(want[g])), "season %d, %s" % [i, g])
		for g in got:
			assert_true(want.has(g) or float(got[g]) < 1e-9, "season %d: %s only in provinces" % [i, g])


func test_only_the_known_border_places_sit_in_another_regions_province() -> void:
	var across: Array = _db.all("places").filter(func(p): return str(p.get("region_id", "")) != str(_db.get_record(Provinces.TABLE, str(p.province_id)).region_id))
	assert_true(across.size() <= 15, "at most the 15 known border places (%d): %s" % [across.size(), str(across.map(func(p): return p.get("continent_id", p.id)))])


func test_wilderness_passes_its_output_by_border_share() -> void:
	for v in _db.all(Provinces.TABLE):
		if str(v.kind) != "wilderness" or Array(v.pass_to).is_empty():
			continue
		var tot: float = 0.0
		for t in v.pass_to:
			tot += float(t.share)
			var u: Dictionary = _db.get_record(Provinces.TABLE, str(t.province))
			assert_eq(int(u.dist), int(v.dist) - 1, "%s passes one hop nearer" % v.id)
			assert_eq(str(u.region_id), str(v.region_id), "within its region")
		assert_near(tot, 1.0, 1e-9, "%s's shares sum to 1" % v.id)


func test_slots_follow_the_seat_and_population_f5() -> void:
	var cs: Dictionary = game_data().file(Provinces.FILE)
	for v in _db.all(Provinces.TABLE):
		var want: int = int(cs.wild_slots)
		if str(v.kind) == "settlement":
			want = int(cs.base_slots.get(str(v.seat_kind), 0)) + int(floor(float(v.population) / float(cs.slot_pop_step)))
		assert_eq(int(v.slots), want, "%s slots" % v.id)


func test_goods_are_fixed_at_the_first_season_f1() -> void:
	var gd := game_data()
	var before := {}
	for v in _db.all(Provinces.TABLE):
		before[str(v.id)] = [str(v.main_good), Array(v.secondary_goods).duplicate()]
	MapProduction.season(gd, _db, false, true)
	Provinces.season(gd, _db)
	var with_good: int = 0
	for v in _db.all(Provinces.TABLE):
		assert_eq([str(v.main_good), Array(v.secondary_goods)], before[str(v.id)], "%s keeps its goods" % v.id)
		if str(v.main_good) != "":
			with_good += 1
	assert_true(with_good > 400, "most provinces have a main good (%d)" % with_good)


func test_a_save_from_before_provinces_is_refused_d7() -> void:
	var s := _session()
	var d: Dictionary = JSON.parse_string(JSON.stringify(s.to_dict()))
	var gd := game_data()
	var llm := LlmService.new(gd)
	llm.enabled = false
	var ok := GameSession.new(gd, llm, TestFixtures.tree())
	assert_true(ok.load_dict(d).ok, "a save of this version loads")
	d.db.tables.world.w_meta.erase("provinces_version")
	var old := GameSession.new(gd, llm, TestFixtures.tree())
	var r: Dictionary = old.load_dict(d)
	assert_false(r.ok, "a save with no provinces version is refused")
	assert_true(str(r.lines).contains("provinces"), "and says why")
