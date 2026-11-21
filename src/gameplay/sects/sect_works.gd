class_name SectWorks
extends RefCounted

## Sects develop their land (design/gdd/travel-map.md rules 31-33, Formula J; design/gdd/sects.md rule 8's Holdings and
## F2's work_max): a sect builds layer-2 works on the places it holds, up to work_max = ⌈Holdings / 2⌉ levels each:
## worked mines (upkept, +production) and vein dressing (permanent, +production) on its sites, and the great array and
## spirit grove (+density) at its seat. The works are paid from the investment the treasury rule sends to Holdings
## (Regional Economy Formula H), so they add no spender of their own: the cash share burns as works and the goods share
## is met in kind. Each season the upkept works cost their upkeep (cash burned, goods in kind; the goods count as
## works_due demand in the markets), and a work unpaid for fade_seasons loses a level. Values are map_works.json's
## (the works and their prices) and its [code]sects[/code] block.
##
## Usage:
## [codeblock]
## var spent := SectWorks.build_best(gd, db, sect, budget)   # from the Holdings investment, before its level rises
## SectWorks.upkeep(gd, db, money)                           # each season, with the sects' upkeep
## [/codeblock]


static func _cfg(gd: GameData) -> Dictionary:
	return MapWorks.cfg(gd).get("sects", {})


## Sects F2: the highest layer-2 work level the sect may build on its land.
static func work_max(gd: GameData, db: WorldDB, sect: Dictionary) -> int:
	var h: float = SectEconomy.effective_level(gd, db, sect, "holdings") if str(sect.get("kind", "")) == "great" else float(sect.get("levels", {}).get("holdings", 0))
	return int(ceil(h / 2.0 - 1e-9))


# A work's season value to the sect: a production work by the site's output value it adds, a density work by the
# members it serves at the seat (density_value_per_member).
static func _value(gd: GameData, db: WorldDB, sect: Dictionary, place: Dictionary, id: String) -> float:
	var w: Dictionary = MapWorks.work(gd, id)
	if str(w.get("stat", "")) == "production":
		if not place.has("site"):
			return 0.0
		var unit: float = float(gd.file(MapProduction.DATA_FILE).unit_value.get(str(place.site.get("resource", "")), 1))
		return float(place.site.get("base_output", 0.0)) * unit * float(w.per_level)
	if str(w.get("stat", "")) == "density":
		var members: int = db.living().filter(func(p): return bool(p.get("alive", false)) and str(p.get("sect_id", "")) == str(sect.id)).size()
		return float(w.per_level) * float(_cfg(gd).get("density_value_per_member", 2.0)) * members
	return 0.0


## The candidate works for [param sect]: [{place, id, level, cost, value}] with value per linh thach, best first.
static func candidates(gd: GameData, db: WorldDB, sect: Dictionary) -> Array:
	var cap: int = work_max(gd, db, sect)
	var out: Array = []
	if cap <= 0:
		return out
	var seat: String = str(sect.get("hq_place_id", ""))
	for p in db.all("places"):
		if str(p.get("holder", "")) != str(sect.id) or not p.has("qi") or bool(p.get("hidden", false)):
			continue
		var ids: Array = []
		if p.has("site"):
			ids.append_array(_cfg(gd).get("site_works", ["worked_mine", "vein_dressing"]))
		if str(p.id) == seat:
			ids.append_array(_cfg(gd).get("seat_works", ["sect_array", "spirit_grove"]))
		for id in ids:
			var w: Dictionary = MapWorks.work(gd, str(id))
			if w.is_empty():
				continue
			var lv: int = int(p.qi.get("layer2", {}).get(str(id), {}).get("level", 0))
			if lv >= mini(int(w.max), cap):
				continue
			var price: float = float(MapWorks.cost(gd, str(id), lv + 1).lt)
			var v: float = _value(gd, db, sect, p, str(id))
			if v <= 0.0 or price <= 0.0:
				continue
			out.append({"place": str(p.id), "id": str(id), "level": lv + 1, "cost": price, "value": v, "score": v / price})
	out.sort_custom(func(a, b): return float(a.score) > float(b.score) or (float(a.score) == float(b.score) and str(a.place) + str(a.id) < str(b.place) + str(b.id)))
	return out


