class_name QuestRules
extends RefCounted
## Pure static Formulas A-E and rule helpers for Template Quests (#31).
## Every gameplay constant is read from [code]assets/data/quest_rules.json[/code],
## [code]assets/data/session_actions.json[/code], [code]assets/data/events_budgets.json[/code],
## and [code]assets/data/items_rarity.json[/code]; zero hardcoded gameplay numbers and zero side effects.
## Design: [code]design/gdd/quests.md[/code] (Formulas A-E, Rules 4-18).
##
## Usage:
## [codeblock]
## var b := QuestRules.compute_budget(gd, "ordinary", 0, stages, 0)
## var dl := QuestRules.compute_deadline(gd, "ordinary", stages, 0)
## var rx := QuestRules.compute_reactions(gd, db, quest, "completed")
## [/codeblock]

## Data file id for quest rules and tuning knobs.
const RULES_FILE := "quest_rules"
## Data file id for authored quest templates.
const TEMPLATES_FILE := "quest_templates"
## Float comparison epsilon for floor/ceil boundaries.
const EPS := 1e-9


## Returns the loaded [code]quest_rules.json[/code] root Dictionary (merged with [param override] if non-empty).
static func config(gd: GameData, override: Dictionary = {}) -> Dictionary:
	var base: Dictionary = gd.file(RULES_FILE) if (gd != null and gd.registry.has_file(RULES_FILE)) else {}
	if override.is_empty():
		return base
	var merged: Dictionary = base.duplicate(true)
	for k in override.keys():
		if override[k] is Dictionary and merged.get(k) is Dictionary:
			var sub: Dictionary = Dictionary(merged[k]).duplicate(true)
			for sk in (override[k] as Dictionary).keys():
				sub[sk] = override[k][sk]
			merged[k] = sub
		else:
			merged[k] = override[k]
	return merged


## Returns the loaded [code]quest_templates.json[/code] root Dictionary.
static func templates_file(gd: GameData) -> Dictionary:
	if gd == null or not gd.registry.has_file(TEMPLATES_FILE):
		return {}
	return gd.file(TEMPLATES_FILE)


## Returns all authored quest templates from [code]quest_templates.json[/code].
static func templates(gd: GameData) -> Array:
	return Array(templates_file(gd).get("templates", []))


## Returns the config block for [param tier] ("errand", "ordinary", "major", "legendary"), or {}.
static func tier_cfg(gd: GameData, tier: String, rules_override: Dictionary = {}) -> Dictionary:
	return Dictionary(config(gd, rules_override).get("tiers", {}).get(tier, {}))


## Returns the ascending ordinal (0..3) of [param tier] in [code]tier_order[/code], or -1 if unknown.
static func tier_rank(gd: GameData, tier: String, rules_override: Dictionary = {}) -> int:
	return Array(config(gd, rules_override).get("tier_order", [])).find(tier)


## Returns the realm index corresponding to [code]legendary_min_realm[/code] (Core Formation = 2).
static func legendary_min_realm_index(gd: GameData, rules_override: Dictionary = {}) -> int:
	var rid: String = str(config(gd, rules_override).get("legendary_min_realm", ""))
	return gd.realm_index(rid) if (gd != null and rid != "") else -1


## Downgrades [code]legendary[/code] to [code]major[/code] below [code]legendary_min_realm[/code] (Rule 14, AC-QS-82, AC-QS-148).
static func downgrade_tier_for_realm(gd: GameData, tier: String, realm_idx: int, rules_override: Dictionary = {}) -> String:
	var min_r: int = legendary_min_realm_index(gd, rules_override)
	if tier == "legendary" and min_r >= 0 and realm_idx < min_r:
		return "major"
	return tier


## Formula A [code]I_r[/code]: one season of base sect mission income at [param realm_idx]
## ([code]sect_base_income * income_realm_scale[realm][/code], AC-QS-77).
static func realm_income_Ir(gd: GameData, realm_idx: int) -> int:
	var realm_id: String = str(gd.realm(realm_idx).id)
	var mission: Dictionary = Dictionary(gd.session().get("mission", {}))
	var base_income: float = float(mission.get("sect_base_income", 0.0))
	var scale: float = float(Dictionary(mission.get("income_realm_scale", {})).get(realm_id, 0.0))
	return int(roundf(base_income * scale))


