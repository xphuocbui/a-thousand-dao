# Lễ Tuyền Phái (`le_tuyen`): Stage 6 checkpoint review (2026-11-27, fresh unanchored Neon audit)

Fresh, unanchored audit of `design/stage6-staging/le_tuyen/` against `design/world/depth/sects/le_tuyen.*`, `production/plans/stage6/_brief-record.md`, `DECISIONS-2026-11-25.md`, `DECISIONS-2026-11-26.md`, `FIGHT-INPUT.md`, and both fight engines (`tools/design/combat_sim/engine.py` and `src/gameplay/combat/fight/`).

**Verdict:** **5 findings fixed** (`2 MUST-FIX`, `3 SHOULD`) plus `2 NIT` observations logged. All three linters, `depth_check.py`, `depth_gap.py`, `sect_fight.py` (`gap 0` and `gap 1`), and dedicated probes pass after fixes. `pending.json` has `0` entries (verified empty; no new engine words warranted).

---

## 1. Ranked findings

1. **[MUST-FIX — FIXED]** `design/stage6-staging/le_tuyen/arts/part-sect-le_tuyen.json` — `last-cup`
   - **What was wrong:** `empower[0]` placed the `drunk` (2 stacks) and `heavy_breath` (1 stack, 4 s) status applications inside `pay` rather than `add_statuses`. In both `engine.py:1174` and `fight.gd:1087`, `empower.pay` runs inside `shape()` *before* `hit()`, so both curses were applied even when the foe evaded `last-cup` (bypassing the evade roll), unlike every other empowered status art in the catalogue (`lamp-oil-lance`, `frozen-hour-seal`, `blight-canker`).
   - **Fix applied:** Replaced `empower[0].pay` with `empower[0].add_statuses: [{"id": "drunk", "stacks": 2}, {"id": "heavy_breath", "stacks": 1, "dur": 4}]`, so the statuses land on hit after the evade check in both engines (`engine.py:1374-1375`, `fight.gd:1316-1317`, `fighter_profile_loader.gd:201-217`). Verified 0 findings in `lint_arts.py` and 9/9 empowered hits applying `heavy_breath` on `ha_thanh_to` seed 0.

2. **[MUST-FIX — FIXED]** `design/stage6-staging/le_tuyen/effects/le_tuyen.effects.json` — `A Brimming Cup` (`eff:A Brimming Cup ward`)
   - **What was wrong:** Granted `ward_grow {"share": 0.05, "of": "hp"}` (5 % of maximum health) while its rule text claimed that was "about half the heal". Measured directly on its real holder `mai_le_tuyen` in `engine.py`, `hundred-herb-draught` (`c_heal: 0.8`) heals `2.45 %` HP raw (`4.17–4.90 %` HP with her +70–100 % healing modifiers), and `morning-dew` (`c_heal: 0.7`) heals `3.64 %` HP (`5.79 %` doubled). A `5 %` HP ward was `102–200 %` of the entire heal — double what the depth rule ("a ward worth half the heal") states.
   - **Fix applied:** Changed `ward_grow.share` from `0.05` to `0.025` (`2.5 %` of maximum health, matching ~half of a 4–5 % heal) and updated `rule` and `approx` to match. Re-verified in the `morning-dew` probe (`10/10` wins, `27 %` HP left vs `0/10` without `A Brimming Cup`).

3. **[SHOULD — FIXED]** `design/stage6-staging/le_tuyen/effects/le_tuyen.effects.json` — `Sealed Cask` (`eff:Sealed Cask`)
   - **What was wrong:** Used `"limit": {"per_pulse": 1}`, which silently dropped ~33 % of `Sealed Cask` procs on its real holder `nhac_thuan_nhuong` whenever he cast two Water arts in the same second (`64` vs `97` procs at gap 0; `79` vs `119` procs at gap 1 over 10 seeds), contradicting both the depth rule ("A foe struck by your Water art while carrying three or more of your Water stacks...") and the **Scale without caps** rule.
   - **Fix applied:** Changed `"limit": {"per_pulse": 1}` to `"limit": {"per_firing": 1}` (supported in both `engine.py:1782` and `effect_runner.gd:314`), so every distinct Water art firing triggers `Sealed Cask` once while multi-hit split Water arts (e.g. `swelling-tide-palm`) still apply once per firing rather than per sub-hit. On `nhac_thuan_nhuong` (`gap 1`, 5 seeds), survival improved to `45.4 s` with `Sealed Cask` vs `21.6 s` without (`77` runs).

