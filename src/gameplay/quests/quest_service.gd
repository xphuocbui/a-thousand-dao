class_name QuestService
extends RefCounted
## Full runtime lifecycle, stage handlers, payment, world outcomes, and Formula E reactions
## for Template Quests (#31).
##
## Persists quests and metadata in [WorldDB] (using native [code]"quests"[/code] / [code]"quest_meta"[/code]
## tables when registered in [member WorldDB.TABLES], else transparently falling back to [code]"world"[/code]
## buckets [code]"w_quests"[/code] and [code]"w_quest_meta"[/code]).
## Holds zero cyclic [RefCounted] back-references (never stores [GameSession]).
## Every linh thạch flow passes through [MoneyLedger] so [method MoneyLedger.season_check] stays at gap 0.
## Design: [code]design/gdd/quests.md[/code] (Rules 1-19, Formulas A-E).
##
## Usage:
## [codeblock]
## var svc := QuestService.new(gd, db, builds, items, event_engine, board)
## var offered := svc.offer_from_person(player, sheet, npc_id, place_id, seed_v, season_idx)
## var accepted := svc.accept(player, offered.quest.id, season_idx)
## svc.tick_season(player, sheet, year, season)
## [/codeblock]

## WorldDB table name for quest records (falls back to "world" bucket "w_quests" if unregistered).
const TABLE_QUESTS := "quests"
## WorldDB table name for quest metadata (falls back to "world" bucket "w_quest_meta" if unregistered).
const TABLE_META := "quest_meta"
const _META_ID := "meta"
const _EPS := 1e-9

const _QuestRules := preload("res://src/gameplay/quests/quest_rules.gd")
const _QuestValidator := preload("res://src/gameplay/quests/quest_validator.gd")
const _QuestGenerator := preload("res://src/gameplay/quests/quest_generator.gd")
const _QuestBoard := preload("res://src/gameplay/quests/quest_board.gd")
const _EventStore := preload("res://src/gameplay/events/event_store.gd")
const _EventBudget := preload("res://src/gameplay/events/event_budget.gd")

var _gd: GameData
var _db: WorldDB
var _builds: BuildGenerator
var _items: ItemFactory
var _event_engine: RefCounted
var _board: RefCounted
var _generator: RefCounted


## Constructs a [QuestService] bound to [param gd] and [param db]. Optional dependencies
## ([param builds], [param items], [param event_engine], [param board]) default cleanly for standalone tests.
func _init(
	gd: GameData,
	db: WorldDB,
	builds: BuildGenerator = null,
	items: ItemFactory = null,
	event_engine: RefCounted = null,
	board: RefCounted = null
) -> void:
	_gd = gd
	_db = db
	_builds = builds
	_items = items if items != null else (ItemFactory.new(gd) if gd != null else null)
	_event_engine = event_engine
	_board = board if board != null else _QuestBoard.new(gd, db, builds)
	_generator = _QuestGenerator.new(gd, db, builds)


# --- Persistence helpers (native WorldDB table or "world" bucket fallback) ---------------------------------------

static func _native(table: String) -> bool:
	return WorldDB.TABLES.has(table)


static func _bucket(db: WorldDB, table: String, create: bool) -> Dictionary:
	var bid: String = "w_" + table
	var rec: Dictionary = db.get_record("world", bid)
	if rec.is_empty():
		if not create:
			return {}
		rec = {"id": bid, "rows": {}, "next": 1}
		db.put("world", rec)
	return rec


static func _get_rec(db: WorldDB, table: String, rid: String) -> Dictionary:
	if db == null or rid == "":
		return {}
	if _native(table):
		return db.get_record(table, rid)
	var b: Dictionary = _bucket(db, table, false)
	if b.is_empty():
		return {}
	return Dictionary(b.rows).get(rid, {})


static func _put_rec(db: WorldDB, table: String, rec: Dictionary) -> void:
	if db == null or str(rec.get("id", "")) == "":
		return
	if _native(table):
		db.put(table, rec)
		return
	var b: Dictionary = _bucket(db, table, true)
	b.rows[str(rec.id)] = rec


static func _all_recs(db: WorldDB, table: String) -> Array:
	if db == null:
		return []
	if _native(table):
		return db.all(table)
	var b: Dictionary = _bucket(db, table, false)
	if b.is_empty():
		return []
	return Dictionary(b.rows).values()


func _meta() -> Dictionary:
	var rec: Dictionary = _get_rec(_db, TABLE_META, _META_ID)
	if rec.is_empty():
		rec = {
			"id": _META_ID,
			"spent_facts": {},
			"fact_cooldowns": {},
			"season_offers": {},
			"offer_seq": 0,
		}
		_put_rec(_db, TABLE_META, rec)
	return rec


func _save_meta(rec: Dictionary) -> void:
	_put_rec(_db, TABLE_META, rec)


## Returns the stored quest record for [param quest_id], or {} if absent.
func get_quest(quest_id: String) -> Dictionary:
	return _get_rec(_db, TABLE_QUESTS, quest_id)


## Stores or replaces a quest record in [WorldDB]. Assigns an id if missing and returns it.
func put_quest(quest: Dictionary) -> String:
	var qid: String = str(quest.get("id", ""))
	if qid == "":
		var m: Dictionary = _meta()
		var seq: int = int(m.get("offer_seq", 0)) + 1
		m["offer_seq"] = seq
		_save_meta(m)
		qid = "q_%d" % seq
		quest["id"] = qid
	_put_rec(_db, TABLE_QUESTS, quest)
	return qid


## Returns all quest records in [WorldDB], optionally filtered by [param player_id].
func all_quests(player_id: String = "") -> Array:
	var out: Array = []
	for raw in _all_recs(_db, TABLE_QUESTS):
		if not (raw is Dictionary):
			continue
		var q: Dictionary = raw as Dictionary
		if player_id != "" and str(q.get("player_id", "")) != player_id:
			continue
		out.append(q)
	out.sort_custom(func(a, b): return str(a.get("id", "")) < str(b.get("id", "")))
	return out


## Returns all currently held ([code]active[/code] or [code]orphaned[/code]) quests for [param player_id]
## (Rule 10, AC-QS-54: an orphaned quest keeps its active slot).
func active_quests(player_id: String = "") -> Array:
	return all_quests(player_id).filter(func(q): return str(q.get("state", "")) in ["active", "orphaned"])


## Returns all currently open [code]offered[/code] quests for [param player_id].
func offered_quests(player_id: String = "") -> Array:
	return all_quests(player_id).filter(func(q): return str(q.get("state", "")) == "offered")


## Returns all terminal quests for [param player_id].
func ended_quests(player_id: String = "") -> Array:
	return all_quests(player_id).filter(func(q):
		return str(q.get("state", "")) in ["completed", "failed", "lapsed", "dropped", "declined", "withdrawn"])


## Returns true if [param fact_id] is neither permanently spent nor on cooldown at [param season_idx]
## (Rule 7, AC-QS-47, AC-QS-98).
func is_fact_available(fact_id: String, season_idx: int) -> bool:
	if fact_id == "":
		return true
	var m: Dictionary = _meta()
	if Dictionary(m.get("spent_facts", {})).has(fact_id):
		return false
	var unlock: int = int(Dictionary(m.get("fact_cooldowns", {})).get(fact_id, -999999))
	return season_idx >= unlock


## Pure read helper for Dialogue #30 and Outliner: returns living NPC target ids from active/orphaned
## quests whose current stage is [code]visit[/code] (AC-NI-12, AC-QS-43).
static func active_visit_targets(db: WorldDB, player_id: String) -> Array[String]:
	var out: Array[String] = []
	if db == null:
		return out
	var seen: Dictionary = {}
	for raw in _all_recs(db, TABLE_QUESTS):
		if not (raw is Dictionary):
			continue
		var q: Dictionary = raw as Dictionary
		if player_id != "" and str(q.get("player_id", "")) != player_id:
			continue
		if not (str(q.get("state", "")) in ["active", "orphaned"]):
			continue
		var st: Dictionary = _current_stage_of(q)
		if str(st.get("kind", "")) != "visit":
			continue
		var tid: String = str(st.get("target_id", ""))
		if tid != "" and not seen.has(tid):
			seen[tid] = true
			out.append(tid)
	out.sort()
	return out


## Returns the active/orphaned quest visit entries [code][{quest_id, npc_id, place_id}][/code] for [param player_id].
static func active_visit_entries(db: WorldDB, player_id: String) -> Array:
	var out: Array = []
	if db == null:
		return out
	for raw in _all_recs(db, TABLE_QUESTS):
		if not (raw is Dictionary):
			continue
		var q: Dictionary = raw as Dictionary
		if player_id != "" and str(q.get("player_id", "")) != player_id:
			continue
		if not (str(q.get("state", "")) in ["active", "orphaned"]):
			continue
		var st: Dictionary = _current_stage_of(q)
		if str(st.get("kind", "")) != "visit":
			continue
		out.append({
			"quest_id": str(q.get("id", "")),
			"npc_id": str(st.get("target_id", "")),
			"place_id": str(st.get("place_id", "")),
		})
	return out


## Pure read summary of an offered quest for Offer UI / Rule 6 & AC-QS-128:
## exposes tier, offerer, source_fact, adversary, each resolved outcome with its ending, role, effect, and amount,
## stage 1 in full, later stages as kind+place only, and lasting-gain cap room status.
func offer_summary(player: Character, quest: Dictionary, rules_override: Dictionary = {}) -> Dictionary:
	if quest.is_empty():
		return {}
	var plan: Dictionary = Dictionary(quest.get("plan", quest))
	var stages: Array = Array(plan.get("stages", []))
	var budget: Dictionary = Dictionary(quest.get("budget", {}))
	var b_val: int = int(budget.get("B", 0))
	var cfg: Dictionary = _QuestRules.config(_gd, rules_override)
	var wealth_cap: int = int(floor(float(cfg.get("world_wealth_share", 0.5)) * float(b_val) + _EPS))
	var resolved_outcomes: Array = []
	for raw_oc in Array(quest.get("outcomes", plan.get("outcomes", []))):
		if not (raw_oc is Dictionary):
			continue
		var oc: Dictionary = raw_oc as Dictionary
		var eff: String = str(oc.get("effect", ""))
		var amt: Variant = null
		if eff == "wealth":
			amt = _resolve_outcome_wealth_amount(oc, b_val, wealth_cap)
		elif eff == "injury" or eff == "standing":
			amt = oc.get("amount", 0)
		resolved_outcomes.append({
			"on": str(oc.get("on", "")),
			"role": str(oc.get("role", "")),
			"effect": eff,
			"amount": amt,
		})
	var later_summary: Array = []
	for i in range(1, stages.size()):
		if stages[i] is Dictionary:
			var st: Dictionary = stages[i] as Dictionary
			later_summary.append({"kind": str(st.get("kind", "")), "place_id": str(st.get("place_id", ""))})
	var rare_raw: Variant = plan.get("rare_reward", quest.get("rare_reward", null))
	var has_lasting: bool = rare_raw is Dictionary and str((rare_raw as Dictionary).get("type", "")) in ["quest_boon", "tree_point"]
	var room: Dictionary = _QuestRules.lasting_gain_room(
		_gd,
		player.quest_gain_total_w if player != null else 0.0,
		player.quest_tree_points_used if player != null else 0,
		rules_override
	)
	return {
		"id": str(quest.get("id", "")),
		"name": str(quest.get("name", "")),
		"tier": str(quest.get("tier", "")),
		"offerer_id": str(quest.get("offerer_id", "")),
		"adversary_id": str(quest.get("adversary_id", "")),
		"source_fact_id": str(quest.get("source_fact_id", "")),
		"stage_count": stages.size(),
		"deadline": int(quest.get("deadline", 0)),
		"budget": budget.duplicate(true),
		"stage_1": (stages[0] as Dictionary).duplicate(true) if not stages.is_empty() and stages[0] is Dictionary else {},
		"later_stages": later_summary,
		"outcomes": resolved_outcomes,
		"has_lasting_gain": has_lasting,
		"can_gain_boon": float(room.allowed_w) > _EPS,
	}


# --- Offers: Person, Sect, Board, Ask for Work (Rules 2, 3, 7, 15, 16, 18) ---------------------------------------

## Generates and stores a person quest offer from [param npc_id] at [param place_id].
## Enforces [code]active_cap[/code] (AC-QS-44), [code]offers_per_season[/code] (AC-QS-02),
## source-fact spent/cooldown state (AC-QS-47, AC-QS-98), and hostility > [code]hostile_threshold[/code] (AC-QS-103, AC-QS-117).
func offer_from_person(
	player: Character,
	sheet: StatSheet,
	npc_id: String,
	place_id: String,
	seed_v: int,
	season_idx: int,
	opts: Dictionary = {}
) -> Dictionary:
	return _generate_and_store_offer(player, sheet, "person", npc_id, place_id, seed_v, season_idx, opts)


## Generates and stores a sect quest offer from [param sect_or_member_id] at [param place_id].
## Resolves the speaking member root (Rule 16, AC-QS-140) and enforces all offer caps and cooldowns.
func offer_from_sect(
	player: Character,
	sheet: StatSheet,
	sect_or_member_id: String,
	place_id: String,
	seed_v: int,
	season_idx: int,
	opts: Dictionary = {}
) -> Dictionary:
	return _generate_and_store_offer(player, sheet, "sect", sect_or_member_id, place_id, seed_v, season_idx, opts)


## Considers an offer from [param offerer_id] (auto-detecting person vs sect by [WorldDB] table) at [param place_id].
func consider_offer(
	player: Character,
	sheet: StatSheet,
	offerer_id: String,
	place_id: String,
	seed_v: int,
	season_idx: int,
	opts: Dictionary = {}
) -> Dictionary:
	var kind: String = "sect" if (_db != null and _db.table_of(offerer_id) == "sects") else "person"
	return _generate_and_store_offer(player, sheet, kind, offerer_id, place_id, seed_v, season_idx, opts)


## Dialogue #30 "Ask for work" handoff (Rule 2, AC-QS-154): tries to generate a person offer from [param npc_id].
## Returns [code]{ok, result: "offered"|"no_work", reason, quest}[/code].
func ask_for_work(
	player: Character,
	sheet: StatSheet,
	npc_id: String,
	seed_v: int,
	season_idx: int,
	opts: Dictionary = {}
) -> Dictionary:
	var place_id: String = str(opts.get("place_id", player.location_id if player != null else ""))
	var res: Dictionary = offer_from_person(player, sheet, npc_id, place_id, seed_v, season_idx, opts)
	if bool(res.ok):
		return {"ok": true, "result": "offered", "reason": "", "quest": res.quest}
	return {"ok": false, "result": "no_work", "reason": str(res.reason), "quest": {}}


