class_name TerminalApp
extends RefCounted
## The debug terminal: parses commands, calls [GameSession] and prints [TerminalViews].
## It holds no gameplay rules — everything it shows comes from the session API, so this
## doubles as a reference client for the future Godot UI.
##
## Usage:
## [codeblock]
## var app := TerminalApp.new(gd, llm, io)
## app.run()                      # REPL until 'quit' or end of input
## app.execute("new quick Lâm")   # or drive it command by command (tests, scripts)
## [/codeblock]

const HELP := [
	["General", [
		["help [command]", "this list"], ["quit", "leave"], ["status", "the HUD (bars, goals)"],
		["<number> / Enter", "run a menu entry / show the menu again"], ["menu on|off", "show the numbered menu after each turn"],
		["goals", "everything worth doing now, most urgent first"],
		["save [slot] / load [slot] / saves", "save files in user://saves"],
		["color on|off", "ANSI colours (on by default in a console)"],
	]],
	["New life", [
		["new", "character creation (Thiên Định roll or Tự Định choose), then world generation"],
		["new quick [name] [seed]", "roll and accept immediately (scripts)"],
	]],
	["Character", [
		["sheet", "full character sheet"], ["explain <what>", "breakdown of any number: rate power life ngo_tinh attack_pct ..."],
		["inv", "inventory"], ["field", "linh điền (herb plots, ripeness)"], ["recipes", "đan phương with odds"],
		["chronicle", "your life story so far"],
		["achievements", "thành tựu across lives (Thiên Định lives only; debug commands disqualify a life)"],
	]],
	["Actions (cost time)", [
		["cul [seasons]", "tu luyện (default 1 season)"], ["bequan <years>", "closed-door cultivation, no events"],
		["mission", "sect mission at your sect HQ, or bounty in a town"], ["explore", "search this place (events, lost treasures)"],
		["go [place id]", "travel along a road (no id: pick from a list)"], ["craft [recipe id]", "luyện đan, one season (no id: pick)"],
		["breakthrough [notalisman] [burn]", "attempt the great breakthrough into the next realm"],
		["tech", "known techniques, layers, slots"], ["slot main|aux1|aux2|second <row> | slot clear <slot>", "change technique slots"],
	]],
	["Actions (free)", [
		["plant [herb id|item id]", "buy a seed / transplant a herb (at home)"], ["harvest [plot|all]", "harvest herbs"],
		["use [item id]", "eat a pill"], ["equip|unequip [item id]", "pháp bảo"], ["learn [item id]", "switch công pháp"],
		["market / buy [id] / sell [id]", "trade at a market"], ["talk [person id] [what you say]", "conversation (LLM or template)"],
		["(any id left out)", "shows a numbered list to pick from"],
		["event / choose <n>", "read / answer the pending event"],
	]],
	["Crafts", [
		["refine [design] [tier]", "luyện khí: refine a pháp bảo, one season (no design: pick); 'explain refine'"],
		["formation", "trận pháp at your động phủ: levels, next cost, upkeep"],
		["formation build [id]", "raise a formation one level, one season (no id: pick); 'explain upkeep'"],
		["talisman [id]", "phù lục: draw a batch, one season (no id: pick); used automatically in fights/escapes"],
		["beasts / release <id>", "linh thú: your beasts (tame them by beating them in events), feeding, loyalty"],
	]],
	["World", [
		["look", "this place, people, roads"], ["map", "all regions and roads"], ["news [n]", "recent world events"],
		["legends [n]", "history of the world"], ["db stats|people|sects|places|items|events [filter]", "database queries"],
		["db show <id>", "any record with its history"],
	]],
	["Kinh Mạch Đồ", [
		["tree", "points and openable huyệt"], ["tree map", "ASCII map"], ["tree targets", "notables/keystones by cost"], ["tree clusters", "hidden clusters"], ["tree mode visible|silhouette", "what hidden clusters show"],
		["tree node <id>", "details"], ["tree alloc [id]", "open one adjacent huyệt (no id: pick)"], ["tree go <id>", "open the whole path"],
	]],
	["LLM", [
		["llm", "status"], ["llm on|off", "toggle for this run"], ["llm key <key>", "store an API key (user://, not the repo)"],
		["llm url <base_url> [model]", "endpoint, e.g. https://api.deepseek.com deepseek-chat"], ["llm lang vi|en", "story language"],
		["llm test", "one round trip"], ["llm last", "last request and response"],
	]],
	["Debug", [
		["debug event [template id]", "force an event"], ["debug tuvi <n>", "add tu vi"], ["debug lt <n>", "add linh thạch"],
		["debug herb <herb id> <age>", "give a herb"], ["debug tp <n>", "add Kinh Mạch points"], ["debug heal", "full khí huyết, clear đan độc/tâm ma"],
		["debug item artifact|cong_phap [grade]", "generate an item"], ["buildgen <archetype> [realm 0-4]", "generate and show an NPC build"],
		["debug templates", "list event templates"],
	]],
]

var gd: GameData
var llm: LlmService
var io: TerminalIO
var session: GameSession
var store: SaveStore = SaveStore.new("user://saves")
## Thành tựu across lives; terminal_main swaps in a file-backed store for real play.
var achievements: Achievements
var quit_requested: bool = false
## Seed for the next 'new' (from --seed); 0 = random.
var next_seed: int = 0
## Show the numbered menu after each turn ('menu on|off').
var show_menu: bool = true

