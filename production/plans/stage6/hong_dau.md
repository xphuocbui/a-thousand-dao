# Stage 6: Hồng Đậu Trang (progress file)

Brief: `production/plans/stage6/_brief-record.md` (`OWNER = hong_dau`). Headless job, decisions auto-accepted (user, 2026-11-26) and logged in `production/plans/stage6/hong_dau-review.md`. Resume here: do the first unchecked step.
Staging folder: `design/stage6-staging/hong_dau/` (mirrors `design/`). Never run git.

## Scope (gap report 2026-11-27, `python -I tools/design/world/depth_gap.py --sect hong_dau`)
- **2 techniques** (`hong_dau.techniques.json`):
  - `red-bean-primer` (Yellow/tier 0 main, `moc` + `thuy`, 6 layers, `ngoai_mon`)
  - `canon-of-longing` (Earth/tier 2 main, `moc`, 12 layers, `noi_mon`)
- **4 new arts**: `scatter-beans` (`red-bean-primer`); `a-branch-in-spring`, `gather-more`, `the-second-cup` (`canon-of-longing`).
- **7 items, 2 sets, 4 Effects**:
  - Items: `hd-phi-hong` (treasure, rarity 5), `hd-longing-gourd`, `hd-gracious-door-fan`, `hd-red-bean-robe`, `hd-second-cup-pot`, `hd-trellis-needles`, `hd-toadwood-ring`.
  - Sets: `hd-tea-at-the-manor` (2pc), `hd-back-garden` (3pc).
  - Effects: `Half of a Pair`, `The Second Cup Is Poured`, `The Second Cup`, `Planted, Waited, Harvested`.
- **1 stand-in**: `te_vong_quy` (`huyen_hoa`, layer 6; Phượng Minh swordsman under charm) -> Phượng Minh's committed `wutong-dawn-breath` (layer 6).
- **0 beasts**, **0 cross-owner**, **4 structured events** (`N-hong_dau-01`..`04`).
- `spatial_words_check.py`: only `hd-back-garden` (`Planted` in the English set Effect name "Planted, Waited, Harvested", literal bean-planting, not spatial Planted immunity).

## Mechanic Table (verified before staging)

| Record | Mechanics | Engine words | Status |
|---|---|---|---|
| `red-bean-primer` | Outer method; `scatter-beans` | standard passives (`stack_effect_pct`, `stack_duration_pct`, `linh_luc_regen_inc_pct`) | exists |
| `scatter-beans` | Wood hit laying 1 Wood debuff; if foe already holds 3+ Wood stacks, lays 1 Slowed Time (2 s) | `debuff: [1, 8]`, `hit_landed` `foe.debuff.wood >= 4` -> `status slowed_time` | exists |
| `canon-of-longing` | Inner canon; `a-branch-in-spring`, `gather-more`, `the-second-cup` | tier 2 bonuses (`tam_ma_resist_pct`, `linh_luc_pct`) & passives | exists |
| `a-branch-in-spring` | Light Wood hit laying 1 Wood debuff (10 s), grows +1 Wood stack/s while fed (reset to 4 s on any non-self Wood `status_applied`), stops growing if 4 s pass without another Wood poison | `counters` (`branch_on`, `branch_feed`, `branch_self`), `pulse`, `status_applied` `element: wood`, `stacks` | exists |
| `gather-more` | Heavy Wood hit (guarded `foe.debuff.wood >= 4`) consuming all foe Wood debuffs for Chaos damage scaled by poison age (`poison_age` counter) + stacks consumed, healing holder | `guards`, `counters` (`poison_age`), `scale`, `consume`, `free_hit` (`pass_shields`, `outside_budget`), `heal` | exists |
| `the-second-cup` | Non-damaging charm (guarded `foe.status.charmed == 0`): Charmed 2 s (`holds_caster`, `hold_arts`, blocks escape/cleanse arts), foe's next art hit deals 20 % less (`dampen_taken 25`) | `status charmed` (`art_fired`), `cup_weaken` counter, `always` `mod dampen_taken 25 [art]`, `was_hit`/`was_evaded` clear | exists (cleanse/escape arts held by `charmed`) |
| `Half of a Pair` (`hd-phi-hong`) | While `tan_hong` is unheld, `-8` sword crit when foe has 0 Wood debuffs | `always` `foe.debuff.wood <= 0` -> `mod crit -8 [sword]` | exists (`tan_hong` not in game yet) |
| `The Second Cup Is Poured` (`hd-gracious-door-fan`) | After `time > 20`: +10 % Wood poison damage (0.002 Chaos/stack on `tick_dealt` 1/pulse) and Charmed +1 pulse (`status_dur 50 [charmed]`) | `time > 20`, `tick_dealt`, `free_hit`, `always` `status_dur 50 [charmed]` | exists (`approx` for poison tick scaling) |
| `The Second Cup` (`hd-tea-at-the-manor`) | Once/fight at `foe.debuff.wood >= 8`: Charmed 2 s, refresh Wood Poison batches, +2 Heavy Breath (4 s) | `status_applied` `per_fight: 1`, `status charmed`, `refresh`, `status heavy_breath` | exists (`approx`: refreshes batches instead of 3 s pause) |
| `Planted, Waited, Harvested` (`hd-back-garden`) | After 6 s of Wood Poison (`garden_ripe_t >= 6`): `stack_grant +1 [wood, debuff]`; once/fight on Wood art hit (not `gather-more`) at `foe.debuff.wood >= 6`, consumes all Wood stacks for Chaos `c 0.15` + `0.5 %` heal/stack | `counters` (`garden_ripe_t`), `always` `stack_grant`, `hit_landed` `not_art_id` `consume` + `free_hit` + `heal` | exists (`approx`: elapsed poison time instead of per-batch age) |
| `te_vong_quy` stand-in | Phượng Minh Fire/Earth swordsman (`hoa 56, tho 40`, `layer 6`) | Phượng Minh committed `wutong-dawn-breath` (layer 6) | exists |

