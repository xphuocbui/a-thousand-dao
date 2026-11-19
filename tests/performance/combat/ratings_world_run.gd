extends Node
## ADR-0003 step 3's measured run (design/gdd/power-rankings.md AC-PR-51, AC-PR-54, AC-PR-55; Open Questions 7, 8):
## a full generated world with Power Rankings switched on in memory only (the shipped combat_rankings.json stays
## off), simulated season by season for --years years with the real season budget. Reports per season the batch's
## work and time, and per realm at each year's end the spread of bases, where NPCs sit against the realm's typical
## fighter, power numbers and how far realms overlap. With --accuracy it also runs AC-PR-55's check on 50 sampled
## NPCs (warm and coarse panels against a cold one).
##
## Run in the export build (the editor binary's debug build misleads thread timings):
##   build/bench/combat_bench.exe --headless -- --ratings-world --years=4 --accuracy --out=<absolute path.json>
## Prints a summary and "RATINGS_JSON {...}"; writes the JSON to --out when given.

var _report := {"seasons": [], "years": []}


func _ready() -> void:
	var years := 4
	var seed_v := 4242
	var out_path := ""
	var accuracy := false
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--years="):
			years = int(arg.trim_prefix("--years="))
		elif arg.begins_with("--seed="):
			seed_v = int(arg.trim_prefix("--seed="))
		elif arg.begins_with("--out="):
			out_path = arg.trim_prefix("--out=")
		elif arg == "--accuracy":
			accuracy = true
	var gd := GameData.load_from("res://assets/data")
	gd.file("combat_rankings")["enabled"] = true   # in memory only
	var llm := LlmService.new(gd)
	llm.enabled = false
	var s := GameSession.new(gd, llm, DaoDoTree.load_map(gd))
	s.ratings_background = false
	var t0 := Time.get_ticks_usec()
	var made: Dictionary = s.new_game(seed_v, {"mode": "roll", "name": "Đo Lường", "gender": "male", "origin": "tan_tu"})
	_report.worldgen_s = (Time.get_ticks_usec() - t0) / 1e6
	_report.worldgen_lines = made.lines
	_report.cores = OS.get_processor_count()
	_report.people = s.db.count("people")
	print("world generation with ratings: %.1f s; %s" % [_report.worldgen_s, made.lines[-1]])
	_report.years.append(_snapshot(s, "after world generation"))
	var spy: int = int(gd.cultivation_rules().seasons_per_year)
	for i in years * spy:
		var t1 := Time.get_ticks_usec()
		s._pass_season("cultivate")   # finishes the season's batch (planned when it began), ticks, plans the next
		var dt: float = (Time.get_ticks_usec() - t1) / 1e6
		var b: Dictionary = s.last_rating_batch.duplicate()
		b["seconds"] = dt
		b["ms_per_fight"] = 1000.0 * dt / maxf(1.0, float(b.get("panel_fights", 0)) + float(b.get("pair_fights", 0)))
		b["states"] = _states(s)
		_report.seasons.append(b)
		print("season %2d: %4d/%4d panels (%5d fights), %5d/%5d pair fights, %.1f s (%.2f ms a fight); %s" % [i + 1,
			int(b.get("panels", 0)), int(b.get("queued", 0)), int(b.get("panel_fights", 0)), int(b.get("pair_fights", 0)),
			int(b.get("pairs", 0)), dt, b.ms_per_fight, str(b.states)])
		if (i + 1) % spy == 0:
			_report.years.append(_snapshot(s, "after year %d" % ((i + 1) / spy)))
	if accuracy:
		_report.accuracy = _accuracy(s, gd)
		var acc: Dictionary = _report.accuracy
		print("AC-PR-55 on %d sampled NPCs: warm within 1 rung of cold %.0f %%, coarse within 3 rungs %.0f %%" % [int(acc.sampled),
			100.0 * float(acc.warm_within_1_rung), 100.0 * float(acc.coarse_within_3_rungs)])
		for row in acc.rows:
			print("  %s realm %d: cold %.0f, warm off %.2f rungs, coarse off %.2f rungs, fights %s" % [row.id, int(row.realm),
				float(row.cold), float(row.warm_rungs), float(row.coarse_rungs), str(row.fights)])
	_report.log = Array(s.ratings.log_lines.slice(0, 40))
	_report.log_count = s.ratings.log_lines.size()
	for snap in _report.years:
		_print_snapshot(snap)
	var json := JSON.stringify(_report)
	if out_path != "":
		var f := FileAccess.open(out_path, FileAccess.WRITE)   # an absolute path: a relative one lands in the pack
		if f == null:
			push_error("cannot write %s (%s)" % [out_path, error_string(FileAccess.get_open_error())])
		else:
			f.store_string(JSON.stringify(_report, "  "))
			f.close()
	print("RATINGS_JSON " + json)
	get_tree().quit(0)


