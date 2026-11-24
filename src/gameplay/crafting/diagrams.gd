class_name Diagrams
extends RefCounted
## Formations Part I: combat formation diagrams (trận đồ; design/gdd/formations.md rules 1-12, Formulas F1-F4, F6).
## A diagram replaces Combat's plain row of art slots: N nodes, each an art slot with a polarity (+ positive,
## - negative, ? conditioned) and one rule, and links (adjacency, or a directed feed that takes seconds off a cooling
## target's timer). Data: crafting_diagrams.json (constants; the catalogue is the user's to author, empty until then).
##
## A diagram record: {id, grade (0-4), nodes: [{polarity, rule, node_score}], links: [{kind: "feed", from, to,
## seconds} | {kind: "adj", a, b}], reserve_share, realm_min, skill_min, source ("taught" | "crafted")}. Node and link
## indices are 1-based. A node rule: {type: "mod", key: art_speed_pct | art_cost_pct | damage_pct, value, scope:
## [tags]}, {type: "gate", cond: {read, op, value}} (Combat's guard vocabulary), or {type: "adj_mod", key, value, tag}
## (+value while a linked node's art carries the tag).
##
## Usage:
## [codeblock]
## var s: float = Diagrams.strength(gd, 2, 3, 20.0)                  # F1: 2.44
## var lay: int = Diagrams.fuel(gd, 5, 2, 3, 2)                       # F2: 288 at Core Formation
## var lines: Array = Diagrams.apply(gd, profile, diagram, ["a", "b"], s, 1.0)   # compiles it into the loadout
## [/codeblock]

const FILE := "crafting_diagrams"


static func cfg(gd: GameData) -> Dictionary:
	return gd.file(FILE)


## Rule 7: the effective level, min(L, min(max_level, skill + 1) + 2 with the keystone Formation Within a Formation),
## never above the diagram's own [param own_max] (rule 1, user 2026-11-24).
static func level_eff(gd: GameData, level: int, skill: int, keystone: bool = false, own_max: int = 99) -> int:
	var cap: int = mini(int(cfg(gd).strength.max_level), skill + 1) + (2 if keystone else 0)
	return maxi(1, mini(mini(level, cap), own_max))


## Formations rule 8 (taught): sects_teaching.json, which formations each fixed sect teaches, the contribution cost by
## grade, and the formation manuals' drop knobs (user 2026-11-24).
const TEACH_FILE := "sects_teaching"
const RANKS := ["ngoai_mon", "noi_mon", "truong_lao", "tong_chu"]


static func teaching(gd: GameData) -> Dictionary:
	return gd.file(TEACH_FILE)


## The formations the fixed sect [param sect_key] teaches: [{id, rank}] ([] for a generated sect or none).
static func taught_at(gd: GameData, sect_key: String) -> Array:
	return Array(teaching(gd).get("sects", {}).get(sect_key, []))


## The contribution it costs to be taught a formation of [param grade].
static func learn_cost(gd: GameData, grade: int) -> int:
	var c: Array = teaching(gd).get("cost_contribution", [60, 200, 600, 1500, 4000])
	return int(c[clampi(grade, 0, c.size() - 1)])


## Whether rank [param have] reaches rank [param need] (the sect ladder's order).
static func rank_reaches(have: String, need: String) -> bool:
	return RANKS.find(have) >= RANKS.find(need)


## A formation manual's formation for a finder of [param realm] ("" for none): any catalogue formation but the special
## ones, whose realm_min is at most realm + realm_ahead, weighted by grade (sects_teaching.json manual).
static func manual_pick(gd: GameData, rng: RandomNumberGenerator, realm: int) -> String:
	var t: Dictionary = teaching(gd)
	var m: Dictionary = t.get("manual", {})
	var special: Array = t.get("special", [])
	var w: Array = m.get("grade_weight", [1.0])
	var pool: Array = []
	var total: float = 0.0
	for d in Array(cfg(gd).get("diagrams", [])):
		if special.has(str(d.id)) or int(d.get("realm_min", 0)) > realm + int(m.get("realm_ahead", 1)) or str(d.id) == str(cfg(gd).get("starter", "")):
			continue
		var wt: float = float(w[clampi(int(d.get("grade", 0)), 0, w.size() - 1)])
		pool.append([str(d.id), wt])
		total += wt
	if pool.is_empty() or total <= 0.0:
		return ""
	var r: float = rng.randf() * total
	for p in pool:
		r -= float(p[1])
		if r <= 0.0:
			return str(p[0])
	return str(pool[-1][0])


