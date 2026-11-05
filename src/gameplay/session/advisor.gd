class_name Advisor
extends RefCounted
## Reads a [GameSession] and says what matters now: dangers (thọ nguyên, khí huyết,
## đan độc, tâm ma), the concrete path to the next breakthrough (which pill, which herbs,
## how many years), unspent Kinh Mạch points, craftable pills, idle pháp bảo, empty plots.
## Read-only: it never changes the session. Any frontend can show the result (the debug
## terminal's menu and HUD today, a Godot HUD later). Thresholds: session_advisor.json.
##
## A goal is {id, severity, text, command, action}: severity is "urgent", "warn", "goal" or
## "tip"; command is a terminal-style command that acts on it ("" when nothing can be done
## now); action is a short label for that command ("Plant Hoàng Tinh Sâm (15 LT)").
## An action is {label, command, group} for a menu.
##
## Usage:
## [codeblock]
## for g in Advisor.goals(session):
##     print("%s: %s" % [g.severity, g.text])
## var odds: Dictionary = Advisor.choice_odds(session, 0)   # {chance (0..1), text, ok, reason}
## [/codeblock]

const SEVERITY_ORDER := {"urgent": 0, "warn": 1, "goal": 2, "tip": 3}


## Every goal that applies now, most severe first.
static func goals(s: GameSession) -> Array:
	var out: Array = []
	if s.player == null or s.life_over:
		return out
	var c: Character = s.player
	var gd: GameData = s.gd
	var sh: StatSheet = s.sheet()
	var cfg: Dictionary = gd.file("session_advisor")
	if s.has_pending_event():
		out.append(_g("event", "urgent", "An event is waiting: %s" % s.pending_event.title, "event", "Answer the event"))

	var life: float = CultivationRules.lifespan(c, gd, sh).total
	var left: float = life - c.age
	var bottleneck: bool = CultivationRules.at_bottleneck(c, gd)
	if left <= float(cfg.lifespan_warning_years):
		var sev: String = "urgent" if left <= float(cfg.lifespan_urgent_years) else "warn"
		out.append(_g("lifespan", sev, "Thọ nguyên: %.1f years left (dies at %d). Only a breakthrough or a life-extending pill adds years." % [left, int(life)], "breakthrough" if bottleneck else ""))
	if c.vitality * 100.0 < float(cfg.khi_huyet_warning_pct):
		out.append(_g("khi_huyet", "warn", "Khí huyết %d%%: you are wounded and weaker in fights. Rest (cultivate) before exploring." % int(c.vitality * 100.0), "cul %d" % int(cfg.menu.cultivate_seasons), "Rest and cultivate a year"))
	if c.dan_doc >= float(cfg.dan_doc_warning):
		out.append(_g("dan_doc", "warn", "Đan độc %.0f: pills work %d%% worse until it fades." % [c.dan_doc, int(c.dan_doc)], ""))
	if c.tam_ma >= float(cfg.tam_ma_warning):
		out.append(_g("tam_ma", "warn", "Tâm ma %.0f: a breakthrough now risks tẩu hỏa nhập ma (%.0f%%)." % [c.tam_ma, CultivationRules.backlash_chance(c, gd, sh).total], ""))

	out.append_array(_breakthrough_goals(s, c, gd, sh, bottleneck))
	out.append_array(_ladder_warnings(s, c, gd, sh))

	for b in s.beasts.owned(c):
		if int(b.get("loyalty", 0)) < int(cfg.beast_loyalty_warning):
			out.append(_g("beast_" + str(b.id), "warn", "%s is hungry and may leave (loyalty %d); feeding costs %d LT a year." % [b.name, int(b.get("loyalty", 0)), s.beasts.feed_cost(c)], "beasts", "Check your linh thú"))
	if c.tree_points > 0:
		out.append(_g("tree", "goal", "%d Kinh Mạch point(s) to spend." % c.tree_points, "tree", "Spend %d Kinh Mạch point(s)" % c.tree_points))
	out.append_array(_field_goals(s, c, gd, sh))
	out.append_array(_craft_goals(s, c, gd, sh))
	out.append_array(_gear_goals(s, c, gd, sh))
	for it in s.db.items_of(c.id):
		if it.kind == "treasure":
			out.append(_g("treasure_" + str(it.id), "goal", "You hold %s. Using it changes your linh căn for good." % it.name, "use %s" % it.id, "Use %s" % it.name))
	out.append_array(_investment_goals(s, c, gd, sh))
	if c.linh_thach < int(cfg.low_linh_thach):
		if can_work_here(s):
			out.append(_g("money", "tip", "Only %d linh thạch. Missions and bounties pay." % c.linh_thach, "mission", "Earn linh thạch (mission / bounty)"))
		else:
			var work: String = nearest_work_place(s)
			var hop: String = next_hop(s, c.location_id, work)
			var wname: String = str(s.db.get_record("places", work).get("name", work))
			out.append(_g("money", "tip", "Only %d linh thạch, and no work here. %s has bounties." % [c.linh_thach, wname] if work != "" else "Only %d linh thạch; no bounties anywhere near." % c.linh_thach,
				("go %s" % hop) if hop != "" else "", "Travel toward %s for bounty work" % wname))

	var indexed: Array = []
	for i in out.size():
		indexed.append([out[i], i])
	indexed.sort_custom(func(a, b):
		var sa: int = SEVERITY_ORDER[a[0].severity]
		var sb: int = SEVERITY_ORDER[b[0].severity]
		return sa < sb or (sa == sb and a[1] < b[1]))
	return indexed.map(func(x): return x[0])


