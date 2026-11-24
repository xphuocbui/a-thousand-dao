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


## The world seed (world-generation.md: shown in the game menu so a world can be shared).
static func world_seed(s: GameSession) -> int:
	return s.seed_value


## The player's essentials a screen needs beside StateSnapshot: {id, name, location_id, home_id, realm_label}.
static func player(s: GameSession) -> Dictionary:
	var c: Character = s.player
	if c == null:
		return {}
	return {"id": c.id, "name": c.name, "location_id": str(c.location_id), "home_id": str(c.home_id),
		"realm_label": s.gd.realm_label(c.realm_index, c.stage),
		"portrait": portrait_of(s, {"id": c.id, "gender": c.gender, "age": c.age, "realm_index": c.realm_index, "sect_id": c.sect_id})}


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


## The regions for the map's names and the political map (art bible 7.14; hud.md Map zoom and the political map):
## [{id, name, name_han, centre: [x, y] tile, grid_id (the grid's REGN value), holder_key and holder_name (the holding
## great sect, "" when none)}], every region: names and great sects' holdings are common knowledge (travel-map.md
## rule 14).
static func regions(s: GameSession) -> Array:
	var out: Array = []
	for r in s.db.all("regions"):
		var h: Dictionary = _holder_sect(s, str(r.get("holder", "")))
		var great: bool = str(h.get("kind", "")) == "great"
		out.append({"id": str(r.id), "name": str(r.get("name", "")), "name_han": str(r.get("name_han", "")),
			"centre": Array(r.get("centre_tile", [0, 0])), "grid_id": int(r.get("continent_id", 0)),
			"holder_key": str(h.get("key", "")) if great else "", "holder_name": str(h.get("name", "")) if great else ""})
	return out


## The sect a region's holder names: the holder is the sect's record id once politics runs, its authored key before.
static func _holder_sect(s: GameSession, holder: String) -> Dictionary:
	if holder == "":
		return {}
	var rec: Dictionary = s.db.get_record("sects", holder)
	if not rec.is_empty():
		return rec
	var by_key: Array = s.db.find("sects", func(x): return str(x.get("key", "")) == holder)
	return by_key[0] if not by_key.is_empty() else {}


## A place's authored look, lore and history (assets/data/world_place_lore.json, keyed by the continent place id the
## world record carries): {look, lore, history, special, levels, projects}; {} when the place has none.
## The provinces' records (assets/data/world_provinces.json, branch provinces-v2: land, places, lore and the start
## record; design/ux/province-panel.md). Read-only: the data file, shared, not copied.
static func provinces(s: GameSession) -> Array:
	return s.gd.file("world_provinces").get("provinces", [])


## The province window's view (design/ux/province-panel.md) for province [param province_id]: a copy of its record
## plus region_name, holder_name (the region's great sect), lord_name (a minor sect seated in the province, Provinces
## rule 2), place_ids ({continent id: session place id} for the places the player knows, the links) and art_order
## (continent ids, seat first, to look for a painting). {} for an unknown id. A copy.
static func province(s: GameSession, province_id: int) -> Dictionary:
	var rec: Dictionary = {}
	for r in provinces(s):
		if int(r.get("id", -1)) == province_id:
			rec = Dictionary(r).duplicate(true)
			break
	if rec.is_empty():
		return {}
	var region: Dictionary = {}
	for r in s.db.all("regions"):
		if int(r.get("continent_id", -1)) == int(rec.get("region", 0)):
			region = r
			break
	rec["region_name"] = str(region.get("name", ""))
	var holder: String = str(region.get("holder", ""))
	rec["holder_name"] = str(s.db.get_record("sects", holder).get("name", "")) if holder != "" else ""
	var by_cid: Dictionary = {}
	for p in s.db.all("places"):
		by_cid[int(p.get("continent_id", -1))] = p
	var ids: Dictionary = {}
	var order: Array = []
	if rec.get("seat_place") != null:
		order.append(int(rec.seat_place))
	rec["lord_name"] = ""
	for q in rec.get("places", []):
		if not q.has("id"):
			continue
		var cid: int = int(q.id)
		order.append(cid)
		var p: Dictionary = by_cid.get(cid, {})
		if p.is_empty():
			continue
		if _shown(s, p):
			ids[str(cid)] = str(p.id)
		if str(p.get("kind", "")) == "minor_seat" and str(p.get("sect_id", "")) != "" and str(rec.lord_name) == "":
			rec["lord_name"] = str(s.db.get_record("sects", str(p.sect_id)).get("name", ""))
	rec["place_ids"] = ids
	rec["art_order"] = order
	return rec


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
		"portrait": portrait_of(s, p),
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
	out.traits = traits_view(gd, p.get("npc_traits", {}))
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