## The catalogue record of [param id] ({} when unknown; the default line has no record).
static func record_of(gd: GameData, id: String) -> Dictionary:
	for d in Array(cfg(gd).get("diagrams", [])):
		if str(d.get("id", "")) == id:
			return d
	return {}


## Rule 7 (amended 2026-11-24): whether a node or link [param entry] is open at [param level] (its unlock, 1 default).
static func is_open(entry: Dictionary, level: int) -> bool:
	return int(entry.get("unlock", 1)) <= level


## The number of nodes of [param diagram] open at [param level] (rule 3's N).
static func open_count(diagram: Dictionary, level: int) -> int:
	return Array(diagram.get("nodes", [])).filter(func(n): return is_open(n, level)).size()


## F1: diagram strength S = clamp(grade_mult[g] × level_growth^(L−1) × (1 + formation_power_pct / 100), S_min, S_max).
static func strength(gd: GameData, grade: int, level: int, power_pct: float) -> float:
	var st: Dictionary = cfg(gd).strength
	var g: Array = st.grade_mult
	var v: float = float(g[clampi(grade, 0, g.size() - 1)]) * pow(float(st.level_growth), level - 1) * (1.0 + power_pct / 100.0)
	return clamp_s(gd, v)


## F1's clamp to [S_min, S_max].
static func clamp_s(gd: GameData, v: float) -> float:
	var st: Dictionary = cfg(gd).strength
	return clampf(v, float(st.s_min), float(st.s_max))


## F1: an authored number on a node of [param polarity] at strength [param s] and share [param share]. A negative-
## polarity node (a drawback) is scaled by the share only; positive and conditioned nodes by S and the share.
static func scaled(v: float, polarity: String, s: float, share: float) -> float:
	return v * share if polarity == "-" else v * s * share


## Rule 9 and Combat rule 12: the share by situation (FightRequest.Situation) and whether the diagram is laid.
static func share_of(gd: GameData, situation: int, laid: bool) -> float:
	var sh: Dictionary = cfg(gd).share
	if situation == FightRequest.Situation.BLIND:
		return float(sh.blind)
	if situation == FightRequest.Situation.FORESEEN and laid:
		return float(sh.laid)
	return float(sh.carried)


## F2: linh thạch to lay a diagram of [param n] nodes, grade [param grade], effective level [param level], for an
## owner of realm [param realm]: ceil(N × fuel_frac[g] × fuel_growth^(L−1) × linh_thach_max[realm] − 1e-6).
static func fuel(gd: GameData, n: int, grade: int, level: int, realm: int) -> int:
	var fu: Dictionary = cfg(gd).fuel
	var ff: Array = fu.fuel_frac
	var budget: float = float(gd.file("events_budgets").per_realm[str(gd.realm(clampi(realm, 0, gd.realms().size() - 1)).id)].linh_thach_max)
	return int(ceil(float(n) * float(ff[clampi(grade, 0, ff.size() - 1)]) * pow(float(fu.fuel_growth), level - 1) * budget - 1e-6))


## F3: linh thạch to raise a diagram of [param grade] to level [param level], cost_lt[g] × cost_growth^(L−1).
static func raise_cost(gd: GameData, grade: int, level: int) -> int:
	var c: Dictionary = cfg(gd)
	return int(round(float(c.cost_lt[clampi(grade, 0, c.cost_lt.size() - 1)]) * pow(float(c.cost_growth), level - 1)))


## F6: the share of maximum linh lực the diagram holds, reserve_share × (1 − min(efficiency, 50) / 100); never scaled.
static func reserved(diagram: Dictionary, efficiency_pct: float) -> float:
	return float(diagram.get("reserve_share", 0.0)) * (1.0 - minf(efficiency_pct, 50.0) / 100.0)


