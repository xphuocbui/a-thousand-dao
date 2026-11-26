extends DaoTestSuite
## Item Database rule 20 (named items: uniqueness by rarity, return after destruction), rule 21's
## modifiers on the sheet, and Formulas D's jewellery affix pool (AC-ID-89, AC-ID-93).


func _template_of_grade(grade: int) -> String:
	for t in game_data().named_items():
		if int(t.grade) == grade:
			return str(t.id)
	return ""


func test_every_named_template_has_a_known_base_and_a_grade_from_1_to_4() -> void:
	var gd := game_data()
	assert_true(gd.named_items().size() > 0, "the catalogue is exported")
	for t in gd.named_items():
		assert_false(gd.artifact_base(str(t.base)).is_empty(), "base of %s" % t.id)
		assert_true(int(t.grade) >= 1 and int(t.grade) <= 4, "grade of %s" % t.id)


func test_a_unique_named_item_is_made_once_per_world() -> void:
	# Arrange: a Cực (grade 4, rarity 5) template.
	var gd := game_data()
	var items := ItemFactory.new(gd)
	var db := WorldDB.new()
	var tid: String = _template_of_grade(4)
	assert_true(items.is_unique(tid), "rarity 5 is unique")
	# Act
	var first: Dictionary = items.named_artifact(tid, 2, db)
	db.add("items", first)
	var second: Dictionary = items.named_artifact(tid, 2, db)
	# Assert
	assert_false(first.is_empty(), "the first is made")
	assert_true(second.is_empty(), "no second while it exists")


func test_a_repeatable_named_item_is_made_any_number_of_times() -> void:
	var gd := game_data()
	var items := ItemFactory.new(gd)
	var db := WorldDB.new()
	var tid: String = _template_of_grade(2)
	assert_false(items.is_unique(tid), "rarity 3 repeats")
	db.add("items", items.named_artifact(tid, 0, db))
	assert_false(items.named_artifact(tid, 0, db).is_empty(), "a second copy")


func test_a_signature_item_marked_unique_is_made_once_whatever_its_grade() -> void:
	# Rule 20f (amended 2026-11-26): a world-depth signature item is unique whatever its grade (`unique: true`).
	var gd := game_data()
	var items := ItemFactory.new(gd)
	var db := WorldDB.new()
	var tid: String = _template_of_grade(2)
	var t: Dictionary = gd.named_item(tid)
	t["unique"] = true   # restored below: the template dict is the game data's own
	var unique: bool = items.is_unique(tid)
	var first: Dictionary = items.named_artifact(tid, 0, db)
	db.add("items", first)
	var second: Dictionary = items.named_artifact(tid, 0, db)
	t.erase("unique")
	assert_true(unique, "a grade 2 template marked unique is unique")
	assert_false(first.is_empty(), "the first is made")
	assert_true(second.is_empty(), "no second while it exists")


func test_a_destroyed_unique_item_returns_after_unique_return_years() -> void:
	# AC-ID-93 with the data value of unique_return_years.
	var gd := game_data()
	var items := ItemFactory.new(gd)
	var db := WorldDB.new()
	var tid: String = _template_of_grade(4)
	var wait: int = int(gd.artifacts_file().named.unique_return_years)
	var rec: Dictionary = items.named_artifact(tid, 1, db)
	rec["destroyed_year"] = 100
	db.add("items", rec)
	assert_false(items.named_available(db, tid, 100 + wait - 1), "refused a year early")
	assert_true(items.named_available(db, tid, 100 + wait), "made again on time")


func test_a_named_item_has_its_template_numbers_and_no_rolled_affixes() -> void:
	var gd := game_data()
	var items := ItemFactory.new(gd)
	var tid: String = _template_of_grade(2)
	var t: Dictionary = gd.named_item(tid)
	var rec: Dictionary = items.named_artifact(tid, 1, null)
	var scale: float = float(gd.artifact_grade(2).power_mult) * float(gd.artifact_tier(1).power_scale)
	assert_eq(rec.affixes, [], "no rolled affix")
	assert_eq(rec.modifiers.size(), t.modifiers.size(), "authored modifiers kept")
	assert_near(float(rec.attack), float(gd.artifact_base(str(t.base)).attack) * scale, 0.001, "Formulas D attack")
	assert_eq(rec.named, tid, "remembers its template")


