class_name TribulationRules
extends RefCounted
## Pure rules, formulas, draw, hashing, and data linting for Heavenly Tribulation (Thiên Kiếp).
## Design: design/gdd/thien-kiep.md. Data: assets/data/tribulation_rules.json,
## assets/data/tribulation_bosses.json.
##
## Zero I/O, zero WorldDB mutations, zero global RNG usage: every function is pure and
## deterministic from its inputs.
##
## Usage:
## [codeblock]
## var errs: PackedStringArray = TribulationRules.validate(gd)
## var step: Dictionary = TribulationRules.step_for(gd, player.realm_index)
## var drawn: Array = TribulationRules.draw_waves(pool, int(step.wave_count), tk_id)
## [/codeblock]

const RULES_FILE := "tribulation_rules"
const BOSSES_FILE := "tribulation_bosses"
const THREAT_KINDS := ["body", "qi", "soul"]
const EPS := 1e-9


## Returns the raw tribulation_rules.json dictionary from [param gd].
static func config(gd: GameData) -> Dictionary:
	return gd.file(RULES_FILE)


## Returns true when Heavenly Tribulation is enabled in config (AC-TK-04; false keeps Realms fallback).
static func is_enabled(gd: GameData) -> bool:
	return bool(config(gd).get("tribulation_enabled", true))


## Returns the tribulation step row whose from_realm matches [param from_realm_idx], or {} if unlisted.
static func step_for(gd: GameData, from_realm_idx: int) -> Dictionary:
	var cfg: Dictionary = config(gd)
	for step in cfg.get("tribulation_steps", []):
		if not (step is Dictionary):
			continue
		var from_idx: int = gd.realm_index(str(step.get("from_realm", "")))
		if from_idx == from_realm_idx and from_idx >= 0:
			return step
	return {}


## Returns the tribulation step row with [param step_id], or {} if not found.
static func step_by_id(gd: GameData, step_id: String) -> Dictionary:
	var cfg: Dictionary = config(gd)
	for step in cfg.get("tribulation_steps", []):
		if step is Dictionary and str(step.get("id", "")) == step_id:
			return step
	return {}


## True when a successful breakthrough roll leaving [param from_realm_idx] must hand off to a tribulation
## (Rule 1, AC-TK-01..04, AC-TK-06). Pass [param session_enabled] to apply a playthrough's New Game toggle.
static func should_trigger(gd: GameData, from_realm_idx: int, session_enabled: Variant = null) -> bool:
	var on: bool = bool(session_enabled) if session_enabled != null else is_enabled(gd)
	return on and not step_for(gd, from_realm_idx).is_empty()


## Returns all boss records from tribulation_bosses.json serving [param step_id].
static func bosses_for_step(gd: GameData, step_id: String) -> Array:
	var out: Array = []
	var data: Dictionary = gd.file(BOSSES_FILE)
	for b in data.get("bosses", []):
		if b is Dictionary and Array(b.get("steps", [])).has(step_id):
			out.append(b)
	return out


## Formulas A: wave pool ramp multiplier w_k = pool_ramp ^ (k - 1) for 1-based wave [param k].
static func wave_multiplier(pool_ramp: float, k: int) -> float:
	return pow(pool_ramp, float(maxi(0, k - 1)))


## Formulas A (AC-TK-60, AC-TK-61): effective boss pool multiplier m_eff = min(m_cap, boss_pool_mult * w_k).
## Returns {m_eff, capped, raw}.
static func effective_pool_mult(boss_pool_mult: float, pool_ramp: float, k: int, m_cap: float = 10.0) -> Dictionary:
	var raw: float = boss_pool_mult * wave_multiplier(pool_ramp, k)
	var capped: bool = raw > m_cap + EPS
	var m_eff: float = minf(m_cap, raw)
	return {"m_eff": m_eff, "capped": capped, "raw": raw}