## Everything the character sheet shows about the player (design/ux/character-sheet.md), as a copy, Breakdowns
## included ({total, lines} each, so the window never reads the session on hover). Reads only: no rating record is
## created, nothing in the world changes. {} before a world exists.
static func character(s: GameSession) -> Dictionary:
	var c: Character = s.player
	if c == null:
		return {}
	var gd: GameData = s.gd
	var sh: StatSheet = s.sheet()
	var bd := func(b: Breakdown) -> Dictionary: return {"total": b.total, "lines": Array(b.lines())}
	var life: Breakdown = CultivationRules.lifespan(c, gd, sh)
	var sect: Dictionary = s.db.get_record("sects", c.sect_id)
	var res: Dictionary = resources(s)
	var req: float = CultivationRules.level_requirement(c, gd)
	var rate: Dictionary = breakdown(s, "rate")
	var layer: int = Ladder.layer_of_level(gd, c.level)
	var out := {
		"id": c.id, "name": c.name, "alive": c.alive, "death_cause": c.death_cause,
		"realm_label": gd.realm_label(c.realm_index, c.stage), "level": c.level, "layer": layer,
		"portrait": portrait_of(s, c.to_dict()), "gender": c.gender, "traits": traits_view(gd, c.npc_traits),
		"sect": str(sect.get("name", "")), "rank": s.sect_members.rank_name(c.sect_rank) if s.sect_members != null and c.sect_rank != "" else "",
		"age": c.age, "lifespan": life.total, "power": int(res.get("power", -1)), "provisional": bool(res.get("provisional", false)),
		"event_waiting": s.has_pending_event(),
		"cultivation": {"tu_vi": c.tu_vi, "requirement": req, "rate": float(rate.get("total", 0.0)),
			"seasons_to_next": ceili((req - c.tu_vi) / float(rate.total)) if float(rate.get("total", 0.0)) > 0.0 and req > c.tu_vi else -1,
			"held": bool(res.get("held", false)), "top": c.realm_index >= gd.realms().size() - 1 and CultivationRules.is_capped(c, gd),
			"bottleneck": {}},
		"roots": {"tier": c.linh_can.tier_name(gd), "speed": CultivationRules.curve_factor(c, gd), "elements": [], "variants": []},
		"talents": [], "vitals": [], "combat": [], "slots": [], "known": [], "speed_label": "", "gear": [], "crafts": [],
		"dao_do": {"open": c.tree_nodes.size(), "unspent": c.tree_points},
		"fate": {"origin": str(gd.origin(c.origin).get("name", c.origin)), "background": c.background,
			"birth_mode": c.birth_mode, "perks": []},
		"breakdowns": {"rate": rate, "lifespan": bd.call(life)},
	}
	for e in gd.element_cycle():
		var p: float = c.linh_can.purity(e)
		out.roots.elements.append({"id": str(e), "name": gd.element_name(e), "purity": p, "grade": gd.grade_name(p) if p > 0.0 else "",
			"role": str(gd.element(e).get("role_desc", ""))})
	for def in gd.variant_defs():
		if c.linh_can.variants.has(def.id):
			var parts: Array = []
			for l in c.linh_can.variant_lines(gd, str(def.id)):
				parts.append(gd.format_mod(str(l.stat), float(l.value)))
			out.roots.variants.append({"id": str(def.id), "name": gd.element_label(str(def.id)), "purity": c.linh_can.purity(str(def.id)),
				"origin": str(def.get("origin", "")), "lines": parts})
	for def in gd.thien_phu_defs():
		var v: float = sh.effective(def.id, c)
		out.talents.append({"id": str(def.id), "name": str(def.name), "value": v, "grade": gd.grade_name(v), "bonus": int(v) - c.base_stat(def.id)})
		out.breakdowns["talent:" + str(def.id)] = bd.call(sh.explain_thien_phu(def.id, c, def.name))
	var kh: Breakdown = CharacterRules.khi_huyet_max(c, gd, sh)
	var ll: Breakdown = CharacterRules.linh_luc(c, gd, sh)
	var tt: Breakdown = CharacterRules.than_thuc(c, gd, sh)
	var bl: Breakdown = CultivationRules.backlash_chance(c, gd, sh)
	var dd: Breakdown = CharacterRules.dan_doc_decay(c, gd, sh)
	out.breakdowns["health"] = bd.call(kh)
	out.breakdowns["linh_luc"] = bd.call(ll)
	out.breakdowns["than_thuc"] = bd.call(tt)
	out.breakdowns["backlash"] = bd.call(bl)
	out.breakdowns["dan_doc"] = bd.call(dd)
	out.vitals = [
		{"key": "health", "label": "Health (khí huyết)", "value": kh.total * c.vitality, "max": kh.total},
		{"key": "linh_luc", "label": "Linh lực", "value": ll.total},
		{"key": "than_thuc", "label": "Thần thức", "value": tt.total},
		{"key": "vitality", "label": "Vitality", "value": c.vitality * 100.0, "unit": "%"},
		{"key": "dan_doc", "label": "Pill toxicity (đan độc)", "value": c.dan_doc, "note": "pills −%d %%" % int(c.dan_doc)},
		{"key": "backlash", "label": "Heart demon (tâm ma)", "value": c.tam_ma, "note": "backlash %.0f %%" % bl.total},
	]
	var prof: FighterProfile = FighterCompiler.compile(c, gd, s.db, sh)
	if prof != null:
		out.combat = [
			{"key": "ward_pts", "label": "Ward points", "value": prof.ward_pts}, {"key": "ward_layer", "label": "Ward layer", "value": prof.ward_layer},
			{"key": "body_shield", "label": "Body shield share", "value": prof.body_shield}, {"key": "block", "label": "Block", "value": prof.block},
			{"key": "evade", "label": "Evade", "value": prof.evade}, {"key": "crit", "label": "Critical chance", "value": prof.crit},
			{"key": "crit_mult", "label": "Critical multiplier", "value": prof.crit_mult}, {"key": "soul_res", "label": "Soul resistance", "value": prof.soul_res},
			{"key": "hregen", "label": "Health regeneration", "value": prof.hregen},
		]
		var resist: Dictionary = prof.resist
		for k in resist:
			out.combat.append({"key": "resist:" + str(k), "label": "Resistance: " + str(k), "value": float(resist[k])})
	# Công pháp slots (Realms rule 14; CongPhap.set_slot): main, second (with the capability), two arts.
	var has_second: bool = c.has_capability(int(gd.cong_phap_file().second_main_capability))
	var slot_rows: Array = [["main", 0, c.main_tech]]
	if has_second:
		slot_rows.append(["second", 0, c.second_tech])
	for i in c.aux_tech.size():
		slot_rows.append(["aux", i, str(c.aux_tech[i])])
	var tech_view := func(key: String) -> Dictionary:
		var e: Dictionary = c.techniques.get(key, {})
		if e.is_empty():
			return {}
		var d: Dictionary = e.def
		var nxt: int = int(e.layer) + 1
		return {"key": key, "name": str(d.get("name", key)), "kind": str(d.get("tech_kind", "")), "layer": int(e.layer), "layers": int(d.get("layers", 0)),
			"mastery": float(e.get("mastery", 0.0)), "next_cost": CongPhap.layer_cost(gd, d, nxt, c.realm_index) if nxt <= int(d.get("layers", 0)) else -1.0,
			"gated": nxt <= int(d.get("layers", 0)) and CongPhap.gated(c, nxt), "usable": CongPhap.usable(c, d),
			"elements": Array(d.get("elements", d.get("names", []))).duplicate(), "id": str(d.get("id", ""))}
	for row in slot_rows:
		out.slots.append({"slot": row[0], "index": row[1], "tech": tech_view.call(str(row[2]))})
	for key in c.techniques:
		var tv: Dictionary = tech_view.call(str(key))
		tv["slotted"] = c.main_tech == key or c.second_tech == key or c.aux_tech.has(key)
		out.known.append(tv)
	out.speed_label = "%s = x%.2f" % [CongPhap.speed_factor(c, gd).label, float(CongPhap.speed_factor(c, gd).mult)]
	# Gear: the equipped pieces and where EquipSlots puts them.
	var placed: Dictionary = EquipSlots.assign(c, gd, s.db, sh)
	for iid in c.equipped:
		var it: Dictionary = s.db.get_record("items", str(iid))
		if it.is_empty():
			continue
		var slot: String = str(placed.slot_of.get(iid, ""))
		if Array(placed.unslotted).has(iid):
			slot = "unslotted"
		out.gear.append({"id": str(iid), "name": str(it.get("name", iid)), "slot": slot, "text": s.items.describe(it)})
	for k in c.skills:
		out.crafts.append({"id": str(k), "level": int(c.skills[k].get("level", 0))})
	for pid in c.perks:
		var pk: Dictionary = ProgressionEdges.perk(gd, str(pid))
		out.fate.perks.append({"id": str(pid), "name": str(pk.get("name", pid)), "text": str(pk.get("desc", ""))})
	# The bottleneck block (canh-gioi.md UI Requirements), only at great perfection.
	if CultivationRules.at_great_perfection(c, gd) and c.realm_index < gd.realms().size() - 1:
		var odds: Dictionary = Advisor.breakthrough_odds(s)
		var cond: Dictionary = odds.get("condition", {})
		var bar_cost: float = Ladder.bar_cost(gd, c.realm_index)
		out.cultivation.bottleneck = {"tu_vi": c.tu_vi, "bar_cost": bar_cost, "full": CultivationRules.at_bottleneck(c, gd),
			"condition": str(cond.get("text", "")), "condition_met": bool(cond.get("met", true)),
			"pill": str(odds.pill.get("name", "")) if not (odds.pill as Dictionary).is_empty() else "",
			"pill_quality": int(odds.pill.get("quality", 0)) if not (odds.pill as Dictionary).is_empty() else -1,
			"talisman": "used" if c.talisman_used else ("held" if s.talisman_available() else "none"),
			"chance": float(odds.chance), "backlash": bl.total,
			"bare_attempts": c.bare_attempts, "bare_cap": int(gd.ladder().get("bare_attempt_cap", 0))}
		if odds.get("breakdown") != null:
			out.breakdowns["breakthrough"] = bd.call(odds.breakdown)
	return out


