# Stage 6 Checkpoint Review — `vong_trieu` (Vọng Triều Đường)

Unanchored checkpoint review of `design/stage6-staging/vong_trieu/` against `design/world/depth/sects/vong_trieu.{md,techniques.json,items.json,cast.json,5.cast.json}`, Stage 6 rules (`_brief-review.md`, `_brief-record.md`, `DECISIONS-2026-11-25.md`, `DECISIONS-2026-11-26.md`), `tools/design/combat_sim/FIGHT-INPUT.md`, `src/gameplay/cultivation/cong_phap.gd`, `src/gameplay/character/linh_can.gd`, and GDScript combat compilation (`effect_compiler.gd`, `effect_runner.gd`, `build_file_compiler.gd`, `fighter_compiler.gd`, `fight.gd`).

---

## Ranked Findings

1. **[MUST-FIX — FIXED] Unlogged unfaithfulness to depth item/set names, `family`, `made_by`, `made_year`, and `lore`**
   - **Files / Records:** `design/stage6-staging/vong_trieu/items/catalogue-sect-vong_trieu.json` (all 6 items) and `design/stage6-staging/vong_trieu/items/sets-vong_trieu.json` (`vtd-lamp-chain`, `vtd-breakwater`).
   - **What was wrong:** The record pass silently renamed all 6 items and both sets' Hán-Việt titles, flattened `family` to `"general"` on every item, changed `vtd-pearl-diver-robe` `made_by` from `"the weavers of Âu Lộ Thôn"` to `"on_thu_dang"` (`900` → `940`), shifted `made_year` on `vtd-breakwater-seal` (`1160` → `1205`, breaking the 1190 Thạch Cơ jetty story `A312`), `vtd-kim-sa-seal` (`870` → `815`), `vtd-sea-wall-shield` (`1170` → `1208`), and `vtd-jetty-stone` (`1190` → `1209`), and rewrote item `lore` and `build_use` without logging any deviation.
   - **Fix applied:** Restored exact depth `name`, `family` (`soul-song-seal`, `water`, `earth` — all valid in `lint_items.py` `FAMILIES`), `made_by`, `made_year`, `lore`, `build_use`, and set `name` (`Đăng Liên Tam Bảo`, `Phá Lãng Tam Bảo`) from `design/world/depth/sects/vong_trieu.items.json`.

2. **[MUST-FIX — FIXED] `The Lamp That Is Not Out` only relit on `seal == 0` (`was_hit`), missing first seal burnouts when `seal >= 1` and timeout burnouts**
   - **Files / Records:** `design/stage6-staging/vong_trieu/effects/vong_trieu.effects.json` (`The Lamp That Is Not Out`), `design/stage6-staging/vong_trieu/arts/part-sect-vong_trieu.json` (`set-the-lamp`).
   - **What was wrong:** Depth text states *"the first seal of hers to burn out each fight relights once"*. The staged Effect checked `seal_just_emptied >= 1` AND `seal == 0` on `was_hit` only. Because `set-the-lamp` has `charges: 3` and holders routinely stack 2–3 seals, the first seal to burn out (`3 -> 2` or `2 -> 1`) never relit, and timeout burnouts on `pulse` never relit or applied `has_unsleeping_lamp` / `seal_fuse` / `Lamp-Ward` reloads cleanly.
   - **Fix applied:** Added `seal_burned_out` (`cap: 1`) on `set-the-lamp` (set on both `was_hit` pop and `pulse` timeout expiry, cleared on new turn/pulse/gain) and added `eff:The Lamp That Is Not Out relight held` (`seal >= 1` → `seal += 1`) before `relight empty` (`seal == 0` → `seal = 1` + `seal_blows`/`seal_ttl`) on both `was_hit` and `pulse`. Also brought `set-the-lamp-tick-reload` into parity with `was_hit` reloads (`has_unsleeping_lamp` +4 s, `seal_fuse` −1 blow, `Lamp-Ward` FIFO). Verified in `PROBE_UNSLEEPING_HELD` (`relight held: 1`, `unsleeping_used: 1`).

