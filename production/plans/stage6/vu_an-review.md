# Stage 6 Record Pass Review — `vu_an` (Vụ Ẩn Môn)

## Summary

- **What was built ([design/stage6-staging/vu_an/](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/vu_an/))**:
  - **Techniques (3)** in [catalogue-sect-vu_an.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/vu_an/techniques/catalogue-sect-vu_an.json): `road-mist-primer` (Tier 0 `main`), `mist-lock-array-canon` (Tier 1 `main`), and `hidden-gate-array` (Tier 1 `secret`), each with `[NEW]` tier-sized unpriced `bonuses` (`0` / `1` / `1`) and `passives` (`7.9 W / 8`, `13.0 W / 16`, `14.6 W / 16`). Committed cross-owner secret technique `haze-walk` (`thuy_vi`) is reused by ID and not duplicated.
  - **Active Arts (4)** in [part-sect-vu_an.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/vu_an/arts/part-sect-vu_an.json): `a-breath-of-road-mist`, `lock-the-road`, `lantern-stone`, and `the-gate-is-not-there`. Reference art `deep-lake-stance` (`family-water.json`) is carried at layer 4 on `mist-lock-array-canon`. Passive arts `The Wind Lifts the Mist` (`d49`, L1) and `Lost on the Road` (`d2`, L5) are wired via `technique-effects`.
  - **Effects (5)** in [vu_an.effects.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/vu_an/effects/vu_an.effects.json): 2 passive-art technique Effects (`The Wind Lifts the Mist`, `Lost on the Road`), 2 item Effects (`The Mist Does Not Ask`, `Out of the Mist`), and 1 full-set Effect (`Nobody Looked`). Every Effect declares all counters it reads or writes in its own `"counters"` array and passes standalone `engine.validate`.
  - **Items (3) & Sets (1)** in [catalogue-sect-vu_an.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/vu_an/items/catalogue-sect-vu_an.json) and [sets-vu_an.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/vu_an/items/sets-vu_an.json): `va-mist-lock-lantern` (`treasure`, `rarity: 4`), `va-bobtail-axe` (`artifact`, `grade: 3`, R6 `exception`), `va-milestone-flag` (`artifact`, `grade: 2`), and 2-piece set `va-road-mist`.
  - **Depth edits**: added `"id"` fields before `"new"` for the 4 active arts in [vu_an.techniques.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/world/depth/sects/vu_an.techniques.json).
  - **Stand-ins & Beasts**: `0` stand-ins (`haze-walk` already committed under `thuy_vi`), `0` beasts, `7` `cross_owner` pointers (`haze-walk`), `0` early promotions.
- **Deviations**: 8 documented engine adaptations (listed below).
- **Decisions taken for the user (auto-accepted)**: 8 decisions with reasons below.
- **Pending words**: None (`pending.json` not needed; all rules compile with existing engine words and `technique-effects`).
- **Never ran in `sect_fight.py`**: `The Wind Lifts the Mist` (`road-mist-primer` L1 & `mist-lock-array-canon` L1 passive) reported `runs 0 NEVER_RAN` against `typical` because `typical` casts no `wind`-element arts; verified in a 10-seed Wind-foe probe (`thai_van_xa` `wind_runs = 26`, survival dropping `18.89 s -> 17.16 s`).
- **Open items**:
  1. `cast_ward_duration_pct` (`+20` on `va-mist-lock-lantern`): valid in `lint_items.py` / `modifiers.md`, currently has no `CHARACTER_MODS` / `cast_wards` reader in `combat_engine.json` (`depth_gap.py` `lines` 1 open).
  2. Depth `arts_new` rows for passive arts `Lost on the Road` and `The Wind Lifts the Mist` remain without active art IDs in `vu_an.techniques.json` because they are promoted via `technique.effects` (`b01` `technique-effects` precedent).
  3. R6 `exception` kept on `va-bobtail-axe` (`phu`, `weapon`) until an authored weapon art or ward is ruled.
  4. 5 structured events (`N-vu_an-01..05`) in [vu_an.events.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/world/depth/events/vu_an.events.json) close at Stage 8 export.

---

## Auto-Accepted Decisions (with Reasons)

