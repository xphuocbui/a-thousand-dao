class_name EventConditions
extends RefCounted
## Pure deterministic condition AST evaluator, effective weight calculator (Formulas B),
## and keyed text placeholder renderer for the Event Engine (design/gdd/event-engine.md
## Rules 4, 7, 22; Formulas B; AC-EV-05, AC-EV-10, AC-EV-40).
##
## Environment dictionary [code]env[/code]:
##   {root: Dictionary, other: Dictionary, place: Dictionary, sect: Dictionary,
##    story: Dictionary, now_season: int, year: int, season: int,
##    edge: bool, co_duyen_left: int, biome: String, travel_mode: String, extra: Dictionary}

const _EventStore = preload("res://src/gameplay/events/event_store.gd")
const _RANK_LADDER := ["ngoai_mon", "noi_mon", "truong_lao", "tong_chu"]

static var _cast_cache_id: int = 0
static var _cast_by_key: Dictionary = {}


## Evaluates a condition AST node [param cond] against [param env], [param gd], and [param db].
## Empty conditions evaluate to true. Unknown condition types evaluate to false.
static func evaluate(cond: Dictionary, env: Dictionary, gd: GameData, db: WorldDB) -> bool:
	if cond.is_empty():
		return true
	var ctype: String = str(cond.get("type", ""))
	if ctype == "":
		return true
	match ctype:
		"all":
			for sub in Array(cond.get("items", [])):
				if not (sub is Dictionary) or not evaluate(sub as Dictionary, env, gd, db):
					return false
			return true
		"any":
			var items: Array = Array(cond.get("items", []))
			if items.is_empty():
				return false
			for sub in items:
				if sub is Dictionary and evaluate(sub as Dictionary, env, gd, db):
					return true
			return false
		"not":
			var sub: Variant = cond.get("item", cond.get("cond", {}))
			if sub is Dictionary:
				return not evaluate(sub as Dictionary, env, gd, db)
			return false
		"realm_min":
			var p: Dictionary = _person(cond, env, db, "root")
			return not p.is_empty() and int(p.get("realm_index", 0)) >= _realm_idx(gd, cond.get("value", 0))
		"realm_max":
			var p: Dictionary = _person(cond, env, db, "root")
			return not p.is_empty() and int(p.get("realm_index", 0)) <= _realm_idx(gd, cond.get("value", 99))
		"stage_min":
			var p: Dictionary = _person(cond, env, db, "root")
			return not p.is_empty() and int(p.get("stage", 0)) >= int(cond.get("value", 0))
		"stage_max":
			var p: Dictionary = _person(cond, env, db, "root")
			return not p.is_empty() and int(p.get("stage", 0)) <= int(cond.get("value", 99))
		"age_min":
			var p: Dictionary = _person(cond, env, db, "root")
			return not p.is_empty() and float(p.get("age", 0.0)) >= float(cond.get("value", 0.0))
		"age_max":
			var p: Dictionary = _person(cond, env, db, "root")
			return not p.is_empty() and float(p.get("age", 0.0)) <= float(cond.get("value", 0.0))
		"lifespan_left_max":
			var p: Dictionary = _person(cond, env, db, "root")
			return not p.is_empty() and _lifespan_left(gd, p) <= float(cond.get("value", 0.0))
		"lifespan_left_min":
			var p: Dictionary = _person(cond, env, db, "root")
			return not p.is_empty() and _lifespan_left(gd, p) >= float(cond.get("value", 0.0))
		"has_sect":
			var p: Dictionary = _person(cond, env, db, "root")
			var want: bool = bool(cond.get("value", true))
			return (str(p.get("sect_id", "")) != "") == want
		"sect_id":
			var s: Dictionary = _sect(cond, env, db)
			var want_s: String = str(cond.get("value", ""))
			if s.is_empty():
				return want_s == ""
			return str(s.get("id", "")) == want_s or str(s.get("key", "")) == want_s
		"sect_rank":
			var p: Dictionary = _person(cond, env, db, "root")
			return str(p.get("sect_rank", "")) == str(cond.get("value", ""))
		"sect_rank_min":
			var p: Dictionary = _person(cond, env, db, "root")
			var cur_i: int = _RANK_LADDER.find(str(p.get("sect_rank", "")))
			var min_i: int = _RANK_LADDER.find(str(cond.get("value", "")))
			return cur_i >= 0 and min_i >= 0 and cur_i >= min_i
		"sect_alignment":
			var s: Dictionary = _sect(cond, env, db)
			return not s.is_empty() and str(s.get("alignment", "")) == str(cond.get("value", ""))
		"attitude_min":
			var p: Dictionary = _person(cond, env, db, "other")
			return not p.is_empty() and int(p.get("attitude", 0)) >= int(cond.get("value", 0))
		"attitude_max":
			var p: Dictionary = _person(cond, env, db, "other")
			return not p.is_empty() and int(p.get("attitude", 0)) <= int(cond.get("value", 0))
		"has_trait":
			var p: Dictionary = _person(cond, env, db, "root")
			var tid: String = str(cond.get("trait", cond.get("value", "")))
			if p.is_empty() or tid == "":
				return false
			return NpcTraits.held(p).has(tid) or Array(p.get("traits", [])).has(tid)
		"has_event_hook":
			var p: Dictionary = _person(cond, env, db, "root")
			var hk: String = str(cond.get("hook", cond.get("value", "")))
			if p.is_empty() or hk == "" or gd == null:
				return false
			if not hk.begins_with("event:"):
				hk = "event:" + hk
			return NpcTraits.opened_hooks(gd, p).has(hk)
		"has_flag":
			var sid: String = _scope_id(cond, env, "root")
			var fname: String = str(cond.get("flag", cond.get("value", "")))
			var now_s: int = int(env.get("now_season", 0))
			return _EventStore.has_flag(db, sid, fname, now_s)
		"var_cmp":
			var sid: String = _scope_id(cond, env, "root")
			var vname: String = str(cond.get("var", ""))
			var cur_v: int = _EventStore.get_var(db, sid, vname, 0)
			if str(cond.get("scope", "")) == "story":
				var st_vars: Dictionary = Dictionary(env.get("story", {}).get("variables", {}))
				if st_vars.has(vname) and _EventStore.get_var(db, sid, vname, -999999999) == -999999999:
					cur_v = int(st_vars[vname])
			return _cmp_int(cur_v, str(cond.get("op", ">=")), int(cond.get("value", 0)))
		"has_item":
			var p: Dictionary = _person(cond, env, db, "root")
			if p.is_empty() or db == null:
				return false
			var target: String = str(cond.get("value", cond.get("item", "")))
			for it in db.items_of(str(p.get("id", ""))):
				if str(it.get("id", "")) == target or str(it.get("template_id", "")) == target \
						or str(it.get("herb", "")) == target or str(it.get("material", "")) == target \
						or str(it.get("recipe", "")) == target or str(it.get("named_id", "")) == target \
						or str(it.get("talisman", "")) == target or str(it.get("treasure", "")) == target \
						or str(it.get("kind", "")) == target:
					return true
			return false
		"has_item_tag":
			var p: Dictionary = _person(cond, env, db, "root")
			if p.is_empty() or db == null:
				return false
			var tag: String = str(cond.get("value", cond.get("tag", "")))
			for it in db.items_of(str(p.get("id", ""))):
				if str(it.get("kind", "")) == tag or Array(it.get("tags", [])).has(tag):
					return true
			return false
		"linh_thach_min":
			var p: Dictionary = _person(cond, env, db, "root")
			return not p.is_empty() and float(p.get("linh_thach", 0.0)) >= float(cond.get("value", 0.0))
		"place_kind":
			var pl: Dictionary = Dictionary(env.get("place", {}))
			var pk: String = place_kind_of(pl, gd)
			return _matches_str_or_array(pk, cond.get("value", ""), true)
		"biome":
			var pl: Dictionary = Dictionary(env.get("place", {}))
			var b: String = str(env.get("biome", ""))
			if b == "":
				b = str(pl.get("biome", Dictionary(pl.get("qi", {})).get("part_biome", "")))
			return _matches_biome(b, cond.get("value", ""))
		"travel_mode":
			var tm: String = str(env.get("travel_mode", ""))
			return _matches_str_or_array(tm, cond.get("value", ""), true)
		"danger_min":
			var pl: Dictionary = Dictionary(env.get("place", {}))
			return int(pl.get("danger", 1)) >= int(cond.get("value", 1))
		"danger_max":
			var pl: Dictionary = Dictionary(env.get("place", {}))
			return int(pl.get("danger", 1)) <= int(cond.get("value", 4))
		"place_owner":
			var pl: Dictionary = Dictionary(env.get("place", {}))
			var want_o: String = str(cond.get("value", ""))
			var holder_id: String = str(pl.get("holder", pl.get("sect_id", "")))
			if want_o == "none" or want_o == "":
				return holder_id == ""
			if holder_id == want_o:
				return true
			if db != null and holder_id != "":
				var srec: Dictionary = db.get_record("sects", holder_id)
				return str(srec.get("key", "")) == want_o
			return false
		"region_id":
			var pl: Dictionary = Dictionary(env.get("place", {}))
			var want_r: String = str(cond.get("value", ""))
			var rid: String = str(pl.get("region_id", ""))
			if rid == want_r:
				return true
			if db != null and rid != "":
				var rrec: Dictionary = db.get_record("regions", rid)
				return str(rrec.get("continent_id", "")) == want_r
			return false
		"place_known":
			var pl: Dictionary = Dictionary(env.get("place", {}))
			var extra: Dictionary = Dictionary(env.get("extra", {}))
			var known: bool = bool(extra.get("place_known", not bool(pl.get("hidden", false))))
			return known == bool(cond.get("value", true))
		"season_of_year":
			var s_idx: int = int(env.get("season", 0))
			var v: Variant = cond.get("value", 0)
			if v is Array:
				return (v as Array).any(func(x): return int(x) == s_idx)
			return s_idx == int(v)
		"year_min":
			return int(env.get("year", 0)) >= int(cond.get("value", 0))
		"year_max":
			return int(env.get("year", 0)) <= int(cond.get("value", 0))
		"event_logged_within":
			if db == null:
				return false
			var sid: String = _scope_id(cond, env, "root")
			var kind_v: String = str(cond.get("event_kind", cond.get("value", "")))
			var within: int = int(cond.get("seasons", 4))
			var spy: int = int(gd.cultivation_rules().get("seasons_per_year", 4)) if gd != null else 4
			var now_s: int = int(env.get("now_season", int(env.get("year", 0)) * spy + int(env.get("season", 0))))
			for e in db.events_of(sid):
				var et: String = str(e.get("type", ""))
				var dt: String = str(Dictionary(e.get("data", {})).get("template_id", ""))
				if et != kind_v and dt != kind_v:
					continue
				var es: int = int(e.get("year", 0)) * spy + int(e.get("season", 0))
				if now_s - es >= 0 and now_s - es <= within:
					return true
			return false
		"story_stage":
			var want_stage: String = str(cond.get("stage", cond.get("value", "")))
			var st: Dictionary = Dictionary(env.get("story", {}))
			var want_sid: String = str(cond.get("story_id", ""))
			if not st.is_empty() and (want_sid == "" or str(st.get("story_id", "")) == want_sid):
				return str(st.get("stage", "")) == want_stage
			if db != null and want_sid != "":
				var root_id: String = str(Dictionary(env.get("root", {})).get("id", ""))
				for srec in _EventStore.active_stories(db, root_id, true):
					if str(srec.get("story_id", "")) == want_sid and str(srec.get("stage", "")) == want_stage:
						return true
			return false
		"person_alive":
			var want_alive: bool = bool(cond.get("value", true))
			var p: Dictionary = _person(cond, env, db, "other")
			if p.is_empty() and str(cond.get("cast_key", "")) != "" and db != null:
				var ck: String = str(cond.cast_key)
				for rec in db.all("people"):
					if str(rec.get("cast_key", "")) == ck:
						p = rec
						break
			return (not p.is_empty() and bool(p.get("alive", false))) == want_alive
		"has_edge":
			return bool(env.get("edge", false)) == bool(cond.get("value", true))
		"co_duyen_left":
			return int(env.get("co_duyen_left", 0)) >= int(cond.get("value", 1))
		"at_bottleneck":
			var p: Dictionary = _person(cond, env, db, "root")
			var extra: Dictionary = Dictionary(env.get("extra", {}))
			var bn: bool = bool(p.get("at_bottleneck", extra.get("at_bottleneck", false)))
			return bn == bool(cond.get("value", true))
		"tam_ma_min":
			var p: Dictionary = _person(cond, env, db, "root")
			return not p.is_empty() and float(p.get("tam_ma", 0.0)) >= float(cond.get("value", 0.0))
		"cast_key":
			var p: Dictionary = _person(cond, env, db, "other")
			return _matches_str_or_array(str(p.get("cast_key", "")), cond.get("value", ""), false)
		"has_secret":
			var p: Dictionary = _person(cond, env, db, "other")
			var want_sec: bool = bool(cond.get("value", true))
			return (_cast_field(p, "secret", gd) != "") == want_sec
		"has_want":
			var p: Dictionary = _person(cond, env, db, "root")
			var want_w: bool = bool(cond.get("value", true))
			return (_cast_field(p, "wants", gd) != "") == want_w
		"chronicle_hidden":
			var cid: String = str(cond.get("chronicle_id", cond.get("value", "")))
			return _is_chronicle_hidden(db, cid)
		"tie_kind":
			if db == null:
				return false
			var r: Dictionary = Dictionary(env.get("root", {}))
			var o: Dictionary = Dictionary(env.get("other", {}))
			if r.is_empty() or o.is_empty():
				return false
			var tie: Dictionary = db.tie_between(str(r.get("id", "")), str(o.get("id", "")))
			if tie.is_empty():
				return false
			var want_k: String = str(cond.get("value", ""))
			var pin: Dictionary = Dictionary(tie.get("pin", {}))
			return pin.has(want_k) or str(tie.get("kind", "")) == want_k
		"sect_at_war":
			var s: Dictionary = _sect(cond, env, db)
			var want_war: bool = bool(cond.get("value", true))
			var at_war: bool = not s.is_empty() and not Array(s.get("wars", [])).is_empty()
			return at_war == want_war
	return false