## Rating states by realm: {realm: {provisional, stale, rated}} for living non-beast NPCs.
func _states(s: GameSession) -> Dictionary:
	var out := {}
	for p in s.db.all("people"):
		if not p.alive or p.get("is_player", false) or p.get("is_beast", false):
			continue
		var r := str(int(p.realm_index))
		if not out.has(r):
			out[r] = {"provisional": 0, "stale": 0, "rated": 0}
		var st: String = str(s.db.get_record(RatingService.TABLE, p.id).get("state", "provisional"))
		out[r][st] = int(out[r].get(st, 0)) + 1
	return out


## Per realm: counts by state; percentiles of base and rating (panel-rated only, and everyone); strength against the
## realm's typical fighter (2^((rating - A_r) / rung gap)); power numbers; overlap with the next realm; AC-PR-54's
## 240-point bin share.
func _snapshot(s: GameSession, label: String) -> Dictionary:
	var lad: RatingLadder = s.ratings.ladder
	var snap := {"label": label, "realms": {}}
	for r in 5:
		var all_r: Array = []
		var rated_r: Array = []
		for p in s.db.all("people"):
			if not p.alive or p.get("is_player", false) or p.get("is_beast", false) or int(p.realm_index) != r:
				continue
			var rec: Dictionary = s.db.get_record(RatingService.TABLE, p.id)
			var rating: float = float(rec.base) + float(rec.offset)
			all_r.append(rating)
			if str(rec.state) != RatingService.PROVISIONAL:
				rated_r.append(float(rec.base))
		all_r.sort()
		rated_r.sort()
		var row := {"npcs": all_r.size(), "panel_rated": rated_r.size()}
		if not rated_r.is_empty():
			row["base_p10_p50_p90"] = [_pct(rated_r, 0.1), _pct(rated_r, 0.5), _pct(rated_r, 0.9)]
			row["base_spread_p10_p90"] = _pct(rated_r, 0.9) - _pct(rated_r, 0.1)
			row["strength_x_typical_p10_p50_p90"] = [_strength(lad, r, _pct(rated_r, 0.1)), _strength(lad, r, _pct(rated_r, 0.5)), _strength(lad, r, _pct(rated_r, 0.9))]
			row["power_p10_p50_p90"] = [lad.power_number(_pct(rated_r, 0.1)), lad.power_number(_pct(rated_r, 0.5)), lad.power_number(_pct(rated_r, 0.9))]
			row["min_max"] = [rated_r[0], rated_r[-1]]
			var bins := {}
			for x in rated_r:
				var k: int = floori(x / 240.0)
				bins[k] = int(bins.get(k, 0)) + 1
			var most := 0
			for k in bins:
				most = maxi(most, int(bins[k]))
			row["largest_240_bin_share"] = float(most) / float(rated_r.size())
		if not all_r.is_empty():
			row["rating_p10_p50_p90_all"] = [_pct(all_r, 0.1), _pct(all_r, 0.5), _pct(all_r, 0.9)]
		row["anchor"] = lad.anchors[r]
		snap.realms[str(r)] = row
	# overlap: share of realm r's panel-rated NPCs above realm r+1's p10 and median
	for r in 4:
		var lo: Dictionary = snap.realms[str(r)]
		var hi: Dictionary = snap.realms[str(r + 1)]
		if lo.has("min_max") and hi.has("base_p10_p50_p90"):
			var above10 := 0
			var above50 := 0
			for p in s.db.all("people"):
				if not p.alive or p.get("is_player", false) or p.get("is_beast", false) or int(p.realm_index) != r:
					continue
				var rec: Dictionary = s.db.get_record(RatingService.TABLE, p.id)
				if str(rec.state) == RatingService.PROVISIONAL:
					continue
				if float(rec.base) > float(hi.base_p10_p50_p90[0]):
					above10 += 1
				if float(rec.base) > float(hi.base_p10_p50_p90[1]):
					above50 += 1
			lo["share_above_next_realm_p10_p50"] = [float(above10) / maxf(1.0, float(lo.panel_rated)), float(above50) / maxf(1.0, float(lo.panel_rated))]
	var pr: Dictionary = s.db.get_record(RatingService.TABLE, s.player.id)
	snap["player"] = {"realm": s.player.realm_index, "stage": s.player.stage, "rating": float(pr.base) + float(pr.offset), "state": str(pr.state),
		"power": lad.power_number(float(pr.base) + float(pr.offset))}
	return snap


