extends SceneTree
## Probe (observation only): by realm, the mean lifespan bonus, mean age against lifespan, the share at the last stage,
## the share fated at the gate, and deaths and breakthroughs counted over 20 years: why the census sits above Realms'
## solved counts.


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
	_dump(gd, db, year)
	var ev0: int = db.count("events")
	for y in 20:
		for s in 4:
			ticker.tick(rng, year, s)
		year += 1
	var counts := {}
	var all: Array = db.all("events")
	for i in range(ev0, all.size()):
		var t: String = str(all[i].get("type", ""))
		if t.begins_with("tick_") or t == "breakthrough":
			var rl: int = -1
			var a: String = str(all[i].get("data", {}).get("refs", {}).get("a", ""))
			counts[t] = int(counts.get(t, 0)) + 1
	print("events over 20 years: %s" % str(counts))
	_dump(gd, db, year)
	quit()


func _dump(gd: GameData, db: WorldDB, year: int) -> void:
	for rl in 5:
		var n: int = 0
		var lb: float = 0.0
		var age_frac: float = 0.0
		var last: int = 0
		var fated: int = 0
		for p in db.all("people"):
			if not bool(p.get("alive", false)) or bool(p.get("is_beast", false)) or int(p.get("realm_index", 0)) != rl:
				continue
			n += 1
			var base_life: float = float(gd.realm(rl).lifespan)
			lb += float(p.get("lifespan_bonus", 0.0))
			age_frac += float(p.age) / (base_life + CultivationRules.lifespan_bonus_curved(gd, rl, float(p.get("lifespan_bonus", 0.0))))
			if int(p.get("stage", 0)) >= gd.stage_count(rl) - 1:
				last += 1
				if bool(p.get("bt_fate", {}).get("ok", false)) and int(p.bt_fate.get("realm", -1)) == rl:
					fated += 1
		print("year %d realm %d: n %d, lifespan %d + bonus %.1f, age/lifespan %.2f, at the last stage %d (%.0f %%), fated %d" % [year, rl, n, int(gd.realm(rl).lifespan), lb / maxf(n, 1), age_frac / maxf(n, 1), last, 100.0 * last / maxf(n, 1), fated])
