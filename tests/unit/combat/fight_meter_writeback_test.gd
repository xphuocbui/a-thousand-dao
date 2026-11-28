extends DaoTestSuite
## Kept fight-meter writeback (Playing Past the Break / Character.save_fight_meters) on real fights only:
## - Event fights / duels (EventResolver.fight_check) write back for both player and living NPC target.
## - Heavenly Tribulation waves carry meters wave-to-wave and write back to player at the end.
## - Quest defeat stages write back via real CombatService (GameSession.quest_start_stage) and stub a_meters.
## - Non-real fights (spar, fight_odds, practice_fight, RatingService panels/pairs) NEVER write back.


func _gd_meter_test(rankings_on: bool = false) -> GameData:
	var base := game_data()
	var files_copy: Dictionary = base.registry.files().duplicate()
	var patched_eff: Dictionary = base.file("combat_effects").duplicate(true)
	patched_eff["effects"]["Playing Past the Break"] = {
		"records": [{
			"id": "eff:Playing Past the Break",
			"on": "fight_start",
			"do": [{"meter": {"id": "playing_past_the_break", "success": [{"gain_qi": {"share": 0.1}}], "failure": []}}],
		}],
	}
	files_copy["combat_effects"] = patched_eff
	var tk_rules: Dictionary = base.file("tribulation_rules").duplicate(true)
	tk_rules["tribulation_enabled"] = true
	files_copy["tribulation_rules"] = tk_rules
	var wg: Dictionary = base.file("world_generation").duplicate(true)
	wg["people"]["world_cultivators"] = 45
	wg["people"]["world_cultivators_min"] = 0
	files_copy["world_generation"] = wg
	var rk: Dictionary = base.file("combat_rankings").duplicate(true)
	rk["enabled"] = rankings_on
	rk["season_fight_budget"] = 120
	rk["worldgen_fight_budget"] = 60
	files_copy["combat_rankings"] = rk
	var gd := GameData.new()
	gd.setup(DataRegistry.from_files(files_copy))
	return gd


func _session(gd: GameData, seed_v: int = 8401) -> GameSession:
	var llm := LlmService.new(gd)
	llm.enabled = false
	var s := GameSession.new(gd, llm, TestFixtures.tree())
	s.ratings_background = false
	s.new_game(seed_v, {
		"mode": "custom", "name": "Huyền Cầm", "gender": "male", "origin": "tan_tu",
		"thien_phu": {"than_hon": 80, "khi_van": 40, "can_cot": 70, "dao_tam": 70, "ngo_tinh": 70, "mi_luc": 50},
		"purities": {"hoa": 80, "kim": 50}, "variants": [], "edge": false,
	})
	s.pending_event = {}
	s.pending_meta = {}
	s.pending_mercy = {}
	return s


func _attach_break_meter(c: Character, start_val: float) -> void:
	c.thien_phu["than_hon"] = 80
	c.thien_phu["khi_van"] = 40
	if not c.linh_can.elements.has("hoa"):
		c.linh_can.elements["hoa"] = 60.0
	var manual := {
		"tech_id": "shao-remnant-score", "name": "Shao", "tier": 2, "tech_kind": "secret",
		"names": ["hoa"], "layers": 12, "bonuses": [], "passives": [], "abilities": [],
		"effects": [{"name": "Playing Past the Break", "unlock_layer": 1}],
		"seal_clusters": [], "origin": "authored",
	}
	CongPhap.learn(c, manual)
	c.aux_tech[0] = "shao-remnant-score"
	c.fight_meters["playing_past_the_break"] = start_val


func _pick_npc(s: GameSession) -> Dictionary:
	for p in s.db.living():
		if bool(p.get("is_player", false)) or bool(p.get("is_beast", false)):
			continue
		p["location_id"] = s.player.location_id
		p["attitude"] = 30
		p["met_player"] = true
		return p
	return {}


