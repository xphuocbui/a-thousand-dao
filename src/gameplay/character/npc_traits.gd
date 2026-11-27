class_name NpcTraits
extends RefCounted

## NPC Traits (design/gdd/npc-traits.md, catalogue design/gdd/npc-traits-catalogue.md; data assets/data/traits.json):
## every person holds traits across ten kinds — v1 (3 personality traits with no opposed pair, 1 calling, 0-2 kept
## fate-given, 0-2 gained) and v2 (1 upbringing, 0-2 talent families at tier 1-3 [1-3 for authored tier A], 0-2 path,
## 0-1 lifestyle, 0-2 health, 0-1 coping). The record is [code]npc_traits[/code] on the person:
## {personality: [ids], calling: id, fate: [ids], gained: [{id, expires, target}], upbringing: id,
## talent: [{id, tier}], path: [ids], lifestyle: id, health: [ids], coping: {} | {id, expires?, refreshes, hardened}}.
## Everything else — stat rows (F1/F1b), choice weights (F2/F7), opinion with likes (F3), Sects F15 pulls + policy
## hooks, and opened hooks / dialogue verbs (rule 8a) — is derived from the catalogue when read.

const FILE := "traits"
const KINDS_V1 := ["personality", "callings", "fate", "gained"]
const KINDS_V2 := ["upbringing", "talent", "path", "lifestyle", "health", "coping"]
const ALL_KINDS := ["personality", "callings", "fate", "gained", "upbringing", "talent", "path", "lifestyle", "health", "coping"]
## Tie-break order for resolving One-element devotee's [code]own_top_element[/code] scope (rule 7, AC-NT-54).
const BASE_ELEMENT_ORDER := ["kim", "moc", "thuy", "hoa", "tho"]
const KIND_LABELS := {
	"personality": "Tính tình",
	"callings": "Nghề nghiệp",
	"fate": "Bẩm sinh",
	"gained": "Hậu thiên",
	"upbringing": "Xuất thân",
	"talent": "Thiên phú",
	"path": "Tu hành",
	"lifestyle": "Thú vui",
	"health": "Thương bệnh",
	"coping": "Ứng phó",
}
const _ENV_SCOPES := [
	"ground", "terrain", "biome", "weather", "place", "time", "season",
	"forest", "mountain", "river", "sea", "city", "village", "wild",
	"day", "night", "spring", "summer", "autumn", "winter", "rain", "snow", "cold_months",
	"own_abode", "vein", "inside_array",
]
const _HOOK_PREFIXES := ["event:", "verb:", "policy:", "stance:", "craft:"]

static var _cache: Dictionary = {}


## The catalogue indexed across all ten kinds: {by_id, kind, by_name, retired_fates, opposed_map, policy_hooks,
## verb_hooks, verb_side, file}.
static func catalogue(gd: GameData) -> Dictionary:
	var key: int = gd.get_instance_id()
	if _cache.has(key):
		return _cache[key]
	var f: Dictionary = gd.file(FILE)
	var by_id := {}
	var kind := {}
	var by_name := {}
	for k in ALL_KINDS:
		for t in f.get(k, []):
			var tid: String = str(t.id)
			by_id[tid] = t
			kind[tid] = k
			by_name[tid.to_lower()] = tid
			var nm: String = str(t.get("name", "")).to_lower()
			if nm != "":
				by_name[nm] = tid
	# Register talent tier display names (after primary names so primary ids/names take precedence).
	for t in f.get("talent", []):
		var tid: String = str(t.id)
		for tn in Array(t.get("tier_names", [])) + Array(t.get("tier_names_vi", [])):
			var low: String = str(tn).strip_edges().to_lower()
			if low != "" and not by_name.has(low):
				by_name[low] = tid
	var retired_fates := {}
	var raw_retired: Dictionary = f.get("retired_fates", {})
	for slug in raw_retired:
		var conv: Dictionary = raw_retired[slug]
		var low: String = str(slug).strip_edges().to_lower()
		retired_fates[low] = conv
		retired_fates[low.replace("_", "-")] = conv
		retired_fates[low.replace("_", " ")] = conv
	var opposed_map := {}
	for pair in f.get("opposed_v2", []):
		if pair is Array and pair.size() >= 2:
			var a: String = str(pair[0])
			var b: String = str(pair[1])
			if not opposed_map.has(a):
				opposed_map[a] = []
			if not (opposed_map[a] as Array).has(b):
				(opposed_map[a] as Array).append(b)
			if not opposed_map.has(b):
				opposed_map[b] = []
			if not (opposed_map[b] as Array).has(a):
				(opposed_map[b] as Array).append(a)
	var verb_hooks: Array = Array(f.get("verb_hooks", []))
	var verb_side := {}
	for vh in verb_hooks:
		if vh is Dictionary and str(vh.get("id", "")) != "":
			verb_side[str(vh.id)] = str(vh.get("side", "self"))
	var out := {
		"by_id": by_id,
		"kind": kind,
		"by_name": by_name,
		"retired_fates": retired_fates,
		"opposed_map": opposed_map,
		"policy_hooks": f.get("policy_hooks", {}),
		"verb_hooks": verb_hooks,
		"verb_side": verb_side,
		"file": f,
	}
	_cache[key] = out
	return out


## True when two personality traits are opposed. Compassionate is opposed to both Callous and Cruel; Callous and
## Cruel may be held together (Trait list, AC-NT-24).
static func _personality_opposed(cat: Dictionary, a_id: String, b_id: String) -> bool:
	if a_id == b_id or a_id == "" or b_id == "":
		return false
	if (a_id == "callous" and b_id == "cruel") or (a_id == "cruel" and b_id == "callous"):
		return false
	var sa: int = int(cat.by_id.get(a_id, {}).get("set", -1))
	var sb: int = int(cat.by_id.get(b_id, {}).get("set", -2))
	return sa >= 0 and sa == sb


## True when trait [param a_id] and trait [param b_id] are opposed under v1 or v2 opposition rules.
static func is_opposed(gd: GameData, a_id: String, b_id: String) -> bool:
	return _is_opposed(catalogue(gd), a_id, b_id)


static func _is_opposed(cat: Dictionary, a_id: String, b_id: String) -> bool:
	if a_id == "" or b_id == "" or a_id == b_id:
		return false
	var ka: String = str(cat.kind.get(a_id, ""))
	var kb: String = str(cat.kind.get(b_id, ""))
	if ka == "personality" and kb == "personality":
		return _personality_opposed(cat, a_id, b_id)
	if Array(cat.opposed_map.get(a_id, [])).has(b_id):
		return true
	if ka == "fate" and kb == "fate":
		var pa: String = str(cat.by_id.get(a_id, {}).get("pair", ""))
		return pa != "" and pa == str(cat.by_id.get(b_id, {}).get("pair", ""))
	if ka == "gained" and kb == "gained":
		return str(cat.by_id.get(a_id, {}).get("opposed", "")) == b_id \
			or str(cat.by_id.get(b_id, {}).get("opposed", "")) == a_id
	return false


static func _empty_record() -> Dictionary:
	return {
		"personality": [],
		"calling": "",
		"fate": [],
		"gained": [],
		"upbringing": "",
		"talent": [],
		"path": [],
		"lifestyle": "",
		"health": [],
		"coping": {},
	}


static func _ensure_record(person: Dictionary) -> Dictionary:
	if not person.has("npc_traits") or not (person.npc_traits is Dictionary):
		person["npc_traits"] = _empty_record()
		return person.npc_traits
	var nt: Dictionary = person.npc_traits
	for k in ["personality", "fate", "gained", "talent", "path", "health"]:
		if not nt.has(k):
			nt[k] = []
	for k in ["calling", "upbringing", "lifestyle"]:
		if not nt.has(k):
			nt[k] = ""
	if not nt.has("coping") or nt.coping == null:
		nt["coping"] = {}
	return nt


static func _unwrap_traits(entry: Variant) -> Dictionary:
	if not (entry is Dictionary):
		return {}
	var d: Dictionary = entry
	if d.has("npc_traits") and d.npc_traits is Dictionary:
		return d.npc_traits
	return d


static func _norm_str_array(raw: Variant) -> Array:
	var out: Array = []
	if raw is Array:
		for x in raw:
			var s: String = str(x).strip_edges()
			if s != "":
				out.append(s)
	elif raw is String:
		var s: String = (raw as String).strip_edges()
		if s != "":
			out.append(s)
	return out


