extends DaoTestSuite
## Advisor: goals, menu actions and event odds read from a real session (LLM off, fixed seed).


func _session(origin: String = "gia_toc") -> GameSession:
	var gd := game_data()
	var llm := LlmService.new(gd)
	llm.enabled = false
	var s := GameSession.new(gd, llm, TestFixtures.tree())
	s.new_game(4242, {"mode": "roll", "name": "Cố Vấn", "gender": "male", "origin": origin})
	s.pending_event = {}
	return s


func _to_bottleneck(s: GameSession) -> void:
	var c: Character = s.player
	c.realm_index = 0
	c.level = Ladder.band(s.gd, 0)[1]
	c.level_peak = c.level
	c.stage = Ladder.stage_of_level(s.gd, c.level)
	c.tu_vi = CultivationRules.level_requirement(c, s.gd)
	for it in s.db.items_of(c.id):
		if it.kind == "pill":
			s.db.remove("items", it.id)


func _goal(s: GameSession, id: String) -> Dictionary:
	for g in Advisor.goals(s):
		if g.id == id:
			return g
	return {}


func test_bottleneck_without_pill_names_the_recipe_and_herb_progress() -> void:
	var s := _session()
	_to_bottleneck(s)
	var g := _goal(s, "breakthrough")
	assert_eq(g.get("severity", ""), "urgent", "bình cảnh is urgent")
	var recipe: Dictionary = Advisor.recipe_for_tag(s.gd, str(s.gd.realm(1).entry_requirement.item_tag))
	assert_true(str(g.text).contains(recipe.name), "names the pill: %s" % g.text)
	for ing in recipe.ingredients:
		assert_true(str(g.text).contains(s.gd.herb(ing.herb).name), "mentions %s: %s" % [ing.herb, g.text])
	assert_true(str(g.text).contains("Without it"), "states the pill-less chance")


func test_bottleneck_with_pill_suggests_breakthrough() -> void:
	var s := _session()
	_to_bottleneck(s)
	var tag: String = str(s.gd.realm(1).entry_requirement.item_tag)
	s.alchemy.add_pills(s.player, Advisor.recipe_for_tag(s.gd, tag).id, 1, 1)
	var g := _goal(s, "breakthrough")
	assert_eq(g.command, "breakthrough", "acts by breaking through")
	assert_eq(Advisor.goals(s)[0].id, "breakthrough", "most severe goal first")


func test_ripe_planted_ingredient_suggests_harvesting_that_plot() -> void:
	var s := _session()
	var c: Character = s.player
	var recipe: Dictionary = Advisor.recipe_for_tag(s.gd, str(s.gd.realm(1).entry_requirement.item_tag))
	var ing: Dictionary = recipe.ingredients[0]
	var plot: int = s.field.free_plot(c, s.sheet())
	if plot == -1:
		for it in s.field.planted(c).values():
			s.db.remove("items", it.id)
		plot = s.field.free_plot(c, s.sheet())
	var h: Dictionary = s.items.herb(str(ing.herb), float(ing.min_age) + 1.0)
	h["owner_id"] = c.id
	h["plot"] = plot
	s.db.add("items", h)
	var st: Dictionary = Advisor.ingredient_status(s, c, s.sheet(), ing)
	assert_eq(st.command, "harvest %d" % plot, "harvest the ripe plot: %s" % st.text)
	assert_true(st.ready, "ready")


func test_pending_event_comes_first_and_menu_lists_its_choices() -> void:
	var s := _session()
	s.start_event("tam_ma_xam_nhap")
	assert_true(s.has_pending_event(), "event forced")
	assert_eq(Advisor.goals(s)[0].id, "event", "event first")
	var acts: Array = Advisor.actions(s)
	assert_eq(acts.size(), s.pending_event.choices.size(), "one menu entry per choice")
	assert_eq(acts[0].command, "choose 1", "numbered choose commands")


func test_unspent_points_and_short_lifespan_are_reported() -> void:
	var s := _session()
	var c: Character = s.player
	c.tree_points = 3
	c.age = CultivationRules.lifespan(c, s.gd, s.sheet()).total - 2.0
	assert_eq(_goal(s, "tree").get("command", ""), "tree", "points -> tree")
	assert_eq(_goal(s, "lifespan").get("severity", ""), "urgent", "two years left is urgent")


func test_unaffordable_choice_is_marked_with_a_reason() -> void:
	var s := _session()
	s.player.linh_thach = 0
	s.pending_event = {"title": "Phí", "text": "", "npc_id": "", "place_id": s.player.location_id, "choices": [
		{"label": "Nộp", "check": {"type": "none"}, "always": [{"type": "linh_thach", "amount": -10}], "success": {"text": "", "effects": []}, "failure": {"text": "", "effects": []}},
		{"label": "Nhìn", "check": {"type": "stat", "stat": "ngo_tinh", "difficulty": 50}, "always": [], "success": {"text": "", "effects": []}, "failure": {"text": "", "effects": []}},
	]}
	var a: Dictionary = Advisor.choice_odds(s, 0)
	var b: Dictionary = Advisor.choice_odds(s, 1)
	assert_false(a.ok, "cannot pay")
	assert_true(str(a.reason).contains("10"), "reason names the cost: %s" % a.reason)
	assert_true(b.ok and b.chance > 0.0 and b.chance < 1.0, "stat check has odds: %s" % str(b))


