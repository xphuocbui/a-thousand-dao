extends SceneTree
## Observation probe (AC-KMD-07, not a gdUnit test): the W an NPC's Đạo Đồ holds, by realm stage, as the allocator
## spends it on the v5 map (the content's W per line times the rule-4 multiplier; roads at road_purity x
## purity_price). 300 seeded NPCs a row.
##   godot --headless --path . -s res://tests/performance/dao_do/tree_power_probe.gd


func _init() -> void:
	var gd := GameData.load_from("res://assets/data")
	var tree := DaoDoTree.load_map(gd)
	var db := WorldDB.new()
	var gen := BuildGenerator.new(gd, tree, db)
	var rng := RandomNumberGenerator.new()
	rng.seed = 707
	for row in [[0, 3, "Qi Refining great perfection"], [1, 3, "Foundation great perfection"], [2, 3, "Core Formation great perfection"], [4, 3, "Deity Transformation great perfection"]]:
		var ws: Array = []
		var per: Array = []
		for i in 300:
			var pid: String = gen.create_person(rng, {"realm_index": int(row[0]), "stage": int(row[1])})
			var c := Character.from_dict(db.get_record("people", pid))
			var w := 0.0
			for id in c.tree_nodes:
				w += tree.node_value(c, gd, int(id))
			ws.append(w)
			per.append(w / maxf(1.0, float(c.tree_nodes.size() - 1)))
		ws.sort()
		per.sort()
		print("%s: tree W median %.0f (p10 %.0f, p90 %.0f), W per point median %.2f (w_target %.2f)" % [row[2], ws[150], ws[30], ws[270], per[150], float(gd.tree_config().w_target)])
	quit()
