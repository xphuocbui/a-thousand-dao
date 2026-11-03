# Systems Index: Ten Thousand Daos

> **Status**: Approved (system list, dependencies and priority tiers approved by the user, 2026-11-03)
> **Created**: 2026-11-03
> **Last Updated**: 2026-11-03
> **Source Concept**: design/gdd/game-concept.md

---

## Overview

Ten Thousand Daos is a roguelite cultivation game: one life of 60–120 minutes, a procedurally
generated world with centuries of history, and a build the player constructs rather than picks
(Pillar 3, Power Is Built, Not Given). Its mechanical scope is four interlocking layers. A
**character layer** (linh căn, thiên phú, cảnh giới, công pháp, Kinh Mạch Đồ, thiên mệnh edges)
decides how fast and how safely a life advances. An **economy layer** (linh thảo that ages,
luyện đan, luyện khí, trận pháp, phù lục, linh thú, linh thạch) turns time and linh căn
affinity into assets (Pillar 4, Every Season Counts). A **world layer** (world generation with
history, a seasonal living-world tick, NPC builds under the player's own rules) gives the LLM
facts to build on (Pillar 5, A World That Remembers). A **bounded story layer** (an engine-side
event engine with budgets, plus an LLM game master that narrates and proposes events inside
them) delivers the stories (Pillar 2, Every Number Is Bounded and Visible). Presentation is a
text debug terminal today and a Godot 2D ink-wash UI later.

**Where the project actually is.** 32 of the 38 systems are implemented in the debug terminal
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
Linh Căn, Character Stats, Cảnh Giới, Công Pháp, Kinh Mạch, Edges, Codex, Item DB,
Linh Thảo, Luyện Đan, Luyện Khí, Trận Pháp, Phù Lục, Linh Thú, Market, Combat,
Thiên Kiếp, Event Engine, NPC Builds, Travel, Sects, World Gen, Living World, LLM GM,
Dialogue, Quests, Thành Tựu, Balance Harness, Localization, Guidance, Debug Terminal,
Game UI, Audio.

| # | System Name | Category | Priority | Status | Design Doc | Depends On |
|---|-------------|----------|----------|--------|------------|------------|
| 1 | Data-Driven Config (inferred) | Core | MVP | Implemented | — | — |
| 2 | Deterministic Simulation Core: seeded RNG, explainable numbers (inferred) | Core | MVP | Implemented | — | — |
| 3 | World Database | Core | MVP | Implemented | — | — |
| 4 | Time & Turn Structure | Core | MVP | Implemented | — | Config |
| 5 | Save/Load (inferred) | Persistence | MVP | Implemented | — | World DB, Time & Turn |
| 6 | Linh Căn (incl. changing linh căn) | Progression | MVP | Implemented | — (quick spec for changing roots: design/quick-specs/phu-luc-linh-thu-thanh-tuu.md) | Config, Sim Core |
| 7 | Character Stats (thiên phú, derived, đạo nghệ) | Progression | MVP | Implemented | — | Linh Căn, Sim Core, Config |
| 8 | Cảnh Giới & Bình Cảnh | Progression | MVP | Implemented | — (calibration notes: design/quick-specs/progression-and-edges.md) | Character Stats, Linh Căn, Time & Turn, Item DB |
| 9 | Công Pháp | Progression | MVP | Implemented | — | Item DB, Linh Căn, Cảnh Giới |
| 10 | Kinh Mạch Đồ (added by request) | Progression | MVP | Implemented | — | Linh Căn, Character Stats, Cảnh Giới |
| 11 | Progression Edges: thiên mệnh, cơ duyên, NPC edges (added by request) | Progression | MVP | Implemented | quick spec: design/quick-specs/progression-and-edges.md | Character Stats, Cảnh Giới, Event Engine (player half) |
| 12 | Codex & Karmic Carryover | Progression | Vertical Slice | Not Started | — | Item DB, Luyện Đan, Linh Căn, Save/Load |
| 13 | Item Database & Generation (inferred) | Economy | MVP | Implemented | — | Config, Sim Core, World DB |
| 14 | Linh Thảo & Linh Điền | Economy | MVP | Implemented | — | Item DB, Character Stats, Time & Turn |
| 15 | Luyện Đan | Economy | MVP | Implemented | — | Linh Thảo, Item DB, Character Stats |
| 16 | Luyện Khí | Economy | Vertical Slice | Implemented | quick spec: design/quick-specs/luyen-khi-and-tran-phap.md | Item DB, Character Stats |
| 17 | Trận Pháp | Economy | Alpha | Implemented | quick spec: design/quick-specs/luyen-khi-and-tran-phap.md | Item DB, Character Stats, Time & Turn |
| 18 | Phù Lục | Economy | Alpha | Implemented | quick spec: design/quick-specs/phu-luc-linh-thu-thanh-tuu.md | Item DB, Character Stats |
| 19 | Linh Thú & Linh Trùng | Economy | Alpha | Implemented (linh thú only) | quick spec: design/quick-specs/phu-luc-linh-thu-thanh-tuu.md | World DB, Character Stats, Time & Turn |
| 20 | Market & Linh Thạch Economy (inferred) | Economy | MVP | Implemented | — | Item DB, Character Stats, Cảnh Giới, World Gen |
| 21 | Combat | Gameplay | MVP | Implemented (power duel only) | — | Character Stats, Cảnh Giới, Công Pháp, Kinh Mạch, Luyện Khí, Trận Pháp, Phù Lục, Linh Thú |
| 22 | Thiên Kiếp (tribulation) | Gameplay | MVP | Not Started | — | Combat, Cảnh Giới, Event Engine |
| 23 | Event Engine: templates, budgets, validator, resolver | Gameplay | MVP | Implemented | — | World DB, Character Stats, Item DB, NPC Builds, Luyện Đan, Phù Lục, Linh Thú, Combat |
| 24 | NPC Build Generation (inferred) | Gameplay | MVP | Implemented | — | Character Stats, Công Pháp, Kinh Mạch, Item DB, Edges (NPC half) |
| 25 | Travel & Map (inferred) | Gameplay | MVP | Implemented | — | World Gen, Time & Turn |
| 26 | Sects & Missions (inferred) | Gameplay | MVP | Implemented (thin) | — | World Gen, Character Stats, Market |
| 27 | World Generation & History | Narrative | MVP | Implemented | — | World DB, NPC Builds, Item DB, Config, Sim Core |
| 28 | Living World Tick | Narrative | Vertical Slice | Implemented (abstract) | — | World DB, Cảnh Giới, NPC Builds, Edges (NPC half), Time & Turn |
| 29 | LLM Game Master: events, narration, epitaph, provider config | Narrative | MVP | Implemented (mock-tested only) | — | Event Engine, World DB, Config |
| 30 | NPC Interaction & Dialogue | Narrative | Vertical Slice | Implemented (thin) | — | World DB, LLM GM, Time & Turn |
| 31 | Quests | Narrative | Vertical Slice | Not Started | — | Event Engine, LLM GM, Dialogue, World DB |
| 32 | Thành Tựu (achievements) | Meta | Vertical Slice | Implemented | quick spec: design/quick-specs/phu-luc-linh-thu-thanh-tuu.md | Character Stats, Cảnh Giới, World DB, Save/Load |
| 33 | Balance Simulation Harness | Meta | MVP | Implemented | — | Time & Turn, Character Stats, Cảnh Giới, Event Engine, Market, Edges |
| 34 | Localization & Hán-Việt Glossary | Meta | Alpha | Not Started | — | LLM GM, Event Engine, Guidance, Game UI, Config |
| 35 | Guidance Layer: Advisor, change line, tutorial role (inferred) | UI | Vertical Slice | Implemented | — | Cảnh Giới, Linh Thảo, Luyện Đan, Event Engine, Market, Travel, Sects, Edges, Kinh Mạch |
| 36 | Debug Terminal (added by request) | UI | MVP | Implemented | docs/debug-terminal.md (run guide, not a GDD) | Guidance, Save/Load, LLM GM |
| 37 | Game UI: Godot, 2D ink-wash | UI | Vertical Slice | Not Started | — | Guidance, Save/Load |
| 38 | Audio | Audio | Full Vision | Not Started | — | Game UI, Event Engine |

**Folded in, not listed separately:** đạo nghệ (into Character Stats), the life chronicle and
LLM provider settings (into LLM GM), changing linh căn (into Linh Căn). The `GameSession`
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
| **Alpha** | All features present in rough form | Alpha | Design THIRD | 4: 17, 18, 19, 34 |
| **Full Vision** | Polish and content-complete features | Beta / release | Design as needed | 1: 38 |

**Why these placements** (from the concept's MVP definition and scope tiers):
- MVP holds the whole engine chain (linh căn → herbs → pills → breakthrough → combat), because
  Pillar 3 (Power Is Built) cannot be tested without all of it; the Event Engine, because
  Pillar 2 forbids the LLM from running before its budgets exist; and World DB, world
  generation and NPC builds, because Pillar 5 (A World That Remembers) needs facts to recall.
- Systems 10 (Kinh Mạch Đồ) and 11 (Progression Edges) are MVP because the user required them
  for the first playable terminal; the concept's own MVP list does not mention them.
- Luyện Khí, the living-world tick, Codex, NPC memory and quests are Vertical Slice and
  Trận Pháp, Phù Lục and Linh Thú are Alpha exactly as the concept's scope tiers say, even
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
3. **Linh Căn** — depends on: Config, Sim Core.
4. **Save/Load** — depends on: World DB, Time & Turn.
5. **Character Stats** — depends on: Linh Căn, Sim Core, Config. *Bottleneck.*
6. **Cảnh Giới & Bình Cảnh** — depends on: Character Stats, Linh Căn, Time & Turn, Item DB.
7. **Công Pháp** — depends on: Item DB, Linh Căn, Cảnh Giới (realm ladder as data).

### Feature Layer

1. **Linh Thảo & Linh Điền** — Item DB, Character Stats, Time & Turn.
2. **Luyện Đan** — Linh Thảo, Item DB, Character Stats.
3. **Kinh Mạch Đồ** — Linh Căn, Character Stats, Cảnh Giới.
4. **Luyện Khí / Trận Pháp / Phù Lục / Linh Thú** — each on Item DB (Linh Thú on World DB) and Character Stats; each exposes a combat contribution and nothing back.
5. **NPC Build Generation** — Character Stats, Công Pháp, Kinh Mạch, Item DB, Edges (NPC half).
6. **World Generation & History** — World DB, NPC Builds, Item DB, Config, Sim Core.
7. **Travel & Map, Market & Linh Thạch Economy, Sects & Missions** — World Gen plus Character Stats, Cảnh Giới, Time & Turn.
8. **Combat** — Character Stats, Cảnh Giới, Công Pháp, Kinh Mạch, and the four asset systems (read-only).
9. **Event Engine** — World DB, Character Stats, Item DB, NPC Builds, Luyện Đan, Phù Lục, Linh Thú, Combat. *Bottleneck.*
10. **Progression Edges** — Character Stats, Cảnh Giới, Event Engine (player half: cơ duyên).
11. **Thiên Kiếp** — Combat, Cảnh Giới, Event Engine.
12. **Living World Tick** — World DB, Cảnh Giới, NPC Builds, Edges (NPC half), Time & Turn.

### Presentation Layer

1. **LLM Game Master** — Event Engine, World DB, Config.
2. **NPC Interaction & Dialogue** — World DB, LLM GM, Time & Turn.
3. **Quests** — Event Engine, LLM GM, Dialogue, World DB.
4. **Guidance Layer** — reads most Feature systems (read-only).
5. **Debug Terminal** — Guidance, Save/Load, LLM GM.
6. **Game UI** — Guidance, Save/Load.

### Polish Layer

1. **Codex & Karmic Carryover** — Item DB, Luyện Đan, Linh Căn, Save/Load.
2. **Thành Tựu** — Character Stats, Cảnh Giới, World DB, Save/Load.
3. **Balance Simulation Harness** — the session API over Time & Turn, Character Stats, Cảnh Giới, Event Engine, Market, Edges.
4. **Localization & Hán-Việt Glossary** — every text-producing system.
5. **Audio** — Game UI, Event Engine.

**Bottlenecks** (many dependents; high design risk): Character Stats (about 20), Item DB,
World DB, Config, Event Engine, Combat. **Leaves** (low risk, design late): Audio, Localization,
Balance Harness, Game UI, Debug Terminal, Thành Tựu, Codex.

---

## Recommended Design Order

Built systems: `/reverse-document design src/gameplay/<area>`, then `/design-review`.
Unbuilt systems (22, 31, 12, 37, 34, 38): `/design-system`. Effort: S = 1 session, M = 2–3, L = 4+.

| Order | System | Priority | Layer | Agent(s) | Est. Effort |
|-------|--------|----------|-------|----------|-------------|
| 1 | Data-Driven Config | MVP | Foundation | lead-programmer | S |
| 2 | Deterministic Simulation Core | MVP | Foundation | systems-designer | S |
| 3 | World Database | MVP | Foundation | game-designer | M |
| 4 | Time & Turn Structure | MVP | Core | game-designer | M |
| 5 | Item Database & Generation | MVP | Core | economy-designer | M |
| 6 | Linh Căn | MVP | Core | systems-designer | L |
| 7 | Character Stats | MVP | Core | systems-designer | M |
| 8 | Cảnh Giới & Bình Cảnh | MVP | Core | systems-designer | L |
| 9 | Công Pháp | MVP | Core | game-designer | M |
| 10 | Save/Load | MVP | Core | gameplay-programmer | S |
| 11 | Linh Thảo & Linh Điền | MVP | Feature | economy-designer | M |
| 12 | Luyện Đan | MVP | Feature | economy-designer | M |
| 13 | Kinh Mạch Đồ | MVP | Feature | systems-designer | M |
| 14 | NPC Build Generation | MVP | Feature | systems-designer | M |
| 15 | World Generation & History | MVP | Feature | world-builder | L |
| 16 | Travel & Map | MVP | Feature | level-designer | S |
| 17 | Market & Linh Thạch Economy | MVP | Feature | economy-designer | M |
| 18 | Sects & Missions | MVP | Feature | game-designer | M |
| 19 | Combat | MVP | Feature | systems-designer | L |
| 20 | Event Engine | MVP | Feature | systems-designer | L |
| 21 | Progression Edges | MVP | Feature | systems-designer | M |
| 22 | Thiên Kiếp | MVP | Feature | game-designer | M |
| 23 | LLM Game Master | MVP | Presentation | narrative-director | L |
| 24 | Debug Terminal | MVP | Presentation | ux-designer | S |
| 25 | Balance Simulation Harness | MVP | Polish | qa-lead | S |
| 26 | Luyện Khí | Vertical Slice | Feature | economy-designer | M |
| 27 | Living World Tick | Vertical Slice | Feature | world-builder | M |
| 28 | NPC Interaction & Dialogue | Vertical Slice | Presentation | narrative-director | M |
| 29 | Quests | Vertical Slice | Presentation | narrative-director | L |
| 30 | Guidance Layer | Vertical Slice | Presentation | ux-designer | S |
| 31 | Game UI | Vertical Slice | Presentation | ux-designer | L |
| 32 | Codex & Karmic Carryover | Vertical Slice | Polish | game-designer | M |
| 33 | Thành Tựu | Vertical Slice | Polish | game-designer | S |
| 34 | Trận Pháp | Alpha | Feature | economy-designer | M |
| 35 | Phù Lục | Alpha | Feature | economy-designer | M |
| 36 | Linh Thú & Linh Trùng | Alpha | Feature | systems-designer | L |
| 37 | Localization & Hán-Việt Glossary | Alpha | Polish | localization-lead | M |
| 38 | Audio | Full Vision | Polish | audio-director | M |

---

## Circular Dependencies

Four were found; all are resolved by splitting a contract, not by designing the systems together.

1. **Cảnh Giới ↔ Công Pháp.** Công pháp speed feeds the cultivation rate; công pháp tiers cap
   at a realm. *Resolution:* the realm ladder (ids, names, stage counts) is a data contract owned
   by Cảnh Giới; Công Pháp depends on it, and the rate formula consumes công pháp through the
   stat interface.
2. **Combat ↔ Phù Lục / Linh Thú / Trận Pháp.** The assets feed combat power; combat outcomes
   consume talismans and trigger taming. *Resolution:* assets only expose a read-only combat
   contribution; the hooks "on a won fight, offer taming" and "consume the talisman" belong to
   the Event Engine.
3. **Progression Edges ↔ Event Engine.** Cơ duyên are events, and the engine reads the edge
   state. *Resolution:* the Event Engine defines a generic gated-gift rule keyed on context flags
   (edge, cơ duyên left, at a bình cảnh); Edges supplies the flags and the templates.
4. **Progression Edges → Event Engine → NPC Builds → Progression Edges** (found while writing
   this index). NPC Builds assigns NPC edges, the Event Engine creates NPCs through NPC Builds,
   and the player half of Edges (cơ duyên) depends on the Event Engine. *Resolution:* design
   Edges in two halves: the **NPC half** (edge score and fate, a pure function over a record,
   no Event Engine dependency) sits below NPC Builds; the **player half** (thiên mệnh, starting
   items, cơ duyên) sits above the Event Engine. One GDD, two dependency layers.

---

## High-Risk Systems

| System | Risk Type | Risk Description | Mitigation |
|--------|-----------|-----------------|------------|
| Event Engine, LLM Game Master | Technical | Pillar 2 rests on them. The real DeepSeek path is untested; the narration number check only catches digits; structured-output reliability is unproven | Run the real model early (key pending); extend the check to numbers written in words; keep template fallback |
| Combat, Thiên Kiếp | Design | The duel is a power ratio only; there is no tribulation; the concept's open question (how assets combine, how vượt cấp works) is unanswered | Answer it in the Combat GDD; prototype with the balance harness |
| Cảnh Giới & Bình Cảnh, Progression Edges | Design | Baseline per-step odds measured 42–46% / 27–35% against a 30% target while the edge sits at 71–79% / 53–74% against 70%; single levers move both together | Decide a baseline-only lever or a larger sample (96+ lives per arm) in the Cảnh Giới GDD; log in design/quick-specs/progression-and-edges.md |
| Market & Linh Thạch Economy, crafts | Design | Degenerate-strategy risk across five crafts; nothing past Kết Đan is worth buying yet | Headless sims per linh căn tier; add sinks when later realms are designed |
| Content volume | Scope | Concept targets about 60 linh thảo, 40 recipes, 40 pháp bảo, 30 phù lục; the build has 8 herbs and 10 recipes | Content pass per tier; do not widen systems before the MVP loop is validated |
| Game UI | Technical | Nothing built; 2D ink-wash pipeline unproven; the Advisor and StateSnapshot APIs must be enough for a UI | Vertical slice (`/vertical-slice`) before committing; art bible first |
| Localization | Scope | Vietnamese text sits inside data files; Vietnamese, Chinese and English are all planned | ADR on string externalization before Alpha |
| Design debt | Process | 32 systems built with no GDDs; `project.yaml` stage is "Concept" | Reverse-document in the order above; reconcile stage with `/project-stage-detect` |

---

## Progress Tracker

| Metric | Count |
|--------|-------|
| Total systems identified | 38 |
| Systems implemented (debug terminal) | 32, of which 6 carry caveats: 19 (thú only), 21 (duel only), 26 (thin), 28 (abstract), 29 (mock-tested only), 30 (thin) |
| Systems not started | 6: 12, 22, 31, 34, 37, 38 (plus Linh Trùng, inside 19) |
| GDDs started | 0 |
| Quick specs covering systems | 4 (cover parts of 6, 8, 11, 16, 17, 18, 19, 32) |
| Design docs reviewed | 0 |
| Design docs approved | 0 |
| MVP systems designed | 0 / 25 |
| Vertical Slice systems designed | 0 / 8 |

---

## Next Steps

- [x] Review and approve this systems enumeration (2026-11-03)
- [ ] Reverse-document the MVP Foundation and Core systems in design order (`/reverse-document design src/gameplay/<area>`), starting with 1 to 3, then Linh Căn, Character Stats and Cảnh Giới & Bình Cảnh
- [ ] Run `/design-review` on each completed GDD
- [ ] Design the unbuilt MVP system, Thiên Kiếp, with `/design-system thien-kiep`
- [ ] Update `design/gdd/game-concept.md` to include Kinh Mạch Đồ, Progression Edges and the Debug Terminal
- [ ] Reconcile `project.yaml` stage with `/project-stage-detect`
- [ ] Run `/gate-check technical-setup` when the MVP systems are designed
- [ ] Validate the highest-risk systems with `/vertical-slice` before committing to Production
