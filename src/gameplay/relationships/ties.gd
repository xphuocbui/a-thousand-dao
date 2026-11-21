class_name Ties
extends RefCounted
## NPC Relationships (design/gdd/npc-relationships.md, #46): the lasting ties between people, one record per pair in
## the World DB's "ties" table, indexed from both people (rule 1). Opinion stays computed (NPC Traits F3); this class
## stores only the named ties that formed and gives F3 its tie term (Formula A). Reading never writes (rule 3).
##
## A record (JSON-safe): {id, a, b (a < b),
##   pin: {kin: true, ket_nghia: true, dao_lu: true, companion: true, su_do: "<master id>"},
##   feud: {"<holder id>": {inherited, generation, cause}}                 (pinned, per direction),
##   soft: {kind: friend|rival, s, set, cause} or {kind: enmity, dir: {"<holder id>": {s, set, cause}}},
##   debt: {debtor, s, set, cause},
##   favour: "<caller id>" (favour_owed caller -> sibling, rule 15a) or "",
##   outside_cap: "<person id>" (mourner enmity held toward that person, rule 7) or ""}
## Strengths are hundredths (0-10,000), set seasons are absolute seasons (year x 4 + season), Formula B fades them lazily.
##
## Usage:
## [codeblock]
## Ties.set_master(gd, db, disciple_id, master_id, season_now)
## var r := Ties.write_soft(gd, db, "p1", "p2", "friend", 20, season_now)   # {ok, reason, evicted}
## var v: float = Ties.tie_value(gd, db, "p1", "p2", season_now)            # Formula A, p1 -> p2
## [/codeblock]

const FILE := "npc_relationships"
const TABLE := "ties"
const PINNED := ["kin", "su_do", "ket_nghia", "dao_lu", "companion"]
const SOFT := ["friend", "rival", "enmity"]
## Rule 1b's table: the news kind of each end reason ("" for none).
const NEWS := {"avenged": "feud_end_avenged", "slain": "feud_end_slain", "target_died": "feud_end_natural",
	"holder_died": "feud_end_holder_died", "partner_died": "", "faded": "", "replaced": "", "cancelled": "",
	"evicted": "evicted", "betrayed": "betrayal", "repaid": "debt_repaid", "parted": "parted"}


## The data file's values.
static func cfg(gd: GameData) -> Dictionary:
	return gd.file(FILE)


## Whether the store is in use (the data file is loaded).
static func enabled(gd: GameData) -> bool:
	return gd.registry.has_file(FILE)


## The data load's checks (Formula B, rule 5): every fade rate above 0, each class's soft_reserve at most its cap.
## Returns the problems found ([] when the data is good).
static func validate(d: Dictionary) -> Array:
	var errs: Array = []
	for k in ["friend", "rival", "enmity", "debt"]:
		if int(d.get("rate", {}).get(k, 0)) <= 0:
			errs.append("rate.%s must be above 0 (a part at 0 never vacates its slot)" % k)
	var res: Dictionary = d.get("soft_reserve", {})
	if int(res.get("ordinary", 0)) > int(d.get("cap_ordinary", 0)):
		errs.append("soft_reserve.ordinary is above cap_ordinary")
	if int(res.get("notable", 0)) > int(d.get("cap_notable", 0)):
		errs.append("soft_reserve.notable is above cap_notable")
	return errs


# --- The clock ----------------------------------------------------------------------------------------------------

## The world's current absolute season (year x 4 + season) for fades, as the tick last wrote it (0 with none).
static func now(db: WorldDB) -> int:
	return int(db.get_record("world", "w_clock").get("season", 0))


## Sets the world's current absolute season (the Living World Tick each season, World Generation at the start).
static func set_now(db: WorldDB, season: int) -> void:
	var rec: Dictionary = db.get_record("world", "w_clock")
	if rec.is_empty():
		db.add("world", {"id": "w_clock", "season": season})
	else:
		rec["season"] = season


