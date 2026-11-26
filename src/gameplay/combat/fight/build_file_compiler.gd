class_name BuildFileCompiler
extends RefCounted
## Compiles a Character-shaped build file into a fully resolved fighter record (the sim's engine [code]Build[/code]
## form that [FighterProfileLoader] loads). A GDScript port of fight.py's [code]expand_library()[/code] and
## [code]to_build()[/code] for the fields a Character's fighter has (ADR-0001 step 3), checked case for case against
## fight.py by tests/parity/compile (every named item and every library art).
##
## The build file: name, realm (0-4), layers, n_body, n_qi, ward ({ws_base, we, layers, block, payload, drain_base}),
## arts ([{"lib": art id}] or inline build-file arts), items (named item ids), modifiers (stat-sheet lines
## [code]{key, value, scope?}[/code], compiled the way fight.py compiles a technique's passives, as the always-on
## Effect "tech:character") and purity (engine element -> points). Any other field is refused by name: the sim's test
## fields (keystones, curses, companions, enemy overrides) are not a Character's.
##
## Data: [code]combat_library.json[/code] (arts, items, constants; written by
## tools/design/combat_sim/export_combat_library.py), [code]combat_effects.json[/code] and [code]combat_engine.json[/code]
## CHARACTER_MODS and MOD_KEYS.
##
## Usage:
## [codeblock]
## var bfc := BuildFileCompiler.new(gd)
## var record: Dictionary = bfc.compile(build_file)
## if record.is_empty(): push_error("\n".join(bfc.errors))
## var report: PackedStringArray = bfc.unmodelled   # what the fight does not run, in fight.py's words
## [/codeblock]

const LIBRARY_FILE := "combat_library"
## Build-file fields a Character's fighter may have (before and after expansion).
const KEYS := ["name", "realm", "layers", "n_body", "n_qi", "ward", "arts", "items", "modifiers", "purity", "effects",
	"counters", "states", "unmodelled", "wards", "reserved", "stack_eff", "stack_dur", "body", "divine_sense",
	"stage_mult", "tree_effects", "tree_lines_on_sheet", "counts", "stack_alias", "no_ward"]
## Base elements among slotted arts (the art_elements count: Utmost Yang, Utmost Yin).
const BASE_ELEMENTS := ["fire", "water", "earth", "metal", "wood"]
const WARD_KEYS := ["model", "payload", "drain_base", "ws_base", "we", "layers", "block"]
const BODY_KEYS := ["block", "resistance", "shield", "layers"]
const ART_KEYS := ["id", "c_art", "cost_share", "cooldown", "element", "kind", "buff", "debuff", "c_heal",
	"qi_restore", "cleanse", "x", "_comment", "tags", "guards", "statuses", "split", "soul_pct", "soul_part", "bypass",
	"pool", "convert", "hp_cost", "charges", "group", "steps", "empower", "escape"]
## The synthetic technique a Character's sheet lines are compiled as (fight.py treats it like any technique).
const SHEET_ID := "character"

## Problems with the last build file; empty when it compiled.
var errors: PackedStringArray = []
## What the last build file has that the fight does not run, in fight.py's wording.
var unmodelled: PackedStringArray = []

var _arts: Dictionary
var _items: Dictionary
var _c: Dictionary
var _defaults: Dictionary
var _file: Dictionary
var _effects_lib: Dictionary
var _mod_keys: Dictionary = {}
var _passive: Dictionary
var _ctx: Dictionary = {}
var _out_of_fight: Dictionary = {}
var _static: Dictionary = {}
var _scope_el: Dictionary
var _scope_dt: Dictionary
var _lib_art_keys: Dictionary = {}
## The reserved share the last _extra_wards() call added (fight.py's extra_wards second return value).
var _xres := 0.0


