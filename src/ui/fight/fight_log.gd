class_name FightLog
extends RefCounted
## The fight log's model (design/ux/interaction-patterns.md "Log list", design/ux/fight-screen.md "Fight log"): turns
## the recorded rows up to a playback time into log entries, in two modes, and the result-and-reasons line for an
## ended fight. It only groups and adds up recorded rows; the screen turns entries into text through tr() templates.
##
## Summary: one entry per event; an art's firing and its hits at the same instant are one entry; repeats of a foldable
## kind with the same actor, target and id fold into one entry ("Burn ×12, 96 total") while each repeat comes within
## the fold gap of the last, and the folded entry sits at its latest repeat. Full: one entry per pulse (side A's pulse
## rows are the boundaries) with each side's arts, damage dealt by type, and health and linh lực after.
## Filters keep rows whose actor is an allowed side and whose kind's group is allowed. Everything is a pure function of
## the rows, so scrubbing to a time gives the same log as playing to it.

## Each row kind's filter group ("pulse" rows are never shown on their own).
const GROUPS := {"art": "arts", "step": "arts", "empower": "arts", "hit": "damage", "tick": "damage", "soul": "damage",
	"reflect": "damage", "return": "damage", "qi_tick": "qi", "stacks": "stacks", "cleanse": "stacks", "status": "status",
	"effect": "status", "bank": "status", "cull": "status", "down": "status", "feed": "feeds", "pulse": "pulse"}
## The filter chips' groups, in display order.
const FILTER_GROUPS := ["damage", "arts", "stacks", "status", "feeds", "qi"]
## Row kinds whose recorded amount is damage dealt, and where it sits in the row's values.
const DEALT_AT := {"hit": 1, "tick": 1, "reflect": 1, "return": 1, "soul": 0}


## Default options: both sides, every group, the fold gap and foldable kinds from [param cfg] (ui_hud.json
## fight_screen "log").
static func default_options(cfg: Dictionary) -> Dictionary:
	var groups := {}
	for g in FILTER_GROUPS:
		groups[g] = true
	return {"sides": {"A": true, "B": true}, "groups": groups, "fold_gap_ms": float(cfg.get("fold_gap_ms", 2500)),
		"fold_kinds": Array(cfg.get("fold_kinds", ["tick", "qi_tick", "hit", "stacks", "status", "effect", "bank", "feed"]))}


## The damage a row dealt (0 for rows that deal none).
static func dealt(r: Dictionary) -> float:
	var at: int = int(DEALT_AT.get(str(r.kind), -1))
	var v: Array = Array(r.values)
	return float(v[at]) if at >= 0 and v.size() > at else 0.0


## True when [param r] passes the side and group filters in [param opts].
static func passes(r: Dictionary, opts: Dictionary) -> bool:
	if not bool(opts.sides.get(str(r.side), true)):
		return false
	return bool(opts.groups.get(str(GROUPS.get(str(r.kind), "status")), true))


## Summary entries for [param rows] (the rows up to the playback time), oldest first. Each entry:
## {id (its first row's index), kind, side, other, art, hit_kind, t_ms (first), t_last, count, total (damage dealt by
## all its rows), hits, rows (indexes into [param rows]), values (its first row's)}. An "art" entry carries its hits
## (hits, total); a folded entry has count > 1.
static func summary(rows: Array, opts: Dictionary) -> Array:
	var events: Array = []
	var last_art := {}   # side|art|t -> the art event its same-instant hits join
	for i in rows.size():
		var r: Dictionary = rows[i]
		var kind: String = str(r.kind)
		if kind == "pulse":
			continue
		if kind == "hit" and str(r.art) != "":
			var k: String = "%s|%s|%d" % [str(r.side), str(r.art), int(r.t_ms)]
			if last_art.has(k):
				var ev: Dictionary = last_art[k]
				ev.hits = int(ev.hits) + 1
				ev.total = float(ev.total) + dealt(r)
				ev.rows.append(i)
				ev.hit_rows.append(i)
				continue
		var e := {"id": i, "kind": kind, "side": str(r.side), "other": str(r.get("other", "")), "art": str(r.art),
			"hit_kind": str(r.get("hit_kind", "")), "t_ms": int(r.t_ms), "t_last": int(r.t_ms), "count": 1,
			"total": dealt(r), "hits": 0, "rows": [i], "hit_rows": [], "values": Array(r.values)}
		if kind == "art":
			last_art["%s|%s|%d" % [str(r.side), str(r.art), int(r.t_ms)]] = e
		events.append(e)
	var out: Array = []
	var open := {}   # fold key -> the entry repeats join
	var fold_kinds: Array = opts.get("fold_kinds", [])
	var gap: float = float(opts.get("fold_gap_ms", 2500.0))
	for e in events:
		if not _event_passes(e, rows, opts):
			continue
		if str(e.kind) in fold_kinds:
			var key: String = "%s|%s|%s|%s|%s" % [e.kind, e.side, e.other, e.art, e.hit_kind]
			if open.has(key) and float(e.t_ms) - float(open[key].t_last) <= gap:
				var f: Dictionary = open[key]
				f.count = int(f.count) + 1
				f.total = float(f.total) + float(e.total)
				f.t_last = int(e.t_ms)
				f.rows.append_array(e.rows)
				continue
			open[key] = e
		out.append(e)
	out.sort_custom(func(x, y): return int(x.t_last) < int(y.t_last) or (int(x.t_last) == int(y.t_last) and int(x.id) < int(y.id)))
	return out


