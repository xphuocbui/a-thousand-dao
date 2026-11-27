# Chức Hà Các (`chuc_ha`): Stage 6 checkpoint review (2026-11-27, auto-accepted)

## Summary

Reviewed `design/stage6-staging/chuc_ha/` against `design/world/depth/sects/chuc_ha.*`, `chuc_ha.md`, `_brief-record.md`, `_brief-review.md`, `DECISIONS-2026-11-25.md`, `DECISIONS-2026-11-26.md`, `FIGHT-INPUT.md`, and GDScript compiler parity (`effect_compiler.gd`, `build_file_compiler.gd`, `assets/data/combat_engine.json`).

- **Findings:** 1 `MUST-FIX` (fixed), 1 `SHOULD` (fixed), 0 `NIT`.
- **Pending words:** 0 (no `pending.json`; all records use existing engine words).
- **GDScript standalone parity:** PASS — every Effect in `chuc_ha.effects.json` declares in its own `"counters"` every counter it reads or writes (`thread_t1`, `thread_t2`, `thread_ended`, `thread_snapped`, `thread_knot`), none set a stance, all 10 arts in `part-sect-chuc_ha.json` declare all counters and states they reference, `warp-and-weft` (`own.field_up < 1`) is the sole stance in `chuc_ha` (and `fire-silk-weave` uses `ward_grow` without setting `s.state`), no `on: "always"` record has a record-level `filter`, and no Effect record has two `"mod"` actions without `"stack": true`.
- **ID & Effect name uniqueness:** PASS — 0 collisions for techniques (`6`), arts (`10`), items (`3`), sets (`1`), and Effect names (`When the Thread Breaks`, `The Thread Catches`, `Chars in a Season`, `Fire Runs the Thread`) against committed `design/`, `assets/data/combat_effects.json`, and all other staged `b03` directories.
- **Stand-ins & root fit:** Verified across all 17 living cast members (`chuc_ha.cast.json` + `chuc_ha.5.cast.json`): all 14 lineage members fit their method elements/admission rules/ranks, and the 3 non-lineage stand-ins (`nhiem_thanh_lam` -> `indigo-vat-canon` L8, `mac_lam_y` -> `vat-stirring-breath` L4, `nguu_thai_diep` -> `mulberry-row-breath` L4) match their notes, roots, and R2 exceptions.
- **`Chars in a Season` (`NEVER_RAN`) verification:** Confirmed intentional `not_run` (details below).

---

## Ranked Findings

1. **[MUST-FIX — FIXED] `design/stage6-staging/chuc_ha/effects/chuc_ha.effects.json` (`When the Thread Breaks` & `Fire Runs the Thread` — same-pulse `evaded` + `was_hit` double recoil and double Fire leap):**
   - *What was wrong:* Both `eff:When the Thread Breaks snap hit t2/t1` (`on: "was_hit"`) and `snap evade t2/t1` (`on: "evaded"`) set `thread_snapped` to `1` (with `cap: 1`), while `eff:When the Thread Breaks recoil hit`, `recoil evade`, `eff:Fire Runs the Thread snap hit`, and `snap evade` each gated only on `own.counter.thread_snapped >= 1` and their own per-record `limit.per_pulse: 1`. If in a single pulse a foe fired a `heavy`/`slow` split hit or two `heavy`/`slow` hits where one was `evaded` and the next `was_hit`, `thread_snapped` remained `1` until the next `pulse`, causing both the `evaded` and `was_hit` recoil/leap records to fire (`-8%` max linh lực recoil and double Fire leap for a single snapped thread).
   - *Fix applied:* Raised `thread_snapped` `cap` to `2` in both `When the Thread Breaks` and `Fire Runs the Thread`; had `snap hit t2/t1` set `thread_snapped = 1` and `snap evade t2/t1` set `thread_snapped = 2`; gated `recoil hit` and `Fire Runs the Thread snap hit` on `own.counter.thread_snapped == 1`, and `recoil evade` and `Fire Runs the Thread snap evade` on `own.counter.thread_snapped == 2` (with `clear snap` on `pulse` still clearing `thread_snapped >= 1` to `0`). Verified with a mixed evade+hit `heavy`/`slow` split-hit probe (`snaps=9`, `recoils=9`, `leaps=8`).

2. **[SHOULD — FIXED] `design/world/depth/sects/chuc_ha.techniques.json` & `design/stage6-staging/chuc_ha/arts/part-sect-chuc_ha.json` (`leaf-basket-guard` — spatial word in concept/rule):**
   - *What was wrong:* `spatial_words_check.py` flagged `"hauling"` as a `removed` spatial word in `chuc_ha.techniques.json` (`leaf-basket-guard`, `techniques.arts.concept`), and `part-sect-chuc_ha.json` carried the same `"hauling mulberry baskets"` phrasing in `rule`.
   - *Fix applied:* Replaced `"hauling"` with `"carrying"` in both `design/world/depth/sects/chuc_ha.techniques.json` and `design/stage6-staging/chuc_ha/arts/part-sect-chuc_ha.json`. Re-running `spatial_words_check.py` leaves zero rule/concept hits for `chuc_ha` (only non-rule `banner` mentions in cast `ties.note` / `build.note`).

