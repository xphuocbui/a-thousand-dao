# Game Concept: Ten Thousand Daos

*Created: 2026-11-02*
*Revised: 2026-11-28 — synced to the shipped fixed-continent non-LLM authored engine, Đạo Đồ v5 passive tree, full combat & economy systems, and Godot HUD & illustrated UI (LLM Game Master parked 2026-11-15; earlier pivot 2026-11-02 in `prototypes/dao-engine-concept/REPORT.md` and `PIVOT-NOTE.md`)*
*Status: Synced Draft (awaits holistic `/review-all-gdds` pass)*

> **Terminology:** cultivation concepts use English terms from `design/glossary.md` (spiritual root,
> Foundation Establishment, magic treasure…), with the Hán-Việt term in parentheses on first use in
> each section. Crafting artifacts is *artifact refining* (luyện chế pháp bảo), to avoid a clash
> with the realm *Qi Refining* (Luyện Khí).

---

## Elevator Pitch

> It's a cultivation roguelite where you live one cultivator's life — born with a spiritual root
> (linh căn) shaped by the land — and build your own engine of the Đạo Đồ passive tree, spirit herbs
> (linh thảo), pills (đan dược), magic treasures (pháp bảo) and combat formations (trận pháp) to
> break through each realm (cảnh giới) and fight beyond your realm, in one hand-crafted continent
> with centuries of history whose ordinary people, secrets and authored stories unfold deterministically
> inside the engine's visible rules (fully playable offline; LLM narration parked).

---

## Core Identity

| Aspect | Detail |
| ---- | ---- |
| **Genre** | Systemic cultivation (tu tiên) life sim × roguelite; turn-based |
| **Platform** | PC (Steam / Epic) |
| **Target Audience** | Systems-minded planners and min-maxers who love cultivation fiction (see Target Player Profile) |
| **Player Count** | Single-player |
| **Session Length** | 60–120 min per life; natural stops at breakthroughs |
| **Monetization** | Premium (not yet decided) |
| **Estimated Scope** | Large (18–24 months, solo) |
| **Comparable Titles** | Tale of Immortal, Amazing Cultivation Simulator, Dwarf Fortress (adventure mode), Crusader Kings III |

---

## Core Fantasy

From mortal (phàm nhân) to someone the heavens fear — not through talent, but through an engine you
designed. You read your spiritual root (linh căn), choose what to plant, refine and forge, survive
the lean early years, and the plan compounds until a Foundation Establishment (Trúc Cơ) cultivator
with the right magic treasures (pháp bảo) and formations (trận pháp) can kill a Core Formation
(Kết Đan) elder. The power is yours because you built it, and you can explain exactly why it
works.

---

## Unique Hook

It's like *Tale of Immortal*'s cultivation world, **and also** a tight roguelite whose power comes
from a crafting, passive-tree (Đạo Đồ) and cultivation economy you build — where your spiritual root
(linh căn) decides which engine you can assemble, and every number is owned and explained by the engine.

It's also like *Dwarf Fortress* and *Crusader Kings III*: every life begins on a fixed continent
that already has centuries of authored history — 50 active and 11 fallen sects, ~1,900 named
cultivators, lost cultivation techniques (công pháp) and blood feuds — and you can travel to any
province and interact with anyone through trait- and relationship-driven verbs, authored event
chains and template quests grounded in that recorded history.

The hook is systemic, not cosmetic: the spiritual root, Đạo Đồ, cultivation techniques, crafts,
provinces, sects and realms are interlocking rules, and authored events, quests and NPC interactions
all operate inside deterministic, engine-set budgets (LLM narration was parked on 2026-11-15 so the
full game plays cleanly offline without external API or local-model requirements).

---

## Player Experience Analysis (MDA Framework)

### Target Aesthetics (What the player FEELS)

| Aesthetic | Priority | How We Deliver It |
| ---- | ---- | ---- |
| **Sensation** (sensory pleasure) | 6 | Painted paper campaign map & near diorama terrain, carved-hardwood & brass illustrated windows, ink-and-ledger clarity, planned guqin-led audio, the satisfaction of a harvest or a breakthrough |
| **Fantasy** (make-believe, role-playing) | 4 | Mortal (phàm nhân) to immortal; cross-realm combat (vượt cấp), fighting beyond your realm, through what you built |
| **Narrative** (drama, story arc) | 5 | Emergent per-life chronicle driven by recorded world facts, authored event chains, template quests, trait-driven NPC interactions and sect politics |
| **Challenge** (obstacle course, mastery) | 2 | Planning under lifespan (thọ nguyên) pressure; bottlenecks (bình cảnh); tribulations; degenerate-proof economy |
| **Fellowship** (social connection) | N/A | Single-player; sharing builds and lives happens outside the game |
| **Discovery** (exploration, secrets) | 3 | Variant roots (biến dị linh căn), the Way (Đạo), recipes, cultivation technique (công pháp) combinations, each world's history, secret domains (bí cảnh) |
| **Expression** (self-expression, creativity) | 1 | Every life a different spiritual root (linh căn), cultivation technique set and engine; no classes |
| **Submission** (relaxation, comfort zone) | 7 | Turn-based, no reflex pressure; tending an engine season after season |

