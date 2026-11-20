class_name SectPolitics
extends RefCounted

## The politics between sects (design/gdd/sects.md rules 3-6, 12-13, 16-18 and States; Formulas F5, F5b, F6, F7, F8,
## F9, F18): each season the dials move toward their need, attitudes between sects move toward their target, pacts and
## feuds form and end, feuds become wars, wars resolve on strength, a won war moves a site, a vassal or a region (the
## map follows through [MapChange]), and vassals' loyalty moves and a Defiant vassal acts. Values are
## sects_members.json's [code]politics[/code] block. Draws come from a stream keyed on the game seed, season and pair,
## so a reload resolves the same.
##
## State: each sect record keeps [code]attitude[/code] {sect id: A}, [code]grudge[/code] {sect id: g},
## [code]relation[/code] {sect id: "peace" | "pact" | "feud" | "war" | "truce"}, [code]truce[/code] {sect id: seasons
## left}, [code]wars[/code] [sect ids], [code]s0[/code] (its strength at the start), [code]state[/code] (Thriving /
## Steady / Strained / Collapsing / Fallen) and, for a vassal, [code]loyalty[/code] and [code]loyalty_state[/code].
## The wars themselves are the world record [code]w_wars[/code].
##
## Usage:
## [codeblock]
## SectPolitics.setup(gd, db)                       # once, at world generation
## var news := SectPolitics.season(gd, db, money, year, season, seed)
## [/codeblock]

const WARS := "w_wars"

# The season's map facts, built once by [method _begin] (region adjacency by continent id, and each sect's held
# regions), so the pairwise formulas do not re-read the continent.
static var _adj: Dictionary = {}
static var _held: Dictionary = {}
static var _for_db: int = 0   # the world the cache was built for: another world rebuilds it
static var _bp: Dictionary = {}   # this season's balance-of-power term toward the strongest great sect {sect id: bp}


static func _cfg(gd: GameData) -> Dictionary:
	return gd.file("sects_members").get("politics", {})


static func _begin(gd: GameData, db: WorldDB) -> void:
	_for_db = db.get_instance_id()
	_bp = {}   # set again by season() once the strengths are known
	_adj = {}
	for r in gd.file(ContinentData.DATA_FILE).get("regions", []):
		_adj[int(r.id)] = Array(r.get("neighbours", [])).map(func(n): return int(n.region))
	_held = {}
	for r in db.all("regions"):
		var h: String = str(r.get("holder", ""))
		if not _held.has(h):
			_held[h] = {}
		_held[h][int(r.get("continent_id", -1))] = true


static func _active(db: WorldDB) -> Array:
	var out: Array = db.find("sects", func(s): return str(s.get("status", "")) == "active")
	out.sort_custom(func(a, b): return str(a.id) < str(b.id))
	return out


static func _greats(db: WorldDB) -> Array:
	return _active(db).filter(func(s): return str(s.get("kind", "")) == "great")


## Once at world generation: attitudes start at their target, authored grudges (World Generation rule 7) are loaded,
## every pair starts at peace (or feud where the attitude is already below the feud line), and each great sect's
## starting strength S0 is stored (F9's seat protection).
static func setup(gd: GameData, db: WorldDB, grudges: Array = []) -> void:
	var by_key := {}
	for s in db.all("sects"):
		by_key[str(s.get("key", ""))] = str(s.id)
	_begin(gd, db)
	var sects := _active(db)
	for s in sects:
		s["attitude"] = {}
		s["grudge"] = {}
		s["relation"] = {}
		s["truce"] = {}
		s["wars"] = []
		if str(s.get("kind", "")) == "minor":
			var loy = s.get("loyalty", null)
			s["loyalty"] = 60.0 if loy == null else float(loy)
			s["loyalty_state"] = loyalty_state(gd, float(s.loyalty))
	for g in grudges:
		var a: String = str(by_key.get(str(g.pair[0]), ""))
		var b: String = str(by_key.get(str(g.pair[1]), ""))
		if a == "" or b == "":
			continue
		db.get_record("sects", a).grudge[b] = float(g.g)
		db.get_record("sects", b).grudge[a] = float(g.g)
	var strength := strengths(gd, db)
	for s in sects:
		for o in sects:
			if str(o.id) == str(s.id):
				continue
			s.attitude[str(o.id)] = attitude_target(gd, db, s, o, strength)
			s.relation[str(o.id)] = "feud" if float(s.attitude[str(o.id)]) <= float(_cfg(gd).feud_line) else "peace"
		s["s0"] = float(strength.get(str(s.id), 0.0))
	for g in _greats(db):   # rule 30: how many vassals each territory starts with
		g["minor_start"] = SectEconomy.vassals(db, g).size()
	db.put("world", {"id": WARS, "wars": [], "next": 1})


## The loyalty state of a vassal at [param loy] (States: Loyal 60+, Restless 30-59, Defiant below the break line).
static func loyalty_state(gd: GameData, loy: float) -> String:
	var c: Dictionary = _cfg(gd)
	if loy >= float(c.loyal_line):
		return "loyal"
	if loy >= float(c.break_line):
		return "restless"
	return "defiant"