## Commands behind the numbers of the last menu shown.
var _menu_commands: Array = []
## Set when the last command started an event; the card is shown after the HUD.
var _event_started: bool = false


func _init(game_data: GameData, llm_service: LlmService, terminal_io: TerminalIO) -> void:
	gd = game_data
	llm = llm_service
	io = terminal_io
	achievements = Achievements.new(gd, AchievementStore.new())


## Read-eval-print loop.
func run() -> void:
	_welcome()
	while not quit_requested:
		var line: Variant = io.read_line(io.paint("> ", "1"))
		if line == null:
			io.out("(end of input)")
			break
		execute(str(line))


## Executes one command line.
func execute(line: String) -> void:
	var text: String = line.strip_edges()
	if text.begins_with("#"):
		return
	if text == "":
		if session != null and session.player != null:
			_show_turn(true)
		else:
			_welcome()
		return
	if text.is_valid_int():
		var picked: String = "choose " + text if session != null and session.has_pending_event() else _menu_command(int(text))
		if picked == "":
			io.out("No menu entry %s. Enter shows the menu." % text)
			return
		io.out(io.paint("» " + picked, "2"))
		text = picked
	var before_session: GameSession = session
	var before: Dictionary = StateSnapshot.take(session)
	_event_started = false
	_dispatch(text)
	_after(before_session, before)


func _dispatch(text: String) -> void:
	var parts: PackedStringArray = text.split(" ", false)
	var cmd: String = parts[0].to_lower()
	var args: Array = Array(parts.slice(1))
	match cmd:
		"help", "?":
			_help(args)
		"quit", "exit", "q":
			quit_requested = true
		"color":
			io.color = args.size() > 0 and args[0] == "on"
			io.out("Colour %s." % ("on" if io.color else "off"))
		"menu":
			if args.size() > 0:
				show_menu = args[0] != "off"
				io.out("Menu after each turn: %s." % ("on" if show_menu else "off"))
			elif session != null and session.player != null:
				_show_turn(true)
			else:
				_welcome()
		"new":
			_new(args)
		"save":
			_save(args)
		"load":
			_load(args)
		"saves":
			io.out("Saves: %s (in %s)" % [", ".join(store.list_slots()), ProjectSettings.globalize_path(store.root)])
		"llm":
			_llm(args)
		_:
			if session == null or session.player == null:
				io.out("No life in progress. 'new' to begin, 'load' to continue, 'help' for commands.")
				return
			_game_command(cmd, args, text)


## Commands that pass time: with an event waiting they cannot run, so skip their pickers.
const TIME_COMMANDS := ["go", "travel", "craft", "refine", "luyenkhi", "talisman", "phu", "phuluc", "cul", "cultivate", "bequan", "closed", "mission", "work", "explore", "breakthrough", "bt"]


