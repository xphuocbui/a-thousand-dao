extends DaoTestSuite
## TooltipLayer's pure parts (design/ux/hud.md, Tooltips): source identity, body parsing, term content.


func test_two_texts_of_one_control_are_two_sources() -> void:
	# A map place under the pointer changes the map's one tip text: moving from place A to place B must be a new source,
	# or the chain keeps showing A (found 2026-11-22).
	var layer: TooltipLayer = auto_free(TooltipLayer.new())
	var c: Control = auto_free(Control.new())
	assert_true(layer._source_id(c, {"title": "Place A"}) != layer._source_id(c, {"title": "Place B"}), "place A and place B differ")
	assert_eq(layer._source_id(c, {"id": "x", "title": "A"}), layer._source_id(c, {"id": "x", "title": "A, updated"}),
		"an explicit id keeps one source while its text updates")


func test_parse_body_splits_highlighted_words() -> void:
	var segs: Array = TooltipLayer.parse_body("Stones of [[linh_khi|spiritual qi]]. And [[tu_vi]]")
	assert_eq(segs.size(), 4)
	assert_eq(segs[0], "Stones of ")
	assert_eq(segs[1], {"key": "linh_khi", "text": "spiritual qi"})
	assert_eq(segs[2], ". And ")
	assert_eq(segs[3], {"key": "tu_vi", "text": "tu_vi"})


func test_words_keep_their_spaces_so_punctuation_hugs_a_link() -> void:
	assert_eq(TooltipLayer._words_with_spaces(". And them; they"), [". ", "And ", "them; ", "they"])
	assert_eq(TooltipLayer._words_with_spaces(" price in"), [" price ", "in"], "a leading space stays on the first word")


func test_term_content_reads_an_authored_entry_and_unknown_keys_give_nothing() -> void:
	var terms := {"mua": {"title": "Season (mùa)", "summary": "One turn.", "body": "Costs [[tho_nguyen|lifespan]]."}}
	var c: Dictionary = TooltipLayer.term_content(terms, "mua")
	assert_eq(c.title, "Season (mùa)")
	assert_eq(c.wiki, "mua")
	assert_eq(Array(c.body).size(), 3)
	assert_true(TooltipLayer.term_content(terms, "nope").is_empty(), "unknown key")
