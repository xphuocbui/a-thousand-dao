# Game Concept: Ten Thousand Daos

*Created: 2026-11-02*
*Revised: 2026-11-02 — pivot after the first concept prototype (see `prototypes/dao-engine-concept/REPORT.md` and `PIVOT-NOTE.md`)*
*Status: Draft*

> **Terminology:** cultivation concepts use English terms from `design/glossary.md` (spiritual root,
> Foundation Establishment, magic treasure…), with the Hán-Việt term in parentheses on first use in
> each section. Crafting artifacts is *artifact refining* (luyện chế pháp bảo), to avoid a clash
> with the realm *Qi Refining* (Luyện Khí).

---

## Elevator Pitch

> It's a cultivation roguelite where you live one cultivator's life — born with a spiritual root
> (linh căn) that shapes everything — and build your own engine of spirit herbs (linh thảo),
> pills (đan dược), magic treasures (pháp bảo) and formations (trận pháp) to break through each realm
> (cảnh giới) and fight beyond your realm, in a freshly generated world whose stories an LLM tells
> within the engine's rules.

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
from a crafting and cultivation economy you build — where your spiritual root (linh căn) decides
which engine you can build, and an LLM tells the life you lived using numbers the engine owns.

It's also like *Dwarf Fortress* adventure mode: every life begins in a world that already has a
history — fallen sects, legendary cultivators, lost cultivation techniques (công pháp) — and you can
go to any node and talk to anyone, with the LLM voicing people who actually exist in that history.

The hook is systemic, not cosmetic: the spiritual root, cultivation techniques, crafts and realms
are interlocking rules,
and the LLM generates events, quests and people the player routes through, inside engine-set budgets.

---

## Player Experience Analysis (MDA Framework)

### Target Aesthetics (What the player FEELS)

| Aesthetic | Priority | How We Deliver It |
| ---- | ---- | ---- |
| **Sensation** (sensory pleasure) | 6 | Ink-wash art, guqin-led audio, the satisfaction of a harvest or a breakthrough |
| **Fantasy** (make-believe, role-playing) | 4 | Mortal (phàm nhân) to immortal; cross-realm combat (vượt cấp), fighting beyond your realm, through what you built |
| **Narrative** (drama, story arc) | 5 | Emergent per-life chronicle written by the LLM from recorded world facts |
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
5. **Combat as a test of what you built** — cultivation base (tu vi) × assets (magic treasures, formations, talismans, swarm size), resolved by the engine and fully inspectable, then narrated by the LLM. Cross-realm combat is only possible through what you built.
6. **World generation with history** — before each life, world-gen simulates a few centuries in seconds (sects founded and destroyed, wars, deaths, artifacts and cultivation techniques lost) and writes the result to the world database that seeds the LLM.
7. **Living world tick** — at each season's end, sects and named NPCs take abstract actions (expand, feud, die, break through, hunt a treasure); the world changes whether or not the player is there.
8. **Bounded LLM game master** — generates events, quests, NPC dialogue and narration from the world database; may author numbers only inside engine-set budgets, which the engine clamps and records.
9. **Meta-progression** — a Codex of discovered recipes and variant roots, and karmic carryover across lives.

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

Eight rarer roots sit beside the five elements, and each has a role and a hidden Meridian Map
sector of its own. They arise in three ways.

| Origin | Variants |
|---|---|
| Convergence (Hội Tụ): specific owned elements meet | Thunder (Lôi) from Fire + Metal; Darkness (Ám) from Earth + Water; Chaos (Hỗn Độn) from all five |
| Transmutation (Chuyển Hóa): one element runs pure | Light (Quang) from Fire; Ice (Băng) from Water |
| Innate (Thiên Sinh): simply born with it | Wind (Phong); Blood (Huyết); Void (Hư Không), only on roots of two elements or fewer |

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
| **Comprehension** (ngộ tính) | How fast you understand | Learning cultivation techniques, enlightenment (đốn ngộ), discovering recipes and variant roots, breaking bottlenecks (bình cảnh) |
| **Physique** (căn cốt) | Body foundation | Vitality (khí huyết), pill toxicity (đan độc) resistance, body-cultivation techniques |
| **Soul strength** (thần hồn) | Base of spiritual sense | Divine sense (thần thức): magic treasure (pháp bảo) control count, swarm size, formation (trận pháp) complexity, detection |
| **Fortune** (khí vận) | Luck | Lucky encounters (kỳ ngộ), rare finds, crafting crits, and the ceiling of LLM-invented reward budgets |
| **Dao heart** (đạo tâm) | Willpower | Resisting heart demons (tâm ma), qi deviation (tẩu hỏa nhập ma) and illusions at breakthroughs and tribulations |
| **Presence** (mị lực) | How people take to you | NPC attitude, prices, recruitment, what LLM-voiced NPCs will share |

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
- **Combat power (chiến lực)** is never raised directly: it is computed from realm, spiritual power, cultivation technique, divine abilities (thần thông), magic treasures, formations, talismans (phù lục) and swarm, and always shown as a breakdown.