## The inventory window's view (design/ux/inventory.md): every item the player owns (planted herbs excepted) with its
## kind, rarity, text, equipped slot, the slots it fits and what it would displace, a comparison with the equipped
## piece, and its verbs (the session's item commands: equip, unequip, nurture, use_item, learn). A copy; reads only.
static func inventory(s: GameSession) -> Dictionary:
	var c: Character = s.player
	if c == null:
		return {}
	var gd: GameData = s.gd
	var sh: StatSheet = s.sheet()
	var placed: Dictionary = EquipSlots.assign(c, gd, s.db, sh)
	var base_total: int = 0
	var holders: Dictionary = {}   # base slot -> [item ids in it]
	for slot in EquipSlots.base_slot_names(gd):
		base_total += EquipSlots.base_slot_size(gd, str(slot))
		holders[str(slot)] = []
	for iid in placed.slot_of:
		var sl: String = str(placed.slot_of[iid])
		if holders.has(sl):
			holders[sl].append(str(iid))
	var out := {"stones": c.linh_thach, "items": [],
		"gear": {"base_used": Array(placed.base).size(), "base_total": base_total, "extra_used": Array(placed.extra).size(),
			"extra_limit": int(placed.limit), "unslotted": Array(placed.unslotted).size()}}
	for it in s.db.items_of(c.id):
		var kind: String = str(it.get("kind", ""))
		if kind == "herb" and int(it.get("plot", -1)) >= 0:
			continue
		var iid: String = str(it.id)
		var equipped: bool = c.equipped.has(iid)
		var row := {"id": iid, "kind": kind, "name": str(it.get("name", iid)), "rarity": ItemRarity.of(gd, it),
			"text": s.items.describe(it), "qty": int(it.get("qty", 1)), "equipped": equipped, "slot": "", "known": false,
			"fact": "", "fits": [], "displaces": {}, "compare": [], "verbs": []}
		match kind:
			"artifact":
				row.fact = "ATK %d · DEF %d" % [int(float(it.get("attack", 0.0))), int(float(it.get("defense", 0.0)))]
				if equipped:
					row.slot = "unslotted" if Array(placed.unslotted).has(iid) else str(placed.slot_of.get(iid, ""))
					row.verbs = [{"id": "unequip", "label": "Unequip", "reason": ""}, {"id": "nurture", "label": "Nurture", "reason": ""}]
				else:
					for slot in EquipSlots.base_slot_names(gd) + [EquipSlots.EXTRA]:
						if not EquipSlots.fits(gd, it, str(slot)):
							continue
						row.fits.append(str(slot))
						if holders.has(str(slot)) and Array(holders[slot]).size() >= EquipSlots.base_slot_size(gd, str(slot)) and not Array(holders[slot]).is_empty():
							row.displaces[str(slot)] = str(s.db.get_record("items", str(holders[slot][0])).get("name", ""))
					row.verbs = [{"id": "equip", "label": "Equip…", "reason": "" if not Array(row.fits).is_empty() else "it fits no slot"}]
					# comparison (Item tooltip pattern): the piece in the first fitting base slot that is taken
					for slot in row.fits:
						if holders.has(slot) and not Array(holders[slot]).is_empty():
							var other: Dictionary = s.db.get_record("items", str(holders[slot][0]))
							row.compare = [{"label": "ATK", "mine": float(it.get("attack", 0.0)), "equipped": float(other.get("attack", 0.0)), "against": str(other.get("name", ""))},
								{"label": "DEF", "mine": float(it.get("defense", 0.0)), "equipped": float(other.get("defense", 0.0)), "against": str(other.get("name", ""))}]
							break
			"cong_phap":
				row.known = c.techniques.has(str(it.get("tech_id", "")))
				row.fact = "%s · %d layers" % [str(it.get("tech_kind", "")), int(it.get("layers", 0))] + (" · known" if row.known else "")
				row.verbs = [{"id": "learn", "label": "Read", "reason": "you already know it" if row.known else ""}]
			"pill":
				row.fact = "x%d · phẩm %d" % [int(it.get("qty", 1)), int(it.get("quality", 0))]
				row.verbs = [{"id": "use_item", "label": "Eat", "reason": "", "confirm": true}]
			"treasure":
				row.fact = str(gd.treasure(str(it.get("template", ""))).get("desc", ""))
				row.verbs = [{"id": "use_item", "label": "Use", "reason": "", "confirm": true}]
			"talisman":
				row.fact = "x%d · used automatically" % int(it.get("qty", 1))
			"herb":
				row.fact = "%s · %.1f năm" % [gd.element_name(str(it.get("element", ""))), float(it.get("age", 0.0))]
			"material":
				row.fact = "x%d" % int(it.get("qty", 1))
		out.items.append(row)
	return out


