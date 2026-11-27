# Loose Cultivators of the North (`loose-north`): Stage 6 checkpoint review (2026-11-27, headless, decisions auto-accepted)

## What this review read
I verified all records independently without trusting the record pass review file:
- **Staged files (`design/stage6-staging/loose-north/`):**
  - `items/catalogue-sect-loose-north.json` (10 unique items);
  - `items/sets-loose-north.json` (4 sets);
  - `effects/loose-north.effects.json` (7 Effects: 2 `not_run`, 5 combat);
  - no `pending.json`, `techniques/`, or `arts/` files (`0` pending engine words, `0` new techniques/arts).
- **Depth files (`design/world/depth/people/loose-north.*`):**
  - `loose-north.md`, `loose-north.items.json`, `loose-north.beasts.json`, `loose-north.cast.json`, `loose-north.2.cast.json`;
  - `design/world/depth/builds/authored/auth-eff-2.json` (`d48`), `auth-mod.json` (`b8`).
- **Rules and engine source:**
  - `production/plans/stage6/_brief-review.md`, `_brief-record.md`, `design/world/depth/DECISIONS-2026-11-25.md`, `DECISIONS-2026-11-26.md`, `tools/design/combat_sim/FIGHT-INPUT.md`;
  - `tools/design/combat_sim/engine.py`, `src/gameplay/combat/fight/fight.gd`, `effect_runner.gd`, `effect_compiler.gd`, `defence_path.gd`, and `src/gameplay/cultivation/cong_phap.gd` (`CongPhap.usable()`).
- **Checks and simulations:**
  - Standalone Effect validation (`engine.validate` + per-Effect counter/state declaration checks);
  - Uniqueness check against `assets/data/combat_effects.json`, `design/items/`, and `design/stage6-staging/`;
  - `spatial_words_check.py --sect loose-north`, `lint_items.py`, `depth_check.py --quiet`, `stage6_merge.py loose-north --check`, `depth_gap.py --sect loose-north`;
  - `sect_fight.py loose-north --seeds 5 --gap 0` and `--gap 1`, plus targeted probes for `Hot Hands`, `Thaw`, `Will Not Fall`, `The Way Out`, and `Never Had a Healer`.

## Findings, most severe first

