extends SceneTree
## Probe (observation only): why Nguyên Anh runs about 2 × Realms' solved count (plan decision 11, 2026-11-21). Runs the
## built continent --years (200) and, each season, records the age of every NPC entering a realm; every 50 years
## prints, per realm, entries, mean and median entry age, the living count, mean age, mean lifespan bonus, and among
## those at the realm's last stage the share already fated (bt_fate ok): the steady-state value World Generation's
## pre-rolled fate needs.

func _init() -> void:
	var years: int = 200
	var args := OS.get_cmdline_user_args()
	if args.find("--years") >= 0:
		years = int(args[args.find("--years") + 1])
	var gd := GameData.load_from("res://assets/data")
	gd.file("combat_rankings")["enabled"] = false
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	var tree := DaoDoTree.load_map(gd)
	var builder := WorldBuilder.new(gd, tree)
	var db: WorldDB = builder.generate(rng, "11")
	var year: int = builder.current_year
	var ticker := WorldTicker.new(gd, db, BuildGenerator.new(gd, tree, db))
	var prev := {}
	for p in db.living():
		prev[str(p.id)] = int(p.get("realm_index", 0))
	var entry: Array = [[], [], [], [], []]
	for y in years:
		for s in 4:
			ticker.tick(rng, year, s)
			for p in db.living():
				var r: int = int(p.get("realm_index", 0))
				var was: int = int(prev.get(str(p.id), r))
				if r > was and not bool(p.get("is_beast", false)):
					entry[r].append(float(p.age))
				prev[str(p.id)] = r
		year += 1
		if (y + 1) % 50 != 0:
			continue
		print("== year %d" % year)
		for r in gd.realms().size():
			var ppl: Array = db.living().filter(func(p): return int(p.get("realm_index", 0)) == r and not bool(p.get("is_beast", false)) and not bool(p.get("is_player", false)))
			var last: int = gd.stage_count(r) - 1
			var gate: Array = ppl.filter(func(p): return int(p.get("stage", 0)) == last and int(p.get("bt_fate", {}).get("realm", -1)) == r)
			var ok: int = gate.filter(func(p): return bool(p.bt_fate.get("ok", false))).size()
			var e: Array = Array(entry[r]).duplicate()
			e.sort()
			var mean_e: float = 0.0 if e.is_empty() else e.reduce(func(a, x): return a + x, 0.0) / e.size()
			var mean_age: float = 0.0 if ppl.is_empty() else ppl.reduce(func(a, p): return a + float(p.age), 0.0) / ppl.size()
			var bonus: float = 0.0 if ppl.is_empty() else ppl.reduce(func(a, p): return a + float(p.get("lifespan_bonus", 0.0)), 0.0) / ppl.size()
			print("  realm %d: n %d, mean age %.0f, lifespan %d + bonus %.1f; entries %d, entry age mean %.0f median %.0f; at the gate with fate %d, fated %d (%.1f %%)" % [r, ppl.size(), mean_age, int(gd.realm(r).lifespan), bonus, e.size(), mean_e, 0.0 if e.is_empty() else e[e.size() / 2], gate.size(), ok, 0.0 if gate.is_empty() else 100.0 * ok / gate.size()])
	quit()
