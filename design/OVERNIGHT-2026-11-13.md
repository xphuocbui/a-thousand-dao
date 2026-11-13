# Overnight 2026-11-13

> Unattended run while the user sleeps. The user's brief: finish the open work (Effects drafts for approval, items into
> game data with code and tests, the content asks), then finish the fight engine with the effects, modifiers and rules
> already designed, and fix bugs. Nothing is committed; everything waits for review.

## Done

### Fan the Pyre, checked in the sim

- The engine gained a `refresh` action (restart or hold one's own stack batches of an element) and batches now remember
  their length. Unit-tested (`test_engine.py`: refresh, hold, the other side's batch untouched).
- **In the two builds that wear the Ashen Phoenix Fan (Two Clocks, Starter Flame) it is a small net loss** (fights
  29.6 → 32.9 s and 20.6 → 21.5 s): those builds spend their Burn with payoff arts (Gourd Swallows the Flame and
  others) long before any batch would expire, so the refresh has nothing to save, while the closing cost (direct Fire
  hits 15 % less) always applies.
- **In a pure Burn-ticking build it pays a little** (typical Kết Đan: 0 → 2 wins of 20; the cost alone makes it worse).
- No runaway: Burn grows while the hits land, but slowly. Nothing to change unless the user wants the Fan to suit
  consume builds too.

### Sim additions from the build asks

`refresh`/`hold` action; a strip can count as a status landed (`"as_status": true`, Unmaking Glass); readables
`foe.curses` (Weight of Names) and `own/foe.ward_paid` with the event `foe_ward_paid` (Water Table); step unlocks and
empowers now print per fight (`steps` / `empowers` lines); `health_regen_inc_pct` runs. Tests pass, regression clean.

### Content asks

3 items (Ninth-Bell Ring, Earthbind Anchor, Hushed Vigil Cuirass: 171 items) and 3 techniques (Formless Ruin Canon, the
Chaos main method; Hundred Arts Sage Canon; Drawn-Out Edge Canon: 34 techniques). Both lints 0 findings; nothing existing
changed; `design/arts/INDEX.md` regenerated.

### Effects drafts for your approval

`design/research/effects-from-items-draft.md`: all 35 new Effects in `effects.md`'s own table format, by section
(Scaling 4, Trigger 12, Conversion 1, Rule change 5, Enablers 13), ready to paste group by group once you approve.
`effects.md` itself is untouched. Two notes there: delays already share a rule (rule 6, R1), so no new delay rule is
needed; Deep Freeze is Rime Lock repeated (suggestion: keep both).

## Plan for the rest of the night (user, 2026-11-13)

1. Items into game data, with code and GdUnit tests (Item Database rules 11, 20, 21).
2. Finish the fight engine: the Effects, modifiers and rules already designed and written, and fix bugs.
3. A balance patch: hold the macro targets (memory: balance-depth), propose and apply where the data says so, no loops.

## Items in the game (step 1, done)

Item Database rules 11, 20 and 21 now run in Godot. **GdUnit: 282 tests, 0 failures** (was 259; 23 new, in
`tests/unit/items/`). The two key new tests were watched failing against the old behaviour first.

- **Data.** `assets/data/items_artifacts.json` is schema 2: the 22 bases of `design/items/bases.json` with `roles` and
  `damage_type` (13 new: axe, coin, zither, anchor, drum, mirror, censer, lantern, branding iron, lightning rod,
  ring, necklace, robe); `equip.base_slots` / `slot_roles` / `extra_slots_by_realm` replace `max_slots`; Liệt and
  Kiên carry `exclude_roles` (rings and necklaces never roll them); a `named` block (`unique_rarity_min` 5,
  `rarity_offset` 1, `unique_return_years` 50, `holder_realm_min` 2). `artifact_slots` got a stat label.
- **Named items.** `tools/design/items/export_named.py` compiles the 171 catalogue items into
  `assets/data/items_named.json` (`--check` says when it is stale). The design catalogue stays the source.
- **Code.** New `EquipSlots` (which slot each piece sits in: pinned slots first, then base slots by role, then
  extras; past the limit a piece is worn but adds nothing) and `ItemStats` (affixes plus unscoped named modifiers).
  `CombatPower.controlled`: every slotted piece counts. `GameSession.equip(item_id, slot)`, the Advisor (suggests a
  free slot) and NPC builds use the slots. `ItemFactory.named_artifact` / `is_unique` / `named_available`
  (one record of a unique item per world; back `unique_return_years` after it is destroyed). World Generation
  places every unique named item at world start (held by an NPC at Kết Đan or above, who wears it if a slot fits, or
  Lost at a place). `WorldDB.items_on_death` moves a dead holder's items (killer, else Lost; bound items Lost), and the
  world tick calls it on old-age deaths.
- **Seen running.** The debug terminal (`debug item artifact <grade> <base>`, `debug item named <id>`, `equip <id>
  [slot]`): transcript `production/qa/evidence/debug-terminal/10-equip-slots-session.txt`.

**Morning correction (user, 2026-11-13): no piece costs thần thức.** I had built extra pieces paying thần thức.
The user's rule is that extra slots are free, and thần thức buys more of them.
- **Decided with the user:**
  - +1 extra slot for each full 1.75 × the realm's reference thần thức (`ds_ref` 45 / 135 / 450 / 1,350 / 4,500,
    the same step as ward slots), with no cap;
  - no item has a thần thức cost;
  - the Linh affix gives +5 to 15 % thần thức.
- **A thần thức or `artifact_slots` grant counts toward the slot count only from a piece in a base slot**, so no piece
  opens its own slot.
- **Changed to match:**
  - the Item Database GDD: rule 11, Formulas D (a new item_slots formula and new rows), the affix pool, the bases
    table, Edge Cases, Tuning Knobs, FX-E, AC-ID-12, 41, 42, 43 and 80, and Open Question 21, marked reversed;
  - `than_thuc_cost_pct` retired in the Modifier System and Character Stats;
  - the data, now schema 3;
  - the code: `EquipSlots`, `CombatPower`, `ItemFactory`, `StatSheet`, `GameSession`, the Advisor, NPC builds and
    autoplay;
  - the tests.
- **GdUnit: 287 tests, 0 failures.** The terminal transcript was rerun and shows "Extra slots 2 / 2, the next at thần
  thức 79".
- **Left as it is:** `design/items/bases.json` and its generated pages still list a per-base thần thức cost that
  nothing reads now. Removing it changes two table layouts; it is a separate small cleanup.
- **Capability #3** (Dưỡng Bảo Nội Thể). **Decided (user, 2026-11-13):** the nurtured treasure lives within the body,
  so the capability gives +1 extra slot.
  - The nurtured piece is now one you choose with `nurture <item id>`.
  - It grows +1 % a year up to +50 % as before.
  - Choosing another, or unequipping it, restarts the growth.
  - Recorded in the Meridian Map GDD catalogue row and the capability data; tested.

**For you to decide (not in the GDD yet):**

1. ~~`holder_realm_min`~~ **Decided (user, 2026-11-13):** Kết Đan and up, as built (rule 20d and Tuning Knobs).
2. ~~The `single_artifact` keystone~~ **Decided (user, 2026-11-13):** the base slots work as normal; only the first
   extra piece counts, at ×2.5 (rule 11; code, data text and a test done).
3. Named modifiers reach the Godot stat sheet only when unscoped and known to the game (attack_pct, khi_huyet_pct
   and others). Scoped ones (`attack_pct` for fire) and combat keys (crit, art speed) are stored on the record for the
   art combat the game does not have yet. Arts, wards, reserve arts and Effects are stored by id only.
4. ~~Rule 14's death transfer~~ **Decided (user, 2026-11-13):** with no killer, the dead NPC's unbound items go to:
   - a close relationship (for now the strongest living disciple, else the living master);
   - else the sect successor (same rank, then the nearest rank above, then below);
   - else they are Lost where the NPC died.

   A dead sect leader's successor also takes the leadership. This is now in rule 14, with a new `Inheritance` helper,
   `sects.rank_ladder` in the data, and a "tick_succession" news line. Old age is still the only way an NPC dies
   (world-tick duels kill nobody, and event and breakthrough deaths are the player's), so there is no other death path
   to wire yet. The transfer takes a killer when one exists.
5. Not built: the Thiết Bích affix (`resist_pct` is not a Godot stat yet), Lost-item decay (AC-ID-92), the source
   lint of AC-ID-91, and the 9 non-Ngũ Hành families (Ice, Thunder, Wind and others) get no element in Godot.

## The fight engine (step 2)

`tools/design/combat_sim/`: `test_engine.py` 0 failed (new tests for everything below, the key ones watched failing on
the committed engine first), `regress.py` 0 unexplained, `--selftest` passed. Input reference updated
(`FIGHT-INPUT.md`).

**Bugs fixed (these changed results):**

1. **Scoped speed and cost applied to every art.** A Sword-only or Fire-only `art_speed_pct`, `art_cost_pct` or
   `x_soul` sped up or cheapened every art (the loader said so in a gap line on 33 builds). Now each art reads its own
   context. The opening cooldown also ignored Effect speed; it no longer does.
2. **Type-scoped modifiers never reached elemental arts.** An elemental art is type `elem` in the engine, so "Fire",
   "Lightning" and "Cold" scopes matched nothing on it, `attack_pct` included. It now counts as its element's usual
   type (Combat Damage Types rule 3). Fire and Thunder builds got faster: Starter Flame 29 → 16 s, Ninth Tribulation
   Seal 15.8 → 6.8 s, Loaded Dice 12.8 → 6.4 s.
3. **Silent typos in build files that switched Effects off.** I added load checks; they found 7:
   - `"dtype": "physical"` in armoury-mind (engine-v2 and v3) and bare-fist: Iron Skin Renewed and Edge Returns the
     Breath never fired.
   - `own.buff.moc` (should be `wood`) in unkillable (v2 and v3): Sap Rises never counted.
   - `foe.status.burn` (Burn is a Fire stack, not a status) in triple-convert (v2 and v3): Kindled Wound never fired.
   - `cost_red` given in points, not as a share: pacifist's Sea Already Deep made every art cost **11×** (−10, meant
     −0.10); the arts library's Tithe Ledger gave 95 % off (40, meant 0.40, the rule says 40 %); Hollow Husk Stance
     made arts cost **36×** (−35, meant −0.35).
   All fixed in the files (`design/arts/family-body.json`, `family-force-chaos.json`, the build files).
4. **Plucked Time pushed the enemy's arts earlier** (its hand-written form used `by: -0.4`, but a positive number
   delays the foe). The library form delays it.
