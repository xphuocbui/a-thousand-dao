# Stage 6 checkpoint review: Trúc Thực Viên (`truc_thuc`)

Unanchored audit of `design/stage6-staging/truc_thuc/` against `design/world/depth/sects/truc_thuc.*` (`md`, `techniques.json`, `items.json`, `cast.json`, `5.cast.json`), `design/arts/family-wood.json`, `design/arts/part-b.json`, `design/techniques/catalogue-wood.json`, `assets/data/combat_engine.json`, `assets/data/combat_effects.json`, Stage 6 rules (`_brief-record.md`, `_brief-review.md`, `DECISIONS-2026-11-25.md`, `DECISIONS-2026-11-26.md`, `FIGHT-INPUT.md`), and both combat engines (`tools/design/combat_sim/{engine,fight,sect_fight}.py` and `src/gameplay/combat/fight/{effect_compiler,effect_runner,build_file_compiler,fighter_profile_loader,defence_path,fight}.gd`).

## Ranked findings (3 SHOULD applied, 0 MUST-FIX, 2 NITs noted)

| # | Severity | File | Record / ID | What was wrong | Fix applied |
|---|---|---|---|---|---|
| 1 | **SHOULD** | `design/stage6-staging/truc_thuc/arts/part-sect-truc_thuc.json` | `open-the-sluice` (`sluice-open`) | `sluice-open` (`on: "art_fired"`, which runs in `act()` *after* `pulse()`) added `3` to `flood_sec` with `decay_per_pulse: 1`. Because `decay_per_pulse` decrements counters *before* `fire_event("pulse")`, the first pulse lost 1 full second (`5932 ms -> 6000 ms` decayed `3 -> 2`, ending at `8000 ms` = `2.07 s` and only 2 pulses of `sluice-slow` and `The Flood Feeds the Garden` without `Measured Flood`, or 5 pulses with it). | Set `"add": 4` on `sluice-open` and clarified `rule` (`4 initial flood_sec -> 3 full pulses after first pulse-start decay; +3 from Measured Flood -> 6 pulses`). Verified `The Flood Feeds the Garden` runs rose from `48 -> 53` (`gap 0`) and `55 -> 60` (`gap 1`), and `open-the-sluice` fires `1.8×` / `1.6×` at `gap 1` on `dao_luong_khe` / `man_tiet_thanh`. |
| 2 | **SHOULD** | `design/world/depth/sects/truc_thuc.items.json` | `ttv-seed-warming-censer` / `Warm the Grove` | `spatial_words_check.py` still flagged `"allies, ally"` in `Warm the Grove`'s `rule` and `"ally"` in `build_use`, whereas `truc_thuc.effects.json` and `catalogue-sect-truc_thuc.json` already used the `DECISIONS-2026-11-26.md` 1v1 `"you"` wording. | Minimal 2-line edit replacing `"allies"` / `"ally"` with `"you"` and `"himself"` to match the staged Effect and item catalogue. |
| 3 | **SHOULD** | `design/stage6-staging/truc_thuc/arts/part-sect-truc_thuc.json` | `the-flowering` (`states[0].suppress`) | `flowered` state's `suppress` list covered the 8 `family-wood.json` arts and 3 `part-sect-truc_thuc.json` Wood arts, omitting the 13 common-pool Wood arts in `design/arts/part-b.json`, even though the rule states it suppresses lineage and Wood catalogue arts. | Added all 13 `part-b.json` Wood art IDs (`rot-seed`, `slow-rot`, `vine-lash`, `spring-sap`, `weeping-sap`, `venom-tithe`, `banyan-shade`, `green-poultice`, `shedding-bark`, `withering-touch`, `venom-drinking-root`, `heartwood-spear`, `bark-mantle`) to `suppress`. |
| 4 | **NIT** | `design/world/depth/sects/truc_thuc.techniques.json` | `furrow-iron-breath` (`concept`) | `spatial_words_check.py` flags `"rooted"` in `"Metal- and Earth-rooted hands"`; this refers to linh căn (spiritual roots), not the spatial `Rooted` status. | Left untouched (false positive). |
| 5 | **NIT** | `design/world/depth/sects/truc_thuc.cast.json` | `ninh_truc_thuc` (`aux`) | Pre-existing depth build gives Ninh (`moc: 80, hoa: 54`, no `thuy`) `aux: [{"tech": "flooded-field-verse", "layer": 6}]` (`names: ["thuy"]`), which flags under strict `CongPhap.usable` (his 6-slot fight loadout in `sect_fight.py` only slots `verdant-cycle-scripture` and `sixty-year-flower` arts). | Left untouched (pre-existing depth cast build); logged in `open`. |

