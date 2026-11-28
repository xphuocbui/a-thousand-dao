class_name QuestGenerator
extends RefCounted
## Deterministic template draw, role-slot binding, parameter sampling, and plan freezing
## for Template Quests (#31).
## Uses a single keyed stream per offer ([code]ADR-0002[/code] decision 4: seed + player_id + season + offer_idx),
## never calls an LLM, never repairs invalid plans (Rule 4), and never mutates unrelated systems
## (registering a [code]new_person[/code] slot in [WorldDB] only when that template is selected and offered, Rule 13).
## Design: [code]design/gdd/quests.md[/code] (Rules 2, 3, 4, 12, 13, 14, 15, 18).
##
## Usage:
## [codeblock]
## var gen := QuestGenerator.new(gd, db, builds)
## var res := gen.generate_offer(player, sheet, "person", npc_id, place_id, seed_v, season_idx, 0)
## if res.ok: var quest: Dictionary = res.quest
## [/codeblock]

const _QuestRules := preload("res://src/gameplay/quests/quest_rules.gd")
const _QuestValidator := preload("res://src/gameplay/quests/quest_validator.gd")

var _gd: GameData
var _db: WorldDB
var _builds: BuildGenerator


func _init(gd: GameData, db: WorldDB, builds: BuildGenerator = null) -> void:
	_gd = gd
	_db = db
	_builds = builds


## Creates the deterministic keyed RNG stream for one quest offer (Rule 12, ADR-0002 decision 4, AC-QS-07, AC-QS-09).
static func offer_rng(
	seed_v: int,
	player_id: String,
	season_idx: int,
	offer_idx: int,
	salt: String = "quest_offer"
) -> RandomNumberGenerator:
	var key: String = "%s:%d:%s:%d:%d" % [salt, seed_v, player_id, season_idx, offer_idx]
	var hi: int = RngUtils.stable_hash(key)
	var lo: int = RngUtils.stable_hash("%d:%s:%d" % [offer_idx, key, seed_v])
	var rng := RandomNumberGenerator.new()
	rng.seed = (hi << 32) | lo
	rng.randi()
	return rng


## Draws a quest tier by [code]tier_share[/code], downgrading [code]legendary[/code] to [code]major[/code]
## below [code]legendary_min_realm[/code] (Rule 14, AC-QS-08, AC-QS-82, AC-QS-148), and falling down to the
## next lower tier in [param available_tiers] when the drawn tier has no candidates (Rule 3 step 4).
static func draw_tier(
	gd: GameData,
	rng: RandomNumberGenerator,
	realm_idx: int,
	available_tiers: Array,
	offer_kind: String = "person",
	rules_override: Dictionary = {}
) -> String:
	if available_tiers.is_empty():
		return ""
	var cfg: Dictionary = _QuestRules.config(gd, rules_override)
	var order: Array = Array(cfg.get("tier_order", ["errand", "ordinary", "major", "legendary"]))
	var tiers_cfg: Dictionary = Dictionary(cfg.get("tiers", {}))

	var roll_tiers: Array = []
	var weights: Array = []
	for t_raw in order:
		var t: String = str(t_raw)
		var tc: Dictionary = Dictionary(tiers_cfg.get(t, {}))
		if offer_kind == "board" and not bool(tc.get("board_allowed", false)):
			continue
		roll_tiers.append(t)
		weights.append(float(tc.get("share", 0.0)))
	if roll_tiers.is_empty():
		return ""

	var idx: int = RngUtils.weighted_index(rng, weights)
	var drawn: String = str(roll_tiers[idx]) if idx >= 0 else str(roll_tiers[0])
	drawn = _QuestRules.downgrade_tier_for_realm(gd, drawn, realm_idx, rules_override)
	if available_tiers.has(drawn):
		return drawn

	# Fall to the next lower tier with available templates (Rule 3 step 4).
	var pos: int = order.find(drawn)
	for step in range(pos - 1, -1, -1):
		var lower: String = str(order[step])
		if available_tiers.has(lower):
			return lower
	# If only higher tiers exist in a custom test fixture, pick the lowest available.
	for t_raw in order:
		var t: String = str(t_raw)
		if available_tiers.has(t):
			return t
	return str(available_tiers[0])


