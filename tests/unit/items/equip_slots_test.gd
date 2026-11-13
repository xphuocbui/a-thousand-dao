extends DaoTestSuite
## Item Database rule 11 (user decision 2026-11-13): every slot is free. Base slots: 1 weapon, 1 armour, 2 rings,
## 1 necklace. Extra slots: 2 / 3 / 4 / 5 / 6 by realm, plus one per 1.75 × the realm's reference thần thức (no cap),
## plus `artifact_slots` (AC-ID-41, AC-ID-43). Fixture characters have thần hồn 50, under the first step (78.75 at Qi
## Refining), unless a test raises it.


## A piece of [param base], with optional extra fields.
func _piece(db: WorldDB, base: String, extra: Dictionary = {}) -> String:
	var rec := {
		"kind": "artifact", "name": "Thử %s" % base, "base": base, "element": "", "attack": 10.0, "defense": 10.0,
		"affixes": [], "owner_id": "", "value": 1,
	}
	rec.merge(extra, true)
	return db.add("items", rec)


func _sense(pct: float) -> Dictionary:
	return {"modifiers": [{"key": "than_thuc_pct", "value": pct, "scope": []}]}


func _control(c: Character, db: WorldDB) -> Dictionary:
	var gd := game_data()
	return CombatPower.controlled(c, gd, db, StatSheet.build(c, gd, db, null))


func _base_set(db: WorldDB) -> Array:
	return [_piece(db, "phi_kiem"), _piece(db, "giap"), _piece(db, "nhan"), _piece(db, "nhan"), _piece(db, "ngoc_boi")]


func test_a_full_base_set_counts_at_qi_refining() -> void:
	var db := WorldDB.new()
	var c := TestFixtures.character({"hoa": 50})
	c.equipped = _base_set(db)
	var ctl: Dictionary = _control(c, db)
	assert_eq(ctl.used.size(), 5, "all five base pieces count")
	assert_eq(ctl.overflow, [], "nothing past the count")
	assert_eq(ctl.extra_used, 0, "no extra slot used")


func test_two_extra_slots_at_qi_refining_and_the_third_extra_piece_adds_nothing() -> void:
	var db := WorldDB.new()
	var c := TestFixtures.character({"hoa": 50})
	var treasure: String = _piece(db, "chuong")
	var third_ring: String = _piece(db, "nhan")
	var flag: String = _piece(db, "ky")
	c.equipped = _base_set(db) + [treasure, third_ring, flag]
	var ctl: Dictionary = _control(c, db)
	assert_true(ctl.used.has(treasure) and ctl.used.has(third_ring), "two extras count")
	assert_eq(ctl.overflow, [flag], "the third extra piece is past the count")
	assert_eq(ctl.slot_of[third_ring], EquipSlots.EXTRA, "a third ring sits in an extra slot")


func test_extra_slots_grow_by_realm() -> void:
	var gd := game_data()
	var expected: Array = [2, 3, 4, 5, 6]
	for realm in expected.size():
		var c := TestFixtures.character({"hoa": 50}, 50, realm)
		assert_eq(EquipSlots.extra_limit(c, gd, StatSheet.build(c, gd, null, null)), expected[realm], "realm %d" % realm)


func test_the_reference_than_thuc_matches_ds_ref() -> void:
	var gd := game_data()
	var refs: Array = [45.0, 135.0, 450.0, 1350.0, 4500.0]
	for realm in refs.size():
		var c := TestFixtures.character({"hoa": 50}, 50, realm)
		assert_near(EquipSlots.sense_ref(c, gd), refs[realm], 0.001, "ds_ref realm %d" % realm)


func test_than_thuc_opens_an_extra_slot_at_each_step() -> void:
	var gd := game_data()
	var c := TestFixtures.character({"hoa": 50})
	c.thien_phu["than_hon"] = 78
	assert_eq(EquipSlots.extra_limit(c, gd, StatSheet.build(c, gd, null, null)), 2, "78 is under 78.75")
	c.thien_phu["than_hon"] = 79
	assert_eq(EquipSlots.extra_limit(c, gd, StatSheet.build(c, gd, null, null)), 3, "79 reaches the first step")


func test_than_thuc_slots_have_no_cap() -> void:
	# A ring in a base slot granting +500 % thần thức: 50 x 6 = 300 = 3.8 steps of 78.75 -> +3.
	var db := WorldDB.new()
	var c := TestFixtures.character({"hoa": 50})
	var ring: String = _piece(db, "nhan", _sense(500.0))
	c.equipped = [ring]
	assert_eq(_control(c, db).limit, 2 + 3, "no cap on the thần thức term")


func test_a_than_thuc_grant_on_an_extra_piece_opens_no_slot() -> void:
	# AC-ID-43: the same grant on a base piece counts toward the slots; on an extra piece it does not.
	var db := WorldDB.new()
	var c := TestFixtures.character({"hoa": 50})
	var flag: String = _piece(db, "ky", _sense(500.0))
	c.equipped = [flag]
	assert_eq(_control(c, db).limit, 2, "an extra piece cannot open slots")
	var gd := game_data()
	assert_true(CharacterRules.than_thuc(c, gd, StatSheet.build(c, gd, db, null)).total > 200.0, "but its thần thức still counts on the sheet")


