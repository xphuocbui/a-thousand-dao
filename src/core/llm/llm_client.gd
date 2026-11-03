class_name LlmClient
extends RefCounted
## Synchronous client for OpenAI-compatible chat-completion endpoints (DeepSeek,
## Ollama, LM Studio, llama.cpp server). Blocks the calling thread while polling
## [HTTPClient]; single-thread-only. Needs no SceneTree, so it works from the
## debug terminal's blocking REPL.
##
## Usage:
## [codeblock]
## var client := LlmClient.new()
## client.base_url = "https://api.deepseek.com"
## client.api_key = OS.get_environment("DEEPSEEK_API_KEY")
## var r: Dictionary = client.chat([{"role": "user", "content": "hi"}], false)
## if r.ok: print(r.content) else: print(r.error)
## [/codeblock]

## Scheme + host (+ optional port), e.g. "https://api.deepseek.com".
var base_url: String = "https://api.deepseek.com"
## Request path appended to [member base_url].
var path: String = "/chat/completions"
## Model name sent in the request body.
var model: String = "deepseek-chat"
## Bearer token; empty means no Authorization header (local servers).
var api_key: String = ""
## Seconds before a call is abandoned.
var timeout_sec: float = 60.0
## Sampling temperature.
var temperature: float = 1.0
## Upper bound on generated tokens.
var max_tokens: int = 1200

## Running statistics, for the terminal's `llm status`.
var calls: int = 0
var failures: int = 0
var total_ms: int = 0


## Sends a chat request. [param messages] is an Array of {role, content}.
## With [param json_mode] the request asks for a JSON object response.
## Returns {ok: bool, content: String, error: String, ms: int}.
func chat(messages: Array, json_mode: bool) -> Dictionary:
	calls += 1
	var started: int = Time.get_ticks_msec()
	var result: Dictionary = _do_chat(messages, json_mode)
	result["ms"] = Time.get_ticks_msec() - started
	total_ms += result.ms
	if not result.ok:
		failures += 1
	return result


## Average latency of all calls so far, in milliseconds.
func average_ms() -> int:
	return 0 if calls == 0 else total_ms / calls


func _do_chat(messages: Array, json_mode: bool) -> Dictionary:
	var url: Dictionary = parse_url(base_url)
	if not url.ok:
		return _fail("bad base_url '%s'" % base_url)
	var body := {
		"model": model,
		"messages": messages,
		"temperature": temperature,
		"max_tokens": max_tokens,
		"stream": false,
	}
	if json_mode:
		body["response_format"] = {"type": "json_object"}
	var headers := PackedStringArray(["Content-Type: application/json", "Accept: application/json"])
	if api_key != "":
		headers.append("Authorization: Bearer " + api_key)

	var http := HTTPClient.new()
	var tls: TLSOptions = TLSOptions.client() if url.tls else null
	var err: int = http.connect_to_host(url.host, url.port, tls)
	if err != OK:
		return _fail("connect_to_host error %d" % err)
	var deadline: int = Time.get_ticks_msec() + int(timeout_sec * 1000.0)

	while http.get_status() in [HTTPClient.STATUS_RESOLVING, HTTPClient.STATUS_CONNECTING]:
		http.poll()
		if Time.get_ticks_msec() > deadline:
			http.close()
			return _fail("timeout while connecting")
		OS.delay_msec(10)
	if http.get_status() != HTTPClient.STATUS_CONNECTED:
		var status: int = http.get_status()
		http.close()
		return _fail("could not connect (status %d)" % status)

	var full_path: String = url.path.trim_suffix("/") + path if url.path != "" else path
	err = http.request(HTTPClient.METHOD_POST, full_path, headers, JSON.stringify(body))
	if err != OK:
		http.close()
		return _fail("request error %d" % err)

	while http.get_status() == HTTPClient.STATUS_REQUESTING:
		http.poll()
		if Time.get_ticks_msec() > deadline:
			http.close()
			return _fail("timeout while requesting")
		OS.delay_msec(10)

	if not http.has_response():
		var st: int = http.get_status()
		http.close()
		return _fail("no response (status %d)" % st)

	var code: int = http.get_response_code()
	var bytes := PackedByteArray()
	while http.get_status() == HTTPClient.STATUS_BODY:
		http.poll()
		var chunk: PackedByteArray = http.read_response_body_chunk()
		if chunk.is_empty():
			if Time.get_ticks_msec() > deadline:
				http.close()
				return _fail("timeout while reading body")
			OS.delay_msec(5)
		else:
			bytes.append_array(chunk)
	http.close()

	var text: String = bytes.get_string_from_utf8()
	if code != 200:
		return _fail("HTTP %d: %s" % [code, text.substr(0, 300)])
	var json := JSON.new()
	if json.parse(text) != OK or typeof(json.data) != TYPE_DICTIONARY:
		return _fail("response is not JSON: %s" % text.substr(0, 200))
	var data: Dictionary = json.data
	var choices: Variant = data.get("choices")
	if typeof(choices) != TYPE_ARRAY or (choices as Array).is_empty():
		return _fail("response has no choices")
	var message: Variant = (choices as Array)[0].get("message", {})
	var content: String = str(message.get("content", "")) if typeof(message) == TYPE_DICTIONARY else ""
	return {"ok": true, "content": content, "error": ""}


func _fail(message: String) -> Dictionary:
	return {"ok": false, "content": "", "error": message}


## Splits "https://host:port/base" into {ok, tls, host, port, path}.
static func parse_url(url: String) -> Dictionary:
	var tls: bool
	var rest: String
	if url.begins_with("https://"):
		tls = true
		rest = url.substr(8)
	elif url.begins_with("http://"):
		tls = false
		rest = url.substr(7)
	else:
		return {"ok": false}
	var slash: int = rest.find("/")
	var hostport: String = rest if slash == -1 else rest.substr(0, slash)
	var base_path: String = "" if slash == -1 else rest.substr(slash)
	var host: String = hostport
	var port: int = 443 if tls else 80
	var colon: int = hostport.rfind(":")
	if colon != -1:
		host = hostport.substr(0, colon)
		port = hostport.substr(colon + 1).to_int()
	if host == "":
		return {"ok": false}
	return {"ok": true, "tls": tls, "host": host, "port": port, "path": base_path}
