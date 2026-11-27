class_name DaoDoTree
extends RefCounted
## Đạo Đồ: the passive tree, the hand-drawn v5 map with its content (ADR-0004), loaded from
## assets/data/dao_do_map.json (written by tools/design/dao_do_rework/content/export_game.py). Holds the graph and
## the access rules. Design: design/gdd/dao-do.md rules 1-5, 16-20.
##
## Nodes are Dao marks (đạo văn), roads and starts. A character holds a start (rule 3) and the Dao marks it opened;
## opening a road raises purity (rule 4), a capability notable grants its capability (rule 16), and the Chaos land
## opens only to a root that passes its gate (rule 3). Bonuses scale with the owner's purity by the node's area
## (rule 4): exact, an element land, a variant land, a border line (the average of two lands) or the Chaos land.
##
## Usage:
## [codeblock]
## var tree := DaoDoTree.load_map(gd)
## c.tree_nodes = [tree.npc_start(c.linh_can, gd)]
## var frontier: Array = tree.frontier(c, gd)
## var check: Dictionary = tree.can_allocate(c, frontier[0], gd)
## if check.ok: tree.open_node(c, frontier[0], gd)
## var mods: Array = tree.collect_mods(c, gd)   # {source, stat, value, scope}
## [/codeblock]

## The data file the map is read from.
const MAP_FILE := "dao_do_map"
## The id baseline a save's tree state belongs to (rule 19). Saves without it come from the generated map.
const BASELINE := "v5"
## Area kinds (rule 4).
const AREA_EXACT := 0
const AREA_ELEMENT := 1
const AREA_VARIANT := 2
const AREA_BORDER := 3
const AREA_CHAOS := 4
## The variant whose root opens the Chaos land at any purity (rule 3).
const CHAOS := "hon_don"

## Node id -> {id, x, y, kind, name, area, gate, cluster, grants, mods, pending, cap, effect, closes, links,
## area_kind, area_ids}. kind: start | road | small | notable | keystone.
var nodes: Dictionary = {}
## Element or variant id -> start node id.
var starts: Dictionary = {}
## Start node id -> element or variant id.
var start_of: Dictionary = {}
## The map's baseline ("v5").
var baseline: String = ""

static var _cache: Dictionary = {}
## Node id -> its modifier lines before the land scale (collect_mods); nodes never change after loading.
var _lines_cache: Dictionary = {}


## The map from game data. Built once per [GameData] and shared: the tree is read-only.
static func load_map(gd: GameData) -> DaoDoTree:
	var key: int = gd.get_instance_id()
	if _cache.has(key):
		return _cache[key]
	var t := DaoDoTree.new()
	t._read(gd.file(MAP_FILE))
	_cache[key] = t
	return t


func _read(d: Dictionary) -> void:
	baseline = str(d.get("baseline", ""))
	for n in d.get("nodes", []):
		var id: int = int(n.id)
		var rec: Dictionary = (n as Dictionary).duplicate(true)
		rec["id"] = id
		rec["links"] = []
		if not rec.has("name"):
			rec["name"] = "Đạo văn" if str(rec.kind) == "small" else "Road" if str(rec.kind) == "road" else str(rec.kind)
		if rec.has("cap"):
			rec["cap"] = int(rec.cap)
		var parts: PackedStringArray = str(rec.get("area", "exact")).split(":")
		match parts[0]:
			"el":
				rec["area_kind"] = AREA_ELEMENT
			"var":
				rec["area_kind"] = AREA_VARIANT
			"border":
				rec["area_kind"] = AREA_BORDER
			"chaos":
				rec["area_kind"] = AREA_CHAOS
			_:
				rec["area_kind"] = AREA_EXACT
		rec["area_ids"] = Array(parts.slice(1))
		rec["gated"] = str(rec.get("gate", "")) == "chaos"
		nodes[id] = rec
	for e in d.get("edges", []):
		var a: int = int(e[0])
		var b: int = int(e[1])
		nodes[a].links.append(b)
		nodes[b].links.append(a)
	for k in d.get("starts", {}):
		starts[str(k)] = int(d.starts[k])
		start_of[int(d.starts[k])] = str(k)


