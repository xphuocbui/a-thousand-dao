class_name SectMembers
extends RefCounted
## The member's side of Sects & Missions (design/gdd/sects.md rules 19-22, 25; Formulas F10, F12, F13): each sect's
## standing with a person and the contribution the person holds with it, joining, promotion, leaving and desertion,
## and what a sect mission adds on top of its linh thạch. Data: sects_members.json. Records live in the World DB's
## "standing" table under "<sect id>:<person id>" ({id, sect, person, standing, contribution}).
##
## Not built yet (they need systems that do not exist): the head seat (rule 28's open seat or trial), mission kinds
## and the board (rule 24, from sect state), F12's cash cap above Kết Đan (sect treasuries), F11's prices and F14's
## services (a sect store, arrays), the stance dials (rule 12: provisional defaults in data), and allies and vassals
## sharing a fall (no pacts or vassalage yet).
##
## Usage:
## [codeblock]
## var sm := SectMembers.new(gd, db)
## var ok: Dictionary = sm.can_join(player, sect)       # {ok, reasons}
## sm.join(player, sect)
## var r: Dictionary = sm.promote(player)                # {ok, lines}
## sm.change_standing(sect.id, player.id, sm.event("mission"))
## [/codeblock]

const TABLE := "standing"

var _gd: GameData
var _db: WorldDB


func _init(gd: GameData, db: WorldDB) -> void:
	_gd = gd
	_db = db


## sects_members.json.
func config() -> Dictionary:
	return _gd.file("sects_members")


## The (sect, person) record, created at standing 0 and no contribution when absent.
func record(sect_id: String, person_id: String) -> Dictionary:
	var id: String = "%s:%s" % [sect_id, person_id]
	var rec: Dictionary = _db.get_record(TABLE, id)
	if rec.is_empty():
		rec = {"id": id, "sect": sect_id, "person": person_id, "standing": 0.0, "contribution": 0}
		_db.put(TABLE, rec)
	return rec


## The sect's standing with the person (F10; 0 when they have never met).
func standing(sect_id: String, person_id: String) -> float:
	var rec: Dictionary = _db.get_record(TABLE, "%s:%s" % [sect_id, person_id])
	return 0.0 if rec.is_empty() else float(rec.standing)


## The contribution the person holds with the sect.
func contribution(sect_id: String, person_id: String) -> int:
	var rec: Dictionary = _db.get_record(TABLE, "%s:%s" % [sect_id, person_id])
	return 0 if rec.is_empty() else int(rec.contribution)


## F10's e for event [param kind] (sects_members.json standing_events).
func event(kind: String) -> float:
	return float(config().standing_events.get(kind, 0.0))


## F10: moves the standing by [param e]: a gain is smoothed by (1 - St / 100) while St >= 0, a fall is taken in
## full; the result stays within -100..100. Returns the change made.
static func standing_step(st: float, e: float) -> float:
	var d: float = e * (1.0 - st / 100.0) if (e > 0.0 and st >= 0.0) else e
	return clampf(st + d, -100.0, 100.0) - st


## Applies F10 to the (sect, person) record. Allies and vassals of the sect would take [code]ally_share[/code] of a fall
## (rule 21); none exist until pacts and vassalage are built. Returns the change made.
func change_standing(sect_id: String, person_id: String, e: float) -> float:
	var rec: Dictionary = record(sect_id, person_id)
	var d: float = standing_step(float(rec.standing), e)
	rec["standing"] = float(rec.standing) + d
	return d


## The sect's recruit line: 20 - 10 x its Recruitment dial (F11; the dial is the provisional default until rule 12's
## dials exist).
func recruit_line(_sect: Dictionary) -> float:
	var c: Dictionary = config()
	return float(c.recruit_line_base) - float(c.recruit_line_per_dial) * float(c.default_dials.recruitment)


## Whether the sect treats the person as hostile (standing at or below Quests' hostile_threshold).
func hostile(sect_id: String, person_id: String) -> bool:
	return standing(sect_id, person_id) <= float(config().hostile_threshold)


## Rule 20: whether [param c] may join [param sect] now: no sect yet, at the sect's seat, the realm floor, and standing at
## least the recruit line (and not hostile). Returns {ok, reasons}.
func can_join(c: Character, sect: Dictionary) -> Dictionary:
	var reasons: Array = []
	if sect.is_empty() or str(sect.get("status", "active")) != "active":
		reasons.append("there is no such sect")
		return {"ok": false, "reasons": reasons}
	if c.sect_id != "":
		reasons.append("you already belong to a sect (leave it first)")
	if c.location_id != str(sect.hq_place_id):
		reasons.append("a sect recruits only at its seat")
	if c.realm_index < int(config().join_realm_floor):
		reasons.append("your realm is below the sect's floor")
	var st: float = standing(str(sect.id), c.id)
	if st < recruit_line(sect) or hostile(str(sect.id), c.id):
		reasons.append("the sect's standing with you is %.0f, below its recruit line %.0f" % [st, recruit_line(sect)])
	if not SectAdmission.admits_outer(_gd, sect, c.linh_can):
		reasons.append(SectAdmission.refusal_reason(_gd, sect, c.linh_can, "ngoai_mon"))
	return {"ok": reasons.is_empty(), "reasons": reasons}


