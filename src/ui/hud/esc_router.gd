class_name EscRouter
extends RefCounted
## Which one thing Esc does (design/ux/hud.md, Platform Adaptation: "Esc first acts on the window that holds focus",
## then the ranked list; user decision 2026-11-22). Pure: the screen describes its state and acts on the answer, so
## the order is tested without a window. Every press does exactly one thing and is consumed.
##
## [param s] keys (all optional, default false / ""):
## [code]in_fight[/code]; [code]modal_open[/code] (rebind capture, keep / discard prompt, settings, the game menu, the
## focus comparison); [code]focus[/code]: where focus is: "tooltip" (inside a tooltip, e.g. opened with Q), "panel",
## "places", "z7" (the centre window), or "" (the map, Z1-Z5 or nothing); [code]banner[/code]; [code]confirm_armed[/code];
## [code]tooltip_open[/code]; [code]running[/code] (a multi-season command); [code]z7_open[/code];
## [code]card_blocking[/code] (the Z7 window is a blocking event card); [code]panel_open[/code]; [code]places_open[/code].
##
## Returns one of: "settings", "modal", "tooltip", "panel", "places", "z7", "card", "banner", "confirm", "stop", "menu".


static func pick(s: Dictionary) -> String:
	if bool(s.get("in_fight", false)):
		return "settings"   # the fight spec allows no exit mid-fight
	if bool(s.get("modal_open", false)):
		return "modal"
	match str(s.get("focus", "")):
		"tooltip":
			return "tooltip"
		"panel":
			return "panel"
		"places":
			return "places"
		"z7":
			return "card" if bool(s.get("card_blocking", false)) else "z7"
	# The ranked list (focus on the map, Z1-Z5 or nothing).
	if bool(s.get("banner", false)):
		return "banner"
	if bool(s.get("confirm_armed", false)):
		return "confirm"
	if bool(s.get("tooltip_open", false)):
		return "tooltip"
	if bool(s.get("running", false)):
		return "stop"
	if bool(s.get("z7_open", false)):
		return "card" if bool(s.get("card_blocking", false)) else "z7"
	if bool(s.get("panel_open", false)):
		return "panel"
	if bool(s.get("places_open", false)):
		return "places"
	return "menu"
