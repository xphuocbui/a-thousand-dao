class_name MeridianGenerator
extends RefCounted
## Builds the Kinh Mạch Đồ from meridian_tree.json with a fixed seed, so the map is identical in
## every life. Design: design/gdd/kinh-mach-do.md rule 1 (topology), Formulas C, D, H, H2-H4.
##
## Build order: the road skeleton, base and bridge clusters, hidden clusters, variant sectors.
## Cluster content is drawn from theme pools, which stands in for the authored sealed clusters
## until that pass (Open Question 6).
##
## Usage:
## [codeblock]
## var tree: MeridianTree = MeridianGenerator.new(gd).build()
## [/codeblock]

var _gd: GameData
var _cfg: Dictionary
var _tree: MeridianTree
var _rng := RandomNumberGenerator.new()
var _next_id: int = 1
## sector element -> radial letter -> depth -> node id.
var _radial: Dictionary = {}
## Non-junction road node ids with a free link, grouped by sector: element -> Array of ids.
var _hosts: Dictionary = {}
## Hosts set aside for variant sectors, so clusters cannot take them.
var _reserved: Dictionary = {}
## Ring segments by "ring:element:gap", where gap is 0 L-C, 1 C-R, 2 the border: Array of ids.
var _segments: Dictionary = {}
## Per sector {x, y, x_ends, y_ends}: connectors and their radial ends (G2).
var _connectors: Dictionary = {}
## Per sector [braid L-C, braid C-R].
var _braids: Dictionary = {}
## Working regions: {id, sector, band, tag, boundary, faces, placed}. faces are the cyclic host
## lists still open; a cluster wired across a face splits it, so later links stay on one side.
var _regions: Array = []
## Road id -> the road it lies on, so a cluster's links can go on two different roads.
var _road_of: Dictionary = {}


func _init(gd: GameData) -> void:
	_gd = gd
	_cfg = gd.tree_config()


## Generates the tree. Tries seeds in order until the hidden cluster rolls pass (Formulas C).
func build() -> MeridianTree:
	var seed_v: int = int(_cfg.seed)
	for attempt in int(_cfg.seed_max_attempts):
		var rolls: Array = _roll_hidden(seed_v + attempt)
		if _rolls_accepted(rolls):
			return _assemble(seed_v, rolls)
	push_error("No tree seed passed the cluster checks.")
	return _assemble(seed_v, _roll_hidden(seed_v))


## Formulas C: size, location and kind of each hidden cluster.
func _roll_hidden(seed_v: int) -> Array:
	var r := RandomNumberGenerator.new()
	r.seed = seed_v
	var out: Array = []
	for i in int(_cfg.cluster_count):
		var n: int = clampi(int(roundf(r.randfn(float(_cfg.cluster_size_mean), float(_cfg.cluster_size_sd)))), int(_cfg.cluster_size_min), int(_cfg.cluster_size_max))
		var inner: bool = r.randf() < float(_cfg.inner_share)
		var sealed: bool = r.randf() < float(_cfg.sealed_share)
		# Big clusters belong near the rim, where the map has room.
		if inner:
			n = mini(n, int(_cfg.inner_cluster_size_max))
		out.append({"n": n, "inner": inner, "sealed": sealed})
	return out


func _rolls_accepted(rolls: Array) -> bool:
	var inner: int = rolls.filter(func(k): return k.inner).size()
	var carriers: int = rolls.filter(func(k): return not k.inner and k.sealed and int(k.n) >= int(_cfg.cap_min_n)).size()
	return inner >= int(_cfg.inner_count_window[0]) and inner <= int(_cfg.inner_count_window[1]) and carriers >= _gd.capabilities().size()


func _assemble(seed_v: int, rolls: Array) -> MeridianTree:
	_tree = MeridianTree.new()
	_rng.seed = seed_v
	_build_core()
	_build_roads()
	_set_depths()
	_collect_hosts()
	var variant_plan: Array = _plan_variants()
	_build_regions()
	_build_keystones()
	_build_bridges()
	_build_base_clusters()
	_build_hidden(rolls)
	_build_variants(variant_plan)
	_set_depths()
	return _tree


# --- Skeleton ---------------------------------------------------------------------

func _add(name: String, kind: String, sector: String, angle: float, mods: Array, id: int = -1) -> int:
	var nid: int = id
	if nid < 0:
		nid = _next_id
		_next_id += 1
	_tree.nodes[nid] = {"id": nid, "name": name, "kind": kind, "sector": sector, "depth": 0, "angle": angle, "links": [], "mods": mods}
	return nid


func _link(a: int, b: int) -> void:
	if not _tree.nodes[a].links.has(b):
		_tree.nodes[a].links.append(b)
		_tree.nodes[b].links.append(a)


func _degree(id: int) -> int:
	return _tree.nodes[id].links.size()


## Mods worth [param w] W on one stat, floored to its grid.
func _mod(stat: String, w: float) -> Dictionary:
	var unit: float = _gd.stat_precision(stat)
	var weights: Dictionary = _cfg.stat_weights
	var per: float = float(weights.get(stat, 1.0))
	if stat == "lifespan_years":
		per = 300.0 / 500.0
	return {"stat": stat, "value": floorf(w / per / unit + 1e-6) * unit}


