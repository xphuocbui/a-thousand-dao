# Game Concept: Ten Thousand Daos

*Created: 2026-11-02*
*Status: Draft*

---

## Elevator Pitch

> It's a cultivation roguelite where you compose your own Dao — drafting and
> fusing insight fragments into a combo engine — across one cultivator's life in
> a freshly generated world with centuries of history, while an LLM storyteller
> narrates the world's reaction to the path you forged.

---

## Core Identity

| Aspect | Detail |
| ---- | ---- |
| **Genre** | Roguelite build-crafter; xianxia/wuxia cultivation; turn-based map adventure |
| **Platform** | PC (Steam / Epic) |
| **Target Audience** | Theory-crafting Achievers first, Storytellers/Creators second (see Target Player Profile) |
| **Player Count** | Single-player |
| **Session Length** | 60–120 min per run (one life); natural stops at each realm breakthrough |
| **Monetization** | Premium (not yet decided) |
| **Estimated Scope** | Large (18–24 months, solo) |
| **Comparable Titles** | Slay the Spire, Balatro, Tale of Immortal, Crusader Kings III |

---

## Core Fantasy

You rise from a nameless cultivator to someone the heavens fear — and you do it
with a Dao no one has walked before. There are no classes: the technique you
forge from fragments found in ruins, duels and enlightenments is yours, it gets a
name, and the world remembers it. The emotional promise is the moment the build
comes together and breaks the game open, in a way you designed and can prove.

---

## Unique Hook

It's like *Balatro*'s combo-engine build-crafting, **and also** each run is a
whole cultivator's life whose story — events, quests, rivals, outcomes — is
written live by an LLM game master, bounded by the engine's rules and a world
database, so your Dao gets a name, a legend and consequences.

It's also like *Dwarf Fortress* adventure mode, **and also** a roguelite: every
life begins in a world that already has a history — fallen sects, legendary
cultivators, lost techniques — and you can go to any node and talk to anyone,
with the LLM voicing people who actually exist in that history.

The hook affects gameplay, not just presentation: the LLM generates the events
and quests the player routes through, and authors in-budget rewards and
opponents that feed directly back into the build.

---

## Player Experience Analysis (MDA Framework)

### Target Aesthetics (What the player FEELS)

| Aesthetic | Priority | How We Deliver It |
| ---- | ---- | ---- |
| **Sensation** (sensory pleasure) | 6 | Ink-wash art, guqin-led audio, satisfying chain-trigger feedback |
| **Fantasy** (make-believe, role-playing) | 4 | Cultivation power fantasy; nobody-to-overpowered arc within one life |
| **Narrative** (drama, story arc) | 5 | Emergent per-run chronicle written by the LLM from recorded world facts |
| **Challenge** (obstacle course, mastery) | 2 | Tribulations as hard build checks; Heaven's Wrath difficulty levels; route optimisation under time scarcity |
| **Fellowship** (social connection) | N/A | Single-player; sharing builds and legends happens outside the game |
| **Discovery** (exploration, secrets) | 3 | Fusion recipes to uncover, each world's generated history and legends, lost techniques, forbidden fragments |
| **Expression** (self-expression, creativity) | 1 | No classes; a self-composed, named Dao every run |
| **Submission** (relaxation, comfort zone) | 7 | Turn-based, no reflex pressure; "one more season" absorption |

*Rationale:* the player ranked self-expression first and challenge/mastery a
close second; the cultivation fantasy is the wrapper that makes both feel
meaningful. Discovery ranks above Fantasy because each life's generated world
history (inspired by Dwarf Fortress adventure mode) is a new place to uncover.

### Key Dynamics (Emergent player behaviors)

- Players theory-craft fragment chains on paper and test them, run after run.
- Players reroute their season plan around a single missing combo piece.
- Players push a build past "strong" into "absurd" to see what breaks.
- Players share their named Dao and its LLM-written legend as screenshots.
- Players trade time against power — spending seasons cultivating versus exploring.
- Players dig into a world's history to find lost techniques, and seek out the people who hold them.

### Core Mechanics (Systems we build)

