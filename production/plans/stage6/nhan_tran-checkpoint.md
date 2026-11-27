# Nhạn Trận Môn (`nhan_tran`): Stage 6 checkpoint review (2026-11-27, Hydrogen, auto-accepted)

Unanchored checkpoint review of `design/stage6-staging/nhan_tran/` against `design/world/depth/sects/nhan_tran.{md,techniques.json,items.json,cast.json,5.cast.json}`, Stage 6 rules (`_brief-review.md`, `_brief-record.md`, `DECISIONS-2026-11-25.md`, `DECISIONS-2026-11-26.md`), `tools/design/combat_sim/FIGHT-INPUT.md`, `design/arts/part-sect-bang_tam.json`, `design/world/depth/effects/bang_tam.effects.json`, `production/plans/stage6/bang_tam-review.md`, and both combat engine implementations (`tools/design/combat_sim/{engine,fight,sect_fight}.py` and `src/gameplay/combat/fight/{effect_compiler,effect_runner,fight}.gd`).

---

## Ranked Findings

1. **[MUST-FIX — FIXED] `One Goose` (`eff:One Goose first share`) and `geese-stance` (`geese-strain-heal`) fired on `was_hit` with `event.amount == 0`**
   - **Files / Records:** `design/stage6-staging/nhan_tran/effects/nhan_tran.effects.json` (`One Goose`), `design/stage6-staging/nhan_tran/arts/part-sect-nhan_tran.json` (`geese-stance`).
   - **What was wrong:** Both `engine.py` (`Fight.hit()`) and `fight.gd` raise `was_hit` for every non-evaded hit even when block, wards, or body shields reduce health damage dealt (`amount`) to `0`. A pre-edit probe showed `muc_han_nhan` took `38/38` zero-damage `was_hit` events at `--gap 0` and `23/65` at `--gap 1` (`muc_tan_vu`: `44/44` at `--gap 0`, `15/37` at `--gap 1`; `dong_kien_luy`: `28/28` at `--gap 0`, `4/45` at `--gap 1`). Without an `event.amount > 0` check, `eff:One Goose first share` triggered on blocked hits, healed `0`, and burned its 6 s cooldown; similarly `geese-strain-heal` (`limit: {"per_pulse": 1}`) burned its per-pulse heal on `0`-damage hits. In addition, `One Goose` emulated a 6 s cooldown via two extra counters (`banner_first`, `banner_first_cd`) and pulse decrement records (`rearm`, `ready`), which rearmed on pulse boundaries (`5.01–5.99 s`) rather than `6.0 s`.
   - **Fix applied:** Added `{"read": "event.amount", "op": ">", "value": 0}` to `if` on both `eff:One Goose first share` and `geese-strain-heal`; simplified `One Goose` to a single `banner_planted` counter and `"limit": {"cooldown": 6}` on `eff:One Goose first share` (removing `banner_first`, `banner_first_cd`, `rearm`, and `ready`); updated `geese-stance` `rule` to `"each damaging blow taken"`. Verified in post-edit probes that `eff:One Goose first share` (`0` fires at `--gap 0`, `5` fires at `--gap 1` seed 1) and `geese-strain-heal` (`0` fires at `--gap 0`, `19` fires at `--gap 1` seed 1) fire only on real health-damaging hits.