## Formula A [code]E_r[/code]: the realm's [code]linh_thach_max[/code] in [code]events_budgets.json[/code] (AC-QS-77).
static func realm_ceiling_Er(gd: GameData, realm_idx: int) -> int:
	return int(gd.realm_budget(realm_idx).get("linh_thach_max", 0))


## Reads [code]hostile_threshold[/code] from [code]session_actions.json[/code] (default -30).
static func hostile_threshold(gd: GameData) -> int:
	return int(Dictionary(gd.session().get("talk", {})).get("hostile_threshold", -30))


## Reads [code]relationship_min[/code] and [code]relationship_max[/code] from [code]session_actions.json[/code].
static func relationship_bounds(gd: GameData) -> Vector2i:
	var talk: Dictionary = Dictionary(gd.session().get("talk", {}))
	return Vector2i(int(talk.get("relationship_min", -100)), int(talk.get("relationship_max", 100)))


## Formula D fail/lapse floor: [code]hostile_threshold + 1[/code] (-29, AC-QS-51, AC-QS-77).
static func fail_relationship_floor(gd: GameData, rules_override: Dictionary = {}) -> int:
	var cfg: Dictionary = config(gd, rules_override)
	if cfg.has("fail_relationship_floor") and rules_override.has("fail_relationship_floor"):
		return int(cfg["fail_relationship_floor"])
	return hostile_threshold(gd) + 1


## Reads [code]tree_point_w[/code] from [code]quest_rules.json[/code] (2.58, AC-QS-77).
static func tree_point_w(gd: GameData, rules_override: Dictionary = {}) -> float:
	return float(config(gd, rules_override).get("tree_point_w", 0.0))


## Returns the realm's normal rarity cap from [code]quest_rules.json[/code] (Rule 14).
static func realm_rarity_cap(gd: GameData, realm_idx: int, rules_override: Dictionary = {}) -> int:
	var realm_id: String = str(gd.realm(realm_idx).id)
	return int(Dictionary(config(gd, rules_override).get("realm_rarity_cap", {})).get(realm_id, 0))


## Returns the maximum rarity allowed for an above-cap Legendary item at [param realm_idx] (Rule 14, AC-QS-86).
static func legendary_rarity_cap(gd: GameData, realm_idx: int, rules_override: Dictionary = {}) -> int:
	var cfg: Dictionary = config(gd, rules_override)
	var base_cap: int = realm_rarity_cap(gd, realm_idx, rules_override)
	var bonus: int = int(cfg.get("legendary_rarity_bonus", 0))
	var hard_max: int = int(cfg.get("rarity_max", int(gd.file("items_rarity").get("rarity_max", 6))))
	return mini(base_cap + bonus, hard_max)


## Returns [code]s_i[/code], the season cost of a single stage (Formula A).
## [code]visit[/code] and [code]reach[/code] always cost 0; [code]mission[/code] uses its stated seasons.
static func stage_seasons(gd: GameData, stage: Dictionary, rules_override: Dictionary = {}) -> int:
	var kind: String = str(stage.get("kind", ""))
	if kind == "visit" or kind == "reach":
		return 0
	var defaults: Dictionary = Dictionary(config(gd, rules_override).get("stage_seasons_default", {}))
	if kind == "mission":
		if stage.has("seasons"):
			return int(stage["seasons"])
		if stage.has("mission_seasons"):
			return int(stage["mission_seasons"])
		return int(defaults.get("mission", 1))
	if stage.has("seasons"):
		return int(stage["seasons"])
	return int(defaults.get(kind, 0))


