extends DaoTestSuite
## Kinh Mạch Đồ (design/gdd/kinh-mach-do.md): map size, topology, access, value scale, sectors.


func _tree() -> MeridianTree:
	return TestFixtures.tree()


func _c(purities: Dictionary = {"hoa": 50}) -> Character:
	var c := TestFixtures.character(purities)
	c.tree_points = 1000
	return c


func _kinds(tree: MeridianTree, keep: Callable) -> int:
	return tree.nodes.values().filter(keep).size()


func test_the_map_is_identical_in_every_build() -> void:
	var a := MeridianTree.generate(game_data())
	var b := MeridianTree.generate(game_data())
	assert_eq(a.nodes.size(), b.nodes.size(), "same size")
	for id in a.nodes.keys():
		assert_eq(a.nodes[id].links, b.nodes[id].links, "node %d" % id)


func test_visible_map_counts_match_formulas_h() -> void:
	var t := _tree()
	var visible := func(n): return int(n.get("cluster", -1)) < 0 and str(n.get("variant", "")) == ""
	assert_eq(_kinds(t, visible), 7 + 5 * 77 + 5 * 8 + 10 + 5 * (6 + 20 + 16 + 3 + 5 + 6 + 10), "visible acupoints")
	assert_eq(_kinds(t, func(n): return n.kind == "keystone"), 11, "keystones")
	assert_eq(_kinds(t, func(n): return n.kind in ["road", "junction", "gate"]), 430, "meridian roads")
	assert_true(_kinds(t, func(n): return visible.call(n) and n.kind in ["notable", "bridge_notable"]) >= 60, "visible notables")


func test_hidden_clusters_match_formulas_c() -> void:
	var t := _tree()
	assert_eq(t.clusters.size(), 75, "cluster count")
	var inner: int = t.clusters.values().filter(func(k): return k.location == "inner").size()
	assert_true(inner >= 9 and inner <= 14, "inner %d" % inner)
	var hidden: int = t.nodes.values().filter(func(n): return int(n.get("cluster", -1)) >= 0).size()
	assert_true(hidden >= 480 and hidden <= 640, "hidden %d" % hidden)
	for k in t.clusters.values():
		if k.location == "inner":
			assert_true(int(k.size) <= 5, "big clusters stay out of the inner band")
	var capable: Array = t.clusters.values().filter(func(k): return int(k.capability) > 0)
	assert_eq(capable.size(), 25, "every capability placed")
	for k in capable:
		assert_eq(k.kind, "sealed", "on a sealed cluster")
		assert_eq(k.location, "outer", "outer")
		assert_true(int(k.size) >= 7, "size floor")
		assert_true(int(k.gate) >= 2, "behind the Core Formation gate")


func test_degree_limits_hold() -> void:
	var t := _tree()
	var sum: int = 0
	for id in t.nodes.keys():
		var nd: Dictionary = t.nodes[id]
		var deg: int = nd.links.size()
		sum += deg
		if id == MeridianTree.ROOT_ID:
			continue
		assert_true(deg <= 4, "#%d %s degree %d" % [id, nd.kind, deg])
		if deg == 4:
			assert_true(nd.kind in ["junction", "gate"], "#%d only junctions have 4" % id)
	var mean: float = float(sum) / float(t.nodes.size())
	assert_true(mean >= 2.2 and mean <= 2.6, "mean degree %.2f" % mean)


func test_every_node_is_reachable_with_everything_open() -> void:
	var t := _tree()
	var seen := {0: true}
	var queue: Array = [0]
	var head: int = 0
	while head < queue.size():
		for nb in t.neighbors(queue[head]):
			if not seen.has(nb):
				seen[nb] = true
				queue.append(nb)
		head += 1
	assert_eq(seen.size(), t.nodes.size(), "connected")


func test_a_road_keeps_its_band_depth_with_everything_open() -> void:
	var t := _tree()
	var gate: Array = t.nodes.values().filter(func(n): return n.kind == "gate")
	assert_eq(gate.size(), 5, "five gates")
	for n in gate:
		assert_eq(int(n.depth), 1, "gate at d 1")
	var deepest_keystone: int = t.nodes.values().filter(func(n): return n.kind == "keystone" and n.sector != "").map(func(n): return int(n.depth)).min()
	assert_eq(deepest_keystone, 22, "no shortcut reaches a sector keystone early")


func test_every_cluster_wires_inside_one_region_g5() -> void:
	var t := _tree()
	assert_eq(t.groups.size(), 55 + 10 + 75, "base, bridge and hidden clusters")
	for g in t.groups:
		var boundary: Array = t.regions[int(g.region)].boundary
		for l in g.links:
			assert_true(boundary.has(l), "link #%d on region %d" % [l, int(g.region)])


