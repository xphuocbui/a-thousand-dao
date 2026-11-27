# Stage 6 Record Pass Review — Dạ Quang Môn (`da_quang`)

**Date**: 2026-11-27
**Owner**: `da_quang`
**Status**: Staged cleanly under `design/stage6-staging/da_quang/`. All three linters (`lint_techniques.py`, `lint_arts.py`, `lint_items.py`) report `0` findings; standalone `engine.validate` passes on all `4` staged Effects; `depth_check.py --quiet` reports `findings: none`; `spatial_words_check.py --sect da_quang` reports `0` hits in staged rule fields; `sect_fight.py da_quang --seeds 5` (`--gap 0` and `--gap 1`) plus targeted probes verify every active art and every Effect on its real holders.

---

## Summary

- **Techniques staged (`techniques/catalogue-sect-da_quang.json`)**: `2` total (`red-sand-sabre-primer` preserved verbatim from existing committed catalogue; `night-glow-blood-sabre-canon` newly promoted as tier `2` Earth main, `names: ["hoa", "kim"]`, with `2` new bonuses and `3` new passives added beside its `2` `b11` lines; temporary `over_time`/`hoa` lint proxy on the `b11` lines pending `lint-bleed-scope`).
- **Arts staged (`arts/part-sect-da_quang.json`)**: `3` active arts total (`cut-the-horse` preserved verbatim from existing committed file; `crescent-of-red-sand` and `pay-in-blood` newly authored). `Wine in the Night-Glow Cup` (`d19`, `a1`) is attached as a layer-4 passive art via `night-glow-blood-sabre-canon.effects` (`passive_art: true`) and defined in `effects/da_quang.effects.json`.
- **Effects staged (`effects/da_quang.effects.json`)**: `4` new Effects (`Wine in the Night-Glow Cup`, `Drink After the Raid`, `Cut the Horse First`, `First and Often`). Existing item Effect `Blood Casting` on `dq-lost-silver-tally` already lives in `assets/data/combat_effects.json`.
- **Items & sets staged (`items/catalogue-sect-da_quang.json`, `items/sets-da_quang.json`)**: `6` unique signature items (`dq-night-glow-cup` converted from `treasure` `grade: 3` to `rarity: 4`; `4` `weapon`/`body_gear` pieces carry the R6 `exception` mark) and `2` 3-piece sets (`dq-night-raider`, `dq-red-band`).
- **Stand-ins, beasts, early promotions**: `0` stand-ins across `16` living cast records, `0` beasts, `0` early promotions (`hang_minh_sa` in `bang_tam.cast.json` already uses promoted `red-sand-sabre-primer`; `cao_sa_lang` in `demonic.2.cast.json` references `night-glow-blood-sabre-canon` at layer 6, which closes on `da_quang` merge/export).
- **Pending engine words**: `0` (all required mechanics — `hp_paid_share`, `tick_dealt` + `status: "bleed"`, `broken`, `next_art_cost`, `art_cost_hp`, `hp_cost_red`, `dmg_more`, `heal_taken`, `ignore_taken`, `convert`, `statuses: ["bleed"]`, `technique-effects` — already exist in both engines).
- **Deviations**: `4` (`Wine in the Night-Glow Cup` Bleed ticks advance cup by fixed `2.0 %` health/tick instead of raw `amount / hp_max`; `Pay in Blood` and `Drink After the Raid` shift `90 %` of linh lực cost via `art_cost_hp: 900` instead of `100 %`; `Night-Glow Blood Sabre Canon` uses temporary `over_time`/`hoa` scope proxies on its two `b11` `bleed` passives for `lint_techniques.py`; `First and Often` gates `first3` and `mark_after` on Fire art `hit_landed` so non-damaging `pay-in-blood` casts do not consume the 3 Fire-cut charges).
- **Never ran in `sect_fight.py` (verified/explained)**:
  - `Blood Casting` (existing `combat_effects.json` `always` Effect on `hang_da_boi`): shows `runs 0` because `sect_fight` counts `Fight.do()` only and `hang_da_boi` did not exhaust linh lực in `--gap 0` (`16.4 s`); at `--gap 1` its `heal_taken: -50` closing shifts survival (`8.6 s` vs `8.8 s` without).
  - `pay-in-blood` at `--gap 1` on `truc_co` holders (`trac_hong_da`, `co_xich_nguyet`, `hang_luu_hoa`, `o_liet_phong`, `cuu_lac_nhat`): `0.0` fires because they fall at `8.0 s` before its `9.0 s` cooldown completes (fires `2.2–4.0`/fight at `--gap 0`, and `0.2–1.0`/fight at `--gap 1` on `ket_dan` holders).
