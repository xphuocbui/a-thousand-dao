extends DaoTestSuite
## Wave 2 W2A unit tests for Event Engine (#23) runtime & NPC step:
## Covers AC-EV-03, 06, 07, 09, 11, 12, 13, 16, 17, 18, 19, 20, 27, 28, 31, 32, 34, 36, 39, 43, 44.

const _EventStore = preload("res://src/gameplay/events/event_store.gd")
const _EventBudget = preload("res://src/gameplay/events/event_budget.gd")
const _EventEngine = preload("res://src/gameplay/events/event_engine.gd")


func _mini_world(seed_v: int = 1001) -> Dictionary:
	var gd := GameData.load_from("res://assets/data")
	var db := WorldDB.new()
	var reg_id: String = db.add("regions", {"name": "Thanh Châu", "continent_id": 1, "places": []})
	var p1_id: String = db.add("places", {"name": "Thanh Sơn", "type": "son", "kind": "peak", "region_id": reg_id, "danger": 2, "density": 1.0, "links": [], "qi": {"density": 1.0, "shares": {}}})
	var p2_id: String = db.add("places", {"name": "Bình Trấn", "type": "tran", "kind": "town", "region_id": reg_id, "danger": 1, "density": 1.0, "links": [], "qi": {"density": 1.0, "shares": {}}})
	var s1_id: String = db.add("sects", {"name": "Thanh Vân Tông", "key": "thanh_van", "kind": "great", "status": "active", "alignment": "chinh", "hq_place_id": p1_id, "region_id": reg_id, "members": [], "treasury": 5000, "loyalty": 60.0, "attitude": {}})
	var s2_id: String = db.add("sects", {"name": "Hắc Sa Môn", "key": "hac_sa", "kind": "minor", "status": "active", "alignment": "ma", "hq_place_id": p2_id, "region_id": reg_id, "members": [], "treasury": 1000, "loyalty": 50.0, "attitude": {}})
	var builds := BuildGenerator.new(gd, TestFixtures.tree(), db)
	var items := ItemFactory.new(gd)
	var c := Character.new()
	c.id = db.add("people", {"name": "Lâm Phong", "alive": true, "is_player": true, "realm_index": 0, "stage": 0, "location_id": p1_id, "sect_id": s1_id, "sect_rank": "ngoai_mon", "age": 18.0, "linh_thach": 200, "thien_phu": {"ngo_tinh": 60, "can_cot": 50, "than_hon": 50, "khi_van": 50, "dao_tam": 50, "mi_luc": 50}})
	c.name = "Lâm Phong"
	c.realm_index = 0
	c.stage = 0
	c.level = int(Ladder.band(gd, 0)[0])
	c.location_id = p1_id
	c.sect_id = s1_id
	c.sect_rank = "ngoai_mon"
	c.linh_thach = 200
	c.vitality = 1.0
	c.thien_phu = {"ngo_tinh": 60, "can_cot": 50, "than_hon": 50, "khi_van": 50, "dao_tam": 50, "mi_luc": 50}
	c.linh_can = LinhCan.new()
	c.linh_can.elements = {"kim": 60.0}
	db.put("people", c.to_dict())
	db.get_record("people", c.id)["is_player"] = true
	var sheet := StatSheet.build(c, gd, db, null)
	var eng := _EventEngine.new(gd, db, builds)
	return {"gd": gd, "db": db, "builds": builds, "items": items, "c": c, "sheet": sheet, "eng": eng, "p1": p1_id, "p2": p2_id, "s1": s1_id, "s2": s2_id, "rng": rng(seed_v)}


# --- AC-EV-03: followup_only never fires from pulse ----------------------------------------------

func test_followup_only_never_fires_from_1000_pulses_ac_ev_03() -> void:
	var w: Dictionary = _mini_world(2303)
	var gd: GameData = w.gd
	var eng: _EventEngine = w.eng
	var c: Character = w.c
	var sheet: StatSheet = w.sheet
	var hooks_doc: Dictionary = gd.file("events_hooks")
	hooks_doc.templates.append({
		"id": "ev_fu_only_heavy_test",
		"kind": "followup_only",
		"weight": 100.0,
		"cooldown_seasons": 0,
		"place_kinds": ["any"],
		"title": "Chỉ kích từ hậu quả",
		"text": "Không bao giờ nổ từ pulse.",
		"log": "{root} gặp hậu quả.",
		"choices": [
			{"label": "A", "check": {"type": "none"}, "always": [], "success": {"text": "A.", "effects": []}},
			{"label": "B", "check": {"type": "none"}, "always": [], "success": {"text": "B.", "effects": []}},
		],
	})
	var r: RandomNumberGenerator = w.rng
	for i in 1000:
		var res: Dictionary = eng.roll_pulse(c, sheet, r, "explore", 1.0, {"year": 1200 + i, "season": 0, "check_cap20": false})
		if bool(res.get("ok", false)):
			assert_true(str(res.event.template_id) != "ev_fu_only_heavy_test", "AC-EV-03: followup_only must never fire from pulse")


# --- AC-EV-06 & AC-EV-07: Formulas A pulse chance & closed_door skip -----------------------------

