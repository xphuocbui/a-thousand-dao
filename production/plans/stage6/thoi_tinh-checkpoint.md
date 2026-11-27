# Thối Tinh Môn (`thoi_tinh`): Stage 6 Checkpoint Review

Unanchored checkpoint review of `design/stage6-staging/thoi_tinh/` against `design/world/depth/sects/thoi_tinh.*`, `thoi_tinh.md`, `production/plans/stage6/_brief-record.md`, `DECISIONS-2026-11-25.md`, `DECISIONS-2026-11-26.md`, and `tools/design/combat_sim/FIGHT-INPUT.md`.

---

## 1. Ranked Findings

1. **SHOULD — `design/stage6-staging/thoi_tinh/arts/part-sect-thoi_tinh.json` :: `ninth-blow` (`ninth-blow-mod`, `ninth-blow-count`, `ninth-blow-reset`)**
   - **What was wrong:** `ninth-blow-count` and `ninth-blow-reset` filtered `hit_landed` with `{"not_tags": ["trigger"]}`, and `ninth-blow-mod` used unscoped `{"mod": {"dmg_more": 1.2}}`. Companion/summon hits carry `"companion"` (not `"trigger"`) in `tags`, so companion hits would have incremented `fold_hits` and consumed the 9th-hit `+120%` `dmg_more` contrary to the rule (`"Every direct hit you land (arts and basic attacks)"`), and an unscoped `dmg_more` could also leak onto a `free_hit` or companion hit if another listener fired while `fold_hits == 8`.
   - **Fix applied:** Changed `not_tags` to `["trigger", "companion"]` in `ninth-blow-count` and `ninth-blow-reset`, and scoped `ninth-blow-mod` to `{"mod": {"dmg_more": 1.2, "not_tags": ["trigger", "companion"]}}` (valid in both `tools/design/combat_sim/engine.py` and `src/gameplay/combat/fight/effect_compiler.gd` / `effect_runner.gd`).

2. **SHOULD — `design/world/depth/sects/thoi_tinh.items.json` (`tht-fallen-star-forge`) & `design/world/depth/sects/thoi_tinh.md` (§10)**
   - **What was wrong:** Both depth files still carried the pre-`d43` clause `"; each step fades after 3 s unless you fire another Fire art. At 5 steps or more..."`, whereas `design/world/depth/builds/authored/auth-eff-2.json` (`d43`, wire `replace`) replaced it with `"Once it holds 5 steps or more..."` (no 3 s fade), which the staged `sets-thoi_tinh.json` and `thoi_tinh.effects.json` already follow.
   - **Fix applied:** Updated `thoi_tinh.items.json` line 51 and `thoi_tinh.md` line 175 to the `d43` rule wording without the 3 s step fade.

3. **SHOULD — `design/world/depth/sects/thoi_tinh.techniques.json` :: `star-quench-canon` (`brittle-from-its-own-blow`)**
   - **What was wrong:** Line 25 read `"Each foe hit you block gives the foe one Quench mark..."`, causing `spatial_words_check.py --sect thoi_tinh` to flag `"Each foe"` as `postponed`, whereas `catalogue-sect-thoi_tinh.json` and `thoi_tinh.effects.json` already phrased it cleanly as `"Each hit from a foe you block..."`.
   - **Fix applied:** Updated `"Each foe hit you block"` to `"Each hit from a foe you block"` in `thoi_tinh.techniques.json` line 25 (`spatial_words_check.py --sect thoi_tinh` now reports `0` non-soft hits).

4. **NIT (informational, no edit) — `production/plans/stage6/thoi_tinh-review.md` §F**
   - §F noted `"all 10 living cast members"` (referencing `thoi_tinh.cast.json` only, omitting the 7 living cast members in `thoi_tinh.5.cast.json`), though §G correctly tested all 11 holders of `star-quench-canon` / `iron-hide-manual`. Across both cast files, all `17` living cast members run `star-quench-canon` or `nine-temper-scripture` (`0` stand-ins, `0` beasts), and all roots meet admission rules (`kim >= 36` outer `>= 30`; inner+ `kim >= 45`; `cat_luu_quang` `kim 80, hoa 62` for `fallen-star-forging-rite`).

