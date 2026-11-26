extends DaoTestSuite
## The world-depth seat moves in the built world (design/map/continent-11/seat_moves.json; World Generation rules 16,
## 16a and AC-WG-52; Provinces rule 2a; Travel & Map rule 6 "Sect halls"; user rulings 2026-11-26). One world per
## suite.

var _db: WorldDB


func before() -> void:
	var r := RandomNumberGenerator.new()
	r.seed = 4242
	_db = WorldBuilder.new(game_data(), TestFixtures.tree()).generate(r, "4242")


func _place(cid: int) -> Dictionary:
	for p in _db.all("places"):
		if int(p.get("continent_id", -1)) == cid:
			return p
	return {}


func _sect(key: String) -> Dictionary:
	for s in _db.all("sects"):
		if str(s.get("key", "")) == key:
			return s
	return {}


func _l2(qi: Dictionary) -> float:
	return float(MapWorks.density(game_data(), qi, null).l2)


func test_founders_arrays_add_their_density_and_a_broken_one_adds_nothing_ac_wg_52() -> void:
	for row in [["phuong_minh", 449, 0.65], ["thuy_vi", 1110, 0.10]]:
		var hq: Dictionary = _db.get_record("places", str(_sect(str(row[0])).hq_place_id))
		assert_eq(int(hq.continent_id), int(row[1]), "%s sits at its new seat" % row[0])
		var with_array: Dictionary = Dictionary(hq.qi).duplicate(true)
		var without: Dictionary = with_array.duplicate(true)
		without.erase("seat_array")
		assert_float(_l2(with_array) - _l2(without)).is_equal_approx(float(row[2]), 0.0001)
		var broken: Dictionary = with_array.duplicate(true)
		broken.seat_array["broken"] = true
		assert_float(_l2(broken) - _l2(without)).is_equal_approx(0.0, 0.0001)


func test_a_seat_with_no_array_value_carries_none() -> void:
	# Ngạo Tuyết and Yến Quang move to denser land: their arrays are named records at 0 (Formula G)
	for key in ["ngao_tuyet", "yen_quang", "tung_dao"]:
		var hq: Dictionary = _db.get_record("places", str(_sect(key).hq_place_id))
		assert_false(Dictionary(hq.qi).has("seat_array"), "%s has no array density" % key)


func test_old_seats_become_sect_halls_settled_like_a_town() -> void:
	for row in [[3, "bang_tam", "Cựu Các"], [7, "thinh_vu", "Vũ Lâu"], [6, "phuong_minh", "Ngô Đồng Đình"]]:
		var p: Dictionary = _place(int(row[0]))
		assert_eq(str(p.kind), "sect_hall")
		assert_eq(str(p.name), str(row[2]))
		assert_eq(str(p.get("hall_of", "")), str(row[1]))
		assert_eq(str(p.holder), str(_sect(str(row[1])).id), "the sect holds its hall")
		assert_float(float(p.qi.prebuilt)).is_equal_approx(0.2, 0.0001)
		assert_true(bool(p.qi.get("settled", false)), "a sect hall carries the settled density cap, like a town")


func test_the_new_seat_is_the_sects_seat_and_keeps_its_name_as_former() -> void:
	var hq: Dictionary = _db.get_record("places", str(_sect("bang_tam").hq_place_id))
	assert_eq(int(hq.continent_id), 214)
	assert_eq(str(hq.kind), "great_seat")
	assert_eq(str(hq.name), "Băng Tâm Các")
	assert_eq(str(hq.former_name), "Hồ Thiên Phái")


func test_a_production_site_stays_with_its_seat() -> void:
	# Bình Thủy's new seat is the beast lair Cự Ngao Chử (302), a kept site: the seat keeps the lair's site
	var hq: Dictionary = _db.get_record("places", str(_sect("binh_thuy").hq_place_id))
	assert_eq(int(hq.continent_id), 302)
	assert_eq(str(hq.get("site_kind", "")), "beast_lair")
	assert_true(hq.has("site"), "the seat is still a site")
	# a vein the provinces-v2 pass left without a site (Hồng Đậu's 263, no_site) gains none by becoming a seat
	var hd: Dictionary = _db.get_record("places", str(_sect("hong_dau").hq_place_id))
	assert_false(hd.has("site"), "a no_site place stays without a site")


