class_name SectWorks
extends RefCounted

## Sects develop their land (design/gdd/provinces.md rule 9; Sects rule 8 and F2's free_level, user decision 2026-11-24:
## prices, not caps; provinces-runtime Stage 2): a sect orders province buildings in the provinces it pays for, with no
## highest level, each level above its track's free level ⌈T / 2⌉ at track_surcharge more, saving over a few seasons:
## production buildings by the output they add, and gathering arrays and spirit groves at its own seat by its members. The works are paid from the investment the treasury rule sends to Holdings
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


## Sects F2: the highest layer-2 work level the sect builds at Travel & Map's price (Holdings).
static func work_max(gd: GameData, db: WorldDB, sect: Dictionary) -> int:
	return _free(gd, db, sect, "holdings")


## Sects F2 (user decision 2026-11-24: prices, not caps): the free level of [param id]'s track, ⌈T / 2⌉ (a province
## building kind, or a Travel & Map work id); each level above costs track_surcharge more again.
static func free_level(gd: GameData, db: WorldDB, sect: Dictionary, id: String) -> int:
	if sect.is_empty():
		return -1
	var track: String = str(ProvinceBuildings.kind(gd, id).get("track", MapWorks.work(gd, id).get("track", "holdings")))
	return _free(gd, db, sect, track)


static func _free(gd: GameData, db: WorldDB, sect: Dictionary, track: String) -> int:
	var t: float = SectEconomy.effective_level(gd, db, sect, track) if str(sect.get("kind", "")) == "great" else float(sect.get("levels", {}).get(track, 0))
	return int(ceil(t / 2.0 - 1e-9))


# A building level's season value to the sect: a production kind by the output value it adds on the province's acting
# sites, a density kind at the sect's own seat by the members it serves (density_value_per_member).
static func _value(gd: GameData, db: WorldDB, v: Dictionary, k: String, members: int, own_seat: bool) -> float:
	var w: Dictionary = MapWorks.work(gd, str(ProvinceBuildings.kind(gd, k).get("work", "")))
	if str(w.get("stat", "")) == "production":
		var units: Dictionary = gd.file(MapProduction.DATA_FILE).unit_value
		var val: float = 0.0
		for p in ProvinceBuildings.acting_places(gd, db, v, k):
			val += float(p.site.get("base_output", 0.0)) * float(units.get(str(p.site.get("resource", "")), 1)) * float(w.per_level)
		return val
	if str(w.get("stat", "")) == "density" and own_seat:
		return float(w.per_level) * float(_cfg(gd).get("density_value_per_member", 2.0)) * members
	return 0.0


## The candidate building levels for [param sect] (Provinces rule 9): in the provinces it pays for, each live kind's next
## level (its lowest standing instance, or a new one in a free slot), at its track's price, with no highest level:
## [{province, building (id or ""), kind, level, cost, value, score}], best value per linh thach first.
static func candidates(gd: GameData, db: WorldDB, sect: Dictionary) -> Array:
	var out: Array = []
	var seat: String = str(sect.get("hq_place_id", ""))
	var members: int = db.living().filter(func(p): return bool(p.get("alive", false)) and str(p.get("sect_id", "")) == str(sect.id)).size()
	var kinds: Dictionary = ProvinceBuildings.cfg(gd).get("kinds", {})
	for v in db.all(Provinces.TABLE):
		if ProvinceBuildings.payer(db, v) != str(sect.id):
			continue
		var own_seat: bool = Array(v.places).has(seat)
		var bs: Array = v.get("buildings", [])
		var standing: int = bs.filter(func(b): return str(b.get("state", "")) != "cancelled").size()
		for k in kinds:
			var kd: Dictionary = kinds[k]
			if not bool(kd.get("live", false)) or str(kd.get("work", "")) == "" or bool(kd.get("element", false)):
				continue
			var val: float = _value(gd, db, v, str(k), members, own_seat)
			if val <= 0.0:
				continue
			var mine: Array = bs.filter(func(b): return str(b.kind) == str(k) and str(b.get("state", "")) != "cancelled")
			if mine.any(func(b): return str(b.state) in ["building", "ruined"]):
				continue   # one order of a kind at a time; a ruined one waits for a repair (Stage 4)
			var bid: String = ""
			var lv: int = 1
			if not mine.is_empty():
				mine.sort_custom(func(a, b): return int(a.level) < int(b.level) or (int(a.level) == int(b.level) and str(a.id) < str(b.id)))
				bid = str(mine[0].id)
				lv = int(mine[0].level) + 1
			elif standing >= int(v.get("slots", 0)):
				continue   # a new building needs a free slot (F5)
			var price: float = float(ProvinceBuildings.cost(gd, str(k), lv, free_level(gd, db, sect, str(k))))
			if price <= 0.0:
				continue
			out.append({"province": str(v.id), "building": bid, "kind": str(k), "level": lv, "cost": price, "value": val, "score": val / price})
	out.sort_custom(func(a, b): return float(a.score) > float(b.score) or (float(a.score) == float(b.score) and str(a.province) + str(a.kind) < str(b.province) + str(b.kind)))
	return out


