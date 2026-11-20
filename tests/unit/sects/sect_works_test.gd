extends DaoTestSuite
## Sects develop their land (design/gdd/travel-map.md rules 31-33, Formula J; design/gdd/sects.md F2's work_max).


func _world() -> Dictionary:
	var gd := game_data()
	var r := RandomNumberGenerator.new()
	r.seed = 7
	var db: WorldDB = WorldBuilder.new(gd, TestFixtures.tree()).generate(r, "7")
	return {"gd": gd, "db": db}


func test_work_max_follows_holdings() -> void:
	var gd := game_data()
	var db := WorldDB.new()
	var s := {"id": "s_x", "kind": "minor", "levels": {"holdings": 5}}
	db.put("sects", s)
	assert_eq(SectWorks.work_max(gd, db, s), 3, "ceil(5 / 2)")
	s.levels.holdings = 0
	assert_eq(SectWorks.work_max(gd, db, s), 0, "no works without Holdings")


func test_a_sect_builds_the_best_work_on_its_land_and_production_rises() -> void:
	var w := _world()
	var gd: GameData = w.gd
	var db: WorldDB = w.db
	var sect: Dictionary = db.find("sects", func(s): return str(s.get("key", "")) == "thien_xu")[0]
	var cands := SectWorks.candidates(gd, db, sect)
	assert_false(cands.is_empty(), "Thiên Xu has works it could build")
	var best: Dictionary = cands[0]
	var p: Dictionary = db.get_record("places", str(best.place))
	var before: float = float(p.get("site", {}).get("works_prod", 0.0))
	var spent := SectWorks.build_best(gd, db, sect, 1.0e9)
	assert_true(spent > 0.0, "it built")
	assert_eq(int(p.qi.layer2[str(best.id)].level), int(best.level), "the best work rose a level")
	if p.has("site") and str(MapWorks.work(gd, str(best.id)).stat) == "production":
		assert_true(float(p.site.works_prod) > before, "the site's production gain rose")
	assert_eq(SectWorks.build_best(gd, db, sect, 0.0), 0.0, "no budget, no works")


func test_unpaid_works_fade() -> void:
	var w := _world()
	var gd: GameData = w.gd
	var db: WorldDB = w.db
	var sect: Dictionary = db.find("sects", func(s): return str(s.get("key", "")) == "thien_xu")[0]
	var mine: Dictionary = db.find("places", func(p): return str(p.get("holder", "")) == str(sect.id) and p.has("site"))[0]
	if not mine.qi.has("layer2"):
		mine.qi["layer2"] = {}
	mine.qi.layer2["worked_mine"] = {"level": 2, "unpaid": 0}
	var money := MoneyLedger.new(db)
	money.burn("sect:%s" % sect.id, money.balance("sect:%s" % sect.id), "test")
	for i in 2:
		SectWorks.upkeep(gd, db, money)
	assert_eq(int(mine.qi.layer2.worked_mine.level), 1, "two unpaid seasons cost a level")
