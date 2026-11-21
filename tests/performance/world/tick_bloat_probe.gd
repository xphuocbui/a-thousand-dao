extends SceneTree
## Probe (observation only): the season tick on a fresh world, then with a century and a half of history added by hand
## (dead people, Lost items, events), to find which part of the people step grows with history.

func _init() -> void:
	var gd := GameData.load_from("res://assets/data")
	gd.file("combat_rankings")["enabled"] = false
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	var tree := DaoDoTree.load_map(gd)
	var builder := WorldBuilder.new(gd, tree)
	var db: WorldDB = builder.generate(rng, "11")
	var year: int = builder.current_year
	var builds := BuildGenerator.new(gd, tree, db)
	var ticker := WorldTicker.new(gd, db, builds)
	for s in 4:
		ticker.tick(rng, year, s)
	year += 1
	_time(gd, db, ticker, builds, rng, year, "fresh")
	var people: Array = db.living()
	for i in 6000:
		var d: Dictionary = Dictionary(people[i % people.size()]).duplicate(true)
		d.erase("id")
		d["alive"] = false
		db.add("people", d)
	var items: Array = db.all("items")
	var places: Array = db.all("places")
	for i in 12000:
		var it: Dictionary = Dictionary(items[i % items.size()]).duplicate(true)
		it.erase("id")
		it["owner_id"] = str(places[i % places.size()].id)
		it["lost"] = true
		db.add("items", it)
	for i in 12000:
		db.log_event(year, 0, "tick_duel", "x", [str(people[i % people.size()].id)], [], [], {})
	_time(gd, db, ticker, builds, rng, year + 1, "with history")
	quit()


func _time(gd: GameData, db: WorldDB, ticker: WorldTicker, builds: BuildGenerator, rng: RandomNumberGenerator, year: int, label: String) -> void:
	var u: int = Time.get_ticks_usec()
	for s in 4:
		ticker.tick(rng, year, s)
	var tick: float = float(Time.get_ticks_usec() - u) / 4000.0
	var ppl: Array = db.living()
	u = Time.get_ticks_usec()
	for i in 200:
		builds.refresh_power(str(ppl[i * 13 % ppl.size()].id))
	var rp: float = float(Time.get_ticks_usec() - u) / 200000.0
	u = Time.get_ticks_usec()
	for i in 50:
		db.items_of(str(ppl[i].id))
	var io: float = float(Time.get_ticks_usec() - u) / 50000.0
	u = Time.get_ticks_usec()
	for i in 50:
		db.events_of(str(ppl[i].id))
	var eo: float = float(Time.get_ticks_usec() - u) / 50000.0
	print("%s: people %d items %d events %d | tick %.0f ms, refresh_power %.2f ms, items_of %.2f ms, events_of %.3f ms" % [label, db.count("people"), db.count("items"), db.count("events"), tick, rp, io, eo])
