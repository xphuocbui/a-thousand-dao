extends DaoTestSuite
## WorldDB's living view and owner index return exactly what the scans do (a random property test: adds, puts,
## removes, gives, deaths and in-place deaths, in a seeded order).


func _scan_items(db: WorldDB, owner: String) -> Array:
	return db.find("items", func(r): return str(r.get("owner_id", "")) == owner).map(func(r): return str(r.id))


func test_owner_index_matches_the_scan_under_random_edits() -> void:
	var db := WorldDB.new()
	var r := RandomNumberGenerator.new()
	r.seed = 4242
	var owners: Array = ["p1", "p2", "p3", "l1", "l2", ""]
	for i in 40:
		db.add("items", {"owner_id": owners[r.randi() % owners.size()], "bound": r.randf() < 0.2})
	db.begin_owner_index()
	for step in 400:
		var ids: Array = db.all("items").map(func(x): return str(x.id))
		match r.randi() % 5:
			0:
				db.add("items", {"owner_id": owners[r.randi() % owners.size()]})
			1:
				db.give_item(ids[r.randi() % ids.size()], owners[r.randi() % owners.size()])
			2:
				var rec: Dictionary = Dictionary(db.get_record("items", ids[r.randi() % ids.size()])).duplicate()
				rec["owner_id"] = owners[r.randi() % owners.size()]
				db.put("items", rec)
			3:
				if ids.size() > 5:
					db.remove("items", ids[r.randi() % ids.size()])
			4:
				db.items_on_death(owners[r.randi() % 3], "l1", "", owners[r.randi() % 3] if r.randf() < 0.5 else "")
		for o in owners:
			var got: Array = db.items_of(o).map(func(x): return str(x.id))
			if got != _scan_items(db, o):   # report the first mismatch only
				assert_eq(got, _scan_items(db, o), "step %d owner %s" % [step, o])
				return
	db.end_owner_index()
	assert_eq(db.items_of("p1").map(func(x): return str(x.id)), _scan_items(db, "p1"), "off again: the scan")


func test_living_matches_the_filtered_table_under_random_edits() -> void:
	var db := WorldDB.new()
	var r := RandomNumberGenerator.new()
	r.seed = 77
	for i in 30:
		db.add("people", {"alive": true, "name": "x%d" % i})
	for step in 300:
		var all: Array = db.all("people")
		var p: Dictionary = all[r.randi() % all.size()]
		match r.randi() % 5:
			0:
				db.add("people", {"alive": r.randf() < 0.9})
			1:
				p["alive"] = false   # an in-place death, as the tick does it
			2:
				var rec: Dictionary = p.duplicate()
				rec["alive"] = r.randf() < 0.7   # a put may also revive a record
				db.put("people", rec)
			3:
				db.remove("people", str(p.id))
			4:
				pass
		var want: Array = db.all("people").filter(func(x): return bool(x.get("alive", true))).map(func(x): return str(x.id))
		if db.living().map(func(x): return str(x.id)) != want:   # report the first mismatch only
			assert_eq(db.living().map(func(x): return str(x.id)), want, "step %d" % step)
			return
	var back := WorldDB.from_dict(db.to_dict())
	assert_eq(back.living().map(func(x): return str(x.id)), db.living().map(func(x): return str(x.id)), "after a load")
