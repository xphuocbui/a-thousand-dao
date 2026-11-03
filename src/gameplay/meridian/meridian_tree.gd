class_name MeridianTree
extends RefCounted
## Kinh Mạch Đồ — the Path-of-Exile-style passive tree. Nodes are huyệt vị (acupoints):
## a center root (Đan Điền), five element sectors in tương sinh order with small nodes,
## named notables and a keystone each, and bridge nodes between neighbouring sectors.
##
## The tree is generated deterministically from meridian_tree.json (fixed seed), so it
## is the same in every life and can be learned and planned, like PoE's tree.
## A node's bonuses scale with the owner's purity in that sector's element, so the
## linh căn shapes which regions are worth walking (more elements = more good regions).
##
## Usage:
## [codeblock]
## var tree := MeridianTree.generate(gd)
## var frontier: Array = tree.frontier(character.tree_nodes)
## var check: Dictionary = tree.can_allocate(character, frontier[0], gd)
## if check.ok: character.tree_nodes.append(frontier[0])
## var mods: Array = tree.collect_mods(character.tree_nodes, character.linh_can, gd)
## [/codeblock]

const ROOT_ID := 0

## Node id -> {id, name, kind, sector, ring, x, y, links, mods, requires_elements, desc}.
## kind: root | gate | small | notable | keystone | bridge | bridge_notable
var nodes: Dictionary = {}


## Builds the tree from data. Same data + seed always yields the same tree.
static func generate(gd: GameData) -> MeridianTree:
	var cfg: Dictionary = gd.tree_config()
	var rng := RandomNumberGenerator.new()
	rng.seed = int(cfg.get("seed", 1))
	var tree := MeridianTree.new()
	var cycle: Array = gd.element_cycle()
	var rings: int = int(cfg.rings)
	var sector_span: float = TAU / float(cycle.size())
	var half_width: float = sector_span * 0.39
	var next_id: Array = [1]

	tree.nodes[ROOT_ID] = _make(ROOT_ID, cfg.root.name, "root", "center", 0, 0.0, cfg.root.mods)

	# ring -> sector index -> Array of node ids ordered by angle
	var ring_nodes: Dictionary = {}
	for s in cycle.size():
		var e: String = cycle[s]
		var theta: float = -PI / 2.0 + float(s) * sector_span
		var gate_id: int = _take(next_id)
		var gate := _make(gate_id, "%s Môn" % gd.element_name(e), "gate", e, 1, theta, cfg.gate_mods)
		tree.nodes[gate_id] = gate
		tree._link(ROOT_ID, gate_id)
		_ring_put(ring_nodes, 1, s, gate_id)

		var notable_queue: Array = cfg.notables.get(e, []).duplicate()
		for r in range(2, rings + 1):
			var n: int = int(cfg.nodes_base) + int(floor(float(r) * float(cfg.nodes_growth)))
			var ids: Array = []
			for k in n:
				var angle: float = theta - half_width + 2.0 * half_width * (float(k) + 0.5) / float(n)
				var pool: Array = cfg.small_pools.get(e, [])
				var mod: Dictionary = pool[rng.randi_range(0, pool.size() - 1)]
				var nid: int = _take(next_id)
				tree.nodes[nid] = _make(nid, "%s huyệt" % gd.element_name(e), "small", e, r, angle, [mod])
				ids.append(nid)
				_ring_put(ring_nodes, r, s, nid)
			# links: nearest node on the ring below, plus some same-ring neighbours
			for nid in ids:
				var below: Array = ring_nodes[r - 1][s]
				tree._link(nid, tree._nearest(nid, below))
			for k in ids.size() - 1:
				if rng.randf() < float(cfg.same_ring_link_chance):
					tree._link(ids[k], ids[k + 1])
			# notables and keystone
			# JSON numbers are floats; compare as ints (Array.has is type-strict).
			if Array(cfg.notable_rings).map(func(x): return int(x)).has(r) and not notable_queue.is_empty():
				var picks: Array = RngUtils.shuffled(rng, ids).slice(0, int(cfg.notables_per_ring))
				for pid in picks:
					if notable_queue.is_empty():
						break
					var nd: Dictionary = notable_queue.pop_front()
					tree._promote(pid, "notable", nd.name, nd.mods, "")
			if r == int(cfg.keystone_ring):
				var ks: Dictionary = cfg.keystones.get(e, {})
				if not ks.is_empty():
					tree._promote(ids[ids.size() / 2], "keystone", ks.name, ks.mods, str(ks.get("desc", "")))

	# bridges between neighbouring sectors
	var bridge_rings: Array = cfg.bridge_rings
	for s in cycle.size():
		var s2: int = (s + 1) % cycle.size()
		var pair: Array = [cycle[s], cycle[s2]]
		var mid_angle: float = -PI / 2.0 + (float(s) + 0.5) * sector_span
		for bi in bridge_rings.size():
			var r: int = int(bridge_rings[bi])
			var left: Array = ring_nodes[r][s]
			var right: Array = ring_nodes[r][s2]
			var bid: int = _take(next_id)
			var is_notable: bool = bi == bridge_rings.size() / 2
			var bridge_notable: Dictionary = _bridge_notable(cfg, pair)
			if is_notable and not bridge_notable.is_empty():
				tree.nodes[bid] = _make(bid, bridge_notable.name, "bridge_notable", "%s-%s" % pair, r, mid_angle, bridge_notable.mods)
			else:
				var bpool: Array = cfg.small_pools.get("bridge", [])
				var bmod: Dictionary = bpool[rng.randi_range(0, bpool.size() - 1)]
				tree.nodes[bid] = _make(bid, "Kỳ Kinh huyệt", "bridge", "%s-%s" % pair, r, mid_angle, [bmod])
			tree._link(bid, left[left.size() - 1])
			tree._link(bid, right[0])

	# center keystone (needs every base element)
	var cks: Dictionary = cfg.keystones.get("center", {})
	if not cks.is_empty():
		var cid: int = _take(next_id)
		var node := _make(cid, cks.name, "keystone", "center", 0, PI / 2.0, cks.mods)
		node["requires_elements"] = int(cks.get("requires_elements", 0))
		node["desc"] = str(cks.get("desc", ""))
		node["x"] = 0.0
		node["y"] = 0.6
		tree.nodes[cid] = node
		tree._link(ROOT_ID, cid)
	return tree


