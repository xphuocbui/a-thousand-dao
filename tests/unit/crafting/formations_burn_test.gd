extends DaoTestSuite
## Formations' stone sinks against design/gdd/formations.md: laying a diagram for a fight (rule 9, F2), the protective
## array (rule 15, F5), and every burn booked as burn_formation in Regional Economy Formula H (rule 17).


func _world() -> WorldDB:
	var db := WorldDB.new()
	db.add(WorldEconomy.TABLE, {"id": "k_test", "sect_id": "s1", "regions": []})   # a world with markets: money is booked
	return db


func _diagram(n: int) -> Dictionary:
	var nodes: Array = []
	for i in n:
		nodes.append({"polarity": "+", "rule": {}})
	return {"id": "fx", "grade": 2, "nodes": nodes, "links": []}


func test_laying_burns_the_fuel_only_in_a_foreseen_fight_that_can_pay_ac_fo_08_09() -> void:
	var gd := game_data()
	var db := _world()
	var c := Character.from_dict({"id": "p1", "realm_index": 2, "linh_thach": 1000})
	var rec: Dictionary = c.to_dict()
	rec["is_player"] = true   # the player pays from the purse on the Character
	db.put("people", rec)
	var r: Dictionary = Diagrams.prepare(gd, db, c, _diagram(5), 3, FightRequest.Situation.FORESEEN)
	assert_eq([bool(r.laid), float(r.share), int(r.fuel), c.linh_thach], [true, 1.0, 288, 712], "288 burnt, full strength")
	assert_near(float(MoneyLedger.new(db, c)._books().burned.get("formation", 0.0)), 288.0, 1e-9, "booked as burn_formation")
	var a: Dictionary = Diagrams.prepare(gd, db, c, _diagram(5), 3, FightRequest.Situation.AMBUSH)
	assert_eq([bool(a.laid), float(a.share), int(a.fuel)], [false, 0.7, 0], "an ambush: carried, nothing burnt")
	assert_eq(float(Diagrams.prepare(gd, db, c, _diagram(5), 3, FightRequest.Situation.BLIND).share), 0.5, "blind")
	c.linh_thach = 100
	var short: Dictionary = Diagrams.prepare(gd, db, c, _diagram(5), 3, FightRequest.Situation.FORESEEN)
	assert_eq([bool(short.laid), float(short.share), c.linh_thach], [false, 0.7, 100], "fuel short: carried at 70 %, 0 burnt")
	c.linh_thach = 1000
	var no: Dictionary = Diagrams.prepare(gd, db, c, _diagram(5), 3, FightRequest.Situation.FORESEEN, false)
	assert_eq([bool(no.laid), float(no.share), c.linh_thach], [false, 0.7, 1000], "the player chooses not to lay")


func test_a_protective_array_triggers_once_and_only_when_paid_ac_fo_15() -> void:
	var gd := game_data()
	var p: Dictionary = Formations.protective(gd, 3, 0.0, 2)
	assert_eq([float(p.defense_pct), int(p.burn)], [30.0, 60], "L3, Core Formation: +30 %, 60 stones")
	assert_near(float(Formations.protective(gd, 3, 20.0, 2).defense_pct), 33.0, 1e-9, "33 % at power +20 %")
	var db := _world()
	var c := Character.from_dict({"id": "p1", "realm_index": 2, "linh_thach": 59})
	var f := Formations.new(gd, db)
	assert_false(bool(f.trigger_protective(c, 3, 0.0).fired), "59 stones: it does not trigger")
	assert_eq(c.linh_thach, 59, "and burns nothing")
	c.linh_thach = 100
	var r: Dictionary = f.trigger_protective(c, 3, 0.0)
	assert_eq([bool(r.fired), c.linh_thach], [true, 40], "once: 60 burnt")
	assert_near(float(MoneyLedger.new(db, c)._books().burned.get("formation", 0.0)), 60.0, 1e-9, "booked as burn_formation")


func test_an_npc_lays_from_its_own_purse_ac_fo_12() -> void:
	var gd := game_data()
	var db := _world()
	db.put("people", {"id": "p7", "alive": true, "realm_index": 2})
	var ledger := MoneyLedger.new(db)
	ledger.mint("npc:p7", 300.0, "mine")
	var c := Character.from_dict({"id": "p7", "realm_index": 2})
	var r: Dictionary = Diagrams.prepare(gd, db, c, _diagram(5), 3, FightRequest.Situation.FORESEEN)
	assert_eq([bool(r.laid), int(r.fuel)], [true, 288], "laid from its purse")
	assert_near(MoneyLedger.new(db).balance("npc:p7"), 12.0, 1e-9, "300 - 288")
	var r2: Dictionary = Diagrams.prepare(gd, db, c, _diagram(5), 3, FightRequest.Situation.FORESEEN)
	assert_eq([bool(r2.laid), float(r2.share)], [false, 0.7], "its purse below the fuel: it carries")


