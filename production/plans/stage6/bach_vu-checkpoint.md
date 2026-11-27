# Bách Vũ Các (`bach_vu`): Stage 6 checkpoint review (2026-11-27)

Reviewed unanchored against `design/world/depth/sects/bach_vu.md`, `bach_vu.techniques.json`, `bach_vu.items.json`, `bach_vu.cast.json`, `bach_vu.5.cast.json`, `bach_vu.beasts.json`, `production/plans/stage6/_brief-record.md`, `design/world/depth/DECISIONS-2026-11-25.md`, `DECISIONS-2026-11-26.md`, and `tools/design/combat_sim/FIGHT-INPUT.md`.

## Ranked findings

**0 MUST-FIX, 0 SHOULD, 3 NIT (no edits required).**

1. **NIT — `design/stage6-staging/bach_vu/arts/part-sect-bach_vu.json` (`still-on-the-branch`, `under-the-wing`):** `sources` includes `"a1"` alongside `"world-depth:bach_vu"`. Harmless (`export_combat_library.py` assigns `source = "part_authored"` from `tier`); left as-is.
2. **NIT — `design/stage6-staging/bach_vu/arts/part-sect-bach_vu.json` (`still-on-the-branch` → `branch-evade`):** checks both `own.state.on-the-branch >= 1` and `own.composed >= 1`. Because state `on-the-branch` carries `"tags": ["composed"]`, `own.composed >= 1` is always true while in the stance; harmless and faithful to the rule text, left as-is.
3. **NIT — `design/world/depth/sects/bach_vu.items.json` (`bvc-bird-mother`):** line 169 retains `"within 2 s"` (flagged as a time-window false positive by `spatial_words_check.py`), whereas `design/stage6-staging/bach_vu/items/sets-bach_vu.json` already rewords it to `"in 2 s"` (0 spatial hits in staged files). Consistent with `b01` convention; left as-is.

## Specific parity, uniqueness, and mechanic verification

- **GDScript standalone compilation parity (`src/gameplay/combat/fight/effect_compiler.gd`, `effect_runner.gd`, `fighter_profile_loader.gd`):**
  - **Counters declared locally:**
    - `bach_vu.effects.json`: `Call of the Luan` declares `luan_flock`; `All Birds Bow` declares `bow_feathers` and `bird_strike_2s` (`each_for: 2`); `Hundred-Feather Fan` reads/writes no counters (`scale: own.tech_layer.moulted-feather-fan`).
    - `part-sect-bach_vu.json`: `call-down` declares `wild_bird`; `still-on-the-branch` declares `branch_still`; `loose-the-flock` declares `luan_flock`; `under-the-wing` declares `wing_decoy`.
  - **No same-record multi-`mod` `temp_mods` clobbering:** the only `mod` actions are on `on: "always"` records (`Hundred-Feather Fan` and `branch-evade`), with zero event-triggered `mod` actions.
  - **Stances declared and non-clobbering:** only `still-on-the-branch` defines and sets a stance (`on-the-branch`, `tags: ["composed"]`), declared in its own `"states"`. None of the 16 living `bach_vu` holders slot two stance techniques, and no outside cast member slots any `bach_vu` technique.
- **Effect name uniqueness:** `Call of the Luan`, `All Birds Bow`, and `Hundred-Feather Fan` have **0 clashes** against all 258 Effects in `assets/data/combat_effects.json` and all 10 staged `design/stage6-staging/*/effects/*.effects.json` files (`b02`). All technique, art, item, and set IDs are also unique across `design/` and `design/stage6-staging/`.
- **`Call of the Luan` (`bvc-blue-luan-whistle`):** triggers once per fight on `pulse` at `own.hp_share <= 0.8` (8 % max HP heal + `luan_flock: 1`), consumed by `loose-the-flock` (`flock-luan-bonus`: `free_hit` `c: 0.49`, `dtype: "chaos"` + 1 Wood stack 8 s). Verified in 10-seed probes: fires 4/10 seeds at `--gap 0` without beasts (`hp_left` ~84 %) and 10/10 seeds at `--gap 1` (with and without beasts), triggering `flock-luan-bonus` on every firing. At `--gap 0` with 3 beasts (`17.2 s`, `96.6 %` HP left), `ta_thanh_loan` never drops below `80 %` HP so it stays held in reserve.
- **`All Birds Bow` (`bvc-bird-mother`):** verified on `ta_thanh_loan` with her 3 bonded birds (`tieu_loan`, `que_tuoc`, `mac_vu`, `tags: ["bird", ...]`, `cd: 1.0`, `c: 0.5`) over 10 seeds:
  - `--gap 0`: **17.2 s, 10/10 wins, 96.6 % HP left** vs **22.0 s, 10/10 wins, 91.1 % HP left** without `eff:All Birds Bow` (`eff:All Birds Bow count` 516, `eff:All Birds Bow slow` 172, `eff:All Birds Bow fan` 40).
  - `--gap 1`: **12.37 s, 0/10 wins** vs **8.40 s, 0/10 wins** without (`count` 360, `slow` 120, `fan` 20).
  - `fan-gust` common-art probe (`--gap 0`, 10 seeds): **19.3 s, 10/10 wins, 83.7 % HP left** (`eff:All Birds Bow fan gust` 76, `count` 579, `slow` 193).
