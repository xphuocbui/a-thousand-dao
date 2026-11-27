# Cửu Cao Phái (`cuu_cao`): Stage 6 Checkpoint Review

Unanchored checkpoint review of `design/stage6-staging/cuu_cao/` against `design/world/depth/sects/cuu_cao.*`, `cuu_cao.md`, `production/plans/stage6/_brief-record.md`, `DECISIONS-2026-11-25.md`, `DECISIONS-2026-11-26.md`, and `tools/design/combat_sim/FIGHT-INPUT.md`.

---

## 1. Ranked Findings

1. **SHOULD (open for Stage 7, no edit) — `CongPhap.usable` (`names: ["phong", "moc"]`) vs plateau riders' roots (`cu_van_ly`, `tong_phi_thu`, `banh_da_hang`)**
   - **What was found:** `crane-bond-rite` declares `"names": ["phong", "moc"]` (faithful to `design/world/depth/sects/cuu_cao.techniques.json` line 29 and `cuu_cao.md` §5: Wind + Wood). In `cuu_cao.cast.json` and `cuu_cao.5.cast.json`, `ung_hac_minh` owns both `moc` and `phong`, whereas `cu_van_ly` (`tho, kim, phong`), `tong_phi_thu` (`tho, hoa, phong`), and `banh_da_hang` (`tho, kim, phong`) lack `moc`. `sect_fight.py` does not enforce `CongPhap.usable`, so it ran `crane-bond-rite` for all four riders; however, in Godot `FighterCompiler.gd:141` (`CongPhap.usable(c, e.def)`, `src/gameplay/cultivation/cong_phap.gd:43` / `cong-phap.md` rule 8) requires *every* id in `names` to be present in `c.linh_can`, so at Stage 7 export those three riders would skip `crane-bond-rite` (both arts and passives). (Cross-sect check shows the same pre-existing depth pattern across 25/50 sects, including `bang_tam`.)
   - **Action:** Kept `names: ["phong", "moc"]` unedited to remain faithful to `cuu_cao.md` §5 and `cuu_cao.techniques.json`; logged in `open` for Stage 7 / user ruling (`names: ["phong"]` vs `CongPhap.usable` / root adjustment).

2. **SHOULD (open for Stage 7, no edit) — `cc-green-field-bell` (`kind: "treasure"`) in `export_named.py` / `CastBuilds.make`**
   - **What was found:** `cc-green-field-bell` (`chuong` 4, `kind: "treasure"`, `rarity: 5`, `unique: true`, R6 `exception`) passes `lint_items.py` and `fight.py`/`export_combat_library.py`. However, `tools/design/items/export_named.py:42` filters `if it.get("kind") != "artifact": continue`, so it omits `kind: "treasure"` items from `assets/data/items_named.json`, and `src/gameplay/world/cast_builds.gd:66` (`items.named_artifact(...)`) looks up named gear there.
   - **Action:** Already flagged in `cuu_cao.done` / `cuu_cao-review.md`; retained in `open` so Stage 7 / exporter pass adds treasure handling in `export_named.py` before `export_world.py --sect cuu_cao`.

3. **NIT (informational, no edit) — `A Crane for the Rider` (`crane_spirit` window alongside `gale-sprite`)**
   - **What was found:** Because `summon` in `engine.py` / `effect_runner.gd` does not carry tags, `eff:A Crane for the Rider spirit wind` filters `{"kind": "companion"}` while `crane_bonded == 0` and `crane_spirit >= 1`. In `ung_hac_minh`'s build, `MAX_ARTS = 6` slots her 4 `gale-courier-scripture` arts + 2 `crane-bond-rite` arts ahead of `slow-hour-scripture`, so `gale-sprite` is not slotted. If a future build slots both `crane-descends` and `gale-sprite` with no crane companion, `gale-sprite` hits during the 8 s `crane_spirit` window also trigger `spirit wind` (capped at `per_pulse: 2`). Covered by `approx`; no edit needed.

4. **NIT (informational, no edit) — Technique `effects[0].name` Hán-Việt suffix (`catalogue-sect-cuu_cao.json`)**
   - **What was found:** `cuu_cao.techniques.json` names the passive `"A Crane for the Rider (Hạc Linh)"`, whereas `catalogue-sect-cuu_cao.json` (`crane-bond-rite.effects[0].name`) omits `(Hạc Linh)` and writes `"A Crane for the Rider"`. Both `sect_fight.py` and `BuildFileCompiler.gd` normalize via `.split(" (")[0]`, matching `"A Crane for the Rider"` in `cuu_cao.effects.json` identically.

