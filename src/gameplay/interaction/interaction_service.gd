class_name InteractionService
extends RefCounted
## Stateful orchestrator for NPC Interaction & Dialogue (#30) + all 19 Trait [code]verb:[/code] hooks.
## Executes all 17 base verbs and 19 trait verbs, enforces per-season caps, per-verb cooldowns,
## timed-verb focus tax, loans with strict [MoneyLedger] conservation, [Ties] bonds/obligations,
## non-lethal rated spars, [code]on_talk[/code] authored scenes, and non-LLM [DialogueVoice] replies.
##
## Holds no back-reference to [GameSession] (zero cyclic [RefCounted] references); [GameSession] is
## passed transiently to [method execute].
##
## Usage:
## [codeblock]
## var svc := InteractionService.new(gd, db, builds, items, market, sect_members, resolver, templates, validator, ratings)
## var menu: Array = svc.list_verbs(player, sheet, npc_id, season_now, year_now, 0.0, false, knowledge)
## var res: Dictionary = svc.execute(session, npc_id, "greet")
## [/codeblock]

## WorldDB [code]world[/code] table record id holding open/overdue/repaid loans.
const LOANS_REC := "w_loans"
## WorldDB [code]world[/code] table record id holding scheduled interaction follow-up events.
const FOLLOWUPS_REC := "w_followups"

var _gd: GameData
var _db: WorldDB
var _builds: BuildGenerator
var _items: ItemFactory
var _market: Market
var _sect_members: SectMembers
var _resolver: EventResolver
var _templates: EventTemplateSource
var _validator: EventValidator
var _ratings: RatingService
var _combat_service: CombatService


func _init(
	gd: GameData,
	db: WorldDB,
	builds: BuildGenerator,
	items: ItemFactory,
	market: Market,
	sect_members: SectMembers,
	resolver: EventResolver,
	templates: EventTemplateSource,
	validator: EventValidator,
	ratings: RatingService = null
) -> void:
	_gd = gd
	_db = db
	_builds = builds
	_items = items
	_market = market
	_sect_members = sect_members
	_resolver = resolver
	_templates = templates
	_validator = validator
	_ratings = ratings


# --- Read-Only Menu Query (ADR-0006 decision 1: never writes) ---------------------------------------------------------

## Returns the grouped, read-only list of verbs for [param npc_id] (never mutates [member _db], [param player],
## or RNG). Filters bond verbs out when [method Ties.enabled] is false (AC-NI-20) and trait verbs by
## [method NpcTraits.available_verbs].
func list_verbs(
	player: Character,
	player_sheet: StatSheet,
	npc_id: String,
	season_now: int,
	year_now: int,
	season_time_used: float,
	event_waiting: bool,
	knowledge: MapKnowledge = null
) -> Array:
	var npc: Dictionary = _db.get_record("people", npc_id)
	if npc.is_empty() or not bool(npc.get("alive", false)) or bool(npc.get("is_player", false)) or bool(npc.get("is_beast", false)):
		return []
	if str(npc.get("location_id", "")) != player.location_id:
		return []

	var k: Dictionary = InteractionRules.knobs(_gd)
	var max_per_season: int = int(k.get("interactions_per_person_per_season", 2))
	var meta: Dictionary = _peek_meta(npc, season_now, year_now)
	var season_count: int = int(meta.season_count)
	var player_rec: Dictionary = _player_dict(player)
	var avail_traits: Array = []
	if _gd.registry.has_file(NpcTraits.FILE):
		avail_traits = NpcTraits.available_verbs(_gd, player_rec, npc, InteractionRules.trait_verb_defs(_gd))

	var req_ctx := {
		"has_open_obligation": not open_obligations(player.id, npc_id, season_now).is_empty(),
		"has_known_other": not _known_others(player, npc_id).is_empty(),
	}
	var sect_st: float = _sect_standing(player, npc)
	var trait_cat: Dictionary = NpcTraits.catalogue(_gd).by_id if _gd.registry.has_file(NpcTraits.FILE) else {}
	var out: Array = []

	for raw_v in InteractionRules.verbs(_gd):
		if not (raw_v is Dictionary):
			continue
		var v: Dictionary = raw_v as Dictionary
		var vid: String = str(v.get("id", ""))
		var grp: String = str(v.get("group", "social"))
		var thook: String = str(v.get("trait_hook", ""))
		if thook != "" and not avail_traits.has(vid):
			continue
		if grp == "bond" and not Ties.enabled(_gd):
			continue

		var req: Dictionary = InteractionRules.check_requirements(_gd, _db, v, player, npc, req_ctx)
		var greyed: bool = false
		var grey_reason: String = ""
		if not bool(req.ok):
			if bool(v.get("show_greyed_on_req_fail", false)) and bool(npc.get("met_player", false)):
				greyed = true
				grey_reason = str(req.reason)
			else:
				continue

		var v_time: float = float(v.get("time", 0.0))
		var cd_until: int = int(Dictionary(meta.get("cooldowns", {})).get(vid, 0))
		var cd_left: int = maxi(0, cd_until - season_now)
		var extra_mods: Dictionary = _extra_score_mods(vid, player.id, npc)
		var sc: Dictionary = InteractionRules.acceptance_score(_gd, _db, v, player, player_sheet, npc, sect_st, extra_mods, "", season_now)
		var always_acc: bool = bool(v.get("always_accept", false))
		var will_acc: bool = true if always_acc else bool(sc.accept)
		var disabled: bool = greyed
		var disabled_reason: String = grey_reason

		if not disabled and not bool(v.get("bypass_season_limit", false)) and season_count >= max_per_season:
			disabled = true
			disabled_reason = "Season limit reached (%d/%d)." % [season_count, max_per_season]
		elif not disabled and cd_left > 0:
			disabled = true
			disabled_reason = "Cooldown: %d season(s)." % cd_left
		elif not disabled and vid == "teach" and int(meta.get("teach_year", -9999)) == year_now:
			disabled = true
			disabled_reason = "Already taught you this year."
		elif not disabled and v_time > 0.0 and event_waiting:
			disabled = true
			disabled_reason = "An event is waiting."
		elif not disabled and v_time > 0.0 and not InteractionRules.has_focus_time(season_time_used, v_time):
			disabled = true
			disabled_reason = "Not enough focus time left this season."

		var loan_max_v: int = InteractionRules.loan_cap(_gd, npc) if vid == "help" else 0
		var wager_max_v: int = InteractionRules.wager_cap(_gd, player, npc) if vid == "wager" else 0
		if vid == "wager" and wager_max_v <= 0:
			will_acc = false
		if vid == "trade" and InteractionRules.band_rank(InteractionRules.attitude_band(_gd, int(npc.get("attitude", 0)))) < InteractionRules.band_rank("neutral"):
			will_acc = false

		var f7: Dictionary = InteractionRules.f7_trait_conflict(_gd, player_rec, Array(v.get("tags", [])), player.heart_demon_used)
		var f7_warn: String = ""
		if int(f7.n_against) > 0 and float(f7.tam_ma_raw) > 0.0:
			f7_warn = "Against trait: +%.0f tâm ma" % float(f7.tam_ma_raw)

		var threat_p: float = -1.0
		if vid == "threaten":
			var q: float = _player_win_share(player, player_sheet, npc)
			threat_p = float(InteractionRules.threat_chance(_gd, q, npc).p)

		var src_trait: String = str(v.get("source_trait", ""))
		var src_tname: String = str(Dictionary(trait_cat.get(src_trait, {})).get("name", src_trait)) if src_trait != "" else ""

		out.append({
			"id": vid,
			"name": str(v.get("name", vid)),
			"name_vi": str(v.get("name_vi", vid)),
			"group": grp,
			"trait_hook": thook,
			"source_trait": src_trait,
			"source_trait_name": src_tname,
			"side": str(v.get("side", "")),
			"time": v_time,
			"cooldown_left": cd_left,
			"shown": true,
			"greyed": greyed,
			"grey_reason": grey_reason,
			"disabled": disabled,
			"disabled_reason": disabled_reason,
			"will_accept": will_acc,
			"always_accept": always_acc,
			"score": float(sc.score),
			"score_parts": sc.parts,
			"confirm": bool(v.get("confirm", false)),
			"param_kind": str(v.get("param_kind", "")),
			"f7_warning": f7_warn,
			"threat_chance": threat_p,
			"loan_max": loan_max_v,
			"wager_max": wager_max_v,
			"options": _verb_options(vid, player, player_sheet, npc, season_now, knowledge),
		})
	return out


## Returns the player's interaction count used this season with [param npc_id] (read-only).
func interactions_used_this_season(npc_id: String, season_now: int) -> int:
	var npc: Dictionary = _db.get_record("people", npc_id)
	if npc.is_empty():
		return 0
	return int(_peek_meta(npc, season_now, 0).season_count)


## Returns all open or overdue obligations the player owes [param npc_id] (loans, favours, gratitude debts).
func open_obligations(player_id: String, npc_id: String, season_now: int) -> Array:
	var out: Array = []
	for loan in loans_of(_db, player_id, npc_id):
		if str(loan.get("status", "")) in ["open", "overdue"]:
			out.append({
				"id": "loan:" + str(loan.id),
				"kind": "loan",
				"loan_id": str(loan.id),
				"amount": int(loan.amount),
				"due_season": int(loan.due_season),
				"status": str(loan.status),
				"label": "Repay loan (%d linh thạch%s)" % [int(loan.amount), ", OVERDUE" if str(loan.status) == "overdue" else ""],
			})
	if Ties.enabled(_gd):
		var rec: Dictionary = _db.tie_between(player_id, npc_id)
		if not rec.is_empty():
			if str(rec.get("favour", "")) == player_id:
				var npc: Dictionary = _db.get_record("people", npc_id)
				var fcost: int = Ties.favour_cost(_gd, int(npc.get("realm_index", 0)))
				out.append({
					"id": "favour",
					"kind": "favour",
					"amount": fcost,
					"label": "Clear sworn sibling favour (%d linh thạch)" % fcost,
				})
			var debt: Dictionary = Dictionary(rec.get("debt", {}))
			if not debt.is_empty() and str(debt.get("debtor", "")) == player_id and Ties.debt_s(Ties.cfg(_gd), rec, season_now) > 0:
				out.append({
					"id": "debt",
					"kind": "debt",
					"strength": Ties.debt_s(Ties.cfg(_gd), rec, season_now),
					"label": "Repay debt of gratitude (ân tình)",
				})
	return out


# --- Stateful Execution -----------------------------------------------------------------------------------------------

