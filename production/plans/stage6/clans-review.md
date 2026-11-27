# Stage 6 Record Pass Review — `clans` (Batch b05)

## Summary

- **Owner**: `clans` (`design/world/depth/people/clans.*`, major non-sect people group: Tiêu, Ôn, Tạ, Lục, Hỗ, Đới).
- **Staged totals**: `5` techniques, `6` authored arts, `17` unique items (`12` with R6 exception), `6` sets, `12` Effects (`6` item + `6` set), `0` pending engine words, `46` stand-ins replaced (`23` in `clans.cast.json`, `23` in `clans.2.cast.json`).
- **Validation**:
  - `lint_arts.py` (`part-sect-clans.json`): `6` arts, **0 findings**.
  - `lint_techniques.py` (`catalogue-sect-clans.json`): `5` techniques (`main/0`: 3, `main/1`: 2), **0 findings**.
  - `lint_items.py` (`items/catalogue-sect-clans.json`): `17` items, all within W budget, **0 findings**.
  - Standalone Effect parity (`engine.validate()`): **12/12** pass with `errors: []`.
  - `sect_fight.py clans --seeds 5 --gap 0` & `--gap 1`: all `6` new arts fire on their real holders; `10/12` Effects trigger naturally in `--gap 0`/`--gap 1`; the remaining `2` (`The Swallow Returns to Its Nest` 3pc split across two holders by design, and `Pulled Tight` needing item art `needle-rain`) pass in targeted probes.
  - `depth_check.py`: **findings: none** (`1891` people).
  - `depth_gap.py --sect clans`: `stand_ins: 0`, `unknown_ids: 0`, `cross_owner: 0`, `ties_unmapped: 0`, `engine_words: 0`, `wishes_open: 0`.
  - `stage6_merge.py clans --check`: **0 failure(s)** across 5 staged moves.

---

## A. Auto-accepted decisions

