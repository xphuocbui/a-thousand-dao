class_name Fight
extends RefCounted
## One fight between two compiled fighters on a millisecond timeline (ADR-0001 decision 1; Combat GDD rule 10).
## Ported from the sim's [code]Fight[/code] (tools/design/combat_sim/engine.py) in the same operation order; the
## parity suite (tests/parity) holds the two to 1e-6 on chance-free fixtures and statistically on chancy ones.
##
## Pure logic: no Node, scene, session or World DB. It reads its two [FighterProfile]s (never writing to them), the
## [CombatConstants] and one seeded [RandomNumberGenerator]. Slices 1-3: the pulse loop (element and status ticks,
## linh lực and health regeneration with Stagnation, the cleansing ward, fatigue, expiries and lockouts, shield
## recharge), arts on cooldown with charges, Slowed Time, Silence, the soul lockout and costs from linh lực, health,
## heart demon or divine sense; heal, restore, buff and cleanse arts; cast wards; the basic attack; companions;
## evade and crit rolls; hit damage (U x c x M x crit x more x realm suppression, dampened), conversion, the added
## Soul part, the [DefencePath]; debuff stacks and statuses on hit; soul attacks; the plain Down check.
## Effect mods join in the Effect slice; where the sim adds a mod, this engine adds nothing yet (x + 0.0 is exact,
## so parity holds).
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
## Sorts batches with no expiry after every timed one, as the sim's 1 << 40.
const _NO_EXPIRY_KEY := 1 << 40

## Side A and side B. Public for tests and the parts that receive them as arguments.
var a: FighterState
var b: FighterState
## The current time in ms.
var t: int = 0

var _k: CombatConstants
var _rng := RandomNumberGenerator.new()
var _order: Order
var _log_enabled: bool
var _log: Array[FightLogRow] = []
## Counts hits and ticks, so a per-hit ward pays one fee per hit (all its parts) and one per tick.
var _hit_id: int = 0


## Sets up both sides and their opening timers, as the sim's Fight does. [param fight_seed] seeds the fight's only
## random stream (the caller derives it from the session stream).
func _init(profile_a: FighterProfile, profile_b: FighterProfile, k: CombatConstants, fight_seed: int,
		order: Order = Order.COIN, log_enabled: bool = false) -> void:
	_k = k
	_rng.seed = fight_seed
	_order = order
	_log_enabled = log_enabled
	a = FighterState.new(profile_a, "A", k)
	b = FighterState.new(profile_b, "B", k)
	_open(a)
	_open(b)


func _open(s: FighterState) -> void:
	var p: FighterProfile = s.p
	for i in p.arts.size():
		# the opening cooldown honours art speed, then opening haste (Combat 13)
		var hz: float = 1.0 + p.art_speed_pct / 100.0
		var cd: float = maxf(_k.cooldown_min, p.arts[i].cd / hz)
		var first: float = maxf(_k.cooldown_min, cd / (1.0 + p.opening_haste_pct / 100.0))
		s.ready[i] = CombatConstants.ms(first)
	s.basic_ready = CombatConstants.ms(basic_cd(s))
	for j in p.companions.size():
		s.comp_ready[j] = CombatConstants.ms(p.companions[j].cd)


## Runs the fight to a Down or the time limit and returns the result.
func run() -> FightResult:
	var next_pulse: int = _k.pulse_ms
	var limit: int = _k.time_limit_ms
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
			next_pulse += _k.pulse_ms
		if _a_first():
			act(a)
			act(b)
		else:
			act(b)
			act(a)
		_defeat_check()
		if a.down or b.down:
			break
	return _result()


## The next event time of [param s] before [param tn]: arts ready after now, the basic attack, companions.
func _earliest(s: FighterState, tn: int) -> int:
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
	return _rng.randf() < 0.5


func _side(idx: int) -> FighterState:
	return a if idx == 0 else b


func _idx(s: FighterState) -> int:
	return 0 if s == a else 1


## The basic attack's cooldown in seconds (Combat A2: basic speed).
func basic_cd(s: FighterState) -> float:
	return maxf(_k.cooldown_min, _k.basic_cooldown / (1.0 + s.p.basic_speed_pct / 100.0))


## The Slowed Time factor on [param s]'s cooldowns (Effects AC-EF-72): 1 + slowed_time_pct per stack (up to the
## status's cap), less Slowed Time resistance.
func slow(s: FighterState) -> float:
	if s.statuses.is_empty():
		return 1.0
	var n: int = mini(s.st("slowed_time"), _k.slowed_cap)
	return 1.0 + _k.slowed_time_pct * float(n) * (1.0 - s.p.timer_resist / 100.0)