## Reads or refreshes the standing quest board at [param place_id] (Rule 2, Rule 7, AC-QS-04, AC-QS-44, AC-QS-46).
## Never counts against [code]offers_per_season[/code] and reading never starts a cooldown.
func board_offers(
	place_id: String,
	player: Character = null,
	sheet: StatSheet = null,
	seed_v: int = 0,
	season_idx: int = 0,
	refresh: bool = false,
	opts: Dictionary = {}
) -> Array:
	if _board == null:
		return []
	if refresh and player != null:
		return _board.refresh_place(place_id, player, sheet, seed_v, season_idx, opts)
	return _board.list_board(place_id)


func _generate_and_store_offer(
	player: Character,
	sheet: StatSheet,
	offer_kind: String,
	offerer_id: String,
	place_id: String,
	seed_v: int,
	season_idx: int,
	opts: Dictionary
) -> Dictionary:
	if player == null or _gd == null or _db == null:
		return {"ok": false, "quest": {}, "reason": "missing_context"}
	var rules_override: Dictionary = Dictionary(opts.get("rules_override", {}))
	var cfg: Dictionary = _QuestRules.config(_gd, rules_override)

	# AC-QS-44: no person/sect offers generated while holding active_cap quests.
	var cap: int = int(cfg.get("active_cap", 3))
	if active_quests(player.id).size() >= cap:
		return {"ok": false, "quest": {}, "reason": "active_cap_reached"}

	# AC-QS-02: at most offers_per_season per character per season.
	var m: Dictionary = _meta()
	var skey: String = "%s|%d" % [player.id, season_idx]
	var offers_used: int = int(Dictionary(m.get("season_offers", {})).get(skey, 0))
	var max_per_season: int = int(cfg.get("offers_per_season", 1))
	if offers_used >= max_per_season:
		return {"ok": false, "quest": {}, "reason": "offers_per_season_limit"}

	var gen_opts: Dictionary = opts.duplicate(true)
	var spent: Dictionary = Dictionary(m.get("spent_facts", {})).duplicate()
	if gen_opts.has("spent_facts"):
		for k in (gen_opts["spent_facts"] as Dictionary).keys():
			spent[k] = true
	gen_opts["spent_facts"] = spent
	var cds: Dictionary = Dictionary(m.get("fact_cooldowns", {})).duplicate()
	if gen_opts.has("fact_cooldowns"):
		for k in (gen_opts["fact_cooldowns"] as Dictionary).keys():
			cds[k] = maxi(int(cds.get(k, -999999)), int(gen_opts["fact_cooldowns"][k]))
	gen_opts["fact_cooldowns"] = cds

	var offer_idx: int = int(opts.get("offer_idx", int(m.get("offer_seq", 0))))
	var res: Dictionary = _generator.generate_offer(
		player, sheet, offer_kind, offerer_id, place_id, seed_v, season_idx, offer_idx, gen_opts
	)
	if not bool(res.ok):
		return {"ok": false, "quest": {}, "reason": str(res.reason), "tries": int(res.get("tries", 0))}

	var quest: Dictionary = (res.quest as Dictionary).duplicate(true)
	quest["player_id"] = player.id
	quest["state"] = "offered"
	quest["offered_season"] = season_idx
	quest["stage"] = 1
	quest["stages_done"] = 0
	quest["seasons_spent"] = 0
	quest["paid_total"] = 0
	quest["paid_rewards"] = []
	quest["skipped_stages"] = []
	quest["defeat_holds"] = {}
	quest["defeat_opened"] = {}
	put_quest(quest)

	m = _meta()
	var so: Dictionary = Dictionary(m.get("season_offers", {}))
	so[skey] = offers_used + 1
	m["season_offers"] = so
	if not opts.has("offer_idx"):
		m["offer_seq"] = offer_idx + 1
	_save_meta(m)
	return {"ok": true, "quest": quest.duplicate(true), "reason": "", "tries": int(res.get("tries", 1))}


# --- Lifecycle: Accept, Decline, Abandon, Drop (Rules 7, 10, 19) -------------------------------------------------

## Accepts an open [code]offered[/code] quest (from [WorldDB] or the local [QuestBoard]), taking one
## active slot (Rule 7, AC-QS-01, AC-QS-44) and starting its Event Engine story (Rule 19, AC-QS-151..153).
func accept(
	player: Character,
	quest_id: String,
	season_idx: int,
	opts: Dictionary = {}
) -> Dictionary:
	if player == null or _gd == null or _db == null:
		return {"ok": false, "reason": "missing_context", "quest": {}}
	var rules_override: Dictionary = Dictionary(opts.get("rules_override", {}))
	var cfg: Dictionary = _QuestRules.config(_gd, rules_override)
	var cap: int = int(cfg.get("active_cap", 3))
	if active_quests(player.id).size() >= cap:
		return {"ok": false, "reason": "active_cap_reached", "quest": {}}

	var quest: Dictionary = get_quest(quest_id)
	if quest.is_empty() and _board != null:
		var place_id: String = str(opts.get("place_id", player.location_id))
		if place_id != "":
			quest = _board.take_from_board(place_id, quest_id)
	if quest.is_empty():
		return {"ok": false, "reason": "quest_not_found", "quest": {}}
	if str(quest.get("state", "")) != "offered":
		return {"ok": false, "reason": "quest_not_offered", "quest": {}}

	# Ensure frozen budget & deadline exist (supports hand-built test fixtures like FX-PLAN/FX-MAJ/FX-SKIP).
	_ensure_frozen_plan_fields(quest, player, rules_override)

	# If offerer/sect/place died before acceptance, withdraw instead of accepting.
	if _offer_became_invalid(quest):
		var wd: Dictionary = _end_quest(player, quest, "withdrawn", int(opts.get("year", 0)), season_idx, rules_override)
		return {"ok": false, "reason": "offer_withdrawn", "quest": wd.quest}

	quest["player_id"] = player.id
	quest["state"] = "active"
	quest["stage"] = 1
	quest["stages_done"] = 0
	quest["accepted_season"] = season_idx
	quest["deadline_season"] = season_idx + int(quest.get("deadline", 0))
	quest["seasons_spent"] = 0
	quest["paid_total"] = 0
	quest["paid_rewards"] = []
	quest["skipped_stages"] = []
	quest["defeat_holds"] = {}
	quest["defeat_opened"] = {}
	quest["adversary_killed_at_knockout"] = false

	# Rule 19: start linked Event Engine story with B replacing the chain budget (excluded from stories_active_max).
	_start_quest_story(player, quest, int(opts.get("year", 0)), season_idx)
	put_quest(quest)
	return {"ok": true, "reason": "", "quest": quest.duplicate(true)}


## Declines an open person/sect offer immediately, putting its source fact on the 8-season cooldown
## (Rule 7, AC-QS-45, AC-QS-47). Does nothing for board quests (AC-QS-46).
func decline(quest_id: String, season_idx: int, year: int = 0, rules_override: Dictionary = {}) -> Dictionary:
	var quest: Dictionary = get_quest(quest_id)
	if quest.is_empty():
		return {"ok": false, "reason": "quest_not_found", "quest": {}}
	if str(quest.get("state", "")) != "offered":
		return {"ok": false, "reason": "quest_not_offered", "quest": {}}
	if str(quest.get("offer_kind", "person")) == "board":
		return {"ok": true, "reason": "board_no_cooldown", "quest": quest.duplicate(true)}
	return _end_quest(null, quest, "declined", year, season_idx, rules_override)


## Abandons an active quest (Failed with relationship loss & 16-season cooldown; stage 1 applies no
## [code]failed[/code] outcomes, AC-QS-49, AC-QS-52, AC-QS-122) or drops an orphaned quest with no penalty (AC-QS-53).
func abandon(
	player: Character,
	quest_id: String,
	year: int,
	season: int,
	opts: Dictionary = {}
) -> Dictionary:
	var quest: Dictionary = get_quest(quest_id)
	if quest.is_empty():
		return {"ok": false, "reason": "quest_not_found", "quest": {}}
	var st: String = str(quest.get("state", ""))
	var rules_override: Dictionary = Dictionary(opts.get("rules_override", {}))
	var season_idx: int = int(opts.get("season_idx", _season_index(year, season)))
	if st == "orphaned":
		return drop_orphaned(player, quest_id, year, season, opts)
	if st != "active":
		return {"ok": false, "reason": "quest_not_active", "quest": {}}
	var end_opts: Dictionary = opts.duplicate(true)
	end_opts["abandoned"] = true
	end_opts["skip_failed_outcomes"] = int(quest.get("stage", 1)) <= 1
	return _end_quest(player, quest, "failed", year, season_idx, rules_override, end_opts)


## Drops an [code]orphaned[/code] quest with no penalty, no outcomes, no reactions, and 8-season cooldown
## (Rule 10, AC-QS-53, AC-QS-54, AC-QS-98).
func drop_orphaned(
	player: Character,
	quest_id: String,
	year: int,
	season: int,
	opts: Dictionary = {}
) -> Dictionary:
	var quest: Dictionary = get_quest(quest_id)
	if quest.is_empty():
		return {"ok": false, "reason": "quest_not_found", "quest": {}}
	if str(quest.get("state", "")) != "orphaned":
		return {"ok": false, "reason": "quest_not_orphaned", "quest": {}}
	var rules_override: Dictionary = Dictionary(opts.get("rules_override", {}))
	var season_idx: int = int(opts.get("season_idx", _season_index(year, season)))
	return _end_quest(player, quest, "dropped", year, season_idx, rules_override, opts)


# --- Stage Handlers (Rules 5, 8, 9, 10, 17) ----------------------------------------------------------------------

## Unified [code]visit[/code] handler (Rule 5, Rule 8, AC-QS-43): completes every active/orphaned quest whose
## current stage is [code]visit[/code] matching [param place_id] (when no target NPC) or [param npc_id].
## Consumes NO season action. Returns Array of stage/quest transition results.
func on_visit(
	player: Character,
	place_id: String,
	npc_id: String,
	year: int,
	season: int,
	opts: Dictionary = {}
) -> Array:
	var results: Array = []
	if player == null:
		return results
	var season_idx: int = int(opts.get("season_idx", _season_index(year, season)))
	var rules_override: Dictionary = Dictionary(opts.get("rules_override", {}))
	for q in active_quests(player.id):
		var st: Dictionary = _current_stage_of(q)
		if str(st.get("kind", "")) != "visit":
			continue
		var tgt: String = str(st.get("target_id", ""))
		var st_place: String = str(st.get("place_id", ""))
		var matched: bool = false
		if tgt != "":
			matched = (npc_id != "" and npc_id == tgt)
		else:
			matched = (place_id != "" and (st_place == "" or st_place == place_id))
		if matched:
			var res: Dictionary = _complete_current_stage(player, q, year, season_idx, rules_override, opts)
			res["action_spent"] = false
			results.append(res)
	return results


## Dialogue #30 [code]greet[/code] hook (AC-NI-12, AC-QS-43): completes all active [code]visit[/code] stages targeting [param npc_id].
func on_greet_npc(player: Character, npc_id: String, year: int, season: int, opts: Dictionary = {}) -> Array:
	return on_visit(player, player.location_id if player != null else "", npc_id, year, season, opts)


## Travel arrival hook (Rule 5, AC-QS-43): completes all place-only active [code]visit[/code] stages at [param place_id].
func on_arrive_place(player: Character, place_id: String, year: int, season: int, opts: Dictionary = {}) -> Array:
	return on_visit(player, place_id, "", year, season, opts)


## Records post-acceptance crafting provenance on [param item_id] (Rule 5, AC-QS-63).
## Items held prior to acceptance lack [code]crafted_season >= accepted_season[/code] and never satisfy [code]craft[/code] stages.
func on_item_crafted(player: Character, item_id: String, season_idx: int) -> void:
	if player == null or _db == null or item_id == "":
		return
	var item: Dictionary = _db.get_record("items", item_id)
	if item.is_empty():
		return
	item["crafted_season"] = season_idx
	item["crafted_by"] = player.id
	_db.put("items", item)


## Explicit [code]craft[/code] stage completion for a chosen [param quest_id] (Rule 5, AC-QS-63).
## Verifies [param item_id] is in [param player]'s inventory, matches the stage's class & quality floor,
## was crafted AFTER [code]quest.accepted_season[/code], and has not been claimed by another craft stage.
func on_craft(
	player: Character,
	quest_id: String,
	item_id: String,
	year: int,
	season: int,
	opts: Dictionary = {}
) -> Dictionary:
	if player == null or _db == null:
		return {"ok": false, "reason": "missing_context"}
	var quest: Dictionary = get_quest(quest_id)
	if quest.is_empty() or not (str(quest.get("state", "")) in ["active", "orphaned"]):
		return {"ok": false, "reason": "quest_not_active"}
	var st: Dictionary = _current_stage_of(quest)
	if str(st.get("kind", "")) != "craft":
		return {"ok": false, "reason": "stage_not_craft"}
	var item: Dictionary = _db.get_record("items", item_id)
	if not _item_satisfies_craft_stage(player, quest, st, item):
		return {"ok": false, "reason": "item_not_eligible_for_craft"}
	item["quest_craft_claimed_by"] = quest_id
	_db.put("items", item)
	var season_idx: int = int(opts.get("season_idx", _season_index(year, season)))
	var rules_override: Dictionary = Dictionary(opts.get("rules_override", {}))
	var res: Dictionary = _complete_current_stage(player, quest, year, season_idx, rules_override, opts)
	res["action_spent"] = true
	return res


## Completes a [code]deliver[/code] stage on the explicitly chosen [param quest_id] (Rule 5, AC-QS-59, AC-QS-61).
## One handed-over item serves one stage only; spirit-stone deliveries transfer via [MoneyLedger].
func on_deliver(
	player: Character,
	quest_id: String,
	item_id: String,
	year: int,
	season: int,
	opts: Dictionary = {}
) -> Dictionary:
	return submit_deliver(player, quest_id, item_id, year, season, opts)