## Formulas B (Rule 7, AC-TK-25..30, AC-TK-43): starting health and linh lực shares for the next wave.
## Health carries with no floor and no healing (or 1 health on a double-KO win). Linh lực carries and
## recovers [param rest_pulses] pulses of regeneration on Combat's log curve; curses do not carry.
## Returns {h_next, q_next}.
static func carry_over_shares(
		health_end: float,
		health_max: float,
		qi_end: float,
		qi_max: float,
		rest_pulses: int,
		regen_base: float,
		regen_k: float,
		regen_bonus: float,
		double_ko_win: bool = false
) -> Dictionary:
	var h_eff: float = 1.0 if double_ko_win else health_end
	var h_next: float = clampf(h_eff / health_max, 0.0, 1.0) if health_max > 0.0 else 0.0
	var bonus: float = maxf(0.0, regen_bonus)
	var per_pulse: float = regen_base + (regen_k * log(1.0 + bonus / regen_k) if regen_k > 0.0 else bonus)
	var pulses: float = float(maxi(0, rest_pulses))
	var qi_rec: float = minf(qi_max, maxf(0.0, qi_end) + pulses * qi_max * per_pulse)
	var q_next: float = clampf(qi_rec / qi_max, 0.0, 1.0) if qi_max > 0.0 else 0.0
	return {"h_next": h_next, "q_next": q_next}


## Formulas C (AC-TK-62): Deity Transformation breakthrough roll target from measured edge survival p_t_ref.
## roll_target = 0.20 / max(p_t_ref, 0.20).
static func roll_target(p_t_ref: float) -> float:
	return 0.20 / maxf(p_t_ref, 0.20)


## Formulas C (AC-TK-63, AC-TK-64): wave_loss pre-check estimate.
## r_b = F_boss / F_player; loss_k = r_b * w_k; sum(loss_k) > 1 means the run fails.
## Returns {r_b, losses, total_loss, fails}.
static func wave_loss_estimate(f_boss: float, f_player: float, wave_count: int, pool_ramp: float) -> Dictionary:
	var r_b: float = f_boss / f_player if f_player > 0.0 else 0.0
	var losses: Array[float] = []
	var total: float = 0.0
	for k in range(1, maxi(0, wave_count) + 1):
		var lk: float = r_b * wave_multiplier(pool_ramp, k)
		losses.append(lk)
		total += lk
	return {"r_b": r_b, "losses": losses, "total_loss": total, "fails": total > 1.0}


## Rule 4 (AC-TK-17, AC-TK-21): canonical FNV-1a 32-bit hash of the compiled [param profile] and [param prep].
## Any change to profile stats, ward, art slots/order, prepared items, pills, or place changes the hash.
static func setup_hash(profile: FighterProfile, prep: Dictionary = {}) -> int:
	var parts: PackedStringArray = []
	if profile != null:
		parts.append("r=%d;sm=%.6f;m=%.6f;nb=%.6f;nq=%.6f" % [
			profile.realm, profile.stage_mult, profile.m, profile.n_body, profile.n_qi])
		parts.append("w=%.6f,%.6f,%.6f,%.6f;b=%.6f,%.6f,%.6f,%.6f" % [
			profile.ward_pts, profile.ward_layer, profile.drain, profile.block,
			profile.body_pts, profile.body_block, profile.bs_mult, profile.body_shield])
		parts.append("c=%.6f,%.6f,%.6f,%.6f;rg=%.6f,%.6f,%.6f,%.6f,%.6f" % [
			profile.crit, profile.crit_mult, profile.evade, profile.acc,
			profile.regen_bonus, profile.hregen, profile.healing, profile.cost_red, profile.reserved])
		parts.append("ds=%.6f;sr=%.6f;xs=%.6f;tm=%.6f;tr=%.6f" % [
			profile.divine_sense, profile.soul_res, profile.x_soul, profile.tam_ma, profile.timer_resist])
		parts.append("res=" + _canonical(profile.resist))
		parts.append("pur=" + _canonical(profile.purity))
		parts.append("pill=" + _canonical(profile.pill))
		var art_parts: PackedStringArray = []
		for a in profile.arts:
			art_parts.append("%s:%.4f:%.4f:%.4f:%s:%s:%.4f" % [
				str(a.id), a.c, a.cd, a.cost, str(a.element), str(a.dtype), a.escape])
		parts.append("arts=[" + ",".join(art_parts) + "]")
		parts.append("feeds=" + _canonical(profile.feeds))
		var eff_ids: PackedStringArray = []
		for e in profile.effects:
			eff_ids.append(e.id)
		parts.append("eff=[" + ",".join(eff_ids) + "]")
		var ward_ids: PackedStringArray = []
		for w in profile.wards:
			ward_ids.append("%s:%d:%.4f" % [w.id, int(w.model), w.block])
		parts.append("xwards=[" + ",".join(ward_ids) + "]")
		var sh_parts: PackedStringArray = []
		for sh in profile.shields:
			sh_parts.append("%.4f:%d" % [sh.size, sh.pieces])
		parts.append("sh=[" + ",".join(sh_parts) + "]")
	else:
		parts.append("profile=null")
	parts.append("prep=" + _canonical(prep))
	return RngUtils.stable_hash("|".join(parts))


