# Content Formats

What a build's pieces look like on the page, and where the live rules are. Numbers live in the
sources, so read them there. `system-roles.md` says which system should carry what; `combat-model.md`
says how the fight treats it.

## Sources to read

| Build touches | Read |
|---|---|
| Any fight | `design/gdd/combat.md`: rules 10, 13, 22 to 24, Formulas A2, C, D, E |
| Tags and modifiers | `design/gdd/combat.md`: rules 5, 6 and Formulas B |
| Statuses, curses, triggers | `design/gdd/combat.md`: rules 7 to 9, Formulas F, G |
| Techniques | `design/gdd/cong-phap.md`: rules 1 to 6, 12, 13, Formulas D, F; `assets/data/items_cong_phap.json` |
| Spiritual root and elements | `assets/data/character_elements.json`, `design/gdd/linh-can.md` |
| Artifacts | `assets/data/items_artifacts.json`, `design/gdd/item-database.md` rule 6 |
| Talismans, formations, beasts | `assets/data/crafting_talismans.json`, `crafting_formations.json`, `creatures_linh_thu.json`, and the quick specs in `design/quick-specs/` |
| Modifiers, tree and clusters | `design/quick-specs/tree-modifier-catalogue.md`, `design/gdd/kinh-mach-do.md` rules 6, 12, 16, `assets/data/meridian_capabilities.json` |
| What earlier builds made | `design/builds/content-ledger.md` |
| The Way | `design/gdd/dao.md`: rules 1 to 5, 12, Formulas D1 |
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

## Modifier record

One row in the sheet's Stack table, and the same fields in the ledger:

| Field | Meaning |
|---|---|
| Rung | Its place on the stack ladder (`modifier-forge.md`) |
| Name | English with Hán-Việt, named after what it does, never after the build |
| Effect | The whole modifier in one line: size, what it changes, scope, condition |
| Form | One of the forge's fourteen forms |
| Channel | Which damage channel it serves, or `any` |
| Layer | L1 to L5, or `none` |
| Status | ● exists, ◐ designed, ○ new, as in the catalogue |
| Home | Which system carries it |
| Second home | Another build that wants it, or `signature` |

## Tree, clusters and Way

- **Node modifiers:** small and notable values from the catalogue, sized by W.
- **Keystones:** rule-benders. Reuse the catalogue's or propose one, tagged `Needs rule`.
- **Hidden cluster idea:** a theme, element affinity, kind, seal condition, size, the small acupoints in
  words, the notables, and any capability. It is an idea for the catalogue, never data.
- **Way (Đạo):** either name an existing Đạo and the nodes wanted, or propose a Đạo or branch: requirement,
  `theme_stats`, three named branches, and the keystone. List the nodes that matter and describe the rest.
- W fills only layer L1. "Increased" tagged bonuses can be W-priced; "more" bonuses in L2 to L5 cannot.

## Fight input

`design/builds/[slug].fight.json`, read by `scripts/fight_calc.py`. Every field except `realm` is optional.
Write one file for the defining realm, and change `realm` and the points for a second run.

**`layers` holds only what applies to every channel:** `attack_pct` and untagged sources in L1, and gear in
L3. A tag-scoped modifier goes in the `x` of the art or status it touches, added on top. Putting "Poison
more" in `layers` also feeds it to the basic attack, and the result is wrong in a way that looks like a
strong build.

```json
{
  "name": "slug", "realm": "ket_dan", "stage": 1.0,
  "n_body": 1.2, "n_qi": 1.1,
  "start_qi": 1.0,
  "layers": [120, 80, 40, 20, 0],
  "crit": {"chance": 0.1, "mult": 1.5},
  "art_speed_pct": 30, "art_cost_pct": 10, "regen_bonus_pct": 2, "pierce_pct": 0,
  "evade_pct": 0, "accuracy_pct": 0, "soul_res_pct": 0, "x_soul": 0,
  "divine_sense": 1.0, "enemy_divine_sense": 1.0,
  "ward": {"model": "drain", "pass": {"body": 0.54, "qi": 0.36},
           "drain": {"body": 1.0, "qi": 1.5}, "ws": 40, "we": 40},
  "guard": {"a_b": 0, "t_b": 0, "body_guard_pct": 20},
  "basic": {"c": 1.0, "kind": "body"},
  "companion": {"c_comp": 0.4, "kind": "body"},
  "arts": [{"id": "slug", "kind": "qi", "c_art": 3.0, "cost_share": 0.12, "cooldown": 3,
            "x": [0, 20, 0, 0, 0],
            "guard": {"who": "enemy", "pool": "qi", "below": 0.3},
            "applies": [{"id": "rot", "kind": "body", "c_tick": 0.3, "duration": 4, "stacks": 1}],
            "curse": {"shred": 0.2, "duration": 3}}],
  "aura": [{"id": "rot", "kind": "body", "c_tick": 0.3, "stacks": 1}],
  "triggers": [{"source": "art", "chance": 1.0, "c_trig": 0.5, "kind": "qi"}],
  "conditional_mods": [{"id": "name", "layer": 5, "points": 30, "channels": ["art", "basic"],
                        "guard": {"who": "enemy", "pool": "qi", "below": 0.05}},
                       {"id": "name", "layer": 2, "per": "enemy_curses", "points_per": 5}],
  "enemy": "typical",
  "enemy_overrides": {"ward": {"ws": 200}},
  "unmodelled": ["what this file cannot express, one line each"]
}
```

- Ward models: `drain`, `default`, `off`, `per_hit` (`hit_cost_share`), `per_pulse` (`upkeep_share`).
- `aura` is a tick with no slot, applied at t = 0. `applies` is a status from an art. Statuses take an
  `x` too. Build-level rule-benders: `reserve_share`, `tick_overflow_qi` (share of clipped tick damage that
  burns linh lực), `dot_cap_bonus` (added to both tick caps). Other art fields:
  `parts` for conversion (`[{"share": 0.6, "kind": "body"}, {"share": 0.4, "kind": "qi", "x": [...]}]`),
  `soul_pct`, `body_cost_share`, `stock`, `refund_qi_share`.
- Curse fields: `shred`, `pass_raise`, `drain_raise`, `cost_raise`, `block_regen`, `duration`.
- Guards and conditions: `{"who": "own|enemy", "pool": "health|qi", "below|above": share}`,
  `{"who": ..., "status": id}`, `{"time_above": seconds}`, `{"on_beat": true}` (same millisecond as a pulse).
- `per` values: `own_qi_missing_pct`, `own_health_missing_pct`, `enemy_qi_missing_pct`,
  `enemy_health_missing_pct`, `fight_seconds`, `enemy_status_stacks`, `enemy_curses`, `empty_slots`.
- Enemies are `typical` and `top_end`, built from the Formulas B anchors. They are exact at Qi Refining
  and fitted elsewhere. Use `enemy_overrides` to shape a matchup, such as a heavy ward or a drainer.
- **Anything the file cannot express goes in `unmodelled`.** Leaving it out makes the result look more
  complete than it is. Rule-benders usually land here, or an approximation is noted there.

## The fight in brief

- Time is true seconds, with a 1 s pulse for regeneration, ticks and durations.
- Costs are a share of maximum, so a bigger pool buys no extra casts. Spending linh lực weakens your ward.
- The basic attack always runs. An art waits ready until its guard and cost allow.
- Art speed divides cooldowns (+100 % halves them). Sources add.
- Soul attacks skip wards and body guard, and are small between equals.
- Layers: bonuses add inside a layer and multiply across layers.

Check these against the GDD on each run, because they may have changed.
