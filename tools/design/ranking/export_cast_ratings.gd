extends SceneTree
## Offline Power Rankings precompute exporter for living authored cast + living authored spirit beasts
## (design/gdd/power-rankings.md Core Rule 16a).
##
## Usage:
##   godot --headless --path . -s res://tools/design/ranking/export_cast_ratings.gd -- --workers=8
##   godot --headless --path . -s res://tools/design/ranking/export_cast_ratings.gd -- --check
##   godot --headless --path . -s res://tools/design/ranking/export_cast_ratings.gd -- --check --recompute --workers=8
##   godot --headless --path . -s res://tools/design/ranking/export_cast_ratings.gd -- --probe-seed=101

const OUT_PATH := "res://assets/data/cast_ratings.json"
const SCHEMA_VERSION := 1
const PRECOMPUTE_SEED := 0
const PRECOMPUTE_SEASON := 0
const WORKER_TIMEOUT_S := 900.0
const DOC_TEXT := "Offline precomputed full-panel Power Rankings bases for every living authored cast member and authored spirit beast (design/gdd/power-rankings.md Core Rule 16a). Written by tools/design/ranking/export_cast_ratings.gd; do not edit by hand. Read by RatingService.worldgen()."


func _init() -> void:
	quit(_main(OS.get_cmdline_user_args()))


static func _has_flag(args: PackedStringArray, flag: String) -> bool:
	for a in args:
		if a == flag:
			return true
	return false


static func _arg_val(args: PackedStringArray, prefix: String, dflt: String) -> String:
	for a in args:
		if a.begins_with(prefix + "="):
			return a.trim_prefix(prefix + "=")
	return dflt


static func _main(args: PackedStringArray) -> int:
	var probe_raw: String = _arg_val(args, "--probe-seed", "")
	if probe_raw != "":
		return _run_probe(int(probe_raw))
	var check_mode: bool = _has_flag(args, "--check")
	var recompute: bool = _has_flag(args, "--recompute")
	var workers_raw: String = _arg_val(args, "--workers", "8")
	var workers: int = maxi(0, int(workers_raw))
	if check_mode and not recompute:
		return _run_fast_check()
	return _run_compute(workers, check_mode)


## Builds a minimal WorldDB containing only the deterministic authored cast + authored beasts (0 random cultivators).
static func _build_cast_world(shipped_gd: GameData) -> Dictionary:
	var files_copy: Dictionary = shipped_gd.registry.files().duplicate()
	var wg_copy: Dictionary = shipped_gd.world_gen().duplicate(true)
	wg_copy["people"]["world_cultivators"] = 0
	wg_copy["people"]["world_cultivators_min"] = 0
	files_copy["world_generation"] = wg_copy
	var build_gd := GameData.new()
	build_gd.setup(DataRegistry.from_files(files_copy))
	var tree := DaoDoTree.load_map(build_gd)
	var builder := WorldBuilder.new(build_gd, tree)
	var rng := RandomNumberGenerator.new()
	rng.seed = PRECOMPUTE_SEED
	var db: WorldDB = builder.generate(rng, str(PRECOMPUTE_SEED))
	return {"gd": build_gd, "tree": tree, "db": db, "errors": builder.errors}


## Collects every living authored cast member and living authored beast, verifying zero duplicate cast_keys.
static func _collect_living_cast(db: WorldDB) -> Dictionary:
	var by_key: Dictionary = {}
	var dupes: Array = []
	var cast_count := 0
	var beast_count := 0
	for p in db.all("people"):
		if not bool(p.get("alive", true)) or bool(p.get("is_player", false)):
			continue
		var ck: String = str(p.get("cast_key", ""))
		if ck == "":
			continue
		if by_key.has(ck):
			dupes.append(ck)
			continue
		by_key[ck] = p
		if bool(p.get("is_beast", false)):
			beast_count += 1
		else:
			cast_count += 1
	return {"by_key": by_key, "dupes": dupes, "cast_count": cast_count, "beast_count": beast_count}


