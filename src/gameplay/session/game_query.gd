class_name GameQuery
extends RefCounted
## The read-only queries a shipped frontend uses beside GameSession's read methods, StateSnapshot and Advisor
## (ADR-0006 decision 3). Static functions that take the session and return deep copies built for the purpose, never a
## World DB record or a live service object, and never change the world (tests/unit/session/session_reads_test.gd).
## A frontend calls them only while no session job runs (decision 6). They grow screen by screen.


## The clock: {year, season, index, label, season_name}.
static func clock(s: GameSession) -> Dictionary:
	var names: Array = s.gd.world_gen().get("season_names", [])
	return {"year": s.year, "season": s.season, "index": s.season_index(), "label": s.clock_label(),
		"season_name": str(names[s.season]) if s.season < names.size() else ""}


## The player's essentials a screen needs beside StateSnapshot: {id, name, location_id, home_id, realm_label}.
static func player(s: GameSession) -> Dictionary:
	var c: Character = s.player
	if c == null:
		return {}
	return {"id": c.id, "name": c.name, "location_id": str(c.location_id), "home_id": str(c.home_id),
		"realm_label": s.gd.realm_label(c.realm_index, c.stage)}


## A known place as a copy, with what screens show: the record's fields plus region_name, holder_name, land_match
## (how well its qi suits the player), here (the player is there), known. {} for a hidden or unknown place.
static func place(s: GameSession, place_id: String) -> Dictionary:
	var p: Dictionary = s.db.get_record("places", place_id)
	if p.is_empty() or not _shown(s, p):
		return {}
	return _place_view(s, p)


## The player's own place (always known).
static func here(s: GameSession) -> Dictionary:
	var p: Dictionary = s.db.get_record("places", str(s.player.location_id))
	return {} if p.is_empty() else _place_view(s, p)


## Every place the player knows (not hidden, on the map), as [method place] copies.
static func known_places(s: GameSession) -> Array:
	var out: Array = []
	for p in s.db.all("places"):
		if p.has("tile") and _shown(s, p):
			out.append(_place_view(s, p))
	return out


## People the player has met who are at [param place_id] now: [{id, name, realm_label, line}] (line: one display line).
static func people_met_at(s: GameSession, place_id: String) -> Array:
	var out: Array = []
	for x in s.db.find("people", func(q): return bool(q.get("alive", true)) and not bool(q.get("is_player", false)) \
			and bool(q.get("met_player", false)) and str(q.get("location_id", "")) == place_id):
		out.append({"id": str(x.id), "name": str(x.get("name", "")),
			"realm_label": s.gd.realm_label(int(x.get("realm_index", 0)), int(x.get("stage", 0))),
			"line": TerminalViews.person_line(s, x)})
	return out


## Everyone alive at [param place_id] except the player, met or not (the player sees everyone, design/ux/person.md):
## [{id, name, realm_label, met}], strongest realm first.
static func people_at(s: GameSession, place_id: String) -> Array:
	var out: Array = []
	for x in s.db.find("people", func(q): return bool(q.get("alive", true)) and not bool(q.get("is_player", false)) \
			and not bool(q.get("is_beast", false)) and str(q.get("location_id", "")) == place_id):
		out.append({"id": str(x.id), "name": str(x.get("name", "")), "realm_index": int(x.get("realm_index", 0)),
			"realm_label": s.gd.realm_label(int(x.get("realm_index", 0)), int(x.get("stage", 0))), "met": bool(x.get("met_player", false))})
	out.sort_custom(func(a, b): return int(a.realm_index) > int(b.realm_index))
	return out


## The travel time in seasons from the player's place to [param dest_id] by the game's own route (TravelGrid.trip on
## the terrain, the road network when there is none), at the player's travel speed; -1 when there is no route.
static func route_seasons(s: GameSession, dest_id: String) -> float:
	var here_p: Dictionary = s.db.get_record("places", str(s.player.location_id))
	var dest: Dictionary = s.db.get_record("places", dest_id)
	if here_p.is_empty() or dest.is_empty():
		return -1.0
	var f: float = Travel.speed_factor(s.gd, s.sheet().total("travel_speed_pct"))
	var tg: TravelGrid = TravelGrid.of(s.gd)
	if tg.errors.is_empty() and here_p.has("tile") and dest.has("tile"):
		var trip: Dictionary = tg.trip(Vector2i(int(here_p.tile[0]), int(here_p.tile[1])), Vector2i(int(dest.tile[0]), int(dest.tile[1])), "ground", f)
		if not trip.is_empty():
			return float(trip.seasons)
	var route: Dictionary = Travel.quickest(s.db, str(here_p.id), dest_id, f)
	return float(route.seasons) if not route.is_empty() else -1.0


