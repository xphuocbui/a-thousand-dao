class_name EventResolver
extends RefCounted
## Resolves a normalized event choice with engine rules only: pays "always" costs, rolls
## the check (thiên phú vs difficulty, or a duel against the event NPC with situation,
## Alarm Array step-up, ground_tags, no_heal, and cultivator Mercy), then applies the
## outcome's effects under chain/story budgets and Formula K money conservation
## (design/gdd/event-engine.md Rules 11-20; Formulas C; AC-EV-15..37, AC-WG-56).
## Also resolves NPC-capable events off-screen via [method resolve_npc] using
## [method NpcTraits.pick_choice] and strictly skipping player-only effects.
## Data: events_budgets.json (check, pacing, chain_budgets, player_only_effects).
##
## Usage:
## [codeblock]
## var r := EventResolver.new(gd, db, builds, items)
## var ok: Dictionary = r.can_choose(c, event, 0)
## var result: Dictionary = r.resolve(c, sheet, rng, event, 0)
## for line in result.lines: print(line)
## [/codeblock]

const _EventStore = preload("res://src/gameplay/events/event_store.gd")
const _EventConditions = preload("res://src/gameplay/events/event_conditions.gd")
const _EventBudget = preload("res://src/gameplay/events/event_budget.gd")

var _gd: GameData
var _db: WorldDB
var _builds: BuildGenerator
var _items: ItemFactory
var _alchemy: Alchemy
## Set by the session: Callable(kind: String) -> String, unseals a cluster and returns its line.
var unseal_fn: Callable
## Runs real fights when combat_rules.json fight_engine.enabled is on (ADR-0001 step 4); made on first use.
var _service: CombatService
## The last event fight, with its timeline log (the debug terminal's `fightlog`), or null; its two sides' names.
var last_fight: FightResult
var last_fight_names: Array = []
## Metadata of the last fight request passed to Combat (situation per side, ground_tags, no_heal, alarm_stepped).
var last_fight_request: Dictionary = {}
## Power Rankings rule 12: when set and enabled, a fight against a rated NPC moves both offsets at once (Formulas D).
var ratings: RatingService
## Callable() -> [game seed, season key] for Power Rankings' keyed event-fight seeds (rule 13); set by GameSession.
var rating_clock: Callable
## Formations rule 11: the last event fight's diagram Breakdown lines (both sides).
var last_diagram_lines: Array = []
## Optional callback [code]Callable(npc_id: String, cause: String) -> void[/code] set by GameSession
## so mercy/kill post-duel choices can resolve an NPC death through WorldTicker without a cyclic reference.
var kill_npc_fn: Callable


func _init(gd: GameData, db: WorldDB, builds: BuildGenerator, items: ItemFactory) -> void:
	_gd = gd
	_db = db
	_builds = builds
	_items = items
	_alchemy = Alchemy.new(gd, db, items)


## True if the player can afford the choice's "always" costs. Returns {ok, reason}.
func can_choose(c: Character, event: Dictionary, index: int) -> Dictionary:
	if index < 0 or index >= event.choices.size():
		return {"ok": false, "reason": "choose 1..%d" % event.choices.size()}
	for fx in event.choices[index].always:
		if fx.type == "linh_thach" and float(fx.amount) < 0.0 and c.linh_thach < int(-float(fx.amount)):
			return {"ok": false, "reason": "needs %d linh thạch (you have %d)" % [int(-float(fx.amount)), c.linh_thach]}
	return {"ok": true, "reason": ""}


## Chance (0..1) of passing a stat check, as a breakdown. [param evade] adds stealth
## (fleeing or hiding checks).
func stat_check_chance(c: Character, sheet: StatSheet, stat: String, difficulty: float, evade: bool = false) -> Breakdown:
	var cfg: Dictionary = _gd.budgets().check
	var v: float = sheet.effective(stat, c) if sheet != null else float(c.base_stat(stat))
	var kv: float = sheet.effective("khi_van", c) if sheet != null else float(c.base_stat("khi_van"))
	var b := Breakdown.new("Check chance")
	b.base("Base", float(cfg.base))
	b.add("%s %d vs difficulty %d" % [stat, int(v), int(difficulty)], (v - difficulty) * float(cfg.per_point))
	if stat != "khi_van":
		b.add("Khí vận %d" % int(kv), (kv - float(cfg.khi_van_neutral)) * float(cfg.khi_van_per_point))
	if evade and sheet != null and sheet.total("stealth") != 0.0:
		b.add("Stealth %d (evading)" % int(sheet.total("stealth")), sheet.total("stealth") * float(cfg.get("stealth_per_point", 0.0)))
	b.clamp_to(float(cfg.min), float(cfg.max))
	return b


## Computes effective per-side combat situations for [param c] at [param place_id] given [param raw_situation]
## and [param ground_tags] (Event Engine Rule 17, AC-EV-31).
## When [code]ground_tags[/code] includes [code]"own_abode"[/code] and [param c] has an active Alarm Array
## at their home abode, side A steps up one level ([code]BLIND -> AMBUSH -> FORESEEN[/code]) while side B
## stays at [param raw_situation]. Returns [code]{a: int, b: int, alarm_stepped: bool}[/code].
static func effective_situations(c: Character, db: WorldDB, raw_situation: int, ground_tags: Array, place_id: String = "") -> Dictionary:
	var sit_a: int = raw_situation
	var sit_b: int = raw_situation
	var stepped: bool = false
	var at_abode: bool = false
	for tg in ground_tags:
		if str(tg) == "own_abode":
			at_abode = true
			break
	if at_abode and c != null and has_active_alarm_array(c, db, place_id if place_id != "" else c.location_id):
		if sit_a == FightRequest.Situation.BLIND:
			sit_a = FightRequest.Situation.AMBUSH
			stepped = true
		elif sit_a == FightRequest.Situation.AMBUSH:
			sit_a = FightRequest.Situation.FORESEEN
			stepped = true
	return {"a": sit_a, "b": sit_b, "alarm_stepped": stepped}


## True when [param c] holds an active (non-dormant) Alarm Array at [param place_id].
static func has_active_alarm_array(c: Character, db: WorldDB, place_id: String) -> bool:
	var place: Dictionary = db.get_record("places", place_id) if (db != null and place_id != "") else {}
	var qi: Dictionary = Dictionary(place.get("qi", {}))
	var home: Dictionary = CaveAbode.home_rec(qi, c.id) if not qi.is_empty() else {}
	var dormant: Array = Array(home.get("dormant", []))
	for fid in ["canh_gioi_tran", "alarm_array"]:
		if int(c.formations.get(fid, 0)) > 0 and not dormant.has("f:" + fid):
			return true
		var l1: Dictionary = Dictionary(Dictionary(qi.get("layer1", {})).get(c.id, {}))
		if int(l1.get(fid, 0)) > 0 and not dormant.has("w:" + fid):
			return true
	if bool(Dictionary(qi.get("abode", {})).get("alarm_array", false)):
		return true
	if db != null and _EventStore.has_flag(db, c.id, "alarm_array", 0):
		return true
	return false