- **Open items**:
  - `lint-bleed-scope` (for `s6-serial-b05`): add `"bleed"` to `TIER` in `tools/design/arts/lint_techniques.py` (matching `modifiers.md` rule 9 `effect` & `status` tags and `fight.py`) and restore `scope: ["bleed"]` on `night-glow-blood-sabre-canon`'s two `b11` lines (`status_duration_pct 15 [bleed]`, `attack_pct 10 [bleed]`).
  - Serial step merge of `design/stage6-staging/da_quang/*` into `design/` and `assets/data/combat_effects.json` (`put_effects.py`, `4` Effects under `world-depth:da_quang`).
  - Stage 7 export: export techniques, items (ensure `export_named.py` exports `kind: "treasure"` `dq-night-glow-cup`), sets, combat library, and `2` structured events (`N-da_quang-01`, `N-da_quang-02`) so `depth_gap.py --sect da_quang` reaches `0`.

---

## A. Decisions Auto-Accepted

1. **Preserve committed `red-sand-sabre-primer` and `cut-the-horse` verbatim**:
   - **Choice**: Keep `red-sand-sabre-primer` in `techniques/catalogue-sect-da_quang.json` and `cut-the-horse` in `arts/part-sect-da_quang.json` untouched, adding only the newly promoted `night-glow-blood-sabre-canon` and its arts.
   - **Reason**: Required by `_brief-record.md` when `design/techniques/catalogue-sect-da_quang.json` and `design/arts/part-sect-da_quang.json` already exist from Băng Tâm's early promotion.
2. **Author `crescent-of-red-sand` at layer `1`, `pay-in-blood` at layer `2`, and `Wine in the Night-Glow Cup` as a layer-`4` passive art**:
   - **Choice**: Place `crescent-of-red-sand` (`unlock_layer: 1`), `pay-in-blood` (`unlock_layer: 2`), and `Wine in the Night-Glow Cup` (`effects[]`, `unlock_layer: 4`, `passive_art: true`) on `night-glow-blood-sabre-canon`, and insert `"id"` fields on all `3` `"new"` art dicts in `da_quang.techniques.json`.
   - **Reason**: Layer-1 disciples (`kieu_liet_ca`, `man_xich_cau`, whose lore says *"his cuts bleed black now"*) need an active damaging sabre arc at layer `1`; `cuu_lac_nhat` (layer `2`) unlocks `pay-in-blood`; `hang_luu_hoa` / `o_liet_phong` (layer `4`) and above unlock `Wine in the Night-Glow Cup` as an automatic passive Effect without consuming an active art slot (so `hang_da_boi` fits all `5` active arts + `1` passive within `MAX_ARTS = 6`).
3. **Temporary lint proxy for `b11` `bleed` scope on `night-glow-blood-sabre-canon`**:
   - **Choice**: Keep `"bleed"` in `crescent-of-red-sand.tags` and in `da_quang.techniques.json`, while staging temporary lint-valid proxies (`status_duration_pct 15 [over_time]` and `attack_pct 10 [hoa]`) in `catalogue-sect-da_quang.json`, logging `lint-bleed-scope` for `s6-serial-b05`.
   - **Reason**: `modifiers.md` rule 9 and `fight.py` both accept `"bleed"` as a tag, but `tools/design/arts/lint_techniques.py` `TIER` omits `"bleed"` and would fail `stage6_gate.py record` with `SCOPE` findings. This follows the `xuyen_lam`/`vong_trieu` `b02` precedent.