## True when the player has clue search areas to show (Places panel).
static func has_clues(s: GameSession) -> bool:
	return s.knowledge != null and not s.knowledge.clues.is_empty()


## A copy of the pending event (title, text, choices), or {}.
static func pending_event(s: GameSession) -> Dictionary:
	return s.pending_event.duplicate(true)


## The market's goods at [param place_id] as display lines (a stand-in until the trade window is designed).
static func market_lines(s: GameSession, place_id: String) -> Array:
	var out: Array = []
	for it in s.market.stock(place_id):
		out.append(s.items.describe(it))
	return out


## A derived number with its Breakdown: [param what] is "rate" (cultivation per season here) or "lifespan".
## Returns {total, lines}; {} for an unknown name.
static func breakdown(s: GameSession, what: String) -> Dictionary:
	var c: Character = s.player
	var b: Breakdown = null
	match what:
		"rate":
			var p: Dictionary = s.db.get_record("places", str(c.location_id))
			b = CultivationRules.rate_per_season(c, s.gd, s.db, s.sheet(), float(p.get("density", 1.0)), false, p.get("qi", {}))
		"lifespan":
			b = CultivationRules.lifespan(c, s.gd, s.sheet())
	if b == null:
		return {}
	return {"total": b.total, "lines": Array(b.lines())}


## The top bar's resource boxes beside StateSnapshot (design/ux/hud.md elements 8, 33-35): {rate_pct (progress per
## season if the player cultivates at the current place, as a % of the level's requirement), power (the shown power
## number, -1 when the player has no rating yet), provisional (a world-generation rating), in_sect, contribution (0 outside a sect), renown (-1: not tracked by
## the game yet), held (at the bottleneck or a realm cap: progress does not move)}. Reads only: an unrated player gets no rating record.
static func resources(s: GameSession) -> Dictionary:
	var c: Character = s.player
	if c == null:
		return {}
	var req: float = CultivationRules.level_requirement(c, s.gd)
	var rate: Dictionary = breakdown(s, "rate")
	var rec: Dictionary = s.db.get_record(RatingService.TABLE, c.id)
	var rated: bool = not rec.is_empty()
	var in_sect: bool = c.sect_id != ""
	return {"rate_pct": (100.0 * float(rate.get("total", 0.0)) / req) if req > 0.0 else 0.0,
		"power": s.ratings.ladder.power_number(s.ratings.rating_of(c.id)) if rated else -1,
		"provisional": rated and str(rec.get("state", "")) == RatingService.PROVISIONAL,
		"in_sect": in_sect, "contribution": s.sect_members.contribution(c.sect_id, c.id) if in_sect else 0,
		"renown": -1, "held": CultivationRules.at_bottleneck(c, s.gd) or CultivationRules.is_capped(c, s.gd)}


## The cultivation requirement of the player's current level (the bar's full mark).
static func level_requirement(s: GameSession) -> float:
	return CultivationRules.level_requirement(s.player, s.gd)


## The player's travel speed factor (Travel.speed_factor of the sheet's travel_speed_pct).
static func travel_factor(s: GameSession) -> float:
	return Travel.speed_factor(s.gd, s.sheet().total("travel_speed_pct"))


## Display lines for a place's stand-in details panel (until the place window is designed).
static func place_lines(s: GameSession, place_id: String) -> Array:
	var p: Dictionary = s.db.get_record("places", place_id)
	if p.is_empty():
		return []
	return TerminalViews.stat_block(s, p.duplicate(true))


## The regions for the map's region names (art bible 7.14): [{id, name, name_han, centre: [x, y] tile}], every region
## (their names are common knowledge, like the continent's outline).
static func regions(s: GameSession) -> Array:
	var out: Array = []
	for r in s.db.all("regions"):
		out.append({"id": str(r.id), "name": str(r.get("name", "")), "name_han": str(r.get("name_han", "")),
			"centre": Array(r.get("centre_tile", [0, 0]))})
	return out


