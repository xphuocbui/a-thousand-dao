class_name TribulationRunner
extends RefCounted
## Atomic, pure-function Heavenly Tribulation (Thiên Kiếp) wave runner.
## Design: design/gdd/thien-kiep.md (Rules 2-13, Formulas A-E, Edge Cases).
##
## Holds no back-references to GameSession, Character, or WorldDB (zero cyclic RefCounted refs).
## Supports an injectable [param fight_fn] Callable for unit tests (FX-STUB) and defaults to real
## [CombatService] resolution.
##
## Usage:
## [codeblock]
## var out: Dictionary = TribulationRunner.run(params, gd)
## if out.ok and out.survived:
##     # advance realm, apply out.tempered_buff, offer out.reward_choices
## [/codeblock]


## Compiles a boss record from tribulation_bosses.json into a [FighterProfile] at [param dest_realm]
## with pool multiplier [param m_eff] (Rules 3 & 6, Formulas A). Appends any compile errors to [param errors].
static func compile_boss(boss_rec: Dictionary, dest_realm: int, m_eff: float, gd: GameData, errors: Array = []) -> FighterProfile:
	var raw_build: Dictionary = boss_rec.get("build", {}) if boss_rec.get("build") is Dictionary else {}
	var d: Dictionary = raw_build.duplicate(true)
	var resist_map: Dictionary = {}
	if d.has("resist") and d.resist is Dictionary:
		for rk in d.resist:
			resist_map[str(rk)] = float(d.resist[rk])
		d.erase("resist")
	if boss_rec.get("resist") is Dictionary:
		for rk in boss_rec.resist:
			resist_map[str(rk)] = float(boss_rec.resist[rk])
	d["name"] = str(boss_rec.get("id", d.get("name", "boss")))
	d["realm"] = clampi(dest_realm, 0, 4)
	d["n_body"] = float(d.get("n_body", 1.0)) * m_eff
	d["n_qi"] = float(d.get("n_qi", 1.0)) * m_eff
	var prof: FighterProfile = FighterCompiler.from_build_file(d, gd, [], errors)
	if prof == null:
		return null
	prof.boss = true
	prof.id = str(boss_rec.get("id", prof.id))
	for rk in resist_map:
		if rk in CombatConstants.DTYPES:
			prof.resist[StringName(rk)] = float(resist_map[rk])
		else:
			errors.append("boss %s: unknown resist dtype '%s'" % [prof.id, rk])
	return prof


