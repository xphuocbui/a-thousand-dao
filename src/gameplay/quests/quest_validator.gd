class_name QuestValidator
extends RefCounted
## Strict load-time and offer-time validator for Template Quests (#31).
## Never repairs an invalid plan: every plan over any limit is rejected cleanly (Rule 4, AC-QS-10).
## Supports injectable [code]fight_power_fn[/code], [code]reach_estimate_fn[/code], and [code]rules_override[/code]
## in [method validate_plan] for deterministic unit tests (FX-STUB).
## Design: [code]design/gdd/quests.md[/code] (Rules 4, 5, 9, 11, 13-18; Formulas A-E).
##
## Usage:
## [codeblock]
## var rule_errs := QuestValidator.validate_rules(gd)
## var tpl_errs := QuestValidator.validate_templates(gd)
## var check := QuestValidator.validate_plan(gd, db, player, sheet, plan)
## [/codeblock]

const _EPS := 1e-6
const _QuestRules := preload("res://src/gameplay/quests/quest_rules.gd")


## Validates [code]quest_rules.json[/code] (or [param raw] override Dictionary) against all GDD bounds
## (AC-QS-77, AC-QS-78, AC-QS-138). Returns Array of error strings ([] when valid).
static func validate_rules(gd: GameData, raw: Variant = null) -> Array:
	var errors: Array = []
	var cfg: Dictionary = raw as Dictionary if raw is Dictionary else _QuestRules.config(gd)
	if cfg.is_empty():
		errors.append("quest_rules.json is empty or missing")
		return errors

	_check_bound(cfg, "stage_reward_share", "stage_reward_share_bounds", errors)
	_check_bound(cfg, "slack", "slack_bounds", errors)
	_check_bound(cfg, "stage_hold", "stage_hold_bounds", errors)
	_check_bound(cfg, "quest_boon_w", "quest_boon_w_bounds", errors)
	_check_bound(cfg, "quest_gain_cap_w", "quest_gain_cap_w_bounds", errors)

	for unit_key in ["quest_cash_share", "deliver_share", "quest_tu_vi_share", "orphan_reward_share", "world_wealth_share", "world_injury_max"]:
		var v: float = float(cfg.get(unit_key, -1.0))
		if v < 0.0 - _EPS or v > 1.0 + _EPS:
			errors.append("%s must be in [0, 1], got %s" % [unit_key, str(v)])

	var st_max: int = int(cfg.get("world_standing_max", -1))
	if st_max < 0 or st_max > 20:
		errors.append("world_standing_max must be in [0, 20], got %d" % st_max)

	if float(cfg.get("tree_point_w", 0.0)) <= 0.0:
		errors.append("tree_point_w must be > 0")
	if int(cfg.get("template_travel_max", -1)) < 0:
		errors.append("template_travel_max must be >= 0")

	var tiers: Dictionary = Dictionary(cfg.get("tiers", {}))
	var tier_order: Array = Array(cfg.get("tier_order", []))
	if tier_order.is_empty():
		errors.append("tier_order must not be empty")
	var share_sum: float = 0.0
	for t_raw in tier_order:
		var t: String = str(t_raw)
		if not tiers.has(t):
			errors.append("tiers missing '%s'" % t)
			continue
		var tc: Dictionary = Dictionary(tiers[t])
		share_sum += float(tc.get("share", 0.0))
		if int(tc.get("stages_min", 0)) < 1 or int(tc.get("stages_max", 0)) < int(tc.get("stages_min", 0)):
			errors.append("tier '%s' has invalid stage bounds" % t)
		if int(tc.get("deadline_max", 0)) < 1:
			errors.append("tier '%s' deadline_max must be >= 1" % t)
	if not tier_order.is_empty() and absf(share_sum - 1.0) > 0.0001:
		errors.append("tier_share must sum to 1.0, got %.4f" % share_sum)

	if gd != null:
		var lmr: String = str(cfg.get("legendary_min_realm", ""))
		if lmr == "" or gd.realm_index(lmr) < 0:
			errors.append("unknown legendary_min_realm '%s'" % lmr)
	return errors


## Validates every template in [code]quest_templates.json[/code] (or [param raw]) at load time
## across all applicable realms (Rules 3, 4, 5, 9, 11, 14, 15, 17, 18; AC-QS-76, AC-QS-118, AC-QS-133, AC-QS-134, AC-QS-142, AC-QS-143, AC-QS-149).
static func validate_templates(gd: GameData, raw: Variant = null, rules_override: Dictionary = {}) -> Array:
	var errors: Array = []
	var doc: Dictionary = raw as Dictionary if raw is Dictionary else _QuestRules.templates_file(gd)
	if doc.is_empty():
		errors.append("quest_templates.json is empty or missing")
		return errors
	var tpls: Array = Array(doc.get("templates", []))
	if tpls.is_empty():
		errors.append("quest_templates.json has no templates")
		return errors
	var seen_ids: Dictionary = {}
	for item in tpls:
		if not (item is Dictionary):
			errors.append("quest_templates.json contains non-Dictionary entry")
			continue
		var tpl: Dictionary = item as Dictionary
		var tid: String = str(tpl.get("id", ""))
		if tid == "":
			errors.append("template missing id")
			continue
		if seen_ids.has(tid):
			errors.append("duplicate template id '%s'" % tid)
		seen_ids[tid] = true
		for e in validate_template(gd, tpl, rules_override):
			errors.append("[%s] %s" % [tid, str(e)])
	return errors