## Resolves a choice for a player character.
## Returns {success, lines: [String], items: [ids], died, check_line, outcome_text,
## mercy_npc_id, mercy_pending, mercy_target_id, warnings, paid, budget_empty,
## scheduled_followups, story_actions, uncovered_chronicles}.
func resolve(c: Character, sheet: StatSheet, rng: RandomNumberGenerator, event: Dictionary, index: int, opts: Dictionary = {}) -> Dictionary:
	var choice: Dictionary = event.choices[index]
	var lines: Array = []
	var items: Array = []
	var warnings: Array = []
	var spy: int = int(_gd.cultivation_rules().get("seasons_per_year", 4))
	var year: int = int(opts.get("year", 0))
	var season: int = int(opts.get("season", 0))
	if year == 0 and _db != null and _db.has_record("world", "w_meta"):
		var now_t: int = Ties.now(_db)
		if now_t > 0:
			year = now_t / spy
			season = now_t % spy
	var now_season: int = int(opts.get("now_season", year * spy + season))
	var rctx := {
		"year": year,
		"season": season,
		"now_season": now_season,
		"warnings": warnings,
		"paid": 0,
		"had_zero_grant": false,
		"scheduled_followups": [],
		"story_actions": [],
		"uncovered_chronicles": [],
		"map_knowledge": opts.get("map_knowledge", null),
		"story_start_fn": opts.get("story_start_fn", Callable()),
		"story_stage_fn": opts.get("story_stage_fn", Callable()),
		"story_end_fn": opts.get("story_end_fn", Callable()),
	}

	for fx in choice.always:
		lines.append(_apply(c, sheet, rng, event, fx, items, rctx))

	var success: bool = true
	var check_line: String = ""
	var chk: Dictionary = Dictionary(choice.get("check", {"type": "none"}))
	var chk_type: String = str(chk.get("type", "none"))
	var used: Array = Talismans.apply_for_check(c, _gd, _db, sheet, chk_type, bool(chk.get("evade", false)), true, rng)
	if not used.is_empty():
		lines.append("used %s" % ", ".join(used))
	match chk_type:
		"stat":
			var chance: float = stat_check_chance(c, sheet, str(chk.stat), float(chk.difficulty), bool(chk.get("evade", false))).total
			var roll: float = rng.randf()
			success = roll < chance
			check_line = "%s check: %.0f%% chance, roll %.0f -> %s" % [str(chk.stat), chance * 100.0, roll * 100.0, "SUCCESS" if success else "FAILURE"]
			if not success and c.has_capability(19) and not c.cap_used.has("19"):
				c.cap_used["19"] = true
				roll = rng.randf()
				success = roll < chance
				check_line += "; Khí Vận Chi Tử rerolls %.0f -> %s" % [roll * 100.0, "SUCCESS" if success else "FAILURE"]
		"combat":
			var enemy_rec: Dictionary = _db.get_record("people", str(chk.enemy))
			var enemy := Character.from_dict(enemy_rec)
			var sit: int = _parse_situation(str(chk.get("situation", event.get("situation", "foreseen"))))
			var gtags: Array = Array(chk.get("ground_tags", event.get("ground_tags", [])))
			var no_heal: bool = bool(chk.get("no_heal", event.get("no_heal", false)))
			var fought: Dictionary = fight_check(c, sheet, enemy, rng, sit, gtags, no_heal)
			if fought.ran:
				success = fought.win
				check_line = fought.line
			else:
				var mine: float = CombatPower.compute(c, _gd, _db, sheet).total
				var theirs: float = _builds.power_of(enemy)
				var duel: Dictionary = CombatPower.duel(mine, theirs, sheet.effective("khi_van", c), float(enemy.base_stat("khi_van")), _gd, rng)
				success = duel.win
				check_line = "Combat: chiến lực %.0f vs %s %.0f -> %.0f%% chance, roll %.0f -> %s" % [mine, enemy.name, theirs, duel.chance * 100.0, duel.roll * 100.0, "VICTORY" if success else "DEFEAT"]
				if str(fought.line) != "":
					check_line += " (%s)" % fought.line
			if success and not enemy.is_beast and c.has_capability(9):
				var p9: Dictionary = _gd.capability(9).params
				var drained: Dictionary = CultivationRules.add_tu_vi(c, _gd, float(p9.stage_frac) * CultivationRules.stage_cost(c, _gd))
				CharacterRules.add_tam_ma(c, _gd, sheet, float(p9.tam_ma))
				lines.append("Hấp Tinh Đại Pháp: tu vi +%.0f" % (float(drained.gained) - float(drained.wasted)))
			if success and enemy.is_beast:
				var tame: Dictionary = BeastKeeper.new(_gd, _db).try_tame(c, sheet, rng, str(chk.enemy))
				if str(tame.get("message", "")) != "":
					lines.append(tame.message)
	if check_line != "":
		lines.push_front(check_line)

	var outcome: Dictionary = choice.success if success else choice.failure
	for fx in outcome.effects:
		lines.append(_apply(c, sheet, rng, event, fx, items, rctx))

	var raw_otext: String = str(outcome.get("text", ""))
	if bool(rctx.had_zero_grant) and str(outcome.get("empty_text", "")).strip_edges() != "":
		raw_otext = str(outcome.empty_text)
	var outcome_text: String = raw_otext.replace("{paid}", str(int(rctx.paid)))

	var mercy_npc_id: String = ""
	if success and chk_type == "combat" and (bool(chk.get("mercy_allowed", false)) or _has_mercy_choice(event)):
		var target_id: String = str(chk.enemy)
		var target_rec: Dictionary = _db.get_record("people", target_id)
		if not target_rec.is_empty() and bool(target_rec.get("alive", false)) and not bool(target_rec.get("is_beast", false)):
			mercy_npc_id = target_id

	var died: bool = false
	if c.vitality <= 0.0 and bool(_gd.session().death.khi_huyet_zero_dies):
		if c.has_capability(5) and not c.cap_used.has("5"):
			c.cap_used["5"] = true
			c.vitality = float(_gd.breakthrough_rules().vitality_floor)
			CultivationRules.lose_stage(c, _gd)
			lines.append("Linh Hồn Xuất Khiếu: your soul slips free; you live, one stage lower.")
		else:
			c.alive = false
			c.death_cause = "Tử nạn: %s" % event.title
			died = true

	return {
		"success": success,
		"lines": lines.filter(func(l): return l != ""),
		"items": items,
		"died": died,
		"check_line": check_line,
		"outcome_text": outcome_text,
		"mercy_npc_id": mercy_npc_id,
		"mercy_pending": mercy_npc_id != "",
		"mercy_target_id": mercy_npc_id,
		"warnings": warnings,
		"paid": int(rctx.paid),
		"budget_empty": bool(rctx.had_zero_grant),
		"scheduled_followups": rctx.scheduled_followups,
		"story_actions": rctx.story_actions,
		"uncovered_chronicles": rctx.uncovered_chronicles,
	}


## Applies the player's post-duel cultivator Mercy decision (Rule 17, AC-EV-30):
## [param kill] == false spares the foe and sets [code]spared_by[/code] = [param c].id;
## [param kill] == true kills the foe via [member kill_npc_fn] (or directly with a WorldDB record).
func resolve_mercy(c: Character, target_id: String, kill: bool, year: int = 0, season: int = 0) -> Dictionary:
	var rec: Dictionary = _db.get_record("people", target_id)
	if rec.is_empty() or not bool(rec.get("alive", false)):
		return {"ok": false, "killed": false, "target_id": target_id, "lines": ["Đối thủ không còn sống."]}
	if not kill:
		_EventStore.set_flag(_db, target_id, "spared_by", -1, c.id)
		var fl: Dictionary = Dictionary(rec.get("flags", {}))
		fl["spared_by"] = c.id
		rec["flags"] = fl
		var line: String = "%s tha mạng cho %s." % [c.name, str(rec.get("name", target_id))]
		_db.log_event(year, season, "mercy_spare", line, [c.id, target_id], [c.location_id], [], {"spared_by": c.id})
		return {"ok": true, "killed": false, "target_id": target_id, "lines": [line]}
	var cause: String = "Bị %s kết liễu" % c.name
	if kill_npc_fn.is_valid():
		kill_npc_fn.call(target_id, cause)
	else:
		rec["alive"] = false
		rec["death_cause"] = cause
		rec["death_year"] = year
		_db.log_event(year, season, "mercy_kill", "%s kết liễu %s." % [c.name, str(rec.get("name", target_id))], [c.id, target_id], [c.location_id], [], {"killer": c.id})
	return {"ok": true, "killed": true, "target_id": target_id, "lines": ["%s kết liễu %s." % [c.name, str(rec.get("name", target_id))]]}


## The fight engine's combat check (ADR-0001 step 4; Event Engine Rule 17, AC-EV-29, AC-EV-31):
## compiles both sides via [method FighterCompiler.compile], applies Alarm Array situation step-up
## when [code]ground_tags[/code] includes [code]"own_abode"[/code], passes [param ground_tags] and
## [param no_heal] to [FightRequest], and takes one draw from [param rng] (ADR-0002 decision 3).
func fight_check(
	c: Character,
	sheet: StatSheet,
	enemy: Character,
	rng: RandomNumberGenerator,
	situation: int = FightRequest.Situation.FORESEEN,
	ground_tags: Array = [],
	no_heal: bool = false
) -> Dictionary:
	var sits: Dictionary = effective_situations(c, _db, situation, ground_tags, c.location_id)
	last_fight_request = {
		"situation_raw": situation,
		"situation_a": int(sits.a),
		"situation_b": int(sits.b),
		"ground_tags": ground_tags.duplicate(),
		"no_heal": no_heal,
		"alarm_stepped": bool(sits.alarm_stepped),
	}
	if not bool(_gd.combat().get("fight_engine", {}).get("enabled", false)):
		return {"ran": false, "win": false, "line": ""}
	var errors: Array = []
	var req := FightRequest.new()
	req.situation = int(sits.a) as FightRequest.Situation
	var typed_tags: Array[StringName] = []
	for tg in ground_tags:
		typed_tags.append(StringName(str(tg)))
	req.ground_tags = typed_tags
	req.no_heal = no_heal
	req.a = FighterCompiler.compile(c, _gd, _db, sheet, [], errors)
	var enemy_sheet: StatSheet = _builds.sheet_of(enemy)
	req.b = FighterCompiler.compile(enemy, _gd, _db, enemy_sheet, [], errors)   # with its Đạo Đồ
	if req.a == null or req.b == null:
		return {"ran": false, "win": false, "line": "fight engine could not compile: %s" % "; ".join(errors)}
	# Formations rules 1-12: each side's combat diagram compiles under that side's effective situation (AC-EV-31)
	var fuel_due: Array = []   # Formations rule 9: the lay fuel is paid only once the fight has run
	last_diagram_lines = Diagrams.compile_for(_gd, _db, c, req.a, sheet, int(sits.a), -1, fuel_due) \
		+ Diagrams.compile_for(_gd, _db, enemy, req.b, enemy_sheet, int(sits.b), -1, fuel_due)
	var rated: bool = ratings != null and ratings.enabled() and enemy.id != "" and _db.has_record("people", enemy.id) \
		and rating_clock.is_valid()
	if rated:   # Power Rankings rule 13 / ADR-0003 decision 4: a rated pair fight takes a keyed seed, no session draw
		var clock: Array = rating_clock.call()
		req.fight_seed = ratings.event_fight_seed(c.id, enemy.id, int(clock[0]), int(clock[1]))
	else:
		req.fight_seed = rng.randi()
	req.log_enabled = true   # event fights are rare; the terminal prints the log
	if _service == null:
		_service = CombatService.new(CombatConstants.from_game_data(_gd))
	var r: FightResult = _service.resolve(req)
	if r == null:
		return {"ran": false, "win": false, "line": "fight engine refused the fight: %s" % "; ".join(_service.errors)}
	for due in fuel_due:
		Diagrams.pay_fuel(_db, due[0], int(due[1]))
	last_fight = r
	last_fight_names = [c.name, enemy.name]
	var code: String = r.win_code()
	if rated:
		var score: float = {"A": 1.0, "B": 0.0}.get(code, 0.5)
		ratings.apply_fight(ratings.ensure(c), ratings.refresh_person(_db.get_record("people", enemy.id)), score)
	var word: String = {"A": "VICTORY", "B": "DEFEAT", "draw": "DRAW (a failure)", "time": "TIME LIMIT (a failure)"}[code]
	return {
		"ran": true,
		"win": code == "A",
		"code": code,
		"line": "Combat: fight against %s, %.1f s -> %s" % [enemy.name, r.seconds, word],
	}


