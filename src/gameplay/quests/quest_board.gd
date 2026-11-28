class_name QuestBoard
extends RefCounted
## Standing quest board manager for sect halls and towns (Template Quests #31).
## Maintains up to [code]board_size[/code] (3) open Errand/Ordinary quests per place,
## replaces the oldest slot each season on refresh (AC-QS-04), enforces zero attitude changes (Rule 18, AC-QS-134),
## never starts a cooldown on reading or leaving (Rule 7, AC-QS-46), and tracks spent (template, place-fact) pairs (Rule 7).
## Persists cleanly inside [WorldDB] (using [code]"quest_boards"[/code] table when present in [member WorldDB.TABLES],
## else [code]"world"[/code] under [code]"w_qboard_<place_id>"[/code] for zero-collision save compatibility).
##
## Usage:
## [codeblock]
## var board := QuestBoard.new(gd, db, builds)
## var open_quests := board.refresh_place(place_id, player, sheet, seed_v, season_idx)
## var shown := board.list_board(place_id)
## [/codeblock]

const _BOARD_TABLE := "quest_boards"
const _FALLBACK_TABLE := "world"
const _FALLBACK_PREFIX := "w_qboard_"
const _QuestRules := preload("res://src/gameplay/quests/quest_rules.gd")
const _QuestGenerator := preload("res://src/gameplay/quests/quest_generator.gd")

var _gd: GameData
var _db: WorldDB
var _builds: BuildGenerator
var _generator: RefCounted


func _init(gd: GameData, db: WorldDB, builds: BuildGenerator = null) -> void:
	_gd = gd
	_db = db
	_builds = builds
	_generator = _QuestGenerator.new(gd, db, builds)


## Returns true if [param place_id] is a registered place that hosts a standing quest board.
func has_board(place_id: String) -> bool:
	if _db == null or place_id == "":
		return false
	var place: Dictionary = _db.get_record("places", place_id)
	if place.is_empty():
		return false
	if bool(place.get("bounties", false)) or str(place.get("holder", "")) != "":
		return true
	var kind: String = str(place.get("kind", place.get("type", "")))
	var allowed: Array = Array(_QuestRules.config(_gd).get("board_place_kinds", []))
	return allowed.has(kind)


## Pure read of currently open board quests at [param place_id].
## Never mutates state and never starts a cooldown (Rule 7, AC-QS-46).
func list_board(place_id: String) -> Array:
	var rec: Dictionary = _read_board_rec(place_id)
	if rec.is_empty():
		return []
	return Array(rec.get("slots", [])).duplicate(true)


## Refreshes the standing board at [param place_id] for [param season_idx]:
## - Drops quests whose place or bound targets disappeared.
## - When a new season has arrived and the board is full ([code]board_size[/code]), drops the oldest slot (AC-QS-04).
## - Fills empty slots up to [code]board_size[/code] with Errand/Ordinary quests (AC-QS-05).
## - Board offers carry [code]board_no_attitude = true[/code] (Rule 18, AC-QS-134) and do not count against [code]offers_per_season[/code] (AC-QS-02).
## Returns the deep-copied list of open board quests.
func refresh_place(
	place_id: String,
	player: Character,
	sheet: StatSheet,
	seed_v: int,
	season_idx: int,
	opts: Dictionary = {}
) -> Array:
	if not has_board(place_id) or player == null:
		return []

	var rules_override: Dictionary = Dictionary(opts.get("rules_override", {}))
	var cfg: Dictionary = _QuestRules.config(_gd, rules_override)
	var board_size: int = int(cfg.get("board_size", 3))

	var rec: Dictionary = _read_board_rec(place_id)
	if rec.is_empty():
		rec = {
			"id": _record_id(place_id),
			"place_id": place_id,
			"last_refresh_season": -1,
			"next_offer_idx": 0,
			"slots": [],
			"spent_pairs": {},
		}

	var slots: Array = Array(rec.get("slots", []))
	var last_season: int = int(rec.get("last_refresh_season", -1))

	# Prune quests referencing dead targets or vanished places.
	var kept: Array = []
	for q_raw in slots:
		if q_raw is Dictionary and _board_quest_still_valid(q_raw as Dictionary):
			kept.append(q_raw)
	slots = kept

	# On a new season, if full, drop the oldest slot so it is replaced (Formulas C, AC-QS-04).
	if last_season >= 0 and season_idx > last_season and slots.size() >= board_size:
		slots.remove_at(0)

	var next_idx: int = int(rec.get("next_offer_idx", 0))
	var spent_pairs: Dictionary = Dictionary(rec.get("spent_pairs", {}))
	var open_tpl_ids: Array = []
	for q in slots:
		open_tpl_ids.append(str((q as Dictionary).get("template_id", "")))

	var needed: int = board_size - slots.size()
	for _slot_attempt in range(needed):
		var gen_opts: Dictionary = opts.duplicate(true)
		gen_opts["spent_board_pairs"] = spent_pairs
		if not gen_opts.has("exclude_template_ids"):
			gen_opts["exclude_template_ids"] = open_tpl_ids.duplicate()

		var res: Dictionary = _generator.generate_offer(
			player, sheet, "board", "", place_id, seed_v, season_idx, next_idx, gen_opts
		)
		next_idx += 1
		# Retry without duplicate-template exclusion if the fixture has fewer unique templates than board_size.
		if not bool(res.ok) and not open_tpl_ids.is_empty() and not opts.has("exclude_template_ids"):
			gen_opts["exclude_template_ids"] = []
			res = _generator.generate_offer(
				player, sheet, "board", "", place_id, seed_v, season_idx, next_idx, gen_opts
			)
			next_idx += 1
		if bool(res.ok):
			var q_rec: Dictionary = res.quest
			q_rec["board_slot_season"] = season_idx
			q_rec["board_no_attitude"] = true
			slots.append(q_rec)
			open_tpl_ids.append(str(q_rec.get("template_id", "")))

	rec["slots"] = slots
	rec["last_refresh_season"] = season_idx
	rec["next_offer_idx"] = next_idx
	rec["spent_pairs"] = spent_pairs
	_write_board_rec(rec)
	return slots.duplicate(true)


