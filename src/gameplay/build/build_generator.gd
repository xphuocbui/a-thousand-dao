class_name BuildGenerator
extends RefCounted
## Generates complete NPC builds with the same rules the player uses: linh căn and
## thiên phú, a công pháp, pháp bảo limited by thần thức, Đạo Đồ points spent
## greedily toward the archetype's focus lands (Đạo Đồ rule 5), and đạo nghệ skills. Every build is
## registered in the WorldDB (person + owned items) and its chiến lực cached.
## Design: game-concept.md (one ruleset for everyone; Dwarf Fortress-style people).
## Data: world_generation.json (archetypes, npc_builds, people).
##
## Usage:
## [codeblock]
## var gen := BuildGenerator.new(gd, tree, db)
## var pid: String = gen.create_person(rng, {"realm_index": 1, "archetype": "kiem_tu"})
## var c := Character.from_dict(db.get_record("people", pid))
## [/codeblock]

var _gd: GameData
var _tree: DaoDoTree
var _db: WorldDB
var _items: ItemFactory


func _init(gd: GameData, tree: DaoDoTree, db: WorldDB) -> void:
	_gd = gd
	_tree = tree
	_db = db
	_items = ItemFactory.new(gd)


## Creates and registers a person. Options (all optional):
## realm_index, stage, archetype, sect_id, sect_rank, location_id, name, gender,
## is_beast, age, created_by. Returns the person id.
func create_person(rng: RandomNumberGenerator, opts: Dictionary = {}) -> String:
	var wg: Dictionary = _gd.world_gen()
	var people_cfg: Dictionary = wg.people
	var c := Character.new()
	c.is_beast = bool(opts.get("is_beast", false))
	c.realm_index = clampi(int(opts.get("realm_index", roll_realm(rng))), 0, _gd.realms().size() - 1)
	c.stage = clampi(int(opts.get("stage", rng.randi_range(0, _gd.stage_count(c.realm_index) - 1))), 0, _gd.stage_count(c.realm_index) - 1)
	c.level = Ladder.stage_first_level(_gd, c.realm_index, c.stage)
	c.level_peak = c.level
	c.tu_vi = 0.0
	var arch_id: String = str(opts.get("archetype", ""))
	if arch_id == "" or _gd.archetype(arch_id).is_empty():
		arch_id = str(RngUtils.weighted_pick(rng, wg.archetypes).id)
	c.archetype = "yeu_thu" if c.is_beast else arch_id
	c.gender = str(opts.get("gender", "female" if rng.randf() < float(people_cfg.female_chance) else "male"))
	c.name = str(opts.get("name", beast_name(rng) if c.is_beast else person_name(rng, c.gender)))
	c.thien_phu = CharacterFactory.roll_thien_phu(_gd, rng)
	c.linh_can = LinhCan.roll(_gd, rng)
	if not c.is_beast:
		arch_id = _fit_archetype(rng, arch_id, c.linh_can)
		c.archetype = arch_id
	var lifespan: float = float(_gd.realm(c.realm_index).lifespan)
	var min_age: float = float(people_cfg.age_min_by_realm[c.realm_index])
	c.age = float(opts.get("age", rng.randf_range(min_age, maxf(min_age + 1.0, lifespan * float(people_cfg.age_max_lifespan_frac)))))
	c.sect_id = str(opts.get("sect_id", ""))
	c.sect_rank = str(opts.get("sect_rank", ""))
	c.location_id = str(opts.get("location_id", ""))
	if not c.is_beast:
		var traits: Array = RngUtils.shuffled(rng, _gd.names().traits).slice(0, int(people_cfg.traits_per_person))
		c.traits = traits.map(func(t): return t.id)
		ProgressionEdges.assign_npc_edges(c, _gd, rng)

	c.id = str(opts.get("id", ""))   # a person whose id was reserved earlier (WorldBuilder's cast)
	var record: Dictionary = c.to_dict()
	record["created_by"] = str(opts.get("created_by", "worldgen"))
	var pid: String = _db.add("people", record)
	c.id = pid
	if not c.is_beast and _gd.registry.has_file(NpcTraits.FILE):   # NPC Traits F4, keyed on the id (a reload rolls the same)
		c.npc_traits = NpcTraits.roll(_gd, pid, str(arch_id), c.sect_id != "")
	if not c.is_beast:
		_equip_build(c, rng, arch_id)
		_allocate_tree(c, rng, arch_id)
		_train_skills(c, rng, arch_id)
	var fresh: Dictionary = c.to_dict()
	fresh["created_by"] = record.created_by
	fresh["power"] = power_of(c)
	_db.put("people", fresh)
	return pid


## Recomputes and caches chiến lực for a person record.
func refresh_power(person_id: String) -> float:
	var rec: Dictionary = _db.get_record("people", person_id)
	if rec.is_empty():
		return 0.0
	var c := Character.from_dict(rec)
	var p: float = power_of(c)
	rec["power"] = p
	return p


## The stat sheet of [param c] with its Đạo Đồ allocations (chiến lực and fights read the same sheet).
func sheet_of(c: Character) -> StatSheet:
	return StatSheet.build(c, _gd, _db, _tree)


