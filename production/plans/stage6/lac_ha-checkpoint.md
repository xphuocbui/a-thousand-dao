# Lạc Hà Tông: Stage 6 checkpoint review (2026-11-27, headless, decisions auto-accepted)

## What this review read
This review audited the staged files, depth source text, rulings, engine implementation, and `sect_fight.py` runs unanchored against `lac_ha-review.md`:
- **All staged files** in `design/stage6-staging/lac_ha/`: `techniques/catalogue-sect-lac_ha.json` (6 techniques), `arts/part-sect-lac_ha.json` (10 arts), `effects/lac_ha.effects.json` (21 Effects), `items/catalogue-sect-lac_ha.json` (30 items), `items/sets-lac_ha.json` (10 sets), and `pending.json`.
- **Depth source of truth:** `design/world/depth/sects/lac_ha.techniques.json`, `lac_ha.items.json`, `lac_ha.md`, all cast files (`lac_ha.*cast*.json`), and `design/world/depth/builds/postponed-2026-11-26.json`.
- **Rules & engine:** `production/plans/stage6/_brief-review.md`, `_brief-record.md`, `DECISIONS-2026-11-25.md`, `DECISIONS-2026-11-26.md`, `FIGHT-INPUT.md`, `tools/design/arts/lint_techniques.py`, `src/gameplay/cultivation/cong_phap.gd`, `src/gameplay/combat/fight/fighter_compiler.gd`, `src/gameplay/combat/fight/build_file_compiler.gd`, `thien_xu-checkpoint.md`, and `lac_ha-review.md`.
- **Verification runs (post-edit):** `lint_techniques.py`, `lint_arts.py`, `lint_items.py`, `depth_check.py`, `sect_fight.py lac_ha --seeds 5` (same realm and `--gap 1`), plus real-kit probes (`10-30` seeds via `sect_fight` + `fight.run`).

## Findings, most severe first

