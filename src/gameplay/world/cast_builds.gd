class_name CastBuilds
extends RefCounted

## The fixed cast's hand-authored builds (design/gdd/world-generation.md Core Rule 6; user decision 2026-11-20: all
## 54 living builds hand-authored). Authored in design/world/cast_builds.json, exported into world_history.json
## "cast_builds" and checked there by tools/design/world/export_world.py (every id must exist). A build fixes every
## choice NPC Build Generation would roll:
##   root {elements: {id: purity}, variants: {id: purity}}, thien_phu {id: 1-100}, archetype, stage,
##   main {tech: catalogue id, layer}, aux [{tech, layer}], gear [{named: id} | {base, grade, element}],
##   tree {start: element or variant id, targets: [node ids, in order]}, skills {skill id: level}.
## The items' own rolls (affixes) come from a stream keyed on the person alone, so the build is the same in every
## game. The tree's points open the shortest route to each target in order (Đạo Đồ rule 3), and any points left are
## spent by the allocator toward the start's land.
##
## Usage:
## [codeblock]
## var c: Character = CastBuilds.make(gd, tree, db, items, builds, authored, opts)
## [/codeblock]


## Builds the person [param p] (a world_history people row) with build [param b] into [param db] under id
## [param pid], at [param location] in sect [param sect_id] with [param rank]. Returns the Character.
static func make(gd: GameData, tree: DaoDoTree, db: WorldDB, items: ItemFactory, builds: BuildGenerator, p: Dictionary,
		b: Dictionary, pid: String, sect_id: String, rank: String, location: String, year: int) -> Character:
	var rng := RandomNumberGenerator.new()
	rng.seed = RngUtils.stable_hash("cast_build:" + str(p.key))
	var c := Character.new()
	c.id = pid
	c.name = str(p.name)
	c.gender = "female" if str(p.sex) == "F" else "male"
	c.realm_index = maxi(gd.realm_index(str(p.realm)), 0)
	c.stage = clampi(int(b.get("stage", 0)), 0, gd.stage_count(c.realm_index) - 1)
	c.level = Ladder.stage_first_level(gd, c.realm_index, c.stage)
	c.level_peak = c.level
	c.age = float(year - int(p.born))
	c.archetype = str(b.get("archetype", "tan_tu"))
	c.sect_id = sect_id
	c.sect_rank = rank
	c.location_id = location
	for k in b.get("thien_phu", {}):
		c.thien_phu[str(k)] = int(b.thien_phu[k])
	var root: Dictionary = b.get("root", {})
	c.linh_can.elements = {}
	for e in root.get("elements", {}):
		c.linh_can.elements[str(e)] = float(root.elements[e])
	c.linh_can.variants = {}
	for v in root.get("variants", {}):
		c.linh_can.variants[str(v)] = float(root.variants[v])
	c.linh_can.recompute_derived(gd)
	var rec: Dictionary = c.to_dict()
	rec["created_by"] = "cast"
	db.put("people", rec)
	# techniques
	var main: Dictionary = b.get("main", {})
	_learn(gd, db, items, c, str(main.get("tech", "")), int(main.get("layer", 1)), true)
	var aux: Array = b.get("aux", [])
	for i in mini(aux.size(), c.aux_tech.size()):
		var id: String = _learn(gd, db, items, c, str(aux[i].get("tech", "")), int(aux[i].get("layer", 1)), false)
		if id != "":
			c.aux_tech[i] = id
	# gear
	var sheet := StatSheet.build(c, gd, db, tree)
	for g in b.get("gear", []):
		var art: Dictionary
		if g.has("named"):
			art = items.named_artifact(str(g.named), c.realm_index, db, year)
		else:
			art = items.artifact(rng, c.realm_index, int(g.get("grade", 1)), str(g.get("element", "none")), str(g.get("base", "")))
		if art.is_empty():
			continue
		art["owner_id"] = c.id
		var aid: String = db.add("items", art)
		var slot: String = EquipSlots.slot_for(c, gd, db, sheet, art)
		if slot != "":
			c.equipped.append(aid)
			c.equip_slots[aid] = slot
	# the tree: start, then the route to each target in order, then the rest toward the start's land
	var tb: Dictionary = b.get("tree", {})
	var start_id: String = str(tb.get("start", ""))
	var start: int = int(tree.starts.get(start_id, -1)) if start_id != "" else tree.npc_start(c.linh_can, gd)
	if start < 0:
		start = tree.npc_start(c.linh_can, gd)
	c.tree_nodes = [start] if start >= 0 else []
	c.tree_points = builds.tree_points_for(c.realm_index, c.stage)
	for target in tb.get("targets", []):
		if c.tree_points <= 0:
			break
		for nid in tree.path_to(c, gd, int(target)):
			if c.tree_points <= 0:
				break
			tree.open_node(c, int(nid), gd)
	if c.tree_points > 0:
		builds.allocate(c, rng, [start_id if start_id != "" else c.linh_can.strongest_element()])
	for sk in b.get("skills", {}):
		c.skills[str(sk)] = {"level": int(b.skills[sk]), "xp": 0.0}
	var fresh: Dictionary = c.to_dict()
	fresh["created_by"] = "cast"
	fresh["power"] = builds.power_of(c)
	db.put("people", fresh)
	return c


## Technique ids a build named that the catalogue lacks, in order (ADR-0009 decision 8; tests read it).
static var unknown_ids: Array = []


static func _learn(gd: GameData, db: WorldDB, items: ItemFactory, c: Character, tech_id: String, layer: int, is_main: bool) -> String:
	if tech_id == "":
		return ""
	for t in gd.cong_phap_file().get("templates", []):
		if str(t.id) == tech_id:
			var cp: Dictionary = items.manual_from_template(t)
			cp["owner_id"] = c.id
			db.add("items", cp)
			CongPhap.learn(c, cp)
			var id: String = str(cp.tech_id)
			c.techniques[id]["layer"] = clampi(layer, 1, int(cp.layers))
			if is_main:
				c.main_tech = id
			return id
	# ADR-0009 decision 8: an unknown id is reported, never dropped silently
	unknown_ids.append(tech_id)
	push_warning("CastBuilds: technique %s is not in the catalogue; %s learns nothing in its place" % [tech_id, c.name])
	return ""