static func _norm_coping(raw: Variant, cat: Dictionary, now: int, fade_c: int) -> Dictionary:
	if raw == null:
		return {}
	if raw is String:
		var s: String = (raw as String).strip_edges()
		if s == "":
			return {}
		var cid: String = str(cat.by_name.get(s.to_lower(), ""))
		if cid == "" or str(cat.kind.get(cid, "")) != "coping":
			return {}
		return {"id": cid, "expires": now + fade_c, "refreshes": 0, "hardened": false}
	if raw is Dictionary:
		var d: Dictionary = raw
		if d.is_empty():
			return {}
		var cid: String = str(cat.by_name.get(str(d.get("id", "")).strip_edges().to_lower(), ""))
		if cid == "" or str(cat.kind.get(cid, "")) != "coping":
			return {}
		var hardened: bool = bool(d.get("hardened", false))
		var out := {"id": cid, "refreshes": int(d.get("refreshes", 0)), "hardened": hardened}
		if not hardened:
			out["expires"] = int(d.get("expires", now + fade_c))
		return out
	return {}


## F4b root bond check for a path trait against [param linh_can] ([LinhCan] or root dict, or null).
static func path_bond_met(gd: GameData, path_id: String, linh_can: Variant) -> bool:
	var bond: Dictionary = catalogue(gd).file.get("path_root_bonds", {}).get(path_id, {})
	if bond.is_empty():
		return true
	if linh_can == null:
		return false
	if bond.has("any"):
		for e in bond.any:
			if _lc_has(linh_can, str(e)):
				return true
		return false
	if bond.has("any_group"):
		for grp in bond.any_group:
			var ok: bool = true
			for e in grp:
				if not _lc_has(linh_can, str(e)):
					ok = false
					break
			if ok:
				return true
		return false
	if bool(bond.get("single_base", false)):
		return _lc_base_count(linh_can) == 1
	return true


static func _lc_has(lc: Variant, el_id: String) -> bool:
	if lc is LinhCan:
		return (lc as LinhCan).has(el_id)
	if lc is Dictionary:
		var d: Dictionary = lc
		return Dictionary(d.get("elements", {})).has(el_id) or Dictionary(d.get("variants", {})).has(el_id)
	return false


static func _lc_base_count(lc: Variant) -> int:
	if lc is LinhCan:
		return (lc as LinhCan).base_count()
	if lc is Dictionary:
		return Dictionary((lc as Dictionary).get("elements", {})).size()
	return 0


static func _lc_purity(lc: Variant, el_id: String) -> float:
	if lc is LinhCan:
		return (lc as LinhCan).purity(el_id)
	if lc is Dictionary:
		var d: Dictionary = lc
		var r: float = float(Dictionary(d.get("road", {})).get(el_id, 0.0))
		var els: Dictionary = d.get("elements", {})
		if els.has(el_id):
			return float(els[el_id]) + r
		return float(Dictionary(d.get("variants", {})).get(el_id, 0.0)) + r
	return 0.0


static func _lc_owns_base(lc: Variant, el_id: String) -> bool:
	if lc is LinhCan:
		return (lc as LinhCan).elements.has(el_id)
	if lc is Dictionary:
		return Dictionary((lc as Dictionary).get("elements", {})).has(el_id)
	return false


## Resolves One-element devotee's [code]own_top_element[/code] placeholder to the holder's highest-purity owned base
## element (tie order Kim, Mộc, Thủy, Hỏa, Thổ), or "" when the root has no owned base element (rule 7, AC-NT-54).
static func own_top_element(linh_can: Variant) -> String:
	if linh_can == null:
		return ""
	var best: String = ""
	var best_p: float = -1.0
	for el in BASE_ELEMENT_ORDER:
		if _lc_owns_base(linh_can, el):
			var p: float = _lc_purity(linh_can, el)
			if best == "" or p > best_p:
				best = el
				best_p = p
	return best


## F5b: inherits talent families with drift from 1 or 2 parent trait records ([param parents]), keyed on
## [code]inherit_talent:<key>:<fid>[/code] and [code]talent_drift:<key>:<fid>[/code]. A gift and its opposed flaw
## both inherited cancel both; families opposed to [param held_fates] are dropped; if more than 2 remain, keeps the
## top 2 by descending tier (ties broken by catalogue order).
static func inherit_talents(gd: GameData, key: String, parents: Array, held_fates: Array = []) -> Array:
	if parents.is_empty():
		return []
	var cat := catalogue(gd)
	var f: Dictionary = cat.file
	var inh: Dictionary = f.get("inherit", {})
	var p_one: float = float(inh.get("talent_one", 0.35))
	var p_both: float = float(inh.get("talent_both", 0.65))
	var drift_w: Array = Array(inh.get("talent_drift", [0.40, 0.45, 0.15]))
	var w_neg: float = float(drift_w[0]) if drift_w.size() > 0 else 0.40
	var w_zero: float = float(drift_w[1]) if drift_w.size() > 1 else 0.45
	var p_count := {}
	var p_best := {}
	for par in parents:
		var nt: Dictionary = _unwrap_traits(par)
		if nt.is_empty():
			continue
		var seen_parent := {}
		for entry in nt.get("talent", []):
			if not (entry is Dictionary):
				continue
			var fid: String = str(entry.get("id", ""))
			if fid == "" or str(cat.kind.get(fid, "")) != "talent" or seen_parent.has(fid):
				continue
			seen_parent[fid] = true
			var tier: int = clampi(int(entry.get("tier", 1)), 1, 3)
			p_count[fid] = int(p_count.get(fid, 0)) + 1
			p_best[fid] = maxi(int(p_best.get(fid, 0)), tier)
	if p_count.is_empty():
		return []
	var fams: Array = Array(f.get("talent", []))
	var inherited: Array = []
	for idx in fams.size():
		var fid: String = str(fams[idx].id)
		var cnt: int = int(p_count.get(fid, 0))
		if cnt <= 0:
			continue
		var p_inh: float = p_both if cnt >= 2 else p_one
		var r_inh := RandomNumberGenerator.new()
		r_inh.seed = RngUtils.stable_hash("inherit_talent:%s:%s" % [key, fid])
		if r_inh.randf() >= p_inh:
			continue
		var k0: int = int(p_best[fid])
		var r_dr := RandomNumberGenerator.new()
		r_dr.seed = RngUtils.stable_hash("talent_drift:%s:%s" % [key, fid])
		var u_dr: float = r_dr.randf()
		var delta: int = -1 if u_dr < w_neg else (0 if u_dr < w_neg + w_zero else 1)
		var k: int = mini(3, k0 + delta)
		if k >= 1:
			inherited.append({"id": fid, "tier": k, "_ord": idx})
	# Cancel both sides when both a talent gift and its opposed flaw are inherited.
	var held_ids := {}
	for e in inherited:
		held_ids[str(e.id)] = true
	var cancelled := {}
	for e in inherited:
		var fid: String = str(e.id)
		for opp in Array(cat.opposed_map.get(fid, [])):
			if held_ids.has(str(opp)):
				cancelled[fid] = true
				cancelled[str(opp)] = true
	var kept: Array = []
	for e in inherited:
		var fid: String = str(e.id)
		if cancelled.has(fid):
			continue
		var fate_conflict: bool = false
		for hf in held_fates:
			if _is_opposed(cat, fid, str(hf)):
				fate_conflict = true
				break
		if not fate_conflict:
			kept.append(e)
	if kept.size() > 2:
		kept.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
			if int(a.tier) != int(b.tier):
				return int(a.tier) > int(b.tier)
			return int(a._ord) < int(b._ord))
		kept = kept.slice(0, 2)
	var out: Array = []
	for e in kept:
		out.append({"id": str(e.id), "tier": int(e.tier)})
	return out


