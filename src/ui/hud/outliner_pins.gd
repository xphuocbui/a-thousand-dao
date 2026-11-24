class_name OutlinerPins
extends RefCounted
## The outliner's pinned people (design/ux/outliner.md). During play they live UI-side per world and player in a
## ConfigFile at [member path] ("" keeps them in memory only: test runs); a save carries them in its frontend block
## (ADR-0007, user decision 2026-11-24 "Save them"): [method to_save] when writing, [method from_save] when loading.

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


## The save file's frontend block for [param world_key] (ADR-0007): {"outliner_pins": [ids, oldest first]}.
func to_save(world_key: String) -> Dictionary:
	return {"outliner_pins": pins(world_key).duplicate()}   # a copy: the live list changes with every pin


## Restores the pins of [param world_key] from a save's frontend [param block] (ADR-0007). A save without the block
## (made before 2026-11-24) leaves the pins as they are; the list is capped at [member max_pins]. Returns true when the
## block carried pins.
func from_save(world_key: String, block: Variant) -> bool:
	if not (block is Dictionary) or not (block as Dictionary).has("outliner_pins"):
		return false
	var l: Array = []
	for id in Array(block.outliner_pins):
		if not l.has(str(id)) and l.size() < max_pins:
			l.append(str(id))
	_store(world_key, l)
	return true


func _store(world_key: String, l: Array) -> void:
	_file.set_value("pins", world_key, l)
	if path != "":
		_file.save(path)
