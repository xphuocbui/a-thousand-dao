# Content Formats

What a build is made of, and where the live rules are. Numbers live in the sources, so read them
there. This file says what to look for.

## Sources to read

| Build touches | Read |
|---|---|
| Any fight | `design/gdd/combat.md`: rules 10, 13, 22 to 24, Formulas A2, C, D, E |
| Tags and modifiers | `design/gdd/combat.md`: rules 5, 6 and Formulas B |
| Techniques | `design/gdd/cong-phap.md`: rules 1 to 6, 12, 13, Formulas D, F; `assets/data/items_cong_phap.json` |
| Spiritual root and elements | `assets/data/character_elements.json`, `design/gdd/linh-can.md` |
| Artifacts | `assets/data/items_artifacts.json`, `design/gdd/item-database.md` rule 6 |
| Talismans, formations, beasts | `assets/data/crafting_talismans.json`, `crafting_formations.json`, `creatures_linh_thu.json`, and the quick specs in `design/quick-specs/` |
| Tree nodes | `design/quick-specs/tree-modifier-catalogue.md`, `design/gdd/kinh-mach-do.md` capability table |
| The Way | `design/gdd/dao.md` |
| Stat keys | `design/gdd/character-stats.md`, the key groups table |
| Tone and pillars | `design/gdd/game-concept.md` |
| Registry values | `design/registry/entities.yaml`, grep by name |

## Technique record

A template in `items_cong_phap.json`:

```json
{"id": "slug", "name": "Tên Hán-Việt", "tier": 2, "tech_kind": "main",
 "names": ["kim"], "layers": 12,
 "bonuses": [{"stat": "linh_luc_pct", "value": 12}],
 "abilities": [{"ability_id": "slug", "unlock_layer": 4}],
 "seal_clusters": [], "origin": "authored"}
```

- `tech_kind`: `main` (sets cultivation speed and technique power), `secret` (auxiliary, names
  elements) or `body` (auxiliary, names no element, scales with Physique, feeds body guard).
- A character has one main slot and `aux_slots` auxiliary slots. A second main needs capability #6.
- `tier` sets layers, bonus budget, maximum realm and price. A high tier is never a strict upgrade.
- `value` is at full mastery. Check `Σ value / pool_max(stat) ≤ bonus_budget[tier]`, and each value
  against `bonus_single_cap` (cong-phap.md Formulas D; `pool_max` comes from `bonus_pool`).
- **Today every shipped template has an empty `abilities` list.** The catalogue does not exist yet
  (Combat Open Question 13), so a build's divine abilities are new content, written as art records.

## Art record

A divine ability, Way art, artifact effect or talisman, in the format of Combat rule 13. There is no
JSON format yet, so write the fields plainly:

| Field | Meaning |
|---|---|
| id, name | Slug, and a name in Hán-Việt with English |
| source | Which technique, layer, item or node gives it |
| tags | Element, form, kind, mode, source, effect (Combat rule 6). Unknown tags are `Needs key` |
| kind | body, qi or soul |
| c_art | Coefficient, inside the art lint (Combat Formulas C) |
| cost_share | Share of maximum linh lực, or `body_cost_share` for health |
| cooldown | Seconds, at least `cooldown_min`. First firing is one cooldown in |
| guard | Optional, one condition from rule 13's vocabulary. Talismans and escape need one |
| effect | What it does, in rule terms: hit, status, curse, trigger, conversion, ward |

Keep the mechanics in the effect line and the flavour in a separate one-line description.

## Items

- **Artifacts:** a `base` from `items_artifacts.json`, a `grade`, a realm `tier`, and affixes. Roles
  are weapon, ward, body or utility (item-database.md rule 6). Each piece costs thần thức, and the
  equipped set is limited by that and by `equip.max_slots`. Bases: read the file. New bases are
  `Needs key`, and a named signature artifact is fine as a generated item with authored flavour.
- **Talismans:** an art used up when it fires, with stock. It takes an art slot.
- **Pills:** preparation only, through Alchemy.
- **Formations:** preparation, filling layer L4 and ground tags (Combat rule 12).
- **Spirit beast:** one companion, its power share and one fixed art (Combat rule 19, Formulas J).

## Tree and Way

- **Node modifiers:** small and notable values from the catalogue, sized by W.
- **Keystones:** rule-benders. Reuse the catalogue's or propose one, tagged `Needs rule`.
- **Way (Đạo):** a build may name its Dao and the nodes it wants. Art nodes are on hold until Combat is approved.
- W fills only layer L1. "Increased" tagged bonuses can be W-priced; "more" bonuses in L2 to L5 cannot.

## The fight in brief

- Time is true seconds, with a 1 s pulse for regeneration, ticks and durations.
- Costs are a share of maximum, so a bigger pool buys no extra casts. Spending linh lực weakens your ward.
- The basic attack always runs. An art waits ready until its guard and cost allow.
- Art speed divides cooldowns (+100 % halves them). Sources add.
- Soul attacks skip wards and body guard, and are small between equals.
- Layers: bonuses add inside a layer and multiply across layers.

Check these against the GDD on each run, because they may have changed.
