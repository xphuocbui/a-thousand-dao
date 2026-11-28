class_name EventEngine
extends RefCounted
## Master Event Engine runtime orchestrator (design/gdd/event-engine.md Rules 1-23,
## Formulas A-E; AC-EV-01..46, AC-WG-56).
##
## Coordinates:
## - Season pulse draws ([method pulse_chance], [method roll_pulse]) with pacing & cooldowns;
## - All 15 game-moment hooks & all 54 trait [code]event:*[/code] hooks ([method raise_hook]);
## - Non-nesting season priority queue ([code]0 = follow-up/story[/code], [code]1 = hook[/code],
##   [code]2 = pulse[/code]; [method drain_queue]);
## - Scheduled follow-ups (delay ranges, waiting windows, hook-keyed triggers, root death cleanup);
## - Multi-stage stories (start/cap/priority displacement, seasonal heartbeat, end records);
## - Hidden chronicle uncoverings ([method uncover_chronicle], AC-WG-56);
## - Off-screen NPC seasonal event step ([method run_npc_season]) using deterministic keyed RNG
##   streams and [NpcTraits] F2 choice weights.
##
## Ownership & memory safety: holds references to [GameData], [WorldDB], [BuildGenerator],
## [EventTemplateSource], [EventValidator], and [EventResolver]; none of them holds a strong
## reference back to [EventEngine] (zero cyclic [RefCounted] leaks).

const _EventStore = preload("res://src/gameplay/events/event_store.gd")
const _EventConditions = preload("res://src/gameplay/events/event_conditions.gd")
const _EventBudget = preload("res://src/gameplay/events/event_budget.gd")
const _EventTemplateSource = preload("res://src/gameplay/events/event_template_source.gd")
const _EventValidator = preload("res://src/gameplay/events/event_validator.gd")
const _EventResolver = preload("res://src/gameplay/events/event_resolver.gd")

const PRIO_FOLLOWUP := 0
const PRIO_HOOK := 1
const PRIO_PULSE := 2

var _gd: GameData
var _db: WorldDB
var _builds: BuildGenerator
var _templates: _EventTemplateSource
var _validator: _EventValidator
var _resolver: _EventResolver

## True while an event is actively resolving or pending so hooks enqueue rather than nest (AC-EV-43).
var busy: bool = false
## Optional RatingService used for off-screen NPC combat checks (Power Rankings rule 12).
var ratings: RatingService
## Warnings collected during the most recent engine step (empty pools, story refusals, etc.).
var last_warnings: Array = []
## Number of off-screen NPC events resolved during the most recent [method run_npc_season] call.
var last_npc_fired: int = 0


func _init(
	gd: GameData,
	db: WorldDB,
	builds: BuildGenerator,
	templates: _EventTemplateSource = null,
	validator: _EventValidator = null,
	resolver: _EventResolver = null
) -> void:
	_gd = gd
	_db = db
	_builds = builds
	_templates = templates if templates != null else _EventTemplateSource.new(gd, db, builds)
	_validator = validator if validator != null else _EventValidator.new(gd, db, builds)
	_resolver = resolver if resolver != null else _EventResolver.new(gd, db, builds, ItemFactory.new(gd))


# --- Formulas A: Season Pulse (Rules 5, 7, 9; AC-EV-03, AC-EV-06, AC-EV-07) ----------------------

## Computes the player's season pulse probability (Formulas A, AC-EV-06):
## [code]clamp(p_base + p_danger * d + explore_bonus + b_cd, 0.0, 1.0)[/code].
func pulse_chance(c: Character, sheet: StatSheet, place: Dictionary, explore_bonus: float, edge_on: bool, co_duyen_left: int) -> float:
	var cfg: Dictionary = _gd.event_templates().get("random_event_chance", {"base": 0.12, "per_danger": 0.06})
	var p_base: float = float(cfg.get("base", 0.12))
	var p_danger: float = float(cfg.get("per_danger", 0.06))
	var d: int = int(place.get("danger", 1))
	var b_cd: float = 0.0
	if edge_on and co_duyen_left > 0 and CultivationRules.at_bottleneck(c, _gd):
		var b_cd0: float = float(ProgressionEdges.config(_gd).player.co_duyen_bottleneck_event_bonus)
		var cd_pct: float = sheet.total("co_duyen_pct") if sheet != null else 0.0
		b_cd = b_cd0 * (1.0 + cd_pct / 100.0)
	return clampf(p_base + p_danger * float(d) + explore_bonus + b_cd, 0.0, 1.0)


## Rolls the season pulse for [param c] in [param mode] (e.g. "cultivate", "explore", "closed_door").
## [code]closed_door[/code] never rolls a pulse or touches [param rng] (Rule 5, AC-EV-07).
## Only [code]kind == "pulse"[/code] templates are ever drawn (Rule 3, AC-EV-03).
func roll_pulse(c: Character, sheet: StatSheet, rng: RandomNumberGenerator, mode: String, explore_bonus: float, extras: Dictionary = {}) -> Dictionary:
	last_warnings = []
	if mode == "closed_door" or mode == "be_quan":
		return {"ok": false, "rolled": false, "hit": false, "skipped": "closed_door", "event": {}, "warnings": []}
	var year: int = int(extras.get("year", 0))
	var season: int = int(extras.get("season", 0))
	var now_season: int = _abs_season(year, season, extras)
	var cap: int = int(_gd.budgets().get("pacing", {}).get("player_events_per_season_max", 2))
	if _EventStore.season_events_count(_db, now_season) >= cap:
		return {"ok": false, "rolled": false, "hit": false, "skipped": "season_cap", "event": {}, "warnings": []}

	var place: Dictionary = _db.get_record("places", c.location_id)
	var edge_on: bool = bool(extras.get("edge", false))
	var co_duyen_left: int = int(extras.get("co_duyen_left", 0))
	var chance: float = pulse_chance(c, sheet, place, explore_bonus, edge_on, co_duyen_left)
	if rng.randf() >= chance:
		return {"ok": false, "rolled": true, "hit": false, "event": {}, "warnings": []}

	if busy or bool(extras.get("has_pending", false)):
		_enqueue_item({
			"priority": PRIO_PULSE,
			"kind": "pulse",
			"event_id": "",
			"scheduled_at": now_season,
			"year": year,
			"season": season,
			"extras": _safe_extras(extras),
		})
		return {"ok": true, "rolled": true, "hit": true, "queued": true, "event": {}, "warnings": []}

	return _draw_pulse_now(c, sheet, rng, year, season, now_season, extras)


# --- Rule 6: Game-Moment Hooks & Hook-Keyed Follow-ups (AC-EV-08, 09, 17, 43) --------------------