func test_pulse_chance_formulas_a_and_closed_door_skip_ac_ev_06_ac_ev_07() -> void:
	var w: Dictionary = _mini_world(2306)
	var gd: GameData = w.gd
	var c: Character = w.c
	var eng: _EventEngine = w.eng
	var sheet: StatSheet = w.sheet

	var p_d2 := {"danger": 2}
	assert_near(eng.pulse_chance(c, sheet, p_d2, 0.0, false, 0), 0.24, 1e-6, "AC-EV-06: danger 2 cultivating = 0.24")
	assert_near(eng.pulse_chance(c, sheet, p_d2, 0.55, false, 0), 0.79, 1e-6, "AC-EV-06: danger 2 exploring = 0.79")

	# Danger 1, exploring, at bottleneck with edge, co_duyen_left=1, cd_pct=100 -> raw 1.23 clamped to 1.0
	c.stage = gd.stage_count(c.realm_index) - 1
	c.level = int(Ladder.band(gd, c.realm_index)[1])
	c.tu_vi = Ladder.bar_cost(gd, c.realm_index)
	assert_true(CultivationRules.at_bottleneck(c, gd), "precondition: character at bottleneck")
	var sheet_cd := StatSheet.build(c, gd, w.db, null)
	sheet_cd.add_mod("Thiên Mệnh", "co_duyen_pct", 100.0)
	var p_d1 := {"danger": 1}
	assert_near(eng.pulse_chance(c, sheet_cd, p_d1, 0.55, true, 1), 1.0, 1e-6, "AC-EV-06: danger 1 explore bottleneck+edge+cd100 = 1.0")

	# AC-EV-07: closed_door rolls zero pulse and does not advance RNG state
	var r: RandomNumberGenerator = w.rng
	var state_before: int = r.state
	var cd_res: Dictionary = eng.roll_pulse(c, sheet, r, "closed_door", 0.55, {"year": 1200, "season": 0})
	assert_false(bool(cd_res.rolled), "AC-EV-07: closed_door never rolls pulse")
	assert_eq(str(cd_res.get("skipped", "")), "closed_door")
	assert_eq(r.state, state_before, "AC-EV-07: RNG state untouched in closed_door")


# --- AC-EV-09: Hook chance 1.0 fires exactly 1 event ---------------------------------------------

func test_hook_chance_one_fires_exactly_one_event_ac_ev_09() -> void:
	var w: Dictionary = _mini_world(2309)
	var gd: GameData = w.gd
	var eng: _EventEngine = w.eng
	var hooks_doc: Dictionary = gd.file("events_hooks")
	for tid in ["ev_h09_a", "ev_h09_b"]:
		hooks_doc.templates.append({
			"id": tid, "kind": "hook", "hook": "on_discover", "weight": 10.0, "place_kinds": ["any"],
			"title": "Khám phá %s" % tid, "text": "Nội dung %s." % tid, "log": "{root} khám phá %s." % tid,
			"choices": [
				{"label": "Xem", "check": {"type": "none"}, "always": [], "success": {"text": "Xong.", "effects": []}},
				{"label": "Rời đi", "check": {"type": "none"}, "always": [], "success": {"text": "Đi.", "effects": []}},
			],
		})
	var res: Dictionary = eng.raise_hook("on_discover", w.c, w.sheet, w.rng, {"year": 1200, "season": 1, "chance_override": 1.0})
	assert_true(bool(res.ok) and bool(res.get("fired", false)), "AC-EV-09: hook fired")
	assert_false(Dictionary(res.event).is_empty(), "AC-EV-09: returned 1 event")
	assert_eq(_EventStore.season_events_count(w.db, 1200 * 4 + 1), 1, "AC-EV-09: exactly 1 event fired for hook occurrence")


# --- AC-EV-11: Determinism (player stream replay & NPC keyed order-invariance) -------------------

func test_determinism_player_replay_and_npc_order_invariance_ac_ev_11() -> void:
	var run_player := func() -> Array:
		var w: Dictionary = _mini_world(2311)
		var out: Array = []
		for i in 6:
			var r: Dictionary = w.eng.roll_pulse(w.c, w.sheet, w.rng, "explore", 0.55, {"year": 1200 + i, "season": 0, "check_cap20": false})
			out.append(str(Dictionary(r.get("event", {})).get("template_id", "")))
		return out
	assert_eq(run_player.call(), run_player.call(), "AC-EV-11: same seed + same player actions produce identical events")

	# NPC order invariance: insert NPCs in forward vs reverse order; keyed streams yield identical choices & outcomes.
	var run_npc := func(reverse_insert: bool) -> Dictionary:
		var w: Dictionary = _mini_world(2311)
		var ids: Array = ["p_npc_a", "p_npc_b", "p_npc_c", "p_npc_d", "p_npc_e"]
		if reverse_insert:
			ids.reverse()
		for pid in ids:
			w.db.put("people", {
				"id": pid, "name": pid, "alive": true, "realm_index": 0, "stage": 0,
				"location_id": w.p1, "sect_id": w.s1, "linh_thach": 100.0, "cast_key": "cast_" + pid,
				"thien_phu": {"ngo_tinh": 50, "can_cot": 50, "than_hon": 50, "khi_van": 50, "dao_tam": 50, "mi_luc": 50},
				"npc_traits": {"personality": ["wrathful", "bold", "greedy"], "calling": "wanderer", "fate": [], "gained": []},
			})
		w.gd.budgets()["npc_events"]["p_npc0"] = 1.0
		w.eng.run_npc_season(w.rng, 1205, 1, 7777, w.c.id)
		var by_pid := {}
		for ev in w.db.all("events"):
			if str(ev.type) == "npc_event":
				var who: String = str(ev.people[0])
				by_pid[who] = [str(ev.data.template_id), int(ev.data.choice_index), bool(ev.data.success)]
		return by_pid
	var fwd: Dictionary = run_npc.call(false)
	var rev: Dictionary = run_npc.call(true)
	assert_false(fwd.is_empty(), "NPC events fired")
	assert_eq(fwd, rev, "AC-EV-11: NPC tick produces identical events & choices regardless of DB insertion order")


