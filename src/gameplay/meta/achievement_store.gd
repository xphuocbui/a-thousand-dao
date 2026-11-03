class_name AchievementStore
extends RefCounted
## Earned thành tựu kept across lives. With an empty path it lives only in memory
## (tests, or a run that should not touch the player's record).
##
## Usage:
## [codeblock]
## var store := AchievementStore.new("user://achievements.json")   # loads if present
## store.earn("truc_co", {"life": "Lâm", "year": 312})
## store.save()
## [/codeblock]

## Path of the JSON file, or "" for memory only.
var path: String = ""
## Achievement id -> {life, year, age}.
var earned: Dictionary = {}


func _init(file_path: String = "") -> void:
	path = file_path
	load_file()


## True if the achievement was earned in any life.
func has(achievement_id: String) -> bool:
	return earned.has(achievement_id)


## Records an achievement (first earning wins).
func earn(achievement_id: String, info: Dictionary) -> void:
	if not earned.has(achievement_id):
		earned[achievement_id] = info


## Loads from [member path] (no-op in memory or when the file is missing).
func load_file() -> void:
	if path == "" or not FileAccess.file_exists(path):
		return
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return
	var d: Variant = JSON.parse_string(f.get_as_text())
	if typeof(d) == TYPE_DICTIONARY:
		earned = d.get("earned", {})


## Writes to [member path]. Returns false on failure (or true in memory).
func save() -> bool:
	if path == "":
		return true
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		return false
	return f.store_string(JSON.stringify({"schema_version": 1, "earned": earned}, "  "))