## Reads the library and constants from [param gd].
func _init(gd: GameData) -> void:
	var lib: Dictionary = gd.file(LIBRARY_FILE)
	_arts = lib.get("arts", {})
	_items = lib.get("items", {})
	_c = lib.get("constants", {})
	_defaults = _c.get("build_defaults", {})
	_file = _c.get("file_defaults", {})
	for k in _c.get("lib_art_keys", []):
		_lib_art_keys[str(k)] = true
	_effects_lib = gd.file("combat_effects").get("effects", {})
	var eng: Dictionary = gd.file("combat_engine")
	for k in eng.get("MOD_KEYS", []):
		_mod_keys[str(k)] = true
	var cm: Dictionary = eng.get("CHARACTER_MODS", {})
	_passive = cm.get("passive", {})
	for k in cm.get("ctx_mods", []):
		_ctx[str(k)] = true
	for k in cm.get("out_of_fight", []):
		_out_of_fight[str(k)] = true
	for k in cm.get("static", []):
		_static[str(k)] = true
	_scope_el = cm.get("scope_element", {})
	_scope_dt = cm.get("scope_dtype", {})
	if _arts.is_empty() or _defaults.is_empty() or _passive.is_empty():
		errors.append("combat_library.json or combat_engine.json CHARACTER_MODS is missing")


## The resolved fighter record for [param build_file], or {} with [member errors] naming each problem.
func compile(build_file: Dictionary) -> Dictionary:
	errors = []
	unmodelled = []
	for key in build_file:
		if not (str(key) in KEYS):
			errors.append("%s: field %s is not compiled for a Character" % [_who(build_file), str(key)])
	if not errors.is_empty():
		return {}
	var d: Dictionary = _expand(build_file)
	if not errors.is_empty():
		return {}
	var rec: Dictionary = _to_build(d, int(d.get("realm", 0)), _who(build_file))
	unmodelled = PackedStringArray(d.get("unmodelled", []))
	return rec if errors.is_empty() else {}


func _who(d: Dictionary) -> String:
	return str(d.get("name", "character"))


# --- expand_library -------------------------------------------------------------------------------------------------