## Generates, validates, and freezes a quest offer for [param player] at [param place_id].
## [param opts] optional overrides for tests and callers:
## - [code]templates[/code]: custom Array of templates (defaults to [code]quest_templates.json[/code])
## - [code]source_fact[/code]: explicit WorldDB event Dictionary to anchor the offer
## - [code]speaking_member_id[/code]: explicit sect member id when [param offer_kind] == "sect"
## - [code]spent_facts[/code]: Dictionary of fact_id -> true
## - [code]fact_cooldowns[/code]: Dictionary of fact_id -> season_idx_unlocked
## - [code]exclude_template_ids[/code]: Array of template ids to skip (e.g. already on board)
## - [code]spent_board_pairs[/code]: Dictionary of "template_id|fact_id" -> true
## - [code]travel_override[/code]: int >= 0 overriding travel_seasons calculation for deterministic tests
## - [code]fight_power_fn[/code], [code]reach_estimate_fn[/code], [code]rules_override[/code]: forwarded to [QuestValidator]
## Returns [code]{ok: bool, quest: Dictionary, reason: String, tries: int}[/code].
func generate_offer(
	player: Character,
	sheet: StatSheet,
	offer_kind: String,
	offerer_id: String,
	place_id: String,
	seed_v: int,
	season_idx: int,
	offer_idx: int,
	opts: Dictionary = {}
) -> Dictionary:
	if player == null or _gd == null or _db == null:
		return {"ok": false, "quest": {}, "reason": "missing_context", "tries": 0}

	var rules_override: Dictionary = Dictionary(opts.get("rules_override", {}))
	var cfg: Dictionary = _QuestRules.config(_gd, rules_override)
	var is_board: bool = offer_kind == "board"
	var rng: RandomNumberGenerator = offer_rng(seed_v, player.id, season_idx, offer_idx)

	var place: Dictionary = _db.get_record("places", place_id)
	if place.is_empty():
		return {"ok": false, "quest": {}, "reason": "unknown_place", "tries": 0}

	# Resolve offerer root & check hostility for person / sect offers (Rules 15, 16; AC-QS-103, AC-QS-140).
	var offerer_root_id: String = ""
	var offerer_sect_id: String = ""
	if offer_kind == "person":
		var p_rec: Dictionary = _db.get_record("people", offerer_id)
		if p_rec.is_empty() or not bool(p_rec.get("alive", false)):
			return {"ok": false, "quest": {}, "reason": "offerer_unavailable", "tries": 0}
		if int(p_rec.get("attitude", 0)) <= _QuestRules.hostile_threshold(_gd):
			return {"ok": false, "quest": {}, "reason": "offerer_hostile", "tries": 0}
		offerer_root_id = offerer_id
		offerer_sect_id = str(p_rec.get("sect_id", ""))
	elif offer_kind == "sect":
		var speaking_id: String = str(opts.get("speaking_member_id", ""))
		if _db.table_of(offerer_id) == "people":
			speaking_id = offerer_id
			offerer_sect_id = str(_db.get_record("people", speaking_id).get("sect_id", ""))
		else:
			offerer_sect_id = offerer_id
			var s_rec: Dictionary = _db.get_record("sects", offerer_sect_id)
			if s_rec.is_empty() or str(s_rec.get("status", "active")) != "active":
				return {"ok": false, "quest": {}, "reason": "sect_unavailable", "tries": 0}
			if speaking_id == "":
				speaking_id = _pick_sect_speaker(s_rec, place_id)
		var sp_rec: Dictionary = _db.get_record("people", speaking_id)
		if sp_rec.is_empty() or not bool(sp_rec.get("alive", false)):
			return {"ok": false, "quest": {}, "reason": "speaker_unavailable", "tries": 0}
		if int(sp_rec.get("attitude", 0)) <= _QuestRules.hostile_threshold(_gd):
			return {"ok": false, "quest": {}, "reason": "speaker_hostile", "tries": 0}
		offerer_root_id = speaking_id
	elif is_board:
		var holder_sect_id: String = str(place.get("holder", ""))
		if holder_sect_id != "":
			var hsect: Dictionary = _db.get_record("sects", holder_sect_id)
			if not hsect.is_empty() and str(hsect.get("status", "active")) == "active":
				offerer_sect_id = holder_sect_id
				var hid: String = str(hsect.get("leader_id", ""))
				if hid != "" and bool(_db.get_record("people", hid).get("alive", false)):
					offerer_root_id = hid
	else:
		return {"ok": false, "quest": {}, "reason": "unknown_offer_kind", "tries": 0}

	# Step 1: Choose source fact (Rule 2, Rule 15, AC-QS-03, AC-QS-102).
	var fact: Dictionary = _choose_source_fact(offer_kind, offerer_root_id, offerer_id, offerer_sect_id, place_id, season_idx, rng, opts)
	if fact.is_empty():
		return {"ok": false, "quest": {}, "reason": "no_source_fact", "tries": 0}
	var fact_kind: String = classify_fact_kind(fact)
	var fact_id: String = str(fact.get("id", ""))
	var place_kind: String = str(place.get("kind", place.get("type", "")))

	# Step 2 & 3: Filter matching templates and bind role slots (dropping any template whose required slot fails).
	var raw_templates: Array = Array(opts.get("templates", _QuestRules.templates(_gd)))
	var exclude_ids: Array = Array(opts.get("exclude_template_ids", []))
	var spent_pairs: Dictionary = Dictionary(opts.get("spent_board_pairs", {}))
	var leg_min: int = _QuestRules.legendary_min_realm_index(_gd, rules_override)

	var by_tier: Dictionary = {}
	for raw_t in raw_templates:
		if not (raw_t is Dictionary):
			continue
		var tpl: Dictionary = raw_t as Dictionary
		var tid: String = str(tpl.get("id", ""))
		if tid == "" or exclude_ids.has(tid):
			continue
		if is_board and spent_pairs.has("%s|%s" % [tid, fact_id]):
			continue
		var tier: String = str(tpl.get("tier", ""))
		if is_board and not bool(_QuestRules.tier_cfg(_gd, tier, rules_override).get("board_allowed", false)):
			continue
		if tier == "legendary" and leg_min >= 0 and player.realm_index < leg_min:
			continue
		if not Array(tpl.get("offer_kinds", [])).has(offer_kind):
			continue
		if not _matches_fact_kind(Array(tpl.get("fact_kinds", ["any"])), fact_kind):
			continue
		if not _matches_place_kind(Array(tpl.get("place_kinds", ["any"])), place_kind):
			continue
		var r_min: int = int(tpl.get("realm_min", 0))
		var r_max: int = int(tpl.get("realm_max", _gd.realms().size() - 1))
		if player.realm_index < r_min or player.realm_index > r_max:
			continue

		var bind_res: Dictionary = _bind_slots(tpl, player, offer_kind, offerer_root_id, offerer_sect_id, place_id, fact)
		if not bool(bind_res.ok):
			continue
		if not by_tier.has(tier):
			by_tier[tier] = []
		(by_tier[tier] as Array).append({"tpl": tpl, "bound": bind_res})

	if by_tier.is_empty():
		return {"ok": false, "quest": {}, "reason": "no_matching_template", "tries": 0}

	# Step 4: Draw tier by tier_share (with Legendary -> Major downgrade below Core Formation).
	var available_tiers: Array = by_tier.keys()
	var current_tier: String = draw_tier(_gd, rng, player.realm_index, available_tiers, offer_kind, rules_override)
	if current_tier == "":
		return {"ok": false, "quest": {}, "reason": "no_tier_available", "tries": 0}

	# Step 5-7: Weighted draw + parameter draw + strict validation, up to offer_tries (6) with lower-tier fallback.
	var tier_order: Array = Array(cfg.get("tier_order", ["errand", "ordinary", "major", "legendary"]))
	var max_tries: int = int(cfg.get("offer_tries", 6))
	var tries: int = 0
	var last_reason: String = "validation_failed"

	while tries < max_tries:
		var pool: Array = Array(by_tier.get(current_tier, []))
		while pool.is_empty():
			var pos: int = tier_order.find(current_tier)
			if pos <= 0:
				return {"ok": false, "quest": {}, "reason": last_reason, "tries": tries}
			current_tier = str(tier_order[pos - 1])
			pool = Array(by_tier.get(current_tier, []))

		var weights: Array = []
		for entry in pool:
			weights.append(maxf(0.01, float((entry.tpl as Dictionary).get("weight", 1.0))))
		var pick_idx: int = RngUtils.weighted_index(rng, weights)
		if pick_idx < 0:
			pick_idx = 0
		var chosen: Dictionary = pool[pick_idx]
		pool.remove_at(pick_idx)
		by_tier[current_tier] = pool
		tries += 1

		var tpl: Dictionary = chosen.tpl
		var bound: Dictionary = (chosen.bound as Dictionary).duplicate(true)
		var drawn_params: Dictionary = _draw_params(tpl, rng)
		var pending_new: Array = Array(bound.get("pending_new_people", []))

		# Build candidate plan without mutating WorldDB first.
		var built: Dictionary = _build_plan(
			tpl, bound, drawn_params, player, sheet, offer_kind,
			offerer_id, offerer_root_id, offerer_sect_id, place_id, fact, opts
		)
		var plan: Dictionary = built.plan

		# If template has new_person slots, pre-validate everything except their registration,
		# then register new_person(s) in WorldDB BEFORE returning the offer (Rule 13, AC-QS-17, AC-QS-150).
		if not pending_new.is_empty():
			var pre_check: Dictionary = _prevalidate_before_new_person(player, sheet, plan, pending_new, opts)
			if not bool(pre_check.ok):
				last_reason = "; ".join(PackedStringArray(pre_check.errors))
				continue
			_materialize_new_people(pending_new, bound, plan, player, place_id, rng)

		var vres: Dictionary = _QuestValidator.validate_plan(_gd, _db, player, sheet, plan, opts)
		if bool(vres.ok):
			var frozen_plan: Dictionary = plan.duplicate(true)
			var qid: String = "q_%s_%d_%d" % [str(tpl.id), season_idx, offer_idx]
			var quest_rec := {
				"id": qid,
				"template_id": str(tpl.id),
				"name": str(frozen_plan.get("name", tpl.name)),
				"tier": str(frozen_plan.tier),
				"offer_kind": offer_kind,
				"offerer_id": offerer_id if not is_board else offerer_sect_id,
				"offerer_root_id": offerer_root_id,
				"offerer_sect_id": offerer_sect_id,
				"adversary_id": str(frozen_plan.get("adversary_id", "")),
				"adversary_root_id": str(frozen_plan.get("adversary_root_id", "")),
				"place_id": place_id,
				"source_fact_id": fact_id,
				"source_fact": fact.duplicate(true),
				"stake_text": str(frozen_plan.get("stake_text", "")),
				"offer_text": str(frozen_plan.get("offer_text", "")),
				"slots": Dictionary(bound.get("slots", {})).duplicate(true),
				"params": drawn_params.duplicate(true),
				"plan": frozen_plan,
				"budget": Dictionary(vres.budget).duplicate(true),
				"deadline": int(vres.deadline.deadline),
				"window_sum": int(vres.deadline.window_sum),
				"outcomes": Array(frozen_plan.get("outcomes", [])).duplicate(true),
				"state": "offered",
				"stage": 1,
				"offered_season": season_idx,
				"board_no_attitude": is_board,
				"realm_index": player.realm_index,
			}
			return {"ok": true, "quest": quest_rec, "reason": "", "tries": tries}
		last_reason = "; ".join(PackedStringArray(vres.errors))

	return {"ok": false, "quest": {}, "reason": last_reason, "tries": tries}