## Warnings from the ladder and techniques: a full bar wasting tu vi, a main method past its
## tier, a next-tier method to buy, and the brews still possible.
static func _ladder_warnings(s: GameSession, c: Character, gd: GameData, sh: StatSheet) -> Array:
	var out: Array = []
	var main: Dictionary = CongPhap.main_entry(c)
	if main.is_empty():
		out.append(_g("technique", "warn", "No main method in the slot: you cultivate crudely. Use 'tech' and 'slot main <row>'.", "tech", "Check your techniques"))
	else:
		var max_realm: int = gd.realm_index(str(CongPhap.tier_of(gd, main.def).max_realm))
		if c.realm_index > max_realm:
			out.append(_g("technique", "warn", "%s stops at %s: speed x0.25 until you change method." % [main.def.name, gd.realm(max_realm).name], "tech", "Check your techniques"))
		elif c.realm_index == max_realm and CultivationRules.at_great_perfection(c, gd):
			out.append(_g("technique", "tip", "%s reaches no further than this realm; find the next tier before you break through." % main.def.name, ""))
	if CultivationRules.at_great_perfection(c, gd):
		var plan: Dictionary = brew_plan(s)
		var p_none: float = pow(1.0 - float(plan.p_brew), float(plan.b))
		out.append(_g("brews", "tip", "%d brew(s) possible this realm; chance of brewing no pill %.0f%%." % [int(plan.b), p_none * 100.0], ""))
	return out


## Cultivation progress: {rate, seasons_to_stage, bottleneck, requirement}. seasons_to_stage
## is -1 at a bình cảnh or when the rate is zero.
static func progress(s: GameSession) -> Dictionary:
	var c: Character = s.player
	var sh: StatSheet = s.sheet()
	var density: float = float(s.db.get_record("places", c.location_id).get("density", 1.0))
	var rate: float = CultivationRules.rate_per_season(c, s.gd, s.db, sh, density).total
	var req: float = CultivationRules.level_requirement(c, s.gd)
	var bottleneck: bool = CultivationRules.at_bottleneck(c, s.gd)
	var seasons: int = -1
	if not bottleneck and rate > 0.0:
		seasons = int(ceil(maxf(req - c.tu_vi, 0.0) / rate))
	return {"rate": rate, "seasons_to_stage": seasons, "bottleneck": bottleneck, "requirement": req}