## The node record, or {}.
func node(node_id: int) -> Dictionary:
	return nodes.get(node_id, {})


## Ids of nodes adjacent to [param node_id].
func neighbors(node_id: int) -> Array:
	return node(node_id).get("links", [])


# --- Starts (rule 3) ------------------------------------------------------------------------------------------------

## The start ids a root may pick: an element start per owned base element, a variant start per owned variant that
## has one (the Chaos start for Primordial Chaos), in cycle then catalogue order.
func starts_for(lc: LinhCan, gd: GameData) -> Array:
	var out: Array = []
	for e in gd.element_cycle():
		if lc.elements.has(e) and starts.has(e):
			out.append(int(starts[e]))
	for def in gd.variant_defs():
		if lc.variants.has(def.id) and starts.has(str(def.id)):
			out.append(int(starts[str(def.id)]))
	return out


## An NPC's start (rule 3): the start of its highest-purity element or variant, ties in generating-cycle order, base
## elements before variants (Ice reads Water's purity, so a tie keeps the Water start). -1 for a root with none.
func npc_start(lc: LinhCan, gd: GameData) -> int:
	var best: int = -1
	var best_p: float = -1.0
	for sid in starts_for(lc, gd):
		var p: float = lc.purity(str(start_of[sid]))
		if p > best_p:
			best_p = p
			best = sid
	return best


## The character's start node: the first open node that is a start it may hold, or -1.
func start_of_character(c: Character) -> int:
	for a in c.tree_nodes:
		if start_of.has(int(a)):
			return int(a)
	return -1


# --- Access (rules 3, 16) -------------------------------------------------------------------------------------------

## Rule 3: true if the root may enter the Chaos land: it holds Primordial Chaos, or owns all five base elements each
## above `chaos_gate_purity`. Purity never falls, so once true it stays true.
func gate_open(lc: LinhCan, gd: GameData) -> bool:
	if lc.variants.has(CHAOS):
		return true
	var need: float = float(gd.tree_config().chaos_gate_purity)
	for e in gd.element_cycle():
		if not lc.elements.has(e) or lc.purity(e) <= need:
			return false
	return true


## True if the character may reach this node: it exists and is not behind a closed Chaos gate.
func accessible(c: Character, node_id: int, gd: GameData) -> bool:
	var nd: Dictionary = node(node_id)
	if nd.is_empty():
		return false
	return not bool(nd.gated) or gate_open(c.linh_can, gd)


## Unopened, reachable nodes adjacent to the character's open nodes, by id.
func frontier(c: Character, gd: GameData) -> Array:
	var open: Dictionary = {}
	for a in c.tree_nodes:
		open[int(a)] = true
	var seen: Dictionary = {}
	var gate: bool = gate_open(c.linh_can, gd)
	for a in c.tree_nodes:
		for nb in neighbors(int(a)):
			if not open.has(nb) and (gate or not bool(nodes[nb].gated)):
				seen[nb] = true
	var out: Array = seen.keys()
	out.sort()
	return out


## Rule 16: the realm a node needs, or -1: a capability notable needs `cap_realm_min` (Core Formation).
func realm_min(node_id: int, gd: GameData) -> int:
	return int(gd.tree_config().cap_realm_min) if int(node(node_id).get("cap", 0)) > 0 else -1


## Checks every allocation rule. Returns {ok, reason}.
func can_allocate(c: Character, node_id: int, gd: GameData) -> Dictionary:
	if not nodes.has(node_id):
		return {"ok": false, "reason": "no such đạo văn #%d" % node_id}
	if c.tree_nodes.has(node_id):
		return {"ok": false, "reason": "already open"}
	if c.tree_points <= 0:
		return {"ok": false, "reason": "no unspent points"}
	if not accessible(c, node_id, gd):
		return {"ok": false, "reason": "the Chaos land opens only to Primordial Chaos or five elements above %s" % LinhCan.fmt(float(gd.tree_config().chaos_gate_purity))}
	var rmin: int = realm_min(node_id, gd)
	if rmin >= 0 and c.realm_index < rmin:
		return {"ok": false, "reason": "a capability notable needs %s" % gd.realm(rmin).get("name", "?")}
	var adjacent: bool = false
	for nb in neighbors(node_id):
		if c.tree_nodes.has(nb):
			adjacent = true
			break
	if not adjacent:
		return {"ok": false, "reason": "not connected to an open đạo văn (use 'tree go %d')" % node_id}
	return {"ok": true, "reason": ""}


