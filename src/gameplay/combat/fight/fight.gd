class_name Fight
extends RefCounted
## One fight between two compiled fighters on a millisecond timeline (ADR-0001 decision 1; Combat GDD rule 10).
## Ported from the sim's [code]Fight[/code] (tools/design/combat_sim/engine.py) in the same operation order; the
## parity suite (tests/parity) holds the two to 1e-6 on chance-free fixtures.
##
## Pure logic: no Node, scene, session or World DB. It reads its two [FighterProfile]s (never writing to them), the
## [CombatConstants] and one seeded [RandomNumberGenerator]. Slices 1-2: the pulse loop (linh lực and health
## regeneration, fatigue, shield recharge), arts on cooldown with charges and linh lực or health costs, heal and
## restore arts, cast wards, the basic attack, companions, evade and crit rolls, hit damage (U x c x M x crit x
## realm suppression), conversion, and the [DefencePath]; the plain Down check.
## Effect mods, stacks, statuses and soul attacks join in later slices; where the sim adds a mod there, this
## engine adds nothing yet (x + 0.0 is exact, so parity holds).
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

## Side A and side B. Public for tests and the later slices' parts, which receive them as arguments.
var a: FighterState
var b: FighterState
## The current time in ms.
var t: int = 0

var _k: CombatConstants
var _rng := RandomNumberGenerator.new()
var _order: Order
var _log_enabled: bool
var _log: Array[FightLogRow] = []
## Counts hits and ticks, so a per-hit ward pays one fee per hit (all its parts).
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


## The basic attack's cooldown in seconds (Combat A2: basic speed).
func basic_cd(s: FighterState) -> float:
	return maxf(_k.cooldown_min, _k.basic_cooldown / (1.0 + s.p.basic_speed_pct / 100.0))


## One pulse for [param s]: regeneration, health regeneration, fatigue (Combat rule 10, Formulas; Combat Defence
## & Healing). Public for mechanism tests.
func pulse(s: FighterState) -> void:
	var kk: float = _k.regen_k
	var regen: float = s.qi_max() * (_k.regen_base + kk * log(1.0 + maxf(0.0, s.p.regen_bonus) / kk))
	s.qi = minf(s.qi_use(), s.qi + regen)
	var hreg: float = s.hp_max * s.p.hregen * s.p.bs_mult
	if hreg > 0.0:
		heal(s, hreg)
	if t >= _k.fatigue_start_ms:
		# pulses fall on whole seconds, so this is a whole number and Python's half-to-even round() never differs
		var n: int = roundi(float(t - _k.fatigue_start_ms) / 1000.0)
		var f: float = s.u * _k.fatigue_units * pow(float(1 + n), _k.fatigue_pow) * (s.g if _k.fatigue_by_realm else 1.0)
		s.hp -= f
		s.fat += f
	# ward shield recharge: standing bars refill a share after a quiet spell (Combat Defence & Healing rule 9)
	for w in s.wshields:
		var cap: float = w.def.size * s.qi_base
		if w.def.standing and t - w.quiet_since >= _k.recharge_delay_ms and w.left < cap:
			w.left = minf(cap, w.left + _k.shield_recharge * cap)
			if w.def.pieces > 1:
				w.pieces_left = mini(w.def.pieces, w.pieces_left + 1)
	if _log_enabled:
		_row(FightLogRow.Kind.PULSE, s.label, &"", &"", [s.hp, s.qi])


## Heals [param s] by [param amount] before healing modifiers, up to health_max. Public for mechanism tests.
func heal(s: FighterState, amount: float) -> void:
	amount *= 1.0 + s.p.healing
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
	var speed_base: float = 1.0 + p.art_speed_pct / 100.0
	for i in p.arts.size():
		if t < s.ready[i]:
			continue
		var art: ArtDef = p.arts[i]
		if not pay(s, art):
			continue
		var cd: float = maxf(_k.cooldown_min, art.cd / speed_base)
		s.charges[i] -= 1
		if s.charges[i] > 0:
			s.ready[i] = t + _k.cooldown_min_ms
		else:
			s.ready[i] = t + CombatConstants.ms(cd)
			s.charges[i] = art.charges
		s.fired[i] += 1
		if art.heal != 0.0:
			var got0: float = s.healed
			heal(s, s.u * art.heal * _k.health_mult)
			if s.healed > got0:
				s.qi = minf(s.qi_use(), s.qi + s.last_cost)
		if art.qi_restore != 0.0:
			s.qi = minf(s.qi_use(), s.qi + art.qi_restore * s.qi_max())
		if _log_enabled:
			_row(FightLogRow.Kind.ART, s.label, &"", art.id, [s.last_cost, s.hp, s.qi])
		if art.c != 0.0:
			if art.split.is_empty():
				hit(s, o, art.c, art.dtype, art, KIND_ART)
			else:
				for sh in art.split:
					hit(s, o, art.c * sh, art.dtype, art, KIND_ART)
	while t >= s.basic_ready:
		hit(s, o, 1.0 + p.basic_coef_add, &"phys", null, KIND_BASIC)
		s.basic_ready += CombatConstants.ms(basic_cd(s))
	for j in p.companions.size():
		var comp: FighterProfile.Companion = p.companions[j]
		while t >= s.comp_ready[j]:
			hit(s, o, comp.c, comp.dtype, null, KIND_COMPANION)
			s.comp_ready[j] += CombatConstants.ms(maxf(_k.cooldown_min, comp.cd))


