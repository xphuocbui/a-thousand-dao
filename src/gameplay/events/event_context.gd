class_name EventContext
extends RefCounted
## Builds the context an event source sees: the player, the place, people present,
## recent history, and the engine's reward budget for the player's realm (scaled by
## Khí vận). The same Dictionary feeds template events and the LLM prompt, so both
## draw on the world database (pillar: A World That Remembers) and both are bounded by
## the same budget (pillar: Every Number Is Bounded and Visible).
## Data: events_budgets.json.
##
## Usage:
## [codeblock]
## var ctx: Dictionary = EventContext.build(c, gd, db, sheet, year, season, "vi")
## var prompt_json: String = JSON.stringify(EventContext.for_prompt(ctx))
## [/codeblock]


## Full context (internal ids and budget included).
## [param extras] merges session facts the rules need: edge (bool), co_duyen_left (int).
static func build(c: Character, gd: GameData, db: WorldDB, sheet: StatSheet, year: int, season: int, language: String, extras: Dictionary = {}) -> Dictionary:
	var cfg: Dictionary = gd.budgets()
	var lim: Dictionary = cfg.context
	var place: Dictionary = db.get_record("places", c.location_id)
	var region: Dictionary = db.get_record("regions", str(place.get("region_id", "")))
	var sect: Dictionary = db.get_record("sects", c.sect_id)
	var here: Array = db.find("people", func(p): return p.alive and not p.get("is_player", false) and str(p.location_id) == c.location_id)
	here = here.slice(0, int(lim.npcs_here_max))
	var mates: Array = []
	if not sect.is_empty():
		mates = db.find("people", func(p): return p.alive and not p.get("is_player", false) and str(p.sect_id) == c.sect_id).slice(0, int(lim.sect_mates_max))
	var recent: Array = []
	for e in db.events_of(c.location_id).slice(-int(lim.recent_events_max)):
		recent.append({"year": int(e.year), "text": e.text})
	for e in db.events_of(c.id).slice(-3):
		recent.append({"year": int(e.year), "text": e.text})
	var ctx := {
		"year": year, "season": season, "language": language,
		"edge": bool(extras.get("edge", false)), "co_duyen_left": int(extras.get("co_duyen_left", 0)),
		"player": {
			"at_bottleneck": CultivationRules.at_bottleneck(c, gd),
			"id": c.id, "name": c.name, "realm": gd.realm_label(c.realm_index, c.stage), "realm_index": c.realm_index,
			"age": int(c.age), "linh_can": c.linh_can.describe(gd), "sect": sect.get("name", ""),
			"thien_phu": c.thien_phu.duplicate(), "tam_ma": int(c.tam_ma), "vitality_pct": int(c.vitality * 100.0),
			"linh_thach": c.linh_thach,
		},
		"place": {"id": c.location_id, "name": place.get("name", ""), "type": place.get("type", ""), "danger": int(place.get("danger", 1)), "region": region.get("name", "")},
		"sect": {"id": c.sect_id, "name": sect.get("name", ""), "alignment": sect.get("alignment_name", "")},
		"npcs_here": here.map(func(p): return _person_summary(p, gd)),
		"sect_mates": mates.map(func(p): return _person_summary(p, gd)),
		"recent_events": recent,
		"budget": budget(c, gd, sheet),
	}
	return ctx


## The budget block for a character: realm limits with reward ceilings scaled by Khí vận.
static func budget(c: Character, gd: GameData, sheet: StatSheet) -> Dictionary:
	var cfg: Dictionary = gd.budgets()
	var b: Dictionary = gd.realm_budget(c.realm_index).duplicate()
	var kv: float = sheet.effective("khi_van", c) if sheet != null else float(c.base_stat("khi_van"))
	var ceiling: float = float(cfg.khi_van_ceiling.base) + kv * float(cfg.khi_van_ceiling.per_point)
	b["ceiling"] = ceiling
	b["linh_thach_max"] = int(float(b.linh_thach_max) * ceiling)
	b["tu_vi_max"] = int(float(b.tu_vi_pct_max) * ceiling * CultivationRules.stage_requirement(c, gd))
	return b


## Compact JSON-safe view for the LLM prompt (no internal-only fields).
static func for_prompt(ctx: Dictionary) -> Dictionary:
	var b: Dictionary = ctx.budget
	return {
		"year": ctx.year, "player": ctx.player, "place": ctx.place, "sect": ctx.sect,
		"people_here": ctx.npcs_here, "sect_mates": ctx.sect_mates, "recent_history": ctx.recent_events,
		"budget": {
			"linh_thach_max": b.linh_thach_max, "linh_thach_cost_max": b.linh_thach_loss_max,
			"tu_vi_max": b.tu_vi_max, "khi_huyet_loss_pct_max": b.khi_huyet_loss_pct_max,
			"tam_ma_max": b.tam_ma_max, "dan_doc_max": b.dan_doc_max, "herb_age_max": b.herb_age_max,
		},
	}


static func _person_summary(p: Dictionary, gd: GameData) -> Dictionary:
	return {
		"id": p.id, "name": p.name, "realm": gd.realm_label(int(p.realm_index), int(p.stage)),
		"archetype": gd.archetype(str(p.archetype)).get("name", p.archetype), "sect_id": p.sect_id,
		"traits": trait_names(p.get("traits", []), gd), "attitude_to_player": int(p.get("attitude", 0)),
	}


## Trait ids to their Vietnamese names (world_names.json).
static func trait_names(ids: Array, gd: GameData) -> Array:
	var names: Dictionary = {}
	for t in gd.names().traits:
		names[t.id] = t.name
	return ids.map(func(i): return names.get(i, i))
