class_name InteractionValidator
extends RefCounted
## Validates NPC Interaction & Dialogue (#30) data files: [code]npc_interactions.json[/code],
## [code]npc_dialogue_lines.json[/code], interaction event references in [code]events_templates.json[/code],
## and 1:1 parity against [code]traits.json["verb_hooks"][/code] (AC-NI-04, AC-NI-26).
##
## Usage:
## [codeblock]
## var errs: Array = InteractionValidator.validate(gd)
## assert(errs.is_empty(), "\n".join(errs))
## [/codeblock]

## Data file id for interaction verbs and tuning knobs.
const INTERACTIONS_FILE := "npc_interactions"
## Data file id for the non-LLM dialogue voice line library.
const LINES_FILE := "npc_dialogue_lines"
## Data file id for event templates.
const TEMPLATES_FILE := "events_templates"
## Allowed verb menu groups (GDD Rule 5).
const VALID_GROUPS := ["social", "favour", "conflict", "bond"]
## Allowed trait verb hook sides (NPC Traits Rule 8a).
const VALID_SIDES := ["self", "other", "either"]
## Canonical attitude bands in ascending order (GDD Rule 13).
const VALID_BANDS := ["hostile", "cold", "neutral", "warm", "friendly", "close"]
## Required keys in [code]npc_dialogue_lines.json["address_table"][/code] (GDD Rule 17).
const REQUIRED_ADDRESS_KEYS := [
	"hostile_or_haughty", "master_to_disciple", "disciple_to_master", "dao_lu",
	"ket_nghia_senior", "ket_nghia_junior", "same_sect_senior", "same_sect_junior",
	"same_sect_peer", "senior", "junior", "peer",
]
## Required numeric tuning knobs in [code]npc_interactions.json["knobs"][/code].
const REQUIRED_KNOBS := [
	"interactions_per_person_per_season", "k_att", "k_pr", "k_tr", "k_st", "k_ch",
	"greet_gain", "gift_gain", "attitude_change_max", "notable_gift_share",
	"ins_base", "spar_loss_share", "k_th", "threat_p_min", "threat_p_max",
	"loan_share", "loan_term", "loan_overdue", "loan_early_repay_att",
	"yearly_drift_step", "f7_tm_a", "f7_tm_cap", "f7_st_a",
	"f7_in_char_discount", "f7_in_char_max_traits", "haggle_buy_mult",
	"haggle_sell_mult", "wager_max_share", "hostile_threshold",
	"friendly_threshold", "relationship_min", "relationship_max",
]


## Validates interaction verbs, dialogue lines, trait hook parity, and interaction event template refs.
## Returns an Array of descriptive error strings (empty when valid). Optional raw overrides allow
## unit tests to validate mutated copies without altering [param gd].
static func validate(gd: GameData, raw_interactions: Variant = null, raw_lines: Variant = null, raw_templates: Variant = null) -> Array:
	var errors: Array = []
	var inter: Dictionary = _resolve_dict(gd, INTERACTIONS_FILE, raw_interactions)
	var lines_doc: Dictionary = _resolve_dict(gd, LINES_FILE, raw_lines)
	var tpl_doc: Dictionary = _resolve_dict(gd, TEMPLATES_FILE, raw_templates)
	if inter.is_empty():
		errors.append("%s: missing or empty file" % INTERACTIONS_FILE)
		return errors
	if lines_doc.is_empty():
		errors.append("%s: missing or empty file" % LINES_FILE)
		return errors

	_validate_knobs(inter, errors)

	var allowed_conds := _to_set(Array(inter.get("allowed_conditions", [])))
	var allowed_effects := _to_set(Array(inter.get("allowed_effects", [])))
	if allowed_conds.is_empty():
		errors.append("%s: allowed_conditions must not be empty" % INTERACTIONS_FILE)
	if allowed_effects.is_empty():
		errors.append("%s: allowed_effects must not be empty" % INTERACTIONS_FILE)

	var traits_doc: Dictionary = gd.file(NpcTraits.FILE) if gd != null and gd.registry.has_file(NpcTraits.FILE) else {}
	var trait_tags := _collect_trait_tags(traits_doc)
	var trait_ids := _collect_trait_ids(traits_doc)
	var cast_keys := _collect_cast_keys(gd)

	var verbs_by_id: Dictionary = _validate_verbs(inter, allowed_conds, allowed_effects, trait_tags, trait_ids, errors)
	_validate_trait_hook_parity(verbs_by_id, traits_doc, errors)
	_validate_lines(lines_doc, verbs_by_id, traits_doc, cast_keys, errors)
	_validate_interaction_events(gd, inter, tpl_doc, cast_keys, errors)
	return errors


