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


# --- The home record (rules 1-3, 9) -------------------------------------------------------------------------------
# A home record lives in its place's qi: qi.abode for a self-built or claimed abode (owner, grade, unpaid, pending,
# state, order, dormant) and qi.residences[person id] for a rented, bought, sect or starting residence (grade, and
# order and dormant once works stand there). "order" is the build order of the home's works ("w:<map work>" for a
# layer-1 work, "f:<formation>" for a standing array), "dormant" the works out of their slots (rule 9).

## [param pid]'s home record at a place with [param qi] (a reference, to write), or {} when it is not their home here.
static func home_rec(qi: Dictionary, pid: String) -> Dictionary:
	var ab: Dictionary = qi.get("abode", {})
	if not ab.is_empty() and str(ab.get("owner", "")) == pid and str(ab.get("state", "open")) in ["open", "claimed"]:
		return ab
	return qi.get("residences", {}).get(pid, {})


## Whether the record is a self-built or claimed abode (its grade can be raised and it pays grade upkeep).
static func is_abode(rec: Dictionary) -> bool:
	return rec.has("owner")


## The home's grade (1-5), or 0 with no record.
static func grade_of(rec: Dictionary) -> int:
	return int(rec.get("grade", 0))


## Rule 9 and F3: the level a work counts at, 0 when dormant, else min(level, ceiling at the grade). With no home record
## here the level counts as stored.
static func eff_level(gd: GameData, qi: Dictionary, pid: String, key: String, level: int, work_max: int) -> int:
	var rec: Dictionary = home_rec(qi, pid)
	if rec.is_empty():
		return level
	if Array(rec.get("dormant", [])).has(key):
		return 0
	return mini(level, ceiling(gd, grade_of(rec), work_max))


## The keys of the works [param c] holds at a home with [param qi]: its layer-1 works and its standing arrays.
static func held(qi: Dictionary, c: Character) -> Array:
	var out: Array = []
	for id in qi.get("layer1", {}).get(c.id, {}):
		out.append("w:%s" % id)
	for id in c.formations:
		if int(c.formations[id]) > 0:
			out.append("f:%s" % id)
	return out


## Rule 3: the slots the active works take (each existing work takes 1).
static func used(qi: Dictionary, c: Character) -> int:
	var rec: Dictionary = home_rec(qi, c.id)
	var dormant: Array = rec.get("dormant", [])
	return held(qi, c).filter(func(k): return not dormant.has(k)).size()


## Rule 9: keeps the build order in step with the works held, sends the latest built to dormancy while the works pass
## the slots, and brings dormant ones back, earliest built first, while a slot is free. Returns the lines to show.
static func reconcile(gd: GameData, qi: Dictionary, c: Character) -> Array:
	var rec: Dictionary = home_rec(qi, c.id)
	if rec.is_empty():
		return []
	var have: Array = held(qi, c)
	var order: Array = Array(rec.get("order", [])).filter(func(k): return have.has(k))
	for k in have:
		if not order.has(k):
			order.append(k)
	rec["order"] = order
	var dormant: Array = Array(rec.get("dormant", [])).filter(func(k): return have.has(k))
	var out: Array = []
	var cap: int = slots(gd, grade_of(rec))
	var active: Array = order.filter(func(k): return not dormant.has(k))
	while active.size() > cap:
		var k: String = active.pop_back()
		dormant.append(k)
		out.append("  %s goes dormant: the home has %d slot(s)." % [k.substr(2), cap])
	for k in order:
		if dormant.has(k) and active.size() < cap:
			dormant.erase(k)
			active.append(k)
			out.append("  %s wakes: a slot is free." % k.substr(2))
	rec["dormant"] = dormant
	return out


## Rules 3 and 7: whether [param c] may raise work [param key] to [param level] at the home with [param qi] (a free slot
## for a new work, and the level ceiling). {ok, reason}.
static func can_raise(gd: GameData, qi: Dictionary, c: Character, key: String, level: int, work_max: int) -> Dictionary:
	var rec: Dictionary = home_rec(qi, c.id)
	if rec.is_empty():
		return {"ok": true, "reason": ""}
	var g: int = grade_of(rec)
	if not held(qi, c).has(key) and used(qi, c) >= slots(gd, g):
		return {"ok": false, "reason": "no free slot (%d of %d used at grade %d)" % [used(qi, c), slots(gd, g), g]}
	if level > ceiling(gd, g, work_max):
		return {"ok": false, "reason": "level %d passes the level ceiling at grade %d (%d)" % [level, g, ceiling(gd, g, work_max)]}
	return {"ok": true, "reason": ""}


# --- Raising the grade and the seasonal upkeep (rules 6, 8) -------------------------------------------------------