*Rationale:* the developer ranked self-expression first and challenge/mastery a close second; the
first prototype showed that expression only matters when it happens *inside a system* the player
understands and exploits. Discovery ranks above Fantasy because each life's spiritual root, variant roots, Ways and world history are new things to uncover.

### Key Dynamics (Emergent player behaviors)

- Players read their spiritual root and plan an engine around it ("Fire (Hỏa) + Metal (Kim) with a Thunder (Lôi) root — I'm a duelist this life").
- Players invest now for a breakthrough decades away ("plant this herb now; in 30 years it's the Core Formation (Kết Đan) bottleneck").
- Players with many-element roots plan how to survive and fund the slow early years before the crossover.
- Players set up cross-realm fights deliberately, stacking magic treasures (pháp bảo), formations (trận pháp) and talismans (phù lục).
- Players trade surplus pills (đan dược) for spirit stones (linh thạch) to buy what their spiritual root can't make.
- Players hunt rare treasures and secret arts (bí thuật) to change their spiritual root.
- Players dig into a world's history to find lost cultivation techniques and the people who hold them.

### Core Mechanics (Systems we build)

1. **Spiritual root** — a set of elements — Metal (Kim), Wood, Water (Thủy), Fire, Earth (Thổ) — each with a purity (độ tinh khiết), plus, in about 1 life in 8, a variant root (biến dị linh căn; eight in all, formed from owned elements or born innate). More elements is better late and slower early, with fast crossovers (see Spiritual Root below). Can change during a life, rarely.
2. **Realms (cảnh giới) and bottlenecks** — Qi Refining (Luyện Khí), layers (tầng) 1–10 → Foundation Establishment (Trúc Cơ) → Core Formation → Nascent Soul (Nguyên Anh) → Deity Transformation (Hóa Thần), each major realm with early / middle / late stage / great perfection (sơ / trung / hậu kỳ / đại viên mãn). Roughly 10× power per major realm. Every major breakthrough needs specific resources; each realm extends lifespan.
3. **The building system** — spirit herbs (linh thảo) that gain value with age → alchemy (luyện đan) → pills; artifact refining (luyện chế pháp bảo), with magic treasures refined and nourished over years; spirit beasts / spirit insects (linh thú / linh trùng), bred in numbers; talismans; formations. Crafting affinity comes from the spiritual root.
4. **Cultivation techniques — the Dao folded in** — found and combined, compatible (or not) with your spiritual root; they set cultivation speed and the divine abilities (thần thông) you gain.
5. **Đạo Đồ, Progression Edges & combat as a test of what you built** — a hand-drawn, fixed 8,051-node passive tree (Đạo Đồ) and destiny perks (thiên mệnh) feed a build-heavy deterministic combat engine (layered Modifiers, Effects, wards, 8 damage types, combat formation diagrams, and fight-based Power Rankings) with full hit breakdowns and an interactive fight/replay screen. Cross-realm combat is only possible through what you built.
6. **A fixed continent with a written history** — one authored continent of 705 provinces, 50 active and 11 fallen sects, ~1,900 named characters, and centuries of authored history (wars, fallen sects, ties, beasts and lost treasures) is the same every life (decided 2026-11-12). Each life rolls the ordinary cultivators up to 5,000+ total (shaped by province land qi and sect admission), hidden spots, tile secrets and resource reserves into the world database.
7. **Living world tick, traits & relationships** — at each season's end, provinces, regional markets, sects (development, policies, wars), sparse NPC ties (blood feuds, debts, kin) and named NPCs act under 151 personality/lifestyle/talent traits; the world changes whether or not the player is there.
8. **Authored story, quest & interaction engine (LLM Game Master parked 2026-11-15)** — deterministic Paradox-style Event Engine chains/stories/hooks, authored template quests, and CK-style trait-driven NPC interaction verbs all run offline from the world database inside engine-set budgets and clamping rules. Optional LLM narration stays parked so the full game plays cleanly without a model.
9. **Meta-progression & Heavenly Tribulation** — Heavenly Tribulation (Thiên Kiếp) tests high-realm ascents; One Life and Continue (heir or lineage rebirth) modes pair with a profile Codex of discovered recipes, variant roots, techniques and lives, plus karmic carryover across runs.

---

## Spiritual Root (Linh Căn) System

*Draft values; the GDD tunes them.*

### Tiers — more elements is better

| Tier | Elements | Rarity |
| ---- | ---- | ---- |
| Single root (Đơn linh căn) | 1 | Common |
| Dual root (Song linh căn) | 2 | Uncommon |
| Triple root (Tam linh căn) | 3 | Rare |
| Quadruple root (Tứ linh căn) | 4 | Very rare |
| Five-element root (Ngũ Hành linh căn) | 5 | Legendary |

