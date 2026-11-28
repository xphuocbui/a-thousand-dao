class_name GameSession
extends RefCounted
## One life: owns the clock, the player, the world database and every gameplay service,
## and exposes each player action as a method that returns {ok, lines, ...}.
## Frontends (the debug terminal now, a Godot UI later) only call this API and render
## the returned lines; no gameplay rule lives in a frontend.
## Design: design/gdd/game-concept.md (core loop: seasons, actions, events, breakthroughs).
##
## Time model: one turn = one season (0.25 year). Every action that costs time passes
## seasons through [method _pass_season], which ages herbs, the player and the world.
##
## Usage:
## [codeblock]
## var s := GameSession.new(GameData.load_from(), LlmService.new(gd))
## s.new_game(42, {"mode": "roll", "name": "Lâm Vô Danh", "gender": "male", "origin": "tan_tu"})
## var r: Dictionary = s.cultivate(4)
## for line in r.lines: print(line)
## if s.has_pending_event(): s.choose(0)
## [/codeblock]

signal life_ended(summary: Dictionary)
## A great breakthrough succeeded (player only, Realms rule 9). [param realm_index] is the new realm.
signal breakthrough_succeeded(realm_index: int)

const SAVE_VERSION := 3
## Save versions load_dict can read. 1 is the old stage ladder, which migrates. 2 is the
## 300-level ladder, which is refused (canh-gioi.md Edge Cases, Saves).
const SAVE_VERSIONS_READ := [1, 3]
const _EventEngine := preload("res://src/gameplay/events/event_engine.gd")
const _EventStore := preload("res://src/gameplay/events/event_store.gd")
const _EventBudget := preload("res://src/gameplay/events/event_budget.gd")
const _QuestBoard := preload("res://src/gameplay/quests/quest_board.gd")
const _QuestService := preload("res://src/gameplay/quests/quest_service.gd")

var gd: GameData
var tree: DaoDoTree
## Set by [method load_dict] when the loaded player's tree was migrated from the generated map (rule 19).
var _player_migrated: bool = false
var llm: LlmService
var db: WorldDB
var rng := RandomNumberGenerator.new()

var items: ItemFactory
var builds: BuildGenerator
var field: HerbField
var alchemy: Alchemy
var refinery: Refinery
var talismans: Talismans
var beasts: BeastKeeper
var formations: Formations
var market: Market
var ticker: WorldTicker
## Sects & Missions, the member's side (standing, contribution, joining, promotion, leaving).
var sect_members: SectMembers
## Power Rankings (design/gdd/power-rankings.md; ADR-0003), behind combat_rankings.json "enabled".
var ratings: RatingService
## Runs each season's rating batch on a background thread while the season is played (ADR-0003 decision 6); false
## runs it, blocking, when the season ends (tools and tests). Either way the batch completes, so results do not
## depend on how fast the season was played.
var ratings_background: bool = true
## {season, panels, panel_fights, pair_fights} of the last applied season batch (the terminal's 'rankings').
var last_rating_batch: Dictionary = {}
## The batch planned at this season's start (running in the background through this season and the next).
var _rating_batch: SeasonBatch
## The batch planned at the previous season's start: it applies at the end of this season (power-rankings.md rule 13,
## one season late, user decision 2026-11-22), so End turn waits only if it is still running a whole season later.
var _rating_prev: SeasonBatch
## A multi-season command in progress (user decision 2026-11-14): the seasons that begin and end inside it share one
## season_fight_budget, split evenly in order, so a command waits for about one season's batch however many seasons
## it passes. _bulk_left counts the command's seasons still to pass; -1 outside such a command.
var _bulk_left: int = -1
var _bulk_share: int = 0
var templates: EventTemplateSource
var validator: EventValidator
var resolver: EventResolver
## Event Engine (#23) orchestrator: pulses, hooks, follow-ups, stories, NPC off-screen events (no back-ref to self).
var event_engine: _EventEngine
## Template Quests (#31) standing town/sect boards (no back-ref to self).
var quest_board: _QuestBoard
## Template Quests (#31) lifecycle, stages, payouts, and Event Engine story bridge (no back-ref to self).
var quests: _QuestService
var narrator: Narrator
## NPC Interaction & Dialogue (#30): verbs, loans, spars, and voiced replies (no back-reference to self).
var interactions: InteractionService
## Share of the current season's focus spent on timed interactions (GDD Rule 4, 0.0..1.0).
var season_time_used: float = 0.0

var seed_value: int = 0
var year: int = 0
var season: int = 0
var player: Character
## Normalized event waiting for a choice ({} when none).
var pending_event: Dictionary = {}
## {source, warnings, llm_error} of the pending event.
var pending_meta: Dictionary = {}
## Post-duel cultivator Mercy decision waiting for spare/kill ({event, choice_index, target_id, title}; {} when none).
var pending_mercy: Dictionary = {}
var life_over: bool = false
## Set when debug commands touched this life: it can no longer earn achievements.
var cheated: bool = false
## The main character's edge (thiên mệnh, starting items, cơ duyên); false = baseline life.
var edge: bool = true
## Realm index -> cơ duyên events offered in that realm.
var co_duyen_used: Dictionary = {}
## Events of the running action (a breakthrough, the end of the life), handed back by [method run] in its result
## (ADR-0006 decision 7). Not saved.
var _events: Array = []
var epitaph_text: String = ""
## What the player knows of the map: known tiles and places, clues, finds (Travel & Map rule 14; null in an old world).
var knowledge: MapKnowledge = null
## The new game's chosen start place (a continent place id or name; "" = picked), read by _place_player.
var _start_home: String = ""
## Lines from the yearly tick (upkeep, stipend) shown with the next action's result.
var _notices: Array = []

# --- Heavenly Tribulation (#22) ---------------------------------------------------
var _tribulation_enabled: Variant = null
## Playthrough Heavenly Tribulation toggle (fixed at new_game; default ON from tribulation_rules.json).
var tribulation_enabled: bool:
	get:
		if _tribulation_enabled == null:
			return TribulationRules.is_enabled(gd) if gd != null else true
		return bool(_tribulation_enabled)
	set(v):
		_tribulation_enabled = bool(v)
## Pending survival reward choices until claimed ({step_id, choices, buff}); empty otherwise.
var pending_tribulation_reward: Dictionary = {}
## Transient last tribulation result (wave summaries & Combat logs for UI/Terminal replay; not saved).
var last_tribulation: Dictionary = {}
## Optional injected fight callable for deterministic tribulation integration tests (empty = real CombatService).
var tribulation_fight_fn: Callable = Callable()

# --- Codex & Karmic Carryover (#12) -----------------------------------------------
## Profile-level Codex store (defaults to pure in-memory "" unless configured; no cyclic back-reference).
var codex_store: CodexStore
## Pure domain Codex rules over GameData + codex_store (no cyclic back-reference).
var codex: Codex
var _playthrough_mode: String = KarmicRules.MODE_ONE_LIFE
## Playthrough mode ("one_life" | "continue"), fixed at new_game and immutable thereafter (AC-CK-01).
var playthrough_mode: String:
	get:
		return str(get_meta("playthrough_mode")) if has_meta("playthrough_mode") else _playthrough_mode
	set(v):
		_playthrough_mode = v
		if has_meta("playthrough_mode"):
			remove_meta("playthrough_mode")
## Stable identifier for this playthrough (used for AC-CK-21 death_reloaded detection).
var playthrough_id: String = ""
## Playthrough lifecycle status ("active" | "succession" | "ended").
var playthrough_status: String = KarmicRules.STATUS_ACTIVE
## Unspent karma accumulated across deaths in this Continue playthrough (always 0 at start, AC-CK-10).
var karma: int = 0
## Count of Codex entries raised to "known" for the first time during the current life (Formula A).
var k_new_this_life: int = 0
## Realm index at which the current life began (0 for new/reborn, heir's realm for heir lives).
var start_realm_this_life: int = 0
## True when the current life began via heir succession (Rule 6: realm karma only if advancing past start_realm).
var is_heir_life: bool = false
var _death_reloaded: bool = false
## True when loading a One Life pre-death save after a prior death of the same playthrough_id (Rule 11, AC-CK-21).
var death_reloaded: bool:
	get:
		return bool(get_meta("death_reloaded")) if has_meta("death_reloaded") else _death_reloaded
	set(v):
		_death_reloaded = v
		if has_meta("death_reloaded"):
			remove_meta("death_reloaded")
## Living partners from the dead life carried into a reborn life for past-life recognition events (AC-CK-22).
var past_ties: Array = []
## Number of past-life recognition events fired in this reborn life (capped at recognition_max = 2, AC-CK-22).
var recognition_used: int = 0
## Pre-death snapshot fields for Continue-mode succession (persisted if saved during succession).
var _last_death_player_id: String = ""
var _last_death_killer: String = ""
var _last_death_disciples: Array = []
var _last_death_sect_id: String = ""
var _last_death_region_id: String = ""
var _last_death_surname: String = ""
var _last_death_karma_earned: int = 0


func _init(game_data: GameData, llm_service: LlmService, dao_do_tree: DaoDoTree = null, codex_inst: Variant = null) -> void:
	gd = game_data
	llm = llm_service
	tree = dao_do_tree if dao_do_tree != null else DaoDoTree.load_map(gd)
	if codex_inst is Codex:
		codex = codex_inst as Codex
		codex_store = codex.store
	elif codex_inst is CodexStore:
		codex_store = codex_inst as CodexStore
		codex = Codex.new(gd, codex_store)
	else:
		codex_store = CodexStore.new("")
		codex = Codex.new(gd, codex_store)


# --- Life cycle -------------------------------------------------------------------

## Generates a new world and player. [param spec]: mode ("roll" | "custom"), name, gender,
## origin, start (an element or variant id the root holds; else the strongest, Đạo Đồ rule 3), and for custom:
## thien_phu {id: value}, purities {element: purity}, variants [ids].
## Job. One at a time, off the main thread (ADR-0006).
func new_game(seed_v: int, spec: Dictionary) -> Dictionary:
	_finish_ratings(false)
	seed_value = seed_v
	rng.seed = seed_v
	# World Generation & History: the authored continent and its history (WorldBuilder); the old random generator
	# only when the authored data is missing
	if gd.registry.has_file(WorldBuilder.HISTORY_FILE) and gd.registry.has_file(ContinentData.DATA_FILE):
		var builder := WorldBuilder.new(gd, tree)
		db = builder.generate(rng, str(seed_v))
		year = builder.current_year
		if not builder.errors.is_empty():
			push_error("World build: %s" % "; ".join(builder.errors))
	else:
		var gen := WorldGenerator.new(gd, tree)
		db = gen.generate(rng)
		year = gen.current_year
	# The player and the play that follows draw from their own stream keyed on the seed, so a change to how much the
	# world's build draws does not change the character a seed rolls (paired balance runs, plan world-economy B).
	rng.seed = RngUtils.stable_hash("player:%d" % seed_v)
	season = 0
	_wire()
	life_over = false
	cheated = false
	season_time_used = 0.0
	edge = bool(spec.get("edge", true))
	co_duyen_used = {}
	pending_event = {}
	pending_meta = {}
	pending_mercy = {}
	epitaph_text = ""
	pending_tribulation_reward = {}
	last_tribulation = {}
	var name: String = str(spec.get("name", "Vô Danh"))
	var gender: String = str(spec.get("gender", "male"))
	var origin: String = str(spec.get("origin", "tan_tu"))
	tribulation_enabled = bool(spec.get("tribulation_enabled", TribulationRules.is_enabled(gd)))
	playthrough_mode = KarmicRules.normalize_mode(str(spec.get("playthrough_mode", KarmicRules.MODE_ONE_LIFE)))
	playthrough_id = str(spec.get("playthrough_id", "pt_%d_%d" % [seed_v, RngUtils.stable_hash("%s:%d:%s:%s" % [name, seed_v, playthrough_mode, origin])]))
	playthrough_status = KarmicRules.STATUS_ACTIVE
	karma = KarmicRules.starting_karma()
	k_new_this_life = 0
	start_realm_this_life = 0
	is_heir_life = false
	death_reloaded = false
	past_ties = []
	recognition_used = 0
	_last_death_player_id = ""
	_last_death_killer = ""
	_last_death_disciples = []
	_last_death_sect_id = ""
	_last_death_region_id = ""
	_last_death_surname = ""
	_last_death_karma_earned = 0
	_start_home = str(spec.get("home", ""))
	if spec.has("character"):
		# A character already created and approved in a frontend (e.g. the rerollable
		# preview in the terminal's character creation).
		player = Character.from_dict(spec.character)
		player.id = ""
	elif str(spec.get("mode", "roll")) == "custom":
		player = CharacterFactory.custom_player(gd, rng, name, gender, origin, spec.get("thien_phu", {}), spec.get("purities", {}), spec.get("variants", []))
	else:
		player = CharacterFactory.roll_player(gd, rng, name, gender, origin)
	if edge:
		_grant_edge(str(spec.get("perk", "")))
	_choose_start(str(spec.get("start", "")))
	player.id = db.add("people", player.to_dict())
	_place_player()
	_teach_starter_diagram()
	knowledge = MapKnowledge.start(gd, db, player) if db.has_record("world", "w_meta") else null
	if edge:
		for si in ProgressionEdges.config(gd).player.starting_items:
			if si.has("talisman"):
				var tal: Dictionary = items.talisman(str(si.talisman), int(si.qty))
				tal["owner_id"] = player.id
				db.add("items", tal)
	sync_player()
	_codex_note_player_variants()
	var rated: Dictionary = {}
	if ratings_on():   # Power Rankings rule 16, while the game loads
		rated = ratings.worldgen(seed_value, player, sheet(), player.location_id)
		_start_ratings()
	var lines: Array = ["A new world: %d regions, %d places, %d sects, %d people, %d recorded events (%s năm %d)." % [
		db.count("regions"), db.count("places"), db.count("sects"), db.count("people"), db.count("events"), gd.world_gen().calendar_name, year]]
	lines.append("%s is born: %s" % [player.name, player.linh_can.describe(gd)])
	lines.append(_start_line())
	if not rated.is_empty():
		var pre_cast: int = int(rated.get("precomputed_cast", 0))
		if pre_cast > 0:
			lines.append("Power Rankings: the player's panel (%d fights), %d precomputed cast ratings, and %d coarse panels (%d fights) rated at load." % [
				int(rated.player_fights), pre_cast, int(rated.coarse_panels), int(rated.fights)])
		else:
			lines.append("Power Rankings: the player's panel (%d fights) and %d coarse panels (%d fights) rated at load." % [
				int(rated.player_fights), int(rated.coarse_panels), int(rated.fights)])
	return {"ok": true, "lines": lines}


## Gives the thiên mệnh perk: the one chosen in the frontend, else a random one of the offer.
func _grant_edge(perk_id: String) -> void:
	var pid: String = perk_id
	if ProgressionEdges.perk(gd, pid).is_empty():
		pid = str(ProgressionEdges.roll_perk_choices(gd, rng)[0])
	ProgressionEdges.apply_birth(player, gd, pid)


## Event context with the session facts the rules need (edge, cơ duyên left this realm, past-life recognition).
## Internal: a frontend never calls it (ADR-0006 decision 2).
func event_context() -> Dictionary:
	var per: int = ProgressionEdges.co_duyen_limit(gd, player.realm_index)
	var left: int = per - int(co_duyen_used.get(player.realm_index, 0)) if edge else 0
	var rec_max: int = KarmicRules.recognition_max(gd)
	var rec_left: int = maxi(0, rec_max - recognition_used)
	return EventContext.build(player, gd, db, sheet(), year, season, llm.language, {
		"edge": edge,
		"co_duyen_left": left,
		"past_ties": past_ties,
		"recognition_left": rec_left,
	})


## Rebuilds services around the current database (after new_game or load).
func _wire() -> void:
	items = ItemFactory.new(gd)
	builds = BuildGenerator.new(gd, tree, db)
	field = HerbField.new(gd, db, items)
	alchemy = Alchemy.new(gd, db, items)
	refinery = Refinery.new(gd, db, items)
	talismans = Talismans.new(gd, db, items)
	beasts = BeastKeeper.new(gd, db)
	formations = Formations.new(gd, db)
	market = Market.new(gd, db, items)
	ticker = WorldTicker.new(gd, db, builds)
	sect_members = SectMembers.new(gd, db)
	ratings = RatingService.new(gd, db)
	ratings.sheet_fn = builds.sheet_of
	ticker.ratings = ratings
	templates = EventTemplateSource.new(gd, db, builds)
	validator = EventValidator.new(gd, db, builds)
	resolver = EventResolver.new(gd, db, builds, items)
	resolver.ratings = ratings
	resolver.rating_clock = _rating_clock   # a method, not a lambda: a lambda capturing self would cycle and leak
	resolver.kill_npc_fn = _kill_npc_from_event
	event_engine = _EventEngine.new(gd, db, builds, templates, validator, resolver)
	event_engine.ratings = ratings
	ticker.event_engine = event_engine
	quest_board = _QuestBoard.new(gd, db, builds)
	quests = _QuestService.new(gd, db, builds, items, event_engine, quest_board)
	narrator = Narrator.new(gd, db, llm, templates, validator)
	interactions = InteractionService.new(gd, db, builds, items, market, sect_members, resolver, templates, validator, ratings, quests)


func _place_player() -> void:
	var o: Dictionary = gd.origin(player.origin)
	var home: Dictionary = _origin_home(player.origin)
	if not home.is_empty() and bool(o.get("sect", false)):
		var seat_sect: Dictionary = db.get_record("sects", str(home.get("sect_id", "")))
		if not seat_sect.is_empty():
			player.sect_id = seat_sect.id
			player.sect_rank = str(gd.session().sect.join_rank)
			seat_sect.members.append(player.id)
			sect_members.record(str(seat_sect.id), player.id)
	elif bool(o.get("sect", false)):
		var sects: Array = db.find("sects", func(s): return s.status == "active")
		if not sects.is_empty():
			var s: Dictionary = RngUtils.pick(rng, sects)
			player.sect_id = s.id
			player.sect_rank = str(gd.session().sect.join_rank)
			s.members.append(player.id)
			sect_members.record(str(s.id), player.id)
			home = db.get_record("places", s.hq_place_id)
	if home.is_empty():
		var types: Array = gd.session().home_place_types
		var towns: Array = db.find("places", func(p): return types.has(p.type))
		home = RngUtils.pick(rng, towns) if not towns.is_empty() else RngUtils.pick(rng, db.all("places"))
	player.home_id = home.id
	player.location_id = home.id
	start_residence()
	if player.origin == "gia_toc":
		_clan_family(home)
	var cp: Dictionary = items.cong_phap(rng, gd.cong_phap_tier_rank(str(o.get("cong_phap_tier", "hoang"))), [_starting_element()])
	cp["owner_id"] = player.id
	db.add("items", cp)
	CongPhap.learn(player, cp)
	player.main_tech = str(cp.tech_id)
	var province: Array = db.find("places", func(p): return bool(p.get("market", false)) and p.get("region_id", "") == home.get("region_id", ""))
	if province.is_empty():
		province = db.find("places", func(p): return bool(p.get("market", false)))
	if not province.is_empty():
		market.stock_guaranteed(province[0].id)
	var plot: int = 0
	for h in o.get("starting_herbs", []):
		for k in int(h.qty):
			var herb: Dictionary = items.herb(str(h.herb), float(h.age))
			herb["owner_id"] = player.id
			herb["plot"] = plot
			plot += 1
			db.add("items", herb)
	_log("player_born", {"a": player.id, "place": home.id})
	if player.sect_id != "":
		_log("player_joined_sect", {"a": player.id, "s1": player.sect_id})


## The strongest base element, ties in cycle order (cong-phap.md Edge Cases).
## World Generation rule 12 and Travel & Map rule 14: on the continent, the origin's start place comes from the
## approved home lists (world_continent.json origin_homes: a sect seat, a cultivator market or a clan town), the
## spec's "home" (a continent place id or name) when it is one of them, else a pick by the game's stream. {} in a
## world without continent places (an old generated world).
func _origin_home(origin_id: String) -> Dictionary:
	var homes: Array = gd.file(ContinentData.DATA_FILE).get("origin_homes", {}).get(origin_id, [])
	var places: Array = []
	for cid in homes:
		var found: Array = db.find("places", func(p): return int(p.get("continent_id", -1)) == int(cid))
		if not found.is_empty():
			places.append(found[0])
	if places.is_empty():
		return {}
	var want: String = str(_start_home)
	for p in places:
		if want != "" and (str(p.continent_id) == want or str(p.name) == want):
			return p
	return RngUtils.pick(rng, places)


func _starting_element() -> String:
	return player.linh_can.strongest_in_cycle(gd)


## Writes the live player object back to its people record.
## Internal: a frontend never calls it (ADR-0006 decision 2).
func sync_player() -> void:
	if player == null or db == null:
		return
	var rec: Dictionary = player.to_dict()
	var old: Dictionary = db.get_record("people", player.id)
	rec["created_by"] = "player"
	if builds != null:
		rec["power"] = builds.power_of(player)
	if old.has("death_year"):
		rec["death_year"] = old.death_year
	if old.has("cast_key"):
		rec["cast_key"] = old.cast_key
	db.put("people", rec)


## Fresh stat sheet for the player.
## Read-only. Never changes the world (ADR-0006 decision 1).
func sheet() -> StatSheet:
	var sh := StatSheet.build(player, gd, db, tree)
	if edge:
		ProgressionEdges.add_protagonist_mods(player, gd, sh)
	return sh


## "Năm 312, Thu" style clock label.
## Read-only. Never changes the world (ADR-0006 decision 1).
func clock_label() -> String:
	var names: Array = gd.world_gen().season_names
	return "%s năm %d, %s" % [gd.world_gen().calendar_name, year, names[season]]


## Absolute season counter (used for once-per-season limits).
## Read-only. Never changes the world (ADR-0006 decision 1).
func season_index() -> int:
	return year * int(gd.cultivation_rules().seasons_per_year) + season


## True while an event waits for a choice.
## Read-only. Never changes the world (ADR-0006 decision 1).
func has_pending_event() -> bool:
	return not pending_event.is_empty()


## True while a post-duel cultivator Mercy decision waits for spare/kill (Event Engine Rule 17, AC-EV-30).
## Read-only. Never changes the world (ADR-0006 decision 1).
func has_pending_mercy() -> bool:
	return not pending_mercy.is_empty()


# --- Time ---------------------------------------------------------------------------

func _guard(needs_time: bool) -> Dictionary:
	if db == null or player == null:
		return {"ok": false, "lines": ["No game in progress. Use 'new'."]}
	if life_over:
		return {"ok": false, "lines": ["This life has ended. Use 'new' to begin another."]}
	if needs_time and has_pending_event():
		return {"ok": false, "lines": ["An event is waiting: '%s'. Use 'event' to read it and 'choose <n>'." % str(pending_event.get("title", "event"))]}
	if needs_time and has_pending_mercy():
		return {"ok": false, "lines": ["An event is waiting: '%s' (Mercy decision). Use 'choose_mercy' to spare or kill." % str(pending_mercy.get("title", "duel"))]}
	return {"ok": true, "lines": []}


## Session extras passed to [EventEngine] pulses, hooks, and queue drains (no cyclic ref to self).
func _event_extras(extra: Dictionary = {}) -> Dictionary:
	var per: int = ProgressionEdges.co_duyen_limit(gd, player.realm_index) if player != null else 0
	var left: int = per - int(co_duyen_used.get(player.realm_index, 0)) if (edge and player != null) else 0
	var rec_max: int = KarmicRules.recognition_max(gd)
	var rec_left: int = maxi(0, rec_max - recognition_used)
	var out := {
		"year": year,
		"season": season,
		"language": llm.language if llm != null else "vi",
		"edge": edge,
		"co_duyen_left": left,
		"past_ties": past_ties,
		"recognition_left": rec_left,
	}
	for k in extra.keys():
		out[k] = extra[k]
	return out


## Activates a normalized event returned by [EventEngine] as [member pending_event] and returns its banner lines.
func _activate_engine_event(ev: Dictionary, extra_meta: Dictionary = {}) -> Array:
	if ev.is_empty():
		return []
	pending_event = ev
	pending_meta = {"source": str(ev.get("source", "")), "warnings": Array(ev.get("_warnings", [])), "llm_error": ""}
	for k in extra_meta.keys():
		pending_meta[k] = extra_meta[k]
	if _is_co_duyen(pending_event):
		co_duyen_used[player.realm_index] = int(co_duyen_used.get(player.realm_index, 0)) + 1
		_log("player_co_duyen", {"a": player.id, "place": player.location_id})
	if _is_past_life_event(pending_event):
		recognition_used += 1
	return ["", "*** EVENT: %s ***  (type 'event' to read, 'choose <n>' to act)" % str(pending_event.get("title", ""))]


## Raises an [EventEngine] hook; if an event fires and none is waiting, activates it and returns banner lines.
func _raise_event_hook(hook_id: String, payload: Dictionary = {}) -> Array:
	if event_engine == null or player == null or life_over:
		return []
	var res: Dictionary = event_engine.raise_hook(hook_id, player, sheet(), rng, _event_extras(payload))
	if not bool(res.get("ok", false)):
		return []
	var ev: Dictionary = Dictionary(res.get("event", {}))
	if ev.is_empty() or has_pending_event() or has_pending_mercy():
		return []
	return _activate_engine_event(ev, {"hook": hook_id})


## Detects cycled secret realm transitions after [method WorldTicker.tick], emitting [code]on_secret_realm[/code]
## and enforcing AC-EV-45 (closing event when player is inside a closing secret realm, else fallback move to gate).
## Opened/announced phases are gated on player relevance (known place or same region) and enqueued via
## [code]queue_only[/code] so [method _maybe_event] drains them on interactive actions rather than blocking mid-season.
func _check_secret_realm_transitions(realm_was_open: Dictionary) -> void:
	if db == null or player == null or life_over:
		return
	var meta_seed: String = str(db.get_record("world", "w_meta").get("seed", ""))
	var abs_s: int = MapChange.abs_season(year, season)
	var player_place: Dictionary = db.get_record("places", player.location_id)
	var player_region: String = str(player_place.get("region_id", ""))
	for p in db.all("places"):
		if not p.has("cycle"):
			continue
		var pid: String = str(p.id)
		var was_open: bool = bool(realm_was_open.get(pid, false))
		var now_open: bool = bool(p.get("open", false))
		var st: Dictionary = MapChange.realm_state(p, abs_s, meta_seed)
		if not was_open and now_open:
			if _secret_realm_relevant_to_player(p, pid, player_region):
				_raise_event_hook("on_secret_realm", {
					"secret_realm_phase": "opened",
					"secret_realm_id": pid,
					"secret_realm_name": str(p.get("name", pid)),
					"secret_realm_slot": str(p.get("slot", "")),
					"queue_only": true,
				})
		elif was_open and not now_open:
			if player.location_id == pid:
				var cbanner: Array = _raise_event_hook("on_secret_realm", {
					"secret_realm_phase": "closing",
					"secret_realm_id": pid,
					"secret_realm_name": str(p.get("name", pid)),
					"secret_realm_slot": str(p.get("slot", "")),
					"chance_override": 1.0,
				})
				if not cbanner.is_empty():
					for l in cbanner:
						_notices.append(str(l))
				else:
					var gate_id: String = _secret_realm_gate(p)
					if gate_id != "" and gate_id != pid:
						player.location_id = gate_id
						for b in beasts.owned(player):
							b["location_id"] = gate_id
						var gname: String = str(db.get_record("places", gate_id).get("name", gate_id))
						_notices.append("  %s closes behind you; you are cast out to %s." % [str(p.get("name", pid)), gname])
		elif not now_open and int(st.get("next_open_in", 99)) == int(Dictionary(p.get("cycle", {})).get("rumour_lead", 4)):
			if _secret_realm_relevant_to_player(p, pid, player_region):
				_raise_event_hook("on_secret_realm", {
					"secret_realm_phase": "announced",
					"secret_realm_id": pid,
					"secret_realm_name": str(p.get("name", pid)),
					"secret_realm_slot": str(p.get("slot", "")),
					"queue_only": true,
				})