## Rule 6 and F1: starts raising [param c]'s home a grade: only a self-built or claimed abode, only to a grade the realm
## can hold; the stones (burn_abode) are paid now and the new grade applies from the next season. {ok, lines}.
static func raise(gd: GameData, db: WorldDB, c: Character, qi: Dictionary) -> Dictionary:
	var rec: Dictionary = home_rec(qi, c.id)
	if rec.is_empty():
		return {"ok": false, "lines": ["You have no home here to raise."]}
	if not is_abode(rec):
		return {"ok": false, "lines": ["The residence's grade is fixed: rent or buy a better one, or open a cave abode."]}
	var g: int = grade_of(rec) + 1
	if int(rec.get("pending", 0)) > 0:
		return {"ok": false, "lines": ["The abode is already being raised to grade %d." % int(rec.pending)]}
	if g > 5 or g > top_grade(gd, c.realm_index):
		return {"ok": false, "lines": ["Grade %d needs a higher realm (%s can hold grade %d)." % [g, gd.realm(c.realm_index).name, top_grade(gd, c.realm_index)]]}
	var cost: int = grade_cost(gd, g, c.realm_index)
	if c.linh_thach < cost:
		return {"ok": false, "lines": ["Raising the abode to grade %d costs %d linh thạch; you have %d." % [g, cost, c.linh_thach]]}
	MoneyLedger.player_pay(db, c, "", cost, "abode")   # rule 14: burn_abode
	rec["pending"] = g
	return {"ok": true, "lines": ["You raise the abode toward grade %d (%d linh thạch, a season's work)." % [g, cost]]}


## Rules 6, 8 and 9 for [param c]'s home, once a season: a self-built or claimed abode pays its grade upkeep at the
## grade it stood at this season (burn_abode), counting consecutive unpaid seasons, and falls a grade at
## grade_fade_seasons (grade 1 never falls); a raise paid this season then takes effect; dormancy is reconciled.
## Returns the lines to show.
static func season(gd: GameData, db: WorldDB, c: Character, qi: Dictionary) -> Array:
	var rec: Dictionary = home_rec(qi, c.id)
	if rec.is_empty():
		return []
	var out: Array = []
	if is_abode(rec):
		if bool(rec.get("claim_season", false)):
			rec.erase("claim_season")   # rule 11: no grade upkeep in the claim season
		else:
			var up: int = grade_upkeep(gd, grade_of(rec), c.realm_index, c.linh_can.purity("tho"))
			if c.linh_thach >= up:
				MoneyLedger.player_pay(db, c, "", up, "abode")
				rec["unpaid"] = 0
			else:
				rec["unpaid"] = int(rec.get("unpaid", 0)) + 1
				if grade_of(rec) > 1 and int(rec.unpaid) >= int(cfg(gd).grade_fade_seasons):
					rec["grade"] = grade_of(rec) - 1
					rec["unpaid"] = 0
					out.append("  The abode's upkeep has gone unpaid: it falls to grade %d." % grade_of(rec))
		if int(rec.get("pending", 0)) > 0:
			rec["grade"] = int(rec.pending)
			rec["pending"] = 0
			out.append("  The abode reaches grade %d: %d slots." % [grade_of(rec), slots(gd, grade_of(rec))])
	out.append_array(reconcile(gd, qi, c))
	return out


## Rule 13: the abode stat block for [param c] at the home with [param qi] (grade, slots, works with level and state,
## the grade upkeep, the next grade).
static func lines(gd: GameData, qi: Dictionary, c: Character, l1u_arrays: float = 0.0) -> Array:
	var rec: Dictionary = home_rec(qi, c.id)
	if rec.is_empty():
		return ["This is not your home."]
	var g: int = grade_of(rec)
	var out: Array = ["%s, grade %d: %d of %d slots used%s." % ["Cave abode" if is_abode(rec) else "Residence", g, used(qi, c), slots(gd, g),
		(", upkeep %d linh thạch a season" % grade_upkeep(gd, g, c.realm_index, c.linh_can.purity("tho"))) if is_abode(rec) else ""]]
	var dormant: Array = rec.get("dormant", [])
	for k in rec.get("order", []):
		var id: String = str(k).substr(2)
		var is_w: bool = str(k).begins_with("w:")
		var lv: int = int(qi.get("layer1", {}).get(c.id, {}).get(id, {}).get("level", 0)) if is_w else int(c.formations.get(id, 0))
		var d: Dictionary = MapWorks.work(gd, id) if is_w else _formation_def(gd, id)
		var wmax: int = int(d.get("max", d.get("max_level", lv)))
		var eff: int = eff_level(gd, qi, c.id, str(k), lv, wmax)
		var stat: String = str(d.get("stat", ""))
		var gain: String = gd.format_mod("density_bonus" if stat == "density" else stat, float(d.get("per_level", 0.0)) * eff) if eff > 0 and stat != "" else "nothing"
		var state: String = " (dormant)" if dormant.has(k) else (" (counts at %d, the grade's ceiling)" % eff if eff < lv else "")
		out.append("  %-16s level %d: %s%s" % [str(d.get("name", id)), lv, gain, state])
	for l in MapWorks.density(gd, qi, c, 0, l1u_arrays).lines:   # rule 13: every clamp line
		if str(l).contains("clamped"):
			out.append("  " + str(l))
	if is_abode(rec) and g < 5:
		out.append("  next grade %d: %d linh thạch, %d slots%s" % [g + 1, grade_cost(gd, g + 1, c.realm_index), slots(gd, g + 1),
			"" if g + 1 <= top_grade(gd, c.realm_index) else " (needs a higher realm)"])
	return out