- **`Hundred-Feather Fan` (`moulted-feather-fan` L2 passive Effect):** staged in `catalogue-sect-bach_vu.json` (`unlock_layer: 2`, `passive_art: true`) and `bach_vu.effects.json` (`scale: own.tech_layer.moulted-feather-fan / 1`, `mod: {stack_dur: 2, element: "fire", kind: "debuff"}`), matching `technique-effects` (`export_combat_library.py`, `fighter_compiler.gd`, `build_file_compiler.gd`, `fight.gd`). Verified on `ta_thanh_thuoc` (L8, `+16 %` Fire debuff duration) over 10 seeds at `--gap 0`: **47.7 s, 10/10 wins, 50.9 % HP left** vs **50.2 s, 10/10 wins, 47.4 % HP left** without `eff:Hundred-Feather Fan`.
- **Stand-in resolution (`hoan_truc_lung`):** `hoang_kim` 5 → `woven-cage-breath` 5 (`tier: 0`, `main`, `names: ["kim", "tho"]`, `rank: "tap_dich"`, `7.8 W of 8`, active art `wire-snare-needle`). Matches his `kim 44, tho 30` root, `tap_dich` rank, and `_brief-review.md` §4 order (no Metal lineage method, note names no external method, pavilion doctrine forbids other cage-makers).

## Pending words

None (`design/stage6-staging/bach_vu/pending.json` absent; 0 pending words).

## Checks & Holder table (`DEPTH_STAGE=design/stage6-staging/bach_vu`)

- `lint_techniques.py`: **0 findings** (`7.4 W`, `15.7 W`, `14.8 W`, `7.8 W`; 4 techniques).
- `lint_arts.py`: **0 findings** (6 arts).
- `lint_items.py`: **0 findings** (3 items, 3/3 unique with R6 `exception`).
- `depth_check.py`: **`findings: none`**.
- `depth_gap.py --sect bach_vu`: `stand_ins: 0`, `unknown_ids: 0`, `cross_owner: 0`, `ties_unmapped: 0`, `ties_over_cap: 0`, `engine_words: 0`, `wishes_open: 0`.
- `sect_fight.py bach_vu --seeds 5` (`--gap 0` and `--gap 1`): **0 REFUSED** across all 16/16 living people; every slotted art fires.

