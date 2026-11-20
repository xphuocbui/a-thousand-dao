extends SceneTree
## Probe (observation only): world supply S and demand D by kind (summed over the great sects' markets), the stock,
## and the demand-weighted price, at the start and every 5 years for 30 years; with the demand split where the
## market keeps one (baskets, sects, craft_in), to see which side moves prices above the 0.9-1.15 band.

const KINDS := ["herb", "ore", "beast", "special", "pill", "talisman", "artifact"]


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
	_dump(db, year)
	for y in 10:
		for s in 4:
			ticker.tick(rng, year, s)
		year += 1
		if (y + 1) % 5 == 0:
			_dump(db, year)
	quit()


func _dump(db: WorldDB, year: int) -> void:
	var agg := {}
	var keys := {}
	for m in db.find(WorldEconomy.TABLE, func(x): return str(x.id).begins_with("mk:")):
		for tbl in ["classes", "crafted"]:
			for cid in m.get(tbl, {}):
				var c: Dictionary = m[tbl][cid]
				var k: String = str(c.get("kind", ""))
				if not agg.has(k):
					agg[k] = {"s": 0.0, "d": 0.0, "stock": 0.0, "pd": 0.0}
				agg[k].s += float(c.get("s", 0.0))
				agg[k].d += float(c.get("d", 0.0))
				agg[k].stock += float(c.get("stock", 0.0))
				agg[k].pd += float(c.get("p", 1.0)) * maxf(float(c.get("d", 0.0)), 1e-6)
				for f in c:
					keys[f] = true
	var out: Array = []
	for k in KINDS:
		if agg.has(k):
			var a: Dictionary = agg[k]
			out.append("%s S %.0f D %.0f st %.0f p %.2f" % [k, a.s, a.d, a.stock, a.pd / maxf(a.d, 1e-6)])
	print("year %d: %s" % [year, " | ".join(PackedStringArray(out))])
	var cc := {}
	for m in db.find(WorldEconomy.TABLE, func(x): return str(x.id).begins_with("mk:")):
		for cid in m.get("crafted", {}):
			var c: Dictionary = m.crafted[cid]
			if not cc.has(cid):
				cc[cid] = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
			cc[cid][0] += float(c.get("s", 0.0))
			cc[cid][1] += float(c.get("d", 0.0))
			cc[cid][2] += float(c.get("plan", 0.0))
			cc[cid][3] += float(c.get("plan_ref", 0.0))
			cc[cid][4] += float(c.get("fill", 0.0))
			cc[cid][5] += 1.0
	var ck: Array = cc.keys()
	ck.sort()
	for cid in ck:
		var v: Array = cc[cid]
		print("   %s S %.0f D %.0f plan %.0f ref %.0f fill %.2f" % [cid, v[0], v[1], v[2], v[3], v[4] / maxf(v[5], 1.0)])
	if year % 100 == 0:
		print("  class fields: %s" % str(keys.keys()))