## Executes interaction [param verb_id] between [param session]'s player and [param npc_id] with optional
## [param params]. Returns [code]{ok, accepted, verb_id, npc_id, reply, voice_meta, effect_lines, lines,
## attitude_before, attitude_after, band, season_time_used, scene_started, ...}[/code].
func execute(session: GameSession, npc_id: String, verb_id: String, params: Dictionary = {}) -> Dictionary:
	var player: Character = session.player
	var npc: Dictionary = _db.get_record("people", npc_id)
	if npc.is_empty() or not bool(npc.get("alive", false)) or bool(npc.get("is_player", false)):
		return {"ok": false, "lines": ["No living person %s." % npc_id]}
	if str(npc.get("location_id", "")) != player.location_id:
		return {"ok": false, "lines": ["%s is not here." % str(npc.get("name", npc_id))]}
	if bool(npc.get("is_beast", false)):
		return {"ok": false, "beast": true, "lines": ["%s only growls." % str(npc.get("name", npc_id))]}

	var verb: Dictionary = InteractionRules.verb_def(_gd, verb_id)
	if verb.is_empty():
		return {"ok": false, "lines": ["Unknown interaction '%s'." % verb_id]}

	var player_rec: Dictionary = _player_dict(player)
	if not InteractionRules.check_trait_side(_gd, player_rec, npc, verb):
		return {"ok": false, "reason": "trait_hook_locked", "lines": ["Cannot use %s with %s." % [str(verb.name), str(npc.name)]]}

	var season_now: int = session.season_index()
	var year_now: int = session.year
	var v_time: float = float(verb.get("time", 0.0))
	if v_time > 0.0 and session.has_pending_event():
		return {"ok": false, "reason": "event_waiting", "lines": ["An event is waiting: cannot spend season time on %s." % str(verb.name)]}
	if v_time > 0.0 and not InteractionRules.has_focus_time(session.season_time_used, v_time):
		return {"ok": false, "reason": "insufficient_focus_time", "lines": ["Not enough of the season left for %s (needs %.2f, %.2f left)." % [str(verb.name), v_time, maxf(0.0, 1.0 - session.season_time_used)]]}

	var k: Dictionary = InteractionRules.knobs(_gd)
	var max_per_season: int = int(k.get("interactions_per_person_per_season", 2))
	var meta: Dictionary = _peek_meta(npc, season_now, year_now)
	if not bool(verb.get("bypass_season_limit", false)) and int(meta.season_count) >= max_per_season:
		return {
			"ok": false,
			"limit_reached": true,
			"reason": "season_limit",
			"lines": ["%s has no more time for you this season (%d / %d interactions limit)." % [str(npc.name), int(meta.season_count), max_per_season]],
		}

	var cd_until: int = int(Dictionary(meta.get("cooldowns", {})).get(verb_id, 0))
	if cd_until > season_now:
		return {
			"ok": false,
			"reason": "cooldown",
			"cooldown_left": cd_until - season_now,
			"lines": ["%s is on cooldown with %s (%d season(s) left)." % [str(verb.name), str(npc.name), cd_until - season_now]],
		}

	if verb_id == "teach" and int(meta.get("teach_year", -9999)) == year_now:
		return {
			"ok": false,
			"reason": "teach_yearly_limit",
			"lines": ["%s has already taught you this year (one lesson per teacher per year)." % str(npc.name)],
		}

	var req_ctx := {
		"has_open_obligation": not open_obligations(player.id, npc_id, season_now).is_empty(),
		"has_known_other": not _known_others(player, npc_id).is_empty(),
	}
	var req: Dictionary = InteractionRules.check_requirements(_gd, _db, verb, player, npc, req_ctx)
	if not bool(req.ok):
		return {"ok": false, "reason": str(req.reason), "lines": ["Cannot %s: %s" % [str(verb.name), str(req.reason)]]}

	var sh: StatSheet = session.sheet()
	var pr: float = sh.effective("mi_luc", player) - 50.0
	var att_before: int = int(npc.get("attitude", 0))
	var effect_lines: Array = []

	# F7: acting against the player's own traits incurs heart demon (never disables the verb, Rule 7 / AC-NI-07).
	var f7: Dictionary = InteractionRules.f7_trait_conflict(_gd, player_rec, Array(verb.get("tags", [])), player.heart_demon_used)
	var f7_applied: float = 0.0
	if int(f7.n_against) > 0 and float(f7.tam_ma_raw) > 0.0:
		f7_applied = CharacterRules.add_tam_ma(player, _gd, sh, float(f7.tam_ma_raw))
		player.heart_demon_used += float(f7.tam_ma_raw)
		effect_lines.append("Against your trait: tâm ma %+.1f (now %.0f)" % [f7_applied, player.tam_ma])

	var exec_res: Dictionary
	match verb_id:
		"greet":
			exec_res = _exec_greet(session, npc, sh, pr, season_now, year_now, effect_lines)
		"news":
			exec_res = _exec_news(session, npc, verb, sh, season_now, year_now, effect_lines)
		"about":
			exec_res = _exec_about(session, npc, verb, sh, season_now, year_now, params, effect_lines)
		"gift":
			exec_res = _exec_gift(session, npc, verb, sh, pr, season_now, year_now, params, effect_lines)
		"work":
			exec_res = _exec_work(session, npc, verb, sh, season_now, year_now, effect_lines)
		"teach":
			exec_res = _exec_teach(session, npc, verb, sh, season_now, year_now, params, effect_lines)
		"help":
			exec_res = _exec_help(session, npc, verb, sh, season_now, year_now, params, effect_lines)
		"trade":
			exec_res = _exec_trade(session, npc, verb, sh, season_now, year_now, params, effect_lines)
		"spar", "challenge":
			exec_res = _exec_spar(session, npc, verb, sh, pr, season_now, year_now, effect_lines)
		"threaten":
			exec_res = _exec_threaten(session, npc, verb, sh, season_now, year_now, effect_lines)
		"provoke":
			exec_res = _exec_provoke(session, npc, verb, season_now, year_now, effect_lines)
		"declare_enmity":
			exec_res = _exec_declare_enmity(session, npc, verb, season_now, year_now, effect_lines)
		"companion", "disciple", "brotherhood", "dao_lu", "take_disciple":
			exec_res = _exec_bond(session, npc, verb, sh, pr, season_now, year_now, effect_lines)
		"repay":
			exec_res = _exec_repay(session, npc, verb, pr, season_now, year_now, params, effect_lines)
		_:
			exec_res = _exec_trait_verb(session, npc, verb, sh, pr, season_now, year_now, params, effect_lines)

	if not bool(exec_res.get("ok", true)):
		return exec_res

	var result_key: String = str(exec_res.get("result_key", "accept" if bool(exec_res.get("accepted", false)) else "refuse"))
	var subs: Dictionary = Dictionary(exec_res.get("subs", {}))
	var voice: Dictionary = DialogueVoice.pick_line(_gd, _db, npc, _player_dict(player), verb_id, result_key, subs, session.seed_value, season_now)
	var att_after: int = int(npc.get("attitude", 0))
	var band: String = InteractionRules.attitude_band(_gd, att_after)
	var lines: Array = []
	if not bool(exec_res.get("scene_started", false)):
		lines.append(str(voice.text))
	else:
		lines.append(str(exec_res.get("scene_banner", str(voice.text))))
	lines.append_array(effect_lines)

	var out := {
		"ok": true,
		"accepted": bool(exec_res.get("accepted", false)),
		"verb_id": verb_id,
		"npc_id": npc_id,
		"result_key": result_key,
		"reply": str(voice.text),
		"voice_meta": voice,
		"effect_lines": effect_lines,
		"lines": lines,
		"attitude_before": att_before,
		"attitude_after": att_after,
		"band": band,
		"season_time_used": session.season_time_used,
		"scene_started": bool(exec_res.get("scene_started", false)),
		"f7_tam_ma": f7_applied,
	}
	for extra_k in exec_res.keys():
		if not out.has(extra_k):
			out[extra_k] = exec_res[extra_k]
	return out


# --- Base Verb Handlers -----------------------------------------------------------------------------------------------

func _exec_greet(session: GameSession, npc: Dictionary, _sh: StatSheet, pr: float, season_now: int, year_now: int, effect_lines: Array) -> Dictionary:
	var player: Character = session.player
	var npc_id: String = str(npc.id)
	var was_met: bool = bool(npc.get("met_player", false))
	session.meet(npc)
	var meta: Dictionary = _ensure_meta(npc, season_now, year_now)

	# AC-NI-12: complete any active visit quest stage naming this NPC.
	var completed_visits: Array = _complete_visits(player, npc_id, effect_lines, str(npc.name))

	var result_key: String = "accept"
	if not was_met:
		result_key = "first_meeting"
		effect_lines.append("Met %s (attitude %d, %s)." % [str(npc.name), int(npc.get("attitude", 0)), InteractionRules.attitude_band(_gd, int(npc.get("attitude", 0)))])
		if str(npc.get("cast_key", "")) != "":
			_log_deed(session.year, session.season, "interaction_meet", "%s gặp gỡ %s tại %s." % [player.name, str(npc.name), _place_name(player.location_id)], [player.id, npc_id], [player.location_id])
	else:
		var n_greet: int = int(meta.get("greet_year_count", 0))
		var delta: int = InteractionRules.greet_delta(_gd, pr, n_greet)
		_apply_attitude(npc, delta, effect_lines)
		meta["greet_year_count"] = n_greet + 1

	npc["last_talk_season"] = season_now
	meta["season_count"] = int(meta.season_count) + 1

	# Rule 18 / AC-NI-25: fire an eligible authored on_talk scene (greeting gain still applies once).
	var scene_started: bool = false
	var scene_banner: String = ""
	if not session.has_pending_event():
		var ctx: Dictionary = session.event_context()
		var raw_scene: Dictionary = _templates.generate_on_talk(ctx, npc, session.rng)
		if not raw_scene.is_empty():
			var norm: Dictionary = _validator.normalize(raw_scene, ctx, session.rng, str(raw_scene.source))
			if bool(norm.ok):
				session.pending_event = norm.event
				session.pending_meta = {"source": str(norm.event.source), "warnings": norm.warnings, "llm_error": ""}
				if bool(raw_scene.get("once", false)):
					var seen: Array = Array(npc.get("seen_scenes", []))
					var tid: String = str(raw_scene.get("template_id", ""))
					if tid != "" and not seen.has(tid):
						seen.append(tid)
						npc["seen_scenes"] = seen
				scene_started = true
				scene_banner = "*** EVENT: %s ***" % str(norm.event.title)
				effect_lines.append("Authored scene triggered: %s" % str(norm.event.title))

	return {
		"ok": true,
		"accepted": true,
		"result_key": result_key,
		"first_meeting": not was_met,
		"completed_visits": completed_visits,
		"scene_started": scene_started,
		"scene_banner": scene_banner,
	}


func _exec_news(session: GameSession, npc: Dictionary, verb: Dictionary, sh: StatSheet, season_now: int, year_now: int, effect_lines: Array) -> Dictionary:
	var player: Character = session.player
	var sc: Dictionary = InteractionRules.acceptance_score(_gd, _db, verb, player, sh, npc, _sect_standing(player, npc), {}, "", season_now)
	var meta: Dictionary = _ensure_meta(npc, season_now, year_now)
	if not bool(sc.accept):
		meta["season_count"] = int(meta.season_count) + 1
		return {"ok": true, "accepted": false, "result_key": "refuse"}

	var shared: Dictionary = _pull_news_item(session, npc, season_now)
	if shared.is_empty():
		# AC-NI-08: nothing new -> neither cooldown nor per-season count is spent!
		return {"ok": true, "accepted": true, "nothing_new": true, "result_key": "nothing_new"}

	meta["season_count"] = int(meta.season_count) + 1
	_set_cooldown(meta, "news", season_now + int(verb.get("cooldown", 1)))
	effect_lines.append(str(shared.note))
	return {
		"ok": true,
		"accepted": true,
		"nothing_new": false,
		"news_shared": shared,
		"result_key": "accept",
		"subs": {"{rumour}": str(shared.rumour)},
	}


func _exec_about(session: GameSession, npc: Dictionary, verb: Dictionary, sh: StatSheet, season_now: int, year_now: int, params: Dictionary, effect_lines: Array) -> Dictionary:
	var player: Character = session.player
	var target_id: String = str(params.get("target_id", ""))
	if target_id == "":
		var others: Array = _known_others(player, str(npc.id))
		if not others.is_empty():
			target_id = str(others[0].id)
	var target: Dictionary = _db.get_record("people", target_id)
	if target.is_empty() or target_id == player.id or target_id == str(npc.id):
		return {"ok": false, "lines": ["No known person to ask about."]}

	var sc: Dictionary = InteractionRules.acceptance_score(_gd, _db, verb, player, sh, npc, _sect_standing(player, npc), {}, "", season_now)
	var meta: Dictionary = _ensure_meta(npc, season_now, year_now)
	if not bool(sc.accept):
		meta["season_count"] = int(meta.season_count) + 1
		return {"ok": true, "accepted": false, "result_key": "refuse", "subs": {"{target}": str(target.name)}}

	meta["season_count"] = int(meta.season_count) + 1
	_set_cooldown(meta, "about", season_now + int(verb.get("cooldown", 1)))
	var op: float = NpcTraits.opinion(_gd, _db, npc, target) if _gd.registry.has_file(NpcTraits.FILE) else 0.0
	var info := {
		"id": target_id,
		"name": str(target.name),
		"realm": _gd.realm_label(int(target.get("realm_index", 0)), int(target.get("stage", 0))),
		"sect": str(_db.get_record("sects", str(target.get("sect_id", ""))).get("name", "Tán tu")),
		"place": _place_name(str(target.get("location_id", ""))),
		"traits": NpcTraits.held(target) if _gd.registry.has_file(NpcTraits.FILE) else [],
		"opinion": op,
	}
	effect_lines.append("%s (%s, %s, at %s) — %s's opinion: %+.0f" % [info.name, info.realm, info.sect, info.place, str(npc.name), op])
	return {"ok": true, "accepted": true, "result_key": "accept", "about_info": info, "subs": {"{target}": info.name}}