---

## 2. Specific Audits & Parity Verification

- **`reed-bed` 8-pulse Field timing & `reed_bed` decrement/exit ordering:**
  - `reed-bed` (`marsh-reed-breath` L1) sets `state: "reed-bed"` (`tags: ["field"]`) and `reed_bed = 8` on `art_fired`, gated by `own.field_up < 1`.
  - On `pulse`, `reed-bed-pulse` applies `slowed_time` (`1` stack, `2 s`), `wood` debuff (`1` stack, `6 s`), `heal` (`0.015`), and `counter reed_bed add -1` *before* `reed-bed-exit` checks `own.state.reed-bed >= 1` and `own.counter.reed_bed <= 0` -> `state: {set: null}` (avoiding any `decay_per_pulse: 1` off-by-one).
  - Verified in `mai_lo_tuyet` parity `plog` trace (seed 1): fires at `t = 8000 ms`, pulses 8 times (`t = 9000..16000 ms`), `reed-bed-exit` clears the stance at `t = 16000 ms` during `pulse()`, and `act()` at `t = 16000 ms` immediately passes `own.field_up < 1` and re-enters seamlessly. No groom slots another stance.
- **`crane-descends` & `cry-in-the-nine-marshes` (`timer` / `refresh` / `crane` tag choices):**
  - `crane-descends` (`Wind`, `c_art 1.5`, `cost_share 0.04`, `cd 5.0`, `tags: ["wind", "crane", "quick"]`) applies `off_guard` (`1` stack, `1 s`) on hit and on `art_fired` runs `timer {side: foe, which: next, by: 0.3}` + single `mod {evade: 8, art_speed: 10, for: 4}` (non-spatial mapping of knockback + circling evasion/speed).
  - `cry-in-the-nine-marshes` (`Wind`, `c_art 1.2`, `cost_share 0.04`, `cd 6.0`, `tags: ["wind", "crane"]`, `buff: [1, 6]`) omits `"song"` per `cuu_cao.md` §4 ("The Pivot does not count it as music") and on `art_fired` runs `timer {side: foe, which: next, by: 0.8}` + `refresh {side: own, kind: buff}` (after `art.buff` is added).
- **`A Crane for the Rider` & `Rider and King` (`crane_bonded`, `king_beside`, `crane_spirit`, companion probes):**
  - Both Effects declare all counters they read/write (`crane_bonded` cap 1, `crane_spirit` `each_for: 8`; `king_beside` cap 1) in their own `"counters"` arrays and pass standalone `E.validate()`.
  - `crane_bonded` and `king_beside` latch on `crane`-tagged companion `hit_landed` or `was_evaded` (confirmed in `ung_hac_minh` + `thanh_dien` seed-1 trace: latches at `t = 1000 ms`, ahead of `crane-descends` at `t = 3333 ms`).
  - When `crane_bonded == 0`, `crane-descends` (`cooldown: 20`) summons a `0.5` Force companion (`cd: 1.0`, `for: 8`) and sets `crane_spirit` (`each_for: 8`), granting up to 2 Wind stacks/pulse.
  - `Rider and King` uses defender event `evaded` (`per_pulse: 1`) -> `free_hit {c: 0.6, dtype: "force"}` and `pulse` -> `heal {share: 0.01}` only when `king_beside >= 1`. Verified active in 20-seed probes: `ung_hac_minh + thanh_dien` (`gap=0`: `274` runs, `7.35 s` vs `7.56 s`; `gap=1`: `394` runs, `10.48 s` vs `11.25 s`) and `cu_van_ly + han_vu` (`A Crane for the Rider`: `247` runs `11.92 s 88%` vs `13.56 s 85%` at `gap=0`; `233` runs `10.87 s` vs `11.10 s` at `gap=1`).
