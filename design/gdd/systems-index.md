# Systems Index: Ten Thousand Daos

> **Status**: Approved (system list, dependencies and priority tiers approved by the user, 2026-11-03)
> **Created**: 2026-11-03
> **Last Updated**: 2026-11-08 (#21a, #21b, #40 and #41 approved; the Combat revision #43 applied to combat.md with back-references in the older GDDs; next: a fresh /design-review of combat.md). Earlier: 2026-11-08 (#21a, #21b, #40 and #41 designed, pending review; next: four fresh-session design reviews, then the Combat revision #43. Earlier 2026-11-07: Modifier System added as #40, now in design and paused; Combat Defence & Healing #21a (in design) and Combat Damage Types #21b added as sub-systems of Combat; Effects System added as #41; Meridian Map redesign planned; build design order)
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
| 6 | Spiritual Roots (Linh Căn) (incl. changing spiritual roots) | Progression | MVP | In Review (2026-11-05: independent review applied; cross-GDD CONCERNS, no blockers) | design/gdd/linh-can.md | Config, Sim Core; soft: Realms (breakthrough event, stage group), Character Stats (capability set) |
| 7 | Character Stats (innate talent [thiên phú], derived, craft mastery [đạo nghệ]) | Progression | MVP | In Review (2026-11-05: independent review applied; cross-GDD CONCERNS, no blockers) | design/gdd/character-stats.md | Spiritual Roots, Sim Core, Config; soft (via the provider interface): Realms, Meridian Map, Cultivation Techniques, Item DB, Progression Edges, Formations, Spirit Herbs & Spirit Fields |
| 8 | Realms & Bottlenecks (Cảnh Giới & Bình Cảnh) | Progression | MVP | In Review (2026-11-05: independent review applied; cross-GDD CONCERNS, no blockers) | design/gdd/canh-gioi.md | Config, Sim Core, Time & Turn, Spiritual Roots, Character Stats, Item DB; soft: Cultivation Techniques, Spirit Herbs, Alchemy, Formations, Travel & Map, Event Engine, Progression Edges |
| 9 | Cultivation Techniques (Công Pháp) | Progression | MVP | In Review (2026-11-05: independent review applied; cross-GDD CONCERNS, no blockers) | design/gdd/cong-phap.md | Spiritual Roots, Realms, Character Stats, Item DB; soft: Time & Turn, Meridian Map |
| 10 | Meridian Map (Kinh Mạch Đồ) (added by request) | Progression | MVP | **Major revision applied 2026-11-10** (design review MAJOR REVISION NEEDED; rewritten section by section with the user): the map is the hand-drawn lean tree (7,115 acupoints, 11 starts, variant lands), roads grant purity, hidden clusters and variant sectors retired, capability text in effects.md, the tree's breakthrough share a curve. Needs a fresh /design-review; content pass and bot calibration open | design/gdd/kinh-mach-do.md | Spiritual Roots, Character Stats, Realms, Config, Sim Core; soft: Event Engine, Item DB, Cultivation Techniques, LLM GM, World DB, Edges |
| 11 | Progression Edges: destiny perk (thiên mệnh), fortuitous encounters (cơ duyên), NPC edges (added by request) | Progression | MVP | Implemented | quick spec: design/quick-specs/progression-and-edges.md | Character Stats, Realms, Event Engine (player half) |
| 12 | Codex & Karmic Carryover | Progression | Vertical Slice | Not Started | — | Item DB, Alchemy, Spiritual Roots, Save/Load |
| 13 | Item Database & Generation (inferred) | Economy | MVP | Approved (2026-11-06: lean /design-review re-review, 0 blockers, 9 recommended; see design/gdd/reviews/item-database-review-log.md; built, with the gaps listed in its Build Gaps section) | design/gdd/item-database.md | Config, Sim Core, World DB; soft: Character Stats (lifespan-cap preview) |
| 14 | Spirit Herbs & Spirit Fields (Linh Thảo & Linh Điền) | Economy | MVP | Implemented | — | Item DB, Character Stats, Time & Turn |
| 15 | Alchemy (Luyện Đan) | Economy | MVP | Implemented | — | Spirit Herbs, Item DB, Character Stats |
| 16 | Artifact Refining (Luyện Khí) | Economy | Vertical Slice | Implemented | quick spec: design/quick-specs/luyen-khi-and-tran-phap.md | Item DB, Character Stats |
| 17 | Formations (Trận Pháp) | Economy | Alpha | Implemented | quick spec: design/quick-specs/luyen-khi-and-tran-phap.md | Item DB, Character Stats, Time & Turn |
| 18 | Talismans (Phù Lục) | Economy | Alpha | Implemented | quick spec: design/quick-specs/phu-luc-linh-thu-thanh-tuu.md | Item DB, Character Stats |
| 19 | Spirit Beasts & Spirit Insects (Linh Thú & Linh Trùng) | Economy | Alpha | Implemented (spirit beasts only) | quick spec: design/quick-specs/phu-luc-linh-thu-thanh-tuu.md | World DB, Character Stats, Time & Turn |
| 20 | Market & Spirit Stone (Linh Thạch) Economy (inferred) | Economy | MVP | Implemented | — | Item DB, Character Stats, Realms, World Gen |
| 21 | Combat | Gameplay | MVP | **Revised 2026-11-08 by the Combat revision (#43)**, in session with the user (parts 1–5, commits 606e787..19c7c87): the defence path, wards, healing, damage types, modifier operations, statuses and the Down step now point to #21a, #21b, #40 and #41; 19 decisions D1–D19 and C1–C4 applied. **In Review**: awaiting a fresh /design-review. Earlier: Approved for rules, numbers provisional (design-review 2026-11-06 ninth pass, lean: no blockers, 8 recommended, items 1-5 applied in session; earlier history: fourth pass, lean: NEEDS REVISION, fixes applied; reworked the same day to a timeline of seconds with no rounds; fifth pass 2026-11-06, lean: NEEDS REVISION, 2 blockers fixed in session (follow-up instants, `ward_floor`), 8 recommended open, simulated numbers provisional, awaiting re-review; sixth pass 2026-11-06, lean: NEEDS REVISION, 1 blocker (guard timing) fixed in session, awaiting re-review; seventh pass 2026-11-06, lean: NEEDS REVISION, 2 blockers (ward pass clamp, defeat check timing) and 2 recommended fixed in session, awaiting re-review; eighth pass 2026-11-06, lean: NEEDS REVISION, 2 blockers (overkill basis wording, stale registry `ward_block`) and 5 recommended fixed in session, not re-reviewed, see design/gdd/reviews/combat-review-log.md; designed with one health bar, linh lực wards, body guard, soul attacks). **Build on hold** (user decision 2026-11-06) until items, techniques, abilities and passives exist; today's power duel stays in use until then | design/gdd/combat.md | Character Stats, Realms, Cultivation Techniques, Meridian Map, Artifact Refining, Formations, Talismans, Spirit Beasts |
| 21a | Combat Defence & Healing (Phòng Ngự & Trị Thương), a **sub-system of Combat (#21)** (added by request 2026-11-07): wards (hộ thể) and their records and cost models, resistance by damage type, block, shields (uncapped), evade, soul and status resistance, maximum health, and healing in a fight | Gameplay | MVP | **Designed** 2026-11-07, revised the same day for Combat Damage Types (resistance per damage type, block, body shields; body guard retired). **Needs Revision** (design-review 2026-11-08, lean, overnight, four passes: 2 blockers: the registry's `defence_shield` output range, and drain billing for non-resistance payloads and negative resistance; 9 recommendations; see `reviews/combat-defence-review-log.md`). **Revised 2026-11-08** with the user's answers (shields uncapped; drain billing completed). **Needs Revision** (re-review 2026-11-08, lean: both earlier blockers resolved; 4 new blockers: soul shield formula, where `ws`/`we` and `a_w`/`a_b` live, drain billing for shared block and a short pool, AC-CD-59's fixture; pass 2 the same day found no new blocker and the same 4 stand; pass 3 the same day adds a 5th: the price check's V for cast wards that carry resistance, block or evade). **Revised 2026-11-08** with the user's answers to all re-review items (soul shield share and bar; ws, we, a_w, a_b moved into Formulas A0; drain billing for shared block and a short pool; a Down refusal is not healing); next: fresh-session re-review. Combat needs a revision afterwards (#43) **Second re-review 2026-11-08b** (fresh session): NEEDS REVISION, 2 blockers (a stray cap on `a_w` in A0; the cast cost after `T_up`), 16 findings; all applied the same day with the user's CD-04 answer (drain on a linh lực tick kept, documented). **APPROVED 2026-11-08c** (third review, headless Sonnet; round-3 safe fixes applied; pass 1 approved, 4 more safe fixes; `reviews/rereview-2026-11-08c/`). | design/gdd/combat-defence.md | Combat (Formulas A, D, E, F, I; rules 11, 22), Character Stats, Modifier System (#40: defence and healing stats); read by: Effects System (#41: heal and lifesteal sources), Item DB, Artifact Refining, Cultivation Techniques, The Way |
| 21b | Combat Damage Types (Loại Sát Thương), a **sub-system of Combat (#21)** (added by request 2026-11-07): eight damage types (Physical, Force, Fire, Cold, Lightning, Light, Chaos, Soul), elements as art tags only, no element cycle in fights, conversion (at most 2 per hit, by step), and which defence each damage type meets | Gameplay | MVP | **Designed** 2026-11-07 (eight damage types, elements as art tags, no element cycle). **Needs Revision** (design-review 2026-11-08, lean, overnight, four passes: 2 blockers — hits that mix Soul with other types, and how same-step conversions share a part; 12 recommendations, 4 fixed as wording in pass 2; passes 3 and 4 found no cross-document conflict; see `reviews/combat-damage-types-review-log.md`). **Revised 2026-11-08** with the user's answers (no mixed Soul hits; same-step conversions read the step's start). **Needs Revision** (re-review 2026-11-08, lean: both earlier blockers resolved; 3 new blockers: order inside a conversion step, the modifier conversion tier against Modifier vs Effect, Qi Disruption's tick path; passes 2 and 3 the same day found no cross-document conflict and no new blocker). **Revised 2026-11-08** with the user's answers to all re-review items (conversion modifiers allowed as ordinary modifiers; qi ticks pass every shield; order inside a step; "Primordial Chaos" for the root); next: fresh-session re-review **Second re-review 2026-11-08b** (fresh session): NEEDS REVISION, 1 blocker (how conversion modifiers count), 14 findings; all applied the same day with the user's answers (one conversion per `convert_pct` key; slot order for unslotted hosts; whole-pp grid). **APPROVED 2026-11-08c** (third review, headless Sonnet; user decisions DT-01 host order and DT-04 per-part scaling applied; pass 1 approved, 4 more safe fixes; `reviews/rereview-2026-11-08c/`). | design/gdd/combat-damage-types.md | Combat (rules 4, 6, 7; Formulas C, F), Combat Defence & Healing (#21a: resistance by final damage type), Spiritual Roots (elements, variants), Modifier System (#40: damage and penetration stats); read by: Effects System (#41), The Way, Cultivation Techniques, Item DB |
| 22 | Heavenly Tribulation (Thiên Kiếp) | Gameplay | MVP | Approved for rules (2026-11-06, re-review after NEEDS REVISION fixes; numbers provisional until the Balance Harness measures p_t; three boss waves from a random pool; numbers are guesses; needs Combat starting shares; build on hold with the full fight) | design/gdd/thien-kiep.md | Combat, Realms, Event Engine |
| 23 | Event Engine: templates, budgets, validator, resolver | Gameplay | MVP | Implemented | — | World DB, Character Stats, Item DB, NPC Builds, Alchemy, Talismans, Spirit Beasts, Combat |
| 24 | NPC Build Generation (inferred) | Gameplay | MVP | Implemented | — | Character Stats, Cultivation Techniques, Meridian Map, Item DB, Edges (NPC half) |
| 25 | Travel & Map (inferred) | Gameplay | MVP | Implemented (thin: named regions and a graph of places). **An open world map is needed** (user decision 2026-11-06). See System Briefs: World Map | — | World Gen, Time & Turn |
| 26 | Sects & Missions (inferred) | Gameplay | MVP | Implemented (thin) | — | World Gen, Character Stats, Market |
| 27 | World Generation & History | Narrative | MVP | Implemented | — | World DB, NPC Builds, Item DB, Config, Sim Core |
| 28 | Living World Tick | Narrative | Vertical Slice | Implemented (abstract) | — | World DB, Realms, NPC Builds, Edges (NPC half), Time & Turn |
| 29 | LLM Game Master: events, narration, epitaph, provider config | Narrative | MVP | Implemented (mock-tested only) | — | Event Engine, World DB, Config |
| 30 | NPC Interaction & Dialogue | Narrative | Vertical Slice | Implemented (thin) | — | World DB, LLM GM, Time & Turn |
| 31 | Quests | Narrative | Vertical Slice | Approved (design-review 2026-11-08, lean, sixth pass: no blockers, 8 recommendations open; numbers are guesses; contracts with Event Engine, LLM GM and Dialogue provisional) | design/gdd/quests.md | Event Engine, LLM GM, Dialogue, World DB |
| 32 | Achievements (Thành Tựu) | Meta | Vertical Slice | Implemented | quick spec: design/quick-specs/phu-luc-linh-thu-thanh-tuu.md | Character Stats, Realms, World DB, Save/Load |
| 33 | Balance Simulation Harness | Meta | MVP | Implemented | — | Time & Turn, Character Stats, Realms, Event Engine, Market, Edges |
| 34 | Localization & Hán-Việt Glossary | Meta | Alpha | Not Started | — | LLM GM, Event Engine, Guidance, Game UI, Config |
| 35 | Guidance Layer: Advisor, change line, tutorial role (inferred) | UI | Vertical Slice | Implemented | — | Realms, Spirit Herbs, Alchemy, Event Engine, Market, Travel, Sects, Edges, Meridian Map |
| 36 | Debug Terminal (added by request) | UI | MVP | Implemented | docs/debug-terminal.md (run guide, not a GDD) | Guidance, Save/Load, LLM GM |
| 37 | Game UI: Godot, 2D ink-wash | UI | Vertical Slice | Not Started | — | Guidance, Save/Load |
| 38 | Audio | Audio | Full Vision | Not Started | — | Game UI, Event Engine |
| 39 | The Way (Đạo) (added by request; holds the mutations moved out of the root) | Progression | Alpha (provisional) | Approved (design-review 2026-11-06 fifth pass, lean: no blockers; 7 recommendations open). **Catalogue to be revisited** after the Modifier System (#40): Daos are broad Ways (Sinh Tử, Luân Hồi, Vụ, Huyễn, Trà, Kiếm, Hiếu, Phong Thủy, Thiên Vận, Kỹ and the like), each hosting many builds; the overnight Đạo trees are not adopted | design/gdd/dao.md | Spiritual Roots; contract provisional (Spiritual Roots Open Question 9); Meridian Map (shared skill points); Combat (arts only, on hold: needs a full combat system); soft: Cultivation Techniques (techniques naming relocated mutations, its Open Question 11), Realms (any ceiling raise or root factor re-runs the breakthrough calibration) |
| 40 | Modifier System (added by request 2026-11-07; the base every build piece draws from; plain numbers on a stat only, user decision 2026-11-07) | Gameplay | MVP | **Designed** 2026-11-07 (finished after #21a and #21b; Stat List and catalogue rebuilt for them). **Needs Revision** (design-review 2026-11-08, lean, overnight: 2 blockers — rule 8 defines no matching for the heal, reservation, outgoing-status and basic-attack targets the Stat List uses, and typed resistance's Stat List price double-counts breadth under Formulas C; 12 recommendations; passes 2, 3 and 4 the same day re-confirmed it; passes 3 and 4 found no cross-document conflict; see `reviews/modifiers-review-log.md`). **Revised 2026-11-08** with the user's answers (all five targets added; one stored resistance price; Chaos resistance rare). **Needs Revision** (fresh re-review 2026-11-08, lean: both earlier blockers resolved; 2 new blockers: type scopes on whole-hit and whole-art stats, and the resistance [type + family tag] row; 12 recommendations; pass 2 the same day found no new blocker and the same 2 stand, with 14 recommendations; pass 3 the same, with 16 recommendations). **Revised 2026-11-08** with the user's answers to all re-review items (whole-hit and whole-art type scopes; the [type + family] resistance row removed; `convert_pct` conversion modifiers added as an ordinary stat; catalogue 266); next: fresh-session re-review **Second re-review 2026-11-08b** (fresh session): **APPROVED**, 0 blockers, 16 recommendations and nits, all applied the same day with the user's answers (no damage-type scope on accuracy or pierce; lifespan rounding a known exception). Approved status stands after the round-3 changes in the other three GDDs (2026-11-08c). | design/gdd/modifiers.md | Combat (damage layers L1–L5 and their caps, channels, ward models), Character Stats; read by: Meridian Map, The Way (Đạo), Cultivation Techniques, Item DB, Artifact Refining, Formations, Talismans, Spirit Beasts |
| 41 | Effects System (added by request 2026-11-07): every build piece with a rule in it (conditions, scaling, triggers, conditional conversion, overflow, rule changes, keystones, enablers), each granting Modifier System modifiers as its payload | Gameplay | MVP | **Needs Revision** (designed 2026-11-08: hand-designed, unpriced; 16 statuses, 46 starter Effects. Design review 2026-11-08, lean, overnight, four passes: 2 blockers. The starter catalogue reads quantities missing from rule 5's readable list and uses actions missing from rule 6's action list; 12 recommendations; see `reviews/effects-review-log.md`). **Revised 2026-11-08** with the user's answers (3 reads and 9 actions added to the closed lists). **Daytime re-review 2026-11-08** (lean, three passes): still Needs Revision, 3 blockers (more starter reads and actions missing from the closed lists; the linh lực tick path), 21 recommendations; decisions in `reviews/rereview-2026-11-08-decisions.md` **Revised 2026-11-08** with the user's answers to all re-review items (more reads and actions; the qi-tick path; last acts resolve requesting side first and win only on overkill; status tags column); next: fresh-session re-review. **Second re-review 2026-11-08b** (fresh session): NEEDS REVISION, 3 blockers (three plain conversions are modifiers; closing-rule actions; AC-EF-50), 16 findings; all applied the same day with the user's answers (the three conversions moved to `convert_pct`, 43 starter Effects remain; last acts add to overkill; one 5 % qi burn pool). **APPROVED 2026-11-08c** (third review, headless Sonnet; safe fixes applied; user decision EF-05: stacked Chaos conversion accepted and watched in the balance pass; `reviews/rereview-2026-11-08c/effects.md`). | design/gdd/effects.md | Modifier System (#40), Combat (#21, #21a), Character Stats; read by: Meridian Map, The Way, Cultivation Techniques, Item DB, Formations, Talismans, Spirit Beasts |

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
| 40 | Combat Defence & Healing (#21a, sub-system of Combat; designed 2026-11-07, Needs Revision 2026-11-08) | MVP | Feature | game-designer, systems-designer | M |
| 40b | Combat Damage Types (#21b, sub-system of Combat; designed 2026-11-07, pending review) | MVP | Feature | game-designer, systems-designer | M |
| 41 | Modifier System (#40; designed 2026-11-07, Needs Revision 2026-11-08) | MVP | Feature | systems-designer | M |
| 42 | Effects System (#41; designed 2026-11-08, Needs Revision 2026-11-08) | MVP | Feature | game-designer, systems-designer | L |
| 43 | Combat revision (folds in #21a, #40, #41); then the Meridian Map redesign, the Đạo catalogue, Cultivation Techniques, items — **applied 2026-11-08** (combat.md parts 1–5; back-reference sweep in nine older GDDs) | MVP | Feature | systems-designer | M |
| 44 | Combat economy revision, **in progress** (decided 2026-11-09 in `design/research/economy-revision-44-decisions.md`; parts 1–5 applied 2026-11-09 to combat.md, combat-defence.md, effects.md, modifiers.md and character-stats.md (parts 4–5 provisional, applied overnight without draft approval); fresh design reviews pending; simulator `tools/design/combat_sim/`) (user direction 2026-11-08): resource sustain is a core build axis. Linh lực regeneration, gain, cost reduction, paying with health and health regeneration must have many sources, and sustain is king; all-in burst builds (spend the whole pool at once, win or be spent) stay possible but rare. Same-realm fights get longer (target 30–60 s, art cooldowns 0.5–12 s; fatigue damage can end stalls); short fights only across a realm gap. Opens mana-based công pháp (damage scaling on remaining linh lực, overflow linh lực into a shield or damage). Touches Combat (pools, costs, time), Combat Defence & Healing (recalibration), the Modifier System (gain stats) and the Effects System; element stacks (a buff and a debuff per element) were added 2026-11-09. Starting point: `design/research/sustain-audit-2026-11-08.md`. Before the Đạo and công pháp content | MVP | Feature | game-designer, systems-designer | L |

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

| Metric | Count |
|--------|-------|
| Total systems identified | 39 |
| Systems implemented (debug terminal) | 32, of which 6 carry caveats: 19 (beasts only), 21 (duel only), 26 (thin), 28 (abstract), 29 (mock-tested only), 30 (thin) |
| Systems not started | 6: 12, 22 (designed, not built), 31 (designed, not built), 34, 37, 38 (plus spirit insects [linh trùng], inside 19) |
| GDDs started | 14 (41 Effects System, designed 2026-11-08, pending review; 21b Combat Damage Types, designed 2026-11-07, pending review; 21a Combat Defence & Healing, designed 2026-11-07, pending review; 40 Modifier System, designed 2026-11-07, pending review; 31 Quests, designed 2026-11-06, pending review; 22 Heavenly Tribulation, approved for rules 2026-11-06; 13 Item Database and 21 Combat, since approved; 11 The Way [Đạo], approved 2026-11-06; 10 Meridian Map [Kinh Mạch Đồ] and 9 Cultivation Techniques [Công Pháp], reopened 2026-11-04 by the Spiritual Roots redesign; 7 Character Stats, in review after the cross-GDD review 04f revisions; 8 Realms & Bottlenecks [Cảnh Giới & Bình Cảnh], needs revision after the 2026-11-05 review, fixes applied; 6 Spiritual Roots [Linh Căn], redesigned 2026-11-04, pending review) |
| Quick specs covering systems | 4 (cover parts of 6, 8, 11, 16, 17, 18, 19, 32) |
| Design docs reviewed | 5, each independently on 2026-11-05 (reports in design/gdd/reviews/) |
| Design docs approved | 0; 6, 7, 8, 9 and 10 in review after the 2026-11-05 reviews, with a clean cross-GDD pass (CONCERNS, no blockers) |
| MVP systems designed | 8 / 25 |
| Vertical Slice systems designed | 1 / 8 |

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

## Next Steps

- [x] Review and approve this systems enumeration (2026-11-03)
- [ ] Reverse-document the MVP Foundation and Core systems in design order (`/reverse-document design src/gameplay/<area>`), starting with 1 to 3, then Spiritual Roots (Linh Căn), Character Stats and Realms & Bottlenecks (Cảnh Giới & Bình Cảnh)
- [ ] Run `/design-review` on each completed GDD (first: `design/gdd/kinh-mach-do.md`, in a fresh session)
- [x] Carry the level ladder (great and small breakthrough bonuses, stat rises at every breakthrough) from the Meridian Map (Kinh Mạch Đồ) GDD into the Realms & Bottlenecks GDD (done; the ladder is now 110 levels, 2026-11-05)
- [x] Design the unbuilt MVP system, Heavenly Tribulation (Thiên Kiếp), with `/design-system thien-kiep` (done 2026-11-06: design/gdd/thien-kiep.md, approved for rules)
- [ ] Add more items to the game, authored by hand rather than generated (user 2026-11-06; Item Database Open Question 10)
- [ ] Design a full combat system (Combat, #21): build-heavy, with very high scaling for the right build (System Briefs: Combat). The built duel is a power ratio and cannot host skills. The Way's arts, Heavenly Tribulation and any future active technique depend on it
- [ ] Design the open world map (Travel & Map #25, with World Generation #27): generated terrain, location stats, real distance, hidden places and clues (System Briefs: World Map)
- [x] Design the Way (Đạo) with `/design-system dao` (done 2026-11-05, approved 2026-11-06: design/gdd/dao.md; its catalogue of trees is a content pass, and its arts wait on a full combat system)
- [ ] Update `design/gdd/game-concept.md` to include the Meridian Map, Progression Edges and the Debug Terminal
- [ ] Reconcile `project.yaml` stage with `/project-stage-detect`
- [ ] Run `/gate-check technical-setup` when the MVP systems are designed
- [ ] Validate the highest-risk systems with `/vertical-slice` before committing to Production
