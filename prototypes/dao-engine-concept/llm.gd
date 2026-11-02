# PROTOTYPE - NOT FOR PRODUCTION
# Question: Does drafting/fusing fragments into a chain engine make players rework builds, and can a local LLM narrate it within engine budgets?
# Date: 2026-11-02
extends Node

# Hypothesis B harness: OpenAI-compatible chat endpoint (Ollama / LM Studio / llama.cpp server).
# The engine owns every number: reward values are clamped to a per-stage budget and the
# narration is checked for numbers the engine did not produce.

var http := HTTPRequest.new()
var url := "http://localhost:11434/v1/chat/completions"
var model := "llama3.2"
var busy := false

# stats for the benchmark
var calls := 0
var transport_ok := 0
var strict_json := 0
var lenient_json := 0
var keys_ok := 0
var clamped := 0
var total_ms := 0
var max_ms := 0

# engine-side budgets: spirit stone reward range per stage
const BUDGETS := [[5, 40], [30, 200], [150, 800]]


func _ready() -> void:
	http.timeout = 60.0
	add_child(http)


func reset_stats() -> void:
	calls = 0
	transport_ok = 0
	strict_json = 0
	lenient_json = 0
	keys_ok = 0
	clamped = 0
	total_ms = 0
	max_ms = 0


func chat(system_prompt: String, user_prompt: String, want_json: bool) -> Dictionary:
	if busy:
		return {"ok": false, "error": "busy", "ms": 0}
	busy = true
	var body := {
		"model": model,
		"stream": false,
		"temperature": 0.7,
		"messages": [
			{"role": "system", "content": system_prompt},
			{"role": "user", "content": user_prompt},
		],
	}
	if want_json:
		body["response_format"] = {"type": "json_object"}
	var t0 := Time.get_ticks_msec()
	var err := http.request(url, ["Content-Type: application/json"], HTTPClient.METHOD_POST, JSON.stringify(body))
	if err != OK:
		busy = false
		return {"ok": false, "error": "request error %d" % err, "ms": 0}
	var res: Array = await http.request_completed
	var ms: int = Time.get_ticks_msec() - t0
	busy = false
	if res[0] != HTTPRequest.RESULT_SUCCESS or res[1] != 200:
		return {"ok": false, "error": "transport result %d http %d" % [res[0], res[1]], "ms": ms}
	var parsed = JSON.parse_string(res[3].get_string_from_utf8())
	if typeof(parsed) != TYPE_DICTIONARY or not parsed.has("choices"):
		return {"ok": false, "error": "unexpected response shape", "ms": ms}
	var content: String = parsed["choices"][0]["message"]["content"]
	return {"ok": true, "content": content, "ms": ms}


# Narration: the model dresses the engine's result. Returns {ok, text, ms, faithful, stray}.
func narrate(result_summary: String, allowed_numbers: Array) -> Dictionary:
	var sys := "You are the narrator of a xianxia cultivation game. Narrate the clash below in 3 short sentences of vivid prose. Do NOT invent or change any numbers; only use numbers that appear in the summary."
	var r: Dictionary = await chat(sys, result_summary, false)
	if not r.ok:
		return r
	var stray: Array = []
	var rx := RegEx.new()
	rx.compile("\\d+")
	for m in rx.search_all(r.content):
		if not allowed_numbers.has(m.get_string()):
			stray.append(m.get_string())
	return {"ok": true, "text": r.content, "ms": r.ms, "faithful": stray.is_empty(), "stray": stray}


# Event generation: the model invents an event; the engine validates + clamps the numbers.
# Returns {ok, event, ms, strict, lenient, keys, was_clamped, error}.
func invent_event(stage: int, context: String) -> Dictionary:
	var budget: Array = BUDGETS[clampi(stage, 0, BUDGETS.size() - 1)]
	var sys := "You are the game master of a xianxia cultivation roguelite. Invent one short event for the player. Reply with ONLY a JSON object with keys: title (string), text (string, under 40 words), npc_name (string), reward_stones (integer)."
	calls += 1
	var r: Dictionary = await chat(sys, "Context: " + context, true)
	total_ms += r.ms
	max_ms = max(max_ms, r.ms)
	if not r.ok:
		return {"ok": false, "error": r.error, "ms": r.ms}
	transport_ok += 1
	var content: String = r.content
	var ev = _try_parse(content)
	var strict: bool = typeof(ev) == TYPE_DICTIONARY
	if strict:
		strict_json += 1
	var lenient: bool = strict
	if not strict:
		var a: int = content.find("{")
		var b: int = content.rfind("}")
		if a != -1 and b > a:
			ev = _try_parse(content.substr(a, b - a + 1))
			lenient = typeof(ev) == TYPE_DICTIONARY
	if lenient:
		lenient_json += 1
	var keys: bool = lenient and ev.has("title") and ev.has("text") and ev.has("npc_name") and ev.has("reward_stones") and (typeof(ev["reward_stones"]) == TYPE_INT or typeof(ev["reward_stones"]) == TYPE_FLOAT)
	if keys:
		keys_ok += 1
	var was_clamped := false
	if keys:
		var raw: int = int(ev["reward_stones"])
		var cl: int = clampi(raw, budget[0], budget[1])
		was_clamped = cl != raw
		ev["reward_stones"] = cl
		if was_clamped:
			clamped += 1
	return {"ok": true, "event": ev, "ms": r.ms, "strict": strict, "lenient": lenient, "keys": keys, "was_clamped": was_clamped, "budget": budget}


func stats_text() -> String:
	if calls == 0:
		return "no calls yet"
	return "calls %d | transport ok %d | strict JSON %d | lenient JSON %d | keys valid %d | clamped %d | avg %d ms | max %d ms" % [calls, transport_ok, strict_json, lenient_json, keys_ok, clamped, total_ms / calls, max_ms]


# JSON.parse_string logs an engine error on bad input; the instance API reports it quietly.
func _try_parse(s: String):
	var j := JSON.new()
	if j.parse(s) == OK:
		return j.data
	return null