func _exec_gift(session: GameSession, npc: Dictionary, _verb: Dictionary, _sh: StatSheet, pr: float, season_now: int, year_now: int, params: Dictionary, effect_lines: Array) -> Dictionary:
	var player: Character = session.player
	var npc_id: String = str(npc.id)
	var stones: int = int(params.get("stones", 0))
	var item_id: String = str(params.get("item_id", ""))
	var val: int = 0
	var label: String = ""

	if item_id != "":
		var item: Dictionary = _db.get_record("items", item_id)
		if item.is_empty() or str(item.get("owner_id", "")) != player.id:
			return {"ok": false, "lines": ["You do not own item %s." % item_id]}
		if player.equipped.has(item_id):
			return {"ok": false, "lines": ["Unequip %s before gifting it." % str(item.name)]}
		if str(item.get("kind", "")) == "herb" and int(item.get("plot", -1)) >= 0:
			return {"ok": false, "lines": ["Harvest %s before gifting it." % str(item.name)]}
		val = maxi(0, _items.value_of(item))
		label = str(item.get("name", item_id))
		_transfer_single_item(item, npc_id)
	elif stones > 0:
		if player.linh_thach < stones:
			return {"ok": false, "lines": ["Not enough linh thạch (need %d, have %d)." % [stones, player.linh_thach]]}
		var moved: int = int(MoneyLedger.new(_db, player).transfer("player", "npc:" + npc_id, float(stones), "gift"))
		val = moved
		label = "%d linh thạch" % moved
	elif params.has("stones") and stones == 0:
		val = 0
		label = "món đồ tầm thường"
	else:
		return {"ok": false, "lines": ["Specify stones or item_id to gift."]}

	var meta: Dictionary = _ensure_meta(npc, season_now, year_now)
	meta["season_count"] = int(meta.season_count) + 1
	if val <= 0:
		effect_lines.append("Gift valued at 0: attitude unchanged.")
		return {"ok": true, "accepted": true, "result_key": "worthless", "gift_value": 0, "subs": {"{item}": label}}

	var n_gift: int = int(meta.get("gift_year_count", 0))
	var delta: int = InteractionRules.gift_delta(_gd, val, npc, pr, n_gift)
	_apply_attitude(npc, delta, effect_lines)
	meta["gift_year_count"] = n_gift + 1

	var w_r: float = float(_gd.realm_budget(int(npc.get("realm_index", 0))).get("linh_thach_max", 80))
	var share: float = float(InteractionRules.knobs(_gd).get("notable_gift_share", 0.25))
	if float(val) >= share * w_r:
		set_npc_flag(npc, "gifted_by", year_now)
		_log_deed(year_now, session.season, "interaction_gift", "%s tặng %s cho %s." % [player.name, label, str(npc.name)], [player.id, npc_id], [player.location_id], [], {"value": val})
	return {"ok": true, "accepted": true, "result_key": "accept", "gift_value": val, "subs": {"{item}": label}}


func _exec_work(session: GameSession, npc: Dictionary, verb: Dictionary, sh: StatSheet, season_now: int, year_now: int, effect_lines: Array) -> Dictionary:
	var player: Character = session.player
	_complete_visits(player, str(npc.id), effect_lines, str(npc.name))
	var sc: Dictionary = InteractionRules.acceptance_score(_gd, _db, verb, player, sh, npc, _sect_standing(player, npc), {}, "", season_now)
	var meta: Dictionary = _ensure_meta(npc, season_now, year_now)
	if not bool(sc.accept):
		meta["season_count"] = int(meta.season_count) + 1
		return {"ok": true, "accepted": false, "result_key": "refuse"}
	var offer: Dictionary = Dictionary(npc.get("quest_offer", {}))
	if offer.is_empty():
		return {"ok": true, "accepted": true, "no_work": true, "result_key": "no_work"}
	meta["season_count"] = int(meta.season_count) + 1
	_set_cooldown(meta, "work", season_now + int(verb.get("cooldown", 1)))
	effect_lines.append("Work accepted: %s" % str(offer.get("title", "task")))
	return {"ok": true, "accepted": true, "quest_offer": offer.duplicate(true), "result_key": "accept"}


func _exec_teach(session: GameSession, npc: Dictionary, verb: Dictionary, sh: StatSheet, season_now: int, year_now: int, params: Dictionary, effect_lines: Array) -> Dictionary:
	var player: Character = session.player
	var npc_id: String = str(npc.id)
	var sc: Dictionary = InteractionRules.acceptance_score(_gd, _db, verb, player, sh, npc, _sect_standing(player, npc), {}, "", season_now)
	var meta: Dictionary = _ensure_meta(npc, season_now, year_now)
	if not bool(sc.accept):
		meta["season_count"] = int(meta.season_count) + 1
		if InteractionRules.attitude_band(_gd, int(npc.get("attitude", 0))) == "hostile":
			_apply_attitude(npc, -2, effect_lines)
		return {"ok": true, "accepted": false, "result_key": "refuse"}

	var lesson: String = str(params.get("lesson", "insight"))
	var lesson_label: String = ""
	var granted_manual_id: String = ""
	var insight_pct: float = 0.0
	if lesson.begins_with("manual:"):
		var tid: String = lesson.trim_prefix("manual:")
		var elig: Array = InteractionRules.teachable_manuals(_gd, npc, player)
		var picked: Dictionary = {}
		for e in elig:
			if str(e.tech_id) == tid:
				picked = e
				break
		if picked.is_empty():
			return {"ok": false, "reason": "manual_not_offered", "lines": ["%s will not teach technique '%s'." % [str(npc.name), tid]]}
		var manual: Dictionary = _make_manual_copy(picked.def, player.id)
		granted_manual_id = _db.add("items", manual)
		lesson_label = str(picked.name)
		effect_lines.append("Received manual copy: %s [%s]" % [lesson_label, granted_manual_id])
	else:
		insight_pct = InteractionRules.teaching_insight_pct(_gd, int(npc.get("realm_index", 0)), player.realm_index)
		player.interaction_buffs.append({
			"source": "Thỉnh giáo: %s" % str(npc.name),
			"stat": "cultivation_speed_pct",
			"value": insight_pct,
			"expires_season": season_now + 2,
		})
		lesson_label = "tâm đắc tu luyện (+%d%%)" % int(roundf(insight_pct))
		effect_lines.append("Teaching insight: cultivation speed +%.0f%% next season." % insight_pct)

	_spend_focus_time(session, float(verb.get("time", 0.25)), effect_lines)
	set_npc_flag(npc, "taught", year_now)
	_log_deed(year_now, session.season, "interaction_taught", "%s thỉnh giáo %s từ %s." % [player.name, lesson_label, str(npc.name)], [player.id, npc_id], [player.location_id], [granted_manual_id] if granted_manual_id != "" else [])
	meta["teach_year"] = year_now
	meta["season_count"] = int(meta.season_count) + 1
	_set_cooldown(meta, "teach", season_now + int(verb.get("cooldown", 4)))
	return {
		"ok": true,
		"accepted": true,
		"result_key": "accept",
		"lesson": lesson,
		"insight_pct": insight_pct,
		"manual_id": granted_manual_id,
		"subs": {"{lesson}": lesson_label},
	}


func _exec_help(session: GameSession, npc: Dictionary, verb: Dictionary, sh: StatSheet, season_now: int, year_now: int, params: Dictionary, effect_lines: Array) -> Dictionary:
	var player: Character = session.player
	var npc_id: String = str(npc.id)
	var sub: String = str(params.get("sub", "loan"))
	var meta: Dictionary = _ensure_meta(npc, season_now, year_now)

	if sub == "introduction":
		if str(npc.get("sect_id", "")) == "" or player.sect_id == str(npc.get("sect_id", "")):
			return {"ok": false, "reason": "invalid_introduction", "lines": ["%s cannot introduce you to their sect." % str(npc.name)]}

	var extra_mods: Dictionary = _extra_score_mods("help", player.id, npc) if sub == "loan" else {}
	var cap: int = InteractionRules.loan_cap(_gd, npc) if sub == "loan" else 0
	if sub == "loan" and cap <= 0:
		meta["season_count"] = int(meta.season_count) + 1
		effect_lines.append("%s has nothing to lend." % str(npc.name))
		return {"ok": true, "accepted": false, "reason": "nothing_to_lend", "result_key": "refuse"}

	var sc: Dictionary = InteractionRules.acceptance_score(_gd, _db, verb, player, sh, npc, _sect_standing(player, npc), extra_mods, sub, season_now)
	if not bool(sc.accept):
		meta["season_count"] = int(meta.season_count) + 1
		if InteractionRules.attitude_band(_gd, int(npc.get("attitude", 0))) == "hostile":
			_apply_attitude(npc, -3, effect_lines)
		return {"ok": true, "accepted": false, "result_key": "refuse"}

	var out_extra := {"help_sub": sub}
	match sub:
		"loan":
			var req_amt: int = int(params.get("amount", cap))
			var amt: int = clampi(req_amt if req_amt > 0 else cap, 1, cap)
			var moved: int = int(MoneyLedger.new(_db, player).transfer("npc:" + npc_id, "player", float(amt), "loan"))
			if moved <= 0:
				meta["season_count"] = int(meta.season_count) + 1
				return {"ok": true, "accepted": false, "reason": "nothing_to_lend", "result_key": "refuse"}
			var term: int = int(InteractionRules.knobs(_gd).get("loan_term", 8))
			var loan: Dictionary = _add_loan(npc_id, player.id, moved, season_now, season_now + term)
			set_npc_flag(npc, "owes_loan", true)
			_log_deed(year_now, session.season, "interaction_loan", "%s vay %d linh thạch từ %s." % [player.name, moved, str(npc.name)], [player.id, npc_id], [player.location_id], [], {"loan_id": loan.id, "amount": moved})
			effect_lines.append("Borrowed %d linh thạch from %s (due in %d seasons)." % [moved, str(npc.name), term])
			out_extra["loan"] = loan
			out_extra["subs"] = {"{amount}": str(moved)}
		"guide":
			var revealed: String = _reveal_unknown_place(session, npc)
			if revealed != "":
				var pname: String = _place_name(revealed)
				effect_lines.append("%s guided you on the route to %s." % [str(npc.name), pname])
				out_extra["guided_place_id"] = revealed
			else:
				effect_lines.append("%s shared local travel tips." % str(npc.name))
			_log_deed(year_now, session.season, "interaction_guide", "%s được %s chỉ đường." % [player.name, str(npc.name)], [player.id, npc_id], [player.location_id])
		"introduction":
			var sid: String = str(npc.sect_id)
			var gain: float = _sect_members.change_standing(sid, player.id, 10.0)
			var sname: String = str(_db.get_record("sects", sid).get("name", sid))
			effect_lines.append("%s introduced you to %s: standing %+.1f." % [str(npc.name), sname, gain])
			_log_deed(year_now, session.season, "interaction_sect_intro", "%s tiến cử %s với %s." % [str(npc.name), player.name, sname], [player.id, npc_id], [player.location_id])
			out_extra["standing_gain"] = gain
		_:
			return {"ok": false, "lines": ["Unknown help kind '%s'." % sub]}

	meta["season_count"] = int(meta.season_count) + 1
	_set_cooldown(meta, "help", season_now + int(verb.get("cooldown", 2)))
	out_extra["ok"] = true
	out_extra["accepted"] = true
	out_extra["result_key"] = "accept"
	return out_extra


func _exec_trade(session: GameSession, npc: Dictionary, verb: Dictionary, sh: StatSheet, season_now: int, year_now: int, params: Dictionary, effect_lines: Array) -> Dictionary:
	var player: Character = session.player
	var npc_id: String = str(npc.id)
	var cur_band: String = InteractionRules.attitude_band(_gd, int(npc.get("attitude", 0)))
	var sc: Dictionary = InteractionRules.acceptance_score(_gd, _db, verb, player, sh, npc, _sect_standing(player, npc), {}, "", season_now)
	var meta: Dictionary = _ensure_meta(npc, season_now, year_now)
	if not bool(sc.accept) or InteractionRules.band_rank(cur_band) < InteractionRules.band_rank("neutral"):
		meta["season_count"] = int(meta.season_count) + 1
		return {"ok": true, "accepted": false, "result_key": "refuse"}

	var offer: Dictionary = InteractionRules.trade_items_for(_gd, _db, npc)
	var haggled: bool = _is_haggled(npc, season_now)
	var action: String = str(params.get("trade_action", "browse"))
	var trade_out := {"offer": offer, "haggled": haggled}

	if action == "buy":
		var item_id: String = str(params.get("item_id", ""))
		var found: Dictionary = {}
		for it in offer.shown:
			if str(it.id) == item_id:
				found = it
				break
		if found.is_empty():
			return {"ok": false, "lines": ["That item is not available for trade."]}
		var base_b: int = _market.buy_price(player, sh, found, player.location_id)
		var base_s: int = _market.sell_price(player, sh, found, player.location_id)
		var price: int = int(InteractionRules.haggle_prices(_gd, base_b, base_s, haggled).buy)
		if player.linh_thach < price:
			return {"ok": false, "lines": ["%s costs %d linh thạch; you have %d." % [str(found.name), price, player.linh_thach]]}
		MoneyLedger.new(_db, player).transfer("player", "npc:" + npc_id, float(price), "npc_trade")
		var moved_id: String = _transfer_single_item(found, player.id)
		effect_lines.append("Bought %s from %s for %d linh thạch." % [str(found.name), str(npc.name), price])
		trade_out["price"] = price
		trade_out["item_id"] = moved_id
	elif action == "sell":
		var item_id: String = str(params.get("item_id", ""))
		var item: Dictionary = _db.get_record("items", item_id)
		if item.is_empty() or str(item.get("owner_id", "")) != player.id:
			return {"ok": false, "lines": ["You do not own %s." % item_id]}
		if player.equipped.has(item_id):
			return {"ok": false, "lines": ["Unequip %s before selling." % str(item.name)]}
		if str(item.get("kind", "")) == "herb" and int(item.get("plot", -1)) >= 0:
			return {"ok": false, "lines": ["Harvest %s before selling." % str(item.name)]}
		var base_b: int = _market.buy_price(player, sh, item, player.location_id)
		var base_s: int = _market.sell_price(player, sh, item, player.location_id)
		var price: int = int(InteractionRules.haggle_prices(_gd, base_b, base_s, haggled).sell)
		if int(floorf(float(npc.get("linh_thach", 0.0)))) < price:
			return {"ok": false, "lines": ["%s cannot afford %d linh thạch." % [str(npc.name), price]]}
		MoneyLedger.new(_db, player).transfer("npc:" + npc_id, "player", float(price), "npc_trade")
		_transfer_single_item(item, npc_id)
		effect_lines.append("Sold %s to %s for %d linh thạch." % [str(item.name), str(npc.name), price])
		trade_out["price"] = price
		trade_out["item_id"] = item_id

	meta["season_count"] = int(meta.season_count) + 1
	trade_out["ok"] = true
	trade_out["accepted"] = true
	trade_out["result_key"] = "accept"
	return trade_out