## The fight engine's odds for [param c] against [param enemy] (the event card, ADR-0001 step 4).
func fight_odds(c: Character, sheet: StatSheet, enemy: Character, situation: int = FightRequest.Situation.FORESEEN, ground_tags: Array = []) -> Dictionary:
	var fe: Dictionary = _gd.combat().get("fight_engine", {})
	if not bool(fe.get("enabled", false)):
		return {"ran": false, "chance": 0.0, "samples": 0}
	var a: FighterProfile = FighterCompiler.compile(c, _gd, _db, sheet)
	var b: FighterProfile = FighterCompiler.compile(enemy, _gd, _db, _builds.sheet_of(enemy))
	if a == null or b == null:
		return {"ran": false, "chance": 0.0, "samples": 0}
	var sits: Dictionary = effective_situations(c, _db, situation, ground_tags, c.location_id)
	Diagrams.compile_for(_gd, _db, c, a, sheet, int(sits.a), -1, [])
	Diagrams.compile_for(_gd, _db, enemy, b, _builds.sheet_of(enemy), int(sits.b), -1, [])
	if _service == null:
		_service = CombatService.new(CombatConstants.from_game_data(_gd))
	var keyed := RandomNumberGenerator.new()
	keyed.seed = RngUtils.stable_hash("odds:%s:%s" % [c.id, enemy.id])
	var n: int = maxi(1, int(fe.get("odds_samples", 24)))
	var wins := 0
	for i in n:
		var req := FightRequest.new()
		req.a = a
		req.b = b
		req.fight_seed = keyed.randi()
		var r: FightResult = _service.resolve(req)
		if r != null and r.win_code() == "A":
			wins += 1
	return {"ran": true, "chance": float(wins) / float(n), "samples": n}


## Resolves an NPC-capable event off-screen for [param npc_rec] (Rules 19-20, AC-EV-33..37).
## Uses [method NpcTraits.pick_choice] (F2 weights) with keyed streams (ADR-0002 decision 4),
## skips player-only effects, preserves strict [MoneyLedger] conservation, and writes one WorldDB record.
func resolve_npc(
	npc_rec: Dictionary,
	event: Dictionary,
	year: int,
	season: int,
	game_seed: int,
	ratings_svc: RatingService = null,
	player_id: String = ""
) -> Dictionary:
	var cfg: Dictionary = _gd.budgets()
	var spy: int = int(_gd.cultivation_rules().get("seasons_per_year", 4))
	var abs_season: int = year * spy + season
	var pid: String = str(npc_rec.get("id", ""))
	var eid: String = str(event.get("template_id", event.get("id", "npc_ev")))
	var choices: Array = Array(event.get("choices", []))
	if choices.is_empty():
		return {"ok": false, "choice_index": -1, "event_log_id": ""}

	# Filter affordable choices for the NPC.
	var purse: float = float(npc_rec.get("linh_thach", 0.0))
	var pick_list: Array = []
	var index_map: Array = []
	for i in choices.size():
		var ch: Dictionary = choices[i]
		var can_pay: bool = true
		for fx in Array(ch.get("always", [])):
			if str(fx.get("type", "")) == "linh_thach" and float(fx.get("amount", 0.0)) < 0.0:
				if purse < -float(fx.get("amount", 0.0)):
					can_pay = false
					break
		if can_pay:
			pick_list.append({"base": float(ch.get("base", 1.0)), "tags": Array(ch.get("tags", []))})
			index_map.append(i)
	if pick_list.is_empty():
		pick_list.append({"base": 1.0, "tags": Array(choices[0].get("tags", []))})
		index_map.append(0)

	var picked_local: int = NpcTraits.pick_choice(_gd, npc_rec, pick_list, "%d:%s" % [game_seed, eid], abs_season)
	var choice_idx: int = int(index_map[clampi(picked_local, 0, index_map.size() - 1)])
	var choice: Dictionary = choices[choice_idx]

	var keyed_rng := RandomNumberGenerator.new()
	keyed_rng.seed = RngUtils.stable_hash("npc_ev:%d:%s:%d:%s" % [game_seed, pid, abs_season, eid])

	var player_only: Array = Array(cfg.get("player_only_effects", []))
	var scheduled_followups: Array = []
	var warnings: Array = []

	for fx in Array(choice.get("always", [])):
		_apply_npc_effect(npc_rec, event, fx, keyed_rng, abs_season, player_only, player_id, scheduled_followups, warnings)

	var success: bool = true
	var chk: Dictionary = Dictionary(choice.get("check", {"type": "none"}))
	match str(chk.get("type", "none")):
		"stat":
			var stat_k: String = str(chk.get("stat", "khi_van"))
			var tp: Dictionary = Dictionary(npc_rec.get("thien_phu", {}))
			var sv: float = float(tp.get(stat_k, 50.0))
			var kv: float = float(tp.get("khi_van", 50.0))
			var cc: Dictionary = cfg.check
			var chance: float = float(cc.base) + (sv - float(chk.get("difficulty", 50.0))) * float(cc.per_point)
			if stat_k != "khi_van":
				chance += (kv - float(cc.khi_van_neutral)) * float(cc.khi_van_per_point)
			chance = clampf(chance, float(cc.min), float(cc.max))
			success = keyed_rng.randf() < chance
		"combat":
			var enemy_id: String = str(chk.get("enemy", event.get("npc_id", "")))
			var enemy_rec: Dictionary = _db.get_record("people", enemy_id)
			if not enemy_rec.is_empty():
				var rs: RatingService = ratings_svc if ratings_svc != null else ratings
				if rs != null and rs.enabled():
					success = bool(rs.world_fight(npc_rec, enemy_rec, keyed_rng).win)
				else:
					var pa: float = float(npc_rec.get("power", 1.0))
					var pb: float = float(enemy_rec.get("power", 1.0))
					var ka: float = float(Dictionary(npc_rec.get("thien_phu", {})).get("khi_van", 50.0))
					var kb: float = float(Dictionary(enemy_rec.get("thien_phu", {})).get("khi_van", 50.0))
					success = bool(CombatPower.duel(pa, pb, ka, kb, _gd, keyed_rng).win)

	var outcome: Dictionary = Dictionary(choice.get("success", {})) if success else Dictionary(choice.get("failure", choice.get("success", {})))
	for fx in Array(outcome.get("effects", [])):
		_apply_npc_effect(npc_rec, event, fx, keyed_rng, abs_season, player_only, player_id, scheduled_followups, warnings)

	# Write one WorldDB record using the event's log line (Rule 20, Rule 22, AC-EV-36, AC-EV-40).
	var other_id: String = str(event.get("npc_id", ""))
	var people: Array = [pid]
	if other_id != "" and other_id != pid:
		people.append(other_id)
	var place_id: String = str(event.get("place_id", npc_rec.get("location_id", "")))
	var places: Array = [place_id] if place_id != "" else []
	var log_text: String = str(event.get("log", "")).strip_edges()
	if log_text == "":
		log_text = "%s: %s." % [str(npc_rec.get("name", pid)), str(event.get("title", eid))]
	var is_newsworthy: bool = bool(event.get("newsworthy", false))
	var reaches_news: bool = is_newsworthy or _player_knows_any(people, player_id)
	var ev_data := {
		"template_id": eid,
		"npc_event": true,
		"newsworthy": is_newsworthy,
		"news": reaches_news,
		"choice_index": choice_idx,
		"success": success,
	}
	var log_id: String = _db.log_event(year, season, "npc_event", log_text, people, places, [], ev_data)
	return {
		"ok": true,
		"choice_index": choice_idx,
		"success": success,
		"event_log_id": log_id,
		"reaches_news": reaches_news,
		"scheduled_followups": scheduled_followups,
		"warnings": warnings,
	}


# --- Player Effect Application (Rule 13, 14, 15) -------------------------------------------------