# --- AC-EV-12: Priority queue order (followup -> hook -> pulse dropped at cap 2) -----------------

func test_priority_queue_orders_followup_hook_and_drops_pulse_ac_ev_12() -> void:
	var w: Dictionary = _mini_world(2312)
	var eng: _EventEngine = w.eng
	var y: int = 1201
	var s: int = 0
	var now_s: int = y * 4 + s
	# Register a follow-up due this season
	_EventStore.add_followup(w.db, {
		"event_id": "ev_fu_debt_collector_arrives", "root_id": w.c.id,
		"scheduled_at": now_s - 2, "due_season": now_s, "wait_seasons": 4,
		"hook": "", "scopes": {"other": w.builds.create_person(w.rng, {"realm_index": 0, "location_id": w.p1})},
	})
	# Put engine in busy state so hook and pulse enqueue cleanly alongside follow-up
	eng.busy = true
	eng.on_season_start(w.c, w.sheet, w.rng, y, s)
	eng.raise_hook("on_discover", w.c, w.sheet, w.rng, {"year": y, "season": s, "chance_override": 1.0})
	eng.roll_pulse(w.c, w.sheet, w.rng, "explore", 1.0, {"year": y, "season": s, "check_cap20": false})
	eng.busy = false

	var first: Dictionary = eng.drain_queue(w.c, w.sheet, w.rng, y, s)
	var second: Dictionary = eng.drain_queue(w.c, w.sheet, w.rng, y, s)
	var third: Dictionary = eng.drain_queue(w.c, w.sheet, w.rng, y, s)
	assert_eq(str(first.get("template_id", "")), "ev_fu_debt_collector_arrives", "AC-EV-12: follow-up fires 1st")
	assert_eq(str(second.get("hook", "")), "on_discover", "AC-EV-12: hook fires 2nd")
	assert_true(third.is_empty(), "AC-EV-12: pulse dropped once season cap (2) is reached")
	assert_eq(_EventStore.get_queue(w.db), [], "queue cleared once cap reached")


# --- AC-EV-13: Cooldown 8, once_per_life, once_per_world -----------------------------------------

func test_cooldown_once_per_life_and_once_per_world_ac_ev_13() -> void:
	var w: Dictionary = _mini_world(2313)
	var ev_cd := {"id": "ev_cd_13", "cooldown_seasons": 8}
	_EventStore.mark_fired(w.db, "ev_cd_13", "p_root_1", 100, false, false)
	for offset in range(1, 8):
		assert_false(_EventStore.can_fire_pacing(w.db, w.gd, ev_cd, "p_root_1", 100 + offset, false), "AC-EV-13: ineligible at t+%d" % offset)
	assert_true(_EventStore.can_fire_pacing(w.db, w.gd, ev_cd, "p_root_1", 108, false), "AC-EV-13: eligible at t+8")

	var ev_life := {"id": "ev_life_13", "once_per_life": true, "cooldown_seasons": 0}
	_EventStore.mark_fired(w.db, "ev_life_13", "p_root_1", 100, true, false)
	assert_false(_EventStore.can_fire_pacing(w.db, w.gd, ev_life, "p_root_1", 500, false), "AC-EV-13: once_per_life never fires twice for same root")
	assert_true(_EventStore.can_fire_pacing(w.db, w.gd, ev_life, "p_root_2", 500, false), "once_per_life allowed for another root")

	var ev_world := {"id": "ev_world_13", "once_per_world": true, "cooldown_seasons": 0}
	_EventStore.mark_fired(w.db, "ev_world_13", "p_root_1", 100, false, true)
	assert_false(_EventStore.can_fire_pacing(w.db, w.gd, ev_world, "p_root_2", 500, false), "AC-EV-13: once_per_world never fires twice in world")


# --- AC-EV-16 & AC-EV-17: Follow-up delay/wait/drop & hook-keyed place trigger -------------------

