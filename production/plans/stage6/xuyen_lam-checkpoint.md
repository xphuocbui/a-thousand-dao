# Stage 6 Checkpoint Review — `xuyen_lam` (Xuyên Lâm Môn)

Unanchored review of `design/stage6-staging/xuyen_lam/` and `design/world/depth/sects/xuyen_lam.*` against `production/plans/stage6/_brief-review.md`, `_brief-record.md`, `DECISIONS-2026-11-25.md`, `DECISIONS-2026-11-26.md`, and `tools/design/combat_sim/FIGHT-INPUT.md` (verified against `tools/design/combat_sim/engine.py` and GDScript `src/gameplay/combat/fight/effect_compiler.gd`, `effect_runner.gd`, `build_file_compiler.gd`, `fighter_profile_loader.gd`).

## Ranked Findings

1. **[MUST-FIX — FIXED] `neither-wind-nor-rain-shrug` cleansed an arbitrary curse instead of the control status**
   - **File / Record:** `design/stage6-staging/xuyen_lam/arts/part-sect-xuyen_lam.json` (`neither-wind-nor-rain`, record `neither-wind-nor-rain-shrug`).
   - **What was wrong:** `neither-wind-nor-rain-shrug` ran `{"cleanse": {"curses": 1}}` with `limit: {"per_fight": 1}` when any of `charmed`, `sleep`, `silence`, `sealed_meridian`, or `bound` was present. In both `engine.py` (`cleanse()`) and `effect_runner.gd`, `cleanse.curses: 1` removes the first curse in `statuses` insertion order (`gone[0]`). Whenever the holder already carried an older non-control curse (`slowed_time`, `withering`, `heavy_breath`, `sundered`, etc.), the shrug cleansed that older curse, left the control status active, and burned its once-per-fight charge.
   - **Fix applied:** Replaced `{"cleanse": {"curses": 1}}` with explicit per-status cleanses for the five control statuses (`charmed`, `sleep`, `silence`, `sealed_meridian`, `bound`) before setting `neither_wind_sure = 1`.
   - **Verification:** Targeted probe (`phi_thoa_y` hit with `slowed_time` at `1200 ms` then `charmed` at `2400 ms`) confirmed `neither-wind-nor-rain-shrug` fired at `3000 ms`, cleansed `charmed` (restoring art casting at `3708 ms` while `slowed_time` remained active), and armed `neither-wind-nor-rain-sure` on the next staff strike at `5500 ms`.

2. **[NIT — KEPT] `Step Before the Strike` models Lightning conversion as +30 % `return_damage` shock on full unblocked strike**
   - **File / Record:** `design/stage6-staging/xuyen_lam/effects/xuyen_lam.effects.json` (`Step Before the Strike`), `design/stage6-staging/xuyen_lam/items/sets-xuyen_lam.json` (`xl-thunder-fort`).
   - **Assessment:** Because the engine has no live `convert` modifier (`convert` is static on `ArtDef`) and `return_damage` passes through `defend()` a second time, reducing the Physical hit by 30 % would make evading a net DPS loss against typical Lightning resistance. Keeping the full unblocked strike + 30 % Lightning shock is documented in `approx` and yields a clean positive delta on `uc_diep_thanh` (`16.8 s` vs `17.0 s`, `41` runs at gap 0; `33` runs at gap 1). Kept as staged.

## Explicit Parity, Uniqueness, and `b01` Merge Checks

