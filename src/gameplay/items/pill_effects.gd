class_name PillEffects
extends RefCounted
## Consuming đan dược. Effects scale with quality and shrink with accumulated đan độc
## (the brake on eating your way up); pills made for a lower realm barely work.
## Breakthrough pills are not eaten here — the breakthrough action consumes them.
## Design: game-concept.md § Character Stats (đan độc). Data: items_recipes.json, session_actions.json (pill).
##
## Usage:
## [codeblock]
## var r: Dictionary = PillEffects.consume(c, gd, db, sheet, item_id)
## print(r.message)
## [/codeblock]


## Eats one pill from a stack. Returns {ok, message, tu_vi}.
static func consume(c: Character, gd: GameData, db: WorldDB, sheet: StatSheet, item_id: String, rng: RandomNumberGenerator = null) -> Dictionary:
	var item: Dictionary = db.get_record("items", item_id)
	if item.is_empty() or item.owner_id != c.id or item.kind != "pill":
		return {"ok": false, "message": "You have no pill %s." % item_id}
	var recipe: Dictionary = gd.recipe(item.template)
	var fx: Dictionary = recipe.effect
	if fx.type == "breakthrough":
		return {"ok": false, "message": "%s is used by the 'breakthrough' command at a bình cảnh." % item.name}
	var max_uses: int = int(fx.get("max_uses", 0))
	if max_uses > 0 and int(c.pill_uses.get(item.template, 0)) >= max_uses:
		return {"ok": false, "message": "Your body no longer responds to %s (limit %d per life)." % [item.name, max_uses]}
	var cfg: Dictionary = gd.session().pill
	var potency := Breakdown.new("Pill effect multiplier")
	potency.base("Base", 1.0)
	potency.add_pct("Quality phẩm %d" % int(item.quality), float(item.quality) * float(cfg.quality_effect_step) * 100.0)
	if c.dan_doc > 0.0:
		potency.mul("Đan độc %d" % int(c.dan_doc), maxf(1.0 - c.dan_doc / float(cfg.toxicity_effect_divisor), 0.0))
	potency.add_pct("pill_effect_pct", sheet.total("pill_effect_pct"))
	var realm_scale: String = str(fx.get("realm_scale", ""))
	if realm_scale != "" and gd.realm_index(realm_scale) < c.realm_index:
		potency.mul("Made for a lower realm", float(cfg.realm_scale_penalty))
	var m: float = potency.total
	var msg: String = ""
	var tu_vi: float = 0.0
	match str(fx.type):
		"tu_vi":
			tu_vi = float(fx.value) * m
			msg = "+%.0f tu vi" % tu_vi
		"dan_doc":
			var before: float = c.dan_doc
			c.dan_doc = maxf(c.dan_doc + float(fx.value) * m, 0.0)
			msg = "đan độc %.0f -> %.0f" % [before, c.dan_doc]
		"tam_ma":
			var before_tm: float = c.tam_ma
			c.tam_ma = maxf(c.tam_ma + float(fx.value) * m, 0.0)
			msg = "tâm ma %.0f -> %.0f" % [before_tm, c.tam_ma]
		"heal_pct":
			c.vitality = minf(c.vitality + float(fx.value) / 100.0 * m, 1.0)
			msg = "khí huyết now %d%%" % int(c.vitality * 100.0)
		"stat":
			c.thien_phu[fx.stat] = clampi(c.base_stat(fx.stat) + int(roundf(float(fx.value) * m)), 1, 100)
			msg = "%s now %d" % [fx.stat, c.base_stat(fx.stat)]
		"lifespan":
			c.lifespan_bonus += float(fx.value) * m
			msg = "+%.1f years of thọ nguyên" % (float(fx.value) * m)
		"purity":
			var e: String = c.linh_can.weakest_element()
			var before_p: int = int(c.linh_can.purity(e))
			c.linh_can.raise_purity(e, maxi(int(roundf(float(fx.value) * m)), 1))
			msg = "%s purity %d -> %d" % [gd.element_name(e), before_p, int(c.linh_can.purity(e))]
			if rng != null:
				msg += TreasureEffects.new_bien_di_text(c, gd, rng)
	var tox: float = CharacterRules.add_dan_doc(c, gd, sheet, float(recipe.toxicity))
	c.pill_uses[item.template] = int(c.pill_uses.get(item.template, 0)) + 1
	item["qty"] = int(item.qty) - 1
	if int(item.qty) <= 0:
		db.remove("items", item_id)
	return {"ok": true, "message": "You swallow %s: %s (effect x%.2f; đan độc +%.1f)." % [item.name, msg, m, tox], "tu_vi": tu_vi, "potency": potency}