func test_followup_delay_waiting_expiry_and_hook_place_keying_ac_ev_16_ac_ev_17() -> void:
	var w: Dictionary = _mini_world(2316)
	var eng: _EventEngine = w.eng
	# Add a gated follow-up template requiring flag "ready_fu"
	w.gd.file("events_hooks").templates.append({
		"id": "ev_fu_gated_16", "kind": "followup_only", "weight": 10.0, "place_kinds": ["any"],
		"conditions": {"type": "has_flag", "scope": "root", "flag": "ready_fu"},
		"title": "Hẹn tái ngộ", "text": "Đến hẹn.", "log": "{root} tái ngộ.",
		"choices": [
			{"label": "A", "check": {"type": "none"}, "always": [], "success": {"text": "A.", "effects": []}},
			{"label": "B", "check": {"type": "none"}, "always": [], "success": {"text": "B.", "effects": []}},
		],
	})
	# Schedule via resolver effect with delay [2, 4] at season 400
	var src_ev := {
		"title": "Khởi đầu", "text": "Khởi đầu.", "npc_id": "", "place_id": w.p1, "source": "test",
		"choices": [{
			"label": "Hẹn", "check": {"type": "none"}, "always": [],
			"success": {"text": "Đã hẹn.", "effects": [{"type": "schedule_followup", "event_id": "ev_fu_gated_16", "delay_seasons": [2, 4], "wait_seasons": 4}]},
			"failure": {"text": "", "effects": []},
		}],
	}
	var r0: Dictionary = eng._resolver.resolve(w.c, w.sheet, w.rng, src_ev, 0, {"year": 100, "season": 0})
	assert_eq(r0.scheduled_followups.size(), 1, "follow-up scheduled")
	var fu: Dictionary = _EventStore.get_followup(w.db, str(r0.scheduled_followups[0]))
	var due: int = int(fu.due_season)
	assert_true(due >= 402 and due <= 404, "AC-EV-16: due_season %d in [402..404]" % due)

	# Condition fails at due..due+3 (stays waiting), then drops at due+4!
	for d in range(0, 4):
		var s_now: int = due + d
		eng.on_season_start(w.c, w.sheet, w.rng, s_now / 4, s_now % 4)
		assert_false(_EventStore.get_followup(w.db, str(fu.id)).is_empty(), "AC-EV-16: waits at due+%d" % d)
	var drop_s: int = due + 4
	eng.on_season_start(w.c, w.sheet, w.rng, drop_s / 4, drop_s % 4)
	assert_true(_EventStore.get_followup(w.db, str(fu.id)).is_empty(), "AC-EV-16: dropped after wait_seasons=4")

	# AC-EV-17: hook-keyed follow-up on_arrive at place p2 only
	_EventStore.set_flag(w.db, w.c.id, "ready_fu")
	var fid17: String = _EventStore.add_followup(w.db, {
		"event_id": "ev_fu_gated_16", "root_id": w.c.id, "scheduled_at": 410, "due_season": 410,
		"wait_seasons": 8, "hook": "on_arrive", "hook_place_id": w.p2, "scopes": {},
	})
	# Arrive at p1 -> does NOT fire fid17
	w.c.location_id = w.p1
	var arr1: Dictionary = eng.raise_hook("on_arrive", w.c, w.sheet, w.rng, {"year": 103, "season": 0, "chance_override": 0.0})
	assert_false(bool(arr1.get("followup", false)), "AC-EV-17: does not fire at p1")
	assert_false(_EventStore.get_followup(w.db, fid17).is_empty(), "follow-up still waiting for p2")
	# Arrive at p2 -> fires fid17!
	w.c.location_id = w.p2
	var arr2: Dictionary = eng.raise_hook("on_arrive", w.c, w.sheet, w.rng, {"year": 103, "season": 1, "chance_override": 0.0})
	assert_true(bool(arr2.get("ok", false)) and bool(arr2.get("followup", false)), "AC-EV-17: fires on_arrive at p2")
	assert_eq(str(arr2.event.template_id), "ev_fu_gated_16")


# --- AC-EV-18 & AC-EV-19: Multi-stage story heartbeat, end record, cap 3 & priority displace -----