func _build_core() -> void:
	_tree.nodes[0] = {"id": 0, "name": _cfg.root.name, "kind": "root", "sector": "", "depth": 0, "angle": 0.0, "links": [], "mods": []}
	var ck: Dictionary = _cfg.center_keystone
	var center: int = _add(str(ck.name), "keystone", "", 0.0, ck.mods.duplicate(true))
	_tree.nodes[center]["requires_elements"] = int(ck.requires_elements)
	_tree.nodes[center]["desc"] = str(ck.desc)
	_link(0, center)
	var cycle: Array = _gd.element_cycle()
	for s in cycle.size():
		var e: String = cycle[s]
		var gate: int = _add("Môn %s" % _gd.element_name(e), "gate", e, s * 72.0, [_gate_mod(e)])
		_link(0, gate)
		_radial[e] = {"L": {1: gate}, "C": {1: gate}, "R": {1: gate}}


## A gate's stat: its element's lead stat.
func _gate_mod(e: String) -> Dictionary:
	return _mod(str(_cfg.element_road_stats[e][0]), float(_cfg.huyet_value_highway))


## A road acupoint's stat: generic, the same in every sector, and mostly health.
func _road_mod(i: int) -> Dictionary:
	var stats: Array = _cfg.road_stats
	return _mod(str(stats[i % stats.size()]), float(_cfg.huyet_value_highway))


## Three radials per sector with their rings, connectors and braids (Formulas H table).
func _build_roads() -> void:
	var cycle: Array = _gd.element_cycle()
	var anchors: Array = _cfg.ring_anchor_depths
	var deepest: int = int(anchors[2])
	var junction_depths: Dictionary = {int(anchors[0]): true, int(anchors[1]): true, int(anchors[2]): true, 17: true}
	var letters: Array = ["L", "C", "R"]
	for s in cycle.size():
		var e: String = cycle[s]
		for li in letters.size():
			var letter: String = letters[li]
			var prev: int = _radial[e][letter][1]
			for d in range(2, deepest + 1):
				var kind: String = "junction" if junction_depths.has(d) else "road"
				var id: int = _add("Kinh Lộ %s %s%d" % [_gd.element_name(e), letter, d], kind, e, s * 72.0 + (li - 1) * 18.0, [_road_mod(d + li)])
				_radial[e][letter][d] = id
				_link(prev, id)
				prev = id
		# Connectors (G2): the seed's chirality picks C8 to L10 and R9 to C11, or the mirror.
		var mirror: bool = _rng.randf() < 0.5
		var a_letter: String = "R" if mirror else "L"
		var b_letter: String = "L" if mirror else "R"
		var x: int = _add("Kinh Lộ %s liên 1" % _gd.element_name(e), "road", e, s * 72.0 + (9.0 if mirror else -9.0), [_road_mod(1)])
		_link(_radial[e].C[8], x)
		_link(x, _radial[e][a_letter][10])
		var y: int = _add("Kinh Lộ %s liên 2" % _gd.element_name(e), "road", e, s * 72.0 + (-9.0 if mirror else 9.0), [_road_mod(2)])
		_link(_radial[e][b_letter][9], y)
		_link(y, _radial[e].C[11])
		for id in [_radial[e].C[8], _radial[e][a_letter][10], _radial[e][b_letter][9], _radial[e].C[11]]:
			_tree.nodes[id].kind = "junction"
		# Each gap's connector: its id and the depth of its end on each side.
		var lc: Dictionary = {"id": y, "x_end": 9, "y_end": 11} if mirror else {"id": x, "x_end": 10, "y_end": 8}
		var cr: Dictionary = {"id": x, "x_end": 8, "y_end": 10} if mirror else {"id": y, "x_end": 11, "y_end": 9}
		_connectors[e] = [lc, cr]
		var b1: int = _add("Kinh Lộ %s bện 1" % _gd.element_name(e), "road", e, s * 72.0 - 9.0, [_road_mod(0)])
		_link(_radial[e].L[17], b1)
		_link(b1, _radial[e].C[17])
		var b2: int = _add("Kinh Lộ %s bện 2" % _gd.element_name(e), "road", e, s * 72.0 + 9.0, [_road_mod(1)])
		_link(_radial[e].C[17], b2)
		_link(b2, _radial[e].R[17])
		_braids[e] = [b1, b2]
		for letter in letters:
			for d in _radial[e][letter].keys():
				_road_of[_radial[e][letter][d]] = "%s:%s" % [e, letter]
		_road_of[x] = "%s:x" % e
		_road_of[y] = "%s:y" % e
		_road_of[b1] = "%s:b1" % e
		_road_of[b2] = "%s:b2" % e
	var interiors: Array = _cfg.ring_interior
	for ring in 3:
		var depth: int = int(anchors[ring])
		var m: int = int(interiors[ring])
		for s in cycle.size():
			var e: String = cycle[s]
			var next: String = cycle[(s + 1) % cycle.size()]
			_segments["%d:%s:0" % [ring, e]] = _ring_segment(ring, m, _radial[e].L[depth], _radial[e].C[depth], e, e, s)
			_segments["%d:%s:1" % [ring, e]] = _ring_segment(ring, m, _radial[e].C[depth], _radial[e].R[depth], e, e, s)
			_segments["%d:%s:2" % [ring, e]] = _ring_segment(ring, m, _radial[e].R[depth], _radial[next].L[depth], e, next, s)


