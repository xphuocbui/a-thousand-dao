# Hàm Nguyệt Trang (`ham_nguyet`): Stage 6 review (headless, auto-accepted)

## Summary

- **Built (staged in `design/stage6-staging/ham_nguyet/`):**
  - **3 techniques** (`techniques/catalogue-sect-ham_nguyet.json`): `pearl-diver-breath` (Yellow main), `moon-holding-scripture` (Earth main), `nacre-over-grit-canon` (Profound secret).
  - **5 new arts** (`arts/part-sect-ham_nguyet.json`): `empty-lungs`, `the-moon-in-the-water`, `full-pool`, `wrap-the-grain`, `cast-the-pearl`. Art IDs inserted into `design/world/depth/sects/ham_nguyet.techniques.json`.
  - **4 items & 1 set** (`items/catalogue-sect-ham_nguyet.json`, `items/sets-ham_nguyet.json`): `hn-tuyet-loc-fist-pearl` (`kind: treasure`, `grade: 4`, `rarity: 5`), `hn-moon-fish-lantern`, `hn-nacre-robe`, `hn-frost-lotus-pin`, and 3-piece set `hn-moon-over-pearl`. All 4 items marked `unique: true` and `sources: ["npc"]`; the 3 weapon/armour pieces carry the R6 `exception`.
  - **3 Effects** (`effects/ham_nguyet.effects.json`): `The Pearl Remembers`, `False Moon`, `What Hurts You, Wrap`. All 3 compile and run standalone with declared shared `counters`.
  - **0 stand-ins, 0 beasts, 0 early promotions, 0 pending words.**
- **Deviations (5):**
  1. `empty-lungs`: status/delay/air-poison protection modelled via `status_immune` (`tags: ["heavy_breath", "silence", "sealed_meridian"]`), `delay_immune 1`, and `status_resist 50` (5 s) because no "choke" or "air-poison" flag exists separately.
  2. `the-moon-in-the-water`: `decoy_struck` carries no damage `amount`, so reflection strike restores a fixed `0.08` `qi_max` instead of "part of the blow", and triggers on any avoided direct hit (including basic/companion) to keep the decoy and `refl_up` counter synchronized; unstruck decoys expire via `refl_t` counter (`decoy -1` after 4 s).
  3. `wrap-the-grain`: tracked via self-counter `wrap_stance` rather than the single fighter `state` slot so it coexists with `deep-lake-stance` (both `kieu_nguyet_chau` and `muc_tiem_uyen` slot both stances).
  4. `cast-the-pearl`: deals a fixed `c_art 2.0` Water hit (gated by spending 1 `pearl`) because active casts cannot read a prior foe art's raw coefficient.
  5. `The Pearl Remembers`: "4 % of maximum linh lực per stack" is expressed as `ward_grow {share: 0.04, of: "hp"}` per stack, matching the established `combat_effects.json` convention (`The Door Stays Shut`).
- **Auto-accepted decisions (5):** all logged in §B below.
- **Pending words:** none.
- **Never ran:** none (all 5 arts fire and all 3 Effects run on their real holders; `The Pearl Remembers` spend/clear + `What Hurts You, Wrap` freeze/ice clauses fire below 1/3 HP as verified in `--gap 1` and a mid-hard Kết Đan probe).
- **Open items for the serial step / Stage 7:** merge `design/stage6-staging/ham_nguyet/` via `stage6_merge.py ham_nguyet`, run exporters (`export_techniques.py`, `export_named.py`, `export_combat_library.py`), and close the 4 structured chronicle events (`N-ham_nguyet-01..04`) in Stage 7.

---

## A. Mechanics & Rule-to-Engine Comparison

### Techniques (`design/stage6-staging/ham_nguyet/techniques/catalogue-sect-ham_nguyet.json`)
All bonuses and passives are newly sized against same-tier catalogue methods (`catalogue-water.json`, `catalogue-sect-bang_tam.json`) and unpriced (`catalogue-sect-` prefix).

