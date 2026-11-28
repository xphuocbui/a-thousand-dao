class_name Fight
extends RefCounted
## One fight between two compiled fighters on a millisecond timeline (ADR-0001 decision 1; Combat GDD rule 10).
## Ported from the sim's [code]Fight[/code] (tools/design/combat_sim/engine.py) in the same operation order; the
## parity suite (tests/parity) holds the two to 1e-6 on chance-free fixtures and statistically on chancy ones.
##
## Pure logic: no Node, scene, session or World DB. It reads its two [FighterProfile]s (never writing to them), the
## [CombatConstants] and one seeded [RandomNumberGenerator]. Slices 1-4a: the pulse loop (element and status ticks,
## regeneration with Stagnation, overflow, the cleansing ward, fatigue, expiries and lockouts, timed mods, counter
## decay, per-pulse resets, shield recharge), arts on cooldown with guards, charges, Slowed Time, Silence, the soul
## lockout and every cost path; heal, restore, buff and cleanse arts; cast wards; the basic attack; companions; evade
## and crit; damage layers; hit damage, conversion, the Soul part and the [DefencePath]; debuffs and statuses on hit;
## soul attacks; Effect mods at every stat the sim reads them and Effect events where the sim raises them
## ([EffectRunner]); trigger hits within their budget. The Down step, stances, timers, summons and multi-step arts
## come in later slices; the loader refuses what needs them.
##
## Usage:
## [codeblock]
## var f := Fight.new(profile_a, profile_b, k, fight_seed)
## var r: FightResult = f.run()
## [/codeblock]

## Who acts first when both sides act at the same moment. COIN: a coin from the fight's random stream at each pulse
## and each action step (the game's rule, ADR-0001 amended 2026-11-13). FIXED: side A first, for exact parity tests.
enum Order { COIN, FIXED }

const KIND_ART := &"art"
const KIND_BASIC := &"basic"
const KIND_COMPANION := &"companion"
const KIND_TRIGGER := &"trigger"
## Sorts batches with no expiry after every timed one, as the sim's 1 << 40.
const _NO_EXPIRY_KEY := 1 << 40
## How long fired arts stay in the fire log (the horizon of fired_within reads), as the sim.
const FIRE_LOG_MS := 30000
## The layer mod keys, x1..x5.
const LAYER_KEYS := ["L1", "L2", "L3", "L4", "L5"]

## Side A and side B. Public for tests and the parts that receive the fight as an argument.
var a: FighterState
var b: FighterState
## The current time in ms.
var t: int = 0
## The constants and the fight's one random stream (read by [EffectRunner] and [DefencePath]).
var k: CombatConstants
var rng := RandomNumberGenerator.new()
## The request's kept tags (REQUEST_TAGS, e.g. tribulation), read as tag.<name> (Combat rule 12, AC-CB-104).
var tags: Array = []
## Reused one-key context for defence reads (DefencePath), and the hit context when no Effect exists: nothing keeps
## them, so reuse avoids an allocation per hit (allocations serialise threads: ADR-0003 spike, 2026-11-14).
var dt_ctx: Dictionary = {}
var _bare_ctx: Dictionary = {}
## The depth of events Effects are raising now (Combat Formulas G).
var depth: int = 0
## Counts hits and ticks, so a per-hit ward pays one fee per hit (all its parts) and one per tick.
var hit_id: int = 0
## No healing in this fight (Combat Defence & Healing rule 19, e.g. Heavenly Tribulation waves).
var no_heal: bool = false

var _last_dmg_layer: PackedInt32Array = PackedInt32Array([-1, -1])
var _order: Order
var _log_enabled: bool
var _log: Array[FightLogRow] = []
var _mod_keys: Dictionary = {}
## True when either side has any Effects or art guards; without them every Effect read is 0 and no event has a listener, so
## the hit path skips building contexts and events (the results are identical).
var _fx: bool = false


## Sets up both sides and their opening timers, as the sim's Fight does. [param fight_seed] seeds the fight's only
## random stream (the caller derives it from the session stream).
func _init(profile_a: FighterProfile, profile_b: FighterProfile, constants: CombatConstants, fight_seed: int,
		order: Order = Order.COIN, log_enabled: bool = false) -> void:
	k = constants
	rng.seed = fight_seed
	_order = order
	_log_enabled = log_enabled
	for x in k.mod_keys:
		_mod_keys[str(x)] = true
	a = FighterState.new(profile_a, "A", k)
	b = FighterState.new(profile_b, "B", k)
	for st in [a, b]:
		if st.more_live:   # stack_more reads Effect mods inside the buff sums: a weak back-reference (no cycle)
			st.fight_ref = weakref(self)
	_fx = not (profile_a.effects.is_empty() and profile_b.effects.is_empty())
	for p in [profile_a, profile_b]:
		for art in p.arts:
			if not art.guards.is_empty() or not art.steps.is_empty() or not art.empower.is_empty():   # these read the fire log
				_fx = true
	_open(a)
	_open(b)


func _open(s: FighterState) -> void:
	var p: FighterProfile = s.p
	for i in p.arts.size():
		var art: ArtDef = p.arts[i]
		# the opening cooldown honours art speed (scoped to the art), then opening haste (Combat 13)
		var hz: float = 1.0 if m(s, "speed_locked", null) > 0.0 else 1.0 + (p.art_speed_pct + m(s, "art_speed", art.ctx) + art.node_speed_pct) / 100.0
		var cd: float = maxf(k.cooldown_min, art.cd / hz)
		var first: float = maxf(k.cooldown_min, cd / (1.0 + (p.opening_haste_pct + m(s, "opening_haste", null)) / 100.0))
		s.ready[i] = CombatConstants.ms(first)
	s.basic_ready = CombatConstants.ms(basic_cd(s))
	for j in p.companions.size():
		s.comp_ready[j] = CombatConstants.ms(p.companions[j].cd)
	s.body_bar *= shield_hold(s)


## Runs the fight to a Down or the time limit and returns the result.
func run() -> FightResult:
	var next_pulse: int = k.pulse_ms
	var limit: int = k.time_limit_ms
	_event(a, "fight_start", {})
	_event(b, "fight_start", {})
	while true:
		var tn: int = next_pulse
		tn = _earliest(a, tn)
		tn = _earliest(b, tn)
		if tn > limit:
			break
		t = tn
		if t >= next_pulse:
			if _a_first():
				pulse(a)
				pulse(b)
			else:
				pulse(b)
				pulse(a)
			next_pulse += k.pulse_ms
		if _a_first():
			act(a)
			act(b)
		else:
			act(b)
			act(a)
		escape_rolls()
		if a.fled or b.fled:   # a success ends the fight there (Combat rule 10)
			break
		_defeat_check()
		if a.down or b.down:
			break
	return _result()


## Escape channels ending this instant, after both sides' hits, A (the requesting side) first (Combat rule 10,
## Formulas I): a side at 0 or below does not flee; Bound fails it with no draw; otherwise p is drawn. As
## engine.py escape_rolls.
func escape_rolls() -> void:
	for s in [a, b]:
		if s.channel_until < 0 or t < s.channel_until:
			continue
		s.channel_until = -1
		if s.hp <= 0.0:
			continue
		var o: FighterState = foe_of(s)
		var ok: bool = false
		if s.st("bound") <= 0.0:
			var lock: float = 1.0 if m(o, "lock", null) > 0.0 else 0.0
			var p: float = minf(k.escape_max, maxf(k.escape_min, s.channel_e + k.escape_realm_step
					* float(s.p.realm - o.p.realm) - k.escape_lock_penalty * lock + m(s, "escape", null) / 100.0))
			ok = rng.randf() < p
		if _log_enabled:
			_row(FightLogRow.Kind.ESCAPE, s.label, &"", &"fled" if ok else &"failed", [])
		if ok:
			s.fled = true
		else:
			_event(s, "escape_failed", {})


## The next event time of [param s] before [param tn]: arts ready after now, the basic attack, companions.
func _earliest(s: FighterState, tn: int) -> int:
	if s.channel_until >= t and s.channel_until < tn:   # an escape channel ending
		tn = s.channel_until
	if s.window_on:   # an extended last act: only its rounds wake the loop; its own timers stand still
		if s.window_next >= t and s.window_next < tn:
			tn = s.window_next
		return tn
	for r in s.ready:
		if r > t and r < tn:
			tn = r
	if s.basic_ready >= t and s.basic_ready < tn:
		tn = s.basic_ready
	for c in s.comp_ready:
		if c > t and c < tn:
			tn = c
	return tn


func _a_first() -> bool:
	if _order == Order.FIXED:
		return true
	return rng.randf() < 0.5


func _side(idx: int) -> FighterState:
	return a if idx == 0 else b


func _idx(s: FighterState) -> int:
	return 0 if s == a else 1


## The side index of [param s] (0 = A, 1 = B), as stack batches and statuses name their source.
func side_index(s: FighterState) -> int:
	return _idx(s)


## Gives [param s] a stolen buff batch of [param n] stacks shaped like [param x] (the strip action's steal): same
## element and expiry, its length the time left, [param s] its source; its power reads [param s]'s profile.
func steal_batch(s: FighterState, x: FighterState.StackBatch, n: float) -> void:
	var nb := FighterState.StackBatch.new()
	nb.el = x.el
	nb.n = n
	nb.until = x.until
	nb.src_idx = _idx(s)
	nb.src_p = s.p
	nb.length = -1 if x.until == -1 else x.until - t
	nb.power = StackMath.stack_power(k, s.p, x.el, "buff")
	s.buffs.append(nb)
	s.touch_buffs()


## The other side.
func foe_of(s: FighterState) -> FighterState:
	return b if s == a else a


## Whether [param key] is in the Effect vocabulary's mod keys.
func is_mod_key(key: String) -> bool:
	return _mod_keys.has(key)


## Whether [param s] has any mod source now (always-on Effect mods, timed mods, banked payloads, a stance).
func has_mods(s: FighterState) -> bool:
	return not (s.p.always_by_key.is_empty() and s.temp_mods.is_empty() and s.banked.is_empty() and s.state == "")


## The Effect mods on [param s] for stat [param key] in context [param ctx] (0 when it has none).
func m(s: FighterState, key: String, ctx: Variant) -> float:
	if not has_mods(s):
		return 0.0
	return EffectRunner.mod(self, s, key, ctx)


## Whether any Effect of [param s] listens to [param name].
func listens(s: FighterState, name: String) -> bool:
	return s.p.listeners.has(name)


func _event(s: FighterState, name: String, ev: Dictionary) -> void:
	if s.p.listeners.has(name):
		EffectRunner.fire(self, s, name, ev)


## The share every body-shield bar and gain holds (Glass Meridians: half): 1 + shield_hold, at least 0.
func shield_hold(s: FighterState) -> float:
	return maxf(0.0, 1.0 + m(s, "shield_hold", null))


## Formations rule 6: the art in slot [param i] fired, so each feed from it takes its seconds off a cooling target's
## timer, floored at cooldown_min and never raising a timer already below it (one hop: a fed timer is never ready in
## the same instant). Logged as a FEED row: the source and target slots and the ms taken off.
func _feed(s: FighterState, i: int) -> void:
	for f in s.p.feeds:
		if int(f[0]) != i:
			continue
		var j: int = int(f[1])
		var rem: int = s.ready[j] - t
		if rem <= 0:
			continue   # ready already: nothing changes
		var new_rem: int = mini(rem, maxi(rem - int(f[2]), k.cooldown_min_ms))
		s.ready[j] = t + new_rem
		if _log_enabled:
			_row(FightLogRow.Kind.FEED, s.label, &"", s.p.arts[j].id, [float(i), float(j), float(rem - new_rem)])


## An art's speed multiplier as act() reads it (1 when speed_locked: Immovable Mountain).
func art_speed(s: FighterState, art: ArtDef) -> float:
	if m(s, "speed_locked", null) > 0.0:
		return 1.0
	return 1.0 + s.bsum("speed") + s.p.art_speed_pct / 100.0 + m(s, "art_speed", art.ctx) / 100.0 + art.node_speed_pct / 100.0


