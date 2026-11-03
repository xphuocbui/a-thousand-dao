class_name TerminalIO
extends RefCounted
## Line-based console I/O for the debug terminal.
##
## Godot 4.7's [method OS.read_string_from_stdin] takes a buffer size: on a console it
## returns one line, on a pipe it returns whatever chunk is available, so input is
## buffered and split into lines here. A command file (--commands) or a list of
## injected lines can replace stdin for scripted runs and tests.
##
## Usage:
## [codeblock]
## var io := TerminalIO.new()
## io.color = true
## io.out(io.paint("Hỏa", "31"))
## var line: Variant = io.read_line("> ")   # null at end of input
## [/codeblock]

## Bytes asked of stdin per read.
const READ_SIZE := 4096
## A read returning "" within this many ms did not wait for input.
const INSTANT_MS := 5

## Emit ANSI colour codes.
var color: bool = false
## Echo input lines (useful when input comes from a file or pipe).
var echo: bool = false
## Lines queued from a command file or tests; consumed before stdin.
var scripted: Array = []
## When true, never touch stdin (tests); end of [member scripted] is end of input.
var scripted_only: bool = false
## Everything written, when [member capture] is on (tests).
var captured: PackedStringArray = PackedStringArray()
var capture: bool = false
## Reads raw stdin: (buffer_size) -> String. Replaced by tests with a fake.
var reader: Callable = func(size: int) -> String: return OS.read_string_from_stdin(size)
## Milliseconds clock used to tell an empty line from end of input. Replaced by tests.
var clock: Callable = func() -> int: return Time.get_ticks_msec()

var _buffer: String = ""
var _eof: bool = false
var _suspect_eof: bool = false


## Prints one line.
func out(text: String = "") -> void:
	if capture:
		captured.append(text)
	print(text)


## Prints several lines.
func out_lines(lines: Variant) -> void:
	for l in lines:
		out(str(l))


## Wraps text in an ANSI colour when colour is on.
func paint(text: String, ansi_code: String) -> String:
	if not color or ansi_code == "":
		return text
	return "\u001b[%sm%s\u001b[0m" % [ansi_code, text]


## Reads one line (without the newline). Returns null at end of input.
func read_line(prompt: String = "") -> Variant:
	if prompt != "":
		printraw(prompt)
	if not scripted.is_empty():
		var line: String = scripted.pop_front()
		if echo or prompt != "":
			print(line)
		return line
	if scripted_only:
		return null
	while true:
		var nl: int = _buffer.find("\n")
		if nl != -1:
			var line2: String = _buffer.substr(0, nl).trim_suffix("\r")
			_buffer = _buffer.substr(nl + 1)
			if echo:
				print(line2)
			return line2
		if _eof:
			if _buffer != "":
				var rest: String = _buffer
				_buffer = ""
				return rest
			return null
		_fill()
	return null


## Reads one chunk of stdin into the buffer, restoring the newline the engine strips.
## Godot 4.7.1 returns the available data minus its trailing newline; an empty line comes
## back as "" (after blocking, or at once when it was already waiting), and end of input
## returns "" at once on every read. There is no way to peek, so an instant "" is taken
## as an empty line and only a second instant "" in a row ends input. Reading again
## straight away would block until the user typed more, while they wait for our answer.
func _fill() -> void:
	var t: int = clock.call()
	var chunk: String = reader.call(READ_SIZE)
	var instant: bool = clock.call() - t <= INSTANT_MS
	if chunk == "" and instant:
		if _suspect_eof:
			_eof = true
			return
		_suspect_eof = true
		_buffer += "\n"
		return
	_suspect_eof = false
	# A read that filled the whole buffer stopped mid-line: no newline was stripped.
	_buffer += chunk + ("" if chunk.to_utf8_buffer().size() >= READ_SIZE else "\n")


## Loads lines from a text file into the scripted queue (blank lines and # comments skipped).
func queue_file(path: String) -> bool:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return false
	for line in f.get_as_text().split("\n"):
		var l: String = line.strip_edges()
		if l != "" and not l.begins_with("#"):
			scripted.append(l)
	return true
