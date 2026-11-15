extends Node
## Single-threaded real NPC fight rate (Power Rankings Open Question 9, 2026-11-15): generates a world (ratings off),
## compiles 300 NPCs on the main thread and runs 300 seeded same-realm fights in this one thread. Run several copies
## at once to measure how fights scale across processes rather than threads:
##   build/bench/combat_bench.console.exe --headless -- --fight-rate
## Prints "FIGHT_RATE <n> fights, <total> ms total, <per> ms a fight".

func _ready() -> void:
	var gd := GameData.load_from("res://assets/data")
	gd.file("combat_rankings")["enabled"] = false   # no background season batch sharing the CPU
	var llm := LlmService.new(gd)
	llm.enabled = false
	var s := GameSession.new(gd, llm, MeridianTree.generate(gd))
	s.new_game(4242, {"mode": "roll", "name": "P", "gender": "male", "origin": "tan_tu"})
	s.shutdown()
	var k := CombatConstants.from_game_data(gd)
	var by_realm := {}
	var profs: Array = []
	for rec in s.db.all("people"):
		if profs.size() >= 300:
			break
		if not bool(rec.get("alive", true)):
			continue
		var c := Character.from_dict(rec)
		var p: FighterProfile = FighterCompiler.compile(c, gd, s.db, s.builds.sheet_of(c))
		if p == null:
			continue
		if not by_realm.has(p.realm):
			by_realm[p.realm] = []
		by_realm[p.realm].append(profs.size())
		profs.append(p)
	var pick := RandomNumberGenerator.new()
	pick.seed = 77
	var realms: Array = by_realm.keys().filter(func(r): return by_realm[r].size() >= 2)
	var n := 300
	var t0 := Time.get_ticks_usec()
	for i in n:
		var pool: Array = by_realm[realms[pick.randi_range(0, realms.size() - 1)]]
		var a: FighterProfile = profs[pool[pick.randi_range(0, pool.size() - 1)]]
		var b: FighterProfile = profs[pool[pick.randi_range(0, pool.size() - 1)]]
		Fight.new(a, b, k, 1000 + i, Fight.Order.COIN, false).run()
	var total: float = (Time.get_ticks_usec() - t0) / 1000.0
	print("FIGHT_RATE %d fights, %.1f ms total, %.2f ms a fight" % [n, total, total / n])
	get_tree().quit(0)
