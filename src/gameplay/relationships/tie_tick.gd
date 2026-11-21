class_name TieTick
extends RefCounted
## NPC Relationships' season step S8b (design/gdd/npc-relationships.md rule 9), run by the Living World Tick after S8.
## A season's sources queue changes (enqueue); S8b applies them in seven steps: (1) deaths and inheritance (rule 13),
## (2) ends (betrayals, tie_end, faded parts of the people touched), (3) evictions for lost notability (rule 6),
## (4) strength changes on parts that exist (Formula C), (5) new parts and deeds with eviction (rules 7, 10),
## (6) hardening (rule 11), (7) the hook pass (rule 15a). Only people named in a queued change are touched, plus the
## player's sweep and the hook pass. No randomness: order is the queue's (event-log) order, then ids.
##
## Queue entries ({kind, ...}): death {dead, killer, known, place, cause, event}; soft {holder, other, sk, delta, deed,
## cause}; debt {debtor, creditor, delta, cause}; pinned {a, b, pk, authored}; betrayal {betrayer, betrayed, cause};
## end {a, b, reason}; repay {debtor, creditor}; notability {pid}.

const QUEUE := "w_tie_queue"


## Queues [param change] for this season's S8b.
static func enqueue(db: WorldDB, change: Dictionary) -> void:
	var q: Dictionary = db.get_record("world", QUEUE)
	if q.is_empty():
		q = {"id": QUEUE, "items": []}
		db.add("world", q)
	q.items.append(change)


## The queued changes (not yet applied).
static func queued(db: WorldDB) -> Array:
	return db.get_record("world", QUEUE).get("items", [])


## S8b for [param season] (an absolute season). Returns the ids of the events logged.
static func run(gd: GameData, db: WorldDB, season: int) -> Array:
	if not Ties.enabled(gd):
		return []
	var items: Array = queued(db).duplicate()
	var q: Dictionary = db.get_record("world", QUEUE)
	if not q.is_empty():
		q["items"] = []
	var dead_set := {}
	for it in items:
		if str(it.kind) == "death":
			dead_set[str(it.dead)] = it
	var touched := {}
	var news: Array = []
	# 1. deaths and inheritance, in ascending dead-person id
	var dead_ids: Array = dead_set.keys()
	dead_ids.sort_custom(func(x, y): return _id_lt(str(x), str(y)))
	var passed := {}   # each dead person passes ties on once
	_kids_ok = false
	for did in dead_ids:
		if passed.has(did):
			continue
		passed[did] = true
		news.append_array(_inherit(gd, db, dead_set[did], dead_set, season, touched))
	var live: Array = items.filter(func(it): return str(it.kind) != "death" and not _names_dead(it, dead_set))
	# 2. ends
	for it in live:
		match str(it.kind):
			"betrayal":
				_betray(gd, db, it, season, touched)
			"end":
				var rec: Dictionary = db.tie_between(str(it.a), str(it.b))
				if not rec.is_empty():
					Ties.end_record(gd, db, rec, str(it.get("reason", "parted")), season)
				touched[str(it.a)] = true
				touched[str(it.b)] = true
			"repay":
				_repay(gd, db, it, season, touched)
	for pid in touched.keys():
		Ties.sweep(gd, db, str(pid), season)
	# 3. evictions for lost notability
	for it in live:
		if str(it.kind) == "notability" and not Ties.notable(gd, db, str(it.pid)):
			_evict_to_limit(gd, db, str(it.pid), season)
	# 4. strength changes on parts that exist, then 5. new parts and deeds
	var later: Array = []
	for it in live:
		if str(it.kind) in ["soft", "debt"]:
			if _exists(gd, db, it, season):
				_apply(gd, db, it, season, touched)
			else:
				later.append(it)
	for it in live:
		if str(it.kind) == "pinned":
			Ties.add_pinned(gd, db, str(it.a), str(it.b), str(it.pk), season, bool(it.get("authored", false)))
			touched[str(it.a)] = true
			touched[str(it.b)] = true
	for it in later:
		_apply(gd, db, it, season, touched)
	# 6. hardening on every direction touched
	var ids: Array = touched.keys()
	ids.sort_custom(func(x, y): return _id_lt(str(x), str(y)))
	for pid in ids:
		harden(gd, db, str(pid), season)
	# 7. the hook pass
	hook_pass(gd, db, season)
	return news


