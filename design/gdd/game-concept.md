# Game Concept: Ten Thousand Daos

*Created: 2026-11-02*
*Revised: 2026-11-02 — pivot after the first concept prototype (see `prototypes/dao-engine-concept/REPORT.md` and `PIVOT-NOTE.md`)*
*Status: Draft*

> **Terminology:** cultivation concepts use Vietnamese Hán-Việt terms (linh căn, Trúc Cơ, pháp bảo…),
> with an English gloss on first use. Crafting artifacts is *luyện chế pháp bảo*, to avoid a clash
> with the realm *Luyện Khí*.

---

## Elevator Pitch

> It's a cultivation roguelite where you live one cultivator's life — born with a linh căn
> (spiritual root) that shapes everything — and build your own engine of linh thảo (spirit herbs),
> đan dược (pills), pháp bảo (artifacts) and trận pháp (formations) to break through each cảnh giới
> (realm) and fight beyond your realm, in a freshly generated world whose stories an LLM tells
> within the engine's rules.

---

## Core Identity

| Aspect | Detail |
| ---- | ---- |
| **Genre** | Systemic tu tiên (cultivation) life sim × roguelite; turn-based |
| **Platform** | PC (Steam / Epic) |
| **Target Audience** | Systems-minded planners and min-maxers who love cultivation fiction (see Target Player Profile) |
| **Player Count** | Single-player |
| **Session Length** | 60–120 min per life; natural stops at breakthroughs |
| **Monetization** | Premium (not yet decided) |
| **Estimated Scope** | Large (18–24 months, solo) |
| **Comparable Titles** | Tale of Immortal, Amazing Cultivation Simulator, Dwarf Fortress (adventure mode), Crusader Kings III |

---

## Core Fantasy

From phàm nhân (mortal) to someone the heavens fear — not through talent, but through an engine you
designed. You read your linh căn, choose what to plant, refine and forge, survive the lean early
years, and the plan compounds until a Trúc Cơ cultivator with the right pháp bảo and trận pháp can
kill a Kết Đan elder. The power is yours because you built it, and you can explain exactly why it
works.

---

## Unique Hook

It's like *Tale of Immortal*'s cultivation world, **and also** a tight roguelite whose power comes
from a crafting and cultivation economy you build — where your linh căn decides which engine you can
build, and an LLM tells the life you lived using numbers the engine owns.

It's also like *Dwarf Fortress* adventure mode: every life begins in a world that already has a
history — fallen sects, legendary cultivators, lost công pháp — and you can go to any node and talk
to anyone, with the LLM voicing people who actually exist in that history.

The hook is systemic, not cosmetic: linh căn, công pháp, crafts and realms are interlocking rules,
and the LLM generates events, quests and people the player routes through, inside engine-set budgets.

---

## Player Experience Analysis (MDA Framework)

### Target Aesthetics (What the player FEELS)

| Aesthetic | Priority | How We Deliver It |
| ---- | ---- | ---- |
| **Sensation** (sensory pleasure) | 6 | Ink-wash art, guqin-led audio, the satisfaction of a harvest or a breakthrough |
| **Fantasy** (make-believe, role-playing) | 4 | Phàm nhân to immortal; vượt cấp (fighting beyond your realm) through what you built |
| **Narrative** (drama, story arc) | 5 | Emergent per-life chronicle written by the LLM from recorded world facts |
| **Challenge** (obstacle course, mastery) | 2 | Planning under thọ nguyên (lifespan) pressure; bình cảnh (bottlenecks); tribulations; degenerate-proof economy |
| **Fellowship** (social connection) | N/A | Single-player; sharing builds and lives happens outside the game |
| **Discovery** (exploration, secrets) | 3 | Biến dị linh căn, recipes, công pháp combinations, each world's history, bí cảnh |
| **Expression** (self-expression, creativity) | 1 | Every life a different linh căn, công pháp set and engine; no classes |
| **Submission** (relaxation, comfort zone) | 7 | Turn-based, no reflex pressure; tending an engine season after season |

*Rationale:* the developer ranked self-expression first and challenge/mastery a close second; the
first prototype showed that expression only matters when it happens *inside a system* the player
understands and exploits. Discovery ranks above Fantasy because each life's linh căn, biến dị and
world history are new things to uncover.

### Key Dynamics (Emergent player behaviors)