2. **[SHOULD — FIXED] Stale `spatial_words_check.py` / `postponed` wording in depth source files (`nhan_tran.items.json`, `nhan_tran.techniques.json`) and staged `sets-nhan_tran.json` / `catalogue-sect-nhan_tran.json` / `nhan_tran.effects.json`**
   - **Files / Records:** `design/world/depth/sects/nhan_tran.items.json` (`nt-first-file-banner`, `One Goose`, `Geese Line`, `nt-out-of-the-grey`), `design/world/depth/sects/nhan_tran.techniques.json` (`wild-geese-formation-canon`, `geese-stance`, `one-breath-down-the-file`), `design/stage6-staging/nhan_tran/items/catalogue-sect-nhan_tran.json`, `design/stage6-staging/nhan_tran/items/sets-nhan_tran.json`, `design/stage6-staging/nhan_tran/techniques/catalogue-sect-nhan_tran.json`, `design/stage6-staging/nhan_tran/effects/nhan_tran.effects.json`.
   - **What was wrong:** While the staged records validly adapted `nhan_tran`'s `postponed-2026-11-26.json` ally-counting mechanics into 1v1 equivalents (keeping `nhan_tran`'s sole `main` technique and head/point items active), `nhan_tran.items.json`, `nhan_tran.techniques.json`, and `sets-nhan_tran.json` (`Last Man in the File`) still retained the old spatial/multi-ally rule text (`10` non-soft rule-field hits in `spatial_words_check.py --sect nhan_tran`: `banner`, `planted`, `Piece`, `Pieces`, `allies`, `ally`, `Alone`, `Displace`) that contradicted the staged 1v1 rules (`15 %` dampen + `30 %` first-share heal, `+8/+8` block, `+20` block + `1` Wood / `1` Corpse Rot cleanse, `geese-stance`, `one-breath-down-the-file`).
   - **Fix applied:** Updated the depth `rule` / `build_use` / `concept` lines and matching staged `sets-nhan_tran.json` / `catalogue-sect-nhan_tran.json` / `nhan_tran.effects.json` wording to match the 1v1 engine records (`"standard"`, `"raised"`). Post-edit `spatial_words_check.py --sect nhan_tran` has **0 non-soft rule-field hits** (only the 3 `soft` prose hits `Pace`, `pace`, `behind her`).

3. **[SHOULD — FIXED] Unasked `limit: {"per_pulse": 2}` cap on `Take the Wind` (`eff:Take the Wind ward`)**
   - **File / Record:** `design/stage6-staging/nhan_tran/effects/nhan_tran.effects.json` (`Take the Wind`).
   - **What was wrong:** `eff:Take the Wind ward` carried `limit: {"per_pulse": 2}` even though the depth rule says *"each block you make gives you a small ward"* with no per-pulse cap (*Scale without caps*; no other Stage 6 `on: "blocked"` ward/counter record caps per pulse).
   - **Fix applied:** Removed `limit: {"per_pulse": 2}` from `eff:Take the Wind ward` and removed `"(up to 2 times per pulse)"` from `Take the Wind`'s `rule`.

4. **[NIT — KEPT] `wild-geese-formation-canon` `b1` passive `attack_pct 6 ["tho"]`**
   - **Files / Records:** `design/stage6-staging/nhan_tran/techniques/catalogue-sect-nhan_tran.json`, `design/world/depth/sects/nhan_tran.techniques.json`.
   - **Assessment:** Preserved verbatim from `nhan_tran.techniques.json` (`b1` line, priced from Earth before the R3 no-lean ruling). Because all 5 `nhan_tran` arts have `element: ""`, `L1: 6` scoped to `element: "earth"` only boosts Earth arts if slotted; kept verbatim per `_brief-record.md`.

5. **[NIT — KEPT] `mountain-root-stance` + `marching-dirge` state coexistence on `dong_kien_luy` and `cat_tri_co`**
   - **Assessment:** Both `mountain-root-stance` (`family-body.json`, `root-toggle` on `tags: ["stance"]`) and `marching-dirge` (`family-soul-song-seal.json`, `state: "march"`, `tags: ["song", "stance", "form"]`) are pre-existing committed library arts. Staged `geese-stance` uses self-counter `geese_stance` and omits `"stance"` from `tags` (`["formation", "ward"]`), so it never clobbers or toggles either stance.

---

## Specific Stage 6 Checklist

