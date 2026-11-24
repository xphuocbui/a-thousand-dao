extends DaoTestSuite
## Provinces Stage 4: the sect halls and their hooks (design/quick-specs/province-building-catalogue.md, Cultivation),
## and sects repairing ruined buildings. One world per suite; each test puts back what it changes.

var _db: WorldDB


func before() -> void:
	var r := RandomNumberGenerator.new()
	r.seed = 4242
	_db = WorldBuilder.new(game_data(), TestFixtures.tree()).generate(r, "4242")


func _tx() -> Dictionary:
	return _db.find("sects", func(s): return str(s.get("key", "")) == "thien_xu")[0]


func _seat_province(s: Dictionary) -> Dictionary:
	return Provinces.of_place(game_data(), _db, _db.get_record("places", str(s.hq_place_id)))


func _with_hall(kind: String, level: int) -> Array:
	var gd := game_data()
	var v: Dictionary = _seat_province(_tx())
	var saved: Array = Array(v.buildings).duplicate(true)
	v["buildings"] = Array(v.buildings).filter(func(b): return str(b.kind) != kind)
	v.buildings.append(ProvinceBuildings.make(v, kind, level))
	ProvinceBuildings.tally_halls(gd, _db)
	return [v, saved]


func _restore(pair: Array) -> void:
	pair[0]["buildings"] = pair[1]
	ProvinceBuildings.tally_halls(game_data(), _db)


func _member(s: Dictionary, at_seat: bool) -> Character:
	var c := Character.from_dict({"id": "p_test", "realm_index": 2, "sect_id": str(s.id)})
	c.location_id = str(s.hq_place_id) if at_seat else "nowhere"
	return c


func test_the_tally_counts_a_halls_levels_at_its_sects_seat() -> void:
	var pair := _with_hall("formation_hall", 3)
	assert_eq(ProvinceBuildings.sect_hall(_db, str(_tx().id), "formation_hall"), 3, "the seat's formation hall, level 3")
	_restore(pair)


func test_halls_give_members_their_rows_at_the_seat_and_away() -> void:
	var gd := game_data()
	var pair := _with_hall("alchemy_hall", 2)
	var p2 := _with_hall("formation_hall", 2)
	var at: StatSheet = StatSheet.build(_member(_tx(), true), gd, _db, null)
	var away: StatSheet = StatSheet.build(_member(_tx(), false), gd, _db, null)
	assert_near(at.total("alchemy_success"), 10.0, 1e-6, "alchemy hall 2 at the seat: +5 x 2")
	assert_near(away.total("alchemy_success"), 0.0, 1e-6, "away from the seat: nothing")
	assert_near(away.total("formation_power_pct"), 6.0, 1e-6, "the formation hall helps every member: +3 x 2")
	_restore(p2)
	_restore(pair)


func test_a_talisman_hall_raises_the_drawing_chance() -> void:
	var gd := game_data()
	var pair := _with_hall("talisman_hall", 4)
	var c := _member(_tx(), true)
	var sheet: StatSheet = StatSheet.build(c, gd, _db, null)
	var t := Talismans.new(gd, _db, ItemFactory.new(gd))
	var id: String = str(t.config().talismans[0].id)
	var with_hall: float = t.success_chance(c, sheet, id).total
	_restore(pair)
	var plain: float = t.success_chance(c, StatSheet.build(c, gd, _db, null), id).total
	assert_true(with_hall >= plain, "the hall never lowers it (%.1f vs %.1f)" % [with_hall, plain])
	assert_true(with_hall > plain or plain >= float(t.config().max_success), "it raises it unless already at the top")


func test_a_regions_alchemy_halls_raise_its_markets_pill_success() -> void:
	var gd := game_data()
	var m: Dictionary = _db.all(WorldEconomy.TABLE)[0]
	var rid: String = str(m.regions.keys()[0])
	var reg: Dictionary = _db.get_record("regions", rid)
	var saved: Dictionary = Dictionary(reg.get("halls", {})).duplicate()
	reg["halls"] = {"alchemy_hall": 5}
	var ps: float = 0.8
	var got: float = CraftEconomy.ps_at(gd, _db, m, "pill", ps)
	reg["halls"] = saved
	assert_near(got, 1.0 - 0.2 / 1.5, 1e-9, "1 - (1 - 0.8) / (1 + 0.1 x 5)")
	assert_near(CraftEconomy.ps_at(gd, _db, m, "artifact", ps), CraftEconomy.ps_at(gd, _db, m, "artifact", ps), 1e-12, "other kinds read their own halls")


func test_a_meditation_chamber_adds_to_a_members_breakthrough_step() -> void:
	var gd := game_data()
	var rec: Dictionary = {}
	for p in _db.living():
		if str(p.get("sect_id", "")) == str(_tx().id) and int(p.get("realm_index", 0)) == 1:
			rec = p
			break
	assert_false(rec.is_empty(), "a Trúc Cơ member of Thiên Xu")
	var plain: float = ProgressionEdges.npc_step_chance(rec, gd, _db).total
	var pair := _with_hall("meditation_chamber", 3)
	var with_hall: float = ProgressionEdges.npc_step_chance(rec, gd, _db).total
	_restore(pair)
	var hi: float = float(ProgressionEdges.config(gd).npc.gate_steps[1].max)
	assert_near(with_hall, minf(plain + 0.03, hi), 1e-9, "+0.01 a level, within the gate's band")


func test_a_recruitment_hall_raises_the_intake() -> void:
	var gd := game_data()
	var s: Dictionary = _tx()
	var base: int = SectEconomy.intake(gd, _db, s, 10)
	var pair := _with_hall("recruitment_hall", 5)
	var more: int = SectEconomy.intake(gd, _db, s, 10)
	_restore(pair)
	assert_true(base > 0, "Thiên Xu takes recruits at 10 members")
	assert_true(absf(float(more) - 1.5 * float(base)) <= 1.0, "x(1 + 0.1 x 5), within rounding (%d vs %d)" % [more, base])


func test_a_ruined_building_is_offered_for_repair_at_half_its_price() -> void:
	var gd := game_data()
	var s: Dictionary = _tx()
	var v: Dictionary = _seat_province(s)
	var saved: Array = Array(v.buildings).duplicate(true)
	var arr: Array = Array(v.buildings).filter(func(b): return str(b.kind) == "gathering_array")
	arr[0]["state"] = "ruined"
	var rep: Array = SectWorks.candidates(gd, _db, s).filter(func(c): return bool(c.get("repair", false)) and str(c.building) == str(arr[0].id))
	v["buildings"] = saved
	assert_eq(rep.size(), 1, "the ruined array is a repair candidate")
	var full: int = ProvinceBuildings.cost(gd, "gathering_array", int(arr[0].level), SectWorks.free_level(gd, _db, s, "gathering_array"))
	assert_near(float(rep[0].cost), 0.5 * float(full), 1.0, "at repair_frac 0.5 of the level's price")
