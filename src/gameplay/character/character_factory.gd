class_name CharacterFactory
extends RefCounted
## Creates player characters in the two birth modes:
## - Thiên Định: thiên phú and linh căn are rolled (achievements enabled).
## - Tự Định: the player sets them (casual; achievements disabled).
## Design: game-concept.md § Character Stats (birth modes). Data: character_attributes.json.
##
## Usage:
## [codeblock]
## var c := CharacterFactory.roll_player(gd, rng, "Lâm Vô Danh", "male", "tan_tu")
## var custom := CharacterFactory.custom_player(gd, rng, "A", "female", "gia_toc",
##     {"ngo_tinh": 90}, {"hoa": 80, "moc": 60})
## [/codeblock]


## Rolls every thiên phú from the data's normal distribution.
static func roll_thien_phu(gd: GameData, rng: RandomNumberGenerator) -> Dictionary:
	var r: Dictionary = gd.attributes().roll
	var out: Dictionary = {}
	for def in gd.thien_phu_defs():
		out[def.id] = int(RngUtils.normal_clamped(rng, float(r.mean), float(r.sd), float(r.min), float(r.max)))
	return out


## Thiên Định player: everything rolled.
static func roll_player(gd: GameData, rng: RandomNumberGenerator, player_name: String, gender: String, origin_id: String) -> Character:
	var c := _base_player(gd, player_name, gender, origin_id)
	c.birth_mode = "thien_dinh"
	c.thien_phu = roll_thien_phu(gd, rng)
	c.linh_can = LinhCan.roll(gd, rng)
	_apply_origin(gd, c)
	return c


## Tự Định player: given thiên phú (missing ones default to the roll mean), element purities
## and variant picks. Nothing is rolled (linh-can.md rule 2). An invalid root choice falls
## back to one element at the mean, the frontend rejects it first with
## [method LinhCan.self_made_error].
static func custom_player(gd: GameData, rng: RandomNumberGenerator, player_name: String, gender: String, origin_id: String, thien_phu: Dictionary, purities: Dictionary, picks: Array = []) -> Character:
	var c := _base_player(gd, player_name, gender, origin_id)
	c.birth_mode = "tu_dinh"
	var r: Dictionary = gd.attributes().roll
	for def in gd.thien_phu_defs():
		c.thien_phu[def.id] = clampi(int(thien_phu.get(def.id, r.mean)), int(r.min), int(r.max))
	if LinhCan.self_made_error(gd, purities, picks) == "":
		c.linh_can = LinhCan.self_made(gd, purities, picks)
	else:
		c.linh_can = LinhCan.self_made(gd, {RngUtils.pick(rng, gd.element_cycle()): int(gd.attributes().linh_can.purity_mean)})
	_apply_origin(gd, c)
	return c


static func _base_player(gd: GameData, player_name: String, gender: String, origin_id: String) -> Character:
	var start: Dictionary = gd.attributes().start
	var c := Character.new()
	c.name = player_name
	c.gender = gender
	c.is_player = true
	c.origin = origin_id if not gd.origin(origin_id).is_empty() else "tan_tu"
	c.archetype = "tan_tu"
	c.age = float(start.age)
	c.linh_thach = int(start.linh_thach)
	c.tree_points = int(start.tree_points)
	c.tree_nodes = [MeridianTree.ROOT_ID]
	return c


static func _apply_origin(gd: GameData, c: Character) -> void:
	var o: Dictionary = gd.origin(c.origin)
	c.linh_thach = int(o.get("linh_thach", c.linh_thach))
	if o.has("khi_van_bonus"):
		c.thien_phu["khi_van"] = clampi(c.base_stat("khi_van") + int(o.khi_van_bonus), 1, 100)
