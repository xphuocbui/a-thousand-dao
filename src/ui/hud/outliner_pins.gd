class_name OutlinerPins
extends RefCounted
## The outliner's pinned people (design/ux/outliner.md), kept UI-side per world and player until the save format
## carries them (hud.md Open Questions: "outliner pins saved with the game"). A ConfigFile at [member path]; "" keeps
## them in memory only (test runs).

## The ConfigFile path ("" = memory only).
var path: String = "user://outliner_pins.cfg"
## The most people that can be pinned (ui_windows.json outliner_pins_max).
var max_pins: int = 12

var _file := ConfigFile.new()


func _init(file_path: String = "user://outliner_pins.cfg", pins_max: int = 12) -> void:
	path = file_path
	max_pins = pins_max
	if path != "" and FileAccess.file_exists(path):
		_file.load(path)


## The pinned ids for world [param world_key] ("<seed>:<player id>"), oldest first.
func pins(world_key: String) -> Array:
	return Array(_file.get_value("pins", world_key, []))


## True when [param id] is pinned in [param world_key].
func has(world_key: String, id: String) -> bool:
	return pins(world_key).has(id)


## Pins [param id]; returns false when the outliner is full or it was already pinned.
func pin(world_key: String, id: String) -> bool:
	var l: Array = pins(world_key)
	if l.has(id) or l.size() >= max_pins:
		return false
	l.append(id)
	_store(world_key, l)
	return true


## Unpins [param id].
func unpin(world_key: String, id: String) -> void:
	var l: Array = pins(world_key)
	l.erase(id)
	_store(world_key, l)


func _store(world_key: String, l: Array) -> void:
	_file.set_value("pins", world_key, l)
	if path != "":
		_file.save(path)
