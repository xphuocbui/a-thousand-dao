extends DaoTestSuite
## Missing art shows an obvious placeholder (.claude/rules/ui-code.md; user 2026-11-24): the illustrated frame and the
## round medallion fall back to PlaceholderArt, never to a bare label or an empty ring.


func test_a_frame_without_art_holds_the_placeholder() -> void:
	var f: PanelContainer = Illustrated.framed(null, Vector2(0, 120), "Thúy Vi Tông")
	auto_free(f)
	var ph: Array = f.get_children().filter(func(c): return bool(c.get_meta("placeholder", false)))
	assert_eq(ph.size(), 1, "the frame holds the placeholder")
	assert_true((ph[0] as Control).tooltip_text.contains("Thúy Vi Tông"), "it names what is missing")


func test_a_frame_with_art_has_no_placeholder() -> void:
	var tex := ImageTexture.create_from_image(Image.create(4, 4, false, Image.FORMAT_RGB8))
	var f: PanelContainer = Illustrated.framed(tex, Vector2(0, 120))
	auto_free(f)
	assert_false(f.get_children().any(func(c): return bool(c.get_meta("placeholder", false))), "a painting, no placeholder")


func test_a_medallion_without_a_portrait_shows_the_stripes() -> void:
	var m: TextureRect = Illustrated.medallion(null, 56.0) as TextureRect
	auto_free(m)
	assert_true(PlaceholderArt.is_placeholder(m.texture), "the placeholder's stripes in the ring")
	assert_true(m.tooltip_text.contains("PLACEHOLDER"), m.tooltip_text)