func test_story_stage_heartbeat_end_record_cap_and_priority_displacement_ac_ev_18_ac_ev_19() -> void:
	var w: Dictionary = _mini_world(2318)
	var eng: _EventEngine = w.eng
	# Start story_chronicle_lang_dao_03, set clues=2 and advance to stage s3_uncover (end: "done")
	var st_r: Dictionary = eng.start_story("story_chronicle_lang_dao_03", w.c.id, {}, 1200, 0, false, -1, w.c, w.sheet)
	assert_true(bool(st_r.ok), "story started")
	var sinst: String = str(st_r.story.id)
	_EventStore.set_var(w.db, sinst, "clues", 2, 0, 5)
	st_r.story["variables"]["clues"] = 2
	eng.advance_story(sinst, "s3_uncover", 1200, 0)

	# Next season start heartbeat queues stage 3 event; draining & resolving closes story as done + 1 record
	eng.on_season_start(w.c, w.sheet, w.rng, 1200, 1)
	var st_ev: Dictionary = eng.drain_queue(w.c, w.sheet, w.rng, 1200, 1)
	assert_eq(str(st_ev.get("template_id", "")), "st_lang_dao_3", "AC-EV-18: stage 3 event fires on next season start")
	var ends_before: int = w.db.all("events").filter(func(e): return str(e.type) == "story_end").size()
	eng.resolve_event(w.c, w.sheet, w.rng, st_ev, 0, 1200, 1)
	var s_after: Dictionary = _EventStore.get_story(w.db, sinst)
	assert_eq(str(s_after.status), "done", "AC-EV-18: story closed as done")
	var ends_after: int = w.db.all("events").filter(func(e): return str(e.type) == "story_end").size()
	assert_eq(ends_after - ends_before, 1, "AC-EV-18: exactly 1 WorldDB story_end record written")

	# AC-EV-19: 3 active non-priority stories -> 4th non-priority refused w/ warning (other effects still apply),
	# then priority story displaces oldest non-priority as timed_out!
	var stories_doc: Dictionary = w.gd.file("events_stories")
	stories_doc.stories.append({
		"id": "story_priority_test", "name": "Đại Biến Khẩn Cấp", "priority": true, "once_per_world": false,
		"budget_mult": 2.0, "items_max": 2, "timeout_seasons": 12, "start": {"mode": "event", "conditions": {}},
		"scopes": {}, "variables": {}, "stages": [{"id": "p1", "event_id": "st_lang_dao_1", "end": "done"}],
		"fail_flags": [], "required_living_scopes": [], "on_scope_death": {},
		"log_done": "Xong.", "log_failed": "Hỏng.", "log_timeout": "Quá hạn.",
	})
	var s_a: Dictionary = eng.start_story("story_chronicle_suong_tung_02", w.c.id, {}, 1201, 0, false, -1, w.c, w.sheet)
	var s_b: Dictionary = eng.start_story("story_chronicle_thai_chi_04", w.c.id, {}, 1201, 1, false, -1, w.c, w.sheet)
	var s_c: Dictionary = eng.start_story("story_chronicle_van_hac_03", w.c.id, {}, 1201, 2, false, -1, w.c, w.sheet)
	assert_true(bool(s_a.ok) and bool(s_b.ok) and bool(s_c.ok), "3 active stories started")

	# 4th normal story attempted in an outcome alongside a tu_vi grant: story refused w/ warning, tu_vi still applies!
	var tv_before: float = w.c.tu_vi
	var lvl_before: int = w.c.level
	var ev_4th := {
		"title": "Thử giới hạn", "text": "Thử.", "npc_id": "", "place_id": w.p1, "source": "test",
		"choices": [{
			"label": "Chấp nhận", "check": {"type": "none"}, "always": [],
			"success": {"text": "Xong.", "effects": [
				{"type": "story_start", "story_id": "story_chronicle_clans_09"},
				{"type": "tu_vi", "amount": 25.0},
				{"type": "set_flag", "scope": "root", "flag": "other_fx_applied"},
			]},
			"failure": {"text": "", "effects": []},
		}],
	}
	var res4: Dictionary = eng.resolve_event(w.c, w.sheet, w.rng, ev_4th, 0, 1201, 3)
	assert_true(w.c.tu_vi > tv_before or w.c.level > lvl_before, "AC-EV-19: tu_vi still applies when 4th story is refused")
	assert_true(_EventStore.has_flag(w.db, w.c.id, "other_fx_applied", 1201 * 4 + 3), "AC-EV-19: flag effect still applies when 4th story is refused")
	assert_true(Array(res4.warnings).any(func(x): return str(x).contains("story_chronicle_clans_09")), "AC-EV-19: warning names refused story: %s" % str(res4.warnings))
	assert_eq(_EventStore.active_stories(w.db, w.c.id, false).size(), 3, "still 3 active stories")

	# Priority story displaces oldest non-priority (s_a) as timed_out!
	var sp: Dictionary = eng.start_story("story_priority_test", w.c.id, {}, 1202, 0, false, -1, w.c, w.sheet)
	assert_true(bool(sp.ok), "AC-EV-19: priority story starts")
	assert_eq(str(_EventStore.get_story(w.db, str(s_a.story.id)).status), "timed_out", "AC-EV-19: oldest non-priority story ended as timed_out")
	assert_eq(_EventStore.active_stories(w.db, w.c.id, false).size(), 3, "active count stays 3")


# --- AC-EV-20, AC-EV-27, AC-EV-28, AC-EV-31, AC-EV-32, AC-EV-39 ----------------------------------