## F8: every active sect's war strength: mil_mult · Σ members · p_r, plus for a great sect lv · loy_f of each vassal's.
static func strengths(gd: GameData, db: WorldDB) -> Dictionary:
	var c: Dictionary = _cfg(gd)
	var p_r: Array = c.p_r
	var own := {}
	for p in db.all("people"):
		if not bool(p.get("alive", false)) or bool(p.get("is_beast", false)) or bool(p.get("is_player", false)):
			continue
		var sid: String = str(p.get("sect_id", ""))
		if sid != "":
			own[sid] = float(own.get(sid, 0.0)) + float(p_r[clampi(int(p.get("realm_index", 0)), 0, p_r.size() - 1)])
	var out := {}
	for s in _active(db):
		var m: float = 1.0 + float(c.m) * float(s.get("levels", {}).get("military", 0))
		out[str(s.id)] = m * float(own.get(str(s.id), 0.0))
	for s in _greats(db):
		var levy: float = 0.0
		for v in SectEconomy.vassals(db, s):
			levy += float(c.lv) * float(c.loy_f.get(str(v.get("loyalty_state", "loyal")), 0.0)) * float(out.get(str(v.id), 0.0))
		out[str(s.id)] = float(out[str(s.id)]) + levy
	return out


# Shared border regions between two great sects' territories (F7's borders).
static func _borders(gd: GameData, db: WorldDB, a: Dictionary, b: Dictionary) -> int:
	if str(a.get("kind", "")) != "great" or str(b.get("kind", "")) != "great":
		return 0
	if _adj.is_empty() or _for_db != db.get_instance_id():
		_begin(gd, db)
	var held_a: Dictionary = _held.get(str(a.id), {})
	var held_b: Dictionary = _held.get(str(b.id), {})
	var n: int = 0
	for cid in held_a:
		for nb in _adj.get(cid, []):
			if held_b.has(int(nb)):
				n += 1
	return n


## F7's target attitude of [param a] toward [param b].
static func attitude_target(gd: GameData, db: WorldDB, a: Dictionary, b: Dictionary, strength: Dictionary) -> float:
	var c: Dictionary = _cfg(gd)
	var al: float = 0.0
	var aa: String = str(a.get("alignment", ""))
	var ba: String = str(b.get("alignment", ""))
	if aa == ba:
		al = float(c.align_same)
	elif (aa == "chinh" and ba == "ma") or (aa == "ma" and ba == "chinh"):
		al = float(c.align_opposed)
	var pact: float = float(c.p_k) if str(a.get("relation", {}).get(str(b.id), "")) == "pact" else 0.0
	var g: float = float(a.get("grudge", {}).get(str(b.id), 0.0))
	return al + float(c.b_k) * _borders(gd, db, a, b) + pact + g - _balance_of_power(db, b, strength)


# F7's bp: toward the strongest great sect only, 1 per 10 % its strength exceeds the runner-up's (worked out once a
# season by [method _season_bp]).
static func _balance_of_power(db: WorldDB, b: Dictionary, strength: Dictionary) -> float:
	if not _bp.is_empty() and _for_db == db.get_instance_id():
		return float(_bp.get(str(b.id), 0.0))
	return float(_season_bp(db, strength).get(str(b.id), 0.0))


static func _season_bp(db: WorldDB, strength: Dictionary) -> Dictionary:
	var out := {}
	var ranked: Array = _greats(db).map(func(s): return [float(strength.get(str(s.id), 0.0)), str(s.id)])
	if ranked.size() < 2:
		return out
	ranked.sort_custom(func(x, y): return x[0] > y[0])
	if float(ranked[1][0]) > 0.0:
		out[str(ranked[0][1])] = floorf((float(ranked[0][0]) / float(ranked[1][0]) - 1.0) / 0.10)
	return out


## F7's step from [param a_now] toward [param tgt].
static func attitude_step(gd: GameData, a_now: float, tgt: float) -> float:
	var d: float = tgt - a_now
	if absf(d) < 1e-9:
		return a_now
	var k: float = float(_cfg(gd).k_a) * absf(d)
	var stp: float = minf(5.0, minf(absf(d), maxf(1.0, float(roundi(k)) if k >= 0.0 else 1.0)))
	return a_now + signf(d) * stp


## One season of politics (States' steps 3, 5 and 6). Returns the ids of events logged.
static func season(gd: GameData, db: WorldDB, money: MoneyLedger, year: int, season_i: int, game_seed: String) -> Array:
	var news: Array = []
	if not db.has_record("world", WARS):
		return news
	_begin(gd, db)
	var strength := strengths(gd, db)
	_bp = _season_bp(db, strength)
	_set_states(gd, db)
	_set_dials(gd, db, strength)
	news.append_array(_attitudes(gd, db, strength, year, season_i))
	news.append_array(_declare_wars(gd, db, strength, year, season_i))
	news.append_array(_resolve_wars(gd, db, money, strength, year, season_i, game_seed))
	news.append_array(_loyalty(gd, db, strength, year, season_i))
	news.append_array(_found_sects(gd, db, money, year, season_i, game_seed))
	return news


