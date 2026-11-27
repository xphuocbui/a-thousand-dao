# Vũ Linh Đường (`vu_linh`): Stage 6 checkpoint review (2026-11-27, headless job)

Unanchored review of `design/stage6-staging/vu_linh/`, `design/world/depth/sects/vu_linh.*`, and `production/plans/stage6/vu_linh-review.md`, verified directly against `tools/design/combat_sim/engine.py`, `tools/design/combat_sim/fight.py`, `src/gameplay/combat/fight/effect_compiler.gd`, `src/gameplay/combat/fight/effect_runner.gd`, `src/gameplay/combat/fight/fight.gd`, `src/gameplay/combat/fight/defence_path.gd`, `assets/data/combat_engine.json`, and `assets/data/combat_effects.json`.

- **Findings:** `1` `MUST-FIX`, `1` `SHOULD` (`2` fixed).
- **Pending words:** `0` (no `pending.json`).
- **GDScript standalone parity:** PASS — all 5 Effects in `vu_linh.effects.json` validate standalone (`engine.validate`), declare every counter they read or write in their own `"counters"` array (`Heard Through the Roots`: `canopy_bell`, `roots_warned`; `The Line Is Tuned`: `canopy_bell`, `pour_cd`; `Tuned Bronze`, `Clear Note`, `The Forest Hears`: `[]`), declare zero `"states"` (zero stance collisions), have no `"always"` record with a record-level `filter`, and have no multi-`mod` records without `"stack": true`.
- **Uniqueness:** PASS — 0 ID/name/counter/state collisions across the 4 techniques, 6 arts, 4 items, 1 set, 5 Effect names, 6 counters, and 1 state (`kiln-banked`) against `assets/data/combat_effects.json`, committed `design/`, and all other staged `b03` directories.

---

## 1. Ranked Findings & Fixes Applied

1. **[MUST-FIX — FIXED] `design/stage6-staging/vu_linh/arts/part-sect-vu_linh.json` (`hang-a-bell`):**
   - *What was wrong:* The engine counter definition on `hang-a-bell` (and `the-line-rings`, `Heard Through the Roots`, and `The Line Is Tuned`) set `canopy_bell` upkeep to `{"pool": "qi", "per_stack": 0.003}`, whereas `hang-a-bell`'s `"rule"` (`"...costs 0.6 % of maximum linh lực per second in upkeep"`) and `"notes"` (`"(0.006 qi/s per bell)"`) stated `0.6 %` (`0.006`), contradicting the engine record. Probe check confirmed `0.003` is the intended value: at `0.006`, `an_thanh_linh` burns dry of linh lực at `25.43 s` and loses `--gap 0` vs `typical` (`62.00 s`, `-2.4 %` HP), whereas at `0.003` she holds `8` bells and wins (`45.00 s`, `95.4 %` HP in seed 1; `5/5`, `92 %` across 5 seeds), matching `vu_linh-review.md` and `vu_linh.done`.
   - *Fix applied:* Updated `hang-a-bell`'s `"rule"` (`0.6 %` -> `0.3 %`) and `"notes"` (`0.006` -> `0.003`) in `design/stage6-staging/vu_linh/arts/part-sect-vu_linh.json` to match `"per_stack": 0.003`.