## Steps
- [x] 1. Verify first: mechanic table built above; `DEPTH_STAGE` env convention verified.
- [x] 2. Techniques and arts (`techniques/catalogue-sect-hong_dau.json`, `arts/part-sect-hong_dau.json`, `hong_dau.techniques.json` art ids).
- [x] 3. Effects (`effects/hong_dau.effects.json`, all 4 validate cleanly).
- [x] 4. Items and sets (`items/catalogue-sect-hong_dau.json`, `items/sets-hong_dau.json`).
- [x] 5. Stand-ins (`hong_dau.cast.json`: `te_vong_quy` -> `wutong-dawn-breath` layer 6).
- [x] 6. Beasts (verified: 0 beasts).
- [x] 7. Holder check (`lint_arts`, `lint_techniques`, `lint_items` 0 findings; `depth_check` findings none; `depth_gap --sect hong_dau` stand_ins 0; `sect_fight.py hong_dau --seeds 5 --gap 0` & `--gap 1` 0 REFUSED + probes for `Half of a Pair` and `The Second Cup Is Poured`).
- [x] 8. Review file (`production/plans/stage6/hong_dau-review.md`).
- [x] 9. Finish (`RECORD PASS DONE` + `production/plans/stage6/hong_dau.done`).

## Exact commands (`$env:DEPTH_STAGE = "C:\Users\xphuo\IdeaProjects\my-game\design\stage6-staging\hong_dau"`)
- `python -I tools/design/arts/lint_arts.py design/stage6-staging/hong_dau/arts/part-sect-hong_dau.json`
- `python -I tools/design/arts/lint_techniques.py design/stage6-staging/hong_dau/techniques/catalogue-sect-hong_dau.json`
- `python -I tools/design/items/lint_items.py design/stage6-staging/hong_dau/items/catalogue-sect-hong_dau.json`
- `python -I tools/design/world/depth_check.py --quiet`
- `python -I tools/design/world/depth_gap.py --sect hong_dau`
- `python -I tools/design/combat_sim/sect_fight.py hong_dau --seeds 5 --gap 0`
- `python -I tools/design/combat_sim/sect_fight.py hong_dau --seeds 5 --gap 1`

RECORD PASS DONE