func _ring_segment(ring: int, m: int, from_id: int, to_id: int, a: String, b: String, s: int) -> Array:
	var prev: int = from_id
	var ids: Array = []
	var sector: String = a if a == b else "%s-%s" % [a, b]
	for i in m:
		var mods: Array = [_road_mod(i + ring)]
		var id: int = _add("Kinh Lộ K%d" % (ring + 1), "road", sector, s * 72.0 + 36.0, mods)
		_link(prev, id)
		prev = id
		ids.append(id)
		_road_of[id] = "K%d:%s:%s:%d" % [ring + 1, a, b, from_id]
	_link(prev, to_id)
	return ids


func _set_depths() -> void:
	var depth: Dictionary = {0: 0}
	var queue: Array = [0]
	var head: int = 0
	while head < queue.size():
		var cur: int = queue[head]
		head += 1
		for nb in _tree.nodes[cur].links:
			if not depth.has(nb):
				depth[nb] = int(depth[cur]) + 1
				queue.append(nb)
	for id in depth.keys():
		_tree.nodes[id].depth = int(depth[id])


func _collect_hosts() -> void:
	for e in _gd.element_cycle():
		_hosts[e] = []
	for id in _tree.nodes.keys():
		var nd: Dictionary = _tree.nodes[id]
		if nd.kind == "road" and _hosts.has(str(nd.sector).split("-")[0]):
			_hosts[str(nd.sector).split("-")[0]].append(id)
	for e in _hosts.keys():
		_hosts[e].sort()


## The radial ids from depth lo to hi, inclusive; hi below lo walks inward.
func _span(e: String, letter: String, lo: int, hi: int) -> Array:
	var out: Array = []
	var step: int = 1 if hi >= lo else -1
	var d: int = lo
	while true:
		out.append(_radial[e][letter][d])
		if d == hi:
			break
		d += step
	return out


func _add_region(sector: String, gap: int, band: String, boundary: Array) -> void:
	var r: Dictionary = {"id": _regions.size(), "sector": sector, "gap": gap, "band": band, "tag": sector, "boundary": boundary, "faces": [boundary.duplicate()], "placed": 0, "load": 0}
	_regions.append(r)
	_tree.regions.append({"id": r.id, "sector": sector, "gap": gap, "band": band, "boundary": boundary, "load": 0})


## Formulas H, G5: the regions of every gap and border. A boundary runs around the region.
func _build_regions() -> void:
	var cycle: Array = _gd.element_cycle()
	var a: Array = _cfg.ring_anchor_depths
	for s in cycle.size():
		var e: String = cycle[s]
		var next: String = cycle[(s + 1) % cycle.size()]
		for gap in 2:
			var x: String = "L" if gap == 0 else "C"
			var y: String = "C" if gap == 0 else "R"
			var conn: Dictionary = _connectors[e][gap]
			var k1: Array = _segments["0:%s:%d" % [e, gap]]
			var k2: Array = _segments["1:%s:%d" % [e, gap]]
			var k3: Array = _segments["2:%s:%d" % [e, gap]]
			var braid: int = _braids[e][gap]
			_add_region(e, gap, "inner", _span(e, x, 2, int(a[0])) + k1 + _span(e, y, int(a[0]), 2))
			_add_region(e, gap, "middle_low", _span(e, x, 6, int(conn.x_end)) + [conn.id] + _span(e, y, int(conn.y_end), 6) + _reversed(k1))
			_add_region(e, gap, "middle_high", _span(e, x, int(conn.x_end), int(a[1])) + k2 + _span(e, y, int(a[1]), int(conn.y_end)) + [conn.id])
			_add_region(e, gap, "outer_low", _span(e, x, 15, 17) + [braid] + _span(e, y, 17, 15) + _reversed(k2))
			_add_region(e, gap, "outer_high", _span(e, x, 17, int(a[2])) + k3 + _span(e, y, int(a[2]), 17) + [braid])
			_add_region(e, gap, "rim", [_radial[e][x][int(a[2])]] + k3 + [_radial[e][y][int(a[2])]])
		var b1: Array = _segments["0:%s:2" % e]
		var b2: Array = _segments["1:%s:2" % e]
		var b3: Array = _segments["2:%s:2" % e]
		_add_region(e, 2, "border_inner", _span(e, "R", 2, int(a[0])) + b1 + _span(next, "L", int(a[0]), 2))
		_add_region(e, 2, "border_middle", _span(e, "R", 6, int(a[1])) + b2 + _span(next, "L", int(a[1]), 6) + _reversed(b1))
		_add_region(e, 2, "border_outer", _span(e, "R", 15, int(a[2])) + b3 + _span(next, "L", int(a[2]), 15) + _reversed(b2))
		_add_region(e, 2, "border_rim", [_radial[e].R[int(a[2])]] + b3 + [_radial[next].L[int(a[2])]])