func _expand(src: Dictionary) -> Dictionary:
	var d: Dictionary = src.duplicate(true)
	var lines: Array = d.get("modifiers", [])
	d.erase("modifiers")
	var effects: Array = d.get("effects", []).duplicate()
	var counters: Array = d.get("counters", []).duplicate()
	var states: Array = d.get("states", []).duplicate()
	var have_c := {}
	for c in counters:
		have_c[c.get("id")] = true
	var have_s := {}
	for s in states:
		have_s[s.get("id")] = true
	var out: Array = []
	for a in d.get("arts", []):
		if a is Dictionary and a.has("lib"):
			var aid: String = str(a.lib)
			if not _arts.has(aid):
				errors.append("arts: library art '%s' not found in combat_library.json" % aid)
				continue
			var s: Dictionary = _arts[aid]
			var x := {}
			for k in s:
				if _lib_art_keys.has(str(k)):
					x[k] = s[k]
			x["id"] = s.id
			for k in a:
				if str(k) != "lib":
					x[k] = a[k]
			out.append(x.duplicate(true))
			effects.append_array(s.get("effects", []).duplicate(true))
			for c in s.get("counters", []):
				if not have_c.has(c.get("id")):
					have_c[c.get("id")] = true
					counters.append(c.duplicate(true))
			for st in s.get("states", []):
				if not have_s.has(st.get("id")):
					have_s[st.get("id")] = true
					states.append(st.duplicate(true))
		else:
			out.append(a)
	d["arts"] = out
	var unmod: Array = Array(d.get("unmodelled", [])).duplicate()
	# the Character's sheet lines, exactly as fight.py compiles a technique's passives
	_apply_static(d, lines, "technique %s" % SHEET_ID, unmod)
	var te: Variant = _passive_effect(SHEET_ID, unmod, lines, "technique", "tech")
	if te != null:
		effects.append(te)
	var worn: Array = Array(d.get("items", []))
	var lib_done := {}
	for iid_v in worn:
		var iid: String = str(iid_v)
		if not _items.has(iid):
			errors.append("items: '%s' not found in combat_library.json" % iid)
			continue
		var it: Dictionary = _items[iid]
		_apply_static(d, it.get("modifiers", []), "item %s" % iid, unmod)
		var ie: Variant = _passive_effect(iid, unmod, it.get("modifiers", []), "item", "item")
		if ie != null:
			effects.append(ie)
		var armour: bool = str(it.get("role", "")) == "body_gear"
		for w in it.get("wards", []):
			var wd: Dictionary = (w as Dictionary).duplicate(true)
			wd["source"] = "item %s" % iid
			wd["own_slot"] = armour
			if not d.has("wards"):
				d["wards"] = []
			d.wards.append(wd)
		for r in it.get("reserve_arts", []):
			d["reserved"] = float(d.get("reserved", 0.0)) + float(r.reserve)
			var grants: Array = r.get("grants", [])
			_apply_static(d, grants, "item %s reserve %s" % [iid, str(r.id)], unmod)
			var re: Variant = _passive_effect("%s:%s" % [iid, str(r.id)], unmod, grants, "reserve art", "reserve")
			if re != null:
				effects.append(re)
			if grants.is_empty():
				unmod.append("item %s reserve art %s: reserves %d %% of linh luc; its rule (%s) is not run unless written in \"effects\"" \
					% [iid, str(r.name), _py_round(100.0 * float(r.reserve)), str(r.get("rule", "")).substr(0, 60)])
		for ef in it.get("effects", []):
			var name: String = str(ef)
			var short: String = name.split(" (")[0]
			var own := false
			for x in src.get("effects", []):
				var xid: String = str(x.get("id", ""))
				if xid.begins_with("eff:") and xid.to_lower().contains(short.to_lower()):
					own = true
			if own or lib_done.has(short):
				continue
			lib_done[short] = true
			if not _add_library_effect(short, d, effects, counters, unmod, "item %s" % iid, worn):
				unmod.append("item %s Effect %s: not in assets/data/combat_effects.json; write it in \"effects\" (id \"eff:<name>\") to run it" % [iid, name])
	d.erase("items")
	# the Đạo Đồ's held Effects by name (keystones and crown notables; ADR-0004 decision 3), as fight.py
	var tree: Array = Array(d.get("tree_effects", [])).duplicate()
	var on_sheet: bool = bool(d.get("tree_lines_on_sheet", false))
	d.erase("tree_effects")
	d.erase("tree_lines_on_sheet")
	for ef in tree:
		var short: String = str(ef).split(" (")[0]
		if lib_done.has(short):
			continue
		lib_done[short] = true
		if not _add_library_effect(short, d, effects, counters, unmod, "Đạo Đồ", worn, build_counts(d), not on_sheet):
			unmod.append("Đạo Đồ Effect %s: not in assets/data/combat_effects.json (not run)" % str(ef))
	var pm: Dictionary = d.get("_pool_more", {})
	for f in pm:
		d[f] = float(d.get(f, _file.n_body if str(f) == "n_body" else _file.n_qi)) * float(pm[f])
	d.erase("_pool_more")
	if d.has("_stack_alias"):
		var alias: Dictionary = d.get("stack_alias", {}).duplicate(true)
		for k in d._stack_alias:
			alias[k] = _union(alias.get(k, []), d._stack_alias[k])
		d["stack_alias"] = alias
		d.erase("_stack_alias")
	for tag in d.get("_only_tag", []):
		var kept: Array = Array(d.get("arts", [])).filter(func(a): return a is Dictionary and str(tag) in Array(a.get("tags", [])))
		if kept.size() < Array(d.get("arts", [])).size():
			unmod.append("Đạo Đồ: only arts tagged %s may be slotted; %d left out" % [str(tag), Array(d.arts).size() - kept.size()])
		d["arts"] = kept
	d.erase("_only_tag")
	d["effects"] = effects
	d["counters"] = counters
	d["states"] = states
	d["unmodelled"] = unmod
	d.erase("_pool_pct")
	return d