---

## Verification: `Chars in a Season` (`NEVER_RAN` in `sect_fight.py`)

- **Depth rule (`chuc_ha.items.json`, `chc-first-weave-robe`):** `"The robe must be rewoven each season; unrewoven, its modifiers fall by a quarter each season until it is ash."`
- **Staged Effect (`chuc_ha.effects.json`):** Marked `"not_run": "out-of-fight seasonal craft/upkeep rule: reweaving and seasonal decay occur between seasons, not inside a duel"` with `"records": []`.
- **Verdict:** Intentionally `not_run`. Both `fight.py` and `BuildFileCompiler` (`build_file_compiler.gd`) handle `not_run` by surfacing the rationale in `unmodelled` without failing load; `sect_fight.py` prints `runs 0 NEVER_RAN` for `tang_mong_kien` because no combat records run. No fix needed.

---

## Pending Words

None (`0` pending words; no `pending.json`).

---

## Checks After Final Edit (`DEPTH_STAGE=C:\Users\xphuo\IdeaProjects\my-game\design\stage6-staging\chuc_ha`)

- `lint_techniques.py design/stage6-staging/chuc_ha/techniques/catalogue-sect-chuc_ha.json`: checked 6 techniques, **0 findings** (`7.6 / 8`, `14.5 / 16`, `13.8 / 16`, `15.1 / 16`, `7.6 / 8`, `7.8 / 8`).
- `lint_arts.py design/stage6-staging/chuc_ha/arts/part-sect-chuc_ha.json`: checked 10 arts in 1 files, **0 findings**.
- `lint_items.py design/stage6-staging/chuc_ha/items/catalogue-sect-chuc_ha.json`: checked 3 items, 22 bases, 9 common arts, **0 findings** (`unique 3 of 3`).
- `depth_check.py --quiet`: **findings: none** (1891 people, 435 builds with Đạo Đồ targets).
- `depth_gap.py --sect chuc_ha`: `stand_ins: 0`, `unknown_ids: 0`, `cross_owner: 0`, `ties_unmapped: 0`, `ties_over_cap: 0`, `engine_words: 0`, `wishes_open: 0`, `lines: 12/12 runs`.
- `spatial_words_check.py`: **0** rule/concept hits for `chuc_ha`.
- `sect_fight.py chuc_ha --seeds 5` and `sect_fight.py chuc_ha --gap 1` (default 20 seeds): **0 `REFUSED`**, **0 `NEVER_FIRED`** across all 17 living cast members.
- Mixed evade+hit `heavy`/`slow` split-hit probe (`than_van_cam`, `evade_pct: 35`, `split: [0.5, 0.5]`): `t=42.98`, `win=A`, `snaps=9`, `recoils=9`, `leaps=8` (`recoils <= snaps`, `leaps <= snaps`).

---

## Holder Table After Fixes (`sect_fight.py chuc_ha --seeds 5` at `--gap 0`; `sect_fight.py chuc_ha --gap 1` at default 20 seeds)

