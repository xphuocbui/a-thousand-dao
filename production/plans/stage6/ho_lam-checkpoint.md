# Hộ Lâm Đường (`ho_lam`): Stage 6 Checkpoint Review (2026-11-27, headless, decisions auto-accepted)

Unanchored review of `design/stage6-staging/ho_lam/` against `design/world/depth/sects/ho_lam.*`, `production/plans/stage6/ho_lam.md`, `production/plans/stage6/ho_lam-review.md`, `production/plans/stage6/ho_lam.done`, `production/plans/stage6/_brief-record.md`, `DECISIONS-2026-11-25.md`, `DECISIONS-2026-11-26.md`, `tools/design/combat_sim/FIGHT-INPUT.md`, `assets/data/combat_engine.json`, `assets/data/combat_effects.json`, and both engines (`tools/design/combat_sim/engine.py`, `src/gameplay/combat/fight/*.gd`).

---

## 1. Ranked Findings

1. **MUST-FIX — `design/stage6-staging/ho_lam/arts/part-sect-ho_lam.json` :: `bark-closes`**
   - **What was wrong:** `bark-closes` guarded its stance entry (`bark-closes-enter`) on `own.state.any == 0` and defined only `"bark-closes"`. All 4 living holders of `night-beside-the-tree` (`luc_thanh_sam`, `lai_hoanh_chi`, `mi_tuc_thu`, `thieu_tung_lam`) also hold `rooted-form` (`verdant-cycle-scripture`), which sits in an earlier slot with a shorter cooldown (`6.0 s` vs `8.0 s`) and enters `"rooted"` first. As a result, `own.state.any` was always `1` when `bark-closes` fired, so `bark-closes` **never entered a `composed` stance on any of its 4 holders** (violating `"you cannot be Pressing"`). Conversely, if `bark-closes` fired while un-stanced before `rooted-form`, `rooted-toggle` would overwrite `"bark-closes"` with `"rooted"`.
   - **Fix applied:** Added `"rooted"` and the combined `"rooted-bark"` (`tags: ["composed"]`, `mods: {hregen: 0.3, healing: 25, dampen_taken: 10, art_speed: -20}`, `suppress: ["thorn-rain"]`) to `bark-closes.states`, declared `"seed"` in `bark-closes.counters`, duplicated `rooted-creep` (`wood` stacks + `seed`) and `rooted-sap` onto `own.state.rooted-bark == 1` (ordered before stance exit on `pulse`), added `bark-closes-enter-rooted` / `bark-closes-keep-rooted` / `bark-closes-keep-plain`, and updated `bark-closes-exit-rooted` to restore `"rooted"` at `bark_sec == 0`. Verified on `luc_thanh_sam` (`bark-closes-enter-rooted: 5`, `bark-closes-exit-rooted: 5`, `rooted-bark-creep: 20`, `rooted-bark-sap: 20`) and standalone (`bark-closes-enter: 32`, `bark-closes-exit: 29`).

2. **SHOULD — `design/stage6-staging/ho_lam/arts/part-sect-ho_lam.json` :: `the-forest-listens`**
   - **What was wrong:**
     (a) `forest-listens-press-hit` (`was_hit`, `kind: art`), `forest-listens-press-evade` (`evaded`, `kind: art`), and `forest-listens-press-foe-evade` (`was_evaded`) each used independent `limit: {"per_pulse": 1}`. If a foe both struck with an art and evaded in the same pulse (or mixed hits and evades on split hits), the foe took 2 Wood stacks in 1 s instead of 1 (`"each second the foe pressed while it lasts it takes 1 Wood stack"`). Additionally, a foe firing a non-damaging `movement` art at a non-integer timestamp would not trigger `was_hit`/`evaded`/`was_evaded`.
     (b) `forest-listens-sure` filtered only `not_art_id: "the-forest-listens"` and checked `own.since_act <= 0`; if a stance art (`rooted-form`, `bark-closes`) fired at the same millisecond as an evade or prior damaging art, `own.since_act <= 0` would still hold and spend `forest_listens_sure` on the stance art.
   - **Fix applied:** Added `forest_listens_pulse` (`cap: 1`) to enforce at most 1 Wood stack per pulse across `was_hit` (`kind: art`, intentionally without `event.amount > 0` because a warded/blocked enemy art is still pressing), `evaded` (`kind: art`), `was_evaded`, and a `pulse` fallback (`own.foe_pressed >= 1`) before `forest-listens-pulse-reset` and `forest-listens-tick`. Added `"not_tags": ["stance"]` to `forest-listens-sure`. Verified with `en_ev.evade = 0.4` (`press-foe-evade: 60`, `press-hit: 64`, `pulse-reset: 122`).

