class_name EventStore
extends RefCounted
## WorldDB persistence layer for the Event Engine (design/gdd/event-engine.md rules 9-12, 14):
## stores flags (with optional expiry), clamped variables, cooldowns and once-per-life/world
## markers, season pacing counts, scheduled follow-ups, active/ended stories, chain/story
## budgets, and the non-nesting season queue.
##
## Uses native WorldDB tables ([code]event_flags[/code], [code]event_followups[/code],
## [code]event_stories[/code], [code]event_meta[/code]) whenever registered in
## [member WorldDB.TABLES], and transparently falls back to [code]world[/code] bucket records
## so saves serialize identically before those tables are registered.

const TABLE_FLAGS := "event_flags"
const TABLE_FOLLOWUPS := "event_followups"
const TABLE_STORIES := "event_stories"
const TABLE_META := "event_meta"

const _META_PACING_ID := "pacing"
const _META_QUEUE_ID := "queue"
const _BUDGET_PREFIX := "budget:"


# --- Low-level table access (native WorldDB table or world-bucket fallback) ----------------------

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
	if _native(table):
		return db.get_record(table, rid)
	var b: Dictionary = _bucket(db, table, false)
	if b.is_empty():
		return {}
	return Dictionary(b.rows).get(rid, {})


static func _put_rec(db: WorldDB, table: String, rec: Dictionary) -> void:
	if _native(table):
		db.put(table, rec)
		return
	var b: Dictionary = _bucket(db, table, true)
	b.rows[str(rec.id)] = rec


static func _add_rec(db: WorldDB, table: String, prefix: String, rec: Dictionary) -> String:
	if _native(table):
		return db.add(table, rec)
	var b: Dictionary = _bucket(db, table, true)
	var rid: String = str(rec.get("id", ""))
	if rid == "":
		rid = "%s%d" % [prefix, int(b.next)]
		b["next"] = int(b.next) + 1
		rec["id"] = rid
	b.rows[rid] = rec
	return rid


static func _all_recs(db: WorldDB, table: String) -> Array:
	if _native(table):
		return db.all(table)
	var b: Dictionary = _bucket(db, table, false)
	if b.is_empty():
		return []
	return Dictionary(b.rows).values()


static func _remove_rec(db: WorldDB, table: String, rid: String) -> void:
	if _native(table):
		db.remove(table, rid)
		return
	var b: Dictionary = _bucket(db, table, false)
	if not b.is_empty():
		Dictionary(b.rows).erase(rid)


# --- Flags & Variables (Rule 11, AC-EV-15) -------------------------------------------------------

static func _flag_id(scope_id: String, flag_name: String) -> String:
	return "flag:%s|%s" % [scope_id, flag_name]


static func _var_id(scope_id: String, var_name: String) -> String:
	return "var:%s|%s" % [scope_id, var_name]


## Sets [param flag_name] on [param scope_id] (person, place, sect, story, or "world").
## When [param expires_season] >= 0, the flag reads true while [code]now_season < expires_season[/code]
## and reads false at [code]now_season >= expires_season[/code] (Rule 11, AC-EV-15).
static func set_flag(db: WorldDB, scope_id: String, flag_name: String, expires_season: int = -1, value: Variant = true) -> void:
	if db == null or flag_name == "":
		return
	var sid: String = "world" if scope_id == "" else scope_id
	var rec := {
		"id": _flag_id(sid, flag_name),
		"kind": "flag",
		"scope_id": sid,
		"name": flag_name,
		"value": value,
		"expires_season": expires_season,
	}
	_put_rec(db, TABLE_FLAGS, rec)


## Clears [param flag_name] on [param scope_id].
static func clear_flag(db: WorldDB, scope_id: String, flag_name: String) -> void:
	if db == null or flag_name == "":
		return
	var sid: String = "world" if scope_id == "" else scope_id
	_remove_rec(db, TABLE_FLAGS, _flag_id(sid, flag_name))