# --- Reading (rule 3: never writes) -------------------------------------------------------------------------------

## Formula B: a part's current strength in hundredths at [param season] (clamped at 0; a set season in the future
## reads as stored).
static func s_now(c: Dictionary, rate_key: String, part: Dictionary, season: int) -> int:
	if part.is_empty():
		return 0
	var age: int = maxi(0, season - int(part.get("set", season)))
	return maxi(0, int(part.get("s", 0)) - int(c.rate[rate_key]) * age)


## The current strength (hundredths) of the soft kind held by [param holder] on [param rec] (enmity per direction;
## friend and rival shared), 0 when absent or faded.
static func soft_s(c: Dictionary, rec: Dictionary, holder: String, season: int) -> int:
	var soft: Dictionary = rec.get("soft", {})
	if soft.is_empty():
		return 0
	if str(soft.kind) == "enmity":
		return s_now(c, "enmity", soft.get("dir", {}).get(holder, {}), season)
	return s_now(c, str(soft.kind), soft, season)


## Rule 1's record-level strength of the soft kind: the larger direction (hundredths).
static func soft_level(c: Dictionary, rec: Dictionary, season: int) -> int:
	return maxi(soft_s(c, rec, str(rec.a), season), soft_s(c, rec, str(rec.b), season))


## The current debt strength (hundredths), 0 when absent or faded.
static func debt_s(c: Dictionary, rec: Dictionary, season: int) -> int:
	return s_now(c, "debt", rec.get("debt", {}), season)


## Whether [param rec] counts as pinned for caps and eviction (a pinned kind, a blood feud, or a favour owed, rule 7).
static func is_pinned(rec: Dictionary) -> bool:
	return not Dictionary(rec.get("pin", {})).is_empty() or not Dictionary(rec.get("feud", {})).is_empty() \
		or str(rec.get("favour", "")) != ""


## Formula A: the tie term of [param a]'s opinion of [param b] at [param season]. The largest positive pinned weight,
## plus a blood feud a holds toward b, plus a's soft kind and the debt at their current strengths. 0 with no record.
static func tie_value(gd: GameData, db: WorldDB, a: String, b: String, season: int) -> float:
	return float(_parts(gd, db, a, b, season).total)


## Formula A's parts for a -> b: {total, enmity} where enmity is the feud plus soft enmity part (for F3's min with a
## Grudge, Open Question 2).
static func _parts(gd: GameData, db: WorldDB, a: String, b: String, season: int) -> Dictionary:
	var rec: Dictionary = db.tie_between(a, b)
	if rec.is_empty():
		return {"total": 0.0, "enmity": 0.0}
	var c: Dictionary = cfg(gd)
	var pin: Dictionary = rec.get("pin", {})
	var best: float = 0.0
	for k in pin:
		best = maxf(best, float(c.pin.get(k, 0)))
	var feud: float = float(c.feud) if Dictionary(rec.get("feud", {})).has(a) else 0.0
	var soft: Dictionary = rec.get("soft", {})
	var sv: float = 0.0
	if not soft.is_empty():
		var w: float = float(c.soft.get(str(soft.kind), 0))
		sv = w * float(soft_s(c, rec, a, season)) / 10000.0
	var dv: float = 0.0
	var debt: Dictionary = rec.get("debt", {})
	var ds: int = debt_s(c, rec, season)
	if ds > 0:
		dv = float(c.debt.debtor if str(debt.debtor) == a else c.debt.creditor) * float(ds) / 10000.0
	var en: float = feud + (sv if str(soft.get("kind", "")) == "enmity" else 0.0)
	return {"total": best + feud + sv + dv, "enmity": en}


## The feud plus soft enmity part of a -> b (F3 takes min(Grudge target, this) for the same person, Formula A).
static func enmity_value(gd: GameData, db: WorldDB, a: String, b: String, season: int) -> float:
	return float(_parts(gd, db, a, b, season).enmity)


