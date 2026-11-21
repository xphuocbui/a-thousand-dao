# Codex & Karmic Carryover

> **Status**: In Design
> **Author**: user + Claude
> **Last Updated**: 2026-11-21
> **Last Verified**: 2026-11-21
> **Implements Pillar**: Pillar 5 "A World That Remembers"; Pillar 3 "Power Is Built, Not Given"
> **Creative Director Review (CD-GDD-ALIGN)**: CONCERNS (accepted) 2026-11-21 — Pillars 3 and 4: an heir successor can make death cheap (a groomed strong disciple as a spare life); tracked as Open Question 1. Player Fantasy not authored at the standard tier, so not checked.

## Summary

Codex & Karmic Carryover decides what outlives a death. A playthrough is started in one of two **modes**: **One Life**
(nhất sinh), where the first death ends the playthrough, or **Continue** (luân hồi kế thừa), where the player goes on
in the same world as a successor. Across all playthroughs a profile-level **Codex** records what the player has
discovered (recipes and variant roots, world knowledge, techniques and items, and the lives lived). Karmic carryover
gives the next life knowledge and unlocked starting options, never stat power.

> **Quick reference** — Layer: `Feature` · Priority: `Vertical Slice` · Key deps: `Save/Load, World DB, Item DB, Alchemy, Spiritual Roots, Achievements, Progression Edges, NPC Relationships, World Generation`

## Overview

Codex & Karmic Carryover is the game's meta-progression: what survives when a cultivator dies. At a new game the
player picks a **mode** for the playthrough. In **One Life** (nhất sinh) a death is final: the playthrough ends with
its epitaph and chronicle, and only the Codex and achievements remain. In **Continue** (luân hồi kế thừa) the world
goes on and so does the player, as a **successor** in the same world: the world keeps its history, the sect, the
feuds and the graves the last life left (Pillar 5, "A World That Remembers").

Behind both modes sits the **Codex** (thiên thư), a record kept on the player's profile across every playthrough. It
holds what the player has discovered: alchemy and crafting recipes and the variant roots (biến dị linh căn) seen or
owned; world knowledge of the fixed continent (secrets uncovered, hidden places, the fixed cast met and their fates,
history learned); cultivation techniques, named items, spirit beasts and herbs met; and the chronicle of every life
lived. Because the world is the same in every playthrough (World Generation, fixed world), this knowledge stays true,
and a returning player plays better because they know more, not because they start stronger.

**Karmic carryover** is what one life hands the next in Continue mode: knowledge from the Codex and unlocked starting
options, never a stat bonus (Pillar 3, "Power Is Built, Not Given"; the intended weak start and the breakthrough
targets stay untouched). The system exists so that death in a game about lifespan is a turn of the story, not only a
loss, and so the Achiever's urge to collect has a home.

## Detailed Design

### Core Rules

**Modes**

1. **A mode per playthrough.** A new game starts in one of two modes, chosen with the birth mode and fixed for the
   whole playthrough (stored in the save, shown on the save slot):
   - **One Life (nhất sinh):** the first death of the player's character ends the playthrough.
   - **Continue (luân hồi kế thừa):** a death opens the succession step (rule 4), and the playthrough goes on in the
     same world.
2. **Saves are ordinary in both modes** (user decision 2026-11-21: reload allowed). One Life only means there is no
   successor; a save made before the death can still be loaded. The Codex is not rolled back by loading (rule 7).
3. **One Life's end.** On the death the game writes the epitaph and the chronicle (as built), adds the life to the
   Codex (rule 9), marks the playthrough **ended**, and offers a new game. An ended playthrough can be read (its
   chronicle and world) but not played on.

**Succession (Continue mode)**

4. **The succession step.** When the player dies in Continue mode, the world first settles the death as it does for
   anyone: NPC Relationships rule 13 passes ties to heirs, and the estate passes by Living World Tick rule 9 (items
   and purse to `Inheritance.heir_of`, else the sect treasury or the region). Then the player chooses one successor:
   - **An heir:** any living child or disciple of the dead player (NPC Relationships kin as parent, or sư đồ as
     master). Play moves to that person as they are: their realm, build, items, ties, sect and place. Whatever the
     estate gave them, they hold (user decision 2026-11-21: normal estate rules).
   - **A rebirth (chuyển thế):** a new person, created as at a new game (birth mode, origin, roll), enters the same
     world `rebirth_years` after the death. The world ticks through those years first (Living World Tick, as the
     closed-door command does). The reborn is a stranger to the world: no ties, no estate.

   Rebirth is always offered, so a Continue playthrough never ends for lack of an heir; the player may also choose to
   end it.
