class_name FightPlayback
extends RefCounted
## The fight screen's playback model (design/ux/fight-screen.md, Data Requirements): rebuilds what each side looks
## like at a playback time from a recorded fight's rows ([method GameQuery.practice_fight]). It only reads and adds up
## recorded events, never computes combat, so scrubbing anywhere gives the same picture.
##
## Row layouts are FightLogRow's: PULSE [hp, qi]; ART [cost, hp, qi]; HIT [D, dealt, def_hp, def_qi, att_hp, att_qi];
## TICK [amount, dealt, hp, qi] on [code]other[/code]; STACKS [n, until_ms, buff 1/0] from side onto other; STATUS
## [stacks, until_ms] onto other; CLEANSE [removed]; STEP [next step]; EMPOWER []; FEED [from slot, to slot, ms];
## EFFECT []; BANK [scale]; DOWN [].
##
## Greybox limits: stacks are summed from their batches and cleanses remove the oldest debuffs first; caps and merges
## inside the engine are not recorded, so a count can differ from the engine's (production/plans/ui-greybox-build.md).

var rows: Array = []
var end_ms: int = 0
## Per side: the largest health and linh lực seen, used as the bars' maximums.
var max_hp := {"A": 1.0, "B": 1.0}
var max_qi := {"A": 1.0, "B": 1.0}
## Per side, per art id: the sorted times it fired.
var fires := {"A": {}, "B": {}}
## Per side, per art id: its cooldown in seconds (from the loadout).
var cooldowns := {"A": {}, "B": {}}


## Builds the model from [param fight] (a practice_fight result).
static func from_fight(fight: Dictionary) -> FightPlayback:
	var p := FightPlayback.new()
	p.rows = Array(fight.get("rows", []))
	for side in ["A", "B"]:
		var info: Dictionary = fight.get("a" if side == "A" else "b", {})
		for art in Array(info.get("arts", [])):
			if art is Dictionary:
				p.cooldowns[side][str(art.id)] = float(art.get("cd", 3.0))
	for r in p.rows:
		p.end_ms = maxi(p.end_ms, int(r.t_ms))
		for reading in hp_qi(r):
			p.max_hp[reading[0]] = maxf(float(p.max_hp[reading[0]]), float(reading[1]))
			p.max_qi[reading[0]] = maxf(float(p.max_qi[reading[0]]), float(reading[2]))
		if str(r.kind) == "art":
			var list: Array = p.fires[str(r.side)].get(str(r.art), [])
			list.append(int(r.t_ms))
			p.fires[str(r.side)][str(r.art)] = list
	return p


## The other side's label.
static func foe_of(side: String) -> String:
	return "B" if side == "A" else "A"


## The [side, hp, qi] readings a row carries.
static func hp_qi(r: Dictionary) -> Array:
	var v: Array = Array(r.values)
	var side: String = str(r.side)
	match str(r.kind):
		"pulse":
			return [[side, v[0], v[1]]] if v.size() >= 2 else []
		"art":
			return [[side, v[1], v[2]]] if v.size() >= 3 else []
		"hit":
			return [[foe_of(side), v[2], v[3]], [side, v[4], v[5]]] if v.size() >= 6 else []
		"tick", "soul":
			var target: String = str(r.other) if str(r.other) != "" else foe_of(side)
			return [[target, v[v.size() - 2], v[v.size() - 1]]] if v.size() >= 2 else []
		"reflect", "return":
			return [[foe_of(side) if str(r.kind) == "reflect" else side, v[2], v[3]]] if v.size() >= 4 else []
	return []


## How charged an art is at [param t] (0 just fired, 1 ready): the share of the gap between its last firing and its
## next one in the record, or of its cooldown after the last firing.
func charge(side: String, art_id: String, t: float) -> float:
	var times: Array = fires[side].get(art_id, [])
	var last: float = -1.0
	var nxt: float = -1.0
	for tm in times:
		if float(tm) <= t:
			last = float(tm)
		elif nxt < 0.0:
			nxt = float(tm)
	if last < 0.0:
		return clampf(t / nxt, 0.0, 1.0) if nxt > 0.0 else 1.0
	var span: float = (nxt - last) if nxt > 0.0 else float(cooldowns[side].get(art_id, 3.0)) * 1000.0
	return clampf((t - last) / maxf(1.0, span), 0.0, 1.0)