## Opens [param node_id] for [param c] after [method can_allocate]: spends 1 point, raises purity on a road (rule 4),
## grants a capability notable's capability (rule 16). Returns {road: {id: amount}, cap: id or 0}.
func open_node(c: Character, node_id: int, gd: GameData) -> Dictionary:
	var nd: Dictionary = node(node_id)
	c.tree_nodes.append(node_id)
	c.tree_points -= 1
	var gained: Dictionary = {}
	if nd.has("grants"):
		var rp: float = float(gd.tree_config().road_purity)
		for id in nd.grants:
			var amount: float = float(nd.grants[id]) * rp
			c.linh_can.add_road_purity(gd, str(id), amount)
			gained[str(id)] = amount
	var cap: int = int(nd.get("cap", 0))
	if cap > 0:
		c.grant_capability(cap)
	return {"road": gained, "cap": cap}


## Distance in unopened nodes from the open set to every reachable node.
func distances(c: Character, gd: GameData) -> Dictionary:
	var dist: Dictionary = {}
	var queue: Array = []
	var gate: bool = gate_open(c.linh_can, gd)
	var rmin: int = int(gd.tree_config().cap_realm_min)
	for a in c.tree_nodes:
		dist[int(a)] = 0
		queue.append(int(a))
	var head: int = 0
	while head < queue.size():
		var cur: int = queue[head]
		head += 1
		for nb in neighbors(cur):
			if dist.has(nb):
				continue
			var nd: Dictionary = nodes[nb]
			if bool(nd.gated) and not gate:
				continue
			if c.realm_index < rmin and int(nd.get("cap", 0)) > 0:
				continue
			dist[nb] = int(dist[cur]) + 1
			queue.append(nb)
	return dist


