class_name LlmService
extends RefCounted
## Configures an [LlmClient] from services_llm.json, environment variables and the
## per-user config file (user://llm_config.json, outside the repo — the API key never
## lives in the project), and exposes JSON / text calls with lenient parsing.
## The game always works without it: every caller has a template fallback.
##
## Key lookup order: user config "api_key", then each env var in key_env_vars
## (DEEPSEEK_API_KEY, LLM_API_KEY).
##
## Usage:
## [codeblock]
## var llm := LlmService.new(gd)
## if llm.available():
##     var r: Dictionary = llm.json_call("You are...", {"context": 1})
##     if r.ok: print(r.data)
## llm.set_key("sk-...")          # persists to user://llm_config.json
## [/codeblock]

var client: LlmClient = LlmClient.new()
## Output language code for prompts ("vi" or "en").
var language: String = "vi"
## Master switch (terminal: `llm on|off`).
var enabled: bool = true
## Which features may use the LLM: events, narration, talk, epitaph.
var use_for: Dictionary = {}
## Last exchange, for `llm last` in the debug terminal.
var last_request: String = ""
var last_response: String = ""
var last_error: String = ""

var _gd: GameData
var _user_path: String = "user://llm_config.json"


func _init(gd: GameData) -> void:
	_gd = gd
	var s: Dictionary = gd.llm_settings()
	client.base_url = str(s.get("base_url", client.base_url))
	client.path = str(s.get("path", client.path))
	client.model = str(s.get("model", client.model))
	client.timeout_sec = float(s.get("timeout_sec", client.timeout_sec))
	client.temperature = float(s.get("temperature", client.temperature))
	client.max_tokens = int(s.get("max_tokens", client.max_tokens))
	language = str(s.get("language", language))
	use_for = s.get("use_for", {}).duplicate()
	_user_path = str(s.get("user_config_path", _user_path))
	for env in s.get("key_env_vars", []):
		if client.api_key == "" and OS.has_environment(str(env)):
			client.api_key = OS.get_environment(str(env)).strip_edges()
	_load_user_config()


## True when calls can be attempted (enabled, and a key or a local endpoint).
func available() -> bool:
	if not enabled:
		return false
	return client.api_key != "" or _is_local()


## True if [param feature] (events, narration, talk, epitaph) should use the LLM now.
func use(feature: String) -> bool:
	return available() and bool(use_for.get(feature, true))


## Stores the API key in the user config file (not the repo).
func set_key(key: String) -> void:
	client.api_key = key.strip_edges()
	_save_user_config()


## Points the client at another OpenAI-compatible endpoint (e.g. a local Ollama).
func set_endpoint(base_url: String, model: String, path: String = "") -> void:
	client.base_url = base_url
	if model != "":
		client.model = model
	if path != "":
		client.path = path
	_save_user_config()


## Calls the model expecting a JSON object. Returns {ok, data, error, ms}.
func json_call(system_prompt: String, payload: Variant) -> Dictionary:
	var user_text: String = payload if typeof(payload) == TYPE_STRING else JSON.stringify(payload)
	var r: Dictionary = _call(system_prompt, user_text, true)
	if not r.ok:
		return {"ok": false, "data": null, "error": r.error, "ms": r.ms}
	var data: Variant = parse_json_lenient(r.content)
	if typeof(data) != TYPE_DICTIONARY:
		last_error = "model did not return a JSON object"
		return {"ok": false, "data": null, "error": last_error, "ms": r.ms}
	return {"ok": true, "data": data, "error": "", "ms": r.ms}


## Calls the model for free text. Returns {ok, text, error, ms}.
func text_call(system_prompt: String, user_text: String) -> Dictionary:
	var r: Dictionary = _call(system_prompt, user_text, false)
	return {"ok": r.ok, "text": str(r.content).strip_edges(), "error": r.error, "ms": r.ms}


## Fills {language} in a prompt from events_prompts.json.
func prompt(key: String) -> String:
	var p: Dictionary = _gd.prompts()
	var lang_name: String = str(p.get("language_names", {}).get(language, language))
	return str(p.get(key, "")).replace("{language}", lang_name)


## One-line status for the terminal.
func status_line() -> String:
	var key_state: String = "key set" if client.api_key != "" else ("local endpoint, no key" if _is_local() else "NO KEY")
	return "LLM %s | %s%s | model %s | %s | language %s | calls %d, failures %d, avg %d ms" % [
		"on" if enabled else "off", client.base_url, client.path, client.model, key_state, language,
		client.calls, client.failures, client.average_ms()]


## Parses JSON, tolerating markdown fences and leading/trailing prose.
static func parse_json_lenient(text: String) -> Variant:
	var json := JSON.new()
	if json.parse(text) == OK:
		return json.data
	var a: int = text.find("{")
	var b: int = text.rfind("}")
	if a != -1 and b > a and json.parse(text.substr(a, b - a + 1)) == OK:
		return json.data
	return null


func _call(system_prompt: String, user_text: String, json_mode: bool) -> Dictionary:
	last_request = "SYSTEM:\n%s\n\nUSER:\n%s" % [system_prompt, user_text]
	var r: Dictionary = client.chat([{"role": "system", "content": system_prompt}, {"role": "user", "content": user_text}], json_mode)
	last_response = str(r.get("content", ""))
	last_error = str(r.get("error", ""))
	return r


func _is_local() -> bool:
	return client.base_url.contains("localhost") or client.base_url.contains("127.0.0.1")


func _load_user_config() -> void:
	if not FileAccess.file_exists(_user_path):
		return
	var f := FileAccess.open(_user_path, FileAccess.READ)
	if f == null:
		return
	var data: Variant = parse_json_lenient(f.get_as_text())
	if typeof(data) != TYPE_DICTIONARY:
		return
	for k in ["base_url", "path", "model"]:
		if data.has(k) and str(data[k]) != "":
			client.set(k, str(data[k]))
	if str(data.get("api_key", "")) != "":
		client.api_key = str(data.api_key)
	if data.has("language"):
		language = str(data.language)
	if data.has("enabled"):
		enabled = bool(data.enabled)


func _save_user_config() -> void:
	var f := FileAccess.open(_user_path, FileAccess.WRITE)
	if f == null:
		return
	f.store_string(JSON.stringify({
		"base_url": client.base_url, "path": client.path, "model": client.model,
		"api_key": client.api_key, "language": language, "enabled": enabled,
	}, "  "))


## Persists the enabled flag and language.
func save() -> void:
	_save_user_config()