## Alias for [method on_deliver] matching the session API.
func submit_deliver(
	player: Character,
	quest_id: String,
	item_id: String,
	year: int,
	season: int,
	opts: Dictionary = {}
) -> Dictionary:
	if player == null or _db == null:
		return {"ok": false, "reason": "missing_context"}
	var quest: Dictionary = get_quest(quest_id)
	if quest.is_empty() or not (str(quest.get("state", "")) in ["active", "orphaned"]):
		return {"ok": false, "reason": "quest_not_active"}
	var st: Dictionary = _current_stage_of(quest)
	if str(st.get("kind", "")) != "deliver":
		return {"ok": false, "reason": "stage_not_deliver"}
	var req_place: String = str(st.get("place_id", ""))
	if req_place != "" and player.location_id != "" and player.location_id != req_place and not bool(opts.get("ignore_place", false)):
		return {"ok": false, "reason": "wrong_place"}

	var item_class: String = str(st.get("item_class", ""))
	if item_class == "linh_thach" and item_id == "":
		var price: int = maxi(0, int(st.get("deliver_price", 0)))
		if player.linh_thach < price:
			return {"ok": false, "reason": "insufficient_linh_thach"}
		if price > 0:
			_transfer_from_player(player, quest, st, price, "quest_deliver")
	else:
		var item: Dictionary = _db.get_record("items", item_id)
		if item.is_empty() or str(item.get("owner_id", "")) != player.id or item.has("destroyed_year"):
			return {"ok": false, "reason": "item_not_owned"}
		var req_item_id: String = str(st.get("item_id", st.get("unique_item_id", "")))
		if req_item_id != "" and item_id != req_item_id:
			return {"ok": false, "reason": "wrong_unique_item"}
		if item_class != "" and item_class != "linh_thach" and str(item.get("kind", "")) != item_class:
			return {"ok": false, "reason": "wrong_item_class"}
		var q_min: int = int(st.get("quality_min", 0))
		if int(item.get("quality", 0)) < q_min:
			return {"ok": false, "reason": "quality_too_low"}
		# Remove or decrement from player inventory so this item cannot satisfy a second quest (AC-QS-61).
		var qty: int = int(item.get("qty", 1))
		var need_qty: int = maxi(1, int(st.get("qty", 1)))
		if qty < need_qty:
			return {"ok": false, "reason": "insufficient_qty"}
		if qty > need_qty:
			item["qty"] = qty - need_qty
			_db.put("items", item)
		else:
			var recipient: String = str(st.get("target_id", ""))
			if recipient != "" and _db.has_record("people", recipient) and bool(_db.get_record("people", recipient).get("alive", false)):
				_db.give_item(item_id, recipient)
			else:
				_db.remove("items", item_id)

	var season_idx: int = int(opts.get("season_idx", _season_index(year, season)))
	var rules_override: Dictionary = Dictionary(opts.get("rules_override", {}))
	var res: Dictionary = _complete_current_stage(player, quest, year, season_idx, rules_override, opts)
	res["action_spent"] = true
	return res


## Spends one season action on the chosen quest's [code]mission[/code] stage (Rule 5, Rule 8, AC-QS-62, AC-QS-69).
## Always pays [code]mission_income = 0[/code] (sect or bounty). Advances the stage once all required mission
## seasons are spent.
func on_mission(
	player: Character,
	quest_id: String,
	year: int,
	season: int,
	opts: Dictionary = {}
) -> Dictionary:
	return run_mission_stage(player, quest_id, year, season, opts)


## Alias for [method on_mission] matching the session API.
func run_mission_stage(
	player: Character,
	quest_id: String,
	year: int,
	season: int,
	opts: Dictionary = {}
) -> Dictionary:
	if player == null or _gd == null:
		return {"ok": false, "reason": "missing_context", "mission_income": 0}
	var quest: Dictionary = get_quest(quest_id)
	if quest.is_empty() or not (str(quest.get("state", "")) in ["active", "orphaned"]):
		return {"ok": false, "reason": "quest_not_active", "mission_income": 0}
	var st: Dictionary = _current_stage_of(quest)
	if str(st.get("kind", "")) != "mission":
		return {"ok": false, "reason": "stage_not_mission", "mission_income": 0}

	var rules_override: Dictionary = Dictionary(opts.get("rules_override", {}))
	var need: int = maxi(1, _QuestRules.stage_seasons(_gd, st, rules_override))
	var done: int = int(st.get("seasons_done", 0)) + 1
	st["seasons_done"] = done
	_write_current_stage(quest, st)
	put_quest(quest)

	var season_idx: int = int(opts.get("season_idx", _season_index(year, season)))
	if done >= need:
		var res: Dictionary = _complete_current_stage(player, quest, year, season_idx, rules_override, opts)
		res["mission_income"] = 0
		res["action_spent"] = true
		res["seasons_done"] = done
		res["seasons_needed"] = need
		return res
	return {
		"ok": true,
		"stage_completed": false,
		"quest_state": str(quest.state),
		"mission_income": 0,
		"action_spent": true,
		"seasons_done": done,
		"seasons_needed": need,
		"quest": quest.duplicate(true),
	}


## Evaluates [code]reach[/code] stages across all active/orphaned quests for [param player] (Rule 5, Rule 8, AC-QS-43, AC-QS-70).
## Consumes NO season action and completes every quest whose [code]reach[/code] threshold is met.
func on_reach(
	player: Character,
	sheet: StatSheet,
	year: int,
	season: int,
	opts: Dictionary = {}
) -> Array:
	var results: Array = []
	if player == null:
		return results
	var season_idx: int = int(opts.get("season_idx", _season_index(year, season)))
	var rules_override: Dictionary = Dictionary(opts.get("rules_override", {}))
	for q in active_quests(player.id):
		var st: Dictionary = _current_stage_of(q)
		if str(st.get("kind", "")) != "reach":
			continue
		if _QuestRules.is_reach_met(player, sheet, st):
			var res: Dictionary = _complete_current_stage(player, q, year, season_idx, rules_override, opts)
			res["action_spent"] = false
			results.append(res)
	return results


## Triggers or resolves an [code]event[/code] stage for [param quest_id] (Rule 5, Rule 8, Rule 19, AC-QS-43, AC-QS-151).
## Consumes the season's action ([code]action_spent = true[/code]). When [param opts] carries [code]event_result[/code]
## (or [code]auto_pass = true[/code]), resolves immediately; otherwise returns a normalized event descriptor ready
## for the Event Engine.
func trigger_stage_event(
	player: Character,
	_sheet: StatSheet,
	_rng: RandomNumberGenerator,
	quest_id: String,
	opts: Dictionary = {}
) -> Dictionary:
	if player == null or _gd == null:
		return {"ok": false, "reason": "missing_context", "action_spent": false}
	var quest: Dictionary = get_quest(quest_id)
	if quest.is_empty() or not (str(quest.get("state", "")) in ["active", "orphaned"]):
		return {"ok": false, "reason": "quest_not_active", "action_spent": false}
	var st: Dictionary = _current_stage_of(quest)
	if str(st.get("kind", "")) != "event":
		return {"ok": false, "reason": "stage_not_event", "action_spent": false}

	var year: int = int(opts.get("year", 0))
	var season: int = int(opts.get("season", 0))
	var season_idx: int = int(opts.get("season_idx", _season_index(year, season)))
	var rules_override: Dictionary = Dictionary(opts.get("rules_override", {}))

	if opts.has("event_result") or bool(opts.get("auto_pass", true)):
		var passed: bool = bool(opts.get("event_result", true))
		if passed:
			var res: Dictionary = _complete_current_stage(player, quest, year, season_idx, rules_override, opts)
			res["action_spent"] = true
			return res
		if bool(st.get("fail_on_check_fail", false)):
			var failed: Dictionary = _end_quest(player, quest, "failed", year, season_idx, rules_override, opts)
			failed["action_spent"] = true
			return failed
		return {"ok": true, "stage_completed": false, "action_spent": true, "quest": quest.duplicate(true)}

	return {
		"ok": true,
		"pending": true,
		"action_spent": true,
		"quest_id": quest_id,
		"stage": int(quest.stage),
		"event": {
			"id": "qev_%s_%d" % [quest_id, int(quest.stage)],
			"quest_id": quest_id,
			"story_id": str(quest.get("story_id", "")),
			"chain_id": str(quest.get("chain_id", "")),
			"title": str(st.get("title", quest.get("name", "Ủy thác"))),
			"text": str(st.get("text_rendered", "")),
			"place_id": str(st.get("place_id", quest.get("place_id", ""))),
		},
	}


## Evaluates Formula B [code]stage_hold[/code] status for an active [code]defeat[/code] stage (AC-QS-33..35, AC-QS-101).
## Returns [code]{open: bool, held: bool, ratio: float, max_ratio: float, held_seasons: int, max_hold: int}[/code].
## Note: a ratio below [code]fight_ratio_min[/code] (0.02) stays valid after acceptance (AC-QS-33).
func evaluate_defeat_hold(
	player: Character,
	sheet: StatSheet,
	quest: Dictionary,
	opts: Dictionary = {}
) -> Dictionary:
	var rules_override: Dictionary = Dictionary(opts.get("rules_override", {}))
	var cfg: Dictionary = _QuestRules.config(_gd, rules_override)
	var tier: String = str(quest.get("tier", "ordinary"))
	var tcfg: Dictionary = _QuestRules.tier_cfg(_gd, tier, rules_override)
	var max_ratio: float = float(tcfg.get("fight_ratio_max", 0.35))
	var max_hold: int = int(cfg.get("stage_hold", 4))
	var st_idx: int = int(quest.get("stage", 1)) - 1
	var skey: String = str(st_idx)
	var holds: Dictionary = Dictionary(quest.get("defeat_holds", {}))
	var opened: Dictionary = Dictionary(quest.get("defeat_opened", {}))
	var held_seasons: int = int(holds.get(skey, 0))
	var st: Dictionary = _current_stage_of(quest)
	var ratio: float = _compute_defeat_ratio(player, sheet, st, opts)

	if bool(opened.get(skey, false)) or ratio <= max_ratio + _EPS or held_seasons >= max_hold:
		return {
			"open": true,
			"held": false,
			"ratio": ratio,
			"max_ratio": max_ratio,
			"held_seasons": held_seasons,
			"max_hold": max_hold,
		}
	return {
		"open": false,
		"held": true,
		"ratio": ratio,
		"max_ratio": max_ratio,
		"held_seasons": held_seasons,
		"max_hold": max_hold,
	}


## Resolves a [code]defeat[/code] stage fight (Rule 5, Rule 17, Formulas B, AC-QS-33..37, AC-QS-96, AC-QS-129..130).
## Supports injectable [param fight_fn] returning [code]"win"[/code]/[code]"knockout"[/code], [code]"loss"[/code]/[code]"down"[/code],
## [code]"draw"[/code], or [code]"flight"[/code] (or a Dictionary with [code]result[/code]).
func on_defeat(
	player: Character,
	sheet: StatSheet,
	rng: RandomNumberGenerator,
	quest_id: String,
	fight_fn: Callable = Callable(),
	opts: Dictionary = {}
) -> Dictionary:
	return run_defeat_stage(player, sheet, rng, quest_id, fight_fn, opts)


## Alias for [method on_defeat] matching the session API.
func run_defeat_stage(
	player: Character,
	sheet: StatSheet,
	rng: RandomNumberGenerator,
	quest_id: String,
	fight_fn: Callable = Callable(),
	opts: Dictionary = {}
) -> Dictionary:
	if player == null or _gd == null:
		return {"ok": false, "reason": "missing_context", "action_spent": false}
	var quest: Dictionary = get_quest(quest_id)
	if quest.is_empty() or not (str(quest.get("state", "")) in ["active", "orphaned"]):
		return {"ok": false, "reason": "quest_not_active", "action_spent": false}
	var st: Dictionary = _current_stage_of(quest)
	if str(st.get("kind", "")) != "defeat":
		return {"ok": false, "reason": "stage_not_defeat", "action_spent": false}

	var hold_info: Dictionary = evaluate_defeat_hold(player, sheet, quest, opts)
	if not bool(hold_info.open) and not bool(opts.get("force_open", false)):
		return {
			"ok": false,
			"held": true,
			"reason": "stage_held",
			"ratio": float(hold_info.ratio),
			"held_seasons": int(hold_info.held_seasons),
			"action_spent": false,
			"quest": quest.duplicate(true),
		}

	var st_idx: int = int(quest.get("stage", 1)) - 1
	var opened: Dictionary = Dictionary(quest.get("defeat_opened", {}))
	opened[str(st_idx)] = true
	quest["defeat_opened"] = opened
	put_quest(quest)

	var outcome_code: String = ""
	if fight_fn.is_valid():
		var raw_res: Variant = fight_fn.call(quest, st, player)
		if raw_res is Dictionary:
			outcome_code = str((raw_res as Dictionary).get("result", (raw_res as Dictionary).get("code", "draw"))).to_lower()
		else:
			outcome_code = str(raw_res).to_lower()
	else:
		# Fallback deterministic combat power duel when no fight_fn is injected.
		var tid: String = str(st.get("target_id", ""))
		var f_pl: float = _QuestRules.fight_power_F(player, _gd, _db, sheet)
		var f_opp: float = 1.0
		if tid != "" and _db.has_record("people", tid):
			var opp_c := Character.from_dict(_db.get_record("people", tid))
			f_opp = _QuestRules.fight_power_F(opp_c, _gd, _db, null)
		var chance: float = clampf(f_pl / maxf(f_pl + f_opp, _EPS), 0.05, 0.95)
		var roll: float = rng.randf() if rng != null else 0.5
		outcome_code = "knockout" if roll < chance else "down"

	var year: int = int(opts.get("year", 0))
	var season: int = int(opts.get("season", 0))
	var season_idx: int = int(opts.get("season_idx", _season_index(year, season)))
	var rules_override: Dictionary = Dictionary(opts.get("rules_override", {}))

	# AC-QS-36: draw or flight leaves stage open and deadline running.
	if outcome_code in ["draw", "flight", "flee", "time"]:
		return {
			"ok": true,
			"result": outcome_code,
			"stage_completed": false,
			"action_spent": true,
			"quest": quest.duplicate(true),
		}

	# AC-QS-37: player Down and alive -> Failed (-15 relationship loss).
	if outcome_code in ["down", "loss", "defeat", "lose"]:
		var fail_res: Dictionary = _end_quest(player, quest, "failed", year, season_idx, rules_override, opts)
		fail_res["result"] = outcome_code
		fail_res["stage_completed"] = false
		fail_res["action_spent"] = true
		return fail_res

	# AC-QS-37, AC-QS-96, AC-QS-129..130: knockout win completes the stage; if plan lists `death` on adversary,
	# adversary dies AT ONCE and ties react immediately (surviving any later Fail/Lapse/Drop).
	var knockout_reactions: Array = []
	var adv_killed: bool = false
	if _plan_allows_adversary_death(quest):
		var adv_root: String = _resolve_adversary_root(quest)
		var target_id: String = str(st.get("target_id", ""))
		if adv_root != "" and (target_id == "" or target_id == adv_root or target_id == str(quest.get("adversary_id", ""))):
			var adv_rec: Dictionary = _db.get_record("people", adv_root)
			if not adv_rec.is_empty() and bool(adv_rec.get("alive", false)):
				_kill_adversary_at_knockout(player, adv_rec, quest, year, season)
				quest["adversary_killed_at_knockout"] = true
				adv_killed = true
				knockout_reactions = apply_reactions(quest, "completed", true, rules_override)
				quest["knockout_reactions"] = knockout_reactions.duplicate(true)
				put_quest(quest)

	var comp_res: Dictionary = _complete_current_stage(player, quest, year, season_idx, rules_override, opts)
	comp_res["result"] = outcome_code
	comp_res["action_spent"] = true
	comp_res["adversary_killed"] = adv_killed
	comp_res["knockout_reactions"] = knockout_reactions
	return comp_res


# --- Death, Target Loss & Season-End Tick (Rules 5, 7, 8, 10, 17) ------------------------------------------------