3. **[MUST-FIX — FIXED] `Lamp-Ward` failed to track `+1 + floor(held / 3)` per gained seal across `seal >= 1`**
   - **Files / Records:** `design/stage6-staging/vong_trieu/arts/part-sect-vong_trieu.json` (`set-the-lamp`).
   - **What was wrong:** On `art_fired`, `set-the-lamp-init-ward` only ran when `seal == 0`, and `reload-ward-3`/`reload-ward-6` checked `seal` at reload time (after decrementing `seal`), misattributing `+1` extra blows to earlier seals and dropping them on the final seal gained while holding 3 or 6 seals.
   - **Fix applied:** Added FIFO counters `lamp_ward_t1` and `lamp_ward_t2` banked on `art_fired` (`seal >= 3` and `seal >= 6` when `has_lamp_ward >= 1`, cleared when `seal == 0`) and spent cleanly when `lamp_ward_t1 >= seal` / `lamp_ward_t2 >= seal` on both `was_hit` and `pulse` reloads (`PROBE_LAMP_WARD_FIFO`: `flares=14, t1_pops=2`).

4. **[MUST-FIX — FIXED] `Scale without caps` breaches on `seal_pass_turns`, `tide_layer`, `seal_turned`, `seal_last_turned`, and `seal_blows`**
   - **Files / Records:** `design/stage6-staging/vong_trieu/arts/part-sect-vong_trieu.json` (`set-the-lamp`), `design/stage6-staging/vong_trieu/effects/vong_trieu.effects.json` (`The Lamp Flares`, `The Lamp That Is Not Out`, `Not One Lamp Out`, `Layered Against the Tide`).
   - **What was wrong:** `seal_pass_turns` had `"cap": 20` (capping `Not One Lamp Out`'s `+1 % ward_pct` per passed turn); `tide_layer` had `"cap": 15` (on top of `each_for: 5`) and hardcoded `>= 10` (`+1` `heavy_breath`) instead of scaling per 5 past 5; `seal_turned`, `seal_last_turned`, and `seal_blows` also had `"cap": 20`.
   - **Fix applied:** Removed `"cap"` from `seal_pass_turns`, `tide_layer` (keeping `each_for: 5`), `seal_turned`, `seal_last_turned`, and `seal_blows`; replaced `Layered Against the Tide extra` + `spend` with `base` (`1` `heavy_breath`) + `scale: {"read": "own.counter.tide_layer", "per": 5}` (`1` per 5 layers, uncapped) + `spend` (`tide_layer = 0`).

5. **[MUST-FIX — FIXED] Missing `pending.json` & `CongPhap.usable()` break from `names: ["thuy", "tho"]` lint proxy**
   - **Files / Records:** `design/stage6-staging/vong_trieu/pending.json` (created), `design/stage6-staging/vong_trieu/techniques/catalogue-sect-vong_trieu.json`.
   - **What was wrong:** `vong_trieu` is an R3 no-lean sect whose 3 lineage techniques (`lamp-ward-seal-canon`, `tide-reading-gaze`, `last-lamp-vigil`) carry `names: []` in `vong_trieu.techniques.json`. Because `lint_techniques.py:130` requires `1..3` elements when `tech_kind != "body"`, the record pass left `"names": ["thuy", "tho"]` without logging `lint-element-free-techniques` in `pending.json`. Checking `CongPhap.usable()` (`src/gameplay/cultivation/cong_phap.gd:42-46`) confirms `"names": ["thuy", "tho"]` fails for **5 of 10** living `vong_trieu` holders (`kien_muc_hai`, `tram_chau_nhi`, `ve_lu_sinh`, `dinh_vong_tinh`, `ky_lam_sa`), causing `season_tick()` and `FighterCompiler` to strip/ignore their techniques. Furthermore, `LinhCan.average_purity([])` (`src/gameplay/character/linh_can.gd:368`) returns `0.0`, which causes `CongPhap.tech_one()` and `bonus_lines()` to drop to `crude` / `0.5` unless element-free non-body methods are handled in `CongPhap`.
   - **Fix applied:** Created `design/stage6-staging/vong_trieu/pending.json` logging `lint-element-free-techniques` with `"decision": "build"` (covering `lint_techniques.py`, `CongPhap` `names.is_empty()` handling, `export_techniques.py`, and restoring `names: []` in `catalogue-sect-vong_trieu.json` during `s6-serial-b02`), while keeping `"names": ["thuy", "tho"]` in the staged file for the pre-serial `record` gate.

6. **[SHOULD — FIXED] Arbitrary `limit: {"per_pulse": 2}` cap on `bind-the-flame-cost`**
   - **File / Record:** `design/stage6-staging/vong_trieu/arts/part-sect-vong_trieu.json` (`bind-the-flame`, `bind-the-flame-cost`).
   - **What was wrong:** `limit: {"per_pulse": 2}` capped Wall-mode self-hits against multi-hit arts even though `not_tags: ["trigger"]` already prevents recursion and depth says *"each blow they turn costs you a little health"* (*Scale without caps*).
   - **Fix applied:** Removed `limit: {"per_pulse": 2}` from `bind-the-flame-cost`.

7. **[NIT — KEPT] `line-of-lamps` `kind: "phys"` + `convert: {to: "force", share: 1.0}`**
   - **Assessment:** `c_art: 1.15`, `leaking_ward` `dur: 2` (`charge: 0.60`, `lint: 1.184`) passes `lint_arts.py` cleanly. `fight.py:847` and `build_file_compiler.gd` require `art.kind` in `{"phys", "elem"}` (testing `"kind": "force"` caused `REFUSED` in `sect_fight.py`). Kept `"kind": "phys"` with 100% Force conversion.

8. **[NIT — KEPT] `The Lamp Flares` `outside_budget: true` across base + scale `free_hit`s**
   - **Assessment:** `free_hit` cannot combine constant + scaled `c` in one action, and early rounds before `line-of-lamps` fires have low `direct_dmg` trigger budget. Kept as staged.

---

## Specific Parity, Uniqueness, and Focus Checks

- **GDScript standalone compilation parity:** Every Effect in `design/stage6-staging/vong_trieu/effects/vong_trieu.effects.json` declares in its own `"counters"` every counter it reads or writes (`PARITY_AND_UNIQUENESS_OK: 5 effects`); 0 same-record multi-`mod` clobbering in `temp_mods`; 0 `on: "always"` records with record-level `filter`; 0 `states` or `"stance"` tags across all 6 arts and 5 Effects (preserving `mountain-root-stance` on `chan_dinh_lan`).
- **Effect name uniqueness:** `Lamp-Ward`, `The Lamp Flares`, `The Lamp That Is Not Out`, `Not One Lamp Out`, and `Layered Against the Tide` have **0 collisions** against `assets/data/combat_effects.json` and all 9 other staged `b02` `.effects.json` files.
- **Lineage & art focus verification:**
  - `line-of-lamps`: `c_art: 1.15`, `cost_share: 0.04`, `cooldown: 5.0`, `slowed_time` (3 s) + `leaking_ward` (2 s) → `charge: 0.60`, `lint: 1.184` (`0 findings` in `lint_arts.py`).
  - `Lamp-Ward`, `The Lamp Flares`, `The Lamp That Is Not Out`, `Not One Lamp Out`, `Layered Against the Tide`, and `mountain-root-stance` on `chan_dinh_lan` verified via `sect_fight.py --gap 0` & `--gap 1` and 6 targeted probes (`PROBE_UNSLEEPING_HELD`, `PROBE_LAMP_WARD_FIFO`, `PROBE_FUSE`, `PROBE_STAYS_LIT`, `PROBE_ESCAPE_BURNOUT`, `PROBE_TIDE_LAYER`).

---

## Pending Words (`design/stage6-staging/vong_trieu/pending.json`)

| Word | Kind | Decision | Reason |
|---|---|---|---|
| `lint-element-free-techniques` | `field` | **`build`** | Allow `names: []` in `lint_techniques.py` for element-free `authored` / `catalogue-sect-*` `main`/`secret` methods whose carried arts have `element: ""`, handle `names.is_empty()` cleanly in `CongPhap.tech_one()` / `bonus_lines()` (`avg_purity([]) == 0.0`), and restore `names: []` on `lamp-ward-seal-canon`, `tide-reading-gaze`, `last-lamp-vigil` (preventing `CongPhap.usable()` from rejecting 5/10 living `vong_trieu` holders). |

---

## Post-Fix Verification & Holder Table (`DEPTH_STAGE=C:\Users\xphuo\IdeaProjects\my-game\design\stage6-staging\vong_trieu`)

- `lint_techniques.py design/stage6-staging/vong_trieu/techniques/catalogue-sect-vong_trieu.json`: `checked 3 techniques, 0 findings` (`14.4 W`, `12.7 W`, `15.6 W` of `16`)
- `lint_arts.py design/stage6-staging/vong_trieu/arts/part-sect-vong_trieu.json`: `checked 6 arts in 1 files, 0 findings`
- `lint_items.py design/stage6-staging/vong_trieu/items/catalogue-sect-vong_trieu.json`: `checked 6 items, 22 bases, 9 common arts, 0 findings` (`unique 6 of 6`)
- `depth_check.py --quiet`: `findings: none`
- `depth_gap.py --sect vong_trieu`: `stand_ins 0`, `unknown_ids 0`, `cross_owner 0`, `engine_words 0`, `wishes_open 0`, `lines 29/29 runs` (`events 4` structured)
- `sect_fight.py vong_trieu --seeds 5` (`--gap 0` & `--gap 1`): **0 `REFUSED`**, all 6 active arts fire on real holders.

| Holder | Realm | Arts (`--gap 0` / `--gap 1` fires) | Gap 0 (`mean_s`, wins, HP) | Gap 1 (`mean_s`, wins, HP) | Effects (`with` vs `without`, runs) |
|---|---|---|---|---|---|
| `on_thu_dang` | `ket_dan` | `set-the-lamp` (9.0/9.0), `line-of-lamps` (13.0/4.0), `bind-the-flame` (1.0/1.0), `the-lamp-stays-lit` (1.0/1.0), `read-the-swell` (8.0/2.0), `far-watch` (7.0/2.0) | `60.8 s`, 5/5, `47%` | `20.5 s`, 0/5, `0%` | `Not One Lamp Out`: `60.8s 47%` vs `60.1s 39%` (366 G0 / 111 G1); `Lamp-Ward` & `The Lamp That Is Not Out`: `5` runs (`init`, masked by `Not One Lamp Out` + `Wall`); `The Lamp Flares`: `0` runs on full kit (masked by `Not One Lamp Out` + `Wall`; verified on other holders + `PROBE_FUSE`). |
| `chan_dinh_lan` | `ket_dan` | `set-the-lamp` (10.0/10.0), `line-of-lamps` (5.0/7.0), `mountain-root-stance` (4.0/8.2), `bone-turning-palm` (6.2/5.8), `bind-the-flame` (1.0/1.0), `the-lamp-stays-lit` (1.0/1.0) | `26.0 s`, 5/5, `99%` | `58.8 s`, 2/5, `16%` | `Layered Against the Tide`: G1 **`58.8s 16% (2/5)`** vs **`28.1s 0% (0/5)`** (`223` G0 / `546` G1 runs); `The Lamp Flares`: `15` G0 / `15` G1 (`26.0s` vs `25.3s` G0); `Lamp-Ward`: `5` runs (`26.0s` vs `24.9s` G0); `mountain-root-stance` preserved cleanly. |
| `kien_muc_hai`, `dich_tan_chieu` | `truc_co` | `set-the-lamp` (21.4/3.0), `line-of-lamps` (9.4/1.0), `read-the-swell` (6.8/1.0), `far-watch` (5.8/0.8) | `50.7 s`, 5/5, `60%` | `9.9 s`, 0/5, `0%` | `Lamp-Ward`: `50.7s 60%` vs `54.4s 57%` (`5` G0 / `5` G1); `The Lamp Flares`: `50.7s 60%` vs `58.2s 45%` (`189` G0 / `27` G1). |
| `bang_tran_lang`, `le_bach_diem`, `ve_lu_sinh` | `truc_co` | `set-the-lamp` (24.6/3.4), `line-of-lamps` (10.6/1.0) | `58.2 s`, 5/5, `40%` | `10.1 s`, 0/5, `0%` | `Lamp-Ward`: `58.2s 40%` vs `59.2s 34%` (`5` G0 / `5` G1); `The Lamp Flares`: `58.2s 40%` vs `58.4s 26%` (`237` G0 / `30` G1). |
| `tram_chau_nhi` | `truc_co` | `set-the-lamp` (27.6/3.4), `line-of-lamps` (10.6/1.0) | `58.4 s`, 5/5, `26%` | `10.4 s`, 0/5, `0%` | `Lamp-Ward`: `58.4s 26%` vs `61.1s 7%` (`5` G0 / `5` G1). |
| `dinh_vong_tinh`, `ky_lam_sa` | `luyen_khi` | `set-the-lamp` (27.0/3.0), `line-of-lamps` (6.6/0.4) | `56.4 s`, 3/5, `8%` | `9.1 s`, 0/5, `0%` | Layer-2 `lamp-ward-seal-canon` holders (`set-the-lamp`, `line-of-lamps`). |

CHECKPOINT DONE
