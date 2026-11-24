extends DaoTestSuite
## Provinces Stage 7: province modifiers (rule 12, F4), shocks (blight, raid, beast tide) and the province states
## (States table). Event tests use their own GameData copy with the chance raised, so they touch no shared data.

var _db: WorldDB


func before() -> void:
	var r := RandomNumberGenerator.new()
	r.seed = 4242
	_db = WorldBuilder.new(game_data(), TestFixtures.tree()).generate(r, "4242")


func _gd_with(event: String, chance: float) -> GameData:
	var gd := GameData.load_from("res://assets/data")
	gd.world_gen().people.world_cultivators = 80
	for k in gd.file(Provinces.FILE).events.kinds:
		gd.file(Provinces.FILE).events.kinds[k]["chance"] = chance if str(k) == event else 0.0
	gd.file(Provinces.FILE).events["log"] = false
	return gd


func test_modifiers_multiply_production_by_kind_f4_example() -> void:
	var v := {"modifiers": [{"stat": "production", "scope": "herb", "kind": "inc", "value": -0.7, "seasons": 4}]}
	assert_near(Provinces.mult_of(v, "production", "herb"), 0.3, 1e-9, "a blight: inc -0.7 on herbs")
	assert_near(Provinces.mult_of(v, "production", "ore"), 1.0, 1e-9, "ore untouched")
	assert_near((400.0 + 150.0 + 120.0) * Provinces.mult_of(v, "production", "herb"), 201.0, 1e-9, "F4's example: 201 during the blight")
	v.modifiers.append({"stat": "production", "scope": "", "kind": "more", "value": 0.5, "seasons": -1})
	assert_near(Provinces.mult_of(v, "production", "herb"), 0.45, 1e-9, "a more on all kinds multiplies: 0.3 x 1.5")


func test_a_blight_strikes_and_cuts_herbs_then_expires() -> void:
	var gd := _gd_with("blight", 1.0)
	var v: Dictionary = _db.all(Provinces.TABLE).filter(func(x): return str(x.kind) == "settlement")[0]
	var keep: Array = Array(v.modifiers).duplicate(true)
	var others: Array = _db.all(Provinces.TABLE).filter(func(x): return x != v)
	var saved_mods := {}
	for x in others:
		saved_mods[str(x.id)] = Array(x.modifiers).duplicate(true)
	Provinces.events(gd, _db, 1201, 0)
	assert_true(Provinces.has_event(v, "blight"), "struck by a blight at chance 1")
	assert_true(Provinces.states(gd, _db, v).has("struck"), "the province shows Struck")
	assert_near(Provinces.mult_of(v, "production", "herb"), 0.3, 1e-9, "herbs at 30 %")
	for i in 4:
		Provinces.events(_gd_with("blight", 0.0), _db, 1201, i + 1)
	assert_false(Provinces.has_event(v, "blight"), "gone after its 4 seasons")
	v["modifiers"] = keep
	for x in others:
		x["modifiers"] = saved_mods[str(x.id)]


func test_warding_walls_soften_a_raid() -> void:
	var gd := _gd_with("raid", 1.0)
	var v: Dictionary = _db.all(Provinces.TABLE).filter(func(x): return str(x.kind) == "settlement")[0]
	var keep := {"m": Array(v.modifiers).duplicate(true), "b": Array(v.buildings).duplicate(true)}
	v["modifiers"] = []
	v["buildings"] = Array(v.buildings).filter(func(b): return str(b.kind) != "warding_wall")
	Provinces.events(gd, _db, 1201, 0)
	var bare: float = Provinces.mult_of(v, "production", "ore")
	v["modifiers"] = []
	v.buildings.append(ProvinceBuildings.make(v, "warding_wall", 5))
	Provinces.events(gd, _db, 1201, 0)
	var walled: float = Provinces.mult_of(v, "production", "ore")
	v["modifiers"] = keep.m
	v["buildings"] = keep.b
	assert_near(bare, 0.7, 1e-9, "a raid: -30 % on every kind")
	assert_near(walled, 1.0 - 0.3 / 2.0, 1e-9, "walls 5: -30 % / (1 + 0.2 x 5)")


func test_events_are_the_same_for_the_same_seed_and_season() -> void:
	var gd := _gd_with("blight", 0.3)
	var snap := func() -> Array:
		return _db.all(Provinces.TABLE).filter(func(x): return Provinces.has_event(x, "blight")).map(func(x): return str(x.id))
	var keep := {}
	for x in _db.all(Provinces.TABLE):
		keep[str(x.id)] = Array(x.modifiers).duplicate(true)
		x["modifiers"] = []
	Provinces.events(gd, _db, 1210, 2)
	var first: Array = snap.call()
	for x in _db.all(Provinces.TABLE):
		x["modifiers"] = []
	Provinces.events(gd, _db, 1210, 2)
	assert_eq(snap.call(), first, "the same provinces struck again")
	assert_true(first.size() > 50 and first.size() < 400, "about 30 % of 705 struck (%d)" % first.size())
	for x in _db.all(Provinces.TABLE):
		x["modifiers"] = keep[str(x.id)]


func test_states_name_under_connected_and_normal() -> void:
	var gd := game_data()
	var v: Dictionary = Dictionary(_db.all(Provinces.TABLE).filter(func(x): return str(x.kind) == "settlement")[0]).duplicate(true)
	v["modifiers"] = []
	v["access"] = 0.5
	var st: Array = Provinces.states(gd, _db, v)
	assert_true(st.has("under_connected"), "access 0.5 < 0.7: Under-connected")
	v["access"] = 1.0
	var st2: Array = Provinces.states(gd, _db, v)
	assert_true(st2.has("normal") or st2.has("war_touched"), "otherwise Normal (or War-touched): %s" % str(st2))