static func _formation_def(gd: GameData, id: String) -> Dictionary:
	for f in gd.file("crafting_formations").get("formations", []):
		if str(f.id) == id:
			return f
	return {}


# --- Leaving, claiming, ruin (rules 10, 11) -----------------------------------------------------------------------

## Rule 10: [param c] leaves the home at [param place] (its home moves elsewhere). A self-built or claimed abode is
## Left at its grade with its clock at 0; a residence returns to its holder. The standing arrays stay behind with the
## place (qi.arrays_left), stop counting and fade on the abode's clock; layer-1 works stay and their upkept ones fade
## (MapWorks.upkeep no longer bills them). The new home starts with no works.
static func leave(gd: GameData, c: Character, place: Dictionary) -> void:
	var qi: Dictionary = place.get("qi", {})
	if qi.is_empty():
		return
	var rec: Dictionary = home_rec(qi, c.id)
	if not rec.is_empty() and is_abode(rec):
		rec["state"] = "left"
		rec["unpaid"] = 0
		rec["pending"] = 0
		rec["dormant"] = []
	elif not rec.is_empty():
		qi.residences.erase(c.id)
	for id in qi.get("layer1", {}).get(c.id, {}):   # the works stay with the place and stop counting for the owner
		qi.layer1[c.id][id]["left"] = true
	if not c.formations.is_empty():
		if not qi.has("arrays_left"):
			qi["arrays_left"] = {}
		var left: Dictionary = qi.arrays_left.get(c.id, {})
		for id in c.formations:
			left[id] = {"level": int(c.formations[id]), "unpaid": 0}
		qi.arrays_left[c.id] = left
		c.formations = {}


## Formations rule 14 and Cave Abode rule 10: arrays left behind lose a level every array_fade_seasons and are gone at
## 0. Once a season for [param pid]. Returns lines.
static func fade_left(gd: GameData, db: WorldDB, pid: String) -> Array:
	var out: Array = []
	var every: int = int(cfg(gd).get("array_fade_seasons", 4))
	for p in db.all("places"):
		var left: Dictionary = p.get("qi", {}).get("arrays_left", {}).get(pid, {})
		for id in left.keys():
			left[id]["unpaid"] = int(left[id].get("unpaid", 0)) + 1
			if int(left[id].unpaid) >= every:
				left[id]["unpaid"] = 0
				left[id]["level"] = int(left[id].level) - 1
				if int(left[id].level) <= 0:
					left.erase(id)
					out.append("  The %s you left at %s has faded away." % [id, p.get("name", "")])
	return out


## Rule 11 and F4: whether the abode at [param place] can be claimed by [param c] (Left or a Ruin, not their own).
static func claimable(place: Dictionary, c: Character) -> bool:
	var ab: Dictionary = place.get("qi", {}).get("abode", {})
	if ab.is_empty() or not str(ab.get("state", "")) in ["left", "ruin"]:
		return false
	return str(ab.get("state", "")) == "left" or str(ab.get("owner", "")) != c.id   # rule 11: anyone, its old owner too