## Breakthrough odds now (best pill held, talismans in the bag previewed, not used):
## {chance, pill, used, breakdown}.
static func breakthrough_odds(s: GameSession) -> Dictionary:
	var c: Character = s.player
	if c.realm_index >= s.gd.realms().size() - 1:
		return {"chance": 0.0, "pill": {}, "used": [], "breakdown": null}
	var tag: String = str(s.gd.realm(c.realm_index + 1).entry_requirement.item_tag)
	var pill: Dictionary = best_pill(s, tag)
	var sh: StatSheet = s.sheet()
	var cond: Dictionary = CultivationRules.breakthrough_condition(c, s.gd, s.local_density(sh))
	var rank: int = int(pill.quality) if not pill.is_empty() and cond.met else -1
	var talisman: bool = rank >= 0 and s.talisman_available()
	var b: Breakdown = CultivationRules.breakthrough_chance(c, s.gd, sh, rank, talisman)
	return {"chance": b.total, "pill": pill, "used": ["Phá Cảnh Phù"] if talisman else [], "breakdown": b, "condition": cond}


## Formulas D: the brews that count from now, by the counting rule: {b, years_first, p_brew}. The
## first attempt waits for the full bar and each later one for the refill plus the attempt's
## season; a brew counts if its attempt starts at least one season before the cap. Plots count as
## empty (B_remaining from the plot state is not built). Packing is greedy over the plots.
static func brew_plan(s: GameSession) -> Dictionary:
	var c: Character = s.player
	var gd: GameData = s.gd
	if c.realm_index >= gd.realms().size() - 1:
		return {"b": 0, "years_first": 0.0, "p_brew": 0.0}
	var sh: StatSheet = s.sheet()
	var recipe: Dictionary = recipe_for_tag(gd, str(gd.realm(c.realm_index + 1).entry_requirement.item_tag))
	var h: float = CharacterRules.herb_growth(c, gd, sh).total
	var plots: int = s.field.plot_count(c, sh)
	var p_brew: float = s.alchemy.success_chance(c, sh, recipe).total / 100.0
	if recipe.is_empty() or h <= 0.0:
		return {"b": 0, "years_first": INF, "p_brew": p_brew}
	var cap: float = CultivationRules.lifespan(c, gd, sh).total
	var season: float = 1.0 / float(gd.cultivation_rules().seasons_per_year)
	var rate: float = maxf(float(progress(s).rate), 1.0)
	var climb: float = _seasons_to_full_bar(c, gd, rate) * season
	var refill: float = float(gd.breakthrough_rules().failure_tu_vi_loss_pct) * Ladder.bar_cost(gd, c.realm_index) / _rate_at_stage(c, gd, rate, Ladder.GREAT_PERFECTION) * season
	var first: float = _pack_capacity(recipe, 1, plots) / h
	var b: int = 0
	var last: float = c.age + maxf(first, climb)
	while last <= cap - season:
		b += 1
		last = maxf(c.age + _pack_capacity(recipe, b + 1, plots) / h, last + refill + season)
	return {"b": b, "years_first": first, "p_brew": p_brew}


## [param rate], the rate now, moved to another stage of the realm by the root curve.
static func _rate_at_stage(c: Character, gd: GameData, rate: float, stage: int) -> float:
	var groups: Array = gd.realm(c.realm_index).stage_curve_groups
	var row: Dictionary = gd.attributes().element_count_curve.get(str(c.linh_can.n_eff(gd)), {})
	return rate * float(row.get(groups[clampi(stage, 0, groups.size() - 1)], 1.0)) / maxf(CultivationRules.curve_factor(c, gd), 0.01)


## Seasons until the bottleneck bar is full, stage by stage from the rate now.
static func _seasons_to_full_bar(c: Character, gd: GameData, rate: float) -> float:
	var held: float = c.tu_vi
	var seasons: float = 0.0
	for level in range(c.level, Ladder.band(gd, c.realm_index)[1]):
		seasons += maxf(Ladder.level_cost(gd, level) - held, 0.0) / _rate_at_stage(c, gd, rate, Ladder.stage_of_level(gd, level))
		held = 0.0
	return seasons + maxf(Ladder.bar_cost(gd, c.realm_index) - held, 0.0) / _rate_at_stage(c, gd, rate, Ladder.GREAT_PERFECTION)


