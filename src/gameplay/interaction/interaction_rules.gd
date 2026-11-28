class_name InteractionRules
extends RefCounted
## Pure static calculation helpers for NPC Interaction & Dialogue (#30) + 19 Trait [code]verb:[/code] hooks.
## Implements Formula A (acceptance score + term breakdown), Formula B (attitude change, gift fall-off, yearly drift),
## Formula C (teaching insight), Formula D (trade band visibility), Formula E (threat check), Formula F (loan cap),
## F7 trait conflict costs, trait [code]verb:[/code] side gating, haggle no-arbitrage clamp, and verb preconditions.
## Every gameplay constant is read from [code]assets/data/npc_interactions.json[/code]; zero side effects.
##
## Usage:
## [codeblock]
## var verb := InteractionRules.verb_def(gd, "teach")
## var res := InteractionRules.acceptance_score(gd, db, verb, player, sheet, npc, 0.0)
## print(res.accept, res.score, res.parts)
## [/codeblock]

## Data file id for interaction verbs and tuning knobs.
const INTERACTIONS_FILE := "npc_interactions"
## Canonical attitude bands in ascending order (GDD Rule 13).
const BAND_ORDER := ["hostile", "cold", "neutral", "warm", "friendly", "close"]


## Returns the loaded [code]npc_interactions.json[/code] root Dictionary (or {} if absent).
static func data(gd: GameData) -> Dictionary:
	if gd == null or not gd.registry.has_file(INTERACTIONS_FILE):
		return {}
	return gd.file(INTERACTIONS_FILE)


## Returns the tuning knobs Dictionary from [code]npc_interactions.json["knobs"][/code].
static func knobs(gd: GameData) -> Dictionary:
	return Dictionary(data(gd).get("knobs", {}))


## Returns all verb definition records from [code]npc_interactions.json["verbs"][/code].
static func verbs(gd: GameData) -> Array:
	return Array(data(gd).get("verbs", []))


## Returns the verb record matching [param verb_id], or {} if not found.
static func verb_def(gd: GameData, verb_id: String) -> Dictionary:
	for raw in verbs(gd):
		if raw is Dictionary and str((raw as Dictionary).get("id", "")) == verb_id:
			return raw as Dictionary
	return {}


## Returns only base verb records (those without a [code]trait_hook[/code]).
static func base_verb_defs(gd: GameData) -> Array:
	return verbs(gd).filter(func(v): return v is Dictionary and str((v as Dictionary).get("trait_hook", "")) == "")


## Returns only trait-hook verb records (those carrying a non-empty [code]trait_hook[/code]).
static func trait_verb_defs(gd: GameData) -> Array:
	return verbs(gd).filter(func(v): return v is Dictionary and str((v as Dictionary).get("trait_hook", "")) != "")


## Rounds halves away from zero (Formula B [code]round_half_up[/code]).
static func round_half_up(x: float) -> int:
	if x >= 0.0:
		return int(floorf(x + 0.5 + 1e-9))
	return -int(floorf(-x + 0.5 + 1e-9))


## Base-2 logarithm clamped above zero to avoid NaN/INF.
static func log2f(x: float) -> float:
	return log(maxf(x, 1e-9)) / log(2.0)


## Returns the attitude band name ("hostile", "cold", "neutral", "warm", "friendly", "close")
## for integer [param attitude] (GDD Rule 13, AC-NI-21).
static func attitude_band(gd: GameData, attitude: int) -> String:
	return DialogueVoice.attitude_band(gd, attitude)


## Returns the ascending rank (0..5) of [param band], or -1 if unknown.
static func band_rank(band: String) -> int:
	return BAND_ORDER.find(band)


## Returns the merged remembered-deed flags Dictionary for [param npc] (reads both [code]flags[/code]
## and [code]interaction_flags[/code] for save compatibility).
static func npc_flags(npc: Dictionary) -> Dictionary:
	var out: Dictionary = Dictionary(npc.get("interaction_flags", {})).duplicate()
	var f: Dictionary = Dictionary(npc.get("flags", {}))
	for k in f.keys():
		out[k] = f[k]
	return out