## Maps a WorldDB event record's [code]type[/code] to a normalized source-fact kind for template matching.
static func classify_fact_kind(fact: Dictionary) -> String:
	var raw: String = str(fact.get("type", fact.get("kind", "place_fact"))).to_lower()
	match raw:
		"grudge", "quarrel", "feud", "feud_end_slain", "betrayal", "raid", "execution":
			return "grudge"
		"shortage", "drought", "flood", "disaster", "loss", "ship_lost", "shipwreck", "mine":
			return "shortage"
		"death", "tribulation_death", "burial", "sect_fall":
			return "death"
		"debt", "loan", "fine", "tribute", "contract":
			return "debt"
		"duel", "battle", "siege", "beast":
			return "duel"
		"war", "war_start", "sect_war", "claim", "pact", "truce":
			return "war"
		"trade", "sale", "craft", "forge", "item_made", "item_found", "item_lost", "item_taken":
			return "trade"
		"secret", "discovery", "realm_opened", "realm_sealed", "abode_sealed", "omen", "tale", "treasure":
			return "secret"
		"breakthrough", "ascension", "deviation", "technique", "technique_made", "doctrine":
			return "breakthrough"
		_:
			return raw if raw != "" else "place_fact"


# --- Source fact selection ----------------------------------------------------------------------------------------