## True when [param flag_name] is currently active on [param scope_id] at [param now_season].
## Falls back to [code]person.flags[/code] / [code]person.interaction_flags[/code] for Dialogue #30 interop.
static func has_flag(db: WorldDB, scope_id: String, flag_name: String, now_season: int) -> bool:
	if db == null or flag_name == "":
		return false
	var sid: String = "world" if scope_id == "" else scope_id
	var rec: Dictionary = _get_rec(db, TABLE_FLAGS, _flag_id(sid, flag_name))
	if not rec.is_empty():
		var exp: int = int(rec.get("expires_season", -1))
		if exp >= 0 and now_season >= exp:
			return false
		var val: Variant = rec.get("value", true)
		if typeof(val) == TYPE_BOOL:
			return bool(val)
		return val != null and str(val) != ""
	var prec: Dictionary = db.get_record("people", sid)
	if not prec.is_empty():
		for dict_key in ["flags", "interaction_flags"]:
			var fdict: Variant = prec.get(dict_key, {})
			if fdict is Dictionary and (fdict as Dictionary).has(flag_name):
				var v: Variant = (fdict as Dictionary)[flag_name]
				return bool(v) if typeof(v) == TYPE_BOOL else (v != null and str(v) != "")
	return false


## Returns the stored value of [param flag_name] on [param scope_id] at [param now_season], or [param default_val].
static func get_flag(db: WorldDB, scope_id: String, flag_name: String, now_season: int, default_val: Variant = null) -> Variant:
	if not has_flag(db, scope_id, flag_name, now_season):
		return default_val
	var sid: String = "world" if scope_id == "" else scope_id
	var rec: Dictionary = _get_rec(db, TABLE_FLAGS, _flag_id(sid, flag_name))
	if not rec.is_empty():
		return rec.get("value", true)
	var prec: Dictionary = db.get_record("people", sid)
	for dict_key in ["flags", "interaction_flags"]:
		var fdict: Variant = prec.get(dict_key, {})
		if fdict is Dictionary and (fdict as Dictionary).has(flag_name):
			return (fdict as Dictionary)[flag_name]
	return default_val


## Adds [param delta] to integer variable [param var_name] on [param scope_id], clamped to [[param lo], [param hi]].
## Appends a warning to [param warnings] whenever clamping occurs (Rule 11, AC-EV-15).
static func add_var(db: WorldDB, scope_id: String, var_name: String, delta: int, lo: int, hi: int, warnings: Array = []) -> int:
	var cur: int = get_var(db, scope_id, var_name, 0)
	var raw: int = cur + delta
	return set_var(db, scope_id, var_name, raw, lo, hi, warnings)


## Sets integer variable [param var_name] on [param scope_id], clamped to [[param lo], [param hi]].
## Appends a warning to [param warnings] whenever clamping occurs.
static func set_var(db: WorldDB, scope_id: String, var_name: String, value: int, lo: int = -2147483648, hi: int = 2147483647, warnings: Array = []) -> int:
	if db == null or var_name == "":
		return value
	var sid: String = "world" if scope_id == "" else scope_id
	var clamped: int = clampi(value, lo, hi)
	if clamped != value:
		warnings.append("var %s.%s clamped from %d to %d (range %d..%d)" % [sid, var_name, value, clamped, lo, hi])
	var rec := {
		"id": _var_id(sid, var_name),
		"kind": "var",
		"scope_id": sid,
		"name": var_name,
		"value": clamped,
		"lo": lo,
		"hi": hi,
	}
	_put_rec(db, TABLE_FLAGS, rec)
	return clamped


## Reads integer variable [param var_name] on [param scope_id], or [param default_val] if unset.
static func get_var(db: WorldDB, scope_id: String, var_name: String, default_val: int = 0) -> int:
	if db == null or var_name == "":
		return default_val
	var sid: String = "world" if scope_id == "" else scope_id
	var rec: Dictionary = _get_rec(db, TABLE_FLAGS, _var_id(sid, var_name))
	if rec.is_empty():
		return default_val
	return int(rec.get("value", default_val))


## Removes all flags whose [code]expires_season[/code] has been reached at [param now_season].
static func expire_flags(db: WorldDB, now_season: int) -> void:
	if db == null:
		return
	var to_drop: Array = []
	for rec in _all_recs(db, TABLE_FLAGS):
		if str(rec.get("kind", "")) != "flag":
			continue
		var exp: int = int(rec.get("expires_season", -1))
		if exp >= 0 and now_season >= exp:
			to_drop.append(str(rec.id))
	for rid in to_drop:
		_remove_rec(db, TABLE_FLAGS, rid)


# --- Cooldowns, Once Markers & Season Pacing (Rule 9, Formulas E) --------------------------------