## Removes and returns the board quest with [param quest_id] from [param place_id], or {} if not found.
func take_from_board(place_id: String, quest_id: String) -> Dictionary:
	var rec: Dictionary = _read_board_rec(place_id)
	if rec.is_empty():
		return {}
	var slots: Array = Array(rec.get("slots", []))
	for i in range(slots.size()):
		if slots[i] is Dictionary and str((slots[i] as Dictionary).get("id", "")) == quest_id:
			var picked: Dictionary = (slots[i] as Dictionary).duplicate(true)
			slots.remove_at(i)
			rec["slots"] = slots
			_write_board_rec(rec)
			return picked
	return {}


## Marks a completed board quest's [code](template_id, fact_id)[/code] pair as spent at [param place_id]
## so it is not offered at that place again until the place's fact changes (Rule 7).
func mark_place_fact_spent(place_id: String, template_id: String, fact_id: String) -> void:
	if place_id == "" or template_id == "" or fact_id == "":
		return
	var rec: Dictionary = _read_board_rec(place_id)
	if rec.is_empty():
		rec = {
			"id": _record_id(place_id),
			"place_id": place_id,
			"last_refresh_season": -1,
			"next_offer_idx": 0,
			"slots": [],
			"spent_pairs": {},
		}
	var spent: Dictionary = Dictionary(rec.get("spent_pairs", {}))
	spent["%s|%s" % [template_id, fact_id]] = true
	rec["spent_pairs"] = spent
	_write_board_rec(rec)


## Returns true if [code](template_id, fact_id)[/code] has already been completed at [param place_id].
func is_place_fact_spent(place_id: String, template_id: String, fact_id: String) -> bool:
	var rec: Dictionary = _read_board_rec(place_id)
	if rec.is_empty():
		return false
	return Dictionary(rec.get("spent_pairs", {})).has("%s|%s" % [template_id, fact_id])


# --- Persistence helpers ------------------------------------------------------------------------------------------

func _table_name() -> String:
	return _BOARD_TABLE if WorldDB.TABLES.has(_BOARD_TABLE) else _FALLBACK_TABLE


func _record_id(place_id: String) -> String:
	return place_id if WorldDB.TABLES.has(_BOARD_TABLE) else "%s%s" % [_FALLBACK_PREFIX, place_id]


func _read_board_rec(place_id: String) -> Dictionary:
	if _db == null or place_id == "":
		return {}
	return _db.get_record(_table_name(), _record_id(place_id))


func _write_board_rec(rec: Dictionary) -> void:
	if _db == null:
		return
	var tbl: String = _table_name()
	if _db.has_record(tbl, str(rec.id)):
		_db.put(tbl, rec)
	else:
		_db.add(tbl, rec)


func _board_quest_still_valid(q: Dictionary) -> bool:
	var place_id: String = str(q.get("place_id", ""))
	if place_id != "" and not _db.has_record("places", place_id):
		return false
	var plan: Dictionary = Dictionary(q.get("plan", {}))
	for raw_st in Array(plan.get("stages", [])):
		if not (raw_st is Dictionary):
			continue
		var st: Dictionary = raw_st as Dictionary
		var sp: String = str(st.get("place_id", ""))
		if sp != "" and not _db.has_record("places", sp):
			return false
		var tid: String = str(st.get("target_id", ""))
		if tid != "" and _db.table_of(tid) == "people":
			var p: Dictionary = _db.get_record("people", tid)
			if p.is_empty() or not bool(p.get("alive", false)):
				return false
	return true