func _reversed(ids: Array) -> Array:
	var out: Array = ids.duplicate()
	out.reverse()
	return out


## True if a road node can take a cluster link: G6's host rules, plus G7's degree-3 junctions
## for hidden clusters.
func _usable(id: int, lo: int, hi: int, hidden: bool) -> bool:
	var nd: Dictionary = _tree.nodes[id]
	if _reserved.has(id) or int(nd.depth) < lo or int(nd.depth) > hi:
		return false
	if nd.kind == "road":
		return _degree(id) < 3 and (hidden or int(nd.depth) != 22)
	return hidden and nd.kind == "junction" and _degree(id) == 3


## Takes up to [param count] hosts from one open face of a region, on different roads where it
## can (G6). The face splits at the hosts, so a later cluster cannot wire across this one.
## Returns the hosts in boundary order.
func _take_hosts(region: Dictionary, lo: int, hi: int, count: int, hidden: bool) -> Array:
	var faces: Array = RngUtils.shuffled(_rng, region.faces)
	for face in faces:
		var cands: Array = face.filter(func(id): return _usable(id, lo, hi, hidden))
		if cands.is_empty():
			continue
		var first: int = cands[_rng.randi_range(0, cands.size() - 1)]
		var picked: Array = [first]
		var order: Array = RngUtils.shuffled(_rng, cands)
		order.sort_custom(func(p, q): return int(_road_of.get(p, "") != _road_of.get(first, "")) > int(_road_of.get(q, "") != _road_of.get(first, "")))
		for id in order:
			if picked.size() >= count:
				break
			if not picked.has(id) and absi(int(_tree.nodes[id].depth) - int(_tree.nodes[first].depth)) <= 2 and not picked.any(func(p): return _road_of.get(p, "") == _road_of.get(id, "") and picked.size() < 2 and order.any(func(o): return _road_of.get(o, "") != _road_of.get(p, ""))):
				picked.append(id)
		_split_face(region, face, picked)
		var ordered: Array = face.filter(func(id): return picked.has(id))
		region.placed = int(region.placed) + 1
		return ordered
	return []


## Replaces a face with the arcs between the hosts just taken.
func _split_face(region: Dictionary, face: Array, picked: Array) -> void:
	region.faces.erase(face)
	var at: Array = []
	for i in face.size():
		if picked.has(face[i]):
			at.append(i)
	for k in at.size():
		var from_i: int = at[k]
		var to_i: int = at[(k + 1) % at.size()]
		var arc: Array = []
		var i: int = (from_i + 1) % face.size()
		while i != to_i:
			arc.append(face[i])
			i = (i + 1) % face.size()
		if not arc.is_empty():
			region.faces.append(arc)


func _region(sector: String, gap: int, band: String) -> Dictionary:
	for r in _regions:
		if r.sector == sector and int(r.gap) == gap and r.band == band:
			return r
	return {}


func _build_keystones() -> void:
	var cycle: Array = _gd.element_cycle()
	for s in cycle.size():
		var e: String = cycle[s]
		for i in 2:
			var segment: Array = _segments["2:%s:%d" % [e, i]]
			var host: int = segment[0] if _rng.randf() < 0.5 else segment[segment.size() - 1]
			var ks: Dictionary = _cfg.keystones[e][i]
			var id: int = _add(str(ks.name), "keystone", e, s * 72.0 + (i * 2 - 1) * 18.0, ks.mods.duplicate(true))
			_tree.nodes[id]["desc"] = str(ks.desc)
			_link(host, id)
			# The keystone hangs outward: the rim face splits at its host.
			var rim: Dictionary = _region(e, i, "rim")
			_split_face(rim, rim.faces[0], [host])


# --- Clusters ---------------------------------------------------------------------

## Internal edges of a shape with n nodes. Every node keeps degree 3 or less.
func _shape_edges(shape: String, n: int) -> Array:
	var edges: Array = []
	match shape:
		"ring":
			for i in n:
				edges.append([i, (i + 1) % n])
		"star":
			var arms: int = mini(3, n - 1)
			var last: Array = []
			for a in arms:
				last.append(0)
			for i in range(1, n):
				var a: int = (i - 1) % arms
				edges.append([last[a], i])
				last[a] = i
		"fork":
			var mid: int = n / 2
			for i in range(0, mid):
				edges.append([i, i + 1])
			var prev: int = mid
			var other: int = mid
			for i in range(mid + 1, n):
				if i % 2 == 0:
					edges.append([prev, i])
					prev = i
				else:
					edges.append([other, i])
					other = i
		"loop_tail":
			var loop: int = maxi(n - 2, 3)
			for i in loop:
				edges.append([i, (i + 1) % loop])
			for i in range(loop, n):
				edges.append([i - 1 if i > loop else 0, i])
		"double_ring":
			var half: int = n / 2 + 1
			for i in half:
				edges.append([i, (i + 1) % half])
			var prev2: int = 0
			for i in range(half, n):
				edges.append([prev2, i])
				prev2 = i
			if n > half:
				edges.append([prev2, half / 2])
		"crescent":
			for i in n - 1:
				edges.append([i, i + 1])
			if n >= 5:
				edges.append([1, n - 2])
		"cross":
			return _shape_edges("star", n)
		_:
			for i in n - 1:
				edges.append([i, i + 1])
	return edges


