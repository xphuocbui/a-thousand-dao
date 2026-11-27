# Stage 6: Củng Tinh Quán (progress file)

Method: `production/plans/world-depth-implementation.md` Stage 6, "the per-sect method" and `production/plans/stage6/_brief-record.md`.
Owner: `cung_tinh`. Decisions are auto-accepted (user 2026-11-26) and logged in `production/plans/stage6/cung_tinh-review.md`.

## Scope (gap report `python -I tools/design/world/depth_gap.py --sect cung_tinh`)
- **4 techniques:** `star-pacing-primer` (Yellow main), `bowing-stars-canon` (Earth main), `armillary-array-canon` (Profound secret), `star-lake-mirror` (Earth secret).
- **8 new arts:** `seven-steps`, `the-stars-bow`, `fixed-pole`, `ring-of-the-hour`, `the-handle-turns`, `The Twelve Hours` (passive art Effect d16), `read-the-water`, `the-star-goes-out`.
- **5 items, 2 sets, 4 item/set Effects** (+ 1 passive art Effect `The Twelve Hours`).
- **0 stand-ins, 0 beasts, 3 structured events.**
- **4 cross-owner references from `market-folk`** (`phong_kinh_sa`, `ngu_hoa_sa`, `ve_van_co` naming `cung_tinh` techniques); `cung_tinh` references no unpromoted foreign methods (only `earth-mountain-pressing-seal`, already in `design/items/catalogue-earth.json`).

## Steps
- [x] 1. Verify first: mechanic table below, `spatial_words_check.py`.
      - `spatial_words_check.py`: 1 false positive (`ct-armillary-rings :: sets.bonuses.effect :: Within the Ring`, matching the Effect's title `"Ring Within the Ring"`; its rule was already rewritten by d46 to use Field and Bound).
- [x] 2. Techniques and arts (staged in `design/stage6-staging/cung_tinh/`).
- [x] 3. Effects and pending words (staged in `design/stage6-staging/cung_tinh/`).
- [x] 4. Items and sets (staged in `design/stage6-staging/cung_tinh/`).
- [x] 5. Stand-ins (`0`, none needed) and depth art ids in `design/world/depth/sects/cung_tinh.techniques.json`.
- [x] 6. Beasts (`0`, none).
- [x] 7. Holder check: linters (`lint_techniques.py`, `lint_arts.py`, `lint_items.py`), `sect_fight.py cung_tinh` and `--gap 1`.
      - `lint_arts.py`: checked 7 arts, 0 findings (`fixed-pole empower 1: x1.31 of the lint, gated`).
      - `lint_techniques.py`: checked 4 techniques, 0 findings (`8.0/8`, `22.3/24`, `13.7/16`, `22.6/24`).
      - `lint_items.py`: checked 5 items, 0 findings (R6 note on `ct-prioress-robe`).
      - `engine.validate`: `None` (0 errors) across all 5 Effects (`The Twelve Hours`, `Seen in the Water`, `Keeper of the Hours`, `The Field Turns`, `Ring Within the Ring`).
      - `sect_fight.py cung_tinh` (18 living cast): all 7 active arts fire on every holder, all 4 item/set Effects run and change fights; `--gap 1` clean (0 wins vs typical foe one realm up).
      - `The Twelve Hours` (`tree_effects` probe): verified working on all 4 `armillary-array-canon` L4+ holders (`tham_bac_than` 27.9 s 82% -> 22.5 s 84%, `to_tinh_nghi` 28.2 s 76% -> 22.5 s 77%, `pho_cuong_dau` & `sam_lac_thiet` 32.9 s 62% -> 24.7 s 67%; 150–195 runs/20 seeds).
- [x] 8. Review file (`production/plans/stage6/cung_tinh-review.md`).
- [x] 9. Finish (`RECORD PASS DONE`, `production/plans/stage6/cung_tinh.done`).

## Step 1: Mechanic table

| Record | Mechanic | Group / Resolution |
|---|---|---|
| `star-pacing-primer` | Tier 0 main (`tho`, `kim`, 6 layers); no bonuses/passives in depth | Engine has it (new passives sized to 8 W) |
| `seven-steps` | 7 arts leave marks; on 7th, Field rises: 1 Slowed Time on foe, dampen taken | Engine has it (`counter`, `state` tagged `field`, `slowed_time`, `dampen_taken`) |
| `bowing-stars-canon` | Tier 2 main (`tho`, 12 layers); `b7` line `stack_effect_pct 14 [tho, debuff]` + new bonuses/passives | Engine has it (sized to 24 W) |
| `the-stars-bow` | Slow field: foe next art waits 0.3 s, Slowed Time + Earth stack each s | Engine has it (`counter`, `state` tagged `field`, `timer`, `stacks`, `slowed_time`) |
| `fixed-pole` | After 3 s Composed, Earth arts deal more & timer_resist; resets when not Composed | Engine has it (`own.composed_time >= 3`, `empower`, `L5 [tho]`, `timer_resist`) |
| `armillary-array-canon` | Tier 1 secret (`tho`, `kim`, 9 layers); carries passive art `The Twelve Hours` | Fight engine has it; technique attachment uses pending word `technique-effects` |
| `ring-of-the-hour` | Ring array: foe deals less damage (`dampen_taken`) & takes Earth damage/tick; 2nd ring doubles | Engine has it (`each_for: 14` charge counter `ring`, `summon`, `state` tagged `field`, `dampen_taken`) |
| `the-handle-turns` | Rotates/refreshes laid arrays and moves a step | Engine has it (`counter` add + `summon`, `refresh` Earth debuffs, `timer` delay 0.3 s) |
| `The Twelve Hours` (d16) | 5 s hours: +30% in own hour; at 3+ distinct hours turns, refreshes & +6%/hr + Slowed Time/s | Fight engine has `counter_hours` & `counter_this_hour`; attachment needs pending word `technique-effects` |
| `star-lake-mirror` | Tier 2 secret (`tho`, `kim`, 12 layers, head only) | Engine has it (sized to 24 W) |
| `read-the-water` | 4 s foresight: +evade, +ward_pct, counter-strikes crit | Engine has it (`evade`, `ward_pct`, `was_hit`/`evaded` -> `sure_crit`) |
| `the-star-goes-out` | Dims buffs & lowers fight luck (`khi_van`) for a long while | Engine has it (existing words: `strip`, `exposed`, 12 s Earth stacks for accuracy down; `khi_van` is out-of-fight) |
| `Seen in the Water` | Wards the first art the foe uses | Engine has it (`was_hit` `kind: art` `per_fight: 1` full heal + `mirror_warded` counter) |
| `Keeper of the Hours` | Arrays last +1/3; first array free | Engine has `next_art_cost: 0`; extra 1/3 uptime approximated via lingering summon / `stars_bow` extension |
| `The Field Turns` | Array field + Composed: every 4 s Earth stack + 0.3 s delay; Mirror-warded foe takes 2x next array | Engine has it (`field_up`, `composed`, `mirror_warded`, `dmg_more`) |
| `Ring Within the Ring` (d46) | 2nd Ring of the Hour: foe Bound & takes each ring's damage each s | Engine has it (`own.counter.ring >= 2`, `bound`, `dmg_more` on ring summons) |
| 5 signature items | `sources: ["npc"]`, `unique: true`, R6 `exception` on `ct-prioress-robe`, `rarity: 5` on `ct-star-lake-mirror` | Engine & linters have it |

RECORD PASS DONE
