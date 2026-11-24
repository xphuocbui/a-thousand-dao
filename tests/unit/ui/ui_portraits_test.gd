extends DaoTestSuite
## Portraits (user decision 2026-11-24 "Set + special characters"; tools/asset-pipeline/portraits/gen_portraits.py):
## every bucket the game can ask for has its own painting (no fallback), every person of the fixed cast has theirs, the
## same person always gets the same face, and GameQuery.portrait_fields maps age, realm and sect to look, tier and dress.

const LOOKS := ["youth", "prime", "elder"]
const TIERS := ["low", "high"]

static var _gd: GameData


static func _data() -> GameData:
	if _gd == null:
		_gd = GameData.load_from("res://assets/data")
	return _gd


func before_test() -> void:
	PortraitPicker.reset()


func _dresses() -> Array:
	var out: Array = ["loose", "minor_chinh", "minor_trung", "minor_ma"]
	for s in Array(_data().file("world_continent").great_sects):
		out.append(str(s.key))
	return out


func test_every_bucket_has_its_own_painting() -> void:
	for sex in ["m", "f"]:
		for look in LOOKS:
			for dress in _dresses():
				for tier in TIERS:
					var key: String = PortraitPicker.key_for({"id": "p1", "sex": sex, "look": look, "dress": dress, "tier": tier})
					assert_true(key.begins_with("type/%s_%s_%s_%s_" % [sex, look, dress, tier]), "%s %s %s %s -> %s" % [sex, look, dress, tier, key])


func test_every_person_of_the_fixed_cast_has_a_portrait() -> void:
	for p in Array(_data().file("world_history").people):
		assert_eq(PortraitPicker.key_for({"cast": str(p.key), "sex": "m"}), "cast/" + str(p.key))
		assert_true(PortraitPicker.texture_for({"cast": str(p.key)}) != null, str(p.key))


func test_a_named_character_without_a_painting_gets_the_placeholder_not_a_type_face() -> void:
	assert_eq(PortraitPicker.key_for({"cast": "no_such_person", "sex": "m", "look": "prime", "dress": "loose", "tier": "low", "id": "p1"}), "")
	assert_true(PortraitPicker.texture_for({"cast": "no_such_person", "sex": "m"}) == null, "null: the window shows PlaceholderArt")


func test_the_same_person_always_gets_the_same_face_and_others_spread() -> void:
	var f := {"sex": "m", "look": "youth", "dress": "loose", "tier": "low"}
	var seen: Dictionary = {}
	for i in 40:
		f["id"] = "p%d" % i
		var k: String = PortraitPicker.key_for(f)
		assert_eq(PortraitPicker.key_for(f), k, "stable")
		seen[k] = true
	assert_eq(seen.size(), 3, "the three faces of the commonest bucket are all used")


func test_portrait_fields_map_age_realm_and_sect() -> void:
	var gd := _data()
	var young := GameQuery.portrait_fields(gd, {"id": "a", "gender": "female", "age": 16.0, "realm_index": 0}, {})
	assert_eq([young.sex, young.look, young.dress, young.tier], ["f", "youth", "loose", "low"])
	var old := GameQuery.portrait_fields(gd, {"id": "b", "age": 450.0, "realm_index": 2}, {"kind": "great", "key": "thuy_vi"})
	assert_eq([old.sex, old.look, old.dress, old.tier], ["m", "elder", "thuy_vi", "high"], "450 of Kết Đan's 500 years looks old")
	var minor := GameQuery.portrait_fields(gd, {"id": "c", "age": 90.0, "realm_index": 1}, {"kind": "minor", "alignment": "ma"})
	assert_eq([minor.look, minor.dress, minor.tier], ["prime", "minor_ma", "low"])