## Validates a single authored quest template at load time. Returns Array of error strings.
static func validate_template(gd: GameData, tpl: Dictionary, rules_override: Dictionary = {}) -> Array:
	var errors: Array = []
	var cfg: Dictionary = _QuestRules.config(gd, rules_override)
	var tiers: Dictionary = Dictionary(cfg.get("tiers", {}))
	var tier: String = str(tpl.get("tier", ""))
	if not tiers.has(tier):
		errors.append("unknown tier '%s'" % tier)
		return errors
	var tcfg: Dictionary = Dictionary(tiers[tier])

	if str(tpl.get("name", "")).strip_edges() == "":
		errors.append("template name must not be empty")
	var offer_texts: Array = Array(tpl.get("offer_text", []))
	if offer_texts.is_empty() or str(offer_texts[0]).strip_edges() == "":
		errors.append("offer_text must have at least one non-empty line")

	var allowed_offer_kinds: Array = Array(cfg.get("offer_kinds", []))
	var offer_kinds: Array = Array(tpl.get("offer_kinds", []))
	if offer_kinds.is_empty():
		errors.append("offer_kinds must not be empty")
	var is_board_tpl: bool = false
	var is_person_or_sect: bool = false
	for ok_raw in offer_kinds:
		var ok: String = str(ok_raw)
		if not allowed_offer_kinds.has(ok):
			errors.append("unknown offer_kind '%s'" % ok)
		if ok == "board":
			is_board_tpl = true
		if ok == "person" or ok == "sect":
			is_person_or_sect = true

	if is_board_tpl and not bool(tcfg.get("board_allowed", false)):
		errors.append("board template cannot have tier '%s'" % tier)
	if is_person_or_sect and str(tpl.get("stake_text", "")).strip_edges() == "":
		errors.append("person/sect template requires non-empty stake_text")

	var allowed_places: Array = Array(cfg.get("allowed_place_kinds", []))
	for pk_raw in Array(tpl.get("place_kinds", ["any"])):
		var pk: String = str(pk_raw)
		if not allowed_places.has(pk):
			errors.append("unknown place_kind '%s'" % pk)

	# Slots validation.
	var allowed_binds: Array = Array(cfg.get("allowed_slot_binds", []))
	var slots: Dictionary = Dictionary(tpl.get("slots", {}))
	for s_name in slots.keys():
		if not (slots[s_name] is Dictionary):
			errors.append("slot '%s' must be a Dictionary" % str(s_name))
			continue
		var sdef: Dictionary = slots[s_name] as Dictionary
		var bkind: String = str(sdef.get("bind", ""))
		if not allowed_binds.has(bkind):
			errors.append("slot '%s' has unknown bind rule '%s'" % [str(s_name), bkind])
		if is_board_tpl and str(s_name) == "adversary" and bkind != "none" and not bool(sdef.get("optional", false)):
			errors.append("board template cannot require an adversary slot")

	# Realm band.
	var max_realm_idx: int = gd.realms().size() - 1 if gd != null else 4
	var realm_min: int = int(tpl.get("realm_min", 0))
	var realm_max: int = int(tpl.get("realm_max", max_realm_idx))
	if realm_min < 0 or realm_max > max_realm_idx or realm_min > realm_max:
		errors.append("invalid realm band [%d, %d]" % [realm_min, realm_max])
	var leg_min: int = _QuestRules.legendary_min_realm_index(gd, rules_override)
	if tier == "legendary" and leg_min >= 0 and realm_max < leg_min:
		errors.append("legendary template realm_max %d is below legendary_min_realm %d" % [realm_max, leg_min])

	# Parameter range sanity.
	var params: Dictionary = Dictionary(tpl.get("params", {}))
	if params.has("cash_share"):
		var cs: Variant = params["cash_share"]
		var cs_hi: float = float(cs[1]) if (cs is Array and (cs as Array).size() >= 2) else float(cs)
		var cs_lo: float = float(cs[0]) if (cs is Array and (cs as Array).size() >= 2) else float(cs)
		if cs_lo < 0.0 or cs_hi < cs_lo or cs_hi > float(cfg.get("quest_cash_share", 0.2)) + _EPS:
			errors.append("params.cash_share out of bounds [0, %.2f]" % float(cfg.get("quest_cash_share", 0.2)))
	var max_mission_param: int = 0
	if params.has("mission_seasons"):
		var ms: Variant = params["mission_seasons"]
		if ms is Array and (ms as Array).size() >= 2:
			var m_lo: int = int(ms[0])
			var m_hi: int = int(ms[1])
			if m_lo < int(cfg.get("mission_seasons_min", 1)) or m_hi > int(cfg.get("mission_seasons_max", 4)) or m_lo > m_hi:
				errors.append("params.mission_seasons out of bounds [%d, %d]" % [m_lo, m_hi])
			max_mission_param = m_hi

	# Stages validation.
	var stages: Array = Array(tpl.get("stages", []))
	var stage_check: Dictionary = _validate_stages_common(gd, cfg, tcfg, stages, is_board_tpl, max_mission_param, rules_override)
	errors.append_array(stage_check.errors)

	# Load-time travel + deadline check (Rule 4, AC-QS-142, AC-QS-143).
	var max_travel: int = int(cfg.get("template_travel_max", 4))
	var max_w_sum: int = int(stage_check.window_sum_max) + max_travel
	var dl_max: int = int(tcfg.get("deadline_max", 0))
	if max_w_sum > dl_max:
		errors.append("template windows (%d) + template_travel_max (%d) = %d exceeds %s deadline_max (%d)" % [
			int(stage_check.window_sum_max), max_travel, max_w_sum, tier, dl_max
		])

	# Rare reward checks (Rules 11, 14; AC-QS-21, AC-QS-64, AC-QS-86, AC-QS-135, AC-QS-137).
	_validate_template_rare_reward(gd, cfg, tcfg, tpl, tier, is_board_tpl, realm_min, realm_max, errors, rules_override)

	# Outcomes checks (Rules 15, 17, 18; AC-QS-104, AC-QS-112..114, AC-QS-118, AC-QS-124..125, AC-QS-131..133, AC-QS-144).
	var outcomes: Array = Array(tpl.get("outcomes", []))
	var has_defeat: bool = bool(stage_check.has_defeat)
	_validate_outcomes_common(gd, cfg, tcfg, tier, outcomes, is_person_or_sect, has_defeat, -1, null, {}, errors, rules_override)

	# Cross-realm sanity check (AC-QS-76).
	if gd != null and errors.is_empty():
		var r_lo: int = maxi(realm_min, leg_min if (tier == "legendary" and leg_min >= 0) else 0)
		var r_hi: int = mini(realm_max, max_realm_idx)
		for r_idx in range(r_lo, r_hi + 1):
			var b_res: Dictionary = _QuestRules.compute_budget(gd, tier, r_idx, stages, 0, rules_override)
			if int(b_res.B) < 1:
				errors.append("realm %d produces invalid budget B=%d" % [r_idx, int(b_res.B)])
			var rb: Dictionary = gd.realm_budget(r_idx)
			var rare: Variant = tpl.get("rare_reward", null)
			if rare is Dictionary:
				var rdict: Dictionary = rare as Dictionary
				var tp: int = int(rdict.get("tree_points", 0))
				if tp > int(rb.get("tree_point_max", 0)):
					errors.append("realm %d tree_points %d exceeds realm tree_point_max %d" % [r_idx, tp, int(rb.get("tree_point_max", 0))])
				if str(rdict.get("type", "")) == "above_cap_item":
					var fixed_price: int = int(rdict.get("price", 0))
					if fixed_price > int(b_res.B):
						errors.append("realm %d above_cap_item price %d exceeds B %d" % [r_idx, fixed_price, int(b_res.B)])
	return errors