## Node record by id (empty if unknown).
func node(node_id: int) -> Dictionary:
	return nodes.get(node_id, {})


## Ids of nodes adjacent to [param node_id].
func neighbors(node_id: int) -> Array:
	return node(node_id).get("links", [])


## Unallocated nodes adjacent to the allocated set.
func frontier(allocated: Array) -> Array:
	var seen: Dictionary = {}
	for a in allocated:
		for nb in neighbors(int(a)):
			if not allocated.has(nb):
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
	var adjacent: bool = false
	for nb in neighbors(node_id):
		if c.tree_nodes.has(nb):
			adjacent = true
			break
	if not adjacent:
		return {"ok": false, "reason": "not connected to an open huyệt (use 'tree path %d')" % node_id}
	var req: int = int(node(node_id).get("requires_elements", 0))
	if req > 0 and c.linh_can.base_count() < req:
		return {"ok": false, "reason": "requires %d base elements in your linh căn" % req}
	return {"ok": true, "reason": ""}


## Shortest list of unallocated node ids from the allocated set to [param target]
## (inclusive), or [] if unreachable/already allocated.
func path_to(allocated: Array, target: int) -> Array:
	if allocated.has(target) or not nodes.has(target):
		return []
	var prev: Dictionary = {}
	var queue: Array = []
	for a in allocated:
		prev[int(a)] = -1
		queue.append(int(a))
	var head: int = 0
	while head < queue.size():
		var cur: int = queue[head]
		head += 1
		if cur == target:
			break
		for nb in neighbors(cur):
			if not prev.has(nb):
				prev[nb] = cur
				queue.append(nb)
	if not prev.has(target):
		return []
	var path: Array = []
	var walk: int = target
	while walk != -1 and not allocated.has(walk):
		path.push_front(walk)
		walk = prev[walk]
	return path