func _choose_source_fact(
	offer_kind: String,
	offerer_root_id: String,
	offerer_id: String,
	_offerer_sect_id: String,
	place_id: String,
	season_idx: int,
	rng: RandomNumberGenerator,
	opts: Dictionary
) -> Dictionary:
	var spent: Dictionary = Dictionary(opts.get("spent_facts", {}))
	var cooldowns: Dictionary = Dictionary(opts.get("fact_cooldowns", {}))

	if opts.has("source_fact") and opts["source_fact"] is Dictionary:
		var explicit: Dictionary = opts["source_fact"] as Dictionary
		if explicit.is_empty():
			return {}
		var fid: String = str(explicit.get("id", ""))
		if fid != "" and (spent.has(fid) or season_idx < int(cooldowns.get(fid, -999999))):
			return {}
		if offer_kind != "board":
			if not _QuestValidator.offerer_has_stake_in_fact(_db, offerer_root_id, offerer_id, explicit):
				return {}
		return explicit

	var candidates: Array = []
	for raw_e in _db.all("events"):
		if not (raw_e is Dictionary):
			continue
		var e: Dictionary = raw_e as Dictionary
		if str(e.get("type", "")) == "hidden" or bool(Dictionary(e.get("data", {})).get("secret", false)):
			continue
		var fid: String = str(e.get("id", ""))
		if fid != "" and (spent.has(fid) or season_idx < int(cooldowns.get(fid, -999999))):
			continue
		if offer_kind == "board":
			if Array(e.get("places", [])).has(place_id):
				candidates.append(e)
		else:
			if _QuestValidator.offerer_has_stake_in_fact(_db, offerer_root_id, offerer_id, e):
				candidates.append(e)

	if candidates.is_empty():
		return {}
	# Sort deterministically by event id, then pick with the keyed offer RNG.
	candidates.sort_custom(func(a, b): return str(a.get("id", "")) < str(b.get("id", "")))
	return candidates[rng.randi_range(0, candidates.size() - 1)] as Dictionary


func _pick_sect_speaker(sect: Dictionary, place_id: String) -> String:
	var members: Array = Array(sect.get("members", [])).duplicate()
	members.sort()
	for mid_raw in members:
		var mid: String = str(mid_raw)
		var p: Dictionary = _db.get_record("people", mid)
		if not p.is_empty() and bool(p.get("alive", false)) and not bool(p.get("is_player", false)):
			if str(p.get("location_id", "")) == place_id and int(p.get("attitude", 0)) > _QuestRules.hostile_threshold(_gd):
				return mid
	var lid: String = str(sect.get("leader_id", ""))
	if lid != "" and bool(_db.get_record("people", lid).get("alive", false)):
		return lid
	return ""


# --- Role-slot binding --------------------------------------------------------------------------------------------

