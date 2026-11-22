extends DaoTestSuite
## LinkStyle (design/ux/hud.md, Tooltips: Content; user decision 2026-11-22): tooltipable text is underlined and styled
## by kind. The table here is a fixture; the game's is ui_hud.json "link_styles".

const TABLE := {
	"term": {"colour": "#E8C268"},
	"number": {"bold": true},
	"person": {"bold": true, "colours": {"friend": "#5BD66B", "hostile": "#E5384F"}},
	"place": {"italic": true},
	"item": {"colours": {"1": "#D8D8D8", "4": "#B98CFF"}},
	"sect": {"bold": true, "italic": true},
}


func before_test() -> void:
	LinkStyle.configure(TABLE)


func test_each_kind_gets_its_weight_slant_and_colour() -> void:
	var term: Dictionary = LinkStyle.style_of("term")
	assert_eq(term.colour, Color.html("#E8C268"), "terms in the term colour")
	assert_true(not term.bold and not term.italic)
	assert_true(LinkStyle.style_of("number").bold and LinkStyle.style_of("number").colour == null, "numbers bold, theme colour")
	assert_true(LinkStyle.style_of("place").italic and not LinkStyle.style_of("place").bold, "places italic")
	var sect: Dictionary = LinkStyle.style_of("sect", "#336699")
	assert_true(sect.bold and sect.italic, "sects bold italic")
	assert_eq(sect.colour, Color.html("#336699"), "in the sect's own colour")


func test_variants_pick_a_relation_or_rarity_colour() -> void:
	assert_eq(LinkStyle.style_of("person", "friend").colour, Color.html("#5BD66B"))
	assert_eq(LinkStyle.style_of("person", "hostile").colour, Color.html("#E5384F"))
	assert_true(LinkStyle.style_of("person", "stranger").colour == null, "an unknown relation keeps the theme colour")
	assert_eq(LinkStyle.style_of("item", "4").colour, Color.html("#B98CFF"), "rarity 4")


func test_a_key_names_its_kind_and_bare_keys_are_terms() -> void:
	assert_eq(LinkStyle.kind_of_key("place:dao_thanh"), "place")
	assert_eq(LinkStyle.kind_of_key("person:npc_12"), "person")
	assert_eq(LinkStyle.kind_of_key("linh_khi"), "term")
	assert_eq(LinkStyle.kind_of_key("odd:thing"), "term", "an unknown prefix reads as a term")
	assert_eq(LinkStyle.style_of("nonsense").colour, Color.html("#E8C268"), "an unknown kind is styled as a term")


func test_apply_underlines_a_link_button_and_sets_its_colour() -> void:
	var b: LinkButton = auto_free(LinkButton.new())
	b.underline = LinkButton.UNDERLINE_MODE_NEVER
	LinkStyle.apply(b, "term")
	assert_eq(b.underline, LinkButton.UNDERLINE_MODE_ALWAYS)
	assert_eq(b.get_theme_color(&"font_color"), Color.html("#E8C268"))


func test_apply_marks_a_label_for_its_drawn_underline_and_bolds_a_number() -> void:
	var l: Label = auto_free(Label.new())
	LinkStyle.apply(l, "number")
	assert_true(l.has_meta(&"link_underline"), "the label draws its underline")
	assert_true(l.has_theme_font_override(&"font"), "a bold font")
	LinkStyle.apply(l, "number")
	assert_eq(l.draw.get_connections().size(), 1, "styling twice draws one underline")