func _shape_for(theme: Dictionary) -> String:
	if _rng.randf() < float(_cfg.shape_preferred_share):
		return str(theme.shape)
	return str(RngUtils.pick(_rng, _cfg.shapes))


## Builds one cluster on its hosts. Notables go on the nodes farthest from the entries.
## [param spec]: {theme, sector, angle, n, k, small_w, notable_w, stats, kind_small, kind_notable,
## cluster_id}. Returns {ids, notables, links}.
func _build_cluster(spec: Dictionary, hosts: Array) -> Dictionary:
	var n: int = int(spec.n)
	var theme: Dictionary = spec.theme
	var shape: String = _shape_for(theme) if n >= 4 else "chain"
	var edges: Array = _shape_edges(shape, n)
	# A double ring's inner path is not on the outside, so entries stay on the outer ring.
	var entry_nodes: int = n / 2 + 1 if shape == "double_ring" else n
	var degree: Array = []
	degree.resize(n)
	degree.fill(0)
	var adj: Array = []
	for i in n:
		adj.append([])
	for e in edges:
		degree[e[0]] += 1
		degree[e[1]] += 1
		adj[e[0]].append(e[1])
		adj[e[1]].append(e[0])
	var entries: Array = []
	for h in hosts.size():
		var want: int = (h * entry_nodes) / maxi(hosts.size(), 1)
		for off in entry_nodes:
			var cand: int = (want + off) % entry_nodes
			if degree[cand] <= 2 and not entries.has(cand):
				entries.append(cand)
				degree[cand] += 1
				break
	var dist: Array = _cluster_dist(adj, entries, n)
	var ranked: Array = range(n)
	ranked.sort_custom(func(a, b): return int(dist[a]) > int(dist[b]) if dist[a] != dist[b] else a < b)
	var notable_idx: Array = ranked.slice(0, int(spec.k))
	var ids: Array = []
	var stats: Array = spec.stats
	var caps: Dictionary = {}
	for i in n:
		var is_notable: bool = notable_idx.has(i)
		var name: String = str(theme.name) + " huyệt"
		var mods: Array
		if is_notable:
			name = str(RngUtils.pick(_rng, theme.notables))
			mods = _notable_mods(stats, float(spec.notable_w), n, caps)
		else:
			mods = _small_mods(stats, i, float(spec.small_w), n, caps)
		var kind: String = str(spec.kind_notable) if is_notable else str(spec.kind_small)
		var id: int = _add(name, kind, str(spec.sector), float(spec.angle), mods, int(spec.get("id_base", -1)) + i + 1 if spec.has("id_base") else -1)
		if spec.has("cluster_id"):
			_tree.nodes[id]["cluster"] = int(spec.cluster_id)
		if spec.has("variant"):
			_tree.nodes[id]["variant"] = str(spec.variant)
		ids.append(id)
	for e in edges:
		_link(ids[e[0]], ids[e[1]])
	for h in mini(hosts.size(), entries.size()):
		_link(hosts[h], ids[entries[h]])
	if spec.has("region"):
		_tree.groups.append({"nodes": ids, "links": hosts.slice(0, entries.size()), "region": int(spec.region)})
		_regions[int(spec.region)].load = int(_regions[int(spec.region)].load) + n
		_tree.regions[int(spec.region)].load = int(_regions[int(spec.region)].load)
	return {"ids": ids, "notables": notable_idx.map(func(i): return ids[i]), "links": hosts.slice(0, entries.size())}


func _cluster_dist(adj: Array, entries: Array, n: int) -> Array:
	var dist: Array = []
	dist.resize(n)
	dist.fill(-1)
	var queue: Array = entries.duplicate()
	for e in entries:
		dist[e] = 0
	var head: int = 0
	while head < queue.size():
		var cur: int = queue[head]
		head += 1
		for nb in adj[cur]:
			if int(dist[nb]) < 0:
				dist[nb] = int(dist[cur]) + 1
				queue.append(nb)
	return dist


func _cap_ok(stat: String, value: float, n: int, caps: Dictionary) -> bool:
	var limits: Dictionary = _cfg.cluster_stat_caps
	if not limits.has(stat):
		return true
	var cap: float = float(limits[stat]) * pow(float(n) / 9.0, float(_cfg.cap_gamma))
	if float(caps.get(stat, 0.0)) + value > cap + 1e-6:
		return false
	caps[stat] = float(caps.get(stat, 0.0)) + value
	return true


func _small_mods(stats: Array, i: int, w: float, n: int, caps: Dictionary) -> Array:
	for off in stats.size():
		var stat: String = str(stats[(i + off) % stats.size()])
		var m: Dictionary = _mod(stat, w)
		if float(m.value) > 0.0 and _cap_ok(stat, float(m.value), n, caps):
			return [m]
	return [_mod("linh_luc_pct", w)]