| # | File | Record | What was wrong | Fix applied | Rank |
|---|---|---|---|---|---|
| 1 | `design/stage6-staging/lac_ha/techniques/catalogue-sect-lac_ha.json` and `design/world/depth/sects/lac_ha.techniques.json` | `bellows-and-hearth-breath` | Staged and depth records required `"names": ["hoa", "kim", "tho"]`. In `src/gameplay/cultivation/cong_phap.gd` (`CongPhap.usable`), a character must hold every listed element to equip/compile a technique. None of the 4 living stand-in holders (`ho_tu_nuong`, `co_tieu_thiet`, `ngu_hoa_lien`, `hua_tra_nuong`) has all three elements, making their main method unusable in Godot (`fighter_compiler.gd:137`). All 4 hold `"hoa"`, `hearth-ember-breath` has `element: ""`, and all 3 passives have `scope: []`. | Tightened `"names"` to `["hoa"]` in both `catalogue-sect-lac_ha.json` and `lac_ha.techniques.json` (and tightened `concept` wording to Fire hands). Re-check across all `lac_ha` cast files confirms `4` holders, `0` root mismatches. | MUST-FIX |
| 2 | `design/stage6-staging/lac_ha/techniques/catalogue-sect-lac_ha.json` | `evening-dust-primer`, `sunset-cloud-canon`, `evening-song-of-the-boats` | Wish `b1`'s 6 non-fight passive lines (`dao_tam` `0.66 / 1.33 / 1.33`, `breakthrough_chance` `0.4 / 0.8 / 0.8`) were held out of staged `passives` because `lint_techniques.py` previously refused `NOT_PRICED` on unpriced files. Commit `adc5978a` downgraded `NOT_PRICED` on `catalogue-sect-*.json` to a note, `fight.py` cleanly moves unknown stat keys into `unmodelled`, `build_file_compiler.gd` skips unmodelled passive keys cleanly, and withholding them broke the 2026-11-26 "Everything goes into the game" ruling. | Restored all 6 `dao_tam` and `breakthrough_chance` lines into `passives` on the 3 techniques matching `lac_ha.techniques.json`. Re-run of `lint_techniques.py` gives `checked 6 techniques, 0 findings` (`NOT_PRICED` as notes only) and `sect_fight.py` passes with `0 REFUSED`. | MUST-FIX |
| 3 | `design/stage6-staging/lac_ha/pending.json` | `technique-effects` | `pending.json` had the field spec and `used_by` (`sunset-cloud-canon`, `The Glow Deepens`) without a checkpoint `"decision"` or `"decision_reason"`. | Added `"decision": "build"` and `"decision_reason"` matching `thien_xu-checkpoint.md`. `The Glow Deepens` stays in `effects/lac_ha.effects.json` with its `"pending"` note until the serial build step wires `technique-effects`. | SHOULD |
| 4 | Existing lineage techniques (`lac_ha.*` + `catalogue-sect-lac_ha.json`) | `evening-dust-primer`, `sunset-cloud-canon`, `evening-song-of-the-boats` | Cast root check vs `CongPhap.usable`: `evening-dust-primer` (`["tho", "moc"]`) has `16/34` living holders lacking one element; `sunset-cloud-canon` (`["tho", "moc"]`) has `4/16` living Metal+Earth holders (`hinh_trong_son`, `tong_thu_tin`, `tu_binh_hanh`, `thinh_kinh_han`) lacking `moc`; `evening-song-of-the-boats` (`["moc"]`) has `5/16` living Earth+Water Boat Hall holders (`lu_tan_chu`, `lo_niem_ca`, `ha_hau_thanh_bich`, `mac_huong_tay`, `cao_van_ca`) lacking `moc`. | **Not applied** (consistent with `thien_xu` and `bang_tam` checkpoints: authored lore `names` are not silently altered). Logged as an open item for Stage 7/9 (`CongPhap` or cast root ruling). | SHOULD |
| 5 | `production/plans/stage6/lac_ha-review.md` §A4 | `the-sunset-clouds-fly-with-the-lone-duck` (`quach_tiep_van`) | §A4 accurately says `the-sunset-clouds-fly-with-the-lone-duck` keeps `mountain` intact via `own.state.any == 0`, but omits that library art `mountain-stance` (`design/arts/family-earth.json`) still unconditionally overwrites `"sunset-cloud"`. | **Not applied** (`lac_ha-review.md` and `design/arts/family-earth.json` are outside this job's write set). Since `quach_tiep_van` carries no `field_up` Effect, no `lac_ha` record breaks; logged in Open items. | SHOULD |
| 6 | `design/stage6-staging/lac_ha/effects/lac_ha.effects.json` | `Fished from the Shallows` (`eff:Fished from the Shallows spend tag`) | `spend tag` filtered only `{"tags": ["needle"]}` without `"not_art_id": "needle-rain"`, unlike its sibling `pin tag`. | Added `"not_art_id": "needle-rain"` to `spend tag`'s filter so `spend rain` and `spend tag` never overlap on `needle-rain`. Verified cleanly in 30-seed probe (`t=14.7s win=30/30 hp=95%`, `arm: 80`, `spend rain: 49`, `pin rain: 60`). | NIT |

### Checked and kept
- **Items & Sets:** Verified all 30 items and 10 sets against `lac_ha.items.json` (`items` and `sets` counts exact `30` and `10`; `Geese in File` on `lh-cold-geese-sword` omitted as parked per `postponed-2026-11-26.json`).
- **Stand-ins:** All 9 stand-ins (`nguy_thu_can` -> `evening-dust-primer`, 3 river/dyer servants -> `evening-ferry-breath`, 4 kitchen/forge servants -> `bellows-and-hearth-breath`, `vuu_chuoc_kim` -> `anvil-thunder-canon`) fit their holders' roots (`0` mismatches after fix #1).
- **Parked content:** `long-sky-one-colour` (and its 3 arts) plus `Geese in File` remain parked per `postponed-2026-11-26.json`.
- **Effect probes verified:**
  - `Fished from the Shallows` (`lu_tan_chu` + `needle-rain`, 30 seeds post-edit): `14.7 s, 30/30, 95% hp` (`arm: 80, spend rain: 49, pin rain: 60`).
  - `Price on the Ribs` (`hach_anh_ha` + `fan-gust`, `without=['eff:Eight Marks']`, 10 seeds post-edit): `26.3 s, 10/10, 99% hp` (`113` runs) vs `27.8 s` without `Price on the Ribs`.
  - `Breath Held` (`hinh_lac_nhan` + `flying-sword-strike` vs Wood-stacking foe, 10 seeds post-edit): `22.7 s, 10/10, 94% hp` (`shed wood: 142` runs) vs `25.1 s, 10/10, 89% hp` without it.
  - Note on `Every Debt Written` / `Every Debt Called` (`tram_tich_duong`): at `--gap 1`, body shield absorbs hits for calls 1 and 2 (`runs 79` and `202` across 5 seeds), after which a partially blocked hit triggers both `blocked` and `was_hit`; benign for Lạc Hà and left unchanged.
- **No spatial or environment words, no caps, Effects unpriced:** Verified across all 10 staged arts and 21 staged Effects.

## Decisions on the pending words (recorded in `pending.json`)

| Word | Decision | Reason |
|---|---|---|
| `technique-effects` | **build** | Matches `thien_xu-checkpoint.md`. Shared across ~20 owners' technique files (`lac_ha`'s `sunset-cloud-canon` + `The Glow Deepens`, `thien_xu`, and others). `The Glow Deepens` keeps its record in `effects/lac_ha.effects.json` with its `pending` note until the serial step wires `tech_layers` + library Effects in both engines. |

