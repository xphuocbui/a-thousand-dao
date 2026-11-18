extends DaoTestSuite
## Item Database rule 11 through the session (AC-ID-41): equip fills a fitting base slot first, then
## an extra slot; a fourth extra piece at Qi Refining is refused; a named slot must fit; unowned and
## already-equipped pieces are refused.


func _session() -> GameSession:
	var gd := game_data()
	var llm := LlmService.new(gd)
	llm.enabled = false
	var s := GameSession.new(gd, llm, TestFixtures.tree())
	s.new_game(4242, {"mode": "roll", "name": "Khí", "gender": "male", "origin": "tan_tu"})
	s.pending_event = {}
	s.player.equipped.clear()
	s.player.equip_slots.clear()
	s.player.thien_phu["than_hon"] = 50   # under the first thần thức step: exactly 2 extra slots at Qi Refining
	s.sync_player()
	return s


func _give(s: GameSession, base: String) -> String:
	var r := RandomNumberGenerator.new()
	r.seed = 1
	var art: Dictionary = s.items.artifact(r, 0, 0, "none", base)
	art["owner_id"] = s.player.id
	return s.db.add("items", art)


func test_equip_fills_base_slots_then_extras_then_refuses() -> void:
	var s := _session()
	for base in ["phi_kiem", "giap", "nhan", "nhan", "ngoc_boi"]:
		assert_true(s.equip(_give(s, base)).ok, "base piece %s" % base)
	assert_eq(s.player.equip_slots.values().count(EquipSlots.EXTRA), 0, "all in base slots")
	assert_true(s.equip(_give(s, "nhan")).ok, "a third ring goes extra")
	assert_true(s.equip(_give(s, "chuong")).ok, "a bell goes extra")
	assert_eq(s.player.equip_slots.values().count(EquipSlots.EXTRA), 2, "two extras")
	assert_false(s.equip(_give(s, "ky")).ok, "a third extra is refused at Qi Refining")


func test_a_named_slot_must_fit() -> void:
	var s := _session()
	var ring: String = _give(s, "nhan")
	assert_false(s.equip(ring, "weapon").ok, "a ring is no weapon")
	assert_true(s.equip(ring, "extra").ok, "but may go extra")
	assert_eq(s.player.equip_slots[ring], EquipSlots.EXTRA, "pinned extra")


func test_unowned_and_already_equipped_pieces_are_refused() -> void:
	var s := _session()
	var mine: String = _give(s, "phi_kiem")
	assert_true(s.equip(mine).ok, "first equip")
	assert_false(s.equip(mine).ok, "already equipped")
	var r := RandomNumberGenerator.new()
	var other: String = s.db.add("items", s.items.artifact(r, 0, 0, "none", "phi_kiem"))
	assert_false(s.equip(other).ok, "not owned")


func test_unequip_forgets_the_pinned_slot() -> void:
	var s := _session()
	var w: String = _give(s, "phi_kiem")
	s.equip(w, "weapon")
	s.unequip(w)
	assert_false(s.player.equip_slots.has(w), "slot forgotten")


func test_capability_3_adds_an_extra_slot_and_grows_only_the_chosen_treasure() -> void:
	# Đạo Đồ capability #3 (user decision 2026-11-13): +1 extra slot; one chosen treasure grows yearly; choosing
	# another or unequipping it restarts the growth.
	var s := _session()
	var gd := game_data()
	var before: int = EquipSlots.extra_limit(s.player, gd, s.sheet())
	s.player.capabilities.append(3)
	assert_eq(EquipSlots.extra_limit(s.player, gd, s.sheet()), before + 1, "+1 extra slot")
	var sword: String = _give(s, "phi_kiem")
	var bell: String = _give(s, "chuong")
	s.equip(sword)
	s.equip(bell)
	assert_true(s.nurture(bell).ok, "a chosen treasure")
	var fresh: float = CombatPower.compute(s.player, gd, s.db, s.sheet()).total
	s.player.nurture_years = 10
	var grown: float = CombatPower.compute(s.player, gd, s.db, s.sheet()).total
	assert_true(grown > fresh, "ten years of nurture raise the chosen treasure's power")
	assert_true(s.nurture(sword).ok, "choosing another")
	assert_eq(s.player.nurture_years, 0, "restarts the growth")
	s.player.nurture_years = 10
	s.unequip(sword)
	assert_eq(s.player.nurtured_id, "", "unequipping clears the choice")
	assert_eq(s.player.nurture_years, 0, "and the growth")
	assert_false(s.nurture(bell + "x").ok, "an unequipped item cannot be chosen")
