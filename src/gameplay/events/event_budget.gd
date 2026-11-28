class_name EventBudget
extends RefCounted
## Chain and story shared reward budget ledger (design/gdd/event-engine.md Rule 14,
## Formulas C; AC-EV-21 through AC-EV-25; Quests Rule 19).
##
## Every chain (an event plus its follow-ups) or story shares one budget per scalar reward kind
## ([code]linh_thach[/code], [code]tu_vi[/code]) equal to [code]m * B_ev[k][/code], plus a total
## item grant count cap ([code]items_max[/code]). A single event step is still bounded by one
## event's ceiling [code]B_ev[k][/code]. Losses never spend the budget. On realm change, the
## unspent share carries over proportionally to the new realm's ceiling (non-quest chains only).

const _EventStore = preload("res://src/gameplay/events/event_store.gd")


## Returns the fortune (khí vận) ceiling multiplier [code]c_kv = base + per_point * kv[/code]
## (uncapped above 100 per Pillar 2 & scale-without-caps; AC-EV-22).
static func fortune_multiplier(gd: GameData, kv: float) -> float:
	var cfg: Dictionary = gd.budgets().get("khi_van_ceiling", {"base": 0.75, "per_point": 0.005})
	return float(cfg.get("base", 0.75)) + float(cfg.get("per_point", 0.005)) * kv


## Computes one event's reward ceiling [code]B_ev[/code] for [param c] (Formulas C).
## Returns [code]{c_kv, linh_thach, tu_vi, realm_index, stage}[/code].
static func event_ceiling(gd: GameData, c: Character, sheet: StatSheet) -> Dictionary:
	var rb: Dictionary = gd.realm_budget(c.realm_index)
	var kv: float = sheet.effective("khi_van", c) if sheet != null else float(c.base_stat("khi_van"))
	var c_kv: float = fortune_multiplier(gd, kv)
	var lt_cap: float = float(rb.get("linh_thach_max", 80)) * c_kv
	var tv_cap: float = float(rb.get("tu_vi_pct_max", 0.5)) * c_kv * CultivationRules.stage_cost(c, gd)
	return {
		"c_kv": c_kv,
		"linh_thach": lt_cap,
		"tu_vi": tv_cap,
		"realm_index": c.realm_index,
		"stage": c.stage,
	}


## Creates and persists a new chain or story budget ledger in [param db] and returns its [code]chain_id[/code].
## When [param custom_quest_b] >= 0, [code]linh_thach[/code] total uses [param custom_quest_b]
## directly (Quests Rule 19) and is frozen across realm changes (AC-QS-29).
static func create_chain(
	db: WorldDB,
	gd: GameData,
	c: Character,
	sheet: StatSheet,
	mult: float,
	items_max: int,
	custom_quest_b: int = -1
) -> String:
	var cb_cfg: Dictionary = gd.budgets().get("chain_budgets", {})
	var m_max: float = float(cb_cfg.get("m_story_max", 3.0))
	var m: float = clampf(mult, 0.0, m_max) if custom_quest_b < 0 else maxf(mult, 0.0)
	var ceil_d: Dictionary = event_ceiling(gd, c, sheet)
	var is_quest: bool = custom_quest_b >= 0
	var lt_total: float = float(custom_quest_b) if is_quest else float(ceil_d.linh_thach) * m
	var tv_total: float = float(ceil_d.tu_vi) * m
	var seq: int = _EventStore.all_chain_budgets(db).size() + 1
	var chain_id: String = "ch_%s_%d" % [c.id if c.id != "" else "root", seq]
	while not _EventStore.get_chain_budget(db, chain_id).is_empty():
		seq += 1
		chain_id = "ch_%s_%d" % [c.id if c.id != "" else "root", seq]
	var rec := {
		"chain_id": chain_id,
		"root_id": c.id,
		"realm_index": c.realm_index,
		"mult": m,
		"is_quest": is_quest,
		"total": {"linh_thach": lt_total, "tu_vi": tv_total},
		"left": {"linh_thach": lt_total, "tu_vi": tv_total},
		"items_max": maxi(0, items_max),
		"items_used": 0,
	}
	_EventStore.put_chain_budget(db, rec)
	return chain_id


