# Plan: building NPC Relationships (#46)

Started 2026-11-21 while the user is away ("continue with the implementation of relationships and formations").
GDD: `design/gdd/npc-relationships.md` (Approved, commit dd75165b). Formations (#17) comes after this.

**Rules for this run (user away):** no GDD edits (they need the user's approval) and no questions; where the GDD is
ambiguous or has no feeder in code, take the conservative reading and log it under "Decisions for the user" below.
Commit own paths only. Every new test is watched failing once; the full suite runs after each phase.

## What feeds ties in the code today (2026-11-21)

- **Sư đồ:** `master_id` on people, written by the cast (world_builder `_hist.people[].master`), World Generation's
  `_join` (master_share 0.3), world_generator's history masters, and Sects rule 20a's `pick_master` at intake. Read
  by NPC Traits F3 (+30), `_bereave` (Grieving), Inheritance (heirs), `pick_master` (disciple count).
- **Deaths:** old age (tick), war losses (sect_politics, no individual killer), failed breakthroughs and events
  (player). **No known kills between NPCs:** tick duels never kill or injure. Power Rankings is off in the sims.
- **None yet:** kin (no parents anywhere), kết nghĩa, đạo lữ, companions, rescues, betrayals between people, the
  player's bond verbs, Quests errands, Combat companion sources, Event Engine `tie_*` effects.

## Phases

1. **Store (no observable change).** A `ties` table in WorldDB (prefix `t`), indexed from both ids (lazy, rebuilt
   after a load), the record of rule 1 (pinned flags, one soft kind with per-direction enmity, one debt, favour_owed,
   causes, outside_cap), Formulas A-C, caps and eviction (rules 5-7, 10), data in `assets/data/npc_relationships.json`
   (load rejects a fade rate of 0 and a soft_reserve above its cap). **Sư đồ gets one writer** that sets the tie and
   `master_id` together; every site routes through it. F3's `tie` term reads the store. Check: a world_sim chronicle
   byte-identical to the commit before (timings aside); no RNG draws in the tie layer.
2. **S8b in the tick.** The queue and the seven sub-steps (rule 9): deaths and inheritance (rule 13: struck set,
   heirs, avengers, mourners, held feuds, debts), ends, lost-notability evictions, strength changes, new parts with
   eviction, hardening (rule 11), the hook pass (rule 15a: master and đạo lữ `cultivation_speed_pct` rows with
   source `tie`). `tie_end` log entries with reasons (rule 1b table).
3. **Sources with feeders.** Event Engine effects `tie_add` / `tie_strengthen` / `tie_weaken` / `tie_end` in the event
   resolver; tick duels as world fights (rival on a close fight only when ratings are on, below); `_bereave` reads close
   ties from the store.
4. **Pure formulas with no caller yet** (Formula F): `p_help`, `favour_cost`, `errand_cost`, `B_errand`; tested,
   listed as unwired.

## AC map (tests in tests/unit/relationships/, tests/integration/relationships/)

Tested: AC-NR-01-06, 08-23, 25, 29, 32, 33, 34, 40, 42-46, 48 (property), 52-56 (55 and 56 in part: the sub-cases
whose sources exist), plus the migration and rule 8's event effects.
Not built (no caller yet): AC-NR-24 (blocked in the GDD), 26 and 27 (FX-W5K and Power Rankings stubs), 28 and 31
(FX-EV-T at scale; 31 also needs a release export), 30 (no kin or authored kết nghĩa / đạo lữ in the cast data),
35-37, 49, 50, 57 (help calls, favours, errands, the verbs: Combat, Quests, Dialogue), 38 (a player kết nghĩa verb),
41 (event conditions on ties: the Event Engine's condition vocabulary has no tie reads yet), 47 (cause links are
written but not asserted), 39 and 51 (UI).

## Decisions for the user

1. **The master and đạo lữ rows are inert for NPCs.** The hook pass writes `cultivation_speed_pct` +5 / +8 rows
   (`tie_rows`, read by the StatSheet as "Quan hệ: ..."), so the player gains them, but the Living World Tick moves
   NPCs by a flat stage chance that reads no stat. Making it read them would change the census again (after today's
   N_stage retune); left for the user.
2. **No known kills between NPCs exist yet**, so feuds, avengers, mourners and inherited feuds have no feeder in the
   world: tick duels never kill or injure, and war deaths name no killer (queued as unknown). The kill path is built
   and tested (FX-FAM) for the Event Engine, the player and Power Rankings when they report kills.
3. **Close world fights form rivals only when Power Rankings is on** (rule 8 reads its rating gap; the sims run with
   it off), so the world forms no rivalries in a simulation.
4. **No kin is generated** (World Generation has no parents), so rule 13's children are always empty and AC-NR-30 is
   deferred.
5. **`_bereave` (Grieving) still reads `master_id`**, not the store's close ties; the same people today (only sư đồ
   exists). `master_id` stays on a disciple after the master dies, as history (Inheritance and Sects rule 20a read it).
6. **A master already dead is kept as `master_id` only** (the cast's history): `set_master` and `migrate` write no
   tie with a dead person (rule 13 removes the dead's records). tie_world_probe.gd, 40 years on the continent: every
   living disciple's master_id matches the store, no tie names the dead, the queue empties each season (1,028 ties).
7. **AC-NR-31's timing is not assessed under its conditions** (it is for a release export); the headless debug
   build measures the hook pass at 5.6 ms p50 against its 2 ms.
8. **Fixtures written past the caps:** `write_soft`'s `force` option, for the GDD's fixture note ("variants write
   those records directly"); no game path uses it.

## Progress

- **Phase 1 (store):** `Ties` (src/gameplay/relationships/ties.gd), the `ties` table and tie index in WorldDB (prefix
  `t`, both sides, the pair key, the hook index), `assets/data/npc_relationships.json` (validated), the clock
  (`w_clock`), sư đồ's one writer `Ties.set_master` (cast, `_join`, the random world's history, `create_person`), the
  old-save migration (`Ties.migrate`, called by `load_dict`), F3's `tie` term from the store with the Grudge min.
  Tests: relationships_store_test.gd (AC-NR-01-06, 08-13, 15, 29, 34, 42, 44, 45, the migration). Byte-identity
  check against HEAD: queued behind ape6.
- **Phase 2 (S8b):** `TieTick` (tie_tick.gd): the queue (`w_tie_queue`) and the seven steps; inheritance with the
  struck set, avengers, heirs, mourners, held feuds (own and inherited, generation and origin), debts; end reasons and
  news kinds; betrayal, repay, lost notability, hardening; the hook pass with `w_tie_rows` reconciling by source.
  Tests: relationships_season_test.gd (AC-NR-14, 16-23, 25, 32-33, 40, 41, 43, 46).
- **Phase 3 (sources):** S8b runs at the end of each world tick; old-age and war deaths are queued; close world fights
  (ratings on) queue a rivalry; the event resolver's `tie_add` / `tie_strengthen` / `tie_weaken` / `tie_end` effects
  queue changes; the session copies the player's tie rows after the tick and keeps the met list (Character
  `met_list`), queuing a notability test for someone pushed off it.
- **Phase 4:** Formula F's `p_help`, `favour_cost`, `errand` (AC-NR-34), unwired.
- **dc59d0e9** phase 1 committed alone (byte-identical 40-year chronicle). Phases 2-4: the chronicle is identical
  to phase 1 (the sims have no tie sources that change anything they print), and the tick costs the same within
  noise (A/B run one after the other: 391 ms a season at HEAD, 393.5 with S8b; two runs each). tie_cost_probe.gd:
  940 hook records; the hook pass 5.6 ms p50 (6.4 p95) in the headless debug build, against AC-NR-31's 2 ms budget
  on a release export: measured, not met yet (the AC is for the release export; logged). S8b with 30 deaths 12.7 ms.
- **AC-NR-48** property test (tests/integration/relationships): 400 random seasons on 60 people; watched failing when
  set_feud kept the holder's soft enmity.
- **Review fixes:** every part that ends while its record lives writes a `tie_end` (betrayed, repaid, replaced,
  faded, cancelled), so those news kinds appear; the holder and the target dying the same season gives the target's
  reason (watched failing); the hook rows carry Modifier kind `tie` (StatSheet.KIND_TIE).

## Decisions answered (user, 2026-11-21, one by one)

1. **NPCs read their tie rows:** the tick multiplies an NPC's stage chance by (1 + tie cultivation_speed_pct / 100)
   (245963f4). Census to year 1600: seed 11 3,945 / 808 / 202 / 40 / 5, seed 23 3,851 / 873 / 236 / 35 / 5, within
   seed noise of the Cave Abode runs. Not retuned.
2. **Duels can kill:** a world duel's winner kills the loser with chance `duel_kill_p` 0.05 × (winner power / loser
   power), at most `duel_kill_p_max` 0.25 (world_generation.json tick). It's a known kill: the killer takes the purse
   and the unbound items, and S8b runs feuds, avengers and mourners. Old-age deaths and kills share
   `WorldTicker.npc_death`.
3. **Rivals with Rankings off:** a fight is close when the weaker fighter has at least `rival_power_ratio` 0.85 of
   the stronger's power.
4. **Families and births** (GDD edits approved: World Generation rule 8 Families, Living World Tick rule 5 Births):
   - At the start, `kin_share` 0.15 of the random cultivators get a parent from their region (at least 18 years
     older, at most 3 children). The child takes the parent's surname, and a family line keeps one surname.
   - Siblings hold kin.
   - A gia_toc player gets a parent and 0-2 siblings in the clan town. When no loose elder exists, the parent is
     made there.
   - `birth_share` 0.3 of each season's intake are children of a living cultivator, so the count is unchanged.
   - Code: `Families` (src/gameplay/relationships/families.gd); Character.parent_id.
5. **Grief follows the close ties:** master, disciples, kin, đạo lữ and kết nghĩa, read from the store before S8b
   (`TieTick.close_ties`).
6. **Dead masters** stay as `master_id` history only (kept).
7. **AC-NR-31** measured on a release export: `build/bench/combat_bench.exe --headless -- --tie-cost`
   (tests/performance/world/tie_cost_bench.gd); results below.
8. **`write_soft` force** kept, fixture-only.
