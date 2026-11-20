extends SceneTree
## Observation, not a verdict: the markets of Regional Economy & Trade over a run of world seasons on continent 11
## (prices, cover and stock by class per market, the calibrated demand scales, and the local price spread), so the
## calibration and stability can be read (AC-RE-51, AC-RE-57). Run:
## godot --headless --path . -s res://tests/performance/world/market_probe.gd -- [seasons]


func _init() -> void:
	var args := OS.get_cmdline_user_args()
	var seasons: int = int(args[0]) if args.size() > 0 else 40
	var gd := GameData.load_from("res://assets/data")
	gd.file("combat_rankings")["enabled"] = false
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	var tree := DaoDoTree.load_map(gd)
	var t0: int = Time.get_ticks_msec()
	var db: WorldDB = WorldBuilder.new(gd, tree).generate(rng, "11")
	print("world built in %d ms; d_scale %s" % [Time.get_ticks_msec() - t0, str(db.get_record(WorldEconomy.TABLE, "mk_calibration").get("d_scale", {}))])
	_show(db, 0)
	var ticker := WorldTicker.new(gd, db, BuildGenerator.new(gd, tree, db))
	var tm: float = 0.0
	for i in seasons:
		var t1: int = Time.get_ticks_msec()
		ticker.tick(rng, 1200 + i / 4, i % 4)
		tm += float(Time.get_ticks_msec() - t1)
		var chk: Dictionary = MoneyLedger.new(db).season_check()
		var b: Dictionary = MoneyLedger.new(db).books()
		var deaths: int = db.find("events", func(e): return str(e.get("type", "")) == "tick_death" and int(e.get("year", 0)) == 1200 + i / 4 and int(e.get("season", -1)) == i % 4).size()
		print("s%02d M %.0f gap %.3f minted %.0f burned %s moved %s deaths %d flows %s" % [i, chk.m_now, chk.gap, chk.minted, str(b.burned), str(b.get("moved", {})), deaths, str(ticker.last_money)])
		if (i + 1) % 10 == 0:
			_show(db, i + 1)
	print("world tick %.1f ms a season" % (tm / maxf(1.0, float(seasons))))
	quit()


func _show(db: WorldDB, s: int) -> void:
	var money := MoneyLedger.new(db)
	print("-- season %d  links %d  M %.0f" % [s, db.get_record(WorldEconomy.TABLE, "mk_links").get("links", []).size(), money.money_in_world()])
	var kinds := {}
	for e in db.all("events"):
		var t: String = str(e.get("type", ""))
		if t.begins_with("sect_") or t.begins_with("vassal_") or t == "territory_change":
			kinds[t] = int(kinds.get(t, 0)) + 1
	var rel := {}
	for sx in db.all("sects"):
		if str(sx.get("status", "")) == "active" and str(sx.get("kind", "")) == "great":
			for o in sx.get("relation", {}):
				rel[str(sx.relation[o])] = int(rel.get(str(sx.relation[o]), 0)) + 1
	var levels: Array = []
	for sx in db.find("sects", func(x): return str(x.get("kind", "")) == "great"):
		levels.append("%s %s %s tr %.0f" % [str(sx.get("key", "")), str(sx.get("status", "")), str(sx.get("levels", {}).values()), float(sx.get("treasury", 0.0))])
	print("   politics %s relations %s" % [str(kinds), str(rel)])
	print("   sects " + " | ".join(levels))
	var ms: Array = db.find(WorldEconomy.TABLE, func(x): return str(x.id).begins_with("mk:"))
	ms.sort_custom(func(a, b): return str(a.id) < str(b.id))
	for m in ms:
		var line: String = "%-8s %-14s" % [str(m.id), str(db.get_record("sects", str(m.sect_id)).get("name", ""))]
		for k in m.classes:
			var c: Dictionary = m.classes[k]
			line += " | %s P %.3f c %.2f S %.0f D %.0f i%.0f e%.0f" % [k, float(c.p), float(c.cover), float(c.s), float(c.d), float(c.get("imp", 0.0)), float(c.get("exp", 0.0))]
		var lo: float = 9.0
		var hi: float = 0.0
		for rid in m.regions:
			for k in m.regions[rid].get("p_loc", {}):
				var v: float = float(m.regions[rid].p_loc[k]) / maxf(0.0001, float(m.classes[k].p))
				lo = minf(lo, v)
				hi = maxf(hi, v)
		line += " | p_loc/P %.2f-%.2f | pool %.0f treasury %.0f" % [lo, hi, MoneyLedger.new(db).balance("pool:%s" % m.sect_id), MoneyLedger.new(db).balance("sect:%s" % m.sect_id)]
		print(line)