## Rule 4 (AC-TK-16, AC-TK-17, AC-TK-21): deterministic tribulation id derived from world seed,
## character id, step id, absolute season, and canonical setup hash.
static func tribulation_id(world_seed: int, char_id: String, step_id: String, abs_season: int, setup_h: int) -> int:
	return RngUtils.stable_hash("tk:%d:%s:%s:%d:%d" % [world_seed, char_id, step_id, abs_season, setup_h])


## Rule 11 (AC-TK-19): deterministic per-wave fight seed derived from [param tk_id] and 1-based [param wave_k].
static func wave_seed(tk_id: int, wave_k: int) -> int:
	return RngUtils.stable_hash("tk_wave:%d:%d" % [tk_id, wave_k])


## Rules 4 & 11 (AC-TK-13..15, AC-TK-20): draws [param wave_count] distinct bosses from [param pool],
## weighted by each boss's "weight", without replacement, using a fresh local RNG seeded from [param tk_id].
## Leaves any external RNG untouched.
static func draw_waves(pool: Array, wave_count: int, tk_id: int) -> Array:
	var drawn: Array = []
	if pool.is_empty() or wave_count <= 0:
		return drawn
	var local_rng := RandomNumberGenerator.new()
	local_rng.seed = tk_id
	var remaining: Array = pool.duplicate()
	var count: int = mini(wave_count, remaining.size())
	for _i in count:
		var weights: Array = []
		for rec in remaining:
			weights.append(float(rec.get("weight", 0.0)))
		var idx: int = RngUtils.weighted_index(local_rng, weights)
		if idx < 0:
			break
		drawn.append(remaining[idx])
		remaining.remove_at(idx)
	return drawn


## Rule 8 (AC-TK-81): true if [param profile] has any slotted escape art.
static func has_escape_art(profile: FighterProfile) -> bool:
	if profile == null:
		return false
	for a in profile.arts:
		if a.escape > 0.0:
			return true
	return false


## Formulas E (AC-TK-79): computes total W cost of [param mods] against [param weights].
## Returns {total_w, unknown_keys, negative_keys}.
static func buff_weight_cost(mods: Array, weights: Dictionary) -> Dictionary:
	var total_w: float = 0.0
	var unknown: PackedStringArray = []
	var negative: PackedStringArray = []
	for m in mods:
		if not (m is Dictionary):
			continue
		var stat: String = str(m.get("stat", ""))
		var val: float = float(m.get("value", 0.0))
		if val < 0.0:
			negative.append(stat)
		if not weights.has(stat) or float(weights[stat]) <= 0.0:
			unknown.append(stat)
		else:
			total_w += val * float(weights[stat])
	return {"total_w": total_w, "unknown_keys": unknown, "negative_keys": negative}


## Alias for [method lint] validating tribulation rules and boss pool data (AC-TK-68..79).
static func validate(gd: GameData, rules_override: Dictionary = {}, bosses_override: Variant = null) -> PackedStringArray:
	return lint(gd, rules_override, bosses_override)