## Overheat: the art speed that cooldown_min clips on this art, in points, up to the mod's cap (added to L5).
func overheat(s: FighterState, art: ArtDef, ctx: Variant) -> float:
	var cap: float = m(s, "overheat", ctx)
	if cap <= 0.0 or art == null or art.cd <= 0.0:
		return 0.0
	var clipped: float = (art_speed(s, art) - art.cd / k.cooldown_min) * 100.0
	return minf(cap, maxf(0.0, clipped))


## The basic attack's cooldown in seconds (Combat A2: basic speed).
func basic_cd(s: FighterState) -> float:
	return maxf(k.cooldown_min, k.basic_cooldown / (1.0 + (s.p.basic_speed_pct + m(s, "basic_speed", null)) / 100.0))


## The Slowed Time factor on [param s]'s cooldowns (Effects AC-EF-72): 1 + slowed_time_pct per stack (up to the
## status's cap), scaled by curse_effect, less Slowed Time resistance.
func slow(s: FighterState) -> float:
	if s.statuses.is_empty():
		return 1.0
	var n: float = minf(s.st("slowed_time"), float(k.slowed_cap))
	var resist: float = 1.0 - (s.p.timer_resist + m(s, "timer_resist", null)) / 100.0
	var out: float = 1.0 + k.slowed_time_pct * n * (curse_scale(s, "slowed_time") if n > 0.0 else 1.0) * resist
	var dk: float = s.st("drunk")
	if dk > 0.0:   # Drunk (Effects Status Catalogue, 2026-11-26): its own slow per stack beside Slowed Time
		out += float(k.status.drunk.slow) * dk * curse_scale(s, "drunk") * resist
	return out


## The offence multiplier M with layer mods (Combat Formulas A): without layer mods or a seal, the fighter's M (x
## the art's); otherwise M scaled by the layer product with the mods (and the seal) over the plain product, x1
## soft-capped, each layer capped. Sealed Meridian (Status Catalogue) is on the SEALED fighter: one named layer L2-L5
## counts as 1.0 when it attacks (fixed 2026-11-14 in both engines; a build without layers has nothing to remove).
func layers_m(s: FighterState, art: ArtDef, ctx: Variant) -> float:
	var mm: float = art.m_mult if art != null else 1.0
	var seal: int = s.statuses["sealed_meridian"].layer if s.st("sealed_meridian") > 0.0 else -1
	var sealed_bites: bool = seal >= 0 and not s.p.layers.is_empty()
	if not has_mods(s) and not sealed_bites:
		return s.p.m * mm
	var adds := PackedFloat64Array()
	var any := false
	for i in 5:
		var v: float = m(s, LAYER_KEYS[i], ctx) if has_mods(s) else 0.0
		adds.append(v)
		if v != 0.0:
			any = true
	var heat: float = overheat(s, art, ctx) if has_mods(s) else 0.0
	if heat != 0.0:
		adds[4] += heat
		any = true
	if not any and not sealed_bites:
		return s.p.m * mm
	var base: PackedFloat64Array = s.p.layers if not s.p.layers.is_empty() else PackedFloat64Array([0, 0, 0, 0, 0])
	var nu := PackedFloat64Array()
	for i in 5:
		nu.append(base[i] + adds[i])
	return s.p.m * mm * _m_of(nu, seal) / _m_of(base, -1)


func _m_of(x: PackedFloat64Array, seal: int) -> float:
	var prod: float = 1.0
	for i in 5:
		var xi: float = x[i]
		if i == 0 and xi > k.l1_soft[0]:
			xi = k.l1_soft[0] + k.l1_soft[1] * (xi - k.l1_soft[0])
		if seal >= 0 and i >= 1 and i == seal:
			xi = 0.0
		prod *= 1.0 + minf(xi, k.layer_caps[i]) / 100.0
	return prod


## One pulse for [param s] (Combat rule 10; Combat Defence & Healing; Status Catalogue; Effects): element debuff
## ticks, status ticks, regeneration (Stagnation dampens; overflow raised), health regeneration, the cleansing ward,
## fatigue, expiries (with lockouts), timed mods, counter decay, per-pulse resets, shield recharge, the pulse event.
## Public for mechanism tests.
func pulse(s: FighterState) -> void:
	if s.window_on:   # an extended last act: the side is out of the fight but for its free hits
		return
	# element ticks (Burn, Poison), each batch at its source's offence and stack power
	for x in (s.debuffs.duplicate() if not s.debuffs.is_empty() else EffectRunner._NONE_A):
		var tab: Dictionary = k.debuff.get(x.el, EffectRunner._NONE_D)
		var c: float = float(tab.get("burn", 0.0)) + float(tab.get("poison", 0.0))
		if c != 0.0:
			var src: FighterState = _side(x.src_idx)
			var amount: float = src.u_att * c * x.n * src.p.m * (1.0 + src.bsum("dmg")) \
					* _supp(src, s, m(src, "pierce", null) / 100.0) * x.power
			tick(src, s, amount, StringName(str(k.tick_type[x.el])), x.el)
	# status ticks
	for sid in (s.statuses.keys() if not s.statuses.is_empty() else EffectRunner._NONE_A):
		var stt: FighterState.StatusState = s.statuses[sid]
		if not k.status.has(sid):   # Internal Injury is not a catalogue status: released below
			continue
		var d: Dictionary = k.status[sid]
		if str(d.kind) == "tick" and stt.stacks > 0.0:
			var src2: FighterState = _side(stt.src_idx)
			var amount2: float = src2.u_att * float(d.c_tick) * stt.stacks * src2.p.m * _supp(src2, s, m(src2, "pierce", null) / 100.0)
			if bool(d.get("on_qi", false)):
				s.qi = maxf(0.0, s.qi - amount2)
				src2.dealt += amount2
				if _log_enabled:
					_row(FightLogRow.Kind.QI_TICK, src2.label, &"", StringName(sid), [amount2, s.hp, s.qi])
			else:
				tick(src2, s, amount2, StringName(str(d.dtype)), sid)
			if d.get("standing") != null and float(d.standing) != 0.0:
				var fee: float = float(d.standing) * src2.qi_max()
				if src2.qi < fee:
					stt.stacks = 0.0
				else:
					src2.qi -= fee
	# stored damage released (R26 Internal Injury)
	var inj: FighterState.StatusState = s.statuses.get("internal_injury")
	if inj != null and inj.stored > 0.0 and t >= inj.next_release:
		var amt: float = inj.stored
		inj.stored = 0.0
		inj.next_release = t + CombatConstants.ms(inj.every)
		s.hp -= amt
		_side(inj.src_idx).dealt += amt
		_note_dmg(s, 0)
	# regeneration; Stagnation dampens both pools by regen_dampen % per stack
	var stag_n: float = s.st("stagnation")
	var stag: float = 1.0 + stag_n * k.stagnation_dampen * (curse_scale(s, "stagnation") if stag_n > 0.0 else 1.0) / 100.0
	var kk: float = k.regen_k
	var bonus: float = s.p.regen_bonus + s.bsum("regen") + m(s, "regen", null)
	var regen: float = s.qi_max() * (k.regen_base + kk * log(1.0 + maxf(0.0, bonus) / kk)) / stag
	if m(s, "no_regen", null) > 0.0:   # Water Table's closing: no linh lực regeneration in fights
		regen = 0.0
	var room: float = s.qi_use() - s.qi
	if regen > room and listens(s, "overflow"):
		_event(s, "overflow", {"amount": regen - room, "share": (regen - room) / s.qi_max()})
	s.qi = minf(s.qi_use(), s.qi + regen)
	var hreg: float = s.hp_max * (s.p.hregen + s.bsum("hregen") + m(s, "hregen", null)) * s.p.bs_mult / stag \
			* (1.0 + m(s, "hregen_inc", null) / 100.0)
	if hreg > 0.0:
		heal(s, hreg, "regen")
	# the cleansing ward: stacks per pulse for a fee each, earliest expiry first; then a share of every batch
	var n_cl: int = s.p.cleanse_pulse
	while n_cl > 0 and not s.debuffs.is_empty():
		_sort_by_until(s.debuffs)
		var j_cl: int = -1
		for ix in s.debuffs.size():
			if not held_fast(s.debuffs[ix]):
				j_cl = ix
				break
		if j_cl < 0:   # only talisman stacks held fast are left (2026-11-26)
			break
		var fee_cl: float = s.p.cleanse_cost * s.qi_max()
		if s.qi < fee_cl:
			break
		s.qi -= fee_cl
		s.debuffs[j_cl].n -= 1.0
		if s.debuffs[j_cl].n <= 0.0:
			s.debuffs.remove_at(j_cl)
		s.touch_debuffs()
		n_cl -= 1
	if s.p.cleanse_share != 0.0:
		var kept: Array[FighterState.StackBatch] = []
		for x in s.debuffs:
			if not held_fast(x):
				x.n *= (1.0 - s.p.cleanse_share)
			if x.n >= k.cleanse_min_stacks:
				kept.append(x)
		s.debuffs = kept
		s.touch_debuffs()
	# fatigue
	if t >= k.fatigue_start_ms:
		# pulses fall on whole seconds, so this is a whole number and Python's half-to-even round() never differs
		var nf: int = roundi(float(t - k.fatigue_start_ms) / 1000.0)
		var f: float = s.u * k.fatigue_units * pow(float(1 + nf), k.fatigue_pow) * (s.g if k.fatigue_by_realm else 1.0)
		s.hp -= f
		s.fat += f
		if f > 0.0:
			_note_dmg(s, 3)
	# expiries: stack batches, then statuses (a status with a lockout cannot return until it ends)
	if not s.buffs.is_empty():
		s.buffs = _live(s.buffs)
		s.touch_buffs()
	if not s.debuffs.is_empty():
		# a debuff batch that runs out on its own is announced to its source (Wildfire), after the batches are removed
		var ended: Array[FighterState.StackBatch] = []
		for x in s.debuffs:
			if x.until != -1 and x.until <= t:
				ended.append(x)
		s.debuffs = _live(s.debuffs)
		s.touch_debuffs()
		for x in ended:
			if x.n > 0.0:
				_event(_side(x.src_idx), "batch_ended", {"element": x.el, "stacks": x.n, "kind": "debuff",
						"rekindled": 1.0 if x.mark == "rekindled" else 0.0})
	for sid in (s.statuses.keys() if not s.statuses.is_empty() else EffectRunner._NONE_A):
		var stt2: FighterState.StatusState = s.statuses[sid]
		if not stt2.each.is_empty():   # Drunk: each stack ends on its own time
			var keep_e: Array = []
			var n_e: float = 0.0
			var last_e: int = 0
			var open_e: bool = false
			for bt in stt2.each:
				if int(bt[1]) < 0 or int(bt[1]) > t:
					keep_e.append(bt)
					n_e += float(bt[0])
					if int(bt[1]) < 0:
						open_e = true
					else:
						last_e = maxi(last_e, int(bt[1]))
			stt2.each = keep_e
			stt2.stacks = n_e
			if keep_e.is_empty():
				end_status(s, sid)
			else:
				stt2.until = -1 if open_e else last_e
			continue
		if stt2.until != -1 and stt2.until <= t:
			end_status(s, sid)
	if not s.temp_mods.is_empty():
		var keep_m: Array[FighterState.TempMod] = []
		for tm in s.temp_mods:
			if tm.until > t:
				keep_m.append(tm)
		s.temp_mods = keep_m
	# self-counter decay
	for cid in s.p.counter_def:
		var dec: float = float(s.p.counter_def[cid].get("decay_per_pulse", 0))
		if dec != 0.0:
			s.counters[cid] = maxf(0.0, float(s.counters[cid]) - dec)
		var dsh: float = float(s.p.counter_def[cid].get("decay_share", 0))
		if dsh != 0.0:   # decay by a share of the count each pulse (world-depth Stage 5)
			s.counters[cid] = float(s.counters[cid]) * maxf(0.0, 1.0 - dsh)
		var up: Variant = s.p.counter_def[cid].get("upkeep")
		if up != null:
			upkeep(s, cid, up)
	check_cross(s, {"kind": "pulse"})
	if s.has_loss_prev:   # this pulse's net losses, for lost_last
		s.loss_log.append([t, maxf(0.0, s.loss_prev_hp - s.hp), maxf(0.0, s.loss_prev_qi - s.qi)])
		var keep_l: Array = []
		for x in s.loss_log:
			if t - int(x[0]) < k.lost_last_keep_ms:
				keep_l.append(x)
		s.loss_log = keep_l
	s.loss_prev_hp = s.hp
	s.loss_prev_qi = s.qi
	s.has_loss_prev = true
	# per-pulse limits reset
	s.trig_count = 0
	s.trig_dmg = 0.0
	s.direct_dmg = 0.0
	s.avoided = 0
	for eid in s.eff_state:
		var es: PackedInt64Array = s.eff_state[eid]
		es[1] = 0
		s.eff_state[eid] = es
	if not s.eff_pulse_n.is_empty():
		s.eff_pulse_n.clear()
	# ward shield recharge: standing bars refill a share after a quiet spell (Combat Defence & Healing rule 9)
	for w in s.wshields:
		var cap: float = w.def.size * s.qi_base
		if w.def.standing and t - w.quiet_since >= k.recharge_delay_ms and w.left < cap:
			w.left = minf(cap, w.left + k.shield_recharge * cap)
			if w.def.pieces > 1:
				w.pieces_left = mini(w.def.pieces, w.pieces_left + 1)
	if _log_enabled:
		_row(FightLogRow.Kind.PULSE, s.label, &"", &"", [s.hp, s.qi])
	if listens(s, "pulse"):
		_event(s, "pulse", {})


