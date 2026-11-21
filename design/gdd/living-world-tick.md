# Living World Tick

> **Status**: Designed 2026-11-15 (pending review; lean mode, no specialist lenses run)
> **Author**: user + Claude
> **Last Updated**: 2026-11-15
> **Last Verified**: 2026-11-15
> **Implements Pillar**: A World That Remembers; Every Season Counts (game-concept.md § Game Pillars); anti-pillar: not a granular world simulation

## Summary

Once each season the world moves without the player: every non-player cultivator ages, heals, trains at a pace set by talent and place, may break through (the fixed cast by authored fates) or die of old age (leaving an estate and, for a sect leader, a successor), the world refills to its 5,000 cultivators and its wild beasts, one rare duel may happen, and the tick then calls the other seasonal systems (Sects, Travel & Map, Regional Economy, NPC events, NPC Traits, Power Rankings) in one fixed order. It does no per-body, per-item or per-tile simulation. News lines (tin đồn) about people the player knows, or events big enough to matter, tell the player what they would hear; after long seclusion a digest sums up the years; once a year old records are compacted so the save stays small.

> **Quick reference** — Layer: `Feature` · Priority: `Vertical Slice` · Key deps: `World DB, Realms, NPC Builds, Edges (NPC half), Time & Turn; calls Sects & Missions, Travel & Map, Regional Economy & Trade, Event Engine, NPC Traits, Power Rankings`

## Overview

The Living World Tick is the one place where the season passes for everyone except the player. The player's own season (cultivating, travelling, resting) is resolved first by the session; the tick then advances the world's 5,000 cultivators by one season and runs, in a fixed order, the seasonal step that every other world system owns. It is **abstract by design**: the land is fixed, the history is authored, and the tick changes only records (age, stage, realm, life, wealth, sect membership, a rare duel's result) and a news log, never positions on a path or items one by one (anti-pillar in game-concept.md). It is automatic: the player never operates it, they hear what it did as news, as changed prices and sects, and as the people they know ageing, rising or dying. Without it the world would stand still between visits, and *A World That Remembers* and *Every Season Counts* would be empty.

This GDD describes a system that is **partly built**. The people step, intake, the duel and item decay exist in `src/gameplay/world/world_ticker.gd`; the calls into Sects, Travel & Map, Regional Economy, NPC events and NPC Traits are owned by GDDs that are designed but not built. Every rule and step below is marked **Built**, **Changed** (built, and this GDD alters it) or **To build**.

## Detailed Design

### Core Rules

1. **One tick per season, for the whole world.** The session calls the tick once each time a season passes, whatever the player did (cultivate, travel, closed-door, rest). A bulk command of *n* seasons calls it *n* times, in order. A year rollover runs the session's yearly step first. *(Built.)*
2. **The player is never touched.** The tick skips the record flagged `is_player`. The player's own ageing, cultivation and death stay with the session. *(Built.)*
3. **Season order is fixed** (table below). A step reads only what earlier steps in the same tick, or earlier ticks, wrote; no step reads a value a later step writes this season. Each callee GDD owns the inside of its step; this GDD owns the order, the hand-offs and the budget.
4. **The people step (S2).** For every living non-player person, in World DB table order: add `1 / seasons_per_year` to `age`; if `age` ≥ lifespan, the person dies of old age (rule 9) and takes no further step; otherwise:
   - **Recovery.** Vitality recovers by the player's own rule: `vitality = min(vitality + injury_recovery_frac_per_season, 1)` (0.25, `character_attributes.json`). Heart demon (tâm ma) and pill poison (đan độc) are not tracked for NPCs. *(To build: today NPC injuries from events never heal, so their rating roll stays lowered for life.)*
   - **Stage.** Below the last stage of the realm, the person advances one stage with chance `p_stage_i` (Formulas A, scaled by talent and place, Formulas H), which raises `level` to the new stage's first level and refreshes the stored power. *(Changed: today the chance is the same for everyone.)*
   - **Breakthrough.** At the last stage, if a next realm exists: on first reaching the bình cảnh (bottleneck) of a realm, the person's fate for that realm is set once and stored in `bt_fate`: **authored** for a fixed-cast member who has an authored fate for that realm (rule 15), otherwise **rolled** from Progression Edges' per-gate NPC odds. A fated person breaks through with chance `p_bt` each season (Formulas B), moving to the next realm, stage 0, and logging a `tick_breakthrough` event. An unfated person stays at the bình cảnh until death. NPCs never run a Heavenly Tribulation (Thiên Kiếp rule 1): their fate already includes it.
   - **Beasts.** An ownerless beast does nothing but age and die; a beast with an owner trains like a person. Beasts are not counted as cultivators for intake; wild beasts have their own refill (rule 16). *(Built.)*
5. **Intake keeps the headcount (S3).** After the people step, the tick spawns `spawn` new Qi Refining (Luyện Khí) cultivators at age 16 (Formulas C), counted against the cultivator target `max(world_cultivators, world_cultivators_min)`. The target, not the population, drives it, so the headcount cannot drift (canh-gioi.md rule 12, decision 2026-11-05). New people are born into a **pool** with no sect. *(Changed: today the ticker places 90 % into sects by a fixed share.)* **Births** (user decision 2026-11-21): `birth_share` (0.3, a guess) of each season's intake are born to a living cultivator instead of a random newcomer: a living ordinary NPC aged at least 16 + `parent_age_gap` with fewer than `children_max` children (World Generation rule 8, Families). The child (16, Qi Refining) starts where the parent is, takes the surname and `parent_id`, joins the parent's sect as an intake member when the parent has one, and holds kin with the parent and siblings. The count is unchanged, so the headcount and the census do not move.
6. **Sects claim the pool (S5, decided 2026-11-15).** The tick alone creates people. Sects & Missions' F17 gives each sect a demand for new Qi Refining members; the Sects tick turns demand into claims on this season's pool (Formulas D) and sets rank by realm (Sects rule 19). A new cultivator no sect claims is **loose**, placed at a place rolled as built. The fixed `intake_sect_share` (0.9) and `intake_rank_shares` retire. *(Changed; needs edits to canh-gioi.md rule 12 and the progression config, see Open Questions 1.)*
7. **One rare duel (S4).** With chance `event_chance_per_season` the tick picks two living non-player, non-beast people by a shuffle on the session stream and resolves their duel by Power Rankings' world-fight roll (one session draw; Power Rankings rule 11), or by `CombatPower.duel` when ratings are off. The result is a `tick_duel` news line. In the Vertical Slice a duel **does not kill or injure**; deaths come from old age, Sects' wars (F9) and Event Engine events. *(Built.)*
8. **Items decay in Spring.** On season 0 of each year, lost items left untouched long enough decay (Item Database rule 14) before the people step, with a `tick_item_decay` news line each. *(Built.)*
9. **Death and estate (decided 2026-11-15).** When the tick kills a person (old age), in this order: (a) mark `alive` false, record `death_cause` and `death_year`, log `tick_death`; (b) items pass to the heir named by `Inheritance.heir_of`, or become Lost where the person died (Item Database rule 14); (c) the **purse** (`linh_thach`) follows the items: to the heir if there is one; else to the treasury of the person's sect if they were a member; else it is counted in `W_dead` for the region (Regional Economy F, burned from the economy); (d) if the person led a sect, the tick calls Sects' succession (rule 15) immediately, so no sect has a dead leader at any later step. Stones are conserved: purse before = heir + treasury + `W_dead`. *(Built for a–b and d; **To build** for c.)*
10. **Succession belongs to Sects.** The tick never picks a successor. It calls Sects' succession and logs `tick_succession` with the result. The built `_succeed_leader` moves behind that call. A succession never picks the player (Sects, as built).
11. **Deterministic streams.** The tick draws from the session stream passed in (ADR-0002 rule 1), in World DB table order, one fixed draw pattern per person (rules 4, 7). A callee that makes a variable number of draws of its own takes **one** draw from the session stream as its seed and draws from its own generator (ADR-0002 rule 3); one with order-free values uses a keyed stream (rule 4). The same seed and the same actions give the same world.
12. **News, filtered like the Event Engine's.** Every event the tick logs goes to the World DB event log, its text filled from `world_generation.json` `history.texts` by event type, naming people and places. Text stands alone with no LLM (llm-parked). An event is marked `news: true`, and so reaches the player as *tin đồn*, only when (Event Engine rule 20's test):
    - it names a person the player **knows** (Event Engine rule 19: met, holds a flag on, or with an attitude other than 0), or
    - it is **newsworthy** by the tick's list (data, `tick.news_rules`): a breakthrough into Nascent Soul (Nguyên Anh) or higher; the death of a Core Formation (Kết Đan) or higher person, a sect leader or a living fixed-cast member; a great sect's succession; a duel in which either side is on the published top list (Power Rankings).

    Everything else stays in the log only. Each season the session shows the latest `news_lines_per_season` (3, as built) news lines. *(Changed: today every tick event is news, so three strangers a season crowd out what matters.)*
