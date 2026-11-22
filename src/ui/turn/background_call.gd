class_name BackgroundCall
extends RefCounted
## Runs one Callable on a worker thread so the UI keeps drawing (`.claude/rules/ui-code.md`: the UI never blocks the
## game thread). While it runs, the caller must not touch whatever the Callable uses: the HUD turns inert instead
## (design/ux/hud.md, The turn: "While a season resolves").
##
## Usage:
## [codeblock]
## var job := BackgroundCall.new()
## job.start(func(): return session.run(session.cultivate.bind(1)))
## # each frame: if job.is_done(): var result = job.finish()
## [/codeblock]

var _thread: Thread = null
var _result: Variant = null
var _done: bool = false
var _mutex := Mutex.new()


## Starts [param work] on a new thread. Returns false when a call is already running.
func start(work: Callable) -> bool:
	if _thread != null:
		return false
	_done = false
	_result = null
	_thread = Thread.new()
	_thread.start(_run.bind(work))
	return true


## True while a call is running and not yet collected with [method finish].
func is_running() -> bool:
	return _thread != null


## True once the running call has returned (collect it with [method finish]).
func is_done() -> bool:
	_mutex.lock()
	var d: bool = _done
	_mutex.unlock()
	return d and _thread != null


## Waits for the call to end, joins its thread and returns its result.
func finish() -> Variant:
	if _thread == null:
		return null
	_thread.wait_to_finish()
	_thread = null
	return _result


func _run(work: Callable) -> void:
	var r: Variant = work.call()
	_mutex.lock()
	_result = r
	_done = true
	_mutex.unlock()
