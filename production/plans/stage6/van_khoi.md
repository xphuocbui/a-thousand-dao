# Stage 6: Vân Khởi Quán (`van_khoi`) — Progress

Method: `production/plans/stage6/_brief-record.md` and `production/plans/world-depth-implementation.md` Stage 6.
Headless job: decisions auto-accepted against design rules and logged in `van_khoi-review.md` and `van_khoi.done`.

## Scope (`python -I tools/design/world/depth_gap.py --sect van_khoi`)
- **Techniques (3):** `water-ends-primer` (Yellow main, element-free), `sitting-cloud-canon` (Earth main, element-free), `cloud-mother-seal` (Profound secret, element-free). Existing carried arts: `lamp-oil-lance`, `frozen-hour-seal`. Existing body technique: `hundred-echo-palm-scripture`.
- **New arts (4):** `not-counting-the-steps` (Bất Kế Bộ), `clouds-rise` (Vân Khởi), `the-water-has-ended` (Thủy Cùng), `cloud-in-the-pane` (Song Trung Vân).
- **Items (6) and sets (2):** `vk-rising-cloud-robe`, `vk-cloud-mother-mirror`, `vk-empty-hall-bell`, `vk-thoi-censer`, `vk-hundred-echo-seal`, `vk-mica-reader-robe`; sets `vk-empty-mountain` (3pc), `vk-readers-pair` (2pc).
- **Effects (3):** `Sit and Watch` (`vk-rising-cloud-robe`), `Sit as Thôi Sat` (`vk-empty-mountain`), `Read Aloud` (`vk-readers-pair`).
- **Stand-ins:** 0 (all 19 living members use `van_khoi` lineage techniques).
- **Beasts:** 0.
- **Events:** 6 structured (`N-van_khoi-01..06`).
- **Spatial words check:** 0 hits in rule/concept/lore fields (4 soft/postponed notes in `ties.note` only).
- **Open modifier line:** `cast_ward_duration_pct` (`+20` on `vk-cloud-mother-mirror`) — valid in `lint_items.py` / `modifiers.md`, no `CHARACTER_MODS` / `cast_wards` reader yet.

## Mechanic Table (Step 1)
| Record | Kind | Mechanic Summary | Engine Support |
|---|---|---|---|
| `water-ends-primer` | Technique (T0 main) | Element-free (`names: []`, `b02`), `[NEW]` tier-0 passives (`8.0 W / 8`) | Has it (`b02` `names: []`) |
| `sitting-cloud-canon` | Technique (T2 main) | Element-free (`names: []`, `b02`), `[NEW]` tier-2 bonuses + passives (`23.8 W / 24`) | Has it (`b02` `names: []`) |
| `cloud-mother-seal` | Technique (T1 secret) | Element-free (`names: []`, `b02`), `[NEW]` tier-1 bonus + passives (`15.0 W / 16`) | Has it (`b02` `names: []`) |
| `not-counting-the-steps` | Art (Primer L1) | `uncounted-walk` Pressing stance; +4 pp evade/s (`walk_step`), escalating qi upkeep (`0.004/stack`), clears on `was_hit` (`event.amount > 0`) | Has it (`state`, `upkeep`, `evade`, `was_hit`) |
| `clouds-rise` | Art (Canon L2) | `clouds-watching` Composed stance; after 2 s Composed (`composed_time >= 2`), banks 1 `cloud`/s at escalating qi cost (`0.003 * (1 + cloud)`); next `soul` art spends all Clouds for `+10 % x_soul` + `+15 % status_dur` per Cloud | Has it (`state`, `composed_time`, `gain_qi`, `x_soul`, `status_dur`) |
| `the-water-has-ended` | Art (Canon L4) | Stance ward (`ward_grow` 5 % hp) + `soul_res 12` / `status_resist 20` for 8 s; while Composed (8 s cd), turns aside 1st status via pulse cleanse + `gain_qi` 3 % + `soul_res` 8 (`approx` for thần thức recovery) | Has it (approx: pulse cleanse + `gain_qi`/`soul_res`) |
| `cloud-in-the-pane` | Art (Seal L3) | Seal strike (`c 1.4`); on `hit_landed`, `slowed_time` (1, 3 s) + `sealed_meridian` (3 s) + `timer` foe next `+1.5 s` + `dampen_taken 100` (`for: 3 s`, halving incoming damage to wards) | Has it (approx: `sealed_meridian` + `dampen_taken 100`) |
| `Sit and Watch` | Effect (`vk-rising-cloud-robe`) | While `composed_time >= 3`, `dampen_taken 13.64` (12 % less damage); when a status ends on you (pulse watcher), `gain_qi` 2 % + `soul_res 6` (`for: 4 s`) (`approx` for thần thức recovery) | Has it (approx: pulse status-end watcher + `gain_qi`/`soul_res`) |
| `Sit as Thôi Sat` | Effect (`vk-empty-mountain` 3pc) | Every 5 s Composed banks 1 `cloud`; on `was_hit` with `cloud >= 5`, spends all Clouds for `1.5 c` palm + `0.6 c * cloud` echo `free_hit` (`phys`) | Has it (`composed`, `cloud`, `free_hit`) |
| `Read Aloud` | Effect (`vk-readers-pair` 2pc) | `bell_ring` (`each_for: 6.5`) at `fight_start` and on `was_hit` (`cd: 8 s`); `soul` arts cast while `bell_ring >= 1` get `+25 % status_dur` and count toward 3; 3rd brings next own art ready (`timer next -99`) | Has it (`each_for`, `status_dur`, `timer next`) |

## Steps
- [x] 1. Verify first: gap report, spatial words check, mechanic table.
- [x] 2. Techniques and arts (staged: 3 techniques, 4 new arts; `id`s written into `van_khoi.techniques.json`).
- [x] 3. Effects (staged: 3 Effects in `van_khoi.effects.json`, all standalone-valid).
- [x] 4. Items and sets (staged: 6 unique items, 2 sets).
- [x] 5. Stand-ins (none needed — 0 stand-ins).
- [x] 6. Beasts (none — 0 beasts).
- [x] 7. Holder check (`lint_arts`, `lint_techniques`, `lint_items`: 0 findings; `depth_check`: none; `sect_fight.py --gap 0/1`: 0 REFUSED, all 6 carried arts fire, Effects verified + status & 5-Cloud probes).
- [x] 8. Review file (`production/plans/stage6/van_khoi-review.md`).
- [x] 9. Finish (`RECORD PASS DONE`, `van_khoi.done`).

RECORD PASS DONE