## One pulse for [param s] (Combat rule 10; Combat Defence & Healing; Status Catalogue): element debuff ticks, status
## ticks, regeneration (Stagnation dampens), health regeneration, the cleansing ward, fatigue, expiries (with
## lockouts), shield recharge. Public for mechanism tests.
func pulse(s: FighterState) -> void:
	# element ticks (Burn, Poison), each batch at its source's offence and stack power
	for x in s.debuffs.duplicate():
		var tab: Dictionary = _k.debuff.get(x.el, {})
		var c: float = float(tab.get("burn", 0.0)) + float(tab.get("poison", 0.0))
		if c != 0.0:
			var src: FighterState = _side(x.src_idx)
			var amount: float = src.u * c * x.n * src.p.m * (1.0 + src.bsum("dmg")) * _supp(src, s) * x.power
			tick(src, s, amount, StringName(str(_k.tick_type[x.el])), x.el)
	# status ticks
	for sid in s.statuses.keys():
		var stt: FighterState.StatusState = s.statuses[sid]
		var d: Dictionary = _k.status[sid]
		if str(d.kind) == "tick" and stt.stacks > 0:
			var src: FighterState = _side(stt.src_idx)
			var amount: float = src.u * float(d.c_tick) * float(stt.stacks) * src.p.m * _supp(src, s)
			if bool(d.get("on_qi", false)):
				s.qi = maxf(0.0, s.qi - amount)
				src.dealt += amount
				if _log_enabled:
					_row(FightLogRow.Kind.QI_TICK, src.label, &"", StringName(sid), [amount, s.hp, s.qi])
			else:
				tick(src, s, amount, StringName(str(d.dtype)), sid)
			if d.get("standing") != null and float(d.standing) != 0.0:
				var fee: float = float(d.standing) * src.qi_max()
				if src.qi < fee:
					stt.stacks = 0
				else:
					src.qi -= fee
	# regeneration; Stagnation dampens both pools by regen_dampen % per stack
	var stag: float = 1.0 + float(s.st("stagnation")) * _k.stagnation_dampen / 100.0
	var kk: float = _k.regen_k
	var bonus: float = s.p.regen_bonus + s.bsum("regen")
	var regen: float = s.qi_max() * (_k.regen_base + kk * log(1.0 + maxf(0.0, bonus) / kk)) / stag
	s.qi = minf(s.qi_use(), s.qi + regen)
	var hreg: float = s.hp_max * (s.p.hregen + s.bsum("hregen")) * s.p.bs_mult / stag
	if hreg > 0.0:
		heal(s, hreg)
	# the cleansing ward: stacks per pulse for a fee each, earliest expiry first; then a share of every batch
	var n_cl: int = s.p.cleanse_pulse
	while n_cl > 0 and not s.debuffs.is_empty():
		var fee_cl: float = s.p.cleanse_cost * s.qi_max()
		if s.qi < fee_cl:
			break
		s.qi -= fee_cl
		_sort_by_until(s.debuffs)
		s.debuffs[0].n -= 1.0
		if s.debuffs[0].n <= 0.0:
			s.debuffs.remove_at(0)
		s.touch_debuffs()
		n_cl -= 1
	if s.p.cleanse_share != 0.0:
		var kept: Array[FighterState.StackBatch] = []
		for x in s.debuffs:
			x.n *= (1.0 - s.p.cleanse_share)
			if x.n >= _k.cleanse_min_stacks:
				kept.append(x)
		s.debuffs = kept
		s.touch_debuffs()
	# fatigue
	if t >= _k.fatigue_start_ms:
		# pulses fall on whole seconds, so this is a whole number and Python's half-to-even round() never differs
		var n: int = roundi(float(t - _k.fatigue_start_ms) / 1000.0)
		var f: float = s.u * _k.fatigue_units * pow(float(1 + n), _k.fatigue_pow) * (s.g if _k.fatigue_by_realm else 1.0)
		s.hp -= f
		s.fat += f
	# expiries: stack batches, then statuses (a status with a lockout cannot return until it ends)
	if not s.buffs.is_empty():
		s.buffs = _live(s.buffs)
		s.touch_buffs()
	if not s.debuffs.is_empty():
		s.debuffs = _live(s.debuffs)
		s.touch_debuffs()
	for sid in s.statuses.keys():
		var stt2: FighterState.StatusState = s.statuses[sid]
		if stt2.until != -1 and stt2.until <= t:
			var lock: Variant = _k.status[sid].get("lockout")
			if lock != null and float(lock) != 0.0 and not stt2.no_lockout:
				s.lockouts[sid] = t + CombatConstants.ms(float(lock))
			s.statuses.erase(sid)
	# ward shield recharge: standing bars refill a share after a quiet spell (Combat Defence & Healing rule 9)
	for w in s.wshields:
		var cap: float = w.def.size * s.qi_base
		if w.def.standing and t - w.quiet_since >= _k.recharge_delay_ms and w.left < cap:
			w.left = minf(cap, w.left + _k.shield_recharge * cap)
			if w.def.pieces > 1:
				w.pieces_left = mini(w.def.pieces, w.pieces_left + 1)
	if _log_enabled:
		_row(FightLogRow.Kind.PULSE, s.label, &"", &"", [s.hp, s.qi])


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