2. **[SHOULD — FIXED] `design/world/depth/sects/vu_linh.items.json` & `design/stage6-staging/vu_linh/items/catalogue-sect-vu_linh.json` (`vl-root-line-banner` `build_use`):**
   - *What was wrong:* `vu_linh.items.json` carried `"build_use": "A warning array in a flag: ..."` (`spatial_words_check.py --sect vu_linh` flagged `removed :: items.build_use :: flag`), and staged `catalogue-sect-vu_linh.json` used `"banner"` (which `spatial_words_check.py` also flags as a `removed` spatial-banner keyword).
   - *Fix applied:* Reworded `build_use` on `vl-root-line-banner` to `"A warning array: sight, evasion and faster Wood arts."` in both `design/world/depth/sects/vu_linh.items.json` and `design/stage6-staging/vu_linh/items/catalogue-sect-vu_linh.json`. `spatial_words_check.py --sect vu_linh` now reports 0 `removed` hits in `vu_linh` (only 1 `soft` commentary phrase `behind it` in `chung_tan_huong`'s `tree.intent`).

---

## 2. Targeted Verification & Open Items

- **`Tuned Bronze` (`listening-bell-seal` L4 passive, `NEVER_RAN` vs `typical`):**
  - Confirmed why it reported `runs 0` against `typical`: `typical` casts no soul art (`soul_pct > 0`) and no `charm`-tagged art (`tags: ["charm"]`).
  - **10-seed soul+charm probe (`an_thanh_linh` vs Kết Đan foe with `soul_pct: 0.06` soul art, `c_art: 1.6` `charm`-tagged art applying `charmed`, and `c_art: 0.0` `charm`-tagged curse art):**
    - *With `Tuned Bronze`*: `10/10` wins, `49.13 s`, `80.5 %` HP left; runs: `eff:Tuned Bronze:soul_ring`: `86`, `eff:Tuned Bronze:charm_stop_ward`: `46`, `eff:Tuned Bronze:charm_stop_evade`: `40`.
    - *Without `Tuned Bronze`*: `10/10` wins, `54.24 s`, `70.3 %` HP left (`+10.2 pp` HP left, `-5.11 s` with `Tuned Bronze`).
  - Verified both `soul_res 15` and `status_resist 20 [status: "charmed"]` (`always` records with `"status": "charmed"` inside `mod`) are supported in both `engine.py` (`_EQ_KEYS` / `apply_status`) and `effect_compiler.gd` / `effect_runner.gd` (`FILTER_KEYS` / `_EQ_KEYS`). Note: non-damaging `charm`-tagged curses (such as `hong_dau`'s `the-second-cup`, `c_art: 0.0`) still meet `status_resist 20 [charmed]`, while `charm_stop_evade` / `charm_stop_ward` trigger on damaging `charm`-tagged arts (`hit()` -> `evaded` / `hit_stopped`), and `soul_ring` triggers on `soul_taken`.
- **`bank-the-kiln-stance` (`charcoal-burners-primer` L1) & stance handling:**
  - Confirmed `bank-the-kiln-stance` is the only stance in `vu_linh` (0 stance collisions), `kiln-banked` carries `tags: ["composed"]`, `kiln-leave-ember` runs before `kiln-toggle` (`state {set: "kiln-banked", toggle: true}`), and `kiln-fire-boost` uses `filter: {"element": "fire", "not_art_id": "bank-the-kiln-stance"}` (`not_art_id` verified in both `engine.py` and `effect_runner.gd`) to apply 1 ms `dmg_more: 0.30` before `hit()` and clear `kiln_ember`.
  - **Trúc Cơ probe (`bank-the-kiln-stance` + `pour-molten-bronze`, seed 1):** `bank-the-kiln-stance` fires `8`, `pour-molten-bronze` fires `13`; `kiln-toggle: 8`, `kiln-leave-ember: 4`, `kiln-fire-boost: 3`.
- **Root fit, layers, & stand-ins:**
  - Verified all 18 living members across `vu_linh.cast.json` and `vu_linh.5.cast.json` (24 technique slots): every member overlaps the slotted technique's `names` with their own root and stays within the technique's max layers (`charcoal-burners-primer` `<= 6`, `canopy-bell-canon` `<= 9`, `molten-bronze-litany` `<= 9`, `listening-bell-seal` `<= 12`). `0` stand-ins needed; `0` beasts.
- **Confirmed open items:**
  1. `cast_ward_duration_pct` (`+15` on `vl-clear-bell`): valid in `lint_techniques.PRICE` and `modifiers.md`, currently has no `CHARACTER_MODS` / `cast_wards` reader in `combat_engine.json` (`depth_gap.py` `lines` 19/20 runs, 1 `rule text`).
  2. Depth `arts_new` rows for passive arts `Heard Through the Roots` and `Tuned Bronze` remain without active art IDs in `vu_linh.techniques.json` because they are staged as `technique.effects` (`thinh_vu` precedent).
  3. R6 `exception` kept on `vl-clear-bell` (`chuong`) and `vl-casters-apron` (`dao_bao`) until authored signature item arts/wards are ruled.
  4. 3 structured events (`N-vu_linh-01..03`) close at Stage 8 export.

---

## 3. Pending Words

None (`pending.json` absent; all 6 active arts and 5 Effects use existing engine words).

---

## 4. Post-Edit Verification Outputs (`DEPTH_STAGE=C:\Users\xphuo\IdeaProjects\my-game\design\stage6-staging\vu_linh`)

- `python -I tools/design/arts/lint_techniques.py design/stage6-staging/vu_linh/techniques/catalogue-sect-vu_linh.json`: `checked 4 techniques, 0 findings` (`8.0 W of 8`, `15.0 W of 16`, `15.8 W of 16`, `23.8 W of 24`).
- `python -I tools/design/arts/lint_arts.py design/stage6-staging/vu_linh/arts/part-sect-vu_linh.json`: `checked 6 arts in 1 files, 0 findings`.
- `python -I tools/design/items/lint_items.py design/stage6-staging/vu_linh/items/catalogue-sect-vu_linh.json`: `checked 4 items, 22 bases, 9 common arts, 0 findings` (`4 of 4` unique).
- `python -I tools/design/world/depth_check.py --quiet`: `findings: none` (`1891` people, `435` builds with Đạo Đồ targets).
- `python -I tools/design/world/depth_gap.py --sect vu_linh`: `stand_ins 0`, `unknown_ids 0`, `cross_owner 0`, `ties_unmapped 0`, `ties_over_cap 0`, `engine_words 0`, `wishes_open 0`, `lines 19/20` (`cast_ward_duration_pct` open).
- `python -I tools/design/world/spatial_words_check.py --sect vu_linh`: `0` `removed`/`postponed` hits in `vu_linh` (`1` `soft` hit `behind it` in `chung_tan_huong.build.tree.intent`).
- `python -I tools/design/combat_sim/put_effects.py design/stage6-staging/vu_linh/effects/vu_linh.effects.json --check`: `combat_effects.json would change` (0 refused).
- `python -I tools/design/combat_sim/sect_fight.py vu_linh --seeds 5` & `--gap 1`: `0 REFUSED` across all 18 living cast members.

---

## 5. Holder Table After Fixes (`sect_fight.py vu_linh --seeds 5`, `--gap 0` / `--gap 1`)

| Holder(s) | Realm | Slotted Arts | `--gap 0` (`mean_s`, `wins`, `hp_left`) | `--gap 1` (`mean_s`, `wins`, `hp_left`) | Effects & Art Fires (`--gap 0` / `--gap 1`) |
|---|---|---|---|---|---|
| `an_thanh_linh` | `ket_dan` | `hang-a-bell,the-line-rings,it-rings-for-you,pour-molten-bronze,hard-as-a-bell` | `45.8 s`, `5/5`, `92%` | `17.5 s`, `0/5`, `0%` | Arts `8.6 / 6.8 / 1.0 / 11.2 / 3.0` (`3.5 / 2.3 / 1.0 / 4.0 / 0.9` gap 1). `Heard Through the Roots`: `45.8s 92%` vs `51.8s 87%` (`5`/`20` runs); `Clear Note`: `45.8s 92%` vs `50.5s 90%` (`58`/`96` runs); `The Forest Hears`: `45.8s 92%` vs `46.8s 90%` (`5`/`20` runs); `The Line Is Tuned`: `45.8s 92%` vs `63.4s 12%` (`135`/`216` runs); `Tuned Bronze`: `0` vs `typical` (verified in 10-seed soul+charm probe: `172` runs, `80.5%` vs `70.3%` HP). |
| `chung_tan_huong` | `ket_dan` | `hang-a-bell,the-line-rings,pour-molten-bronze,hard-as-a-bell` | `51.8 s`, `1/5`, `1%` | `10.1 s`, `0/5`, `0%` | Arts `6.6 / 4.6 / 8.8 / 2.0` (`1.1 / 1.0 / 2.2 / 0.1` gap 1). `Heard Through the Roots`: `51.8s 1%` vs `48.5s 0%` (`5`/`20` runs). |
| `chung_dong_am`, `chung_hong_lo`, `thieu_van_linh` | `truc_co` | `hang-a-bell,the-line-rings,pour-molten-bronze,hard-as-a-bell` | `34.8 s`, `0/5`, `0%` | `8.8 s`, `0/5`, `0%` | Arts `5.0 / 3.4 / 7.0 / 2.0` (`1.0 / 1.0 / 2.0 / 0.0` `NEVER_FIRED` at gap 1: `8.8 s` loss before `9.5 s` cd). `Heard Through the Roots`: `34.8s 0%` vs `35.2s 0%` (`5`/`20` runs). |
| `la_dang_huyen`, `trinh_thu_linh`, `dang_quai_linh` | `truc_co` | `hang-a-bell,the-line-rings` | `35.3 s`, `0/5`, `0%` | `8.6 s`, `0/5`, `0%` | Arts `6.0 / 5.0` (`1.1 / 1.0` gap 1). `Heard Through the Roots`: `35.3s 0%` vs `34.9s 0%` (`5`/`20` runs). |
| `doan_thinh_moc` | `luyen_khi` | `hang-a-bell,the-line-rings` | `33.2 s`, `0/5`, `0%` | `8.3 s`, `0/5`, `0%` | Arts `5.4 / 4.4` (`1.0 / 1.0` gap 1). |
| 9 outer disciples (`giang_phong_lo`, `au_tuong_thu`, `co_thang_nhi`, `phan_linh_sach`, `thang_tieu_hoa`, `hach_chi_dien`, `bach_mien_thanh`, `nguy_tieu_dac`, `canh_tinh_am`) | `luyen_khi` | `bank-the-kiln-stance` | `37.2 s`, `0/5`, `0%` | `8.0 s`, `0/5`, `0%` | `bank-the-kiln-stance` fires `6.8` (`1.0` gap 1). |

CHECKPOINT DONE