## A place's authored look, lore and history (assets/data/world_place_lore.json, keyed by the continent place id the
## world record carries): {look, lore, history, special, levels, projects}; {} when the place has none.
static func place_lore(s: GameSession, place_id: String) -> Dictionary:
	var p: Dictionary = s.db.get_record("places", place_id)
	if p.is_empty() or not p.has("continent_id"):
		return {}
	return s.gd.file("world_place_lore").get("places", {}).get(str(int(p.continent_id)), {}).duplicate(true)


## Display lines for the stand-in character sheet (until the character window is designed).
static func sheet_lines(s: GameSession) -> Array:
	return TerminalViews.sheet(s, TerminalIO.new())


## Everything the person window shows about [param person_id] (design/ux/person.md: the player always sees everything),
## as a copy: identity, standing, attitude and band, power number, linh căn, stats, công pháp, traits, ties, where they
## are and their recent history. {} when there is no such person; {"gone": true, ...} for a dead one.
static func person(s: GameSession, person_id: String) -> Dictionary:
	var p: Dictionary = s.db.get_record("people", person_id)
	if p.is_empty():
		return {}
	var gd: GameData = s.gd
	var c := Character.from_dict(p.duplicate(true))
	var sh: StatSheet = s.builds.sheet_of(c) if s.builds != null else null
	var sect: Dictionary = s.db.get_record("sects", str(p.get("sect_id", "")))
	var here_id: String = str(s.player.location_id)
	var at: Dictionary = s.db.get_record("places", str(p.get("location_id", "")))
	var att: int = int(p.get("attitude", 0))
	var out := {
		"id": person_id, "name": str(p.get("name", "")), "gender": str(p.get("gender", "")), "age": float(p.get("age", 0.0)),
		"alive": bool(p.get("alive", true)), "death_cause": str(p.get("death_cause", "")), "is_beast": bool(p.get("is_beast", false)),
		"is_player": bool(p.get("is_player", false)), "met": bool(p.get("met_player", false)),
		"realm_label": gd.realm_label(int(p.get("realm_index", 0)), int(p.get("stage", 0))), "level": int(p.get("level", 1)),
		"archetype": str(gd.archetype(str(p.get("archetype", ""))).get("name", p.get("archetype", ""))),
		"sect": str(sect.get("name", "")), "sect_id": str(p.get("sect_id", "")),
		"rank": s.sect_members.rank_name(str(p.get("sect_rank", ""))) if s.sect_members != null and str(p.get("sect_rank", "")) != "" else "",
		"attitude": att, "band": attitude_band(gd, att),
		"power": str(s.power_of_person(person_id).get("text", "")),
		"linh_can": c.linh_can.describe(gd),
		"place_id": str(p.get("location_id", "")), "place": str(at.get("name", "")), "here": str(p.get("location_id", "")) == here_id,
		"home": str(s.db.get_record("places", str(p.get("home_id", ""))).get("name", "")),
		"stats": [], "techniques": [], "traits": [], "ties": [], "history": [], "talents": [],
	}
	if sh != null:
		out.stats = [
			{"label": "Health (khí huyết)", "value": CharacterRules.khi_huyet_max(c, gd, sh).total},
			{"label": "Linh lực", "value": CharacterRules.linh_luc(c, gd, sh).total},
			{"label": "Thần thức", "value": CharacterRules.than_thuc(c, gd, sh).total},
			{"label": "Vitality", "value": float(p.get("vitality", 1.0))},
		]
	for t in Array(gd.attributes().get("thien_phu", [])):
		if (p.get("thien_phu", {}) as Dictionary).has(str(t.id)):
			out.talents.append({"label": str(t.name), "value": float(p.thien_phu[str(t.id)])})
	var techs: Dictionary = p.get("techniques", {})
	for key in techs:
		var e: Dictionary = techs[key]
		var slot: String = ""
		if str(key) == str(p.get("main_tech", "")):
			slot = "main"
		elif str(key) == str(p.get("second_tech", "")):
			slot = "second"
		elif Array(p.get("aux_tech", [])).has(key):
			slot = "art"
		out.techniques.append({"name": str((e.get("def", {}) as Dictionary).get("name", key)), "slot": slot,
			"layer": int(e.get("layer", 0)), "layers": int((e.get("def", {}) as Dictionary).get("layers", 0))})
	out.techniques.sort_custom(func(a, b): return ["main", "second", "art", ""].find(a.slot) < ["main", "second", "art", ""].find(b.slot))
	var tr_data: Dictionary = gd.file("traits")
	var nt: Dictionary = p.get("npc_traits", {})
	for group in ["personality", "calling", "fate", "gained"]:
		var ids: Array = Array(nt.get(group, [])) if nt.get(group) is Array else ([nt.get(group)] if str(nt.get(group, "")) != "" else [])
		var table: Array = Array(tr_data.get("callings" if group == "calling" else group, []))
		for tid in ids:
			var rec: Dictionary = {}
			for r in table:
				if str(r.get("id", "")) == str(tid):
					rec = r
			out.traits.append({"group": group, "id": str(tid), "name": str(rec.get("name", tid)), "name_vi": str(rec.get("name_vi", ""))})
	var mine: Array = []
	var other: Array = []
	for t in s.db.all(Ties.TABLE):
		if str(t.a) != person_id and str(t.b) != person_id:
			continue
		var partner: String = str(t.b) if str(t.a) == person_id else str(t.a)
		var kinds: Array = []
		for k in (t.get("pin", {}) as Dictionary):
			kinds.append("master" if k == "su_do" and str(t.pin.su_do) == partner else ("disciple" if k == "su_do" else str(k)))
		if not (t.get("feud", {}) as Dictionary).is_empty():
			kinds.append("feud")
		if not (t.get("soft", {}) as Dictionary).is_empty():
			kinds.append(str(t.soft.get("kind", "")))
		if not (t.get("debt", {}) as Dictionary).is_empty():
			kinds.append("debt")
		if kinds.is_empty():
			continue
		var row := {"partner_id": partner, "partner": str(s.db.get_record("people", partner).get("name", partner)), "kinds": kinds}
		(mine if partner == str(s.player.id) else other).append(row)
	out.ties = mine + other.slice(0, 3)
	for e in s.db.events_of(person_id).slice(-5):
		out.history.append(str(e.get("text", "")))
	return out