## Alias of [method validate] matching the Dialogue #30 technical blueprint name.
static func validate_all(gd: GameData, raw_interactions: Variant = null, raw_lines: Variant = null, raw_templates: Variant = null) -> Array:
	return validate(gd, raw_interactions, raw_lines, raw_templates)


static func _resolve_dict(gd: GameData, file_id: String, raw: Variant) -> Dictionary:
	if raw != null:
		return raw as Dictionary if typeof(raw) == TYPE_DICTIONARY else {}
	if gd == null or not gd.registry.has_file(file_id):
		return {}
	return gd.file(file_id)


static func _to_set(arr: Array) -> Dictionary:
	var out := {}
	for item in arr:
		var s: String = str(item)
		if s != "":
			out[s] = true
	return out


static func _collect_trait_tags(traits_doc: Dictionary) -> Dictionary:
	var tags := {}
	for kind in NpcTraits.ALL_KINDS:
		for item in traits_doc.get(kind, []):
			if item is Dictionary:
				for k in Dictionary(item.get("tags", {})).keys():
					tags[str(k)] = true
	return tags


static func _collect_trait_ids(traits_doc: Dictionary) -> Dictionary:
	var ids := {}
	for kind in NpcTraits.ALL_KINDS:
		for item in traits_doc.get(kind, []):
			if item is Dictionary and str(item.get("id", "")) != "":
				ids[str(item.id)] = true
	return ids


static func _collect_cast_keys(gd: GameData) -> Dictionary:
	var keys := {}
	if gd == null or not gd.registry.has_file("world_history"):
		return keys
	var wh: Dictionary = gd.file("world_history")
	for p in wh.get("people", []):
		if p is Dictionary:
			var ck: String = str(p.get("key", p.get("cast_key", "")))
			if ck != "":
				keys[ck] = true
	return keys


static func _validate_knobs(inter: Dictionary, errors: Array) -> void:
	var knobs: Variant = inter.get("knobs", {})
	if typeof(knobs) != TYPE_DICTIONARY:
		errors.append("%s: knobs must be an object" % INTERACTIONS_FILE)
		return
	var k: Dictionary = knobs as Dictionary
	for name in REQUIRED_KNOBS:
		if not k.has(name):
			errors.append("%s: missing knob '%s'" % [INTERACTIONS_FILE, name])
	if int(k.get("interactions_per_person_per_season", 0)) < 1:
		errors.append("%s: interactions_per_person_per_season must be >= 1" % INTERACTIONS_FILE)
	if float(k.get("threat_p_min", 0.0)) >= float(k.get("threat_p_max", 0.0)):
		errors.append("%s: threat_p_min must be < threat_p_max" % INTERACTIONS_FILE)
	if int(k.get("loan_term", 0)) < 1:
		errors.append("%s: loan_term must be >= 1" % INTERACTIONS_FILE)
	if float(k.get("loan_share", 0.0)) <= 0.0:
		errors.append("%s: loan_share must be > 0" % INTERACTIONS_FILE)
	var bands: Variant = k.get("attitude_bands", [])
	if typeof(bands) != TYPE_ARRAY or (bands as Array).size() != VALID_BANDS.size():
		errors.append("%s: knobs.attitude_bands must define %d bands" % [INTERACTIONS_FILE, VALID_BANDS.size()])
	else:
		var prev: int = -999999
		for i in VALID_BANDS.size():
			var row: Variant = (bands as Array)[i]
			if typeof(row) != TYPE_ARRAY or (row as Array).size() < 2:
				errors.append("%s: attitude_bands[%d] must be [min, name]" % [INTERACTIONS_FILE, i])
				continue
			var lo: int = int((row as Array)[0])
			var bname: String = str((row as Array)[1])
			if lo < prev:
				errors.append("%s: attitude_bands[%d] threshold %d is out of order" % [INTERACTIONS_FILE, i, lo])
			prev = lo
			if bname != VALID_BANDS[i]:
				errors.append("%s: attitude_bands[%d] expected '%s', got '%s'" % [INTERACTIONS_FILE, i, VALID_BANDS[i], bname])