Why more is better, through rules rather than a flat bonus: each element owned unlocks its
cultivation techniques (công pháp) and crafts; each generating (tương sinh) pair inside the root
(Wood→Fire→Earth→Metal→Water→Wood, i.e. Mộc→Hỏa→Thổ→Kim→Thủy→Mộc) speeds cultivation, and a full
five-element cycle closes the loop for the largest bonus; specific elements can converge or transmute into a variant root
(biến dị linh căn).

The ladder has 110 levels in five realms: 1–10, 11–40, 41–80, 81–100 and 101–110.

### Trade-off — slower early, better late, fast crossovers

Relative cultivation speed vs. a single root at the same stage:

| | QR early (1–3) | QR middle (4–6) | QR late (7–10) | FE early | FE mid | FE late | FE GP | CF early | CF mid | CF late | NS early |
|---|---|---|---|---|---|---|---|---|---|---|---|
| Dual (2) | 0.6 | 0.7 | 0.8 | 0.9 | **1.0** | 1.3 | 1.6 | 2.0 | 2.4 | 2.8 | 3.5 |
| Triple (3) | 0.5 | 0.6 | 0.75 | 0.9 | **1.0** | 1.4 | 1.8 | 2.3 | 2.8 | 3.4 | 4.5 |
| Quadruple (4) | 0.4 | 0.5 | 0.6 | 0.75 | 0.9 | **1.0** | 1.5 | 2.1 | 2.8 | 3.6 | 5 |
| Five (5+) | 0.3 | 0.4 | 0.5 | 0.6 | 0.75 | 0.85 | 0.95 | **1.0** | 1.8 | 2.8 | 6+ |

QR = Qi Refining (Luyện Khí), FE = Foundation Establishment (Trúc Cơ), CF = Core Formation (Kết Đan), NS = Nascent Soul (Nguyên Anh); early/mid/late/GP = sơ/trung/hậu kỳ/đại viên mãn.

Parity: 2–3 elements at Foundation Establishment middle stage, 4 at Foundation Establishment late
stage, 5+ at Core Formation early stage; each further element pushes parity about one sub-stage
later, and growth after parity is steep. A many-element root must survive and fund a slow Qi
Refining and Foundation Establishment through its crafts, caution and engine.

### Variant roots (biến dị linh căn)

Eight rarer roots (six in play: Void and Blood are archived) sit beside the five elements, and each has a role and a hidden Đạo Đồ
sector of its own. They arise in three ways.

| Origin | Variants |
|---|---|
| Convergence (Hội Tụ): specific owned elements meet | Thunder (Lôi) from Fire + Metal; Darkness (Ám) from Earth + Water; Primordial Chaos (Hỗn Độn) from all five |
| Transmutation (Chuyển Hóa): one element runs pure | Light (Quang) from Fire; Ice (Băng) from Water |
| Innate (Thiên Sinh): simply born with it | Wind (Phong). Blood (Huyết) and Void (Hư Không) are archived (2026-11-09) |

An innate variant counts as an extra element for the speed curve; the others do not. The
rules are in `design/gdd/linh-can.md`. The older higher-order mutations (Sword, Pill Fire,
Space, Time and the rest) moved to a separate system, the Way (Đạo), which is not yet designed.

### Changing spiritual roots (linh căn)

The spiritual root can change during a life, but rarely: rare treasures and pills
can add an element, raise purity or trigger a variant root — making the root a long-term build goal
as well as a starting condition.

---

## Realm (Cảnh Giới) Ladder

| Realm | Sub-stages | Lifespan (thọ nguyên), design value | Power vs. realm below |
|---|---|---|---|
| Qi Refining (Luyện Khí) | layers (tầng) 1–10 | ~120 years | a mortal stands no chance |
| Foundation Establishment (Trúc Cơ) | early / middle / late stage / great perfection (sơ / trung / hậu kỳ / đại viên mãn) | ~200 | ~10× |
| Core Formation (Kết Đan) | same | ~500 | ~10× |
| Nascent Soul (Nguyên Anh) | same | ~1000 | ~10× |
| Deity Transformation (Hóa Thần) | same | ~2000 | ~10×; ceiling of the mortal world (Nhân giới) |
| Void Refining (Luyện Hư) → Body Integration (Hợp Thể) → Great Vehicle (Đại Thừa) → Tribulation Crossing (Độ Kiếp) | — | — | Spirit world (Linh giới); later scope |

Cross-realm combat (vượt cấp) is normally impossible; achieving it through magic treasures (pháp
bảo), formations (trận pháp), talismans (phù lục) and swarms is the min-max fantasy. Each major
breakthrough has a bottleneck (bình cảnh) that needs specific resources.

---

## Character Stats

*Summary; the full design (formulas, ranges, edge cases) gets its own GDD (`/design-system character-stats`) after `/map-systems`.*

Every stat is a visible number. Innate stats are the hand you're dealt; power comes from what you
build with them (*Power Is Built, Not Given*).

### Layer 1 — Innate talent (thiên phú; set at birth, changes rarely)