## Heals [param s] by [param amount] before healing modifiers, up to health_max; Withering halves it, and with
## Crossing the Line it lands as damage instead (Combat Defence & Healing 19). Public for mechanism tests.
func heal(s: FighterState, amount: float) -> void:
	amount *= 1.0 + s.p.healing
	if s.st("withering") > 0:
		amount *= 1.0 + _k.withering_heal_taken
		var w: FighterState.StatusState = s.statuses["withering"]
		if w.crossing:
			s.hp -= amount
			_side(w.src_idx).dealt += amount
			return
	var got: float = minf(amount, s.hp_max - s.hp)
	if got > 0.0:
		s.hp += got
		s.healed += got


## [param s] acts at the current time: arts ready in slot order, the basic attack, companions. Public for
## mechanism tests.
func act(s: FighterState) -> void:
	if s.down:
		return
	if not s.xwards.is_empty():
		cast_wards(s)
	var o: FighterState = b if s == a else a
	var p: FighterProfile = s.p
	var speed_base: float = 1.0 + s.bsum("speed") + p.art_speed_pct / 100.0
	for i in p.arts.size():
		if t < s.ready[i]:
			continue
		var art: ArtDef = p.arts[i]
		if not art.tags.is_empty() and s.st("silence") > 0:
			var sil: FighterState.StatusState = s.statuses["silence"]
			if sil.tag != "" and art.tags.has(StringName(sil.tag)):
				continue
		if art.soul_pct != 0.0 and t < s.soul_ready:
			continue
		if not pay(s, art):
			continue
		var cd: float = maxf(_k.cooldown_min, art.cd / speed_base) * slow(s)
		s.charges[i] -= 1
		if s.charges[i] > 0:
			s.ready[i] = t + _k.cooldown_min_ms
		else:
			s.ready[i] = t + CombatConstants.ms(cd)
			s.charges[i] = art.charges
		s.fired[i] += 1
		if art.soul_pct != 0.0 or art.soul_part != 0.0:
			s.soul_ready = t + _k.soul_lockout_ms
		if art.buff_n != 0.0:
			add_stacks(s, s, str(art.element), art.buff_n, art.buff_dur, true)
		if art.cleanse != 0:
			cleanse(s, art.cleanse)
		if art.heal != 0.0:
			var got0: float = s.healed
			heal(s, s.u * art.heal * _k.health_mult)
			if s.healed > got0:
				s.qi = minf(s.qi_use(), s.qi + s.last_cost)
		if art.qi_restore != 0.0:
			s.qi = minf(s.qi_use(), s.qi + art.qi_restore * s.qi_max())
		if _log_enabled:
			_row(FightLogRow.Kind.ART, s.label, &"", art.id, [s.last_cost, s.hp, s.qi])
		if art.soul_pct != 0.0:
			soul_hit(s, o, art)
		elif art.c != 0.0:
			if art.split.is_empty():
				hit(s, o, art.c, art.dtype, art, KIND_ART)
			else:
				for sh in art.split:
					hit(s, o, art.c * sh, art.dtype, art, KIND_ART)
	while t >= s.basic_ready:
		hit(s, o, 1.0 + p.basic_coef_add, &"phys", null, KIND_BASIC)
		s.basic_ready += CombatConstants.ms(basic_cd(s) * slow(s))
	for j in p.companions.size():
		var comp: FighterProfile.Companion = p.companions[j]
		while t >= s.comp_ready[j]:
			hit(s, o, comp.c, comp.dtype, null, KIND_COMPANION)
			s.comp_ready[j] += CombatConstants.ms(maxf(_k.cooldown_min, comp.cd))


