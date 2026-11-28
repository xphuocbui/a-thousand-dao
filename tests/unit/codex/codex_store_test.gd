extends DaoTestSuite
## CodexStore unit tests: in-memory isolation, atomic JSON persistence, monotonic
## level promotion, save-rollback independence (AC-CK-15), corruption backup +
## single notice (AC-CK-16), and playthrough death lookup (Rule 11).

var _tmp_dir: String = ""
var _seq: int = 0


func before_test() -> void:
	_seq += 1
	_tmp_dir = "user://codex_unit_tmp_%d_%d" % [OS.get_process_id(), _seq]
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(_tmp_dir))


func after_test() -> void:
	if _tmp_dir == "":
		return
	var abs_dir: String = ProjectSettings.globalize_path(_tmp_dir)
	if DirAccess.dir_exists_absolute(abs_dir):
		for f in DirAccess.get_files_at(abs_dir):
			DirAccess.remove_absolute(abs_dir.path_join(f))
		DirAccess.remove_absolute(abs_dir)
	_tmp_dir = ""


func _tmp_file(name: String) -> String:
	return _tmp_dir.path_join(name)


func test_default_store_is_in_memory_without_disk_io() -> void:
	var store := CodexStore.new()
	assert_eq(store.path, "", "default path is empty (pure in-memory)")
	var r: Dictionary = store.promote("recipes", "tu_khi_dan", CodexStore.LEVEL_KNOWN, {"year": 1201, "life": "Lâm"})
	assert_true(bool(r.changed), "promoted")
	assert_true(bool(r.newly_known), "newly known")
	assert_true(bool(r.saved), "in-memory save returns true")
	assert_eq(store.level_of("recipes", "tu_khi_dan"), CodexStore.LEVEL_KNOWN, "stored in memory")
	assert_eq(store.take_notice(), "", "no notice in memory mode")


func test_promotion_is_monotonic_and_never_downgrades() -> void:
	var store := CodexStore.new()
	var r1: Dictionary = store.promote("recipes", "tu_khi_dan", CodexStore.LEVEL_SEEN, {"year": 1201, "life": "A"})
	assert_true(bool(r1.changed), "none -> seen changes")
	assert_false(bool(r1.newly_known), "seen is not newly_known")
	assert_eq(store.level_of("recipes", "tu_khi_dan"), CodexStore.LEVEL_SEEN, "level is seen")

	var r2: Dictionary = store.promote("recipes", "tu_khi_dan", CodexStore.LEVEL_SEEN, {"year": 1202, "life": "A"})
	assert_false(bool(r2.changed), "seen -> seen is no-op")
	assert_false(bool(r2.newly_known), "still not newly_known")

	var r3: Dictionary = store.promote("recipes", "tu_khi_dan", CodexStore.LEVEL_KNOWN, {"year": 1203, "life": "A"})
	assert_true(bool(r3.changed), "seen -> known changes")
	assert_true(bool(r3.newly_known), "first time known returns newly_known")
	assert_eq(store.level_of("recipes", "tu_khi_dan"), CodexStore.LEVEL_KNOWN, "level is known")

	var r4: Dictionary = store.promote("recipes", "tu_khi_dan", CodexStore.LEVEL_SEEN, {"year": 1204, "life": "B"})
	assert_false(bool(r4.changed), "known never downgrades to seen")
	assert_eq(store.level_of("recipes", "tu_khi_dan"), CodexStore.LEVEL_KNOWN, "remains known")

	var r5: Dictionary = store.promote("recipes", "tu_khi_dan", CodexStore.LEVEL_KNOWN, {"year": 1205, "life": "B"})
	assert_false(bool(r5.changed), "known -> known is no-op")
	assert_false(bool(r5.newly_known), "second known does not recount")


