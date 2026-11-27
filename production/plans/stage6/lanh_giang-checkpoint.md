# Lãnh Giang Phái (`lanh_giang`): Stage 6 Checkpoint Review (2026-11-27)

Unanchored checkpoint review of `design/stage6-staging/lanh_giang/` against `design/world/depth/sects/lanh_giang.*`, `lanh_giang.md`, `production/plans/stage6/_brief-record.md`, `design/world/depth/DECISIONS-2026-11-25.md`, `DECISIONS-2026-11-26.md`, `tools/design/combat_sim/FIGHT-INPUT.md`, `design/arts/part-sect-bang_tam.json`, `design/world/depth/effects/bang_tam.effects.json`, and `production/plans/stage6/bang_tam-review.md`.

---

## 1. Ranked Findings

**0 MUST-FIX, 1 SHOULD, 1 NIT — SHOULD finding fixed and re-verified.**

1. **SHOULD (FIXED) — `design/stage6-staging/lanh_giang/effects/lanh_giang.effects.json` (`Answers Twice`)**
   - **What was wrong:** Unlike `The Line Is Patient` (which carried an explicit `"approx"` note), `Answers Twice` omitted `"approx"` even though it adapts two clauses of the depth rule (`lanh_giang.items.json` / `sets-lanh_giang.json`: *"while you sit, your ward gains 2 % of its value each second; when a foe breaks it, your next counter art fires twice"*):
     1. `eff:Answers Twice grow` uses `ward_grow {of: "hp", share: 0.02}` (`2 %` of max HP/s, creating a stance ward if absent) instead of `of: "peak"` because Bồ Tọa Tuyết's kit (`lone-line-sitting-canon` + `returning-wake-verse`) has no art that creates a stance ward (`sward_peak` would remain `0` forever).
     2. `eff:Answers Twice reply` filters `tags: ["counter", "seal"]` instead of `["counter"]` because no art in the library carries `"counter"` while Bồ's counter art (`backwash-seal`) carries `"seal"` (and a `0 c` `seal` art would consume `answers_twice_ready` without echoing a hit).
   - **Fix applied:** Added `"approx"` to `Answers Twice` in `design/stage6-staging/lanh_giang/effects/lanh_giang.effects.json` so `fight.py` and `BuildFileCompiler` surface these engine approximations in `unmodelled`.

2. **NIT (informational, no edit) — `design/world/depth/sects/lanh_giang.cast.json` (`bo_toa_tuyet.build.tree.targets_note`)**
   - `spatial_words_check.py --sect lanh_giang --depth` flags `"Still"` in `bo_toa_tuyet`'s commentary field `build.tree.targets_note` (`"The Black Abyss pool, Still Water's overflow into health..."`, naming the Đạo Đồ cluster *Still Water*) as `rename`, and `5` `soft` tie/concept occurrences of `"beside"`. `0` non-soft hits appear in rule fields; left untouched.

---

## 2. Specific Audits & Parity Verification

- **`landing-the-fish` (`e5` `qi_drained` -> `catch`):**
  - `auth-tech.json` `e5` used unbuilt `counter.add_amount`, `free_hit.amount`, and `qi_drained.source`. Staged `part-sect-lanh_giang.json` adapts this cleanly using existing engine words: `catch-bank` (`on: "qi_drained"`, no `filter`, verified no other art/Effect in `design/` or `assets/data/combat_effects.json` emits `qi_drained`) increments `catch` by `1`; `catch-landed` (`foe.qi_share >= 0.2`) and `catch-landed-dry` (`foe.qi_share < 0.2`) trigger on `hit_landed` (`filter: {"art_id": "landing-the-fish"}`), scaled by `own.counter.catch` (`per: 1`), firing `free_hit {c: 0.35 / 0.70, dtype: "elem", outside_budget: true}` and clearing `catch = 0`. Verified in `engine.py` and `effect_runner.gd` that `free_hit` runs as `kind="trigger"` so it does not re-trigger `hit_landed` on `art_id: "landing-the-fish"`, and triggering on `hit_landed` keeps `catch` unspent if the pull is evaded while benefiting from `The Line Is Patient`'s `1 ms` `acc: 500`.
