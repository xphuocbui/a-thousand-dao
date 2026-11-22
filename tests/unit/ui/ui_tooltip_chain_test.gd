extends DaoTestSuite
## TooltipChain (design/ux/hud.md, Tooltips; acceptance criteria "Tooltips"), driven with simulated time at 60 frames
## a second. The knob values are the spec's defaults (delay 0.3 s = 18 frames, lock 1 s, grace 0.3 s, depth 5).

const DT := 1.0 / 60.0
const SRC := {"title": "Spirit stones", "body": [{"text": "linh thạch", "key": "a"}]}


func _chain() -> TooltipChain:
	var c := TooltipChain.new()
	c.configure({"tooltip_delay": 0.3, "tooltip_lock_delay": 1.0, "tooltip_close_grace": 0.3, "tooltip_depth_max": 5,
		"tooltip_lock": ["timer", "middle", "click"]})
	# Every word key resolves to a tooltip with one more word, so a chain can go as deep as the rules allow.
	c.resolve = func(key: String) -> Dictionary: return {"title": key, "body": [{"text": "next", "key": key + "+"}]}
	return c


func _on_source(c: TooltipChain, frames: int, source: String = "s1") -> void:
	for i in frames:
		c.advance(DT, {"level": -1, "source": source, "content": SRC})


func _in_level(c: TooltipChain, frames: int, level: int, word: String = "") -> void:
	for i in frames:
		c.advance(DT, {"level": level, "word": word})


func _away(c: TooltipChain, frames: int) -> void:
	for i in frames:
		c.advance(DT, {"level": -1})


func test_a_tooltip_opens_on_the_18th_frame_of_hovering_and_not_before() -> void:
	var c := _chain()
	_on_source(c, 17)
	assert_true(not c.is_open(), "not open after 17 frames")
	_on_source(c, 1)
	assert_true(c.is_open(), "open on frame 18")
	assert_eq(c.levels[0].source, "s1")


func test_a_zero_delay_opens_on_the_first_frame() -> void:
	var c := _chain()
	c.delay = 0.0
	_on_source(c, 1)
	assert_true(c.is_open(), "delay 0 opens at once")


func test_moving_into_the_tooltip_within_the_grace_keeps_it_and_staying_off_closes_it() -> void:
	var c := _chain()
	_on_source(c, 18)
	_away(c, 10)   # crossing the gap: 10 frames < 18 frames of grace
	_in_level(c, 30, 0)
	assert_true(c.is_open(), "still open after crossing into it")
	_away(c, 17)
	assert_true(c.is_open(), "open 17 frames off it")
	_away(c, 1)
	assert_true(not c.is_open(), "closed once the grace (18 frames) is used up")


func test_hovering_a_highlighted_word_opens_a_second_level_and_leaving_it_returns_to_the_parent() -> void:
	var c := _chain()
	_on_source(c, 18)
	_in_level(c, 18, 0, "a")
	assert_eq(c.levels.size(), 2, "the word opened level 1")
	assert_eq(c.levels[1].key, "a")
	_in_level(c, 18, 0)   # back on the parent, off the word and the child
	assert_eq(c.levels.size(), 1, "leaving the child returns to the parent")


func test_a_middle_click_locks_and_a_locked_chain_stays_open_for_ten_simulated_minutes() -> void:
	var c := _chain()
	_on_source(c, 18)
	_in_level(c, 2, 0)
	assert_true(c.click(MOUSE_BUTTON_MIDDLE, {"level": 0}, false), "the middle click is used by the tooltip")
	assert_true(c.is_locked(), "locked")
	for i in 600:   # 10 minutes in 1 s steps
		c.advance(1.0, {"level": -1})
	assert_true(c.is_open(), "a locked tooltip never closes on a timer")


func test_resting_in_a_tooltip_for_the_lock_delay_locks_it() -> void:
	var c := _chain()
	_on_source(c, 18)
	_in_level(c, 59, 0)
	assert_true(not c.is_locked(), "not yet after 59 frames")
	_in_level(c, 1, 0)
	assert_true(c.is_locked(), "locked after 1 s of rest")