| # | File | Record | What was wrong | Fix applied | Rank |
|---|---|---|---|---|---|
| 1 | `design/world/depth/people/loose-north.2.cast.json` | `bi_tu_nuong`, `yen_luu_huy` (stand-in replacements) | Both replacements failed `CongPhap.usable()` (`src/gameplay/cultivation/cong_phap.gd:43-47`): `bi_tu_nuong` (`moc: 40, hoa: 22, thuy: 20`) was given `warm-hearth-breath` (`names: ["tho", "moc", "hoa"]`, missing `tho`); `yen_luu_huy` (`kim: 40, hoa: 26, quang: 24`) was given `weighing-stone-primer` (`names: ["kim", "tho"]`, missing `tho`). | Replaced `bi_tu_nuong`'s `main` with `hearth-simmer-breath` (`tung_dao`, `tap_dich`, tier 0, `names: ["hoa"]`, `simmered-broth`, matches Tùng Hạ Thị stove/wine-warmer `dan_su`); replaced `yen_luu_huy`'s `main` with `touchstone-primer` (`chan_kim`, `ngoai_mon`, tier 0, `names: []`, `streak-on-the-stone`, matches assayer/miner `phap_tu`). Verified 20/20 stand-ins usable and firing (`simmered-broth` 8.8/fight `--gap 0`, `streak-on-the-stone` 10.4/fight `--gap 0`). | MUST-FIX |
| 2 | `design/stage6-staging/loose-north/effects/loose-north.effects.json` | `The Way Out` (`eff:The Way Out break node`, `eff:The Way Out escape hit` / `pulse`) | (a) `eff:The Way Out break node` (`on: "hit_landed"`, `tags: ["seal"]`, `if: foe.field_up >= 1`) used `timer {side: "foe", which: "next", by: 0.4}`. In both engines (`engine.py:1971`, `effect_runner.gd:588`), `which: "next"` picks `min(ready[i])` across ALL slots, including permanently guarded-out Field stances (`13/21` `field`-tagged stance arts in `combat_library.json`, including `lotus-seal-ground` in Probe 3, sit at `ready[i] <= t`). In Probe 3 at `t = 10300`, `which: "next"` delayed dead `lotus-seal-ground` (`8000 -> 8400`) instead of active `scorch-fist` (`13066`). (b) `sundered` `dur: 6` exceeded `K["curse_duration_max"] = 5` and was silently clamped. (c) `escape: 100` used `for: 10`, which could expire before a slow or delayed escape art fires. | Changed `timer.which` to `"longest"` (always targets the foe's active cooling art with latest `ready[i]`, delaying `scorch-fist` `12666 -> 13066` at `t = 10300` in Probe 3); set `sundered.dur` to `5`; widened `escape` duration from `for: 10` to `for: 300`; updated `The Way Out`'s `approx` note. | MUST-FIX |
| 3 | `design/stage6-staging/loose-north/effects/loose-north.effects.json` | `Will Not Fall` (`eff:Will Not Fall heal`) | `eff:Will Not Fall heal` (`on: "hit_landed"`, `filter: {"dtype": "phys"}`) had no `event.amount > 0` check. A 0-damage Physical hit (such as `whetstone-pass`, `bulwark-ram`, or a blocked/warded basic hit) within 3 s of `refuse_down` would consume `will_not_fall_heal` (`add: -1`) for `0` health. | Added `{"read": "event.amount", "op": ">", "value": 0}` to `eff:Will Not Fall heal`'s `if` conditions so only damaging hits consume the 3 s post-refusal heal. Verified on `lam_da_hac` `--gap 1` (`17.8 s` vs `11.4 s` without, `runs 10`: 5 survive + 5 heal). | SHOULD |
| 4 | `design/stage6-staging/loose-north/effects/loose-north.effects.json` | `Hot Hands` (`eff:Hot Hands chilled`) | `eff:Hot Hands chilled` checked `foe.debuff.ice >= 1` while `eff:Hot Hands warm` checked `foe.debuff.ice == 0`, leaving a dead gap for fractional Ice batches in `(0, 1)` (after a foe's `cleanse_share`) where neither record would fire. | Changed `foe.debuff.ice >= 1` to `foe.debuff.ice > 0` in `eff:Hot Hands chilled` so `chilled` and `warm` partition all Ice stack values cleanly. Verified in Probe 1a (`chilled = 41`, 68% HP) and Probe 1b (`warm = 64`, 28% HP). | SHOULD |
| 5 | `design/world/depth/people/loose-north.items.json` | `ln-thawing-brazier` (`Thaw`) | `loose-north.items.json` omitted `", at most 2 a pulse"` in `Thaw`'s `rule` string, diverging from `authored: "d48"` (`auth-eff-2.json:973`) and `loose-north.effects.json:16`. | Added `", at most 2 a pulse"` to `Thaw`'s `rule` in `loose-north.items.json` so depth text, `d48`, and staged Effect match verbatim. | SHOULD |

### Checked and kept
- **Items & sets (`catalogue-sect-loose-north.json`, `sets-loose-north.json`):** Diffed all 10 items and 4 sets against `loose-north.items.json` and `loose-north.md`. Every id, name, Hán-Việt parenthetical, family, kind, base, grade, modifier key/value/scope, set piece list, 2pc/3pc bonus, Effect name, rule, lore, and story matches verbatim; R6 `exception` is applied on the 6 `phu`/`giap`/`an`/`dao_bao` items and omitted on `dang`, `huong_lo`, `nhan`, `ngoc_boi`; `lint_items.py` reports 0 findings.
- **Standalone Effects & pitfall checklist:**
  - `loose-north.effects.json` carries `"_doc"` and `"source": "world-depth:loose-north"`; all 5 combat Effects compile standalone via `engine.validate()` with every self-counter (`will_not_fall_heal`, `way_out_used`, `leech_shield_up`) declared in its own `"counters"` and 0 stances set; all 7 Effect names, 10 item IDs, and 4 set IDs are unique against `assets/data/combat_effects.json`, `design/items/`, and `design/stage6-staging/`.
  - `Will Not Fall`: `refuse_down` sets `hp = 1.0` (`refuse_down_health`), `shield {refill: 1.0}` refills `body_bar`, `will_not_fall_heal` uses `each_for: 3, cap: 1` with `add: 1` on `down` and `add: -1` on `hit_landed`.
  - `Never Had a Healer`: traced `plog` on `khau_thien_tu` — `heal_overflow` (`source: "leech"`) adds overflow to `body_bar` and sets `leech_shield_up = 1`, `decay` runs before `clear` on `pulse` (`-10%` of `body_bar` while `body_shield_share > 0`), `clear` resets `leech_shield_up = 0` when `body_bar` breaks to `0`, and `always` `crit_mult: 25` is scoped inside `mod` (`dtype: "phys"`).
  - `Thaw`: `hit_landed` (`element: "fire"`, `own.debuff.ice >= 1`, `per_pulse: 2`) -> `cleanse` Ice 1, `heal` 0.5% max HP, `stacks` Fire buff 1 for 5 s (`eff:Thaw = 65` in Probe 1c vs Ice foe).
  - `Flame Leans` and `Thaw the Ice`: out-of-fight ruin exploration rules cleanly marked `not_run` with `records: []`.
  - `spatial_words_check.py --sect loose-north`: 0 hits for `loose-north`.
  - `tiem_anh` beast wiring: `quan_tuyet_tung` has `than_hon: 56` (beast capacity `2`), `beasts: ["tiem_anh"]` in `loose-north.cast.json`, and `tiem_anh` in `loose-north.beasts.json` has matching `owner_id` and `bond.keeper`.

## Decisions on pending words
- **None (`0` pending words)**. No `pending.json` exists; all 5 combat Effects run on existing engine vocabulary.

## Holder table after the fixes

Same realm (`--gap 0`) and one realm up (`--gap 1`), typical foe, 5 seeds each via `sect_fight.py loose-north`. All 31 living members run with 0 `REFUSED` and every slotted art fires.

| Holder (realm) | `--gap 0` (5 seeds) | `--gap 1` (5 seeds) | Effects: with / without (runs) & notes |
|---|---|---|---|
| `lam_da_hac` (`truc_co`) | 15.5 s, 5/5, 67% | 17.8 s, 0/5, 0% | `Will Not Fall`: `--gap 0` 67% / 67% (`runs 0`); `--gap 1` **17.8 s / 11.4 s** (`runs 10`: 5 survive + 5 heal) |
| `phan_co_dang` (`ket_dan`) | 11.7 s, 5/5, 100% | 14.0 s, 0/5, 0% | `Flame Leans`: `not_run` (`runs 0`). `The Way Out`: `--gap 0` 100% / 100% (`runs 0`); `--gap 1` 14.0 s / 14.0 s (`runs 5` escape trigger; no escape art slotted; `break node` verified in Probe 3 with `seal-slam` vs `lotus-seal-ground`: delays `scorch-fist` +0.4 s + `sundered`) |
| `khau_thien_tu` (`ket_dan`) | 21.0 s, 5/5, 100% | 9.0 s, 0/5, 0% | `Never Had a Healer`: `--gap 0` **21.0 s (100%) / 22.0 s (99%)** (`runs 112`); `--gap 1` 9.0 s / 9.0 s (`runs 17`) |
| `du_chuc_nhi` (`luyen_khi`) | 44.0 s, 4/5, 12% | 8.0 s, 0/5, 0% | `Thaw the Ice`: `not_run` (`runs 0`). `Thaw`: `runs 0` vs `typical` (no Ice foe; Probe 1c vs Ice foe: **39.8 s, 5/5, 49%, `eff:Thaw = 65`**). `Hot Hands`: 1pc equipped at `luyen_khi` (activates at `truc_co`); Probe 1a chilled **25.0 s, 5/5, 68% (`41`)**, Probe 1b warm **39.2 s, 5/5, 28% (`64`)** |
| `nham_do_han` (`truc_co`) | 59.8 s, 0/5, 0% | 10.4 s, 0/5, 0% | `line-through-the-ice` 8.8, `sitting-in-the-snow` 1.0 (`--gap 0`) |
| `cat_chau_nuong` (`truc_co`) | 51.8 s, 5/5, 99% | 10.8 s, 0/5, 0% | `deep-lake-stance` 17.2, `full-pool` 6.6, `the-moon-in-the-water` 6.0 |
| `ho_dien_liet` (`truc_co`) | 62.6 s, 3/5, 10% | 8.9 s, 0/5, 0% | `cut-the-horse` 13.0, `hold-the-line` 11.0 |
| `gia_chi_lo` (`luyen_khi`) | 44.9 s, 0/5, 0% | 9.0 s, 0/5, 0% | `lighter-than-a-horse` 8.6 |
| `mong_thuy_huong` (`luyen_khi`) | 36.0 s, 0/5, 0% | 8.0 s, 0/5, 0% | `frost-breath-palm` 11.4 |
| `hau_tieu_luc`, `luyen_dac_bao` (`luyen_khi`) | 40.4 s, 0/5, 0% | 9.2 s, 0/5, 0% | `a-breath-of-road-mist` 7.6; `The Wind Lifts the Mist` (`runs 0`, fires only vs Wind foe arts) |
| `dinh_van_tac` (`truc_co`) | 49.4 s, 5/5, 100% | 9.6 s, 0/5, 0% | `cloud-in-the-pool` 6.4, `upside-down-sky` 5.0, `deep-lake-stance` 16.4 |
| `cu_lo_nhi` (`luyen_khi`) | 62.6 s, 5/5, 67% | 13.0 s, 0/5, 0% | `pole-vault` 14.2, `rooted-form` 7.8 |
| `mach_phuc_linh` (`luyen_khi`) | 25.8 s, 5/5, 100% | 8.1 s, 0/5, 0% | `seed-of-spring` 5.0, `furrow-palm` 6.2 |
| `bi_tu_nuong` (`luyen_khi`, fixed) | 47.4 s, 0/5, 0% | 8.0 s, 0/5, 0% | `simmered-broth` 8.8 (`--gap 0`), 1.0 (`--gap 1`) |
| `yen_luu_huy` (`luyen_khi`, fixed) | 35.2 s, 0/5, 0% | 8.0 s, 0/5, 0% | `streak-on-the-stone` 10.4 (`--gap 0`), 2.0 (`--gap 1`) |
| `nhung_tu_dieu` (`luyen_khi`) | 55.2 s, 5/5, 90% | 15.0 s, 0/5, 0% | `rooted-form` 7.2, `log-on-the-current` 8.0 |
| `tuan_tuyet_lien` (`luyen_khi`) | 56.8 s, 4/5, 15% | 8.0 s, 0/5, 0% | `morning-dew` 10.2, `leaf-drip` 17.0 |
| `ngu_bat_te` (`luyen_khi`) | 64.4 s, 1/5, 3% | 10.2 s, 0/5, 0% | `hold-the-line` 11.6 |
| Other tier C (`lieu_tay_sa`, `khong_vong_bang`, `ha_tieu_bang`, `xa_linh_nhi`, `au_van_chieu`, `mac_than_nuong`) | 33.6–48.6 s, 0/5, 0% | 8.0–9.0 s, 0/5, 0% | All slotted arts fire (`8.0–14.8` at `--gap 0`, `1.0–2.0` at `--gap 1`) |

- **Post-edit linters:** `lint_items.py` 0 findings (10 items); `depth_check.py --quiet` `findings: none`; `stage6_merge.py loose-north --check` 0 failures; `depth_gap.py --sect loose-north` `stand_ins: 0`, `engine_words: 0`, `wishes_open: 0`; `spatial_words_check.py --sect loose-north` 0 `loose-north` hits.

## Open items
1. **Pre-existing non-stand-in `CongPhap` mismatches (`loose-north.cast.json`):** `quan_tuyet_tung` (`moc: 62, thuy: 28`) carries pre-existing `aux: hunters-reach-canon` (`names: ["kim"]`), which fails `CongPhap.usable()` in Godot; `phan_co_dang` (`hollow-bell-canon` `main` in `aux`), `ho_dien_liet` (`sand-wall-primer` `main` in `aux`), `khau_thien_tu` (`drawn-out-edge-canon` `secret` in `main`), and `du_chuc_nhi` (`scorch-fist-primer` `secret` in `main`) carry slot-kind mismatches under `CongPhap.set_slot`. Left untouched as pre-existing authored cast data.
2. **`phan_co_dang` kit coverage (`The Way Out`):** Her technique arts (`still-moon-tide-scripture`, `hollow-bell-canon`) carry neither an `escape`-tagged art nor a `seal`-tagged art (though `ln-lock-breaker-seal` provides common art `seal-slam`, verified in Probe 3).
3. **`du_chuc_nhi` growth goal (`Hot Hands`):** At `luyen_khi` she equips only `ln-thawing-brazier` (`ln-ember-pendant` sits in `items` until `truc_co`), per `DECISIONS-2026-11-25.md` Group 4.
4. **Stale record-pass files (outside checkpoint write set):** `production/plans/stage6/loose-north-review.md` §F and `loose-north.done` still list `warm-hearth-breath` (`bi_tu_nuong`) and `weighing-stone-primer` (`yen_luu_huy`).
5. **Stage 8 merge & export:** 17 cross-owner techniques (all merged in `design/techniques/`), `nham_do_han`'s `mf-way-out-knot` (`market-folk`), and beast `tiem_anh` close at Stage 8 merge / `export_world.py --sect all`.

CHECKPOINT DONE
