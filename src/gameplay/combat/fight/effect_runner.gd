class_name EffectRunner
extends RefCounted
## The Effect interpreter (ADR-0001 decision 3; Effects GDD rules 5, 6, 8, 16), ported from the sim's
## [code]read[/code], [code]holds[/code], [code]scale[/code], [code]mod[/code], [code]fire_event[/code],
## [code]allowed[/code], [code]mark[/code], [code]bank[/code], [code]spend_banked[/code] and [code]do[/code] in the same
## order. Static functions that take the [Fight] as an argument, so neither holds the other (ADR-0001: no
## back-pointers). Events and contexts are Dictionaries with the sim's keys.


## A readable's value for side [param s] (Effects rule 5): own.* reads s, foe.* its foe; time and event.* read the
## clock and the event.
## Shared read-only empties, so a lookup's default allocates nothing (GDScript evaluates defaults eagerly, and an
## allocation takes an engine-wide lock that stops fights scaling across threads: ADR-0003 spike, 2026-11-14).
const _NONE_A: Array = []
const _NONE_D: Dictionary = {}
## The filter keys matched by equality (the sim's match()).
const _EQ_KEYS: Array = ["element", "kind", "status", "art_id", "source"]

static func read(f: Fight, s: FighterState, r: EffectDef.ReadDef, ev: Variant) -> float:
	if r.side == 2:
		if r.key == "time":
			return f.t / 1000.0
		if r.key == "cycle":   # the pulse index modulo n (Tide's 6-pulse cycle)
			@warning_ignore("integer_division")
			var pulse_index: int = f.t / f.k.pulse_ms
			return float(pulse_index % r.window_ms)
		var evd: Dictionary = ev if ev is Dictionary else {}
		var v: Variant = evd.get(r.param, 0.0)
		return float(v) if (v is float or v is int or v is bool) else 0.0
	var x: FighterState = s if r.side == 0 else f.foe_of(s)
	match r.key:
		"hp_share":
			return maxf(0.0, x.hp) / x.hp_max
		"hp_missing_share":
			return 1.0 - maxf(0.0, x.hp) / x.hp_max
		"qi_share":
			return x.qi / x.qi_max()
		"qi_missing_share":
			return 1.0 - x.qi / x.qi_max()
		"buff":
			return _count_buffs(x, r.param)
		"debuff":
			return _count(x.debuffs, r.param)
		"status":
			return x.st(r.param)
		"counter":
			var cdef: Dictionary = x.p.counter_def.get(r.param, {})
			if cdef.get("each_for") != null and float(cdef.each_for) != 0.0:
				x.counter_times[r.param] = _live_times(x.counter_times[r.param], f.t)
				return float((x.counter_times[r.param] as Array).size())
			return float(x.counters.get(r.param, 0.0))
		"distinct_statuses":
			var n: int = 0
			for sid in x.statuses:
				if x.statuses[sid].stacks > 0:
					n += 1
			var els := {}
			for d in x.debuffs:
				els[d.el] = true
			return float(n + els.size())
		"fired":
			var tot: int = 0
			for v in x.fired:
				tot += v
			return float(tot)
		"curses":
			var c: int = 0
			for sid in x.statuses:
				if x.statuses[sid].stacks > 0 and str(f.k.status.get(sid, {}).get("kind", "")) == "curse":
					c += 1
			return float(c)
		"ward_paid":
			return x.ward_paid / x.qi_max()
		"body_shield_share":
			return x.body_bar / x.hp_max
		"boss":
			return 1.0 if x.p.boss else 0.0
		"tam_ma":
			return x.tam_ma
		"evade":   # own evade in points before the cap (Hidden Moon)
			return 0.0 if f.m(x, "no_evade", null) > 0.0 else x.p.evade * 100.0 + f.m(x, "evade", null)
		"since_hit":   # seconds since a hit last landed on the side (Earthen Armour)
			return (f.t - x.last_hit_t) / 1000.0
		"hp_max_lead":   # own maximum health over the foe's, less 1, at least 0 (Mountain's Weight)
			return maxf(0.0, x.hp_max / f.foe_of(x).hp_max - 1.0)
		"state.any":
			return 1.0 if x.state != "" else 0.0
		"state":
			return 1.0 if x.state == r.param else 0.0
		"buff_elements":
			var seen := {}
			for d in x.buffs:
				if d.n > 0.0:
					seen[d.el] = true
			return float(seen.size())
		"fired_within":
			var seen_ids := {}
			for row in x.fire_log:
				if f.t - int(row[0]) <= r.window_ms and (r.what == "all" or (r.what == "tag" and (row[2] as Array).has(r.param))
						or (r.what == "group" and str(row[3]) == r.param) or (r.what == "art" and str(row[1]) == r.param)):
					seen_ids[row[1]] = true
			return float(seen_ids.size())
		"since":
			var last: int = -1
			for row in x.fire_log:
				if str(row[1]) == r.param:
					last = int(row[0])
			return (f.t - last) / 1000.0 if last >= 0 else 1e9
		"step":
			for i in x.p.arts.size():
				if str(x.p.arts[i].id) == r.param:
					return float(x.step[i])
			return 0.0
	return 0.0