func _apply(c: Character, sheet: StatSheet, rng: RandomNumberGenerator, event: Dictionary, fx: Dictionary, items: Array, rctx: Dictionary = {}) -> String:
	var warnings: Array = Array(rctx.get("warnings", []))
	var chain_id: String = str(event.get("chain_id", ""))
	var now_season: int = int(rctx.get("now_season", 0))
	var year: int = int(rctx.get("year", 0))
	var season: int = int(rctx.get("season", 0))
	var ftype: String = str(fx.type)

	# Enforce chain/story item count cap (Formulas C, AC-EV-24)
	if chain_id != "" and Array(_gd.budgets().get("item_effect_types", ["herb", "material", "artifact", "cong_phap", "pill", "talisman", "treasure"])).has(ftype):
		if not _EventBudget.try_spend_item(_db, chain_id, warnings):
			return ""

	match ftype:
		"linh_thach":
			var req_amt: int = int(roundf(float(fx.amount)))
			var amt: int = req_amt
			if amt > 0 and chain_id != "":
				var ev_cap: float = float(_EventBudget.event_ceiling(_gd, c, sheet).linh_thach)
				amt = int(floorf(_EventBudget.spend_scalar(_db, chain_id, "linh_thach", float(amt), ev_cap, warnings)))
				if amt <= 0:
					rctx["had_zero_grant"] = true
					return ""
			var payee: String = _money_holder(str(fx.get("source", "")), c, event, fx, amt)
			if amt < 0:
				amt = -MoneyLedger.player_pay(_db, c, payee, mini(-amt, c.linh_thach), "event")
			else:
				amt = MoneyLedger.player_take(_db, c, payee, amt, "event")
				rctx["paid"] = int(rctx.get("paid", 0)) + amt
				if req_amt > 0 and amt <= 0:
					rctx["had_zero_grant"] = true
					return ""
			return "linh thạch %+d (now %d)" % [amt, c.linh_thach]
		"tu_vi":
			var req_tv: float = float(fx.amount)
			var tv_amt: float = req_tv
			if tv_amt > 0.0 and chain_id != "":
				var tv_cap: float = float(_EventBudget.event_ceiling(_gd, c, sheet).tu_vi)
				tv_amt = _EventBudget.spend_scalar(_db, chain_id, "tu_vi", tv_amt, tv_cap, warnings)
				if tv_amt <= 0.0:
					rctx["had_zero_grant"] = true
					return ""
			var res: Dictionary = CultivationRules.add_tu_vi(c, _gd, tv_amt)
			return "tu vi +%.0f%s" % [tv_amt, (" (+%d stage(s), +%d Đạo Đồ points)" % [res.stages, res.tree_points]) if res.stages > 0 else ""]
		"khi_huyet_loss_pct":
			c.vitality = c.vitality - float(fx.amount) / 100.0
			return "khí huyết -%.0f%% (now %d%%)" % [float(fx.amount), int(maxf(c.vitality, 0.0) * 100.0)]
		"tam_ma":
			var applied: float = CharacterRules.add_tam_ma(c, _gd, sheet, float(fx.amount))
			return "tâm ma %+.1f (now %.0f)" % [applied, c.tam_ma]
		"dan_doc":
			var applied2: float = CharacterRules.add_dan_doc(c, _gd, sheet, float(fx.amount))
			return "đan độc %+.1f (now %.0f)" % [applied2, c.dan_doc]
		"relationship":
			var npc_id: String = str(event.get("npc_id", "")) if str(fx.get("npc", "event_npc")) == "event_npc" else str(fx.npc)
			var rec: Dictionary = _db.get_record("people", npc_id)
			if rec.is_empty():
				return ""
			var cfg: Dictionary = _gd.session().talk
			var st: float = SectMembers.new(_gd, _db).standing(str(rec.get("sect_id", "")), c.id) if str(rec.get("sect_id", "")) != "" else 0.0
			NpcTraits.first_meeting(_gd, _db, rec, c.to_dict(), st, int(cfg.hostile_threshold))
			rec["attitude"] = clampi(int(rec.get("attitude", 0)) + int(fx.amount), int(cfg.relationship_min), int(cfg.relationship_max))
			return "%s's attitude %+d (now %d)" % [rec.name, int(fx.amount), int(rec.attitude)]
		"tie_add", "tie_strengthen", "tie_weaken", "tie_end":
			var other: String = str(event.get("npc_id", "")) if str(fx.get("npc", "event_npc")) == "event_npc" else str(fx.npc)
			if other == "" or not Ties.enabled(_gd):
				return ""
			var kind: String = str(fx.get("kind", "friend"))
			var holder: String = c.id if str(fx.get("holder", "npc")) == "player" else other
			var to: String = other if holder == c.id else c.id
			var d: int = int(fx.get("delta", 20))
			if ftype == "tie_weaken":
				d = -absi(d)
			var cause := {"kind": "event", "event_id": str(event.get("id", event.get("template_id", "")))}
			if ftype == "tie_end":
				TieTick.enqueue(_db, {"kind": "end", "a": holder, "b": to, "reason": str(fx.get("reason", "parted"))})
				return "a tie ends"
			if kind == "debt":
				TieTick.enqueue(_db, {"kind": "debt", "debtor": holder, "creditor": to, "delta": d, "cause": cause})
			elif kind in Ties.PINNED:
				TieTick.enqueue(_db, {"kind": "pinned", "a": holder, "b": to, "pk": kind, "authored": bool(fx.get("authored", false))})
			else:
				TieTick.enqueue(_db, {"kind": "soft", "holder": holder, "other": to, "sk": kind, "delta": d, "cause": cause})
			return "%s %+d (at the season's end)" % [kind, d]
		"insight":
			if c.realm_index == _gd.realm_index("nguyen_anh") and not c.has_insight:
				c.has_insight = true
				return "breakthrough insight gained"
			return ""
		"unseal_sealed", "unseal_open":
			return str(unseal_fn.call(ftype.trim_prefix("unseal_"))) if unseal_fn.is_valid() else ""
		"tree_point":
			c.tree_points += int(fx.amount)
			return "+%d Đạo Đồ point(s)" % int(fx.amount)
		"herb":
			var h: Dictionary
			if str(fx.get("herb", "")) != "":
				h = _items.herb(fx.herb, RngUtils.range_f(rng, fx.age_range))
			else:
				h = _items.random_herb(rng, int(fx.rarity_max), fx.age_range, str(fx.get("element", "")))
			return _give(c, h, items)
		"material":
			var m: Dictionary = _items.material(fx.material, 1) if str(fx.get("material", "")) != "" else _items.random_material(rng, int(fx.rarity_max), str(fx.get("element", "")))
			return _give(c, m, items)
		"artifact":
			var a: Dictionary = _items.artifact(rng, c.realm_index, int(fx.grade), str(fx.get("element", "")), "", str(fx.get("name", "")))
			return _give(c, a, items)
		"cong_phap":
			var mcfg: Dictionary = Diagrams.teaching(_gd).get("manual", {})
			var keyed := RandomNumberGenerator.new()
			keyed.seed = RngUtils.stable_hash("diagram_manual:%s:%d" % [c.id, _db.count("items")])
			if keyed.randf() < float(mcfg.get("from_cong_phap_chance", 0.0)):
				var did: String = Diagrams.manual_pick(_gd, keyed, c.realm_index)
				if did != "":
					return _give(c, _items.diagram_manual(did), items)
			var elems: Array = [fx.element] if str(fx.get("element", "")) != "" else []
			var cp: Dictionary = _items.cong_phap(rng, int(fx.tier), elems, str(fx.get("name", "")), {"root": c.linh_can})
			return _give(c, cp, items)
		"talisman":
			var tal: Dictionary = _items.talisman(str(fx.talisman), 1)
			return _give(c, tal, items)
		"breakthrough_pill":
			if c.realm_index >= _gd.realms().size() - 1:
				return ""
			var recipe: Dictionary = Advisor.recipe_for_tag(_gd, str(_gd.realm(c.realm_index + 1).entry_requirement.item_tag))
			if recipe.is_empty():
				return ""
			var bp: String = _alchemy.add_pills(c, str(recipe.id), 0, 1)
			items.append(bp)
			return "gained %s" % recipe.name
		"plan_herb":
			if c.realm_index >= _gd.realms().size() - 1:
				return ""
			var r2: Dictionary = Advisor.recipe_for_tag(_gd, str(_gd.realm(c.realm_index + 1).entry_requirement.item_tag))
			for ing in r2.get("ingredients", []):
				if not Alchemy.is_herb_entry(ing):
					var el: String = str(ing.element)
					var held: float = 0.0
					for i in _db.items_of(c.id):
						if i.kind == "herb" and ItemFactory.herb_elements(_gd.herb(str(i.template))).has(el):
							held += Alchemy.value_at(_gd, str(i.template), float(i.age))
					if held < float(ing.value) - 1e-9:
						var basic: String = Alchemy.basic_herb(_gd, el)
						if basic != "":
							var age: float = float(_gd.herb(basic).get("mature_years", 1.0))
							while Alchemy.value_at(_gd, basic, age) < float(ing.value) - held - 1e-9 and age < 500.0:
								age += 1.0
							return _give(c, _items.herb(basic, age), items)
					continue
				var have_n: int = 0
				for i in _db.items_of(c.id):
					if i.kind == "herb" and i.template == ing.herb and float(i.age) >= float(ing.min_age) - 1e-9:
						have_n += 1
				if have_n < int(ing.qty):
					return _give(c, _items.herb(str(ing.herb), float(ing.min_age) + 1.0), items)
			return ""
		"treasure":
			return _give(c, _items.treasure(str(fx.treasure)), items)
		"pill":
			var pid: String = _alchemy.add_pills(c, str(fx.recipe), 0, 1)
			items.append(pid)
			return "gained %s" % _gd.recipe(fx.recipe).name
		"set_flag":
			var sid: String = _resolve_scope_id(str(fx.get("scope", "root")), c, event)
			var fname: String = str(fx.get("flag", ""))
			if fname == "":
				return ""
			var exp_dur: int = int(fx.get("expires_seasons", -1))
			var exp_s: int = (now_season + exp_dur) if exp_dur >= 0 else -1
			_EventStore.set_flag(_db, sid, fname, exp_s, fx.get("value", true))
			var prec: Dictionary = _db.get_record("people", sid)
			if not prec.is_empty():
				var fl: Dictionary = Dictionary(prec.get("flags", {}))
				fl[fname] = fx.get("value", true)
				prec["flags"] = fl
			return "flag %s set" % fname
		"clear_flag":
			var sid_c: String = _resolve_scope_id(str(fx.get("scope", "root")), c, event)
			var fname_c: String = str(fx.get("flag", ""))
			if fname_c == "":
				return ""
			_EventStore.clear_flag(_db, sid_c, fname_c)
			var prec_c: Dictionary = _db.get_record("people", sid_c)
			if not prec_c.is_empty() and prec_c.has("flags") and prec_c.flags is Dictionary:
				(prec_c.flags as Dictionary).erase(fname_c)
			return "flag %s cleared" % fname_c
		"var_add", "var_set":
			var sid_v: String = _resolve_scope_id(str(fx.get("scope", "root")), c, event)
			var vname: String = str(fx.get("var", ""))
			if vname == "":
				return ""
			var bounds: Array = _var_bounds(str(fx.get("scope", "root")), vname, event, fx)
			var new_v: int = 0
			if ftype == "var_add":
				new_v = _EventStore.add_var(_db, sid_v, vname, int(fx.get("amount", 0)), int(bounds[0]), int(bounds[1]), warnings)
			else:
				new_v = _EventStore.set_var(_db, sid_v, vname, int(fx.get("value", 0)), int(bounds[0]), int(bounds[1]), warnings)
			if str(fx.get("scope", "")) == "story" and sid_v != "":
				var srec: Dictionary = _EventStore.get_story(_db, sid_v)
				if not srec.is_empty():
					var svars: Dictionary = Dictionary(srec.get("variables", {}))
					svars[vname] = new_v
					srec["variables"] = svars
					_EventStore.put_story(_db, srec)
			return "%s = %d" % [vname, new_v]
		"schedule_followup":
			var fu_ev: String = str(fx.get("event_id", ""))
			if fu_ev == "":
				return ""
			var target_root_key: String = str(fx.get("target_root", "root"))
			var fu_root: String = c.id if target_root_key in ["root", "player", ""] else (str(event.get("npc_id", c.id)) if target_root_key in ["other", "npc"] else target_root_key)
			var delay: int = _roll_delay(rng, fx.get("delay_seasons", [2, 4]))
			var fu_chain: String = chain_id
			if fu_chain == "" and fu_root == c.id:
				var cb_cfg: Dictionary = _gd.budgets().get("chain_budgets", {})
				fu_chain = _EventBudget.create_chain(_db, _gd, c, sheet, float(cb_cfg.get("m_chain", 1.5)), int(cb_cfg.get("chain_items_max", 2)))
				event["chain_id"] = fu_chain
			var fu_scopes: Dictionary = Dictionary(fx.get("scopes", {})).duplicate(true)
			if not fu_scopes.has("other") and str(event.get("npc_id", "")) != "":
				fu_scopes["other"] = str(event.get("npc_id", ""))
			var fu_rec := {
				"event_id": fu_ev,
				"root_id": fu_root,
				"scheduled_at": now_season,
				"due_season": now_season + delay,
				"wait_seasons": int(fx.get("wait_seasons", _gd.budgets().get("pacing", {}).get("default_wait_seasons", 4))),
				"hook": str(fx.get("hook", "")),
				"hook_place_id": str(fx.get("hook_place_id", "")),
				"chain_id": fu_chain,
				"story_instance_id": str(event.get("story_instance_id", "")),
				"followup_of": str(event.get("title", event.get("template_id", ""))),
				"scopes": fu_scopes,
			}
			var fid: String = _EventStore.add_followup(_db, fu_rec)
			rctx.scheduled_followups.append(fid)
			return "follow-up scheduled"
		"story_start":
			var st_id: String = str(fx.get("story_id", ""))
			if st_id == "":
				return ""
			var sfn: Callable = rctx.get("story_start_fn", Callable())
			var st_scopes: Dictionary = Dictionary(fx.get("scopes", {})).duplicate(true)
			if not st_scopes.has("other") and str(event.get("npc_id", "")) != "":
				st_scopes["other"] = str(event.npc_id)
			var sr: Dictionary = sfn.call(st_id, c.id, st_scopes, year, season, c, sheet) if sfn.is_valid() else _direct_start_story(st_id, c, sheet, st_scopes, year, season, warnings)
			rctx.story_actions.append({"action": "start", "story_id": st_id, "result": sr})
			if bool(sr.get("ok", false)):
				return "story started: %s" % str(Dictionary(sr.get("story", {})).get("name", st_id))
			if str(sr.get("warning", "")) != "":
				warnings.append(str(sr.warning))
			return ""
		"story_stage":
			var sinst: String = str(event.get("story_instance_id", ""))
			if sinst == "" and str(fx.get("story_id", "")) != "":
				for srec in _EventStore.active_stories(_db, c.id, true):
					if str(srec.get("story_id", "")) == str(fx.story_id):
						sinst = str(srec.id)
						break
			var next_st: String = str(fx.get("stage", ""))
			if sinst == "" or next_st == "":
				return ""
			var stfn: Callable = rctx.get("story_stage_fn", Callable())
			var sres: Dictionary = stfn.call(sinst, next_st, year, season) if stfn.is_valid() else _direct_advance_story(sinst, next_st)
			rctx.story_actions.append({"action": "stage", "story_instance_id": sinst, "stage": next_st, "result": sres})
			return "story advanced: %s" % next_st
		"story_end":
			var sinst_e: String = str(event.get("story_instance_id", ""))
			if sinst_e == "" and str(fx.get("story_id", "")) != "":
				for srec in _EventStore.active_stories(_db, c.id, true):
					if str(srec.get("story_id", "")) == str(fx.story_id):
						sinst_e = str(srec.id)
						break
			if sinst_e == "":
				return ""
			var status_e: String = str(fx.get("status", "done"))
			var efn: Callable = rctx.get("story_end_fn", Callable())
			var eres: Dictionary = efn.call(sinst_e, status_e, year, season, true) if efn.is_valid() else _direct_end_story(sinst_e, status_e, year, season)
			rctx.story_actions.append({"action": "end", "story_instance_id": sinst_e, "status": status_e, "result": eres})
			return "story ended (%s)" % status_e
		"grant_trait":
			var target_id: String = _resolve_scope_id(str(fx.get("scope", "root")), c, event)
			var prec: Dictionary = _db.get_record("people", target_id)
			if prec.is_empty() and target_id == c.id:
				prec = {"id": c.id, "npc_traits": c.npc_traits}
			var tid: String = str(fx.get("trait", ""))
			if prec.is_empty() or tid == "" or not _gd.registry.has_file(NpcTraits.FILE):
				return ""
			var cat: Dictionary = NpcTraits.catalogue(_gd)
			var tkind: String = str(cat.kind.get(tid, ""))
			var gres: String = "refused"
			if tkind == "gained":
				gres = NpcTraits.grant(_gd, prec, tid, now_season, str(fx.get("target", "")))
			elif tkind in ["path", "lifestyle", "health", "coping"]:
				gres = NpcTraits.grant_v2(_gd, prec, tid, now_season)
			if target_id == c.id:
				c.npc_traits = Dictionary(prec.get("npc_traits", {})).duplicate(true)
			return ("trait %s (%s)" % [tid, gres]) if gres != "refused" else ""
		"remove_trait":
			var target_id_r: String = _resolve_scope_id(str(fx.get("scope", "root")), c, event)
			var prec_r: Dictionary = _db.get_record("people", target_id_r)
			if prec_r.is_empty() and target_id_r == c.id:
				prec_r = {"id": c.id, "npc_traits": c.npc_traits}
			var tid_r: String = str(fx.get("trait", ""))
			if prec_r.is_empty() or tid_r == "" or not _gd.registry.has_file(NpcTraits.FILE):
				return ""
			var removed: bool = _remove_any_trait(prec_r, tid_r)
			if target_id_r == c.id:
				c.npc_traits = Dictionary(prec_r.get("npc_traits", {})).duplicate(true)
			return ("trait %s removed" % tid_r) if removed else ""
		"trait_trigger":
			var target_id_tr: String = _resolve_scope_id(str(fx.get("scope", "root")), c, event)
			var prec_tr: Dictionary = _db.get_record("people", target_id_tr)
			if prec_tr.is_empty() and target_id_tr == c.id:
				prec_tr = {"id": c.id, "npc_traits": c.npc_traits}
			var trig: String = str(fx.get("trigger", fx.get("id", "")))
			if prec_tr.is_empty() or trig == "" or not _gd.registry.has_file(NpcTraits.FILE):
				return ""
			var granted_id: String = _apply_trait_trigger(prec_tr, trig, now_season)
			if target_id_tr == c.id:
				c.npc_traits = Dictionary(prec_tr.get("npc_traits", {})).duplicate(true)
			return ("trait trigger %s -> %s" % [trig, granted_id]) if granted_id != "" else ""
		"sect_standing":
			var sid_s: String = _resolve_sect_id(str(fx.get("sect", "")), c, event)
			if sid_s == "":
				return ""
			var sm := SectMembers.new(_gd, _db)
			var d_st: float = sm.change_standing(sid_s, c.id, float(fx.get("amount", 0.0)))
			var sname: String = str(_db.get_record("sects", sid_s).get("name", sid_s))
			return "%s standing %+.1f" % [sname, d_st]
		"sect_loyalty":
			var sid_l: String = _resolve_sect_id(str(fx.get("sect", "")), c, event)
			var srec_l: Dictionary = _db.get_record("sects", sid_l)
			if srec_l.is_empty():
				return ""
			var loy: float = clampf(float(srec_l.get("loyalty", 60.0)) + float(fx.get("amount", 0.0)), 0.0, 100.0)
			srec_l["loyalty"] = loy
			srec_l["loyalty_state"] = SectPolitics.loyalty_state(_gd, loy)
			return "%s loyalty %.0f (%s)" % [str(srec_l.get("name", sid_l)), loy, str(srec_l.loyalty_state)]
		"sect_attitude":
			var sid_a: String = _resolve_sect_id(str(fx.get("sect", "")), c, event)
			var sid_b: String = str(fx.get("other_sect", ""))
			if sid_b == "":
				var npc_r: Dictionary = _db.get_record("people", str(event.get("npc_id", "")))
				sid_b = str(npc_r.get("sect_id", ""))
			var sa: Dictionary = _db.get_record("sects", sid_a)
			if sa.is_empty() or sid_b == "" or sid_a == sid_b:
				return ""
			var att_d: Dictionary = Dictionary(sa.get("attitude", {}))
			att_d[sid_b] = clampf(float(att_d.get(sid_b, 0.0)) + float(fx.get("amount", 0.0)), -100.0, 100.0)
			sa["attitude"] = att_d
			return "sect attitude %+.0f" % float(fx.get("amount", 0.0))
		"market_shock":
			var m_sect: String = str(fx.get("sect", ""))
			if m_sect == "":
				m_sect = MoneyLedger.market_sect_of(_db, str(c.location_id))
			var mk: Dictionary = _db.get_record(WorldEconomy.TABLE, WorldEconomy.market_id(m_sect)) if m_sect != "" else {}
			if mk.is_empty():
				return ""
			var gk: String = str(fx.get("good_kind", fx.get("class_id", "herb")))
			var delta: float = float(fx.get("delta", 0.2))
			var dur: int = int(fx.get("duration_seasons", 2))
			var classes: Dictionary = Dictionary(mk.get("classes", {}))
			var eco_cfg: Dictionary = _gd.file(WorldEconomy.FILE).get("classes", {})
			var p_min: float = float(Dictionary(eco_cfg.get("p_min", {})).get(gk, 0.5))
			var p_max: float = float(Dictionary(eco_cfg.get("p_max", {})).get(gk, 3.0))
			for cid in classes:
				if str(cid) == gk or str(Dictionary(classes[cid]).get("kind", "")) == gk:
					var cl: Dictionary = classes[cid]
					cl["p"] = clampf(float(cl.get("p", 1.0)) * (1.0 + delta), p_min, p_max)
			var shocks: Array = Array(mk.get("event_shocks", []))
			shocks.append({"kind": gk, "delta": delta, "expires_season": now_season + dur})
			mk["event_shocks"] = shocks
			return "market shock %s (%+.0f%%)" % [gk, delta * 100.0]
		"clue":
			var reg_id: String = str(fx.get("region_id", ""))
			if reg_id == "":
				reg_id = str(_db.get_record("places", str(c.location_id)).get("region_id", ""))
			var mk_know: Variant = rctx.get("map_knowledge", null)
			if mk_know is MapKnowledge:
				var line_r: String = Discovery.rumour(_gd, _db, mk_know as MapKnowledge, rng, reg_id)
				if line_r != "":
					return line_r.strip_edges()
			var ckind: String = str(fx.get("kind", "rumour"))
			var clue_rec := {"kind": ckind, "region_id": reg_id, "slot": str(fx.get("slot", "")), "season": now_season}
			_EventStore.set_flag(_db, c.id, "clue:%s:%d" % [ckind, now_season], -1, clue_rec)
			return "clue gained (%s)" % ckind
		"reveal_place":
			var target_pl: String = str(fx.get("place_id", ""))
			var slot_k: String = str(fx.get("slot", ""))
			if target_pl == "" and slot_k != "":
				var led: Dictionary = Discovery.ledger(_db)
				target_pl = str(Dictionary(led.get(slot_k, {})).get("place_id", ""))
			if target_pl == "":
				for p in _db.all("places"):
					if bool(p.get("hidden", false)):
						target_pl = str(p.id)
						break
			var pl_rec: Dictionary = _db.get_record("places", target_pl)
			if pl_rec.is_empty():
				return ""
			pl_rec["hidden"] = false
			var mk_know2: Variant = rctx.get("map_knowledge", null)
			if mk_know2 is MapKnowledge:
				(mk_know2 as MapKnowledge).places[target_pl] = true
			return "place revealed: %s" % str(pl_rec.get("name", target_pl))
		"scar":
			var sc_pl: String = str(fx.get("place_id", event.get("place_id", c.location_id)))
			var sc_rec: Dictionary = _db.get_record("places", sc_pl) if sc_pl != "" else {}
			if sc_rec.is_empty() or not sc_rec.has("density"):
				return ""
			var cause_s: String = str(fx.get("cause", event.get("title", "biến cố")))
			var ok_sc: bool = MapChange.scar(_db, sc_pl, float(fx.get("d_density", -0.05)), Dictionary(fx.get("push", {})), year, season, cause_s)
			return "land scarred" if ok_sc else ""
		"uncover_chronicle":
			var cid: String = str(fx.get("chronicle_id", ""))
			var unc: Dictionary = uncover_chronicle_in_db(_db, cid)
			if bool(unc.get("ok", false)):
				rctx.uncovered_chronicles.append(cid)
				return ("chronicle uncovered: %s" % cid) if bool(unc.get("changed", false)) else ("chronicle known: %s" % cid)
			return ""
		"quest_boon":
			var boon := {
				"quest_id": str(fx.get("quest_id", event.get("story_id", ""))),
				"title": str(fx.get("title", event.get("title", "Ủy thác"))),
				"mods": Array(fx.get("mods", [])).duplicate(true),
			}
			if "quest_boons" in c:
				c.get("quest_boons").append(boon)
			else:
				_EventStore.set_flag(_db, c.id, "quest_boon:%s" % str(boon.quest_id), -1, boon)
			var tp_add: int = int(fx.get("tree_points", 0))
			if tp_add > 0:
				c.tree_points += tp_add
			return "quest boon gained: %s" % str(boon.title)
		"access":
			var akey: String = str(fx.get("key", fx.get("target", fx.get("place_id", ""))))
			if akey == "":
				return ""
			var aexp_d: int = int(fx.get("expires_seasons", -1))
			var aexp: int = (now_season + aexp_d) if aexp_d >= 0 else -1
			_EventStore.set_flag(_db, c.id, "access:" + akey, aexp, true)
			return "access granted: %s" % akey
		"set_npc_flag":
			var target_id_n: String = str(event.get("npc_id", "")) if str(fx.get("npc", "event_npc")) == "event_npc" else str(fx.npc)
			var rec_n: Dictionary = _db.get_record("people", target_id_n)
			if rec_n.is_empty():
				return ""
			var flag_name: String = str(fx.get("flag", ""))
			if flag_name != "":
				_EventStore.set_flag(_db, target_id_n, flag_name, -1, fx.get("value", true))
				var fl_n: Dictionary = Dictionary(rec_n.get("flags", {}))
				fl_n[flag_name] = fx.get("value", true)
				rec_n["flags"] = fl_n
				if rec_n.has("interaction_flags"):
					var ifl: Dictionary = Dictionary(rec_n.get("interaction_flags", {}))
					ifl[flag_name] = fx.get("value", true)
					rec_n["interaction_flags"] = ifl
				return "%s remembers: %s" % [str(rec_n.get("name", target_id_n)), flag_name]
			return ""
		"kill_npc":
			var ktarget: String = str(event.get("npc_id", "")) if str(fx.get("npc", "event_npc")) == "event_npc" else str(fx.npc)
			var krec: Dictionary = _db.get_record("people", ktarget)
			if krec.is_empty() or not bool(krec.get("alive", false)):
				return ""
			if kill_npc_fn.is_valid():
				kill_npc_fn.call(ktarget, str(fx.get("cause", "Tử chiến")))
			else:
				krec["alive"] = false
				krec["death_cause"] = str(fx.get("cause", "Tử chiến"))
			return "%s was slain." % str(krec.get("name", ktarget))
	return ""