## An event passes when its actor's side is allowed and any of its groups is (a fired art with hits is both "arts"
## and "damage").
static func _event_passes(e: Dictionary, rows: Array, opts: Dictionary) -> bool:
	if not bool(opts.sides.get(str(e.side), true)):
		return false
	if str(e.kind) == "art" and int(e.hits) > 0:
		return bool(opts.groups.get("arts", true)) or bool(opts.groups.get("damage", true))
	return passes(rows[int(e.rows[0])], opts)


## Full entries, one per pulse, oldest first: {id, kind "pulse", t_ms, rows (shown rows, as indexes), sides: {A/B:
## {arts: {art id: firings}, dealt: {type label: damage}, total, hp, qi, seen}}}. hp / qi are the side's last
## reading by the pulse's end, carried over from earlier pulses, as recorded (health can read below 0 after a killing
## hit); seen is false while the side has no reading yet. [param type_of] maps a row to its damage label (see [method
## type_label]). Pulses with no shown rows are left out.
static func full(rows: Array, opts: Dictionary, type_of: Callable) -> Array:
	var out: Array = []
	var cur: Dictionary = {}
	var reading := {"A": {"hp": 0.0, "qi": 0.0, "seen": false}, "B": {"hp": 0.0, "qi": 0.0, "seen": false}}
	for i in rows.size():
		var r: Dictionary = rows[i]
		if str(r.kind) == "pulse" and str(r.side) == "A" or cur.is_empty():
			if not cur.is_empty():
				_close_pulse(cur, reading, out)
			cur = {"id": i, "kind": "pulse", "t_ms": int(r.t_ms), "rows": [],
				"sides": {"A": {"arts": {}, "dealt": {}, "total": 0.0}, "B": {"arts": {}, "dealt": {}, "total": 0.0}}}
		for x in FightPlayback.hp_qi(r):
			reading[x[0]] = {"hp": float(x[1]), "qi": float(x[2]), "seen": true}
		if str(r.kind) == "pulse" or not passes(r, opts):
			continue
		cur.rows.append(i)
		var s: Dictionary = cur.sides[str(r.side)]
		if str(r.kind) == "art":
			s.arts[str(r.art)] = int(s.arts.get(str(r.art), 0)) + 1
		var d: float = dealt(r)
		if d > 0.0:
			var label: String = str(type_of.call(r))
			s.dealt[label] = float(s.dealt.get(label, 0.0)) + d
			s.total = float(s.total) + d
	if not cur.is_empty():
		_close_pulse(cur, reading, out)
	return out


static func _close_pulse(cur: Dictionary, reading: Dictionary, out: Array) -> void:
	for side in ["A", "B"]:
		cur.sides[side].hp = float(reading[side].hp)
		cur.sides[side].qi = float(reading[side].qi)
		cur.sides[side].seen = bool(reading[side].seen)
	if not Array(cur.rows).is_empty():
		out.append(cur)


## A row's damage label: a hit's art element, else its damage type, from the attacker's loadout [param arts_of] ({side:
## [art dicts]}); "phys" for a basic attack; a tick's or soul hit's own id (the element or status that ticked: the
## record carries no damage type for it); "soul" for a Soul hit; "reflect" / "return" for those (no type recorded).
static func type_label(r: Dictionary, arts_of: Dictionary) -> String:
	var kind: String = str(r.kind)
	if kind == "soul":
		return "soul"
	if kind == "tick":
		return str(r.art) if str(r.art) != "" else kind
	if kind == "reflect" or kind == "return":
		return kind   # the record carries no damage type for either
	if str(r.art) == "":
		return "phys"
	for a in Array(arts_of.get(str(r.side), [])):
		if str(a.get("id", "")) == str(r.art):
			return str(a.element) if str(a.get("element", "")) != "" else str(a.get("dtype", "phys"))
	return "phys"