func _live(batches: Array[FighterState.StackBatch]) -> Array[FighterState.StackBatch]:
	var out: Array[FighterState.StackBatch] = []
	for x in batches:
		if x.until == -1 or x.until > t:
			out.append(x)
	return out


## A stable sort by expiry, batches with none last (the sim's list.sort is stable; Array.sort_custom is not).
static func _sort_by_until(batches: Array[FighterState.StackBatch]) -> void:
	for i in range(1, batches.size()):
		var x: FighterState.StackBatch = batches[i]
		var key: int = x.until if x.until != -1 else _NO_EXPIRY_KEY
		var j: int = i - 1
		while j >= 0:
			var kj: int = batches[j].until if batches[j].until != -1 else _NO_EXPIRY_KEY
			if kj <= key:
				break
			batches[j + 1] = batches[j]
			j -= 1
		batches[j + 1] = x


## Stops [param s]'s clock for [param d] ms (Effects rule 6, 2026-11-26): its art timers, basic attack, companions,
## soul attack, summons and the stack, status and charge timers on it move [param d] later; an art already ready
## waits too (slice 2a). Returns what it moved, [holder, key, index, new value], for [method restart_clock]: an
## Object property (index -1), an index of a packed-array property (packed arrays copy on write, so the record
## names the owner), or an index of a plain Array (key ""). As engine.py.
func stop_clock(s: FighterState, d: int) -> Array:
	var rec: Array = []
	if d <= 0:
		return rec
	for i in s.ready.size():
		s.ready[i] = maxi(s.ready[i], t) + d
		rec.append([s, "ready", i, s.ready[i]])
	for i in s.comp_ready.size():
		s.comp_ready[i] = maxi(s.comp_ready[i], t) + d
		rec.append([s, "comp_ready", i, s.comp_ready[i]])
	s.basic_ready = maxi(s.basic_ready, t) + d
	rec.append([s, "basic_ready", -1, s.basic_ready])
	s.soul_ready = maxi(s.soul_ready, t) + d
	rec.append([s, "soul_ready", -1, s.soul_ready])
	for sm in s.summons:
		sm[3] = int(sm[3]) + d
		rec.append([sm, "", 3, sm[3]])
		sm[4] = int(sm[4]) + d
		rec.append([sm, "", 4, sm[4]])
	for lst in [s.buffs, s.debuffs]:
		for x in lst:
			if x.until >= 0:   # -1: a batch for the whole fight
				x.until += d
				rec.append([x, "until", -1, x.until])
	for sid in s.statuses:
		var stt: FighterState.StatusState = s.statuses[sid]
		if stt.until >= 0:
			stt.until += d
			rec.append([stt, "until", -1, stt.until])
		for bt in stt.each:   # Drunk's stacks, each on its own time
			if int(bt[1]) >= 0:
				bt[1] = int(bt[1]) + d
				rec.append([bt, "", 1, bt[1]])
	for cid in s.counter_times:   # self-counter charges on their own timers (Effects rule 8)
		var moved: Array = []
		for u in s.counter_times[cid]:
			moved.append(int(u) + d)
		s.counter_times[cid] = moved
	return rec


## Gives back [param left] ms of a clock stop that ended early: each timer in [param rec] comes [param left]
## sooner, unless something set it since; never earlier than now. As engine.py restart_clock.
func restart_clock(rec: Array, left: int) -> void:
	for r in rec:
		var holder: Variant = r[0]
		var key: String = r[1]
		var idx: int = r[2]
		var val: int = int(r[3])
		var back: int = maxi(t, val - left)
		if holder is Array:
			if int(holder[idx]) == val:
				holder[idx] = back
		elif idx < 0:
			if int(holder.get(key)) == val:
				holder.set(key, back)
		else:
			var arr: Variant = holder.get(key)   # a packed array: write the whole property back
			if idx < arr.size() and int(arr[idx]) == val:
				arr[idx] = back
				holder.set(key, arr)


## Broken and Wounded (Combat rule 25, Formulas L): the first time this fight [param s]'s health falls to
## broken_threshold of its maximum or below, it is Wounded and its foe has Broken it; once a fight. As engine.py.
## Move the Sickness (2026-11-26): [param s]'s debuff batches, oldest first, then its statuses, soonest end first,
## move to the foe as its own with the time they had left; each stack costs [param per] of its maximum linh lực and
## the move stops at the first it cannot pay; a moved curse needs a free curse slot on the foe, or it stays.
## As engine.py move_own_debuffs.
func move_own_debuffs(s: FighterState, per: float) -> void:
	var o: FighterState = foe_of(s)
	var fee: float = per * s.qi_max()
	# oldest first; ties keep their list order (sort_custom is not stable, the sim's sorted() is)
	var keyed: Array = []
	for i in s.debuffs.size():
		keyed.append([_batch_start(s.debuffs[i]), i])
	keyed.sort_custom(func(p1, p2): return p1[0] < p2[0] or (p1[0] == p2[0] and p1[1] < p2[1]))
	var order: Array = keyed.map(func(p): return s.debuffs[p[1]])
	var stop := false
	for x in order:
		var can: float = x.n if fee <= 0.0 else minf(x.n, floorf(s.qi / fee + 1e-9))
		if can <= 0.0:
			stop = true
			break
		s.qi -= can * fee
		var nb := FighterState.StackBatch.new()
		nb.el = x.el
		nb.n = can
		nb.until = x.until
		nb.src_idx = _idx(s)
		nb.src_p = s.p
		nb.length = x.length
		nb.power = StackMath.stack_power(k, s.p, x.el, "debuff")
		o.debuffs.append(nb)
		x.n -= can
		if x.n > 0.0:   # only part of it could be paid for
			stop = true
			break
	var kept: Array[FighterState.StackBatch] = []
	for y in s.debuffs:
		if y.n > 0.0:
			kept.append(y)
	s.debuffs = kept
	s.touch_debuffs()
	o.touch_debuffs()
	if stop:
		return
	var sids: Array = []
	for sid in s.statuses:
		if k.status.has(sid):
			sids.append(sid)
	sids.sort_custom(func(a1, b1): return _status_end(s, a1) < _status_end(s, b1) or (_status_end(s, a1) == _status_end(s, b1) and str(a1) < str(b1)))
	for sid in sids:
		var stt: FighterState.StatusState = s.statuses[sid]
		var cost: float = stt.stacks * fee
		if cost > s.qi + 1e-9:
			return
		if str(k.status[sid].kind) == "curse" and not o.statuses.has(sid):
			var live: int = 0
			for other in o.statuses:
				if str(k.status.get(other, {}).get("kind", "")) == "curse":
					live += 1
			if live >= k.curse_slots:
				continue   # no free slot on the foe: it stays
		s.qi -= cost
		if o.statuses.has(sid):   # the foe has it already: stacks add, the longer time stays
			var ot: FighterState.StatusState = o.statuses[sid]
			var cap_v: Variant = k.status[sid].get("cap")
			ot.stacks = ot.stacks + stt.stacks if cap_v == null else minf(float(cap_v), ot.stacks + stt.stacks)
			if ot.until >= 0 and stt.until >= 0:
				ot.until = maxi(ot.until, stt.until)
		else:
			var mv := FighterState.StatusState.new()
			mv.stacks = stt.stacks
			mv.until = stt.until
			mv.src_idx = _idx(s)
			mv.tag = stt.tag
			mv.layer = stt.layer
			mv.crossing = stt.crossing
			mv.no_lockout = stt.no_lockout
			mv.stored = stt.stored
			mv.every = stt.every
			mv.next_release = stt.next_release
			for bt in stt.each:
				mv.each.append((bt as Array).duplicate())
			o.statuses[sid] = mv
		s.statuses.erase(sid)


func _batch_start(x: FighterState.StackBatch) -> int:
	return (x.until - x.length) if (x.until != -1 and x.length != -1) else -1


func _status_end(s: FighterState, sid: String) -> int:
	var u: int = s.statuses[sid].until
	return u if u >= 0 else 1 << 40


## Black Under White (2026-11-26): while [param holder] reads its foe [param x], every counted_curse_per of its stacks
## of an element on that foe count as one more curse. A count only. As engine.py counted_curses.
func counted_curses(holder: FighterState, x: FighterState) -> int:
	if x == holder or not has_mods(holder):
		return 0
	var els: Array = []
	for d in x.debuffs:
		if not els.has(d.el):
			els.append(d.el)
	els.sort()
	var n: int = 0
	var me: int = _idx(holder)
	for el in els:
		var per: float = m(holder, "counted_curse_per", {"element": el})
		if per > 0.0:
			var tot: float = 0.0
			for d in x.debuffs:
				if d.el == el and d.src_idx == me:
					tot += d.n
			n += int(floorf(tot / per))
	return n


func check_cross(s: FighterState, ev: Dictionary) -> void:
	if s.crossed or s.hp > k.broken_threshold * s.hp_max:
		return
	s.crossed = true
	_event(s, "wounded", ev.duplicate())
	_event(foe_of(s), "broken", ev.duplicate())


func _stance_tag(s: FighterState, tag: String) -> bool:
	if s.state == "":
		return false
	var st: Dictionary = s.p.states.get(s.state, {})
	return Array(st.get("tags", [])).has(tag)


func _composed(s: FighterState) -> bool:
	return _stance_tag(s, "composed") or t - maxi(s.t_act, 0) >= k.composed_after_ms


## A duel reading of [param x] (Effects rule 17, Combat Formulas L). As engine.py read.
func reading(x: FighterState, key: String) -> float:
	match key:
		"composed":
			return 1.0 if _composed(x) else 0.0
		"composed_time":
			if _stance_tag(x, "composed"):
				return (t - x.state_since) / 1000.0
			return maxi(0, t - (maxi(x.t_act, 0) + k.composed_after_ms)) / 1000.0
		"pressing":
			if _composed(x):
				return 0.0
			var moved: bool = x.t_move >= 0 and t - x.t_move < k.pressing_after_ms
			return 1.0 if _stance_tag(x, "pressing") or moved else 0.0
		"foe_pressed":
			var o: FighterState = foe_of(x)
			return 1.0 if o.t_act >= 0 and t - o.t_act < k.act_window_ms else 0.0
		"since_act":
			return (t - maxi(x.t_act, 0)) / 1000.0
		"field_up":
			return 1.0 if _stance_tag(x, "field") else 0.0
		"broken":
			return 1.0 if foe_of(x).crossed else 0.0
		"wounded":
			return 1.0 if x.crossed else 0.0
	return 0.0