## Holder table after the fixes

Same realm, typical foe, 5 seeds (`python -I tools/design/combat_sim/sect_fight.py lac_ha --seeds 5`, `0 REFUSED` across 69 living holders).

| Holder (realm) | Result | Effects: with / without (runs) | Note |
|---|---|---|---|
| `to_van_chieu` (NA) | `32.2 s, 5/5, 100%` | `Colour of the Hour` `32.2 s / 32.2 s` (`65`); `The Lightning Sleeps` `0 NEVER_RAN` | No Thunder root, no Thanh Sương; verified via probe (`thien_xu`/`lac_ha`) |
| `tram_tich_duong` (NA) | `10.8 s, 5/5, 100%` | `Every Debt Written` `10.8 / 11.4 s` (`10`); `Every Debt Called` `10.8 / 11.4 s` (`102`) | Both run; active defense at `--gap 1` (`25.3 s` vs `22.5 / 20.9 s`, `79 / 202` runs) |
| `canh_truong_thien` (NA) | `43.1 s, 5/5, 100%` | `Waits for Its Blade` `0 NEVER_RAN`; `Geese in the Cold` `43.1 s 100% / 43.1 s 99%` (`0`) | Thanh Sương lost (`Waits` probe `25.0 vs 27.6 s`); `Geese` shelter `always` runs at `--gap 1` (`18.2 vs 16.2 s`, `5` runs) |
| `hach_anh_ha` (KĐ) | `41.2 s, 5/5, 99%` | `Price on the Ribs` `0 NEVER_RAN`; `Eight Marks` `0 NEVER_RAN` | `sect_fight` slots 6 tech arts; probes with `fan-gust`: `Price` `26.3 vs 27.8 s` (`113`), `Eight Marks` `24.2 vs 26.3 s` |
| `quach_tiep_van` (KĐ) | `23.5 s, 5/5, 100%` | `Span the Gap` `23.5 / 32.5 s` (`70`); `Anchored Span` `23.5 / 26.8 s` (`82`) | Both clear; `mountain-stance` overwrites `sunset-cloud` (no `field_up` Effect on Quách) |
| `hinh_trong_son` (KĐ) | `43.0 s, 5/5, 99%` | `The Flame Turns Green` `0 NEVER_RAN`; `Outlast the Grey` `43.0 / 42.0 s` (`15`) | Typical foe lays no poison (runs with Wood/poison foe) |
| `lo_xuong_van` (KĐ) | `40.4 s, 5/5, 99%` | `Lit but Not Launched` `40.4 / 45.6 s` (`64`) | |
| `vuu_chuoc_kim` (KĐ) | `24.3 s, 5/5, 82%` | — | Fires `anvil-blow` `6.4`, `thunder-quench` `4.0`, `iron-hide-stance` `4.0` |
| `tong_thu_tin`, `tu_binh_hanh` (KĐ) | `10.9 s, 5/5, 97%` | — | |
| Other KĐ elders (`chu_hong_diep`, `bo_tan_chieu`, `su_thu_thuy`, `lan_vien_pham`, `thinh_kinh_han`) | `42.2–44.6 s, 5/5, 97–99%` | — | |
| `lu_tan_chu` (TC) | `17.0 s, 5/5, 96%` | `Fished from the Shallows` `17.0 / 17.0 s` (`15`) | `needle-rain` not slotted by `sect_fight`; post-edit 30-seed probe `14.7 s`, `arm 80 / spend rain 49 / pin rain 60` |
| `hinh_lac_nhan` (TC) | `39.6 s, 5/5, 98%` | `Breath Held` `0 NEVER_RAN` | Post-edit probe (`+flying-sword-strike` vs Wood foe): `22.7 s 94%` vs `25.1 s 89%` (`142` sheds) |
| `tang_van_tieu` (TC) | `10.4 s, 5/5, 95%` | — | |
| 4 TC Boat/Body holders (`nhiep_ngoc_am`, `sai_thanh_phong`, `giang_vong_pham`, `mac_huong_tay`) | `20.3 s, 5/5, 94%` | — | |
| 4 TC Boat-song elders (`lo_niem_ca`, `quan_dan_phong`, `hong_van_tinh`, `ha_hau_thanh_bich`) | `37.6 s, 5/5, 95%` | — | `the-ninth-verse` fires `0.2/fight` at `--gap 1` on `hong_van_tinh` and `ha_hau_thanh_bich` |
| `cao_van_ca` (LK) | `45.5 s, 5/5, 45%` | — | |
| `to_mo_van` (LK) | `45.8 s, 1/5, 10%` | — | Wears `lh-scribes-reed-brush` (set goal `Glow After Dark` requires TC `lh-evening-glow-brush`) |
| 33 Primer+millstone outer gate (LK) | `40.4–42.8 s, 1–2/5, 3–8%` | — | |
| `nghe_tieu_thao` (LK) | `49.6 s, 0/5, 0%` | — | Primer only |
| 3 `evening-ferry-breath` servants (`hoang_lan_chi`, `khuc_lao_dieu`, `tan_tieu_uyen`, LK) | `46.2 s, 0/5, 0%` | — | `ferry-breath` fires `8.2` |
| 4 `bellows-and-hearth-breath` servants (`ho_tu_nuong`, `co_tieu_thiet`, `ngu_hoa_lien`, `hua_tra_nuong`, LK) | `46.4 s, 0/5, 0%` | — | `hearth-ember-breath` fires `8.4`; `names: ["hoa"]` now valid for all 4 |