- **GDScript standalone compilation parity:** Checked all 6 Effects in `design/stage6-staging/xuyen_lam/effects/xuyen_lam.effects.json` (`The Long Road` declares `walk_slowly`; `Do Not Listen` declares `unheeding_ward`; `Rain on the Leaves` declares `walk_slowly`; `Lamp on the Road` declares `[]`; `Step Before the Strike` declares `step_before`; `The Lamp Does Not Go Out` declares `lamp_lit`) and both staged Arts in `design/stage6-staging/xuyen_lam/arts/part-sect-xuyen_lam.json` (`lighter-than-a-horse` declares `horse_step`, `horse_trip`, and state `lighter-than-a-horse`; `neither-wind-nor-rain` declares `neither_wind_sure`) against `EffectCompiler`, `BuildFileCompiler`, `FighterProfileLoader`, and `assets/data/combat_engine.json`: **0 errors, 0 undeclared counters or states**. On dual-stance holders (`phi_thoa_y`, `nghiem_quy_khu`, `ky_khinh_ma`), `lighter-than-a-horse-enter` guards on `own.state.any == 0` and `lighter-than-a-horse-end` guards on `own.state.lighter-than-a-horse >= 1`, so `walk-slowly` is never clobbered.
- **Effect name uniqueness:** Verified the 6 Effect names (`The Long Road`, `Do Not Listen`, `Rain on the Leaves`, `Lamp on the Road`, `Step Before the Strike`, `The Lamp Does Not Go Out`) have **0 collisions** against all 258 entries in `assets/data/combat_effects.json` and against all other staged `b02` files (`phan_vu`, `muc_van`, `truc_thuc`, `nhan_van`, `minh_loan`).
- **`calm-wind-staff-canon` + 3 `b01`-merged arts merge check:**
  - `design/techniques/catalogue-sect-xuyen_lam.json` holds `calm-wind-staff-canon`; staged `catalogue-sect-xuyen_lam.json` holds `straw-sandal-step-primer`, `calm-wind-staff-canon` (updating only `effects[0].rule` to the exact `d23` `5 %` / `1 %` wording and `notes`), and `unheeding-rain-heart-method`. `stage6_merge.py`'s `merge_list()` replaces `calm-wind-staff-canon` in-place by `id` and appends the 2 new techniques with no dropped fields or duplicate IDs.
  - `design/arts/part-sect-xuyen_lam.json` holds `walk-slowly`, `who-is-afraid`, `one-straw-cape`; staged `part-sect-xuyen_lam.json` holds `lighter-than-a-horse`, `neither-wind-nor-rain` (disjoint IDs: `overlap = 0`). Neither `design/items/catalogue-sect-xuyen_lam.json`, `design/items/sets-xuyen_lam.json`, nor `design/world/depth/effects/xuyen_lam.effects.json` exists yet.
- **`The Long Road` & `Do Not Listen` verification (`--gap 0` & `--gap 1`):**
  - `The Long Road` (`calm-wind-staff-canon` L5) attaches cleanly on all 7 `xuyen_lam` L5+ holders (`uc_diep_thanh`, `phi_thoa_y`, `lai_tiet_truong`, `dinh_van_do`, `lo_kim_tuyen`, `ky_khinh_ma`, `gian_dang_bo`) and cross-owner `uc_da_diep` (`thinh_vu` L6), and stays inactive on `nghiem_quy_khu` (L4). `always` `cost_red` shows active deltas at `--gap 0` (`phi_thoa_y` 78 % vs 65 % HP, `dry_at 34.9 s` vs `30.1 s`; `lai_tiet_truong` 76 % vs 65 % HP; `ky_khinh_ma` 52.0 s 1/5 wins vs 44.6 s 0/5; `dinh_van_do`/`lo_kim_tuyen`/`gian_dang_bo` 38.4 s vs 34.4 s; `uc_diep_thanh` 31 % vs 22 % qi remaining at 18 s) and `--gap 1` (`uc_diep_thanh` 12.4 s vs 12.0 s; `phi_thoa_y` 13.4 s vs 12.9 s).
  - `Do Not Listen` (`unheeding-rain-heart-method` L1) attaches cleanly on both `uc_diep_thanh` (even with 6 active arts full) and `phi_thoa_y` at `--gap 0` and `--gap 1`; typical `sect_fight.py` foes cast no soul/song/Charm arts (`0` runs vs typical foe), and targeted soul+song+Charm probing recorded `84` runs (`:song` and `:soul`).

## Pending Words

None (`pending.json` absent; 0 pending engine words). Carried non-engine open items:
- `body-element-free-names` (Stage 7/9 cultivation/schema ruling, carried from `thinh_vu.reviewed`): allow `names: []` on element-free `main`/`secret` methods for R3 no-lean sects (`straw-sandal-step-primer`, `calm-wind-staff-canon`, `unheeding-rain-heart-method` carry lint proxy `["kim", "moc", "tho"]`).
- Staff base gap in `design/items/bases.json` (pre-existing note in `xuyen_lam.items.json`): `xl-bamboo-staff` sits on `loi_truong` (`utility`).

## Post-Fix Verification & Holder Table

### Linters & Checkers (`DEPTH_STAGE=design/stage6-staging/xuyen_lam`)
- `lint_techniques.py`: `checked 3 techniques, 0 findings`
- `lint_arts.py`: `checked 2 arts in 1 files, 0 findings`
- `lint_items.py`: `checked 6 items, 22 bases, 9 common arts, 0 findings`
- `depth_check.py`: **0 findings in `xuyen_lam`** (only 1 transient finding in in-flight `b02` lane `bach_vu`: `hoan_truc_lung`)
- `depth_gap.py --sect xuyen_lam`: `stand_ins 0`, `beasts 0`, `unknown_ids 0`, `lines 31/31 runs`, `engine_words 0`, `wishes_open 0` (`techniques 3`, `arts_new 7` [3 in `design/` + 2 active staged + 2 passive `effect`], `items 6`, `sets 3`, `effects 4`, `events 5`, `cross_owner 2`)
- `sect_fight.py xuyen_lam --seeds 5 --gap 0` & `--gap 1`: **18/18 living cast, 0 `REFUSED`**, all slotted arts fire; cross-owner `uc_da_diep` (`thinh_vu`) and `truong_da_dao` (`loose-south`) **0 `REFUSED`**, all slotted arts fire.