## Health ([param pool] "hp") or linh lực ("qi") [param s] lost over the last [param window] ms (Effects rule 5,
## 2026-11-26): each pulse's net loss in the window, plus what it has lost since the last pulse. As engine.py.
func lost_last(s: FighterState, pool: String, window: int) -> float:
	var i: int = 1 if pool == "hp" else 2
	var tot: float = 0.0
	for x in s.loss_log:
		if t - int(x[0]) < window:
			tot += float(x[i])
	if s.has_loss_prev:
		tot += maxf(0.0, (s.loss_prev_hp - s.hp) if pool == "hp" else (s.loss_prev_qi - s.qi))
	return tot


## The fight hours a charge counter's live charges were laid in: how many distinct hours, or ([param this_hour]) how
## many were laid in the current hour (The Twelve Hours, 2026-11-26). Laid = end - each_for. As engine.py.
func charge_hours(s: FighterState, cid: String, this_hour: bool) -> float:
	var cdef: Dictionary = s.p.counter_def.get(cid, {})
	if cdef.get("each_for") == null or float(cdef.each_for) == 0.0:
		return 0.0
	var each: int = CombatConstants.ms(float(cdef.each_for))
	var hours: Dictionary = {}
	var now_n: int = 0
	var now_h: int = t / k.fight_hour_ms
	for u in s.counter_times.get(cid, []):
		if int(u) > t:
			var h: int = (int(u) - each) / k.fight_hour_ms
			hours[h] = true
			if h == now_h:
				now_n += 1
	return float(now_n) if this_hour else float(hours.size())


## Upkeep on self-counter [param cid] (Effects rule 6, 2026-11-26): each pulse every stack costs per_stack of the
## pool's maximum (qi: linh lực; hp: health, which must leave pay_keep_health). Stacks the pool cannot pay end; a
## charge counter (each_for) loses the charges nearest their end first. As engine.py upkeep.
func upkeep(s: FighterState, cid: String, up: Dictionary) -> void:
	var cdef: Dictionary = s.p.counter_def[cid]
	var charged: bool = cdef.get("each_for") != null and float(cdef.each_for) != 0.0
	var n: float
	if charged:
		var live: Array = []
		for u in s.counter_times[cid]:
			if int(u) > t:
				live.append(int(u))
		live.sort()
		s.counter_times[cid] = live
		n = float(live.size())
	else:
		n = float(s.counters[cid])
	if n <= 0.0:
		return
	var qi: bool = str(up.get("pool", "qi")) == "qi"
	var cost: float = float(up.per_stack) * (s.qi_max() if qi else s.hp_max)
	var have: float = s.qi if qi else s.hp - k.pay_keep_health
	var keep: float = n if cost <= 0.0 or have >= n * cost else floorf(maxf(0.0, have) / cost)
	var paid: float = keep * cost
	if qi:
		s.qi -= paid
	else:
		s.hp -= paid
	if keep < n:
		if charged:
			s.counter_times[cid] = (s.counter_times[cid] as Array).slice(int(n - keep))
		s.counters[cid] = keep


## True while the foe carries a status that holds its caster and [param s] laid it (Effects Status Catalogue,
## "Statuses that hold their caster", 2026-11-26). Read live, so any way the status ends frees the caster.
func caster_held(s: FighterState) -> bool:
	var o: FighterState = foe_of(s)
	if o.statuses.is_empty():
		return false
	var me: int = _idx(s)
	for sid in o.statuses:
		var stt: FighterState.StatusState = o.statuses[sid]
		if stt.src_idx == me and stt.stacks > 0.0 and bool(k.status.get(sid, {}).get("holds_caster", false)):
			return true
	return false


## Ends status [param sid] on [param s] now (its time ran out, or a hit ended it); the reapply lockout starts. A
## Sleep cut short ([param early]) gives back the clock time it had not used. As engine.py end_status.
func end_status(s: FighterState, sid: String, early: bool = false) -> void:
	var stt: FighterState.StatusState = s.statuses.get(sid)
	if stt == null:
		return
	s.statuses.erase(sid)
	var lock: Variant = k.status.get(sid, {}).get("lockout")
	if lock != null and float(lock) != 0.0 and not stt.no_lockout:
		s.lockouts[sid] = t + CombatConstants.ms(float(lock))
	if early and not stt.clock.is_empty() and stt.until >= 0 and stt.until > t:
		restart_clock(stt.clock, stt.until - t)


## Heals [param s] by [param amount] (Combat Defence & Healing E, 19): healing and healing taken (floored with
## curses), Withering (with Crossing the Line it lands as damage), a heal cap from Effects, then heal_restored.
## Public for mechanism tests.

func heal(s: FighterState, amount: float, source: String = "", ignore_taken: bool = false) -> void:
	if s.window_on:   # an extended last act: the side cannot be healed (Effects rule 11)
		return
	if no_heal:   # Combat Defence & Healing rule 19 (e.g. Heavenly Tribulation waves)
		return
	amount *= 1.0 + s.p.healing + m(s, "healing", null) / 100.0
	# ignore_taken: a heal its own closing exempts (Still Water)
	if not ignore_taken:
		amount *= maxf(1.0 - k.curse_heal_taken_max, 1.0 + m(s, "heal_taken", null) / 100.0)
	if s.st("withering") > 0.0:
		var w_eff: float = maxf(-k.curse_heal_taken_max, k.withering_heal_taken * curse_scale(s, "withering"))
		amount *= 1.0 + w_eff
		var w: FighterState.StatusState = s.statuses["withering"]
		if w.crossing:
			s.hp -= amount
			_side(w.src_idx).dealt += amount
			return
	var top: float = s.hp_max
	var cap: float = m(s, "heal_cap", null)
	if cap > 0.0:   # Whetstone Vow's closing: never heal above that share of maximum
		top = minf(top, cap * s.hp_max)
	var got: float = minf(amount, top - s.hp)
	var ov: float = amount - maxf(0.0, got)
	if got > 0.0:
		s.hp += got
		s.healed += got
		if listens(s, "heal_restored"):
			var ev: Dictionary = (s.cur_ev as Dictionary).duplicate() if s.cur_ev is Dictionary else {}
			ev["amount"] = got
			ev["share"] = got / s.hp_max
			ev["overflow"] = maxf(0.0, ov)   # Effects rule 5 (2026-11-26): healing lost to full health
			if source != "":
				ev["source"] = source
			_event(s, "heal_restored", ev)
	if ov > 0.0 and listens(s, "heal_overflow"):
		var ev_ov: Dictionary = (s.cur_ev as Dictionary).duplicate() if s.cur_ev is Dictionary else {}
		ev_ov["amount"] = ov
		ev_ov["share"] = ov / s.hp_max
		if source != "":
			ev_ov["source"] = source
		_event(s, "heal_overflow", ev_ov)


## [param s] acts at the current time: arts ready in slot order, the basic attack, companions. Public for
## mechanism tests.
func act(s: FighterState) -> void:
	if s.down:
		return
	if s.window_on:   # an extended last act: only its named free hits, one round each window_every ms
		var spend: String = str(s.window_spec.get("spend", ""))
		while t >= s.window_next and s.window_next <= s.window_until \
				and not (spend != "" and float(s.counters.get(spend, 0.0)) <= 0.0):
			for h in s.window_spec.get("hits", []):
				hit(s, foe_of(s), float(h.c), StringName(str(h.get("dtype", "phys"))), null, KIND_TRIGGER, true)
			if spend != "":
				s.counters[spend] = maxf(0.0, float(s.counters[spend]) - 1.0)
			s.window_next += s.window_every
		return
	if not s.xwards.is_empty():
		cast_wards(s)
	var o: FighterState = foe_of(s)
	var p: FighterProfile = s.p
	var speed_base: float = 1.0 + s.bsum("speed") + p.art_speed_pct / 100.0
	var sup: Array = s.p.states.get(s.state, EffectRunner._NONE_D).get("suppress", EffectRunner._NONE_A) if s.state != "" else EffectRunner._NONE_A
	# Sleep and Charmed hold every art of their target; a status s laid that holds its caster holds s's damaging arts
	# and basic attack (Effects Status Catalogue, 2026-11-26)
	var stopped: bool = not s.statuses.is_empty() and (s.st("sleep") > 0.0 or s.st("charmed") > 0.0)
	var held: bool = caster_held(s)
	for i in p.arts.size():
		if t < s.ready[i]:
			continue
		var art: ArtDef = p.arts[i]
		if art.escape != 0.0 and s.channel_until >= 0:   # one escape channel open at a time; a ready one waits
			continue
		if stopped or (held and (art.c != 0.0 or art.soul_pct != 0.0 or art.soul_part != 0.0)):
			continue
		if not sup.is_empty() and sup.has(str(art.id)):
			continue
		if not art.tags.is_empty() and s.st("silence") > 0.0:
			var sil: FighterState.StatusState = s.statuses["silence"]
			if sil.tag != "" and art.tags.has(StringName(sil.tag)):
				continue
		if not art.guards.is_empty() and not EffectRunner.holds(self, s, art.guards, null):
			continue
		if art.soul_pct != 0.0 and t < s.soul_ready:
			continue
		if not pay(s, art):
			continue
		if s.nc_idx >= 0:   # a waiting next-art cost is used by the art that paid with it
			s.next_cost.remove_at(s.nc_idx)
			s.nc_idx = -1
		var base_id: StringName = art.id
		art = shape(s, i, art)
		var speed: float = 1.0 if m(s, "speed_locked", null) > 0.0 else speed_base + m(s, "art_speed", art.ctx) / 100.0 + art.node_speed_pct / 100.0
		if not s.eff_state.is_empty():   # per_firing limits restart with each art firing
			for eid in s.eff_state:
				var es_f: PackedInt64Array = s.eff_state[eid]
				es_f[3] = 0
				s.eff_state[eid] = es_f
		var cd: float = maxf(k.cooldown_min, art.cd / speed) * slow(s)
		s.charges[i] -= 1
		if s.charges[i] > 0:
			s.ready[i] = t + k.cooldown_min_ms
		else:
			s.ready[i] = t + CombatConstants.ms(cd)
			s.charges[i] = art.charges
		s.fired[i] += 1
		if not p.feeds.is_empty():
			_feed(s, i)
		if _fx:   # only Effect reads (fired_within, since) look at the fire log
			s.fire_log.append([t, str(base_id), art.tags_s, art.group])
			var log_keep: Array = []
			for row in s.fire_log:
				if t - int(row[0]) <= FIRE_LOG_MS:
					log_keep.append(row)
			s.fire_log = log_keep
		if art.soul_pct != 0.0 or art.soul_part != 0.0:
			s.soul_ready = t + k.soul_lockout_ms
		if art.buff_n != 0.0:
			add_stacks(s, s, str(art.element), art.buff_n, art.buff_dur, true)
		if art.cleanse != 0:
			cleanse(s, art.cleanse)
		if art.heal != 0.0:
			var got0: float = s.healed
			heal(s, s.u_att * art.heal * k.health_mult)
			if s.healed > got0:
				s.qi = minf(s.qi_use(), s.qi + s.last_cost)
		if art.qi_restore != 0.0:
			s.qi = minf(s.qi_use(), s.qi + art.qi_restore * s.qi_max())
		if _log_enabled:
			_row(FightLogRow.Kind.ART, s.label, &"", art.id, [s.last_cost, s.hp, s.qi])
		var ev: Dictionary = {}
		if _fx:
			ev = {"art_id": str(art.id), "slot": i, "cost": s.last_cost, "tags": art.tags_s, "element": str(art.element),
				"dtype": str(art.dtype), "kind": "art", "hp_paid_share": s.hp_paid / s.hp_max, "group": art.group}
		s.cur_ev = ev
		s.last_art = i
		if art.c != 0.0 or art.soul_pct != 0.0 or art.soul_part != 0.0 or art.tags.has(&"movement"):
			s.t_act = t   # the duel readings' clock (Formulas L)
		if art.tags.has(&"movement"):
			s.t_move = t
		if art.escape != 0.0:   # an escape art opens its channel; hits keep landing (Combat rule 10)
			s.channel_until = t + k.escape_channel_ms
			s.channel_e = art.escape
		if not art.movements.is_empty():   # a piece's movements (2026-11-26; Nine Shao): the next one, if it is this art's
			var nxt_m: int = int(float(s.counters.get(art.movement_counter, 0.0))) + 1
			var mv_d: Dictionary = {}
			for mv in art.movements:
				if int(mv.n) == nxt_m:
					mv_d = mv
					break
			ev["in_turn"] = 0.0 if mv_d.is_empty() else 1.0
			ev["movement"] = 0.0 if mv_d.is_empty() else float(nxt_m)
			if not mv_d.is_empty():
				if _log_enabled:
					_row(FightLogRow.Kind.MOVEMENT, s.label, &"", art.id, [float(nxt_m)])
				EffectRunner.run(self, s, mv_d.e, mv_d.do, 1.0, ev)
		_event(s, "art_fired", ev)
		if art.soul_pct != 0.0:
			soul_hit(s, o, art)
		elif art.c != 0.0:
			if art.split.is_empty():
				hit(s, o, art.c, art.dtype, art, KIND_ART)
			else:
				for sh in art.split:
					hit(s, o, art.c * sh, art.dtype, art, KIND_ART)
		EffectRunner.spend_banked(self, s, "art_fired", ev)
		s.cur_ev = null
	while t >= s.basic_ready:
		if not (stopped or held):   # a held basic attack misses; its timer still runs
			hit(s, o, 1.0 + p.basic_coef_add + m(s, "basic_coef", null), &"phys", null, KIND_BASIC)
		s.basic_ready += CombatConstants.ms(basic_cd(s) * slow(s))
	var cp: float = m(s, "companion_power", null) / 100.0
	var cs: float = maxf(0.01, 1.0 + m(s, "companion_speed", null) / 100.0)
	for sm in (s.summons.duplicate() if not s.summons.is_empty() else EffectRunner._NONE_A):
		while t >= int(sm[3]) and int(sm[3]) < int(sm[4]):
			var sm_c: float = float(sm[0])
			var c_sm: float = minf(maxf(k.c_comp_cap, sm_c), maxf(0.0, sm_c + cp))
			hit(s, o, c_sm, sm[1], null, KIND_COMPANION)
			var base_cd: float = float(sm[5]) if (sm as Array).size() > 5 else float(sm[2]) / 1000.0
			sm[3] = int(sm[3]) + CombatConstants.ms(maxf(k.cooldown_min, base_cd / cs))
		if t >= int(sm[4]):
			s.summons.erase(sm)
	for j in p.companions.size():
		var comp: FighterProfile.Companion = p.companions[j]
		while t >= s.comp_ready[j]:
			var c_comp: float = minf(k.c_comp_cap, maxf(0.0, comp.c + cp))
			hit(s, o, c_comp, comp.dtype, null, KIND_COMPANION, false, comp.tags)
			var ccd: float = comp.cd / cs
			s.comp_ready[j] += CombatConstants.ms(maxf(k.cooldown_min, ccd))


