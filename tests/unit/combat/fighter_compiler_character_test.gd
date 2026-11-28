extends DaoTestSuite
## FighterCompiler.compile for a Character (ADR-0001 step 3; user decisions 2026-11-14: typical layers for the realm,
## the library and modifier table shared with fight.py). The build-file step itself is parity-tested against fight.py
## in tests/parity/compile_parity_test.gd; these tests cover what a Character puts into the build file.

const WEAPON := "blade-mirror-trace-sword"     # a weapon with one art and scoped modifiers
const ROBE := "blade-edge-hiding-robe"         # body gear with a drain ward and pool and divine-sense lines


func _named(db: WorldDB, gd: GameData, tid: String, realm: int) -> String:
	var rec: Dictionary = ItemFactory.new(gd).named_artifact(tid, realm, db)
	assert_false(rec.is_empty(), "%s is made" % tid)
	return db.add("items", rec)


func _ordinary(db: WorldDB, affixes: Array) -> String:
	return db.add("items", {"kind": "artifact", "name": "Thử", "base": "", "element": "", "attack": 10.0,
		"defense": 0.0, "affixes": affixes, "owner_id": "", "value": 1})


func test_a_bare_character_fights_as_the_typical_fighter_of_its_realm_with_its_purity() -> void:
	var gd := game_data()
	var db := WorldDB.new()
	var c := TestFixtures.character({"hoa": 60}, 50, 1)
	var report: Array = []
	var d: Dictionary = FighterCompiler.character_build_file(c, gd, db, StatSheet.build(c, gd, db, null), report)
	var typical: Dictionary = gd.file("combat_library").typical[1]
	var want: Array = Array(typical.layers).duplicate()
	want[0] = 0.0
	want[2] = 0.0
	assert_eq(d.layers, want, "typical L2, L4, L5; L1 from its own attack_pct (none); no gear in L3")
	assert_near(float(d.n_body), 50.0 / 45.0, 1e-9, "căn cốt 50 against the talent-45 reference")
	assert_eq(float(d.ward.ws_base), 0.0, "no ward gear: no gear ward strength")
	assert_near(float(d.ward.block), 4.4 * 50.0 / 45.0, 1e-9, "flesh block only")
	assert_eq(d.arts, typical.arts, "the typical kit stands in for arts")
	assert_true(report.any(func(x): return str(x).contains("typical kit")), "and the report says so")
	assert_eq(d.purity, {"fire": 60.0}, "hỏa purity as Fire")
	var errors: Array = []
	var p: FighterProfile = FighterCompiler.compile(c, gd, db, StatSheet.build(c, gd, db, null), [], errors)
	assert_true(p != null and errors.is_empty(), "compiles: %s" % str(errors))
	if p == null:
		return   # a fight with no profile never advances (2026-11-26: it hung the suite for 18 min)
	var r: FightResult = Fight.new(p, FighterCompiler.from_data("typical", 1, gd), CombatConstants.from_game_data(gd), 3).run()
	assert_true(r.seconds > 0.0, "and fights")


func test_named_pieces_bring_their_arts_wards_and_modifiers() -> void:
	var gd := game_data()
	var db := WorldDB.new()
	var c := TestFixtures.character({"kim": 50}, 50, 2)
	c.equipped = [_named(db, gd, WEAPON, 2), _named(db, gd, ROBE, 2)]
	var sheet := StatSheet.build(c, gd, db, null)
	var d: Dictionary = FighterCompiler.character_build_file(c, gd, db, sheet)
	assert_eq(d.items, [WEAPON, ROBE], "both named pieces compile")
	var lib: Dictionary = gd.file("combat_library")
	assert_eq(d.arts, [{"lib": lib.items[WEAPON].arts[0]}], "the weapon's art, not the kit")
	var errors: Array = []
	var p: FighterProfile = FighterCompiler.compile(c, gd, db, sheet, [], errors)
	assert_true(p != null and errors.is_empty(), "compiles: %s" % str(errors))
	assert_eq(p.arts.size(), 1, "one art")
	assert_eq(p.wards.size(), 1, "the robe's ward")
	assert_true(p.effects.any(func(e): return e.id == "item:" + WEAPON), "the weapon's modifiers run as an Effect")