static func _validate_verbs(inter: Dictionary, allowed_conds: Dictionary, allowed_effects: Dictionary, trait_tags: Dictionary, trait_ids: Dictionary, errors: Array) -> Dictionary:
	var verbs_by_id := {}
	var verbs: Variant = inter.get("verbs", [])
	if typeof(verbs) != TYPE_ARRAY or (verbs as Array).is_empty():
		errors.append("%s: verbs must be a non-empty array" % INTERACTIONS_FILE)
		return verbs_by_id
	for idx in (verbs as Array).size():
		var raw_v: Variant = (verbs as Array)[idx]
		if typeof(raw_v) != TYPE_DICTIONARY:
			errors.append("%s: verbs[%d] must be an object" % [INTERACTIONS_FILE, idx])
			continue
		var v: Dictionary = raw_v as Dictionary
		var vid: String = str(v.get("id", "")).strip_edges()
		if vid == "":
			errors.append("%s: verbs[%d] missing id" % [INTERACTIONS_FILE, idx])
			continue
		if verbs_by_id.has(vid):
			errors.append("verb '%s': duplicate verb id" % vid)
			continue
		verbs_by_id[vid] = v
		if str(v.get("name", "")).strip_edges() == "" or str(v.get("name_vi", "")).strip_edges() == "":
			errors.append("verb '%s': missing name or name_vi" % vid)
		var grp: String = str(v.get("group", ""))
		if not VALID_GROUPS.has(grp):
			errors.append("verb '%s': unknown group '%s'" % [vid, grp])
		var tm: float = float(v.get("time", 0.0))
		if tm < 0.0 or tm > 1.0:
			errors.append("verb '%s': time %.3f outside 0..1" % [vid, tm])
		if int(v.get("cooldown", 0)) < 0:
			errors.append("verb '%s': negative cooldown" % vid)
		for tag in Array(v.get("tags", [])):
			var ts: String = str(tag)
			if not trait_tags.is_empty() and not trait_tags.has(ts):
				errors.append("verb '%s': unknown trait tag '%s'" % [vid, ts])
		for req in Array(v.get("requirements", [])):
			if typeof(req) != TYPE_DICTIONARY:
				errors.append("verb '%s': requirement entry must be an object" % vid)
				continue
			var ctype: String = str((req as Dictionary).get("type", ""))
			if not allowed_conds.has(ctype):
				errors.append("verb '%s': unknown condition '%s'" % [vid, ctype])
		for eff_list_key in ["accept_effects", "refuse_effects"]:
			for fx in Array(v.get(eff_list_key, [])):
				if typeof(fx) != TYPE_DICTIONARY:
					errors.append("verb '%s': %s entry must be an object" % [vid, eff_list_key])
					continue
				var etype: String = str((fx as Dictionary).get("type", ""))
				if not allowed_effects.has(etype):
					errors.append("verb '%s': unknown effect '%s' in %s" % [vid, etype, eff_list_key])
		var hook: String = str(v.get("trait_hook", ""))
		if hook != "":
			if hook != "verb:" + vid:
				errors.append("verb '%s': trait_hook '%s' must equal 'verb:%s'" % [vid, hook, vid])
			var side: String = str(v.get("side", ""))
			if not VALID_SIDES.has(side):
				errors.append("verb '%s': invalid side '%s'" % [vid, side])
			var src_trait: String = str(v.get("source_trait", ""))
			if src_trait == "":
				errors.append("verb '%s': trait verb missing source_trait" % vid)
			elif not trait_ids.is_empty() and not trait_ids.has(src_trait):
				errors.append("verb '%s': unknown source_trait '%s'" % [vid, src_trait])
	return verbs_by_id


static func _validate_trait_hook_parity(verbs_by_id: Dictionary, traits_doc: Dictionary, errors: Array) -> void:
	if traits_doc.is_empty():
		return
	var hooks: Array = Array(traits_doc.get("verb_hooks", []))
	var expected := {}
	for h in hooks:
		if not (h is Dictionary):
			continue
		var hid: String = str(h.get("id", ""))
		var htrait: String = str(h.get("trait", ""))
		var hside: String = str(h.get("side", ""))
		expected[hid] = h
		if not verbs_by_id.has(hid):
			errors.append("trait verb_hook '%s' (trait '%s', side '%s'): missing verb record in %s" % [hid, htrait, hside, INTERACTIONS_FILE])
			continue
		var v: Dictionary = verbs_by_id[hid]
		if str(v.get("trait_hook", "")) != "verb:" + hid:
			errors.append("verb '%s': expected trait_hook 'verb:%s'" % [hid, hid])
		if str(v.get("source_trait", "")) != htrait:
			errors.append("verb '%s': source_trait '%s' does not match traits.json '%s'" % [hid, str(v.get("source_trait", "")), htrait])
		if str(v.get("side", "")) != hside:
			errors.append("verb '%s': side '%s' does not match traits.json '%s'" % [hid, str(v.get("side", "")), hside])
	for vid in verbs_by_id.keys():
		var v: Dictionary = verbs_by_id[vid]
		if str(v.get("trait_hook", "")) != "" and not expected.has(vid):
			errors.append("verb '%s': defines trait_hook '%s' absent from traits.json verb_hooks" % [vid, str(v.trait_hook)])