## Spends up to [param budget] of the Holdings investment on the best works (whole levels only; the budget not spent
## raises the Holdings level as before). Returns what the works cost.
static func build_best(gd: GameData, db: WorldDB, sect: Dictionary, budget: float, year: int = 0, season_i: int = 0) -> float:
	var spent: float = 0.0
	var built: int = 0
	var max_builds: int = int(_cfg(gd).get("builds_per_season", 2))
	for cand in candidates(gd, db, sect):
		if built >= max_builds:
			break
		if spent + float(cand.cost) > budget:
			continue
		var p: Dictionary = db.get_record("places", str(cand.place))
		if not p.qi.has("layer2"):
			p.qi["layer2"] = {}
		p.qi.layer2[str(cand.id)] = {"level": int(cand.level), "unpaid": 0, "element": "", "by": str(sect.id)}
		if p.has("site"):
			p.site["works_prod"] = MapWorks.production_gain(gd, p.qi)
		spent += float(cand.cost)
		built += 1
		if bool(_cfg(gd).get("log_builds", true)):
			db.log_event(year, season_i, "sect_works", "%s xây %s cấp %d tại %s." % [sect.name, MapWorks.work(gd, str(cand.id)).name, int(cand.level), p.name],
				[str(sect.id)], [str(p.id)], [], {"work": cand.id, "level": cand.level})
	sect["works_spent"] = float(sect.get("works_spent", 0.0)) + spent
	return spent


## A sect's upkeep due this season for its upkept layer-2 works (Formula J: a worked mine's upkeep_site_frac of its
## site's output value a level, an array's upkeep a level).
static func upkeep_due(gd: GameData, db: WorldDB, sect: Dictionary) -> float:
	var t: float = 0.0
	for p in db.all("places"):
		if str(p.get("holder", "")) != str(sect.id) or not p.has("qi"):
			continue
		for id in p.qi.get("layer2", {}):
			var w: Dictionary = MapWorks.work(gd, str(id))
			if str(w.get("kind", "")) != "upkept":
				continue
			var lv: int = int(p.qi.layer2[id].get("level", 0))
			if w.has("upkeep_site_frac") and p.has("site"):
				var unit: float = float(gd.file(MapProduction.DATA_FILE).unit_value.get(str(p.site.get("resource", "")), 1))
				t += float(w.upkeep_site_frac) * float(p.site.get("base_output", 0.0)) * unit * lv
			else:
				t += float(w.get("upkeep", 0.0)) * lv
	return t


## Each season: every active sect pays its works' upkeep, the cash share burned and the goods share in kind (counted as
## works_due demand next season); unpaid works count a season and lose a level every fade_seasons unpaid seasons.
static func upkeep(gd: GameData, db: WorldDB, money: MoneyLedger) -> float:
	var gf: float = float(gd.file(WorldEconomy.FILE).demand.goods_frac)
	var total: float = 0.0
	for s in db.all("sects"):
		if str(s.get("status", "")) != "active":
			continue
		var due: float = upkeep_due(gd, db, s)
		s["works_due"] = due
		if due <= 0.0:
			continue
		var cash: float = due * (1.0 - gf)
		var paid: float = money.burn("sect:%s" % s.id, cash, "works_upkeep")
		s["kind_due"] = float(s.get("kind_due", 0.0)) + due * gf
		s["cash_costs"] = float(s.get("cash_costs", 0.0)) + paid
		total += paid
		var short: bool = paid + 1e-6 < cash
		for p in db.all("places"):
			if str(p.get("holder", "")) != str(s.id) or not p.has("qi"):
				continue
			for id in p.qi.get("layer2", {}).keys():
				var w: Dictionary = MapWorks.work(gd, str(id))
				if str(w.get("kind", "")) != "upkept":
					continue
				var rec: Dictionary = p.qi.layer2[id]
				rec["unpaid"] = int(rec.get("unpaid", 0)) + 1 if short else 0
				if int(rec.unpaid) >= int(w.get("fade_seasons", 2)) and int(w.get("fade_seasons", 2)) > 0:
					rec["level"] = int(rec.get("level", 0)) - 1
					rec["unpaid"] = 0
					if int(rec.level) <= 0:
						p.qi.layer2.erase(id)
					if p.has("site"):
						p.site["works_prod"] = MapWorks.production_gain(gd, p.qi)
	return total