| Holder | Realm | Arts | `--gap 0` (`mean_s`, `wins/5`, `hp_left`) | `--gap 1` (`mean_s`, `wins/20`, `hp_left`) | Staged Effects (`gap 0` / `gap 1` runs) | Notes on art fires (`gap 0` / `gap 1`) |
|---|---|---|---|---|---|---|
| `than_van_cam` | `truc_co` | `reel-in,warp-and-weft,burning-thread,fire-silk-weave` | `27.0 s`, `5/5`, `78%` | `8.8 s`, `0/20`, `0%` | **When the Thread Breaks**: `27.0s 78% / 40.4s 60%` (`102` / `21`); **The Thread Catches**: `27.0s 78% / 28.1s 76%` (`37` / `20`); **Fire Runs the Thread**: `27.0s 78% / 31.4s 74%` (`155` / `125`) | `reel-in` `8.4`/`2.0`, `warp-and-weft` `4.0`/`1.0`, `burning-thread` `5.0`/`1.0`, `fire-silk-weave` `3.0`/`1.0` |
| `tang_mong_kien` | `truc_co` | `reel-in,warp-and-weft` | `49.0 s`, `5/5`, `27%` | `8.9 s`, `0/20`, `0%` | **When the Thread Breaks**: `49.0s 27% / 47.1s 0%` (`157` / `20`); **Chars in a Season**: `0` / `0` (`not_run`) | `reel-in` `14.2`/`2.0`, `warp-and-weft` `7.0`/`1.0` |
| `co_chuc_viem` | `truc_co` | `reel-in,warp-and-weft,burning-thread,fire-silk-weave` | `35.2 s`, `5/5`, `65%` | `8.3 s`, `0/20`, `0%` | **When the Thread Breaks**: `35.2s 65% / 51.6s 0%` (`132` / `20`) | `reel-in` `10.0`/`2.0`, `warp-and-weft` `4.4`/`1.0`, `burning-thread` `6.8`/`1.0`, `fire-silk-weave` `4.0`/`1.0` |
| `mau_tu_linh` | `truc_co` | `reel-in,warp-and-weft,burning-thread,fire-silk-weave` | `35.2 s`, `5/5`, `65%` | `8.3 s`, `0/20`, `0%` | **When the Thread Breaks**: `35.2s 65% / 51.6s 0%` (`132` / `20`) | `reel-in` `10.0`/`2.0`, `warp-and-weft` `4.4`/`1.0`, `burning-thread` `6.8`/`1.0`, `fire-silk-weave` `4.0`/`1.0` |
| `trinh_to_am` | `truc_co` | `reel-in,warp-and-weft` | `49.2 s`, `4/5`, `22%` | `8.6 s`, `0/20`, `0%` | **When the Thread Breaks**: `49.2s 22% / 44.8s 0%` (`158` / `20`) | `reel-in` `14.6`/`2.0`, `warp-and-weft` `7.0`/`1.0` |
| `thanh_kim_toa` | `truc_co` | `reel-in,warp-and-weft` | `49.2 s`, `4/5`, `22%` | `8.6 s`, `0/20`, `0%` | **When the Thread Breaks**: `49.2s 22% / 44.8s 0%` (`158` / `20`) | `reel-in` `14.6`/`2.0`, `warp-and-weft` `7.0`/`1.0` |
| `nhiem_thanh_lam` | `ket_dan` | `indigo-steep,mordant-fix` | `63.6 s`, `2/5`, `3%` | `9.2 s`, `0/20`, `0%` | n/a | `indigo-steep` `15.6`/`1.4`, `mordant-fix` `10.0`/`1.0` |
| `dau_hong_ti` | `luyen_khi` | `reel-in,warp-and-weft,burning-thread,fire-silk-weave` | `48.7 s`, `1/5`, `0%` | `8.3 s`, `0/20`, `0%` | n/a (L2, `When the Thread Breaks` unlocks at L3) | `reel-in` `11.2`/`2.0`, `warp-and-weft` `4.6`/`0.9`, `burning-thread` `5.4`/`1.0`, `fire-silk-weave` `5.6`/`1.0` |
| `luong_kien_sinh` | `luyen_khi` | `reel-in,warp-and-weft` | `40.3 s`, `0/5`, `0%` | `8.3 s`, `0/20`, `0%` | n/a | `reel-in` `11.6`/`2.0`, `warp-and-weft` `5.4`/`1.0` |
| `van_diep_tang` | `luyen_khi` | `reel-in,warp-and-weft` | `40.3 s`, `0/5`, `0%` | `8.3 s`, `0/20`, `0%` | n/a | `reel-in` `11.6`/`2.0`, `warp-and-weft` `5.4`/`1.0` |
| `tich_diem_ti` | `luyen_khi` | `reel-in,warp-and-weft` | `40.3 s`, `0/5`, `0%` | `8.3 s`, `0/20`, `0%` | n/a | `reel-in` `11.6`/`2.0`, `warp-and-weft` `5.4`/`1.0` |
| `la_tieu_tam` | `luyen_khi` | `spin-a-strand,warm-shed` | `45.2 s`, `0/5`, `0%` | `8.2 s`, `0/20`, `0%` | n/a | `spin-a-strand` `14.0`/`2.0`, `warm-shed` `6.8`/`1.0` |
| `phung_tieu_toa` | `luyen_khi` | `spin-a-strand,warm-shed` | `45.2 s`, `0/5`, `0%` | `8.2 s`, `0/20`, `0%` | n/a | `spin-a-strand` `14.0`/`2.0`, `warm-shed` `6.8`/`1.0` |
| `luu_cam_ho` | `luyen_khi` | `spin-a-strand,warm-shed` | `45.2 s`, `0/5`, `0%` | `8.2 s`, `0/20`, `0%` | n/a | `spin-a-strand` `14.0`/`2.0`, `warm-shed` `6.8`/`1.0` |
| `quan_bo_hanh` | `luyen_khi` | `spin-a-strand,warm-shed` | `45.2 s`, `0/5`, `0%` | `8.2 s`, `0/20`, `0%` | n/a | `spin-a-strand` `14.0`/`2.0`, `warm-shed` `6.8`/`1.0` |
| `mac_lam_y` | `luyen_khi` | `vat-rinse` | `41.4 s`, `0/5`, `0%` | `8.0 s`, `0/20`, `0%` | n/a | `vat-rinse` `11.0`/`2.0` |
| `nguu_thai_diep` | `luyen_khi` | `leaf-basket-guard` | `39.4 s`, `0/5`, `0%` | `8.0 s`, `0/20`, `0%` | n/a | `leaf-basket-guard` `10.4`/`2.0` |

CHECKPOINT DONE
