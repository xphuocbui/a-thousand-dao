# Lễ Tuyền Phái (`le_tuyen`): Stage 6 record pass review (2026-11-27, headless job, decisions auto-accepted)

## Summary

**Built (all staged in `design/stage6-staging/le_tuyen/`; nothing exported, nothing outside allowed paths):**
- **4 techniques** (`techniques/catalogue-sect-le_tuyen.json`): the 3 depth lineage methods (`dew-gathering-breath`, `hundred-herb-mending-scripture`, `sweet-spring-wine-rite`), plus 1 new Yellow Earth+Fire servants' method, `yoke-and-axle-breath`, for the two Khấu brothers (`khau_dai_ung`, `khau_nhi_dam`). `still-moon-tide-scripture` is already committed in `design/techniques/catalogue-water.json`. Every bonus and passive on the staged techniques is new and sized to its tier (§C).
- **7 new arts** (`arts/part-sect-le_tuyen.json`): the 6 depth arts (`morning-dew`, `leaf-drip`, `hundred-herb-draught`, `bitter-root`, `open-the-cask`, `last-cup`), plus `shoulder-the-yoke` for `yoke-and-axle-breath`. All 7 art ids and `yoke-and-axle-breath` were registered in `design/world/depth/sects/le_tuyen.techniques.json`.
- **4 Effects** (`effects/le_tuyen.effects.json`): 2 item Effects (`Needle of Mending`, `Sealed Cask`) and 2 set Effects (`A Brimming Cup`, `Half Lake`). All 4 validate cleanly in `engine.validate`, and all 4 run and change fights in probes or `sect_fight.py`.
- **6 items and 2 sets** (`items/catalogue-sect-le_tuyen.json`, `items/sets-le_tuyen.json`): depth modifiers preserved verbatim (all 28 lines already run in `fight.py`), `sources: ["npc"]`, `unique: true`, and the R6 `exception` mark on all 6 weapons/armour/gourds.
- **2 stand-ins resolved** in `le_tuyen.cast.json` and `le_tuyen.5.cast.json`: `khau_dai_ung` (`hoang_tho` 5) and `khau_nhi_dam` (`hoang_tho` 3) switched to `yoke-and-axle-breath`. Gap report `stand_ins` is now `0`.
- **0 beasts** (`le_tuyen` has no `beasts.json`).
- **0 pending words** (`pending.json` is empty: all records run on existing engine words).
- **0 early promotions** (`cross_owner: 0`).

