extends SceneTree
## Entry point of the debug terminal (runs headless in the console build of Godot):
##
##   Godot_v4.7.1-stable_win64_console.exe --headless --path . -s res://src/debug_terminal/terminal_main.gd
##       [-- --seed N] [--color | --no-color] [--echo] [--commands file.txt] [--exit-after-commands]
##          [--no-llm] [--llm-url http://localhost:18080] [--llm-model name]
##          [--achievements-file path]   (default user://achievements.json; memory only with --commands)
##
## tools/debug-terminal.sh and tools/debug-terminal.bat wrap this command.


func _init() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	var gd := GameData.load_from("res://assets/data")
	if not gd.registry.errors.is_empty():
		for e in gd.registry.errors:
			printerr("DATA ERROR: " + e)
		quit(1)
		return
	var io := TerminalIO.new()
	# Colour by default in an interactive console; --color forces it (pipes), --no-color disables it.
	io.color = args.has("--color") or (OS.get_stdin_type() == OS.STD_HANDLE_CONSOLE and not args.has("--no-color"))
	# Echo input when it does not come from an interactive console (pipes, files).
	io.echo = args.has("--echo") or OS.get_stdin_type() != OS.STD_HANDLE_CONSOLE
	var llm := LlmService.new(gd)
	# --no-llm and --llm-url/--llm-model affect this run only (user config untouched).
	if args.has("--no-llm"):
		llm.enabled = false
	var u: int = args.find("--llm-url")
	if u != -1 and u + 1 < args.size():
		llm.client.base_url = args[u + 1]
		llm.enabled = true
	var mdl: int = args.find("--llm-model")
	if mdl != -1 and mdl + 1 < args.size():
		llm.client.model = args[mdl + 1]
	var app := TerminalApp.new(gd, llm, io)
	# Achievements persist for real play; scripted runs (--commands) keep them in memory so
	# tests never write into the player's record. --achievements-file overrides either way.
	var ach_path: String = "" if args.has("--commands") else "user://achievements.json"
	var af: int = args.find("--achievements-file")
	if af != -1 and af + 1 < args.size():
		ach_path = args[af + 1]
	app.achievements = Achievements.new(gd, AchievementStore.new(ach_path))
	var i: int = args.find("--seed")
	if i != -1 and i + 1 < args.size():
		app.next_seed = int(args[i + 1])
	var c: int = args.find("--commands")
	if c != -1 and c + 1 < args.size():
		if not io.queue_file(args[c + 1]):
			printerr("Cannot read command file %s" % args[c + 1])
			quit(1)
			return
		io.echo = true
		io.scripted_only = args.has("--exit-after-commands")
	app.run()
	quit(0)