| Technique | Tier, kind | Bonuses (new) | Passives (new) | Arts (unlock layer) |
|---|---|---|---|---|
| `pearl-diver-breath` | Yellow (0) main, Water (`thuy`) | none (`bonus_count: 0`) | `linh_luc_regen_inc_pct 7`, `status_resist_pct 5` (7.6 W of 8) | `gathering-wave` (1), `empty-lungs` (2) |
| `moon-holding-scripture` | Earth (2) main, Water (`thuy`) | `linh_luc_pct 12`, `defense_pct 10` (`bonus_count: 2`) | `ward_efficiency_pct 8`, `healing_pct 10`, `health_regen_inc_pct 12`, `linh_luc_regen_inc_pct 5`, `stack_duration_pct 12 ["thuy", "buff"]` (23.0 W of 24) | `deep-lake-stance` (1), `full-pool` (2), `the-moon-in-the-water` (4) |
| `nacre-over-grit-canon` | Profound (1) secret, Water (`thuy`) | `defense_pct 8` (`bonus_count: 1`) | `ward_efficiency_pct 6`, `stack_effect_pct 10 ["thuy", "buff"]`, `status_resist_pct 8`, `attack_pct 6 ["thuy"]` (15.7 W of 16) | `wrap-the-grain` (1), `cast-the-pearl` (3) |

### Arts (`design/stage6-staging/ham_nguyet/arts/part-sect-ham_nguyet.json`)

| Art | Depth text | Engine form | Deviation |
|---|---|---|---|
| `empty-lungs` | Cannot be choked, poisoned through the air or broken out of a channel for a few seconds; faster linh lực regen while it lasts | `c_art 0`, `cost 0.03`, `cd 8`; for 5 s: `regen 0.03`, `delay_immune 1`, `status_resist 50`, plus `status_immune 1` on `tags: ["heavy_breath", "silence", "sealed_meridian"]` | Proxy using existing status tags + delay immunity + status resist |
| `the-moon-in-the-water` | Gains a Reflection charge for a few seconds; next foe art hits reflection instead and restores linh lực equal to part of the blow | Guarded `refl_up < 1`; `c_art 0`, `cost 0.04`, `cd 8`; `decoy 1`, `refl_up 1`, `refl_t 4`; `decoy_struck` restores `0.08 qi_max` and clears; pulse expiry removes `decoy -1` after 4 s | Fixed `8 % qi_max` return (`decoy_struck` has no `amount`); triggers on any avoided direct hit |
| `full-pool` | Slow heal over time growing stronger for each second the holder has not moved | `c_art 0`, `c_heal 0.5`, `cost 0.04`, `cd 7`; 4 s HoT: `1.5 %` max HP + `0.5 %` per second of `own.since_act` (uncapped) | None (`since_act` tracks non-movement/non-damaging stillness) |
| `wrap-the-grain` | A stance: each foe art that hits adds a Nacre stack and a small ward; 5 stacks become 1 Pearl | Guarded `wrap_stance < 1`; `cost 0.04`, `cd 6`; sets `wrap_stance = 1` + `ward_grow 0.04`; `was_hit (kind: art)` adds `1 nacre` + `ward_grow 0.025`; `5 nacre -> 1 pearl` + `pearl_just_made` | Tracked on self-counter `wrap_stance` so it coexists with `deep-lake-stance` |
| `cast-the-pearl` | Spends a Pearl to return the last art that struck her at half its damage, as Water | Guarded `pearl >= 1`; `c_art 2.0` Water, `cost 0.04`, `cd 5`; spends 1 `pearl` | Fixed `c_art 2.0` proxy (no foe-art coefficient memory) |

### Effects (`design/stage6-staging/ham_nguyet/effects/ham_nguyet.effects.json`)

