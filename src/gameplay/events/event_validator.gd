class_name EventValidator
extends RefCounted
## Normalizes an event proposed by any source (LLM JSON or a template) into the
## engine's event shape, clamping every number to the budget and registering any new
## person in the WorldDB before it can appear (pillars: Every Number Is Bounded and
## Visible; A World That Remembers). Each clamp or drop is reported as a warning so the
## debug terminal can show exactly what the engine changed.
## Data: events_budgets.json.
##
## Normalized event:
##   {title, text, npc_id, place_id, source, choices: [{label, check, always, success, failure}]}
## check: {type: none|stat|combat, stat, difficulty, evade}; outcomes: {text, effects: [effect]}
## evade marks fleeing/hiding checks, which stealth helps.
##
## Usage:
## [codeblock]
## var v := EventValidator.new(gd, db, builds)
## var res: Dictionary = v.normalize(raw_json, ctx, rng, "llm")
## if res.ok: session.pending_event = res.event
## for w in res.warnings: print("clamped: ", w)
## [/codeblock]

var _gd: GameData
var _db: WorldDB
var _builds: BuildGenerator


func _init(gd: GameData, db: WorldDB, builds: BuildGenerator) -> void:
	_gd = gd
	_db = db
	_builds = builds


## Returns {ok, event, warnings, error}.
func normalize(raw: Variant, ctx: Dictionary, rng: RandomNumberGenerator, source: String) -> Dictionary:
	var cfg: Dictionary = _gd.budgets()
	var warnings: Array = []
	if typeof(raw) != TYPE_DICTIONARY:
		return {"ok": false, "error": "event is not an object", "warnings": warnings}
	var title: String = _text(raw.get("title", ""), int(cfg.max_title_chars))
	var text: String = _text(raw.get("text", ""), int(cfg.max_text_chars))
	if title == "" or text == "":
		return {"ok": false, "error": "missing title or text", "warnings": warnings}
	var raw_choices: Variant = raw.get("choices", [])
	if typeof(raw_choices) != TYPE_ARRAY or (raw_choices as Array).size() < int(cfg.min_choices):
		return {"ok": false, "error": "needs at least %d choices" % int(cfg.min_choices), "warnings": warnings}
	if (raw_choices as Array).size() > int(cfg.max_choices):
		warnings.append("choices truncated to %d" % int(cfg.max_choices))
		raw_choices = (raw_choices as Array).slice(0, int(cfg.max_choices))

	var npc_id: String = _resolve_npc(raw.get("npc"), ctx, rng, warnings)
	var choices: Array = []
	for rc in raw_choices:
		if typeof(rc) != TYPE_DICTIONARY:
			warnings.append("dropped a non-object choice")
			continue
		var check: Dictionary = _check(rc.get("check", {}), npc_id, warnings)
		choices.append({
			"label": _text(rc.get("label", "?"), int(cfg.max_title_chars)),
			"check": check,
			"always": _effects(rc.get("always", []), ctx, warnings, "always"),
			"success": _outcome(rc.get("success", {}), ctx, warnings, "success"),
			"failure": _outcome(rc.get("failure", rc.get("success", {})), ctx, warnings, "failure"),
		})
	if choices.size() < int(cfg.min_choices):
		return {"ok": false, "error": "too few valid choices", "warnings": warnings}
	# Every event must be answerable by a player with no linh thạch, or it would block
	# all time-consuming actions forever (softlock).
	var free_exists: bool = choices.any(func(ch): return not ch.always.any(func(fx): return fx.type == "linh_thach" and float(fx.amount) < 0.0))
	if not free_exists:
		var exit: Dictionary = cfg.free_exit_choice
		choices.append({"label": str(exit.label), "check": {"type": "none"}, "always": [], "success": {"text": str(exit.text), "effects": []}, "failure": {"text": str(exit.text), "effects": []}})
		warnings.append("every choice had a cost; added a free exit")
	var event := {"title": title, "text": text, "npc_id": npc_id, "place_id": ctx.place.id, "source": source, "choices": choices}
	return {"ok": true, "event": event, "warnings": warnings, "error": ""}