func test_worn_pieces_count_once() -> void:
	# The sheet already holds an ordinary piece's unscoped affix (KIND_ITEM); the compile takes worn pieces' lines
	# from the pieces, so the sheet's copy is left out.
	var gd := game_data()
	var db := WorldDB.new()
	var c := TestFixtures.character({"hoa": 50}, 50, 1)
	c.equipped = [_ordinary(db, [{"id": "a", "word": "", "stat": "khi_huyet_pct", "value": 10.0},
		{"id": "b", "word": "", "stat": "attack_pct", "value": 6.0, "scope": ["fire"]}])]
	var sheet := StatSheet.build(c, gd, db, null)
	assert_eq(sheet.total("khi_huyet_pct"), 10.0, "the sheet counts the affix")
	var d: Dictionary = FighterCompiler.character_build_file(c, gd, db, sheet)
	var pools: Array = d.modifiers.filter(func(l): return l.key == "khi_huyet_pct")
	assert_eq(pools.size(), 1, "one khi_huyet_pct line")
	assert_eq(float(pools[0].value), 10.0, "worth the affix once")
	var scoped: Array = d.modifiers.filter(func(l): return l.key == "attack_pct")
	assert_eq(scoped.size(), 1, "the scoped affix comes too")
	assert_eq(scoped[0].scope, ["fire"], "with its scope")


func test_sheet_lines_from_other_sources_reach_the_fight() -> void:
	var gd := game_data()
	var db := WorldDB.new()
	var c := TestFixtures.character({"hoa": 50}, 50, 0)
	var sheet := StatSheet.build(c, gd, db, null)
	sheet.add_mod("test perk", "crit_chance_pct", 5.0)
	sheet.add_mod("test perk", "cultivation_speed_pct", 30.0)
	var d: Dictionary = FighterCompiler.character_build_file(c, gd, db, sheet)
	assert_true(d.modifiers.any(func(l): return l.key == "crit_chance_pct" and float(l.value) == 5.0), "crit comes")
	assert_false(d.modifiers.any(func(l): return l.key == "cultivation_speed_pct"), "cultivation speed stays out")
	var p: FighterProfile = FighterCompiler.compile(c, gd, db, sheet)
	assert_true(p.effects.any(func(e): return e.id == "tech:character"), "the sheet's lines run as one Effect")


func test_a_piece_past_the_slot_count_is_not_compiled() -> void:
	# Qi Refining with 50 thần hồn has two extra slots (equip_control_test): the third piece is past the count
	var gd := game_data()
	var db := WorldDB.new()
	var c := TestFixtures.character({"hoa": 50}, 50, 0)
	var a: String = _ordinary(db, [])
	var b: String = _ordinary(db, [])
	var past: String = _ordinary(db, [{"id": "x", "word": "", "stat": "crit_chance_pct", "value": 9.0}])
	c.equipped = [a, b, past]
	var d: Dictionary = FighterCompiler.character_build_file(c, gd, db, StatSheet.build(c, gd, db, null))
	assert_false(d.modifiers.any(func(l): return l.key == "crit_chance_pct"), "the third extra piece adds nothing")


func test_pools_follow_the_characters_vitality_and_linh_luc() -> void:
	# Combat Formulas A: n = clamp(stat / ref[r], 0.25, 8), the stats before their pct bonuses
	var gd := game_data()
	var db := WorldDB.new()
	var c := TestFixtures.character({"hoa": 50}, 45, 1, 0)
	var sheet := StatSheet.build(c, gd, db, null)
	var p: Dictionary = FighterCompiler.pool_sizes(c, gd, sheet, 1)
	assert_near(float(p.n_body), 1.0, 1e-9, "talent 45 at stage 1.00 is the reference")
	assert_near(float(p.n_qi), float(gd.cong_phap_file().no_tech_power), 1e-9, "no main method: its power alone")
	var strong := TestFixtures.character({"hoa": 50}, 90, 1, 2)
	var p2: Dictionary = FighterCompiler.pool_sizes(strong, gd, StatSheet.build(strong, gd, db, null), 1)
	assert_near(float(p2.n_body), 2.0 * Ladder.stage_mult(gd, 2), 1e-9, "talent 90, stage 2: twice, times the stage")
	var absurd := TestFixtures.character({"hoa": 50}, 45, 1, 0)
	var p3: Dictionary = FighterCompiler.pool_sizes(absurd, gd, StatSheet.build(absurd, gd, db, null), 4)
	assert_near(float(p3.n_body), float(gd.combat().fighter_pools.n_min), 1e-9, "a Foundation body against Nascent Soul's reference clamps")