## Runs a complete tribulation atomically and deterministically.
## [param params] keys:
## - [code]world_seed[/code] (int), [code]char_id[/code] (String), [code]abs_season[/code] (int)
## - [code]step[/code] (Dictionary, or [code]step_id[/code] String resolved via [TribulationRules])
## - [code]pool[/code] (Array of boss records; defaults to [method TribulationRules.bosses_for_step])
## - [code]player_profile[/code] ([FighterProfile], compiled at pre-breakthrough realm & stage)
## - [code]prep[/code] (Dictionary: ward, slot order, consumable_stock / talismans, pill, diagram, place_id)
## - [code]place_tags[/code] (Array of String/StringName)
## - [code]start_vitality[/code] (float, default 1.0; wave 1 applies Combat's vitality floor)
## - [code]log_enabled[/code] (bool, default true)
## - optional test overrides: [code]rules_override[/code], [code]regen_base[/code], [code]regen_k[/code],
##   [code]on_wave_start[/code] (Callable(wave_k, boss_rec, wave_header)).
static func run(params: Dictionary, gd: GameData, fight_fn: Callable = Callable()) -> Dictionary:
	var rules: Dictionary = TribulationRules.config(gd).duplicate(true)
	var overrides: Dictionary = params.get("rules_override", {})
	for ok_key in overrides:
		rules[ok_key] = overrides[ok_key]

	var step: Dictionary = params.get("step", {})
	if step.is_empty() and str(params.get("step_id", "")) != "":
		step = TribulationRules.step_by_id(gd, str(params.step_id))
	var step_id: String = str(step.get("id", params.get("step_id", "")))
	var dest_realm: int = gd.realm_index(str(step.get("to_realm", "hoa_than")))
	if dest_realm < 0:
		dest_realm = int(params.get("dest_realm", 4))

	var wave_count: int = int(params.get("wave_count",
			overrides["wave_count"] if overrides.has("wave_count") else step.get("wave_count", rules.get("wave_count", 3))))
	var pool_ramp: float = float(rules.get("pool_ramp", 1.5))
	var m_cap: float = float(rules.get("m_cap", 10.0))
	var rest_pulses: int = int(params.get("rest_pulses", rules.get("rest_pulses", 8)))

	var pool: Array = Array(params.get("pool", []))
	if pool.is_empty() and step_id != "":
		pool = TribulationRules.bosses_for_step(gd, step_id)
	if pool.size() < wave_count or wave_count < 1:
		return {"ok": false, "error": "boss pool size %d is below wave_count %d" % [pool.size(), wave_count]}

	var k_const: CombatConstants = CombatConstants.from_game_data(gd)
	var regen_base: float = float(params.get("regen_base", k_const.regen_base))
	var regen_k: float = float(params.get("regen_k", k_const.regen_k))

	var player_profile: FighterProfile = params.get("player_profile")
	var prep: Dictionary = (params.get("prep", {}) as Dictionary).duplicate(true)
	var setup_h: int = TribulationRules.setup_hash(player_profile, prep)
	var tk_id: int = TribulationRules.tribulation_id(
		int(params.get("world_seed", 0)),
		str(params.get("char_id", "")),
		step_id,
		int(params.get("abs_season", 0)),
		setup_h
	)
	var drawn: Array = TribulationRules.draw_waves(pool, wave_count, tk_id)
	if drawn.size() < wave_count:
		return {"ok": false, "error": "failed to draw %d bosses" % wave_count}

	var ground_tags: Array[StringName] = _build_ground_tags(Array(params.get("place_tags", [])))
	var vit_floor: float = float(gd.combat().get("duel", {}).get("injured_power_floor", 0.4))
	var start_v: float = clampf(float(params.get("start_vitality", 1.0)), 0.0, 1.0)
	var h_share: float = clampf(maxf(start_v, vit_floor), 0.0001, 1.0)
	var q_share: float = 1.0
	var log_enabled: bool = bool(params.get("log_enabled", true))

	var stock: Dictionary = {}
	var stock_src: Variant = prep.get("consumable_stock", prep.get("talismans", {}))
	if stock_src is Dictionary:
		for sk in stock_src:
			stock[str(sk)] = maxi(0, int(stock_src[sk]))
	var spent_stock: Dictionary = {}
	var prepared_pill: Dictionary = {}
	if prep.get("pill") is Dictionary and not (prep.pill as Dictionary).is_empty():
		prepared_pill = (prep.pill as Dictionary).duplicate(true)
	elif player_profile != null and not player_profile.pill.is_empty():
		prepared_pill = player_profile.pill.duplicate(true)

	var carried_meters: Dictionary = {}
	if player_profile != null and not player_profile.meters.is_empty():
		for mid in player_profile.meters:
			var mdef: Variant = player_profile.meters[mid]
			if mdef is Dictionary:
				carried_meters[str(mid)] = clampf(float((mdef as Dictionary).get("start", 0.0)), 0.0, 1.0)

	var on_wave_start: Variant = params.get("on_wave_start", Callable())
	var wave_results: Array = []
	var notes: PackedStringArray = []
	var survived: bool = true
	var waves_cleared: int = 0
	var fatal_wave: int = 0
	var fatal_boss: Dictionary = {}
	var fail_reason: String = ""
	var service: CombatService = null if fight_fn.is_valid() else CombatService.new(k_const)

	for idx in drawn.size():
		var k_wave: int = idx + 1
		var boss_rec: Dictionary = drawn[idx]
		var boss_id: String = str(boss_rec.get("id", "boss_%d" % k_wave))
		var boss_name: String = str(boss_rec.get("name", boss_id))
		var boss_mult: float = float(boss_rec.get("boss_pool_mult", 1.0))
		var mult_info: Dictionary = TribulationRules.effective_pool_mult(boss_mult, pool_ramp, k_wave, m_cap)
		var m_eff: float = float(mult_info.m_eff)
		var m_capped: bool = bool(mult_info.capped)
		var wave_notes: PackedStringArray = []
		if m_capped:
			var cap_msg: String = "Wave %d (%s): m_eff %.4f capped at m_cap %.4f" % [k_wave, boss_id, float(mult_info.raw), m_cap]
			notes.append(cap_msg)
			wave_notes.append(cap_msg)

		var wave_header: String = "Wave %d/%d — %s | Start HP %.1f%% · Qi %.1f%%" % [
			k_wave, wave_count, boss_name, h_share * 100.0, q_share * 100.0]
		if on_wave_start is Callable and (on_wave_start as Callable).is_valid():
			(on_wave_start as Callable).call(k_wave, boss_rec, wave_header)

		var boss_profile: FighterProfile = _boss_profile_for_wave(boss_rec, dest_realm, m_eff, gd, fight_fn.is_valid(), wave_notes)
		if boss_profile == null:
			return {"ok": false, "error": "failed to compile boss '%s': %s" % [boss_id, "; ".join(wave_notes)]}

		var wave_player: FighterProfile = _wave_player_profile(player_profile, stock, prepared_pill, carried_meters)
		var req := FightRequest.new()
		req.a = wave_player
		req.b = boss_profile
		req.situation = FightRequest.Situation.FORESEEN
		req.ground_tags = ground_tags.duplicate()
		req.no_heal = true
		req.start_health_share = h_share
		req.start_qi_share = q_share
		req.fight_seed = TribulationRules.wave_seed(tk_id, k_wave)
		req.log_enabled = log_enabled

		# wave_ctx exposes ONLY the current wave's boss (never later drawn bosses; AC-TK-18)
		var wave_ctx := {
			"wave": k_wave,
			"wave_count": wave_count,
			"boss": boss_rec,
			"m_eff": m_eff,
			"m_capped": m_capped,
			"header": wave_header,
			"stock": stock.duplicate(true),
			"pill": prepared_pill.duplicate(true),
			"prep": prep.duplicate(true),
			"spent_out": {},
		}

		var res: FightResult
		if fight_fn.is_valid():
			if fight_fn.get_argument_count() == 1:
				res = fight_fn.call(req)
			else:
				res = fight_fn.call(req, wave_ctx)
		else:
			res = service.resolve(req)
			if res == null:
				return {"ok": false, "error": "combat error on wave %d: %s" % [k_wave, "; ".join(service.errors)]}

		_apply_wave_stock_spend(wave_player, res, wave_ctx.spent_out, stock, spent_stock)

		var wave_meters: Dictionary = {}
		if res != null and res.a_end != null and not res.a_end.meters.is_empty():
			for mid in res.a_end.meters:
				var mv: float = clampf(float(res.a_end.meters[mid]), 0.0, 1.0)
				carried_meters[str(mid)] = mv
				wave_meters[str(mid)] = mv

		var cleared: bool = (res != null and res.winner == FightResult.Winner.A and res.ending == FightResult.Ending.KNOCKOUT)
		var double_ko_win: bool = cleared and res.a_end != null and res.a_end.health <= 0.0
		var hp_max: float = res.a_end.health_max if (res != null and res.a_end != null) else 0.0
		var qi_max: float = res.a_end.linh_luc_base if (res != null and res.a_end != null) else 0.0
		var hp_end: float = 1.0 if double_ko_win else (res.a_end.health if (res != null and res.a_end != null) else 0.0)
		var qi_end: float = res.a_end.linh_luc if (res != null and res.a_end != null) else 0.0
		if res != null and not res.notes.is_empty():
			for n in res.notes:
				wave_notes.append(n)

		var wave_rec := {
			"wave": k_wave,
			"header": wave_header,
			"boss_id": boss_id,
			"boss_name": boss_name,
			"main_kind": str(boss_rec.get("main_kind", "")),
			"m_eff": m_eff,
			"m_capped": m_capped,
			"start_h": h_share,
			"start_q": q_share,
			"fight_seed": req.fight_seed,
			"winner": res.win_code() if res != null else "error",
			"ending": _ending_name(res),
			"seconds": res.seconds if res != null else 0.0,
			"health_end": hp_end,
			"health_max": hp_max,
			"qi_end": qi_end,
			"qi_max": qi_max,
			"deciding_layer": res.deciding_layer if res != null else -1,
			"log_rows": res.log_rows if res != null else [],
			"cleared": cleared,
			"double_ko_win": double_ko_win,
			"a_meters": wave_meters,
			"notes": wave_notes,
		}
		wave_results.append(wave_rec)

		if not cleared:
			survived = false
			fatal_wave = k_wave
			fatal_boss = boss_rec.duplicate(true)
			fail_reason = _ending_name(res)
			break

		waves_cleared += 1
		if k_wave < wave_count:
			var regen_bonus: float = player_profile.regen_bonus if player_profile != null else float(params.get("regen_bonus", 0.0))
			var carry: Dictionary = TribulationRules.carry_over_shares(
				hp_end, hp_max, qi_end, qi_max, rest_pulses, regen_base, regen_k, regen_bonus, double_ko_win
			)
			h_share = clampf(float(carry.h_next), 0.000001, 1.0)
			q_share = float(carry.q_next)

	var reward_choices: Array = []
	var tempered_buff: Dictionary = {}
	if survived:
		reward_choices = _dedup_rewards(drawn)
		if step.get("tempered_buff") is Dictionary:
			tempered_buff = (step.tempered_buff as Dictionary).duplicate(true)

	return {
		"ok": true,
		"tribulation_id": tk_id,
		"setup_hash": setup_h,
		"step_id": step_id,
		"survived": survived,
		"final_ending": "survived" if survived else "failed",
		"fail_reason": fail_reason,
		"waves_cleared": waves_cleared,
		"wave_count": wave_count,
		"waves": wave_results,
		"fatal_wave": fatal_wave,
		"fatal_boss": fatal_boss,
		"remaining_stock": stock,
		"spent_stock": spent_stock,
		"end_meters": carried_meters.duplicate(),
		"tempered_buff": tempered_buff,
		"reward_choices": reward_choices,
		"notes": notes,
	}