5. **What the successor brings.** Every successor, heir or reborn:
   - picks one **destiny perk** (thiên mệnh) from `3 + perk_extra` rolled options in Fated birth, or any one in
     Self-made birth (Progression Edges part 1; Formulas). A perk the person already holds is not offered again;
   - has the protagonist's edge from then on: fortuitous encounters and the breakthrough bonus (Progression Edges
     parts 3 and 4), as every player life does;
   - knows what the Codex knows (rules 7–8);
   - if reborn, also receives the two starting Phá Cảnh Phù (Progression Edges part 2). An heir does not: they are
     not newly born.

   Nothing else carries: no stats, no purity, no cultivation base, no items beyond what the world's own estate rules
   hand an heir (Pillar 3; the breakthrough targets 0.70 / 0.70 / 0.30 / 0.20 are measured per life with the edge).
6. **Karma (nghiệp duyên) is per playthrough.** Each life that ends in Continue mode earns karma from what it did
   (Formulas). Karma is spent only at that playthrough's next succession, on starting options:
   - extra destiny perk options (`perk_extra`);
   - a **lineage rebirth**: a reborn may start as an outer disciple of the dead life's sect, or in its clan, if that
     sect or clan still exists (the three ordinary origins stay free).

   Unspent karma carries to the next succession of the same playthrough. Karma never crosses playthroughs and never
   exists in One Life.

**The Codex (thiên thư)**

7. **A profile record.** The Codex lives on the player's profile, outside any save (like `user://achievements.json`),
   and is shared by every playthrough of both modes. An entry is written the moment it is earned and is never
   removed: loading an older save does not undo it. Entries are keyed by authored ids, which are the same in every
   game because the world is fixed (World Generation); facts rolled per game (where a hidden place lies this time) are
   never stored as Codex truths.
8. **What it holds, and what each entry does in a life.** An entry has a level, **seen** or **known**:

   | Book | Seen when | Known when | Effect in later lives (knowledge, not possession) |
   |---|---|---|---|
   | Recipes (đan phương, khí phương, phù, trận) | A recipe is shown or found | The player crafts it once | Known: the recipe is known from the start of a life; materials, skill and the success roll are unchanged |
   | Variant roots (biến dị linh căn) | Seen on any person | Owned by the player | Seen: its description; known: its formation conditions (Spiritual Roots) |
   | World: secrets and hidden places | A rumour names it | The player enters it | Known: its lore and its 2–3 candidate sites show as rumours; which site holds it this game does not |
   | World: the fixed cast | Met | — | Their profile (name, sect, known traits) and their fates in past lives |
   | World: history | A history entry is learned | — | Readable from the start |
   | Techniques (công pháp), named items | Seen | Owned | Their requirements and description; never the thing itself |
   | Beasts and herbs | Met or found | Tamed or harvested | Their kinds, ages and uses |
   | Lives | — | A life ends | The epitaph, chronicle summary, realm, age and cause of death |

9. **Who writes the Codex.** Only Fated-birth (Thiên Định) lives that are not marked `cheated` write entries, as for
   achievements. Self-made birth and `debug` / `buildgen` lives read the Codex but add nothing. A life's Lives entry
   is written at its death in either mode.
10. **The Codex is read, not spent.** Reading it costs nothing and changes nothing in the world; it is the player's
    memory. The advisor, craft lists and map may show Codex knowledge (a known recipe in the craft list, a rumoured
    site on the map), marked as remembered.

**Achievements**

11. Achievements stay as built (earned in Fated-birth, uncheated lives, kept across lives). A successor's deeds count
    for achievements like any life's. Whether some achievements need One Life is Open Question 2.

### States and Transitions

| Thing | From | To | Trigger | Rule |
|---|---|---|---|---|
| Playthrough | — | Active (life 1) | New game: mode, birth mode, origin chosen | 1 |
| Playthrough | Active | Ended | Death in One Life; or the player ends a Continue playthrough at succession | 3, 4 |
| Playthrough | Active | Succession | Death in Continue | 4 |
| Playthrough | Succession | Active (life n + 1) | An heir chosen (play moves at once) or a rebirth chosen (after `rebirth_years` of world ticks) | 4 |
| Codex entry | none | Seen | A seeing event in a writing life | 7–9 |
| Codex entry | Seen or none | Known | A knowing event in a writing life | 7–9 |
| Karma | 0 | k | A Continue life ends | 6 |
| Karma | k | k − spent | Spent at succession | 6 |