## The compile-time counts a library Effect may multiply by (fight.py build_counts): the build file's own "counts"
## (empty_extra_slots, carried_sword, root_elements: FighterCompiler fills them) plus empty_art_slots (the realm's
## art slots less the arts) and art_elements (distinct base elements among the arts).
func build_counts(d: Dictionary) -> Dictionary:
	var out: Dictionary = (d.get("counts", {}) as Dictionary).duplicate()
	var arts: Array = d.get("arts", [])
	var r: int = int(d.get("realm", 0))
	if not out.has("empty_art_slots"):
		out["empty_art_slots"] = maxi(0, int(_c.slots_by_realm[r]) - arts.size())
	if not out.has("art_elements"):
		var els := {}
		for a in arts:
			if a is Dictionary and str(a.get("element", "")) in BASE_ELEMENTS:
				els[str(a.element)] = true
		out["art_elements"] = els.size()
	return out


static func _union(a: Array, b: Array) -> Array:
	var seen := {}
	for x in a + b:
		seen[str(x)] = true
	var out: Array = seen.keys()
	out.sort()
	return out


func _lib_count(spec: Dictionary, worn: Array, counts: Dictionary = {}) -> float:
	if spec.has("of"):
		var c: float = float(counts.get(str(spec.of), 0))
		return minf(c, float(spec.cap)) if spec.get("cap") != null else c
	var n := 0
	for iid in worn:
		var it: Dictionary = _items.get(str(iid), {})
		if spec.has("role"):
			if str(it.get("role", "")) == str(spec.role) and str(spec.role) != "":
				n += 1
		else:
			for tags in it.get("art_tags", []):
				if str(spec.art_tag) in Array(tags):
					n += 1
					break
	return float(maxi(0, n - int(spec.get("minus", 0))))


## fight.py add_library_effect: a named Effect's library form. A Đạo Đồ entry (2026-11-20) may also carry "lines"
## (its closing and other plain stat lines, folded like an item's modifiers; skipped when [param lines] is false
## because the Character's sheet already holds them), "pool_more", "stack_alias", "no_ward", "only_tag", "pending",
## and "fixed" records (closings: never multiplied by the count, kept at a count of 0).
func _add_library_effect(name: String, d: Dictionary, effects: Array, counters: Array, unmod: Array, who: String, worn: Array,
		counts: Dictionary = {}, lines: bool = true) -> bool:
	if not _effects_lib.has(name):
		return false
	var lib: Dictionary = _effects_lib[name]
	if lib.get("not_run"):
		unmod.append("%s Effect %s: not run (%s)" % [who, name, str(lib.not_run)])
		return true
	if lib.get("pending"):
		unmod.append("%s Effect %s: part not run yet (%s)" % [who, name, str(lib.pending)])
	if lines and lib.get("lines"):
		_apply_static(d, lib.lines, "%s Effect %s" % [who, name], unmod)
		var pe: Variant = _passive_effect(name, unmod, lib.lines, "Effect", "lines")
		if pe != null:
			effects.append(pe)
	if lib.get("pool_more"):
		if not d.has("_pool_more"):
			d["_pool_more"] = {}
		for k in lib.pool_more:
			d._pool_more[k] = float(d._pool_more.get(k, 1.0)) * float(lib.pool_more[k])
	if lib.get("stack_alias"):
		if not d.has("_stack_alias"):
			d["_stack_alias"] = {}
		for k in lib.stack_alias:
			d._stack_alias[k] = _union(d._stack_alias.get(k, []), lib.stack_alias[k])
	if lib.get("no_ward"):
		d["no_ward"] = true
	if lib.get("only_tag"):
		if not d.has("_only_tag"):
			d["_only_tag"] = []
		d._only_tag.append(str(lib.only_tag))
	var n: float = _lib_count(lib["count"], worn, counts) if lib.get("count") else 1.0
	var have := {}
	for e in effects:
		have[e.get("id")] = true
	for r0 in lib.get("records", []):
		if have.has(r0.id):
			continue
		var r: Dictionary = (r0 as Dictionary).duplicate(true)
		var fixed: bool = bool(r.get("fixed", false))
		r.erase("fixed")
		if n != 1.0 and not fixed:
			for a in r.get("do", []):
				if a.has("mod"):
					var m := {}
					for k in a.mod:
						m[k] = float(a.mod[k]) * n if _mod_keys.has(str(k)) and not (a.mod[k] is bool) else a.mod[k]
					a["mod"] = m
		if n > 0.0 or fixed:
			effects.append(r)
	var have_c := {}
	for c in counters:
		have_c[c.get("id")] = true
	for c in lib.get("counters", []):
		if not have_c.has(c.id):
			counters.append((c as Dictionary).duplicate(true))
	if lib.get("static"):
		_apply_static(d, lib.static, "%s Effect %s" % [who, name], unmod)
	if lib.get("reserve"):
		d["reserved"] = float(d.get("reserved", 0.0)) + float(lib.reserve)
	if lib.get("approx"):
		unmod.append("%s Effect %s: run from the library, approximately (%s)" % [who, name, str(lib.approx)])
	return true