### Draft formulas

- Cultivation per season = realm base × spiritual root curve (element count, stage) × (purity of the cultivation technique's elements ÷ 100) × cultivation technique grade × (1 + Comprehension ÷ 200) × local spiritual qi (linh khí) density × (1 − Pill toxicity ÷ 200)
- Breakthrough backlash chance = max(0, Heart demon − Dao heart ÷ 2)%
- LLM reward ceiling = realm budget × (0.75 + Fortune ÷ 200)

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

One season: tend and harvest spirit herbs, practise alchemy (luyện đan), trade at a market (phường
thị), explore a secret domain (bí cảnh), talk to anyone the LLM voices from their world-database
record, take quests that come from people and world state — or go into closed-door cultivation (bế
quan) for years at a time. Events are resolved by the engine and narrated by the LLM. At season's end
the living world ticks and lifespan (thọ nguyên) counts down. "One more season" lives here: the herb
is almost old enough, the breakthrough is almost funded.

### Session-Level (30-120 minutes)

One life. World generation and the spiritual root (linh căn) reveal, an origin pick (born into a
sect, a clan, or as nobody), surviving the slow start, the crossover moment when the engine takes
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
The LLM may author numbers (rewards, NPC strength, prices, item stats) only inside a budget the engine sets for the current realm, rarity tier and event type; the engine validates, clamps and records the value in the world database, after which it is canonical and inspectable like any other number. The LLM narrates resolved outcomes and never rewrites one after the fact.

*Design test*: If the LLM wants to introduce a number, the engine supplies the range, clamps and logs it — and if a number has no budget yet, **we define one before the LLM may use it**.

*Rationale:* storytelling sometimes needs invented numbers ("a 300-year spirit herb (linh thảo) worth 40 spirit stones (linh thạch)"); bounding them preserves planning and theory-crafting.

### Pillar 3: Power Is Built, Not Given
Power emerges from what the player constructs inside the system — spiritual root, cultivation techniques, crafts and assets — never from picking bigger numbers.

*Design test*: If we're debating between a flat stat bonus and a buildable asset, this pillar says we choose **the buildable asset**.

*Rationale:* the first prototype's stat-block fragments were rejected because "it doesn't even have a decent system".

### Pillar 4: Every Season Counts
Time and lifespan (thọ nguyên) are scarce; herbs age, closed-door cultivation (bế quan) costs years, and many-element roots start slow — the timing of the plan matters as much as the plan.

*Design test*: If an action costs no time or resources, we **give it a cost or cut it**.

### Pillar 5: A World That Remembers
Stories grow from recorded facts — people, places, items and history in the world database. The world has a history before the player arrives and keeps acting while they travel.

*Design test*: If the LLM wants to introduce something new, we **prefer a callback to an existing entity; anything new must be registered in the database first**.

*Intended tensions:* Pillar 1 pulls against Pillar 2 (wild expression vs. provable math); Pillar 3 pulls against Pillar 4 (ever-growing engines vs. scarce time).

### Anti-Pillars (What This Game Is NOT)

- **NOT stat-block card picking**: power never comes from choosing the bigger number off a list — it would compromise *Power Is Built, Not Given*.
- **NOT reflex or action combat**: outcomes come from what you built, not hand speed — it would compromise *Every Number Is Bounded and Visible*.
- **NOT an unbounded LLM**: the LLM never creates numbers outside a budget, changes game rules, or alters a recorded value — it would compromise *Every Number Is Bounded and Visible*.
- **NOT fixed classes**: the spiritual root shapes a build but never locks it — locking would compromise *Your Dao, Your Name*.
- **NOT a granular world simulation (Dwarf Fortress or CK scale)**: history is generated at world creation, and the living world ticks once per season with abstract faction and NPC actions — no per-tick body, economy or pathing simulation. Anything deeper would break first-game scope — compromising *Power Is Built, Not Given* and *Every Season Counts*.
- **NOT the novel's IP**: we take the cultivation-economy *systems and genre conventions* of Phàm Nhân Tu Tiên, never its characters, places, sects, plot or signature items — originality protects *Your Dao, Your Name* and the project itself.

---

## Visual Identity Anchor

*Proposed during concept (art-director review skipped in Lean mode); `/art-bible` refines it.*

**Direction: Ink and Ledger** — ink-wash (*shuimo*) 2D illustration for the world and map, paired with crisp, ledger-clean UI for the numbers.

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
| Dwarf Fortress (adventure mode) | Generated world history and legends; go anywhere, talk to anyone | Abstract seasonal world tick; roguelite structure; LLM conversation instead of menus | Validates generated history as a source of emergent stories |
| Crusader Kings II/III | Emergent character story from systems | One life per run, LLM-narrated | Validates emergent narrative as a hook |
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
| **Key Technical Challenges** | An interlocking economy simulation (herb aging, alchemy, artifacts, cultivation speed) that is deterministic and inspectable; balance across many interacting systems (needs a headless sim); world generation with history; seasonal living-world tick; local-LLM integration with structured output, engine-side budgets and clamping |
| **Art Style** | 2D ink-wash illustration + clean UI |
| **Art Pipeline Complexity** | Medium (custom 2D; compositable glyph system for icons) |
| **Audio Needs** | Moderate (guqin-led ambient music, UI and crafting SFX) |
| **Networking** | None for gameplay; optional HTTPS to an LLM API provider |
| **Content Volume** | 5 base elements and 8 variant roots (biến dị linh căn); 5 realms (Qi Refining–Deity Transformation, i.e. Luyện Khí–Hóa Thần); ~60 spirit herbs (linh thảo), ~40 pill (đan dược) recipes, ~40 magic treasures (pháp bảo), ~20 spirit beasts/spirit insects (linh thú/linh trùng), ~30 talismans (phù lục), ~20 formations (trận pháp), ~40 cultivation techniques (công pháp); 1-2 provinces; 40+ hours to master |
| **Procedural Systems** | Spiritual root (linh căn) generation; world generation with centuries of history per life; seasonal living-world tick; LLM-generated events, quests, dialogue and narration; procedural map layout per life |

---

## Risks and Open Questions

### Design Risks
- The economy may produce a degenerate strategy (one engine dominates every spiritual root, linh căn).
- The slow early game of many-element roots may frustrate players before the crossover.
- Open freedom (go anywhere, talk to anyone) pulls against lifespan (thọ nguyên) pressure; talking may need a time cost.
- Hán-Việt terminology may be opaque to non-Vietnamese players without a glossary.

### Technical Risks
- Balancing many interlocking systems needs a headless simulation from the start.
- Local-model latency and quality on mid-range GPUs (the developer's machine: AMD RX 9070 XT, 61 GB RAM; no model installed yet).
- Reliable structured output from the LLM (JSON schema or grammar-constrained decoding).
- Licensing for redistributing model weights.
- Generated history must stay coherent enough for the LLM to build on without contradicting it.
- Feasibility not assessed by technical-director (TD-FEASIBILITY skipped — Lean mode).

### Market Risks
- The core cultivation audience is largely Chinese- and Vietnamese-speaking — localization (Vietnamese, Chinese, English) matters early.
- Steam requires disclosure of AI-generated content, including guardrails for live-generated content.

### Scope Risks
- **Top risk:** five crafting systems, world generation and an LLM is too much for a first game. Mitigation: the MVP has one craft, spirit herbs (linh thảo) + alchemy (luyện đan); the rest arrive tier by tier.
- World generation plus a living world is kept abstract to protect the 18-24 month estimate.
- Scope not assessed by producer (PR-SCOPE skipped — Lean mode).

### Open Questions
- ~~Do root mutations (biến dị) count as extra elements for the tier curve?~~ **Answered in the Spiritual Roots GDD (redesign 2026-11-04):** innate variants count as an extra element for the curve, derived ones do not.
- How the seven innate talents (thiên phú) roll (distributions, correlations, origin influence) and whether Self-made birth (Tự Định) has any limits — decide in the character-stats GDD.
- Time granularity: is a turn a season or a year, and how does closed-door cultivation (bế quan) for years interact with herb aging? — answer in the next prototype.
- Exact combat resolution: how cultivation base (tu vi) and each asset type combine, and how cross-realm combat (vượt cấp) becomes possible — answer in the combat GDD and prototype.
- Which local model size gives acceptable quality at mainstream VRAM? — benchmark with a real model.

---

## MVP Definition

**Core hypothesis**: If the player plans an engine shaped by their spiritual root (linh căn) — spirit herbs (linh thảo) → pills (đan dược) → breakthrough — under lifespan (thọ nguyên) pressure, they will feel the compounding of their own plan — evidenced by deliberate long-term investments the player can explain, and by different spiritual roots leading to visibly different engines.

**Required for MVP**:
1. Character generation: innate talents (thiên phú), by Fated birth (Thiên Định) roll and Self-made birth (Tự Định) choice, including spiritual root element count, purity, variant roots (biến dị linh căn), and the slow-early / fast-crossover curve; pill toxicity (đan độc) and heart demon (tâm ma)
2. Qi Refining (Luyện Khí) → Foundation Establishment (Trúc Cơ) → Core Formation (Kết Đan) with bottlenecks (bình cảnh) and lifespan
3. Spirit herb aging + alchemy (luyện đan) — the only craft in the MVP
4. A handful of cultivation techniques (công pháp) with spiritual root compatibility
5. Combat as an asset check, with one tribulation
6. Minimal world generation: one province, ~3 sects, ~20 named NPCs, ~100 years of history
7. LLM harness (events and narration within budgets) + templated-narration fallback

**Explicitly NOT in MVP** (defer to later):
- Artifact refining (luyện chế pháp bảo), spirit beasts / spirit insects (linh thú / linh trùng), talismans (phù lục), formations (trận pháp)
- The Way (Đạo) and changing spiritual roots
- Nascent Soul (Nguyên Anh) and above
- Living-world season tick, Codex, karmic carryover
- Final art and audio; LLM API provider option

### Scope Tiers (if budget/time shrinks)

| Tier | Content | Features | Timeline |
| ---- | ---- | ---- | ---- |
| **MVP** | Qi Refining → Core Formation, 1 small province | Spiritual root, herbs + alchemy, combat check, LLM harness, minimal world-gen | ~2-3 months |
| **Vertical Slice** | + Nascent Soul | + Artifact refining, living-world tick, Codex, NPC memory, quests, art direction | ~6 months |
| **Alpha** | Qi Refining → Deity Transformation (Hóa Thần), the Way (Đạo) | All five crafts rough; changing spiritual roots; full history generation; local/API settings | ~13 months |
| **Full Vision** | 1-2 provinces, full content | Polish, Vietnamese / Chinese / English localization, Steam release | 18-24 months |

---

## Next Steps

- [ ] **Prototype the cultivation system** (`/prototype` — revised hypothesis in `prototypes/dao-engine-concept/PIVOT-NOTE.md`; paper / spreadsheet sim first)
- [ ] If the prototype PROCEEDS: author the art bible (`/art-bible`)
- [ ] Validate the concept (`/design-review design/gdd/game-concept.md`)
- [ ] Decompose concept into systems (`/map-systems`)
- [ ] Design each system (`/design-system [system-name]`) — spiritual root (linh căn), realms (cảnh giới), spirit herbs (linh thảo) + alchemy (luyện đan) first
- [ ] Build vertical slice in Pre-Production (`/vertical-slice`)
- [ ] Validate core loop with playtest (`/playtest-report`)
- [ ] Plan first milestone (`/sprint-plan new`)
