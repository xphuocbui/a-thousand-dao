class_name SectAdmission
extends RefCounted
## Sect root admission (F20, rules 20c-20d) and seasonal intake fill (F21) for Sects & Missions
## (design/gdd/sects.md). All thresholds and score weights are read from sects_members.json under "admission".
##
## Ownership rule: purity p_x counts only elements and variants owned by the LinhCan (`lc.has(x)`). Road purity
## on an unowned element never passes an admission test or scores in intake fill.
##
## Usage:
## [codeblock]
## if not SectAdmission.admits_outer(gd, sect, character.linh_can):
##     var why: String = SectAdmission.refusal_reason(gd, sect, character.linh_can, "ngoai_mon")
## var res: Dictionary = SectAdmission.fill_claims(gd, sects, claims, pool, home_fn, kin_fn)
## [/codeblock]

const EXEMPT_RANKS: Array[String] = ["khach_khanh", "tap_dich"]
const CORE_RANKS: Array[String] = ["noi_mon", "chan_truyen", "chap_su", "truong_lao", "thai_thuong"]


## Returns the "admission" config dictionary from sects_members.json.
static func cfg(gd: GameData) -> Dictionary:
	return gd.file("sects_members").get("admission", {})


## Returns the canonical element and variant IDs of [param sect]'s lineage, in lineage order.
## Reads `lineage_elements` first (even when empty), then `lineage.elements`, then `leans` (normalizing English
## names via world_generation.json's continent.element_names), else `[]`.
static func elements_of(gd: GameData, sect: Dictionary) -> Array:
	var raw_list: Array = []
	if sect.has("lineage_elements"):
		raw_list = Array(sect["lineage_elements"])
	elif sect.get("lineage") is Dictionary and Dictionary(sect["lineage"]).has("elements"):
		raw_list = Array(Dictionary(sect["lineage"])["elements"])
	elif sect.has("leans"):
		raw_list = Array(sect["leans"])
	else:
		return []
	var names: Dictionary = gd.world_gen().get("continent", {}).get("element_names", {})
	var out: Array = []
	for item in raw_list:
		var id: String = _normalize_id(gd, str(item), names)
		if id != "" and not out.has(id):
			out.append(id)
	return out


## Returns true when [param sect] has no lineage elements (rule 20d: admits any root).
static func is_no_lean(gd: GameData, sect: Dictionary) -> bool:
	return elements_of(gd, sect).is_empty()


## Returns the base element IDs of [param sect]'s lineage, preserving lineage order.
static func base_elements_of(gd: GameData, sect: Dictionary) -> Array:
	var out: Array = []
	for id in elements_of(gd, sect):
		var s: String = str(id)
		if not gd.element(s).is_empty():
			out.append(s)
	return out


## Returns the variant IDs of [param sect]'s lineage, preserving lineage order.
static func variants_of(gd: GameData, sect: Dictionary) -> Array:
	var out: Array = []
	for id in elements_of(gd, sect):
		var s: String = str(id)
		if not gd.variant(s).is_empty():
			out.append(s)
	return out


## Owned purity of element or variant [param id] on [param lc]; 0.0 when unowned (road purity alone never counts).
static func owned_purity(lc: LinhCan, id: String) -> float:
	if lc == null or id == "" or not lc.has(id):
		return 0.0
	return lc.purity(id)


## F20 outer-disciple admission test: passes for a no-lean sect, or if any lineage base element has owned purity
## >= admit_min, or if any lineage variant is owned with purity > 0.
static func admits_outer(gd: GameData, sect: Dictionary, lc: LinhCan) -> bool:
	var elems: Array = elements_of(gd, sect)
	if elems.is_empty():
		return true
	if lc == null:
		return false
	var min_p: float = float(cfg(gd).get("admit_min", 30))
	for id in elems:
		var s: String = str(id)
		if not gd.element(s).is_empty():
			if owned_purity(lc, s) >= min_p:
				return true
		elif not gd.variant(s).is_empty():
			if lc.has(s) and lc.purity(s) > 0.0:
				return true
	return false


## F20 core-rank admission test (`core_ok(t, var_min)`): passes for a no-lean sect; for a base lineage requires
## `b1 >= t`; for a convergence-variant lineage requires `b1 >= t` or `v1 >= var_min`; for other variant lineages
## requires `v1 >= var_min`. Defaults `t` to `admit_core` when [param base_min] < 0.
static func admits_core(gd: GameData, sect: Dictionary, lc: LinhCan, base_min: float = -1.0, var_min: float = 1.0) -> bool:
	var elems: Array = elements_of(gd, sect)
	if elems.is_empty():
		return true
	if lc == null:
		return false
	var c: Dictionary = cfg(gd)
	var t: float = float(c.get("admit_core", 45)) if base_min < 0.0 else base_min
	var bases: Array = base_elements_of(gd, sect)
	var vars: Array = variants_of(gd, sect)
	var b1: String = str(bases[0]) if not bases.is_empty() else ""
	if vars.is_empty():
		return b1 != "" and owned_purity(lc, b1) >= t
	var v1: String = str(vars[0])
	var has_v1: bool = lc.has(v1) and lc.purity(v1) >= var_min
	var conv: Array = Array(c.get("convergence_variants", []))
	if conv.has(v1):
		return (b1 != "" and owned_purity(lc, b1) >= t) or has_v1
	return has_v1