## Strict offer-time validator for a concrete bound quest plan (Rule 4: reject, never repair).
## [param opts] may include:
## - [code]fight_power_fn[/code]: [code]Callable[/code] returning either float (F_opp) or {f_opp, f_player}
## - [code]reach_estimate_fn[/code]: [code]Callable[/code] returning float estimated seasons for a reach stage
## - [code]rules_override[/code]: [code]Dictionary[/code] overriding quest_rules knobs for tests
## - [code]check_stake[/code]: [code]bool[/code] (default true when source_fact is present on person/sect offer)
## Returns [code]{ok: bool, errors: Array[String], budget: Dictionary, deadline: Dictionary}[/code].
static func validate_plan(
	gd: GameData,
	db: WorldDB,
	player: Character,
	sheet: StatSheet,
	plan: Dictionary,
	opts: Dictionary = {}
) -> Dictionary:
	var errors: Array = []
	var rules_override: Dictionary = Dictionary(opts.get("rules_override", {}))
	var cfg: Dictionary = _QuestRules.config(gd, rules_override)
	var tiers: Dictionary = Dictionary(cfg.get("tiers", {}))

	var tier: String = str(plan.get("tier", ""))
	if not tiers.has(tier):
		return {"ok": false, "errors": ["unknown tier '%s'" % tier], "budget": {}, "deadline": {}}
	var tcfg: Dictionary = Dictionary(tiers[tier])
	var realm_idx: int = int(plan.get("realm_index", player.realm_index if player != null else 0))
	var offer_kind: String = str(plan.get("offer_kind", "person"))
	if not Array(cfg.get("offer_kinds", [])).has(offer_kind):
		errors.append("unknown offer_kind '%s'" % offer_kind)
	var is_board: bool = offer_kind == "board"
	var is_person_or_sect: bool = offer_kind == "person" or offer_kind == "sect"

	# Rule 14: Legendary below legendary_min_realm rejected; boards cannot be Major/Legendary.
	var leg_min: int = _QuestRules.legendary_min_realm_index(gd, rules_override)
	if tier == "legendary" and leg_min >= 0 and realm_idx < leg_min:
		errors.append("legendary tier not allowed below legendary_min_realm (%d < %d)" % [realm_idx, leg_min])
	if is_board and not bool(tcfg.get("board_allowed", false)):
		errors.append("board quest cannot have tier '%s'" % tier)

	# Rule 16: Adversary checks.
	var adv_raw: Variant = plan.get("adversary_id", "")
	var adv_id: String = ""
	if adv_raw is Array:
		if (adv_raw as Array).size() > 1:
			errors.append("a quest may name at most one adversary")
		elif (adv_raw as Array).size() == 1:
			adv_id = str((adv_raw as Array)[0])
	else:
		adv_id = str(adv_raw)
	if plan.has("adversaries") and Array(plan.get("adversaries", [])).size() > 1:
		errors.append("a quest may name at most one adversary")
	if is_board and adv_id != "":
		errors.append("board quest cannot have an adversary")
	if player != null and adv_id != "" and adv_id == player.id:
		errors.append("player cannot be named as adversary")

	# Rule 13: Registered entities check.
	var offerer_id: String = str(plan.get("offerer_id", ""))
	var offerer_root_id: String = str(plan.get("offerer_root_id", offerer_id))
	var offer_place_id: String = str(plan.get("place_id", ""))
	if db != null:
		if offer_place_id != "" and not db.has_record("places", offer_place_id):
			errors.append("unregistered place '%s'" % offer_place_id)
		if is_person_or_sect:
			if offerer_id == "":
				errors.append("person/sect offer missing offerer_id")
			elif not _entity_registered(db, offerer_id):
				errors.append("unregistered offerer '%s'" % offerer_id)
			if offerer_root_id != "" and db.table_of(offerer_root_id) == "sects":
				offerer_root_id = str(db.get_record("sects", offerer_root_id).get("leader_id", ""))
			if offerer_root_id == "" or not db.has_record("people", offerer_root_id):
				errors.append("unregistered offerer root person '%s'" % offerer_root_id)
		if adv_id != "" and not _entity_registered(db, adv_id):
			errors.append("unregistered adversary '%s'" % adv_id)
		for extra_ref in Array(plan.get("entity_refs", [])):
			var eid: String = str(extra_ref)
			if eid != "" and not _entity_registered(db, eid):
				errors.append("unregistered entity '%s'" % eid)

	# Rule 15: Offerer hostility and stake.
	if is_person_or_sect and db != null and offerer_root_id != "" and db.has_record("people", offerer_root_id):
		var root_rec: Dictionary = db.get_record("people", offerer_root_id)
		if not bool(root_rec.get("alive", false)):
			errors.append("offerer root '%s' is dead" % offerer_root_id)
		var att: int = int(root_rec.get("attitude", 0))
		var h_thresh: int = _QuestRules.hostile_threshold(gd)
		if att <= h_thresh:
			errors.append("offerer attitude %d is at or below hostile_threshold %d" % [att, h_thresh])
		var check_stake: bool = bool(opts.get("check_stake", plan.has("source_fact")))
		if check_stake and plan.get("source_fact") is Dictionary and not (plan["source_fact"] as Dictionary).is_empty():
			if not offerer_has_stake_in_fact(db, offerer_root_id, offerer_id, plan["source_fact"] as Dictionary):
				errors.append("offerer '%s' has no stake in source_fact" % offerer_root_id)

	# Stages graph, windows, travel, and budget.
	var stages: Array = Array(plan.get("stages", []))
	var travel_seasons: int = int(plan.get("travel_seasons", 0))
	if travel_seasons < 0:
		errors.append("travel_seasons cannot be negative")
	var stage_check: Dictionary = _validate_stages_common(gd, cfg, tcfg, stages, is_board, 0, rules_override)
	errors.append_array(stage_check.errors)

	var budget: Dictionary = _QuestRules.compute_budget(gd, tier, realm_idx, stages, travel_seasons, rules_override)
	var deadline: Dictionary = _QuestRules.compute_deadline(gd, tier, stages, travel_seasons, rules_override)
	if not bool(deadline.ok):
		errors.append("window_sum %d exceeds %s deadline_max %d" % [int(deadline.window_sum), tier, int(deadline.deadline_max)])

	# Stage-specific entity, reach, defeat, deliver, and reward checks.
	var total_priced: int = 0
	var total_cash: int = 0
	var total_tu_vi: float = 0.0
	var total_rel: int = 0
	var lasting_gain_count: int = 0
	var insight_count: int = 0
	var above_cap_count: int = 0
	var rb: Dictionary = gd.realm_budget(realm_idx) if gd != null else {}
	var r_cap: int = _QuestRules.realm_rarity_cap(gd, realm_idx, rules_override)
	var leg_r_cap: int = _QuestRules.legendary_rarity_cap(gd, realm_idx, rules_override)
	var allowed_stats: Array = Array(gd.budgets().get("allowed_check_stats", [])) if gd != null else []
	var allowed_effs: Array = _all_allowed_effect_types(gd, cfg)
	var n: int = stages.size()

	for i in range(n):
		if not (stages[i] is Dictionary):
			continue
		var st: Dictionary = stages[i] as Dictionary
		var kind: String = str(st.get("kind", ""))
		var w_i: int = _QuestRules.stage_window(gd, st, rules_override)

		# Registered entities on stage.
		if db != null:
			var sp_id: String = str(st.get("place_id", ""))
			if sp_id != "" and not db.has_record("places", sp_id):
				errors.append("stage %d references unregistered place '%s'" % [i, sp_id])
			var tgt_id: String = str(st.get("target_id", ""))
			if tgt_id != "" and not _entity_registered(db, tgt_id):
				errors.append("stage %d references unregistered target '%s'" % [i, tgt_id])
			var item_id: String = str(st.get("item_id", ""))
			if item_id != "" and not db.has_record("items", item_id):
				errors.append("stage %d references unregistered item '%s'" % [i, item_id])

		# Check stat validation for event stages.
		if st.has("check_stat"):
			var cstat: String = str(st["check_stat"])
			if cstat != "" and not allowed_stats.is_empty() and not allowed_stats.has(cstat):
				errors.append("stage %d uses disallowed check stat '%s'" % [i, cstat])

		# Rule 5 deliver price ceiling.
		if kind == "deliver":
			var d_price: int = int(st.get("deliver_price", 0))
			if d_price > int(budget.deliver_max):
				errors.append("stage %d deliver price %d exceeds deliver_max %d" % [i, d_price, int(budget.deliver_max)])

		# Rule 5 reach checks (AC-QS-16).
		if kind == "reach" and player != null:
			if _QuestRules.is_reach_met(player, sheet, st):
				errors.append("stage %d reach target is already met at offer" % i)
			else:
				var est: float = 0.0
				if opts.get("reach_estimate_fn") is Callable and (opts["reach_estimate_fn"] as Callable).is_valid():
					est = float((opts["reach_estimate_fn"] as Callable).call(st, player))
				else:
					est = _QuestRules.estimate_reach_seasons(gd, db, player, sheet, st, rules_override)
				if est > float(w_i) + _EPS:
					errors.append("stage %d reach estimate %.2f exceeds window %d" % [i, est, w_i])

		# Formula B defeat fight ratio check (AC-QS-13, AC-QS-30..33, AC-QS-84).
		if kind == "defeat":
			var f_pair: Dictionary = _resolve_fight_powers(gd, db, player, sheet, st, opts)
			var f_opp: float = float(f_pair.f_opp)
			var f_pl: float = float(f_pair.f_player)
			if f_opp > 0.0 and f_pl > 0.0:
				var ratio: float = _QuestRules.fight_ratio(f_opp, f_pl)
				var r_min: float = float(cfg.get("fight_ratio_min", 0.02))
				var r_max: float = float(tcfg.get("fight_ratio_max", 0.35))
				if ratio < r_min - _EPS:
					errors.append("stage %d fight ratio %.5f below min %.2f" % [i, ratio, r_min])
				elif ratio > r_max + _EPS:
					errors.append("stage %d fight ratio %.5f above %s max %.2f" % [i, ratio, tier, r_max])

		# Stage rewards & effect caps (Rule 9, AC-QS-18, AC-QS-19, AC-QS-28, AC-QS-91).
		var rewards: Array = Array(st.get("rewards", st.get("effects", [])))
		var is_final: bool = (i == n - 1)
		var eff_cap: int = int(cfg.get("quest_final_effects_max", 6)) if is_final else int(cfg.get("non_final_effects_max", 3))
		if rewards.size() > eff_cap:
			errors.append("stage %d has %d reward effects (max %d)" % [i, rewards.size(), eff_cap])

		var stage_priced: int = 0
		var stage_cap: int = int(budget.stage_pays[i]) if i < (budget.stage_pays as Array).size() else 0
		for raw_eff in rewards:
			if not (raw_eff is Dictionary):
				continue
			var eff: Dictionary = raw_eff as Dictionary
			var etype: String = str(eff.get("type", ""))
			if etype == "recipe" and not bool(cfg.get("recipe_rewards_enabled", false)):
				errors.append("recipe reward is rejected until Open Question 11 is closed")
				continue
			if not allowed_effs.has(etype):
				errors.append("stage %d has unknown effect type '%s'" % [i, etype])
				continue
			if etype == "linh_thach":
				var amt: int = int(eff.get("amount", 0))
				stage_priced += maxi(0, amt)
				total_cash += maxi(0, amt)
			elif etype == "tu_vi":
				total_tu_vi += float(eff.get("amount", 0.0))
			elif etype == "relationship":
				var r_amt: int = int(eff.get("amount", 0))
				total_rel += abs(r_amt)
				if is_board and str(eff.get("role", "offerer")) == "offerer":
					errors.append("board quest cannot pay a relationship reward with the sect head")
			elif etype == "quest_boon":
				lasting_gain_count += 1
				_validate_lasting_gain_entry(gd, cfg, tcfg, tier, realm_idx, rb, player, eff, errors, rules_override)
			elif etype == "tree_point":
				lasting_gain_count += 1
				var tp_boon := {"tree_points": int(eff.get("amount", eff.get("tree_points", 1)))}
				_validate_lasting_gain_entry(gd, cfg, tcfg, tier, realm_idx, rb, player, tp_boon, errors, rules_override)
			elif etype == "insight":
				insight_count += 1
				_validate_insight_entry(gd, tcfg, tier, realm_idx, player, errors)
			elif etype == "above_cap_item":
				above_cap_count += 1
				var price: int = int(eff.get("price", eff.get("value", 0)))
				stage_priced += maxi(0, price)
				var r_val: int = int(eff.get("rarity", leg_r_cap))
				if not bool(tcfg.get("above_cap_item", false)):
					errors.append("above_cap_item is only allowed on legendary quests (tier '%s')" % tier)
				if r_val > leg_r_cap:
					errors.append("above_cap_item rarity %d exceeds legendary cap %d" % [r_val, leg_r_cap])
				if price > int(budget.B):
					errors.append("above_cap_item price %d exceeds budget B %d" % [price, int(budget.B)])
			elif etype in ["herb", "material", "artifact", "cong_phap", "pill", "talisman", "treasure"]:
				var price: int = int(eff.get("price", eff.get("value", 0)))
				stage_priced += maxi(0, price)
				if eff.has("rarity"):
					var item_r: int = int(eff["rarity"])
					if item_r > r_cap:
						if bool(tcfg.get("above_cap_item", false)) and item_r <= leg_r_cap:
							above_cap_count += 1
						else:
							errors.append("stage %d item rarity %d exceeds realm cap %d" % [i, item_r, r_cap])
			elif etype != "access":
				var val_p: int = int(eff.get("price", eff.get("value", 0)))
				stage_priced += maxi(0, val_p)

		# Also support explicit scalar stage_value for concise plan fixtures.
		if st.has("stage_value"):
			stage_priced = maxi(stage_priced, int(st["stage_value"]))
		if stage_priced > stage_cap:
			errors.append("stage %d reward value %d exceeds stage cap %d" % [i, stage_priced, stage_cap])
		total_priced += stage_priced

	# Plan-level rare_reward field (if provided outside stage rewards).
	var rare_raw: Variant = plan.get("rare_reward", null)
	if rare_raw is Dictionary and not (rare_raw as Dictionary).is_empty():
		var rare: Dictionary = rare_raw as Dictionary
		var rtype: String = str(rare.get("type", ""))
		if rtype == "recipe" and not bool(cfg.get("recipe_rewards_enabled", false)):
			errors.append("recipe reward is rejected until Open Question 11 is closed")
		elif rtype == "quest_boon" or rtype == "tree_point":
			lasting_gain_count += 1
			_validate_lasting_gain_entry(gd, cfg, tcfg, tier, realm_idx, rb, player, rare, errors, rules_override)
		elif rtype == "insight":
			insight_count += 1
			_validate_insight_entry(gd, tcfg, tier, realm_idx, player, errors)
		elif rtype == "above_cap_item":
			above_cap_count += 1
			var price: int = int(rare.get("price", rare.get("value", 0)))
			var r_val: int = int(rare.get("rarity", leg_r_cap))
			if not bool(tcfg.get("above_cap_item", false)):
				errors.append("above_cap_item is only allowed on legendary quests (tier '%s')" % tier)
			if r_val > leg_r_cap:
				errors.append("above_cap_item rarity %d exceeds legendary cap %d" % [r_val, leg_r_cap])
			if price > int(budget.B):
				errors.append("above_cap_item price %d exceeds budget B %d" % [price, int(budget.B)])
		else:
			errors.append("unknown rare_reward type '%s'" % rtype)

	if plan.has("total_value"):
		total_priced = maxi(total_priced, int(plan["total_value"]))
	if plan.has("cash_total"):
		total_cash = maxi(total_cash, int(plan["cash_total"]))
	if plan.has("tu_vi_total"):
		total_tu_vi = maxf(total_tu_vi, float(plan["tu_vi_total"]))

	if total_priced > int(budget.B):
		errors.append("total reward value %d exceeds budget B %d" % [total_priced, int(budget.B)])
	if total_cash > int(budget.cash_max):
		errors.append("total cash %d exceeds cash_max %d" % [total_cash, int(budget.cash_max)])
	if total_tu_vi > float(budget.tu_vi_max) + _EPS:
		errors.append("total tu_vi %.4f exceeds tu_vi_max %.4f" % [total_tu_vi, float(budget.tu_vi_max)])
	var rel_max: int = int(rb.get("relationship_max", 30))
	if total_rel > rel_max:
		errors.append("total relationship reward %d exceeds relationship_max %d" % [total_rel, rel_max])
	if lasting_gain_count > 1:
		errors.append("at most one lasting gain per quest (got %d)" % lasting_gain_count)
	if insight_count > 1:
		errors.append("at most one insight per quest (got %d)" % insight_count)
	if above_cap_count > 1:
		errors.append("at most one above-cap item per quest (got %d)" % above_cap_count)

	# Outcomes validation (Rules 15, 17, 18).
	var outcomes: Array = Array(plan.get("outcomes", []))
	var role_targets := {
		"offerer": offerer_root_id,
		"adversary": adv_id,
	}
	_validate_outcomes_common(
		gd, cfg, tcfg, tier, outcomes, is_person_or_sect,
		bool(stage_check.has_defeat), int(budget.B), db, role_targets, errors, rules_override
	)

	return {
		"ok": errors.is_empty(),
		"errors": errors,
		"budget": budget,
		"deadline": deadline,
	}


