# Stage 6 Checkpoint Review — `tam_kiem` (Tầm Kiếm Đường)

Unanchored review of `design/stage6-staging/tam_kiem/` and `design/world/depth/sects/tam_kiem.*` against `production/plans/stage6/_brief-review.md`, `_brief-record.md`, `DECISIONS-2026-11-25.md`, `DECISIONS-2026-11-26.md`, and `tools/design/combat_sim/FIGHT-INPUT.md` (verified against `tools/design/combat_sim/engine.py` and GDScript `src/gameplay/combat/fight/effect_compiler.gd`, `effect_runner.gd`, `build_file_compiler.gd`, `fighter_profile_loader.gd`, `defence_path.gd`, and `fight.gd`).

## Ranked Findings

No **MUST-FIX** or **SHOULD** defects found in `design/stage6-staging/tam_kiem/` or `design/world/depth/sects/tam_kiem.*`.

1. **[NIT — KEPT] `the-silent-place` (`cd: 5.0`) aligns with the basic-attack pulse (`1.0 s`) on `tieu_van_phong` in `sect_fight.py`**
   - **File / Record:** `design/stage6-staging/tam_kiem/arts/part-sect-tam_kiem.json` (`the-silent-place`, records `silent-place-arm`, `silent-place-ignore`, `silent-place-spend`).
   - **Observation:** In `sect_fight.py` (which does not fold in `art_speed_pct` beyond techniques/items, and `tieu_van_phong` has `0` `art_speed_pct`), `the-silent-place` (`cooldown: 5.0`) fires at `5000, 10000, 15000, 20000 ms`, immediately before `basic_ready` at those exact integer seconds in `act()`. Consequently, `silent_place` (`bypass: 0.35`, `pen: 80`) is spent on the same-millisecond `basic` hit (`4/4` in the seed-1 parity probe) rather than on `ask` or `the-blade-answers`.
   - **Assessment:** Kept as staged. Both `tam_kiem.techniques.json` (`"the holder's next hit ignores part of the ward"`) and `part-sect-tam_kiem.json` (`"your next hit that lands"`) explicitly specify the next hit (not next art), and in full builds with Đạo Đồ speed or `Slowed Time` the timers diverge naturally.

2. **[NIT — KEPT] `tam_kiem-review.md` undercounts the living cast as `10/10` instead of `17` (`14` in `sect_fight.py`)**
   - **File / Record:** `production/plans/stage6/tam_kiem-review.md` (`Status`, `§G`, `§I`).
   - **Observation:** `tam_kiem.cast.json` holds `10` living + `1` dead (`tieu_kien_quang`) and `tam_kiem.5.cast.json` holds `7` more living cast members (`17` living total). `sect_fight.py` runs `14` holders (the `3` `the_tu` using only `mountain-bone-body-art` — `nguu_pha_son`, `mong_thach_sinh`, `van_kien_boi` — have no `owner`-tagged technique or named item, so `sect_fight.py` skips them). Corrected in the holder table below.

## Explicit Parity, Uniqueness, and Pitfall Checks

- **Standalone Effect compilation (`EffectCompiler` / `engine.validate`):**
  - `The Second Duel` (`design/stage6-staging/tam_kiem/effects/tam_kiem.effects.json`): declares `second_duel_hit` in its own `counters`; `eff:The Second Duel hit` (`on: "was_hit"`) gates on `event.amount > 0` and `own.counter.second_duel_hit == 0`; `eff:The Second Duel dmg` (`on: "always"`) puts `tags: ["sword"]` inside `mod` (`dmg_more: 0.1`).
  - `The Answer` (`design/stage6-staging/tam_kiem/effects/tam_kiem.effects.json`): declares `ask_mark` in its own `counters`; `eff:The Answer crit` (`on: "always"`, scaled by `own.counter.ask_mark`) and `eff:The Answer bypass` (`on: "always"`, guarded on `own.counter.ask_mark >= 5`) are separate single-`mod` records (`no multi-mod clobber`) with `"art_id": "the-blade-answers"` inside `mod`. Verified in `engine.py` (`mod()`, `match()`) and `effect_runner.gd` (`mod()`, `matches()`, `_EQ_KEYS`): `on: "always"` preserves and checks `art_id` (unlike `temp_mods`).
  - All `4` arts in `design/stage6-staging/tam_kiem/arts/part-sect-tam_kiem.json` (`where-it-will-be`, `ask`, `the-blade-answers`, `the-silent-place`) declare every counter they read/write locally (`ask_mark`, `silent_place`) and pass both `engine.validate` and `EffectCompiler` field/vocabulary checks.