static func _id_lt(x: String, y: String) -> bool:
	var nx: int = int(x.substr(1)) if x.substr(1).is_valid_int() else 0
	var ny: int = int(y.substr(1)) if y.substr(1).is_valid_int() else 0
	return nx < ny if nx != ny else x < y


static func _names_dead(it: Dictionary, dead_set: Dictionary) -> bool:
	for k in ["holder", "other", "debtor", "creditor", "a", "b", "betrayer", "betrayed", "pid"]:
		if it.has(k) and dead_set.has(str(it[k])):
			return true
	return false


static func _exists(gd: GameData, db: WorldDB, it: Dictionary, season: int) -> bool:
	var c: Dictionary = Ties.cfg(gd)
	if str(it.kind) == "debt":
		var r: Dictionary = db.tie_between(str(it.debtor), str(it.creditor))
		return not r.is_empty() and Ties.debt_s(c, r, season) > 0
	var rec: Dictionary = db.tie_between(str(it.holder), str(it.other))
	return not rec.is_empty() and str(rec.get("soft", {}).get("kind", "")) == str(it.sk) and Ties.soft_s(c, rec, str(it.holder), season) > 0


static func _apply(gd: GameData, db: WorldDB, it: Dictionary, season: int, touched: Dictionary) -> void:
	if str(it.kind) == "debt":
		Ties.write_debt(gd, db, str(it.debtor), str(it.creditor), int(it.delta), season, {"cause": it.get("cause", {})})
		touched[str(it.debtor)] = true
		touched[str(it.creditor)] = true
	else:
		Ties.write_soft(gd, db, str(it.holder), str(it.other), str(it.sk), int(it.delta), season,
			{"deed": bool(it.get("deed", false)), "cause": it.get("cause", {})})
		touched[str(it.holder)] = true
		touched[str(it.other)] = true


# --- Rule 12: betrayal ---------------------------------------------------------------------------------------------

static func _betray(gd: GameData, db: WorldDB, it: Dictionary, season: int, touched: Dictionary) -> void:
	var a: String = str(it.betrayed)
	var b: String = str(it.betrayer)
	var rec: Dictionary = db.tie_between(a, b)
	touched[a] = true
	touched[b] = true
	if not rec.is_empty():
		for k in ["ket_nghia", "dao_lu", "su_do"]:
			if Dictionary(rec.pin).has(k):
				Ties.end_part(db, rec, k, "betrayed", season)
			rec.pin.erase(k)
		rec["favour"] = ""
		db.put(Ties.TABLE, rec)
	var d: int = int(it.get("delta", Ties.cfg(gd).delta.betrayal_enmity))
	# in place, needing no room (rule 9 step 2): an existing record keeps its slot
	Ties.write_soft(gd, db, a, b, "enmity", d, season, {"deed": true, "cause": it.get("cause", {"kind": "betrayal"}), "in_place": true})


# --- Rule 14: repaying a debt ---------------------------------------------------------------------------------------

static func _repay(gd: GameData, db: WorldDB, it: Dictionary, season: int, touched: Dictionary) -> void:
	var rec: Dictionary = db.tie_between(str(it.debtor), str(it.creditor))
	if rec.is_empty() or Dictionary(rec.get("debt", {})).is_empty():
		return
	Ties.end_part(db, rec, "debt", "repaid", season, rec.debt.get("cause", {}))
	rec["debt"] = {}
	var soft: Dictionary = rec.get("soft", {})
	var c: Dictionary = Ties.cfg(gd)
	if soft.is_empty() or str(soft.kind) == "friend":
		var cur: int = Ties.soft_s(c, rec, str(rec.a), season) if not soft.is_empty() else 0
		rec["soft"] = {"kind": "friend", "s": maxi(cur, 100 * int(c.delta.repay_friend)), "set": season,
			"cause": soft.get("cause", {"kind": "rescue"})}
	db.put(Ties.TABLE, rec)
	touched[str(it.debtor)] = true
	touched[str(it.creditor)] = true


# --- Rule 6: lost notability -------------------------------------------------------------------------------------

static func _evict_to_limit(gd: GameData, db: WorldDB, pid: String, season: int) -> void:
	var c: Dictionary = Ties.cfg(gd)
	var mine: Array = Ties.soft_only(db, pid)
	var extra: int = mine.size() - Ties.soft_limit(gd, db, pid)
	if extra <= 0:
		return
	mine.sort_custom(func(x, y):
		var sx: int = Ties.evict_s(c, x, season)
		var sy: int = Ties.evict_s(c, y, season)
		return sx < sy or (sx == sy and Ties._set_of(x) < Ties._set_of(y)))
	for i in extra:
		Ties.end_record(gd, db, mine[i], "evicted", season)