## Spends up to [param budget] of the Holdings investment on the best building levels (whole levels only; the budget not
## spent raises the Holdings level as before). A level is paid now and built over its build seasons. Returns what this
## season's budget paid.
static func build_best(gd: GameData, db: WorldDB, sect: Dictionary, budget: float, year: int = 0, season_i: int = 0) -> float:
	var spent: float = 0.0
	var built: int = 0
	var max_builds: int = int(_cfg(gd).get("builds_per_season", 2))
	var cands: Array = candidates(gd, db, sect)
	# saving (2026-11-24): when the best level costs more than this season's budget but at most save_seasons_max seasons
	# of it, and pays back within save_payback_max seasons (cost / value), the sect sets this season's budget aside for it
	var saved: float = float(sect.get("works_saving", 0.0))
	if not cands.is_empty():
		var best: Dictionary = cands[0]
		var c0: float = float(best.cost)
		if c0 > budget + saved and c0 <= budget * float(_cfg(gd).get("save_seasons_max", 0)) and c0 / maxf(float(best.value), 1e-9) <= float(_cfg(gd).get("save_payback_max", 0)):
			sect["works_saving"] = saved + budget
			sect["works_spent"] = float(sect.get("works_spent", 0.0)) + budget
			return budget
	budget += saved
	for cand in cands:
		if built >= max_builds:
			break
		if spent + float(cand.cost) > budget:
			continue
		var v: Dictionary = db.get_record(Provinces.TABLE, str(cand.province))
		var seasons: int = ProvinceBuildings.build_seasons(gd, str(cand.kind), int(cand.level))
		if str(cand.building) == "":
			v.buildings.append(ProvinceBuildings.make(v, str(cand.kind), int(cand.level), true, seasons))
		else:
			for b in v.buildings:
				if str(b.id) == str(cand.building):
					b["target"] = int(cand.level)
					b["state"] = "building"
					b["left"] = seasons
		spent += float(cand.cost)
		built += 1
		if bool(_cfg(gd).get("log_builds", true)):
			db.log_event(year, season_i, "sect_works", "%s xây %s cấp %d tại %s." % [sect.name, str(ProvinceBuildings.kind(gd, str(cand.kind)).get("name_vi", cand.kind)), int(cand.level), str(v.get("name", v.id))],
				[str(sect.id)], [], [], {"work": cand.kind, "level": cand.level, "province": cand.province})
	# the saved part was already taken from earlier seasons' investment: report only this season's share, keep the rest
	var used_saved: float = minf(saved, spent)
	sect["works_saving"] = saved - used_saved
	sect["works_spent"] = float(sect.get("works_spent", 0.0)) + spent - used_saved
	return spent - used_saved


## A sect's upkeep due this season for the live upkept buildings of the provinces it pays for (ProvinceBuildings).
static func upkeep_due(gd: GameData, db: WorldDB, sect: Dictionary) -> float:
	var t: float = 0.0
	for row in ProvinceBuildings.bills(gd, db, sect):
		t += float(row[2])
	return t


## Each season: every active sect pays its buildings' upkeep, the cash share burned and the goods share in kind (counted
## as works_due demand next season). A short payment covers buildings in D3's order (production first); the rest count
## an unpaid season (Provinces States: unpaid, then ruined after ruin_seasons).
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
		ProvinceBuildings.settle(gd, db, s, paid / maxf(cash, 1e-9))
	return total
