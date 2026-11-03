class_name DataRegistry
extends RefCounted
## Loads every JSON data file in a directory and serves them by file name.
##
## Data files follow the `[system]_[name].json` convention (see docs/data-schemas.md).
## Godot's JSON parser returns every number as float; callers convert to int where needed.
##
## Usage:
## [codeblock]
## var registry := DataRegistry.new()
## if not registry.load_dir("res://assets/data"):
##     push_error("\n".join(registry.errors))
## var realms: Array = registry.get_file("cultivation_realms")["realms"]
## [/codeblock]

## Human-readable load errors, empty when everything loaded.
var errors: PackedStringArray = PackedStringArray()

var _files: Dictionary = {}


## Loads all `*.json` files in [param dir_path]. Returns false if any file failed.
func load_dir(dir_path: String) -> bool:
	errors.clear()
	var names: PackedStringArray = DirAccess.get_files_at(dir_path)
	if names.is_empty():
		errors.append("No files found in %s" % dir_path)
		return false
	for file_name in names:
		if not file_name.ends_with(".json"):
			continue
		var path: String = dir_path.path_join(file_name)
		var parsed: Variant = load_json_file(path)
		if parsed == null:
			continue
		if typeof(parsed) != TYPE_DICTIONARY:
			errors.append("%s: top level must be an object" % path)
			continue
		_files[file_name.get_basename()] = parsed
	return errors.is_empty()


## Registers an already-parsed data file. Used by tests to inject fixtures.
func set_file(file_id: String, content: Dictionary) -> void:
	_files[file_id] = content


## Returns true if a data file with this id (file name without extension) is loaded.
func has_file(file_id: String) -> bool:
	return _files.has(file_id)


## Returns the parsed content of a data file, or an empty Dictionary if missing.
func get_file(file_id: String) -> Dictionary:
	if not _files.has(file_id):
		push_warning("DataRegistry: missing data file '%s'" % file_id)
		return {}
	return _files[file_id]


## Parses one JSON file. Returns null and records an error on failure.
func load_json_file(path: String) -> Variant:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		errors.append("%s: cannot open (error %d)" % [path, FileAccess.get_open_error()])
		return null
	var json := JSON.new()
	var err: int = json.parse(file.get_as_text())
	if err != OK:
		errors.append("%s:%d: %s" % [path, json.get_error_line(), json.get_error_message()])
		return null
	return json.data