# Rule 30: in a great sect's territory that holds fewer minor sects than it started with, a strong loose cultivator may
# found one (a keyed chance a season): the seat is the territory's densest unclaimed place, the founder heads it and
# pays its starting treasury from their own purse (at most what they hold), and it becomes the great sect's vassal.
static func _found_sects(gd: GameData, db: WorldDB, money: MoneyLedger, year: int, season_i: int, game_seed: String) -> Array:
	var c: Dictionary = _cfg(gd)
	var news: Array = []
	for g in _greats(db):
		if SectEconomy.vassals(db, g).size() >= int(g.get("minor_start", 0)):
			continue
		var r := RandomNumberGenerator.new()
		r.seed = RngUtils.stable_hash("%s:found:%s:%d" % [game_seed, str(g.id), MapChange.abs_season(year, season_i)])
		if r.randf() >= float(c.found_chance):
			continue
		var regions := {}
		for reg in db.all("regions"):
			if str(reg.get("holder", "")) == str(g.id):
				regions[str(reg.id)] = true
		var place_region := {}
		var best_place: Dictionary = {}
		var best_d: float = -1.0
		for p in db.all("places"):
			place_region[str(p.id)] = str(p.get("region_id", ""))
			if not regions.has(str(p.get("region_id", ""))) or bool(p.get("hidden", false)) or str(p.get("sect_id", "")) != "":
				continue
			if not str(p.get("kind", "")) in ["village", "town", "peak", "gorge", "forest", "lake", "island"]:
				continue
			var dens: float = float(p.get("qi", {}).get("land_density", p.get("density", 1.0)))
			if dens > best_d:
				best_d = dens
				best_place = p
		if best_place.is_empty():
			continue
		var founder: Dictionary = {}
		for p in db.all("people"):
			if not bool(p.get("alive", false)) or bool(p.get("is_player", false)) or bool(p.get("is_beast", false)) or str(p.get("sect_id", "")) != "":
				continue
			if int(p.get("realm_index", 0)) < int(c.found_realm_min) or not regions.has(str(place_region.get(str(p.get("location_id", "")), ""))):
				continue
			if founder.is_empty() or int(p.realm_index) > int(founder.realm_index) or (int(p.realm_index) == int(founder.realm_index) and str(p.id) < str(founder.id)):
				founder = p
		if founder.is_empty():
			continue
		var names: Dictionary = gd.file("world_names")
		var taken := {}
		for s in db.all("sects"):
			taken[str(s.name)] = true
		var nm: String = ""
		for i in 20:
			nm = "%s %s" % [RngUtils.pick(r, names.sect_first), RngUtils.pick(r, names.sect_suffix)]
			if not taken.has(nm):
				break
		var lv: Dictionary = Dictionary(c.found_levels).duplicate()
		var rec := {"name": nm, "key": "founded_%d_%d_%s" % [year, season_i, str(g.id)], "kind": "minor", "alignment": str(g.get("alignment", "trung")),
			"specialty": "", "hq_place_id": str(best_place.id), "region_id": str(best_place.get("region_id", "")), "leader_id": str(founder.id),
			"members": [str(founder.id)], "status": "active", "founded_year": year, "levels": lv, "treasury": 0.0, "lord_id": str(g.id),
			"loyalty": 60.0, "loyalty_state": "loyal", "attitude": {}, "grudge": {}, "relation": {}, "truce": {}, "wars": [],
			"dials": Dictionary(gd.file("sects_members").get("default_dials", {})).duplicate()}
		var sid: String = db.add("sects", rec)
		var inv := {}
		var spend := {}
		for tr in SectEconomy.TRACKS:
			inv[tr] = SectEconomy.total_cost(gd, tr, float(lv.get(tr, 0)))
			spend[tr] = 0.0
		rec["invested"] = inv
		rec["spend"] = spend
		money.transfer("npc:%s" % founder.id, "sect:%s" % sid, float(c.found_treasury), "sect_founding")
		founder["sect_id"] = sid
		founder["sect_rank"] = str(gd.world_gen().sects.rank_ladder[-1])
		best_place["sect_id"] = sid
		best_place["holder"] = sid
		news.append(db.log_event(year, season_i, "sect_founded_new", "%s lập %s tại %s, quy phục %s." % [founder.get("name", founder.id), nm, best_place.name, g.name],
			[str(founder.id), sid, str(g.id)], [str(best_place.id)], []))
	return news


# States: Thriving (treasury >= R, no track fell lately), Strained (cannot cover next season's stipends), Collapsing
# (Strained 4 seasons in a row), else Steady.
static func _set_states(gd: GameData, db: WorldDB) -> void:
	var stip: Dictionary = db.get_record(MoneyLedger.TABLE, "m_stipends").get("by_sect", {})
	var rm: float = float(gd.file(WorldEconomy.FILE).money.reserve_mult)
	for s in _active(db):
		var cost: float = float(stip.get(str(s.id), 0.0)) + float(s.get("cash_costs", 0.0))
		var tr: float = float(s.get("treasury", 0.0))
		var fell: bool = Dictionary(s.get("track_trouble", {})).values().any(func(v): return int(v) > 0)
		var st: String = "steady"
		if tr < float(stip.get(str(s.id), 0.0)):
			s["strained_for"] = int(s.get("strained_for", 0)) + 1
			st = "collapsing" if int(s.strained_for) >= int(_cfg(gd).collapse_seasons) else "strained"
		else:
			s["strained_for"] = 0
			if tr >= rm * cost and not fell:
				st = "thriving"
		s["state"] = st


