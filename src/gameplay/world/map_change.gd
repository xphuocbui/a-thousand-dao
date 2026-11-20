class_name MapChange
extends RefCounted

## How the map changes (design/gdd/travel-map.md rule 26), worked out once a season or when an event calls it:
## - secret realms on cycles: a realm with a cycle {every_seasons, open_seasons, rumour_lead} opens for open_seasons
##   every every_seasons, its phase offset rolled per game (keyed on the seed and the realm's name, so the entrance
##   never moves but its timing is not guessable); a rumour runs rumour_lead seasons ahead of each opening;
## - territory changes hands: [method transfer] moves a place or a region to a sect and records it;
## - great battles scar the land: [method scar] changes a place's density and shares for good and records it.
## Sites thinning and recovering is MapProduction's (rules 21-22). The authored terrain never changes otherwise.
##
## Usage:
## [codeblock]
## var news: Array = MapChange.season(db, year, season, seed)
## MapChange.transfer(db, region_id, sect_id, year, season, "the War of the Frost Coast")
## [/codeblock]


## The season count since year 0 (4 seasons a year).
static func abs_season(year: int, season: int) -> int:
	return year * 4 + season


## Whether a place with a cycle is open at [param t] (an absolute season), and the seasons until its next opening.
static func realm_state(place: Dictionary, t: int, game_seed: String) -> Dictionary:
	var cy: Dictionary = place.get("cycle", {})
	if cy.is_empty():
		return {"cycled": false, "open": true, "next_open_in": 0}
	var every: int = maxi(1, int(cy.get("every_seasons", 120)))
	var offset: int = RngUtils.stable_hash("%s:cycle:%s" % [game_seed, str(place.name)]) % every
	var phase: int = posmod(t + offset, every)
	var open_n: int = int(cy.get("open_seasons", 4))
	return {"cycled": true, "open": phase < open_n, "next_open_in": 0 if phase < open_n else every - phase,
		"closes_in": open_n - phase if phase < open_n else 0}


## One season of change: secret realms open, close and are rumoured. Returns the news lines.
static func season(db: WorldDB, year: int, season_i: int, game_seed: String) -> Array:
	var news: Array = []
	var t: int = abs_season(year, season_i)
	for p in db.all("places"):
		if not p.has("cycle"):
			continue
		var st: Dictionary = realm_state(p, t, game_seed)
		var was: bool = bool(p.get("open", false))
		p["open"] = bool(st.open)
		var lead: int = int(p.cycle.get("rumour_lead", 4))
		if not st.open and int(st.next_open_in) == lead:
			news.append("  [tin đồn] Người ta đồn rằng cổng %s sẽ mở sau %d mùa." % [p.name, lead])
		elif st.open and not was:
			db.log_event(year, season_i, "realm_opened", "Cổng %s mở." % p.name, [], [str(p.id)], [], {"cycle": true})
			news.append("  [tin tức] Cổng %s đã mở (%d mùa)." % [p.name, int(st.closes_in)])
		elif was and not st.open:
			news.append("  [tin tức] Cổng %s đã đóng." % p.name)
	return news


## Moves a place or a region (by World DB id) to the sect [param sect_id] and records it (rule 26). A region moves
## its places with it. Returns false for an unknown id.
static func transfer(db: WorldDB, target_id: String, sect_id: String, year: int, season_i: int, cause: String) -> bool:
	var table: String = db.table_of(target_id)
	if table != "places" and table != "regions":
		return false
	var rec: Dictionary = db.get_record(table, target_id)
	if rec.is_empty():
		return false
	var before: String = str(rec.get("holder", ""))
	rec["holder"] = sect_id
	var places: Array = [target_id] if table == "places" else Array(rec.get("places", []))
	for pid in places:
		var p: Dictionary = db.get_record("places", str(pid))
		p["holder"] = sect_id
		p["territory"] = sect_id
	db.log_event(year, season_i, "territory_change", "%s về tay %s (%s)." % [rec.get("name", target_id), db.get_record("sects", sect_id).get("name", sect_id), cause],
		[sect_id] + ([before] if before != "" else []), places.map(func(x): return str(x)), [], {"from": before, "to": sect_id, "cause": cause})
	return true


## A battle scar (rule 26): changes place [param place_id]'s land density by [param d_density] and adds [param push]
## points to its shares (renormalised to 100), for good; the change is stored on the place and recorded.
static func scar(db: WorldDB, place_id: String, d_density: float, push: Dictionary, year: int, season_i: int, cause: String) -> bool:
	var p: Dictionary = db.get_record("places", place_id)
	if p.is_empty() or not p.has("qi"):
		return false
	p["density"] = clampf(float(p.density) + d_density, 0.3, 2.4)
	var sh: Dictionary = p.qi.get("shares", {})
	for e in push:
		sh[e] = maxf(0.0, float(sh.get(e, 0.0)) + float(push[e]))
	var tot: float = 0.0
	for e in sh:
		tot += float(sh[e])
	if tot > 0.0:
		for e in sh:
			sh[e] = float(sh[e]) * 100.0 / tot
	p["scars"] = Array(p.get("scars", [])) + [{"year": year, "density": d_density, "push": push, "cause": cause}]
	if p.has("site"):
		p.site["scar"] = clampf(float(p.site.get("scar", 1.0)) * (1.0 + d_density), 0.0, 1.5)
	db.log_event(year, season_i, "scar", "Đất ở %s đổi khác sau %s." % [p.name, cause], [], [place_id], [], {"density": d_density, "push": push})
	return true