## Raises game-moment hook [param hook_id] for [param root].
## 1. Activates any hook-keyed follow-ups waiting on [param hook_id] (AC-EV-17).
## 2. Starts any authored [code]start.mode == "hook"[/code] stories whose conditions hold.
## 3. If [code]payload.queue_only[/code], [member busy], or [code]payload.has_pending[/code],
##    enqueues onto the season queue without immediately activating or nesting (AC-EV-43).
## 4. Otherwise rolls the hook's chance and fires at most ONE eligible event (AC-EV-09).
func raise_hook(hook_id: String, root: Character, sheet: StatSheet, rng: RandomNumberGenerator, payload: Dictionary = {}) -> Dictionary:
	last_warnings = []
	var queue_only: bool = bool(payload.get("queue_only", false))
	var year: int = int(payload.get("year", 0))
	var season: int = int(payload.get("season", 0))
	var now_season: int = _abs_season(year, season, payload)
	var ctx: Dictionary = _build_ctx(root, sheet, year, season, payload)
	var bound_other_id: String = str(payload.get("other_id", payload.get("npc_id", "")))
	var bound_other: Dictionary = _db.get_record("people", bound_other_id) if bound_other_id != "" else {}
	var env: Dictionary = _templates.env_from_ctx(ctx, bound_other)

	# 1. Hook-keyed follow-ups (Rule 11, AC-EV-17)
	var triggered_fu: Dictionary = _check_hook_followups(hook_id, root, ctx, env, now_season, year, season)
	if not triggered_fu.is_empty():
		if queue_only or busy or bool(payload.get("has_pending", false)):
			return {"ok": true, "queued": true, "followup": true, "event": {}, "warnings": last_warnings}
		var drained: Dictionary = drain_queue(root, sheet, rng, year, season, payload)
		if not drained.is_empty():
			return {"ok": true, "fired": true, "followup": true, "event": drained, "warnings": last_warnings}

	# 2. Check hook-started stories (Rule 12)
	for st_def in _templates.all_stories():
		var st_start: Dictionary = Dictionary(st_def.get("start", {}))
		if str(st_start.get("mode", "")) != "hook" or str(st_start.get("hook", "")) != hook_id:
			continue
		if bool(st_def.get("once_per_world", false)) and _EventStore.has_world_story_started(_db, str(st_def.id)):
			continue
		var scond: Dictionary = Dictionary(st_start.get("conditions", {}))
		if not scond.is_empty() and not _EventConditions.evaluate(scond, env, _gd, _db):
			continue
		var sres: Dictionary = start_story(str(st_def.id), root.id, {}, year, season, false, -1, root, sheet)
		if bool(sres.get("ok", false)):
			var srec: Dictionary = sres.story
			var stage0: Dictionary = _stage_def(st_def, str(srec.stage))
			if not stage0.is_empty():
				var st_extras: Dictionary = _safe_extras(payload)
				st_extras.erase("queue_only")
				st_extras.erase("has_pending")
				_enqueue_item({
					"priority": PRIO_FOLLOWUP,
					"kind": "story",
					"event_id": str(stage0.get("event_id", "")),
					"story_instance_id": str(srec.id),
					"scheduled_at": now_season,
					"year": year,
					"season": season,
					"extras": st_extras,
				})
				if not queue_only and not busy and not bool(payload.get("has_pending", false)):
					var d_ev: Dictionary = drain_queue(root, sheet, rng, year, season, payload)
					if not d_ev.is_empty():
						return {"ok": true, "fired": true, "story_started": str(st_def.id), "event": d_ev, "warnings": last_warnings}
				return {"ok": true, "queued": true, "story_started": str(st_def.id), "event": {}, "warnings": last_warnings}

	# 3. Non-nesting / queue-only guard (Rule 10, AC-EV-43)
	if queue_only or busy or bool(payload.get("has_pending", false)):
		var clean_payload: Dictionary = _safe_extras(payload)
		clean_payload.erase("queue_only")
		clean_payload.erase("has_pending")
		_enqueue_item({
			"priority": PRIO_HOOK,
			"kind": "hook",
			"hook_id": hook_id,
			"event_id": str(payload.get("template_id", hook_id)),
			"scheduled_at": now_season,
			"year": year,
			"season": season,
			"payload": clean_payload,
		})
		return {"ok": true, "queued": true, "event": {}, "warnings": last_warnings}

	# 4. Fire at most one eligible event for this hook (Rule 6, AC-EV-09)
	return _fire_hook_now(hook_id, root, sheet, rng, year, season, now_season, payload)


# --- Rule 10, 11, 12: Seasonal Heartbeat & Priority Queue (AC-EV-12, 16, 18, 43) -----------------

## Runs the start-of-season Event Engine heartbeat for [param player]:
## expires timed flags, checks due/waiting follow-ups, evaluates active non-quest stories
## (fail flags, living scopes, timeouts, next stage conditions), and enqueues eligible items
## onto the non-nesting priority queue. Returns status/log lines.
func on_season_start(player: Character, sheet: StatSheet, _rng: RandomNumberGenerator, year: int, season: int, extras: Dictionary = {}) -> Array:
	last_warnings = []
	var now_season: int = _abs_season(year, season, extras)
	_EventStore.expire_flags(_db, now_season)
	var lines: Array = []
	var ctx: Dictionary = _build_ctx(player, sheet, year, season, extras)

	# 1. Process due / waiting non-hook follow-ups (Rule 11, AC-EV-16)
	for fu in _EventStore.followups_for(_db, player.id):
		if str(fu.get("hook", "")) != "":
			continue
		var due_s: int = int(fu.get("due_season", 0))
		if now_season < due_s:
			continue
		var wait_s: int = int(fu.get("wait_seasons", _gd.budgets().get("pacing", {}).get("default_wait_seasons", 4)))
		if (now_season - due_s) >= wait_s:
			_EventStore.remove_followup(_db, str(fu.id))
			lines.append("Follow-up '%s' expired after waiting %d seasons." % [str(fu.get("event_id", "")), wait_s])
			continue
		var t: Dictionary = _templates.get_template(str(fu.get("event_id", "")))
		if t.is_empty():
			_EventStore.remove_followup(_db, str(fu.id))
			continue
		var other_id: String = str(Dictionary(fu.get("scopes", {})).get("other", ""))
		var other_rec: Dictionary = _db.get_record("people", other_id) if other_id != "" else {}
		var env: Dictionary = _templates.env_from_ctx(ctx, other_rec)
		var cond: Dictionary = Dictionary(t.get("conditions", {}))
		if not cond.is_empty() and not _EventConditions.evaluate(cond, env, _gd, _db):
			continue   # stays in Waiting state until wait_seasons runs out
		_enqueue_item({
			"priority": PRIO_FOLLOWUP,
			"kind": "followup",
			"followup_id": str(fu.id),
			"event_id": str(fu.get("event_id", "")),
			"scheduled_at": int(fu.get("scheduled_at", due_s)),
			"year": year,
			"season": season,
			"extras": _safe_extras(extras),
		})

	# 2. Heartbeat active non-quest stories (Rule 12, AC-EV-18)
	for srec in _EventStore.active_stories(_db, player.id, false):
		var st_def: Dictionary = _templates.get_story(str(srec.get("story_id", "")))
		if st_def.is_empty():
			continue
		# Check fail_flags
		var failed_flag: bool = false
		for ff in Array(st_def.get("fail_flags", [])):
			if _EventStore.has_flag(_db, player.id, str(ff), now_season) or _EventStore.has_flag(_db, str(srec.id), str(ff), now_season) or _EventStore.has_flag(_db, "world", str(ff), now_season):
				failed_flag = true
				break
		if failed_flag:
			end_story(str(srec.id), "failed", year, season, true)
			lines.append("Story '%s' failed." % str(srec.get("name", "")))
			continue
		# Check required living scopes
		var scope_dead: bool = false
		var s_scopes: Dictionary = Dictionary(srec.get("scopes", {}))
		for req_sc in Array(st_def.get("required_living_scopes", [])):
			var sc_pid: String = str(s_scopes.get(str(req_sc), ""))
			if sc_pid != "":
				var p_rec: Dictionary = _db.get_record("people", sc_pid)
				if p_rec.is_empty() or not bool(p_rec.get("alive", false)):
					var death_stage: String = str(Dictionary(st_def.get("on_scope_death", {})).get(str(req_sc), ""))
					if death_stage != "":
						advance_story(str(srec.id), death_stage, year, season)
					else:
						end_story(str(srec.id), "failed", year, season, true)
						lines.append("Story '%s' failed after scope death." % str(srec.get("name", "")))
						scope_dead = true
					break
		if scope_dead:
			continue
		# Check timeout
		var timeout_s: int = int(srec.get("timeout_seasons", st_def.get("timeout_seasons", 24)))
		if timeout_s > 0 and (now_season - int(srec.get("started_season", now_season))) >= timeout_s:
			end_story(str(srec.id), "timed_out", year, season, true)
			lines.append("Story '%s' timed out." % str(srec.get("name", "")))
			continue
		# Check current stage event conditions
		var cur_stage_id: String = str(srec.get("stage", ""))
		if cur_stage_id == "" or str(srec.get("stage_fired", "")) == cur_stage_id:
			continue
		var stg: Dictionary = _stage_def(st_def, cur_stage_id)
		if stg.is_empty():
			continue
		var other_id_s: String = str(s_scopes.get("other", ""))
		var other_rec_s: Dictionary = _db.get_record("people", other_id_s) if other_id_s != "" else {}
		var env_s: Dictionary = _templates.env_from_ctx(ctx, other_rec_s, srec)
		var stg_cond: Dictionary = Dictionary(stg.get("conditions", {}))
		if not stg_cond.is_empty() and not _EventConditions.evaluate(stg_cond, env_s, _gd, _db):
			continue
		_enqueue_item({
			"priority": PRIO_FOLLOWUP,
			"kind": "story",
			"story_instance_id": str(srec.id),
			"event_id": str(stg.get("event_id", "")),
			"scheduled_at": int(srec.get("started_season", now_season)),
			"year": year,
			"season": season,
			"extras": _safe_extras(extras),
		})

	return lines


