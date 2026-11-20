extends DaoTestSuite
## WorldBuilder (design/gdd/world-generation.md Core Rules 1-15, Formulas A-D): a new game's world is continent 11
## with its authored history. One world is built per suite (a full build takes seconds) and only read by the tests.

const SEED := "4242"

var _b: WorldBuilder
var _db: WorldDB


func before() -> void:
	var r := RandomNumberGenerator.new()
	r.seed = 4242
	_b = WorldBuilder.new(game_data(), TestFixtures.tree())
	_db = _b.generate(r, SEED)


func _hist() -> Dictionary:
	return game_data().file("world_history")


func test_the_world_builds_with_no_errors_at_the_authored_start_year() -> void:
	assert_true(_b.errors.is_empty(), "no errors: %s" % str(_b.errors))
	assert_eq(_b.current_year, 1200, "Core Rule 11: every game starts in year 1,200")


func test_the_base_is_the_authored_continent() -> void:
	var cont: Dictionary = game_data().file("world_continent")
	assert_eq(_db.count("places"), cont.places.size(), "every continent place")
	assert_eq(_db.count("regions"), cont.regions.size(), "every region")
	for p in _db.all("places"):
		assert_true(str(p.region_id) != "" or int(p.continent_id) == 0, "%s sits in a region" % p.name)
		assert_true(p.has("qi") and float(p.density) >= 0.3, "%s carries its Formula C qi" % p.name)


func test_routes_become_symmetric_links_timed_by_formula_d() -> void:
	var travel: Dictionary = game_data().file("travel_rules")
	for p in _db.all("places"):
		for l in p.links:
			var back: Array = _db.get_record("places", str(l.to)).links.filter(func(x): return str(x.to) == str(p.id))
			assert_eq(back.size(), 1, "%s -> %s has its way back" % [p.name, l.to])
			assert_true(float(l.seasons) > 0.0, "a trip takes time")
	for rt in game_data().file("world_continent").routes:
		var a: Dictionary = _db.get_record("places", _b.place_ids[int(rt.a)])
		var link: Array = a.links.filter(func(x): return str(x.to) == _b.place_ids[int(rt.b)])
		assert_true(float(link[0].seasons) <= ContinentData.trip_seasons(rt, travel) + 0.001, "Formula D: the quicker of a pair's routes")


func test_the_thirty_sects_start_as_authored_with_their_leaders() -> void:
	var active: Array = _db.find("sects", func(s): return s.status == "active")
	assert_eq(active.size(), 30, "7 great and 23 minor sects")
	for s in active:
		var leader: Dictionary = _db.get_record("people", str(s.leader_id))
		assert_true(bool(leader.get("alive", false)), "%s has a living leader" % s.name)
		assert_eq(str(leader.get("sect_rank", "")), "tong_chu", "%s's leader is its head" % s.name)
		assert_eq(str(_db.get_record("places", str(s.hq_place_id)).sect_id), str(s.id), "%s's seat is its place" % s.name)
	var tx: Dictionary = _db.find("sects", func(s): return str(s.get("key", "")) == "thien_xu")[0]
	assert_eq(int(tx.treasury), 90000, "Thiên Xu Tông's authored treasury")
	assert_eq(str(tx.alignment), "trung", "and its alignment")
	assert_eq(_db.find("sects", func(s): return s.status == "fallen").size(), _hist().fallen_sects.size(), "the fallen sects are history")


func test_the_chronicle_and_annals_are_the_event_log_in_order() -> void:
	var events: Array = _db.all("events")
	assert_eq(events.size(), _hist().events.size(), "every landmark and annal, nothing generated")
	var last: int = -1
	for e in events:
		assert_true(int(e.year) >= last, "ordered by year")
		last = int(e.year)
		assert_true(bool(e.data.get("authored", false)), "authored")
	var c001: Array = events.filter(func(e): return str(e.data.id) == "C001")
	assert_eq(str(c001[0].text), str(_hist().events.filter(func(e): return str(e.id) == "C001")[0].text_vi), "canon Vietnamese text")