func test_cluster_links_never_interleave_in_a_region() -> void:
	# Two clusters whose links alternate around a region's boundary could not be drawn without
	# crossing, so a later cluster must stay on one side of an earlier one.
	var t := _tree()
	var by_region: Dictionary = {}
	for g in t.groups:
		if not by_region.has(int(g.region)):
			by_region[int(g.region)] = []
		by_region[int(g.region)].append(g)
	for rid in by_region.keys():
		var boundary: Array = t.regions[rid].boundary
		var gs: Array = by_region[rid]
		for i in gs.size():
			for j in range(i + 1, gs.size()):
				var a: Array = gs[i].links.map(func(l): return boundary.find(l))
				var b: Array = gs[j].links.map(func(l): return boundary.find(l))
				a.sort()
				for lo_i in a.size():
					var lo: int = a[lo_i]
					var hi: int = a[(lo_i + 1) % a.size()]
					var inside: int = 0
					for p in b:
						var between: bool = (p > lo and p < hi) if lo < hi else (p > lo or p < hi)
						if between:
							inside += 1
					assert_true(a.size() < 2 or inside == 0 or inside == b.size(), "region %d: clusters interleave" % rid)


func test_opening_needs_adjacency_points_and_access() -> void:
	var gd := game_data()
	var t := _tree()
	var c := _c()
	var gate: int = t.frontier(c).filter(func(id): return t.node(id).kind == "gate")[0]
	assert_true(t.can_allocate(c, gate, gd).ok, "adjacent")
	c.tree_points = 0
	assert_false(t.can_allocate(c, gate, gd).ok, "no points")
	c.tree_points = 5
	var far: int = t.nodes.values().filter(func(n): return n.kind == "keystone" and n.sector != "")[0].id
	assert_false(t.can_allocate(c, far, gd).ok, "not adjacent")


func test_center_keystone_reads_n_base_lc35() -> void:
	var gd := game_data()
	var t := _tree()
	var center: int = t.nodes.values().filter(func(n): return int(n.get("requires_elements", 0)) == 5)[0].id
	var four := _c({"hoa": 50, "kim": 50, "moc": 50, "tho": 50})
	four.linh_can.variants = {"phong": 50}
	assert_false(t.can_allocate(four, center, gd).ok, "n_eff 5 is not enough")
	assert_true(t.can_allocate(_c({"hoa": 50, "kim": 50, "moc": 50, "tho": 50, "thuy": 50}), center, gd).ok, "five base")


func test_a_hidden_cluster_stays_shut_until_unsealed() -> void:
	var gd := game_data()
	var t := _tree()
	var k: Dictionary = t.clusters[0]
	var c := _c()
	var entry_host: int = int(k.links[0])
	c.tree_nodes.append(entry_host)
	for id in t.frontier(c):
		assert_true(int(t.node(id).get("cluster", -1)) != 0, "hidden nodes are not frontier")
	assert_eq(t.path_to(c, gd, int(k.nodes[0])), [], "the path tool cannot route in")
	c.unsealed.append(0)
	var entries: Array = t.frontier(c).filter(func(id): return int(t.node(id).get("cluster", -1)) == 0)
	assert_false(entries.is_empty(), "entries join the frontier")


func test_a_variant_sector_opens_only_with_the_variant_lc33() -> void:
	var gd := game_data()
	var t := _tree()
	var road: int = MeridianTree.VARIANT_ID_BASE
	assert_eq(t.node(road).get("variant", ""), "phong", "slot 0 is Wind")
	var c := _c()
	assert_false(t.accessible(c, road), "locked")
	var before: int = t.reported_size(c)
	assert_false(t.can_allocate(c, road, gd).ok, "a spend is refused")
	c.linh_can.variants = {"phong": 62}
	assert_true(t.accessible(c, road), "unlocked")
	assert_eq(t.reported_size(c), before + 30, "the sector joins the reported size")


func test_variant_sectors_hold_thirty_acupoints_each() -> void:
	var t := _tree()
	assert_eq(t.visible_variant_count(), 240, "8 x 30")
	for v in game_data().variant_defs():
		var nodes: Array = t.nodes.values().filter(func(n): return n.get("variant", "") == v.id)
		assert_eq(nodes.size(), 30, "%s size" % v.id)
		assert_eq(nodes.filter(func(n): return n.kind == "apex").size(), 1, "%s apex" % v.id)
		assert_eq(nodes.filter(func(n): return n.kind == "keystone").size(), 0, "%s no keystone" % v.id)
		for n in nodes:
			for m in n.mods:
				assert_true(not (m.stat in ["breakthrough_chance", "herb_growth_pct", "alchemy_success", "lifespan_years"]), "%s forbidden stat %s" % [v.id, m.stat])


