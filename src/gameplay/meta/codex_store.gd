class_name CodexStore
extends RefCounted
## Profile-level persistent JSON store for the Codex (Thiên Thư), shared across all
## playthroughs and never rolled back by loading an older save. Design:
## design/gdd/codex-karmic-carryover.md (Rules 7, 9, 11; Edge Cases; AC-CK-12, 15, 16).
##
## With an empty [member path] (the default), the store lives strictly in memory and
## performs zero external I/O (used by unit tests and scripted runs). When given a path
## such as `"user://codex.json"`, writes are persisted atomically via a temporary file
## and unreadable files are quarantined to a backup with a one-time notice.
##
## Usage:
## [codeblock]
## var store := CodexStore.new("user://codex.json")
## var notice: String = store.take_notice()
## var r: Dictionary = store.promote("recipes", "tu_khi_dan", CodexStore.LEVEL_KNOWN, {"year": 1205, "life": "Lâm"})
## [/codeblock]

const SCHEMA_VERSION := 1
const LEVEL_NONE := ""
const LEVEL_SEEN := "seen"
const LEVEL_KNOWN := "known"

## Path of the JSON file, or "" for pure in-memory storage.
var path: String = ""
## Book id -> {entry_id: {level, first_year, first_life, known_year?, known_life?, fates?}}.
var books: Dictionary = {}
## Chronicle records of ended lives, in chronological order (each carries `playthrough_id`).
var lives: Array = []
## One-time player-facing notice set when a corrupt file is backed up (cleared by [method take_notice]).
var load_notice: String = ""
## Path of the backup file created when a corrupt Codex file was quarantined ("" when none).
var backup_path: String = ""


func _init(file_path: String = "") -> void:
	path = file_path
	load_file()


## Loads from [member path] (no-op in memory or when the file does not exist).
## If the file exists but cannot be opened, parsed, or validated, moves it aside to a
## backup file, resets to an empty Codex, and records one notice (AC-CK-16).
func load_file() -> void:
	books = {}
	lives = []
	load_notice = ""
	backup_path = ""
	if path == "" or not FileAccess.file_exists(path):
		return
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		_quarantine_corrupt("could not be opened")
		return
	var raw: String = f.get_as_text()
	f.close()
	var json := JSON.new()
	if json.parse(raw) != OK:
		_quarantine_corrupt("was unreadable")
		return
	if typeof(json.data) != TYPE_DICTIONARY or not _is_valid_payload(json.data):
		_quarantine_corrupt("had invalid structure")
		return
	var d: Dictionary = json.data
	books = Dictionary(d.get("books", {})).duplicate(true)
	lives = Array(d.get("lives", [])).duplicate(true)


## Writes the Codex atomically to [member path] (write `.tmp`, check [method FileAccess.store_string],
## then replace target). Returns true in memory mode without touching the filesystem.
func save() -> bool:
	if path == "":
		return true
	var abs_dst: String = ProjectSettings.globalize_path(path)
	var parent_dir: String = abs_dst.get_base_dir()
	if parent_dir != "" and not DirAccess.dir_exists_absolute(parent_dir):
		var mk_err: int = DirAccess.make_dir_recursive_absolute(parent_dir)
		if mk_err != OK and not DirAccess.dir_exists_absolute(parent_dir):
			return false
	var payload: String = JSON.stringify({
		"schema_version": SCHEMA_VERSION,
		"books": books,
		"lives": lives,
	}, "  ")
	var tmp_path: String = path + ".tmp"
	var abs_tmp: String = ProjectSettings.globalize_path(tmp_path)
	var f := FileAccess.open(tmp_path, FileAccess.WRITE)
	if f == null:
		return false
	var wrote: bool = f.store_string(payload)
	f.close()
	if not wrote:
		if FileAccess.file_exists(tmp_path):
			DirAccess.remove_absolute(abs_tmp)
		return false
	var err: int = DirAccess.rename_absolute(abs_tmp, abs_dst)
	if err != OK:
		if FileAccess.file_exists(path):
			var rm_err: int = DirAccess.remove_absolute(abs_dst)
			if rm_err == OK:
				err = DirAccess.rename_absolute(abs_tmp, abs_dst)
	if err != OK:
		if FileAccess.file_exists(tmp_path):
			DirAccess.remove_absolute(abs_tmp)
		return false
	return true


## Returns the discovery level of [param entry_id] in [param book]: "", "seen", or "known".
func level_of(book: String, entry_id: String) -> String:
	var rec: Dictionary = Dictionary(books.get(book, {})).get(entry_id, {})
	return str(rec.get("level", LEVEL_NONE))


## Returns a copy of the stored entry record for [param entry_id] in [param book], or {}.
func entry(book: String, entry_id: String) -> Dictionary:
	var rec: Dictionary = Dictionary(books.get(book, {})).get(entry_id, {})
	return rec.duplicate(true)


## Returns a copy of the entry dictionary (`entry_id -> record`) for [param book].
func entries_in(book: String) -> Dictionary:
	return Dictionary(books.get(book, {})).duplicate(true)


## Total number of recorded knowledge entries across all non-Lives books.
func total_entries() -> int:
	var total: int = 0
	for book_id in books:
		if str(book_id) == "lives":
			continue
		if typeof(books[book_id]) == TYPE_DICTIONARY:
			total += Dictionary(books[book_id]).size()
	return total