1. **Dao composition** — draft 1-of-N insight fragments; fuse two fragments into a stronger one by tag rules; fragments trigger each other in chains (engine-building).
2. **Life-run on a province map** — season-by-season travel between nodes with a lifespan clock; realms as acts, Heavenly Tribulations as boss checks.
3. **Stat-check conflict resolution** — the engine runs both sides' trigger chains with dice and produces an inspectable log.
4. **Bounded LLM game master** — generates events, quests, NPC dialogue and narration from the world database; may author numbers only inside engine-set budgets, which the engine clamps and records.
5. **World generation with history** — before each life, world-gen simulates a few centuries in seconds (sects founded and destroyed, wars, deaths, artifacts and techniques lost) and writes the result to the world database that seeds the LLM.
6. **Living world tick** — at each season's end, sects and named NPCs take abstract actions (expand, feud, die, break through, hunt a treasure); the world changes whether or not the player is there.
7. **Meta-progression** — Dao Codex and karmic carryover across lives.

---

## Player Motivation Profile

### Primary Psychological Needs Served

| Need | How This Game Satisfies It | Strength |
| ---- | ---- | ---- |
| **Autonomy** (freedom, meaningful choice) | No classes; the player composes their own Dao and chooses their own route through the map | Core |
| **Competence** (mastery, skill growth) | Transparent, inspectable numbers; tribulations as clear tests; the payoff when a combo detonates | Core |
| **Relatedness** (connection, belonging) | Named masters, rivals and debts persist in the world database and return in the story | Supporting |

### Player Type Appeal (Bartle Taxonomy)

- [x] **Achievers** (goal completion, collection, progression) — How: Dao Codex completion, Heaven's Wrath levels, ascending with every root Dao
- [x] **Explorers** (discovery, understanding systems, finding secrets) — How: fusion recipes, map nodes, forbidden fragments, understanding the trigger system deeply
- [ ] **Socializers** (relationships, cooperation, community) — How: only indirectly, via sharing builds and legends
- [ ] **Killers/Competitors** (domination, PvP, leaderboards) — How: not served

Quantic Foundry: primary **Strategy + Completion**, secondary **Fantasy + Design**.

### Flow State Design

- **Onboarding curve**: the first life starts with a small, curated fragment pool and a short realm; the first fusion and the first chain trigger are guaranteed within the first 10 minutes.
- **Difficulty scaling**: each realm's tribulation scales; Heaven's Wrath levels add modifiers after a first ascension.
- **Feedback clarity**: the live chain preview recomputes on every draft and fusion; the conflict log shows every trigger and roll.
- **Recovery from failure**: death ends the life but yields karmic carryover and a chronicle entry; a new life starts immediately, and failures are explainable from the log.

---

## Core Loop

### Moment-to-Moment (30 seconds)