## Returns the Formula A trait term [code]round(k_tr * log2(m))[/code] (AC-NI-06: -33 at M=0.1, +23 at M=5).
static func trait_term_for_m(gd: GameData, m: float) -> float:
	var k_tr: float = float(knobs(gd).get("k_tr", 10.0))
	return roundf(k_tr * log2f(m))


## Formula A: computes the deterministic acceptance score and term breakdown for [param verb]
## with [param npc] (GDD Rule 6, AC-NI-05, AC-NI-06).
## Returns [code]{score, accept, parts, m, m_raw, never, delta_r, trait_term}[/code].
static func acceptance_score(
	gd: GameData,
	db: WorldDB,
	verb: Dictionary,
	player: Character,
	player_sheet: StatSheet,
	npc: Dictionary,
	sect_standing: float,
	extra_flag_mods: Dictionary = {},
	sub_kind: String = "",
	season_now: int = -1
) -> Dictionary:
	var k: Dictionary = knobs(gd)
	var k_att: float = float(k.get("k_att", 1.0))
	var k_pr: float = float(k.get("k_pr", 0.25))
	var k_st: float = float(k.get("k_st", 0.2))
	var never_pen: float = float(k.get("never_trait_penalty", -100.0))

	var b_v: int = int(verb.get("b_v", 0))
	var sub_map: Dictionary = Dictionary(verb.get("sub_b_v", {}))
	if sub_kind != "" and sub_map.has(sub_kind):
		b_v = int(sub_map[sub_kind])

	var att: int = int(npc.get("attitude", 0))
	var mi_luc: float = player_sheet.effective("mi_luc", player) if player_sheet != null else float(player.base_stat("mi_luc"))
	var pr: float = mi_luc - 50.0
	var delta_r: int = int(npc.get("realm_index", 0)) - player.realm_index
	var g_v: int = int(verb.get("g_v", 0))

	var tags: Array = Array(verb.get("tags", []))
	var m_raw: float = 1.0
	if not tags.is_empty() and gd != null and gd.registry.has_file(NpcTraits.FILE):
		m_raw = NpcTraits.choice_weight(gd, npc, tags, 1.0)
	var is_never: bool = not tags.is_empty() and m_raw <= 0.0
	var m_eff: float = 0.1 if is_never else m_raw
	var tr_term: float = trait_term_for_m(gd, m_eff)
	var never_term: float = never_pen if is_never else 0.0

	var att_term: float = k_att * float(att)
	var pr_term: float = k_pr * pr
	var gap_term: float = float(g_v * absi(delta_r))
	var st_eff: float = sect_standing if str(npc.get("sect_id", "")) != "" else 0.0
	var st_term: float = k_st * st_eff

	var parts: Array = [
		{"key": "base", "label": "Base ask", "value": float(b_v)},
		{"key": "attitude", "label": "Attitude (%+d)" % att, "value": att_term},
		{"key": "presence", "label": "Presence (%.0f)" % mi_luc, "value": pr_term},
		{"key": "realm_gap", "label": "Realm gap (%d)" % absi(delta_r), "value": gap_term},
		{"key": "traits", "label": "Traits (M=%.2f)" % m_eff, "value": tr_term},
	]
	if is_never:
		parts.append({"key": "trait_never", "label": "Trait refusal (never)", "value": never_term})
	if st_term != 0.0:
		parts.append({"key": "standing", "label": "Sect standing (%.0f)" % st_eff, "value": st_term})

	var flags: Dictionary = npc_flags(npc)
	var flag_sum: float = 0.0
	var fmods: Dictionary = Dictionary(verb.get("flag_mods", {}))
	for fk in fmods.keys():
		var fks: String = str(fk)
		var mod_v: float = float(fmods[fk])
		var active: bool = false
		if fks == "dao_lu_tie":
			active = db != null and player != null and Ties.has_pin(db, player.id, str(npc.get("id", "")), "dao_lu")
		elif flags.has(fks):
			var fv: Variant = flags[fks]
			if typeof(fv) == TYPE_BOOL:
				active = bool(fv)
			elif fks == "clan_invoked" and season_now >= 0 and (typeof(fv) == TYPE_INT or typeof(fv) == TYPE_FLOAT):
				active = int(fv) > season_now
			else:
				active = fv != null
		if active and mod_v != 0.0:
			flag_sum += mod_v
			parts.append({"key": "flag:" + fks, "label": "Flag: %s" % fks, "value": mod_v})

	for ek in extra_flag_mods.keys():
		var ev: float = float(extra_flag_mods[ek])
		if ev != 0.0:
			flag_sum += ev
			parts.append({"key": "extra:" + str(ek), "label": str(ek), "value": ev})

	var total: float = float(b_v) + att_term + pr_term + gap_term + tr_term + never_term + st_term + flag_sum
	var accepted: bool = (not is_never) and (total >= 0.0)
	return {
		"score": total,
		"accept": accepted,
		"parts": parts,
		"m": m_eff,
		"m_raw": m_raw,
		"never": is_never,
		"delta_r": delta_r,
		"trait_term": tr_term,
	}