func _resolve_npc(npc: Variant, ctx: Dictionary, rng: RandomNumberGenerator, warnings: Array) -> String:
	if typeof(npc) != TYPE_DICTIONARY:
		return ""
	if npc.has("existing_id"):
		var pid: String = str(npc.existing_id)
		var rec: Dictionary = _db.get_record("people", pid)
		if rec.is_empty() or not rec.alive or rec.get("is_player", false):
			warnings.append("npc %s does not exist or is dead; dropped" % pid)
			return ""
		return pid
	if npc.has("id_resolved"):
		return str(npc.id_resolved)
	if npc.has("new") and typeof(npc.new) == TYPE_DICTIONARY:
		var spec: Dictionary = npc.new
		var off_cfg: Dictionary = _gd.budgets().npc_realm_offset
		var offset: int = clampi(int(spec.get("realm_offset", 0)), int(off_cfg.min), int(off_cfg.max))
		if offset != int(spec.get("realm_offset", 0)):
			warnings.append("npc realm_offset clamped to %d" % offset)
		var arch: String = str(spec.get("archetype", ""))
		if _gd.archetype(arch).is_empty():
			arch = ""
		var opts := {
			"realm_index": clampi(int(ctx.player.realm_index) + offset, 0, _gd.realms().size() - 1),
			"location_id": ctx.place.id, "created_by": "llm", "is_beast": bool(spec.get("is_beast", false)),
		}
		if arch != "":
			opts["archetype"] = arch
		var nm: String = _text(spec.get("name", ""), int(_gd.budgets().max_name_chars))
		if nm != "":
			opts["name"] = nm
		var pid2: String = _builds.create_person(rng, opts)
		warnings.append("registered new person %s (%s)" % [_db.get_record("people", pid2).name, pid2])
		return pid2
	return ""


func _check(raw: Variant, npc_id: String, warnings: Array) -> Dictionary:
	var cfg: Dictionary = _gd.budgets()
	if typeof(raw) != TYPE_DICTIONARY:
		return {"type": "none"}
	match str(raw.get("type", "none")):
		"stat":
			var stat: String = str(raw.get("stat", ""))
			if not Array(cfg.allowed_check_stats).has(stat):
				warnings.append("unknown check stat '%s' -> khi_van" % stat)
				stat = "khi_van"
			var d: float = float(raw.get("difficulty", 50))
			var dc: float = clampf(d, float(cfg.difficulty.min), float(cfg.difficulty.max))
			if dc != d:
				warnings.append("difficulty %s clamped to %s" % [str(d), str(dc)])
			return {"type": "stat", "stat": stat, "difficulty": dc, "evade": bool(raw.get("evade", false))}
		"combat":
			if npc_id == "":
				warnings.append("combat check without an opponent -> Căn cốt check")
				return {"type": "stat", "stat": "can_cot", "difficulty": 50.0}
			return {"type": "combat", "enemy": npc_id}
	return {"type": "none"}


func _outcome(raw: Variant, ctx: Dictionary, warnings: Array, label: String) -> Dictionary:
	if typeof(raw) != TYPE_DICTIONARY:
		return {"text": "", "effects": []}
	return {"text": _text(raw.get("text", ""), int(_gd.budgets().max_text_chars)), "effects": _effects(raw.get("effects", []), ctx, warnings, label)}


