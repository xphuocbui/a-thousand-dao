class_name TalentPlace
extends RefCounted

## Living World Tick Formulas H, the talent and place multiplier on an NPC's stage chance (design/gdd/living-world-tick.md;
## q_i amended 2026-11-24 to Travel & Map Formula B's stacked density, so a sect's buildings speed its members):
## raw_i = root_i · max(q_i, 0.1); s_i = clamp((raw_i / mean_raw)^γ, m_lo, m_hi); m_i = s_i / mean(s).
## root_i is the root curve factor (CultivationRules.curve_factor, read from the record); q_i the stacked density of
## the person's place without personal layers, a sect member's being the seat's. mean_raw and mean(s) are recomputed
## each Spring over living non-beast NPCs and kept in the world record w_talent, so a save resumes with the same means.
## Knobs: world_generation.json tick.talent_gamma, talent_min, talent_max.
##
## Usage:
## [codeblock]
## var cache := {}                                            # place id -> q, one season
## if season == 0: TalentPlace.recompute(gd, db, cache)      # Spring, before the people step
## var m: float = TalentPlace.mult(gd, db, p, cache)          # Formulas A: p_stage = min(m / N_stage, 1)
## [/codeblock]

const RECORD := "w_talent"


static func _cfg(gd: GameData) -> Dictionary:
	return gd.world_gen().tick


## The root curve factor of the person record [param p] at its realm and stage (CultivationRules.curve_factor without
## building a Character: n_eff = min(n_cap, base elements + innate variants)).
static func root_factor(gd: GameData, p: Dictionary) -> float:
	var lc: Dictionary = p.get("linh_can", {})
	var n: int = Dictionary(lc.get("elements", {})).size()
	for v in Dictionary(lc.get("variants", {})):
		if str(gd.variant(str(v)).get("origin", "")) == "innate":
			n += 1
	n = mini(int(gd.attributes().linh_can.n_cap), n)
	var groups: Array = gd.realm(int(p.get("realm_index", 0))).stage_curve_groups
	var group: String = str(groups[clampi(int(p.get("stage", 0)), 0, groups.size() - 1)])
	return float(gd.attributes().element_count_curve.get(str(n), {}).get(group, 1.0))


## q_i: the stacked density (Travel & Map Formula B, no personal layers) at [param p]'s place; a sect member reads the
## seat. A place without qi reads its land density, a missing place 1.0 (Edge Cases). [param cache] keeps one value
## per place for the season.
static func place_q(gd: GameData, db: WorldDB, p: Dictionary, cache: Dictionary) -> float:
	var pid: String = str(p.get("location_id", ""))
	var sid: String = str(p.get("sect_id", ""))
	if sid != "" and db.has_record("sects", sid):
		var seat: String = str(db.get_record("sects", sid).get("hq_place_id", ""))
		if seat != "":
			pid = seat
	if cache.has(pid):
		return float(cache[pid])
	var q: float = 1.0
	if pid != "" and db.has_record("places", pid):
		var place: Dictionary = db.get_record("places", pid)
		var d4: float = float(place.get("density", 1.0))
		var qi: Dictionary = place.get("qi", {})
		q = d4 if qi.is_empty() else float(LandQi.stacked_density(gd, null, qi, d4, 0.0).total)
	cache[pid] = q
	return q


## raw_i = root_i · max(q_i, 0.1).
static func raw(gd: GameData, db: WorldDB, p: Dictionary, cache: Dictionary) -> float:
	return root_factor(gd, p) * maxf(place_q(gd, db, p, cache), 0.1)


## s_i for [param raw_i] against [param mean_raw]: clamp((raw / mean_raw)^γ, m_lo, m_hi); 1 when γ is 0.
static func s_of(gd: GameData, raw_i: float, mean_raw: float) -> float:
	var c: Dictionary = _cfg(gd)
	var g: float = float(c.get("talent_gamma", 0.5))
	if g <= 0.0 or mean_raw <= 0.0:
		return 1.0
	return clampf(pow(maxf(raw_i, 1e-9) / mean_raw, g), float(c.get("talent_min", 0.5)), float(c.get("talent_max", 2.0)))


## Spring: recomputes mean_raw and mean(s) over living non-beast NPCs and stores them in the world record. With no
## such NPC both are 1 (every m_i is 1). Returns {mean_raw, mean_s, n}.
static func recompute(gd: GameData, db: WorldDB, cache: Dictionary) -> Dictionary:
	var raws: Array = []
	for p in db.living():
		if bool(p.get("alive", false)) and not bool(p.get("is_beast", false)) and not bool(p.get("is_player", false)):
			raws.append(raw(gd, db, p, cache))
	var out := {"id": RECORD, "mean_raw": 1.0, "mean_s": 1.0, "n": raws.size()}
	if not raws.is_empty():
		var sum_r: float = 0.0
		for r in raws:
			sum_r += float(r)
		out.mean_raw = sum_r / float(raws.size())
		var sum_s: float = 0.0
		for r in raws:
			sum_s += s_of(gd, float(r), float(out.mean_raw))
		out.mean_s = maxf(sum_s / float(raws.size()), 1e-9)
	db.put("world", out)
	return out


## m_i for the NPC record [param p]: s_i / mean(s) with this year's means (computed now if the world has none yet);
## 1 for a beast.
static func mult(gd: GameData, db: WorldDB, p: Dictionary, cache: Dictionary) -> float:
	if bool(p.get("is_beast", false)):
		return 1.0
	var means: Dictionary = db.get_record("world", RECORD) if db.has_record("world", RECORD) else recompute(gd, db, cache)
	return s_of(gd, raw(gd, db, p, cache), float(means.mean_raw)) / float(means.mean_s)