## True when a cycled secret realm's opening/announcement is relevant to the player
## (either already known on their map or located in their current region).
func _secret_realm_relevant_to_player(place_rec: Dictionary, pid: String, player_region: String) -> bool:
	if knowledge != null and knowledge.knows_place(pid):
		return true
	var p_region: String = str(place_rec.get("region_id", ""))
	return player_region != "" and p_region == player_region


## Fallback gate place when a player is expelled from a closing secret realm (AC-EV-45).
func _secret_realm_gate(realm_place: Dictionary) -> String:
	var pid: String = str(realm_place.get("id", ""))
	for link in Array(realm_place.get("links", [])):
		var lid: String = str(link.get("to", "")) if link is Dictionary else str(link)
		if lid != "" and lid != pid and db.has_record("places", lid):
			return lid
	var reg: String = str(realm_place.get("region_id", ""))
	for p in db.all("places"):
		if str(p.id) != pid and not p.has("cycle") and not bool(p.get("hidden", false)) and str(p.get("region_id", "")) == reg:
			return str(p.id)
	if player != null and player.home_id != "" and player.home_id != pid and db.has_record("places", player.home_id):
		return player.home_id
	for p in db.all("places"):
		if str(p.id) != pid and not p.has("cycle"):
			return str(p.id)
	return ""


## Provinces rule 9 (provinces-runtime Stage 8): the player funds the next level (or the repair) of building
## [param kind] in province [param province_id] for their sect. It is the sect's own candidate (price at its track's
## free level, slot, one order of a kind at a time); the player pays it, the order is marked funded_by the player, and
## it earns contribution and standing as a mission of that cash would.
## Action. Returns {ok, lines, ...}; a frontend calls it through run() (ADR-0006).
func fund_building(province_id: String, kind: String) -> Dictionary:
	var g: Dictionary = _guard(false)
	if not g.ok:
		return g
	if player.sect_id == "" or not db.has_record("sects", player.sect_id):
		return {"ok": false, "lines": ["Province buildings are funded through a sect, and you belong to none."]}
	var sect: Dictionary = db.get_record("sects", player.sect_id)
	var cands: Array = SectWorks.candidates(gd, db, sect).filter(func(c): return str(c.province) == province_id and str(c.kind) == kind)
	var kname: String = str(ProvinceBuildings.kind(gd, kind).get("name", kind))
	if cands.is_empty():
		return {"ok": false, "lines": ["%s cannot order a %s there now: not a province it pays for, no free slot, nothing it would gain, or one already building." % [str(sect.name), kname]]}
	var c: Dictionary = cands[0]
	var cost: int = int(ceil(float(c.cost)))
	if player.linh_thach < cost:
		return {"ok": false, "lines": ["Level %d of the %s costs %d linh thạch; you have %d." % [int(c.level), kname, cost, player.linh_thach]]}
	MoneyLedger.player_pay(db, player, "", cost, "province_building")
	var v: Dictionary = SectWorks.place_order(gd, db, c, player.id)
	var rw: Dictionary = sect_members.mission_reward(player, cost)
	_log("player_fund_building", {"a": player.id})
	return {"ok": true, "lines": ["You fund %s %d of the %s in %s (%d linh thạch, %d season(s) to build): +%d contribution with %s." % [
		"the repair of level" if bool(c.get("repair", false)) else "level", int(c.level), kname, str(v.get("name", v.id)), cost,
		ProvinceBuildings.build_seasons(gd, kind, int(c.level)), int(rw.contribution), str(sect.name)]]}


## Passes one season. [param mode]: "cultivate", "closed_door" or "" (time passes only).
## Returns {tu_vi, stages, points, news: [event ids], died}.
func _pass_season(mode: String) -> Dictionary:
	var sh: StatSheet = sheet()
	var out := {"tu_vi": 0.0, "stages": 0, "points": 0, "news": [], "died": false}
	var yield_share: float = InteractionRules.focus_yield_share(season_time_used)
	var cultivating: bool = mode == "cultivate" or mode == "closed_door"
	out["techniques"] = CongPhap.season_tick(player, gd, sh.effective("ngo_tinh", player), cultivating)
	if cultivating:
		var density: float = float(db.get_record("places", player.location_id).get("density", 1.0))
		var gain: float = CultivationRules.rate_per_season(player, gd, db, sh, density, mode == "closed_door", db.get_record("places", player.location_id).get("qi", {})).total * yield_share
		var res: Dictionary = CultivationRules.add_tu_vi(player, gd, gain)
		out.tu_vi = gain
		out.stages = res.stages
		out.points = res.tree_points
		if res.stages > 0:
			sh = sheet()
	elif mode == "travel" and player.has_capability(8):
		var density_t: float = float(db.get_record("places", player.location_id).get("density", 1.0))
		var r8: Dictionary = CultivationRules.add_tu_vi(player, gd, float(gd.capability(8).params.rate_mult) * CultivationRules.rate_per_season(player, gd, db, sh, density_t, false, db.get_record("places", player.location_id).get("qi", {})).total * yield_share)
		out.tu_vi = r8.gained
		out.stages = r8.stages
		out.points = r8.tree_points
	field.grow(player, sh, 1)
	if knowledge != null:   # Formula J upkeep and Formula M rent, once a season
		var home_p: Dictionary = db.get_record("places", player.home_id)
		if not home_p.get("qi", {}).is_empty():   # Cave Abode rules 6, 8, 9: the grade upkeep is paid before the works'
			out.news.append_array(CaveAbode.season(gd, db, player, home_p.qi))
		out.news.append_array(CaveAbode.fade_left(gd, db, player.id))   # rule 10: arrays left behind fade
		out.news.append_array(MapWorks.upkeep(gd, db, player))
		out.news.append_array(_bill_residence())
		_sect_residence()
	var d: Dictionary = gd.attributes().derived
	player.dan_doc = maxf(player.dan_doc - CharacterRules.dan_doc_decay(player, gd, sh).total, 0.0)
	player.tam_ma = maxf(player.tam_ma - float(d.tam_ma_natural_decay), 0.0)
	player.vitality = minf(player.vitality + float(d.injury_recovery_frac_per_season), 1.0)
	var aging: float = float(gd.capability(7).params.age_mult) if mode == "closed_door" and player.has_capability(7) else 1.0
	player.age += aging / float(gd.cultivation_rules().seasons_per_year)
	# Snapshot cycled secret realms before WorldTicker advances MapChange.season() (AC-EV-45).
	var realm_was_open: Dictionary = {}
	for p in db.all("places"):
		if p.has("cycle"):
			realm_was_open[str(p.id)] = bool(p.get("open", false))
	season += 1
	var year_rolled: bool = false
	if season >= int(gd.cultivation_rules().seasons_per_year):
		season = 0
		year += 1
		year_rolled = true
	# NPC Interaction & Dialogue (#30): reset seasonal focus tax / F7 counter and expire finished buffs
	season_time_used = 0.0
	player.season_time_used = 0.0
	player.heart_demon_used = 0.0
	var s_idx: int = season_index()
	if not player.interaction_buffs.is_empty():
		player.interaction_buffs = player.interaction_buffs.filter(func(b): return b is Dictionary and int((b as Dictionary).get("expires_season", 0)) > s_idx)
	# Event Engine (#23): expire flags and clear prior-season leftovers BEFORE yearly/new-season hooks enqueue.
	_EventStore.expire_flags(db, s_idx)
	if event_engine != null:
		event_engine.end_of_season_cleanup(year, season)
	if year_rolled:
		_yearly()
	if event_engine != null:
		event_engine.on_season_start(player, sh, rng, year, season, _event_extras())
	_roll_ratings()   # rule 13, one season late: the previous season's batch applies; this season's waits a season
	db.mark_hook_dirty(player.id)   # NPC Relationships rule 15a: the player's realm and place change often
	out.news = ticker.tick(rng, year, season)
	# NPC Relationships rule 15a: the hook pass wrote the player's tie rows on the World DB record
	player.tie_rows = Array(db.get_record("people", player.id).get("tie_rows", [])).duplicate(true)
	_check_secret_realm_transitions(realm_was_open)
	# Template Quests (#31): AC-QS-57 strict 4-step season-end resolution order & local board refresh.
	if quests != null and not life_over:
		quests.on_season_end(player, sheet(), year, season, {
			"season_idx": s_idx,
			"seed": seed_value,
			"refresh_board": true,
		})
	if quest_board != null and not life_over and quest_board.has_board(player.location_id):
		quest_board.refresh_place(player.location_id, player, sheet(), seed_value, s_idx)
	if _bulk_left > 0:
		_bulk_left -= 1
	_start_ratings()
	if player.age >= CultivationRules.lifespan(player, gd, sh).total:
		_end_life("Thọ nguyên cạn kiệt ở tuổi %d" % int(player.age))
		out.died = true
	sync_player()
	return out


func _yearly() -> void:
	if player.has_capability(3) and player.equipped.has(player.nurtured_id):
		player.nurture_years += 1
	if player.sect_id != "":
		var stipend: int = int(gd.session().sect.stipend_per_year_by_realm.get(gd.realm(player.realm_index).id, 0))
		var got: int = MoneyLedger.player_take(db, player, "sect:%s" % player.sect_id, stipend, "stipend")   # paid by the treasury (Formula H)
		if got < stipend:
			_notices.append("  Your sect's treasury could pay only %d of your %d linh thạch stipend." % [got, stipend])
	for l in beasts.feed(player):
		_notices.append("  " + l)
	for l in formations.pay_upkeep(player):
		_notices.append("  " + l)
		_log("player_formation_decay", {"a": player.id})
	InteractionService.yearly_attitude_drift(gd, db, db.get_record("people", player.id))
	_raise_event_hook("on_year_start", {"year": year, "season": season, "queue_only": true})


func _news_lines(news: Array, limit: int = 3) -> Array:
	var lines: Array = _notices.duplicate()
	_notices.clear()
	for eid in news.slice(-limit):
		lines.append("  [tin đồn] " + str(db.get_record("events", eid).get("text", "")))
	return lines


## True when an event carries a cơ duyên gift (counted against the realm's allowance).
func _is_co_duyen(ev: Dictionary) -> bool:
	var gifts: Array = gd.budgets().get("co_duyen_effects", [])
	for ch in ev.get("choices", []):
		for part in [ch.get("always", []), ch.get("success", {}).get("effects", []), ch.get("failure", {}).get("effects", [])]:
			for fx in part:
				var key: String = str(fx.type) if str(fx.type) != "talisman" else "talisman:" + str(fx.get("talisman", ""))
				if gifts.has(key):
					return true
	return false


## Rolls for a random event at the current place via [EventEngine]. Returns lines describing it, or [].
## At a bình cảnh a life with the edge is likelier to meet one (cơ duyên).
func _maybe_event(bonus: float, mode: String = "cultivate") -> Array:
	if has_pending_event() or has_pending_mercy():
		return []
	# NPC Interaction & Dialogue (#30): fire scheduled follow-up events (e.g. overdue loan collection) first.
	var fu: Dictionary = InteractionService.pop_due_followup(db, season_index())
	if not fu.is_empty():
		var fu_npc: Dictionary = db.get_record("people", str(fu.get("npc_id", "")))
		if not fu_npc.is_empty() and bool(fu_npc.get("alive", false)):
			var ctx: Dictionary = event_context()
			var raw_fu: Dictionary = templates.generate_for_npc(ctx, fu_npc, rng, str(fu.get("template_id", "")))
			if not raw_fu.is_empty():
				var norm_fu: Dictionary = validator.normalize(raw_fu, ctx, rng, str(raw_fu.source))
				if bool(norm_fu.ok):
					pending_event = norm_fu.event
					pending_meta = {"source": str(norm_fu.event.source), "warnings": norm_fu.warnings, "llm_error": ""}
					return ["", "*** EVENT: %s ***  (type 'event' to read, 'choose <n>' to act)" % pending_event.title]
	if event_engine != null:
		var extras: Dictionary = _event_extras()
		var queued: Dictionary = event_engine.drain_queue(player, sheet(), rng, year, season, extras)
		if not queued.is_empty():
			return _activate_engine_event(queued, {"queued": true})
		var p_res: Dictionary = event_engine.roll_pulse(player, sheet(), rng, mode, bonus, extras)
		var pulsed: Dictionary = Dictionary(p_res.get("event", {})) if bool(p_res.get("ok", false)) else {}
		if not pulsed.is_empty():
			return _activate_engine_event(pulsed)
		return []
	var cfg: Dictionary = gd.event_templates().random_event_chance
	var place: Dictionary = db.get_record("places", player.location_id)
	var chance: float = float(cfg.base) + float(cfg.per_danger) * float(place.get("danger", 1)) + bonus
	if edge and CultivationRules.at_bottleneck(player, gd) and int(co_duyen_used.get(player.realm_index, 0)) < ProgressionEdges.co_duyen_limit(gd, player.realm_index):
		chance += float(ProgressionEdges.config(gd).player.co_duyen_bottleneck_event_bonus) * (1.0 + sheet().total("co_duyen_pct") / 100.0)
	if rng.randf() >= chance:
		return []
	var lines: Array = start_event("")
	# Capability #20: a hostile event may pass the character by.
	if player.has_capability(20) and has_pending_event() and rng.randf() >= float(gd.capability(20).params.hostile_mult):
		if pending_event.choices.any(func(ch): return str(ch.check.type) == "combat"):
			pending_event = {}
			pending_meta = {}
			return []
	return lines


## Generates an event now (LLM first, templates as fallback). [param template_id] forces a template.
## Internal: a frontend never calls it (ADR-0006 decision 2).
func start_event(template_id: String) -> Array:
	var ctx: Dictionary = event_context()
	var res: Dictionary = narrator.generate_event(ctx, rng, template_id)
	if not res.ok:
		return ["(No event fits here.%s)" % ((" " + res.llm_error) if res.llm_error != "" else "")]
	pending_event = res.event
	pending_meta = {"source": res.source, "warnings": res.warnings, "llm_error": res.llm_error}
	if _is_co_duyen(pending_event):
		co_duyen_used[player.realm_index] = int(co_duyen_used.get(player.realm_index, 0)) + 1
		_log("player_co_duyen", {"a": player.id, "place": player.location_id})
	if _is_past_life_event(pending_event):
		recognition_used += 1
	return ["", "*** EVENT: %s ***  (type 'event' to read, 'choose <n>' to act)" % pending_event.title]


# --- Actions ------------------------------------------------------------------------

## Tu luyện for [param seasons] seasons (stops early if an event interrupts).
## Action. Returns {ok, lines, ...}; a frontend calls it through run() (ADR-0006).
func cultivate(seasons: int) -> Dictionary:
	var g: Dictionary = _guard(true)
	if not g.ok:
		return g
	var n: int = clampi(seasons, 1, int(gd.session().cultivate.max_seasons_per_command))
	var total: float = 0.0
	var stages: int = 0
	var points: int = 0
	var news: Array = []
	var lines: Array = []
	var done: int = 0
	_bulk_begin(n)
	for i in n:
		var r: Dictionary = _pass_season("cultivate")
		done += 1
		total += r.tu_vi
		stages += r.stages
		points += r.points
		news.append_array(r.news)
		if r.died:
			break
		var ev: Array = _maybe_event(0.0)
		if not ev.is_empty():
			lines.append_array(ev)
			break
	_bulk_end()
	lines.push_front("Tu luyện %d season(s): +%.0f tu vi%s. Now %s (%.0f / %.0f)." % [done, total,
		(", +%d stage(s), +%d Đạo Đồ points" % [stages, points]) if stages > 0 else "",
		gd.realm_label(player.realm_index, player.stage), player.tu_vi, CultivationRules.level_requirement(player, gd)])
	if CultivationRules.at_bottleneck(player, gd):
		lines.insert(1, "  Bình cảnh! Further tu vi is wasted. Use 'breakthrough' (a %s helps greatly)." % str(gd.realm(player.realm_index + 1).entry_requirement.item_tag))
	lines.append_array(_news_lines(news))
	if life_over:
		lines.append_array(death_lines())
	return {"ok": true, "lines": lines}


## Bế quan for whole years: more efficient, no events, the world moves on.
## Action. Returns {ok, lines, ...}; a frontend calls it through run() (ADR-0006).
func closed_door(years: int) -> Dictionary:
	var g: Dictionary = _guard(true)
	if not g.ok:
		return g
	var y: int = clampi(years, 1, int(gd.session().closed_door.max_years))
	var total: float = 0.0
	var stages: int = 0
	var news: Array = []
	var seasons: int = y * int(gd.cultivation_rules().seasons_per_year)
	var done: int = 0
	_bulk_begin(seasons)
	for i in seasons:
		var r: Dictionary = _pass_season("closed_door")
		done += 1
		total += r.tu_vi
		stages += r.stages
		news.append_array(r.news)
		if r.died:
			break
	_bulk_end()
	var lines: Array = ["Bế quan %.1f năm: +%.0f tu vi (x%s efficiency)%s. Now %s, age %d." % [
		float(done) / float(gd.cultivation_rules().seasons_per_year), total, str(gd.cultivation_rules().closed_door_efficiency),
		(", +%d stage(s)" % stages) if stages > 0 else "", gd.realm_label(player.realm_index, player.stage), int(player.age)]]
	if CultivationRules.at_bottleneck(player, gd):
		lines.append("  You reached a bình cảnh during seclusion; excess tu vi was lost.")
	lines.append("  %d things happened in the world while you were secluded; 'news' shows them." % news.size())
	lines.append_array(_news_lines(news))
	if life_over:
		lines.append_array(death_lines())
	return {"ok": true, "lines": lines}


## Sect mission (at your sect's headquarters) or bounty work (in a town). One season.
## Action. Returns {ok, lines, ...}; a frontend calls it through run() (ADR-0006).
func mission() -> Dictionary:
	var g: Dictionary = _guard(true)
	if not g.ok:
		return g
	var cfg: Dictionary = gd.session().mission
	var place: Dictionary = db.get_record("places", player.location_id)
	var sect: Dictionary = db.get_record("sects", player.sect_id)
	var base: float
	var kind: String
	if not sect.is_empty() and sect.hq_place_id == player.location_id:
		base = float(cfg.sect_base_income)
		kind = "Sect mission for %s" % sect.name
	elif bool(place.get("bounties", false)):
		base = float(cfg.bounty_base_income)
		kind = "Bounty work in %s" % place.name
	else:
		return {"ok": false, "lines": ["No work here: go to your sect's headquarters or a town/city with bounties."]}
	var sh: StatSheet = sheet()
	var income := Breakdown.new("Income")
	income.base(kind, base)
	income.mul("Realm scale", float(cfg.income_realm_scale.get(gd.realm(player.realm_index).id, 1.0)))
	income.mul("Kim/mission multiplier", CharacterRules.mission_income(player, gd, sh).total)
	var yield_share_m: float = InteractionRules.focus_yield_share(season_time_used)
	if yield_share_m < 1.0:
		income.mul("Season focus remaining (%.0f%%)" % (yield_share_m * 100.0), yield_share_m)
	var earned: int = int(roundf(income.total))
	# Formula H: a sect mission is paid by the sect's treasury, a bounty by the town's commons (the market's pool)
	var client: String = "sect:%s" % sect.id if not sect.is_empty() and sect.hq_place_id == player.location_id else "pool:%s" % MoneyLedger.market_sect_of(db, player.location_id)
	var asked: int = earned
	earned = MoneyLedger.player_take(db, player, client, earned, "player_mission")
	var lines: Array = ["%s: +%d linh thạch (now %d)." % [kind, earned, player.linh_thach]]
	if earned < asked:
		lines.append("  The client could pay only %d of the %d agreed." % [earned, asked])
	if not sect.is_empty() and sect.hq_place_id == player.location_id:
		# Sects rule 25, F10, F12: contribution and standing with the sect
		var rw: Dictionary = sect_members.mission_reward(player, earned)
		lines.append("  +%d contribution (now %d), standing %+.1f (now %.0f)." % [int(rw.contribution),
			sect_members.contribution(sect.id, player.id), float(rw.standing), sect_members.standing(sect.id, player.id)])
	if rng.randf() < float(cfg.injury_chance):
		player.vitality = maxf(player.vitality - float(cfg.injury_khi_huyet_loss_pct) / 100.0, 0.05)
		lines.append("  You were wounded: khí huyết -%d%%." % int(cfg.injury_khi_huyet_loss_pct))
	var r: Dictionary = _pass_season("")
	lines.append_array(_news_lines(r.news))
	if not r.died:
		lines.append_array(_maybe_event(0.0, "mission"))
	else:
		lines.append_array(death_lines())
	return {"ok": true, "lines": lines}


## Explore the current place for a season: small finds, lost treasures, likely events.
## Action. Returns {ok, lines, ...}; a frontend calls it through run() (ADR-0006).
func explore() -> Dictionary:
	var g: Dictionary = _guard(true)
	if not g.ok:
		return g
	var cfg: Dictionary = gd.session().explore
	var place: Dictionary = db.get_record("places", player.location_id)
	if place.has("cycle"):   # Travel & Map rule 26: a secret realm on a cycle is entered only while open
		var st: Dictionary = MapChange.realm_state(place, MapChange.abs_season(year, season), str(db.get_record("world", "w_meta").get("seed", "")))
		if not bool(st.open):
			return {"ok": false, "lines": ["The gate of %s is sealed. It opens in %d season(s)." % [place.name, int(st.next_open_in)]]}
	var b: Dictionary = EventContext.budget(player, gd, sheet())
	var yield_share_e: float = InteractionRules.focus_yield_share(season_time_used)
	var found: int = int(roundf(RngUtils.range_f(rng, cfg.loot_linh_thach_frac) * float(b.linh_thach_max) * yield_share_e))
	# Formula K: found money is drawn from the lost stash of the market here (fed by a share of every mine)
	found = MoneyLedger.player_take(db, player, "stash:%s" % MoneyLedger.market_sect_of(db, player.location_id), found, "found")
	var lines: Array = ["You explore %s for a season and find %d linh thạch." % [place.name, found]]
	if rng.randf() < float(cfg.get("material_find_chance", 0.0)):
		var m: Dictionary = items.random_material(rng, int(b.get("material_rarity_max", 1)))
		m["qty"] = rng.randi_range(1, int(cfg.get("material_qty_max", 1)))
		m["owner_id"] = player.id
		var mid: String = market.add_or_merge(player, m)
		lines.append("  You also gather %s." % items.describe(db.get_record("items", mid)))
	for lost in db.items_of(place.id):
		var sh: StatSheet = sheet()
		var chance: float = resolver.stat_check_chance(player, sh, str(cfg.lost_item_check.stat), float(cfg.lost_item_check.difficulty)).total
		if rng.randf() < chance:
			db.set_owner(lost, player.id)
			lost.erase("lost")
			lost.erase("lost_since")
			_log("player_found_lost", {"a": player.id, "item": lost.id, "place": place.id})
			lines.append("  !!! You sense a hidden aura and unearth %s, lost here long ago. [%s]" % [items.describe(lost), lost.id])
		else:
			lines.append("  You sense something hidden here, but cannot find it (%.0f%% chance)." % (chance * 100.0))
		break
	lines.append_array(_gather_herbs(place))
	if knowledge != null and str(place.get("kind", "")) in gd.world_gen().get("continent", {}).get("settled_kinds", []):
		var heard: String = Discovery.rumour(gd, db, knowledge, rng, str(place.get("region_id", "")))
		if heard != "":
			lines.append(heard)
			_codex_note_knowledge_secrets()
	if str(place.get("slot", "")) != "":
		_codex_note(Codex.BOOK_SECRETS, str(place.slot), CodexStore.LEVEL_KNOWN)
	var r: Dictionary = _pass_season("")
	lines.append_array(_news_lines(r.news))
	if not r.died:
		lines.append_array(_maybe_event(float(gd.event_templates().random_event_chance.explore_bonus), "explore"))
	else:
		lines.append_array(death_lines())
	return {"ok": true, "lines": lines}


## Travel to a linked place. Takes the link's seasons (faster with travel_speed_pct).
## Travels to [param dest_id] (a place id or name), any reachable place, by the quickest way (Travel & Map rules
## 9-13, Formulas D-E; user decision 2026-11-20). On the continent the trip is a tile path: roads, rivers by boat,
## sea lanes and the wilderness, or flight when [param how] is "flight" (Foundation Establishment and up); in an old
## generated world it follows the links. A trip of T seasons spends ceil(T) seasons and the rest of the last season
## cultivates at the destination; each season of the trip may draw one encounter (Formula E).
## Action. Returns {ok, lines, ...}; a frontend calls it through run() (ADR-0006).
func travel(dest_id: String, how: String = "ground") -> Dictionary:
	var g: Dictionary = _guard(true)
	if not g.ok:
		return g
	var here: Dictionary = db.get_record("places", player.location_id)
	if not db.has_record("places", dest_id):
		var named: Array = db.find("places", func(p): return str(p.name) == dest_id)
		if named.is_empty():
			return {"ok": false, "lines": ["No place '%s'. Use 'map' to see roads." % dest_id]}
		dest_id = str(named[0].id)
	if dest_id == player.location_id:
		return {"ok": false, "lines": ["You are already at %s." % here.name]}
	if knowledge != null and not knowledge.knows_place(dest_id) and not _map_clue_for(dest_id):
		return {"ok": false, "lines": ["You have not heard of such a place."]}
	var f: float = Travel.speed_factor(gd, sheet().total("travel_speed_pct"))
	var dest: Dictionary = db.get_record("places", dest_id)
	var t: float = -1.0
	var hops: String = ""
	var stretches: Array = []
	var path_tiles: Array = []
	var flown: float = 0.0
	if here.has("tile") and dest.has("tile") and TravelGrid.of(gd).errors.is_empty():
		var tg: TravelGrid = TravelGrid.of(gd)
		var fly_speed: float = 0.0
		if how == "flight":
			fly_speed = tg.flight_speed(str(gd.realm(player.realm_index).id))
			if fly_speed <= 0.0:
				return {"ok": false, "lines": ["You cannot fly yet: flight opens at %s." % gd.realm(1).name]}
		var trip: Dictionary = tg.trip(Vector2i(int(here.tile[0]), int(here.tile[1])), Vector2i(int(dest.tile[0]), int(dest.tile[1])), how, f, fly_speed)
		if not trip.is_empty():
			t = float(trip.seasons)
			stretches = tg.stretches(trip)
			path_tiles = trip.tiles
			var legs: PackedStringArray = []
			for m in trip.by_mode:
				legs.append("%s %.2f" % [m, float(trip.by_mode[m])])
			hops = "%d tiles: %s" % [trip.steps.size(), ", ".join(legs)]
			if how == "flight":
				flown = float(trip.steps.size())
	if t < 0.0:
		if how == "flight":
			return {"ok": false, "lines": ["There is no flight path to %s." % dest.name]}
		var route: Dictionary = Travel.quickest(db, player.location_id, dest_id, f)
		if route.is_empty():
			return {"ok": false, "lines": ["%s cannot be reached from %s." % [dest.name, here.name]]}
		t = float(route.seasons)
		hops = "%d leg(s)" % int(route.hops)
		for pid in route.path:
			if not player.visited.has(pid):
				player.visited.append(pid)
	if season_time_used > 0.0:
		t += season_time_used
	var split: Dictionary = Travel.split(t)
	var seasons: int = int(split.seasons)
	var news: Array = []
	var died: bool = false
	var encounter: Dictionary = {}
	_bulk_begin(seasons)
	for i in seasons:
		var r: Dictionary = _pass_season("travel")
		news.append_array(r.news)
		if r.died:
			died = true
			break
		if encounter.is_empty() and i < stretches.size() and rng.randf() < float(stretches[i].chance):
			encounter = stretches[i]
	_bulk_end()
	if died:
		return {"ok": true, "lines": ["You die on the road."] + death_lines()}
	player.location_id = dest_id
	if not player.visited.has(dest_id):
		player.visited.append(dest_id)
	for b in beasts.owned(player):
		b["location_id"] = dest_id
	var lines: Array = ["You travel %.2f season(s) (%s) and arrive at %s; %d season(s) pass." % [t, hops, dest.name, seasons]]
	if knowledge != null:
		knowledge.signposts(db, dest_id)
	if knowledge != null and not path_tiles.is_empty():
		var ds: float = CharacterRules.than_thuc(player, gd, sheet()).total
		var seen: Array = knowledge.reveal_path(db, path_tiles, MapKnowledge.sight_radius(gd, ds))
		if not seen.is_empty():
			lines.append("You see %d place(s) you did not know along the way." % seen.size())
		var found_before: int = knowledge.found.size()
		lines.append_array(Discovery.check_path(gd, db, knowledge, rng, player, ds, path_tiles, how == "flight", year, season))
		_codex_note_knowledge_secrets()
		if knowledge.found.size() > found_before:
			lines.append_array(_raise_event_hook("on_discover", {"place_id": dest_id}))
	if str(dest.get("slot", "")) != "":
		_codex_note(Codex.BOOK_SECRETS, str(dest.slot), CodexStore.LEVEL_KNOWN)
	if flown > 0.0:
		var v_eff: float = TravelGrid.of(gd).flight_speed(str(gd.realm(player.realm_index).id)) * f
		var last_tiles: float = minf(flown, v_eff * float(split.last_share))
		var pool: float = clampf(1.0 - float(gd.file(Travel.RULES_FILE).get("flight_drain_per_season", 0.6)) * last_tiles / v_eff, 0.0, 1.0)
		lines.append("You land with %d%% of your linh lực (Formula D flight drain)." % int(round(pool * 100.0)))
	var left: float = 1.0 - float(split.last_share)
	if left > 0.0 and not CultivationRules.at_bottleneck(player, gd):
		var eta: float = float(gd.file(Travel.RULES_FILE).get("partial_season_efficiency", 1.0))
		var rate: float = CultivationRules.rate_per_season(player, gd, db, sheet(), float(dest.get("density", 1.0)), false, dest.get("qi", {})).total
		var res: Dictionary = CultivationRules.add_tu_vi(player, gd, rate * left * eta)
		lines.append("The rest of the season (%d%%) you cultivate there: +%.1f tu vi." % [int(round(left * 100.0)), float(res.gained)])
	sync_player()
	market.ensure_stock(rng, dest_id, year, player.realm_index, player.linh_can)
	if quests != null:
		var q_arr: Array = quests.on_arrive_place(player, dest_id, year, season, {"season_idx": season_index()})
		for qa in q_arr:
			if qa is Dictionary and bool((qa as Dictionary).get("ok", false)):
				var qrec: Dictionary = Dictionary((qa as Dictionary).get("quest", {}))
				lines.append("  Quest stage completed: %s." % str(qrec.get("name", qrec.get("id", ""))))
		quests.on_reach(player, sheet(), year, season, {"season_idx": season_index()})
	if quest_board != null and quest_board.has_board(dest_id):
		quest_board.refresh_place(dest_id, player, sheet(), seed_value, season_index())
	lines.append_array(_news_lines(news))
	if not encounter.is_empty():
		lines.append_array(_road_encounter(encounter))
	else:
		var arr_ev: Array = _raise_event_hook("on_arrive", {"place_id": dest_id})
		if not arr_ev.is_empty():
			lines.append_array(arr_ev)
		else:
			lines.append_array(_maybe_event(0.0, "travel"))
	return {"ok": true, "lines": lines}