## Returns true if [param offerer_root_id] (or their sect or one of their direct living ties)
## is named in [param fact] (Rule 15, AC-QS-102).
static func offerer_has_stake_in_fact(
	db: WorldDB,
	offerer_root_id: String,
	offerer_id: String,
	fact: Dictionary
) -> bool:
	if fact.is_empty():
		return false
	var refs: Dictionary = {}
	for p in Array(fact.get("people", [])):
		refs[str(p)] = true
	for s in Array(fact.get("sects", [])):
		refs[str(s)] = true
	var fdata: Dictionary = Dictionary(fact.get("data", {}))
	for k in ["person_id", "sect_id", "offerer_id", "adversary_id", "victim_id", "killer_id"]:
		var v: String = str(fdata.get(k, ""))
		if v != "":
			refs[v] = true
	if refs.has(offerer_root_id) or (offerer_id != "" and refs.has(offerer_id)):
		return true
	var root_rec: Dictionary = db.get_record("people", offerer_root_id)
	var sid: String = str(root_rec.get("sect_id", ""))
	if sid != "" and refs.has(sid):
		return true
	var ties: Dictionary = _QuestRules.direct_ties_of(db, offerer_root_id)
	var m: String = str(ties.get("master", ""))
	if m != "" and refs.has(m):
		return true
	for did in Array(ties.get("disciples", [])):
		if refs.has(str(did)):
			return true
	var h: String = str(ties.get("sect_head", ""))
	if h != "" and refs.has(h):
		return true
	return false


