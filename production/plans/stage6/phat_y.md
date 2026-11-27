# Stage 6: Phất Y Cốc (`phat_y`, progress file)

Owner: `phat_y`
Brief: `production/plans/stage6/_brief-record.md`
Plan ref: `production/plans/world-depth-implementation.md`
Staging dir: `design/stage6-staging/phat_y/`

## Scope (gap report 2026-11-27, `python -I tools/design/world/depth_gap.py --sect phat_y`)
- **3 techniques** (`dry-road-sword-primer`, `contract-sword-canon`, `brushed-sleeve-step`)
- **5 new arts** (`noon-guard`, `final-count`, `step-back`, `brush-the-sleeve`, `a-thousand-sleeves`)
- **4 items** (`py-grey-sleeve`, `py-contract-seal`, `py-sleeve-token`, `py-contract-blade`) and **2 sets** (`py-grey-seal`, `py-hired-pair`)
- **4 Effects** in `phat_y.effects.json` (`Serve a Term`, `Gone Before Thanks`, `Paid in Full`, `The Last Step`)
- **0 stand-ins**, **0 beasts**, **2 cross-owner refs** (`loose-south`'s `tu_ban_kiem` and `market-folk`'s `dieu_thiet_tien` on `dry-road-sword-primer`, closed once `phat_y` merges), **3 structured events** (`N-phat_y-01..03`)

## Step 1: Mechanic Table
| Source | Mechanic | Engine Status |
|---|---|---|
| `dry-road-sword-primer` / `noon-guard` | Stance: reduces incoming damage (`dampen_taken`), each hit taken grants Heat boosting next cut | **Has** (`states`, `dampen_taken`, `was_hit`, `dmg_more`, `hit_landed`) |
| `contract-sword-canon` (`Serve a Term`) | Each second Pressing without striking with an art serves 1 Term; enemy art hits strip 1 Term | **Has** (`own.pressing`, `pulse`, `hit_landed`, `was_hit`, `counter`) |
| `final-count` | Spends all Terms on Metal strike scaling damage and crit per Term; >=5 Terms ignores part of defence | **Has** (`scale`, `mod` `dmg_more`/`crit`/`pen` scoped `art_id`, `empower` `bypass`) |
| `step-back` | Movement step; Breaking foe or exhausting its ward grants evade for 1 s | **Has** (`movement` tag, `broken`, `hit_landed` `foe.qi_share`, `mod` `evade`) |
| `brushed-sleeve-step` / `brush-the-sleeve` | Turns next attack (`decoy`), then faster Metal strikes for a breath | **Has** (`decoy`, `decoy_struck`, `mod` `art_speed` scoped `metal`; counters-only so `thang_vo_ta`'s `flurry-stance` never collides) |
| `a-thousand-sleeves` | For 4 s strikes leave Force afterimages; cannot be singled out (decoy + evade/dampen) | **Has** (`free_hit` `force`, `decoy`, `evade`, `dampen_taken`; counters-only) |
| `Gone Before Thanks` (`py-grey-sleeve`) | Vanish for 2 s (untargetable + next Metal strike sure crit) on foe Broken/defeated | **Has** (`broken`, `decoy`, `evade`, `sure_crit` scoped `metal`; adapted from `dies or flees` in 1v1) |
| `Paid in Full` (`py-contract-seal`, `py-hired-pair`) | Protect hirer: -20 % damage taken, heal on strike/crit (2 % crit heal) | **Has** (`was_hit` -> `dampen_taken: 20`, `crit` -> `heal: 0.02`; 1v1 duel adaptation, idempotent across item+set) |
| `The Last Step` (`py-grey-seal` 2pc) | After vanish/evade, next sword art within 2 s +30 % dmg; Broken vanishes again; Return to the Scabbard after 3 s without damaging art | **Has** (`evaded`, `broken`, `last_step` `each_for: 2`, `dmg_more`, `scabbard_acted`/`scabbard_idle` -> vanish + un-evadable `acc: 500`) |

## Steps
- [x] 1. Verify first: mechanic table & `spatial_words_check.py`.
- [x] 2. Techniques and arts (staged in `design/stage6-staging/phat_y/techniques/catalogue-sect-phat_y.json` and `arts/part-sect-phat_y.json`; art ids wired in `design/world/depth/sects/phat_y.techniques.json`).
- [x] 3. Effects (staged in `design/stage6-staging/phat_y/effects/phat_y.effects.json`: 4 Effects, `STANDALONE_EFFECT_CHECK: OK 4`).
- [x] 4. Items and sets (staged in `design/stage6-staging/phat_y/items/catalogue-sect-phat_y.json` and `sets-phat_y.json`).
- [x] 5. Stand-ins (`0` needed) and Beasts (`0` needed).
- [x] 6. Holder check (`lint_arts.py`, `lint_techniques.py`, `lint_items.py` all `0 findings`; `depth_check.py` `findings: none`; `depth_gap.py --sect phat_y`; `sect_fight.py phat_y --seeds 5 --gap 0` and `--gap 1` `0 REFUSED`, `0 NEVER_FIRED`; targeted `thang_vo_ta` and 5-seed `final-count` empower probes passed).
- [x] 7. Review file (`production/plans/stage6/phat_y-review.md`).
- [x] 8. Finish (`RECORD PASS DONE` and `production/plans/stage6/phat_y.done`).

RECORD PASS DONE