# F6: each dial moves one step toward clamp(2 + needs + pulls, 0, 4) (pulls wait for NPC Traits #42).
static func _set_dials(gd: GameData, db: WorldDB, strength: Dictionary) -> void:
	for s in _active(db):
		var dials: Dictionary = s.get("dials", {})
		var st: String = str(s.get("state", "steady"))
		var at_war: bool = not Array(s.get("wars", [])).is_empty()
		var feuds: int = Dictionary(s.get("relation", {})).values().filter(func(r): return str(r) == "feud").size()
		var need := {"tax": 0, "expansion": 0, "openness": 0, "war_readiness": 0, "recruitment": 0}
		if st == "strained" or st == "collapsing":
			need.tax += 2
			need.openness -= 1
		elif st == "thriving":
			need.tax -= 1
		if at_war:
			need.openness -= 1
			need.war_readiness += 2
			need.expansion -= 2
		need.war_readiness += feuds
		if st == "thriving" and str(s.get("kind", "")) == "great":
			for o in _greats(db):
				if str(o.id) != str(s.id) and _borders(gd, db, s, o) > 0 and float(strength.get(str(o.id), 0.0)) * 1.5 < float(strength.get(str(s.id), 0.0)):
					need.expansion += 1
					break
		for d in need:
			var tgt: int = clampi(2 + clampi(int(need[d]), -2, 2), 0, 4)
			var cur: int = int(dials.get(d, 2))
			dials[d] = cur + signi(tgt - cur)
		s["dials"] = dials


# F7: attitudes move; pacts form at A >= pact line both ways, feuds start at A <= feud line one way and end at A >=
# feud_end; a truce counts down.
static func _attitudes(gd: GameData, db: WorldDB, strength: Dictionary, year: int, season_i: int) -> Array:
	var c: Dictionary = _cfg(gd)
	var news: Array = []
	var sects := _active(db)
	for s in sects:
		for o in sects:
			var oid: String = str(o.id)
			if oid == str(s.id):
				continue
			var tgt: float = attitude_target(gd, db, s, o, strength)
			if int(s.get("truce", {}).get(oid, 0)) > 0:
				tgt = 0.0
			s.attitude[oid] = attitude_step(gd, float(s.attitude.get(oid, 0.0)), tgt)
	if season_i == 0:   # authored grudges fade toward 0 by grudge_fade a year
		for s in sects:
			for oid in s.get("grudge", {}).keys():
				var g: float = float(s.grudge[oid])
				s.grudge[oid] = minf(0.0, g + float(c.grudge_fade))
	for i in sects.size():
		for j in range(i + 1, sects.size()):
			var a: Dictionary = sects[i]
			var b: Dictionary = sects[j]
			var aid: String = str(a.id)
			var bid: String = str(b.id)
			var rel: String = str(a.relation.get(bid, "peace"))
			var ab: float = float(a.attitude.get(bid, 0.0))
			var ba: float = float(b.attitude.get(aid, 0.0))
			if rel == "truce":
				var left: int = int(a.truce.get(bid, 0)) - 1
				a.truce[bid] = left
				b.truce[aid] = left
				if left <= 0:
					_set_relation(a, b, "peace")
				continue
			if rel == "war":
				continue
			if rel == "peace" and ab >= float(c.pact_line) and ba >= float(c.pact_line):
				_set_relation(a, b, "pact")
				news.append(db.log_event(year, season_i, "sect_pact", "%s và %s kết minh ước." % [a.name, b.name], [aid, bid], [], []))
			elif rel == "pact" and (ab < float(c.pact_line) - float(c.pact_hysteresis) or ba < float(c.pact_line) - float(c.pact_hysteresis)):
				_set_relation(a, b, "peace")
			elif rel != "feud" and (ab <= float(c.feud_line) or ba <= float(c.feud_line)):
				_set_relation(a, b, "feud")
				news.append(db.log_event(year, season_i, "sect_feud", "%s và %s trở mặt thành thù." % [a.name, b.name], [aid, bid], [], []))
			elif rel == "feud" and ab >= float(c.feud_end) and ba >= float(c.feud_end):
				_set_relation(a, b, "peace")
	return news


static func _set_relation(a: Dictionary, b: Dictionary, rel: String) -> void:
	a.relation[str(b.id)] = rel
	b.relation[str(a.id)] = rel


