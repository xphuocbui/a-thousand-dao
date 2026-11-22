class_name BubbleModel
extends RefCounted
## Which area bubbles the map shows (design/ux/hud.md, Map bubbles, element 32): pure rules, no scene and no session,
## so tests need nothing else. The screen gathers what the player knows about each place and passes it in.

## Bubble kinds in their fixed order within a place (the spec's kinds; "work" is missions and bounties, the quests
## bubble until the quest system exists).
const KINDS := ["market", "sect", "work", "people", "explore"]


## The bubble kinds at one known place: {kind: count}. [param place] is the World DB place record; [param is_here] is
## whether the player is there; [param people_here] counts people the player has met who are there now (only known
## at the player's own place: no last-seen data exists yet, so elsewhere a people bubble never shows);
## [param can_work] is whether a mission can be taken there; [param explore_kinds] lists the place kinds that are
## explore sites (ui_hud.json "bubbles" "explore_kinds").
static func kinds_for(place: Dictionary, is_here: bool, people_here: int, can_work: bool, explore_kinds: Array) -> Dictionary:
	var out: Dictionary = {}
	if bool(place.get("market", false)):
		out["market"] = 1
	if str(place.get("sect_id", "")) != "":
		out["sect"] = 1
	if can_work:
		out["work"] = 1
	if is_here and people_here > 0:
		out["people"] = people_here
	if str(place.get("kind", "")) in explore_kinds:
		out["explore"] = 1
	return out


## Seasons of travel from [param here_id] to every place reachable within [param max_seasons] over [param links]
## (place id -> [{to, seasons}]), moving only through places in [param known] (place id -> anything). The start is 0.
static func distances(here_id: String, links: Dictionary, known: Dictionary, max_seasons: float) -> Dictionary:
	var dist: Dictionary = {here_id: 0.0}
	var open: Array = [here_id]
	while not open.is_empty():
		# pop the nearest open place (ties by id, so the result never depends on dictionary order)
		var best_i: int = 0
		for i in range(1, open.size()):
			var a: String = open[i]
			var b: String = open[best_i]
			if float(dist[a]) < float(dist[b]) or (is_equal_approx(float(dist[a]), float(dist[b])) and a < b):
				best_i = i
		var cur: String = open[best_i]
		open.remove_at(best_i)
		for l in links.get(cur, []):
			var to: String = str(l.get("to", ""))
			if not known.has(to):
				continue
			var d: float = float(dist[cur]) + float(l.get("seasons", 0.0))
			if d > max_seasons + 1e-9:
				continue
			if not dist.has(to) or d < float(dist[to]) - 1e-9:
				dist[to] = d
				if not open.has(to):
					open.append(to)
	return dist


## The bubbles to show: [{place_id, kind, count, seasons}], nearest first (route seasons, then place id, then the
## kind order). [param kinds_by_place] is place id -> {kind: count}; [param dist] comes from [method distances].
## At most [param cap] bubbles, except that the current place's bubbles ([param here_id]) are never dropped.
static func build(kinds_by_place: Dictionary, dist: Dictionary, here_id: String, cap: int) -> Array:
	var ids: Array = []
	for id in kinds_by_place:
		if dist.has(id):
			ids.append(str(id))
	ids.sort_custom(func(a: String, b: String) -> bool:
		if a == here_id or b == here_id:
			return a == here_id and b != here_id
		var da: float = float(dist[a])
		var db_: float = float(dist[b])
		if not is_equal_approx(da, db_):
			return da < db_
		return a < b)
	var out: Array = []
	for id in ids:
		var kinds: Dictionary = kinds_by_place[id]
		for k in KINDS:
			if not kinds.has(k):
				continue
			if id != here_id and out.size() >= cap:
				return out
			out.append({"place_id": id, "kind": k, "count": int(kinds[k]), "seasons": float(dist[id])})
	return out


## True when clicking [param kind] at the player's own place opens a window at once (a free action); false when it
## opens the focus comparison (a season action). Elsewhere every bubble opens the comparison with Travel preselected.
static func is_free_here(kind: String) -> bool:
	return kind in ["market", "sect", "people"]