## F4 + F5 + F5b + F4b: rolls a person's traits from keyed streams on [param key] (world seed + person id):
## 3 non-opposed personality traits (F5 parent inheritance + F4 weighted fill with m_master on
## [param master_personality]), 1 calling, 0-2 kept fate-given traits, F5b inherited talents, and F4b v2 kinds
## (1 upbringing, then optional talent, path, health, lifestyle, coping up to n_create_max).
## [param opts] keys (all optional): realm_index, linh_can, birthplace_kind, family_kind, parents, now.
static func roll(gd: GameData, key: String, archetype: String, sect_member: bool, master_personality: Array = [],
		talents: Dictionary = {}, opts: Dictionary = {}) -> Dictionary:
	var cat := catalogue(gd)
	var f: Dictionary = cat.file
	var inh: Dictionary = f.get("inherit", {})
	var pool: Array = Array(f.get("personality", [])).duplicate()
	var pers: Array = []
	var parents: Array = Array(opts.get("parents", []))
	var h_pers: float = float(inh.get("h", 0.5))
	# F5: personality inheritance per known parent on keyed stream inherit:<key>:<pi>
	for pi in parents.size():
		if pers.size() >= 3:
			break
		var p_nt: Dictionary = _unwrap_traits(parents[pi])
		var p_pers: Array = Array(p_nt.get("personality", []))
		if p_pers.is_empty():
			continue
		var r_inh := RandomNumberGenerator.new()
		r_inh.seed = RngUtils.stable_hash("inherit:%s:%d" % [key, pi])
		if r_inh.randf() >= h_pers:
			continue
		var cands: Array = []
		for pid in p_pers:
			var s_pid: String = str(pid)
			if not cat.by_id.has(s_pid) or pers.has(s_pid):
				continue
			var opp: bool = false
			for held_p in pers:
				if _personality_opposed(cat, s_pid, str(held_p)):
					opp = true
					break
			if not opp:
				cands.append(s_pid)
		if not cands.is_empty():
			var chosen: String = str(cands[r_inh.randi_range(0, cands.size() - 1)])
			pers.append(chosen)
			pool = pool.filter(func(x): return str(x.id) != chosen and not _personality_opposed(cat, chosen, str(x.id)))
	var r := RandomNumberGenerator.new()
	r.seed = RngUtils.stable_hash("traits:" + key)
	var m_master: float = float(inh.get("m_master", 3.0))   # F5: a master known at creation
	while pers.size() < 3 and not pool.is_empty():
		var t: Dictionary = RngUtils.weighted_pick(r, pool.map(func(x): return {"id": str(x.id), "set": int(x.set),
			"weight": float(x.get("weight", 1.0)) * (m_master if master_personality.has(str(x.id)) else 1.0)}))
		var tid: String = str(t.id)
		pers.append(tid)
		pool = pool.filter(func(x): return str(x.id) != tid and not _personality_opposed(cat, tid, str(x.id)))
	var cw: Dictionary = Dictionary(f.get("calling_weights", {}).get(archetype, f.get("calling_weights", {}).get("tan_tu", {}))).duplicate()
	if sect_member:
		for c in f.get("calling_weights", {}).get("sect_member", {}):
			cw[c] = float(cw.get(c, 0.0)) + float(f.calling_weights.sect_member[c])
	var calling: String = ""
	if not cw.is_empty():
		var c_opts: Array = []
		var keys: Array = cw.keys()
		keys.sort()
		for c in keys:
			c_opts.append({"id": str(c), "weight": float(cw[c])})
		calling = str(RngUtils.weighted_pick(r, c_opts).id)
	var fate: Array = []
	var rc: Dictionary = f.get("roll", {})
	var p_any: float = float(rc.get("p_any", 0.04))
	var p_sec: float = float(rc.get("p_second", 0.10))
	var u: float = r.randf()
	var p2: float = p_any * p_sec
	var n_fate: int = 2 if u < p2 else (1 if u < p_any else 0)
	var fpool: Array = Array(f.get("fate", [])).duplicate()
	for i in n_fate:
		if fpool.is_empty():
			break
		var ft: Dictionary = RngUtils.weighted_pick(r, fpool.map(func(x): return {"id": str(x.id), "pair": str(x.pair),
			"weight": g_f(rc, str(x.get("reads", "")), talents)}))
		fate.append(str(ft.id))
		fpool = fpool.filter(func(x): return str(x.pair) != str(ft.pair))
	# F5b: inherited talents (never skipped by n_create_max)
	var talent: Array = inherit_talents(gd, key, parents, fate)
	var n_inh: int = talent.size()
	# F4b: v2 creation roll on separate keyed stream per kind
	var rv2: Dictionary = f.get("roll_v2", {})
	var upbringing: String = _roll_upbringing(gd, cat, rv2, key, opts, parents)
	var n_now: int = pers.size() + (1 if calling != "" else 0) + (1 if upbringing != "" else 0) + fate.size() + talent.size()
	var n_max: int = int(rv2.get("n_create_max", 6))
	# Talent roll
	var r_t := RandomNumberGenerator.new()
	r_t.seed = RngUtils.stable_hash("traits_v2:%s:talent" % key)
	var pt: Array = Array(rv2.get("p_talent", [0.75, 0.22, 0.03]))
	var ut: float = r_t.randf()
	var pt0: float = float(pt[0]) if pt.size() > 0 else 0.75
	var pt1: float = float(pt[1]) if pt.size() > 1 else 0.22
	var n_t: int = 0 if ut < pt0 else (1 if ut < pt0 + pt1 else 2)
	var want_t: int = maxi(n_t, n_inh)
	var pti: Array = Array(rv2.get("p_tier", [0.70, 0.24, 0.06]))
	var pti0: float = float(pti[0]) if pti.size() > 0 else 0.70
	var pti1: float = float(pti[1]) if pti.size() > 1 else 0.24
	while talent.size() < want_t and n_now < n_max:
		var t_cands: Array = []
		for fam in f.get("talent", []):
			var fid: String = str(fam.id)
			var blocked: bool = false
			for held_t in talent:
				var hfid: String = str(held_t.id)
				if hfid == fid or _is_opposed(cat, fid, hfid):
					blocked = true
					break
			if blocked:
				continue
			for hf in fate:
				if _is_opposed(cat, fid, str(hf)):
					blocked = true
					break
			if blocked:
				continue
			var stat_k: String = str(fam.get("stat", ""))
			var reads: String = stat_k if int(fam.get("direction", 1)) > 0 else ("%s (inverse)" % stat_k)
			t_cands.append({"id": fid, "weight": g_f(rc, reads, talents)})
		if t_cands.is_empty():
			break
		var pick_t: Dictionary = RngUtils.weighted_pick(r_t, t_cands)
		var uti: float = r_t.randf()
		var tier: int = 1 if uti < pti0 else (2 if uti < pti0 + pti1 else 3)
		talent.append({"id": str(pick_t.id), "tier": tier})
		n_now += 1
	# Path roll
	var paths: Array = []
	if n_now < n_max:
		var r_p := RandomNumberGenerator.new()
		r_p.seed = RngUtils.stable_hash("traits_v2:%s:path" % key)
		var pp: Array = Array(rv2.get("p_path", [0.05, 0.20, 0.40, 0.60, 0.60]))
		var ri: int = clampi(int(opts.get("realm_index", 0)), 0, maxi(pp.size() - 1, 0))
		var p_chance: float = float(pp[ri]) if not pp.is_empty() else 0.0
		if r_p.randf() < p_chance:
			var lc: Variant = opts.get("linh_can", null)
			var p_cands: Array = []
			for pt_entry in f.get("path", []):
				var pid: String = str(pt_entry.id)
				if path_bond_met(gd, pid, lc):
					p_cands.append(pid)
			if not p_cands.is_empty():
				paths.append(str(p_cands[r_p.randi_range(0, p_cands.size() - 1)]))
				n_now += 1
	# Health roll (excluding waning_years)
	var health: Array = []
	if n_now < n_max:
		var r_h := RandomNumberGenerator.new()
		r_h.seed = RngUtils.stable_hash("traits_v2:%s:health" % key)
		if r_h.randf() < float(rv2.get("p_health", 0.08)):
			var h_cands: Array = []
			for h_entry in f.get("health", []):
				var hid: String = str(h_entry.id)
				if hid != "waning_years":
					h_cands.append(hid)
			if not h_cands.is_empty():
				health.append(str(h_cands[r_h.randi_range(0, h_cands.size() - 1)]))
				n_now += 1
	# Lifestyle roll
	var lifestyle: String = ""
	if n_now < n_max:
		var r_l := RandomNumberGenerator.new()
		r_l.seed = RngUtils.stable_hash("traits_v2:%s:lifestyle" % key)
		if r_l.randf() < float(rv2.get("p_lifestyle", 0.35)):
			var l_cands: Array = Array(f.get("lifestyle", []))
			if not l_cands.is_empty():
				lifestyle = str(l_cands[r_l.randi_range(0, l_cands.size() - 1)].id)
				n_now += 1
	# Coping roll
	var coping: Dictionary = {}
	if n_now < n_max:
		var r_c := RandomNumberGenerator.new()
		r_c.seed = RngUtils.stable_hash("traits_v2:%s:coping" % key)
		if r_c.randf() < float(rv2.get("p_coping", 0.03)):
			var c_cands: Array = Array(f.get("coping", []))
			if not c_cands.is_empty():
				var cid: String = str(c_cands[r_c.randi_range(0, c_cands.size() - 1)].id)
				var now_s: int = int(opts.get("now", 0))
				var fade_c: int = int(rv2.get("coping_fade_seasons", 20))
				coping = {"id": cid, "expires": now_s + fade_c, "refreshes": 0, "hardened": false}
				n_now += 1
	return {
		"personality": pers,
		"calling": calling,
		"fate": fate,
		"gained": [],
		"upbringing": upbringing,
		"talent": talent,
		"path": paths,
		"lifestyle": lifestyle,
		"health": health,
		"coping": coping,
	}