func _exec_spar(session: GameSession, npc: Dictionary, verb: Dictionary, sh: StatSheet, pr: float, season_now: int, year_now: int, effect_lines: Array) -> Dictionary:
	var player: Character = session.player
	var npc_id: String = str(npc.id)
	var vid: String = str(verb.id)
	var sc: Dictionary = InteractionRules.acceptance_score(_gd, _db, verb, player, sh, npc, _sect_standing(player, npc), {}, "", season_now)
	var meta: Dictionary = _ensure_meta(npc, season_now, year_now)
	if not bool(sc.accept):
		meta["season_count"] = int(meta.season_count) + 1
		_apply_refuse_effects(npc, verb, effect_lines)
		return {"ok": true, "accepted": false, "result_key": "refuse"}

	var fx: Dictionary = _first_effect(verb, "run_spar")
	var loss_share: float = float(fx.get("loss_share", InteractionRules.knobs(_gd).get("spar_loss_share", 0.50)))
	var normal_loss: float = float(_gd.session().mission.injury_khi_huyet_loss_pct) / 100.0
	var vit_loss: float = normal_loss * loss_share
	var vit_floor: float = float(_gd.breakthrough_rules().vitality_floor)

	var enemy: Character = Character.from_dict(npc)
	var enemy_sheet: StatSheet = _builds.sheet_of(enemy)
	var player_won: bool = false
	var rated: bool = false
	var fight_res: FightResult = null
	var fe_on: bool = bool(_gd.combat().get("fight_engine", {}).get("enabled", false))

	if fe_on:
		var errors: Array = []
		var req := FightRequest.new()
		req.situation = FightRequest.Situation.FORESEEN
		req.a = FighterCompiler.compile(player, _gd, _db, sh, [], errors)
		req.b = FighterCompiler.compile(enemy, _gd, _db, enemy_sheet, [], errors)
		if req.a != null and req.b != null:
			var fuel_due: Array = []
			Diagrams.compile_for(_gd, _db, player, req.a, sh, req.situation, -1, fuel_due)
			Diagrams.compile_for(_gd, _db, enemy, req.b, enemy_sheet, req.situation, -1, fuel_due)
			if _ratings != null and _ratings.enabled():
				req.fight_seed = _ratings.event_fight_seed(player.id, npc_id, session.seed_value, season_now)
			else:
				req.fight_seed = session.rng.randi()
			req.log_enabled = true
			if _combat_service == null:
				_combat_service = CombatService.new(CombatConstants.from_game_data(_gd))
			fight_res = _combat_service.resolve(req)
			if fight_res != null:
				for due in fuel_due:
					Diagrams.pay_fuel(_db, due[0], int(due[1]))
				var code: String = fight_res.win_code()
				player_won = (code == "A")
				if _ratings != null and _ratings.enabled():
					var score_v: float = {"A": 1.0, "B": 0.0}.get(code, 0.5)
					_ratings.apply_fight(_ratings.ensure(player), _ratings.refresh_person(npc), score_v)
					rated = true

	if fight_res == null:
		var mine: float = CombatPower.compute(player, _gd, _db, sh).total
		var theirs: float = _builds.power_of(enemy)
		var duel: Dictionary = CombatPower.duel(mine, theirs, sh.effective("khi_van", player), float(enemy.base_stat("khi_van")), _gd, session.rng)
		player_won = bool(duel.win)
		if _ratings != null and _ratings.enabled():
			_ratings.apply_fight(_ratings.ensure(player), _ratings.refresh_person(npc), 1.0 if player_won else 0.0)
			rated = true

	# AC-NI-17: non-lethal (neither dies); loser takes spar_loss_share (0.5) of normal vitality loss.
	if player_won:
		npc["vitality"] = maxf(float(npc.get("vitality", 1.0)) - vit_loss, vit_floor)
	else:
		player.vitality = maxf(player.vitality - vit_loss, vit_floor)
	player.alive = true
	npc["alive"] = true

	var held: Array = NpcTraits.held(npc) if _gd.registry.has_file(NpcTraits.FILE) else []
	var att_base: float = float(fx.get("default_att", 2))
	if held.has("brave") or held.has("warlike") or held.has("duel_seeker"):
		att_base = float(fx.get("martial_att", 4))
	elif held.has("arrogant") and player_won and fx.has("arrogant_loss_att"):
		att_base = float(fx.get("arrogant_loss_att", -5))
	var delta: int = InteractionRules.attitude_delta(_gd, att_base, pr)
	_apply_attitude(npc, delta, effect_lines)

	_spend_focus_time(session, float(verb.get("time", 0.10)), effect_lines)
	var flag_name: String = "challenged" if vid == "challenge" else "sparred"
	set_npc_flag(npc, flag_name, year_now)
	_log_deed(year_now, session.season, "interaction_" + vid, "%s %s với %s (%s)." % [player.name, "giao đấu" if vid == "challenge" else "luận bàn", str(npc.name), "thắng" if player_won else "thua"], [player.id, npc_id], [player.location_id])
	meta["season_count"] = int(meta.season_count) + 1
	_set_cooldown(meta, vid, season_now + int(verb.get("cooldown", 2)))
	effect_lines.append("Spar (%s): %s (loser vitality -%.0f%%%s)." % ["foreseen", "VICTORY" if player_won else "DEFEAT", vit_loss * 100.0, ", rated" if rated else ""])
	return {
		"ok": true,
		"accepted": true,
		"result_key": "win" if player_won else "lose",
		"spar_result": {
			"win": player_won,
			"non_lethal": true,
			"situation": "foreseen",
			"loser_vitality_loss": vit_loss,
			"rated": rated,
		},
	}


func _exec_threaten(session: GameSession, npc: Dictionary, verb: Dictionary, sh: StatSheet, season_now: int, year_now: int, effect_lines: Array) -> Dictionary:
	var player: Character = session.player
	var npc_id: String = str(npc.id)
	var meta: Dictionary = _ensure_meta(npc, season_now, year_now)
	var fx: Dictionary = _first_effect(verb, "run_threat")
	var q: float = _player_win_share(player, sh, npc)
	var tc: Dictionary = InteractionRules.threat_chance(_gd, q, npc)
	var roll: float = session.rng.randf()
	var succeeded: bool = roll < float(tc.p)

	set_npc_flag(npc, "threatened_by", year_now)
	meta["season_count"] = int(meta.season_count) + 1
	_set_cooldown(meta, "threaten", season_now + int(verb.get("cooldown", 2)))

	if succeeded:
		var w_r: float = float(_gd.realm_budget(int(npc.get("realm_index", 0))).get("linh_thach_max", 80))
		var demand: int = mini(int(floorf(float(fx.get("yield_share", 0.25)) * w_r)), maxi(0, int(floorf(float(npc.get("linh_thach", 0.0))))))
		var moved: int = int(MoneyLedger.new(_db, player).transfer("npc:" + npc_id, "player", float(demand), "threat")) if demand > 0 else 0
		_apply_attitude(npc, int(fx.get("success_att", -25)), effect_lines)
		if Ties.enabled(_gd):
			TieTick.enqueue(_db, {"kind": "soft", "holder": npc_id, "other": player.id, "sk": "enmity", "delta": int(fx.get("enmity_gain", 20)), "deed": true, "cause": {"kind": "threaten"}})
		_log_deed(year_now, session.season, "interaction_threaten", "%s uy hiếp %s đoạt %d linh thạch." % [player.name, str(npc.name), moved], [player.id, npc_id], [player.location_id])
		effect_lines.append("Threat succeeded (%.0f%% odds): took %d linh thạch." % [float(tc.p) * 100.0, moved])
		return {
			"ok": true,
			"accepted": true,
			"result_key": "accept",
			"threat_chance": float(tc.p),
			"yielded": moved,
			"subs": {"{amount}": str(moved)},
		}

	_apply_attitude(npc, int(fx.get("fail_att", -15)), effect_lines)
	_log_deed(year_now, session.season, "interaction_threaten_fail", "%s uy hiếp %s bất thành." % [player.name, str(npc.name)], [player.id, npc_id], [player.location_id])
	var held: Array = NpcTraits.held(npc) if _gd.registry.has_file(NpcTraits.FILE) else []
	var agg_w: float = NpcTraits.choice_weight(_gd, npc, ["aggressive", "bold"], 1.0) if _gd.registry.has_file(NpcTraits.FILE) else 1.0
	var ambushes: bool = held.has("brave") or held.has("wrathful") or held.has("warlike") or agg_w >= float(fx.get("ambush_weight_min", 1.5))
	var scene_started: bool = false
	var scene_banner: String = ""
	if ambushes and not session.has_pending_event():
		var ctx: Dictionary = session.event_context()
		var raw_ev: Dictionary = _templates.generate_for_npc(ctx, npc, session.rng, str(fx.get("ambush_template", "threat_ambush")))
		if not raw_ev.is_empty():
			var norm: Dictionary = _validator.normalize(raw_ev, ctx, session.rng, str(raw_ev.source))
			if bool(norm.ok):
				norm.event["situation"] = "ambush"
				session.pending_event = norm.event
				session.pending_meta = {"source": str(norm.event.source), "warnings": norm.warnings, "llm_error": ""}
				scene_started = true
				scene_banner = "*** EVENT: %s ***" % str(norm.event.title)
				effect_lines.append("%s retaliates with an ambush!" % str(npc.name))
	return {
		"ok": true,
		"accepted": false,
		"result_key": "ambush" if scene_started else "refuse",
		"threat_chance": float(tc.p),
		"scene_started": scene_started,
		"scene_banner": scene_banner,
	}


func _exec_provoke(session: GameSession, npc: Dictionary, verb: Dictionary, season_now: int, year_now: int, effect_lines: Array) -> Dictionary:
	var player: Character = session.player
	var npc_id: String = str(npc.id)
	var meta: Dictionary = _ensure_meta(npc, season_now, year_now)
	var fx: Dictionary = _first_effect(verb, "open_provoke")

	_apply_attitude(npc, -20, effect_lines)
	var place: Dictionary = _db.get_record("places", player.location_id)
	if str(npc.get("sect_id", "")) != "" and str(place.get("sect_id", "")) == str(npc.sect_id):
		var drop: float = _sect_members.change_standing(str(npc.sect_id), player.id, float(fx.get("sect_seat_standing", -10.0)))
		effect_lines.append("Provocation on sect grounds: standing %+.1f." % drop)

	var scene_started: bool = false
	var scene_banner: String = ""
	var ctx: Dictionary = session.event_context()
	var raw_ev: Dictionary = _templates.generate_for_npc(ctx, npc, session.rng, str(fx.get("template", "provoke_duel")))
	if not raw_ev.is_empty():
		var norm: Dictionary = _validator.normalize(raw_ev, ctx, session.rng, str(raw_ev.source))
		if bool(norm.ok):
			norm.event["situation"] = "foreseen"
			norm.event["mercy_choice"] = true
			session.pending_event = norm.event
			session.pending_meta = {"source": str(norm.event.source), "warnings": norm.warnings, "llm_error": ""}
			scene_started = true
			scene_banner = "*** EVENT: %s ***" % str(norm.event.title)
			effect_lines.append("Foreseen duel opened with %s (mercy choice on win)." % str(npc.name))

	_log_deed(year_now, session.season, "interaction_provoke", "%s khiêu khích %s tại %s." % [player.name, str(npc.name), _place_name(player.location_id)], [player.id, npc_id], [player.location_id])
	meta["season_count"] = int(meta.season_count) + 1
	_set_cooldown(meta, "provoke", season_now + int(verb.get("cooldown", 2)))
	return {"ok": true, "accepted": true, "result_key": "accept", "scene_started": scene_started, "scene_banner": scene_banner}


