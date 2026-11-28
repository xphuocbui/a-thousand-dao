class_name EventValidator
extends RefCounted
## Normalizes an event proposed by any source (authored template, hook, story, quest stage, or
## LLM JSON) into the engine's canonical event shape, clamping every number to the per-event and
## chain/story budgets, registering any new person in WorldDB before the event can appear,
## enforcing trait-gated [code]show_conditions[/code], and guaranteeing a free exit when every
## choice costs spirit stones (design/gdd/event-engine.md Rules 1, 13, 14, 21, 23; Formulas C).
## Data: events_budgets.json.
##
## Normalized event:
##   {title, text, log, npc_id, place_id, sect_id, source, template_id, kind, hook,
##    story_id, story_instance_id, story_name, story_stage, chain_id, followup_of,
##    illustration, situation, ground_tags, no_heal, mercy_choice, once, once_per_life,
##    once_per_world, cooldown_seasons, npc_capable, newsworthy, choices: [...]}
##
## Usage:
## [codeblock]
## var v := EventValidator.new(gd, db, builds)
## var res: Dictionary = v.normalize(raw_json, ctx, rng, "template:ev_01")
## if res.ok: session.pending_event = res.event
## for w in res.warnings: print("clamped: ", w)
## [/codeblock]

const _EventStore = preload("res://src/gameplay/events/event_store.gd")
const _EventConditions = preload("res://src/gameplay/events/event_conditions.gd")

var _gd: GameData
var _db: WorldDB
var _builds: BuildGenerator


func _init(gd: GameData, db: WorldDB, builds: BuildGenerator) -> void:
	_gd = gd
	_db = db
	_builds = builds