## Formulas D & E data linter (AC-TK-68..79). Validates rules, tempered buffs, and boss pool records.
## Pass [param rules_override] to test modified knobs and [param bosses_override] (an Array, including [])
## to test an alternative boss pool. Returns an empty PackedStringArray when all checks pass.
static func lint(gd: GameData, rules_override: Dictionary = {}, bosses_override: Variant = null) -> PackedStringArray:
	var errors: PackedStringArray = []
	var rules: Dictionary = config(gd).duplicate(true)
	for k in rules_override:
		rules[k] = rules_override[k]
	var bosses: Array = bosses_override if bosses_override is Array else Array(gd.file(BOSSES_FILE).get("bosses", []))

	var wave_count: int = int(rules.get("wave_count", 3))
	var pool_ramp: float = float(rules.get("pool_ramp", 1.5))
	var bm_max: float = float(rules.get("bm_max", 1.5))
	var m_cap: float = float(rules.get("m_cap", 10.0))
	var band_min: float = float(rules.get("band_min", 0.10))
	var band_max: float = float(rules.get("band_max", 0.35))
	var stall_time: float = float(rules.get("stall_time", 60.0))
	var soul_share_max: float = float(rules.get("soul_share_max", 0.50))
	var kind_share_max: float = float(rules.get("kind_share_max", 0.50))
	var pool_target: int = int(rules.get("pool_target", 6))
	var tempered_buff_w: float = float(rules.get("tempered_buff_w", 60.0))

	var ref: Dictionary = rules.get("baseline_ref", {})
	var ref_off: float = float(ref.get("off", 1500.0))
	var ref_ehp: float = float(ref.get("ehp", 9400.0))
	var ref_f: float = ref_off * ref_ehp
	var weights: Dictionary = rules.get("stat_power_weights", {})
	var steps: Array = Array(rules.get("tribulation_steps", []))

	# Global ramp & multiplier bounds (AC-TK-68, AC-TK-69)
	if pool_ramp < 1.0 - EPS:
		errors.append("ramp: pool_ramp %.4f must be >= 1.0" % pool_ramp)
	if bm_max < 1.0 - EPS:
		errors.append("multiplier: bm_max %.4f must be >= 1.0" % bm_max)
	if bm_max > pool_ramp + EPS:
		errors.append("multiplier: bm_max %.4f exceeds pool_ramp %.4f" % [bm_max, pool_ramp])
	if wave_count < 1:
		errors.append("ramp: wave_count %d must be >= 1" % wave_count)
	elif bm_max * wave_multiplier(pool_ramp, wave_count) > m_cap + EPS:
		errors.append("ramp: bm_max * pool_ramp^(wave_count-1) = %.6f exceeds m_cap %.4f" % [
			bm_max * wave_multiplier(pool_ramp, wave_count), m_cap])

	var k_const: CombatConstants = CombatConstants.from_game_data(gd)
	var rarity_cfg: Dictionary = gd.file("items_rarity")
	var rarity_max: int = int(rarity_cfg.get("rarity_max", 6))
	var kind_offset: Dictionary = rarity_cfg.get("kind_offset", {})

	for step in steps:
		if not (step is Dictionary):
			errors.append("step: entry is not a Dictionary")
			continue
		var step_id: String = str(step.get("id", ""))
		var step_waves: int = int(rules_override["wave_count"]) if rules_override.has("wave_count") else int(step.get("wave_count", wave_count))
		if step_waves < 1:
			errors.append("step %s: wave_count %d must be >= 1" % [step_id, step_waves])
		elif bm_max * wave_multiplier(pool_ramp, step_waves) > m_cap + EPS:
			errors.append("step %s ramp: bm_max * pool_ramp^(%d-1) = %.6f exceeds m_cap %.4f" % [
				step_id, step_waves, bm_max * wave_multiplier(pool_ramp, step_waves), m_cap])

		# Tempered buff W budget (Formulas E, AC-TK-79)
		var buff: Dictionary = step.get("tempered_buff", {})
		var mods: Array = Array(buff.get("mods", []))
		var cost: Dictionary = buff_weight_cost(mods, weights)
		for uk in cost.unknown_keys:
			errors.append("step %s tempered_buff: unknown stat weight for '%s'" % [step_id, uk])
		for nk in cost.negative_keys:
			errors.append("step %s tempered_buff: negative amount for '%s'" % [step_id, nk])
		if float(cost.total_w) > tempered_buff_w + EPS:
			errors.append("step %s tempered_buff: total %.4f W exceeds budget %.4f W" % [
				step_id, float(cost.total_w), tempered_buff_w])

		# Step pool coverage (Rule 12, AC-TK-76, AC-TK-77)
		var step_pool: Array = []
		for b in bosses:
			if b is Dictionary and Array(b.get("steps", [])).has(step_id):
				step_pool.append(b)
		if step_pool.size() < step_waves:
			errors.append("step %s coverage: pool size %d is below wave_count %d" % [step_id, step_pool.size(), step_waves])

		var kind_counts := {"body": 0, "qi": 0, "soul": 0}
		var kind_weights := {"body": 0.0, "qi": 0.0, "soul": 0.0}
		var total_weight: float = 0.0
		var dest_realm: int = gd.realm_index(str(step.get("to_realm", "hoa_than")))
		if dest_realm < 0:
			dest_realm = 4

		for b in step_pool:
			var bid: String = str(b.get("id", "<unnamed>"))
			# Realm check (Rule 3 & 6, AC-TK-74): equiv_realm key forbidden with ANY value
			if b.has("equiv_realm"):
				errors.append("boss %s: equiv_realm key is forbidden (destination realm always applies)" % bid)
			# Weight check (AC-TK-75)
			var w: float = float(b.get("weight", 0.0))
			if w <= 0.0:
				errors.append("boss %s: weight %.4f must be > 0" % [bid, w])
			total_weight += maxf(0.0, w)
			# Multiplier check (AC-TK-68)
			var mult: float = float(b.get("boss_pool_mult", 1.0))
			if mult < 1.0 - EPS or mult > bm_max + EPS:
				errors.append("boss %s: boss_pool_mult %.4f outside [1.0, %.4f]" % [bid, mult, bm_max])
			# Power band check (AC-TK-70)
			var off_est: float = float(b.get("off_estimate", 0.0))
			var ehp_est: float = float(b.get("ehp_estimate", 0.0))
			var r_b: float = (off_est * ehp_est) / ref_f if ref_f > 0.0 else 0.0
			if r_b < band_min - EPS or r_b > band_max + EPS:
				errors.append("boss %s: power band r_b=%.5f outside [%.4f, %.4f]" % [bid, r_b, band_min, band_max])
			# Kill time check (AC-TK-71)
			var m_eff_last: float = float(effective_pool_mult(mult, pool_ramp, step_waves, m_cap).m_eff)
			var kill_t: float = (ehp_est * m_eff_last) / ref_off if ref_off > 0.0 else INF
			if kill_t > stall_time + EPS:
				errors.append("boss %s: last-wave kill time %.2f s exceeds stall_time %.2f s" % [bid, kill_t, stall_time])
			# Soul share & main_kind coverage (AC-TK-72, AC-TK-77)
			var shares: Dictionary = b.get("off_shares", {}) if b.get("off_shares") is Dictionary else {}
			var soul_share: float = float(shares.get("soul", b.get("soul_share", 0.0)))
			if soul_share > soul_share_max + EPS:
				errors.append("boss %s: soul share %.4f exceeds soul_share_max %.4f" % [bid, soul_share, soul_share_max])
			var mk: String = str(b.get("main_kind", ""))
			if not (mk in THREAT_KINDS):
				errors.append("boss %s: main_kind '%s' must be one of body, qi, soul" % [bid, mk])
			else:
				kind_counts[mk] = int(kind_counts[mk]) + 1
				kind_weights[mk] = float(kind_weights[mk]) + maxf(0.0, w)
				if not shares.is_empty():
					var mk_share: float = float(shares.get(mk, -1.0))
					var max_share: float = maxf(float(shares.get("body", 0.0)), maxf(float(shares.get("qi", 0.0)), float(shares.get("soul", 0.0))))
					if mk_share <= 0.0 or mk_share + EPS < max_share:
						errors.append("boss %s: main_kind '%s' (%.4f) is not largest offence share (%.4f)" % [bid, mk, mk_share, max_share])
			# Arts lint (AC-TK-73)
			_lint_boss_arts(b, bid, dest_realm, gd, k_const, errors)
			# Reward bounds (AC-TK-78)
			_lint_boss_reward(b, bid, gd, rarity_max, kind_offset, errors)

		for tk in THREAT_KINDS:
			if int(kind_counts[tk]) < 1:
				errors.append("step %s coverage: missing boss with main_kind '%s'" % [step_id, tk])
		if step_pool.size() >= pool_target and total_weight > 0.0:
			for tk in THREAT_KINDS:
				var share: float = float(kind_weights[tk]) / total_weight
				if share > kind_share_max + EPS:
					errors.append("step %s coverage: main_kind '%s' weight share %.4f exceeds kind_share_max %.4f" % [
						step_id, tk, share, kind_share_max])

	return errors