## The relationships page's view (design/ux/relationships-page.md; npc-relationships.md UI Requirements): every tie
## record of the player with its kinds, strengths (0-100), bands, directions, causes and inherited marks; the cap, the
## held and outside-cap counts, the room left and the record rule 7 would evict next; then the people met with no tie.
## Built from Ties' read functions (they never write, GDD rule 3). A copy.
static func relationships(s: GameSession) -> Dictionary:
	var c: Character = s.player
	if c == null or not Ties.enabled(s.gd):
		return {} if c == null else {"cap": 0, "held": 0, "outside_cap": 0, "room": 0, "next_evict": {}, "ties": [], "met": [], "off": true}
	var gd: GameData = s.gd
	var db: WorldDB = s.db
	var pid: String = c.id
	var cfgd: Dictionary = Ties.cfg(gd)
	var now: int = Ties.now(db)
	var band := func(st: int) -> String:
		var v: int = int(ceil(float(st) / 100.0))
		return "" if v <= 0 else ("faint" if v <= 33 else ("firm" if v <= 66 else "deep"))
	var person := func(id: String) -> Dictionary:
		var p: Dictionary = db.get_record("people", id)
		var at: Dictionary = db.get_record("places", str(p.get("location_id", "")))
		return {"partner_id": id, "partner": str(p.get("name", id)), "alive": bool(p.get("alive", true)),
			"realm": gd.realm_label(int(p.get("realm_index", 0)), int(p.get("stage", 0))) if not p.is_empty() else "",
			"place": str(at.get("name", "")), "attitude": int(p.get("attitude", 0)), "band_word": attitude_band(gd, int(p.get("attitude", 0))),
			"sect": str(db.get_record("sects", str(p.get("sect_id", ""))).get("name", "")), "portrait": portrait_of(s, p) if not p.is_empty() else {}}
	var ties: Array = []
	var outside: int = 0
	var partners: Dictionary = {}
	for rec in db.ties_of(pid):
		var other: String = str(rec.b) if str(rec.a) == pid else str(rec.a)
		partners[other] = true
		if str(rec.get("outside_cap", "")) == pid:
			outside += 1
		var row: Dictionary = person.call(other)
		var kinds: Array = []
		for k in (rec.get("pin", {}) as Dictionary):
			var kk: String = str(k)
			if kk == "su_do":
				kk = "master" if str(rec.pin.su_do) == other else "disciple"
			kinds.append({"kind": kk, "strength": -1, "band": "", "direction": "", "inherited": false, "cause": ""})
		for holder in (rec.get("feud", {}) as Dictionary):
			var f: Dictionary = rec.feud[holder]
			kinds.append({"kind": "feud", "strength": -1, "band": "", "direction": "toward_them" if str(holder) == pid else "toward_you",
				"inherited": bool(f.get("inherited", false)), "cause": str(f.get("cause", ""))})
		var soft: Dictionary = rec.get("soft", {})
		if not soft.is_empty():
			if str(soft.get("kind", "")) == "enmity":
				for holder in (soft.get("dir", {}) as Dictionary):
					var sv: int = Ties.soft_s(cfgd, rec, str(holder), now)
					kinds.append({"kind": "enmity", "strength": int(ceil(sv / 100.0)), "band": band.call(sv),
						"direction": "toward_them" if str(holder) == pid else "toward_you", "inherited": bool(soft.dir[holder].get("inherited", false)),
						"cause": str(soft.dir[holder].get("cause", ""))})
			else:
				var sv2: int = Ties.soft_s(cfgd, rec, pid, now)
				kinds.append({"kind": str(soft.kind), "strength": int(ceil(sv2 / 100.0)), "band": band.call(sv2), "direction": "",
					"inherited": false, "cause": str(soft.get("cause", ""))})
		var debt: Dictionary = rec.get("debt", {})
		if not debt.is_empty():
			var dv: int = Ties.debt_s(cfgd, rec, now)
			kinds.append({"kind": "debt", "strength": int(ceil(dv / 100.0)), "band": band.call(dv),
				"direction": "you_owe" if str(debt.get("debtor", "")) == pid else "they_owe", "inherited": bool(debt.get("inherited", false)),
				"cause": str(debt.get("cause", ""))})
		row["kinds"] = kinds
		row["group"] = "pinned" if not (rec.get("pin", {}) as Dictionary).is_empty() else ("feud" if not (rec.get("feud", {}) as Dictionary).is_empty() else "soft")
		row["favour"] = str(db.get_record("people", str(rec.get("favour", ""))).get("name", "")) if str(rec.get("favour", "")) != "" else ""
		if row.favour != "":
			# rule 15c's favour block; the call-in's state (awaiting, presented, accepted) is not stored in the record yet
			var sib: Dictionary = db.get_record("people", other)
			row["favour_info"] = {"state": "awaiting", "recorded": false, "refuse_delta": int(cfgd.get("delta", {}).get("refuse_delta", 30)),
				"cost": Ties.favour_cost(gd, int(sib.get("realm_index", 0))), "call_seasons": int(cfgd.get("favour_call_seasons", 4))}
		row["strength"] = int(Ties.evict_s(cfgd, rec, now) / 100.0)
		ties.append(row)
	var room: Variant = Ties.room(gd, db, pid, 1 << 30, now)
	var next_evict: Dictionary = {}
	if room is Array and not (room as Array).is_empty():
		var r0: Dictionary = room[0]
		var o0: String = str(r0.b) if str(r0.a) == pid else str(r0.a)
		var soft0: Dictionary = r0.get("soft", {})
		next_evict = {"partner_id": o0, "partner": str(db.get_record("people", o0).get("name", o0)),
			"kind": str(soft0.get("kind", "debt")) if not soft0.is_empty() else "debt", "band": band.call(Ties.evict_s(cfgd, r0, now))}
	var met: Array = []
	for p in db.find("people", func(q): return bool(q.get("met_player", false)) and not bool(q.get("is_player", false))):
		if partners.has(str(p.id)):
			continue
		var m: Dictionary = person.call(str(p.id))
		met.append({"id": str(p.id), "name": m.partner, "realm": m.realm, "place": m.place, "attitude": m.attitude, "band_word": m.band_word, "alive": m.alive,
			"sect": m.sect, "portrait": m.portrait})
	var soft_used: int = Ties.soft_only(db, pid).size()
	var soft_limit: int = Ties.soft_limit(gd, db, pid)
	return {"cap": Ties.cap(gd, db, pid), "held": db.ties_of(pid).size() - outside, "outside_cap": outside,
		"soft_used": soft_used, "soft_limit": soft_limit, "room": maxi(0, soft_limit - soft_used),
		"next_evict": next_evict if soft_used >= soft_limit else {}, "ties": ties, "met": met}