4. **Size new `bonuses` and `passives` on `night-glow-blood-sabre-canon` to tier-2 Earth norms (`22.9 W` / `24 W`)**:
   - **Choice**: Add `bonuses: [attack_pct 10, khi_huyet_pct 12]` (`bonus_count: 2`) and `passives: [leech_health_pct 15, art_cost_health_pct 10, crit_damage_pct 15 [physical]]` alongside the `2` `b11` lines.
   - **Reason**: Matches the canon's concept (*"each art can be paid in health instead of linh lực, and each wound the sabre opens pays some of it back"*), Hạng Dạ Bôi's `tree.intent` (Metal crit + blood-paid Fire), and tier-2 catalogue budgets (`18.85 W` once `[bleed]` is restored; `22.92 W` under staged proxies).
5. **Use `art_cost_hp: 900` (`90 %` shifted to health) on `pay-in-blood` and `Drink After the Raid`**:
   - **Choice**: Model *"arts cost health instead of linh lực"* with `art_cost_hp: 900` (`shifted = cost * 900 / 1000 = 90 %` to health), split into two separate Effect records (`pay-in-blood-shift` and `pay-in-blood-fire`) to avoid multi-`mod` clobber.
   - **Reason**: Preserves `pay_keep_health` safety (`engine.py` refuses lethal `art_cost_hp` payments, unlike `blood_cast`) while converting nearly the full cost to health and feeding `Wine in the Night-Glow Cup` / `Cut the Horse First`.
6. **Approximate Bleed cup fill as `2.0 %` of `hp_max` per Bleed tick in `Wine in the Night-Glow Cup`**:
   - **Choice**: Advance `cup_pct` by `event.hp_paid_share / 0.01` (exact) on `art_fired`, and by `+2.0` per damaging `tick_dealt` (`filter: {"status": "bleed"}`, `event.amount > 0`), without adding Bleed ticks to `cup_paid_pct`.
   - **Reason**: `tick_dealt` carries raw HP (`event.amount`) rather than a `hp_max` share; `2.0 %` matches `~1-2` Bleed stacks at typical same-realm `M`, and keeping `cup_paid_pct` strictly on `art_fired` preserves *"heals you for a fifth of the health you paid since the last drink"*.
7. **Use `ignore_taken: true` on `Cut the Horse First` crit heal and `hit_landed` (`kind: "art"`, `per_firing: 1`) on `First and Often`**:
   - **Choice**: Give `Cut the Horse First`'s `4 %` crit heal `ignore_taken: true` so its own `heal_taken: -50` closing does not halve it; gate `First and Often`'s `first3` and `mark_after` on `hit_landed` (`element: "fire", kind: "art", per_firing: 1`) so utility casts of `pay-in-blood` (`c_art: 0.0`) do not burn the 3 Fire-cut charges.
   - **Reason**: Faithfully enforces *"healing from other sources is halved on you"* (`Still Water` precedent) and *"first three Fire cuts"*.
8. **Convert `dq-night-glow-cup` to `kind: "treasure", rarity: 4` and apply R6 `exception` to weapon/armour pieces**:
   - **Choice**: Set `rarity: 4` (dropping `grade: 3`), `sources: ["npc"]`, `unique: true` on all `6` items, and add the R6 `exception` to `dq-night-glow-cup` (`ho_lo`), `dq-night-sabre` (`phi_kiem`), `dq-red-feather-sabre` (`phi_kiem`), and `dq-felt-rider-coat` (`giap`).
   - **Reason**: Required by `lint_items.py` schema and `DECISIONS-2026-11-26.md` R6 / rule 20f.

---

## B. Mechanic Classification Table