## The plant plan (Formulas D): the herb the next free plot should grow. Recipes are filled in
## order, counting herbs held and growing, so plots rotate into the staggered layout. Returns a
## herb id, or "" when [param recipes] brews are covered.
static func next_plant(s: GameSession, recipe: Dictionary, recipes: int) -> String:
	var c: Character = s.player
	var supply: Dictionary = {}
	for it in s.db.items_of(c.id):
		if it.kind == "herb":
			supply[it.template] = int(supply.get(it.template, 0)) + 1
	for k in recipes:
		for ing in recipe.ingredients:
			for i in int(ing.qty):
				var left: int = int(supply.get(ing.herb, 0))
				if left > 0:
					supply[ing.herb] = left - 1
				else:
					return str(ing.herb)
	return ""


## C_k: the smallest herb-years per plot that fit [param k] recipes' herbs in [param plots] plots.
static func _pack_capacity(recipe: Dictionary, k: int, plots: int) -> float:
	var ages: Array = []
	for ing in recipe.ingredients:
		for i in int(ing.qty) * k:
			ages.append(float(ing.min_age))
	ages.sort()
	ages.reverse()
	var loads: Array = []
	loads.resize(maxi(plots, 1))
	loads.fill(0.0)
	for a in ages:
		var best: int = 0
		for i in loads.size():
			if float(loads[i]) < float(loads[best]):
				best = i
		loads[best] = float(loads[best]) + float(a)
	return float(loads.max())


## Odds of one choice of the pending event: {chance (0..1, or -1 without a check), text, ok, reason}.
static func choice_odds(s: GameSession, index: int) -> Dictionary:
	var ev: Dictionary = s.pending_event
	var ch: Dictionary = ev.choices[index]
	var sh: StatSheet = s.sheet()
	var used: Array = Talismans.apply_for_check(s.player, s.gd, s.db, sh, str(ch.check.type), bool(ch.check.get("evade", false)), false)
	if used.is_empty():
		used = []
	var allowed: Dictionary = s.resolver.can_choose(s.player, ev, index)
	var out := {"chance": -1.0, "text": "no check", "ok": allowed.ok, "reason": allowed.reason}
	match str(ch.check.type):
		"stat":
			var evade: bool = bool(ch.check.get("evade", false))
			var p: float = s.resolver.stat_check_chance(s.player, sh, ch.check.stat, float(ch.check.difficulty), evade).total
			out.chance = p
			out.text = "%s %d vs %d" % [_stat_name(s.gd, str(ch.check.stat)), int(sh.effective(str(ch.check.stat), s.player)), int(ch.check.difficulty)]
			if evade and sh.total("stealth") > 0.0:
				out.text += " + stealth %d" % int(sh.total("stealth"))
		"combat":
			var enemy := Character.from_dict(s.db.get_record("people", ch.check.enemy))
			var mine: float = CombatPower.compute(s.player, s.gd, s.db, sh).total
			var theirs: float = s.builds.power_of(enemy)
			var cfg: Dictionary = s.gd.combat().duel
			var k: float = float(cfg.ratio_exponent)
			var p2: float = pow(maxf(mine, 1.0), k) / (pow(maxf(mine, 1.0), k) + pow(maxf(theirs, 1.0), k))
			p2 += (sh.effective("khi_van", s.player) - float(enemy.base_stat("khi_van"))) * float(cfg.khi_van_per_point)
			out.chance = clampf(p2, float(cfg.min_win_chance), float(cfg.max_win_chance))
			out.text = "fight: chiến lực %.0f vs %.0f" % [mine, theirs]
	if not used.is_empty():
		out.text += " + " + ", ".join(used)
	return out


