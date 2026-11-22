extends DaoTestSuite
## EscRouter (design/ux/hud.md, Platform Adaptation: Esc; acceptance criteria "Windows, Esc and focus"): the focused
## window first, then the ranked list, one thing per press.


func test_a_pointer_locked_tooltip_over_a_focused_summary_closes_the_summary_first() -> void:
	var s := {"focus": "z7", "z7_open": true, "tooltip_open": true}
	assert_eq(EscRouter.pick(s), "z7", "first Esc closes the summary")
	s.focus = ""
	s.z7_open = false
	assert_eq(EscRouter.pick(s), "tooltip", "second Esc closes the tooltip")


func test_a_tooltip_opened_with_q_from_a_panel_closes_before_the_panel() -> void:
	assert_eq(EscRouter.pick({"focus": "tooltip", "tooltip_open": true, "panel_open": true}), "tooltip")
	assert_eq(EscRouter.pick({"focus": "panel", "panel_open": true}), "panel", "then the panel, focus back on it")


func test_an_armed_confirm_is_cancelled_before_a_pointer_locked_tooltip_closes() -> void:
	var s := {"confirm_armed": true, "tooltip_open": true}
	assert_eq(EscRouter.pick(s), "confirm")
	s.confirm_armed = false
	assert_eq(EscRouter.pick(s), "tooltip")


func test_the_banner_is_skipped_first() -> void:
	assert_eq(EscRouter.pick({"banner": true, "tooltip_open": true, "confirm_armed": true}), "banner")


func test_a_focused_panel_over_a_blocking_card_closes_and_the_card_is_only_minimised_after() -> void:
	assert_eq(EscRouter.pick({"focus": "panel", "panel_open": true, "z7_open": true, "card_blocking": true}), "panel")
	assert_eq(EscRouter.pick({"focus": "z7", "z7_open": true, "card_blocking": true}), "card", "minimised, never dismissed")


func test_a_closed_door_run_goes_on_when_a_focused_panel_closes() -> void:
	assert_eq(EscRouter.pick({"focus": "panel", "panel_open": true, "running": true}), "panel")
	assert_eq(EscRouter.pick({"running": true}), "stop", "Esc again stops the run")


func test_a_modal_takes_esc_whatever_has_focus() -> void:
	assert_eq(EscRouter.pick({"modal_open": true, "focus": "panel", "tooltip_open": true}), "modal")


func test_with_nothing_open_esc_opens_the_game_menu_and_in_a_fight_only_settings() -> void:
	assert_eq(EscRouter.pick({}), "menu")
	assert_eq(EscRouter.pick({"in_fight": true, "tooltip_open": true}), "settings")


func test_unfocused_panels_close_in_the_ranked_order() -> void:
	assert_eq(EscRouter.pick({"panel_open": true, "places_open": true}), "panel")
	assert_eq(EscRouter.pick({"places_open": true}), "places")