## The rankings window's view (design/ux/rankings.md; power-rankings.md rule 9): [param which] a realm index 0-4, or
## "top" for the Vấn Đỉnh Bảng (Nguyên Anh and Hóa Thần together). Rows are ordered as rule 9 orders them (rating,
## rated fights, age, id; Provisional mixed in by their estimate, user 2026-11-24) but each person is read with RatingService.peek_person, which never
## writes: no panel runs, nobody is marked Stale, no record is created (ADR-0006 decision 1). {on: false} when Power
## Rankings is off.
static func rankings(s: GameSession, which: Variant) -> Dictionary:
	var c: Character = s.player
	if c == null:
		return {}
	if not s.ratings_on():
		return {"on": false, "realm": c.realm_index, "player_realm": c.realm_index}
	var gd: GameData = s.gd
	var realms: Array = RatingService.TOP_REALMS.duplicate() if str(which) == "top" else [clampi(int(which), 0, 4)]
	var title: String = "Vấn Đỉnh Bảng" if str(which) == "top" else str(gd.realm(int(realms[0])).get("name", ""))
	var rows: Array = []
	var me: Dictionary = c.to_dict()
	for p in s.db.all("people"):
		if not bool(p.get("alive", true)) or bool(p.get("is_beast", false)):
			continue
		var is_me: bool = str(p.id) == c.id
		if bool(p.get("is_player", false)) and not is_me:
			continue
		var src: Dictionary = me if is_me else p   # the player as they are now (GameSession.power_of_person)
		if not realms.has(int(src.get("realm_index", 0))):
			continue
		var rec: Dictionary = s.ratings.peek_person(src)
		if str(rec.state) == RatingService.GONE:
			continue
		var stored: Dictionary = s.db.get_record(RatingService.TABLE, str(p.id))
		var r: float = float(rec.base) + float(rec.offset)
		if is_me and not stored.is_empty():
			r = s.ratings.rating_of(c.id)   # the same applied value the top bar's rating box shows (hud.md element 33)
		var sect: Dictionary = s.db.get_record("sects", str(src.get("sect_id", "")))
		rows.append({"id": str(p.id), "name": str(src.get("name", p.id)), "sect": str(sect.get("name", "")),
			"stage": gd.realm_label(int(src.get("realm_index", 0)), int(src.get("stage", 0))), "rating": r,
			"realm": str(gd.realm(int(src.get("realm_index", 0))).get("name", "")),
			"base": float(rec.base), "offset": float(rec.offset), "power": s.ratings.ladder.power_number(r), "state": str(rec.state),
			"n": int(stored.get("n", 0)), "age": float(src.get("age", 0.0)), "you": is_me})
	rows.sort_custom(func(x, y):   # rule 9 (2026-11-24): one order by rating, provisional rows mixed in by their estimate
		if x.rating != y.rating:
			return x.rating > y.rating
		if x.n != y.n:
			return x.n > y.n
		if x.age != y.age:
			return x.age > y.age
		return RatingService.id_less(x.id, y.id))
	var mine: int = 0
	for i in rows.size():
		rows[i]["rank"] = i + 1
		if bool(rows[i].you):
			mine = i + 1
	var b: Dictionary = s.last_rating_batch
	return {"on": true, "which": str(which), "title": title, "realms": realms, "player_realm": c.realm_index, "total": rows.size(),
		"player_rank": mine, "rows": rows,
		"last_batch": {} if b.is_empty() else {"panels": int(b.get("panels", 0)), "queued": int(b.get("queued", 0)),
			"panel_fights": int(b.get("panel_fights", 0)), "pair_fights": int(b.get("pair_fights", 0))}}


## The sect window's view (design/ux/sect-window.md; sects.md rules 19-22): [param sect_id] "" for the player's sect,
## or the sect seated at the player's place when they have none. mode: member (the player's own), loose (no sect),
## other (another sect). Built with SectMembers' pure reads (standing, contribution, promotion_needs, can_join), never
## record(), which creates a record. A copy.
static func sect(s: GameSession, sect_id: String = "") -> Dictionary:
	var c: Character = s.player
	if c == null or s.sect_members == null:
		return {}
	var gd: GameData = s.gd
	var db: WorldDB = s.db
	var sm: SectMembers = s.sect_members
	var here: Dictionary = db.get_record("places", c.location_id)
	var here_sect: String = str(here.get("sect_id", ""))
	var sid: String = sect_id if sect_id != "" else (c.sect_id if c.sect_id != "" else here_sect)
	var mode: String = "member" if sid != "" and sid == c.sect_id else ("loose" if c.sect_id == "" and sect_id == "" else "other")
	var view_sect := func(rec: Dictionary) -> Dictionary:
		if rec.is_empty():
			return {}
		var seat: Dictionary = db.get_record("places", str(rec.get("hq_place_id", "")))
		var head: Dictionary = db.get_record("people", str(rec.get("leader_id", "")))
		var liege: Dictionary = db.get_record("sects", str(rec.get("lord_id", "")))
		var held: Array = []
		for r in db.all("regions"):
			if str(r.get("holder", "")) == str(rec.id):
				held.append(str(r.get("name", "")))
		return {"id": str(rec.id), "name": str(rec.get("name", "")), "name_han": str(rec.get("name_han", "")), "gloss": str(rec.get("gloss", "")),
			"kind": str(rec.get("kind", "")), "alignment_name": str(rec.get("alignment_name", "")), "specialty": str(rec.get("specialty", "")),
			"specialty_name": str(gd.archetype(str(rec.get("specialty", ""))).get("name", rec.get("specialty", ""))),
			"status": str(rec.get("status", "active")), "founded_year": int(rec.get("founded_year", 0)), "fell_year": int(rec.get("fell_year", 0)),
			"cause": str(rec.get("cause", "")), "seat": {"id": str(seat.get("id", "")), "name": str(seat.get("name", ""))},
			"region": str(db.get_record("regions", str(rec.get("region_id", ""))).get("name", "")),
			"head": {"id": str(head.get("id", "")), "name": str(head.get("name", "")),
				"realm_label": gd.realm_label(int(head.get("realm_index", 0)), int(head.get("stage", 0))) if not head.is_empty() else "",
				"portrait": portrait_of(s, head) if not head.is_empty() else {}},
			"seat_art": int(seat.get("continent_id", -1)), "notables": _sect_notables(s, rec),
			"members": Array(rec.get("members", [])).size(),
			"treasury": int(rec.get("treasury", 0)), "levels": Dictionary(rec.get("levels", {})).duplicate(true), "regions": held,
			"liege": {"id": str(liege.get("id", "")), "name": str(liege.get("name", ""))}}
	var srec: Dictionary = db.get_record("sects", sid)
	var out := {"mode": mode, "sect": view_sect.call(srec), "in_sect": c.sect_id != "", "event_waiting": s.has_pending_event(),
		"you": {}, "ladder": [], "next": {}, "join": {}, "others": [], "great": []}
	if mode == "member":
		out.you = {"rank": c.sect_rank, "rank_name": sm.rank_name(c.sect_rank), "contribution": sm.contribution(sid, c.id),
			"standing": sm.standing(sid, c.id), "hostile": sm.hostile(sid, c.id)}
		for r in Array(gd.world_gen().sects.rank_ladder):
			out.ladder.append({"rank": str(r), "name": sm.rank_name(str(r)), "current": str(r) == c.sect_rank})
		var need: Dictionary = sm.promotion_needs(c)
		var gate: Dictionary = need.get("gate", {})
		var g: Array = []
		if not gate.is_empty():
			g.append({"label": "realm", "have": gd.realm(c.realm_index).name, "need": gd.realm(int(gate.realm)).name, "met": c.realm_index >= int(gate.realm)})
			g.append({"label": "contribution", "have": sm.contribution(sid, c.id), "need": int(gate.contribution), "met": sm.contribution(sid, c.id) >= int(gate.contribution)})
			g.append({"label": "standing", "have": int(sm.standing(sid, c.id)), "need": int(float(gate.standing)), "met": sm.standing(sid, c.id) >= float(gate.standing)})
		# the leave preview (rule 22, F10): what each way of leaving does, as the session's leave_sect does it
		var dcfg: Dictionary = sm.config().get("desertion", {})
		var st0: float = sm.standing(sid, c.id)
		var after: float = minf(st0 + SectMembers.standing_step(st0, float(dcfg.get("fall", -40))), float(dcfg.get("ceiling", -30)))
		out["leave_preview"] = {"standing_now": st0, "desert_standing": after, "desert_hostile": after <= float(sm.config().get("hostile_threshold", -30)),
			"hostile_threshold": float(sm.config().get("hostile_threshold", -30))}
		out.next = {"rank": str(need.get("rank", "")), "rank_name": sm.rank_name(str(need.get("rank", ""))) if str(need.get("rank", "")) != "" else "",
			"gate": g, "reachable": not gate.is_empty(), "top": str(need.get("rank", "")) == "", "missing": Array(need.get("missing", [])),
			"cost": int(gate.get("contribution", 0))}
	if c.sect_id == "" and not srec.is_empty():
		var cj: Dictionary = sm.can_join(c, srec)
		out.join = {"here": str(srec.get("hq_place_id", "")) == c.location_id, "ok": bool(cj.ok), "reasons": Array(cj.reasons),
			"standing": sm.standing(sid, c.id)}
	for rec in db.all(SectMembers.TABLE):
		if str(rec.person) == c.id and str(rec.sect) != c.sect_id and float(rec.standing) != 0.0:
			out.others.append({"id": str(rec.sect), "name": str(db.get_record("sects", str(rec.sect)).get("name", rec.sect)),
				"standing": float(rec.standing), "hostile": sm.hostile(str(rec.sect), c.id)})
	if c.sect_id == "":
		for rec in db.all("sects"):
			if str(rec.get("kind", "")) == "great" and str(rec.get("status", "active")) == "active":
				var v: Dictionary = view_sect.call(rec)
				out.great.append({"id": v.id, "name": v.name, "seat": v.seat.name, "region": v.region, "alignment": v.alignment_name})
	return out