func test_the_fixed_cast_is_the_same_in_every_game() -> void:
	var r2 := RandomNumberGenerator.new()
	r2.seed = 99
	var other := WorldBuilder.new(game_data(), TestFixtures.tree())
	var odb: WorldDB = other.generate(r2, "99")
	for p in _hist().people:
		var a: Dictionary = _db.get_record("people", _b.person_ids[str(p.key)])
		var b: Dictionary = odb.get_record("people", other.person_ids[str(p.key)])
		assert_eq(str(a.name), str(p.name), "%s by name" % p.key)
		assert_eq(bool(a.alive), bool(p.alive), "%s alive as authored" % p.key)
		if bool(p.alive):
			assert_eq(int(a.realm_index), game_data().realm_index(str(p.realm)), "%s at the authored realm" % p.key)
			assert_eq(int(a.age), 1200 - int(p.born), "%s at the authored age" % p.key)
			assert_eq(a.linh_can, b.linh_can, "%s has the same root in another game" % p.key)


func test_realm_headcounts_meet_formula_a_exactly() -> void:
	var weights: Array = [3936.0, 844.0, 191.0, 27.0, 3.0]
	assert_eq(WorldBuilder.realm_targets(5000, weights), [3935, 844, 191, 27, 3], "Formula A's example at 5,000")
	assert_eq(WorldBuilder.realm_targets(3000, weights), [2361, 506, 115, 16, 2], "and at 3,000")
	# the test data's world is small (fast fixtures), so the cast can exceed a realm's target there
	var pc: Dictionary = game_data().world_gen().people
	var n: int = maxi(int(pc.world_cultivators), int(pc.world_cultivators_min))
	var targets: Array = WorldBuilder.realm_targets(n, game_data().world_gen().realm_distribution.map(func(x): return float(x.weight)))
	var cast := [0, 0, 0, 0, 0]
	for p in _hist().people:
		if bool(p.alive):
			cast[game_data().realm_index(str(p.realm))] += 1
	var by := [0, 0, 0, 0, 0]
	for p in _db.find("people", func(x): return x.alive and not x.get("is_beast", false)):
		by[int(p.realm_index)] += 1
	for r in 5:
		assert_eq(by[r], maxi(int(targets[r]), int(cast[r])), "realm %d: the cast plus F_r = T_r - K_r (Formula B)" % r)


func test_hidden_spots_are_keyed_on_seed_and_slot_alone() -> void:
	assert_eq(_b.ledger.size(), _hist().hidden_slots.size() + _hist().tile_secrets.size(), "every slot and tile secret rolled")
	var again := WorldBuilder.new(game_data(), TestFixtures.tree())
	again._seed = SEED
	for s in _hist().hidden_slots:
		var i: int = again.slot_pick("slot", str(s.slot), s.candidates.size())
		assert_eq(_b.ledger[str(s.slot)].tile, s.candidates[i], "%s: the same pick, whatever else ran" % s.slot)
	var meta: Dictionary = _db.get_record("world", "w_meta")
	assert_eq(meta.ledger.size(), _b.ledger.size(), "the ledger is saved with the world")
	var changed: int = 0
	again._seed = "another"
	for s in _hist().hidden_slots:
		if again.slot_pick("slot", str(s.slot), s.candidates.size()) != int(_b.ledger[str(s.slot)].candidate):
			changed += 1
	assert_true(changed > 0, "another seed moves some hidden places")


func test_random_members_join_inside_the_history() -> void:
	var checked: int = 0
	for s in _db.find("sects", func(x): return x.status == "active"):
		for mid in s.members:
			var m: Dictionary = _db.get_record("people", str(mid))
			if not m.has("joined_year"):
				continue
			checked += 1
			assert_true(int(m.joined_year) >= int(s.founded_year), "no one joins before the founding")
			assert_true(int(m.joined_year) <= 1200, "or after the start")
			assert_true(int(m.joined_year) - int(m.born_year) >= 16, "or before 16")
			if str(m.get("master_id", "")) != "":
				var master: Dictionary = _db.get_record("people", str(m.master_id))
				assert_true(int(master.realm_index) > int(m.realm_index), "a master is of a higher realm")
	var random: int = _db.find("people", func(x): return x.alive and str(x.get("created_by", "")) == "worldgen").size()
	assert_true(checked > 0, "random cultivators join sects")
	assert_eq(checked, random, "in the small test world every random cultivator finds a sect place (F17 targets exceed it)")
