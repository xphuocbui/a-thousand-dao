# Plan: Formations (Trận Pháp, systems index #17), parked 2026-11-21

Status: **parked by the user** ("put the plan there for now, we will come back to it"), at the start of
`/design-system formations`, after Phase 2 (context gathered), before the skeleton. Resume with
`/design-system formations`; no `design/gdd/formations.md` exists yet.

How it started: the world economy's decision 7 (stone sinks: formation fuel, crafting fuel, the cave abode) turned into
"design what formations actually do first" (user, 2026-11-21).

## The user's decisions (2026-11-21)

1. **One Formations GDD in two parts:** home and world arrays (Tụ Linh, Thanh Mộc, Hộ Sơn, teleport and protective
   arrays, burning linh thạch as fuel) and combat formation diagrams.
2. **The diagram is the loadout.** A combat formation diagram (trận đồ) replaces Combat's plain art-slot row: each node
   is an art slot with its own rule, and links between nodes let arts feed each other. The arrangement is the build.
3. **Many diagrams, of any shape, not element-themed** (Ngũ Hành was one example only). E.g. a ring plus a centre: the
   ring's slots all get increased art cooldown, the centre decreased. **A slot may carry a positive effect, a negative
   effect, or a condition.** Lots of formations to choose from; players unlock them when they are able to.
4. **Sources: crafted** (positions rolled like an artifact's affixes) **and taught** by công pháp / formation manuals.
5. **Fuel: per fight laid.** Laying a diagram for a foreseen fight burns linh thạch by its size and grade; a carried
   diagram follows Combat's carried-ground share (100 % foreseen, 70 % ambush, 50 % blind).

## Context gathered (Phase 2)

- **Today:** quick spec `design/quick-specs/luyen-khi-and-tran-phap.md` (implemented 2026-11-03): three home arrays
  raised by level (cost_lt × cost_growth^(L−1) plus materials; max level min(max_level, skill + 1); yearly upkeep
  Σ levels × upkeep_lt_per_level, cut by Thổ purity); `assets/data/crafting_formations.json`;
  `src/gameplay/crafting/formations.gd`; the Trận Pháp skill to level 9.
- **Index row:** Economy, Alpha, Feature; depends on Item Database, Character Stats, Time & Turn (and Modifier System
  #40, Effects System #41).
- **Downstream:** Combat (approved: rule 12's laid formation and carried ground, "one formation per side away from
  home, every standing home formation at your own abode"); Regional Economy #43 Formula H (the sink ledger); Travel &
  Map (Tụ Linh counts as a layer-1 work); Sects (teleport arrays); Cultivation Techniques (teaching diagrams); NPC
  Builds (NPC loadouts).
- **Constraints to respect:**
  - Combat rule 13 and Formulas A2: one art pool of `slot_count = slots_by_realm (3/4/5/6/7) + bonus_slots`, no cap;
    each art on its own cooldown; slot order settles ties and the hit order; kind-locked slots sit outside the pool.
    The diagram must say how its node count relates to slot_count.
  - Existing keys and Effects that read formations: `formation_power_pct` (Field Walls: half of formation power counts
    as ward strength), a formation's **level** (keystone Formation Within a Formation, +2 levels), "while your own
    formation stands" (Earth Vein Tap), `formation_upkeep_pct`. Combat diagrams must keep these meaningful.
  - Modifier vs Effect (memory): a slot's plain number is a Modifier; a slot rule with a condition is an Effect.
  - Linh thạch is money only; every new sink is booked in #43 Formula H.
- **Pillars:** 3 (Power Is Built, Not Given), 2 (Every Number Is Bounded and Visible).
- **Feasibility:** Godot 4.7.1, domain Scripting: no engine reference for `scripting` under
  `docs/engine-reference/godot/modules/`, so feasibility is not checked against the pinned engine; pure rules and
  data, no engine risk expected.

## Open questions for when we resume

- How a diagram's node count relates to `slot_count` (equal, at most, or the diagram adds nodes).
- What a link does (order, triggers, shared tags, cooldown feeding) and how links show in the fight's Breakdown.
- What makes a diagram stronger (grade, level, Trận Pháp skill, formation_power_pct) and the fuel formula.
- NPC loadouts: how the NPC generator picks and arranges a diagram.
- Home and world arrays: teleport and protective arrays, their fuel, who owns sect arrays.