## Normalizes [param raw] into an engine event. Returns [code]{ok, event, warnings, error}[/code].
## Optional [param opts]: [code]{chain_id, max_effects_override, rarity_bonus, env, npc_mode}[/code].
func normalize(raw: Variant, ctx: Dictionary, rng: RandomNumberGenerator, source: String, opts: Dictionary = {}) -> Dictionary:
	var cfg: Dictionary = _gd.budgets()
	var warnings: Array = []
	if typeof(raw) != TYPE_DICTIONARY:
		return {"ok": false, "error": "event is not an object", "warnings": warnings}
	var rd: Dictionary = raw as Dictionary
	var title: String = _text(rd.get("title", ""), int(cfg.max_title_chars))
	var text: String = _text(rd.get("text", ""), int(cfg.max_text_chars))
	if title == "" or text == "":
		return {"ok": false, "error": "missing title or text", "warnings": warnings}
	var raw_choices: Variant = rd.get("choices", [])
	if typeof(raw_choices) != TYPE_ARRAY or (raw_choices as Array).size() < int(cfg.min_choices):
		return {"ok": false, "error": "needs at least %d choices" % int(cfg.min_choices), "warnings": warnings}

	var chain_id: String = str(opts.get("chain_id", rd.get("chain_id", "")))
	var chain_rec: Dictionary = _EventStore.get_chain_budget(_db, chain_id) if (_db != null and chain_id != "") else {}
	var env: Dictionary = Dictionary(opts.get("env", {}))
	var max_fx: int = int(opts.get("max_effects_override", rd.get("max_effects_override", int(cfg.max_effects_per_outcome))))
	if max_fx <= 0:
		max_fx = int(cfg.max_effects_per_outcome)
	var rarity_bonus: int = maxi(0, int(opts.get("rarity_bonus", rd.get("rarity_bonus", 0))))
	var npc_mode: bool = bool(opts.get("npc_mode", false))

	var filtered_raw: Array = []
	for rc in (raw_choices as Array):
		if typeof(rc) != TYPE_DICTIONARY:
			warnings.append("dropped a non-object choice")
			continue
		var rcd: Dictionary = rc as Dictionary
		if not env.is_empty() and rcd.has("show_conditions") and rcd.show_conditions is Dictionary and not (rcd.show_conditions as Dictionary).is_empty():
			if not _EventConditions.evaluate(rcd.show_conditions as Dictionary, env, _gd, _db):
				continue
		filtered_raw.append(rcd)

	if filtered_raw.size() < int(cfg.min_choices):
		return {"ok": false, "error": "too few valid choices", "warnings": warnings}
	if filtered_raw.size() > int(cfg.max_choices):
		warnings.append("choices truncated to %d" % int(cfg.max_choices))
		filtered_raw = filtered_raw.slice(0, int(cfg.max_choices))

	var npc_id: String = _resolve_npc(rd.get("npc"), ctx, rng, warnings)
	var choices: Array = []
	var fx_opts := {
		"chain_id": chain_id,
		"chain_rec": chain_rec,
		"max_effects": max_fx,
		"rarity_bonus": rarity_bonus,
		"npc_mode": npc_mode,
	}
	for rcd in filtered_raw:
		var check: Dictionary = _check(rcd.get("check", {}), npc_id, rd, warnings)
		var suc_raw: Variant = rcd.get("success", {})
		var fail_raw: Variant = rcd.get("failure", suc_raw)
		var ch_out := {
			"label": _text(rcd.get("label", "?"), int(cfg.max_title_chars)),
			"tags": _choice_tags(rcd.get("tags", []), cfg),
			"trait_badge": str(rcd.get("trait_badge", "")),
			"check": check,
			"always": _effects(rcd.get("always", []), ctx, warnings, "always", fx_opts),
			"success": _outcome(suc_raw, ctx, warnings, "success", fx_opts),
			"failure": _outcome(fail_raw, ctx, warnings, "failure", fx_opts),
		}
		if rcd.has("show_conditions") and rcd.show_conditions is Dictionary:
			ch_out["show_conditions"] = (rcd.show_conditions as Dictionary).duplicate(true)
		choices.append(ch_out)
	if choices.size() < int(cfg.min_choices):
		return {"ok": false, "error": "too few valid choices", "warnings": warnings}

	# Every event must be answerable by a player with no linh thạch, or it would block
	# all time-consuming actions forever (softlock).
	var free_exists: bool = choices.any(func(ch): return not ch.always.any(func(fx): return fx.type == "linh_thach" and float(fx.amount) < 0.0))
	if not free_exists:
		var exit: Dictionary = cfg.free_exit_choice
		choices.append({
			"label": str(exit.label),
			"tags": ["cautious"],
			"trait_badge": "",
			"check": {"type": "none"},
			"always": [],
			"success": {"text": str(exit.text), "empty_text": "", "hidden": false, "deadly": false, "effects": []},
			"failure": {"text": str(exit.text), "empty_text": "", "hidden": false, "deadly": false, "effects": []},
		})
		warnings.append("every choice had a cost; added a free exit")

	var event := {
		"title": title,
		"text": text,
		"log": _text(rd.get("log", ""), int(cfg.max_text_chars)),
		"npc_id": npc_id,
		"place_id": str(Dictionary(ctx.get("place", {})).get("id", "")),
		"sect_id": str(rd.get("sect_id", Dictionary(ctx.get("sect", {})).get("id", ""))),
		"source": source,
		"template_id": str(rd.get("template_id", rd.get("id", ""))),
		"kind": str(rd.get("kind", "hook" if str(rd.get("hook", "")) != "" else "pulse")),
		"hook": str(rd.get("hook", "")),
		"story_id": str(rd.get("story_id", "")),
		"story_instance_id": str(rd.get("story_instance_id", "")),
		"story_name": str(rd.get("story_name", "")),
		"story_stage": str(rd.get("story_stage", "")),
		"chain_id": chain_id,
		"followup_of": str(rd.get("followup_of", "")),
		"illustration": str(rd.get("illustration", "")),
		"situation": str(rd.get("situation", "")),
		"ground_tags": Array(rd.get("ground_tags", [])).duplicate(),
		"no_heal": bool(rd.get("no_heal", false)),
		"mercy_choice": bool(rd.get("mercy_choice", false)),
		"once": bool(rd.get("once", false)),
		"once_per_life": bool(rd.get("once_per_life", rd.get("once", false))),
		"once_per_world": bool(rd.get("once_per_world", false)),
		"cooldown_seasons": int(rd.get("cooldown_seasons", cfg.get("pacing", {}).get("default_cooldown_seasons", 8))),
		"npc_capable": bool(rd.get("npc_capable", false)),
		"newsworthy": bool(rd.get("newsworthy", false)),
		"choices": choices,
	}
	return {"ok": true, "event": event, "warnings": warnings, "error": ""}