## The art as it fires (the sim's shape; Combat 13, Effects 6): a multi-step art fires as its next step when that
## step's unlock holds (paying its pay, raising step_unlocked), else as its first form; then each empower whose
## conditions hold pays and adds its override (raising empowered). Public for mechanism tests.
func shape(s: FighterState, i: int, art: ArtDef) -> ArtDef:
	var fired: ArtDef = art
	if not art.steps.is_empty():
		var nxt: int = s.step[i] + 1
		if nxt <= art.steps.size() and EffectRunner.holds(self, s, art.steps[nxt - 1].conds, null) 				and step_health(s, art, art.steps[nxt - 1], false):
			var sd: ArtOverride.StepDef = art.steps[nxt - 1]
			step_health(s, art, sd, true)
			fired = sd.art
			if not sd.pay.is_empty():
				EffectRunner.run(self, s, sd.pay_effect, sd.pay, 1.0, {"art_id": str(art.id)})
			s.step[i] = nxt if nxt < art.steps.size() else 0
			if _log_enabled:
				_row(FightLogRow.Kind.STEP, s.label, &"", art.id, [float(nxt)])
			_event(s, "step_unlocked", {"art_id": str(art.id), "step": nxt})
		else:
			s.step[i] = 0
	for em in art.empower:
		if EffectRunner.holds(self, s, em.conds, null):
			if not em.pay.is_empty():
				EffectRunner.run(self, s, em.pay_effect, em.pay, 1.0, {"art_id": str(art.id)})
			fired = em.ov.apply(fired)
			if _log_enabled:
				_row(FightLogRow.Kind.EMPOWER, s.label, &"", art.id, [])
			_event(s, "empowered", {"art_id": str(art.id)})
	return fired


## A step's own health cost (the sim's step_health; 2026-11-14): hp_cost x health_max, reduced by hp_cost_red, paid
## first by the body shield under shield_pays; it must leave pay_keep_health or the step does not unlock. With
## [param do_pay] false it only answers whether the step can pay.
func step_health(s: FighterState, art: ArtDef, sd: ArtOverride.StepDef, do_pay: bool) -> bool:
	if sd.hp_cost == 0.0:
		return true
	var need: float = sd.hp_cost * s.hp_max * (1 - minf(1.0, m(s, "hp_cost_red", art.ctx)))
	var from_shield: float = minf(s.body_bar, need) if m(s, "shield_pays", null) > 0 else 0.0
	if s.hp - (need - from_shield) < k.pay_keep_health:
		return false
	if do_pay:
		s.body_bar -= from_shield
		s.hp -= need - from_shield
		s.hp_paid += need
	return true


## Pays [param art]'s cost for [param s] (Combat E, R12; Effects): Ice stacks and Heavy Breath raise it, cost
## reduction lowers it; a heart-demon art pays from tâm ma, a divine-sense art spends thần thức; otherwise linh lực,
## the hp_pay share, art_cost_health, Blood Casting and the art's health cost (halved by hp_cost_red, paid first by
## the body shield with Shield Pays the Blood); foe_cost_extra raised on the Ice share. Returns false, paying
## nothing, when it cannot. Public for mechanism tests.
func pay(s: FighterState, art: ArtDef) -> bool:
	var p: FighterProfile = s.p
	s.hp_paid = 0.0
	var hb_n: float = s.st("heavy_breath")
	var hb_up: float = minf(k.curse_cost_raise_max, hb_n * k.heavy_cost_up * curse_scale(s, "heavy_breath")) if hb_n > 0.0 else 0.0
	var cost_up: float = (1.0 + s.dsum("cost_up")) * (1.0 + hb_up)
	var cost: float = art.cost * k.cost_scale * (1.0 - minf(k.cost_red_cap, p.cost_red + m(s, "cost_red", art.ctx))) \
			* cost_up * s.qi_base * (1.0 + art.node_cost_pct / 100.0)
	s.nc_idx = -1
	for j in s.next_cost.size():
		if EffectRunner.matches(self, s.next_cost[j][1], art.ctx):
			s.nc_idx = j
			break
	if s.nc_idx >= 0:   # a waiting next-art cost (2026-11-26; Nine Shao's seventh movement)
		cost *= float(s.next_cost[s.nc_idx][0])
	if art.pool == &"tam_ma":
		var need: float = cost / s.qi_max() * 100.0
		if s.tam_ma < need:
			return false
		s.tam_ma -= need
		s.last_cost = 0.0
		return true
	if art.pool == &"than_thuc":
		var share: float = cost / s.qi_max()
		var ds: float = p.divine_sense * (1.0 - s.ts_spent)
		if ds <= share * p.divine_sense:
			return false
		s.ts_spent += share
		s.last_cost = 0.0
		return true
	var hp_red: float = 1.0 - minf(1.0, m(s, "hp_cost_red", art.ctx))
	var shield_pays: bool = m(s, "shield_pays", null) > 0.0
	if art.hp_cost != 0.0 and s.hp - art.hp_cost * hp_red * s.hp_max < k.pay_keep_health and not shield_pays:
		return false
	var qi_part: float = cost * (1.0 - p.hp_pay)
	var hp_part: float = cost * p.hp_pay * (s.hp_max / s.qi_base)
	var x_hp: float = m(s, "art_cost_hp", art.ctx)
	if x_hp > 0.0:
		# art_cost_health_pct (Combat E, #44 B4): linh lực pays cost / (1 + X/100), health the rest point for point
		var shifted: float = qi_part - qi_part / (1.0 + x_hp / 100.0)
		qi_part -= shifted
		hp_part += shifted
	var blood: bool = s.qi + 1e-6 < qi_part and m(s, "blood_cast", null) > 0.0
	if blood:   # Blood Casting: the shortfall is paid in health, 1 for 1; it may put you Down
		hp_part += qi_part - maxf(0.0, s.qi)
		qi_part = maxf(0.0, s.qi)
	if s.qi + 1e-6 < qi_part:
		return false
	var hp_total: float = (hp_part + art.hp_cost * s.hp_max) * hp_red
	var from_shield: float = minf(s.body_bar, hp_total) if shield_pays else 0.0
	if hp_total - from_shield > 0.0 and s.hp - (hp_total - from_shield) < k.pay_keep_health and not blood:
		return false
	s.qi -= qi_part
	s.body_bar -= from_shield
	s.hp -= hp_total - from_shield
	s.hp_paid = hp_total
	if listens(foe_of(s), "foe_cost_extra") and qi_part > 0.0:
		var ice: float = 0.0
		for x in s.debuffs:
			if x.el == "ice":
				ice += float(k.debuff.ice.cost_up) * x.n * x.power
		if ice > 0.0:   # the part of this cost the foe's Ice stacks added (Toll Taker)
			_event(foe_of(s), "foe_cost_extra", {"amount": qi_part * ice / (1.0 + s.dsum("cost_up"))})
	s.spent += qi_part
	s.last_cost = qi_part
	return true