- **`The King Answers` (`fire_art` double-cast + `free_hit`, recursion & `per_pulse` guard safety):**
  - `eff:The King Answers ring` (`art_fired`, `tags: ["crane"]`, `per_fight: 1`) fires `free_hit {c: 1.2, dtype: "force"}` and sets `king_answers` (`each_for: 8`). `eff:The King Answers echo` (`art_fired`, `tags: ["crane"]`, `if: own.counter.king_answers >= 1`) executes `fire_art {which: "last", share: 1.0}`.
  - Verified directly in `engine.py:1956` and `effect_runner.gd:636` that `fire_art` calls `hit(...)` directly and never raises `art_fired`, so there is zero infinite recursion risk; non-crane arts are excluded by `filter: {"tags": ["crane"]}`. Verified in 50-seed runs (`ung_hac_minh + thanh_dien` `gap=0`: `7.30 s` vs `8.24 s`; `gap=1`: `10.58 s` survival vs `10.21 s`).
- **`beasts` wiring & stances:**
  - `ung_hac_minh` -> `["thanh_dien"]` (`cuu_cao.beasts.json`), `cu_van_ly` -> `["han_vu"]` (`cuu_cao.2.beasts.json`), `mai_lo_tuyet` -> `["bat_phi"]` (`cuu_cao.2.beasts.json`) all match `cuu_cao.cast.json`.
  - No holder slots two stances (`swallow-stance` is the only stance among riders; `reed-bed` is the only stance among grooms).
- **Standalone parity, multi-`mod`, `temp_mods`, collisions & spatial check:**
  - `3/3` Effects in `cuu_cao.effects.json` pass standalone `E.validate()` with `0` undeclared counters and `0` states.
  - `0` multi-`mod` records without `"stack": true`; `0` `temp_mods` filters using `"art_id"` or `"status"`; `0` `always` records with record-level `filter`; `0` `decay_per_pulse: 1`; `0` `set`+`add` races.
  - `0` ID, Effect-name, or Effect-record-ID collisions against `assets/data/combat_effects.json`, committed `design/`, or all other staged `b04` directories (`binh_thuy`, `coc_vu`, `ham_nguyet`, `lanh_giang`, `thoi_tinh`, `trac_anh`, `van_hac`, `van_khoi`, `vu_an`).
  - `spatial_words_check.py --sect cuu_cao`: `0` `removed`/`postponed` hits (`7` `soft`, `1` `rename` `"stillness"` in `su_man_thanh.build.tree.intent`); staged files have `0` `removed`/`postponed` hits (`2` `rename` `"still"`/`"stand still"` in `marsh-reed-breath` prose).
  - `depth_check.py`: `findings: none`; all 17 living members slot `cuu_cao` / `gale-courier-scripture` / `slow-hour-scripture` methods (`0` stand-ins).

---

## 3. Pending Words

None (`design/stage6-staging/cuu_cao/pending.json` absent; all mechanics expressed with existing engine words).

---

## 4. Holder Table (after review; no edits required)

### Linters (`DEPTH_STAGE=C:\Users\xphuo\IdeaProjects\my-game\design\stage6-staging\cuu_cao`)
- `lint_techniques.py`: `checked 2 techniques, 0 findings` (`marsh-reed-breath` `7.7 W of 8`, `crane-bond-rite` `14.7 W of 16`).
- `lint_arts.py`: `checked 3 arts in 1 files, 0 findings`.
- `lint_items.py`: `checked 3 items, 22 bases, 9 common arts, 0 findings` (`3 of 3` unique, R6 `exception` on all 3).

### `sect_fight.py cuu_cao --seeds 5` (`--gap 0` & `--gap 1`, plus `--people` and 20-seed companion probes; `0` `REFUSED`)