## Pops and returns the highest-priority pending event from the season queue if under
## [code]player_events_per_season_max[/code] (Rule 10, Formulas E; AC-EV-12, AC-EV-43), or {}.
func drain_queue(player: Character, sheet: StatSheet, rng: RandomNumberGenerator, year: int = -1, season: int = -1, extras: Dictionary = {}) -> Dictionary:
	if busy:
		return {}
	var items: Array = _EventStore.get_queue(_db)
	if items.is_empty():
		return {}
	items.sort_custom(_queue_less)

	var eff_year: int = year if year >= 0 else int(items[0].get("year", 0))
	var eff_season: int = season if season >= 0 else int(items[0].get("season", 0))
	var now_season: int = _abs_season(eff_year, eff_season, extras)
	var cap: int = int(_gd.budgets().get("pacing", {}).get("player_events_per_season_max", 2))

	if _EventStore.season_events_count(_db, now_season) >= cap:
		# Cap full: drop hook & pulse items; leave follow-ups in event_followups to wait next season (Rule 10, AC-EV-12).
		_EventStore.set_queue(_db, [])
		return {}

	while not items.is_empty():
		var entry: Dictionary = items.pop_front()
		_EventStore.set_queue(_db, items)
		var ey: int = int(entry.get("year", eff_year))
		var es: int = int(entry.get("season", eff_season))
		var ens: int = _abs_season(ey, es, extras)
		var merged_ex: Dictionary = Dictionary(entry.get("extras", entry.get("payload", {}))).merged(extras, true)
		var kind: String = str(entry.get("kind", ""))
		match kind:
			"followup":
				var fid: String = str(entry.get("followup_id", ""))
				var fu: Dictionary = _EventStore.get_followup(_db, fid)
				if fu.is_empty():
					continue
				var ev: Dictionary = _materialize_followup(fu, player, sheet, rng, ey, es, ens, merged_ex)
				if not ev.is_empty():
					_EventStore.remove_followup(_db, fid)
					return ev
			"story":
				var sinst: String = str(entry.get("story_instance_id", ""))
				var srec: Dictionary = _EventStore.get_story(_db, sinst)
				if srec.is_empty() or str(srec.get("status", "")) != "active":
					continue
				var ev_st: Dictionary = _materialize_story_stage(srec, str(entry.get("event_id", "")), player, sheet, rng, ey, es, ens, merged_ex)
				if not ev_st.is_empty():
					srec["stage_fired"] = str(srec.get("stage", ""))
					_EventStore.put_story(_db, srec)
					return ev_st
			"hook":
				var hres: Dictionary = _fire_hook_now(str(entry.get("hook_id", "")), player, sheet, rng, ey, es, ens, merged_ex)
				if bool(hres.get("ok", false)) and not Dictionary(hres.get("event", {})).is_empty():
					return Dictionary(hres.event)
			"pulse":
				var pres: Dictionary = _draw_pulse_now(player, sheet, rng, ey, es, ens, merged_ex)
				if bool(pres.get("ok", false)) and not Dictionary(pres.get("event", {})).is_empty():
					return Dictionary(pres.event)
	return {}


## Clears unpopped hook/pulse queue entries at season end (waiting follow-ups remain in [code]event_followups[/code]).
func end_of_season_cleanup(_year: int, _season: int) -> void:
	_EventStore.set_queue(_db, [])


