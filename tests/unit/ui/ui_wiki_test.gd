extends DaoTestSuite
## WikiData and WikiWindow (design/ux/wiki.md): the index counts match the data, a trait entry shows its boons and
## costs, highlighted words become links, a bare id resolves to a term, search dims in place, unknown keys.

static var _gd: GameData


static func _data() -> GameData:
	if _gd == null:
		_gd = GameData.load_from("res://assets/data")
	return _gd


func test_the_index_counts_match_the_data_files() -> void:
	var gd := _data()
	var cats: Dictionary = {}
	for c in WikiData.categories(gd):
		cats[str(c.id)] = Array(c.entries).size()
	assert_eq(int(cats.terms), (gd.file("ui_terms").terms as Dictionary).size())
	for g in ["personality", "callings", "fate", "gained"]:
		assert_eq(int(cats[g]), Array(gd.file("traits")[g]).size(), g)
	assert_eq(int(cats.realms), gd.realms().size())
	assert_eq(int(cats.elements), 5)


func test_a_trait_entry_shows_boons_and_costs_in_the_game_s_words() -> void:
	var gd := _data()
	var t: Dictionary = gd.file("traits").personality[0]
	var v: Dictionary = WikiData.view(gd, "trait:" + str(t.id))
	assert_eq(str(v.title), str(t.name))
	var facts: String = "\n".join(Array(v.facts))
	assert_true(facts.contains("Boon: ") and facts.contains("Cost: "), facts)


func test_a_bare_id_resolves_to_a_term_and_its_words_are_links() -> void:
	var v: Dictionary = WikiData.view(_data(), "linh_thach")
	assert_eq(str(v.key), "term:linh_thach")
	assert_true(Array(v.body).any(func(seg): return seg is Dictionary), "highlighted words")
	var w: WikiWindow = auto_free(WikiWindow.new())
	add_child(w)
	w.show_view(v, "", false)
	var got: Array = []
	w.open_requested.connect(func(k: String, sub: String, _s: String): got.append(sub))
	var links: Array = w.body.find_children("*", "LinkButton", true, false)
	(links[0] as LinkButton).pressed.emit()
	assert_eq(got, ["linh_khi"], "the first highlighted word opens its entry")


func test_search_dims_non_matches_in_place() -> void:
	var w: WikiWindow = auto_free(WikiWindow.new())
	add_child(w)
	w.show_view(WikiData.view(_data(), ""), "", false)
	w._search.text = "linh thach"
	w._on_search(w._search.text)
	var full: int = 0
	var dim: int = 0
	for r in w._entry_rows:
		if (r[0] as Control).modulate.a >= 1.0:
			full += 1
		else:
			dim += 1
	assert_true(full >= 1 and dim > 10, "%d full, %d dimmed" % [full, dim])


func test_an_unknown_key_says_so() -> void:
	assert_true(bool(WikiData.view(_data(), "trait:nope").get("unknown", false)))
