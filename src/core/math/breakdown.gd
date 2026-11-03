class_name Breakdown
extends RefCounted
## A number that remembers how it was computed, so every value in the game can be
## explained to the player (pillar: Every Number Is Bounded and Visible).
##
## Usage:
## [codeblock]
## var b := Breakdown.new("Tu luyện / mùa")
## b.base("Realm base", 10.0)
## b.mul("Linh căn curve", 0.6)
## b.add_pct("Kinh Mạch Đồ", 12.0)
## print(b.total)          # 6.72
## print("\n".join(b.lines()))
## [/codeblock]

## Label of the quantity being computed.
var label: String = ""
## Current value after all steps.
var total: float = 0.0
## Ordered steps: {label, op, value, after}.
var steps: Array = []


func _init(quantity_label: String = "") -> void:
	label = quantity_label


## Sets the starting value.
func base(step_label: String, value: float) -> Breakdown:
	total = value
	steps.append({"label": step_label, "op": "=", "value": value, "after": total})
	return self


## Adds a flat amount.
func add(step_label: String, value: float) -> Breakdown:
	total += value
	steps.append({"label": step_label, "op": "+", "value": value, "after": total})
	return self


## Multiplies by a factor.
func mul(step_label: String, factor: float) -> Breakdown:
	total *= factor
	steps.append({"label": step_label, "op": "x", "value": factor, "after": total})
	return self


## Multiplies by (1 + pct/100); skipped when pct is zero.
func add_pct(step_label: String, pct: float) -> Breakdown:
	if is_zero_approx(pct):
		return self
	return mul("%s (%+.1f%%)" % [step_label, pct], 1.0 + pct / 100.0)


## Clamps the running total, recording a step only when the clamp changed it.
func clamp_to(lo: float, hi: float, step_label: String = "clamp") -> Breakdown:
	var before: float = total
	total = clampf(total, lo, hi)
	if not is_equal_approx(before, total):
		steps.append({"label": "%s [%s..%s]" % [step_label, _fmt(lo), _fmt(hi)], "op": "clamp", "value": total, "after": total})
	return self


## Renders the computation as text lines, one per step.
func lines() -> PackedStringArray:
	var out := PackedStringArray()
	if label != "":
		out.append("%s = %s" % [label, _fmt(total)])
	for s in steps:
		match s.op:
			"=":
				out.append("    %-34s = %s" % [s.label, _fmt(s.value)])
			"+":
				out.append("    %-34s %s%s  -> %s" % [s.label, "+" if s.value >= 0.0 else "", _fmt(s.value), _fmt(s.after)])
			"x":
				out.append("    %-34s x%s  -> %s" % [s.label, _fmt(s.value), _fmt(s.after)])
			_:
				out.append("    %-34s -> %s" % [s.label, _fmt(s.after)])
	return out


## Serializable form for logs and saves.
func to_dict() -> Dictionary:
	return {"label": label, "total": total, "steps": steps.duplicate(true)}


static func _fmt(v: float) -> String:
	if absf(v) >= 1000.0:
		return "%.0f" % v
	if is_equal_approx(v, roundf(v)):
		return "%d" % int(roundf(v))
	return "%.2f" % v