## Pays [param art]'s cost for [param s] (Combat E, R12): Ice stacks and Heavy Breath raise it; a heart-demon art
## pays from tâm ma, a divine-sense art spends a share of thần thức; otherwise linh lực, the hp_pay share and the
## art's health cost. Returns false, paying nothing, when it cannot. Public for mechanism tests.
func pay(s: FighterState, art: ArtDef) -> bool:
	var p: FighterProfile = s.p
	s.hp_paid = 0.0
	var cost_up: float = (1.0 + s.dsum("cost_up")) * (1.0 + float(s.st("heavy_breath")) * _k.heavy_cost_up)
	var cost: float = art.cost * _k.cost_scale * (1.0 - minf(_k.cost_red_cap, p.cost_red)) * cost_up * s.qi_base
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
	if art.hp_cost != 0.0 and s.hp - art.hp_cost * 1.0 * s.hp_max < _k.pay_keep_health:
		return false
	var qi_part: float = cost * (1.0 - p.hp_pay)
	var hp_part: float = cost * p.hp_pay * (s.hp_max / s.qi_base)
	if s.qi + 1e-6 < qi_part:
		return false
	var hp_total: float = hp_part + art.hp_cost * s.hp_max
	if hp_total > 0.0 and s.hp - hp_total < _k.pay_keep_health:
		return false
	s.qi -= qi_part
	s.hp -= hp_total
	s.hp_paid = hp_total
	s.spent += qi_part
	s.last_cost = qi_part
	return true


## One hit of coefficient [param c] from [param att] into [param dfn]: the evade roll, the crit roll (not for
## companions), D = U x c x M x crit x more x supp (Combat Formulas A, I; element stacks), Earth's dampening, the
## added Soul part split off, the [DefencePath] (per converted part), the Soul part against soul resistance, then
## on-hit sustain, debuff stacks and statuses. Returns the health removed. Public for mechanism tests.
func hit(att: FighterState, dfn: FighterState, c: float, dtype: StringName, art: ArtDef, kind: StringName) -> float:
	# evade, then crit: both rolls are drawn whenever they apply, so a zero chance never shifts the stream
	if _rng.randf() < evade_chance(att, dfn):
		return 0.0
	var is_crit := false
	if kind != KIND_COMPANION:
		is_crit = _rng.randf() < crit_chance(att, dfn)
	var crit: float = (att.p.crit_mult + dfn.dsum("critdmg_taken")) if is_crit else 1.0
	var phys: bool = dtype == &"phys"
	var more: float = 1.0 + att.bsum("dmg") + ((att.bsum("dmg_phys") + dfn.dsum("phys_taken")) if phys else 0.0)
	var m: float = att.p.m if kind == KIND_COMPANION else att.p.m * (art.m_mult if art != null else 1.0)
	var d: float = att.u * c * m * crit * more * _supp(att, dfn)
	var damp: float = dfn.bsum("phys_dampen") if phys else 0.0
	if damp != 0.0:
		d /= 1.0 + damp
	var d_in: float = d
	var soul_d: float = 0.0
	if art != null and art.soul_part != 0.0:
		soul_d = d * art.soul_part
		d -= soul_d
	_hit_id += 1
	var dealt: float
	if art != null and art.convert_share != 0.0:
		# conversion: each part meets its own type's defence (Combat Damage Types)
		var cd_part: float = d * art.convert_share
		dealt = DefencePath.defend(_k, att, dfn, d - cd_part, dtype, art, false, t, _hit_id)
		dealt += DefencePath.defend(_k, att, dfn, cd_part, art.convert_to, art, false, t, _hit_id)
	else:
		dealt = DefencePath.defend(_k, att, dfn, d, dtype, art, false, t, _hit_id)
	if soul_d != 0.0:
		var sr: float = _soul_res(dfn)
		var sd: float = soul_d / (1.0 + sr / 100.0) if sr >= 0.0 else soul_d * (1.0 + absf(sr) / 100.0)
		dfn.hp -= sd
		dealt += sd
	att.dealt += dealt
	att.direct_dmg += dealt
	var gain: float = att.p.gain_on_hit * att.qi_max() + att.p.leech_qi * dealt
	att.qi = minf(att.qi_use(), att.qi + gain)
	if att.p.leech_hp != 0.0:
		heal(att, att.p.leech_hp * dealt)
	if _log_enabled:
		var id: StringName = art.id if art != null else kind
		_row(FightLogRow.Kind.HIT, att.label, kind, id, [d_in, dealt, dfn.hp, dfn.qi, att.hp, att.qi])
	if art != null and art.debuff_n != 0.0:
		add_stacks(att, dfn, str(art.element), art.debuff_n, art.debuff_dur, false)
	if art != null:
		for spec in art.statuses:
			apply_status(att, dfn, spec)
	return dealt