| Effect (source item/set) | Depth text | Engine form | Deviation |
|---|---|---|---|
| `The Pearl Remembers` (`hn-tuyet-loc-fist-pearl`) | Each Pearl made stores 1 Nacre (fades in 30 s); below 1/3 HP spends all for 4 % max linh lực ward per stack | `fist_nacre` (`each_for: 30`) +1 on `pearl_just_made`; crossing `<= 0.3334` HP (hit or pulse) grows stance ward `0.04 * hp_max` per stack and sets `fist_spent = 1` (rearmed above `0.3334` HP) | `ward_grow {of: "hp"}` 4 % proxy matching `The Door Stays Shut` |
| `False Moon` (`hn-moon-fish-lantern`) | Reflection lasts twice as long; while up, regenerate linh lực as if cultivating | `art_fired` on `the-moon-in-the-water` adds `+4` to `refl_t` (8 s total); `always` while `refl_up >= 1` adds `+0.035` `regen` (doubles base meditation regen) | None |
| `What Hurts You, Wrap` (`hn-moon-over-pearl`, 3-pc) | Absorbed foe arts lay Fist Nacre; when Fist spends Nacre, ward freezes unbreakable 2 s and next pearl carries 2 Ice stacks | `ward_absorbed (kind: art, cd 0.1)` adds `+1 fist_nacre`; `fist_spent >= 1` (hit or pulse) grants `ward_fixed 1` for 2 s and `next_pearl_ice = 2`; `cast-the-pearl` lays 2 Ice stacks (8 s) | None (`cooldown 0.1` prevents multi-part / split double-counting) |

### Items & Set (`items/catalogue-sect-ham_nguyet.json`, `items/sets-ham_nguyet.json`)
- **4 items**, all `unique: true`, `sources: ["npc"]`:
  - `hn-tuyet-loc-fist-pearl` (`treasure`, `an`, `grade: 4`, `rarity: 5`, R6 `exception`, Effect `The Pearl Remembers`)
  - `hn-moon-fish-lantern` (`artifact`, `dang`, `grade: 3`, Effect `False Moon`)
  - `hn-nacre-robe` (`artifact`, `dao_bao`, `grade: 3`, R6 `exception`)
  - `hn-frost-lotus-pin` (`artifact`, `cham`, `grade: 3`, R6 `exception`)
- **1 set:** `hn-moon-over-pearl` (2-pc: `linh_luc_pct 6`, `ward_efficiency_pct 2`; 3-pc: `What Hurts You, Wrap`).

---

## B. Auto-Accepted Decisions

