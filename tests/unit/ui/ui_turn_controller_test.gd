extends DaoTestSuite
## TurnController (design/ux/hud.md, The turn): the End turn gate, the label precedence and the default-focus
## fallback, against a fake session (no world, no files).


class FakePlayer:
	extends RefCounted
	var location_id: String = "here"


class FakeSession:
	extends RefCounted
	var player := FakePlayer.new()
	var pending: bool = false
	var calls: Array = []
	var travel_ok: bool = true
	var travel_arrives: bool = true

	func has_pending_event() -> bool:
		return pending

	func cultivate(seasons: int) -> Dictionary:
		calls.append(["cultivate", seasons])
		return {"ok": true, "lines": ["cultivated"]}

	var mission_ok: bool = true

	func explore() -> Dictionary:
		calls.append(["explore"])
		return {"ok": true, "lines": ["explored"]}

	func mission() -> Dictionary:
		calls.append(["mission"])
		return {"ok": mission_ok, "lines": ["mission"]}

	func travel(dest: String) -> Dictionary:
		calls.append(["travel", dest])
		if travel_ok and travel_arrives:
			player.location_id = dest
		return {"ok": travel_ok, "lines": ["travelled"]}


func test_default_focus_is_cultivate_and_end_turn_cultivates_one_season() -> void:
	var s := FakeSession.new()
	var tc := TurnController.new(s)
	assert_eq(tc.focus, TurnController.FOCUS_CULTIVATE, "first season starts on Cultivate")
	assert_true(tc.gate().ok, "nothing blocks")
	tc.end_turn()
	assert_eq(s.calls, [["cultivate", 1]], "one season of cultivation")


func test_pending_event_blocks_end_turn_and_names_it_first() -> void:
	var s := FakeSession.new()
	s.pending = true
	var tc := TurnController.new(s)
	tc.window_open = true
	assert_false(tc.gate().ok, "an event blocks End turn")
	assert_eq(tc.button_label(), "Event waiting", "the event outranks every other label")


func test_open_window_and_resolving_block_end_turn() -> void:
	var tc := TurnController.new(FakeSession.new())
	tc.window_open = true
	assert_false(tc.gate().ok, "a Z7 window blocks")
	tc.window_open = false
	tc.resolving = true
	assert_false(tc.gate().ok, "a resolving season blocks")
	assert_eq(tc.button_label(), "The world turns…", "the label says the world is turning")


func test_travel_without_destination_is_refused() -> void:
	var tc := TurnController.new(FakeSession.new())
	tc.focus = TurnController.FOCUS_TRAVEL
	assert_false(tc.gate().ok, "Travel needs a destination")


func test_travel_focus_calls_travel_and_carries_over_until_arrival() -> void:
	var s := FakeSession.new()
	s.travel_arrives = false
	var tc := TurnController.new(s)
	tc.choose_travel("far", "Far Town")
	assert_eq(tc.button_label(), "End turn: Travel to Far Town", "the label names the focus")
	var r: Dictionary = tc.end_turn()
	tc.after_turn(r)
	assert_eq(s.calls, [["travel", "far"]], "End turn travels")
	assert_eq(tc.focus, TurnController.FOCUS_TRAVEL, "the focus carries over while still on the way")
	assert_eq(tc.fallback_note, "", "no fallback yet")


func test_arrival_falls_back_to_cultivate_with_a_note() -> void:
	var s := FakeSession.new()
	var tc := TurnController.new(s)
	tc.choose_travel("near", "Near Village")
	tc.after_turn(tc.end_turn())
	assert_eq(tc.focus, TurnController.FOCUS_CULTIVATE, "arrived: back to Cultivate")
	assert_true(tc.fallback_note.contains("Near Village") and tc.fallback_note.contains("arrived"), "the note names the old focus and why: %s" % tc.fallback_note)


func test_failed_journey_falls_back_to_cultivate() -> void:
	var s := FakeSession.new()
	s.travel_ok = false
	var tc := TurnController.new(s)
	tc.choose_travel("nowhere", "Nowhere")
	tc.after_turn(tc.end_turn())
	assert_eq(tc.focus, TurnController.FOCUS_CULTIVATE, "a journey that could not start falls back")
	assert_true(tc.fallback_note.contains("could not start"), "the note says why: %s" % tc.fallback_note)


func test_fallback_note_clears_after_the_next_turn() -> void:
	var s := FakeSession.new()
	var tc := TurnController.new(s)
	tc.choose_travel("near", "Near Village")
	tc.after_turn(tc.end_turn())
	assert_true(tc.fallback_note != "", "arrival leaves a note")
	tc.after_turn(tc.end_turn())
	assert_eq(tc.fallback_note, "", "the note is shown once, not carried into the next season")


func test_cultivate_focus_carries_over_after_a_turn() -> void:
	var tc := TurnController.new(FakeSession.new())
	tc.after_turn(tc.end_turn())
	assert_eq(tc.focus, TurnController.FOCUS_CULTIVATE, "Cultivate carries over")
	assert_eq(tc.fallback_note, "", "no note")


func test_explore_focus_explores_and_carries_over() -> void:
	var s := FakeSession.new()
	var tc := TurnController.new(s)
	tc.choose_explore()
	assert_eq(tc.button_label(), "End turn: Explore", "the label names the focus")
	tc.after_turn(tc.end_turn())
	assert_eq(s.calls, [["explore"]], "End turn explores")
	assert_eq(tc.focus, TurnController.FOCUS_EXPLORE, "Explore carries over")


func test_mission_that_cannot_be_done_falls_back_to_cultivate() -> void:
	var s := FakeSession.new()
	s.mission_ok = false
	var tc := TurnController.new(s)
	tc.choose_mission()
	tc.after_turn(tc.end_turn())
	assert_eq(s.calls, [["mission"]], "End turn tries the mission")
	assert_eq(tc.focus, TurnController.FOCUS_CULTIVATE, "a refused mission falls back to Cultivate")
	assert_true(tc.fallback_note.contains("Mission") and tc.fallback_note.contains("could not be done"), "the note names it: %s" % tc.fallback_note)