## One hit of coefficient [param c] from [param att] into [param dfn]: the evade roll, the crit roll (not for
## companions or triggers), D = U x c x M x crit x more x supp (Combat Formulas A, H, I; element stacks; Effect mods),
## dampening, the added Soul part split off, the [DefencePath] (per converted part), the Soul part against soul
## resistance, on-hit sustain, debuff stacks and statuses, then hit_landed, crit, was_hit and hit_stopped (a trigger
## only below the trigger depth) and payloads held until hit_landed. Returns the health removed.
## Public for mechanism tests.
func hit(att: FighterState, dfn: FighterState, c: float, dtype: StringName, art: ArtDef, kind: StringName,
		trig: bool = false, ctags: Array = [], pass_shields: bool = false) -> float:
	if dfn.window_on:   # an extended last act: the side cannot be struck (Effects rule 11)
		return 0.0
	var ctx: Dictionary
	if not _fx:
		ctx = _bare_ctx   # no Effects: nothing reads the context (defend may mark it stopped; nothing reads that)
	elif art != null:
		ctx = art.ctx.duplicate()
		ctx["dtype"] = str(dtype)
	else:
		var tg: Array = [str(kind)]
		tg.append_array(ctags)   # a companion's own tags (crane, bird), 2026-11-26
		ctx = {"dtype": str(dtype), "element": "", "tags": tg, "kind": str(kind), "art_id": str(kind)}
	if pass_shields:   # a free hit that passes ward shields (2026-11-26; Move the Sickness)
		if ctx == _bare_ctx:
			ctx = {}
		ctx["pass_shields"] = true
	var am: bool = has_mods(att)
	var dm: bool = has_mods(dfn)
	# avoid (Combat R6): a decoy absorbs the whole hit, within the side's per-pulse avoid budget (W3, 2026-11-26)
	if not trig and dfn.decoys > 0 and dfn.avoided < int(k.avoid_budget):
		dfn.decoys -= 1
		dfn.avoided += 1
		if listens(dfn, "decoy_struck"):
			_event(dfn, "decoy_struck", {"kind": str(kind), "art_id": str(art.id) if art != null else str(kind)})
		return 0.0
	# Returning Wave: the first hit taken does no harm and strikes the attacker at full damage, once a fight
	if not trig and not dfn.reflected and dm and m(dfn, "reflect_first", null) > 0.0:
		dfn.reflected = true
		var back: float = layers_m(att, art, ctx) if kind != KIND_COMPANION else att.p.m
		var d0: float = att.u_att * c * back * _supp(att, dfn, m(att, "pierce", null) / 100.0)
		var rctx: Dictionary = ctx.duplicate()
		rctx["kind"] = "trigger"
		var got_r: float = DefencePath.defend(self, dfn, att, d0, dtype, null, rctx, false)
		dfn.dealt += got_r
		if _log_enabled:
			_row(FightLogRow.Kind.REFLECT, dfn.label, &"", &"", [d0, got_r, att.hp, att.qi])
		return 0.0
	# evade, then crit: both rolls are drawn whenever they apply, so a zero chance never shifts the stream
	# Off Guard (2026-11-26): evade counts as 0, with no draw
	if dfn.st("off_guard") <= 0.0 and rng.randf() < evade_chance(att, dfn):
		dfn.t_act = t   # an evade is an act and a move (Formulas L)
		dfn.t_move = t
		_event(dfn, "evaded", ctx)
		_event(att, "was_evaded", ctx)
		return 0.0
	dfn.last_hit_t = t
	var wake_cut: float = 0.0
	if not dfn.statuses.is_empty():   # the hit landed: it may end a held status (Effects Status Catalogue)
		if dfn.st("sleep") > 0.0:   # any direct hit wakes the sleeper, and deals less
			wake_cut = float(k.status.sleep.wake_cut)
			end_status(dfn, "sleep", true)
		var ch_s: FighterState.StatusState = dfn.statuses.get("charmed")
		if ch_s != null and ch_s.src_idx == _idx(att) and kind != KIND_COMPANION:   # the charmer's trigger or free hit
			end_status(dfn, "charmed", true)
	var is_crit := false
	if kind != KIND_COMPANION and not trig:
		var ch: float = crit_chance(att, dfn, ctx)
		if am and m(att, "counted_crit", null) > 0.0:   # Called Blow: a meter in thousandths, no draw (Effects Formulas A)
			att.crit_meter += int(floorf(maxf(0.0, ch) * 1000.0 + 0.5))
			if att.crit_meter >= 1000:
				att.crit_meter -= 1000
				is_crit = true
		else:
			is_crit = rng.randf() < ch
		if am and m(att, "sure_crit", ctx) > 0.0:
			is_crit = true
	if _fx:
		ctx["crit"] = is_crit
	var crit: float = (att.p.crit_mult + (m(att, "crit_mult", ctx) if am else 0.0) / 100.0 + dfn.dsum("critdmg_taken")) if is_crit else 1.0
	var phys: bool = dtype == &"phys"
	var more: float = 1.0 + att.bsum("dmg") + ((att.bsum("dmg_phys") + dfn.dsum("phys_taken")) if phys else 0.0)
	more *= 1.0 + (m(att, "dmg_more", ctx) if am else 0.0)
	var mm: float = att.p.m if kind == KIND_COMPANION else layers_m(att, art, ctx)
	var d: float = att.u_att * c * mm * crit * more * _supp(att, dfn, (m(att, "pierce", null) if am else 0.0) / 100.0)
	if wake_cut != 0.0:   # the hit that wakes a sleeper deals less
		d *= 1.0 - wake_cut
	if art != null and art.element == &"water" and dfn.st("drunk") >= float(k.status.drunk.water_taken_at):
		d *= 1.0 + float(k.status.drunk.water_taken) * curse_scale(dfn, "drunk")   # Drunk at 3+: Water parts hit harder
	var damp: float = (dfn.bsum("phys_dampen") if phys else 0.0) + (m(dfn, "dampen_taken", ctx) if dm else 0.0) / 100.0
	if damp != 0.0:
		d /= 1.0 + damp
	var d_in: float = d
	var soul_d: float = 0.0
	if art != null and art.soul_part != 0.0:
		soul_d = d * art.soul_part
		d -= soul_d
	hit_id += 1
	var dealt: float
	if art != null and art.convert_share != 0.0:
		# conversion: each part meets its own type's defence (Combat Damage Types); the second part's context is a copy
		var cd_part: float = d * art.convert_share
		dealt = DefencePath.defend(self, att, dfn, d - cd_part, dtype, art, ctx, false)
		var ctx2: Dictionary = ctx.duplicate() if _fx else {}
		if _fx:
			ctx2["dtype"] = str(art.convert_to)
		dealt += DefencePath.defend(self, att, dfn, cd_part, art.convert_to, art, ctx2, false)
	else:
		dealt = DefencePath.defend(self, att, dfn, d, dtype, art, ctx, false)
	if soul_d != 0.0:
		var sr: float = _soul_res(att, dfn)
		var sd: float = soul_d / (1.0 + sr / 100.0) if sr >= 0.0 else soul_d * (1.0 + absf(sr) / 100.0)
		dfn.hp -= sd
		dealt += sd
	if dealt > 0.0:
		_note_dmg(dfn, 2 if (dtype == &"soul" or (soul_d > 0.0 and dealt <= soul_d + 1e-9)) else _layer_of(dtype))
	att.dealt += dealt
	if trig:
		att.trig_dmg += dealt
	else:
		att.direct_dmg += dealt
	var on_hit: float = 0.0 if (am and m(att, "no_gain_on_hit", null) > 0.0) 			else att.p.gain_on_hit + (m(att, "gain_on_hit", null) if am else 0.0) / 100.0
	var gain: float = on_hit * att.qi_max() \
			+ (att.p.leech_qi + (m(att, "leech_qi", null) if am else 0.0) / 100.0) * dealt
	att.qi = minf(att.qi_use(), att.qi + gain)
	var lh: float = att.p.leech_hp + (m(att, "leech_hp", null) if am else 0.0) / 100.0
	if lh != 0.0:
		heal(att, lh * dealt, "leech")   # a leech is a heal's source (2026-11-26)
	if _log_enabled:
		var id: StringName = art.id if art != null else kind
		_row(FightLogRow.Kind.HIT, att.label, kind, id, [d_in, dealt, dfn.hp, dfn.qi, att.hp, att.qi])
	if art != null and art.debuff_n != 0.0:
		add_stacks(att, dfn, str(art.element), art.debuff_n, art.debuff_dur, false,
				"talisman" if art.tags.has(&"talisman") else "")   # talisman stacks (2026-11-26)
	if art != null:
		for spec in art.statuses:
			apply_status(att, dfn, spec)
	if not dfn.crossed and dfn.hp <= k.broken_threshold * dfn.hp_max:
		var cev: Dictionary = ctx.duplicate() if _fx else {}
		if _fx:
			cev["amount"] = dealt
			cev["crit"] = is_crit
			cev["cost"] = att.last_cost if kind == KIND_ART and not trig else 0.0
		check_cross(dfn, cev)
	if _fx and (not trig or depth < k.trig_depth):
		var ev: Dictionary = ctx.duplicate()
		ev["amount"] = dealt
		ev["crit"] = is_crit
		ev["cost"] = att.last_cost if kind == KIND_ART and not trig else 0.0
		_event(att, "hit_landed", ev)
		if is_crit:
			var qc: float = m(att, "qi_on_crit", ctx) / 100.0   # linh_luc_on_crit_pct: pp of maximum per crit (#44 B3)
			if qc != 0.0:
				att.qi = minf(att.qi_use(), att.qi + qc * att.qi_max())
			_event(att, "crit", ev)
		_event(dfn, "was_hit", ev)
		if bool(ev.get("stopped", false)):
			_event(dfn, "hit_stopped", ev)
		if kind == KIND_ART or kind == KIND_BASIC:
			EffectRunner.spend_banked(self, att, "hit_landed", ev)
	return dealt


## A tick of [param amount] and type [param dtype] from [param src]'s status or element [param sid] into
## [param s]: through the [DefencePath] as a tick (no minimum; block only through tick_block; shields only where they
## stop ticks), then tick_dealt. Returns the health removed.
func tick(src: FighterState, s: FighterState, amount: float, dtype: StringName, sid: String) -> float:
	hit_id += 1
	var dealt: float = 0.0
	var tc: float = 0.0
	if has_mods(s):
		tc = m(s, "tick_to_heal", {"element": sid if sid in CombatConstants.ELEMENTS else "", "status": sid,
				"dtype": str(dtype)})
	if tc > 0.0:
		# Turn a tick into healing (Effects rule 6, 2026-11-26; Bitter Medicine): the tick deals nothing and heals
		# its taker for that share of it, as healing (Withering and the healing rules apply). As engine.py tick.
		heal(s, amount * minf(1.0, tc / 100.0), "tick")
	else:
		dealt = DefencePath.defend(self, src, s, amount, dtype, null, {"dtype": str(dtype)} if _fx else {}, true)
	if dealt > 0.0:
		_note_dmg(s, _layer_of(dtype))
	src.dealt += dealt
	if _log_enabled:
		_row(FightLogRow.Kind.TICK, src.label, &"", StringName(sid), [amount, dealt, s.hp, s.qi])
	if listens(src, "tick_dealt"):
		_event(src, "tick_dealt", {"amount": dealt, "status": sid,
			"element": sid if sid in CombatConstants.ELEMENTS else "", "dtype": str(dtype)})
	if listens(s, "tick_taken"):
		_event(s, "tick_taken", {"amount": dealt, "status": sid,
			"element": sid if sid in CombatConstants.ELEMENTS else "", "dtype": str(dtype)})
	check_cross(s, {"status": sid, "kind": "tick"})
	return dealt


## A soul attack by [param att] with [param art] (Combat 24, E2): rho from both sides' divine sense left and the
## defender's soul resistance; no effect below rho_min; else a share of the defender's health and linh lực, capped
## at soul_cap; then soul_hit. Returns the health removed. Public for mechanism tests.
func soul_hit(att: FighterState, dfn: FighterState, art: ArtDef) -> float:
	if dfn.window_on:   # an extended last act: the side cannot be struck (Effects rule 11)
		return 0.0
	var ds_att: float = att.p.divine_sense * (1.0 - att.ts_spent)
	var ds_def: float = dfn.p.divine_sense * (1.0 - dfn.ts_spent)
	var sr: float = _soul_res(att, dfn)
	var rho: float = ds_att / (ds_def * (1.0 + sr / 100.0)) if sr >= 0.0 else ds_att * (1.0 + absf(sr) / 100.0) / ds_def
	if rho < k.rho_min:
		return 0.0
	var pct: float = minf(art.soul_pct * (1.0 + (att.p.x_soul + m(att, "x_soul", art.ctx)) / 100.0) * pow(rho, k.soul_beta)
			* _supp(att, dfn, m(att, "pierce", null) / 100.0), k.soul_cap)
	var lh: float = pct * dfn.hp_max
	var lq: float = pct * dfn.qi_max()
	if not dfn.soul_charges.is_empty():   # Reflect a soul art (W2, 2026-11-26): no harm; Cold on the caster
		var live: Array[int] = []
		for u in dfn.soul_charges:
			if u > t:
				live.append(u)
		live.sort()
		if not live.is_empty():
			live.remove_at(0)
			dfn.soul_charges = live
			var got_s: float = DefencePath.defend(self, dfn, att, lh, &"cold", null, {"dtype": "cold", "kind": "trigger"}, false)
			dfn.dealt += got_s
			if listens(dfn, "soul_taken"):
				_event(dfn, "soul_taken", {"amount": lh, "art_id": str(art.id), "tags": art.tags_s, "reflected": 1.0})
			return 0.0
		dfn.soul_charges = live
	dfn.hp -= lh
	dfn.qi = maxf(0.0, dfn.qi - lq)
	if lh > 0.0:
		_note_dmg(dfn, 2)
	att.dealt += lh
	att.direct_dmg += lh
	if _log_enabled:
		_row(FightLogRow.Kind.SOUL, att.label, &"", art.id, [lh, lq, dfn.hp, dfn.qi])
	if listens(att, "soul_hit"):
		_event(att, "soul_hit", {"amount": lh, "qi": lq, "tags": art.tags_s, "element": str(art.element),
			"art_id": str(art.id), "kind": "art", "dtype": "soul"})
	if listens(dfn, "soul_taken"):   # W2 (2026-11-26): the side a soul art lands on
		_event(dfn, "soul_taken", {"amount": lh, "art_id": str(art.id), "tags": art.tags_s, "reflected": 0.0})
	return lh


