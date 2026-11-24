extends DaoTestSuite
## Living World Tick Formulas H, the talent and place multiplier (design/gdd/living-world-tick.md, AC-LW-31 and AC-LW-32;
## q_i read as Travel & Map Formula B's stacked density, user decision 2026-11-24), and the settled cap kept to
## settlements (Travel & Map rule 34, Formula M). One small world per suite, read-only except where a test copies it.

var _db: WorldDB


func before() -> void:
	var r := RandomNumberGenerator.new()
	r.seed = 4242
	_db = WorldBuilder.new(game_data(), TestFixtures.tree()).generate(r, "4242")


func _npcs(db: WorldDB) -> Array:
	return db.living().filter(func(p): return bool(p.get("alive", false)) and not bool(p.get("is_beast", false)) and not bool(p.get("is_player", false)))


func test_spring_means_make_the_mean_multiplier_one_and_keep_the_order_ac_lw_31() -> void:
	var gd := game_data()
	var cache := {}
	var means: Dictionary = TalentPlace.recompute(gd, _db, cache)
	var people: Array = _npcs(_db)
	assert_true(people.size() >= 20, "a world with NPCs (%d)" % people.size())
	var rows: Array = []
	var sum_m: float = 0.0
	for p in people:
		var raw_i: float = TalentPlace.raw(gd, _db, p, cache)
		var s_i: float = TalentPlace.s_of(gd, raw_i, float(means.mean_raw))
		assert_true(s_i >= 0.5 - 1e-12 and s_i <= 2.0 + 1e-12, "s_i %.4f inside [0.5, 2.0]" % s_i)
		var m_i: float = TalentPlace.mult(gd, _db, p, cache)
		sum_m += m_i
		rows.append([raw_i, m_i])
	assert_near(sum_m / float(people.size()), 1.0, 1e-9, "the mean of m_i is 1")
	rows.sort_custom(func(a, b): return float(a[0]) < float(b[0]))
	for i in range(1, rows.size()):
		assert_true(float(rows[i][1]) >= float(rows[i - 1][1]) - 1e-12, "a higher raw_i never has a lower m_i")


func test_gamma_zero_makes_every_multiplier_one_ac_lw_32() -> void:
	var gd := GameData.load_from("res://assets/data")   # its own copy: the knob is changed here
	gd.world_gen().tick["talent_gamma"] = 0.0
	var cache := {}
	TalentPlace.recompute(gd, _db, cache)
	for p in _npcs(_db).slice(0, 30):
		assert_near(TalentPlace.mult(gd, _db, p, cache), 1.0, 1e-12, "m_i is 1 at gamma 0")
	TalentPlace.recompute(game_data(), _db, {})   # the suite's world keeps the shipped means


func test_a_sect_member_reads_the_seat_and_its_buildings_raise_q() -> void:
	var gd := game_data()
	var member: Dictionary = {}
	var seat: Dictionary = {}
	for p in _npcs(_db):
		var sid: String = str(p.get("sect_id", ""))
		if sid == "":
			continue
		var s: Dictionary = _db.get_record("places", str(_db.get_record("sects", sid).hq_place_id))
		if not s.is_empty() and s.has("qi"):
			member = p
			seat = s
			break
	assert_false(member.is_empty(), "a sect member with a seat")
	if member.is_empty():
		return
	var away: Array = _db.find("places", func(x): return str(x.id) != str(seat.id) and x.has("qi"))
	var was: String = str(member.location_id)
	member["location_id"] = str(away[0].id)   # standing elsewhere: the seat still counts
	var q0: float = TalentPlace.place_q(gd, _db, member, {})
	member["location_id"] = was
	var expect: float = float(LandQi.stacked_density(gd, null, seat.qi, float(seat.density), 0.0).total)
	assert_near(q0, expect, 1e-9, "a member reads the seat's stacked density, not where they stand")
	var saved: Dictionary = Dictionary(seat.qi.get("layer2", {})).duplicate(true)
	if not seat.qi.has("layer2"):
		seat.qi["layer2"] = {}
	seat.qi.layer2["spirit_grove"] = {"level": 2, "unpaid": 0, "element": ""}
	var q1: float = TalentPlace.place_q(gd, _db, member, {})
	seat.qi["layer2"] = saved
	assert_true(q1 > q0, "a spirit grove at the seat raises the member's q (%.3f -> %.3f)" % [q0, q1])


func test_the_settled_cap_holds_in_settlements_but_not_at_sect_seats() -> void:
	var gd := game_data()
	var city: Array = _db.find("places", func(p): return str(p.get("kind", "")) == "city")
	var seats: Array = _db.find("places", func(p): return str(p.get("kind", "")) in ["great_seat", "minor_seat"])
	assert_false(city.is_empty() or seats.is_empty(), "a city and a sect seat")
	assert_true(bool(city[0].qi.get("settled", false)), "a city is settled ground")
	assert_near(float(LandQi.stacked_density(gd, null, city[0].qi, 1.7, 0.5).total), 1.8, 1e-9, "a city home stays at 1.8")
	for s in seats:
		assert_false(bool(s.qi.get("settled", false)), "%s carries no settled cap" % s.name)
		assert_near(float(s.qi.get("prebuilt", 0.0)), 0.4, 1e-9, "%s keeps the ground's own works" % s.name)
	var st: Dictionary = LandQi.stacked_density(gd, null, seats[0].qi, 1.7, 0.0)
	assert_true(float(st.total) > 1.8, "a seat passes 1.8 (%.3f)" % float(st.total))
