extends DaoTestSuite
## Provinces F6 and the economy's switch to provinces (design/gdd/provinces.md rule 11, F6; ADR-0008;
## provinces-runtime Stage 6): infrastructure, usage and access, the start floor, the border places following their
## province, and Regional Economy & Trade taking each province's production at its access.

var _db: WorldDB


func before() -> void:
	var r := RandomNumberGenerator.new()
	r.seed = 4242
	_db = WorldBuilder.new(game_data(), TestFixtures.tree()).generate(r, "4242")


func _settlement() -> Dictionary:
	return _db.all(Provinces.TABLE).filter(func(v): return str(v.kind) == "settlement")[0]


func test_the_imports_example_gives_access_one_half_f6() -> void:
	var gd := game_data()
	var v: Dictionary = Dictionary(_settlement()).duplicate(true)
	v["seat_kind"] = "village"
	v["road_tiles"] = 0
	v["river_tiles"] = 0
	v["buildings"] = []
	v["infra_old"] = 900.0   # village 100 + 900: infrastructure 1,000
	var reg: Dictionary = _db.get_record("regions", str(v.region_id))
	var keep := {"d_loc": reg.get("d_loc", {}), "pop_units": reg.get("pop_units", 0.0)}
	reg["d_loc"] = {"herb": 2000.0}
	reg["pop_units"] = float(v.population)   # the whole region's need is this province's
	Provinces._access(gd, _db, v, {})
	reg["d_loc"] = keep.d_loc
	reg["pop_units"] = keep.pop_units
	assert_near(float(v.usage), 2000.0, 1e-6, "a valley making no herbs but needing 2,000")
	assert_near(float(v.access), 0.5, 1e-9, "infrastructure 1,000 against usage 2,000")


func test_every_settlement_province_starts_at_access_one_half_or_more() -> void:
	var low: Array = _db.all(Provinces.TABLE).filter(func(v): return str(v.kind) == "settlement" and float(v.access) < 0.5 - 1e-9)
	assert_eq(low.size(), 0, "the old roads and porters lift every province to start_access_min: %s" % str(low.map(func(v): return v.id)))


func test_every_place_sits_in_its_provinces_region() -> void:
	for p in _db.all("places"):
		var v: Dictionary = _db.get_record(Provinces.TABLE, str(p.province_id))
		assert_eq(str(p.region_id), str(v.region_id), "%s follows its province (user decision 2026-11-24)" % p.name)
		assert_true(Array(_db.get_record("regions", str(p.region_id)).places).has(str(p.id)), "%s is listed in its region" % p.name)


func test_a_road_raises_a_short_provinces_access() -> void:
	var gd := game_data()
	var v: Dictionary = {}
	for x in _db.all(Provinces.TABLE):
		if str(x.kind) == "settlement" and float(x.access) < 1.0:
			v = x
			break
	if v.is_empty():
		return   # every province of this world reaches access 1: nothing to raise
	var before: float = float(v.access)
	var b: Dictionary = ProvinceBuildings.make(v, "road", 3)
	v.buildings.append(b)
	Provinces._access(gd, _db, v, v.production_value)
	v.buildings.erase(b)
	var after: float = float(v.access)
	Provinces._access(gd, _db, v, v.production_value)
	assert_true(after > before, "a level-3 road (+600) lifts access (%.3f -> %.3f)" % [before, after])


func test_the_economy_takes_each_provinces_production_at_its_access() -> void:
	var gd := game_data()
	assert_true(bool(gd.file(Provinces.FILE).get("economy_reads_provinces", false)), "the switch is on in the shipped data")
	var m: Dictionary = _db.all(WorldEconomy.TABLE)[0]
	var got: Dictionary = WorldEconomy._inputs(gd, _db, m)
	var cfg: Dictionary = gd.file(WorldEconomy.FILE)
	var sect: Dictionary = _db.get_record("sects", str(m.sect_id))
	var lv: Dictionary = sect.get("levels", {})
	var want := {}
	for rid in m.regions:
		var r: Dictionary = _db.get_record("regions", rid)
		var safe: float = float(EconomyRules.access(cfg, float(m.regions[rid].d), int(lv.get("trade", 0)), int(lv.get("military", 0)), bool(r.get("war", false))).safe)
		for v in _db.all(Provinces.TABLE):
			if str(v.kind) != "settlement" or str(v.region_id) != str(rid):
				continue
			for g in v.production_value:
				var cid: String = WorldEconomy.class_of(gd, str(g))
				want[cid] = float(want.get(cid, 0.0)) + float(v.production_value[g]) * float(v.access) * safe
	for cid in got.reached:
		assert_near(float(got.reached[cid]), float(want.get(cid, 0.0)), 1e-6 * maxf(1.0, float(want.get(cid, 0.0))), "%s reached = province value x access x safety" % cid)