# --- Rule 11: hardening -------------------------------------------------------------------------------------------

## Rule 11: every enmity [param pid] holds (or is held at) whose current strength reaches feud_threshold becomes a
## pinned blood feud on the same record, that direction only.
static func harden(gd: GameData, db: WorldDB, pid: String, season: int) -> void:
	var c: Dictionary = Ties.cfg(gd)
	for rec in db.ties_of(pid):
		var soft: Dictionary = rec.get("soft", {})
		if str(soft.get("kind", "")) != "enmity":
			continue
		for h in Dictionary(soft.dir).keys():
			if Ties.soft_s(c, rec, str(h), season) >= 100 * int(c.feud_threshold):
				var cause: Dictionary = soft.dir[h].get("cause", {})
				var target: String = Ties._other(rec, str(h))
				Ties.set_feud(gd, db, str(h), target, season, {"inherited": false, "generation": 0, "cause": cause})
				rec = db.tie_between(str(h), target)
				soft = rec.get("soft", {})
				if str(soft.get("kind", "")) != "enmity":
					break


# --- Rule 13: death passes ties on --------------------------------------------------------------------------------

## The dead person's close ties (kin, master, disciples, kết nghĩa, đạo lữ) by kind, and their records.
static func _close(db: WorldDB, did: String) -> Dictionary:
	var out := {"dao_lu": [], "master": [], "kin": [], "ket_nghia": [], "disciples": [], "all": []}
	for rec in db.ties_of(did):
		var o: String = Ties._other(rec, did)
		var pin: Dictionary = rec.get("pin", {})
		var close: bool = false
		if pin.has("dao_lu"):
			out.dao_lu.append(o)
			close = true
		if pin.has("su_do"):
			if str(pin.su_do) == did:
				out.disciples.append(o)
			else:
				out.master.append(o)
			close = true
		if pin.has("kin"):
			out.kin.append(o)
			close = true
		if pin.has("ket_nghia"):
			out.ket_nghia.append(o)
			close = true
		if close:
			out.all.append(o)
	return out


static func _eldest_first(db: WorldDB, ids: Array) -> Array:
	var out: Array = ids.duplicate()
	out.sort_custom(func(x, y):
		var bx: int = int(db.get_record("people", str(x)).get("born_year", 0))
		var by: int = int(db.get_record("people", str(y)).get("born_year", 0))
		return bx < by or (bx == by and _id_lt(str(x), str(y))))
	return out


static var _kids: Dictionary = {}   # parent id -> [child ids], built once per S8b run that has a death
static var _kids_ok: bool = false


## Children of [param did] (people whose World DB parent is the dead), eldest first. No parents are generated yet.
static func _children(db: WorldDB, did: String) -> Array:
	if not _kids_ok:
		_kids = {}
		for p in db.living():
			var par: String = str(p.get("parent_id", ""))
			if par != "":
				if not _kids.has(par):
					_kids[par] = []
				_kids[par].append(str(p.id))
		_kids_ok = true
	return _eldest_first(db, _kids.get(did, []))


static func _uniq_add(lst: Array, ids: Array, struck: Dictionary, n: int) -> void:
	for x in ids:
		if lst.size() >= n:
			return
		if not struck.has(str(x)) and not lst.has(str(x)):
			lst.append(str(x))


