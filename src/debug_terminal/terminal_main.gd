extends SceneTree
## Entry point of the debug terminal (runs headless in the console build of Godot):
##
##   Godot_v4.7.1-stable_win64_console.exe --headless --path . -s res://src/debug_terminal/terminal_main.gd
##       [-- --seed N] [--color | --no-color] [--echo] [--commands file.txt] [--exit-after-commands]
##          [--no-llm] [--llm-url http://localhost:18080] [--llm-model name]
##          [--achievements-file path]   (default user://achievements.json; memory only with --commands)
##          [--codex-file path]          (default user://codex.json; memory only with --commands)
##          [--set file.key.path=value ...]   (in-memory data overrides for this run only, e.g.
##           --set combat_rankings.enabled=true --set combat_rules.fight_engine.enabled=true)
##
## tools/debug-terminal.sh and tools/debug-terminal.bat wrap this command.


func _init() -> void:
	quit(run(OS.get_cmdline_user_args()))


## Runs the terminal with [param args] (the user args) until it exits; returns the exit code. Static so the release
## bench export can run it too (tests/performance/combat/combat_bench.gd --terminal).
static func run(args: PackedStringArray) -> int:
	var gd := GameData.load_from("res://assets/data")
	if not gd.registry.errors.is_empty():
		for e in gd.registry.errors:
			printerr("DATA ERROR: " + e)
		return 1
	for ai in args.size():
		if args[ai] == "--set" and ai + 1 < args.size():
			var err: String = apply_override(gd, args[ai + 1])
			if err != "":
				printerr("--set %s: %s" % [args[ai + 1], err])
				return 1
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
	# Codex persists for real play; scripted runs (--commands) keep it in memory unless --codex-file is passed.
	var codex_path: String = "" if args.has("--commands") else "user://codex.json"
	var cf: int = args.find("--codex-file")
	if cf != -1 and cf + 1 < args.size():
		codex_path = args[cf + 1]
	app.codex_store = CodexStore.new(codex_path)
	var i: int = args.find("--seed")
	if i != -1 and i + 1 < args.size():
		app.next_seed = int(args[i + 1])
	var c: int = args.find("--commands")
	if c != -1 and c + 1 < args.size():
		if not io.queue_file(args[c + 1]):
			printerr("Cannot read command file %s" % args[c + 1])
			return 1
		io.echo = true
		io.scripted_only = args.has("--exit-after-commands")
	app.run()
	if app.session != null:
		app.session.shutdown()   # a season batch may still run on its background thread
	return 0


## Applies one "--set file.key.path=value" override to [param gd]'s loaded data, in memory only (the files are never
## written). The value is parsed as JSON (true, 12, 0.5, "text", [1, 2]); a bare word that is not JSON is a string.
## Returns "" or the reason it was refused (an unknown file or key: a typo must not pass silently).
static func apply_override(gd: GameData, spec: String) -> String:
	var eq: int = spec.find("=")
	if eq <= 0:
		return "expected file.key=value"
	var path: PackedStringArray = spec.substr(0, eq).split(".")
	if path.size() < 2:
		return "expected file.key=value"
	var node: Variant = gd.file(path[0])
	if not (node is Dictionary) or (node as Dictionary).is_empty():
		return "no data file %s" % path[0]
	for k in range(1, path.size() - 1):
		if not (node is Dictionary) or not (node as Dictionary).has(path[k]):
			return "no key %s" % ".".join(path.slice(0, k + 1))
		node = node[path[k]]
	var last: String = path[path.size() - 1]
	if not (node is Dictionary) or not (node as Dictionary).has(last):
		return "no key %s" % spec.substr(0, eq)
	var raw: String = spec.substr(eq + 1)
	var parsed: Variant = JSON.parse_string(raw)
	node[last] = raw if parsed == null and raw != "null" else parsed
	print("data override (this run only): %s = %s" % [spec.substr(0, eq), str(node[last])])
	return ""