# F7 / F18: a great sect in a feud declares war when War readiness >= 3 and its strength over the target's (with the
# target's defence-pact partners) is at least war_odds' (lowered by Expansion above 2); it names a goal by Expansion.
static func _declare_wars(gd: GameData, db: WorldDB, strength: Dictionary, year: int, season_i: int) -> Array:
	var c: Dictionary = _cfg(gd)
	var news: Array = []
	var rec: Dictionary = db.get_record("world", WARS)
	for s in _greats(db):
		if not Array(s.wars).is_empty() or int(s.dials.get("war_readiness", 2)) < int(c.war_readiness_min):
			continue
		var odds: float = maxf(float(c.war_odds_min), float(c.war_odds) - float(c.war_odds_step) * maxf(0.0, float(s.dials.get("expansion", 2)) - 2.0))
		var best: Dictionary = {}
		var best_s: float = INF
		for o in _greats(db):
			var oid: String = str(o.id)
			if str(s.relation.get(oid, "")) != "feud" or _borders(gd, db, s, o) == 0:
				continue
			var so: float = float(strength.get(oid, 0.0))
			for p in _greats(db):
				if str(p.id) != oid and str(p.id) != str(s.id) and str(o.relation.get(str(p.id), "")) == "pact":
					so += float(strength.get(str(p.id), 0.0))
			if float(strength.get(str(s.id), 0.0)) / maxf(so, 1e-9) >= odds and so < best_s:
				best_s = so
				best = o
		if best.is_empty():
			continue
		var goal := _goal(gd, db, s, best, strength)
		if goal.is_empty():
			continue
		var war := {"id": "war%d" % int(rec.next), "a": str(s.id), "d": str(best.id), "goal": goal, "ws": 0, "w_a": 0.0,
			"w_d": 0.0, "seasons": 0, "began": [year, season_i]}
		rec.next = int(rec.next) + 1
		rec.wars.append(war)
		s.wars.append(str(best.id))
		best.wars.append(str(s.id))
		_set_relation(s, best, "war")
		news.append(db.log_event(year, season_i, "sect_war", "%s tuyên chiến với %s, nhắm %s." % [s.name, best.name, str(goal.name)],
			[str(s.id), str(best.id)], [], [], {"war": war.id, "goal": goal}))
	return news


# F18: the goal by Expansion: a border site (0-1), a border vassal (2-3, else a site), a border region (4, its seat
# region only under F9's protection rule; else a vassal or a site). {kind, id, name, threshold} or {}.
static func _goal(gd: GameData, db: WorldDB, a: Dictionary, d: Dictionary, strength: Dictionary) -> Dictionary:
	var c: Dictionary = _cfg(gd)
	var exp_d: int = int(a.dials.get("expansion", 2))
	var border := _border_regions(gd, db, a, d)
	if exp_d >= 4 and not border.is_empty():
		var seat_rid: String = str(d.get("region_id", ""))
		for rid in border:
			if rid != seat_rid or float(strength.get(str(d.id), 0.0)) < 0.5 * float(d.get("s0", 0.0)):
				return {"kind": "region", "id": rid, "name": str(db.get_record("regions", rid).name), "threshold": int(c.goal_thresholds.region)}
	if exp_d >= 2:
		for v in SectEconomy.vassals(db, d):
			if border.has(str(v.get("region_id", ""))):
				return {"kind": "vassal", "id": str(v.id), "name": str(v.name), "threshold": int(c.goal_thresholds.vassal)}
	var best: Dictionary = {}
	var best_v: float = -1.0
	var unit: Dictionary = gd.file(MapProduction.DATA_FILE).unit_value
	for p in db.all("places"):
		if not border.has(str(p.get("region_id", ""))) or str(p.get("holder", "")) != str(d.id) or not p.has("site"):
			continue
		var v: float = float(p.site.get("last_output", 0.0)) * float(unit.get(str(p.site.get("resource", "")), 1))
		if v > best_v:
			best_v = v
			best = p
	if best.is_empty():
		return {}
	return {"kind": "site", "id": str(best.id), "name": str(best.name), "threshold": int(c.goal_thresholds.site)}


# The defender's regions that border the attacker's territory.
static func _border_regions(gd: GameData, db: WorldDB, a: Dictionary, d: Dictionary) -> Array:
	if _adj.is_empty() or _for_db != db.get_instance_id():
		_begin(gd, db)
	var held_a: Dictionary = _held.get(str(a.id), {})
	var out: Array = []
	for r in db.all("regions"):
		if str(r.get("holder", "")) != str(d.id):
			continue
		for nb in _adj.get(int(r.continent_id), []):
			if held_a.has(int(nb)):
				out.append(str(r.id))
				break
	out.sort()
	return out