## [param s]'s buff stacks of [param el], counting stacks of elements aliased to it (stack_alias).
static func _count_buffs(s: FighterState, el: String) -> float:
	var tot: float = _count(s.buffs, el)
	var alias: Dictionary = s.p.stack_alias
	if not alias.is_empty():
		for x in s.buffs:
			if alias.has(x.el) and (alias[x.el] as Array).has(el):
				tot += x.n
	return tot


static func _count(lst: Array, el: String) -> float:
	var tot: float = 0.0
	for x in lst:
		if x.el == el:
			tot += x.n
	return tot


static func _live_times(times: Array, t: int) -> Array:
	var out: Array = []
	for u in times:
		if int(u) > t:
			out.append(u)
	return out


## True when every condition holds (an "any" holds when one of its list does).
static func holds(f: Fight, s: FighterState, conds: Array, ev: Variant) -> bool:
	for c in conds:
		if c.is_any:
			var one := false
			for x in c.any:
				if holds(f, s, [x], ev):
					one = true
					break
			if not one:
				return false
			continue
		var v: float = read(f, s, c.read, ev)
		var ok: bool
		match c.op:
			"<=":
				ok = v <= c.value
			">=":
				ok = v >= c.value
			"<":
				ok = v < c.value
			">":
				ok = v > c.value
			_:
				ok = v == c.value
		if not ok:
			return false
	return true


## An Effect's scale (Effects rule 8): 1 without one; else read / per, floored unless told not to, capped, >= 0.
static func scale(f: Fight, s: FighterState, e: EffectDef, ev: Variant) -> float:
	if e.scale == null:
		return 1.0
	var n: float = read(f, s, e.scale.read, ev) / e.scale.per
	if e.scale.do_floor:
		n = floorf(n + 1e-9)
	if e.scale.has_cap:
		n = minf(n, e.scale.cap)
	return maxf(0.0, n)


## The sum of stat [param key]'s Effect mods on [param s] in context [param ctx] (the sim's mod): always-on
## Effects whose conditions hold (times their scale), timed mods from events, then banked payloads.
static func mod(f: Fight, s: FighterState, key: String, ctx: Variant) -> float:
	var always: Array = s.p.always_by_key.get(key, _NONE_A)
	if always.is_empty() and s.temp_mods.is_empty() and s.banked.is_empty() and s.state == "":
		return 0.0
	var tot: float = 0.0
	for entry in always:
		var e: EffectDef = entry[0]
		if not holds(f, s, e.conds, null):
			continue
		var n: float = scale(f, s, e, null)
		if matches(f, entry[2], ctx):
			tot += float(entry[1]) * n
	for m in s.temp_mods:
		if m.key == key and m.until > f.t and matches(f, m.filt, ctx):
			tot += m.v
	if s.state != "":
		var st_mods: Dictionary = s.p.states.get(s.state, _NONE_D).get("mods", _NONE_D)
		if st_mods.has(key):
			var v: float = float(st_mods[key])
			# Unmoved Stance: a stance's speed penalties do not apply
			if not (v < 0.0 and (key == "art_speed" or key == "basic_speed") and mod(f, s, "unmoved", null) > 0.0):
				tot += v
	for x in s.banked:
		for a in x.actions:
			if a.verb == "mod" and (a.arg as Dictionary).has(key) and matches(f, a.arg, ctx):
				tot += float(a.arg[key]) * x.n
	return tot