func _game_command(cmd: String, args: Array, raw: String) -> void:
	var s: GameSession = session
	var builds_formation: bool = cmd in ["formation", "formations", "tran"] and _arg(args, 0, "") == "build"
	if (cmd in TIME_COMMANDS or builds_formation) and s.has_pending_event():
		io.out(io.paint("An event is waiting: answer it first (type 1-%d, or event to read it)." % s.pending_event.choices.size(), "33"))
		return
	match cmd:
		"status", "st", "hud":
			io.out_lines(TerminalViews.hud(s, io))
		"goals", "todo":
			io.out_lines(TerminalViews.goals(s, io))
		"sheet", "char", "c":
			io.out_lines(TerminalViews.sheet(s, io))
		"explain", "why":
			io.out_lines(TerminalViews.explain(s, _arg(args, 0, "rate")))
		"inv", "inventory", "i":
			io.out_lines(TerminalViews.inventory(s))
		"field":
			io.out_lines(TerminalViews.field(s))
		"recipes":
			io.out_lines(TerminalViews.recipes(s))
		"chronicle", "story":
			for e in s.db.events_of(s.player.id):
				io.out("năm %d: %s" % [int(e.year), e.text])
				if e.data.has("narration"):
					io.out("    " + str(e.data.narration))
		"cul", "cultivate":
			_r(s.cultivate(int(_arg(args, 0, "1"))))
		"bequan", "closed":
			_r(s.closed_door(int(_arg(args, 0, "1"))))
		"mission", "work":
			_r(s.mission())
		"explore":
			_r(s.explore())
		"go", "travel":
			var dest: String = _arg(args, 0, "") if args.size() > 0 else _pick_road()
			if dest != "":
				_r(s.travel(dest))
		"craft":
			var rid: String = _arg(args, 0, "") if args.size() > 0 else _pick_recipe()
			if rid != "":
				_r(s.craft(rid))
		"breakthrough", "bt":
			var no_talisman: bool = args.has("notalisman")
			var burn: bool = args.has("burn")
			var bt: Dictionary = s.breakthrough(false, not no_talisman, burn)
			if bool(bt.get("needs_confirm", false)):
				io.out_lines(bt.lines)
				var yes: Variant = io.read_line("  Attempt anyway? (yes/no): ")
				if str(yes) == "yes":
					bt = s.breakthrough(true, not no_talisman, burn)
				else:
					return
			_r(bt)
		"plant":
			var what: String = " ".join(args) if args.size() > 0 else _pick_seed()
			if what != "":
				_r(s.plant(what))
		"harvest":
			var a: String = _arg(args, 0, "all")
			_r(s.harvest(-1 if a == "all" else int(a)))
		"use", "eat":
			var u: String = _arg(args, 0, "") if args.size() > 0 else _pick_item("Use which pill or treasure?", func(it): return it.kind in ["pill", "treasure"])
			if u != "":
				_r(s.use_item(u, _arg(args, 1, "")))
		"equip":
			var e: String = _arg(args, 0, "") if args.size() > 0 else _pick_item("Equip which pháp bảo?", func(it): return it.kind == "artifact" and not s.player.equipped.has(it.id))
			if e != "":
				_r(s.equip(e))
		"unequip":
			var ue: String = _arg(args, 0, "") if args.size() > 0 else _pick_item("Unequip which pháp bảo?", func(it): return s.player.equipped.has(it.id))
			if ue != "":
				_r(s.unequip(ue))
		"learn":
			var lc: String = _arg(args, 0, "") if args.size() > 0 else _pick_item("Read which manual?", func(it): return it.kind == "cong_phap" and not s.player.techniques.has(str(it.get("tech_id", ""))))
			if lc != "":
				_r(s.learn(lc))
		"blink":
			_r(s.blink(_arg(args, 0, "")))
		"tech", "techniques":
			io.out_lines(TerminalViews.techniques(s, io))
		"slot":
			_slot_command(s, args)
		"refine", "luyenkhi":
			var design: String = _arg(args, 0, "") if args.size() > 0 else _pick_design()
			if design != "":
				_r(s.refine(design, int(_arg(args, 1, "-1"))))
		"beasts", "linhthu", "pets":
			io.out_lines(TerminalViews.beasts(s, io))
		"release":
			_r(s.release_beast(_arg(args, 0, "")))
		"talisman", "phu", "phuluc":
			var tid: String = _arg(args, 0, "") if args.size() > 0 else _pick_talisman()
			if tid != "":
				_r(s.draw_talisman(tid))
		"formation", "formations", "tran":
			if _arg(args, 0, "") == "build":
				var fid: String = _arg(args, 1, "") if args.size() > 1 else _pick_formation()
				if fid != "":
					_r(s.formation_build(fid))
			else:
				io.out_lines(TerminalViews.formations(s, io))
		"market":
			_market()
		"buy":
			var b: String = _arg(args, 0, "") if args.size() > 0 else _pick_market()
			if b != "":
				_r(s.buy(b))
		"sell":
			var sl: String = _arg(args, 0, "") if args.size() > 0 else _pick_item("Sell what?", func(it): return not s.player.equipped.has(it.id) and not (it.kind == "herb" and int(it.get("plot", -1)) >= 0))
			if sl != "":
				_r(s.sell(sl))
		"talk":
			var who: String = _arg(args, 0, "") if args.size() > 0 else _pick_person()
			if who == "":
				return
			var said: String = " ".join(args.slice(1)) if args.size() > 1 else ""
			if args.size() == 0:
				var said_in: Variant = io.read_line("What do you say? (Enter = a polite greeting): ")
				said = str(said_in).strip_edges() if said_in != null else ""
			if llm.use("talk"):
				io.out(io.paint("(thinking...)", "2"))
			_r(s.talk(who, said))
		"event":
			io.out_lines(TerminalViews.event(s, io))
		"choose", "ch":
			if llm.use("narration"):
				io.out("(the story unfolds...)")
			_r(s.choose(int(_arg(args, 0, "1")) - 1))
		"look", "here", "l":
			io.out_lines(TerminalViews.here(s))
		"map", "places":
			io.out_lines(TerminalViews.map(s))
		"news":
			var n: int = int(_arg(args, 0, "10"))
			for e in s.db.all("events").filter(func(x): return x.data.get("news", false)).slice(-n):
				io.out("năm %d: %s" % [int(e.year), e.text])
		"legends", "history":
			var n2: int = int(_arg(args, 0, "25"))
			for e in s.db.all("events").filter(func(x): return int(x.year) < s.year - 0 and not x.data.get("news", false)).slice(-n2):
				io.out("năm %d: %s" % [int(e.year), e.text])
		"db":
			_db(args)
		"person", "show":
			io.out_lines(TerminalViews.show(s, _arg(args, 0, "")))
		"tree":
			_tree(args)
		"buildgen":
			s.cheated = true
			_buildgen(args)
		"debug":
			s.cheated = true
			_debug(args)
		"achievements", "thanhtuu":
			io.out_lines(TerminalViews.achievements(s, achievements, io))
		_:
			io.out("Unknown command '%s'. 'help' lists commands." % cmd)


func _r(result: Dictionary) -> void:
	var lines: Array = result.get("lines", [])
	# The event card (shown after the HUD) replaces the session's one-line event notice.
	var triggered: bool = lines.any(func(l): return str(l).begins_with("*** EVENT"))
	for l in lines:
		if triggered and (str(l).begins_with("*** EVENT") or str(l) == ""):
			continue
		io.out(_style(str(l)))
	if session != null and session.has_pending_event() and triggered:
		_event_started = true


## Colours the session's plain result lines by their conventional markers.
func _style(l: String) -> String:
	if l.begins_with("  [tin đồn]"):
		return io.paint(l, "2")
	if l.contains("THÀNH CÔNG") or l.contains("!!!"):
		return io.paint(l, "1;32")
	if l.begins_with("Breakthrough failed") or l.contains("Tẩu hỏa") or l.contains("wounded"):
		return io.paint(l, "31")
	if l.contains("Bình cảnh!"):
		return io.paint(l, "1;33")
	return l


