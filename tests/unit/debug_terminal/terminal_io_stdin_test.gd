extends DaoTestSuite
## TerminalIO line reading over Godot 4.7.1's stdin behaviour (Windows, verified with a
## pipe probe): each read returns the data available with ONE trailing newline stripped;
## an empty line returns "" after blocking for input; end of input returns "" at once,
## on every read.


## A fake stdin: each entry is [text returned, milliseconds the read blocked].
## After the script runs out it behaves like end of input ("" instantly).
func _io(reads: Array) -> TerminalIO:
	var io := TerminalIO.new()
	var state := {"now": 0, "i": 0}
	io.clock = func() -> int: return state.now
	io.reader = func(_size: int) -> String:
		if state.i >= reads.size():
			return ""
		var r: Array = reads[state.i]
		state.i += 1
		state.now += int(r[1])
		return str(r[0])
	return io


## End of input: an instant "" may first read as one empty line (indistinguishable from a
## queued Enter), then the second instant "" ends input.
func _assert_ends(io: TerminalIO) -> void:
	var a: Variant = io.read_line()
	if a != null:
		assert_eq(a, "", "at most one empty line before the end")
		assert_eq(io.read_line(), null, "then end of input")


func test_lines_typed_one_at_a_time_are_returned_one_at_a_time() -> void:
	# Regression: the newline Godot strips was never put back, so a typed line waited
	# forever (console) or was glued to the next one ("new quick Probe 7sheetquit").
	var io := _io([["new quick Probe 7", 900], ["sheet", 1200], ["quit", 800]])
	assert_eq(io.read_line(), "new quick Probe 7", "first line")
	assert_eq(io.read_line(), "sheet", "second line")
	assert_eq(io.read_line(), "quit", "third line")
	_assert_ends(io)


func test_an_empty_line_is_not_end_of_input() -> void:
	# Regression: pressing Enter on an empty line returned "" and quit the game.
	var io := _io([["look", 500], ["", 700], ["sheet", 600]])
	assert_eq(io.read_line(), "look", "line")
	assert_eq(io.read_line(), "", "empty line")
	assert_eq(io.read_line(), "sheet", "next line still read")


func test_a_queued_empty_line_returned_instantly_is_not_end_of_input() -> void:
	# The empty line was already waiting, so the read returns "" at once; the next
	# read blocks for real input, which proves it was not end of input.
	var io := _io([["", 0], ["sheet", 400]])
	assert_eq(io.read_line(), "", "empty line")
	assert_eq(io.read_line(), "sheet", "line after it")


func test_a_block_of_lines_with_crlf_is_split() -> void:
	var io := _io([["a\r\nb\r\n\r\nc", 0]])
	assert_eq(io.read_line(), "a", "a")
	assert_eq(io.read_line(), "b", "b")
	assert_eq(io.read_line(), "", "blank")
	assert_eq(io.read_line(), "c", "c (its newline was stripped by the engine)")
	_assert_ends(io)


func test_a_full_buffer_read_continues_the_same_line() -> void:
	var long_line: String = "x".repeat(4096)
	var io := _io([[long_line, 0], ["yz", 0]])
	assert_eq(io.read_line(), long_line + "yz", "joined across the buffer boundary")


func test_vietnamese_text_survives() -> void:
	var io := _io([["talk p12 Chào tiền bối", 300]])
	assert_eq(io.read_line(), "talk p12 Chào tiền bối", "diacritics intact")


func test_a_queued_empty_line_is_returned_without_a_second_read() -> void:
	# Regression (flaky pipe check): an empty line already waiting returns "" at once;
	# reading again to rule out end of input blocked until the client typed more, while
	# the client waited for the menu that Enter should have shown.
	var io := _io([["", 0], ["sheet", 400]])
	var calls := {"n": 0}
	var inner: Callable = io.reader
	io.reader = func(size: int) -> String:
		calls.n += 1
		return inner.call(size)
	assert_eq(io.read_line(), "", "empty line")
	assert_eq(calls.n, 1, "returned after one read")