## Handles an NPC death (Rule 5, Rule 10, AC-QS-48, AC-QS-56, AC-QS-93..96).
## If killed by the player, their party, or their sect: offerer death fails with no relationship change (AC-QS-56),
## and stage target death fails with normal relationship loss unless it was a permitted [code]defeat[/code] kill (AC-QS-96).
## Natural deaths withdraw open offers (AC-QS-48) and apply [code]if_target_lost[/code] / orphaning unless
## [code]opts.defer_to_season_end[/code] is true (Rule 8, AC-QS-57).
func on_person_death(
	dead_id: String,
	killer_id: String,
	year: int,
	season: int,
	opts: Dictionary = {}
) -> Array:
	return on_entity_killed(dead_id, killer_id, year, season, opts)


## Alias for [method on_person_death] matching the blueprint signature.
func on_entity_killed(
	dead_id: String,
	killer_id: String,
	year: int,
	season: int,
	opts: Dictionary = {}
) -> Array:
	var events: Array = []
	if _db == null or dead_id == "":
		return events

	var dead_rec: Dictionary = _db.get_record("people", dead_id)
	if not dead_rec.is_empty():
		if not dead_rec.has("estate_at_death"):
			dead_rec["estate_at_death"] = float(dead_rec.get("linh_thach", 0.0))
		dead_rec["alive"] = false
		if killer_id != "":
			dead_rec["killed_by"] = killer_id

	var season_idx: int = int(opts.get("season_idx", _season_index(year, season)))
	var rules_override: Dictionary = Dictionary(opts.get("rules_override", {}))
	var defer_natural: bool = bool(opts.get("defer_to_season_end", false))
	var player: Character = opts.get("player", null) as Character

	for q in all_quests():
		var st_name: String = str(q.get("state", ""))
		if st_name == "offered":
			if _offer_became_invalid(q):
				events.append(_end_quest(player, q, "withdrawn", year, season_idx, rules_override, opts))
			continue
		if not (st_name in ["active", "orphaned"]):
			continue

		var q_player: Character = player if (player != null and player.id == str(q.get("player_id", ""))) else _load_player(str(q.get("player_id", "")))
		var player_caused: bool = _is_player_caused_kill(q_player, killer_id, opts)
		var off_root: String = _resolve_offerer_root(q)

		# AC-QS-56: player/party/sect killed offerer -> Failed, no relationship change, NOT Orphaned.
		if player_caused and (dead_id == off_root or dead_id == str(q.get("offerer_id", ""))):
			var fail_opts: Dictionary = opts.duplicate(true)
			fail_opts["skip_reactions"] = true
			events.append(_end_quest(q_player, q, "failed", year, season_idx, rules_override, fail_opts))
			continue

		# AC-QS-96: player/party/sect killed a stage target -> Failed with normal relationship loss,
		# unless it was the permitted adversary kill on a defeat stage.
		if player_caused and _is_stage_target(q, dead_id):
			var permitted_kill: bool = (
				bool(q.get("adversary_killed_at_knockout", false))
				and dead_id == _resolve_adversary_root(q)
			)
			if not permitted_kill:
				events.append(_end_quest(q_player, q, "failed", year, season_idx, rules_override, opts))
			continue

		# Natural / third-party death: apply immediately unless deferred to season-end Step 2 (Rule 8, AC-QS-57).
		if not defer_natural:
			var res: Dictionary = _evaluate_loss_and_orphaning(q_player, q, year, season_idx, rules_override, opts)
			if not res.is_empty():
				events.append(res)
	return events


## Handles a named unique item being destroyed (Rule 10, AC-QS-59).
## Any active/orphaned quest whose [code]deliver[/code] stage requires that exact unique [param item_id]
## transitions to [code]failed[/code]. Class-item [code]deliver[/code] stages stay open.
func on_item_destroyed(
	player: Character,
	item_id: String,
	year: int,
	season: int,
	opts: Dictionary = {}
) -> Array:
	var events: Array = []
	if _db == null or item_id == "":
		return events
	var rec: Dictionary = _db.get_record("items", item_id)
	if not rec.is_empty():
		rec["destroyed_year"] = year
		_db.put("items", rec)
	var season_idx: int = int(opts.get("season_idx", _season_index(year, season)))
	var rules_override: Dictionary = Dictionary(opts.get("rules_override", {}))
	for q in active_quests(player.id if player != null else ""):
		if _quest_missing_unique_item(q):
			var q_pl: Character = player if player != null else _load_player(str(q.get("player_id", "")))
			events.append(_end_quest(q_pl, q, "failed", year, season_idx, rules_override, opts))
	return events


## Handles player death (Edge Cases, AC-QS-58, AC-QS-145):
## - Every active/orphaned quest ends as [code]failed[/code] with NO relationship change and none carries to the next life.
## - [code]failed[/code] outcomes apply if [code]stage > 1[/code], and do NOT apply if still in [code]stage == 1[/code].
## - Source fact always goes on the 16-season cooldown.
## - Open offers are withdrawn cleanly.
func on_player_death(
	player: Character,
	year: int,
	season: int,
	opts: Dictionary = {}
) -> Array:
	var events: Array = []
	if player == null:
		return events
	var season_idx: int = int(opts.get("season_idx", _season_index(year, season)))
	var rules_override: Dictionary = Dictionary(opts.get("rules_override", {}))

	for q in active_quests(player.id):
		var fail_opts: Dictionary = opts.duplicate(true)
		fail_opts["skip_reactions"] = true
		fail_opts["skip_failed_outcomes"] = int(q.get("stage", 1)) <= 1
		events.append(_end_quest(player, q, "failed", year, season_idx, rules_override, fail_opts))

	for q in offered_quests(player.id):
		events.append(_end_quest(player, q, "withdrawn", year, season_idx, rules_override, opts))
	return events


## Season-end tick enforcing Rule 8's strict resolution order (AC-QS-41, AC-QS-42, AC-QS-45, AC-QS-48, AC-QS-54, AC-QS-57, AC-QS-93..101):
## 1. Resolve stage completions ([code]reach[/code] thresholds, post-accept [code]craft[/code] items, [code]defeat[/code] holds).
## 2. Check target/place/offerer/sect loss, named unique item destruction, and orphaning.
## 3. Check deadlines ([code]active[/code] -> [code]lapsed[/code]; [code]orphaned[/code] -> [code]dropped[/code] with no penalty).
## 4. Withdraw invalid [code]offered[/code] quests and expire offers past [code]offer_seasons[/code] (4).
func tick_season(
	player: Character,
	sheet: StatSheet,
	year: int,
	season: int,
	opts: Dictionary = {}
) -> Array:
	return on_season_end(player, sheet, year, season, opts)


## Alias for [method tick_season] matching the blueprint signature.
func on_season_end(
	player: Character,
	sheet: StatSheet,
	year: int,
	season: int,
	opts: Dictionary = {}
) -> Array:
	var events: Array = []
	if player == null or _gd == null or _db == null:
		return events
	var rules_override: Dictionary = Dictionary(opts.get("rules_override", {}))
	var cfg: Dictionary = _QuestRules.config(_gd, rules_override)
	var season_idx: int = int(opts.get("season_idx", _season_index(year, season)))

	# --- STEP 1: Resolve stage completions & defeat holds (Rule 8) ---
	for q in active_quests(player.id):
		q["seasons_spent"] = int(q.get("seasons_spent", 0)) + 1
		put_quest(q)

		# Loop in case a stage completion immediately advances into a skippable or met stage.
		var st: Dictionary = _current_stage_of(q)
		var kind: String = str(st.get("kind", ""))
		if kind == "reach" and _QuestRules.is_reach_met(player, sheet, st):
			var r_res: Dictionary = _complete_current_stage(player, q, year, season_idx, rules_override, opts)
			r_res["action_spent"] = false
			events.append(r_res)
			continue
		if kind == "craft":
			var crafted_id: String = _find_unclaimed_crafted_item(player, q, st)
			if crafted_id != "":
				var item_rec: Dictionary = _db.get_record("items", crafted_id)
				item_rec["quest_craft_claimed_by"] = str(q.id)
				_db.put("items", item_rec)
				var c_res: Dictionary = _complete_current_stage(player, q, year, season_idx, rules_override, opts)
				events.append(c_res)
				continue
		if kind == "defeat":
			var hold_info: Dictionary = evaluate_defeat_hold(player, sheet, q, opts)
			var skey: String = str(int(q.get("stage", 1)) - 1)
			if bool(hold_info.held):
				var holds: Dictionary = Dictionary(q.get("defeat_holds", {}))
				holds[skey] = int(holds.get(skey, 0)) + 1
				q["defeat_holds"] = holds
				q["deadline_season"] = int(q.get("deadline_season", 0)) + 1
				q["deadline"] = int(q.get("deadline", 0)) + 1
				put_quest(q)
				events.append({
					"type": "defeat_held",
					"quest_id": str(q.id),
					"held_seasons": int(holds[skey]),
					"deadline_season": int(q.deadline_season),
				})
			else:
				var opened: Dictionary = Dictionary(q.get("defeat_opened", {}))
				if not bool(opened.get(skey, false)):
					opened[skey] = true
					q["defeat_opened"] = opened
					put_quest(q)

	# --- STEP 2: Check unique item destruction, orphaning & target/place loss (Rule 8, Rule 10) ---
	for q in active_quests(player.id):
		if _quest_missing_unique_item(q):
			events.append(_end_quest(player, q, "failed", year, season_idx, rules_override, opts))
			continue
		var loss_ev: Dictionary = _evaluate_loss_and_orphaning(player, q, year, season_idx, rules_override, opts)
		if not loss_ev.is_empty():
			events.append(loss_ev)

	# --- STEP 3: Check deadlines (Rule 8, AC-QS-41, AC-QS-42, AC-QS-54, AC-QS-57) ---
	for q in active_quests(player.id):
		var dl_season: int = int(q.get("deadline_season", 0))
		if season_idx >= dl_season:
			var st_name: String = str(q.get("state", ""))
			if st_name == "orphaned":
				events.append(_end_quest(player, q, "dropped", year, season_idx, rules_override, opts))
			else:
				events.append(_end_quest(player, q, "lapsed", year, season_idx, rules_override, opts))

	# --- STEP 4: Withdraw invalid offers & expire offers past offer_seasons (AC-QS-45, AC-QS-48) ---
	var offer_seasons: int = int(cfg.get("offer_seasons", 4))
	for q in offered_quests(player.id):
		if _offer_became_invalid(q):
			events.append(_end_quest(player, q, "withdrawn", year, season_idx, rules_override, opts))
		elif str(q.get("offer_kind", "person")) != "board" and (season_idx - int(q.get("offered_season", season_idx))) >= offer_seasons:
			events.append(_end_quest(player, q, "declined", year, season_idx, rules_override, opts))

	# Refresh local board if requested by caller.
	if bool(opts.get("refresh_board", false)) and _board != null and player.location_id != "":
		_board.refresh_place(player.location_id, player, sheet, int(opts.get("seed", 0)), season_idx, opts)

	return events


# --- Outcomes & Reactions Application (Rules 15, 16, 17, 18, Formulas E) -----------------------------------------

## Applies every resolved [code]outcomes[/code] entry matching [param ending] (Rules 17, 18, AC-QS-115, AC-QS-120..126, AC-QS-132, AC-QS-134).
## Uses [MoneyLedger] for all [code]wealth[/code] changes so [method MoneyLedger.season_check] stays balanced.
## Returns Array of applied outcome records for ending display and logging.
func apply_outcomes(
	player: Character,
	quest: Dictionary,
	ending: String,
	rules_override: Dictionary = {},
	opts: Dictionary = {}
) -> Array:
	var applied: Array = []
	if _db == null or _gd == null or quest.is_empty():
		return applied
	var match_on: String = ""
	if ending == "completed" or ending == "orphaned_completed":
		match_on = "completed"
	elif ending == "failed" or ending == "lapsed":
		if bool(opts.get("skip_failed_outcomes", false)):
			return applied
		match_on = "failed"
	else:
		return applied

	var cfg: Dictionary = _QuestRules.config(_gd, rules_override)
	var b_val: int = int(Dictionary(quest.get("budget", {})).get("B", 0))
	var wealth_cap: int = int(floor(float(cfg.get("world_wealth_share", 0.5)) * float(b_val) + _EPS))
	var inj_max: float = float(cfg.get("world_injury_max", 0.4))
	var stand_max: int = int(cfg.get("world_standing_max", 10))
	var vit_floor: float = float(_gd.breakthrough_rules().get("vitality_floor", 0.05))
	var tie_shares: Dictionary = Dictionary(cfg.get("tie_share", {}))
	var plan: Dictionary = Dictionary(quest.get("plan", quest))
	var outcomes: Array = Array(quest.get("outcomes", plan.get("outcomes", [])))
	var money := MoneyLedger.new(_db, player)
	var sect_members := SectMembers.new(_gd, _db)
	var player_id: String = player.id if player != null else str(quest.get("player_id", ""))

	for raw_oc in outcomes:
		if not (raw_oc is Dictionary):
			continue
		var oc: Dictionary = raw_oc as Dictionary
		if str(oc.get("on", "")) != match_on:
			continue
		var role: String = str(oc.get("role", ""))
		var eff: String = str(oc.get("effect", ""))
		if eff == "death":
			# Rule 17: death lands at knockout, never at quest ending (AC-QS-129, AC-QS-130).
			continue

		match eff:
			"wealth":
				var raw_amt: int = _resolve_outcome_wealth_amount(oc, b_val, wealth_cap)
				if raw_amt == 0:
					continue
				if role == "offerer" or role == "adversary":
					var pid: String = _resolve_offerer_root(quest) if role == "offerer" else _resolve_adversary_root(quest)
					var moved: float = _apply_npc_wealth(money, pid, player_id, raw_amt)
					if absf(moved) > _EPS:
						applied.append({"role": role, "effect": "wealth", "target_id": pid, "amount": int(roundf(moved))})
				elif role == "offerer_ties" or role == "adversary_ties":
					var root_id: String = _resolve_offerer_root(quest) if role == "offerer_ties" else _resolve_adversary_root(quest)
					var ties: Array = _outcome_tie_targets(root_id, player_id)
					if ties.is_empty():
						continue
					# Rule 18, AC-QS-123: split evenly and rounded down (toward 0 for losses).
					var per_tie: int = int(floor(float(raw_amt) / float(ties.size()) + _EPS)) if raw_amt >= 0 else -int(floor(float(-raw_amt) / float(ties.size()) + _EPS))
					if per_tie == 0:
						continue
					for tid in ties:
						var moved_t: float = _apply_npc_wealth(money, str(tid), player_id, per_tie)
						if absf(moved_t) > _EPS:
							applied.append({"role": role, "effect": "wealth", "target_id": str(tid), "amount": int(roundf(moved_t))})
			"standing":
				var sid: String = _resolve_outcome_sect(quest, role)
				if sid == "" or player_id == "":
					continue
				var srec: Dictionary = _db.get_record("sects", sid)
				if srec.is_empty() or str(srec.get("status", "active")) != "active":
					continue
				var s_amt: float = clampf(float(oc.get("amount", 0.0)), -float(stand_max), float(stand_max))
				var delta_st: float = sect_members.change_standing(sid, player_id, s_amt)
				applied.append({"role": role, "effect": "standing", "target_id": sid, "amount": s_amt, "delta": delta_st})
			"injury":
				var inj: float = clampf(float(oc.get("amount", 0.0)), 0.0, inj_max)
				if inj <= 0.0:
					continue
				if role == "offerer" or role == "adversary":
					var pid: String = _resolve_offerer_root(quest) if role == "offerer" else _resolve_adversary_root(quest)
					var loss: float = _apply_npc_injury(pid, player_id, inj, vit_floor)
					if loss > _EPS:
						applied.append({"role": role, "effect": "injury", "target_id": pid, "amount": loss})
				elif role == "offerer_ties" or role == "adversary_ties":
					var root_id: String = _resolve_offerer_root(quest) if role == "offerer_ties" else _resolve_adversary_root(quest)
					var ties: Array = _outcome_tie_targets(root_id, player_id)
					var share: float = float(tie_shares.get("master", 0.5))
					for tid in ties:
						var loss_t: float = _apply_npc_injury(str(tid), player_id, inj * share, vit_floor)
						if loss_t > _EPS:
							applied.append({"role": role, "effect": "injury", "target_id": str(tid), "amount": loss_t})
			"rank":
				if role != "offerer" and role != "adversary":
					continue
				var pid: String = _resolve_offerer_root(quest) if role == "offerer" else _resolve_adversary_root(quest)
				var is_promo: bool = (match_on == "completed" and role == "offerer") or (match_on == "failed" and role == "adversary")
				var moved_rank: Dictionary = _apply_npc_rank_step(pid, player_id, is_promo)
				if bool(moved_rank.changed):
					applied.append({
						"role": role,
						"effect": "rank",
						"target_id": pid,
						"from": moved_rank.from,
						"to": moved_rank.to,
					})
	return applied