| Holder | Realm | Slotted arts (all fired) | Gap 0 (`mean_s`, wins, HP) | Gap 1 (`mean_s`, wins) | Effect checks (`with` vs `without`, runs) |
|---|---|---|---|---|---|
| `uc_diep_thanh` | `ket_dan` | `walk-slowly` (10.0), `who-is-afraid` (3.0), `one-straw-cape` (2.0), `answering-palm` (6.0), `twin-shadow-fist` (2.0), `rolling-barrage-fist` (7.8) | 16.8 s, 5/5, 95 % | 12.4 s, 0/5 | `Rain on the Leaves`: 16.8 s vs 17.2 s (**50** gap 0 / **41** gap 1); `Step Before the Strike`: 16.8 s vs 17.0 s (**41** gap 0 / **33** gap 1); `The Long Road`: 12.4 s vs 12.0 s gap 1 (`always`); `Do Not Listen`: 0 vs typical foe |
| `phi_thoa_y` | `ket_dan` | `walk-slowly` (34.0), `who-is-afraid` (10.8), `one-straw-cape` (6.4), `neither-wind-nor-rain` (6.2), `lighter-than-a-horse` (9.8) | 61.6 s, 5/5, 78 % | 13.4 s, 0/5 | `The Long Road`: 78 % vs 65 % HP gap 0, 13.4 s vs 12.9 s gap 1 (`always`); `The Lamp Does Not Go Out`: 78 % vs 60 % HP (**572** gap 0 / **75** gap 1); `Lamp on the Road`: **10** (gap 0 & gap 1); `Do Not Listen`: 0 vs typical foe |
| `lai_tiet_truong` | `truc_co` | `walk-slowly` (15.0), `who-is-afraid` (4.6), `one-straw-cape` (2.6), `answering-palm` (8.0), `twin-shadow-fist` (2.0) | 26.9 s, 5/5, 76 % | 8.0 s, 0/5 | `The Long Road`: 26.9 s 76 % vs 28.3 s 65 % gap 0 (`always`) |
| `ky_khinh_ma` | `truc_co` | `walk-slowly` (27.8), `who-is-afraid` (8.4), `one-straw-cape` (3.8), `lighter-than-a-horse` (7.8) | 52.0 s, 1/5, 3 % | 9.0 s, 0/5 | `The Long Road`: 52.0 s 3 % (1 win) vs 44.6 s 0 % gap 0 (`always`) |
| `nghiem_quy_khu` | `truc_co` | `walk-slowly` (24.4), `who-is-afraid` (6.2), `one-straw-cape` (3.4), `lighter-than-a-horse` (7.8) | 44.6 s, 0/5, 0 % | 9.0 s, 0/5 | Layer 4 (`The Long Road` unlocks at L5) |
| `gian_dang_bo`, `dinh_van_do`, `lo_kim_tuyen` (3) | `truc_co` | `walk-slowly` (20.2), `who-is-afraid` (5.4), `one-straw-cape` (3.2) | 38.4 s, 0/5, 0 % | 8.0 s, 0/5 | `The Long Road`: 38.4 s vs 34.4 s gap 0 (`always`) |
| 10 outer disciples (`khuc_phu_thach`, `cu_tieu_thoa`, `man_thanh_truong`, `thoi_vong_pham`, `uc_yen_vu`, `gian_tieu_dang`, `mong_thiet_lang`, `dinh_tieu_chu`, `khuong_lang_thu`, `manh_hoi_lo`) | `luyen_khi` | `lighter-than-a-horse` (8.6) | 44.9 s, 0/5, 0 % | 9.0 s, 0/5 | Primer-only Pressing stance + delay |
| `uc_da_diep` (`thinh_vu`, cross-owner) | `truc_co` | `walk-slowly` (18.2), `who-is-afraid` (4.6), `one-straw-cape` (3.0) | 34.4 s, 0/5, 0 % | 8.0 s, 0/5 | `The Long Road`: L6 (`always`) |
| `truong_da_dao` (`loose-south`, cross-owner) | `luyen_khi` | `lighter-than-a-horse` (8.6) | 44.9 s, 0/5, 0 % | — | Primer-only (`straw-sandal-step-primer` L5) |

CHECKPOINT DONE