static func _run_fast_check() -> int:
	var t0: int = Time.get_ticks_msec()
	var gd := GameData.load_from("res://assets/data")
	var abs_path: String = ProjectSettings.globalize_path(OUT_PATH)
	if not FileAccess.file_exists(abs_path):
		printerr("[FAIL] %s does not exist" % OUT_PATH)
		return 1
	var raw_text: String = FileAccess.get_file_as_string(abs_path)
	var parsed: Variant = JSON.parse_string(raw_text)
	if not (parsed is Dictionary):
		printerr("[FAIL] %s is not a valid JSON object" % OUT_PATH)
		return 1
	var doc: Dictionary = parsed as Dictionary
	var built: Dictionary = _build_cast_world(gd)
	if not (built.errors as PackedStringArray).is_empty():
		printerr("[FAIL] WorldBuilder errors: %s" % "; ".join(built.errors))
		return 1
	var db: WorldDB = built.db
	var rs := RatingService.new(gd, db)
	var hist: Dictionary = gd.file(WorldBuilder.HISTORY_FILE)
	var want_data_ver: String = str(gd.file(RatingLadder.DATA_FILE).get("data_version", ""))
	var want_wdv: int = int(hist.get("world_data_version", 0))
	var want_whv: String = str(hist.get("data_version", ""))
	var want_digest: String = RatingService.cast_asset_digest(gd)
	var errs: Array = []
	if int(doc.get("schema_version", 0)) != SCHEMA_VERSION:
		errs.append("schema_version=%s (want %d)" % [str(doc.get("schema_version")), SCHEMA_VERSION])
	if str(doc.get("data_version", "")) != want_data_ver:
		errs.append("data_version=%s (want %s)" % [str(doc.get("data_version")), want_data_ver])
	if int(doc.get("world_data_version", -1)) != want_wdv:
		errs.append("world_data_version=%s (want %d)" % [str(doc.get("world_data_version")), want_wdv])
	if str(doc.get("world_history_version", "")) != want_whv:
		errs.append("world_history_version=%s (want %s)" % [str(doc.get("world_history_version")), want_whv])
	if str(doc.get("asset_digest", "")) != want_digest:
		errs.append("asset_digest=%s (want %s)" % [str(doc.get("asset_digest")), want_digest])
	var col: Dictionary = _collect_living_cast(db)
	if not (col.dupes as Array).is_empty():
		errs.append("duplicate cast_keys in WorldBuilder: %s" % str(col.dupes))
	var by_key: Dictionary = col.by_key
	var entries_v: Variant = doc.get("entries", {})
	if not (entries_v is Dictionary):
		errs.append("entries missing or not an object")
	else:
		var entries: Dictionary = entries_v as Dictionary
		if int(doc.get("count", -1)) != by_key.size():
			errs.append("count=%s (want %d)" % [str(doc.get("count")), by_key.size()])
		if int(doc.get("cast_count", -1)) != int(col.cast_count):
			errs.append("cast_count=%s (want %d)" % [str(doc.get("cast_count")), int(col.cast_count)])
		if int(doc.get("beast_count", -1)) != int(col.beast_count):
			errs.append("beast_count=%s (want %d)" % [str(doc.get("beast_count")), int(col.beast_count)])
		if entries.size() != by_key.size():
			errs.append("entries.size=%d (want %d)" % [entries.size(), by_key.size()])
		for ck in by_key:
			if not entries.has(ck):
				errs.append("missing entry: %s" % ck)
				continue
			var p: Dictionary = by_key[ck]
			var e: Dictionary = entries[ck]
			var realm: int = clampi(int(p.get("realm_index", 0)), 0, 4)
			if int(e.get("realm", -1)) != realm:
				errs.append("%s: realm=%s (want %d)" % [ck, str(e.get("realm")), realm])
			var sig: String = rs.build_sig(p)
			if str(e.get("sig", "")) != sig:
				errs.append("%s: sig=%s (want %s)" % [ck, str(e.get("sig")), sig])
		for ck in entries:
			if not by_key.has(ck):
				errs.append("extra entry not in living cast/beasts: %s" % ck)
	var wall_s: float = float(Time.get_ticks_msec() - t0) / 1000.0
	if not errs.is_empty():
		printerr("[FAIL] cast_ratings --check found %d mismatch(es) in %.2f s:" % [errs.size(), wall_s])
		for i in mini(errs.size(), 25):
			printerr("  - %s" % errs[i])
		if errs.size() > 25:
			printerr("  ... and %d more" % (errs.size() - 25))
		return 1
	print("[OK] cast_ratings --check passed in %.2f s (%d cast + %d beasts = %d entries; data_version=%s; asset_digest=%s)" % [
		wall_s, int(col.cast_count), int(col.beast_count), by_key.size(), want_data_ver, want_digest])
	return 0