static func _inherit(gd: GameData, db: WorldDB, death: Dictionary, dead_set: Dictionary, season: int, touched: Dictionary) -> Array:
	var c: Dictionary = Ties.cfg(gd)
	var did: String = str(death.dead)
	var killer: String = str(death.get("killer", ""))
	var known: bool = killer != "" and bool(death.get("known", true)) and not dead_set.has(killer)
	var payload := {"dead": did, "killer": killer if known else "", "place": str(death.get("place", "")),
		"cause": str(death.get("cause", "")), "season": season, "event": str(death.get("event", ""))}
	var close: Dictionary = _close(db, did)
	var children: Array = _children(db, did)
	var disciples: Array = _eldest_first(db, close.disciples)
	var nf: int = int(c.inherit_feud_max)
	var nm: int = int(c.mourner_max)
	# mourners, closest first: đạo lữ, the master, other kin (children eldest first, then the rest eldest first),
	# kết nghĩa, other disciples (eldest first); heirs are taken out by the caller's struck set
	var mourn_order: Array = Array(close.dao_lu) + Array(close.master) + children \
		+ _eldest_first(db, Array(close.kin).filter(func(x): return not children.has(x))) + Array(close.ket_nghia) + disciples
	var base_struck := {}
	for x in dead_set:
		base_struck[str(x)] = true
	base_struck[did] = true
	# a known kill
	if known:
		var struck: Dictionary = base_struck.duplicate()
		struck[killer] = true
		var av: Array = []
		for o in close.all:
			if struck.has(str(o)):
				continue
			var r: Dictionary = db.tie_between(str(o), killer)
			if r.is_empty():
				continue
			if Dictionary(r.get("feud", {})).has(str(o)):
				av.append([1000000, str(o)])
			elif str(r.get("soft", {}).get("kind", "")) == "enmity" and Ties.soft_s(c, r, str(o), season) > 0:
				av.append([Ties.soft_s(c, r, str(o), season), str(o)])
		av.sort_custom(func(x, y): return x[0] > y[0] or (x[0] == y[0] and _id_lt(x[1], y[1])))
		var avengers: Array = av.map(func(x): return x[1])
		var heirs: Array = []
		_uniq_add(heirs, avengers, struck, nf)
		_uniq_add(heirs, children, struck, nf)
		_uniq_add(heirs, disciples, struck, nf)
		for h in heirs:
			var own: bool = avengers.has(h)
			Ties.set_feud(gd, db, h, killer, season, {"inherited": not own, "generation": 0,
				"cause": {"kind": "kill" if own else "inherited", "death": payload}})
			touched[h] = true
		var mourners: Array = []
		var taken: Dictionary = struck.duplicate()
		for h in heirs:
			taken[h] = true
		_uniq_add(mourners, mourn_order, taken, nm)
		for m in mourners:
			Ties.write_soft(gd, db, m, killer, "enmity", int(c.inherit_enmity), season,
				{"floor": true, "outside_cap": true, "cause": {"kind": "inherited", "death": payload}})
			touched[m] = true
		touched[killer] = true
	# feuds the dead held
	for rec in db.ties_of(did):
		var fd: Dictionary = rec.get("feud", {}).get(did, {})
		if fd.is_empty():
			continue
		var target: String = Ties._other(rec, did)
		if dead_set.has(target):
			continue
		var struck2: Dictionary = base_struck.duplicate()
		struck2[target] = true
		var heirs2: Array = []
		_uniq_add(heirs2, children, struck2, nf)
		_uniq_add(heirs2, disciples, struck2, nf)
		var origin: Dictionary = fd.get("cause", {}).get("origin", fd.get("cause", {}).get("death", payload))
		var gen: int = int(fd.get("generation", 0)) + 1
		var cause := {"kind": "inherited", "death": payload, "origin": origin, "generation": gen}
		for h in heirs2:
			if bool(fd.get("inherited", false)):
				Ties.write_soft(gd, db, h, target, "enmity", int(c.inherit_enmity), season, {"floor": true, "outside_cap": true, "cause": cause})
			else:
				Ties.set_feud(gd, db, h, target, season, {"inherited": true, "generation": gen, "cause": cause})
			touched[h] = true
		var taken2: Dictionary = struck2.duplicate()
		for h in heirs2:
			taken2[h] = true
		var mourners2: Array = []
		_uniq_add(mourners2, mourn_order, taken2, nm)
		for m in mourners2:
			Ties.write_soft(gd, db, m, target, "enmity", int(c.inherit_enmity), season, {"floor": true, "outside_cap": true, "cause": cause})
			touched[m] = true
		touched[target] = true
	# debts owed to the dead pass to the heirs (children then disciples); debts the dead owed are cancelled
	for rec in db.ties_of(did):
		var debt: Dictionary = rec.get("debt", {})
		if debt.is_empty() or str(debt.debtor) == did:
			continue
		var debtor: String = str(debt.debtor)
		if dead_set.has(debtor):
			continue
		var s: int = int(floor(float(Ties.debt_s(c, rec, season)) * float(c.inherit_debt)))
		if s < 100:
			continue
		var struck3: Dictionary = base_struck.duplicate()
		struck3[debtor] = true
		var heirs3: Array = []
		_uniq_add(heirs3, children, struck3, nf)
		_uniq_add(heirs3, disciples, struck3, nf)
		for h in heirs3:
			Ties.write_debt(gd, db, debtor, h, int(s / 100), season, {"floor": true, "cause": {"kind": "inherited", "death": payload}})
			touched[h] = true
		touched[debtor] = true
	# every record of the dead ends; a feud or enmity toward the dead ends with its reason (rule 1b)
	var news: Array = []
	for rec in db.ties_of(did):
		var o: String = Ties._other(rec, did)
		touched[o] = true
		var reason: String = "partner_died"
		var held: bool = Dictionary(rec.get("feud", {})).has(o) or (str(rec.get("soft", {}).get("kind", "")) == "enmity" and Ties.soft_s(c, rec, o, season) > 0)
		if held:
			if known and (killer == o or _hates(gd, db, killer, did, season)):
				reason = "avenged"
			elif known:
				reason = "slain"
			else:
				reason = "target_died"
		elif Dictionary(rec.get("feud", {})).has(did) and dead_set.has(o):
			# rule 1b precedence: the holder and the target both die this season: the target's reason wins
			var od: Dictionary = dead_set[o]
			var o_known: bool = str(od.get("killer", "")) != "" and bool(od.get("known", true)) and not dead_set.has(str(od.killer))
			if o_known and str(od.killer) == did:
				reason = "avenged"
			elif o_known:
				reason = "slain"
			else:
				reason = "target_died"
		elif Dictionary(rec.get("feud", {})).has(did):
			reason = "holder_died"
		Ties.end_record(gd, db, rec, reason, season, payload)
	return news