## The sim's match(): every filter key the context must meet (tags any-of; dtype, with an "elem" art meeting its
## element's usual type; element, kind, status, art_id equal). Mod keys and for/stack are not filters.
static func matches(f: Fight, filt: Dictionary, ctx: Variant) -> bool:
	if filt.is_empty():
		return true
	var c: Dictionary = ctx if ctx is Dictionary else _NONE_D
	for key in filt:
		var k: String = str(key)
		if k == "tags":
			var have: Array = c.get("tags", _NONE_A)
			var one := false
			for tg in filt[key]:
				if have.has(str(tg)):
					one = true
					break
			if not one:
				return false
		elif k == "not_tags":   # none of these tags (Thousand Talismans)
			var have_n: Array = c.get("tags", _NONE_A)
			for tg in filt[key]:
				if have_n.has(str(tg)):
					return false
		elif k == "is_crit":   # the hit is (or is not) a crit (Heaven's Eye)
			if bool(c.get("crit", false)) != bool(filt[key]):
				return false
		elif k == "dtype":
			var got: String = str(c.get("dtype", ""))
			var want: String = str(filt[key])
			if got != want and not (got == "elem" and str(f.k.elem_type.get(str(c.get("element", "")), "")) == want):
				return false
		elif k in _EQ_KEYS:
			if not c.has(k) or str(c[k]) != str(filt[key]):
				return false
	return true


## Raises event [param name] on side [param s] (the sim's fire_event): each listening Effect in order is banked
## when held; else it must match the filter, be allowed by its limits, hold its conditions and pass its chance,
## then it is marked and runs its actions at its scale.
static func fire(f: Fight, s: FighterState, name: String, ev: Dictionary) -> void:
	var listeners: Array = s.p.listeners.get(name, [])
	for e in listeners:
		if name == "down" and e.actions.any(func(x): return x.verb == "refuse_down" or x.verb == "last_act"):
			continue   # refusals are Down step 1 and last acts run in the step itself (Fight._defeat_check)
		if e.held:
			bank(f, s, e, ev)
			continue
		if not matches(f, e.filter, ev):
			continue
		if not allowed(f, s, e):
			continue
		if not holds(f, s, e.conds, ev):
			continue
		if e.chance < 1.0 and f.rng.randf() >= e.chance:
			continue
		var n_fire: float = scale(f, s, e, ev)
		if e.scale_per_pulse >= 0.0:   # the summed scale a pulse may give (Ever-Burning Furnace)
			n_fire = minf(n_fire, e.scale_per_pulse - float(s.eff_pulse_n.get(e.id, 0.0)))
			if n_fire <= 0.0:
				continue
			s.eff_pulse_n[e.id] = float(s.eff_pulse_n.get(e.id, 0.0)) + n_fire
		mark(f, s, e)
		f.log_effect(FightLogRow.Kind.EFFECT, s, e.id, [])
		f.depth += 1
		run(f, s, e, e.actions, n_fire, ev)
		f.depth -= 1


## Whether limits let Effect [param e] fire now: per fight, per pulse, its cooldown.
static func allowed(f: Fight, s: FighterState, e: EffectDef) -> bool:
	var st: PackedInt64Array = s.eff_state.get(e.id, PackedInt64Array([0, 0, 0, 0]))
	if not s.eff_state.has(e.id):
		s.eff_state[e.id] = st
	if e.per_fight >= 0 and st[0] >= e.per_fight:
		return false
	if e.per_pulse >= 0 and st[1] >= e.per_pulse:
		return false
	if e.per_firing >= 0 and st[3] >= e.per_firing:
		return false
	if f.t < st[2]:
		return false
	return true