func _passive_effect(id: String, unmod: Array, lines: Array, what: String, prefix: String) -> Variant:
	var do: Array = []
	for p in lines:
		var key: String = str(p.key)
		var val: float = float(p.value)
		var scope: Array = Array(p.get("scope", []))
		if _static.has(key) or _out_of_fight.has(key):
			continue
		if not _passive.has(key):
			unmod.append("%s %s passive %s %s %s: no engine stat (not run)" % [what, id, key, _py_g_signed(val), _py_list(scope) if not scope.is_empty() else ""])
			continue
		var mk: String = str(_passive[key][0])
		var f: float = float(_passive[key][1])
		var m := {mk: val * f}
		if not scope.is_empty():
			if not _ctx.has(mk):
				unmod.append("%s %s passive %s scope %s: the engine reads %s without hit context, so it applies to every art" % [what, id, key, _py_list(scope), mk])
			else:
				for tag_v in scope:
					var tag: String = str(tag_v)
					if _scope_el.has(tag):
						m["element"] = _scope_el[tag]
					elif _scope_dt.has(tag):
						m["dtype"] = _scope_dt[tag]
					elif tag in ["buff", "debuff"] and mk == "stack_grant":
						m["kind"] = tag
					else:
						if not m.has("tags"):
							m["tags"] = []
						m.tags.append(tag)
		do.append({"mod": m})
	return {"id": "%s:%s" % [prefix, id], "on": "always", "do": do} if not do.is_empty() else null


func _apply_static(d: Dictionary, lines: Array, who: String, unmod: Array) -> void:
	var r: int = int(d.get("realm", 0))
	if not d.has("_pool_pct"):
		d["_pool_pct"] = {"n_body": [float(d.get("n_body", _file.n_body)), 0.0], "n_qi": [float(d.get("n_qi", _file.n_qi)), 0.0]}
	var pools: Dictionary = d._pool_pct
	for ln in lines:
		var key: String = str(ln.key)
		var val: float = float(ln.value)
		var scope: Array = Array(ln.get("scope", []))
		if not _static.has(key):
			continue
		if key == "khi_huyet_pct" or key == "linh_luc_pct":
			var f: String = "n_body" if key == "khi_huyet_pct" else "n_qi"
			pools[f][1] = float(pools[f][1]) + val
			d[f] = float(pools[f][0]) * (1 + float(pools[f][1]) / 100)
		elif key == "body_shield_pct":
			if not d.has("body"):
				d["body"] = {}
			d.body["shield"] = float(d.body.get("shield", 0.0)) + val / 100
		elif key == "defense_pct" or key == "ward_efficiency_pct":
			if not d.has("ward"):
				d["ward"] = {}
			var ward: Dictionary = d.ward
			if str(ward.get("model", "drain")) != "drain":
				unmod.append("%s %s %s: the build's ward is not a drain ward" % [who, key, _py_g_signed(val)])
				continue
			var ws: float = float(ward.get("ws_base", _c.typical_ws[r]))
			if not ward.has("we"):
				ward["we"] = ws
			if key == "defense_pct":
				ward["ws_base"] = ws + val
			else:
				ward["we"] = float(ward.we) + val
		elif key == "than_thuc_pct":
			d["divine_sense"] = float(d.get("divine_sense", 1.0)) * (1 + val / 100)
		else:
			var els: Array = []
			var kinds: Array = []
			var other: Array = []
			for t_v in scope:
				var t: String = str(t_v)
				if _scope_el.has(t):
					els.append(_scope_el[t])
				elif t in ["buff", "debuff"]:
					kinds.append(t)
				else:
					other.append(t)
			if not other.is_empty():
				unmod.append("%s %s scope %s: only element and buff/debuff scopes are run; read as unscoped for %s" % [who, key, _py_list(scope), _py_list(other)])
			var k: String = "%s|%s" % [els[0] if not els.is_empty() else "*", kinds[0] if not kinds.is_empty() else "*"]
			var tname: String = "stack_eff" if key == "stack_effect_pct" else "stack_dur"
			if not d.has(tname):
				d[tname] = {}
			d[tname][k] = float(d[tname].get(k, 0.0)) + val