---

## 2. Specific Audits & Parity Verification

- **`white_heat` vs `iron-hide-stance` (`part-sect-thoi_tinh.json`, `design/arts/family-metal.json`):**
  - `cat_luu_quang` slots both `white-heat` (`fallen-star-forging-rite`) and `iron-hide-stance` (`iron-hide-manual`), and `iron-hide-stance` uses the single fighter `state` slot (`"iron-hide"`). Implementing `white-heat` as a timed charge counter (`{"id": "white_heat", "each_for": 4, "cap": 1}`) lets both run without overwriting `"iron-hide"`.
  - `white-heat-fire` fires a `0.35 c` Fire `free_hit` on Metal `hit_landed` (`per_pulse: 3`), `white-heat-burn` lays 1 Burn (`fire` debuff, `6 s`) on direct hits (`not_tags: ["trigger"]`, `per_pulse: 3`), and `white-heat-quench` grants `stack_grant: 1` on `["metal", "debuff"]` in `on: "always"` when `own.counter.white_heat >= 1` and `foe.debuff.fire >= 1`. Verified in targeted probes (`cat_luu_quang` vs Thunder foe: `white-heat-start: 2, white-heat-fire: 5, white-heat-burn: 11, iron-hide-toggle: 1, iron-hide-temper: 8`).

- **`ninth-blow` 9th-hit burst (`+120% dmg_more`):**
  - `engine.py` (`trig_budget`) caps trigger `free_hit` damage per pulse at `0.5 * direct_dmg`. Applying `dmg_more: 1.2` on `always` when `own.counter.fold_hits >= 8` (scoped to `not_tags: ["trigger", "companion"]`) boosts the 9th direct hit without `trig_budget` clipping, and `ninth-blow-count` (`add: 1`) + `ninth-blow-reset` (`fold_hits >= 9 -> set: 0`) reset cleanly after the 9th direct hit (`ninth-blow-count: 17, ninth-blow-reset: 1` vs Thunder foe; `ninth-blow-count: 59, ninth-blow-reset: 6` in 30 s vs 50x-HP foe).

- **`quench-strike` Metal debuff mapping & `the-makers-fold`:**
  - `quench-strike` applies `[1, 8]` Metal debuff (`debuff: [1, 8]`, `add_stacks` executes before `hit_landed`), matching `auth-mod.json` `b3` (`Quench Mark`). `quench-brittle-spend` precedes `quench-brittle-arm` in `effects` so an armed `quench_brittle` boosts the current Metal art hit by `+35% dmg_more`, clears, and re-arms (`sundered` 1 stack for `4 s` + `quench_brittle = 1`) if `foe.debuff.metal >= 3`.
  - `the-makers-fold` (`hp_cost: 0.05`) arms `maker_fold = 3` on `art_fired` before its own `hit()`, keeps `makers-fold-unblockable` unscoped in `always` because both `engine.py` (`self.mod(att, "ignore_block")`) and `defence_path.gd` (`f.m(att, "ignore_block", null)`) read `ignore_block` without hit context, and consumes `1` charge + lays `1` Metal debuff (`15 s`) on `hit_landed` (`tags: ["sword"]`).

