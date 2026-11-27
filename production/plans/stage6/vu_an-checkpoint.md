# Stage 6 Checkpoint Review — `vu_an` (Vụ Ẩn Môn, Batch b04)

Unanchored review of staged records in [design/stage6-staging/vu_an/](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/vu_an/) and depth files in [design/world/depth/sects/](file:///C:/Users/xphuo/IdeaProjects/my-game/design/world/depth/sects/vu_an.md) against `production/plans/stage6/_brief-review.md`, `_brief-record.md`, `DECISIONS-2026-11-25.md`, `DECISIONS-2026-11-26.md`, and `tools/design/combat_sim/FIGHT-INPUT.md`.

---

## 1. Ranked Findings & Fixes Applied

### MUST-FIX (2)

1. **`The Wind Lifts the Mist` (`effects/vu_an.effects.json`) — `lantern_wear` desync when Wind hits spend a Lantern-Stone:**
   - **File / Record:** [vu_an.effects.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/vu_an/effects/vu_an.effects.json), `eff:The Wind Lifts the Mist:hit-stone` & `eff:The Wind Lifts the Mist:evade-stone`.
   - **What was wrong:** Both stone-spend records decremented `lantern_stone` (`add: -1`) without decrementing `lantern_wear` (`add: -2`), relying on `lantern-stone-sync-0/1/2` which only run on `pulse`. If a holder held `lantern_stone == 2` (`lantern_wear == 4`), a Wind hit lowered `lantern_stone` to `1` while leaving `lantern_wear` at `4`. Two non-wind hits before the next `pulse` then ran `lantern-stone-wear-4` -> `lantern-stone-wear-3` (`lantern_wear = 2`, `lantern_stone = 0`), breaking the last stone **without** clearing `mist_field = 0` (`sync-0` then cleared `lantern_wear = 0` on the next pulse while `mist_field` stayed up).
   - **Fix applied:** Declared `{"id": "lantern_wear", "cap": 6}` in `The Wind Lifts the Mist`'s own `"counters"` list and added `{"counter": {"id": "lantern_wear", "add": -2}}` to both `hit-stone` and `evade-stone`.

2. **`The Wind Lifts the Mist` (`effects/vu_an.effects.json`) — per-record `per_pulse: 1` allowed multi-hit (`split`) Wind arts to lift multiple layers in one pulse:**
   - **File / Record:** [vu_an.effects.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/vu_an/effects/vu_an.effects.json), `The Wind Lifts the Mist` (`hit-breath`, `hit-field`, `hit-stone`, `evade-breath`, `evade-field`, `evade-stone`).
   - **What was wrong:** Each of the 6 records carried its own `limit: {"per_pulse": 1}`, which only limits that individual record ID. Against a multi-hit (`split`) Wind art in a single pulse, sub-hit 1 could spend `lantern_stone` (`hit-stone`) and sub-hit 2 immediately end `mist_field` (`hit-field`), contradicting the rule (*"lifts one mist of yours"*) and the `approx` claim (*"once per pulse"*).
   - **Fix applied:** Added shared counter `{"id": "wind_lifted", "cap": 1}` and `eff:The Wind Lifts the Mist:pulse-reset` (`on: "pulse"`, resets `wind_lifted = 0`); gated all 6 Wind records on `own.counter.wind_lifted == 0` and set `wind_lifted = 1` on firing. Verified via split-hit Wind probe (`1` lift per pulse second across the fight).

### SHOULD (3)

3. **`lantern-stone` (`arts/part-sect-vu_an.json`) — `not_tags: ["wind"]` missed Wind-element arts tagged `"phong"`:**
   - **File / Record:** [part-sect-vu_an.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/vu_an/arts/part-sect-vu_an.json), `lantern-stone-wear-1..6`.
   - **What was wrong:** `part-sect-phat_y.json` (`brush-the-sleeve`, `a-thousand-sleeves`) uses `"phong"` rather than `"wind"` in `tags` with `"element": "wind"`, so `not_tags: ["wind"]` would let those Wind arts both trigger `The Wind Lifts the Mist` (`element: "wind"`) and wear `lantern_wear`.
   - **Fix applied:** Updated `filter` on `lantern-stone-wear-1..6` to `{"not_tags": ["wind", "phong"]}`.

4. **`Out of the Mist` (`effects/vu_an.effects.json`) — missed mist fields that open and end between two pulses:**
   - **File / Record:** [vu_an.effects.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/vu_an/effects/vu_an.effects.json), `Out of the Mist`.
   - **What was wrong:** `eff:Out of the Mist:watch` only ran on `pulse`. If `lock-the-road` fired mid-pulse and was lifted by Wind or shattered by `lantern-stone` before the next `pulse`, `out_mist_seen` remained `0` and `Out of the Mist` never armed.
   - **Fix applied:** Added `eff:Out of the Mist:watch-fire` (`on: "art_fired"`, `filter: {"tags": ["lock_road"]}`, `if: [mist_field >= 1, out_mist_seen == 0]`, `do: [out_mist_seen = 1]`).

5. **`Nobody Looked` (`effects/vu_an.effects.json`) — `nobody_ext_given` could stay `1` on mid-pulse shatter + immediate recast:**
   - **File / Record:** [vu_an.effects.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/vu_an/effects/vu_an.effects.json), `Nobody Looked`.
   - **What was wrong:** `eff:Nobody Looked:extend-reset` only ran on `pulse`. If a mist field ended mid-pulse and `lock-the-road` recast before the next `pulse`, `nobody_ext_given` stayed `1`, skipping the `+3 s` extension for the new field.
   - **Fix applied:** Added `eff:Nobody Looked:extend-clear-cast` (`on: "art_fired"`, `filter: {"tags": ["lock_road"]}`, `if: [nobody_ext_given >= 1]`, `do: [nobody_ext_given = 0]`). Post-fix `sect_fight.py` on `bang_yen_toa` (`--gap 0`): `Nobody Looked` runs rose `95 -> 107` and `The Mist Does Not Ask` runs rose `135 -> 145`.

### Verified Clean / Behaviour Confirmed (No Change Needed)

- **`Lost on the Road` (`bang_yen_toa` `51.1 s` with vs `48.8 s` without; previously `50.3 s` vs `48.8 s`):** Verified by full `plog` trace on `bang_yen_toa` (`seed 1`: `50.69 s` vs `43.36 s`; `seed 5`: `40.09 s` vs `48.71 s`). Because `engine.py` `timer` has no tag filter (`which` only accepts `all | others | longest | next`), `evade-spend` / `decoy-spend` uses `timer {side: "own", which: "all", by: -99}` as documented in `approx`. On `bang_yen_toa` (who carries no `escape`-tagged art), resetting all cooldowns at `t = 22.9 s` toggles `deep-lake-stance` back ON (`-30% dmg_more`) and shifts its toggle phase across seeds, whereas `chuc_minh_lo` (`49.0 s` vs `50.7 s`), `trieu_ngu_lang` (`51.6 s` vs `53.2 s`), and `ham_thanh_dang` (`49.0 s` vs `52.0 s`) are faster, and a holder with an escape art (`lantern-out`) gets the immediate reset and `+100 escape` (`escape_max 0.95` unless `bound`). Intended within the documented `approx`.
- **`mist_field` coexistence with `deep-lake-stance` & `haze-walk`:** Confirmed zero edits and zero duplication on `thuy_vi.*`. `lock-the-road` drives the mist field via counter `mist_field` and sets `mist-lock-field` (`tags: ["field"]`) only when `own.state.any == 0`, so `deep-lake` (`own.state.deep-lake >= 1`) is never overwritten or masked, and `haze-walk` (`step-into-the-green`, `haze-on-the-path`) defines no `states`.
- **`The Wind Lifts the Mist` Wind-foe probe:** Verified (`thai_van_xa` vs 10-seed Trúc Cơ Wind foe: `WITH` `15.87 s`, `lift_runs = 24`; `WITHOUT` `17.54 s`, `lift_runs = 0`).
- **Standalone compilation & consolidated checklist:** All 5 Effects in `vu_an.effects.json` declare every counter they read/write and pass `engine.validate` standalone; 0 `always`+`filter`, 0 multi-`mod` without `stack: true`, 0 invalid `temp_mods` filter keys (`art_id`/`status`); 0 ID/Effect-name collisions vs `assets/data/combat_effects.json`, committed `design/`, and all other staged `b04` dirs; `spatial_words_check.py --sect vu_an` has 0 non-soft rule hits (only 2 non-rule `ties.note` hits); all 3 linters (`lint_techniques.py`, `lint_arts.py`, `lint_items.py`) report `0 findings`.
- **Stand-ins & roots:** `0` stand-ins (`haze-walk` already committed under `thuy_vi`), `0` beasts, `0` root mismatches across all 17 living `vu_an` members.
- **Open item (`cast_ward_duration_pct`):** `+20` on `va-mist-lock-lantern` is valid in `modifiers.md` and `lint_items.py`, with no `CHARACTER_MODS`/`cast_wards` reader yet (`depth_gap.py` `lines: 1 open`), matching `vu_linh` precedent.

---

## 2. Pending Words

- `pending.json` absent (`0` pending words; all rules compile with existing engine words and `technique-effects`).

---

## 3. Holder Table (Post-Fix Verification)

Verified with `$env:DEPTH_STAGE = "C:\Users\xphuo\IdeaProjects\my-game\design\stage6-staging\vu_an"`:
- `lint_techniques.py`: `checked 3 techniques, 0 findings`
- `lint_arts.py`: `checked 4 arts in 1 files, 0 findings`
- `lint_items.py`: `checked 3 items, 22 bases, 9 common arts, 0 findings`
- `spatial_words_check.py --sect vu_an`: `0` rule hits (`2` non-rule `ties.note` hits)
- `depth_gap.py --sect vu_an`: `stand_ins 0, unknown_ids 0, cross_owner 7 (catalogue), ties_unmapped 0, ties_over_cap 0, engine_words 0, wishes_open 0, lines 12/13 runs (1 open: cast_ward_duration_pct)`
- `sect_fight.py vu_an --seeds 5` & `--gap 1 --seeds 5`: `17/17` living holders ran, `0 REFUSED`, all slotted active arts fired at both gaps.

| Holder(s) | Realm | Slotted Arts | Gap 0 (`--seeds 5`) | Gap 1 (`--seeds 5`) | Post-Fix Effect Runs & Art Fires (Gap 0) |
|---|---|---|---|---|---|
| `bang_yen_toa` | `truc_co` | `lock-the-road`, `lantern-stone`, `deep-lake-stance`, `step-into-the-green`, `haze-on-the-path`, `the-gate-is-not-there` | `51.1 s`, `5/5`, `100%` | `19.1 s`, `0/5`, `0%` | Arts `8.2 / 9.6 / 20.0 / 9.6 / 8.4 / 9.6` (`Gap 1`: `2.6 / 3.2 / 6.2 / 2.8 / 2.8 / 2.8`). `Lost on the Road` `51.1s` vs `48.8s` (`runs 25`); `The Mist Does Not Ask` `51.1s` vs `52.2s` (`runs 145`); `Nobody Looked` `51.1s` vs `50.4s` (`runs 107`); `The Wind Lifts the Mist` `runs 0` (Wind-only trigger). |
| `trieu_ngu_lang` | `ket_dan` | `lock-the-road`, `lantern-stone`, `deep-lake-stance`, `step-into-the-green`, `haze-on-the-path` | `51.6 s`, `5/5`, `100%` | `15.2 s`, `0/5`, `0%` | Arts `9.0 / 9.6 / 19.2 / 9.6 / 7.8` (`Gap 1`: `1.8 / 1.8 / 4.8 / 2.0 / 1.6`). `Lost on the Road` `51.6s 100%` vs `53.2s 99%` (`runs 25`); `Out of the Mist` `51.6s` vs `52.3s` (`runs 118`); `The Wind Lifts the Mist` `runs 0`. |
| `chuc_minh_lo` | `truc_co` | `lock-the-road`, `lantern-stone`, `deep-lake-stance`, `step-into-the-green` | `49.0 s`, `5/5`, `100%` | `13.8 s`, `0/5`, `0%` | Arts `8.4 / 9.2 / 18.4 / 9.2` (`Gap 1`: `1.4 / 1.4 / 3.8 / 1.8`). `Lost on the Road` `49.0s` vs `50.7s` (`runs 25`). |
| `ham_thanh_dang`, `luyen_to_y` | `truc_co` | `lock-the-road`, `lantern-stone`, `deep-lake-stance`, `step-into-the-green`, `haze-on-the-path` | `49.0 s`, `5/5`, `98%` | `14.0 s`, `0/5`, `0%` | Arts `8.4 / 9.0 / 18.0 / 8.8 / 7.2` (`Gap 1`: `1.4 / 1.2 / 3.8 / 1.8 / 1.2`). `Lost on the Road` `49.0s` vs `52.0s` (`runs 25`). |
| `thai_van_xa` | `truc_co` | `lock-the-road`, `lantern-stone`, `deep-lake-stance` | `52.3 s`, `5/5`, `83%` | `10.4 s`, `0/5`, `0%` | Arts `6.0 / 6.0 / 18.0` (`Gap 1`: `0.6 / 0.4 / 2.8`). `The Wind Lifts the Mist` `runs 0` (verified in Wind probe: `lift_runs = 24`, `15.87s` vs `17.54s`). |
| `nham_tung_anh` | `luyen_khi` | `lock-the-road`, `lantern-stone`, `step-into-the-green` | `50.2 s`, `0/5`, `0%` | `10.4 s`, `0/5`, `0%` | Arts `7.4 / 7.4 / 7.8` (`Gap 1`: `1.0 / 1.0 / 1.2`). |
| `khuyet_lac_vu` | `luyen_khi` | `lock-the-road`, `lantern-stone` | `42.8 s`, `0/5`, `0%` | `9.4 s`, `0/5`, `0%` | Arts `4.8 / 4.6` (`Gap 1`: `0.6 / 0.6`). |
| `bao_thuy_hanh` | `truc_co` | `a-breath-of-road-mist` | `46.2 s`, `0/5`, `0%` | `9.6 s`, `0/5`, `0%` | Art `8.8` (`Gap 1`: `1.4`). |
| 8 `luyen_khi` outer disciples (`dao_thach_an`, `bien_ha_huong`, `quan_da_tu`, `tap_minh_nhi`, `ham_tieu_vu`, `tap_xuan_tra`, `mao_dao_bi`, `ky_that_lo`) | `luyen_khi` | `a-breath-of-road-mist` | `40.4 s`, `0/5`, `0%` | `9.2 s`, `0/5`, `0%` | Art `7.6` (`Gap 1`: `1.4`). |

CHECKPOINT DONE
