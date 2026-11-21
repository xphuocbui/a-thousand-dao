class_name NpcTraits
extends RefCounted

## NPC Traits (design/gdd/npc-traits.md, catalogue design/gdd/npc-traits-catalogue.md; data assets/data/traits.json):
## every person holds 3 personality traits (never both sides of a set), 1 calling, up to 2 fate-given and up to 2 gained
## traits. The record is [code]npc_traits[/code] on the person: {personality: [ids], calling: id, fate: [ids],
## gained: [{id, expires, target}]}; everything else is read from the catalogue. This class rolls a person's traits
## (F4, keyed on the person id so a reload rolls the same), maps the cast's authored trait names to ids, and sums a
## leader's Sects F15 pulls (stance dials, boldness, war and rebel odds, weariness, invest share, the head's draw,
## loyalty, pact line, alignment factor, attitude speed and bias), which SectPolitics, SectEconomy and WorldMoney read.
## Stat rows, choice weights (F2), opinion (F3) and gained traits from events wait for their readers.

const FILE := "traits"


static var _cache: Dictionary = {}


## The catalogue indexed: {by_id: {id: trait}, kind: {id: kind}, by_name: {lower name: id}}.
static func catalogue(gd: GameData) -> Dictionary:
	var key: int = gd.get_instance_id()
	if _cache.has(key):
		return _cache[key]
	var f: Dictionary = gd.file(FILE)
	var by_id := {}
	var kind := {}
	var by_name := {}
	for k in ["personality", "callings", "fate", "gained"]:
		for t in f.get(k, []):
			by_id[str(t.id)] = t
			kind[str(t.id)] = k
			by_name[str(t.name).to_lower()] = str(t.id)
	var out := {"by_id": by_id, "kind": kind, "by_name": by_name, "file": f}
	_cache[key] = out
	return out


## F4: a person's traits from a stream keyed on [param key] (their id): 3 personality draws by weight, each removing the
## drawn trait's whole set; 1 calling by the archetype's weights (sect members also weigh the leader callings); 0-2
## fate-given traits (P 0.90 / 0.09 / 0.01), the second never the first's pair.
static func roll(gd: GameData, key: String, archetype: String, sect_member: bool) -> Dictionary:
	var cat := catalogue(gd)
	var f: Dictionary = cat.file
	var r := RandomNumberGenerator.new()
	r.seed = RngUtils.stable_hash("traits:" + key)
	var pool: Array = Array(f.get("personality", [])).duplicate()
	var pers: Array = []
	for i in 3:
		if pool.is_empty():
			break
		var t: Dictionary = RngUtils.weighted_pick(r, pool.map(func(x): return {"id": str(x.id), "set": int(x.set), "weight": float(x.get("weight", 1.0))}))
		pers.append(str(t.id))
		pool = pool.filter(func(x): return int(x.set) != int(t.set))
	var cw: Dictionary = Dictionary(f.get("calling_weights", {}).get(archetype, f.get("calling_weights", {}).get("tan_tu", {}))).duplicate()
	if sect_member:
		for c in f.get("calling_weights", {}).get("sect_member", {}):
			cw[c] = float(cw.get(c, 0.0)) + float(f.calling_weights.sect_member[c])
	var calling: String = ""
	if not cw.is_empty():
		var opts: Array = []
		var keys: Array = cw.keys()
		keys.sort()
		for c in keys:
			opts.append({"id": str(c), "weight": float(cw[c])})
		calling = str(RngUtils.weighted_pick(r, opts).id)
	var fate: Array = []
	var u: float = r.randf()
	var n_fate: int = 2 if u < 0.01 else (1 if u < 0.10 else 0)
	var fpool: Array = Array(f.get("fate", [])).duplicate()
	for i in n_fate:
		if fpool.is_empty():
			break
		var ft: Dictionary = RngUtils.pick(r, fpool)
		fate.append(str(ft.id))
		fpool = fpool.filter(func(x): return str(x.pair) != str(ft.pair))
	return {"personality": pers, "calling": calling, "fate": fate, "gained": []}