- Players read their linh căn and plan an engine around it ("Hỏa + Mộc with a Đan Hỏa biến dị — I'm an alchemist this life").
- Players invest now for a breakthrough decades away ("plant this herb now; in 30 years it's the Kết Đan bottleneck").
- Players with many-element roots plan how to survive and fund the slow early years before the crossover.
- Players set up vượt cấp fights deliberately, stacking pháp bảo, trận pháp and phù lục.
- Players trade surplus đan dược for linh thạch to buy what their linh căn can't make.
- Players hunt rare treasures and bí thuật to change their linh căn.
- Players dig into a world's history to find lost công pháp and the people who hold them.

### Core Mechanics (Systems we build)

1. **Linh căn (spiritual root)** — a set of elements (Kim, Mộc, Thủy, Hỏa, Thổ), each with a độ tinh khiết (purity), plus any biến dị linh căn (mutated roots; about 30, formed by rule from element combinations). More elements is better late and slower early, with fast crossovers (see Linh Căn below). Can change during a life, rarely.
2. **Cảnh giới and bình cảnh (realms and bottlenecks)** — Luyện Khí (tầng 1–13) → Trúc Cơ → Kết Đan → Nguyên Anh → Hóa Thần, each major realm with sơ / trung / hậu kỳ / đại viên mãn. Roughly 10× power per major realm. Every major breakthrough needs specific resources; each realm extends thọ nguyên.
3. **The building system** — linh thảo that gain value with age → luyện đan (alchemy) → đan dược; luyện chế pháp bảo (refined and nourished over years); linh thú / linh trùng (bred in numbers); phù lục (talismans); trận pháp (formations). Crafting affinity comes from linh căn.
4. **Công pháp (cultivation methods) — the Dao folded in** — found and combined, compatible (or not) with your linh căn; they set cultivation speed and the thần thông (divine abilities) you gain.
5. **Combat as a test of what you built** — tu vi (cultivation base) × assets (pháp bảo, trận pháp, phù lục, swarm size), resolved by the engine and fully inspectable, then narrated by the LLM. Vượt cấp is only possible through what you built.
6. **World generation with history** — before each life, world-gen simulates a few centuries in seconds (sects founded and destroyed, wars, deaths, artifacts and công pháp lost) and writes the result to the world database that seeds the LLM.
7. **Living world tick** — at each season's end, sects and named NPCs take abstract actions (expand, feud, die, break through, hunt a treasure); the world changes whether or not the player is there.
8. **Bounded LLM game master** — generates events, quests, NPC dialogue and narration from the world database; may author numbers only inside engine-set budgets, which the engine clamps and records.
9. **Meta-progression** — a Codex of discovered recipes and biến dị, and karmic carryover across lives.

---

## Linh Căn (Spiritual Root) System

*Draft values; the GDD tunes them.*

### Tiers — more elements is better

| Tier | Elements | Rarity |
| ---- | ---- | ---- |
| Đơn linh căn | 1 | Common |
| Song linh căn | 2 | Uncommon |
| Tam linh căn | 3 | Rare |
| Tứ linh căn | 4 | Very rare |
| Ngũ Hành linh căn | 5 | Legendary |

Why more is better, through rules rather than a flat bonus: each element owned unlocks its công
pháp and crafts; each tương sinh (generating) pair inside the root (Mộc→Hỏa→Thổ→Kim→Thủy→Mộc) speeds
cultivation, and a full five-element cycle closes the loop for the largest bonus; every pair is a
chance at biến dị.

### Trade-off — slower early, better late, fast crossovers

Relative cultivation speed vs. Đơn linh căn at the same stage:

| | LK 1–4 | LK 5–9 | LK 10–13 | TC sơ | TC trung | TC hậu | TC đvm | KĐ sơ | KĐ trung | KĐ hậu | NA sơ |
|---|---|---|---|---|---|---|---|---|---|---|---|
| Song (2) | 0.6 | 0.7 | 0.8 | 0.9 | **1.0** | 1.3 | 1.6 | 2.0 | 2.4 | 2.8 | 3.5 |
| Tam (3) | 0.5 | 0.6 | 0.75 | 0.9 | **1.0** | 1.4 | 1.8 | 2.3 | 2.8 | 3.4 | 4.5 |
| Tứ (4) | 0.4 | 0.5 | 0.6 | 0.75 | 0.9 | **1.0** | 1.5 | 2.1 | 2.8 | 3.6 | 5 |
| Ngũ (5+) | 0.3 | 0.4 | 0.5 | 0.6 | 0.75 | 0.85 | 0.95 | **1.0** | 1.8 | 2.8 | 6+ |