# --- Internal helpers ---------------------------------------------------------------------------------------------

static func _check_bound(cfg: Dictionary, key: String, bounds_key: String, errors: Array) -> void:
	if not cfg.has(key):
		errors.append("missing '%s'" % key)
		return
	var b: Array = Array(cfg.get(bounds_key, []))
	if b.size() < 2:
		errors.append("missing bounds '%s'" % bounds_key)
		return
	var v: float = float(cfg[key])
	var lo: float = float(b[0])
	var hi: float = float(b[1])
	if v < lo - _EPS or v > hi + _EPS:
		errors.append("%s = %s outside [%s, %s]" % [key, str(v), str(lo), str(hi)])


static func _validate_stages_common(
	gd: GameData,
	cfg: Dictionary,
	tcfg: Dictionary,
	stages: Array,
	is_board: bool,
	max_mission_param: int,
	rules_override: Dictionary
) -> Dictionary:
	var errors: Array = []
	var n: int = stages.size()
	var s_min: int = int(tcfg.get("stages_min", 2))
	var s_max: int = int(tcfg.get("stages_max", 5))
	if n < s_min or n > s_max:
		errors.append("stage count %d outside [%d, %d]" % [n, s_min, s_max])

	var allowed_kinds: Array = Array(cfg.get("stage_kinds", []))
	var allowed_lost: Array = Array(cfg.get("if_target_lost_allowed", ["orphan", "skip", "drop"]))
	var allowed_items: Array = Array(cfg.get("allowed_item_classes", []))
	var w_max_limit: int = int(cfg.get("stage_window_max", 12))
	var del_share_max: float = float(cfg.get("deliver_share", 0.5))
	var allowed_effs: Array = _all_allowed_effect_types(gd, cfg)

	var reach_count: int = 0
	var season_cost_stages: int = 0
	var has_defeat: bool = false
	var w_sum_max: int = 0

	for i in range(n):
		if not (stages[i] is Dictionary):
			errors.append("stage %d is not a Dictionary" % i)
			continue
		var st: Dictionary = stages[i] as Dictionary
		var kind: String = str(st.get("kind", ""))
		if not allowed_kinds.has(kind):
			errors.append("stage %d has unknown kind '%s'" % [i, kind])
			continue
		if kind == "reach":
			reach_count += 1
		if kind == "defeat":
			has_defeat = true

		var s_i: int = _QuestRules.stage_seasons(gd, st, rules_override)
		if kind == "mission":
			var m_min: int = int(cfg.get("mission_seasons_min", 1))
			var m_max: int = int(cfg.get("mission_seasons_max", 4))
			if s_i < m_min or s_i > m_max:
				errors.append("stage %d mission seasons %d outside [%d, %d]" % [i, s_i, m_min, m_max])
			if bool(st.get("use_mission_param", false)) and max_mission_param > s_i:
				s_i = max_mission_param
		if s_i >= 1:
			season_cost_stages += 1

		var w_i: int = _QuestRules.stage_window(gd, st, rules_override)
		var min_w: int = maxi(1, s_i)
		if w_i < min_w or w_i > w_max_limit:
			errors.append("stage %d window %d outside [%d, %d]" % [i, w_i, min_w, w_max_limit])
		w_sum_max += w_i

		if st.has("if_target_lost"):
			var lost_v: String = str(st["if_target_lost"])
			if not allowed_lost.has(lost_v):
				errors.append("stage %d has unknown if_target_lost '%s'" % [i, lost_v])
			elif lost_v == "skip" and i == n - 1:
				errors.append("stage %d (final) cannot use if_target_lost='skip'" % i)

		if kind == "deliver":
			if st.has("deliver_share") and float(st["deliver_share"]) > del_share_max + _EPS:
				errors.append("stage %d deliver_share %.2f exceeds %.2f" % [i, float(st["deliver_share"]), del_share_max])
			var ic: String = str(st.get("item_class", ""))
			if ic != "" and not allowed_items.is_empty() and not allowed_items.has(ic):
				errors.append("stage %d unknown deliver item_class '%s'" % [i, ic])

		if kind == "craft":
			var ic: String = str(st.get("item_class", ""))
			if ic != "" and not allowed_items.is_empty() and not allowed_items.has(ic):
				errors.append("stage %d unknown craft item_class '%s'" % [i, ic])

		# Validate authored template stage effects if present.
		var raw_effs: Array = Array(st.get("rewards", st.get("effects", [])))
		var is_final: bool = (i == n - 1)
		var eff_cap: int = int(cfg.get("quest_final_effects_max", 6)) if is_final else int(cfg.get("non_final_effects_max", 3))
		if raw_effs.size() > eff_cap:
			errors.append("stage %d has %d effects (max %d)" % [i, raw_effs.size(), eff_cap])
		for raw_e in raw_effs:
			if raw_e is Dictionary:
				var et: String = str((raw_e as Dictionary).get("type", ""))
				if et == "recipe" and not bool(cfg.get("recipe_rewards_enabled", false)):
					errors.append("stage %d uses disabled recipe reward" % i)
				elif not allowed_effs.has(et):
					errors.append("stage %d uses unknown effect '%s'" % [i, et])
				elif is_board and et == "relationship" and str((raw_e as Dictionary).get("role", "offerer")) == "offerer":
					errors.append("board template cannot pay relationship reward with sect head")

	if reach_count > 1:
		errors.append("at most one reach stage allowed (got %d)" % reach_count)
	if n > 0 and season_cost_stages < 1:
		errors.append("at least one stage must cost a season (s_i >= 1)")

	return {"errors": errors, "has_defeat": has_defeat, "window_sum_max": w_sum_max}