## F20 sect-head admission test: `core_ok(head_min, head_min)`.
static func admits_head(gd: GameData, sect: Dictionary, lc: LinhCan) -> bool:
	var h: float = float(cfg(gd).get("head_min", 50))
	return admits_core(gd, sect, lc, h, h)


## F20 / rule 20c admission test dispatched by [param rank]. Any non-empty [param exception], guest elder
## (`khach_khanh`), or servant (`tap_dich`) skips the root test.
static func admits_for_rank(gd: GameData, sect: Dictionary, lc: LinhCan, rank: String, exception: String = "") -> bool:
	if exception != "" or EXEMPT_RANKS.has(rank):
		return true
	if rank == "ngoai_mon":
		return admits_outer(gd, sect, lc)
	if rank == "tong_chu":
		return admits_head(gd, sect, lc)
	if CORE_RANKS.has(rank):
		return admits_core(gd, sect, lc)
	return admits_core(gd, sect, lc)


## Returns `""` if [param lc] passes admission to [param sect] at [param rank], otherwise a player-facing refusal
## reason such as `"root: needs Water 30 or Ice"` (AC-SM-67).
static func refusal_reason(gd: GameData, sect: Dictionary, lc: LinhCan, rank: String = "ngoai_mon") -> String:
	if admits_for_rank(gd, sect, lc, rank):
		return ""
	var c: Dictionary = cfg(gd)
	var bases: Array = base_elements_of(gd, sect)
	var vars: Array = variants_of(gd, sect)
	if rank == "ngoai_mon":
		var min_p: int = int(c.get("admit_min", 30))
		var parts: PackedStringArray = []
		for b in bases:
			parts.append("%s %d" % [_english_name(gd, str(b)), min_p])
		for v in vars:
			parts.append(_english_name(gd, str(v)))
		return "root: needs %s" % " or ".join(parts)
	var b1: String = str(bases[0]) if not bases.is_empty() else ""
	var is_head: bool = rank == "tong_chu"
	var req_p: int = int(c.get("head_min", 50)) if is_head else int(c.get("admit_core", 45))
	if vars.is_empty():
		return "root: needs %s %d" % [_english_name(gd, b1), req_p]
	var v1: String = str(vars[0])
	var v_text: String = "%s %d" % [_english_name(gd, v1), req_p] if is_head else _english_name(gd, v1)
	var conv: Array = Array(c.get("convergence_variants", []))
	if conv.has(v1) and b1 != "":
		return "root: needs %s %d or %s" % [_english_name(gd, b1), req_p, v_text]
	return "root: needs %s" % v_text


## Returns the thiên phú talent key a no-lean sect recruits by (`recruit_by.talent`), or `""` if unset.
static func recruit_talent(sect: Dictionary) -> String:
	var rb: Variant = sect.get("recruit_by", {})
	return str(rb.get("talent", "")) if rb is Dictionary else ""


## Returns true if [param sect] prefers members' kin (`recruit_by.kin`).
static func recruit_kin(sect: Dictionary) -> bool:
	var rb: Variant = sect.get("recruit_by", {})
	return bool(rb.get("kin", false)) if rb is Dictionary else false


## F21 candidate quality term `q`: for a no-lean sect, the candidate's `recruit_by.talent` value; for a lean sect,
## `variant_bonus + max(owned variant purity)` if any lineage variant is owned, else `max(owned base purity)`.
static func candidate_q(gd: GameData, sect: Dictionary, lc: LinhCan, thien_phu: Dictionary) -> float:
	if is_no_lean(gd, sect):
		var talent: String = recruit_talent(sect)
		return float(thien_phu.get(talent, 0.0)) if talent != "" else 0.0
	if lc == null:
		return 0.0
	var has_v: bool = false
	var best_v: float = 0.0
	for v in variants_of(gd, sect):
		var vid: String = str(v)
		if lc.has(vid):
			var p: float = lc.purity(vid)
			if not has_v or p > best_v:
				best_v = p
				has_v = true
	if has_v:
		return float(cfg(gd).get("variant_bonus", 100)) + best_v
	var best_b: float = 0.0
	for b in base_elements_of(gd, sect):
		var bid: String = str(b)
		if lc.has(bid):
			best_b = maxf(best_b, lc.purity(bid))
	return best_b


