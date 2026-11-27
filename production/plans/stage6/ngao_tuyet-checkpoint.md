# Ngạo Tuyết Phái (`ngao_tuyet`): Stage 6 Checkpoint Review

Unanchored checkpoint review of `design/stage6-staging/ngao_tuyet/` against `design/world/depth/sects/ngao_tuyet.*`, `ngao_tuyet.md`, `production/plans/stage6/_brief-record.md`, `production/plans/stage6/_brief-review.md`, `DECISIONS-2026-11-25.md`, `DECISIONS-2026-11-26.md`, `tools/design/combat_sim/FIGHT-INPUT.md`, `tools/design/combat_sim/engine.py`, `src/gameplay/combat/fight/`, and `src/gameplay/cultivation/cong_phap.gd`.

---

## 1. Ranked Findings

| # | File | Record | What was wrong | Fix applied | Rank |
|---|---|---|---|---|---|
| 1 | `design/stage6-staging/ngao_tuyet/arts/part-sect-ngao_tuyet.json` | `first-petal` (`first-petal-arm`, `first-petal-disarm`, `first-petal-crit`) | `first-petal-arm` and `first-petal-disarm` filtered on `{"art_id": "first-petal"}` while `first-petal-crit` (`on: always`) checked only `own.counter.plum_petal >= 5` (`tags: ["sword"]`) and `first-petal-spend` (`on: crit`, `filter: {"tags": ["sword"]}`) required `own.counter.first_petal_ready >= 1`. Whenever a `first-petal` holder also carried another sword art (all 5 outer disciples carry `phi_kiem`, which grants `plain-sword-cut` `[sword]` via Item DB rule 21 in `FighterCompiler`), reaching `plum_petal == 5` gave `plain-sword-cut` (or `five-petals` sub-hits 2..5) a free `sure_crit: 1` without setting `first_petal_ready = 1`, so `first-petal-spend` never spent the 5 Petals. | Changed `first-petal-arm` and `first-petal-disarm` to `"filter": {"tags": ["sword"]}` and updated `first-petal-crit` `if` to require both `own.counter.first_petal_ready >= 1` and `own.counter.plum_petal >= 5`. Verified in `first-petal + plain-sword-cut` and `first-petal + five-petals` probes (`arms: 9, spends: 9`, exact 1:1 spend). | MUST-FIX |
| 2 | `design/stage6-staging/ngao_tuyet/arts/part-sect-ngao_tuyet.json`, `design/stage6-staging/ngao_tuyet/effects/ngao_tuyet.effects.json` | `bare-winter`, `Bare Branch Blooms` (`has_companion` latch) | `bare-winter-comp-hit`/`evade` and `eff:Bare Branch Blooms comp hit`/`evade` gated on `own.since.flying-sword >= 12` (the exact `12 s` duration of `flying-sword`'s summon). Because `stop_clock` shifts `summons` expiry and next-hit timestamps (`engine.py:2161`, `fight.gd:581`) without shifting `fire_log` timestamps, a clock stop when `flying-sword` does not refire on cooldown can push a `flying-sword` summon hit past `12 s` and falsely latch `has_companion = 1` on a solo fighter. | Raised the threshold from `12` to `15` in `bare-winter` and `Bare Branch Blooms` (plus `Bare Branch Blooms`'s `approx` note), adding a 3 s buffer over `flying-sword`'s 12 s summon while still latching any real beast companion on its opening hits (`t = 1–3 s`, `since.flying-sword == 1e9`). | SHOULD |
| 3 | `design/stage6-staging/ngao_tuyet/arts/part-sect-ngao_tuyet.json` | `last-blossom` (`last-blossom-save`) | Depth text (`ngao_tuyet.techniques.json:40`) writes `"during which her next sword art deals double damage"`, whereas staged `last-blossom-save` uses `mod {dmg_more: 1.0, tags: ["sword"], for: 1.0}` (`"during which your sword arts deal double damage"`). | **No edit** (logged): neither engine has an `art_finished` event to spend a counter after a multi-hit sword art like `five-petals` without either failing to boost `hit()` (`art_fired`) or dropping sub-hits 2..5 (`hit_landed`). `for: 1.0` with `tags: ["sword"]` (no `art_id` filter on `temp_mods`, single `mod` action) is clean and matches the staged `rule` text. | NIT |
| 4 | `design/stage6-staging/ngao_tuyet/techniques/catalogue-sect-ngao_tuyet.json` | `cold-plum-sword-primer`, `plum-through-snow-sword-canon` | Staged `names` narrowed to `["kim"]` while `ngao_tuyet.techniques.json` keeps `["kim", "moc"]`. | **No edit**: matches `ngao_tuyet.md` §§4, 6 (Metal-only gate rule: `kim >= 30` / `>= 45`) and `tung_dao`'s `listening-pine-primer` precedent, allowing all 5 Metal+Earth holders (`truong_luyen_phong`, `hau_thach_nhan`, `an_lanh_phong`, `chung_thiet_tuyen`, `duong_tam_mach`) to pass `CongPhap.usable()` (`cong_phap.gd:43`) and `lint_techniques.py`. | NIT |