func _resolve_npc(npc: Variant, ctx: Dictionary, rng: RandomNumberGenerator, warnings: Array) -> String:
	if typeof(npc) != TYPE_DICTIONARY:
		return ""
	var nd: Dictionary = npc as Dictionary
	if nd.has("existing_id"):
		var pid: String = str(nd.existing_id)
		var rec: Dictionary = _db.get_record("people", pid)
		if rec.is_empty() or not rec.alive or rec.get("is_player", false):
			warnings.append("npc %s does not exist or is dead; dropped" % pid)
			return ""
		return pid
	if nd.has("id_resolved"):
		return str(nd.id_resolved)
	if nd.has("new") and typeof(nd.new) == TYPE_DICTIONARY:
		var spec: Dictionary = nd.new
		var off_cfg: Dictionary = _gd.budgets().npc_realm_offset
		var offset: int = clampi(int(spec.get("realm_offset", 0)), int(off_cfg.min), int(off_cfg.max))
		if offset != int(spec.get("realm_offset", 0)):
			warnings.append("npc realm_offset clamped to %d" % offset)
		var arch: String = str(spec.get("archetype", ""))
		if _gd.archetype(arch).is_empty():
			arch = ""
		var opts := {
			"realm_index": clampi(int(ctx.player.realm_index) + offset, 0, _gd.realms().size() - 1),
			"location_id": ctx.place.id,
			"created_by": "llm",
			"is_beast": bool(spec.get("is_beast", false)),
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


func _check(raw: Variant, npc_id: String, event_raw: Dictionary, warnings: Array) -> Dictionary:
	var cfg: Dictionary = _gd.budgets()
	if typeof(raw) != TYPE_DICTIONARY:
		return {"type": "none"}
	var cd: Dictionary = raw as Dictionary
	match str(cd.get("type", "none")):
		"stat":
			var stat: String = str(cd.get("stat", ""))
			if not Array(cfg.allowed_check_stats).has(stat):
				warnings.append("unknown check stat '%s' -> khi_van" % stat)
				stat = "khi_van"
			var d: float = float(cd.get("difficulty", 50))
			var dc: float = clampf(d, float(cfg.difficulty.min), float(cfg.difficulty.max))
			if dc != d:
				warnings.append("difficulty %s clamped to %s" % [str(d), str(dc)])
			return {"type": "stat", "stat": stat, "difficulty": dc, "evade": bool(cd.get("evade", false))}
		"combat":
			var enemy_id: String = npc_id
			var raw_enemy: String = str(cd.get("enemy", ""))
			if raw_enemy != "" and raw_enemy != "event_npc" and raw_enemy != "other" and _db != null and _db.has_record("people", raw_enemy):
				enemy_id = raw_enemy
			if enemy_id == "":
				warnings.append("combat check without an opponent -> Căn cốt check")
				return {"type": "stat", "stat": "can_cot", "difficulty": 50.0}
			var out_c := {
				"type": "combat",
				"enemy": enemy_id,
				"situation": str(cd.get("situation", event_raw.get("situation", "foreseen"))),
				"ground_tags": Array(cd.get("ground_tags", event_raw.get("ground_tags", []))).duplicate(),
				"no_heal": bool(cd.get("no_heal", event_raw.get("no_heal", false))),
				"mercy_allowed": bool(cd.get("mercy_allowed", event_raw.get("mercy_choice", false))),
			}
			return out_c
	return {"type": "none"}


func _outcome(raw: Variant, ctx: Dictionary, warnings: Array, label: String, fx_opts: Dictionary) -> Dictionary:
	if typeof(raw) != TYPE_DICTIONARY:
		return {"text": "", "empty_text": "", "hidden": false, "deadly": false, "effects": []}
	var rd: Dictionary = raw as Dictionary
	var max_t: int = int(_gd.budgets().max_text_chars)
	return {
		"text": _text(rd.get("text", ""), max_t),
		"empty_text": _text(rd.get("empty_text", ""), max_t),
		"hidden": bool(rd.get("hidden", false)),
		"deadly": bool(rd.get("deadly", false)),
		"effects": _effects(rd.get("effects", []), ctx, warnings, label, fx_opts),
	}


func _effects(raw: Variant, ctx: Dictionary, warnings: Array, label: String, fx_opts: Dictionary = {}) -> Array:
	var cfg: Dictionary = _gd.budgets()
	var b: Dictionary = ctx.budget
	var out: Array = []
	if typeof(raw) != TYPE_ARRAY:
		return out
	var max_fx: int = int(fx_opts.get("max_effects", int(cfg.max_effects_per_outcome)))
	var chain_rec: Dictionary = Dictionary(fx_opts.get("chain_rec", {}))
	var chain_left: Dictionary = Dictionary(chain_rec.get("left", {}))
	var chain_items_used: int = int(chain_rec.get("items_used", 0))
	var chain_items_max: int = int(chain_rec.get("items_max", 999))
	var item_types: Array = Array(cfg.get("item_effect_types", ["herb", "material", "artifact", "cong_phap", "pill", "talisman", "treasure"]))
	var player_only: Array = Array(cfg.get("player_only_effects", []))
	var npc_mode: bool = bool(fx_opts.get("npc_mode", false))
	var rarity_bonus_base: int = int(fx_opts.get("rarity_bonus", 0))

	for fx in raw:
		if out.size() >= max_fx:
			warnings.append("%s: extra effects dropped" % label)
			break
		if typeof(fx) != TYPE_DICTIONARY:
			continue
		var fxd: Dictionary = fx as Dictionary
		var t: String = str(fxd.get("type", ""))
		if not Array(cfg.allowed_effect_types).has(t):
			warnings.append("%s: unknown effect '%s' dropped" % [label, t])
			continue
		if npc_mode:
			var po_key: String = t if t != "talisman" else ("talisman:" + str(fxd.get("talisman", "")))
			if player_only.has(t) or player_only.has(po_key):
				warnings.append("%s: player-only effect '%s' dropped in NPC mode" % [label, po_key])
				continue
		if not chain_rec.is_empty() and item_types.has(t) and chain_items_used >= chain_items_max:
			warnings.append("%s: item effect '%s' dropped (chain item cap %d reached)" % [label, t, chain_items_max])
			continue

		var e := {"type": t}
		var rb_bonus: int = maxi(rarity_bonus_base, int(fxd.get("rarity_bonus", 0)))
		match t:
			"linh_thach":
				var lt_hi: float = float(b.linh_thach_max)
				if not chain_rec.is_empty():
					lt_hi = minf(lt_hi, maxf(0.0, float(chain_left.get("linh_thach", lt_hi))))
				e.amount = _clamp_num(float(fxd.get("amount", 0)), -float(b.linh_thach_loss_max), lt_hi, "%s linh_thach" % label, warnings, true)
				if fxd.has("source") and str(fxd.source) != "":
					e["source"] = str(fxd.source)
				if fxd.has("npc") and str(fxd.npc) != "":
					e["npc"] = str(fxd.npc)
			"tu_vi":
				var tv_hi: float = float(b.tu_vi_max)
				if not chain_rec.is_empty():
					tv_hi = minf(tv_hi, maxf(0.0, float(chain_left.get("tu_vi", tv_hi))))
				e.amount = _clamp_num(float(fxd.get("amount", 0)), 0.0, tv_hi, "%s tu_vi" % label, warnings, true)
			"khi_huyet_loss_pct":
				e.amount = _clamp_num(float(fxd.get("amount", 0)), 0.0, float(b.khi_huyet_loss_pct_max), "%s khi_huyet_loss_pct" % label, warnings, false)
			"tam_ma":
				e.amount = _clamp_num(float(fxd.get("amount", 0)), -float(b.tam_ma_max), float(b.tam_ma_max), "%s tam_ma" % label, warnings, false)
			"dan_doc":
				e.amount = _clamp_num(float(fxd.get("amount", 0)), -float(b.dan_doc_max), float(b.dan_doc_max), "%s dan_doc" % label, warnings, false)
			"relationship":
				e.amount = _clamp_num(float(fxd.get("amount", 0)), -float(b.relationship_max), float(b.relationship_max), "%s relationship" % label, warnings, true)
				e.npc = str(fxd.get("npc", "event_npc"))
			"tree_point":
				e.amount = _clamp_num(float(fxd.get("amount", 1)), 0.0, float(b.tree_point_max), "%s tree_point" % label, warnings, true)
			"herb":
				e.element = _element(fxd.get("element", ""))
				e.herb = str(fxd.get("herb", "")) if not _gd.herb(str(fxd.get("herb", ""))).is_empty() else ""
				var age_max: float = float(b.herb_age_max)
				if fxd.has("age_range"):
					var ar: Array = fxd.age_range
					e.age_range = [clampf(float(ar[0]), 0.0, age_max), clampf(float(ar[1]), 0.0, age_max)]
				else:
					var a: float = _clamp_num(float(fxd.get("age", 5.0)), 0.0, age_max, "%s herb age" % label, warnings, false)
					e.age_range = [a, a]
				var h_rar_cap: int = mini(6, int(b.herb_rarity_max) + rb_bonus)
				e.rarity_max = clampi(int(fxd.get("rarity_max", h_rar_cap)), 1, h_rar_cap)
			"material":
				e.element = _element(fxd.get("element", ""))
				e.material = str(fxd.get("material", "")) if not _gd.material(str(fxd.get("material", ""))).is_empty() else ""
				var m_rar_cap: int = mini(6, int(b.material_rarity_max) + rb_bonus)
				e.rarity_max = clampi(int(fxd.get("rarity_max", m_rar_cap)), 1, m_rar_cap)
			"artifact":
				e.element = _element(fxd.get("element", ""))
				e.name = _text(fxd.get("name", ""), int(cfg.max_name_chars))
				var g_cap: int = mini(5, int(b.artifact_grade_max) + rb_bonus)
				var g_default: int = int(b.artifact_grade_max) + int(cfg.default_artifact_grade_offset)
				var g: int = int(fxd.get("grade", g_default + int(fxd.get("grade_offset", 0))))
				e.grade = clampi(g, 0, g_cap)
				if e.grade != g:
					warnings.append("%s artifact grade %d clamped to %d" % [label, g, e.grade])
			"cong_phap":
				e.element = _element(fxd.get("element", ""))
				e.name = _text(fxd.get("name", ""), int(cfg.max_name_chars))
				var t_cap: int = mini(4, int(b.cong_phap_tier_max) + rb_bonus)
				var t_default: int = int(b.cong_phap_tier_max) + int(cfg.default_cong_phap_tier_offset)
				var tr: int = int(fxd.get("tier", t_default + int(fxd.get("tier_offset", 0))))
				e.tier = clampi(tr, 0, t_cap)
				if e.tier != tr:
					warnings.append("%s công pháp tier %d clamped to %d" % [label, tr, e.tier])
			"talisman", "breakthrough_pill", "plan_herb":
				var key: String = t if t != "talisman" else "talisman:" + str(fxd.get("talisman", ""))
				if t == "talisman" and Talismans.def_of(_gd, str(fxd.get("talisman", ""))).is_empty():
					warnings.append("%s: unknown talisman dropped" % label)
					continue
				if Array(cfg.get("co_duyen_effects", [])).has(key) and not _co_duyen_allowed(ctx):
					warnings.append("%s: %s is a cơ duyên gift (edge, bình cảnh, once per realm); dropped" % [label, key])
					continue
				if t == "talisman":
					e.talisman = str(fxd.talisman)
			"treasure":
				var tid: String = str(fxd.get("treasure", ""))
				if not Array(b.get("treasures", [])).has(tid):
					warnings.append("%s: treasure '%s' not allowed at this realm; dropped" % [label, tid])
					continue
				e.treasure = tid
			"pill":
				var recipe: Dictionary = _gd.recipe(str(fxd.get("recipe", "")))
				if recipe.is_empty() or int(recipe.price) > int(b.pill_price_max):
					warnings.append("%s: pill '%s' unknown or over budget; dropped" % [label, str(fxd.get("recipe", ""))])
					continue
				e.recipe = recipe.id
			"tie_add", "tie_strengthen", "tie_weaken", "tie_end":
				e["kind"] = str(fxd.get("kind", "friend"))
				e["holder"] = str(fxd.get("holder", "npc"))
				e["delta"] = int(fxd.get("delta", 20))
				e["npc"] = str(fxd.get("npc", "event_npc"))
				if fxd.has("reason"):
					e["reason"] = str(fxd.reason)
				if fxd.has("authored"):
					e["authored"] = bool(fxd.authored)
			"set_flag":
				e["scope"] = str(fxd.get("scope", "root"))
				e["flag"] = str(fxd.get("flag", ""))
				e["value"] = fxd.get("value", true)
				e["expires_seasons"] = int(fxd.get("expires_seasons", -1))
			"clear_flag":
				e["scope"] = str(fxd.get("scope", "root"))
				e["flag"] = str(fxd.get("flag", ""))
			"var_add":
				e["scope"] = str(fxd.get("scope", "root"))
				e["var"] = str(fxd.get("var", ""))
				e["amount"] = int(fxd.get("amount", 0))
				if fxd.has("min"):
					e["min"] = int(fxd.min)
				if fxd.has("max"):
					e["max"] = int(fxd.max)
			"var_set":
				e["scope"] = str(fxd.get("scope", "root"))
				e["var"] = str(fxd.get("var", ""))
				e["value"] = int(fxd.get("value", 0))
				if fxd.has("min"):
					e["min"] = int(fxd.min)
				if fxd.has("max"):
					e["max"] = int(fxd.max)
			"schedule_followup":
				e["event_id"] = str(fxd.get("event_id", ""))
				e["target_root"] = str(fxd.get("target_root", "root"))
				e["delay_seasons"] = fxd.get("delay_seasons", [2, 4])
				e["wait_seasons"] = int(fxd.get("wait_seasons", cfg.get("pacing", {}).get("default_wait_seasons", 4)))
				if fxd.has("hook"):
					e["hook"] = str(fxd.hook)
				if fxd.has("hook_place_id"):
					e["hook_place_id"] = str(fxd.hook_place_id)
				if fxd.has("scopes") and fxd.scopes is Dictionary:
					e["scopes"] = (fxd.scopes as Dictionary).duplicate(true)
			"story_start":
				e["story_id"] = str(fxd.get("story_id", ""))
				if fxd.has("scopes") and fxd.scopes is Dictionary:
					e["scopes"] = (fxd.scopes as Dictionary).duplicate(true)
			"story_stage":
				e["story_id"] = str(fxd.get("story_id", ""))
				e["stage"] = str(fxd.get("stage", ""))
			"story_end":
				e["story_id"] = str(fxd.get("story_id", ""))
				e["status"] = str(fxd.get("status", "done"))
			"grant_trait", "remove_trait":
				e["trait"] = str(fxd.get("trait", ""))
				e["scope"] = str(fxd.get("scope", "root"))
				if fxd.has("target"):
					e["target"] = str(fxd.target)
			"trait_trigger":
				e["trigger"] = str(fxd.get("trigger", fxd.get("id", "")))
				e["scope"] = str(fxd.get("scope", "root"))
			"sect_standing":
				e["amount"] = _clamp_num(float(fxd.get("amount", 0)), -30.0, 30.0, "%s sect_standing" % label, warnings, false)
				if fxd.has("sect"):
					e["sect"] = str(fxd.sect)
			"sect_loyalty":
				e["amount"] = _clamp_num(float(fxd.get("amount", 0)), -30.0, 30.0, "%s sect_loyalty" % label, warnings, false)
				if fxd.has("sect"):
					e["sect"] = str(fxd.sect)
			"sect_attitude":
				e["amount"] = _clamp_num(float(fxd.get("amount", 0)), -30.0, 30.0, "%s sect_attitude" % label, warnings, false)
				if fxd.has("sect"):
					e["sect"] = str(fxd.sect)
				if fxd.has("other_sect"):
					e["other_sect"] = str(fxd.other_sect)
			"market_shock":
				e["good_kind"] = str(fxd.get("good_kind", fxd.get("class_id", "herb")))
				e["delta"] = clampf(float(fxd.get("delta", 0.2)), -0.5, 0.5)
				e["duration_seasons"] = clampi(int(fxd.get("duration_seasons", 2)), 1, 8)
				if fxd.has("sect"):
					e["sect"] = str(fxd.sect)
			"clue":
				e["kind"] = str(fxd.get("kind", "rumour"))
				if fxd.has("region_id"):
					e["region_id"] = str(fxd.region_id)
				if fxd.has("slot"):
					e["slot"] = str(fxd.slot)
			"reveal_place":
				if fxd.has("place_id"):
					e["place_id"] = str(fxd.place_id)
				if fxd.has("slot"):
					e["slot"] = str(fxd.slot)
			"scar":
				e["d_density"] = clampf(float(fxd.get("d_density", -0.05)), -0.3, 0.3)
				e["push"] = Dictionary(fxd.get("push", {})).duplicate(true)
				e["cause"] = _text(fxd.get("cause", ""), int(cfg.max_title_chars))
				if fxd.has("place_id"):
					e["place_id"] = str(fxd.place_id)
			"uncover_chronicle":
				e["chronicle_id"] = str(fxd.get("chronicle_id", ""))
			"quest_boon":
				e["quest_id"] = str(fxd.get("quest_id", ""))
				e["title"] = _text(fxd.get("title", ""), int(cfg.max_title_chars))
				e["mods"] = Array(fxd.get("mods", [])).duplicate(true)
				e["tree_points"] = maxi(0, int(fxd.get("tree_points", 0)))
			"access":
				e["key"] = str(fxd.get("key", fxd.get("target", fxd.get("place_id", ""))))
				e["expires_seasons"] = int(fxd.get("expires_seasons", -1))
		out.append(e)
	return out


func _co_duyen_allowed(ctx: Dictionary) -> bool:
	return bool(ctx.get("edge", false)) and int(ctx.get("co_duyen_left", 0)) > 0 and bool(ctx.player.get("at_bottleneck", false))


func _choice_tags(raw: Variant, cfg: Dictionary) -> Array:
	var out: Array = []
	if not (raw is Array):
		return out
	var allowed: Array = Array(cfg.get("allowed_choice_tags", []))
	for tag in (raw as Array):
		var ts: String = str(tag)
		if allowed.is_empty() or allowed.has(ts):
			out.append(ts)
	return out


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