## Whether [param a] and [param b] hold pinned kind [param kind] (su_do in either direction).
static func has_pin(db: WorldDB, a: String, b: String, kind: String) -> bool:
	return Dictionary(db.tie_between(a, b).get("pin", {})).has(kind)


## The living master of [param disciple_id] by the store, or "".
static func master_of(db: WorldDB, disciple_id: String) -> String:
	for rec in db.ties_of(disciple_id):
		var m: String = str(rec.get("pin", {}).get("su_do", ""))
		if m != "" and m != disciple_id and bool(db.get_record("people", m).get("alive", false)):
			return m
	return ""


# --- Caps (rules 5-7) -------------------------------------------------------------------------------------------

## Rule 6: whether [param pid] is notable now (fixed cast, sect head or elder, Nguyên Anh or higher, on the player's
## met list, or the player). Computed, never stored.
static func notable(gd: GameData, db: WorldDB, pid: String) -> bool:
	var p: Dictionary = db.get_record("people", pid)
	if p.is_empty():
		return false
	if bool(p.get("is_player", false)) or str(p.get("cast_key", "")) != "" or int(p.get("realm_index", 0)) >= 3:
		return true
	if str(p.get("sect_rank", "")) in ["truong_lao", "tong_chu"]:
		return true
	return met_list(db).has(pid)


static var _player_db: int = 0
static var _player_id: String = ""
static var _player_n: int = -1


## The player's met list (rule 6), most recent first ([] when there is no player record). The player's id is cached
## per World DB (a scan of the people only when the cache misses).
static func met_list(db: WorldDB) -> Array:
	var rec: Dictionary = {}
	var same: bool = _player_db == db.get_instance_id() and _player_n == db.count("people")
	if same and _player_id == "":
		return []   # no player in this world (a simulation), until someone is added
	if same:
		rec = db.get_record("people", _player_id)
	if rec.is_empty() or not bool(rec.get("is_player", false)):
		rec = {}
		_player_db = db.get_instance_id()
		_player_n = db.count("people")
		_player_id = ""
		for p in db.living():
			if bool(p.get("is_player", false)):
				rec = p
				_player_id = str(p.id)
				break
	return rec.get("met_list", [])


## Rule 6: the met list [param met] after the player meets [param pid] (front of the list, trimmed to
## met_notable_max). Someone pushed off the end is returned in "dropped" so S8b can test their notability.
static func met_after(gd: GameData, met: Array, pid: String) -> Dictionary:
	var l: Array = met.duplicate()
	l.erase(pid)
	l.push_front(pid)
	var n: int = int(cfg(gd).met_notable_max)
	return {"list": l.slice(0, n), "dropped": l.slice(n)}


## Rule 5: [param pid]'s cap.
static func cap(gd: GameData, db: WorldDB, pid: String) -> int:
	var c: Dictionary = cfg(gd)
	return int(c.cap_notable if notable(gd, db, pid) else c.cap_ordinary)


## Rule 5: [param pid]'s soft-only limit, max(soft_reserve, cap − pinned records).
static func soft_limit(gd: GameData, db: WorldDB, pid: String) -> int:
	var c: Dictionary = cfg(gd)
	var cls: String = "notable" if notable(gd, db, pid) else "ordinary"
	var pinned: int = db.ties_of(pid).filter(func(r): return is_pinned(r)).size()
	return maxi(int(c.soft_reserve[cls]), cap(gd, db, pid) - pinned)


## The soft-only records that count on [param pid]'s side (an outside_cap record does not count there, rule 7).
static func soft_only(db: WorldDB, pid: String) -> Array:
	return db.ties_of(pid).filter(func(r): return not is_pinned(r) and str(r.get("outside_cap", "")) != pid)


## Rule 7's eviction strength of a soft-only record: the larger of its soft kind's and debt's current strengths.
static func evict_s(c: Dictionary, rec: Dictionary, season: int) -> int:
	return maxi(soft_level(c, rec, season), debt_s(c, rec, season))