static func _lint_boss_arts(b: Dictionary, bid: String, dest_realm: int, gd: GameData, k_const: CombatConstants, errors: PackedStringArray) -> void:
	var has_build: bool = b.get("build") is Dictionary and not (b.build as Dictionary).is_empty()
	var raw_arts: Array = Array(b.build.get("arts", [])) if has_build else Array(b.get("arts", []))
	if raw_arts.size() < 2 or raw_arts.size() > 5:
		errors.append("boss %s: arts count %d must be 2..5" % [bid, raw_arts.size()])
		return
	var lib_arts: Dictionary = gd.file("combat_library").get("arts", {})
	var cd_min: float = k_const.cooldown_min if k_const.errors.is_empty() else 0.5
	for i in raw_arts.size():
		var a: Variant = raw_arts[i]
		if not (a is Dictionary):
			errors.append("boss %s.arts[%d]: art must be a Dictionary" % [bid, i])
			continue
		var ad: Dictionary = a
		if ad.has("lib"):
			var aid: String = str(ad.lib)
			if not lib_arts.has(aid):
				errors.append("boss %s.arts[%d]: library art '%s' not found" % [bid, i, aid])
				continue
			var src: Dictionary = lib_arts[aid]
			if float(ad.get("escape", src.get("escape", 0.0))) > 0.0:
				errors.append("boss %s.arts[%d]: escape art '%s' is forbidden on tribulation bosses" % [bid, i, aid])
			if float(ad.get("cooldown", src.get("cooldown", 1.0))) < cd_min - EPS:
				errors.append("boss %s.arts[%d]: cooldown below cooldown_min %.2f" % [bid, i, cd_min])
		else:
			if float(ad.get("escape", 0.0)) > 0.0:
				errors.append("boss %s.arts[%d]: escape art is forbidden on tribulation bosses" % [bid, i])
			if ad.has("cooldown") and float(ad.cooldown) < cd_min - EPS:
				errors.append("boss %s.arts[%d]: cooldown %.3f below cooldown_min %.2f" % [bid, i, float(ad.cooldown), cd_min])
			if float(ad.get("c_art", 0.0)) < 0.0:
				errors.append("boss %s.arts[%d]: negative c_art" % [bid, i])
			if float(ad.get("cost_share", 0.0)) < 0.0 or float(ad.get("cost_share", 0.0)) > 1.0:
				errors.append("boss %s.arts[%d]: cost_share outside [0, 1]" % [bid, i])
			if float(ad.get("soul_part", 0.0)) > FighterProfileLoader.SOUL_PART_MAX + EPS:
				errors.append("boss %s.arts[%d]: soul_part exceeds %.2f" % [bid, i, FighterProfileLoader.SOUL_PART_MAX])
			if int(ad.get("charges", 1)) < 1:
				errors.append("boss %s.arts[%d]: charges must be >= 1" % [bid, i])
			var el: String = str(ad.get("element", ""))
			if not (el in CombatConstants.ELEMENTS):
				errors.append("boss %s.arts[%d]: unknown element '%s'" % [bid, i, el])
			var kind: String = str(ad.get("kind", "phys"))
			if not (kind in ["phys", "elem"]):
				errors.append("boss %s.arts[%d]: kind '%s' must be phys or elem" % [bid, i, kind])
	if has_build:
		var comp_errs: Array = []
		var prof: FighterProfile = TribulationRunner.compile_boss(b, dest_realm, 1.0, gd, comp_errs)
		for ce in comp_errs:
			errors.append("boss %s build: %s" % [bid, str(ce)])
		if prof != null:
			for art in prof.arts:
				if art.escape > 0.0:
					errors.append("boss %s: compiled escape art '%s' is forbidden" % [bid, str(art.id)])
				if art.cd < cd_min - EPS:
					errors.append("boss %s: compiled art '%s' cooldown %.3f below min %.2f" % [bid, str(art.id), art.cd, cd_min])