func _notable_mods(stats: Array, w: float, n: int, caps: Dictionary) -> Array:
	if w <= 0.0:
		return []
	var out: Array = []
	var share: float = w / minf(float(stats.size()), 2.0)
	for i in mini(stats.size(), 2):
		var stat: String = str(stats[i])
		var m: Dictionary = _mod(stat, share)
		if float(m.value) > 0.0 and _cap_ok(stat, float(m.value), n, caps):
			out.append(m)
	return out if not out.is_empty() else [_mod("linh_luc_pct", w)]


## G6: E for a cluster of [param n]; no shape at n 5 or below supports three entries.
func _entries_for(n: int) -> int:
	return mini(_entry_count(), 2) if n <= 5 else _entry_count()


func _entry_count() -> int:
	return RngUtils.weighted_index(_rng, _cfg.entry_count_weights) + 1


## G6: each gap gets one inner, one middle-low, one middle-high and one outer cluster.
func _build_base_clusters() -> void:
	var cycle: Array = _gd.element_cycle()
	var slots: Dictionary = _cfg.base_cluster_slots
	var small_w: float = float(_cfg.huyet_value_small)
	var notable_w: float = float(_cfg.huyet_value_notable)
	var per_notable: int = int(_cfg.huyet_per_notable_visible)
	for s in cycle.size():
		var e: String = cycle[s]
		var themes: Array = _cfg.element_themes[e]
		var t: int = 0
		for gap in 2:
			var outer_band: String = "outer_low" if _rng.randf() < 0.5 else "outer_high"
			var plan: Array = [["inner", int(slots.inner[gap]), 2, 5], ["middle_low", int(slots.middle[gap * 2]), 6, 13], ["middle_high", int(slots.middle[gap * 2 + 1]), 6, 13], [outer_band, int(slots.outer[gap]), 15, 18]]
			for p in plan:
				var theme: Dictionary = _cfg.themes[themes[t % themes.size()]]
				t += 1
				var region: Dictionary = _region(e, gap, p[0])
				var n: int = p[1]
				var hosts: Array = _take_hosts(region, p[2], p[3], _entries_for(n), false)
				_build_cluster({"theme": theme, "sector": e, "angle": s * 72.0 + float(t) * 4.0, "n": n, "k": clampi(n / per_notable, 1, 3), "region": region.id,
					"small_w": small_w, "notable_w": notable_w, "stats": theme.stats, "kind_small": "small", "kind_notable": "notable"}, hosts)
		# The gap between two elements holds clusters too, not just its bridges.
		for p in [["border_inner", int(slots.border_inner), 2, 5], ["border_middle", int(slots.border_middle), 6, 13], ["border_outer", int(slots.border_outer), 15, 19]]:
			var theme_b: Dictionary = _cfg.themes[themes[t % themes.size()]]
			t += 1
			var border: Dictionary = _region(e, 2, p[0])
			var n_b: int = p[1]
			var hosts_b: Array = _take_hosts(border, p[2], p[3], _entries_for(n_b), false)
			_build_cluster({"theme": theme_b, "sector": e, "angle": s * 72.0 + 36.0, "n": n_b, "k": clampi(n_b / per_notable, 1, 3), "region": border.id,
				"small_w": small_w, "notable_w": notable_w, "stats": theme_b.stats, "kind_small": "small", "kind_notable": "notable"}, hosts_b)


## G6: a bridge takes one link on each side's radial, never on a border ring.
func _build_bridges() -> void:
	var cycle: Array = _gd.element_cycle()
	var slots: Dictionary = _cfg.base_cluster_slots
	for s in cycle.size():
		var e: String = cycle[s]
		var next: String = cycle[(s + 1) % cycle.size()]
		for band in [["bridge_middle", "border_middle", 9, 12], ["bridge_outer", "border_outer", 15, 16]]:
			var region: Dictionary = _region(e, 2, band[1])
			var d: int = _rng.randi_range(int(band[2]), int(band[3]))
			var left: int = _radial[e].R[d] if _tree.nodes[_radial[e].R[d]].kind == "road" else _radial[e].R[d + 1]
			var right: int = _radial[next].L[d] if _tree.nodes[_radial[next].L[d]].kind == "road" else _radial[next].L[d + 1]
			var hosts: Array = [left, right]
			var face: Array = region.faces[0]
			_split_face(region, face, hosts)
			region.placed = int(region.placed) + 1
			var theme: Dictionary = _cfg.themes[_cfg.element_themes[e][0]]
			var stats: Array = [_cfg.element_road_stats[e][0], _cfg.element_road_stats[next][0]]
			_build_cluster({"theme": theme, "sector": "%s-%s" % [e, next], "angle": s * 72.0 + 36.0, "n": int(slots[band[0]]), "k": 1, "region": region.id,
				"small_w": float(_cfg.huyet_value_small), "notable_w": float(_cfg.huyet_value_notable), "stats": stats, "kind_small": "bridge", "kind_notable": "bridge_notable"}, hosts)