# F9: each war resolves a season: the score moves on strength and fortune, both sides lose members and weariness
# grows, the war costs half the stipends (to the commons), the goal falls at its threshold, the attack fails at the
# mirror threshold, and weariness ends it in a truce or a concession.
static func _resolve_wars(gd: GameData, db: WorldDB, money: MoneyLedger, strength: Dictionary, year: int, season_i: int, game_seed: String) -> Array:
	var c: Dictionary = _cfg(gd)
	var news: Array = []
	var rec: Dictionary = db.get_record("world", WARS)
	var stip: Dictionary = db.get_record(MoneyLedger.TABLE, "m_stipends").get("by_sect", {})
	var still: Array = []
	_fallen = {}
	var members: Dictionary = _members_by_sect(db) if not rec.wars.is_empty() else {}
	for w in rec.wars:
		var a: Dictionary = db.get_record("sects", str(w.a))
		var d: Dictionary = db.get_record("sects", str(w.d))
		if a.is_empty() or d.is_empty() or str(a.get("status", "")) != "active" or str(d.get("status", "")) != "active":
			_end_war(db, w, a, d, "peace", 0)
			continue
		var r := RandomNumberGenerator.new()
		r.seed = RngUtils.stable_hash("%s:war:%s:%d" % [game_seed, str(w.id), MapChange.abs_season(year, season_i)])
		var ea: float = r.randf_range(float(c.fortune[0]), float(c.fortune[1]))
		var ed: float = r.randf_range(float(c.fortune[0]), float(c.fortune[1]))
		var sa: float = float(strength.get(str(a.id), 0.0))
		var sd: float = float(strength.get(str(d.id), 0.0))
		var def_mult: float = float(c.def_seat) if _defends_seat(db, w, d) else 1.0
		var ta: float = sa * ea
		var td: float = sd * def_mult * ed
		var dws: int = roundi(20.0 * (ta - td) / maxf(ta + td, 1e-9))
		w.ws = int(w.ws) + dws
		w.seasons = int(w.seasons) + 1
		var la: float = float(c.loss_k) * sd / maxf(sa + sd, 1e-9)
		var ld: float = float(c.loss_k) * sa / maxf(sa + sd, 1e-9)
		news.append_array(_war_losses(gd, db, money, a, la, year, season_i, members.get(str(a.id), [])))
		news.append_array(_war_losses(gd, db, money, d, ld, year, season_i, members.get(str(d.id), [])))
		w.w_a = float(w.w_a) + 1.0 + 50.0 * la + maxf(0.0, -dws) / 2.0
		w.w_d = float(w.w_d) + 1.0 + 50.0 * ld + maxf(0.0, dws) / 2.0
		for s in [a, d]:   # war cost: half the stipends, paid to the market's commons (suppliers and hired hands)
			var ms: String = str(s.id) if str(s.get("kind", "")) == "great" else str(s.get("lord_id", ""))
			money.transfer("sect:%s" % s.id, "pool:%s" % ms, float(c.war_cost) * float(stip.get(str(s.id), 0.0)), "war_cost")
			if int(w.seasons) % int(c.military_drop_every) == 0:
				_drop_level(gd, s, "military")
		var thr: int = int(w.goal.threshold)
		var limit: float = float(c.weariness_limit)
		var end := ""
		if int(w.ws) >= thr:
			end = "won"
		elif int(w.ws) <= -thr:
			end = "failed"
		elif int(w.ws) > 0 and float(w.w_a) >= limit:
			end = "truce"
		elif int(w.ws) < 0 and float(w.w_d) >= limit:
			end = "truce"
		elif int(w.ws) > 0 and float(w.w_d) >= limit and absi(int(w.ws)) * 2 >= thr:
			end = "won"
		elif int(w.ws) < 0 and float(w.w_a) >= limit and absi(int(w.ws)) * 2 >= thr:
			end = "failed"
		if end == "":
			still.append(w)
			continue
		news.append_array(_conclude(gd, db, money, w, a, d, end, year, season_i))
	rec.wars = still
	_drop_fallen_items(db)
	return news


static func _defends_seat(db: WorldDB, w: Dictionary, d: Dictionary) -> bool:
	return str(w.goal.kind) == "region" and str(w.goal.id) == str(d.get("region_id", ""))


# F9's losses: a share of the members, lowest realm first (the cast is spared); the dead's purses go to the sect's
# treasury and their few items are left Lost on the field (a war death names no heir: Inheritance's search over every
# person was too slow for a season of battles), and the record says why. [param members] are the sect's living members,
# sorted lowest realm first, built once a season.
static func _war_losses(gd: GameData, db: WorldDB, money: MoneyLedger, s: Dictionary, share: float, year: int, season_i: int, members: Array = []) -> Array:
	var alive: Array = members.filter(func(p): return bool(p.get("alive", false)))
	var n: int = int(floor(share * alive.size()))
	for i in mini(n, alive.size()):
		var p: Dictionary = alive[i]
		WorldMoney.settle_death(gd, db, money, p, "")
		p["alive"] = false
		p["death_cause"] = "Tử trận"
		p["death_year"] = year
		p["equipped"] = []
		p["equip_slots"] = {}
		_fallen[str(p.id)] = str(p.get("location_id", ""))
	return []


# The season's war dead {person id: place}: their items are left Lost where they fell, in one pass over the items.
static var _fallen: Dictionary = {}


static func _drop_fallen_items(db: WorldDB) -> void:
	if _fallen.is_empty():
		return
	for item in db.all("items"):
		var o: String = str(item.get("owner_id", ""))
		if _fallen.has(o):
			item["owner_id"] = _fallen[o]
			item["lost"] = true
	_fallen = {}