## Resolves [param event] choice [param choice_index] under the non-nesting [member busy] guard,
## logs the Rule 22 [code]log[/code] line to WorldDB, closes any end-stage story on completion,
## and queues [code]on_fight_end[/code] after combat without nesting (AC-EV-18, AC-EV-40, AC-EV-43).
func resolve_event(
	c: Character,
	sheet: StatSheet,
	rng: RandomNumberGenerator,
	event: Dictionary,
	choice_index: int,
	year: int,
	season: int,
	opts: Dictionary = {}
) -> Dictionary:
	busy = true
	var merged_opts: Dictionary = opts.duplicate()
	merged_opts["year"] = year
	merged_opts["season"] = season
	merged_opts["story_start_fn"] = _cb_start_story
	merged_opts["story_stage_fn"] = _cb_advance_story
	merged_opts["story_end_fn"] = _cb_end_story
	var res: Dictionary = _resolver.resolve(c, sheet, rng, event, choice_index, merged_opts)

	# Write Rule 22 WorldDB log line (AC-EV-40)
	var people: Array = [c.id]
	if str(event.get("npc_id", "")) != "":
		people.append(str(event.npc_id))
	var places: Array = [str(event.get("place_id", c.location_id))] if str(event.get("place_id", c.location_id)) != "" else []
	var log_line: String = str(event.get("log", "")).strip_edges()
	if log_line == "":
		log_line = "%s — %s: %s" % [str(event.get("title", "")), str(event.choices[choice_index].label), "thành công" if bool(res.success) else "thất bại"]
	var log_id: String = _db.log_event(year, season, "story", log_line, people, places, Array(res.get("items", [])), {
		"template_id": str(event.get("template_id", "")),
		"source": str(event.get("source", "")),
		"effects": res.lines,
		"success": bool(res.success),
		"paid": int(res.get("paid", 0)),
	})
	res["event_log_id"] = log_id

	# Auto-close story if an end stage just finished without an explicit story_end effect (AC-EV-18)
	var sinst: String = str(event.get("story_instance_id", ""))
	if sinst != "":
		var srec: Dictionary = _EventStore.get_story(_db, sinst)
		if not srec.is_empty() and str(srec.get("status", "")) == "active" and not bool(srec.get("is_quest", false)):
			var st_def: Dictionary = _templates.get_story(str(srec.get("story_id", "")))
			var stg: Dictionary = _stage_def(st_def, str(event.get("story_stage", srec.get("stage", ""))))
			var end_st: String = str(stg.get("end", ""))
			if end_st != "":
				end_story(sinst, end_st, year, season, true)

	# Raise on_fight_end hook while busy == true so it queues cleanly after resolution (AC-EV-43)
	var chk: Dictionary = Dictionary(event.choices[choice_index].get("check", {}))
	if str(chk.get("type", "")) == "combat" and bool(opts.get("emit_fight_end_hook", false)):
		raise_hook("on_fight_end", c, sheet, rng, {"year": year, "season": season, "other_id": str(chk.get("enemy", "")), "won": bool(res.success)})

	busy = false
	return res


# --- Rule 12: Stories & Root Death Cleanup (AC-EV-18, 19, 44; Quests Rule 19) --------------------

## Starts a new story instance for [param root_id] (or a Quest story bridge when [param is_quest] == true).
## Enforces [code]stories_active_max[/code] for non-quest stories and priority displacement (AC-EV-19).
func start_story(
	story_id: String,
	root_id: String,
	scopes: Dictionary,
	year: int,
	season: int,
	is_quest: bool = false,
	quest_b: int = -1,
	c_opt: Character = null,
	sheet_opt: StatSheet = null
) -> Dictionary:
	var st_def: Dictionary = {} if is_quest else _templates.get_story(story_id)
	if not is_quest and st_def.is_empty():
		var w_u: String = "unknown story '%s'" % story_id
		last_warnings.append(w_u)
		return {"ok": false, "reason": "unknown_story", "warning": w_u}
	if not is_quest and bool(st_def.get("once_per_world", false)) and _EventStore.has_world_story_started(_db, story_id):
		var w_o: String = "story '%s' already started in this world" % story_id
		last_warnings.append(w_o)
		return {"ok": false, "reason": "once_per_world", "warning": w_o}

	var root_rec: Dictionary = _db.get_record("people", root_id)
	var is_player: bool = bool(root_rec.get("is_player", c_opt != null))
	var pacing_cfg: Dictionary = _gd.budgets().get("pacing", {})
	var max_st: int = int(pacing_cfg.get("stories_active_max_player", 3)) if is_player else int(pacing_cfg.get("stories_active_max_npc", 1))

	if not is_quest:
		var active: Array = _EventStore.active_stories(_db, root_id, false)
		if active.size() >= max_st:
			if not bool(st_def.get("priority", false)):
				var w_cap: String = "story '%s' refused: active story cap (%d) reached" % [story_id, max_st]
				last_warnings.append(w_cap)
				return {"ok": false, "reason": "story_cap_full", "warning": w_cap}
			var displaced: bool = false
			for old_st in active:
				if not bool(old_st.get("priority", false)):
					end_story(str(old_st.id), "timed_out", year, season, true)
					displaced = true
					break
			if not displaced:
				var w_pr: String = "priority story '%s' refused: all active stories are priority" % story_id
				last_warnings.append(w_pr)
				return {"ok": false, "reason": "all_priority", "warning": w_pr}

	var ch: Character = c_opt if c_opt != null else (Character.from_dict(root_rec) if not root_rec.is_empty() else Character.new())
	if ch.id == "":
		ch.id = root_id
	var mult: float = float(st_def.get("budget_mult", 1.5)) if not is_quest else 1.0
	var imax: int = int(st_def.get("items_max", 2)) if not is_quest else 4
	var chain_id: String = _EventBudget.create_chain(_db, _gd, ch, sheet_opt, mult, imax, quest_b if is_quest else -1)

	var resolved_scopes: Dictionary = _resolve_story_scopes(st_def, scopes, root_rec)
	var stages: Array = Array(st_def.get("stages", []))
	var first_stage: String = str(stages[0].get("id", "")) if not stages.is_empty() else "stage_0"
	var init_vars := {}
	for vk in Dictionary(st_def.get("variables", {})):
		var vd: Dictionary = Dictionary(st_def.variables[vk])
		init_vars[str(vk)] = int(vd.get("init", 0))

	var spy: int = int(_gd.cultivation_rules().get("seasons_per_year", 4))
	var abs_s: int = year * spy + season
	var rec := {
		"story_id": story_id,
		"name": str(st_def.get("name", scopes.get("name", story_id))),
		"root_id": root_id,
		"status": "active",
		"is_quest": is_quest,
		"priority": bool(st_def.get("priority", false)),
		"stage": first_stage,
		"stage_fired": "",
		"started_season": abs_s,
		"timeout_seasons": int(st_def.get("timeout_seasons", 24)) if not is_quest else 0,
		"chain_id": chain_id,
		"scopes": resolved_scopes,
		"variables": init_vars,
	}
	var inst_id: String = _EventStore.add_story(_db, rec)
	for vk in init_vars:
		var vd: Dictionary = Dictionary(st_def.variables[vk])
		_EventStore.set_var(_db, inst_id, str(vk), int(init_vars[vk]), int(vd.get("min", -2147483648)), int(vd.get("max", 2147483647)))
	return {"ok": true, "story": rec}


## Moves active story [param story_instance_id] to [param next_stage] (Rule 12, AC-EV-18).
func advance_story(story_instance_id: String, next_stage: String, _year: int, _season: int) -> Dictionary:
	var rec: Dictionary = _EventStore.get_story(_db, story_instance_id)
	if rec.is_empty() or str(rec.get("status", "")) != "active":
		return {"ok": false, "story": rec}
	rec["stage"] = next_stage
	rec["stage_fired"] = ""
	_EventStore.put_story(_db, rec)
	return {"ok": true, "story": rec}