Parity: 2–3 elements at Trúc Cơ trung kỳ, 4 at Trúc Cơ hậu kỳ, 5+ at Kết Đan sơ kỳ; each further
element pushes parity about one sub-stage later, and growth after parity is steep. A many-element
root must survive and fund a slow Luyện Khí and Trúc Cơ through its crafts, caution and engine.

### Biến dị linh căn — formed by rule

**First order (two base elements).** Tương sinh pairs give stable, nurturing mutations; tương khắc
(overcoming) pairs give volatile, aggressive ones.

| Tương sinh pair | Biến dị | Tương khắc pair | Biến dị |
|---|---|---|---|
| Mộc + Hỏa | Quang (light) | Kim + Mộc | Phong (wind) |
| Hỏa + Thổ | Dung Nham (lava) | Mộc + Thổ | Độc (poison) |
| Thổ + Kim | Trọng (gravity) | Thổ + Thủy | Ám (darkness) |
| Kim + Thủy | Băng (ice) | Thủy + Hỏa | Vụ (mist, illusion) |
| Thủy + Mộc | Sinh Mệnh (life) | Hỏa + Kim | Lôi (thunder) |

**Higher order (biến dị combine further; rarer, stronger).**

| Combat | Crafting | Esoteric | Apex |
|---|---|---|---|
| Phong + Kim → Kiếm (sword) | Hỏa + Sinh Mệnh → Đan Hỏa (luyện đan) | Ám + Sinh Mệnh → Hồn (soul: thần thức, khôi lỗi, linh thú) | Âm + Dương → Thái Cực |
| Lôi + Quang → Thiên Lôi | Thổ + Sinh Mệnh → Linh Thực (linh thảo) | Vụ + Ám → Huyễn (illusion) | Không Gian + Luân Hồi → Thời Gian (time) |
| Dung Nham + Lôi → Hủy Diệt | Kim + Dung Nham → Tinh Kim (pháp bảo) | Quang + Ám → Tinh Thần (stars) | All five base elements → Hỗn Độn (chaos) |
| Sinh Mệnh + Độc → Huyết (blood) | Trọng + Thổ → Trận (trận pháp) | Trọng + Phong → Không Gian (space) | |
| Ám + Độc → Tử (death) | | Băng + Ám → Âm (yin); Quang + Dung Nham → Dương (yang) | |
| | | Sinh Mệnh + Tử → Luân Hồi (reincarnation) | |

Names and pairings are drafts. **Open question:** do biến dị count as extra elements for the tier
curve (e.g. Ngũ Hành + Lôi = 6)?

### Changing linh căn

Linh căn can change during a life, but rarely: rare treasures or bí thuật can add an element, raise
purity or trigger a biến dị — making the root a long-term build goal as well as a starting condition.

---

## Cảnh Giới (Realm) Ladder

| Cảnh giới | Sub-stages | Thọ nguyên (design value) | Power vs. realm below |
|---|---|---|---|
| Luyện Khí | tầng 1–13 | ~120 years | a mortal stands no chance |
| Trúc Cơ | sơ / trung / hậu kỳ / đại viên mãn | ~200 | ~10× |
| Kết Đan | same | ~500 | ~10× |
| Nguyên Anh | same | ~1000 | ~10× |
| Hóa Thần | same | ~2000 | ~10×; ceiling of Nhân giới (mortal world) |
| Luyện Hư → Hợp Thể → Đại Thừa → Độ Kiếp | — | — | Linh giới (spirit world); later scope |

Vượt cấp is normally impossible; achieving it through pháp bảo, trận pháp, phù lục and swarms is the
min-max fantasy. Each major breakthrough has a bình cảnh that needs specific resources.

---

## Character Stats

*Summary; the full design (formulas, ranges, edge cases) gets its own GDD (`/design-system character-stats`) after `/map-systems`.*

Every stat is a visible number. Innate stats are the hand you're dealt; power comes from what you
build with them (*Power Is Built, Not Given*).

### Layer 1 — Thiên phú (innate; set at birth, changes rarely)

Scale 1–100 with grade bands: **Hạ** 1–30 · **Trung** 31–60 · **Thượng** 61–85 · **Cực phẩm** 86–99 · **Thiên** 100.