## Rule 7: the records [param pid] must evict to take a new soft-only record entering at [param entry] hundredths,
## weakest first (older set season, then lower partner id), each strictly weaker than the entry; null when it cannot
## make room. [] when there is a free slot.
static func room(gd: GameData, db: WorldDB, pid: String, entry: int, season: int) -> Variant:
	var c: Dictionary = cfg(gd)
	var mine: Array = soft_only(db, pid)
	var need: int = mine.size() - (soft_limit(gd, db, pid) - 1)
	if need <= 0:
		return []
	var cands: Array = mine.map(func(r): return [evict_s(c, r, season), _set_of(r), _other(r, pid), r])
	cands.sort_custom(func(x, y): return x[0] < y[0] or (x[0] == y[0] and (x[1] < y[1] or (x[1] == y[1] and str(x[2]) < str(y[2])))))
	var out: Array = []
	for cd in cands:
		if out.size() >= need:
			break
		if int(cd[0]) >= entry:
			return null
		out.append(cd[3])
	return out if out.size() >= need else null


static func _set_of(rec: Dictionary) -> int:
	var s: int = -1
	var soft: Dictionary = rec.get("soft", {})
	if not soft.is_empty():
		if str(soft.kind) == "enmity":
			for h in soft.get("dir", {}):
				s = maxi(s, int(soft.dir[h].get("set", -1)))
		else:
			s = int(soft.get("set", -1))
	if not Dictionary(rec.get("debt", {})).is_empty():
		s = maxi(s, int(rec.debt.get("set", -1)))
	return s


static func _other(rec: Dictionary, pid: String) -> String:
	return str(rec.b) if str(rec.a) == pid else str(rec.a)


# --- Writing ----------------------------------------------------------------------------------------------------

## The record of the pair, created (not yet stored) when absent.
static func _record(db: WorldDB, a: String, b: String) -> Dictionary:
	var rec: Dictionary = db.tie_between(a, b)
	if not rec.is_empty():
		return rec
	var lo: String = a if a < b else b
	var hi: String = b if a < b else a
	return {"a": lo, "b": hi, "pin": {}, "feud": {}, "soft": {}, "debt": {}, "favour": "", "outside_cap": ""}


static func _store(db: WorldDB, rec: Dictionary) -> void:
	if str(rec.get("id", "")) == "":
		db.add(TABLE, rec)
	else:
		db.put(TABLE, rec)


## Whether [param rec] holds nothing (no pinned kind, feud, soft kind, debt or favour).
static func is_empty_record(rec: Dictionary) -> bool:
	return Dictionary(rec.get("pin", {})).is_empty() and Dictionary(rec.get("feud", {})).is_empty() \
		and Dictionary(rec.get("soft", {})).is_empty() and Dictionary(rec.get("debt", {})).is_empty() \
		and str(rec.get("favour", "")) == ""


## Removes an emptied record from the store.
static func _drop_if_empty(db: WorldDB, rec: Dictionary) -> void:
	if is_empty_record(rec) and str(rec.get("id", "")) != "":
		db.remove(TABLE, str(rec.id))