# Each sect's living members (not the player, beasts or the cast), lowest realm first, for the season's war losses.
static func _members_by_sect(db: WorldDB) -> Dictionary:
	var out := {}
	for p in db.all("people"):
		if not bool(p.get("alive", false)) or bool(p.get("is_player", false)) or bool(p.get("is_beast", false)) or p.has("cast_key"):
			continue
		var sid: String = str(p.get("sect_id", ""))
		if sid == "":
			continue
		if not out.has(sid):
			out[sid] = []
		out[sid].append(p)
	for sid in out:
		out[sid].sort_custom(func(x, y): return int(x.get("realm_index", 0)) < int(y.get("realm_index", 0)) or (int(x.get("realm_index", 0)) == int(y.get("realm_index", 0)) and str(x.id) < str(y.id)))
	return out


static func _drop_level(gd: GameData, s: Dictionary, track: String) -> void:
	if not s.has("invested"):
		return
	var lv: int = int(floor(SectEconomy.level_of(gd, track, float(s.invested.get(track, 0.0))) + 1e-9))
	s.invested[track] = SectEconomy.total_cost(gd, track, maxi(0, lv - 1))
	SectEconomy._refresh_levels(gd, s)


# The end of a war: the goal moves on a win (the map follows), a failed attack costs the attacker a Military level and
# the defender's goodwill; every end is an 8-season truce.
static func _conclude(gd: GameData, db: WorldDB, money: MoneyLedger, w: Dictionary, a: Dictionary, d: Dictionary, end: String, year: int, season_i: int) -> Array:
	var c: Dictionary = _cfg(gd)
	var news: Array = []
	if end == "won":
		match str(w.goal.kind):
			"site":
				MapChange.transfer(db, str(w.goal.id), str(a.id), year, season_i, "chiến thắng")
				var p: Dictionary = db.get_record("places", str(w.goal.id))
				if p.has("site"):
					p.site["spoils"] = int(c.spoils_seasons)
			"region":
				MapChange.transfer(db, str(w.goal.id), str(a.id), year, season_i, "chiến thắng")
				_begin(gd, db)
				news.append_array(_check_fall(gd, db, money, d, a, year, season_i))
			"vassal":
				var v: Dictionary = db.get_record("sects", str(w.goal.id))
				if not v.is_empty():
					v["lord_id"] = str(a.id)
					v["loyalty"] = float(c.new_lord_loyalty)
					v["loyalty_state"] = loyalty_state(gd, float(v.loyalty))
			"rebellion":   # the rebel wins its freedom: it takes the backer (or the bordering great sect that likes it best) as lord
				var nl: String = str(w.get("backer", ""))
				if nl == "":
					var best: float = -INF
					for b in _greats(db):
						if str(b.id) != str(d.id) and float(b.attitude.get(str(a.id), 0.0)) > best:
							best = float(b.attitude.get(str(a.id), 0.0))
							nl = str(b.id)
				a["lord_id"] = nl
				a["loyalty"] = float(c.new_lord_loyalty)
				a["loyalty_state"] = loyalty_state(gd, float(a.loyalty))
		news.append(db.log_event(year, season_i, "sect_war_won", "%s thắng %s, đoạt %s." % [a.name, d.name, str(w.goal.name)], [str(a.id), str(d.id)], [], [], {"war": w.id}))
	elif end == "failed" and str(w.goal.kind) == "rebellion":   # the lord wins: the rebel returns Restless
		a["loyalty"] = float(c.rebel_loyalty_after)
		a["loyalty_state"] = loyalty_state(gd, float(a.loyalty))
		news.append(db.log_event(year, season_i, "rebellion_crushed", "%s dẹp yên cuộc nổi dậy của %s." % [d.name, a.name], [str(a.id), str(d.id)], [], [], {"war": w.id}))
	elif end == "failed":
		_drop_level(gd, a, "military")
		d.attitude[str(a.id)] = float(d.attitude.get(str(a.id), 0.0)) - float(c.failed_attitude)
		news.append(db.log_event(year, season_i, "sect_war_failed", "%s đánh %s không thành." % [a.name, d.name], [str(a.id), str(d.id)], [], [], {"war": w.id}))
	else:
		news.append(db.log_event(year, season_i, "sect_truce", "%s và %s đình chiến." % [a.name, d.name], [str(a.id), str(d.id)], [], [], {"war": w.id}))
	_end_war(db, w, a, d, "truce", int(c.truce_seasons))
	return news


static func _end_war(_db: WorldDB, w: Dictionary, a: Dictionary, d: Dictionary, rel: String, truce: int) -> void:
	if a.is_empty() or d.is_empty():
		return
	a.wars.erase(str(d.id))
	d.wars.erase(str(a.id))
	_set_relation(a, d, rel)
	a.truce[str(d.id)] = truce
	d.truce[str(a.id)] = truce


# Rule 17: a great sect with no region left falls: half its treasury to the victor, the rest to the lost stash, its
# vassals to the victor.
static func _check_fall(gd: GameData, db: WorldDB, money: MoneyLedger, d: Dictionary, victor: Dictionary, year: int, season_i: int) -> Array:
	if db.find("regions", func(r): return str(r.get("holder", "")) == str(d.id)).size() > 0:
		return []
	money.transfer("sect:%s" % d.id, "sect:%s" % victor.id, 0.5 * money.balance("sect:%s" % d.id), "spoils")
	money.transfer("sect:%s" % d.id, "stash:%s" % victor.id, money.balance("sect:%s" % d.id), "spoils")
	for v in SectEconomy.vassals(db, d):
		v["lord_id"] = str(victor.id)
	d["status"] = "fallen"
	return [db.log_event(year, season_i, "sect_fallen", "%s diệt vong." % d.name, [str(d.id), str(victor.id)], [], [])]


