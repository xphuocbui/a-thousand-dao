extends SceneTree
## Probe (observation only): where the map makes each herb and material (plan decision 3, 2026-11-21). Per herb: the
## wild places holding its ground and the settlements whose land grows it; per resource: the sites yielding it, their
## kind and base value a season.

func _init() -> void:
	var gd := GameData.load_from("res://assets/data")
	gd.file("combat_rankings")["enabled"] = false
	gd.world_gen().people.world_cultivators = 200
	gd.world_gen().people.world_cultivators_min = 0
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	var builder := WorldBuilder.new(gd, DaoDoTree.load_map(gd))
	var db: WorldDB = builder.generate(rng, "11")
	var unit: Dictionary = gd.file(MapProduction.DATA_FILE).get("unit_value", {})
	var grounds := {}
	var local := {}
	var res := {}
	for p in db.all("places"):
		for g in p.get("herb_grounds", []):
			grounds[str(g.herb)] = int(grounds.get(str(g.herb), 0)) + 1
		for g in Dictionary(p.get("local", {})).get("herbs", []):
			local[str(g.herb)] = int(local.get(str(g.herb), 0)) + 1
		var site: Dictionary = p.get("site", {})
		if not site.is_empty():
			var r: String = str(site.get("resource", ""))
			if not res.has(r):
				res[r] = []
			res[r].append("%s %.0f" % [str(p.get("kind", "")), float(site.base_output) * float(unit.get(r, 1.0))])
	for h in gd.file(HerbFit.HERBS_FILE).get("herbs", []):
		print("herb %-18s rarity %d: wild grounds %d, settlements %d" % [h.id, int(h.rarity), int(grounds.get(str(h.id), 0)), int(local.get(str(h.id), 0))])
	for m in gd.file("items_materials").get("materials", []):
		print("material %-18s rarity %d: sites %s" % [m.id, int(m.rarity), str(res.get(str(m.id), []))])
	print("linh_thach sites: %d" % Array(res.get("linh_thach", [])).size())
	# candidates for scarce rare sites: wild places with no site, by land density, with their best rarity 4+ herb fits
	var cands: Array = []
	for p in db.all("places"):
		if not Dictionary(p.get("site", {})).is_empty() or Dictionary(p.get("qi", {})).is_empty() or p.has("local"):
			continue
		var fits: Array = []
		for h in gd.file(HerbFit.HERBS_FILE).get("herbs", []):
			if int(h.rarity) >= 4:
				fits.append([snappedf(float(HerbFit.fit(gd, h, p).fit), 0.01), str(h.id)])
		fits.sort_custom(func(x, y): return x[0] > y[0])
		cands.append([float(p.qi.get("land_density", p.get("density", 0.0))), p, fits.slice(0, 2)])
	cands.sort_custom(func(x, y): return x[0] > y[0])
	for c in cands.slice(0, 16):
		var p: Dictionary = c[1]
		var reg: Dictionary = db.get_record("regions", str(p.get("region_id", "")))
		print("cand %s (%s) %s, region %s, holder %s, density %.2f, fits %s, grounds %s" % [p.get("name", ""), p.id, p.get("kind", ""), reg.get("name", ""), reg.get("holder", ""), c[0], str(c[2]), str(Array(p.get("herb_grounds", [])).map(func(g): return g.herb))])
	quit()