## Static idempotent hidden-chronicle uncovering helper shared by [EventResolver] and [EventEngine]
## (World Generation Rule 3a, AC-WG-56).
static func uncover_chronicle_in_db(db: WorldDB, chronicle_id: String) -> Dictionary:
	if db == null or chronicle_id == "":
		return {"ok": false, "changed": false, "event_id": "", "text": ""}
	for e in db.all("events"):
		var data: Dictionary = Dictionary(e.get("data", {}))
		if str(data.get("id", "")) != chronicle_id:
			continue
		var is_hidden: bool = str(e.get("type", "")) == "hidden" or bool(data.get("secret", false)) or str(data.get("tier", "")) == "hidden"
		if not is_hidden:
			return {"ok": true, "changed": false, "event_id": str(e.id), "text": str(e.get("text", ""))}
		data["secret"] = false
		data["tier"] = str(data.get("uncover_tier", "annal"))
		data["uncovered"] = true
		e["data"] = data
		e["type"] = str(data.get("story_kind", "tale"))
		return {"ok": true, "changed": true, "event_id": str(e.id), "text": str(e.get("text", ""))}
	return {"ok": false, "changed": false, "event_id": "", "text": ""}


# --- NPC Off-Screen Effect Application (strictly MoneyLedger-conserving, no player-only effects) -

