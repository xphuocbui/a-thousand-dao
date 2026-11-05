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