static func _build_ground_tags(place_tags: Array) -> Array[StringName]:
	var out: Array[StringName] = []
	for t in place_tags:
		var sn := StringName(str(t))
		if str(sn) != "" and not out.has(sn):
			out.append(sn)
	if not out.has(&"tribulation"):
		out.append(&"tribulation")
	return out


static func _boss_profile_for_wave(boss_rec: Dictionary, dest_realm: int, m_eff: float, gd: GameData, allow_stub: bool, notes: PackedStringArray) -> FighterProfile:
	if boss_rec.get("build") is Dictionary and not (boss_rec.build as Dictionary).is_empty():
		var errs: Array = []
		var p: FighterProfile = compile_boss(boss_rec, dest_realm, m_eff, gd, errs)
		for e in errs:
			notes.append(str(e))
		return p
	if allow_stub:
		var p := FighterProfile.new()
		p.id = str(boss_rec.get("id", "boss"))
		p.realm = clampi(dest_realm, 0, 4)
		p.boss = true
		p.n_body = m_eff
		p.n_qi = m_eff
		return p
	notes.append("boss %s has no build definition" % str(boss_rec.get("id", "")))
	return null


static func _wave_player_profile(base: FighterProfile, stock: Dictionary, prepared_pill: Dictionary, carried_meters: Dictionary = {}) -> FighterProfile:
	if base == null:
		return null
	var needs_filter: bool = false
	for a in base.arts:
		var aid: String = str(a.id)
		if a.tags.has(&"talisman") and stock.has(aid) and int(stock[aid]) <= 0:
			needs_filter = true
			break
	var needs_pill: bool = not prepared_pill.is_empty() and base.pill.is_empty()
	var needs_meters: bool = false
	if not carried_meters.is_empty() and not base.meters.is_empty():
		for mid in carried_meters:
			if base.meters.has(mid) and base.meters[mid] is Dictionary:
				var base_start: float = float((base.meters[mid] as Dictionary).get("start", 0.0))
				if not is_equal_approx(base_start, float(carried_meters[mid])):
					needs_meters = true
					break
	if not needs_filter and not needs_pill and not needs_meters:
		return base
	var clone := FighterProfile.new()
	for prop in base.get_property_list():
		if prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			clone.set(prop.name, base.get(prop.name))
	if needs_filter:
		var kept: Array[ArtDef] = []
		for a in base.arts:
			var aid: String = str(a.id)
			if a.tags.has(&"talisman") and stock.has(aid) and int(stock[aid]) <= 0:
				continue
			kept.append(a)
		clone.arts = kept
	if needs_pill:
		clone.pill = prepared_pill.duplicate(true)
	if needs_meters:
		var cloned_meters: Dictionary = base.meters.duplicate(true)
		for mid in carried_meters:
			if cloned_meters.has(mid) and cloned_meters[mid] is Dictionary:
				(cloned_meters[mid] as Dictionary)["start"] = clampf(float(carried_meters[mid]), 0.0, 1.0)
		clone.meters = cloned_meters
	return clone