## Rule 3: the shortest route from the open set to [param target], inclusive. Among equally short routes it takes the
## highest total scaled value, then the lowest ids. [] if none (a gated node behind a closed gate and a capability
## notable below its realm are never on a route).
func path_to(c: Character, gd: GameData, target: int) -> Array:
	if c.tree_nodes.has(target):
		return []
	var tnd: Dictionary = nodes.get(target, {})
	if tnd.is_empty():
		return []
	var gate: bool = gate_open(c.linh_can, gd)
	if bool(tnd.gated) and not gate:
		return []
	var cfg: Dictionary = gd.tree_config()
	var rmin: int = int(cfg.cap_realm_min)
	var below_cap: bool = c.realm_index < rmin
	if below_cap and tnd.has("cap") and int(tnd["cap"]) > 0:
		return []

	# Bounded forward BFS: stops as soon as `target` is discovered at `target_dist`. Because BFS pops by distance,
	# every node at distance <= target_dist - 1 is already in `dist` with its exact shortest distance.
	var dist: Dictionary = {}
	var queue: Array[int] = []
	for a in c.tree_nodes:
		var ai: int = int(a)
		if not dist.has(ai):
			dist[ai] = 0
			queue.append(ai)
	var head: int = 0
	var target_dist: int = -1
	while head < queue.size():
		var cur: int = queue[head]
		head += 1
		var next_d: int = int(dist[cur]) + 1
		var cur_nd: Dictionary = nodes.get(cur, {})
		for nb in cur_nd.get("links", []):
			if dist.has(nb):
				continue
			var nd: Dictionary = nodes[nb]
			if bool(nd.gated) and not gate:
				continue
			if below_cap and nd.has("cap") and int(nd["cap"]) > 0:
				continue
			dist[nb] = next_d
			if nb == target:
				target_dist = next_d
				break
			queue.append(nb)
		if target_dist >= 0:
			break
	if target_dist < 0:
		return []
	if target_dist == 1:
		return [target]

	# Backward BFS from `target` down to distance 1: keeps only nodes on at least one shortest path to `target`.
	var layers: Array = []
	layers.resize(target_dist + 1)
	for i in range(target_dist + 1):
		layers[i] = []
	layers[target_dist] = [target]
	var in_dag: Dictionary = {target: true}
	for d in range(target_dist, 1, -1):
		var prev_layer: Array = layers[d - 1]
		var want: int = d - 1
		for cur in layers[d]:
			for nb in nodes[cur].links:
				if not in_dag.has(nb) and int(dist.get(nb, -9)) == want:
					in_dag[nb] = true
					prev_layer.append(nb)

	# Forward DP over the pruned shortest-path DAG only, with hoisted config and per-area scale cache.
	var fx: Dictionary = gd.element_effects()
	var parents: Dictionary = gd.attributes().linh_can.get("variant_parents", {})
	var road_purity: float = float(cfg.road_purity)
	var purity_price: float = float(cfg.purity_price)
	var scales: Dictionary = {}
	var best: Dictionary = {}
	for d in range(1, target_dist + 1):
		var prev_d: int = d - 1
		for id in layers[d]:
			var value: float = _node_value_cached(c.linh_can, gd, id, fx, parents, gate, road_purity, purity_price, scales)
			if d == 1:
				best[id] = {"value": 0.0 + value, "path": [id]}
				continue
			var chosen_val: float = 0.0
			var chosen_prior_path: Array = []
			var has_chosen: bool = false
			for nb in nodes[id].links:
				if int(dist.get(nb, -9)) != prev_d:
					continue
				var prior: Dictionary = best[nb]
				var cand_val: float = float(prior.value) + value
				var prior_path: Array = prior.path
				if not has_chosen:
					chosen_val = cand_val
					chosen_prior_path = prior_path
					has_chosen = true
				elif not is_equal_approx(cand_val, chosen_val):
					if cand_val > chosen_val:
						chosen_val = cand_val
						chosen_prior_path = prior_path
				elif prior_path < chosen_prior_path:
					chosen_val = cand_val
					chosen_prior_path = prior_path
			best[id] = {"value": chosen_val, "path": chosen_prior_path + [id]}
	return best[target].path


func _node_value_cached(lc: LinhCan, gd: GameData, node_id: int, fx: Dictionary, parents: Dictionary, gate: bool,
		road_purity: float, purity_price: float, scales: Dictionary) -> float:
	var nd: Dictionary = nodes[node_id]
	var total: float = 0.0
	if nd.has("mods"):
		for m in nd.mods:
			total += float(m.w)
		var ak: String = str(nd.get("area", "exact"))
		var sc: float
		if scales.has(ak):
			sc = float(scales[ak])
		else:
			sc = _node_scale_cached(nd, lc, gd, fx, parents, gate)
			scales[ak] = sc
		total *= sc
	if nd.has("grants"):
		for gid in nd.grants:
			total += float(nd.grants[gid]) * road_purity * purity_price
	return total


func _node_scale_cached(nd: Dictionary, lc: LinhCan, gd: GameData, fx: Dictionary, parents: Dictionary, gate: bool) -> float:
	match int(nd.get("area_kind", AREA_EXACT)):
		AREA_ELEMENT:
			return _element_scale_cached(str(nd.area_ids[0]), lc, fx, parents)
		AREA_VARIANT:
			return _rate(lc.variants.has(str(nd.area_ids[0])), lc.purity(str(nd.area_ids[0])), fx)
		AREA_BORDER:
			return (_element_scale_cached(str(nd.area_ids[0]), lc, fx, parents) + _element_scale_cached(str(nd.area_ids[1]), lc, fx, parents)) / 2.0
		AREA_CHAOS:
			if lc.variants.has(CHAOS):
				return _rate(true, lc.purity(CHAOS), fx)
			if gate:
				return _rate(true, lc.purity(lc.weakest_element(gd)), fx)
			return _rate(false, lc.purity(CHAOS), fx)
	return 1.0