## Rule 11 and F4: [param c] claims the Left or ruined abode at [param place]: pays the fee (burn_abode), the abode
## comes back at grade_after, its permanent works and any upkept work that has not faded away pass to the claimant,
## arrays left there are gone, and its grade upkeep falls due from the next season. The caller leaves the old home
## first and passes the season. {ok, lines}.
static func claim(gd: GameData, db: WorldDB, c: Character, place: Dictionary) -> Dictionary:
	if not claimable(place, c):
		return {"ok": false, "lines": ["There is no left or ruined abode here to claim."]}
	var fee: int = claim_fee(gd, c.realm_index)
	if c.linh_thach < fee:
		return {"ok": false, "lines": ["Claiming this abode costs %d linh thạch; you have %d." % [fee, c.linh_thach]]}
	var qi: Dictionary = place.qi
	var ab: Dictionary = qi.abode
	var old: String = str(ab.get("owner", ""))
	MoneyLedger.player_pay(db, c, "", fee, "abode")   # rule 14: burn_abode
	var was: int = grade_of(ab)
	var works: Dictionary = qi.get("layer1", {}).get(old, {})
	if not qi.has("layer1"):
		qi["layer1"] = {}
	var kept: Dictionary = works.duplicate(true)
	qi.layer1.erase(old)
	qi.layer1[c.id] = kept
	for id in qi.layer1[c.id]:
		qi.layer1[c.id][id].erase("left")   # they count again for the claimant
	if qi.has("arrays_left"):
		qi.arrays_left.erase(old)
	ab["owner"] = c.id
	ab["grade"] = grade_after(gd, was, c.realm_index)
	ab["state"] = "claimed"
	ab["unpaid"] = 0
	ab["pending"] = 0
	ab["claim_season"] = true
	ab["order"] = []
	ab["dormant"] = []
	place["owner_id"] = c.id
	var lines: Array = ["You claim the abode for %d linh thạch: grade %d (it stood at %d)." % [fee, grade_of(ab), was]]
	lines.append_array(reconcile(gd, qi, c))
	return {"ok": true, "lines": lines}


## Rule 10: the owner of the abode at [param place] died: it becomes a Ruin (a claim target; an heir claims like
## anyone, rule 11).
static func ruin(place: Dictionary) -> void:
	var ab: Dictionary = place.get("qi", {}).get("abode", {})
	if not ab.is_empty():
		ab["state"] = "ruin"
		ab["unpaid"] = 0
		ab["pending"] = 0


# --- NPC abodes (rule 12, F5) -------------------------------------------------------------------------------------

## Rule 12 and F5, once a season for every living loose cultivator (no sect, not a beast, not the player): the grade
## (p.abode_grade, 1 when unset) may rise by the keyed roll when the purse read before the upkeep passes the gate,
## the grade upkeep of the old grade is paid from the NPC's own purse (rule 6: the old grade holds this season), and
## an NPC that cannot pay advances only its own fade clock (p.abode_unpaid, rule 8). Every payment is burned in one
## burn_abode aggregate ([param money] may be null in a world without books: the stones are still taken). Returns
## the aggregate paid.
static func npc_season(gd: GameData, db: WorldDB, money: MoneyLedger, seed_s: String, abs_season: int) -> float:
	var takes: Array = []
	var total: float = 0.0
	var fade: int = int(cfg(gd).grade_fade_seasons)
	for p in db.living():
		if not bool(p.get("alive", true)) or bool(p.get("is_player", false)) or bool(p.get("is_beast", false)):
			continue
		if str(p.get("sect_id", "")) != "":
			continue
		var pay: float = npc_pay(gd, p, npc_roll(seed_s, str(p.id), abs_season), fade)
		if pay > 0.0:
			takes.append(["npc:%s" % p.id, pay])
			total += pay
	if money != null:
		money.burn_many(takes, "abode")
	else:
		for e in takes:
			var p: Dictionary = db.get_record("people", str(e[0]).substr(4))
			p["linh_thach"] = float(p.get("linh_thach", 0.0)) - float(e[1])
	return total


## One NPC's F5 season on its record [param p] with roll [param u]: sets abode_grade and abode_unpaid and returns the
## stones it pays (the raise plus the old grade's upkeep, or 0 when it cannot pay the upkeep). The purse is not
## touched here (the caller burns the sum).
static func npc_pay(gd: GameData, p: Dictionary, u: float, fade: int) -> float:
	var g: int = int(p.get("abode_grade", 1))
	var realm: int = int(p.get("realm_index", 0))
	var purse: float = float(p.get("linh_thach", 0.0))
	var raise_cost: float = 0.0
	if npc_raises(gd, g, realm, purse, u):
		raise_cost = float(grade_cost(gd, g + 1, realm))
	var tho: float = _npc_tho(p)
	var up: float = float(grade_upkeep(gd, g, realm, tho))
	var pay: float = raise_cost
	if purse - raise_cost >= up:
		pay += up
		p["abode_unpaid"] = 0
	else:
		p["abode_unpaid"] = int(p.get("abode_unpaid", 0)) + 1
		if g > 1 and int(p.abode_unpaid) >= fade:
			g -= 1
			p["abode_unpaid"] = 0
	if raise_cost > 0.0:
		g += 1
	p["abode_grade"] = g
	return pay


## Thổ purity on an NPC record's linh căn (LinhCan.purity without building the object).
static func _npc_tho(p: Dictionary) -> float:
	var lc: Dictionary = p.get("linh_can", {})
	var r: float = float(lc.get("road", {}).get("tho", 0.0))
	if lc.get("elements", {}).has("tho"):
		return float(lc.elements.tho) + r
	return float(lc.get("variants", {}).get("tho", 0.0)) + r