func test_chords_join_two_sectors_and_spurs_one() -> void:
	var t := _tree()
	var ids: Array = game_data().variant_defs().map(func(v): return v.id)
	for i in ids.size():
		var hosts: int = 0
		for n in t.nodes.values():
			if n.get("variant", "") == ids[i]:
				for nb in n.links:
					if t.node(nb).get("variant", "") != ids[i]:
						hosts += 1
		assert_eq(hosts, 2 if ids[i] in ["loi", "am"] else 1, "%s host links" % ids[i])


func test_sector_scale_follows_purity_lc34() -> void:
	var gd := game_data()
	var t := _tree()
	var lc := LinhCan.new()
	lc.elements = {"moc": 40, "hoa": 86}
	var gate_of := func(e): return t.nodes.values().filter(func(n): return n.kind == "gate" and n.sector == e)[0].id
	assert_near(t.node_scale(gate_of.call("moc"), lc, gd), 0.9, 1e-9, "Wood")
	assert_near(t.node_scale(gate_of.call("hoa"), lc, gd), 1.36, 1e-9, "Fire")
	assert_near(t.node_scale(gate_of.call("tho"), lc, gd), 0.25, 1e-9, "absent Earth")
	var bridge: int = t.nodes.values().filter(func(n): return n.kind == "bridge" and n.sector == "moc-hoa")[0].id
	assert_near(t.node_scale(bridge, lc, gd), 1.13, 1e-9, "bridge")
	lc.variants = {"loi": 47}
	assert_near(t.node_scale(MeridianTree.VARIANT_ID_BASE + 300, lc, gd), 0.97, 1e-9, "Thunder sector")


func test_paths_are_shortest_and_prefer_value() -> void:
	var gd := game_data()
	var t := _tree()
	var c := _c()
	var keystone: int = t.nodes.values().filter(func(n): return n.kind == "keystone" and n.sector == "hoa")[0].id
	var path: Array = t.path_to(c, gd, keystone)
	assert_eq(path.size(), int(t.node(keystone).depth), "reaching depth d costs d points")
	assert_eq(path[-1], keystone, "ends at the target")
	var prev: int = MeridianTree.ROOT_ID
	for id in path:
		assert_true(t.neighbors(prev).has(id), "a connected route")
		prev = id


func test_roads_are_generic_and_ignore_the_root() -> void:
	var gd := game_data()
	var t := _tree()
	var generic: Array = gd.tree_config().road_stats
	var lc := LinhCan.new()
	lc.elements = {"hoa": 50}
	for n in t.nodes.values():
		if n.kind in ["road", "junction"]:
			assert_eq(t.node_scale(n.id, lc, gd), 1.0, "#%d pays the same on every root" % n.id)
			for m in n.mods:
				assert_true(generic.has(m.stat), "#%d stat %s" % [n.id, m.stat])


func test_every_gap_between_elements_holds_clusters() -> void:
	var t := _tree()
	for band in ["border_inner", "border_middle", "border_outer"]:
		var regions: Array = t.regions.filter(func(r): return r.band == band)
		assert_eq(regions.size(), 5, band)
		for r in regions:
			var count: int = t.groups.filter(func(g): return int(g.region) == int(r.id)).size()
			assert_true(count >= 1, "%s %s holds a cluster" % [band, r.sector])


func test_no_region_holds_more_than_its_capacity() -> void:
	var t := _tree()
	var caps: Dictionary = game_data().tree_config().region_capacity
	for r in t.regions:
		if caps.has(r.band):
			assert_true(int(r.load) <= int(caps[r.band]), "%s %s holds %d" % [r.band, r.sector, int(r.load)])


func test_a_shrunk_cluster_keeps_its_value_in_stronger_acupoints() -> void:
	var t := _tree()
	for k in t.clusters.values():
		var premium: Dictionary = game_data().tree_config().premium
		assert_true(float(k.premium) >= float(premium.p_min), "%s premium" % k.name)


func test_road_values_carry_no_breakthrough_chance() -> void:
	var t := _tree()
	for n in t.nodes.values():
		if n.kind in ["road", "junction", "gate"]:
			for m in n.mods:
				assert_true(m.stat != "breakthrough_chance", "#%d" % n.id)


func test_every_stat_on_the_map_is_a_known_key() -> void:
	var gd := game_data()
	var labels: Dictionary = gd.file("character_stat_labels").labels
	for n in _tree().nodes.values():
		for m in n.mods:
			assert_true(labels.has(m.stat), "%s on #%d" % [m.stat, n.id])


func test_a_small_acupoint_is_worth_about_the_base_value() -> void:
	var gd := game_data()
	var t := _tree()
	var c := _c({"hoa": 50})
	var small: Array = t.nodes.values().filter(func(n): return n.kind == "small" and int(n.get("cluster", -1)) < 0 and n.sector == "hoa")
	var w: float = t.node_value(c, gd, small[0].id)
	assert_true(w > 0.7 and w <= 1.25, "W %.2f" % w)
