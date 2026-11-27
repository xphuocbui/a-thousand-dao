# The Clans (`clans`): Stage 6 Checkpoint Review

Unanchored checkpoint review of `design/stage6-staging/clans/` against `design/world/depth/people/clans.*`, `clans.md`, `production/plans/stage6/_brief-record.md`, `DECISIONS-2026-11-25.md`, `DECISIONS-2026-11-26.md`, `assets/data/combat_effects.json`, and `tools/design/combat_sim/FIGHT-INPUT.md`.

---

## 1. Ranked Findings

1. **MUST-FIX — `design/stage6-staging/clans/effects/clans.effects.json` :: top-level `"source"` & `"_doc"` missing**
   - **What was wrong:** `clans.effects.json` omitted `"source": "world-depth:clans"` and `"_doc"` at the top level (putting `"source"` only inside each Effect entry). `tools/design/combat_sim/put_effects.py` reads `src["source"]` directly at the top level and would fail with `KeyError: 'source'` during the serial export step.
   - **Fix applied:** Added `"_doc"` and `"source": "world-depth:clans"` at the top level matching `bang_tam.effects.json`, and verified `put_effects.py design/stage6-staging/clans/effects/clans.effects.json --check` runs cleanly (exit `1` indicating valid merge diff with `0` refused keys).

