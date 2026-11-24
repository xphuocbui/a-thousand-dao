extends DaoTestSuite
## DaoDoCanvas and DaoDoScreen (design/ux/dao-do-view.md): the v5 map loads whole, clusters get the viewer's stat
## families, off-screen nodes are skipped, redraws happen only on a change; the plan grows by routes, Apply is refused
## while the plan costs more than the points (rule 3: nothing spent partway), arms a confirm, emits the plan in order;
## leaving with a plan asks first.

static var _gd: GameData
static var _tree: DaoDoTree


static func _data() -> GameData:
	if _gd == null:
		_gd = GameData.load_from("res://assets/data")
		_tree = DaoDoTree.load_map(_gd)
	return _gd


func _canvas() -> DaoDoCanvas:
	_data()
	var c: DaoDoCanvas = auto_free(DaoDoCanvas.new())
	c.families = _gd.file("ui_windows").get("dao_do", {}).get("families", {})
	c.size = Vector2(1200, 800)
	add_child(c)
	c.setup(_tree)
	return c


func test_the_whole_v5_map_loads() -> void:
	var c := _canvas()
	assert_eq(c.node_count(), Array(_gd.file("dao_do_map").nodes).size())


func test_clusters_get_the_viewer_s_stat_families() -> void:
	var c := _canvas()
	var fams: Dictionary = {}
	for nd in Array(_gd.file("dao_do_map").nodes):
		var f: String = c.family_of_cluster(int(nd.get("cluster", -1)))
		if f != "":
			fams[f] = true
	for f in ["offence", "defence", "sustain", "cultivation"]:
		assert_true(fams.has(f), "some cluster is %s" % f)


func test_zoomed_in_only_the_nodes_in_view_are_drawn() -> void:
	var c := _canvas()
	c.centre_on(int(_tree.starts.values()[0]), 20.0)
	c.queue_redraw()
	await get_tree().process_frame
	await get_tree().process_frame
	assert_true(c.drawn_nodes > 0 and c.drawn_nodes < c.node_count() / 4, "%d of %d drawn" % [c.drawn_nodes, c.node_count()])


func test_it_redraws_only_on_a_change() -> void:
	var c := _canvas()
	await get_tree().process_frame
	await get_tree().process_frame
	var before: int = c.draws
	for i in 5:
		await get_tree().process_frame
	assert_eq(c.draws, before, "no change, no redraw")
	c.pan(Vector2(10, 0))
	await get_tree().process_frame
	assert_eq(c.draws, before + 1, "a pan redraws once")


func _screen(points: int) -> DaoDoScreen:
	_data()
	var s: DaoDoScreen = auto_free(DaoDoScreen.new())
	s.tree = _tree
	s.cfg = _gd.file("ui_windows").get("dao_do", {})
	# a fake reader: every node is plannable by a two-node route [id - 1, id]
	s.node_reader = func(id: int, pending: Array) -> Dictionary:
		return {"id": id, "name": "N%d" % id, "kind": "notable", "area": "el:kim", "lines": "+1 attack", "open": false,
			"planned": pending.has(id), "route": [id - 1, id], "cost": 2, "gains": {}, "purity_now": {}, "route_lines": [],
			"stats": ["+4% attack", "+10% fire resistance"], "scale": 1.0, "cap": 0, "effect": "", "closes": "",
			"ok": not pending.has(id), "reason": ""}
	add_child(s)
	s.show_view({"open": [1], "points": points, "start": 1, "starts": [], "frontier": [2], "next_points": "", "gate_open": false}, "x", false)
	return s


func test_planning_adds_the_route_and_reset_clears_it() -> void:
	var s := _screen(5)
	s._on_click(11)
	s._on_click(21)
	assert_eq(s.plan(), [10, 11, 20, 21])
	s.reset_plan()
	assert_eq(s.plan(), [])


func test_apply_is_refused_while_the_plan_costs_more_than_the_points() -> void:
	var s := _screen(3)
	s._on_click(11)
	s._on_click(21)
	assert_true(s._apply.disabled, "4 marks, 3 points")
	assert_true(s._apply.accessibility_name.contains("nothing is spent partway"))


func test_apply_arms_a_confirm_and_emits_the_plan_in_order() -> void:
	var s := _screen(5)
	var got: Array = []
	s.action_requested.connect(func(a: String, args: Array): got.append([a, args]))
	s._plan_route(11)
	s._apply.pressed.emit()
	assert_eq(got, [], "armed first")
	(s.find_child("ConfirmApply", true, false) as Button).pressed.emit()
	assert_eq(got, [["tree_apply", [[10, 11]]]])


func test_leaving_with_a_plan_asks_first() -> void:
	var s := _screen(5)
	assert_false(s.ask_leave(), "no plan: no question")
	s._plan_route(11)
	assert_true(s.ask_leave(), "a plan: keep, discard or stay")
	var went: Array = []
	s.leave_decided.connect(func(go: bool): went.append(go))
	(s.find_child("Leave_discard", true, false) as Button).pressed.emit()
	assert_eq(went, [true])
	assert_eq(s.plan(), [], "discarded")


func test_hovering_a_mark_shows_its_stats_one_per_line() -> void:
	var s := _screen(5)
	s._show_card(11, Vector2(100, 100))
	var t: String = s.card_text()
	assert_true(t.contains("N11") and t.contains("+4% attack") and t.contains("+10% fire resistance"), t)
	assert_true(t.contains("Click to plan: 2 point(s)"), "what reaching it costs")


func test_clicking_a_planned_mark_takes_it_and_the_rest_back_out() -> void:
	var s := _screen(5)
	s._on_click(11)
	s._on_click(21)
	assert_eq(s.plan(), [10, 11, 20, 21])
	s._on_click(20)
	assert_eq(s.plan(), [10, 11], "20 and everything after it")


func test_the_icon_sheet_covers_every_node() -> void:
	var c := _canvas()
	assert_eq(c.load_icons("res://assets/icons/dao_do/game/icons.json"), c.node_count(), "an icon for every node")


func test_the_bar_is_grouped_and_the_minimap_moves_the_view() -> void:
	var s := _screen(5)
	for g in ["points", "search", "plan", "view"]:
		assert_true(s.find_child("Group_" + g, true, false) != null, "the %s group" % g)
	assert_true(s._apply.get_parent().get_parent().name == "Group_plan", "Apply sits in the Plan group")
	var m: DaoDoMinimap = s.find_child("Minimap", true, false) as DaoDoMinimap
	assert_true(m != null, "the minimap in the corner")
	m.size = Vector2(200, 200)
	var c: DaoDoCanvas = s.canvas()
	var target: Vector2 = m.world_at(Vector2(30, 170))
	var ev := InputEventMouseButton.new()
	ev.button_index = MOUSE_BUTTON_LEFT
	ev.pressed = true
	ev.position = Vector2(30, 170)
	m._gui_input(ev)
	assert_true(c.view_world_rect().get_center().distance_to(target) < 0.01, "a click centres the view there")


func test_the_canvas_takes_the_body_s_place_under_the_bar() -> void:
	var s := _screen(5)
	var holder: Node = s.find_child("CanvasHolder", true, false)
	assert_true(holder.get_index() > s.header.get_index(), "the tree sits under the bar, not above it")
	assert_false(s.body_area().visible, "the empty body area is hidden, so the tree gets the height")