- **`--gap 1`, all 69 living holders:** all lose in `8.0–27.0 s` (`0/5`), `the-ninth-verse` fires `0.2/fight` when Wounded (`hong_van_tinh`, `ha_hau_thanh_bich`). Only `bastion-reprisal` hits `0.0` on `nhiep_ngoc_am`, `sai_thanh_phong`, `giang_vong_pham`, and `mac_huong_tay` (cooldown timing before death at gap 1).
- **Linters & `depth_check.py` after final JSON edits:**
  - `lint_techniques.py`: `checked 6 techniques, 0 findings` (`NOT_PRICED` and `OVER_BUDGET` reported as notes).
  - `lint_arts.py`: `checked 10 arts in 1 files, 0 findings`.
  - `lint_items.py`: `checked 30 items, 22 bases, 9 common arts, 0 findings`.
  - `depth_check.py`: `findings: none`.

## Open items (for the user, Stage 7/9, or serial step)
1. **Cross-root lineage `names` vs `CongPhap.usable` (finding #4):** `evening-dust-primer` (`16/34` living holders), `sunset-cloud-canon` (`4/16`), and `evening-song-of-the-boats` (`5/16`) include holders missing one element in `names`, blocking `CongPhap.usable` in Godot unless lineage `names` or cast roots/rules change.
2. **`b1` non-fight passives in engine/UI (finding #2):** `dao_tam` and `breakthrough_chance` are restored in `catalogue-sect-lac_ha.json`; Stage 7+ / `combat_engine.json` `out_of_fight` and `cong_phap.gd` StatSheet wiring must consume them cleanly outside combat.
3. **`technique-effects` pending word (finding #3):** wire `sunset-cloud-canon` (`The Glow Deepens`) in the serial step (`fight.py` `tech_layers` + Godot `FighterCompiler` / `build_file_compiler.gd`).
4. **Stance overwrite on `quach_tiep_van` (finding #5):** `mountain-stance` (`design/arts/family-earth.json`) unconditionally overwrites `sunset-cloud`; `quach_tiep_van` has no `field_up` Effect, so benign for Lạc Hà unless future builds rely on `sunset-cloud` uptime.
5. **Carried over from `lac_ha-review.md`:** parked `long-sky-one-colour` and `Geese in File` (multi-fighter combat), `export_named.py` skipping `kind: treasure` (`lh-tu-dien`, `lh-thanh-suong`), WIRED held items (`mountain-heart-canon` + `lh-nails-of-dao-sa`, `ruin-ledger-scripture`, `sai_thanh_phong` aux `evening-song-of-the-boats`), and out-of-fight half of `The Treasury Key`.

CHECKPOINT DONE
