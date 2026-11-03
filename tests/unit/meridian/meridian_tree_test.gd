extends DaoTestSuite
## MeridianTree (Kinh Mạch Đồ): generation, connectivity and allocation rules.


func test_generation_is_deterministic() -> void:
	var gd := game_data()
	var a := MeridianTree.generate(gd)
	var b := MeridianTree.generate(gd)
	assert_eq(a.size(), b.size(), "same size")
	assert_eq(a.node(17), b.node(17), "same node 17")


func test_every_node_reachable_from_root() -> void:
	var tree := TestFixtures.tree()
	var seen := {MeridianTree.ROOT_ID: true}
	var queue: Array = [MeridianTree.ROOT_ID]
	while not queue.is_empty():
		var cur: int = queue.pop_back()
		for nb in tree.neighbors(cur):
			if not seen.has(nb):
				seen[nb] = true
				queue.append(nb)
	assert_eq(seen.size(), tree.size(), "connected")


func test_tree_has_notables_and_keystones_per_element() -> void:
	var tree := TestFixtures.tree()
	var keystones := 0
	var notables := 0
	for n in tree.nodes.values():
		if n.kind == "keystone":
			keystones += 1
		if n.kind == "notable":
			notables += 1
	assert_eq(keystones, 6, "5 element keystones + center")
	assert_eq(notables, 30, "6 notables per element")


func test_allocate_requires_adjacency_and_points() -> void:
	var gd := game_data()
	var tree := TestFixtures.tree()
	var c := TestFixtures.character({"hoa": 50})
	c.tree_points = 0
	var gate: int = tree.neighbors(MeridianTree.ROOT_ID)[0]
	assert_false(tree.can_allocate(c, gate, gd).ok, "no points")
	c.tree_points = 1
	assert_true(tree.can_allocate(c, gate, gd).ok, "adjacent gate")
	var far: int = tree.size() - 2
	assert_false(tree.can_allocate(c, far, gd).ok, "far node not adjacent")


func test_center_keystone_requires_five_elements() -> void:
	var gd := game_data()
	var tree := TestFixtures.tree()
	var center: int = -1
	for n in tree.nodes.values():
		if n.kind == "keystone" and n.sector == "center":
			center = n.id
	var c := TestFixtures.character({"hoa": 50, "moc": 50})
	c.tree_points = 5
	assert_false(tree.can_allocate(c, center, gd).ok, "two elements")
	var c5 := TestFixtures.character({"kim": 50, "moc": 50, "thuy": 50, "hoa": 50, "tho": 50})
	c5.tree_points = 5
	assert_true(tree.can_allocate(c5, center, gd).ok, "five elements")


func test_path_to_returns_shortest_unallocated_chain() -> void:
	var tree := TestFixtures.tree()
	var target: int = -1
	for n in tree.nodes.values():
		if n.kind == "keystone" and n.sector == "hoa":
			target = n.id
	var path: Array = tree.path_to([MeridianTree.ROOT_ID], target)
	assert_eq(path[-1], target, "ends at target")
	assert_true(tree.neighbors(MeridianTree.ROOT_ID).has(path[0]), "starts next to root")
	for i in path.size() - 1:
		assert_true(tree.neighbors(path[i]).has(path[i + 1]), "consecutive nodes linked")


func test_node_scale_follows_purity() -> void:
	var gd := game_data()
	var tree := TestFixtures.tree()
	var gate_hoa: int = -1
	for n in tree.nodes.values():
		if n.kind == "gate" and n.sector == "hoa":
			gate_hoa = n.id
	var strong := TestFixtures.character({"hoa": 100}).linh_can
	var none := TestFixtures.character({"kim": 100}).linh_can
	assert_near(tree.node_scale(gate_hoa, strong, gd), 1.5, 0.001, "base 0.5 + purity 1.0")
	assert_near(tree.node_scale(gate_hoa, none, gd), 0.25, 0.001, "absent element")