## Formulas D: the premium of a hidden cluster.
func _premium(entry_depth: int, n: int) -> float:
	var p: Dictionary = _cfg.premium
	var t_d: float = clampf((float(entry_depth) - float(p.d_lo)) / (float(p.d_hi) - float(p.d_lo)), 0.0, 1.0)
	var t_n: float = (float(n) - float(_cfg.cluster_size_min)) / (float(_cfg.cluster_size_max) - float(_cfg.cluster_size_min))
	return float(p.p_min) + (float(p.p_max) - float(p.p_min)) * (float(p.w_d) * t_d + float(p.w_n) * t_n)


func _gate_of(n: int, inner: bool) -> int:
	var g: Array = _cfg.size_realm_gates
	var realm: int = 1 if n <= int(g[0]) else (2 if n <= int(g[1]) else 3)
	return maxi(realm - (1 if inner else 0), 0)


func _build_hidden(rolls: Array) -> void:
	var cycle: Array = _gd.element_cycle()
	var caps: Array = _gd.capabilities().duplicate()
	var seal_cycle: Array = ["event", "item", "technique"]
	var sealed_seen: int = 0
	for i in rolls.size():
		var r: Dictionary = rolls[i]
		var n: int = int(r.n)
		var e: String = cycle[i % cycle.size()]
		var theme_id: String = _cfg.hidden_themes[i % _cfg.hidden_themes.size()]
		var theme: Dictionary = _cfg.themes[theme_id]
		var want: int = mini(_entry_count(), maxi(1, n - clampi(n / int(_cfg.huyet_per_notable), 1, 3) - 1))
		# G6: no shape at n 5 or below supports three entries.
		if n <= 5:
			want = mini(want, 2)
		var placed: Dictionary = _place_hidden(e, bool(r.inner), want, n)
		if placed.is_empty():
			for other in cycle:
				placed = _place_hidden(other, bool(r.inner), 1, n)
				if not placed.is_empty():
					e = other
					break
		if placed.is_empty():
			push_error("Hidden cluster %d found no link host." % i)
			continue
		var hosts: Array = placed.hosts
		# A cluster that had to shrink keeps its value in fewer, stronger acupoints.
		var strength: float = float(n) / float(placed.n)
		n = int(placed.n)
		var d_entry: int = 1 + hosts.map(func(h): return int(_tree.nodes[h].depth)).min()
		var premium: float = _premium(d_entry, n)
		var k: int = clampi(n / int(_cfg.huyet_per_notable), 1, 3)
		premium *= strength
		var capability: int = 0
		if bool(r.sealed) and not bool(r.inner) and n >= int(_cfg.cap_min_n) and not caps.is_empty():
			capability = int(caps.pop_front().id)
		var built: Dictionary = _build_cluster({"theme": theme, "sector": e, "angle": cycle.find(e) * 72.0, "n": n, "k": k,
			"small_w": float(_cfg.huyet_value_small) * premium, "notable_w": float(_cfg.huyet_value_notable) * premium,
			"stats": theme.stats, "kind_small": "small", "kind_notable": "notable", "cluster_id": i, "region": placed.region}, hosts)
		var seal: Dictionary = {"type": "story"}
		if bool(r.sealed):
			seal = {"type": seal_cycle[sealed_seen % seal_cycle.size()]}
			sealed_seen += 1
		if capability > 0:
			var nid: int = built.notables[0]
			var def: Dictionary = _gd.capability(capability)
			var share: float = float(_cfg.capability_stat_share[def.tier])
			_tree.nodes[nid]["capability"] = capability
			_tree.nodes[nid].name = str(def.name)
			_tree.nodes[nid].mods = _notable_mods(theme.stats, float(_cfg.huyet_value_notable) * premium * share, n, {})
		_tree.clusters[i] = {"id": i, "name": "%s %d" % [theme.name, i + 1], "theme": theme_id, "sector": e, "location": "inner" if r.inner else "outer",
			"kind": "sealed" if r.sealed else "open", "seal": seal, "gate": _gate_of(int(r.n), bool(r.inner)), "size": n, "nodes": built.ids,
			"notables": built.notables, "links": built.links, "capability": capability, "premium": premium}


## How many more acupoints a region can hold; the rim is open space.
func _room(r: Dictionary) -> int:
	if str(r.band).ends_with("rim"):
		return 1 << 20
	return int(_cfg.region_capacity.get(r.band, 0)) - int(r.load)