func test_event_fight_check_writes_back_player_and_npc_meters_and_persists_across_reload() -> void:
	var gd := _gd_meter_test(false)
	var s := _session(gd, 8401)
	_attach_break_meter(s.player, 0.0)   # p = (80 + 40) / 400 = 0.3
	s.sync_player()

	var npc_rec: Dictionary = _pick_npc(s)
	assert_false(npc_rec.is_empty(), "living NPC found")
	var enemy := Character.from_dict(npc_rec)
	enemy.perks = []
	enemy.equipped = []
	enemy.tree_nodes = []
	enemy.tie_rows = []
	_attach_break_meter(enemy, 0.7)      # 0.7 + 0.3 = 1.0 -> triggers & wraps to 0.0
	s.db.put("people", enemy.to_dict())

	# Fight 1: player 0.0 -> 0.3; enemy 0.7 -> 0.0 (wrapped).
	var r1: Dictionary = s.resolver.fight_check(s.player, s.sheet(), enemy, s.rng)
	assert_true(bool(r1.ran), "event fight 1 ran")
	assert_true(r1.has("ending"), "fight_check exposes ending enum")
	assert_near(float(s.player.fight_meters.get("playing_past_the_break", -1.0)), 0.3, 1e-6, "fight 1 advances player meter to 0.3")
	var erec1: Dictionary = s.db.get_record("people", enemy.id)
	assert_near(float(Dictionary(erec1.get("fight_meters", {})).get("playing_past_the_break", -1.0)), 0.0, 1e-6, "fight 1 writes wrapped NPC meter 0.0 to WorldDB")

	# Save/reload preserves player.fight_meters.
	s.sync_player()
	var saved_json: String = JSON.stringify(s.to_dict())
	var s2 := _session(gd, 8402)
	assert_true(bool(s2.load_dict(JSON.parse_string(saved_json)).ok), "reload ok")
	assert_near(float(s2.player.fight_meters.get("playing_past_the_break", -1.0)), 0.3, 1e-6, "player meter 0.3 survives save/reload")

	# Fights 2, 3, 4 on reloaded session: 0.3 -> 0.6 -> 0.9 -> 0.2 (crosses 1.0 and wraps).
	var foe2 := Character.from_dict(s2.db.get_record("people", enemy.id))
	assert_true(bool(s2.resolver.fight_check(s2.player, s2.sheet(), foe2, s2.rng).ran))
	assert_near(float(s2.player.fight_meters.get("playing_past_the_break", -1.0)), 0.6, 1e-6, "fight 2 -> 0.6")
	assert_true(bool(s2.resolver.fight_check(s2.player, s2.sheet(), foe2, s2.rng).ran))
	assert_near(float(s2.player.fight_meters.get("playing_past_the_break", -1.0)), 0.9, 1e-6, "fight 3 -> 0.9")
	assert_true(bool(s2.resolver.fight_check(s2.player, s2.sheet(), foe2, s2.rng).ran))
	assert_near(float(s2.player.fight_meters.get("playing_past_the_break", -1.0)), 0.2, 1e-6, "fight 4 crosses 1.0 and wraps to 0.2")
	s.shutdown()
	s2.shutdown()


func test_tribulation_multi_wave_carries_meters_between_waves_and_persists_to_player() -> void:
	var gd := _gd_meter_test(false)
	gd.breakthrough_rules()["chance_min"] = 1.0
	var s := _session(gd, 8403)
	_attach_break_meter(s.player, 0.5)   # start 0.5, p = 0.3
	s.player.realm_index = 3
	s.player.level = Ladder.band(gd, 3)[1]
	s.player.level_peak = s.player.level
	s.player.stage = Ladder.stage_of_level(gd, s.player.level)
	s.player.tu_vi = Ladder.bar_cost(gd, 3)
	s.player.has_insight = true
	s.player.tam_ma = 0.0
	s.player.vitality = 1.0
	s.player.age = 500.0
	s.alchemy.add_pills(s.player, str(gd.realm(4).entry_requirement.item_tag), 3, 2)
	s.sync_player()

	# Record the starting meter fed into each wave and advance via real Fight + EffectRunner on fight_start.
	var wave_starts: Array = []
	var k_const := CombatConstants.from_game_data(gd)
	s.tribulation_fight_fn = func(req: FightRequest, _wctx: Dictionary) -> FightResult:
		var m_in: Dictionary = req.a.meters.get("playing_past_the_break", {})
		wave_starts.append(float(m_in.get("start", -1.0)))
		var f := Fight.new(req.a, req.b, k_const, req.fight_seed, Fight.Order.FIXED)
		EffectRunner.fire(f, f.a, "fight_start", {})
		var res := FightResult.new()
		res.winner = FightResult.Winner.A
		res.ending = FightResult.Ending.KNOCKOUT
		res.seconds = 10.0
		res.a_end = FighterEnd.of(f.a)
		res.a_end.health = 4000.0
		res.a_end.health_max = 6400.0
		res.a_end.linh_luc = 2000.0
		res.a_end.linh_luc_base = 4000.0
		res.b_end = FighterEnd.of(f.b)
		res.b_end.health = 0.0
		res.b_end.down = true
		return res

	var bt: Dictionary = s.breakthrough()
	assert_true(bool(bt.ok), "tribulation breakthrough ok")
	assert_eq(wave_starts.size(), 3, "all 3 tribulation waves ran")
	assert_near(float(wave_starts[0]), 0.5, 1e-6, "wave 1 started at 0.5")
	assert_near(float(wave_starts[1]), 0.8, 1e-6, "wave 2 received carried meter 0.8 from wave 1")
	assert_near(float(wave_starts[2]), 0.1, 1e-6, "wave 3 received wrapped meter 0.1 from wave 2")
	assert_near(float(s.player.fight_meters.get("playing_past_the_break", -1.0)), 0.4, 1e-6, "player.fight_meters persisted 0.4 after wave 3")
	var waves: Array = Array(s.last_tribulation.get("waves", []))
	assert_near(float(Dictionary(waves[0].get("a_meters", {})).get("playing_past_the_break", -1.0)), 0.8, 1e-6, "wave 1 a_meters == 0.8")
	assert_near(float(Dictionary(waves[1].get("a_meters", {})).get("playing_past_the_break", -1.0)), 0.1, 1e-6, "wave 2 a_meters == 0.1")
	assert_near(float(Dictionary(waves[2].get("a_meters", {})).get("playing_past_the_break", -1.0)), 0.4, 1e-6, "wave 3 a_meters == 0.4")
	s.shutdown()