| Stat | Meaning | Drives |
|---|---|---|
| **Linh căn** | Purity per element (Kim · Mộc · Thủy · Hỏa · Thổ; 0 = absent) + biến dị with derived purity (e.g. geometric mean of parents × 0.8) | Element count and its curve; cultivation speed with matching công pháp; craft affinity |
| **Ngộ tính** (comprehension) | How fast you understand | Learning công pháp, đốn ngộ (enlightenment), discovering recipes and biến dị, breaking bình cảnh |
| **Căn cốt** (physique) | Body foundation | Khí huyết, đan độc resistance, body-cultivation công pháp |
| **Thần hồn** (soul strength) | Base of spiritual sense | Thần thức: pháp bảo control count, swarm size, trận pháp complexity, detection |
| **Khí vận** (fortune) | Luck | Kỳ ngộ, rare finds, crafting crits, and the ceiling of LLM-invented reward budgets |
| **Đạo tâm** (Dao heart) | Willpower | Resisting tâm ma, tẩu hỏa nhập ma and illusions at breakthroughs and tribulations |
| **Mị lực** (presence) | How people take to you | NPC attitude, prices, recruitment, what LLM-voiced NPCs will share |

**Birth modes:**
- **Thiên Định (rolled)** — thiên phú are rolled at birth; achievements and Codex progress are enabled.
- **Tự Định (chosen)** — the player sets thiên phú freely for a casual run; achievements are disabled.

### Layer 2 — Tu vi state (changes every season)

Cảnh giới and tu vi progress (e.g. Trúc Cơ sơ kỳ 3,420 / 5,000) · thọ nguyên (age / max) · linh lực
(realm × công pháp) · thần thức (Thần hồn × realm) · khí huyết (Căn cốt × realm) · **đan độc** (pill
toxicity 0–100: builds with each pill, weakens pills, must be purged — the brake on eating your way
up) · **tâm ma** (heart demon 0–100: builds from killing, failed breakthroughs and broken oaths;
tested against Đạo tâm at every breakthrough).

### Layer 3 — Đạo nghệ and Chiến lực (built by doing)

- **Đạo nghệ (craft skills)** rise only through practice: Linh Thực, Đan Đạo, Khí Đạo, Trận Đạo, Phù Đạo, Ngự Thú; ranks Nhất phẩm → Cửu phẩm, each multiplied by its element affinity.
- **Chiến lực (combat power)** is never raised directly: it is computed from realm, linh lực, công pháp, thần thông, pháp bảo, trận pháp, phù lục and swarm, and always shown as a breakdown.

### Draft formulas