## Formula B: computes integer attitude delta from [param base_delta] and presence offset [param pr]
## ([code]eff(mi_luc) - 50[/code]). Positive gains scale with presence and round half up;
## negative losses NEVER scale with presence (AC-NI-10).
static func attitude_delta(gd: GameData, base_delta: float, pr: float) -> int:
	if base_delta <= 0.0:
		return int(roundf(base_delta))
	var k_ch: float = float(knobs(gd).get("k_ch", 0.01))
	return round_half_up(base_delta * maxf(0.0, 1.0 + k_ch * pr))


## Formula B: attitude gain from greeting after [param n_greet] prior greetings this year.
static func greet_delta(gd: GameData, pr: float, n_greet: int) -> int:
	var greet_gain: float = float(knobs(gd).get("greet_gain", 2.0))
	var base: float = greet_gain * pow(0.5, float(maxi(0, n_greet)))
	return attitude_delta(gd, base, pr)


## Formula B: attitude gain from a gift of value [param value] to [param npc] after [param n_gift]
## prior gifts this year (AC-NI-09). Returns 0 for worthless gifts ([param value] <= 0).
static func gift_delta(gd: GameData, value: int, npc: Dictionary, pr: float, n_gift: int) -> int:
	if value <= 0:
		return 0
	var k: Dictionary = knobs(gd)
	var gift_gain: float = float(k.get("gift_gain", 15.0))
	var w_r: float = float(gd.realm_budget(int(npc.get("realm_index", 0))).get("linh_thach_max", 80))
	var m_greedy: float = 1.0
	if gd != null and gd.registry.has_file(NpcTraits.FILE):
		m_greedy = NpcTraits.choice_weight(gd, npc, ["greedy"], 1.0)
		if m_greedy <= 0.0:
			m_greedy = 0.1
	var base: float = gift_gain * (1.0 - exp(-float(value) / maxf(w_r, 1.0))) * m_greedy * pow(0.5, float(maxi(0, n_gift)))
	return attitude_delta(gd, base, pr)


## Formula B (yearly drift): moves [param current_att] by [code]yearly_drift_step[/code] (1) toward
## [param opinion_val] (AC-NI-11), clamped to [code]relationship_min..relationship_max[/code].
static func yearly_drift(gd: GameData, current_att: int, opinion_val: float) -> int:
	var k: Dictionary = knobs(gd)
	var step: int = maxi(1, int(k.get("yearly_drift_step", 1)))
	var lo: int = int(k.get("relationship_min", -100))
	var hi: int = int(k.get("relationship_max", 100))
	var op: int = int(roundf(opinion_val))
	var diff: int = op - current_att
	if diff == 0:
		return clampi(current_att, lo, hi)
	var move: int = mini(step, absi(diff)) * (1 if diff > 0 else -1)
	return clampi(current_att + move, lo, hi)


## Formula C: returns the next-season [code]cultivation_speed_pct[/code] bonus (percentage points, e.g. 20.0)
## from a teacher at [param teacher_realm] instructing a student at [param student_realm] (AC-NI-13).
static func teaching_insight_pct(gd: GameData, teacher_realm: int, student_realm: int) -> float:
	var ins_base: float = float(knobs(gd).get("ins_base", 0.10))
	return 100.0 * ins_base * (1.0 + float(maxi(0, teacher_realm - student_realm)))