func _exec_declare_enmity(session: GameSession, npc: Dictionary, verb: Dictionary, season_now: int, year_now: int, effect_lines: Array) -> Dictionary:
	var player: Character = session.player
	var npc_id: String = str(npc.id)
	var meta: Dictionary = _ensure_meta(npc, season_now, year_now)
	var fx: Dictionary = _first_effect(verb, "declare_enmity")
	var strength: int = int(fx.get("strength", 30))
	if Ties.enabled(_gd):
		Ties.write_soft(_gd, _db, player.id, npc_id, "enmity", strength, season_now, {"deed": true, "cause": {"kind": "declare_enmity"}})
		Ties.write_soft(_gd, _db, npc_id, player.id, "enmity", strength, season_now, {"deed": true, "cause": {"kind": "declare_enmity"}})
	_apply_attitude(npc, -30, effect_lines)
	_log_deed(year_now, session.season, "interaction_enmity", "%s tuyệt giao với %s." % [player.name, str(npc.name)], [player.id, npc_id], [player.location_id])
	meta["season_count"] = int(meta.season_count) + 1
	_set_cooldown(meta, "declare_enmity", season_now + int(verb.get("cooldown", 4)))
	effect_lines.append("Declared enmity (+%d both ways) with %s." % [strength, str(npc.name)])
	return {"ok": true, "accepted": true, "result_key": "accept"}


func _exec_bond(session: GameSession, npc: Dictionary, verb: Dictionary, sh: StatSheet, pr: float, season_now: int, year_now: int, effect_lines: Array) -> Dictionary:
	var player: Character = session.player
	var npc_id: String = str(npc.id)
	var vid: String = str(verb.id)
	var sc: Dictionary = InteractionRules.acceptance_score(_gd, _db, verb, player, sh, npc, _sect_standing(player, npc), {}, "", season_now)
	var meta: Dictionary = _ensure_meta(npc, season_now, year_now)
	if not bool(sc.accept):
		meta["season_count"] = int(meta.season_count) + 1
		return {"ok": true, "accepted": false, "result_key": "refuse"}

	var fx: Dictionary = _first_effect(verb, "form_bond")
	var bond_kind: String = str(fx.get("bond", ""))
	var res: Dictionary = {"ok": false, "reason": "unknown bond"}
	match bond_kind:
		"companion":
			res = Ties.add_pinned(_gd, _db, player.id, npc_id, "companion", season_now)
		"su_do":
			res = Ties.set_master(_gd, _db, npc_id, player.id, season_now)
			_db.mark_hook_dirty(npc_id)
			_db.mark_hook_dirty(player.id)
		"ket_nghia":
			res = Ties.add_pinned(_gd, _db, player.id, npc_id, "ket_nghia", season_now)
		"dao_lu":
			res = Ties.add_pinned(_gd, _db, player.id, npc_id, "dao_lu", season_now)
			_db.mark_hook_dirty(player.id)
			_db.mark_hook_dirty(npc_id)

	if not bool(res.get("ok", false)):
		return {"ok": false, "reason": str(res.get("reason", "bond failed")), "lines": ["Cannot form bond: %s" % str(res.get("reason", ""))]}

	for eff in Array(verb.get("accept_effects", [])):
		if eff is Dictionary and str((eff as Dictionary).get("type", "")) == "attitude":
			var d: int = InteractionRules.attitude_delta(_gd, float((eff as Dictionary).get("amount", 0)), pr)
			_apply_attitude(npc, d, effect_lines)

	_log_deed(year_now, session.season, "interaction_bond_" + bond_kind, "%s kết %s với %s." % [player.name, bond_kind, str(npc.name)], [player.id, npc_id], [player.location_id])
	meta["season_count"] = int(meta.season_count) + 1
	_set_cooldown(meta, vid, season_now + int(verb.get("cooldown", 4)))
	effect_lines.append("Formed %s bond with %s." % [bond_kind, str(npc.name)])
	return {"ok": true, "accepted": true, "bond": bond_kind, "result_key": "accept"}


func _exec_repay(session: GameSession, npc: Dictionary, _verb: Dictionary, pr: float, season_now: int, year_now: int, params: Dictionary, effect_lines: Array) -> Dictionary:
	var player: Character = session.player
	var npc_id: String = str(npc.id)
	var obls: Array = open_obligations(player.id, npc_id, season_now)
	if obls.is_empty():
		return {"ok": false, "lines": ["No open obligation to %s." % str(npc.name)]}

	var want: String = str(params.get("obligation_id", ""))
	var picked: Dictionary = obls[0]
	if want != "":
		for o in obls:
			if str(o.id) == want or str(o.get("loan_id", "")) == want:
				picked = o
				break

	match str(picked.kind):
		"loan":
			var loan: Dictionary = _find_loan(str(picked.loan_id))
			var amt: int = int(loan.amount)
			if player.linh_thach < amt:
				return {"ok": false, "lines": ["Need %d linh thạch to repay loan (have %d)." % [amt, player.linh_thach]]}
			MoneyLedger.new(_db, player).transfer("player", "npc:" + npc_id, float(amt), "loan_repay")
			loan["status"] = "repaid"
			if season_now < int(loan.due_season):
				var bonus_att: int = int(InteractionRules.knobs(_gd).get("loan_early_repay_att", 5))
				_apply_attitude(npc, InteractionRules.attitude_delta(_gd, float(bonus_att), pr), effect_lines)
			_refresh_loan_flags(_db, player.id, npc_id)
			_log_deed(year_now, session.season, "interaction_repay", "%s trả nợ %d linh thạch cho %s." % [player.name, amt, str(npc.name)], [player.id, npc_id], [player.location_id])
			effect_lines.append("Repaid loan of %d linh thạch to %s." % [amt, str(npc.name)])
		"favour":
			var fcost: int = int(picked.amount)
			if player.linh_thach < fcost:
				return {"ok": false, "lines": ["Need %d linh thạch to clear favour (have %d)." % [fcost, player.linh_thach]]}
			MoneyLedger.player_pay(_db, player, "", fcost, "favour_repay")
			var rec: Dictionary = _db.tie_between(player.id, npc_id)
			if not rec.is_empty():
				rec["favour"] = ""
				_db.put(Ties.TABLE, rec)
			_log_deed(year_now, session.season, "interaction_repay", "%s hoàn ân cho %s." % [player.name, str(npc.name)], [player.id, npc_id], [player.location_id])
			effect_lines.append("Cleared favour with %s (%d linh thạch)." % [str(npc.name), fcost])
		"debt":
			var rec: Dictionary = _db.tie_between(player.id, npc_id)
			if not rec.is_empty() and not Dictionary(rec.get("debt", {})).is_empty():
				Ties.end_part(_db, rec, "debt", "repaid", season_now, rec.debt.get("cause", {}))
				rec["debt"] = {}
				_db.put(Ties.TABLE, rec)
			_log_deed(year_now, session.season, "interaction_repay", "%s trả ân tình cho %s." % [player.name, str(npc.name)], [player.id, npc_id], [player.location_id])
			effect_lines.append("Repaid gratitude debt to %s." % str(npc.name))
	return {"ok": true, "accepted": true, "repaid": picked, "result_key": "accept"}


# --- 19 Trait verb: Hook Handlers -------------------------------------------------------------------------------------