## AC-PR-55: 50 sampled panel-rated NPCs across the realms: a cold full panel, then a warm panel from it, and a coarse
## one; how many land within 1 and 3 rungs of the cold base.
func _accuracy(s: GameSession, gd: GameData) -> Dictionary:
	var rs: RatingService = s.ratings
	var pool: Array = s.db.find("people", func(p): return p.alive and not p.get("is_player", false) and not p.get("is_beast", false))
	pool.sort_custom(func(x, y): return RatingService.id_less(x.id, y.id))
	var picks: Array = []
	var step: int = maxi(1, pool.size() / 50)
	for i in range(0, pool.size(), step):
		if picks.size() < 50:
			picks.append(pool[i])
	var warm_ok := 0
	var coarse_ok := 0
	var rows: Array = []
	for p in picks:
		var c := Character.from_dict(p)
		var prof: FighterProfile = FighterCompiler.compile(c, gd, s.db, s.builds.sheet_of(c))
		if prof == null:
			continue
		var r: int = int(p.realm_index)
		var gap: float = (rs.ladder.rung_rating(r, 1) - rs.ladder.rung_rating(r, -1)) / 2.0
		var cold_rec := {"id": "acc_" + str(p.id), "base": 0.0, "offset": 0.0, "n": 0, "state": RatingService.PROVISIONAL, "realm": r, "seeds": {"season": -1, "counts": {}}}
		var cold: Dictionary = rs.panel(prof, r, cold_rec, 999, 1, false)
		var warm_rec := {"id": "acc_" + str(p.id), "base": float(cold.base), "offset": 0.0, "n": 0, "state": RatingService.RATED, "realm": r, "seeds": {"season": -1, "counts": {}}}
		var warm: Dictionary = rs.panel(prof, r, warm_rec, 999, 2, false)
		var coarse_rec := cold_rec.duplicate(true)
		coarse_rec.seeds = {"season": -1, "counts": {}}
		var coarse: Dictionary = rs.panel(prof, r, coarse_rec, 999, 3, true)
		var dw: float = absf(float(warm.base) - float(cold.base)) / gap
		var dc: float = absf(float(coarse.base) - float(cold.base)) / gap
		if dw <= 1.0:
			warm_ok += 1
		if dc <= 3.0:
			coarse_ok += 1
		rows.append({"id": p.id, "realm": r, "cold": cold.base, "warm_rungs": dw, "coarse_rungs": dc, "fights": [cold.fights, warm.fights, coarse.fights]})
	var n: int = rows.size()
	return {"sampled": n, "warm_within_1_rung": float(warm_ok) / maxf(1.0, n), "coarse_within_3_rungs": float(coarse_ok) / maxf(1.0, n), "rows": rows}


func _print_snapshot(snap: Dictionary) -> void:
	print("== %s ==" % snap.label)
	for r in 5:
		var row: Dictionary = snap.realms[str(r)]
		if not row.has("base_p10_p50_p90"):
			print("  realm %d: %d NPCs, none panel-rated" % [r, int(row.npcs)])
			continue
		print("  realm %d: %d NPCs (%d panel-rated); base p10/50/90 %s, spread %.0f; x typical %s; power %s; largest 240-bin %.0f %%%s" % [r,
			int(row.npcs), int(row.panel_rated), _fmt(row.base_p10_p50_p90), float(row.base_spread_p10_p90),
			_fmt(row.strength_x_typical_p10_p50_p90, "%.2f"), str(row.power_p10_p50_p90), 100.0 * float(row.largest_240_bin_share),
			("; above next realm p10/p50 %s" % _fmt(row.share_above_next_realm_p10_p50, "%.2f")) if row.has("share_above_next_realm_p10_p50") else ""])
	print("  player: %s" % str(snap.player))


static func _strength(lad: RatingLadder, r: int, rating: float) -> float:
	return pow(2.0, float(lad.nearest_rung(r, rating)) / float(lad.rung_div))


static func _pct(sorted: Array, q: float) -> float:
	return float(sorted[clampi(int(round(q * (sorted.size() - 1))), 0, sorted.size() - 1)])


static func _fmt(xs: Array, f: String = "%.0f") -> String:
	return "[" + ", ".join(xs.map(func(x): return f % float(x))) + "]"