static func _roll_upbringing(gd: GameData, cat: Dictionary, rv2: Dictionary, key: String, opts: Dictionary, parents: Array) -> String:
	var up_list: Array = Array(cat.file.get("upbringing", []))
	if up_list.is_empty():
		return ""
	var r_u := RandomNumberGenerator.new()
	r_u.seed = RngUtils.stable_hash("traits_v2:%s:upbringing" % key)
	var birth_leans_all: Dictionary = rv2.get("birth_leans", {})
	var bp_kind: String = str(opts.get("birthplace_kind", ""))
	if bp_kind != "" and not birth_leans_all.has(bp_kind):
		var wild_kinds: Array = Array(gd.world_gen().get("continent", {}).get("wild_kinds", []))
		if wild_kinds.has(bp_kind) or bp_kind in ["ruin", "secret_realm", "abode", "blessed_land"]:
			bp_kind = "wild"
	var b_leans: Dictionary = birth_leans_all.get(bp_kind, {})
	var fam_kind: String = str(opts.get("family_kind", ""))
	if fam_kind == "" and not parents.is_empty():
		fam_kind = "cultivating"
	var f_leans: Dictionary = rv2.get("family_leans", {}).get(fam_kind, {})
	var weighted: Array = []
	for u in up_list:
		var uid: String = str(u.id)
		var w: float = float(b_leans.get(uid, 1.0)) * float(f_leans.get(uid, 1.0))
		weighted.append({"id": uid, "weight": maxf(w, 0.0)})
	return str(RngUtils.weighted_pick(r_u, weighted).id)


## F4's g_f of a fate-given trait or talent family whose catalogue "reads" is [param reads] ("khi_van" or
## "khi_van (inverse)") for a person with talents [param talents] (thiên phú, before trait rows):
## clamp(t / g_ref, lo, hi), or its inverse.
static func g_f(rc: Dictionary, reads: String, talents: Dictionary) -> float:
	var key: String = reads.split(" ")[0]
	if not talents.has(key):
		return 1.0
	var t: float = maxf(float(talents[key]), 1e-6)
	var ref: float = float(rc.get("g_ref", 45.0))
	var v: float = ref / t if reads.contains("inverse") else t / ref
	return clampf(v, float(rc.get("g_lo", 0.25)), float(rc.get("g_hi", 3.0)))


## Migrates any retired v1 fate ids/names in [param nt]'s [code]fate[/code] list into [code]talent[/code] tiers
## (rule 2, AC-NT-49). Keeps the higher tier when the family is already held and drops any opposed family cleanly.
static func migrate_retired_fates(gd: GameData, nt: Dictionary) -> Dictionary:
	var cat := catalogue(gd)
	var raw_fates: Array = Array(nt.get("fate", []))
	var talents: Array = []
	for entry in nt.get("talent", []):
		if entry is Dictionary:
			var tid: String = str(cat.by_name.get(str(entry.get("id", "")).strip_edges().to_lower(), ""))
			if tid != "" and str(cat.kind.get(tid, "")) == "talent":
				talents.append({"id": tid, "tier": clampi(int(entry.get("tier", 1)), 1, 3)})
	var new_fate: Array = []
	for raw in raw_fates:
		var key_low: String = str(raw).strip_edges().to_lower()
		if key_low == "":
			continue
		if cat.retired_fates.has(key_low):
			var conv: Dictionary = cat.retired_fates[key_low]
			var tid: String = str(conv.id)
			var tier: int = clampi(int(conv.tier), 1, 3)
			var merged: bool = false
			for existing in talents:
				if str(existing.id) == tid:
					existing["tier"] = maxi(int(existing.tier), tier)
					merged = true
					break
			if not merged:
				talents = talents.filter(func(e): return not _is_opposed(cat, tid, str(e.id)))
				talents.append({"id": tid, "tier": tier})
			continue
		var fid: String = str(cat.by_name.get(key_low, ""))
		if fid != "" and str(cat.kind.get(fid, "")) == "fate" and not new_fate.has(fid):
			var conflict: bool = false
			for ef in new_fate:
				if _is_opposed(cat, fid, str(ef)):
					conflict = true
					break
			if not conflict:
				new_fate.append(fid)
	# Ensure no talent conflicts with a kept fate.
	if not new_fate.is_empty():
		talents = talents.filter(func(e):
			for hf in new_fate:
				if _is_opposed(cat, str(e.id), str(hf)):
					return false
			return true)
	nt["fate"] = new_fate
	nt["talent"] = talents
	return nt


## The cast's authored traits (v1 personality, calling, fate_given + v2 upbringing, talent, path, lifestyle, health,
## coping) normalized to catalogue ids, with retired v1 fates migrated to talent tiers (AC-NT-49).
static func from_authored(gd: GameData, authored: Dictionary, now: int = 0) -> Dictionary:
	var cat := catalogue(gd)
	var rv2: Dictionary = cat.file.get("roll_v2", {})
	var fade_c: int = int(rv2.get("coping_fade_seasons", 20))
	var pers: Array = []
	for n in authored.get("personality", []):
		var id: String = str(cat.by_name.get(str(n).strip_edges().to_lower(), ""))
		if id != "" and str(cat.kind.get(id, "")) == "personality" and not pers.has(id):
			pers.append(id)
	var calling: String = str(cat.by_name.get(str(authored.get("calling", "")).strip_edges().to_lower(), ""))
	if calling != "" and str(cat.kind.get(calling, "")) != "callings":
		calling = ""
	var raw_fates: Array = Array(authored.get("fate_given", authored.get("fate", [])))
	var upbringing: String = str(cat.by_name.get(str(authored.get("upbringing", "")).strip_edges().to_lower(), ""))
	if upbringing != "" and str(cat.kind.get(upbringing, "")) != "upbringing":
		upbringing = ""
	var talents_out: Array = []
	for entry in authored.get("talent", []):
		if entry is Dictionary:
			var tid: String = str(cat.by_name.get(str(entry.get("id", "")).strip_edges().to_lower(), ""))
			if tid == "" or str(cat.kind.get(tid, "")) != "talent":
				continue
			var tier: int = clampi(int(entry.get("tier", 1)), 1, 3)
			var dup: bool = false
			var opp: bool = false
			for ex in talents_out:
				if str(ex.id) == tid:
					ex["tier"] = maxi(int(ex.tier), tier)
					dup = true
					break
				if _is_opposed(cat, tid, str(ex.id)):
					opp = true
					break
			if not dup and not opp:
				talents_out.append({"id": tid, "tier": tier})
	var paths: Array = []
	for raw_p in _norm_str_array(authored.get("path", [])):
		var pid: String = str(cat.by_name.get(str(raw_p).to_lower(), ""))
		if pid == "" or str(cat.kind.get(pid, "")) != "path" or paths.has(pid):
			continue
		var opp: bool = false
		for ep in paths:
			if _is_opposed(cat, pid, str(ep)):
				opp = true
				break
		if not opp:
			paths.append(pid)
	var lifestyle: String = str(cat.by_name.get(str(authored.get("lifestyle", "")).strip_edges().to_lower(), ""))
	if lifestyle != "" and str(cat.kind.get(lifestyle, "")) != "lifestyle":
		lifestyle = ""
	var health: Array = []
	for raw_h in _norm_str_array(authored.get("health", [])):
		var hid: String = str(cat.by_name.get(str(raw_h).to_lower(), ""))
		if hid != "" and str(cat.kind.get(hid, "")) == "health" and not health.has(hid):
			health.append(hid)
	var coping: Dictionary = _norm_coping(authored.get("coping", null), cat, now, fade_c)
	var out := {
		"personality": pers,
		"calling": calling,
		"fate": raw_fates,
		"gained": [],
		"upbringing": upbringing,
		"talent": talents_out,
		"path": paths,
		"lifestyle": lifestyle,
		"health": health,
		"coping": coping,
	}
	return migrate_retired_fates(gd, out)


## F2: the weight of a choice tagged [param tags] for [param person]: [param base] times the product of every held
## trait's weight on every tag (catalogue; unlisted pairs 1.0), clamped to [m_lo, m_hi]; 0 when any weight is the
## catalogue's never (0). Includes the 15 behaviour-shaping v2 traits (rule 8, AC-NT-51).
static func choice_weight(gd: GameData, person: Dictionary, tags: Array, base: float = 1.0) -> float:
	var cat := catalogue(gd)
	var c: Dictionary = cat.file.get("choice", {})
	var m: float = 1.0
	for id in held(person):
		var tw: Dictionary = cat.by_id.get(str(id), {}).get("tags", {})
		for g in tags:
			var gs: String = str(g)
			if tw.has(gs):
				if float(tw[gs]) <= 0.0:
					return 0.0
				m *= float(tw[gs])
	return base * clampf(m, float(c.get("m_lo", 0.1)), float(c.get("m_hi", 5.0)))