## Returns [code]w_i[/code], the stage window (Formula C), falling back to [code]stage_window_default[/code].
static func stage_window(gd: GameData, stage: Dictionary, rules_override: Dictionary = {}) -> int:
	if stage.has("window"):
		return int(stage["window"])
	var kind: String = str(stage.get("kind", ""))
	if kind == "mission":
		return maxi(1, stage_seasons(gd, stage, rules_override))
	var defaults: Dictionary = Dictionary(config(gd, rules_override).get("stage_window_default", {}))
	return int(defaults.get(kind, 1))


## Formula A: computes the quest reward budget, per-stage ceilings, final stage pay, and cash/deliver/tu_vi/wealth limits.
## Returns [code]{S_plan, I_r, E_r, B, stage_pays, final_pay, cash_max, deliver_max, tu_vi_max, wealth_max}[/code].
static func compute_budget(
	gd: GameData,
	tier: String,
	realm_idx: int,
	stages: Array,
	travel_seasons: int,
	rules_override: Dictionary = {}
) -> Dictionary:
	var cfg: Dictionary = config(gd, rules_override)
	var tcfg: Dictionary = tier_cfg(gd, tier, rules_override)
	var i_r: int = realm_income_Ir(gd, realm_idx)
	var e_r: int = realm_ceiling_Er(gd, realm_idx)
	var s_list: Array[int] = []
	var s_sum: int = 0
	for raw in stages:
		var s_i: int = stage_seasons(gd, raw as Dictionary, rules_override) if raw is Dictionary else 0
		s_list.append(s_i)
		s_sum += s_i
	var s_plan: int = s_sum + maxi(0, travel_seasons)
	var reward_mult: float = float(tcfg.get("reward_mult", 0.0))
	var cap_mult: float = float(tcfg.get("cap_mult", 0.0))
	var raw_b: float = minf(reward_mult * float(i_r) * float(s_plan), cap_mult * float(e_r))
	var b: int = int(floor(maxf(0.0, raw_b) + EPS))
	var share: float = float(cfg.get("stage_reward_share", 0.0))
	var stage_pays: Array[int] = []
	var non_final_sum: int = 0
	var n: int = s_list.size()
	for idx in range(n):
		if idx < n - 1:
			var pay_i: int = 0
			if s_plan > 0 and s_list[idx] > 0:
				pay_i = int(floor(share * float(b) * float(s_list[idx]) / float(s_plan) + EPS))
			stage_pays.append(pay_i)
			non_final_sum += pay_i
		else:
			stage_pays.append(b - non_final_sum)
	var final_pay: int = stage_pays[n - 1] if n > 0 else b
	var cash_max: int = int(floor(float(cfg.get("quest_cash_share", 0.0)) * float(b) + EPS))
	var deliver_max: int = int(floor(float(cfg.get("deliver_share", 0.0)) * float(b) + EPS))
	var tu_vi_max: float = float(cfg.get("quest_tu_vi_share", 0.0)) * float(gd.realm_budget(realm_idx).get("tu_vi_pct_max", 0.0))
	var wealth_max: int = int(floor(float(cfg.get("world_wealth_share", 0.0)) * float(b) + EPS))
	return {
		"S_plan": s_plan,
		"I_r": i_r,
		"E_r": e_r,
		"B": b,
		"stage_pays": stage_pays,
		"final_pay": final_pay,
		"cash_max": cash_max,
		"deliver_max": deliver_max,
		"tu_vi_max": tu_vi_max,
		"wealth_max": wealth_max,
	}


## Formula C: computes [code]window_sum[/code], [code]deadline[/code], and [code]deadline_max[/code].
## Returns [code]{window_sum, deadline, deadline_max, ok}[/code].
static func compute_deadline(
	gd: GameData,
	tier: String,
	stages: Array,
	travel_seasons: int,
	rules_override: Dictionary = {}
) -> Dictionary:
	var cfg: Dictionary = config(gd, rules_override)
	var tcfg: Dictionary = tier_cfg(gd, tier, rules_override)
	var w_sum: int = maxi(0, travel_seasons)
	for raw in stages:
		if raw is Dictionary:
			w_sum += stage_window(gd, raw as Dictionary, rules_override)
	var slack: float = float(cfg.get("slack", 0.0))
	var dl_max: int = int(tcfg.get("deadline_max", 0))
	var raw_dl: int = int(ceil(float(w_sum) * (1.0 + slack) - EPS))
	var dl: int = mini(raw_dl, dl_max)
	return {
		"window_sum": w_sum,
		"deadline": dl,
		"deadline_max": dl_max,
		"ok": w_sum <= dl_max and dl_max > 0,
	}