## Counts a firing of [param e] against its limits.
static func mark(f: Fight, s: FighterState, e: EffectDef) -> void:
	var st: PackedInt64Array = s.eff_state[e.id]
	st[0] += 1
	st[1] += 1
	st[3] += 1
	if e.cooldown >= 0.0:
		st[2] = f.t + CombatConstants.ms(e.cooldown)
	s.eff_state[e.id] = st


## Banks a held payload (Effects rule 16): an allowed firing whose conditions hold adds its scale, up to its cap
## (without a cap the new scale replaces the old).
static func bank(f: Fight, s: FighterState, e: EffectDef, ev: Dictionary) -> void:
	if not allowed(f, s, e) or not holds(f, s, e.conds, ev):
		return
	mark(f, s, e)
	var n: float = scale(f, s, e, ev)
	f.log_effect(FightLogRow.Kind.BANK, s, e.id, [n])
	for x in s.banked:
		if x.e == e:
			x.n = n if e.held_cap < 0.0 else minf(e.held_cap, x.n + n)
			return
	var b := FighterState.Banked.new()
	b.e = e
	b.actions = e.actions
	b.n = n if e.held_cap < 0.0 else minf(e.held_cap, n)
	s.banked.append(b)


## Spends payloads held until event [param name]: their non-mod actions run at the banked scale (their mods were read
## live during the hit that spends them), and they leave the bank.
static func spend_banked(f: Fight, s: FighterState, name: String, ev: Dictionary) -> void:
	if s.banked.is_empty():
		return
	var keep: Array[FighterState.Banked] = []
	var i: int = 0
	while i < s.banked.size():   # the sim iterates the live list, so payloads banked meanwhile are seen too
		var x: FighterState.Banked = s.banked[i]
		if x.e.held_until == name:
			var acts: Array[EffectDef.ActionDef] = []
			for a in x.actions:
				if a.verb != "mod":
					acts.append(a)
			run(f, s, x.e, acts, x.n, ev)
		else:
			keep.append(x)
		i += 1
	s.banked = keep