## F7: counts how many held traits align with vs against a choice tagged [param tags]: per held trait, product p_t;
## never or p_t < 0.99 counts against, p_t > 1.01 counts with, [0.99, 1.01] counts neither.
## Returns {"with": n_with, "against": n_against}.
static func choice_alignment(gd: GameData, person: Dictionary, tags: Array) -> Dictionary:
	var cat := catalogue(gd)
	var n_with: int = 0
	var n_against: int = 0
	for id in held(person):
		var tw: Dictionary = cat.by_id.get(str(id), {}).get("tags", {})
		if tw.is_empty():
			continue
		var p_t: float = 1.0
		var is_never: bool = false
		for g in tags:
			var gs: String = str(g)
			if tw.has(gs):
				var w: float = float(tw[gs])
				if w <= 0.0:
					is_never = true
					break
				p_t *= w
		if is_never or p_t < 0.99:
			n_against += 1
		elif p_t > 1.01:
			n_with += 1
	return {"with": n_with, "against": n_against}


## F2's pick among [param choices] ([{base, tags}]) for [param person], keyed on ("choice", event id, person id,
## season): the first choice whose running weight reaches u · Σ w; base weights when every weight is 0. Returns its index.
static func pick_choice(gd: GameData, person: Dictionary, choices: Array, event_id: String, season: int) -> int:
	var w: Array = choices.map(func(ch): return choice_weight(gd, person, Array(ch.get("tags", [])), float(ch.get("base", 1.0))))
	var total: float = 0.0
	for x in w:
		total += float(x)
	if total <= 0.0:
		w = choices.map(func(ch): return float(ch.get("base", 1.0)))
		total = 0.0
		for x in w:
			total += float(x)
	var r := RandomNumberGenerator.new()
	r.seed = RngUtils.stable_hash("choice:%s:%s:%d" % [event_id, str(person.get("id", "")), season])
	var u: float = r.randf() * total
	var run: float = 0.0
	for i in w.size():
		run += float(w[i])
		if run >= u:
			return i
	return w.size() - 1


## F3's v2 likes/dislikes term lk(a -> b): for each v2 trait held by [param a], +opinion.like (5) per liked target
## held by [param b] (all 10 kinds; talent matches at any tier) and -opinion.dislike (10) per disliked target.
static func opinion_lk(gd: GameData, a: Dictionary, b: Dictionary) -> float:
	var cat := catalogue(gd)
	var c: Dictionary = cat.file.get("opinion", {})
	var like_v: float = float(c.get("like", 5))
	var dislike_v: float = float(c.get("dislike", 10))
	var va: Array = held_v2(a)
	if va.is_empty():
		return 0.0
	var b_set := {}
	for bid in held(b):
		b_set[str(bid)] = true
	if b_set.is_empty():
		return 0.0
	var lk: float = 0.0
	for vid in va:
		var vt: Dictionary = cat.by_id.get(str(vid), {})
		for target in vt.get("likes", []):
			var tid: String = str(cat.by_name.get(str(target).strip_edges().to_lower(), str(target)))
			if b_set.has(tid):
				lk += like_v
		for target in vt.get("dislikes", []):
			var tid: String = str(cat.by_name.get(str(target).strip_edges().to_lower(), str(target)))
			if b_set.has(tid):
				lk -= dislike_v
	return lk


## F3: person [param a]'s opinion of person [param b] (records), −100 to 100: s per shared personality trait or calling,
## −o per opposed pair (personality sets and gained opposites only), b's bias_all, a's directed regard toward b,
## v2 likes/dislikes lk(a, b), ties, sect term, and targeted gained trait naming b. Computed, never stored.
static func opinion(gd: GameData, db: WorldDB, a: Dictionary, b: Dictionary) -> float:
	var cat := catalogue(gd)
	var c: Dictionary = cat.file.get("opinion", {})
	var ta: Dictionary = a.get("npc_traits", {})
	var tb: Dictionary = b.get("npc_traits", {})
	var pa: Array = ta.get("personality", [])
	var pb: Array = tb.get("personality", [])
	var n_sh: int = pa.filter(func(x): return pb.has(x)).size()
	if str(ta.get("calling", "")) != "" and str(ta.get("calling", "")) == str(tb.get("calling", "")):
		n_sh += 1
	var n_op: int = 0
	for x in pa:
		for y in pb:
			if _personality_opposed(cat, str(x), str(y)):
				n_op += 1
	var ga: Array = Array(ta.get("gained", [])).map(func(e): return str(e.get("id", "")))
	var gb: Array = Array(tb.get("gained", [])).map(func(e): return str(e.get("id", "")))
	for x in ga:
		for y in gb:
			if str(cat.by_id.get(x, {}).get("opposed", "")) == y:
				n_op += 1
	var op: float = float(c.get("s", 10)) * n_sh - float(c.get("o", 10)) * n_op
	op += opinion_lk(gd, a, b)
	var sa: Dictionary = db.get_record("sects", str(a.get("sect_id", ""))) if db != null else {}
	var sb: Dictionary = db.get_record("sects", str(b.get("sect_id", ""))) if db != null else {}
	var al_a: String = str(sa.get("alignment", ""))
	var al_b: String = str(sb.get("alignment", ""))
	var opposite: bool = (al_a == "chinh" and al_b == "ma") or (al_a == "ma" and al_b == "chinh")
	var rival: bool = not sa.is_empty() and not sb.is_empty() and ["feud", "war"].has(str(sa.get("relation", {}).get(str(sb.id), "")))
	for id in held(b):
		var rg: Dictionary = cat.by_id.get(str(id), {}).get("regard", {})
		op += float(rg.get("bias_all", 0.0))
		if rg.has("bias_dir") and str(rg.get("toward", "")).contains("righteous") and al_a == "chinh":
			op += float(rg.bias_dir)
	for id in held(a):
		var rg: Dictionary = cat.by_id.get(str(id), {}).get("regard", {})
		if not rg.has("bias_dir"):
			continue
		var tw: String = str(rg.get("toward", ""))
		if (tw.contains("rival") and rival) or (tw.contains("opposite") and opposite):
			op += float(rg.bias_dir)
	var tie: Dictionary = c.get("tie", {})
	var target: float = 0.0
	for e in ta.get("gained", []):
		if str(e.get("target", "")) != "" and str(e.target) == str(b.get("id", "?")):
			target += float(cat.by_id.get(str(e.id), {}).get("regard", {}).get("target", 0.0))
	if db != null and Ties.enabled(gd) and str(a.get("id", "")) != "" and str(b.get("id", "")) != "":
		var season: int = Ties.now(db)
		var tv: float = Ties.tie_value(gd, db, str(a.id), str(b.id), season)
		var en: float = Ties.enmity_value(gd, db, str(a.id), str(b.id), season)
		if target < 0.0:
			op += tv - en + minf(target, en)
		else:
			op += tv + target
		target = 0.0
	elif str(a.get("master_id", "")) == str(b.get("id", "?")) or str(b.get("master_id", "")) == str(a.get("id", "?")):
		op += float(tie.get("master", 30))
	if not sb.is_empty() and str(sb.get("leader_id", "")) == str(b.get("id", "?")) and str(a.get("sect_id", "")) == str(sb.id):
		op += float(tie.get("own_head", 15))
	if not sa.is_empty() and str(sa.id) == str(sb.get("id", "?")):
		op += float(c.get("sect_same", 10))
	elif not sa.is_empty() and not sb.is_empty() and not bool(a.get("is_player", false)) and not bool(b.get("is_player", false)):
		op += float(c.get("sect_k", 0.2)) * float(sa.get("attitude", {}).get(str(sb.id), 0.0))
	op += target
	return clampf(op, -100.0, 100.0)


## F3: the first meeting of [param npc] with the player sets its attitude to att0, once ("met_player"). A record that
## already carries an attitude or a past talk (an older save, an event before any talk) counts as met and keeps it.
static func first_meeting(gd: GameData, db: WorldDB, npc: Dictionary, player: Dictionary, standing: float, hostile_threshold: int) -> void:
	if bool(npc.get("met_player", false)) or not gd.registry.has_file(FILE):
		return
	npc["met_player"] = true
	if int(npc.get("attitude", 0)) != 0 or int(npc.get("last_talk_season", -1)) >= 0:
		return
	npc["attitude"] = att0(gd, db, npc, player, standing, hostile_threshold)


## F3's att0: an NPC's starting attitude to the player at their first meeting, from the NPC's opinion of the player and
## the player's standing with the NPC's sect; clamped to [hostile_threshold + 1, att0_max].
static func att0(gd: GameData, db: WorldDB, npc: Dictionary, player: Dictionary, standing: float, hostile_threshold: int) -> int:
	var c: Dictionary = gd.file(FILE).get("opinion", {})
	var v: float = roundf(opinion(gd, db, npc, player) + float(c.get("k_st", 0.25)) * standing)
	return clampi(int(v), hostile_threshold + 1, int(c.get("att0_max", 30)))