## Rules 2 and 6: adds pinned kind [param kind] between [param a] and [param b] (for su_do, a is the master). Refuses
## a second living master or đạo lữ, a companion that is not the player's, and kết nghĩa or đạo lữ between two
## ordinary people unless [param authored]. A new pinned tie always forms (overflow, rule 7). Returns {ok, reason}.
static func add_pinned(gd: GameData, db: WorldDB, a: String, b: String, kind: String, _season: int, authored: bool = false) -> Dictionary:
	if a == b or not kind in PINNED:
		return {"ok": false, "reason": "bad tie"}
	var pa: Dictionary = db.get_record("people", a)
	var pb: Dictionary = db.get_record("people", b)
	if kind == "companion" and not (bool(pa.get("is_player", false)) or bool(pb.get("is_player", false))):
		return {"ok": false, "reason": "a companion is the player's"}
	if kind in ["ket_nghia", "dao_lu"] and not authored and not (notable(gd, db, a) or notable(gd, db, b)):
		return {"ok": false, "reason": "kết nghĩa and đạo lữ need a notable person"}
	if kind == "su_do":
		var m: String = master_of(db, b)
		if m != "" and m != a:
			return {"ok": false, "reason": "the disciple has a living master"}
	if kind == "dao_lu":
		for who in [a, b]:
			for r in db.ties_of(who):
				if Dictionary(r.get("pin", {})).has("dao_lu") and _other(r, who) != (b if who == a else a) \
						and bool(db.get_record("people", _other(r, who)).get("alive", false)):
					return {"ok": false, "reason": "already has a living đạo lữ"}
	var rec: Dictionary = _record(db, a, b)
	rec.pin[kind] = a if kind == "su_do" else true
	rec["outside_cap"] = ""
	_store(db, rec)
	return {"ok": true, "reason": ""}


## The one writer of sư đồ (rule 2): the tie and the disciple's `master_id` together, so the two never disagree.
## Returns add_pinned's result.
static func set_master(gd: GameData, db: WorldDB, disciple_id: String, master_id: String, season: int) -> Dictionary:
	if master_id == "" or disciple_id == "":
		return {"ok": false, "reason": "no master"}
	# a master already dead (the cast's history) is kept as master_id only: a tie never names the dead (rule 13)
	var alive: bool = bool(db.get_record("people", master_id).get("alive", true))
	var r: Dictionary = add_pinned(gd, db, master_id, disciple_id, "su_do", season, true) if enabled(gd) and alive else {"ok": true}
	if bool(r.ok):
		var d: Dictionary = db.get_record("people", disciple_id)
		if not d.is_empty():
			d["master_id"] = master_id
	return r


## Rules 11 and 13: sets a pinned blood feud held by [param holder] toward [param target]: the holder's soft enmity
## toward the target is removed (the other direction keeps its own), and a friend or rival kind on the record is
## replaced. opts: inherited (bool), generation (int), cause (Dictionary). A pinned tie always forms (rule 7).
static func set_feud(gd: GameData, db: WorldDB, holder: String, target: String, season: int, opts: Dictionary = {}) -> void:
	if holder == target:
		return
	var rec: Dictionary = _record(db, holder, target)
	var soft: Dictionary = rec.get("soft", {})
	if str(soft.get("kind", "")) == "enmity":
		if Dictionary(soft.dir).has(holder):
			end_part(db, rec, "enmity:%s" % holder, "replaced", season, soft.dir[holder].get("cause", {}))
		_clear_soft(rec, holder)
	elif not soft.is_empty():
		end_part(db, rec, str(soft.kind), "replaced", season, soft.get("cause", {}))
		rec["soft"] = {}
	rec.feud[holder] = {"inherited": bool(opts.get("inherited", false)), "generation": int(opts.get("generation", 0)),
		"cause": opts.get("cause", {}), "set": season}
	rec["outside_cap"] = ""
	_store(db, rec)


## An older save keeps masters only in `master_id`: writes the missing sư đồ records (once; a load calls it). Sets the
## clock from [param season] when the save has none. Returns the records added.
static func migrate(gd: GameData, db: WorldDB, season: int) -> int:
	if not enabled(gd):
		return 0
	if db.get_record("world", "w_clock").is_empty():
		set_now(db, season)
	var n: int = 0
	for p in db.all("people"):
		var m: String = str(p.get("master_id", ""))
		if m != "" and bool(p.get("alive", true)) and bool(db.get_record("people", m).get("alive", false)) and not has_pin(db, m, str(p.id), "su_do"):
			var rec: Dictionary = _record(db, m, str(p.id))
			rec.pin["su_do"] = m
			_store(db, rec)
			n += 1
	return n


