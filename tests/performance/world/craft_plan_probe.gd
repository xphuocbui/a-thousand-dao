extends SceneTree
## Probe (observation only): one crafted class per market, season by season: plan, plan_ref, the plan update's star,
## price, input cost ratio, cover, fill, output and demand. Why talisman plans stay flat while demand doubles.

const CID := "pill5"


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
	var cfg: Dictionary = gd.file("economy")
	for y in 2:
		for s in 4:
			ticker.tick(rng, year, s)
			for m in db.find(WorldEconomy.TABLE, func(x): return str(x.id).begins_with("mk:")):
				var c: Dictionary = m.crafted.get(CID, {})
				if c.is_empty():
					continue
				print("  %s %s plan %.1f out %.1f fill_now %.2f fill %.2f s %.1f d %.1f stock %.1f p %.2f" % [m.id, CID, float(c.plan), float(c.get("out", 0)), float(c.get("fill_now", -1)), float(c.get("fill", -1)), float(c.s), float(c.d), float(c.stock), float(c.p)])
			continue
			var m: Dictionary = {}
			var c: Dictionary = {}
			var star: Dictionary = CraftEconomy.plan_next(cfg, float(c.plan), float(c.plan_ref), 1.0, float(c.cover), 1.0, str(c.kind))
			print("%d.%d %s plan %.1f ref %.1f p %.2f cover %.2f fill %.2f fill_now %.2f out %.1f s %.1f d %.1f stock %.1f star(r=1) %.1f" % [year, s, m.id, float(c.plan), float(c.plan_ref), float(c.p), float(c.cover), float(c.get("fill", 0)), float(c.get("fill_now", -1)), float(c.get("out", 0)), float(c.s), float(c.d), float(c.stock), float(star.star)])
		year += 1
	quit()
