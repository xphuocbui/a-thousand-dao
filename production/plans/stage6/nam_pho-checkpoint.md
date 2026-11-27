# Stage 6 checkpoint review: Nam Phố Đường (`nam_pho`)

Fresh, unanchored audit of `design/stage6-staging/nam_pho/` against `design/world/depth/sects/nam_pho.*`, Stage 6 rules and rulings (`_brief-record.md`, `_brief-review.md`, `DECISIONS-2026-11-25.md`, `DECISIONS-2026-11-26.md`, `FIGHT-INPUT.md`), the Băng Tâm reference (`design/arts/part-sect-bang_tam.json`, `design/world/depth/effects/bang_tam.effects.json`), and both combat engines (`tools/design/combat_sim/engine.py`, `fight.py`, `sect_fight.py`, and `src/gameplay/combat/fight/{effect_compiler,effect_runner,fighter_profile_loader,fight}.gd`).

## What this review read and verified
- All 6 staged files in `design/stage6-staging/nam_pho/`: `techniques/catalogue-sect-nam_pho.json` (3 techniques), `arts/part-sect-nam_pho.json` (7 arts), `items/catalogue-sect-nam_pho.json` (6 items), `items/sets-nam_pho.json` (2 sets), `effects/nam_pho.effects.json` (3 Effects), `pending.json` (empty: `{"words": [], "arts": [], "effects": {}}`).
- Source-of-truth depth files: `design/world/depth/sects/nam_pho.md`, `nam_pho.techniques.json`, `nam_pho.items.json`, `nam_pho.cast.json`, and `nam_pho.5.cast.json` (all 18 living and 2 dead cast rows).
- Record-pass account (`production/plans/stage6/nam_pho-review.md`, `nam_pho.done`, `nam_pho.md`) verified independently against source files and engine execution.
- GDScript standalone compilation parity verified against `EffectCompiler.compile()` and `FighterProfileLoader`:
  - Every Effect (`Dawn Ink`, `Paper Laid at Dawn`, `Roll Up the Western Rain`) and every staged art (`part-sect-nam_pho.json`) declares in its own `"counters"` every counter it reads or writes (`0` errors, `0` undeclared counters).
  - Zero non-`always` `"mod"` actions across `nam_pho.effects.json` and `part-sect-nam_pho.json`, so zero same-record `temp_mods` multi-`mod` clobbering.
  - Every stance set (`morning-cloud` on `catch-the-morning-cloud`, `dawn-flight` on `dawn-flight`) is declared in its own `"states"`, guarded on `own.state.any == 0`, and cleared only when its own stance holds (`own.state.<id> >= 1`), so neither clobbers `marching-dirge`'s `"march"` stance on shared holders (`chau_phi_van`, `kha_trieu_phi`, `ninh_hoa_van`, `doanh_mo_vu`, `doi_huyen_nghien`, `ung_trieu_hong`).
- Effect name uniqueness verified: `Dawn Ink`, `Paper Laid at Dawn`, and `Roll Up the Western Rain` are absent from `assets/data/combat_effects.json` (258 entries) and unique across all 10 staged `b02` Effects files.
- Item/set fidelity verified field-by-field against `nam_pho.items.json`: all 6 items (24 modifier lines, `unique: true`, `sources: ["npc"]`, R6 `exception` on the 5 weapon/robe pieces) and both sets (`np-dawn-half`, `np-dusk-half`) match 100%; all cast holders carry every element in their slotted techniques' `names`.

---

## Ranked findings (3 applied: 1 MUST-FIX, 2 SHOULD)