- **`Heat the Edge` (`d43` + unscoped `pierce`) & `Brittle from Its Own Blow` (`d30`):**
  - `Heat the Edge` follows `d43` (no 3 s fade). `pierce: 4` is unscoped in `always` (scaled by `own.counter.heat`) because both `engine.py` (`self.mod(att, "pierce")`) and `fight.gd` (`m(att, "pierce", null)`) read `pierce` without hit context. `Heat the Edge crit` places `"tags": ["sword"]` inside `"mod"`, and `Heat the Edge quench` clears `heat = 0` and sets `sky_iron_rings = 3` on sword `crit` when `heat >= 5`. In 30 s vs 50x-HP Kết Đan foe: `eff:Heat the Edge step: 7`, `eff:Heat the Edge quench: 1`, `eff:Sky Iron Sings strike: 3`.
  - `Brittle from Its Own Blow` uses `quench_from_block` around the block-granted Quench mark (`blocked`, `cooldown: 1.0`) so blocking does not consume Burn, and `burn_to_quench` (`scale: foe.debuff.fire per 3` floored, then `consume` all Fire stacks, then `marks`) so Burn is consumed before bonus Quench marks land (preventing recursion and matching `"for every 3 spent (rounded down)"`).

- **`Sky Iron Sings` & `Drawn from the River` probes (post-edit):**
  - `Sky Iron Sings`: runs `0` in `--gap 0` / `--gap 1` because typical foes lack Thunder arts and fights end in `10.2–13.9 s` before `Heat the Edge` reaches 5 Fire casts (~`20 s`). Verified in targeted probes:
    - `cat_luu_quang` vs Thunder Kết Đan foe (`th-bolt`, seed 1): won in `10.0 s`, `eff:Sky Iron Sings thunder: 5`, `eff:Sky Iron Sings strike: 7`.
    - `cat_luu_quang` vs 50x-HP Kết Đan foe (seed 1): `30.0 s`, `eff:Heat the Edge step: 7`, `eff:Heat the Edge quench: 1`, `eff:Sky Iron Sings strike: 3`.
  - `Drawn from the River`: runs `0` in `--gap 0` because `bang_lanh_toi` wins at `85 %` HP (`> 33.3 %`), and runs `20` across 20 seeds (`1/fight`) in `--gap 1`. Verified in Fire Nguyên Anh probe (`fire-burn`, seed 1): `eff:Drawn from the River hit: 1` (`5.0 s`). `ward_pct +60` for `5.0 s` cleanly models the `block_rating * 10` ward approximation (`approx` documented).

- **Standalone compilation parity & consolidated Stage 6 bug checklist:**
  - `4/4` Effects in `thoi_tinh.effects.json` declare every read/written counter in their own `"counters"` (`0` `"states"`), pass `engine.validate()`, and run cleanly standalone in a 1-seed fight.
  - `0` multi-`mod` records without `"stack": true`; `0` `temp_mods` filtering by `"art_id"` or `"status"`; `0` `always` records with record-level `"filter"`; `0` `decay_per_pulse: 1` counters; `0` `set`+`add` listener-order races; `0` `evaded` vs `was_evaded` swaps; `Sky Iron Sings thunder` intentionally omits `event.amount > 0` because `"strikes you or your blade"` includes blocked/warded hits.
  - `0` ID, Effect-name, or record-ID collisions against `assets/data/combat_effects.json`, committed `design/`, or other staged `b04` directories.
  - `spatial_words_check.py --sect thoi_tinh`: `0` non-soft hits (`3` figurative `soft` hits in `thoi_tinh.cast.json`: `"behind it"`, `"pace"`).
  - Item parity: all `5` items match `thoi_tinh.items.json` modifiers, grade, base, kind, holder, made_by, made_year, and set (`5/5` `unique: true`, `sources: ["npc"]`, `rarity: 4` on `tht-river-tongs`, R6 `exception` on `tht-three-years-tax`, `tht-coal-black-apron`, `tht-quench-robe`).

---

## 3. Pending Words

None (`pending.json` absent; all mechanics map cleanly to existing Python and GDScript engine words).

---

## 4. Holder Table (after final edits)