---

## Checked & verified

### 1. GDScript compilation parity & Effect name uniqueness
- **Uniqueness:** `set(truc_thuc.effects) & set(combat_effects.json)` = `set()`, and 0 collisions against all 8 other staged `design/stage6-staging/*/effects/*.effects.json` files.
- **Standalone Effect & Art compilation parity (`effect_compiler.gd` / `fighter_profile_loader.gd`):**
  - Every Effect in `truc_thuc.effects.json` declares every counter it reads or writes in its own `"counters"` (`Warm the Grove`: `[]`; `Measured Flood`: `flood_sec`, `flood_was_up`; `Forced to Seed`: `no_fire_sec`; `The Flood Feeds the Garden`: `flood_sec`, `flood_fed_up`).
  - Every art in `part-sect-truc_thuc.json` declares every counter it reads or writes locally (`shoot-after-rain`: `rain_fed`; `open-the-sluice`: `flood_sec`; `paddy-mud`: `flood_sec`; `store-the-culm`: `culm_storing`, `bloom`, `flowered`; `the-flowering`: `bloom`, `flowered`) and declares every state it sets (`the-flowering`: `flowered`).
  - Stance safety: `open-the-sluice` and `store-the-culm` use self-counters so neither clobbers `verdant-cycle-scripture`'s `rooted-form` (`own.state.rooted == 1`). `the-flowering` intentionally enters `flowered` (`suppress`ing Wood arts, including `rooted-form`).
  - Zero `always` records carry a record-level `filter` (scopes live inside `mod`), zero counters are armed and spent on the same hit, and `GDScript parity errors: []`.

### 2. Specific focus investigations
- **Why `second-spring` showed `NEVER_FIRED` on `ninh_truc_thuc` at `--gap 0`:**
  - `second-spring` (`design/arts/family-wood.json`) has `"cooldown": 8` and `"guards": [{"read": "own.hp_share", "op": "<=", "value": 0.95}]`.
  - Across `--seeds 5` at `--gap 0`, Ninh's sustain (`Warm the Grove`, censer/bell/ring/2pc regen & healing, `rooted-form`, `the-flowering`, `Forced to Seed`) keeps his HP between `97.9 %` and `100 %` (`0.979` lowest pulse on seed 1), never reaching `<= 0.95`.
  - Over `--seeds 20` at `--gap 0`, `second-spring` fires `0.1` times/fight (`18.9 s`, `20/20` wins, `99 %` HP); at `--gap 1`, where enemy hits push him below `0.95`, it fires `1.0` time/fight (`5` seeds; `0.9`/fight over `20` seeds, e.g., `8654 ms` on seed 1).
  - Similarly, `dao_luong_khe` and `man_tiet_thanh` fire `second-spring` `1.0` time/fight at `--gap 0`, while at `--gap 1` they either remain above `0.95` at `t = 8 s` (`1.0` HP) or run below `second-spring`'s `0.05` linh lực cost before dying at `~13–14 s`.