## Chiến lực of a character under the shared rules.
func power_of(c: Character) -> float:
	var sheet := sheet_of(c)
	var power: float = CombatPower.compute(c, _gd, _db, sheet).total
	# An NPC's capabilities act through their simplified npc_effect (Formulas G).
	for id in c.capabilities:
		var fx: Dictionary = _gd.capability(int(id)).get("npc_effect", {})
		if str(fx.get("type", "")) == "chien_luc_mult" and not c.is_player:
			power *= float(fx.value)
	return power


## An archetype never changes a root (linh-can.md rule 15). An NPC whose root lacks its
## archetype's elements usually switches to one that fits, and may keep it anyway.
func _fit_archetype(rng: RandomNumberGenerator, arch_id: String, lc: LinhCan) -> String:
	var fits := func(a: Dictionary) -> bool:
		for e in a.get("elements", []):
			if not lc.has(e):
				return false
		return true
	if fits.call(_gd.archetype(arch_id)) or rng.randf() < float(_gd.world_gen().npc_builds.archetype_keep_chance):
		return arch_id
	var options: Array = _gd.world_gen().archetypes.filter(fits)
	return arch_id if options.is_empty() else str(RngUtils.weighted_pick(rng, options).id)


## Realm index rolled from world_generation.json's distribution.
func roll_realm(rng: RandomNumberGenerator) -> int:
	var dist: Array = _gd.world_gen().realm_distribution
	return _gd.realm_index(str(RngUtils.weighted_pick(rng, dist).realm))


## Total Đạo Đồ points a cultivator at this realm/stage has earned (Realms rule 12: an
## NPC's level is the first level of its stage).
func tree_points_for(realm_index: int, stage: int) -> int:
	return Ladder.points_total(_gd, Ladder.stage_first_level(_gd, realm_index, stage))


## Random Hán-Việt person name.
func person_name(rng: RandomNumberGenerator, gender: String) -> String:
	var n: Dictionary = _gd.names()
	var given: Array = n.given_female if gender == "female" else n.given_male
	return "%s %s" % [RngUtils.pick(rng, n.surnames), RngUtils.pick(rng, given)]


## Random demon-beast name.
func beast_name(rng: RandomNumberGenerator) -> String:
	var b: Dictionary = _gd.combat().beast
	return "%s %s" % [RngUtils.pick(rng, b.name_prefixes), RngUtils.pick(rng, b.name_bases)]


func _equip_build(c: Character, rng: RandomNumberGenerator, arch_id: String) -> void:
	var cfg: Dictionary = _gd.world_gen().npc_builds
	var arch: Dictionary = _gd.archetype(arch_id)
	# Công pháp matching the strongest element(s).
	var tier: int = clampi(int(float(c.realm_index) * float(cfg.cong_phap_tier_per_realm) + rng.randf()), 0, 3)
	var elems: Array = [c.linh_can.strongest_element()]
	var cp: Dictionary = _items.cong_phap(rng, tier, elems)
	cp["owner_id"] = c.id
	_db.add("items", cp)
	CongPhap.learn(c, cp)
	c.main_tech = str(cp.tech_id)
	# NPC Build Generation sets layers to fit the realm (cong-phap.md rule 19).
	c.techniques[c.main_tech]["layer"] = mini(3 * (c.realm_index + 1), int(cp.layers))
	# Auxiliary slots (rule 6; AC-CP-42: at most 2): secret arts of the NPC's own elements, or body techniques for
	# body cultivators, at the same tier roll and layer rule as the main method (2026-11-14: generation filled none)
	var n_aux: int = mini(int(cfg.get("aux_techniques_by_realm", [0])[mini(c.realm_index, cfg.get("aux_techniques_by_realm", [0]).size() - 1)]), c.aux_tech.size())
	var own: Array = c.linh_can.elements.keys()
	for i in n_aux:
		var body: bool = Array(cfg.get("aux_body_archetypes", [])).has(arch_id)
		var t_aux: int = clampi(int(float(c.realm_index) * float(cfg.cong_phap_tier_per_realm) + rng.randf()), 0, 3)
		var names: Array = [] if body or own.is_empty() else [str(RngUtils.pick(rng, own))]
		var kind_aux: String = "body" if body else "secret"
		var aux: Dictionary = _items.cong_phap(rng, t_aux, names, "", {"kind": kind_aux})
		# an authored template already known: a few more picks, then a generated common of the top common tier
		for attempt in 3:
			if aux.is_empty() or not c.techniques.has(str(aux.tech_id)):
				break
			aux = _items.cong_phap(rng, t_aux, names, "", {"kind": kind_aux})
		if not aux.is_empty() and c.techniques.has(str(aux.tech_id)):
			aux = _items.cong_phap(rng, int(_gd.cong_phap_file().commons_tiers[-1]), names, "", {"kind": kind_aux})
		if aux.is_empty() or c.techniques.has(str(aux.tech_id)):
			continue
		aux["owner_id"] = c.id
		_db.add("items", aux)
		CongPhap.learn(c, aux)
		c.aux_tech[i] = str(aux.tech_id)
		c.techniques[str(aux.tech_id)]["layer"] = mini(3 * (c.realm_index + 1), int(aux.layers))
	# Pháp bảo, equipped while a slot is free (item-database.md rule 11).
	var count: int = mini(int(cfg.artifacts_base) + c.realm_index * int(cfg.artifacts_per_realm), int(cfg.artifacts_max))
	var bases: Array = arch.get("artifact_bases", [])
	var sheet := StatSheet.build(c, _gd, _db, _tree)
	for i in count:
		var base_id: String = str(RngUtils.pick(rng, bases)) if not bases.is_empty() else ""
		var grade: int = _items.roll_grade(rng, mini(1 + c.realm_index, 4))
		var elem: String = c.linh_can.strongest_element() if rng.randf() < float(cfg.artifact_root_element_chance) else "none"
		var art: Dictionary = _items.artifact(rng, c.realm_index, grade, elem, base_id)
		art["owner_id"] = c.id
		var aid: String = _db.add("items", art)
		var slot: String = EquipSlots.slot_for(c, _gd, _db, sheet, art)
		if slot == "":
			continue
		c.equipped.append(aid)
		c.equip_slots[aid] = slot