## Formula C and rule 10: writes soft kind [param kind] held by [param holder] toward [param other] with change
## [param delta] (whole points). opts: deed (betrayal, crippling or killing, slight: replaces another soft kind),
## floor (inherited: s = max(s_now, 100 · delta)), cause (a Dictionary), outside_cap (mourner enmity held toward
## other: no room needed on other's side), force (an authored or fixture record written directly, past the caps).
## Returns {ok, reason, evicted: [record ids]}.
static func write_soft(gd: GameData, db: WorldDB, holder: String, other: String, kind: String, delta: int, season: int, opts: Dictionary = {}) -> Dictionary:
	if holder == other or not kind in SOFT:
		return {"ok": false, "reason": "bad tie", "evicted": []}
	var c: Dictionary = cfg(gd)
	var rec: Dictionary = _record(db, holder, other)
	if kind == "enmity" and Dictionary(rec.get("feud", {})).has(holder):
		return {"ok": false, "reason": "the feud already carries it", "evicted": []}   # rule 10
	var soft: Dictionary = rec.get("soft", {})
	var cur_kind: String = str(soft.get("kind", ""))
	var cur: int = soft_s(c, rec, holder, season) if cur_kind == kind else 0
	var level: int = soft_level(c, rec, season)
	var deed: bool = bool(opts.get("deed", false))
	var floor_w: bool = bool(opts.get("floor", false))
	var cause: Dictionary = opts.get("cause", {})
	if cur_kind != "" and cur_kind != kind and level > 0:
		# rule 10: another soft kind replaces the current one when stronger, or always when a deed
		if not deed and 100 * delta <= level:
			return {"ok": false, "reason": "a stronger soft kind holds", "evicted": []}
		end_part(db, rec, cur_kind, "replaced", season, soft.get("cause", {}) if cur_kind != "enmity" else {})
	var new_s: int
	if cur_kind == kind and cur > 0:
		new_s = maxi(cur, 100 * delta) if floor_w else clampi(cur + 100 * delta, 0, 10000)
	else:
		if delta <= 0:
			return {"ok": false, "reason": "nothing to weaken", "evicted": []}   # rule 4: no part at 0 is stored
		new_s = clampi(100 * delta, 0, 10000)
	var evicted: Array = []
	if str(rec.get("id", "")) == "" and new_s > 0 and not bool(opts.get("force", false)):
		# rule 7: a new soft-only record needs room on both sides (an outside_cap side needs none)
		var ra: Variant = room(gd, db, holder, new_s, season)
		var rb: Variant = [] if bool(opts.get("outside_cap", false)) else room(gd, db, other, new_s, season)
		if ra == null or rb == null:
			return {"ok": false, "reason": "no room", "evicted": []}
		for r in Array(ra) + Array(rb):
			if not evicted.has(str(r.id)):
				evicted.append(str(r.id))
				end_record(gd, db, r, "evicted", season)
		if bool(opts.get("outside_cap", false)):
			rec["outside_cap"] = other
	elif str(rec.get("outside_cap", "")) != "" and not bool(opts.get("outside_cap", false)):
		rec["outside_cap"] = ""   # rule 7: gaining any other part makes it count
	if new_s <= 0:
		_clear_soft(rec, holder)
	elif kind == "enmity":
		if cur_kind != "enmity":
			rec["soft"] = {"kind": "enmity", "dir": {}}
		var keep_cause: Dictionary = rec.soft.dir.get(holder, {}).get("cause", {}) if cur > 0 else {}
		rec.soft.dir[holder] = {"s": new_s, "set": season, "cause": keep_cause if cause.is_empty() else cause}
	else:
		var keep: Dictionary = soft.get("cause", {}) if cur_kind == kind and cur > 0 else {}
		rec["soft"] = {"kind": kind, "s": new_s, "set": season, "cause": keep if cause.is_empty() else cause}
	if is_empty_record(rec):
		_drop_if_empty(db, rec)
	else:
		_store(db, rec)
	return {"ok": true, "reason": "", "evicted": evicted}