## Formula E & Event Engine AC-EV-08: an encounter on the way draws exclusively from [code]on_travel_stretch[/code]
## filtered by biome and travel mode, with no pulse roll.
func _road_encounter(st: Dictionary) -> Array:
	var tg: TravelGrid = TravelGrid.of(gd)
	var legend: Dictionary = gd.file(ContinentData.DATA_FILE).get("legend", {}).get("biome_ids", {})
	var biome: String = str(legend.get(str(tg.biome_at(st.tile)), "")).to_lower().replace(" ", "_")
	var types: Dictionary = gd.file(Travel.RULES_FILE).get("encounter_place_type", {})
	var ptype: String = str(types.get(biome, types.get("default", "son")))
	if event_engine != null:
		var r_res: Dictionary = event_engine.raise_hook("on_travel_stretch", player, sheet(), rng, _event_extras({
			"biome": biome,
			"travel_mode": str(st.mode),
			"danger": int(st.danger),
			"place_type": ptype,
			"chance_override": 1.0,
		}))
		var ev: Dictionary = Dictionary(r_res.get("event", {})) if bool(r_res.get("ok", false)) else {}
		if ev.is_empty():
			return []
		_activate_engine_event(ev, {"on_the_road": st, "hook": "on_travel_stretch"})
		return ["", "*** ON THE ROAD (%s, danger %d): %s ***  (type 'event' to read, 'choose <n>' to act)" % [str(st.mode), int(st.danger), str(pending_event.get("title", ""))]]
	return []


## Travel & Map rule 18 and Trade Goods Formula K: gathering at a wild herb ground while exploring it. Returns lines.
func _gather_herbs(place: Dictionary) -> Array:
	var grounds: Array = place.get("herb_grounds", [])
	var hg: Dictionary = gd.file(MapProduction.DATA_FILE).get("herb_ground", {})
	if grounds.is_empty() or rng.randf() >= float(hg.get("gather_chance", 0.6)):
		return []
	var total: float = 0.0
	for g in grounds:
		total += float(g.fit)
	var x: float = rng.randf() * total
	var pick: Dictionary = grounds[-1]
	for g in grounds:
		x -= float(g.fit)
		if x <= 0.0:
			pick = g
			break
	var herb: Dictionary = gd.herb(str(pick.herb))
	var q: float = minf(float(hg.get("q_max", 0.5)), float(hg.get("q_base", 0.15)) * float(place.get("density", 1.0)) * (1.0 - float(hg.get("access_default", 0.5))))
	var units: int = rng.randi_range(int(hg.get("units_min", 1)), int(hg.get("units_max", 2)))
	var out: Array = []
	for u in units:
		var j: int = 0
		var key: String = "%s:herb:%s:%d:%s:%d" % [str(seed_value), str(place.id), year * 4 + season, str(pick.herb), u]
		while j < 8 and float(RngUtils.stable_hash("%s:%d" % [key, j]) % 100000) / 100000.0 < q:
			j += 1
		var age: float = float(herb.get("mature_years", 1)) * pow(2.0, float(j))
		var item: Dictionary = items.herb(str(pick.herb), age)
		item["owner_id"] = player.id
		item["origin_market"] = WorldEconomy.market_of_region(db, db.get_record("regions", str(place.get("region_id", ""))))   # Formula G: gathered here
		db.add("items", item)
		_codex_note(Codex.BOOK_HERBS, str(pick.herb), CodexStore.LEVEL_KNOWN)
		out.append("  You gather %s (%.0f năm) from the wild herb ground here." % [herb.get("name", pick.herb), age])
	return out


## Searches the current region for a season with the clues held for it (Travel & Map rule 17, Formula F). The
## season is spent off-road, so it may draw an encounter at the region's danger (Formula E, mode "search").
## Action. Returns {ok, lines, ...}; a frontend calls it through run() (ADR-0006).
func search() -> Dictionary:
	var g: Dictionary = _guard(true)
	if not g.ok:
		return g
	if knowledge == null:
		return {"ok": false, "lines": ["There is nothing hidden to search for in this world."]}
	var place: Dictionary = db.get_record("places", player.location_id)
	var region_id: String = str(place.get("region_id", ""))
	var ds: float = CharacterRules.than_thuc(player, gd, sheet()).total
	var f: float = Travel.speed_factor(gd, sheet().total("travel_speed_pct"))
	var found_before_s: int = knowledge.found.size()
	var res: Dictionary = Discovery.search(gd, db, knowledge, rng, player, ds, f, region_id, year, season)
	_codex_note_knowledge_secrets()
	var lines: Array = ["You spend a season searching the wilds of %s." % db.get_record("regions", region_id).get("name", "")]
	lines.append_array(res.lines)
	var r: Dictionary = _pass_season("")
	lines.append_array(_news_lines(r.news))
	if r.died:
		return {"ok": true, "lines": lines + death_lines()}
	if knowledge.found.size() > found_before_s or not Array(res.get("found", [])).is_empty():
		lines.append_array(_raise_event_hook("on_discover", {"region_id": region_id, "place_id": player.location_id}))
	var hz: Array = gd.file(Travel.RULES_FILE).get("hazard_per_season", [0.15, 0.35, 0.7, 1.2])
	var danger: int = clampi(int(place.get("danger", 1)) + 1, 1, hz.size())
	var chance: float = 1.0 - exp(-float(hz[danger - 1]) * float(gd.file(Travel.RULES_FILE).get("mode_factor", {}).get("search", 1.0)))
	if not has_pending_event() and rng.randf() < chance:
		lines.append_array(_road_encounter({"tile": place.get("tile", [0, 0]), "mode": "search", "danger": danger}))
	return {"ok": true, "lines": lines}


## The clues the player holds, as lines (never the truth: a false clue looks like a true one).
## Read-only. Never changes the world (ADR-0006 decision 1).
func clue_lines() -> Array:
	if knowledge == null or knowledge.clues.is_empty():
		return ["You hold no clues to hidden places. Explore settlements to hear rumours."]
	var out: Array = []
	for c in knowledge.clues:
		var roll: Dictionary = Discovery.ledger(db).get(str(c.slot), {})
		var done: String = " (found)" if knowledge.found.has(str(c.slot)) else ""
		out.append("  %-9s %s in %s, quality %.2f%s" % [str(c.kind), Discovery._kind_words(str(roll.get("kind", ""))), db.get_record("regions", str(c.region)).get("name", "?"), float(c.quality), done])
	return out


## Whether the player holds an exact map to the hidden place [param place_id] (it may then be travelled to).
func _map_clue_for(place_id: String) -> bool:
	if knowledge == null:
		return false
	var slot: String = str(db.get_record("places", place_id).get("slot", ""))
	return slot != "" and knowledge.clues.any(func(c): return str(c.slot) == slot and str(c.kind) == "map")


## Travel & Map rule 11 and Formula K: a jump between two teleport-array cities. The fee grows with the straight-line
## distance d in tiles: round(linh_thach_max[realm] * min(fee_base_frac + fee_per_tile_frac * d, fee_frac_max) *
## owner_mult); the jump takes jump_seasons, and the rest of the season cultivates at the destination. {} fee when
## either end has no array.
## Read-only. Never changes the world (ADR-0006 decision 1).
func teleport_fee(dest_id: String) -> Dictionary:
	var here: Dictionary = db.get_record("places", player.location_id)
	var dest: Dictionary = db.get_record("places", dest_id)
	if not bool(here.get("array", false)) or not bool(dest.get("array", false)) or dest_id == player.location_id:
		return {}
	var tp: Dictionary = gd.file(Travel.RULES_FILE).get("teleport", {})
	var d: int = maxi(absi(int(here.tile[0]) - int(dest.tile[0])), absi(int(here.tile[1]) - int(dest.tile[1])))
	var frac: float = minf(float(tp.get("fee_base_frac", 0.05)) + float(tp.get("fee_per_tile_frac", 0.0005)) * float(d), float(tp.get("fee_frac_max", 0.3)))
	var lt_max: float = float(gd.realm_budget(player.realm_index).get("linh_thach_max", 0))
	return {"fee": int(round(lt_max * frac * float(tp.get("owner_mult", 1.0)))), "tiles": d, "seasons": float(tp.get("jump_seasons", 0.05))}


## Jumps through the teleport array here to the one at [param dest_id] (a place id or name).
## Action. Returns {ok, lines, ...}; a frontend calls it through run() (ADR-0006).
func teleport(dest_id: String) -> Dictionary:
	var g: Dictionary = _guard(true)
	if not g.ok:
		return g
	if not db.has_record("places", dest_id):
		var named: Array = db.find("places", func(p): return str(p.name) == dest_id)
		dest_id = str(named[0].id) if not named.is_empty() else dest_id
	var fee: Dictionary = teleport_fee(dest_id)
	if fee.is_empty():
		return {"ok": false, "lines": ["A jump needs a teleport array here and at the destination (the great cities that hold one: 'arrays')."]}
	if player.linh_thach < int(fee.fee):
		return {"ok": false, "lines": ["The array keepers ask %d linh thạch; you have %d." % [int(fee.fee), player.linh_thach]]}
	# Formula H: f_burn of the fee powers the arrays, the rest goes to the sect that holds the array here
	var f_burn: float = float(gd.file(WorldEconomy.FILE).get("money", {}).get("f_burn", 0.5)) if db.count(WorldEconomy.TABLE) > 0 else 1.0
	var burned: int = int(round(int(fee.fee) * f_burn))
	MoneyLedger.player_pay(db, player, "", burned, "array_fees")
	var keeper: String = str(db.get_record("places", player.location_id).get("holder", ""))
	MoneyLedger.player_pay(db, player, "sect:%s" % keeper if keeper != "" else "", int(fee.fee) - burned, "array_fees")
	var dest: Dictionary = db.get_record("places", dest_id)
	var r: Dictionary = _pass_season("travel")
	if r.died:
		return {"ok": true, "lines": ["You die before the array takes you."] + death_lines()}
	player.location_id = dest_id
	if not player.visited.has(dest_id):
		player.visited.append(dest_id)
	if knowledge != null:
		knowledge.places[dest_id] = true
	var lines: Array = ["The array flares: %d tiles in %.2f of a season, for %d linh thạch. You arrive at %s." % [int(fee.tiles), float(fee.seasons), int(fee.fee), dest.name]]
	var left: float = 1.0 - float(fee.seasons)
	if not CultivationRules.at_bottleneck(player, gd):
		var rate: float = CultivationRules.rate_per_season(player, gd, db, sheet(), float(dest.get("density", 1.0)), false, dest.get("qi", {})).total
		var res: Dictionary = CultivationRules.add_tu_vi(player, gd, rate * left * float(gd.file(Travel.RULES_FILE).get("partial_season_efficiency", 1.0)))
		lines.append("The rest of the season you cultivate there: +%.1f tu vi." % float(res.gained))
	sync_player()
	if quests != null:
		var q_tp: Array = quests.on_arrive_place(player, dest_id, year, season, {"season_idx": season_index()})
		for qa in q_tp:
			if qa is Dictionary and bool((qa as Dictionary).get("ok", false)):
				var qrec: Dictionary = Dictionary((qa as Dictionary).get("quest", {}))
				lines.append("  Quest stage completed: %s." % str(qrec.get("name", qrec.get("id", ""))))
		quests.on_reach(player, sheet(), year, season, {"season_idx": season_index()})
	if quest_board != null and quest_board.has_board(dest_id):
		quest_board.refresh_place(dest_id, player, sheet(), seed_value, season_index())
	lines.append_array(_news_lines(r.news))
	lines.append_array(_raise_event_hook("on_arrive", {"place_id": dest_id}))
	return {"ok": true, "lines": lines}


## The teleport-array cities and the fee from here to each, as lines.
## Read-only. Never changes the world (ADR-0006 decision 1).
func array_lines() -> Array:
	var out: Array = []
	for p in db.find("places", func(x): return bool(x.get("array", false))):
		var fee: Dictionary = teleport_fee(str(p.id))
		var here_array: bool = bool(db.get_record("places", player.location_id).get("array", false))
		var note: String = "(you are here)" if str(p.id) == player.location_id else ("%d LT, %d tiles" % [int(fee.fee), int(fee.tiles)] if not fee.is_empty() else ("" if here_array else "(go to an array city to jump)"))
		out.append("  %-5s %-22s %s" % [p.id, p.name, note])
	return out if not out.is_empty() else ["No teleport arrays in this world."]


## Builds or raises a work on the land here (Travel & Map rules 31-32, Formula J): a shared work at a place the
## player holds, a home work at home. Permanent works take their level's seasons; upkept ones one season.
## Action. Returns {ok, lines, ...}; a frontend calls it through run() (ADR-0006).
func build_work(work_id: String, element: String = "") -> Dictionary:
	var g: Dictionary = _guard(true)
	if not g.ok:
		return g
	var place: Dictionary = db.get_record("places", player.location_id)
	var r: Dictionary = MapWorks.build(gd, db, player, place, work_id, element)
	if not r.ok:
		return r
	var lines: Array = r.lines
	for i in int(r.seasons):
		var t: Dictionary = _pass_season("")
		lines.append_array(_news_lines(t.news))
		if t.died:
			return {"ok": true, "lines": lines + death_lines()}
	return {"ok": true, "lines": lines}


## The works here and what each would cost next, as lines.
## Read-only. Never changes the world (ADR-0006 decision 1).
func work_lines() -> Array:
	var place: Dictionary = db.get_record("places", player.location_id)
	var qi: Dictionary = place.get("qi", {})
	if qi.is_empty():
		return ["This ground has no land qi to work."]
	var out: Array = ["Works at %s (layer 2 shared%s; layer 1 at your home):" % [place.name, ", you hold it" if MapWorks.holds(db, player, place) else ", held by others"]]
	if float(qi.get("prebuilt", 0.0)) > 0.0:
		out.append("  the ground's own works: density +%.2f (kept up by its holder)" % float(qi.prebuilt))
	var mine: Dictionary = qi.get("layer1", {}).get(player.id, {})
	for id in MapWorks.cfg(gd).works:
		var w: Dictionary = MapWorks.work(gd, str(id))
		var store: Dictionary = qi.get("layer2", {}) if int(w.layer) == 2 else mine
		var lv: int = int(store.get(id, {}).get("level", 0))
		var wmax: int = int(w.get("max", 0))   # 0: no highest level (layer 2 since 2026-11-24)
		var next: String = "max" if wmax > 0 and lv >= wmax else "next %d LT, %d materials, %d season(s)" % [int(MapWorks.cost(gd, str(id), lv + 1).lt), int(MapWorks.cost(gd, str(id), lv + 1).materials), int(MapWorks.cost(gd, str(id), lv + 1).seasons)]
		out.append("  %-15s layer %d %-9s %-10s level %d/%s  (%s)" % [id, int(w.layer), str(w.kind), str(w.stat), lv, str(wmax) if wmax > 0 else "-", next])
	return out


## Opens a cave abode on the wilderness tile ([param x], [param y]) (Travel & Map rule 8, Formulas M): travels there,
## pays round(linh_thach_max x abode_cost_frac) and a season, and the abode becomes the player's home, a new place
## with the tile part's terrain and qi ([param part] 0-2; -1 picks the part with the best density x land match).
## Action. Returns {ok, lines, ...}; a frontend calls it through run() (ADR-0006).
func open_abode(x: int, y: int, part: int = -1) -> Dictionary:
	var g: Dictionary = _guard(true)
	if not g.ok:
		return g
	var tg: TravelGrid = TravelGrid.of(gd)
	var here: Dictionary = db.get_record("places", player.location_id)
	if knowledge == null or not here.has("tile") or not tg.errors.is_empty():
		return {"ok": false, "lines": ["Cave abodes can be opened on the continent's wilderness only."]}
	var t := Vector2i(x, y)
	if not tg.passable(t) or db.find("places", func(p): return p.has("tile") and int(p.tile[0]) == x and int(p.tile[1]) == y).size() > 0:
		return {"ok": false, "lines": ["Tile %d,%d is not open wilderness (water, or a place stands there)." % [x, y]]}
	var grid := ContinentGrid.from_continent(gd)
	var best: int = -1
	var best_v: float = -1.0
	for k in 3:
		var q: Dictionary = grid.part_qi(x, y, k)
		if q.is_empty() or int(grid.value("BIO%d" % (k + 1), x, y)) in [ContinentGrid.SEA_ID, ContinentGrid.LAKE_ID]:
			continue
		var v: float = float(q.density) * LandQi.land_match(player, gd, q).total
		if (part < 0 and v > best_v) or k == part:
			best = k
			best_v = v
	if best < 0:
		return {"ok": false, "lines": ["Tile %d,%d has no land to dig into (sea or lake)." % [x, y]]}
	var q: Dictionary = grid.part_qi(x, y, best)
	if q.is_empty():
		return {"ok": false, "lines": ["That tile has no land to dig into."]}
	var cost: int = int(round(float(gd.realm_budget(player.realm_index).get("linh_thach_max", 0)) * float(MapWorks.cfg(gd).get("abode_cost_frac", 0.05))))
	var trip: Dictionary = tg.trip(Vector2i(int(here.tile[0]), int(here.tile[1])), t, "ground", Travel.speed_factor(gd, sheet().total("travel_speed_pct")))
	if trip.is_empty():
		return {"ok": false, "lines": ["You cannot reach tile %d,%d on foot." % [x, y]]}
	if player.linh_thach < cost:
		return {"ok": false, "lines": ["Opening a cave abode costs %d linh thạch; you have %d." % [cost, player.linh_thach]]}
	var seasons: int = int(Travel.split(float(trip.seasons)).seasons) + 1
	var lines: Array = ["You walk %.2f season(s) to tile %d,%d and open a cave abode there (%d linh thạch, a season's work)." % [float(trip.seasons), x, y, cost]]
	_bulk_begin(seasons)
	for i in seasons:
		var r: Dictionary = _pass_season("travel" if i < seasons - 1 else "")
		lines.append_array(_news_lines(r.news))
		if r.died:
			_bulk_end()
			return {"ok": true, "lines": lines + death_lines()}
	_bulk_end()
	MoneyLedger.player_pay(db, player, "", cost, "works")   # a cave abode's opening is works (burned)
	var region_cid: int = grid.region(x, y)
	var region: Array = db.find("regions", func(r): return int(r.get("continent_id", -1)) == region_cid)
	var rec := {"name": "Động phủ của %s" % player.name, "type": "dong_phu", "kind": "abode", "region_id": str(region[0].id) if not region.is_empty() else "",
		"density": float(q.density), "danger": int(q.danger), "market": false, "bounties": false, "links": [], "sect_id": "",
		"tile": [x, y], "qi": {"shares": q.shares, "variants": q.variants, "land_density": float(q.density), "part": best,
			"abode": {"owner": player.id, "grade": 1, "unpaid": 0, "pending": 0, "state": "open", "order": [], "dormant": []}},
		"owner_id": player.id, "opened_year": year}
	WorldBuilder._climate(rec, grid)
	CaveAbode.leave(gd, player, db.get_record("places", player.home_id))   # Cave Abode rule 10: the old home is left
	var pid: String = db.add("places", rec)
	if not region.is_empty():
		region[0].places.append(pid)
	knowledge.places[pid] = true
	knowledge.reveal_path(db, trip.tiles, MapKnowledge.sight_radius(gd, CharacterRules.than_thuc(player, gd, sheet()).total))
	player.location_id = pid
	player.home_id = pid
	db.log_event(year, season, "abode_opened", "%s mở động phủ tại %s." % [player.name, rec.region_id], [player.id], [pid], [], {"tile": [x, y]})
	sync_player()
	lines.append("Your new home: density %.2f, danger %d, land match x%.3f." % [float(q.density), int(q.danger), LandQi.land_match(player, gd, rec.qi).total])
	return {"ok": true, "lines": lines}


## Cave Abode (user decision 2026-11-21): a home that is neither an abode nor a residence (an origin's home town) is a
## free grade-1 residence of that place: 2 slots, works up to level 3, its furnishing, no rent. Also for an older save.
## Internal: a frontend never calls it (ADR-0006 decision 2).
func start_residence() -> void:
	var home: Dictionary = db.get_record("places", player.home_id)
	if home.get("qi", {}).is_empty() or not CaveAbode.home_rec(home.qi, player.id).is_empty():
		return
	if str(home.qi.get("abode", {}).get("owner", "")) == player.id or str(home.get("owner_id", "")) == player.id:
		return   # the player's own cave abode (an older save without a home record gets one in load_dict)
	if player.sect_id != "" and str(db.get_record("sects", player.sect_id).get("hq_place_id", "")) == str(home.id):
		_sect_residence()   # the sect houses its member by realm (Travel & Map rule 34)
		return
	if not home.qi.has("residences"):
		home.qi["residences"] = {}
	home.qi.residences[player.id] = {"grade": 1, "own": true, "rent": 0, "origin": true}
	CaveAbode.reconcile(gd, home.qi, player)


## Rule 6 and F1: raises the player's cave abode a grade (one season). The residence's grade is fixed.
## Action. Returns {ok, lines, ...}; a frontend calls it through run() (ADR-0006).
func raise_abode() -> Dictionary:
	var g: Dictionary = _guard(true)
	if not g.ok:
		return g
	if player.location_id != player.home_id:
		return {"ok": false, "lines": ["The abode is raised at your home."]}
	var home: Dictionary = db.get_record("places", player.home_id)
	var r: Dictionary = CaveAbode.raise(gd, db, player, home.get("qi", {}))
	if not bool(r.ok):
		return r
	var lines: Array = r.lines
	var t: Dictionary = _pass_season("")
	lines.append_array(_news_lines(t.news))
	if t.died:
		return {"ok": true, "lines": lines + death_lines()}
	return {"ok": true, "lines": lines}


## Rule 11 and F4: claims the Left or ruined cave abode here (half the opening fee, one season); it becomes the home.
## Action. Returns {ok, lines, ...}; a frontend calls it through run() (ADR-0006).
func claim_abode() -> Dictionary:
	var g: Dictionary = _guard(true)
	if not g.ok:
		return g
	var place: Dictionary = db.get_record("places", player.location_id)
	if not CaveAbode.claimable(place, player):
		return {"ok": false, "lines": ["There is no left or ruined abode here to claim."]}
	if player.linh_thach < CaveAbode.claim_fee(gd, player.realm_index):
		return {"ok": false, "lines": ["Claiming this abode costs %d linh thạch; you have %d." % [CaveAbode.claim_fee(gd, player.realm_index), player.linh_thach]]}
	if player.home_id != str(place.id):
		CaveAbode.leave(gd, player, db.get_record("places", player.home_id))
	var r: Dictionary = CaveAbode.claim(gd, db, player, place)
	if not bool(r.ok):
		return r
	player.home_id = str(place.id)
	db.log_event(year, season, "abode_claimed", "%s chiếm động phủ %s." % [player.name, place.name], [player.id], [place.id], [])
	sync_player()
	var lines: Array = r.lines
	var t: Dictionary = _pass_season("")
	lines.append_array(_news_lines(t.news))
	if t.died:
		return {"ok": true, "lines": lines + death_lines()}
	if str(place.qi.abode.get("state", "")) == "claimed":
		place.qi.abode["state"] = "open"   # the claim season has passed
	return {"ok": true, "lines": lines}


## World Generation rule 8, Families: a gia_toc player has a living parent and 0 to player_siblings_max siblings in
## the clan town (people already there, renamed to the player's surname; the player is made last, so no one has seen
## them yet). Kin through NPC Relationships.
func _clan_family(home: Dictionary) -> void:
	var c: Dictionary = Families.cfg(gd)
	var ordinary: Array = db.living().filter(func(p): return bool(p.get("alive", true)) and not bool(p.get("is_player", false)) and not bool(p.get("is_beast", false)) and not p.has("cast_key") and str(p.get("parent_id", "")) == "" and str(p.get("sect_id", "")) == "")
	ordinary.sort_custom(func(a, b): return str(a.id) < str(b.id))
	var region: String = str(home.get("region_id", ""))
	var here: Array = ordinary.filter(func(p): return str(p.get("location_id", "")) == str(home.id))
	var gap: float = float(c.get("parent_age_gap", 18))
	var elders: Array = []
	for pool in [here, ordinary.filter(func(p): return str(db.get_record("places", str(p.get("location_id", ""))).get("region_id", "")) == region), ordinary]:
		elders = pool.filter(func(p): return float(p.get("age", 0.0)) >= player.age + gap)
		if not elders.is_empty():
			break   # the clan town first, then its region, then anywhere: the family lives in the clan town
	var parent: Dictionary = {}
	if elders.is_empty():   # no loose elder anywhere (a small world): the parent is made in the clan town
		var pid: String = builds.create_person(rng, {"realm_index": 0, "stage": 0, "age": player.age + gap + float(rng.randi() % 20), "location_id": str(home.id)})
		parent = db.get_record("people", pid)
	else:
		parent = elders[rng.randi() % elders.size()]
	parent["location_id"] = str(home.id)
	var surname: String = Families.surname_of(gd, player.name)
	parent["name"] = Families.with_surname(gd, str(parent.name), surname)
	sync_player()
	var me: Dictionary = db.get_record("people", player.id)
	Families.link(gd, db, me, parent, Ties.now(db), true)
	player.parent_id = str(parent.id)
	var peers: Array = ordinary.filter(func(p): return str(p.id) != str(parent.id) and absf(float(p.get("age", 0.0)) - player.age) <= gap and float(parent.get("age", 0.0)) >= float(p.get("age", 0.0)) + gap)
	for i in mini(rng.randi() % (int(c.get("player_siblings_max", 2)) + 1), peers.size()):
		peers[i]["location_id"] = str(home.id)
		Families.link(gd, db, peers[i], parent, Ties.now(db))