## Formula B helper: fight power [code]F = Off * ehp[/code] scaled by current vitality.
static func fight_power_F(c: Character, gd: GameData, db: WorldDB, sheet: StatSheet) -> float:
	if c == null or gd == null:
		return 1.0
	var s: StatSheet = sheet if sheet != null else StatSheet.build(c, gd, db, null)
	var p: Dictionary = CombatPower.compute(c, gd, db, s)
	var kh: float = CharacterRules.khi_huyet_max(c, gd, s).total
	var off: float = maxf(float(p.get("offense", 1.0)), 1.0)
	var def_v: float = maxf(float(p.get("defense", 0.0)), 0.0)
	var vit: float = clampf(c.vitality, float(gd.combat().duel.injured_power_floor), 1.0)
	var ehp: float = maxf((kh + def_v) * vit, 1.0)
	return off * ehp


## Formula B: fight ratio [code]r = F_opp / F_player[/code].
static func fight_ratio(f_opp: float, f_player: float) -> float:
	return f_opp / maxf(f_player, EPS)


## Returns true if [param player] already satisfies a [code]reach[/code] stage's target (Rule 5, AC-QS-16).
static func is_reach_met(player: Character, sheet: StatSheet, stage: Dictionary) -> bool:
	if player == null:
		return false
	if stage.has("target_realm"):
		var req_realm: int = int(stage["target_realm"])
		var req_stage: int = int(stage.get("target_stage", 0))
		if player.realm_index > req_realm:
			return true
		if player.realm_index == req_realm and player.stage >= req_stage:
			return true
		return false
	if stage.has("target_stage"):
		return player.stage >= int(stage["target_stage"])
	if stage.has("target_level"):
		return player.level >= int(stage["target_level"])
	if stage.has("target_stat"):
		var stat_id: String = str(stage["target_stat"])
		var req_val: float = float(stage.get("target_value", 0.0))
		var cur_val: float = sheet.effective(stat_id, player) if sheet != null else float(player.base_stat(stat_id))
		return cur_val >= req_val - EPS
	return false


## Provisional Realms time estimate (in seasons) for [param player] to satisfy a [code]reach[/code] stage.
## Returns 0.0 when already met; tests may inject [code]reach_estimate_fn[/code] into [method QuestValidator.validate_plan].
static func estimate_reach_seasons(
	gd: GameData,
	db: WorldDB,
	player: Character,
	sheet: StatSheet,
	stage: Dictionary,
	rules_override: Dictionary = {}
) -> float:
	if is_reach_met(player, sheet, stage):
		return 0.0
	var est_cfg: Dictionary = Dictionary(config(gd, rules_override).get("reach_estimate", {}))
	var per_level: float = float(est_cfg.get("seasons_per_level", 1.5))
	var per_stage: float = float(est_cfg.get("seasons_per_stage", 4.0))
	var per_realm: float = float(est_cfg.get("seasons_per_realm", 12.0))
	var per_stat: float = float(est_cfg.get("seasons_per_stat_point", 1.0))

	if stage.has("target_level"):
		var target_lvl: int = int(stage["target_level"])
		var lvl_diff: int = maxi(1, target_lvl - player.level)
		if gd != null and sheet != null:
			var density: float = 1.0
			if db != null and player.location_id != "":
				density = float(db.get_record("places", player.location_id).get("density", 1.0))
			var rate: float = CultivationRules.rate_per_season(player, gd, db, sheet, density).total
			if rate > EPS:
				var need_tu_vi: float = maxf(0.0, CultivationRules.level_requirement(player, gd) - player.tu_vi)
				for lv in range(player.level + 1, target_lvl):
					need_tu_vi += Ladder.level_cost(gd, lv)
				return need_tu_vi / rate
		return float(lvl_diff) * per_level

	if stage.has("target_realm"):
		var r_diff: int = maxi(0, int(stage["target_realm"]) - player.realm_index)
		var s_diff: int = int(stage.get("target_stage", 0)) - player.stage
		return maxf(1.0, float(r_diff) * per_realm + float(s_diff) * per_stage)

	if stage.has("target_stage"):
		var st_diff: int = maxi(1, int(stage["target_stage"]) - player.stage)
		return float(st_diff) * per_stage

	if stage.has("target_stat"):
		var stat_id: String = str(stage["target_stat"])
		var req_val: float = float(stage.get("target_value", 0.0))
		var cur_val: float = sheet.effective(stat_id, player) if sheet != null else float(player.base_stat(stat_id))
		return maxf(1.0, (req_val - cur_val) * per_stat)

	return per_stage