func _exec_trait_verb(session: GameSession, npc: Dictionary, verb: Dictionary, sh: StatSheet, pr: float, season_now: int, year_now: int, params: Dictionary, effect_lines: Array) -> Dictionary:
	var player: Character = session.player
	var npc_id: String = str(npc.id)
	var vid: String = str(verb.id)
	var meta: Dictionary = _ensure_meta(npc, season_now, year_now)

	# Pre-check wager purse before score.
	if vid == "wager":
		var cap: int = InteractionRules.wager_cap(_gd, player, npc)
		if cap <= 0:
			meta["season_count"] = int(meta.season_count) + 1
			effect_lines.append("Nothing to wager (empty purse).")
			return {"ok": true, "accepted": false, "reason": "nothing_to_wager", "result_key": "refuse"}

	var sc: Dictionary = InteractionRules.acceptance_score(_gd, _db, verb, player, sh, npc, _sect_standing(player, npc), {}, "", season_now)
	if not bool(sc.accept):
		meta["season_count"] = int(meta.season_count) + 1
		_apply_refuse_effects(npc, verb, effect_lines)
		return {"ok": true, "accepted": false, "result_key": "refuse"}

	var p_held: Array = NpcTraits.held(_player_dict(player)) if _gd.registry.has_file(NpcTraits.FILE) else []
	var n_held: Array = NpcTraits.held(npc) if _gd.registry.has_file(NpcTraits.FILE) else []
	var delta_r: int = int(npc.get("realm_index", 0)) - player.realm_index
	var subs: Dictionary = {}
	var out_extra: Dictionary = {}
	var result_key: String = "accept"

	match vid:
		"invoke_clan":
			_apply_attitude(npc, InteractionRules.attitude_delta(_gd, 8.0, pr), effect_lines)
			set_npc_flag(npc, "clan_invoked", season_now + 4)
			effect_lines.append("Clan name invoked (+10 on Help/Trade with %s for 1 year)." % str(npc.name))
		"command_mortals":
			var shared: Dictionary = _pull_news_item(session, npc, season_now)
			var rum: String = str(shared.get("rumour", "tình hình quanh %s tạm yên ổn" % _place_name(player.location_id)))
			subs["{rumour}"] = rum
			_apply_attitude(npc, InteractionRules.attitude_delta(_gd, 2.0, pr), effect_lines)
			effect_lines.append("Mortal retainers report: %s" % rum)
		"haggle":
			set_npc_flag(npc, "haggled_season", season_now)
			effect_lines.append("Haggled with %s: better trade prices this season (no-arbitrage clamped)." % str(npc.name))
		"charm":
			var tier: int = _talent_tier(player, "comely")
			var base_att: float = 4.0 + 2.0 * float(maxi(0, tier - 1))
			_apply_attitude(npc, InteractionRules.attitude_delta(_gd, base_att, pr), effect_lines)
			set_npc_flag(npc, "charmed", year_now)
		"tempt":
			_apply_attitude(npc, InteractionRules.attitude_delta(_gd, 10.0, pr), effect_lines)
			set_npc_flag(npc, "tempted", year_now)
			if Ties.enabled(_gd):
				TieTick.enqueue(_db, {"kind": "soft", "holder": npc_id, "other": player.id, "sk": "friend", "delta": 15, "cause": {"kind": "tempt"}})
			_log_deed(year_now, session.season, "interaction_tempt", "%s dụ dỗ %s theo ma đạo." % [player.name, str(npc.name)], [player.id, npc_id], [player.location_id])
		"exhort":
			player.tam_ma = maxf(0.0, player.tam_ma - 3.0)
			_apply_attitude(npc, InteractionRules.attitude_delta(_gd, 6.0, pr), effect_lines)
			if Ties.enabled(_gd):
				Ties.write_soft(_gd, _db, npc_id, player.id, "enmity", -15, season_now, {"cause": {"kind": "exhort"}})
			effect_lines.append("Exhorted on the Dharma: tâm ma -3 (now %.0f)." % player.tam_ma)
		"propose_dual_cultivation":
			var syn: bool = (Ties.enabled(_gd) and Ties.has_pin(_db, player.id, npc_id, "dao_lu")) or n_held.has("dual_cultivator")
			var pct: float = 20.0 if syn else 15.0
			player.interaction_buffs.append({
				"source": "Song tu: %s" % str(npc.name),
				"stat": "cultivation_speed_pct",
				"value": pct,
				"expires_season": season_now + 2,
			})
			_apply_attitude(npc, InteractionRules.attitude_delta(_gd, 6.0, pr), effect_lines)
			_spend_focus_time(session, float(verb.get("time", 0.25)), effect_lines)
			_log_deed(year_now, session.season, "interaction_dual_cultivation", "%s song tu cùng %s." % [player.name, str(npc.name)], [player.id, npc_id], [player.location_id])
			effect_lines.append("Dual cultivation: cultivation speed +%.0f%% next season." % pct)
		"counsel":
			var drop: float = 4.0 + float(maxi(0, delta_r)) * 2.0
			player.tam_ma = maxf(0.0, player.tam_ma - drop)
			_apply_attitude(npc, InteractionRules.attitude_delta(_gd, 3.0, pr), effect_lines)
			_spend_focus_time(session, float(verb.get("time", 0.10)), effect_lines)
			_log_deed(year_now, session.season, "interaction_counsel", "%s cầu khai thị từ %s." % [player.name, str(npc.name)], [player.id, npc_id], [player.location_id])
			effect_lines.append("Spiritual counsel: tâm ma -%.0f (now %.0f)." % [drop, player.tam_ma])
		"counsel_deviation":
			player.interaction_buffs.append({
				"source": "Phòng tẩu hỏa: %s" % str(npc.name),
				"stat": "qi_deviation_pct",
				"value": -10.0,
				"expires_season": season_now + 2,
			})
			player.tam_ma = maxf(0.0, player.tam_ma - 3.0)
			set_npc_flag(npc, "counseled_deviation", year_now)
			_apply_attitude(npc, InteractionRules.attitude_delta(_gd, 3.0, pr), effect_lines)
			_spend_focus_time(session, float(verb.get("time", 0.10)), effect_lines)
			effect_lines.append("Deviation counsel: qi_deviation_pct -10%% next season, tâm ma -3.")
		"ask_history":
			var hist: Dictionary = _pull_history_lore(session, npc)
			if hist.is_empty():
				return {"ok": true, "accepted": true, "nothing_new": true, "result_key": "nothing_new"}
			subs["{rumour}"] = str(hist.summary)
			_apply_attitude(npc, InteractionRules.attitude_delta(_gd, 2.0, pr), effect_lines)
			effect_lines.append("History shared: %s" % str(hist.summary))
			out_extra["history_shared"] = hist
		"share_tea":
			var syn_tea: bool = (p_held.has("tea_master") and n_held.has("tea_master")) or n_held.has("calm") or p_held.has("calm")
			_apply_attitude(npc, InteractionRules.attitude_delta(_gd, 8.0 if syn_tea else 5.0, pr), effect_lines)
			player.tam_ma = maxf(0.0, player.tam_ma - 2.0)
			effect_lines.append("Shared spirit tea: tâm ma -2 (now %.0f)." % player.tam_ma)
		"exchange_poems":
			var syn_poem: bool = (p_held.has("poet") or p_held.has("scholar_family")) and (n_held.has("poet") or n_held.has("scholar_family"))
			_apply_attitude(npc, InteractionRules.attitude_delta(_gd, 8.0 if syn_poem else 5.0, pr), effect_lines)
			if Ties.enabled(_gd) and InteractionRules.band_rank(InteractionRules.attitude_band(_gd, int(npc.get("attitude", 0)))) >= InteractionRules.band_rank("friendly"):
				TieTick.enqueue(_db, {"kind": "soft", "holder": npc_id, "other": player.id, "sk": "friend", "delta": 10, "cause": {"kind": "exchange_poems"}})
		"play_for":
			var drop_q: float = 3.0 if delta_r > 0 else 2.0
			_apply_attitude(npc, InteractionRules.attitude_delta(_gd, 5.0, pr), effect_lines)
			player.tam_ma = maxf(0.0, player.tam_ma - drop_q)
			effect_lines.append("Played guqin: tâm ma -%.0f (now %.0f)." % [drop_q, player.tam_ma])
		"play_go":
			var syn_go: bool = p_held.has("go_player") and (n_held.has("go_player") or n_held.has("strategist"))
			_apply_attitude(npc, InteractionRules.attitude_delta(_gd, 9.0 if syn_go else 6.0, pr), effect_lines)
			player.interaction_buffs.append({
				"source": "Đánh cờ vây: %s" % str(npc.name),
				"stat": "cultivation_speed_pct",
				"value": 5.0,
				"expires_season": season_now + 2,
			})
			_spend_focus_time(session, float(verb.get("time", 0.10)), effect_lines)
			effect_lines.append("Game of Go: cultivation speed +5%% next season.")
		"trade_curio":
			var item_id: String = str(params.get("item_id", ""))
			var curio: Dictionary = _pick_curio(player, item_id)
			if curio.is_empty():
				return {"ok": false, "lines": ["No eligible curio (rarity 2+) to trade."]}
			var cname: String = str(curio.get("name", curio.id))
			_transfer_single_item(curio, npc_id)
			if Ties.enabled(_gd):
				Ties.write_debt(_gd, _db, npc_id, player.id, 30, season_now, {"cause": {"kind": "trade_curio"}})
			_apply_attitude(npc, InteractionRules.attitude_delta(_gd, 8.0, pr), effect_lines)
			_log_deed(year_now, session.season, "interaction_trade_curio", "%s tặng kỳ vật %s cho %s đổi lấy ân tình." % [player.name, cname, str(npc.name)], [player.id, npc_id], [player.location_id])
			subs["{item}"] = cname
			effect_lines.append("Traded curio %s: %s now owes you a debt of gratitude." % [cname, str(npc.name)])
		"wager":
			var cap: int = InteractionRules.wager_cap(_gd, player, npc)
			var req_stake: int = int(params.get("stake", cap))
			var stake: int = clampi(req_stake if req_stake > 0 else cap, 1, cap)
			var p_kv: float = sh.effective("khi_van", player)
			var n_kv: float = float(Dictionary(npc.get("thien_phu", {})).get("khi_van", 50))
			var p_win: float = clampf(0.5 + (p_kv - n_kv) * 0.004, 0.25, 0.75)
			var won: bool = session.rng.randf() < p_win
			var ledger := MoneyLedger.new(_db, player)
			var moved: int = 0
			if won:
				moved = int(ledger.transfer("npc:" + npc_id, "player", float(stake), "wager"))
				result_key = "win"
				var att_d: int = -3 if n_held.has("greedy") else 3
				_apply_attitude(npc, InteractionRules.attitude_delta(_gd, float(att_d), pr), effect_lines)
				effect_lines.append("Won wager against %s: +%d linh thạch." % [str(npc.name), moved])
			else:
				moved = int(ledger.transfer("player", "npc:" + npc_id, float(stake), "wager"))
				result_key = "lose"
				_apply_attitude(npc, InteractionRules.attitude_delta(_gd, 3.0, pr), effect_lines)
				effect_lines.append("Lost wager to %s: -%d linh thạch." % [str(npc.name), moved])
			subs["{amount}"] = str(moved)
			out_extra["wager_win"] = won
			out_extra["wager_amount"] = moved
		"drink_with":
			var syn_dr: bool = (p_held.has("drinker") and n_held.has("drinker")) or n_held.has("gregarious")
			_apply_attitude(npc, InteractionRules.attitude_delta(_gd, 10.0 if syn_dr else 6.0, pr), effect_lines)
			var rum_d: String = "chuyện trà dư tửu hậu quanh %s" % _place_name(player.location_id)
			if session.knowledge != null and session.rng.randf() < 0.50:
				var leaked: Dictionary = _pull_news_item(session, npc, season_now)
				if not leaked.is_empty():
					rum_d = str(leaked.rumour)
					effect_lines.append("Over wine, %s let slip: %s" % [str(npc.name), str(leaked.note)])
			subs["{rumour}"] = rum_d

	meta["season_count"] = int(meta.season_count) + 1
	_set_cooldown(meta, vid, season_now + int(verb.get("cooldown", 2)))
	out_extra["ok"] = true
	out_extra["accepted"] = true
	out_extra["result_key"] = result_key
	out_extra["subs"] = subs
	return out_extra


# --- Season / Yearly / Death Lifecycle Hooks --------------------------------------------------------------------------

## Processes season-boundary interaction housekeeping: marks overdue loans (dropping lender attitude by
## [code]loan_overdue[/code] and scheduling [code]loan_collection[/code] follow-ups — AC-NI-15), and prunes
## expired temporary [code]interaction_buffs[/code] on stored person records. Returns logged WorldDB event ids.
static func tick_world_season(gd: GameData, db: WorldDB, abs_season: int, year_now: int, season_in_year: int) -> Array:
	var news: Array = []
	if db == null or gd == null or not gd.registry.has_file(InteractionRules.INTERACTIONS_FILE):
		return news
	var k: Dictionary = InteractionRules.knobs(gd)
	var overdue_pen: int = int(k.get("loan_overdue", 30))
	var lo: int = int(k.get("relationship_min", -100))
	var hi: int = int(k.get("relationship_max", 100))

	var rec: Dictionary = db.get_record("world", LOANS_REC)
	if not rec.is_empty():
		var items: Array = Array(rec.get("items", []))
		for raw_loan in items:
			if not (raw_loan is Dictionary):
				continue
			var loan: Dictionary = raw_loan as Dictionary
			if str(loan.get("status", "")) != "open":
				continue
			if abs_season < int(loan.get("due_season", 0)):
				continue
			var lender_id: String = str(loan.get("lender_id", ""))
			var borrower_id: String = str(loan.get("borrower_id", ""))
			var lender: Dictionary = db.get_record("people", lender_id)
			var borrower: Dictionary = db.get_record("people", borrower_id)
			if lender.is_empty() or not bool(lender.get("alive", false)) or borrower.is_empty() or not bool(borrower.get("alive", false)):
				loan["status"] = "written_off"
				continue
			loan["status"] = "overdue"
			lender["attitude"] = clampi(int(lender.get("attitude", 0)) - overdue_pen, lo, hi)
			set_npc_flag(lender, "owes_loan", true)
			set_npc_flag(lender, "owes_loan_overdue", true)
			if not bool(loan.get("follow_up_scheduled", false)):
				loan["follow_up_scheduled"] = true
				schedule_followup(db, {
					"template_id": "loan_collection",
					"npc_id": lender_id,
					"due_season": abs_season,
					"loan_id": str(loan.get("id", "")),
					"meta": {"amount": int(loan.get("amount", 0))},
				})
			var eid: String = db.log_event(
				year_now, season_in_year, "loan_overdue",
				"Khoản vay %d linh thạch của %s với %s đã quá hạn." % [int(loan.get("amount", 0)), str(borrower.get("name", borrower_id)), str(lender.get("name", lender_id))],
				[borrower_id, lender_id], [], [], {"loan_id": str(loan.get("id", "")), "amount": int(loan.get("amount", 0))}
			)
			news.append(eid)

	# Expire temporary interaction buffs on stored records (fast skip for people without buffs).
	for p in db.living():
		var buffs: Variant = p.get("interaction_buffs", null)
		if buffs is Array and not (buffs as Array).is_empty():
			p["interaction_buffs"] = (buffs as Array).filter(func(b): return b is Dictionary and int((b as Dictionary).get("expires_season", 0)) > abs_season)
		if float(p.get("season_time_used", 0.0)) > 0.0:
			p["season_time_used"] = 0.0
		if float(p.get("heart_demon_used", 0.0)) > 0.0:
			p["heart_demon_used"] = 0.0
	return news


## Alias matching the technical blueprint name [code]tick_loans[/code].
static func tick_loans(gd: GameData, db: WorldDB, _player: Character, season_now: int, year_now: int, season_in_year: int) -> Array:
	return tick_world_season(gd, db, season_now, year_now, season_in_year)


## Writes off any open/overdue loan where [param dead_id] is lender or borrower (GDD Edge Cases, #46 Rule 13:
## loans never pass to heirs; purses are untouched).
static func on_npc_death(db: WorldDB, dead_id: String, year_now: int, season_in_year: int) -> void:
	if db == null or dead_id == "":
		return
	var rec: Dictionary = db.get_record("world", LOANS_REC)
	if rec.is_empty():
		return
	for raw_loan in Array(rec.get("items", [])):
		if not (raw_loan is Dictionary):
			continue
		var loan: Dictionary = raw_loan as Dictionary
		if not (str(loan.get("status", "")) in ["open", "overdue"]):
			continue
		var lid: String = str(loan.get("lender_id", ""))
		var bid: String = str(loan.get("borrower_id", ""))
		if lid == dead_id or bid == dead_id:
			loan["status"] = "written_off"
			loan["written_off_reason"] = "lender_died" if lid == dead_id else "borrower_died"
			_refresh_loan_flags(db, bid, lid)
			db.log_event(year_now, season_in_year, "loan_written_off", "Khoản vay %d linh thạch được xóa sổ do có người tử nạn." % int(loan.get("amount", 0)), [lid, bid], [], [], {"loan_id": str(loan.get("id", ""))})


## Writes off the player's open loans on death without touching lenders' purses (GDD Edge Cases).
static func on_player_death(db: WorldDB, player_id: String, year_now: int, season_in_year: int) -> void:
	on_npc_death(db, player_id, year_now, season_in_year)