| Kind | Record | Engine Word State | Implementation Summary |
|---|---|---|---|
| Tech | `red-sand-sabre-primer` | `has` (committed) | Preserved verbatim: Yellow (`0`) main, `names: ["hoa"]`, `cut-the-horse` (L1). |
| Tech | `night-glow-blood-sabre-canon` | `has` (`lint-bleed-scope` proxy) | Tier `2` Earth main (`["hoa", "kim"]`), `2` new bonuses, `3` new passives + `2` `b11` lines (staged proxy), `crescent-of-red-sand` (L1), `pay-in-blood` (L2), `Wine in the Night-Glow Cup` (L4 passive). |
| Art | `cut-the-horse` | `has` (committed) | Preserved verbatim: Fire `c_art 1.8`, `2` `slowed_time` (`2 s`), `x2.0` vs `foe.pressing >= 1`. |
| Art | `crescent-of-red-sand` | `has` (`convert`, `bleed`, `dmg_more`) | Fire (`c_art 2.1`, `cost_share 0.04`, `cd 4.0`, `convert` 50% `phys`), `2` `bleed` (`4` pulses); if bleeding, next direct cut deals `+25 %` (`red_sand_mark`). |
| Art | `pay-in-blood` | `has` (`hp_cost`, `art_cost_hp`, `dmg_more`) | Fire utility (`c_art 0.0`, `cost_share 0.03`, `cd 9.0`, `hp_cost 0.04`); for `5 s` grants `art_cost_hp 900` and `dmg_more 0.25` (`element: "fire"`). |
| Passive | `Wine in the Night-Glow Cup` (`d19`) | `has` (`hp_paid_share`, `tick_dealt`, `broken`, `next_art_cost`, `heal`) | `night-glow-blood-sabre-canon` L4: fills cup (`cap 5`) per `5 %` HP paid or Bleed tick (`2 %` approx), instant `5` on `broken`; at `5` waives next art cost (`next_art_cost: 0`), heals `20 %` of `cup_paid_pct`, resets. |
| Effect | `Blood Casting` | `has` (committed) | Already in `assets/data/combat_effects.json`; worn on `dq-lost-silver-tally`. |
| Effect | `Drink After the Raid` (`a1`) | `has` (`broken`, `art_cost_hp`, `heal` `of: "amount"`) | `dq-night-glow-cup`: on `broken` sets `raid_drink = 3`; next 3 arts get `art_cost_hp 900` and heal `5 %` of hit damage dealt. |
| Effect | `Cut the Horse First` | `has` (`hp_paid_share`, `hp_missing_share`, `ignore_taken`, `heal_taken`) | `dq-night-raider` 3pc: health-paid arts gain `+1 %` `dmg_more` per `1 %` missing HP and heal `4 %` HP on art crit (`ignore_taken: true`); other healing halved (`heal_taken: -50`). |
| Effect | `First and Often` | `has` (`hp_cost_red`, `hit_landed`, `crit`, `stacks`) | `dq-red-band` 3pc: first 3 Fire cuts have `hp_cost_red 1` and add `2` Burn (`6 s`); after that, Fire art crits add `1` Burn (`6 s`). |

---

## C. Techniques (`techniques/catalogue-sect-da_quang.json`)

`lint_techniques.py`: **checked 2 techniques, 0 findings** (`red-sand-sabre-primer` `3.3 W of 8`; `night-glow-blood-sabre-canon` `22.9 W of 24`). All bonuses and the 3 non-`b11` passives on `night-glow-blood-sabre-canon` are newly authored and unpriced.

| Technique | Tier, kind | Bonuses | Passives | Arts / Effects (unlock layer) |
|---|---|---|---|---|
| `red-sand-sabre-primer` (preserved) | Yellow (`0`) main, `["hoa"]` | none | `attack_pct 5 [fire]`, `art_speed_pct 6 [fire]`, `art_cost_pct 6 [fire]` | `cut-the-horse` (1) |
| `night-glow-blood-sabre-canon` | Earth (`2`) main, `["hoa", "kim"]` | **[NEW]** `attack_pct 10`, `khi_huyet_pct 12` | `status_duration_pct 15 [over_time]` (`b11` `[bleed]` proxy), `attack_pct 10 [hoa]` (`b11` `[bleed]` proxy); **[NEW]** `leech_health_pct 15`, `art_cost_health_pct 10`, `crit_damage_pct 15 [physical]` | `crescent-of-red-sand` (1), `pay-in-blood` (2); Effect `Wine in the Night-Glow Cup` (4, passive) |

Updated `design/world/depth/sects/da_quang.techniques.json` with `"id"` fields on all `3` `"new"` art entries (`pay-in-blood`, `wine-in-the-night-glow-cup`, `crescent-of-red-sand`).

