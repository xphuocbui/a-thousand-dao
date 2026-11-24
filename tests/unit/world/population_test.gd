extends DaoTestSuite
## Provinces F3, the yearly mortal population (design/gdd/provinces.md rule 5, F3; provinces-runtime Stage 5), with the
## GDD's own examples. Each test uses one settlement province of a fresh suite world and puts back what it changes.

var _db: WorldDB


func before() -> void:
	var r := RandomNumberGenerator.new()
	r.seed = 4242
	_db = WorldBuilder.new(game_data(), TestFixtures.tree()).generate(r, "4242")


func _province() -> Dictionary:
	for v in _db.all(Provinces.TABLE):
		if str(v.kind) == "settlement" and Array(v.places).any(func(pid): return _db.get_record("places", str(pid)).has("local")):
			return v
	return {}


# A province whose region nobody holds: no market (fed) and no war (safe); no buildings: capacity P0 (1 + cap0).
func _bare(v: Dictionary, p0: float, p: float) -> Dictionary:
	var reg: Dictionary = _db.get_record("regions", str(v.region_id))
	var keep := {"holder": reg.get("holder", ""), "buildings": Array(v.buildings).duplicate(true), "p0": v.p0, "population": v.population}
	reg["holder"] = ""
	v["buildings"] = []
	v["p0"] = p0
	v["population"] = p
	return keep


func _put_back(v: Dictionary, keep: Dictionary) -> void:
	_db.get_record("regions", str(v.region_id))["holder"] = keep.holder
	v["buildings"] = keep.buildings
	v["p0"] = keep.p0
	v["population"] = keep.population


func _only(v: Dictionary) -> void:   # one province's yearly step (the others are not part of the fixture)
	var all: Array = _db.all(Provinces.TABLE)
	var others := {}
	for x in all:
		if x != v and str(x.kind) == "settlement":
			others[str(x.id)] = x.kind
			x["kind"] = "_skip"
	Provinces.yearly(game_data(), _db)
	for x in all:
		if others.has(str(x.id)):
			x["kind"] = others[str(x.id)]


func test_a_fed_safe_province_grows_toward_capacity_f3_example() -> void:
	var v: Dictionary = _province()
	var keep := _bare(v, 10.0, 10.0)
	_only(v)
	assert_near(float(v.capacity), 12.0, 1e-9, "C = 10 x (1 + 0.2)")
	assert_near(float(v.population), 10.05, 1e-9, "+0.03 x 10 x (1 - 10/12) = +0.05 a year")
	_put_back(v, keep)


func test_an_over_full_province_falls_toward_capacity_and_never_below_the_floor() -> void:
	var v: Dictionary = _province()
	var keep := _bare(v, 10.0, 20.0)
	_only(v)
	assert_near(float(v.population), 16.0, 1e-9, "P 20, C 12, fed: falls by f_fam of P to 16")
	v["population"] = 1.0
	_only(v)
	assert_true(float(v.population) >= 3.0 - 1e-9, "never below pop_floor x P0 = 3")
	_put_back(v, keep)


func test_famine_and_war_cut_the_population() -> void:
	var gd := game_data()
	var v: Dictionary = {}
	for x in _db.all(Provinces.TABLE):
		var mid: String = WorldEconomy.market_of_region(_db, _db.get_record("regions", str(x.region_id)))
		if str(x.kind) == "settlement" and mid != "":
			v = x
			break
	assert_false(v.is_empty(), "a settlement province with a market")
	var m: Dictionary = _db.get_record(WorldEconomy.TABLE, WorldEconomy.market_of_region(_db, _db.get_record("regions", str(v.region_id))))
	var covers := {}
	for k in m.classes:
		covers[k] = m.classes[k].get("cover", 1.0)
		if str(k).begins_with("herb") or str(k).begins_with("beast"):
			m.classes[k]["cover"] = 0.3
	var keep := {"buildings": Array(v.buildings).duplicate(true), "p0": v.p0, "population": v.population}
	v["buildings"] = []
	v["p0"] = 10.0
	v["population"] = 10.0
	var holder: Dictionary = _db.get_record("sects", str(_db.get_record("regions", str(v.region_id)).holder))
	var wars: Array = Array(holder.get("wars", [])).duplicate()
	holder["wars"] = []
	_only(v)
	assert_near(float(v.population), 9.0, 1e-9, "famine at cover 0.3: -0.2 x (1 - 0.3/0.6) = -10 %")
	holder["wars"] = ["w_test"]
	for k in m.classes:
		m.classes[k]["cover"] = 1.0
	v["population"] = 10.0
	_only(v)
	assert_near(float(v.population), 9.5, 1e-9, "fed but at war: no growth, then x (1 - 0.05)")
	holder["wars"] = wars
	for k in covers:
		m.classes[k]["cover"] = covers[k]
	v["buildings"] = keep.buildings
	v["p0"] = keep.p0
	v["population"] = keep.population


func test_the_settlements_workforce_follows_the_province() -> void:
	var v: Dictionary = _province()
	var pl: Dictionary = {}
	for pid in v.places:
		var p: Dictionary = _db.get_record("places", str(pid))
		if p.has("local"):
			pl = p
	var base: float = float(pl.local.get("pop0", pl.local.pop))
	var keep := _bare(v, 10.0, 15.0)
	_only(v)
	assert_near(float(pl.local.pop), snappedf(base * float(v.population) / 10.0, 0.001), 1e-6, "local.pop = its start x P / P0")
	_put_back(v, keep)
	pl.local["pop"] = base