## Runs actions (the sim's do) for side [param s] of Effect [param e] at scale [param n] on event [param ev].
static func run(f: Fight, s: FighterState, e: EffectDef, actions: Array, n: float, ev: Dictionary) -> void:
	var o: FighterState = f.foe_of(s)
	var k: CombatConstants = f.k
	for a in actions:
		var arg: Dictionary = a.arg if a.arg is Dictionary else {}
		match a.verb:
			"mod":
				if e.on != "always":
					var dur: float = float(arg.get("for", 0))
					if not bool(arg.get("stack", false)):
						# "while X in the last N s": a new firing refreshes, never stacks
						var kept: Array[FighterState.TempMod] = []
						for m in s.temp_mods:
							if m.eid != e.id:
								kept.append(m)
						s.temp_mods = kept
					var filt := {}
					for kk in ["dtype", "element", "tags", "kind"]:
						if arg.has(kk):
							filt[kk] = arg[kk]
					for key in arg:
						if f.is_mod_key(str(key)):
							var tm := FighterState.TempMod.new()
							tm.key = str(key)
							tm.v = float(arg[key]) * n
							tm.until = f.t + CombatConstants.ms(dur) if dur != 0.0 else f.t + 1
							tm.filt = filt
							tm.eid = e.id
							s.temp_mods.append(tm)
			"gain_qi":
				var base_q: float = float(ev.get("amount", 0.0)) if str(arg.get("of", "")) == "amount" else s.qi_max()
				var amt_q: float = float(arg.get("share", 0)) * base_q * n
				s.qi = minf(s.qi_use(), s.qi + amt_q)
			"heal":
				var base_h: float = float(ev.get("amount", 0.0)) if str(arg.get("of", "")) == "amount" else s.hp_max
				var amt_h: float = float(arg.get("share", 0)) * base_h * n
				if bool(arg.get("body_shield", false)):
					s.body_bar += amt_h * f.shield_hold(s)
				else:
					f.heal(s, amt_h, "", bool(arg.get("ignore_taken", false)))
			"free_hit":
				if s.trig_count >= int(k.trig_cap):
					continue
				var budget: float = k.trig_budget * maxf(s.direct_dmg, k.trig_floor_u * s.u_att) - s.trig_dmg
				if budget <= 0.0:
					continue
				s.trig_count += 1
				var before: float = o.hp
				var dt: String = str(arg.get("dtype", "phys"))
				if dt == "same":   # Echo: the same type as the hit that triggered it
					var evd: String = str(ev.get("dtype", ""))
					dt = evd if evd in CombatConstants.DTYPES else "phys"
				f.hit(s, o, float(arg.c) * n, StringName(dt), null, Fight.KIND_TRIGGER, true)
				var over: float = (before - o.hp) - budget
				if over > 0.0 and not bool(arg.get("outside_budget", false)):
					o.hp += over
					s.dealt -= over
					s.trig_dmg -= over
			"stacks":
				var tgt: FighterState = o if str(arg.get("side", "foe")) == "foe" else s
				var dur_s: float = -1.0 if arg.get("for") == null else float(arg["for"])
				f.add_stacks(s, tgt, str(arg.el), float(arg.n) * n, dur_s, tgt == s, str(arg.get("mark", "")))
			"status":
				var spec := StatusSpec.new()
				spec.id = str(arg.id)
				spec.stacks = float(arg.get("stacks", 1)) * n
				spec.chance = float(arg.get("chance", 1.0))
				for kk in arg:
					if not (str(kk) in ["id", "stacks", "chance", "side"]):
						spec.extra[str(kk)] = arg[kk]
				f.apply_status(s, o if str(arg.get("side", "foe")) == "foe" else s, spec)
			"cleanse":
				var by_status: bool = arg.get("status") != null and str(arg.status) != ""
				var curses: float = float(arg.get("curses", 0)) if arg.get("curses") != null else 0.0
				if by_status or curses != 0.0:
					var gone: Array = []
					for sid in s.statuses.keys():
						if (by_status and sid == str(arg.status)) or (curses != 0.0
								and str(k.status.get(sid, {}).get("kind", "")) == "curse"):
							gone.append(sid)
					if curses != 0.0:
						gone = gone.slice(0, int(curses * n))
					for sid in gone:
						s.statuses.erase(sid)
					if not gone.is_empty():
						fire(f, o, "cleansed", {"amount": gone.size()})
				else:
					f.cleanse(s, int(float(arg.get("n", 1)) * n), str(arg.get("el", "")))
			"refund":
				s.qi = minf(s.qi_use(), s.qi + minf(1.0, float(arg.get("share", 1.0)) * n) * float(ev.get("cost", 0.0)))
			"burn_qi":
				var base_b: float = float(ev.get("amount", 0.0)) if str(arg.get("of", "amount")) == "amount" else o.qi_max()
				var amt_b: float = float(arg.get("share", 0)) * base_b * n
				o.qi = maxf(0.0, o.qi - amt_b)
			"shield":
				if arg.get("refill") != null:   # refill toward the starting bar, never past it (Earthen Armour)
					var cap_b: float = s.p.body_shield * s.hp_max * f.shield_hold(s)
					if s.body_bar < cap_b:
						s.body_bar = minf(cap_b, s.body_bar + float(arg.refill) * cap_b * n)
				else:
					s.body_bar += float(arg.get("body", 0.0)) * s.hp_max * n * f.shield_hold(s)
			"return_damage":
				# a share of the event's amount strikes the foe through its defence (Thorns: a share of the blocked)
				var amt_r: float = float(arg.get("share", 0.0)) * float(ev.get("amount", 0.0)) * n
				if amt_r > 0.0:
					var dt_r: String = str(arg.get("dtype", "phys"))
					var got_r: float = DefencePath.defend(f, s, o, amt_r, StringName(dt_r), null,
							{"dtype": dt_r, "kind": "trigger"}, false)
					s.dealt += got_r
					f.log_effect(FightLogRow.Kind.RETURN, s, "", [amt_r, got_r, o.hp, o.qi])
			"self_hit":
				f.hit(o, s, float(arg.get("c", 0.0)) * n, StringName(str(arg.get("dtype", "phys"))), null,
						Fight.KIND_TRIGGER, true)
			"emit":
				# raise another event as if it happened (Phantom Dodge: a basic hit counts as an evade)
				if f.depth <= int(k.trig_depth):
					var ev2: Dictionary = ev.duplicate()
					ev2["emitted"] = true
					fire(f, s, str(arg.event), ev2)
			"counter":
				var cid: String = str(arg.id)
				var cdef: Dictionary = s.p.counter_def[cid]
				if cdef.get("each_for") != null and float(cdef.each_for) != 0.0:
					# each stack on its own timer; at the cap the oldest is replaced
					var times: Array = _live_times(s.counter_times[cid], f.t)
					for i in int(float(arg.get("add", 1)) * n):
						times.append(f.t + CombatConstants.ms(float(cdef.each_for)))
					times.sort()
					var tcap: int = int(cdef.get("cap", 0)) if cdef.get("cap") != null else 0
					s.counter_times[cid] = times.slice(maxi(0, times.size() - tcap)) if tcap > 0 else times
					continue
				var v: float = float(s.counters[cid]) + float(arg.get("add", 1)) * n
				if arg.get("set") != null:
					v = float(arg.set)
				var ccap: Variant = cdef.get("cap")
				s.counters[cid] = maxf(0.0, v if ccap == null else minf(float(ccap), v))
			"timer":
				var tgt_t: FighterState = s if str(arg.get("side", "own")) == "own" else o
				var by: float = float(arg.by) * n
				if tgt_t == o and by > 0.0 and f.m(o, "delay_immune", null) > 0.0:
					continue   # Immovable Mountain: timer delays never land
				if tgt_t == o:
					# a delay: falloff within the window, timer resistance (R1)
					var recent: Array = []
					for x in o.delays:
						if f.t - int(x) < k.delay_window_ms:
							recent.append(x)
					o.delays = recent
					var tr_m: float = f.m(o, "timer_resist", null)
					by = by * pow(k.delay_falloff, float(o.delays.size())) * (1.0 - (o.p.timer_resist + tr_m) / 100.0)
					o.delays.append(f.t)
				var which: String = str(arg.get("which", "all"))
				var idx: Array = []
				for i in tgt_t.ready.size():
					if not (tgt_t == s and int(ev.get("slot", -1)) == i and which == "others"):
						idx.append(i)
				if which == "longest" and not idx.is_empty():
					var best: int = idx[0]
					for i in idx:
						if tgt_t.ready[i] > tgt_t.ready[best]:
							best = i
					idx = [best]
				elif which == "next" and not idx.is_empty():
					var first: int = idx[0]   # least time left, the earlier slot on a tie (Effects rule 6)
					for i in idx:
						if tgt_t.ready[i] < tgt_t.ready[first]:
							first = i
					idx = [first]
				for i in idx:
					var last_ok: int = f.t + k.cooldown_min_ms if tgt_t == s else 0
					tgt_t.ready[i] = maxi(last_ok if by < 0.0 else 0, tgt_t.ready[i] + CombatConstants.ms(by))
			"state":
				var set_to: String = str(arg.set) if arg.get("set") != null else ""
				s.state = "" if (bool(arg.get("toggle", false)) and s.state == set_to) else set_to
			"summon":
				var cd_ms: int = CombatConstants.ms(maxf(k.cooldown_min, float(arg.get("cd", k.basic_cooldown))))
				s.summons.append([float(arg.get("c", k.summon_c)) * n, StringName(str(arg.get("dtype", "phys"))), cd_ms,
						f.t + cd_ms, f.t + CombatConstants.ms(float(arg.get("for", k.summon_for)))])
			"fire_art":
				if f.depth > int(k.trig_depth):
					continue
				var which_a: String = str(arg.get("which", "last"))
				var ai: int = -1
				if which_a == "longest":
					for i in s.p.arts.size():
						var x: ArtDef = s.p.arts[i]
						if x.c != 0.0 and x.soul_pct == 0.0 and (ai < 0 or x.cd > s.p.arts[ai].cd):
							ai = i
				elif which_a == "last":
					ai = s.last_art
				else:
					for i in s.p.arts.size():
						if str(s.p.arts[i].id) == which_a:
							ai = i
							break
				if ai < 0:
					continue
				var fa: ArtDef = s.p.arts[ai]
				if fa.c != 0.0 and fa.soul_pct == 0.0:
					f.hit(s, o, fa.c * float(arg.get("share", 1.0)) * n, fa.dtype, fa, Fight.KIND_ART)
			"consume":
				var tgt_c: FighterState = o if str(arg.get("side", "foe")) == "foe" else s
				var is_debuff: bool = str(arg.get("kind", "debuff")) == "debuff"
				var lst: Array[FighterState.StackBatch] = tgt_c.debuffs if is_debuff else tgt_c.buffs
				Fight._sort_by_until(lst)
				var left: float = float(int(arg.get("n", 1 << 30)))
				var got: float = 0.0
				for x in lst.duplicate():
					if left <= 0.0:
						break
					if x.el != str(arg.el):
						continue
					var kk: float = minf(left, x.n)
					x.n -= kk
					left -= kk
					got += kk
					if x.n <= 0.0:
						lst.erase(x)
				if is_debuff:
					tgt_c.touch_debuffs()
				else:
					tgt_c.touch_buffs()
				if not a.then.is_empty():
					run(f, s, e, a.then, got / float(arg.get("per", 1)), ev)
			"strip":
				var left_s: float = float(int(float(arg.get("n", 1)) * n))
				var pile: String = str(arg.get("el", "")) if arg.get("el") != null else ""
				if pile == "":
					# the largest pile; a tie goes to the pile listed first (both engines, 2026-11-14)
					var best_n: float = -1.0
					for x in o.buffs:
						var cnt: float = _count_buffs(o, x.el)
						if cnt > best_n:
							best_n = cnt
							pile = x.el
				Fight._sort_by_until(o.buffs)
				var taken: float = 0.0
				for x in o.buffs.duplicate():
					if left_s <= 0.0:
						break
					if x.el != pile:
						continue
					var ks: float = minf(left_s, x.n)
					x.n -= ks
					left_s -= ks
					taken += ks
					if bool(arg.get("steal", false)):
						f.steal_batch(s, x, ks)
					if x.n <= 0.0:
						o.buffs.erase(x)
				o.touch_buffs()
				if taken != 0.0 and bool(arg.get("as_status", false)):
					# Unmaking Glass: each stripped stack counts as a status landed
					fire(f, s, "status_applied", {"element": pile, "stacks": taken, "strip": true})
			"refresh":
				var tgt_r: FighterState = o if str(arg.get("side", "foe")) == "foe" else s
				var lst_r: Array = tgt_r.debuffs if str(arg.get("kind", "debuff")) == "debuff" else tgt_r.buffs
				var el_r: String = str(arg.get("el", "")) if arg.get("el") != null else ""
				for x in lst_r:
					if x.src_idx != f.side_index(s) or (el_r != "" and x.el != el_r):
						continue
					if bool(arg.get("hold", false)):
						x.until = -1
					elif arg.get("at_least") != null:   # keep it at least this long from now (Fire Feeds Fire)
						if x.until != -1:
							x.until = maxi(x.until, f.t + CombatConstants.ms(float(arg.at_least)))
					elif x.length != -1 and x.until != -1:
						x.until = f.t + x.length
			"protect":
				s.protect[str(arg.el)] = {"for_first": arg.get("for_first"), "swap_buff": bool(arg.get("swap_buff", false))}
			"refuse_down", "last_act":
				pass   # read by the Down step
			"store_damage":
				var inj: FighterState.StatusState = o.statuses.get("internal_injury")
				if inj == null:
					var spec := StatusSpec.new()
					spec.id = "internal_injury"
					spec.extra["every"] = arg.get("every", k.injury_every)
					f.apply_status(s, o, spec)
					inj = o.statuses["internal_injury"]
				inj.stored += float(arg.get("share", 0.0)) * float(ev.get("amount", 0.0)) * n
			"bank":
				pass
			_:
				push_error("EffectRunner: action %s has no branch (Effect %s)" % [a.verb, e.id])