static func _element_scale_cached(e: String, lc: LinhCan, fx: Dictionary, parents: Dictionary) -> float:
	var owned: bool = lc.elements.has(e)
	var best: float = lc.purity(e)
	for v in lc.variants.keys():
		if parents.get(v, []).has(e):
			owned = true
			best = maxf(best, lc.purity(str(v)))
	return _rate(owned, best, fx)


static func _better(a: Dictionary, b: Dictionary) -> bool:
	if not is_equal_approx(float(a.value), float(b.value)):
		return float(a.value) > float(b.value)
	return a.path < b.path


## A node's value for this character in W, used to break route ties: its lines' prices (the content's W) times the
## rule-4 multiplier; a road's purity grants at `purity_price` per purity point (Formulas A2).
func node_value(c: Character, gd: GameData, node_id: int) -> float:
	var nd: Dictionary = node(node_id)
	var total: float = 0.0
	for m in nd.get("mods", []):
		total += float(m.w)
	total *= node_scale(node_id, c.linh_can, gd)
	if nd.has("grants"):
		var cfg: Dictionary = gd.tree_config()
		for id in nd.grants:
			total += float(nd.grants[id]) * float(cfg.road_purity) * float(cfg.purity_price)
	return total


# --- Scaling (rule 4) -----------------------------------------------------------------------------------------------

## Rule 4: the multiplier on a node's bonuses. Starts, roads, keystones and the hub are exact; an element land's Dao
## marks read the element (or a held child variant, rule 12), a variant land's the variant, a border line's the
## average of both lands, the Chaos land's Chaos purity, or for a gate passer without Chaos its weakest element at the
## owned rate.
func node_scale(node_id: int, lc: LinhCan, gd: GameData) -> float:
	var nd: Dictionary = node(node_id)
	var fx: Dictionary = gd.element_effects()
	match int(nd.get("area_kind", AREA_EXACT)):
		AREA_ELEMENT:
			return element_scale(str(nd.area_ids[0]), lc, gd)
		AREA_VARIANT:
			return _rate(lc.variants.has(str(nd.area_ids[0])), lc.purity(str(nd.area_ids[0])), fx)
		AREA_BORDER:
			return (element_scale(str(nd.area_ids[0]), lc, gd) + element_scale(str(nd.area_ids[1]), lc, gd)) / 2.0
		AREA_CHAOS:
			return chaos_scale(lc, gd)
	return 1.0


## An element land's multiplier: the owned rate on the higher of the element's purity and a held child variant's
## (Thunder for Fire and Metal, Ice for Water, Wind for Water and Wood, Chaos for all five; linh-can.md rule 12),
## else the unowned rate on whatever purity roads gave it (rule 8).
func element_scale(e: String, lc: LinhCan, gd: GameData) -> float:
	var fx: Dictionary = gd.element_effects()
	var parents: Dictionary = gd.attributes().linh_can.get("variant_parents", {})
	var owned: bool = lc.elements.has(e)
	var best: float = lc.purity(e)
	for v in lc.variants.keys():
		if parents.get(v, []).has(e):
			owned = true
			best = maxf(best, lc.purity(str(v)))
	return _rate(owned, best, fx)


## The Chaos land's multiplier (rule 4): Chaos purity at the owned rate for a Chaos root; a root that passed the gate
## without Chaos reads its weakest base element at the owned rate; any other root the unowned rate on Chaos purity.
func chaos_scale(lc: LinhCan, gd: GameData) -> float:
	var fx: Dictionary = gd.element_effects()
	if lc.variants.has(CHAOS):
		return _rate(true, lc.purity(CHAOS), fx)
	if gate_open(lc, gd):
		return _rate(true, lc.purity(lc.weakest_element(gd)), fx)
	return _rate(false, lc.purity(CHAOS), fx)