## Rules 3 and 9a: whether [param diagram] can be set with [param slot_count] art slots, beside [param other_reserved]
## (wards' effective reservations) under reserve_cap. {ok, reason}.
static func can_set(diagram: Dictionary, slot_count: int, other_reserved: float, efficiency_pct: float, reserve_cap: float, level: int = 99) -> Dictionary:
	var n: int = open_count(diagram, level)
	if n > slot_count:
		return {"ok": false, "reason": "%d nodes but %d art slots: it cannot be set" % [n, slot_count]}
	if other_reserved + reserved(diagram, efficiency_pct) > reserve_cap + 1e-9:
		return {"ok": false, "reason": "its reservation would pass the cap of %.0f %%: drop a ward" % (reserve_cap * 100.0)}
	return {"ok": true, "reason": ""}


# --- F4: NPC fit and placement ----------------------------------------------------------------------------------

## F4's m(art, n): 1 if the art's tags meet the node's scope (or the node has none).
static func _matches(node: Dictionary, tags: Array) -> bool:
	var scope: Array = node.get("rule", {}).get("scope", [])
	if scope.is_empty():
		return true
	for t in scope:
		if not tags.has(str(t)):
			return false
	return true


## F4: places arts [param arts] ([{id, tags}], pool order) in [param diagram]'s nodes greedily (nodes by descending
## |node_score|, ties by index; each takes the unplaced art with the highest node_score × m, ties by pool order).
## Returns {fit, placement: [art id or "" per node]}.
static func place(diagram: Dictionary, arts: Array, level: int = 99) -> Dictionary:
	var nodes: Array = diagram.get("nodes", [])
	var order: Array = range(nodes.size()).filter(func(i): return is_open(nodes[i], level))   # closed nodes stay empty
	order.sort_custom(func(x, y):
		var ax: float = absf(float(nodes[x].get("node_score", 0.0)))
		var ay: float = absf(float(nodes[y].get("node_score", 0.0)))
		return ax > ay or (ax == ay and x < y))
	var placement: Array = []
	placement.resize(nodes.size())
	placement.fill("")
	var used := {}
	var fit: float = 0.0
	for ni in order:
		var best: int = -1
		var best_v: float = -INF
		for ai in arts.size():
			if used.has(ai):
				continue
			var v: float = float(nodes[ni].get("node_score", 0.0)) * (1.0 if _matches(nodes[ni], Array(arts[ai].get("tags", []))) else 0.0)
			if v > best_v:
				best_v = v
				best = ai
		if best >= 0 and best_v > 0.0:   # an art goes only where it gains: a node whose scope no art meets stays empty,
			used[best] = true            # and a drawback node is never filled by fit (2026-11-24: the starter's one art
			placement[ni] = str(arts[best].id)   # sat inert in a heavy-arts node)
			fit += best_v
	return {"fit": fit, "placement": placement}


## Rule 12 and F4: the diagram an NPC takes from [param allowed] for its arts: the highest fit, ties to fewer nodes
## then the lower id; none (the default line) when the best fit is at or below fit_min. {diagram, placement, fit}.
static func choose(gd: GameData, allowed: Array, arts: Array) -> Dictionary:
	var best := {}
	for d in allowed:
		var r: Dictionary = place(d, arts, 1)   # an NPC's diagram is at level 1
		var better: bool = best.is_empty() or float(r.fit) > float(best.fit) + 1e-9
		if not better and absf(float(r.fit) - float(best.fit)) <= 1e-9:
			var nd: int = Array(d.nodes).size()
			var nb: int = Array(best.diagram.nodes).size()
			better = nd < nb or (nd == nb and str(d.id) < str(best.diagram.id))
		if better:
			best = {"diagram": d, "placement": r.placement, "fit": float(r.fit)}
	if best.is_empty() or float(best.fit) <= float(cfg(gd).fit_min):
		return {"diagram": {}, "placement": [], "fit": 0.0}
	return best


# --- Compiling into the loadout (Combat owns the fight; Formations owns the record) ------------------------------

