extends SceneTree
## Probe (observation only): how many people NPC Relationships' incremental hook pass recomputes a season (marked by
## writes, and in all with partners and the rolling slice), in the built world. Debug build: compare counts, not ms.

func _init() -> void:
	var gd := GameData.load_from("res://assets/data")
	gd.file("combat_rankings")["enabled"] = false
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	var tree := DaoDoTree.load_map(gd)
	var builder := WorldBuilder.new(gd, tree)
	var db: WorldDB = builder.generate(rng, "11")
	var ticker := WorldTicker.new(gd, db, BuildGenerator.new(gd, tree, db))
	var lines: PackedStringArray = []
	for s in 12:
		ticker.tick(rng, builder.current_year + s / 4, s % 4)
		lines.append("%d/%d (%.1f ms)" % [int(TieTick.last_counts[0]), int(TieTick.last_counts[1]), float(TieTick.last_us[1]) / 1000.0])
	print("hook ties %d; marked/recomputed a season: %s" % [db.hook_ties().size(), ", ".join(lines)])
	quit()