## Rule 9: the owner picks which work sleeps while a lost slot forces one to (a swap; see CaveAbode.sleep).
## Action. Returns {ok, lines, ...}; a frontend calls it through run() (ADR-0006).
func abode_sleep(id: String, wake: String = "") -> Dictionary:
	if player.location_id != player.home_id:
		return {"ok": false, "lines": ["You choose at your home."]}
	var home: Dictionary = db.get_record("places", player.home_id)
	var r: Dictionary = CaveAbode.sleep(gd, home.get("qi", {}), player, id, wake)
	sync_player()
	return r


## Rule 13: the home's stat block (grade, slots, works and their state, upkeep, the next grade).
## Read-only. Never changes the world (ADR-0006 decision 1).
func abode_lines() -> Array:
	var home: Dictionary = db.get_record("places", player.home_id)
	if home.get("qi", {}).is_empty():
		return ["Your home has no land qi (an old generated world)."]
	return CaveAbode.lines(gd, home.qi, player, sheet().total("home_array_density"), sheet().total("formation_power_pct"))


## Rents or buys a residence of [param grade] here (Travel & Map rule 34, Formula M): settled ground only, the grade
## within the place's max_grade and the realm minimum. A sect member lives at their seat by realm for free.
## Action. Returns {ok, lines, ...}; a frontend calls it through run() (ADR-0006).
func take_residence(grade: int, buy: bool = false) -> Dictionary:
	var g: Dictionary = _guard(false)
	if not g.ok:
		return g
	var place: Dictionary = db.get_record("places", player.location_id)
	var cfg: Dictionary = MapWorks.cfg(gd)
	if place.get("qi", {}).is_empty() or not MapWorks.settled(gd, place):
		return {"ok": false, "lines": ["Residences are let in settlements and sect grounds."]}
	if player.sect_id != "" and str(place.get("sect_id", "")) == player.sect_id:
		return {"ok": false, "lines": ["Your sect houses you here by your realm; there is nothing to rent."]}
	var max_g: int = int(cfg.max_grade.get(str(place.kind), 1))
	if grade < 1 or grade > max_g:
		return {"ok": false, "lines": ["%s has residences of grade 1 to %d." % [place.name, max_g]]}
	if player.realm_index < int(cfg.grade_realm_min.get(str(grade), 0)):
		return {"ok": false, "lines": ["Grade %d needs %s." % [grade, gd.realm(int(cfg.grade_realm_min[str(grade)])).name]]}
	var d_res: float = float(LandQi.stacked_density(gd, player, place.qi, float(place.density), 0.0).total) + float(cfg.furnish_per_grade) * grade
	var rent: int = MapWorks.rent(gd, player.realm_index, d_res)
	var price: int = rent * int(cfg.buy_seasons)
	if buy and player.linh_thach < price:
		return {"ok": false, "lines": ["A grade %d residence here sells for %d linh thạch; you have %d." % [grade, price, player.linh_thach]]}
	if buy:   # paid to the sect that holds the place (burned where none does)
		var seller: String = str(place.get("holder", ""))
		MoneyLedger.player_pay(db, player, "sect:%s" % seller if seller != "" else "", price, "residence")
	if player.home_id != str(place.id):   # Cave Abode rule 10: the old home is left (a residence returns to its holder)
		CaveAbode.leave(gd, player, db.get_record("places", player.home_id))
	if not place.qi.has("residences"):
		place.qi["residences"] = {}
	var res: Dictionary = place.qi.residences.get(player.id, {})   # merged: the works' order and dormancy survive
	res["grade"] = grade
	res["own"] = buy
	res["rent"] = rent
	res.erase("origin")
	place.qi.residences[player.id] = res
	player.home_id = str(place.id)
	CaveAbode.reconcile(gd, place.qi, player)
	sync_player()
	return {"ok": true, "lines": ["You %s a grade %d residence at %s%s; it is your home now." % ["buy" if buy else "rent", grade, place.name, (" for %d linh thạch" % price) if buy else (" for %d linh thạch a season" % rent)]]}


## Rule 33: a sect member lives at their seat in a residence of grade min(realm + 1, the seat's max grade), allocated
## by the sect, free (Sects #26 owns the allocation by rank).
func _sect_residence() -> void:
	if player.sect_id == "":
		return
	var sect: Dictionary = db.get_record("sects", player.sect_id)
	var seat: Dictionary = db.get_record("places", str(sect.get("hq_place_id", "")))
	if seat.get("qi", {}).is_empty():
		return
	var grade: int = mini(player.realm_index + 1, int(MapWorks.cfg(gd).max_grade.get(str(seat.get("kind", "")), 5)))
	if not seat.qi.has("residences"):
		seat.qi["residences"] = {}
	var cur: Dictionary = seat.qi.residences.get(player.id, {})
	if cur.is_empty():
		seat.qi.residences[player.id] = {"grade": grade, "own": true, "rent": 0, "sect": true}
	elif bool(cur.get("origin", false)):   # a starting residence at the seat (an older save) becomes the sect's
		cur.erase("origin")
		cur["sect"] = true
		cur["grade"] = grade
		CaveAbode.reconcile(gd, seat.qi, player)
	elif bool(cur.get("sect", false)) and int(cur.grade) != grade:
		cur["grade"] = grade   # Cave Abode rule 9: merged, so the works' order and dormancy survive
		CaveAbode.reconcile(gd, seat.qi, player)


## Formula M: bills the season's rent of a rented residence; one unpaid season ends the lease.
func _bill_residence() -> Array:
	for p in db.all("places"):
		var res: Dictionary = p.get("qi", {}).get("residences", {}).get(player.id, {})
		if res.is_empty() or bool(res.get("own", false)):
			continue
		if player.linh_thach >= int(res.rent):
			var landlord: String = str(p.get("holder", ""))
			MoneyLedger.player_pay(db, player, "sect:%s" % landlord if landlord != "" else "", int(res.rent), "rent")
			return []
		# Cave Abode: the home keeps a record, so its slots and ceiling hold: the rooms fall back to the free grade-1
		# terms of a starting residence (works over the slots go dormant, rule 9)
		p.qi.residences[player.id] = {"grade": 1, "own": true, "rent": 0, "origin": true,
			"order": res.get("order", []), "dormant": res.get("dormant", [])}
		var lines: Array = ["  You could not pay the rent at %s; you keep only a plain grade 1 room there." % p.name]
		lines.append_array(CaveAbode.reconcile(gd, p.qi, player))
		return lines
	return []


## Capability #21: once a year, travel instantly to any visited place.
## Action. Returns {ok, lines, ...}; a frontend calls it through run() (ADR-0006).
func blink(dest_id: String) -> Dictionary:
	var g: Dictionary = _guard(true)
	if not g.ok:
		return g
	if not player.has_capability(21):
		return {"ok": false, "lines": ["You hold no Blink Mark."]}
	if player.blink_year == year:
		return {"ok": false, "lines": ["The mark has not recovered this year."]}
	if not player.visited.has(dest_id):
		return {"ok": false, "lines": ["You have not been to %s." % dest_id]}
	player.blink_year = year
	player.location_id = dest_id
	sync_player()
	return {"ok": true, "lines": ["You step through the mark to %s." % db.get_record("places", dest_id).get("name", dest_id)]}


## Luyện đan one recipe (one season; with capability #10 two recipes share a season).
## Action. Returns {ok, lines, ...}; a frontend calls it through run() (ADR-0006).
func craft(recipe_id: String) -> Dictionary:
	var g: Dictionary = _guard(true)
	if not g.ok:
		return g
	var r: Dictionary = alchemy.craft(player, sheet(), rng, recipe_id)
	if not r.ok:
		return {"ok": false, "lines": [r.message]}
	if bool(r.get("success", false)):
		_codex_note(Codex.BOOK_RECIPES, recipe_id, CodexStore.LEVEL_KNOWN)
		if quests != null and str(r.get("pill_id", "")) != "":
			quests.on_item_crafted(player, str(r.pill_id), season_index())
	else:
		_codex_note(Codex.BOOK_RECIPES, recipe_id, CodexStore.LEVEL_SEEN)
	var lines: Array = [r.message]
	if player.has_capability(10) and not player.cap_used.has("10_brew"):
		player.cap_used["10_brew"] = true
		return {"ok": true, "lines": lines + ["The second furnace is still lit: one more brew fits this season."]}
	player.cap_used.erase("10_brew")
	var t: Dictionary = _pass_season("")
	lines.append_array(_news_lines(t.news))
	if t.died:
		lines.append_array(death_lines())
	return {"ok": true, "lines": lines}


## Luyện khí: refines a pháp bảo of [param base_id] at [param tier] (-1 = own realm). One season.
## Action. Returns {ok, lines, ...}; a frontend calls it through run() (ADR-0006).
func refine(base_id: String, tier: int = -1) -> Dictionary:
	var g: Dictionary = _guard(true)
	if not g.ok:
		return g
	var t: int = player.realm_index if tier < 0 else tier
	var r: Dictionary = refinery.refine(player, sheet(), rng, base_id, t)
	if not r.ok:
		return {"ok": false, "lines": [r.message]}
	if r.success:
		_log("player_refined", {"a": player.id, "item": r.item_id})
		_codex_note(Codex.BOOK_RECIPES, base_id, CodexStore.LEVEL_KNOWN)
		_codex_note_item(db.get_record("items", str(r.item_id)))
		if quests != null and str(r.get("item_id", "")) != "":
			quests.on_item_crafted(player, str(r.item_id), season_index())
	else:
		_codex_note(Codex.BOOK_RECIPES, base_id, CodexStore.LEVEL_SEEN)
	var lines: Array = [r.message]
	var p: Dictionary = _pass_season("")
	lines.append_array(_news_lines(p.news))
	if p.died:
		lines.append_array(death_lines())
	return {"ok": true, "lines": lines}


## Phù lục: draws one batch of talismans. One season.
## Action. Returns {ok, lines, ...}; a frontend calls it through run() (ADR-0006).
func draw_talisman(talisman_id: String) -> Dictionary:
	var g: Dictionary = _guard(true)
	if not g.ok:
		return g
	var r: Dictionary = talismans.draw(player, sheet(), rng, talisman_id)
	if not r.ok:
		return {"ok": false, "lines": [r.message]}
	if bool(r.get("success", false)):
		_codex_note(Codex.BOOK_RECIPES, talisman_id, CodexStore.LEVEL_KNOWN)
		if quests != null:
			for it in db.items_of(player.id):
				if str(it.get("kind", "")) == "talisman" and str(it.get("template", "")) == talisman_id:
					quests.on_item_crafted(player, str(it.id), season_index())
					break
	else:
		_codex_note(Codex.BOOK_RECIPES, talisman_id, CodexStore.LEVEL_SEEN)
	var lines: Array = [r.message]
	var p: Dictionary = _pass_season("")
	lines.append_array(_news_lines(p.news))
	if p.died:
		lines.append_array(death_lines())
	return {"ok": true, "lines": lines}


## Trận pháp: raises a formation at the động phủ one level. One season.
## Action. Returns {ok, lines, ...}; a frontend calls it through run() (ADR-0006).
func formation_build(formation_id: String) -> Dictionary:
	var g: Dictionary = _guard(true)
	if not g.ok:
		return g
	var r: Dictionary = formations.build(player, formation_id)
	if not r.ok:
		return {"ok": false, "lines": [r.message]}
	_log("player_formation", {"a": player.id, "place": player.home_id})
	var lines: Array = [r.message]
	var p: Dictionary = _pass_season("")
	lines.append_array(_news_lines(p.news))
	if p.died:
		lines.append_array(death_lines())
	return {"ok": true, "lines": lines}


## Lets an owned linh thú go.
## Action. Returns {ok, lines, ...}; a frontend calls it through run() (ADR-0006).
func release_beast(beast_id: String) -> Dictionary:
	var g: Dictionary = _guard(false)
	if not g.ok:
		return g
	var r: Dictionary = beasts.release(player, beast_id)
	sync_player()
	return {"ok": r.ok, "lines": [r.message]}


## Plants a seed (herb template id or name) or transplants an owned herb item id.
## Action. Returns {ok, lines, ...}; a frontend calls it through run() (ADR-0006).
func plant(what: String) -> Dictionary:
	var g: Dictionary = _guard(false)
	if not g.ok:
		return g
	var r: Dictionary
	if db.has_record("items", what):
		r = field.transplant(player, sheet(), what)
	else:
		var herb_id: String = _herb_id(what)
		r = field.plant_seed(player, sheet(), herb_id)
	sync_player()
	return {"ok": r.ok, "lines": [r.message]}


## Harvests a plot, or every plot with [param plot] = -1.
## Action. Returns {ok, lines, ...}; a frontend calls it through run() (ADR-0006).
func harvest(plot: int) -> Dictionary:
	var g: Dictionary = _guard(false)
	if not g.ok:
		return g
	var lines: Array = []
	var planted: Dictionary = field.planted(player)
	var plots: Array = [plot] if plot >= 0 else planted.keys()
	if plots.is_empty():
		return {"ok": false, "lines": ["Nothing is planted."]}
	if plot < 0:
		# "harvest all" never pulls a herb younger than its mature age; name the plot to force it.
		var young: Array = plots.filter(func(p): return float(planted[p].age) < float(gd.herb(planted[p].template).get("mature_years", 0.0)))
		for p in young:
			lines.append("Plot %d: %s is not mature yet (%.1f / %.0f năm); left in the ground. Use 'harvest %d' to force." % [int(p), planted[p].name, float(planted[p].age), float(gd.herb(planted[p].template).mature_years), int(p)])
		plots = plots.filter(func(p): return not young.has(p))
	var any_ok: bool = false
	for p in plots:
		var tpl_h: String = str(planted.get(p, {}).get("template", ""))
		var r: Dictionary = field.harvest(player, int(p))
		lines.append(r.message)
		if r.ok and tpl_h != "":
			_codex_note(Codex.BOOK_HERBS, tpl_h, CodexStore.LEVEL_KNOWN)
		any_ok = any_ok or r.ok
	return {"ok": any_ok, "lines": lines}


## Eats a pill or uses a treasure. [param element] is the player's pick for a Linh Căn Quả;
## without a valid one the fruit is kept and the answer lists the choices.
## Action. Returns {ok, lines, ...}; a frontend calls it through run() (ADR-0006).
func use_item(item_id: String, element: String = "") -> Dictionary:
	var g: Dictionary = _guard(false)
	if not g.ok:
		return g
	if db.get_record("items", item_id).get("kind", "") == "treasure":
		var t: Dictionary = TreasureEffects.use(player, gd, db, rng, item_id, element)
		if t.has("unseal_item"):
			return {"ok": false, "lines": ["The seal finds nothing to open: the Đạo Đồ has no hidden clusters (rule 6, retired)."]}
		if t.get("needs_element", false):
			return {"ok": false, "needs_element": true, "options": t.options, "lines": TreasureEffects.preview_lines(player, gd, t.options, item_id)}
		if t.ok:
			_log_root_changes("player_linh_can_changed", t.changes)
			_codex_note_player_variants()
		_sync_and_rate()
		return {"ok": t.ok, "lines": [t.message]}
	var r: Dictionary = PillEffects.consume(player, gd, db, sheet(), item_id)
	var lines: Array = [r.message]
	if r.ok:
		_log_root_changes("player_root_purified", r.get("changes", []))
	if r.ok and float(r.get("tu_vi", 0.0)) > 0.0:
		var res: Dictionary = CultivationRules.add_tu_vi(player, gd, float(r.tu_vi))
		if res.stages > 0:
			lines.append("  Stage up! Now %s (+%d Đạo Đồ points)." % [gd.realm_label(player.realm_index, player.stage), res.tree_points])
		if res.bottleneck:
			lines.append("  Bình cảnh reached.")
	_sync_and_rate()
	return {"ok": r.ok, "lines": lines}


## Equips a pháp bảo in [param slot] ("weapon", "armour", "ring", "necklace" or "extra"); with none, the first
## fitting free base slot, then an extra slot (item-database.md rule 11).
## Action. Returns {ok, lines, ...}; a frontend calls it through run() (ADR-0006).
func equip(item_id: String, slot: String = "") -> Dictionary:
	var g: Dictionary = _guard(false)
	if not g.ok:
		return g
	var item: Dictionary = db.get_record("items", item_id)
	if item.is_empty() or item.owner_id != player.id or item.kind != "artifact":
		return {"ok": false, "lines": ["You own no pháp bảo %s." % item_id]}
	if player.equipped.has(item_id):
		return {"ok": false, "lines": ["Already equipped."]}
	var to: String = EquipSlots.slot_for(player, gd, db, sheet(), item, slot)
	if to == "":
		if slot != "":
			return {"ok": false, "lines": ["%s cannot go in the %s slot, or it is full." % [item.name, slot]]}
		return {"ok": false, "lines": ["No free slot fits %s." % item.name]}
	player.equipped.append(item_id)
	player.equip_slots[item_id] = to
	_codex_note_item(item)
	_sync_and_rate()
	var p: Dictionary = CombatPower.compute(player, gd, db, sheet())
	var where: String = "an extra slot" if to == EquipSlots.EXTRA else "the %s slot" % to
	var lines: Array = ["Equipped %s in %s. Chiến lực now %.0f." % [item.name, where, p.total]]
	if p.overflow.has(item_id):
		lines.append("  Warning: it is past your extra slots (%d); it adds nothing until a slot frees up (thần thức %.0f opens the next)." % [p.extra_limit, EquipSlots.next_slot_than_thuc(player, gd, sheet())])
	return {"ok": true, "lines": lines}


## Chooses the equipped pháp bảo to nurture (capability #3). Choosing another restarts the growth.
## Action. Returns {ok, lines, ...}; a frontend calls it through run() (ADR-0006).
func nurture(item_id: String) -> Dictionary:
	var g: Dictionary = _guard(false)
	if not g.ok:
		return g
	if not player.has_capability(3):
		return {"ok": false, "lines": ["You have not opened Dưỡng Bảo Nội Thể."]}
	if not player.equipped.has(item_id):
		return {"ok": false, "lines": ["%s is not equipped." % item_id]}
	if player.nurtured_id == item_id:
		return {"ok": false, "lines": ["Already nurtured (%d years)." % player.nurture_years]}
	var restarted: bool = player.nurtured_id != ""
	player.nurtured_id = item_id
	player.nurture_years = 0
	_sync_and_rate()
	var label: String = str(db.get_record("items", item_id).get("name", item_id))
	return {"ok": true, "lines": ["You begin nurturing %s within your body%s." % [label, "; the old growth is lost" if restarted else ""]]}


## Unequips a pháp bảo.
## Action. Returns {ok, lines, ...}; a frontend calls it through run() (ADR-0006).
func unequip(item_id: String) -> Dictionary:
	var g: Dictionary = _guard(false)
	if not g.ok:
		return g
	if not player.equipped.has(item_id):
		return {"ok": false, "lines": ["%s is not equipped." % item_id]}
	player.equipped.erase(item_id)
	player.equip_slots.erase(item_id)
	if player.nurtured_id == item_id:   # capability #3: the growth restarts with the next chosen treasure
		player.nurtured_id = ""
		player.nurture_years = 0
	_sync_and_rate()
	return {"ok": true, "lines": ["Unequipped %s." % db.get_record("items", item_id).get("name", item_id)]}


## Reads an owned manual: its technique joins the known list at layer 1 (cong-phap.md rule 4).
## Action. Returns {ok, lines, ...}; a frontend calls it through run() (ADR-0006).
func learn(item_id: String) -> Dictionary:
	var g: Dictionary = _guard(false)
	if not g.ok:
		return g
	var item: Dictionary = db.get_record("items", item_id)
	if not item.is_empty() and item.owner_id == player.id and item.kind == "diagram_manual":   # a formation manual
		var known: bool = player.known_diagrams.any(func(k): return str(k.id) == str(item.diagram_id))
		if known:
			return {"ok": false, "lines": ["You already know that formation."]}
		return learn_diagram(str(item.diagram_id))
	if item.is_empty() or item.owner_id != player.id or item.kind != "cong_phap":
		return {"ok": false, "lines": ["You own no manual %s." % item_id]}
	if not CongPhap.learn(player, item):
		return {"ok": false, "lines": ["You already know %s." % item.name]}
	_codex_note(Codex.BOOK_TECHNIQUES, str(item.get("tech_id", "")), CodexStore.LEVEL_KNOWN)
	_sync_and_rate()
	var lines: Array = ["You learn %s at layer 1. Put it in a slot with 'slot'." % item.name]
	if not CongPhap.usable(player, player.techniques[str(item.tech_id)].def):
		lines.append("  Your root lacks what it names, so it cannot be slotted yet.")
	return {"ok": true, "lines": lines}


## Changes a technique slot at the season start. [param slot] is main, second or aux with
## [param index]; key "" empties it. A change that would end the life needs [param confirm]
## (Realms rule 14). Returns {ok, lines, needs_confirm}.
## Action. Returns {ok, lines, ...}; a frontend calls it through run() (ADR-0006).
func set_slot(slot: String, index: int, key: String, confirm: bool = false) -> Dictionary:
	var g: Dictionary = _guard(false)
	if not g.ok:
		return g
	var before: Dictionary = {"main": player.main_tech, "second": player.second_tech, "aux": player.aux_tech.duplicate()}
	var r: Dictionary = CongPhap.set_slot(player, gd, slot, index, key)
	if not r.ok:
		return {"ok": false, "lines": [r.reason]}
	var cap: float = CultivationRules.lifespan(player, gd, sheet()).total
	if cap <= player.age and not confirm:
		player.main_tech = before.main
		player.second_tech = before.second
		player.aux_tech = before.aux
		return {"ok": false, "needs_confirm": true, "lines": ["Your lifespan falls to %d; you are %d: you will die of old age." % [int(cap), int(player.age)]]}
	_sync_and_rate()
	if cap <= player.age:
		_end_life("Thọ nguyên cạn kiệt ở tuổi %d" % int(player.age))
		return {"ok": true, "lines": death_lines()}
	var f: Dictionary = CongPhap.speed_factor(player, gd)
	return {"ok": true, "lines": ["Slots set. Speed factor: %s = x%.2f." % [f.label, f.mult]]}


# --- Formations Part I: the player's combat diagram (design/gdd/formations.md rules 1-12) ------------------------

## Rule 8 (user 2026-11-24: taught only, one at the start): the player knows the catalogue's starter diagram and has
## it set, the arts placed by fit (F4).
func _teach_starter_diagram() -> void:
	var sid: String = str(Diagrams.cfg(gd).get("starter", ""))
	var rec: Dictionary = Diagrams.record_of(gd, sid)
	if rec.is_empty() or player == null:
		return
	if not player.known_diagrams.any(func(k): return str(k.id) == sid):
		player.known_diagrams.append({"id": sid, "level": 1})
	if player.diagram.is_empty():
		player.diagram = {"id": sid, "level": 1, "placement": Diagrams.place(rec, _diagram_pool(), 1).placement, "lay": true}


## The arts a diagram's nodes can hold: the player's compiled art pool, [{id, tags}] in slot order.
func _diagram_pool() -> Array:
	var prof: FighterProfile = FighterCompiler.compile(player, gd, db, sheet())
	return [] if prof == null else prof.arts.map(func(a): return {"id": str(a.id), "tags": Array(a.tags_s)})


## Rules 2-4: sets the known diagram [param id] as the loadout ("" for the default line, the Plain Row), keeping its
## level and placing the arts by fit. Refused while an event waits, for an unknown id, or when its open nodes pass the
## art slots or its reservation the cap (rule 3, rule 9a). {ok, lines}.
## Action. Returns {ok, lines, ...}; a frontend calls it through run() (ADR-0006).
func set_diagram(id: String) -> Dictionary:
	var g: Dictionary = _guard(false)
	if not g.ok:
		return g
	if id == "":
		player.diagram = {}
		_sync_and_rate()
		return {"ok": true, "lines": ["The Plain Row: your arts in plain slots."]}
	var known: Array = player.known_diagrams.filter(func(k): return str(k.id) == id)
	var rec: Dictionary = Diagrams.record_of(gd, id)
	if known.is_empty() or rec.is_empty():
		return {"ok": false, "lines": ["You do not know that formation."]}
	var level: int = int(known[0].get("level", 1))
	var check: Dictionary = diagram_check(rec, level)
	if not bool(check.ok):
		return {"ok": false, "lines": [str(check.reason)]}
	var lay: bool = bool(player.diagram.get("lay", true))
	player.diagram = {"id": id, "level": level, "placement": Diagrams.place(rec, _diagram_pool(), Diagrams.level_eff(gd, level,
		player.skill_level("tran_phap"), player.has_capability(15), int(rec.get("max_level", 99)))).placement, "lay": lay}
	_sync_and_rate()
	return {"ok": true, "lines": ["%s set as your formation." % str(rec.get("name", id))]}


## Rule 8: the player learns the catalogue's diagram [param id] at level 1 (taught: by a sect, a manual; the screenshot
## fixtures). Already known: nothing changes. {ok, lines}.
## Action. Returns {ok, lines, ...}; a frontend calls it through run() (ADR-0006).
func learn_diagram(id: String) -> Dictionary:
	var rec: Dictionary = Diagrams.record_of(gd, id)
	if rec.is_empty():
		return {"ok": false, "lines": ["No such formation."]}
	if player.known_diagrams.any(func(k): return str(k.id) == id):
		return {"ok": true, "lines": ["You already know %s." % str(rec.get("name", id))]}
	player.known_diagrams.append({"id": id, "level": 1})
	_sync_and_rate()
	return {"ok": true, "lines": ["You learn %s (%s)." % [str(rec.get("name", id)), str(rec.get("name_vi", ""))]]}


## F3 and rule 7: raising the known diagram [param id] a level: {ok, reason, cost, target, cap}. The level cap is
## min(its max_level, Trận Pháp skill + 1) (+2 with the keystone); raising is done at home (the abode, rule 7) and costs
## raise_cost(grade, target) linh thạch (its materials are not in the game yet). Read-only.
func diagram_raise_check(id: String) -> Dictionary:
	var rec: Dictionary = Diagrams.record_of(gd, id)
	var known: Array = player.known_diagrams.filter(func(k): return str(k.id) == id)
	if rec.is_empty() or known.is_empty():
		return {"ok": false, "reason": "You do not know that formation.", "cost": 0, "target": 0, "cap": 0}
	var level: int = int(known[0].get("level", 1))
	var own: int = int(rec.get("max_level", 5))
	var cap: int = mini(mini(int(Diagrams.cfg(gd).strength.max_level), player.skill_level("tran_phap") + 1) + (2 if player.has_capability(15) else 0), own)
	var target: int = level + 1
	var cost: int = Diagrams.raise_cost(gd, int(rec.get("grade", 0)), target)
	var why: String = ""
	if level >= own:
		why = "%s has no higher level." % str(rec.get("name", id))
	elif level >= cap:
		why = "Your Trận Pháp skill caps it at level %d." % cap
	elif player.location_id != player.home_id:
		why = "Raise it at home (your abode)."
	elif float(player.linh_thach) < float(cost):
		why = "It costs %d linh thạch; you have %d." % [cost, int(player.linh_thach)]
	return {"ok": why == "", "reason": why, "cost": cost, "target": target, "cap": cap}