## Rules 11-13 and F6: grants (or refreshes) gained trait [param id] to [param person] in season [param now], expiring
## fade_seasons later. Returns "granted", "refreshed", "replaced" or "refused".
static func grant(gd: GameData, person: Dictionary, id: String, now: int, target: String = "") -> String:
	var cat := catalogue(gd)
	var t: Dictionary = cat.by_id.get(id, {})
	if t.is_empty() or str(cat.kind.get(id, "")) != "gained":
		return "refused"
	var fade_s: int = int(cat.file.get("fade_seasons", 40))
	var nt: Dictionary = _ensure_record(person)
	var g: Array = nt.get("gained", [])
	var rank := func(x: String) -> int: return 1 if str(cat.by_id.get(x, {}).get("grade", "small")) == "notable" else 0
	for e in g:
		if str(e.id) == id:
			e["expires"] = now + fade_s
			return "refreshed"
	for i in g.size():
		var e: Dictionary = g[i]
		if str(e.id) == str(t.get("opposed", "")) or str(cat.by_id.get(str(e.id), {}).get("opposed", "")) == id:
			if int(rank.call(id)) >= int(rank.call(str(e.id))):
				g[i] = {"id": id, "expires": now + fade_s, "target": target}
				nt["gained"] = g
				return "replaced"
			return "refused"
	if g.size() < 2:
		g.append({"id": id, "expires": now + fade_s, "target": target})
		nt["gained"] = g
		return "granted"
	var oldest: int = -1
	for i in g.size():
		if int(rank.call(str(g[i].id))) <= int(rank.call(id)) and (oldest < 0 or int(g[i].expires) < int(g[oldest].expires)):
			oldest = i
	if oldest < 0:
		return "refused"
	g[oldest] = {"id": id, "expires": now + fade_s, "target": target}
	nt["gained"] = g
	return "replaced"


## Rule 2a, 11a & F6b: grants or refreshes a v2 event-grantable trait (path, lifestyle, health, coping) to
## [param person] at season [param now]. Upbringing and talent are refused for events.
## Returns "granted", "refreshed", "replaced" or "refused".
static func grant_v2(gd: GameData, person: Dictionary, id: String, now: int = 0) -> String:
	var cat := catalogue(gd)
	var k: String = str(cat.kind.get(id, ""))
	if k == "" or not (k in ["path", "lifestyle", "health", "coping"]):
		return "refused"
	var nt: Dictionary = _ensure_record(person)
	match k:
		"path":
			var paths: Array = _norm_str_array(nt.get("path", []))
			if paths.has(id):
				nt["path"] = paths
				return "refreshed"
			for i in paths.size():
				if _is_opposed(cat, id, str(paths[i])):
					paths[i] = id
					nt["path"] = paths
					return "replaced"
			if paths.size() < 2:
				paths.append(id)
				nt["path"] = paths
				return "granted"
			return "refused"
		"lifestyle":
			var cur: String = str(nt.get("lifestyle", ""))
			if cur == id:
				return "refreshed"
			nt["lifestyle"] = id
			return "granted" if cur == "" else "replaced"
		"health":
			var hs: Array = _norm_str_array(nt.get("health", []))
			if hs.has(id):
				nt["health"] = hs
				return "refreshed"
			if hs.size() < 2:
				hs.append(id)
				nt["health"] = hs
				return "granted"
			if id == "waning_years":
				hs.remove_at(0)
				hs.append(id)
				nt["health"] = hs
				return "replaced"
			return "refused"
		"coping":
			var rv2: Dictionary = cat.file.get("roll_v2", {})
			var fade_c: int = int(rv2.get("coping_fade_seasons", 20))
			var harden_n: int = int(rv2.get("coping_harden_refreshes", 3))
			var cur: Dictionary = _norm_coping(nt.get("coping", {}), cat, now, fade_c)
			if cur.is_empty():
				nt["coping"] = {"id": id, "expires": now + fade_c, "refreshes": 0, "hardened": false}
				return "granted"
			if str(cur.id) == id:
				if bool(cur.get("hardened", false)):
					nt["coping"] = cur
					return "refreshed"
				var refs: int = int(cur.get("refreshes", 0)) + 1
				cur["refreshes"] = refs
				if refs >= harden_n:
					cur["hardened"] = true
					cur.erase("expires")
				else:
					cur["expires"] = now + fade_c
				nt["coping"] = cur
				return "refreshed"
			if bool(cur.get("hardened", false)):
				return "refused"
			nt["coping"] = {"id": id, "expires": now + fade_c, "refreshes": 0, "hardened": false}
			return "replaced"
	return "refused"


## Creation-time / Self-made helper enforcing Rule 2a talent caps (2 rolled/tier B-C, hard max 3 for tier A) and
## opposition rules (no gift+flaw pair, no family opposed to a held kept fate). Returns "granted" or "refused".
static func add_talent(gd: GameData, person: Dictionary, id: String, tier: int, max_talents: int = 2) -> String:
	var cat := catalogue(gd)
	if str(cat.kind.get(id, "")) != "talent" or tier < 1 or tier > 3:
		return "refused"
	var cap: int = clampi(max_talents, 1, 3)
	var nt: Dictionary = _ensure_record(person)
	var talents: Array = Array(nt.get("talent", []))
	if talents.size() >= cap:
		return "refused"
	for ex in talents:
		var eid: String = str(ex.get("id", "")) if ex is Dictionary else str(ex)
		if eid == id or _is_opposed(cat, id, eid):
			return "refused"
	for hf in nt.get("fate", []):
		if _is_opposed(cat, id, str(hf)):
			return "refused"
	talents.append({"id": id, "tier": tier})
	nt["talent"] = talents
	return "granted"


## Rule 2a & 11a: removes a deed-removable v2 trait (path, lifestyle, health, coping — including hardened coping).
## Upbringing and talent cannot be removed. Returns true when removed.
static func remove_v2(gd: GameData, person: Dictionary, id: String) -> bool:
	if not person.has("npc_traits") or not (person.npc_traits is Dictionary):
		return false
	var cat := catalogue(gd)
	var k: String = str(cat.kind.get(id, ""))
	if not (k in ["path", "lifestyle", "health", "coping"]):
		return false
	var nt: Dictionary = person.npc_traits
	match k:
		"path":
			var paths: Array = _norm_str_array(nt.get("path", []))
			if not paths.has(id):
				return false
			paths.erase(id)
			nt["path"] = paths
			return true
		"lifestyle":
			if str(nt.get("lifestyle", "")) != id:
				return false
			nt["lifestyle"] = ""
			return true
		"health":
			var hs: Array = _norm_str_array(nt.get("health", []))
			if not hs.has(id):
				return false
			hs.erase(id)
			nt["health"] = hs
			return true
		"coping":
			var cop: Variant = nt.get("coping", {})
			if cop is Dictionary and str((cop as Dictionary).get("id", "")) == id:
				nt["coping"] = {}
				return true
			if cop is String and str(cop) == id:
				nt["coping"] = {}
				return true
			return false
	return false


## The cast's authored gained traits (world-depth; names from the catalogue), granted at season [param now] as rule 12
## grants any gained trait, so they fade like the rest. Unknown names are skipped.
static func grant_authored(gd: GameData, person: Dictionary, names: Array, now: int) -> void:
	var cat := catalogue(gd)
	for n in names:
		var id: String = str(cat.by_name.get(str(n).to_lower(), ""))
		if id != "":
			grant(gd, person, id, now)


## Rule 12 & F6b: removes gained traits and unhardened coping traits of [param person] whose expiry <= [param now].
static func fade(person: Dictionary, now: int) -> void:
	if not person.has("npc_traits") or not (person.npc_traits is Dictionary):
		return
	var nt: Dictionary = person.npc_traits
	if nt.has("gained"):
		var g: Array = nt.get("gained", [])
		nt["gained"] = g.filter(func(e): return int(e.get("expires", 0)) > now)
	var cop: Variant = nt.get("coping", {})
	if cop is Dictionary and not (cop as Dictionary).is_empty():
		var cd: Dictionary = cop
		if not bool(cd.get("hardened", false)) and cd.has("expires") and int(cd.expires) <= now:
			nt["coping"] = {}