static func _run_compute(workers: int, check_mode: bool) -> int:
	var t0: int = Time.get_ticks_msec()
	var gd := GameData.load_from("res://assets/data")
	var built: Dictionary = _build_cast_world(gd)
	if not (built.errors as PackedStringArray).is_empty():
		printerr("[FAIL] WorldBuilder errors: %s" % "; ".join(built.errors))
		return 1
	var db: WorldDB = built.db
	var tree: DaoDoTree = built.tree
	var bg := BuildGenerator.new(gd, tree, db)
	var rs := RatingService.new(gd, db)
	rs.sheet_fn = bg.sheet_of
	var col: Dictionary = _collect_living_cast(db)
	if not (col.dupes as Array).is_empty():
		printerr("[FAIL] Duplicate cast_keys: %s" % str(col.dupes))
		return 1
	var by_key: Dictionary = col.by_key
	var keys: Array = by_key.keys()
	keys.sort()

	var builds_map: Dictionary = {}
	var sig_map: Dictionary = {}
	var realm_map: Dictionary = {}
	var profile_map: Dictionary = {}
	var compile_errors: Array = []

	for ck in keys:
		var p: Dictionary = by_key[ck]
		var c := Character.from_dict(p)
		var sheet: StatSheet = bg.sheet_of(c)
		var build: Dictionary = FighterCompiler.character_build_file(c, gd, db, sheet)
		var pay: Dictionary = Diagrams.panel_payload(gd, c, sheet)
		if not pay.is_empty():
			build["diagram"] = pay
		var errs: Array = []
		var profile: FighterProfile = FighterCompiler.from_build_file(build, gd, [], errs)
		if profile == null or not errs.is_empty():
			compile_errors.append("%s: %s" % [ck, "; ".join(errs.map(func(x): return str(x)))])
			continue
		builds_map[ck] = build
		sig_map[ck] = rs.build_sig(p)
		realm_map[ck] = clampi(int(p.get("realm_index", 0)), 0, 4)
		profile_map[ck] = profile

	if not compile_errors.is_empty():
		printerr("[FAIL] %d compile error(s):" % compile_errors.size())
		for i in mini(compile_errors.size(), 25):
			printerr("  - %s" % compile_errors[i])
		return 1

	# Dispatch order: realm descending, then cast_key ascending (LPT load balance for workers).
	var dispatch: Array = keys.duplicate()
	dispatch.sort_custom(func(a, b):
		var ra: int = int(realm_map[a])
		var rb: int = int(realm_map[b])
		if ra != rb:
			return ra > rb
		return str(a) < str(b))

	var tasks: Array = []
	for ck in dispatch:
		tasks.append(["p", str(ck), int(realm_map[ck]), false, 0, false, {}, PRECOMPUTE_SEED, PRECOMPUTE_SEASON])

	var panel_results: Dictionary = {}
	var use_workers: int = mini(workers, OS.get_processor_count())
	var got: Array = []
	got.resize(tasks.size())
	if use_workers > 0 and RatingWorkerPool.supported():
		print("Dispatching %d panels (%d cast + %d beasts) across %d worker processes..." % [
			tasks.size(), int(col.cast_count), int(col.beast_count), use_workers])
		var pool := RatingWorkerPool.new(gd, use_workers, WORKER_TIMEOUT_S)
		if pool.begin(builds_map):
			got = pool.run(tasks)
			pool.end()
			if not pool.wave_stats.is_empty():
				var st: Dictionary = pool.wave_stats[0]
				print("Worker wave finished: done=%d failed=%d wall=%.2fs load_max=%.2fs work_max=%.2fs" % [
					pool.last_done, pool.last_failed, float(st.wall_s), float(st.load_s_max), float(st.work_s_max)])
		else:
			printerr("Warning: RatingWorkerPool failed to start; falling back to threads")

	var missing_idx: Array = []
	for i in dispatch.size():
		var r: Variant = got[i]
		if r is Array and (r as Array).size() == 2:
			panel_results[str(dispatch[i])] = r[0]
		else:
			missing_idx.append(i)

	if not missing_idx.is_empty():
		print("Running %d panel(s) via WorkerThreadPool..." % missing_idx.size())
		rs._prebuild(null)
		var out_local: Array = []
		out_local.resize(missing_idx.size())
		var gid: int = WorkerThreadPool.add_group_task(func(j: int) -> void:
			var idx: int = int(missing_idx[j])
			var ck: String = str(dispatch[idx])
			out_local[j] = rs.panel_core(profile_map[ck], int(realm_map[ck]), ck, false, 0, false, {}, PRECOMPUTE_SEED, PRECOMPUTE_SEASON)
		, missing_idx.size(), -1, false, "cast precompute")
		WorkerThreadPool.wait_for_group_task_completion(gid)
		for j in missing_idx.size():
			panel_results[str(dispatch[int(missing_idx[j])])] = out_local[j]

	# Assemble deterministic sorted JSON document.
	var entries: Dictionary = {}
	var total_fights := 0
	var per_realm_bases: Array = [[], [], [], [], []]
	var per_realm_off_top: Array = [0, 0, 0, 0, 0]
	var k_max: int = rs.ladder.k_max
	for ck in keys:
		var res: Dictionary = panel_results[ck]
		var r: int = int(realm_map[ck])
		var base_v: float = RatingService._snap(float(res.base))
		var fights_v: int = int(res.fights)
		total_fights += fights_v
		per_realm_bases[r].append(base_v)
		var clipped: bool = base_v >= rs.ladder.rung_rating(r, k_max)
		for pr in Array(res.get("probes", [])):
			if int(pr[0]) == k_max and float(pr[2]) >= float(pr[1]):
				clipped = true
				break
		if clipped:
			per_realm_off_top[r] = int(per_realm_off_top[r]) + 1
		entries[ck] = {
			"base": base_v,
			"realm": r,
			"sig": str(sig_map[ck]),
			"fights": fights_v,
		}

	var hist: Dictionary = gd.file(WorldBuilder.HISTORY_FILE)
	var doc := {
		"schema_version": SCHEMA_VERSION,
		"_doc": DOC_TEXT,
		"data_version": str(gd.file(RatingLadder.DATA_FILE).get("data_version", "")),
		"world_data_version": int(hist.get("world_data_version", 0)),
		"world_history_version": str(hist.get("data_version", "")),
		"asset_digest": RatingService.cast_asset_digest(gd),
		"precompute_seed": PRECOMPUTE_SEED,
		"count": keys.size(),
		"cast_count": int(col.cast_count),
		"beast_count": int(col.beast_count),
		"entries": entries,
	}
	var out_text: String = JSON.stringify(doc, " ", true) + "\n"
	var abs_path: String = ProjectSettings.globalize_path(OUT_PATH)
	var wall_s: float = float(Time.get_ticks_msec() - t0) / 1000.0

	if check_mode:
		if not FileAccess.file_exists(abs_path):
			printerr("[FAIL] --check --recompute: %s does not exist" % OUT_PATH)
			return 1
		var disk_text: String = FileAccess.get_file_as_string(abs_path)
		if disk_text != out_text:
			printerr("[FAIL] --check --recompute: %s differs from recomputed output (wall=%.2fs)" % [OUT_PATH, wall_s])
			return 1
		print("[OK] --check --recompute byte-identical (%d entries, %d fights, %.2fs)" % [keys.size(), total_fights, wall_s])
		return 0

	var wf := FileAccess.open(abs_path, FileAccess.WRITE)
	if wf == null:
		printerr("[FAIL] Cannot write %s (error %d)" % [abs_path, FileAccess.get_open_error()])
		return 1
	wf.store_string(out_text)
	wf.close()

	print("[OK] Wrote %s (%d cast + %d beasts = %d entries, %d total fights, %.2fs)" % [
		OUT_PATH, int(col.cast_count), int(col.beast_count), keys.size(), total_fights, wall_s])
	for r in 5:
		var bs: Array = per_realm_bases[r]
		bs.sort()
		if bs.is_empty():
			continue
		var med: float = float(bs[bs.size() / 2])
		var cap: float = rs.ladder.rung_rating(r, k_max)
		print("  R%d: n=%d min=%.1f med=%.1f max=%.1f cap=%.1f off_top=%d" % [
			r, bs.size(), float(bs[0]), med, float(bs[-1]), cap, int(per_realm_off_top[r])])
	if entries.has("thoi_khinh_hong") and entries.has("mac_quy_khu"):
		print("  Hoa Than check: thoi_khinh_hong=%.1f vs mac_quy_khu=%.1f" % [
			float(entries["thoi_khinh_hong"].base), float(entries["mac_quy_khu"].base)])
	return 0