func _apply_npc_effect(
	npc_rec: Dictionary,
	event: Dictionary,
	fx: Dictionary,
	rng: RandomNumberGenerator,
	abs_season: int,
	player_only: Array,
	player_id: String,
	scheduled_followups: Array,
	warnings: Array
) -> void:
	var ftype: String = str(fx.get("type", ""))
	var po_key: String = ftype if ftype != "talisman" else ("talisman:" + str(fx.get("talisman", "")))
	if player_only.has(ftype) or player_only.has(po_key):
		warnings.append("npc_mode skipped player-only effect '%s'" % po_key)
		return
	var pid: String = str(npc_rec.get("id", ""))
	var other_id: String = str(event.get("npc_id", ""))
	match ftype:
		"linh_thach":
			var amt: float = float(fx.get("amount", 0.0))
			if is_zero_approx(amt) or _db.count(WorldEconomy.TABLE) == 0:
				return
			var m_sect: String = MoneyLedger.market_sect_of(_db, str(npc_rec.get("location_id", "")))
			var src: String = str(fx.get("source", "commons"))
			var counter: String = _npc_money_counterparty(src, m_sect, npc_rec, other_id)
			if counter == "" or counter.ends_with(":"):
				return
			var ledger := MoneyLedger.new(_db)
			if amt > 0.0:
				ledger.transfer(counter, "npc:%s" % pid, amt, "npc_event")
			else:
				ledger.transfer("npc:%s" % pid, counter, -amt, "npc_event")
		"tu_vi":
			var cur_tv: float = float(npc_rec.get("tu_vi", 0.0))
			npc_rec["tu_vi"] = cur_tv + maxf(0.0, float(fx.get("amount", 0.0)))
		"khi_huyet_loss_pct":
			var v: float = float(npc_rec.get("vitality", 1.0)) - float(fx.get("amount", 0.0)) / 100.0
			npc_rec["vitality"] = maxf(0.1, v)   # off-screen NPC pulses wound but don't bypass ticker death accounting
		"tam_ma":
			npc_rec["tam_ma"] = clampf(float(npc_rec.get("tam_ma", 0.0)) + float(fx.get("amount", 0.0)), 0.0, 100.0)
		"dan_doc":
			npc_rec["dan_doc"] = clampf(float(npc_rec.get("dan_doc", 0.0)) + float(fx.get("amount", 0.0)), 0.0, 100.0)
		"relationship":
			if other_id != "" and Ties.enabled(_gd):
				var delta_r: int = int(fx.get("amount", 0))
				var sk: String = "friend" if delta_r >= 0 else "enmity"
				TieTick.enqueue(_db, {"kind": "soft", "holder": pid, "other": other_id, "sk": sk, "delta": absi(delta_r), "cause": {"kind": "npc_event"}})
		"tie_add", "tie_strengthen", "tie_weaken", "tie_end":
			if other_id == "" or not Ties.enabled(_gd):
				return
			var kind: String = str(fx.get("kind", "friend"))
			var d: int = int(fx.get("delta", 20))
			if ftype == "tie_weaken":
				d = -absi(d)
			if ftype == "tie_end":
				TieTick.enqueue(_db, {"kind": "end", "a": pid, "b": other_id, "reason": str(fx.get("reason", "parted"))})
			elif kind == "debt":
				TieTick.enqueue(_db, {"kind": "debt", "debtor": pid, "creditor": other_id, "delta": d, "cause": {"kind": "npc_event"}})
			elif kind in Ties.PINNED:
				TieTick.enqueue(_db, {"kind": "pinned", "a": pid, "b": other_id, "pk": kind, "authored": false})
			else:
				TieTick.enqueue(_db, {"kind": "soft", "holder": pid, "other": other_id, "sk": kind, "delta": d, "cause": {"kind": "npc_event"}})
		"set_flag":
			var sc: String = str(fx.get("scope", "root"))
			var sid: String = pid if sc == "root" else (other_id if sc in ["other", "npc"] else ("world" if sc == "world" else sc))
			if sid != "":
				var dur: int = int(fx.get("expires_seasons", -1))
				_EventStore.set_flag(_db, sid, str(fx.get("flag", "")), (abs_season + dur) if dur >= 0 else -1, fx.get("value", true))
		"clear_flag":
			var sc_c: String = str(fx.get("scope", "root"))
			var sid_c: String = pid if sc_c == "root" else (other_id if sc_c in ["other", "npc"] else ("world" if sc_c == "world" else sc_c))
			if sid_c != "":
				_EventStore.clear_flag(_db, sid_c, str(fx.get("flag", "")))
		"var_add":
			var sc_v: String = str(fx.get("scope", "root"))
			var sid_v: String = pid if sc_v == "root" else (other_id if sc_v in ["other", "npc"] else ("world" if sc_v == "world" else sc_v))
			_EventStore.add_var(_db, sid_v, str(fx.get("var", "")), int(fx.get("amount", 0)), int(fx.get("min", -999999)), int(fx.get("max", 999999)), warnings)
		"var_set":
			var sc_vs: String = str(fx.get("scope", "root"))
			var sid_vs: String = pid if sc_vs == "root" else (other_id if sc_vs in ["other", "npc"] else ("world" if sc_vs == "world" else sc_vs))
			_EventStore.set_var(_db, sid_vs, str(fx.get("var", "")), int(fx.get("value", 0)), int(fx.get("min", -999999)), int(fx.get("max", 999999)), warnings)
		"grant_trait":
			var tid: String = str(fx.get("trait", ""))
			if tid != "" and _gd.registry.has_file(NpcTraits.FILE):
				var cat: Dictionary = NpcTraits.catalogue(_gd)
				var tk: String = str(cat.kind.get(tid, ""))
				if tk == "gained":
					NpcTraits.grant(_gd, npc_rec, tid, abs_season)
				elif tk in ["path", "lifestyle", "health", "coping"]:
					NpcTraits.grant_v2(_gd, npc_rec, tid, abs_season)
		"remove_trait":
			_remove_any_trait(npc_rec, str(fx.get("trait", "")))
		"sect_standing":
			var sid_s: String = str(npc_rec.get("sect_id", ""))
			if sid_s != "":
				SectMembers.new(_gd, _db).change_standing(sid_s, pid, float(fx.get("amount", 0.0)))
		"schedule_followup":
			var fu_ev: String = str(fx.get("event_id", ""))
			if fu_ev == "":
				return
			var tr_key: String = str(fx.get("target_root", "root"))
			var fu_root: String = pid
			if tr_key == "player":
				fu_root = player_id if player_id != "" else _find_player_id()
			elif tr_key in ["other", "npc"]:
				fu_root = other_id
			elif tr_key != "root" and tr_key != "":
				fu_root = tr_key
			if fu_root == "":
				return
			var delay: int = _roll_delay(rng, fx.get("delay_seasons", [2, 4]))
			var fu_scopes: Dictionary = Dictionary(fx.get("scopes", {})).duplicate(true)
			if tr_key == "player" and not fu_scopes.has("other"):
				fu_scopes["other"] = pid   # the NPC who triggered the follow-up for the player
			var fu_rec := {
				"event_id": fu_ev,
				"root_id": fu_root,
				"scheduled_at": abs_season,
				"due_season": abs_season + delay,
				"wait_seasons": int(fx.get("wait_seasons", _gd.budgets().get("pacing", {}).get("default_wait_seasons", 4))),
				"hook": str(fx.get("hook", "")),
				"hook_place_id": str(fx.get("hook_place_id", "")),
				"chain_id": "",
				"followup_of": str(event.get("title", event.get("template_id", ""))),
				"scopes": fu_scopes,
			}
			var fid: String = _EventStore.add_followup(_db, fu_rec)
			scheduled_followups.append(fid)