func test_effects_losses_stat_check_alarm_array_death_and_new_npc_ac_ev_20_27_28_31_32_39() -> void:
	var w: Dictionary = _mini_world(2320)
	var eng: _EventEngine = w.eng
	var c: Character = w.c
	var ctx: Dictionary = EventContext.build(c, w.gd, w.db, w.sheet, 1200, 0, "vi")

	# AC-EV-28: stat 60 vs difficulty 50 and fortune 50 -> 0.60 + Breakdown
	var bd: Breakdown = eng._resolver.stat_check_chance(c, w.sheet, "ngo_tinh", 50.0, false)
	assert_near(bd.total, 0.60, 1e-6, "AC-EV-28: stat 60 vs diff 50 fortune 50 -> 0.60")
	assert_true(bd.lines().size() >= 2, "AC-EV-28: Breakdown exposes contributing lines")

	# AC-EV-20 & AC-EV-39: new NPC registered before pending event is returned; effects mutate owning systems
	var raw_new := {
		"title": "Khách lạ", "text": "Khách lạ tới.", "npc": {"new": {"name": "Triệu Vũ", "archetype": "tan_tu", "realm_offset": 0}},
		"choices": [
			{
				"label": "Giao thiệp", "check": {"type": "none"}, "always": [],
				"success": {"text": "Xong.", "effects": [
					{"type": "sect_standing", "amount": 10},
					{"type": "set_flag", "scope": "root", "flag": "met_trieu_vu"},
					{"type": "unknown_bogus_effect_xyz", "amount": 5},
				]},
			},
			{"label": "Bỏ qua", "check": {"type": "none"}, "always": [], "success": {"text": "Đi.", "effects": []}},
		],
	}
	var norm_new: Dictionary = eng._validator.normalize(raw_new, ctx, w.rng, "test")
	assert_true(bool(norm_new.ok), "normalizes cleanly")
	assert_true(w.db.has_record("people", str(norm_new.event.npc_id)), "AC-EV-39: new person exists in WorldDB before event is shown")
	assert_true(Array(norm_new.warnings).any(func(x): return str(x).contains("unknown_bogus_effect_xyz")), "AC-EV-20: unknown effect dropped with warning")
	var st_before: float = SectMembers.new(w.gd, w.db).standing(w.s1, c.id)
	eng.resolve_event(c, w.sheet, w.rng, norm_new.event, 0, 1200, 0)
	assert_true(SectMembers.new(w.gd, w.db).standing(w.s1, c.id) > st_before, "AC-EV-20: sect_standing mutated")
	assert_true(_EventStore.has_flag(w.db, c.id, "met_trieu_vu", 1200 * 4), "AC-EV-20: set_flag mutated")

	# Additional Rule 13 effects: grant_trait, remove_trait, sect_loyalty, sect_attitude, scar, access
	var raw_fx := {
		"title": "Ảnh hưởng rộng", "text": "Thử các hiệu ứng.", "place_id": w.p1, "sect_id": w.s2,
		"choices": [
			{
				"label": "Áp dụng", "check": {"type": "none"}, "always": [],
				"success": {"text": "Xong.", "effects": [
					{"type": "grant_trait", "trait": "old_wound", "scope": "root"},
					{"type": "sect_loyalty", "sect": w.s2, "amount": -10},
					{"type": "scar", "place_id": w.p1, "d_density": -0.1, "cause": "Kiếm khí"},
					{"type": "access", "key": "secret_library", "expires_seasons": 4},
				]},
			},
			{"label": "Không", "check": {"type": "none"}, "always": [], "success": {"text": "Thôi.", "effects": []}},
		],
	}
	var norm_fx: Dictionary = eng._validator.normalize(raw_fx, ctx, w.rng, "test", {"max_effects_override": 6})
	eng.resolve_event(c, w.sheet, w.rng, norm_fx.event, 0, 1200, 1)
	assert_true(NpcTraits.held(w.db.get_record("people", c.id)).has("old_wound"), "AC-EV-20: grant_trait applied")
	assert_near(float(w.db.get_record("sects", w.s2).loyalty), 40.0, 1e-4, "AC-EV-20: sect_loyalty mutated")
	assert_true(Array(w.db.get_record("places", w.p1).get("scars", [])).size() >= 1, "AC-EV-20: scar applied")
	assert_true(_EventStore.has_flag(w.db, c.id, "access:secret_library", 1200 * 4 + 2), "AC-EV-20: access granted")

	# AC-EV-27: losses (-60% vitality, +15 tam_ma) don't spend chain budget; 80% clamped to 60%
	var ch_id: String = _EventBudget.create_chain(w.db, w.gd, c, w.sheet, 1.5, 2)
	var left_before: float = float(_EventStore.get_chain_budget(w.db, ch_id).left.linh_thach)
	var raw_loss := {
		"title": "Thương tổn", "text": "Thử tổn thất.", "chain_id": ch_id,
		"choices": [
			{
				"label": "Chịu đựng", "check": {"type": "none"}, "always": [],
				"success": {"text": "Đau.", "effects": [
					{"type": "khi_huyet_loss_pct", "amount": 80},
					{"type": "tam_ma", "amount": 15},
				]},
			},
			{"label": "Tránh", "check": {"type": "none"}, "always": [], "success": {"text": "Tránh.", "effects": []}},
		],
	}
	var norm_loss: Dictionary = eng._validator.normalize(raw_loss, ctx, w.rng, "test", {"chain_id": ch_id})
	var fx_kh: Dictionary = norm_loss.event.choices[0].success.effects[0]
	assert_near(float(fx_kh.amount), 60.0, 1e-4, "AC-EV-27: 80% vitality loss clamped to 60%")
	c.vitality = 1.0
	c.tam_ma = 0.0
	eng.resolve_event(c, w.sheet, w.rng, norm_loss.event, 0, 1200, 1)
	assert_near(c.vitality, 0.4, 1e-4, "AC-EV-27: 60% vitality loss applied")
	assert_true(c.tam_ma > 0.0, "AC-EV-27: tam_ma applied")
	assert_near(float(_EventStore.get_chain_budget(w.db, ch_id).left.linh_thach), left_before, 1e-4, "AC-EV-27: losses never reduce chain budget")

	# AC-EV-31: Alarm Array at abode raises player BLIND -> AMBUSH while foe stays BLIND
	c.formations["canh_gioi_tran"] = 1
	var sits: Dictionary = EventResolver.effective_situations(c, w.db, FightRequest.Situation.BLIND, ["own_abode"], c.location_id)
	assert_true(bool(sits.alarm_stepped), "AC-EV-31: Alarm Array stepped up situation")
	assert_eq(int(sits.a), FightRequest.Situation.AMBUSH, "AC-EV-31: player fights as AMBUSH")
	assert_eq(int(sits.b), FightRequest.Situation.BLIND, "AC-EV-31: foe stays BLIND")

	# AC-EV-32: vitality 0.3 - 30% -> death naming event title; cap #5 saves one stage lower
	var ev_fatal := {
		"title": "Lôi Hỏa Phản Phệ", "text": "Nguy hiểm.", "npc_id": "", "place_id": w.p1, "source": "test",
		"choices": [{
			"label": "Chịu", "check": {"type": "none"}, "always": [],
			"success": {"text": "Gục.", "effects": [{"type": "khi_huyet_loss_pct", "amount": 30}]},
			"failure": {"text": "", "effects": []},
		}],
	}
	c.vitality = 0.3
	c.alive = true
	c.stage = 2
	c.capabilities = [5]
	c.cap_used = {}
	var r_cap5: Dictionary = eng._resolver.resolve(c, w.sheet, w.rng, ev_fatal, 0)
	assert_false(bool(r_cap5.died), "AC-EV-32: cap #5 saves the character")
	assert_true(c.alive and c.stage == 1, "AC-EV-32: lives one stage lower (2 -> 1)")

	c.vitality = 0.3
	var r_die: Dictionary = eng._resolver.resolve(c, w.sheet, w.rng, ev_fatal, 0)
	assert_true(bool(r_die.died) and not c.alive, "AC-EV-32: vitality reaching 0 kills when cap #5 used")
	assert_true(c.death_cause.contains("Lôi Hỏa Phản Phệ"), "AC-EV-32: death cause names event title: %s" % c.death_cause)