func test_the_one_treasure_keystone_keeps_the_base_set_and_one_extra_at_x2_5() -> void:
	# Rule 11 (user decision 2026-11-13): base slots as usual; only the first extra piece counts, at the keystone mult.
	var gd := game_data()
	var db := WorldDB.new()
	var c := TestFixtures.character({"hoa": 50})
	var base_set: Array = _base_set(db)
	var bell: String = _piece(db, "chuong")
	var flag: String = _piece(db, "ky")
	c.equipped = base_set + [bell, flag]
	var plain: Dictionary = CombatPower.compute(c, gd, db, StatSheet.build(c, gd, db, null))
	var sheet := StatSheet.build(c, gd, db, null)
	sheet.add_mod("Nhất Kiếm Phá Vạn Pháp", "single_artifact", 1.0)
	var ctl: Dictionary = CombatPower.controlled(c, gd, db, sheet)
	assert_eq(ctl.used, base_set + [bell], "the base set and the first extra piece count")
	assert_eq(ctl.overflow, [flag], "a second extra piece adds nothing")
	var kept: Dictionary = CombatPower.compute(c, gd, db, sheet)
	# Every test piece has attack 10: the bell rises to 25, the flag's 10 drops out, the base pieces stay at 10 each.
	assert_near(float(kept.offense) - float(plain.offense), 25.0 - 10.0 - 10.0, 0.01, "only the bell is multiplied")
	assert_eq(kept.extra_used, 1, "one extra slot counts")


func test_a_pinned_slot_wins_over_an_earlier_unpinned_piece() -> void:
	var db := WorldDB.new()
	var c := TestFixtures.character({"hoa": 50})
	var first: String = _piece(db, "phi_kiem")
	var second: String = _piece(db, "an")
	c.equipped = [first, second]
	c.equip_slots = {second: "weapon"}
	var ctl: Dictionary = _control(c, db)
	assert_eq(ctl.slot_of[second], "weapon", "the pinned piece keeps the weapon slot")
	assert_eq(ctl.slot_of[first], EquipSlots.EXTRA, "the other weapon goes extra")


func test_artifact_slots_on_a_base_piece_opens_an_extra_slot_and_losing_it_unslots_the_last() -> void:
	# AC-ID-43: three extra pieces at Qi Refining with their +1 slot source removed: all stay equipped, the third
	# adds nothing.
	var db := WorldDB.new()
	var c := TestFixtures.character({"hoa": 50})
	var slot_ring: String = _piece(db, "nhan", {"modifiers": [{"key": "artifact_slots", "value": 1, "scope": []}]})
	var extras: Array = [_piece(db, "ky"), _piece(db, "ky"), _piece(db, "ky")]
	c.equipped = [slot_ring] + extras
	assert_eq(_control(c, db).overflow, [], "the ring opens a third extra slot")
	c.equipped = extras.duplicate()
	var ctl: Dictionary = _control(c, db)
	assert_eq(c.equipped.size(), 3, "nothing is unequipped")
	assert_eq(ctl.overflow, [extras[2]], "the third extra adds nothing")


func test_an_extra_piece_never_opens_its_own_slot() -> void:
	var db := WorldDB.new()
	var c := TestFixtures.character({"hoa": 50})
	var opener: Dictionary = {"modifiers": [{"key": "artifact_slots", "value": 1, "scope": []}]}
	var extras: Array = [_piece(db, "ky"), _piece(db, "ky"), _piece(db, "ky", opener)]
	c.equipped = extras
	assert_eq(_control(c, db).overflow, [extras[2]], "a piece past the count cannot slot itself")


func test_a_ring_never_fits_the_weapon_slot() -> void:
	var gd := game_data()
	var db := WorldDB.new()
	var c := TestFixtures.character({"hoa": 50})
	var ring: Dictionary = db.get_record("items", _piece(db, "nhan"))
	var sheet := StatSheet.build(c, gd, db, null)
	assert_false(EquipSlots.fits(gd, ring, "weapon"), "ring role is not weapon")
	assert_eq(EquipSlots.slot_for(c, gd, db, sheet, ring, "weapon"), "", "asking for the weapon slot is refused")
	assert_eq(EquipSlots.slot_for(c, gd, db, sheet, ring), "ring", "unasked, it takes a ring slot")


func test_a_role_less_piece_only_fits_an_extra_slot() -> void:
	var gd := game_data()
	var db := WorldDB.new()
	var bare: Dictionary = db.get_record("items", _piece(db, ""))
	for slot in EquipSlots.base_slot_names(gd):
		assert_false(EquipSlots.fits(gd, bare, slot), slot)
	assert_true(EquipSlots.fits(gd, bare, EquipSlots.EXTRA), "extra")