## Context menu: goal commands first, then what can be done at this place.
static func actions(s: GameSession) -> Array:
	var out: Array = []
	if s.player == null or s.life_over:
		return [{"label": "Begin a new life", "command": "new", "group": "life"}]
	if s.has_pending_event():
		for i in s.pending_event.choices.size():
			out.append({"label": str(s.pending_event.choices[i].label), "command": "choose %d" % (i + 1), "group": "event"})
		return out
	var c: Character = s.player
	var cfg: Dictionary = s.gd.file("session_advisor").menu
	var seen: Dictionary = {}
	for g in goals(s):
		if g.command == "" or seen.has(g.command) or seen.size() >= int(cfg.max_goal_entries):
			continue
		seen[g.command] = true
		out.append({"label": str(g.action) if str(g.action) != "" else _short(g.text, int(cfg.label_max_chars)), "command": g.command, "group": "goal"})
	var place: Dictionary = s.db.get_record("places", c.location_id)
	var std: Array = [
		{"label": "Cultivate 1 year", "command": "cul %d" % int(cfg.cultivate_seasons), "group": "time"},
		{"label": "Closed-door %d years" % int(cfg.closed_door_years), "command": "bequan %d" % int(cfg.closed_door_years), "group": "time"},
		{"label": "Explore %s" % place.name, "command": "explore", "group": "time"},
	]
	if can_work_here(s):
		std.append({"label": "Mission / bounty", "command": "mission", "group": "time"})
	std.append({"label": "Travel…", "command": "go", "group": "time"})
	if c.location_id == c.home_id:
		std.append({"label": "Herb field", "command": "field", "group": "home"})
	std.append({"label": "Alchemy…", "command": "craft", "group": "home"})
	std.append({"label": "Refine a pháp bảo…", "command": "refine", "group": "home"})
	std.append({"label": "Draw talismans…", "command": "talisman", "group": "home"})
	if c.location_id == c.home_id:
		std.append({"label": "Formations (trận pháp)", "command": "formation", "group": "home"})
	if bool(place.get("market", false)):
		std.append({"label": "Market", "command": "market", "group": "place"})
	var people: Array = s.db.find("people", func(p): return p.alive and not p.get("is_player", false) and not p.get("is_beast", false) and str(p.location_id) == c.location_id)
	if not people.is_empty():
		std.append({"label": "Talk to someone… (%d here)" % people.size(), "command": "talk", "group": "place"})
	if not c.beasts.is_empty():
		std.append({"label": "Linh thú (%d)" % c.beasts.size(), "command": "beasts", "group": "self"})
	std.append({"label": "Kinh Mạch Đồ", "command": "tree", "group": "self"})
	std.append({"label": "Character sheet", "command": "sheet", "group": "self"})
	std.append({"label": "Inventory", "command": "inv", "group": "self"})
	for a in std:
		if not seen.has(a.command):
			out.append(a)
	return out


## Nearest place (by roads) where 'mission' finds work, or "" if none is reachable.
static func nearest_work_place(s: GameSession) -> String:
	var c: Character = s.player
	var sect: Dictionary = s.db.get_record("sects", c.sect_id)
	var seen: Dictionary = {c.location_id: true}
	var queue: Array = [c.location_id]
	while not queue.is_empty():
		var cur: String = queue.pop_front()
		var pl: Dictionary = s.db.get_record("places", cur)
		if cur != c.location_id and (bool(pl.get("bounties", false)) or (not sect.is_empty() and sect.hq_place_id == cur)):
			return cur
		for l in pl.get("links", []):
			if not seen.has(l.to):
				seen[l.to] = true
				queue.append(l.to)
	return ""


## The first road to take from [param from] toward [param to] ("" if unreachable or there).
static func next_hop(s: GameSession, from: String, to: String) -> String:
	if from == to or to == "":
		return ""
	var prev: Dictionary = {from: ""}
	var queue: Array = [from]
	while not queue.is_empty():
		var cur: String = queue.pop_front()
		if cur == to:
			break
		for l in s.db.get_record("places", cur).get("links", []):
			if not prev.has(l.to):
				prev[l.to] = cur
				queue.append(l.to)
	if not prev.has(to):
		return ""
	var step: String = to
	while prev[step] != from:
		step = prev[step]
	return step


## True when 'mission' would find work at the player's location.
static func can_work_here(s: GameSession) -> bool:
	var c: Character = s.player
	var place: Dictionary = s.db.get_record("places", c.location_id)
	var sect: Dictionary = s.db.get_record("sects", c.sect_id)
	return bool(place.get("bounties", false)) or (not sect.is_empty() and sect.hq_place_id == c.location_id)


# --- Goal builders ---------------------------------------------------------------------