A choice that reshapes the machine: draft one insight from three, or fuse two
fragments. The chain preview recomputes instantly ("Ember Breath → triggers
Scorched Meridian ×2 → …"), so every pick gives numeric feedback on how much
stronger or stranger the build just became. Satisfying because it is fast,
legible and has a high skill ceiling.

### Short-Term (5-15 minutes)

One season: travel to any reachable node on the province map (sect, market,
ruin, secret realm, a rival's cave) — there is no fixed path. Talk to anyone
there; the LLM voices NPCs from their world-database records, and quests come
from people and world state rather than a script. The LLM generates events
grounded in the database; the player picks a response; the engine resolves it
with a stat check; the LLM narrates the outcome. Rewards — fragments, spirit
stones, relationships, grudges — feed back into the build. Then spend time
cultivating (fuse/upgrade) or move on, while lifespan ticks down. At season's
end the living world ticks: sects and NPCs act on their own. "One more season"
lives here: the next node might hold the missing combo piece.

### Session-Level (30-120 minutes)

One life. It opens with world generation (a fresh world with its own history)
and an origin pick — born into a sect, a clan, or as nobody. Realms are acts — Qi Condensation → Foundation Establishment → Core
Formation → Nascent Soul — each ending in a Heavenly Tribulation that checks the
whole build. Breakthroughs are natural stopping points. The run ends in ascension
or death; either way the Dao is named and entered into the chronicle — the reason
to come back.

### Long-Term Progression

- **Dao Codex** records every fusion discovered.
- **Karmic carryover** grants a small inheritance to the next life.
- **A new world each life** — every life generates a fresh world with its own history, so the map, sects and legends are never the same twice.
- **Heaven's Wrath** difficulty levels after first ascension.
- The game is "done" when the player has broken the heavens with every root Dao.

### Retention Hooks

- **Curiosity**: undiscovered fusions, forbidden fragments, what history the next world will hold
- **Investment**: the Codex, karmic carryover, named Daos in the chronicle
- **Social**: sharing named Daos and absurd builds (outside the game)
- **Mastery**: Heaven's Wrath levels, ascending with every root, proving a theory-crafted chain works

---

## Game Pillars

### Pillar 1: Your Dao, Your Name
Every run produces a technique that is unmistakably the player's own.

*Design test*: If we're debating between an option that creates more distinct builds and one that is easier to balance, this pillar says we choose **more distinct builds**.

### Pillar 2: Every Number Is Bounded and Visible
The LLM may author numbers (rewards, NPC strength, prices, item stats) only inside a budget the engine sets for the current realm, rarity tier and event type; the engine validates, clamps and records the value in the world database, after which it is canonical and inspectable like any other number. The LLM narrates resolved outcomes and never rewrites one after the fact.

*Design test*: If the LLM wants to introduce a number, the engine supplies the range, clamps and logs it — and if a number has no budget yet, **we define one before the LLM may use it**.

*Rationale:* storytelling sometimes needs invented numbers ("a 300-year ginseng worth 40 spirit stones"); bounding them preserves theory-crafting.

### Pillar 3: Break the Heavens
Builds are allowed to become absurdly strong; the balance goal is that every path can break the game, not that nothing breaks.

*Design test*: If a dominant combo is found, we **buff the weak paths before nerfing the strong one**.

### Pillar 4: Every Season Counts
Time and lifespan are scarce; the route matters as much as the build.

*Design test*: If an action costs no time or resources, we **give it a cost or cut it**.

### Pillar 5: A World That Remembers
Stories grow from recorded facts — people, places, items and history in the world database. The world has a history before the player arrives and keeps acting while they travel.

*Design test*: If the LLM wants to introduce something new, we **prefer a callback to an existing entity; anything new must be registered in the database first**.

*Intended tensions:* Pillar 1 pulls against Pillar 2 (wild expression vs. provable math); Pillar 3 pulls against Pillar 4 (unlimited power vs. scarce time).

### Anti-Pillars (What This Game Is NOT)

- **NOT reflex or action combat**: outcomes come from the build, not hand speed — it would compromise *Every Number Is Bounded and Visible*.
- **NOT an unbounded LLM**: the LLM never creates numbers outside a budget, changes game rules, or alters a recorded value — it would compromise *Every Number Is Bounded and Visible*.
- **NOT predefined classes or fixed skill trees**: they would compromise *Your Dao, Your Name*.
- **NOT a granular world simulation (Dwarf Fortress or CK scale)**: history is generated at world creation, and the living world ticks once per season with abstract faction and NPC actions — no per-tick body, economy or pathing simulation. Anything deeper would pull focus from the build and break first-game scope — compromising *Your Dao, Your Name* and *Every Season Counts*.

---

## Visual Identity Anchor

*Proposed during concept (art-director review skipped in Lean mode); `/art-bible` refines it.*

**Direction: Ink and Ledger** — ink-wash (*shuimo*) 2D illustration for the world and map, paired with crisp, ledger-clean UI for the numbers.

**Visual rule:** The world is brushed; the math is printed. Nothing mechanical is ever hidden in the art.

**Supporting principles:**
1. **The map is a scroll.** The province map unrolls as it is explored. *Design test:* a new map feature is drawn as part of the scroll, not as a floating overlay.
2. **Glyphs, not paintings.** Fragment icons are built from a compositable glyph-and-element system. *Design test:* a new fragment needs no new hand-painted asset to ship.
3. **Numbers in print.** Every mechanical value uses the clean UI layer, never brushwork. *Design test:* if a value is only legible in the illustration, move it to the UI.

**Colour philosophy:** Colour is earned. Ink black on rice paper by default; elemental colours (fire vermilion, water indigo, wood jade, metal gold, earth ochre) appear as the player's Dao grows, so a late-run screen visibly reflects the build.

---

## Inspiration and References

| Reference | What We Take From It | What We Do Differently | Why It Matters |
| ---- | ---- | ---- | ---- |
| Balatro | Combo-engine scaling; numbers that go absurd | Engine lives inside a cultivator's life with a map and story | Validates that legible numeric escalation is the fun |
| Slay the Spire | Act structure, draft-1-of-N, boss checks | Realms and tribulations; fusion instead of card removal | Validates a clean, balanceable run structure |
| Backpack Battles / Path of Exile | Build as the test; deep synergy spaces | Player-composed Dao with a name and lore | Validates theory-crafting audiences |
| Crusader Kings II/III | Emergent character story from systems | One life per run, LLM-narrated, roguelite-sized | Validates emergent narrative as a hook |
| Tale of Immortal / Amazing Cultivation Simulator | The cultivation fantasy and setting | Tight roguelite design instead of sprawling sim | Validates a large audience for cultivation games |
| Dwarf Fortress (adventure mode) | Generated world history and legends; go anywhere, talk to anyone | Abstract seasonal world tick; roguelite structure; LLM conversation instead of menus | Validates generated history as a source of emergent stories |
| Europa Universalis IV | Map-based strategic planning, min-maxing | Personal scale — one cultivator, not a nation | Matches the creator's and target player's taste |

**Non-game inspirations**: xianxia web novels (cultivation realms, tribulations, the overpowered-protagonist arc); wuxia film; Chinese ink-wash painting and scroll maps; guqin music.

---

## Target Player Profile

| Attribute | Detail |
| ---- | ---- |
| **Age range** | 18-40 |
| **Gaming experience** | Mid-core to hardcore |
| **Time availability** | 60-120 minute sessions; can stop at realm breakthroughs |
| **Platform preference** | PC |
| **Current games they play** | Slay the Spire, Balatro, Europa Universalis IV, Crusader Kings III, Dwarf Fortress, Tale of Immortal |
| **What they're looking for** | Deep, provable build-crafting inside a cultivation fantasy, with stories that differ every run |
| **What would turn them away** | Reflex combat, hidden or arbitrary numbers, an LLM that contradicts the rules, samey events |

---

## Technical Considerations

| Consideration | Assessment |
| ---- | ---- |
| **Recommended Engine** | Godot — the developer's stated preference; `/setup-engine` pins the version (reference: 4.7) and checks APIs |
| **Key Technical Challenges** | Local-LLM integration (inference server over HTTP or native extension); structured, schema-constrained LLM output; engine-side budgets, validation and clamping; world database design; world generation with history; seasonal living-world tick; deterministic chain resolution |
| **Art Style** | 2D ink-wash illustration + clean UI |
| **Art Pipeline Complexity** | Medium (custom 2D; compositable glyph system for fragment icons) |
| **Audio Needs** | Moderate (guqin-led ambient music, UI/chain-trigger SFX) |
| **Networking** | None for gameplay; optional HTTPS to an LLM API provider |
| **Content Volume** | 4 realms + tribulations; ~250 fragments across 5 elemental roots plus forbidden ones; ~30 map-node types; ~40 opponent archetypes; 1-2 provinces; 6-10 Heaven's Wrath levels; 40+ hours to master |
| **Procedural Systems** | World generation with centuries of history per life; seasonal living-world tick; LLM-generated events, quests, dialogue and narration; procedural map layout per life; rule-based (tag) fusion results |

---

## Risks and Open Questions

### Design Risks
- Fusion combinatorics: hand-authored pairs would explode content — fusions must be tag-rule-based.
- LLM events may feel samey after ~20 runs.
- Stat-check resolution may feel passive unless the chain log is readable and exciting.
- Open-ended freedom (go anywhere, talk to anyone) pulls against season pressure (*Every Season Counts*); talking may need a time cost.

### Technical Risks
- Local-model latency and quality on mid-range GPUs — a season cannot take 20 seconds to narrate.
- Reliable structured output from the LLM (JSON schema or grammar-constrained decoding).
- Licensing for redistributing model weights.
- Generated history must stay coherent enough for the LLM to build on without contradicting it.
- Feasibility not assessed by technical-director (TD-FEASIBILITY skipped — Lean mode).

### Market Risks
- The core cultivation audience is largely Chinese-speaking — Chinese localization matters early.
- Steam requires disclosure of AI-generated content, including guardrails for live-generated content.

### Scope Risks
- An LLM system plus a combo engine is a lot for a first game.
- World generation plus a living world is the largest addition to scope; both are kept abstract (no granular simulation) to protect the 18-24 month estimate.
- Scope not assessed by producer (PR-SCOPE skipped — Lean mode).
- Mitigation: the MVP tests both together, and a templated-narration fallback limits the downside.

### Open Questions
- Is fusion fully tag-rule-based, or tags plus a small set of authored "named" fusions? — answer in `/prototype`.
- What is the latency budget per season before pacing breaks? — answer with an LLM harness spike.
- Which local model size gives acceptable quality at mainstream VRAM? — benchmark during the spike.
- How are LLM number budgets defined per realm, rarity tier and event type? — answer in the GDD for the LLM game master.

---

## MVP Definition

**Core hypothesis**: Drafting and fusing fragments into a Dao engine, then watching the engine resolve a clash that the LLM narrates, makes players want one more season and one more life.

**Required for MVP**:
1. One realm (Qi Condensation) ending in one tribulation
2. ~30 fragments with tag-based triggers, fusion rules and a live chain preview
3. 8-10 node map with a season/lifespan clock
4. Stat-check conflict resolution with an inspectable log
5. LLM harness: event generation and narration via a local model, with engine-set number budgets, clamping and a minimal world database
6. Templated-narration fallback so the game runs without the LLM (also makes tests deterministic)
7. Minimal world generation: one province, ~3 sects, ~20 named NPCs, ~100 years of generated history, written to the world database the LLM reads

**Explicitly NOT in MVP** (defer to later):
- Dao Codex, karmic carryover
- Living-world season tick (vertical slice)
- Heaven's Wrath difficulty levels
- Realms 2-4
- Final art and audio
- LLM API provider option

### Scope Tiers (if budget/time shrinks)

| Tier | Content | Features | Timeline |
| ---- | ---- | ---- | ---- |
| **MVP** | 1 realm, ~30 fragments, 1 small generated province | Core loop + LLM harness + minimal world-gen | ~2 months |
| **Vertical Slice** | 2 realms | + Living-world tick, Codex, NPC memory, quests, carryover, art direction | ~5 months |
| **Alpha** | 4 realms, ~150 fragments | All features rough; full history generation; Heaven's Wrath; local/API settings | ~12 months |
| **Full Vision** | ~250 fragments, 1-2 provinces | Polish, Chinese localization, Steam release | 18-24 months |

---

## Next Steps

- [ ] Configure the engine (`/setup-engine`) — Godot preferred
- [ ] **Prototype core idea** (`/prototype dao-engine`) — the fusion/chain loop and an LLM harness spike, before writing GDDs
- [ ] If prototype PROCEEDS: author the art bible (`/art-bible`)
- [ ] Validate the concept (`/design-review design/gdd/game-concept.md`)
- [ ] Decompose concept into systems (`/map-systems`)
- [ ] Design each system (`/design-system [system-name]`) — use prototype learnings in Tuning Knobs and Formulas sections
- [ ] Build vertical slice in Pre-Production (`/vertical-slice`)
- [ ] Validate core loop with playtest (`/playtest-report`)
- [ ] Plan first milestone (`/sprint-plan new`)