## Formula D: computes [code]gain_w = sum(amount_key * W_key) + tree_points * tree_point_w[/code].
## Accepts [param boon] with [code]mods[/code] ([{stat, value}]), [code]stats[/code] ({stat: value}), and/or [code]tree_points[/code].
static func boon_weight(gd: GameData, boon: Dictionary, rules_override: Dictionary = {}) -> float:
	if boon.is_empty():
		return 0.0
	var cfg: Dictionary = config(gd, rules_override)
	var weights: Dictionary = Dictionary(cfg.get("boon_stat_weights", {}))
	var tp_w: float = float(cfg.get("tree_point_w", 0.0))
	var total: float = 0.0
	for raw in Array(boon.get("mods", [])):
		if raw is Dictionary:
			var stat_k: String = str((raw as Dictionary).get("stat", ""))
			var val: float = float((raw as Dictionary).get("value", 0.0))
			total += val * float(weights.get(stat_k, 0.0))
	var stats_map: Dictionary = Dictionary(boon.get("stats", {}))
	for stat_k in stats_map.keys():
		total += float(stats_map[stat_k]) * float(weights.get(str(stat_k), 0.0))
	var tp: int = int(boon.get("tree_points", 0))
	total += float(tp) * tp_w
	return total


## Formula D: remaining lifetime room for lasting gains on a character (AC-QS-66..68).
## Returns [code]{cap_w, per_quest_w, remaining_w, allowed_w, tree_point_cap, remaining_tree_points}[/code].
static func lasting_gain_room(
	gd: GameData,
	quest_gain_total_w: float,
	quest_tree_points_used: int = 0,
	rules_override: Dictionary = {}
) -> Dictionary:
	var cfg: Dictionary = config(gd, rules_override)
	var cap_w: float = float(cfg.get("quest_gain_cap_w", 0.0))
	var per_q: float = float(cfg.get("quest_boon_w", 0.0))
	var tp_cap: int = int(cfg.get("quest_tree_point_cap", 0))
	var rem_w: float = maxf(0.0, cap_w - maxf(0.0, quest_gain_total_w))
	var allowed_w: float = minf(per_q, rem_w)
	return {
		"cap_w": cap_w,
		"per_quest_w": per_q,
		"remaining_w": rem_w,
		"allowed_w": allowed_w,
		"tree_point_cap": tp_cap,
		"remaining_tree_points": maxi(0, tp_cap - maxi(0, quest_tree_points_used)),
	}


## Formula D / Rule 10: orphan payout [code]floor(orphan_reward_share * unpaid * s' / S')[/code]
## with [code]s' = max(1, s_cur)[/code] and [code]S' = max(s', s_rem)[/code] (AC-QS-53, AC-QS-90, AC-QS-99).
static func orphan_payout(
	gd: GameData,
	unpaid: int,
	s_cur: int,
	s_rem: int,
	rules_override: Dictionary = {}
) -> int:
	if unpaid <= 0:
		return 0
	var share: float = float(config(gd, rules_override).get("orphan_reward_share", 0.0))
	var s_eff: int = maxi(1, s_cur)
	var s_tot: int = maxi(s_eff, s_rem)
	return int(floor(share * float(unpaid) * float(s_eff) / float(s_tot) + EPS))