## The state at playback time [param t] (ms): per side health, linh lực, down, each art's tally, stacks, statuses,
## fired Effects; the pulse count; the log rows up to t; and the recent hits, ticks, feeds and fires within
## [param recent_ms] for floating numbers, link lines and flashes.
func state_at(t: float, recent_ms: float = 900.0) -> Dictionary:
	var sides := {}
	for side in ["A", "B"]:
		sides[side] = {"hp": max_hp[side], "qi": max_qi[side], "down": false, "arts": {}, "buffs": [], "debuffs": [],
			"statuses": {}, "effects": {}, "bank": {}}
	var log_rows: Array = []
	var recent: Array = []
	var pulses: int = 0
	for r in rows:
		var tm: float = float(r.t_ms)
		if tm > t:
			break
		var kind: String = str(r.kind)
		var side: String = str(r.side)
		var v: Array = Array(r.values)
		for reading in hp_qi(r):
			sides[reading[0]].hp = maxf(0.0, float(reading[1]))
			sides[reading[0]].qi = maxf(0.0, float(reading[2]))
		var target: String = str(r.other) if str(r.other) in ["A", "B"] else foe_of(side)
		match kind:
			"pulse":
				if side == "A":
					pulses += 1
			"art":
				var a: Dictionary = _art(sides[side], str(r.art))
				a.count += 1
				a.empowered = false
			"hit":
				var key: String = str(r.art) if str(r.art) != "" else "basic"
				var a2: Dictionary = _art(sides[side], key)
				a2.dmg += float(v[1]) if v.size() > 1 else 0.0
			"step":
				_art(sides[side], str(r.art)).step = int(v[0]) if v.size() > 0 else 0
			"empower":
				_art(sides[side], str(r.art)).empowered = true
			"stacks":
				var batch := {"el": str(r.art), "n": float(v[0]), "until": float(v[1])}
				sides[target]["buffs" if v.size() > 2 and float(v[2]) > 0.5 else "debuffs"].append(batch)
			"status":
				sides[target].statuses[str(r.art)] = {"stacks": float(v[0]), "until": float(v[1])}
			"cleanse":
				var left: float = float(v[0]) if v.size() > 0 else 0.0
				for b in sides[side].debuffs:
					var take: float = minf(left, float(b.n))
					b.n = float(b.n) - take
					left -= take
			"effect":
				sides[side].effects[str(r.art)] = int(sides[side].effects.get(str(r.art), 0)) + 1
			"bank":
				sides[side].bank[str(r.art)] = float(v[0]) if v.size() > 0 else 0.0
			"down":
				sides[side].down = true
		log_rows.append(r)
		if t - tm <= recent_ms and kind in ["hit", "tick", "feed", "art"]:
			recent.append(r)
	for side in ["A", "B"]:
		sides[side].buff_totals = _totals(sides[side].buffs, t)
		sides[side].debuff_totals = _totals(sides[side].debuffs, t)
		var live := {}
		for sid in sides[side].statuses:
			var st: Dictionary = sides[side].statuses[sid]
			if float(st.until) < 0.0 or float(st.until) > t:
				live[sid] = st
		sides[side].statuses = live
	return {"sides": sides, "pulses": pulses, "log": log_rows, "recent": recent}


static func _art(side_state: Dictionary, id: String) -> Dictionary:
	if not side_state.arts.has(id):
		side_state.arts[id] = {"count": 0, "dmg": 0.0, "step": 0, "empowered": false}
	return side_state.arts[id]


## Live stacks per element at [param t]: {element: {n, until (the latest expiry, -1 none)}}.
static func _totals(batches: Array, t: float) -> Dictionary:
	var out := {}
	for b in batches:
		var live: bool = float(b.until) < 0.0 or float(b.until) > t
		if not live or float(b.n) <= 0.0:
			continue
		var cur: Dictionary = out.get(str(b.el), {"n": 0.0, "until": 0.0})
		cur.n = float(cur.n) + float(b.n)
		cur.until = -1.0 if float(b.until) < 0.0 or float(cur.until) < 0.0 else maxf(float(cur.until), float(b.until))
		out[str(b.el)] = cur
	return out