## Computes and writes Formula E attitude changes onto every reacting living NPC in [WorldDB]
## (Rule 16, Rule 18, Formulas E, AC-QS-51, AC-QS-52, AC-QS-107..111, AC-QS-129, AC-QS-134, AC-QS-140..141).
func apply_reactions(
	quest: Dictionary,
	ending: String,
	killed_now: bool = false,
	rules_override: Dictionary = {}
) -> Array:
	if _db == null or _gd == null or quest.is_empty():
		return []
	var reactions: Array = _QuestRules.compute_reactions(_gd, _db, quest, ending, killed_now, rules_override)
	for r in reactions:
		var pid: String = str(r.get("person_id", ""))
		var rec: Dictionary = _db.get_record("people", pid)
		if not rec.is_empty() and bool(rec.get("alive", false)):
			rec["attitude"] = int(r.after)
	return reactions


# --- Stage Completion & Reward Payment (Rules 5, 9, 10, 11, 14, 19) ----------------------------------------------

func _complete_current_stage(
	player: Character,
	quest: Dictionary,
	year: int,
	season_idx: int,
	rules_override: Dictionary,
	opts: Dictionary
) -> Dictionary:
	var plan: Dictionary = Dictionary(quest.get("plan", quest))
	var stages: Array = Array(plan.get("stages", []))
	var n: int = stages.size()
	var cur_idx: int = int(quest.get("stage", 1)) - 1
	var is_orphaned: bool = str(quest.get("state", "")) == "orphaned"

	quest["stages_done"] = int(quest.get("stages_done", 0)) + 1

	# Finishing an Orphaned quest's current stage completes it with the proportional orphan payout (Rule 10).
	if is_orphaned:
		var orphan_pay_res: Dictionary = _pay_orphan_completion(player, quest, cur_idx, rules_override, opts)
		var end_res: Dictionary = _end_quest(player, quest, "orphaned_completed", year, season_idx, rules_override, opts)
		end_res["stage_completed"] = true
		end_res["stage_paid"] = int(orphan_pay_res.paid)
		end_res["payment"] = orphan_pay_res
		return end_res

	# Final stage -> Completed!
	if cur_idx >= n - 1:
		var final_pay_res: Dictionary = _pay_stage_rewards(player, quest, cur_idx, true, rules_override, opts)
		var end_res: Dictionary = _end_quest(player, quest, "completed", year, season_idx, rules_override, opts)
		end_res["stage_completed"] = true
		end_res["stage_paid"] = int(final_pay_res.paid_value)
		end_res["payment"] = final_pay_res
		return end_res

	# Non-final stage -> pay stage reward and advance to stage k + 1.
	var pay_res: Dictionary = _pay_stage_rewards(player, quest, cur_idx, false, rules_override, opts)
	quest["stage"] = cur_idx + 2
	_sync_story_stage(quest)
	put_quest(quest)

	# AC-QS-95: if the newly entered stage has a dead target with if_target_lost == "skip",
	# auto-skip it with 0 pay (never moving its pay to the final stage) and advance onward.
	var skipped_now: Array = _auto_skip_dead_stages(quest)
	put_quest(quest)

	return {
		"ok": true,
		"stage_completed": true,
		"quest_state": str(quest.state),
		"new_stage": int(quest.stage),
		"stage_paid": int(pay_res.paid_value),
		"payment": pay_res,
		"skipped_stages": skipped_now,
		"quest": quest.duplicate(true),
	}


func _pay_stage_rewards(
	player: Character,
	quest: Dictionary,
	stage_idx: int,
	is_final: bool,
	rules_override: Dictionary,
	opts: Dictionary
) -> Dictionary:
	var plan: Dictionary = Dictionary(quest.get("plan", quest))
	var stages: Array = Array(plan.get("stages", []))
	var st: Dictionary = stages[stage_idx] as Dictionary if stage_idx >= 0 and stage_idx < stages.size() else {}
	var budget: Dictionary = Dictionary(quest.get("budget", {}))
	var stage_pays: Array = Array(budget.get("stage_pays", []))
	var stage_cap: int = int(stage_pays[stage_idx]) if stage_idx < stage_pays.size() else 0
	var b_total: int = int(budget.get("B", 0))
	var chain_id: String = str(quest.get("chain_id", ""))
	var rewards: Array = Array(st.get("rewards", st.get("effects", [])))
	var rng: RandomNumberGenerator = _stage_reward_rng(quest, stage_idx)

	var paid_cash: int = 0
	var paid_items_val: int = 0
	var paid_value: int = 0
	var granted_items: Array = []
	var granted_boon: Dictionary = {}
	var granted_tree_points: int = 0
	var granted_insight: bool = false
	var granted_above_cap: Dictionary = {}
	var warnings: Array = []
	var lines: Array = []
	var quest_realm: int = int(quest.get("realm_index", plan.get("realm_index", player.realm_index)))
	var leg_r_cap: int = _QuestRules.legendary_rarity_cap(_gd, quest_realm, rules_override)
	var is_legendary: bool = str(quest.get("tier", "")) == "legendary"

	# If the stage has no explicit rewards array, pay its Formula A stage_cap as cash/items up to cash_max.
	if rewards.is_empty() and stage_cap > 0:
		rewards = [{"type": "linh_thach", "amount": stage_cap}]

	for raw_eff in rewards:
		if not (raw_eff is Dictionary):
			continue
		var eff: Dictionary = raw_eff as Dictionary
		var etype: String = str(eff.get("type", ""))
		match etype:
			"linh_thach":
				var want: int = maxi(0, int(eff.get("amount", 0)))
				var allow: int = mini(want, maxi(0, stage_cap - paid_value))
				if chain_id != "":
					allow = int(floor(_EventBudget.spend_scalar(_db, chain_id, "linh_thach", float(allow), float(stage_cap), warnings) + _EPS))
				if allow > 0:
					var got: int = _pay_player_cash(player, quest, allow, "quest_reward", false)
					paid_cash += got
					paid_value += got
					lines.append("linh thạch +%d" % got)
			"tu_vi":
				var frac: float = maxf(0.0, float(eff.get("amount", 0.0)))
				if frac > 0.0:
					var tv_amt: float = frac * CultivationRules.stage_cost(player, _gd)
					CultivationRules.add_tu_vi(player, _gd, tv_amt)
					lines.append("tu vi +%.0f" % tv_amt)
			"relationship":
				# Applied through Formula E reactions on quest completion; record only.
				lines.append("hảo cảm %+d" % int(eff.get("amount", 0)))
			"access":
				var flag_key: String = str(eff.get("flag", eff.get("label", "access_%s" % str(quest.id))))
				_EventStore.set_flag(_db, player.id, "quest.%s.%s" % [str(quest.id), flag_key], -1, true)
				lines.append("đặc quyền: %s" % flag_key)
			"quest_boon":
				var b_res: Dictionary = _pay_lasting_gain(player, quest, eff, rules_override)
				if not b_res.is_empty():
					granted_boon = b_res
					lines.append("phúc duyên: %.2f W" % float(b_res.get("paid_w", 0.0)))
			"tree_point":
				var tp_res: Dictionary = _pay_lasting_gain(player, quest, {"type": "tree_point", "tree_points": int(eff.get("amount", eff.get("tree_points", 1)))}, rules_override)
				granted_tree_points += int(tp_res.get("tree_points", 0))
				if granted_tree_points > 0:
					lines.append("Đạo Đồ +%d điểm" % granted_tree_points)
			"insight":
				if _pay_insight(player):
					granted_insight = true
					lines.append("cảm ngộ Hóa Thần")
			"above_cap_item":
				if is_legendary:
					var price: int = maxi(0, int(eff.get("price", eff.get("value", stage_cap))))
					var allow_p: int = mini(price, maxi(0, b_total - int(quest.get("paid_total", 0)) - paid_value))
					if chain_id != "":
						_EventBudget.spend_scalar(_db, chain_id, "linh_thach", float(allow_p), float(b_total), warnings)
					var item_rec: Dictionary = _grant_above_cap_item(player, quest, eff, leg_r_cap, allow_p, rng)
					if not item_rec.is_empty():
						granted_above_cap = item_rec
						granted_items.append(str(item_rec.id))
						paid_items_val += allow_p
						paid_value += allow_p
						lines.append("bảo vật vượt phẩm (phẩm %d): %s" % [int(item_rec.get("rarity", leg_r_cap)), str(item_rec.get("name", ""))])
			"herb", "material", "artifact", "cong_phap", "pill", "talisman", "treasure":
				var val: int = maxi(0, int(eff.get("price", eff.get("value", 0))))
				var allow_v: int = mini(val, maxi(0, stage_cap - paid_value))
				if chain_id != "" and allow_v > 0:
					allow_v = int(floor(_EventBudget.spend_scalar(_db, chain_id, "linh_thach", float(allow_v), float(stage_cap), warnings) + _EPS))
				var item_rec: Dictionary = _grant_reward_item(player, quest, etype, eff, quest_realm, allow_v, rng)
				if not item_rec.is_empty():
					granted_items.append(str(item_rec.id))
					paid_items_val += allow_v
					paid_value += allow_v
					lines.append("vật phẩm: %s (giá %d)" % [str(item_rec.get("name", etype)), allow_v])

	# Plan-level rare_reward is paid on the final stage (unless already paid in stage rewards).
	if is_final:
		var rare_raw: Variant = plan.get("rare_reward", quest.get("rare_reward", null))
		if rare_raw is Dictionary and not (rare_raw as Dictionary).is_empty():
			var rare: Dictionary = rare_raw as Dictionary
			var rtype: String = str(rare.get("type", ""))
			if rtype == "quest_boon" and granted_boon.is_empty():
				var b_res: Dictionary = _pay_lasting_gain(player, quest, rare, rules_override)
				if not b_res.is_empty():
					granted_boon = b_res
					lines.append("phúc duyên: %.2f W" % float(b_res.get("paid_w", 0.0)))
			elif rtype == "tree_point" and granted_tree_points == 0:
				var tp_res: Dictionary = _pay_lasting_gain(player, quest, rare, rules_override)
				granted_tree_points += int(tp_res.get("tree_points", 0))
				if granted_tree_points > 0:
					lines.append("Đạo Đồ +%d điểm" % granted_tree_points)
			elif rtype == "insight" and not granted_insight:
				if _pay_insight(player):
					granted_insight = true
					lines.append("cảm ngộ Hóa Thần")
			elif rtype == "above_cap_item" and granted_above_cap.is_empty() and is_legendary:
				var price: int = maxi(0, int(rare.get("price", rare.get("value", mini(stage_cap, b_total)))))
				var item_rec: Dictionary = _grant_above_cap_item(player, quest, rare, leg_r_cap, price, rng)
				if not item_rec.is_empty():
					granted_above_cap = item_rec
					granted_items.append(str(item_rec.id))
					lines.append("bảo vật vượt phẩm (phẩm %d): %s" % [int(item_rec.get("rarity", leg_r_cap)), str(item_rec.get("name", ""))])

	var paid_rewards: Array = Array(quest.get("paid_rewards", []))
	paid_rewards.append({
		"stage": stage_idx + 1,
		"cash": paid_cash,
		"items_value": paid_items_val,
		"value": paid_value,
		"items": granted_items,
		"boon": granted_boon,
		"tree_points": granted_tree_points,
		"insight": granted_insight,
		"above_cap_item": granted_above_cap,
		"lines": lines,
	})
	quest["paid_rewards"] = paid_rewards
	quest["paid_total"] = int(quest.get("paid_total", 0)) + paid_value
	_sync_player_record(player)
	put_quest(quest)
	return {
		"paid_cash": paid_cash,
		"paid_items_value": paid_items_val,
		"paid_value": paid_value,
		"items": granted_items,
		"boon": granted_boon,
		"tree_points": granted_tree_points,
		"insight": granted_insight,
		"above_cap_item": granted_above_cap,
		"lines": lines,
		"warnings": warnings,
	}