## Ends story [param story_instance_id] with [param status] ([code]"done"[/code], [code]"failed"[/code],
## or [code]"timed_out"[/code]). Writes one WorldDB record when [param write_log] is true (AC-EV-18, AC-QS-152).
func end_story(story_instance_id: String, status: String, year: int, season: int, write_log: bool = true) -> Dictionary:
	var rec: Dictionary = _EventStore.get_story(_db, story_instance_id)
	if rec.is_empty():
		return {"ok": false, "story": {}, "event_id": ""}
	var spy: int = int(_gd.cultivation_rules().get("seasons_per_year", 4))
	rec["status"] = status
	rec["ended_season"] = year * spy + season
	_EventStore.put_story(_db, rec)
	var log_id: String = ""
	if write_log:
		var st_def: Dictionary = _templates.get_story(str(rec.get("story_id", "")))
		var lk: String = "log_done" if status == "done" else ("log_timeout" if status == "timed_out" else "log_failed")
		var raw_log: String = str(st_def.get(lk, "Câu chuyện '%s' kết thúc (%s)." % [str(rec.get("name", "")), status]))
		var root_rec: Dictionary = _db.get_record("people", str(rec.get("root_id", "")))
		var rendered: String = _EventConditions.render_text(raw_log, {
			"player": str(root_rec.get("name", "")),
			"root": str(root_rec.get("name", "")),
			"story_name": str(rec.get("name", "")),
		})
		var people: Array = [str(rec.get("root_id", ""))] if str(rec.get("root_id", "")) != "" else []
		log_id = _db.log_event(year, season, "story_end", rendered, people, [], [], {
			"story_id": str(rec.get("story_id", "")),
			"story_instance_id": story_instance_id,
			"status": status,
		})
	return {"ok": true, "story": rec, "event_id": log_id}


## Handles death of [param dead_id] (Edge Cases, AC-EV-44):
## drops all follow-ups rooted on [param dead_id] (keeping other roots' follow-ups intact),
## ends all active non-quest stories rooted on [param dead_id] as [code]"failed"[/code] with WorldDB records,
## and checks other active stories requiring [param dead_id] as a living scope.
func on_root_death(dead_id: String, year: int, season: int) -> Array:
	var logged: Array = []
	if dead_id == "":
		return logged
	for fu in _EventStore.followups_for(_db, dead_id):
		_EventStore.remove_followup(_db, str(fu.id))
	for srec in _EventStore.active_stories(_db, dead_id, false):
		var eres: Dictionary = end_story(str(srec.id), "failed", year, season, true)
		if str(eres.get("event_id", "")) != "":
			logged.append(str(eres.event_id))
	# Check stories of OTHER living roots that require dead_id alive
	for srec in _EventStore.active_stories(_db, "", false):
		if str(srec.get("root_id", "")) == dead_id:
			continue
		var st_def: Dictionary = _templates.get_story(str(srec.get("story_id", "")))
		var s_scopes: Dictionary = Dictionary(srec.get("scopes", {}))
		for req_sc in Array(st_def.get("required_living_scopes", [])):
			if str(s_scopes.get(str(req_sc), "")) == dead_id:
				var death_stage: String = str(Dictionary(st_def.get("on_scope_death", {})).get(str(req_sc), ""))
				if death_stage != "":
					advance_story(str(srec.id), death_stage, year, season)
				else:
					var eres2: Dictionary = end_story(str(srec.id), "failed", year, season, true)
					if str(eres2.get("event_id", "")) != "":
						logged.append(str(eres2.event_id))
				break
	return logged


# --- Hidden Chronicle Uncovering (World Generation Rule 3a, AC-WG-56) ----------------------------

## Uncovers hidden chronicle entry [param chronicle_id] in [param db] (idempotent, AC-WG-56).
## Returns [code]{ok: bool, changed: bool, event_id: String, text: String}[/code].
static func uncover_chronicle(db: WorldDB, chronicle_id: String) -> Dictionary:
	return _EventResolver.uncover_chronicle_in_db(db, chronicle_id)


## True when a chronicle/event record is currently hidden/secret and must be excluded from public readers.
static func is_hidden_chronicle(event_rec: Dictionary) -> bool:
	return str(event_rec.get("type", "")) == "hidden" or bool(Dictionary(event_rec.get("data", {})).get("secret", false))


## True when an NPC event record should reach the player's news (Rule 20, AC-EV-36).
static func is_news_for_player(db: WorldDB, event_rec: Dictionary, player_id: String) -> bool:
	if is_hidden_chronicle(event_rec):
		return false
	var data: Dictionary = Dictionary(event_rec.get("data", {}))
	if bool(data.get("newsworthy", false)):
		return true
	var pl: Dictionary = db.get_record("people", player_id) if (db != null and player_id != "") else {}
	var met_list: Array = Array(pl.get("met_list", []))
	for pid_v in Array(event_rec.get("people", [])):
		var pid: String = str(pid_v)
		if pid == "" or pid == player_id:
			continue
		if met_list.has(pid):
			return true
		var rec: Dictionary = db.get_record("people", pid)
		if bool(rec.get("met_player", false)) or int(rec.get("attitude", 0)) != 0:
			return true
	return false


# --- Rules 19-20 & Formulas D: Off-Screen NPC Event Step (AC-EV-11, 34, 35, 36, 37) --------------

## Runs one seasonal off-screen NPC event step (Rules 19-20, Formulas D).
## Selects all living fixed-cast people, all player-known people (deduped), and a keyed sample
## of [code]npc_sample_per_season[/code] (200) other living cultivators, rolls [code]p_npc0[/code] (0.10)
## per candidate on keyed streams (order-invariant, AC-EV-11), caps at [code]npc_events_per_season_max[/code]
## (40, AC-EV-34), and returns the WorldDB event ids that reach the player's news (AC-EV-36).
func run_npc_season(_rng: RandomNumberGenerator, year: int, season: int, game_seed: int, player_id: String = "") -> Array:
	var news: Array = []
	var npc_cfg: Dictionary = _gd.budgets().get("npc_events", {})
	var p_npc0: float = float(npc_cfg.get("p_npc0", 0.10))
	var sample_n: int = int(npc_cfg.get("npc_sample_per_season", 200))
	var cap_n: int = int(npc_cfg.get("npc_events_per_season_max", 40))
	var spy: int = int(_gd.cultivation_rules().get("seasons_per_year", 4))
	var abs_season: int = year * spy + season

	var pool_templates: Array = _templates.npc_capable_templates()
	if pool_templates.is_empty() or cap_n <= 0:
		return news

	var candidates: Array = select_npc_candidates(game_seed, abs_season, sample_n, player_id)
	var fired: int = 0
	for npc_rec in candidates:
		if fired >= cap_n:
			break
		var pid: String = str(npc_rec.id)
		var r_pulse := RandomNumberGenerator.new()
		r_pulse.seed = RngUtils.stable_hash("npc_pulse:%d:%s:%d" % [game_seed, pid, abs_season])
		if r_pulse.randf() >= p_npc0:
			continue
		var ev_res: Dictionary = _run_single_npc_event(npc_rec, pool_templates, year, season, abs_season, game_seed, player_id)
		if bool(ev_res.get("ok", false)):
			fired += 1
			if bool(ev_res.get("reaches_news", false)) and str(ev_res.get("event_log_id", "")) != "":
				news.append(str(ev_res.event_log_id))
	last_npc_fired = fired
	return news