13. **The chronicle is read-only.** The tick appends to the event log; it never edits the authored chronicle (World Generation rule 1).
14. **No LLM in the tick.** Every step is rules and data. An LLM may narrate the news later; it cannot change a result.
15. **The fixed cast: authored fate, rolled timing (decided 2026-11-15).** A living fixed-cast member (World Generation rule 5) may carry an authored `fates` list, one entry per realm gate: *will* or *won't* break through. At the bình cảnh the tick stores that value as `bt_fate` instead of rolling (rule 4); the season it happens is still rolled by Formulas B, and stage climbs use Formulas A and H like anyone else. A gate with no authored entry is rolled. Cast members are not protected: they age, can die of old age before an authored breakthrough, and can die by events or war. So each game keeps the arcs (who can rise, who is stuck) and varies the timing. *(To build; World Generation owns the authored `fates` field.)*
16. **Wild beasts refill (S3b).** After intake, each region's ownerless beasts are topped up to the region's target by Formulas I, each new beast at a realm drawn from the region's danger. Event-spawned beasts count toward the target. Beasts never join the cultivator pool. *(To build; the targets are set with Spirit Beasts #19, provisional.)*
17. **Seclusion digest.** When one player command passes more than one season (closed-door cultivation, long travel, a rest of years), the session shows, at the end, a **digest** of the news those seasons made instead of the last 3 lines: first the totals (deaths, breakthroughs, successions, wars and changes of hands among the known and the newsworthy), then lines grouped by person the player knows, newest first, capped at `digest_lines_max` (12) with "and *n* more in the log". The digest reads the log; it adds no events. *(To build.)*
18. **Bulk runs.** A bulk command runs its ticks back to back with a progress line once a simulated year. Each tick keeps the per-season budget (Formulas G), so a century of seclusion (400 ticks) takes up to about one minute (Open Questions 7).
19. **Yearly upkeep of the log (S11, in Spring).** Once a year, after S10, the tick compacts the dead and prunes old news so the save does not grow without bound (Formulas J):
    - A person dead for more than `retain_full_years` (10) is reduced to a **stub**: id, name, sex, realm and stage, sect, birth and death year, death cause, killer, heir, place of death. The build, sheet, traits, rating and memories are dropped.
    - A log event older than `news_keep_years` (50) that was never `news: true` is deleted.
    - **Never compacted or pruned:** the fixed cast, anyone the player knows or knew, anyone named by the chronicle, an open quest or story, or a held flag, and every chronicle and `news: true` event.
    *(To build.)*
