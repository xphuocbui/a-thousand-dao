class_name MeridianTree
extends RefCounted
## Kinh Mạch Đồ: the passive tree. Holds the generated graph and the access rules; building it
## is [MeridianGenerator]. Design: design/gdd/kinh-mach-do.md rules 1-5, 8, 20.
##
## Nodes are acupoints (huyệt). A node belongs to the base map, to a hidden cluster (reachable
## once the character has unsealed it) or to a variant sector (reachable while the root owns
## the variant). Bonuses scale with the owner's purity in the node's element.
##
## Usage:
## [codeblock]
## var tree := MeridianTree.generate(gd)
## var frontier: Array = tree.frontier(character)
## var check: Dictionary = tree.can_allocate(character, frontier[0], gd)
## if check.ok: character.tree_nodes.append(frontier[0])
## var mods: Array = tree.collect_mods(character, gd)
## [/codeblock]

const ROOT_ID := 0
## Variant sector ids live in their own block: VARIANT_ID_BASE + 100 x slot + n.
const VARIANT_ID_BASE := 100000

## Node id -> {id, name, kind, sector, depth, angle, links, mods, requires_elements, desc,
## cluster, variant, capability}. kind: root | gate | road | junction | small | notable |
## keystone | bridge | bridge_notable | variant_road | apex.
var nodes: Dictionary = {}
## Hidden cluster id -> {id, name, theme, sector, location, kind, seal, gate, size, nodes,
## notables, links, capability, premium}.
var clusters: Dictionary = {}
## Variant id -> sector name.
var sectors: Dictionary = {}
## Regions (Formulas H, G5): {id, sector, band, tag, boundary}. boundary is the road ids around
## the region, in order.
var regions: Array = []
## Every cluster's wiring: {nodes, links, region}. All of a cluster's links lie on one region's
## boundary, so the map stays drawable with no crossing edges.
var groups: Array = []


## Builds the tree from data. Same data and seed always yield the same tree.
static func generate(gd: GameData) -> MeridianTree:
	return MeridianGenerator.new(gd).build()


## The node record, or {}.
func node(node_id: int) -> Dictionary:
	return nodes.get(node_id, {})


## Ids of nodes adjacent to [param node_id].
func neighbors(node_id: int) -> Array:
	return node(node_id).get("links", [])


## True if the character may reach this node: a hidden cluster must be unsealed, a variant
## sector needs the variant. Everything else is open.
func accessible(c: Character, node_id: int) -> bool:
	var nd: Dictionary = node(node_id)
	if nd.is_empty():
		return false
	var cluster: int = int(nd.get("cluster", -1))
	if cluster >= 0 and not c.unsealed.has(cluster):
		return false
	var variant: String = str(nd.get("variant", ""))
	return variant == "" or c.linh_can.variants.has(variant)


## Unopened, reachable nodes adjacent to the character's open nodes.
func frontier(c: Character) -> Array:
	var open: Dictionary = {}
	for a in c.tree_nodes:
		open[int(a)] = true
	var seen: Dictionary = {}
	for a in c.tree_nodes:
		for nb in neighbors(int(a)):
			if not open.has(nb) and accessible(c, nb):
				seen[nb] = true
	var out: Array = seen.keys()
	out.sort()
	return out


## Checks every allocation rule. Returns {ok, reason}.
func can_allocate(c: Character, node_id: int, gd: GameData) -> Dictionary:
	if not nodes.has(node_id):
		return {"ok": false, "reason": "no such huyệt #%d" % node_id}
	if c.tree_nodes.has(node_id):
		return {"ok": false, "reason": "already open"}
	if c.tree_points <= 0:
		return {"ok": false, "reason": "no unspent points"}
	if not accessible(c, node_id):
		return {"ok": false, "reason": "hidden"}
	var adjacent: bool = false
	for nb in neighbors(node_id):
		if c.tree_nodes.has(nb):
			adjacent = true
			break
	if not adjacent:
		return {"ok": false, "reason": "not connected to an open huyệt (use 'tree go %d')" % node_id}
	var req: int = int(node(node_id).get("requires_elements", 0))
	if req > 0 and c.linh_can.base_count() < req:
		return {"ok": false, "reason": "requires %d base elements in your root" % req}
	return {"ok": true, "reason": ""}


## Distance in unopened nodes from the open set to every reachable node.
func distances(c: Character) -> Dictionary:
	var dist: Dictionary = {}
	var queue: Array = []
	for a in c.tree_nodes:
		dist[int(a)] = 0
		queue.append(int(a))
	var head: int = 0
	while head < queue.size():
		var cur: int = queue[head]
		head += 1
		for nb in neighbors(cur):
			if not dist.has(nb) and accessible(c, nb):
				dist[nb] = int(dist[cur]) + 1
				queue.append(nb)
	return dist


