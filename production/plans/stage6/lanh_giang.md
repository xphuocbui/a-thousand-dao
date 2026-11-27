# Stage 6: Lãnh Giang Phái (`lanh_giang`) (progress file)

Method: `production/plans/world-depth-implementation.md` Stage 6, "the per-sect method", and `production/plans/stage6/_brief-record.md` (headless Batch b04, decisions auto-accepted under the 2026-11-26 rule).

## Scope (`python -I tools/design/world/depth_gap.py --sect lanh_giang`)
- **Techniques (`2`):** `ice-fish-boat-breath` (Yellow main, `thuy`, 6 layers), `lone-line-sitting-canon` (Profound main, `thuy`, 9 layers). Existing in lineage: `undertow-litany`, `returning-wake-verse`.
- **New arts (`4`):** `oar-stroke`, `line-through-the-ice`, `sitting-in-the-snow` (rule text, no ids yet), and `landing-the-fish` (engine form `e5` in `design/world/depth/builds/authored/auth-tech.json`).
- **Items (`5`) & sets (`2`):** `lg-ice-hook`, `lg-snow-cape`, `lg-sitting-robe`, `lg-old-sitter-gourd`, `lg-river-bottom-stone`; sets `lg-lone-line` (2 pc), `lg-heap-of-snow` (3 pc). All `23` modifier lines already run.
- **Effects (`3`):** `A Bite on the Line` (`lg-ice-hook`), `The Line Is Patient` (`lg-lone-line`), `Answers Twice` (`lg-heap-of-snow`).
- **Stand-ins (`0`), beasts (`0`), cross-owner (`0`), events (`3` structured).**

## Step 1 result: mechanic table & spatial check
`spatial_words_check.py --sect lanh_giang`: `0` non-soft hits (`lone-line-sitting-canon` concept and 4 tie notes have soft `"beside"`; `bo_toa_tuyet` `targets_note` has `"Still"`).

| Kind | Record | Mechanic | Engine Status | Choice / Plan |
|---|---|---|---|---|
| Tech | `ice-fish-boat-breath` | Yellow Water main, no depth passives | Has | Size new passives to Tier 0 `8.0 W` budget (`7.6 W`) |
| Tech | `lone-line-sitting-canon` | Profound Water main, no depth bonus/passives | Has | Add Tier 1 `linh_luc_pct 10` bonus + new passives (`15.5 W / 16.0 W`) |
| Art | `oar-stroke` | Water blow, foe soonest art waits 0.3 s, restores a little linh lực | Has | `c_art 1.4`, `qi_restore 0.05`, `hit_landed -> timer foe next +0.3` |
| Art | `line-through-the-ice` | Hooks foe, drains linh lực/s while held, banks Catch | Has | `ice_line` (`cap 1, each_for 6.0`), `pulse -> burn_qi {of: qi_max, share: 0.015, to_self: 1.0}` |
| Art | `sitting-in-the-snow` | Stance: while still, fast linh lực regen and lower Water damage taken | Has | `sitting-in-the-snow` state (`tags: ["composed"]`, `regen: 0.025`), `always -> dampen_taken 20 [cold]` |
| Art | `landing-the-fish` (`e5`) | Banks Catch from `qi_drained`, spends as 1 Water hit (doubled below 20% foe qi) | Existing words (adapted) | `e5` used `counter.add_amount`, `free_hit.amount`, `filter.source`; adapt to existing `qi_drained` -> `+1` `catch`, `hit_landed` -> `free_hit {c: 0.35, outside_budget: true}` per `catch` (`0.70` below 20% foe qi) |
| Effect | `A Bite on the Line` | While `line-through-the-ice` holds and sitting, foe loses 1% qi/s to you | Has | Declares `ice_line`; `pulse` (`ice_line >= 1`, `state.sitting-in-the-snow >= 1`) -> `burn_qi {of: qi_max, share: 0.01, to_self: 1.0}` |
| Effect | `The Line Is Patient` | While sitting: qi leech also heals half as much; every 5 s sitting, next hook art is a sure hit | Has (approx) | `always` sitting -> `leech_hp 3` (half of set's 6% `leech_qi`); 5 s counter `patient_sec` -> `patient_sure`, spent on `art_fired [hook]` as `acc: 500` |
| Effect | `Answers Twice` | While sitting: ward gains 2%/s; when broken, next counter art fires twice | Has | `pulse` sitting -> `ward_grow {share: 0.02, of: "hp"}`; `shield_broken` -> `answers_twice_ready`; `art_fired [counter, seal]` -> `fire_art {which: "last", share: 1.0}` |
| Items | 5 items (`lg-*`) | 23 modifier lines verbatim; 4 weapon/body_gear items | Has (R6) | `sources: ["npc"]`, `unique: true`, R6 `exception` on `cham`, `dao_bao`, `ho_lo` |

## Steps
- [x] 1. Verify first: mechanic table & `spatial_words_check.py`.
- [x] 2. Techniques and arts (staged `catalogue-sect-lanh_giang.json`, `part-sect-lanh_giang.json`) + depth art ids in `lanh_giang.techniques.json`.
- [x] 3. Effects (staged `effects/lanh_giang.effects.json`).
- [x] 4. Items and sets (staged `items/catalogue-sect-lanh_giang.json`, `items/sets-lanh_giang.json`).
- [x] 5. Stand-ins (none; verified 0).
- [x] 6. Beasts (none; verified 0).
- [x] 7. Holder check: `lint_arts.py` (0), `lint_techniques.py` (0), `lint_items.py` (0), `depth_check.py` (none), standalone `engine.validate` (3/3), `suite_check.py` (4 runs), `sect_fight.py lanh_giang --seeds 5` (`--gap 0` and `--gap 1`), targeted 10/20-seed probes (`evade=35`, `n_qi=0.2`, sub-record trace).
  - [x] Every Effect changes the fight with and without it on its holders; every art fires (`0 REFUSED`, `0 NEVER_FIRED`, `0 NEVER_RAN`).
  - [x] No holder slots two stances without a combined stance (`sitting-in-the-snow` is the sole stance; aux methods `undertow-litany` and `returning-wake-verse` define none).
  - [x] Each "your X" Effect works for a holder who may lack X (`Answers Twice` creates `sward` via `ward_grow {of: "hp"}`; all sitting Effects guard on `own.state.sitting-in-the-snow >= 1`).
  - [x] Vague words pinned into `rule`.
  - [x] Techniques' new bonuses and passives sized against same tier and marked as new in the review.
- [x] 8. Review file (`production/plans/stage6/lanh_giang-review.md`).
- [x] 9. Finish (`RECORD PASS DONE` and `production/plans/stage6/lanh_giang.done`).

RECORD PASS DONE