static func _validate_lines(lines_doc: Dictionary, verbs_by_id: Dictionary, traits_doc: Dictionary, cast_keys: Dictionary, errors: Array) -> void:
	var tones_set := _to_set(Array(lines_doc.get("tones", [])))
	if tones_set.is_empty():
		errors.append("%s: tones must be a non-empty array" % LINES_FILE)
	var tone_map: Dictionary = Dictionary(lines_doc.get("tone_by_trait", {}))
	for p in traits_doc.get("personality", []):
		if p is Dictionary:
			var pid: String = str(p.get("id", ""))
			if pid == "":
				continue
			if not tone_map.has(pid):
				errors.append("%s: tone_by_trait missing personality trait '%s'" % [LINES_FILE, pid])
			else:
				var tn: String = str(tone_map[pid])
				if not tones_set.is_empty() and not tones_set.has(tn):
					errors.append("%s: tone_by_trait['%s'] uses unknown tone '%s'" % [LINES_FILE, pid, tn])
	var addr: Dictionary = Dictionary(lines_doc.get("address_table", {}))
	for req_key in REQUIRED_ADDRESS_KEYS:
		if not addr.has(req_key) or typeof(addr[req_key]) != TYPE_DICTIONARY:
			errors.append("%s: address_table missing '%s'" % [LINES_FILE, req_key])

	var allowed_tokens := _to_set(Array(lines_doc.get("supported_tokens", [])))
	var lines_by_verb: Dictionary = Dictionary(lines_doc.get("lines", {}))
	for vid in verbs_by_id.keys():
		var v: Dictionary = verbs_by_id[vid]
		var req_results: Array = Array(v.get("required_results", ["accept", "refuse"]))
		if not lines_by_verb.has(vid) or typeof(lines_by_verb[vid]) != TYPE_DICTIONARY:
			errors.append("verb '%s': missing entry in %s.lines" % [vid, LINES_FILE])
			continue
		var v_lines: Dictionary = lines_by_verb[vid]
		for res in req_results:
			var rkey: String = str(res)
			if not v_lines.has(rkey) or typeof(v_lines[rkey]) != TYPE_DICTIONARY:
				errors.append("verb '%s': missing result '%s' in %s.lines" % [vid, rkey, LINES_FILE])
				continue
			var r_dict: Dictionary = v_lines[rkey]
			var gen: Variant = r_dict.get("generic", [])
			if typeof(gen) != TYPE_ARRAY or (gen as Array).is_empty():
				errors.append("verb '%s': result '%s' missing non-empty 'generic' lines" % [vid, rkey])
			for bucket_key in r_dict.keys():
				var arr: Variant = r_dict[bucket_key]
				if typeof(arr) != TYPE_ARRAY or (arr as Array).is_empty():
					errors.append("verb '%s': result '%s' bucket '%s' must be a non-empty array" % [vid, rkey, str(bucket_key)])
					continue
				for line in (arr as Array):
					_validate_line_text("verb '%s' [%s/%s]" % [vid, rkey, str(bucket_key)], line, allowed_tokens, errors)

	var person_lines: Dictionary = Dictionary(lines_doc.get("person_lines", {}))
	for ck in person_lines.keys():
		var cks: String = str(ck)
		if not cast_keys.is_empty() and not cast_keys.has(cks):
			errors.append("%s: person_lines references unknown cast_key '%s'" % [LINES_FILE, cks])
		var pv: Variant = person_lines[ck]
		if typeof(pv) != TYPE_DICTIONARY:
			errors.append("%s: person_lines['%s'] must be an object" % [LINES_FILE, cks])
			continue
		for vid in (pv as Dictionary).keys():
			var res_map: Variant = (pv as Dictionary)[vid]
			if typeof(res_map) != TYPE_DICTIONARY:
				continue
			for rkey in (res_map as Dictionary).keys():
				var arr: Variant = (res_map as Dictionary)[rkey]
				if typeof(arr) != TYPE_ARRAY or (arr as Array).is_empty():
					errors.append("%s: person_lines['%s']['%s']['%s'] must be non-empty" % [LINES_FILE, cks, str(vid), str(rkey)])
					continue
				for line in (arr as Array):
					_validate_line_text("person_lines '%s' [%s/%s]" % [cks, str(vid), str(rkey)], line, allowed_tokens, errors)