func test_the_province_a_seat_lies_in_is_its_seat_province_rule_2a() -> void:
	# Phượng Minh's court (449) lies in Phần Vũ's province: the great sect is its seat and its payer
	var pm: Dictionary = _sect("phuong_minh")
	var hq: Dictionary = _db.get_record("places", str(pm.hq_place_id))
	var v: Dictionary = _db.get_record(Provinces.TABLE, str(hq.province_id))
	assert_eq(str(v.key), "prov_phan_vu")
	assert_eq(str(v.seat_place), str(hq.id))
	assert_eq(str(v.seat_kind), "great_seat")
	assert_eq(ProvinceBuildings.payer(_db, v), str(pm.id))
	# Thính Vũ's peak (874) was in a wilderness province, which becomes a settlement province around the seat
	var tv: Dictionary = _db.get_record("places", str(_sect("thinh_vu").hq_place_id))
	var w: Dictionary = _db.get_record(Provinces.TABLE, str(tv.province_id))
	assert_eq(str(w.key), "prov_r19_30")
	assert_eq(str(w.kind), "settlement")
	assert_eq(str(w.seat_place), str(tv.id))


func test_a_minor_seat_in_a_city_province_is_a_vassal_seat() -> void:
	# Yến Quang (423) in Tang Ma Thành's province: the city keeps the province and its seat
	var yq: Dictionary = _sect("yen_quang")
	var hq: Dictionary = _db.get_record("places", str(yq.hq_place_id))
	var v: Dictionary = _db.get_record(Provinces.TABLE, str(hq.province_id))
	assert_eq(str(v.key), "prov_p80")
	assert_eq(str(v.seat_kind), "city")
	assert_true(str(v.seat_place) != str(hq.id), "the city stays the province's seat")
	assert_true(ProvinceBuildings.payer(_db, v) != str(yq.id), "the vassal seat does not pay for the province")


func test_every_new_seat_is_linked_and_the_island_seat_has_a_lane() -> void:
	for key in ["bang_tam", "binh_thuy", "ham_nguyet", "hong_dau", "lac_ha", "le_hoa", "le_tuyen", "minh_loan",
			"ngao_tuyet", "phuong_minh", "thinh_vu", "thuy_vi", "yen_quang"]:
		var hq: Dictionary = _db.get_record("places", str(_sect(key).hq_place_id))
		assert_true(Array(hq.links).size() > 0, "%s's new seat has a route" % key)
	var bt: Dictionary = _db.get_record("places", str(_sect("bang_tam").hq_place_id))
	var lane: Array = Array(bt.links).filter(func(l): return str(l.kind) == "lane")
	assert_eq(lane.size(), 1, "the island seat is reached by one sea lane")
	assert_eq(int(_db.get_record("places", str(lane[0].to)).continent_id), 1346)


func test_a_great_seat_in_a_minor_sects_province_gains_its_seat_halls_rule_2a() -> void:
	# Provinces rule 2a: the great sect gains its seat halls there (Phượng Minh, phap_tu: the scripture pavilion), even
	# though Phần Vũ's minor seat is in the same province
	var hq: Dictionary = _db.get_record("places", str(_sect("phuong_minh").hq_place_id))
	var v: Dictionary = _db.get_record(Provinces.TABLE, str(hq.province_id))
	var kinds: Array = Array(v.get("buildings", [])).map(func(b): return str(b.kind))
	assert_true(kinds.has("scripture_pavilion"), "Phượng Minh's seat hall stands in %s: %s" % [v.key, str(kinds)])


func test_a_player_can_walk_or_sail_off_the_island_and_lake_seats() -> void:
	# sect origins start at the new seats: Băng Tâm's island (214) and Lễ Tuyền's lake (193) must not trap a player
	var tg: TravelGrid = TravelGrid.of(game_data())
	for row in [[214, 1346], [193, 26]]:
		var a: Dictionary = _place(int(row[0]))
		var b: Dictionary = _place(int(row[1]))
		var trip: Dictionary = tg.trip(Vector2i(int(a.tile[0]), int(a.tile[1])), Vector2i(int(b.tile[0]), int(b.tile[1])), "ground", 1.0, 0.0)
		assert_false(trip.is_empty(), "a ground trip leaves %s for %s" % [a.name, b.name])


func test_every_minor_seat_province_is_seated_at_and_paid_by_its_sect_rule_9() -> void:
	# Provinces rule 9 and rule 2a (user ruling 2026-11-26): a province whose seat kind is a minor seat has that seat as
	# its seat place, so the minor sect seated in it is its payer (Bách Vũ's 330 in prov_p146 was a village before)
	for v in _db.all(Provinces.TABLE):
		if str(v.get("seat_kind", "")) != "minor_seat":
			continue
		var seat: Dictionary = _db.get_record("places", str(v.get("seat_place", "")))
		assert_eq(str(seat.get("kind", "")), "minor_seat", "%s is seated at its minor seat" % v.key)
		assert_eq(ProvinceBuildings.payer(_db, v), str(seat.get("sect_id", "")), "%s is paid by its seated sect" % v.key)