| Holder | Realm | Arts | Gap 0 (`mean_s`, `wins`, `hp_left`) | Gap 1 (`mean_s`, `wins`, `hp_left`) | Art fires (G0 / G1) & Effect notes |
|---|---|---|---|---|---|
| `ta_thanh_loan` | `truc_co` | `loose-the-flock`, `under-the-wing`, `shed-feathers-burn` | 37.3 s, 5/5, 85 % | 8.8 s, 0/5, 0 % | Fires 9.2/7.2/8.2 (G0), 2.0/1.2/2.0 (G1). `Call of the Luan`: 2 runs G0 (37.3 s 85 % vs 37.7 s 79 % without), 5 runs G1 (8.8 s vs 8.2 s). `All Birds Bow`: 0 runs in default `sect_fight` (Stage 7 beasts; 10-seed probe: 17.2 s 96.6 % vs 22.0 s 91.1 % G0, 12.37 s vs 8.40 s G1). `Hundred-Feather Fan`: `always` (0 `Fight.do()` runs). |
| `ta_thanh_thuoc` | `truc_co` | `loose-the-flock`, `under-the-wing`, `shed-feathers-burn` | 46.2 s, 5/5, 55 % | 8.0 s, 0/5, 0 % | Fires 10.0/7.8/8.8 (G0), 1.4/1.0/2.0 (G1). `Hundred-Feather Fan`: 46.2 s 55 % vs 48.8 s 50 % without (10-seed probe: 47.7 s 50.9 % vs 50.2 s 47.4 %). |
| `hang_thai_vu` | `truc_co` | `loose-the-flock`, `under-the-wing`, `shed-feathers-burn` | 58.8 s, 2/5, 2 % | 8.4 s, 0/5, 0 % | Fires 10.4/10.2/7.4 (G0), 1.2/1.0/1.0 (G1). `Hundred-Feather Fan`: 58.8 s 2 % vs 59.2 s 1 % without (`always`). |
| `giai_van_tieu` | `truc_co` | `loose-the-flock`, `under-the-wing` | 62.4 s, 1/5, 0 % | 8.6 s, 0/5, 0 % | Fires 13.4/11.0 (G0), 1.4/1.0 (G1). |
| `phu_vu_to` | `truc_co` | `loose-the-flock`, `under-the-wing` | 62.4 s, 1/5, 0 % | 8.6 s, 0/5, 0 % | Fires 13.4/11.0 (G0), 1.4/1.0 (G1). |
| `lam_the_ngo` | `truc_co` | `loose-the-flock`, `under-the-wing` | 62.4 s, 1/5, 0 % | 8.6 s, 0/5, 0 % | Fires 13.4/11.0 (G0), 1.4/1.0 (G1). |
| `ky_hong_phien` | `luyen_khi` | `loose-the-flock`, `under-the-wing` | 42.8 s, 0/5, 0 % | 8.0 s, 0/5, 0 % | Fires 8.8/7.2 (G0), 1.4/1.0 (G1). |
| `phong_tieu_cuu` | `luyen_khi` | `loose-the-flock`, `under-the-wing` | 43.4 s, 0/5, 0 % | 8.0 s, 0/5, 0 % | Fires 9.0/7.2 (G0), 1.4/1.0 (G1). |
| `nhieu_tieu_yen` | `luyen_khi` | `loose-the-flock` | 33.0 s, 0/5, 0 % | 8.0 s, 0/5, 0 % | Fires 7.2 (G0), 1.4 (G1). |
| `tran_da_minh` | `luyen_khi` | `call-down`, `still-on-the-branch` | 52.2 s, 0/5, 0 % | 8.0 s, 0/5, 0 % | Fires 8.8/8.2 (G0), 1.0/1.0 (G1). |
| `que_hoang_oanh` | `luyen_khi` | `call-down`, `still-on-the-branch` | 52.2 s, 0/5, 0 % | 8.0 s, 0/5, 0 % | Fires 8.8/8.2 (G0), 1.0/1.0 (G1). |
| `kieu_thuy_nhi` | `luyen_khi` | `call-down`, `still-on-the-branch` | 52.2 s, 0/5, 0 % | 8.0 s, 0/5, 0 % | Fires 8.8/8.2 (G0), 1.0/1.0 (G1). |
| `ma_tin_phi` | `luyen_khi` | `call-down`, `still-on-the-branch` | 52.2 s, 0/5, 0 % | 8.0 s, 0/5, 0 % | Fires 8.8/8.2 (G0), 1.0/1.0 (G1). |
| `khau_tinh_minh` | `luyen_khi` | `call-down`, `still-on-the-branch` | 52.2 s, 0/5, 0 % | 8.0 s, 0/5, 0 % | Fires 8.8/8.2 (G0), 1.0/1.0 (G1). |
| `o_tieu_sao` | `luyen_khi` | `call-down` | 46.7 s, 0/5, 0 % | 8.0 s, 0/5, 0 % | Fires 7.4 (G0), 1.0 (G1). |
| `hoan_truc_lung` | `luyen_khi` | `wire-snare-needle` | 47.8 s, 0/5, 0 % | 8.0 s, 0/5, 0 % | Fires 14.2 (G0), 2.0 (G1). |

CHECKPOINT DONE