func test_pct_bonuses_count_once_through_the_sheet_lines() -> void:
	var gd := game_data()
	var db := WorldDB.new()
	var c := TestFixtures.character({"hoa": 50}, 45, 1, 0)
	var sheet := StatSheet.build(c, gd, db, null)
	sheet.add_mod("test", "khi_huyet_pct", 20.0)
	var d: Dictionary = FighterCompiler.character_build_file(c, gd, db, sheet)
	assert_near(float(d.n_body), 1.0, 1e-9, "the base leaves the bonus out")
	var rec: Dictionary = BuildFileCompiler.new(gd).compile(d)
	assert_near(float(rec.n_body), 1.2, 1e-9, "the sheet line adds it once")


func test_the_gear_layer_follows_worn_artifacts_attack() -> void:
	# Combat Formulas B, L3 = 100 x attack as built / (power_base x stage_mult)
	var gd := game_data()
	var db := WorldDB.new()
	var c := TestFixtures.character({"hoa": 50}, 50, 0, 0)
	c.equipped = [_ordinary(db, [])]
	var sheet := StatSheet.build(c, gd, db, null)
	var want: float = 100.0 * 10.0 / float(gd.realm(0).power_base)
	assert_near(FighterCompiler.gear_layer(c, gd, db, sheet), want, 1e-9, "attack 10 at Qi Refining")
	assert_near(float(FighterCompiler.character_build_file(c, gd, db, sheet).layers[2]), want, 1e-9, "in L3")
	c.stage = 2
	assert_near(FighterCompiler.gear_layer(c, gd, db, StatSheet.build(c, gd, db, null)), want / Ladder.stage_mult(gd, 2), 1e-9, "a later stage needs more gear")


func test_a_generated_common_carries_one_common_art_of_its_element() -> void:
	# Cultivation Techniques rule 17: one ability from the library's common tier, from an element it names, layer 1
	var gd := game_data()
	var items := ItemFactory.new(gd)
	var lib: Dictionary = gd.file("combat_library").arts
	for seed_v in [1, 2, 3, 4, 5]:
		var m: Dictionary = items.cong_phap(rng(seed_v), 1, ["hoa"])
		assert_eq(m.abilities.size(), 1, "one ability")
		var art: Dictionary = lib[m.abilities[0].ability_id]
		assert_eq(str(art.source), "part_common", "from the common tier")
		assert_eq(str(art.element), "fire", "hỏa names Fire")
		assert_eq(int(m.abilities[0].unlock_layer), 1, "unlocked at layer 1")
	var a1: Array = items.common_ability("gen_42", ["thuy"], "main")
	assert_eq(items.common_ability("gen_42", ["thuy"], "main"), a1, "the same technique always has the same art")
	var body: Array = items.common_ability("gen_7", ["kim"], "body")
	assert_eq(str(lib[body[0].ability_id].element), "", "a body technique's art is element-less")


func test_slotted_technique_arts_come_before_item_arts() -> void:
	var gd := game_data()
	var db := WorldDB.new()
	var c := TestFixtures.character({"hoa": 60}, 50, 1)
	var manual: Dictionary = ItemFactory.new(gd).cong_phap(rng(9), 1, ["hoa"])
	CongPhap.learn(c, manual)
	c.main_tech = str(manual.tech_id)
	c.equipped = [_named(db, gd, WEAPON, 1)]
	var d: Dictionary = FighterCompiler.character_build_file(c, gd, db, StatSheet.build(c, gd, db, null))
	var lib: Dictionary = gd.file("combat_library")
	assert_eq(d.arts, [{"lib": manual.abilities[0].ability_id}, {"lib": lib.items[WEAPON].arts[0]}], "technique art, then the weapon's")
	var p: FighterProfile = FighterCompiler.compile(c, gd, db, StatSheet.build(c, gd, db, null))
	assert_true(p != null and p.arts.size() == 2, "both fight")