## Returns true if [param tech_def] is restricted to members of its owning sect (GDD Rule 9, AC-NI-14).
static func is_sect_technique(tech_def: Dictionary) -> bool:
	if bool(tech_def.get("sect_only", false)):
		return true
	if str(tech_def.get("origin", "")).to_lower() == "sect":
		return true
	if str(tech_def.get("sect_id", "")) != "" or str(tech_def.get("sect", "")) != "" or str(tech_def.get("sect_key", "")) != "":
		return true
	return str(tech_def.get("source", "")).begins_with("sect:")


## Returns the list of techniques [param teacher] can copy as a manual lesson for [param player]
## (unlearned by player, usable by player's root per Công Pháp Rule 8, and excluding sect techniques
## unless player shares the teacher's sect — AC-NI-14).
static func teachable_manuals(gd: GameData, teacher: Dictionary, player: Character) -> Array:
	var out: Array = []
	var techs: Dictionary = Dictionary(teacher.get("techniques", {}))
	var t_sect: String = str(teacher.get("sect_id", ""))
	for key in techs.keys():
		var tid: String = str(key)
		if player.techniques.has(tid):
			continue
		var entry: Variant = techs[key]
		if not (entry is Dictionary):
			continue
		var def: Dictionary = Dictionary((entry as Dictionary).get("def", {}))
		if def.is_empty():
			continue
		if not CongPhap.usable(player, def):
			continue
		if is_sect_technique(def):
			var req_sect: String = str(def.get("sect_id", t_sect))
			if req_sect == "" or player.sect_id != req_sect:
				continue
		out.append({
			"tech_id": tid,
			"name": str(def.get("name", tid)),
			"def": def,
			"layer": int((entry as Dictionary).get("layer", 1)),
		})
	out.sort_custom(func(a, b): return str(a.tech_id) < str(b.tech_id))
	return out


## GDD Rule 9: true when [param teacher] is above [param player]'s realm, or at the same realm
## with at least one teachable technique manual [param player] lacks.
static func can_teach(gd: GameData, teacher: Dictionary, player: Character) -> bool:
	var t_realm: int = int(teacher.get("realm_index", 0))
	if t_realm > player.realm_index:
		return true
	if t_realm == player.realm_index:
		return not teachable_manuals(gd, teacher, player).is_empty()
	return false


## Formula E: computes threat success probability [code]p = clamp(q + k_th * log2(M_cautious), p_min, p_max)[/code]
## from player win share [param q] and target's cautious trait weight (AC-NI-18).
static func threat_chance(gd: GameData, q: float, npc: Dictionary) -> Dictionary:
	var k: Dictionary = knobs(gd)
	var k_th: float = float(k.get("k_th", 0.10))
	var p_min: float = float(k.get("threat_p_min", 0.05))
	var p_max: float = float(k.get("threat_p_max", 0.95))
	var m_caut: float = 1.0
	if gd != null and gd.registry.has_file(NpcTraits.FILE):
		m_caut = NpcTraits.choice_weight(gd, npc, ["cautious"], 1.0)
		if m_caut <= 0.0:
			m_caut = 0.1
	var p: float = clampf(q + k_th * log2f(m_caut), p_min, p_max)
	return {"p": p, "q": q, "m_cautious": m_caut}


## Formula F: maximum spirit stones [param npc] can lend ([code]min(floor(loan_share * W_r), purse)[/code], AC-NI-15).
static func loan_cap(gd: GameData, npc: Dictionary) -> int:
	var share: float = float(knobs(gd).get("loan_share", 0.50))
	var w_r: float = float(gd.realm_budget(int(npc.get("realm_index", 0))).get("linh_thach_max", 80))
	var purse: int = maxi(0, int(floorf(float(npc.get("linh_thach", 0.0)))))
	return mini(int(floorf(share * w_r)), purse)


