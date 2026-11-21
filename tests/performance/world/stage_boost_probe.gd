extends SceneTree
## Probe (observation only): the money speed-up of NPC stage gains (WorldTicker: stage chance × (1 + prov) × (1 +
## stone_boost), user decision 2026-11-20). Every 5 years for 30, per realm, the mean multiplier over NPCs below their
## realm's last stage (those it speeds), and the share with any boost. Sizes the base climb's retune (plan decision 11).

func _init() -> void:
	var gd := GameData.load_from("res://assets/data")
	gd.file("combat_rankings")["enabled"] = false
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	var tree := DaoDoTree.load_map(gd)
	var builder := WorldBuilder.new(gd, tree)
	var db: WorldDB = builder.generate(rng, "11")
	var year: int = builder.current_year
	var ticker := WorldTicker.new(gd, db, BuildGenerator.new(gd, tree, db))
	for y in 30:
		for s in 4:
			ticker.tick(rng, year, s)
		year += 1
		if (y + 1) % 5 != 0:
			continue
		var line: Array = []
		var all_m: float = 0.0
		var all_n: int = 0
		for r in gd.realms().size():
			var m: float = 0.0
			var n: int = 0
			var boosted: int = 0
			for p in db.living():
				if int(p.get("realm_index", 0)) != r or bool(p.get("is_beast", false)) or int(p.get("stage", 0)) >= gd.stage_count(r) - 1:
					continue
				var k: float = (1.0 + float(p.get("prov", 0.0))) * (1.0 + float(p.get("stone_boost", 0.0)))
				m += k
				n += 1
				boosted += 1 if k > 1.0 + 1e-9 else 0
			all_m += m
			all_n += n
			line.append("r%d %.3f (n %d, boosted %d %%)" % [r, m / maxf(n, 1), n, 0 if n == 0 else 100 * boosted / n])
		print("year %d: all %.3f; %s" % [year, all_m / maxf(all_n, 1), ", ".join(line)])
	quit()
