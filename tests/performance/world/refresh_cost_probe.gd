extends SceneTree
## Probe (observation only): the cost of BuildGenerator.refresh_power (a stage-up's power refresh) and of the people
## loop's other parts, on the built continent.

func _init() -> void:
	var gd := GameData.load_from("res://assets/data")
	gd.file("combat_rankings")["enabled"] = false
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	var tree := DaoDoTree.load_map(gd)
	var builder := WorldBuilder.new(gd, tree)
	var db: WorldDB = builder.generate(rng, "11")
	var builds := BuildGenerator.new(gd, tree, db)
	var people: Array = db.find("people", func(p): return bool(p.alive) and not bool(p.get("is_beast", false)))
	var t0: int = Time.get_ticks_usec()
	for i in 400:
		builds.refresh_power(str(people[i * 7 % people.size()].id))
	print("refresh_power: %.2f ms each (400 calls %.0f ms)" % [float(Time.get_ticks_usec() - t0) / 400000.0, float(Time.get_ticks_usec() - t0) / 1000.0])
	t0 = Time.get_ticks_usec()
	for i in 400:
		Character.from_dict(people[i * 7 % people.size()])
	print("from_dict: %.3f ms each" % (float(Time.get_ticks_usec() - t0) / 400000.0))
	t0 = Time.get_ticks_usec()
	var n: int = 0
	for p in db.all("people"):
		if bool(p.alive):
			n += 1
	print("db.all loop: %.1f ms" % (float(Time.get_ticks_usec() - t0) / 1000.0))
	t0 = Time.get_ticks_usec()
	for i in 400:
		ProgressionEdges.npc_step_chance(people[i * 7 % people.size()], gd)
	print("npc_step_chance: %.3f ms each" % (float(Time.get_ticks_usec() - t0) / 400000.0))
	var cs: Array = []
	for i in 200:
		cs.append(Character.from_dict(people[i * 7 % people.size()]))
	t0 = Time.get_ticks_usec()
	var sheets: Array = []
	for c in cs:
		sheets.append(builds.sheet_of(c))
	print("sheet_of: %.3f ms each" % (float(Time.get_ticks_usec() - t0) / 200000.0))
	t0 = Time.get_ticks_usec()
	for i in cs.size():
		CombatPower.compute(cs[i], gd, db, sheets[i])
	print("CombatPower.compute: %.3f ms each" % (float(Time.get_ticks_usec() - t0) / 200000.0))
	t0 = Time.get_ticks_usec()
	for c in cs:
		tree.collect_mods(c, gd)
	print("collect_mods: %.3f ms each (nodes %d)" % [float(Time.get_ticks_usec() - t0) / 200000.0, cs[0].tree_nodes.size()])
	t0 = Time.get_ticks_usec()
	for c in cs:
		var sh := StatSheet.new()
		for m in tree.collect_mods(c, gd):
			sh.add_mod(m.source, m.stat, m.value, "tree", m.scope)
	print("collect + add_mod: %.3f ms each" % (float(Time.get_ticks_usec() - t0) / 200000.0))
	var parts := {"effect_lines": 0, "perks": 0, "formations": 0, "cong_phap": 0, "caps_traits": 0, "controlled": 0, "effect_from": 0}
	for c in cs:
		var sh := StatSheet.new()
		sh._gd = gd
		var u: int = Time.get_ticks_usec()
		sh._add_tree_effect_lines(c, tree)
		parts.effect_lines += Time.get_ticks_usec() - u
		u = Time.get_ticks_usec()
		ProgressionEdges.add_perk_mods(c, gd, sh)
		parts.perks += Time.get_ticks_usec() - u
		u = Time.get_ticks_usec()
		Formations.add_mods(c, gd, sh)
		parts.formations += Time.get_ticks_usec() - u
		u = Time.get_ticks_usec()
		CongPhap.bonus_lines(c, gd, sh.effective("can_cot", c), sh.effective("ngo_tinh", c))
		parts.cong_phap += Time.get_ticks_usec() - u
		u = Time.get_ticks_usec()
		sh._add_capability_mods(c)
		sh._add_trait_mods(c)
		parts.caps_traits += Time.get_ticks_usec() - u
		u = Time.get_ticks_usec()
		CombatPower.controlled(c, gd, db, sh)
		parts.controlled += Time.get_ticks_usec() - u
		u = Time.get_ticks_usec()
		sh._add_tree_effect_from(c, tree)
		parts.effect_from += Time.get_ticks_usec() - u
	var o: Array = []
	for k in parts:
		o.append("%s %.3f" % [k, float(parts[k]) / 200000.0])
	print("sheet parts ms each: " + ", ".join(PackedStringArray(o)))
	quit()