static func _pacing_rec(db: WorldDB) -> Dictionary:
	var rec: Dictionary = _get_rec(db, TABLE_META, _META_PACING_ID)
	if rec.is_empty():
		rec = {
			"id": _META_PACING_ID,
			"last_fired": {},
			"fired_life": {},
			"fired_world": {},
			"season_counts": {},
		}
		_put_rec(db, TABLE_META, rec)
	return rec


## Records that [param event_id] fired for [param root_id] at [param now_season], updating cooldown
## and [code]once_per_life[/code] / [code]once_per_world[/code] ledgers (Rule 9, AC-EV-13).
static func mark_fired(db: WorldDB, event_id: String, root_id: String, now_season: int, once_life: bool, once_world: bool) -> void:
	if db == null or event_id == "":
		return
	var rec: Dictionary = _pacing_rec(db)
	var rk: String = "%s|%s" % [root_id, event_id]
	rec.last_fired[rk] = now_season
	if once_life:
		rec.fired_life[rk] = true
	if once_world:
		rec.fired_world[event_id] = true
	_put_rec(db, TABLE_META, rec)


## True when [param event_rec] may fire for [param root_id] at [param now_season] under Formulas E
## (season cap, per-root cooldown, once_per_life, once_per_world).
static func can_fire_pacing(db: WorldDB, gd: GameData, event_rec: Dictionary, root_id: String, now_season: int, check_season_cap: bool = true) -> bool:
	if db == null or event_rec.is_empty():
		return false
	var pacing_cfg: Dictionary = gd.budgets().get("pacing", {}) if gd != null else {}
	var cap: int = int(pacing_cfg.get("player_events_per_season_max", 2))
	if check_season_cap and season_events_count(db, now_season) >= cap:
		return false
	var rec: Dictionary = _pacing_rec(db)
	var eid: String = str(event_rec.get("id", ""))
	if eid == "":
		return true
	var rk: String = "%s|%s" % [root_id, eid]
	if bool(event_rec.get("once_per_world", false)) and bool(rec.fired_world.get(eid, false)):
		return false
	if (bool(event_rec.get("once_per_life", false)) or bool(event_rec.get("once", false))) and bool(rec.fired_life.get(rk, false)):
		return false
	var default_cd: int = int(pacing_cfg.get("default_cooldown_seasons", 8))
	var cd: int = int(event_rec.get("cooldown_seasons", default_cd))
	if cd > 0 and rec.last_fired.has(rk):
		var last_s: int = int(rec.last_fired[rk])
		if (now_season - last_s) < cd:
			return false
	return true


## Number of player events already fired in [param now_season] (follow-ups included).
static func season_events_count(db: WorldDB, now_season: int) -> int:
	if db == null:
		return 0
	var rec: Dictionary = _pacing_rec(db)
	return int(rec.season_counts.get(str(now_season), 0))


## Increments the player event count for [param now_season].
static func increment_season_events(db: WorldDB, now_season: int) -> void:
	if db == null:
		return
	var rec: Dictionary = _pacing_rec(db)
	var sk: String = str(now_season)
	rec.season_counts[sk] = int(rec.season_counts.get(sk, 0)) + 1
	_put_rec(db, TABLE_META, rec)


# --- Scheduled Follow-ups (Rule 11) --------------------------------------------------------------

## Persists a new scheduled follow-up record and returns its assigned id.
static func add_followup(db: WorldDB, rec: Dictionary) -> String:
	if db == null:
		return ""
	return _add_rec(db, TABLE_FOLLOWUPS, "fu", rec)


## Fetches a scheduled follow-up record by id, or {}.
static func get_followup(db: WorldDB, fid: String) -> Dictionary:
	if db == null or fid == "":
		return {}
	return _get_rec(db, TABLE_FOLLOWUPS, fid)


## Updates an existing scheduled follow-up record.
static func put_followup(db: WorldDB, rec: Dictionary) -> void:
	if db == null or str(rec.get("id", "")) == "":
		return
	_put_rec(db, TABLE_FOLLOWUPS, rec)


## Removes a scheduled follow-up record by id.
static func remove_followup(db: WorldDB, fid: String) -> void:
	if db == null or fid == "":
		return
	_remove_rec(db, TABLE_FOLLOWUPS, fid)


## Returns all scheduled follow-ups, optionally filtered by [param root_id].
static func followups_for(db: WorldDB, root_id: String = "") -> Array:
	if db == null:
		return []
	var out: Array = []
	for rec in _all_recs(db, TABLE_FOLLOWUPS):
		if root_id == "" or str(rec.get("root_id", "")) == root_id:
			out.append(rec)
	out.sort_custom(func(a, b):
		var sa: int = int(a.get("scheduled_at", 0))
		var sb: int = int(b.get("scheduled_at", 0))
		if sa != sb:
			return sa < sb
		return str(a.get("event_id", "")) < str(b.get("event_id", "")))
	return out