# --- to_build -------------------------------------------------------------------------------------------------------

func _offence_m(x_in: Array) -> float:
	var caps: Array = _c.layer_caps
	var start: float = float(_c.l1_soft[0])
	var slope: float = float(_c.l1_soft[1])
	var x: Array = _pad(x_in, 5)
	var x1: float = maxf(float(_file.l1_floor), float(x[0]))
	var x1e: float = x1 if x1 <= start else start + slope * (x1 - start)
	var m: float = 1 + minf(x1e, float(caps[0])) / 100
	for i in range(1, 5):
		m *= 1 + minf(maxf(0.0, float(x[i])), float(caps[i])) / 100
	return m


func _defence_layers(y_in: Array) -> float:
	var caps: Array = _c.defence_layer_caps
	var y: Array = _pad(y_in, 4)
	var m := 1.0
	for i in 4:
		m *= 1 + minf(maxf(0.0, float(y[i])), float(caps[i])) / 100
	return m


static func _pad(a: Array, n: int) -> Array:
	var out: Array = a.duplicate()
	while out.size() < n:
		out.append(0)
	return out


func _check(d: Dictionary, allowed: Array, where: String) -> void:
	for k in d:
		if not (str(k) in allowed):
			errors.append("%s: unknown field %s" % [where, str(k)])


