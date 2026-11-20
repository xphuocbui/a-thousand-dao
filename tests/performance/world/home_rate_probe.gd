extends SceneTree
## The cultivation ground at every origin home (observation): Formula B's stacked density and Formula A's land match
## for a few sample roots, against the old generated world's home density (about 0.8-1.1).
## Run: godot --headless --path . -s res://tests/performance/world/home_rate_probe.gd


func _init() -> void:
	var gd := GameData.load_from("res://assets/data")
	gd.file("combat_rankings")["enabled"] = false
	gd.world_gen().people.world_cultivators = 200
	gd.world_gen().people.world_cultivators_min = 0
	var rng := RandomNumberGenerator.new()
	rng.seed = 1
	var db: WorldDB = WorldBuilder.new(gd, DaoDoTree.load_map(gd)).generate(rng, "1")
	var roots := {"Fire 70": {"hoa": 70.0}, "Wood 60 Water 40": {"moc": 60.0, "thuy": 40.0}, "Metal 80 Earth 50": {"kim": 80.0, "tho": 50.0}, "five 40": {"kim": 40.0, "moc": 40.0, "thuy": 40.0, "hoa": 40.0, "tho": 40.0}}
	var homes: Dictionary = gd.file("world_continent").origin_homes
	for origin in homes:
		var dens: Array = []
		var line: String = "%-9s" % origin
		var by_root := {}
		for cid in homes[origin]:
			var p: Dictionary = db.find("places", func(x): return int(x.get("continent_id", -1)) == int(cid))[0]
			for rname in roots:
				var c := Character.new()
				c.id = "probe"
				c.linh_can.elements = roots[rname].duplicate()
				c.linh_can.recompute_derived(gd)
				var d: float = float(LandQi.stacked_density(gd, c, p.qi, float(p.density), 0.0).total)
				var m: float = LandQi.land_match(c, gd, p.qi).total
				if not by_root.has(rname):
					by_root[rname] = []
				by_root[rname].append(d * m)
				if rname == "five 40":
					dens.append(d)
		var mean_d: float = 0.0
		for x in dens:
			mean_d += float(x)
		line += " stacked density mean %.2f |" % (mean_d / float(dens.size()))
		for rname in by_root:
			var v: float = 0.0
			for x in by_root[rname]:
				v += float(x)
			line += " %s D x M %.2f |" % [rname, v / float(by_root[rname].size())]
		print(line)
	quit()