func _piece(db: WorldDB, base: String, defense: float) -> String:
	return db.add("items", {"kind": "artifact", "name": "Giáp", "base": base, "element": "", "attack": 0.0,
		"defense": defense, "affixes": [], "owner_id": "", "value": 1})


func test_typical_ward_gear_reproduces_the_typical_ward() -> void:
	# Combat Defence & Healing A0, A2: a_w 0.85 gives ws_base 25.5 (the rest of 30.8 is modifiers), W3 +40, block 15.0
	var gd := game_data()
	var db := WorldDB.new()
	var c := TestFixtures.character({"hoa": 50}, 45, 0, 0)
	c.equipped = [_piece(db, "thuan", 85.0)]
	var g: Dictionary = FighterCompiler.gear_defence(c, gd, db, StatSheet.build(c, gd, db, null), 1.0883, {})
	assert_near(float(g.ward.ws_base), 25.5, 1e-9, "ward strength from gear")
	assert_near(float(g.ward.we), 25.5, 1e-9, "and efficiency")
	assert_near(float(g.ward.layers[1]), 39.95, 1e-9, "W3 about +40")
	assert_near(float(g.ward.block), 4.4 * 1.0883 + 12.0 * 0.85, 1e-9, "block 15.0")
	assert_true(g.body.is_empty(), "no body gear, no body layers")


func test_body_gear_fills_the_body_layers_and_body_block() -> void:
	var gd := game_data()
	var db := WorldDB.new()
	var c := TestFixtures.character({"hoa": 50}, 45, 0, 0)
	c.equipped = [_piece(db, "giap", 100.0)]
	var g: Dictionary = FighterCompiler.gear_defence(c, gd, db, StatSheet.build(c, gd, db, null), 1.0, {})
	assert_near(float(g.body.layers[1]), 47.0, 1e-9, "B3 from a_b 1.0")
	assert_near(float(g.body.block), 12.0, 1e-9, "body block")
	assert_eq(float(g.ward.ws_base), 0.0, "body gear is not ward gear")
	var p: FighterProfile = FighterCompiler.compile(c, gd, db, StatSheet.build(c, gd, db, null))
	assert_near(p.bs_mult, 1.47, 1e-9, "the body layers reach the fighter")


func test_an_authored_technique_brings_its_unlocked_arts_and_scoped_passives() -> void:
	# Cultivation Techniques rule 17, exported from design/techniques (tools/design/items/export_techniques.py)
	var gd := game_data()
	var db := WorldDB.new()
	var t: Dictionary = gd.cong_phap_file().templates.filter(func(x): return x.id == "hunters-reach-canon")[0]
	var c := TestFixtures.character({"kim": 60}, 50, 0)
	CongPhap.learn(c, ItemFactory.new(gd).manual_from_template(t))
	c.main_tech = "hunters-reach-canon"
	var d: Dictionary = FighterCompiler.character_build_file(c, gd, db, StatSheet.build(c, gd, db, null))
	assert_eq(d.arts, [{"lib": "pinning-arrow"}], "layer 1 unlocks only the first art")
	var scoped: Array = d.modifiers.filter(func(l): return l.key == "status_duration_pct")
	assert_eq(scoped.size(), 1, "the passive comes")
	assert_eq(scoped[0].scope, ["curse"], "with its scope")
	c.techniques["hunters-reach-canon"].layer = 3
	var d3: Dictionary = FighterCompiler.character_build_file(c, gd, db, StatSheet.build(c, gd, db, null))
	assert_eq(d3.arts, [{"lib": "pinning-arrow"}, {"lib": "nocked-arrow"}], "layer 3 adds the second")
	assert_true(FighterCompiler.compile(c, gd, db, StatSheet.build(c, gd, db, null)) != null, "and it compiles")