static func _lint_boss_reward(b: Dictionary, bid: String, gd: GameData, rarity_max: int, kind_offset: Dictionary, errors: PackedStringArray) -> void:
	if not b.has("reward") or not (b.reward is Dictionary) or (b.reward as Dictionary).is_empty():
		errors.append("boss %s: missing reward" % bid)
		return
	var rew: Dictionary = b.reward
	var kind: String = str(rew.get("kind", ""))
	if kind == "" or (not kind_offset.is_empty() and not kind_offset.has(kind)):
		errors.append("boss %s reward: invalid kind '%s'" % [bid, kind])
	var rarity: int = int(rew.get("rarity", 0))
	if rarity < 1 or rarity > rarity_max:
		errors.append("boss %s reward: rarity %d outside 1..%d" % [bid, rarity, rarity_max])
	if int(rew.get("qty", 1)) < 1:
		errors.append("boss %s reward: qty must be >= 1" % bid)
	var tpl: String = str(rew.get("template", ""))
	if tpl == "":
		errors.append("boss %s reward: missing template" % bid)
		return
	if not _template_exists(gd, kind, tpl):
		errors.append("boss %s reward: unknown %s template '%s'" % [bid, kind, tpl])


static func _template_exists(gd: GameData, kind: String, tpl: String) -> bool:
	match kind:
		"material":
			return not gd.material(tpl).is_empty()
		"treasure":
			return not gd.treasure(tpl).is_empty()
		"herb":
			return not gd.herb(tpl).is_empty()
		"pill":
			return not gd.recipe(tpl).is_empty()
		"artifact":
			return not gd.artifact_base(tpl).is_empty() or not gd.named_item(tpl).is_empty()
		"talisman":
			for t in gd.file("crafting_talismans").get("talismans", []):
				if str(t.get("id", "")) == tpl:
					return true
			return false
		"cong_phap":
			for cp in gd.file("items_cong_phap").get("techniques", []):
				if str(cp.get("id", "")) == tpl or str(cp.get("tech_id", "")) == tpl:
					return true
			return false
	return false


static func _canonical(v: Variant) -> String:
	match typeof(v):
		TYPE_NIL:
			return "null"
		TYPE_BOOL:
			return "true" if v else "false"
		TYPE_INT:
			return str(v)
		TYPE_FLOAT:
			return "%.6f" % float(v)
		TYPE_STRING, TYPE_STRING_NAME:
			return "\"%s\"" % str(v)
		TYPE_ARRAY, TYPE_PACKED_STRING_ARRAY, TYPE_PACKED_INT32_ARRAY, TYPE_PACKED_INT64_ARRAY, TYPE_PACKED_FLOAT32_ARRAY, TYPE_PACKED_FLOAT64_ARRAY:
			var arr_parts: PackedStringArray = []
			for item in v:
				arr_parts.append(_canonical(item))
			return "[" + ",".join(arr_parts) + "]"
		TYPE_DICTIONARY:
			var d: Dictionary = v
			var keys: Array = d.keys()
			keys.sort_custom(func(a, b): return str(a) < str(b))
			var dict_parts: PackedStringArray = []
			for k in keys:
				dict_parts.append("%s:%s" % [str(k), _canonical(d[k])])
			return "{" + ",".join(dict_parts) + "}"
	return str(v)