static func _breakthrough_goals(s: GameSession, c: Character, gd: GameData, sh: StatSheet, bottleneck: bool) -> Array:
	if c.realm_index >= gd.realms().size() - 1:
		return []
	var next: Dictionary = gd.realm(c.realm_index + 1)
	var tag: String = str(next.entry_requirement.item_tag)
	var pill: Dictionary = best_pill(s, tag)
	var prefix: String = "Bình cảnh! " if bottleneck else "Toward %s: " % next.name
	var sev: String = "urgent" if bottleneck else "goal"
	if not pill.is_empty():
		var chance: float = breakthrough_odds(s).chance * 100.0
		if bottleneck:
			return [_g("breakthrough", "urgent", "Bình cảnh reached and you hold %s: break through (%.0f%%)." % [pill.name, chance], "breakthrough", "Break through to %s (%.0f%%)" % [next.name, chance])]
		var prog: Dictionary = progress(s)
		return [_g("breakthrough", "tip", "%s ready for %s (%.0f%% now). Reach the bình cảnh first%s." % [pill.name, next.name, chance, _eta(gd, c, prog)], "")]
	var recipe: Dictionary = recipe_for_tag(gd, tag)
	if recipe.is_empty():
		return [_g("breakthrough", sev, "%sfind a %s (no known recipe)." % [prefix, tag], "")]
	var parts: Array = []
	var command: String = ""
	var action: String = ""
	var plan: Dictionary = s.alchemy.find_ingredients(c, recipe)
	var level: int = c.skill_level(Alchemy.SKILL)
	if level + 1 < int(recipe.min_level):
		parts.append("Đan Đạo %d/%d (craft lesser pills to train)" % [level, int(recipe.min_level)])
	if plan.ok:
		if level + 1 >= int(recipe.min_level):
			parts.append("craft it now (%.0f%%)" % s.alchemy.success_chance(c, sh, recipe).total)
			command = "craft %s" % recipe.id
			action = "Craft %s (%.0f%%)" % [recipe.name, s.alchemy.success_chance(c, sh, recipe).total]
	else:
		for ing in recipe.ingredients:
			var st: Dictionary = ingredient_status(s, c, sh, ing)
			parts.append(st.text)
			if command == "" and st.command != "":
				command = st.command
				action = "%s — for %s" % [st.action, recipe.name]
	var market_line: String = _market_offer(s, tag)
	if market_line != "":
		parts.append(market_line)
	var base_chance: float = breakthrough_odds(s).chance * 100.0
	var text: String = "%s%s needs: %s." % [prefix, recipe.name, "; ".join(parts)]
	if bottleneck:
		text += " (Without it: %.0f%%.)" % base_chance
		if command == "":
			command = "breakthrough"
			action = "Attempt the breakthrough without a pill (%.0f%%)" % base_chance
	return [_g("breakthrough", sev, text, command, action)]


