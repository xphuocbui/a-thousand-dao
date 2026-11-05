extends DaoTestSuite
## World population (design/gdd/canh-gioi.md rule 12, Formulas C2; linh-can.md rule 15): NPC gate
## odds, replacing the dead, the world's minimum, and archetypes that never change a root.


func _world(seed_v: int) -> WorldDB:
	return WorldGenerator.new(game_data(), TestFixtures.tree()).generate(rng(seed_v))


func _alive(db: WorldDB) -> int:
	return db.find("people", func(p): return p.alive and not p.get("is_beast", false)).size()


func _tick_years(db: WorldDB, years: int, seed_v: int) -> void:
	var gd := game_data()
	var ticker := WorldTicker.new(gd, db, BuildGenerator.new(gd, TestFixtures.tree(), db))
	var r := rng(seed_v)
	for y in years:
		for s in int(gd.cultivation_rules().seasons_per_year):
			ticker.tick(r, y, s)


func test_gate_steps_match_the_formula_ac53() -> void:
	var gd := game_data()
	# A score of exactly 0.5: rich family 0.3 + inner rank 0.1 + a variant 0.1.
	var half := {"linh_can": {"elements": {"kim": 40}, "variants": {"loi": 30}}, "sect_rank": "noi_mon", "background": "rich_family", "perks": []}
	var plain := {"linh_can": {"elements": {"kim": 40}, "variants": {}}, "sect_rank": "", "background": "", "perks": []}
	var want_base: Array = [0.123, 0.078, 0.059, 0.032]
	var want_half: Array = [0.1320, 0.0877, 0.0628, 0.0346]
	for g in 4:
		var a: Dictionary = plain.duplicate()
		a["realm_index"] = g
		var b: Dictionary = half.duplicate()
		b["realm_index"] = g
		assert_near(ProgressionEdges.npc_step_chance(a, gd).total, want_base[g], 1e-6, "gate %d base" % g)
		assert_near(ProgressionEdges.npc_step_chance(b, gd).total, want_half[g], 1e-4, "gate %d at e 0.5" % g)


func test_the_world_starts_at_its_configured_size() -> void:
	var people: Dictionary = game_data().world_gen().people
	var size_was: int = int(people.world_cultivators)
	people.world_cultivators = 200
	var alive: int = _alive(_world(11))
	people.world_cultivators = size_was
	assert_eq(alive, 200, "cultivators")


func test_the_dead_are_replaced_by_new_qi_refining_cultivators_ac69() -> void:
	var people: Dictionary = game_data().world_gen().people
	var size_was: int = int(people.world_cultivators)
	people.world_cultivators = 200
	var db := _world(12)
	var before: Array = db.all("people").map(func(p): return p.id)
	var victims: Array = db.find("people", func(p): return p.alive and not p.get("is_beast", false)).slice(0, 30)
	for p in victims:
		p["alive"] = false
	_tick_years(db, 1, 13)
	people.world_cultivators = size_was
	var fresh: Array = db.all("people").filter(func(p): return not before.has(p.id))
	assert_true(fresh.size() >= 30, "30 replaced, got %d" % fresh.size())
	assert_true(_alive(db) >= 200, "back to the target, got %d" % _alive(db))
	for p in fresh:
		assert_true(int(p.realm_index) == 0, "new cultivators start in Qi Refining")


func test_the_configured_size_cannot_go_below_the_minimum() -> void:
	var people: Dictionary = game_data().world_gen().people
	var floor_was: int = int(people.world_cultivators_min)
	people.world_cultivators_min = 200
	var alive: int = _alive(_world(14))
	people.world_cultivators_min = floor_was
	assert_eq(alive, 200, "the minimum wins over a smaller size")


func test_an_archetype_never_changes_a_root() -> void:
	var gd := game_data()
	var db := WorldDB.new()
	var builds := BuildGenerator.new(gd, TestFixtures.tree(), db)
	var r := rng(16)
	var singles: int = 0
	var without_kim: int = 0
	var kept: int = 0
	var n: int = 1500
	for i in n:
		var rec: Dictionary = db.get_record("people", builds.create_person(r, {"realm_index": 0, "stage": 0, "archetype": "kiem_tu"}))
		var elements: Dictionary = rec.linh_can.elements
		if elements.size() == 1:
			singles += 1
		if not elements.has("kim"):
			without_kim += 1
			if str(rec.archetype) == "kiem_tu":
				kept += 1
	assert_near(float(singles) / float(n), 0.45, 0.05, "single roots stay at the birth rate")
	assert_near(float(kept) / float(without_kim), 0.2, 0.05, "most switch, some keep it")


func _tick_season(db: WorldDB, seed_v: int) -> void:
	var gd := game_data()
	WorldTicker.new(gd, db, BuildGenerator.new(gd, TestFixtures.tree(), db)).tick(rng(seed_v), 1, 0)


func _age_out(db: WorldDB, count: int) -> void:
	for p in db.find("people", func(x): return x.alive and not x.get("is_beast", false)).slice(0, count):
		p["age"] = 100000.0


func test_the_world_is_back_at_its_size_the_season_its_dead_die_ac69() -> void:
	var people: Dictionary = game_data().world_gen().people
	var size_was: int = int(people.world_cultivators)
	people.world_cultivators = 200
	var db := _world(21)
	_age_out(db, 10)
	_tick_season(db, 22)
	people.world_cultivators = size_was
	assert_eq(_alive(db), 200, "replaced in the same season")


func test_the_intake_refills_to_the_minimum_over_a_smaller_size() -> void:
	var people: Dictionary = game_data().world_gen().people
	var size_was: int = int(people.world_cultivators)
	var floor_was: int = int(people.world_cultivators_min)
	people.world_cultivators = 100
	people.world_cultivators_min = 200
	var db := _world(23)
	_age_out(db, 10)
	_tick_season(db, 24)
	people.world_cultivators = size_was
	people.world_cultivators_min = floor_was
	assert_eq(_alive(db), 200, "the minimum holds after world generation too")