func test_quest_defeat_stub_a_meters_writes_back_to_player() -> void:
	var gd := _gd_meter_test(false)
	var s := _session(gd, 8404)
	_attach_break_meter(s.player, 0.2)
	var npc: Dictionary = _pick_npc(s)
	var stages: Array = [{"kind": "defeat", "place_id": s.player.location_id, "target_id": str(npc.id), "description": "Đấu thử"}]
	var q := {
		"id": "q_stub_meter", "template_id": "tpl_stub_meter", "name": "Đấu thử",
		"tier": "ordinary", "offer_kind": "person", "state": "active",
		"player_id": s.player.id, "offerer_id": str(npc.id), "offerer_root_id": str(npc.id),
		"place_id": s.player.location_id, "realm_index": s.player.realm_index,
		"travel_seasons": 0, "stage": 1, "stages": stages,
		"budget": {"B": 20, "stage_pays": [20]}, "deadline": 20, "outcomes": [],
		"defeat_opened": {"0": true},
	}
	s.quests.put_quest(q)
	var res: Dictionary = s.quests.run_defeat_stage(
		s.player, s.sheet(), s.rng, "q_stub_meter",
		func(_quest, _st, _pl): return {"result": "knockout", "a_meters": {"playing_past_the_break": 0.65}},
		{"year": s.year, "season": s.season, "season_idx": s.season_index(), "force_open": true}
	)
	assert_true(bool(res.ok), "stub defeat stage succeeded")
	assert_near(float(s.player.fight_meters.get("playing_past_the_break", -1.0)), 0.65, 1e-6, "stub a_meters wrote back 0.65 onto player")
	s.shutdown()


func test_non_real_fights_never_write_back_fight_meters() -> void:
	var gd := _gd_meter_test(true)
	var s := _session(gd, 8405)
	_attach_break_meter(s.player, 0.45)
	s.sync_player()
	var npc: Dictionary = _pick_npc(s)
	assert_false(npc.is_empty(), "living NPC found")
	var npc_id: String = str(npc.id)
	var foe := Character.from_dict(npc)

	# 1. EventResolver.fight_odds (24-sample preview)
	var odds: Dictionary = s.resolver.fight_odds(s.player, s.sheet(), foe)
	assert_true(bool(odds.ran), "fight_odds ran")
	assert_near(float(s.player.fight_meters.get("playing_past_the_break", -1.0)), 0.45, 1e-9, "fight_odds leaves player fight_meters unchanged")

	# 2. GameQuery.practice_fight (fight-screen playback)
	var pf: Dictionary = GameQuery.practice_fight(s, npc_id)
	assert_true(bool(pf.get("ok", false)), "practice_fight ran")
	assert_near(float(s.player.fight_meters.get("playing_past_the_break", -1.0)), 0.45, 1e-9, "practice_fight leaves player fight_meters unchanged")

	# 3. InteractionService spar (non-lethal spar)
	var sp: Dictionary = s.interact(npc_id, "spar")
	assert_true(bool(sp.get("ok", false)), "spar ran: %s" % str(sp))
	assert_near(float(s.player.fight_meters.get("playing_past_the_break", -1.0)), 0.45, 1e-9, "spar leaves player fight_meters unchanged")

	# 4. RatingService panel / background rating fights
	var prec: Dictionary = s.db.get_record("people", s.player.id)
	var panel_res: Dictionary = s.ratings.run_panel(s.player, s.sheet(), s.seed_value, s.season_index(), true)
	assert_true(bool(panel_res.get("ok", false)), "RatingService panel ran")
	assert_near(float(s.player.fight_meters.get("playing_past_the_break", -1.0)), 0.45, 1e-9, "RatingService panel leaves player fight_meters unchanged")
	assert_near(float(Dictionary(prec.get("fight_meters", {})).get("playing_past_the_break", -1.0)), 0.45, 1e-9, "RatingService panel leaves WorldDB fight_meters unchanged")
	s.shutdown()