func test_a_stand_in_template_without_abilities_gets_one_common_art() -> void:
	var gd := game_data()
	var items := ItemFactory.new(gd)
	var t: Dictionary = gd.cong_phap_file().templates.filter(func(x): return x.id == "dia_kim")[0]
	assert_true(Array(t.abilities).is_empty(), "the stand-in has none of its own")
	var m: Dictionary = items.manual_from_template(t)
	assert_eq(m.abilities.size(), 1, "one art")
	assert_eq(str(gd.file("combat_library").arts[m.abilities[0].ability_id].element), "metal", "of its element")
	assert_eq(items.manual_from_template(t).abilities, m.abilities, "every copy carries the same art")
	var authored: Dictionary = gd.cong_phap_file().templates.filter(func(x): return x.id == "hunters-reach-canon")[0]
	assert_eq(items.manual_from_template(authored).abilities, authored.abilities, "authored abilities stay as written")


func test_rolled_pieces_give_their_bases_common_art_and_ward() -> void:
	# Item Database rule 21: a rolled weapon gives its base's common art; armour and ward gear their common ward
	var gd := game_data()
	var db := WorldDB.new()
	var c := TestFixtures.character({"kim": 50}, 50, 1)
	c.equipped = [_piece(db, "phi_kiem", 0.0), _piece(db, "giap", 30.0), _piece(db, "chuong", 10.0)]
	var d: Dictionary = FighterCompiler.character_build_file(c, gd, db, StatSheet.build(c, gd, db, null))
	assert_eq(d.arts, [{"lib": "flying-sword-strike"}], "the flying sword's strike")
	assert_eq(d.wards.size(), 2, "the armour's and the bell's wards")
	assert_eq(str(d.wards[0].name), "Black Tortoise Shell (Huyền Quy Giáp)", "the armour's ward")
	assert_true(bool(d.wards[0].own_slot), "in the armour's own slot")
	assert_false(bool(d.wards[1].own_slot), "the bell's ward takes an ordinary slot")
	var p: FighterProfile = FighterCompiler.compile(c, gd, db, StatSheet.build(c, gd, db, null))
	assert_eq(p.wards.size(), 2, "both wards reach the fighter")


func test_own_damage_more_replaces_the_typical_l2_stand_in() -> void:
	# L2 = max(typical 40, own unscoped damage_more): nothing counts twice
	var gd := game_data()
	var db := WorldDB.new()
	var c := TestFixtures.character({"hoa": 50}, 50, 1)
	var sheet := StatSheet.build(c, gd, db, null)
	sheet.add_mod("test", "damage_more", 25.0)
	var d: Dictionary = FighterCompiler.character_build_file(c, gd, db, sheet)
	assert_near(float(d.layers[1]), 15.0, 1e-9, "the base keeps only what the own 25 does not cover")
	var rec: Dictionary = BuildFileCompiler.new(gd).compile(d)
	var p: FighterProfile = FighterProfileLoader.new(CombatConstants.from_game_data(gd)).from_sim_build(rec, "x")
	var l2 := 0.0
	for e in p.effects:
		for a in e.actions:
			if a.verb == "mod" and a.arg.has("L2"):
				l2 += float(a.arg.L2)
	assert_near(float(rec.layers[1]) + l2, 40.0, 1e-9, "15 + 25 = the typical 40, not 65")


func test_capability_4_linh_luc_is_not_scaled_by_linh_luc_pct() -> void:
	# CharacterRules.linh_luc adds Huyết Ngự Linh after the pct step; the fight's pool must match the game's
	var gd := game_data()
	var db := WorldDB.new()
	var c := TestFixtures.character({"hoa": 50}, 45, 1, 0)
	c.grant_capability(4)
	var sheet := StatSheet.build(c, gd, db, null)
	sheet.add_mod("test", "linh_luc_pct", 50.0)
	var rec: Dictionary = BuildFileCompiler.new(gd).compile(FighterCompiler.character_build_file(c, gd, db, sheet))
	var ref_qi: float = float(gd.realm(1).linh_luc_base) * float(gd.combat().fighter_pools.ref_tech_power)
	assert_near(float(rec.n_qi), CharacterRules.linh_luc(c, gd, sheet).total / ref_qi, 1e-9, "the game's linh lực, once")