# --- Turn display ------------------------------------------------------------------------

## After a command: what changed, then the HUD and the menu when anything changed.
func _after(before_session: GameSession, before: Dictionary) -> void:
	if session == null or session.player == null or quit_requested:
		return
	if session != before_session:
		_show_turn(false)
		return
	for a in achievements.check(session):
		io.out(io.paint("  ★ Thành tựu: %s — %s" % [a.name, a.desc], "1;35"))
	var diff: Array = StateSnapshot.diff(before, StateSnapshot.take(session), gd)
	if diff.is_empty():
		if _event_started:
			io.out_lines(TerminalViews.event(session, io))
		return
	io.out_lines(TerminalViews.changes(io, diff))
	_show_turn(false)


## HUD, then the event reminder or the numbered menu. [param full] repeats the event card.
func _show_turn(full: bool) -> void:
	io.out("")
	io.out_lines(TerminalViews.hud(session, io))
	var actions: Array = Advisor.actions(session)
	_menu_commands = actions.map(func(a): return str(a.command))
	if session.has_pending_event():
		if full or _event_started:
			io.out_lines(TerminalViews.event(session, io))
		else:
			io.out(io.paint(" An event waits: type 1-%d to choose ('event' shows it again)." % session.pending_event.choices.size(), "33"))
		return
	if session.life_over or show_menu or full:
		io.out_lines(TerminalViews.menu(io, actions))


func _menu_command(n: int) -> String:
	if n < 1 or n > _menu_commands.size():
		return ""
	return str(_menu_commands[n - 1])


func _welcome() -> void:
	io.out("")
	io.out(io.paint("  ☯  TEN THOUSAND DAOS  — debug terminal", "1;36"))
	io.out(io.paint("  " + llm.status_line(), "2"))
	io.out("")
	var entries: Array = [
		{"label": "New life (choose origin, roll or set your thiên phú and linh căn)", "command": "new", "group": "goal"},
		{"label": "Quick start (random tán tu)", "command": "new quick", "group": "goal"},
	]
	if store.list_slots().has("autosave"):
		entries.append({"label": "Continue (load autosave)", "command": "load", "group": "goal"})
	entries.append({"label": "Help: every command", "command": "help", "group": "goal"})
	_menu_commands = entries.map(func(a): return str(a.command))
	io.out_lines(TerminalViews.menu(io, entries))


# --- Pickers -----------------------------------------------------------------------------

## Shows numbered rows ({label, value}) and returns the chosen value, or "" when cancelled.
func _pick(title: String, rows: Array) -> String:
	if rows.is_empty():
		io.out("Nothing to choose from: %s" % title)
		return ""
	io.out(io.paint(title, "1"))
	for i in rows.size():
		io.out("  %s %s" % [io.paint("%2d" % (i + 1), "1"), rows[i].label])
	var a: Variant = io.read_line("Pick 1-%d (Enter = cancel): " % rows.size())
	var t: String = str(a).strip_edges() if a != null else ""
	if not t.is_valid_int() or int(t) < 1 or int(t) > rows.size():
		io.out("Cancelled.")
		return ""
	return str(rows[int(t) - 1].value)


func _pick_road() -> String:
	var s: GameSession = session
	var here: Dictionary = s.db.get_record("places", s.player.location_id)
	var rows: Array = []
	for l in here.links:
		var to: Dictionary = s.db.get_record("places", l.to)
		var marks: PackedStringArray = []
		if to.market:
			marks.append("market")
		if to.sect_id != "":
			marks.append(s.db.get_record("sects", to.sect_id).name)
		if to.id == s.player.home_id:
			marks.append("home")
		rows.append({"label": "%-24s %d season(s) · linh khí %.2f · danger %d%s" % [to.name, int(l.seasons), float(to.density), int(to.danger), (" · " + ", ".join(marks)) if not marks.is_empty() else ""], "value": l.to})
	return _pick("Travel from %s to:" % here.name, rows)


func _pick_recipe() -> String:
	var s: GameSession = session
	var sh: StatSheet = s.sheet()
	var rows: Array = []
	for r in gd.recipes():
		var plan: Dictionary = s.alchemy.find_ingredients(s.player, r)
		var state: String = io.paint("ready", "32") if plan.ok else io.paint("missing " + ", ".join(plan.missing), "2")
		rows.append({"label": "%-18s %3.0f%%  %s" % [r.name, s.alchemy.success_chance(s.player, sh, r).total, state], "value": r.id})
	return _pick("Luyện đan (one season):", rows)


func _pick_seed() -> String:
	var s: GameSession = session
	var rows: Array = []
	for h in s.field.seed_catalog(s.player.realm_index):
		rows.append({"label": "%-18s seed %3d LT · matures in %.0f y · %s" % [h.name, int(h.seed_price), float(h.mature_years), h.desc], "value": h.id})
	for it in s.db.items_of(s.player.id):
		if it.kind == "herb" and int(it.get("plot", -1)) < 0:
			rows.append({"label": "transplant %s" % s.items.describe(it), "value": it.id})
	return _pick("Plant what? (you have %d linh thạch)" % s.player.linh_thach, rows)


func _pick_item(title: String, filter: Callable) -> String:
	var s: GameSession = session
	var rows: Array = []
	for it in s.db.items_of(s.player.id):
		if filter.call(it):
			rows.append({"label": s.items.describe(it), "value": it.id})
	return _pick(title, rows)