- **Verification of all 4 Effects (`Warm the Grove`, `Measured Flood`, `Forced to Seed`, `The Flood Feeds the Garden`):**
  - `Warm the Grove` (`ttv-seed-warming-censer`): attaches via `items`, runs `30` times over 5 seeds (`gap 0` and `gap 1`), shifts `ninh_truc_thuc` at `gap 0` from `21.4 s` (`98 %` HP) without to `19.2 s` (`99 %` HP) with (`-2.2 s`; `18.9 s` vs `19.8 s` over 20 seeds).
  - `Forced to Seed` (`ttv-yearly-seed` 3pc): attaches via `sets-truc_thuc.json` (`"Forced to Seed (Cưỡng Kết)"`), runs `110` times (`gap 0`) / `90` times (`gap 1`). Without a Fire art on Ninh, its canonical 10 s flowering trade-off consumes Wood buff stacks for 3 % HP/stack (`19.2 s` vs `17.6 s` at `gap 0`; `16.0 s` vs `17.6 s` at `gap 1`), while the Fire-art probe reported in `truc_thuc-review.md` exercises the Fire-refresh branch (`14.7 s`).
  - `Measured Flood` (`ttv-rain-measure-gourd`): attaches via `items`, runs `15` times (`gap 0` and `gap 1`). At `gap 0` (`15.9 s` vs `15.7 s`, `100 %` HP), `uy_thuong_dien` already over-sustains; at `gap 1` (`17.6 s` vs `23.3 s`), extending `flood_sec` delays the second `The Flood Feeds the Garden` heal past `17.6 s` (`19 s`) whereas without it the heal lands at `16.0 s`. Under a harder same-realm Kết Đan pressure probe (`layers [180, 120, 80, 40, 20]`, 10 seeds), `Measured Flood` lifts wins from `9/10` (`20.4 s`, `paddy-mud` empowers `1.0/fight`) to `10/10` (`18.9 s`, `paddy-mud` empowers `2.6/fight`).
  - `The Flood Feeds the Garden` (`ttv-rain-record` 3pc): attaches via `sets-truc_thuc.json` (`"The Flood Feeds the Garden (Thủy Dưỡng Điền)"`), runs `53` times (`gap 0`) / `60` times (`gap 1`) after the `add: 4` fix. Because `uy_thuong_dien` sits at `100 %` HP at `t = 11 s` (`gap 0` & `gap 1`) and falls at `17.6 s` before the 2nd flood ends (`gap 1`), `sect_fight` shows `15.9 s` vs `16.0 s` (`gap 0`) and `17.6 s` vs `17.6 s` (`gap 1`); under the harder Kết Đan pressure probe (`10` seeds), removing `The Flood Feeds the Garden` drops HP left from `90.7 %` to `84.3 %` (`-6.4 pp`).

### 3. Techniques, items, sets, and stand-ins
- **Techniques (`catalogue-sect-truc_thuc.json`):** `rain-on-bamboo-breath` (`7.8 W / 8`), `flooded-field-verse` (`15.9 W / 16`), `sixty-year-flower` (`23.5 W / 24`), `furrow-iron-breath` (`7.8 W / 8`). `lint_techniques.py`: `0 findings`.
- **Items & sets (`catalogue-sect-truc_thuc.json`, `sets-truc_thuc.json`):** All 28 item modifier lines match `truc_thuc.items.json` verbatim (`unique: true`, `sources: ["npc"]`, `rarity: 4` on grade-3 treasure `ttv-seed-warming-censer`, R6 `exception` on the 4 weapons/wards/armour). `lint_items.py`: `0 findings`.
- **Stand-ins (`truc_thuc.cast.json`, `truc_thuc.5.cast.json`):** `phi_dong_canh` (`kim 44, tho 32`) and `ngo_le_thach` (`kim 46, tho 30`) both use `furrow-iron-breath` (fitting their `["kim", "tho"]` roots and servant ploughman roles). `depth_gap.py`: `stand_ins: 0`, `cross_owner: 0`.

---

## Pending word decisions

None (`0` pending words; no `pending.json` in `design/stage6-staging/truc_thuc/`).

---

## Linters & Holder table after fixes