- **`line-through-the-ice` (`ice_line` refresh) & `A Bite on the Line`:**
  - Both declare `{"id": "ice_line", "cap": 1, "each_for": 6.0}`. `line-through-ice-hook` (`on: "art_fired"`, `filter: {"art_id": "line-through-the-ice"}`) runs `set: 0` then `add: 1` sequentially inside one action list. Verified in `engine.py:1984-1996` and `effect_runner.gd:540-554` that `set: 0` clears any prior timestamp and `add: 1` sets `[t + 6000]`, expiring cleanly when `u > t` becomes false at `t + 6000`.
- **`sitting-in-the-snow` (Composed stance + `always` Cold reduction):**
  - Enters state `sitting-in-the-snow` (`tags: ["composed"]`, `mods: {"regen": 0.025}`) guarded by `own.state.sitting-in-the-snow < 1`, and applies `dampen_taken: 20` (`dtype: "cold"`) in an `always` record (`sitting-cold-ward`) gated on `own.state.sitting-in-the-snow >= 1` (no record-level `filter`, scope inside `mod`). Neither `undertow-litany` nor `returning-wake-verse` defines any `states`, so no holder has two stances.
- **`The Line Is Patient` (`leech_hp: 3` + `acc: 500`):**
  - `eff:The Line Is Patient leech` (`on: "always"`, `own.state.sitting-in-the-snow >= 1`) grants `leech_hp: 3` (half of `lg-ice-hook` `4 %` + `lg-lone-line` 2pc `2 %` = `6 %` linh lực leech, documented in `"approx"`).
  - `tick` (`add: 1`) and `arm` (`patient_sec >= 5` -> `patient_sec = 0`, `patient_sure = 1`) are ordered sequentially within the same Effect; `clear` resets `patient_sec = 0` when not sitting; `sure` (`art_fired`, `tags: ["hook"]`, `patient_sure >= 1`) applies `mod: {"acc": 500}` (`1 ms` window `t + 1` in both `engine.py:1844` and `effect_runner.gd:408`, matching `where-the-drop-falls` since `acc` reads with `ctx = None`) and sets `patient_sure = 0`.
  - Targeted probes on `lu_doc_dieu`: vs `evade_pct: 35` (`20` seeds): `25.1 s`, `20/20` wins, `41 %` HP (`68` `sure` fires) vs `28.1 s`, `20/20` wins, `29 %` HP without; vs `n_qi: 0.2` (`10` seeds): `9` `catch-landed-dry` fires (`0.70 c` payoff).
- **`Answers Twice` (`ward_grow` + `fire_art {which: "last"}`):**
  - Declares `answers_twice_ready` (`cap: 1`); `grow` pulses `ward_grow {share: 0.02, of: "hp"}` while sitting; `broken` arms `answers_twice_ready = 1` on `shield_broken`; `reply` triggers on `art_fired` (`tags: ["counter", "seal"]`), echoing `fire_art {which: "last", share: 1.0}` (verified both `engine.py:1107` and `fight.gd:1026` set `last_art` before raising `art_fired`) and clearing `answers_twice_ready = 0`.
- **Standalone compilation parity, multi-`mod`, `temp_mods`, events/pulses, uniqueness & cast fidelity:**
  - `3/3` Effects pass `engine.validate()` standalone with `0` undeclared counters and `0` state actions.
  - `0` multi-`mod` records without `"stack": true`; `0` `temp_mods` filtering on `"art_id"` or `"status"`; `0` `always` records with record-level `filter`; `0` `decay_per_pulse: 1`; `0` `set`+`add` cross-listener races.
  - `0` ID, Effect-name, or record-ID collisions against `assets/data/combat_effects.json`, committed `design/`, or any other staged directory under `design/stage6-staging/`.
  - `23/23` item modifier lines preserved verbatim; `5/5` unique (`sources: ["npc"]`, R6 `exception` on `lg-ice-hook`, `lg-snow-cape`, `lg-sitting-robe`, `lg-old-sitter-gourd`); `0` stand-ins across all `17` living cast members (`thuy >= 40` on all); `0` beasts.

---

## 3. Pending Words

None (`pending.json` absent; `0` pending words — `landing-the-fish` and all 3 Effects run on existing engine words).

---

## 4. Holder Table (after final edit)