static func _hates(gd: GameData, db: WorldDB, who: String, target: String, season: int) -> bool:
	var r: Dictionary = db.tie_between(who, target)
	if r.is_empty():
		return false
	return Dictionary(r.get("feud", {})).has(who) or (str(r.get("soft", {}).get("kind", "")) == "enmity" and Ties.soft_s(Ties.cfg(gd), r, who, season) > 0)


# --- Rule 15a: the hook pass --------------------------------------------------------------------------------------

## Rule 15a: the master and đạo lữ cultivation rows (source `tie`), rebuilt from the records holding sư đồ or đạo lữ:
## a disciple whose master lives and is of a higher realm gets master_cult_pct; each đạo lữ pair in the same place gets
## daolu_cult_pct each. Rows no surviving record qualifies are removed. Writes each person's `tie_rows`.
static func hook_pass(gd: GameData, db: WorldDB, _season: int) -> void:
	var c: Dictionary = Ties.cfg(gd)
	var want := {}
	for rec in db.hook_ties():
		var pin: Dictionary = rec.get("pin", {})
		var pa: Dictionary = db.get_record("people", str(rec.a))
		var pb: Dictionary = db.get_record("people", str(rec.b))
		if not bool(pa.get("alive", false)) or not bool(pb.get("alive", false)):
			continue
		if pin.has("su_do"):
			var m: Dictionary = pa if str(pin.su_do) == str(rec.a) else pb
			var d: Dictionary = pb if str(pin.su_do) == str(rec.a) else pa
			if int(m.get("realm_index", 0)) > int(d.get("realm_index", 0)):
				_want(want, str(d.id), {"stat": "cultivation_speed_pct", "value": float(c.master_cult_pct), "source": "master", "with": str(m.id)})
		if pin.has("dao_lu") and str(pa.get("location_id", "")) != "" and str(pa.get("location_id", "")) == str(pb.get("location_id", "")):
			_want(want, str(pa.id), {"stat": "cultivation_speed_pct", "value": float(c.daolu_cult_pct), "source": "dao_lu", "with": str(pb.id)})
			_want(want, str(pb.id), {"stat": "cultivation_speed_pct", "value": float(c.daolu_cult_pct), "source": "dao_lu", "with": str(pa.id)})
	# reconcile by source: everyone holding rows now, and everyone who should
	var holders: Dictionary = db.get_record("world", "w_tie_rows").get("holders", {})
	for pid in want:
		holders[pid] = true
	var still := {}
	for pid in holders:
		var p: Dictionary = db.get_record("people", str(pid))
		if p.is_empty():
			continue
		var rows: Array = want.get(pid, [])
		if rows.is_empty():
			p.erase("tie_rows")
		else:
			if p.get("tie_rows", []) != rows:   # unchanged rows are not rewritten
				p["tie_rows"] = rows
			still[pid] = true
	var meta: Dictionary = db.get_record("world", "w_tie_rows")
	if meta.is_empty():
		db.add("world", {"id": "w_tie_rows", "holders": still})
	else:
		meta["holders"] = still


static func _want(want: Dictionary, pid: String, row: Dictionary) -> void:
	if not want.has(pid):
		want[pid] = []
	want[pid].append(row)
