# Trạc Anh Đài (`trac_anh`): Stage 6 Checkpoint Review

Unanchored checkpoint review of [design/stage6-staging/trac_anh/](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/trac_anh) against [trac_anh.md](file:///C:/Users/xphuo/IdeaProjects/my-game/design/world/depth/sects/trac_anh.md), [trac_anh.techniques.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/world/depth/sects/trac_anh.techniques.json), [trac_anh.items.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/world/depth/sects/trac_anh.items.json), [trac_anh.cast.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/world/depth/sects/trac_anh.cast.json), [trac_anh.5.cast.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/world/depth/sects/trac_anh.5.cast.json), [trac_anh.beasts.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/world/depth/sects/trac_anh.beasts.json), [production/plans/stage6/_brief-record.md](file:///C:/Users/xphuo/IdeaProjects/my-game/production/plans/stage6/_brief-record.md), [DECISIONS-2026-11-25.md](file:///C:/Users/xphuo/IdeaProjects/my-game/design/world/depth/DECISIONS-2026-11-25.md), [DECISIONS-2026-11-26.md](file:///C:/Users/xphuo/IdeaProjects/my-game/design/world/depth/DECISIONS-2026-11-26.md), and [FIGHT-INPUT.md](file:///C:/Users/xphuo/IdeaProjects/my-game/tools/design/combat_sim/FIGHT-INPUT.md).

---

## 1. Ranked Findings

**0 MUST-FIX, 1 SHOULD, 2 NIT — the SHOULD finding was fixed and re-verified.**

1. **SHOULD (FIXED) — [trac_anh.techniques.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/world/depth/sects/trac_anh.techniques.json) :: `wash-the-feet`, `ninth-fathom`, `throw-the-iron` concepts**
   - **What was wrong:** While [part-sect-trac_anh.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/trac_anh/arts/part-sect-trac_anh.json) already rewrote all three arts non-spatially, the depth source file [trac_anh.techniques.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/world/depth/sects/trac_anh.techniques.json) still carried stale 2026-11-26 spatial/renamed wording in `arts[].concept`: `wash-the-feet` (`"rooted"`, flagged `removed` by `spatial_words_check.py`), `ninth-fathom` (`"stillness"`, flagged `rename` by `spatial_words_check.py`), and `throw-the-iron` (`"A ranged throw that pins the target: their movement and art speed fall while the line holds."`).
   - **Fix applied:** Minimal in-place edits in [trac_anh.techniques.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/world/depth/sects/trac_anh.techniques.json):
     - `wash-the-feet.concept`: `"A low, rooted stance..."` -> `"A low Composed stance..."`
     - `ninth-fathom.concept`: `"sinks into the stillness of deep water"` -> `"sinks into deep-water calm"`
     - `throw-the-iron.concept`: `"A ranged throw that pins the target: their movement and art speed fall while the line holds."` -> `"Throws the harpoon on its qi-woven line: binds the foe (Bound, cannot flee) and slows its timers while the line holds."`
   - After edit, `spatial_words_check.py --sect trac_anh` reports `0` hits in `trac_anh.techniques.json`.

2. **NIT (informational, no edit) — [trac_anh.items.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/world/depth/sects/trac_anh.items.json) & [trac_anh.cast.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/world/depth/sects/trac_anh.cast.json) / [trac_anh.5.cast.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/world/depth/sects/trac_anh.5.cast.json) residual `spatial_words_check.py` hits**
   - `trac_anh.items.json :: ta-old-ivory-hunt :: sets.bonuses.effect` matches `Drag` inside the proper Effect name `"Drag It to the Ice (Duệ Thượng Băng)"` (not stripped because `effect` is not in `NAME_FIELDS`; [sets-trac_anh.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/trac_anh/items/sets-trac_anh.json) already separates `effect` and `rule` cleanly).
   - `trac_anh.5.cast.json :: lam_nhan_thanh :: tree.intent` (`"stillness"`) and `trac_anh.cast.json :: tan_bach_au :: build.note` (`"banner"`) are commentary fields (`COMMENT_FIELDS`) describing lore/theme. Left untouched.

3. **NIT (informational, no edit) — [trac_anh-review.md](file:///C:/Users/xphuo/IdeaProjects/my-game/production/plans/stage6/trac_anh-review.md) holder-count typo**
   - [trac_anh-review.md](file:///C:/Users/xphuo/IdeaProjects/my-game/production/plans/stage6/trac_anh-review.md) line 94 wrote `13/13 Authored-Kit Holders` whereas the table lists `12` holders of staged `trac_anh` methods (`1 + 1 + 1 + 1 + 1 + 1 + 2 + 1 + 3 = 12`) plus `6` outer disciples (`unbroken-flesh-canon`), totaling `18/18` living cast members.

---

## 2. Specific Audits & Parity Verification

- **`wash-the-hat-strings` split `art_fired`:**
  - Verified in [part-sect-trac_anh.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/trac_anh/arts/part-sect-trac_anh.json): split into two separate `art_fired` records (`wash-the-hat-strings-regen` with `hregen: 0.025, for: 4.0` and `wash-the-hat-strings-cold` with `dampen_taken: 100, dtype: "cold", for: 4.0`). No multi-`mod` clobber (`0` records with 2+ `mod` actions without `stack: true`).
  - Verified `engine.py` line 1333 and `fight.gd` line 1280: `dampen_taken: 100` yields `D / (1 + 1.0) = 0.5 * D` (Cold damage halved), and `engine.py` line 921 / `fight.gd` line 407 apply `hregen: 0.025` as 2.5 % `hp_max`/s.
- **`wash-the-feet` `convert`-before-`arm` & stance safety:**
  - Verified `wash-the-feet-convert` precedes `wash-the-feet-arm` in `effects` and both gate on `event.amount > 0` and `own.state.wash-the-feet >= 1`.
  - Hit-by-hit trace in `engine.py` (`seed=1`, `t=6000 ms`): `wash-the-feet-enter` enters `wash-the-feet` (`tags: ["composed"]`, `mods: {"block": 10}`) with `wash_feet_armed = 0`; 1st damaging hit (`11.53`) triggers `wash-the-feet-arm` (`wash_feet_armed = 1`); 2nd damaging hit (`11.53`) triggers `wash-the-feet-convert`, restoring `11.53` HP (`ignore_taken: true`), adding `11.53` to `body_bar` (`body_shield: true`), resetting `wash_feet_armed = 0`, and exiting stance (`state: null`) without re-arming.
  - Checked all companion techniques slotted by `trac_anh` cast (`undertow-litany`, `hundred-echo-palm-scripture`, `unbroken-flesh-canon`): none define or set any `states`, so `wash-the-feet` has zero stance collisions.
- **`ninth-fathom` `dampen_taken: 10000` + refunds (`unlock_layer: 6`):**
  - `catalogue-sect-trac_anh.json` sets `unlock_layer: 6` (satisfying `lint_techniques.py`'s `<= 6` rule and unlocking for all L6+ holders: `doan_thanh_lang`, `phi_nhan_tam`, `doan_to_ba`, `ngac_hai_tieu`).
  - Verified `ninth_fathom_sec` (`each_for: 1.0`) + `dampen_taken: 10000` (`for: 1.0`) + `was_hit` / `tick_taken` / `soul_taken` (`event.reflected == 0`) refunds in `engine.py` trace (`t=6000..7000 ms`): `slowed_time` and `drunk` (the only two slowing statuses in `STATUS`; `DEBUFF` has no timer-slowing element) are cleansed on cast; direct hits are dampened (`191.7 -> 1.9 -> 0.0` after ward/block) and `soul_poke` (`141.3` HP) is immediately refunded by `ninth-fathom-soul`, with normal damage resuming at `t=7000 ms`.
- **`throw-the-iron` & `haul-in`:**
  - `throw-the-iron` (`c_art 1.35`, `cd 4.0`) applies `bound` (`3 s`) and `slowed_time` (`2 s`) cleanly under the non-spatial ruling.
  - `haul-in` (`c_art 2.2`, `cd 5.0`, `tags: ["physical", "harpoon", "haul_in"]`) empowers on `foe.status.bound >= 1` (`timer {side: "foe", which: "next", by: 0.3}`, `c_mult: 1.6`) and scales `+15 % dmg_more` per `line_held` pulse via `tags: ["haul_in"]` on `always` (never filtering `temp_mods` by `art_id` or placing `filter` on `always`).
- **`The Line Holds` & `Drag It to the Ice` standalone counters:**
  - Both Effects in [trac_anh.effects.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/trac_anh/effects/trac_anh.effects.json) pass `engine.validate()` standalone (`The Line Holds`: `counters: []`, `states: []`; `Drag It to the Ice`: `counters: [{"id": "ivory_bind"}]`, `states: []`).
  - `Drag It to the Ice:clear` resets `ivory_bind = 0` on `pulse` when `foe.status.bound == 0`; `always` gates on `foe.status.bound >= 1` and `own.counter.ivory_bind >= 1`, scaling `dmg_more: 0.04` with `"dtype": "phys"` inside the `mod`.
  - Verified why `The Line Holds` shows `54.6 s 96%` vs `54.6 s 96%` on `doan_thanh_lang` in `sect_fight.py`: on `seed=1` vs typical Kết Đan, `eff:The Line Holds` executes `32` times and adds `+9.48` net healing (`2454.27` vs `2444.79`), with most of the 3 % hit-leech overflowing because `wash-the-hat-strings` + `Drag It to the Ice` + `wash-the-feet` keep `doan_thanh_lang` near full HP; against a 2× HP / higher-layer enemy (`[160, 120, 60, 30, 0]`), `The Line Holds` runs `15` times and adds `+5.70` net healing (`3319.51` vs `3313.81`), confirming the Effect functions as specified.
- **Beasts (`lang_nhi`, `tiem_nhi`) & stand-ins:**
  - `doan_to_ba` (`than_hon: 54`, capacity `1 + floor(54/40) = 2`) lists `"beasts": ["lang_nhi", "tiem_nhi"]` in [trac_anh.cast.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/world/depth/sects/trac_anh.cast.json), matching `owner_id: "doan_to_ba"` and `bond.keeper: "doan_to_ba"` in [trac_anh.beasts.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/world/depth/sects/trac_anh.beasts.json).
  - `0` stand-ins across all `18` living cast members (`12` on staged `trac_anh` methods + `6` outer disciples on committed `unbroken-flesh-canon`).
- **Multi-`mod`, `temp_mods`, events/pulses, collisions, items & sets:**
  - `0` multi-`mod` records without `stack: true`; `0` `temp_mods` filtering by `art_id` or `status`; `0` `always` records with record-level `filter`; `0` `decay_per_pulse: 1` off-by-ones; `0` `set`+`add` races; `0` ID or Effect-name collisions vs `assets/data/combat_effects.json`, committed `design/`, or other staged directories.
  - All `4` staged items match [trac_anh.items.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/world/depth/sects/trac_anh.items.json) modifiers/fields and carry `sources: ["npc"]`, `unique: true`, `rarity: 4` on `ta-goose-bone-beads`, and R6 `exception` on `ta-canglang-harpoon` and `ta-white-whale-coat`.

---

## 3. Pending Words

None (`pending.json` absent; `0` pending words — all mechanics run on existing Python and GDScript engine words).

---

## 4. Holder Table & Final Verification (after final edits)

### Linters & Checkers (`DEPTH_STAGE=C:\Users\xphuo\IdeaProjects\my-game\design\stage6-staging\trac_anh`)
- `python -I tools/design/arts/lint_techniques.py design/stage6-staging/trac_anh/techniques/catalogue-sect-trac_anh.json`: **checked 2 techniques, 0 findings** (`canglang-body-canon` `15.9 W of 16`, `whale-line-harpoon` `14.8 W of 16`).
- `python -I tools/design/arts/lint_arts.py design/stage6-staging/trac_anh/arts/part-sect-trac_anh.json`: **checked 5 arts in 1 files, 0 findings** (`haul-in empower 1: x1.10 of the lint, gated`).
- `python -I tools/design/items/lint_items.py design/stage6-staging/trac_anh/items/catalogue-sect-trac_anh.json`: **checked 4 items, 22 bases, 9 common arts, 0 findings** (`unique 4 of 4`).
- `python -I tools/design/world/spatial_words_check.py --sect trac_anh`: `0` hits in `trac_anh.techniques.json`; `1` false-positive (`Drag` in `"Drag It to the Ice"` in `trac_anh.items.json`); `2` commentary hits (`lam_nhan_thanh.tree.intent`, `tan_bach_au.build.note`).

### `sect_fight.py trac_anh` (`--seeds 5` at `--gap 0`, default `--seeds 20` at `--gap 1`; `0` `REFUSED`, `0` `NEVER_FIRED`, `0` `NEVER_RAN`)

| Holder | Realm | Slotted arts (Gap 0 fires/fight) | Gap 0 (`mean_s`, `wins`, `hp_left`) | Gap 1 (`mean_s`, `wins`, `hp_left`) | Effects (`with` vs `without`, runs G0 / G1) |
|---|---|---|---|---|---|
| `doan_thanh_lang` | `ket_dan` | `wash-the-hat-strings` (8.8), `wash-the-feet` (5.8), `ninth-fathom` (1.0), `throw-the-iron` (7.6), `haul-in` (4.0), `seep-through-palm` (7.0) | `54.6 s`, `5/5`, `96%` | `10.7 s`, `0/20`, `0%` (fires `1.3`/`1.0`/`1.0`/`2.0`/`1.0`/`2.0`) | `The Line Holds`: `54.6 s 96%` vs `54.6 s 96%` (`182` G0 / `95` G1); `Drag It to the Ice`: `54.6 s 96%` vs `58.6 s 92%` (`137` G0 / `109` G1) |
| `phi_nhan_tam` | `ket_dan` | `answering-palm` (7.8), `twin-shadow-fist` (2.8), `rolling-barrage-fist` (9.4), `wash-the-hat-strings` (3.4), `wash-the-feet` (3.0), `ninth-fathom` (1.0) | `23.7 s`, `5/5`, `93%` | `8.8 s`, `0/20`, `0%` (fires `2.9`/`1.0`/`4.0`/`1.1`/`1.0`/`1.0`) | — |
| `doan_to_ba` | `truc_co` | `wash-the-hat-strings` (7.2), `wash-the-feet` (5.4), `ninth-fathom` (1.0), `throw-the-iron` (6.2), `haul-in` (4.0) | `44.3 s`, `0/5`, `0%` | `10.4 s`, `0/20`, `0%` (fires `1.0`/`1.0`/`1.0`/`2.0`/`1.0`) | — (`lang_nhi`, `tiem_nhi` beasts not modelled by `sect_fight.py`) |
| `ngac_hai_tieu` | `truc_co` | `wash-the-hat-strings` (7.2), `wash-the-feet` (5.4), `ninth-fathom` (1.0), `throw-the-iron` (6.2), `haul-in` (4.0) | `44.3 s`, `0/5`, `0%` | `10.4 s`, `0/20`, `0%` (fires `1.0`/`1.0`/`1.0`/`2.0`/`1.0`) | — |
| `dau_thuy_lang` | `truc_co` | `wash-the-hat-strings` (4.2), `wash-the-feet` (4.0), `answering-palm` (8.8), `twin-shadow-fist` (3.0) | `26.5 s`, `5/5`, `93%` | `8.0 s`, `0/20`, `0%` (fires `1.0`/`1.0`/`2.0`/`1.0`) | — |
| `boc_kinh_thang` | `truc_co` | `wash-the-hat-strings` (6.8), `wash-the-feet` (5.2), `throw-the-iron` (6.2), `haul-in` (4.0) | `43.5 s`, `0/5`, `0%` | `8.3 s`, `0/20`, `0%` (fires `1.0`/`1.0`/`2.0`/`1.0`) | — |
| `lo_chau_nuong`, `bao_thiet_thu` (2) | `truc_co` | `wash-the-hat-strings` (6.8), `wash-the-feet` (6.0) | `45.4 s`, `0/5`, `0%` | `8.5 s`, `0/20`, `0%` (fires `1.0`/`1.0`) | — |
| `co_lang_hoa` | `luyen_khi` | `wash-the-hat-strings` (6.4), `wash-the-feet` (5.6), `throw-the-iron` (6.8) | `40.4 s`, `0/5`, `0%` | `8.2 s`, `0/20`, `0%` (fires `1.0`/`1.0`/`1.9`) | — |
| `lam_nhan_thanh`, `nghe_tieu_lang`, `vu_bich_trieu` (3) | `luyen_khi` | `wash-the-hat-strings` (5.6), `wash-the-feet` (5.4) | `40.0 s`, `0/5`, `0%` | `8.1 s`, `0/20`, `0%` (fires `1.0`/`1.0`) | — |

CHECKPOINT DONE
