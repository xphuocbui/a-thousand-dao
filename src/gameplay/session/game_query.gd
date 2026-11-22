class_name GameQuery
extends RefCounted
## The read-only queries a shipped frontend uses beside GameSession's read methods, StateSnapshot and Advisor
## (ADR-0006 decision 3). Static functions that take the session and return deep copies built for the purpose, never a
## World DB record or a live service object, and never change the world (tests/unit/session/session_reads_test.gd).
## A frontend calls them only while no session job runs (decision 6). They grow screen by screen.


## The clock: {year, season, index, label}.
static func clock(s: GameSession) -> Dictionary:
	return {"year": s.year, "season": s.season, "index": s.season_index(), "label": s.clock_label()}


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


## Display lines for the stand-in character sheet (until the character window is designed).
static func sheet_lines(s: GameSession) -> Array:
	return TerminalViews.sheet(s, TerminalIO.new())


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