## Carries over the unspent share of every non-quest chain/story budget owned by [param c]
## to the new realm's ceiling: [code]B_left' = (B_left / B_ch) * B_ch'[/code] (Formulas C, AC-EV-25).
static func on_realm_change(db: WorldDB, gd: GameData, c: Character, sheet: StatSheet) -> void:
	if db == null or c == null:
		return
	var ceil_d: Dictionary = event_ceiling(gd, c, sheet)
	for rec in _EventStore.all_chain_budgets(db, c.id):
		if bool(rec.get("is_quest", false)):
			continue
		var m: float = float(rec.get("mult", 1.5))
		var total_d: Dictionary = Dictionary(rec.get("total", {}))
		var left_d: Dictionary = Dictionary(rec.get("left", {}))
		for k in ["linh_thach", "tu_vi"]:
			var old_total: float = float(total_d.get(k, 0.0))
			var old_left: float = float(left_d.get(k, 0.0))
			var new_total: float = float(ceil_d.get(k, 0.0)) * m
			var share: float = (old_left / old_total) if old_total > 0.0 else 0.0
			total_d[k] = new_total
			left_d[k] = share * new_total
		rec["total"] = total_d
		rec["left"] = left_d
		rec["realm_index"] = c.realm_index
		_EventStore.put_chain_budget(db, rec)


## Spends up to [code]min(requested, event_cap, B_left[key])[/code] from [param chain_id]
## (Formulas C; AC-EV-21, AC-EV-23). Negative or zero requests do not spend the budget.
## Appends a clamp warning to [param warnings] whenever the paid amount is less than requested.
static func spend_scalar(
	db: WorldDB,
	chain_id: String,
	key: String,
	requested: float,
	event_cap: float,
	warnings: Array
) -> float:
	if requested <= 0.0:
		return requested
	var rec: Dictionary = _EventStore.get_chain_budget(db, chain_id)
	if rec.is_empty():
		var plain: float = minf(requested, event_cap) if event_cap >= 0.0 else requested
		if plain < requested - 1e-6:
			warnings.append("%s %s clamped from %.2f to %.2f (event cap %.2f)" % [chain_id, key, requested, plain, event_cap])
		return maxf(0.0, plain)
	var left_d: Dictionary = Dictionary(rec.get("left", {}))
	var left: float = maxf(0.0, float(left_d.get(key, 0.0)))
	var limit: float = minf(left, event_cap) if event_cap >= 0.0 else left
	var grant: float = maxf(0.0, minf(requested, limit))
	if grant < requested - 1e-6:
		warnings.append("chain %s %s clamped from %.2f to %.2f (event_cap %.2f, budget_left %.2f)" % [
			chain_id, key, requested, grant, event_cap, left,
		])
	left_d[key] = maxf(0.0, left - grant)
	rec["left"] = left_d
	_EventStore.put_chain_budget(db, rec)
	return grant


## Attempts to consume one item grant slot from [param chain_id] (Formulas C, AC-EV-24).
## Returns true if allowed, or false and appends a warning when the item cap is exhausted.
static func try_spend_item(db: WorldDB, chain_id: String, warnings: Array) -> bool:
	var rec: Dictionary = _EventStore.get_chain_budget(db, chain_id)
	if rec.is_empty():
		return true
	var used: int = int(rec.get("items_used", 0))
	var cap: int = int(rec.get("items_max", 2))
	if used >= cap:
		warnings.append("chain %s item grant dropped (item cap %d reached)" % [chain_id, cap])
		return false
	rec["items_used"] = used + 1
	_EventStore.put_chain_budget(db, rec)
	return true
