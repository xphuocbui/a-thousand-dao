class_name PortraitPicker
extends RefCounted
## Picks a painted portrait for a person (user decision 2026-11-24: "Set + special characters";
## tools/asset-pipeline/portraits/gen_portraits.py). The fields come from GameQuery.portrait_of: a person of the fixed
## cast gets their own painting; everyone else gets one from the type set, keyed sex_look_dress_tier_variant, the variant
## chosen by a stable hash of the person id so the same person always shows the same face. When a key is missing the
## picker falls back to the loose dress, then to any painting of the same sex, so a box is never empty while the set fills.
## A named cast member without their own painting gets "" (the PlaceholderArt stripes, .claude/rules/ui-code.md).
## Textures are loaded once and cached.

const INDEX := "res://assets/portraits/portraits.json"
const DIR := "res://assets/portraits/"

static var _index: Dictionary = {}
static var _cache: Dictionary = {}


## The portrait key ("cast/<key>" or "type/<key>") for [param f] (GameQuery.portrait_of), or "" when none is installed.
static func key_for(f: Dictionary) -> String:
	_load_index()
	if f.is_empty():
		return ""
	var cast: String = str(f.get("cast", ""))
	if cast != "":   # a named character never wears a generic face: no painting yet means the placeholder (ui-code.md)
		return ("cast/" + cast) if Array(_index.get("cast", [])).has(cast) else ""
	var types: Array = Array(_index.get("type", []))
	var sex: String = str(f.get("sex", "m"))
	for prefix in ["%s_%s_%s_%s_" % [sex, f.get("look", "prime"), f.get("dress", "loose"), f.get("tier", "low")],
			"%s_%s_loose_%s_" % [sex, f.get("look", "prime"), f.get("tier", "low")], "%s_%s_" % [sex, f.get("look", "prime")], sex + "_"]:
		var hits: Array = types.filter(func(k): return str(k).begins_with(prefix))
		if not hits.is_empty():
			return "type/" + str(hits[absi(RngUtils.stable_hash(str(f.get("id", "")))) % hits.size()])
	return ""


## The portrait texture for [param f], or null when no painting is installed.
static func texture_for(f: Dictionary) -> Texture2D:
	var key: String = key_for(f)
	if key == "":
		return null
	if not _cache.has(key):
		var path: String = DIR + key + ".webp"
		_cache[key] = load(path) if ResourceLoader.exists(path) else null
	return _cache[key]


## The banner painting of a place by its continent id (assets/art/places/<id>.webp), or null.
static func place_painting(continent_id: int) -> Texture2D:
	var path: String = "res://assets/art/places/%d.webp" % continent_id
	if continent_id < 0 or not ResourceLoader.exists(path):
		return null
	if not _cache.has(path):
		_cache[path] = load(path)
	return _cache[path]


static func _load_index() -> void:
	if not _index.is_empty():
		return
	var f := FileAccess.open(INDEX, FileAccess.READ)
	if f == null:
		_index = {"type": [], "cast": []}
		return
	var d: Variant = JSON.parse_string(f.get_as_text())
	_index = d if d is Dictionary else {"type": [], "cast": []}


## Forgets the index and cache (tests, or after the set is re-installed).
static func reset() -> void:
	_index = {}
	_cache = {}
