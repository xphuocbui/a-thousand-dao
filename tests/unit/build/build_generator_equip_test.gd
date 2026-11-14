extends DaoTestSuite
## BuildGenerator: generated NPCs use the same rules as the player.


func _gen() -> Dictionary:
	var gd := game_data()
	var db := WorldDB.new()
	return {"gd": gd, "db": db, "gen": BuildGenerator.new(gd, TestFixtures.tree(), db)}


func test_npcs_can_wield_artifacts_of_their_own_realm() -> void:
	# Regression: artifact thần thức cost scaled with the x100 power tier while thần thức
	# scaled x10, so Kết Đan and higher NPCs could not equip any of their own items.
	var t := _gen()
	var r := rng(5)
	for realm in [0, 1, 2, 3]:
		var equipped_any := 0
		for k in 10:
			var pid: String = t.gen.create_person(r, {"realm_index": realm, "archetype": "kiem_tu"})
			if not t.db.get_record("people", pid).equipped.is_empty():
				equipped_any += 1
		assert_true(equipped_any >= 7, "realm %d: only %d/10 NPCs could equip an artifact" % [realm, equipped_any])


func test_tree_points_spent_match_realm() -> void:
	var t := _gen()
	var pid: String = t.gen.create_person(rng(9), {"realm_index": 1, "stage": 2, "archetype": "dan_su"})
	var c := Character.from_dict(t.db.get_record("people", pid))
	var expected: int = t.gen.tree_points_for(1, 2)
	assert_eq(c.tree_nodes.size() - 1 + c.tree_points, expected, "allocated + unspent = earned")


func test_higher_realm_is_much_stronger() -> void:
	var t := _gen()
	var r := rng(11)
	var low := Character.from_dict(t.db.get_record("people", t.gen.create_person(r, {"realm_index": 1, "stage": 3})))
	var high := Character.from_dict(t.db.get_record("people", t.gen.create_person(r, {"realm_index": 2, "stage": 0})))
	assert_true(t.gen.power_of(high) > t.gen.power_of(low) * 2.5, "Kết Đan sơ >> Trúc Cơ đại viên mãn")


func test_npcs_slot_auxiliary_techniques_per_realm_ac_cp_42() -> void:
	# Cultivation Techniques rule 6 and AC-CP-42: at most 1 main and 2 auxiliaries, all usable, no duplicates;
	# generation fills world_generation.json npc_builds.aux_techniques_by_realm of them (1 at Qi Refining, then 2)
	var t := _gen()
	var r := rng(17)
	var want: Array = t.gd.world_gen().npc_builds.aux_techniques_by_realm
	for realm in [0, 1, 2, 3, 4]:
		for k in 8:
			var arch: String = "the_tu" if k % 4 == 0 else "kiem_tu"
			var c := Character.from_dict(t.db.get_record("people", t.gen.create_person(r, {"realm_index": realm, "archetype": arch})))
			var aux: Array = Array(c.aux_tech).filter(func(x): return str(x) != "")
			assert_eq(aux.size(), int(want[realm]), "realm %d: %d auxiliaries" % [realm, int(want[realm])])
			var keys: Array = [c.main_tech] + aux
			for key in keys:
				assert_true(CongPhap.usable(c, c.techniques[key].def), "realm %d: %s usable (%s, names %s, root %s, main %s)" % [realm, key, c.techniques[key].def.tech_kind, str(c.techniques[key].def.names), str(c.linh_can.elements.keys()) + str(c.linh_can.variants.keys()), str(key == c.main_tech)])
			var seen := {}
			for key in keys:
				assert_false(seen.has(key), "no duplicates")
				seen[key] = true
			for key in aux:
				var kind: String = str(c.techniques[key].def.tech_kind)
				assert_eq(kind, "body" if c.archetype == "the_tu" else "secret", "realm %d: %s aux kind" % [realm, c.archetype])