func _pick_person() -> String:
	var s: GameSession = session
	var rows: Array = []
	for p in s.db.find("people", func(x): return x.alive and not x.get("is_player", false) and not x.get("is_beast", false) and str(x.location_id) == s.player.location_id):
		rows.append({"label": TerminalViews.person_line(s, p).substr(7), "value": p.id})
	return _pick("Talk to whom?", rows)


func _pick_market() -> String:
	var s: GameSession = session
	var place: Dictionary = s.db.get_record("places", s.player.location_id)
	if not bool(place.get("market", false)):
		io.out("No market at %s." % place.name)
		return ""
	s.market.ensure_stock(s.rng, place.id, s.year, s.player.realm_index)
	var sh: StatSheet = s.sheet()
	var rows: Array = []
	for it in s.market.stock(place.id):
		rows.append({"label": "%5d LT  %s" % [s.market.buy_price(s.player, sh, it), s.items.describe(it)], "value": it.id})
	return _pick("Buy what? (you have %d linh thạch)" % s.player.linh_thach, rows)


func _arg(args: Array, i: int, default: String) -> String:
	return str(args[i]) if args.size() > i else default


func _help(args: Array) -> void:
	var want: String = _arg(args, 0, "")
	for group in HELP:
		var rows: Array = group[1].filter(func(r): return want == "" or str(r[0]).begins_with(want))
		if rows.is_empty():
			continue
		io.out(io.paint(group[0], "1"))
		for r in rows:
			io.out("  %-38s %s" % [r[0], r[1]])


# --- New life ---------------------------------------------------------------------

func _new(args: Array) -> void:
	var seed_v: int = next_seed if next_seed != 0 else int(Time.get_unix_time_from_system()) % 1000000007
	next_seed = 0
	if args.size() > 0 and args[0] == "quick":
		var nm: String = _arg(args, 1, "Vô Danh")
		if args.size() > 2 and str(args[2]).is_valid_int():
			seed_v = int(args[2])
		_start(seed_v, {"mode": "roll", "name": nm, "gender": "male", "origin": "tan_tu"})
		return
	var nm2: Variant = io.read_line("Tên (name) [Vô Danh]: ")
	if nm2 == null:
		return
	var gender_in: Variant = io.read_line("Giới tính m/f [m]: ")
	var gender: String = "female" if str(gender_in).strip_edges().to_lower().begins_with("f") else "male"
	io.out("Xuất thân (origin):")
	var origins: Array = gd.origins()
	for i in origins.size():
		io.out("  %d) %s — %s" % [i + 1, origins[i].name, origins[i].desc])
	var o_in: Variant = io.read_line("Choose 1-%d [1]: " % origins.size())
	var oi: int = clampi(int(str(o_in)) - 1, 0, origins.size() - 1) if str(o_in).is_valid_int() else 0
	var seed_in: Variant = io.read_line("World seed [%d]: " % seed_v)
	if str(seed_in).is_valid_int():
		seed_v = int(seed_in)
	var mode_in: Variant = io.read_line("Birth mode: 1) Thiên Định — roll, achievements on   2) Tự Định — choose, casual  [1]: ")
	var spec := {"name": str(nm2).strip_edges() if str(nm2).strip_edges() != "" else "Vô Danh", "gender": gender, "origin": origins[oi].id}
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_v
	var c: Character
	if str(mode_in).strip_edges() == "2":
		c = _custom_character(spec, rng)
		if c == null:
			return
	else:
		while true:
			c = CharacterFactory.roll_player(gd, rng, spec.name, spec.gender, spec.origin)
			io.out_lines(_preview(c))
			var a: Variant = io.read_line("Accept? y = accept, r = reroll, q = cancel [y]: ")
			if a == null or str(a).strip_edges().to_lower() == "q":
				io.out("Cancelled.")
				return
			if str(a).strip_edges().to_lower() != "r":
				break
	spec["character"] = c.to_dict()
	var perk: String = _pick_perk(rng, c.birth_mode == "thien_dinh")
	if perk == "":
		io.out("Cancelled.")
		return
	spec["perk"] = perk
	_start(seed_v, spec)


## Thiên mệnh: Thiên Định picks one of the rolled offer, Tự Định any perk.
func _pick_perk(rng: RandomNumberGenerator, rolled: bool) -> String:
	var ids: Array = ProgressionEdges.roll_perk_choices(gd, rng) if rolled else ProgressionEdges.perks(gd).map(func(p): return str(p.id))
	var rows: Array = []
	for id in ids:
		var p: Dictionary = ProgressionEdges.perk(gd, id)
		var fx: PackedStringArray = []
		for e in p.get("effects", []):
			fx.append(gd.format_mod(str(e.stat), float(e.value)))
		if p.has("birth"):
			fx.append("+%d purity on every root at birth" % int(p.birth.get("purity_all", 0)))
		rows.append({"label": "%-20s %s  [%s]" % [p.name, p.desc, ", ".join(fx)], "value": id})
	var title: String = "Thiên mệnh — heaven offers three; choose one:" if rolled else "Thiên mệnh — choose one:"
	return _pick(title, rows)