Scale 1–100 with grade bands: **Lower (Hạ)** 1–30 · **Middle (Trung)** 31–60 · **Upper (Thượng)** 61–85 · **Supreme (Cực phẩm)** 86–99 · **Heavenly (Thiên)** 100.

| Stat | Meaning | Drives |
|---|---|---|
| **Spiritual root** (linh căn) | Purity (độ tinh khiết) per element (Metal · Wood · Water · Fire · Earth, i.e. Kim · Mộc · Thủy · Hỏa · Thổ; 0 = absent) + variant roots (biến dị linh căn), each with its own purity | Element count and its curve; cultivation speed with matching cultivation techniques (công pháp); craft affinity |
| **Comprehension** (ngộ tính) | How fast you understand | Learning cultivation techniques and how strong they are, enlightenment (đốn ngộ), discovering recipes and variant roots, breaking bottlenecks (bình cảnh) |
| **Physique** (căn cốt) | Body foundation | Vitality (khí huyết), pill toxicity (đan độc) resistance, body-cultivation techniques |
| **Soul strength** (thần hồn) | Base of spiritual sense | Divine sense (thần thức): magic treasure (pháp bảo) control count, swarm size, formation (trận pháp) complexity, detection |
| **Fortune** (khí vận) | Luck | Lucky encounters (kỳ ngộ), rare finds, crafting crits, and event reward budgets |
| **Dao heart** (đạo tâm) | Willpower | Resisting heart demons (tâm ma), qi deviation (tẩu hỏa nhập ma) and illusions at breakthroughs and tribulations |
| **Presence** (mị lực) | How people take to you | NPC attitude, interaction acceptance scores, prices, recruitment and what NPCs will share |

**Birth modes:**
- **Fated birth (Thiên Định), rolled** — innate talents are rolled at birth; achievements and Codex progress are enabled.
- **Self-made birth (Tự Định), chosen** — the player sets innate talents freely for a casual run; achievements are disabled.

### Layer 2 — Cultivation base (tu vi) state (changes every season)

Realm (cảnh giới) and cultivation base progress (e.g. Foundation Establishment early stage, Trúc Cơ
sơ kỳ, 3,420 / 5,000) · lifespan (thọ nguyên; age / max) · spiritual power (linh lực; realm ×
cultivation technique) · divine sense (Soul strength × realm) · vitality (Physique × realm) ·
**pill toxicity** (0–100: builds with each pill, weakens pills, must be purged — the brake on eating
your way up) · **heart demon** (0–100: builds from killing, failed breakthroughs and broken oaths;
tested against Dao heart at every breakthrough).

### Layer 3 — Craft mastery and combat power (built by doing)

- **Craft mastery (đạo nghệ)** skills rise only through practice: Spirit Farming (Linh Thực), Way of Alchemy (Đan Đạo), Way of Artifacts (Khí Đạo), Way of Formations (Trận Đạo), Way of Talismans (Phù Đạo), Beast Taming (Ngự Thú); ranks First Grade (Nhất phẩm) → Ninth Grade (Cửu phẩm), each multiplied by its element affinity.
- **Combat power / Power Rankings** is never raised directly: in the shipped game, fight-based Elo-style ratings (`design/gdd/power-rankings.md`, replacing the early `chiến lực` sum below) measure what a build actually wins in simulated combat from realm, spiritual power, Đạo Đồ, cultivation techniques, divine abilities (thần thông), magic treasures, formations, talismans (phù lục) and spirit beasts.

### Draft formulas

