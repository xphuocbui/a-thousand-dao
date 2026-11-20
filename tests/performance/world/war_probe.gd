extends SceneTree
## Probe (observation only): why great sects stop declaring wars. Every 5 years prints, per great sect, its war
## readiness and expansion dials, then each great pair's attitude, relation, borders and strength ratio against F18's odds.

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
	for y in 40:
		for s in 4:
			ticker.tick(rng, year, s)
		year += 1
		if (y + 1) % 5 != 0:
			continue
		var st := SectPolitics.strengths(gd, db)
		var greats: Array = db.find("sects", func(x): return str(x.get("kind", "")) == "great" and str(x.get("status", "")) == "active")
		print("== year %d" % year)
		for a in greats:
			print("  %s [%s] wr %d exp %d str %.0f state %s pulls %s" % [a.key, a.alignment, int(a.dials.get("war_readiness", 2)), int(a.dials.get("expansion", 2)), float(st.get(str(a.id), 0.0)), a.get("state", ""), str(SectPolitics.pulls_of(gd, db, a).get("dials", {}))])
		for a in greats:
			for b in greats:
				if a == b:
					continue
				var bo: int = SectPolitics._borders(gd, db, a, b)
				if bo == 0:
					continue
				print("    %s -> %s: A %.0f (tgt %.0f) rel %s borders %d ratio %.2f grudge %.0f" % [a.key, b.key, float(a.attitude.get(str(b.id), 0.0)),
					SectPolitics.attitude_target(gd, db, a, b, st), str(a.relation.get(str(b.id), "")), bo,
					float(st.get(str(a.id), 0.0)) / maxf(float(st.get(str(b.id), 0.0)), 1e-9), float(a.get("grudge", {}).get(str(b.id), 0.0))])
	quit()
