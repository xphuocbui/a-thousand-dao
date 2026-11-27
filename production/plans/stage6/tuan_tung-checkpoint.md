# Tuần Tùng Đường (`tuan_tung`): Stage 6 Checkpoint Review

Unanchored checkpoint review of `design/stage6-staging/tuan_tung/` against `design/world/depth/sects/tuan_tung.*`, `tuan_tung.md`, `production/plans/stage6/_brief-record.md`, `DECISIONS-2026-11-25.md`, `DECISIONS-2026-11-26.md`, and `tools/design/combat_sim/FIGHT-INPUT.md`.

---

## 1. Ranked Findings

1. **SHOULD — `design/stage6-staging/tuan_tung/effects/tuan_tung.effects.json` & `techniques/catalogue-sect-tuan_tung.json` :: `Warden Geese Line`**
   - **What was wrong:** The `Warden Geese Line` rule text (`"or your companion fights beside you"`) used the soft spatial word `"beside"`, which `spatial_words_check.py` flags once merged into `assets/data/combat_effects.json` (`STAGED_SPATIAL_HITS 2` on `beside`).
   - **Fix applied:** Reworded `"fights beside you"` -> `"fights with you"` in both [tuan_tung.effects.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/tuan_tung/effects/tuan_tung.effects.json#L6) and [catalogue-sect-tuan_tung.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/tuan_tung/techniques/catalogue-sect-tuan_tung.json#L29). Re-running `spatial_words_check.scan` over all 5 staged files now reports `STAGED_SPATIAL_HITS 0`.

2. **NIT (informational, no edit) — `design/world/depth/sects/tuan_tung.techniques.json` :: `pine-warden-staff-and-bow-canon` (`b10` `["bow"]` scope)**
   - `pine-warden-staff-and-bow-canon` (`attack_pct 6`, `crit_damage_pct 20`) and `ttg-wolf-winter-bow` (`attack_pct 21`) use `scope: ["physical"]` in the staged catalogues as a deferred workaround until `"bow"` enters `lint_techniques.py` `TIER` during `s6-serial-b05`. Kept unchanged per task instructions.

---

## 2. Specific Audits & Parity Verification

- **`Dawn Shot` (`ttg-three-nights` 2-piece set):**
  - `eff:Dawn Shot dmg` uses `"on": "always"` (NOT `temp_mods`), with `"scale": {"read": "own.counter.dawn_wait", "per": 1}` and `"mod": {"dmg_more": 0.015, "art_id": "the-leader-first"}`. Verified in both `engine.py` (`match`) and `effect_runner.gd` (`_EQ_KEYS` includes `"art_id"`): `"on": "always"` preserves `art_id` filtering, and there is no `temp_mods` `art_id` drop and no multi-`mod` clobber.
  - `eff:Dawn Shot bypass` is a separate `"on": "always"` record granting `bypass: 0.25` scoped to `tags: ["bow"]`, stacking cleanly with `leader-bypass` (`0.25 + 0.25 = 0.50`, `bypass_cap`).
  - Verified directly on `hua_van_cung` (`marked_leader = 1`, `dawn_wait = 10`): `the-leader-first` receives `dmg_more = 0.15, bypass = 0.5`; `pinning-arrow` and `nocked-arrow` receive `dmg_more = 0.0, bypass = 0.5`; `wolf-ring`, `second-night`, and basic attacks receive `dmg_more = 0.0, bypass = 0.0`.
  - `eff:Dawn Shot reset` listens on `hit_landed` (`filter: {"art_id": "the-leader-first"}`) and resets `dawn_wait` to `0` (`39` resets across 10 seeds in `DAWN_WITH`).
- **`Warden Geese Line` (layer-2 technique Effect + `thuong_muc` beast interaction):**
  - Wired in `catalogue-sect-tuan_tung.json` on `pine-warden-staff-and-bow-canon` (`unlock_layer: 2, passive_art: true`) and renamed from `Geese Line` (owned by `world-depth:nhan_tran` in `assets/data/combat_effects.json`).
  - Declares all three counters (`warden_brace`, `ring_wardens` with `each_for: 3`, `warden_companion`) locally in its own `"counters"` list.
  - `eff:Warden Geese Line brace` filters on `group: "pine-warden-staff-and-bow-canon"` (`wolf-ring`, unlocked at layer 2 alongside `Warden Geese Line`, so every layer-2+ warden fires it).
  - Companion anchors listen on both `hit_landed` and `was_evaded` (`filter: {"kind": "companion"}`), tested with `diem_lac_nhan` + `thuong_muc` (`tuan_tung.beasts.json`, wired on `diem_lac_nhan.beasts` in `tuan_tung.cast.json`): in `DIEM_EAGLE_WITH` (10 seeds), `eff:Warden Geese Line companion hit: 10`, `eff:Warden Geese Line brace: 10`, raising HP left from `76.7%` to `80.9%` (`16.60 s, 10/10`).
- **`second-night` (`glow_clock >= 30 s`):**
  - `second-night-clock-pulse` (`+1` per `pulse`) is ordered before `second-night-regen` (`heal 0.015`), and `second-night-clock-hit` (`was_hit`) guards on `event.amount > 0` (`+1.5` per damaging blow, matching `lac_ha`'s `The Glow Deepens`).
  - Two separate `"on": "always"` records (`second-night-staff`, `second-night-bow`) apply `+15% dmg_more` on `tags: ["staff"]` and `tags: ["bow"]` once `own.counter.glow_clock >= 30`.
  - Verified threshold behavior (`glow_clock = 29` -> `0.0` vs `glow_clock = 30` -> `0.15` on `wolf-ring` and `pinning-arrow`) and 10-seed probe `GLOW30_WITH` vs `GLOW30_WITHOUT_SN` (`24.15 s, 10/10, 99.8%` with `second-night-regen: 150` vs `25.30 s, 10/10, 93.2%`).
- **`the-leader-first` + `The Pack Turns`:**
  - `leader-mark` (`on: "art_fired"`) sets `marked_leader = 1` before `the-leader-first`'s own hit lands, so `leader-bypass` (`0.25 [bow]`) applies from the first shot and `broken` listeners trigger even if the first shot crosses 25% HP.
  - `leader-broken` applies `slowed_time` `stacks: 2, dur: 4` without `cap: 1` (preserving catalogue `cap: 5`). `The Pack Turns` declares `marked_leader` in its own `"counters"` and fires `stop_clock {side: "foe", seconds: 3.0}` on `broken`.
  - At `--gap 0`, `The Pack Turns` runs `5` times over 5 seeds on `hua_van_cung` (`15.3 s 100%` vs `15.1 s 99%`). At `--gap 1`, `hua_van_cung` falls at `10.1 s` before the `ket_dan` typical foe crosses `<= 25%` HP (`runs 0 NEVER_RAN` is expected).
- **`Ring for the Wardens` (`ttg-caravan-bell`):**
  - Rings on `on: "pulse"` with `limit: {"cooldown": 10}` adding `1` to `ring_wardens` (`each_for: 3`), applying `dampen_taken: 20` and `dmg_more: 0.2 [kind: "companion"]` while active, and also lighting `Warden Geese Line block bell` (`+8` block).
  - Verified on `trang_thiet_cuoc` (`sect_fight.py`: `15` runs at gap 0, `8` at gap 1) and in `TRANG_COMP_WITH` (`27` rings, `second-night-clock-hit` reduced `211` vs `251` without).
- **Standalone compilation, collisions & spatial check:**
  - `4/4` Effects in `tuan_tung.effects.json` pass standalone `E.validate()` and run a fight (`STANDALONE_OK 4`).
  - `0` multi-`mod` records without `"stack": true`; `0` `temp_mods` filtering by `"art_id"`; `0` `always` records with record-level `filter`; `0` `decay_per_pulse: 1`.
  - `0` technique/art/item/set ID or Effect name collisions against `assets/data/combat_effects.json`, committed `design/`, or other `design/stage6-staging/` directories.
  - `spatial_words_check.scan` over all 5 staged files: `STAGED_SPATIAL_HITS 0`.

---

## 3. Pending Words

None (`pending.json` absent; all mechanics expressed cleanly with existing engine words).

---

## 4. Holder Table (after final edits)

### Linters & Checks (`DEPTH_STAGE=C:\Users\xphuo\IdeaProjects\my-game\design\stage6-staging\tuan_tung`)
- `lint_techniques.py`: `checked 3 techniques, 0 findings` (`pine-warden-staff-and-bow-canon`: `NOT ASSESSED` due to `can_cot`, `three-nights-on-the-road`: `16.0 W of 16`, `wolf-winter-arrow`: `15.8 W of 16`).
- `lint_arts.py`: `checked 3 arts in 1 files, 0 findings`.
- `lint_items.py`: `checked 3 items, 22 bases, 9 common arts, 0 findings` (`3 of 3` unique, R6 `exception` on all 3).
- `depth_check.py --quiet`: `findings: none`.
- Standalone Effect compile & fight: `STANDALONE_OK 4`.
- Staged spatial scan: `STAGED_SPATIAL_HITS 0`.

### `sect_fight.py tuan_tung --seeds 5` (`--gap 0`, `--gap 1`, and `--people` for outer disciples; `0` `REFUSED` across all 16/16 living members)

| Holder | Realm | Arts (gap 0 fires) | Gap 0 (`mean_s`, `wins`, `hp_left`) | Gap 1 (`mean_s`, `wins`, `hp_left`) | Effects (gap 0 with vs without, runs; gap 1 runs) |
|---|---|---|---|---|---|
| `hua_van_cung` | `truc_co` | `pinning-arrow` (4.8), `wolf-ring` (4.2), `nocked-arrow` (4.8), `the-leader-first` (2.0), `second-night` (2.0) | `15.3 s`, `5/5`, `100%` | `10.1 s`, `0/5`, `0%` | `Warden Geese Line`: 15.3s 100% vs 15.3s 100% (`5` / `5`); `The Pack Turns`: 15.3s 100% vs 15.1s 99% (`5` / `0` — falls before 25% HP); `Dawn Shot`: 15.3s 100% vs 15.3s 100% (`86` / `55`) |
| `trang_thiet_cuoc` | `truc_co` | `pinning-arrow` (7.4), `wolf-ring` (6.0), `nocked-arrow` (7.4), `second-night` (3.4) | `22.2 s`, `5/5`, `100%` | `11.3 s`, `0/5`, `0%` | `Warden Geese Line`: 22.2s 100% vs 21.6s 100% (`5` / `5`); `Ring for the Wardens`: 22.2s 100% vs 21.6s 100% (`15` / `8`) |
| `diem_lac_nhan` | `truc_co` | `pinning-arrow` (6.6), `wolf-ring` (5.6), `nocked-arrow` (6.6), `the-leader-first` (3.0) | `19.8 s`, `5/5`, `77%` | `9.7 s`, `0/5`, `0%` | `Warden Geese Line`: 19.8s 77% vs 19.8s 75% (`5` / `5`); + `thuong_muc` 10-seed probe: `16.60 s`, `10/10`, `80.9%` vs `76.7%` |
| `lac_tung_lang` | `truc_co` | `pinning-arrow` (7.6), `wolf-ring` (6.2), `nocked-arrow` (7.6) | `22.9 s`, `5/5`, `71%` | `9.8 s`, `0/5`, `0%` | `Warden Geese Line`: 22.9s 71% vs 22.9s 68% (`5` / `5`) |
| `canh_da_tuan`, `tu_tien_suong` | `truc_co` | `pinning-arrow` (4.8), `wolf-ring` (4.0), `nocked-arrow` (4.8), `marrow-tithe-strike` (1.0), `bulwark-knuckle` (2.0), `last-breath-fist` (2.8) | `14.8 s`, `5/5`, `91%` | `25.6 s`, `0/5`, `0%` | `Warden Geese Line`: 14.8s 91% vs 14.6s 91% (`5` / `5`) |
| `ly_hanh_lo`, `lieu_khe_nhi`, `hua_tich_van`, `khau_toan_lo` | `luyen_khi` | `pinning-arrow` (12.0), `wolf-ring` (9.6) | `37.5 s`, `2/5`, `7%` | `8.6 s`, `0/5`, `0%` | `Warden Geese Line`: 37.5s 7% vs 37.0s 5% (`5` / `5`) |
| `sam_thanh_tung` | `luyen_khi` | `pinning-arrow` (15.2) | `47.2 s`, `1/5`, `0%` | `8.7 s`, `0/5`, `0%` | — (L1 `<` L2 unlock) |
| `vuong_tieu_nhi`, `doan_bat_mien`, `hoang_thiet_huyen` (`--people`) | `luyen_khi` | `marrow-tithe-strike` (3.4), `bulwark-knuckle` (5.0) | `31.0 s`, `5/5`, `67%` | — | — (`unbroken-flesh-canon`) |
| `trang_tieu_da`, `lam_tieu_tien` (`--people`) | `luyen_khi` | `marrow-tithe-strike` (4.0) | `32.6 s`, `5/5`, `13%` | — | — (`unbroken-flesh-canon`) |

CHECKPOINT DONE
