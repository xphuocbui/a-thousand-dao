extends SceneTree
## Balance probe for NPC progression: creates cohorts of NPCs at Luyện Khí tầng 1, age 16,
## runs the real world tick with the intake off until they die, and prints how many made each
## breakthrough. Targets: canh-gioi.md AC-CG-54 (all edges at e = 1 reach each gate's max).
## Observations only.
##
##   Godot_console.exe --headless --path . -s res://tools/balance/npc_cohort.gd -- [--size 300] [--seed 7]


func _init() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	var size: int = int(_arg(args, "--size", "300"))
	var seed_v: int = int(_arg(args, "--seed", "7"))
	var gd := GameData.load_from("res://assets/data")
	gd.world_gen().people.world_cultivators = 0
	gd.world_gen().people.world_cultivators_min = 0
	var tree := MeridianTree.generate(gd)
	var llm := LlmService.new(gd)
	llm.enabled = false
	for cohort in ["no edge", "all edges"]:
		var s := GameSession.new(gd, llm, tree)
		s.new_game(seed_v, {"mode": "roll", "name": "Probe", "origin": "tan_tu", "edge": false})
		# Only the cohort lives in this world, so the tick measures it alone.
		for p in s.db.all("people"):
			if not p.get("is_player", false):
				p["alive"] = false
		var ids: Array = []
		for i in size:
			var pid: String = s.builds.create_person(s.rng, {"realm_index": 0, "stage": 0, "age": 16.0, "location_id": s.player.location_id})
			var rec: Dictionary = s.db.get_record("people", pid)
			rec["background"] = ""
			rec["perks"] = []
			rec["sect_rank"] = ""
			if cohort == "all edges":
				rec["background"] = "rich_family"
				rec["perks"] = ["dao_cot"]
				rec["sect_rank"] = "tong_chu"
			ids.append(pid)
		var year: int = s.year
		var seasons: int = 0
		while ids.any(func(id): return s.db.get_record("people", id).alive) and seasons < 4000:
			s.ticker.tick(s.rng, year, seasons % 4)
			seasons += 1
			if seasons % 4 == 0:
				year += 1
		var reached: Array = [size, 0, 0, 0, 0]
		var mean_p: float = 0.0
		for id in ids:
			var r: Dictionary = s.db.get_record("people", id)
			for ri in [1, 2, 3, 4]:
				if int(r.realm_index) >= ri:
					reached[ri] += 1
			mean_p += ProgressionEdges.npc_step_chance(r, gd).total
		var parts: PackedStringArray = []
		for ri in [1, 2, 3, 4]:
			parts.append("%s %d/%d = %.0f%%" % [gd.realm(ri).name, reached[ri], reached[ri - 1], 100.0 * float(reached[ri]) / maxf(float(reached[ri - 1]), 1.0)])
		print("%-10s (mean step chance %.2f, %d years): %s" % [cohort, mean_p / float(size), seasons / 4, " · ".join(parts)])
	quit()


func _arg(args: PackedStringArray, flag: String, default: String) -> String:
	var i: int = args.find(flag)
	return args[i + 1] if i != -1 and i + 1 < args.size() else default