static func _validate_template_rare_reward(
	gd: GameData,
	cfg: Dictionary,
	tcfg: Dictionary,
	tpl: Dictionary,
	tier: String,
	is_board: bool,
	realm_min: int,
	realm_max: int,
	errors: Array,
	rules_override: Dictionary
) -> void:
	var rare_raw: Variant = tpl.get("rare_reward", null)
	if rare_raw == null or (rare_raw is Dictionary and (rare_raw as Dictionary).is_empty()):
		return
	if not (rare_raw is Dictionary):
		errors.append("rare_reward must be a Dictionary or null")
		return
	var rare: Dictionary = rare_raw as Dictionary
	if is_board or not bool(tcfg.get("rare_rewards", false)):
		errors.append("tier '%s' (board=%s) cannot carry rare_reward" % [tier, str(is_board)])
		return
	var rtype: String = str(rare.get("type", ""))
	if rtype == "recipe":
		if not bool(cfg.get("recipe_rewards_enabled", false)):
			errors.append("recipe reward is rejected until Open Question 11 is closed")
	elif rtype == "quest_boon" or rtype == "tree_point":
		var weights: Dictionary = Dictionary(cfg.get("boon_stat_weights", {}))
		for raw_m in Array(rare.get("mods", [])):
			if raw_m is Dictionary:
				var sk: String = str((raw_m as Dictionary).get("stat", ""))
				if not weights.has(sk):
					errors.append("rare_reward boon uses unknown stat key '%s'" % sk)
				if float((raw_m as Dictionary).get("value", 0.0)) < 0.0:
					errors.append("rare_reward boon value must be >= 0")
		var w: float = _QuestRules.boon_weight(gd, rare, rules_override)
		var max_w: float = float(cfg.get("quest_boon_w", 8.0))
		if w > max_w + _EPS:
			errors.append("rare_reward boon weight %.2f exceeds quest_boon_w %.2f" % [w, max_w])
		var tp: int = int(rare.get("tree_points", 0))
		if tp > int(cfg.get("quest_tree_point_cap", 3)):
			errors.append("rare_reward tree_points %d exceeds quest_tree_point_cap %d" % [tp, int(cfg.get("quest_tree_point_cap", 3))])
	elif rtype == "insight":
		var ns_idx: int = gd.realm_index("nguyen_anh") if gd != null else 3
		if ns_idx >= 0 and (realm_max < ns_idx or realm_min > ns_idx):
			errors.append("insight template realm band [%d, %d] must cover Nascent Soul (%d)" % [realm_min, realm_max, ns_idx])
	elif rtype == "above_cap_item":
		if not bool(tcfg.get("above_cap_item", false)):
			errors.append("above_cap_item is only allowed on legendary templates")
	else:
		errors.append("unknown rare_reward type '%s'" % rtype)


