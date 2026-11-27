# Stage 6: Trạc Anh Đài (progress file)

Method: `production/plans/world-depth-implementation.md` Stage 6, "the per-sect method", and `production/plans/stage6/_brief-record.md` (headless record pass, batch `b04`, decisions auto-accepted).

## Scope (`python -I tools/design/world/depth_gap.py --sect trac_anh`)
- **Techniques (2):** `canglang-body-canon` (Profound `body`, `names: []`), `whale-line-harpoon` (Profound `secret`, `names: []`). Existing referenced: `unbroken-flesh-canon`, `hundred-echo-palm-scripture`, `undertow-litany`.
- **New arts (5):** `wash-the-hat-strings`, `wash-the-feet`, `ninth-fathom`, `throw-the-iron`, `haul-in`.
- **Items (4) & Sets (1):** `ta-canglang-harpoon`, `ta-white-whale-coat`, `ta-goose-bone-beads`, `ta-sworn-ice-ring`; set `ta-old-ivory-hunt`.
- **Effects (2):** `The Line Holds` (item `ta-canglang-harpoon`), `Drag It to the Ice` (set `ta-old-ivory-hunt`).
- **Beasts (2):** `lang_nhi`, `tiem_nhi` (`owner_id: "doan_to_ba"`, already wired in `trac_anh.cast.json` `"beasts": ["lang_nhi", "tiem_nhi"]`; closes at Stage 7 export).
- **Stand-ins:** `0`. **Cross-owner:** `0`. **Ties over cap / unmapped:** `0`. **Events:** `2` structured (`N-trac_anh-01`, `N-trac_anh-02`, close at Stage 7).

## Step 1: Mechanic Table (Verify First)
| Record | Kind | Depth mechanic | Engine support / mapping | Status |
|---|---|---|---|---|
| `canglang-body-canon` | Technique (Profound `body`) | No element (`names: []`), 9 layers, endurance/cold water body | `bonus_count: 1`, passives sized <= 16 W (`khi_huyet_pct 12`; `health_regen_inc_pct 12`, `resist_pct 75 [cold]`, `body_shield_pct 8`, `status_resist_pct 8`, `defense_pct 3`) | Ready |
| `whale-line-harpoon` | Technique (Profound `secret`) | Element-free force secret (`names: []`), binds & delays | `bonus_count: 1`, passives sized <= 16 W (`attack_pct 8`; `attack_pct 6 [physical]`, `pierce_pct 4`, `status_duration_pct 12 [curse]`, `art_speed_pct 5 [physical]`) | Ready |
| `wash-the-hat-strings` | Art (`canglang-body-canon` L1) | Breath held: health regenerates + cold damage taken halved | `art_fired`: `hregen 0.025` for 4 s + separate record `dampen_taken 100 [dtype: cold]` for 4 s | Ready |
| `wash-the-feet` | Art (`canglang-body-canon` L2) | Low stance after being hit: next hit taken turned into body shield | `wash-the-feet` Composed stance (`block 10`); `was_hit` (`event.amount > 0`) arms `wash_feet_armed`, next damaging `was_hit` refunds `event.amount` + adds `event.amount` to `body_bar` (`body_shield: true`) and exits stance | Ready |
| `ninth-fathom` | Art (`canglang-body-canon` L6) | Once/fight: 1 s no damage + clears every slowing effect | `unlock_layer: 6` (suite <= 6 rule), `cooldown: 6.0`, `each_for: 1.0` timer counter + `dampen_taken 10000` for 1 s + `was_hit`/`tick_taken`/`soul_taken` refund + `cleanse {status: "slowed_time"}` & `drunk` | Ready |
| `throw-the-iron` | Art (`whale-line-harpoon` L1) | Non-spatial rewrite: Bound (cannot flee) + Slowed Time | `c_art 1.35`, `cooldown: 4.0`, `statuses`: `bound` (3 s) + `slowed_time` (2 s) | Ready |
| `haul-in` | Art (`whale-line-harpoon` L4) | Delays Bound foe's soonest art 0.3 s; Physical scaled by Bound duration | `empower` on `foe.status.bound >= 1` (`timer {side: "foe", which: "next", by: 0.3}`, `c_mult 1.6`) + `line_held` pulse counter + `always` `dmg_more 0.15` scoped `tags: ["haul_in"]` | Ready |
| `The Line Holds` | Item Effect (`ta-canglang-harpoon`) | While Bound, hits heal 3 % of damage dealt | `hit_landed` (`foe.status.bound >= 1`, `event.amount > 0`): `heal {of: "amount", share: 0.03}` | Ready |
| `Drag It to the Ice` | Set Effect (`ta-old-ivory-hunt`) | Each second Bound holds: +1 % HP & +4 % Physical damage taken; lost when Bind ends | `pulse` clear/tick on `foe.status.bound` with `ivory_bind` counter + `always` `dmg_more 0.04 [dtype: phys]` scaled by `ivory_bind` | Ready |

## Steps
- [x] 1. Verify first: mechanic table, `depth_gap.py`, `spatial_words_check.py`.
- [x] 2. Techniques and arts (staged under `design/stage6-staging/trac_anh/`) + depth art ids in `trac_anh.techniques.json`.
- [x] 3. Effects (staged under `design/stage6-staging/trac_anh/effects/trac_anh.effects.json`).
- [x] 4. Items and sets (staged under `design/stage6-staging/trac_anh/items/`).
- [x] 5. Stand-ins (none needed; verified 0).
- [x] 6. Beasts (`doan_to_ba` `beasts` field verified: `["lang_nhi", "tiem_nhi"]`).
- [x] 7. Holder check (`DEPTH_STAGE` linters: 0 findings across arts/techniques/items; `depth_check.py`: 0 findings; `sect_fight.py` `--gap 0` & `--gap 1`: all 5 arts fired `>= 1.0`, both Effects ran; targeted probes green).
- [x] 8. Review file (`production/plans/stage6/trac_anh-review.md`).
- [x] 9. Finish (`trac_anh.done`, `RECORD PASS DONE`).

RECORD PASS DONE
