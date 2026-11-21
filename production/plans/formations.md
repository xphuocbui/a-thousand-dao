# Plan: Formations (Trận Pháp, systems index #17), parked 2026-11-21

Status: **resumed 2026-11-21; GDD written: design/gdd/formations.md (Designed, pending review).** Earlier: parked by the user ("put the plan there for now, we will come back to it"), at the start of
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

## Build, 2026-11-21 evening (user away: "continue with the implementation of relationships and formations")

The build reads the approved GDD's working copy (blob `8f2cdf8a`, unchanged since 16:35). **The catalogue is not
built**: Open Question 4 says the first catalogue (diagrams, shapes, node rules, `reserve_share`, `cost_lt[grade]`)
is the user's to hand-author, so `assets/data/crafting_diagrams.json` ships `"diagrams": []` and every combatant fights
with the default line until it is filled.

### Built

- **`Diagrams`** (`src/gameplay/crafting/diagrams.gd`), data `crafting_diagrams.json`:
  - F1 strength and F1's scaling (drawbacks by the share only, polarity not sign);
  - rule 7's effective level (skill cap, the keystone's +2 after the caps);
  - F2 lay fuel (with the 1e-6 tolerance), F3 raise cost, F6 reservation;
  - rules 3 and 9a: the node budget and the reservation cap;
  - F4 placement and the NPC's choice (ties to fewer nodes, then id; at or below fit_min the default line);
  - rule 9's laying (`prepare`): foreseen and affordable, the fuel burnt as `formation` (Formula H's
    `burn_formation`), the player from the Character's purse, an NPC from its ledger purse; otherwise carried at the
    share;
  - `apply`: compiles a diagram into a FighterProfile (node order first, plain slots after; Modifier nodes as per-art
    `node_speed_pct` / `node_cost_pct` / damage `m_mult`; adjacency Modifier nodes; gate nodes as guards; feeds; the
    reservation) on copies of the shared arts; `compile_for`: the Set diagram (Character `diagram`) or an NPC's best
    fit, wired into the event fight check for both sides.
- **The fight engine** (`fight.gd`): node art speed and cost; `_feed` after each firing (floored at cooldown_min,
  never raising a timer, a FEED log row). The python sim is untouched (nodes are 0 without a diagram).
- **Arrays** (`formations.gd`): builds and upkeep burnt through MoneyLedger as `formation`; F5's protective array
  (`protective`, `trigger_protective`: once per event, only when the owner can pay); data `protective` in
  `crafting_formations.json`.
- Tests: `tests/unit/crafting/diagrams_test.gd` (AC-FO-01, 02, 03, 04, 05, 12, 17, 18, 19, 20, 24, 26) and
  `formations_burn_test.gd` (AC-FO-08, 09, 12's purse, 15, burn_formation). Watched failing: the feed floor, laying
  without the fuel.

### Not built, and why (decisions for the user)

1. **The catalogue** (Open Question 4): yours to author; nothing is invented here.
2. **Effect nodes** ("fires one extra time below 40 % health", AC-FO-04's first case): an Effect node needs its own
   Effect record in the fight's EffectRunner; built when the catalogue names one.
3. **Crafting diagrams** (rule 8, Open Question 5): the node count by grade and the pool of rolled rules are open.
4. **The preparation screen, the terminal diagram commands and raising a diagram's level at the abode** (UI, AC-FO-23):
   with `/ux-design` and the catalogue.
5. **Teleport arrays** stay Travel & Map's fee (rule 15; no second burn, already built). **Sect-owned arrays** and
   which events trigger a protective array (Open Question 7) wait on Sects.
6. **Standing arrays' dormant and left-behind states** (rule 14) wait on Cave Abode (#47), designed but not built.
7. **Situation:** the event fight check passes Combat's default `FORESEEN`; where events set ambush or blind, the
   share follows.
8. **The node-rule schema is provisional:** the GDD names Modifier, Effect and gate nodes but no record format; the
   build uses `{type: mod | adj_mod | gate, key: art_speed_pct | art_cost_pct | damage_pct, value, scope, tag, cond}`.
   The catalogue may change it.
9. **Only the event fight check compiles diagrams.** The trial-fight odds (event_resolver's 24 keyed fights) and Power
   Rankings' compiles do not, so shown odds and ratings will ignore a diagram once the catalogue exists; wire them
   then (the fuel is paid only after a fight runs, so trial fights must decide without paying).
10. **Laying is automatic unless the Set diagram says `lay: false`;** the preparation screen will give the choice.
11. **This session edited `formations.gd` and `crafting_formations.json`** after telling the design session it would
   stay out of them (the user then asked for the implementation); the Cave Abode design session may touch standing
   arrays: check before both edit the same file.
