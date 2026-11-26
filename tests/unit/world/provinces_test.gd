extends DaoTestSuite
## Provinces as live world records, Stage 1 in shadow (design/gdd/provinces.md rules 1-7, F1, F2, F4, F5; ADR-0008;
## AC-PV-01 counts as amended to 705 / 468 / 237, and 472 / 233 since the seat moves, Provinces rule 2a 2026-11-26). One world per suite; the season tests copy nothing and only add
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
	# Provinces rule 2a (2026-11-26): the four wilderness provinces a moved seat lands in become settlement provinces
	assert_eq(all.filter(func(v): return str(v.kind) == "settlement").size(), 472, "settlement provinces")
	assert_eq(all.filter(func(v): return str(v.kind) == "wilderness").size(), 233, "wilderness provinces")
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
		var standing: int = Array(v.buildings).filter(func(x): return str(x.get("state", "")) != "cancelled").size()
		assert_eq(int(v.slots), maxi(want, standing), "%s slots: never below the buildings standing (rule 10 fills a seat)" % v.id)


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


func test_rule_10_starting_buildings_are_placed_and_project_onto_places() -> void:
	var gd := game_data()
	var great: Array = _db.all(Provinces.TABLE).filter(func(v): return str(v.seat_kind) == "great_seat")
	assert_eq(great.size(), 7, "the seven great seats")
	for v in great:
		var kinds: Array = Array(v.buildings).map(func(b): return str(b.kind))
		assert_eq(kinds.count("gathering_array"), 2, "%s: gathering array x2" % v.id)
		assert_eq(kinds.count("road"), 3, "%s: road x3" % v.id)
		var seat: Dictionary = _db.get_record("places", str(v.seat_place))
		var sum: int = Array(v.buildings).filter(func(b): return str(b.kind) == "gathering_array").reduce(func(acc, b): return acc + int(b.level), 0)
		assert_eq(int(seat.qi.layer2.get("sect_array", {}).get("level", 0)), sum, "%s: the two arrays count as their summed level at the seat" % v.id)
		assert_eq(str(seat.qi.layer2.sect_array.get("by", "")), ProvinceBuildings.BY, "written by the province")
	for v in _db.all(Provinces.TABLE).filter(func(x): return str(x.kind) == "wilderness"):
		var has_mine: bool = Array(v.places).any(func(pid): return str(_db.get_record("places", str(pid)).get("kind", "")) == "mine")
		assert_eq(Array(v.buildings).any(func(b): return str(b.kind) == "mine_works"), has_mine, "%s: an outpost only with a mine" % v.id)
	for v in _db.all(Provinces.TABLE):
		for b in v.buildings:
			if not bool(ProvinceBuildings.kind(gd, str(b.kind)).get("live", false)):
				assert_eq(ProvinceBuildings.upkeep_of(gd, _db, v, b), 0.0, "%s %s: not live, not billed" % [v.id, b.kind])


func test_starting_levels_and_halls_follow_the_lore() -> void:
	var gd := game_data()
	var tx: Dictionary = _db.find("sects", func(s): return str(s.get("key", "")) == "thien_xu")[0]
	var seat_v: Dictionary = Provinces.of_place(gd, _db, _db.get_record("places", str(tx.hq_place_id)))
	var arrays: Array = Array(seat_v.buildings).filter(func(b): return str(b.kind) == "gathering_array")
	assert_eq(arrays.map(func(b): return int(b.level)), [4, 4], "Thiên Xu's seat arrays at level 4 (Institutions 12 x 0.34)")
	assert_true(Array(seat_v.buildings).any(func(b): return str(b.kind) == "formation_hall"), "its specialty (trận sư) gives a formation hall")
	for v in _db.all(Provinces.TABLE):
		if ProvinceBuildings.payer(_db, v) == str(tx.id):
			var kinds: Array = Array(v.buildings).map(func(b): return str(b.kind))
			assert_true(kinds.has("warding_wall") and kinds.has("caravan_post"), "%s: the world police's wall and post" % v.id)
	var thai: Array = _db.find("sects", func(s): return str(s.get("key", "")) == "thai_chi")
	if not thai.is_empty():
		var tv: Dictionary = Provinces.of_place(gd, _db, _db.get_record("places", str(thai[0].hq_place_id)))
		assert_true(Array(tv.buildings).any(func(b): return str(b.kind) == "alchemy_hall"), "Thải Chi Cốc (herb fields and alchemy) starts with an alchemy hall")
	for v in _db.all(Provinces.TABLE):
		if ProvinceBuildings.payer(_db, v) == "":
			for b in v.buildings:
				assert_eq(int(b.level), 1, "%s %s: unheld land starts at level 1" % [v.id, b.kind])