**Counts:**
- **Deviations:** `13` (§C–§F).
- **Decisions taken for the user:** `5` (§A).
- **Pending words:** `0`.
- **Never ran in `sect_fight.py`:** `Needle of Mending` (on `mai_le_tuyen`, because `sect_fight.py` slots only technique arts and not the weapon's common art `needle-rain`; verified in a dedicated probe with `needle-rain` slotted, 840 heal procs and 140 cleanse procs over 20 seeds).

**Checks (all run after final edit with `DEPTH_STAGE=C:\Users\xphuo\IdeaProjects\my-game\design\stage6-staging\le_tuyen`):**
- `lint_arts.py`: checked 7 arts in 1 file, **0 findings**.
- `lint_techniques.py`: checked 4 techniques, **0 findings** (`7.6 W / 8`, `15.9 W / 16`, `15.5 W / 16`, `7.8 W / 8`).
- `lint_items.py`: checked 6 items, **0 findings** (`unique 6 of 6`).
- `depth_check.py --quiet`: **findings: none**.
- `depth_gap.py --sect le_tuyen`: `stand_ins: 0`, `unknown_ids: 0`, `cross_owner: 0`, `engine_words: 0`, `wishes_open: 0`, `lines: 28/28 runs`.
- `sect_fight.py le_tuyen` (`gap 0` and `gap 1`, 10 seeds each): **0 REFUSED**, every art fires on all 18 living cast members.

**Open items (for Stage 7 / user):**
- `Needle of Mending` loadout toggle ("instead of striking") is approximated as heal+cleanse alongside the hit (`approx`), and `A Brimming Cup` heal-overflow ward fires on heal-tagged `art_fired` above 80 % linh lực (`approx`) until `heal_overflow` (queued by `thuy_vi`) and full-HP heal triggers exist.

---

## A. Decisions auto-accepted (user rule 2026-11-26), with reasons

1. **New Yellow servants' method `yoke-and-axle-breath` (`names: ["tho", "hoa"]`) for the two Khấu stand-ins.**
   - *Choice:* Create a `le_tuyen` Yellow main method (`shoulder-the-yoke` at layer 1) rather than cross-promoting another sect's Earth method.
   - *Reason:* Follows `_brief-record.md` Step 5 (lineage doesn't fit Earth-Fire roots; `le_tuyen.md` explicitly states the plain's Earth roots become cellar porters and cart drivers outside the Water/Wood gate). Both `khau_dai_ung` (`tho 50, hoa 30`) and `khau_nhi_dam` (`tho 46, hoa 28`) match `["tho", "hoa"]`, and keeping it inside `le_tuyen` creates zero cross-owner dependencies.
2. **Counter `wine_mist` instead of a stance `state` on `open-the-cask`.**
   - *Choice:* Track the 6 s spirit-wine mist via counter `wine_mist` instead of `s.state`.
   - *Reason:* Both `mai_le_tuyen` and `nhac_thuan_nhuong` slot `deep-lake-stance` (`still-moon-tide-scripture`), which uses `s.state = "deep-lake"`. A second `state` would overwrite Deep Lake every time `open-the-cask` fires (Băng Tâm Lesson 2).
3. **`Needle of Mending` approximated on `hit_landed` (`approx`), no new pending word.**
   - *Choice:* Heal for `event.amount` (`share: 1.0`, unthrottled so split needles heal their full damage) and cleanse 1 debuff stack (`per_pulse: 1`), matching both `tags: ["needle"]` and `art_id: "needle-rain"` (`not_tags: ["needle"]` to prevent double-firing on `family-metal.json`'s `needle-rain`).
   - *Reason:* Adding a loadout UI + compiler damage-suppression toggle for a single item (`ltp-sweet-dew-needles`) is not worth a new engine feature ("A new word must be worth it for builds"). Matching `not_tags: ["needle"]` on the `art_id: "needle-rain"` fallback avoids double-proccing while covering `common-arts.json`'s `needle-rain` (which lacks the `needle` tag).
4. **`A Brimming Cup` uses heal-tagged `art_fired` (above 80 % `qi_share`) + consecutive `overflow` pulse tracking (`approx`), no new pending word.**
   - *Choice:* Ward overflow triggers `ward_grow {share: 0.05, of: "hp"}` on `art_fired` (`tags: ["heal"]`, `own.qi_share >= 0.8`), and the 3 s full-linh-lực heal doubling counts consecutive `overflow` pulses (`brimming_overflow_tick` / `brimming_full_qi`) to grant `+100` `healing` until the next `heal`-tagged art fires.
   - *Reason:* In `engine.py:1593`, `heal_restored` does not fire at 100 % HP (`got == 0`), and `ward_grow` takes `hp`/`peak`, not `amount`. Tracking `overflow` pulses respects `reserved` usable linh lực (`qi_use()`), and firing on `art_fired` (`tags: ["heal"]`) makes `A Brimming Cup` visibly strengthen heals and raise the stance ward in real fights today (verified in `brimming_ready`: 20/20 wins at 45 % HP vs 0/20 without).
5. **`bitter-root` uses `debuff: [2, 6]` + `statuses: [withering 4s]` (`c_art: 1.2`) and `hundred-herb-draught` adds `c_heal: 0.8` + `stack_more`.**
   - *Choice:* Keep `bitter-root`'s `withering` directly in `statuses` (charge `0.18 + 0.40 = 0.58 <= 0.60`, honest against `lint_arts.py`) and give `hundred-herb-draught` a small `c_heal: 0.8` (`tags: ["wood", "buff", "heal"]`) alongside `stack_more: 0.10` per 3 Wood buff stacks.
   - *Reason:* Avoids gaming `CHARGE_FAIL` via hidden status Effects, gives pure-Wood holders (`nhac_du_huong`, `ngai_bach_chi`, `phuong_kim_cham`) real sustain that feeds `A Brimming Cup` / `still-moon-tide-scripture` heal hooks, and expresses "stacks stronger" cleanly via `stack_more` without recursion.

---

## B. Mechanic table (Step 1)

| Record | Mechanic | Engine status | Implementation |
|---|---|---|---|
| `dew-gathering-breath` / `morning-dew` | Small heal + clear 1 debuff stack | Has | `c_heal: 0.7`, `cleanse: 1`, `tags: ["water", "heal", "cleanse"]` |
| `dew-gathering-breath` / `leaf-drip` | Light Water hit + 1 Wood stack | Has | `c_art: 1.5`, `hit_landed` -> `stacks {el: wood, n: 1, for: 8, side: foe}` |
| `hundred-herb-mending-scripture` / `hundred-herb-draught` | 3 healing Wood buff stacks that stack stronger | Has | `c_heal: 0.8`, `buff: [3, 10]`, `always` `scale` per 3 `own.buff.wood` -> `stack_more: 0.1` (`element: wood`) |
| `hundred-herb-mending-scripture` / `bitter-root` | Wood stacks on foe halving healing received | Has | `c_art: 1.2`, `debuff: [2, 6]`, `statuses: [withering 4s]` |
| `sweet-spring-wine-rite` / `open-the-cask` | Wine mist: HoT, resist fear, foe Water stacks + 1 Drunk / 2 s | Has | `wine_mist` counter (6 s): `status_resist 20` + `soul_res 15`, `heal 0.015`, `stacks water 1 (8s)`, `drunk` (`cooldown: 2.0`) |
| `sweet-spring-wine-rite` / `last-cup` | At 5+ foe Water stacks: +2 Drunk, +1 Heavy Breath | Has | `c_art: 1.6`, `debuff [1, 8]`, `empower` (`foe.debuff.water >= 5`) -> `drunk` 2 + `heavy_breath` 1 (4s) |
| `yoke-and-axle-breath` / `shoulder-the-yoke` | New Yellow Earth+Fire servants' method | Has | `c_art: 1.8`, `buff [1, 8]` Earth |
| `Needle of Mending` (`ltp-sweet-dew-needles`) | Needle arts set in loadout to heal for damage + clear 1 debuff | Decision / approx | `hit_landed` (`tags: [needle]` and `art_id: needle-rain` + `not_tags: [needle]`): `heal {of: amount, share: 1.0}` + `cleanse 1` (`per_pulse: 1`) |
| `Sealed Cask` (`ltp-hundred-jar-seal`) | Water art hit vs 3+ Water stacks -> 1 Drunk + 1 Heavy Breath | Has | `hit_landed` (`element: water, kind: art`), `foe.debuff.water >= 3`, `per_pulse: 1` -> `drunk 1` + `heavy_breath 1 (4s)` |
| `A Brimming Cup` (`ltp-sweet-spring` 3pc) | Heals above 80 % qi overflow into ward (~half heal); 3 s full qi doubles next heal | Decision / approx | `art_fired` (`tags: [heal]`, `qi_share >= 0.8`) -> `ward_grow 0.05 hp`; consecutive `overflow` pulses (3 s) -> `+100 healing` until next `heal` art |
| `Half Lake` (`ltp-hundred-jars` 3pc) | Foe at 6+ Water stacks gains 1 Drunk per pulse | Has | `pulse`, `foe.debuff.water >= 6` -> `status {id: drunk, stacks: 1, side: foe}` |

---

## C. Techniques (`catalogue-sect-le_tuyen.json`)

All bonuses and passives below are **new** (the depth proposals name none) and sized against same-tier catalogue peers.

| Technique | Tier, kind | Bonuses | Passives (new) | Abilities (unlock) | Peer & W |
|---|---|---|---|---|---|
| `dew-gathering-breath` | Yellow main, Wood+Water | none | `healing_pct` 4 `[]`, `health_regen_inc_pct` 8 `[]`, `linh_luc_regen_inc_pct` 4 `[]` | `morning-dew` (1), `leaf-drip` (2) | `clear-frost-breath` / `warm-hearth-breath` (`7.6 W of 8`) |
| `hundred-herb-mending-scripture` | Profound main, Wood | `khi_huyet_pct` 12 | `stack_effect_pct` 10 `[moc, buff]`, `stack_duration_pct` 10 `[moc, buff]`, `stack_effect_pct` 8 `[moc, debuff]`, `healing_pct` 8 `[]`, `health_regen_inc_pct` 10 `[]`, `art_speed_pct` 6 `[moc]` | `hundred-herb-draught` (1), `bitter-root` (2) | `verdant-cycle-scripture` (`15.9 W of 16`) |
| `sweet-spring-wine-rite` | Profound secret, Water | `linh_luc_pct` 12 | `stack_duration_pct` 14 `[thuy, debuff]`, `stack_effect_pct` 10 `[thuy, debuff]`, `status_duration_pct` 10 `[curse]`, `healing_pct` 8 `[]`, `art_speed_pct` 8 `[thuy]` | `open-the-cask` (1), `last-cup` (3) | `snow-plum-sword` (`15.5 W of 16`) |
| `yoke-and-axle-breath` (new) | Yellow main, Earth+Fire | none | `khi_huyet_pct` 4 `[]`, `defense_pct` 3 `[]`, `health_regen_inc_pct` 8 `[]` | `shoulder-the-yoke` (1) | `warm-hearth-breath` (`7.8 W of 8`) |

**Deviations (D1–D4):**
- **D1–D3:** New tier-sized bonuses and passives added to `dew-gathering-breath`, `hundred-herb-mending-scripture`, and `sweet-spring-wine-rite`.
- **D4:** New Yellow Earth+Fire servants' method `yoke-and-axle-breath` authored for the Khấu stand-ins.

---

## D. Arts (`part-sect-le_tuyen.json`)

`lint_arts.py`: **7 arts, 0 findings**.

| Art | Depth text | Engine form | Deviation |
|---|---|---|---|
| `morning-dew` | Small heal on holder + clear 1 debuff stack | Water `heal`, `c_art 0`, `c_heal 0.7`, `cleanse 1`, `cost 0.03`, `cd 5.0` | none |
| `leaf-drip` | Light Water hit that lays 1 Wood stack | Water `damage`, `c_art 1.5`, `cost 0.03`, `cd 3.0`; `hit_landed` -> 1 Wood debuff (8 s) | **D5:** `stacks` in `effects` because `art.debuff` uses `art.element` |
| `hundred-herb-draught` | 3 healing Wood stacks; each heals over time and stacks stronger | Wood `heal`, `c_art 0`, `c_heal 0.8`, `cost 0.04`, `cd 5.0`, `buff [3, 10]`; `always` `scale` per 3 `own.buff.wood` -> `+10% stack_more` (wood) | **D6:** added `c_heal 0.8` (`heal` tag) and live `stack_more` scaling |
| `bitter-root` | Wood stacks on foe that halve healing received while they last | Wood `curse`, `c_art 1.2`, `cost 0.04`, `cd 5.0`, `debuff [2, 6]`, `statuses [withering 4s]` | **D7:** fixed 4-pulse `withering` in `statuses` (charge `0.58 <= 0.60`) rather than bound to Wood duration |
| `open-the-cask` | Wine mist for several s: HoT, resist fear, foe Water stacks + 1 Drunk / 2 s | Water `curse`, `c_art 0`, `cost 0.05`, `cd 8.0`; `wine_mist` counter (6 s): `status_resist 20` + `soul_res 15`, `heal 0.015`, 1 Water (8 s)/s, 1 Drunk / 2 s | **D8:** "resist fear" -> `status_resist` + `soul_res`; counter avoids stance clash with `deep-lake` |
| `last-cup` | Against foe with 5+ Water stacks: 2 Drunk + 1 Heavy Breath | Water `curse`, `c_art 1.6`, `cost 0.04`, `cd 5.0`, `debuff [1, 8]`; `empower` (`foe.debuff.water >= 5`) -> 2 Drunk + 1 Heavy Breath (4 s) | **D9:** base `c_art 1.6` + 1 Water stack so it builds stacks before empowering |
| `shoulder-the-yoke` (new) | Porter's Earth blow granting 1 Earth buff stack | Earth `damage`, `c_art 1.8`, `cost 0.03`, `cd 3.0`, `buff [1, 8]` | part of **D4** |

---

## E. Effects (`effects/le_tuyen.effects.json`)

| Effect (source) | Depth text | Engine form | Deviation |
|---|---|---|---|
| `Needle of Mending` (`ltp-sweet-dew-needles`) | Needle arts may be set in loadout to heal for damage + clear 1 debuff instead of striking | `hit_landed` (`tags: [needle]` and `art_id: needle-rain` + `not_tags: [needle]`): `heal {of: amount, share: 1.0}` + `cleanse 1` (`per_pulse: 1`) | **D10:** loadout strike-skip not modelled (`approx`); `not_tags` avoids double-proccing `family-metal`'s `needle-rain` |
| `Sealed Cask` (`ltp-hundred-jar-seal`) | Foe struck by Water art at 3+ Water stacks gains 1 Drunk + 1 Heavy Breath | `hit_landed` (`element: water, kind: art`), `foe.debuff.water >= 3`, `per_pulse: 1` -> `drunk 1` + `heavy_breath 1 (4s)` | **D11:** added `per_pulse: 1` limit |
| `A Brimming Cup` (`ltp-sweet-spring` 3pc) | Heals above 80 % qi overflow into ward (~half heal); 3 s full qi doubles next heal | `art_fired` (`tags: [heal]`, `qi_share >= 0.8`) -> `ward_grow 0.05 hp`; consecutive `overflow` pulses (3 s) -> `+100 healing` until next `heal` art | **D12:** uses `art_fired` + `ward_grow 0.05 hp` (`approx`) because `heal_restored` skips 100 % HP and `ward_grow` takes `hp`/`peak` |
| `Half Lake` (`ltp-hundred-jars` 3pc) | Foe at 6+ Water stacks gains 1 Drunk per pulse | `pulse`, `foe.debuff.water >= 6` -> `drunk 1` | none |

---

## F. Items and Sets (`items/catalogue-sect-le_tuyen.json`, `items/sets-le_tuyen.json`)

- **6 items**, modifiers preserved verbatim (`26.0–36.8 W`, unpriced), `sources: ["npc"]`, `unique: true`, all 6 carrying the R6 `exception` (**D13**).
- **2 sets** (`ltp-sweet-spring`, `ltp-hundred-jars`), 2-piece modifiers preserved verbatim, 3-piece bonuses split into `"effect"` + `"rule"`.
- `lint_items.py`: **6 items, 0 findings**.

---

## G. Stand-ins & Beasts (`le_tuyen.cast.json`, `le_tuyen.5.cast.json`)

| Person | Realm | Was | Now | Beasts |
|---|---|---|---|---|
| `khau_dai_ung` | `luyen_khi` 2 | `hoang_tho` 5 | `yoke-and-axle-breath` 5 | none |
| `khau_nhi_dam` | `luyen_khi` 1 | `hoang_tho` 3 | `yoke-and-axle-breath` 3 | none |

---

## H. Holder Table & Probes (`sect_fight.py le_tuyen`, 10 seeds; + 20-seed probes)

**Every technique art fires at both `gap 0` and `gap 1` (0 REFUSED).**

| Holder / Probe | Result (`gap 0` / `gap 1`) | Effect (`with / without`, runs) | Note |
|---|---|---|---|
| `mai_le_tuyen` (KD 2) | `16.4 s 10/10 100%` / `14.2 s 0/10 0%` | **A Brimming Cup**: `16.4 s 100%` vs `16.6 s 100%` (**364 runs** `gap 0`, **300 runs** `gap 1`); **Needle of Mending**: **0 runs** (`NEVER_RAN`) | `sect_fight` does not slot item common art `needle-rain`; see probes below |
| `nhac_thuan_nhuong` (KD 0) | `23.1 s 10/10 100%` / `34.6 s 0/10 0%` | **Sealed Cask**: `gap 0` 64 runs; `gap 1` `34.6 s 0%` vs `28.2 s 2%` (**102 runs**); **Half Lake**: `gap 0` 137 runs; `gap 1` `34.6 s 0%` vs `20.5 s 0%` (**250 runs**) | Massive +14.1 s survival swing on `Half Lake` at `gap 1` |
| `ha_thanh_to`, `can_tri_vi`, `gia_tuyen_phong` (TC) | `56.3–56.5 s 10/10 88%` / `8.3 s 0/10 0%` | n/a | All 4 arts (`hundred-herb-draught`, `bitter-root`, `open-the-cask`, `last-cup`) fire 6–11×/fight |
| `phuong_kim_cham`, `nhac_du_huong`, `ngai_bach_chi` (TC) | `63.4 s 5/10 8%` / `8.1 s 0/10 0%` | n/a | Both Wood arts fire 11.2×/fight |
| `trac_linh_tuyen`, `loc_thao_nhi`, `nhu_tri_thu`, `lien_than_ha` (LK) | `60.4 s 1/10 2%` / `8.0 s 0/10 0%` | n/a | Both Wood arts fire 9.6×/fight |
| `lu_tieu_khuc`, `sa_au_lan`, `bac_trieu_am` (LK) | `51.3–51.7 s 4/10 7–8%` / `8.0 s 0/10 0%` | n/a | `morning-dew` 9.1×, `leaf-drip` 15.3× |
| `truong_ham_chuoc` (LK 0) | `47.0 s 0/10 0%` / `8.0 s 0/10 0%` | n/a | `morning-dew` fires 8.5× (layer 1 outer vat-stirrer: pure heal+cleanse, basic attack only) |
| `khau_dai_ung`, `khau_nhi_dam` (LK, stand-in) | `44.9–45.0 s 1/10 1%` / `8.0 s 0/10 0%` | n/a | `shoulder-the-yoke` fires 13.9×/fight |
| **Probe:** `mai_le_tuyen` (`needle-rain` + `leaf-drip` vs burn KD foe, 20 seeds) | `62.5 s 20/20 24%` | **Needle of Mending**: **840 heal procs, 140 cleanse procs** | Confirms `Needle of Mending` heals & cleanses without double-counting (`common` fallback gated by `not_tags`) |
| **Probe:** `mai_le_tuyen` (`morning-dew` only vs typical KD, 20 seeds) | `65.0 s 20/20 45%` vs `64.9 s 0/20 0%` | **A Brimming Cup**: **359 overflow, 300 ward procs** | +20 wins (+45 % HP) from `A Brimming Cup` |

**Băng Tâm pilot checklist:**
- [x] Every Effect changes the fight with and without it on its real holders (or probe with `needle-rain`), and every art fires.
- [x] No holder slots two stances without a combined stance (`open-the-cask` uses counter `wine_mist`, leaving `deep-lake` intact).
- [x] Each Effect works for holders lacking optional mechanics (`A Brimming Cup` uses `ward_grow`, creating the stance ward if absent).
- [x] Vague words ("resist fear", "stacks stronger", "overflows", "several seconds") pinned in `rule` fields.
- [x] New technique bonuses and passives sized against same-tier peers (`7.6/8`, `15.9/16`, `15.5/16`, `7.8/8`) and marked new above.

---

## I. Open items

- Stage 7 export will attach `ltp-sweet-dew-needles`'s common art `needle-rain` onto `mai_le_tuyen` (note: `family-metal.json` and `common-arts.json` both define `id: "needle-rain"`, so `Needle of Mending` matches either via `tags: ["needle"]` or `art_id: "needle-rain" + not_tags: ["needle"]`).
- If `heal_overflow` (`thuy_vi/pending.json`) is built in the serial step, `A Brimming Cup` may optionally also listen to `heal_overflow` for passive regeneration overflows, though `art_fired` (`tags: ["heal"]`) already works cleanly on active heals.