- **Effect standalone compilation parity:** Every Effect in `design/stage6-staging/nhan_tran/effects/nhan_tran.effects.json` declares in its own `"counters"` every counter it reads or writes (`One Goose`: `banner_planted`; `Geese Line`: `banner_planted`, `geese_stance`; `Last Man in the File`: `banner_planted`; `Take the Wind`: `[]`). `engine.validate` passes standalone on all 4 Effects (`STANDALONE_OK`). Every art in `part-sect-nhan_tran.json` declares every counter it reads or writes (`geese-stance`: `geese_stance`; `trading-the-point`: `point_hold`, `geese_stance`; `one-breath-down-the-file`: `one_breath`). Zero `"states"` collisions (`geese-stance` uses counter `geese_stance`).
- **Multi-`mod` records & `always` filters:** Zero records contain two `"mod"` actions without `"stack": true` (`close-file-beat` and `close-file-wounded` each merge all stats into one `"mod"` dict). Zero `on: "always"` records have a record-level `filter`. Zero `decay_per_pulse: 1` off-by-one issues (`point_hold` and `one_breath` decrement explicitly on `pulse`).
- **Uniqueness:** Verified 0 ID/name collisions for all 3 techniques, 5 arts, 6 items, 2 sets, 4 Effect names, 21 Effect record IDs, and 6 counter IDs against `assets/data/combat_effects.json`, committed `design/`, and all other staged `b03` directories (`chan_kim`, `chuc_ha`, `hoa_cai`, `hong_dau`, `vu_linh`).
- **Stand-ins & root fit:** `0` stand-ins (`depth_gap.py`: `stand_ins 0`), `0` beasts, `0` early promotions; all 18 cast records (`15` living, `3` dead) match `build.gear` / `items` and fit their element-free / body techniques cleanly.

---

## Pending Words

None (`0` pending words; no `pending.json`).

---

## Checks After Final Edit (`DEPTH_STAGE=C:\Users\xphuo\IdeaProjects\my-game\design\stage6-staging\nhan_tran`)

- `lint_techniques.py design/stage6-staging/nhan_tran/techniques/catalogue-sect-nhan_tran.json`: `checked 3 techniques, 0 findings` (`16.0 W of 16`, `15.6 W of 16`, `22.5 W of 24`).
- `lint_arts.py design/stage6-staging/nhan_tran/arts/part-sect-nhan_tran.json`: `checked 5 arts in 1 files, 0 findings`.
- `lint_items.py design/stage6-staging/nhan_tran/items/catalogue-sect-nhan_tran.json`: `checked 6 items, 22 bases, 9 common arts, 0 findings` (`unique 6 of 6`).
- `depth_gap.py --sect nhan_tran`: `stand_ins 0`, `unknown_ids 0`, `cross_owner 0`, `ties_unmapped 0`, `ties_over_cap 0`, `engine_words 0`, `wishes_open 0`, `lines 29/29 runs`.
- `depth_check.py --quiet`: `findings: none`.
- `spatial_words_check.py --sect nhan_tran`: `0` non-soft rule-field hits in `nhan_tran` (`3` soft prose notes only).
- `sect_fight.py nhan_tran --seeds 5` (`--gap 0` and `--gap 1`): `0 REFUSED`, all 5 staged arts fire on real holders.

---

## Holder Table After Fixes (`sect_fight.py nhan_tran --seeds 5`, `--gap 0` / `--gap 1`)