func test_carried_array_ambush_lays_diagram_burns_fuel_and_persists_fight_meters() -> void:
	# Cross-lane Track 2 integration: mf-carried-array (diagram_always) + MoneyLedger formation fuel burn
	# + kept fight_meters writeback on the same real EventResolver.fight_check(..., AMBUSH).
	var gd := _gd_meter_test(false)
	var s := _session(gd, 8406)
	s.player.realm_index = 2
	s.player.level = Ladder.stage_first_level(gd, 2, 0)
	s.player.level_peak = s.player.level
	s.player.stage = 0
	s.player.linh_thach = 1000
	s.player.skills["tran_phap"] = {"level": 4, "xp": 0.0}
	_attach_break_meter(s.player, 0.25)   # p = (80 + 40) / 400 = 0.3 -> 0.25 + 0.30 = 0.55

	# Equip full 3-piece mf-carried-array set (sets diagram_always = true).
	for nid in ["mf-loom-of-letters-seal", "mf-carried-array-flag", "mf-paid-shield"]:
		var item: Dictionary = s.items.named_artifact(nid, 2)
		assert_false(item.is_empty(), "named artifact created: %s" % nid)
		item["owner_id"] = s.player.id
		var iid: String = s.db.add("items", item)
		s.player.equipped.append(iid)

	# Set a 5-node grade-2 diagram at level 3 (F2 lay fuel at Core Formation = 288 linh thạch).
	var nodes: Array = []
	for i in 5:
		nodes.append({"polarity": "+", "rule": {}})
	var diag := {"id": "fx_carried_ambush", "grade": 2, "nodes": nodes, "links": []}
	s.player.diagram = {"record": diag, "level": 3, "placement": [], "lay": true}
	s.sync_player()

	var npc_rec: Dictionary = _pick_npc(s)
	assert_false(npc_rec.is_empty(), "living NPC found")
	var enemy := Character.from_dict(npc_rec)
	enemy.perks = []
	enemy.equipped = []
	enemy.tree_nodes = []
	enemy.tie_rows = []
	s.db.put("people", enemy.to_dict())

	var expected_fuel: int = Diagrams.fuel(gd, 5, 2, 3, 2)
	assert_eq(expected_fuel, 288, "F2 lay fuel for 5-node grade-2 L3 diagram at realm 2 is 288")
	var burn_before: float = float(MoneyLedger.new(s.db, s.player)._books().burned.get("formation", 0.0))
	var lt_before: int = s.player.linh_thach

	var res: Dictionary = s.resolver.fight_check(s.player, s.sheet(), enemy, s.rng, FightRequest.Situation.AMBUSH)
	assert_true(bool(res.ran), "AMBUSH event fight ran: %s" % str(res))
	assert_eq(int(s.resolver.last_fight_request.get("situation_a", -1)), FightRequest.Situation.AMBUSH, "fight resolved under AMBUSH")
	var diag_joined: String = "\n".join(s.resolver.last_diagram_lines)
	assert_true(diag_joined.contains("share 100%"), "mf-carried-array laid diagram at 100%% share in AMBUSH (%s)" % diag_joined)
	assert_true(diag_joined.contains("laid: %d linh thạch burnt" % expected_fuel), "diagram breakdown records laid fuel burn")
	assert_eq(s.player.linh_thach, lt_before - expected_fuel, "player purse decreased by lay fuel (%d)" % expected_fuel)
	var burn_after: float = float(MoneyLedger.new(s.db, s.player)._books().burned.get("formation", 0.0))
	assert_near(burn_after - burn_before, float(expected_fuel), 1e-6, "MoneyLedger recorded formation lay fuel burn")
	assert_near(float(s.player.fight_meters.get("playing_past_the_break", -1.0)), 0.55, 1e-6, "real AMBUSH fight persisted fight_meters (0.25 -> 0.55)")
	s.shutdown()