## F3: raises the known diagram [param id] a level (diagram_raise_check), paying its linh thạch (burn_formation,
## Formula H). The Set diagram keeps its placement; a node the new level opens starts empty.
## Action. Returns {ok, lines, ...}; a frontend calls it through run() (ADR-0006).
func raise_diagram(id: String) -> Dictionary:
	var g: Dictionary = _guard(false)
	if not g.ok:
		return g
	var chk: Dictionary = diagram_raise_check(id)
	if not bool(chk.ok):
		return {"ok": false, "lines": [str(chk.reason)]}
	MoneyLedger.player_pay(db, player, "", int(chk.cost), "formation")
	for k in player.known_diagrams:
		if str(k.id) == id:
			k["level"] = int(chk.target)
	if str(player.diagram.get("id", "")) == id:
		player.diagram["level"] = int(chk.target)
	_sync_and_rate()
	var rec: Dictionary = Diagrams.record_of(gd, id)
	return {"ok": true, "lines": ["%s raised to level %d (%d linh thạch)." % [str(rec.get("name", id)), int(chk.target), int(chk.cost)]]}


## Formations rule 8 and Sects rule 19a: whether the player's sect teaches them formation [param id] now. {ok, reason,
## cost, rank}: it must be on the sect's list (sects_teaching.json), the player's rank must reach the one it needs, their
## realm and Trận Pháp skill must meet the formation's, and they must hold its contribution. Read-only.
func sect_teach_check(id: String) -> Dictionary:
	var rec: Dictionary = Diagrams.record_of(gd, id)
	if player.sect_id == "" or not db.has_record("sects", player.sect_id) or rec.is_empty():
		return {"ok": false, "reason": "Join a sect to learn its formations.", "cost": 0, "rank": ""}
	var sect: Dictionary = db.get_record("sects", player.sect_id)
	var row: Array = Diagrams.taught_at(gd, str(sect.get("key", ""))).filter(func(r): return str(r.id) == id)
	if row.is_empty():
		return {"ok": false, "reason": "%s does not teach it." % str(sect.get("name", "")), "cost": 0, "rank": ""}
	var need: String = str(row[0].rank)
	var cost: int = Diagrams.learn_cost(gd, int(rec.get("grade", 0)))
	var why: String = ""
	if player.known_diagrams.any(func(k): return str(k.id) == id):
		why = "You know it."
	elif not Diagrams.rank_reaches(player.sect_rank, need):
		why = "Taught to the %s and above." % sect_members.rank_name(need)
	elif player.realm_index < int(rec.get("realm_min", 0)):
		why = "It needs %s." % gd.realm_label(int(rec.get("realm_min", 0)), 0)
	elif player.skill_level("tran_phap") < int(rec.get("skill_min", 0)):
		why = "It needs Trận Pháp %d." % int(rec.get("skill_min", 0))
	elif sect_members.contribution(player.sect_id, player.id) < cost:
		why = "It costs %d contribution; you hold %d." % [cost, sect_members.contribution(player.sect_id, player.id)]
	return {"ok": why == "", "reason": why, "cost": cost, "rank": need}


## Formations rule 8: the player's sect teaches them formation [param id] for its contribution (sect_teach_check).
## Action. Returns {ok, lines, ...}; a frontend calls it through run() (ADR-0006).
func learn_sect_diagram(id: String) -> Dictionary:
	var g: Dictionary = _guard(false)
	if not g.ok:
		return g
	var chk: Dictionary = sect_teach_check(id)
	if not bool(chk.ok):
		return {"ok": false, "lines": [str(chk.reason)]}
	var rec: Dictionary = sect_members.record(player.sect_id, player.id)
	rec["contribution"] = int(rec.contribution) - int(chk.cost)
	var r: Dictionary = learn_diagram(id)
	r["lines"] = Array(r.lines) + ["(%d contribution spent, %d left.)" % [int(chk.cost), int(rec.contribution)]]
	return r


## Rules 3 and 9a for the player: whether [param rec] at [param level] can be set now. {ok, reason}.
func diagram_check(rec: Dictionary, level: int) -> Dictionary:
	var sh: StatSheet = sheet()
	var l_eff: int = Diagrams.level_eff(gd, level, player.skill_level("tran_phap"), player.has_capability(15), int(rec.get("max_level", 99)))
	var prof: FighterProfile = FighterCompiler.compile(player, gd, db, sh)
	var sl: Array = gd.file("combat_library").get("constants", {}).get("slots_by_realm", [3, 4, 5, 6, 7])
	var slots: int = int(sl[clampi(player.realm_index, 0, sl.size() - 1)]) + int(sh.total("bonus_slots"))
	var k: CombatConstants = CombatConstants.from_game_data(gd)
	return Diagrams.can_set(rec, slots, 0.0 if prof == null else prof.reserved, sh.total("reserve_eff_pct"), k.reserve_cap, l_eff)


## Rule 4: puts art [param art_id] in node [param node] (1-based) of the Set diagram ("" empties it); an art already in
## another node moves here (each art sits in one node). Refused for a closed node or an art the player does not have.
## Action. Returns {ok, lines, ...}; a frontend calls it through run() (ADR-0006).
func place_diagram_art(node: int, art_id: String) -> Dictionary:
	var g: Dictionary = _guard(false)
	if not g.ok:
		return g
	var rec: Dictionary = Diagrams.record_of(gd, str(player.diagram.get("id", "")))
	if rec.is_empty():
		return {"ok": false, "lines": ["No formation is set: the Plain Row has no nodes."]}
	var nodes: Array = rec.get("nodes", [])
	if node < 1 or node > nodes.size():
		return {"ok": false, "lines": ["No such node."]}
	var level: int = Diagrams.level_eff(gd, int(player.diagram.get("level", 1)), player.skill_level("tran_phap"), player.has_capability(15), int(rec.get("max_level", 99)))
	if not Diagrams.is_open(nodes[node - 1], level):
		return {"ok": false, "lines": ["That node opens at level %d." % int(nodes[node - 1].get("unlock", 1))]}
	if art_id != "" and not _diagram_pool().any(func(a): return str(a.id) == art_id):
		return {"ok": false, "lines": ["You have no such art in your slots."]}
	var pl: Array = Array(player.diagram.get("placement", [])).duplicate()
	pl.resize(nodes.size())
	for i in pl.size():
		if pl[i] == null:
			pl[i] = ""
		if art_id != "" and str(pl[i]) == art_id:
			pl[i] = ""
	pl[node - 1] = art_id
	player.diagram["placement"] = pl
	_sync_and_rate()
	return {"ok": true, "lines": ["Node %d: %s." % [node, art_id if art_id != "" else "empty"]]}


## Rule 9: whether the player lays the Set diagram (burns fuel) in a foreseen fight, or always carries it.
## Action. Returns {ok, lines, ...}; a frontend calls it through run() (ADR-0006).
func set_diagram_lay(on: bool) -> Dictionary:
	var g: Dictionary = _guard(false)
	if not g.ok:
		return g
	if player.diagram.is_empty():
		return {"ok": false, "lines": ["No formation is set."]}
	player.diagram["lay"] = on
	_sync_and_rate()
	return {"ok": true, "lines": ["Lay in foreseen fights: %s." % ("on" if on else "off (carried at 70 %)")]}


## Local spiritual qi: the place's density plus density_bonus, the same sum the rate uses.
## The density the player would cultivate at in [param place_id] (Formula B's stack for them there, density_bonus
## included; the place's density in an old generated world).
## Read-only. Never changes the world (ADR-0006 decision 1).
func place_density(place_id: String) -> float:
	var p: Dictionary = db.get_record("places", place_id)
	var bonus: float = sheet().total("density_bonus")
	if p.get("qi", {}).is_empty():
		return float(p.get("density", 1.0)) + bonus + sheet().total("home_array_density")
	return float(LandQi.stacked_density(gd, player, p.qi, float(p.get("density", 1.0)), bonus, sheet().total("home_array_density"), sheet().total("formation_power_pct")).total)


## Read-only. Never changes the world (ADR-0006 decision 1).
func local_density(sh: StatSheet) -> float:
	var here: Dictionary = db.get_record("places", player.location_id)
	if here.get("qi", {}).is_empty():
		return float(here.get("density", 1.0)) + sh.total("density_bonus") + sh.total("home_array_density")
	return float(LandQi.stacked_density(gd, player, here.qi, float(here.get("density", 1.0)), sh.total("density_bonus"), sh.total("home_array_density"), sh.total("formation_power_pct")).total)


## True if a talisman would go on this attempt: one held, and none used this realm step.
## Read-only. Never changes the world (ADR-0006 decision 1).
func talisman_available() -> bool:
	return not _breakthrough_talisman().is_empty() and not player.talisman_used


func _breakthrough_talisman() -> Dictionary:
	for it in db.items_of(player.id):
		if it.kind == "talisman" and str(Talismans.def_of(gd, str(it.template)).get("use", "")) == "breakthrough":
			return it
	return {}


## Attempts the great breakthrough (Realms rules 7-11). The best matching pill and the
## talisman burn on a pill attempt. With a pill held but the condition unmet the attempt
## would be bare: that needs [param confirm_bare]. [param use_talisman] is the preview toggle.
## [param burn_life] commits capability #23's extra roll if this pill attempt fails.
## Action. Returns {ok, lines, ...}; a frontend calls it through run() (ADR-0006).
func breakthrough(confirm_bare: bool = false, use_talisman: bool = true, burn_life: bool = false) -> Dictionary:
	var g: Dictionary = _guard(true)
	if not g.ok:
		return g
	if not CultivationRules.at_bottleneck(player, gd):
		return {"ok": false, "lines": ["You are not at a bottleneck (%s, %.0f / %.0f tu vi)." % [gd.realm_label(player.realm_index, player.stage), player.tu_vi, CultivationRules.level_requirement(player, gd)]]}
	var next: Dictionary = gd.realm(player.realm_index + 1)
	var pill: Dictionary = Advisor.best_pill(self, str(next.entry_requirement.item_tag))
	if not pill.is_empty():
		pill = db.get_record("items", str(pill.id))   # the live record: the action burns it (Advisor returns copies)
	var sh: StatSheet = sheet()
	var cond: Dictionary = CultivationRules.breakthrough_condition(player, gd, local_density(sh))
	var is_pill: bool = not pill.is_empty() and bool(cond.met)
	if not is_pill and not CultivationRules.bare_attempt_left(player, gd):
		return {"ok": false, "lines": ["Bare attempts used up for this breakthrough."]}
	if not pill.is_empty() and not bool(cond.met) and not confirm_bare:
		var cap: int = int(gd.ladder().bare_attempt_cap)
		var bare: float = CultivationRules.breakthrough_chance(player, gd, sh, -1).total
		return {"ok": false, "needs_confirm": true, "lines": ["Condition not met: %s. This would be a bare attempt at %.3f%%, burning no pill and using 1 of the %d of %d bare attempts left." % [cond.text, 100.0 * bare, cap - player.bare_attempts, cap]]}
	var rank: int = int(pill.quality) if is_pill else -1
	var talisman: bool = is_pill and use_talisman and talisman_available()
	var chance: Breakdown = CultivationRules.breakthrough_chance(player, gd, sh, rank, talisman)
	var odds: float = chance.total
	var lines: Array = Array(chance.lines())
	var step_used: bool = player.cap_used.has("22") or player.cap_used.has("23")
	var left: float = CultivationRules.lifespan(player, gd, sh).total - player.age
	var tau: float = CultivationRules.talisman_value(gd) * CultivationRules.gate_factor(player, gd) if talisman else 0.0
	var held: int = int(pill.get("qty", 0)) if is_pill else 0
	if is_pill and player.has_capability(22) and not step_used and left < float(gd.capability(22).params.years_left):
		var s_guard: float = CultivationRules.guard_success(player, gd, held, odds - tau)
		odds = CultivationRules.q_desperate(gd, odds - tau, tau, s_guard) + tau
		player.cap_used["22"] = true
		step_used = true
		lines.append("  Hồi Quang Phản Chiếu lifts this attempt to %.1f%%." % (odds * 100.0))
	if talisman:
		var tal: Dictionary = _breakthrough_talisman()
		if not Talismans.keeps_talisman(player, gd, rng):
			tal["qty"] = int(tal.qty) - 1
			if int(tal.qty) <= 0:
				db.remove("items", tal.id)
		player.talisman_used = true
		lines.push_front("You burn %s." % tal.name)
	if is_pill:
		pill["qty"] = int(pill.qty) - 1
		if int(pill.qty) <= 0:
			db.remove("items", pill.id)
		lines.append("  Consumed 1 %s." % pill.name)
	var tk_step: Dictionary = TribulationRules.step_for(gd, player.realm_index)
	var tk_on: bool = TribulationRules.should_trigger(gd, player.realm_index, tribulation_enabled)
	var res: Dictionary = CultivationRules.resolve_attempt(player, gd, sh, rng, odds, is_pill, tk_on)
	lines.append("Roll %.0f vs %.0f%%." % [res.roll * 100.0, res.chance * 100.0])
	if not res.success and not res.died and is_pill and burn_life and player.has_capability(23) and not step_used:
		var burn: float = CultivationRules.burn_cost(player, gd)
		var life_left: float = CultivationRules.lifespan(player, gd, sheet()).total - player.age
		if life_left > burn:
			player.age += burn
			player.cap_used["23"] = true
			var q: float = CultivationRules.breakthrough_chance(player, gd, sheet(), rank, false).total
			var insight: float = CultivationRules.failure_insight(gd, player.failed_pills)
			var s_g: float = CultivationRules.guard_success(player, gd, maxi(held - 1, 0), q)
			var retry: float = CultivationRules.q_retry(gd, q, insight, s_g, CultivationRules.gate_factor(player, gd))
			lines.append("Thiêu Thọ Phá Cảnh: %.0f years burn; an extra roll at %.1f%%." % [burn, retry * 100.0])
			res = CultivationRules.resolve_attempt(player, gd, sheet(), rng, retry, true, tk_on)
			lines.append("Roll %.0f vs %.0f%%." % [res.roll * 100.0, res.chance * 100.0])
	if res.success and tk_on:
		var tk_lines: Array = _run_tribulation(tk_step, next, sh)
		lines.append_array(tk_lines)
	elif res.success:
		_log("player_breakthrough", {"a": player.id, "realm": next.name})
		lines.append("*** BREAKTHROUGH! You are now %s. +%d Đạo Đồ points. Lifespan rises to %.0f. ***" % [gd.realm_label(player.realm_index, player.stage), res.points, CultivationRules.lifespan(player, gd, sheet()).total])
		lines.append_array(_on_breakthrough_succeeded())
	else:
		_log("player_breakthrough_fail", {"a": player.id, "realm": next.name})
		lines.append("Breakthrough failed: -%.0f tu vi, tâm ma +%.1f, khí huyết now %d%%." % [res.tu_vi_lost, res.tam_ma_gained, int(player.vitality * 100.0)])
		if res.backlash:
			lines.append("  Tẩu hỏa nhập ma! Your meridians convulse.")
		if res.died:
			_end_life(player.death_cause, "", "backlash")
			lines.append_array(death_lines())
	_sync_and_rate()
	var t: Dictionary = {"died": false, "news": []}
	if not life_over:
		t = _pass_season("")
	lines.append_array(_news_lines(t.news))
	if t.died:
		lines.append_array(death_lines())
	elif not life_over:
		var bt_lines: Array = _raise_event_hook("on_breakthrough", {"success": bool(res.success), "realm_index": player.realm_index})
		lines.append_array(bt_lines)
		if bool(res.success) and not has_pending_event():
			lines.append_array(_raise_event_hook("on_realm_enter", {"realm_index": player.realm_index}))
	return {"ok": true, "lines": lines}


## Read-only. Previews the Heavenly Tribulation step, boss pool with weights, player setup,
## and escape-art warning without rolling or calling the wave draw (AC-TK-80, AC-TK-81).
func tribulation_preview() -> Dictionary:
	if player == null or gd == null:
		return {"enabled": false, "active": false, "step_id": "", "wave_count": 0, "pool": [], "setup": {}, "has_escape_art": false, "escape_warning": ""}
	var enabled: bool = tribulation_enabled
	var step: Dictionary = TribulationRules.step_for(gd, player.realm_index)
	var active: bool = enabled and not step.is_empty()
	var step_id: String = str(step.get("id", ""))
	var cfg: Dictionary = TribulationRules.config(gd)
	var wave_count: int = int(step.get("wave_count", cfg.get("wave_count", 3))) if not step.is_empty() else 0
	var pool_views: Array = []
	if step_id != "":
		for b in TribulationRules.bosses_for_step(gd, step_id):
			var rew: Dictionary = b.get("reward", {}) if b.get("reward") is Dictionary else {}
			var raw_arts: Array = Array(b.get("build", {}).get("arts", []))
			var art_names: Array = []
			for ra in raw_arts:
				if ra is Dictionary:
					art_names.append(str((ra as Dictionary).get("lib", (ra as Dictionary).get("id", ""))))
			pool_views.append({
				"id": str(b.get("id", "")),
				"name": str(b.get("name", "")),
				"main_kind": str(b.get("main_kind", "")),
				"weight": float(b.get("weight", 1.0)),
				"boss_pool_mult": float(b.get("boss_pool_mult", 1.0)),
				"off_estimate": float(b.get("off_estimate", 0.0)),
				"ehp_estimate": float(b.get("ehp_estimate", 0.0)),
				"off_shares": Dictionary(b.get("off_shares", {})).duplicate(true),
				"resist": Dictionary(b.get("resist", {})).duplicate(true),
				"arts": art_names,
				"reward_label": str(rew.get("label", str(rew.get("template", "")))),
				"provisional": bool(b.get("provisional", false)),
			})
	var sh: StatSheet = sheet()
	var prof: FighterProfile = FighterCompiler.compile(player, gd, db, sh)
	if prof != null:
		Diagrams.compile_read(gd, db, player, prof, sh)
	var has_escape: bool = TribulationRules.has_escape_art(prof)
	var art_ids: Array = []
	if prof != null:
		for a in prof.arts:
			art_ids.append(str(a.id))
	var place_tags: Array = _tribulation_place_tags()
	var stock: Dictionary = _tribulation_talisman_stock()
	return {
		"enabled": enabled,
		"active": active,
		"step_id": step_id,
		"from_realm": str(step.get("from_realm", "")),
		"to_realm": str(step.get("to_realm", "")),
		"wave_count": wave_count,
		"pool": pool_views,
		"setup": {
			"realm_index": player.realm_index,
			"realm_label": gd.realm_label(player.realm_index, player.stage),
			"vitality": player.vitality,
			"diagram_id": str(player.diagram.get("id", "")),
			"place_id": player.location_id,
			"place_tags": place_tags,
			"arts": art_ids,
			"talismans": stock,
		},
		"has_escape_art": has_escape,
		"escape_warning": "Escape arts cannot flee a Heavenly Tribulation — fleeing fails the tribulation." if has_escape else "",
	}


## Action. Claims one survival reward choice by 0-based [param choice_idx] after clearing a Heavenly Tribulation
## (AC-TK-51, AC-TK-52). Returns {ok, lines, item_id, choice}; a frontend calls it through run() (ADR-0006).
func claim_tribulation_reward(choice_idx: int) -> Dictionary:
	var g: Dictionary = _guard(false)
	if not g.ok:
		return g
	if pending_tribulation_reward.is_empty():
		return {"ok": false, "lines": ["No tribulation reward is waiting."]}
	var choices: Array = Array(pending_tribulation_reward.get("choices", []))
	if choice_idx < 0 or choice_idx >= choices.size():
		return {"ok": false, "lines": ["Choose a reward between 1 and %d." % choices.size()]}
	var choice: Dictionary = Dictionary(choices[choice_idx]).duplicate(true)
	var item: Dictionary = _create_tribulation_reward_item(choice)
	if item.is_empty():
		return {"ok": false, "lines": ["Could not materialize reward '%s'." % str(choice.get("label", choice.get("template", "?")))]}
	item["owner_id"] = player.id
	var iid: String = db.add("items", item)
	_codex_note_item(item)
	pending_tribulation_reward = {}
	_sync_and_rate()
	var lbl: String = str(choice.get("label", items.describe(item)))
	return {"ok": true, "lines": ["Claimed tribulation reward: %s [%s]." % [lbl, iid]], "item_id": iid, "choice": choice}


## Action. Alias for [method claim_tribulation_reward]. Returns {ok, lines, item_id, choice}.
func choose_tribulation_reward(index: int) -> Dictionary:
	return claim_tribulation_reward(index)


func _run_tribulation(tk_step: Dictionary, next_realm: Dictionary, sh: StatSheet) -> Array:
	var lines: Array = []
	var prof: FighterProfile = FighterCompiler.compile(player, gd, db, sh)
	var fuel_due: Array = []
	if prof != null:
		Diagrams.compile_for(gd, db, player, prof, sh, FightRequest.Situation.FORESEEN, -1, fuel_due)
	var stock: Dictionary = _tribulation_talisman_stock()
	var place_tags: Array = _tribulation_place_tags()
	var stock_norm: Dictionary = {}
	for sk in stock.keys():
		stock_norm[str(sk)] = int(stock[sk])
	var diag_place: Array = []
	for dp in Array(player.diagram.get("placement", [])):
		diag_place.append(str(dp))
	var prep := {
		"ward": str(player.diagram.get("id", "")),
		"diagram_level": int(player.diagram.get("level", 0)),
		"diagram_placement": diag_place,
		"diagram_lay": bool(player.diagram.get("lay", true)),
		"place_id": str(player.location_id),
		"consumable_stock": stock_norm,
	}
	var params := {
		"world_seed": seed_value,
		"char_id": player.id,
		"step": tk_step,
		"step_id": str(tk_step.get("id", "")),
		"player_profile": prof,
		"prep": prep,
		"place_tags": place_tags,
		"start_vitality": player.vitality,
		"abs_season": season_index(),
		"log_enabled": true,
	}
	var tk: Dictionary = TribulationRunner.run(params, gd, tribulation_fight_fn)
	last_tribulation = tk
	if not bool(tk.get("ok", false)):
		lines.append("Heavenly Tribulation error: %s" % str(tk.get("error", "unknown")))
		return lines
	var end_m: Dictionary = Dictionary(tk.get("end_meters", {}))
	if not end_m.is_empty():
		player.save_fight_meters(end_m)
	for due in fuel_due:
		Diagrams.pay_fuel(db, due[0], int(due[1]))
	# Rule 9 / AC-TK-53: decrement spent consumable stock once, whether the player survives or dies.
	_spend_tribulation_stock(Dictionary(tk.get("spent_stock", {})))
	for w in Array(tk.get("waves", [])):
		lines.append(str(w.get("header", "")))
		lines.append("  -> %s (%s, %.1f s | HP %.0f/%.0f, Qi %.0f/%.0f)" % [
			"CLEARED" if bool(w.get("cleared", false)) else "FAILED",
			str(w.get("ending", "")), float(w.get("seconds", 0.0)),
			float(w.get("health_end", 0.0)), float(w.get("health_max", 0.0)),
			float(w.get("qi_end", 0.0)), float(w.get("qi_max", 0.0)),
		])
	if bool(tk.get("survived", false)):
		var pts: int = CultivationRules.enter_next_realm(player, gd)
		var tb: Dictionary = Dictionary(tk.get("tempered_buff", {})).duplicate(true)
		if not tb.is_empty():
			tb["step_id"] = str(tk.get("step_id", ""))
			var replaced: bool = false
			for bi in player.tribulation_buffs.size():
				if str(Dictionary(player.tribulation_buffs[bi]).get("step_id", "")) == str(tb.step_id):
					player.tribulation_buffs[bi] = tb
					replaced = true
					break
			if not replaced:
				player.tribulation_buffs.append(tb)
		var boss_ids: Array = Array(tk.get("waves", [])).map(func(w): return str(w.get("boss_id", "")))
		var surv_text: String = str(gd.world_gen().history.texts.get("player_tribulation_survived", "{a} vượt qua Thiên Kiếp ({waves} đợt), tấn cấp {realm}."))
		surv_text = surv_text.replace("{a}", player.name).replace("{waves}", str(int(tk.waves_cleared))).replace("{realm}", str(next_realm.name))
		db.log_event(year, season, "player_tribulation_survived", surv_text, [player.id], [player.location_id], [], {
			"step_id": str(tk.step_id),
			"bosses": boss_ids,
			"waves_cleared": int(tk.waves_cleared),
			"cause": "tribulation",
		})
		_log("player_breakthrough", {"a": player.id, "realm": next_realm.name})
		var choices: Array = Array(tk.get("reward_choices", [])).duplicate(true)
		if not choices.is_empty():
			pending_tribulation_reward = {
				"step_id": str(tk.step_id),
				"choices": choices,
				"buff": tb.duplicate(true),
			}
		lines.append("*** HEAVENLY TRIBULATION CLEARED (%d/%d)! You are now %s. +%d Đạo Đồ points. Lifespan rises to %.0f. ***" % [
			int(tk.waves_cleared), int(tk.wave_count), gd.realm_label(player.realm_index, player.stage),
			pts, CultivationRules.lifespan(player, gd, sheet()).total])
		lines.append_array(_on_breakthrough_succeeded())
		lines.append_array(_raise_event_hook("on_tribulation_end", {
			"survived": true,
			"step_id": str(tk.step_id),
			"waves_cleared": int(tk.waves_cleared),
			"realm_index": player.realm_index,
		}))
		_events.append({
			"kind": "tribulation",
			"survived": true,
			"step_id": str(tk.step_id),
			"waves_cleared": int(tk.waves_cleared),
			"needs_reward": not choices.is_empty(),
		})
	else:
		var fb: Dictionary = Dictionary(tk.get("fatal_boss", {}))
		var fw: int = int(tk.get("fatal_wave", int(tk.get("waves_cleared", 0)) + 1))
		var fb_name: String = str(fb.get("name", str(fb.get("id", "?"))))
		var fail_text: String = str(gd.world_gen().history.texts.get("player_tribulation_failed", "{a} vẫn lạc dưới Thiên Kiếp tại đợt {wave} trước {boss}."))
		fail_text = fail_text.replace("{a}", player.name).replace("{wave}", str(fw)).replace("{boss}", fb_name)
		db.log_event(year, season, "player_tribulation_failed", fail_text, [player.id], [player.location_id], [], {
			"step_id": str(tk.step_id),
			"cause": "tribulation",
			"waves_cleared": int(tk.waves_cleared),
			"fatal_wave": fw,
			"fatal_boss": str(fb.get("id", "")),
			"fail_reason": str(tk.get("fail_reason", "")),
		})
		_end_life("Thiên Kiếp (%s, đợt %d)" % [fb_name, fw], "", "tribulation")
		_events.append({
			"kind": "tribulation",
			"survived": false,
			"step_id": str(tk.step_id),
			"waves_cleared": int(tk.waves_cleared),
			"fatal_wave": fw,
			"fatal_boss": fb_name,
		})
		lines.append("Heavenly Tribulation failed on wave %d against %s." % [fw, fb_name])
		lines.append_array(death_lines())
	return lines


## The player-only breakthrough_succeeded event: Mutation Awakening when capability #24 is held
## (linh-can.md rule 10). Only a formed variant is recorded.
func _on_breakthrough_succeeded() -> Array:
	breakthrough_succeeded.emit(player.realm_index)
	_events.append({"kind": "breakthrough", "realm_index": player.realm_index})
	if db != null and gd != null and player != null:
		_EventBudget.on_realm_change(db, gd, player, sheet())
		if quests != null:
			quests.on_reach(player, sheet(), year, season, {"season_idx": season_index()})
	if not player.has_capability(int(gd.attributes().linh_can.awakening_capability)):
		return []
	var formed: Array = player.linh_can.awakening_pass(gd, rng)
	var changes: Array = []
	for id in formed:
		changes.append({"what": "variant", "id": id, "from": 0, "to": player.linh_can.purity(id)})
	_log_root_changes("player_variant_awakened", changes)
	_codex_note_player_variants()
	return [TreasureEffects.variants_text(gd, player.linh_can, formed).strip_edges()] if not formed.is_empty() else []