## Formula D fail/lapse floor clamp: never lowers an NPC below [code]hostile_threshold + 1[/code] (-29)
## and never raises an NPC already at or below that floor (AC-QS-51, AC-QS-109).
static func apply_fail_floor(current_att: int, delta: int, gd: GameData, rules_override: Dictionary = {}) -> int:
	if delta >= 0:
		return 0
	var floor_v: int = fail_relationship_floor(gd, rules_override)
	if current_att <= floor_v:
		return 0
	var after: int = maxi(floor_v, current_att + delta)
	return after - current_att


## Resolves direct living ties of person [param root_id] in [param db]:
## [code]{master: String, disciples: Array[String], sect_head: String}[/code] (Rule 16).
static func direct_ties_of(db: WorldDB, root_id: String) -> Dictionary:
	var out := {"master": "", "disciples": [], "sect_head": ""}
	if db == null or root_id == "":
		return out
	var root: Dictionary = db.get_record("people", root_id)
	if root.is_empty():
		return out

	# Master: prefer Ties store, fall back to person.master_id.
	var master_id: String = Ties.master_of(db, root_id)
	if master_id == "":
		var mid: String = str(root.get("master_id", ""))
		if mid != "" and mid != root_id and bool(db.get_record("people", mid).get("alive", false)):
			master_id = mid
	out["master"] = master_id

	# Disciples: living people whose master is root_id via Ties or master_id.
	var disc_set: Dictionary = {}
	for rec in db.ties_of(root_id):
		var m: String = str(Dictionary(rec.get("pin", {})).get("su_do", ""))
		if m == root_id:
			var other: String = str(rec.get("b", "")) if str(rec.get("a", "")) == root_id else str(rec.get("a", ""))
			if other != "" and other != root_id and bool(db.get_record("people", other).get("alive", false)):
				disc_set[other] = true
	for p in db.living():
		var pid: String = str(p.get("id", ""))
		if pid != "" and pid != root_id and str(p.get("master_id", "")) == root_id:
			disc_set[pid] = true
	var disc_ids: Array = disc_set.keys()
	disc_ids.sort()
	out["disciples"] = disc_ids

	# Sect head: living leader of root's active sect (never root itself).
	var sid: String = str(root.get("sect_id", ""))
	if sid != "":
		var sect: Dictionary = db.get_record("sects", sid)
		if not sect.is_empty() and str(sect.get("status", "active")) == "active":
			var hid: String = str(sect.get("leader_id", ""))
			if hid != "" and hid != root_id and bool(db.get_record("people", hid).get("alive", false)):
				out["sect_head"] = hid
	return out