static func _apply_wave_stock_spend(profile: FighterProfile, res: FightResult, spent_out: Dictionary, stock: Dictionary, spent_total: Dictionary) -> void:
	# Explicit spend reported by a stub/caller takes precedence for those keys
	for tid in spent_out:
		var key: String = str(tid)
		var used: int = maxi(0, int(spent_out[tid]))
		if stock.has(key):
			used = mini(used, int(stock[key]))
			stock[key] = int(stock[key]) - used
		if used > 0:
			spent_total[key] = int(spent_total.get(key, 0)) + used
	# Real combat talisman art firings consume matching stock entries
	if profile == null or res == null or res.a_end == null:
		return
	for i in mini(profile.arts.size(), res.a_end.fired.size()):
		var art: ArtDef = profile.arts[i]
		var aid: String = str(art.id)
		if art.tags.has(&"talisman") and stock.has(aid) and not spent_out.has(aid):
			var fired_n: int = maxi(0, int(res.a_end.fired[i]))
			var take: int = mini(fired_n, int(stock[aid]))
			if take > 0:
				stock[aid] = int(stock[aid]) - take
				spent_total[aid] = int(spent_total.get(aid, 0)) + take


static func _dedup_rewards(beaten_bosses: Array) -> Array:
	var out: Array = []
	var seen: Dictionary = {}
	for b in beaten_bosses:
		if not (b is Dictionary) or not (b.get("reward") is Dictionary):
			continue
		var rew: Dictionary = b.reward
		if rew.is_empty():
			continue
		var key: String = str(rew.get("id", ""))
		if key == "":
			key = "%s:%s:%d:%d" % [
				str(rew.get("kind", "")),
				str(rew.get("template", "")),
				int(rew.get("qty", 1)),
				int(rew.get("rarity", 1)),
			]
		if not seen.has(key):
			seen[key] = true
			out.append(rew.duplicate(true))
	return out


static func _ending_name(res: FightResult) -> String:
	if res == null:
		return "error"
	if res.timed_out:
		return "time"
	match res.ending:
		FightResult.Ending.KNOCKOUT:
			return "knockout"
		FightResult.Ending.DRAW:
			return "draw"
		FightResult.Ending.FLIGHT:
			return "flight"
	return "draw"