## Curse strength multiplier for [param sid] on [param tgt] from its source fighter (modifiers.md
## curse_effect_pct): max(0.0, 1.0 + mod(src, "curse_effect") / 100.0). Returns 1.0 without a caster or mods.
func curse_scale(tgt: FighterState, sid: String) -> float:
	var st: FighterState.StatusState = tgt.statuses.get(sid)
	if st == null or st.src_idx < 0 or st.src_idx > 1:
		return 1.0
	var src: FighterState = _side(st.src_idx)
	if not has_mods(src):
		return 1.0
	var sctx := {"status": sid, "kind": "curse", "tags": ["curse", sid]} if _fx else EffectRunner._NONE_D
	return maxf(0.0, 1.0 + m(src, "curse_effect", sctx) / 100.0)


## The defender's soul resistance against [param att]: its own, its Effect mods, Slackened Soul, and the attacker's
## foe_soul_res (Lamp-Lit Reading).
func _soul_res(att: FighterState, dfn: FighterState) -> float:
	var ss_n: float = dfn.st("slackened_soul")
	var ss_pts: float = ss_n * k.slackened_soul_res * curse_scale(dfn, "slackened_soul") if ss_n > 0.0 else 0.0
	return dfn.p.soul_res + m(dfn, "soul_res", null) + ss_pts + m(att, "foe_soul_res", null)


## Grants [param n] stacks of element [param el] from [param src] to [param target] (Effects rule 9a): plus the
## source's stack_grant, lasting [param dur] seconds (-1: the fight) scaled by its stack duration %, at least
## min_batch; a debuff raises status_applied. Public for mechanism tests.
func add_stacks(src: FighterState, target: FighterState, el: String, n: float, dur: float, is_buff: bool,
		mark: String = "") -> void:
	if n == 0.0:
		return
	var kind: String = "buff" if is_buff else "debuff"
	if has_mods(src):
		n += float(int(m(src, "stack_grant", {"element": el, "kind": kind})))
	if dur >= 0.0 and not src.p.stack_dur.is_empty():
		dur = dur * (1.0 + StackMath.stack_pct(src.p.stack_dur, el, kind) / 100.0)
	if dur >= 0.0 and has_mods(src):   # the live stack_dur mod (W4, 2026-11-26; Master's Road), read when laid
		dur = dur * maxf(0.0, 1.0 + m(src, "stack_dur", {"element": el, "kind": kind}) / 100.0)
	var until: int = -1 if dur < 0.0 else t + CombatConstants.ms(maxf(k.min_batch, dur))
	var batch := FighterState.StackBatch.new()
	batch.el = el
	batch.n = n
	batch.until = until
	batch.src_idx = _idx(src)
	batch.src_p = src.p
	batch.length = -1 if until == -1 else until - t
	batch.mark = mark
	# a buff's power reads the holder's profile, a debuff's its source's (the sim's bsum / dsum)
	batch.power = StackMath.stack_power(k, target.p if is_buff else src.p, el, kind)
	if is_buff:
		target.buffs.append(batch)
		target.touch_buffs()
		if _log_enabled:
			_row(FightLogRow.Kind.STACKS, src.label, &"", StringName(el), [n, float(until), 1.0], target.label)
		_event(target, "buff_gained", {"element": el, "stacks": n})
	else:
		target.debuffs.append(batch)
		target.touch_debuffs()
		if _log_enabled:
			_row(FightLogRow.Kind.STACKS, src.label, &"", StringName(el), [n, float(until), 0.0], target.label)
		_event(src, "status_applied", {"element": el, "stacks": n})


## Applies status [param spec] from [param src] to [param target] (Status Catalogue; Combat Formulas F; Effects
## R22): nothing during its lockout; status resistance and a chance below 1 roll within the chance clamp; a new curse
## needs a free curse slot; the duration scales with the source's status_dur, curses last 1 to curse_duration_max
## pulses; stacks add up to the cap; the duration restarts; then status_applied. Public for mechanism tests.
func apply_status(src: FighterState, target: FighterState, spec: StatusSpec) -> void:
	var sid: String = spec.id
	if sid == "internal_injury":
		var ii: FighterState.StatusState = target.statuses.get(sid)
		if ii == null:
			ii = FighterState.StatusState.new()
			ii.stacks = 1.0
			ii.src_idx = _idx(src)
			target.statuses[sid] = ii
		ii.every = float(spec.extra.get("every", k.injury_every))
		return
	var d: Dictionary = k.status[sid]
	if has_mods(target) and m(target, "status_immune", {"status": sid}) > 0.0:
		return   # Immovable Mountain: Slowed Time never lands
	if t < int(target.lockouts.get(sid, -1)):
		return
	if str(d.get("stacking", "")) == "none" and target.st(sid) > 0.0:
		return   # stacking None: a recast while it runs does nothing (Effects Edge Cases; both engines, 2026-11-14)
	var is_curse: bool = str(d.kind) == "curse"
	var sctx: Dictionary = {"status": sid, "kind": str(d.kind), "tags": [str(d.kind), sid]} if _fx else {}
	var chance: float = spec.chance
	var resist: float = m(target, "status_resist", sctx) / 100.0
	if chance <= 0.0:
		return
	if not (chance >= 1.0 and resist <= 0.0):
		if rng.randf() >= minf(k.status_chance_max, maxf(k.status_chance_min, chance * (1.0 - resist))):
			return
	if is_curse and not target.statuses.has(sid):
		var live: int = 0
		for other in target.statuses:
			if str(k.status.get(other, {}).get("kind", "")) == "curse":
				live += 1
		if live >= k.curse_slots:
			return
	var dur_v: Variant = spec.extra["dur"] if spec.extra.has("dur") else d.get("dur")
	var has_dur: bool = dur_v != null
	var dur: float = float(dur_v) if has_dur else 0.0
	if has_dur:
		dur = dur * (1.0 + m(src, "status_dur", sctx) / 100.0)
	if has_dur and is_curse:
		dur = maxf(1.0, minf(k.curse_duration_max, dur))
	if has_dur and bool(d.get("falloff", false)):   # Charmed: the delay falloff (R1), counted with timer delays
		var recent: Array = []
		for x in target.delays:
			if t - int(x) < k.delay_window_ms:
				recent.append(x)
		target.delays = recent
		dur = dur * pow(k.delay_falloff, float(target.delays.size()))
		target.delays.append(t)
	if has_dur and bool(d.get("timer_resisted", false)):   # Charmed, Sleep: timer resistance shortens it, >= 1 s
		dur = maxf(1.0, dur * (1.0 - (target.p.timer_resist + m(target, "timer_resist", null)) / 100.0))
	var st: FighterState.StatusState = target.statuses.get(sid)
	var cap_v: Variant = spec.extra["cap"] if spec.extra.has("cap") else d.get("cap")
	if st == null:
		st = FighterState.StatusState.new()
		target.statuses[sid] = st
	st.src_idx = _idx(src)
	if is_curse and has_mods(src) and m(src, "curse_fast", sctx) >= 1.0:
		st.fast = true   # Effects rule 6 (Stage 6 b01; Sentence Stands): cannot be cleansed, expires on time only
	if bool(d.get("stack_timers", false)):   # Drunk: each landing runs its own time; a new stack refreshes no other
		st.each.append([spec.stacks, -1 if not has_dur else t + CombatConstants.ms(dur)])
		var n_s: float = 0.0
		var last_s: int = 0
		var open_s: bool = false
		for bt in st.each:
			n_s += float(bt[0])
			if int(bt[1]) < 0:
				open_s = true
			else:
				last_s = maxi(last_s, int(bt[1]))
		st.stacks = n_s
		st.until = -1 if open_s else last_s
	else:
		st.stacks = st.stacks + spec.stacks if cap_v == null else minf(float(cap_v), st.stacks + spec.stacks)
		if has_dur and bool(d.get("clock_stop", false)):   # Sleep: the target's clock stops for its time (rule 6)
			st.clock = stop_clock(target, CombatConstants.ms(dur))
		st.until = -1 if not has_dur else t + CombatConstants.ms(dur)
	if spec.extra.has("layer"):
		st.layer = int(spec.extra.layer)
	if spec.extra.has("tag"):
		st.tag = str(spec.extra.tag)
	if spec.extra.has("crossing"):
		st.crossing = bool(spec.extra.crossing)
	if spec.extra.has("no_lockout"):
		st.no_lockout = bool(spec.extra.no_lockout)
	if _log_enabled:
		_row(FightLogRow.Kind.STATUS, src.label, &"", StringName(sid), [st.stacks, float(st.until)], target.label)
	_event(src, "status_applied", {"status": sid, "stacks": spec.stacks})


## Cleanses up to [param n] debuff stacks from [param s], earliest expiry first (of element [param el] only, when
## given); the foe hears cleansed. Returns the stacks removed. Public for mechanism tests.
## A debuff batch a talisman art laid, while its caster holds talisman_fast: no cleanse removes it (Rainfast Ink,
## 2026-11-26). As engine.py held_fast.
func held_fast(x: FighterState.StackBatch) -> bool:
	if x.mark != "talisman":
		return false
	var owner: FighterState = _side(x.src_idx)
	return has_mods(owner) and m(owner, "talisman_fast", null) > 0.0


func cleanse(s: FighterState, n: int, el: String = "") -> float:
	var removed: float = 0.0
	var left: float = n
	_sort_by_until(s.debuffs)
	var i: int = 0
	while left > 0.0 and i < s.debuffs.size():
		var x: FighterState.StackBatch = s.debuffs[i]
		if el != "" and x.el != el:
			i += 1
			continue
		if held_fast(x):
			i += 1
			continue
		var owner: FighterState = _side(x.src_idx)
		var guard: Dictionary = owner.protect.get(x.el, {})
		if not guard.is_empty():
			var ff: Variant = guard.get("for_first")
			var started: int = (x.until - x.length) if (x.until != -1 and x.length != -1) else -1
			if ff == null or started == -1 or t - started < CombatConstants.ms(float(ff)):
				if bool(guard.get("swap_buff", false)):   # Embers Never Die: the source loses its own buff stacks instead
					var lose: float = minf(left, EffectRunner._count_buffs(owner, x.el))
					var mine: Array[FighterState.StackBatch] = []
					for y in owner.buffs:
						if y.el == x.el:
							mine.append(y)
					_sort_by_until(mine)
					for y in mine:
						var ky: float = minf(lose, y.n)
						y.n -= ky
						lose -= ky
					var kept_b: Array[FighterState.StackBatch] = []
					for y in owner.buffs:
						if y.n > 0.0:
							kept_b.append(y)
					owner.buffs = kept_b
					owner.touch_buffs()
				i += 1
				continue
		var take: float = minf(left, x.n)
		x.n -= take
		left -= take
		removed += take
		if x.n <= 0.0:
			s.debuffs.remove_at(i)
		else:
			i += 1
	s.touch_debuffs()
	if _log_enabled and removed != 0.0:
		_row(FightLogRow.Kind.CLEANSE, s.label, &"", &"", [removed])
	if removed != 0.0:
		_event(foe_of(s), "cleansed", {"amount": removed})
	return removed


