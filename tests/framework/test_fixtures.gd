class_name TestFixtures
extends RefCounted
## Shared read-only fixtures for unit tests: the real data files (loaded once) and
## factory functions that build characters with exact values (no random inputs).

static var _gd: GameData = null
static var _tree: MeridianTree = null


## The project's real data, loaded once.
static func game_data() -> GameData:
	if _gd == null:
		_gd = GameData.load_from("res://assets/data")
	return _gd


## The Kinh Mạch Đồ generated from the real data, built once.
static func tree() -> MeridianTree:
	if _tree == null:
		_tree = MeridianTree.generate(game_data())
	return _tree


## A character with every thiên phú at [param stat_value] and the given purities.
static func character(purities: Dictionary, stat_value: int = 50, realm_index: int = 0, stage: int = 0) -> Character:
	var c := Character.new()
	c.name = "Test"
	for def in game_data().thien_phu_defs():
		c.thien_phu[def.id] = stat_value
	for e in purities.keys():
		c.linh_can.elements[e] = int(purities[e])
	c.realm_index = realm_index
	c.stage = stage
	c.tree_nodes = [MeridianTree.ROOT_ID]
	return c
