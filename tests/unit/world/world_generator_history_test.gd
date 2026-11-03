extends DaoTestSuite
## WorldGenerator: generated history must stay consistent with the present state.


func _world(seed_v: int) -> WorldDB:
	var gen := WorldGenerator.new(game_data(), TestFixtures.tree())
	return gen.generate(rng(seed_v))


func test_breakthrough_legends_are_ordered_and_unique_per_person() -> void:
	# Regression: a person used to "break into Trúc Cơ" several times, or into
	# Nguyên Anh before Trúc Cơ.
	var gd := game_data()
	for seed_v in [777, 4242, 9001]:
		var db := _world(seed_v)
		var seen: Dictionary = {}
		for e in db.all("events"):
			if e.type != "breakthrough":
				continue
			var pid: String = e.people[0]
			var realm_name: String = str(e.data.refs.realm)
			var r: int = -1
			for i in gd.realms().size():
				if gd.realm(i).name == realm_name:
					r = i
			var prev: int = int(seen.get(pid, 0))
			assert_true(r > prev, "seed %d: %s broke into %s after realm %d" % [seed_v, pid, realm_name, prev])
			seen[pid] = r


func test_breakthrough_legends_never_exceed_present_realm() -> void:
	var db := _world(777)
	var gd := game_data()
	for e in db.all("events"):
		if e.type != "breakthrough":
			continue
		var person: Dictionary = db.get_record("people", e.people[0])
		var realm_name: String = str(e.data.refs.realm)
		assert_true(gd.realm_index_by_name(realm_name) <= int(person.realm_index), "%s is %d now but a legend says %s" % [person.name, int(person.realm_index), realm_name])


func test_world_has_people_in_every_town() -> void:
	var db := _world(777)
	for place in db.find("places", func(p): return p.type in ["thanh", "tran", "phuong_thi"]):
		var here: Array = db.find("people", func(p): return p.alive and str(p.location_id) == place.id)
		assert_true(here.size() >= 2, "%s has %d residents" % [place.name, here.size()])


func test_every_event_reference_exists() -> void:
	var db := _world(4242)
	for e in db.all("events"):
		for ref in Array(e.people) + Array(e.places) + Array(e.items):
			assert_false(db.lookup(str(ref)).is_empty(), "event %s references missing %s" % [e.id, ref])