## Opens a Đạo Đồ node; with [param walk_path] opens the whole shortest path.
## Action. Returns {ok, lines, ...}; a frontend calls it through run() (ADR-0006).
func tree_allocate(node_id: int, walk_path: bool) -> Dictionary:
	var g: Dictionary = _guard(false)
	if not g.ok:
		return g
	var targets: Array = tree.path_to(player, gd, node_id) if walk_path else [node_id]
	if walk_path and targets.size() > player.tree_points:
		return {"ok": false, "lines": ["The route costs %d points; you have %d." % [targets.size(), player.tree_points]]}
	if targets.is_empty():
		return {"ok": false, "lines": ["Nothing to open (already open or unreachable)."]}
	if targets.size() > player.tree_points:
		return {"ok": false, "lines": ["Path needs %d points; you have %d." % [targets.size(), player.tree_points]]}
	var lines: Array = []
	for nid in targets:
		var check: Dictionary = tree.can_allocate(player, int(nid), gd)
		if not check.ok:
			lines.append("Cannot open #%d %s: %s" % [int(nid), tree.node(int(nid)).get("name", ""), check.reason])
			break
		var opened: Dictionary = tree.open_node(player, int(nid), gd)
		lines.append("Opened #%d %s: %s" % [int(nid), tree.node(int(nid)).name, tree.describe_mods(int(nid), player.linh_can, gd)])
		for id in opened.road:
			lines.append("  %s purity +%s (now %s)." % [gd.element_label(str(id)), LinhCan.fmt(float(opened.road[id])), LinhCan.fmt(player.linh_can.purity(str(id)))])
		if int(opened.cap) > 0:
			lines.append("  Capability gained: %s. %s" % [gd.capability(int(opened.cap)).name, gd.capability(int(opened.cap)).desc])
	_sync_and_rate()
	return {"ok": true, "lines": lines}


## The starts the player's root may pick (Đạo Đồ rule 3), as {id, key, name, current}.
## Read-only. Never changes the world (ADR-0006 decision 1).
func tree_starts() -> Array:
	var out: Array = []
	var cur: int = tree.start_of_character(player)
	for sid in tree.starts_for(player.linh_can, gd):
		out.append({"id": sid, "key": str(tree.start_of[sid]), "name": str(tree.node(sid).name), "current": sid == cur})
	return out


## Changes the player's start to the start of [param key] (an element or variant id the root holds), allowed while no
## Dao mark has been opened yet: at birth, and after a migrated save (rule 19). Returns {ok, lines}.
## Action. Returns {ok, lines, ...}; a frontend calls it through run() (ADR-0006).
func tree_choose_start(key: String) -> Dictionary:
	if player.tree_nodes.size() > 1:
		return {"ok": false, "lines": ["The start is fixed once a Dao mark is open."]}
	var sid: int = int(tree.starts.get(key, -1))
	if sid < 0 or not tree.starts_for(player.linh_can, gd).has(sid):
		return {"ok": false, "lines": ["Your root may start at: %s." % ", ".join(tree_starts().map(func(x): return x.key))]}
	player.tree_nodes = [sid]
	_sync_and_rate()
	return {"ok": true, "lines": ["You start at the %s (#%d)." % [str(tree.node(sid).name), sid]]}


## Sets the player's start: [param key]'s if the root holds it, else the strongest element's (rule 3).
func _choose_start(key: String) -> void:
	var sid: int = int(tree.starts.get(key, -1))
	if sid < 0 or not tree.starts_for(player.linh_can, gd).has(sid):
		sid = tree.npc_start(player.linh_can, gd)
	player.tree_nodes = [sid] if sid >= 0 else []
	player.tree_baseline = DaoDoTree.BASELINE


func _start_line() -> String:
	var sid: int = tree.start_of_character(player)
	var others: Array = tree_starts().filter(func(x): return not x.current)
	var s: String = "Đạo Đồ start: %s (#%d)." % [str(tree.node(sid).get("name", "?")), sid]
	if not others.is_empty():
		s += " Before opening a Dao mark you may move it: 'tree start <%s>'." % "|".join(others.map(func(x): return x.key))
	return s


## Buys an item from the market here.
## Action. Returns {ok, lines, ...}; a frontend calls it through run() (ADR-0006).
func buy(item_id: String) -> Dictionary:
	var g: Dictionary = _guard(false)
	if not g.ok:
		return g
	var r: Dictionary = market.buy(player, sheet(), player.location_id, item_id)
	if bool(r.get("ok", false)):
		_codex_note_item(db.get_record("items", item_id))
	sync_player()
	return {"ok": r.ok, "lines": [r.message]}


## Sells one unit of an owned item at the market here.
## Action. Returns {ok, lines, ...}; a frontend calls it through run() (ADR-0006).
func sell(item_id: String) -> Dictionary:
	var g: Dictionary = _guard(false)
	if not g.ok:
		return g
	var r: Dictionary = market.sell(player, sheet(), player.location_id, item_id)
	sync_player()
	return {"ok": r.ok, "lines": [r.message]}


## NPC Traits F3: at the player's first meeting with [param npc], its attitude to the player starts at att0 (its
## opinion of the player from traits, ties and sect, plus a quarter of the player's standing with its sect). Later
## meetings change nothing here (Quests' attitude rules take over).
## Internal: a frontend never calls it (ADR-0006 decision 2).
func meet(npc: Dictionary) -> void:
	if Ties.enabled(gd):   # NPC Relationships rule 6: the met list; someone pushed off it is tested at the next S8b
		var m: Dictionary = Ties.met_after(gd, player.met_list, str(npc.id))
		player.met_list = m.list
		for x in m.dropped:
			TieTick.enqueue(db, {"kind": "notability", "pid": str(x)})
		sync_player()
	var st: float = 0.0
	if str(npc.get("sect_id", "")) != "":
		st = sect_members.standing(str(npc.sect_id), player.id)
	var prec: Dictionary = db.get_record("people", player.id)
	if prec.is_empty():
		prec = player.to_dict()
	NpcTraits.first_meeting(gd, db, npc, prec, st, int(gd.session().talk.hostile_threshold))
	var ck: String = str(npc.get("cast_key", ""))
	if ck != "":
		_codex_note(Codex.BOOK_CAST, ck, CodexStore.LEVEL_SEEN)
	var n_lc: Variant = npc.get("linh_can", {})
	if n_lc is Dictionary:
		for vid in Dictionary((n_lc as Dictionary).get("variants", {})).keys():
			_codex_note(Codex.BOOK_VARIANTS, str(vid), CodexStore.LEVEL_SEEN)


## Executes an NPC Interaction & Dialogue (#30) verb (17 base verbs + 19 trait [code]verb:[/code] hooks)
## against [param person_id]. Returns [code]{ok, accepted, lines, reply, effect_lines, voice_meta, ...}[/code].
## Action. Returns {ok, lines, ...}; a frontend calls it through run() (ADR-0006).
func interact(person_id: String, verb_id: String, opts: Dictionary = {}) -> Dictionary:
	var g: Dictionary = _guard(false)
	if not g.ok:
		return g
	var res: Dictionary = interactions.execute(self, person_id, verb_id, opts)
	sync_player()
	return res


## Backwards-compatible greeting helper delegating cleanly to [method interact].
## Action. Returns {ok, lines, ...}; a frontend calls it through run() (ADR-0006).
func greet(person_id: String) -> Dictionary:
	return interact(person_id, "greet")


## Talks to a person at the same place (once per season each).
## Action. Returns {ok, lines, ...}; a frontend calls it through run() (ADR-0006).
func talk(npc_id: String, player_line: String) -> Dictionary:
	var g: Dictionary = _guard(false)
	if not g.ok:
		return g
	var npc: Dictionary = db.get_record("people", npc_id)
	if npc.is_empty() or not npc.alive or npc.get("is_player", false):
		return {"ok": false, "lines": ["No living person %s." % npc_id]}
	if str(npc.location_id) != player.location_id:
		return {"ok": false, "lines": ["%s is not here." % npc.name]}
	if npc.get("is_beast", false):
		return {"ok": false, "lines": ["%s only growls." % npc.name]}
	if int(npc.get("last_talk_season", -1)) == season_index():
		return {"ok": false, "lines": ["You already spoke with %s this season." % npc.name]}
	meet(npc)   # before the talk is noted: a past talk counts as a meeting
	npc["last_talk_season"] = season_index()
	var ctx: Dictionary = event_context()
	var r: Dictionary = narrator.talk(npc, ctx, player_line, rng)
	var cfg: Dictionary = gd.session().talk
	var change: int = clampi(int(r.attitude_change), -int(cfg.attitude_change_max), int(cfg.attitude_change_max))
	npc["attitude"] = clampi(int(npc.get("attitude", 0)) + change, int(cfg.relationship_min), int(cfg.relationship_max))
	var lines: Array = [r.reply]
	if r.rumor_id != "":
		var ent: Dictionary = db.lookup(r.rumor_id)
		lines.append("  (hint: %s %s — 'db show %s')" % [r.rumor_id, str(ent.get("name", ent.get("text", ""))).substr(0, 60), r.rumor_id])
	lines.append("  [%s | attitude %+d -> %d]%s" % [r.source, change, int(npc.attitude), (" " + r.error) if r.error != "" else ""])
	return {"ok": true, "lines": lines}


## Resolves the pending event with choice [param index] (0-based).
## Action. Returns {ok, lines, ...}; a frontend calls it through run() (ADR-0006).
func choose(index: int) -> Dictionary:
	var g: Dictionary = _guard(false)
	if not g.ok:
		return g
	if not has_pending_event():
		return {"ok": false, "lines": ["No event is waiting."]}
	var check: Dictionary = resolver.can_choose(player, pending_event, index)
	if not check.ok:
		return {"ok": false, "lines": ["Cannot choose that: %s." % check.reason]}
	var event: Dictionary = pending_event
	var ev_src_pre: String = str(event.get("source", ""))
	var sh: StatSheet = sheet()
	var beasts_before: int = player.beasts.size()
	var result: Dictionary
	var story: Dictionary
	if event_engine != null:
		var emit_fe: bool = ev_src_pre != "template:provoke_duel" and not ev_src_pre.begins_with("interaction:")
		result = event_engine.resolve_event(player, sh, rng, event, index, year, season, {
			"map_knowledge": knowledge,
			"emit_fight_end_hook": emit_fe,
		})
		story = narrator.narrate(event, index, result)
		var log_id: String = str(result.get("event_log_id", ""))
		if log_id != "":
			var ev_log: Dictionary = db.get_record("events", log_id)
			if not ev_log.is_empty():
				var ev_data: Dictionary = Dictionary(ev_log.get("data", {}))
				ev_data["narration"] = story.text
				if pending_meta.has("source") and str(ev_data.get("source", "")) == "":
					ev_data["source"] = pending_meta.get("source", "")
				ev_log["data"] = ev_data
	else:
		result = resolver.resolve(player, sh, rng, event, index)
		story = narrator.narrate(event, index, result)
		var people: Array = [player.id]
		if str(event.get("npc_id", "")) != "":
			people.append(event.npc_id)
		db.log_event(year, season, "story", "%s — %s: %s" % [event.title, event.choices[index].label, "thành công" if result.success else "thất bại"],
			people, [event.place_id], result.items, {"narration": story.text, "effects": result.lines, "source": pending_meta.get("source", "")})
	# AC-WG-56: sync uncovered hidden chronicles into the profile Codex History book.
	for raw_cid in Array(result.get("uncovered_chronicles", [])):
		var cid: String = str(raw_cid)
		if cid != "" and codex != null:
			_codex_note(Codex.BOOK_HISTORY, cid, CodexStore.LEVEL_KNOWN)
	if player.beasts.size() > beasts_before:
		for bi in range(beasts_before, player.beasts.size()):
			var brec: Dictionary = db.get_record("people", str(player.beasts[bi]))
			var bkey: String = str(brec.get("cast_key", brec.get("species", "")))
			if bkey != "":
				_codex_note(Codex.BOOK_BEASTS, bkey, CodexStore.LEVEL_KNOWN)
	for gained_iid in Array(result.get("items", [])):
		_codex_note_item(db.get_record("items", str(gained_iid)))
	var ev_src: String = str(event.get("source", ""))
	if ev_src == "template:loan_collection" and index == 0 and bool(result.success):
		InteractionService.mark_loans_repaid(db, player.id, str(event.npc_id))
	elif ev_src.begins_with("template:tien_kiep_") and index == 0 and bool(result.success) and str(event.get("npc_id", "")) != "" and Ties.enabled(gd):
		var sk_tie: String = "rival" if ev_src == "template:tien_kiep_cuu_thu" else "friend"
		TieTick.enqueue(db, {"kind": "soft", "holder": str(event.npc_id), "other": player.id, "sk": sk_tie, "delta": 25, "cause": {"kind": "past_life"}})
	var lines: Array = ["> " + str(event.choices[index].label), ""]
	lines.append(story.text)
	lines.append("")
	for l in result.lines:
		lines.append("  " + l)
	if story.error != "":
		lines.append("  (%s)" % story.error)
	# Template Quests (#31): advance linked quest event stage if this event belonged to a quest.
	var qid_ev: String = str(event.get("quest_id", ""))
	if qid_ev != "" and quests != null and not bool(result.died):
		var q_res: Dictionary = quests.trigger_stage_event(player, sheet(), rng, qid_ev, {
			"event_result": bool(result.success),
			"year": year,
			"season": season,
			"season_idx": season_index(),
		})
		if bool(q_res.get("stage_completed", false)):
			lines.append("  Quest stage advanced (%s)." % qid_ev)
	# Post-duel Mercy (Event Engine Rule 17, AC-EV-30; Dialogue #30 provoke_duel compatibility).
	var mercy_id: String = str(result.get("mercy_npc_id", result.get("mercy_target_id", "")))
	if mercy_id != "" and not bool(result.died):
		if ev_src == "template:provoke_duel":
			pending_event = InteractionService.build_mercy_event(db, player, mercy_id, player.location_id, year)
			pending_meta = {"source": "interaction:mercy_choice", "warnings": [], "llm_error": ""}
		else:
			pending_event = {}
			pending_meta = {}
			pending_mercy = {
				"event": event.duplicate(true),
				"choice_index": index,
				"target_id": mercy_id,
				"title": str(event.get("title", "")),
			}
	else:
		pending_event = {}
		pending_meta = {}
	if result.died:
		var killer_id: String = str(event.get("npc_id", "")) if str(event.choices[index].check.type) == "combat" else ""
		var ckey: String = "duel" if killer_id != "" else "event"
		_end_life(player.death_cause, killer_id, ckey)
		lines.append_array(death_lines())
	elif not has_pending_event() and not has_pending_mercy() and event_engine != null:
		# AC-EV-43: drain any queued hook/follow-up under the season pacing cap after resolution.
		var next_ev: Dictionary = event_engine.drain_queue(player, sheet(), rng, year, season, _event_extras())
		if not next_ev.is_empty():
			lines.append_array(_activate_engine_event(next_ev, {"queued": true}))
	_sync_and_rate()
	return {"ok": true, "lines": lines}


## Resolves the pending post-duel cultivator Mercy choice (Event Engine Rule 17, AC-EV-30).
## [param kill] == false spares the foe ([code]spared_by[/code] flag); true kills via [WorldTicker].
## Action. Returns {ok, lines, killed, target_id}; a frontend calls it through run() (ADR-0006).
func choose_mercy(kill: bool) -> Dictionary:
	var g: Dictionary = _guard(false)
	if not g.ok:
		return g
	if not has_pending_mercy():
		if has_pending_event() and str(pending_event.get("source", "")) == "interaction:mercy_choice":
			return choose(1 if kill else 0)
		return {"ok": false, "lines": ["No mercy decision is waiting."]}
	var target_id: String = str(pending_mercy.get("target_id", ""))
	var mres: Dictionary = resolver.resolve_mercy(player, target_id, kill, year, season)
	pending_mercy = {}
	var lines: Array = Array(mres.get("lines", [])).duplicate()
	if not has_pending_event() and event_engine != null and not life_over:
		var next_ev: Dictionary = event_engine.drain_queue(player, sheet(), rng, year, season, _event_extras())
		if not next_ev.is_empty():
			lines.append_array(_activate_engine_event(next_ev, {"queued": true}))
	_sync_and_rate()
	return {
		"ok": bool(mres.get("ok", true)),
		"killed": bool(mres.get("killed", false)),
		"target_id": target_id,
		"lines": lines,
	}


# --- Template Quests (#31) Actions (ADR-0006) ----------------------------------------

## Accepts an offered or board quest [param quest_id] (Quests Rule 7, AC-QS-01, AC-QS-44).
## Action. Returns {ok, lines, quest, reason}; a frontend calls it through run() (ADR-0006).
func quest_accept(quest_id: String) -> Dictionary:
	var g: Dictionary = _guard(false)
	if not g.ok:
		return g
	if quests == null:
		return {"ok": false, "reason": "quests_unavailable", "lines": ["Quest service is unavailable."]}
	var res: Dictionary = quests.accept(player, quest_id, season_index(), {
		"year": year,
		"place_id": player.location_id,
	})
	_sync_and_rate()
	var lines: Array = []
	if bool(res.get("ok", false)):
		var q: Dictionary = Dictionary(res.get("quest", {}))
		lines.append("Accepted quest: %s [%s]." % [str(q.get("name", quest_id)), str(q.get("id", quest_id))])
	else:
		lines.append("Cannot accept quest '%s': %s." % [quest_id, str(res.get("reason", "unknown"))])
	res["lines"] = lines
	return res


## Declines an open person/sect quest offer [param quest_id] (Quests Rule 7, AC-QS-45..47).
## Action. Returns {ok, lines, quest, reason}; a frontend calls it through run() (ADR-0006).
func quest_decline(quest_id: String) -> Dictionary:
	var g: Dictionary = _guard(false)
	if not g.ok:
		return g
	if quests == null:
		return {"ok": false, "reason": "quests_unavailable", "lines": ["Quest service is unavailable."]}
	var res: Dictionary = quests.decline(quest_id, season_index(), year)
	_sync_and_rate()
	var lines: Array = []
	if bool(res.get("ok", false)):
		lines.append("Declined quest offer '%s'." % quest_id)
	else:
		lines.append("Cannot decline quest '%s': %s." % [quest_id, str(res.get("reason", "unknown"))])
	res["lines"] = lines
	return res


## Abandons an active quest [param quest_id] (or drops an orphaned quest with no penalty; AC-QS-49, AC-QS-53).
## Action. Returns {ok, lines, quest, reason}; a frontend calls it through run() (ADR-0006).
func quest_abandon(quest_id: String) -> Dictionary:
	var g: Dictionary = _guard(false)
	if not g.ok:
		return g
	if quests == null:
		return {"ok": false, "reason": "quests_unavailable", "lines": ["Quest service is unavailable."]}
	var res: Dictionary = quests.abandon(player, quest_id, year, season, {"season_idx": season_index()})
	_sync_and_rate()
	var lines: Array = []
	if bool(res.get("ok", false)):
		lines.append("Abandoned quest '%s'." % quest_id)
	else:
		lines.append("Cannot abandon quest '%s': %s." % [quest_id, str(res.get("reason", "unknown"))])
	res["lines"] = lines
	return res


## Drops an orphaned quest [param quest_id] cleanly with no penalty (Quests Rule 10, AC-QS-53).
## Action. Returns {ok, lines, quest, reason}; a frontend calls it through run() (ADR-0006).
func quest_drop(quest_id: String) -> Dictionary:
	var g: Dictionary = _guard(false)
	if not g.ok:
		return g
	if quests == null:
		return {"ok": false, "reason": "quests_unavailable", "lines": ["Quest service is unavailable."]}
	var res: Dictionary = quests.drop_orphaned(player, quest_id, year, season, {"season_idx": season_index()})
	_sync_and_rate()
	var lines: Array = []
	if bool(res.get("ok", false)):
		lines.append("Dropped orphaned quest '%s'." % quest_id)
	else:
		lines.append("Cannot drop quest '%s': %s." % [quest_id, str(res.get("reason", "unknown"))])
	res["lines"] = lines
	return res


## Submits [param item_id] (or linh thạch when empty) for a [code]deliver[/code] quest stage (1 season; AC-QS-61).
## Action. Returns {ok, lines, ...}; a frontend calls it through run() (ADR-0006).
func quest_deliver(quest_id: String, item_id: String = "") -> Dictionary:
	var g: Dictionary = _guard(true)
	if not g.ok:
		return g
	if quests == null:
		return {"ok": false, "reason": "quests_unavailable", "lines": ["Quest service is unavailable."]}
	var res: Dictionary = quests.submit_deliver(player, quest_id, item_id, year, season, {"season_idx": season_index()})
	if not bool(res.get("ok", false)):
		res["lines"] = ["Cannot deliver for quest '%s': %s." % [quest_id, str(res.get("reason", "unknown"))]]
		return res
	var lines: Array = ["Delivered item for quest '%s'." % quest_id]
	if bool(res.get("action_spent", true)) and not life_over:
		var p: Dictionary = _pass_season("")
		lines.append_array(_news_lines(p.news))
		if p.died:
			lines.append_array(death_lines())
	_sync_and_rate()
	res["lines"] = lines
	return res


## Spends one season on a quest's [code]mission[/code] stage with [code]mission_income = 0[/code] (AC-QS-62, AC-QS-69).
## Action. Returns {ok, lines, mission_income, ...}; a frontend calls it through run() (ADR-0006).
func quest_mission(quest_id: String) -> Dictionary:
	var g: Dictionary = _guard(true)
	if not g.ok:
		return g
	if quests == null:
		return {"ok": false, "reason": "quests_unavailable", "mission_income": 0, "lines": ["Quest service is unavailable."]}
	var res: Dictionary = quests.run_mission_stage(player, quest_id, year, season, {"season_idx": season_index()})
	if not bool(res.get("ok", false)):
		res["lines"] = ["Cannot work mission stage for '%s': %s." % [quest_id, str(res.get("reason", "unknown"))]]
		return res
	var lines: Array = ["Worked quest mission stage (%d/%d season(s), 0 mission income)." % [
		int(res.get("seasons_done", 1)), int(res.get("seasons_needed", 1))]]
	var p: Dictionary = _pass_season("")
	lines.append_array(_news_lines(p.news))
	if p.died:
		lines.append_array(death_lines())
	_sync_and_rate()
	res["mission_income"] = 0
	res["lines"] = lines
	return res


## Starts the current [code]event[/code] or [code]defeat[/code] stage of [param quest_id] (1 season).
## Action. Returns {ok, lines, ...}; a frontend calls it through run() (ADR-0006).
func quest_start_stage(quest_id: String) -> Dictionary:
	var g: Dictionary = _guard(true)
	if not g.ok:
		return g
	if quests == null:
		return {"ok": false, "reason": "quests_unavailable", "lines": ["Quest service is unavailable."]}
	var q: Dictionary = quests.get_quest(quest_id)
	if q.is_empty() or not (str(q.get("state", "")) in ["active", "orphaned"]):
		return {"ok": false, "reason": "quest_not_active", "lines": ["Quest '%s' is not active." % quest_id]}
	var plan_q: Dictionary = Dictionary(q.get("plan", q))
	var stages: Array = Array(plan_q.get("stages", q.get("stages", [])))
	var st_idx: int = clampi(int(q.get("stage", 1)) - 1, 0, maxi(0, stages.size() - 1))
	if stages.is_empty():
		return {"ok": false, "reason": "no_stages", "lines": ["Quest '%s' has no stages." % quest_id]}
	var st: Dictionary = Dictionary(stages[st_idx])
	var kind: String = str(st.get("kind", ""))
	if kind == "event":
		var res: Dictionary = quests.trigger_stage_event(player, sheet(), rng, quest_id, {
			"auto_pass": false,
			"year": year,
			"season": season,
			"season_idx": season_index(),
		})
		if not bool(res.get("ok", false)):
			res["lines"] = ["Cannot start event stage for '%s': %s." % [quest_id, str(res.get("reason", "unknown"))]]
			return res
		var lines: Array = []
		var raw_ev: Dictionary = Dictionary(res.get("event", {}))
		if bool(res.get("pending", false)) and not raw_ev.is_empty():
			var cstat: String = str(raw_ev.get("check_stat", st.get("check_stat", "")))
			var cdiff: float = float(raw_ev.get("check_difficulty", st.get("check_difficulty", 50.0)))
			var ev_obj := {
				"id": str(raw_ev.get("id", "qev_%s" % quest_id)),
				"template_id": str(raw_ev.get("id", "qev_%s" % quest_id)),
				"source": "quest:%s" % quest_id,
				"kind": "story",
				"quest_id": quest_id,
				"story_instance_id": str(raw_ev.get("story_id", q.get("story_id", ""))),
				"story_id": str(raw_ev.get("story_id", q.get("story_id", ""))),
				"story_name": str(q.get("name", quest_id)),
				"story_stage": "stage_%d" % int(q.get("stage", 1)),
				"chain_id": str(raw_ev.get("chain_id", q.get("chain_id", ""))),
				"title": str(raw_ev.get("title", q.get("name", "Sự kiện ủy thác"))),
				"text": str(raw_ev.get("text", st.get("description", "Bạn bắt tay xử lý bước ủy thác này."))),
				"place_id": str(raw_ev.get("place_id", st.get("place_id", player.location_id))),
				"npc_id": str(raw_ev.get("target_id", st.get("target_id", ""))),
				"choices": [
					{
						"label": "Thực hiện",
						"check": {"type": "stat", "stat": cstat, "difficulty": cdiff} if cstat != "" else {"type": "none"},
						"always": [],
						"success": {"text": "Bạn hoàn tất bước ủy thác thuận lợi.", "effects": []},
						"failure": {"text": "Mọi việc không suôn sẻ như dự tính.", "effects": []},
					},
					{
						"label": "Tạm lùi chờ thời cơ",
						"check": {"type": "none"},
						"always": [],
						"success": {"text": "Bạn tạm rút lui để chuẩn bị lại.", "effects": []},
						"failure": {"text": "", "effects": []},
					},
				],
			}
			lines.append_array(_activate_engine_event(ev_obj, {"quest_id": quest_id}))
		var p: Dictionary = _pass_season("")
		lines.append_array(_news_lines(p.news))
		if p.died:
			lines.append_array(death_lines())
		_sync_and_rate()
		res["lines"] = lines
		return res
	if kind == "defeat":
		var defeat_fight_fn: Callable = Callable()
		var tid: String = str(st.get("target_id", ""))
		if bool(gd.combat().get("fight_engine", {}).get("enabled", false)) and tid != "" and db.has_record("people", tid):
			var trec_chk: Dictionary = db.get_record("people", tid)
			if bool(trec_chk.get("alive", true)):
				defeat_fight_fn = func(_q: Dictionary, stage_d: Dictionary, pl: Character) -> Variant:
					var target_id: String = str(stage_d.get("target_id", tid))
					var trec: Dictionary = db.get_record("people", target_id)
					if trec.is_empty() or not bool(trec.get("alive", true)):
						return ""
					var sit_raw: Variant = stage_d.get("situation", FightRequest.Situation.FORESEEN)
					var sit: int = int(sit_raw) if (sit_raw is int or sit_raw is float) else FightRequest.Situation.FORESEEN
					var gtags: Array = Array(stage_d.get("ground_tags", []))
					var no_heal: bool = bool(stage_d.get("no_heal", false))
					var fought: Dictionary = resolver.fight_check(pl, sheet(), Character.from_dict(trec), rng, sit, gtags, no_heal)
					if not bool(fought.get("ran", false)):
						return ""
					match str(fought.get("code", "draw")):
						"A":
							return "knockout"
						"B":
							return "down"
						"flight":
							return "flight"
						_:
							return "draw"
		var dres: Dictionary = quests.run_defeat_stage(player, sheet(), rng, quest_id, defeat_fight_fn, {
			"year": year,
			"season": season,
			"season_idx": season_index(),
		})
		if not bool(dres.get("ok", false)):
			dres["lines"] = ["Cannot start defeat stage for '%s': %s." % [quest_id, str(dres.get("reason", "unknown"))]]
			return dres
		var lines_d: Array = ["Quest combat resolved: %s." % str(dres.get("result", "done"))]
		if bool(dres.get("action_spent", false)) and not life_over:
			var pd: Dictionary = _pass_season("")
			lines_d.append_array(_news_lines(pd.news))
			if pd.died:
				lines_d.append_array(death_lines())
		_sync_and_rate()
		dres["lines"] = lines_d
		return dres
	return {"ok": false, "reason": "stage_not_startable", "lines": ["Current stage '%s' cannot be started via quest_start_stage." % kind]}


## Asks [param npc_id] for work through the Dialogue #30 [code]work[/code] bridge (Quests Rule 2, AC-QS-154).
## Action. Returns {ok, lines, ...}; a frontend calls it through run() (ADR-0006).
func quest_ask_work(npc_id: String) -> Dictionary:
	return interact(npc_id, "work")