## Compiles [param diagram] into [param p] (a compiled FighterProfile): the arts named in [param placement] go to the
## diagram's nodes in node order, the rest follow as plain slots in their order (rules 3-4); each node's rule is set
## on a copy of its art (Modifier nodes as per-art numbers, gate nodes as guards), scaled by F1 ([param s], [param
## share]); feeds become the profile's feed list; the reservation is added (rule 9a). Empty nodes are inert. Returns
## the Breakdown lines (rule 11).
static func apply(gd: GameData, p: FighterProfile, diagram: Dictionary, placement: Array, s: float, share: float, efficiency_pct: float = 0.0, level: int = 99) -> Array:
	var lines: Array = []
	if diagram.is_empty():
		return lines
	var nodes: Array = diagram.get("nodes", [])
	var by_id := {}
	for a in p.arts:
		by_id[str(a.id)] = a
	var node_art: Array = []   # node index -> ArtDef copy or null
	var placed := {}
	for ni in nodes.size():
		var aid: String = str(placement[ni]) if ni < placement.size() else ""
		if not is_open(nodes[ni], level):
			aid = ""   # a closed node holds no art (rule 7)
		if aid != "" and by_id.has(aid) and not placed.has(aid):
			placed[aid] = true
			node_art.append(_copy(by_id[aid]))
		else:
			node_art.append(null)
	var tags_of := func(i: int) -> Array: return [] if node_art[i] == null else Array(node_art[i].tags_s)
	var adj := {}
	for l in diagram.get("links", []):
		if str(l.kind) == "adj" and is_open(l, level):
			for pair in [[int(l.a) - 1, int(l.b) - 1], [int(l.b) - 1, int(l.a) - 1]]:
				if not adj.has(pair[0]):
					adj[pair[0]] = []
				adj[pair[0]].append(pair[1])
	for ni in nodes.size():
		var art: ArtDef = node_art[ni]
		if art == null:
			continue   # an empty node does nothing (Edge Cases)
		var node: Dictionary = nodes[ni]
		var rule: Dictionary = node.get("rule", {})
		var pol: String = str(node.get("polarity", "+"))
		match str(rule.get("type", "")):
			"mod":
				if _matches(node, Array(art.tags_s)):
					var v: float = scaled(float(rule.value), pol, s, share)
					_set_mod(art, str(rule.key), v, float(cfg(gd).node_cost_min_pct))
					lines.append("node %d (%s %s): %s %+.1f%% on %s" % [ni + 1, pol, str(rule.key), str(rule.key), v, art.id])
			"adj_mod":
				var hit: bool = false
				for o in adj.get(ni, []):
					if Array(tags_of.call(o)).has(str(rule.tag)):
						hit = true
				if hit:
					var v2: float = scaled(float(rule.value), pol, s, share)
					_set_mod(art, str(rule.key), v2, float(cfg(gd).node_cost_min_pct))
					lines.append("node %d (%s, beside %s): %s %+.1f%% on %s" % [ni + 1, pol, str(rule.tag), str(rule.key), v2, art.id])
			"gate":
				var ec := EffectCompiler.new(CombatConstants.from_game_data(gd))
				var g: Array[EffectDef.CondDef] = ec.compile_conds([rule.cond], "diagram %s node %d" % [diagram.get("id", ""), ni + 1], {})
				var guards: Array[EffectDef.CondDef] = art.guards.duplicate()
				guards.append_array(g)
				art.guards = guards
				lines.append("node %d (gate): %s fires only while %s %s %s" % [ni + 1, art.id, rule.cond.read, rule.cond.op, str(rule.cond.value)])
	# the new art order: the nodes' arts, then the plain slots in the player's order
	var arts: Array[ArtDef] = []
	var node_slot := {}   # node index -> slot index in the new order
	for ni in nodes.size():
		if node_art[ni] != null:
			node_slot[ni] = arts.size()
			arts.append(node_art[ni])
	for a in p.arts:
		if not placed.has(str(a.id)):
			arts.append(a)
	p.arts = arts
	var feeds: Array = []
	for l in diagram.get("links", []):
		if str(l.kind) != "feed" or not is_open(l, level):
			continue
		var fi: int = int(l.from) - 1
		var ti: int = int(l.to) - 1
		if not node_slot.has(fi) or not node_slot.has(ti):
			continue   # an empty node feeds nothing and is fed nothing
		var secs: float = scaled(float(l.seconds), "+", s, share)
		feeds.append([int(node_slot[fi]), int(node_slot[ti]), CombatConstants.ms(secs)])
		lines.append("feed %d -> %d: %.2f s" % [fi + 1, ti + 1, secs])
	p.feeds = feeds
	var res: float = reserved(diagram, efficiency_pct)
	if res > 0.0:
		p.reserved += res
		lines.append("reserved %.1f%% of linh lực" % (res * 100.0))
	lines.append("diagram %s: S %.2f, share %.0f%%" % [diagram.get("id", ""), s, share * 100.0])
	return lines


