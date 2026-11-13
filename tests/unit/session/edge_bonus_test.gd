extends DaoTestSuite
## The protagonist's breakthrough bonus (user decision 2026-11-13; character_edges.json
## player.breakthrough_bonus_by_gate): a life with the edge gets it on pill attempts at its gate, outside the extras
## ceiling; a baseline life does not.


func _session(edge: bool) -> GameSession:
	var gd := game_data()
	var llm := LlmService.new(gd)
	llm.enabled = false
	var s := GameSession.new(gd, llm, TestFixtures.tree())
	s.new_game(4242, {"mode": "roll", "name": "Thử", "gender": "male", "origin": "tan_tu", "edge": edge})
	s.pending_event = {}
	s.player.perks.clear()   # isolate the protagonist line from a rolled destiny perk
	return s


func test_an_edge_life_gets_the_gate_bonus_on_pill_attempts() -> void:
	var gd := game_data()
	var on := _session(true)
	var off := _session(false)
	var bonus: float = float(gd.file("character_edges").player.breakthrough_bonus_by_gate[0])
	assert_near(on.sheet().perk_breakthrough(), bonus, 0.001, "the Thiên mệnh line at the first gate")
	assert_near(off.sheet().perk_breakthrough(), 0.0, 0.001, "none without the edge")
	off.player.thien_phu = on.player.thien_phu.duplicate()
	var with_edge: float = CultivationRules.breakthrough_chance(on.player, gd, on.sheet(), 0).total
	var without: float = CultivationRules.breakthrough_chance(on.player, gd, off.sheet(), 0).total
	assert_near(with_edge - without, bonus / 100.0, 0.0001, "added in full, outside the ceiling")


func test_the_bonus_follows_the_gate() -> void:
	var gd := game_data()
	var on := _session(true)
	var by_gate: Array = gd.file("character_edges").player.breakthrough_bonus_by_gate
	on.player.realm_index = 2
	assert_near(on.sheet().perk_breakthrough(), float(by_gate[2]), 0.001, "Kết Đan's gate value")
