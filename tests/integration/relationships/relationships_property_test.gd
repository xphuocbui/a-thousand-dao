extends DaoTestSuite
## NPC Relationships AC-NR-48 (rules 7, 9, a property test): random S8b queues (soft adds and deeds, debts, pinned
## ties, betrayals, ends, repays, deaths with and without known killers) on a 60-person world, seeded. After every
## S8b: each record is indexed from both sides and by its pair key; no stored part has strength 0; no record holds a
## blood feud and soft enmity the same way; no record names a person who is dead or pairs a person with themselves; and
## each death creates at most inherit_feud_max pinned feuds toward any one target. Reports the first failure only.

const N := 60
const SEASONS := 400


func _check(gd: GameData, db: WorldDB, step: int) -> String:
	var seen := {}
	for rec in db.all("ties"):
		var a: String = str(rec.a)
		var b: String = str(rec.b)
		if a == b:
			return "step %d: %s pairs a person with themselves" % [step, rec.id]
		if not bool(db.get_record("people", a).get("alive", false)) or not bool(db.get_record("people", b).get("alive", false)):
			return "step %d: %s names a dead person" % [step, rec.id]
		if not db.ties_of(a).has(rec) or not db.ties_of(b).has(rec) or db.tie_between(a, b) != rec:
			return "step %d: %s is not indexed from both sides" % [step, rec.id]
		var key: String = WorldDB.tie_key(a, b)
		if seen.has(key):
			return "step %d: two records for %s" % [step, key]
		seen[key] = true
		var soft: Dictionary = rec.get("soft", {})
		if not soft.is_empty():
			if str(soft.kind) == "enmity":
				for h in soft.dir:
					if int(soft.dir[h].s) <= 0:
						return "step %d: %s stores enmity at 0" % [step, rec.id]
					if Dictionary(rec.get("feud", {})).has(h):
						return "step %d: %s holds a feud and soft enmity the same way" % [step, rec.id]
			elif int(soft.s) <= 0:
				return "step %d: %s stores a soft kind at 0" % [step, rec.id]
		if not Dictionary(rec.get("debt", {})).is_empty() and int(rec.debt.s) <= 0:
			return "step %d: %s stores a debt at 0" % [step, rec.id]
		if Ties.is_empty_record(rec):
			return "step %d: %s holds nothing" % [step, rec.id]
	return ""


func test_random_s8b_queues_keep_the_store_consistent_ac_nr_48() -> void:
	var gd := game_data()
	var db := WorldDB.new()
	var r := rng(4848)
	var next_id: int = 1
	var alive: Array = []
	for i in N:
		var pid := "p%d" % next_id
		next_id += 1
		db.put("people", {"id": pid, "alive": true, "realm_index": r.randi() % 4, "sect_rank": "truong_lao" if r.randf() < 0.1 else "",
			"born_year": 900 + r.randi() % 100, "location_id": "l%d" % (r.randi() % 3)})
		alive.append(pid)
	var nf: int = int(Ties.cfg(gd).inherit_feud_max)
	for s in SEASONS:
		var season: int = 100 + s
		Ties.set_now(db, season)
		var dead_now: Array = []
		for k in 8:
			var a: String = alive[r.randi() % alive.size()]
			var b: String = alive[r.randi() % alive.size()]
			match r.randi() % 9:
				0, 1:
					TieTick.enqueue(db, {"kind": "soft", "holder": a, "other": b, "sk": ["friend", "rival", "enmity"][r.randi() % 3],
						"delta": r.randi_range(-40, 60), "deed": r.randf() < 0.2})
				2:
					TieTick.enqueue(db, {"kind": "debt", "debtor": a, "creditor": b, "delta": r.randi_range(-30, 60)})
				3:
					TieTick.enqueue(db, {"kind": "pinned", "a": a, "b": b, "pk": ["kin", "su_do", "ket_nghia", "dao_lu"][r.randi() % 4], "authored": true})
				4:
					TieTick.enqueue(db, {"kind": "betrayal", "betrayer": a, "betrayed": b})
				5:
					TieTick.enqueue(db, {"kind": "end", "a": a, "b": b, "reason": "parted"})
				6:
					TieTick.enqueue(db, {"kind": "repay", "debtor": a, "creditor": b})
				7, 8:
					if dead_now.size() < 3 and not dead_now.has(a) and r.randf() < 0.5:
						dead_now.append(a)
						var killer: String = b if r.randf() < 0.6 and b != a else ""
						TieTick.enqueue(db, {"kind": "death", "dead": a, "killer": killer, "known": r.randf() < 0.8, "cause": "kill" if killer != "" else "old_age"})
		for d in dead_now:
			db.get_record("people", d)["alive"] = false
			alive.erase(d)
		var feuds_before := {}
		for rec in db.all("ties"):
			for h in rec.get("feud", {}):
				feuds_before["%s>%s" % [h, Ties._other(rec, str(h))]] = true
		TieTick.run(gd, db, season)
		# per death, per target: at most inherit_feud_max new pinned feuds (several deaths a season: nf each)
		var new_by_target := {}
		for rec in db.all("ties"):
			for h in rec.get("feud", {}):
				var t: String = Ties._other(rec, str(h))
				if not feuds_before.has("%s>%s" % [h, t]) and str(rec.feud[h].get("cause", {}).get("kind", "")) != "":
					new_by_target[t] = int(new_by_target.get(t, 0)) + 1
		for t in new_by_target:
			if int(new_by_target[t]) > nf * maxi(dead_now.size(), 1):
				assert_true(false, "season %d: %d new feuds toward %s" % [season, int(new_by_target[t]), t])
				return
		var err: String = _check(gd, db, s)
		if err != "":
			assert_true(false, err)
			return
		while alive.size() < N:   # newcomers keep the world at N
			var pid := "p%d" % next_id
			next_id += 1
			db.put("people", {"id": pid, "alive": true, "realm_index": 0, "sect_rank": "", "born_year": 1000 + s, "location_id": "l0"})
			alive.append(pid)
	assert_true(db.count("ties") > 0, "the run formed ties (%d at the end)" % db.count("ties"))