1. **Coexistence of `wrap-the-grain` and `deep-lake-stance`:** Used a self-counter `wrap_stance` instead of the single fighter `state` slot so `kieu_nguyet_chau` and `muc_tiem_uyen` can hold both `deep-lake-stance` and `wrap-the-grain` simultaneously without overwriting `deep-lake` (consistent with `nhan_van`'s `ink-sediment`).
2. **Proxy for `cast-the-pearl` damage:** Used an active guarded Water strike (`c_art 2.0`, spending 1 `pearl`) rather than adding a new engine word for "foe's last art coefficient", keeping all records playable and lint-clean in Stage 6 without engine changes.
3. **Proxy for `the-moon-in-the-water` return & `False Moon` regen:** Used `decoy_struck` -> `0.08 qi_max` restore (since `decoy_struck` carries no damage `amount`) and `refl_t` counter expiration (`decoy -1` after 4 s, +4 s with `False Moon`), plus `+0.035` `regen` bonus (matching `combat_engine.json` `regen_base`) while `refl_up >= 1`.
4. **Ward size on `The Pearl Remembers`:** Used `ward_grow {share: 0.04, of: "hp"}` per `fist_nacre` stack, matching the established `combat_effects.json` convention (`The Door Stays Shut`) so the emergency ward is meaningful at all realms.
5. **Technique bonuses/passives & R6 / unique items:** Sized all 3 techniques' unpriced bonuses and passives within their tier budgets (`7.6/8`, `23.0/24`, `15.7/16`), added `rarity: 5` on `hn-tuyet-loc-fist-pearl` (`treasure`), marked all 4 items `unique: true`, and applied R6 `exception` to `hn-tuyet-loc-fist-pearl`, `hn-nacre-robe`, and `hn-frost-lotus-pin`.

---

## C. Pending Engine Words

None. All 5 arts and 3 Effects run on the current Python and GDScript engine vocabulary.

---

## D. Holder Check (`sect_fight.py ham_nguyet --seeds 5`, `DEPTH_STAGE=design/stage6-staging/ham_nguyet`)

| Holder | Realm | Slotted Arts | Gap 0 (`mean_s / wins / hp`) | Gap 1 (`mean_s / wins / hp`) | Notes |
|---|---|---|---|---|---|
| `kieu_nguyet_chau` | `ket_dan` | `deep-lake-stance`, `full-pool`, `the-moon-in-the-water`, `wrap-the-grain`, `cast-the-pearl`, `seep-through-palm` | `34.0 s / 5 / 100%` | `17.6 s / 0 / 0%` | All 6 arts fire (`12.8, 5.4, 4.4, 1.0, 3.0, 12.8`). `The Pearl Remembers` (15 runs gap 0; 19 runs gap 1: `17.6 s` vs `16.8 s`), `What Hurts You, Wrap` (70 runs gap 0; 48 runs gap 1: `17.6 s` vs `16.8 s`). Against a mid-hard Kết Đan foe (`[180,120,60,30,0]`), `spend hit` (4), `freeze hit` (4), and `pearl` 2-Ice (4) all fire (`40.6 s / 5 / 56%`). |
| `muc_tiem_uyen` | `ket_dan` | `deep-lake-stance`, `full-pool`, `the-moon-in-the-water`, `wrap-the-grain`, `cast-the-pearl` | `49.8 s / 5 / 100%` | `14.8 s / 0 / 0%` | All 5 arts fire (`16.6, 6.4, 6.2, 1.0, 6.0`). `False Moon` runs `31` times at gap 0 and `4` times at gap 1 (`14.8 s` vs `14.6 s`). |
| `lam_ham_suong` | `truc_co` | `deep-lake-stance`, `full-pool`, `the-moon-in-the-water`, `seep-through-palm`, `marrow-to-dew`, `drag-of-the-deep` | `28.4 s / 5 / 100%` | `20.5 s / 0 / 0%` | All 6 arts fire (`10.6, 4.4, 3.4, 10.6, 4.4, 6.4`). |
| `quach_bat_tram` | `truc_co` | `deep-lake-stance`, `full-pool`, `the-moon-in-the-water`, `seep-through-palm`, `marrow-to-dew` | `35.8 s / 5 / 100%` | `16.0 s / 0 / 0%` | All 5 arts fire (`13.6, 5.8, 4.8, 13.6, 5.8`). |
| `dam_thiem_dang` | `truc_co` | `deep-lake-stance`, `full-pool`, `the-moon-in-the-water`, `seep-through-palm` | `36.3 s / 5 / 100%` | `10.2 s / 0 / 0%` | All 4 arts fire (`13.8, 5.8, 4.8, 13.8`). |
| `kha_toan_chau`, `dao_nguyet_lan`, `phan_tinh_ba` | `truc_co` | `deep-lake-stance`, `full-pool`, `the-moon-in-the-water` | `51.8 s / 5 / 99%` | `10.8 s / 0 / 0%` | All 3 arts fire (`17.2, 6.6, 6.0`). |
| `nhan_bich_thuy`, `thu_anh_dam`, `vien_tiem_nhi`, `mong_loc_nhi`, `la_tu_chau`, `dinh_luu_ly` | `luyen_khi` | `deep-lake-stance`, `full-pool` | `50.6 s / 5 / 99%` | `8.4 s / 0 / 0%` | Both arts fire (`16.8, 6.4`). |
| `kieu_vong_thiem`, `mong_bach_giac`, `la_tieu_boi`, `nguy_tieu_ngu` | `luyen_khi` | `gathering-wave`, `empty-lungs` | `63.0 s / 0 / 0%` | `8.0 s / 0 / 0%` | Both arts fire (`12.0, 7.0`). Outer `pearl-diver-breath` has no Tide source for `gathering-wave` crests and deals light damage, matching its depth concept ("long, even linh lực and very little else"). |
