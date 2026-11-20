extends SceneTree
## Observation probe (not a gdUnit test; Power Rankings calibration, active.md open item 1): after the v5 tree, the
## median NPC win share against the typical reference fighter of its realm, per realm. One seeded world (ratings
## off), up to 40 NPCs a realm, 10 fights each.
##   godot --headless --path . -s res://tests/performance/dao_do/npc_strength_probe.gd


func _init() -> void:
	var gd := GameData.load_from("res://assets/data")
	gd.file("combat_rankings")["enabled"] = false
	var tree := DaoDoTree.load_map(gd)
	var rng := RandomNumberGenerator.new()
	rng.seed = 4242
	var gen := WorldGenerator.new(gd, tree)
	var db: WorldDB = gen.generate(rng)
	var builds := BuildGenerator.new(gd, tree, db)
	var k := CombatConstants.from_game_data(gd)
	var by_realm := {}
	for rec in db.all("people"):
		if rec.get("is_beast", false) or not rec.get("alive", true):
			continue
		var r: int = int(rec.get("realm_index", 0))
		if not by_realm.has(r):
			by_realm[r] = []
		if by_realm[r].size() < 40:
			by_realm[r].append(rec)
	var realms: Array = by_realm.keys()
	realms.sort()
	for r in realms:
		var errors: Array = []
		var foe: FighterProfile = FighterCompiler.from_data("typical", mini(r, 4), gd, errors)
		var shares: Array = []
		var keystones := 0
		for rec in by_realm[r]:
			var c := Character.from_dict(rec)
			var me: FighterProfile = FighterCompiler.compile(c, gd, db, builds.sheet_of(c), [], errors)
			if me == null:
				continue
			keystones += tree.held_effects(c).size()
			var w := 0
			for s in 10:
				if Fight.new(me, foe, k, 7000 + s).run().win_code() == "A":
					w += 1
			shares.append(float(w) / 10.0)
		shares.sort()
		var med: float = shares[shares.size() / 2] if not shares.is_empty() else -1.0
		print("realm %d: %d NPCs, median win share vs typical %.2f (p25 %.2f, p75 %.2f), tree Effects held per NPC %.1f" % [
			r, shares.size(), med, shares[shares.size() / 4] if not shares.is_empty() else -1.0,
			shares[shares.size() * 3 / 4] if not shares.is_empty() else -1.0, float(keystones) / maxf(1.0, float(shares.size()))])
	quit()
