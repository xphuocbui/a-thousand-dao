# Chân Kim Các: Stage 6 Review

## Summary

- **What was built:** 3 element-free (`names: []`) techniques (`touchstone-primer`, `true-gold-canon`, `hundred-refinings-art`), 4 active arts (`streak-on-the-stone`, `assay`, `the-furnace-shows`, `part-the-dross`), 1 passive technique Effect (`True Gold Does Not Fear the Furnace`, d31), 5 signature unique items (`ck-hundred-fold-crucible`, `ck-house-weight`, `ck-hallmark-seal`, `ck-refiner-robe`, `ck-counterweight-coin`), 2 sets (`ck-assayer-tools`, `ck-scale-pair`), and 5 item/set Effects (`Nothing False Survives`, `A Hair Light`, `Touchstone`, `Tried and Stamped`, `A Second Lean` — 6 Effects total in `chan_kim.effects.json`).
- **Deviations:** 5 records carry engine approximations/adaptations (logged in §C–§F below): `the-furnace-shows` ("cannot gain new buffs" -> `exposed` + pulse `strip` 99 for 4 s, matching `thien_xu`'s `Sealed Writ`); `part-the-dross` ("lowers foe's attack" -> `dampen_taken` +3 per stack in 1v1); `Nothing False Survives` ("burns off twice as fast" -> `ward_bill` +50 + pulse `strip` 1 every 2 s; appraisal is lore); `A Hair Light` (roll-tipping -> `was_hit` charge grants `+25 evade`, `+25 status_resist` for 3 s and `sure_crit`); `A Second Lean` (see next art -> `+15 evade`, `+20 acc` for 3 s).
- **Decisions taken (auto-accepted):** 6 decisions logged in §A below (new passives/bonuses for `touchstone-primer` and `hundred-refinings-art`, `assay` ward-share vs no-ward fallback, `the-furnace-shows` buff lock, `part-the-dross` 1v1 attack reduction, `Nothing False Survives` ward/buff burn, `A Hair Light` / `A Second Lean` roll tipping and foresight).
- **Pending words:** none (`pending.json` not needed; all mechanics expressible cleanly using existing engine words).
- **Never ran against `typical` foe (with reason):** `Touchstone` (`ck-hallmark-seal`) and `Tried and Stamped` (`ck-assayer-tools` 3-pc) on `tuong_bach_luyen` report `runs 0` against `typical` enemies because `typical` enemies carry no buffs; verified in a dedicated test against a buff-slotted `typical` enemy (`feed-the-fire` + `packed-earth-stance`) where `Touchstone` ran 10 times and `Tried and Stamped` marked 10 / burned 25 times (`20.6 s`, `5/5` wins, `97 %` HP left).
- **Early promotions:** none (`censer-smoke-manual` for `phung_xich_kim` is already merged in `design/techniques/catalogue-sect-market-folk.json` and `design/arts/part-sect-market-folk.json` from `b01`).
- **Open items:** serial merge of `design/stage6-staging/chan_kim/` into `design/` and `assets/data/combat_effects.json`, and Stage 7 world export (`N-chan_kim-01`, `N-chan_kim-02`).

---

## A. Auto-accepted decisions (logged with reasons)

1. **New technique bonuses and passives (`touchstone-primer`, `true-gold-canon`, `hundred-refinings-art`):**
   - Depth records supplied `passives` for `true-gold-canon` (`b3, b5`), and none for `touchstone-primer` or `hundred-refinings-art` or `bonuses`.
   - **Choice:** Sized `touchstone-primer` Yellow passives (`8.0 W` of `8`: `than_thuc_pct 2`, `accuracy_pct 4`, `resist_pen_pct 10`, `linh_luc_regen_inc_pct 3`), `true-gold-canon` Profound bonus (`than_thuc_pct 10`), and `hundred-refinings-art` Profound bonus (`attack_pct 8`) + passives (`14.2 W` of `16`: `attack_pct 4`, `resist_pen_pct 20`, `than_thuc_pct 4`, `accuracy_pct 6`). All keys are consumed by both engines with no scope gaps.
   - **Reason:** Matches the house's spirit-sense assaying and resistance-parting identity while staying inside standard tier budgets.

2. **`Assay` ("strips one buff or a share of the ward; if the foe has none, the holder's next strike is critical"):**
   - **Choice:** If `foe.buff_elements >= 1`, strips 1 stack from the largest pile (`strip {n: 1}`); else if `foe.qi_share > 0.05` (ward still active), burns 4 % of `foe.qi_max` (`burn_qi`) and grants `+30` resistance penetration (`pen`) for 4 s; else (`foe.buff_elements == 0` and `foe.qi_share <= 0.05`), sets `assay_crit` (`sure_crit` on next direct strike). Both buff and ward strips set `assay_did_strip` so `True Gold Does Not Fear the Furnace` (L4) triggers on both.
   - **Reason:** Keeps every clause active on real fights (`typical` enemies have drain wards and no buffs, so ward-strip runs regularly and feeds `True Gold Does Not Fear the Furnace`, while depleted/wardless foes trigger the crit payoff).

3. **`The Furnace Shows` ("loses a part of its defence and cannot gain new buffs"):**
   - **Choice:** Applies `exposed` (`-100` all resistance, 3 s) and sets `furnace_shows = 4` (stripping up to 99 buff stacks on `hit_landed` and each `pulse` for 4 s).
   - **Reason:** Follows the existing Stage 6 precedent (`thien_xu` `Sealed Writ`) without needing a new `no_buff` status or flag.

4. **`Part the Dross` ("lowers the foe's attack slightly and adds it to the holder's; each stack lasts 4 s"):**
   - **Choice:** Uses an `each_for: 4` charge counter `dross` incremented on every direct hit (`not_tags: ["trigger"]`) and by `True Gold Does Not Fear the Furnace`. Scales `L1 +4` and `dampen_taken +3` per stack.
   - **Reason:** Since fights are strictly 1v1 (2026-11-26 ruling) and no engine status lowers foe attack directly, `dampen_taken +3` per stack models the reduced incoming strike damage cleanly in both engines without a new pending word.

5. **`Nothing False Survives` (`ck-hundred-fold-crucible`):**
   - **Choice:** `always` `ward_bill +50` (foe drain wards burn linh lực 50 % faster) plus `pulse` (`cooldown: 2`) `strip {n: 1}` when `foe.buff_elements >= 1`. Second sentence (item appraisal) kept as out-of-fight lore.
   - **Reason:** Models both ward and buff acceleration cleanly using existing words; `ward_bill` visibly impacts `tuong_bach_luyen`'s fight (`24.0 s, 76 % HP` vs `30.7 s, 69 % HP` without).

6. **`A Hair Light` (`ck-house-weight`) and `A Second Lean` (`ck-scale-pair` 2-pc):**
   - **Choice:** `A Hair Light` grants 1 `hair_light_charges` at `fight_start`; `A Second Lean` adds +1 charge (so 2/fight). On `was_hit` (`not_tags: ["trigger"]`, i.e., a defensive roll weighed against you), spends 1 charge to grant `+25 evade` and `+25 status_resist` for 3 s and arms `sure_crit` on the next direct hit; when `A Second Lean` is active, that same tip also grants `+15 evade` and `+20 acc` for 3 s (`eff:A Second Lean read` in a separate record so `temp_mods` do not overwrite).
   - **Reason:** No engine word exists to rewind a failed RNG roll retroactively; tipping the immediate defensive/offensive exchange once (twice with set) faithfully captures the "thumb on the scale" mechanic and shows strong identity on `tuong_ngoc_can`.

7. **Signature items R6 & R7:**
   - **Choice:** All 5 items carry `sources: ["npc"]` and `unique: true`; `ck-hundred-fold-crucible` (`kind: "treasure"`, `grade: 4`) carries `rarity: 5`; the 4 weapon/body_gear pieces carry the standard R6 `exception`.
   - **Reason:** Complies with `lint_items.py` and Băng Tâm R6/rule 20f rulings.

---

## B. Pending words

None (`0` engine words needed).

---

## C. Techniques (`design/stage6-staging/chan_kim/techniques/catalogue-sect-chan_kim.json`)

| Technique | Tier, kind | `names` | Bonuses (new) | Passives | Arts / Effects (unlock layer) |
|---|---|---|---|---|---|
| `touchstone-primer` | Yellow (0), main | `[]` | none (`bonus_count: 0`) | **new (8.0 W):** `than_thuc_pct 2`, `accuracy_pct 4`, `resist_pen_pct 10`, `linh_luc_regen_inc_pct 3` | `streak-on-the-stone` (1) |
| `true-gold-canon` | Profound (1), main | `[]` | **new:** `than_thuc_pct 10` | depth (14.2 W): `stack_effect_pct 12 [kim, debuff]`, `stack_duration_pct 16 [kim, debuff]`, `status_resist_pct 20 [poison]`, `khi_huyet_pct 6.6` | `assay` (1), `the-furnace-shows` (2); Effect: `True Gold Does Not Fear the Furnace` (4, passive art) |
| `hundred-refinings-art` | Profound (1), secret | `[]` | **new:** `attack_pct 8` | **new (14.2 W):** `attack_pct 4`, `resist_pen_pct 20`, `than_thuc_pct 4`, `accuracy_pct 6` | `part-the-dross` (1) |

---

## D. Arts (`design/stage6-staging/chan_kim/arts/part-sect-chan_kim.json`)

| Art | Depth text | Engine form | Deviation |
|---|---|---|---|
| `streak-on-the-stone` | Marks a foe after the holder's first hit: for a few seconds the holder's strikes against the marked foe ignore part of their resistances. | `kind: "phys"`, `c_art: 1.4`, `cost_share: 0.03`, `cd: 3.0`, `tags: ["seal", "pierce"]`; on `hit_landed`: `mod {pen: 40, for: 5.0}`. | Marks on every landing hit of this art (refreshes 5 s window). |
| `assay` | Strips one buff or a share of the ward from a foe; if the foe has none, the holder's next strike is critical. | `kind: "phys"`, `c_art: 1.2`, `cost_share: 0.04`, `cd: 5.0`, `tags: ["seal", "control"]`; `art_fired`: if `foe.buff_elements >= 1` -> `strip {n: 1}`; elif `foe.qi_share > 0.05` -> `burn_qi {of: qi_max, share: 0.04}` + `pen 30 (4 s)`; else `assay_crit` (`sure_crit` on next direct hit). | Ward share read as 4 % max linh lực burned + 30 `pen` for 4 s; `sure_crit` fires when foe holds neither buffs nor >5 % linh lực. |
| `the-furnace-shows` | For a few seconds the foe loses a part of its defence and cannot gain new buffs. | `kind: "phys"`, `c_art: 1.0`, `cost_share: 0.04`, `cd: 7.0`, `tags: ["seal", "curse"]`, `statuses: [exposed (3 s)]`; on `hit_landed`: `strip {n: 99}`, `furnace_shows = 4`; on `pulse` while `>= 1`: `strip {n: 99}`, `-1`. | "Cannot gain new buffs" approximated via pulse `strip 99` for 4 s (as `Sealed Writ`). |
| `part-the-dross` | Each of the holder's hits lowers the foe's attack slightly and adds it to the holder's; each stack lasts 4 s. | `kind: "phys"`, `c_art: 1.5`, `cost_share: 0.04`, `cd: 3.5`, `tags: ["seal"]`; on direct `hit_landed` (`not_tags: ["trigger"]`): `+1 dross` (`each_for: 4`); `always` scaled by `dross`: `L1 +4, dampen_taken +3`. | "Lowers foe's attack" approximated as `dampen_taken +3` per stack in 1v1. |

---

## E. Effects (`design/stage6-staging/chan_kim/effects/chan_kim.effects.json`)

| Effect (source) | Depth text | Engine form | Deviation |
|---|---|---|---|
| `True Gold Does Not Fear the Furnace` (`true-gold-canon` L4, d31) | Each buff stack you strip from the foe, and each ward share your Assay strips, restores 1.5 % of your maximum linh lực and adds one Part the Dross stack. | On `assay` `art_fired` (if `assay_did_strip >= 1`): `gain_qi 0.015`, `+1 dross`, clear; on `pulse` (if `touchstone_stripped >= 1`, scaled): `gain_qi 0.015`, `+1 dross`, clear. Declares `assay_did_strip`, `touchstone_stripped`, `dross` (`each_for: 4`). | None (triggers on Assay buff/ward strips, Touchstone, and Tried and Stamped). |
| `Nothing False Survives` (`ck-hundred-fold-crucible`) | Every buff, ward or borrowed stat a foe gains while near you burns off twice as fast. You can tell whether any item you are shown is what its owner says it is. | `always`: `ward_bill +50`; `pulse` (`cooldown: 2`, if `foe.buff_elements >= 1`): `strip {n: 1}`. | "Burns off twice as fast" approximated as `ward_bill +50` + periodic `strip 1`; appraisal is out-of-fight lore. |
| `A Hair Light` (`ck-house-weight`) | Once a fight, you may make one roll that weighs against you come out slightly in your favour (a dodge, a resist or a crit). | `fight_start`: `+1 hair_light_charges`. On `was_hit` (`not_tags: ["trigger"]`, `charges >= 1`): `-1 charge`, `hair_light_crit = 1`, `hair_light_tipped = 1`, `evade +25, status_resist +25 (3 s)`. `always` `sure_crit` while `hair_light_crit >= 1`, cleared on direct `crit`. | Tipping a failed roll approximated as a post-hit dodge/resist window + guaranteed next crit. |
| `Touchstone` (`ck-hallmark-seal`, d38) | Once per art firing, your first hit on a foe that holds buff stacks strips one of them (its largest pile, oldest batch first). | On `hit_landed` (`kind: "art"`, `per_firing: 1`, `foe.buff_elements >= 1`): `strip {n: 1}`, `+1 touchstone_stripped`. | None. |
| `Tried and Stamped` (`ck-assayer-tools` 3-pc) | A foe your art hits while it carries a buff is stamped for 6 s; the next buff it gains burns off at once, and you gain a ward worth 5 % of your health. | On `hit_landed` (`kind: "art"`, `foe.buff_elements >= 1`): `stamped_ttl = 6`. On `pulse` while `stamped_ttl >= 1`: if `foe.buff_elements >= 1` -> `strip {n: 99}`, `ward_grow 5% hp`, `+1 touchstone_stripped`; decrement `stamped_ttl`. | None (burn-off checked per pulse during 6 s stamp). |
| `A Second Lean` (`ck-scale-pair` 2-pc) | The House Weight's tipped roll comes twice a fight; after each tipped roll you see the next art that foe will use. | `fight_start`: `+1 hair_light_charges`. On `was_hit` (`not_tags: ["trigger"]`, `hair_light_tipped >= 1`): clear `hair_light_tipped`, `evade +15, acc +20 (3 s)`. | "See the next art" modelled as `+15 evade, +20 acc` for 3 s. |

---

## F. Items and sets (`design/stage6-staging/chan_kim/items/`)

- **5 items** (`catalogue-sect-chan_kim.json`), all `sources: ["npc"]`, `unique: true`, modifiers matching `chan_kim.items.json` verbatim; `ck-hundred-fold-crucible` carries `rarity: 5`; the 4 weapon/body_gear pieces carry the R6 `exception`.
- **2 sets** (`sets-chan_kim.json`): `ck-assayer-tools` (3-pc) and `ck-scale-pair` (2-pc).
- **0 stand-ins, 0 beasts.** `phung_xich_kim`'s aux `censer-smoke-manual` (`market-folk`) is already merged from `b01`.

---

## G. Linters & Holder Check (`sect_fight.py chan_kim --seeds 5`)

- `lint_techniques.py`: `checked 3 techniques, 0 findings`
- `lint_arts.py`: `checked 4 arts in 1 files, 0 findings`
- `lint_items.py`: `checked 5 items, 22 bases, 9 common arts, 0 findings`
- `depth_check.py`: `findings: none`
- `depth_gap.py --sect chan_kim`: `0` `unknown_ids`, `0` `stand_ins`, `0` `engine_words`, `0` `wishes_open`, `0` `ties_unmapped`, `0` `ties_over_cap`.

### `sect_fight.py chan_kim --gap 0 --seeds 5` (0 `REFUSED`, all 17 living holders)

| Holder | Realm | Arts (fires/fight) | Mean s | Wins | HP left | Effects (with vs without, runs) |
|---|---|---|---|---|---|---|
| `tuong_bach_luyen` | `ket_dan` | `assay` (4.4), `the-furnace-shows` (3.0), `part-the-dross` (6.4) | 24.0 | 5 | 76% | `True Gold...`: 24.0s 76% vs 24.2s 75% (16); `Nothing False Survives`: 24.0s 76% vs 30.7s 69% (always `ward_bill` live); `Touchstone`: 0 (`typical` foe has no buffs); `Tried and Stamped`: 0 (`typical` foe has no buffs) |
| `tuong_ngoc_can` | `truc_co` | `assay` (7.8), `the-furnace-shows` (5.2) | 39.4 | 5 | 34% | `True Gold...`: 39.4s 34% vs 39.6s 33% (29); `A Hair Light`: 39.4s 34% vs 41.2s 27% (23); `A Second Lean`: 39.4s 34% vs 42.8s 23% (15) |
| `phung_xich_kim` | `truc_co` | `assay` (4.8), `the-furnace-shows` (3.8), `part-the-dross` (7.6), `pill-smoke` (3.8) | 27.0 | 5 | 62% | `True Gold...`: 27.0s 62% vs 29.2s 57% (20) |
| `on_song_ngoc`, `tuong_tri_chuan`, `duong_noan_ha` | `truc_co` | `assay` (9.0), `the-furnace-shows` (6.4) | 48.0 | 5 | 14% | `True Gold...`: 48.0s 14% vs 48.0s 7% (30) |
| `la_minh_nhan` | `truc_co` | `assay` (9.0), `the-furnace-shows` (5.6) | 48.0 | 2 | 7% | — (L3, below L4 passive) |
| `cu_tieu_hanh`, `tien_phan_vi`, `khuong_tieu_kim`, `luong_diem_chi` | `luyen_khi` | `assay` (7.0), `the-furnace-shows` (4.0) | 43.0 | 2 | 2% | — (L2–L3) |
| `nghiem_bac_sinh`, `nghiem_tuyet_ngan`, `on_bich_lien`, `on_tieu_kieu`, `quan_thap_thu` | `luyen_khi` | `streak-on-the-stone` (10.4) | 35.2 | 0 | 0% | — |

### `sect_fight.py chan_kim --gap 1 --seeds 5`
- `0 REFUSED`; all 17 holders load, every slotted art fires (`1.0–2.0` times before falling to +1 realm typical foe), `True Gold Does Not Fear the Furnace` (5–6 runs), `A Hair Light` (23 runs), `A Second Lean` (15 runs).

### Supplemental buffing-foe check (`tuong_bach_luyen` vs `typical` + `feed-the-fire` + `packed-earth-stance`, 5 seeds)
- Result: `20.6 s`, `5/5` wins, `97 %` HP left.
- Record runs: `eff:Touchstone` 10, `eff:Tried and Stamped mark` 10, `eff:Tried and Stamped burn` 25, `eff:Tried and Stamped tick` 38, `eff:Nothing False Survives buff` 22, `eff:True Gold Does Not Fear the Furnace assay` 15, `strip` 31, `clear` 31, `furnace-shows-open` 13, `furnace-shows-hold` 40.

REVIEW DONE