## Formulas B (Rule 7, AC-EV-10): effective weight of [param rec] in [param env].
## Returns 0.0 if [code]w_base <= 0[/code] or any active modifier has [code]factor <= 0[/code];
## otherwise [code]w_base * clamp(product(active factors), f_lo, f_hi)[/code].
static func effective_weight(rec: Dictionary, env: Dictionary, gd: GameData, db: WorldDB) -> float:
	var w_base: float = float(rec.get("weight", 1.0))
	if w_base <= 0.0:
		return 0.0
	var prod: float = 1.0
	for mod in Array(rec.get("weight_mods", [])):
		if not (mod is Dictionary):
			continue
		var md: Dictionary = mod as Dictionary
		var mcond: Dictionary = Dictionary(md.get("conditions", {}))
		if not mcond.is_empty() and not evaluate(mcond, env, gd, db):
			continue
		var f: float = float(md.get("factor", 1.0))
		if f <= 0.0:
			return 0.0
		prod *= f
	var extra_factors: Variant = Dictionary(env.get("extra", {})).get("weight_factors", [])
	if extra_factors is Array:
		for f_val in (extra_factors as Array):
			var fv: float = float(f_val)
			if fv <= 0.0:
				return 0.0
			prod *= fv
	var w_cfg: Dictionary = gd.budgets().get("weights", {}) if gd != null else {}
	var f_lo: float = float(w_cfg.get("f_lo", 0.1))
	var f_hi: float = float(w_cfg.get("f_hi", 10.0))
	return w_base * clampf(prod, f_lo, f_hi)