## The chance [param dfn] evades a hit from [param att] (Combat Formulas I): evade, its up wards' evade (a reserved
## ward always counts, others need live linh lực) and Effect evade, less Wind debuffs on it, less the attacker's
## accuracy (Effect accuracy and Thunder buffs raise it, Earth debuffs lower it), within 0 and evade_cap.
func evade_chance(att: FighterState, dfn: FighterState) -> float:
	var w_ev: float = 0.0
	for xw in dfn.xwards:
		if xw.up and (xw.def.model == ExtraWardDef.Model.RESERVED or dfn.qi > 0.0):
			w_ev += xw.def.evade
	w_ev /= 100.0
	if has_mods(dfn) and m(dfn, "no_evade", null) > 0.0:
		return 0.0
	var ev_m: float = m(dfn, "evade", null) if has_mods(dfn) else 0.0
	var acc_m: float = m(att, "acc", null) if has_mods(att) else 0.0
	var dk: float = att.st("drunk")
	var p_ev: float = dfn.p.evade + w_ev + ev_m / 100.0 - dfn.dsum("evade_down") \
			- (att.p.acc + acc_m / 100.0 + att.bsum("acc") - att.dsum("acc_down")) \
			+ float(k.status.drunk.acc_down) * dk * (curse_scale(att, "drunk") if dk > 0.0 else 1.0)   # Drunk: aim lost (2026-11-26)
	return minf(k.evade_cap, maxf(0.0, p_ev))


## The chance a hit from [param att] on [param dfn] crits (Combat Formulas I): crit, Effect crit (scoped by the hit's
## [param ctx]), Thunder buffs on the attacker and Thunder debuffs on the defender, within crit_cap.
func crit_chance(att: FighterState, dfn: FighterState, ctx: Variant = null) -> float:
	var crit_m: float = m(att, "crit", ctx) if has_mods(att) else 0.0
	var cap: float = k.crit_cap
	if has_mods(att):
		var cap_to: float = m(att, "crit_cap_to", null)
		if cap_to > 0.0:   # a lower crit cap (Called Blow)
			cap = minf(cap, cap_to)
	return minf(cap, att.p.crit + crit_m / 100.0 + att.bsum("crit") + dfn.dsum("crit_taken"))


## Cast wards for [param s] (Combat Defence & Healing rule 7): a ward up past its window goes down (its bar goes
## with it); a ward down and off cooldown is cast when linh lực pays the cost, up for its window, with a bar when
## it carries a shield. Public for mechanism tests.
func cast_wards(s: FighterState) -> void:
	for xw in s.xwards:
		var w: ExtraWardDef = xw.def
		if w.model != ExtraWardDef.Model.CAST:
			continue
		if xw.up and t >= xw.until:
			xw.up = false
			if xw.bar != null:
				s.wshields.erase(xw.bar)
			xw.bar = null
		if not xw.up and t >= xw.ready:
			var cost: float = w.cost * s.qi_base
			if s.qi + 1e-9 < cost:
				continue
			s.qi -= cost
			s.spent += cost
			var scale_w: float = maxf(0.0, 1.0 + m(s, "cast_ward_dur", null) / 100.0)
			var dur_ms: int = mini(CombatConstants.ms(w.cooldown) - 1, CombatConstants.ms(w.up * scale_w)) \
					if w.up < w.cooldown else CombatConstants.ms(w.up * scale_w)
			xw.up = true
			xw.until = t + maxi(0, dur_ms)
			xw.ready = t + CombatConstants.ms(w.cooldown)
			if w.shield != 0.0:
				var bar_def := WardShieldDef.new()
				bar_def.size = w.shield
				bar_def.standing = false
				var bar := FighterState.ShieldState.new()
				bar.def = bar_def
				bar.left = w.shield * s.qi_base
				bar.quiet_since = t
				xw.bar = bar
				s.wshields.append(bar)


## Realm suppression (Combat Formulas H): 1 - s_g (1 - P), P = min(pierce_cap, max(0, pierce)).
func _supp(att: FighterState, dfn: FighterState, pierce: float) -> float:
	var gap: int = mini(maxi(0, dfn.p.realm - att.p.realm), 4)
	return 1.0 - k.supp[gap] * (1.0 - minf(k.pierce_cap, maxf(0.0, pierce)))


## The Down step (Effects rule 11; R5, R15c): a foe's cull Effect drops a side at or below its share; a side at
## 0 refuses Down with a refuse_down Effect while it has refusals (left at refuse_down_health), else its last acts
## strike and it goes Down.
func _defeat_check() -> void:
	for s in [a, b]:
		if s.hp > 0.0:
			var foe: FighterState = foe_of(s)
			for e in foe.p.effects:
				for act_def in e.actions:
					if act_def.verb == "cull" and s.hp <= float(act_def.arg) * s.hp_max and EffectRunner.holds(self, foe, e.conds, null):
						s.hp = 0.0
						if _log_enabled:
							_row(FightLogRow.Kind.CULL, s.label, &"", &"", [])
	var downs: Array = []
	for s in [a, b]:
		if s.hp <= 0.0 and not s.window_on:   # a window side is past its Down step
			downs.append(s)
	for s in downs:
		# Down step 1 (Effects rule 11): the first usable refusal whose conditions hold; its other actions run with it,
		# then the "refused" event (2026-11-14, both engines: conditions were not read, other actions never ran)
		var refuse: EffectDef = null
		for e in s.p.effects:
			if e.on == "down" and EffectRunner.allowed(self, s, e) and EffectRunner.holds(self, s, e.conds, {}):
				var has_refuse := false
				for act_def in e.actions:
					if act_def.verb == "refuse_down":
						has_refuse = true
				if has_refuse:
					refuse = e
					break
		if refuse != null and s.refusals_left > 0:
			EffectRunner.mark(self, s, refuse)
			s.refusals_left -= 1
			var share_rd: float = 0.0
			for act_def in refuse.actions:
				if act_def.verb == "refuse_down":
					share_rd = float((act_def.arg as Dictionary).get("hp_share", 0.0)) if act_def.arg is Dictionary else 0.0
					break
			s.hp = share_rd * s.hp_max if share_rd != 0.0 else k.refuse_down_health   # Nirvana: 30 % of maximum
			if _log_enabled:
				_row(FightLogRow.Kind.DOWN, s.label, &"", &"refused", [])
			var rest: Array = refuse.actions.filter(func(x): return x.verb != "refuse_down")
			if not rest.is_empty():
				depth += 1
				EffectRunner.run(self, s, refuse, rest, EffectRunner.scale(self, s, refuse, {}), {})
				depth -= 1
			EffectRunner.fire(self, s, "refused", {})
			continue
		# An extended last act (Effects rule 11, 2026-11-26; The Fifteenth Layer): the side stays in the fight for the
		# window, untargetable and inactive; only its named free hits fire. It replaces the side's other last acts and
		# its Down event, and opens once a fight. As engine.py defeat_check.
		var win_e: EffectDef = null
		var win_spec: Dictionary = {}
		if not s.window_used:
			for e in s.p.effects:
				for act_def in e.actions:
					if act_def.verb == "last_act_window" and EffectRunner.allowed(self, s, e):
						win_e = e
						win_spec = act_def.arg
						break
				if win_e != null:
					break
		if win_e != null:
			EffectRunner.mark(self, s, win_e)
			s.window_used = true
			s.window_on = true
			s.window_spec = win_spec
			s.window_every = CombatConstants.ms(float(win_spec.get("every", 1.0)))
			s.window_until = t + CombatConstants.ms(float(win_spec.seconds))
			s.window_next = t + s.window_every
			if _log_enabled:
				_row(FightLogRow.Kind.DOWN, s.label, &"", &"window", [])
			continue
		for e in s.p.effects:
			for act_def in e.actions:
				if act_def.verb == "last_act" and EffectRunner.allowed(self, s, e):
					EffectRunner.mark(self, s, e)
					var la: Dictionary = act_def.arg
					hit(s, foe_of(s), float(la.get("c", 0.0)), StringName(str(la.get("dtype", "phys"))), null, KIND_TRIGGER, true)
		# Down step 2's event: the "down" listeners that are neither refusals nor last acts (Final Clause)
		EffectRunner.fire(self, s, "down", {})
		s.down = true
		if _log_enabled:
			_row(FightLogRow.Kind.DOWN, s.label, &"", &"down", [])
	for s in [a, b]:
		if s.window_on:
			var spend: String = str(s.window_spec.get("spend", ""))
			if foe_of(s).down:   # the foe went Down within the window: a draw (Combat rule 10)
				s.down = true
			elif t >= s.window_until or (spend != "" and float(s.counters.get(spend, 0.0)) <= 0.0):
				s.down = true
				if _log_enabled:
					_row(FightLogRow.Kind.DOWN, s.label, &"", &"down", [])
			continue
		if not s.down and s.hp <= 0.0:
			s.down = true


## Logs an Effect firing or a banked payload (parity rows), when the log is on.
func log_effect(kind: FightLogRow.Kind, s: FighterState, eid: String, values: Array) -> void:
	if _log_enabled:
		_row(kind, s.label, &"", StringName(eid), values)


## The log rows so far (empty with the log off); for mechanism tests that drive [method act] directly.
func log_rows() -> Array[FightLogRow]:
	return _log


func _row(kind: FightLogRow.Kind, side: String, hit_kind: StringName, art_id: StringName, values: Array,
		other: String = "") -> void:
	var r := FightLogRow.new()
	r.kind = kind
	r.t_ms = t
	r.side = side
	r.hit_kind = hit_kind
	r.art_id = art_id
	r.other = other
	r.values = PackedFloat64Array(values)
	_log.append(r)


func _note_dmg(target: FighterState, layer: int) -> void:
	_last_dmg_layer[_idx(target)] = layer


static func _layer_of(dtype: StringName) -> int:
	if dtype == &"phys":
		return 0
	if dtype == &"soul":
		return 2
	return 1


func _result() -> FightResult:
	var r := FightResult.new()
	r.t_ms = t
	r.seconds = t / 1000.0
	if a.fled or b.fled:   # the fled side wins by knockout if the foe is at 0 or below; else flight, no winner
		if a.fled and not b.fled and b.hp <= 0.0:
			r.winner = FightResult.Winner.A
			r.ending = FightResult.Ending.KNOCKOUT
		elif b.fled and not a.fled and a.hp <= 0.0:
			r.winner = FightResult.Winner.B
			r.ending = FightResult.Ending.KNOCKOUT
		else:
			r.winner = FightResult.Winner.DRAW
			r.ending = FightResult.Ending.FLIGHT
	elif a.down and b.down:
		r.winner = FightResult.Winner.DRAW
		r.ending = FightResult.Ending.DRAW
	elif b.down:
		r.winner = FightResult.Winner.A
		r.ending = FightResult.Ending.KNOCKOUT
	elif a.down:
		r.winner = FightResult.Winner.B
		r.ending = FightResult.Ending.KNOCKOUT
	else:
		r.winner = FightResult.Winner.DRAW
		r.ending = FightResult.Ending.DRAW
		r.timed_out = true
	if r.ending == FightResult.Ending.KNOCKOUT:
		r.deciding_layer = _last_dmg_layer[1] if r.winner == FightResult.Winner.A else _last_dmg_layer[0]
	r.a_end = FighterEnd.of(a)
	r.b_end = FighterEnd.of(b)
	r.log_rows = _log
	return r