func test_a_worn_set_shows_on_the_sheet_and_runs_in_the_fight() -> void:
	# Item Database rule 22, Formulas J (world-depth Stage 5 slice 6, 2026-11-26): two of three pieces give the 2-piece
	# Modifiers (on the sheet as "Bộ: <name> (2/3)", in the fight as set:<id>); all of a 2-piece set also its Effect.
	var gd := game_data()
	var old: Dictionary = gd.file("items_sets")
	gd.registry.set_file("items_sets", {"constants": {"set_bonus_min_pieces": 2}, "sets": [
		{"id": "trio", "name": "Blade Trio", "pieces": [WEAPON, ROBE, "blade-sword-nest-flag"],
			"bonuses": [{"pieces": 2, "modifiers": [{"key": "linh_luc_pct", "value": 8, "scope": []},
				{"key": "attack_pct", "value": 4, "scope": []}]}]},
		{"id": "pair", "name": "Blade Pair", "pieces": [WEAPON, ROBE],
			"bonuses": [{"pieces": 2, "modifiers": [{"key": "attack_pct", "value": 5, "scope": []}]},
				{"pieces": 2, "effect": "Pair Whole", "record": {"id": "x", "on": "always", "do": [{"mod": {"block": 5}}]}}]}]})
	var db := WorldDB.new()
	var c := TestFixtures.character({"kim": 50}, 50, 2)
	c.equipped = [_named(db, gd, WEAPON, 2), _named(db, gd, ROBE, 2)]
	var sheet := StatSheet.build(c, gd, db, null)
	var errors: Array = []
	var p: FighterProfile = FighterCompiler.compile(c, gd, db, sheet, [], errors)
	gd.registry.set_file("items_sets", old)
	assert_true(sheet.sources("linh_luc_pct").any(func(x): return str(x.source) == "Bộ: Blade Trio (2/3)"),
			"the sheet shows the set and its count: %s" % str(sheet.sources("linh_luc_pct")))
	assert_true(p != null and errors.is_empty(), "compiles: %s" % str(errors))
	if p == null:
		return
	var ids: Array = p.effects.map(func(e): return str(e.id))
	# linh_luc_pct is a pool stat, folded into the build like an item's; attack_pct runs as the set:<id> Effect
	assert_true(ids.has("set:trio") and not ids.has("set:trio:full"), "two of three: the Modifiers only: %s" % str(ids))
	assert_true(ids.has("set:pair") and ids.has("set:pair:full"), "a whole 2-piece set: both: %s" % str(ids))


func test_darkness_convergence_purity_and_am_scope_compile() -> void:
	# Darkness (am) Convergence purity (LinhCan rule 10: round(0.8 * sqrt(60 * 60)) = 48) -> purity["dark"] == 48.0
	var gd := game_data()
	var db := WorldDB.new()
	var c := TestFixtures.character({"tho": 60, "thuy": 60}, 50, 1)
	var am_p: float = c.linh_can.derived_purity(gd, "am")
	assert_near(am_p, 48.0, 1e-9, "derived_purity('am') = round(0.8 * 60) = 48")
	c.linh_can.variants["am"] = am_p
	var sheet := StatSheet.build(c, gd, db, null)
	sheet.add_mod("test", "attack_pct", 14.0, StatSheet.KIND_TREE, ["am"])
	var d: Dictionary = FighterCompiler.character_build_file(c, gd, db, sheet)
	assert_near(float(d.purity.get("dark", 0.0)), 48.0, 1e-9, "build file maps am purity -> purity['dark'] = 48.0")
	var errors: Array = []
	var p: FighterProfile = FighterCompiler.compile(c, gd, db, sheet, [], errors)
	assert_true(p != null and errors.is_empty(), "compiles cleanly: %s" % str(errors))
	if p == null:
		return
	assert_near(float(p.purity.get("dark", 0.0)), 48.0, 1e-9, "profile keeps purity['dark'] = 48.0")
	var found_dark_l1 := false
	for e in p.effects:
		for a in e.actions:
			if a.verb == "mod" and absf(float(a.arg.get("L1", 0.0)) - 14.0) < 1e-9 and str(a.arg.get("element", "")) == "dark":
				found_dark_l1 = true
	assert_true(found_dark_l1, "attack_pct [am] compiles into FighterProfile as L1 element='dark'")
