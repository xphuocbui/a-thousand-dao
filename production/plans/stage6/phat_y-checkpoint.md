# Phất Y Cốc (`phat_y`): Stage 6 checkpoint review (2026-11-27, fresh unanchored Hydrogen audit)

Fresh, unanchored audit of `design/stage6-staging/phat_y/` against `design/world/depth/sects/phat_y.*`, `phat_y.md`, `production/plans/stage6/_brief-record.md`, `DECISIONS-2026-11-25.md`, `DECISIONS-2026-11-26.md`, `tools/design/combat_sim/FIGHT-INPUT.md`, `bang_tam` reference files, and both fight engines (`tools/design/combat_sim/engine.py` and `src/gameplay/combat/fight/`).

**Verdict:** **3 findings fixed** (`2 MUST-FIX`, `1 SHOULD`) plus `2 NIT` observations logged. All three linters, `depth_check.py`, `depth_gap.py`, `put_effects.py --check`, `sect_fight.py` (`--gap 0` and `--gap 1`), standalone Effect validation, and targeted probes pass after final edits. `pending.json` is absent (`0` pending engine words).

---

## 1. Ranked findings

| # | File | Record ID | What was wrong | Fix applied | Rank |
|---|---|---|---|---|---|
| 1 | `design/stage6-staging/phat_y/effects/phat_y.effects.json`, `items/catalogue-sect-phat_y.json`, `items/sets-phat_y.json`, `design/world/depth/sects/phat_y.items.json`, `design/world/depth/sects/phat_y.md` | `Paid in Full` (`py-contract-seal`, `py-hired-pair`) | (a) `depth_gap.py` flagged `Effect names on more than one record: Paid in Full x3`: `market-folk.items.json` (`mf-golden-valley-seal`, not yet staged) owns `"Paid in Full (Thanh Toán)"` with a completely different rule (*"A debuff you apply cannot be cleansed until half its duration has run"*), which would collide with `assets/data/combat_effects.json` / `stage6_merge.py` uniqueness when `market-folk` merges; (b) `phat_y` also bundled two distinct rules (`py-contract-seal` 1pc vs `py-hired-pair` 2pc set) under one `"Paid in Full"` key, so wearing `py-contract-seal` alone granted the 2pc `crit -> 2% heal` set bonus. | Disambiguated and split cleanly: `py-contract-seal` now carries **`Contract Paid in Full (Khế Thanh Toán)`** (`id: "contract-paid-in-full"`, `was_hit` `cd 4.0 s` -> `dampen_taken: 20` for `2.0 s`, noting the item's `leech_health_pct: 15` covers heal-on-strike in 1v1), and `py-hired-pair` 2pc carries **`Hired Sword's Full Pay (Dung Kiếm Thanh Toán)`** (`crit` `per_pulse: 1` -> `heal: 0.02`, post-fight hirer-survival full heal unmodelled). Global `depth_gap.py` now reports `0` shared occurrences for `Paid in Full`; `put_effects.py --check` passes cleanly (`0` refused). | MUST-FIX |
| 2 | `design/stage6-staging/phat_y/effects/phat_y.effects.json` | `The Last Step` (`eff:The Last Step:sure_cut`) | Listened on `art_fired` with `filter: {"tags": ["sword"]}` and `own.since_act <= 0`. Because `step-back` (`c_art: 0.0`, 0 damage, never rolls evade) carries `"tags": ["kim", "sword", "movement"]` and `"movement"` sets `t_act = t`, `step-back` fired `eff:The Last Step:sure_cut` at `t = 1047 ms` and immediately set `first_sword_done = 1`, wasting the un-evadable `acc: 500` on `step-back` before any damaging sword art (`phantom-sword` at `t = 2027 ms`) fired. | Added `"not_art_id": "step-back"` to `eff:The Last Step:sure_cut`'s `filter` (keeping the 1 ms `art_fired` `mod: {"acc": 500}` without `tags`/`kind` inside `mod`, because `evade_chance()` in `engine.py:1285` and `fight.gd:1241` reads `mod(..., "acc")` without `ctx`). Verified in `thang_vo_ta` seed 1 trace: `step-back` at `1047 ms` no longer consumes `first_sword_done`, and `phantom-sword` at `2027 ms` receives `sure_cut`. | MUST-FIX |
| 3 | `design/stage6-staging/phat_y/effects/phat_y.effects.json`, `techniques/catalogue-sect-phat_y.json` | `Serve a Term` (`eff:Serve a Term:serve_evade`) | `eff:Serve a Term:serve_evade` granted `+1` Term on `evaded` (`per_pulse: 1`) independently of `eff:Serve a Term:serve` on `pulse`, allowing a fighter who evaded while `Pressing` to serve **2 Terms in 1 second**, while neither `rule` text mentioned `evaded`. Removing `serve_evade` altogether dropped `final-count` empowers to `0` (`au_duong_kien` / `thoi_an_thu` / `kieu_tinh_son` fell to `1/5` wins) because `step-back`'s `1.55 s` cooldown leaves a gap every ~4th pulse. | Added per-pulse guard counter `term_served` (`cap: 1`, cleared on `pulse` via `clear_served`) shared by `serve` and `serve_evade` so at most **1 Term** is served per pulse across `Pressing` and `evaded`, and updated `Serve a Term`'s `rule` and `approx` in `phat_y.effects.json` and `catalogue-sect-phat_y.json` to state both triggers explicitly. Pure `contract-sword-canon` holders still trigger `final-count` empowers (`au_duong_kien`: `3`, `thoi_an_thu`: `4`, `kieu_tinh_son`: `4`, `lo_khinh_tran`: `2` across 5 seeds) with honest 1-Term/s pacing (`50–54 s` fights). | SHOULD |
| 4 | `design/stage6-staging/phat_y/techniques/catalogue-sect-phat_y.json` | `dry-road-sword-primer` | `names: ["kim", "hoa"]` matches depth text (*"Metal or Fire, either one"*), but `CongPhap.usable()` (`src/gameplay/cultivation/cong_phap.gd:40-44`) currently requires **all** elements in `names`: `hua_ngan_son` (`kim 44, thuy 24`) and cross-owner `dieu_thiet_tien` (`market-folk`, `tho 44, kim 36`) lack `hoa`. | **Not applied** (preserved depth `names: ["kim", "hoa"]`, matching `thuy_vi-checkpoint.md` #16 and `lac_ha-checkpoint.md`). Logged as Open item #2 for Stage 7/9 `CongPhap.usable()` ruling. | NIT |
| 5 | `design/stage6-staging/phat_y/arts/part-sect-phat_y.json` | `a-thousand-sleeves`, `step-back` | `a-thousand-sleeves-echo` uses `limit: {"per_pulse": 2}` (to keep `flying-sword` summons + direct hits from saturating `trig_cap = 6`), and `step-back-ward-break` uses `limit: {"per_fight": 1}` (`foe.qi_share <= 0.05` proxy for breaking the main ward). | **Not applied** (matches documented `rule` text and trigger-budget safety). | NIT |

---

## 2. Explicit parity, uniqueness, and probe checks

- **Effect name & ID uniqueness:** Verified all `3` techniques, `5` arts, `4` items, `2` sets, and `5` Effects (`Serve a Term`, `Gone Before Thanks`, `Contract Paid in Full`, `Hired Sword's Full Pay`, `The Last Step`) have **0 collisions** against `assets/data/combat_effects.json`, committed `design/`, all other `design/stage6-staging/` (`b03`) folders, and depth `*.items.json` / `*.techniques.json` (`depth_gap.py` global shared-effect list no longer contains `Paid in Full`).
- **Standalone Effect compilation parity:** All `5` Effects in `effects/phat_y.effects.json` pass `engine.validate()` (`STANDALONE_EFFECT_CHECK: OK 5`), declare every read/written `own.counter.*` in their own `counters` array, use no `states` (leaving `thang_vo_ta`'s `flurry-stance` untouched), have no multi-`mod` records without `"stack": true`, no `on: "always"` with record-level `filter`, and no `decay_per_pulse: 1` off-by-one decay.
- **Depth fidelity & cross-owner refs:** Verified 1:1 field parity between staged catalogues and `phat_y.techniques.json` / `phat_y.items.json`; `0` stand-ins, `0` beasts, `0` environment conditions, `0` spatial fight mechanics (`spatial_words_check.py`: `0` hits in `design/stage6-staging/phat_y/`). Confirmed the `2` incoming `cross_owner` refs on `dry-road-sword-primer` (`loose-south` `tu_ban_kiem` L5 and `market-folk` `dieu_thiet_tien` L4) close on serial merge; `tu_ban_kiem` (`tho 40, kim 34, hoa 26`) fits `noon-guard` cleanly with no second stance.
- **Targeted probes (`Gone Before Thanks` & `brushed-sleeve-step`):**
  - `Gone Before Thanks`: at `--gap 0` typical foe, `thang_vo_ta` wins in `12.1 s` right as `broken` triggers, and at `--gap 1` he falls at `15.2 s` before reaching `25 %` foe HP. In a 10-seed targeted probe with `blade-thousand-cut-return` (`element: "metal"`) slotted against a durable Kết Đan foe (`n_body * 3, ward_pts * 2`), `Gone Before Thanks` shifted the fight by **`-3.71 s`** and **`+4.3 %` HP** (`26.21 s 83.2%` with, `35` runs vs `29.92 s 78.9%` without).
  - `brushed-sleeve-step` (`brush-the-sleeve`, `a-thousand-sleeves`): sit past `MAX_ARTS = 6` in `sect_fight.py` on `thang_vo_ta`. When slotted directly on `thang_vo_ta` (`5` seeds), they shifted `--gap 0` from `15.40 s 88.7%` (without) to **`13.22 s 90.7%`** (with: `28` `brush-the-sleeve-haste` procs, `80` `a-thousand-sleeves-echo` procs) and fired actively at `--gap 1` (`30` haste procs, `56` echo procs; still `0/5` vs Nguyên Anh typical foe at `15.2 s`).

---

## 3. Pending words

None (`pending.json` absent; `0` pending engine words).

---

## 4. Holder table after the fixes

All run post-edit with `$env:DEPTH_STAGE = "C:\Users\xphuo\IdeaProjects\my-game\design\stage6-staging\phat_y"`:
- `lint_techniques.py`: `checked 3 techniques, 0 findings` (`6.7/8`, `15.7/16`, `22.0/24` W).
- `lint_arts.py`: `checked 5 arts in 1 files, 0 findings`.
- `lint_items.py`: `checked 4 items, 22 bases, 9 common arts, 0 findings` (`unique 4 of 4`).
- `depth_check.py --quiet`: `findings: none`.
- `depth_gap.py --sect phat_y`: `stand_ins: 0`, `unknown_ids: 0`, `engine_words: 0`, `wishes_open: 0`, `lines: 19 runs / 1 game (khi_van)`, `cross_owner: 2`.
- `sect_fight.py phat_y --seeds 5` (`--gap 0` and `--gap 1`): `0 REFUSED`, `0 NEVER_FIRED` across all `17` living holders.

| Holder(s) | Realm | `--gap 0` (`5` seeds: `t` / wins / `hp_left`) | `--gap 1` (`5` seeds: `t` / wins / `hp_left`) | Effects (`--gap 0` with / without / `runs`) & Notes |
|---|---|---|---|---|
| `thang_vo_ta` | `ket_dan` | `12.1 s` / `5/5` / `91%` | `15.2 s` / `0/5` / `0%` | `Serve a Term`: `12.1 s 91%` / `12.3 s 90%` (`223`); `Marked Prey`: `12.1 s 91%` / `12.4 s 91%` (`0`, `always` mod); `Gone Before Thanks`: `12.1 s 91%` / `12.1 s 91%` (`5`; `0` at `--gap 1`, probed above); `The Last Step`: `12.1 s 91%` / `12.4 s 91%` (`234`, `sure_cut` now fires on `phantom-sword` at `2027 ms`) |
| `lam_khe_ngon` | `truc_co` | `29.8 s` / `5/5` / `65%` | `10.2 s` / `0/5` / `0%` | `Serve a Term`: `29.8 s 65%` / `32.2 s 59%` (`289`); `Contract Paid in Full`: `29.8 s 65%` / `29.8 s 64%` (`37`; `--gap 1`: `10.2 s` / `9.6 s`, `14`); `Hired Sword's Full Pay`: `29.8 s 65%` / `29.0 s 51%` (`37`; `--gap 1`: `10.2 s` / `10.0 s`, `11`) |
| `tiet_hoanh_sa` | `truc_co` | `31.8 s` / `5/5` / `27%` | `8.4 s` / `0/5` / `0%` | `Serve a Term`: `31.8 s 27%` / `35.8 s 15%` (`309`) |
| `khuc_liet_duong` | `truc_co` | `31.8 s` / `5/5` / `26%` | `8.4 s` / `0/5` / `0%` | `Serve a Term`: `31.8 s 26%` / `35.8 s 15%` (`309`) |
| `au_duong_kien` | `truc_co` | `53.2 s` / `2/5` / `14%` | `9.8 s` / `0/5` / `0%` | `Serve a Term`: `53.2 s 14%` / `54.6 s 0%` (`434`; `3` `final-count` empowers) |
| `kieu_tinh_son`, `thoi_an_thu` | `truc_co` | `54.0 s` / `3/5` / `15%` | `9.8 s` / `0/5` / `0%` | `Serve a Term`: `54.0 s 15%` / `54.6 s 0%` (`454`; `4` `final-count` empowers each) |
| `au_duong_tuyen`, `manh_thu_cam`, `lo_khinh_tran`, `vien_tich_chieu` | `luyen_khi` | `50.4 s` / `2/5` / `11%` | `9.0 s` / `0/5` / `0%` | `Serve a Term`: `50.4 s 11%` / `45.6 s 0%` (`385`; `2` `final-count` empowers on `lo_khinh_tran`) |
| `lieu_vong_phong`, `hoac_ngo_lo`, `yen_lac_tu`, `giang_bich_sa`, `cat_da_binh`, `hua_ngan_son` | `luyen_khi` | `61.4 s` / `0/5` / `0%` | `9.2 s` / `0/5` / `0%` | `noon-guard` fires `1.0` per fight |

---

## 5. Open items

1. **Serial merge & export:** Merge `design/stage6-staging/phat_y/` via `stage6_merge.py` and re-export (`export_techniques.py`, `export_named.py`, `export_combat_library.py`, `compile_parity_export.py`, `export_world.py`); closes the `2` incoming `cross_owner` refs on `dry-road-sword-primer`.
2. **`dry-road-sword-primer` `names: ["kim", "hoa"]` vs `CongPhap.usable()` (NIT #4):** Needs Stage 7/9 decision on OR-vs-AND element usability for `hua_ngan_son` and `dieu_thiet_tien` (same pattern as `thuy_vi` / `lac_ha`).
3. **`khi_van` out-of-fight reader (`py-contract-seal`)** and **multi-ally hirer-survival full-heal clause (`Hired Sword's Full Pay`)** if allied-charge fights are added later.

CHECKPOINT DONE