## G7: a hidden cluster's region, fewest-placed first. All its links lie on that region, so they
## share one tag. A region must have room: an outer cluster that fits nowhere goes to the rim,
## and an inner one shrinks to the room left, down to the smallest cluster. Returns {hosts,
## region, n}, or {} if no region has a host.
func _place_hidden(sector: String, inner: bool, want: int, size: int) -> Dictionary:
	var lo: int = 3 if inner else 15
	var hi: int = 7 if inner else 22
	var smallest: int = int(_cfg.cluster_size_min)
	var bands: Array = ["inner", "border_inner"] if inner else ["outer_low", "outer_high", "rim", "border_outer", "border_rim"]
	var cands: Array = _regions.filter(func(r): return r.sector == sector and bands.has(r.band) and _room(r) >= smallest)
	cands = RngUtils.shuffled(_rng, cands)
	cands.sort_custom(func(a, b): return int(a.placed) < int(b.placed))
	# Big clusters take the rim first, where nothing is around them.
	if size >= int(_cfg.rim_cluster_size_min):
		cands.sort_custom(func(a, b): return int(str(a.band).ends_with("rim")) > int(str(b.band).ends_with("rim")))
	# Regions that fit the whole cluster come first.
	cands.sort_custom(func(a, b): return int(_room(a) >= size) > int(_room(b) >= size))
	for r in cands:
		if not inner and _room(r) < size:
			continue
		var hosts: Array = _take_hosts(r, lo, hi, 1 if str(r.band).ends_with("rim") else want, true)
		if not hosts.is_empty():
			return {"hosts": hosts, "region": r.id, "n": mini(size, _room(r))}
	return {}


# --- Variant sectors --------------------------------------------------------------

## Chooses each sector's hosts before clusters can take them (Formulas H2).
func _plan_variants() -> Array:
	var plan: Array = []
	var depth_of: Dictionary = _cfg.variant_entry_depth
	var used: Dictionary = {}
	var cycle: Array = _gd.element_cycle()
	var defs: Array = _gd.variant_defs()
	for slot in defs.size():
		var id: String = str(defs[slot].id)
		var r := RandomNumberGenerator.new()
		r.seed = hash("variant:" + id) ^ int(_cfg.seed)
		var host_spec: Array = _cfg.variant_hosts[id]
		var entry: Variant = depth_of[id]
		var e: int = r.randi_range(int(entry[0]), int(entry[1])) if entry is Array else int(entry)
		var hosts: Array = []
		for h in host_spec:
			var sector: String = str(h)
			if sector == "inner" or sector == "k1":
				sector = str(cycle[r.randi_range(0, cycle.size() - 1)])
			var host: int = _variant_host(sector, e - 1, used, r)
			if host >= 0:
				hosts.append(host)
				used[host] = true
				_reserved[host] = true
		plan.append({"id": id, "slot": slot, "entry": e, "hosts": hosts})
	return plan


func _variant_host(sector: String, depth: int, used: Dictionary, r: RandomNumberGenerator) -> int:
	for d in [depth, depth + 1, depth - 1]:
		var pool: Array = _hosts[sector].filter(func(id): return int(_tree.nodes[id].depth) == d and _degree(id) < 3 and not used.has(id))
		if not pool.is_empty():
			return pool[r.randi_range(0, pool.size() - 1)]
	return -1


func _build_variants(plan: Array) -> void:
	var slots: Dictionary = _cfg.variant_cluster_slots
	var p_v: float = float(_cfg.variant_premium)
	var road_w: float = float(_cfg.huyet_value_highway) * p_v
	var small_w: float = float(_cfg.huyet_value_small) * p_v
	var notable_w: float = float(_cfg.huyet_value_notable) * p_v
	for v in plan:
		var id: String = str(v.id)
		var st: Dictionary = _cfg.variant_stats[id]
		var base: int = MeridianTree.VARIANT_ID_BASE + 100 * int(v.slot)
		_tree.sectors[id] = str(st.name)
		var s1: String = str(st.s[0])
		var roads: Array = []
		for i in int(_cfg.variant_road_count):
			var nid: int = _add("%s lộ %d" % [st.name, i + 1], "variant_road", id, 0.0, [_mod(s1, road_w)], base + i)
			_tree.nodes[nid]["variant"] = id
			roads.append(nid)
		for i in roads.size() - 1:
			_link(roads[i], roads[i + 1])
		var chord: bool = v.hosts.size() == 2
		_link(v.hosts[0], roads[0])
		if chord:
			_link(v.hosts[1], roads[roads.size() - 1])
		var theme := {"name": st.name, "shape": "ring", "notables": [st.name + " tinh hoa"]}
		var pieces: Array = [[int(slots.a), [roads[1]] if chord else [roads[2]], 10], [int(slots.b), [roads[6], roads[5]] if chord else [roads[4], roads[5]], 20], [int(slots.x), [roads[3], roads[4]] if chord else [roads[7]], 40]]
		for piece in pieces:
			var n: int = piece[0]
			var built: Dictionary = _build_cluster({"theme": theme, "sector": id, "angle": 0.0, "n": n, "k": clampi(n / int(_cfg.huyet_per_notable_visible), 1, 3), "small_w": small_w, "notable_w": notable_w,
				"stats": st.s, "kind_small": "small", "kind_notable": "notable", "variant": id, "id_base": base + int(piece[2]) - 1}, piece[1])
			if piece[2] == 40:
				var apex: int = built.notables[0]
				_tree.nodes[apex].kind = "apex"
				_tree.nodes[apex].name = str(st.apex)
				var mods: Array = []
				for m in st.apex_mods:
					mods.append(_mod(str(m[0]), float(m[1])))
				_tree.nodes[apex].mods = mods