static func _set_mod(art: ArtDef, key: String, v: float, cost_min_pct: float = -50.0) -> void:
	match key:
		"art_speed_pct":
			art.node_speed_pct += v
		"art_cost_pct":   # F1's bounds: art_cost_pct's reduction stays within its Modifier System bound
			art.node_cost_pct = maxf(cost_min_pct, art.node_cost_pct + v)
		"damage_pct":
			art.m_mult *= 1.0 + v / 100.0


static func _copy(a: ArtDef) -> ArtDef:
	var b := ArtDef.new()
	for prop in a.get_property_list():
		var nm: String = str(prop.name)
		if (int(prop.usage) & PROPERTY_USAGE_SCRIPT_VARIABLE) != 0:
			b.set(nm, a.get(nm))
	return b


## Rules 3, 7-12: compiles [param c]'s diagram into fighter [param p] for a fight in [param situation]: the Set one
## (rule 2: the default line when none, or when it cannot be set), or for an NPC with none set the best fit from the
## catalogue its realm and Trận Pháp skill allow (rule 12; the catalogue is empty until the user authors it). Lays it
## when it can and the Set diagram's `lay` preference allows (rule 9; on unless the player turned it off). With
## [param pending] (an Array) the fuel is not burnt here: [c, fuel] is appended for the caller to pay with
## [method pay_fuel] once the fight has run (a refused fight burns nothing). Returns the Breakdown lines.
static func compile_for(gd: GameData, db: WorldDB, c: Character, p: FighterProfile, sheet: StatSheet, situation: int, slot_count: int, pending: Variant = null) -> Array:
	return Array(compile_for_info(gd, db, c, p, sheet, situation, slot_count, pending).lines)


## [method compile_for], telling what it did: {lines, applied (the diagram is in the loadout), laid, share, fuel, id}, so
## a screen shows the formation the fight really used (carried when the fuel was short, the default line when it
## could not be set).
static func compile_for_info(gd: GameData, db: WorldDB, c: Character, p: FighterProfile, sheet: StatSheet, situation: int, slot_count: int, pending: Variant = null) -> Dictionary:
	var info := {"lines": [], "applied": false, "laid": false, "share": 1.0, "fuel": 0, "id": ""}
	if p == null:
		return info
	var set: Dictionary = c.diagram
	var record: Dictionary = set.get("record", {})
	if record.is_empty() and str(set.get("id", "")) != "":
		record = record_of(gd, str(set.id))   # the Set diagram by id (rule 8; the catalogue's current record)
	var placement: Array = set.get("placement", [])
	var level: int = int(set.get("level", 1))
	var skill: int = c.skill_level("tran_phap")
	var npc: bool = str(c.id) != "" and not bool(db.get_record("people", c.id).get("is_player", false))
	if record.is_empty() and npc and bool(cfg(gd).get("npc_use", false)):   # user 2026-11-24: NPCs on the default line for now
		var allowed: Array = Array(cfg(gd).get("diagrams", [])).filter(func(d): return int(d.get("realm_min", 0)) <= c.realm_index and int(d.get("skill_min", 0)) <= skill)
		var pick: Dictionary = choose(gd, allowed, p.arts.map(func(a): return {"id": str(a.id), "tags": Array(a.tags_s)}))
		record = pick.diagram
		placement = pick.placement
		level = 1
	if record.is_empty():
		return info
	if slot_count < 0:   # Combat Formulas A2: slots_by_realm + bonus_slots
		var sl: Array = gd.file("combat_library").get("constants", {}).get("slots_by_realm", [3, 4, 5, 6, 7])
		slot_count = int(sl[clampi(c.realm_index, 0, sl.size() - 1)]) + (int(sheet.total("bonus_slots")) if sheet != null else 0)
	var eff: float = sheet.total("reserve_eff_pct") if sheet != null else 0.0
	var k: CombatConstants = CombatConstants.from_game_data(gd)
	var l_eff: int = level_eff(gd, level, skill, c.has_capability(15), int(record.get("max_level", 99)))
	var ok: Dictionary = can_set(record, slot_count, p.reserved, eff, k.reserve_cap, l_eff)
	if not bool(ok.ok):
		info.lines = ["diagram %s not set (%s): the default line" % [record.get("id", ""), ok.reason]]
		return info
	var prep: Dictionary = prepare(gd, db, c, record, l_eff, situation, bool(set.get("lay", true)), pending == null)
	if bool(prep.laid) and pending is Array:
		pending.append([c, int(prep.fuel)])
	var s: float = strength(gd, int(record.get("grade", 0)), l_eff, sheet.total("formation_power_pct") if sheet != null else 0.0)
	var lines: Array = apply(gd, p, record, placement, s, float(prep.share), eff, l_eff)
	if bool(prep.laid):
		lines.append("laid: %d linh thạch burnt" % int(prep.fuel))
	return {"lines": lines, "applied": true, "laid": bool(prep.laid), "share": float(prep.share), "fuel": int(prep.fuel), "id": str(record.get("id", ""))}