static func _clear_soft(rec: Dictionary, holder: String) -> void:
	var soft: Dictionary = rec.get("soft", {})
	if str(soft.get("kind", "")) == "enmity":
		soft.dir.erase(holder)
		if Dictionary(soft.dir).is_empty():
			rec["soft"] = {}
	else:
		rec["soft"] = {}


## Rule 1a and Formula C: a debt of gratitude [param debtor] owes [param creditor], change [param delta]. The same way
## adds (or floors, opts.floor); the other way is netted (the larger remains at the difference, 0 removes it).
## Returns {ok, reason, evicted}.
static func write_debt(gd: GameData, db: WorldDB, debtor: String, creditor: String, delta: int, season: int, opts: Dictionary = {}) -> Dictionary:
	if debtor == creditor:
		return {"ok": false, "reason": "bad tie", "evicted": []}
	var c: Dictionary = cfg(gd)
	var rec: Dictionary = _record(db, debtor, creditor)
	var cur: int = debt_s(c, rec, season)
	var debt: Dictionary = rec.get("debt", {})
	var cause: Dictionary = opts.get("cause", {})
	var new_s: int
	var new_debtor: String = debtor
	if cur > 0 and str(debt.debtor) != debtor:
		var net: int = cur - 100 * delta
		if net == 0:
			rec["debt"] = {}
			if is_empty_record(rec):
				end_record(gd, db, rec, "cancelled", season)
			else:
				end_part(db, rec, "debt", "cancelled", season, debt.get("cause", {}))
				_store(db, rec)
			return {"ok": true, "reason": "", "evicted": []}
		new_s = absi(net)
		new_debtor = str(debt.debtor) if net > 0 else debtor
	elif cur > 0:
		new_s = maxi(cur, 100 * delta) if bool(opts.get("floor", false)) else clampi(cur + 100 * delta, 0, 10000)
	else:
		if delta <= 0:
			return {"ok": false, "reason": "nothing to weaken", "evicted": []}
		new_s = clampi(100 * delta, 0, 10000)
	var evicted: Array = []
	if str(rec.get("id", "")) == "":
		var ra: Variant = room(gd, db, debtor, new_s, season)
		var rb: Variant = room(gd, db, creditor, new_s, season)
		if ra == null or rb == null:
			return {"ok": false, "reason": "no room", "evicted": []}
		for r in Array(ra) + Array(rb):
			if not evicted.has(str(r.id)):
				evicted.append(str(r.id))
				end_record(gd, db, r, "evicted", season)
	else:
		rec["outside_cap"] = ""
	var keep: Dictionary = debt.get("cause", {}) if cur > 0 and new_debtor == str(debt.get("debtor", "")) else {}
	rec["debt"] = {"debtor": new_debtor, "s": new_s, "set": season, "cause": keep if cause.is_empty() else cause}
	_store(db, rec)
	return {"ok": true, "reason": "", "evicted": evicted}


## Rule 4: removes the faded parts (current strength 0) of every record of [param pid], and records left empty.
## Returns the number of parts removed.
static func sweep(gd: GameData, db: WorldDB, pid: String, season: int) -> int:
	var c: Dictionary = cfg(gd)
	var n: int = 0
	for rec in db.ties_of(pid):
		var soft: Dictionary = rec.get("soft", {})
		var faded: Array = []
		if not soft.is_empty():
			if str(soft.kind) == "enmity":
				for h in Dictionary(soft.dir).keys():
					if soft_s(c, rec, str(h), season) <= 0:
						faded.append(["enmity:%s" % h, soft.dir[h].get("cause", {})])
						soft.dir.erase(h)
				if Dictionary(soft.dir).is_empty():
					rec["soft"] = {}
			elif soft_s(c, rec, str(rec.a), season) <= 0:
				faded.append([str(soft.kind), soft.get("cause", {})])
				rec["soft"] = {}
		if not Dictionary(rec.get("debt", {})).is_empty() and debt_s(c, rec, season) <= 0:
			faded.append(["debt", rec.debt.get("cause", {})])
			rec["debt"] = {}
		n += faded.size()
		if is_empty_record(rec):
			end_record(gd, db, rec, "faded", season)
		else:
			for f in faded:   # rule 1b: a part that faded on a record that lives on
				end_part(db, rec, str(f[0]), "faded", season, f[1])
			db.put(TABLE, rec)
	return n


