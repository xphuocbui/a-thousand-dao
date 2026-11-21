class_name Families
extends RefCounted
## Families (user decision 2026-11-21): World Generation rule 8's families at the start and Living World Tick rule 5's
## births, both writing NPC Relationships' kin records (parent and child, and children of the same parent).
##
##   Families.cfg(gd)                                   # world_generation.json "families"
##   Families.link(gd, db, child, parent, season)       # parent_id, surname, kin with the parent and the siblings
##   Families.pick_parent(gd, db, idx, region, age, key) # a living ordinary person who may take one more child
##   Families.at_start(gd, db, seed_s, season)          # the start's keyed kin_share of the random cultivators


const FILE := "world_generation"


## The families block: kin_share, parent_age_gap, children_max, birth_share.
static func cfg(gd: GameData) -> Dictionary:
	return gd.file(FILE).get("families", {})


## [param name]'s surname from the names list (the longest that fits, for two-word surnames), or its first word.
static func surname_of(gd: GameData, name: String) -> String:
	var best: String = ""
	for s in gd.names().get("surnames", []):
		var sn: String = str(s)
		if name.begins_with(sn + " ") and sn.length() > best.length():
			best = sn
	if best == "":
		best = name.split(" ")[0]
	return best


## [param name] with its surname replaced by [param surname].
static func with_surname(gd: GameData, name: String, surname: String) -> String:
	var old: String = surname_of(gd, name)
	return surname + name.substr(old.length())


## Makes [param child] the child of [param parent]: parent_id, the parent's surname (unless [param keep_name]), and
## kin with the parent and with each living child of the same parent ([param idx] from [method index]: its lists are
## kept up to date; {} scans the living).
static func link(gd: GameData, db: WorldDB, child: Dictionary, parent: Dictionary, season: int, keep_name: bool = false, idx: Dictionary = {}) -> void:
	var cid: String = str(child.id)
	var pid: String = str(parent.id)
	var sibs: Array = []
	if idx.is_empty():
		for p in db.living():
			if str(p.get("parent_id", "")) == pid and bool(p.get("alive", true)):
				sibs.append(str(p.id))
	else:
		sibs = idx.kids.get(pid, []).duplicate()
	for sid in sibs:
		if str(sid) != cid:
			Ties.add_pinned(gd, db, cid, str(sid), "kin", season, true)
	if not idx.is_empty():
		if not idx.kids.has(pid):
			idx.kids[pid] = []
		idx.kids[pid].append(cid)
	child["parent_id"] = pid
	db.note_child(pid, cid)
	if not keep_name:
		_rename_line(gd, db, child, surname_of(gd, str(parent.get("name", ""))), idx, 0)
	Ties.add_pinned(gd, db, pid, cid, "kin", season, true)


## [param p] and their descendants take [param surname] (a family line keeps one name when an elder joins another).
static func _rename_line(gd: GameData, db: WorldDB, p: Dictionary, surname: String, idx: Dictionary, depth: int) -> void:
	p["name"] = with_surname(gd, str(p.get("name", "")), surname)
	if depth > 8 or idx.is_empty():
		return
	for cid in idx.kids.get(str(p.id), []):
		var k: Dictionary = db.get_record("people", str(cid))
		if not k.is_empty():
			_rename_line(gd, db, k, surname, idx, depth + 1)


## An index for [method pick_parent] and [method link]: {kids: {parent id: [living child ids]}, by_region: {region id:
## [eligible people]}}. Parents are ordinary people only (no beast, no player, no fixed cast), living.
static func index(db: WorldDB) -> Dictionary:
	var kids := {}
	var by_region := {}
	for p in db.living():
		if not bool(p.get("alive", true)):
			continue
		var par: String = str(p.get("parent_id", ""))
		if par != "":
			if not kids.has(par):
				kids[par] = []
			kids[par].append(str(p.id))
		if bool(p.get("is_beast", false)) or bool(p.get("is_player", false)) or p.has("cast_key"):
			continue
		var rid: String = str(db.get_record("places", str(p.get("location_id", ""))).get("region_id", ""))
		if not by_region.has(rid):
			by_region[rid] = []
		by_region[rid].append(p)
	var everyone: Array = []
	for rid in by_region:
		everyone.append_array(by_region[rid])
	return {"kids": kids, "by_region": by_region, "all": everyone}


## A parent for a child of [param age] in region [param region] ("*": anywhere, for a birth): at least parent_age_gap older, fewer than
## children_max children, picked by [param key] among those eligible ({} when none). [method link] counts the child.
static func pick_parent(gd: GameData, idx: Dictionary, region: String, age: float, key: String) -> Dictionary:
	var c: Dictionary = cfg(gd)
	var gap: float = float(c.get("parent_age_gap", 18))
	var cap: int = int(c.get("children_max", 3))
	var ok: Array = Array(idx.all if region == "*" else idx.by_region.get(region, [])).filter(func(p): return bool(p.get("alive", true)) and float(p.get("age", 0.0)) >= age + gap and Array(idx.kids.get(str(p.id), [])).size() < cap)
	if ok.is_empty():
		return {}
	return ok[RngUtils.stable_hash(key) % ok.size()]


## World Generation rule 8, Families: a keyed kin_share of the random cultivators (created_by worldgen, by id order)
## each get a parent of their region. Returns the number linked.
static func at_start(gd: GameData, db: WorldDB, seed_s: String, season: int) -> int:
	var share: float = float(cfg(gd).get("kin_share", 0.0))
	if share <= 0.0:
		return 0
	var idx: Dictionary = index(db)
	var pool: Array = db.living().filter(func(p): return str(p.get("created_by", "")) == "worldgen" and not bool(p.get("is_beast", false)) and str(p.get("parent_id", "")) == "")
	pool.sort_custom(func(a, b): return str(a.id) < str(b.id))
	var n: int = 0
	for p in pool:
		if float(RngUtils.stable_hash("%s:kin:%s" % [seed_s, p.id]) % 10000) / 10000.0 >= share:
			continue
		var rid: String = str(db.get_record("places", str(p.get("location_id", ""))).get("region_id", ""))
		var par: Dictionary = pick_parent(gd, idx, rid, float(p.get("age", 16.0)), "%s:parent:%s" % [seed_s, p.id])
		if par.is_empty() or str(par.id) == str(p.id):
			continue
		link(gd, db, p, par, season, false, idx)
		n += 1
	return n