## The cast's authored traits ({personality: [names], calling: name, fate_given: [names]}) as ids.
static func from_authored(gd: GameData, authored: Dictionary) -> Dictionary:
	var cat := catalogue(gd)
	var ids := func(names: Array) -> Array:
		var out: Array = []
		for n in names:
			var id: String = str(cat.by_name.get(str(n).to_lower(), ""))
			if id != "":
				out.append(id)
		return out
	var calling: String = str(cat.by_name.get(str(authored.get("calling", "")).to_lower(), ""))
	return {"personality": ids.call(authored.get("personality", [])), "calling": calling,
		"fate": ids.call(authored.get("fate_given", [])), "gained": []}


## Rules 11-13 and F6: grants (or refreshes) gained trait [param id] to [param person] in season [param now], expiring
## fade_seasons later. A held one is refreshed; an opposed gained trait is replaced when the new one's grade is at least
## its own; with both slots full the oldest of grade at most the new one's goes; else the grant is refused. Returns
## "granted", "refreshed", "replaced" or "refused".
static func grant(gd: GameData, person: Dictionary, id: String, now: int, target: String = "") -> String:
	var cat := catalogue(gd)
	var t: Dictionary = cat.by_id.get(id, {})
	if t.is_empty() or str(cat.kind.get(id, "")) != "gained":
		return "refused"
	var fade: int = int(gd.file(FILE).get("fade_seasons", 40))
	if not person.has("npc_traits"):
		person["npc_traits"] = {"personality": [], "calling": "", "fate": [], "gained": []}
	var g: Array = person.npc_traits.get("gained", [])
	var rank := func(x: String) -> int: return 1 if str(cat.by_id.get(x, {}).get("grade", "small")) == "notable" else 0
	for e in g:
		if str(e.id) == id:
			e["expires"] = now + fade
			return "refreshed"
	for i in g.size():
		var e: Dictionary = g[i]
		if str(e.id) == str(t.get("opposed", "")) or str(cat.by_id.get(str(e.id), {}).get("opposed", "")) == id:
			if int(rank.call(id)) >= int(rank.call(str(e.id))):
				g[i] = {"id": id, "expires": now + fade, "target": target}
				person.npc_traits["gained"] = g
				return "replaced"
			return "refused"
	if g.size() < 2:
		g.append({"id": id, "expires": now + fade, "target": target})
		person.npc_traits["gained"] = g
		return "granted"
	var oldest: int = -1
	for i in g.size():
		if int(rank.call(str(g[i].id))) <= int(rank.call(id)) and (oldest < 0 or int(g[i].expires) < int(g[oldest].expires)):
			oldest = i
	if oldest < 0:
		return "refused"
	g[oldest] = {"id": id, "expires": now + fade, "target": target}
	person.npc_traits["gained"] = g
	return "replaced"


## Rule 12: removes the gained traits of [param person] that expire by season [param now].
static func fade(person: Dictionary, now: int) -> void:
	if not person.has("npc_traits"):
		return
	var g: Array = person.npc_traits.get("gained", [])
	person.npc_traits["gained"] = g.filter(func(e): return int(e.get("expires", 0)) > now)


## Every trait id a person holds (personality, calling, fate-given, gained).
static func held(person: Dictionary) -> Array:
	var t: Dictionary = person.get("npc_traits", {})
	var out: Array = Array(t.get("personality", [])).duplicate()
	if str(t.get("calling", "")) != "":
		out.append(str(t.calling))
	out.append_array(t.get("fate", []))
	for g in t.get("gained", []):
		out.append(str(g.get("id", "")) if g is Dictionary else str(g))
	return out