func test_snapshot_diff_reports_time_tu_vi_and_items() -> void:
	var s := _session()
	var before: Dictionary = StateSnapshot.take(s)
	s.closed_door(1)
	s.alchemy.add_pills(s.player, "tu_khi_dan", 0, 2)
	var changes: Array = StateSnapshot.diff(before, StateSnapshot.take(s), s.gd)
	var keys: Array = changes.map(func(ch): return ch.key)
	assert_true(keys.has("time"), "time passed: %s" % str(keys))
	assert_true(keys.has("tu_vi") or keys.has("realm"), "progress shown: %s" % str(keys))
	assert_true(keys.has("items_gained"), "pills gained: %s" % str(keys))
	assert_eq(changes[0].text, "1 year passed", "duration text")


func test_snapshot_diff_is_empty_when_nothing_changed() -> void:
	var s := _session()
	var a: Dictionary = StateSnapshot.take(s)
	assert_eq(StateSnapshot.diff(a, StateSnapshot.take(s), s.gd).size(), 0, "no changes")


func test_snapshot_diff_skips_changes_that_round_to_the_same_value() -> void:
	# Regression: tâm ma 9.4 -> 8.6 was shown as "Tâm ma 9 → 9 (-1)".
	var s := _session()
	s.player.tam_ma = 9.4
	var a: Dictionary = StateSnapshot.take(s)
	s.player.tam_ma = 8.6
	var keys: Array = StateSnapshot.diff(a, StateSnapshot.take(s), s.gd).map(func(ch): return ch.key)
	assert_false(keys.has("tam_ma"), "no visible change: %s" % str(keys))


func test_a_young_herb_in_the_bag_is_planted_not_searched_for() -> void:
	# Regression: a Kim Tủy Quả bought young sat in the bag while the advice said
	# "find one (markets, exploring)", so the player (and the balance bot) kept buying more.
	var s := _session()
	var c: Character = s.player
	var ing: Dictionary = {"herb": "kim_tuy_qua", "min_age": 100.0, "qty": 1}
	var h: Dictionary = s.items.herb("kim_tuy_qua", 60.0)
	h["owner_id"] = c.id
	var hid: String = s.db.add("items", h)
	var st: Dictionary = Advisor.ingredient_status(s, c, s.sheet(), ing)
	assert_false(str(st.text).contains("find one"), "not told to search: %s" % st.text)
	assert_true(str(st.text).contains("60"), "names the herb age: %s" % st.text)
	if s.field.free_plot(c, s.sheet()) != -1:
		assert_eq(st.command, "plant %s" % hid, "plant that herb")


func test_unseedable_herb_names_a_price_and_the_market_offer() -> void:
	var s := _session()
	var c: Character = s.player
	var ing: Dictionary = {"herb": "kim_tuy_qua", "min_age": 100.0, "qty": 1}
	var away: Dictionary = Advisor.ingredient_status(s, c, s.sheet(), ing)
	assert_true(int(away.get("price", 0)) > 0, "estimates a market price: %s" % away.text)
	var market: Array = s.db.find("places", func(pl): return bool(pl.get("market", false)))
	assert_false(market.is_empty(), "the world has a market")
	c.location_id = market[0].id
	s.market.ensure_stock(s.rng, c.location_id, s.year, c.realm_index)
	var h: Dictionary = s.items.herb("kim_tuy_qua", 40.0)
	h["owner_id"] = Market.owner_of(c.location_id)
	s.db.add("items", h)
	c.linh_thach = 100000
	var offers: Array = s.market.stock(c.location_id).filter(func(i): return i.get("template", "") == "kim_tuy_qua")
	offers.sort_custom(func(a, b): return float(a.age) > float(b.age))
	var here: Dictionary = Advisor.ingredient_status(s, c, s.sheet(), ing)
	assert_eq(here.command, "buy %s" % offers[0].id, "buy the oldest offered herb: %s" % here.text)


func test_no_work_here_points_to_the_nearest_bounty_town() -> void:
	# Regression (balance probe): a poor tán tu whose home had no bounties was only told
	# "Missions and bounties pay" and never found work, dying at Luyện Khí 13 with no money.
	var s := _session("tan_tu")
	var c: Character = s.player
	var here: Dictionary = s.db.get_record("places", c.location_id)
	here["bounties"] = false
	c.sect_id = ""
	c.linh_thach = 0
	var work: String = Advisor.nearest_work_place(s)
	assert_true(work != "" and work != c.location_id, "a bounty town elsewhere: %s" % work)
	var g := _goal(s, "money")
	assert_true(str(g.get("command", "")).begins_with("go "), "travel toward work: %s" % str(g))
