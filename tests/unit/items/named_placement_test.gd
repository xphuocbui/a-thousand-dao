extends DaoTestSuite
## Item Database rule 20d (AC-ID-90): a new world holds exactly one record of every unique named
## template, held by an NPC whose realm fits it or Lost at a place; rule 14: a holder's death with
## no killer leaves what they held Lost where they died.


func _world(seed_v: int) -> WorldDB:
	var r := RandomNumberGenerator.new()
	r.seed = seed_v
	return WorldGenerator.new(game_data(), TestFixtures.tree()).generate(r)


func test_a_new_world_holds_one_record_of_every_unique_named_template() -> void:
	var gd := game_data()
	var items := ItemFactory.new(gd)
	var db := _world(11)
	var min_realm: int = int(gd.artifacts_file().named.holder_realm_min)
	for t in gd.named_items():
		var recs: Array = db.find("items", func(r): return str(r.get("named", "")) == str(t.id))
		if not items.is_unique(str(t.id)):
			assert_eq(recs.size(), 0, "repeatable %s is not placed" % t.id)
			continue
		assert_eq(recs.size(), 1, "one %s" % t.id)
		var held_by: String = str(recs[0].owner_id)
		var table: String = db.table_of(held_by)
		assert_true(table in ["people", "places"], "%s held or Lost" % t.id)
		if table == "people":
			var p: Dictionary = db.get_record("people", held_by)
			assert_true(int(p.realm_index) >= min_realm, "holder of %s fits" % t.id)
		else:
			assert_true(bool(recs[0].get("lost", false)), "%s marked Lost" % t.id)


func test_a_holder_who_dies_without_a_killer_leaves_items_lost_where_they_died() -> void:
	var db := WorldDB.new()
	var pid: String = db.add("people", {"name": "Lão", "alive": false, "location_id": "l1", "equipped": [], "equip_slots": {}})
	var aid: String = db.add("items", {"kind": "artifact", "name": "Thử", "owner_id": pid})
	db.get_record("people", pid)["equipped"] = [aid]
	db.items_on_death(pid, "l1")
	assert_eq(db.get_record("items", aid).owner_id, "l1", "Lost at the place of death")
	assert_true(bool(db.get_record("items", aid).get("lost", false)), "flagged Lost")
	assert_eq(db.get_record("people", pid).equipped, [], "no longer worn")


func test_a_killer_takes_unbound_items_but_bound_ones_are_lost() -> void:
	var db := WorldDB.new()
	var pid: String = db.add("people", {"name": "Lão", "alive": false, "location_id": "l1", "equipped": [], "equip_slots": {}})
	var free_item: String = db.add("items", {"kind": "artifact", "name": "A", "owner_id": pid})
	var bound_item: String = db.add("items", {"kind": "artifact", "name": "B", "owner_id": pid, "bound": true})
	db.items_on_death(pid, "l1", "p_killer")
	assert_eq(db.get_record("items", free_item).owner_id, "p_killer", "loot")
	assert_eq(db.get_record("items", bound_item).owner_id, "l1", "bound stays at the place")