## Formula E: computes deterministic attitude changes for all reacting living NPCs on quest ending
## or immediate knockout death ([param killed_now] = true).
## Enforces: board zero-attitude (Rule 18), master==sect_head single largest-share dedup (AC-QS-108),
## offerer-side-first order for NPCs on both sides (AC-QS-108), -29 fail/lapse floor (AC-QS-51, AC-QS-109),
## and [-100, 100] attitude clamping (AC-QS-110).
## Returns Array of [code]{person_id, delta, before, after, side, role, reason}[/code].
static func compute_reactions(
	gd: GameData,
	db: WorldDB,
	quest: Dictionary,
	ending: String,
	killed_now: bool = false,
	rules_override: Dictionary = {}
) -> Array:
	var results: Array = []
	if db == null or quest.is_empty():
		return results
	var offer_kind: String = str(quest.get("offer_kind", "person"))
	if offer_kind == "board":
		return results

	var cfg: Dictionary = config(gd, rules_override)
	var bounds: Vector2i = relationship_bounds(gd)
	var sim_att: Dictionary = {}

	# Immediate adversary knockout kill (Rule 17, AC-QS-129): adversary's ties react to -adversary_attitude_max.
	if killed_now:
		var adv_id: String = _resolve_adversary_root(db, quest)
		if adv_id != "":
			var d_kill: int = -int(cfg.get("adversary_attitude_max", 30))
			_append_side_reactions(results, sim_att, gd, db, cfg, bounds, adv_id, d_kill, "adversary", "adversary_killed", false, true, rules_override)
		return results

	if ending in ["dropped", "declined", "withdrawn"]:
		return results

	var offerer_root: String = _resolve_offerer_root(db, quest)
	if ending == "failed" or ending == "lapsed":
		if offerer_root == "":
			return results
		var d_fail: int = int(cfg.get("fail_relationship_failed", -15)) if ending == "failed" else int(cfg.get("fail_relationship_lapsed", -8))
		_append_side_reactions(results, sim_att, gd, db, cfg, bounds, offerer_root, d_fail, "offerer", ending, true, false, rules_override)
		return results

	if ending == "completed" or ending == "orphaned_completed":
		# 1. Offerer side first (Formula E).
		if offerer_root != "":
			var offerer_rel: int = _planned_offerer_relationship_reward(quest)
			if offerer_rel != 0:
				_append_side_reactions(results, sim_att, gd, db, cfg, bounds, offerer_root, offerer_rel, "offerer", "completed_reward", false, false, rules_override)
		# 2. Adversary side second (Formula E).
		var adv_root: String = _resolve_adversary_root(db, quest)
		if adv_root != "":
			var sev_sum: int = _adversary_severity_sum(cfg, quest)
			if sev_sum > 0:
				var adv_max: int = int(cfg.get("adversary_attitude_max", 30))
				var d_adv: int = -mini(sev_sum, adv_max)
				var adv_dead: bool = not bool(db.get_record("people", adv_root).get("alive", false))
				_append_side_reactions(results, sim_att, gd, db, cfg, bounds, adv_root, d_adv, "adversary", "adversary_harmed", false, adv_dead, rules_override)
	return results


static func _resolve_offerer_root(db: WorldDB, quest: Dictionary) -> String:
	var rid: String = str(quest.get("offerer_root_id", quest.get("offerer_id", "")))
	if rid == "":
		return ""
	if db.table_of(rid) == "sects":
		return str(db.get_record("sects", rid).get("leader_id", ""))
	return rid


static func _resolve_adversary_root(db: WorldDB, quest: Dictionary) -> String:
	var aid: String = str(quest.get("adversary_root_id", quest.get("adversary_id", "")))
	if aid == "":
		return ""
	if db.table_of(aid) == "sects":
		return str(db.get_record("sects", aid).get("leader_id", ""))
	return aid


static func _planned_offerer_relationship_reward(quest: Dictionary) -> int:
	if quest.has("offerer_relationship_reward"):
		return int(quest["offerer_relationship_reward"])
	var plan: Dictionary = Dictionary(quest.get("plan", quest))
	var total: int = 0
	for raw_stage in Array(plan.get("stages", [])):
		if not (raw_stage is Dictionary):
			continue
		for raw_eff in Array((raw_stage as Dictionary).get("rewards", (raw_stage as Dictionary).get("effects", []))):
			if not (raw_eff is Dictionary):
				continue
			var eff: Dictionary = raw_eff as Dictionary
			if str(eff.get("type", "")) == "relationship":
				var target_role: String = str(eff.get("role", "offerer"))
				if target_role == "offerer" or target_role == "":
					total += int(eff.get("amount", 0))
	return total


static func _adversary_severity_sum(cfg: Dictionary, quest: Dictionary) -> int:
	var sev_map: Dictionary = Dictionary(cfg.get("severity", {}))
	var plan: Dictionary = Dictionary(quest.get("plan", quest))
	var outcomes: Array = Array(quest.get("outcomes", plan.get("outcomes", [])))
	var skip_death: bool = bool(quest.get("adversary_killed_at_knockout", false))
	var total: int = 0
	for raw in outcomes:
		if not (raw is Dictionary):
			continue
		var oc: Dictionary = raw as Dictionary
		if str(oc.get("on", "")) != "completed":
			continue
		var role: String = str(oc.get("role", ""))
		if not (role in ["adversary", "adversary_ties", "adversary_sect"]):
			continue
		var eff: String = str(oc.get("effect", ""))
		if eff == "death" and skip_death:
			continue
		total += int(sev_map.get(eff, 0))
	return total