## Deterministically selects the season's NPC event candidates:
## living fixed cast + living player-known (deduped) + keyed sample of [param sample_n] others,
## sorted canonically by person id so visitation order never affects outcomes (AC-EV-11, AC-EV-34).
func select_npc_candidates(game_seed: int, abs_season: int, sample_n: int, player_id: String = "") -> Array:
	var pl_rec: Dictionary = _db.get_record("people", player_id) if player_id != "" else {}
	var met_set := {}
	for mid in Array(pl_rec.get("met_list", [])):
		met_set[str(mid)] = true

	var must_check: Dictionary = {}
	var others: Array = []
	for p in _db.living():
		if not bool(p.get("alive", false)) or bool(p.get("is_player", false)) or bool(p.get("is_beast", false)):
			continue
		var pid: String = str(p.id)
		var is_cast: bool = str(p.get("cast_key", "")) != ""
		var is_known: bool = met_set.has(pid) or bool(p.get("met_player", false)) or int(p.get("attitude", 0)) != 0
		if is_cast or is_known:
			must_check[pid] = p
		else:
			others.append(p)

	others.sort_custom(func(a, b): return str(a.id) < str(b.id))
	var chosen: Array = must_check.values()
	if sample_n > 0 and not others.is_empty():
		var take: int = mini(sample_n, others.size())
		if take == others.size():
			chosen.append_array(others)
		else:
			var r_s := RandomNumberGenerator.new()
			r_s.seed = RngUtils.stable_hash("npc_sample:%d:%d" % [game_seed, abs_season])
			var idxs: Array = range(others.size())
			for i in take:
				var j: int = r_s.randi_range(i, idxs.size() - 1)
				var tmp: int = int(idxs[i])
				idxs[i] = idxs[j]
				idxs[j] = tmp
				chosen.append(others[int(idxs[i])])

	chosen.sort_custom(func(a, b): return str(a.id) < str(b.id))
	return chosen


# --- Internal Helpers ----------------------------------------------------------------------------

func _draw_pulse_now(c: Character, sheet: StatSheet, rng: RandomNumberGenerator, year: int, season: int, now_season: int, extras: Dictionary) -> Dictionary:
	var ctx: Dictionary = _build_ctx(c, sheet, year, season, extras)
	var env: Dictionary = _templates.env_from_ctx(ctx)
	var ptype: String = str(Dictionary(ctx.get("place", {})).get("type", ""))
	var pkind: String = _EventConditions.place_kind_of(env.place, _gd)
	var pool: Array = _templates.pulse_templates(true).filter(func(t):
		if not _EventStore.can_fire_pacing(_db, _gd, t, c.id, now_season, true):
			return false
		return _templates.is_template_eligible(t, ctx, env, ptype, pkind))
	if pool.is_empty():
		last_warnings.append("pulse pool empty at %s" % str(ctx.place.id))
		return {"ok": false, "rolled": true, "hit": true, "empty_pool": true, "event": {}, "warnings": last_warnings}

	var raw_ev: Dictionary = _pick_and_fill_from_pool(pool, ctx, env, rng, str(extras.get("bound_npc_id", "")))
	if raw_ev.is_empty():
		last_warnings.append("pulse pool exhausted after scope/show_conditions binding")
		return {"ok": false, "rolled": true, "hit": true, "empty_pool": true, "event": {}, "warnings": last_warnings}

	var norm: Dictionary = _validator.normalize(raw_ev, ctx, rng, str(raw_ev.source), {"env": env})
	if not bool(norm.ok):
		last_warnings.append("pulse event rejected: %s" % str(norm.error))
		return {"ok": false, "rolled": true, "hit": true, "event": {}, "warnings": last_warnings}

	var ev: Dictionary = norm.event
	# Capability #20: hostile event may pass the player by without consuming pacing cap or cooldown (Edge Cases).
	if bool(extras.get("check_cap20", true)) and c.has_capability(20):
		if Array(ev.choices).any(func(ch): return str(ch.check.type) == "combat"):
			if rng.randf() >= float(_gd.capability(20).params.hostile_mult):
				return {"ok": false, "rolled": true, "hit": true, "passed_by": true, "event": {}, "warnings": []}

	_mark_player_event_fired(ev, c.id, now_season)
	return {"ok": true, "rolled": true, "hit": true, "event": ev, "warnings": norm.warnings, "source": ev.source}


func _fire_hook_now(hook_id: String, root: Character, sheet: StatSheet, rng: RandomNumberGenerator, year: int, season: int, now_season: int, payload: Dictionary) -> Dictionary:
	var cap: int = int(_gd.budgets().get("pacing", {}).get("player_events_per_season_max", 2))
	if _EventStore.season_events_count(_db, now_season) >= cap:
		return {"ok": false, "skipped": "season_cap", "event": {}, "warnings": []}

	var hcfg: Dictionary = _templates.hook_config(hook_id)
	var chance: float = float(payload.get("chance_override", hcfg.get("chance", 1.0)))
	if chance < 1.0 and rng.randf() >= chance:
		return {"ok": false, "missed": true, "event": {}, "warnings": []}

	var ctx: Dictionary = _build_ctx(root, sheet, year, season, payload)
	var bound_other_id: String = str(payload.get("other_id", payload.get("npc_id", "")))
	var bound_other: Dictionary = _db.get_record("people", bound_other_id) if bound_other_id != "" else {}
	var env: Dictionary = _templates.env_from_ctx(ctx, bound_other)
	var ptype: String = str(Dictionary(ctx.get("place", {})).get("type", ""))
	var pkind: String = _EventConditions.place_kind_of(env.place, _gd)
	var forced_tid: String = str(payload.get("template_id", ""))
	var sr_phase: String = str(payload.get("secret_realm_phase", ""))
	var sr_name: String = str(payload.get("secret_realm_name", ""))
	var sr_slot: String = str(payload.get("secret_realm_slot", ""))

	var pool: Array = _templates.hook_templates(hook_id, true).filter(func(t):
		if forced_tid != "" and str(t.get("id", "")) != forced_tid:
			return false
		if sr_phase != "" and str(t.get("secret_realm_phase", "")) != sr_phase:
			return false
		if sr_name != "" and str(t.get("secret_realm_name", "")) != "" and str(t.get("secret_realm_name", "")) != sr_name:
			return false
		if sr_slot != "" and str(t.get("secret_realm_slot", "")) != "" and str(t.get("secret_realm_slot", "")) != sr_slot:
			return false
		if not _EventStore.can_fire_pacing(_db, _gd, t, root.id, now_season, true):
			return false
		return _templates.is_template_eligible(t, ctx, env, ptype, pkind))

	if pool.is_empty():
		var msg: String = "hook '%s' pool empty" % hook_id
		if hook_id == "on_travel_stretch":
			msg = "content warning: no on_travel_stretch event fits biome '%s' mode '%s'" % [str(env.biome), str(env.travel_mode)]
		last_warnings.append(msg)
		return {"ok": false, "empty_pool": true, "event": {}, "warnings": last_warnings}

	var raw_ev: Dictionary = _pick_and_fill_from_pool(pool, ctx, env, rng, bound_other_id)
	if raw_ev.is_empty():
		return {"ok": false, "empty_pool": true, "event": {}, "warnings": last_warnings}

	var norm: Dictionary = _validator.normalize(raw_ev, ctx, rng, str(raw_ev.source), {"env": env})
	if not bool(norm.ok):
		last_warnings.append("hook event rejected: %s" % str(norm.error))
		return {"ok": false, "event": {}, "warnings": last_warnings}

	_mark_player_event_fired(norm.event, root.id, now_season)
	return {"ok": true, "fired": true, "event": norm.event, "warnings": norm.warnings, "source": norm.event.source}