## Formula B yearly drift: moves every met living NPC's attitude 1 point toward their computed opinion
## of [param player_rec] (AC-NI-11).
static func yearly_attitude_drift(gd: GameData, db: WorldDB, player_rec: Dictionary) -> void:
	if gd == null or db == null or player_rec.is_empty() or not gd.registry.has_file(NpcTraits.FILE):
		return
	for p in db.living():
		if bool(p.get("is_player", false)) or bool(p.get("is_beast", false)):
			continue
		if not bool(p.get("met_player", false)):
			continue
		var op: float = NpcTraits.opinion(gd, db, p, player_rec)
		p["attitude"] = InteractionRules.yearly_drift(gd, int(p.get("attitude", 0)), op)


## Returns all loan records in [param db] filtered by optional [param borrower_id] and [param lender_id].
static func loans_of(db: WorldDB, borrower_id: String = "", lender_id: String = "") -> Array:
	if db == null:
		return []
	var rec: Dictionary = db.get_record("world", LOANS_REC)
	if rec.is_empty():
		return []
	var out: Array = []
	for raw in Array(rec.get("items", [])):
		if not (raw is Dictionary):
			continue
		var d: Dictionary = raw as Dictionary
		if borrower_id != "" and str(d.get("borrower_id", "")) != borrower_id:
			continue
		if lender_id != "" and str(d.get("lender_id", "")) != lender_id:
			continue
		out.append(d)
	return out


## Schedules a follow-up interaction event (e.g. [code]loan_collection[/code]) in [constant FOLLOWUPS_REC].
static func schedule_followup(db: WorldDB, entry: Dictionary) -> void:
	var rec: Dictionary = db.get_record("world", FOLLOWUPS_REC)
	if rec.is_empty():
		rec = {"id": FOLLOWUPS_REC, "items": []}
		db.add("world", rec)
	(rec.items as Array).append(entry.duplicate(true))


## Pops and returns the first due follow-up event ([code]due_season <= season_now[/code]) whose NPC is alive,
## or {} if none is due.
static func pop_due_followup(db: WorldDB, season_now: int) -> Dictionary:
	if db == null:
		return {}
	var rec: Dictionary = db.get_record("world", FOLLOWUPS_REC)
	if rec.is_empty():
		return {}
	var items: Array = Array(rec.get("items", []))
	for i in items.size():
		var fu: Dictionary = items[i]
		if int(fu.get("due_season", 0)) <= season_now:
			items.remove_at(i)
			rec["items"] = items
			var npc: Dictionary = db.get_record("people", str(fu.get("npc_id", "")))
			if not npc.is_empty() and bool(npc.get("alive", false)):
				return fu
			return pop_due_followup(db, season_now)
	return {}


## Marks open/overdue loans between [param borrower_id] and [param lender_id] as repaid (used when
## the player pays during a [code]loan_collection[/code] event).
static func mark_loans_repaid(db: WorldDB, borrower_id: String, lender_id: String) -> void:
	for loan in loans_of(db, borrower_id, lender_id):
		if str(loan.get("status", "")) in ["open", "overdue"]:
			loan["status"] = "repaid"
	_refresh_loan_flags(db, borrower_id, lender_id)


## Builds the immediate 2-choice post-win mercy follow-up event for [code]provoke_duel[/code] (AC-NI-19).
static func build_mercy_event(db: WorldDB, player: Character, npc_id: String, place_id: String, year_now: int) -> Dictionary:
	var npc: Dictionary = db.get_record("people", npc_id)
	var npc_name: String = str(npc.get("name", npc_id))
	return {
		"title": "Định đoạt sinh tử",
		"text": "%s đã gục xuống trước mũi binh khí của ngươi. Ngươi sẽ tha mạng hay kết liễu đối phương?" % npc_name,
		"npc_id": npc_id,
		"place_id": place_id,
		"source": "interaction:mercy_choice",
		"choices": [
			{
				"label": "Tha mạng cho %s (Mercy)" % npc_name,
				"check": {"type": "none"},
				"always": [],
				"success": {
					"text": "Ngươi thu binh khí, giữ lại một mạng cho %s." % npc_name,
					"effects": [
						{"type": "set_npc_flag", "npc": "event_npc", "flag": "spared_by", "value": year_now},
						{"type": "relationship", "npc": "event_npc", "amount": 10},
					],
				},
				"failure": {"text": "", "effects": []},
			},
			{
				"label": "Kết liễu %s (Kill)" % npc_name,
				"check": {"type": "none"},
				"always": [],
				"success": {
					"text": "Ngươi tung đòn cuối cùng, kết liễu %s ngay tại chỗ." % npc_name,
					"effects": [
						{"type": "kill_npc", "npc": "event_npc", "cause": "Tử chiến dưới tay %s" % player.name},
					],
				},
				"failure": {"text": "", "effects": []},
			},
		],
	}


## Sets remembered flag [param flag_name] to [param value] on [param npc], mirroring into
## [code]interaction_flags[/code] if present.
static func set_npc_flag(npc: Dictionary, flag_name: String, value: Variant) -> void:
	var fl: Dictionary = Dictionary(npc.get("flags", {}))
	fl[flag_name] = value
	npc["flags"] = fl
	if npc.has("interaction_flags"):
		var ifl: Dictionary = Dictionary(npc.get("interaction_flags", {}))
		ifl[flag_name] = value
		npc["interaction_flags"] = ifl


## Clears remembered flag [param flag_name] from [param npc].
static func clear_npc_flag(npc: Dictionary, flag_name: String) -> void:
	if npc.has("flags") and npc.flags is Dictionary:
		(npc.flags as Dictionary).erase(flag_name)
	if npc.has("interaction_flags") and npc.interaction_flags is Dictionary:
		(npc.interaction_flags as Dictionary).erase(flag_name)


# --- Internal Helpers -------------------------------------------------------------------------------------------------

static func _peek_meta(npc: Dictionary, season_now: int, year_now: int) -> Dictionary:
	var raw: Dictionary = Dictionary(npc.get("interact_meta", {}))
	var sc: int = int(raw.get("season_count", 0)) if int(raw.get("season", -9999)) == season_now else 0
	var same_year: bool = int(raw.get("year", -9999)) == year_now
	return {
		"season": season_now,
		"season_count": sc,
		"cooldowns": Dictionary(raw.get("cooldowns", {})),
		"year": year_now,
		"greet_year_count": int(raw.get("greet_year_count", 0)) if same_year else 0,
		"gift_year_count": int(raw.get("gift_year_count", 0)) if same_year else 0,
		"teach_year": int(raw.get("teach_year", -9999)),
	}


static func _ensure_meta(npc: Dictionary, season_now: int, year_now: int) -> Dictionary:
	var m: Dictionary = _peek_meta(npc, season_now, year_now)
	m["cooldowns"] = Dictionary(m.cooldowns).duplicate()
	npc["interact_meta"] = m
	return m


static func _set_cooldown(meta: Dictionary, verb_id: String, until_season: int) -> void:
	var cds: Dictionary = Dictionary(meta.get("cooldowns", {}))
	cds[verb_id] = until_season
	meta["cooldowns"] = cds


func _player_dict(player: Character) -> Dictionary:
	return player.to_dict()


func _sect_standing(player: Character, npc: Dictionary) -> float:
	var sid: String = str(npc.get("sect_id", ""))
	if sid == "" or _sect_members == null:
		return 0.0
	return _sect_members.standing(sid, player.id)


func _place_name(place_id: String) -> String:
	if place_id == "" or _db == null:
		return "nơi này"
	return str(_db.get_record("places", place_id).get("name", place_id))


func _apply_attitude(npc: Dictionary, delta: int, effect_lines: Array) -> void:
	var k: Dictionary = InteractionRules.knobs(_gd)
	var lo: int = int(k.get("relationship_min", -100))
	var hi: int = int(k.get("relationship_max", 100))
	var before: int = int(npc.get("attitude", 0))
	var after: int = clampi(before + delta, lo, hi)
	npc["attitude"] = after
	if delta != 0:
		effect_lines.append("%s's attitude %+d (now %d, %s)." % [str(npc.name), delta, after, InteractionRules.attitude_band(_gd, after)])


func _apply_refuse_effects(npc: Dictionary, verb: Dictionary, effect_lines: Array) -> void:
	var n_held: Array = NpcTraits.held(npc) if _gd.registry.has_file(NpcTraits.FILE) else []
	for raw_fx in Array(verb.get("refuse_effects", [])):
		if not (raw_fx is Dictionary):
			continue
		var fx: Dictionary = raw_fx as Dictionary
		match str(fx.get("type", "")):
			"attitude":
				if bool(fx.get("when_hostile_only", false)) and InteractionRules.attitude_band(_gd, int(npc.get("attitude", 0))) != "hostile":
					continue
				var amt: int = int(fx.get("amount", 0))
				if fx.has("righteous_amount") and (n_held.has("temple_raised") or n_held.has("devout") or n_held.has("just")):
					amt = int(fx.righteous_amount)
				elif fx.has("demonic_amount") and n_held.has("demonic_path"):
					amt = int(fx.demonic_amount)
				_apply_attitude(npc, amt, effect_lines)
			"set_flag":
				var fn: String = str(fx.get("flag", ""))
				if fn != "":
					set_npc_flag(npc, fn, true)


func _spend_focus_time(session: GameSession, amount: float, effect_lines: Array) -> void:
	if amount <= 0.0:
		return
	session.season_time_used = clampf(session.season_time_used + amount, 0.0, 1.0)
	session.player.season_time_used = session.season_time_used
	effect_lines.append("Spent %.2f season (focus yield now %d%%)." % [amount, int(roundf(InteractionRules.focus_yield_share(session.season_time_used) * 100.0))])


func _complete_visits(player: Character, npc_id: String, effect_lines: Array, npc_name: String) -> Array:
	var done: Array = []
	for raw_v in player.active_visits:
		if not (raw_v is Dictionary):
			continue
		var v: Dictionary = raw_v as Dictionary
		if str(v.get("npc_id", "")) == npc_id and not bool(v.get("completed", false)):
			v["completed"] = true
			done.append(str(v.get("quest_id", "")))
			effect_lines.append("Visit stage completed: met %s." % npc_name)
	return done


func _first_effect(verb: Dictionary, eff_type: String) -> Dictionary:
	for raw in Array(verb.get("accept_effects", [])):
		if raw is Dictionary and str((raw as Dictionary).get("type", "")) == eff_type:
			return raw as Dictionary
	return {}


func _is_haggled(npc: Dictionary, season_now: int) -> bool:
	var flags: Dictionary = InteractionRules.npc_flags(npc)
	return flags.has("haggled_season") and int(flags.get("haggled_season", -9999)) == season_now


func _talent_tier(player: Character, talent_id: String) -> int:
	var nt: Dictionary = Dictionary(player.npc_traits)
	for entry in Array(nt.get("talent", [])):
		if entry is Dictionary and str((entry as Dictionary).get("id", "")) == talent_id:
			return clampi(int((entry as Dictionary).get("tier", 1)), 1, 3)
		if str(entry) == talent_id:
			return 1
	return 1


func _known_others(player: Character, exclude_npc_id: String) -> Array:
	var seen := {}
	var out: Array = []
	for pid in player.met_list:
		var s: String = str(pid)
		if s == "" or s == player.id or s == exclude_npc_id or seen.has(s):
			continue
		var rec: Dictionary = _db.get_record("people", s)
		if not rec.is_empty() and bool(rec.get("alive", false)) and not bool(rec.get("is_beast", false)):
			seen[s] = true
			out.append(rec)
	for p in _db.living():
		var s: String = str(p.id)
		if s == player.id or s == exclude_npc_id or seen.has(s) or bool(p.get("is_beast", false)):
			continue
		if bool(p.get("met_player", false)):
			seen[s] = true
			out.append(p)
	return out


func _extra_score_mods(verb_id: String, player_id: String, npc: Dictionary) -> Dictionary:
	var out: Dictionary = {}
	if verb_id == "help":
		var npc_id: String = str(npc.get("id", ""))
		for loan in loans_of(_db, player_id):
			if str(loan.get("status", "")) == "overdue" and str(loan.get("lender_id", "")) != npc_id:
				var lender: Dictionary = _db.get_record("people", str(loan.lender_id))
				if _npc_knows_lender(npc, lender):
					out["Unpaid overdue loan"] = -30.0
					break
	return out


func _npc_knows_lender(npc: Dictionary, lender: Dictionary) -> bool:
	if lender.is_empty():
		return false
	if str(npc.get("sect_id", "")) != "" and str(npc.get("sect_id", "")) == str(lender.get("sect_id", "")):
		return true
	if str(npc.get("location_id", "")) != "" and str(npc.get("location_id", "")) == str(lender.get("location_id", "")):
		return true
	return Ties.enabled(_gd) and not _db.tie_between(str(npc.id), str(lender.id)).is_empty()


