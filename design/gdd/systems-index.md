# Systems Index: Ten Thousand Daos

> **Status**: Approved (system list, dependencies and priority tiers approved by the user, 2026-11-03)
> **Created**: 2026-11-03
> **Last Updated**: 2026-11-10 (refresh: statuses compressed to the current state; progress tracker, design order and next steps updated; combat GDDs approved; seven progression GDDs revised after the 2026-11-10 reviews). Earlier: 2026-11-10 (combat review of #21, #21a, #21b and its fixes). Earlier: 2026-11-08 (#21a, #21b, #40 and #41 approved; the Combat revision #43 applied to combat.md with back-references in the older GDDs; next: a fresh /design-review of combat.md). Earlier: 2026-11-08 (#21a, #21b, #40 and #41 designed, pending review; next: four fresh-session design reviews, then the Combat revision #43. Earlier 2026-11-07: Modifier System added as #40, now in design and paused; Combat Defence & Healing #21a (in design) and Combat Damage Types #21b added as sub-systems of Combat; Effects System added as #41; Meridian Map redesign planned; build design order)
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

**Where the project actually is.** 32 of the 40 systems are implemented in the debug terminal
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
Market, Combat, Modifiers, Heavenly Tribulation (Thiên Kiếp), Event Engine, NPC Builds, Travel, Sects, World Gen,
Living World, LLM GM, Dialogue, Quests, Achievements (Thành Tựu), Balance Harness, Localization,
Guidance, Debug Terminal, Game UI, Audio.

| # | System Name | Category | Priority | Status | Design Doc | Depends On |
|---|-------------|----------|----------|--------|------------|------------|
| 1 | Data-Driven Config (inferred) | Core | MVP | Implemented | — | — |
| 2 | Deterministic Simulation Core: seeded RNG, explainable numbers (inferred) | Core | MVP | Implemented | — | — |
| 3 | World Database | Core | MVP | Implemented | — | — |
| 4 | Time & Turn Structure | Core | MVP | Implemented | — | Config |
| 5 | Save/Load (inferred) | Persistence | MVP | Implemented | — | World DB, Time & Turn |
| 6 | Spiritual Roots (Linh Căn) (incl. changing spiritual roots) | Progression | MVP | In Review: design-review 2026-11-10 (NEEDS REVISION) answered and fixed the same day; confirming re-review 2026-11-10 (NEEDS REVISION, small) answered and fixed the same day; next: a clean re-review for approval. History: the GDD header and its review log. | design/gdd/linh-can.md | Config, Sim Core; soft: Realms (breakthrough event, stage group), Character Stats (capability set) |
| 7 | Character Stats (innate talent [thiên phú], derived, craft mastery [đạo nghệ]) | Progression | MVP | In Review: design-review 2026-11-10 (NEEDS REVISION) answered and fixed the same day; confirming re-review 2026-11-10 (NEEDS REVISION, small) answered and fixed the same day; next: a clean re-review for approval. History: the GDD header and its review log. | design/gdd/character-stats.md | Spiritual Roots, Sim Core, Config; soft (via the provider interface): Realms, Meridian Map, Cultivation Techniques, Item DB, Progression Edges, Formations, Spirit Herbs & Spirit Fields |
| 8 | Realms & Bottlenecks (Cảnh Giới & Bình Cảnh) | Progression | MVP | In Review: design-review 2026-11-10 (NEEDS REVISION) answered and fixed the same day; the gate calibration must be re-run (its Open Question 23); confirming re-review 2026-11-10 (NEEDS REVISION, small) answered and fixed the same day; next: a clean re-review for approval. History: the GDD header and its review log. | design/gdd/canh-gioi.md | Config, Sim Core, Time & Turn, Spiritual Roots, Character Stats, Item DB; soft: Cultivation Techniques, Spirit Herbs, Alchemy, Formations, Travel & Map, Event Engine, Progression Edges |
| 9 | Cultivation Techniques (Công Pháp) | Progression | MVP | In Review: design-review 2026-11-10 (NEEDS REVISION) answered and fixed the same day; confirming re-review 2026-11-10 (NEEDS REVISION, small) answered and fixed the same day; next: a clean re-review for approval. History: the GDD header and its review log. | design/gdd/cong-phap.md | Spiritual Roots, Realms, Character Stats, Item DB; soft: Time & Turn, Meridian Map |
| 10 | Meridian Map (Kinh Mạch Đồ) (added by request) | Progression | MVP | In Review: **major revision 2026-11-10** to the hand-drawn tree (rules final; the drawn map is a **shape placeholder**, user 2026-11-10; content pass and bot calibration open); confirming re-review 2026-11-10 (NEEDS REVISION, small) answered and fixed the same day; next: a clean re-review for approval. History: the GDD header and its review log. | design/gdd/kinh-mach-do.md | Spiritual Roots, Character Stats, Realms, Config, Sim Core; soft: Event Engine, Item DB, Cultivation Techniques, LLM GM, World DB, Edges |
| 11 | Progression Edges: destiny perk (thiên mệnh), fortuitous encounters (cơ duyên), NPC edges (added by request) | Progression | MVP | Implemented | quick spec: design/quick-specs/progression-and-edges.md | Character Stats, Realms, Event Engine (player half) |
| 12 | Codex & Karmic Carryover | Progression | Vertical Slice | Not Started | — | Item DB, Alchemy, Spiritual Roots, Save/Load |
| 13 | Item Database & Generation (inferred) | Economy | MVP | In Review: design-review 2026-11-10 (NEEDS REVISION) answered and fixed the same day (named items, `artifact_slots`, damage type, reward bounds, Mạch Ấn retired); confirming re-review 2026-11-10 (NEEDS REVISION, small) answered and fixed the same day; next: a clean re-review for approval. Built, with the gaps in its Build Gaps section. History: the GDD header and its review log. | design/gdd/item-database.md | Config, Sim Core, World DB; soft: Character Stats (lifespan-cap preview) |
| 14 | Spirit Herbs & Spirit Fields (Linh Thảo & Linh Điền) | Economy | MVP | Implemented | — | Item DB, Character Stats, Time & Turn |
| 15 | Alchemy (Luyện Đan) | Economy | MVP | Implemented | — | Spirit Herbs, Item DB, Character Stats |
| 16 | Artifact Refining (Luyện Khí) | Economy | Vertical Slice | Implemented | quick spec: design/quick-specs/luyen-khi-and-tran-phap.md | Item DB, Character Stats |
| 17 | Formations (Trận Pháp) | Economy | Alpha | Implemented | quick spec: design/quick-specs/luyen-khi-and-tran-phap.md | Item DB, Character Stats, Time & Turn |
| 18 | Talismans (Phù Lục) | Economy | Alpha | Implemented | quick spec: design/quick-specs/phu-luc-linh-thu-thanh-tuu.md | Item DB, Character Stats |
| 19 | Spirit Beasts & Spirit Insects (Linh Thú & Linh Trùng) | Economy | Alpha | Implemented (spirit beasts only) | quick spec: design/quick-specs/phu-luc-linh-thu-thanh-tuu.md | World DB, Character Stats, Time & Turn |
| 20 | Market & Spirit Stone (Linh Thạch) Economy (inferred) | Economy | MVP | Implemented | — | Item DB, Character Stats, Realms, World Gen |
| 21 | Combat | Gameplay | MVP | **Approved 2026-11-10** (combat review, five headless rounds; Combat revision #43 and economy revision #44 applied). Built only as the old duel. History: the GDD header and its review log. | design/gdd/combat.md | Character Stats, Realms, Cultivation Techniques, Meridian Map, Artifact Refining, Formations, Talismans, Spirit Beasts |
| 21a | Combat Defence & Healing (Phòng Ngự & Trị Thương), a **sub-system of Combat (#21)** (added by request 2026-11-07): wards (hộ thể) and their records and cost models, resistance by damage type, block, shields (uncapped), evade, soul and status resistance, maximum health, and healing in a fight | Gameplay | MVP | **Approved 2026-11-10** (combat review rounds 4 and 5). Not built. History: the GDD header and its review log. | design/gdd/combat-defence.md | Combat (Formulas A, D, E, F, I; rules 11, 22), Character Stats, Modifier System (#40: defence and healing stats); read by: Effects System (#41: heal and lifesteal sources), Item DB, Artifact Refining, Cultivation Techniques, The Way |
| 21b | Combat Damage Types (Loại Sát Thương), a **sub-system of Combat (#21)** (added by request 2026-11-07): eight damage types (Physical, Force, Fire, Cold, Lightning, Light, Chaos, Soul), elements as art tags only, no element cycle in fights, conversion (at most 2 per hit, by step), and which defence each damage type meets | Gameplay | MVP | **Approved 2026-11-10** (combat review confirming round). Not built. History: the GDD header and its review log. | design/gdd/combat-damage-types.md | Combat (rules 4, 6, 7; Formulas C, F), Combat Defence & Healing (#21a: resistance by final damage type), Spiritual Roots (elements, variants), Modifier System (#40: damage and penetration stats); read by: Effects System (#41), The Way, Cultivation Techniques, Item DB |
| 22 | Heavenly Tribulation (Thiên Kiếp) | Gameplay | MVP | Approved for rules (2026-11-06; #44 pass 2026-11-10); numbers provisional until the Balance Harness measures `p_t`. Not built. History: the GDD header and its review log. | design/gdd/thien-kiep.md | Combat, Realms, Event Engine |
| 23 | Event Engine: templates, budgets, validator, resolver | Gameplay | MVP | Implemented | — | World DB, Character Stats, Item DB, NPC Builds, Alchemy, Talismans, Spirit Beasts, Combat |
| 24 | NPC Build Generation (inferred) | Gameplay | MVP | Implemented | — | Character Stats, Cultivation Techniques, Meridian Map, Item DB, Edges (NPC half) |
| 25 | Travel & Map (inferred) | Gameplay | MVP | Implemented (thin: named regions and a graph of places). **An open world map is needed** (user decision 2026-11-06). See System Briefs: World Map | — | World Gen, Time & Turn |
| 26 | Sects & Missions (inferred) | Gameplay | MVP | Implemented (thin) | — | World Gen, Character Stats, Market |
| 27 | World Generation & History | Narrative | MVP | Implemented | — | World DB, NPC Builds, Item DB, Config, Sim Core |
| 28 | Living World Tick | Narrative | Vertical Slice | Implemented (abstract) | — | World DB, Realms, NPC Builds, Edges (NPC half), Time & Turn |
| 29 | LLM Game Master: events, narration, epitaph, provider config | Narrative | MVP | Implemented (mock-tested only) | — | Event Engine, World DB, Config |
| 30 | NPC Interaction & Dialogue | Narrative | Vertical Slice | Implemented (thin) | — | World DB, LLM GM, Time & Turn |
| 31 | Quests | Narrative | Vertical Slice | Approved (2026-11-08); numbers are guesses; Event Engine, LLM GM and Dialogue contracts provisional. Not built. History: the GDD header and its review log. | design/gdd/quests.md | Event Engine, LLM GM, Dialogue, World DB |
| 32 | Achievements (Thành Tựu) | Meta | Vertical Slice | Implemented | quick spec: design/quick-specs/phu-luc-linh-thu-thanh-tuu.md | Character Stats, Realms, World DB, Save/Load |
| 33 | Balance Simulation Harness | Meta | MVP | Implemented | — | Time & Turn, Character Stats, Realms, Event Engine, Market, Edges |
| 34 | Localization & Hán-Việt Glossary | Meta | Alpha | Not Started | — | LLM GM, Event Engine, Guidance, Game UI, Config |
| 35 | Guidance Layer: Advisor, change line, tutorial role (inferred) | UI | Vertical Slice | Implemented | — | Realms, Spirit Herbs, Alchemy, Event Engine, Market, Travel, Sects, Edges, Meridian Map |
| 36 | Debug Terminal (added by request) | UI | MVP | Implemented | docs/debug-terminal.md (run guide, not a GDD) | Guidance, Save/Load, LLM GM |
| 37 | Game UI: Godot, 2D ink-wash | UI | Vertical Slice | Not Started | — | Guidance, Save/Load |
| 38 | Audio | Audio | Full Vision | Not Started | — | Game UI, Event Engine |
| 39 | The Way (Đạo) (added by request; holds the mutations moved out of the root) | Progression | Alpha (provisional) | In Review: graph Ways, 94-Way Catalogue (short Hán-Việt names with poetic titles), Sword pilot drawn; design-review 2026-11-10 answered and fixed; confirming re-review 2026-11-10 (NEEDS REVISION, small) answered and fixed the same day; next: a clean re-review for approval. Not built. History: the GDD header and its review log. | design/gdd/dao.md | Spiritual Roots; contract provisional (Spiritual Roots Open Question 9); Meridian Map (shared skill points); Combat (arts only, on hold: needs a full combat system); soft: Cultivation Techniques (techniques naming relocated mutations, its Open Question 11), Realms (any ceiling raise or root factor re-runs the breakthrough calibration) |
| 40 | Modifier System (added by request 2026-11-07; the base every build piece draws from; plain numbers on a stat only, user decision 2026-11-07) | Gameplay | MVP | **Approved** (2026-11-08b; #44 parts 4–5 accepted 2026-11-10; re-review 2026-11-10 fixes applied). Not built. History: the GDD header and its review log. | design/gdd/modifiers.md | Combat (damage layers L1–L5 and their caps, channels, ward models), Character Stats; read by: Meridian Map, The Way (Đạo), Cultivation Techniques, Item DB, Artifact Refining, Formations, Talismans, Spirit Beasts |
| 41 | Effects System (added by request 2026-11-07): every build piece with a rule in it (conditions, scaling, triggers, conditional conversion, overflow, rule changes, keystones, enablers), each granting Modifier System modifiers as its payload | Gameplay | MVP | **Approved** (2026-11-08c; #44 part 3 and equal-value element stacks 2026-11-10; re-review 2026-11-10 fixes applied). Not built. History: the GDD header and its review log. | design/gdd/effects.md | Modifier System (#40), Combat (#21, #21a), Character Stats; read by: Meridian Map, The Way, Cultivation Techniques, Item DB, Formations, Talismans, Spirit Beasts |
| 42 | NPC Traits (added by request 2026-11-10; personality traits in the manner of grand-strategy character games) | Narrative | Alpha (provisional; later) | Not Started. See System Briefs: NPC Traits | — | NPC Builds, Living World Tick, Event Engine, Character Stats, Modifier System, NPC Interaction & Dialogue, LLM GM |

**Build design order (user decision 2026-11-07).** Builds are the game: a concept with modifiers stacked on it, sometimes opened by an enabler. Content is designed from the shared pieces up, and builds come last as tests. **Before step 1 is finished (user decision 2026-11-07):** Combat Defence & Healing (#21a) and Combat Damage Types (#21b) are designed first as sub-systems of Combat (files prefixed `combat-`, flat in `design/gdd/` for now. **User decision 2026-11-07:** the combat GDDs move into `design/gdd/combat/` later, once more combat docs exist. Before the move, the skills and hooks that read `design/gdd/*.md` without subfolders (about 28 sites) must be made to read subfolders, and the 46 files that cite `combat.md` updated, so no review silently skips a combat GDD), then the Modifier System is resumed, then the Effects System (#41), then one Combat revision that folds in #21a and the Modifier and Effects contracts. The steps: (1) the Modifier System (#40), the shared vocabulary of modifiers by layer and channel; (2) The Way (Đạo) as broad Ways, each with three branches drawn mostly from that vocabulary; (3) Cultivation Techniques (Công Pháp); (4) items and enablers; (5) builds, which check that a fantasy can be made from existing pieces and add a new piece only when a second build would use it too. The overnight build campaign of 2026-11-07 (`design/builds/overnight-2026-11-07/`, 69 builds) went builds-first: its builds and content are **proposals to be re-evaluated and filtered** against the new pieces, not adopted content. Its rule findings (`decisions.md`) stand on their own.

**Implementation note (2026-11-05).** Systems 6-10 are now built in the debug terminal from their GDDs (uncommitted on feature/debug-terminal). The Meridian Map GDD was revised to match by rule 21 (generic roads, smaller clusters, border gap clusters, region capacity, drawing rules), so it is back In Review. Results: `production/qa/evidence/balance/2026-11-05-gdd-bot-run.txt`.

**In Review (2026-11-04). The sixth cross-GDD pass, `reviews/cross-gdd/gdd-cross-review-2026-11-04f.md`, gave FAIL with 3 blockers; all three were revised the same day with user decisions (discrete brews, best plot play, the odds lever, one talisman per realm step, ceilings 10 / 3 / 15 %, mutation herb growth under the ceiling). Each revised GDD awaits a /design-review re-review, then a /review-all-gdds re-run. The seventh pass, `gdd-cross-review-2026-11-04g.md`, gave FAIL with 3 mechanical blockers (registry `breakthrough_guard` and `lifespan_cap`, h = 0 in Realms Formulas D) and design warnings F2, F11, F13-F16 and C5 awaiting user rulings.**
- 6 Spiritual Roots: In Review. Independent review 2026-11-05 found 1 blocker (sector "spendable" against the Meridian frontier rule), fixed, with the plain-error items; a third review's 1 was also fixed. A second review found 2 more, also fixed. Left open: what Void's `co_duyen_pct` does (deferred by the user). The earlier lean /design-review of 2026-11-04 on the redesign (five elements + eight variant roots; the 22 old mutations moved to the Way) found no blocking items and 8 recommended revisions (4 applied). Open: Meridian Map variant sectors (its Open Question 15), Wind and Void weights (guess), the Way (undesigned).
- 7 Character Stats: In Review after the 2026-11-05 review (7 blockers, fixed). Earlier: Fourth lean review (2026-11-04) NEEDS REVISION, revised: AC-CS-28, penalties apply after the cap, rule 12 / 14 source lists (nine kinds), craft mastery AC and Dependencies row, Formulas G rows.
- 8 Realms & Bottlenecks: In Review. Independent review 2026-11-05 found 6 blockers, fixed, with the plain-error items; a third review's 5 were also fixed. After it, the user set NPC odds of 1 in 8 / 12 / 15 / 20 and a world of 5,000 cultivators (never fewer than 3,000). A second review found 5 more, also fixed. Earlier: Needs Revision per 04g (its h = 0 blocker is fixed). Revised after 04g with user rulings: CF/NS recipes 4x60+10 / 4x100+80, pill_chance 0.04 / 0.045 / 0.02 / 0.0225, failure insight (+2 pp per failed attempt, cap 4), q-extras ceiling 10 pp, root factors and holder raises outside the target, Advisor plant plan; means 0.30 at every gate, ceiling run 0.44-0.46 accepted within AC-CG-60. Cross-GDD review 04h (FAIL: C1 insight-cap knob limit, F20 alchemy_yield scope) closed the balancing passes by user direction: macro targets hold, slightly overpowered builds are acceptable.
- 9 Cultivation Techniques: In Review after the 2026-11-05 review (7 blockers, fixed). Built, including layers, mastery, slots and harmony; unbuilt display items are in its Open Question 8.
- 10 Meridian Map: In Review after the 2026-11-05 review (10 blockers, fixed); built gaps are in its Known gaps table. Earlier: Cleanup 2026-11-04: Formulas E2 guard handles a talisman on a #22 attempt (user decision). 04f warnings: F7 (linear W prices for a step growth payoff) and I1 (host labels).

**Pending obligations on systems without a GDD (04c W7, 04d W12):**
- Time & Turn (#4): a one-click "retreat until ripe" so the bottleneck wait at CF and NS (about 54 % / 57 % of W at a full bar) costs no attention (Realms Open Question 18; cross-GDD review 04g F2, user decision).
- Spirit Herbs & Spirit Fields (#14): plots are a build outside the breakthrough targets; the tree gives no plots at launch values; seed supply and plot cost are unassessed (04g F11).
- Item DB (#13): the unequip-treasure preview that Realms rule 14 needs when a change would end the life is designed (rule 12) and not built.
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
13. **The Way (Đạo)** — Spiritual Roots (read-only), Meridian Map (shared skill points); soft: Cultivation Techniques, Realms, Event Engine; Combat for arts only (on hold). Provisional until its GDD is approved.
14. **Modifier System** — Combat (layers, caps, channels), Character Stats. Designed before the Meridian Map redesign and the Đạo catalogue, which draw their nodes from it, as do Cultivation Techniques and the item systems.

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
Unbuilt systems (22, 31, 12, 37, 34, 38, 39, 40, 21a, 21b, 41): `/design-system`. Effort: S = 1 session, M = 2–3, L = 4+.

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
| 40 | Combat Defence & Healing (#21a; approved 2026-11-10) | MVP | Feature | game-designer, systems-designer | M |
| 40b | Combat Damage Types (#21b; approved 2026-11-10) | MVP | Feature | game-designer, systems-designer | M |
| 41 | Modifier System (#40; approved) | MVP | Feature | systems-designer | M |
| 42 | Effects System (#41; approved) | MVP | Feature | game-designer, systems-designer | L |
| 43 | Combat revision (folds in #21a, #40, #41); then the Meridian Map redesign, the Đạo catalogue, Cultivation Techniques, items — **applied 2026-11-08** (combat.md parts 1–5; back-reference sweep in nine older GDDs) | MVP | Feature | systems-designer | M |
| 44 | Combat economy revision (sustain-first fights, element stacks), **done 2026-11-10** (`design/research/economy-revision-44-decisions.md`; applied to combat.md, combat-defence.md, effects.md, modifiers.md, character-stats.md) | MVP | Feature | game-designer, systems-designer | L |

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
| Combat, Heavenly Tribulation (Thiên Kiếp) | Design | The duel is a power ratio only, and a full combat system is needed (user decision 2026-11-05; The Way's arts wait on it); there is no tribulation; the concept's open question (how assets combine, how fighting beyond one's realm [vượt cấp] works) is unanswered | Answered in design/gdd/combat.md (2026-11-06); its numbers come from a simplified simulation, so confirm them with the balance harness |
| Realms & Bottlenecks (Cảnh Giới & Bình Cảnh), Progression Edges | Design | Baseline per-step odds measured 42–46% / 27–35% against a 30% target while the edge sits at 71–79% / 53–74% against 70%; single levers move both together | Decide a baseline-only lever or a larger sample (96+ lives per arm) in the Realms & Bottlenecks GDD; log in design/quick-specs/progression-and-edges.md |
| Market & Spirit Stone (Linh Thạch) Economy, crafts | Design | Degenerate-strategy risk across five crafts; nothing past Core Formation (Kết Đan) is worth buying yet | Headless sims per spiritual root (linh căn) tier; add sinks when later realms are designed |
| Content volume | Scope | Concept targets about 60 spirit herbs (linh thảo), 40 recipes, 40 magic treasures (pháp bảo), 30 talismans (phù lục); the build has 8 herbs and 10 recipes | Content pass per tier; do not widen systems before the MVP loop is validated |
| Game UI | Technical | Nothing built; 2D ink-wash pipeline unproven; the Advisor and StateSnapshot APIs must be enough for a UI | Vertical slice (`/vertical-slice`) before committing; art bible first |
| Localization | Scope | Vietnamese text sits inside data files; Vietnamese, Chinese and English are all planned | ADR on string externalization before Alpha |
| Design debt | Process | 32 systems built with no GDDs; `project.yaml` stage is "Concept" | Reverse-document in the order above; reconcile stage with `/project-stage-detect` |

---

## Progress Tracker

| Metric | Count (2026-11-10) |
|--------|-------|
| Systems identified | 44 (42 numbered, plus Combat's sub-systems #21a and #21b) |
| Systems implemented (debug terminal) | 32, of which 6 carry caveats: 19 (beasts only), 21 (old duel only), 26 (thin), 28 (abstract), 29 (mock-tested only), 30 (thin). The built game predates this week's design (old Meridian map, ceilings, variant sectors, hidden clusters) |
| Systems not built | 10: 12, 21a, 21b, 22, 31, 34, 37, 38, 40, 41 (plus spirit insects inside 19; #39 the Way) |
| GDDs | 15: 6, 7, 8, 9, 10, 13, 21, 21a, 21b, 22, 31, 39, 40, 41, and the Way's catalogue inside 39 |
| GDDs approved | 7: 21, 21a, 21b, 40, 41 (approved), 22 and 31 (approved for rules; numbers provisional) |
| GDDs in review | 7: 6, 7, 8, 9, 10, 13, 39 (review and confirming re-review fixes applied 2026-11-10) |
| Built MVP systems without a GDD | 17: 1, 2, 3, 4, 5, 11, 14, 15, 20, 23, 24, 25, 26, 27, 29, 33, 36 |
| Quick specs covering systems | 4 (cover parts of 6, 8, 11, 16, 17, 18, 19, 32) |
| MVP systems designed | 13 / 27 (25 MVP plus #21a, #21b, #40, #41 counted) |
| Vertical Slice systems designed | 1 / 8 (31) |

---

## System Briefs

Recorded 2026-11-06 at the user's request, so the intent is not lost. Combat is now designed in
design/gdd/combat.md; the World Map is not. **User intent** is binding on the eventual GDD. **Ideas to explore** are starting points,
not decisions: `/design-system` puts each one to the user.

### Combat (#21)

**User intent:** a combat system that is very build-heavy, and complex enough that the player
feels a build makes a difference, much like Path of Exile. With the correct build, scaling can
go very high.

**Ideas to explore:**
- **Scaling layers.** Bonuses add within a layer and multiply across layers, so a build that
  works several layers far outscales one that stacks a single number. Big numbers then come from
  how a build is assembled, not from a stat race.
- **Every system is a build slot.** Root, technique, Meridian Map, Daos, artifacts, talismans,
  formations, spirit beasts and pills all feed one rule set through shared tags.
- **Tagged arts.** An art carries tags (element, sword, soul, poison) and a build's modifiers key
  off them. Techniques and Dao nodes change how an art behaves, not only how hard it hits.
- **Conversion and triggers.** Fire converted to Lava by a Dao, or "when X happens, do Y", give
  builds their signature combos.
- **Several kinds of threat.** Body, qi and soul attacks, damage over time, curses and layered
  defences, with enemies that punish one-note builds, so a build must answer more than damage.
- **Spiritual power (linh lực) as the fight's economy.** Long fights drain it, so sustain is a
  build choice too.
- **Preparation counts.** Formations laid, talismans drawn, poison applied and ground chosen
  before a fight, in the spirit of the game's "build with the system" core.
- **Fighting above your realm (vượt cấp)** is the payoff a great build earns, against realm
  suppression.
- **Every hit explains itself** with a Breakdown, so a player can see why a build won or lost.

**Must be solved in the design:**
- The Meridian Map and the Way price everything in W, which is additive (1 W = +1 % attack).
  Multiplying layers break that pricing, so the W scale, `dao_premium` and capability tiers need
  a decision.
- NPCs need a cheap abstract form: 5,000 cultivators cannot run full fights each season. The
  player's and the NPCs' power must stay comparable.
- Fights stay deterministic from the seed, and readable in the Debug Terminal.
- Heavenly Tribulation (#22) depends on Combat, so Combat comes first.

### World Map (#25, with World Generation #27)

**User intent:** generate an open world map that players travel across. There are hidden places
that players can find clues for. Distance between places is reflected in the game: NPCs
travelling, sects, kingdoms, culture, economy, environment and more. Each location has stats,
much like a Dwarf Fortress map. Some places are good for planting certain herbs and plants, or
good for other specific things.

**Ideas to explore:**
- **Layered generation.** Seeded elevation, rainfall, temperature and drainage give biomes and
  rivers. A cultivation layer sits on top: spiritual qi density (linh khí), five-element
  affinity, dragon veins (long mạch) and miasma.
- **A location's stat block:** qi density, element affinity, soil, climate, danger, resources,
  population, ruler, culture and trade access.
- **Places that matter to a build.** A Fire root cultivates faster near a volcano, a Water herb
  thrives in a wet valley, some herbs grow in one kind of place only, and where a character sets
  a cave dwelling (động phủ) or field is a real decision. Fighting on Fire-rich ground could
  favour Fire arts.
- **Distance as a cost.** Travel time depends on terrain and route: road, river, flight by realm,
  or teleport arrays (truyền tống trận) that sects control.
- **News and goods travel too.** Rumours reach far towns late. Prices differ by distance from
  the source, so trade routes pay. A sect's reach fades with distance, and geography shapes
  borders and cultures.
- **Hidden places:** secret realms (bí cảnh), ruins and dead cultivators' cave dwellings, placed
  by the world's history, so a famous dead NPC's cave can really be there.
- **Clues narrow the search.** A rumour names a region, a jade slip (ngọc giản) a mountain, a torn
  map a valley. Clues can be bought, found or false, and the player's own map only shows what
  they have seen.
- **The map changes.** Over-harvested veins thin out, wars move borders, great battles scar the
  land, and secret realms open on cycles.

**Must be solved in the design:**
- The living world must stay cheap: a tick for 5,000 cultivators on a large map, and the save
  size that map needs.
- How much simulation is per region and how much per location.
- How a map reads in a text terminal, and later in the Game UI.
- The move from today's region-and-place graph, and what that does to Market, Sects, Spirit
  Fields, Events and the balance bots that rely on it.

### NPC Traits (#42)

Recorded 2026-11-10 at the user's request, to be designed later.

**User intent:** a trait system for NPCs, similar in spirit to the trait systems of grand-strategy character games
(personality, lifestyle and congenital traits). Traits decide how an NPC acts around events (what it chooses, whom it
helps or betrays, what it risks) and somewhat affect its stats. The goal is a world that feels more realistic and
lively. Not urgent: it can come after the world map and sects.

**Ideas to explore (not decisions):**
- Trait kinds: personality (greedy, cautious, ambitious, righteous, ruthless), lifestyle (alchemist, swordsman,
  recluse), congenital or fate-given (heaven-favoured, ill-starred), and traits gained from events (scarred, vengeful).
- Stat effects as plain modifiers through the Modifier System (a trait is one more modifier source on the Character
  Stats sheet); behaviour effects as weights on event choices and Living World Tick actions.
- Opposed traits (cautious vs reckless) and how NPCs regard others with shared or opposed traits (attitude in NPC
  Interaction & Dialogue, sect loyalty).
- Whether the player has traits too, or only NPCs; whether the LLM Game Master reads traits for narration.
- Cost: traits per NPC across 5,000 cultivators must stay cheap in the season tick and the save.

---

## Next Steps

Done: the systems enumeration (2026-11-03); the level ladder into Realms (2026-11-05); Heavenly Tribulation designed
(2026-11-06); the full Combat design with #21a, #21b, #40, #41, revisions #43 and #44 (approved 2026-11-10); the Way
designed and its catalogue started (2026-11-10); the Meridian Map redrawn by hand and its GDD rewritten (2026-11-10);
design reviews of the progression GDDs with fixes (2026-11-10).

- [x] Confirming re-reviews of 6, 7, 8, 9, 10, 13 and 39, and their fixes (2026-11-10)
- [ ] A last clean re-review of those seven for approval
- [ ] `/consistency-check`, then a split `/review-all-gdds` (progression, combat, economy and content, then a cross-part pass)
- [ ] Library track (user's design order: modifiers, Đạo, công pháp, items, builds): the Đạo catalogue (93 of 94 Ways to draw;
      the Sword Effects into effects.md), the công pháp catalogue (bonuses to W budgets), hand-authored items, then builds as tests
- [ ] The Meridian Map's real shape and its content pass (every element land's linh-lực keystone); the side-tree tab for
      công pháp and items (`design/research/side-trees-thoughts.md`)
- [ ] Design the open world map (Travel & Map #25, with World Generation #27) and a real sect system (Sects & Missions #26,
      with sect tiers)
- [ ] Later: design NPC Traits (#42, System Briefs), after the world map and sects
- [ ] Reverse-document the 17 built MVP systems without a GDD (`/reverse-document`), Foundation first (1–5)
- [ ] Balance Harness: the calibration bot run on the new curves and the drawn map (Realms Open Question 23, Meridian
      AC-KMD-07, -50, -101), after the library is fuller
- [ ] Implement this week's design in code (Meridian map, curves, uncapped purity, combat, Effects, the Way)
- [ ] Update `design/gdd/game-concept.md` (Meridian Map, Progression Edges, Debug Terminal, the Way, combat)
- [ ] `/project-stage-detect`, then `/gate-check technical-setup` when the MVP systems are designed, then `/vertical-slice`
