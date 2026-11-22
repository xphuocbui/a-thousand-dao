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
	return "%s %d / %d" % [TranslationServer.translate("age"), int(floor(age)), int(floor(lifespan))]


## Element 10's warning: true when [param warn_share] (lifespan_warn_share) or less of the lifespan is left.
static func lifespan_warning(age: float, lifespan: float, warn_share: float) -> bool:
	if lifespan <= 0.0:
		return true
	return (lifespan - age) / lifespan <= warn_share


## Element 2: linh thạch with thousands separators, "1,240".
static func stones_text(amount: float) -> String:
	var n: int = int(floor(amount))
	var neg: bool = n < 0
	var digits: String = str(absi(n))
	var out: String = ""
	while digits.length() > 3:
		out = "," + digits.substr(digits.length() - 3) + out
		digits = digits.substr(0, digits.length() - 3)
	return ("-" if neg else "") + digits + out
