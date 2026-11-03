class_name Narrator
extends RefCounted
## The storyteller. Chooses between the LLM and the templated fallback for events,
## narration, NPC conversation and the closing chronicle. The LLM never decides
## outcomes: events go through [EventValidator], narration is checked for numbers the
## engine did not produce, and talk replies may only reference existing entities.
## Design: game-concept.md (bounded LLM game master; pillars 2 and 5).
##
## Usage:
## [codeblock]
## var n := Narrator.new(gd, db, llm, templates, validator)
## var ev: Dictionary = n.generate_event(ctx, rng)      # {ok, event, warnings, source}
## var story: Dictionary = n.narrate(ev.event, 0, result) # {text, source, faithful}
## [/codeblock]

var _gd: GameData
var _db: WorldDB
var _llm: LlmService
var _templates: EventTemplateSource
var _validator: EventValidator


func _init(gd: GameData, db: WorldDB, llm: LlmService, templates: EventTemplateSource, validator: EventValidator) -> void:
	_gd = gd
	_db = db
	_llm = llm
	_templates = templates
	_validator = validator


## Generates and validates an event. Tries the LLM first when available, then templates.
## Returns {ok, event, warnings, source, llm_error, ms}.
func generate_event(ctx: Dictionary, rng: RandomNumberGenerator, template_id: String = "") -> Dictionary:
	var llm_error: String = ""
	if template_id == "" and _llm.use("events"):
		var r: Dictionary = _llm.json_call(_llm.prompt("event_system"), EventContext.for_prompt(ctx))
		if r.ok:
			var norm: Dictionary = _validator.normalize(r.data, ctx, rng, "llm")
			if norm.ok:
				norm["source"] = "llm"
				norm["llm_error"] = ""
				norm["ms"] = r.ms
				return norm
			llm_error = "LLM event rejected: %s" % norm.error
		else:
			llm_error = "LLM call failed: %s" % r.error
	var raw: Dictionary = _templates.generate(ctx, rng, template_id)
	if raw.is_empty():
		return {"ok": false, "event": {}, "warnings": [], "source": "none", "llm_error": llm_error, "ms": 0}
	var res: Dictionary = _validator.normalize(raw, ctx, rng, str(raw.source))
	res["source"] = str(raw.source)
	res["llm_error"] = llm_error
	res["ms"] = 0
	return res


## Narrates a resolved choice. Returns {text, source, faithful, stray, error}.
func narrate(event: Dictionary, choice_index: int, result: Dictionary) -> Dictionary:
	var choice: Dictionary = event.choices[choice_index]
	var facts := "Event: %s\n%s\nPlayer chose: %s\nCheck: %s\nOutcome: %s\nEffects: %s" % [
		event.title, event.text, choice.label, result.check_line, result.outcome_text, "; ".join(result.lines)]
	var fallback: String = str(result.outcome_text)
	if _llm.use("narration"):
		var r: Dictionary = _llm.text_call(_llm.prompt("narrate_system"), facts)
		if r.ok and r.text != "":
			var stray: Array = stray_numbers(r.text, facts)
			if stray.is_empty():
				return {"text": r.text, "source": "llm", "faithful": true, "stray": [], "error": ""}
			return {"text": fallback, "source": "template", "faithful": false, "stray": stray, "error": "LLM narration invented numbers %s; used template" % str(stray)}
		return {"text": fallback, "source": "template", "faithful": true, "stray": [], "error": "LLM narration failed: %s" % r.error}
	return {"text": fallback, "source": "template", "faithful": true, "stray": [], "error": ""}


## Conversation with an NPC. Returns {reply, rumor_id, attitude_change, source, error}.
func talk(npc: Dictionary, ctx: Dictionary, player_line: String, rng: RandomNumberGenerator) -> Dictionary:
	var history: Array = _db.events_of(npc.id).slice(-5).map(func(e): return {"year": int(e.year), "text": e.text})
	var sect: Dictionary = _db.get_record("sects", str(npc.sect_id))
	var record := {
		"you": {"id": npc.id, "name": npc.name, "realm": _gd.realm_label(int(npc.realm_index), int(npc.stage)),
			"archetype": _gd.archetype(str(npc.archetype)).get("name", npc.archetype), "sect": sect.get("name", ""),
			"traits": EventContext.trait_names(npc.get("traits", []), _gd), "attitude_to_player": int(npc.get("attitude", 0)), "age": int(npc.age), "history": history},
		"player": ctx.player, "place": ctx.place, "others_here": ctx.npcs_here.filter(func(o): return o.id != npc.id), "recent_history": ctx.recent_events,
		"player_says": player_line,
	}
	if _llm.use("talk"):
		var r: Dictionary = _llm.json_call(_llm.prompt("talk_system"), record)
		if r.ok:
			var reply: String = EventValidator._text(r.data.get("reply", ""), int(_gd.budgets().max_text_chars))
			var rumor: String = str(r.data.get("rumor_entity_id", ""))
			if rumor != "" and _db.lookup(rumor).is_empty():
				rumor = ""
			var att: int = clampi(int(r.data.get("attitude_change", 0)), -10, 10)
			if reply != "":
				return {"reply": reply, "rumor_id": rumor, "attitude_change": att, "source": "llm", "error": ""}
		return _talk_template(npc, rng, "LLM talk failed: %s" % r.error)
	return _talk_template(npc, rng, "")


## Closing chronicle entry for a finished life.
func epitaph(facts: String) -> Dictionary:
	if _llm.use("epitaph"):
		var r: Dictionary = _llm.text_call(_llm.prompt("epitaph_system"), facts)
		if r.ok and r.text != "" and stray_numbers(r.text, facts).is_empty():
			return {"text": r.text, "source": "llm"}
	return {"text": facts, "source": "template"}


## Numbers that appear in [param text] but not in [param facts].
static func stray_numbers(text: String, facts: String) -> Array:
	var rx := RegEx.new()
	rx.compile("\\d+")
	var allowed: Dictionary = {}
	for m in rx.search_all(facts):
		allowed[m.get_string()] = true
	var stray: Array = []
	for m in rx.search_all(text):
		if not allowed.has(m.get_string()):
			stray.append(m.get_string())
	return stray


func _talk_template(npc: Dictionary, rng: RandomNumberGenerator, error: String) -> Dictionary:
	var att: int = int(npc.get("attitude", 0))
	var greeting: String
	if att >= 30:
		greeting = "%s mỉm cười: \"Đạo hữu lại tới, mời ngồi.\"" % npc.name
	elif att <= -30:
		greeting = "%s lạnh lùng liếc ngươi, không nói một lời." % npc.name
	else:
		greeting = "%s chắp tay: \"Đạo hữu có việc gì?\"" % npc.name
	var rumor_id: String = ""
	var pool: Array = _db.events_of(npc.id) + _db.events_of(str(npc.sect_id))
	if not pool.is_empty() and att > -30:
		var e: Dictionary = RngUtils.pick(rng, pool)
		greeting += " Hắn kể: \"%s\"" % str(e.text)
		rumor_id = str(e.id)
	return {"reply": greeting, "rumor_id": rumor_id, "attitude_change": 1 if att > -30 else 0, "source": "template", "error": error}