# F5 and F5b: vassals' loyalty moves; a Defiant vassal seeks a new lord or pays late (a rebellion waits for its war
# rules: Open Question in the plan).
static func _loyalty(gd: GameData, db: WorldDB, strength: Dictionary, year: int, season_i: int) -> Array:
	var c: Dictionary = _cfg(gd)
	var news: Array = []
	for v in _active(db).filter(func(s): return str(s.get("kind", "")) == "minor"):
		var lord: Dictionary = db.get_record("sects", str(v.get("lord_id", "")))
		if lord.is_empty() or str(lord.get("status", "")) != "active":
			continue
		var tax: int = int(lord.get("dials", {}).get("tax", 2))
		var threat: float = 0.0
		for o in _greats(db):
			if str(o.id) != str(lord.id):
				threat = maxf(threat, float(strength.get(str(o.id), 0.0)))
		var prot: float = clampf(log(maxf(float(strength.get(str(lord.id), 0.0)), 1e-9) / maxf(threat, 1e-9)) / log(2.0), -1.0, 1.0)
		var loy: float = float(v.get("loyalty", 60.0))
		loy += float(c.k_tax) * (2 - tax) + float(c.k_prot) * prot + float(c.k_rest) * (60.0 - loy)
		if not Array(lord.get("wars", [])).is_empty() and str(v.get("loyalty_state", "")) == "defiant":
			loy -= float(c.k_refuse)   # rule 5: a Defiant vassal refuses its lord's levy
		v["loyalty"] = clampf(loy, 0.0, 100.0)
		v["loyalty_state"] = loyalty_state(gd, float(v.loyalty))
		if str(v.loyalty_state) != "defiant" or Array(v.get("wars", [])).has(str(lord.id)):
			continue
		for b in _greats(db):   # F5b check 1: a bordering great sect that likes the vassal and not its lord
			if str(b.id) == str(lord.id):
				continue
			if float(b.attitude.get(str(v.id), 0.0)) >= float(c.seek_attitude) and float(b.attitude.get(str(lord.id), 0.0)) <= 0.0:
				v["lord_id"] = str(b.id)
				v["loyalty"] = float(c.new_lord_loyalty)
				v["loyalty_state"] = loyalty_state(gd, float(v.loyalty))
				lord.attitude[str(b.id)] = float(lord.attitude.get(str(b.id), 0.0)) - float(c.seek_lord_attitude)
				news.append(db.log_event(year, season_i, "vassal_new_lord", "%s bỏ %s, quy phục %s." % [v.name, lord.name, b.name], [str(v.id), str(lord.id), str(b.id)], [], []))
				break
		if str(v.get("lord_id", "")) != str(lord.id):
			continue
		news.append_array(_maybe_rebel(gd, db, v, lord, strength, year, season_i))
	return news


# F5b check 2: a Defiant vassal rebels when its strength with a backer's, over the lord's strength spread over its wars
# (the rebellion counted), reaches rebel_odds; the rebellion is a war of the vassal on its lord for its freedom.
static func _maybe_rebel(gd: GameData, db: WorldDB, v: Dictionary, lord: Dictionary, strength: Dictionary, year: int, season_i: int) -> Array:
	var c: Dictionary = _cfg(gd)
	var backer: Dictionary = {}
	var s_b: float = 0.0
	for b in _greats(db):
		if str(b.id) == str(lord.id):
			continue
		if float(b.attitude.get(str(v.id), 0.0)) >= float(c.backer_attitude) and float(b.attitude.get(str(lord.id), 0.0)) <= -float(c.backer_attitude):
			if float(strength.get(str(b.id), 0.0)) > s_b:
				s_b = float(strength.get(str(b.id), 0.0))
				backer = b
	var spare: float = float(strength.get(str(lord.id), 0.0)) / float(Array(lord.get("wars", [])).size() + 1)
	if (float(strength.get(str(v.id), 0.0)) + s_b) / maxf(spare, 1e-9) < float(c.rebel_odds):
		return []
	var rec: Dictionary = db.get_record("world", WARS)
	var war := {"id": "war%d" % int(rec.next), "a": str(v.id), "d": str(lord.id), "backer": str(backer.get("id", "")),
		"goal": {"kind": "rebellion", "id": str(v.id), "name": str(v.name), "threshold": int(c.goal_thresholds.vassal)},
		"ws": 0, "w_a": 0.0, "w_d": 0.0, "seasons": 0, "began": [year, season_i]}
	rec.next = int(rec.next) + 1
	rec.wars.append(war)
	v.wars.append(str(lord.id))
	lord.wars.append(str(v.id))
	v["loyalty_state"] = "rebelling"
	_set_relation(v, lord, "war")
	return [db.log_event(year, season_i, "vassal_rebellion", "%s nổi dậy chống %s." % [v.name, lord.name], [str(v.id), str(lord.id)], [], [], {"war": war.id})]
