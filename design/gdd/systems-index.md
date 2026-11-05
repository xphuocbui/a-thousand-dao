# Systems Index: Ten Thousand Daos

> **Status**: Approved (system list, dependencies and priority tiers approved by the user, 2026-11-03)
> **Created**: 2026-11-03
> **Last Updated**: 2026-11-05
> **Source Concept**: design/gdd/game-concept.md

---

## Overview

Ten Thousand Daos is a roguelite cultivation game: one life of 60–120 minutes, a procedurally
generated world with centuries of history, and a build the player constructs rather than picks
(Pillar 3, Power Is Built, Not Given). Its mechanical scope is four interlocking layers. A
**character layer** (spiritual roots [linh căn], innate talent [thiên phú], realms [cảnh giới],
cultivation techniques [công pháp], the Meridian Map [Kinh Mạch Đồ], destiny perk [thiên mệnh] edges)
decides how fast and how safely a life advances. An **economy layer** (spirit herbs [linh thảo] that age,
alchemy [luyện đan], artifact refining [luyện khí], formations [trận pháp], talismans [phù lục],
spirit beasts [linh thú], spirit stones [linh thạch]) turns time and spiritual root
affinity into assets (Pillar 4, Every Season Counts). A **world layer** (world generation with
history, a seasonal living-world tick, NPC builds under the player's own rules) gives the LLM
facts to build on (Pillar 5, A World That Remembers). A **bounded story layer** (an engine-side
event engine with budgets, plus an LLM game master that narrates and proposes events inside
them) delivers the stories (Pillar 2, Every Number Is Bounded and Visible). Presentation is a
text debug terminal today and a Godot 2D ink-wash UI later.

**Where the project actually is.** 32 of the 39 systems are implemented in the debug terminal
build (src/gameplay, src/core, src/debug_terminal; 97 gdUnit4 tests), but there are no GDDs
yet, only four quick specs in `design/quick-specs/`, and `project.yaml` still says stage
"Concept". The design order below therefore treats built systems as **reverse-document, then
review** (`/reverse-document design src/gameplay/<area>`, then `/design-review`; a review may
change the code) and unbuilt systems as ordinary `/design-system` work. Systems 10, 11 and 36
were added by the user's requests and are not in the concept doc; the concept should be
updated to include them.

**Priority tiers follow the concept's milestones** (MVP, Vertical Slice, Alpha, Full Vision).
A built system keeps its later tier: the tier says when the system ships in the product plan,
the Status column says whether it exists.

> **Review gates**: TD-SYSTEM-BOUNDARY, PR-SCOPE and CD-SYSTEMS were skipped (Lean review mode).

---

## Systems Enumeration

Short names used in "Depends On": Config, Sim Core, World DB, Time & Turn, Save/Load,
Spiritual Roots (Linh Căn), Character Stats, Realms (Cảnh Giới), Cultivation Techniques (Công Pháp),
Meridian Map (Kinh Mạch), Edges, Codex, Item DB, Spirit Herbs (Linh Thảo), Alchemy (Luyện Đan),
Artifact Refining (Luyện Khí), Formations (Trận Pháp), Talismans (Phù Lục), Spirit Beasts (Linh Thú),
Market, Combat, Heavenly Tribulation (Thiên Kiếp), Event Engine, NPC Builds, Travel, Sects, World Gen,
Living World, LLM GM, Dialogue, Quests, Achievements (Thành Tựu), Balance Harness, Localization,
Guidance, Debug Terminal, Game UI, Audio.

| # | System Name | Category | Priority | Status | Design Doc | Depends On |
|---|-------------|----------|----------|--------|------------|------------|
| 1 | Data-Driven Config (inferred) | Core | MVP | Implemented | — | — |
| 2 | Deterministic Simulation Core: seeded RNG, explainable numbers (inferred) | Core | MVP | Implemented | — | — |
| 3 | World Database | Core | MVP | Implemented | — | — |
| 4 | Time & Turn Structure | Core | MVP | Implemented | — | Config |
| 5 | Save/Load (inferred) | Persistence | MVP | Implemented | — | World DB, Time & Turn |
| 6 | Spiritual Roots (Linh Căn) (incl. changing spiritual roots) | Progression | MVP | Needs Revision (independent review 2026-11-05: 1 blocker, fixed; awaiting a fresh re-review) | design/gdd/linh-can.md | Config, Sim Core; soft: Realms (breakthrough event, stage group), Character Stats (capability set) |
| 7 | Character Stats (innate talent [thiên phú], derived, craft mastery [đạo nghệ]) | Progression | MVP | In Review | design/gdd/character-stats.md | Spiritual Roots, Sim Core, Config; soft (via the provider interface): Realms, Meridian Map, Cultivation Techniques, Item DB, Progression Edges, Formations, Spirit Herbs & Spirit Fields |
| 8 | Realms & Bottlenecks (Cảnh Giới & Bình Cảnh) | Progression | MVP | Needs Revision (independent review 2026-11-05: 6 blockers, fixed; awaiting a fresh re-review) | design/gdd/canh-gioi.md | Config, Sim Core, Time & Turn, Spiritual Roots, Character Stats, Item DB; soft: Cultivation Techniques, Spirit Herbs, Alchemy, Formations, Travel & Map, Event Engine, Progression Edges |
| 9 | Cultivation Techniques (Công Pháp) | Progression | MVP | In Review, reopened 2026-11-04 by the Spiritual Roots redesign. Was Approved (second lean review 2026-11-04, no blockers, 6 recommended revisions open) | design/gdd/cong-phap.md | Spiritual Roots, Realms, Character Stats, Item DB; soft: Time & Turn, Meridian Map |
| 10 | Meridian Map (Kinh Mạch Đồ) (added by request) | Progression | MVP | In Review 2026-11-05 (map density revision, rule 21). Approved 2026-11-04 (lean re-review after the Spiritual Roots redesign added the variant sectors: 0 blockers, 9 recommended; 7 lean reviews in all; partially implemented: base tree at 202-acupoint [huyệt] prototype scale; levels, clusters, capabilities not built) | design/gdd/kinh-mach-do.md | Spiritual Roots, Character Stats, Realms, Config, Sim Core; soft: Event Engine, Item DB, Cultivation Techniques, LLM GM, World DB, Edges |
| 11 | Progression Edges: destiny perk (thiên mệnh), fortuitous encounters (cơ duyên), NPC edges (added by request) | Progression | MVP | Implemented | quick spec: design/quick-specs/progression-and-edges.md | Character Stats, Realms, Event Engine (player half) |
| 12 | Codex & Karmic Carryover | Progression | Vertical Slice | Not Started | — | Item DB, Alchemy, Spiritual Roots, Save/Load |
| 13 | Item Database & Generation (inferred) | Economy | MVP | Implemented | — | Config, Sim Core, World DB |
| 14 | Spirit Herbs & Spirit Fields (Linh Thảo & Linh Điền) | Economy | MVP | Implemented | — | Item DB, Character Stats, Time & Turn |
| 15 | Alchemy (Luyện Đan) | Economy | MVP | Implemented | — | Spirit Herbs, Item DB, Character Stats |
| 16 | Artifact Refining (Luyện Khí) | Economy | Vertical Slice | Implemented | quick spec: design/quick-specs/luyen-khi-and-tran-phap.md | Item DB, Character Stats |
| 17 | Formations (Trận Pháp) | Economy | Alpha | Implemented | quick spec: design/quick-specs/luyen-khi-and-tran-phap.md | Item DB, Character Stats, Time & Turn |
| 18 | Talismans (Phù Lục) | Economy | Alpha | Implemented | quick spec: design/quick-specs/phu-luc-linh-thu-thanh-tuu.md | Item DB, Character Stats |
| 19 | Spirit Beasts & Spirit Insects (Linh Thú & Linh Trùng) | Economy | Alpha | Implemented (spirit beasts only) | quick spec: design/quick-specs/phu-luc-linh-thu-thanh-tuu.md | World DB, Character Stats, Time & Turn |
| 20 | Market & Spirit Stone (Linh Thạch) Economy (inferred) | Economy | MVP | Implemented | — | Item DB, Character Stats, Realms, World Gen |
| 21 | Combat | Gameplay | MVP | Implemented (power duel only) | — | Character Stats, Realms, Cultivation Techniques, Meridian Map, Artifact Refining, Formations, Talismans, Spirit Beasts |
| 22 | Heavenly Tribulation (Thiên Kiếp) | Gameplay | MVP | Not Started | — | Combat, Realms, Event Engine |
| 23 | Event Engine: templates, budgets, validator, resolver | Gameplay | MVP | Implemented | — | World DB, Character Stats, Item DB, NPC Builds, Alchemy, Talismans, Spirit Beasts, Combat |
| 24 | NPC Build Generation (inferred) | Gameplay | MVP | Implemented | — | Character Stats, Cultivation Techniques, Meridian Map, Item DB, Edges (NPC half) |
| 25 | Travel & Map (inferred) | Gameplay | MVP | Implemented | — | World Gen, Time & Turn |
| 26 | Sects & Missions (inferred) | Gameplay | MVP | Implemented (thin) | — | World Gen, Character Stats, Market |
| 27 | World Generation & History | Narrative | MVP | Implemented | — | World DB, NPC Builds, Item DB, Config, Sim Core |
| 28 | Living World Tick | Narrative | Vertical Slice | Implemented (abstract) | — | World DB, Realms, NPC Builds, Edges (NPC half), Time & Turn |
| 29 | LLM Game Master: events, narration, epitaph, provider config | Narrative | MVP | Implemented (mock-tested only) | — | Event Engine, World DB, Config |
| 30 | NPC Interaction & Dialogue | Narrative | Vertical Slice | Implemented (thin) | — | World DB, LLM GM, Time & Turn |
| 31 | Quests | Narrative | Vertical Slice | Not Started | — | Event Engine, LLM GM, Dialogue, World DB |
| 32 | Achievements (Thành Tựu) | Meta | Vertical Slice | Implemented | quick spec: design/quick-specs/phu-luc-linh-thu-thanh-tuu.md | Character Stats, Realms, World DB, Save/Load |
| 33 | Balance Simulation Harness | Meta | MVP | Implemented | — | Time & Turn, Character Stats, Realms, Event Engine, Market, Edges |
| 34 | Localization & Hán-Việt Glossary | Meta | Alpha | Not Started | — | LLM GM, Event Engine, Guidance, Game UI, Config |
| 35 | Guidance Layer: Advisor, change line, tutorial role (inferred) | UI | Vertical Slice | Implemented | — | Realms, Spirit Herbs, Alchemy, Event Engine, Market, Travel, Sects, Edges, Meridian Map |
| 36 | Debug Terminal (added by request) | UI | MVP | Implemented | docs/debug-terminal.md (run guide, not a GDD) | Guidance, Save/Load, LLM GM |
| 37 | Game UI: Godot, 2D ink-wash | UI | Vertical Slice | Not Started | — | Guidance, Save/Load |
| 38 | Audio | Audio | Full Vision | Not Started | — | Game UI, Event Engine |
| 39 | The Way (Đạo) (added by request; holds the mutations moved out of the root) | Progression | Alpha (provisional) | Not Started | — | Spiritual Roots; contract provisional (Spiritual Roots Open Question 9); soft: Cultivation Techniques (techniques naming relocated mutations, its Open Question 11), Realms (any ceiling raise or root factor re-runs the breakthrough calibration) |

**Implementation note (2026-11-05).** Systems 6-10 are now built in the debug terminal from their GDDs (uncommitted on feature/debug-terminal). The Meridian Map GDD was revised to match by rule 21 (generic roads, smaller clusters, border gap clusters, region capacity, drawing rules), so it is back In Review. Results: `production/qa/evidence/balance/2026-11-05-gdd-bot-run.txt`.

**In Review (2026-11-04). The sixth cross-GDD pass, `reviews/cross-gdd/gdd-cross-review-2026-11-04f.md`, gave FAIL with 3 blockers; all three were revised the same day with user decisions (discrete brews, best plot play, the odds lever, one talisman per realm step, ceilings 10 / 3 / 15 %, mutation herb growth under the ceiling). Each revised GDD awaits a /design-review re-review, then a /review-all-gdds re-run. The seventh pass, `gdd-cross-review-2026-11-04g.md`, gave FAIL with 3 mechanical blockers (registry `breakthrough_guard` and `lifespan_cap`, h = 0 in Realms Formulas D) and design warnings F2, F11, F13-F16 and C5 awaiting user rulings.**
- 6 Spiritual Roots: Needs Revision. Independent review 2026-11-05 found 1 blocker (sector "spendable" against the Meridian frontier rule), fixed, with the plain-error items; a fresh re-review is due. A second review found 2 more, also fixed. Left open: what Void's `co_duyen_pct` does (deferred by the user). The earlier lean /design-review of 2026-11-04 on the redesign (five elements + eight variant roots; the 22 old mutations moved to the Way) found no blocking items and 8 recommended revisions (4 applied). Open: Meridian Map variant sectors (its Open Question 15), Wind and Void weights (guess), the Way (undesigned).
- 7 Character Stats: In Review. Fourth lean review (2026-11-04) NEEDS REVISION, revised: AC-CS-28, penalties apply after the cap, rule 12 / 14 source lists (nine kinds), craft mastery AC and Dependencies row, Formulas G rows.
- 8 Realms & Bottlenecks: Needs Revision. Independent review 2026-11-05 found 6 blockers, fixed, with the plain-error items; a fresh re-review is due. After it, the user set NPC odds of 1 in 8 / 12 / 15 / 20 and a world of 5,000 cultivators (never fewer than 3,000). A second review found 5 more, also fixed. Earlier: Needs Revision per 04g (its h = 0 blocker is fixed). Revised after 04g with user rulings: CF/NS recipes 4x60+10 / 4x100+80, pill_chance 0.04 / 0.045 / 0.02 / 0.0225, failure insight (+2 pp per failed attempt, cap 4), q-extras ceiling 10 pp, root factors and holder raises outside the target, Advisor plant plan; means 0.30 at every gate, ceiling run 0.44-0.46 accepted within AC-CG-60. Cross-GDD review 04h (FAIL: C1 insight-cap knob limit, F20 alchemy_yield scope) closed the balancing passes by user direction: macro targets hold, slightly overpowered builds are acceptable.
- 9 Cultivation Techniques: approved after its second lean review. Built as a flat item; layers, mastery, slots, harmony, the normalised speed factor and the speed/power split are not built. No 04f findings of its own.
- 10 Meridian Map: approved. Cleanup 2026-11-04: Formulas E2 guard handles a talisman on a #22 attempt (user decision). 04f warnings: F7 (linear W prices for a step growth payoff) and I1 (host labels).

**Pending obligations on systems without a GDD (04c W7, 04d W12):**
- Time & Turn (#4): a one-click "retreat until ripe" so the bottleneck wait at CF and NS (about 54 % / 57 % of W at a full bar) costs no attention (Realms Open Question 18; cross-GDD review 04g F2, user decision).
- Spirit Herbs & Spirit Fields (#14): plots are a build outside the breakthrough targets; the tree gives no plots at launch values; seed supply and plot cost are unassessed (04g F11).
- Item DB (#2): the unequip-treasure preview that Realms rule 14 needs when a change would end the life.
- Market (#20), Sects (#26), World Gen (#27) and World DB (#3): the Cultivation Techniques rule 18 duties (reserved copy, fallback stock, recording the new location).

**Folded in, not listed separately:** craft mastery (into Character Stats), the life chronicle and
LLM provider settings (into LLM GM), changing spiritual roots (into Spiritual Roots). The `GameSession`
facade is an architecture decision (an ADR), not a design system.

---

## Categories

| Category | Description | Systems |
|----------|-------------|---------|
| **Core** | Foundation everything reads | 1, 2, 3, 4 |
| **Persistence** | Save state and continuity | 5 |
| **Progression** | How a life, and across lives, grows | 6, 7, 8, 9, 10, 11, 12 |
| **Economy** | Resources, crafts and assets | 13–20 |
| **Gameplay** | Rules the player acts through | 21–26 |
| **Narrative** | World, history, story, dialogue | 27–31 |
| **Meta** | Outside the core loop | 32, 33, 34 |
| **UI** | Player-facing information | 35, 36, 37 |
| **Audio** | Sound and music | 38 |

---

## Priority Tiers

| Tier | Definition | Target Milestone | Design Urgency | Systems |
|------|------------|------------------|----------------|---------|
| **MVP** | Required for the core loop; without these you cannot test "is this fun?" | First playable | Design FIRST | 25: 1–11, 13, 14, 15, 20–27, 29, 33, 36 |
| **Vertical Slice** | One complete, polished area | Vertical slice / demo | Design SECOND | 8: 12, 16, 28, 30, 31, 32, 35, 37 |
| **Alpha** | All features present in rough form | Alpha | Design THIRD | 5: 17, 18, 19, 34, 39 |
| **Full Vision** | Polish and content-complete features | Beta / release | Design as needed | 1: 38 |

**Why these placements** (from the concept's MVP definition and scope tiers):
- MVP holds the whole engine chain (spiritual roots [linh căn] → herbs → pills → breakthrough → combat), because
  Pillar 3 (Power Is Built) cannot be tested without all of it; the Event Engine, because
  Pillar 2 forbids the LLM from running before its budgets exist; and World DB, world
  generation and NPC builds, because Pillar 5 (A World That Remembers) needs facts to recall.
- Systems 10 (Meridian Map [Kinh Mạch Đồ]) and 11 (Progression Edges) are MVP because the user required them
  for the first playable terminal; the concept's own MVP list does not mention them.
- Artifact Refining (Luyện Khí), the living-world tick, Codex, NPC memory and quests are Vertical Slice and
  Formations (Trận Pháp), Talismans (Phù Lục) and Spirit Beasts (Linh Thú) are Alpha exactly as the concept's scope tiers say, even
  though they are already built.
- Localization is Alpha although the concept's Scope tiers put localization at Full Vision;
  its market risk says "matters early", and string externalization needs an ADR before Alpha.

---

## Dependency Map

Design and build from top to bottom.

### Foundation Layer (no dependencies)

1. **Data-Driven Config** — every gameplay number lives in data; everything reads it.
2. **Deterministic Simulation Core** — seeded RNG and explainable numbers; the base of Pillar 2's "visible" numbers and of headless balancing.
3. **World Database** — the single record of people, sects, places, items and events.

### Core Layer

1. **Time & Turn Structure** — depends on: Config. The season is the unit crafts, herbs and aging count in.
2. **Item Database & Generation** — depends on: Config, Sim Core, World DB.
3. **Spiritual Roots (Linh Căn)** — depends on: Config, Sim Core.
4. **Save/Load** — depends on: World DB, Time & Turn.
5. **Character Stats** — depends on: Spiritual Roots, Sim Core, Config. *Bottleneck.*
6. **Realms & Bottlenecks (Cảnh Giới & Bình Cảnh)** — depends on: Character Stats, Spiritual Roots, Time & Turn, Item DB.
7. **Cultivation Techniques (Công Pháp)** — depends on: Item DB, Spiritual Roots, Realms (realm ladder as data).

### Feature Layer

1. **Spirit Herbs & Spirit Fields (Linh Thảo & Linh Điền)** — Item DB, Character Stats, Time & Turn.
2. **Alchemy (Luyện Đan)** — Spirit Herbs, Item DB, Character Stats.
3. **Meridian Map (Kinh Mạch Đồ)** — Spiritual Roots, Character Stats, Realms.
4. **Artifact Refining (Luyện Khí) / Formations (Trận Pháp) / Talismans (Phù Lục) / Spirit Beasts (Linh Thú)** — each on Item DB (Spirit Beasts on World DB) and Character Stats; each exposes a combat contribution and nothing back.
5. **NPC Build Generation** — Character Stats, Cultivation Techniques, Meridian Map, Item DB, Edges (NPC half).
6. **World Generation & History** — World DB, NPC Builds, Item DB, Config, Sim Core.
7. **Travel & Map, Market & Spirit Stone (Linh Thạch) Economy, Sects & Missions** — World Gen plus Character Stats, Realms, Time & Turn.
8. **Combat** — Character Stats, Realms, Cultivation Techniques, Meridian Map, and the four asset systems (read-only).
9. **Event Engine** — World DB, Character Stats, Item DB, NPC Builds, Alchemy, Talismans, Spirit Beasts, Combat. *Bottleneck.*
10. **Progression Edges** — Character Stats, Realms, Event Engine (player half: fortuitous encounters [cơ duyên]).
11. **Heavenly Tribulation (Thiên Kiếp)** — Combat, Realms, Event Engine.
12. **Living World Tick** — World DB, Realms, NPC Builds, Edges (NPC half), Time & Turn.
13. **The Way (Đạo)** — Spiritual Roots (read-only); soft: Cultivation Techniques, Realms. Provisional until its GDD.

### Presentation Layer

1. **LLM Game Master** — Event Engine, World DB, Config.
2. **NPC Interaction & Dialogue** — World DB, LLM GM, Time & Turn.
3. **Quests** — Event Engine, LLM GM, Dialogue, World DB.
4. **Guidance Layer** — reads most Feature systems (read-only).
5. **Debug Terminal** — Guidance, Save/Load, LLM GM.
6. **Game UI** — Guidance, Save/Load.

### Polish Layer

1. **Codex & Karmic Carryover** — Item DB, Alchemy, Spiritual Roots, Save/Load.
2. **Achievements (Thành Tựu)** — Character Stats, Realms, World DB, Save/Load.
3. **Balance Simulation Harness** — the session API over Time & Turn, Character Stats, Realms, Event Engine, Market, Edges.
4. **Localization & Hán-Việt Glossary** — every text-producing system.
5. **Audio** — Game UI, Event Engine.

**Bottlenecks** (many dependents; high design risk): Character Stats (about 20), Item DB,
World DB, Config, Event Engine, Combat. **Leaves** (low risk, design late): Audio, Localization,
Balance Harness, Game UI, Debug Terminal, Achievements, Codex.

---

## Recommended Design Order

Built systems: `/reverse-document design src/gameplay/<area>`, then `/design-review`.
Unbuilt systems (22, 31, 12, 37, 34, 38, 39): `/design-system`. Effort: S = 1 session, M = 2–3, L = 4+.

| Order | System | Priority | Layer | Agent(s) | Est. Effort |
|-------|--------|----------|-------|----------|-------------|
| 1 | Data-Driven Config | MVP | Foundation | lead-programmer | S |
| 2 | Deterministic Simulation Core | MVP | Foundation | systems-designer | S |
| 3 | World Database | MVP | Foundation | game-designer | M |
| 4 | Time & Turn Structure | MVP | Core | game-designer | M |
| 5 | Item Database & Generation | MVP | Core | economy-designer | M |
| 6 | Spiritual Roots (Linh Căn) | MVP | Core | systems-designer | L |
| 7 | Character Stats | MVP | Core | systems-designer | M |
| 8 | Realms & Bottlenecks (Cảnh Giới & Bình Cảnh) | MVP | Core | systems-designer | L |
| 9 | Cultivation Techniques (Công Pháp) | MVP | Core | game-designer | M |
| 10 | Save/Load | MVP | Core | gameplay-programmer | S |
| 11 | Spirit Herbs & Spirit Fields (Linh Thảo & Linh Điền) | MVP | Feature | economy-designer | M |
| 12 | Alchemy (Luyện Đan) | MVP | Feature | economy-designer | M |
| 13 | Meridian Map (Kinh Mạch Đồ) | MVP | Feature | systems-designer | M |
| 14 | NPC Build Generation | MVP | Feature | systems-designer | M |
| 15 | World Generation & History | MVP | Feature | world-builder | L |
| 16 | Travel & Map | MVP | Feature | level-designer | S |
| 17 | Market & Spirit Stone (Linh Thạch) Economy | MVP | Feature | economy-designer | M |
| 18 | Sects & Missions | MVP | Feature | game-designer | M |
| 19 | Combat | MVP | Feature | systems-designer | L |
| 20 | Event Engine | MVP | Feature | systems-designer | L |
| 21 | Progression Edges | MVP | Feature | systems-designer | M |
| 22 | Heavenly Tribulation (Thiên Kiếp) | MVP | Feature | game-designer | M |
| 23 | LLM Game Master | MVP | Presentation | narrative-director | L |
| 24 | Debug Terminal | MVP | Presentation | ux-designer | S |
| 25 | Balance Simulation Harness | MVP | Polish | qa-lead | S |
| 26 | Artifact Refining (Luyện Khí) | Vertical Slice | Feature | economy-designer | M |
| 27 | Living World Tick | Vertical Slice | Feature | world-builder | M |
| 28 | NPC Interaction & Dialogue | Vertical Slice | Presentation | narrative-director | M |
| 29 | Quests | Vertical Slice | Presentation | narrative-director | L |
| 30 | Guidance Layer | Vertical Slice | Presentation | ux-designer | S |
| 31 | Game UI | Vertical Slice | Presentation | ux-designer | L |
| 32 | Codex & Karmic Carryover | Vertical Slice | Polish | game-designer | M |
| 33 | Achievements (Thành Tựu) | Vertical Slice | Polish | game-designer | S |
| 34 | The Way (Đạo) | Alpha (provisional) | Feature | game-designer | L |
| 35 | Formations (Trận Pháp) | Alpha | Feature | economy-designer | M |
| 36 | Talismans (Phù Lục) | Alpha | Feature | economy-designer | M |
| 37 | Spirit Beasts & Spirit Insects (Linh Thú & Linh Trùng) | Alpha | Feature | systems-designer | L |
| 38 | Localization & Hán-Việt Glossary | Alpha | Polish | localization-lead | M |
| 39 | Audio | Full Vision | Polish | audio-director | M |

---

## Circular Dependencies

Four were found; all are resolved by splitting a contract, not by designing the systems together.

1. **Realms (Cảnh Giới) ↔ Cultivation Techniques (Công Pháp).** Technique speed feeds the cultivation rate; technique tiers cap
   at a realm. *Resolution:* the realm ladder (ids, names, stage counts) is a data contract owned
   by Realms; Cultivation Techniques depends on it, and the rate formula consumes techniques through the
   stat interface.
2. **Combat ↔ Talismans (Phù Lục) / Spirit Beasts (Linh Thú) / Formations (Trận Pháp).** The assets feed combat power; combat outcomes
   consume talismans and trigger taming. *Resolution:* assets only expose a read-only combat
   contribution; the hooks "on a won fight, offer taming" and "consume the talisman" belong to
   the Event Engine.
3. **Progression Edges ↔ Event Engine.** Fortuitous encounters (cơ duyên) are events, and the engine reads the edge
   state. *Resolution:* the Event Engine defines a generic gated-gift rule keyed on context flags
   (edge, fortuitous encounters left, at a bottleneck [bình cảnh]); Edges supplies the flags and the templates.
4. **Progression Edges → Event Engine → NPC Builds → Progression Edges** (found while writing
   this index). NPC Builds assigns NPC edges, the Event Engine creates NPCs through NPC Builds,
   and the player half of Edges (fortuitous encounters) depends on the Event Engine. *Resolution:* design
   Edges in two halves: the **NPC half** (edge score and fate, a pure function over a record,
   no Event Engine dependency) sits below NPC Builds; the **player half** (destiny perk [thiên mệnh], starting
   items, fortuitous encounters) sits above the Event Engine. One GDD, two dependency layers.

---

## High-Risk Systems

| System | Risk Type | Risk Description | Mitigation |
|--------|-----------|-----------------|------------|
| Event Engine, LLM Game Master | Technical | Pillar 2 rests on them. The real DeepSeek path is untested; the narration number check only catches digits; structured-output reliability is unproven | Run the real model early (key pending); extend the check to numbers written in words; keep template fallback |
| Combat, Heavenly Tribulation (Thiên Kiếp) | Design | The duel is a power ratio only; there is no tribulation; the concept's open question (how assets combine, how fighting beyond one's realm [vượt cấp] works) is unanswered | Answer it in the Combat GDD; prototype with the balance harness |
| Realms & Bottlenecks (Cảnh Giới & Bình Cảnh), Progression Edges | Design | Baseline per-step odds measured 42–46% / 27–35% against a 30% target while the edge sits at 71–79% / 53–74% against 70%; single levers move both together | Decide a baseline-only lever or a larger sample (96+ lives per arm) in the Realms & Bottlenecks GDD; log in design/quick-specs/progression-and-edges.md |
| Market & Spirit Stone (Linh Thạch) Economy, crafts | Design | Degenerate-strategy risk across five crafts; nothing past Core Formation (Kết Đan) is worth buying yet | Headless sims per spiritual root (linh căn) tier; add sinks when later realms are designed |
| Content volume | Scope | Concept targets about 60 spirit herbs (linh thảo), 40 recipes, 40 magic treasures (pháp bảo), 30 talismans (phù lục); the build has 8 herbs and 10 recipes | Content pass per tier; do not widen systems before the MVP loop is validated |
| Game UI | Technical | Nothing built; 2D ink-wash pipeline unproven; the Advisor and StateSnapshot APIs must be enough for a UI | Vertical slice (`/vertical-slice`) before committing; art bible first |
| Localization | Scope | Vietnamese text sits inside data files; Vietnamese, Chinese and English are all planned | ADR on string externalization before Alpha |
| Design debt | Process | 32 systems built with no GDDs; `project.yaml` stage is "Concept" | Reverse-document in the order above; reconcile stage with `/project-stage-detect` |

---

## Progress Tracker

| Metric | Count |
|--------|-------|
| Total systems identified | 39 |
| Systems implemented (debug terminal) | 32, of which 6 carry caveats: 19 (beasts only), 21 (duel only), 26 (thin), 28 (abstract), 29 (mock-tested only), 30 (thin) |
| Systems not started | 7: 12, 22, 31, 34, 37, 38, 39 (plus spirit insects [linh trùng], inside 19) |
| GDDs started | 5 (10 Meridian Map [Kinh Mạch Đồ] and 9 Cultivation Techniques [Công Pháp], reopened 2026-11-04 by the Spiritual Roots redesign; 7 Character Stats, in review after the cross-GDD review 04f revisions; 8 Realms & Bottlenecks [Cảnh Giới & Bình Cảnh], needs revision after the 2026-11-05 review, fixes applied; 6 Spiritual Roots [Linh Căn], redesigned 2026-11-04, pending review) |
| Quick specs covering systems | 4 (cover parts of 6, 8, 11, 16, 17, 18, 19, 32) |
| Design docs reviewed | 5 (Meridian Map: 6 lean passes; Realms & Bottlenecks: 8; Character Stats: 3; Spiritual Roots: 1 since its earlier 3 were set aside; Cultivation Techniques: 2) |
| Design docs approved | 0; 7, 9 and 10 in review (9 and 10 reopened by the Spiritual Roots redesign); 6 and 8 need revision after the 2026-11-05 reviews, fixes applied, re-review due |
| MVP systems designed | 5 / 25 |
| Vertical Slice systems designed | 0 / 8 |

---

## Next Steps

- [x] Review and approve this systems enumeration (2026-11-03)
- [ ] Reverse-document the MVP Foundation and Core systems in design order (`/reverse-document design src/gameplay/<area>`), starting with 1 to 3, then Spiritual Roots (Linh Căn), Character Stats and Realms & Bottlenecks (Cảnh Giới & Bình Cảnh)
- [ ] Run `/design-review` on each completed GDD (first: `design/gdd/kinh-mach-do.md`, in a fresh session)
- [x] Carry the level ladder (great and small breakthrough bonuses, stat rises at every breakthrough) from the Meridian Map (Kinh Mạch Đồ) GDD into the Realms & Bottlenecks GDD (done; the ladder is now 110 levels, 2026-11-05)
- [ ] Design the unbuilt MVP system, Heavenly Tribulation (Thiên Kiếp), with `/design-system thien-kiep`
- [ ] Design the Way (Đạo) with `/design-system dao`: the planned next GDD, taken ahead of its Alpha place in the design order. It owns the mutations moved out of the root, and Spiritual Roots Open Question 9 and Cultivation Techniques Open Question 11 wait on it
- [ ] Update `design/gdd/game-concept.md` to include the Meridian Map, Progression Edges and the Debug Terminal
- [ ] Reconcile `project.yaml` stage with `/project-stage-detect`
- [ ] Run `/gate-check technical-setup` when the MVP systems are designed
- [ ] Validate the highest-risk systems with `/vertical-slice` before committing to Production
