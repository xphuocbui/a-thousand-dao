extends DaoTestSuite
## The combat-formation catalogue (assets/data/crafting_diagrams.json, 50 diagrams approved by the user 2026-11-24;
## design/gdd/formations.md rules 1, 3, 7 amended): every record is well formed (node and link indices, unlock levels
## within its max_level, a link opening no earlier than its nodes), fits its realm's art slots at level 1, keeps its
## reservation under the cap, uses only rule types, art tags and gate reads the engine runs; levels open nodes and
## links (rule 7); the starter exists; NPCs stay on the default line while npc_use is false.


func _cat() -> Array:
	return Array(Diagrams.cfg(game_data()).get("diagrams", []))


func _tags() -> Dictionary:
	var out := {}
	_walk_tags(game_data().file("combat_library"), out)
	return out


static func _walk_tags(o: Variant, out: Dictionary) -> void:
	if o is Dictionary:
		if (o as Dictionary).get("tags") is Array:
			for t in o.tags:
				out[str(t)] = true
		for v in (o as Dictionary).values():
			_walk_tags(v, out)
	elif o is Array:
		for v in o:
			_walk_tags(v, out)


func test_the_catalogue_has_fifty_unique_well_formed_diagrams() -> void:
	var cat := _cat()
	assert_eq(cat.size(), 50, "the approved 50")
	var ids := {}
	for d in cat:
		assert_false(ids.has(str(d.id)), "unique id %s" % d.id)
		ids[str(d.id)] = true
		var n: int = Array(d.nodes).size()
		var top: int = int(d.get("max_level", 5))
		assert_true(top >= 1 and top <= int(Diagrams.cfg(game_data()).strength.max_level), "%s max_level" % d.id)
		for nd in d.nodes:
			assert_true(int(nd.get("unlock", 1)) >= 1 and int(nd.get("unlock", 1)) <= top, "%s node unlock within max_level" % d.id)
			assert_true(["+", "-", "?"].has(str(nd.polarity)), "%s polarity" % d.id)
			assert_true(Array(nd.get("pos", [])).size() == 2, "%s node pos for drawing" % d.id)
		for l in d.links:
			var ends: Array = [int(l.a), int(l.b)] if str(l.kind) == "adj" else [int(l.from), int(l.to)]
			assert_true(ends[0] >= 1 and ends[0] <= n and ends[1] >= 1 and ends[1] <= n and ends[0] != ends[1], "%s link indices" % d.id)
			assert_true(int(l.get("unlock", 1)) >= maxi(int(d.nodes[ends[0] - 1].get("unlock", 1)), int(d.nodes[ends[1] - 1].get("unlock", 1))),
				"%s: a link opens no earlier than its nodes" % d.id)


func test_every_diagram_fits_its_realm_at_level_one_and_keeps_its_reservation_under_the_cap() -> void:
	var gd := game_data()
	var sl: Array = gd.file("combat_library").get("constants", {}).get("slots_by_realm", [3, 4, 5, 6, 7])
	var cap: float = CombatConstants.from_game_data(gd).reserve_cap
	for d in _cat():
		var slots: int = int(sl[clampi(int(d.realm_min), 0, sl.size() - 1)])
		assert_true(bool(Diagrams.can_set(d, slots, 0.0, 0.0, cap, 1).ok), "%s can be set at realm %d with %d slots" % [d.id, int(d.realm_min), slots])


func test_rules_use_only_what_the_engine_runs() -> void:
	var gd := game_data()
	var tags := _tags()
	var ec := EffectCompiler.new(CombatConstants.from_game_data(gd))
	for d in _cat():
		for nd in d.nodes:
			var r: Dictionary = nd.rule
			assert_true(["mod", "adj_mod", "gate"].has(str(r.type)), "%s rule type" % d.id)
			if str(r.type) == "mod":
				assert_true(["damage_pct", "art_speed_pct", "art_cost_pct"].has(str(r.key)), "%s mod key" % d.id)
				for t in Array(r.get("scope", [])):
					assert_true(tags.has(str(t)), "%s: tag %s is on some art" % [d.id, t])
			elif str(r.type) == "adj_mod":
				assert_true(tags.has(str(r.tag)), "%s: tag %s is on some art" % [d.id, r.tag])
			else:
				ec.errors.clear()
				ec.compile_conds([r.cond], "catalogue %s" % d.id, {})
				assert_true(ec.errors.is_empty(), "%s gate compiles: %s" % [d.id, ", ".join(ec.errors)])


func test_levels_open_nodes_and_links() -> void:
	var gd := game_data()
	var serpent: Dictionary = Diagrams.record_of(gd, "truong_xa")
	assert_eq([1, 2, 3].map(func(L): return Diagrams.open_count(serpent, L)), [2, 3, 4], "the Long Serpent Line grows 2, 3, 4")
	var poles: Dictionary = Diagrams.record_of(gd, "luong_nghi")
	assert_eq(Diagrams.level_eff(gd, 5, 9, false, int(poles.max_level)), 1, "a one-level diagram stays at level 1")
	# a closed node holds no art and a closed feed does nothing (rule 7)
	var p := FighterProfile.new()
	var arts: Array[ArtDef] = []
	for id in ["a", "b", "c"]:
		var a := ArtDef.new()
		a.id = id
		arts.append(a)
	p.arts = arts
	Diagrams.apply(gd, p, serpent, ["a", "b", "c", ""], 1.0, 1.0, 0.0, 1)
	assert_eq(p.feeds.size(), 1, "at level 1 only the tail-to-head feed of the two open nodes runs")
	assert_eq(str(p.arts[2].id), "c", "the art placed in the closed node 3 stays a plain slot")


func test_the_starter_exists_and_npcs_stay_on_the_default_line() -> void:
	var gd := game_data()
	var c: Dictionary = Diagrams.cfg(gd)
	assert_false(Diagrams.record_of(gd, str(c.starter)).is_empty(), "the starter is in the catalogue")
	assert_false(bool(c.get("npc_use", true)), "NPCs keep the default line (user 2026-11-24)")