- Cultivation per season = realm base × spiritual root curve (element count, stage) × (purity of the cultivation technique's elements ÷ 100) × cultivation technique grade × (1 + Comprehension ÷ 200) × local spiritual qi (linh khí) density × (1 − Pill toxicity ÷ 200)
- Breakthrough backlash chance = max(0, Heart demon − Dao heart ÷ 2)%
- Event reward ceiling = realm budget × (0.75 + Fortune ÷ 200)

### Example sheet

```
Lâm Vô Danh — 47 / 200 tuổi                    Trúc Cơ sơ kỳ  3,420 / 5,000
LINH CĂN  Tam linh căn + Quang
  Hỏa 78 Thượng   Mộc 52 Trung   Thổ 31 Trung   Kim 0   Thủy 0
  Biến dị: Quang 62 (từ Hỏa)                parity at Trúc Cơ trung kỳ · now 0.75×
THIÊN PHÚ  Ngộ tính 72 Thượng · Căn cốt 44 Trung · Thần hồn 58 Trung
           Khí vận 23 Hạ · Đạo tâm 66 Thượng · Mị lực 40 Trung
TRẠNG THÁI Linh lực 840/840 · Thần thức 290 · Khí huyết 1,320
           Đan độc 34 (pill effect −17%) · Tâm ma 12 (backlash 0%)
ĐẠO NGHỆ   Đan Đạo Tam phẩm (Hỏa ×1.78) · Linh Thực Nhị phẩm (Mộc ×1.52)
CHIẾN LỰC  2,950 = realm 1,800 + công pháp 420 + pháp bảo 600 + phù lục 130
```

---

## Player Motivation Profile

### Primary Psychological Needs Served

| Need | How This Game Satisfies It | Strength |
| ---- | ---- | ---- |
| **Autonomy** (freedom, meaningful choice) | No classes; the player decides which engine to build from their spiritual root (linh căn) and where to go | Core |
| **Competence** (mastery, skill growth) | Inspectable rules and numbers; long plans that visibly pay off; bottlenecks (bình cảnh) and tribulations as clear tests | Core |
| **Relatedness** (connection, belonging) | Masters, rivals, debts and trading partners persist in the world database and return in the story | Supporting |

### Player Type Appeal (Bartle Taxonomy)

- [x] **Achievers** (goal completion, collection, progression) — How: realms, the Codex of recipes and variant roots (biến dị linh căn), ascending with every spiritual root tier
- [x] **Explorers** (discovery, understanding systems, finding secrets) — How: variant root rules, the Way (Đạo), recipes, cultivation technique (công pháp) combinations, secret domains (bí cảnh), each world's history
- [ ] **Socializers** (relationships, cooperation, community) — How: only indirectly, via sharing builds and lives
- [ ] **Killers/Competitors** (domination, PvP, leaderboards) — How: not served

Quantic Foundry: primary **Strategy + Completion**, secondary **Fantasy + Design**.

### Flow State Design

- **Onboarding curve**: the first life rolls a simple single or dual root (Đơn or Song linh căn) and opens with one plot, one recipe and one cultivation technique; the first harvest, first pill and first breakthrough land within the first 15 minutes.
- **Difficulty scaling**: bottlenecks demand rarer resources each realm; tribulations scale; harder world settings after a first Core Formation (Kết Đan).
- **Feedback clarity**: every decision shows its projected effect (harvest value, pill yield, cultivation-speed change, combat power); the combat log shows every term.
- **Recovery from failure**: death ends the life but yields karmic carryover, Codex entries and a chronicle; a new life (new world, new spiritual root) starts immediately, and failures are explainable from the log.

---

## Core Loop

### Moment-to-Moment (30 seconds)

One engine decision, with its projected effect shown immediately: which spirit herb (linh thảo) goes
in this plot; refine this herb now or let it age; which recipe to attempt; which magic treasure (pháp
bảo) to feed spirit stones (linh thạch) to; which cultivation technique (công pháp) to cultivate.
Satisfying because it is legible and compounding — you can see the plan getting better.

### Short-Term (5-15 minutes)

One season: tend and harvest spirit herbs, practise alchemy (luyện đan), trade at regional markets
(phường thị), tend your cave abode (động phủ), explore a secret domain (bí cảnh), interact with
NPCs through trait- and relationship-driven verbs, follow authored event chains and template quests
— or go into closed-door cultivation (bế quan) for years at a time. Events and fights resolve
deterministically in the engine with full breakdowns. At season's end the living world ticks and
lifespan (thọ nguyên) counts down. "One more season" lives here: the herb is almost old enough, the
breakthrough is almost funded.

### Session-Level (30-120 minutes)

One life. The spiritual root (linh căn) reveal, an origin pick (born into a sect, a clan, or as
nobody) that sets where on the map you start, surviving the slow start, the crossover moment when the engine takes
off, the bottlenecks (bình cảnh) and tribulations of each realm — ending in ascension or death.
Breakthroughs are natural stopping points.

### Long-Term Progression

- **Codex** of discovered recipes and variant roots (biến dị linh căn).
- **Karmic carryover** grants a small inheritance to the next life.
- **A new world and a new spiritual root each life**, so no two engines are the same.
- Harder world settings after a first Core Formation (Kết Đan); long-term goal: reach Deity Transformation (Hóa Thần) with every spiritual root tier.

### Retention Hooks

- **Curiosity**: undiscovered variant roots and recipes, the next world's history, what a five-element root (Ngũ Hành linh căn) can do
- **Investment**: herbs aging toward a breakthrough, magic treasures nourished for years, the Codex
- **Social**: sharing spiritual root rolls, engines and absurd cross-realm (vượt cấp) wins (outside the game)
- **Mastery**: reaching higher realms, beating harder world settings, making a "bad" spiritual root work

---

## Game Pillars

### Pillar 1: Your Dao, Your Name
Every life produces a cultivator whose spiritual root (linh căn), cultivation techniques (công pháp) and engine are unmistakably theirs.

*Design test*: If we're debating between an option that creates more distinct builds and one that is easier to balance, this pillar says we choose **more distinct builds**.

### Pillar 2: Every Number Is Bounded and Visible
Every event, quest, interaction, economy rule, combat formula — and any future optional LLM layer — may produce or alter numbers (rewards, NPC strength, prices, item stats) only inside explicit budgets the engine sets for the current realm, rarity tier and event type; the engine validates, clamps and records every value in the world database, after which it is canonical and inspectable with a breakdown like any other number. Narrative text describes resolved outcomes and never rewrites one after the fact.

*Design test*: If a new event, quest, system or optional narration layer wants to introduce a number, the engine supplies the range, clamps and logs it — and if a number has no budget yet, **we define one before it may be used**.

*Rationale:* storytelling sometimes needs varied rewards or encounters ("a 300-year spirit herb (linh thảo) worth 40 spirit stones (linh thạch)"); bounding and explaining them preserves planning and theory-crafting.

### Pillar 3: Power Is Built, Not Given
Power emerges from what the player constructs inside the system — spiritual root, cultivation techniques, crafts and assets — never from picking bigger numbers.

*Design test*: If we're debating between a flat stat bonus and a buildable asset, this pillar says we choose **the buildable asset**.

*Rationale:* the first prototype's stat-block fragments were rejected because "it doesn't even have a decent system".

### Pillar 4: Every Season Counts
Time and lifespan (thọ nguyên) are scarce; herbs age, closed-door cultivation (bế quan) costs years, and many-element roots start slow — the timing of the plan matters as much as the plan.

*Design test*: If an action costs no time or resources, we **give it a cost or cut it**.

### Pillar 5: A World That Remembers
Stories grow from recorded facts — people, places, items and history in the world database. The world has a history before the player arrives and keeps acting while they travel.

*Design test*: If an event, quest or narration layer wants to introduce something new, we **prefer a callback to an existing entity; anything new must be registered in the database first**.

*Intended tensions:* Pillar 1 pulls against Pillar 2 (wild expression vs. provable math); Pillar 3 pulls against Pillar 4 (ever-growing engines vs. scarce time).

### Anti-Pillars (What This Game Is NOT)

- **NOT stat-block card picking**: power never comes from choosing the bigger number off a list — it would compromise *Power Is Built, Not Given*.
- **NOT reflex or action combat**: outcomes come from what you built, not hand speed — it would compromise *Every Number Is Bounded and Visible*.
- **NOT an unbounded LLM**: LLM narration is parked (2026-11-15) so the game runs cleanly offline; neither authored templates nor any future optional LLM may create numbers outside a budget, change game rules, or alter a recorded value — it would compromise *Every Number Is Bounded and Visible*.
- **NOT fixed classes**: the spiritual root shapes a build but never locks it — locking would compromise *Your Dao, Your Name*.
- **NOT a granular world simulation (Dwarf Fortress or CK scale)**: the geography and history are authored once and the same every life (decided 2026-11-12), and the land stays fixed (only rare scars change it). The living world ticks once per season with abstract steps per region or per place: faction and NPC actions, mine output, a region's supply. There is no per-tick body, per-item, per-NPC trade, per-tile or pathing simulation (clarified 2026-11-10 with Travel & Map). Anything deeper would break first-game scope — compromising *Power Is Built, Not Given* and *Every Season Counts*.
- **NOT the novel's IP**: we take the cultivation-economy *systems and genre conventions* of Phàm Nhân Tu Tiên, never its characters, places, sects, plot or signature items — originality protects *Your Dao, Your Name* and the project itself.

---

## Visual Identity Anchor

*Proposed during concept (art-director review skipped in Lean mode); `/art-bible` refines it.*

**Direction: Ink and Ledger — Carved Hardwood & Painted Map** (updated 2026-11-22/24 for the shipped Godot UI): a painted paper campaign map (far zoom) transitioning into painted diorama terrain (near zoom), paired with carved hardwood & brass illustrated windows, a PoE-style full-screen Đạo Đồ canvas, and crisp, ledger-clean UI for every number (missing art renders explicit `PlaceholderArt`, never a stand-in).

**Visual rule:** The world is brushed; the math is printed. Nothing mechanical is ever hidden in the art.

**Supporting principles:**
1. **The map is a scroll.** The province map unrolls as it is explored. *Design test:* a new map feature is drawn as part of the scroll, not as a floating overlay.
2. **Glyphs, not paintings.** Item, herb and magic treasure (pháp bảo) icons are built from a compositable glyph-and-element system. *Design test:* a new item needs no new hand-painted asset to ship.
3. **Numbers in print.** Every mechanical value uses the clean UI layer, never brushwork. *Design test:* if a value is only legible in the illustration, move it to the UI.

**Colour philosophy:** Colour is earned. Ink black on rice paper by default; element colours — Fire (Hỏa) vermilion, Water (Thủy) indigo, Wood (Mộc) jade, Metal (Kim) gold, Earth (Thổ) ochre — appear as the cultivator's spiritual root (linh căn) awakens and their engine grows, so a late-life screen visibly reflects the build.

---

## Inspiration and References

| Reference | What We Take From It | What We Do Differently | Why It Matters |
| ---- | ---- | ---- | ---- |
| Phàm Nhân Tu Tiên (novel, Vong Ngữ) | The cultivation economy: spiritual root (linh căn), realm ladder and bottlenecks (bình cảnh), herbs and alchemy, artifacts, beasts, talismans, formations; the mortal who wins by planning | Original world, names and items; a player-built roguelite; more-elements-is-better spiritual root | The developer's anchor for "a system you build inside" |
| Tale of Immortal | Cultivation-world sandbox, realms, sects | Tight roguelite lives; an engine-building economy as the core | Validates a large audience for cultivation games |
| Amazing Cultivation Simulator | Systemic cultivation, interlocking production | One cultivator, not a colony | Validates systemic depth in the genre |
| Dwarf Fortress (adventure mode) | Generated world history and legends; go anywhere, talk to anyone | An authored fixed continent and history instead of a generated one; abstract seasonal world tick; roguelite structure; trait- and relationship-driven interaction verbs | Validates history as a source of emergent stories |
| Crusader Kings II/III | Emergent character story from systems, map-centric UI, traits & nested tooltips | One cultivator's life per run (or heir/rebirth Continue mode), cultivation economy & build combat | Validates emergent narrative and map-centric UX as a hook |
| Europa Universalis IV | Long-horizon planning and min-maxing an economy | Personal scale — one cultivator's engine, not a nation | Matches the creator's and target player's taste |

**Non-game inspirations**: cultivation (tu tiên) / xianxia novels (realms, tribulations, the mortal-to-immortal arc); wuxia film; Chinese ink-wash painting and scroll maps; guqin music.

*Removed after the first prototype:* Balatro and Backpack Battles — they pulled the design toward stat-block card picking.

---

## Target Player Profile

| Attribute | Detail |
| ---- | ---- |
| **Age range** | 18-40 |
| **Gaming experience** | Mid-core to hardcore |
| **Time availability** | 60-120 minute sessions; can stop at breakthroughs |
| **Platform preference** | PC |
| **Current games they play** | Tale of Immortal, Amazing Cultivation Simulator, Europa Universalis IV, Crusader Kings III, Dwarf Fortress |
| **What they're looking for** | A cultivation game whose power comes from a system they understand and exploit, with a different life and story every run |
| **What would turn them away** | Reflex combat, hidden or arbitrary numbers, stat-block progression, an LLM that contradicts the rules, samey events |

---

## Technical Considerations

| Consideration | Assessment |
| ---- | ---- |
| **Recommended Engine** | Godot 4.7.1, GDScript (configured by `/setup-engine`) |
| **Key Technical Challenges** | An interlocking economy & province simulation (herb aging, alchemy, artifacts, formations, regional markets, cultivation speed) that is deterministic and inspectable; dual-engine (Python + Godot) combat parity across Modifiers, Effects and Power Rankings; an authored fixed continent and history with per-life rolls; seasonal living-world tick at 5,000+ cultivators; responsive Godot 2D map-centric HUD & Đạo Đồ canvas |
| **Art Style** | Painted paper campaign map (far) + painted diorama terrain (near), carved hardwood & brass illustrated windows, painted node/item icons + clean ledger UI |
| **Art Pipeline Complexity** | Medium (painted continent crops, character portraits, node/item icons, `PlaceholderArt` for remaining assets) |
| **Audio Needs** | Moderate (guqin-led ambient music, UI and crafting SFX — unbuilt) |
| **Networking** | None (offline single-player; optional LLM API parked 2026-11-15) |
| **Content Volume** | 5 base elements and 6 active variant roots (biến dị linh căn; 2 archived); 5 realms (Qi Refining–Deity Transformation, i.e. Luyện Khí–Hóa Thần); fixed continent of 705 provinces, 50 active & 11 fallen sects, ~1,900 named characters, 965 historical events, 2,054 ties, 21 spirit beasts; 8,051-node Đạo Đồ v5; 247 cultivation techniques, 459 arts, 661 items (166 sets), 50 combat formation diagrams, 151 traits (v1+v2), 23 raw trade goods; 40+ hours to master |
| **Procedural Systems** | Land-influenced spiritual root (linh căn) generation; per-life rolls on the authored continent (ordinary cultivators to 5,000+, hidden-place spots, tile secrets, resource reserves); seasonal living-world tick; deterministic Event Engine chains, template quests and trait-driven NPC interactions. The continent map and core cast/history are authored, not procedural (2026-11-12); LLM generation is parked (2026-11-15) |

---

## Risks and Open Questions

### Design Risks
- The economy may produce a degenerate strategy (one engine dominates every spiritual root, linh căn).
- The slow early game of many-element roots may frustrate players before the crossover.
- Open freedom (go anywhere, talk to anyone) pulls against lifespan (thọ nguyên) pressure; talking may need a time cost.
- Hán-Việt terminology may be opaque to non-Vietnamese players without a glossary.

### Technical Risks
- Balancing many interlocking systems needs a headless simulation from the start (addressed: Python combat sim + Godot headless balance suite).
- *(Parked 2026-11-15 with LLM Game Master)* Local-model latency, structured-output reliability, and model-weight redistribution licensing no longer block gameplay; they return only if optional LLM narration is ever revived.
- The authored history and the rolled people must stay coherent across seasons and saves (`world_data_version` and `depth_check.py` guard data integrity).
- Feasibility not assessed by technical-director (TD-FEASIBILITY skipped — Lean mode).

### Market Risks
- The core cultivation audience is largely Chinese- and Vietnamese-speaking — localization (Vietnamese, Chinese, English) matters early.
- Steam requires disclosure of AI-generated art/content assets used in development.

### Scope Risks
- **Top risk:** five crafting systems, a living continent and deep combat is large for a solo project. Mitigation: systems were built and verified incrementally behind headless balance and parity suites, and live LLM narration was parked (2026-11-15).
- The authored continent plus living-world tick stays abstract per province/sect/season to keep 5,000-cultivator performance fast.
- Scope not assessed by producer (PR-SCOPE skipped — Lean mode).

### Open Questions
- ~~Do root mutations (biến dị) count as extra elements for the tier curve?~~ **Answered in the Spiritual Roots GDD (redesign 2026-11-04):** innate variants count as an extra element for the curve, derived ones do not.
- How the seven innate talents (thiên phú) roll (distributions, correlations, origin influence) and whether Self-made birth (Tự Định) has any limits — decide in the character-stats GDD.
- Time granularity: is a turn a season or a year, and how does closed-door cultivation (bế quan) for years interact with herb aging? — answer in the next prototype.
- Exact combat resolution: how cultivation base (tu vi) and each asset type combine, and how cross-realm combat (vượt cấp) becomes possible — answer in the combat GDD and prototype.
- Which local model size gives acceptable quality at mainstream VRAM? — benchmark with a real model.

---

## MVP Definition & Current Scope Status (2026-11-28)

**Core hypothesis** *(original 2026-11-02 anchor, preserved)*: If the player plans an engine shaped by their spiritual root (linh căn) — spirit herbs (linh thảo) → pills (đan dược) → breakthrough — under lifespan (thọ nguyên) pressure, they will feel the compounding of their own plan — evidenced by deliberate long-term investments the player can explain, and by different spiritual roots leading to visibly different engines.

**Superseded early MVP:** The original one-province, single-craft, LLM-harness MVP definition (2026-11-02) has been superseded by the shipped fixed-continent, non-LLM Godot build. All five mortal-world realms (Qi Refining → Deity Transformation), the full 705-province authored continent (`world_continent.json` + `world_history.json` with 50 active / 11 fallen sects and 1,909 named characters), the frozen Đạo Đồ v5 passive tree (`DaoDoScreen`), the dual-engine combat system (Modifiers, Effects, 8 damage types including Darkness stacks, combat formation diagrams, Power Rankings), all five economy/abode/regional-trade tracks, Traits v2, NPC Relationships, NPC Interaction (`#30`), Event Engine (`#23`), Template Quests (`#31`), Heavenly Tribulation (`#22`), Codex & Karmic Carryover (`#12`), and the Godot map-centric HUD & illustrated windows (`#37`) are implemented and verified by automated suites.

### Scope Tiers (updated 2026-11-28)

| Tier | Content | Features | Status |
| ---- | ---- | ---- | ---- |
| **MVP** | Qi Refining → Deity Transformation, full 705-province fixed continent | Spiritual roots + land roll, Đạo Đồ v5, herbs + alchemy + artifacts + formations + talismans + beasts, full combat & Power Rankings, authored history, offline Event Engine | **Shipped** (Power Rankings Track 1 precompute in progress) |
| **Vertical Slice** | Full mortal-world playable loop in Godot | Map-centric HUD & carved-hardwood illustrated windows, `DaoDoScreen`, Living World Tick, Traits v2, Relationships, Interaction `#30`, Quests `#31`, Tribulation `#22`, Codex & Karmic Carryover `#12` | **Shipped** |
| **Alpha** | Remaining feature breadth & holistic design sign-off | The Way (`#39`), Localization (`#34`), spirit insects, side-tree tab, remaining GDD `/reverse-document` + single `/review-all-gdds` pass, remaining beast/trait art | **In Progress** |
| **Full Vision** | Polish & release | Audio (`#38`), Vietnamese / Chinese / English localization, release polish, Steam launch | **Planned** |

---

## Next Steps (2026-11-28)

- [x] Core systems built & playable in Godot (fixed continent, Đạo Đồ v5, combat + formations + Darkness stacks, economy/sects/provinces/abode, traits/ties/interaction/events/quests/tribulation/codex, Godot HUD & illustrated windows)
- [ ] Complete Track 1 Power Rankings post-Đạo-Đồ calibration & offline `cast_ratings.json` precompute
- [ ] Finish remaining unbuilt Alpha/Full Vision systems: The Way (`#39`), Localization (`#34`), Audio (`#38`), remaining beast/trait art
- [ ] Finish remaining `/reverse-document` GDDs and run `/consistency-check` + single `/review-all-gdds` pass (including this concept doc)
- [ ] Run `/project-stage-detect`, `/gate-check`, and playtest validation (`/playtest-report`) toward Alpha/release