## The abode screen's view (design/ux/abode-screen.md; cave-abode.md rule 13 and UI Requirements): the player's home
## (cave abode or residence) with grade, slots, upkeep, the next grade, each work's level, effective level, gain and
## state, the clamp lines, the home-work catalogue with costs and the ceiling at this grade; residences for rent at the
## current place and a claimable abode here. Built with CaveAbode and MapWorks reads, which never write. A copy.
static func abode(s: GameSession) -> Dictionary:
	var c: Character = s.player
	if c == null:
		return {}
	var gd: GameData = s.gd
	var db: WorldDB = s.db
	var sh: StatSheet = s.sheet()
	var home: Dictionary = db.get_record("places", c.home_id)
	var qi: Dictionary = home.get("qi", {})
	var rec: Dictionary = CaveAbode.home_rec(qi, c.id) if not qi.is_empty() else {}
	var here_p: Dictionary = db.get_record("places", c.location_id)
	var out := {"has_home": not rec.is_empty(), "here": c.location_id == c.home_id and not rec.is_empty(),
		"home_place": {"id": str(home.get("id", "")), "name": str(home.get("name", ""))}, "at": str(here_p.get("name", "")),
		"event_waiting": s.has_pending_event(), "works": [], "clamps": [], "catalogue": [], "rent": [], "claim": {}, "density": {}}
	if not rec.is_empty():
		var g: int = CaveAbode.grade_of(rec)
		var is_ab: bool = CaveAbode.is_abode(rec)
		out["kind"] = "abode" if is_ab else "residence"
		out["grade"] = g
		out["slots"] = CaveAbode.slots(gd, g)
		out["used"] = CaveAbode.used(qi, c)
		out["upkeep"] = CaveAbode.grade_upkeep(gd, g, c.realm_index, c.linh_can.purity("tho")) if is_ab else 0
		out["rent_paid"] = int(rec.get("rent", 0)) if not is_ab and not bool(rec.get("own", false)) and not bool(rec.get("origin", false)) else 0
		out["origin"] = bool(rec.get("origin", false))
		out["pending"] = int(rec.get("pending", 0))
		out["unpaid"] = int(rec.get("unpaid", 0))
		out["next"] = {} if not is_ab or g >= 5 else {"grade": g + 1, "cost": CaveAbode.grade_cost(gd, g + 1, c.realm_index),
			"slots": CaveAbode.slots(gd, g + 1), "realm_ok": g + 1 <= CaveAbode.top_grade(gd, c.realm_index)}
		var dormant: Array = rec.get("dormant", [])
		for k in rec.get("order", []):
			var id: String = str(k).substr(2)
			var is_w: bool = str(k).begins_with("w:")
			var lv: int = int(qi.get("layer1", {}).get(c.id, {}).get(id, {}).get("level", 0)) if is_w else int(c.formations.get(id, 0))
			var d: Dictionary = MapWorks.work(gd, id) if is_w else CaveAbode._formation_def(gd, id)
			var wmax: int = int(d.get("max", d.get("max_level", lv)))
			var eff: int = CaveAbode.eff_level(gd, qi, c.id, str(k), lv, wmax)
			var stat: String = str(d.get("stat", ""))
			out.works.append({"key": str(k), "id": id, "kind": "work" if is_w else "array", "name": str(d.get("name", id)), "level": lv, "max": wmax,
				"eff": eff, "dormant": dormant.has(k), "stat": stat, "share": stat == "share",
				"gain": gd.format_mod("density_bonus" if stat == "density" else stat, float(d.get("per_level", 0.0)) * eff) if eff > 0 and stat != "" else "",
				"upkeep": int(d.get("upkeep", 0)) if str(d.get("kind", "")) == "upkept" else 0,
				"element": str(qi.get("layer1", {}).get(c.id, {}).get(id, {}).get("element", "")),
				"next_cost": MapWorks.cost(gd, id, lv + 1) if is_w and lv < wmax else {}})
		var dens: Dictionary = MapWorks.density(gd, qi, c, 0, sh.total("home_array_density"), sh.total("formation_power_pct"))
		# the total is the density the player cultivates at there (place_density: the place plus density_bonus, Formula B's
		# stack); the works' own layer and its clamp lines come from MapWorks.density
		out.density = {"total": s.place_density(c.home_id), "works": float(dens.get("total", 0.0)),
			"lines": Array(dens.get("lines", [])).map(func(l): return str(l))}
		for l in out.density.lines:
			if str(l).contains("clamped"):
				out.clamps.append(str(l))
		var held: Array = CaveAbode.held(qi, c)
		for id in MapWorks.cfg(gd).works:
			var w: Dictionary = MapWorks.work(gd, str(id))
			if int(w.get("layer", 0)) != 1 or held.has("w:%s" % id):
				continue
			var ok: Dictionary = CaveAbode.can_raise(gd, qi, c, "w:%s" % id, 1, int(w.max))
			out.catalogue.append({"id": str(id), "name": str(w.get("name", id)), "stat": str(w.stat), "per_level": float(w.per_level),
				"gain": gd.format_mod("density_bonus" if str(w.stat) == "density" else str(w.stat), float(w.per_level)),
				"next_cost": MapWorks.cost(gd, str(id), 1), "upkeep": int(w.get("upkeep", 0)) if str(w.kind) == "upkept" else 0, "kind": str(w.kind),
				"max": int(w.max), "ceiling": CaveAbode.ceiling(gd, g, int(w.max)), "ok": bool(ok.ok), "reason": str(ok.reason), "share": str(w.stat) == "share"})
	# residences for rent here (Travel & Map rule 34) and a claimable abode here (rule 11)
	var cfgw: Dictionary = MapWorks.cfg(gd)
	if not here_p.get("qi", {}).is_empty() and MapWorks.settled(gd, here_p) and not (c.sect_id != "" and str(here_p.get("sect_id", "")) == c.sect_id):
		var max_g: int = int(cfgw.max_grade.get(str(here_p.get("kind", "")), 1))
		for gr in range(1, max_g + 1):
			var d_res: float = float(LandQi.stacked_density(gd, c, here_p.qi, float(here_p.get("density", 1.0)), 0.0).total) + float(cfgw.furnish_per_grade) * gr
			var rent: int = MapWorks.rent(gd, c.realm_index, d_res)
			var need: int = int(cfgw.grade_realm_min.get(str(gr), 0))
			out.rent.append({"grade": gr, "rent": rent, "price": rent * int(cfgw.buy_seasons), "realm_ok": c.realm_index >= need,
				"realm_need": str(gd.realm(need).get("name", "")), "slots": CaveAbode.slots(gd, gr)})
	if CaveAbode.claimable(here_p, c):
		var ab: Dictionary = here_p.qi.abode
		var kept: Array = []   # rule 11: the permanent works and any upkept one not yet faded pass to the claimant
		var old: Dictionary = here_p.qi.get("layer1", {}).get(str(ab.get("owner", "")), {})
		for wid in old:
			var wd: Dictionary = MapWorks.work(gd, str(wid))
			kept.append({"name": str(wd.get("name", wid)), "level": int(old[wid].get("level", 0)), "upkept": str(wd.get("kind", "")) == "upkept"})
		out.claim = {"grade": int(ab.get("grade", 1)), "after": CaveAbode.grade_after(gd, int(ab.get("grade", 1)), c.realm_index),
			"fee": CaveAbode.claim_fee(gd, c.realm_index), "state": str(ab.get("state", "")), "works": kept}
	return out