func test_atomic_persistence_round_trip_and_overwrite() -> void:
	var path: String = _tmp_file("codex.json")
	var store := CodexStore.new(path)
	store.promote("recipes", "tu_khi_dan", CodexStore.LEVEL_SEEN, {"year": 1200, "life": "Lâm"})
	store.promote("recipes", "tu_khi_dan", CodexStore.LEVEL_KNOWN, {"year": 1201, "life": "Lâm"})
	store.add_cast_fate("doan_ngoc_hanh", {"year": 1202, "life": "Lâm", "fate": "Met at Thiên Xu"})
	store.add_life({"playthrough_id": "pt_1", "mode": "one_life", "name": "Lâm", "cause": "Old age"})

	assert_true(FileAccess.file_exists(path), "codex file written")
	assert_false(FileAccess.file_exists(path + ".tmp"), "atomic tmp file cleaned up")

	var reloaded := CodexStore.new(path)
	assert_eq(reloaded.level_of("recipes", "tu_khi_dan"), CodexStore.LEVEL_KNOWN, "known entry persisted")
	assert_eq(reloaded.level_of("cast", "doan_ngoc_hanh"), CodexStore.LEVEL_SEEN, "cast entry persisted")
	assert_eq(Array(reloaded.entry("cast", "doan_ngoc_hanh").get("fates", [])).size(), 1, "cast fate persisted")
	assert_eq(reloaded.lives.size(), 1, "lives entry persisted")
	assert_true(reloaded.has_life_for_playthrough("pt_1"), "playthrough id indexed")
	assert_false(reloaded.has_life_for_playthrough("pt_other"), "unrelated playthrough id absent")
	assert_eq(reloaded.take_notice(), "", "clean reload produces no notice")


func test_ac_ck_15_codex_survives_loading_older_save_snapshot() -> void:
	var path: String = _tmp_file("codex_ac15.json")
	var store := CodexStore.new(path)
	# Write 7 entries before making a save snapshot.
	for i in 7:
		store.promote("herbs", "herb_%d" % i, CodexStore.LEVEL_KNOWN, {"year": 1200 + i, "life": "Lâm"})
	assert_eq(store.total_entries(), 7, "7 entries at save time")
	var save_snapshot := {"year": 1206, "k_new_this_life": 7}

	# Write 3 more entries after the save.
	for j in 3:
		store.promote("recipes", "recipe_%d" % j, CodexStore.LEVEL_KNOWN, {"year": 1207 + j, "life": "Lâm"})
	assert_eq(store.total_entries(), 10, "10 entries after post-save discoveries")

	# Simulate loading the earlier save (Codex loads from profile path, never rolled back).
	var after_load := CodexStore.new(path)
	assert_eq(int(save_snapshot.k_new_this_life), 7, "save counter stays at saved value")
	assert_eq(after_load.total_entries(), 10, "AC-CK-15: Codex still holds all 10 entries after loading earlier save")


func test_ac_ck_16_corrupt_json_starts_empty_backs_up_and_notices_once() -> void:
	var path: String = _tmp_file("codex_corrupt.json")
	var bad_bytes := "{not valid json!!!"
	var f := FileAccess.open(path, FileAccess.WRITE)
	assert_true(f != null, "opened fixture file")
	f.store_string(bad_bytes)
	f.close()

	var store := CodexStore.new(path)
	assert_eq(store.total_entries(), 0, "AC-CK-16: starts with empty Codex books")
	assert_eq(store.lives.size(), 0, "AC-CK-16: starts with empty Lives")
	assert_true(store.backup_path != "", "AC-CK-16: backup path recorded")
	assert_true(FileAccess.file_exists(store.backup_path), "AC-CK-16: backup file exists on disk")

	var bf := FileAccess.open(store.backup_path, FileAccess.READ)
	assert_true(bf != null, "backup readable")
	assert_eq(bf.get_as_text(), bad_bytes, "backup preserves original corrupt contents")
	bf.close()

	var first_notice: String = store.take_notice()
	assert_true(first_notice != "", "AC-CK-16: emits one notice")
	assert_eq(store.take_notice(), "", "AC-CK-16: notice only shown once")

	# Subsequent writes succeed cleanly on top of the recovered store.
	var r: Dictionary = store.promote("recipes", "tu_khi_dan", CodexStore.LEVEL_KNOWN, {"year": 1200, "life": "Lâm"})
	assert_true(bool(r.saved), "new entries save cleanly after recovery")


func test_ac_ck_16_invalid_schema_json_also_quarantined() -> void:
	var path: String = _tmp_file("codex_bad_schema.json")
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_string("[1, 2, 3]")
	f.close()

	var store := CodexStore.new(path)
	assert_eq(store.total_entries(), 0, "non-object JSON resets to empty Codex")
	assert_true(store.backup_path != "" and FileAccess.file_exists(store.backup_path), "bad schema file backed up")
	assert_true(store.take_notice() != "", "notice emitted once for bad schema")
	assert_eq(store.take_notice(), "", "notice cleared after read")
