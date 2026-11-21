extends DaoTestSuite
## Item Database rule 14 (user decision 2026-11-13): with no killer, a dead NPC's unbound items go to a close
## relationship (the strongest living disciple, else the living master), else the sect successor (same rank, then the
## nearest rank above, then below), else they are Lost where the NPC died. A dead sect leader's successor leads.


func _person(db: WorldDB, fields: Dictionary) -> String:
	var rec := {"name": "Thử", "alive": true, "realm_index": 0, "stage": 0, "master_id": "", "sect_id": "",
		"sect_rank": "", "location_id": "l1", "equipped": [], "equip_slots": {}}
	rec.merge(fields, true)
	return db.add("people", rec)


func _item(db: WorldDB, owner: String, bound: bool = false) -> String:
	return db.add("items", {"kind": "artifact", "name": "Bảo", "owner_id": owner, "bound": bound})


func test_the_strongest_living_disciple_inherits_first() -> void:
	var gd := game_data()
	var db := WorldDB.new()
	var master: String = _person(db, {"realm_index": 3})
	_person(db, {"realm_index": 1, "master_id": master})
	var strong: String = _person(db, {"realm_index": 2, "master_id": master})
	_person(db, {"realm_index": 2, "master_id": master, "alive": false})
	assert_eq(Inheritance.heir_of(db, gd, db.get_record("people", master)), strong, "highest realm among the living")


func test_with_no_disciple_the_living_master_inherits() -> void:
	var gd := game_data()
	var db := WorldDB.new()
	var master: String = _person(db, {"realm_index": 3})
	var pupil: String = _person(db, {"master_id": master})
	assert_eq(Inheritance.heir_of(db, gd, db.get_record("people", pupil)), master, "the master")


func test_the_sect_successor_is_the_same_rank_then_above_then_below() -> void:
	var gd := game_data()
	var db := WorldDB.new()
	var dead: String = _person(db, {"sect_id": "s1", "sect_rank": "noi_mon"})
	var peer: String = _person(db, {"sect_id": "s1", "sect_rank": "noi_mon", "realm_index": 1})
	var elder: String = _person(db, {"sect_id": "s1", "sect_rank": "truong_lao", "realm_index": 2})
	_person(db, {"sect_id": "s2", "sect_rank": "noi_mon", "realm_index": 4})
	var rec: Dictionary = db.get_record("people", dead)
	assert_eq(Inheritance.sect_successor(db, gd, rec), peer, "same rank first")
	db.get_record("people", peer)["alive"] = false
	assert_eq(Inheritance.sect_successor(db, gd, rec), elder, "then the nearest rank above")
	db.get_record("people", elder)["alive"] = false
	var outer: String = _person(db, {"sect_id": "s1", "sect_rank": "ngoai_mon"})
	assert_eq(Inheritance.sect_successor(db, gd, rec), outer, "then below")


func test_a_leader_is_succeeded_by_the_strongest_elder() -> void:
	var gd := game_data()
	var db := WorldDB.new()
	var leader: String = _person(db, {"sect_id": "s1", "sect_rank": "tong_chu", "realm_index": 3})
	_person(db, {"sect_id": "s1", "sect_rank": "truong_lao", "realm_index": 2, "stage": 1})
	var strong: String = _person(db, {"sect_id": "s1", "sect_rank": "truong_lao", "realm_index": 2, "stage": 4})
	assert_eq(Inheritance.sect_successor(db, gd, db.get_record("people", leader)), strong, "strongest elder")


func test_the_heir_takes_unbound_items_and_bound_ones_are_lost() -> void:
	var db := WorldDB.new()
	var dead: String = _person(db, {"alive": false})
	var heir: String = _person(db, {})
	var free_item: String = _item(db, dead)
	var bound_item: String = _item(db, dead, true)
	db.items_on_death(dead, "l1", "", heir)
	assert_eq(db.get_record("items", free_item).owner_id, heir, "inherited")
	assert_false(bool(db.get_record("items", free_item).get("lost", false)), "not Lost")
	assert_eq(db.get_record("items", bound_item).owner_id, "l1", "bound stays at the place")


func test_with_no_killer_and_no_heir_items_are_lost_at_the_place() -> void:
	var gd := game_data()
	var db := WorldDB.new()
	var loner: String = _person(db, {"alive": false})
	var item: String = _item(db, loner)
	db.items_on_death(loner, "l1", "", Inheritance.heir_of(db, gd, db.get_record("people", loner)))
	assert_eq(db.get_record("items", item).owner_id, "l1", "Lost where they died")
	assert_true(bool(db.get_record("items", item).get("lost", false)), "flagged Lost")


func test_a_leader_dying_of_old_age_hands_over_items_and_the_sect() -> void:
	var gd := game_data()
	var db := WorldDB.new()
	var leader: String = _person(db, {"sect_id": "s1", "sect_rank": "tong_chu", "realm_index": 2})
	var elder: String = _person(db, {"sect_id": "s1", "sect_rank": "truong_lao", "realm_index": 2})
	db.put("sects", {"id": "s1", "name": "Tông", "leader_id": leader, "members": [leader, elder], "status": "active", "hq_place_id": "l1"})
	var relic: String = _item(db, leader)
	# The death step of the season tick (a full tick would also top the world up to thousands of new cultivators).
	WorldTicker.new(gd, db, BuildGenerator.new(gd, TestFixtures.tree(), db)).old_age_death(db.get_record("people", leader), 1, 0)
	assert_false(bool(db.get_record("people", leader).alive), "the leader died of old age")
	assert_eq(db.get_record("sects", "s1").leader_id, elder, "the elder leads")
	assert_eq(db.get_record("people", elder).sect_rank, "tong_chu", "and holds the leader's rank")
	assert_eq(db.get_record("items", relic).owner_id, elder, "and inherited the relic")


func test_a_death_leaves_the_disciples_and_master_grieving() -> void:
	# NPC Traits rule 11, trigger bereaved: the dead person's living close ties from the relationship store (master,
	# disciples, kin, đạo lữ, kết nghĩa; user decision 2026-11-21) gain Grieving (40 seasons)
	var gd := game_data()
	var db := WorldDB.new()
	var master: String = _person(db, {"realm_index": 3})
	var dead: String = _person(db, {"realm_index": 2})
	var pupil: String = _person(db, {})
	var child: String = _person(db, {"parent_id": dead})
	var other: String = _person(db, {"master_id": dead})   # an old field with no tie: not a close tie
	Ties.set_master(gd, db, dead, master, 0)
	Ties.set_master(gd, db, pupil, dead, 0)
	Ties.add_pinned(gd, db, dead, child, "kin", 0, true)
	db.get_record("people", other)["master_id"] = dead
	WorldTicker.new(gd, db, BuildGenerator.new(gd, TestFixtures.tree(), db)).old_age_death(db.get_record("people", dead), 1, 0)
	for pid in [master, pupil, child]:
		var g: Array = db.get_record("people", pid).get("npc_traits", {}).get("gained", [])
		assert_eq(g.map(func(e): return e.id), ["grieving"], "%s grieves" % pid)
	assert_false(db.get_record("people", other).has("npc_traits"), "a stranger does not")