## Pays [param art]'s cost for [param s] (Combat E: linh lực, the hp_pay share and the art's health cost).
## Returns false, paying nothing, when it cannot. Public for mechanism tests.
func pay(s: FighterState, art: ArtDef) -> bool:
	var p: FighterProfile = s.p
	s.hp_paid = 0.0
	var cost: float = art.cost * _k.cost_scale * (1.0 - minf(_k.cost_red_cap, p.cost_red)) * s.qi_base
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
## companions), D = U x c x M x crit x supp (Combat Formulas A, I), the [DefencePath] (per converted part), then
## on-hit sustain. Returns the health removed. Public for mechanism tests.
func hit(att: FighterState, dfn: FighterState, c: float, dtype: StringName, art: ArtDef, kind: StringName) -> float:
	# evade, then crit: both rolls are drawn whenever they apply, so a zero chance never shifts the stream
	if _rng.randf() < evade_chance(att, dfn):
		return 0.0
	var is_crit := false
	if kind != KIND_COMPANION:
		is_crit = _rng.randf() < crit_chance(att)
	var crit: float = att.p.crit_mult if is_crit else 1.0
	var m: float = att.p.m if kind == KIND_COMPANION else att.p.m * (art.m_mult if art != null else 1.0)
	var d: float = att.u * c * m * crit * _supp(att, dfn)
	var d_in: float = d
	_hit_id += 1
	var dealt: float
	if art != null and art.convert_share != 0.0:
		# conversion: each part meets its own type's defence (Combat Damage Types)
		var cd_part: float = d * art.convert_share
		dealt = DefencePath.defend(_k, att, dfn, d - cd_part, dtype, art, false, t, _hit_id)
		dealt += DefencePath.defend(_k, att, dfn, cd_part, art.convert_to, art, false, t, _hit_id)
	else:
		dealt = DefencePath.defend(_k, att, dfn, d, dtype, art, false, t, _hit_id)
	att.dealt += dealt
	att.direct_dmg += dealt
	var gain: float = att.p.gain_on_hit * att.qi_max() + att.p.leech_qi * dealt
	att.qi = minf(att.qi_use(), att.qi + gain)
	if att.p.leech_hp != 0.0:
		heal(att, att.p.leech_hp * dealt)
	if _log_enabled:
		var id: StringName = art.id if art != null else kind
		_row(FightLogRow.Kind.HIT, att.label, kind, id, [d_in, dealt, dfn.hp, dfn.qi, att.hp, att.qi])
	return dealt


## The chance [param dfn] evades a hit from [param att] (Combat Formulas I): evade plus the evade of its up
## wards (a reserved ward always counts, others need live linh lực), less accuracy, within 0 and evade_cap.
func evade_chance(att: FighterState, dfn: FighterState) -> float:
	var w_ev: float = 0.0
	for xw in dfn.xwards:
		if xw.up and (xw.def.model == ExtraWardDef.Model.RESERVED or dfn.qi > 0.0):
			w_ev += xw.def.evade
	w_ev /= 100.0
	return minf(_k.evade_cap, maxf(0.0, dfn.p.evade + w_ev - att.p.acc))


## The chance a hit from [param att] crits, within crit_cap (Combat Formulas I).
func crit_chance(att: FighterState) -> float:
	return minf(_k.crit_cap, att.p.crit)


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


func _row(kind: FightLogRow.Kind, side: String, hit_kind: StringName, art_id: StringName, values: Array) -> void:
	var r := FightLogRow.new()
	r.kind = kind
	r.t_ms = t
	r.side = side
	r.hit_kind = hit_kind
	r.art_id = art_id
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