1. **Coexist `lock-the-road` with `deep-lake-stance` via counter `mist_field` (`thinh_vu` pattern)**: `mist-lock-array-canon` carries `deep-lake-stance` at L4 alongside `lock-the-road` at L1. Following `the-night-is-long`, `lock-the-road` drives the mist field on counter `mist_field` and claims state `mist-lock-field` (`tags: ["field"]`) only when `own.state.any == 0` (clearing `state: null` only when `own.state.mist-lock-field >= 1`), so `deep-lake` is never overwritten and `mist_field` never breaks on stance toggles.
2. **Share explicit counters (`mist_field`, `lantern_stone`, `mist_lantern`, `road_mist`) cleanly across `effects/vu_an.effects.json` and `arts/part-sect-vu_an.json`**: Every Effect in [vu_an.effects.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/vu_an/effects/vu_an.effects.json) declares every counter it reads or writes in its own `"counters"` list so standalone `engine.validate` and `effect_compiler.gd` parity pass without needing cross-file symbol inference.
3. **Set `lock-the-road` cooldown to `8.0 s` (matching its `8 s` field duration)**: With `cooldown: 10.0`, Luyện Khí holder `khuyet_lac_vu` died at `8.6 s` at `--gap 1` before ever casting `lock-the-road` (`fires 0.0`). At `cooldown: 8.0` (with guard `mist_field == 0`), `khuyet_lac_vu` fires `lock-the-road` (`0.6` at `--gap 1`, `4.8` at `--gap 0`) while still never overlapping an active field.
4. **Model `lantern-stone` durability as 1 stone = 2 hits of wear (`lantern_wear`, ascending `== 1..6` dispatch)**: The depth rule states *"Gains a lantern-stone charge... it is worn by the foe's hits, and when it is gone the field ends."* Giving each cast `+1` `lantern_stone` (`cap: 3`) and `+2` `lantern_wear` (`cap: 6`) with non-wind (`not_tags: ["wind"]`) `event.amount > 0` wear records ordered `1 -> 6` prevents single-hit shatter, prevents double-spending on Wind hits alongside `The Wind Lifts the Mist`, and eliminates same-event cascade bugs.
5. **Express `lock-the-road` per-second foe accuracy loss as equivalent `own` `evade` scaling (`+2` per pulse elapsed)**: `engine.py` has no `"side": "foe"` on `mod` and computes `p_ev` from `(dfn.evade - att.acc)`. Adding `+18 evade` base plus `+2 evade` per `mist_field_age` pulse matches `"you gain evasion, the foe loses accuracy for each second of the field"` in 1v1 combat without injecting `drunk` Water-vulnerability side effects.
6. **Use `own.composed >= 1` vs `== 0` for `The Mist Does Not Ask` *"stand inside / leave it"***: Per `DECISIONS-2026-11-26` (no spatial fight), `own.composed >= 1` represents standing steady inside the mist (`mist_lantern = 1` pauses normal pulse decay), while `own.composed == 0` (on movement/evade via `step-into-the-green`, `the-gate-is-not-there`, or dodging) deducts `-2` per pulse.
7. **Size `[NEW]` tier-0/1 `bonuses` and `passives` to catalogue budgets and set `Lost on the Road` `unlock_layer: 5`**: `vu_an.techniques.json` lists no bonuses or passives; sized tier-0 passives to `7.9 W / 8` (`road-mist-primer`) and tier-1 `bonuses` (`linh_luc_pct 12`, `than_thuc_pct 10`) + passives (`13.0 W / 16` and `14.6 W / 16`) for Wood/Water evasion, sense, and array sustain. `Lost on the Road` (`unlock_layer: 5`, unspecified in depth) matches Trúc Cơ holders `luyen_to_y` and `chuc_minh_lo`.
8. **Stage `va-mist-lock-lantern` with `rarity: 4`, `unique: true` on all 3 items, and R6 `exception` on `va-bobtail-axe`**: Depth gives `kind: "treasure", grade: 3` on `va-mist-lock-lantern`; `lint_items.py` requires `rarity` in `(4, 5)` on treasures (`rarity: 4` -> grade `3`), `sources: ["npc"]`, `unique: true` (`bang_tam` R6/20f), and an R6 `exception` on `phu` weapon `va-bobtail-axe`.