## Resolves a place's canonical fixed-world kind (falling back from legacy [code]type[/code] if absent).
static func place_kind_of(place: Dictionary, gd: GameData) -> String:
	var pk: String = str(place.get("kind", ""))
	if pk != "":
		return pk
	var legacy: String = str(place.get("type", ""))
	if legacy == "" or gd == null:
		return legacy
	var kinds: Dictionary = Dictionary(gd.world_gen().get("continent", {})).get("kinds", {})
	for k in kinds:
		if str(Dictionary(kinds[k]).get("type", "")) == legacy:
			return str(k)
	return legacy


## Renders a Vietnamese text string or variant array using keyed selection and placeholder substitution
## (Rule 22, AC-EV-40). Supports {player}, {root}, {other}, {npc}, {place}, {region}, {sect},
## {other_history}, {npc_history}, {paid}, {story_name}, and {var:<name>}.
static func render_text(raw_text: Variant, subs: Dictionary, seed_key: String = "") -> String:
	var chosen: String = ""
	if raw_text is Array:
		var arr: Array = raw_text as Array
		if arr.is_empty():
			return ""
		var idx: int = int(abs(RngUtils.stable_hash(seed_key))) % arr.size() if seed_key != "" else 0
		chosen = str(arr[idx])
	else:
		chosen = str(raw_text) if raw_text != null else ""
	var out: String = chosen
	for k in subs:
		var ks: String = str(k)
		var token: String = ks if (ks.begins_with("{") and ks.ends_with("}")) else ("{%s}" % ks)
		out = out.replace(token, str(subs[k]))
	return out


