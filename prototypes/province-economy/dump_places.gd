# PROTOTYPE - NOT FOR PRODUCTION
extends SceneTree
## Province economy prototype, step 1 (prototypes/province-economy/README.md): builds the real world for one seed and
## writes what the economy needs per place, so the prototype re-sums the game's own numbers into provinces instead of
## inventing yields: each place's production by good class (MapProduction's per-place parts, the same ones its season
## sums into regions), its people by realm, its settlement weight, its region and that region's market.
##
## Run: godot --headless --path . -s res://prototypes/province-economy/dump_places.gd -- [--seed 7] [--out <path>]

func _init() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	var seed_v: int = 7
	var out: String = "res://prototypes/province-economy/places_seed7.json"
	for i in args.size():
		if args[i] == "--seed" and i + 1 < args.size():
			seed_v = int(args[i + 1])
		if args[i] == "--out" and i + 1 < args.size():
			out = args[i + 1]
	var gd := GameData.load_from("res://assets/data")
	gd.file("combat_rankings")["enabled"] = false
	var llm := LlmService.new(gd)
	llm.enabled = false
	var s := GameSession.new(gd, llm)
	s.new_game(seed_v, {"mode": "roll", "name": "Probe", "gender": "male", "origin": "tan_tu"})
	var db: WorldDB = s.db
	MapProduction.season(gd, db, true, false)   # per-place outputs for this season, reserves not advanced
	var cfg: Dictionary = gd.file(MapProduction.DATA_FILE)
	var heads: Dictionary = {}   # place id -> [n by realm 0..4]
	for person in db.living():
		if bool(person.get("alive", false)) and not bool(person.get("is_beast", false)):
			var pid: String = str(person.get("location_id", ""))
			if not heads.has(pid):
				heads[pid] = [0, 0, 0, 0, 0]
			var rl: int = clampi(int(person.get("realm_index", 0)), 0, 4)
			heads[pid][rl] = int(heads[pid][rl]) + 1
	var rows: Array = []
	for p in db.all("places"):
		var by_class: Dictionary = {}
		var add := func(good: String, v: float) -> void:
			if v <= 0.0:
				return
			var c: String = WorldEconomy.class_of(gd, good)
			by_class[c] = float(by_class.get(c, 0.0)) + v
		if p.has("local"):
			for g in p.local.get("last_herbs", {}):
				add.call(str(g), float(p.local.last_herbs[g]))
			if float(p.local.get("last_ore", 0.0)) > 0.0:
				add.call(str(p.local.get("ore", "")), float(p.local.last_ore))
		if p.has("herb_site"):
			for g in p.herb_site.get("by_good", {}):
				add.call(str(g), float(p.herb_site.by_good[g]))
		if p.has("site") and str(p.site.kind) != "linh_thach":
			var vv: float = float(p.site.get("last_output", 0.0)) * float(cfg.unit_value.get(str(p.site.resource), 1))
			var parts: Dictionary = MapProduction.kind_split(gd, str(p.site.kind), str(p.site.resource), int(round(vv)))
			for g in parts:
				add.call(str(g), float(parts[g]))
		var reg: Dictionary = db.get_record("regions", str(p.get("region_id", "")))
		var rec := {"id": str(p.id), "continent_id": int(p.get("continent_id", -1)), "name": str(p.get("name", "")),
			"kind": str(p.get("kind", "")), "tile": p.get("tile", [0, 0]), "region": int(reg.get("continent_id", 0)),
			"market": WorldEconomy.market_of_region(db, reg) if not reg.is_empty() else "",
			"production": by_class, "heads": heads.get(str(p.id), [0, 0, 0, 0, 0]),
			"mine_stones": float(p.site.get("last_output", 0.0)) if p.has("site") and str(p.site.kind) == "linh_thach" else 0.0}
		rows.append(rec)
	var markets: Array = []
	for m in db.all("markets"):
		markets.append({"id": str(m.id), "sect": str(m.get("sect_id", "")), "hub_region": str(m.get("hub_region", "")),
			"classes": (m.get("classes", {}) as Dictionary).keys()})
	var f := FileAccess.open(out, FileAccess.WRITE)
	f.store_string(JSON.stringify({"seed": seed_v, "places": rows, "markets": markets}))
	f.close()
	print("places %d, markets %d -> %s" % [rows.size(), markets.size(), out])
	s.shutdown()
	quit()