5. Smaller: a stolen stack batch lost its length; the top-level `art_cost_health_pct` converted health by the pool
   ratio, which the loader itself flagged as off the GDD (now point for point, the same as the item key).

**Now run (were gaps):**

- **Catalogue keys:** `status_duration_pct` (74 uses), `status_resist_pct`, `healing_taken_pct`,
  `linh_luc_on_crit_pct`, `art_cost_health_pct`, `resist_pen_pct` (AC-CD-13), `pierce_pct` (AC-CB-44), `stack_grant`.
  Status application now follows Combat Formulas F's chance and resistance.
- **Evade wards:** Cloud-Walker's Veil and Settling Dust Shirt.
- **All 54 Effects the item catalogue names**, in a new `tools/design/combat_sim/effects_library.json`. 34 were
  harvested from build files: where builds disagreed, the version closest to the rule won. 20 are new: Fan the Pyre,
  Spillover, Opening Cut, Final Clause, Blood Casting, Embers Never Die, Unmoved Stance, Toll Taker, Rime Lock, Deep
  Freeze, Whetstone Vow and the others.
  - A worn item now brings its Effect automatically; a build's own version still wins.
  - 11 are approximations, and each prints its reason.
  - 4 cannot run: Beneath Notice and Cold Feet need escape (deferred), Seal of Full Payment needs carried spirit
    stones, and Stone Answers needs a hit sized by damage stopped.
  - A test fails if a new catalogue Effect has no entry.