func _effects(raw: Variant, ctx: Dictionary, warnings: Array, label: String) -> Array:
	var cfg: Dictionary = _gd.budgets()
	var b: Dictionary = ctx.budget
	var out: Array = []
	if typeof(raw) != TYPE_ARRAY:
		return out
	for fx in raw:
		if out.size() >= int(cfg.max_effects_per_outcome):
			warnings.append("%s: extra effects dropped" % label)
			break
		if typeof(fx) != TYPE_DICTIONARY:
			continue
		var t: String = str(fx.get("type", ""))
		if not Array(cfg.allowed_effect_types).has(t):
			warnings.append("%s: unknown effect '%s' dropped" % [label, t])
			continue
		var e := {"type": t}
		match t:
			"linh_thach":
				e.amount = _clamp_num(float(fx.get("amount", 0)), -float(b.linh_thach_loss_max), float(b.linh_thach_max), "%s linh_thach" % label, warnings, true)
			"tu_vi":
				e.amount = _clamp_num(float(fx.get("amount", 0)), 0.0, float(b.tu_vi_max), "%s tu_vi" % label, warnings, true)
			"khi_huyet_loss_pct":
				e.amount = _clamp_num(float(fx.get("amount", 0)), 0.0, float(b.khi_huyet_loss_pct_max), "%s khi_huyet_loss_pct" % label, warnings, false)
			"tam_ma":
				e.amount = _clamp_num(float(fx.get("amount", 0)), -float(b.tam_ma_max), float(b.tam_ma_max), "%s tam_ma" % label, warnings, false)
			"dan_doc":
				e.amount = _clamp_num(float(fx.get("amount", 0)), -float(b.dan_doc_max), float(b.dan_doc_max), "%s dan_doc" % label, warnings, false)
			"relationship":
				e.amount = _clamp_num(float(fx.get("amount", 0)), -float(b.relationship_max), float(b.relationship_max), "%s relationship" % label, warnings, true)
				e.npc = str(fx.get("npc", "event_npc"))
			"tree_point":
				e.amount = _clamp_num(float(fx.get("amount", 1)), 0.0, float(b.tree_point_max), "%s tree_point" % label, warnings, true)
			"herb":
				e.element = _element(fx.get("element", ""))
				e.herb = str(fx.get("herb", "")) if not _gd.herb(str(fx.get("herb", ""))).is_empty() else ""
				var age_max: float = float(b.herb_age_max)
				if fx.has("age_range"):
					var ar: Array = fx.age_range
					e.age_range = [clampf(float(ar[0]), 0.0, age_max), clampf(float(ar[1]), 0.0, age_max)]
				else:
					var a: float = _clamp_num(float(fx.get("age", 5.0)), 0.0, age_max, "%s herb age" % label, warnings, false)
					e.age_range = [a, a]
				e.rarity_max = clampi(int(fx.get("rarity_max", b.herb_rarity_max)), 1, int(b.herb_rarity_max))
			"material":
				e.element = _element(fx.get("element", ""))
				e.material = str(fx.get("material", "")) if not _gd.material(str(fx.get("material", ""))).is_empty() else ""
				e.rarity_max = clampi(int(fx.get("rarity_max", b.material_rarity_max)), 1, int(b.material_rarity_max))
			"artifact":
				e.element = _element(fx.get("element", ""))
				e.name = _text(fx.get("name", ""), int(cfg.max_name_chars))
				var g_default: int = int(b.artifact_grade_max) + int(cfg.default_artifact_grade_offset)
				var g: int = int(fx.get("grade", g_default + int(fx.get("grade_offset", 0))))
				e.grade = clampi(g, 0, int(b.artifact_grade_max))
				if e.grade != g:
					warnings.append("%s artifact grade %d clamped to %d" % [label, g, e.grade])
			"cong_phap":
				e.element = _element(fx.get("element", ""))
				e.name = _text(fx.get("name", ""), int(cfg.max_name_chars))
				var t_default: int = int(b.cong_phap_tier_max) + int(cfg.default_cong_phap_tier_offset)
				var tr: int = int(fx.get("tier", t_default + int(fx.get("tier_offset", 0))))
				e.tier = clampi(tr, 0, int(b.cong_phap_tier_max))
				if e.tier != tr:
					warnings.append("%s công pháp tier %d clamped to %d" % [label, tr, e.tier])
			"talisman", "breakthrough_pill", "plan_herb":
				var key: String = t if t != "talisman" else "talisman:" + str(fx.get("talisman", ""))
				if t == "talisman" and Talismans.def_of(_gd, str(fx.get("talisman", ""))).is_empty():
					warnings.append("%s: unknown talisman dropped" % label)
					continue
				if Array(cfg.get("co_duyen_effects", [])).has(key) and not _co_duyen_allowed(ctx):
					warnings.append("%s: %s is a cơ duyên gift (edge, bình cảnh, once per realm); dropped" % [label, key])
					continue
				if t == "talisman":
					e.talisman = str(fx.talisman)
			"treasure":
				var tid: String = str(fx.get("treasure", ""))
				if not Array(b.get("treasures", [])).has(tid):
					warnings.append("%s: treasure '%s' not allowed at this realm; dropped" % [label, tid])
					continue
				e.treasure = tid
			"pill":
				var recipe: Dictionary = _gd.recipe(str(fx.get("recipe", "")))
				if recipe.is_empty() or int(recipe.price) > int(b.pill_price_max):
					warnings.append("%s: pill '%s' unknown or over budget; dropped" % [label, str(fx.get("recipe", ""))])
					continue
				e.recipe = recipe.id
		out.append(e)
	return out


func _co_duyen_allowed(ctx: Dictionary) -> bool:
	return bool(ctx.get("edge", false)) and int(ctx.get("co_duyen_left", 0)) > 0 and bool(ctx.player.get("at_bottleneck", false))


func _clamp_num(v: float, lo: float, hi: float, what: String, warnings: Array, round_int: bool) -> float:
	var c: float = clampf(v, lo, hi)
	if round_int:
		c = roundf(c)
	if not is_equal_approx(c, v) and not (round_int and is_equal_approx(c, roundf(v))):
		warnings.append("%s %s clamped to %s" % [what, str(v), str(c)])
	return c


func _element(v: Variant) -> String:
	var s: String = str(v)
	return s if not _gd.element(s).is_empty() else ""


static func _text(v: Variant, max_chars: int) -> String:
	var s: String = str(v).strip_edges() if v != null else ""
	return s.substr(0, max_chars)