func _bind_slots(
	tpl: Dictionary,
	player: Character,
	offer_kind: String,
	offerer_root_id: String,
	offerer_sect_id: String,
	place_id: String,
	fact: Dictionary
) -> Dictionary:
	var slots_out: Dictionary = {
		"offerer": offerer_root_id,
		"offer_place": place_id,
		"offerer_sect": offerer_sect_id,
	}
	var pending_new: Array = []
	var slot_defs: Dictionary = Dictionary(tpl.get("slots", {}))
	var slot_names: Array = slot_defs.keys()
	slot_names.sort()

	for s_name_raw in slot_names:
		var s_name: String = str(s_name_raw)
		if not (slot_defs[s_name] is Dictionary):
			continue
		var sdef: Dictionary = slot_defs[s_name] as Dictionary
		var bind_kind: String = str(sdef.get("bind", "none"))
		var optional: bool = bool(sdef.get("optional", false))
		var resolved: String = ""

		match bind_kind:
			"none":
				resolved = ""
			"offerer":
				resolved = offerer_root_id
			"offer_place":
				resolved = place_id
			"nearest_living_calling":
				resolved = _find_nearest_living_calling(str(sdef.get("calling", "")), place_id, player.id, offerer_root_id)
			"sect_mate":
				resolved = _find_sect_mate(offerer_sect_id, player.id, offerer_root_id)
			"fact_person", "fact_other":
				resolved = _find_fact_person(fact, player.id, offerer_root_id)
			"fact_adversary":
				if offer_kind != "board":
					resolved = _find_fact_adversary(fact, player.id, offerer_root_id, offerer_sect_id)
			"fact_place":
				resolved = _find_fact_place(fact, place_id)
			"cast_key":
				resolved = _find_cast_key(str(sdef.get("key", "")))
			"new_person":
				var placeholder_id: String = "__new_person_%s__" % s_name
				resolved = placeholder_id
				pending_new.append({
					"slot": s_name,
					"placeholder": placeholder_id,
					"archetype": str(sdef.get("archetype", "")),
					"realm_offset": int(sdef.get("realm_offset", 0)),
					"calling": str(sdef.get("calling", "")),
					"sect_id": offerer_sect_id if bool(sdef.get("same_sect", false)) else "",
				})
			"same_region_settled":
				resolved = _find_region_place(place_id, true, int(sdef.get("max_travel", 4)))
			"same_region_wild":
				resolved = _find_region_place(place_id, false, int(sdef.get("max_travel", 4)))
			"slot_person_place":
				var ref_slot: String = str(sdef.get("person_slot", "target_person"))
				var pid: String = str(slots_out.get(ref_slot, ""))
				if pid != "" and not pid.begins_with("__new_person_"):
					resolved = str(_db.get_record("people", pid).get("location_id", ""))
				if resolved == "":
					resolved = place_id
			"named_continent_id":
				resolved = _find_continent_place(int(sdef.get("continent_id", -1)))

		if resolved == "" and not optional and bind_kind != "none":
			return {"ok": false, "reason": "slot_unbound:%s" % s_name}
		if resolved != "":
			slots_out[s_name] = resolved

	return {"ok": true, "slots": slots_out, "pending_new_people": pending_new}


func _find_nearest_living_calling(calling: String, from_place: String, player_id: String, offerer_id: String) -> String:
	var best_id: String = ""
	var best_dist: float = INF
	var living: Array = _db.living()
	living.sort_custom(func(a, b): return str(a.get("id", "")) < str(b.get("id", "")))
	for p in living:
		var pid: String = str(p.get("id", ""))
		if pid == "" or pid == player_id or pid == offerer_id or bool(p.get("is_player", false)) or bool(p.get("is_beast", false)):
			continue
		var p_call: String = str(Dictionary(p.get("npc_traits", {})).get("calling", p.get("calling", "")))
		if calling != "" and p_call != calling:
			continue
		var loc: String = str(p.get("location_id", ""))
		var dist: float = 0.0 if loc == from_place else _travel_dist(from_place, loc)
		if dist < best_dist - 1e-6:
			best_dist = dist
			best_id = pid
	return best_id


func _find_sect_mate(sect_id: String, player_id: String, offerer_id: String) -> String:
	if sect_id == "":
		return ""
	var sect: Dictionary = _db.get_record("sects", sect_id)
	var members: Array = Array(sect.get("members", [])).duplicate()
	members.sort()
	for mid_raw in members:
		var mid: String = str(mid_raw)
		if mid == "" or mid == player_id or mid == offerer_id:
			continue
		var p: Dictionary = _db.get_record("people", mid)
		if not p.is_empty() and bool(p.get("alive", false)) and not bool(p.get("is_player", false)):
			return mid
	return ""


func _find_fact_person(fact: Dictionary, player_id: String, offerer_id: String) -> String:
	for raw in Array(fact.get("people", [])):
		var id: String = str(raw)
		if id == "" or id == player_id or id == offerer_id:
			continue
		if _db.table_of(id) == "people":
			var p: Dictionary = _db.get_record("people", id)
			if not p.is_empty() and bool(p.get("alive", false)) and not bool(p.get("is_player", false)):
				return id
	return ""


func _find_fact_adversary(fact: Dictionary, player_id: String, offerer_id: String, offerer_sect_id: String) -> String:
	var fdata: Dictionary = Dictionary(fact.get("data", {}))
	var explicit: String = str(fdata.get("adversary_id", ""))
	if explicit != "" and explicit != player_id and explicit != offerer_id:
		return _resolve_living_adversary(explicit)
	for raw in Array(fact.get("people", [])):
		var id: String = str(raw)
		if id == "" or id == player_id or id == offerer_id or id == offerer_sect_id:
			continue
		var resolved: String = _resolve_living_adversary(id)
		if resolved != "":
			return resolved
	for raw_s in Array(fact.get("sects", [])):
		var sid: String = str(raw_s)
		if sid == "" or sid == offerer_sect_id:
			continue
		var resolved: String = _resolve_living_adversary(sid)
		if resolved != "":
			return resolved
	return ""