## The outliner's view (design/ux/outliner.md; hud.md element 6) for the pinned person ids [param pins]: each pinned
## person's current place (or travelling, died) and attitude band; the home and the sect seat with "here" or the
## travel time; the event waiting. A copy; reads only.
static func outliner(s: GameSession, pins: Array) -> Dictionary:
	var c: Character = s.player
	if c == null:
		return {}
	var db: WorldDB = s.db
	var out := {"people": [], "home": {}, "seat": {}, "event": {}}
	for pid in pins:
		var p: Dictionary = db.get_record("people", str(pid))
		if p.is_empty():
			continue
		var at: Dictionary = db.get_record("places", str(p.get("location_id", "")))
		out.people.append({"id": str(pid), "name": str(p.get("name", pid)), "alive": bool(p.get("alive", true)),
			"place": str(at.get("name", "")), "travelling": false, "attitude": int(p.get("attitude", 0)),
			"band": attitude_band(s.gd, int(p.get("attitude", 0))), "realm": s.gd.realm_label(int(p.get("realm_index", 0)), int(p.get("stage", 0)))})
	var place_row := func(id: String) -> Dictionary:
		var pl: Dictionary = db.get_record("places", id)
		if pl.is_empty():
			return {}
		var here: bool = id == c.location_id
		return {"id": id, "name": str(pl.get("name", "")), "here": here, "seasons": 0.0 if here else route_seasons(s, id)}
	out.home = place_row.call(c.home_id)
	if c.sect_id != "":
		out.seat = place_row.call(str(db.get_record("sects", c.sect_id).get("hq_place_id", "")))
	if s.has_pending_event():
		out.event = {"title": str(s.pending_event.get("title", ""))}
	return out


## The Đạo Đồ view's player state (design/ux/dao-do-view.md): {open (node ids), points, start (node id), starts (the
## root's choices, while no Dao mark is open yet), can_change_start, gate_open, realm}. The map itself is static data
## (DaoDoTree, read by the view). A copy; reads only.
static func dao_do(s: GameSession) -> Dictionary:
	var c: Character = s.player
	if c == null or s.tree == null:
		return {}
	var start: int = s.tree.start_of_character(c)
	var marks: int = c.tree_nodes.filter(func(n): return int(n) != start).size()
	var chaos: Dictionary = {"hon_don": c.linh_can.purity(DaoDoTree.CHAOS)}
	for e in s.gd.element_cycle():
		chaos[str(e)] = c.linh_can.purity(str(e))
	return {"open": c.tree_nodes.map(func(n): return int(n)), "points": c.tree_points, "start": start,
		"starts": s.tree_starts() if marks == 0 else [], "can_change_start": marks == 0,
		"gate_open": s.tree.gate_open(c.linh_can, s.gd), "gate_purity": float(s.gd.tree_config().chaos_gate_purity), "purities": chaos,
		"frontier": s.tree.frontier(c, s.gd), "next_points": TerminalViews.next_points_line(s.gd, c),
		"realm": c.realm_index, "event_waiting": s.has_pending_event()}


