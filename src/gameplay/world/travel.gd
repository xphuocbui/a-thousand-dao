class_name Travel
extends RefCounted

## Travel along the world's links (design/gdd/travel-map.md rules 10-12, Formula D; user decision 2026-11-20: go to
## any reachable place by the quickest path, part seasons count). A link's "seasons" is Formula D's time at base
## speed (cost / v_mode, set when the world is built); a character's travel_speed_pct divides it, never below
## travel_speed_floor. A trip of T seasons spends ceil(T) seasons; the share of the last season not spent travelling
## is spent cultivating at the destination (Formula D leftover_cultivation, at partial_season_efficiency).
##
## Usage:
## [codeblock]
## var r: Dictionary = Travel.quickest(db, here_id, dest_id, Travel.speed_factor(gd, sheet.total("travel_speed_pct")))
## if not r.is_empty(): print(r.path, " ", r.seasons)
## [/codeblock]

const RULES_FILE := "travel_rules"


## Formula D's speed factor max(f_min, 1 + tsp / 100).
static func speed_factor(gd: GameData, travel_speed_pct: float) -> float:
	var f_min: float = float(gd.file(RULES_FILE).get("travel_speed_floor", 0.25))
	return maxf(f_min, 1.0 + travel_speed_pct / 100.0)


## The quickest path from [param from_id] to [param to_id] over the places' links (Dijkstra on link seasons), at
## speed factor [param f]: {path: [place ids, from first], seasons: T, hops}; {} when unreachable or the same place.
static func quickest(db: WorldDB, from_id: String, to_id: String, f: float = 1.0) -> Dictionary:
	if from_id == to_id or not db.has_record("places", to_id) or not db.has_record("places", from_id):
		return {}
	var dist := {from_id: 0.0}
	var prev := {}
	var done := {}
	var frontier: Array = [[0.0, from_id]]
	while not frontier.is_empty():
		var best: int = 0
		for i in frontier.size():
			if float(frontier[i][0]) < float(frontier[best][0]):
				best = i
		var cur: Array = frontier[best]
		frontier.remove_at(best)
		var id: String = str(cur[1])
		if done.has(id):
			continue
		done[id] = true
		if id == to_id:
			break
		for l in db.get_record("places", id).get("links", []):
			var to: String = str(l.to)
			var d: float = float(cur[0]) + float(l.seasons)
			if not dist.has(to) or d < float(dist[to]) - 1e-9:
				dist[to] = d
				prev[to] = id
				frontier.append([d, to])
	if not dist.has(to_id):
		return {}
	var path: Array = [to_id]
	while path[0] != from_id:
		path.push_front(prev[path[0]])
	return {"path": path, "seasons": float(dist[to_id]) / maxf(f, 0.0001), "hops": path.size() - 1}


## Seasons a trip of [param t] seasons spends (at least one), and the share u of the last season spent travelling.
static func split(t: float) -> Dictionary:
	var n: int = maxi(1, int(ceil(t - 1e-9)))
	var u: float = clampf(t - float(n - 1), 0.0, 1.0)
	return {"seasons": n, "last_share": u}