- **No `temp_mods` `art_id` or multi-`mod` clobber:**
  - `where-it-will-be-sure` (`on: "art_fired"`, `mod: {"acc": 100}`, `for: 0` -> `until = t + 1 ms`) and `blade-answers-pierce` (`on: "art_fired"`, `mod: {"pierce": 8}`, `for: 0` -> `until = t + 1 ms`) have no `art_id` inside `mod` (matching `engine.py` / `fight.gd` reading `acc` and `pierce` with `ctx = None`), have 1 `mod` per record, and run alongside `empower` (`c_mult: 1.6`) and `blade-answers-dmg` (`on: "always"`, `art_id: "the-blade-answers"`).
  - Verified `where-it-will-be-sure` + `empower` both fire (`4/4` on `lu_hoi_lo`, seed 1); verified `ask-place-mark` (`15`), `blade-answers-pierce` (`3`), `blade-answers-spend` (`3`), `silent-place-arm` (`4`), `silent-place-spend` (`4`) on `tieu_van_phong` (seed 1); verified `The Answer` against a shielded `truc_co` typical foe (`shields: [{size: 1.0, standing: true}]`): `36.00 s` win (`32.12 %` HP left) with `The Answer` vs `45.00 s` loss without it.
- **Stances & cross-technique builds:**
  - `tam_kiem` introduces `0` stances. Dual-method holders `sai_mo_kiem` (`flurry` from `afterimage-sword-canon`), `tich_lang_tung`, and `cat_linh_hanh` (`mountain-root` from `mountain-bone-body-art`) each hold at most `1` stance (`0` stance conflicts).
- **Depth faithfulness & design rules:**
  - All `3` techniques (`tracker-sword-primer`, `asking-blade-canon`, `seal-listening-art`), `4` arts, `3` items (`tk-asking-blade`, `tk-evening-sword`, `tk-map-coat`, all `sources: ["npc"]`, `unique: true`, R6 `exception`), and `1` set (`tk-map-wall`) match `design/world/depth/sects/tam_kiem.md`, `tam_kiem.techniques.json`, and `tam_kiem.items.json`. No environment conditions, no spatial fight rules, no hard stack caps, and unpriced `catalogue-sect-tam_kiem.json`.
  - Uniqueness check: `0` ID or Effect name collisions across `assets/data/combat_effects.json` (`375` entries), `design/`, and `design/stage6-staging/`.

## Pending Words

None (`pending.json` absent; `0` pending engine words).

## Verification & Holder Table

### Linters & Checkers (`DEPTH_STAGE=C:\Users\xphuo\IdeaProjects\my-game\design\stage6-staging\tam_kiem`)
- `spatial_words_check.py --sect tam_kiem`: `0` hits in staged files, `tam_kiem.techniques.json`, `tam_kiem.items.json` (`1` pre-existing `soft` `beside` in `tam_kiem.cast.json` tie note).
- `lint_techniques.py design/stage6-staging/tam_kiem/techniques/catalogue-sect-tam_kiem.json`: `checked 3 techniques, 0 findings` (`8.0 W of 8`, `16.0 W of 16`, `15.8 W of 16`).
- `lint_arts.py design/stage6-staging/tam_kiem/arts/part-sect-tam_kiem.json`: `checked 4 arts in 1 files, 0 findings`.
- `lint_items.py design/stage6-staging/tam_kiem/items/catalogue-sect-tam_kiem.json`: `checked 3 items, 22 bases, 9 common arts, 0 findings` (`unique 3 of 3`).
- `depth_gap.py --sect tam_kiem` & `depth_check.py --sect tam_kiem --quiet`: `findings: none`, `stand_ins 0`, `beasts 0`, `unknown_ids 0`, `engine_words 0`, `wishes_open 0`.
- `sect_fight.py tam_kiem --seeds 5 --gap 0` & `--gap 1`: **14/14 holders tested, 0 `REFUSED`**, every slotted art fires (remaining `3/17` living cast members — `nguu_pha_son`, `mong_thach_sinh`, `van_kien_boi` — use only shared `mountain-bone-body-art` and have no `tam_kiem` method or named item).

