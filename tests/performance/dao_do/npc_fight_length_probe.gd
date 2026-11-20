extends SceneTree
## Observation probe (not a gdUnit test): same-realm NPC fights on the v5 tree, median length and how they end
## (Combat target 30-60 s, fatigue from 60 s). One seeded world, 200 pairs a realm.
##   godot --headless --path . -s res://tests/performance/dao_do/npc_fight_length_probe.gd


func _init() -> void:
	var gd := GameData.load_from("res://assets/data")
	gd.file("combat_rankings")["enabled"] = false
	var tree := DaoDoTree.load_map(gd)
	var rng := RandomNumberGenerator.new()
	rng.seed = 4242
	var db: WorldDB = WorldGenerator.new(gd, tree).generate(rng)
	var builds := BuildGenerator.new(gd, tree, db)
	var k := CombatConstants.from_game_data(gd)
	var by_realm := {}
	for rec in db.all("people"):
		if rec.get("is_beast", false) or not rec.get("alive", true):
			continue
		var r: int = int(rec.get("realm_index", 0))
		if not by_realm.has(r):
			by_realm[r] = []
		if by_realm[r].size() < 60:
			var c := Character.from_dict(rec)
			var p: FighterProfile = FighterCompiler.compile(c, gd, db, builds.sheet_of(c))
			if p != null:
				by_realm[r].append(p)
	var pick := RandomNumberGenerator.new()
	pick.seed = 9
	var realms: Array = by_realm.keys()
	realms.sort()
	for r in realms:
		var ps: Array = by_realm[r]
		if ps.size() < 2:
			continue
		var ts: Array = []
		var ends := {"A": 0, "B": 0, "draw": 0, "time": 0}
		for i in 200:
			var a: FighterProfile = ps[pick.randi_range(0, ps.size() - 1)]
			var b: FighterProfile = ps[pick.randi_range(0, ps.size() - 1)]
			var res: FightResult = Fight.new(a, b, k, 500 + i).run()
			ts.append(res.seconds)
			var w: String = res.win_code()
			ends[w] = int(ends.get(w, 0)) + 1
		ts.sort()
		print("realm %d: %d fighters, fight length median %.1f s (p10 %.1f, p90 %.1f), ends %s" % [r, ps.size(), ts[100], ts[20], ts[180], str(ends)])
	quit()