2. **MUST-FIX — `design/stage6-staging/clans/items/sets-clans.json` :: all 6 sets (`cl-locust-shade`, `cl-twin-bridges`, `cl-set-old-hall`, `cl-granary`, `cl-ho-fleet`, `cl-reeling-thread`)**
   - **What was wrong:** All 6 sets had their names and 2-piece modifiers silently altered from `design/world/depth/people/clans.items.json` without logging any decision or reason, Hán-Việt parentheticals on `effect` were dropped, and `cl-reeling-thread` had its 2-piece `modifiers` (`stack_duration_pct +12 [hoa, debuff]`, `attack_pct +6 [fire]`) completely deleted.
   - **Fix applied:** Restored exact depth set names (`Locust Shade (Hòe Âm Tam Kiện)`, `Twin Bridges (Song Kiều Tam Kiện)`, `The Old Hall (Cựu Đường Tam Bảo)`, `The Granary (Thương Lẫm Tam Kiện)`, `The Hỗ Fleet (Hỗ Gia Thuyền Đội)`, `Reeling Thread (Trừu Ti Song Kiện)`), exact depth 2-piece `modifiers` (including `cl-reeling-thread`'s 2-piece modifiers), `"<Effect Name> (<Hán-Việt>)"` on `effect`, and faithful `rule`/`story` text (retaining the non-spatial/1v1 wording on `He Waited`, `Pillar in the Flood`, and `Leave With the Tide`). Updated `clans.effects.json` `"rule"` prefixes to match the restored set names.

3. **MUST-FIX — `design/stage6-staging/clans/effects/clans.effects.json` :: `The Swallow Returns` (`cl-swallow-hall-fan`)**
   - **What was wrong:** Three bugs in `eff:The Swallow Returns:*`:
     1. `arm` added `"filter": {"element": "wood", "tags": ["quick"]}`, which contradicts `clans.items.json` (`"Your first art of each fight is cast again 3 s later at 40 % power"`).
     2. `tick` (`swallow_wait > 1 -> add -1`) was ordered *before* `fire` (`swallow_wait == 1 -> fire_art`), so `swallow_wait = 3` decremented `3 -> 2` on pulse 1 (`t=3000`), then `2 -> 1` and fired on pulse 2 (`t=4000`, only `1.76 s` after `t=2239` instead of 3 pulses).
     3. Because `ta_cuu_duong` casts `marching-dirge` and `blood-ink-writ` at `t=3000`, firing at `t=4000` caused `fire_art {which: "last"}` to echo `blood-ink-writ` instead of `swallows-return`.
   - **Fix applied:** Removed the `wood`/`quick` filter from `arm` (triggers on the first `art_fired` of the fight when `swallow_used == 0`), and ordered `fire` (`swallow_wait == 1`) *before* `tick` (`swallow_wait >= 1 -> add -1`) so it waits 3 full pulses (`t=3000: 3->2`, `t=4000: 2->1`, `t=5000: fire` — when `ta_cuu_duong`'s `last_art` is `swallows-return` from `t=4546`). Updated `rule` and `approx` to accurately document the first-art trigger and `which: "last"` 3-pulse echo approximation.

4. **MUST-FIX — `design/stage6-staging/clans/effects/clans.effects.json` :: `He Waited`, `The Drawn Thread`, `Outlast the Drought` (unfaithful caps & `He Waited` rule/code contradiction)**
   - **What was wrong:**
     - `He Waited`: `clans.items.json` has no cap (`"for each 10 s you are Still, your wards gain 5 % strength, and the gain falls away by a fifth each second once you move; your first damaging art after it is a sure hit"`). Staged `clans.effects.json` invented `"cap": 3` (`up to +15%`), contradicted its own `per: 5, floor: false` decay code by stating `"Drops 1 stack per pulse"` in `rule`/`approx`, and added `"do not stop being Composed"` even though `wait_still` intentionally accumulates Composed pulses without resetting (needed for `tieu_thua_am`, who fires `falling-locust-flowers` every 5 s).
     - `The Drawn Thread`: `clans.items.json` has no cap (`"each thread lasts 8 s on its own"`), yet `thread` added `"cap": 4` (`up to 4`).
     - `Outlast the Drought`: `clans.items.json` has no cap (`"every 10 s of a fight you store a seed"`), yet `granary_seed` added `"cap": 4` (`up to 4`).
   - **Fix applied:** Removed `"cap"` from `wait_ward` (`He Waited`), `thread` (`The Drawn Thread`), and `granary_seed` (`Outlast the Drought`) per the standing `scale-without-caps` rule (bounded by `per: 5` decay, `each_for: 8`, and full consumption at `< 20% HP`, respectively), and aligned `rule`/`approx` in `clans.effects.json` and `sets-clans.json` with `clans.items.json`.

5. **SHOULD — `design/stage6-staging/clans/arts/part-sect-clans.json` :: `pillar-in-the-current` (`guards`)**
   - **What was wrong:** Guarding `pillar-in-the-current` on `own.counter.pillar_hits < 1` would permanently soft-lock the art if a holder ever entered another stance before taking 3 hits (since `push` requires `own.state.pillar-in-current == 1` to decrement `pillar_hits`).
   - **Fix applied:** Changed `guards` to `[{"read": "own.state.pillar-in-current", "op": "<", "value": 1}]`, matching the studio's stance guard pattern (`still-on-the-branch`, `heart-in-the-jade-vessel`).

6. **NIT (no edit) — `design/stage6-staging/clans/items/catalogue-sect-clans.json` :: redundant `rarity` on `artifact` items**
   - `lint_items.py` computes artifact rarity as `grade + 1` and only reads `"rarity"` on `kind: "treasure"`, so `"rarity": 1/2/3` on the 14 `artifact` items is ignored. Left untouched.

7. **NIT (no edit) — `design/world/depth/people/clans.cast.json` & `clans.2.cast.json` :: `"the id is a stand-in."` in `build.note`**
   - All 46 replaced people keep `"; the id is a stand-in."` in `build.note` (matching committed cast files such as `bang_tam.cast.json` and `thien_xu.cast.json`). Left untouched.

---

## 2. Specific Audits & Parity Verification

- **`pillar-in-the-current` (`timer {side: "foe", which: "next", by: 0.5}`):**
  - All 7 Ôn holders of `twin-span-pillar-method` (`on_thuc_ha`, `on_the_hoanh`, `on_lap_tru`, `lo_hanh_nuong`, `on_thanh_luu`, `on_huu_toan`, `on_bich_de`) slot only `pillar-in-the-current` (no other stances on `own`), and `on_trong_luong` runs `mountain-heart-canon` (`mountain-stance` / `mountain-root-stance`, neither guarded-out).
  - `timer` targets `side: "foe"` (`which: "next"`, `by: 0.5`), and `push` runs before `exit` on `was_hit` so the 3rd hit delays the foe's next art, decrements `pillar_hits` to `0`, and `exit` immediately clears the stance. Verified in parity trace (`on_thuc_ha` seed 0: enters at `6.0 s`, `push` x3 + `exit` at `8.0 s`, re-enters at `12.0 s`).
- **`falling-locust-flowers` Fire-debuff gate (`own.debuff.fire == 0`):**
  - Verified in parity trace (`tieu_thu_dao` vs `doi_tam_nuong` seed 0): at `5.0 s` (`0` Fire debuffs) fires `heal` x4 and `stack` x1; at `10.0 s` and `20.0 s` (while carrying Fire debuffs) both `heal` and `stack` are suppressed; at `15.0 s` (after Fire debuffs expire) both resume.
- **`He Waited` (`own.composed`) & `Under the Locust` (`ward_pct`):**
  - Verified `ward_pct` is in `MOD_KEYS` (`engine.py:1392`, `defence_path.gd:30`) and `scale` `floor: false` matches `EffectRunner.scale` (`effect_compiler.gd:79`, `effect_runner.gd:195`).
  - On `tieu_thua_am` (`gap=0`), `sect_fight.py` shows `64.4 s 59%` with and without because `shade-of-the-road`'s stance ward + main drain ward + Wood regrowth keep HP on the same curve, though `ward_paid` shifts (`2265.94` vs `2256.86` without `Under the Locust`, `2250.56` without `He Waited`), and at `gap=1` `Under the Locust` reduces negative HP overshoot (`-4498.85` vs `-4592.73`).
- **`Pillar in the Flood` (`delay_immune: 1, unmoved: 1`):**
  - Both keys are in `MOD_KEYS` and read via `always` (`own.hp_share > 0.5`), paired with `blocked` (`event.amount > 0`) `flood_blk` count -> reset -> `burn_qi {share: 0.03, of: "qi_max", to_self: 1.0}` (`on_trong_luong` `--gap 1`: `65.4 s 57%` with vs `66.0 s 37%` without, `runs 563`).
- **`The Swallow Returns to Its Nest` (`cl-set-old-hall` 3pc) & `Pulled Tight` (`cl-reeling-thread` 2pc):**
  - `The Swallow Returns to Its Nest` (`count` before `strike` on `art_fired`, `element: "wood"`): `0` runs in default `sect_fight.py` because `cl-swallow-hall-fan` + `cl-ta-hall-seal` sit on `ta_cuu_duong` while `cl-returning-ink-pendant` sits on `ta_tri_xuan` by design. Verified in 3pc probe (`ta_cuu_duong` + `cl-returning-ink-pendant`, seed 0): `count` fires every Wood cast and `strike` (`c=1.4 soul`) fires on the 3rd and 6th Wood casts (`6.34 s`, `12.21 s`).
  - `Pulled Tight` (`art_id: "needle-rain"` and `tags: ["needle"], not_art_id: "needle-rain"`): `0` runs in default `sect_fight.py` because `doi_tam_nuong` slots `red-sun-scripture` without auto-slotting `cl-golden-reeling-needle`'s common art `needle-rain`. Verified in probe (`doi_tam_nuong` + `needle-rain`, seed 0): `eff:Pulled Tight:rain` fires at `8.0 s` when `foe.debuff.fire >= 6`.
- **Standalone Effect compilation, multi-`mod`, `temp_mods`, collisions & spatial check:**
  - `12/12` Effects pass `fight.to_build` + `engine.validate()` standalone with every counter declared in its own `"counters"` and `0` stances.
  - `0` multi-`mod` clobbers, `0` `temp_mods` filtering by `"art_id"`, `0` `always` records with record-level `filter`, `0` `decay_per_pulse: 1`, `0` Effect-name/ID collisions against `assets/data/combat_effects.json`, committed `design/`, or other `design/stage6-staging/` directories.
  - `spatial_words_check.py --sect clans` exits `0` (`0` hits in `clans` records; `61` total non-soft hits across `assets/data/`).
- **Cast stand-ins (`46/46` replaced across 7 clans/houses, `depth_gap.py --sect clans` `stand_ins: 0`):**
  - All `50` living clan/house members (`clans.cast.json` + `clans.2.cast.json`) pass `CongPhap.usable()` root element checks (`aux_bad: []`, `items` match `gear`):
    - Tiêu (8, all `thuy`+`moc`): `locust-shade-breathing` (`["thuy", "moc"]`).
    - Ôn (7 replaced, all `tho`+`moc`): `twin-span-pillar-method` (`["tho", "moc"]`); head `on_trong_luong` keeps `mountain-heart-canon` (`["tho"]`).
    - Tạ (8, all `moc`+`thuy`): `returning-swallow-breath` (`["moc", "thuy"]`).
    - Lục (7 replaced, all `moc`): `seed-store-method` (`["moc"]`); head `luc_thuong_lam` keeps `verdant-cycle-scripture` (`["moc"]`); spouse `tong_thanh_mieu` (`kim: 42, thuy: 38, moc: 26`): `nine-temper-scripture` (`["kim"]`).
    - Hỗ (6 replaced, all `thuy`): `still-moon-tide-scripture` (`["thuy"]`), matching head `ho_te_xuyen` (`still-moon-tide-scripture`); spouse `man_tu_chi` (`moc: 46, kim: 30, thuy: 24`): `verdant-cycle-scripture` (`["moc"]`).
    - Đới (8 replaced, all `hoa`+`tho`): `reeling-thread-breath` (`["hoa", "tho"]`); head `doi_tam_nuong` keeps `red-sun-scripture` (`["hoa"]`).

---

## 3. Pending Words

None (`pending.json` absent; `0` pending engine words).

---

## 4. Holder Table (after final edits)

### Linters & Integrity (`DEPTH_STAGE=design/stage6-staging/clans`)
- `lint_techniques.py`: `checked 5 techniques, 0 findings` (`locust-shade-breathing` `15.6 W of 16`, `twin-span-pillar-method` `7.8 W of 8`, `returning-swallow-breath` `15.8 W of 16`, `seed-store-method` `8.0 W of 8`, `reeling-thread-breath` `7.6 W of 8`).
- `lint_arts.py`: `checked 6 arts in 1 files, 0 findings`.
- `lint_items.py`: `checked 17 items, 22 bases, 9 common arts, 0 findings` (`17 of 17` unique, R6 `exception` on all `12` weapon/body_gear/ward_gear items).
- `depth_check.py --quiet`: `findings: none` (`1891` people).
- `depth_gap.py --sect clans`: `stand_ins: 0`, `unknown_ids: 0`, `cross_owner: 0`, `ties_unmapped: 0`, `engine_words: 0`, `wishes_open: 0`.
- `stage6_merge.py clans --check`: `0 failure(s)`.

### `sect_fight.py clans --seeds 5` (`--gap 0` and `--gap 1`, `0` `REFUSED`)

| Holder(s) | Realm | Arts (gap 0 fires) | Gap 0 (`mean_s`, `wins`, `hp_left`) | Gap 1 (`mean_s`, `wins`, `hp_left`) | Effects (with vs without, runs: gap 0 / gap 1) |
|---|---|---|---|---|---|
| `tieu_thua_am` | `ket_dan` | `falling-locust-flowers` (12.4), `shade-of-the-road` (10.0) | `64.4 s`, `5/5`, `59%` | `15.6 s`, `0/5`, `0%` (2.6 / 1.6 fires) | `Under the Locust`: 64.4s 59% vs 64.4s 59% (`5` / `5`); `He Waited`: 64.4s 59% vs 64.4s 59% (`354` / `71`) |
| `tieu_thu_dao`, `tieu_thu_tuyen` (2) | `truc_co` | `falling-locust-flowers` (12.0), `shade-of-the-road` (9.8) | `64.6 s`, `5/5`, `42%` | `8.4 s`, `0/5`, `0%` (1.0 / 1.0 fires) | — |
| `ha_thu_dinh`, `tieu_van_canh`, `tieu_thu_tan`, `tieu_uyen_am`, `tieu_minh_khe` (5) | `luyen_khi` | `falling-locust-flowers` (11.8), `shade-of-the-road` (9.4) | `63.8 s`, `5/5`, `43%` | `8.0 s`, `0/5`, `0%` (1.0 / 1.0 fires) | — |
| `on_trong_luong` | `ket_dan` | `mountain-stance` (3.0), `sinking-weight` (2.0), `bastion-reprisal` (1.0), `strata-hammer` (2.0), `mountain-root-stance` (2.0), `bone-turning-palm` (3.0) | `14.2 s`, `5/5`, `100%` | `65.4 s`, `5/5`, `57%` | `The Toll`: 14.2s vs 14.9s (`98`) / 65.4s 57% vs 56.9s 32% (`403`); `Pillar in the Flood`: 14.2s vs 14.2s (`130`) / 65.4s 57% vs 66.0s 37% (`563`) |
| `on_thuc_ha`, `on_the_hoanh`, `on_lap_tru` (3) | `truc_co` | `pillar-in-the-current` (7.0) | `47.5 s`, `0/5`, `0%` | `8.9 s`, `0/5`, `0%` (1.0 fire) | — |
| `lo_hanh_nuong`, `on_thanh_luu`, `on_huu_toan`, `on_bich_de` (4) | `luyen_khi` | `pillar-in-the-current` (6.0) | `40.0 s`, `0/5`, `0%` | `8.3 s`, `0/5`, `0%` (1.0 fire) | — |
| `ta_cuu_duong` | `ket_dan` | `swallows-return` (6.6), `marching-dirge` (4.6), `thorn-lullaby` (2.0), `blood-ink-writ` (5.2) | `14.1 s`, `5/5`, `100%` | `9.6 s`, `0/5`, `0%` | `The Swallow Returns`: 14.1s vs 14.3s (`20`) / 9.6s vs 9.8s (`20`); `The Swallow Returns to Its Nest`: `0` (`NEVER_RAN` by `2/3` split; probe `strike=2` in 1 seed) |
| `ta_tri_xuan`, `ta_tri_thu` (2) | `truc_co` | `swallows-return` (15.0) | `42.5 s`, `5/5`, `20%` | `8.6 s` / `8.0 s`, `0/5`, `0%` (2.4 / 2.0 fires) | — |
| `dieu_nhu_lan`, `van_bich_thu`, `ta_quy_hac`, `ta_quy_nhan`, `ta_quy_hoc` (5) | `luyen_khi` | `swallows-return` (13.4) | `39.4–39.6 s`, `5/5`, `17–18%` | `8.0 s`, `0/5`, `0%` (2.0 fires) | — |
| `luc_thuong_lam` | `ket_dan` | `seed-of-spring` (3.2), `rooted-form` (2.6), `second-spring` (0.2), `harvest-bloom` (2.6) | `18.1 s`, `5/5`, `100%` | `17.2 s`, `0/5`, `0%` | `The Harvest Bell`: `0` (`NEVER_RAN` at 100% HP) / 17.2s vs 16.4s (`25`); `Outlast the Drought`: 18.1s vs 18.1s (`7`) / 17.2s vs 16.0s (`21`) |
| `luc_ke_dien`, `luc_nhi_hoa` (2) | `truc_co` | `opened-granary` (1.0) | `56.2 s`, `0/5`, `0%` | `9.6 s`, `0/5`, `0%` (0.4 fires) | — |
| `luc_mach_thu`, `thieu_xuan_nuong`, `luc_ha_mieu`, `luc_uong_nhi`, `luc_man_thuong` (5) | `luyen_khi` | `opened-granary` (1.0) | `54.0 s`, `0/5`, `0%` | `9.0 s`, `0/5`, `0%` (0.4 fires) | — |
| `ho_te_xuyen` | `ket_dan` | `deep-lake-stance` (5.8), `gathering-wave` (3.0), `brimming-cup` (2.4), `swelling-tide-palm` (4.0), `backwash-seal` (8.4) | `14.5 s`, `5/5`, `100%` | `22.0 s`, `0/5`, `0%` | `Reading the Weather`: 14.5s vs 14.9s (`10`) / 22.0s vs 23.2s (`10`); `Leave With the Tide`: `0` (`NEVER_RAN` at 100% HP) / 22.0s vs 18.0s (`10`) |
| `doi_tam_nuong` | `truc_co` | `brazier-form` (3.0), `flint-volley` (4.6), `furnace-heart` (4.6), `twin-flame-echo` (6.0) | `18.3 s`, `5/5`, `69%` | `8.0 s`, `0/5`, `0%` (`flint-volley` 0.0) | `The Drawn Thread`: 18.3s 69% vs 18.3s 69% (`96` / `20`); `Pulled Tight`: `0` (`NEVER_RAN` without `needle-rain`; probe `rain=1` in 1 seed) |
| `doi_hau_cam`, `long_tang_chi` (2) | `truc_co` | `unbroken-thread` (10.6 / 10.4) | `44.8 s` / `44.4 s`, `0/5`, `0%` | `8.2 s`, `0/5`, `0%` (1.6 fires) | — |
| `doi_thu_kien`, `doi_hoa_tam`, `doi_lang_y`, `doi_so_cuong`, `doi_hong_kien`, `doi_tan_tam` (6) | `luyen_khi` | `unbroken-thread` (8.2) | `35.4 s`, `0/5`, `0%` | `8.0 s`, `0/5`, `0%` (1.4 fires) | — |

CHECKPOINT DONE