## Where one recipe ingredient stands: {text, command, action, ready}. A recipe may need several
## of a herb, so held, ripening and missing herbs are counted against [code]ing.qty[/code].
static func ingredient_status(s: GameSession, c: Character, sh: StatSheet, ing: Dictionary) -> Dictionary:
	var gd: GameData = s.gd
	var herb: Dictionary = gd.herb(str(ing.herb))
	var need_age: float = float(ing.min_age)
	var qty: int = int(ing.qty)
	var label: String = "%s ≥%.0fy%s" % [herb.get("name", ing.herb), need_age, " x%d" % qty if qty > 1 else ""]
	var have: int = s.db.items_of(c.id).filter(func(i): return i.kind == "herb" and int(i.get("plot", -1)) < 0 and i.template == ing.herb and float(i.age) >= need_age).size()
	if have >= qty:
		return {"text": "%s ✓" % label, "command": "", "action": "", "ready": true}
	var growing: Array = []
	var planted: Dictionary = s.field.planted(c)
	for p in planted.keys():
		var h: Dictionary = planted[p]
		if h.template != ing.herb:
			continue
		if float(h.age) >= need_age:
			return {"text": "%s ripe in plot %d" % [label, int(p)], "command": "harvest %d" % int(p), "action": "Harvest %s (plot %d)" % [herb.get("name", ing.herb), int(p)], "ready": true}
		growing.append(h)
	if have + growing.size() >= qty:
		var years: float = 0.0
		for h in growing:
			years = maxf(years, s.field.years_until(c, sh, h, need_age))
		return {"text": "%s growing (%.1f y left)" % [label, years], "command": "", "action": "", "ready": false}
	# A young herb in the bag only ages once it is planted.
	var young: Array = s.db.items_of(c.id).filter(func(i): return i.kind == "herb" and int(i.get("plot", -1)) < 0 and i.template == ing.herb and float(i.age) < need_age)
	young.sort_custom(func(a, b): return float(a.age) > float(b.age))
	if not young.is_empty():
		var y: Dictionary = young[0]
		var at_home: bool = c.location_id == c.home_id
		var free: bool = s.field.free_plot(c, sh) != -1
		var where: String = "plant it to keep it aging" if at_home and free else ("free a plot and plant it" if at_home else "plant it at home")
		return {"text": "%s: you hold one aged %.0fy; %s" % [label, float(y.age), where], "command": "plant %s" % y.id if at_home and free else "",
			"action": "Plant your %s (%.0fy)" % [herb.get("name", ing.herb), float(y.age)], "ready": false}
	if int(herb.get("rarity", 99)) <= int(gd.session().field.seed_rarity_by_realm[c.realm_index]):
		return {"text": "%s: plant a seed (%d LT)" % [label, int(herb.seed_price)], "command": "plant %s" % ing.herb if c.location_id == c.home_id else "", "action": "Plant %s (%d LT)" % [herb.get("name", ing.herb), int(herb.seed_price)], "ready": false}
	# Seeds are not sold: buy a young one at a market and let it age in the field.
	var place: Dictionary = s.db.get_record("places", c.location_id)
	if bool(place.get("market", false)):
		var offers: Array = s.market.stock(place.id).filter(func(i): return i.kind == "herb" and i.template == ing.herb)
		offers.sort_custom(func(a, b): return float(a.age) > float(b.age))
		if not offers.is_empty():
			var o: Dictionary = offers[0]
			var price: int = s.market.buy_price(c, sh, o)
			return {"text": "%s: this market sells one aged %.0fy for %d LT" % [label, float(o.age), price], "command": "buy %s" % o.id if c.linh_thach >= price else "",
				"action": "Buy %s %.0fy (%d LT)" % [herb.get("name", ing.herb), float(o.age), price], "ready": false, "price": price}
	var est: int = market_price_estimate(s, str(ing.herb))
	return {"text": "%s: no seeds sold; find one exploring" % label, "command": "", "action": "", "ready": false, "price": est}


## Typical market price of a herb that seeds cannot provide (a mid-aged one).
static func market_price_estimate(s: GameSession, herb_id: String) -> int:
	var cfg: Dictionary = s.gd.session().market
	var h: Dictionary = s.items.herb(herb_id, float(cfg.aged_herb_max_years) / 2.0)
	return s.market.buy_price(s.player, s.sheet(), h)


static func _field_goals(s: GameSession, c: Character, gd: GameData, sh: StatSheet) -> Array:
	var out: Array = []
	if c.location_id != c.home_id:
		return out
	var free: int = s.field.free_plot(c, sh)
	if free != -1:
		out.append(_g("plot", "tip", "Plot %d of your linh điền is empty." % free, "plant", "Plant something (plot %d is empty)" % free))
	return out


static func _craft_goals(s: GameSession, c: Character, gd: GameData, sh: StatSheet) -> Array:
	var out: Array = []
	for r in gd.recipes():
		if str(r.effect.type) == "breakthrough":
			continue
		if c.skill_level(Alchemy.SKILL) + 1 < int(r.min_level):
			continue
		if s.alchemy.find_ingredients(c, r).ok:
			out.append(_g("craft_" + str(r.id), "tip", "You can craft %s (%.0f%%)." % [r.name, s.alchemy.success_chance(c, sh, r).total], "craft %s" % r.id, "Craft %s (%.0f%%)" % [r.name, s.alchemy.success_chance(c, sh, r).total]))
	return out