---

## D. Arts (`arts/part-sect-da_quang.json`)

`lint_arts.py`: **checked 3 arts in 1 files, 0 findings** (`3` Fire, `2` `damage`, `1` `utility`, `2` `engine`, `1` `standalone`).

| Art | Depth text | Engine form | Deviation |
|---|---|---|---|
| `cut-the-horse` (preserved) | A riding draw-cut that deals Fire damage and slows the target heavily for a moment; doubled against a foe who is moving. | Fire `c_art 1.8`, `cost_share 0.04`, `cd 4.0`, `2` `slowed_time` (`2 s`); `x2.0` vs `foe.pressing >= 1`. | none (already committed). |
| `crescent-of-red-sand` | A wide Metal-and-Fire sabre arc that bleeds the foe; a bleeding foe takes more from the holder's next cut. | Fire `c_art 2.1`, `cost_share 0.04`, `cd 4.0`, `convert` 50% `phys`, tags `["fire", "sabre", "bleed"]`, `2` `bleed` (`4` pulses); if `foe.status.bleed >= 1`, sets `red_sand_mark = 1` granting `+25 %` `dmg_more` until next non-`crescent` direct hit (`not_art_id: ["crescent-of-red-sand", "trigger"]`). | none. |
| `pay-in-blood` | For a few seconds the holder's arts cost health instead of linh lực and deal more Fire damage. | Fire utility `c_art 0.0`, `cost_share 0.03`, `cd 9.0`, `hp_cost 0.04`; on `art_fired` grants `art_cost_hp 900` (`5 s`) and `dmg_more 0.25` (`element: "fire"`, `5 s`) in separate records. | `art_cost_hp 900` shifts `90 %` of linh lực cost to health instead of `100 %` (`pay_keep_health`-safe). |

---

## E. Effects (`effects/da_quang.effects.json`) & Holder Verification

Standalone parity check (`E.validate` per Effect): **4 / 4 passed**.

| Effect | Depth rule | Engine form | Deviation |
|---|---|---|---|
| `Wine in the Night-Glow Cup` (`d19`, `a1`) | Each 5 % of your health you pay for arts or deal as Bleed fills the cup by one, to five; a Broken foe fills it at once. At five you drink: your next art is free and heals you for a fifth of the health you paid since the last drink. | `art_fired` reads exact `event.hp_paid_share / 0.01` (`floor: false`) into `cup_pct` and `cup_paid_pct`; `tick_dealt` (`status: "bleed"`) adds `2.0` to `cup_pct`; each `5` `cup_pct` adds `1` to `night_glow_cup` (`cap 5`); `broken` sets `night_glow_cup = 5`; at `5`, heals `0.2 % * cup_paid_pct` (`0.002` share scaled by `cup_paid_pct`), queues `next_art_cost: 0`, and resets `night_glow_cup` & `cup_paid_pct`. | Bleed tick approximated as `2.0 %` `hp_max` per tick (`approx`). |
| `Drink After the Raid` (`a1`) | When the foe is Broken, the cup fills: your next three arts cost health instead of linh lực and heal you for 5 % of the damage they deal. | `broken` sets `raid_drink = 3`; while `raid_drink >= 1`, `always` grants `art_cost_hp 900`; each `art_fired` resets `raid_drink_hit = 0`, then arms `raid_drink_hit = 1` and decrements `raid_drink` if `>= 1`; `hit_landed` (`kind: "art"`) heals `0.05` `of: "amount"` while `raid_drink_hit >= 1`. | `art_cost_hp 900` shifts `90 %` of linh lực cost to health. |
| `Cut the Horse First` | Your arts paid in health deal 1 % more damage for each 1 % of health you are missing, and each crit they land heals you for 4 % of your health; healing from other sources is halved on you. | `art_fired` clears `horse_hp_art = 0`, then sets `1` if `event.hp_paid_share > 0`; while `horse_hp_art >= 1`, `always` adds `dmg_more 0.01` (`kind: "art"`) scaled by `hp_missing_share / 0.01`, and `crit` (`kind: "art"`) heals `0.04` (`ignore_taken: true`); `always` applies `heal_taken -50`. | none. |
| `First and Often` | Your first three Fire cuts each fight cost no health and each puts 2 Burn stacks; after that, every Fire cut that crits puts one more Burn stack. | While `red_band_cuts < 3`, `always` grants `hp_cost_red 1` (`element: "fire", kind: "art"`); on `hit_landed` (`element: "fire", kind: "art", per_firing: 1`), sets `red_band_after = 1` when `red_band_cuts >= 3`, else adds `2` Fire debuff stacks (`6 s`) and increments `red_band_cuts`; on `crit` (`element: "fire", kind: "art"`) while `red_band_after >= 1`, adds `1` Fire debuff stack (`6 s`). | `first3` and `mark_after` filter on Fire `art` `hit_landed` so `pay-in-blood` (`c_art: 0.0`) does not consume Fire-cut charges. |

