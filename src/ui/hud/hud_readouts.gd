class_name HudReadouts
extends RefCounted
## Pure formatting for the HUD's always-on readouts (design/ux/hud.md, HUD Element Specifications 2, 3, 8, 9, 10):
## numbers in, display text out, so the screen holds no rules of its own and tests need no scene.


## Element 9: cultivation progress to the next level as a 0..1 share ([param requirement] 0 or less gives 1).
static func cultivation_share(tu_vi: float, requirement: float) -> float:
	if requirement <= 0.0:
		return 1.0
	return clampf(tu_vi / requirement, 0.0, 1.0)


## Element 9's text: "62%".
static func cultivation_text(tu_vi: float, requirement: float) -> String:
	return "%d%%" % int(floor(cultivation_share(tu_vi, requirement) * 100.0))


## Element 10: "age 84 / 220" (whole years, rounded down).
static func lifespan_text(age: float, lifespan: float) -> String:
	return "%s %s" % [TranslationServer.translate("age"), lifespan_numbers(age, lifespan)]


## Element 10's numbers alone, "84 / 220": the tooltipable part of the readout (styled as a number).
static func lifespan_numbers(age: float, lifespan: float) -> String:
	return "%d / %d" % [int(floor(age)), int(floor(lifespan))]


## Element 10's warning: true when [param warn_share] (lifespan_warn_share) or less of the lifespan is left.
static func lifespan_warning(age: float, lifespan: float, warn_share: float) -> bool:
	if lifespan <= 0.0:
		return true
	return (lifespan - age) / lifespan <= warn_share


## The number separators of the current language (hud.md Localisation: numbers follow the language, 2026-11-22):
## [thousands, decimal], "," and "." in English, "." and "," in Vietnamese.
static func separators() -> Array:
	return [".", ","] if TranslationServer.get_locale().begins_with("vi") else [",", "."]


## Element 2: linh thạch with thousands separators, "1,240" ("1.240" in Vietnamese).
static func stones_text(amount: float) -> String:
	var n: int = int(floor(amount))
	var neg: bool = n < 0
	var digits: String = str(absi(n))
	var out: String = ""
	var sep: String = separators()[0]
	while digits.length() > 3:
		out = sep + digits.substr(digits.length() - 3) + out
		digits = digits.substr(0, digits.length() - 3)
	return ("-" if neg else "") + digits + out


## Resource boxes (elements 2, 8, 10, 33-35): the season's change as "▲ +30", "▼ −12", or "" for no change. Whole
## numbers unless [param decimals] is set; [param suffix] follows the number ("%" for the cultivation rate, " y" for
## lifespan). The sign is always printed, so the change never rests on colour or the mark alone.
static func change_text(delta: float, decimals: int = 0, suffix: String = "") -> String:
	var q: float = snappedf(delta, pow(10.0, -decimals)) if decimals > 0 else roundf(delta)
	if is_zero_approx(q):
		return ""
	var num: String = stones_text(absf(q)) if decimals == 0 else String.num(absf(q), decimals).replace(".", separators()[1])
	return ("▲ +" if q > 0.0 else "▼ −") + num + suffix


## The compact layout's change: the mark alone ("▲", "▼" or "").
static func change_mark(delta: float, decimals: int = 0) -> String:
	var t: String = change_text(delta, decimals)
	return t.left(1)


## Element 10's box number: whole years left, "136 y" (0 when the lifespan is spent).
static func years_left_text(age: float, lifespan: float) -> String:
	return "%d y" % maxi(0, int(floor(lifespan - age)))


## A resource box's number: grouped up to 99,999 ("1,240"), then shortened ("123k", "1.2M"); the full number stays in
## the tooltip and the accessible name (hud.md Resource box).
static func short_number(n: float) -> String:
	var a: float = absf(n)
	var sign: String = "-" if n < 0.0 else ""
	if a < 100000.0:
		return stones_text(n)
	if a < 1000000.0:
		return sign + "%dk" % int(floor(a / 1000.0))
	return sign + String.num(floor(a / 100000.0) / 10.0, 1).replace(".", separators()[1]) + "M"
