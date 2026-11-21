extends SceneTree
## Probe (observation only): NPC Relationships in the built world over --years (40). Each season after the tick:
## every living disciple whose master lives has the matching sư đồ tie (Ties.master_of == master_id); no tie names a
## dead person; the S8b queue is empty. Prints the first breach of each kind and a count at the end.

func _init() -> void:
	var years: int = 40
	var gd := GameData.load_from("res://assets/data")
	gd.file("combat_rankings")["enabled"] = false
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	var tree := DaoDoTree.load_map(gd)
	var builder := WorldBuilder.new(gd, tree)
	var db: WorldDB = builder.generate(rng, "11")
	var year: int = builder.current_year
	var ticker := WorldTicker.new(gd, db, BuildGenerator.new(gd, tree, db))
	var breaches := {"master": 0, "dead": 0, "queue": 0}
	var first := {}
	var check := func(when: String) -> void:
		for p in db.living():
			var m: String = str(p.get("master_id", ""))
			if m != "" and bool(db.get_record("people", m).get("alive", false)) and Ties.master_of(db, str(p.id)) != m:
				breaches.master += 1
				if not first.has("master"):
					first["master"] = "%s: %s's master_id %s, store %s" % [when, p.id, m, Ties.master_of(db, str(p.id))]
		for rec in db.all("ties"):
			for x in [str(rec.a), str(rec.b)]:
				if not bool(db.get_record("people", x).get("alive", false)):
					breaches.dead += 1
					if not first.has("dead"):
						first["dead"] = "%s: %s names the dead %s (%s)" % [when, rec.id, x, JSON.stringify(rec.get("pin", {}))]
		if not TieTick.queued(db).is_empty():
			breaches.queue += 1
	check.call("start")
	for y in years:
		for s in 4:
			ticker.tick(rng, year, s)
			check.call("%d.%d" % [year, s])
		year += 1
	print("ties %d at the end; breaches %s; first %s" % [db.count("ties"), JSON.stringify(breaches), JSON.stringify(first)])
	quit()