func _allocate_tree(c: Character, rng: RandomNumberGenerator, arch_id: String) -> void:
	var focus: Array = _gd.archetype(arch_id).get("tree_focus", []).duplicate()
	if focus.is_empty():
		focus = [c.linh_can.strongest_element()]
	var start: int = _tree.npc_start(c.linh_can, _gd)
	c.tree_nodes = [start] if start >= 0 else []
	c.tree_points = tree_points_for(c.realm_index, c.stage)
	allocate(c, rng, focus)


## Đạo Đồ rule 5 (Computational budget): spends [param c]'s points greedily from its open nodes. Every reachable
## node is scored once when first seen: its kind's `tree_kind_scores` entry, times `tree_focus_weight` when it lies in
## a land of [param focus] (or a road grants it), plus a random term drawn once. Opening a node adds only its new
## neighbours, so each point is one pop. A gated node behind a closed Chaos gate is parked and joins the ranking when
## roads open the gate; a capability notable below `cap_realm_min` is never taken. [param stats] gets the counts
## {pushes, pops, scans} (AC-KMD-55: no rescan of the frontier per point).
func allocate(c: Character, rng: RandomNumberGenerator, focus: Array, stats: Dictionary = {}) -> void:
	var cfg: Dictionary = _gd.world_gen().npc_builds
	var scores: Dictionary = cfg.tree_kind_scores
	var focus_w: float = float(cfg.tree_focus_weight)
	var rmin: int = int(_gd.tree_config().cap_realm_min)
	var st := {"gate": _tree.gate_open(c.linh_can, _gd)}   # a lambda captures locals by value: shared state
	var ranked: Array = []
	var parked: Array = []
	var seen: Dictionary = {}
	stats["pushes"] = 0
	stats["pops"] = 0
	stats["scans"] = 0
	for a in c.tree_nodes:
		seen[int(a)] = true
	var push := func(id: int, s: float) -> void:
		var at: int = ranked.bsearch_custom([s, id], func(x, y): return float(x[0]) < float(y[0]))
		ranked.insert(at, [s, id])
		stats.pushes = int(stats.pushes) + 1
	var see := func(id: int) -> void:
		for nb in _tree.neighbors(id):
			if seen.has(nb):
				continue
			seen[nb] = true
			var nd: Dictionary = _tree.node(nb)
			if c.realm_index < rmin and int(nd.get("cap", 0)) > 0:
				continue
			var s: float = float(scores.get(str(nd.kind), 1.0))
			var ids: Array = Array(nd.get("area_ids", [])) + Array(nd.get("grants", {}).keys())
			for f in focus:
				if ids.has(f):
					s *= focus_w
					break
			s += rng.randf() * 0.5
			if bool(nd.gated) and not bool(st.gate):
				parked.append([s, nb])
			else:
				push.call(nb, s)
	for a in c.tree_nodes.duplicate():
		see.call(int(a))
	while c.tree_points > 0 and not ranked.is_empty():
		var best: int = ranked.pop_back()[1]
		stats.pops = int(stats.pops) + 1
		_tree.open_node(c, best, _gd)
		if not bool(st.gate) and _tree.node(best).has("grants") and _tree.gate_open(c.linh_can, _gd):
			st.gate = true
			for p in parked:
				push.call(int(p[1]), float(p[0]))
			parked.clear()
		see.call(best)


func _train_skills(c: Character, rng: RandomNumberGenerator, arch_id: String) -> void:
	var cfg: Dictionary = _gd.world_gen().npc_builds
	var skill: String = str(cfg.archetype_skills.get(arch_id, ""))
	if skill == "":
		return
	var level: int = clampi(int(cfg.skill_level_base) + c.realm_index * int(cfg.skill_level_per_realm) + rng.randi_range(0, 1), 1, 9)
	c.skills[skill] = {"level": level, "xp": 0.0}
