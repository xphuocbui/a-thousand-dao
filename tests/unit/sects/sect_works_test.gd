extends DaoTestSuite
## Sects develop their land through province buildings (design/gdd/provinces.md rule 9 and States; Sects F2's free
## level; provinces-runtime Stage 2): ordering by value per linh thach, building over seasons, the projection onto the
## acting places, and upkeep that leaves buildings unpaid, then ruined.


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
	assert_eq(SectWorks.work_max(gd, db, s), 0, "free level 0 without Holdings")


func test_a_sect_orders_the_best_building_and_its_site_produces_more_once_built() -> void:
	var w := _world()
	var gd: GameData = w.gd
	var db: WorldDB = w.db
	var sect: Dictionary = db.find("sects", func(s): return str(s.get("key", "")) == "thien_xu")[0]
	var cands := SectWorks.candidates(gd, db, sect)
	assert_false(cands.is_empty(), "Thiên Xu has buildings it could order")
	var best: Dictionary = cands[0]
	var v: Dictionary = db.get_record(Provinces.TABLE, str(best.province))
	assert_eq(ProvinceBuildings.payer(db, v), str(sect.id), "in a province it pays for")
	var spent := SectWorks.build_best(gd, db, sect, 1.0e9)
	assert_true(spent > 0.0, "it paid")
	var b: Dictionary = {}
	for x in v.buildings:
		if str(x.kind) == str(best.kind) and int(x.target) == int(best.level):
			b = x
	assert_false(b.is_empty(), "the ordered level is on the province")
	assert_eq(str(b.state), "building", "building first")
	var site: Dictionary = {}
	for p in ProvinceBuildings.acting_places(gd, db, v, str(best.kind)):
		if p.has("site"):
			site = p
	var before: float = float(site.get("site", {}).get("works_prod", 0.0))
	for i in ProvinceBuildings.build_seasons(gd, str(best.kind), int(best.level)):
		ProvinceBuildings.season(gd, db, v)
	assert_eq([str(b.state), int(b.level)], ["active", int(best.level)], "built after its seasons")
	if not site.is_empty() and str(MapWorks.work(gd, str(ProvinceBuildings.kind(gd, str(best.kind)).work)).stat) == "production":
		assert_true(float(site.site.works_prod) > before, "the acting site's production gain rose")
	assert_eq(SectWorks.build_best(gd, db, sect, 0.0), 0.0, "no budget, nothing ordered")


func test_unpaid_buildings_count_nothing_then_ruin() -> void:
	var w := _world()
	var gd: GameData = w.gd
	var db: WorldDB = w.db
	var sect: Dictionary = db.find("sects", func(s): return str(s.get("key", "")) == "thien_xu")[0]
	var v: Dictionary = {}
	for x in db.all(Provinces.TABLE):
		if ProvinceBuildings.payer(db, x) == str(sect.id) and not ProvinceBuildings.acting_places(gd, db, x, "mine_works").is_empty():
			v = x
			break
	assert_false(v.is_empty(), "a province of Thiên Xu with a mine")
	var b: Dictionary = ProvinceBuildings.make(v, "mine_works", 2)
	v.buildings.append(b)
	ProvinceBuildings.project(gd, db, v)
	var site: Dictionary = ProvinceBuildings.acting_places(gd, db, v, "mine_works")[0]
	assert_true(float(site.site.works_prod) > 0.0, "an active mine works raises the site")
	var money := MoneyLedger.new(db)
	money.burn("sect:%s" % sect.id, money.balance("sect:%s" % sect.id), "test")
	SectWorks.upkeep(gd, db, money)
	ProvinceBuildings.season(gd, db, v)
	assert_eq(str(b.state), "unpaid", "one unpaid season: unpaid")
	assert_eq(ProvinceBuildings.effective(gd, b), 0, "an unpaid upkept building counts nothing")
	for i in int(ProvinceBuildings.cfg(gd).ruin_seasons):
		SectWorks.upkeep(gd, db, money)
		ProvinceBuildings.season(gd, db, v)
	assert_eq(str(b.state), "ruined", "ruined after ruin_seasons unpaid")
	assert_eq(int(b.level), 2, "the built level is kept for a repair")
