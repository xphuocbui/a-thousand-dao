extends SceneTree
## Probe (observation only): why crafted prices sit near 2. Each year for 12 years, per crafted class summed over the
## markets: demand d, supply s, stock, the plan, its output and the input fill (fill_now), and the mean price.

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
	for y in 4:
		for s in 4:
			ticker.tick(rng, year, s)
		year += 1
		var by := {}
		for m in db.find(WorldEconomy.TABLE, func(x): return str(x.id).begins_with("mk:")):
			for cid in m.get("crafted", {}):
				var c: Dictionary = m.crafted[cid]
				if not by.has(cid):
					by[cid] = {"d": 0.0, "s": 0.0, "stock": 0.0, "plan": 0.0, "out": 0.0, "fill": 0.0, "p": 0.0, "n": 0}
				var b: Dictionary = by[cid]
				b.d += float(c.get("d", 0)); b.s += float(c.get("s", 0)); b.stock += float(c.get("stock", 0))
				b.plan += float(c.get("plan", 0)); b.out += float(c.get("out", 0)); b.fill += float(c.get("fill_now", 0))
				b.p += float(c.get("p", 0)); b.n += 1
		var cfg: Dictionary = gd.file("economy")
		var sp := CraftEconomy.specs(gd)
		for m in db.find(WorldEconomy.TABLE, func(x): return str(x.id).begins_with("mk:")):
			for cid in ["talisman3", "artifact4"]:
				var c: Dictionary = m.get("crafted", {}).get(cid, {})
				if c.is_empty():
					continue
				var cost: float = 0.0
				for rr in sp[cid].recipes:
					var goods: Array = rr.a.keys() if rr.has("a") else rr.group
					var rc_cost: float = 0.0
					for g in goods:
						var w: float = float(rr.a[g]) if rr.has("a") else 1.0 / float(goods.size())
						var rc: String = WorldEconomy.class_of(gd, str(g))
						rc_cost += w * float(m.classes.get(rc, {}).get("p", 1.0)) * WorldEconomy.scarcity_factor(gd, db, str(m.id), str(g))
					cost += float(rr.share) * rc_cost
				var nx := CraftEconomy.plan_next(cfg, float(c.plan), float(c.plan_ref), float(c.p) / maxf(cost, 1e-9), float(c.cover), float(c.get("fill_now", 1.0)), str(c.kind))
				print("    %s %s plan %.1f ref %.1f p %.2f cost %.2f cover %.2f fill %.2f d %.1f star %.1f next %.1f" % [m.id, cid, float(c.plan), float(c.plan_ref), float(c.p), cost, float(c.cover), float(c.get("fill_now", 1.0)), float(c.d), float(nx.star), float(nx.plan)])
		var ids: Array = by.keys()
		ids.sort()
		print("== year %d" % year)
		for cid in ids:
			var b: Dictionary = by[cid]
			print("  %-10s d %8.1f s %8.1f stock %8.1f plan %8.1f out %8.1f fill %.2f p %.2f" % [cid, b.d, b.s, b.stock, b.plan, b.out, b.fill / maxf(b.n, 1), b.p / maxf(b.n, 1)])
	quit()
