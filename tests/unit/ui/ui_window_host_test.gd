extends DaoTestSuite
## WindowHost (src/ui/windows/window_host.gd; interaction-patterns.md Side panel with history): browser-like history,
## forward entries dropped on a new open, the reader decides what can open, and actions are forwarded with the kind.


class FakeWindow extends GameWindow:
	var _k: String
	func _init(k: String) -> void:
		super._init()
		_k = k
	func kind() -> String:
		return _k
	func window_title(v: Dictionary) -> String:
		return "T:" + str(v.get("who", ""))
	func _build() -> void:
		section("a", "A")
		line(str(view.get("who", "")))
		section("b", "B")


func _host() -> WindowHost:
	var h: WindowHost = auto_free(WindowHost.new())
	h.register(FakeWindow.new("one"))
	h.register(FakeWindow.new("two"))
	h.reader = func(k: String, sub: String) -> Dictionary: return {} if sub == "missing" else {"who": k + "/" + sub}
	add_child(h)
	return h


func test_back_and_forward_step_through_the_history() -> void:
	var h := _host()
	h.open("one", "x")
	h.open("two", "y")
	assert_eq(h.current_kind(), "two")
	h.back()
	assert_eq(h.current_kind(), "one", "back to the first window")
	assert_eq(h._title.text, "T:one/x", "the title follows the history step")
	h.forward()
	assert_eq(h.current_kind(), "two", "forward again")


func test_opening_after_going_back_drops_the_forward_entries() -> void:
	var h := _host()
	h.open("one", "a")
	h.open("two", "b")
	h.open("one", "c")
	h.back()
	h.back()
	h.open("two", "d")
	var hist: Dictionary = h.history()
	assert_eq(hist.entries.size(), 2, "a, then d: b and c were forward entries")
	assert_eq(str(hist.entries[1].subject), "d")
	assert_true(h._fwd.disabled, "nothing forward")


func test_the_history_keeps_only_history_max_entries() -> void:
	var h := _host()
	h.history_max = 3
	for i in 5:
		h.open("one" if i % 2 == 0 else "two", str(i))
	assert_eq(h.history().entries.size(), 3)
	assert_eq(str(h.history().entries[0].subject), "2", "the oldest fell off")


func test_a_window_the_reader_cannot_read_does_not_open() -> void:
	var h := _host()
	assert_false(h.open("one", "missing"), "an empty view opens nothing")
	assert_false(h.visible)
	var asked: Array = []
	h.unknown_requested.connect(func(k: String, _s: String, _x: String): asked.append(k))
	assert_false(h.open("nope"), "an unknown kind")
	assert_eq(asked, ["nope"], "an unknown kind is handed to the map screen")


func test_actions_come_out_with_the_window_kind() -> void:
	var h := _host()
	h.open("one", "x")
	var got: Array = []
	h.action_requested.connect(func(k: String, a: String, args: Array): got.append([k, a, args]))
	h.current().action_requested.emit("set_slot", ["main", 0, "k", false])
	assert_eq(got, [["one", "set_slot", ["main", 0, "k", false]]])


func test_reopening_the_same_window_updates_its_entry_instead_of_adding_one() -> void:
	var h := _host()
	h.open("one", "x")
	h.open("one", "x", "b")
	assert_eq(h.history().entries.size(), 1)
	assert_eq(str(h.history().entries[0].section), "b")