static func _append_side_reactions(
	results: Array,
	sim_att: Dictionary,
	gd: GameData,
	db: WorldDB,
	cfg: Dictionary,
	bounds: Vector2i,
	root_id: String,
	d_root: int,
	side: String,
	reason: String,
	use_fail_floor: bool,
	skip_root_record: bool,
	rules_override: Dictionary
) -> void:
	if d_root == 0 or root_id == "":
		return
	var root_rec: Dictionary = db.get_record("people", root_id)
	if not skip_root_record and not root_rec.is_empty() and bool(root_rec.get("alive", false)):
		_push_reaction(results, sim_att, gd, db, bounds, root_id, d_root, side, "root", reason, use_fail_floor, rules_override)

	var ties: Dictionary = direct_ties_of(db, root_id)
	var tie_shares: Dictionary = Dictionary(cfg.get("tie_share", {}))
	# Deduplicate ties on this side: one person holding multiple roles takes ONLY the larger share (AC-QS-108).
	var best_share: Dictionary = {}
	var best_role: Dictionary = {}
	var ordered_ids: Array[String] = []

	var master_id: String = str(ties.get("master", ""))
	if master_id != "" and master_id != root_id:
		_consider_tie(best_share, best_role, ordered_ids, master_id, "master", float(tie_shares.get("master", 0.5)))

	for did_raw in Array(ties.get("disciples", [])):
		var did: String = str(did_raw)
		if did != "" and did != root_id:
			_consider_tie(best_share, best_role, ordered_ids, did, "disciple", float(tie_shares.get("disciple", 0.5)))

	var head_id: String = str(ties.get("sect_head", ""))
	if head_id != "" and head_id != root_id:
		_consider_tie(best_share, best_role, ordered_ids, head_id, "sect_head", float(tie_shares.get("sect_head", 0.25)))

	for pid in ordered_ids:
		var rec: Dictionary = db.get_record("people", pid)
		if rec.is_empty() or not bool(rec.get("alive", false)):
			continue
		var d_tie: int = int(float(d_root) * float(best_share[pid]))
		if d_tie == 0:
			continue
		_push_reaction(results, sim_att, gd, db, bounds, pid, d_tie, side, str(best_role[pid]), reason, use_fail_floor, rules_override)


static func _consider_tie(
	best_share: Dictionary,
	best_role: Dictionary,
	ordered_ids: Array[String],
	pid: String,
	role: String,
	share: float
) -> void:
	if not best_share.has(pid):
		ordered_ids.append(pid)
		best_share[pid] = share
		best_role[pid] = role
	elif share > float(best_share[pid]) + EPS:
		best_share[pid] = share
		best_role[pid] = role


static func _push_reaction(
	results: Array,
	sim_att: Dictionary,
	gd: GameData,
	db: WorldDB,
	bounds: Vector2i,
	pid: String,
	raw_delta: int,
	side: String,
	role: String,
	reason: String,
	use_fail_floor: bool,
	rules_override: Dictionary
) -> void:
	var rec: Dictionary = db.get_record("people", pid)
	var before: int = int(sim_att[pid]) if sim_att.has(pid) else int(rec.get("attitude", 0))
	var delta: int = apply_fail_floor(before, raw_delta, gd, rules_override) if use_fail_floor else (clampi(before + raw_delta, bounds.x, bounds.y) - before)
	var after: int = clampi(before + delta, bounds.x, bounds.y)
	sim_att[pid] = after
	results.append({
		"person_id": pid,
		"delta": delta,
		"before": before,
		"after": after,
		"side": side,
		"role": role,
		"reason": reason,
	})