## Rule 3: the shortest route from the open set to [param target], inclusive. Among equally
## short routes it takes the highest total scaled value, then the lowest ids. [] if none.
func path_to(c: Character, gd: GameData, target: int) -> Array:
	if c.tree_nodes.has(target) or not accessible(c, target):
		return []
	var dist: Dictionary = distances(c)
	if not dist.has(target):
		return []
	var order: Array = dist.keys().filter(func(k): return int(dist[k]) > 0 and int(dist[k]) <= int(dist[target]))
	order.sort_custom(func(a, b): return int(dist[a]) < int(dist[b]) if dist[a] != dist[b] else a < b)
	var best: Dictionary = {}
	for id in order:
		var value: float = node_value(c, gd, id)
		var chosen: Dictionary = {}
		for nb in neighbors(id):
			if int(dist.get(nb, -9)) != int(dist[id]) - 1:
				continue
			var prior: Dictionary = best.get(nb, {"value": 0.0, "path": []})
			var cand: Dictionary = {"value": float(prior.value) + value, "path": prior.path + [id]}
			if chosen.is_empty() or _better(cand, chosen):
				chosen = cand
		best[id] = chosen
	return best[target].path


static func _better(a: Dictionary, b: Dictionary) -> bool:
	if not is_equal_approx(float(a.value), float(b.value)):
		return float(a.value) > float(b.value)
	return a.path < b.path


## Total weighted value of a node for this character, used to break route ties.
func node_value(c: Character, gd: GameData, node_id: int) -> float:
	var w: Dictionary = gd.tree_config().stat_weights
	var scale: float = node_scale(node_id, c.linh_can, gd)
	var total: float = 0.0
	for m in node(node_id).get("mods", []):
		total += float(w.get(m.stat, 1.0)) * absf(float(m.value)) * scale
	return total


## Rule 4: scale applied to a node's bonuses (keystones and the root are exact).
func node_scale(node_id: int, lc: LinhCan, gd: GameData) -> float:
	var nd: Dictionary = node(node_id)
	# Keystones, the root and the generic roads pay the same on every root.
	if nd.kind in ["keystone", "root", "road", "junction"]:
		return 1.0
	var variant: String = str(nd.get("variant", ""))
	if variant != "":
		return 0.5 + lc.purity(variant) / 100.0
	var fx: Dictionary = gd.element_effects()
	var sector: String = str(nd.sector)
	if sector.contains("-"):
		var parts: PackedStringArray = sector.split("-")
		return (_element_scale(parts[0], lc, fx) + _element_scale(parts[1], lc, fx)) / 2.0
	return _element_scale(sector, lc, fx)


## Every stat modifier from the character's open nodes, scaled: Array of {source, stat, value}.
func collect_mods(c: Character, gd: GameData) -> Array:
	var out: Array = []
	for a in c.tree_nodes:
		var nd: Dictionary = node(int(a))
		if nd.is_empty():
			continue
		var scale: float = node_scale(int(a), c.linh_can, gd)
		for m in nd.mods:
			out.append({"source": "Kinh Mạch: %s #%d" % [nd.name, int(a)], "stat": m.stat, "value": float(m.value) * scale})
	return out


## Human-readable bonus text for a node under a root.
func describe_mods(node_id: int, lc: LinhCan, gd: GameData) -> String:
	var nd: Dictionary = node(node_id)
	var scale: float = node_scale(node_id, lc, gd)
	var parts: PackedStringArray = []
	for m in nd.mods:
		parts.append(gd.format_mod(str(m.stat), float(m.value) * scale))
	var s: String = ", ".join(parts)
	if not is_equal_approx(scale, 1.0):
		s += "  (x%.2f from your root)" % scale
	if int(nd.get("capability", 0)) > 0:
		s += "  [capability: %s]" % gd.capability(int(nd.capability)).get("name", "?")
	return s


## Acupoints in the launch map, hidden clusters included, variant sectors excluded.
func size() -> int:
	return nodes.size() - visible_variant_count()


## Acupoints in variant sectors.
func visible_variant_count() -> int:
	return nodes.values().filter(func(n): return str(n.get("variant", "")) != "").size()


## The size the character is told: the base map plus sectors it owns (rule 20).
func reported_size(c: Character) -> int:
	return nodes.values().filter(func(n): return str(n.get("variant", "")) == "" or c.linh_can.variants.has(str(n.variant))).size()


## Hidden clusters of [param kind] ("sealed", "open"), ordered by id.
func clusters_of(kind: String) -> Array:
	var out: Array = clusters.values().filter(func(k): return k.kind == kind)
	out.sort_custom(func(a, b): return int(a.id) < int(b.id))
	return out


static func _element_scale(e: String, lc: LinhCan, fx: Dictionary) -> float:
	if not lc.elements.has(e):
		return float(fx.absent_element_tree_scale)
	return float(fx.tree_scale_base) + lc.purity(e) / 100.0