4. **[SHOULD — FIXED]** `design/stage6-staging/le_tuyen/effects/le_tuyen.effects.json` — `Needle of Mending` (`eff:Needle of Mending cleanse tag`, `eff:Needle of Mending cleanse common`)
   - **What was wrong:** Used `"limit": {"per_pulse": 1}` on both cleanse records, which throttles fast 1 s cooldown needle arts (`common-arts.json`'s `needle-rain` or `rime-needle`) accelerated by art speed or paired needle arts fired in the same pulse.
   - **Fix applied:** Changed `"limit": {"per_pulse": 1}` to `"limit": {"per_firing": 1}` on both cleanse records. Verified in dual probes: `family-metal`'s 6-split `needle-rain` fires `69` times -> `69` cleanses and `414` heals (zero `common` double-procs); `common-arts`'s 1 s `needle-rain` fires `337` times -> `337` cleanses and `337` heals (zero `tag` double-procs; `+39 %` HP left vs without).

5. **[SHOULD — FIXED]** `design/stage6-staging/le_tuyen/effects/le_tuyen.effects.json` — `A Brimming Cup` (`eff:A Brimming Cup reset`, `eff:A Brimming Cup pulse`)
   - **What was wrong:** Both bookkeeping records fired unconditionally on every pulse even when `brimming_full_qi == 0` and `brimming_overflow_tick == 0`, executing ~144 no-ops per 5 seeds and inflating `sect_fight.py` run counts (`170` at gap 0, `152` at gap 1) while masking that `ward` ran `0` times at gap 1 and `ready`/`spend` ran `0` times in the default 6-art build.
   - **Fix applied:** Added `{"read": "own.counter.brimming_full_qi", "op": ">=", "value": 1}` to `reset` and `"if": [{"read": "own.counter.brimming_overflow_tick", "op": ">=", "value": 1}]` to `pulse`. Identical state-machine behavior with zero no-ops; `sect_fight.py` now reports honest counts (`49` runs at gap 0, `21` at gap 1).

6. **[NIT — LOGGED]** `production/plans/stage6/le_tuyen-review.md` §C table — `sweet-spring-wine-rite`
   - **Observation:** The record job's review table listed `stack_effect_pct 10 [thuy, debuff]` (`15.5 W`), whereas the actual staged `catalogue-sect-le_tuyen.json` has `linh_luc_regen_inc_pct 3 []` (`15.4 W of 16`). The staged JSON is strictly better because `combat_engine.json` `DEBUFF` has no `water` row (`effects.md:310`), so `linh_luc_regen_inc_pct` actually runs. No edit needed to the JSON.

7. **[NIT — LOGGED]** `design/stage6-staging/le_tuyen/items/catalogue-sect-le_tuyen.json` (`ltp-hundred-jar-seal`) & `items/sets-le_tuyen.json` (`ltp-hundred-jars` 2pc)
   - **Observation:** Preserves `stack_effect_pct [thuy, debuff]` (+20 % / +10 %) verbatim from `le_tuyen.items.json` per `_brief-record.md`. Because `DEBUFF` has no `water` stat row (`effects.md:310`; Ice carries the pair's debuff stat), Water debuff stacks function as wine-drench markers feeding `Last Cup`, `Sealed Cask`, and `Half Lake`, and `stack_duration_pct [thuy, debuff]` (`ltp-cut-wine-cask`, `sweet-spring-wine-rite`) extends them, while `stack_effect_pct [thuy, debuff]` currently has no `dsum` multiplier target. Kept verbatim as required.

---

## 2. Faithfulness, rules, and stand-in audit

- **Engine parity verified** across both `engine.py` and `src/gameplay/combat/fight/` (`not_tags`, `per_firing`, `stack_more` fractional `0.1`, `status_resist` / `soul_res` percent points, `heal {of: "amount"}`, `art.heal` executing before `art_fired`, `drunk` `stack_timers` without explicit `dur`, `add_statuses` in `empower`, `ward_grow`, `overflow`).
- **Stances:** No holder slots two stances without a combined stance (`open-the-cask` tracks its 6 s mist via counter `wine_mist`, leaving `deep-lake-stance` intact on `mai_le_tuyen` and `nhac_thuan_nhuong`).
- **Items & sets:** Exact 1:1 diff against `design/world/depth/sects/le_tuyen.items.json` on all 6 items and both sets (28/28 modifier lines run, all 6 `unique: true`, `sources: ["npc"]`, and all 6 bases `cham`/`an`/`ho_lo`/`dao_bao`/`giap` carry the R6 `exception` mark matching `bang_tam`).
- **Stand-ins & cast (20 people: 18 living, 2 dead):**
  - `khau_dai_ung` (`tho 50, hoa 30`, layer 5) and `khau_nhi_dam` (`tho 46, hoa 28`, layer 3) moved from `hoang_tho` to `yoke-and-axle-breath` (`["tho", "hoa"]`, Yellow main, `shoulder-the-yoke` at layer 1). Follows Step 5 order (lineage Wood/Water gates exclude Earth-Fire servants per `le_tuyen.md` §2/§5/§6; no note names another method; new owner method fits both roots with zero cross-owner dependencies).
  - All other 16 living cast members verified: roots, ranks, technique layers, and gear all valid (`issues: []`, `stand_ins: 0`, `unknown_ids: 0`, `cross_owner: 0`).
- **Design rules:** No environment conditions, no spatial fight (`spatial_words_check.py`: 0 non-soft hits in `le_tuyen` rule fields), scale without caps (`draught-steep` uncapped, `Drunk` uncapped, `Sealed Cask` and `Needle of Mending` cleanse now `per_firing: 1`), Effects unpriced.

---

## 3. Pending words (`design/stage6-staging/le_tuyen/pending.json`)

`pending.json` contains **0 words** (`{"words": [], "arts": [], "effects": {}}`). Confirmed:
- **`Needle of Mending` (no new word — keep `approx`):** Building a loadout-UI toggle + compiler damage-suppression path in both engines for a single unique item (`ltp-sweet-dew-needles`, 1 holder) is not worth the engine complexity. The `hit_landed` `approx` (heals `event.amount` + cleanses 1 debuff stack `per_firing: 1`, matching both `tags: ["needle"]` and `art_id: "needle-rain"` with `not_tags: ["needle"]`) keeps the intent and runs cleanly today.
- **`A Brimming Cup` (no new word — keep `approx`):** Firing `ward_grow {"share": 0.025, "of": "hp"}` on heal-tagged `art_fired` above `80 %` `qi_share` is actually *more* faithful to *"each heal you cast while above 80 % linh lực overflows"* than waiting for 100 % HP `heal_overflow`, because it works even while injured; consecutive `overflow` pulse tracking accurately measures holding full usable linh lực for 3 s.

---

## 4. Verification & holder table after fixes

All run with `$env:DEPTH_STAGE = "C:\Users\xphuo\IdeaProjects\my-game\design\stage6-staging\le_tuyen"`:
- `lint_arts.py`: 7 arts, **0 findings**.
- `lint_techniques.py`: 4 techniques (`7.6/8`, `15.9/16`, `15.4/16`, `7.8/8`), **0 findings**.
- `lint_items.py`: 6 items (`unique 6 of 6`), **0 findings**.
- `depth_check.py --quiet`: **findings: none**.
- `depth_gap.py --sect le_tuyen`: `stand_ins: 0`, `unknown_ids: 0`, `cross_owner: 0`, `engine_words: 0`, `wishes_open: 0`, `lines: 28/28 runs`.
- `sect_fight.py le_tuyen --seeds 5` and `--gap 1 --seeds 5`: **0 REFUSED**, every art fires on every holder.

| Holder / Probe | Realm | Arts (fires/fight at gap 0) | Gap 0 (`mean_s`, wins, HP) | Gap 1 (`mean_s`, wins, HP) | Effects (`with` vs `without`, runs) |
|---|---|---|---|---|---|
| `mai_le_tuyen` | `ket_dan` | `deep-lake-stance` (6.0), `gathering-wave` (3.0), `brimming-cup` (3.0), `swelling-tide-palm` (4.4), `hundred-herb-draught` (3.0), `bitter-root` (3.0) | `15.9 s`, 5/5, `100%` | `15.2 s`, 0/5, `0%` | **A Brimming Cup**: gap 0 `15.9 s 100%` vs `16.5 s 100%` (`49` runs); gap 1 `15.2 s 0%` vs `15.2 s 0%` (`21` runs; ward/ready gated by Nguyên Anh ward drain dropping qi below 80 % before t=4.7 s); **Needle of Mending**: `0` runs in `sect_fight` (does not slot weapon common art `needle-rain`; verified in probes below) |
| `nhac_thuan_nhuong` | `ket_dan` | `hundred-herb-draught` (4.8), `bitter-root` (4.8), `open-the-cask` (3.0), `last-cup` (5.0), `deep-lake-stance` (9.6), `gathering-wave` (5.0) | `24.2 s`, 5/5, `100%` | `45.4 s`, 0/5, `0%` | **Sealed Cask**: gap 0 `24.2 s` vs `23.9 s` (`49` runs); gap 1 `45.4 s` vs `21.6 s` (`77` runs, `+23.8 s`); **Half Lake**: gap 0 `24.2 s` vs `23.6 s` (`75` runs); gap 1 `45.4 s` vs `21.2 s` (`180` runs, `+24.2 s`) |
| `ha_thanh_to` | `truc_co` | `hundred-herb-draught` (10.6), `bitter-root` (10.6), `open-the-cask` (6.8), `last-cup` (11.0) | `54.5 s`, 5/5, `99%` | `8.2 s`, 0/5, `0%` | n/a |
| `can_tri_vi`, `gia_tuyen_phong` | `truc_co` | `hundred-herb-draught` (11.0), `bitter-root` (10.8), `open-the-cask` (6.8), `last-cup` (11.2) | `55.3 s`, 5/5, `99%` | `8.2 s`, 0/5, `0%` | n/a |
| `phuong_kim_cham`, `nhac_du_huong`, `ngai_bach_chi` | `truc_co` | `hundred-herb-draught` (11.6), `bitter-root` (11.6) | `63.8 s`, 3/5, `7%` | `8.0 s`, 0/5, `0%` | n/a (`draught-steep` verified separately: 5/10 wins `8.1%` HP vs 3/10 `3.0%` HP without) |
| `trac_linh_tuyen`, `loc_thao_nhi`, `nhu_tri_thu`, `lien_than_ha` | `luyen_khi` | `hundred-herb-draught` (9.2), `bitter-root` (9.2) | `58.6 s`, 0/5, `0%` | `8.0 s`, 0/5, `0%` | n/a |
| `bac_trieu_am`, `lu_tieu_khuc`, `sa_au_lan` | `luyen_khi` | `morning-dew` (10.2), `leaf-drip` (17.0) | `56.8–57.0 s`, 4/5, `15%` | `8.0 s`, 0/5, `0%` | n/a |
| `truong_ham_chuoc` | `luyen_khi` | `morning-dew` (9.0) | `49.2 s`, 0/5, `0%` | `8.0 s`, 0/5, `0%` | n/a (layer 1 outer disciple: heal+cleanse + basic attack) |
| `khau_dai_ung`, `khau_nhi_dam` | `luyen_khi` | `shoulder-the-yoke` (15.0) | `47.4 s`, 1/5, `2%` | `8.0 s`, 0/5, `0%` | n/a |
| **Probe 1a:** `mai_le_tuyen` (`family-metal` `needle-rain` + `leaf-drip` vs burn KD, 10 seeds) | `ket_dan` | `needle-rain` (6.9), `leaf-drip` (22.7) | `57.5 s`, 10/10, `30%` | — | **Needle of Mending**: `414` heal procs (`69 × 6` sub-hits), `69` cleanse procs (`1` per firing), `0` `common` double-procs |
| **Probe 1b:** `mai_le_tuyen` (`common-arts` `needle-rain` + `leaf-drip` vs burn KD, 10 seeds) | `ket_dan` | `needle-rain` (33.7), `leaf-drip` (13.2) | `33.8 s`, 10/10, `100%` | — | **Needle of Mending**: `337` heal procs, `337` cleanse procs (`1` per firing), `0` `tag` double-procs; `100%` HP vs `61%` HP without (`+39%` HP) |
| **Probe 2:** `mai_le_tuyen` (`morning-dew` only vs typical KD, 10 seeds) | `ket_dan` | `morning-dew` | `65.0 s`, 10/10, `27%` | — | **A Brimming Cup**: `10/10` (`27%` HP) vs `0/10` (`0%` HP) without; `150` ward (`2.5%` HP), `236` overflow, `66` ready, `37` spend |

CHECKPOINT DONE