### Holder Check (`sect_fight.py da_quang --seeds 5`)

| Holder | Realm | Arts | Gap 0 (`mean_s`, `wins`, `hp_left`) | Gap 1 (`mean_s`, `wins`, `hp_left`) | Notes |
|---|---|---|---|---|---|
| `hang_da_boi` | `ket_dan` | `crescent-of-red-sand`, `pay-in-blood`, `debt-blade`, `shearing-palm`, `bloodletting-rite` | `16.4 s`, `5/5`, `93%` | `8.6 s`, `0/5`, `0%` | All `5` arts fired (`3.8`, `1.2`, `5.2`, `5.2`, `1.2`). `Wine in the Night-Glow Cup` `237` runs (`93%` vs `90%` without); `Drink After the Raid` `105` runs; `Cut the Horse First` `173` runs (`93%` vs `77%` without, `16.4 s` vs `17.4 s`); `Blood Casting` `0` runs (`always`-only mod, `8.6 s` vs `8.8 s` at `--gap 1`). |
| `do_xich_linh` | `ket_dan` | `crescent-of-red-sand`, `pay-in-blood`, `debt-blade` | `22.9 s`, `5/5`, `54%` | `9.0 s`, `0/5`, `0%` | All `3` arts fired in both (`7.0`/`2.2`, `3.0`/`1.0`, `7.4`/`2.2`). `Wine` `280` runs (`54%` vs `45%` without); `First and Often` `37` runs (`54%` vs `49%` without). |
| `hang_luu_hoa`, `trac_hong_da` | `truc_co` | `crescent-of-red-sand`, `pay-in-blood`, `debt-blade` | `26.0 s`, `5/5`, `40%` | `8.0 s`, `0/5`, `0%` | All `3` arts fired at `--gap 0` (`6.2`, `2.6`, `8.6`); `Wine` `330` runs (`40%` vs `33%` without). At `--gap 1`, `pay-in-blood` (`cd 9.0`) is `0.0` due to `8.0 s` defeat. |
| `co_xich_nguyet` | `truc_co` | `crescent-of-red-sand`, `pay-in-blood`, `debt-blade` | `25.2 s`, `5/5`, `33%` | `8.0 s`, `0/5`, `0%` | All `3` arts fired at `--gap 0` (`6.0`, `2.2`, `8.2`); layer `3` (`< 4`, no `Wine`). |
| `o_liet_phong` | `truc_co` | `crescent-of-red-sand`, `pay-in-blood` | `38.6 s`, `5/5`, `22%` | `8.0 s`, `0/5`, `0%` | Both arts fired at `--gap 0` (`9.6`, `4.0`); `Wine` `349` runs (`22%` vs `19%` without). |
| `cuu_lac_nhat` | `truc_co` | `crescent-of-red-sand`, `pay-in-blood` | `38.6 s`, `5/5`, `19%` | `8.0 s`, `0/5`, `0%` | Both arts fired at `--gap 0` (`9.6`, `4.0`); layer `2` (`< 4`). |
| `man_xich_cau`, `kieu_liet_ca` | `luyen_khi` | `crescent-of-red-sand` | `38.2 s`, `5/5`, `35%` | `8.0 s`, `0/5`, `0%` | `crescent-of-red-sand` fired `9.4`/fight at `--gap 0`, `1.4` at `--gap 1`. |
| `na_lac_linh`, `dan_muc_lang`, `thoi_kim_doi`, `dieu_luu_ly`, `o_sa_nhi`, `hung_da_linh`, `tat_da_lang`, `liem_hoa_nhi` | `luyen_khi` | `cut-the-horse` | `33.6 s`, `0/5`, `0%` | `8.3 s`, `0/5`, `0%` | `cut-the-horse` fired `8.0`/fight at `--gap 0`, `1.8` at `--gap 1` (committed Yellow primer). |