## One Đạo Đồ node for the inspector and the route preview: its fields, its lines at the player's root (describe_mods),
## the shortest route to it from the open set plus the pending plan [param pending] (DaoDoTree.path_to on a copy), the
## route's cost and purity gains, whether it can be planned and why not. Reads only: the player is never changed.
static func dao_do_node(s: GameSession, node_id: int, pending: Array = []) -> Dictionary:
	var c: Character = s.player
	if c == null or s.tree == null:
		return {}
	var gd: GameData = s.gd
	var tr0: DaoDoTree = s.tree
	var nd: Dictionary = tr0.node(node_id)
	if nd.is_empty():
		return {}
	var ghost := Character.new()   # the player with the plan opened, for the route (path_to reads nodes, root and realm)
	ghost.id = c.id
	ghost.linh_can = c.linh_can
	ghost.realm_index = c.realm_index
	ghost.tree_nodes = c.tree_nodes.duplicate() + pending.duplicate()
	var open: bool = c.tree_nodes.has(node_id)
	var planned: bool = pending.has(node_id)
	var route: Array = [] if open or planned else tr0.path_to(ghost, gd, node_id)
	var gains: Dictionary = {}
	for nid in route:
		var g: Dictionary = tr0.node(int(nid)).get("grants", {})
		for e in g:
			gains[str(e)] = float(gains.get(str(e), 0.0)) + float(g[e]) * float(gd.tree_config().road_purity)
	var reason: String = ""
	if open:
		reason = "already open"
	elif planned:
		reason = "already in the plan"
	elif not tr0.accessible(c, node_id, gd):
		reason = "the Chaos land opens only to Primordial Chaos or five elements above %s" % LinhCan.fmt(float(gd.tree_config().chaos_gate_purity))
	elif tr0.realm_min(node_id, gd) >= 0 and c.realm_index < tr0.realm_min(node_id, gd):
		reason = "a capability notable needs %s" % str(gd.realm(tr0.realm_min(node_id, gd)).get("name", "?"))
	elif route.is_empty():
		reason = "no route from your open marks"
	var cap: int = int(nd.get("cap", 0))
	# the node's own lines one by one, at the player's root (DaoDoTree.describe_mods' parts, for the PoE-style hover card)
	var scale: float = tr0.node_scale(node_id, c.linh_can, gd)
	var stats: Array = []
	for m in nd.get("mods", []):
		var t: String = gd.format_mod(str(m.stat), float(m.value) * scale)
		if not Array(m.get("scope", [])).is_empty():
			t += " [%s]" % ",".join(PackedStringArray(Array(m.scope)))
		stats.append(t)
	if nd.has("grants"):
		for e in nd.grants:
			stats.append("+%s %s purity" % [LinhCan.fmt(float(nd.grants[e]) * float(gd.tree_config().road_purity)), gd.element_label(str(e))])
	for p in nd.get("pending", []):
		stats.append("(pending: %s)" % str(p.stat))
	var now_p: Dictionary = {}   # each granted element's purity now, for "Hỏa 34 → 36" (dao-do.md UI Requirements)
	for e in gains:
		now_p[e] = c.linh_can.purity(str(e))
	return {"id": node_id, "name": str(nd.get("name", "")), "kind": str(nd.get("kind", "")), "area": str(nd.get("area", "")),
		"gated": bool(nd.get("gated", false)), "cap": cap, "cap_name": str(gd.capability(cap).get("name", "")) if cap > 0 else "",
		"lines": tr0.describe_mods(node_id, c.linh_can, gd), "open": open, "planned": planned, "route": route, "cost": route.size(),
		"gains": gains, "purity_now": now_p,
		"route_lines": route.slice(0, 12).map(func(n): return "%s: %s" % [str(tr0.node(int(n)).get("name", "#%d" % int(n))) if str(tr0.node(int(n)).get("name", "")) != "" else str(tr0.node(int(n)).get("kind", "")), tr0.describe_mods(int(n), c.linh_can, gd)]),
		"stats": stats, "scale": scale, "effect": str(nd.get("effect", "")),
		"effect_rule": str(effect_of(gd, "eff:" + str(nd.get("effect", ""))).get("rule", "")) if str(nd.get("effect", "")) != "" else "",
		"cap_desc": str(gd.capability(cap).get("desc", "")) if cap > 0 else "", "closes": str(nd.get("closes", "")),
		"ok": reason == "", "reason": reason}


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


## A sect's notable members for its window (the round-3 mock-up): the head, then the elders and the highest ranks after,
## up to [code]ui_windows.json sect.notables[/code] (default 4), each with rank, realm and portrait fields.
static func _sect_notables(s: GameSession, rec: Dictionary) -> Array:
	var ladder: Array = Array(s.gd.world_gen().sects.rank_ladder)
	var rows: Array = []
	for pid in Array(rec.get("members", [])):
		var p: Dictionary = s.db.get_record("people", str(pid))
		if p.is_empty() or not bool(p.get("alive", true)):
			continue
		rows.append(p)
	rows.sort_custom(func(a, b): return ladder.find(str(a.get("sect_rank", ""))) > ladder.find(str(b.get("sect_rank", ""))) 		or (ladder.find(str(a.get("sect_rank", ""))) == ladder.find(str(b.get("sect_rank", ""))) and int(a.get("realm_index", 0)) > int(b.get("realm_index", 0))))
	var n: int = int(s.gd.file("ui_windows").get("sect", {}).get("notables", 4))
	var out: Array = []
	for p in rows.slice(0, n):
		out.append({"id": str(p.id), "name": str(p.get("name", "")), "rank": s.sect_members.rank_name(str(p.get("sect_rank", ""))) if s.sect_members != null else "",
			"realm_label": s.gd.realm_label(int(p.get("realm_index", 0)), int(p.get("stage", 0))), "portrait": portrait_of(s, p)})
	return out


## A person's traits (NPC Traits #42, assets/data/traits.json) for a window: in group order (personality, calling,
## fate, gained), each {group, id, name, name_vi, icon (res:// path of its medallion, "" when none), lines (the boon,
## cost and rows as stat lines)}. [param nt] is a record's npc_traits. A copy.
static func traits_view(gd: GameData, nt: Dictionary) -> Array:
	var tr_data: Dictionary = gd.file("traits")
	var out: Array = []
	for group in ["personality", "calling", "fate", "gained"]:
		var ids: Array = Array(nt.get(group, [])) if nt.get(group) is Array else ([nt.get(group)] if str(nt.get(group, "")) != "" else [])
		var table: Array = Array(tr_data.get("callings" if group == "calling" else group, []))
		for tid in ids:
			var rec: Dictionary = {}
			for r in table:
				if str(r.get("id", "")) == str(tid):
					rec = r
			var lines: Array = []
			for key in ["boon", "rows", "cost"]:
				for m in Array(rec.get(key, [])):
					lines.append(gd.format_mod(str(m.get("stat", "")), float(m.get("value", 0.0))))
			var icon: String = "res://assets/icons/traits/%s.png" % str(tid)
			out.append({"group": group, "id": str(tid), "name": str(rec.get("name", tid)), "name_vi": str(rec.get("name_vi", "")),
				"icon": icon if ResourceLoader.exists(icon) else "", "lines": lines})
	return out


## What a portrait is chosen from (PortraitPicker, user decision 2026-11-24 "Set + special characters"), for a person
## record (or the player's to_dict): the cast key when the person is one of the fixed cast; else sex, how old they look
## (age over the realm's lifespan: a cultivator ages slowly), the dress (a great sect's own, a minor sect's alignment, or
## loose) and the tier (Kết Đan and up wear rich robes). A copy.
static func portrait_of(s: GameSession, p: Dictionary) -> Dictionary:
	return portrait_fields(s.gd, p, s.db.get_record("sects", str(p.get("sect_id", ""))))


## [method portrait_of] from the data alone: [param p] a person record, [param sect] their sect record ({} when loose).
static func portrait_fields(gd: GameData, p: Dictionary, sect: Dictionary) -> Dictionary:
	var ri: int = int(p.get("realm_index", 0))
	var life: float = float(gd.realm(ri).get("lifespan", 120.0))
	var frac: float = float(p.get("age", 16.0)) / maxf(1.0, life)
	var look: String = "youth" if frac < 0.3 else ("elder" if frac > 0.75 else "prime")
	var dress: String = "loose"
	if not sect.is_empty():
		dress = str(sect.get("key", "")) if str(sect.get("kind", "")) == "great" else "minor_" + str(sect.get("alignment", "trung"))
	return {"id": str(p.get("id", "")), "cast": str(p.get("cast_key", "")), "sex": "f" if str(p.get("gender", "male")) == "female" else "m",
		"look": look, "dress": dress, "tier": "high" if ri >= 2 else "low", "alive": bool(p.get("alive", true))}


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