**Gaps across the 38 engine-v3 builds: 636 lines → 278.** What remains is mostly the authors' own notes
about retired v1 fields.

**Result shifts** (typical enemy, same realm, 20 seeds; before → after):

| Build | Fight length | Wins |
|---|---|---|
| Starter Flame | 20.6 → 16.0 s | 20/20 |
| One Art | 10.0 → 6.7 s | 20/20 |
| Unique Heaven-Purchasing Coin | 44.9 → 63.1 s | 20/20 |
| Dry Well | 39.2 → 62.5 s | 0 → 0 wins, more draws |
| Curse Engine | — | 12 → 14 wins |

The scratch comparisons are in the session scratchpad.

## Balance (step 3)

One light pass against the macro targets, per the balance-depth memory: check what holds, fix what is plainly a bug,
and leave every design number to you as a proposal. **No GDD number and no catalogue number was changed for
balance.** The one change is a rule-conformance fix (below).

### What holds

- **Same-realm fight length.** The typical mirror is 35.7 / 39.8 / 43.8 / 51.9 / 61.3 s from Qi Refining to Deity
  Transformation (40 seeds) after all of tonight's engine changes. That is inside the 30–60 s band; Deity
  Transformation sits 1.3 s over, as it did before tonight.
- **Progression baseline (edge off).** Autoplay at the first gate: committed code 15/36 (42 %), tonight's tree
  11/36 (31 %), target about 30 %. Second gate: 7/15 against 6/11.
  - Every one of the 72 lives died of old age or a breakthrough deviation, never in combat, so tonight's free base
    slots do not reach these numbers.
  - The difference between the trees is about one standard error; the new bases re-roll the random streams.
  - Raw output: scratchpad `auto-*.txt`.