| Holder | Realm | Slotted arts (all fired) | Gap 0 (`mean_s`, wins, HP) | Gap 1 (`mean_s`, wins, HP) | Effect checks (`with` vs `without`, runs) |
|---|---|---|---|---|---|
| `tieu_van_phong` | `truc_co` | `ask` (19.0 / 5.0), `the-blade-answers` (2.8 / 1.0), `the-silent-place` (5.0 / 1.0) | 30.5 s, 5/5, 40 % | 8.0 s, 0/5, 0 % | `The Answer`: 30.5 s 40 % vs 34.9 s 28 % (`always` only, `runs 0`; probe vs shielded typical: 36.0 s win vs 45.0 s loss) |
| `sai_mo_kiem` | `ket_dan` | `ask` (9.6 / 6.4), `the-blade-answers` (1.4 / 1.0), `flurry-stance` (2.8 / 2.2), `phantom-sword` (4.2 / 3.0), `triple-draw` (3.6 / 3.0), `flying-sword` (1.0 / 1.0) | 11.5 s, 5/5, 81 % | 8.8 s, 0/5, 0 % | `The Second Duel`: 11.5 s 81 % vs 11.9 s 81 % (`runs 5` at both gaps) |
| `cat_linh_hanh` | `truc_co` | `ask` (17.6 / 6.6), `the-blade-answers` (3.0 / 1.0), `mountain-root-stance` (3.6 / 1.6) | 25.8 s, 5/5, 98 % | 15.4 s, 0/5, 0 % | — |
| `tich_lang_tung` | `truc_co` | `ask` (11.8 / 6.4), `the-blade-answers` (2.0 / 1.0), `mountain-root-stance` (2.4 / 1.4), `bone-turning-palm` (3.8 / 1.4) | 17.2 s, 5/5, 94 % | 15.0 s, 0/5, 0 % | — |
| `thang_phuc_tuyet` | `truc_co` | `ask` (18.2 / 5.0), `the-blade-answers` (2.8 / 1.0), `frost-breath-palm` (8.0 / 2.0) | 26.9 s, 5/5, 48 % | 8.0 s, 0/5, 0 % | — |
| `lac_tam_chan` | `truc_co` | `ask` (22.8 / 5.0), `the-blade-answers` (3.6 / 1.0) | 33.6 s, 5/5, 38 % | 8.0 s, 0/5, 0 % | — |
| `ngo_han_dac`, `quach_do_anh`, `tieu_hoe_sinh` (3) | `luyen_khi` | `ask` (20.6 / 5.0), `the-blade-answers` (2.8 / 0.8) | 34.4 s, 4/5, 25 % | 8.0 s, 0/5, 0 % | — |
| `hach_tung` | `luyen_khi` | `ask` (20.6 / 5.0) | 29.7 s, 5/5, 39 % | 8.0 s, 0/5, 0 % | — |
| `lu_hoi_lo` | `truc_co` | `where-it-will-be` (15.8 / 2.0) | 49.4 s, 0/5, 0 % | 8.0 s, 0/5, 0 % | Probe seed 1: `where-it-will-be-sure` 4, `empower` 4 |
| `au_da_loc`, `duong_tieu_kiem`, `thai_truong_thanh` (3) | `luyen_khi` | `where-it-will-be` (12.2 / 2.0) | 40.4 s, 0/5, 0 % | 8.0 s, 0/5, 0 % | — |

CHECKPOINT DONE