| # | Severity | File | Record / ID | What was wrong | Fix applied |
|---|---|---|---|---|---|
| 1 | **MUST-FIX** | `design/stage6-staging/nam_pho/arts/part-sect-nam_pho.json` | `catch-the-morning-cloud` (`morning_cloud`), `dawn-flight` (`dawn_flight`) | Both Field cloud talismans set their counter to `10` on `art_fired` while defining `"decay_per_pulse": 1` on the counter. Because `act()` runs after `pulse()`, and `decay_per_pulse` decrements counters *before* `fire_event("pulse")` (`engine.py:976` / `fight.gd:496`), each cast lost its 10th pulse (only 9 ticks of Wood stacks + healing / Slowed Time instead of 10), and `guards` (`<= 1`) allowed recasting after 9 pulses instead of 10. | Removed `"decay_per_pulse": 1` from `morning_cloud` and `dawn_flight`; appended `{"counter": {"id": "morning_cloud", "add": -1}}` / `{"counter": {"id": "dawn_flight", "add": -1}}` to `morning-cloud-pulse` / `dawn-flight-pulse` (before `*-end` in `effects`); tightened `guards` on both arts from `<= 1` to `<= 0`. Verified exact 10 pulses per cast on standalone `catch-the-morning-cloud` (`42` pulses across 4 full cycles + 2) and `dawn-flight` (`52` pulses across 5 full cycles + 2). |
| 2 | **SHOULD** | `design/stage6-staging/nam_pho/effects/nam_pho.effects.json` | `Paper Laid at Dawn` (`eff:Paper Laid at Dawn tick`) | `eff:Paper Laid at Dawn tick` added a flat `1` to `dawn_unspent_s` whenever `laid_talisman >= 1`, ignoring how many talismans were laid (depth text: *"each one grows once for every 10 s it stays unspent"*). With `painted-rain` clearing `laid_talisman` every ~3.5 s on `chau_phi_van`, `dawn_unspent_s` never reached 10 in `sect_fight.py` at either `--gap 0` or `--gap 1`. | Added `"scale": {"read": "own.counter.laid_talisman", "per": 1}` to `eff:Paper Laid at Dawn tick` and updated `approx`. In an unspent-hold probe (`chau_phi_van` slotting `catch-the-morning-cloud`, `paper-beam`, `dawn-flight`, `dusk-curtain`, `marching-dirge`, `thorn-lullaby` at `--gap 1`), all 4 records fire (`tick: 41`, `ripen: 5`, `stacks: 10`, `fire: 14`, `19.38 s` vs `15.69 s`). |
| 3 | **SHOULD** | `design/stage6-staging/nam_pho/effects/nam_pho.effects.json` | `Roll Up the Western Rain` | `eff:Roll Up the Western Rain cleanse` listens on `"cleansed"` with no `"approx"` note on the Effect explaining that the engine's `cleansed` event carries only `{"amount": removed}` (no `element` field), so any debuff cleansed by the foe triggers it. | Added `"approx"` field to `Roll Up the Western Rain` documenting the `cleansed` event limitation (`D9`). |

---