| Holder | Realm | Arts Slotted | Gap 0 (`mean_s`, `wins/5`, `hp_left`) | Gap 1 (`mean_s`, `wins/5`, `hp_left`) | Staged Effects (`with` vs `without`, `runs`) / Notes |
|---|---|---|---|---|---|
| `muc_han_nhan` | `ket_dan` | `geese-stance`, `trading-the-point`, `mountain-root-stance`, `one-breath-down-the-file`, `the-rear-guard-faces-back`, `bone-turning-palm` | `32.0 s`, `5/5`, `100%` | `44.0 s`, `0/5`, `0%` | **One Goose**: G0 `32.0s 100%` (`runs 5`), G1 `44.0s` vs `23.4s` (`runs 38`; 20-seed G1: `40.8s` vs `24.4s`, `runs 139`). **Geese Line**: `always`-only (`runs 0`; 20-seed G1: `40.8s` vs `40.5s`). **Last Man in the File**: G0 `runs 51`, G1 `runs 74` (20-seed G1: `40.8s` vs `40.5s`, `runs 277`; poison/curse probe `shed_fires: 7`). |
| `dong_kien_luy` | `ket_dan` | `geese-stance`, `trading-the-point`, `mountain-root-stance`, `close-the-file`, `marching-dirge`, `bone-turning-palm` | `17.2 s`, `5/5`, `100%` | `16.4 s`, `0/5`, `0%` | All 6 arts fire (`3.0, 2.6, 4.0, 4.0, 7.0, 5.6` G0; `2.2, 2.2, 2.4, 2.4, 3.2, 2.0` G1); `close-file-wounded` fires `1` at G1. |
| `muc_tan_vu` | `truc_co` | `geese-stance`, `trading-the-point`, `mountain-root-stance`, `bone-turning-palm` | `26.0 s`, `5/5`, `100%` | `20.8 s`, `0/5`, `0%` | **Take the Wind**: G0 `26.0s 100%` (`runs 203`), G1 `20.8s` vs `18.2s` (`runs 194`, `+2.6s`). |
| `co_thiet_liet`, `ngo_bat_tan` | `truc_co` | `geese-stance`, `trading-the-point`, `mountain-root-stance`, `bone-turning-palm` | `29.9 s`, `5/5`, `100%` | `16.4 s`, `0/5`, `0%` | All 4 arts fire cleanly (`3.8, 3.2, 4.4, 7.0` G0; `2.0, 1.0, 1.8, 1.4` G1). |
| `duong_thu_tuyen` | `truc_co` | `geese-stance`, `trading-the-point`, `mountain-root-stance` | `60.8 s`, `5/5`, `96%` | `16.4 s`, `0/5`, `0%` | All 3 arts fire cleanly (`7.4, 6.8, 9.2` G0; `1.6, 1.0, 1.6` G1). |
| `luong_thu_hang` | `truc_co` | `geese-stance`, `trading-the-point`, `mountain-root-stance` | `60.8 s`, `5/5`, `96%` | `16.0 s`, `0/5`, `0%` | All 3 arts fire cleanly (`7.4, 6.8, 9.2` G0; `1.6, 1.0, 1.6` G1). |
| `cat_tri_co` | `truc_co` | `geese-stance`, `trading-the-point`, `mountain-root-stance`, `close-the-file`, `marching-dirge` | `38.6 s`, `5/5`, `95%` | `13.4 s`, `0/5`, `0%` | All 5 arts fire cleanly (`5.6, 5.0, 7.4, 7.6, 10.2` G0; `1.6, 1.6, 2.2, 1.8, 2.2` G1). |
| `bo_thanh_lang` | `luyen_khi` | `geese-stance`, `trading-the-point`, `close-the-file` | `51.7 s`, `5/5`, `93%` | `12.0 s`, `0/5`, `0%` | All 3 arts fire (`7.0, 6.8, 10.4` G0; `1.8, 1.0, 1.4` G1). |
| `thieu_vu_hang`, `la_nhat_hang`, `lam_te_vu`, `ninh_bac_hang` | `luyen_khi` | `geese-stance`, `trading-the-point` | `65.0 s`, `3/5`, `5%` | `10.8 s`, `0/5`, `0%` | Both arts fire (`8.0, 7.4` G0; `1.0, 0.6` G1). |

*(Outer disciples `lieu_kien_thach`, `luong_bo_khuyet`, `sach_bat_ngon`, `ton_lac_ho`, `hang_co_nhan` hold `mountain-bone-body-art` only and are skipped by `sect_fight.py` unless requested via `--people`.)*

CHECKPOINT DONE