### Fixed tonight (rule conformance, not tuning)

- **Per-hit wards were charged per hit part and met no ticks.** The GDD says one fee per hit, covering all its parts,
  and one fee per tick (Combat Defence & Healing rule 6). The engine now does that (test added).
- No result moved: the typical enemy has no converted hits and no ticks.

### Proposals for you (not applied)

**1. Per-hit wards are a trap (Combat Defence & Healing Formulas H).**
- **The finding.** A typical cultivator who adds the starter Golden Bell (all 100 points, per hit 0.035) goes from
  about even with a typical cultivator to losing **40 of 40** at Kết Đan and at Deity Transformation. Surging Tide
  does the same. The wearer runs dry at 12 s instead of 19 s.
- **Two reasons:**
  - The price assumes one incoming hit a second, but the typical enemy lands **1.6** at every realm.
  - The price check values health, while in fights linh lực decides who wins (running dry is losing).
- **Where it breaks even.** A sweep of the Golden Bell's fee:

  | Fee | Kết Đan (W–L) | Deity Transformation (W–L) |
  |---|---|---|
  | 0.035 (GDD) | 0–40 | 0–40 |
  | 0.0175 | 0–40 | 0–40 |
  | 0.0117 | 1–39 | 0–39 |
  | 0.0070 | 31–5 | 24–6 |
  | 0.0035 | 40–0 | 40–0 |

  It breaks even near 0.008–0.010, a quarter of today's fee.
- **In the catalogue.** The 6 per-hit item wards (Bronze Peal Bell, Hollow Bell, Thunderclap Bell, Tide Bell,
  Muffled Temple Bell, Hoarfrost Tide Shield) inherit the same price. In the item study the Bronze Peal Bell made its
  build *worse*: it ended at 50 % health instead of 79 % and ran dry at 8 s instead of 13 s. With no fee, the same
  bell is clearly good.
- **Options:**
  - (a) Reprice the per-hit fee, through the hit rate and a linh lực value in Formulas H, to about a quarter. The 6
    items follow from their `check_from`.
  - (b) Keep it, and say in the GDD that bells only suit fights with few, heavy hits (the GDD already says "strains
    under many small ones"). Then the typical enemy is exactly the case they lose.
- I lean (a). It needs your call because it is a GDD number.

**2. Most designed builds kill a typical same-realm enemy in 1–3 s.**
- **The cause** is the build files' own layer totals, not one item or art:
  - The fast builds carry L1 266–400, L2 225–265, L3 250, L4 130–150 and L5 100. Every layer is at or near its cap,
    which is the top-end reference enemy, built to beat typical in about 2 s.
  - Typical carries L2–L5 of 40 / 40 / 20 / 10.
- **The question:** what can a Nascent Soul character really reach from the Meridian Map, techniques and gear? A
  **layer budget per realm** in the build-file rules would settle it.
  - If you want designed builds to win in about 10–20 s rather than 2, that budget is the lever, not the content.
  - Nothing changed tonight.

**3. The player's edge barely helps at the first two gates (this predates tonight).**
- **Measured:** autoplay, 36 lives each (two seed sets):

  | Gate | Edge off, committed | Edge off, tonight | Edge on, committed | Edge on, tonight | Target (off / on) |
  |---|---|---|---|---|---|
  | Qi Refining → Trúc Cơ | 15/36 (42 %) | 11/36 (31 %) | 16/36 (44 %) | 15/36 (42 %) | 30 % / 70 % |
  | Trúc Cơ → Kết Đan | 7/15 (47 %) | 6/11 (55 %) | 8/16 (50 %) | 7/14 (50 %) | 30 % / 70 % |

- **On the committed code, edge on and edge off land within 2 points of each other.** The edge's three parts do not
  reach the per-gate odds the targets need. Tonight's tree shows the same, inside the noise (one standard error is
  about 8 points at 36 lives).
- **The knobs** are the edge's three parts in `character_edges.json`: perk breakthrough bonuses, the two starting Phá
  Cảnh Phù, and cơ duyên frequency. First find out why autoplay's lives fail the gate: running out of lifespan before
  the pill, or failing the roll. Then tune.
- Tuning is a loop of 15-minute runs, so I did not start it on my own. **I'd make this the next balance job**,
  because it is the main macro target and it is off.