# --- Death & Succession (Codex & Karmic Carryover #12) -------------------------------

func _end_life(cause: String, killer_id: String = "", cause_key: String = "") -> void:
	if life_over:
		return
	life_over = true
	_finish_ratings(false)
	# Snapshot pre-death relationships, disciples, sect, region, and surname BEFORE S8b removes the dead player's ties.
	_last_death_player_id = player.id
	_last_death_killer = killer_id
	_last_death_sect_id = player.sect_id
	_last_death_region_id = str(db.get_record("places", player.location_id).get("region_id", ""))
	_last_death_surname = Families.surname_of(gd, player.name)
	_snapshot_pre_death_ties()

	# Sync live player state before world death settlement.
	sync_player()
	var p_rec: Dictionary = db.get_record("people", player.id)

	# Settle world death (Rule 4, AC-CK-04: estate, sect leader succession, bereavement, S8b) BEFORE offering succession.
	var estate_heir: String = _resolve_player_estate_heir(p_rec, killer_id)
	_settle_player_purse(estate_heir)

	player.alive = false
	player.death_cause = cause
	p_rec["alive"] = false
	p_rec["death_cause"] = cause
	p_rec["death_year"] = year
	var home_d: Dictionary = db.get_record("places", player.home_id)   # Cave Abode rule 10: the dead owner's abode is a Ruin
	if str(home_d.get("qi", {}).get("abode", {}).get("owner", "")) == player.id:
		CaveAbode.ruin(home_d)
	if ticker != null:
		ticker.bereave_close_ties(p_rec, year, season)
	var death_eid: String = _log("player_death", {"a": player.id, "cause": cause})
	InteractionService.on_player_death(db, player.id, year, season)
	# Event Engine (#23) AC-EV-44 & Template Quests (#31) AC-QS-58 / AC-QS-145: root death cleanup.
	if quests != null:
		quests.on_player_death(player, year, season, {"season_idx": season_index()})
	if event_engine != null:
		event_engine.on_root_death(player.id, year, season)
	pending_event = {}
	pending_meta = {}
	pending_mercy = {}
	db.items_on_death(player.id, player.location_id, killer_id, estate_heir)
	if ticker != null:
		var succ_leader: String = ticker.settle_sect_leader(p_rec)
		if succ_leader != "":
			_log("tick_succession", {"a": succ_leader, "b": player.id})
	TieTick.enqueue(db, {
		"kind": "death",
		"dead": player.id,
		"killer": killer_id,
		"known": killer_id != "",
		"cause": cause_key if cause_key != "" else "death",
		"place": player.location_id,
		"event": death_eid,
	})
	TieTick.run(gd, db, season_index())

	var facts: String = "%s, %s, died at age %d in %s. Linh căn: %s. Cause: %s. Notable events: %s" % [
		player.name, gd.realm_label(player.realm_index, player.stage), int(player.age), clock_label(),
		player.linh_can.describe(gd), cause, "; ".join(db.events_of(player.id).slice(-8).map(func(e): return str(e.text)))]
	epitaph_text = narrator.epitaph(facts).text
	sync_player()

	# Always write Lives entry to profile Codex (Rule 9, AC-CK-02, 03, 12).
	if codex != null:
		codex.record_life(self, cause, playthrough_mode, playthrough_id)

	# Mode branching: One Life ends; Continue awards karma and opens succession.
	if playthrough_mode == KarmicRules.MODE_CONTINUE:
		_last_death_karma_earned = KarmicRules.karma_earned(
			gd, playthrough_mode, player.birth_mode, cheated,
			player.realm_index, is_heir_life, start_realm_this_life, k_new_this_life
		)
		karma += _last_death_karma_earned
		playthrough_status = KarmicRules.STATUS_SUCCESSION
	else:
		_last_death_karma_earned = 0
		playthrough_status = KarmicRules.STATUS_ENDED

	var summary := {
		"name": player.name,
		"realm": gd.realm_label(player.realm_index, player.stage),
		"age": player.age,
		"cause": cause,
		"mode": playthrough_mode,
		"status": playthrough_status,
		"karma": karma,
		"karma_earned": _last_death_karma_earned,
	}
	life_ended.emit(summary)
	_events.append({"kind": "life_ended", "summary": summary})


## Read-only. Returns the succession choices available after death in Continue mode
## (heirs with karma costs, lineage rebirth status, free origins, epitaph, karma).
func succession_options() -> Dictionary:
	var dead_id: String = _last_death_player_id if _last_death_player_id != "" else (player.id if player != null else "")
	var heirs: Array = KarmicRules.heir_candidates(gd, db, dead_id, _last_death_killer, karma, _last_death_disciples) if db != null else []
	var sect_rec: Dictionary = db.get_record("sects", _last_death_sect_id) if db != null and _last_death_sect_id != "" else {}
	var sect_alive: bool = not sect_rec.is_empty() and str(sect_rec.get("status", "active")) == "active"
	var l_cost: int = KarmicRules.lineage_cost(gd)
	var origins: Array = Array(gd.attributes().get("origins", [])).duplicate(true)
	return {
		"status": playthrough_status,
		"mode": playthrough_mode,
		"epitaph": epitaph_text,
		"karma": karma,
		"karma_earned": _last_death_karma_earned,
		"birth_mode": player.birth_mode if player != null else "thien_dinh",
		"heirs": heirs,
		"lineage": {
			"sect_id": _last_death_sect_id,
			"sect_name": str(sect_rec.get("name", "")),
			"sect_alive": sect_alive,
			"clan_region_id": _last_death_region_id,
			"clan_surname": _last_death_surname,
			"clan_available": _last_death_region_id != "",
			"cost": l_cost,
			"affordable": karma >= l_cost,
		},
		"origins": origins,
		"rebirth_years": KarmicRules.rebirth_years(gd),
		"rebirth_seasons": KarmicRules.rebirth_seasons(gd),
		"perk_extra_max": KarmicRules.perk_extra_max(gd),
	}


## Action. Continues a dead Continue-mode playthrough as eligible heir [param heir_id]
## (Rule 4-6, AC-CK-04, 05, 07, 20). [param opts]: perk_extra (int), perk / chosen_perk_id (String).
## Returns {ok, lines, karma_spent, karma_left, offered_perks}; a frontend calls it through run() (ADR-0006).
func succeed_heir(heir_id: String, opts: Dictionary = {}) -> Dictionary:
	if db == null or player == null:
		return {"ok": false, "lines": ["No playthrough in progress."]}
	if playthrough_mode != KarmicRules.MODE_CONTINUE or playthrough_status != KarmicRules.STATUS_SUCCESSION:
		return {"ok": false, "lines": ["Succession is only available after death in Continue mode."]}
	var dead_id: String = _last_death_player_id if _last_death_player_id != "" else player.id
	var cands: Array = KarmicRules.heir_candidates(gd, db, dead_id, _last_death_killer, karma, _last_death_disciples)
	var found: Dictionary = {}
	for cand in cands:
		if str(cand.get("id", "")) == heir_id:
			found = cand
			break
	if found.is_empty():
		return {"ok": false, "lines": ["'%s' is not an eligible living heir." % heir_id]}
	var heir_rec: Dictionary = db.get_record("people", heir_id)
	var birth_mode: String = KarmicRules.successor_birth_mode(player.birth_mode, true)
	var perk_extra: int = int(opts.get("perk_extra", 0))
	var unheld_count: int = KarmicRules.unheld_perks(gd, Array(heir_rec.get("perks", []))).size()
	var spend: Dictionary = KarmicRules.validate_spend(gd, karma, true, int(heir_rec.get("realm_index", 0)), false, perk_extra, unheld_count, birth_mode)
	if not bool(spend.ok):
		return {"ok": false, "reason": str(spend.reason), "lines": ["Cannot succeed as %s: %s." % [str(heir_rec.get("name", heir_id)), str(spend.reason)]]}
	karma = int(spend.karma_left)

	# Release player flag from dead predecessor record.
	var old_rec: Dictionary = db.get_record("people", dead_id)
	if not old_rec.is_empty():
		old_rec["is_player"] = false
		db.put("people", old_rec)

	var new_p := Character.from_dict(heir_rec.duplicate(true))
	new_p.is_player = true
	new_p.birth_mode = birth_mode
	if new_p.home_id == "":
		new_p.home_id = new_p.location_id
	var offered_perks: Array = KarmicRules.roll_successor_perks(gd, rng, new_p.perks, perk_extra, birth_mode)
	var chosen_perk: String = str(opts.get("perk", opts.get("chosen_perk_id", "")))
	if chosen_perk != "" and offered_perks.has(chosen_perk):
		ProgressionEdges.apply_birth(new_p, gd, chosen_perk)
	elif not offered_perks.is_empty():
		ProgressionEdges.apply_birth(new_p, gd, str(offered_perks[0]))

	player = new_p
	edge = KarmicRules.successor_gets_edge()
	if player.known_diagrams.is_empty():
		_teach_starter_diagram()
	if player.tree_nodes.is_empty():
		_choose_start("")
	is_heir_life = true
	start_realm_this_life = player.realm_index
	k_new_this_life = 0
	past_ties = []
	recognition_used = 0
	co_duyen_used = {}
	pending_event = {}
	pending_meta = {}
	pending_mercy = {}
	pending_tribulation_reward = {}
	last_tribulation = {}
	epitaph_text = ""
	life_over = false
	playthrough_status = KarmicRules.STATUS_ACTIVE
	season_time_used = 0.0
	knowledge = MapKnowledge.start(gd, db, player) if db.has_record("world", "w_meta") else null
	start_residence()
	_log("player_heir_succeeded", {"a": player.id, "b": dead_id})
	_sync_and_rate()
	_codex_note_player_variants()
	_start_ratings()
	return {
		"ok": true,
		"lines": ["You continue as %s (%s), carrying on the legacy." % [player.name, gd.realm_label(player.realm_index, player.stage)]],
		"karma_spent": int(spend.total_cost),
		"karma_left": karma,
		"offered_perks": offered_perks,
	}


## Action. Advances the same world by 64 seasons (16 years) and enters as a newly born age-16 cultivator
## (Rules 4-6, AC-CK-06, 07, 11, 22). [param opts]: name, gender, origin, mode ("roll"|"custom"),
## birth_mode, lineage_kind (""|"sect"|"clan"), perk_extra (int), perk (String), thien_phu, purities, variants, start,
## optional on_mid_gap (Callable for tests).
## Returns {ok, lines, seasons_passed, news, lineage_refunded, refund_amount, karma_left, offered_perks}.
func succeed_rebirth(opts: Dictionary = {}) -> Dictionary:
	if db == null or player == null:
		return {"ok": false, "lines": ["No playthrough in progress."]}
	if playthrough_mode != KarmicRules.MODE_CONTINUE or playthrough_status != KarmicRules.STATUS_SUCCESSION:
		return {"ok": false, "lines": ["Rebirth is only available after death in Continue mode."]}
	var lineage_kind: String = str(opts.get("lineage_kind", opts.get("lineage", "")))
	var lineage: bool = lineage_kind == "sect" or lineage_kind == "clan"
	var origin: String = str(opts.get("origin", "tan_tu"))
	var req_mode: String = str(opts.get("mode", "roll"))
	var chosen_bm: String = "tu_dinh" if req_mode == "custom" else str(opts.get("birth_mode", "thien_dinh"))
	var birth_mode: String = KarmicRules.successor_birth_mode(player.birth_mode, false, chosen_bm)
	var perk_extra: int = int(opts.get("perk_extra", 0))
	var unheld_count: int = KarmicRules.unheld_perks(gd, []).size()
	var spend: Dictionary = KarmicRules.validate_spend(gd, karma, false, 0, lineage, perk_extra, unheld_count, birth_mode)
	if not bool(spend.ok):
		return {"ok": false, "reason": str(spend.reason), "lines": ["Cannot afford rebirth options: %s." % str(spend.reason)]}
	karma = int(spend.karma_left)

	# Release player flag from dead predecessor record before ticking world.
	var dead_id: String = _last_death_player_id if _last_death_player_id != "" else player.id
	var old_rec: Dictionary = db.get_record("people", dead_id)
	if not old_rec.is_empty():
		old_rec["is_player"] = false
		db.put("people", old_rec)

	# Advance the same world by 64 seasons (16 years, Formula C, AC-CK-06).
	var seasons_n: int = KarmicRules.rebirth_seasons(gd, origin)
	var mid_cb: Variant = opts.get("on_mid_gap", Callable())
	var gap_news: Array = _advance_world_only(seasons_n, mid_cb if mid_cb is Callable else Callable())

	# Check lineage survival after the 64-season gap (Edge Cases, AC-CK-11).
	var lineage_alive: bool = true
	if lineage_kind == "sect":
		var srec: Dictionary = db.get_record("sects", _last_death_sect_id)
		lineage_alive = not srec.is_empty() and str(srec.get("status", "active")) == "active"
	elif lineage_kind == "clan":
		lineage_alive = _is_clan_lineage_alive()
	var lin_res: Dictionary = KarmicRules.resolve_lineage_survival(gd, karma, lineage_kind, lineage_alive, _last_death_region_id)
	karma = int(lin_res.karma)
	var refunded: bool = bool(lin_res.refunded)
	if refunded:
		origin = str(lin_res.fallback_origin)
		lineage_kind = ""

	# Roll or build the newly born age-16 successor.
	var new_name: String = str(opts.get("name", "Tái Sinh"))
	var new_gender: String = str(opts.get("gender", "male"))
	_start_home = str(opts.get("home", ""))
	if birth_mode == "tu_dinh" or req_mode == "custom":
		player = CharacterFactory.custom_player(gd, rng, new_name, new_gender, origin, opts.get("thien_phu", {}), opts.get("purities", {}), opts.get("variants", []))
	else:
		player = CharacterFactory.roll_player(gd, rng, new_name, new_gender, origin)
	edge = KarmicRules.successor_gets_edge()
	var offered_perks: Array = KarmicRules.roll_successor_perks(gd, rng, player.perks, perk_extra, birth_mode)
	var chosen_perk: String = str(opts.get("perk", opts.get("chosen_perk_id", "")))
	if chosen_perk != "" and offered_perks.has(chosen_perk):
		ProgressionEdges.apply_birth(player, gd, chosen_perk)
	elif not offered_perks.is_empty():
		ProgressionEdges.apply_birth(player, gd, str(offered_perks[0]))
	_choose_start(str(opts.get("start", "")))
	player.id = db.add("people", player.to_dict())

	if lineage_kind == "sect" and lineage_alive:
		_place_reborn_in_sect(_last_death_sect_id)
	elif lineage_kind == "clan" and lineage_alive:
		player.origin = "gia_toc"
		_place_reborn_in_region(_last_death_region_id, true)
	elif refunded and _last_death_region_id != "":
		_place_reborn_in_region(_last_death_region_id, false)
	else:
		_place_player()
	_teach_starter_diagram()
	knowledge = MapKnowledge.start(gd, db, player) if db.has_record("world", "w_meta") else null
	# Rule 5 (AC-CK-07): a reborn receives the two starting Phá Cảnh Phù.
	for si in KarmicRules.successor_starting_talismans(gd, false):
		if si.has("talisman"):
			var tal: Dictionary = items.talisman(str(si.talisman), int(si.qty))
			tal["owner_id"] = player.id
			db.add("items", tal)

	# Keep past_ties from the dead life for past-life recognition events (up to recognition_max = 2, AC-CK-22).
	# Crucially, NO tie records exist between the reborn player and past_ties NPCs unless formed by an event.
	recognition_used = 0
	is_heir_life = false
	start_realm_this_life = 0
	k_new_this_life = 0
	co_duyen_used = {}
	pending_event = {}
	pending_meta = {}
	pending_mercy = {}
	pending_tribulation_reward = {}
	last_tribulation = {}
	epitaph_text = ""
	life_over = false
	playthrough_status = KarmicRules.STATUS_ACTIVE
	season_time_used = 0.0
	_log("player_reborn", {"a": player.id, "place": player.location_id})
	_sync_and_rate()
	_codex_note_player_variants()
	_start_ratings()

	var lines: Array = ["%d seasons pass (%s). %s enters the world anew at age %d." % [seasons_n, clock_label(), player.name, int(player.age)]]
	if refunded:
		lines.append("Your old lineage fell during the passing years; %d karma was refunded and you begin as a loose cultivator in that region." % int(lin_res.refund_amount))
	return {
		"ok": true,
		"lines": lines,
		"seasons_passed": seasons_n,
		"news": gap_news,
		"lineage_refunded": refunded,
		"refund_amount": int(lin_res.refund_amount),
		"karma_left": karma,
		"offered_perks": offered_perks,
	}


## Action. Ends a Continue-mode playthrough from the succession screen (Rule 3).
## Returns {ok, lines, status}; a frontend calls it through run() (ADR-0006).
func end_playthrough() -> Dictionary:
	if playthrough_status != KarmicRules.STATUS_SUCCESSION:
		return {"ok": false, "lines": ["No succession is waiting to end."]}
	playthrough_status = KarmicRules.STATUS_ENDED
	return {"ok": true, "lines": ["This playthrough has ended."], "status": playthrough_status}


## Action. Records an uncovered hidden chronicle/history entry in the Codex (World Generation rule 3a back-link).
func uncover_history(event_id: String) -> Dictionary:
	if event_id == "":
		return {"ok": false, "lines": ["No history entry specified."]}
	_codex_note(Codex.BOOK_HISTORY, event_id, CodexStore.LEVEL_KNOWN)
	return {"ok": true, "lines": ["Recorded chronicle entry %s in the Codex." % event_id]}


## Job. Runs [param action] (a bound action method of this session, e.g. [code]session.cultivate.bind(1)[/code]) and
## returns its result with [code]events[/code]: what happened during it that a frontend reacts to
## ([code]{kind: "breakthrough", realm_index}[/code], [code]{kind: "life_ended", summary}[/code]). A shipped frontend
## calls actions through this, off the main thread, one at a time (ADR-0006 decisions 6 and 7).
func run(action: Callable) -> Dictionary:
	_events = []
	var r: Variant = action.call()
	var out: Dictionary = r if r is Dictionary else {"ok": false, "lines": ["The action gave no result."]}
	out["events"] = _events.duplicate(true)
	_events = []
	return out


## Read-only. The sect status lines (the read half of [method sect_status], ADR-0006 decision 2).
func sect_lines() -> Array:
	if player == null:
		return []
	return Array(sect_status().get("lines", []))


## Lines shown when the life ends.
## Read-only. Never changes the world (ADR-0006 decision 1).
func death_lines() -> Array:
	return ["", "======== %s ========" % "ĐẠO TIÊU THÂN VẪN", epitaph_text, "", "Your life is over. 'chronicle' shows your story; 'new' begins another life."]


# --- Sects: the member's side ----------------------------------------------------

## The player's sect, rank, standing and contribution, the next promotion's needs, and any other sect's standing
## with the player (Sects rules 19-22). Returns {ok, lines}.
## Action. Returns {ok, lines, ...}; a frontend calls it through run() (ADR-0006).
func sect_status() -> Dictionary:
	var g: Dictionary = _guard(false)
	if not g.ok:
		return g
	var lines: Array = []
	if player.sect_id == "":
		lines.append("You are a loose cultivator (tán tu).")
		var here: Dictionary = db.get_record("sects", str(db.get_record("places", player.location_id).get("sect_id", "")))
		if not here.is_empty():
			var cj: Dictionary = sect_members.can_join(player, here)
			lines.append("  %s [%s] has its seat here: %s" % [here.name, here.id, "you may join ('join')" if cj.ok else "cannot join: " + "; ".join(cj.reasons)])
	else:
		var s: Dictionary = db.get_record("sects", player.sect_id)
		lines.append("%s [%s], %s. Standing %.0f, contribution %d." % [s.get("name", player.sect_id), player.sect_id,
			sect_members.rank_name(player.sect_rank), sect_members.standing(player.sect_id, player.id), sect_members.contribution(player.sect_id, player.id)])
		var need: Dictionary = sect_members.promotion_needs(player)
		if (need.missing as Array).is_empty():
			lines.append("  You may be promoted to %s ('promote'): %d contribution." % [sect_members.rank_name(str(need.rank)), int(need.gate.contribution)])
		else:
			lines.append("  Next rank %s: %s." % [sect_members.rank_name(str(need.rank)) if need.rank != "" else "-", "; ".join(need.missing)])
	for rec in db.all(SectMembers.TABLE):
		if str(rec.person) == player.id and str(rec.sect) != player.sect_id and float(rec.standing) != 0.0:
			lines.append("  %s: standing %.0f%s" % [db.get_record("sects", str(rec.sect)).get("name", rec.sect), float(rec.standing),
				" (hostile)" if sect_members.hostile(str(rec.sect), player.id) else ""])
	return {"ok": true, "lines": lines}


## Joins the sect whose seat is here, or [param sect_id] (Sects rule 20). No time passes. Returns {ok, lines}.
## Action. Returns {ok, lines, ...}; a frontend calls it through run() (ADR-0006).
func join_sect(sect_id: String = "") -> Dictionary:
	var g: Dictionary = _guard(true)
	if not g.ok:
		return g
	var sid: String = sect_id if sect_id != "" else str(db.get_record("places", player.location_id).get("sect_id", ""))
	if sid == "":
		return {"ok": false, "lines": ["No sect has its seat here: a sect recruits at its seat ('map' marks them S)."]}
	var s: Dictionary = db.get_record("sects", sid)
	var cj: Dictionary = sect_members.can_join(player, s)
	if not cj.ok:
		return {"ok": false, "lines": ["You cannot join: %s." % "; ".join(cj.reasons)]}
	sect_members.join(player, s)
	_log("player_joined_sect", {"a": player.id, "s1": s.id})
	_sync_and_rate()
	var lines_j: Array = ["You join %s as an %s." % [s.name, sect_members.rank_name(player.sect_rank)]]
	lines_j.append_array(_raise_event_hook("on_join_sect", {"sect_id": str(s.id)}))
	return {"ok": true, "lines": lines_j}


## Promotion to the next rank when its gate is met (Sects F13). No time passes. Returns {ok, lines}.
## Action. Returns {ok, lines, ...}; a frontend calls it through run() (ADR-0006).
func promote() -> Dictionary:
	var g: Dictionary = _guard(true)
	if not g.ok:
		return g
	var r: Dictionary = sect_members.promote(player)
	if r.ok:
		_sync_and_rate()
		var ev_l: Array = _raise_event_hook("on_rank_change", {"sect_id": player.sect_id, "rank": player.sect_rank})
		if not ev_l.is_empty():
			r["lines"] = Array(r.get("lines", [])) + ev_l
	return r


## Leaves the player's sect on good terms, or deserts it ([param desert]; Sects rule 22). Returns {ok, lines}.
## Action. Returns {ok, lines, ...}; a frontend calls it through run() (ADR-0006).
func leave_sect(desert: bool) -> Dictionary:
	var g: Dictionary = _guard(true)
	if not g.ok:
		return g
	var old_sect: String = player.sect_id
	var r: Dictionary = sect_members.leave(player, desert)
	if r.ok:
		_sync_and_rate()
		var ev_l: Array = _raise_event_hook("on_leave_sect", {"sect_id": old_sect, "desert": desert})
		if not ev_l.is_empty():
			r["lines"] = Array(r.get("lines", [])) + ev_l
	return r


# --- Power Rankings ---------------------------------------------------------------

## Call before the program exits or the session is dropped: waits for a season batch still running on its
## background thread (a process quitting under a running batch hangs) and drops it unapplied.
## Job. One at a time, off the main thread (ADR-0006).
func shutdown() -> void:
	_finish_ratings(false)


## True when Power Rankings runs (combat_rankings.json "enabled").
## Read-only. Never changes the world (ADR-0006 decision 1).
func ratings_on() -> bool:
	return ratings != null and ratings.enabled()


## Plans this season's rating batch and, with [member ratings_background], starts it.
func _start_ratings() -> void:
	if not ratings_on() or life_over:
		return
	sync_player()
	var budget: int = _bulk_share if _bulk_left > 0 else -1   # a season that will end inside the command
	_rating_batch = ratings.plan_season(seed_value, season_index(), year, season, player, sheet(), budget)
	if ratings_background:
		_rating_batch.start()


## Starts a command that passes [param seasons] seasons back to back: the seasons that begin inside it (all but its
## first, whose batch was planned before) share one season_fight_budget. [method _bulk_end] when it returns.
func _bulk_begin(seasons: int) -> void:
	if seasons < 2 or not ratings_on():
		return
	_bulk_left = seasons
	_bulk_share = floori(float(ratings.knob("season_fight_budget")) / float(seasons - 1))


func _bulk_end() -> void:
	_bulk_left = -1
	_bulk_share = 0


## [game seed, season key] for Power Rankings' keyed event-fight seeds (EventResolver.rating_clock).
func _rating_clock() -> Array:
	return [seed_value, season_index()]


## The season-end step of rule 13 (one season late, 2026-11-22): the previous season's batch completes and applies, in
## the fixed order, and this season's batch becomes the previous one, to apply at the end of the next season.
func _roll_ratings() -> void:
	var prev: SeasonBatch = _rating_prev
	_rating_prev = _rating_batch
	_rating_batch = null
	if prev != null:
		_apply_batch(prev)


## Completes every pending batch and applies them, oldest first ([param apply] false stops and drops them instead:
## quitting, or a life or world being replaced). Tools and tests use it to flush the lag.
func _finish_ratings(apply: bool = true) -> void:
	var pending: Array = [_rating_prev, _rating_batch].filter(func(b): return b != null)
	_rating_prev = null
	_rating_batch = null
	for b in pending:
		if not apply:
			b.cancel()   # its results are dropped: a running batch stops at its next fight
			b.finish()
		else:
			_apply_batch(b)


## Completes [param b] (waits for its background run, or runs it now) and applies it.
func _apply_batch(b: SeasonBatch) -> void:
	_complete_batch(b)
	if ratings != null:
		ratings.apply_batch(b)
		last_rating_batch = {"season": b.season, "budget": b.budget, "panels": b.panels.filter(func(p): return not p.result.is_empty()).size(),
			"queued": b.waiting, "panel_fights": b.panel_fights, "pair_fights": b.pair_fights, "pairs": b.pairs.size()}


## Waits for [param b]'s background run, or runs it now when it was not started (a restored batch has already run).
func _complete_batch(b: SeasonBatch) -> void:
	b.finish()
	if not b.ran:
		b.run(true)


## The player's shown power (Power Rankings rule 10): the power number when ratings run (opening it while Stale runs
## the player's panel now, once per build: Edge Cases), else chiến lực. Returns {value, text, provisional}.
## Read-only. Never changes the world (ADR-0006 decision 1).
func player_power() -> Dictionary:
	if not ratings_on():
		var cl: float = CombatPower.compute(player, gd, db, sheet()).total
		return {"value": cl, "text": "Chiến lực %.0f" % cl, "provisional": false}
	return power_of_person(player.id)


## After an action that can change the player's build or realm (ADR-0006 decision 1; power-rankings.md Edge Cases):
## syncs the player's record, refreshes its rating and, when it is Stale, runs the player's panel (once per build, on
## the action's thread). The season pass does not call it: there the season batch plans the player's panel (rule 14).
func _sync_and_rate() -> void:
	sync_player()
	if player == null or life_over or not ratings_on():
		return
	var rec: Dictionary = ratings.refresh_person(db.get_record("people", player.id))
	if str(rec.state) == RatingService.STALE:
		ratings.run_panel(player, sheet(), seed_value, season_index())


## A person's shown power: {value, text, provisional} (the power number when ratings run, else chiến lực).
## Read-only. Never changes the world (ADR-0006 decision 1).
func power_of_person(id: String) -> Dictionary:
	var p: Dictionary = db.get_record("people", id)
	if not ratings_on():
		return {"value": float(p.get("power", 0.0)), "text": "chiến lực %.0f" % float(p.get("power", 0.0)), "provisional": false}
	if player != null and id == player.id:
		p = player.to_dict()   # the player as it is now, which its record may not show until the next action syncs it
	var rec: Dictionary = ratings.peek_person(p)
	var n: int = ratings.ladder.power_number(float(rec.base) + float(rec.offset))
	var prov: bool = str(rec.state) == RatingService.PROVISIONAL
	return {"value": float(n), "text": "power %s%s" % [_thousands(n), "?" if prov else ""], "provisional": prov}