## Scale applied to a node's bonuses for this linh căn (keystones and root are exact).
func node_scale(node_id: int, lc: LinhCan, gd: GameData) -> float:
	var nd: Dictionary = node(node_id)
	if nd.kind in ["keystone", "root"]:
		return 1.0
	var fx: Dictionary = gd.element_effects()
	var sector: String = str(nd.sector)
	if sector.contains("-"):
		var parts: PackedStringArray = sector.split("-")
		return (_element_scale(parts[0], lc, fx) + _element_scale(parts[1], lc, fx)) / 2.0
	return _element_scale(sector, lc, fx)


## Every stat modifier from the allocated nodes, scaled:
## Array of {source, stat, value}.
func collect_mods(allocated: Array, lc: LinhCan, gd: GameData) -> Array:
	var out: Array = []
	for a in allocated:
		var nd: Dictionary = node(int(a))
		if nd.is_empty():
			continue
		var scale: float = node_scale(int(a), lc, gd)
		for m in nd.mods:
			out.append({"source": "Kinh Mạch: %s #%d" % [nd.name, int(a)], "stat": m.stat, "value": float(m.value) * scale})
	return out


## Human-readable bonus text for a node under a linh căn.
func describe_mods(node_id: int, lc: LinhCan, gd: GameData) -> String:
	var nd: Dictionary = node(node_id)
	var scale: float = node_scale(node_id, lc, gd)
	var parts: PackedStringArray = []
	for m in nd.mods:
		parts.append(gd.format_mod(str(m.stat), float(m.value) * scale))
	var s: String = ", ".join(parts)
	if not is_equal_approx(scale, 1.0):
		s += "  (x%.2f from linh căn)" % scale
	return s


## Number of nodes.
func size() -> int:
	return nodes.size()


static func _element_scale(e: String, lc: LinhCan, fx: Dictionary) -> float:
	if not lc.has(e):
		return float(fx.get("absent_element_tree_scale", 0.25))
	return float(fx.get("tree_scale_base", 0.5)) + lc.purity(e) / 100.0


static func _make(id: int, name: String, kind: String, sector: String, ring: int, angle: float, mods: Array) -> Dictionary:
	return {
		"id": id, "name": name, "kind": kind, "sector": sector, "ring": ring,
		"x": float(ring) * cos(angle), "y": float(ring) * sin(angle),
		"links": [], "mods": mods.duplicate(true), "requires_elements": 0, "desc": "",
	}


static func _take(counter: Array) -> int:
	var v: int = counter[0]
	counter[0] = v + 1
	return v


static func _ring_put(ring_nodes: Dictionary, ring: int, sector: int, node_id: int) -> void:
	if not ring_nodes.has(ring):
		ring_nodes[ring] = {}
	if not ring_nodes[ring].has(sector):
		ring_nodes[ring][sector] = []
	ring_nodes[ring][sector].append(node_id)


static func _bridge_notable(cfg: Dictionary, pair: Array) -> Dictionary:
	for b in cfg.notables.get("bridge", []):
		var p: Array = b.pair
		if (p[0] == pair[0] and p[1] == pair[1]) or (p[0] == pair[1] and p[1] == pair[0]):
			return b
	return {}


func _link(a: int, b: int) -> void:
	if a == b:
		return
	if not nodes[a].links.has(b):
		nodes[a].links.append(b)
	if not nodes[b].links.has(a):
		nodes[b].links.append(a)


func _nearest(from_id: int, candidates: Array) -> int:
	var best: int = candidates[0]
	var best_d: float = INF
	var fx: float = nodes[from_id].x
	var fy: float = nodes[from_id].y
	for c in candidates:
		var d: float = Vector2(fx, fy).distance_squared_to(Vector2(nodes[c].x, nodes[c].y))
		if d < best_d:
			best_d = d
			best = c
	return best


func _promote(node_id: int, kind: String, new_name: String, mods: Array, desc: String) -> void:
	nodes[node_id]["kind"] = kind
	nodes[node_id]["name"] = new_name
	nodes[node_id]["mods"] = mods.duplicate(true)
	nodes[node_id]["desc"] = desc