### Linters & static checks (`DEPTH_STAGE=design/stage6-staging/lanh_giang`)
- `lint_techniques.py`: `checked 2 techniques, 0 findings` (`ice-fish-boat-breath`: `7.6 W of 8`, `lone-line-sitting-canon`: `15.5 W of 16`).
- `lint_arts.py`: `checked 4 arts in 1 files, 0 findings`.
- `lint_items.py`: `checked 5 items, 22 bases, 9 common arts, 0 findings` (`unique 5 of 5`, R6 `exception` on 4 items).
- `spatial_words_check.py --sect lanh_giang --depth`: `0` non-soft rule-field hits (`1` commentary `rename`, `5` `soft`).

### `sect_fight.py lanh_giang` (`--seeds 5` at gap 0; `--gap 1` default 20 seeds; `0` `REFUSED`)

| Holder | Realm | Arts (gap 0 fires) | Gap 0 (`mean_s`, `wins`, `hp_left`) | Gap 1 (`mean_s`, `wins`, `hp_left`, 20 seeds) | Effects (with vs without, runs G0 / G1) |
|---|---|---|---|---|---|
| `lu_doc_dieu` | `truc_co` | `line-through-the-ice` (2.8), `sitting-in-the-snow` (1.0), `landing-the-fish` (3.4), `seep-through-palm` (7.4), `marrow-to-dew` (3.0), `drag-of-the-deep` (4.8) | `19.3 s`, `5/5`, `56%` | `12.4 s`, `0/20`, `0%` (fires `1.9/1.0/2.0/4.0/1.9/2.9`) | `A Bite on the Line`: `19.3s 56%` vs `22.8s 47%` (`68` / `139`); `The Line Is Patient`: `19.3s 56%` vs `19.3s 53%` (`77` / `179`) |
| `bo_toa_tuyet` | `ket_dan` | `line-through-the-ice` (4.0), `sitting-in-the-snow` (1.0), `landing-the-fish` (5.0), `backwash-seal` (15.4) | `27.0 s`, `5/5`, `96%` | `16.1 s`, `0/20`, `0%` (fires `2.0/1.0/3.0/9.0`) | `Answers Twice`: `27.0s 96%` vs `29.2s 59%` (`138` / `666`) |
| `man_tinh_ba` | `truc_co` | `line-through-the-ice` (4.2), `sitting-in-the-snow` (1.0), `landing-the-fish` (5.2), `seep-through-palm` (10.6), `marrow-to-dew` (4.8) | `27.1 s`, `5/5`, `28%` | `11.2 s`, `0/20`, `0%` (fires `1.6/1.0/1.8/3.8/1.6`) | — |
| `su_pha_bang` | `truc_co` | `line-through-the-ice` (5.4), `sitting-in-the-snow` (1.0), `seep-through-palm` (14.0), `marrow-to-dew` (6.4) | `34.5 s`, `5/5`, `12%` | `11.3 s`, `0/20`, `0%` (fires `1.8/1.0/3.8/1.8`) | — |
| `than_vong_giang` | `truc_co` | `line-through-the-ice` (5.4), `sitting-in-the-snow` (1.0), `seep-through-palm` (13.8) | `34.2 s`, `5/5`, `41%` | `9.0 s`, `0/20`, `0%` (fires `1.1/1.0/3.1`) | — |
| `phuong_lo_hoa`, `tien_ngan_lan` | `truc_co` | `line-through-the-ice` (8.8), `sitting-in-the-snow` (1.0) | `59.8 s`, `0/5`, `0%` | `9.9 s`, `0/20`, `0%` (fires `1.0/1.0`) | — |
| `bui_truong_tuyen`, `lieu_thoa_nhi`, `ngai_han_tich` | `luyen_khi` | `line-through-the-ice` (8.0), `sitting-in-the-snow` (1.0) | `57.0 s`, `0/5`, `0%` | `8.8 s`, `0/20`, `0%` (fires `1.0/1.0`) | — |
| `cu_bang_ngu`, `mach_tieu_dieu`, `hong_lap_nhi`, `phuong_diep_chu`, `la_to_lan`, `ma_han_chu`, `chiem_dong_nhi` | `luyen_khi` | `oar-stroke` (17.4) | `51.4 s`, `1/5`, `0%` | `8.1 s`, `0/20`, `0%` (fires `2.0`) | — |

CHECKPOINT DONE
