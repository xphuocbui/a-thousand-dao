extends SceneTree
## Herb fit (Travel & Map Formula G) at every origin home on the continent, for each herb (observation for tuning the
## herbs' first-guess climate bands). Run: godot --headless --path . -s res://tests/performance/world/herb_fit_probe.gd


func _init() -> void:
	var gd := GameData.load_from("res://assets/data")
	gd.file("combat_rankings")["enabled"] = false
	gd.world_gen().people.world_cultivators = 200
	gd.world_gen().people.world_cultivators_min = 0
	var rng := RandomNumberGenerator.new()
	rng.seed = 1
	var db: WorldDB = WorldBuilder.new(gd, DaoDoTree.load_map(gd)).generate(rng, "1")
	var homes: Dictionary = gd.file("world_continent").origin_homes
	var herbs: Array = gd.file("items_herbs").herbs
	for origin in homes:
		var line: String = "%-9s" % origin
		for h in herbs:
			var fits: Array = []
			for cid in homes[origin]:
				var p: Array = db.find("places", func(x): return int(x.get("continent_id", -1)) == int(cid))
				fits.append(float(HerbFit.fit(gd, h, p[0]).fit))
			fits.sort()
			var mean: float = 0.0
			for f in fits:
				mean += f
			mean /= float(fits.size())
			line += " | %s mean %.2f median %.2f" % [str(h.id).left(10), mean, fits[fits.size() / 2]]
		print(line)
	var grounds := {}
	for p in db.all("places"):
		for g in p.get("herb_grounds", []):
			grounds[str(g.herb)] = int(grounds.get(str(g.herb), 0)) + 1
	print("wild herb grounds by herb (Travel & Map rule 18): ", grounds)
	var all: Array = db.all("places").filter(func(x): return x.has("temp_c"))
	var t := []
	var r := []
	for p in all:
		t.append(HerbFit.climate(gd, p).T)
		r.append(HerbFit.climate(gd, p).R)
	t.sort()
	r.sort()
	print("climate index over %d places: T p10 %.0f median %.0f p90 %.0f; R p10 %.0f median %.0f p90 %.0f" % [all.size(), t[all.size() / 10], t[all.size() / 2], t[all.size() * 9 / 10], r[all.size() / 10], r[all.size() / 2], r[all.size() * 9 / 10]])
	quit()
