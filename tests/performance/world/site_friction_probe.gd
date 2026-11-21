extends SceneTree
## Probe (observation only): for each pair of bordering great sects on the built continent, the attitude target (Sects
## F7) and the resource sites on their shared border: sites in a region one holds that borders a region the other
## holds, with each site's kind and base output. Feeds the site-friction proposal (plan decision 1, 2026-11-21).

func _init() -> void:
	var gd := GameData.load_from("res://assets/data")
	gd.file("combat_rankings")["enabled"] = false
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	var tree := DaoDoTree.load_map(gd)
	var builder := WorldBuilder.new(gd, tree)
	var db: WorldDB = builder.generate(rng, "11")
	var adj := {}
	for r in gd.file(ContinentData.DATA_FILE).get("regions", []):
		adj[int(r.id)] = Array(r.get("neighbours", [])).map(func(n): return int(n.region))
	var holder_of := {}   # continent region id -> sect id
	var cid_of := {}   # db region id -> continent id
	for r in db.all("regions"):
		holder_of[int(r.get("continent_id", -1))] = str(r.get("holder", ""))
		cid_of[str(r.id)] = int(r.get("continent_id", -1))
	var st := SectPolitics.strengths(gd, db)
	var greats: Array = db.find("sects", func(x): return str(x.get("kind", "")) == "great" and str(x.get("status", "")) == "active")
	var all_sites: Array = db.all("places").filter(func(p): return not Dictionary(p.get("site", {})).is_empty())
	print("sites in all: %d; base output total %.0f" % [all_sites.size(), all_sites.reduce(func(acc, p): return acc + float(p.site.base_output), 0.0)])
	for i in greats.size():
		for j in range(i + 1, greats.size()):
			var a: Dictionary = greats[i]
			var b: Dictionary = greats[j]
			var bo: int = SectPolitics._borders(gd, db, a, b)
			if bo == 0:
				continue
			var cont: Array = []
			for p in all_sites:
				var cid: int = int(cid_of.get(str(p.get("region_id", "")), -1))
				var h: String = str(holder_of.get(cid, ""))
				var other: String = str(b.id) if h == str(a.id) else (str(a.id) if h == str(b.id) else "")
				if other == "":
					continue
				for nb in adj.get(cid, []):
					if str(holder_of.get(int(nb), "")) == other:
						cont.append("%s %s %.0f" % [str(p.get("kind", "")), str(p.get("name", "")), float(p.site.base_output)])
						break
			var v: float = 0.0
			for c in cont:
				v += float(str(c).split(" ")[-1])
			print("%s [%s] - %s [%s]: borders %d, A_tgt %.0f / %.0f, str %.0f / %.0f, border sites %d worth %.0f: %s" % [a.key, a.alignment, b.key, b.alignment, bo,
				SectPolitics.attitude_target(gd, db, a, b, st), SectPolitics.attitude_target(gd, db, b, a, st),
				float(st.get(str(a.id), 0.0)), float(st.get(str(b.id), 0.0)), cont.size(), v, ", ".join(cont)])
	quit()