# --- Internal Helpers ----------------------------------------------------------------------------

func _money_holder(source: String, c: Character, event: Dictionary, fx: Dictionary, amt: int) -> String:
	if amt < 0 and str(event.get("source", "")) == "template:loan_collection" and str(event.get("npc_id", "")) != "":
		return "npc:%s" % str(event.npc_id)
	var m_sect: String = MoneyLedger.market_sect_of(_db, str(c.location_id))
	match source:
		"stash":
			return "stash:%s" % m_sect
		"sect":
			var sid: String = _resolve_sect_id(str(fx.get("sect", "")), c, event)
			return "sect:%s" % sid
		"victim", "other_purse":
			var target: String = str(fx.get("npc", event.get("npc_id", "")))
			return "npc:%s" % target
		_:
			return "pool:%s" % m_sect


func _npc_money_counterparty(source: String, m_sect: String, npc_rec: Dictionary, other_id: String) -> String:
	match source:
		"stash":
			return "stash:%s" % m_sect
		"sect":
			var sid: String = str(npc_rec.get("sect_id", ""))
			return ("sect:%s" % sid) if sid != "" else ("pool:%s" % m_sect)
		"victim", "other_purse":
			return ("npc:%s" % other_id) if other_id != "" else ("pool:%s" % m_sect)
		_:
			return "pool:%s" % m_sect


func _resolve_scope_id(scope: String, c: Character, event: Dictionary) -> String:
	match scope:
		"root", "player", "":
			return c.id
		"other", "npc":
			return str(event.get("npc_id", ""))
		"place":
			return str(event.get("place_id", c.location_id))
		"sect":
			return _resolve_sect_id("", c, event)
		"story":
			return str(event.get("story_instance_id", event.get("story_id", "")))
		"world":
			return "world"
	return scope


func _resolve_sect_id(explicit: String, c: Character, event: Dictionary) -> String:
	if explicit != "":
		if _db.has_record("sects", explicit):
			return explicit
		for s in _db.all("sects"):
			if str(s.get("key", "")) == explicit:
				return str(s.id)
	if str(event.get("sect_id", "")) != "":
		return str(event.sect_id)
	if c.sect_id != "":
		return c.sect_id
	var pl: Dictionary = _db.get_record("places", str(event.get("place_id", c.location_id)))
	return str(pl.get("sect_id", pl.get("holder", "")))