static func _validate_lasting_gain_entry(
	gd: GameData,
	cfg: Dictionary,
	tcfg: Dictionary,
	tier: String,
	_realm_idx: int,
	rb: Dictionary,
	player: Character,
	entry: Dictionary,
	errors: Array,
	rules_override: Dictionary
) -> void:
	if not bool(tcfg.get("rare_rewards", false)):
		errors.append("lasting gain is not allowed on tier '%s'" % tier)
		return
	var weights: Dictionary = Dictionary(cfg.get("boon_stat_weights", {}))
	for raw_m in Array(entry.get("mods", [])):
		if raw_m is Dictionary:
			var sk: String = str((raw_m as Dictionary).get("stat", ""))
			if not weights.has(sk):
				errors.append("quest_boon uses unknown stat key '%s'" % sk)
			if float((raw_m as Dictionary).get("value", 0.0)) < 0.0:
				errors.append("quest_boon stat value must be >= 0")
	var stats_map: Dictionary = Dictionary(entry.get("stats", {}))
	for sk in stats_map.keys():
		if not weights.has(str(sk)):
			errors.append("quest_boon uses unknown stat key '%s'" % str(sk))
		if float(stats_map[sk]) < 0.0:
			errors.append("quest_boon stat value must be >= 0")
	var w: float = _QuestRules.boon_weight(gd, entry, rules_override)
	var max_w: float = float(cfg.get("quest_boon_w", 8.0))
	if w > max_w + _EPS:
		errors.append("lasting gain weight %.2f exceeds quest_boon_w %.2f" % [w, max_w])
	var tp: int = int(entry.get("tree_points", 0))
	if tp > 0:
		var r_tp_max: int = int(rb.get("tree_point_max", 0))
		if tp > r_tp_max:
			errors.append("tree_points %d exceeds realm tree_point_max %d" % [tp, r_tp_max])
		var used_tp: int = int(player.get("quest_tree_points_used")) if (player != null and _has_prop(player, "quest_tree_points_used")) else 0
		var life_cap: int = int(cfg.get("quest_tree_point_cap", 3))
		if used_tp + tp > life_cap:
			errors.append("tree_points %d + used %d exceeds lifetime quest_tree_point_cap %d" % [tp, used_tp, life_cap])


static func _validate_insight_entry(
	gd: GameData,
	tcfg: Dictionary,
	tier: String,
	realm_idx: int,
	player: Character,
	errors: Array
) -> void:
	if not bool(tcfg.get("rare_rewards", false)):
		errors.append("insight is not allowed on tier '%s'" % tier)
		return
	var ns_idx: int = gd.realm_index("nguyen_anh") if gd != null else 3
	if realm_idx != ns_idx:
		errors.append("insight is only allowed in Nascent Soul (realm %d, got %d)" % [ns_idx, realm_idx])
	if player != null and player.has_insight:
		errors.append("insight rejected because player already holds an insight")


static func _validate_outcomes_common(
	gd: GameData,
	cfg: Dictionary,
	tcfg: Dictionary,
	tier: String,
	outcomes: Array,
	is_person_or_sect: bool,
	has_defeat: bool,
	budget_b: int,
	db: WorldDB,
	role_targets: Dictionary,
	errors: Array,
	rules_override: Dictionary
) -> void:
	var allowed_on: Array = Array(cfg.get("allowed_outcome_on", ["completed", "failed"]))
	var allowed_roles: Array = Array(cfg.get("allowed_outcome_roles", []))
	var allowed_effects: Dictionary = Dictionary(cfg.get("allowed_outcome_effects", {}))
	var tier_ord: int = _QuestRules.tier_rank(gd, tier, rules_override)
	var max_per_ending: int = int(tcfg.get("world_effects_max", 1))
	var w_share_max: float = float(cfg.get("world_wealth_share", 0.5))
	var inj_max: float = float(cfg.get("world_injury_max", 0.4))
	var stand_max: int = int(cfg.get("world_standing_max", 10))
	var wealth_cap: int = int(floor(w_share_max * float(budget_b) + 1e-9)) if budget_b >= 0 else -1

	var count_by_on := {"completed": 0, "failed": 0}
	var offerer_completed_gains: int = 0
	var offerer_completed_harms: int = 0

	for idx in range(outcomes.size()):
		if not (outcomes[idx] is Dictionary):
			errors.append("outcome %d is not a Dictionary" % idx)
			continue
		var oc: Dictionary = outcomes[idx] as Dictionary
		var on_v: String = str(oc.get("on", ""))
		var role: String = str(oc.get("role", ""))
		var eff: String = str(oc.get("effect", ""))

		if not allowed_on.has(on_v):
			errors.append("outcome %d has unknown on '%s'" % [idx, on_v])
			continue
		if not allowed_roles.has(role):
			errors.append("outcome %d has unknown role '%s'" % [idx, role])
			continue
		if not allowed_effects.has(eff):
			errors.append("outcome %d has unknown effect '%s'" % [idx, eff])
			continue

		count_by_on[on_v] = int(count_by_on.get(on_v, 0)) + 1

		var ecfg: Dictionary = Dictionary(allowed_effects[eff])
		var min_tier: String = str(ecfg.get("min_tier", "errand"))
		if tier_ord < _QuestRules.tier_rank(gd, min_tier, rules_override):
			errors.append("outcome %d effect '%s' requires tier >= '%s' (got '%s')" % [idx, eff, min_tier, tier])
		if not Array(ecfg.get("roles", [])).has(role):
			errors.append("outcome %d effect '%s' is not allowed on role '%s'" % [idx, eff, role])

		var has_amt: bool = oc.has("amount")
		var has_share: bool = oc.has("amount_share")
		var field_rule: String = str(ecfg.get("field", "none"))
		var is_offerer_side: bool = role in ["offerer", "offerer_ties", "offerer_sect"]
		var is_gain: bool = false
		var is_loss: bool = false

		match field_rule:
			"amount_or_share":
				if has_amt == has_share:
					errors.append("outcome %d effect '%s' must specify exactly one of amount or amount_share" % [idx, eff])
					continue
				if has_share:
					var sh: float = float(oc["amount_share"])
					if absf(sh) > w_share_max + _EPS or is_zero_approx(sh):
						errors.append("outcome %d wealth amount_share %.3f outside nonzero [-%.2f, %.2f]" % [idx, sh, w_share_max, w_share_max])
					is_gain = sh > 0.0
					is_loss = sh < 0.0
				else:
					var amt: float = float(oc["amount"])
					if is_zero_approx(amt):
						errors.append("outcome %d wealth amount cannot be 0" % idx)
					if wealth_cap >= 0 and absf(amt) > float(wealth_cap) + _EPS:
						errors.append("outcome %d wealth amount %.0f exceeds cap %d" % [idx, absf(amt), wealth_cap])
					is_gain = amt > 0.0
					is_loss = amt < 0.0
			"amount":
				if has_share or not has_amt:
					errors.append("outcome %d effect '%s' must specify amount (never amount_share)" % [idx, eff])
					continue
				var amt: float = float(oc["amount"])
				if eff == "injury":
					if amt <= 0.0 or amt > inj_max + _EPS:
						errors.append("outcome %d injury amount %.3f outside (0, %.2f]" % [idx, amt, inj_max])
					is_loss = true
				elif eff == "standing":
					if is_zero_approx(amt) or absf(amt) > float(stand_max) + _EPS:
						errors.append("outcome %d standing amount %.1f outside nonzero [-%d, %d]" % [idx, amt, stand_max, stand_max])
					is_gain = amt > 0.0
					is_loss = amt < 0.0
			"none":
				if has_amt or has_share:
					errors.append("outcome %d effect '%s' must not carry amount or amount_share" % [idx, eff])
					continue
				if eff == "death":
					if on_v != "completed":
						errors.append("outcome %d death is only allowed on 'completed'" % idx)
					if not has_defeat:
						errors.append("outcome %d death requires a defeat stage" % idx)
					is_loss = true
				elif eff == "rank":
					# Direction follows side + ending: completed offerer = +1, adversary = -1; failed reverses.
					var expected_gain: bool = (on_v == "completed" and is_offerer_side) or (on_v == "failed" and not is_offerer_side)
					is_gain = expected_gain
					is_loss = not expected_gain
					if db != null and role_targets.has(role):
						_validate_rank_target(gd, db, str(role_targets[role]), is_gain, idx, errors)

		# Direction rule (Rule 18, AC-QS-124):
		# completed -> gains for offerer's side, losses for adversary's side.
		# failed -> losses for offerer's side, gains for adversary's side.
		if on_v == "completed":
			if is_offerer_side:
				if is_loss:
					offerer_completed_harms += 1
					errors.append("outcome %d completed entry cannot harm offerer's side" % idx)
				elif is_gain:
					offerer_completed_gains += 1
			else:
				if is_gain:
					errors.append("outcome %d completed entry cannot benefit adversary's side" % idx)
		elif on_v == "failed":
			if is_offerer_side and is_gain:
				errors.append("outcome %d failed entry cannot benefit offerer's side" % idx)
			if not is_offerer_side and is_loss:
				errors.append("outcome %d failed entry cannot harm adversary's side" % idx)

	for end_k in ["completed", "failed"]:
		if int(count_by_on[end_k]) > max_per_ending:
			errors.append("%s outcomes count %d exceeds %s world_effects_max %d" % [end_k, int(count_by_on[end_k]), tier, max_per_ending])

	if is_person_or_sect:
		if offerer_completed_gains < 1:
			errors.append("person/sect quest must have at least one completed gain for offerer's side (Rule 15)")
		if offerer_completed_harms > 0:
			errors.append("person/sect quest cannot harm offerer's side on completion (Rule 15)")