## The attitude band word for [param attitude] (npc-interaction-dialogue.md rule 13; thresholds in ui_hud.json).
static func attitude_band(gd: GameData, attitude: int) -> String:
	var bands: Array = Array(gd.file("ui_hud").get("attitude_bands", []))
	var word: String = "neutral"
	for b in bands:
		if attitude >= int(b[0]):
			word = str(b[1])
	return word


## A practice fight between the player and [param person_id] for the fight screen: keyed on the two ids and the season,
## so it is the same every time and draws nothing from the session stream; it changes nothing (a read, ADR-0006). Returns
## {ok, rows: [{kind, t_ms, side, art, values}], a/b: {name, realm, arts}, winner, ending, seconds} or {ok: false, reason}.
static func practice_fight(s: GameSession, person_id: String) -> Dictionary:
	var fe: Dictionary = s.gd.combat().get("fight_engine", {})
	if not bool(fe.get("enabled", false)):
		return {"ok": false, "reason": "The fight engine is switched off in this build."}
	var p: Dictionary = s.db.get_record("people", person_id)
	if p.is_empty() or not bool(p.get("alive", true)):
		return {"ok": false, "reason": "No living person to fight."}
	var foe := Character.from_dict(p.duplicate(true))
	var a: FighterProfile = FighterCompiler.compile(s.player, s.gd, s.db, s.sheet())
	var b: FighterProfile = FighterCompiler.compile(foe, s.gd, s.db, s.builds.sheet_of(foe))
	if a == null or b == null:
		return {"ok": false, "reason": "A fighter could not be compiled."}
	var req := FightRequest.new()
	req.a = a
	req.b = b
	req.fight_seed = RngUtils.stable_hash("practice:%s:%s:%d" % [s.player.id, person_id, s.season_index()])
	req.log_enabled = true
	var r: FightResult = CombatService.new(CombatConstants.from_game_data(s.gd)).resolve(req)
	if r == null:
		return {"ok": false, "reason": "The fight did not run."}
	var rows: Array = []
	for row in r.log_rows:
		rows.append({"kind": FightLogRow.Kind.keys()[row.kind].to_lower(), "t_ms": row.t_ms, "side": row.side,
			"other": row.other, "art": str(row.art_id), "hit_kind": str(row.hit_kind), "values": Array(row.values)})
	var side_info := func(c: Character, prof: FighterProfile) -> Dictionary:
		var arts: Array = []
		var lib: Dictionary = s.gd.file("combat_library").get("arts", {})
		for x in prof.arts:
			var rec: Dictionary = lib.get(str(x.id), {})
			arts.append({"id": str(x.id), "name": str(rec.get("name", "")), "rule": str(rec.get("rule", "")), "cd": x.cd, "cost": x.cost, "element": str(x.element), "dtype": str(x.dtype),
				"charges": x.charges, "steps": x.steps.size(), "empower": x.empower.size(), "heal": x.heal,
				"pool": str(x.pool), "statuses": x.statuses.map(func(st): return st.id)})
		var wards: Array = []
		for w in prof.wards:
			wards.append({"id": w.id, "model": ExtraWardDef.Model.keys()[w.model].to_lower(), "cost": w.cost, "drain": w.drain,
				"cooldown": w.cooldown, "up": w.up, "shield": w.shield, "block": w.block, "evade": w.evade})
		var shields: Array = []
		for sh in prof.shields:
			shields.append({"size": sh.size, "body": sh.body, "standing": sh.standing, "pieces": sh.pieces})
		var effect_info := {}
		for e in prof.effects:
			effect_info[str(e.id)] = effect_of(s.gd, str(e.id))
		return {"name": c.name, "realm": s.gd.realm_label(c.realm_index, c.stage), "roots": c.linh_can.describe(s.gd),
			"arts": arts, "wards": wards, "shields": shields, "body_shield": prof.body_shield, "block": prof.block,
			"evade": prof.evade, "crit": prof.crit, "reserved": prof.reserved, "feeds": prof.feeds.duplicate(true),
			"effects": prof.effects.map(func(e): return e.id), "effect_info": effect_info, "items": [],
			"sheet": {"ward_pts": prof.ward_pts, "ward_layer": prof.ward_layer, "drain": prof.drain, "resist": prof.resist.duplicate(),
				"soul_res": prof.soul_res, "divine_sense": prof.divine_sense, "crit_mult": prof.crit_mult, "hregen": prof.hregen,
				"healing": prof.healing, "power": str(s.power_of_person(c.id).get("text", ""))}}
	return {"ok": true, "rows": rows, "a": side_info.call(s.player, a), "b": side_info.call(foe, b),
		"winner": r.win_code(), "ending": FightResult.Ending.keys()[r.ending].to_lower(), "seconds": r.seconds}