## A node rule in the player's words (the editor, the fight screen, tooltips): "+12% art speed (quick arts)",
## "+10% damage beside sword arts", "holds until your health <= 50%". [param s] scales a benefit's number (F1).
static func rule_words(rule: Dictionary, polarity: String = "+", s: float = 1.0) -> String:
	var key_words := {"damage_pct": "damage", "art_speed_pct": "art speed", "art_cost_pct": "art cost"}
	match str(rule.get("type", "")):
		"mod":
			var v: float = scaled(float(rule.value), polarity, s, 1.0)
			var sc: Array = Array(rule.get("scope", []))
			return "%+.0f%% %s%s" % [v, key_words.get(str(rule.key), str(rule.key)), (" (%s arts)" % ", ".join(sc)) if not sc.is_empty() else ""]
		"adj_mod":
			return "%+.0f%% %s beside %s arts" % [scaled(float(rule.value), polarity, s, 1.0), key_words.get(str(rule.key), str(rule.key)), str(rule.tag)]
		"gate":
			var c: Dictionary = rule.cond
			var read: String = str(c.read)
			var who: String = "your" if read.begins_with("own.") else ("the foe's" if read.begins_with("foe.") else "")
			var what: String = read.get_slice(".", 1) if read.contains(".") and not read.begins_with("cycle.") else read
			var names := {"hp_share": "health", "hp_missing_share": "health lost", "qi_share": "linh lực", "curses": "curses",
				"distinct_statuses": "statuses", "body_shield_share": "body shield", "since_hit": "seconds since you were hit",
				"buff_elements": "elemental buffs", "time": "the fight's time"}
			var val: float = float(c.value)
			var shown: String = ("%.0f%%" % (val * 100.0)) if what.ends_with("_share") else ("%gs" % val if what == "time" else "%g" % val)
			if read.begins_with("cycle."):
				return "fires only on pulse %d of every %s" % [int(val), read.get_slice(".", 1)]
			return "holds until %s %s %s %s" % [who, names.get(what, what), str(c.op), shown]
	return ""


## A read path's diagram (the character sheet, a practice fight, an event card's odds): compiles [param c]'s Set
## diagram into [param p] for a foreseen fight, laid by its preference, burning nothing. Returns the Breakdown lines.
static func compile_read(gd: GameData, db: WorldDB, c: Character, p: FighterProfile, sheet: StatSheet) -> Array:
	return compile_for(gd, db, c, p, sheet, FightRequest.Situation.FORESEEN, -1, [])


