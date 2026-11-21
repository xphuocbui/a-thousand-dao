class_name CaveAbode
extends RefCounted
## Cave Abode & Home Works (design/gdd/cave-abode.md, #47): a home's grade (1-5) sets its work slots and the level
## ceiling of its works (F3); a self-built or claimed abode is raised with stones (F1) and costs upkeep each season
## (F2), and falls a grade after grade_fade_seasons unpaid seasons; a left abode can be claimed (F4); NPCs raise
## theirs from their purses (F5). Data: cave_abode.json. Stones on the abode itself are burn_abode (Formula H).
##
## Usage:
## [codeblock]
## var cost: int = CaveAbode.grade_cost(gd, 3, 2)       # F1: 3,750 at Core Formation
## var up: int = CaveAbode.grade_upkeep(gd, 5, 3, 0.0)  # F2: 400 a season at Nascent Soul
## [/codeblock]

const FILE := "cave_abode"


static func cfg(gd: GameData) -> Dictionary:
	return gd.file(FILE)


static func _budget(gd: GameData, realm: int) -> float:
	return float(gd.realm_budget(clampi(realm, 0, gd.realms().size() - 1)).get("linh_thach_max", 0))


## F1: linh thạch to raise an abode to grade [param g] (2-5) for an owner of [param realm]; 0 for grade 1 (only the
## opening fee).
static func grade_cost(gd: GameData, g: int, realm: int) -> int:
	if g <= 1:
		return 0
	return int(round(_budget(gd, realm) * float(cfg(gd).grade_cost_frac.get(str(g), 0.0))))


## F2: a grade-[param g] abode's upkeep a season for an owner of [param realm] with Thổ purity [param tho]:
## max(1, ceil(round(budget × upkeep_frac[g] × (1 − tho_cut), 6))), tho_cut = clamp(tho × 0.004, 0, 0.9).
static func grade_upkeep(gd: GameData, g: int, realm: int, tho: float) -> int:
	var fr: Array = cfg(gd).upkeep_frac
	var cut: float = clampf(tho * float(MapWorks.cfg(gd).get("tho_upkeep_cut_per_purity", 0.004)), 0.0, 0.9)
	var v: float = snappedf(_budget(gd, realm) * float(fr[clampi(g, 1, fr.size()) - 1]) * (1.0 - cut), 0.000001)
	return maxi(1, int(ceil(v)))


## F3: work slots at grade [param g].
static func slots(gd: GameData, g: int) -> int:
	var s: Array = cfg(gd).slots_by_grade
	return int(s[clampi(g, 1, s.size()) - 1])


## F3: the level ceiling for a work of maximum [param work_max] at grade [param g], min(work_max, g + level_margin).
static func ceiling(gd: GameData, g: int, work_max: int) -> int:
	return mini(work_max, g + int(cfg(gd).level_margin))


## Rule 2 and F4: the highest grade [param realm] can hold.
static func top_grade(gd: GameData, realm: int) -> int:
	var t: Array = cfg(gd).top_grade_by_realm
	return int(t[clampi(realm, 0, t.size() - 1)])


## F4: the claim fee for a claimant of [param realm], round(budget × abode_cost_frac × claim_frac).
static func claim_fee(gd: GameData, realm: int) -> int:
	return int(round(_budget(gd, realm) * float(MapWorks.cfg(gd).get("abode_cost_frac", 0.05)) * float(cfg(gd).claim_frac)))


## F4: the grade a claimed abode comes back at, min(max(1, grade_before − 1), top_grade[claimant realm]).
static func grade_after(gd: GameData, grade_before: int, realm: int) -> int:
	return mini(maxi(1, grade_before - 1), top_grade(gd, realm))


## F5: whether an NPC at grade [param g] with [param purse] raises this season, given its roll [param u] (0-1).
static func npc_raises(gd: GameData, g: int, realm: int, purse: float, u: float) -> bool:
	if g >= top_grade(gd, realm):
		return false
	return purse >= float(grade_cost(gd, g + 1, realm)) * float(cfg(gd).npc_reserve_mult) and u < float(cfg(gd).npc_raise_p)


## F5's keyed seasonal roll for [param pid] in [param season] (no draw from the tick's random stream).
static func npc_roll(seed_s: String, pid: String, season: int) -> float:
	return float(RngUtils.stable_hash("abode:%s:%s:%d" % [seed_s, pid, season]) % 1000000) / 1000000.0