## Rule 1b: one part of record [param rec] ended for [param reason] while the record lives on ([param part]: a pinned
## kind, a soft kind ("enmity:<holder>" for one direction), "debt" or "feud:<holder>"): a `tie_end` log entry with the
## reason, its news kind and the part's old cause. Removes nothing (the caller has).
static func end_part(db: WorldDB, rec: Dictionary, part: String, reason: String, season: int, cause: Dictionary = {}) -> void:
	if str(rec.get("id", "")) == "":
		return   # a record not yet stored has no history to end
	db.log_event(int(season / 4), season % 4, "tie_end", "", [str(rec.a), str(rec.b)], [], [],
		{"reason": reason, "news": str(NEWS.get(reason, "")), "part": part, "causes": [cause], "death": {}, "pin": []})


## Ends record [param rec] for [param reason] (rule 1b's table): removes it and writes a `tie_end` log entry with the
## reason and the old parts' causes. [param death] is the ending death's payload, when a death ends it.
static func end_record(gd: GameData, db: WorldDB, rec: Dictionary, reason: String, season: int, death: Dictionary = {}) -> void:
	if str(rec.get("id", "")) == "":
		return
	var causes: Array = []
	for h in rec.get("feud", {}):
		causes.append(rec.feud[h].get("cause", {}))
	var soft: Dictionary = rec.get("soft", {})
	if not soft.is_empty():
		if str(soft.kind) == "enmity":
			for h in soft.get("dir", {}):
				causes.append(soft.dir[h].get("cause", {}))
		else:
			causes.append(soft.get("cause", {}))
	if not Dictionary(rec.get("debt", {})).is_empty():
		causes.append(rec.debt.get("cause", {}))
	db.remove(TABLE, str(rec.id))
	db.log_event(int(season / 4), season % 4, "tie_end", "", [str(rec.a), str(rec.b)], [], [],
		{"reason": reason, "news": str(NEWS.get(reason, "")), "causes": causes, "death": death,
			"pin": Dictionary(rec.get("pin", {})).keys()})


# --- Formula F: hooks with no caller yet (help calls, favours, errands) -------------------------------------------

## Formula F: a sworn sibling's chance to answer a help call, from their opinion [param op] of the caller; 0 while
## they are owed a favour by the caller.
static func p_help(gd: GameData, op: float, favour_owed: bool = false) -> float:
	if favour_owed:
		return 0.0
	var m: float = float(cfg(gd).help_min)
	return clampf((op - m) / (100.0 - m), 0.0, 1.0)


## Formula F: linh thạch to clear a favour early, ceil(stipend of the sibling's realm × favour_cost_mult), burned.
static func favour_cost(gd: GameData, sibling_realm: int) -> int:
	var st: Array = gd.file("economy").money.stipend
	return int(ceil(float(st[clampi(sibling_realm, 0, st.size() - 1)]) * float(cfg(gd).favour_cost_mult)))


## Formula F: an errand's cost at the higher of the player's and the disciple's realm, and its reward budget
## B_errand = floor(errand_margin × cost). {cost, budget}.
static func errand(gd: GameData, player_realm: int, disciple_realm: int) -> Dictionary:
	var st: Array = gd.file("economy").money.stipend
	var r: int = clampi(maxi(player_realm, disciple_realm), 0, st.size() - 1)
	var cost: int = int(ceil(float(st[r]) * float(cfg(gd).errand_cost_mult)))
	return {"cost": cost, "budget": int(floor(float(cfg(gd).errand_margin) * float(cost)))}