## The result-and-reasons line for a finished fight (call only once playback has ended: the record knows the winner
## from the start). [param fight] is a practice_fight result. Returns {ending, winner, seconds, subject (the side the
## reasons are about: the loser, or A in a draw), reasons: up to [param top] of
##   {key "qi_low", share}: the share of the fight's time the subject's linh lực sat below its cheapest art's cost
##   (listed when it reaches [param qi_low_share]);
##   {key "taken_share", label, share}: the largest share of the damage the subject took, by type label;
##   {key "top_source", side, art, share}: the single source that dealt the most of it (an art id, the hit kind for a
##   basic attack, or "tick:<id>"), left out when it is the whole of the largest type's share (it would repeat it);
##   {key "dealt_taken", dealt, taken}: what the subject dealt and took}.
## Reasons are recorded facts, not causes.
static func result(fight: Dictionary, type_of: Callable, top: int = 3, qi_low_share: float = 0.5) -> Dictionary:
	var rows: Array = in_time_order(Array(fight.get("rows", [])))
	var winner: String = str(fight.get("winner", ""))
	var subject: String = "A" if winner != "A" else "B"
	var foe: String = FightPlayback.foe_of(subject)
	var reasons: Array = []
	var info: Dictionary = fight.get("a" if subject == "A" else "b", {})
	var cheapest: float = INF
	for a in Array(info.get("arts", [])):
		if str(a.get("pool", "qi")) == "qi" and float(a.get("cost", 0.0)) > 0.0:
			cheapest = minf(cheapest, float(a.cost))
	var first_t: int = int(rows[0].t_ms) if not rows.is_empty() else 0
	var last_t: int = first_t
	var low: bool = false
	var low_since: int = first_t
	var low_ms: int = 0
	var taken := {}
	var sources := {}
	var source_label := {}
	var taken_total: float = 0.0
	var dealt_total: float = 0.0
	for r in rows:
		var t: int = int(r.t_ms)
		last_t = maxi(last_t, t)
		for x in FightPlayback.hp_qi(r):
			if str(x[0]) != subject or cheapest == INF:
				continue
			var now_low: bool = float(x[2]) < cheapest
			if now_low and not low:
				low_since = t
			elif low and not now_low:
				low_ms += t - low_since
			low = now_low
		var d: float = dealt(r)
		if d <= 0.0:
			continue
		var target: String = FightPlayback.foe_of(str(r.side))
		if str(r.kind) in ["tick", "soul"] and str(r.get("other", "")) in ["A", "B"]:
			target = str(r.other)
		if target == subject:
			taken_total += d
			var label: String = str(type_of.call(r))
			taken[label] = float(taken.get(label, 0.0)) + d
			var src: String = "%s|%s" % [str(r.side), str(r.art) if str(r.kind) == "hit" else str(r.kind) + ":" + str(r.art)]
			sources[src] = float(sources.get(src, 0.0)) + d
			source_label[src] = label
		elif target == foe:
			dealt_total += d
	if low:
		low_ms += last_t - low_since
	if last_t > first_t and float(low_ms) / float(last_t - first_t) >= qi_low_share:
		reasons.append({"key": "qi_low", "share": float(low_ms) / float(last_t - first_t)})
	if taken_total > 0.0:
		var best: String = _argmax(taken)
		reasons.append({"key": "taken_share", "label": best, "share": float(taken[best]) / taken_total})
		var src_best: String = _argmax(sources)
		var whole: bool = str(source_label[src_best]) == best and is_equal_approx(float(sources[src_best]), float(taken[best]))
		if not whole:
			var parts: PackedStringArray = src_best.split("|")
			reasons.append({"key": "top_source", "side": parts[0], "art": parts[1] if parts.size() > 1 else "",
				"share": float(sources[src_best]) / taken_total})
	reasons.append({"key": "dealt_taken", "dealt": dealt_total, "taken": taken_total})
	return {"ending": str(fight.get("ending", "")), "winner": winner, "seconds": float(fight.get("seconds", 0.0)),
		"subject": subject, "reasons": reasons.slice(0, top)}


## [param rows] ordered by time, keeping the record's order within one instant (GDScript's sort is not stable).
static func in_time_order(rows: Array) -> Array:
	var keyed: Array = []
	for i in rows.size():
		keyed.append([int(rows[i].t_ms), i])
	keyed.sort_custom(func(x, y): return x[0] < y[0] or (x[0] == y[0] and x[1] < y[1]))   # unique keys: any sort is exact
	return keyed.map(func(k): return rows[int(k[1])])


static func _argmax(d: Dictionary) -> String:
	var best: String = ""
	var bv: float = -INF
	for k in d:
		if float(d[k]) > bv:
			bv = float(d[k])
			best = str(k)
	return best