### Notes from the item study (267 refights: each worn item removed from its build)

- **The Whetstone Jade Pendant was the round's most popular item (7 builds) because of an engine bug.** Its reserve
  art's Metal-only art speed sped up every art until tonight's scoped-read fix. Now it changes its builds' fights by
  +1 % on average. The other most-worn pieces (Iron Skin Ring, Clay Seal Ring, Iron Temper Ring, the Hollow and Ledger
  pieces) also measure within ±7 %.
- **The strongest single pieces are expected ones**, each the centrepiece of its build:

  | Item | Build | Fight without it |
  |---|---|---|
  | Heaven-Minted Coin (Cực) | Ninth Bell | +126 % longer |
  | Nine-Fathom Seal (unique) | its own build | +78 % |
  | Heartwood Hatchet | Starter Venom | +62 % |
  | Red Sun Seal | Sect Ladder, Starter Flame | about +50 % in both |

  None is out of line with its grade or its role as an engine piece.
- **Loaded Dice and Unbroken Edge Ring sit on a knife edge one realm up.** Removing almost any item takes them from
  about 10 wins to 0. That is a close fight, not an outlier.
- Raw data: scratchpad `item_impact.txt`.

### Item Effects re-measured (118 refights: each Effect removed, same enemy and gap)

- **Most Effects move their build's fight by under 1 s.** Either the fight is already saturated (2–4 s), or the
  trigger rarely comes up: Final Clause needs going Down, Blood Casting needs running dry, and Bought Fate fires once.
- **Effects that decide a build:**
  - **Drumbeat** is Loaded Dice's engine: without it, 10 wins → 0.
  - **Iron Skin Renewed** keeps the Heaven-Purchasing Coin build alive: without it, 50 % → 37 % health and one loss.
  - **Edge Returns the Breath** in Unbroken Edge Ring: without it, 9 wins → 5.
- **Fan the Pyre is a net loss for both its wearers:** fights get faster without it (Starter Flame 16.0 → 14.6 s,
  Two Clocks 28.5 → 25.0 s). This confirms the check earlier tonight. It pays only where Burn is left to tick; a change
  is your call.
- Raw data: scratchpad `effect_impact.txt`.

## Decisions with the user (2026-11-13, morning)

1. **No piece costs thần thức;** thần thức adds extra slots (see "Items in the game").
2. **The one-treasure keystone:** base set + one extra piece at ×2.5.
3. **`holder_realm_min`:** Kết Đan.
4. **Inheritance on death:** killer, then a disciple or master, then the sect successor (with leader succession), else
   Lost.
5. **Capability #3:** +1 extra slot and a chosen nurtured treasure.
6. **The per-base thần thức cost** is removed from `design/items/bases.json` and its pages.
7. **Linh** is +7 to +18 % thần thức, which keeps `w_affix` at 12.80 W (0 lint findings).
8. **Fan the Pyre's closing** is 8 % (was 15). Measured afterwards, it is still a small loss for the two consume builds
   (7–9 % slower; was 10–12 %); it gains for pure Burn tickers.
9. **The 35 Effects** are in `effects.md`, approved as drafted.
10. **Being done now:**
    - per-hit wards repriced to about a quarter (Combat Defence & Healing Formulas H);
    - a per-realm layer budget drafted for your approval;
    - the player's edge diagnosed before any tuning;
    - three commits.

**Found while applying these:** the Effect **Open Sky** (already in `effects.md`) reads "thần thức not bound to
artifacts". Nothing binds thần thức any more, so its read needs a new meaning. For you to decide.

## For the morning

Nothing is committed. Here is what is waiting:

1. **Review and commit.** A suggested split:
   - (a) items in Godot (`src/`, `tests/unit/items/`, `assets/data/`, `tools/design/items/export_named.py`,
     `docs/data-schemas.md`, the debug-terminal evidence);
   - (b) the fight engine and its fixes (`tools/design/combat_sim/`, the fixed build and arts files, the round-summary
     addendum);
   - (c) the earlier content patch and the Effects drafts.
2. **Decisions**, in order of weight:
   - balance proposal 3 (the edge);
   - proposal 1 (per-hit ward pricing);
   - proposal 2 (a layer budget for build files);
   - the five item questions under "Items in the game";
   - Fan the Pyre.
3. **The Effects drafts**, group by group into `effects.md` (from earlier tonight).
4. **One untracked folder**, `design/gdd/production/`, is still there from before; delete it if it is not yours (my
   delete was refused).