20. **NPC Relationships (S8b).** After NPC events and before traits, the tick calls NPC Relationships (#46), which applies the season's queued tie changes in its own seven sub-steps (deaths and inheritance, ends, lost-notability evictions, strength changes, new parts with eviction, hardening, then the hook pass that adds and removes the `tie` cultivation rows; `npc-relationships.md` rule 9) and touches only the people named in them; fading is computed when read, so nothing scans ties (`npc-relationships.md` rules 4, 9). Revenge and help among NPCs are this tick's choices, weighted by ties, inside the violent-death budget (Open Questions 4; NPC Relationships rule 14a); revenge may also target the player (#46 rule 15b). A kill by this tick or a Power Rankings world fight is known (it passes feuds) unless an event flags it `secret` (#46 rule 13), and S11's pruning of old events must not strip the cause payloads tie records carry (#46 rule 1b).

### The season order

| Step | What runs | Owner of the inside | Reads | Writes | State |
|---|---|---|---|---|---|
| S0 | The player's own season; year rollover and `_yearly` | Session | — | player, clock | Built |
| S1 | Finish the previous season's rating batch and apply it | Power Rankings (rule 13) | batch results | ratings | Built |
| S2 | **People step**: ageing, recovery, stage (by talent), breakthrough (authored or rolled fate), old-age death, estate, succession call; Spring item decay first; in Spring, the talent mean for Formulas H is recomputed first | This GDD | people, realms, places | people, items, events | Built (recovery, talent, authored fate, estate purse: To build) |
| S3 | **Intake**: spawn to the target into the pool | This GDD | cultivator count | new people | Changed |
| S3b | **Wild beast refill** per region | This GDD + Spirit Beasts | beasts per region, danger | new beasts | To build |
| S4 | **Duel** (rare) | This GDD + Power Rankings | ratings | events | Built |
| S5 | **Sects season tick**: great sects, then vassals; F17 claims the pool, loose ones placed | Sects & Missions | pool, treasuries | sects, members, ranks | To build |
| S6 | **Travel & Map season update**: reserves, secret-realm cycles, fading works, ownership, contract records, regional head counts; then the **abode step**: grade upkeep and its fade clock, NPC abode raises (Cave Abode & Home Works #47 rules 8, 12) | Travel & Map; Cave Abode | sect holdings, purses | places, regions, homes | To build |
| S7 | **Regional Economy tick** (with Trade Goods): flows, prices, stock, market restock | Regional Economy & Trade | contract, `W_dead`, sects | prices, sect income | To build |
| S8 | **NPC events**: fixed cast, people the player knows, a keyed sample | Event Engine (rule 19) | everything above | people, events | To build |
| S8b | **NPC Relationships**: queued ties form, change, harden, pass to heirs, end; then the hook pass (`tie` rows) | NPC Relationships (#46) | events, deaths, breakthroughs, travel, people | ties, `tie` modifier rows | Approved (2026-11-21), to build |
| S9 | **NPC Traits season steps**: grants, expiries, modifier rows | NPC Traits | events' grants | traits, sheets | To build |
| S10 | **Start the next rating batch**; check the player's lifespan; hand news (or the digest, rule 17) to the session | Power Rankings; Session | — | batch plan | Built (digest: To build) |
| S11 | **Yearly upkeep** (Spring only): compact the dead, prune old non-news events | This GDD | log, people | stubs | To build |

Quests' world effects (offerer estates, NPC wealth and rank changes) are written by their own systems at S8 or by the player's action, not by a separate tick step.

### States and Transitions

The tick has no state of its own across seasons: its inputs are the World DB and the session stream. A single tick moves through these phases.

| Phase | Entered when | Leaves when | Notes |
|---|---|---|---|
| Idle | between seasons | the session passes a season | no work, no budget |
| Running (S1–S10) | the session calls `tick(rng, year, season)` | S10 completes | runs to completion on the main thread; the rating batch alone runs in the background (Power Rankings rule 14) |
| Done | S10 returns the news ids | the session reads them | the world is consistent: no dead leaders, headcount at target, no pending pool |

A person's life state, owned by World DB, changes here only as **Alive → Dead** (old age, rule 9). Realm and stage change only upward. Nothing in this tick returns a dead person to life.

### Interactions with Other Systems

| System | Direction | What passes | Owner of the interface |
|---|---|---|---|
| **World DB** | in / out | people, sects, places, events, items; the event log | World DB (storage); this GDD (what it writes) |
| **Realms & Bottlenecks** (canh-gioi.md) | in | lifespan, stage counts, level of a stage, headcount targets, the fate roll's odds | Realms |
| **NPC Build Generation** (#24) | in / out | `create_person` for intake; `refresh_power` after a stage or realm change | NPC Builds |
| **Progression Edges** | in | per-gate NPC breakthrough odds; `fated_breakthrough_per_season`; intake settings | Edges |
| **Time & Turn** | in | `seasons_per_year` (4), the year and season passed to the tick | Time & Turn |
| **Sects & Missions** (#26) | out / in | out: the pool, succession calls, deaths; in: F17 claims, sect season tick | Sects (the tick's inside); this GDD (the order) |
| **Travel & Map** (#25) | out / in | out: pool placement of loose cultivators, deaths; in: the seasonal map update, head counts per region | Travel & Map |
| **Regional Economy & Trade** (#43) | out / in | out: `W_dead`, the sect tick done; in: its economy tick | Regional Economy |
| **Event Engine** (#23) | out / in | out: the season's world state; in: the NPC event step | Event Engine |
| **NPC Traits** (#42) | out / in | out: events' trait grants; in: the three season steps | NPC Traits |
| **Power Rankings** | out / in | out: batch start and finish; in: world-fight rolls | Power Rankings |
| **Item Database** | out / in | out: deaths, Spring decay call; in: inheritance, Lost items | Item Database |
| **Quests** (#31) | out | the estate (purse) at death, for payouts to offerers' quest rewards | Quests (provisional) |
| **World Generation & History** (#27) | in | the fixed cast and their authored `fates` | World Generation |
| **Spiritual Roots** | in | the root curve factor (Formulas H) | Spiritual Roots |
| **Spirit Beasts** (#19) | in / out | in: beast targets per region; out: new wild beasts | Spirit Beasts (targets); this GDD (the refill) |
| **NPC Relationships** (#46) | out / in | out: the S8b step, the season's deaths, rescues and betrayals; in: ties as weights for help and revenge | NPC Relationships |
| **Save / Load** | out | stubs and a pruned log | Save / Load |

## Formulas

### A. Stage chance

`p_stage_i = min( m_i / max(N_stage, 1), 1 )`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| N_stage | int | ≥ 1 | data file (`world_generation.json` tick.`npc_cultivation_seasons_per_stage`) | Seasons the average unboosted NPC takes per stage; 14 (was 12: the money speed-up, ×1.16 on average, user decision 2026-11-20, brings the average back to 12; retune 2026-11-21, stage_boost_probe.gd) |
| m_i | float | 0.5 – 2.0 before normalising | Formulas H | The person's talent and place multiplier; 1 for an owned beast |
| p_stage_i | float | (0, 1] | calculated | The person's chance per season of one stage |

**Output Range:** (0, 1]; 1 at N_stage ≤ m_i. **Example:** at m_i 1, N_stage 12 gives 0.0833 a season, a mean of 12 seasons (3 years) per stage. At m_i 1.55 it is 0.129 (about 8 seasons); at 0.63 it is 0.053 (about 19 seasons).

### B. Breakthrough

`p_bt = fate_ok · f_season`, where `fate_ok = [ u < p_gate ]` is drawn once per realm at the bình cảnh and stored, and `f_season = npc.fated_breakthrough_per_season`.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| u | float | [0, 1) | session stream | One draw, stored in `bt_fate` with the realm index |
| p_gate | float | [0, 1] | Progression Edges `npc_step_chance(p).total` | The person's odds for this gate |
| f_season | float | (0, 1] | data file (`progression_edges.json` npc) | Chance each season that a fated person breaks through |
| p_bt | float | 0 or f_season | calculated | Per-season chance |

**Output Range:** 0 (unfated) or `f_season`. A fated person's wait is geometric with mean `1 / f_season` seasons. **Example:** `f_season` 0.08 (`character_edges.json`, as built; canh-gioi.md rule 12) gives a mean of 12.5 seasons, about 3 years; 95 % break through within 36 seasons. An unfated person never advances, so the realm's headcount is bounded by lifespan. For a fixed-cast member with an authored fate, `fate_ok` is the authored value and `u` is not drawn (rule 15).

### C. Intake

`spawn = max( max(world_cultivators, world_cultivators_min) − C, 0 )`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| world_cultivators | int | 5,000 | data file (`world_generation.json` people) | The headcount target |
| world_cultivators_min | int | 3,000 | data file | The floor; the target is the larger of the two |
| C | int | 0 – ∞ | calculated | Non-beast living non-player people after this season's deaths |
| spawn | int | ≥ 0 | calculated | New Qi Refining cultivators this season |

**Output Range:** 0 up to the season's deaths, so about 10 a season (42 a year at 5,000, canh-gioi.md). **Example:** target 5,000, C 4,988 after 12 deaths gives spawn 12; the new people are age 16, realm 0, stage 0.

### D. Pool allocation

Each sect *s* has demand `d_s` = F17's intake (Sects F17) for this season, 0 for a Strained or Collapsing sect. With pool size `P = spawn` and total demand `D = Σ d_s`:

`claim_s = d_s` if `D ≤ P`; otherwise `claim_s = floor(P · d_s / D)`, and the remaining `P − Σ floor` go one each to the sects with the largest remainder, ties to the lower sect id. `loose = P − Σ claim_s`.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| P | int | ≥ 0 | calculated | The season's spawn |
| d_s | int | ≥ 0 | Sects F17 | Sect *s*'s demand |
| D | int | ≥ 0 | calculated | Total demand |
| claim_s | int | 0 – d_s | calculated | New members the sect receives |
| loose | int | ≥ 0 | calculated | New cultivators no sect took |

**Output Range:** `Σ claim_s + loose = P`; no sect gets more than it asked for. **Example:** P 10, three sects with demands 30, 20, 10 (D 60): exact shares 5.00, 3.33, 1.67 give floors 5, 3, 1 (9); the one left over goes to the largest fraction (0.67, the third sect): claims 5, 3, 2, loose 0. Demand far exceeds supply at default settings (29 sects want hundreds), so in practice the supply, not F17, sets sect growth (Open Questions 1).

### E. Lifespan check

`lifespan = base_life(realm) + min(lifespan_bonus, base_life(realm) · bonus_ceilings.lifespan_frac)`; death when `age ≥ lifespan`.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| base_life | float | years | data file (`cultivation_realms.json`) | The realm's lifespan cap (Realms rule 13) |
| lifespan_bonus | float | ≥ 0 | World DB person record | Years from pills, techniques, items |
| lifespan_frac | float | ≥ 0 | data file (`attributes.json` bonus_ceilings) | The ceiling as a share of base_life |
| age | float | ≥ 0 | World DB | Years; `+1/seasons_per_year` each season |

**Output Range:** `base_life` to `base_life · (1 + lifespan_frac)`. **Example:** base_life 100, bonus 80, frac 0.5: lifespan 150. A person at age 149.9 dies the season age reaches 150.

### F. Estate conservation

`purse_dead = to_heir + to_sect + W_dead`, with exactly one term non-zero.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| purse_dead | int | ≥ 0 | World DB (`linh_thach`) | The dead person's stones at death |
| to_heir | int | 0 or purse_dead | calculated | Whole purse to `heir_of` |
| to_sect | int | 0 or purse_dead | calculated | Whole purse to the sect treasury (member, no heir) |
| W_dead | int | 0 or purse_dead | calculated | Whole purse to the region's economy (no heir, no sect) |

**Output Range:** 0 to the purse; the sum over the world's stones is unchanged by the tick except through `W_dead`, which Regional Economy accounts as a burn. **Example:** a sectless hermit with 340 stones and no heir adds 340 to `W_dead` for their place's region.

### G. Tick budget

`T_tick = T_people + T_intake + T_duel + T_sects + T_map + T_econ + T_events + T_traits + T_ratings_main`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| T_people | ms | to measure | calculated | People step, S2 (the built 60–90 ms is this step alone, canh-gioi.md OQ 21) |
| T_sects | ms | ≤ 8 mean, ≤ 15 p99 | Sects AC-SM | S5 |
| T_map | ms | ≤ 20 mean, ≤ 50 p95 | Travel & Map AC | S6 (excluding the stacked D·M, 10 ms) |
| T_econ | ms | ≤ 8 | Regional Economy AC | S7 |
| T_events | ms | not stated | Event Engine | S8: no budget in event-engine.md (**NOT SOURCEABLE** from the GDDs read) |
| T_traits | ms | ≤ 2 median, ≤ 5 p99 | NPC Traits AC | S9 |
| T_ratings_main | ms | ≤ 10 added | Combat AC-CB-67 | Rating clashes on the main thread |

A bulk run of *n* seasons (rule 18) costs `n · T_tick`; a century (400 seasons) at the provisional mean is 60 s.

**Output Range / budget:** the callee ceilings above sum to about 48 ms; with the built people step at 60–90 ms the first full tick is **about 110–140 ms**, over the 60–90 ms the Sects GDD assumed. **Provisional target (a guess, to measure): mean ≤ 150 ms, p99 ≤ 250 ms at 5,000 cultivators**, with no frame stall beyond 33 ms in the background batch (Power Rankings AC-PR-51). **Example:** 90 + 8 + 20 + 8 + 2 + 10 = 138 ms plus events.

### H. Talent and place multiplier (decided 2026-11-15)

`raw_i = root_i · max(q_i, 0.1)` · `s_i = clamp( (raw_i / mean_raw)^γ, m_lo, m_hi )` · `m_i = s_i / mean(s)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| root_i | float | > 0 | calculated (`CultivationRules.curve_factor`, the player's root curve) | The person's spiritual root (linh căn) factor; cached on the record when the person is created or the root changes |
| q_i | float | ≥ 0.1 | World DB (place `density`) | Qi density of the person's place; a sect member uses the sect seat |
| mean_raw | float | > 0 | calculated | Mean of `raw_i` over living non-beast NPCs |
| γ | float | 0 – 1 | data file (`tick.talent_gamma`, 0.5) | Softens talent: 0 makes everyone equal, 1 makes speed proportional to talent |
| m_lo, m_hi | float | 0.5, 2.0 | data file (`tick.talent_min`, `tick.talent_max`) | Clamp on the multiplier before normalising |
| mean(s) | float | > 0 | calculated | Mean of `s_i` over the same people |
| m_i | float | ≈ 0.5 – 2.0 | calculated | The multiplier used in Formulas A |

`mean_raw` and `mean(s)` are recomputed once a year, in Spring, at the start of S2; a person created mid-year uses the current means. Dividing by `mean(s)` keeps the world's average stage speed equal to `1 / N_stage` **by construction**, so Realms' calibration of the average climb holds. The spread can still move realm shares (talented people reach the bình cảnh sooner), so AC-LW-27 re-checks Realms' headcounts. γ, `m_lo` and `m_hi` are guesses.

**Output Range:** `m_i` from about `m_lo / mean(s)` to `m_hi / mean(s)`; the mean of `m_i` is exactly 1. **Example:** a strong root (factor 2.0) at a seat of density 1.5 gives raw 3.0; with mean_raw 1.2, (2.5)^0.5 = 1.58; with mean(s) 1.02, m = 1.55, about 8 seasons a stage. A weak root (0.5) at density 1.0: (0.417)^0.5 = 0.645, m = 0.63, about 19 seasons.

### I. Wild beast refill

`spawn_r = max( B_r − b_r, 0 )` for each region *r*

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| B_r | int | ≥ 0 | data file (per region, set with Spirit Beasts #19; **provisional**) | The region's target of living ownerless beasts |
| b_r | int | ≥ 0 | calculated | Living ownerless beasts in the region after S2 |
| spawn_r | int | ≥ 0 | calculated | New wild beasts this season, each at a realm drawn from the region's danger band (Travel & Map tile danger) |

**Output Range:** 0 to the region's deaths this season. **Example:** B_r 40, b_r 37 after three deaths gives 3 new beasts.

### J. Log size after upkeep

`full_dead ≤ deaths_per_year · retain_full_years` · `stub_bytes_per_year ≈ deaths_per_year · stub_size` · `kept_events ≤ events_per_year · news_keep_years + news_events`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| deaths_per_year | int | about 42 | calculated (canh-gioi.md rule 12) | Cultivator deaths a year at 5,000 |
| retain_full_years | int | 10 | data file (`tick.retain_full_years`) | Years a dead stranger keeps the full record |
| stub_size | bytes | about 200 | measured (guess) | One compacted record in the save |
| news_keep_years | int | 50 | data file (`tick.news_keep_years`) | Years a non-news event is kept |
| events_per_year | int | to measure | calculated | Non-news events the world logs a year |
| news_events | int | grows slowly | calculated | News and chronicle events, never pruned |

**Output Range:** at most about 420 full dead records at any time; stubs grow by about 8 KB a year (about 8 MB over 1,000 years). **Example:** 42 deaths a year · 10 years = 420 full records kept; everyone dead longer than 10 years who is not protected is a stub.

## Edge Cases

- **If the world has fewer than the floor (3,000) cultivators after a season** (mass death, a long bulk run): intake spawns `target − C` in one tick, so the floor holds at once; the spawn can exceed 10 and the extra people are claimed or loose by rule 6.
- **If a leader dies and the sect has no eligible successor**: Sects' succession returns none; the tick logs no `tick_succession`, the sect is leaderless and enters Sects' Strained state at S5 the same season. The tick never invents a leader.
- **If a person dies who is both a sect leader and holds items and a purse**: order is rule 9 a–d; the heir may be the successor; the purse goes to the heir first, never to the sect when an heir exists.
- **If `heir_of` names a dead or non-existent person**: treated as no heir (Item Database rule 14 and Inheritance already skip the dead); the purse goes to the sect or `W_dead`.
- **If two people reach lifespan the same season**: both die in table order; each estate is settled before the next person's, so an heir who dies the same season passes the inheritance on in order.
- **If the duel picks a person who died earlier this tick**: the pair is chosen after the people step from the living, so a dead person is never picked. With fewer than two living candidates the duel is skipped silently (no news).
- **If ratings are off or a person has no rating**: the duel uses `CombatPower.duel`; a missing power defaults to 1.0 (as built).
- **If a fated person's `bt_fate` realm index differs from their current realm**: the stored fate is stale; it is re-rolled once for the new realm (as built).
- **If the player is the only person in a table** (tests): the people step does nothing, the duel is skipped, intake spawns to the target.
- **If a step of a callee is not built yet**: the tick skips that step and **says so by name** in the debug log (`tick_step_skipped: S5 sects`); a skipped step never reads as a step that ran and changed nothing.
- **If the player dies this season** (S10 lifespan check): the tick has already completed; the session ends the life after the tick, so the world is consistent when the life closes.
- **If a bulk command passes *n* seasons and the player dies at season *k* < *n***: the remaining seasons are not run for that life.
- **If a fixed-cast member's authored fate says *will* but they die of old age first**: they die; the authored fate does not extend life. A story that needed them reads `a person alive` as false (Event Engine conditions).
- **If a fixed-cast member has an authored fate for a gate they already passed at world start**: the entry is ignored.
- **If a person's place has no density** (a new place, a stub): q = 1.0. **If every NPC has the same raw value**: every `m_i` is 1. **If the world has no living non-beast NPC**: Formulas H is skipped and `m_i` is 1.
- **If a person moves or changes sect mid-year**: `raw_i` is recomputed when it is read (the place's density), only the means wait for Spring; the mean of `m_i` may drift from 1 until the next Spring, by at most the year's moves.
- **If vitality is already 1**: recovery does nothing. **If an NPC is at the vitality floor**: recovery starts from the floor; injuries never kill in the tick.
- **If a news-filter rule names a person the player came to know this season**: the test is made when the event is logged; earlier events about that person stay log-only.
- **If a bulk command passes seasons with no news**: the digest says so in one line ("the world was quiet"), not an empty block.
- **If the player knows a dead stranger only through a stub** (met them, then 10 years passed): anyone the player knew is never compacted (rule 19), so this cannot happen; a person the player meets later is already a stub only if dead, and a stub is never met.
- **If a stub is the heir, killer or parent in another record**: the id still resolves to the stub's name; nothing that needs the build reads a dead person.
- **If a region has no beast target** (B_r missing): no refill there; the data loader reports the missing region by name.
- **If the session loads a save**: the tick has no saved state of its own. The next tick runs from the loaded World DB and the restored session stream; the pending pool is always empty at a save (the tick is atomic, rule 3).

## Dependencies

| System | Dependency | Nature | Status | Note |
|---|---|---|---|---|
| World DB | people, sects, places, items, event log | Hard | Built | |
| Realms & Bottlenecks | lifespan, stages, fate odds, headcounts | Hard | Designed (approved) | |
| NPC Build Generation (#24) | `create_person`, `refresh_power` | Hard | Built, no GDD | |
| Edges (NPC half) | NPC breakthrough odds, intake config | Hard | Built | |
| Time & Turn | `seasons_per_year`, clock | Hard | Built | |
| Sects & Missions (#26) | the S5 tick, F17, succession | Hard | Designed (approved) | Slice 1 built; the tick is not |
| Travel & Map (#25) | S6 update, pool placement | Hard | Designed | Not built |
| Regional Economy & Trade (#43) | S7, `W_dead` | Soft | Designed | The tick runs without it |
| Event Engine (#23) | S8 | Soft | Designed | |
| NPC Traits (#42) | S9 | Soft | Designed | |
| Power Rankings | S1, S4, S10 | Soft | Built, approved | Duel falls back to `CombatPower.duel` |
| Item Database | inheritance, decay, Lost items | Hard | Built | |
| Quests (#31) | estate | Soft | Revised, not reviewed | |
| World Generation & History (#27) | the fixed cast's authored `fates` (rule 15) | Soft | Designed | New field for World Gen's cast table |
| Spiritual Roots (linh-can.md) | root curve factor for Formulas H | Hard | Designed | Read only |
| Spirit Beasts (#19) | wild beast targets per region (Formulas I) | Soft | Built (beasts only), no GDD | Targets provisional |
| NPC Relationships (#46) | S8b | Soft | Designed 2026-11-20 | `npc-relationships.md` lists this GDD back |
| Codex & Karmic Carryover (#12) | rule 9 (the player's estate, unchanged); the closed-door ticks for a rebirth's 4 × `rebirth_years` seasons | Soft | Approved 2026-11-21 | `codex-karmic-carryover.md` lists this GDD back |
| Cave Abode & Home Works (#47) | S6 (abode step) | Soft | Approved 2026-11-21 | `cave-abode.md` lists this GDD back |
| Save / Load | stubs and pruned events (rule 19) | Hard | Built | The save must load a stub |
| Character Stats | `injury_recovery_frac_per_season` (rule 4) | Hard | Designed | The player's rule, applied to NPCs |

Back-links owed (not written; other files are being edited elsewhere): Sects (F17 note: demand is a claim on the tick's pool; succession called by the tick), Canh-gioi rule 12 (intake share retired; NPC stage chance now scaled by Formulas H, which reopens an approved rule), World Generation (authored `fates` per cast member), Event Engine rule 20 (the tick uses the same news test), Regional Economy (`W_dead` source row: this GDD), Power Rankings ("Still owed" line), Travel & Map (tick row: GDD exists), Quests OQ 9, Event Engine rule 19, NPC Traits Dependencies row, World Generation row (#28).

## Visual/Audio Requirements

Narrative systems need this section; the tick has almost no presentation of its own.
- **Visual:** none beyond text. The season's news appears as *tin đồn* lines, each starting with a bracketed tag as built (`[tin đồn]`).
- **Audio:** no sound of its own; the season-advance cue belongs to Time & Turn and Game UI.
- `art-director` not consulted — lean mode. Review manually before production.

## Game Feel

A season must pass without a visible stall: the main thread finishes the tick within the budget in Formulas G, and nothing the tick does needs an animation. The "world moved" feeling comes from the news (up to 3 lines a season on screen) and from consequences the player later notices: a named rival who has died, a sect that changed hands, a price that moved.

## UI Requirements

- The season summary shows the latest news lines (as built, 3) that pass the news test (rule 12).
- After a command of more than one season, the summary shows the seclusion digest (rule 17) instead: totals, then lines grouped by known person, at most 12, with a pointer to the log.
- A bulk run shows a progress line once a simulated year (rule 18).
- A news log screen lists the full log of `news: true` events, newest first, filterable by person and place (Codex and Game UI own it).
- No control for the tick itself.

📌 UX Flag — Living World Tick: this system has UI requirements (the news log). In Pre-Production, run `/ux-design` for the news log before writing epics.

## Cross-References

| This GDD says | Source |
|---|---|
| Headcount 5,000, floor 3,000, intake by target not population | canh-gioi.md rule 12 |
| Stage chance 1/12 as built; fate rolled once per realm | canh-gioi.md, `world_ticker.gd` |
| Sect tick order (great, then vassals), F17 intake, succession rule 15 | sects.md (season tick, F17, rule 15) |
| Economy tick after the Sects tick and Travel & Map production; `W_dead` | regional-economy-trade.md rule 19, Formulas |
| NPC events after the tick's own steps | event-engine.md rule 19 |
| Trait steps after events resolve | npc-traits.md (Season tick order) |
| World fights are one rating roll; batch scheduling | power-rankings.md rules 11, 13, 14 |
| Estates, Lost items, decay | item-database.md rule 14 |
| Seasonal map update; head counts per region | travel-map.md (Interactions, Edge) |
| Random streams | docs/architecture/adr-0002-random-streams.md |
| Known person; news only for the known or newsworthy | event-engine.md rules 19, 20 |
| NPCs never run a tribulation; their fate includes it | thien-kiep.md rule 1 |
| Fixed cast of 60–100 authored people | world-generation.md rule 5 |
| Injury recovery 0.25 a season | `character_attributes.json` (Character Stats) |
| Root curve factor | linh-can.md; `CultivationRules.curve_factor` |
| Anti-pillar: not a granular simulation | game-concept.md § Anti-Pillars |

## Acceptance Criteria

- **AC-LW-01** [Logic] Rule 1. **GIVEN** a session, **WHEN** a season passes by any player action, **THEN** the tick is called exactly once for that season, and *n* bulk seasons call it *n* times in order.
- **AC-LW-02** [Logic] Rule 2. **GIVEN** a world with a player record, **WHEN** a tick runs, **THEN** the player's `age`, `realm_index`, `stage` and `alive` are unchanged by the tick.
- **AC-LW-03** [Logic] Rule 4, A. **GIVEN** 1,000 Qi Refining people at stage 0, every `m_i` 1 and `N_stage` 12, **WHEN** one tick runs on a fixed seed, **THEN** the number advanced is within 4σ of 83 (binomial 1,000, 0.0833), and every advanced person's `level` equals the stage's first level.
- **AC-LW-04** [Logic] Rule 4, E. **GIVEN** a person with age 99.9, base_life 100, bonus 0, 4 seasons a year, **WHEN** a tick runs, **THEN** they die (age 100.15 ≥ 100); **GIVEN** the same person with age 99.7, **THEN** they live.
- **AC-LW-05** [Logic] Rule 4, B. **GIVEN** a person at the last stage whose stored `bt_fate.realm` is another realm, **WHEN** a tick runs, **THEN** a new fate is stored for the current realm and at most one draw is used for it.
- **AC-LW-06** [Logic] Rule 4, B. **GIVEN** an unfated person at the bình cảnh, **WHEN** 400 ticks run, **THEN** they never change realm.
- **AC-LW-07** [Logic] Rule 4. **GIVEN** an ownerless beast, **WHEN** a tick runs, **THEN** it ages and may die but its stage and realm are unchanged, and it is not counted in `C`.
- **AC-LW-08** [Logic] Rule 5, C. **GIVEN** target 5,000 and 4,988 living cultivators after deaths, **WHEN** a tick runs, **THEN** 12 new Qi Refining people of age 16 exist afterwards; **GIVEN** 5,000 or more, **THEN** none.
- **AC-LW-09** [Logic] Rule 5, C. **GIVEN** 2,000 cultivators and a floor of 3,000 with a target of 5,000, **WHEN** a tick runs, **THEN** the tick spawns up to the larger of the two, 3,000.
- **AC-LW-10** [Integration] Rules 5, 6, D. **GIVEN** a pool of 10 and sect demands 30, 20, 10, **WHEN** the Sects step runs, **THEN** the sects receive 5, 3 and 2 and 0 are loose; with demands 3, 2, 1, they receive 3, 2, 1 and 4 are loose; `Σ claims + loose = P` in both.
- **AC-LW-11** [Integration] Rule 6. **GIVEN** a Strained sect with demand, **WHEN** the pool is allocated, **THEN** its claim is 0.
- **AC-LW-12** [Logic] Rule 7. **GIVEN** `event_chance_per_season` 1.0 and two living fighters with ratings 1450 and 1400, **WHEN** a tick runs, **THEN** 0 fights run, the session stream advances by the world-fight draws only, and a `tick_duel` news line names both; with fewer than two living fighters, no news and no draw.
- **AC-LW-13** [Logic] Rule 7. **GIVEN** a duel in the tick, **THEN** neither fighter's `alive` changes.
- **AC-LW-14** [Logic] Rule 8. **GIVEN** a Lost item past its decay age, **WHEN** the season is Spring, **THEN** it decays before the people step with a `tick_item_decay` line; **WHEN** the season is not Spring, **THEN** it does not.
- **AC-LW-15** [Logic] Rules 9, F. **GIVEN** a dead person with 340 stones and an heir, **THEN** the heir gains 340, the sect and `W_dead` gain 0; **GIVEN** no heir and a sect, the sect treasury gains 340; **GIVEN** no heir and no sect, `W_dead` is 340.
- **AC-LW-16** [Property] Rule 9, F. **GIVEN** 400 seasons from a seeded 5,000-person world, **THEN** at each season the world's total stones plus cumulative `W_dead` is unchanged by the tick's deaths.
- **AC-LW-17** [Logic] Rules 9, 10. **GIVEN** a sect leader who dies of old age, **WHEN** the tick finishes S2, **THEN** the sect already has a living leader chosen by Sects' succession, a `tick_succession` line names them, and the player is never the successor.
- **AC-LW-18** [Logic] Edge. **GIVEN** a leader with no eligible successor, **THEN** no `tick_succession` line is logged and the sect is leaderless but Strained at S5 in the same tick.
- **AC-LW-19** [Integration] Rule 3, season order. **GIVEN** a tick with every step built, **THEN** a trace shows S1 to S10 in the table's order, each exactly once.
- **AC-LW-20** [Integration] Rule 3. **GIVEN** a step not built, **WHEN** a tick runs, **THEN** the log names the skipped step; no step's absence is silent.
- **AC-LW-21** [Logic] Rule 11. **GIVEN** the same seed and the same actions run twice for 100 seasons, **THEN** the two World DB dumps and event logs are identical.
- **AC-LW-22** [Logic] Rule 11. **GIVEN** a callee with a variable number of draws, **THEN** the tick takes exactly one draw from the session stream for it.
- **AC-LW-23** [Logic] Rule 12. **GIVEN** a tick that logs events, **THEN** each has `news: true`, text with no unfilled `{key}`, and references the people and places named.
- **AC-LW-24** [Logic] Rule 13. **GIVEN** the authored chronicle, **WHEN** 40 ticks run, **THEN** no authored event is changed or removed.
- **AC-LW-25** [Integration] Edge. **GIVEN** a save taken at any season boundary, **WHEN** it is loaded and ticked, **THEN** the world equals the world of an uninterrupted run with the same seed (stream and DB restored).
- **AC-LW-26** [Performance] Formulas G. **GIVEN** a 5,000-cultivator world, **WHEN** 400 seasons run with every built step, **THEN** the main-thread tick has a mean ≤ 150 ms and p99 ≤ 250 ms (provisional guess, Open Questions 2), and the people step alone is reported separately.
- **AC-LW-27** [Integration] Realms headcount. **GIVEN** 400 seasons from the shipped world, **THEN** the cultivator count is ≥ 3,000 after every season, equals the target after the intake step, and the realm shares stay within the tolerance Realms states for its solved counts (Open Questions 3).
- **AC-LW-28** [Integration] Rule 12. **GIVEN** a season with deaths, breakthroughs and a duel, **THEN** the session shows at most 3 `[tin đồn]` lines and the full list is in the event log.
- **AC-LW-29** [Logic] Rule 12. **GIVEN** in one season a stranger's Foundation breakthrough, a stranger's Nascent Soul breakthrough, the old-age death of a Qi Refining person the player met, and a stranger's Qi Refining death, **THEN** the second and third are `news: true`, the first and fourth are logged with `news: false`.
- **AC-LW-30** [Logic] Rule 4. **GIVEN** an NPC at vitality 0.5, **WHEN** one tick runs, **THEN** vitality is 0.75; after two more, 1.0 and never above.
- **AC-LW-31** [Logic] Formulas H. **GIVEN** 1,000 NPCs with mixed roots and places, **WHEN** the Spring recomputation runs, **THEN** the mean of `m_i` is 1 within 1e-9, every `s_i` lies in [0.5, 2.0], and a person with a higher `raw_i` never has a lower `m_i`.
- **AC-LW-32** [Logic] Formulas H. **GIVEN** `talent_gamma` 0, **THEN** every `m_i` is 1 and the stage chances equal Formulas A at m 1.
- **AC-LW-33** [Logic] Rule 15. **GIVEN** a fixed-cast member with an authored *won't* for the Core Formation gate and a 1.0 per-gate roll chance, **WHEN** they reach the bình cảnh, **THEN** `bt_fate.ok` is false and no draw is made for the fate; with *will*, `bt_fate.ok` is true and they break through by Formulas B's timing.
- **AC-LW-34** [Logic] Rule 15. **GIVEN** a fixed-cast member with *will* who reaches lifespan first, **THEN** they die of old age as anyone else.
- **AC-LW-35** [Logic] Rule 16, I. **GIVEN** a region with target 40 and 37 wild beasts after deaths, **WHEN** a tick runs, **THEN** 3 new ownerless beasts exist in the region, and the cultivator count and pool are unchanged.
- **AC-LW-36** [Integration] Rule 17. **GIVEN** a closed-door command of 40 seasons during which 2 people the player knows die and one newsworthy breakthrough happens, **THEN** the digest shows totals, the two deaths grouped by person and the breakthrough, at most 12 lines, and no line about a stranger who is not newsworthy.
- **AC-LW-37** [Logic] Rule 19. **GIVEN** a stranger dead 11 years, a stranger dead 9 years, a fixed-cast member dead 30 years and a person the player met dead 30 years, **WHEN** Spring upkeep runs, **THEN** only the first is a stub, and the stub keeps id, name, realm, sect, birth and death year, cause, killer, heir and place.
- **AC-LW-38** [Logic] Rule 19. **GIVEN** a 60-year-old non-news event, a 60-year-old news event and a chronicle event, **WHEN** upkeep runs, **THEN** only the first is deleted.
- **AC-LW-39** [Integration] Rule 19, J. **GIVEN** a save after 400 seasons and a save after 4,000 seasons from the same seeded world, **THEN** the full dead records are at most `deaths_per_year · retain_full_years` plus the protected, and the later save loads with every stub id resolving to a name.
- **AC-LW-40** [Performance] Rule 18, G. **GIVEN** a 400-season closed-door command at 5,000 cultivators, **THEN** it completes in at most 60 s on the reference machine with a progress line each simulated year (provisional, Open Questions 7).

## Open Questions

1. **Intake and loose cultivators.** With the fixed 0.9 sect share retired (decision 2026-11-15), sects' demand (hundreds) far exceeds the supply (about 10 a season), so almost no new cultivator is loose; loose people then come only from desertion and collapse. Is that wanted, or should a share stay loose? Also: Sects rule 19 sets rank by realm, so `intake_rank_shares` (elder 0.06, inner 0.30) retire; canh-gioi.md rule 12 and the progression config need that edit. Owner: user, Sects. Resolve at the Sects tick build.
2. **The tick budget.** The 60–90 ms in canh-gioi.md is the built people step alone; callee ceilings add about 48 ms plus events (no budget stated). The provisional 150 ms mean / 250 ms p99 is a guess. Measure in the Balance Harness once S5–S9 exist; owner: performance-analyst, technical-director. Related: ADR on world scale and simulation budget (architecture.md, ADR 6).
3. **Realm shares at steady state.** Intake adds only Qi Refining and `bt_fate` bounds breakthroughs; does the stationary distribution match Realms' solved counts (3936 / 844 / 191 / 27 / 3)? Quests OQ 9 asks the same. Measure with `tools/balance/world_census.gd` over 400 seasons.
4. **NPC duel budget** (Combat OQ 11). One rare duel a season with chance 0.6 and no death is a placeholder. When wars, feuds and NPC deaths by violence exist (Sects F9, Event Engine), set a budget of violent deaths a season so Realms' headcounts hold. NPC Relationships rule 14a also relies on it to damp blood-feud revenge (2026-11-20). Owner: world-builder, Combat.
5. **NPC acquisition** (Power Rankings OQ 5). The tick gives NPCs no techniques or items; does a season ever raise an NPC's build beyond stage and realm? Defer to NPC Builds (#24).
6. **Wound and injury.** The duel does not injure or kill in the Vertical Slice; whether duels may kill, and what happens to the dead person's estate then, waits on Event Engine's death events.
7. **Fast-forward for long seclusion.** A century at about 150 ms a season is a minute of waiting. If that is too slow, a lighter bulk mode could run S6–S7 (map, economy) once a year instead of each season during a bulk command. Decide after measuring (Open Questions 2). Owner: performance-analyst, user.
8. **Talent multiplier values.** γ 0.5 and the clamp 0.5–2.0 are guesses; check the realm shares (AC-LW-27) and that the fastest NPCs do not crowd the top list. Owner: systems-designer, with Realms (canh-gioi.md rule 12 needs the note that the chance is now scaled).
9. **Authored fates for the 51 living cast members** are not written yet; World Generation's cast table needs a `fates` entry per gate they have not passed. Owner: user (authoring pass).
10. **Beast targets per region** (Formulas I) wait on Spirit Beasts #19 and Travel & Map's danger bands.
11. **Back-link edits** listed in Dependencies are not written yet because other sessions have uncommitted edits in sects.md, canh-gioi.md and others; commit own paths only.