---

## Băng Tâm Pilot Checklist

- [x] Every Effect changes the fight or verified probe outcome with vs without it (`Lost on the Road`, `The Mist Does Not Ask`, `Out of the Mist`, `Nobody Looked` in `sect_fight.py`, and `The Wind Lifts the Mist` in the Wind-foe probe); every active art fires across all 17 living holders at both `--gap 0` and `--gap 1`.
- [x] No holder slots two conflicting stances (`lock-the-road` yields the single stance slot whenever `deep-lake` is active).
- [x] Each Effect handles holders across all technique layers cleanly (`Out of the Mist` watches `mist_field`, `The Wind Lifts the Mist` covers both `road_mist` and `mist_field`/`lantern_stone`).
- [x] Vague depth phrasing (*"high chance to miss"*, *"worn by the foe's hits"*, *"fades twice as fast"*) resolved to explicit numbers in every `rule`.
- [x] `[NEW]` technique bonuses and passives sized to tier `0` / `1` and flagged `[NEW]` below.

---

## Mechanic Table & Depth-vs-Engine Mapping

### Techniques ([catalogue-sect-vu_an.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/vu_an/techniques/catalogue-sect-vu_an.json))

| ID | Name | Tier / Kind | Depth Lines | Staged Engine Form | Deviations / `[NEW]` |
|---|---|---|---|---|---|
| `road-mist-primer` | Road Mist Primer (Lộ Vụ Quyết) | 0 / `main` | `names: ["moc", "thuy"]`, `layers: 6`, no bonuses/passives | `bonuses: []`; **[NEW]** `passives`: `evade_pct 3`, `linh_luc_regen_inc_pct 3`, `accuracy_pct 2` (`7.9 W / 8`); `abilities`: `a-breath-of-road-mist` (L1); `effects`: `The Wind Lifts the Mist` (L1, `passive_art`) | **[NEW]** 3 tier-0 passives; `d49` staged as `technique-effects`. |
| `mist-lock-array-canon` | Mist-Lock Array Canon (Tỏa Vụ Trận Kinh) | 1 / `main` | `names: ["moc", "thuy"]`, `layers: 9`, no bonuses/passives | **[NEW]** `bonuses`: `linh_luc_pct 12`; **[NEW]** `passives`: `evade_pct 4`, `linh_luc_regen_inc_pct 5`, `art_speed_pct 5 ["moc", "thuy"]`, `status_duration_pct 5 ["curse"]` (`13.0 W / 16`); `abilities`: `lock-the-road` (L1), `lantern-stone` (L2), `deep-lake-stance` (L4); `effects`: `The Wind Lifts the Mist` (L1), `Lost on the Road` (L5) | **[NEW]** tier-1 bonus + 4 passives; `Lost on the Road` at L5; `d49`/`d2` staged as `technique-effects`. |
| `hidden-gate-array` | Gate Hidden in Mist (Vụ Ẩn Môn Trận) | 1 / `secret` | `names: ["moc"]`, `layers: 9`, no bonuses/passives | **[NEW]** `bonuses`: `than_thuc_pct 10`; **[NEW]** `passives`: `evade_pct 4`, `art_speed_pct 6 ["moc"]`, `status_resist_pct 8`, `accuracy_pct 6` (`14.6 W / 16`); `abilities`: `the-gate-is-not-there` (L1) | **[NEW]** tier-1 bonus + 4 passives. |

### Arts ([part-sect-vu_an.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/vu_an/arts/part-sect-vu_an.json))