## Checked & kept (no change needed)
- **Techniques (`catalogue-sect-nam_pho.json`, 3 techniques):** `mulberry-ink-primer` (`8.0/8 W`), `southern-shore-cloud-canon` (`15.9/16 W`), `painted-beams-dawn-flight` (`23.9/24 W`). All `auth-mod.json` `b4` passives preserved; new tier-sized bonuses and passives match `bang_tam` peers. `lint_techniques.py`: 0 findings.
- **Stand-ins & beasts:** 0 stand-ins needed (`0` in `depth_gap.py`), 0 beasts.
- **Effect behaviour verification (`Dawn Ink`, `Paper Laid at Dawn`, `Roll Up the Western Rain`):**
  - **`Dawn Ink` (`chau_phi_van`):** At `--gap 0` default slotting (`arts[:6]` = `southern-shore-cloud-canon` + `thorn-and-ink-verses`), `catch-the-morning-cloud` lays 5 s Wood batches extended by `stack_duration_pct 16` + `Dawn Ink 50` to `8.7 s`; the earliest batch (`t = 3.0 s`) expires at the `12.0 s` pulse, after `chau_phi_van` wins in `11.1 s` (`runs 0` at `--gap 0`). At `--gap 1`, `Dawn Ink` fires **`19` times** (`14.8 s` vs `13.4 s`, `+1.4 s` survival). With `dawn-flight` + `dusk-curtain` slotted (replacing `thorn-lullaby` + `blood-ink-writ`), `Dawn Ink` fires **`62` times** at `--gap 0` (`20.75 s` vs `21.46 s`, faster kill via sustained qi) and **`58` times** at `--gap 1` (`19.73 s` vs `17.65 s`).
  - **`Paper Laid at Dawn` (`chau_phi_van`):** At `--gap 0` (`11.1 s 100%`), `chau_phi_van` has `0.81` qi left with or without `Paper Laid at Dawn` (`11.1 s` vs `11.1 s`). At `--gap 1`, `cost_red: 0.95` extends survival by **`+3.4 s`** (`14.8 s` vs `11.4 s`, `33` runs of `tick`). In the unspent-hold probe without `painted-rain` (`--gap 1`), `dawn_growth` ripens 5 times (`tick: 41`, `ripen: 5`, `stacks: 10`, `fire: 14`, `19.38 s` vs `15.69 s`).
  - **`Roll Up the Western Rain` (`kha_trieu_phi`):** At `--gap 0`, it fires **`66` times** across 5 seeds (`batch_ended` + `broken`), with **`21.9 s 100%` vs `21.9 s 100%`** because `kha_trieu_phi` is already at `100.0%` HP from `t = 12.0 s` through win at `21.9 s` (from `catch-the-morning-cloud` + `paper-beam` + `dusk-curtain`) and the typical foe applies zero debuffs, so all 66 heals overheal into full HP. At `--gap 1`, `kha_trieu_phi` takes real HP damage: `Roll Up the Western Rain` runs **`14` times**, heals `+215` to `+430` HP per fight on seeds 2–5 (`2,677–2,876` vs `2,247–2,446`), and shifts mean survival to **`12.9 s` vs `12.8 s`** (`0/5` wins against the Nguyên Anh typical foe).

---

## Pending word decisions (`design/stage6-staging/nam_pho/pending.json`)

`design/stage6-staging/nam_pho/pending.json` is empty (`{"words": [], "arts": [], "effects": {}}`). **0 pending words**; all Nam Phố mechanics run on existing engine primitives.

---

## Linters & Holder table after fixes

### Linters & checks (`$env:DEPTH_STAGE = C:\Users\xphuo\IdeaProjects\my-game\design\stage6-staging\nam_pho`)
- `lint_arts.py`: `checked 7 arts in 1 files, 0 findings`
- `lint_techniques.py`: `checked 3 techniques, 0 findings` (`8.0 W of 8`, `15.9 W of 16`, `23.9 W of 24`)
- `lint_items.py`: `checked 6 items, 22 bases, 9 common arts, 0 findings` (`unique 6 of 6`)
- `depth_check.py --quiet`: `findings: none`
- `depth_gap.py --sect nam_pho`: `stand_ins: 0`, `unknown_ids: 0`, `ties_unmapped: 0`, `ties_over_cap: 0` open (`1` game-capped), `engine_words: 0`, `wishes_open: 0`, `lines: 34/34 runs`, `cross_owner: 3` (closes at Stage 7 merge)
- `sect_fight.py nam_pho --seeds 5` (`--gap 0` and `--gap 1`): **0 REFUSED**, **0 NEVER_FIRED**.

### Holder table after fixes (`sect_fight.py nam_pho --seeds 5`)