## [method compile_read] with what it did ([method compile_for_info]).
static func compile_read_info(gd: GameData, db: WorldDB, c: Character, p: FighterProfile, sheet: StatSheet) -> Dictionary:
	return compile_for_info(gd, db, c, p, sheet, FightRequest.Situation.FORESEEN, -1, [])


## Power Rankings (the build includes the diagram, 2026-11-24): [param c]'s Set diagram resolved for a rating panel's
## build file, so a worker process applies it too ([method apply_payload]); a panel is a foreseen fight, laid by the
## lay preference, and burns nothing. {} when none is set (NPCs while npc_use is false).
static func panel_payload(gd: GameData, c: Character, sheet: StatSheet) -> Dictionary:
	var set: Dictionary = c.diagram
	var record: Dictionary = set.get("record", {})
	if record.is_empty() and str(set.get("id", "")) != "":
		record = record_of(gd, str(set.id))
	if record.is_empty():
		return {}
	var l_eff: int = level_eff(gd, int(set.get("level", 1)), c.skill_level("tran_phap"), c.has_capability(15), int(record.get("max_level", 99)))
	var sl: Array = gd.file("combat_library").get("constants", {}).get("slots_by_realm", [3, 4, 5, 6, 7])
	var slots: int = int(sl[clampi(c.realm_index, 0, sl.size() - 1)]) + (int(sheet.total("bonus_slots")) if sheet != null else 0)
	return {"record": record, "placement": Array(set.get("placement", [])), "level": l_eff, "slots": slots,
		"s": strength(gd, int(record.get("grade", 0)), l_eff, sheet.total("formation_power_pct") if sheet != null else 0.0),
		"share": share_of(gd, FightRequest.Situation.FORESEEN, bool(set.get("lay", true))),
		"eff": sheet.total("reserve_eff_pct") if sheet != null else 0.0}


## Applies a [method panel_payload] to compiled profile [param p] (rule 3 and 9a checked against its own reservation).
static func apply_payload(gd: GameData, p: FighterProfile, pay: Dictionary) -> void:
	if pay.is_empty() or p == null:
		return
	var k: CombatConstants = CombatConstants.from_game_data(gd)
	if bool(can_set(pay.record, int(pay.slots), p.reserved, float(pay.eff), k.reserve_cap, int(pay.level)).ok):
		apply(gd, p, pay.record, Array(pay.placement), float(pay.s), float(pay.share), float(pay.eff), int(pay.level))


## Rule 9 and F2: prepares [param c]'s set diagram for a fight in [param situation]: in a foreseen fight the owner
## lays it when [param lay] and the fuel is affordable (burnt as burn_formation, Formula H), else it is carried.
## [param level] is the effective level (rule 7). Returns {laid, share, fuel}; nothing is burnt when not laid.
static func prepare(gd: GameData, db: WorldDB, c: Character, diagram: Dictionary, level: int, situation: int, lay: bool = true, pay: bool = true) -> Dictionary:
	if diagram.is_empty():
		return {"laid": false, "share": 1.0, "fuel": 0}
	var need: int = fuel(gd, open_count(diagram, level), int(diagram.get("grade", 0)), level, c.realm_index)
	var npc: bool = str(c.id) != "" and db.has_record("people", c.id) and not bool(db.get_record("people", c.id).get("is_player", false))
	var purse: float = MoneyLedger.new(db).balance("npc:%s" % c.id) if npc else float(c.linh_thach)
	var laid: bool = lay and situation == FightRequest.Situation.FORESEEN and purse >= float(need)
	if laid and pay:
		pay_fuel(db, c, need)
	return {"laid": laid, "share": share_of(gd, situation, laid), "fuel": need if laid else 0}


## Rule 9: burns [param fuel] linh thạch of lay fuel as burn_formation (Formula H): an NPC from its own purse (rule 12),
## the player from the Character's.
static func pay_fuel(db: WorldDB, c: Character, fuel_lt: int) -> void:
	var npc: bool = str(c.id) != "" and db.has_record("people", c.id) and not bool(db.get_record("people", c.id).get("is_player", false))
	if npc:
		MoneyLedger.new(db).burn("npc:%s" % c.id, fuel_lt, "formation")
	else:
		MoneyLedger.player_pay(db, c, "", fuel_lt, "formation")