func _pay_orphan_completion(
	player: Character,
	quest: Dictionary,
	cur_idx: int,
	rules_override: Dictionary,
	_opts: Dictionary
) -> Dictionary:
	var plan: Dictionary = Dictionary(quest.get("plan", quest))
	var stages: Array = Array(plan.get("stages", []))
	var budget: Dictionary = Dictionary(quest.get("budget", {}))
	var stage_pays: Array = Array(budget.get("stage_pays", []))
	var skipped: Array = Array(quest.get("skipped_stages", []))

	# Rule 10, AC-QS-53, AC-QS-90, AC-QS-99:
	# unpaid = planned pay of current stage and every later stage (skipped stages excluded).
	var unpaid: int = 0
	var s_rem: int = 0
	for i in range(cur_idx, stages.size()):
		if skipped.has(i):
			continue
		if i < stage_pays.size():
			unpaid += int(stage_pays[i])
		if stages[i] is Dictionary:
			s_rem += _QuestRules.stage_seasons(_gd, stages[i] as Dictionary, rules_override)
	var s_cur: int = _QuestRules.stage_seasons(_gd, stages[cur_idx] as Dictionary, rules_override) if cur_idx < stages.size() else 1
	var amount: int = _QuestRules.orphan_payout(_gd, unpaid, s_cur, s_rem, rules_override)

	# Orphaned quests NEVER pay lasting gains, insights, or above-cap items (AC-QS-55, AC-QS-88).
	var paid: int = _pay_player_cash(player, quest, amount, "quest_orphan_reward", true)
	var paid_rewards: Array = Array(quest.get("paid_rewards", []))
	paid_rewards.append({
		"stage": cur_idx + 1,
		"orphan": true,
		"unpaid": unpaid,
		"s_cur": maxi(1, s_cur),
		"s_rem": maxi(maxi(1, s_cur), s_rem),
		"planned": amount,
		"cash": paid,
		"value": paid,
		"boon": {},
		"tree_points": 0,
		"insight": false,
		"above_cap_item": {},
	})
	quest["paid_rewards"] = paid_rewards
	quest["paid_total"] = int(quest.get("paid_total", 0)) + paid
	_sync_player_record(player)
	put_quest(quest)
	return {
		"unpaid": unpaid,
		"s_cur": maxi(1, s_cur),
		"s_rem": maxi(maxi(1, s_cur), s_rem),
		"planned": amount,
		"paid": paid,
		"boon": {},
		"tree_points": 0,
		"above_cap_item": {},
	}


## Formula D payment-time lasting gain application (Rule 11, AC-QS-64..68, AC-QS-71).
## Re-checks remaining room against [code]quest_gain_cap_w[/code] (48 W) and [code]quest_tree_point_cap[/code] (3).
func _pay_lasting_gain(
	player: Character,
	quest: Dictionary,
	entry: Dictionary,
	rules_override: Dictionary
) -> Dictionary:
	if player == null:
		return {}
	var room: Dictionary = _QuestRules.lasting_gain_room(
		_gd, player.quest_gain_total_w, player.quest_tree_points_used, rules_override
	)
	var allowed_w: float = float(room.allowed_w)
	if allowed_w <= _EPS:
		return {"paid_w": 0.0, "mods": [], "tree_points": 0}

	var tp_req: int = int(entry.get("tree_points", entry.get("amount", 0))) if str(entry.get("type", "")) == "tree_point" else int(entry.get("tree_points", 0))
	var tp_paid: int = 0
	var tp_w: float = _QuestRules.tree_point_w(_gd, rules_override)
	if tp_req > 0 and tp_w > _EPS:
		# AC-QS-68: if room < tree_point_w, floor(allowed_w / tree_point_w) == 0 -> pays nothing.
		var max_by_w: int = int(floor(allowed_w / tp_w + _EPS))
		var max_by_cap: int = int(room.remaining_tree_points)
		tp_paid = mini(tp_req, mini(max_by_w, max_by_cap))
		if tp_paid > 0:
			player.tree_points += tp_paid
			player.quest_tree_points_used += tp_paid
			var tp_spent_w: float = float(tp_paid) * tp_w
			player.quest_gain_total_w += tp_spent_w
			allowed_w = maxf(0.0, allowed_w - tp_spent_w)

	var raw_mods: Array = []
	for rm in Array(entry.get("mods", [])):
		if rm is Dictionary and str((rm as Dictionary).get("stat", "")) != "":
			raw_mods.append({"stat": str((rm as Dictionary).get("stat", "")), "value": float((rm as Dictionary).get("value", 0.0))})
	var stats_map: Dictionary = Dictionary(entry.get("stats", {}))
	for sk in stats_map.keys():
		raw_mods.append({"stat": str(sk), "value": float(stats_map[sk])})

	var paid_mods: Array = []
	var mods_paid_w: float = 0.0
	if not raw_mods.is_empty() and allowed_w > _EPS:
		var raw_w: float = _QuestRules.boon_weight(_gd, {"mods": raw_mods}, rules_override)
		if raw_w > _EPS:
			var scale: float = minf(1.0, allowed_w / raw_w)
			for m in raw_mods:
				var scaled_v: float = float(m.value) * scale
				if scaled_v > _EPS:
					paid_mods.append({"stat": str(m.stat), "value": scaled_v})
			mods_paid_w = _QuestRules.boon_weight(_gd, {"mods": paid_mods}, rules_override)
			if not paid_mods.is_empty() and mods_paid_w > _EPS:
				player.quest_boons.append({
					"quest_id": str(quest.get("id", "")),
					"title": str(entry.get("title", quest.get("name", "Ủy thác"))),
					"mods": paid_mods.duplicate(true),
				})
				player.quest_gain_total_w += mods_paid_w

	return {
		"paid_w": float(tp_paid) * tp_w + mods_paid_w,
		"mods": paid_mods,
		"tree_points": tp_paid,
	}


## Rule 11, AC-QS-136: re-checks at payment; if player already gained insight elsewhere, pays nothing and replaces nothing.
func _pay_insight(player: Character) -> bool:
	if player == null or player.has_insight:
		return false
	var ns_idx: int = _gd.realm_index("nguyen_anh") if _gd != null else 3
	if ns_idx >= 0 and player.realm_index != ns_idx:
		return false
	player.has_insight = true
	return true


func _grant_above_cap_item(
	player: Character,
	quest: Dictionary,
	spec: Dictionary,
	leg_r_cap: int,
	price: int,
	rng: RandomNumberGenerator
) -> Dictionary:
	var item_class: String = str(spec.get("item_class", "artifact"))
	var target_rarity: int = mini(int(spec.get("rarity", leg_r_cap)), leg_r_cap)
	var realm_idx: int = int(quest.get("realm_index", player.realm_index))
	var item: Dictionary = {}
	if _items != null:
		match item_class:
			"cong_phap":
				item = _items.cong_phap(rng, 3, [], str(spec.get("name", "")))
			_:
				item = _items.artifact(rng, realm_idx, 4, str(spec.get("element", "")), "", str(spec.get("name", "")))
	else:
		item = {"kind": item_class, "name": str(spec.get("name", "Chí Bảo Truyền Kỳ")), "tier": realm_idx, "grade": 4}
	item["rarity"] = target_rarity
	item["above_cap"] = true
	item["quest_id"] = str(quest.get("id", ""))
	if price > 0:
		item["value"] = price
	item["owner_id"] = player.id
	var iid: String = _db.add("items", item)
	item["id"] = iid
	return item


func _grant_reward_item(
	player: Character,
	quest: Dictionary,
	etype: String,
	spec: Dictionary,
	quest_realm: int,
	val: int,
	rng: RandomNumberGenerator
) -> Dictionary:
	var r_cap: int = _QuestRules.realm_rarity_cap(_gd, quest_realm)
	var item: Dictionary = {}
	if _items != null:
		match etype:
			"herb":
				var hid: String = str(spec.get("herb", ""))
				item = _items.herb(hid, 10.0) if hid != "" else _items.random_herb(rng, r_cap, [5.0, 20.0], str(spec.get("element", "")))
			"material":
				var mid: String = str(spec.get("material", ""))
				item = _items.material(mid, 1) if mid != "" else _items.random_material(rng, r_cap, str(spec.get("element", "")))
			"artifact":
				var grade: int = clampi(int(spec.get("grade", 1)), 0, 4)
				item = _items.artifact(rng, quest_realm, grade, str(spec.get("element", "")), "", str(spec.get("name", "")))
			"cong_phap":
				var tier_r: int = clampi(int(spec.get("tier", 0)), 0, 3)
				item = _items.cong_phap(rng, tier_r, [], str(spec.get("name", "")))
			"pill":
				var rid: String = str(spec.get("recipe", "tu_khi_dan"))
				item = _items.pill(rid, clampi(int(spec.get("quality", 0)), 0, 3), maxi(1, int(spec.get("qty", 1))))
			"talisman":
				var tid: String = str(spec.get("talisman", "ho_than_phu"))
				item = _items.talisman(tid, maxi(1, int(spec.get("qty", 1))))
			"treasure":
				item = _items.treasure(str(spec.get("treasure", "linh_can_qua")))
			_:
				item = {"kind": etype, "name": str(spec.get("name", etype)), "qty": 1}
	else:
		item = {"kind": etype, "name": str(spec.get("name", etype)), "qty": 1}
	if val > 0:
		item["value"] = val
	item["owner_id"] = player.id
	var iid: String = _db.add("items", item)
	item["id"] = iid
	return item


# --- Ending, Cooldowns, Logging & Story Bridge (Rules 7, 10, 17, 19) ---------------------------------------------

func _end_quest(
	player: Character,
	quest: Dictionary,
	ending: String,
	year: int,
	season_idx: int,
	rules_override: Dictionary,
	opts: Dictionary = {}
) -> Dictionary:
	var cfg: Dictionary = _QuestRules.config(_gd, rules_override)
	var stored_state: String = "completed" if ending == "orphaned_completed" else ending
	quest["state"] = stored_state
	quest["ending"] = ending
	quest["ended_season"] = season_idx

	var applied_outcomes: Array = apply_outcomes(player, quest, ending, rules_override, opts)
	var applied_reactions: Array = []
	if not bool(opts.get("skip_reactions", false)):
		applied_reactions = apply_reactions(quest, ending, false, rules_override)

	quest["applied_outcomes"] = applied_outcomes
	quest["applied_reactions"] = applied_reactions

	# Rule 7: source fact spent/cooldown tracking (AC-QS-47, AC-QS-48, AC-QS-52, AC-QS-98, AC-QS-145).
	_record_source_fact_ending(quest, ending, season_idx, cfg)

	# Rule 19: close linked Event Engine story silently (story writes NO WorldDB record; quest writes the ONE record).
	_end_quest_story(quest, ending, year, season_idx)

	# Rule 10, Rule 17, AC-QS-60, AC-QS-116: log ONE WorldDB event naming people involved, stages, seasons, rewards.
	var log_event_id: String = _log_quest_ending(player, quest, ending, year, season_idx, applied_outcomes, applied_reactions)
	quest["ending_event_id"] = log_event_id
	put_quest(quest)

	return {
		"ok": true,
		"quest_id": str(quest.id),
		"state": stored_state,
		"ending": ending,
		"outcomes": applied_outcomes,
		"reactions": applied_reactions,
		"event_id": log_event_id,
		"quest": quest.duplicate(true),
	}


func _record_source_fact_ending(quest: Dictionary, ending: String, season_idx: int, cfg: Dictionary) -> void:
	var fid: String = str(quest.get("source_fact_id", ""))
	if fid == "":
		var sf: Dictionary = Dictionary(quest.get("source_fact", {}))
		fid = str(sf.get("id", ""))
	if fid == "":
		return
	var m: Dictionary = _meta()
	var spent: Dictionary = Dictionary(m.get("spent_facts", {}))
	var cds: Dictionary = Dictionary(m.get("fact_cooldowns", {}))
	var cd_def: int = int(cfg.get("reoffer_cooldown_default", 8))
	var cd_fail: int = int(cfg.get("reoffer_cooldown_failed", 16))
	var is_board: bool = str(quest.get("offer_kind", "person")) == "board"

	match ending:
		"completed":
			if is_board and _board != null:
				_board.mark_place_fact_spent(str(quest.get("place_id", "")), str(quest.get("template_id", "")), fid)
			else:
				spent[fid] = true
		"failed":
			cds[fid] = maxi(int(cds.get(fid, -999999)), season_idx + cd_fail)
		"declined", "lapsed", "dropped", "orphaned_completed":
			# Rule 7, AC-QS-47, AC-QS-98: Declined, Lapsed, Orphaned, Dropped -> 8-season cooldown.
			cds[fid] = maxi(int(cds.get(fid, -999999)), season_idx + cd_def)
		"withdrawn":
			# Rule 7, AC-QS-48, AC-QS-98: Withdrawn -> zero cooldown.
			pass

	m["spent_facts"] = spent
	m["fact_cooldowns"] = cds
	_save_meta(m)


func _log_quest_ending(
	player: Character,
	quest: Dictionary,
	ending: String,
	year: int,
	season_idx: int,
	applied_outcomes: Array,
	applied_reactions: Array
) -> String:
	if _db == null:
		return ""
	var people: Array = []
	var pid: String = player.id if player != null else str(quest.get("player_id", ""))
	if pid != "":
		people.append(pid)
	var off_r: String = _resolve_offerer_root(quest)
	if off_r != "" and not people.has(off_r):
		people.append(off_r)
	var adv_r: String = _resolve_adversary_root(quest)
	if adv_r != "" and not people.has(adv_r):
		people.append(adv_r)

	var places: Array = []
	var pl_id: String = str(quest.get("place_id", ""))
	if pl_id != "":
		places.append(pl_id)

	var ev_type: String = "quest_%s" % ending
	var text: String = "Ủy thác '%s' kết thúc (%s): %d chặng, %d mùa, thưởng %d." % [
		str(quest.get("name", quest.get("id", ""))),
		ending,
		int(quest.get("stages_done", 0)),
		int(quest.get("seasons_spent", 0)),
		int(quest.get("paid_total", 0)),
	]
	var season_of_year: int = posmod(season_idx, 4)
	var data := {
		"quest_id": str(quest.get("id", "")),
		"template_id": str(quest.get("template_id", "")),
		"tier": str(quest.get("tier", "")),
		"ending": ending,
		"stages_done": int(quest.get("stages_done", 0)),
		"seasons_spent": int(quest.get("seasons_spent", 0)),
		"paid_total": int(quest.get("paid_total", 0)),
		"paid_rewards": Array(quest.get("paid_rewards", [])).duplicate(true),
		"outcomes": applied_outcomes.duplicate(true),
		"reactions": applied_reactions.duplicate(true),
		"offerer_id": off_r,
		"adversary_id": adv_r,
	}
	return _db.log_event(year, season_of_year, ev_type, text, people, places, [], data)


# --- Orphaning & Target Loss Evaluation (Rules 5, 8, 10) ---------------------------------------------------------