static func _gear_goals(s: GameSession, c: Character, gd: GameData, sh: StatSheet) -> Array:
	var out: Array = []
	var power: Dictionary = CombatPower.compute(c, gd, s.db, sh)
	var free: float = float(power.than_thuc_capacity) - float(power.than_thuc_used)
	for it in s.db.items_of(c.id):
		if it.kind == "artifact" and not c.equipped.has(it.id) and float(it.than_thuc_cost) <= free:
			out.append(_g("equip_" + str(it.id), "tip", "%s is unused and your thần thức can carry it." % it.name, "equip %s" % it.id, "Equip %s" % it.name))
	return out


## Linh thạch with nothing to do: suggest a formation level or a refine the player can afford.
static func _investment_goals(s: GameSession, c: Character, gd: GameData, sh: StatSheet) -> Array:
	var out: Array = []
	var at_home: bool = c.location_id == c.home_id
	for f in s.formations.config().formations:
		var ck: Dictionary = s.formations.can_build(c, f.id)
		if ck.ok and c.linh_thach >= int(ck.cost.lt) * int(gd.file("session_advisor").invest_affordability_mult):
			var lv: int = s.formations.level(c, f.id) + 1
			out.append(_g("formation_" + str(f.id), "tip", "%s level %d: %s for %d LT." % [f.name, lv, gd.format_mod(str(f.stat), float(f.per_level) * float(lv)), int(ck.cost.lt)],
				"formation build %s" % f.id, "Raise %s to level %d (%d LT)" % [f.name, lv, int(ck.cost.lt)]))
			break
	var tier: int = c.realm_index
	for b in gd.artifacts_file().bases:
		var rk: Dictionary = s.refinery.check(c, b.id, tier)
		if rk.ok and c.linh_thach >= int(rk.fuel) * int(gd.file("session_advisor").invest_affordability_mult):
			out.append(_g("refine", "tip", "You can refine a %s (%.0f%%, fuel from %d LT)." % [gd.artifact_tier(tier).name, s.refinery.success_chance(c, sh, tier).total, int(rk.fuel)],
				"refine", "Refine a %s…" % gd.artifact_tier(tier).name))
			break
	if not at_home:
		return out.filter(func(g): return g.id == "refine")
	return out


static func _market_offer(s: GameSession, tag: String) -> String:
	var place: Dictionary = s.db.get_record("places", s.player.location_id)
	if not bool(place.get("market", false)):
		return ""
	for it in s.market.stock(place.id):
		if it.kind == "pill" and str(s.gd.recipe(str(it.template)).effect.get("tag", "")) == tag:
			return "or buy one here (%d LT)" % s.market.buy_price(s.player, s.sheet(), it)
	return ""


# --- Helpers ---------------------------------------------------------------------------

## The best-quality pill the player owns with this breakthrough tag, or {}.
static func best_pill(s: GameSession, tag: String) -> Dictionary:
	var pill: Dictionary = {}
	for it in s.db.items_of(s.player.id):
		if it.kind == "pill" and str(s.gd.recipe(str(it.template)).effect.get("tag", "")) == tag:
			if pill.is_empty() or int(it.quality) > int(pill.quality):
				pill = it
	return pill


## The recipe whose effect carries [param tag], or {}.
static func recipe_for_tag(gd: GameData, tag: String) -> Dictionary:
	for r in gd.recipes():
		if str(r.effect.get("tag", "")) == tag:
			return r
	return {}


static func _eta(gd: GameData, c: Character, prog: Dictionary) -> String:
	var levels_left: int = Ladder.band(gd, c.realm_index)[1] - c.level
	if levels_left <= 0 or int(prog.seasons_to_stage) < 0:
		return ""
	return " (%d levels to go)" % levels_left


static func _stat_name(gd: GameData, stat: String) -> String:
	for def in gd.thien_phu_defs():
		if def.id == stat:
			return str(def.name)
	return stat


static func _short(text: String, max_chars: int) -> String:
	var cut: int = text.find(". ")
	var t: String = text if cut == -1 else text.substr(0, cut)
	return t if t.length() <= max_chars else t.substr(0, max_chars - 1) + "…"


static func _g(id: String, severity: String, text: String, command: String, action: String = "") -> Dictionary:
	return {"id": id, "severity": severity, "text": text, "command": command, "action": action}
