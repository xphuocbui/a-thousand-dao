class_name ProgressionEdges
extends RefCounted
## Edges over the baseline progression. Baseline: about 3 in 10 make each realm
## breakthrough; the main character's edge (thiên mệnh perk, starting items, cơ duyên)
## lifts that toward 7 in 10; NPC edges (strong root, sect value, rich family, a
## blessing) do the same for NPCs, up to the player's level. Spec:
## design/quick-specs/progression-and-edges.md. Data: character_edges.json.
##
## Usage:
## [codeblock]
## var offered: Array = ProgressionEdges.roll_perk_choices(gd, rng)   # three perk ids
## ProgressionEdges.apply_birth(player, gd, offered[0])
## ProgressionEdges.add_perk_mods(player, gd, sheet)                   # StatSheet.build does this
## var p: Breakdown = ProgressionEdges.npc_step_chance(npc_record, gd) # 0.30 .. 0.70
## [/codeblock]


## character_edges.json content.
static func config(gd: GameData) -> Dictionary:
	return gd.file("character_edges")


## Perk definition by id, or {}.
static func perk(gd: GameData, perk_id: String) -> Dictionary:
	for p in config(gd).get("perks", []):
		if p.id == perk_id:
			return p
	return {}


## Every perk definition.
static func perks(gd: GameData) -> Array:
	return config(gd).get("perks", [])


## Distinct perk ids offered at birth (Thiên Định picks one of these).
static func roll_perk_choices(gd: GameData, rng: RandomNumberGenerator) -> Array:
	var n: int = int(config(gd).player.perk_choices)
	return RngUtils.shuffled(rng, perks(gd)).slice(0, n).map(func(p): return str(p.id))


## Gives a perk at birth: records it and applies its one-time birth effects.
static func apply_birth(c: Character, gd: GameData, perk_id: String) -> void:
	var p: Dictionary = perk(gd, perk_id)
	if p.is_empty() or c.perks.has(perk_id):
		return
	c.perks.append(perk_id)
	var birth: Dictionary = p.get("birth", {})
	if birth.has("purity_all"):
		for e in c.linh_can.elements.keys():
			c.linh_can.raise_purity(gd, e, int(birth.purity_all))


## Adds every owned perk's effects to a stat sheet (source "Thiên mệnh: <name>").
static func add_perk_mods(c: Character, gd: GameData, sheet: StatSheet) -> void:
	for id in c.perks:
		var p: Dictionary = perk(gd, str(id))
		for fx in p.get("effects", []):
			sheet.add_mod("Thiên mệnh: %s" % p.name, str(fx.stat), float(fx.value), StatSheet.KIND_PERK)


## Gives a new NPC its background edges (rich family, a blessing) by chance.
static func assign_npc_edges(c: Character, gd: GameData, rng: RandomNumberGenerator) -> void:
	var cfg: Dictionary = config(gd).npc
	if rng.randf() < float(cfg.rich_family.chance):
		c.background = "rich_family"
	if rng.randf() < float(cfg.blessing.chance):
		c.perks.append(str(RngUtils.pick(rng, perks(gd)).id))


## An NPC's edge score (0..) from its record, as a breakdown.
static func npc_edge_score(rec: Dictionary, gd: GameData) -> Breakdown:
	var cfg: Dictionary = config(gd).npc
	var b := Breakdown.new("Edge score")
	b.base("No edge", 0.0)
	var lc: Dictionary = rec.get("linh_can", {})
	var elements: Dictionary = lc.get("elements", {})
	if not elements.is_empty():
		var avg: float = 0.0
		for e in elements.keys():
			avg += float(elements[e])
		avg /= float(elements.size())
		var sr: Dictionary = cfg.strong_root
		var frac: float = clampf((avg - float(sr.purity_from)) / (float(sr.purity_to) - float(sr.purity_from)), 0.0, 1.0)
		if frac > 0.0:
			b.add("Strong linh căn (purity %d)" % int(avg), frac * float(sr.weight))
		var bd: int = lc.get("variants", {}).size()
		if bd > 0:
			b.add("Biến dị ×%d" % bd, minf(float(bd) * float(sr.per_variant), float(sr.variant_max)))
	var rank: String = str(rec.get("sect_rank", ""))
	if cfg.sect_rank.has(rank):
		b.add("Valued by the sect (%s)" % rank, float(cfg.sect_rank[rank]))
	if str(rec.get("background", "")) == "rich_family":
		b.add("Rich family", float(cfg.rich_family.weight))
	for id in rec.get("perks", []):
		var p: Dictionary = perk(gd, str(id))
		if not p.is_empty():
			b.add("Blessing: %s" % p.name, float(cfg.blessing.weight))
	return b


## Chance (0..1) that an NPC makes its next realm breakthrough, as a breakdown.
static func npc_step_chance(rec: Dictionary, gd: GameData) -> Breakdown:
	var cfg: Dictionary = config(gd).npc
	var score: Breakdown = npc_edge_score(rec, gd)
	var b := Breakdown.new("Breakthrough chance (NPC)")
	b.base("Baseline", float(cfg.base_step))
	for step in score.steps:
		if str(step.op) == "+" and float(step.value) != 0.0:
			b.add(str(step.label), float(step.value) * (float(cfg.max_step) - float(cfg.base_step)))
	for id in rec.get("capabilities", []):
		var fx: Dictionary = gd.capability(int(id)).get("npc_effect", {})
		if str(fx.get("type", "")) == "p_step_add":
			b.add("Capability: %s" % gd.capability(int(id)).name, float(fx.value))
	b.clamp_to(float(cfg.base_step), float(cfg.max_step))
	return b