func _check_hook_followups(hook_id: String, root: Character, _ctx: Dictionary, env: Dictionary, now_season: int, year: int, season: int) -> Dictionary:
	var first_queued: Dictionary = {}
	for fu in _EventStore.followups_for(_db, root.id):
		if str(fu.get("hook", "")) != hook_id:
			continue
		var req_pl: String = str(fu.get("hook_place_id", ""))
		if req_pl != "" and req_pl != root.location_id:
			continue
		var t: Dictionary = _templates.get_template(str(fu.get("event_id", "")))
		if t.is_empty():
			continue
		var cond: Dictionary = Dictionary(t.get("conditions", {}))
		if not cond.is_empty() and not _EventConditions.evaluate(cond, env, _gd, _db):
			continue
		var q_item := {
			"priority": PRIO_FOLLOWUP,
			"kind": "followup",
			"followup_id": str(fu.id),
			"event_id": str(fu.get("event_id", "")),
			"scheduled_at": int(fu.get("scheduled_at", now_season)),
			"year": year,
			"season": season,
		}
		_enqueue_item(q_item)
		if first_queued.is_empty():
			first_queued = q_item
	return first_queued


func _materialize_followup(fu: Dictionary, player: Character, sheet: StatSheet, rng: RandomNumberGenerator, year: int, season: int, now_season: int, extras: Dictionary) -> Dictionary:
	var t: Dictionary = _templates.get_template(str(fu.get("event_id", "")))
	if t.is_empty():
		return {}
	var ex: Dictionary = extras.duplicate(true)
	ex["chain_id"] = str(fu.get("chain_id", ""))
	ex["followup_of"] = str(fu.get("followup_of", ""))
	var other_id: String = str(Dictionary(fu.get("scopes", {})).get("other", ""))
	var ctx: Dictionary = _build_ctx(player, sheet, year, season, ex)
	ctx["chain_id"] = str(fu.get("chain_id", ""))
	ctx["followup_of"] = str(fu.get("followup_of", ""))
	var npc_id: String = other_id
	if npc_id == "":
		npc_id = _templates.bind_other_scope(t, ctx, rng, "")
		if npc_id == "!":
			return {}
	var other_rec: Dictionary = _db.get_record("people", npc_id) if npc_id != "" else {}
	var env: Dictionary = _templates.env_from_ctx(ctx, other_rec)
	var raw_ev: Dictionary = _templates.fill_template(t, ctx, npc_id, rng)
	if raw_ev.is_empty():
		return {}
	raw_ev["chain_id"] = str(fu.get("chain_id", ""))
	raw_ev["followup_of"] = str(fu.get("followup_of", ""))
	raw_ev["story_instance_id"] = str(fu.get("story_instance_id", ""))
	var norm: Dictionary = _validator.normalize(raw_ev, ctx, rng, str(raw_ev.source), {"chain_id": str(fu.get("chain_id", "")), "env": env})
	if not bool(norm.ok):
		return {}
	_mark_player_event_fired(norm.event, player.id, now_season)
	return norm.event


func _materialize_story_stage(srec: Dictionary, event_id: String, player: Character, sheet: StatSheet, rng: RandomNumberGenerator, year: int, season: int, now_season: int, extras: Dictionary) -> Dictionary:
	var t: Dictionary = _templates.get_template(event_id)
	if t.is_empty():
		return {}
	var ctx: Dictionary = _build_ctx(player, sheet, year, season, extras)
	var scopes: Dictionary = Dictionary(srec.get("scopes", {}))
	var npc_id: String = str(scopes.get("other", ""))
	if npc_id == "":
		npc_id = _templates.bind_other_scope(t, ctx, rng, "")
		if npc_id == "!":
			return {}
	var other_rec: Dictionary = _db.get_record("people", npc_id) if npc_id != "" else {}
	var env: Dictionary = _templates.env_from_ctx(ctx, other_rec, srec)
	var raw_ev: Dictionary = _templates.fill_template(t, ctx, npc_id, rng, {}, srec)
	if raw_ev.is_empty():
		return {}
	var norm: Dictionary = _validator.normalize(raw_ev, ctx, rng, str(raw_ev.source), {"chain_id": str(srec.get("chain_id", "")), "env": env})
	if not bool(norm.ok):
		return {}
	_mark_player_event_fired(norm.event, player.id, now_season)
	return norm.event


func _pick_and_fill_from_pool(pool: Array, ctx: Dictionary, env: Dictionary, rng: RandomNumberGenerator, bound_npc_id: String) -> Dictionary:
	var work: Array = pool.duplicate()
	var tries: int = mini(maxi(work.size(), 1), 16)
	for _i in tries:
		if work.is_empty():
			return {}
		var weighted: Array = []
		for t in work:
			var w: float = _EventConditions.effective_weight(t, env, _gd, _db)
			if w > 0.0:
				weighted.append({"rec": t, "weight": w})
		if weighted.is_empty():
			return {}
		var chosen: Dictionary = RngUtils.weighted_pick(rng, weighted).rec
		var npc_id: String = _templates.bind_other_scope(chosen, ctx, rng, bound_npc_id)
		if npc_id == "!":
			work.erase(chosen)
			continue
		var filled: Dictionary = _templates.fill_template(chosen, ctx, npc_id, rng)
		if filled.is_empty():
			work.erase(chosen)
			continue
		return filled
	return {}


func _run_single_npc_event(npc_rec: Dictionary, pool_templates: Array, year: int, season: int, abs_season: int, game_seed: int, player_id: String) -> Dictionary:
	var pid: String = str(npc_rec.id)
	var place_id: String = str(npc_rec.get("location_id", ""))
	var place: Dictionary = _db.get_record("places", place_id) if place_id != "" else {}
	var sect_id: String = str(npc_rec.get("sect_id", ""))
	var sect: Dictionary = _db.get_record("sects", sect_id) if sect_id != "" else {}
	var realm_idx: int = int(npc_rec.get("realm_index", 0))
	var rb: Dictionary = _gd.realm_budget(realm_idx).duplicate()
	var kv: float = float(Dictionary(npc_rec.get("thien_phu", {})).get("khi_van", 50.0))
	var c_kv: float = _EventBudget.fortune_multiplier(_gd, kv)
	rb["ceiling"] = c_kv
	rb["linh_thach_max"] = int(float(rb.get("linh_thach_max", 80)) * c_kv)
	rb["tu_vi_max"] = int(float(rb.get("tu_vi_pct_max", 0.5)) * c_kv * 100.0)
	var ctx := {
		"year": year,
		"season": season,
		"now_season": abs_season,
		"language": "vi",
		"edge": false,
		"co_duyen_left": 0,
		"player": {
			"id": pid,
			"name": str(npc_rec.get("name", pid)),
			"realm": _gd.realm_label(realm_idx, int(npc_rec.get("stage", 0))),
			"realm_index": realm_idx,
			"at_bottleneck": false,
			"tam_ma": float(npc_rec.get("tam_ma", 0.0)),
			"linh_thach": float(npc_rec.get("linh_thach", 0.0)),
		},
		"place": {
			"id": place_id,
			"name": str(place.get("name", "")),
			"type": str(place.get("type", "")),
			"danger": int(place.get("danger", 1)),
			"region": str(_db.get_record("regions", str(place.get("region_id", ""))).get("name", "")),
		},
		"sect": {
			"id": sect_id,
			"name": str(sect.get("name", "")),
			"alignment": str(sect.get("alignment", "")),
		},
		"budget": rb,
	}
	var env: Dictionary = _templates.env_from_ctx(ctx)
	var ptype: String = str(ctx.place.type)
	var pkind: String = _EventConditions.place_kind_of(env.place, _gd)
	var eligible: Array = pool_templates.filter(func(t):
		if not _EventStore.can_fire_pacing(_db, _gd, t, pid, abs_season, false):
			return false
		return _templates.is_template_eligible(t, ctx, env, ptype, pkind))
	if eligible.is_empty():
		return {"ok": false}
	var r_pick := RandomNumberGenerator.new()
	r_pick.seed = RngUtils.stable_hash("npc_pick:%d:%s:%d" % [game_seed, pid, abs_season])
	var raw_ev: Dictionary = _pick_and_fill_from_pool(eligible, ctx, env, r_pick, "")
	if raw_ev.is_empty():
		return {"ok": false}
	var norm: Dictionary = _validator.normalize(raw_ev, ctx, r_pick, str(raw_ev.source), {"env": env, "npc_mode": true})
	if not bool(norm.ok):
		return {"ok": false}
	var ev: Dictionary = norm.event
	_EventStore.mark_fired(_db, str(ev.get("template_id", "")), pid, abs_season, bool(ev.get("once_per_life", false)), bool(ev.get("once_per_world", false)))
	return _resolver.resolve_npc(npc_rec, ev, year, season, game_seed, ratings, player_id)


