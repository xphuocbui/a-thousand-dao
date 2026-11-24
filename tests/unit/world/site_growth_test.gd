extends DaoTestSuite
## Site growth (design/gdd/provinces.md rule 8's bullet, user decisions 2026-11-24 and D5a; provinces-runtime Stage 3):
## a site that starts at grade minor steps up a grade for each level of its province's matching building above level 1,
## never above its land's grade, keeping its reserve fraction, and follows the building back down.

var _db: WorldDB


func before() -> void:
	var r := RandomNumberGenerator.new()
	r.seed = 4242
	_db = WorldBuilder.new(game_data(), TestFixtures.tree()).generate(r, "4242")


func _minor_site(kinds: Array, stone: bool = false) -> Dictionary:
	for p in _db.all("places"):
		if p.has("site") and str(p.get("site_grade", "")) == "minor" and str(p.get("kind", "")) in kinds and (str(p.site.kind) == "linh_thach") == stone:
			return p
	return {}


func _match(kind: String) -> String:
	return {"mine": "mine_works", "beast_lair": "hunting_lodge", "spirit_vein": "spirit_fields", "hot_spring": "spirit_fields"}.get(kind, "")


func test_a_minor_site_steps_up_with_its_building_and_keeps_its_reserve_fraction() -> void:
	var gd := game_data()
	var p: Dictionary = _minor_site(["mine", "beast_lair", "spirit_vein", "hot_spring"])
	assert_false(p.is_empty(), "a kept new site at grade minor")
	var v: Dictionary = Provinces.of_place(gd, _db, p)
	var saved: Array = Array(v.buildings).duplicate(true)
	v["buildings"] = Array(v.buildings).filter(func(b): return str(b.kind) != _match(str(p.kind)))
	p.site["reserve"] = float(p.site.reserve_max) * 0.6
	var b: Dictionary = ProvinceBuildings.make(v, _match(str(p.kind)), 1)
	v.buildings.append(b)
	ProvinceBuildings.grow_sites(gd, _db, v)
	assert_eq(str(p.site.grade), "minor", "level 1: still minor")
	b["level"] = 2
	ProvinceBuildings.grow_sites(gd, _db, v)
	assert_eq(str(p.site.grade), "small", "level 2: one step, to small")
	assert_near(float(p.site.reserve) / float(p.site.reserve_max), 0.6, 0.01, "the reserve keeps its fraction (D5a)")
	var mp: Dictionary = gd.file(MapProduction.DATA_FILE)
	var cap: String = "small"
	for g in mp.grade_by_density:
		if float(p.qi.get("land_density", p.get("density", 1.0))) >= float(g[0]):
			cap = str(g[1])
			break
	b["level"] = 9
	ProvinceBuildings.grow_sites(gd, _db, v)
	assert_eq(str(p.site.grade), cap, "never above the land's grade (%s)" % cap)
	b["state"] = "ruined"
	ProvinceBuildings.grow_sites(gd, _db, v)
	assert_eq(str(p.site.grade), "minor", "a ruined building: back to minor")
	v["buildings"] = saved
	ProvinceBuildings.grow_sites(gd, _db, v)


func test_an_old_site_never_changes_grade() -> void:
	var gd := game_data()
	for p in _db.all("places"):
		if p.has("site") and str(p.get("site_grade", "")) == "" and str(p.get("kind", "")) == "mine":
			var v: Dictionary = Provinces.of_place(gd, _db, p)
			var before: String = str(p.site.grade)
			var b: Dictionary = ProvinceBuildings.make(v, "mine_works", 6)
			v.buildings.append(b)
			ProvinceBuildings.grow_sites(gd, _db, v)
			v.buildings.erase(b)
			assert_eq(str(p.site.grade), before, "an authored site keeps its land grade")
			return


func test_a_stone_site_never_grows() -> void:
	var gd := game_data()
	var p: Dictionary = _minor_site(["mine", "spirit_vein", "beast_lair", "hot_spring"], true)
	if p.is_empty():
		return   # no minor stone site in this world
	var v: Dictionary = Provinces.of_place(gd, _db, p)
	var b: Dictionary = ProvinceBuildings.make(v, _match(str(p.kind)), 6)
	v.buildings.append(b)
	ProvinceBuildings.grow_sites(gd, _db, v)
	v.buildings.erase(b)
	assert_eq(str(p.site.grade), "minor", "a spirit-stone site keeps its grade (user decision 2026-11-24)")
