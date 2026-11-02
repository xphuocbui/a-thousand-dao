# PROTOTYPE - NOT FOR PRODUCTION
# Question: Does drafting/fusing fragments into a chain engine make players rework builds, and can a local LLM narrate it within engine budgets?
# Date: 2026-11-02
extends SceneTree

# Headless balance sim: godot --headless --path . -s sim.gd
# Measures build spread (hypothesis A: best vs worst >= 10x) and calibrates enemy HP.

const Core := preload("res://core.gd")


func _permutations(arr: Array) -> Array:
	if arr.size() <= 1:
		return [arr.duplicate()]
	var out: Array = []
	for i in arr.size():
		var rest: Array = arr.duplicate()
		var head = rest[i]
		rest.remove_at(i)
		for p in _permutations(rest):
			p.push_front(head)
			out.append(p)
	return out


func _stats(vals: Array) -> String:
	vals.sort()
	var n: int = vals.size()
	return "min %.0f  p25 %.0f  median %.0f  p75 %.0f  max %.0f" % [vals[0], vals[n / 4], vals[n / 2], vals[3 * n / 4], vals[n - 1]]


func _init() -> void:
	var core = Core.new()
	var rng := RandomNumberGenerator.new()
	rng.seed = 12345

	# determinism check: same seed -> same dice result
	var b: Array = [Core.POOL[0], Core.POOL[5], Core.POOL[1]]
	var r1 := RandomNumberGenerator.new()
	r1.seed = 99
	var r2 := RandomNumberGenerator.new()
	r2.seed = 99
	var t1: float = core.simulate(b, r1).total
	var t2: float = core.simulate(b, r2).total
	print("determinism: %s (%.2f vs %.2f)" % ["OK" if t1 == t2 else "FAIL", t1, t2])

	# amp chain sanity: two amps then a strike multiplies
	var amp_chain: Array = [Core.POOL[5], Core.POOL[6], Core.POOL[0]]
	var plain: Array = [Core.POOL[0]]
	print("amp chain total %.1f vs plain strike %.1f (expect %.2fx)" % [core.simulate(amp_chain).total, core.simulate(plain).total, 1.6 * 1.5])

	for size in [3, 5, 6]:
		var random_order: Array = []
		var best_order: Array = []
		for trial in 300:
			var picks: Array = []
			for n in size:
				picks.append(Core.POOL[rng.randi_range(0, Core.POOL.size() - 1)])
			random_order.append(core.simulate(picks).total)
			if size <= 6:
				var best: float = 0.0
				for p in _permutations(picks):
					best = max(best, core.simulate(p).total)
				best_order.append(best)
		print("size %d random order : %s" % [size, _stats(random_order)])
		print("size %d best ordering: %s" % [size, _stats(best_order)])
		var ro: Array = random_order.duplicate()
		var bo: Array = best_order.duplicate()
		ro.sort()
		bo.sort()
		print("size %d spread: worst random %.0f -> best ordered %.0f = %.1fx; median ordering gain %.2fx" % [size, ro[0], bo[bo.size() - 1], bo[bo.size() - 1] / max(ro[0], 1.0), bo[bo.size() / 2] / max(ro[ro.size() / 2], 1.0)])

	# draft sim: 6 picks of 1-of-3. naive = random pick, greedy = pick maximizing best ordering.
	var naive: Array = []
	var greedy: Array = []
	for trial in 200:
		var nb: Array = []
		var gb: Array = []
		for step in 6:
			var offers: Array = core.draw_offers(rng)
			nb.append(offers[rng.randi_range(0, 2)])
			var best_total: float = -1.0
			var best_offer: Dictionary = offers[0]
			for o in offers:
				var cand: Array = gb.duplicate()
				cand.append(o)
				var bt: float = 0.0
				for p in _permutations(cand):
					bt = max(bt, core.simulate(p).total)
				if bt > best_total:
					best_total = bt
					best_offer = o
			gb.append(best_offer)
		naive.append(core.simulate(nb).total)
		var gbest: float = 0.0
		for p in _permutations(gb):
			gbest = max(gbest, core.simulate(p).total)
		greedy.append(gbest)
	print("draft naive : %s" % _stats(naive))
	print("draft greedy: %s" % _stats(greedy))
	var nv: Array = naive.duplicate()
	var gv: Array = greedy.duplicate()
	nv.sort()
	gv.sort()
	print("draft median ratio greedy/naive: %.2fx   p90 ratio: %.2fx   best greedy / worst naive: %.1fx" % [gv[gv.size() / 2] / nv[nv.size() / 2], gv[gv.size() * 9 / 10] / nv[nv.size() * 9 / 10], gv[gv.size() - 1] / max(nv[0], 1.0)])

	# fusion check
	var f: Dictionary = core.fuse(Core.POOL[8], Core.POOL[11])
	print("fusion Furnace+Pill -> %s dmg %.1f param %.1f" % [f.name, f.dmg, f.param])
	quit()