## F6b: grants or removes Waning years on [param person] as remaining lifespan crosses waning_share * lifespan.
## Fast-paths without allocations when already in the target state. Returns true if changed.
static func update_waning(gd: GameData, person: Dictionary, age: float, lifespan: float) -> bool:
	if lifespan <= 0.0:
		return false
	var w_s: float = float(catalogue(gd).file.get("roll_v2", {}).get("waning_share", 0.10))
	var should_have: bool = (lifespan - age) <= w_s * lifespan + 1e-6
	var nt: Dictionary = person.get("npc_traits", {})
	var raw_h: Variant = nt.get("health", [])
	var has_waning: bool = false
	if raw_h is Array:
		has_waning = (raw_h as Array).has("waning_years")
	elif raw_h is String:
		has_waning = str(raw_h) == "waning_years"
	if should_have == has_waning:
		return false
	if should_have:
		var res: String = grant_v2(gd, person, "waning_years")
		return res == "granted" or res == "replaced"
	return remove_v2(gd, person, "waning_years")


## Every v2 trait id a person holds (upbringing, talent family ids, path, lifestyle, health, coping id).
static func held_v2(person: Dictionary) -> Array:
	var t: Dictionary = person.get("npc_traits", {})
	if t.is_empty():
		return []
	var out: Array = []
	var up: String = str(t.get("upbringing", ""))
	if up != "":
		out.append(up)
	for entry in t.get("talent", []):
		var tid: String = str(entry.get("id", "")) if entry is Dictionary else str(entry)
		if tid != "":
			out.append(tid)
	for pid in _norm_str_array(t.get("path", [])):
		out.append(pid)
	var ls: String = str(t.get("lifestyle", ""))
	if ls != "":
		out.append(ls)
	for hid in _norm_str_array(t.get("health", [])):
		out.append(hid)
	var cop: Variant = t.get("coping", {})
	if cop is Dictionary:
		var cid: String = str((cop as Dictionary).get("id", ""))
		if cid != "":
			out.append(cid)
	elif cop is String and str(cop) != "":
		out.append(str(cop))
	return out


## Every trait id a person holds across all 10 kinds (v1 personality, calling, fate, gained + v2 kinds).
static func held(person: Dictionary) -> Array:
	var t: Dictionary = person.get("npc_traits", {})
	if t.is_empty():
		return []
	var out: Array = Array(t.get("personality", [])).duplicate()
	if str(t.get("calling", "")) != "":
		out.append(str(t.calling))
	out.append_array(t.get("fate", []))
	for g in t.get("gained", []):
		var gid: String = str(g.get("id", "")) if g is Dictionary else str(g)
		if gid != "":
			out.append(gid)
	out.append_array(held_v2(person))
	return out


## All stat modifier rows across all 10 trait kinds for [param person], resolving [code]own_top_element[/code]
## against [param linh_can] (rule 7, AC-NT-54). Returns [{source, stat, value, scope}].
static func stat_rows(gd: GameData, person: Dictionary, linh_can: Variant = null) -> Array:
	var nt: Dictionary = person.get("npc_traits", {})
	if nt.is_empty() or not gd.registry.has_file(FILE):
		return []
	var cat := catalogue(gd)
	var out: Array = []
	# Non-talent traits across v1 and v2
	var plain_ids: Array = Array(nt.get("personality", [])).duplicate()
	if str(nt.get("calling", "")) != "":
		plain_ids.append(str(nt.calling))
	plain_ids.append_array(nt.get("fate", []))
	for g in nt.get("gained", []):
		var gid: String = str(g.get("id", "")) if g is Dictionary else str(g)
		if gid != "":
			plain_ids.append(gid)
	if str(nt.get("upbringing", "")) != "":
		plain_ids.append(str(nt.upbringing))
	plain_ids.append_array(_norm_str_array(nt.get("path", [])))
	if str(nt.get("lifestyle", "")) != "":
		plain_ids.append(str(nt.lifestyle))
	plain_ids.append_array(_norm_str_array(nt.get("health", [])))
	var cop: Variant = nt.get("coping", {})
	if cop is Dictionary and str((cop as Dictionary).get("id", "")) != "":
		plain_ids.append(str((cop as Dictionary).id))
	elif cop is String and str(cop) != "":
		plain_ids.append(str(cop))
	for id in plain_ids:
		var sid: String = str(id)
		var t: Dictionary = cat.by_id.get(sid, {})
		if t.is_empty():
			continue
		var k: String = str(cat.kind.get(sid, ""))
		var src: String = "%s: %s" % [str(KIND_LABELS.get(k, "Đặc tính")), str(t.get("name_vi", t.get("name", sid)))]
		var rows: Array = Array(t.get("boon", [])) + Array(t.get("cost", [])) + Array(t.get("rows", []))
		for row in rows:
			_append_resolved_row(out, src, row, linh_can)
	# Talent families: flat talent add + tier rows (F1b)
	for entry in nt.get("talent", []):
		if not (entry is Dictionary):
			continue
		var tid: String = str(entry.get("id", ""))
		var fam: Dictionary = cat.by_id.get(tid, {})
		if fam.is_empty():
			continue
		var tiers: Array = Array(fam.get("tiers", []))
		if tiers.is_empty():
			continue
		var tier: int = clampi(int(entry.get("tier", 1)), 1, tiers.size())
		var idx: int = tier - 1
		var names_vi: Array = Array(fam.get("tier_names_vi", []))
		var tname: String = str(names_vi[idx]) if idx < names_vi.size() else str(fam.get("name_vi", fam.get("name", tid)))
		var src: String = "%s: %s" % [str(KIND_LABELS.talent), tname]
		var td: Dictionary = tiers[idx]
		var t_adds: Dictionary = td.get("talent", {})
		for stat_k in t_adds:
			out.append({"source": src, "stat": str(stat_k), "value": float(t_adds[stat_k]), "scope": []})
		for row in td.get("rows", []):
			_append_resolved_row(out, src, row, linh_can)
	return out


static func _append_resolved_row(out: Array, src: String, row: Dictionary, linh_can: Variant) -> void:
	var raw_scope: Array = Array(row.get("scope", []))
	var scope: Array = []
	for s in raw_scope:
		var ss: String = str(s)
		if ss == "own_top_element":
			var top_el: String = own_top_element(linh_can)
			if top_el == "":
				return   # pure Wind or missing root: omit row (rule 7, AC-NT-54)
			scope.append(top_el)
		else:
			scope.append(ss)
	out.append({"source": src, "stat": str(row.stat), "value": float(row.value), "scope": scope})


## Talent-tier sources affecting [param talent_id] (e.g. "ngo_tinh") for [param person], for Breakdown and grade
## display (F1b, AC-NT-39). Returns [{id, tier, name, name_vi, value}].
static func talent_tier_sources(gd: GameData, person: Dictionary, talent_id: String) -> Array:
	var nt: Dictionary = person.get("npc_traits", {})
	if nt.is_empty() or not gd.registry.has_file(FILE):
		return []
	var cat := catalogue(gd)
	var out: Array = []
	for entry in nt.get("talent", []):
		if not (entry is Dictionary):
			continue
		var tid: String = str(entry.get("id", ""))
		var fam: Dictionary = cat.by_id.get(tid, {})
		if fam.is_empty() or str(fam.get("stat", "")) != talent_id:
			continue
		var tiers: Array = Array(fam.get("tiers", []))
		if tiers.is_empty():
			continue
		var tier: int = clampi(int(entry.get("tier", 1)), 1, tiers.size())
		var idx: int = tier - 1
		var names: Array = Array(fam.get("tier_names", []))
		var names_vi: Array = Array(fam.get("tier_names_vi", []))
		var val: float = float(Dictionary(tiers[idx].get("talent", {})).get(talent_id, 0.0))
		out.append({
			"id": tid,
			"tier": tier,
			"name": str(names[idx]) if idx < names.size() else tid,
			"name_vi": str(names_vi[idx]) if idx < names_vi.size() else tid,
			"value": val,
		})
	return out


## Rule 8a: union of all [code]opens[/code] hook ids from every trait [param person] holds (computed, never stored).
static func opened_hooks(gd: GameData, person: Dictionary) -> Array:
	var cat := catalogue(gd)
	var seen := {}
	var out: Array = []
	for id in held(person):
		var t: Dictionary = cat.by_id.get(str(id), {})
		for h in t.get("opens", []):
			var hs: String = str(h)
			if hs != "" and not seen.has(hs):
				seen[hs] = true
				out.append(hs)
	return out