## Maximum spirit stones that can be wagered between [param player] and [param npc]
## ([code]min(player_purse, npc_purse, floor(wager_max_share * W_r))[/code]).
static func wager_cap(gd: GameData, player: Character, npc: Dictionary) -> int:
	var share: float = float(knobs(gd).get("wager_max_share", 0.25))
	var w_r: float = float(gd.realm_budget(int(npc.get("realm_index", 0))).get("linh_thach_max", 80))
	var npc_purse: int = maxi(0, int(floorf(float(npc.get("linh_thach", 0.0)))))
	return mini(mini(maxi(0, player.linh_thach), npc_purse), int(floorf(share * w_r)))


## Applies the [code]haggle[/code] trait verb multipliers with a strict no-arbitrage clamp
## guaranteeing [code]buy > sell[/code] (zero buy-sell infinite money loop).
static func haggle_prices(gd: GameData, base_buy: int, base_sell: int, haggled: bool) -> Dictionary:
	var b: int = maxi(1, base_buy)
	var s: int = maxi(1, base_sell)
	if haggled:
		var k: Dictionary = knobs(gd)
		var bm: float = float(k.get("haggle_buy_mult", 0.90))
		var sm: float = float(k.get("haggle_sell_mult", 1.05))
		b = maxi(1, int(ceilf(float(base_buy) * bm - 1e-6)))
		s = maxi(1, int(floorf(float(base_sell) * sm + 1e-6)))
	if s >= b:
		s = maxi(1, b - 1)
		if s >= b:
			b = s + 1
	return {"buy": b, "sell": s}


## Formula D: filters [param npc]'s unequipped spare items by attitude band (AC-NI-16).
## Common spare goods (<= median rarity): [code]neutral[/code]; better (> median): [code]friendly[/code];
## treasures (kind == "treasure" or rarity >= 5): [code]close[/code]. Hostile/cold trade nothing.
## Returns [code]{shown, locked, band, median_rarity}[/code].
static func trade_items_for(gd: GameData, db: WorldDB, npc: Dictionary) -> Dictionary:
	var cur_band: String = attitude_band(gd, int(npc.get("attitude", 0)))
	var cur_rank: int = band_rank(cur_band)
	var tb: Dictionary = Dictionary(knobs(gd).get("trade_bands", {"common": "neutral", "better": "friendly", "treasure": "close"}))
	var common_b: String = str(tb.get("common", "neutral"))
	var better_b: String = str(tb.get("better", "friendly"))
	var treasure_b: String = str(tb.get("treasure", "close"))
	var npc_id: String = str(npc.get("id", ""))
	if db == null or npc_id == "":
		return {"shown": [], "locked": [], "band": cur_band, "median_rarity": 0.0}

	var equipped: Array = Array(npc.get("equipped", []))
	var spares: Array = []
	var rarities: Array = []
	for it in db.items_of(npc_id):
		if equipped.has(str(it.get("id", ""))):
			continue
		if str(it.get("kind", "")) == "herb" and int(it.get("plot", -1)) >= 0:
			continue
		var r: int = ItemRarity.of(gd, it)
		spares.append({"item": it, "rarity": r})
		rarities.append(r)

	if spares.is_empty():
		return {"shown": [], "locked": [], "band": cur_band, "median_rarity": 0.0}

	rarities.sort()
	var n: int = rarities.size()
	var median: float = float(rarities[n / 2]) if (n % 2 == 1) else (0.5 * (float(rarities[n / 2 - 1]) + float(rarities[n / 2])))

	var shown: Array = []
	var locked: Array = []
	for entry in spares:
		var it: Dictionary = entry.item
		var r: int = int(entry.rarity)
		var need: String = common_b
		if str(it.get("kind", "")) == "treasure" or r >= 5:
			need = treasure_b
		elif float(r) > median:
			need = better_b
		if cur_rank >= band_rank(need):
			shown.append(it)
		else:
			locked.append({"item": it, "band_needed": need})
	return {"shown": shown, "locked": locked, "band": cur_band, "median_rarity": median}