func test_a_click_outside_a_locked_chain_closes_it_and_is_consumed() -> void:
	var c := _chain()
	_on_source(c, 18)
	c.lock(0)
	assert_true(c.click(MOUSE_BUTTON_LEFT, {"level": -1, "source": ""}, false), "consumed")
	assert_true(not c.is_open(), "closed")


func test_clicking_a_button_with_an_unlocked_tooltip_open_reaches_the_button_and_does_not_lock() -> void:
	var c := _chain()
	_on_source(c, 18)
	var consumed: bool = c.click(MOUSE_BUTTON_LEFT, {"level": -1, "source": "s1"}, true)
	assert_true(not consumed, "the button gets its click")
	assert_true(not c.is_locked(), "and the tooltip is not locked")


func test_click_to_lock_on_a_source_without_a_click_action_locks_it() -> void:
	var c := _chain()
	_on_source(c, 18)
	assert_true(not c.click(MOUSE_BUTTON_LEFT, {"level": -1, "source": "s1"}, false), "not consumed")
	assert_true(c.is_locked(), "a text source locks on click")


func test_a_locked_chain_ignores_other_sources_until_it_closes() -> void:
	var c := _chain()
	_on_source(c, 18)
	c.lock(0)
	_on_source(c, 60, "s2")
	assert_eq(c.levels[0].source, "s1", "hovering elsewhere opens nothing")


func test_an_unlocked_chain_is_replaced_by_another_source() -> void:
	var c := _chain()
	_on_source(c, 18)
	_on_source(c, 18, "s2")
	assert_eq(c.levels.size(), 1)
	assert_eq(c.levels[0].source, "s2", "the new source's tooltip replaced it")


func test_the_sixth_level_opens_the_wiki_instead() -> void:
	var c := _chain()
	_on_source(c, 18)
	var key: String = "a"
	for lvl in 4:
		assert_eq(c.press_word(lvl, key, true), "opened", "level %d's word opens level %d" % [lvl, lvl + 1])
		key += "+"
	assert_eq(c.levels.size(), 5, "five levels open")
	assert_eq(c.press_word(4, key, true), "wiki", "a word at the 5th level opens the wiki")
	assert_eq(c.levels.size(), 5, "no 6th level")
	_in_level(c, 60, 4, key)
	assert_eq(c.levels.size(), 5, "hovering a last-level word does nothing")


func test_keyboard_open_is_locked_and_esc_closes_one_level_at_a_time() -> void:
	var c := _chain()
	c.open_keyboard("s1", SRC)
	assert_true(c.is_locked(), "Q opens it locked")
	assert_eq(c.press_word(0, "a", true), "opened")
	_away(c, 600)
	assert_eq(c.levels.size(), 2, "keyboard-opened levels ignore the pointer")
	assert_eq(c.close_top().key, "a", "Esc closes the top level")
	assert_eq(c.levels.size(), 1)
	c.close_top()
	assert_true(not c.is_open(), "Esc again closes the root")


func test_the_source_disappearing_closes_a_locked_chain() -> void:
	var c := _chain()
	_on_source(c, 18)
	c.lock(0)
	c.source_gone("s1")
	assert_true(not c.is_open(), "closed with its source")


func test_settings_change_the_behaviour_at_once() -> void:
	var c := _chain()
	c.configure({"tooltip_delay": 1.0, "tooltip_close_grace": 2.0, "tooltip_lock": ["middle"]})
	_on_source(c, 59)
	assert_true(not c.is_open(), "the new 1 s delay holds")
	_on_source(c, 1)
	assert_true(c.is_open())
	_in_level(c, 300, 0)
	assert_true(not c.is_locked(), "timer lock off: resting does not lock")
	assert_true(not c.click(MOUSE_BUTTON_LEFT, {"level": 0}, false) and not c.is_locked(), "click lock off")
	_away(c, 119)
	assert_true(c.is_open(), "2 s grace: still open after 119 frames")
	_away(c, 1)
	assert_true(not c.is_open(), "closed at 2 s")
