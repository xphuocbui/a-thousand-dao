# Stage 6: Lãng Đào Môn (`lang_dao`, progress file)

Owner: `lang_dao` (Batch `b05`)
Stage dir: `design/stage6-staging/lang_dao/`

## Scope (gap report `python -B -I tools/design/world/depth_gap.py --sect lang_dao`)
- Techniques: 3 (`ferry-pole-primer`, `washing-waves-canon`, `nine-bends-art`) + `returning-wake-verse` (existing in `catalogue-water`)
- Arts (new): 3 (`pole-vault`, `a-thousand-washings`, `ninth-bend`)
- Arts (ref): 4 (`rooted-form`, `gathering-wave`, `drag-of-the-deep`, `swallow-stance` — `swallow-stance` omitted from staged `nine-bends-art` `abilities`; see Decisions)
- Items: 4 (`ld-nine-bend-toll-seal` treasure `rarity: 5`, `ld-last-white-sail`, `ld-first-fleet-anchor`, `ld-ferry-master-oilskin`)
- Sets: 1 (`ld-nine-landings`)
- Effects: 3 (`Pay the Toll`, `The Boat That Did Not Burn`, `Round the Bend, Then the Anchor`)
- Stand-ins: 0
- Beasts: 0
- Events: 4 (`N-lang_dao-01`..`04`, structured)
- Cross-owner: `loose-south` (`trinh_tieu_do`, `yen_hoi_do` on `ferry-pole-primer`) — closes at serial merge.

## Steps
- [x] 1. Verify first: mechanic table, `spatial_words_check.py`, `CongPhap.usable()` root check, collision check.
- [x] 2. Techniques and arts (staged) + depth `id` tags in `lang_dao.techniques.json`.
- [x] 3. Effects (staged).
- [x] 4. Items and sets (staged).
- [x] 5. Stand-ins (none) and beasts (none).
- [x] 6. Holder check (`lint_techniques`, `lint_arts`, `lint_items`, `depth_check`, `spatial_words_check`, `sect_fight.py` gap 0 & 1, targeted probes).
- [x] 7. Review file (`production/plans/stage6/lang_dao-review.md`).
- [x] 8. Finish (`RECORD PASS DONE` + `production/plans/stage6/lang_dao.done`).

## Step 1: Mechanic Table
| Record | Kind | Engine form | Status / Notes |
|---|---|---|---|
| `ferry-pole-primer` | Technique (T0, main) | `names: ["thuy", "moc"]`, `passives` 7.9 W (`evade_pct 3`, `khi_huyet_pct 3`, `linh_luc_regen_inc_pct 2`), `abilities`: `pole-vault` (L1), `rooted-form` (L2) | Existing words |
| `washing-waves-canon` | Technique (T2, main) | `names: ["thuy", "moc"]`, `bonuses`: `linh_luc_pct 12`, `attack_pct 10`; `passives` 23.3 W (`art_speed_pct 10 [thuy]`, `attack_pct 8 [thuy]`, `resist_pen_pct 30 [cold]`, `pierce_pct 8`, `linh_luc_regen_inc_pct 5`); `abilities`: `gathering-wave` (L1), `a-thousand-washings` (L2), `drag-of-the-deep` (L4) | Existing words |
| `nine-bends-art` | Technique (T1, secret) | `names: ["thuy"]`, `bonuses`: `attack_pct 8`; `passives` 16.0 W (`evade_pct 8`, `attack_pct 6 [thuy]`); `abilities`: `ninth-bend` (L1) (`swallow-stance` omitted for `CongPhap.usable` & `lint_techniques` `ELEMENT`) | Existing words |
| `pole-vault` | Art (`ferry-pole-primer`) | `water`, `c_art: 1.45`, `cost_share: 0.03`, `cd: 3.5`, `tags: ["cold", "movement"]`, `held` until `hit_landed`: `timer foe next +0.3 s` | Existing words |
| `a-thousand-washings` | Art (`washing-waves-canon`) | `water`, `c_art: 1.8`, `split: [0.25]*4`, `cost_share: 0.05`, `cd: 5.0`; Water art `hit_landed` adds `washings` (+15 `pen [water]` each); at 10 clears & arms `washings_pierce` for next damaging art (`bypass 0.5`, `pierce 75`, `pen 300`) | Existing words (`bypass 0.5`, `pierce 75`, `pen 300` approx for "pierces fully") |
| `ninth-bend` | Art (`nine-bends-art`) | `water`, `c_art: 1.5`, `cost_share: 0.04`, `cd: 4.0`, `tags: ["cold", "step"]`; grants `+12 evade` 3.5 s on cast; `evaded` builds `nine_bend` -> at 9 clears & arms `ninth_bend_ready` for next damaging Water art (`dmg_more 1.0`, `acc 500`) | Existing words; non-spatial ("from behind" dropped) |
| `Pay the Toll` | Effect (`ld-nine-bend-toll-seal`) | First Water `art_fired` sets `tolled`; `was_hit`/`evaded` (`kind: "art"`, `per_pulse: 1`) drains `0.02` max qi (`burn_qi of: "max", to_self: 1.0`) up to 5 tolls (`0.10` max); then flips `tolled -> 0, toll_pass -> 1` (`always` `dampen_taken 11.11` = -10% dmg taken) | Existing words |
| `The Boat That Did Not Burn` | Effect (`ld-last-white-sail`) | Sail charge standing while worn: `always` `dampen_taken 100, resist 200 [dtype: fire]`; `down` (`per_fight: 1`) while `sail_burn_tick` / `own.debuff.fire >= 1` runs `refuse_down` (leaves 1 HP) | Existing words (`resist 200` + `dampen_taken 100` approx for burn tick halving) |
| `Round the Bend, Then the Anchor` | Effect (`ld-nine-landings` 3p) | On `evaded`: if `tolled >= 1`, drains 1 toll (`0.02` max qi, flips `toll_pass` at 5); builds `anchor_bend` -> at 9 clears & `mod {bypass: 0.5, pen: 150}` + `free_hit {c: 1.8, dtype: "cold"}` | Existing words |

RECORD PASS DONE