## Counts entries in [param book]: `{seen, known, total}` (`seen` counts seen-only entries).
func count_book(book: String) -> Dictionary:
	if book == "lives":
		var n: int = lives.size()
		return {"seen": 0, "known": n, "total": n}
	var seen_only: int = 0
	var known_n: int = 0
	for rec in Dictionary(books.get(book, {})).values():
		var lv: String = str(Dictionary(rec).get("level", LEVEL_NONE))
		if lv == LEVEL_KNOWN:
			known_n += 1
		elif lv == LEVEL_SEEN:
			seen_only += 1
	return {"seen": seen_only, "known": known_n, "total": seen_only + known_n}


## Promotes [param entry_id] in [param book] to [param target_level] ("seen" or "known").
## Entries never downgrade (known stays known; seen stays seen or rises to known).
## Persists immediately on change and returns `{changed, newly_known, saved}`.
func promote(book: String, entry_id: String, target_level: String, info: Dictionary = {}) -> Dictionary:
	if book == "" or entry_id == "" or (target_level != LEVEL_SEEN and target_level != LEVEL_KNOWN):
		return {"changed": false, "newly_known": false, "saved": true}
	var cur_level: String = level_of(book, entry_id)
	var cur_rank: int = _level_rank(cur_level)
	var new_rank: int = _level_rank(target_level)
	if new_rank <= cur_rank:
		return {"changed": false, "newly_known": false, "saved": true}
	if not books.has(book) or typeof(books[book]) != TYPE_DICTIONARY:
		books[book] = {}
	var rec: Dictionary = Dictionary(books[book].get(entry_id, {})).duplicate(true)
	rec["level"] = target_level
	if not rec.has("first_year"):
		rec["first_year"] = int(info.get("year", 0))
	if not rec.has("first_life"):
		rec["first_life"] = str(info.get("life", ""))
	if target_level == LEVEL_KNOWN:
		rec["known_year"] = int(info.get("year", 0))
		rec["known_life"] = str(info.get("life", ""))
	books[book][entry_id] = rec
	var saved: bool = save()
	return {
		"changed": true,
		"newly_known": target_level == LEVEL_KNOWN and cur_rank < 2,
		"saved": saved,
	}


## Appends a past-life fate record for a fixed-cast member [param cast_key] and saves.
func add_cast_fate(cast_key: String, fate_entry: Dictionary) -> bool:
	if cast_key == "":
		return false
	if not books.has("cast") or typeof(books["cast"]) != TYPE_DICTIONARY:
		books["cast"] = {}
	var rec: Dictionary = Dictionary(books["cast"].get(cast_key, {})).duplicate(true)
	if str(rec.get("level", LEVEL_NONE)) == LEVEL_NONE:
		rec["level"] = LEVEL_SEEN
		rec["first_year"] = int(fate_entry.get("year", 0))
		rec["first_life"] = str(fate_entry.get("life", ""))
	var fates: Array = Array(rec.get("fates", [])).duplicate(true)
	fates.append(fate_entry.duplicate(true))
	rec["fates"] = fates
	books["cast"][cast_key] = rec
	return save()


## Appends an ended life record to [member lives] and saves immediately.
func add_life(life_rec: Dictionary) -> bool:
	lives.append(life_rec.duplicate(true))
	return save()


## True if any recorded life in [member lives] belongs to [param playthrough_id] (Rule 11).
func has_life_for_playthrough(playthrough_id: String) -> bool:
	if playthrough_id == "":
		return false
	for l in lives:
		if typeof(l) == TYPE_DICTIONARY and str(l.get("playthrough_id", "")) == playthrough_id:
			return true
	return false


## Returns [member load_notice] and clears it so a corruption warning shows only once (AC-CK-16).
func take_notice() -> String:
	var msg: String = load_notice
	load_notice = ""
	return msg


static func _level_rank(lv: String) -> int:
	if lv == LEVEL_KNOWN:
		return 2
	if lv == LEVEL_SEEN:
		return 1
	return 0


static func _is_valid_payload(d: Dictionary) -> bool:
	if d.has("books") and typeof(d["books"]) != TYPE_DICTIONARY:
		return false
	if d.has("lives") and typeof(d["lives"]) != TYPE_ARRAY:
		return false
	if d.has("books"):
		for book_val in Dictionary(d["books"]).values():
			if typeof(book_val) != TYPE_DICTIONARY:
				return false
	return true


func _quarantine_corrupt(reason: String) -> void:
	books = {}
	lives = []
	var abs_src: String = ProjectSettings.globalize_path(path)
	var bak: String = path + ".bak"
	if FileAccess.file_exists(bak):
		var ts: int = int(Time.get_unix_time_from_system())
		var n: int = 0
		bak = "%s.bak.%d" % [path, ts]
		while FileAccess.file_exists(bak):
			n += 1
			bak = "%s.bak.%d.%d" % [path, ts, n]
	var abs_bak: String = ProjectSettings.globalize_path(bak)
	var moved: bool = DirAccess.rename_absolute(abs_src, abs_bak) == OK
	if not moved:
		var rf := FileAccess.open(path, FileAccess.READ)
		var wf := FileAccess.open(bak, FileAccess.WRITE)
		if rf != null and wf != null:
			var bytes: PackedByteArray = rf.get_buffer(rf.get_length())
			rf.close()
			wf.store_buffer(bytes)
			wf.close()
			moved = true
		else:
			if rf != null:
				rf.close()
			if wf != null:
				wf.close()
	backup_path = bak if moved else ""
	if backup_path != "":
		load_notice = "Codex file %s; started with an empty Codex and saved a backup at %s." % [reason, backup_path]
	else:
		load_notice = "Codex file %s; started with an empty Codex." % reason
