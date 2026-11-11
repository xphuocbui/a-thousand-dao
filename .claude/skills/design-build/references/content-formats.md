# Content Formats

What a build's pieces look like on the page, and where the live rules are. `system-roles.md` says which
system should carry what; `combat-model.md` says how the fight treats it.

## Where to look

The fight's numbers come from `python .claude/skills/design-build/scripts/fight.py --numbers`, checked
against the GDDs; how the fight behaves is in `combat-model.md`. The places below are **lookups: Grep for
the rule, key or id, and read only the lines around it** (about 40). Never read a GDD section whole for
numbers the digest already gives.

| Build touches | Grep in |
|---|---|
| A fight rule to cite in a `Needs rule` piece | `design/gdd/combat.md` (offence, time, linh lực, statuses, triggers), `design/gdd/combat-defence.md` (wards, resistance, block, shields, healing, the ward and body layers) |
| Tags and modifier keys | `design/gdd/modifiers.md` Stat List, by key |
| Statuses, curses, Effects to reuse | `design/gdd/effects.md` Status Catalogue and Starter Effects, by name or keyword |
| Techniques | `design/gdd/cong-phap.md`: rules 1 to 6, 12, 13, Formulas D, F; `assets/data/items_cong_phap.json` |
| Spiritual root and elements | `assets/data/character_elements.json`, `design/gdd/linh-can.md` |
| Artifacts | `assets/data/items_artifacts.json`, `design/gdd/item-database.md` rule 6 |
| Talismans, formations, beasts | `assets/data/crafting_talismans.json`, `crafting_formations.json`, `creatures_linh_thu.json`, and the quick specs in `design/quick-specs/` |
| Modifiers, tree and clusters | `design/quick-specs/tree-modifier-catalogue.md`, `design/gdd/kinh-mach-do.md` rules 6, 12, 16, `assets/data/meridian_capabilities.json` |
| What earlier builds made | `design/builds/content-ledger.md` |
| The Way | `design/gdd/dao.md` Catalogue, by Way name; its rules only to cite one |
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

`design/builds/[slug].fight.json`, read by `scripts/fight.py`, which runs it on the combat simulator
(`tools/design/combat_sim/sim.py`). `realm`, `layers` and `arts` are required; every other field is
optional and defaults to the typical anchor. Write one file for the defining realm, and change `realm` and
the points for a second run. **A field the loader does not know stops the run** (`UNKNOWN_FIELD`), so a
result never silently ignores part of the build.

**`layers` holds only what applies to every channel:** `attack_pct` and untagged sources in L1, gear in L3,
and the untagged L2, L4 and L5 points. A tag-scoped modifier goes in the `x` of the art it touches, added on
top. Putting "Fire more" in `layers` also feeds it to the basic attack, and the result is wrong in a way that
looks like a strong build.

```json
{
  "name": "slug", "realm": "ket_dan",
  "layers": [120, 80, 40, 20, 0],
  "crit": {"chance": 0.1, "mult": 1.5},
  "n_body": 1.2, "n_qi": 1.1,
  "art_speed_pct": 30, "art_cost_pct": 10, "art_cost_health_pct": 0,
  "regen_bonus_pp": 2, "health_regen_pp": 0, "healing_pct": 0,
  "evade_pct": 0, "accuracy_pct": 0,
  "gain_on_hit_pct": 0, "leech_qi_pct": 0, "leech_health_pct": 0,
  "ward": {"model": "drain", "payload": 342.5, "drain_base": 0.328, "ws_base": 40, "we": 40,
           "layers": [40, 40, 20, 10], "block": 15},
  "body": {"block": 30, "resistance": 25, "shield": 0.3, "layers": [40, 47, 20, 0]},
  "cleanse": {"per_pulse": 0, "fee_share": 0, "share": 0.25},
  "keystones": {"k_burn": 0.5},
  "curses": ["withering"],
  "purity": {"fire": 80},
  "bonus_slots": 0,
  "arts": [{"id": "slug", "c_art": 2.9, "cost_share": 0.06, "cooldown": 3, "element": "fire", "kind": "elem",
            "buff": [1, 10], "debuff": [2, 6], "c_heal": 0, "qi_restore": 0, "cleanse": 0,
            "x": [0, 20, 0, 0, 0]}],
  "enemy": "typical",
  "enemy_overrides": {"ward": {"ws_base": 200}},
  "unmodelled": ["what this file cannot express, one line each"]
}
```

- **Numbers are GDD units.** `cost_share` is the #44 share (0.02–0.125); `drain_base` the #44 ward record
  (the Common Ward 0.328); `regen_bonus_pp` and `health_regen_pp` are percentage points a pulse; the `_pct`
  fields are percent. The loader converts them to the simulator's units.
- **Ward** (Combat Defence & Healing A0, A, C): `model` is `drain`, `default` (60 points, drain 0.40, no ws)
  or `off`. `payload` is the ward's resistance points at ws 0; `ws_base` the additive ward strength (gear
  included); `layers` the ward layers W2–W5 (W3 is gear: `100 · 0.47 · a_w`). With no `ward` the build has
  the realm's typical Common Ward. Per-hit, reserved and cast wards, shields and soul wards: model the
  nearest drain ward and list the real one in `unmodelled`.
- **Body** (A0, A, A2, B, E): base block rating, base body resistance in points and the body shield's
  share of health; `layers` are B2–B5 (B3 is body gear: `100 · 0.47 · a_b`). The layers scale block,
  resistance and health regeneration, never the shield. `ward.block` is the unscaled rest (flesh, ward gear).
- **Arts:** `kind` is `phys` or `elem`; `element` one of fire, water, earth, metal, wood, thunder, wind, ice;
  `buff` and `debuff` are `[stacks, seconds]` of that element's stacks (Effects System Formulas D). The
  loader prints `lint_over` for an art above the art lint (or a heal above the heal lint), and `range` for a
  cost or cooldown outside the GDD's range.
- **Keystones** are the simulator's `k_` fields (linh lực keystones from the builds-by-root catalogue);
  `curses` takes `withering` and `stagnation`.
- **Enemies:** `typical`, `top_end` (every offence and ward layer at cap) and `top_end_the_tu` (every body
  layer at cap, the default ward). They are exact at Qi Refining and fitted elsewhere. Use
  `enemy_overrides` (same fields as a build) to shape a matchup, such as a heavy ward or a cleanser.
- **Not modelled by the simulator:** soul attacks, companions, triggers, conversion, curses other than
  Withering and Stagnation, guards and conditions (an art waits only for its cost), shields beyond the body
  shield, escape. A build whose engine is one of these gets `NOT ASSESSED` on the fight, with the nearest
  approximation run and the real piece in `unmodelled`.

## The fight in brief

- Time is true seconds, with a 1 s pulse for regeneration, ticks, stacks and fatigue. Fatigue starts at
  60 s and grows each pulse, so every fight ends.
- A typical same-realm fight lasts 30–60 s. Linh lực running dry decides it: the ward falls and hits land
  nearly whole. A top-end build ends an ordinary fight in a volley or two, and a top-end mirror lasts as
  long as a typical one, because top-end wards (and the body, for a thể tu) grow with top-end offence.
- Costs are a share of maximum, so a bigger pool buys no extra casts. Heal arts refund their cost when
  they heal.
- The basic attack always runs. An art fires when it is off cooldown and affordable.
- Art speed divides cooldowns (+100 % halves them), down to 0.5 s.
- Layers: bonuses add inside a layer and multiply across layers. The ward and body layers work the same
  way on defence.

Check these against the GDD on each run, because they may have changed.
