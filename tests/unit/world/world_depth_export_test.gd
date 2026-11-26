extends DaoTestSuite
## The world-depth export in the game (ADR-0009; world-depth plan Stage 7, Băng Tâm Các, 2026-11-26): the authored
## beasts and ties the WorldBuilder makes from world_history.json, the cast's gained traits, the save refusal on
## world_data_version, and CastBuilds reporting an unknown technique id. One world is built for the suite.

static var _s: GameSession


func before() -> void:
	var gd := game_data()
	var llm := LlmService.new(gd)
	llm.enabled = false
	_s = GameSession.new(gd, llm, TestFixtures.tree())
	_s.new_game(4242, {"mode": "roll", "name": "Thợ Đất", "gender": "male", "origin": "tan_tu"})
	_s.pending_event = {}


static func _cast(key: String) -> Dictionary:
	for p in _s.db.find("people", func(r): return str(r.get("cast_key", "")) == key):
		return p
	return {}


func test_the_exported_sect_brings_its_authored_people() -> void:
	var hist: Dictionary = game_data().file("world_history")
	assert_true(Array(hist.get("depth_sects", [])).has("bang_tam"), "Băng Tâm is exported")
	var head: Dictionary = _cast("so_ngoc_ho")
	assert_false(head.is_empty(), "the Keeper is in the world")
	assert_eq(str(head.get("build_source", "")), "authored", "with her authored build")
	assert_false(_cast("dao_han_mac").is_empty(), "and a tier C servant of the depth cast")


func test_an_authored_beast_is_owned_and_listed_by_its_owner() -> void:
	var owner: Dictionary = _cast("lam_tuyet_dieu")
	var sable: Dictionary = _cast("ngoc_dieu")
	assert_false(sable.is_empty(), "the Jade Sable is in the world")
	assert_true(bool(sable.get("is_beast", false)), "as a beast")
	assert_eq(str(sable.get("owner_id", "")), str(owner.get("id", "")), "owned by Lam Tuyết Điêu")
	assert_true(Array(owner.get("beasts", [])).has(str(sable.get("id", ""))), "who lists it")


func test_authored_ties_reach_the_tie_store() -> void:
	var hist: Dictionary = game_data().file("world_history")
	var made := 0
	var tried := 0
	for t in hist.get("ties", []):
		var a: Dictionary = _cast(str(t.a))
		var b: Dictionary = _cast(str(t.b))
		if a.is_empty() or b.is_empty():
			continue
		tried += 1
		if not _s.db.tie_between(str(a.id), str(b.id)).is_empty():
			made += 1
	assert_true(tried > 50, "the export carries the sect's ties (%d)" % tried)
	assert_true(made >= tried * 9 / 10, "nearly every authored tie is in the store (%d of %d; caps may refuse a few)" % [made, tried])


func test_the_casts_gained_traits_are_read() -> void:
	var head: Dictionary = _cast("so_ngoc_ho")
	var gained: Array = Array(Dictionary(head.get("npc_traits", {})).get("gained", []))
	assert_false(gained.is_empty(), "Renowned is a gained trait of the Keeper")


func test_a_save_with_another_world_data_version_is_refused() -> void:
	var gd := game_data()
	var d: Dictionary = JSON.parse_string(JSON.stringify(_s.to_dict()))
	var llm := LlmService.new(gd)
	llm.enabled = false
	assert_true(GameSession.new(gd, llm, TestFixtures.tree()).load_dict(d).ok, "a save of this version loads")
	d.db.tables.world.w_meta["world_data_version"] = 99
	var r: Dictionary = GameSession.new(gd, llm, TestFixtures.tree()).load_dict(d)
	assert_false(r.ok, "a save of another world data version is refused")
	assert_true(str(r.lines).contains("world data version"), "and says why")


func test_an_unknown_technique_id_is_reported_not_dropped_silently() -> void:
	var gd := game_data()
	var db := WorldDB.new()
	var c := Character.new()
	c.name = "probe"
	CastBuilds.unknown_ids.clear()
	var got: String = CastBuilds._learn(gd, db, ItemFactory.new(gd), c, "no-such-technique", 1, true)
	assert_eq(got, "", "nothing is learnt")
	assert_true(CastBuilds.unknown_ids.has("no-such-technique"), "the id is reported")