# --- Internal Helpers ----------------------------------------------------------------------------

static func _person(cond: Dictionary, env: Dictionary, db: WorldDB, default_scope: String) -> Dictionary:
	var sc: String = str(cond.get("scope", default_scope))
	match sc:
		"root", "player":
			return Dictionary(env.get("root", {}))
		"other", "npc":
			return Dictionary(env.get("other", {}))
	if db != null and sc != "":
		return db.get_record("people", sc)
	return {}


static func _sect(cond: Dictionary, env: Dictionary, db: WorldDB) -> Dictionary:
	var sc: String = str(cond.get("scope", "sect"))
	if sc == "sect":
		var s: Dictionary = Dictionary(env.get("sect", {}))
		if not s.is_empty():
			return s
		var r_sid: String = str(Dictionary(env.get("root", {})).get("sect_id", ""))
		return db.get_record("sects", r_sid) if (db != null and r_sid != "") else {}
	if sc == "root" or sc == "other":
		var p: Dictionary = _person({"scope": sc}, env, db, sc)
		var sid: String = str(p.get("sect_id", ""))
		return db.get_record("sects", sid) if (db != null and sid != "") else {}
	if db != null and sc != "":
		return db.get_record("sects", sc)
	return {}


static func _scope_id(cond: Dictionary, env: Dictionary, default_scope: String) -> String:
	var sc: String = str(cond.get("scope", default_scope))
	match sc:
		"world":
			return "world"
		"root", "player":
			return str(Dictionary(env.get("root", {})).get("id", ""))
		"other", "npc":
			return str(Dictionary(env.get("other", {})).get("id", ""))
		"place":
			return str(Dictionary(env.get("place", {})).get("id", ""))
		"sect":
			return str(Dictionary(env.get("sect", {})).get("id", ""))
		"story":
			return str(Dictionary(env.get("story", {})).get("id", ""))
	return sc