func _player_win_share(player: Character, sh: StatSheet, npc: Dictionary) -> float:
	var enemy: Character = Character.from_dict(npc)
	if _resolver != null and bool(_gd.combat().get("fight_engine", {}).get("enabled", false)):
		var odds: Dictionary = _resolver.fight_odds(player, sh, enemy)
		if bool(odds.get("ran", false)):
			return float(odds.chance)
	var mine: float = CombatPower.compute(player, _gd, _db, sh).total
	var theirs: float = maxf(1.0, _builds.power_of(enemy))
	var ratio: float = mine / maxf(mine + theirs, 1.0)
	return clampf(ratio, 0.05, 0.95)


func _reveal_unknown_place(session: GameSession, npc: Dictionary) -> String:
	if session.knowledge == null:
		return ""
	var k: MapKnowledge = session.knowledge
	# 1. Explicit places known or visited by this NPC.
	var candidates: Array = []
	for pid in Array(npc.get("known_places", [])) + Array(npc.get("visited", [])):
		var s: String = str(pid)
		if s != "" and not candidates.has(s):
			candidates.append(s)
	for pid in candidates:
		var p: Dictionary = _db.get_record("places", str(pid))
		if not p.is_empty() and not bool(p.get("hidden", false)) and not k.knows_place(str(pid)):
			k.places[str(pid)] = true
			return str(pid)
	# 2. Non-hidden places in NPC's home/current region.
	var cur_place: Dictionary = _db.get_record("places", str(npc.get("location_id", session.player.location_id)))
	var reg_id: String = str(cur_place.get("region_id", ""))
	if reg_id != "":
		for p in _db.all("places"):
			if str(p.get("region_id", "")) == reg_id and not bool(p.get("hidden", false)) and not k.knows_place(str(p.id)):
				k.places[str(p.id)] = true
				return str(p.id)
	return ""


func _pull_news_item(session: GameSession, npc: Dictionary, season_now: int) -> Dictionary:
	# 1. An unknown place the NPC knows.
	var pid: String = _reveal_unknown_place(session, npc)
	if pid != "":
		var pname: String = _place_name(pid)
		return {
			"kind": "place",
			"place_id": pid,
			"rumour": "địa danh %s ở gần đây rất đáng lưu ý" % pname,
			"note": "Learned of place: %s." % pname,
		}
	# 2. An explicit clue carried by the NPC or a rumour via Discovery.
	if session.knowledge != null:
		var clues: Array = Array(npc.get("clues", []))
		for raw_c in clues:
			if not (raw_c is Dictionary):
				continue
			var c: Dictionary = raw_c as Dictionary
			var slot: String = str(c.get("slot", ""))
			if slot != "" and not session.knowledge.clues.any(func(x): return str(x.get("slot", "")) == slot):
				var copy_c: Dictionary = c.duplicate(true)
				copy_c["heard_from"] = str(npc.id)
				session.knowledge.clues.append(copy_c)
				if bool(copy_c.get("false", false)) and NpcTraits.held(npc).has("deceitful"):
					set_npc_flag(npc, "passed_false_clue", true)
				return {"kind": "clue", "slot": slot, "rumour": "một manh mối bí ẩn trong vùng", "note": "Learned a clue from %s." % str(npc.name)}
	# 3. A recent (within last 4 seasons) WorldDB event mentioning the NPC's region, place, or sect.
	var seen_ev: Array = Array(npc.get("shared_news_events", []))
	var spyr: int = int(_gd.cultivation_rules().seasons_per_year)
	var npc_place: String = str(npc.get("location_id", ""))
	var npc_sect: String = str(npc.get("sect_id", ""))
	var all_ev: Array = _db.all("events")
	for i in range(all_ev.size() - 1, -1, -1):
		var ev: Dictionary = all_ev[i]
		var eid: String = str(ev.get("id", ""))
		if eid == "" or seen_ev.has(eid):
			continue
		var ev_abs: int = int(ev.get("year", 0)) * spyr + int(ev.get("season", 0))
		if season_now - ev_abs > 4 or ev_abs > season_now:
			continue
		var etype: String = str(ev.get("type", ""))
		if etype.begins_with("interaction_") or etype == "player_born":
			continue
		var relevant: bool = Array(ev.get("places", [])).has(npc_place) or (npc_sect != "" and Array(ev.get("people", [])).has(npc_sect))
		if relevant and str(ev.get("text", "")).strip_edges() != "":
			seen_ev.append(eid)
			npc["shared_news_events"] = seen_ev
			var txt: String = str(ev.text).trim_suffix(".")
			return {"kind": "event", "event_id": eid, "rumour": txt, "note": "News: %s." % txt}
	return {}


func _pull_history_lore(session: GameSession, npc: Dictionary) -> Dictionary:
	var seen: Array = Array(npc.get("shared_history_events", []))
	var lines: Array = []
	var npc_sect: String = str(npc.get("sect_id", ""))
	var npc_place: String = str(npc.get("location_id", ""))
	var npc_id: String = str(npc.id)
	var all_ev: Array = _db.all("events")
	for i in range(all_ev.size() - 1, -1, -1):
		var ev: Dictionary = all_ev[i]
		var eid: String = str(ev.get("id", ""))
		if eid == "" or seen.has(eid):
			continue
		var txt: String = str(ev.get("text", "")).strip_edges()
		if txt == "":
			continue
		var match_it: bool = Array(ev.get("people", [])).has(npc_id) \
			or (npc_sect != "" and Array(ev.get("people", [])).has(npc_sect)) \
			or Array(ev.get("places", [])).has(npc_place)
		if match_it:
			seen.append(eid)
			lines.append(txt.trim_suffix("."))
			if lines.size() >= 2:
				break
	if not lines.is_empty():
		npc["shared_history_events"] = seen
		return {"kind": "events", "lines": lines, "summary": "; ".join(lines)}
	var pid: String = _reveal_unknown_place(session, npc)
	if pid != "":
		return {"kind": "place", "place_id": pid, "summary": "di tích cổ %s từng xuất hiện trong sử sách" % _place_name(pid)}
	return {}


func _pick_curio(player: Character, item_id: String) -> Dictionary:
	if item_id != "":
		var it: Dictionary = _db.get_record("items", item_id)
		if not it.is_empty() and str(it.get("owner_id", "")) == player.id and not player.equipped.has(item_id) and ItemRarity.of(_gd, it) >= 2:
			if not (str(it.get("kind", "")) == "herb" and int(it.get("plot", -1)) >= 0):
				return it
		return {}
	for it in _db.items_of(player.id):
		if player.equipped.has(str(it.id)):
			continue
		if str(it.get("kind", "")) == "herb" and int(it.get("plot", -1)) >= 0:
			continue
		if ItemRarity.of(_gd, it) >= 2:
			return it
	return {}


func _transfer_single_item(item: Dictionary, new_owner_id: String) -> String:
	if int(item.get("qty", 1)) > 1:
		item["qty"] = int(item.qty) - 1
		var copy: Dictionary = item.duplicate(true)
		copy.erase("id")
		copy["qty"] = 1
		copy["owner_id"] = new_owner_id
		return _db.add("items", copy)
	_db.give_item(str(item.id), new_owner_id)
	return str(item.id)


func _make_manual_copy(def: Dictionary, owner_id: String) -> Dictionary:
	var tier_rank: int = int(def.get("tier", 0))
	var tier_rec: Dictionary = _gd.cong_phap_tier(tier_rank)
	return {
		"kind": "cong_phap",
		"name": str(def.get("name", "Bí tịch")),
		"tech_id": str(def.get("tech_id", "")),
		"tier": tier_rank,
		"tier_name": str(tier_rec.get("name", "")),
		"tech_kind": str(def.get("tech_kind", "main")),
		"names": Array(def.get("names", [])).duplicate(),
		"layers": int(def.get("layers", int(tier_rec.get("layers", 3)))),
		"bonuses": Array(def.get("bonuses", [])).duplicate(true),
		"passives": Array(def.get("passives", [])).duplicate(true),
		"effects": Array(def.get("effects", [])).duplicate(true),
		"abilities": Array(def.get("abilities", [])).duplicate(true),
		"seal_clusters": Array(def.get("seal_clusters", [])).duplicate(),
		"origin": str(def.get("origin", "copied")),
		"value": int(tier_rec.get("value", 50)),
		"owner_id": owner_id,
	}


func _add_loan(lender_id: String, borrower_id: String, amount: int, taken_season: int, due_season: int) -> Dictionary:
	var rec: Dictionary = _db.get_record("world", LOANS_REC)
	if rec.is_empty():
		rec = {"id": LOANS_REC, "next_id": 1, "items": []}
		_db.add("world", rec)
	var lid: int = int(rec.get("next_id", Array(rec.items).size() + 1))
	rec["next_id"] = lid + 1
	var loan := {
		"id": "loan_%d" % lid,
		"lender_id": lender_id,
		"borrower_id": borrower_id,
		"amount": amount,
		"taken_season": taken_season,
		"due_season": due_season,
		"status": "open",
		"follow_up_scheduled": false,
	}
	(rec.items as Array).append(loan)
	return loan


func _find_loan(loan_id: String) -> Dictionary:
	for loan in loans_of(_db):
		if str(loan.get("id", "")) == loan_id:
			return loan
	return {}


static func _refresh_loan_flags(db: WorldDB, borrower_id: String, lender_id: String) -> void:
	var lender: Dictionary = db.get_record("people", lender_id)
	if lender.is_empty():
		return
	var any_open: bool = false
	var any_overdue: bool = false
	for loan in loans_of(db, borrower_id, lender_id):
		var st: String = str(loan.get("status", ""))
		if st == "open" or st == "overdue":
			any_open = true
		if st == "overdue":
			any_overdue = true
	if not any_open:
		clear_npc_flag(lender, "owes_loan")
	if not any_overdue:
		clear_npc_flag(lender, "owes_loan_overdue")


func _log_deed(year_now: int, season_in_year: int, kind: String, text: String, people: Array, places: Array, items: Array = [], data: Dictionary = {}) -> String:
	return _db.log_event(year_now, season_in_year, kind, text, people, places, items, data)


func _verb_options(verb_id: String, player: Character, player_sheet: StatSheet, npc: Dictionary, season_now: int, _knowledge: MapKnowledge) -> Array:
	match verb_id:
		"about":
			return _known_others(player, str(npc.id)).map(func(p): return {"id": str(p.id), "name": str(p.name)})
		"gift":
			var giftable: Array = []
			for it in _db.items_of(player.id):
				if player.equipped.has(str(it.id)):
					continue
				if str(it.get("kind", "")) == "herb" and int(it.get("plot", -1)) >= 0:
					continue
				giftable.append({"id": str(it.id), "name": str(it.name), "value": _items.value_of(it)})
			return giftable
		"teach":
			var pct: float = InteractionRules.teaching_insight_pct(_gd, int(npc.get("realm_index", 0)), player.realm_index)
			var opts: Array = [{"id": "insight", "label": "Insight (+%d%% cultivation speed next season)" % int(roundf(pct))}]
			for m in InteractionRules.teachable_manuals(_gd, npc, player):
				opts.append({"id": "manual:" + str(m.tech_id), "label": "Manual: %s" % str(m.name), "tech_id": str(m.tech_id)})
			return opts
		"help":
			var opts_h: Array = [
				{"id": "loan", "label": "Loan (max %d linh thạch)" % InteractionRules.loan_cap(_gd, npc)},
				{"id": "guide", "label": "Guide"},
			]
			if str(npc.get("sect_id", "")) != "" and player.sect_id != str(npc.get("sect_id", "")):
				opts_h.append({"id": "introduction", "label": "Sect introduction"})
			return opts_h
		"repay":
			return open_obligations(player.id, str(npc.id), season_now)
		"trade_curio":
			var curios: Array = []
			for it in _db.items_of(player.id):
				if player.equipped.has(str(it.id)):
					continue
				if str(it.get("kind", "")) == "herb" and int(it.get("plot", -1)) >= 0:
					continue
				if ItemRarity.of(_gd, it) >= 2:
					curios.append({"id": str(it.id), "name": str(it.name), "rarity": ItemRarity.of(_gd, it)})
			return curios
		"trade":
			var offer: Dictionary = InteractionRules.trade_items_for(_gd, _db, npc)
			var hag: bool = _is_haggled(npc, season_now)
			var rows: Array = []
			for it in offer.shown:
				var p_info: Dictionary = InteractionRules.haggle_prices(_gd, _market.buy_price(player, player_sheet, it, player.location_id), _market.sell_price(player, player_sheet, it, player.location_id), hag)
				rows.append({"id": str(it.id), "name": str(it.name), "price": int(p_info.buy), "locked": false})
			for lk in offer.locked:
				rows.append({"id": str(lk.item.id), "name": str(lk.item.name), "locked": true, "band_needed": str(lk.band_needed)})
			return rows
	return []