static func _validate_rank_target(
	gd: GameData,
	db: WorldDB,
	target_id: String,
	is_promotion: bool,
	idx: int,
	errors: Array
) -> void:
	if target_id == "":
		return
	var pid: String = target_id
	if db.table_of(pid) == "sects":
		pid = str(db.get_record("sects", pid).get("leader_id", ""))
	var person: Dictionary = db.get_record("people", pid)
	if person.is_empty():
		return
	var rank: String = str(person.get("sect_rank", ""))
	var ladder: Array = Array(gd.world_gen().get("sects", {}).get("rank_ladder", ["ngoai_mon", "noi_mon", "truong_lao", "tong_chu"]))
	var head_rank: String = str(ladder[ladder.size() - 1]) if not ladder.is_empty() else "tong_chu"
	if rank == head_rank:
		errors.append("outcome %d rank cannot move a sect head (Rule 17)" % idx)
		return
	if is_promotion and rank != "":
		var pos: int = ladder.find(rank)
		if pos >= 0 and pos + 1 < ladder.size() and str(ladder[pos + 1]) == head_rank:
			errors.append("outcome %d rank cannot promote anyone into sect head (Rule 17)" % idx)


static func _resolve_fight_powers(
	gd: GameData,
	db: WorldDB,
	player: Character,
	sheet: StatSheet,
	stage: Dictionary,
	opts: Dictionary
) -> Dictionary:
	var f_player: float = float(opts.get("f_player", 0.0))
	var f_opp: float = float(stage.get("f_opp", 0.0))
	if opts.get("fight_power_fn") is Callable and (opts["fight_power_fn"] as Callable).is_valid():
		var res: Variant = (opts["fight_power_fn"] as Callable).call(stage, player)
		if res is Dictionary:
			var d: Dictionary = res as Dictionary
			return {
				"f_opp": float(d.get("f_opp", f_opp)),
				"f_player": float(d.get("f_player", f_player)),
			}
		f_opp = float(res)
	if f_player <= 0.0 and player != null:
		f_player = _QuestRules.fight_power_F(player, gd, db, sheet)
	if f_opp <= 0.0 and db != null:
		var tid: String = str(stage.get("target_id", ""))
		if tid != "" and db.has_record("people", tid):
			var opp_c := Character.from_dict(db.get_record("people", tid))
			f_opp = _QuestRules.fight_power_F(opp_c, gd, db, null)
	return {"f_opp": f_opp, "f_player": f_player}


static func _entity_registered(db: WorldDB, entity_id: String) -> bool:
	var tbl: String = db.table_of(entity_id)
	if tbl != "":
		return db.has_record(tbl, entity_id)
	for t in ["people", "sects", "places", "items"]:
		if db.has_record(t, entity_id):
			return true
	return false


static func _all_allowed_effect_types(gd: GameData, cfg: Dictionary) -> Array:
	var out: Array = []
	if gd != null:
		for e in Array(gd.budgets().get("allowed_effect_types", [])):
			if not out.has(str(e)):
				out.append(str(e))
	for e in Array(cfg.get("quest_extra_effect_types", [])):
		if not out.has(str(e)):
			out.append(str(e))
	return out


static func _has_prop(obj: Object, prop_name: String) -> bool:
	for p in obj.get_property_list():
		if str(p.name) == prop_name:
			return true
	return false