## slot main <n> | slot aux1 <n> | slot aux2 <n> | slot second <n> | slot clear <slot>, where n
## is the row number shown by 'tech'.
func _slot_command(s: GameSession, args: Array) -> void:
	var name: String = _arg(args, 0, "")
	var clear: bool = name == "clear"
	if clear:
		name = _arg(args, 1, "")
	var slot: String = "aux" if name.begins_with("aux") else name
	var index: int = int(name.substr(3)) - 1 if slot == "aux" else 0
	var key: String = ""
	if not clear:
		var keys: Array = s.player.techniques.keys()
		var row: int = int(_arg(args, 1, "0")) - 1
		if row < 0 or row >= keys.size():
			io.out("Usage: slot main|aux1|aux2|second <row from 'tech'>, or slot clear <slot>.")
			return
		key = str(keys[row])
	var r: Dictionary = s.set_slot(slot, index, key)
	if bool(r.get("needs_confirm", false)):
		io.out_lines(r.lines)
		var yes: Variant = io.read_line("  Confirm? (yes/no): ")
		if str(yes) == "yes":
			r = s.set_slot(slot, index, key, true)
		else:
			return
	_r(r)


func _custom_character(spec: Dictionary, rng: RandomNumberGenerator) -> Character:
	io.out("Tự Định: set each thiên phú 1-100 (enter = 50).")
	var tp: Dictionary = {}
	for def in gd.thien_phu_defs():
		var v: Variant = io.read_line("  %s (%s): " % [def.name, def.desc])
		if v == null:
			return null
		tp[def.id] = int(v) if str(v).is_valid_int() else 50
	var purities: Dictionary = {}
	var picks: Array = []
	while true:
		io.out("Root purities 10-100, e.g. 'hoa=80 moc=60 tho=40' (elements: kim moc thuy hoa tho).")
		var p_in: Variant = io.read_line("  purities: ")
		if p_in == null:
			return null
		purities = {}
		for pair in str(p_in).split(" ", false):
			var kv: PackedStringArray = pair.split("=")
			if kv.size() == 2:
				purities[kv[0].strip_edges()] = float(kv[1])
		io.out("Variants you qualify for: phong huyet hu_khong (one or two elements), loi (hoa+kim), am (tho+thuy), hon_don (all five), quang (hoa), bang (thuy). Any you leave out never forms.")
		var b_in: Variant = io.read_line("  variant ids (blank = none): ")
		if b_in == null:
			return null
		picks = Array(str(b_in).split(" ", false))
		var err: String = LinhCan.self_made_error(gd, purities, picks)
		if err == "":
			break
		io.out(err)
	var c := CharacterFactory.custom_player(gd, rng, spec.name, spec.gender, spec.origin, tp, purities, picks)
	io.out_lines(_preview(c))
	return c


func _preview(c: Character) -> Array:
	return TerminalViews.birth_card(gd, c, io)


func _start(seed_v: int, spec: Dictionary) -> void:
	io.out("Generating the world (seed %d)..." % seed_v)
	session = GameSession.new(gd, llm)
	var r: Dictionary = session.new_game(seed_v, spec)
	io.out_lines(r.lines)
	io.out("")
	io.out_lines(TerminalViews.sheet(session, io))
	io.out("")
	io.out_lines(TerminalViews.here(session))


# --- Save / load ---------------------------------------------------------------------

func _save(args: Array) -> void:
	if session == null or session.player == null:
		io.out("Nothing to save.")
		return
	var slot: String = _arg(args, 0, "autosave")
	var err: int = store.write(slot, session.to_dict())
	io.out("Saved to %s" % store.describe_path(slot) if err == OK else "Save failed (error %d)." % err)


func _load(args: Array) -> void:
	var slot: String = _arg(args, 0, "autosave")
	var d: Variant = store.read(slot)
	if typeof(d) != TYPE_DICTIONARY:
		io.out("No save '%s'." % slot)
		return
	var s := GameSession.new(gd, llm)
	var r: Dictionary = s.load_dict(d)
	io.out_lines(r.lines)
	if r.ok:
		session = s


# --- Market ---------------------------------------------------------------------------

func _market() -> void:
	var s: GameSession = session
	var place: Dictionary = s.db.get_record("places", s.player.location_id)
	if not bool(place.get("market", false)):
		io.out("No market at %s. 'map' marks markets with M." % place.name)
		return
	s.market.ensure_stock(s.rng, place.id, s.year, s.player.realm_index)
	var sh: StatSheet = s.sheet()
	io.out("Market of %s (Mị lực adjusts prices). buy <id>, sell <id>:" % place.name)
	for it in s.market.stock(place.id):
		io.out("  %-6s %5d LT  %s" % [it.id, s.market.buy_price(s.player, sh, it), s.items.describe(it)])
	io.out("Seeds are bought with 'plant <herb id>' at home. You have %d linh thạch." % s.player.linh_thach)


# --- Database -----------------------------------------------------------------------