## NPC Traits F7: computes heart-demon and standing costs when [param player_rec] acts against
## their own traits on a verb carrying [param tags] (GDD Rule 7, AC-NI-07).
## Returns [code]{n_with, n_against, tam_ma_raw, standing_pen, cost_mult}[/code].
static func f7_trait_conflict(gd: GameData, player_rec: Dictionary, tags: Array, heart_demon_used: float) -> Dictionary:
	if tags.is_empty() or gd == null or not gd.registry.has_file(NpcTraits.FILE):
		return {"n_with": 0, "n_against": 0, "tam_ma_raw": 0.0, "standing_pen": 0, "cost_mult": 1.0}
	var al: Dictionary = NpcTraits.choice_alignment(gd, player_rec, tags)
	var n_with: int = int(al.get("with", 0))
	var n_against: int = int(al.get("against", 0))
	var k: Dictionary = knobs(gd)
	var tm_a: float = float(k.get("f7_tm_a", 2.0))
	var tm_cap: float = float(k.get("f7_tm_cap", 6.0))
	var st_a: int = int(k.get("f7_st_a", 3))
	var disc: float = float(k.get("f7_in_char_discount", 0.10))
	var max_t: int = int(k.get("f7_in_char_max_traits", 2))
	var tam_ma_raw: float = minf(tm_a * float(n_against), maxf(0.0, tm_cap - maxf(0.0, heart_demon_used)))
	var cost_mult: float = pow(1.0 - disc, float(mini(n_with, max_t)))
	return {
		"n_with": n_with,
		"n_against": n_against,
		"tam_ma_raw": tam_ma_raw,
		"standing_pen": st_a * n_against,
		"cost_mult": cost_mult,
	}


## Returns true if [param verb] is unlocked by trait [code]verb:[/code] side gating ([code]self[/code],
## [code]other[/code], or [code]either[/code]); always true for base verbs (empty [code]trait_hook[/code]).
static func check_trait_side(gd: GameData, player_rec: Dictionary, npc_rec: Dictionary, verb: Dictionary) -> bool:
	if str(verb.get("trait_hook", "")) == "":
		return true
	if gd == null or not gd.registry.has_file(NpcTraits.FILE):
		return false
	var avail: Array = NpcTraits.available_verbs(gd, player_rec, npc_rec, [verb])
	return avail.has(str(verb.get("id", "")))


## Returns the remaining focus yield fraction [code]clamp(1.0 - season_time_used, 0.0, 1.0)[/code] (GDD Rule 4).
static func focus_yield_share(season_time_used: float) -> float:
	return clampf(1.0 - season_time_used, 0.0, 1.0)


## Returns true if enough focus time remains this season to execute a verb costing [param verb_time] (GDD Rule 4).
static func has_focus_time(season_time_used: float, verb_time: float) -> bool:
	if verb_time <= 0.0:
		return true
	return (1.0 - season_time_used) + 1e-6 >= verb_time


## Returns true if [param pid] currently has a living [code]dao_lu[/code] tie in [param db].
static func has_living_dao_lu(db: WorldDB, pid: String) -> bool:
	if db == null or pid == "":
		return false
	for r in db.ties_of(pid):
		if Dictionary(r.get("pin", {})).has("dao_lu"):
			var other: String = str(r.b) if str(r.a) == pid else str(r.a)
			if bool(db.get_record("people", other).get("alive", false)):
				return true
	return false