---

## 2. Focus Area & Pitfall Audit Summary

- **`last-blossom` (`refuse_down {}` + `stop_clock` + sword `dmg_more`):**
  - Verified `refuse_down: {}` sets `hp = K["refuse_down_health"]` (`1.0`) in both `engine.py:2211` and `fight.gd:1740`.
  - Verified `mod {dmg_more: 1.0, tags: ["sword"], for: 1.0}` uses only `"tags"` (no `"art_id"` or `"status"` filter on `temp_mods`) and has only a single `"mod"` action (no multi-`mod` clobber).
  - Verified `stop_clock {side: "foe", seconds: 1.0}` and `last_blossom_saved = 1` execute in `defeat_check()` before `fire_event(s, "refused", {})`, enabling `eff:Bare Branch Blooms save` (`on: "refused"`, `per_fight: 1`) to add `+5` `plum_petal` cleanly.
- **`plum_petal` (`each_for: 12`) & `first_petal_ready`:**
  - All 4 consumers (`first-petal`, `five-petals`, `One Flower on Iron`, `Bare Branch Blooms`) declare identical `{"id": "plum_petal", "each_for": 12}` definitions.
  - Finding #1 fixed `first-petal` so other sword arts (`plain-sword-cut`, `five-petals`) arm/disarm `first_petal_ready` consistently and never receive free unspent `sure_crit`s.
  - Verified `One Flower on Iron` (`1 <= plum_petal < 5` vs `>= 5`) runs mutually exclusively on `crit [sword]` after `hit_landed` adds `plum_petal`.
- **`has_companion` latch, `The Tiger's Weight`, & `names: ["kim"]` root fit:**
  - Finding #2 raised `own.since.flying-sword` threshold from `12` to `15` in `bare-winter` and `Bare Branch Blooms`; verified solo (`29.82 s`, `20/20`) vs companion (`27.71 s`, `20/20`) on `pho_ngao_suong`.
  - Verified `The Tiger's Weight` (`on: "fight_start"`, `foe.boss == 0` -> `stop_clock {side: "foe", seconds: 1.0}`, `approx`) runs on `trac_thiet_can` (`27.5 s` vs `26.6 s` at gap 0; `15.6 s` vs `14.2 s` at gap 1).
  - Verified `CongPhap.usable()` passes for all 16/16 living members in `ngao_tuyet.cast.json` + `ngao_tuyet.5.cast.json`, including all 5 Metal+Earth disciples.
- **Consolidated b01–b04 checklist:**
  - Standalone Effect compilation (`engine.validate` + local `counters`/`states` check): **3/3 Effects PASS** (`One Flower on Iron`, `The Tiger's Weight`, `Bare Branch Blooms`).
  - Stances: `0` stances defined in `ngao_tuyet` staged files; `iron-hide-stance` is the sole stance on `lang_dap_tuyet` / `trac_thiet_can` / `mac_chiet_chi` / `chung_thiet_tuyen` / `duong_tam_mach` (0 combined stance conflicts).
  - Multi-`mod` clobber / `temp_mods` dropped keys / `always` record-level filter / `timer {which: "next"}` / `was_hit` 0-dmg / `evaded` vs `was_evaded` / `set`+`add` races / `decay_per_pulse: 1` / `slowed_time` `cap: 1`: **0 issues found**.
  - Spatial text (`spatial_words_check.py --sect ngao_tuyet`): 1 `soft` hit (`beside` in `pho_ngao_suong` tie note), **0 `removed` / `postponed` hits**.
  - Global uniqueness against `assets/data/combat_effects.json`, committed `design/`, and all staged `design/stage6-staging/` folders: **0 collisions**.

---

## 3. Decisions on Pending Words

None (`0` pending words; `pending.json` absent).

---

## 4. Holder Table After Fixes

### Post-Edit Linters & Validation (`DEPTH_STAGE=C:\Users\xphuo\IdeaProjects\my-game\design\stage6-staging\ngao_tuyet`)
- `lint_techniques.py`: `checked 3 techniques, 0 findings` (`cold-plum-sword-primer` `7.9 W of 8`, `plum-through-snow-sword-canon` `15.3 W of 16`, `lone-branch-sword` `15.7 W of 16`).
- `lint_arts.py`: `checked 5 arts in 1 files, 0 findings`.
- `lint_items.py`: `checked 3 items, 22 bases, 9 common arts, 0 findings` (`unique 3 of 3`, R6 `exception` on all 3).
- `depth_check.py --quiet`: `findings: none`.
- Standalone Effect `engine.validate`: `STANDALONE_OK 3`.

