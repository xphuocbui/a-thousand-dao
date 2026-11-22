class_name TurnController
extends RefCounted
## The Civ-style season turn on the UI side (design/ux/hud.md, HUD Philosophy rule 1 and The turn): the player picks
## one season focus, then End turn resolves it. Greybox: Cultivate, Explore here, a Mission here, and Travel to a
## known place.
##
## It does not change the session code: End turn calls the session's existing timed command for the focus
## (`cultivate(1)`, `explore()`, `mission()` or `travel(dest)`), which passes the season itself. The session is
## injected and only needs `has_pending_event()`, those four commands and a `player` with `location_id`, so tests use
## a fake.
##
## Usage:
## [codeblock]
## var tc := TurnController.new(session)
## tc.choose_travel("l52", "Lạc Hà Thành")
## if tc.gate().ok: var r := tc.end_turn()
## [/codeblock]

const FOCUS_CULTIVATE := "cultivate"
const FOCUS_TRAVEL := "travel"
const FOCUS_EXPLORE := "explore"
const FOCUS_MISSION := "mission"

var _session: Object
## The chosen focus (FOCUS_*).
var focus: String = FOCUS_CULTIVATE
## Travel's destination place id ("" for other focuses).
var destination_id: String = ""
## Travel's destination name, for labels.
var destination_name: String = ""
## Set by the screen while a Z7 window (summary, event card) is open: the gate refuses End turn then.
var window_open: bool = false
## Set by the screen while a season resolves on the worker thread.
var resolving: bool = false
## The note shown after a fallback to Cultivate ("" when none).
var fallback_note: String = ""


func _init(session: Object) -> void:
	_session = session


## Sets the focus to Cultivate.
func choose_cultivate() -> void:
	focus = FOCUS_CULTIVATE
	destination_id = ""
	destination_name = ""
	fallback_note = ""


## Sets the focus to exploring the current place.
func choose_explore() -> void:
	choose_cultivate()
	focus = FOCUS_EXPLORE


## Sets the focus to a mission at the current place (a sect headquarters or a place with bounties).
func choose_mission() -> void:
	choose_cultivate()
	focus = FOCUS_MISSION


## Sets the focus to Travel towards [param place_id] (named [param place_name]).
func choose_travel(place_id: String, place_name: String) -> void:
	focus = FOCUS_TRAVEL
	destination_id = place_id
	destination_name = place_name
	fallback_note = ""


## The End turn button's label for the current state, in the HUD's order of precedence
## (element 15: an event waiting outranks everything else).
func button_label() -> String:
	if _session.has_pending_event():
		return tr_text("Event waiting")
	if resolving:
		return tr_text("The world turns…")
	return tr_text("End turn") + ": " + focus_label()


## The focus as the selector shows it.
func focus_label() -> String:
	match focus:
		FOCUS_TRAVEL:
			return tr_text("Travel to") + " " + destination_name
		FOCUS_EXPLORE:
			return tr_text("Explore")
		FOCUS_MISSION:
			return tr_text("Mission")
	return tr_text("Cultivate")


## The End turn gate (The turn: one End turn gate): {ok, reason}. Slice 1 checks the inhibitors it has: a season
## resolving, a Z7 window open, a blocking event, and a Travel focus without a destination.
func gate() -> Dictionary:
	if resolving:
		return {"ok": false, "reason": tr_text("The season is resolving.")}
	if _session.has_pending_event():
		return {"ok": false, "reason": tr_text("An event is waiting for your answer.")}
	if window_open:
		return {"ok": false, "reason": tr_text("Close the open window first.")}
	if focus == FOCUS_TRAVEL and destination_id == "":
		return {"ok": false, "reason": tr_text("Pick a destination on the map.")}
	return {"ok": true, "reason": ""}


## Runs the season for the chosen focus through the session's existing command. Call it only when [method gate]
## is ok (on the worker thread from the screen). Returns the session's {ok, lines}.
func end_turn() -> Dictionary:
	match focus:
		FOCUS_TRAVEL:
			return _session.travel(destination_id)
		FOCUS_EXPLORE:
			return _session.explore()
		FOCUS_MISSION:
			return _session.mission()
	return _session.cultivate(1)


## Applies the default-focus rule after a turn (The turn: Default focus): the focus carries over; a journey that has
## arrived (or could not start), and any other focus that could not be done, falls back to Cultivate, and
## [member fallback_note] names the old focus and why.
func after_turn(result: Dictionary) -> void:
	fallback_note = ""   # a note is shown for the turn that made it, not carried into the next one
	if focus == FOCUS_CULTIVATE:
		return
	if focus != FOCUS_TRAVEL:
		if not bool(result.get("ok", false)):
			var label: String = focus_label()
			choose_cultivate()
			fallback_note = label + ": " + tr_text("could not be done") + ". " + tr_text("Focus back to Cultivate.")
		return
	var arrived: bool = str(_session.player.location_id) == destination_id
	if arrived or not bool(result.get("ok", false)):
		var why: String = tr_text("you arrived") if arrived else tr_text("the journey could not start")
		var old: String = destination_name
		choose_cultivate()
		fallback_note = tr_text("Travel to") + " " + old + ": " + why + ". " + tr_text("Focus back to Cultivate.")


## Translates [param text] (UI strings go through the localisation system; with no tables loaded it is the key).
func tr_text(text: String) -> String:
	return TranslationServer.translate(text)