# --- AC-EV-34 & AC-EV-36: NPC volume Formulas D + cap 40 + news filtering ------------------------

func test_npc_volume_formulas_d_cap_40_and_news_filtering_ac_ev_34_ac_ev_36() -> void:
	var w: Dictionary = _mini_world(2334)
	var db: WorldDB = w.db
	var gd: GameData = w.gd
	var eng: _EventEngine = w.eng
	# Replace npc_capable templates with a zero-cooldown universal pulse so volume tests pure Formulas D odds cleanly
	gd.file("events_hooks")["templates"] = [{
		"id": "ev_npc_vol_probe", "kind": "pulse", "npc_capable": true, "newsworthy": false,
		"cooldown_seasons": 0, "weight": 10.0, "place_kinds": ["any"], "npc": {"mode": "none"},
		"title": "Du ngoạn", "text": "{root} du ngoạn.", "log": "{root} du ngoạn tại {place}.",
		"choices": [
			{"label": "A", "tags": ["cautious"], "check": {"type": "none"}, "always": [], "success": {"text": "A.", "effects": []}},
			{"label": "B", "tags": ["bold"], "check": {"type": "none"}, "always": [], "success": {"text": "B.", "effects": []}},
		],
	}]
	# Create 51 cast + 30 known + 300 strangers (sample=200 -> 281 candidates -> expected 28.1/season)
	for i in 51:
		db.put("people", {"id": "p_cast_%03d" % i, "name": "C%d" % i, "alive": true, "realm_index": 0, "stage": 0, "location_id": w.p1, "cast_key": "ck_%d" % i, "thien_phu": {"khi_van": 50}, "npc_traits": {"personality": ["calm"]}})
	for i in 30:
		db.put("people", {"id": "p_known_%03d" % i, "name": "K%d" % i, "alive": true, "realm_index": 0, "stage": 0, "location_id": w.p1, "met_player": true, "attitude": 15, "thien_phu": {"khi_van": 50}, "npc_traits": {"personality": ["calm"]}})
	for i in 300:
		db.put("people", {"id": "p_str_%03d" % i, "name": "S%d" % i, "alive": true, "realm_index": 0, "stage": 0, "location_id": w.p1, "thien_phu": {"khi_van": 50}, "npc_traits": {"personality": ["calm"]}})

	var total_fired: int = 0
	for s_i in 400:
		eng.run_npc_season(w.rng, 1200 + s_i / 4, s_i % 4, 9001, w.c.id)
		total_fired += eng.last_npc_fired
	var mean_fired: float = float(total_fired) / 400.0
	assert_true(absf(mean_fired - 28.1) <= 28.1 * 0.05, "AC-EV-34: 400-season mean %.2f within ±5%% of 28.1" % mean_fired)

	# Cap test: 600 known/cast eligible -> never exceeds 40 in a season
	for i in 600:
		db.put("people", {"id": "p_big_%03d" % i, "name": "B%d" % i, "alive": true, "realm_index": 0, "stage": 0, "location_id": w.p1, "cast_key": "big_%d" % i, "thien_phu": {"khi_van": 50}, "npc_traits": {"personality": ["calm"]}})
	for s_i in 10:
		eng.run_npc_season(w.rng, 1400 + s_i, 0, 9002, w.c.id)
		assert_true(eng.last_npc_fired <= 40, "AC-EV-34: NPC events capped <= 40 (got %d)" % eng.last_npc_fired)

	# AC-EV-36: NPC event with known other reaches player news; stranger unmarked does not
	var stranger_ev := {"type": "npc_event", "people": ["p_str_001", "p_str_002"], "data": {"newsworthy": false}}
	var known_other_ev := {"type": "npc_event", "people": ["p_str_001", "p_known_001"], "data": {"newsworthy": false}}
	var newsworthy_ev := {"type": "npc_event", "people": ["p_str_001"], "data": {"newsworthy": true}}
	assert_false(_EventEngine.is_news_for_player(db, stranger_ev, w.c.id), "AC-EV-36: unmarked stranger event excluded from news")
	assert_true(_EventEngine.is_news_for_player(db, known_other_ev, w.c.id), "AC-EV-36: event with known other reaches news")
	assert_true(_EventEngine.is_news_for_player(db, newsworthy_ev, w.c.id), "AC-EV-36: newsworthy event reaches news")