static func _thousands(n: int) -> String:
	var s: String = str(absi(n))
	var out: String = ""
	while s.length() > 3:
		out = "," + s.right(3) + out
		s = s.left(s.length() - 3)
	return ("-" if n < 0 else "") + s + out


# --- Save / load ------------------------------------------------------------------

## Whole session as a JSON-safe Dictionary.
## Job. One at a time, off the main thread (ADR-0006).
func to_dict() -> Dictionary:
	sync_player()
	return {
		"version": SAVE_VERSION, "seed": seed_value, "rng_state": str(rng.state), "rng_seed": str(rng.seed),
		"year": year, "season": season, "player_id": player.id, "db": db.to_dict(),
		"pending_event": pending_event, "pending_meta": pending_meta, "pending_mercy": pending_mercy.duplicate(true), "life_over": life_over, "epitaph": epitaph_text, "cheated": cheated,
		"edge": edge, "co_duyen_used": co_duyen_used,
		"season_time_used": season_time_used,
		"knowledge": knowledge.to_dict() if knowledge != null else {},
		"rating_pending": _pending_rating_results(),
		"playthrough_mode": playthrough_mode,
		"playthrough_id": playthrough_id,
		"playthrough_status": playthrough_status,
		"karma": karma,
		"k_new_this_life": k_new_this_life,
		"start_realm_this_life": start_realm_this_life,
		"is_heir_life": is_heir_life,
		"death_reloaded": death_reloaded,
		"past_ties": past_ties.duplicate(true),
		"recognition_used": recognition_used,
		"tribulation_enabled": tribulation_enabled,
		"pending_tribulation_reward": pending_tribulation_reward.duplicate(true),
		"last_death": {
			"player_id": _last_death_player_id,
			"killer": _last_death_killer,
			"disciples": _last_death_disciples.duplicate(),
			"sect_id": _last_death_sect_id,
			"region_id": _last_death_region_id,
			"surname": _last_death_surname,
			"karma_earned": _last_death_karma_earned,
		},
	}


## Rule 13, one season late: the previous season's batch has not applied yet, so a save waits for it to finish and keeps
## its results, to apply at the end of this season after a load. The current season's batch is not saved: it is
## planned again from the saved state on load (as before the lag).
func _pending_rating_results() -> Dictionary:
	if _rating_prev == null:
		return {}
	_complete_batch(_rating_prev)
	return _rating_prev.results_to_dict()


## Restores a session saved by [method to_dict]. Returns {ok, lines}.
## Job. One at a time, off the main thread (ADR-0006).
func load_dict(d: Dictionary) -> Dictionary:
	if int(d.get("version", 0)) == 2:
		return {"ok": false, "lines": ["This save uses the old 300-level ladder and cannot be loaded."]}
	if not SAVE_VERSIONS_READ.has(int(d.get("version", 0))):
		return {"ok": false, "lines": ["Save version %s is not supported." % str(d.get("version"))]}
	_finish_ratings(false)
	_player_migrated = false
	seed_value = int(d.seed)
	rng.seed = str(d.rng_seed).to_int()
	rng.state = str(d.rng_state).to_int()
	year = int(d.year)
	season = int(d.season)
	var loaded_db: WorldDB = WorldDB.from_dict(d.db)
	var meta: Dictionary = loaded_db.get_record("world", "w_meta")
	var map_now: String = str(gd.file(ContinentData.DATA_FILE).get("map_version", ""))
	if not meta.is_empty() and str(meta.get("map_version", "")) != map_now:
		# World Generation Core Rule 13: the terrain is read from the data files, so a save made on another map is refused
		return {"ok": false, "lines": ["This save was made on map version %s; this game has map version %s. It cannot be loaded." % [str(meta.get("map_version", "?")), map_now]]}
	var prov_now: int = int(gd.file(Provinces.FILE).get("provinces_version", 0))
	if not meta.is_empty() and prov_now > 0 and int(meta.get("provinces_version", 0)) != prov_now:
		# ADR-0008 decision 10 (user D7, 2026-11-24): a save made before the provinces table is refused, not migrated
		return {"ok": false, "lines": ["This save was made before provinces were part of the world (provinces version %d; this game has %d). It cannot be loaded." % [int(meta.get("provinces_version", 0)), prov_now]]}
	var wdv_now: int = int(gd.file("world_history").get("world_data_version", 0))
	if not meta.is_empty() and wdv_now > 0 and int(meta.get("world_data_version", 0)) != wdv_now:
		# ADR-0009 decision 9 (2026-11-26): a save made on another world data version is refused, not migrated
		return {"ok": false, "lines": ["This save was made with world data version %d; this game has %d. It cannot be loaded." % [int(meta.get("world_data_version", 0)), wdv_now]]}
	db = loaded_db
	Ties.migrate(gd, db, year * int(gd.cultivation_rules().seasons_per_year) + season)   # NPC Relationships: masters kept only in master_id
	for rec in db.all("people"):
		if rec.has("linh_can"):
			rec["linh_can"] = LinhCan.migrate_record(rec.linh_can, gd)
		var old_ladder: bool = not rec.has("level")
		Ladder.migrate_record(rec, gd)
		CongPhap.migrate_record(rec, db, gd)
		if old_ladder:
			# The old map's ids mean nothing on the new map: the points come back unspent.
			rec["tree_nodes"] = []
			rec["tree_points"] = Ladder.points_total(gd, int(rec.level))
			rec["tree_baseline"] = ""
		migrate_tree_record(rec)
		prune_removed_tree_nodes(rec)
	_wire()
	_reallocate_migrated()
	player = Character.from_dict(db.get_record("people", str(d.player_id)))
	if player.known_diagrams.is_empty():   # an older save: the character learns the starter diagram (2026-11-24)
		_teach_starter_diagram()
	var home_l: Dictionary = db.get_record("places", player.home_id)   # Cave Abode: an older save's home gets its record
	if not home_l.get("qi", {}).is_empty():
		if str(home_l.get("owner_id", "")) == player.id and not home_l.qi.has("abode"):
			home_l.qi["abode"] = {"owner": player.id, "grade": 1, "unpaid": 0, "pending": 0, "state": "open", "order": [], "dormant": []}
			home_l.qi.abode["grade"] = CaveAbode.grade_to_hold(gd, home_l.qi, player)   # grandfathered (user, 2026-11-21)
		start_residence()
		CaveAbode.reconcile(gd, home_l.qi, player)
	var migrated: bool = _player_migrated
	pending_event = d.get("pending_event", {})
	pending_meta = d.get("pending_meta", {})
	pending_mercy = Dictionary(d.get("pending_mercy", {})).duplicate(true)
	life_over = bool(d.get("life_over", false))
	cheated = bool(d.get("cheated", false))
	edge = bool(d.get("edge", true))
	season_time_used = clampf(float(d.get("season_time_used", player.season_time_used)), 0.0, 1.0)
	player.season_time_used = season_time_used
	co_duyen_used = {}
	var cdu: Dictionary = d.get("co_duyen_used", {})
	for k in cdu.keys():
		co_duyen_used[int(k)] = int(cdu[k])
	epitaph_text = str(d.get("epitaph", ""))
	playthrough_mode = KarmicRules.normalize_mode(str(d.get("playthrough_mode", KarmicRules.MODE_ONE_LIFE)))
	playthrough_id = str(d.get("playthrough_id", ""))
	var default_status: String = KarmicRules.STATUS_ENDED if life_over else KarmicRules.STATUS_ACTIVE
	playthrough_status = str(d.get("playthrough_status", default_status))
	karma = int(d.get("karma", 0))
	k_new_this_life = int(d.get("k_new_this_life", 0))
	start_realm_this_life = int(d.get("start_realm_this_life", 0))
	is_heir_life = bool(d.get("is_heir_life", false))
	death_reloaded = bool(d.get("death_reloaded", false))
	past_ties = Array(d.get("past_ties", [])).duplicate(true)
	recognition_used = int(d.get("recognition_used", 0))
	tribulation_enabled = bool(d.get("tribulation_enabled", TribulationRules.is_enabled(gd)))
	pending_tribulation_reward = Dictionary(d.get("pending_tribulation_reward", {})).duplicate(true)
	last_tribulation = {}
	var ld: Dictionary = Dictionary(d.get("last_death", {}))
	_last_death_player_id = str(ld.get("player_id", ""))
	_last_death_killer = str(ld.get("killer", ""))
	_last_death_disciples = Array(ld.get("disciples", [])).duplicate()
	_last_death_sect_id = str(ld.get("sect_id", ""))
	_last_death_region_id = str(ld.get("region_id", ""))
	_last_death_surname = str(ld.get("surname", ""))
	_last_death_karma_earned = int(ld.get("karma_earned", 0))
	# Rule 11 (AC-CK-21): loading a One Life pre-death save after a prior death of this playthrough_id
	# marks the save death_reloaded so one_life prestige achievements are blocked.
	if not life_over and Achievements.should_mark_death_reloaded(playthrough_mode, playthrough_id, codex_store):
		death_reloaded = true
	var kd: Dictionary = d.get("knowledge", {})
	knowledge = MapKnowledge.from_dict(kd) if not kd.is_empty() else null
	ratings.normalise_loaded()
	var pending: Dictionary = d.get("rating_pending", {})
	if not pending.is_empty() and not life_over and ratings_on():
		_rating_prev = SeasonBatch.from_results(ratings, pending)   # rule 13: applies at the end of this season
	if not life_over:
		_start_ratings()   # the season's batch is planned again from the saved state (rule 14's pending work)
	var out: Array = ["Loaded %s — %s, %s." % [player.name, gd.realm_label(player.realm_index, player.stage), clock_label()]]
	if migrated:
		out.append("The Đạo Đồ was redrawn: your open Dao marks came back as %d unspent points. %s" % [player.tree_points, _start_line()])
	return {"ok": true, "lines": out}


## Rule 19: a people record from the generated map (no `tree_baseline`) is migrated once: every open node but the old
## root comes back as an unspent point, its hidden-cluster state is dropped, and it takes the start of its strongest
## element (the player may move it with [method tree_choose_start] before opening a Dao mark). A record on the
## current baseline is left alone. Returns true if it migrated.
## Internal: a frontend never calls it (ADR-0006 decision 2).
func migrate_tree_record(rec: Dictionary) -> bool:
	if str(rec.get("tree_baseline", "")) == DaoDoTree.BASELINE:
		return false
	if rec.get("is_beast", false):
		rec["tree_baseline"] = DaoDoTree.BASELINE
		return false
	var opened: int = maxi(0, Array(rec.get("tree_nodes", [])).size() - 1)
	rec["tree_points"] = int(rec.get("tree_points", 0)) + opened
	for k in ["unsealed", "discovered", "fills", "tree_visibility", "open_unseals"]:
		rec.erase(k)
	# capabilities came from opened Dao marks of the old map: they go with them (the new map's notables grant them again)
	rec["capabilities"] = []
	var lc := LinhCan.from_dict(rec.get("linh_can", {}))
	var sid: int = tree.npc_start(lc, gd)
	rec["tree_nodes"] = [sid] if sid >= 0 else []
	rec["tree_baseline"] = DaoDoTree.BASELINE
	if bool(rec.get("is_player", false)):
		_player_migrated = true
	elif opened > 0 or int(rec.get("tree_points", 0)) > 0:
		rec["_tree_realloc"] = true
	return true


## A layout edit on the v5 map (design/dao-do/layout/v5-layout-2026-11-20.json) may remove Dao marks; ids are never
## reused (rule 19). A saved record that has one open drops it and gets its point back, unspent; the marks around a
## removed one were re-linked, so the rest of the build stays connected. Returns how many it dropped.
## Internal: a frontend never calls it (ADR-0006 decision 2).
func prune_removed_tree_nodes(rec: Dictionary) -> int:
	var kept: Array = []
	var dropped := 0
	for n in Array(rec.get("tree_nodes", [])):
		if tree.nodes.has(int(n)):
			kept.append(int(n))
		else:
			dropped += 1
	if dropped > 0:
		rec["tree_nodes"] = kept
		rec["tree_points"] = int(rec.get("tree_points", 0)) + dropped
	return dropped


## After a migration (rule 19), every migrated NPC spends its refunded points on the new map by rule 5, from a stream
## keyed on the game seed and its id (ADR-0002), so a reload gives the same trees. The player chooses for itself.
func _reallocate_migrated() -> void:
	for rec in db.all("people"):
		if not rec.get("_tree_realloc", false):
			continue
		rec.erase("_tree_realloc")
		var c := Character.from_dict(rec)
		var r := RandomNumberGenerator.new()
		r.seed = RngUtils.stable_hash("tree_migrate:%d:%s" % [seed_value, str(rec.get("id", ""))])
		var focus: Array = gd.archetype(c.archetype).get("tree_focus", []).duplicate()
		if focus.is_empty():
			focus = [c.linh_can.strongest_element()]
		builds.allocate(c, r, focus)
		for k in ["tree_nodes", "tree_points", "capabilities", "linh_can"]:
			rec[k] = c.to_dict()[k]
		db.put("people", rec)


# --- Helpers ------------------------------------------------------------------------

## Callback invoked by [EventResolver] when a post-duel kill choice executes; routes through [WorldTicker]
## without holding a cyclic lambda reference.
func _kill_npc_from_event(npc_id: String, cause: String) -> void:
	var rec: Dictionary = db.get_record("people", npc_id)
	if rec.is_empty() or not bool(rec.get("alive", false)):
		return
	ticker.npc_death(rec, year, season, cause, "duel", player.id, "tick_duel_kill", {"a": player.id, "b": npc_id, "place": player.location_id})
	if quests != null and player != null:
		quests.on_person_death(npc_id, player.id, year, season, {"player": player, "season_idx": season_index()})


func _herb_id(what: String) -> String:
	if not gd.herb(what).is_empty():
		return what
	var needle: String = WorldDB.fold(what)
	for h in gd.herbs():
		if WorldDB.fold(h.name).contains(needle) or WorldDB.fold(h.id).contains(needle):
			return h.id
	return what


## One World Database record per root change, with old and new values (linh-can.md AC-LC-45).
func _log_root_changes(type: String, changes: Array) -> void:
	for ch in changes:
		var text: String = str(gd.world_gen().history.texts.get(type, type)).replace("{a}", player.name)
		db.log_event(year, season, type, text, [player.id], [], [], ch)


func _log(type: String, refs: Dictionary) -> String:
	var text: String = str(gd.world_gen().history.texts.get(type, type))
	var people: Array = []
	var places: Array = []
	var its: Array = []
	for key in refs.keys():
		var v: String = str(refs[key])
		var rec: Dictionary = db.lookup(v)
		text = text.replace("{%s}" % key, str(rec.get("name", v)) if not rec.is_empty() else v)
		match db.table_of(v):
			"people", "sects":
				people.append(v)
			"places":
				places.append(v)
			"items":
				its.append(v)
	return db.log_event(year, season, type, text, people, places, its, {"refs": refs})


# --- Tribulation & Codex Helpers --------------------------------------------------

func _codex_note(book: String, entry_id: String, level: String) -> void:
	if codex == null or player == null or entry_id == "":
		return
	if codex.record(book, entry_id, level, player, cheated, year):
		k_new_this_life += 1


func _codex_note_player_variants() -> void:
	if player == null:
		return
	for vid in player.linh_can.variants.keys():
		_codex_note(Codex.BOOK_VARIANTS, str(vid), CodexStore.LEVEL_KNOWN)


func _codex_note_item(item: Dictionary) -> void:
	if item.is_empty():
		return
	var named_id: String = str(item.get("named", ""))
	if named_id != "":
		_codex_note(Codex.BOOK_ITEMS, named_id, CodexStore.LEVEL_KNOWN)
	elif str(item.get("kind", "")) == "treasure":
		_codex_note(Codex.BOOK_ITEMS, str(item.get("template", "")), CodexStore.LEVEL_KNOWN)
	elif str(item.get("kind", "")) == "cong_phap":
		_codex_note(Codex.BOOK_TECHNIQUES, str(item.get("tech_id", "")), CodexStore.LEVEL_SEEN)


func _codex_note_knowledge_secrets() -> void:
	if knowledge == null:
		return
	for clue in knowledge.clues:
		var slot_s: String = str(clue.get("slot", ""))
		if slot_s != "":
			_codex_note(Codex.BOOK_SECRETS, slot_s, CodexStore.LEVEL_SEEN)
	for slot_f in knowledge.found.keys():
		var sf: String = str(slot_f)
		if sf != "":
			_codex_note(Codex.BOOK_SECRETS, sf, CodexStore.LEVEL_KNOWN)


func _is_past_life_event(ev: Dictionary) -> bool:
	var src: String = str(ev.get("source", ""))
	if not src.begins_with("template:"):
		return false
	var tid: String = src.trim_prefix("template:")
	for t in gd.event_templates().get("templates", []):
		if t is Dictionary and str((t as Dictionary).get("id", "")) == tid:
			return bool((t as Dictionary).get("requires_past_ties", false))
	return false


func _tribulation_place_tags() -> Array:
	var tags: Array = []
	if db == null or player == null:
		return tags
	var place: Dictionary = db.get_record("places", player.location_id)
	if place.is_empty():
		return tags
	for raw_t in Array(place.get("tags", [])):
		var ts: String = str(raw_t)
		if ts != "" and not tags.has(ts):
			tags.append(ts)
	var ptype: String = str(place.get("type", ""))
	var pkind: String = str(place.get("kind", ""))
	if (ptype == "linh_mach" or pkind == "spirit_vein" or bool(place.get("vein", false))) and not tags.has("vein"):
		tags.append("vein")
	if ptype != "" and not tags.has(ptype):
		tags.append(ptype)
	return tags


func _tribulation_talisman_stock() -> Dictionary:
	var stock: Dictionary = {}
	if db == null or player == null:
		return stock
	for it in db.items_of(player.id):
		if str(it.get("kind", "")) == "talisman":
			var tpl: String = str(it.get("template", ""))
			if tpl != "":
				stock[tpl] = int(stock.get(tpl, 0)) + maxi(1, int(it.get("qty", 1)))
	return stock


func _spend_tribulation_stock(spent: Dictionary) -> void:
	if db == null or player == null or spent.is_empty():
		return
	for raw_k in spent.keys():
		var tpl: String = str(raw_k)
		var rem: int = maxi(0, int(spent[raw_k]))
		if rem <= 0:
			continue
		for it in db.items_of(player.id):
			if rem <= 0:
				break
			if str(it.get("kind", "")) == "talisman" and str(it.get("template", "")) == tpl:
				var q: int = maxi(1, int(it.get("qty", 1)))
				var take: int = mini(q, rem)
				rem -= take
				if q - take <= 0:
					db.remove("items", str(it.id))
				else:
					it["qty"] = q - take


func _create_tribulation_reward_item(choice: Dictionary) -> Dictionary:
	var kind: String = str(choice.get("kind", ""))
	var tpl: String = str(choice.get("template", ""))
	var qty: int = maxi(1, int(choice.get("qty", 1)))
	match kind:
		"material":
			return items.material(tpl, qty)
		"treasure":
			var tr: Dictionary = items.treasure(tpl)
			if qty > 1:
				tr["qty"] = qty
			return tr
		"talisman":
			return items.talisman(tpl, qty)
		"pill":
			return items.pill(tpl, int(choice.get("quality", 1)), qty)
		"herb":
			return items.herb(tpl, float(choice.get("age", 10.0)))
		"artifact":
			if not gd.named_item(tpl).is_empty():
				var na: Dictionary = items.named_artifact(tpl, player.realm_index, db, year)
				if not na.is_empty():
					return na
			return items.artifact(rng, player.realm_index, int(choice.get("grade", 3)), "", tpl)
		"cong_phap":
			for cp in gd.file("items_cong_phap").get("templates", []):
				if str(cp.get("id", "")) == tpl:
					return items.manual_from_template(cp)
			return items.cong_phap(rng, 2)
	return {}


func _snapshot_pre_death_ties() -> void:
	past_ties = []
	_last_death_disciples = []
	if db == null or player == null:
		return
	var seen_pt := {}
	var seen_disc := {}
	for rec in db.ties_of(player.id):
		var other: String = str(rec.b) if str(rec.a) == player.id else str(rec.a)
		var orec: Dictionary = db.get_record("people", other)
		if orec.is_empty() or not bool(orec.get("alive", false)) or bool(orec.get("is_beast", false)):
			continue
		var kinds: Array = []
		var pin: Dictionary = rec.get("pin", {})
		for pk in pin.keys():
			if str(pk) == "su_do":
				if str(pin.su_do) == player.id:
					kinds.append("disciple")
					if not seen_disc.has(other):
						seen_disc[other] = true
						_last_death_disciples.append(other)
				else:
					kinds.append("master")
			else:
				kinds.append(str(pk))
		if not Dictionary(rec.get("feud", {})).is_empty():
			kinds.append("feud")
		var soft: Dictionary = rec.get("soft", {})
		if not soft.is_empty() and str(soft.get("kind", "")) != "":
			kinds.append(str(soft.kind))
		if not Dictionary(rec.get("debt", {})).is_empty():
			kinds.append("debt")
		if not seen_pt.has(other):
			seen_pt[other] = true
			past_ties.append({"id": other, "name": str(orec.get("name", other)), "kinds": kinds})
	for p in db.living():
		if str(p.get("master_id", "")) == player.id and not bool(p.get("is_beast", false)):
			var did: String = str(p.id)
			if not seen_disc.has(did):
				seen_disc[did] = true
				_last_death_disciples.append(did)
			if not seen_pt.has(did):
				seen_pt[did] = true
				past_ties.append({"id": did, "name": str(p.get("name", did)), "kinds": ["disciple"]})
	for cid in db.children_of(player.id):
		var cs: String = str(cid)
		var crec: Dictionary = db.get_record("people", cs)
		if not crec.is_empty() and bool(crec.get("alive", false)) and not seen_pt.has(cs):
			seen_pt[cs] = true
			past_ties.append({"id": cs, "name": str(crec.get("name", cs)), "kinds": ["child"]})


func _resolve_player_estate_heir(p_rec: Dictionary, killer_id: String) -> String:
	if killer_id != "":
		return killer_id
	var h: String = Inheritance.heir_of(db, gd, p_rec)
	if h != "":
		return h
	var living_kids: Array = []
	for cid in db.children_of(player.id):
		var crec: Dictionary = db.get_record("people", str(cid))
		if not crec.is_empty() and bool(crec.get("alive", false)):
			living_kids.append(crec)
	if not living_kids.is_empty():
		living_kids.sort_custom(func(a, b): return int(a.get("realm_index", 0)) > int(b.get("realm_index", 0)))
		return str(living_kids[0].id)
	return ""


func _settle_player_purse(estate_heir: String) -> void:
	var amt: int = maxi(0, player.linh_thach)
	if amt <= 0:
		return
	var has_econ: bool = db.count(WorldEconomy.TABLE) > 0
	if estate_heir != "" and db.has_record("people", estate_heir) and bool(db.get_record("people", estate_heir).get("alive", false)):
		if has_econ:
			MoneyLedger.player_pay(db, player, "npc:%s" % estate_heir, amt, "inheritance")
		else:
			var hr: Dictionary = db.get_record("people", estate_heir)
			hr["linh_thach"] = int(hr.get("linh_thach", 0)) + amt
			player.linh_thach = 0
		return
	if player.sect_id != "" and db.has_record("sects", player.sect_id):
		if has_econ:
			MoneyLedger.player_pay(db, player, "sect:%s" % player.sect_id, amt, "inheritance")
		else:
			var sr: Dictionary = db.get_record("sects", player.sect_id)
			sr["treasury"] = int(sr.get("treasury", 0)) + amt
			player.linh_thach = 0
		return
	if has_econ:
		var lost_frac: float = float(gd.file(WorldEconomy.FILE).get("money", {}).get("lost_frac", 0.5))
		var burned: int = int(roundf(float(amt) * lost_frac))
		if burned > 0:
			MoneyLedger.player_pay(db, player, "", burned, "heirless")
		var left_amt: int = maxi(0, player.linh_thach)
		var ms: String = MoneyLedger.market_sect_of(db, player.location_id)
		if left_amt > 0 and ms != "":
			MoneyLedger.player_pay(db, player, "stash:%s" % ms, left_amt, "heirless")
		elif left_amt > 0:
			MoneyLedger.player_pay(db, player, "", left_amt, "heirless")
	else:
		player.linh_thach = 0


func _advance_world_only(seasons_n: int, on_mid_gap: Callable = Callable()) -> Array:
	var spy: int = maxi(1, int(gd.cultivation_rules().seasons_per_year))
	var news: Array = []
	var mid: int = int(seasons_n / 2)
	for i in maxi(0, seasons_n):
		season += 1
		if season >= spy:
			season = 0
			year += 1
		news.append_array(ticker.tick(rng, year, season))
		if i == mid and on_mid_gap.is_valid():
			on_mid_gap.call()
	return news


func _is_clan_lineage_alive() -> bool:
	if _last_death_region_id == "" or db == null:
		return false
	if not db.has_record("regions", _last_death_region_id):
		return false
	for p in db.living():
		if bool(p.get("is_beast", false)) or bool(p.get("is_player", false)):
			continue
		var pl: Dictionary = db.get_record("places", str(p.get("location_id", "")))
		if str(pl.get("region_id", "")) == _last_death_region_id:
			if _last_death_surname == "" or Families.surname_of(gd, str(p.get("name", ""))) == _last_death_surname:
				return true
	return false


func _place_reborn_in_sect(sect_id: String) -> void:
	var srec: Dictionary = db.get_record("sects", sect_id)
	if srec.is_empty():
		_place_player()
		return
	var hq: Dictionary = db.get_record("places", str(srec.get("hq_place_id", "")))
	if hq.is_empty():
		_place_player()
		return
	player.origin = "tong_mon"
	player.sect_id = str(srec.id)
	player.sect_rank = str(gd.session().sect.join_rank)
	srec.members.append(player.id)
	sect_members.record(str(srec.id), player.id)
	player.home_id = str(hq.id)
	player.location_id = str(hq.id)
	start_residence()
	_grant_starting_kit(hq)
	_log("player_born", {"a": player.id, "place": str(hq.id)})
	_log("player_joined_sect", {"a": player.id, "s1": player.sect_id})


func _place_reborn_in_region(region_id: String, with_clan: bool) -> void:
	var types: Array = gd.session().home_place_types
	var reg_places: Array = db.find("places", func(p): return str(p.get("region_id", "")) == region_id and types.has(p.get("type", "")))
	if reg_places.is_empty():
		reg_places = db.find("places", func(p): return str(p.get("region_id", "")) == region_id)
	var home: Dictionary = RngUtils.pick(rng, reg_places) if not reg_places.is_empty() else RngUtils.pick(rng, db.all("places"))
	player.home_id = str(home.id)
	player.location_id = str(home.id)
	start_residence()
	if with_clan:
		_clan_family(home)
	_grant_starting_kit(home)
	_log("player_born", {"a": player.id, "place": str(home.id)})


func _grant_starting_kit(home: Dictionary) -> void:
	var o: Dictionary = gd.origin(player.origin)
	var cp: Dictionary = items.cong_phap(rng, gd.cong_phap_tier_rank(str(o.get("cong_phap_tier", "hoang"))), [_starting_element()])
	cp["owner_id"] = player.id
	db.add("items", cp)
	CongPhap.learn(player, cp)
	player.main_tech = str(cp.tech_id)
	var province: Array = db.find("places", func(p): return bool(p.get("market", false)) and p.get("region_id", "") == home.get("region_id", ""))
	if province.is_empty():
		province = db.find("places", func(p): return bool(p.get("market", false)))
	if not province.is_empty():
		market.stock_guaranteed(province[0].id)
	var plot: int = 0
	for h in o.get("starting_herbs", []):
		for _k in int(h.qty):
			var herb: Dictionary = items.herb(str(h.herb), float(h.age))
			herb["owner_id"] = player.id
			herb["plot"] = plot
			plot += 1
			db.add("items", herb)