## F21 candidate intake score: `kin_bonus * kin + home_bonus * home + q`, where `kin` applies only if [param sect]
## recruits by kin.
static func candidate_score(gd: GameData, sect: Dictionary, lc: LinhCan, thien_phu: Dictionary, is_kin: bool, is_home: bool) -> float:
	var c: Dictionary = cfg(gd)
	var total: float = candidate_q(gd, sect, lc, thien_phu)
	if is_kin and recruit_kin(sect):
		total += float(c.get("kin_bonus", 1000))
	if is_home:
		total += float(c.get("home_bonus", 500))
	return total


## F21 seasonal intake fill: iterates [param sects_in_order], admitting up to `claims[sect.id]` remaining pool
## members who pass `admits_outer`, ordered by descending `candidate_score` with ties broken by ascending `str(p.id)`.
## Optional [param home_fn] and [param kin_fn] are called as `(sect, person) -> bool`.
## Returns `{"admitted": {sect_id: [person...]}, "loose": [person...]}` partitioning [param pool].
static func fill_claims(gd: GameData, sects_in_order: Array, claims: Dictionary, pool: Array, home_fn: Callable = Callable(), kin_fn: Callable = Callable()) -> Dictionary:
	var n: int = pool.size()
	var pids: Array[String] = []
	var lcs: Array[LinhCan] = []
	var tps: Array[Dictionary] = []
	pids.resize(n)
	lcs.resize(n)
	tps.resize(n)
	for i in n:
		var p: Variant = pool[i]
		pids[i] = _person_id(p)
		lcs[i] = _person_lc(p)
		tps[i] = _person_tp(p)
	var admitted: Dictionary = {}
	var taken: Dictionary = {}
	for s in sects_in_order:
		var sect: Dictionary = s
		var sid: String = str(sect.get("id", sect.get("key", "")))
		var picked: Array = []
		admitted[sid] = picked
		var want: int = int(claims.get(sid, 0))
		if want <= 0:
			continue
		var cands: Array = []
		for i in n:
			if taken.has(i):
				continue
			if not admits_outer(gd, sect, lcs[i]):
				continue
			var is_home: bool = bool(home_fn.call(sect, pool[i])) if home_fn.is_valid() else false
			var is_kin: bool = bool(kin_fn.call(sect, pool[i])) if kin_fn.is_valid() else false
			var sc: float = candidate_score(gd, sect, lcs[i], tps[i], is_kin, is_home)
			cands.append({"idx": i, "score": sc, "pid": pids[i]})
		cands.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
			var sa: float = float(a.score)
			var sb: float = float(b.score)
			if sa != sb:
				return sa > sb
			return str(a.pid) < str(b.pid))
		var take_n: int = mini(want, cands.size())
		for k in take_n:
			var idx: int = int(cands[k].idx)
			taken[idx] = true
			picked.append(pool[idx])
	var loose: Array = []
	for i in n:
		if not taken.has(i):
			loose.append(pool[i])
	return {"admitted": admitted, "loose": loose}


static func _normalize_id(gd: GameData, raw: String, names: Dictionary) -> String:
	if raw == "":
		return ""
	if names.has(raw):
		return str(names[raw])
	if not gd.element(raw).is_empty() or not gd.variant(raw).is_empty():
		return raw
	var low: String = raw.to_lower()
	if not gd.element(low).is_empty() or not gd.variant(low).is_empty():
		return low
	for k in names.keys():
		if str(k).to_lower() == low:
			return str(names[k])
	if low == "chaos" or low == "primordial chaos":
		return "hon_don"
	for def in gd.variant_defs():
		if str(def.get("name_en", "")).to_lower() == low:
			return str(def.id)
	return raw


static func _english_name(gd: GameData, id: String) -> String:
	if id == "hon_don":
		return "Chaos"
	var e: Dictionary = gd.element(id)
	if not e.is_empty():
		return str(e.get("name_en", e.get("name", id)))
	var v: Dictionary = gd.variant(id)
	if not v.is_empty():
		return str(v.get("name_en", v.get("name", id)))
	return id


static func _person_id(p: Variant) -> String:
	if p is Dictionary:
		return str(p.get("id", ""))
	if p is Object:
		return str(p.get("id"))
	return str(p)


static func _person_lc(p: Variant) -> LinhCan:
	var raw: Variant = null
	if p is Dictionary:
		raw = p.get("linh_can", null)
	elif p is Object:
		raw = p.get("linh_can")
	if raw is LinhCan:
		return raw as LinhCan
	if raw is Dictionary:
		return LinhCan.from_dict(raw)
	return LinhCan.new()


static func _person_tp(p: Variant) -> Dictionary:
	var raw: Variant = null
	if p is Dictionary:
		raw = p.get("thien_phu", {})
	elif p is Object:
		raw = p.get("thien_phu")
	return raw if raw is Dictionary else {}