# --- Stories (Rule 12) ---------------------------------------------------------------------------

## Persists a new story instance record and returns its assigned id.
static func add_story(db: WorldDB, rec: Dictionary) -> String:
	if db == null:
		return ""
	return _add_rec(db, TABLE_STORIES, "st", rec)


## Fetches a story instance record by id, or {}.
static func get_story(db: WorldDB, sid: String) -> Dictionary:
	if db == null or sid == "":
		return {}
	return _get_rec(db, TABLE_STORIES, sid)


## Updates an existing story instance record.
static func put_story(db: WorldDB, rec: Dictionary) -> void:
	if db == null or str(rec.get("id", "")) == "":
		return
	_put_rec(db, TABLE_STORIES, rec)


## Returns all active story instances for [param root_id].
## Excludes quest stories ([code]is_quest == true[/code]) unless [param include_quests] is true
## (Quests Rule 19, AC-QS-153).
static func active_stories(db: WorldDB, root_id: String, include_quests: bool = false) -> Array:
	if db == null:
		return []
	var out: Array = []
	for rec in _all_recs(db, TABLE_STORIES):
		if str(rec.get("status", "")) != "active":
			continue
		if root_id != "" and str(rec.get("root_id", "")) != root_id:
			continue
		if not include_quests and bool(rec.get("is_quest", false)):
			continue
		out.append(rec)
	out.sort_custom(func(a, b):
		var sa: int = int(a.get("started_season", 0))
		var sb: int = int(b.get("started_season", 0))
		if sa != sb:
			return sa < sb
		return str(a.get("id", "")) < str(b.get("id", "")))
	return out


## True if any story instance (active or ended) has ever been created for [param story_def_id].
static func has_world_story_started(db: WorldDB, story_def_id: String) -> bool:
	if db == null or story_def_id == "":
		return false
	for rec in _all_recs(db, TABLE_STORIES):
		if str(rec.get("story_id", "")) == story_def_id:
			return true
	return false


# --- Chain / Story Budgets (Rule 14, Formulas C) -------------------------------------------------

static func _budget_key(chain_id: String) -> String:
	return chain_id if chain_id.begins_with(_BUDGET_PREFIX) else (_BUDGET_PREFIX + chain_id)


## Reads a chain/story budget record by [param chain_id], or {}.
static func get_chain_budget(db: WorldDB, chain_id: String) -> Dictionary:
	if db == null or chain_id == "":
		return {}
	return _get_rec(db, TABLE_META, _budget_key(chain_id))


## Writes or replaces a chain/story budget record. Ensures [code]id[/code] is prefixed cleanly.
static func put_chain_budget(db: WorldDB, rec: Dictionary) -> void:
	if db == null:
		return
	var cid: String = str(rec.get("chain_id", rec.get("id", "")))
	if cid == "":
		return
	rec["chain_id"] = cid.trim_prefix(_BUDGET_PREFIX)
	rec["id"] = _budget_key(rec["chain_id"])
	_put_rec(db, TABLE_META, rec)


## Returns all stored chain/story budget records, optionally filtered by [param root_id].
static func all_chain_budgets(db: WorldDB, root_id: String = "") -> Array:
	if db == null:
		return []
	var out: Array = []
	for rec in _all_recs(db, TABLE_META):
		if not str(rec.get("id", "")).begins_with(_BUDGET_PREFIX):
			continue
		if root_id == "" or str(rec.get("root_id", "")) == root_id:
			out.append(rec)
	return out


# --- Season Priority Queue (Rule 10, AC-EV-12, AC-EV-43) -----------------------------------------

## Returns the persisted non-nesting event queue array for the current season.
static func get_queue(db: WorldDB) -> Array:
	if db == null:
		return []
	var rec: Dictionary = _get_rec(db, TABLE_META, _META_QUEUE_ID)
	if rec.is_empty():
		return []
	return Array(rec.get("items", []))


## Replaces the persisted non-nesting event queue array.
static func set_queue(db: WorldDB, items: Array) -> void:
	if db == null:
		return
	_put_rec(db, TABLE_META, {"id": _META_QUEUE_ID, "items": items.duplicate(true)})