func _evaluate_loss_and_orphaning(
	player: Character,
	quest: Dictionary,
	year: int,
	season_idx: int,
	rules_override: Dictionary,
	opts: Dictionary
) -> Dictionary:
	var plan: Dictionary = Dictionary(quest.get("plan", quest))
	var stages: Array = Array(plan.get("stages", []))
	if stages.is_empty():
		return {}

	# First auto-skip any dead targets on the current stage whose clause is "skip" (AC-QS-95).
	_auto_skip_dead_stages(quest)

	var cur_idx: int = int(quest.get("stage", 1)) - 1
	if cur_idx < 0 or cur_idx >= stages.size():
		return {}
	var cur_st: Dictionary = stages[cur_idx] as Dictionary

	# AC-QS-100: current stage's place gone -> Dropped at once, no penalty.
	var cur_place: String = str(cur_st.get("place_id", ""))
	if cur_place != "" and not _db.has_record("places", cur_place):
		return _end_quest(player, quest, "dropped", year, season_idx, rules_override, opts)

	# AC-QS-94: current stage's own target died (clause "orphan" or "drop") -> Dropped at once, no penalty.
	if _stage_target_is_lost(cur_st):
		var cur_clause: String = str(cur_st.get("if_target_lost", "orphan"))
		if cur_clause != "skip":
			return _end_quest(player, quest, "dropped", year, season_idx, rules_override, opts)

	var is_already_orphaned: bool = str(quest.get("state", "")) == "orphaned"
	if is_already_orphaned:
		# Check payer solvency for already-orphaned quest (AC-QS-54).
		if not _orphan_has_solvent_payer(quest):
			return _end_quest(player, quest, "dropped", year, season_idx, rules_override, opts)
		return {}

	# Check offerer death / sect fall (non-board).
	var should_orphan: bool = false
	var should_drop: bool = false
	var offer_kind: String = str(quest.get("offer_kind", "person"))
	if offer_kind != "board":
		var off_root: String = _resolve_offerer_root(quest)
		if off_root != "":
			var orec: Dictionary = _db.get_record("people", off_root)
			if orec.is_empty() or not bool(orec.get("alive", false)):
				should_orphan = true
		if offer_kind == "sect":
			var osid: String = str(quest.get("offerer_sect_id", ""))
			if osid != "":
				var srec: Dictionary = _db.get_record("sects", osid)
				if srec.is_empty() or str(srec.get("status", "active")) != "active":
					should_orphan = true

	# Check later stages (j > cur_idx) for lost place or lost target (AC-QS-93, AC-QS-100).
	for j in range(cur_idx + 1, stages.size()):
		if not (stages[j] is Dictionary):
			continue
		var later_st: Dictionary = stages[j] as Dictionary
		var lp: String = str(later_st.get("place_id", ""))
		if lp != "" and not _db.has_record("places", lp):
			should_orphan = true
		if _stage_target_is_lost(later_st):
			var clause: String = str(later_st.get("if_target_lost", "orphan"))
			if clause == "drop":
				should_drop = true
				break
			elif clause == "orphan":
				should_orphan = true
			# clause == "skip": handled when stage j begins (AC-QS-95).

	if should_drop:
		return _end_quest(player, quest, "dropped", year, season_idx, rules_override, opts)

	if should_orphan:
		# AC-QS-54: if no estate or sect remains to pay -> Dropped at once with no penalty.
		if not _orphan_has_solvent_payer(quest):
			return _end_quest(player, quest, "dropped", year, season_idx, rules_override, opts)
		quest["state"] = "orphaned"
		quest["orphaned_season"] = season_idx
		put_quest(quest)
		return {
			"ok": true,
			"quest_id": str(quest.id),
			"state": "orphaned",
			"quest": quest.duplicate(true),
		}
	return {}


func _auto_skip_dead_stages(quest: Dictionary) -> Array:
	var skipped_now: Array = []
	var plan: Dictionary = Dictionary(quest.get("plan", quest))
	var stages: Array = Array(plan.get("stages", []))
	var skipped: Array = Array(quest.get("skipped_stages", []))
	while true:
		var idx: int = int(quest.get("stage", 1)) - 1
		# "skip" is never allowed on the last stage (Rule 5).
		if idx < 0 or idx >= stages.size() - 1:
			break
		var st: Dictionary = stages[idx] as Dictionary
		if _stage_target_is_lost(st) and str(st.get("if_target_lost", "orphan")) == "skip":
			if not skipped.has(idx):
				skipped.append(idx)
			skipped_now.append(idx + 1)
			quest["stage"] = idx + 2
			quest["skipped_stages"] = skipped
			_sync_story_stage(quest)
		else:
			break
	return skipped_now


# --- MoneyLedger Helpers (Strict Conservation: gap == 0) ---------------------------------------------------------

func _pay_player_cash(
	player: Character,
	quest: Dictionary,
	amount: int,
	cause: String,
	is_orphan: bool
) -> int:
	if player == null or amount <= 0:
		return 0
	var money := MoneyLedger.new(_db, player)
	var remaining: float = float(amount)
	var paid: int = 0
	var offer_kind: String = str(quest.get("offer_kind", "person"))
	var off_root: String = _resolve_offerer_root(quest)
	var off_sect: String = str(quest.get("offerer_sect_id", ""))
	var place_id: String = str(quest.get("place_id", player.location_id))
	var market_sect: String = MoneyLedger.market_sect_of(_db, place_id) if place_id != "" else ""

	if is_orphan:
		# Rule 10, AC-QS-53, AC-QS-54, AC-QS-100:
		# 1) Living offerer (when target/place on later stage was lost) pays directly.
		if offer_kind != "board" and off_root != "":
			var orec: Dictionary = _db.get_record("people", off_root)
			if not orec.is_empty() and bool(orec.get("alive", false)):
				var got: int = int(money.transfer("npc:%s" % off_root, MoneyLedger.PLAYER, remaining, cause))
				paid += got
				remaining -= float(got)
				if remaining > 0.0 and off_sect != "" and _sect_active(off_sect):
					var got_s: int = int(money.transfer("sect:%s" % off_sect, MoneyLedger.PLAYER, remaining, cause))
					paid += got_s
					remaining -= float(got_s)
				if remaining > 0.0 and _db.count(WorldEconomy.TABLE) == 0:
					var got_m: int = int(money.mint(MoneyLedger.PLAYER, remaining, cause))
					paid += got_m
					remaining -= float(got_m)
				return paid
			# 2) Dead offerer: pay from dead offerer's estate_at_death or active sect treasury.
			if not orec.is_empty():
				var estate: float = float(orec.get("estate_at_death", orec.get("linh_thach", 0.0)))
				if estate > 0.0:
					var from_est: float = floorf(minf(remaining, estate))
					if from_est > 0.0:
						var got_e: int = int(money.mint(MoneyLedger.PLAYER, from_est, cause))
						orec["estate_at_death"] = maxf(0.0, estate - float(got_e))
						orec["linh_thach"] = maxf(0.0, float(orec.get("linh_thach", 0.0)) - float(got_e))
						paid += got_e
						remaining -= float(got_e)
			if remaining > 0.0 and off_sect != "" and _sect_active(off_sect):
				var got_s2: int = int(money.transfer("sect:%s" % off_sect, MoneyLedger.PLAYER, remaining, cause))
				paid += got_s2
				remaining -= float(got_s2)
			return paid

		# 3) Board quest orphaned: paid by the board's holding sect or town market pool.
		var holder_sect: String = _board_holder_sect(quest)
		if holder_sect != "" and _sect_active(holder_sect):
			var got_b: int = int(money.transfer("sect:%s" % holder_sect, MoneyLedger.PLAYER, remaining, cause))
			paid += got_b
			remaining -= float(got_b)
		if remaining > 0.0 and market_sect != "":
			var got_p: int = int(money.transfer("pool:%s" % market_sect, MoneyLedger.PLAYER, remaining, cause))
			paid += got_p
			remaining -= float(got_p)
		if remaining > 0.0 and _db.count(WorldEconomy.TABLE) == 0:
			var got_m2: int = int(money.mint(MoneyLedger.PLAYER, remaining, cause))
			paid += got_m2
		return paid

	# Standard stage / final cash reward: draw from offerer -> offerer_sect -> market pool -> fallback mint.
	if offer_kind != "board" and off_root != "":
		var orec: Dictionary = _db.get_record("people", off_root)
		if not orec.is_empty() and bool(orec.get("alive", false)):
			var got_o: int = int(money.transfer("npc:%s" % off_root, MoneyLedger.PLAYER, remaining, cause))
			paid += got_o
			remaining -= float(got_o)
		elif not orec.is_empty():
			# Offerer died in the completion season (AC-QS-57): pay from estate first, then sect.
			var estate: float = float(orec.get("estate_at_death", orec.get("linh_thach", 0.0)))
			var from_est: float = floorf(minf(remaining, maxf(0.0, estate)))
			if from_est > 0.0:
				var got_e: int = int(money.mint(MoneyLedger.PLAYER, from_est, cause))
				orec["estate_at_death"] = maxf(0.0, estate - float(got_e))
				orec["linh_thach"] = maxf(0.0, float(orec.get("linh_thach", 0.0)) - float(got_e))
				paid += got_e
				remaining -= float(got_e)
	if remaining > 0.0 and off_sect != "" and _sect_active(off_sect):
		var got_s: int = int(money.transfer("sect:%s" % off_sect, MoneyLedger.PLAYER, remaining, cause))
		paid += got_s
		remaining -= float(got_s)
	if remaining > 0.0 and market_sect != "":
		var got_p: int = int(money.transfer("pool:%s" % market_sect, MoneyLedger.PLAYER, remaining, cause))
		paid += got_p
		remaining -= float(got_p)
	if remaining > 0.0:
		var got_m: int = int(money.mint(MoneyLedger.PLAYER, remaining, cause))
		paid += got_m
	return paid


func _transfer_from_player(
	player: Character,
	quest: Dictionary,
	st: Dictionary,
	amount: int,
	cause: String
) -> int:
	if player == null or amount <= 0:
		return 0
	var money := MoneyLedger.new(_db, player)
	var tgt: String = str(st.get("target_id", _resolve_offerer_root(quest)))
	if tgt != "" and _db.has_record("people", tgt) and bool(_db.get_record("people", tgt).get("alive", false)):
		return int(money.transfer(MoneyLedger.PLAYER, "npc:%s" % tgt, float(amount), cause))
	var sid: String = str(quest.get("offerer_sect_id", ""))
	if sid != "" and _sect_active(sid):
		return int(money.transfer(MoneyLedger.PLAYER, "sect:%s" % sid, float(amount), cause))
	var market_sect: String = MoneyLedger.market_sect_of(_db, str(quest.get("place_id", player.location_id)))
	if market_sect != "":
		return int(money.transfer(MoneyLedger.PLAYER, "pool:%s" % market_sect, float(amount), cause))
	return int(money.burn(MoneyLedger.PLAYER, float(amount), cause))


func _orphan_has_solvent_payer(quest: Dictionary) -> bool:
	var offer_kind: String = str(quest.get("offer_kind", "person"))
	if offer_kind == "board":
		var hsect: String = _board_holder_sect(quest)
		if hsect != "" and _sect_active(hsect) and float(_db.get_record("sects", hsect).get("treasury", 0.0)) > 0.0:
			return true
		var place_id: String = str(quest.get("place_id", ""))
		if place_id != "" and _db.has_record("places", place_id):
			var ms: String = MoneyLedger.market_sect_of(_db, place_id)
			if ms != "":
				return MoneyLedger.new(_db, null).balance("pool:%s" % ms) > 0.0
			# Town in a minimal non-market fixture still pays for its own board.
			return _db.count(WorldEconomy.TABLE) == 0
		return false

	var off_root: String = _resolve_offerer_root(quest)
	if off_root != "":
		var orec: Dictionary = _db.get_record("people", off_root)
		if not orec.is_empty():
			if bool(orec.get("alive", false)):
				return true
			var estate: float = float(orec.get("estate_at_death", orec.get("linh_thach", 0.0)))
			if estate > 0.0:
				return true
	var osid: String = str(quest.get("offerer_sect_id", ""))
	if osid != "" and _sect_active(osid):
		if float(_db.get_record("sects", osid).get("treasury", 0.0)) > 0.0:
			return true
	return false


func _apply_npc_wealth(money: MoneyLedger, pid: String, player_id: String, amt: int) -> float:
	if pid == "" or pid == player_id or amt == 0:
		return 0.0
	var rec: Dictionary = _db.get_record("people", pid)
	if rec.is_empty() or not bool(rec.get("alive", false)):
		return 0.0
	var holder: String = "npc:%s" % pid
	if amt > 0:
		return money.mint(holder, float(amt), "quest_outcome")
	return -money.burn(holder, float(-amt), "quest_outcome")


func _apply_npc_injury(pid: String, player_id: String, inj: float, vit_floor: float) -> float:
	if pid == "" or pid == player_id or inj <= 0.0:
		return 0.0
	var rec: Dictionary = _db.get_record("people", pid)
	if rec.is_empty() or not bool(rec.get("alive", false)):
		return 0.0
	var before: float = float(rec.get("vitality", 1.0))
	var after: float = maxf(vit_floor, before - inj)
	rec["vitality"] = after
	return before - after


func _apply_npc_rank_step(pid: String, player_id: String, is_promotion: bool) -> Dictionary:
	if pid == "" or pid == player_id:
		return {"changed": false}
	var rec: Dictionary = _db.get_record("people", pid)
	if rec.is_empty() or not bool(rec.get("alive", false)):
		return {"changed": false}
	var cur_rank: String = str(rec.get("sect_rank", ""))
	if cur_rank == "":
		return {"changed": false}
	var ladder: Array = Array(_gd.world_gen().get("sects", {}).get("rank_ladder", ["ngoai_mon", "noi_mon", "truong_lao", "tong_chu"]))
	var head_rank: String = str(ladder[ladder.size() - 1]) if not ladder.is_empty() else "tong_chu"
	if cur_rank == head_rank:
		return {"changed": false}
	var pos: int = ladder.find(cur_rank)
	if pos < 0:
		return {"changed": false}
	var nxt_pos: int = pos + (1 if is_promotion else -1)
	if nxt_pos < 0 or nxt_pos >= ladder.size():
		return {"changed": false}
	var nxt_rank: String = str(ladder[nxt_pos])
	if nxt_rank == head_rank:
		return {"changed": false}
	rec["sect_rank"] = nxt_rank
	return {"changed": true, "from": cur_rank, "to": nxt_rank}


# --- Event Engine Story Bridge (Rule 19, AC-QS-151..153) ---------------------------------------------------------

func _start_quest_story(player: Character, quest: Dictionary, year: int, season_idx: int) -> void:
	var qid: String = str(quest.get("id", ""))
	var b_val: int = int(Dictionary(quest.get("budget", {})).get("B", 0))
	if _event_engine != null and _event_engine.has_method("start_story"):
		var sres: Dictionary = _event_engine.start_story(
			"quest.%s" % qid,
			player.id,
			Dictionary(quest.get("slots", {})),
			year,
			posmod(season_idx, 4),
			true,
			b_val
		)
		if bool(sres.get("ok", false)):
			var st_rec: Dictionary = Dictionary(sres.get("story", sres))
			quest["story_id"] = str(st_rec.get("id", st_rec.get("story_id", "")))
			quest["chain_id"] = str(st_rec.get("chain_id", ""))
			return
	# Standalone fallback via EventStore + EventBudget (keeps is_quest = true so stories_active_max ignores it).
	var chain_id: String = _EventBudget.create_chain(_db, _gd, player, null, 1.0, 99, b_val)
	var sid: String = _EventStore.add_story(_db, {
		"story_id": "quest.%s" % qid,
		"quest_id": qid,
		"root_id": player.id,
		"is_quest": true,
		"status": "active",
		"stage": int(quest.get("stage", 1)),
		"started_season": season_idx,
		"chain_id": chain_id,
	})
	quest["story_id"] = sid
	quest["chain_id"] = chain_id