# --- AC-EV-43 & AC-EV-44: Non-nesting hook queue & root death cleanup ----------------------------

func test_non_nesting_hook_and_root_death_cleanup_ac_ev_43_ac_ev_44() -> void:
	var w: Dictionary = _mini_world(2343)
	var eng: _EventEngine = w.eng

	# AC-EV-43: hook raised while event resolves queues cleanly after, never nests
	var combat_foe: String = w.builds.create_person(w.rng, {"realm_index": 0, "location_id": w.p1})
	var ev_fight := {
		"title": "Tranh đấu", "text": "Giao thủ.", "npc_id": combat_foe, "place_id": w.p1, "source": "test",
		"choices": [{
			"label": "Đánh", "check": {"type": "combat", "enemy": combat_foe}, "always": [],
			"success": {"text": "Thắng.", "effects": []}, "failure": {"text": "Thua.", "effects": []},
		}],
	}
	w.gd.combat()["fight_engine"]["enabled"] = false
	eng.resolve_event(w.c, w.sheet, w.rng, ev_fight, 0, 1200, 0, {"emit_fight_end_hook": true})
	var q: Array = _EventStore.get_queue(w.db)
	assert_eq(q.size(), 1, "AC-EV-43: on_fight_end hook queued during resolution rather than nesting")
	assert_eq(str(q[0].hook_id), "on_fight_end")
	var next_ev: Dictionary = eng.drain_queue(w.c, w.sheet, w.rng, 1200, 0, {"chance_override": 1.0})
	assert_false(next_ev.is_empty(), "AC-EV-43: queued hook fires cleanly after event finishes")

	# AC-EV-44: root death drops 2 follow-ups (keeps another root's) and ends active story as failed with record
	var f1: String = _EventStore.add_followup(w.db, {"event_id": "ev_fu_debt_collector_arrives", "root_id": w.c.id, "scheduled_at": 10, "due_season": 12, "wait_seasons": 4})
	var f2: String = _EventStore.add_followup(w.db, {"event_id": "ev_fu_friend_request", "root_id": w.c.id, "scheduled_at": 11, "due_season": 13, "wait_seasons": 4})
	var f_other: String = _EventStore.add_followup(w.db, {"event_id": "ev_fu_friend_request", "root_id": combat_foe, "scheduled_at": 11, "due_season": 13, "wait_seasons": 4})
	var st_r: Dictionary = eng.start_story("story_chronicle_lang_dao_03", w.c.id, {}, 1200, 1, false, -1, w.c, w.sheet)
	var sinst: String = str(st_r.story.id)

	var death_logs: Array = eng.on_root_death(w.c.id, 1200, 2)
	assert_true(_EventStore.get_followup(w.db, f1).is_empty() and _EventStore.get_followup(w.db, f2).is_empty(), "AC-EV-44: both root follow-ups dropped")
	assert_false(_EventStore.get_followup(w.db, f_other).is_empty(), "AC-EV-44: other root's follow-up stays")
	assert_eq(str(_EventStore.get_story(w.db, sinst).status), "failed", "AC-EV-44: active story ended as failed")
	assert_eq(death_logs.size(), 1, "AC-EV-44: story failure wrote 1 WorldDB record")