3. **SHOULD — `design/stage6-staging/ho_lam/arts/part-sect-ho_lam.json` :: `the-flood-takes-it`**
   - **What was wrong:** `flood-streak-up` matched `"kind": "art", "element": "water"` while `flood-streak-reset` matched `"kind": "art", "not_tags": ["water"]`. Any Water-element art lacking the `"water"` tag (e.g. `bang_tam`'s `frost-breath-palm`, which has `element: "water", tags: ["cold", "palm"]`) incremented `water_streak` and was immediately wiped to `0` by `flood-streak-reset` on the same hit.
   - **Fix applied:** Added `water_hit_ok` (`cap: 1`) and replaced the `not_tags` reset with `flood-streak-mark-clear` (`kind: art`), `flood-streak-mark-water` (`kind: art, element: water`), and `flood-streak-reset` (`kind: art`, `if: own.counter.water_hit_ok == 0`). Verified with `frost-breath-palm` + `the-flood-takes-it` (`flood-streak-up: 113`, `flood-streak-break: 30` across 5 seeds).

---

## 2. Specific Audits & Pitfall Checklist Verification

- **`log-on-the-current`:** `c_art: 3.0`, `cost_share: 0.05`, `cd: 5.0`, `empower` gated on `own.buff.water >= 1` (`split: [1.0, 0.5]`, `x1.41` lint), `timer {side: foe, which: next, by: 0.5}` on `hit_landed` (`per_pulse: 1`). Verified `deep-lake-stance` + `log-on-the-current` empower probe (`empowered: 2.8`/fight, `log-current-delay: 29`).
- **`One Stroke` (`hlm-asking-axe`):** `own.composed >= 1` + `one_stroke_done == 0` grants `+0.3 dmg_more` on the first Composed hit each fight (`t = 2.0 s` basic attack on `luc_thanh_sam`, `5` runs). Reading as first Composed hit is faithful because `t = 0` starts with `composed == 0` and basic attacks fire at `t = 1.0 s`.
- **`The Tree Did Not Answer` (`hlm-first-light-heart`):** `down` (`per_fight: 1`) runs `refuse_down {hp_share: 0.1}` and sets `heartwood_spent = 1`; `always` applies `mod {healing: -12, hregen_inc: -36}` (`hregen_inc` confirmed in `combat_engine.json` `MOD_KEYS` and both engines), cancelling only the pendant's own `+12 % healing_pct` and `+36 % health_regen_inc_pct`. Verified at `--gap 1` (`18.0 s` vs `16.0 s`, `runs 5`).
- **`The Forest Closes` (`hlm-first-light` 3-pc):** Triggers on `art_fired` for `mountain-cleave` (`phu` base common art), sets `forest_closes_sec = 6`, applies `no_evade: 1` while `>= 1`, heals `2 %` HP and decrements on `pulse` (6 pulses total), and lays 1 Wood debuff (`8 s`) on `was_hit` (`per_pulse: 2`). `runs 0` in `sect_fight.py` because `luc_thanh_sam`'s 2 techniques fill all 6 art slots; verified via `luc_axe_gap0` probe (`brace: 10`, `regen: 50`, `thorns: 75`).
- **Standalone compilation, multi-`mod`, `temp_mods`, `always` filters, collisions, spatial check:**
  - All `3/3` Effects in `ho_lam.effects.json` declare all their own counters (`one_stroke_done`, `heartwood_spent`, `forest_closes_sec`), define no undeclared states, and pass `engine.validate()` + `E.fight()` standalone.
  - All `4/4` arts in `part-sect-ho_lam.json` pass `E.validate()` + `E.fight()` standalone.
  - `0` multi-`mod` records without `"stack": true`; `0` `temp_mods` filtering on `"art_id"` or `"status"`; `0` `always` records with record-level `filter`; `0` `decay_per_pulse: 1`; `0` `slowed_time` `cap: 1` overwrites.
  - `0` ID or Effect-name collisions against `assets/data/combat_effects.json`, committed `design/`, or `design/stage6-staging/`.
  - `spatial_words_check.py --sect ho_lam`: `0` rule-field hits in staged files (`ho_lam` depth hits are non-rule prose/metadata only).
  - All `18` living cast members hold real techniques matching their roots (`0` stand-ins, `0` beasts).

---

## 3. Pending Words

None (`pending.json` absent; all 4 arts and 3 Effects run on existing engine vocabulary).

---

## 4. Holder Table (after fixes)

### Linters & Checks (`DEPTH_STAGE=C:\Users\xphuo\IdeaProjects\my-game\design\stage6-staging\ho_lam`)
- `spatial_words_check.py --sect ho_lam`: `0` staged hits (`depth 9` prose/metadata only).
- `lint_techniques.py`: `checked 3 techniques, 0 findings` (`raft-and-root-primer` `7.7 W of 8`, `night-beside-the-tree` `10.4 W of 16`, `spring-flood-raft-art` `8.5 W of 16`).
- `lint_arts.py`: `checked 4 arts in 1 files, 0 findings` (`log-on-the-current empower 1: x1.41 of the lint, gated`).
- `lint_items.py`: `checked 4 items, 22 bases, 9 common arts, 0 findings` (`4 of 4` unique; R6 `exception` on `hlm-asking-axe` and `hlm-white-wax-robe`).

### `sect_fight.py ho_lam --seeds 5` (`--gap 0` and `--gap 1`, `0 REFUSED`)

| Holder | Realm | Arts (fires/fight @ gap 0) | Gap 0 (`mean_s`, `wins`, `hp_left`) | Gap 1 (`mean_s`, `wins`, `hp_left`) | Effects (`with` vs `without`, `runs`) |
|---|---|---|---|---|---|
| `luc_thanh_sam` | `ket_dan` | `seed-of-spring` (3.0), `rooted-form` (2.0), `second-spring` (0.0), `harvest-bloom` (2.0), `the-forest-listens` (1.0), `bark-closes` (1.0) | `15.7 s`, `5/5`, `100%` | `18.0 s`, `0/5`, `0%` | `One Stroke`: `15.7 s 100%` vs `15.7 s 100%` (`5`), gap 1 `18.0 s` vs `18.0 s` (`5`); `The Tree Did Not Answer`: `0` @ gap 0 (100% HP), gap 1 `18.0 s` vs `16.0 s` (`5`); `The Forest Closes`: `0` (`mountain-cleave` unslotted; probe `brace 10, regen 50, thorns 75`) |
| `dang_bich_luu` | `ket_dan` | `seed-of-spring` (2.0), `rooted-form` (1.6), `second-spring` (0.2), `harvest-bloom` (1.2), `swelling-tide-palm` (2.6), `the-flood-takes-it` (4.6) | `11.6 s`, `5/5`, `100%` | `14.9 s`, `0/5`, `0%` | — |
| `do_xuan_trieu` | `truc_co` | `seed-of-spring` (2.2), `rooted-form` (2.0), `second-spring` (0.2), `swelling-tide-palm` (3.0), `the-flood-takes-it` (6.0) | `15.2 s`, `5/5`, `100%` | `11.7 s`, `0/5`, `0%` | — |
| `lai_hoanh_chi` | `truc_co` | `seed-of-spring` (3.0), `rooted-form` (2.0), `second-spring` (0.2), `harvest-bloom` (2.0), `the-forest-listens` (1.0), `bark-closes` (1.0) | `15.6 s`, `5/5`, `100%` | `14.4 s`, `0/5`, `0%` | — |
| `mi_tuc_thu` | `truc_co` | `seed-of-spring` (3.0), `rooted-form` (2.0), `second-spring` (0.2), `harvest-bloom` (2.0), `the-forest-listens` (1.0), `bark-closes` (1.0) | `15.6 s`, `5/5`, `100%` | `14.4 s`, `0/5`, `0%` | — |
| `thieu_tung_lam` | `truc_co` | `seed-of-spring` (4.0), `rooted-form` (3.4), `second-spring` (0.2), `the-forest-listens` (2.4), `bark-closes` (2.4) | `23.9 s`, `5/5`, `99%` | `14.0 s`, `0/5`, `0%` | — |
| `sam_lang_nhi` | `luyen_khi` | `rooted-form` (7.2), `log-on-the-current` (7.8) | `55.0 s`, `5/5`, `90%` | `15.0 s`, `0/5`, `0%` | — |
| `tac_ha_thang` | `luyen_khi` | `rooted-form` (7.2), `log-on-the-current` (7.8) | `55.0 s`, `5/5`, `90%` | `15.0 s`, `0/5`, `0%` | — |
| `truc_linh_lo` | `luyen_khi` | `rooted-form` (7.2), `log-on-the-current` (7.8) | `55.0 s`, `5/5`, `90%` | `15.0 s`, `0/5`, `0%` | — |
| `binh_thiet_phu` | `luyen_khi` | `rooted-form` (8.8) | `65.0 s`, `5/5`, `57%` | `15.2 s`, `0/5`, `0%` | — |
| `to_mieu_nhi` | `luyen_khi` | `rooted-form` (8.8) | `64.8 s`, `5/5`, `59%` | `15.2 s`, `0/5`, `0%` | — |
| `phan_tieu_ho` | `luyen_khi` | `rooted-form` (8.8) | `65.0 s`, `5/5`, `57%` | `15.2 s`, `0/5`, `0%` | — |
| `phu_hau_tho` | `luyen_khi` | `seed-of-spring` (5.0), `furrow-palm` (6.2) | `25.8 s`, `5/5`, `100%` | `8.1 s`, `0/5`, `0%` | — |

CHECKPOINT DONE
