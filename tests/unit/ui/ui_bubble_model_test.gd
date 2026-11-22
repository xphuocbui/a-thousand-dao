extends DaoTestSuite
## BubbleModel (design/ux/hud.md, Map bubbles): kinds per place, reach within a season over known roads, the cap with
## nearest-first order and the current place always kept, and free versus season actions.

const EXPLORE := ["ruin", "beast_lair"]


func _links() -> Dictionary:
	# here -a 0.4- b -0.4- c (c is 0.8 away); here -0.5- d; here -1.5- far; b -0.1- hidden (unknown)
	return {
		"here": [{"to": "a", "seasons": 0.4}, {"to": "d", "seasons": 0.5}, {"to": "far", "seasons": 1.5}],
		"a": [{"to": "here", "seasons": 0.4}, {"to": "c", "seasons": 0.4}, {"to": "hidden", "seasons": 0.1}],
		"c": [{"to": "a", "seasons": 0.4}],
		"d": [{"to": "here", "seasons": 0.5}],
		"hidden": [{"to": "a", "seasons": 0.1}],
	}


func _known() -> Dictionary:
	return {"here": true, "a": true, "c": true, "d": true, "far": true}


func test_kinds_for_reads_market_sect_work_and_explore() -> void:
	var k: Dictionary = BubbleModel.kinds_for({"market": true, "sect_id": "s1", "kind": "ruin"}, false, 0, true, EXPLORE)
	assert_eq(k, {"market": 1, "sect": 1, "work": 1, "explore": 1}, "every kind the place has")


func test_people_bubble_only_at_the_players_place() -> void:
	assert_eq(BubbleModel.kinds_for({}, true, 3, false, EXPLORE), {"people": 3}, "people met who are here now")
	assert_eq(BubbleModel.kinds_for({}, false, 3, false, EXPLORE), {}, "elsewhere: no last-seen data, no bubble")
	assert_eq(BubbleModel.kinds_for({}, true, 0, false, EXPLORE), {}, "nobody known here")


func test_distances_stay_within_the_reach_and_on_known_places() -> void:
	var d: Dictionary = BubbleModel.distances("here", _links(), _known(), 1.0)
	assert_near(float(d["a"]), 0.4, 1e-9, "a by road")
	assert_near(float(d["c"]), 0.8, 1e-9, "c through a")
	assert_near(float(d["d"]), 0.5, 1e-9, "d by road")
	assert_false(d.has("far"), "1.5 seasons is beyond the 1-season reach")
	assert_false(d.has("hidden"), "an unknown place is never reached")


func test_build_orders_nearest_first_and_keeps_kind_order() -> void:
	var kinds := {"here": {"explore": 1, "market": 1}, "a": {"sect": 1}, "c": {"market": 1}, "d": {"work": 1}}
	var d: Dictionary = BubbleModel.distances("here", _links(), _known(), 1.0)
	var b: Array = BubbleModel.build(kinds, d, "here", 12)
	var seq: Array = b.map(func(x): return "%s:%s" % [x.place_id, x.kind])
	assert_eq(seq, ["here:market", "here:explore", "a:sect", "d:work", "c:market"], "here first, then by seasons, kinds in order")


func test_cap_drops_the_farthest_but_never_the_current_place() -> void:
	var kinds := {"here": {"market": 1, "sect": 1, "work": 1}, "a": {"sect": 1}, "c": {"market": 1}, "d": {"work": 1}}
	var d: Dictionary = BubbleModel.distances("here", _links(), _known(), 1.0)
	var b: Array = BubbleModel.build(kinds, d, "here", 2)
	var seq: Array = b.map(func(x): return "%s:%s" % [x.place_id, x.kind])
	assert_eq(seq, ["here:market", "here:sect", "here:work"], "the current place's bubbles stay even past the cap")
	var b2: Array = BubbleModel.build(kinds, d, "here", 4)
	assert_eq(b2.map(func(x): return x.place_id), ["here", "here", "here", "a"], "the cap fills nearest first")


func test_ties_in_distance_break_by_place_id() -> void:
	var links := {"here": [{"to": "zz", "seasons": 0.5}, {"to": "aa", "seasons": 0.5}]}
	var known := {"here": true, "zz": true, "aa": true}
	var d: Dictionary = BubbleModel.distances("here", links, known, 1.0)
	var b: Array = BubbleModel.build({"zz": {"market": 1}, "aa": {"market": 1}}, d, "here", 12)
	assert_eq(b.map(func(x): return x.place_id), ["aa", "zz"], "equal seasons: lower id first")


func test_free_and_season_actions() -> void:
	for k in ["market", "sect", "people"]:
		assert_true(BubbleModel.is_free_here(k), "%s opens its window at once" % k)
	for k in ["work", "explore"]:
		assert_false(BubbleModel.is_free_here(k), "%s goes through the focus comparison" % k)