## A tick of [param amount] and type [param dtype] from [param src]'s status or element [param sid] into
## [param s]: through the [DefencePath] as a tick (no minimum, no block, shields only where they stop ticks).
## Returns the health removed.
func tick(src: FighterState, s: FighterState, amount: float, dtype: StringName, sid: String) -> float:
	_hit_id += 1
	var dealt: float = DefencePath.defend(_k, src, s, amount, dtype, null, true, t, _hit_id)
	src.dealt += dealt
	if _log_enabled:
		_row(FightLogRow.Kind.TICK, src.label, &"", StringName(sid), [amount, dealt, s.hp, s.qi])
	return dealt


## A soul attack by [param att] with [param art] (Combat 24, E2): rho from both sides' divine sense left and the
## defender's soul resistance; no effect below rho_min; else a share of the defender's health and linh lực, capped
## at soul_cap. Returns the health removed. Public for mechanism tests.
func soul_hit(att: FighterState, dfn: FighterState, art: ArtDef) -> float:
	var ds_att: float = att.p.divine_sense * (1.0 - att.ts_spent)
	var ds_def: float = dfn.p.divine_sense * (1.0 - dfn.ts_spent)
	var sr: float = _soul_res(dfn)
	var rho: float = ds_att / (ds_def * (1.0 + sr / 100.0)) if sr >= 0.0 else ds_att * (1.0 + absf(sr) / 100.0) / ds_def
	if rho < _k.rho_min:
		return 0.0
	var pct: float = minf(art.soul_pct * (1.0 + att.p.x_soul / 100.0) * pow(rho, _k.soul_beta) * _supp(att, dfn), _k.soul_cap)
	var lh: float = pct * dfn.hp_max
	var lq: float = pct * dfn.qi_max()
	dfn.hp -= lh
	dfn.qi = maxf(0.0, dfn.qi - lq)
	att.dealt += lh
	att.direct_dmg += lh
	if _log_enabled:
		_row(FightLogRow.Kind.SOUL, att.label, &"", art.id, [lh, lq, dfn.hp, dfn.qi])
	return lh


func _soul_res(dfn: FighterState) -> float:
	return dfn.p.soul_res + float(dfn.st("slackened_soul")) * _k.slackened_soul_res


## Grants [param n] stacks of element [param el] from [param src] to [param target] (Effects rule 9a): a buff batch
## or a debuff batch, lasting [param dur] seconds (-1: the fight) scaled by the source's stack duration %, at least
## min_batch. Public for mechanism tests.
func add_stacks(src: FighterState, target: FighterState, el: String, n: float, dur: float, is_buff: bool) -> void:
	if n == 0.0:
		return
	var kind: String = "buff" if is_buff else "debuff"
	if dur >= 0.0 and not src.p.stack_dur.is_empty():
		dur = dur * (1.0 + StackMath.stack_pct(src.p.stack_dur, el, kind) / 100.0)
	var until: int = -1 if dur < 0.0 else t + CombatConstants.ms(maxf(_k.min_batch, dur))
	var batch := FighterState.StackBatch.new()
	batch.el = el
	batch.n = n
	batch.until = until
	batch.src_idx = _idx(src)
	batch.src_p = src.p
	batch.length = -1 if until == -1 else until - t
	# a buff's power reads the holder's profile, a debuff's its source's (the sim's bsum / dsum)
	batch.power = StackMath.stack_power(_k, target.p if is_buff else src.p, el, kind)
	if is_buff:
		target.buffs.append(batch)
		target.touch_buffs()
	else:
		target.debuffs.append(batch)
		target.touch_debuffs()
	if _log_enabled:
		_row(FightLogRow.Kind.STACKS, src.label, &"", StringName(el), [n, float(until), 1.0 if is_buff else 0.0],
				target.label)