static func _rate(owned: bool, p: float, fx: Dictionary) -> float:
	return (float(fx.tree_scale_base) if owned else float(fx.absent_element_tree_scale)) + p / 100.0


# --- Bonuses --------------------------------------------------------------------------------------------------------

## Every stat modifier from the character's open nodes, scaled: Array of {source, stat, value, scope}. scope is []
## for a plain line; a scoped line keeps its tags (the sheet holds it apart, ADR-0004 decision 4).
func collect_mods(c: Character, gd: GameData) -> Array:
	var out: Array = []
	var scales := {}   # one scale per land area in this call (an NPC's ~280 nodes sit in a handful of areas)
	for a in c.tree_nodes:
		var lines: Array = _node_lines(int(a))
		if lines.is_empty():
			continue
		var nd: Dictionary = node(int(a))
		var ak: String = "%d|%s" % [int(nd.get("area_kind", AREA_EXACT)), str(nd.get("area_ids", []))]
		if not scales.has(ak):
			scales[ak] = node_scale(int(a), c.linh_can, gd)
		var scale: float = float(scales[ak])
		for m in lines:
			out.append({"source": m.source, "stat": m.stat, "value": float(m.value) * scale, "scope": m.scope})
	return out


# A node's modifier lines before the land scale, built once: [{source, stat, value, scope}] (callers copy the scope).
func _node_lines(node_id: int) -> Array:
	if _lines_cache.has(node_id):
		return _lines_cache[node_id]
	var nd: Dictionary = node(node_id)
	var out: Array = []
	if not nd.is_empty() and nd.has("mods"):
		for m in nd.mods:
			out.append({"source": source_name(node_id), "stat": str(m.stat), "value": float(m.value), "scope": Array(m.get("scope", []))})
	_lines_cache[node_id] = out
	return out


## The modifier source of a node: "Đạo Đồ: <name> #<id>" (rule 4).
func source_name(node_id: int) -> String:
	return "Đạo Đồ: %s #%d" % [node(node_id).get("name", "?"), node_id]


## The held Effects of the character's open nodes (keystones and crown notables), by effects.md name, in id order.
func held_effects(c: Character) -> Array:
	var ids: Array = c.tree_nodes.duplicate()
	ids.sort()
	var out: Array = []
	for a in ids:
		var e: String = str(node(int(a)).get("effect", ""))
		if e != "" and not out.has(e):
			out.append(e)
	return out


## Human-readable bonus text for a node under a root.
func describe_mods(node_id: int, lc: LinhCan, gd: GameData) -> String:
	var nd: Dictionary = node(node_id)
	var scale: float = node_scale(node_id, lc, gd)
	var parts: PackedStringArray = []
	for m in nd.get("mods", []):
		var t: String = gd.format_mod(str(m.stat), float(m.value) * scale)
		if not Array(m.get("scope", [])).is_empty():
			t += " [%s]" % ",".join(PackedStringArray(Array(m.scope)))
		parts.append(t)
	if nd.has("grants"):
		var rp: float = float(gd.tree_config().road_purity)
		for id in nd.grants:
			parts.append("+%s %s purity" % [LinhCan.fmt(float(nd.grants[id]) * rp), gd.element_label(str(id))])
	for p in nd.get("pending", []):
		parts.append("(pending: %s)" % str(p.stat))
	var s: String = ", ".join(parts)
	if not is_equal_approx(scale, 1.0):
		s += "  (x%.2f from your root)" % scale
	if int(nd.get("cap", 0)) > 0:
		s += "  [capability: %s]" % gd.capability(int(nd.cap)).get("name", "?")
	if str(nd.get("effect", "")) != "":
		s += "  [Effect: %s]" % str(nd.effect)
	if str(nd.get("closes", "")) != "":
		s += "  [closes: %s]" % str(nd.closes)
	return s


## Visible Dao marks on the map (small, notable and keystone; starts and roads excluded; rule 1: 7,295).
func size() -> int:
	return nodes.values().filter(func(n): return str(n.kind) in ["small", "notable", "keystone"]).size()