static func _realm_idx(gd: GameData, val: Variant) -> int:
	if typeof(val) == TYPE_INT or typeof(val) == TYPE_FLOAT:
		return int(val)
	var s: String = str(val)
	if s.is_valid_int():
		return int(s)
	if gd != null:
		var idx: int = gd.realm_index(s)
		if idx >= 0:
			return idx
	return 0


static func _lifespan_left(gd: GameData, p: Dictionary) -> float:
	if p.has("lifespan_left"):
		return float(p.lifespan_left)
	var age: float = float(p.get("age", 16.0))
	var bonus: float = float(p.get("lifespan_bonus", 0.0))
	var base_life: float = 100.0
	if gd != null:
		var r: Dictionary = gd.realm(int(p.get("realm_index", 0)))
		base_life = float(r.get("lifespan", 100.0))
	return maxf(0.0, base_life + bonus - age)


static func _cmp_int(a: int, op: String, b: int) -> bool:
	match op:
		"==", "=":
			return a == b
		"!=":
			return a != b
		">":
			return a > b
		">=":
			return a >= b
		"<":
			return a < b
		"<=":
			return a <= b
	return false


static func _matches_str_or_array(actual: String, expected: Variant, allow_any: bool) -> bool:
	if expected is Array:
		for x in (expected as Array):
			var xs: String = str(x)
			if (allow_any and xs == "any") or xs == actual:
				return true
		return false
	var es: String = str(expected)
	return (allow_any and es == "any") or es == actual


static func _matches_biome(actual: String, expected: Variant) -> bool:
	var norm_a: String = actual.strip_edges().to_lower().replace(" ", "_")
	if expected is Array:
		for x in (expected as Array):
			var nx: String = str(x).strip_edges().to_lower().replace(" ", "_")
			if nx == "any" or nx == norm_a:
				return true
		return false
	var ne: String = str(expected).strip_edges().to_lower().replace(" ", "_")
	return ne == "any" or ne == norm_a


static func _cast_field(p: Dictionary, field: String, gd: GameData) -> String:
	if p.is_empty():
		return ""
	var direct: String = str(p.get(field, "")).strip_edges()
	if direct != "":
		return direct
	if field == "secret":
		var alt: String = str(p.get("secrets", "")).strip_edges()
		if alt != "":
			return alt
	var ck: String = str(p.get("cast_key", ""))
	if ck == "" or gd == null:
		return ""
	var gid: int = gd.get_instance_id()
	if _cast_cache_id != gid:
		_cast_cache_id = gid
		_cast_by_key = {}
		for cp in Array(gd.file("world_history").get("people", [])):
			if cp is Dictionary and str((cp as Dictionary).get("key", "")) != "":
				_cast_by_key[str((cp as Dictionary).key)] = cp
	var crec: Dictionary = _cast_by_key.get(ck, {})
	return str(crec.get(field, "")).strip_edges()


static func _is_chronicle_hidden(db: WorldDB, cid: String) -> bool:
	if db == null or cid == "":
		return false
	for e in db.all("events"):
		var data: Dictionary = Dictionary(e.get("data", {}))
		if str(data.get("id", "")) == cid:
			return str(e.get("type", "")) == "hidden" or bool(data.get("secret", false))
	return false
