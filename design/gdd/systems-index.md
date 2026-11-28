# Systems Index: Ten Thousand Daos

> **Status**: Approved (system list, dependencies and priority tiers approved by the user, 2026-11-03)
> **Created**: 2026-11-03
> **Last Updated**: 2026-11-28 (synced system statuses, Overview, Progress Tracker, and Next Steps to shipped state — commits `3941106f`, `31cd736e`, `84bc1692`: World Depth Stages 0–11, Combat/Effects/Damage Types + Darkness `am` stacks, Đạo Đồ v5 + `DaoDoScreen`, Fixed Continent & 705 Provinces, Sects + war-weariness retune, Economy/Trade/Abode, Traits v2, Relationships, Interaction `#30`, Event Engine `#23`, Quests `#31`, Tribulation `#22`, Codex `#12`, Power Rankings `#44` [Track 1 post-Đạo-Đồ calibration & 1,769-entry offline cast precompute complete], Godot HUD & illustrated windows). Earlier: 2026-11-12 (library counts in the Progress Tracker; Game UI groundwork; Next Steps: item catalogue next); 2026-11-10 (refresh: combat GDDs approved; progression GDDs revised); 2026-11-08 (#21a, #21b, #40, #41 approved).
> **Source Concept**: design/gdd/game-concept.md

---

## Overview

Ten Thousand Daos is a roguelite cultivation game: one life of 60–120 minutes, an authored fixed
continent with centuries of recorded history (per-life rolls for ordinary cultivators, hidden spots,
secrets and reserves), and a build the player constructs rather than picks (Pillar 3, Power Is Built,
Not Given). Its mechanical scope is four interlocking layers. A **character layer** (spiritual roots
[linh căn], innate talent [thiên phú], realms [cảnh giới], cultivation techniques [công pháp], the
Đạo Đồ, destiny perk [thiên mệnh] edges, Codex & karmic carryover) decides how fast and how safely a
life advances. An **economy layer** (provinces, cave abodes, spirit herbs [linh thảo] that age,
alchemy [luyện đan], artifact refining [luyện khí], formations [trận pháp], talismans [phù lục],
spirit beasts [linh thú], regional markets & trade goods, spirit stones [linh thạch]) turns time and
spiritual root affinity into assets (Pillar 4, Every Season Counts). A **world layer** (authored
world history with 50 active / 11 fallen sects and 1,909 named people, seasonal living-world tick,
NPC traits v2 & sparse relationships, NPC builds and fight-based Power Rankings under the player's
own rules) gives every life a living society (Pillar 5, A World That Remembers). A **bounded story
layer** (deterministic Event Engine chains/stories/hooks, template quests, CK-style trait-driven NPC
interaction & dialogue; LLM Game Master parked 2026-11-15 so the game plays completely offline)
delivers emergent stories inside visible budgets (Pillar 2, Every Number Is Bounded and Visible).
Presentation ships as a Godot 2D map-centric HUD with carved-hardwood & brass illustrated windows and
a PoE-style `DaoDoScreen`, alongside the debug terminal.

**Where the project actually is (2026-11-28).** 45 of the 50 catalogued systems (48 numbered plus
`#21a` and `#21b`) are implemented in Godot (`src/gameplay/`, `src/core/`, `src/ui/`,
`src/debug_terminal/`; 169 GdUnit4 test processes (1,486 test cases) plus Python combat/world/lint/parity suites), with 32
GDD files in `design/gdd/` (31 system GDDs plus `npc-traits-catalogue.md`). LLM GM (`#29`) is parked
with mock-tested fallback code; only Localization (`#34`), Audio (`#38`), The Way (`#39`), and spirit
insects inside `#19` remain unbuilt, while Power Rankings (`#44`) Track 1 is complete (`31cd736e`:
post-Đạo-Đồ reference fighters, `k_max = 256` calibration with 0 saturation / 0 Hóa Thần & 0 Nguyên Anh
clipping, and offline `cast_ratings.json` precompute of 1,748 living cast + 21 beasts = 1,769 entries).
Built systems lacking a full GDD remain tracked for `/reverse-document` before the single holistic
`/review-all-gdds` pass.

**Priority tiers follow the concept's milestones** (MVP, Vertical Slice, Alpha, Full Vision).
A built system keeps its later tier: the tier says when the system ships in the product plan,
the Status column says whether it exists.

> **Review gates**: TD-SYSTEM-BOUNDARY, PR-SCOPE and CD-SYSTEMS were skipped (Lean review mode).

---

## Systems Enumeration

Short names used in "Depends On": Config, Sim Core, World DB, Time & Turn, Save/Load,
Spiritual Roots (Linh Căn), Character Stats, Realms (Cảnh Giới), Cultivation Techniques (Công Pháp),
Đạo Đồ, Edges, Codex, Item DB, Spirit Herbs (Linh Thảo), Alchemy (Luyện Đan),
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
| 6 | Spiritual Roots (Linh Căn) (incl. changing spiritual roots) | Progression | MVP | **Implemented** (float uncapped purity, variant roots, province land roll Formulas A2/D4 & sect admission F20/F21, commit `c75beac2`). GDD In Review (2026-11-10 fixes applied; amended 2026-11-25 for world-depth R1 land roll; covered in final `/review-all-gdds` pass). | design/gdd/linh-can.md | Config, Sim Core; soft: Realms (breakthrough event, stage group), Character Stats (capability set) |
| 7 | Character Stats (innate talent [thiên phú], derived, craft mastery [đạo nghệ]) | Progression | MVP | **Implemented** (`StatSheet` bonus curves, Traits v2 integration, C3 shifted talent grades in `CharacterWindow`, commit `c5e2ecec`). GDD In Review (2026-11-10 fixes applied; AC-CS-56 reconciled 2026-11-28 for live v5 Đạo Đồ lifespan lines). | design/gdd/character-stats.md | Spiritual Roots, Sim Core, Config; soft (via the provider interface): Realms, Đạo Đồ, Cultivation Techniques, Item DB, Progression Edges, Formations, Spirit Herbs & Spirit Fields |
| 8 | Realms & Bottlenecks (Cảnh Giới & Bình Cảnh) | Progression | MVP | **Implemented** (110-level ladder, Đạo Đồ breakthrough curve, heavenly suppression, gate calibration measured in v5 loader 2026-11-20 & Stage 11B 2026-11-28 — on target, no retune needed). GDD In Review (2026-11-10 fixes applied; amended 2026-11-25 `world_cultivators_min` 5,000; AC-CG-19/-25/-68 & OQ 23 reconciled 2026-11-28). | design/gdd/canh-gioi.md | Config, Sim Core, Time & Turn, Spiritual Roots, Character Stats, Item DB; soft: Cultivation Techniques, Spirit Herbs, Alchemy, Formations, Travel & Map, Event Engine, Progression Edges |
| 9 | Cultivation Techniques (Công Pháp) | Progression | MVP | **Implemented** (`items_cong_phap.json`: 247 techniques carrying 428 signature arts, layers/mastery/slots/harmony). GDD In Review (2026-11-10 fixes applied). | design/gdd/cong-phap.md | Spiritual Roots, Realms, Character Stats, Item DB; soft: Time & Turn, Đạo Đồ |
| 10 | Đạo Đồ (added by request) | Progression | MVP | **Implemented** (frozen v5 map `assets/data/dao_do_map.json` via `DaoDoTree.load_map()`, ADR-0004: 8,051 nodes / 7,289 Dao marks / 11 starts / 43 keystones / 55 tree Effects across Python + GDScript, float road purity, Chaos gate, breakthrough curve, optimized NPC allocator, save migration, PoE-style `DaoDoScreen` UI; old generator retired; user content review & 4 out-of-fight Effects open). GDD In Review (Known gaps & AC-KMD-60 synced 2026-11-28). | design/gdd/dao-do.md | Spiritual Roots, Character Stats, Realms, Config, Sim Core; soft: Event Engine, Item DB, Cultivation Techniques, World DB, Edges |
| 11 | Progression Edges: destiny perk (thiên mệnh), fortuitous encounters (cơ duyên), NPC edges (added by request) | Progression | MVP | Implemented | quick spec: design/quick-specs/progression-and-edges.md | Character Stats, Realms, Event Engine (player half) |
| 12 | Codex & Karmic Carryover | Progression | Vertical Slice | **Implemented** (commit `5804f812`: One Life & Continue modes, profile Codex, karma, heir/rebirth succession, `CodexWindow` & `SuccessionScreen`); GDD **Approved** 2026-11-21 (round 2 lean APPROVED). | design/gdd/codex-karmic-carryover.md | Item DB, Alchemy, Spiritual Roots, Save/Load |
| 13 | Item Database & Generation (inferred) | Economy | MVP | **Implemented** (`items_named.json` 661 items / 516 unique, `items_sets.json` 166 sets, set bonuses on `StatSheet`). GDD In Review (2026-11-10 fixes applied; amended 2026-11-25 for signature items & sets, rules 20f–22, Formulas J). | design/gdd/item-database.md | Config, Sim Core, World DB; soft: Character Stats (lifespan-cap preview) |
| 14 | Spirit Herbs & Spirit Fields (Linh Thảo & Linh Điền) | Economy | MVP | **Implemented** (herb aging, home garden & Linh Điền plots, herb element rework); GDD **Approved** 2026-11-21 (lean round 5). | design/gdd/spirit-herbs.md | Item DB, Character Stats, Time & Turn, Travel & Map, Trade Goods, Cave Abode |
| 15 | Alchemy (Luyện Đan) | Economy | MVP | **Implemented** (element-value recipes, Formula B equivalents, `p_brew` dampener, crafting fuel sink); GDD **Designed** 2026-11-21 (pending final review pass). | design/gdd/alchemy.md | Spirit Herbs, Item DB, Character Stats, Realms, Trade Goods |
| 16 | Artifact Refining (Luyện Khí) | Economy | Vertical Slice | Implemented | quick spec: design/quick-specs/luyen-khi-and-tran-phap.md | Item DB, Character Stats |
| 17 | Formations (Trận Pháp) | Economy | Alpha | **Implemented** (50 combat formation diagrams in `diagrams.gd`, Combat tab editor, B2 fight screen, `diagram_always` Track 2 W1-C (commit `3941106f`), plus home/world arrays; NPC combat diagrams off); GDD **Approved** 2026-11-21 (lean round 6). | design/gdd/formations.md (built record: design/quick-specs/luyen-khi-and-tran-phap.md) | Item DB, Character Stats, Time & Turn, Combat, Combat Defence & Healing, Modifier System, Effects System, Regional Economy & Trade |
| 18 | Talismans (Phù Lục) | Economy | Alpha | Implemented | quick spec: design/quick-specs/phu-luc-linh-thu-thanh-tuu.md | Item DB, Character Stats |
| 19 | Spirit Beasts & Spirit Insects (Linh Thú & Linh Trùng) | Economy | Alpha | Implemented (spirit beasts only; 21 authored beasts in `world_history.json`, `PlaceholderArt` portraits until painted; spirit insects unbuilt) | quick spec: design/quick-specs/phu-luc-linh-thu-thanh-tuu.md | World DB, Character Stats, Time & Turn |
| 20 | Market & Spirit Stone (Linh Thạch) Economy (inferred) | Economy | MVP | Implemented | — | Item DB, Character Stats, Realms, World Gen |
| 21 | Combat | Gameplay | MVP | **Implemented** in both Python (`tools/design/combat_sim/engine.py`) and Godot (`src/gameplay/combat/fight/`; full parity across exact + chancy fixtures including `t34_curse_reflect_exact` & `t35_darkness_erosion_exact`, real-fight `save_fight_meters` writeback, commit `3941106f`, B2 fight screen; 31 multi-fighter/ally records parked); GDD **Approved** 2026-11-10 (amended 2026-11-25 for duel readings & no environment conditions). | design/gdd/combat.md | Character Stats, Realms, Cultivation Techniques, Đạo Đồ, Artifact Refining, Formations, Talismans, Spirit Beasts |
| 21a | Combat Defence & Healing (Phòng Ngự & Trị Thương), a **sub-system of Combat (#21)** (added by request 2026-11-07): wards (hộ thể) and their records and cost models, resistance by damage type, block, shields (uncapped), evade, soul and status resistance, maximum health, and healing in a fight | Gameplay | MVP | **Implemented** (`src/gameplay/combat/fight/defence_path.gd`, full parity with Python engine); GDD **Approved** 2026-11-10. | design/gdd/combat-defence.md | Combat (Formulas A, D, E, F, I; rules 11, 22), Character Stats, Modifier System (#40: defence and healing stats); read by: Effects System (#41: heal and lifesteal sources), Item DB, Artifact Refining, Cultivation Techniques, The Way |
| 21b | Combat Damage Types (Loại Sát Thương), a **sub-system of Combat (#21)** (added by request 2026-11-07): eight damage types (Physical, Force, Fire, Cold, Lightning, Light, Chaos, Soul), elements as art tags only, no element cycle in fights, conversion (at most 2 per hit, by step), and which defence each damage type meets | Gameplay | MVP | **Implemented** (all 8 damage types, conversion, element tags; Darkness `am` stacks + 9 `attack_pct [am]` lines landed 2026-11-28 (commit `3941106f`), `combat-damage-types.md` synced); GDD **Approved** 2026-11-10. | design/gdd/combat-damage-types.md | Combat (rules 4, 6, 7; Formulas C, F), Combat Defence & Healing (#21a: resistance by final damage type), Spiritual Roots (elements, variants), Modifier System (#40: damage and penetration stats); read by: Effects System (#41), The Way, Cultivation Techniques, Item DB |
| 22 | Heavenly Tribulation (Thiên Kiếp) | Gameplay | MVP | **Implemented** (commit `5804f812` + Track 2 W1-B (`3941106f`): `TribulationRunner`, `TribulationScreen`, `tribulation_rules.json` default-on playthrough toggle in `GameMenu`, real-fight meter writeback); GDD **Approved** for rules (2026-11-06; #44 pass 2026-11-10). | design/gdd/thien-kiep.md | Combat, Realms, Event Engine |
| 23 | Event Engine: templates, budgets, validator, resolver; flags, follow-ups, stories, hooks, NPC events | Gameplay | MVP | **Implemented** (commit `facc5a41`: full Paradox-style chains, stories, flags, hooks, NPC events, shared budgets, real-fight meter writeback); GDD **Designed** 2026-11-15 (pending final review pass). | design/gdd/event-engine.md | World DB, Time & Turn, Character Stats, Realms, Item DB, NPC Builds, Combat, NPC Traits, Regional Economy & Trade; soft: Travel & Map, Sects, World Gen, Power Rankings, Progression Edges, Alchemy, Talismans, Spirit Beasts |
| 24 | NPC Build Generation (inferred) | Gameplay | MVP | Implemented (v5 Đạo Đồ allocator, cast builds & generated NPCs) | — | Character Stats, Cultivation Techniques, Đạo Đồ, Item DB, Edges (NPC half) |
| 25 | Travel & Map (with the geography half of #27) | Gameplay | MVP | **Implemented** (fixed continent `world_continent.json`, 705 provinces with land qi & biomes, painted far paper + near diorama relief map, travel, clues, secrets, resource sites, `MapScreen` / `ProvinceWindow`); GDD **Designed** 2026-11-10 / revised 2026-11-13 (pending final review pass). | design/gdd/travel-map.md | World Gen & History, Map build (tool), World DB, Time & Turn, Spiritual Roots, Character Stats |
| 26 | Sects & Missions | Gameplay | MVP | **Implemented** (50 active + 11 fallen sects, seats & founder arrays, lineages, admission F20/F21, 4 development tracks, 5 policy dials, missions, war-weariness retune Track 2 W1-A (`3941106f`, 2026-11-28), `SectWindow`); GDD **Approved** 2026-11-14 (amended 2026-11-25 for world-depth seats, lineages, admission, 11 no-lean sects, titles). | design/gdd/sects.md | World Gen, Travel & Map, Character Stats, Realms, Time & Turn, Living World Tick; soft: NPC Traits, Regional Economy & Trade, Event Engine, Market |
| 27 | World Generation & History | Narrative | MVP | **Implemented** (World Depth Stage 8 `bfc48f75` + Stage 9 `c75beac2`: `world_history.json` with 56 depth owners [50 sects + 6 outside groups], 1,909 authored people [1,748 living + 161 dead], 965 events, 2,054 ties, 21 beasts, `world_data_version: 1`; `N >= 5,000` fill with land-roll births & sect admission); GDD **Designed** 2026-11-15 (amended 2026-11-25 for world-depth cast & seats; pending final review pass). | design/gdd/world-generation.md | World DB, NPC Builds, Item DB, Config, Sim Core |
| 28 | Living World Tick | Narrative | Vertical Slice | **Implemented** (full S1–S10 seasonal tick: economy, sects & wars, ties S8b, NPC events, loans, land-roll births, succession); GDD **Designed** 2026-11-15 (pending final review pass). | design/gdd/living-world-tick.md | World DB, Realms, NPC Builds, Edges (NPC half), Time & Turn |
| 29 | LLM Game Master: events, narration, epitaph, provider config | Narrative | MVP | **Parked** 2026-11-15 (user decision): the game plays completely without an LLM; authored Event Engine (#23), Quests (#31), Interaction (#30) and templates carry narrative, and player-facing text is Vietnamese. Built mock-tested code stays dormant. | — | Event Engine, World DB, Config |
| 30 | NPC Interaction & Dialogue | Narrative | Vertical Slice | **Implemented** (commit `86fac3cd`: 17 base verbs + 19 trait `verb:` hooks, Formula A acceptance breakdown, focus tax, loans/ties/spar/`on_talk`, live `CharacterWindow` `Interact` tab); GDD **Designed** 2026-11-15 (pending final review pass). | design/gdd/npc-interaction-dialogue.md | World DB, NPC Traits, Character Stats, Event Engine, Time & Turn; soft: Quests, Sects, Market, Regional Economy & Trade, Combat, Power Rankings, Travel & Map, Công Pháp |
| 31 | Quests | Narrative | Vertical Slice | **Implemented** (commit `facc5a41`: authored template quests running as Event Engine stories, `QuestsWindow`, lasting Major/Legendary quest boons); GDD **Approved** 2026-11-08 (revised 2026-11-15 for no-LLM templates; pending final review pass). | design/gdd/quests.md | Event Engine, Dialogue, World DB; LLM GM parked |
| 32 | Achievements (Thành Tựu) | Meta | Vertical Slice | Implemented | quick spec: design/quick-specs/phu-luc-linh-thu-thanh-tuu.md | Character Stats, Realms, World DB, Save/Load |
| 33 | Balance Simulation Harness | Meta | MVP | Implemented (`tools/balance/`: `autoplay.gd`, `npc_cohort.gd`, `world_census.gd`, parallel runs) | — | Time & Turn, Character Stats, Realms, Event Engine, Market, Edges |
| 34 | Localization & Hán-Việt Glossary | Meta | Alpha | Not Started | — | Event Engine, Guidance, Game UI, Config |
| 35 | Guidance Layer: Advisor, change line, tutorial role (inferred) | UI | Vertical Slice | Implemented | — | Realms, Spirit Herbs, Alchemy, Event Engine, Market, Travel, Sects, Edges, Đạo Đồ |
| 36 | Debug Terminal (added by request) | UI | MVP | Implemented | docs/debug-terminal.md (run guide, not a GDD) | Guidance, Save/Load |
| 37 | Game UI: Godot 2D map-centric HUD & illustrated carved-hardwood/brass windows | UI | Vertical Slice | **Implemented** (map-centric HUD over painted far paper + near relief continent, `UiScale`, `WindowHost` / `FullScreenHost`, illustrated `CharacterWindow`, `SectWindow`, `ProvinceWindow`, `InventoryWindow`, `QuestsWindow`, `RankingsWindow`, `RelationshipsWindow`, `NewsWindow`, `CodexWindow`, `WikiWindow`, `GameMenu`, plus full-screen `DaoDoScreen`, `AbodeScreen`, `TribulationScreen`, `SuccessionScreen`, B2 fight screen; 1,909 cast portraits installed; 21 beast portraits & 80 v2 trait medallions show `PlaceholderArt` until painted). | UX specs in `design/ux/` | Guidance, Save/Load |
| 38 | Audio | Audio | Full Vision | Not Started | — | Game UI, Event Engine |
| 39 | The Way (Đạo) (added by request; holds the mutations moved out of the root) | Progression | Alpha (provisional) | In Review: graph Ways, 94-Way Catalogue (short Hán-Việt names with poetic titles), Sword pilot drawn; 2026-11-10 review fixes applied. **Not built.** | design/gdd/dao.md | Spiritual Roots; Đạo Đồ (shared skill points); Combat (arts only); soft: Cultivation Techniques, Realms |
| 40 | Modifier System (added by request 2026-11-07; the base every build piece draws from; plain numbers on a stat only, user decision 2026-11-07) | Gameplay | MVP | **Implemented** (`StatSheet`, `assets/data/combat_engine.json`, `FighterCompiler`, full parity); GDD **Approved** 2026-11-08b / 2026-11-10. | design/gdd/modifiers.md | Combat (damage layers L1–L5 and their caps, channels, ward models), Character Stats; read by: Đạo Đồ, The Way (Đạo), Cultivation Techniques, Item DB, Artifact Refining, Formations, Talismans, Spirit Beasts |
| 41 | Effects System (added by request 2026-11-07): every build piece with a rule in it (conditions, scaling, triggers, conditional conversion, overflow, rule changes, keystones, enablers), each granting Modifier System modifiers as its payload | Gameplay | MVP | **Implemented** (`effect_runner.gd` & `engine.py`, `combat_effects.json`, 55 Đạo Đồ Effects, 363 world-depth Effects, `curse_reflect` [`A Fair Copy`] & Darkness `Shadow Veil`/`Shadow Erosion` stacks + `The Banner Is Raised` landed 2026-11-28 (commit `3941106f`), `effects.md` synced; 4 out-of-fight tree Effects Pending); GDD **Approved** 2026-11-08c / 2026-11-10 (amended 2026-11-25 for duel vocabulary, no environment conditions, no caps inside pieces). | design/gdd/effects.md | Modifier System (#40), Combat (#21, #21a), Character Stats; read by: Đạo Đồ, The Way, Cultivation Techniques, Item DB, Formations, Talismans, Spirit Beasts |
| 42 | NPC Traits (added by request 2026-11-10; personality traits in the manner of grand-strategy character games) | Narrative | Alpha (provisional; later) | **Implemented** (Stage 10 `c5e2ecec`: `traits.json` 151 traits [71 v1 + 80 v2 across 10 kinds], `NpcTraits` runtime, 4 `policy_hooks`, 19 `verb_hooks`, C3 shifted talent grades in `CharacterWindow`; 80 v2 medallions render `PlaceholderArt` until painted); GDD & Catalogue **Approved** 2026-11-14 (amended 2026-11-25 for traits v2). | design/gdd/npc-traits.md, design/gdd/npc-traits-catalogue.md | NPC Builds, Living World Tick, Event Engine, Character Stats, Modifier System, NPC Interaction & Dialogue |
| 43 | Regional Economy & Trade (added by request 2026-11-10; split out of Travel & Map) | Economy | MVP (provisional) | **Implemented** (regional markets, supply/demand prices, trade flows, Formula H conservation via `MoneyLedger`, stone absorption, provisioned factor); GDD **Approved** 2026-11-23 (lean round 6 after Provinces #48 amendment). | design/gdd/regional-economy-trade.md | Travel & Map, Market, Item DB, Time & Turn, Sects & Missions, Provinces |
| 44 | Power Rankings (added by request 2026-11-14): fight-based power ratings (Elo-style, ladder panels, seasonal matchmaking and round robins); the one power number replacing chiến lực and `display_power`; NPC-against-NPC world fights decided from ratings | Gameplay | MVP | **Implemented** (`RatingService`, `RankingsWindow`, `combat_rankings.json` calibrated at `k_max = 256` in Stage 11 `408fc35a`; **Track 1 complete (commit `31cd736e`)**: post-Đạo-Đồ `POST_DAO_DO_TYPICAL` `combat_reference_fighters.json` & `t6` mirrors, `combat_rankings.json` recalibrated (`data_version 6c829cf0107774f4`, `k_max = 256`, 0 saturation errors, 0/2 Hóa Thần & 0/27 Nguyên Anh clipping), offline `export_cast_ratings.gd` -> `assets/data/cast_ratings.json` (1,748 cast + 21 beasts = 1,769 precomputed entries), `RatingService` digest validation & Rule 16 fallback, `power-rankings.md` (Core Rule 16a, AC-PR-58/59) & `docs/data-schemas.md` synced); GDD **Approved** 2026-11-14, ADR-0003 accepted. | design/gdd/power-rankings.md | Combat, Combat Defence & Healing, Realms, Character Stats, Cultivation Techniques, Item DB, Đạo Đồ, NPC Build Generation, Living World Tick, Save/Load; soft: Event Engine, Sects & Missions, Game UI, Debug Terminal |
| 45 | Trade Goods (added by request 2026-11-14): the goods that are traded, as items | Economy | MVP | **Implemented** (23 named raw goods in 8 classes, regional specialties, crafted-good pricing & craft plans); GDD **Approved** 2026-11-15 (lean round 12). | design/gdd/trade-goods.md | Regional Economy & Trade (#43), Item Database, Travel & Map (#25), Market (#20); soft: Sects & Missions (#26), Alchemy, Artifact Refining |
| 46 | NPC Relationships (added by request 2026-11-15): lasting bonds and grudges between people, NPC to NPC and NPC to player | Narrative | Alpha (provisional) | **Implemented** (`Ties`, S8b `TieTick`, families/births, blood feuds, debts, build hooks, `RelationshipsWindow`); GDD **Approved** 2026-11-21 (lean round 11). | design/gdd/npc-relationships.md | NPC Traits (#42), Living World Tick, NPC Interaction & Dialogue, Sects & Missions, World DB, Save/Load |
| 47 | Cave Abode & Home Works (Động Phủ) (added by request 2026-11-21; split from Travel & Map by the user) | Economy | Alpha (provisional) | **Implemented** (`CaveAbode`, `AbodeScreen`, grade 1–5 work slots, Tụ Linh home array, NPC aggregate); GDD **Approved** 2026-11-21 (lean round 5). | design/gdd/cave-abode.md | Travel & Map, Formations, Regional Economy & Trade, Sects & Missions, Realms, Item DB, Character Stats |
| 48 | Provinces (Tỉnh / Châu) (added by request 2026-11-23): fixed continent provinces as the economy's unit (705 provinces in `world_continent.json` with land qi, mortal population, production, buildings, market access) | Economy | MVP | **Implemented** (`world_continent.json`, province buildings, market access, land qi & `variant_max`, `ProvinceWindow`); GDD **Approved** 2026-11-23 (lean round 7; amended 2026-11-25 for land-roll births & Phượng Minh's seat). | design/gdd/provinces.md | Travel & Map, Sects & Missions, Living World Tick, World DB, Item DB, Modifiers, Effects |

**Build design order (user decision 2026-11-07).** Builds are the game: a concept with modifiers stacked on it, sometimes opened by an enabler. Content is designed from the shared pieces up, and builds come last as tests. **Before step 1 is finished (user decision 2026-11-07):** Combat Defence & Healing (#21a) and Combat Damage Types (#21b) are designed first as sub-systems of Combat (files prefixed `combat-`, flat in `design/gdd/` for now. **User decision 2026-11-07:** the combat GDDs move into `design/gdd/combat/` later, once more combat docs exist. Before the move, the skills and hooks that read `design/gdd/*.md` without subfolders (about 28 sites) must be made to read subfolders, and the 46 files that cite `combat.md` updated, so no review silently skips a combat GDD), then the Modifier System is resumed, then the Effects System (#41), then one Combat revision that folds in #21a and the Modifier and Effects contracts. The steps: (1) the Modifier System (#40), the shared vocabulary of modifiers by layer and channel; (2) The Way (Đạo) as broad Ways, each with three branches drawn mostly from that vocabulary; (3) Cultivation Techniques (Công Pháp); (4) items and enablers; (5) builds, which check that a fantasy can be made from existing pieces and add a new piece only when a second build would use it too. The overnight build campaign of 2026-11-07 (`design/builds/overnight-2026-11-07/`, 69 builds) went builds-first: its builds and content are **proposals to be re-evaluated and filtered** against the new pieces, not adopted content. Its rule findings (`decisions.md`) stand on their own.

**Implementation note (2026-11-05).** Systems 6-10 are now built in the debug terminal from their GDDs (uncommitted on feature/debug-terminal). The Đạo Đồ GDD was revised to match by rule 21 (generic roads, smaller clusters, border gap clusters, region capacity, drawing rules), so it is back In Review. Results: `production/qa/evidence/balance/2026-11-05-gdd-bot-run.txt`.

**In Review (2026-11-04). The sixth cross-GDD pass, `reviews/cross-gdd/gdd-cross-review-2026-11-04f.md`, gave FAIL with 3 blockers; all three were revised the same day with user decisions (discrete brews, best plot play, the odds lever, one talisman per realm step, ceilings 10 / 3 / 15 %, mutation herb growth under the ceiling). Each revised GDD awaits a /design-review re-review, then a /review-all-gdds re-run. The seventh pass, `gdd-cross-review-2026-11-04g.md`, gave FAIL with 3 mechanical blockers (registry `breakthrough_guard` and `lifespan_cap`, h = 0 in Realms Formulas D) and design warnings F2, F11, F13-F16 and C5 awaiting user rulings.**
- 6 Spiritual Roots: In Review. Independent review 2026-11-05 found 1 blocker (sector "spendable" against the Đạo Đồ frontier rule), fixed, with the plain-error items; a third review's 1 was also fixed. A second review found 2 more, also fixed. Left open: what Void's `co_duyen_pct` does (deferred by the user). The earlier lean /design-review of 2026-11-04 on the redesign (five elements + eight variant roots; the 22 old mutations moved to the Way) found no blocking items and 8 recommended revisions (4 applied). Open: Đạo Đồ variant sectors (its Open Question 15), Wind and Void weights (guess), the Way (undesigned).
- 7 Character Stats: In Review after the 2026-11-05 review (7 blockers, fixed). Earlier: Fourth lean review (2026-11-04) NEEDS REVISION, revised: AC-CS-28, penalties apply after the cap, rule 12 / 14 source lists (nine kinds), craft mastery AC and Dependencies row, Formulas G rows.
- 8 Realms & Bottlenecks: In Review. Independent review 2026-11-05 found 6 blockers, fixed, with the plain-error items; a third review's 5 were also fixed. After it, the user set NPC odds of 1 in 8 / 12 / 15 / 20 and a world of 5,000 cultivators (never fewer than 3,000; 2026-11-25: floor 5,000, World Generation Open Question 8). A second review found 5 more, also fixed. Earlier: Needs Revision per 04g (its h = 0 blocker is fixed). Revised after 04g with user rulings: CF/NS recipes 4x60+10 / 4x100+80, pill_chance 0.04 / 0.045 / 0.02 / 0.0225, failure insight (+2 pp per failed attempt, cap 4), q-extras ceiling 10 pp, root factors and holder raises outside the target, Advisor plant plan; means 0.30 at every gate, ceiling run 0.44-0.46 accepted within AC-CG-60. Cross-GDD review 04h (FAIL: C1 insight-cap knob limit, F20 alchemy_yield scope) closed the balancing passes by user direction: macro targets hold, slightly overpowered builds are acceptable.
- 9 Cultivation Techniques: In Review after the 2026-11-05 review (7 blockers, fixed). Built, including layers, mastery, slots and harmony; unbuilt display items are in its Open Question 8.
- 10 Đạo Đồ: In Review after the 2026-11-05 review (10 blockers, fixed); built gaps are in its Known gaps table. Earlier: Cleanup 2026-11-04: Formulas E2 guard handles a talisman on a #22 attempt (user decision). 04f warnings: F7 (linear W prices for a step growth payoff) and I1 (host labels).

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
- Systems 10 (Đạo Đồ) and 11 (Progression Edges) are MVP because the user required them
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
3. **Đạo Đồ** — Spiritual Roots, Character Stats, Realms.
4. **Artifact Refining (Luyện Khí) / Formations (Trận Pháp) / Talismans (Phù Lục) / Spirit Beasts (Linh Thú)** — each on Item DB (Spirit Beasts on World DB) and Character Stats; each exposes a combat contribution and nothing back.
5. **NPC Build Generation** — Character Stats, Cultivation Techniques, Đạo Đồ, Item DB, Edges (NPC half).
6. **World Generation & History** — World DB, NPC Builds, Item DB, Config, Sim Core.
7. **Travel & Map, Market & Spirit Stone (Linh Thạch) Economy, Sects & Missions** — World Gen plus Character Stats, Realms, Time & Turn.
8. **Combat** — Character Stats, Realms, Cultivation Techniques, Đạo Đồ, and the four asset systems (read-only).
9. **Event Engine** — World DB, Character Stats, Item DB, NPC Builds, Alchemy, Talismans, Spirit Beasts, Combat. *Bottleneck.*
10. **Progression Edges** — Character Stats, Realms, Event Engine (player half: fortuitous encounters [cơ duyên]).
11. **Heavenly Tribulation (Thiên Kiếp)** — Combat, Realms, Event Engine.
12. **Living World Tick** — World DB, Realms, NPC Builds, Edges (NPC half), Time & Turn.
13. **The Way (Đạo)** — Spiritual Roots (read-only), Đạo Đồ (shared skill points); soft: Cultivation Techniques, Realms, Event Engine; Combat for arts only (on hold). Provisional until its GDD is approved.
14. **Modifier System** — Combat (layers, caps, channels), Character Stats. Designed before the Đạo Đồ redesign and the Đạo catalogue, which draw their nodes from it, as do Cultivation Techniques and the item systems.

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
| 13 | Đạo Đồ | MVP | Feature | systems-designer | M |
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
| 43 | Combat revision (folds in #21a, #40, #41); then the Đạo Đồ redesign, the Đạo catalogue, Cultivation Techniques, items — **applied 2026-11-08** (combat.md parts 1–5; back-reference sweep in nine older GDDs) | MVP | Feature | systems-designer | M |
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

| Metric | Count (2026-11-28) |
|--------|-------|
| Systems identified | 50 (48 numbered, plus Combat sub-systems #21a and #21b) |
| Systems implemented in Godot | 45 (#1–28, #30–33, #35–37, #40–48; caveats: #19 spirit beasts only, #17 NPC combat diagrams off) |
| Systems parked | 1 (#29 LLM Game Master — parked 2026-11-15; mock-tested code stays dormant) |
| Systems not built | 3 (#34 Localization & Hán-Việt Glossary, #38 Audio, #39 The Way; plus spirit insects inside #19) |
| System GDDs in `design/gdd/` | 31 system GDDs (+ `npc-traits-catalogue.md` companion = 32 files; covers #6–10, #12–15, #17, #21, #21a, #21b, #22–23, #25–28, #30–31, #39–48) |
| GDDs approved | 16 (#12, #14, #17, #21, #21a, #21b, #22 [rules], #26, #31 [pre-no-LLM], #40, #41, #42 + catalogue, #43, #44, #45, #46, #47, #48 — 18 counting #22 & #31; 2026-11-25 world-depth amendments wait for the single end-of-design `/review-all-gdds` pass) |
| GDDs designed / in review | 13 (#6–10, #13, #15, #23, #25, #27, #28, #30, #39 — awaiting the single holistic `/review-all-gdds` pass) |
| Built systems without a full GDD | 15 (#1–5, #11, #16, #18–20, #24, #32–33, #35–36; 4 quick specs cover #11/#16/#18/#19/#32, `docs/debug-terminal.md` covers #36, `design/ux/` specs cover #37) |
| Library & World Depth content (2026-11-28) | 459 arts (409 authored, 50 common), 247 techniques, 661 items (516 unique, 166 sets), 151 traits (71 v1 + 80 v2), 8,051 Đạo Đồ v5 nodes (7,289 Dao marks, 43 keystones, 55 Effects), 50 active + 11 fallen sects (56 depth owners), 1,909 authored people (1,748 living + 161 dead), 965 events, 2,054 ties, 21 beasts, 705 continent provinces |
| Combat engine & parity | Dual-engine: Python reference (`tools/design/combat_sim/engine.py`) + Godot runtime (`src/gameplay/combat/fight/`), verified in exact + chancy parity (`t1_*`–`t35_darkness_erosion_exact`, incl. `t34_curse_reflect_exact`); Darkness (`am`) stacks (`Shadow Veil` / `Shadow Erosion`) landed 2026-11-28 |
| Automated test suites | 169 GdUnit4 test processes (1,486 test cases across `tests/unit/`, `tests/integration/`, `tests/parity/`) + Python combat/world/lint/parity suite (331 engine tests, 46 exact parity fixtures, 144 compile cases) + `export_cast_ratings.gd --check` |

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
- **Every system is a build slot.** Root, technique, Đạo Đồ, Daos, artifacts, talismans,
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
- The Đạo Đồ and the Way price everything in W, which is additive (1 W = +1 % attack).
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

### NPC Relationships (#46)

Recorded 2026-11-15 at the user's request, to be designed later.

**User intent:** a relationship system for NPCs.

**Ideas to explore (not decisions):**
- Kinds of tie: master and disciple (sư đồ), sworn siblings (kết nghĩa), Dao companions (đạo lữ), friends, rivals,
  enmity and blood feuds (thù hận), debts of gratitude (ân tình), family and clan.
- How ties form, change and end: shared events, fights (Power Rankings world fights), sect life, rescues and
  betrayals, and death passing a feud on to disciples or kin.
- What ties change: event choices and Living World Tick actions, who helps or takes revenge, sect politics and
  succession, quest offers, and the LLM Game Master's narration.
- **Conflict to settle:** NPC Traits rule 16 computes opinion from traits and stores none for NPC pairs. Options
  include keeping computed opinion and storing only named ties, or storing them only for notable NPCs.
- Cost: across 5,000 cultivators the ties must stay cheap in the season tick and the save (a cap per person, or ties
  only between people who have met).
- The player's side: whether the player's ties use the same model as the stored attitude to the player (Quests,
  Formulas E).

---

## Next Steps

Done (through 2026-11-28): the systems enumeration; 110-level Realms ladder and breakthrough curve (calibrated in v5
loader & Stage 11B, no retune needed); full Combat engine (#21, #21a, #21b, #40, #41) ported to Godot with full Python
parity, combat formation diagrams (#17), Darkness (`am`) stacks (`Shadow Veil` / `Shadow Erosion`), `curse_reflect`
(`A Fair Copy`), `diagram_always`, and real-fight `save_fight_meters` writeback (`3941106f`); Đạo Đồ v5 frozen map,
content fill, loader (`DaoDoTree.load_map()`), and PoE-style `DaoDoScreen` UI; Fixed Continent (`#25`, `#48`, 705
provinces) with painted far/near maps and World Depth Stages 0–11 (`world_history.json`: 56 depth owners, 1,909
people, 965 events, 2,054 ties, 21 beasts, land-roll births & sect admission F20/F21); Sects (`#26` + war-weariness
retune `3941106f`), Regional Economy (`#43`), Trade Goods (`#45`), Cave Abode (`#47`), Spirit Herbs (`#14`), Alchemy
(`#15`); Traits v2 (`#42`, 151 traits), NPC Relationships (`#46`), NPC Interaction & Dialogue (`#30`), Event Engine
(`#23`), Template Quests (`#31`), Heavenly Tribulation (`#22`, default-on New Game toggle `3941106f`), Codex & Karmic
Carryover (`#12`); Power Rankings (`#44`, Track 1 complete in `31cd736e`: post-Đạo-Đồ `POST_DAO_DO_TYPICAL` reference
fighters & `t6` mirrors, `k_max = 256` recalibration with 0 saturation / 0 clipping, offline 1,769-entry
`cast_ratings.json` precompute, `RatingService` digest validation & Rule 16 fallback, `power-rankings.md` &
`docs/data-schemas.md` synced); Godot HUD & illustrated carved-hardwood/brass windows (`#37`); and Track 4 GDD sync
(`84bc1692`: `dao-do.md`, `canh-gioi.md`, `character-stats.md`, `systems-index.md`, `game-concept.md`,
`production/todo.md`).

**Next (2026-11-28 — aligned with `production/todo.md` Section 6):**

- [ ] **Phase A — User reviews & small calls:** Đạo Đồ v5 filled content review (`design/dao-do/content-decisions.md`
      #1–34, Metal 6/200 breakthrough notables), 2 non-Darkness unscoped lines (`red-debt-rite`, `lone-branch-sword`),
      and Stage 11 minor advisories (`the-pivot-does-not-turn`, Băng Tâm island seat levels & 12 minor seats)
- [ ] **Phase B — Complete GDD coverage & single holistic review gate:** `#34` Localization & Hán-Việt Glossary GDD,
      `/reverse-document` for the 15 built systems still lacking a full GDD (`#1–5`, `#11`, `#16`, `#18–20`, `#24`,
      `#32–33`, `#35–36`), optional Great Projects GDD handoff (`production/plans/handoff-great-projects.md`), then
      `/consistency-check` + `/review-all-gdds` + Systems Design / Vertical Slice gates
- [ ] **Phase C — Unbuilt systems & perf:** `#39` The Way (Đạo — draw remaining 93 of 94 Ways & implement), `#38`
      Audio, `#34` Localization, spirit insects inside `#19`, side-tree tab for cultivation techniques & items, 4
      out-of-fight Đạo Đồ Effects Pending non-combat hosts, and optional integer-keyed combat hot loop
      (`power-rankings.md` OQ 9)
- [ ] **Phase D — Art integration & release polish:** verify/wire 21 Spirit Beast portraits + 80 v2 trait medallions
      once finished by the parallel art session (do not edit `assets/portraits/` outside the art session), optional
      multi-fighter combat for the 31 parked records (`design/world/depth/builds/postponed-2026-11-26.json`), and
      pre-release checklists
