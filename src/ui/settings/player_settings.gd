class_name PlayerSettings
extends RefCounted
## The player's settings (design/ux/game-menu.md; hud.md Tuning Knobs, Player settings): one set for all saves, kept in
## a ConfigFile (default user://settings.cfg), with defaults and ranges from ui_windows.json "settings". A UI-side
## store: nothing in the world reads it. Values are clamped to their ranges on read and on write.

## A setting changed (after it was stored).
signal changed(key: String, value: Variant)

## The ConfigFile path.
var path: String = "user://settings.cfg"

var _defs: Dictionary = {}       # key -> {default, min?, max?, options?}
var _file := ConfigFile.new()


## [param defs] is ui_windows.json "settings" ({key: {default, min, max, options}}); [param file_path] the store ("" =
## in memory only, nothing read or written).
func _init(defs: Dictionary = {}, file_path: String = "user://settings.cfg") -> void:
	path = file_path
	for k in defs:
		if not str(k).begins_with("_") and defs[k] is Dictionary:
			_defs[str(k)] = defs[k]
	if path != "" and FileAccess.file_exists(path):
		_file.load(path)


## The keys this store knows (the data's order).
func keys() -> Array:
	return _defs.keys()


## The definition of [param key] ({default, min, max, options}).
func def(key: String) -> Dictionary:
	return _defs.get(key, {})


## The value of [param key]: the stored one, else the default; clamped to its range or options.
func value(key: String) -> Variant:
	var d: Dictionary = def(key)
	return _clamp(d, _file.get_value("player", key, d.get("default")))


## True when the player has set [param key] (a value is stored, not only the default).
func is_stored(key: String) -> bool:
	return _file.has_section_key("player", key)


## Stores [param v] for [param key] (clamped) and saves the file. Returns the value stored.
func set_value(key: String, v: Variant) -> Variant:
	var d: Dictionary = def(key)
	if d.is_empty():
		return null
	var c: Variant = _clamp(d, v)
	_file.set_value("player", key, c)
	if path != "":   # "" keeps the settings in memory only (test runs)
		_file.save(path)
	changed.emit(key, c)
	return c


static func _clamp(d: Dictionary, v: Variant) -> Variant:
	var dv: Variant = d.get("default")
	if dv is bool:
		return bool(v) if (v is bool or v is int or v is float) else dv
	if d.has("options"):
		# JSON numbers are floats and Variant equality is typed, so numbers are compared by value
		for o in Array(d.options):
			if (o is float or o is int) and (v is float or v is int) and is_equal_approx(float(o), float(v)):
				return o
			if typeof(o) == typeof(v) and o == v:
				return o
		return dv
	if dv is float or dv is int:
		if not (v is float or v is int):
			return dv
		var x: float = float(v)
		if d.has("min"):
			x = maxf(x, float(d.min))
		if d.has("max"):
			x = minf(x, float(d.max))
		return int(round(x)) if dv is int else x
	return v if typeof(v) == typeof(dv) else dv
