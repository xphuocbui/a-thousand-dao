class_name BuildGenerator
extends RefCounted
## Generates complete NPC builds with the same rules the player uses: linh căn and
## thiên phú, a công pháp, pháp bảo limited by thần thức, Kinh Mạch Đồ points spent
## greedily toward the archetype's focus sectors, and đạo nghệ skills. Every build is
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
var _tree: MeridianTree
var _db: WorldDB
var _items: ItemFactory


func _init(gd: GameData, tree: MeridianTree, db: WorldDB) -> void:
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

	var record: Dictionary = c.to_dict()
	record["created_by"] = str(opts.get("created_by", "worldgen"))
	var pid: String = _db.add("people", record)
	c.id = pid
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


## Chiến lực of a character under the shared rules.
func power_of(c: Character) -> float:
	var sheet := StatSheet.build(c, _gd, _db, _tree)
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


## Total Kinh Mạch Đồ points a cultivator at this realm/stage has earned (Realms rule 12: an
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
	# Pháp bảo, equipped while thần thức allows.
	var count: int = mini(int(cfg.artifacts_base) + c.realm_index * int(cfg.artifacts_per_realm), int(cfg.artifacts_max))
	var bases: Array = arch.get("artifact_bases", [])
	var capacity: float = CharacterRules.than_thuc(c, _gd, StatSheet.build(c, _gd, _db, _tree)).total
	var spent: float = 0.0
	for i in count:
		var base_id: String = str(RngUtils.pick(rng, bases)) if not bases.is_empty() else ""
		var grade: int = _items.roll_grade(rng, mini(1 + c.realm_index, 4))
		var elem: String = c.linh_can.strongest_element() if rng.randf() < float(cfg.artifact_root_element_chance) else "none"
		var art: Dictionary = _items.artifact(rng, c.realm_index, grade, elem, base_id)
		art["owner_id"] = c.id
		var aid: String = _db.add("items", art)
		if spent + float(art.than_thuc_cost) <= capacity:
			spent += float(art.than_thuc_cost)
			c.equipped.append(aid)


func _allocate_tree(c: Character, rng: RandomNumberGenerator, arch_id: String) -> void:
	var cfg: Dictionary = _gd.world_gen().npc_builds
	var focus: Array = _gd.archetype(arch_id).get("tree_focus", []).duplicate()
	if focus.is_empty():
		focus = [c.linh_can.strongest_element()]
	c.tree_nodes = [MeridianTree.ROOT_ID]
	c.tree_points = tree_points_for(c.realm_index, c.stage)
	_roll_unseals(c, rng)
	var scores: Dictionary = cfg.tree_kind_scores
	# Each reachable node is scored once, so spending stays cheap on the full map.
	var ranked: Array = []
	var seen: Dictionary = {MeridianTree.ROOT_ID: true}
	var add_frontier := func(id: int) -> void:
		for nb in _tree.neighbors(id):
			if seen.has(nb) or not _tree.accessible(c, nb):
				continue
			seen[nb] = true
			var nd: Dictionary = _tree.node(nb)
			if int(nd.get("requires_elements", 0)) > c.linh_can.base_count():
				continue
			var s: float = float(scores.get(nd.kind, 1.0))
			if str(nd.get("variant", "")) == "":
				for f in focus:
					if str(nd.sector).contains(f):
						s *= float(cfg.tree_focus_weight)
						break
			s += rng.randf() * 0.5
			var at: int = ranked.bsearch_custom([s, nb], func(a, b): return float(a[0]) < float(b[0]))
			ranked.insert(at, [s, nb])
	add_frontier.call(MeridianTree.ROOT_ID)
	while c.tree_points > 0 and not ranked.is_empty():
		var best: int = ranked.pop_back()[1]
		c.tree_nodes.append(best)
		c.tree_points -= 1
		var cap: int = int(_tree.node(best).get("capability", 0))
		if cap > 0:
			c.grant_capability(cap)
		add_frontier.call(best)


## Rule 14, Formulas G: a gifted NPC may hold sealed clusters. Open clusters never.
func _roll_unseals(c: Character, rng: RandomNumberGenerator) -> void:
	var cfg: Dictionary = ProgressionEdges.config(_gd).npc
	var share: float = float(_gd.tree_config().npc_unseal_share[c.realm_index])
	var edge: float = minf(ProgressionEdges.npc_edge_score(c.to_dict(), _gd).total, 1.0)
	var a: float = share * (float(cfg.base_step) + edge * (float(cfg.max_step) - float(cfg.base_step))) / float(cfg.max_step)
	var eligible: Array = _tree.clusters_of("sealed").filter(func(k): return int(k.gate) <= c.realm_index and c.linh_can.elements.has(k.sector))
	var m_r: int = _tree.clusters_of("sealed").filter(func(k): return int(k.gate) <= c.realm_index).size()
	if m_r == 0:
		return
	var p: float = 1.0 - pow(1.0 - a, 1.0 / float(m_r))
	var limit: int = 2 if c.realm_index >= _gd.realm_index("nguyen_anh") else 1
	for k in RngUtils.shuffled(rng, eligible):
		if c.unsealed.size() >= limit:
			break
		if rng.randf() < p:
			c.unsealed.append(int(k.id))


func _train_skills(c: Character, rng: RandomNumberGenerator, arch_id: String) -> void:
	var cfg: Dictionary = _gd.world_gen().npc_builds
	var skill: String = str(cfg.archetype_skills.get(arch_id, ""))
	if skill == "":
		return
	var level: int = clampi(int(cfg.skill_level_base) + c.realm_index * int(cfg.skill_level_per_realm) + rng.randi_range(0, 1), 1, 9)
	c.skills[skill] = {"level": level, "xp": 0.0}