A Codex entry never goes back down; karma never goes below 0.

### Interactions with Other Systems

| System | Direction | What passes | Owner of the interface |
|---|---|---|---|
| **Session** (death flow, built) | in / out | In: the player's death, epitaph, chronicle. Out: the mode's end or the succession step, the new player character | Session runs the flow; this GDD the rules |
| **Save / Load** (#5) | in / out | The playthrough's mode, karma and status in the save; the Codex in its own profile file, never rolled back | Save/Load (format) |
| **NPC Relationships** (#46) | in | Rule 13 runs at the death first; an heir successor keeps their own ties (answers #46 Open Question 5) | #46 |
| **Living World Tick** (#28) | in / out | The estate at the death (rule 9 there); the `rebirth_years` of ticks before a reborn enters | Tick |
| **Sects & Missions** (#26) | in | If the dead player led a sect, Sects' succession picks the new head as for anyone; an heir successor may or may not be it | Sects |
| **Progression Edges** (#11) | out | The successor's destiny perk pick (`3 + perk_extra`), the edge, a reborn's starting talismans | Progression Edges |
| **World Generation** (#27) | in | Stable authored ids; hidden places' candidate sites; origins | World Gen |
| **Item Database** (#13), **Alchemy** (#15) and the crafts | in / out | Recipes seen and crafted; a known recipe is known at the start of a life | Item DB, crafts |
| **Spiritual Roots** (#6) | in | Variant roots seen and owned; formation conditions shown | Spiritual Roots |
| **Achievements** (#32) | — | The same writing gate (Fated birth, not cheated); achievements unchanged | Achievements |
| **Guidance Layer** (#35), **Game UI** (#37) | out | Codex knowledge shown in the advisor, craft lists and the map, marked as remembered | Guidance, UI |

## Formulas

Values marked *(guess)* are first numbers for the balance pass. Realm index r: Luyện Khí 0, Trúc Cơ 1, Kết Đan 2,
Nguyên Anh 3, Hóa Thần 4.

### A. Karma earned by a life

The karma_earned formula is defined as:

`karma_earned = realm_karma[r_max] + floor(K_new / known_per_karma)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| r_max | int | 0–4 | the life | Highest realm the life reached |
| realm_karma | int | 0 / 1 / 2 / 4 / 6 by r_max | data file *(guess)* | Karma for how far the life got |
| K_new | int | ≥ 0 | the Codex | Entries this life raised to **known** that no earlier life had known (first time on the profile) |
| known_per_karma | int | 10 (safe ≥ 1) | data file *(guess)* | New known entries per point of karma |

**Output Range:** 0 upward; in practice 0 to about 12 (a Hóa Thần life that learns 60 new things). Only Continue
lives earn it (rule 6); a writing gate applies as for the Codex (rule 9: a Self-made or cheated life earns 0).
**Example:** a life dies at Trúc Cơ (1) after crafting, owning or entering 25 things new to the Codex:
1 + floor(25 / 10) = **3**.

### B. Spending karma at succession

The karma_spend formula is defined as:

`options = 3 + perk_extra` ; `perk_extra ≤ min(perk_extra_max, karma)` ; `karma_left = karma − perk_extra − lineage_cost · lineage`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| karma | int | ≥ 0 | the playthrough | Unspent karma, carried from earlier successions of this playthrough |
| perk_extra | int | 0 – `perk_extra_max` | the player's choice | Extra destiny perk options, 1 karma each |
| perk_extra_max | int | 3 | data file *(guess)* | At most 6 options, of the 8 perks |
| lineage | bool | 0 or 1 | the player's choice | A rebirth into the dead life's sect (outer disciple) or clan, if it still exists (rule 6) |
| lineage_cost | int | 3 | data file *(guess)* | Karma for a lineage rebirth |

**Output Range:** `options` 3–6; `karma_left` ≥ 0 (a spend that would go below 0 is not offered).
**Example:** with 4 karma, a rebirth into the old sect (3) plus 1 extra perk option: 4 options, 0 karma left.

### C. Rebirth gap

`rebirth_years = start_age(origin)` (16 for every origin today, `character.gd`)

The reborn is born in the season of the death and the game resumes when they reach the origin's start age, so the
world ticks `4 × rebirth_years` seasons (64) first, as the closed-door command does (Living World Tick AC-LW-40: 400
seasons within 60 s, so 64 seasons take about 10 s).

**Feedback loop.** Karma buys more perk options, a better perk can make a stronger life, and a stronger life earns more
karma. It is mild and capped: `perk_extra_max` 3, and a perk is one of the eight existing birth perks, so the loop
never adds stat power beyond what a lucky Fated roll gives.

## Edge Cases

**Succession**
- **If the player dies with no living child or disciple:** only rebirth (and ending the playthrough) is offered
  (rule 4).
- **If a child or disciple is the killer** (or the death's known killer by NPC Relationships rule 13): they are not
  offered as heir, as #46 strikes a killer from the heirs.
- **If an heir dies in the same season as the player:** candidates are read after S8b settles the season's deaths, so
  a dead heir is never offered.
- **If the dead player led a sect:** Sects' succession picks the new head as for anyone (Sects rule 15); the heir the
  player chooses may or may not be that head.
- **If the heir is in seclusion, imprisoned, injured or mid-errand:** play moves to them in that state; nothing is
  reset.
- **If the heir carries NPC traits:** they keep them, with their stat rows (NPC Traits); event behaviour driven by
  traits no longer applies, because the player now chooses their actions (Open Question 4).
- **If every destiny perk is already held by the successor:** fewer options are shown; with none left, the pick is
  skipped and any `perk_extra` karma is refunded.
- **If a lineage rebirth's sect or clan is gone when the reborn enters** (destroyed during the `rebirth_years` of
  ticks): the reborn starts as a loose cultivator (tán tu) in that region and the `lineage_cost` is refunded.
- **If a Continue life was Self-made or cheated:** a successor is still offered; that life earns no karma and writes
  no Codex entries except its Lives entry (rule 9).

**Saves and the Codex**
- **If the player loads a save from before a death:** the Codex keeps everything written since, including the Lives
  entry of the death that was undone (rule 7); karma lives in the save and goes back with it.
- **If the Codex file is missing or unreadable:** the game plays on with an empty Codex, keeps the bad file aside
  as a backup and says so once; play is never blocked by the Codex.
- **If a data update removes an authored id an entry points to:** the entry is kept but hidden; it reappears if the
  id returns.
- **If a known recipe needs a craft level the life does not have:** it shows as known and not yet usable.
- **If a hidden place was entered in an earlier game:** the Codex shows its 2–3 candidate sites, never the site it
  took this game (rule 8); finding it is still play.

**One Life**
- **If the player dies in One Life and then loads an earlier save:** allowed (rule 2); the playthrough is Active
  again in that save, and the earlier death stays in the Codex.

**Degenerate strategies**
- **Grooming a strong disciple as a spare life:** allowed for now: the heir's power was built in the world (their own
  cultivation, the player's teaching and gifts), they start without the dead player's realm, and the estate follows
  the world's rules. Whether to limit heirs by realm is Open Question 1.
- **Farming karma from the Codex:** `K_new` counts only entries known for the first time on the profile, a finite
  set, so karma from discovery runs out (Formulas A).
- **Reloading to farm Codex entries:** the set of entries is finite and entries give knowledge only; accepted.

## Dependencies

**Upstream (this system needs them)**

| System | Hard / Soft | Interface | Has GDD |
|---|---|---|---|
| Session (death flow) | Hard | The player's death, epitaph, chronicle, new game | No (built) |
| Save / Load (#5) | Hard | Mode, status and karma in the save; the Codex profile file | No (built) |
| World Database (#3) | Hard | People, kin, events, stable ids | No (built) |
| NPC Relationships (#46) | Hard | Children and disciples (heir candidates); rule 13 at the death | Yes |
| Living World Tick (#28) | Hard | Estate at the death (rule 9); the ticks before a rebirth | Yes |
| Progression Edges (#11) | Hard | Destiny perks, the edge, starting talismans | Quick spec |
| World Generation & History (#27) | Hard | Fixed authored ids, candidate sites, origins, history entries | Yes |
| Item Database (#13), Alchemy (#15) and the crafts | Soft | Recipes seen and crafted | Yes (Item DB); built |
| Spiritual Roots (#6) | Soft | Variant roots and their formation conditions | Yes |
| Sects & Missions (#26) | Soft | Succession of a sect the player led; a lineage rebirth's sect | Yes |
| Achievements (#32) | Soft | The shared writing gate | Quick spec |

**Downstream (they read this system)**

| System | Hard / Soft | Interface |
|---|---|---|
| Guidance Layer (#35) | Soft | Codex knowledge in the advisor, marked as remembered |
| Game UI (#37) | Soft | The mode choice, the succession screen, the Codex screens |
| NPC Relationships (#46) | Soft | Its Open Question 5 (successor play) is answered by rule 4 |

**Back-links owed:** NPC Relationships Open Question 5 (answered here); Living World Tick rule 9 (the player's estate
uses it unchanged; a rebirth runs ticks); Progression Edges (perk pick for every successor, talismans only for a
reborn); Achievements (the shared gate); World Generation (stable ids and candidate sites read by the Codex).

## Visual/Audio Requirements

The Codex is a book (thiên thư) in the art bible's ink-wash style (§7): one page per entry, a seen entry drawn in faint
ink, a known one in full ink. A death in One Life closes with the epitaph on a stele; the succession screen shows the
dead and the candidates as portraits on one scroll. No new audio is required; a page-turn and a single bell at a
death are candidates for the audio pass (Audio #38).

## Game Feel

A death in Continue is a turn, not a menu: the epitaph shows first, then the succession screen, and the first season
of the new life follows without a loading break for an heir. For a rebirth the 64 seasons of world ticks show as a
short chronicle of the years passing (the news of those years), so the gap reads as time, not as a wait.

## UI Requirements

- **New game:** mode (One Life or Continue) beside the birth mode and origin, each with one line saying what it means.
  The save slot shows the mode.
- **Succession screen (Continue):** the epitaph; each heir candidate (relation, realm, age, sect, place, notable
  ties); rebirth with its origins (lineage marked with its karma cost and whether the sect or clan still exists); the
  karma total, the spend, and the perk options; "end this playthrough".
- **Codex:** books by rule 8's table, each entry seen or known, with its effect stated; a Lives book listing every
  life (mode, realm, age, cause of death). Known knowledge in other screens (craft list, map rumours) carries a
  "remembered" mark.
- The screens themselves belong to a UX spec (`/ux-design`) before implementation.

## Cross-References

| This GDD | Refers to | Where | Why |
|---|---|---|---|
| Rule 4 | Rule 13 (inheritance), Open Question 5 | `npc-relationships.md` | Ties at the death; successor play |
| Rule 4 | Rule 9 (death and estate); closed-door ticks, AC-LW-40 | `living-world-tick.md` | The estate; the rebirth gap |
| Rule 5 | Destiny perk, edge parts 1–4 | `design/quick-specs/progression-and-edges.md` | What a successor gets |
| Rules 7, 9 | Achievements' file and gate | `design/quick-specs/phu-luc-linh-thu-thanh-tuu.md` | The same profile pattern and gate |
| Rule 8 | Fixed world, candidate sites, origins | `world-generation.md` | What the Codex may store as true |
| Rule 8 | Variant roots | `linh-can.md` | Seen and known variant roots |

## Acceptance Criteria

Tags: [Logic] gdUnit4 unit test in `tests/unit/codex/`; [Integration] in `tests/integration/codex/`; [UI] a retained
screenshot in `production/qa/evidence/`. Tests use a Codex file in a temporary folder, never the player's profile
(as Achievements' `--achievements-file`). Numbers come from the data file.

- **AC-CK-01** [Integration] Rule 1. **GIVEN** a new game in One Life, **THEN** the save holds the mode and it cannot
  be changed during the playthrough; the same for Continue.
- **AC-CK-02** [Integration] Rule 3. **GIVEN** One Life, **WHEN** the player dies, **THEN** the playthrough is Ended,
  the Lives entry is written, and no successor is offered.
- **AC-CK-03** [Integration] Rule 2. **GIVEN** One Life with a save from before the death, **WHEN** it is loaded,
  **THEN** play resumes, and the Codex still holds the death's Lives entry.
- **AC-CK-04** [Integration] Rule 4. **GIVEN** Continue and a player with 2 living children and 3 living disciples,
  one of whom is the known killer, **WHEN** the player dies, **THEN** the succession step offers the 2 children, the
  2 other disciples, rebirth and "end"; NPC Relationships rule 13 and Tick rule 9 ran before it.
- **AC-CK-05** [Integration] Rule 4. **GIVEN** an heir is chosen, **THEN** play moves to that person with their own
  realm, items and ties unchanged, plus whatever the estate gave them.
- **AC-CK-06** [Integration] Rules 4, Formulas C. **GIVEN** a rebirth is chosen, **THEN** 64 seasons of world ticks
  run, and a new person at age 16 with no ties enters the same world; the world's history shows those years.
- **AC-CK-07** [Logic] Rule 5. **GIVEN** an heir successor in Fated birth with karma 0, **THEN** they pick one of 3
  rolled destiny perks they do not hold, gain the edge, and receive no Phá Cảnh Phù; **GIVEN** a reborn, **THEN**
  they also receive 2 Phá Cảnh Phù.
- **AC-CK-08** [Logic] Formulas A. **GIVEN** a Continue life that reached Trúc Cơ and made 25 entries known for the
  first time, **THEN** it earns 3 karma; **GIVEN** the same life made those entries known in an earlier life, **THEN**
  it earns 1.
- **AC-CK-09** [Logic] Formulas B. **GIVEN** 4 karma, **THEN** offering lineage (3) plus 1 extra perk option leaves 0;
  a spend above the karma held is not offered; `perk_extra` never exceeds 3.
- **AC-CK-10** [Logic] Rule 6. **GIVEN** a One Life playthrough, **THEN** no karma is ever earned; **GIVEN** a new
  Continue playthrough, **THEN** it starts with 0 karma whatever earlier playthroughs earned.
- **AC-CK-11** [Integration] Edge Cases. **GIVEN** a lineage rebirth into a sect destroyed during the 64 seasons,
  **THEN** the reborn starts as a loose cultivator in that region and 3 karma is refunded.
- **AC-CK-12** [Logic] Rules 7, 9. **GIVEN** a Fated-birth life crafts a recipe, **THEN** its entry is known in the
  Codex file at once; **GIVEN** a Self-made or `cheated` life does the same, **THEN** nothing is written except, at
  death, its Lives entry.
- **AC-CK-13** [Integration] Rule 8. **GIVEN** a recipe known in the Codex, **WHEN** a new life starts in either
  mode, **THEN** it is in the craft list marked remembered, and crafting it still needs its materials and level.
- **AC-CK-14** [Integration] Rule 8. **GIVEN** a hidden place entered in an earlier game, **WHEN** a new game rolls
  it to another of its candidate sites, **THEN** the Codex shows all of its candidate sites and not which one holds it.
- **AC-CK-15** [Logic] Rule 7. **GIVEN** a Codex with 10 entries, **WHEN** an older save is loaded, **THEN** the Codex
  still holds 10 entries.
- **AC-CK-16** [Logic] Edge Cases. **GIVEN** an unreadable Codex file, **THEN** the game starts with an empty Codex,
  keeps the old file as a backup, and shows one notice.
- **AC-CK-17** [Logic] Edge Cases. **GIVEN** an heir successor who already holds 6 of the 8 perks, **WHEN** they
  have 1 `perk_extra`, **THEN** 2 options show and the unused karma is refunded.
- **AC-CK-18** [UI] **GIVEN** a Continue death, **THEN** the succession screen shows the epitaph, the candidates,
  rebirth with its origins and costs, the karma and the perk options. Screenshot: `codex-succession.png`.
- **AC-CK-19** [UI] **GIVEN** a Codex with seen and known entries in each book, **THEN** the Codex screen shows them
  apart and states each effect. Screenshot: `codex-books.png`.

## Open Questions

| # | Question | Owner | By |
|---|---|---|---|
| 1 | Spare-life heirs: should an heir successor be limited (for example to a realm no higher than the dead player's, or to a karma cost by realm), or is grooming a strong disciple a fair lineage fantasy? | user | Balance pass |
| 2 | Should some achievements require One Life (prestige), or count in both modes alike? | user | Before building |
| 3 | Values marked *(guess)*: `realm_karma`, `known_per_karma` 10, `perk_extra_max` 3, `lineage_cost` 3 | systems-designer | Balance pass |
| 4 | An NPC heir's traits: keep their stat rows only (as written), or let some traits colour the player's events? | NPC Traits | Before building |
| 5 | Should a reborn keep a faint link to the past life (old friends may recognise them, a past-life memory event), or stay a stranger? | user, narrative | Later |