### Linters & structural checks (`DEPTH_STAGE=C:\Users\xphuo\IdeaProjects\my-game\design\stage6-staging\truc_thuc`)
- `lint_techniques.py`: `checked 4 techniques, 0 findings`
- `lint_arts.py`: `checked 7 arts in 1 files, 0 findings`
- `lint_items.py`: `checked 6 items, 22 bases, 9 common arts, 0 findings` (`unique 6 of 6`)
- `depth_check.py --quiet`: `findings: none`
- `depth_gap.py --sect truc_thuc`: `stand_ins: 0, unknown_ids: 0, cross_owner: 0, ties_unmapped: 0, ties_over_cap: 0, engine_words: 0, wishes_open: 0, lines: 28/28 runs`
- `spatial_words_check.py`: 0 real hits in `truc_thuc` (1 false positive on linh căn `"rooted"` in `furrow-iron-breath`)
- `sect_fight.py truc_thuc --seeds 5` (`--gap 0` and `--gap 1`): **0 REFUSED** across all 18 living holders

### Holder table (`sect_fight.py truc_thuc --seeds 5`, post-fix)

| Holder | Realm | `gap 0` (`mean_s`, wins, HP) | `gap 1` (`mean_s`, wins, HP) | Arts & Effects (`with` vs `without`, `runs`) |
|---|---|---|---|---|
| `ninh_truc_thuc` | Kết Đan 1 | `19.2 s`, `5/5`, `99 %` | `16.0 s`, `0/5`, `0 %` | `store-the-culm` `2.0`/`2.0`, `the-flowering` `1.0`/`0.4`, `second-spring` `0.0` (`gap 0`; `0.1`/20 seeds)/`1.0` (`gap 1`). **Warm the Grove**: `19.2 s 99%` vs `21.4 s 98%` (`30` runs) / `16.0 s` vs `16.0 s` (`30` runs). **Forced to Seed**: `19.2 s 99%` vs `17.6 s 99%` (`110` runs) / `16.0 s` vs `17.6 s` (`90` runs). |
| `uy_thuong_dien` | Kết Đan 0 | `15.9 s`, `5/5`, `100 %` | `17.6 s`, `0/5`, `0 %` | `open-the-sluice` `2.0`/`2.0`, `paddy-mud` `3.0`/`3.0`, `second-spring` `0.4`/`0.8`. **Measured Flood**: `15.9 s 100%` vs `15.7 s 100%` (`15` runs) / `17.6 s` vs `23.3 s` (`15` runs). **The Flood Feeds the Garden**: `15.9 s 100%` vs `16.0 s 100%` (`53` runs) / `17.6 s` vs `17.6 s` (`60` runs). |
| `man_tiet_thanh` | Trúc Cơ 2 | `15.2 s`, `5/5`, `100 %` | `13.0 s`, `0/5`, `0 %` | `open-the-sluice` `2.0`/`1.6`, `paddy-mud` `3.0`/`1.0`, `second-spring` `1.0`/`0.0` |
| `dao_luong_khe` | Trúc Cơ 1 | `19.4 s`, `5/5`, `100 %` | `14.3 s`, `0/5`, `0 %` | `open-the-sluice` `2.0`/`1.8`, `paddy-mud` `3.8`/`1.0`, `second-spring` `1.0`/`0.0` |
| `khuat_liep_nguyen` | Trúc Cơ 1 | — | — | `verdant-cycle-scripture` only (no staged `truc_thuc` art or named item; excluded from `sect_fight` authored-holder filter) |
| `sam_dao_huong`, `kha_tung_canh`, `chiem_da_tuan`, `an_coc_vu`, `ung_so_hoa` | Trúc Cơ / Luyện Khí | — | — | `verdant-cycle-scripture` only (no staged `truc_thuc` art or named item) |
| `tan_tieu_duan`, `ly_bich_ba`, `yen_mach_nhi`, `pho_tong_thuc`, `dieu_lang_nhi`, `chu_thu_dien` | Luyện Khí | `59.3 s`, `5/5`, `54–55 %` | `8.0 s`, `0/5`, `0 %` | `shoot-after-rain` `18.0`/`2.0`, `bend-not-break` `10.6`/`1.0` |
| `phi_dong_canh`, `ngo_le_thach` | Luyện Khí | `46.2 s`, `2/5`, `1 %` | `8.0 s`, `0/5`, `0 %` | `turn-the-furrow` `14.0`/`2.0` |

CHECKPOINT DONE