func _to_build(d: Dictionary, r: int, who: String) -> Dictionary:
	if r < 0 or r > 4:
		errors.append("%s: realm %d is not 0-4" % [who, r])
		return {}
	for req in ["layers", "arts"]:
		if not d.has(req):
			errors.append("%s: \"%s\" is required" % [who, req])
			return {}
	var b: Dictionary = _defaults.duplicate(true)
	b["name"] = d.get("name", who)
	b["realm"] = r
	var layers: Array = d.layers
	b["M"] = _offence_m(layers)
	b["crit"] = minf(float(_file.crit[0]), float(_c.crit_chance_cap))
	b["crit_mult"] = minf(float(_file.crit[1]), float(_c.crit_mult_cap))
	for key in ["n_body", "n_qi"]:
		if d.has(key):
			b[key] = float(d[key]) * 1
	var ward: Dictionary = d.get("ward", {})
	_check(ward, WARD_KEYS, who + ".ward")
	var model: String = str(ward.get("model", "drain"))
	if model != "drain":
		errors.append("%s.ward: model %s is not compiled for a Character (a drain ward)" % [who, model])
		return {}
	var ws_base: float = float(ward.get("ws_base", _c.typical_ws[r]))
	var we_main: float = float(ward.get("we", ws_base))
	var m_w: float = _defence_layers(ward.get("layers", _file.ward_layers))
	var ws_mult: float = maxf(float(_file.ws_floor), 1 + ws_base / 100) * m_w / float(_c.w_ref)
	var drain_base: float = float(ward.get("drain_base", _file.drain_base))
	b["ward_pts"] = float(ward.get("payload", _c.common_ward)) * ws_mult
	b["drain"] = drain_base / float(_c.drain_44) / (ws_mult * (1 + we_main / 100))
	b["block"] = float(ward.get("block", _c.typical_block[r]))
	var xw: Array = _extra_wards(d, r, ws_mult, we_main)
	var body: Dictionary = d.get("body", {})
	_check(body, BODY_KEYS, who + ".body")
	if not body.is_empty():
		b["bs_mult"] = _defence_layers(body.get("layers", _file.body_layers))
		b["body_block"] = float(body.get("block", 0.0))
		b["body_pts"] = float(body.get("resistance", 0.0))
		b["body_shield"] = float(body.get("shield", 0.0))
	b["cleanse_pulse"] = 0
	b["cleanse_cost"] = 0.0
	b["cleanse_share"] = 0.0
	var pur: Dictionary = d.get("purity", {})
	for el in pur:
		if not (str(el) in CombatConstants.ELEMENTS) or str(el) == "":
			errors.append("%s.purity: unknown field %s" % [who, str(el)])
	b["purity"] = pur.duplicate()
	var arts: Array = []
	var base_x: Array = layers.duplicate()
	base_x.append_array([0, 0, 0, 0, 0])
	var art_files: Array = d.arts
	for i in art_files.size():
		var a: Dictionary = art_files[i]
		_check(a, ART_KEYS, "%s.arts[%d]" % [who, i])
		var aid: String = str(a.get("id", "art%d" % (i + 1)))
		var el: String = str(a.get("element", ""))
		if not (el in CombatConstants.ELEMENTS):
			errors.append("%s: element %s is not an engine element" % [aid, el])
		var kind: String = str(a.get("kind", "phys"))
		if not (kind in ["phys", "elem"]):
			errors.append("%s: kind must be phys or elem" % aid)
		var m_mult := 1.0
		if a.has("x"):
			var ax: Array = _pad(Array(a.x), 5)
			var mx: Array = []
			for j in 5:
				mx.append(float(base_x[j]) + float(ax[j]))
			m_mult = _offence_m(mx) / float(b.M)
		var art := {
			"name": aid,
			"c": float(a.get("c_art", 0.0)),
			"cost": float(a.get("cost_share", _file.cost_share)) / float(_c.cost_scale),
			"cd": float(a.get("cooldown", _file.cooldown)),
			"element": el, "dtype": kind,
			"buff": Array(a.get("buff", [])).duplicate(), "debuff": Array(a.get("debuff", [])).duplicate(),
			"heal": float(a.get("c_heal", 0.0)), "qi_restore": float(a.get("qi_restore", 0.0)),
			"cleanse": int(a.get("cleanse", 0)), "m_mult": m_mult,
			"tags": Array(a.get("tags", [])).duplicate(), "guards": Array(a.get("guards", [])).duplicate(true),
			"statuses": Array(a.get("statuses", [])).duplicate(true), "split": Array(a.get("split", [])).duplicate(),
			"soul_pct": float(a.get("soul_pct", 0.0)), "soul_part": float(a.get("soul_part", 0.0)),
			"bypass": float(a.get("bypass", 0.0)), "pool": str(a.get("pool", "qi")),
			"convert": (a.get("convert", {}) as Dictionary).duplicate(true), "hp_cost": float(a.get("hp_cost", 0.0)),
			"charges": int(a.get("charges", 1)), "group": str(a.get("group", "")),
			"steps": Array(a.get("steps", [])).duplicate(true), "empower": Array(a.get("empower", [])).duplicate(true),
		}
		if float(art.soul_pct) != 0.0:
			art["c"] = 0.0
		if float(a.get("escape", 0.0)) != 0.0:   # an escape art (world-depth Stage 5); absent at 0, as fight.py's cases
			art["escape"] = float(a.escape)
		arts.append(art)
	b["arts"] = arts
	b["layers"] = _pad(layers, 5)
	b["effects"] = Array(d.get("effects", [])).duplicate(true)
	b["counters"] = Array(d.get("counters", [])).duplicate(true)
	b["states"] = Array(d.get("states", [])).duplicate(true)
	if d.has("divine_sense"):
		b["divine_sense"] = float(d.divine_sense)
	if d.has("stage_mult"):
		b["stage_mult"] = float(d.stage_mult)
	b["wards"] = xw
	var total_res: float = float(d.get("reserved", 0.0)) + _xres
	b["reserved"] = minf(float(_file.reserved_cap), total_res)
	b["stack_eff"] = (d.get("stack_eff", {}) as Dictionary).duplicate()
	b["stack_dur"] = (d.get("stack_dur", {}) as Dictionary).duplicate()
	b["stack_alias"] = (d.get("stack_alias", {}) as Dictionary).duplicate(true)
	if bool(d.get("no_ward", false)):
		# No Ward (Đạo Đồ keystone): no ward of any kind, the default ward included (Combat Defence & Healing rule 5)
		b["ward_pts"] = 0.0
		b["drain"] = 0.0
		b["wards"] = []
		b["reserved"] = maxf(0.0, float(b.reserved) - _xres)
	return b