## The Effect a fight record id belongs to (combat_effects.json): a record id is "eff:<Effect name>" with an optional
## suffix (" phase 2", " (closes)", " closes"), so the longest Effect name it starts with is its Effect. Returns {name,
## rule}; an unknown id comes back as its own name with no rule.
static func effect_of(gd: GameData, record_id: String) -> Dictionary:
	var body: String = record_id.trim_prefix("eff:")
	var lib: Dictionary = gd.file("combat_effects").get("effects", {})
	var best: String = ""
	for name in lib:
		var n: String = str(name)
		if n.length() > best.length() and (body == n or body.begins_with(n + " ")):
			best = n
	if best == "":
		return {"name": body, "rule": ""}
	return {"name": best, "rule": str(lib[best].get("rule", ""))}


static func _shown(s: GameSession, p: Dictionary) -> bool:
	if bool(p.get("hidden", false)):
		return false
	return s.knowledge == null or str(p.id) == str(s.player.location_id) or s.knowledge.knows_place(str(p.id))


static func _place_view(s: GameSession, p: Dictionary) -> Dictionary:
	var v: Dictionary = p.duplicate(true)
	v["region_name"] = str(s.db.get_record("regions", str(p.get("region_id", ""))).get("name", ""))
	var holder: String = str(p.get("holder", ""))
	v["holder_name"] = str(s.db.get_record("sects", holder).get("name", holder)) if holder != "" else ""
	var qi: Dictionary = p.get("qi", {})
	v["land_match"] = float(LandQi.land_match(s.player, s.gd, qi).total) if not qi.is_empty() else 0.0
	v["here"] = str(p.id) == str(s.player.location_id)
	v["known"] = true
	return v