- Cultivation per season = realm base × linh căn curve (element count, stage) × (purity of the công pháp's elements ÷ 100) × công pháp grade × (1 + Ngộ tính ÷ 200) × local linh khí density × (1 − Đan độc ÷ 200)
- Breakthrough backlash chance = max(0, Tâm ma − Đạo tâm ÷ 2)%
- LLM reward ceiling = realm budget × (0.75 + Khí vận ÷ 200)

### Example sheet

```
Lâm Vô Danh — 47 / 200 tuổi                    Trúc Cơ sơ kỳ  3,420 / 5,000
LINH CĂN  Tứ linh căn (Tam + 1 biến dị)
  Hỏa 78 Thượng   Mộc 52 Trung   Thổ 31 Trung   Kim 0   Thủy 0
  Biến dị: Quang 51 (Mộc × Hỏa)            parity at Trúc Cơ hậu kỳ · now 0.75×
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
| **Autonomy** (freedom, meaningful choice) | No classes; the player decides which engine to build from their linh căn and where to go | Core |
| **Competence** (mastery, skill growth) | Inspectable rules and numbers; long plans that visibly pay off; bình cảnh and tribulations as clear tests | Core |
| **Relatedness** (connection, belonging) | Masters, rivals, debts and trading partners persist in the world database and return in the story | Supporting |

### Player Type Appeal (Bartle Taxonomy)

- [x] **Achievers** (goal completion, collection, progression) — How: realms, the Codex of recipes and biến dị, ascending with every linh căn tier
- [x] **Explorers** (discovery, understanding systems, finding secrets) — How: biến dị rules, recipes, công pháp combinations, bí cảnh, each world's history
- [ ] **Socializers** (relationships, cooperation, community) — How: only indirectly, via sharing builds and lives
- [ ] **Killers/Competitors** (domination, PvP, leaderboards) — How: not served

Quantic Foundry: primary **Strategy + Completion**, secondary **Fantasy + Design**.

### Flow State Design

- **Onboarding curve**: the first life rolls a simple Đơn or Song linh căn and opens with one plot, one recipe and one công pháp; the first harvest, first pill and first breakthrough land within the first 15 minutes.
- **Difficulty scaling**: bình cảnh demand rarer resources each realm; tribulations scale; harder world settings after a first Kết Đan.
- **Feedback clarity**: every decision shows its projected effect (harvest value, pill yield, cultivation-speed change, combat power); the combat log shows every term.
- **Recovery from failure**: death ends the life but yields karmic carryover, Codex entries and a chronicle; a new life (new world, new linh căn) starts immediately, and failures are explainable from the log.

---

## Core Loop

### Moment-to-Moment (30 seconds)

One engine decision, with its projected effect shown immediately: which linh thảo goes in this
plot; refine this herb now or let it age; which recipe to attempt; which pháp bảo to feed linh thạch
to; which công pháp to cultivate. Satisfying because it is legible and compounding — you can see
the plan getting better.

### Short-Term (5-15 minutes)

One season: tend and harvest linh thảo, luyện đan, trade at a phường thị (market), explore a bí cảnh,
talk to anyone the LLM voices from their world-database record, take quests that come from people
and world state — or bế quan (seclusion) for years at a time. Events are resolved by the engine and
narrated by the LLM. At season's end the living world ticks and thọ nguyên counts down. "One more
season" lives here: the herb is almost old enough, the breakthrough is almost funded.

### Session-Level (30-120 minutes)

One life. World generation and the linh căn reveal, an origin pick (born into a sect, a clan, or as
nobody), surviving the slow start, the crossover moment when the engine takes off, the bình cảnh and
tribulations of each realm — ending in ascension or death. Breakthroughs are natural stopping points.

### Long-Term Progression

- **Codex** of discovered recipes and biến dị.
- **Karmic carryover** grants a small inheritance to the next life.
- **A new world and a new linh căn each life**, so no two engines are the same.
- Harder world settings after a first Kết Đan; long-term goal: reach Hóa Thần with every linh căn tier.

### Retention Hooks

- **Curiosity**: undiscovered biến dị and recipes, the next world's history, what a Ngũ Hành root can do
- **Investment**: herbs aging toward a breakthrough, pháp bảo nourished for years, the Codex
- **Social**: sharing linh căn rolls, engines and absurd vượt cấp wins (outside the game)
- **Mastery**: reaching higher realms, beating harder world settings, making a "bad" linh căn work

---

## Game Pillars

### Pillar 1: Your Dao, Your Name
Every life produces a cultivator whose linh căn, công pháp and engine are unmistakably theirs.

*Design test*: If we're debating between an option that creates more distinct builds and one that is easier to balance, this pillar says we choose **more distinct builds**.

### Pillar 2: Every Number Is Bounded and Visible
The LLM may author numbers (rewards, NPC strength, prices, item stats) only inside a budget the engine sets for the current realm, rarity tier and event type; the engine validates, clamps and records the value in the world database, after which it is canonical and inspectable like any other number. The LLM narrates resolved outcomes and never rewrites one after the fact.

*Design test*: If the LLM wants to introduce a number, the engine supplies the range, clamps and logs it — and if a number has no budget yet, **we define one before the LLM may use it**.

*Rationale:* storytelling sometimes needs invented numbers ("a 300-year linh thảo worth 40 linh thạch"); bounding them preserves planning and theory-crafting.

### Pillar 3: Power Is Built, Not Given
Power emerges from what the player constructs inside the system — linh căn, công pháp, crafts and assets — never from picking bigger numbers.

*Design test*: If we're debating between a flat stat bonus and a buildable asset, this pillar says we choose **the buildable asset**.

*Rationale:* the first prototype's stat-block fragments were rejected because "it doesn't even have a decent system".

### Pillar 4: Every Season Counts
Time and thọ nguyên are scarce; herbs age, bế quan costs years, and many-element roots start slow — the timing of the plan matters as much as the plan.

*Design test*: If an action costs no time or resources, we **give it a cost or cut it**.

### Pillar 5: A World That Remembers
Stories grow from recorded facts — people, places, items and history in the world database. The world has a history before the player arrives and keeps acting while they travel.

*Design test*: If the LLM wants to introduce something new, we **prefer a callback to an existing entity; anything new must be registered in the database first**.

*Intended tensions:* Pillar 1 pulls against Pillar 2 (wild expression vs. provable math); Pillar 3 pulls against Pillar 4 (ever-growing engines vs. scarce time).

### Anti-Pillars (What This Game Is NOT)

- **NOT stat-block card picking**: power never comes from choosing the bigger number off a list — it would compromise *Power Is Built, Not Given*.
- **NOT reflex or action combat**: outcomes come from what you built, not hand speed — it would compromise *Every Number Is Bounded and Visible*.
- **NOT an unbounded LLM**: the LLM never creates numbers outside a budget, changes game rules, or alters a recorded value — it would compromise *Every Number Is Bounded and Visible*.
- **NOT fixed classes**: linh căn shapes a build but never locks it — locking would compromise *Your Dao, Your Name*.
- **NOT a granular world simulation (Dwarf Fortress or CK scale)**: history is generated at world creation, and the living world ticks once per season with abstract faction and NPC actions — no per-tick body, economy or pathing simulation. Anything deeper would break first-game scope — compromising *Power Is Built, Not Given* and *Every Season Counts*.
- **NOT the novel's IP**: we take the cultivation-economy *systems and genre conventions* of Phàm Nhân Tu Tiên, never its characters, places, sects, plot or signature items — originality protects *Your Dao, Your Name* and the project itself.

---

## Visual Identity Anchor

*Proposed during concept (art-director review skipped in Lean mode); `/art-bible` refines it.*

**Direction: Ink and Ledger** — ink-wash (*shuimo*) 2D illustration for the world and map, paired with crisp, ledger-clean UI for the numbers.

**Visual rule:** The world is brushed; the math is printed. Nothing mechanical is ever hidden in the art.

**Supporting principles:**
1. **The map is a scroll.** The province map unrolls as it is explored. *Design test:* a new map feature is drawn as part of the scroll, not as a floating overlay.
2. **Glyphs, not paintings.** Item, herb and pháp bảo icons are built from a compositable glyph-and-element system. *Design test:* a new item needs no new hand-painted asset to ship.
3. **Numbers in print.** Every mechanical value uses the clean UI layer, never brushwork. *Design test:* if a value is only legible in the illustration, move it to the UI.

**Colour philosophy:** Colour is earned. Ink black on rice paper by default; element colours (Hỏa vermilion, Thủy indigo, Mộc jade, Kim gold, Thổ ochre) appear as the cultivator's linh căn awakens and their engine grows, so a late-life screen visibly reflects the build.

---

## Inspiration and References

| Reference | What We Take From It | What We Do Differently | Why It Matters |
| ---- | ---- | ---- | ---- |
| Phàm Nhân Tu Tiên (novel, Vong Ngữ) | The cultivation economy: linh căn, realm ladder and bình cảnh, herbs and alchemy, artifacts, beasts, talismans, formations; the mortal who wins by planning | Original world, names and items; a player-built roguelite; more-elements-is-better linh căn | The developer's anchor for "a system you build inside" |
| Tale of Immortal | Cultivation-world sandbox, realms, sects | Tight roguelite lives; an engine-building economy as the core | Validates a large audience for cultivation games |
| Amazing Cultivation Simulator | Systemic cultivation, interlocking production | One cultivator, not a colony | Validates systemic depth in the genre |
| Dwarf Fortress (adventure mode) | Generated world history and legends; go anywhere, talk to anyone | Abstract seasonal world tick; roguelite structure; LLM conversation instead of menus | Validates generated history as a source of emergent stories |
| Crusader Kings II/III | Emergent character story from systems | One life per run, LLM-narrated | Validates emergent narrative as a hook |
| Europa Universalis IV | Long-horizon planning and min-maxing an economy | Personal scale — one cultivator's engine, not a nation | Matches the creator's and target player's taste |

**Non-game inspirations**: tu tiên / xianxia novels (realms, tribulations, the mortal-to-immortal arc); wuxia film; Chinese ink-wash painting and scroll maps; guqin music.

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
| **Content Volume** | 5 base elements and ~30 biến dị; 5 realms (Luyện Khí–Hóa Thần); ~60 linh thảo, ~40 đan dược recipes, ~40 pháp bảo, ~20 linh thú/linh trùng, ~30 phù lục, ~20 trận pháp, ~40 công pháp; 1-2 provinces; 40+ hours to master |
| **Procedural Systems** | Linh căn generation; world generation with centuries of history per life; seasonal living-world tick; LLM-generated events, quests, dialogue and narration; procedural map layout per life |

---

## Risks and Open Questions

### Design Risks
- The economy may produce a degenerate strategy (one engine dominates every linh căn).
- The slow early game of many-element roots may frustrate players before the crossover.
- Open freedom (go anywhere, talk to anyone) pulls against thọ nguyên pressure; talking may need a time cost.
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
- **Top risk:** five crafting systems, world generation and an LLM is too much for a first game. Mitigation: the MVP has one craft (linh thảo + luyện đan); the rest arrive tier by tier.
- World generation plus a living world is kept abstract to protect the 18-24 month estimate.
- Scope not assessed by producer (PR-SCOPE skipped — Lean mode).

### Open Questions
- Do biến dị count as extra elements for the tier curve (e.g. Ngũ Hành + Lôi = 6)? — decide in the linh căn GDD.
- How the seven thiên phú roll (distributions, correlations, origin influence) and whether Tự Định has any limits — decide in the character-stats GDD.
- Time granularity: is a turn a season or a year, and how does bế quan for years interact with herb aging? — answer in the next prototype.
- Exact combat resolution: how tu vi and each asset type combine, and how vượt cấp becomes possible — answer in the combat GDD and prototype.
- Which local model size gives acceptable quality at mainstream VRAM? — benchmark with a real model.

---

## MVP Definition

**Core hypothesis**: If the player plans an engine shaped by their linh căn (linh thảo → đan dược → breakthrough) under thọ nguyên pressure, they will feel the compounding of their own plan — evidenced by deliberate long-term investments the player can explain, and by different linh căn leading to visibly different engines.

**Required for MVP**:
1. Character generation: thiên phú (Thiên Định roll and Tự Định choice) including linh căn element count, purity, first-order biến dị, and the slow-early / fast-crossover curve; đan độc and tâm ma
2. Luyện Khí → Trúc Cơ → Kết Đan with bình cảnh and thọ nguyên
3. Linh thảo aging + luyện đan — the only craft in the MVP
4. A handful of công pháp with linh căn compatibility
5. Combat as an asset check, with one tribulation
6. Minimal world generation: one province, ~3 sects, ~20 named NPCs, ~100 years of history
7. LLM harness (events and narration within budgets) + templated-narration fallback

**Explicitly NOT in MVP** (defer to later):
- Luyện chế pháp bảo, linh thú / linh trùng, phù lục, trận pháp
- Higher-order biến dị and changing linh căn
- Nguyên Anh and above
- Living-world season tick, Codex, karmic carryover
- Final art and audio; LLM API provider option

### Scope Tiers (if budget/time shrinks)

| Tier | Content | Features | Timeline |
| ---- | ---- | ---- | ---- |
| **MVP** | Luyện Khí → Kết Đan, 1 small province | Linh căn, herbs + alchemy, combat check, LLM harness, minimal world-gen | ~2-3 months |
| **Vertical Slice** | + Nguyên Anh | + Luyện chế pháp bảo, living-world tick, Codex, NPC memory, quests, art direction | ~6 months |
| **Alpha** | Luyện Khí → Hóa Thần, ~30 biến dị | All five crafts rough; changing linh căn; full history generation; local/API settings | ~13 months |
| **Full Vision** | 1-2 provinces, full content | Polish, Vietnamese / Chinese / English localization, Steam release | 18-24 months |

---

## Next Steps

- [ ] **Prototype the cultivation system** (`/prototype` — revised hypothesis in `prototypes/dao-engine-concept/PIVOT-NOTE.md`; paper / spreadsheet sim first)
- [ ] If the prototype PROCEEDS: author the art bible (`/art-bible`)
- [ ] Validate the concept (`/design-review design/gdd/game-concept.md`)
- [ ] Decompose concept into systems (`/map-systems`)
- [ ] Design each system (`/design-system [system-name]`) — linh căn, cảnh giới, linh thảo + luyện đan first
- [ ] Build vertical slice in Pre-Production (`/vertical-slice`)
- [ ] Validate core loop with playtest (`/playtest-report`)
- [ ] Plan first milestone (`/sprint-plan new`)
