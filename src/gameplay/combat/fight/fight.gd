class_name Fight
extends RefCounted
## One fight between two compiled fighters on a millisecond timeline (ADR-0001 decision 1; Combat GDD rule 10).
## Ported from the sim's [code]Fight[/code] (tools/design/combat_sim/engine.py) in the same operation order; the
## parity suite (tests/parity) holds the two to 1e-6 on chance-free fixtures.
##
## Pure logic: no Node, scene, session or World DB. It reads its two [FighterProfile]s (never writing to them), the
## [CombatConstants] and one seeded [RandomNumberGenerator]. Slice 1: the pulse loop (linh lực and health
## regeneration, fatigue), arts on cooldown with charges and linh lực or health costs, heal and restore arts, the
## basic attack, companions, hit damage (U x c x M x realm suppression) and the [DefencePath]; the plain Down check.
## Effect mods, stacks, statuses, crits and evades join in later slices; where the sim adds a mod there, this
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


## One hit of coefficient [param c] from [param att] into [param dfn] (Combat Formulas A: D = U x c x M x
## supp), through the [DefencePath], then on-hit sustain. Returns the health removed. Public for mechanism tests.
func hit(att: FighterState, dfn: FighterState, c: float, dtype: StringName, art: ArtDef, kind: StringName) -> float:
	var m: float = att.p.m if kind == KIND_COMPANION else att.p.m * (art.m_mult if art != null else 1.0)
	var d: float = att.u * c * m * _supp(att, dfn)
	var d_in: float = d
	var dealt: float = DefencePath.defend(_k, att, dfn, d, dtype, art, false)
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