func _extra_wards(d: Dictionary, r: int, ws_mult: float, we: float) -> Array:
	_xres = 0.0
	if not d.has("unmodelled"):
		d["unmodelled"] = []
	var unmod: Array = d.unmodelled
	var main: int = 0 if str(d.get("ward", {}).get("model", "drain")) == "off" else 1
	var ds: float = float(d.get("divine_sense", 1.0))
	var free_ward: int = int(_c.ward_slots_by_realm[r]) + mini(2, int(floorf(ds / float(_c.ward_slot_sense_step)))) - main
	var free_art: int = int(_c.slots_by_realm[r]) - Array(d.get("arts", [])).size()
	var out: Array = []
	for w in d.get("wards", []):
		var name: String = str(w.get("name", w.get("id", "ward")))
		var src: String = str(w.get("source", "build"))
		for x in w.get("not_run", []):
			unmod.append("%s ward %s: %s is not run" % [src, name, str(x)])
		if w.get("fields") == null:
			continue
		var f: Dictionary = (w.fields as Dictionary).duplicate(true)
		if bool(w.get("own_slot", false)):
			pass   # a worn armour's ward has its armour's own slot (Combat Defence & Healing rule 5)
		elif free_ward > 0:
			free_ward -= 1
		elif free_art > 0:
			free_art -= 1
		else:
			unmod.append("%s ward %s: no free ward or art slot, not slotted" % [src, name])
			continue
		var eff: float = 1 + we / 100
		var payload := {}
		for k in f.payload:
			payload[k] = float(f.payload[k]) * ws_mult
		f["payload"] = payload
		if f.get("block"):
			f["block"] = float(f.block) * ws_mult
		if f.get("shield"):
			f["shield"] = float(f.shield) * ws_mult
		if f.has("cost"):
			f["cost"] = float(f.cost) / eff
		if str(f.model) == "drain":
			var db: float = float(f.drain_base)
			f.erase("drain_base")
			f["drain"] = db / float(_c.drain_44) / (ws_mult * eff)
		if str(f.model) == "reserved":
			_xres += float(f.reserve) / eff
			f.erase("reserve")
		out.append(f)
	return out


# --- Python formatting, so the report reads as fight.py's does ------------------------------------------------------

## Python's "%+g".
static func _py_g_signed(v: float) -> String:
	var s: String = _py_g(absf(v))
	return ("-" if v < 0 else "+") + s


## Python's "%g" for a non-negative number (6 significant digits, no trailing zeros).
static func _py_g(v: float) -> String:
	if v == 0.0:
		return "0"
	var e: int = int(floorf(log(v) / log(10.0)))
	if e < -4 or e >= 6:
		return String.num_scientific(v)
	var s: String = String.num(v, maxi(0, 5 - e))
	if s.contains("."):
		s = s.rstrip("0").rstrip(".")
	return s


## Python's repr of a list of strings.
static func _py_list(a: Array) -> String:
	var parts: PackedStringArray = []
	for x in a:
		parts.append("'%s'" % str(x))
	return "[" + ", ".join(parts) + "]"


## Python's round(): halves go to the even neighbour.
static func _py_round(v: float) -> int:
	var f: float = floorf(v)
	var diff: float = v - f
	if diff > 0.5:
		return int(f) + 1
	if diff < 0.5:
		return int(f)
	return int(f) if int(f) % 2 == 0 else int(f) + 1