## Evaluates every precondition in [param verb]["requirements"] against [param player] and [param npc].
## Optional [param ctx] may provide precomputed [code]has_open_obligation[/code] and [code]has_known_other[/code].
## Returns [code]{ok: bool, reasons: Array, reason: String}[/code].
static func check_requirements(
	gd: GameData,
	db: WorldDB,
	verb: Dictionary,
	player: Character,
	npc: Dictionary,
	ctx: Dictionary = {}
) -> Dictionary:
	var reasons: Array = []
	var npc_id: String = str(npc.get("id", ""))
	var band: String = attitude_band(gd, int(npc.get("attitude", 0)))
	for raw_req in Array(verb.get("requirements", [])):
		if not (raw_req is Dictionary):
			continue
		var req: Dictionary = raw_req as Dictionary
		var rtype: String = str(req.get("type", ""))
		match rtype:
			"met":
				if not bool(npc.get("met_player", false)):
					reasons.append("Meet %s first." % str(npc.get("name", "them")))
			"realm_above_player":
				if int(npc.get("realm_index", 0)) <= player.realm_index:
					reasons.append("Requires higher realm than yours.")
			"realm_below_player":
				if int(npc.get("realm_index", 0)) >= player.realm_index:
					reasons.append("Requires target below your realm.")
			"realm_at_most_player":
				if int(npc.get("realm_index", 0)) > player.realm_index:
					reasons.append("Target realm is above yours.")
			"can_teach":
				if not can_teach(gd, npc, player):
					reasons.append("Cannot teach you at your realm.")
			"has_spare_items":
				var tr: Dictionary = trade_items_for(gd, db, npc)
				if Array(tr.shown).is_empty() and Array(tr.locked).is_empty():
					reasons.append("Has no spare items.")
			"band_min":
				var need_b: String = str(req.get("band", "neutral"))
				if band_rank(band) < band_rank(need_b):
					reasons.append("Requires attitude %s." % need_b)
			"band_max":
				var max_b: String = str(req.get("band", "close"))
				if band_rank(band) > band_rank(max_b):
					reasons.append("Requires attitude at most %s." % max_b)
			"not_hostile":
				if band == "hostile":
					reasons.append("Hostile attitude.")
			"same_sect":
				if player.sect_id == "" or player.sect_id != str(npc.get("sect_id", "")):
					reasons.append("Must belong to the same sect.")
			"npc_in_sect":
				if str(npc.get("sect_id", "")) == "":
					reasons.append("Target belongs to no sect.")
			"player_loose":
				if player.sect_id != "":
					reasons.append("Requires loose cultivator.")
			"ties_enabled":
				if not Ties.enabled(gd):
					reasons.append("Relationships system disabled.")
			"notable_either":
				if db == null or not (Ties.notable(gd, db, player.id) or Ties.notable(gd, db, npc_id)):
					reasons.append("Requires a notable cultivator.")
			"target_no_living_master":
				if db != null and Ties.master_of(db, npc_id) != "":
					reasons.append("Already has a living master.")
			"neither_has_dao_lu":
				if has_living_dao_lu(db, player.id) or has_living_dao_lu(db, npc_id):
					reasons.append("Already has a living Dao companion.")
			"has_open_obligation":
				if not bool(ctx.get("has_open_obligation", false)):
					reasons.append("No open obligation.")
			"settled_place":
				if not _is_settled_place(gd, db, player.location_id):
					reasons.append("Requires a settled place.")
			"has_known_other":
				if not bool(ctx.get("has_known_other", false)):
					reasons.append("No other known person to ask about.")
			"player_has_giftable":
				var rmin: int = int(req.get("rarity_min", 1))
				if not _player_has_spare_item(gd, db, player, rmin):
					reasons.append("Requires an unequipped item (rarity %d+)." % rmin)
	return {"ok": reasons.is_empty(), "reasons": reasons, "reason": "; ".join(reasons)}


static func _is_settled_place(gd: GameData, db: WorldDB, place_id: String) -> bool:
	if db == null or place_id == "":
		return false
	var place: Dictionary = db.get_record("places", place_id)
	if place.is_empty():
		return false
	var settled_kinds: Array = Array(gd.world_gen().get("continent", {}).get("settled_kinds", []))
	if not settled_kinds.is_empty() and settled_kinds.has(str(place.get("kind", ""))):
		return true
	var ptype: String = str(place.get("type", ""))
	return ptype in ["thanh", "tran", "tong_mon", "phuong_thi"] or bool(place.get("market", false)) or bool(place.get("bounties", false))


static func _player_has_spare_item(gd: GameData, db: WorldDB, player: Character, rarity_min: int) -> bool:
	if db == null or player == null:
		return false
	for it in db.items_of(player.id):
		if player.equipped.has(str(it.get("id", ""))):
			continue
		if str(it.get("kind", "")) == "herb" and int(it.get("plot", -1)) >= 0:
			continue
		if ItemRarity.of(gd, it) >= rarity_min:
			return true
	return false