### Linters (`DEPTH_STAGE=C:\Users\xphuo\IdeaProjects\my-game\design\stage6-staging\thoi_tinh`)
- `lint_techniques.py`: `checked 2 techniques, 0 findings` (`star-quench-canon` `14.7 W of 16`, `fallen-star-forging-rite` `23.0 W of 24`).
- `lint_arts.py`: `checked 4 arts in 1 files, 0 findings`.
- `lint_items.py`: `checked 5 items, 22 bases, 9 common arts, 0 findings` (`5 of 5` unique, R6 `exception` on the 3 weapons/armour).

### `sect_fight.py thoi_tinh` (`--gap 0 --seeds 5` and `--gap 1` default `--seeds 20`; `0` `REFUSED`, `0` `NEVER_FIRED`)

| Holder | Realm | Arts (gap 0 fires) | Gap 0 (`mean_s`, `wins`, `hp_left`) | Gap 1 (`mean_s`, `wins`, `hp_left`) | Effects (gap 0 with vs without, runs; gap 1 runs) |
|---|---|---|---|---|---|
| `cat_luu_quang` | `ket_dan` | `quench-strike` (3.4), `ninth-blow` (2.4), `white-heat` (2.0), `the-makers-fold` (1.0), `iron-hide-stance` (1.0) | `10.2 s`, `5/5`, `90%` | `13.9 s`, `0/20`, `0%` | `Brittle`: `10.2s 90%` vs `10.9s 90%` (`108` / `501`); `Heat the Edge`: `10.2s 90%` vs `10.2s 90%` (`10` / `43`); `Sky Iron Sings`: `0` / `0` (verified in probes) |
| `cat_doan_nhac` | `truc_co` | `quench-strike` (4.0), `ninth-blow` (3.0), `iron-hide-stance` (2.0) | `12.0 s`, `5/5`, `94%` | `13.2 s`, `0/20`, `0%` | `Brittle`: `12.0s 94%` vs `16.0s 91%` (`60` / `264`) |
| `bang_lanh_toi` | `truc_co` | `quench-strike` (4.0), `ninth-blow` (3.0) | `12.0 s`, `5/5`, `85%` | `8.1 s`, `0/20`, `0%` | `Brittle`: `12.0s 85%` vs `16.0s 81%` (`60` / `161`); `Drawn from the River`: `0` (`12.0s 85%`) / `20` (`8.1s 0%`) |
| `phan_lo_kien`, `nghe_bach_doan` (2 stewards/elders) | `truc_co` | `quench-strike` (4.0), `ninth-blow` (3.0), `iron-hide-stance` (2.0) | `12.0 s`, `5/5`, `92%` | `11.1 s`, `0/20`, `0%` | `Brittle`: `12.0s 92%` vs `16.0s 88%` (`60` / `221` each) |
| `hau_thiet_anh`, `dinh_hoa_lan` (2 inner/steward) | `truc_co` | `quench-strike` (4.0), `ninth-blow` (3.0) | `12.0 s`, `5/5`, `79%` | `8.0 s`, `0/20`, `0%` | `Brittle`: `12.0s 79%` vs `16.4s 71%` (`60` / `160` each) |
| `tat_kim_thanh` | `luyen_khi` | `quench-strike` (4.0), `ninth-blow` (3.0) | `12.6 s`, `5/5`, `75%` | `8.0 s`, `0/20`, `0%` | `Brittle`: `12.6s 75%` vs `19.6s 61%` (`63` / `160`) |
| `cat_thanh_diem`, `cat_tinh_chuy` (2 inner, L2–L3) | `luyen_khi` | `quench-strike` (6.0), `ninth-blow` (4.6) | `19.6 s`, `5/5`, `61%` | `8.0 s`, `0/20`, `0%` | — (`layer < 4`, before `Brittle`) |
| `man_hac_chau` | `luyen_khi` | `quench-strike` (7.4) | `23.2 s`, `5/5`, `52%` | `8.0 s`, `0/20`, `0%` | — (`layer 1 < 4`, before `Brittle`) |

CHECKPOINT DONE
