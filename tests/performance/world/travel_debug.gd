extends SceneTree
## Prints the travel grid's modes around a tile (debugging aid; not a test).
##   godot --headless --path . -s res://tests/performance/world/travel_debug.gd -- <x> <y> [r]


func _init() -> void:
	var args: Array = Array(OS.get_cmdline_user_args())
	var x0: int = int(args[0]) if args.size() > 0 else 265
	var y0: int = int(args[1]) if args.size() > 1 else 186
	var r: int = int(args[2]) if args.size() > 2 else 4
	var gd := GameData.load_from("res://assets/data")
	var tg := TravelGrid.of(gd)
	for y in range(y0 - r, y0 + r + 1):
		var row: String = ""
		for x in range(x0 - r, x0 + r + 1):
			var i: int = y * tg.width + x
			row += ".WRBS"[tg._mode[i]] if tg._mode[i] < 5 else "?"
		print("%3d %s" % [y, row])
	if args.size() > 4:
		var a := Vector2i(int(args[3]), int(args[4]))
		var t: Dictionary = tg.trip(a, Vector2i(x0, y0))
		print("passable a ", tg.passable(a), " b ", tg.passable(Vector2i(x0, y0)), " trip ", t.get("seasons", "none"), " ", t.get("by_mode", {}))
		print("ground path size ", tg._ground.get_id_path(a, Vector2i(x0, y0)).size(), " solid a ", tg._ground.is_point_solid(a), " solid b ", tg._ground.is_point_solid(Vector2i(x0, y0)))
	quit()