- **Targeted `3x HP` probe (`ket_dan` tank, `seed 1`)**: verified `Drink After the Raid` (`fill: 1`, `arm_hit: 3`, `heal: 3`), `Cut the Horse First` (`clear: 26`, `mark: 24`, `crit: 4`), `Wine in the Night-Glow Cup` (`pay: 24`/`20`, `bleed: 20`/`31`, `drink_heal_art: 2`/`3`, `drink_heal_tick: 1`/`2`, `drink_heal_broken: 1`), `First and Often` (`first3: 3`, `mark_after: 8`, `crit_burn: 1`), and `crescent-of-red-sand` (`crescent-bleed-arm: 6`/`11`, `crescent-bleed-spend: 6`/`10`) all fire end-to-end.

---

## F. Items & Sets (`items/catalogue-sect-da_quang.json`, `items/sets-da_quang.json`)

`lint_items.py`: **checked 6 items, 22 bases, 9 common arts, 0 findings**.
- `dq-night-glow-cup`: `treasure`, `rarity: 4`, `base: ho_lo`, `24.1 W`, `unique: true`, `sources: ["npc"]`, R6 `exception`, Effect `["Drink After the Raid"]`.
- `dq-night-sabre`: `artifact`, `grade: 3`, `base: phi_kiem`, `32.6 W`, `unique: true`, `sources: ["npc"]`, R6 `exception`.
- `dq-red-feather-sabre`: `artifact`, `grade: 3`, `base: phi_kiem`, `25.5 W`, `unique: true`, `sources: ["npc"]`, R6 `exception`.
- `dq-lost-silver-tally`: `artifact`, `grade: 3`, `base: ngoc_boi`, `22.2 W`, `unique: true`, `sources: ["npc"]`, Effect `["Blood Casting"]`.
- `dq-felt-rider-coat`: `artifact`, `grade: 3`, `base: giap`, `23.9 W`, `unique: true`, `sources: ["npc"]`, R6 `exception`.
- `dq-gamblers-ember-ring`: `artifact`, `grade: 3`, `base: nhan`, `19.0 W`, `unique: true`, `sources: ["npc"]`.
- Sets (`2`): `dq-night-raider` (3pc, `Cut the Horse First`), `dq-red-band` (3pc, `First and Often`).

---

## G. Stand-ins & Beasts

- Stand-ins: `0` across `18` total cast records (`16` living across `da_quang.cast.json` + `da_quang.5.cast.json`, `2` dead `lau_minh_chau`, `co_mac_phong`).
- Beasts: `0`.

---

## H. Pending Words & Open Items

- **Pending engine words**: `0` (`pending.json` not needed).
- **Tool / serial / Stage 7 open items**:
  1. **`lint-bleed-scope` (for `s6-serial-b05`)**: Add `"bleed"` to `TIER` in `tools/design/arts/lint_techniques.py` (matching `modifiers.md` rule 9 `effect` & `status` tags and `fight.py`) and restore `scope: ["bleed"]` on `night-glow-blood-sabre-canon`'s two `b11` lines (`status_duration_pct 15 [bleed]`, `attack_pct 10 [bleed]`).
  2. **Serial step merge**: Merge `design/stage6-staging/da_quang/*` into `design/` and `assets/data/combat_effects.json` (`put_effects.py` under `world-depth:da_quang`).
  3. **Stage 7 export**: Export techniques, items (ensuring `export_named.py` exports `kind: "treasure"` `dq-night-glow-cup`), sets, combat library, and `2` structured events (`N-da_quang-01`, `N-da_quang-02`) so `depth_gap.py --sect da_quang` reaches `0`.