func _build_ctx(c: Character, sheet: StatSheet, year: int, season: int, extras: Dictionary) -> Dictionary:
	var ctx: Dictionary = EventContext.build(c, _gd, _db, sheet, year, season, "vi", extras)
	if extras.has("biome"):
		ctx["biome"] = str(extras.biome)
	if extras.has("travel_mode"):
		ctx["travel_mode"] = str(extras.travel_mode)
	if extras.has("bound_npc_id"):
		ctx["bound_npc_id"] = str(extras.bound_npc_id)
	return ctx


func _mark_player_event_fired(ev: Dictionary, root_id: String, now_season: int) -> void:
	var tid: String = str(ev.get("template_id", ""))
	if tid != "":
		_EventStore.mark_fired(_db, tid, root_id, now_season, bool(ev.get("once_per_life", false)), bool(ev.get("once_per_world", false)))
	_EventStore.increment_season_events(_db, now_season)


func _resolve_story_scopes(st_def: Dictionary, overrides: Dictionary, root_rec: Dictionary) -> Dictionary:
	var out: Dictionary = overrides.duplicate(true)
	var def_scopes: Dictionary = Dictionary(st_def.get("scopes", {}))
	for sk in def_scopes:
		if out.has(str(sk)):
			continue
		var spec: Variant = def_scopes[sk]
		if not (spec is Dictionary):
			out[str(sk)] = str(spec)
			continue
		var sd: Dictionary = spec as Dictionary
		var mode: String = str(sd.get("mode", ""))
		match mode:
			"cast_key":
				var ck: String = str(sd.get("key", ""))
				for p in _db.all("people"):
					if str(p.get("cast_key", "")) == ck:
						out[str(sk)] = str(p.id)
						break
			"named_key":
				var skey: String = str(sd.get("key", ""))
				for s in _db.all("sects"):
					if str(s.get("key", "")) == skey:
						out[str(sk)] = str(s.id)
						break
			"named_continent_id":
				var cid: int = int(sd.get("id", -1))
				for pl in _db.all("places"):
					if int(pl.get("continent_id", -999)) == cid:
						out[str(sk)] = str(pl.id)
						break
			"current":
				out[str(sk)] = str(root_rec.get("location_id", ""))
			"root_sect":
				out[str(sk)] = str(root_rec.get("sect_id", ""))
	return out


static func _stage_def(st_def: Dictionary, stage_id: String) -> Dictionary:
	for stg in Array(st_def.get("stages", [])):
		if stg is Dictionary and str((stg as Dictionary).get("id", "")) == stage_id:
			return stg as Dictionary
	return {}


func _enqueue_item(item: Dictionary) -> void:
	var q: Array = _EventStore.get_queue(_db)
	# Avoid duplicating identical followup, story stage, or hook entry already queued
	var f_id: String = str(item.get("followup_id", ""))
	var st_id: String = str(item.get("story_instance_id", ""))
	var kind: String = str(item.get("kind", ""))
	for ex in q:
		if f_id != "" and str(ex.get("followup_id", "")) == f_id:
			return
		if st_id != "" and str(ex.get("story_instance_id", "")) == st_id and str(ex.get("event_id", "")) == str(item.get("event_id", "")):
			return
		if kind == "hook" and str(ex.get("kind", "")) == "hook":
			if str(ex.get("hook_id", "")) == str(item.get("hook_id", "")) and str(ex.get("event_id", "")) == str(item.get("event_id", "")):
				var p1: Dictionary = Dictionary(ex.get("payload", {}))
				var p2: Dictionary = Dictionary(item.get("payload", {}))
				if str(p1.get("secret_realm_phase", "")) == str(p2.get("secret_realm_phase", "")) and str(p1.get("secret_realm_id", "")) == str(p2.get("secret_realm_id", "")):
					return
	q.append(item)
	q.sort_custom(_queue_less)
	_EventStore.set_queue(_db, q)


static func _queue_less(a: Dictionary, b: Dictionary) -> bool:
	var pa: int = int(a.get("priority", 99))
	var pb: int = int(b.get("priority", 99))
	if pa != pb:
		return pa < pb
	var sa: int = int(a.get("scheduled_at", 0))
	var sb: int = int(b.get("scheduled_at", 0))
	if sa != sb:
		return sa < sb
	return str(a.get("event_id", "")) < str(b.get("event_id", ""))


func _abs_season(year: int, season: int, extras: Dictionary) -> int:
	if extras.has("now_season"):
		return int(extras.now_season)
	var spy: int = int(_gd.cultivation_rules().get("seasons_per_year", 4))
	return year * spy + season


static func _safe_extras(d: Dictionary) -> Dictionary:
	var out := {}
	for k in d:
		var v: Variant = d[k]
		if typeof(v) in [TYPE_BOOL, TYPE_INT, TYPE_FLOAT, TYPE_STRING, TYPE_ARRAY, TYPE_DICTIONARY]:
			out[str(k)] = v
	return out


func _cb_start_story(story_id: String, root_id: String, scopes: Dictionary, year: int, season: int, c: Character, sheet: StatSheet) -> Dictionary:
	return start_story(story_id, root_id, scopes, year, season, false, -1, c, sheet)


func _cb_advance_story(story_instance_id: String, next_stage: String, year: int, season: int) -> Dictionary:
	return advance_story(story_instance_id, next_stage, year, season)


func _cb_end_story(story_instance_id: String, status: String, year: int, season: int, write_log: bool) -> Dictionary:
	return end_story(story_instance_id, status, year, season, write_log)