| Holder / Probe | Realm | Arts (gap 0 fires) | Gap 0 (`mean_s`, `wins`, `hp_left`) | Gap 1 (`mean_s`, `wins`, `hp_left`) | Effects (`with` vs `without`, runs) |
|---|---|---|---|---|---|
| `ung_hac_minh` | `ket_dan` | `swallow-stance` (5.2), `hundred-feather-flurry` (3.4), `three-step-chase` (3.2), `held-breath` (7.6), `crane-descends` (3.8), `cry-in-the-nine-marshes` (3.2) | `8.6 s`, `5/5`, `100%` | `10.6 s`, `0/5`, `0%` | `A Crane for the Rider`: `8.6s` vs `8.8s` (`29` / `34`); `The King Answers`: `8.6s` vs `9.0s` (`40` / `34`); `Phantom Dodge`: `8.6s` vs `10.0s` (`56` / `69`); `Rider and King`: `0` (`NEVER_RAN` — no `beasts` loaded before Stage 7) |
| `ung_hac_minh` + `thanh_dien` (20-seed probe) | `ket_dan` | same + `crane` companion (`c 0.5 force cd 1.0`) | `7.35 s`, `20/20`, `100%` | `10.48 s`, `0/20`, `0%` | `A Crane for the Rider`: `7.35s` vs `7.76s` (`161` / `221`); `The King Answers`: `7.35s` vs `8.40s` (`134` / `141`); `Phantom Dodge`: `7.35s` vs `9.22s` (`188` / `270`); `Rider and King`: `7.35s` vs `7.56s` (`274` / `394`) |
| `cu_van_ly` | `truc_co` | `swallow-stance` (5.0), `hundred-feather-flurry` (2.8), `three-step-chase` (4.0), `held-breath` (7.0), `crane-descends` (3.4), `cry-in-the-nine-marshes` (2.6) | `13.1 s`, `5/5`, `85%` | `9.5 s`, `0/5`, `0%` | `A Crane for the Rider`: `13.1s 85%` vs `14.2s 84%` (`40` / `28`) |
| `cu_van_ly` + `han_vu` (20-seed probe) | `truc_co` | same + `crane` companion (`c 0.5 force cd 1.0`) | `11.92 s`, `20/20`, `88%` | `10.87 s`, `0/20`, `0%` | `A Crane for the Rider`: `11.92s 88%` vs `13.56s 85%` (`247` / `233`) |
| `tong_phi_thu` | `truc_co` | `swallow-stance` (4.2), `hundred-feather-flurry` (2.2), `three-step-chase` (3.8), `held-breath` (6.4), `crane-descends` (3.0), `cry-in-the-nine-marshes` (2.2) | `13.2 s`, `5/5`, `82%` | `10.1 s`, `0/5`, `0%` | `A Crane for the Rider`: `13.2s 82%` vs `14.7s 80%` (`40` / `31`) |
| `banh_da_hang` | `truc_co` | `swallow-stance` (4.0), `hundred-feather-flurry` (2.8), `three-step-chase` (5.0), `crane-descends` (3.0), `cry-in-the-nine-marshes` (2.0) | `14.6 s`, `5/5`, `77%` | `10.1 s`, `0/5`, `0%` | `A Crane for the Rider`: `14.6s 77%` vs `16.3s 74%` (`40` / `31`) |
| `mai_lo_tuyet`, `ha_vi_lang` | `truc_co` | `reed-bed` (7.8 / 0.4) | `64.7 s`, `3/5`, `2%` | `8.4 s`, `0/5`, `0%` | — (`mai_lo_tuyet` + `bat_phi` 20-seed probe: `63.30 s`, `20/20`, `59%`) |
| `dong_duoc_huong` | `luyen_khi` | `reed-bed` (7.4 / 0.4) | `63.5 s`, `0/5`, `0%` | `8.0 s`, `0/5`, `0%` | — |
| `lu_thuy_dien` | `luyen_khi` | `reed-bed` (7.2 / 0.4) | `61.6 s`, `1/5`, `1%` | `8.0 s`, `0/5`, `0%` | — |
| `nguy_ha_lo`, `dau_quang_lang`, `su_man_thanh`, `pham_thanh_lo` | `luyen_khi` | `reed-bed` (7.2 / 0.4) | `61.8–62.0 s`, `0/5`, `0%` | `8.0 s`, `0/5`, `0%` | — |
| `ha_tri_han` | `luyen_khi` | `reed-bed` (7.0 / 0.4) | `61.8 s`, `0/5`, `0%` | `8.0 s`, `0/5`, `0%` | — |
| `khong_tuong_vu` (`--people`) | `truc_co` | `swallow-stance` (4.0), `hundred-feather-flurry` (2.6), `three-step-chase` (5.6) | `18.4 s`, `5/5`, `66%` | — | — |
| `mo_cao_yen`, `lo_phi_suong`, `ninh_van_tuoc` (`--people`) | `luyen_khi` | `swallow-stance` (9.4), `hundred-feather-flurry` (5.8) | `43.6 s`, `0/5`, `0%` | — | — |

CHECKPOINT DONE