func _db(args: Array) -> void:
	var s: GameSession = session
	var sub: String = _arg(args, 0, "stats")
	var filter: String = " ".join(args.slice(1))
	match sub:
		"stats":
			for t in WorldDB.TABLES.keys():
				io.out("  %-8s %d" % [t, s.db.count(t)])
			var alive: int = s.db.find("people", func(p): return p.alive).size()
			io.out("  living people %d, dead %d" % [alive, s.db.count("people") - alive])
		"people":
			var rows: Array = s.db.all("people") if filter == "" else s.db.find("people", func(p): return _match(p, filter))
			for p in rows.slice(0, 60):
				io.out(TerminalViews.person_line(s, p))
			io.out("(%d shown of %d; filter by name, id, place id, sect id, or 'alive'/'dead')" % [mini(rows.size(), 60), rows.size()])
		"sects":
			for x in s.db.all("sects"):
				io.out("  %-5s %-22s %-10s %-9s members %d" % [x.id, x.name, x.alignment_name, x.status, x.members.size()])
		"places":
			io.out_lines(TerminalViews.map(s))
		"items":
			var rows2: Array = s.db.all("items") if filter == "" else s.db.find("items", func(i): return _match(i, filter))
			for it in rows2.slice(0, 60):
				io.out("  %-6s %-12s %s" % [it.id, it.get("owner_id", ""), s.items.describe(it)])
			io.out("(%d shown of %d; filter by name, kind, owner id, 'lost', 'legendary')" % [mini(rows2.size(), 60), rows2.size()])
		"events":
			var rows3: Array = s.db.all("events") if filter == "" else s.db.find("events", func(e): return WorldDB.fold(str(e.text)).contains(WorldDB.fold(filter)) or str(e.type) == filter or Array(e.people + e.places + e.items).has(filter))
			for e in rows3.slice(-60):
				io.out("  %-6s năm %3d %-18s %s" % [e.id, int(e.year), e.type, e.text])
			io.out("(%d matching)" % rows3.size())
		"show":
			io.out_lines(TerminalViews.show(s, _arg(args, 1, "")))
		_:
			io.out("db stats|people|sects|places|items|events [filter] | db show <id>")


func _match(rec: Dictionary, filter: String) -> bool:
	var f: String = WorldDB.fold(filter)
	if f == "alive":
		return bool(rec.get("alive", false))
	if f == "dead":
		return not bool(rec.get("alive", true))
	if f == "lost":
		return bool(rec.get("lost", false))
	if f == "legendary":
		return bool(rec.get("legendary", false))
	for k in ["id", "name", "location_id", "sect_id", "owner_id", "kind", "archetype"]:
		if WorldDB.fold(str(rec.get(k, ""))).contains(f):
			return true
	return false


# --- Tree -----------------------------------------------------------------------------

func _tree(args: Array) -> void:
	var s: GameSession = session
	match _arg(args, 0, ""):
		"clusters":
			io.out_lines(TerminalViews.tree_clusters(session, io))
		"mode":
			var mode: String = _arg(args, 1, "")
			if mode in ["visible", "silhouette"]:
				session.player.tree_visibility = mode
				session.sync_player()
				io.out("Tree display: %s." % mode)
			else:
				io.out("Usage: tree mode visible|silhouette")
		"":
			io.out_lines(TerminalViews.tree_summary(s, io))
		"map":
			io.out_lines(TerminalViews.tree_map(s, io))
		"targets":
			io.out_lines(TerminalViews.tree_targets(s))
		"node":
			io.out_lines(TerminalViews.tree_node(s, int(_arg(args, 1, "-1"))))
		"alloc", "open":
			var nid: String = _arg(args, 1, "") if args.size() > 1 else _pick_huyet()
			if nid != "":
				_r(s.tree_allocate(int(nid), false))
		"go", "path":
			_r(s.tree_allocate(int(_arg(args, 1, "-1")), true))
		_:
			io.out("tree | tree map | tree targets | tree node <id> | tree alloc <id> | tree go <id>")


func _pick_design() -> String:
	var s: GameSession = session
	var tier: int = s.player.realm_index
	var rows: Array = []
	var chance: float = s.refinery.success_chance(s.player, s.sheet(), tier).total
	for b in gd.artifacts_file().bases:
		var ck: Dictionary = s.refinery.check(s.player, b.id, tier)
		var state: String = io.paint("ready", "32") if ck.ok else io.paint(str(ck.reason), "2")
		rows.append({"label": "%-10s ATK %3d DEF %3d thần thức %3d · fuel %5d LT · %s" % [b.name, int(b.attack), int(b.defense), int(b.than_thuc_cost), s.refinery.fuel_cost(b.id, tier), state], "value": b.id})
	return _pick("Refine which %s? (%.0f%% success, 'explain refine')" % [gd.artifact_tier(tier).name, chance], rows)


func _pick_talisman() -> String:
	var s: GameSession = session
	var rows: Array = []
	for t in s.talismans.config().talismans:
		var ck: Dictionary = s.talismans.check(s.player, t.id)
		var state: String = io.paint("ready", "32") if ck.ok else io.paint(str(ck.reason), "2")
		rows.append({"label": "%-14s %3.0f%% · ink %d LT · %d per batch · %s · %s" % [t.name, s.talismans.success_chance(s.player, s.sheet(), t.id).total, int(t.ink_lt), int(t.yield), t.desc, state], "value": t.id})
	return _pick("Draw which talisman? (one season)", rows)


func _pick_formation() -> String:
	var s: GameSession = session
	var rows: Array = []
	for f in s.formations.config().formations:
		var lv: int = s.formations.level(s.player, f.id)
		var ck: Dictionary = s.formations.can_build(s.player, f.id)
		var cost: Dictionary = s.formations.build_cost(f.id, lv + 1)
		var state: String = io.paint("ready", "32") if ck.ok else io.paint(str(ck.reason), "2")
		rows.append({"label": "%-15s level %d → %d · %d LT + %d material(s) · %s" % [f.name, lv, lv + 1, int(cost.lt), int(cost.materials), state], "value": f.id})
	return _pick("Raise which formation?", rows)


