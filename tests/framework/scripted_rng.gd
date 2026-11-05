class_name ScriptedRng
extends RefCounted
## Test double for the seeded RNG (linh-can.md AC notation): returns a scripted list of uniform
## (U) and normal (N) draws in order and logs each call. randfn returns the final sample.
##
## Usage:
## [codeblock]
## var r := ScriptedRng.new(["U", 0.8, "N", 40.0])
## var u: float = r.randf()
## assert_true(r.done(), "every draw used, in order")
## [/codeblock]

var _script: Array = []
var _next: int = 0
## Calls made, as "U" or "N".
var log: Array = []
## Set when a call has the wrong kind or runs past the end of the script.
var error: String = ""


## [param script] alternates kind and value: ["U", 0.5, "N", 60.0].
func _init(script: Array = []) -> void:
	_script = script


## Next uniform draw.
func randf() -> float:
	return _take("U")


## Next normal draw; the mean and deviation are ignored.
func randfn(_mean: float = 0.0, _deviation: float = 1.0) -> float:
	return _take("N")


## True when the script was consumed exactly, with no wrong call.
func done() -> bool:
	return error == "" and _next == _script.size()


func _take(kind: String) -> float:
	log.append(kind)
	if _next >= _script.size():
		error = "call %d past the end" % log.size()
		return 0.99
	if _script[_next] != kind:
		error = "call %d: expected %s, got %s" % [log.size(), _script[_next], kind]
	var v: float = float(_script[_next + 1])
	_next += 2
	return v