func _var_bounds(scope: String, vname: String, event: Dictionary, fx: Dictionary) -> Array:
	if fx.has("min") or fx.has("max"):
		return [int(fx.get("min", -2147483648)), int(fx.get("max", 2147483647))]
	if scope == "story":
		var sid: String = str(event.get("story_id", ""))
		if sid != "":
			for st in Array(_gd.file("events_stories").get("stories", [])):
				if st is Dictionary and str((st as Dictionary).get("id", "")) == sid:
					var vdef: Dictionary = Dictionary(Dictionary((st as Dictionary).get("variables", {})).get(vname, {}))
					if not vdef.is_empty():
						return [int(vdef.get("min", -2147483648)), int(vdef.get("max", 2147483647))]
	return [-2147483648, 2147483647]


func _roll_delay(rng: RandomNumberGenerator, raw_delay: Variant) -> int:
	if raw_delay is Array:
		var arr: Array = raw_delay as Array
		if arr.size() >= 2:
			return rng.randi_range(int(arr[0]), int(arr[1]))
		if arr.size() == 1:
			return int(arr[0])
		return 1
	return maxi(0, int(raw_delay))


func _remove_any_trait(prec: Dictionary, tid: String) -> bool:
	var cat: Dictionary = NpcTraits.catalogue(_gd)
	var tk: String = str(cat.kind.get(tid, ""))
	if tk == "gained":
		var nt: Dictionary = Dictionary(prec.get("npc_traits", {}))
		var g: Array = Array(nt.get("gained", []))
		var before: int = g.size()
		nt["gained"] = g.filter(func(e): return (str(e.get("id", "")) if e is Dictionary else str(e)) != tid)
		prec["npc_traits"] = nt
		return Array(nt.gained).size() < before
	if tk in ["path", "lifestyle", "health", "coping"]:
		return NpcTraits.remove_v2(_gd, prec, tid)
	return false


func _apply_trait_trigger(prec: Dictionary, trigger_id: String, now_season: int) -> String:
	var cat: Dictionary = NpcTraits.catalogue(_gd)
	var f: Dictionary = cat.file
	for k in ["gained", "coping"]:
		for t in Array(f.get(k, [])):
			if not (t is Dictionary):
				continue
			var td: Dictionary = t as Dictionary
			var tr_raw: Variant = td.get("trigger", td.get("triggers", ""))
			var hit: bool = false
			if tr_raw is Array:
				hit = (tr_raw as Array).has(trigger_id)
			else:
				hit = str(tr_raw) == trigger_id
			if hit:
				var tid: String = str(td.id)
				if k == "gained":
					NpcTraits.grant(_gd, prec, tid, now_season)
				else:
					NpcTraits.grant_v2(_gd, prec, tid, now_season)
				return tid
	return ""


func _direct_start_story(story_id: String, c: Character, sheet: StatSheet, scopes: Dictionary, year: int, season: int, warnings: Array) -> Dictionary:
	var st_def: Dictionary = {}
	for st in Array(_gd.file("events_stories").get("stories", [])):
		if st is Dictionary and str((st as Dictionary).get("id", "")) == story_id:
			st_def = st as Dictionary
			break
	if st_def.is_empty():
		return {"ok": false, "reason": "unknown_story", "warning": "unknown story '%s'" % story_id}
	if bool(st_def.get("once_per_world", false)) and _EventStore.has_world_story_started(_db, story_id):
		return {"ok": false, "reason": "once_per_world", "warning": "story '%s' already started in this world" % story_id}
	var max_st: int = int(_gd.budgets().get("pacing", {}).get("stories_active_max_player", 3))
	var active: Array = _EventStore.active_stories(_db, c.id, false)
	if active.size() >= max_st:
		if not bool(st_def.get("priority", false)):
			var w: String = "story '%s' refused: active story cap %d reached" % [story_id, max_st]
			warnings.append(w)
			return {"ok": false, "reason": "story_cap_full", "warning": w}
		var displaced: bool = false
		for old_st in active:
			if not bool(old_st.get("priority", false)):
				_direct_end_story(str(old_st.id), "timed_out", year, season)
				displaced = true
				break
		if not displaced:
			var w2: String = "priority story '%s' refused: all active stories are priority" % story_id
			warnings.append(w2)
			return {"ok": false, "reason": "all_priority", "warning": w2}
	var spy: int = int(_gd.cultivation_rules().get("seasons_per_year", 4))
	var abs_s: int = year * spy + season
	var mult: float = float(st_def.get("budget_mult", 1.5))
	var imax: int = int(st_def.get("items_max", 2))
	var ch_id: String = _EventBudget.create_chain(_db, _gd, c, sheet, mult, imax)
	var stages: Array = Array(st_def.get("stages", []))
	var first_stage: String = str(stages[0].get("id", "")) if not stages.is_empty() else ""
	var init_vars := {}
	for vk in Dictionary(st_def.get("variables", {})):
		var vd: Dictionary = Dictionary(st_def.variables[vk])
		init_vars[str(vk)] = int(vd.get("init", 0))
	var rec := {
		"story_id": story_id,
		"name": str(st_def.get("name", story_id)),
		"root_id": c.id,
		"status": "active",
		"is_quest": false,
		"priority": bool(st_def.get("priority", false)),
		"stage": first_stage,
		"stage_fired": "",
		"started_season": abs_s,
		"timeout_seasons": int(st_def.get("timeout_seasons", 24)),
		"chain_id": ch_id,
		"scopes": scopes.duplicate(true),
		"variables": init_vars,
	}
	var inst_id: String = _EventStore.add_story(_db, rec)
	for vk in init_vars:
		var vd: Dictionary = Dictionary(st_def.variables[vk])
		_EventStore.set_var(_db, inst_id, str(vk), int(init_vars[vk]), int(vd.get("min", -2147483648)), int(vd.get("max", 2147483647)))
	return {"ok": true, "story": rec}


func _direct_advance_story(story_instance_id: String, next_stage: String) -> Dictionary:
	var rec: Dictionary = _EventStore.get_story(_db, story_instance_id)
	if rec.is_empty() or str(rec.get("status", "")) != "active":
		return {"ok": false}
	rec["stage"] = next_stage
	rec["stage_fired"] = ""
	_EventStore.put_story(_db, rec)
	return {"ok": true, "story": rec}


func _direct_end_story(story_instance_id: String, status: String, year: int, season: int) -> Dictionary:
	var rec: Dictionary = _EventStore.get_story(_db, story_instance_id)
	if rec.is_empty():
		return {"ok": false}
	var spy: int = int(_gd.cultivation_rules().get("seasons_per_year", 4))
	rec["status"] = status
	rec["ended_season"] = year * spy + season
	_EventStore.put_story(_db, rec)
	var st_def: Dictionary = {}
	for st in Array(_gd.file("events_stories").get("stories", [])):
		if st is Dictionary and str((st as Dictionary).get("id", "")) == str(rec.get("story_id", "")):
			st_def = st as Dictionary
			break
	var lk: String = "log_done" if status == "done" else ("log_timeout" if status == "timed_out" else "log_failed")
	var raw_log: String = str(st_def.get(lk, "Câu chuyện '%s' kết thúc (%s)." % [str(rec.get("name", "")), status]))
	var root_rec: Dictionary = _db.get_record("people", str(rec.get("root_id", "")))
	var rendered: String = _EventConditions.render_text(raw_log, {
		"player": str(root_rec.get("name", "")),
		"root": str(root_rec.get("name", "")),
		"story_name": str(rec.get("name", "")),
	})
	var log_id: String = _db.log_event(year, season, "story_end", rendered, [str(rec.get("root_id", ""))], [], [], {
		"story_id": str(rec.get("story_id", "")),
		"story_instance_id": story_instance_id,
		"status": status,
	})
	return {"ok": true, "story": rec, "event_id": log_id}


func _player_knows_any(person_ids: Array, player_id: String) -> bool:
	var pid: String = player_id if player_id != "" else _find_player_id()
	var pl_rec: Dictionary = _db.get_record("people", pid) if pid != "" else {}
	var met_list: Array = Array(pl_rec.get("met_list", []))
	for id_v in person_ids:
		var s: String = str(id_v)
		if s == "" or s == pid:
			continue
		if met_list.has(s):
			return true
		var rec: Dictionary = _db.get_record("people", s)
		if bool(rec.get("met_player", false)) or int(rec.get("attitude", 0)) != 0:
			return true
	return false


func _find_player_id() -> String:
	if _db == null:
		return ""
	for p in _db.living():
		if bool(p.get("is_player", false)):
			return str(p.id)
	return ""


static func _parse_situation(name: String) -> int:
	match name.strip_edges().to_lower():
		"ambush":
			return FightRequest.Situation.AMBUSH
		"blind":
			return FightRequest.Situation.BLIND
	return FightRequest.Situation.FORESEEN


func _has_mercy_choice(event: Dictionary) -> bool:
	if bool(event.get("mercy_choice", false)):
		return true
	var src: String = str(event.get("source", ""))
	if src.begins_with("template:") and _gd != null:
		var tid: String = src.trim_prefix("template:")
		for t in _gd.event_templates().get("templates", []):
			if t is Dictionary and str((t as Dictionary).get("id", "")) == tid:
				return bool((t as Dictionary).get("mercy_choice", false))
	return false


func _give(c: Character, item: Dictionary, items: Array) -> String:
	item["owner_id"] = c.id
	var iid: String = _db.add("items", item)
	items.append(iid)
	return "gained %s [%s]" % [_items.describe(item), iid]