static func _validate_line_text(label: String, line: Variant, allowed_tokens: Dictionary, errors: Array) -> void:
	if typeof(line) != TYPE_STRING or str(line).strip_edges() == "":
		errors.append("%s: empty or non-string line" % label)
		return
	var s: String = str(line)
	var i: int = 0
	while i < s.length():
		var open_idx: int = s.find("{", i)
		if open_idx < 0:
			break
		var close_idx: int = s.find("}", open_idx + 1)
		if close_idx < 0:
			errors.append("%s: unclosed placeholder in '%s'" % [label, s])
			return
		var tok: String = s.substr(open_idx, close_idx - open_idx + 1)
		if not allowed_tokens.is_empty() and not allowed_tokens.has(tok):
			errors.append("%s: unsupported placeholder '%s'" % [label, tok])
		i = close_idx + 1


static func _validate_interaction_events(gd: GameData, inter: Dictionary, tpl_doc: Dictionary, cast_keys: Dictionary, errors: Array) -> void:
	var refs: Array = Array(inter.get("interaction_events", []))
	if refs.is_empty() and tpl_doc.is_empty():
		return
	var by_id := {}
	for t in Array(tpl_doc.get("templates", [])):
		if t is Dictionary and str(t.get("id", "")) != "":
			by_id[str(t.id)] = t
	for eid in refs:
		var id_s: String = str(eid)
		if not by_id.has(id_s):
			errors.append("%s: interaction_events ref '%s' missing from %s" % [INTERACTIONS_FILE, id_s, TEMPLATES_FILE])

	var budgets: Dictionary = gd.budgets() if gd != null and gd.registry.has_file("events_budgets") else {}
	var allowed_fx := _to_set(Array(budgets.get("allowed_effect_types", [])))
	var allowed_stats := _to_set(Array(budgets.get("allowed_check_stats", [])))
	var min_choices: int = int(budgets.get("min_choices", 2))
	var max_choices: int = int(budgets.get("max_choices", 4))

	for id_s in by_id.keys():
		var t: Dictionary = by_id[id_s]
		var hook: String = str(t.get("hook", ""))
		if hook != "on_talk" and hook != "interaction":
			continue
		if float(t.get("weight", 0.0)) <= 0.0:
			errors.append("event template '%s': weight must be > 0" % id_s)
		if not Array(t.get("place_types", [])).is_empty():
			errors.append("event template '%s': hooked template must have empty place_types" % id_s)
		for ck in Array(t.get("cast_keys", [])):
			if not cast_keys.is_empty() and not cast_keys.has(str(ck)):
				errors.append("event template '%s': unknown cast_key '%s'" % [id_s, str(ck)])
		var choices: Array = Array(t.get("choices", []))
		if choices.size() < min_choices or choices.size() > max_choices:
			errors.append("event template '%s': choices count %d outside %d..%d" % [id_s, choices.size(), min_choices, max_choices])
		for ci in choices.size():
			var ch: Dictionary = choices[ci]
			var chk: Dictionary = Dictionary(ch.get("check", {}))
			if str(chk.get("type", "")) == "stat" and not allowed_stats.is_empty():
				var st: String = str(chk.get("stat", ""))
				if not allowed_stats.has(st):
					errors.append("event template '%s' choice %d: unknown check stat '%s'" % [id_s, ci, st])
			for bucket in [Array(ch.get("always", [])), Array(Dictionary(ch.get("success", {})).get("effects", [])), Array(Dictionary(ch.get("failure", {})).get("effects", []))]:
				for fx in bucket:
					if fx is Dictionary and not allowed_fx.is_empty():
						var ft: String = str((fx as Dictionary).get("type", ""))
						if not allowed_fx.has(ft):
							errors.append("event template '%s' choice %d: unknown effect '%s'" % [id_s, ci, ft])