| ID | Name | Role / Cost / CD | Depth Text | Staged Engine Form | Deviations |
|---|---|---|---|---|---|
| `a-breath-of-road-mist` | A Breath of Road Mist (Lộ Vụ Nhất Tức) | `utility`, `0.03`, `5.0 s` | Breathes out mist over yourself for 4 s: next art aimed at you has a high chance to miss. | Guarded `road_mist == 0`; sets `road_mist = 1` (`each_for: 4.0`, `cap: 1`): `+65 evade`, cleared on next `was_hit`/`evaded`/`decoy_struck` (`kind: "art"`). | **Dev 1**: uses timed counter `road_mist` instead of claiming the stance slot so `The Wind Lifts the Mist` can clear it legally. |
| `lock-the-road` | Lock the Road (Tỏa Lộ) | `utility`, `0.05`, `8.0 s` | Lays a mist field for 8 s: gain evasion, foe loses accuracy per second, foe's first art misses (an avoid). | Guarded `mist_field == 0`; sets `mist_field = 8`, `mist_field_age = 0`, `decoy {n: 1}`; `+18 evade` + `+2 evade` per pulse elapsed; claims `mist-lock-field` (`field`) when stance slot is free. | **Dev 2–3**: foe accuracy loss expressed as `+2` `evade`/s (identical inside `p_ev`); `cooldown: 8.0` matches field duration so Luyện Khí holders cast before losing at `--gap 1`. |
| `lantern-stone` | Lantern-Stone (Đăng Thạch) | `utility`, `0.04`, `8.0 s` | Gains a lantern-stone charge: while held & Composed, mist field does not fade; worn by foe's hits; ends field when gone. | Guarded `lantern_stone < 2`; adds `+1` `lantern_stone` (`cap: 3`) and `+2` `lantern_wear` (`cap: 6`); `not_tags: ["wind"]` `event.amount > 0` hits wear stones (`1` -> breaks last stone & sets `mist_field = 0`). | **Dev 4**: `2` wear hits per stone so "foe's hits" (plural) wears cleanly without double-spending on Wind lifts. |
| `the-gate-is-not-there` | The Gate Is Not There (Môn Bất Tại) | `utility`, `0.04`, `7.0 s` | Steps into a fold of mist; foe loses target and soonest art waits 0.3 s. | `tags: ["wood", "mist", "movement", "gate_fold"]`; grants `decoy {n: 1}` and `timer` `foe` `next` `+0.3 s`. | None (matches `hidden-gate-array` concept's `0.3 s`). |

### Effects ([vu_an.effects.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/vu_an/effects/vu_an.effects.json))

| Name | Source | Counters | Depth Rule | Engine Form & Deviations |
|---|---|---|---|---|
| `The Wind Lifts the Mist` | `road-mist-primer` L1 & `mist-lock-array-canon` L1 (`d49`) | `mist_field`, `lantern_stone`, `road_mist` | Wind art lifts newest mist Field (`mist-tagged`) or `A Breath of Road Mist`; if Lantern-Stone holds it, spends stone instead; lift happens before hit. | **Dev 5**: `engine.py` emits resolution events (`was_hit`/`evaded`, `filter: {"element": "wind", "kind": "art"}`, `limit: {"per_pulse": 1}`) rather than pre-roll events, and `decoy_struck` drops `element`; ordered reverse (`road_mist -> mist_field -> lantern_stone`) so one Wind hit lifts at most one layer without cascade. |
| `Lost on the Road` | `mist-lock-array-canon` L5 (`d2`) | `mist_field`, `lost`, `lost_ready` | Each foe art missed (evaded/avoided) while mist field stands adds 1 Lost; at 5, escape art comes ready at once and cannot fail, Lost spent. | **Dev 6**: `timer` has no tag filter, so reset uses `which: "all", by: -99` alongside setting `lost_ready = 1` (`+100 escape` until an `escape`-tagged art fires; channel still respects `bound` and `escape_max 0.95`). |
| `The Mist Does Not Ask` | `va-mist-lock-lantern` | `mist_field`, `mist_lantern` | Standing inside own mist field prevents fade; leaving it fades twice as fast. | **Dev 7**: uses `own.composed >= 1` vs `== 0` (`mist_lantern = 1` at `fight_start`, extra `-1` `mist_field` on `pulse` when `own.composed == 0`) since combat is non-spatial. |
| `Out of the Mist` | `va-bobtail-axe` | `mist_field`, `out_mist_seen`, `out_mist_armed` | First hit after mist field ends strikes 20 % harder; never struck while mist is up. | Watches `mist_field >= 1 -> 0` transitions on `pulse`, `was_hit`, `evaded`, and `art_fired`; applies `dmg_more: 0.2` only while `mist_field == 0`, spent on `hit_landed`. |
| `Nobody Looked` | `va-road-mist` (2pc) | `mist_field`, `nobody_ext_given` | While mist holds, first art aimed at you every 8 s misses; mist holds 3 s longer. | **Dev 8**: extends `mist_field` `+3` on first pulse of a field (zero listener-order dependence); grants `1 decoy` every `8 s` via pulse cooldown (`decoy` stops the next direct attack since `hit()` consumes `decoys` before checking `kind`). |

### Items & Sets ([catalogue-sect-vu_an.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/vu_an/items/catalogue-sect-vu_an.json), [sets-vu_an.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/vu_an/items/sets-vu_an.json))

- **3 Unique Items**:
  - `va-mist-lock-lantern` (`treasure`, `dang`, `rarity: 4`, `34.6 W / 38.4`, `holder: bang_yen_toa`, Effect `The Mist Does Not Ask`, open line `cast_ward_duration_pct: 20`)
  - `va-bobtail-axe` (`artifact`, `phu`, `grade: 3`, `rarity: 4`, `28.0 W / 38.4`, R6 `exception`, `holder: trieu_ngu_lang`, Effect `Out of the Mist`)
  - `va-milestone-flag` (`artifact`, `ky`, `grade: 2`, `rarity: 3`, `17.2 W / 25.6`, `holder: bang_yen_toa`)
- **1 Set**:
  - `va-road-mist` (`Road Mist (Lộ Vụ)`, 2pc on `bang_yen_toa`: `evade_pct 3`, `linh_luc_regen_inc_pct 6`, Effect `Nobody Looked`).

---

## Holder Check & Combat Probes

All 17 living `vu_an` members ran in `sect_fight.py` with **`0 REFUSED`** under `$env:DEPTH_STAGE = "C:\Users\xphuo\IdeaProjects\my-game\design\stage6-staging\vu_an"`.

| Holder(s) | Realm | Slotted Arts | Gap 0 (`--seeds 5`) | Gap 1 (`--seeds 5`) | Effect Runs & Art Fires (Gap 0) |
|---|---|---|---|---|---|
| `bang_yen_toa` | `truc_co` | `lock-the-road`, `lantern-stone`, `deep-lake-stance`, `step-into-the-green`, `haze-on-the-path`, `the-gate-is-not-there` | `50.3 s`, `5/5`, `100%` | `19.1 s`, `0/5`, `0%` | Arts fire `7.8 / 9.4 / 19.6 / 9.4 / 8.2 / 9.4` (`Gap 1`: `2.6 / 3.2 / 6.2 / 2.8 / 2.8 / 2.8`). `Lost on the Road` `50.3s 100%` vs `48.8s 100%` (`runs 25`), `The Mist Does Not Ask` `50.3s 100%` vs `52.2s 100%` (`runs 135`), `Nobody Looked` `50.3s 100%` vs `50.4s 100%` (`runs 95`; `--gap 1`: `19.1s` vs `17.8s`), `The Wind Lifts the Mist` `runs 0` (see Wind probe). |
| `trieu_ngu_lang` | `ket_dan` | `lock-the-road`, `lantern-stone`, `deep-lake-stance`, `step-into-the-green`, `haze-on-the-path` | `51.6 s`, `5/5`, `100%` | `15.2 s`, `0/5`, `0%` | Arts fire `9.0 / 9.6 / 19.2 / 9.6 / 7.8`. `Lost on the Road` `51.6s 100%` vs `53.2s 99%` (`runs 25`), `Out of the Mist` `51.6s 100%` vs `52.3s 100%` (`runs 118`), `The Wind Lifts the Mist` `runs 0`. |
| `chuc_minh_lo` | `truc_co` | `lock-the-road`, `lantern-stone`, `deep-lake-stance`, `step-into-the-green` | `49.0 s`, `5/5`, `100%` | `13.8 s`, `0/5`, `0%` | Arts fire `8.4 / 9.2 / 18.4 / 9.2`. `Lost on the Road` `49.0s 100%` vs `50.7s 100%` (`runs 25`). |
| `ham_thanh_dang`, `luyen_to_y` | `truc_co` | `lock-the-road`, `lantern-stone`, `deep-lake-stance`, `step-into-the-green`, `haze-on-the-path` | `49.0 s`, `5/5`, `98%` | `14.0 s`, `0/5`, `0%` | Arts fire `8.4 / 9.0 / 18.0 / 8.8 / 7.2`. `Lost on the Road` `49.0s 98%` vs `52.0s 98%` (`runs 25`). |
| `thai_van_xa` | `truc_co` | `lock-the-road`, `lantern-stone`, `deep-lake-stance` | `52.3 s`, `5/5`, `83%` | `10.4 s`, `0/5`, `0%` | Arts fire `6.0 / 6.0 / 18.0`. `The Wind Lifts the Mist` `runs 0`. |
| `nham_tung_anh` | `luyen_khi` | `lock-the-road`, `lantern-stone`, `step-into-the-green` | `50.2 s`, `0/5`, `0%` | `10.4 s`, `0/5`, `0%` | Arts fire `7.4 / 7.4 / 7.8` (`Gap 1`: `1.0 / 1.0 / 1.2`). |
| `khuyet_lac_vu` | `luyen_khi` | `lock-the-road`, `lantern-stone` | `42.8 s`, `0/5`, `0%` | `9.4 s`, `0/5`, `0%` | Arts fire `4.8 / 4.6` (`Gap 1`: `0.6 / 0.6`). |
| `bao_thuy_hanh` | `truc_co` | `a-breath-of-road-mist` | `46.2 s`, `0/5`, `0%` | `9.6 s`, `0/5`, `0%` | Art fires `8.8` (`Gap 1`: `1.4`). |
| 8 `luyen_khi` outer guards (`dao_thach_an`, `bien_ha_huong`, `quan_da_tu`, `tap_minh_nhi`, `ham_tieu_vu`, `tap_xuan_tra`, `mao_dao_bi`, `ky_that_lo`) | `luyen_khi` | `a-breath-of-road-mist` | `40.4 s`, `0/5`, `0%` | `9.2 s`, `0/5`, `0%` | Art fires `7.6` (`Gap 1`: `1.4`). |

### Targeted Conditional Probes
- **`The Wind Lifts the Mist` (`thai_van_xa` vs 10-seed Trúc Cơ Wind foe [`chaff-needle`, `reed-cutting-breeze`, `hollow-step`, `falling-leaf`])**: `WITH`: `17.16 s`, `wind_runs = 26` (`evade-stone: 7`, `hit-stone: 6`, `hit-field: 10`, `evade-field: 3`); `WITHOUT`: `18.89 s` (`wind_runs = 0`). (Note: on `dao_thach_an`, `a-breath-of-road-mist`'s own 1-art clear fires before `The Wind Lifts the Mist` on resolution.)
- **`Lost on the Road` (`chuc_minh_lo` + `lantern-out`)**:
  - 20 seeds vs Kết Đan `typical`: `decoy-count: 10`, `decoy-spend: 2`, `evade-count: 20`.
  - 10 seeds vs Trúc Cơ `typical` (`lantern-out` gated on `own.counter.lost_ready >= 1`): `evade-count: 43`, `evade-spend: 6`, `decoy-count: 58`, `decoy-spend: 15`, `escape-spend: 19` (`10/10` vs `0` when stripped).
- **`Out of the Mist` (`trieu_ngu_lang` vs 20-seed Kết Đan `typical`)**: `WITH`: `51.43 s`, `20/20`, `99.4%` HP (`watch: 175`, `arm-hit: 156`, `arm-pulse: 3`, `spend: 127`); `WITHOUT`: `52.43 s`, `20/20`, `98.4%` HP.
- **`The Mist Does Not Ask` + `Nobody Looked` + `deep-lake-stance` (`bang_yen_toa` vs 10-seed Trúc Cơ `typical`)**: `48.40 s`, `10/10`, `100%` HP (`hold-flag: 10`, `double-fade: 259`, `extend: 66`, `extend-reset: 58`, `avoid: 56`, `deep-lake-stance-empower: 170`, `hidden-gate-fold: 93`).