## Rule 20: [param c] joins [param sect] as an outer disciple (the join rank). The caller checks [method can_join].
func join(c: Character, sect: Dictionary) -> void:
	c.sect_id = str(sect.id)
	c.sect_rank = str(_gd.session().sect.join_rank)
	if not (sect.members as Array).has(c.id):
		sect.members.append(c.id)
	record(str(sect.id), c.id)


## How rank [param rank] is shown (sects_members.json rank_names; the id itself when unnamed).
func rank_name(rank: String) -> String:
	return str(config().get("rank_names", {}).get(rank, rank))


## The rank after [param rank] on the ladder, or "" at the top.
func next_rank(rank: String) -> String:
	var ladder: Array = _gd.world_gen().sects.rank_ladder
	var i: int = ladder.find(rank)
	return str(ladder[i + 1]) if i >= 0 and i + 1 < ladder.size() else ""


## F13 for [param c]'s next rank: {rank, gate (or {} when promotion cannot reach it), missing: [reasons]}.
func promotion_needs(c: Character) -> Dictionary:
	var nxt: String = next_rank(c.sect_rank)
	var gate: Dictionary = config().promotion.get(nxt, {})
	var missing: Array = []
	if c.sect_id == "":
		missing.append("you belong to no sect")
	elif nxt == "":
		missing.append("you hold the highest rank")
	elif gate.is_empty():
		missing.append("the %s seat is not reached by promotion: it opens on the head's death or retreat, or by a trial" % rank_name(nxt))
	else:
		if c.realm_index < int(gate.realm):
			missing.append("realm %s needed" % _gd.realm(int(gate.realm)).name)
		var have: int = contribution(c.sect_id, c.id)
		if have < int(gate.contribution):
			missing.append("contribution %d of %d" % [have, int(gate.contribution)])
		var st: float = standing(c.sect_id, c.id)
		if st < float(gate.standing):
			missing.append("standing %.0f of %.0f" % [st, float(gate.standing)])
		if nxt in ["noi_mon", "truong_lao"]:
			var sect: Dictionary = _db.get_record("sects", c.sect_id)
			if not sect.is_empty() and not SectAdmission.admits_core(_gd, sect, c.linh_can):
				missing.append(SectAdmission.refusal_reason(_gd, sect, c.linh_can, nxt))
	return {"rank": nxt, "gate": gate, "missing": missing}


## F13: promotes [param c] one rank when it meets the gate, spending the contribution. Returns {ok, lines}.
func promote(c: Character) -> Dictionary:
	var need: Dictionary = promotion_needs(c)
	if not (need.missing as Array).is_empty():
		return {"ok": false, "lines": ["No promotion yet: %s." % "; ".join(need.missing)]}
	var rec: Dictionary = record(c.sect_id, c.id)
	rec["contribution"] = int(rec.contribution) - int(need.gate.contribution)
	c.sect_rank = str(need.rank)
	return {"ok": true, "lines": ["Promoted to %s (%d contribution spent, %d left)." % [rank_name(str(need.rank)), int(need.gate.contribution), int(rec.contribution)]]}


## Rule 22: [param c] leaves its sect on good terms, or deserts ([param desert]): F10's desertion fall, then standing
## set to at most the ceiling (hostile at the threshold). Returns {ok, lines}.
func leave(c: Character, desert: bool) -> Dictionary:
	if c.sect_id == "":
		return {"ok": false, "lines": ["You belong to no sect."]}
	var sect: Dictionary = _db.get_record("sects", c.sect_id)
	var lines: Array = []
	if desert:
		var d: Dictionary = config().desertion
		change_standing(c.sect_id, c.id, float(d.fall))
		var rec: Dictionary = record(c.sect_id, c.id)
		rec["standing"] = minf(float(rec.standing), float(d.ceiling))
		lines.append("You desert %s. Its standing with you falls to %.0f: it now treats you as hostile." % [str(sect.get("name", c.sect_id)), float(rec.standing)])
	else:
		lines.append("You leave %s on good terms." % str(sect.get("name", c.sect_id)))
	if not sect.is_empty():
		(sect.members as Array).erase(c.id)
	c.sect_id = ""
	c.sect_rank = ""
	return {"ok": true, "lines": lines}


## Rule 25, F10, F12: what a mission for [param c]'s own sect adds to its linh thạch [param cash]: contribution
## (c_share x cash, the cash cap above Kết Đan waiting on sect treasuries) and the mission's standing gain.
## Returns {contribution, standing}.
func mission_reward(c: Character, cash: int) -> Dictionary:
	var gain: int = int(roundf(float(config().contribution_per_cash) * float(cash)))
	var rec: Dictionary = record(c.sect_id, c.id)
	rec["contribution"] = int(rec.contribution) + gain
	var d: float = change_standing(c.sect_id, c.id, event("mission"))
	return {"contribution": gain, "standing": d}