| Holder | Realm | `--gap 0` (mean_s, wins, hp) | `--gap 1` (mean_s, wins, hp) | Arts fired (`--gap 0` / `--gap 1`) | Effects (`with / without`, runs) |
|---|---|---|---|---|---|
| `chau_phi_van` | Kết Đan | `11.1 s, 5/5, 100 %` | `14.8 s, 0/5, 0 %` | `catch-the-morning-cloud` 1.0/2.0, `painted-rain` 2.8/3.8, `paper-beam` 2.0/2.8, `marching-dirge` 3.6/4.8, `thorn-lullaby` 1.0/1.6, `blood-ink-writ` 5.6/7.0 | `Dawn Ink`: `--gap 0` `11.1/11.1 s` (`0` runs: `11.1 s` kill < `12.0 s` expiry pulse; `--gap 1` **`14.8/13.4 s`**, `19` runs); `Paper Laid at Dawn`: `--gap 0` `11.1/11.1 s` (`29` runs), `--gap 1` **`14.8/11.4 s`** (`33` runs) |
| `kha_trieu_phi` | Kết Đan | `21.9 s, 5/5, 100 %` | `12.9 s, 0/5, 0 %` | `catch-the-morning-cloud` 2.2/1.6, `painted-rain` 5.0/2.0, `paper-beam` 5.0/2.0, `dawn-flight` 2.2/1.0, `dusk-curtain` 4.0/1.0, `marching-dirge` 7.6/3.8 | `Roll Up the Western Rain`: `--gap 0` `21.9/21.9 s` (`66` runs, overheals at 100 % HP), `--gap 1` **`12.9/12.8 s`** (`14` runs, `+215..+430` HP healed on seeds 2–5) |
| `ninh_hoa_van`, `doi_huyen_nghien` | Trúc Cơ | `29.9 s, 5/5, 92 %` | `8.4 s, 0/5, 0 %` | `catch-the-morning-cloud` 3.0/1.0, `painted-rain` 4.4/1.8, `paper-beam` 3.4/1.0, `marching-dirge` 8.2/2.2, `thorn-lullaby` 2.0/0.8 | n/a |
| `doanh_mo_vu` | Trúc Cơ | `29.7 s, 5/5, 93 %` | `8.4 s, 0/5, 0 %` | `catch-the-morning-cloud` 3.0/1.0, `painted-rain` 4.6/1.8, `paper-beam` 3.4/1.0, `marching-dirge` 8.2/2.2, `thorn-lullaby` 2.0/0.8 | n/a |
| `ung_trieu_hong` | Trúc Cơ | `36.9 s, 5/5, 81 %` | `8.0 s, 0/5, 0 %` | `catch-the-morning-cloud` 4.0/1.0, `painted-rain` 3.6/1.0, `marching-dirge` 11.8/2.0 | n/a |
| `van_tang_chi`, `trac_thu_lan` | Trúc Cơ | `59.2 s, 4/5, 12 %` | `8.0 s, 0/5, 0 %` | `catch-the-morning-cloud` 6.0/1.0, `painted-rain` 6.0/1.0 | n/a |
| `ly_khe_thu` | Luyện Khí | `22.8 s, 5/5, 100 %` | `8.0 s, 0/5, 0 %` | `catch-the-morning-cloud` 2.2/1.0, `painted-rain` 5.0/1.0, `three-wet-sheets` 17.0/5.6, `blotting-paper` 4.0/1.0 | n/a |
| `chuc_hieu_ha` | Luyện Khí | `53.0 s, 1/5, 1 %` | `8.0 s, 0/5, 0 %` | `catch-the-morning-cloud` 5.4/1.0, `painted-rain` 5.0/1.0 | n/a |
| `ta_quy_hong`, `phung_luc_y`, `nhieu_thach_nhu` | Luyện Khí | `38.3 s, 5/5, 60 %` | `8.0 s, 0/5, 0 %` | `three-wet-sheets` 25.8/4.8, `blotting-paper` 5.8/1.0 | n/a |
| `dai_diep_thu`, `mac_tieu_trien`, `han_tieu_chuc`, `tho_ma_tu`, `van_tieu_tang` | Luyện Khí | `40.0 s, 3/5, 18 %` | `8.0 s, 0/5, 0 %` | `three-wet-sheets` 25.4/4.8 | n/a |

---

## Open items
1. **Stage 7 / serial merge:** Merge `design/stage6-staging/nam_pho/` into `design/` and `assets/data/combat_effects.json`; closes `nam_pho`'s `cross_owner` technique references (`gian_van_lo` in `loose-south`, `trinh_hong_tien` and `trinh_chu_sa` in `market-folk`), `N-nam_pho-01`..`04`, and `chau_phi_van`'s game tie cap.
2. **Stale record-pass files (outside checkpoint write set):** `production/plans/stage6/nam_pho-review.md` and `nam_pho.done` reflect pre-fix `sect_fight.py` numbers (`catch-the-morning-cloud` / `dawn-flight` 9-pulse timing and unscaled `Paper Laid at Dawn tick`).

CHECKPOINT DONE