func test_diagram_always_lays_and_burns_fuel_in_ambush_and_blind_rule9() -> void:
	var gd := game_data()
	var db := _world()
	var c := Character.from_dict({"id": "p1", "realm_index": 2, "linh_thach": 1000})
	var rec: Dictionary = c.to_dict()
	rec["is_player"] = true
	db.put("people", rec)
	# Direct prepare() checks with diagram_always = true
	var amb: Dictionary = Diagrams.prepare(gd, db, c, _diagram(5), 3, FightRequest.Situation.AMBUSH, true, true, true)
	assert_eq([bool(amb.laid), float(amb.share), int(amb.fuel), c.linh_thach], [true, 1.0, 288, 712], "ambush laid at 100%, 288 burnt")
	assert_near(float(MoneyLedger.new(db, c)._books().burned.get("formation", 0.0)), 288.0, 1e-9, "ambush burn booked as burn_formation")
	var bl: Dictionary = Diagrams.prepare(gd, db, c, _diagram(5), 3, FightRequest.Situation.BLIND, true, true, true)
	assert_eq([bool(bl.laid), float(bl.share), int(bl.fuel), c.linh_thach], [true, 1.0, 288, 424], "blind laid at 100%, 288 burnt")
	assert_near(float(MoneyLedger.new(db, c)._books().burned.get("formation", 0.0)), 576.0, 1e-9, "blind burn booked as burn_formation")
	# Fuel short falls back to carried share (0.7 ambush, 0.5 blind) with 0 burnt
	c.linh_thach = 100
	var short_amb: Dictionary = Diagrams.prepare(gd, db, c, _diagram(5), 3, FightRequest.Situation.AMBUSH, true, true, true)
	assert_eq([bool(short_amb.laid), float(short_amb.share), int(short_amb.fuel), c.linh_thach], [false, 0.7, 0, 100], "short fuel ambush fallback")
	var short_bl: Dictionary = Diagrams.prepare(gd, db, c, _diagram(5), 3, FightRequest.Situation.BLIND, true, true, true)
	assert_eq([bool(short_bl.laid), float(short_bl.share), int(short_bl.fuel), c.linh_thach], [false, 0.5, 0, 100], "short fuel blind fallback")
	# lay = false respects opt-out even with diagram_always = true
	c.linh_thach = 1000
	var opt_out: Dictionary = Diagrams.prepare(gd, db, c, _diagram(5), 3, FightRequest.Situation.BLIND, false, true, true)
	assert_eq([bool(opt_out.laid), float(opt_out.share), int(opt_out.fuel), c.linh_thach], [false, 0.5, 0, 1000], "lay=false stays carried")
	# End-to-end compile of full 3-piece mf-carried-array set -> p.diagram_always == true -> compile_for_info in BLIND
	var lib: Dictionary = gd.file("combat_library")
	var base: Dictionary = (lib.typical[2] as Dictionary).duplicate(true)
	var bfc := BuildFileCompiler.new(gd)
	var loader := FighterProfileLoader.new(CombatConstants.from_game_data(gd))
	var pieces := ["mf-loom-of-letters-seal", "mf-carried-array-flag", "mf-paid-shield"]
	var rec2: Dictionary = bfc.compile({"name": "ca2", "realm": 2, "layers": base.layers, "n_body": base.n_body,
		"n_qi": base.n_qi, "ward": base.ward, "arts": base.arts, "items": pieces.slice(0, 2), "modifiers": [], "purity": {"earth": 50.0}})
	assert_true(bfc.errors.is_empty(), "2-piece compiles: %s" % "; ".join(bfc.errors))
	var p2: FighterProfile = loader.from_sim_build(rec2, "ca2")
	assert_false(p2.diagram_always, "2 pieces do not set diagram_always")
	var rec3: Dictionary = bfc.compile({"name": "ca3", "realm": 2, "layers": base.layers, "n_body": base.n_body,
		"n_qi": base.n_qi, "ward": base.ward, "arts": base.arts, "items": pieces, "modifiers": [], "purity": {"earth": 50.0}})
	assert_true(bfc.errors.is_empty(), "3-piece compiles: %s" % "; ".join(bfc.errors))
	var p3: FighterProfile = loader.from_sim_build(rec3, "ca3")
	assert_true(p3 != null and loader.errors.is_empty(), "3-piece loads: %s" % "; ".join(loader.errors))
	assert_true(p3.diagram_always, "full mf-carried-array sets p.diagram_always")
	c.skills["tran_phap"] = {"level": 4, "xp": 0.0}
	c.diagram = {"record": _diagram(5), "level": 3, "placement": [], "lay": true}
	var due: Array = []
	var info: Dictionary = Diagrams.compile_for_info(gd, db, c, p3, null, FightRequest.Situation.BLIND, 5, due)
	assert_eq([bool(info.laid), float(info.share), int(info.fuel), due.size()], [true, 1.0, 288, 1], "blind fight with mf-carried-array lays at 100% and queues fuel")
	Diagrams.pay_fuel(db, due[0][0], int(due[0][1]))
	assert_eq(c.linh_thach, 712, "deferred blind lay fuel paid once fight runs")
	assert_near(float(MoneyLedger.new(db, c)._books().burned.get("formation", 0.0)), 864.0, 1e-9, "queued blind burn booked as burn_formation")