## Rule 8a & AC-NT-47: dialogue verb ids available when [param player] speaks with [param npc], filtered to
## [param verb_defs] (consumer records [{id, side}]; defaults to catalogue verb_hooks when omitted / null).
## Hooks with no entry in [param verb_defs] add nothing.
static func available_verbs(gd: GameData, player: Dictionary, npc: Dictionary, verb_defs: Variant = null) -> Array:
	var cat := catalogue(gd)
	var defs: Array = Array(cat.verb_hooks) if verb_defs == null else Array(verb_defs)
	if defs.is_empty():
		return []
	var p_hooks := {}
	for h in opened_hooks(gd, player):
		p_hooks[str(h)] = true
	var n_hooks := {}
	for h in opened_hooks(gd, npc):
		n_hooks[str(h)] = true
	var out: Array = []
	for vd in defs:
		if not (vd is Dictionary):
			continue
		var vid: String = str(vd.get("id", ""))
		if vid == "":
			continue
		var hook: String = vid if vid.begins_with("verb:") else ("verb:" + vid)
		var side: String = str(vd.get("side", ""))
		if side == "":
			side = str(cat.verb_side.get(vid, "self"))
		var ok: bool = false
		match side:
			"self":
				ok = p_hooks.has(hook)
			"other":
				ok = n_hooks.has(hook)
			"either":
				ok = p_hooks.has(hook) or n_hooks.has(hook)
		if ok and not out.has(vid):
			out.append(vid)
	return out


## Validates a traits catalogue dictionary against Rules 5, 7a, 8a, AC-NT-38 and AC-NT-48. Returns an array of error
## strings (empty when valid). Uses [param gd]'s loaded traits file when [param raw] is null.
static func validate_catalogue(gd: GameData, raw: Variant = null) -> Array:
	var f: Dictionary = gd.file(FILE) if raw == null else (raw as Dictionary)
	var errors: Array = []
	var labels: Dictionary = gd.file("character_stat_labels").get("labels", {})
	var cm: Dictionary = gd.file("combat_engine").get("CHARACTER_MODS", {})
	var valid_stats := {}
	for k in labels:
		valid_stats[str(k)] = true
	for k in cm.get("passive", {}):
		valid_stats[str(k)] = true
	for k in cm.get("static", []):
		valid_stats[str(k)] = true
	for k in cm.get("out_of_fight", []):
		valid_stats[str(k)] = true
	var by_name := {}
	for k in ALL_KINDS:
		for t in f.get(k, []):
			var tid: String = str(t.get("id", ""))
			by_name[tid.to_lower()] = tid
			var nm: String = str(t.get("name", "")).to_lower()
			if nm != "":
				by_name[nm] = tid
	var tier_adds: Array = Array(f.get("roll_v2", {}).get("talent_tier_add", [6, 12, 20]))
	for k in KINDS_V2:
		for t in f.get(k, []):
			var tid: String = str(t.get("id", "?"))
			var all_rows: Array = []
			if k == "talent":
				var tiers: Array = Array(t.get("tiers", []))
				var dir: int = int(t.get("direction", 1))
				var tstat: String = str(t.get("stat", ""))
				if tiers.size() != 3:
					errors.append("%s: talent family must have 3 tiers (got %d)" % [tid, tiers.size()])
				for i in tiers.size():
					var td: Dictionary = tiers[i]
					var tmap: Dictionary = td.get("talent", {})
					var want: float = float(dir * int(tier_adds[i])) if i < tier_adds.size() else 0.0
					if not tmap.has(tstat) or not is_equal_approx(float(tmap[tstat]), want):
						errors.append("%s tier %d: expected %s %g" % [tid, i + 1, tstat, want])
					all_rows.append_array(Array(td.get("rows", [])))
			else:
				all_rows = Array(t.get("rows", []))
			for r in all_rows:
				if not (r is Dictionary):
					errors.append("%s: non-dict row" % tid)
					continue
				for rk in r:
					if not (str(rk) in ["stat", "value", "scope"]):
						errors.append("%s: rule 7a illegal row field %s" % [tid, str(rk)])
				var st: String = str(r.get("stat", ""))
				if st.ends_with("_more") or st == "damage_more":
					errors.append("%s: rule 5 more row %s forbidden" % [tid, st])
				elif not valid_stats.has(st):
					errors.append("%s: unknown or Pending stat key %s" % [tid, st])
				for sc in r.get("scope", []):
					var scs: String = str(sc).to_lower()
					if _ENV_SCOPES.has(scs):
						errors.append("%s: rule 7a environment scope %s forbidden" % [tid, str(sc)])
			for h in t.get("opens", []):
				var hs: String = str(h)
				var ok_h: bool = false
				for pref in _HOOK_PREFIXES:
					if hs.begins_with(pref):
						ok_h = true
						break
				if not ok_h:
					errors.append("%s: invalid hook prefix %s" % [tid, hs])
			for lk in Array(t.get("likes", [])) + Array(t.get("dislikes", [])):
				if not by_name.has(str(lk).strip_edges().to_lower()):
					errors.append("%s: unknown like/dislike target %s" % [tid, str(lk)])
	return errors


## Sects F15: a person's summed pulls across all held traits plus any opened [code]policy:*[/code] hooks (rule 8a).
static func pulls(gd: GameData, person: Dictionary) -> Dictionary:
	var cat := catalogue(gd)
	var out := {"dials": {}, "dial_when_thriving": {}, "war_odds": INF, "rebel_odds": INF, "weariness": 0.0, "weariness_truce": 0.0,
		"half_loss_weariness": false, "loyalty": 0.0,
		"pact_line": INF, "alignment_factor": 1.0, "attitude_speed": {"hostile": 1.0, "friendly": 1.0}, "bias_from_all": 0.0,
		"bold": false, "never_bold": false, "needs_halved": false, "fickle": false, "first_track": "", "abs_sum": 0.0,
		"bias_dir": {"rivals": 0.0, "opposite": 0.0, "from_righteous": 0.0}}
	for id in held(person):
		var t: Dictionary = cat.by_id.get(str(id), {})
		if t.is_empty():
			continue
		var rg: Dictionary = t.get("regard", {})
		if rg.has("bias_dir"):
			var tw: String = str(rg.get("toward", ""))
			var slot: String = "rivals" if tw.contains("rival") else ("opposite" if tw.contains("opposite") else ("from_righteous" if tw.contains("righteous") else ""))
			if slot != "":
				out.bias_dir[slot] = float(out.bias_dir[slot]) + float(rg.bias_dir)
		_apply_pull(out, t.get("pulls", {}))
	for hook in opened_hooks(gd, person):
		if cat.policy_hooks.has(hook):
			_apply_pull(out, cat.policy_hooks[hook])
	if float(out.war_odds) == INF:
		out.erase("war_odds")
	if float(out.rebel_odds) == INF:
		out.erase("rebel_odds")
	return out


static func _apply_pull(out: Dictionary, p: Dictionary) -> void:
	if p.is_empty():
		return
	for d in p.get("dials", {}):
		out.dials[d] = float(out.dials.get(d, 0.0)) + float(p.dials[d])
		out.abs_sum = float(out.abs_sum) + absf(float(p.dials[d]))
	for d in p.get("dial_when_thriving", {}):
		out.dial_when_thriving[d] = float(out.dial_when_thriving.get(d, 0.0)) + float(p.dial_when_thriving[d])
	if p.has("war_odds"):
		out.war_odds = minf(float(out.war_odds), float(p.war_odds))
	if p.has("rebel_odds"):
		out.rebel_odds = minf(float(out.rebel_odds), float(p.rebel_odds))
	if bool(p.get("weariness_for_truce", false)):
		out.weariness_truce = float(out.weariness_truce) + float(p.get("weariness", 0.0))
	else:
		out.weariness = float(out.weariness) + float(p.get("weariness", 0.0))
	if bool(p.get("half_loss_weariness", false)):
		out.half_loss_weariness = true
	out.loyalty = float(out.loyalty) + float(p.get("loyalty", 0.0))
	if p.has("pact_line") and str(p.get("pact_line_scope", "")) == "":
		out.pact_line = minf(float(out.pact_line), float(p.pact_line))
	out.alignment_factor = float(out.alignment_factor) * float(p.get("alignment_factor", 1.0))
	if p.has("attitude_speed"):
		out.attitude_speed[str(p.get("attitude_speed_when", "hostile"))] = float(p.attitude_speed)
	out.bias_from_all = float(out.bias_from_all) + float(p.get("attitude_bias_from_all", 0.0))
	for k in ["bold", "never_bold", "needs_halved", "fickle"]:
		if bool(p.get(k, false)):
			out[k] = true
	if p.has("invest_share"):
		out["invest_share"] = float(p.invest_share)
	if p.has("draw_mult"):
		out["draw_mult"] = float(p.draw_mult)
	if str(p.get("first_track", "")) != "" and str(out.first_track) == "":
		out.first_track = str(p.first_track)


## A sect's leader's pulls ({} pulls of nobody when it has no living leader).
static func leader_pulls(gd: GameData, db: WorldDB, sect: Dictionary) -> Dictionary:
	var lead: Dictionary = db.get_record("people", str(sect.get("leader_id", "")))
	if lead.is_empty() or not bool(lead.get("alive", false)):
		return pulls(gd, {})
	return pulls(gd, lead)
