extends SceneTree
## Probe (observation only): the NPCs' per-realm breakthrough fate (ProgressionEdges.npc_step_chance) over the built
## world's people, by realm: mean, the share above the base, and the mean edge, against the difficulty targets 1 in
## 8 / 12 / 15 / 20 (plan decision 11, 2026-11-21: why Kết Đan and Nguyên Anh run above Realms' counts).

func _init() -> void:
	var gd := GameData.load_from("res://assets/data")
	gd.file("combat_rankings")["enabled"] = false
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	var db: WorldDB = WorldBuilder.new(gd, DaoDoTree.load_map(gd)).generate(rng, "11")
	var steps: Array = ProgressionEdges.config(gd).npc.gate_steps
	for r in steps.size():
		var ps: Array = []
		for p in db.living():
			if int(p.get("realm_index", -1)) == r and not bool(p.get("is_beast", false)) and not bool(p.get("is_player", false)):
				ps.append(float(ProgressionEdges.npc_step_chance(p, gd).total))
		if ps.is_empty():
			continue
		var mean: float = ps.reduce(func(a, x): return a + x, 0.0) / ps.size()
		var above: int = ps.filter(func(x): return x > float(steps[r].base) + 1e-9).size()
		ps.sort()
		print("gate %d -> %d: n %d, base %.3f, mean %.3f (1 in %.1f), above base %d (%.0f %%), median %.3f, p90 %.3f, max %.3f" % [r, r + 1, ps.size(), float(steps[r].base), mean, 1.0 / mean, above, 100.0 * above / ps.size(), ps[ps.size() / 2], ps[int(ps.size() * 0.9)], ps[-1]])
	quit()