### `sect_fight.py ngao_tuyet --seeds 5` (`--gap 0` & `--gap 1`) + Targeted Probes (`0 REFUSED`, `0 NEVER_FIRED`)

| Holder / Probe | Realm | Arts | Gap 0 (`mean_s`, `wins`, `hp_left`) | Gap 1 (`mean_s`, `wins`, `hp_left`) | Effects / Art fires |
|---|---|---|---|---|---|
| `lang_dap_tuyet` | `truc_co` | `five-petals`, `flying-sword`, `bloom-in-the-snow`, `bare-winter`, `last-blossom`, `iron-hide-stance` | `14.5 s`, `5/5`, `90%` | `14.2 s`, `0/5`, `0%` | All 6 arts fire (`3.2/1.4/3.2/3.2/2.6/2.0` G0; `2.8/1.0/2.8/2.8/1.6/1.0` G1). `One Flower on Iron`: `34` runs G0, `36` runs G1. `Bare Branch Blooms`: `0` runs G0 (`>50%` HP), `5` runs G1 (`Last Blossom` save). |
| `lang_dap_tuyet` (20-seed 3x HP `truc_co` probe) | `truc_co` | same | `22.01 s`, `20/20`, `88.5%` (without `One Flower`: `23.30 s`, `20/20`, `87.9%`) | — | `One Flower on Iron` reduces mean kill time by `1.29 s`. |
| `lang_dap_tuyet` (20-seed hard `truc_co`: `n_body 2.5, layers [150,110,60,20,0]`) | `truc_co` | same | `25.2 s`, `14/20`, `6.7%` (without `Bare Branch Blooms`: `25.4 s`, `12/20`, `6.4%`) | — | `Bare Branch Blooms` improves wins `12/20 -> 14/20`. |
| `trac_thiet_can` | `truc_co` | `five-petals`, `flying-sword`, `bloom-in-the-snow`, `iron-hide-stance` | `27.5 s`, `5/5`, `100%` | `15.6 s`, `0/5`, `0%` | All 4 arts fire (`7.0/3.2/7.0/4.2` G0; `2.0/1.0/3.2/1.0` G1). `The Tiger's Weight`: `5` runs G0 (`27.5 s` vs `26.6 s`), `5` runs G1 (`15.6 s` vs `14.2 s`). |
| `pho_ngao_suong` | `truc_co` | `five-petals`, `flying-sword`, `bloom-in-the-snow`, `bare-winter`, `last-blossom` | `18.9 s`, `5/5`, `67%` | `10.0 s`, `0/5`, `0%` | All 5 arts fire (`4.8/2.0/4.8/4.8/4.0` G0; `2.0/1.0/2.0/2.0/2.0` G1). 20-seed 2x-HP probe: `29.82 s` solo vs `27.71 s` with `c: 0.5` beast companion. |
| `mac_chiet_chi` | `truc_co` | `five-petals`, `flying-sword`, `bloom-in-the-snow`, `iron-hide-stance` | `26.9 s`, `5/5`, `75%` | `11.2 s`, `0/5`, `0%` | All 4 arts fire (`6.6/3.2/6.4/4.2` G0; `2.0/1.0/2.4/1.0` G1). |
| `chung_thiet_tuyen`, `duong_tam_mach` | `truc_co` | `five-petals`, `flying-sword`, `bloom-in-the-snow`, `iron-hide-stance` | `27.4 s`, `5/5`, `75%` | `11.2 s`, `0/5`, `0%` | All 4 arts fire (`6.8/3.2/6.8/4.2` G0; `2.0/1.0/2.4/1.0` G1). |
| `cung_han_nhan` | `luyen_khi` | `five-petals`, `flying-sword` | `41.6 s`, `3/5`, `7%` | `8.0 s`, `0/5`, `0%` | Both arts fire (`9.0/3.4` G0; `2.0/1.0` G1). |
| `la_thiet_mai`, `ha_tuyet_nhan`, `so_bang_chi` | `luyen_khi` | `five-petals`, `flying-sword` | `40.2 s`, `3/5`, `7%` | `8.0 s`, `0/5`, `0%` | Both arts fire (`8.6/3.4` G0; `2.0/1.0` G1). |
| `an_lanh_phong` | `luyen_khi` | `five-petals`, `flying-sword` | `40.0 s`, `1/5`, `1%` | `8.0 s`, `0/5`, `0%` | Both arts fire (`8.6/3.4` G0; `2.0/1.0` G1). |
| `du_ho_van`, `phi_tam_mai`, `doan_mai_cot`, `truong_luyen_phong`, `hau_thach_nhan` | `luyen_khi` | `first-petal` | `44.6 s`, `2/5`, `5%` | `8.0 s`, `0/5`, `0%` | `first-petal` fires `26.8` G0 / `5.0` G1. |

CHECKPOINT DONE