## Sects F15: a person's summed pulls. dials {dial: Σ}, dial_when_thriving {dial: Σ}, war_odds and rebel_odds (the
## lowest of the traits' values, which replaces the default; absent when no trait gives one), weariness Σ (and
## weariness_truce Σ, the part that counts for accepting a truce only), half_loss_weariness, invest_share and draw_mult
## (the trait's value; absent when none), loyalty
## Σ, pact_line (the lowest), alignment_factor (the product), attitude_speed {hostile, friendly}, bias_from_all Σ (regard
## bias_all and the attitude-bias pull), bold, never_bold, needs_halved, fickle, first_track, abs_sum (the dial pulls'
## absolute sum, F6's boldness test).
static func pulls(gd: GameData, person: Dictionary) -> Dictionary:
	var cat := catalogue(gd)
	var out := {"dials": {}, "dial_when_thriving": {}, "war_odds": INF, "rebel_odds": INF, "weariness": 0.0, "weariness_truce": 0.0,
		"half_loss_weariness": false, "loyalty": 0.0,
		"pact_line": INF, "alignment_factor": 1.0, "attitude_speed": {"hostile": 1.0, "friendly": 1.0}, "bias_from_all": 0.0,
		"bold": false, "never_bold": false, "needs_halved": false, "fickle": false, "first_track": "", "abs_sum": 0.0,
		"bias_dir": {"rivals": 0.0, "opposite": 0.0, "from_righteous": 0.0}}
	for id in held(person):
		var t: Dictionary = cat.by_id.get(str(id), {})
		if t.is_empty():
			continue
		var rg: Dictionary = t.get("regard", {})
		out.bias_from_all = float(out.bias_from_all) + float(rg.get("bias_all", 0.0))
		if rg.has("bias_dir"):   # F3's directed regard: to rivals, to the opposite alignment, or from righteous people
			var tw: String = str(rg.get("toward", ""))
			var slot: String = "rivals" if tw.contains("rival") else ("opposite" if tw.contains("opposite") else ("from_righteous" if tw.contains("righteous") else ""))
			if slot != "":
				out.bias_dir[slot] = float(out.bias_dir[slot]) + float(rg.bias_dir)
		var p: Dictionary = t.get("pulls", {})
		for d in p.get("dials", {}):
			out.dials[d] = float(out.dials.get(d, 0.0)) + float(p.dials[d])
			out.abs_sum = float(out.abs_sum) + absf(float(p.dials[d]))
		for d in p.get("dial_when_thriving", {}):
			out.dial_when_thriving[d] = float(out.dial_when_thriving.get(d, 0.0)) + float(p.dial_when_thriving[d])
		if p.has("war_odds"):
			out.war_odds = minf(float(out.war_odds), float(p.war_odds))
		if p.has("rebel_odds"):
			out.rebel_odds = minf(float(out.rebel_odds), float(p.rebel_odds))
		if bool(p.get("weariness_for_truce", false)):
			out.weariness_truce = float(out.weariness_truce) + float(p.get("weariness", 0.0))
		else:
			out.weariness = float(out.weariness) + float(p.get("weariness", 0.0))
		if bool(p.get("half_loss_weariness", false)):
			out.half_loss_weariness = true
		out.loyalty = float(out.loyalty) + float(p.get("loyalty", 0.0))
		if p.has("pact_line") and str(p.get("pact_line_scope", "")) == "":
			out.pact_line = minf(float(out.pact_line), float(p.pact_line))
		out.alignment_factor = float(out.alignment_factor) * float(p.get("alignment_factor", 1.0))
		if p.has("attitude_speed"):
			out.attitude_speed[str(p.get("attitude_speed_when", "hostile"))] = float(p.attitude_speed)
		out.bias_from_all = float(out.bias_from_all) + float(p.get("attitude_bias_from_all", 0.0))
		for k in ["bold", "never_bold", "needs_halved", "fickle"]:
			if bool(p.get(k, false)):
				out[k] = true
		if p.has("invest_share"):
			out["invest_share"] = float(p.invest_share)
		if p.has("draw_mult"):
			out["draw_mult"] = float(p.draw_mult)
		if str(p.get("first_track", "")) != "" and str(out.first_track) == "":
			out.first_track = str(p.first_track)
	if float(out.war_odds) == INF:
		out.erase("war_odds")
	if float(out.rebel_odds) == INF:
		out.erase("rebel_odds")
	return out


## A sect's leader's pulls ({} pulls of nobody when it has no living leader).
static func leader_pulls(gd: GameData, db: WorldDB, sect: Dictionary) -> Dictionary:
	var lead: Dictionary = db.get_record("people", str(sect.get("leader_id", "")))
	if lead.is_empty() or not bool(lead.get("alive", false)):
		return pulls(gd, {})
	return pulls(gd, lead)