1. **Spatial -> non-spatial rewrites (standing rule: non-spatial 1v1 combat)**:
   - `pillar-in-the-current`: "pushes the attacker back on the next three hits" rewritten as `timer {side: "foe", which: "next", by: 0.5}` (delays the foe's next ready art by 0.5 s on each of the next 3 hits before exiting stance). Reason: combat is non-spatial.
   - `cl-first-sheaf-bell` (`The Harvest Bell`): "you and your allies" narrowed to "you" (2% max HP pulse for 4 s on self). Reason: simulator runs 1v1 duels with no allied targets.
   - `cl-locust-shade` (`He Waited`): "hold Still and never move" mapped to `own.composed >= 1` (`wait_still` +1/pulse, threshold 10); "falls off in 5 s if you move" mapped to decaying 1 `wait_ward` stack per pulse when `own.composed == 0` via fractional `scale: {"read": "own.counter.wait_ward", "per": 5, "floor": false}`. Reason: non-spatial combat expresses stillness via `Composed`.
   - `cl-twin-bridges` (`Pillar in the Flood`): "cannot be moved" mapped to `mod {delay_immune: 1, unmoved: 1}` while `own.hp_share > 0.5` (combined in a single `mod` record to prevent multi-`mod` clobber). Reason: standard non-spatial immovable/anti-delay flags.
2. **Item Effect approximations using existing DSL words (no new engine words)**:
   - `Under the Locust` (`cl-old-locust-seal`): `ward_pct: 20` on `always` (`time <= 10`) lacks an element scope in `MOD_KEYS`, paired with `art_fired` `ward_grow` (`0.015 HP`) filtered on `water`/`wood` ward arts (`time <= 10`). Reason: avoids inventing single-use element-scoped `ward_pct`.
   - `The Toll` (`cl-keystone-toll-seal`) & `Pillar in the Flood` (`cl-twin-bridges`): `burn_qi` scales on `of: "qi_max"` (`0.01` and `0.03` respectively, `to_self: 1.0`) guarded by `event.amount > 0` on `blocked`. Reason: engine `burn_qi` supports `"qi_max"` / `"base"` cleanly without current-qi scaling.
   - `The Swallow Returns` (`cl-swallow-hall-fan`): echoes `fire_art {which: "last", share: 0.4}` 3 pulses after the first `wood` + `quick` art (`swallow_wait` decremented 1/pulse). Reason: deterministic timer without dynamic art-ID lookup.
   - `Reading the Weather` (`cl-misty-wave-mirror`): `decoy {n: 1}` on `pulse` (`limit: {cooldown: 12}`). Reason: directly expresses foreseeing and avoiding one blow every 12 s.
   - `Leave With the Tide` (`cl-ho-fleet` 3pc): `mod {dampen_taken: 9900, for: 2}`, `gain_qi {share: 0.1}`, plus `tide_sure` granting `acc: 1000` until the next `hit_landed` (`kind: "art"`). Reason: models 2 s strike avoidance + next guaranteed art cleanly within existing DSL.
   - `Pulled Tight` (`cl-reeling-thread` 2pc): matches both `art_id: "needle-rain"` and `tags: ["needle"], not_art_id: "needle-rain"` at `foe.debuff.fire >= 6`, consuming all Fire debuff stacks via `consume` -> `free_hit {c: 0.114, dtype: "fire"}` (`0.019 * 6 s` remaining tick equivalent). Reason: standard detonation pattern.
3. **Rarity & R6 item exceptions**:
   - Assigned `"rarity": 4` to the 3 `grade: 3, kind: "treasure"` items (`cl-old-locust-seal`, `cl-keystone-toll-seal`, `cl-first-sheaf-bell`) to match `lint_items.py` rarity bounds for grade-3 uniques.
   - Applied R6 `"exception"` (`"world-depth signature item: its base's common art or ward until an authored one is ruled (review R6)"`) to all 12 items whose `base` has a common art/ward (`an`, `phien`, `chuong`, `ho_lo`, `dao_bao`, `thuan`, `giap`, `cham`), leaving `arts: []`. Omitted `exception` on the 5 `kinh`/`nhan`/`ngoc_boi` items.
4. **Non-clan cast stand-in replacements**:
   - Replaced all 46 stand-ins strictly following `clans.cast.json`, `clans.2.cast.json`, and `clans.md` ("Hỗ has none"; outside-clan wives use shared catalogue methods matching root element): Tiêu (8) -> `locust-shade-breathing`; Ôn (7) -> `twin-span-pillar-method`; Tạ (8) -> `returning-swallow-breath`; Lục (7) -> `seed-store-method`; Tống Thanh Miễu (`huyen_kim`, L5) -> `nine-temper-scripture`; Hỗ Thương Phạm & 5 `hoang_thuy` Hỗ (6) -> `still-moon-tide-scripture`; Mãn Tử Chi (`huyen_moc`, L5) -> `verdant-cycle-scripture`; Đới (8) -> `reeling-thread-breath`.
5. **`Shade of the Road` slot independence**:
   - Used counter `road_shade` (`cap: 5`) + `own.composed >= 1` check on `pulse` instead of occupying the single stance slot, so it coexists cleanly with stances (`Pillar`, `He Waited`, etc.).

---

## B. Pending words

- **None (`0` pending engine words)**. No `pending.json` needed or written.

---

## C. Techniques (`design/stage6-staging/clans/techniques/catalogue-sect-clans.json`)

| ID | Family | Tier | Kind | Elements | Layers | Passive W | Bonus | Unlocked Arts |
|---|---|---|---|---|---|---|---|---|
| `locust-shade-breathing` | Tiêu | 1 | `main` | `thuy`, `moc` | 9 | `15.6 / 16` | `linh_luc_pct +10` | `falling-locust-flowers` (L1), `shade-of-the-road` (L2) |
| `twin-span-pillar-method` | Ôn | 0 | `main` | `tho`, `moc` | 6 | `7.8 / 8` | — | `pillar-in-the-current` (L1) |
| `returning-swallow-breath` | Tạ | 1 | `main` | `moc`, `thuy` | 9 | `15.8 / 16` | `than_thuc_pct +10` | `swallows-return` (L1) |
| `seed-store-method` | Lục | 0 | `main` | `moc` | 6 | `8.0 / 8` | — | `opened-granary` (L1) |
| `reeling-thread-breath` | Đới | 0 | `main` | `hoa`, `tho` | 6 | `7.6 / 8` | — | `unbroken-thread` (L1) |

---

## D. Arts (`design/stage6-staging/clans/arts/part-sect-clans.json`)

| ID | Technique | Element | Role | Cooldown / Cost | Engine Implementation Summary |
|---|---|---|---|---|---|
| `falling-locust-flowers` | `locust-shade-breathing` | `wood` | `damage` | `5.0 s` / `3%` | 4x `0.25` split (`c=1.5`); if `own.debuff.fire == 0`, each hit heals `0.8% HP` (`3.2%` max) and grants 1 Wood buff (`8 s`, `per_firing: 1`). |
| `shade-of-the-road` | `locust-shade-breathing` | `water` | `ward` | `6.0 s` / `3%` | Raises `5% HP` ward and sets `road_shade = 5`; while `own.composed >= 1`, pulses `+2% HP` ward and decrements counter. |
| `pillar-in-the-current` | `twin-span-pillar-method` | `earth` | `ward` | `6.0 s` / `3%` | Stance `pillar-in-current` (`composed`, `block +40`) + `pillar_hits = 3`; next 3 `was_hit` delay foe next art `0.5 s` and exit stance on 3rd hit. Guarded until `pillar_hits < 1`. |
| `swallows-return` | `returning-swallow-breath` | `wood` | `damage` | `3.0 s` / `3%` | `c=1.7` strike + `debuff [1, 6.0]`; `hit_landed` (`per_firing: 1`) triggers `free_hit {c: 0.85, dtype: "chaos"}`. |
| `opened-granary` | `seed-store-method` | `wood` | `heal` | `8.0 s` / `6%` | Once/fight (`hp_share <= 0.75` or `time >= 10`): `c_heal 2.2`, `qi_restore 0.15`, `buff [2, 8.0]`, `+30%` art/basic speed for `6 s`. |
| `unbroken-thread` | `reeling-thread-breath` | `fire` | `curse` | `4.0 s` / `3%` | `c=1.2`, `debuff [2, 8.0]`, `bound (2 s)`, plus `off_guard (1 s)` on `hit_landed`. |

---

## E. Effects (`design/stage6-staging/clans/effects/clans.effects.json`)

| Effect Name | Source Holder | Triggers / State | Depth vs Engine Fidelity |
|---|---|---|---|
| `Under the Locust` | `cl-old-locust-seal` | `always` (`time <= 10`) + `art_fired` (`water`/`wood` ward) | `approx`: `+20% ward_pct` un-scoped + `1.5% HP` ward_grow on `water`/`wood` ward casts for `10 s`. |
| `The Toll` | `cl-keystone-toll-seal` | `blocked` (`event.amount > 0`, `foe.qi_share > 0`) | `approx`: `burn_qi` `1%` of `qi_max` (`to_self: 1.0`). |
| `The Swallow Returns` | `cl-swallow-hall-fan` | `art_fired` (`wood`, `quick`) + `pulse` countdown (`3 s`) | `approx`: echoes `fire_art {which: "last", share: 0.4}` once per fight. |
| `The Harvest Bell` | `cl-first-sheaf-bell` | `was_hit`/`pulse` (`hp_share < 0.5`) -> `bell_heal = 4` | `approx`: allies dropped (1v1); `2% HP` pulse for `4 s` on self. |
| `Reading the Weather` | `cl-misty-wave-mirror` | `pulse` (`limit: cooldown 12`) | `approx`: `decoy {n: 1}` every `12 s`. |
| `The Drawn Thread` | `cl-golden-reeling-needle` | `hit_landed` (`fire`, `art`) + `always` | Exact: `thread` (`cap: 4, each_for: 8`) -> `+2 acc` per stack. |
| `The Swallow Returns to Its Nest` | `cl-set-old-hall` (3pc) | `art_fired` (`wood`) -> every 3rd cast | Exact (`approx` note): `free_hit {c: 1.4, dtype: "soul"}`. Split worn `2/1` in cast; verified via 3pc probe. |
| `Outlast the Drought` | `cl-granary` (3pc) | `pulse` (`time >= 10, cd 10`) + `was_hit`/`pulse` (`hp < 0.2`) | Exact: stacks `granary_seed` (up to `4`), heals `8% HP/stack` below `20% HP`. |
| `Leave With the Tide` | `cl-ho-fleet` (3pc) | `was_hit`/`pulse` (`hp < 0.5`) + `always` + `hit_landed` | `approx`: `dampen_taken 9900 (2 s)`, `+10% qi`, next art `acc 1000`. |
| `Pulled Tight` | `cl-reeling-thread` (2pc) | `art_fired` (`needle-rain` or `needle` tag, `foe.debuff.fire >= 6`) | `approx`: `consume` all Fire debuff stacks -> `free_hit {c: 0.114, dtype: "fire"}`/stack. Needs `needle-rain`; verified via probe. |
| `He Waited` | `cl-locust-shade` (3pc) | `pulse` (`composed >= 1` / `== 0`), `always`, `hit_landed` | `approx`: `+5% ward_pct` per 10 s Composed (cap 3) + certain next art; decays `1/pulse` when un-Composed. |
| `Pillar in the Flood` | `cl-twin-bridges` (3pc) | `always` (`hp > 0.5`) + `blocked` (`event.amount > 0`, 5th) | `approx`: `delay_immune: 1, unmoved: 1` above `50% HP`; every 5th block burns `3% qi_max` to self. |

---

## F. Items & sets (`items/catalogue-sect-clans.json`, `items/sets-clans.json`)

- **17 unique items**: all `sources: ["npc"]`, `unique: true`, `arts: []`, W-checked cleanly (`0` findings). R6 `exception` set on all 12 items with common-art bases (`cl-old-locust-seal`, `cl-keystone-toll-seal`, `cl-swallow-hall-fan`, `cl-first-sheaf-bell`, `cl-golden-reeling-needle`, `cl-granary-seal`, `cl-seed-store-gourd`, `cl-white-sand-robe`, `cl-locust-dye-robe`, `cl-east-pillar-shield`, `cl-flood-year-coat`, `cl-ta-hall-seal`). Rarity `4` set on grade-3 treasures (`cl-old-locust-seal`, `cl-keystone-toll-seal`, `cl-first-sheaf-bell`).
- **6 sets**: `cl-locust-shade` (3pc), `cl-twin-bridges` (3pc), `cl-set-old-hall` (3pc), `cl-granary` (3pc), `cl-ho-fleet` (3pc), `cl-reeling-thread` (2pc), all matching `items_sets.json` schema (`pieces` + `modifiers` / `effect` + non-spatial `rule` + `story`).

---

## G. Stand-ins (`clans.cast.json`, `clans.2.cast.json`)

- `clans.cast.json`: **23** stand-ins replaced (`8` Tiêu `huyen_thuy` -> `locust-shade-breathing`; `7` Ôn `hoang_tho` -> `twin-span-pillar-method`; `8` Tạ `huyen_moc` -> `returning-swallow-breath`).
- `clans.2.cast.json`: **23** stand-ins replaced (`7` Lục `hoang_moc` -> `seed-store-method`; `1` Tống Thanh Miễu `huyen_kim` -> `nine-temper-scripture`; `6` Hỗ `huyen_thuy`/`hoang_thuy` -> `still-moon-tide-scripture`; `1` Mãn Tử Chi `huyen_moc` -> `verdant-cycle-scripture`; `8` Đới `hoang_hoa` -> `reeling-thread-breath`).
- Total remaining stand-ins reported by `depth_gap.py --sect clans`: **`0`**.

---

## H. Holder check (`sect_fight.py clans --seeds 5` + targeted probes)

### Default `sect_fight.py` runs
| Effect / Art | Holder(s) | `--gap 0` (5 seeds) | `--gap 1` (5 seeds) | Delta / Notes |
|---|---|---|---|---|
| `falling-locust-flowers` | Tiêu (8) | `11.8–12.4` fires/fight (`100%` win) | `1.0–2.6` fires/fight | Fires immediately in rotation on all 8 Tiêu holders. |
| `shade-of-the-road` | Tiêu (8) | `9.4–10.0` fires/fight | `1.0–1.8` fires/fight | Fires immediately and grows ward on Composed pulses. |
| `pillar-in-the-current` | Ôn (7) | `6.0–7.0` fires/fight | `1.0` fires/fight | Enters stance, blocks, delays foe's next art. |
| `swallows-return` | Tạ (8) | `6.2–15.0` fires/fight (`100%` win) | `2.0–3.8` fires/fight | Lands main wood hit + `0.85 c` chaos follow-up. |
| `opened-granary` | Lục (7) | `1.0` fire/fight | `0.4` fires/fight | Once-per-fight burst heal & haste fires reliably when gated. |
| `unbroken-thread` | Đới (8) | `8.2–10.6` fires/fight | `1.4–1.6` fires/fight | Applies Fire debuffs, Bound, and Off-Guard. |
| `Under the Locust` | `tieu_thua_am` | `runs 5` (`64.4 s 59%`) | `runs 5` (`16.0 s 0%`) | `always` (`ward_pct`) + `water_grow` (`5` casts `<= 10 s`) both fire (`eff_state` verified). |
| `He Waited` | `tieu_thua_am` | `runs 354` (`64.4 s 59%`) | `runs 73` (`16.0 s 0%`) | `tick=257, stack=25, decay=50, spend=22` across 5 seeds. |
| `The Toll` | `on_trong_luong` | ran | `runs 402` (`+15% HP` left: `47% vs 32%`) | Strong qi-drain sustain on blocks against higher-realm foe. |
| `Pillar in the Flood` | `on_trong_luong` | ran | `runs 566` (`+10% HP` left: `47% vs 37%`) | `delay_immune`/`unmoved` + every-5th-block qi burn active. |
| `The Swallow Returns` | `ta_cuu_duong` | `runs 20` (`13.0 s` vs `14.2 s`) | `runs 20` (`9.6 s` vs `11.2 s`) | Clear kill-speed gain from `3 s` echo (`-1.2 s` in `--gap 0`). |
| `The Harvest Bell` | `luc_thuong_lam` | `0` (stayed `100% HP`) | `runs 25` (`17.2 s vs 16.8 s`) | Threshold `< 50% HP` triggers cleanly under `--gap 1` pressure. |
| `Outlast the Drought` | `luc_thuong_lam` | `runs 7` | `runs 22` (`17.2 s vs 16.0 s`) | Seeds + `< 20% HP` emergency heal both fire in `--gap 1`. |
| `Reading the Weather` | `ho_te_xuyen` | `runs 10` (`14.9 s vs 14.5 s`) | `runs 10` (`22.4 s vs 24.4 s`) | Periodic Decoy fires every `12 s`. |
| `Leave With the Tide` | `ho_te_xuyen` | `0` (stayed `100% HP`) | `runs 10` (`22.4 s vs 20.8 s`) | `< 50% HP` trigger fires cleanly in `--gap 1`. |
| `The Drawn Thread` | `doi_tam_nuong` | `runs 98` | `runs 20` | Accumulates Fire-hit accuracy stacks cleanly. |
| `The Swallow Returns to Its Nest` | `ta_cuu_duong` (2/3) | `0` (`NEVER_RAN` by split) | `0` (`NEVER_RAN` by split) | `cl-set-old-hall` 3rd piece (`cl-returning-ink-pendant`) sits on `ta_tri_xuan`. Verified by Probe 1. |
| `Pulled Tight` | `doi_tam_nuong` | `0` (`NEVER_RAN` by build) | `0` (`NEVER_RAN` by build) | Requires `needle-rain` slotted alongside Burn stacks. Verified by Probe 2. |

### Targeted Probes
1. **Probe 1 (`cl-set-old-hall` 3pc on `ta_cuu_duong`)**: Added `cl-returning-ink-pendant` to `ta_cuu_duong`'s items against `typical` peer (`5` seeds): `eff:The Swallow Returns to Its Nest:count = 31`, `eff:The Swallow Returns to Its Nest:strike = 10` (`2` bonus soul hits/fight).
2. **Probe 2 (`cl-reeling-thread` 2pc `Pulled Tight` on `doi_tam_nuong`)**: Slotted `{'lib': 'needle-rain'}` (`needle` tag) on `doi_tam_nuong` against `typical` peer (`5` seeds): `eff:Pulled Tight:rain = 5` (`1/fight` Fire-debuff detonation upon reaching `>= 6` Fire stacks).
3. **Probe 3 (`tieu_thua_am` `Under the Locust` + `He Waited`)**: Verified `eff:Under the Locust:water_grow = 5` (`5` casts <= `10 s`) alongside `He Waited` (`tick = 257`, `stack = 25`, `decay = 50`, `spend = 22`).
4. **Probe 4 (`falling-locust-flowers` Fire-debuff gate)**: Pitted `tieu_thu_dao` against `doi_tam_nuong` (`seed 0`): `4` casts (`16` hits), `art:falling-locust-flowers:heal` ran only `8` times (the first `2` casts before Fire debuff applied; suppressed once Fire debuff held).