## Applies status [param spec] from [param src] to [param target] (Status Catalogue; Combat Formulas F; Effects
## R22): nothing during its lockout; a chance below 1 is rolled within the chance clamp; a new curse needs a free
## curse slot; curses last 1 to curse_duration_max pulses; stacks add up to the cap; the duration restarts.
## Public for mechanism tests.
func apply_status(src: FighterState, target: FighterState, spec: StatusSpec) -> void:
	var sid: String = spec.id
	var d: Dictionary = _k.status[sid]
	if t < int(target.lockouts.get(sid, -1)):
		return
	var is_curse: bool = str(d.kind) == "curse"
	var chance: float = spec.chance
	var resist: float = 0.0   # status resistance arrives with Effect mods
	if chance <= 0.0:
		return
	if not (chance >= 1.0 and resist <= 0.0):
		if _rng.randf() >= minf(_k.status_chance_max, maxf(_k.status_chance_min, chance * (1.0 - resist))):
			return
	if is_curse and not target.statuses.has(sid):
		var live: int = 0
		for other in target.statuses:
			if str(_k.status[other].kind) == "curse":
				live += 1
		if live >= _k.curse_slots:
			return
	var dur_v: Variant = spec.extra["dur"] if spec.extra.has("dur") else d.get("dur")
	var has_dur: bool = dur_v != null
	var dur: float = float(dur_v) if has_dur else 0.0
	if has_dur and is_curse:
		dur = maxf(1.0, minf(_k.curse_duration_max, dur))
	var st: FighterState.StatusState = target.statuses.get(sid)
	var cap_v: Variant = spec.extra["cap"] if spec.extra.has("cap") else d.get("cap")
	if st == null:
		st = FighterState.StatusState.new()
		target.statuses[sid] = st
	st.stacks = st.stacks + spec.stacks if cap_v == null else mini(int(cap_v), st.stacks + spec.stacks)
	st.src_idx = _idx(src)
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
		_row(FightLogRow.Kind.STATUS, src.label, &"", StringName(sid), [float(st.stacks), float(st.until)],
				target.label)


## Cleanses up to [param n] debuff stacks from [param s], earliest expiry first (of element [param el] only, when
## given). Returns the stacks removed. Public for mechanism tests.
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
	return removed


## The chance [param dfn] evades a hit from [param att] (Combat Formulas I): evade plus the evade of its up wards (a
## reserved ward always counts, others need live linh lực), less Wind debuffs on it, less the attacker's accuracy
## (raised by Thunder buffs, lowered by Earth debuffs), within 0 and evade_cap.
func evade_chance(att: FighterState, dfn: FighterState) -> float:
	var w_ev: float = 0.0
	for xw in dfn.xwards:
		if xw.up and (xw.def.model == ExtraWardDef.Model.RESERVED or dfn.qi > 0.0):
			w_ev += xw.def.evade
	w_ev /= 100.0
	var p_ev: float = dfn.p.evade + w_ev - dfn.dsum("evade_down") - (att.p.acc + att.bsum("acc") - att.dsum("acc_down"))
	return minf(_k.evade_cap, maxf(0.0, p_ev))


## The chance a hit from [param att] on [param dfn] crits (Combat Formulas I): crit plus Thunder buffs on the
## attacker and Thunder debuffs on the defender, within crit_cap.
func crit_chance(att: FighterState, dfn: FighterState) -> float:
	return minf(_k.crit_cap, att.p.crit + att.bsum("crit") + dfn.dsum("crit_taken"))


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
			xw.up = true
			xw.until = t + CombatConstants.ms(w.up)
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


## Realm suppression (Combat Formulas H): 1 - s_g (1 - P); pierce P joins with Effect mods.
func _supp(att: FighterState, dfn: FighterState) -> float:
	var gap: int = mini(maxi(0, dfn.p.realm - att.p.realm), 4)
	return 1.0 - _k.supp[gap] * (1.0 - minf(_k.pierce_cap, 0.0))


func _defeat_check() -> void:
	if a.hp <= 0.0:
		a.down = true
	if b.hp <= 0.0:
		b.down = true


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


func _result() -> FightResult:
	var r := FightResult.new()
	r.t_ms = t
	r.seconds = t / 1000.0
	if a.down and b.down:
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
	r.a_end = FighterEnd.of(a)
	r.b_end = FighterEnd.of(b)
	r.log_rows = _log
	return r
