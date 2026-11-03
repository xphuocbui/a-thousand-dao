class_name SaveStore
extends RefCounted
## Reads and writes JSON documents under a root directory (default user://saves).
##
## Usage:
## [codeblock]
## var store := SaveStore.new("user://saves")
## store.write("slot1", {"hello": 1})
## var doc: Variant = store.read("slot1")
## [/codeblock]

## Directory that holds the save files.
var root: String = "user://saves"


func _init(root_dir: String = "user://saves") -> void:
	root = root_dir


## Writes [param data] as JSON to `<root>/<slot>.json`. Returns OK or an error code.
func write(slot: String, data: Variant) -> int:
	var err: int = DirAccess.make_dir_recursive_absolute(root)
	if err != OK and not DirAccess.dir_exists_absolute(root):
		return err
	var file := FileAccess.open(_path(slot), FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	if not file.store_string(JSON.stringify(data, "", false, true)):
		return ERR_FILE_CANT_WRITE
	return OK


## Reads `<root>/<slot>.json`. Returns null if missing or invalid.
func read(slot: String) -> Variant:
	var path: String = _path(slot)
	if not FileAccess.file_exists(path):
		return null
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return null
	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		return null
	return json.data


## Lists slot names that exist under the root directory.
func list_slots() -> PackedStringArray:
	var out := PackedStringArray()
	if not DirAccess.dir_exists_absolute(root):
		return out
	for f in DirAccess.get_files_at(root):
		if f.ends_with(".json"):
			out.append(f.get_basename())
	return out


## Absolute (globalized) path of a slot, for display.
func describe_path(slot: String) -> String:
	return ProjectSettings.globalize_path(_path(slot))


func _path(slot: String) -> String:
	return root.path_join(slot.validate_filename() + ".json")