func _resolve_living_adversary(entity_id: String) -> String:
	if _db.table_of(entity_id) == "sects":
		var sect: Dictionary = _db.get_record("sects", entity_id)
		if sect.is_empty() or str(sect.get("status", "active")) != "active":
			return ""
		var hid: String = str(sect.get("leader_id", ""))
		if hid != "" and bool(_db.get_record("people", hid).get("alive", false)):
			return entity_id
		return ""
	var p: Dictionary = _db.get_record("people", entity_id)
	if not p.is_empty() and bool(p.get("alive", false)) and not bool(p.get("is_player", false)):
		return entity_id
	return ""


func _find_fact_place(fact: Dictionary, fallback_place: String) -> String:
	for raw in Array(fact.get("places", [])):
		var pid: String = str(raw)
		if pid != "" and _db.has_record("places", pid):
			return pid
	return fallback_place


func _find_cast_key(cast_key: String) -> String:
	if cast_key == "":
		return ""
	for p in _db.living():
		if str(p.get("cast_key", "")) == cast_key:
			return str(p.get("id", ""))
	return ""


func _find_region_place(from_place: String, settled: bool, max_travel: int) -> String:
	var cur: Dictionary = _db.get_record("places", from_place)
	var reg: String = str(cur.get("region_id", ""))
	var settled_kinds := ["great_seat", "minor_seat", "sect_hall", "city", "market", "town", "village", "thanh", "tran", "phuong_thi", "thon"]
	var places: Array = _db.all("places")
	places.sort_custom(func(a, b): return str(a.get("id", "")) < str(b.get("id", "")))
	var best_id: String = ""
	var best_d: float = INF
	for pl in places:
		var pid: String = str(pl.get("id", ""))
		if pid == "" or pid == from_place:
			continue
		if reg != "" and str(pl.get("region_id", "")) != reg:
			continue
		var kind: String = str(pl.get("kind", pl.get("type", "")))
		var is_set: bool = settled_kinds.has(kind)
		if is_set != settled:
			continue
		var d: float = _travel_dist(from_place, pid)
		if d <= float(max_travel) + 1e-6 and d < best_d - 1e-6:
			best_d = d
			best_id = pid
	return best_id if best_id != "" else from_place


func _find_continent_place(continent_id: int) -> String:
	if continent_id < 0:
		return ""
	for pl in _db.all("places"):
		if int(pl.get("continent_id", -1)) == continent_id:
			return str(pl.get("id", ""))
	return ""


func _travel_dist(from_id: String, to_id: String) -> float:
	if from_id == to_id or from_id == "" or to_id == "":
		return 0.0
	var r: Dictionary = Travel.quickest(_db, from_id, to_id, 1.0)
	if r.is_empty():
		return 1.0
	return float(r.get("seasons", 1.0))


# --- Parameter drawing & plan instantiation -----------------------------------------------------------------------