static func _run_probe(seed_v: int) -> int:
	var t0: int = Time.get_ticks_msec()
	var gd := GameData.load_from("res://assets/data")
	var llm := LlmService.new(gd)
	llm.enabled = false
	var tree := DaoDoTree.load_map(gd)
	var s := GameSession.new(gd, llm, tree)
	s.ratings_background = false
	var ng: Dictionary = s.new_game(seed_v, {"mode": "roll", "name": "Thăm Dò", "gender": "male", "origin": "tan_tu"})
	var wall_s: float = float(Time.get_ticks_msec() - t0) / 1000.0
	var errs: Array = []
	if not bool(ng.get("ok", false)):
		errs.append("new_game(%d) failed" % seed_v)

	var ladder: RatingLadder = s.ratings.ladder
	var k_max: int = ladder.k_max
	var cast_total := 0
	var cast_rated := 0
	var beast_total := 0
	var beast_rated := 0
	var gen_total := 0
	var gen_stale := 0
	var gen_prov := 0
	var gen_unexpected_rated := 0
	var ht_cast: Dictionary = {}
	var ht_clip := 0
	var na_total := 0
	var na_clip := 0
	var na_min := INF
	var na_max := -INF

	for p in s.db.all("people"):
		if not bool(p.get("alive", true)) or bool(p.get("is_player", false)):
			continue
		var rec: Dictionary = s.db.get_record(RatingService.TABLE, str(p.id))
		var st: String = str(rec.get("state", ""))
		var base_v: float = float(rec.get("base", 0.0))
		var r: int = clampi(int(p.get("realm_index", 0)), 0, 4)
		var ck: String = str(p.get("cast_key", ""))
		if ck != "":
			if bool(p.get("is_beast", false)):
				beast_total += 1
				if st == RatingService.RATED:
					beast_rated += 1
			else:
				cast_total += 1
				if st == RatingService.RATED:
					cast_rated += 1
				if r == 4:
					ht_cast[ck] = base_v
					if base_v >= ladder.rung_rating(4, k_max):
						ht_clip += 1
				elif r == 3:
					na_total += 1
					na_min = minf(na_min, base_v)
					na_max = maxf(na_max, base_v)
					if base_v >= ladder.rung_rating(3, k_max):
						na_clip += 1
		else:
			gen_total += 1
			if st == RatingService.STALE:
				gen_stale += 1
			elif st == RatingService.PROVISIONAL:
				gen_prov += 1
			else:
				gen_unexpected_rated += 1

	var prec: Dictionary = s.db.get_record(RatingService.TABLE, s.player.id)
	if str(prec.get("state", "")) != RatingService.RATED:
		errs.append("player state=%s (want rated)" % str(prec.get("state", "")))
	if cast_total != 1748 or cast_rated != 1748:
		errs.append("authored cast rated=%d/%d (want 1748/1748)" % [cast_rated, cast_total])
	if beast_total != 21 or beast_rated != 21:
		errs.append("authored beasts rated=%d/%d (want 21/21)" % [beast_rated, beast_total])
	if ht_cast.size() != 2 or ht_clip != 0:
		errs.append("Hoa Than cast=%d clip=%d (want 2 cast, 0 clip)" % [ht_cast.size(), ht_clip])
	if not ht_cast.has("thoi_khinh_hong") or not ht_cast.has("mac_quy_khu"):
		errs.append("missing thoi_khinh_hong or mac_quy_khu in Hoa Than cast")
	elif float(ht_cast["thoi_khinh_hong"]) <= float(ht_cast["mac_quy_khu"]):
		errs.append("expected thoi_khinh_hong (%.1f) > mac_quy_khu (%.1f)" % [
			float(ht_cast["thoi_khinh_hong"]), float(ht_cast["mac_quy_khu"])])
	if na_total != 27 or na_clip != 0:
		errs.append("Nguyen Anh cast=%d clip=%d (want 27 cast, 0 clip)" % [na_total, na_clip])
	if gen_total <= 0 or gen_unexpected_rated != 0:
		errs.append("generated NPCs=%d unexpected_rated=%d (want >0 gen, 0 unexpected)" % [gen_total, gen_unexpected_rated])
	if gen_stale <= 0:
		errs.append("expected generated non-cast coarse panels (gen_stale=%d)" % gen_stale)

	var summary_line := ""
	for ln in Array(ng.get("lines", [])):
		if str(ln).begins_with("Power Rankings:"):
			summary_line = str(ln)
	if not summary_line.contains("1769 precomputed cast ratings"):
		errs.append("startup summary missing '1769 precomputed cast ratings': %s" % summary_line)

	s.shutdown()

	print("Probe seed=%d wall=%.2fs" % [seed_v, wall_s])
	print("  Summary: %s" % summary_line)
	print("  Authored cast RATED: %d/%d | Authored beasts RATED: %d/%d (total %d)" % [
		cast_rated, cast_total, beast_rated, beast_total, cast_rated + beast_rated])
	print("  Hoa Than: thoi_khinh_hong=%.1f, mac_quy_khu=%.1f (cap=%.1f, clip=%d/%d)" % [
		float(ht_cast.get("thoi_khinh_hong", 0.0)), float(ht_cast.get("mac_quy_khu", 0.0)),
		ladder.rung_rating(4, k_max), ht_clip, ht_cast.size()])
	print("  Nguyen Anh: min=%.1f max=%.1f (cap=%.1f, clip=%d/%d)" % [
		na_min, na_max, ladder.rung_rating(3, k_max), na_clip, na_total])
	print("  Generated non-cast NPCs: total=%d stale=%d provisional=%d unexpected=%d" % [
		gen_total, gen_stale, gen_prov, gen_unexpected_rated])

	if not errs.is_empty():
		printerr("[FAIL] --probe-seed=%d failed (%d issue(s)):" % [seed_v, errs.size()])
		for e in errs:
			printerr("  - %s" % e)
		return 1
	print("[OK] --probe-seed=%d passed all checks" % seed_v)
	return 0