func test_only_unscoped_known_named_modifiers_reach_the_sheet() -> void:
	var gd := game_data()
	var db := WorldDB.new()
	var c := TestFixtures.character({"hoa": 50})
	var aid: String = db.add("items", {
		"kind": "artifact", "name": "Thử", "base": "nhan", "element": "", "attack": 0.0, "defense": 0.0,
		"than_thuc_cost": 1.0, "affixes": [], "owner_id": "", "value": 1,
		"modifiers": [
			{"key": "khi_huyet_pct", "value": 10, "scope": []},
			{"key": "khi_huyet_pct", "value": 5, "scope": ["fire"]},
			{"key": "crit_chance_pct", "value": 5, "scope": []},
		],
	})
	c.equipped = [aid]
	var sheet := StatSheet.build(c, gd, db, null)
	assert_eq(sheet.total("khi_huyet_pct"), 10.0, "the scoped line waits for art combat")
	assert_eq(sheet.total("crit_chance_pct"), 0.0, "a key the game does not run is stored, not applied")


func test_no_record_has_a_than_thuc_cost_and_linh_gives_than_thuc() -> void:
	# AC-ID-12 and Formulas D (2026-11-13): no piece costs thần thức; the Linh affix is +7-18 % thần thức.
	var gd := game_data()
	var items := ItemFactory.new(gd)
	var r := RandomNumberGenerator.new()
	r.seed = 3
	var linh: Dictionary = gd.artifacts_file().affixes.filter(func(a): return a.id == "linh")[0]
	assert_eq(str(linh.stat), "than_thuc_pct", "Linh's stat")
	assert_true(float(linh.min) == 7.0 and float(linh.max) == 18.0, "Linh's range")
	for i in 30:
		assert_false(items.artifact(r, 1, 3).has("than_thuc_cost"), "rolled record %d" % i)
	assert_false(items.named_artifact(_template_of_grade(2), 1, null).has("than_thuc_cost"), "named record")


func test_jewellery_never_rolls_lie_or_kien() -> void:
	var gd := game_data()
	var items := ItemFactory.new(gd)
	var r := RandomNumberGenerator.new()
	r.seed = 7
	for base in ["nhan", "ngoc_boi"]:
		for i in 60:
			for a in items.artifact(r, 0, 4, "none", base).affixes:
				assert_false(str(a.id) in ["liet", "kien"], "%s rolled %s" % [base, a.id])


func test_a_weapon_still_rolls_liet() -> void:
	var gd := game_data()
	var items := ItemFactory.new(gd)
	var r := RandomNumberGenerator.new()
	r.seed = 7
	var seen: bool = false
	for i in 60:
		for a in items.artifact(r, 0, 4, "none", "phi_kiem").affixes:
			seen = seen or str(a.id) == "liet"
	assert_true(seen, "Liệt is in a weapon's pool")


func test_thiet_bich_rolls_with_its_physical_scope_and_stays_on_the_record() -> void:
	# Formulas D (user decision 2026-11-13): in the rolled pool, stored until art combat reads resistance.
	var gd := game_data()
	var items := ItemFactory.new(gd)
	var r := RandomNumberGenerator.new()
	r.seed = 11
	var found: Dictionary = {}
	for i in 300:
		for a in items.artifact(r, 0, 4, "none", "giap").affixes:
			if str(a.id) == "thiet_bich":
				found = a
	assert_false(found.is_empty(), "Thiết Bích is in the pool")
	assert_eq(Array(found.get("scope", [])), ["physical"], "scoped Physical")
	assert_eq(ItemStats.total({"affixes": [found]}, "resist_pct"), 0.0, "not applied to the sheet yet")


func test_a_variant_family_item_matches_its_variant_root() -> void:
	# Ice, Thunder, Wind and Force-Chaos named items carry their variant root (user decision 2026-11-13).
	var gd := game_data()
	var ice: Array = gd.named_items().filter(func(t): return str(t.family) == "ice")
	assert_true(not ice.is_empty() and str(ice[0].element) == "bang", "ice -> Băng")
	var c := TestFixtures.character({"thuy": 50})
	c.linh_can.variants["bang"] = 50
	assert_true(c.linh_can.has(str(ice[0].element)), "a Băng holder matches it")
