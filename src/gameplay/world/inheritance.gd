class_name Inheritance
extends RefCounted
## Who receives a dead NPC's items when no killer is named, and who succeeds them in a sect
## (item-database.md rule 14, user decision 2026-11-13). Reads people records in the WorldDB; changes nothing.
##
## Order: a close relationship (today only master and disciple: the strongest living disciple, else the living master),
## then the sect successor, else nobody (the caller leaves the items Lost at the place of death).
##
## Usage:
## [codeblock]
## var heir: String = Inheritance.heir_of(db, gd, dead)     # "" when the items are Lost
## var next_leader: String = Inheritance.sect_successor(db, gd, dead)
## [/codeblock]


## The person who inherits [param dead]'s unbound items when there is no killer, or "".
static func heir_of(db: WorldDB, gd: GameData, dead: Dictionary) -> String:
	var disciples: Array = db.find("people", func(p): return p.alive and str(p.get("master_id", "")) == str(dead.id))
	if not disciples.is_empty():
		return str(_strongest(disciples).id)
	var master: Dictionary = db.get_record("people", str(dead.get("master_id", "")))
	if not master.is_empty() and master.alive:
		return str(master.id)
	return sect_successor(db, gd, dead)


## The living member of [param dead]'s sect who takes their place: the same rank first (highest realm), then the
## nearest rank above, then the nearest rank below (`sects.rank_ladder`). "" when not in a sect or nobody is left.
static func sect_successor(db: WorldDB, gd: GameData, dead: Dictionary) -> String:
	var sid: String = str(dead.get("sect_id", ""))
	if sid == "":
		return ""
	var ladder: Array = gd.world_gen().sects.rank_ladder
	# the player is never picked: they stand for an open seat by their own choice (Sects & Missions rule 28)
	var members: Array = db.find("people", func(p): return p.alive and str(p.get("sect_id", "")) == sid \
		and str(p.id) != str(dead.id) and not p.get("is_beast", false) and not bool(p.get("is_player", false)))
	if members.is_empty():
		return ""
	var at: int = ladder.find(str(dead.get("sect_rank", "")))
	var order: Array = []
	if at < 0:
		order = ladder.duplicate()
		order.reverse()
	else:
		order.append(ladder[at])
		for i in range(at + 1, ladder.size()):
			order.append(ladder[i])
		for i in range(at - 1, -1, -1):
			order.append(ladder[i])
	for rank in order:
		var same: Array = members.filter(func(p): return str(p.get("sect_rank", "")) == str(rank))
		if not same.is_empty():
			return str(_strongest(same).id)
	return str(_strongest(members).id)


## The highest realm, then stage, then the earlier record id.
static func _strongest(people: Array) -> Dictionary:
	var best: Dictionary = {}
	for p in people:
		if best.is_empty():
			best = p
			continue
		var a: Array = [int(p.realm_index), int(p.get("stage", 0))]
		var b: Array = [int(best.realm_index), int(best.get("stage", 0))]
		if a[0] > b[0] or (a[0] == b[0] and a[1] > b[1]) or (a == b and _num(p.id) < _num(best.id)):
			best = p
	return best


## A record id's number ("p123" -> 123), so ties go to the earlier record.
static func _num(record_id: Variant) -> int:
	return str(record_id).substr(1).to_int()
