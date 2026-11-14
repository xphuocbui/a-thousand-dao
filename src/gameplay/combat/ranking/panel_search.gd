class_name PanelSearch
extends RefCounted
## The ladder search and base solve of Power Rankings Formulas B (design/gdd/power-rankings.md), the GDScript twin of
## tools/design/combat_sim/export_rankings_calibration.py's search() and solve_base(). Pure: the fights come in
## through a probe Callable, so tests can script results and the rating service can run real fights.
##
## Usage:
## [codeblock]
## var probe := func(k: int, fights: int) -> float: return score_against_rung(k, fights)
## var r: Dictionary = PanelSearch.search(probe, ladder, 32, 0, 8, 1, 4, 1.0)   # a cold search
## var base: float = r.base   # r.probes: [[rung, fights, score], ...] in the order they ran
## [/codeblock]

## Bisection steps for the base (Formulas B: the left side rises strictly in R, so the root is unique).
const BISECT_STEPS := 60


## Formulas A: a's expected score against b.
static func expected(ra: float, rb: float) -> float:
	return 1.0 / (1.0 + pow(10.0, (rb - ra) / 400.0))


## Formulas B's base: R* with sum n_p E(R*, L_kp) + prior E(R*, start) = sum S_p + prior / 2, by bisection on
## [ladder min - 2000, ladder max + 2000]. [param probes] holds [rung rating, fights, score] triples.
static func solve_base(probes: Array, start_rating: float, ladder: PackedFloat64Array, prior: float) -> float:
	var lo: float = ladder[0] - 2000.0
	var hi: float = ladder[ladder.size() - 1] + 2000.0
	var want: float = prior * 0.5
	for p in probes:
		want += float(p[2])
	for i in BISECT_STEPS:
		var mid: float = (lo + hi) / 2.0
		var got: float = prior * expected(mid, start_rating)
		for p in probes:
			got += float(p[1]) * expected(mid, float(p[0]))
		if got < want:
			lo = mid
		else:
			hi = mid
	return (lo + hi) / 2.0


## Formulas B's search on [param ladder] (rung k at index k + k_max). [param probe] is Callable(k: int, fights: int)
## -> float score. Starts at [param start_k] with [param step], doubling the step each move until the result flips or
## the move reaches ±k_max, then bisects the win/loss bracket down to [param bracket_stop] rungs. Returns
## {base, probes: [[k, fights, score], ...], fights}.
static func search(probe: Callable, ladder: PackedFloat64Array, k_max: int, start_k: int, step: int, bracket_stop: int,
		fights: int, prior: float) -> Dictionary:
	var done: Array = []
	var run := func(k: int) -> bool:
		var s: float = probe.call(k, fights)
		done.append([k, fights, s])
		return s > float(fights) / 2.0
	var k: int = start_k
	var won: bool = run.call(k)
	var last_win: Variant = k if won else null
	var last_loss: Variant = null if won else k
	while true:
		var nk: int = clampi(k + (step if won else -step), -k_max, k_max)
		if nk == k:
			break
		k = nk
		won = run.call(k)
		if won:
			last_win = k if last_win == null or k > int(last_win) else last_win
		else:
			last_loss = k if last_loss == null or k < int(last_loss) else last_loss
		if last_win != null and last_loss != null and int(last_loss) > int(last_win):
			break
		if absi(k) == k_max:
			break
		step *= 2
	if last_win != null and last_loss != null and int(last_loss) > int(last_win):
		while int(last_loss) - int(last_win) > bracket_stop:
			var mid: int = floori((int(last_win) + int(last_loss)) / 2.0)
			if run.call(mid):
				last_win = mid
			else:
				last_loss = mid
	var rungs: Array = []
	var total := 0
	for d in done:
		rungs.append([ladder[int(d[0]) + k_max], d[1], d[2]])
		total += int(d[1])
	return {"base": solve_base(rungs, ladder[start_k + k_max], ladder, prior), "probes": done, "fights": total}