func _sync_story_stage(quest: Dictionary) -> void:
	var sid: String = str(quest.get("story_id", ""))
	if sid == "":
		return
	var srec: Dictionary = _EventStore.get_story(_db, sid)
	if not srec.is_empty():
		srec["stage"] = int(quest.get("stage", 1))
		_EventStore.put_story(_db, srec)


func _end_quest_story(quest: Dictionary, ending: String, year: int, season_idx: int) -> void:
	var sid: String = str(quest.get("story_id", ""))
	if sid == "":
		return
	var story_status: String = "failed"
	match ending:
		"completed", "orphaned_completed":
			story_status = "done"
		"lapsed":
			story_status = "timed_out"
		_:
			story_status = "failed"
	if _event_engine != null and _event_engine.has_method("end_story"):
		_event_engine.end_story(sid, story_status, year, posmod(season_idx, 4), false)
		return
	var srec: Dictionary = _EventStore.get_story(_db, sid)
	if not srec.is_empty():
		srec["status"] = story_status
		srec["ended_season"] = season_idx
		_EventStore.put_story(_db, srec)


# --- Internal Helpers --------------------------------------------------------------------------------------------

func _ensure_frozen_plan_fields(quest: Dictionary, player: Character, rules_override: Dictionary) -> void:
	if not quest.has("plan"):
		quest["plan"] = quest.duplicate(true)
	var plan: Dictionary = Dictionary(quest["plan"])
	var tier: String = str(quest.get("tier", plan.get("tier", "ordinary")))
	var realm_idx: int = int(quest.get("realm_index", plan.get("realm_index", player.realm_index)))
	var stages: Array = Array(plan.get("stages", []))
	var travel_s: int = int(plan.get("travel_seasons", 0))
	if not quest.has("budget") or Dictionary(quest.get("budget", {})).is_empty():
		quest["budget"] = _QuestRules.compute_budget(_gd, tier, realm_idx, stages, travel_s, rules_override)
	if not quest.has("deadline") or int(quest.get("deadline", 0)) <= 0:
		var dl: Dictionary = _QuestRules.compute_deadline(_gd, tier, stages, travel_s, rules_override)
		quest["deadline"] = int(dl.deadline)
		quest["window_sum"] = int(dl.window_sum)
	if not quest.has("realm_index"):
		quest["realm_index"] = realm_idx


static func _current_stage_of(quest: Dictionary) -> Dictionary:
	var plan: Dictionary = Dictionary(quest.get("plan", quest))
	var stages: Array = Array(plan.get("stages", []))
	var idx: int = int(quest.get("stage", 1)) - 1
	if idx < 0 or idx >= stages.size() or not (stages[idx] is Dictionary):
		return {}
	return stages[idx] as Dictionary


func _write_current_stage(quest: Dictionary, st: Dictionary) -> void:
	var plan: Dictionary = Dictionary(quest.get("plan", {}))
	var stages: Array = Array(plan.get("stages", []))
	var idx: int = int(quest.get("stage", 1)) - 1
	if idx >= 0 and idx < stages.size():
		stages[idx] = st
		plan["stages"] = stages
		quest["plan"] = plan


func _resolve_offerer_root(quest: Dictionary) -> String:
	var rid: String = str(quest.get("offerer_root_id", quest.get("offerer_id", "")))
	if rid == "":
		var offer_kind: String = str(quest.get("offer_kind", "person"))
		if offer_kind == "board":
			var hsect: String = _board_holder_sect(quest)
			if hsect != "" and _sect_active(hsect):
				return str(_db.get_record("sects", hsect).get("leader_id", ""))
		return ""
	if _db.table_of(rid) == "sects":
		return str(_db.get_record("sects", rid).get("leader_id", ""))
	return rid


func _resolve_adversary_root(quest: Dictionary) -> String:
	var aid: String = str(quest.get("adversary_root_id", quest.get("adversary_id", "")))
	if aid == "":
		return ""
	if _db.table_of(aid) == "sects":
		return str(_db.get_record("sects", aid).get("leader_id", ""))
	return aid


func _resolve_outcome_sect(quest: Dictionary, role: String) -> String:
	if role == "offerer_sect":
		var sid: String = str(quest.get("offerer_sect_id", ""))
		if sid != "":
			return sid
		if str(quest.get("offer_kind", "person")) == "board":
			return _board_holder_sect(quest)
		var off_r: String = _resolve_offerer_root(quest)
		return str(_db.get_record("people", off_r).get("sect_id", "")) if off_r != "" else ""
	if role == "adversary_sect":
		var adv_id: String = str(quest.get("adversary_id", ""))
		if adv_id != "" and _db.table_of(adv_id) == "sects":
			return adv_id
		var adv_r: String = _resolve_adversary_root(quest)
		return str(_db.get_record("people", adv_r).get("sect_id", "")) if adv_r != "" else ""
	return ""


func _board_holder_sect(quest: Dictionary) -> String:
	var sid: String = str(quest.get("offerer_sect_id", ""))
	if sid != "":
		return sid
	var place_id: String = str(quest.get("place_id", ""))
	if place_id != "" and _db.has_record("places", place_id):
		return str(_db.get_record("places", place_id).get("holder", ""))
	return ""


func _outcome_tie_targets(root_id: String, player_id: String) -> Array:
	# Rule 18: offerer_ties / adversary_ties resolves to root's living master and disciples.
	var ties: Dictionary = _QuestRules.direct_ties_of(_db, root_id)
	var out: Array = []
	var seen: Dictionary = {}
	var m_id: String = str(ties.get("master", ""))
	if m_id != "" and m_id != player_id and not seen.has(m_id):
		seen[m_id] = true
		out.append(m_id)
	for did in Array(ties.get("disciples", [])):
		var sdid: String = str(did)
		if sdid != "" and sdid != player_id and not seen.has(sdid):
			seen[sdid] = true
			out.append(sdid)
	out.sort()
	return out


func _resolve_outcome_wealth_amount(oc: Dictionary, b_val: int, wealth_cap: int) -> int:
	var raw: int = 0
	if oc.has("resolved_amount"):
		raw = int(oc["resolved_amount"])
	elif oc.has("amount_share"):
		var sh: float = float(oc["amount_share"])
		var mag: int = int(floor(absf(sh) * float(b_val) + _EPS))
		raw = mag if sh >= 0.0 else -mag
	else:
		raw = int(oc.get("amount", 0))
	if wealth_cap >= 0:
		raw = clampi(raw, -wealth_cap, wealth_cap)
	return raw


func _sect_active(sect_id: String) -> bool:
	if sect_id == "" or _db == null or not _db.has_record("sects", sect_id):
		return false
	return str(_db.get_record("sects", sect_id).get("status", "active")) == "active"


func _offer_became_invalid(quest: Dictionary) -> bool:
	var offer_kind: String = str(quest.get("offer_kind", "person"))
	if offer_kind != "board":
		var off_root: String = _resolve_offerer_root(quest)
		if off_root != "":
			var rec: Dictionary = _db.get_record("people", off_root)
			if rec.is_empty() or not bool(rec.get("alive", false)):
				return true
		if offer_kind == "sect":
			var sid: String = str(quest.get("offerer_sect_id", ""))
			if sid != "" and not _sect_active(sid):
				return true
	var pl_id: String = str(quest.get("place_id", ""))
	if pl_id != "" and not _db.has_record("places", pl_id):
		return true
	var plan: Dictionary = Dictionary(quest.get("plan", quest))
	for raw_st in Array(plan.get("stages", [])):
		if raw_st is Dictionary:
			var sp: String = str((raw_st as Dictionary).get("place_id", ""))
			if sp != "" and not _db.has_record("places", sp):
				return true
	return false


func _stage_target_is_lost(stage: Dictionary) -> bool:
	var tid: String = str(stage.get("target_id", ""))
	if tid == "":
		return false
	if _db.table_of(tid) == "sects":
		return not _sect_active(tid)
	var rec: Dictionary = _db.get_record("people", tid)
	return rec.is_empty() or not bool(rec.get("alive", false))


func _is_stage_target(quest: Dictionary, entity_id: String) -> bool:
	var plan: Dictionary = Dictionary(quest.get("plan", quest))
	var stages: Array = Array(plan.get("stages", []))
	var cur_idx: int = maxi(0, int(quest.get("stage", 1)) - 1)
	for i in range(cur_idx, stages.size()):
		if stages[i] is Dictionary and str((stages[i] as Dictionary).get("target_id", "")) == entity_id:
			return true
	return false


func _is_player_caused_kill(player: Character, killer_id: String, opts: Dictionary) -> bool:
	var side: String = str(opts.get("killer_side", "")).to_lower()
	if side in ["player", "party", "sect"]:
		return true
	if killer_id == "" or player == null:
		return false
	if killer_id == player.id:
		return true
	if player.beasts.has(killer_id):
		return true
	if Array(opts.get("party_ids", [])).has(killer_id):
		return true
	if player.sect_id != "":
		var krec: Dictionary = _db.get_record("people", killer_id)
		if not krec.is_empty() and str(krec.get("sect_id", "")) == player.sect_id:
			return true
	return false


func _plan_allows_adversary_death(quest: Dictionary) -> bool:
	var plan: Dictionary = Dictionary(quest.get("plan", quest))
	for raw in Array(quest.get("outcomes", plan.get("outcomes", []))):
		if raw is Dictionary:
			var oc: Dictionary = raw as Dictionary
			if str(oc.get("on", "")) == "completed" and str(oc.get("role", "")) == "adversary" and str(oc.get("effect", "")) == "death":
				return true
	return false


func _kill_adversary_at_knockout(player: Character, adv_rec: Dictionary, quest: Dictionary, year: int, season: int) -> void:
	adv_rec["estate_at_death"] = float(adv_rec.get("linh_thach", 0.0))
	# Settle the purse through WorldMoney BEFORE marking alive=false so MoneyLedger stays conserved (gap == 0).
	WorldMoney.settle_death(_gd, _db, MoneyLedger.new(_db, player), adv_rec, "")
	adv_rec["alive"] = false
	adv_rec["death_cause"] = "Bị %s hạ sát trong ủy thác '%s'" % [player.name, str(quest.get("name", ""))]
	adv_rec["killed_by"] = player.id
	var pid: String = str(adv_rec.id)
	var place_id: String = str(adv_rec.get("location_id", quest.get("place_id", "")))
	_db.items_on_death(pid, place_id, player.id, "")
	_db.log_event(year, season, "duel", "%s hạ sát %s trong trận quyết chiến." % [player.name, str(adv_rec.get("name", pid))],
		[player.id, pid], [place_id] if place_id != "" else [], [], {"quest_id": str(quest.id), "killer_id": player.id})


func _item_satisfies_craft_stage(player: Character, quest: Dictionary, st: Dictionary, item: Dictionary) -> bool:
	if item.is_empty():
		return false
	if str(item.get("owner_id", "")) != player.id:
		return false
	if item.has("destroyed_year"):
		return false
	var claimed: String = str(item.get("quest_craft_claimed_by", ""))
	if claimed != "" and claimed != str(quest.get("id", "")):
		return false
	var ic: String = str(st.get("item_class", ""))
	if ic != "" and str(item.get("kind", "")) != ic:
		return false
	var q_min: int = int(st.get("quality_min", 0))
	if int(item.get("quality", 0)) < q_min:
		return false
	# AC-QS-63: must be crafted AFTER acceptance (items held before acceptance do not count).
	if not item.has("crafted_season"):
		return false
	return int(item.get("crafted_season", -1)) >= int(quest.get("accepted_season", 0))


func _find_unclaimed_crafted_item(player: Character, quest: Dictionary, st: Dictionary) -> String:
	for item in _db.items_of(player.id):
		if _item_satisfies_craft_stage(player, quest, st, item):
			return str(item.get("id", ""))
	return ""


func _quest_missing_unique_item(quest: Dictionary) -> bool:
	var plan: Dictionary = Dictionary(quest.get("plan", quest))
	var stages: Array = Array(plan.get("stages", []))
	var cur_idx: int = maxi(0, int(quest.get("stage", 1)) - 1)
	for i in range(cur_idx, stages.size()):
		if not (stages[i] is Dictionary):
			continue
		var st: Dictionary = stages[i] as Dictionary
		if str(st.get("kind", "")) != "deliver":
			continue
		var req_id: String = str(st.get("item_id", st.get("unique_item_id", "")))
		if req_id == "":
			continue
		var rec: Dictionary = _db.get_record("items", req_id)
		if rec.is_empty() or rec.has("destroyed_year"):
			return true
	return false


func _compute_defeat_ratio(player: Character, sheet: StatSheet, st: Dictionary, opts: Dictionary) -> float:
	if opts.has("fight_ratio"):
		return float(opts["fight_ratio"])
	if opts.get("fight_power_fn") is Callable and (opts["fight_power_fn"] as Callable).is_valid():
		var res: Variant = (opts["fight_power_fn"] as Callable).call(st, player)
		if res is Dictionary:
			var d: Dictionary = res as Dictionary
			return _QuestRules.fight_ratio(float(d.get("f_opp", 0.0)), float(d.get("f_player", 1.0)))
		var f_pl: float = float(opts.get("f_player", _QuestRules.fight_power_F(player, _gd, _db, sheet)))
		return _QuestRules.fight_ratio(float(res), f_pl)
	var f_player: float = _QuestRules.fight_power_F(player, _gd, _db, sheet)
	var tid: String = str(st.get("target_id", ""))
	if tid != "" and _db.has_record("people", tid):
		var opp := Character.from_dict(_db.get_record("people", tid))
		var f_opp: float = _QuestRules.fight_power_F(opp, _gd, _db, null)
		return _QuestRules.fight_ratio(f_opp, f_player)
	return 0.0


func _stage_reward_rng(quest: Dictionary, stage_idx: int) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = RngUtils.stable_hash("quest_reward:%s:%d" % [str(quest.get("id", "")), stage_idx])
	return rng


func _load_player(player_id: String) -> Character:
	if _db == null or player_id == "":
		return null
	var rec: Dictionary = _db.get_record("people", player_id)
	return null if rec.is_empty() else Character.from_dict(rec)


func _sync_player_record(player: Character) -> void:
	if _db == null or player == null or player.id == "" or not _db.has_record("people", player.id):
		return
	var rec: Dictionary = _db.get_record("people", player.id)
	rec["linh_thach"] = player.linh_thach
	rec["tu_vi"] = player.tu_vi
	rec["tree_points"] = player.tree_points
	rec["has_insight"] = player.has_insight
	rec["quest_boons"] = player.quest_boons.duplicate(true)
	rec["quest_gain_total_w"] = player.quest_gain_total_w
	rec["quest_tree_points_used"] = player.quest_tree_points_used


static func _season_index(year: int, season: int) -> int:
	return year * 4 + season
