extends DaoTestSuite
## Phù lục: drawing talismans, and talismans used automatically on the check they help
## (design/quick-specs/phu-luc-linh-thu-thanh-tuu.md).


func _session() -> GameSession:
	var gd := game_data()
	var llm := LlmService.new(gd)
	llm.enabled = false
	var s := GameSession.new(gd, llm, TestFixtures.tree())
	s.new_game(4242, {"mode": "roll", "name": "Phù", "gender": "male", "origin": "tan_tu"})
	s.pending_event = {}
	return s


func _give(s: GameSession, item: Dictionary) -> String:
	item["owner_id"] = s.player.id
	return s.db.add("items", item)


func _count(s: GameSession, template: String) -> int:
	var n: int = 0
	for it in s.db.items_of(s.player.id):
		if it.kind == "talisman" and it.template == template:
			n += int(it.qty)
	return n


func _event(s: GameSession, check: Dictionary) -> Dictionary:
	return {"title": "Thử", "text": "", "npc_id": str(check.get("enemy", "")), "place_id": s.player.location_id, "choices": [
		{"label": "A", "check": check, "always": [], "success": {"text": "", "effects": []}, "failure": {"text": "", "effects": []}},
		{"label": "B", "check": {"type": "none"}, "always": [], "success": {"text": "", "effects": []}, "failure": {"text": "", "effects": []}},
	]}


func test_drawing_spends_ink_and_materials_and_passes_a_season() -> void:
	var s := _session()
	var d: Dictionary = s.talismans.def("hoa_cau")
	_give(s, s.items.material("tinh_thiet", 5))
	s.player.linh_thach = 500
	var season_before: int = s.season_index()
	var r: Dictionary = s.draw_talisman("hoa_cau")
	assert_true(r.ok, "drew: %s" % str(r.lines))
	assert_eq(s.player.linh_thach, 500 - int(d.ink_lt), "ink paid")
	assert_eq(s.season_index(), season_before + 1, "one season")
	assert_true(_count(s, "hoa_cau") >= int(d.yield) or str(r.lines).contains("Failed"), "talismans on success")


func test_combat_uses_attack_and_defense_talismans_and_the_card_shows_them() -> void:
	var s := _session()
	var enemy_id: String = s.builds.create_person(s.rng, {"realm_index": 0, "archetype": "kiem_tu", "location_id": s.player.location_id})
	var ev: Dictionary = _event(s, {"type": "combat", "enemy": enemy_id})
	s.pending_event = ev
	var plain: float = Advisor.choice_odds(s, 0).chance
	_give(s, s.items.talisman("hoa_cau", 2))
	_give(s, s.items.talisman("kim_cuong", 1))
	var with_t: Dictionary = Advisor.choice_odds(s, 0)
	assert_true(float(with_t.chance) > plain or float(with_t.chance) >= 0.94, "odds rise: %.2f -> %.2f" % [plain, float(with_t.chance)])
	assert_true(str(with_t.text).contains("Phù"), "card names the talisman: %s" % with_t.text)
	assert_eq(_count(s, "hoa_cau"), 2, "showing odds consumes nothing")
	s.pending_meta = {"source": "template"}
	s.choose(0)
	assert_eq(_count(s, "hoa_cau"), 1, "one attack talisman used")
	assert_eq(_count(s, "kim_cuong"), 0, "the defense talisman used")


func test_evade_checks_use_than_hanh_and_other_checks_do_not() -> void:
	var s := _session()
	_give(s, s.items.talisman("than_hanh", 2))
	s.pending_event = _event(s, {"type": "stat", "stat": "ngo_tinh", "difficulty": 50.0})
	s.pending_meta = {"source": "template"}
	s.choose(0)
	assert_eq(_count(s, "than_hanh"), 2, "not used on a plain check")
	s.pending_event = _event(s, {"type": "stat", "stat": "than_hon", "difficulty": 50.0, "evade": true})
	s.pending_meta = {"source": "template"}
	s.choose(0)
	assert_eq(_count(s, "than_hanh"), 1, "used when fleeing")