func _draw_params(tpl: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	var out: Dictionary = {}
	var pdefs: Dictionary = Dictionary(tpl.get("params", {}))
	var keys: Array = pdefs.keys()
	keys.sort()
	for k_raw in keys:
		var k: String = str(k_raw)
		var spec: Variant = pdefs[k]
		if spec is Array and (spec as Array).size() >= 2:
			var lo: Variant = spec[0]
			var hi: Variant = spec[1]
			var is_int_range: bool = _is_whole(lo) and _is_whole(hi) and not (k.ends_with("_share") or k.ends_with("_pct"))
			if is_int_range:
				out[k] = rng.randi_range(int(lo), int(hi))
			else:
				out[k] = rng.randf_range(float(lo), float(hi))
		else:
			out[k] = spec
	return out


func _build_plan(
	tpl: Dictionary,
	bound: Dictionary,
	drawn_params: Dictionary,
	player: Character,
	sheet: StatSheet,
	offer_kind: String,
	offerer_id: String,
	offerer_root_id: String,
	offerer_sect_id: String,
	place_id: String,
	fact: Dictionary,
	opts: Dictionary
) -> Dictionary:
	var rules_override: Dictionary = Dictionary(opts.get("rules_override", {}))
	var cfg: Dictionary = _QuestRules.config(_gd, rules_override)
	var slots: Dictionary = Dictionary(bound.get("slots", {}))
	var tier: String = str(tpl.get("tier", "errand"))
	var adv_id: String = str(slots.get("adversary", ""))
	var adv_root_id: String = adv_id
	if adv_id != "" and _db.table_of(adv_id) == "sects":
		adv_root_id = str(_db.get_record("sects", adv_id).get("leader_id", ""))

	# Build concrete stages first to compute travel, budget, and deadline.
	var stages: Array = []
	var prev_place: String = place_id
	var travel_total: float = 0.0
	var speed_f: float = Travel.speed_factor(_gd, sheet.total("travel_speed_pct")) if sheet != null else 1.0

	for raw_st in Array(tpl.get("stages", [])):
		var st_tpl: Dictionary = raw_st as Dictionary
		var st: Dictionary = st_tpl.duplicate(true)
		var kind: String = str(st.get("kind", ""))

		if kind == "mission" and bool(st.get("use_mission_param", false)) and drawn_params.has("mission_seasons"):
			st["seasons"] = int(drawn_params["mission_seasons"])
			st["window"] = maxi(int(st.get("window", 1)), int(st["seasons"]))
		if st.has("window_param"):
			var wp: String = str(st["window_param"])
			if drawn_params.has(wp):
				st["window"] = int(drawn_params[wp])

		var p_slot: String = str(st.get("place_slot", "offer_place"))
		var st_place: String = str(slots.get(p_slot, place_id))
		if st_place == "":
			st_place = place_id
		st["place_id"] = st_place
		if st_place != prev_place and _db.has_record("places", st_place) and _db.has_record("places", prev_place):
			var leg: Dictionary = Travel.quickest(_db, prev_place, st_place, speed_f)
			if not leg.is_empty():
				travel_total += float(leg.seasons)
			prev_place = st_place

		var t_slot: String = str(st.get("target_slot", ""))
		if t_slot != "" and slots.has(t_slot):
			st["target_id"] = str(slots[t_slot])
		if not st.has("if_target_lost"):
			st["if_target_lost"] = "orphan"

		st["title"] = _render_text(str(st.get("title", "")), slots, tpl)
		var texts: Array = Array(st.get("text", []))
		st["text_rendered"] = _render_text(str(texts[0]) if not texts.is_empty() else "", slots, tpl)
		stages.append(st)

	var travel_seasons: int = int(opts["travel_override"]) if opts.has("travel_override") else int(ceil(travel_total - 1e-9)) if travel_total > 1e-9 else 0
	var budget: Dictionary = _QuestRules.compute_budget(_gd, tier, player.realm_index, stages, travel_seasons, rules_override)

	# Populate concrete deliver prices & bounded stage reward lines within Formula A ceilings.
	var cash_share: float = clampf(float(drawn_params.get("cash_share", float(cfg.get("quest_cash_share", 0.2)))), 0.0, float(cfg.get("quest_cash_share", 0.2)))
	var cash_budget_left: int = mini(int(budget.cash_max), int(floor(cash_share * float(budget.B) + 1e-9)))
	var n: int = stages.size()
	for i in range(n):
		var st: Dictionary = stages[i]
		if str(st.get("kind", "")) == "deliver" and not st.has("deliver_price"):
			var d_sh: float = float(st.get("deliver_share", 0.35))
			st["deliver_price"] = mini(int(budget.deliver_max), int(floor(d_sh * float(budget.B) + 1e-9)))
		if not st.has("rewards") and not st.has("effects"):
			var cap_i: int = int(budget.stage_pays[i]) if i < (budget.stage_pays as Array).size() else 0
			var stage_rewards: Array = []
			if cap_i > 0:
				var cash_i: int = mini(cash_budget_left, cap_i) if i < n - 1 else mini(cash_budget_left, cap_i)
				if cash_i > 0:
					stage_rewards.append({"type": "linh_thach", "amount": cash_i})
					cash_budget_left -= cash_i
				var item_val: int = cap_i - cash_i
				if item_val > 0:
					var item_type: String = str(st.get("reward_item_type", "material" if i < n - 1 else "artifact"))
					stage_rewards.append({"type": item_type, "value": item_val})
			st["rewards"] = stage_rewards

	# Resolve outcomes, dropping any entry whose role does not resolve (Rule 18, AC-QS-126, AC-QS-141).
	var resolved_outcomes: Array = []
	for raw_oc in Array(tpl.get("outcomes", [])):
		if not (raw_oc is Dictionary):
			continue
		var oc: Dictionary = (raw_oc as Dictionary).duplicate(true)
		var role: String = str(oc.get("role", ""))
		if not _outcome_role_resolves(role, offerer_root_id, offerer_sect_id, adv_id, adv_root_id):
			continue
		if oc.has("amount_share"):
			oc["resolved_amount"] = int(floor(float(oc["amount_share"]) * float(budget.B) + (1e-9 if float(oc["amount_share"]) >= 0.0 else -1e-9)))
		resolved_outcomes.append(oc)

	var rare_raw: Variant = tpl.get("rare_reward", null)
	var rare_out: Variant = null
	if rare_raw is Dictionary and not (rare_raw as Dictionary).is_empty():
		var rd: Dictionary = (rare_raw as Dictionary).duplicate(true)
		if str(rd.get("type", "")) == "above_cap_item" and not rd.has("price"):
			rd["price"] = mini(int(budget.final_pay), int(budget.B))
			rd["rarity"] = _QuestRules.legendary_rarity_cap(_gd, player.realm_index, rules_override)
		rare_out = rd

	var offer_texts: Array = Array(tpl.get("offer_text", []))
	var offer_line: String = _render_text(str(offer_texts[0]) if not offer_texts.is_empty() else "", slots, tpl)

	var plan := {
		"template_id": str(tpl.id),
		"name": _render_text(str(tpl.get("name", "")), slots, tpl),
		"tier": tier,
		"realm_index": player.realm_index,
		"offer_kind": offer_kind,
		"offerer_id": offerer_id if offer_kind != "board" else offerer_sect_id,
		"offerer_root_id": offerer_root_id,
		"offerer_sect_id": offerer_sect_id,
		"adversary_id": adv_id,
		"adversary_root_id": adv_root_id,
		"place_id": place_id,
		"source_fact": fact.duplicate(true),
		"stake_text": _render_text(str(tpl.get("stake_text", "")), slots, tpl),
		"offer_text": offer_line,
		"travel_seasons": travel_seasons,
		"stages": stages,
		"rare_reward": rare_out,
		"outcomes": resolved_outcomes,
	}
	return {"plan": plan, "budget": budget}


func _outcome_role_resolves(
	role: String,
	offerer_root_id: String,
	offerer_sect_id: String,
	adv_id: String,
	adv_root_id: String
) -> bool:
	match role:
		"offerer", "offerer_ties":
			return offerer_root_id != "" and bool(_db.get_record("people", offerer_root_id).get("alive", false))
		"offerer_sect":
			return offerer_sect_id != "" and str(_db.get_record("sects", offerer_sect_id).get("status", "active")) == "active"
		"adversary", "adversary_ties":
			return adv_root_id != "" and bool(_db.get_record("people", adv_root_id).get("alive", false))
		"adversary_sect":
			if adv_id != "" and _db.table_of(adv_id) == "sects":
				return str(_db.get_record("sects", adv_id).get("status", "active")) == "active"
			if adv_root_id != "":
				var sid: String = str(_db.get_record("people", adv_root_id).get("sect_id", ""))
				return sid != "" and str(_db.get_record("sects", sid).get("status", "active")) == "active"
			return false
	return false


func _prevalidate_before_new_person(
	player: Character,
	sheet: StatSheet,
	plan: Dictionary,
	pending_new: Array,
	opts: Dictionary
) -> Dictionary:
	var placeholders: Dictionary = {}
	for entry in pending_new:
		placeholders[str(entry.placeholder)] = true
	var check: Dictionary = _QuestValidator.validate_plan(_gd, _db, player, sheet, plan, opts)
	var real_errors: Array = []
	for err_raw in Array(check.errors):
		var err: String = str(err_raw)
		var is_placeholder_err: bool = false
		for ph in placeholders.keys():
			if err.contains(str(ph)):
				is_placeholder_err = true
				break
		if not is_placeholder_err:
			real_errors.append(err)
	return {"ok": real_errors.is_empty(), "errors": real_errors}


func _materialize_new_people(
	pending_new: Array,
	bound: Dictionary,
	plan: Dictionary,
	player: Character,
	place_id: String,
	rng: RandomNumberGenerator
) -> void:
	var slots: Dictionary = Dictionary(bound.get("slots", {}))
	var replacements: Dictionary = {}
	for entry in pending_new:
		var slot_name: String = str(entry.slot)
		var placeholder: String = str(entry.placeholder)
		var target_realm: int = clampi(player.realm_index + int(entry.get("realm_offset", 0)), 0, _gd.realms().size() - 1)
		var new_pid: String = ""
		if _builds != null:
			var create_opts := {
				"realm_index": target_realm,
				"location_id": place_id,
				"created_by": "quest_offer",
			}
			if str(entry.get("archetype", "")) != "":
				create_opts["archetype"] = str(entry.archetype)
			if str(entry.get("sect_id", "")) != "":
				create_opts["sect_id"] = str(entry.sect_id)
			new_pid = _builds.create_person(rng, create_opts)
		else:
			var c := Character.new()
			c.name = "Lữ Khách #%d" % (rng.randi() % 9000 + 1000)
			c.realm_index = target_realm
			c.location_id = place_id
			c.alive = true
			var rec: Dictionary = c.to_dict()
			rec["created_by"] = "quest_offer"
			new_pid = _db.add("people", rec)
		slots[slot_name] = new_pid
		replacements[placeholder] = new_pid

	bound["slots"] = slots
	for st in Array(plan.get("stages", [])):
		if st is Dictionary:
			var tid: String = str((st as Dictionary).get("target_id", ""))
			if replacements.has(tid):
				(st as Dictionary)["target_id"] = str(replacements[tid])
	var adv: String = str(plan.get("adversary_id", ""))
	if replacements.has(adv):
		plan["adversary_id"] = str(replacements[adv])
		plan["adversary_root_id"] = str(replacements[adv])


func _render_text(text: String, slots: Dictionary, tpl: Dictionary) -> String:
	var out: String = text
	var replacements := {
		"{name}": str(tpl.get("name", "")),
		"{offerer}": _entity_name(str(slots.get("offerer", ""))),
		"{place}": _entity_name(str(slots.get("offer_place", ""))),
		"{target_person}": _entity_name(str(slots.get("target_person", ""))),
		"{target_place}": _entity_name(str(slots.get("target_place", slots.get("offer_place", "")))),
		"{adversary}": _entity_name(str(slots.get("adversary", ""))),
		"{sect}": _entity_name(str(slots.get("offerer_sect", ""))),
	}
	for tok in replacements.keys():
		if out.contains(tok):
			out = out.replace(tok, str(replacements[tok]))
	return out


func _entity_name(entity_id: String) -> String:
	if entity_id == "" or entity_id.begins_with("__new_person_"):
		return "người liên quan"
	var rec: Dictionary = _db.lookup(entity_id)
	if not rec.is_empty() and str(rec.get("name", "")) != "":
		return str(rec.name)
	return entity_id


static func _matches_fact_kind(allowed: Array, fact_kind: String) -> bool:
	return allowed.is_empty() or allowed.has("any") or allowed.has(fact_kind)


static func _matches_place_kind(allowed: Array, place_kind: String) -> bool:
	return allowed.is_empty() or allowed.has("any") or allowed.has(place_kind)


static func _is_whole(v: Variant) -> bool:
	if v is int:
		return true
	if v is float:
		return is_equal_approx(float(v), roundf(float(v)))
	return false