func _pick_huyet() -> String:
	var s: GameSession = session
	var rows: Array = []
	for nid in s.tree.frontier(s.player):
		var nd: Dictionary = s.tree.node(nid)
		var ok: Dictionary = s.tree.can_allocate(s.player, nid, gd)
		var why: String = "" if ok.ok or s.player.tree_points <= 0 else io.paint("  (" + str(ok.reason) + ")", "2")
		rows.append({"label": "#%-4d %-24s %-14s %s%s" % [nid, nd.name, nd.kind, s.tree.describe_mods(nid, s.player.linh_can, gd), why], "value": str(nid)})
	return _pick("Open which huyệt? (%d point(s))" % s.player.tree_points, rows)


# --- LLM ------------------------------------------------------------------------------

func _llm(args: Array) -> void:
	match _arg(args, 0, ""):
		"":
			io.out(llm.status_line())
		"on", "off":
			llm.enabled = args[0] == "on"
			io.out(llm.status_line() + "  (this run only)")
		"key":
			llm.set_key(_arg(args, 1, ""))
			io.out("Key stored in %s. %s" % [ProjectSettings.globalize_path("user://llm_config.json"), llm.status_line()])
		"url":
			llm.set_endpoint(_arg(args, 1, llm.client.base_url), _arg(args, 2, ""))
			io.out(llm.status_line())
		"lang":
			llm.language = _arg(args, 1, "vi")
			io.out(llm.status_line() + "  (this run only; set \"language\" in services_llm.json to change the default)")
		"test":
			io.out("Calling %s ..." % llm.client.base_url)
			var r: Dictionary = llm.json_call("Reply with a json object {\"ok\": true, \"greeting\": string} greeting a cultivator in %s." % llm.language, {"ping": 1})
			io.out("ok=%s in %d ms: %s %s" % [str(r.ok), int(r.ms), JSON.stringify(r.data) if r.ok else "", r.error])
		"last":
			io.out("--- request ---\n%s\n--- response ---\n%s\n--- error ---\n%s" % [llm.last_request.substr(0, 4000), llm.last_response.substr(0, 4000), llm.last_error])
		_:
			io.out("llm | llm on|off | llm key <key> | llm url <base> [model] | llm lang vi|en | llm test | llm last")


# --- Debug -----------------------------------------------------------------------------

func _debug(args: Array) -> void:
	var s: GameSession = session
	var c: Character = s.player
	match _arg(args, 0, ""):
		"event":
			_r({"lines": s.start_event(_arg(args, 1, ""))})
		"templates":
			for t in gd.event_templates().templates:
				io.out("  %-22s %s (places: %s)" % [t.id, t.title, ", ".join(t.get("place_types", []))])
		"tuvi":
			var res: Dictionary = CultivationRules.add_tu_vi(c, gd, float(_arg(args, 1, "100")))
			io.out("tu vi added; +%d stages; now %s %.0f" % [res.stages, gd.realm_label(c.realm_index, c.stage), c.tu_vi])
		"lt":
			c.linh_thach += int(_arg(args, 1, "100"))
			io.out("Linh thạch %d." % c.linh_thach)
		"herb":
			var h: Dictionary = s.items.herb(_arg(args, 1, "ngung_khi_thao"), float(_arg(args, 2, "1")))
			h["owner_id"] = c.id
			io.out("Gave %s [%s]." % [s.items.describe(h), s.db.add("items", h)])
		"tp":
			c.tree_points += int(_arg(args, 1, "5"))
			io.out("Kinh Mạch points: %d." % c.tree_points)
		"heal":
			c.vitality = 1.0
			c.dan_doc = 0.0
			c.tam_ma = 0.0
			io.out("Healed.")
		"item":
			var kind: String = _arg(args, 1, "artifact")
			var grade: int = int(_arg(args, 2, "2"))
			var it: Dictionary = s.items.cong_phap(s.rng, grade) if kind == "cong_phap" else s.items.artifact(s.rng, c.realm_index, grade)
			it["owner_id"] = c.id
			io.out("Gave %s [%s]." % [s.items.describe(it), s.db.add("items", it)])
		_:
			io.out("debug event [id] | templates | tuvi <n> | lt <n> | herb <id> <age> | tp <n> | heal | item artifact|cong_phap [grade]")
	s.sync_player()


func _buildgen(args: Array) -> void:
	var s: GameSession = session
	var arch: String = _arg(args, 0, "kiem_tu")
	if gd.archetype(arch).is_empty():
		io.out("Archetypes: %s" % ", ".join(gd.world_gen().archetypes.map(func(a): return a.id)))
		return
	var realm: int = clampi(int(_arg(args, 1, "1")), 0, gd.realms().size() - 1)
	var pid: String = s.builds.create_person(s.rng, {"realm_index": realm, "archetype": arch, "location_id": s.player.location_id, "created_by": "debug"})
	var c := Character.from_dict(s.db.get_record("people", pid))
	io.out_lines(TerminalViews.show(s, pid))
	var sh := StatSheet.build(c, gd, s.db, s.tree)
	io.out("Kinh Mạch (%d huyệt): %s" % [c.tree_nodes.size(), ", ".join(c.tree_nodes.filter(func(n): return s.tree.node(n).kind in ["notable", "keystone", "bridge_notable"]).map(func(n): return s.tree.node(n).name))])
	io.out_lines(CombatPower.compute(c, gd, s.db, sh).lines)
	io.out("(registered as %s at your location; 'talk %s' works)" % [pid, pid])
