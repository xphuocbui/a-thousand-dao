extends DaoTestSuite
## Item icons (tools/asset-pipeline/icons/gen_item_icons.py): every item template the factory makes has its painted
## icon, a named legendary item shows its own, and a công pháp manual falls back to the generic cover.

static var _gd: GameData


static func _data() -> GameData:
	if _gd == null:
		_gd = GameData.load_from("res://assets/data")
	return _gd


func test_every_artifact_base_herb_material_and_pill_has_an_icon() -> void:
	var gd := _data()
	for b in Array(gd.file("items_artifacts").bases):
		assert_true(GameQuery.item_icon({"kind": "artifact", "base": str(b.id)}) != "", "artifact " + str(b.id))
	for pair in [["herb", "items_herbs", "herbs"], ["material", "items_materials", "materials"], ["pill", "items_recipes", "recipes"]]:
		for t in Array(gd.file(str(pair[1]))[str(pair[2])]):
			assert_true(GameQuery.item_icon({"kind": str(pair[0]), "template": str(t.id)}) != "", "%s %s" % [pair[0], t.id])


func test_a_named_item_shows_its_own_icon_not_its_base() -> void:
	var gd := _data()
	for t in Array(gd.file("items_named").named):
		var path: String = GameQuery.item_icon({"kind": "artifact", "base": str(t.base), "named": str(t.id)})
		assert_true(path.ends_with("named_%s.png" % str(t.id)), "%s -> %s" % [t.id, path])


func test_a_manual_without_an_element_gets_the_plain_cover() -> void:
	assert_true(GameQuery.item_icon({"kind": "cong_phap", "elements": []}).ends_with("cong_phap_.png"))
